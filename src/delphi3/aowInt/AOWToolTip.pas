unit AOWToolTip;

{ The AOWToolTip unit of aowInt.dpl: TAOWToolTip, the small window that TAOWControl shows with a
  control's tool tip text after the mouse rested on it for ToolTipDelay updates. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl, AoWBaseWin, AoWWinGeneric;

type
  { AOWToolTip.TAOWToolTip (instance size 564). Fields: +$1EC FItems, +$1F0 FOnDrawItem, +$1F8
    FToolTipStatic, +$1FC FToolTipDelay, +$200 FShowDuration, +$204 FItemHeight, +$208 FShowing,
    +$20C FControlRect (the control on the screen; the tip shows at its bottom right), +$21C
    FItemIndex, +$220 FItemRect (the line being drawn, for OnDrawItem), +$230 FLines (Items
    broken into lines that fit) }
  TAOWToolTip = class(TAOWGenericWindow)
  public
    FItems: TStringList;
    FOnDrawItem: TNotifyEvent;
    FToolTipStatic: Boolean;
    FToolTipDelay: Integer;
    FShowDuration: Integer;
    FItemHeight: Integer;
    FShowing: Boolean;
    FControlRect: TRect;
    FItemIndex: Integer;
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
    procedure SetFStrings(Value: TStringList);
  published
    property ILFrame;
    property ILIndexFrame;
    property ILIndexTexture;
    property ILTexture;
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property Items: TStringList read FItems write SetFStrings;
    property OnDrawItem: TNotifyEvent read FOnDrawItem write FOnDrawItem;
    property TextColor;
    property ToolTipStatic: Boolean read FToolTipStatic write FToolTipStatic;
    property ToolTipDelay: Integer read FToolTipDelay write FToolTipDelay;
    property ShowDuration: Integer read FShowDuration write FShowDuration;
    property ItemHeight: Integer read FItemHeight write FItemHeight;
  end;

procedure Register;

implementation
uses AoWWindow;

{ TAOWToolTip }

constructor TAOWToolTip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLines := TStringList.Create;
  FItems := TStringList.Create;
  FItems.OnChange := OnChangeText;
  FShowDuration := 100;
  FItemHeight := 10;
end;

destructor TAOWToolTip.Destroy;
begin
  FLines.Destroy;
  FItems.Destroy;
  inherited Destroy;
end;

procedure TAOWToolTip.Validate;
begin
  if FILFrame <> nil then
    FILFrame := FILFrame.CheckIL(FILIndexFrame, 8, Self);
  if FILTexture <> nil then
    FILTexture := FILTexture.CheckIL(FILIndexTexture, 1, Self);
  if (FAOWOwner <> nil) and (FILFrame <> nil) and (FILTexture <> nil) and (FAOWFont <> nil) then
    FValid := True;
  inherited Validate;
end;

{ SetSize breaks the lines of Items into FLines so that each fits the width (moving the last
  characters of a line to the next one up to a space), sizes the tool tip to the text and keeps
  it on the screen. The width limit of the line breaking uses the images 3 and 4 of the frame
  library instead of FILIndexFrame + 3 and + 4, and the minimum width adds the width of the
  top left corner twice (original bugs). }
procedure TAOWToolTip.SetSize;
var
  I, W: Integer;
  Moved, Done: Boolean;
begin
  if FOwnerItem <> 0 then
    FWinWidth := FOwnerItem
  else
    FOwnerItem := FWinWidth;
  if FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height > FWinHeight then
    FWinHeight := FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height;
  if FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width > FWinWidth then
    FWinWidth := FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame].Width;
  FLines.Clear;
  for I := 0 to FItems.Count - 1 do
    FLines.Add(FItems[I]);
  if FLines.Count > 0 then
  begin
    I := 0;
    while I < FLines.Count do
    begin
      Moved := False;
      Done := True;
      while (not Done or (FAOWFont.GetTextWidth(FLines[I]) > FWinWidth - FILFrame[3].Width -
        FILFrame[4].Width - FBorderWidth * 2)) and (Length(FLines[I]) > 1) do
      begin
        Done := False;
        if I < FLines.Count - 1 then
          if Moved = True then
            FLines[I + 1] := Copy(FLines[I], Length(FLines[I]), 1) + FLines[I + 1]
          else
            FLines.Insert(I + 1, Copy(FLines[I], Length(FLines[I]), 1))
        else
          FLines.Add(Copy(FLines[I], Length(FLines[I]), 1));
        FLines[I] := Copy(FLines[I], 1, Length(FLines[I]) - 1);
        Moved := True;
        if Copy(FLines[I], Length(FLines[I]), 1) = ' ' then
          Done := True;
      end;
      Inc(I);
    end;
    FWinHeight := FILFrame[FILIndexFrame + 1].Height + FILFrame[FILIndexFrame + 6].Height +
      FBorderHeight * 2 + FLines.Count * FItemHeight;
    W := FAOWFont.GetTextWidth(FLines[0]);
    if W < FWinWidth - FILFrame[FILIndexFrame].Width - FILFrame[FILIndexFrame + 2].Width -
      FBorderWidth * 2 then
      FWinWidth := W + FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width +
        FBorderWidth * 2;
  end;
  if FMasked then
  begin
    FFrameLeft := FILFrame[FILIndexFrame + 3].Width;
    FFrameRight := FWinWidth - FILFrame[FILIndexFrame + 4].Width;
    FFrameTop := FILFrame[FILIndexFrame + 1].Height;
    FFrameBottom := FWinHeight - FILFrame[FILIndexFrame + 6].Height;
  end;
  FWinLeft := FControlRect.Right;
  FWinTop := FControlRect.Bottom;
  if FWinManager.FWinWidth < FWinLeft + FWinWidth then
    FWinLeft := FWinManager.FWinWidth - FWinWidth;
  if FWinTop + FWinHeight > FWinManager.FWinHeight then
    FWinTop := FControlRect.Top - FWinHeight;
  if FWinTop < 0 then
    FWinTop := 0;
  inherited SetSize;
end;

procedure TAOWToolTip.Update;
var
  B: Boolean;
begin
  B := FDoubleBuffered;
  FDoubleBuffered := False;
  inherited Update;
  FDoubleBuffered := B;
end;

procedure TAOWToolTip.SetFStrings(Value: TStringList);
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
  FSized := False;
end;

procedure TAOWToolTip.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    if not FVisible then
    begin
      FHidden := True;
      if Assigned(FOnHide) then
        FOnHide(Self);
    end
    else
    begin
      if FDoubleBuffered then
        FSurfaceValid := False
      else
        FDrawn := False;
      if not FHidden then
      begin
        FBackRect.Right := FWinWidth;
        FBackRect.Bottom := FWinHeight;
        FBackRect.Top := FWinTop;
        FBackRect.Left := FWinLeft;
      end;
      if Assigned(FOnShow) then
        FOnShow(Self);
    end;
    if FVisible = True then
    begin
      FHidden := False;
      SetPriority(FPriority);
    end;
  end;
  FBackRect.Right := 0;
  FBackRect.Bottom := 0;
end;

procedure TAOWToolTip.Draw(SurfDesc: TSurfaceDesc);
var
  I: Integer;
  OldClip: TRect;
begin
  try
    if FValid and FVisible then
    begin
      FILFrame.DrawILF(FILIndexFrame, Rect(FWinLeft, FWinTop, FWinWidth, FWinHeight), SurfDesc);
      FILTexture.DrawILT(FILIndexTexture, Rect(FWinLeft + FILFrame[FILIndexFrame + 3].Width,
        FWinTop + FILFrame[FILIndexFrame + 1].Height, FWinWidth -
        FILFrame[FILIndexFrame + 3].Width - FILFrame[FILIndexFrame + 4].Width, FWinHeight -
        FILFrame[FILIndexFrame + 1].Height - FILFrame[FILIndexFrame + 6].Height), SurfDesc);
      FAOWFont.Color := FColor;
      OldClip := SurfDesc.ClipRect;
      if FLines.Count > 0 then
        for I := 0 to FLines.Count - 1 do
        begin
          if FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 4].Width < OldClip.Right then
            SurfDesc.ClipRect.Right := FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 4].Width;
          if (I < FLines.Count) and (FLines.Count > 0) then
          begin
            FAOWFont.SetText(FWinLeft + FBorderWidth + FILFrame[FILIndexFrame + 3].Width,
              FWinTop + FBorderHeight + FILFrame[FILIndexFrame].Height + FItemHeight * I,
              FLines[I], SurfDesc);
            FItemIndex := I;
            FItemRect := Rect(FWinLeft + FILFrame[FILIndexFrame + 3].Width,
              FWinTop + FILFrame[FILIndexFrame + 1].Height + FItemHeight * I,
              FWinLeft + FWinWidth,
              FWinTop + FILFrame[FILIndexFrame + 1].Height + (I + 1) * FItemHeight);
            if Assigned(FOnDrawItem) then
              FOnDrawItem(Self);
          end;
          SurfDesc.ClipRect := OldClip;
        end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAOWToolTip.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FShowing := False;
  SetVisible(False);
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWToolTip]);
end;

end.
