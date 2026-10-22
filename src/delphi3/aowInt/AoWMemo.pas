unit AoWMemo;

{ The AoWMemo unit of aowInt.dpl: TAOWMemo, a multi-line text control in a frame, optionally
  editable, with a vertical scroll bar. Items holds the text as the user sees it, one paragraph a
  line; SetSize wraps it into FLines at the width of the control, and a paragraph that starts
  with ColorChangeChar followed by six hex digits is drawn in that color (TColorChange, one per
  wrapped line). The cursor has two positions: FRealCol/FRealLine in Items and FCurCol/FCurLine
  in the wrapped lines; CurToReal and RealToCur convert one into the other. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWVScroll, AOWToolTip, AoWControl, AOWWinManager, AoWComp, AOWInterfaceImgLib,
  AoWWinControl, AoWBaseWin;

type
  TMemoType = (mtNormal, mtBlank);

  { AoWMemo.TColorChange (instance size 12): the color of a wrapped line. +4 FHasColor, +8
    FColor }
  TColorChange = class(TObject)
  public
    FHasColor: Boolean;
    FColor: TColor;
  end;

  { AoWMemo.TAOWMemo (instance size 396). Fields: +$114 F114 (cleared by CheckMouseUp, not read),
    +$118 FItems (the text, one paragraph a line), +$11C FColorList (TColorChange of every wrapped
    line), +$120 FVScrollBar, +$124 FNumVisible (lines that fit), +$128 FTopItem (the first line
    shown), +$12C FScrollSet, +$130 FOnDrawItem, +$138 FScrollWidth (the width taken at the right
    by the frame or the scroll bar), +$13C FScrollVisible, +$13D FCursorChar, +$140 FBlink (the
    cursor is shown), +$144 FBlinkDelay, +$145 FBlinkCount, +$148 FCurCol, +$14C FCurLine (the
    cursor in FLines), +$150 FRealCol, +$154 FRealLine (the cursor in FItems), +$158 FEditable,
    +$15C FILFrame, +$160 FILTexture, +$164 FItemHeight, +$168 FColorChangeChar, +$169
    FTextAlign, +$16A FNoFrame (Validate found no frame or texture: drawn transparent), +$16C
    FILIndexFrame, +$170 FILIndexTexture, +$174 FDrawIndex, +$178 FItemRect (the line being
    drawn, for OnDrawItem), +$188 FLines (the wrapped lines). FRedraw (+$94) is the focus: the
    memo takes the keys while it is set.
    VMT (new): SetILFrame, SetILTexture }
  TAOWMemo = class(TAOWControl)
  public
    F114: Integer;
    FItems: TStringList;
    FColorList: TList;
    FVScrollBar: TAOWVScrollBar;
    FNumVisible: Integer;
    FTopItem: Integer;
    FScrollSet: LongBool;
    FOnDrawItem: TNotifyEvent;
    FScrollWidth: Integer;
    FScrollVisible: Boolean;
    FCursorChar: Char;
    FBlink: LongBool;
    FBlinkDelay: Byte;
    FBlinkCount: Byte;
    FCurCol: Integer;
    FCurLine: Integer;
    FRealCol: Integer;
    FRealLine: Integer;
    FEditable: Boolean;
    FILFrame: TInterfaceIL;
    FILTexture: TInterfaceIL;
    FItemHeight: Integer;
    FColorChangeChar: Char;
    FTextAlign: TaowTextAlign;
    FNoFrame: Boolean;
    FILIndexFrame: Integer;
    FILIndexTexture: Integer;
    FDrawIndex: Integer;
    FItemRect: TRect;
    FLines: TStringList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure SetVisible(Value: Boolean); override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure CheckKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure SetILFrame(Value: TInterfaceIL); virtual;
    procedure SetILTexture(Value: TInterfaceIL); virtual;
    procedure SetFStrings(Value: TStringList);
    procedure SetListOff(Value: Integer);
    procedure SetVScroll(Value: TAOWVScrollBar);
    procedure SetILFIndex(Value: Integer);
    procedure SetILTIndex(Value: Integer);
    procedure CurToReal;
    procedure RealToCur;
    procedure KeyStuff;
    property ListOffset: Integer read FTopItem write SetListOff;
  published
    property WinWidth;
    property WinHeight;
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property Items: TStringList read FItems write SetFStrings;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property VScrollBar: TAOWVScrollBar read FVScrollBar write SetVScroll;
    property OnChange;
    property OnDrawItem: TNotifyEvent read FOnDrawItem write FOnDrawItem;
    property TextColor;
    property CursorChar: Char read FCursorChar write FCursorChar;
    property BlinkDelay: Byte read FBlinkDelay write FBlinkDelay;
    property Editable: Boolean read FEditable write FEditable;
    property ILFrame: TInterfaceIL read FILFrame write SetILFrame;
    property ILTexture: TInterfaceIL read FILTexture write SetILTexture;
    property ILIndexFrame: Integer read FILIndexFrame write SetILFIndex;
    property ILIndexTexture: Integer read FILIndexTexture write SetILTIndex;
    property ItemHeight: Integer read FItemHeight write FItemHeight;
    property ColorChangeChar: Char read FColorChangeChar write FColorChangeChar;
    property TextAlign: TaowTextAlign read FTextAlign write FTextAlign;
  end;

procedure Register;

implementation
uses AoWTabPanel;

{ TAOWMemo }

constructor TAOWMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLines := TStringList.Create;
  FItems := TStringList.Create;
  FItems.OnChange := OnChangeText;
  FColorList := TList.Create;
  FNumVisible := 3;
  FCursorChar := '|';
  FEditable := True;
end;

destructor TAOWMemo.Destroy;
var
  I: Integer;
begin
  FLines.Free;
  FItems.Free;
  for I := 0 to FColorList.Count - 1 do
    TColorChange(FColorList[I]).Free;
  FColorList.Free;
  inherited Destroy;
end;

procedure TAOWMemo.Validate;
begin
  if FAOWFont <> nil then
  begin
    if FILFrame <> nil then
      FILFrame := FILFrame.CheckIL(FILIndexFrame, 8, Self);
    if FILTexture <> nil then
      FILTexture := FILTexture.CheckIL(FILIndexTexture, 1, Self);
    if (FILFrame <> nil) and (FILTexture <> nil) then
      FNoFrame := False
    else
      FNoFrame := True;
    FValid := True;
  end;
  inherited Validate;
end;

{ SetSize wraps every item at the width of the control into FLines (at spaces; a word that does
  not fit starts a new line) and sets up the scroll bar }
procedure TAOWMemo.SetSize;
var
  I, Len, W: Integer;
  P: PChar;
  S: string;
  J, Start, TW: Integer;
  CC: TColorChange;
begin
  if FItemHeight < 1 then
    FItemHeight := 10;
  case FNoFrame of
    False:
      begin
        if FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height > FWinHeight then
          FWinHeight := FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height;
        if FILFrame[FILIndexFrame].Width > FWinWidth then
          FWinWidth := FILFrame[FILIndexFrame].Width;
        FNumVisible := (FWinHeight - FILFrame[FILIndexFrame + 1].Height -
          FILFrame[FILIndexFrame + 6].Height) div FItemHeight;
        FScrollWidth := FILFrame[FILIndexFrame + 4].Width;
        FMasked := False;
      end;
    True:
      begin
        FNumVisible := FWinHeight div FItemHeight;
        FScrollWidth := 0;
        FMasked := True;
      end;
  end;
  if FVScrollBar <> nil then
  begin
    FScrollWidth := FVScrollBar.WinWidth;
    FTopItem := FVScrollBar.Position;
  end;
  for I := 0 to FColorList.Count - 1 do
  begin
    CC := FColorList[I];
    CC.Free;
  end;
  FColorList.Clear;
  FLines.Clear;
  for I := 0 to FItems.Count - 1 do
  begin
    FLines.Add('');
    FColorList.Add(TColorChange.Create);
    J := 0;
    Start := 0;
    if not FNoFrame then
      W := FILFrame[FILIndexFrame + 3].Width + FScrollWidth + FBorderWidth * 2
    else
      W := FBorderWidth * 2;
    P := Pointer(FItems[I]);
    Len := Length(string(P));
    if (Len > 6) and (P^ = FColorChangeChar) then
    begin
      CC := FColorList[FColorList.Count - 1];
      CC.FHasColor := True;
      try
        CC.FColor := StrToInt('$' + Copy(FItems[I], 2, 6));
      except
      end;
      J := 8;
      Start := 7;
    end;
    while J < Len do
    begin
      if (P[J] = ' ') or (J = Len - 1) then
      begin
        S := Copy(string(P), Start + 1, J + 1 - Start);
        TW := FAOWFont.GetTextWidth(S);
        if W + TW > FWinWidth then
        begin
          FLines.Add(S);
          FColorList.Add(TColorChange.Create);
          if not FNoFrame then
            W := TW + (FILFrame[FILIndexFrame + 3].Width + FScrollWidth + FBorderWidth * 2)
          else
            W := TW + FBorderWidth * 2;
        end
        else
        begin
          FLines[FLines.Count - 1] := FLines[FLines.Count - 1] + S;
          W := W + TW;
        end;
        Start := J + 1;
      end;
      Inc(J);
    end;
  end;
  if FLines.Count < FTopItem + FNumVisible then
    FTopItem := FLines.Count - FNumVisible;
  if FTopItem < 0 then
    FTopItem := 0;
  FScrollSet := False;
  if FScrollSet = False then
  begin
    if not FNoFrame then
      FScrollWidth := FILFrame[FILIndexFrame + 4].Width
    else
      FScrollWidth := 0;
    FScrollVisible := False;
    if FVScrollBar <> nil then
    begin
      FScrollSet := True;
      if FAOWWindow <> FVScrollBar.AOWWindow then
        FVScrollBar.AOWWindow := FAOWWindow;
      FVScrollBar.Min := 0;
      FVScrollBar.Max := FLines.Count - 2;
      FVScrollBar.Priority := FPriority + 1;
      FVScrollBar.Position := FTopItem;
      FVScrollBar.NumberVisible := FNumVisible - 1;
      FVScrollBar.WinHeight := FWinHeight;
      FVScrollBar.LargeChange := FNumVisible - 1;
      FVScrollBar.Visible := FVisible;
      if (FVScrollBar.VanishWhenFull = True) and (FLines.Count - 1 < FNumVisible) then
        FVScrollBar.Visible := False
      else
        FScrollWidth := FVScrollBar.WinWidth;
      FVScrollBar.FSized := False;
      FVScrollBar.WinLeft := FWinLeft + FWinWidth - FVScrollBar.WinWidth;
      FVScrollBar.WinTop := FWinTop;
      FScrollVisible := FVScrollBar.Visible;
    end;
  end;
  inherited SetSize;
end;

procedure TAOWMemo.SetFStrings(Value: TStringList);
var
  I: Integer;
begin
  FLines.Clear;
  FItems.Clear;
  for I := 0 to Value.Count - 1 do
  begin
    FLines.Add(Value[I]);
    FItems.Add(Value[I]);
  end;
  if FLines.Count < FNumVisible then
    FNumVisible := FLines.Count;
  if FLines.Count < FTopItem + FNumVisible then
    FTopItem := FLines.Count - FNumVisible;
  FSized := False;
end;

procedure TAOWMemo.SetListOff(Value: Integer);
begin
  if Value >= FLines.Count then
    Value := FLines.Count - 1;
  if Value <> FTopItem then
  begin
    FTopItem := Value;
    FDrawn := False;
  end;
end;

procedure TAOWMemo.SetVScroll(Value: TAOWVScrollBar);
begin
  FVScrollBar := Value;
  if Value <> nil then
    Value.Priority := FPriority;
  FSized := False;
end;

procedure TAOWMemo.SetVisible(Value: Boolean);
begin
  inherited SetVisible(Value);
  if FVScrollBar <> nil then
    FVScrollBar.Visible := FVisible;
end;

procedure TAOWMemo.SetILFrame(Value: TInterfaceIL);
begin
  if Value <> FILFrame then
  begin
    FValid := False;
    FILFrame := Value;
  end;
end;

procedure TAOWMemo.SetILTexture(Value: TInterfaceIL);
begin
  if Value <> FILTexture then
  begin
    FValid := False;
    FILTexture := Value;
  end;
end;

procedure TAOWMemo.SetILFIndex(Value: Integer);
begin
  if Value <> FILIndexFrame then
  begin
    FILIndexFrame := Value;
    FValid := False;
  end;
end;

procedure TAOWMemo.SetILTIndex(Value: Integer);
begin
  if Value <> FILIndexTexture then
  begin
    FILIndexTexture := Value;
    FValid := False;
  end;
end;

{ Draw draws the frame and the texture, the visible lines (clipped to the text area) and the
  cursor }
procedure TAOWMemo.Draw(SurfDesc: TSurfaceDesc);
var
  X, Y, W: Integer;
  OldClip: TRect;
  H, I: Integer;
  CC: TColorChange;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      FAOWFont.Color := FColor;
      OldClip := SurfDesc.ClipRect;
      case FNoFrame of
        False:
          begin
            FILFrame.DrawILF(FILIndexFrame, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
            FILTexture.DrawILT(FILIndexTexture,
              Rect(FAOWWindow.FWinLeft + FWinLeft + FILFrame[FILIndexFrame + 3].Width,
              FAOWWindow.FWinTop + FWinTop + FILFrame[FILIndexFrame + 1].Height,
              FWinWidth - FILFrame[FILIndexFrame + 3].Width - FScrollWidth,
              FWinHeight - FILFrame[FILIndexFrame + 1].Height - FILFrame[FILIndexFrame + 6].Height),
              SurfDesc);
            X := FAOWWindow.FWinLeft + FWinLeft + FILFrame[FILIndexFrame + 3].Width;
            Y := FAOWWindow.FWinTop + FWinTop + FILFrame[FILIndexFrame + 1].Height;
            H := FWinHeight - FILFrame[FILIndexFrame + 1].Height - FILFrame[FILIndexFrame + 6].Height;
            W := FWinWidth - FILFrame[FILIndexFrame + 3].Width - FScrollWidth;
          end;
      else
        X := FAOWWindow.FWinLeft + FWinLeft;
        Y := FAOWWindow.FWinTop + FWinTop;
        H := FWinHeight;
        W := FWinWidth - FScrollWidth;
      end;
      if X + W < OldClip.Right then
        SurfDesc.ClipRect.Right := X + W;
      if Y + H < OldClip.Bottom then
        SurfDesc.ClipRect.Bottom := Y + H;
      for I := 0 to FNumVisible do
        if FTopItem + I < FLines.Count then
        begin
          CC := FColorList[FTopItem + I];
          if CC.FHasColor then
            FAOWFont.Color := CC.FColor;
          case FTextAlign of
            taLeft:
              FAOWFont.SetText(FBorderWidth + X, FBorderHeight + Y + FItemHeight * I,
                FLines[FTopItem + I], SurfDesc);
            taRight:
              FAOWFont.SetText(X + W - FBorderWidth - FAOWFont.GetTextWidth(FLines[FTopItem + I]),
                FBorderHeight + Y + FItemHeight * I, FLines[FTopItem + I], SurfDesc);
          else
            FAOWFont.SetText(X + W div 2 - FAOWFont.GetTextWidth(FLines[FTopItem + I]) div 2,
              FBorderHeight + Y + FItemHeight * I, FLines[FTopItem + I], SurfDesc);
          end;
          FDrawIndex := FTopItem + I;
          FItemRect := Rect(X, Y + FItemHeight * I, X + W, Y + (I + 1) * FItemHeight);
          if FItemRect.Bottom > SurfDesc.ClipRect.Bottom then
            FItemRect.Bottom := SurfDesc.ClipRect.Bottom;
          if Assigned(FOnDrawItem) then
            FOnDrawItem(Self);
        end;
      SurfDesc.ClipRect := OldClip;
      if (FCurLine - FTopItem > -1) and (FCurLine - FTopItem < FNumVisible) and
        (FCurLine - FTopItem < FLines.Count) and (FRedraw = True) and FEditable and
        (FBlink = True) then
        FAOWFont.SetText(FBorderWidth + X + FAOWFont.GetTextWidth(Copy(FLines[FCurLine], 1, FCurCol)),
          FBorderHeight + Y + (FCurLine - FTopItem) * FItemHeight, FCursorChar, SurfDesc);
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ Update follows the scroll bar and blinks the cursor }
procedure TAOWMemo.Update;
var
  P: Integer;
begin
  inherited Update;
  if FVisible then
  begin
    if (FVScrollBar <> nil) and (FLines.Count > 0) then
      if FVScrollBar.Position <> FTopItem then
      begin
        P := FVScrollBar.Position;
        FTopItem := P;
        if FLines.Count < P + FNumVisible then
          FTopItem := FLines.Count - FNumVisible;
        if FTopItem < 0 then
          FTopItem := 0;
        FDrawn := False;
        if FNoFrame = True then
          if FAOWWindow <> nil then
            FAOWWindow.FDrawn := False;
      end;
    if FEditable and (FBlinkDelay > 0) and (FRedraw = True) then
    begin
      Inc(FBlinkCount);
      if FBlinkCount > FBlinkDelay then
      begin
        FDrawn := False;
        if FNoFrame = True then
          if FAOWWindow <> nil then
            FAOWWindow.FDrawn := False;
        FBlinkCount := 0;
        if FBlink = True then
          FBlink := False
        else
          FBlink := True;
      end;
    end;
  end;
end;

procedure TAOWMemo.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end;
end;

{ CheckMouseUp takes the focus when the text area is clicked and puts the cursor at the click }
procedure TAOWMemo.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Len, Left: Integer;
  Old: Boolean;
  Top, Bottom: Integer;
begin
  FHandled := False;
  FMouseDown := False;
  F114 := 0;
  Old := FRedraw;
  FRedraw := False;
  if FEditable and (FItems.Count = 0) then
  begin
    FItems.Add('');
    FLines.Add('');
    FColorList.Add(TColorChange.Create);
  end;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    case FNoFrame of
      False:
        begin
          Left := FAOWWindow.FWinLeft + FWinLeft + FILFrame[FILIndexFrame + 3].Width - 1;
          Top := FAOWWindow.FWinTop + FWinTop + FBorderHeight + FILFrame[FILIndexFrame + 1].Height - 1;
          Bottom := FAOWWindow.FWinTop + FWinTop + FWinHeight - FILFrame[FILIndexFrame + 6].Height;
        end;
    else
      Left := FAOWWindow.FWinLeft + FWinLeft - 1;
      Top := FAOWWindow.FWinTop + FWinTop + FBorderHeight - 1;
      Bottom := FAOWWindow.FWinTop + FWinTop + FWinHeight;
    end;
    if FEditable and (X > Left) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth - FScrollWidth) and
      (Y > Top) and (Y < Bottom) and (Button = mbLeft) then
    begin
      if FEditable = True then
      begin
        FRedraw := True;
        FBlink := True;
        FBlinkCount := 0;
        FHandled := True;
        FDrawn := False;
        if FNoFrame = True then
          if FAOWWindow <> nil then
            FAOWWindow.FDrawn := False;
      end;
      if (FLines.Count - FTopItem) * FItemHeight + Top < Y then
      begin
        FCurLine := FLines.Count - 1;
        FCurCol := Length(FLines[FLines.Count - 1]);
        FRealLine := FItems.Count - 1;
        FRealCol := Length(FItems[FItems.Count - 1]);
      end
      else
      begin
        Len := Length(FItems[0]);
        FRealCol := 0;
        FRealLine := 0;
        FCurCol := 0;
        FCurLine := 0;
        while FCurLine < FTopItem do
        begin
          FRealCol := FRealCol + Length(FLines[FCurLine]);
          if FRealCol >= Len then
          begin
            FRealCol := 0;
            Inc(FRealLine);
            Len := Length(FItems[FRealLine]);
          end;
          Inc(FCurLine);
        end;
        while (FLines.Count > FCurLine) and ((FCurLine - FTopItem + 1) * FItemHeight + Top < Y) do
        begin
          FRealCol := FRealCol + Length(FLines[FCurLine]);
          if FRealCol >= Len then
          begin
            FRealCol := 0;
            Inc(FRealLine);
            Len := Length(FItems[FRealLine]);
          end;
          Inc(FCurLine);
        end;
        if FLines.Count = FCurLine then
          Dec(FCurLine);
        while (Length(FLines[FCurLine]) > FCurCol) and
          (FAOWFont.GetTextWidth(Copy(FLines[FCurLine], 1, FCurCol + 1)) + Left < X) do
        begin
          Inc(FCurCol);
          Inc(FRealCol);
        end;
      end;
    end;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
  if FRedraw <> Old then
    FDrawn := False;
end;

procedure TAOWMemo.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if FVisible and (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth - FScrollWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if FEditable = True then
      FAOWWindow.FCursor := crIBeam;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
end;

{ CheckKeyDown moves the cursor with the arrow keys and deletes with Delete }
procedure TAOWMemo.CheckKeyDown(var Key: Word; Shift: TShiftState);
var
  Changed, Moved: Boolean;
begin
  FHandled := FRedraw;
  Changed := False;
  Moved := False;
  if FEditable and (FRedraw = True) and (FValid = True) and (FVisible = True) then
  begin
    case Key of
      VK_LEFT:
        begin
          if FRealCol > 0 then
            Dec(FRealCol)
          else if FRealLine > 0 then
          begin
            Dec(FRealLine);
            FRealCol := Length(FItems[FRealLine]);
          end;
          if FCurCol > 0 then
            Dec(FCurCol)
          else if FCurLine > 0 then
          begin
            Dec(FCurLine);
            FCurCol := Length(FLines[FCurLine]);
          end;
        end;
      VK_UP:
        if FCurLine > 0 then
        begin
          Dec(FCurLine);
          if Length(FLines[FCurLine]) < FCurCol then
            FCurCol := Length(FLines[FCurLine]);
          Moved := True;
        end;
      VK_RIGHT:
        begin
          if Length(FLines[FCurLine]) > FCurCol then
            Inc(FCurCol)
          else if FLines.Count - 1 > FCurLine then
          begin
            FCurCol := 0;
            Inc(FCurLine);
          end;
          if Length(FItems[FRealLine]) > FRealCol then
            Inc(FRealCol)
          else if FItems.Count - 1 > FRealLine then
          begin
            FRealCol := 0;
            Inc(FRealLine);
          end;
        end;
      VK_DOWN:
        if FLines.Count - 1 > FCurLine then
        begin
          Inc(FCurLine);
          if Length(FLines[FCurLine]) < FCurCol then
            FCurCol := Length(FLines[FCurLine]);
          Moved := True;
        end;
      VK_DELETE:
        if Length(FItems[FRealLine]) > FRealCol then
        begin
          FItems[FRealLine] := Copy(FItems[FRealLine], 1, FRealCol) +
            Copy(FItems[FRealLine], FRealCol + 2, Length(FItems[FRealLine]) - FRealCol);
          Changed := True;
        end
        else if FItems.Count - 1 > FRealLine then
        begin
          FItems[FRealLine] := FItems[FRealLine] + FItems[FRealLine + 1];
          FItems.Delete(FRealLine + 1);
          Changed := True;
        end;
    end;
    if Changed = True then
      RealToCur;
    if Moved = True then
      CurToReal;
    KeyStuff;
    if Assigned(FOnKeyDown) then
      FOnKeyDown(Self, Key, Shift);
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

{ CheckKeyPress edits the text: Backspace, Enter (splits the paragraph) and the printable
  characters }
procedure TAOWMemo.CheckKeyPress(var Key: Char);
var
  Changed, Moved: Boolean;
  C: Char;
begin
  FHandled := FRedraw;
  Changed := False;
  Moved := False;
  if FEditable and (FRedraw = True) and (FValid = True) and (FVisible = True) then
  begin
    case Key of
      #8:
        if FRealCol > 0 then
        begin
          FItems[FRealLine] := Copy(FItems[FRealLine], 1, FRealCol - 1) +
            Copy(FItems[FRealLine], FRealCol + 1, Length(FItems[FRealLine]) - FRealCol + 1);
          Dec(FRealCol);
          Changed := True;
        end
        else if FRealLine > 0 then
        begin
          FRealCol := Length(FItems[FRealLine - 1]);
          FItems[FRealLine - 1] := FItems[FRealLine - 1] + FItems[FRealLine];
          FItems.Delete(FRealLine);
          Dec(FRealLine);
          Changed := True;
        end;
      #13:
        begin
          if Length(FLines[FCurLine]) = FCurCol then
          begin
            FItems.Insert(FRealLine + 1, '');
            FItems[FRealLine] := Copy(FItems[FRealLine], 1, FRealCol + 1);
          end
          else
          begin
            FItems.Insert(FRealLine + 1, Copy(FItems[FRealLine], FRealCol + 1,
              Length(FItems[FRealLine])));
            FItems[FRealLine] := Copy(FItems[FRealLine], 1, FRealCol);
          end;
          FRealCol := 0;
          Inc(FRealLine);
          Changed := True;
        end;
      #0..#7, #9..#12, #14..#31:
        ;
    else
        begin
          C := Key;
          if Length(FLines[FCurLine]) = FCurCol then
            FItems[FRealLine] := Copy(FItems[FRealLine], 1, FRealCol + 1) + C +
              Copy(FItems[FRealLine], FRealCol + 2, Length(FItems[FRealLine]) - FRealCol)
          else
            FItems[FRealLine] := Copy(FItems[FRealLine], 1, FRealCol) + C +
              Copy(FItems[FRealLine], FRealCol + 1, Length(FItems[FRealLine]) - FRealCol);
          Inc(FRealCol);
          Changed := True;
        end;
    end;
    if Moved = True then
      CurToReal;
    if Changed = True then
      RealToCur;
    KeyStuff;
    { tests OnKeyDown and calls OnKeyPress (original bug) }
    if Assigned(FOnKeyDown) then
      FOnKeyPress(Self, Key);
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

{ CurToReal finds the cursor in FItems from the cursor in FLines; it adds the length of the
  cursor's line for every line up to it, not of each line (original bug) }
procedure TAOWMemo.CurToReal;
var
  Len, I: Integer;
begin
  Len := Length(FItems[0]);
  FRealCol := 0;
  FRealLine := 0;
  I := 0;
  while I <= FCurLine do
  begin
    FRealCol := FRealCol + Length(FLines[FCurLine]);
    if FRealCol >= Len then
    begin
      FRealCol := 0;
      Inc(FRealLine);
      Len := Length(FItems[FRealLine]);
    end;
    Inc(I);
  end;
  FRealCol := FRealCol + FCurCol;
end;

{ RealToCur wraps the text again and finds the cursor in FLines from the cursor in FItems }
procedure TAOWMemo.RealToCur;
var
  Len, I: Integer;
begin
  SetSize;
  Len := Length(FItems[0]);
  FCurCol := 0;
  FCurLine := 0;
  I := 0;
  while I < FRealLine do
  begin
    FCurCol := FCurCol + Length(FLines[FCurLine]);
    if FCurCol >= Len then
    begin
      FCurCol := 0;
      Inc(I);
      Len := Length(FItems[I]);
    end;
    Inc(FCurLine);
  end;
  I := Length(FLines[FCurLine]);
  while (I < FRealCol) and (FLines.Count > FCurLine) do
  begin
    Inc(FCurLine);
    I := I + Length(FLines[FCurLine]);
  end;
  FCurCol := Length(FLines[FCurLine]) + FRealCol - I;
end;

{ KeyStuff scrolls the cursor into view and shows it }
procedure TAOWMemo.KeyStuff;
begin
  if FNumVisible + FTopItem - 1 < FCurLine then
  begin
    if FVScrollBar <> nil then
      FVScrollBar.Position := FVScrollBar.Position + 1;
    Inc(FTopItem);
  end;
  if FCurLine < FTopItem then
  begin
    if FVScrollBar <> nil then
      FVScrollBar.Position := FVScrollBar.Position - 1;
    Dec(FTopItem);
  end;
  FBlink := True;
  FBlinkCount := 0;
  FDrawn := False;
  if FNoFrame = True then
    if FAOWWindow <> nil then
      FAOWWindow.FDrawn := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWMemo]);
end;

end.
