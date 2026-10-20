unit AoWHTMLMemo;

{ The AoWHTMLMemo unit of aowInt.dpl: TaowHTMLMemo, a window that shows a text with a small set
  of HTML-like tags (the text must start with <INT>): <P> and <BR> break lines, <FONT=file>,
  <ITEMHEIGHT=n>, <COLOR=rrggbb>, <SPACING=n> and <ALIGN=LEFT|CENTER|RIGHT> change the style
  from there on (one TChangeInfo per change), <BACKGROUND=file INDEX=n> picks the background
  texture. SetSize parses and wraps the text into FLines; Draw renders it once into a back
  surface (FBackSurface) of the size of the whole text and blits the visible part, scrolled by
  the vertical scroll bar. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWComp, AOWInterfaceImgLib, AoWWinControl, AOWWinManager, AoWBaseWin, AOWToolTip,
  AoWControl, AoWVScroll;

type
  { the state of the tag parser of SetSize }
  TIntParseMode = (pNone, pStart, pFont, pItemHeight, pColor, pBG, pInBG, pBGIndex, pSpace,
    pAlign);
  TaowAlign = (aLeft, aCenter, aRight);

  { AoWHTMLMemo.TChangeInfo (instance size 32): a style change in the text. +4 FHeight (the line
    height), +8 FColor, +$C FFont (the font file, '' for the current font), +$10 FAlign, +$14
    FPos (the character of the line where it starts), +$18 FLine, +$1C FSpacing }
  TChangeInfo = class(TObject)
  public
    FHeight: Integer;
    FColor: TColor;
    FFont: string;
    FAlign: TaowTextAlign;
    FPos: Integer;
    FLine: Integer;
    FSpacing: Integer;
  end;

  { AoWHTMLMemo.TaowHTMLMemo (instance size 548). Fields: +$1EC F1EC (a list that is created and
    freed only), +$1F0 FChanges (TChangeInfo), +$1F4 FLines (the wrapped lines), +$1F8 FItems
    (the text), +$1FC FVScrollBar, +$200 FFilename, +$204 FScrollWidth, +$208 FBackDrawn (the
    back surface holds the text), +$20C FImages (the background textures), +$210 FTopItem (the
    first pixel row shown), +$214 FFonts (the fonts loaded, TImageLibraryFont), +$218 FAOWWindow,
    +$21C FTextWidth, +$220 FTextHeight (the size of the back surface). }
  TaowHTMLMemo = class(TAOWBaseWindow)
  public
    F1EC: TList;
    FChanges: TList;
    FLines: TStringList;
    FItems: TStringList;
    FVScrollBar: TAOWVScrollBar;
    FFilename: string;
    FScrollWidth: Integer;
    FBackDrawn: Boolean;
    FImages: TInterfaceIL;
    FTopItem: Integer;
    FFonts: TList;
    FAOWWindow: TAOWBaseWindow;
    FTextWidth: Integer;
    FTextHeight: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnChangeText(Sender: TObject); override;
    procedure SetSize; override;
    procedure Update; override;
    procedure InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent); override;
    procedure SetOwner(Value: TAoWComponent); override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure SetAOWWindow(Value: TAOWBaseWindow);
    procedure SetFStrings(Value: TStringList);
    procedure SetVScroll(Value: TAOWVScrollBar);
    procedure SetListOff(Value: Integer);
    procedure SetFileName(Value: string);
    function LoadFont(FileName: string): Boolean;
    property Items: TStringList read FItems write SetFStrings;
    property ListOffset: Integer read FTopItem write SetListOff;
  published
    property WinHeight;
    property AOWWindow: TAOWBaseWindow read FAOWWindow write SetAOWWindow;
    property VScrollBar: TAOWVScrollBar read FVScrollBar write SetVScroll;
    property Filename: string read FFilename write SetFileName;
    property FreeSurfaceOnHide: Boolean read FFreeSurfaceOnHide write FFreeSurfaceOnHide;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property MaskColor: TColor read FMaskColor write FMaskColor;
  end;

procedure Register;

implementation

{ TaowHTMLMemo }

constructor TaowHTMLMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLines := TStringList.Create;
  FItems := TStringList.Create;
  FItems.OnChange := OnChangeText;
  FChanges := TList.Create;
  F1EC := TList.Create;
  FFonts := TList.Create;
  FImages := TInterfaceIL.Create(Self);
end;

destructor TaowHTMLMemo.Destroy;
var
  I: Integer;
begin
  FLines.Destroy;
  FItems.Destroy;
  F1EC.Free;
  for I := 0 to FChanges.Count - 1 do
    TChangeInfo(FChanges[I]).Free;
  for I := 0 to FFonts.Count - 1 do
    TImageLibraryFont(FFonts[I]).Free;
  FFonts.Free;
  FChanges.Free;
  FImages.Free;
  inherited Destroy;
end;

procedure TaowHTMLMemo.InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent);
begin
  if FValid and FVisible then
    AddDrawRect(ARect, Sender);
end;

procedure TaowHTMLMemo.SetOwner(Value: TAoWComponent);
begin
  inherited SetOwner(Value);
  FAOWWindow := TAOWBaseWindow(FAOWOwner);
end;

procedure TaowHTMLMemo.SetAOWWindow(Value: TAOWBaseWindow);
begin
  SetOwner(Value);
end;

procedure TaowHTMLMemo.SetFStrings(Value: TStringList);
begin
  FItems.Clear;
  FItems.AddStrings(Value);
end;

procedure TaowHTMLMemo.SetVScroll(Value: TAOWVScrollBar);
begin
  if Value <> FVScrollBar then
  begin
    FVScrollBar := Value;
    if FVScrollBar <> nil then
      FVScrollBar.Priority := FPriority;
    FSized := False;
  end;
end;

procedure TaowHTMLMemo.SetListOff(Value: Integer);
begin
  if Value <> FTopItem then
  begin
    FTopItem := Value;
    FSurfaceValid := False;
  end;
end;

procedure TaowHTMLMemo.SetFileName(Value: string);
begin
  if (Value <> FFilename) and FileExists(Value) then
  begin
    FFilename := Value;
    FItems.LoadFromFile(FFilename);
  end;
end;

procedure TaowHTMLMemo.OnChangeText(Sender: TObject);
begin
  SetListOff(0);
  FSized := False;
end;

{ LoadFont makes the font in FileName (relative to the program) the current font, loading it
  the first time }
function TaowHTMLMemo.LoadFont(FileName: string): Boolean;
var
  Font: TImageLibraryFont;
  I: Integer;
begin
  FileName := ExtractFilePath(Application.ExeName) + FileName;
  Font := nil;
  I := 0;
  while (I < FFonts.Count) and (Font = nil) do
  begin
    if TImageLibraryFont(FFonts[I]).FileName = FileName then
      Font := FFonts[I];
    Inc(I);
  end;
  if (Font = nil) and FileExists(FileName) then
  begin
    Font := TImageLibraryFont.Create(Self);
    Font.FontColorPaletteIndex := 1;
    Font.LoadFromFile(FileName);
    FFonts.Add(Font);
  end;
  if Font <> nil then
    FAOWFont := Font;
  Result := Font <> nil;
end;

{ SetSize parses the text into FLines and FChanges, wrapping the lines at the width of the
  window, and sets up the scroll bar }
procedure TaowHTMLMemo.SetSize;
var
  CI: TChangeInfo;
  H: Integer;
  LineIdx: Integer;
  State: TIntParseMode;
  I, J, Last, TextStart, TextEnd, TagStart: Integer;
  C: Char;
  P: PChar;
  S: string;
  K, V: Integer;

  procedure NewLine;
  begin
    FLines.Add('');
    H := H + CI.FHeight;
    Inc(LineIdx);
  end;

  { AddText adds the words of S to the current line, breaking it where the next word does not
    fit; it tests S[I] for a space, one character before the one it means (original bug) }
  procedure AddText(const S: string);
  var
    TW, W, Start: Integer;
    Word: string;
    I, Len: Integer;
  begin
    if FAOWFont <> nil then
    begin
      I := 0;
      Start := 0;
      Len := Length(S);
      W := FAOWFont.GetTextWidth(FLines[LineIdx]) + FBorderWidth * 2 + FScrollWidth;
      while I < Len do
      begin
        if (S[I] = ' ') or (I = Len - 1) then
        begin
          if I = Len - 1 then
            Inc(I);
          Word := Copy(S, Start + 1, I - Start);
          TW := FAOWFont.GetTextWidth(Word);
          if W + TW > FWinWidth then
          begin
            NewLine;
            FLines[LineIdx] := FLines[LineIdx] + Word;
            W := FBorderWidth * 2 + FScrollWidth + TW;
          end
          else
          begin
            FLines[LineIdx] := FLines[LineIdx] + Word;
            W := W + TW;
          end;
          Start := I;
        end;
        Inc(I);
      end;
    end;
  end;

  procedure NewChange;
  var
    N: TChangeInfo;
  begin
    N := TChangeInfo.Create;
    N.FHeight := CI.FHeight;
    N.FColor := CI.FColor;
    N.FFont := CI.FFont;
    N.FAlign := CI.FAlign;
    N.FSpacing := CI.FSpacing;
    N.FPos := CI.FPos;
    N.FLine := CI.FLine;
    FChanges.Add(N);
    CI := N;
  end;

  procedure ParseTag(Tag: string);
  begin
    Tag := UpperCase(Tag);
    case State of
      pInBG:
        if Tag = 'INDEX' then
          State := pBGIndex;
    else
      if Tag = 'P' then
      begin
        NewLine;
        NewLine;
      end
      else if Tag = 'BR' then
        NewLine
      else if Tag = 'FONT' then
        State := pFont
      else if Tag = 'ITEMHEIGHT' then
        State := pItemHeight
      else if Tag = 'COLOR' then
        State := pColor
      else if Tag = 'SPACING' then
        State := pSpace
      else if Tag = 'ALIGN' then
        State := pAlign
      else if Tag = 'BACKGROUND' then
        State := pBG;
    end;
  end;

begin
  FScrollWidth := 0;
  if FVScrollBar <> nil then
  begin
    FScrollWidth := FVScrollBar.WinWidth;
    FVScrollBar.Position := FTopItem;
  end;
  H := FTextHeight;
  FLines.Clear;
  State := pNone;
  if (FItems.Count > 0) and (UpperCase(Copy(FItems[0], 1, 5)) = '<INT>') then
  begin
    FLines.Add('');
    H := FBorderHeight * 2;
    FImages.Clear;
    for I := 0 to FChanges.Count - 1 do
      TChangeInfo(FChanges[I]).Free;
    FChanges.Clear;
    CI := TChangeInfo.Create;
    CI.FHeight := 10;
    CI.FColor := $FFFFFF;
    CI.FFont := '';
    CI.FAlign := taLeft;
    CI.FPos := 0;
    CI.FLine := 0;
    CI.FSpacing := 0;
    FChanges.Add(CI);
    LineIdx := 0;
    for I := 0 to FItems.Count - 1 do
    begin
      P := Pointer(FItems[I]);
      Last := Length(string(P)) - 1;
      TextStart := 0;
      TextEnd := -1;
      TagStart := 0;
      for J := 0 to Last do
      begin
        C := P[J];
        case State of
          pNone:
            case C of
              '<':
                begin
                  State := pStart;
                  TextEnd := J - 1;
                  TagStart := J + 1;
                end;
            end;
          pStart, pInBG:
            case C of
              '>':
                begin
                  ParseTag(Copy(string(P), TagStart + 1, J - TagStart));
                  State := pNone;
                  TextStart := J + 1;
                end;
              ' ', '=':
                begin
                  ParseTag(Copy(string(P), TagStart + 1, J - TagStart));
                  TagStart := J + 1;
                end;
            end;
          pFont:
            if C in [' ', '>'] then
            begin
              CI.FPos := Length(FLines[LineIdx]);
              CI.FLine := LineIdx;
              CI.FFont := Copy(string(P), TagStart + 1, J - TagStart);
              if CI.FFont <> '' then
                if not LoadFont(CI.FFont) then
                  CI.FFont := '';
              NewChange;
              if C = '>' then
              begin
                State := pNone;
                TextStart := J + 1;
              end
              else
              begin
                State := pStart;
                TagStart := J + 1;
              end;
            end;
          pItemHeight:
            if C in [' ', '>'] then
            begin
              CI.FPos := Length(FLines[LineIdx]);
              CI.FLine := LineIdx;
              try
                CI.FHeight := StrToInt(Copy(string(P), TagStart + 1, J - TagStart));
              except
              end;
              NewChange;
              if C = '>' then
              begin
                State := pNone;
                TextStart := J + 1;
              end
              else
              begin
                State := pStart;
                TagStart := J + 1;
              end;
            end;
          pColor:
            if C in [' ', '>'] then
            begin
              CI.FPos := Length(FLines[LineIdx]);
              CI.FLine := LineIdx;
              if J - TagStart = 6 then
              begin
                CI.FColor := 0;
                for K := 0 to 5 do
                begin
                  V := Ord(P[TagStart + K]);
                  if V < $3A then
                    V := V - $30
                  else
                    V := V - $37;
                  CI.FColor := CI.FColor shl 4 + V;
                end;
                NewChange;
              end;
              if C = '>' then
              begin
                State := pNone;
                TextStart := J + 1;
              end
              else
              begin
                State := pStart;
                TagStart := J + 1;
              end;
            end;
          pSpace:
            if C in [' ', '>'] then
            begin
              CI.FPos := Length(FLines[LineIdx]);
              CI.FLine := LineIdx;
              try
                CI.FSpacing := StrToInt(Copy(string(P), TagStart + 1, J - TagStart));
                if FAOWFont <> nil then
                  FAOWFont.CharacterDistance := CI.FSpacing;
              except
              end;
              NewChange;
              if C = '>' then
              begin
                State := pNone;
                TextStart := J + 1;
              end
              else
              begin
                State := pStart;
                TagStart := J + 1;
              end;
            end;
          pAlign:
            if C in [' ', '>'] then
            begin
              S := UpperCase(Copy(string(P), TagStart + 1, J - TagStart));
              CI.FPos := Length(FLines[LineIdx]);
              CI.FLine := LineIdx;
              if S = 'RIGHT' then
                CI.FAlign := taRight
              else if S = 'CENTER' then
                CI.FAlign := taCenter
              else
                CI.FAlign := taLeft;
              NewChange;
              if C = '>' then
              begin
                State := pNone;
                TextStart := J + 1;
              end
              else
              begin
                State := pStart;
                TagStart := J + 1;
              end;
            end;
          pBG:
            if C in [' ', '>'] then
            begin
              if FileExists(ExtractFilePath(Application.ExeName) +
                Copy(string(P), TagStart + 1, J - TagStart)) then
                FImages.LoadFromFile(ExtractFilePath(Application.ExeName) +
                  Copy(string(P), TagStart + 1, J - TagStart));
              FILIndexTexture := 0;
              if C = '>' then
              begin
                State := pNone;
                TextStart := J + 1;
              end
              else
              begin
                State := pInBG;
                TagStart := J + 1;
              end;
            end;
          pBGIndex:
            if C in [' ', '>'] then
            begin
              try
                FILIndexTexture := StrToInt(Copy(string(P), TagStart + 1, J - TagStart));
              except
              end;
              if C = '>' then
              begin
                State := pNone;
                TextStart := J + 1;
              end
              else
              begin
                State := pInBG;
                TagStart := J + 1;
              end;
            end;
        end;
        if TextEnd >= TextStart then
        begin
          AddText(Copy(string(P), TextStart + 1, TextEnd - TextStart + 1));
          TextStart := TextEnd;
        end;
      end;
      case State of
        pNone:
          if TextStart <= Last then
            AddText(Copy(string(P), TextStart + 1, Last - TextStart + 1));
        pStart:
          if TagStart <= Last then
            ParseTag(Copy(string(P), TagStart + 1, Last - TagStart));
      end;
    end;
    H := H + CI.FHeight;
  end;
  if (FWinWidth - FScrollWidth <> FTextWidth) or (FTextHeight <> H) then
  begin
    FTextWidth := FWinWidth - FScrollWidth;
    FTextHeight := H;
    if FTextHeight < FWinHeight then
      FTextHeight := FWinHeight;
    if FBackSurface <> nil then
      FBackSurface.Resize(FTextWidth, FTextHeight);
  end;
  FSurfaceValid := False;
  FBackDrawn := False;
  if FVScrollBar <> nil then
  begin
    if FAOWWindow <> FVScrollBar.AOWWindow then
      FVScrollBar.AOWWindow := FAOWWindow;
    FVScrollBar.Min := 0;
    FVScrollBar.Max := FTextHeight;
    FVScrollBar.Priority := FPriority + 1;
    FVScrollBar.Position := FTopItem;
    FVScrollBar.NumberVisible := FWinHeight;
    FVScrollBar.WinHeight := FWinHeight;
    FVScrollBar.LargeChange := FWinHeight;
    FVScrollBar.SmallChange := 20;
    FVScrollBar.Visible := FVisible;
    FVScrollBar.FSized := False;
    FVScrollBar.WinLeft := FWinLeft + FWinWidth - FVScrollBar.WinWidth;
    FVScrollBar.WinTop := FWinTop;
  end;
  inherited SetSize;
end;

{ Draw renders the text into the back surface when it changed, then blits the dirty rectangles
  of the window (or the whole visible part) from it }
procedure TaowHTMLMemo.Draw(SurfDesc: TSurfaceDesc);
var
  I, OldLeft, OldTop, Pos, LH, X, Y: Integer;
  Align: TaowTextAlign;
  FontName: string;
  BackSD: TSurfaceDesc;
  SrcR: TRect;
  Line: Integer;
  CI: TChangeInfo;
  R: TaowRect;
begin
  try
    if FValid and FVisible then
    begin
      OldLeft := FWinLeft;
      OldTop := FWinTop;
      FWinLeft := 0;
      FWinTop := 0;
      if FBackSurface <> nil then
        if FBackSurface.PixelFormatID <> SurfDesc.PixelFormatID then
        begin
          FBackSurface.Free;
          FBackSurface := nil;
        end;
      if FBackSurface = nil then
      begin
        FBackSurface := TDataSurface.Create(FTextWidth, FTextHeight, SurfDesc.PixelFormatID, nil);
        FBackDrawn := False;
      end;
      if not FBackDrawn then
      begin
        if FImages.Count <= FILIndexTexture then
        begin
          if FMasked then
            FBackSurface.Cls(FMaskColor)
          else
            FBackSurface.Cls(0);
          FBackSurface.Lock(BackSD);
        end
        else
        begin
          FBackSurface.Lock(BackSD);
          FImages.DrawILT(FILIndexTexture, Rect(0, 0, FTextWidth, FTextHeight), BackSD);
        end;
        Line := 1;
        CI := FChanges[0];
        Align := taLeft;
        FontName := '';
        X := FBorderWidth;
        Y := FBorderHeight;
        LH := 10;
        for I := 0 to FLines.Count - 1 do
        begin
          Pos := 0;
          case Align of
            taLeft: X := FBorderWidth;
            taCenter: X := 0;
            taRight: X := FTextWidth - FBorderWidth;
          end;
          while (CI.FLine = I) and (Line <= FChanges.Count) do
          begin
            if (FontName <> '') and (CI.FPos > Pos) then
              case Align of
                taLeft:
                  begin
                    FAOWFont.SetText(X, Y, Copy(FLines[I], Pos + 1, CI.FPos - Pos), BackSD);
                    X := X + FAOWFont.GetTextWidth(Copy(FLines[I], Pos + 1, CI.FPos - Pos));
                  end;
                taCenter:
                  FAOWFont.SetText(FTextWidth div 2 -
                    FAOWFont.GetTextWidth(Copy(FLines[I], Pos + 1, CI.FPos - Pos)) div 2, Y,
                    Copy(FLines[I], Pos + 1, CI.FPos - Pos), BackSD);
                taRight:
                  begin
                    FAOWFont.SetText(X - FAOWFont.GetTextWidth(Copy(FLines[I], Pos + 1, CI.FPos - Pos)),
                      Y, Copy(FLines[I], Pos + 1, CI.FPos - Pos), BackSD);
                    X := X - FAOWFont.GetTextWidth(Copy(FLines[I], Pos + 1, CI.FPos - Pos));
                  end;
              end;
            Pos := CI.FPos;
            if CI.FFont <> '' then
              LoadFont(CI.FFont);
            FAOWFont.FontColorPaletteIndex := 1;
            FAOWFont.Color := CI.FColor;
            FAOWFont.CharacterDistance := CI.FSpacing;
            FontName := CI.FFont;
            LH := CI.FHeight;
            if CI.FAlign <> Align then
              case Align of
                taLeft: X := FBorderWidth;
                taCenter: X := 0;
                taRight: X := FTextWidth - FBorderWidth;
              end;
            Align := CI.FAlign;
            if Line < FChanges.Count then
              CI := FChanges[Line];
            Inc(Line);
          end;
          if FontName <> '' then
            case Align of
              taLeft:
                FAOWFont.SetText(X, Y, Copy(FLines[I], Pos + 1, Length(FLines[I]) - Pos), BackSD);
              taCenter:
                FAOWFont.SetText(FTextWidth div 2 -
                  FAOWFont.GetTextWidth(Copy(FLines[I], Pos + 1, Length(FLines[I]) - Pos)) div 2,
                  Y, Copy(FLines[I], Pos + 1, Length(FLines[I]) - Pos), BackSD);
              taRight:
                FAOWFont.SetText(X - FAOWFont.GetTextWidth(Copy(FLines[I], Pos + 1,
                  Length(FLines[I]) - Pos)), Y, Copy(FLines[I], Pos + 1, Length(FLines[I]) - Pos),
                  BackSD);
            end;
          Y := Y + LH;
        end;
        FBackSurface.Unlock;
        FBackDrawn := True;
      end;
      FWinLeft := OldLeft;
      FWinTop := OldTop;
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      FBackSurface.Lock(BackSD);
      if FSurfaceValid then
        for I := 0 to FDrawCount - 1 do
        begin
          R := FDrawList[I];
          if FAOWOwner.FWinLeft + FWinLeft > R.R.Left then
            R.R.Left := FAOWOwner.FWinLeft + FWinLeft;
          if FAOWOwner.FWinTop + FWinTop > R.R.Top then
            R.R.Top := FAOWOwner.FWinTop + FWinTop;
          if FAOWOwner.FWinLeft + FWinLeft + FWinWidth < R.R.Right then
            R.R.Right := FAOWOwner.FWinLeft + FWinLeft + FWinWidth;
          if FAOWOwner.FWinTop + FWinTop + FWinHeight < R.R.Bottom then
            R.R.Bottom := FAOWOwner.FWinTop + FWinTop + FWinHeight;
          SrcR := Rect(R.R.Left - FAOWOwner.FWinLeft - FWinLeft,
            FTopItem + R.R.Top - FAOWOwner.FWinTop - FWinTop,
            R.R.Right - FAOWOwner.FWinLeft - FWinLeft,
            FTopItem + R.R.Bottom - FAOWOwner.FWinTop - FWinTop);
          if FMasked then
            BltSpriteClipped16(BackSD, SrcR, SurfDesc, R.R.Left, R.R.Top, FMaskColor)
          else
            BltSDRectClipped(BackSD, SrcR, SurfDesc, R.R.Left, R.R.Top);
        end
      else
      begin
        SrcR := Rect(0, FTopItem, FWinWidth, FTopItem + FWinHeight);
        if FMasked then
          BltSpriteClipped16(BackSD, SrcR, SurfDesc, FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop, FMaskColor)
        else
          BltSDRectClipped(BackSD, SrcR, SurfDesc, FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop);
      end;
      FBackSurface.Unlock;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
      FSurfaceValid := True;
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ Update follows the scroll bar; a masked memo asks its owner to redraw it under the text }
procedure TaowHTMLMemo.Update;
var
  R: TRect;
begin
  if FVisible then
  begin
    if (FVScrollBar <> nil) and (FLines.Count > 0) then
      if FVScrollBar.Position <> FTopItem then
        SetListOff(FVScrollBar.Position);
    if not FDrawn then
      FSurfaceValid := False;
    FDrawn := False;
  end;
  inherited Update;
  if FVisible and FMasked and not FSurfaceValid then
  begin
    if FAOWOwner.FAOWOwner.FAOWOwner = nil then
      R := Rect(FWinLeft, FWinTop, FWinLeft + FWinWidth - 1, FWinTop + FWinHeight - 1)
    else
      R := Rect(FAOWOwner.FWinLeft + FWinLeft, FAOWOwner.FWinTop + FWinTop,
        FAOWOwner.FWinLeft + FWinLeft + FWinWidth - 1, FAOWOwner.FWinTop + FWinTop + FWinHeight - 1);
    FAOWOwner.AddDrawRect(R, Self);
  end;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TaowHTMLMemo]);
end;

end.
