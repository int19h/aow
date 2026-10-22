unit AOWGauge;

{ The AOWGauge unit of aowInt.dpl: TAoWGauge, a horizontal progress bar. The part left of
  Position is drawn with the selected texture, the rest with the normal texture, inside a frame
  of eight images when ILFrame is set. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWToolTip, AoWControl, AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl,
  AoWBaseWin, AoWWinGeneric;

type
  { How TAoWGauge is drawn, set by Validate: with a frame (ILFrame is set) or textures only }
  TAOWGaugeType = (gtNormal, gtBorderless);

  { AOWGauge.TAoWGauge (instance size 316). Fields: +$114 FMin, +$118 FMax, +$11C FPosition,
    +$120 FILFrame, +$124 FILTextureNormal, +$128 FILTextureSelected, +$12C FStyle, +$130
    FILIndexFrame, +$134 FILIndexTNormal, +$138 FILIndexTSelected.
    VMT (new): SetILFrame, SetILTNorm, SetILTSel }
  TAoWGauge = class(TAOWControl)
  public
    FMin: Integer;
    FMax: Integer;
    FPosition: Integer;
    FILFrame: TInterfaceIL;
    FILTextureNormal: TInterfaceIL;
    FILTextureSelected: TInterfaceIL;
    FStyle: TAOWGaugeType;
    FILIndexFrame: Integer;
    FILIndexTNormal: Integer;
    FILIndexTSelected: Integer;
    constructor Create(AOwner: TComponent); override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetILFrame(Value: TInterfaceIL); virtual;
    procedure SetILTNorm(Value: TInterfaceIL); virtual;
    procedure SetILTSel(Value: TInterfaceIL); virtual;
    procedure SetILFIndex(Value: Integer);
    procedure SetILTnIndex(Value: Integer);
    procedure SetILTsIndex(Value: Integer);
    procedure SetPos(Value: Integer);
  published
    property WinWidth;
    property WinHeight;
    property Min: Integer read FMin write FMin;
    property Max: Integer read FMax write FMax;
    property Position: Integer read FPosition write SetPos;
    property ILFrame: TInterfaceIL read FILFrame write SetILFrame;
    property ILTextureNormal: TInterfaceIL read FILTextureNormal write SetILTNorm;
    property ILTextureSelected: TInterfaceIL read FILTextureSelected write SetILTSel;
    property ILIndexFrame: Integer read FILIndexFrame write FILIndexFrame;
    property ILIndexTNormal: Integer read FILIndexTNormal write SetILTnIndex;
    property ILIndexTSelected: Integer read FILIndexTSelected write SetILTsIndex;
  end;

procedure Register;

implementation

{ TAoWGauge }

constructor TAoWGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMax := 1;
end;

procedure TAoWGauge.Validate;
begin
  if FILTextureNormal <> nil then
    FILTextureNormal := FILTextureNormal.CheckIL(FILIndexTNormal, 1, Self);
  if FILTextureSelected <> nil then
    FILTextureSelected := FILTextureSelected.CheckIL(FILIndexTSelected, 1, Self);
  if (FILTextureNormal <> nil) and (FILTextureSelected <> nil) then
  begin
    if FILFrame <> nil then
      FILFrame := FILFrame.CheckIL(FILIndexFrame, 8, Self);
    if FILFrame <> nil then
      FStyle := gtNormal
    else
      FStyle := gtBorderless;
    FValid := True;
  end;
  inherited Validate;
end;

procedure TAoWGauge.SetSize;
begin
  case FStyle of
    gtNormal:
      begin
        if FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height > FWinHeight then
          FWinHeight := FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height;
        if FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width > FWinWidth then
          FWinWidth := FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width;
      end;
  end;
  if FMin + 1 > FMax then
    FMax := FMin + 1;
  if FMin > FPosition then
    FPosition := FMin;
  if FMax < FPosition then
    FPosition := FMax;
  inherited SetSize;
end;

procedure TAoWGauge.SetILFIndex(Value: Integer);
begin
  if Value <> FILIndexFrame then
  begin
    FILIndexFrame := Value;
    FValid := False;
  end;
end;

procedure TAoWGauge.SetILTnIndex(Value: Integer);
begin
  if Value <> FILIndexTNormal then
  begin
    FILIndexTNormal := Value;
    FValid := False;
  end;
end;

procedure TAoWGauge.SetILTsIndex(Value: Integer);
begin
  if Value <> FILIndexTSelected then
  begin
    FILIndexTSelected := Value;
    FValid := False;
  end;
end;

procedure TAoWGauge.SetILFrame(Value: TInterfaceIL);
begin
  if Value <> FILFrame then
  begin
    FValid := False;
    FILFrame := Value;
  end;
end;

procedure TAoWGauge.SetILTNorm(Value: TInterfaceIL);
begin
  if Value <> FILTextureNormal then
  begin
    FValid := False;
    FILTextureNormal := Value;
  end;
end;

procedure TAoWGauge.SetILTSel(Value: TInterfaceIL);
begin
  if Value <> FILTextureSelected then
  begin
    FValid := False;
    FILTextureSelected := Value;
  end;
end;

procedure TAoWGauge.SetPos(Value: Integer);
begin
  if Value <> FPosition then
  begin
    FPosition := Value;
    if FPosition > FMax then
      FPosition := FMax;
    if FMin > FPosition then
      FPosition := FMin;
    FDrawn := False;
  end;
end;

{ Draw: the filled width P is computed from Position without subtracting Min (original bug:
  the gauge is only right for Min = 0) }
procedure TAoWGauge.Draw(SurfDesc: TSurfaceDesc);
var
  OldClip: TRect;
  P: Integer;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      OldClip := SurfDesc.ClipRect;
      case FStyle of
        gtNormal:
          begin
            P := (FWinWidth - FILFrame[FILIndexFrame + 3].Width - FILFrame[FILIndexFrame + 4].Width) *
              FPosition div (FMax - FMin);
            FILFrame.DrawILF(FILIndexFrame, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
            if FAOWWindow.FWinLeft + P + FWinLeft + FILFrame[FILIndexFrame + 3].Width >
              SurfDesc.ClipRect.Left then
              SurfDesc.ClipRect.Left := FAOWWindow.FWinLeft + P + FWinLeft +
                FILFrame[FILIndexFrame + 3].Width;
            FILTextureNormal.DrawILT(FILIndexTNormal, Rect(FAOWWindow.FWinLeft + FWinLeft +
              FILFrame[FILIndexFrame + 3].Width, FAOWWindow.FWinTop + FWinTop +
              FILFrame[FILIndexFrame + 1].Height, FWinWidth - FILFrame[FILIndexFrame + 3].Width -
              FILFrame[FILIndexFrame + 4].Width, FWinHeight - FILFrame[FILIndexFrame + 1].Height -
              FILFrame[FILIndexFrame + 6].Height), SurfDesc);
            SurfDesc.ClipRect := OldClip;
            FILTextureSelected.DrawILT(FILIndexTSelected, Rect(FAOWWindow.FWinLeft + FWinLeft +
              FILFrame[FILIndexFrame + 3].Width, FAOWWindow.FWinTop + FWinTop +
              FILFrame[FILIndexFrame + 1].Height, P, FWinHeight - FILFrame[FILIndexFrame + 1].Height -
              FILFrame[FILIndexFrame + 6].Height), SurfDesc);
          end;
        gtBorderless:
          begin
            P := FPosition * FWinWidth div (FMax - FMin);
            if FAOWWindow.FWinLeft + P + FWinLeft > SurfDesc.ClipRect.Left then
              SurfDesc.ClipRect.Left := FAOWWindow.FWinLeft + P + FWinLeft;
            FILTextureNormal.DrawILT(FILIndexTNormal, Rect(FAOWWindow.FWinLeft + P + FWinLeft,
              FAOWWindow.FWinTop + FWinTop,
              FWinWidth - P, FWinHeight), SurfDesc);
            SurfDesc.ClipRect := OldClip;
            FILTextureSelected.DrawILT(FILIndexTSelected, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, P, FWinHeight), SurfDesc);
          end;
      end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAoWGauge.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TAoWGauge.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

procedure TAoWGauge.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
end;

procedure TAoWGauge.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAoWGauge]);
end;

end.
