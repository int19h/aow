unit AoWBookWindow;

{ Book window and page-turn animation from AOWTools.dpl. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWWindow, PageTurnCtrl;

type
  TAoWBookWindow = class;


  { TAoWBookWindow: instance size $208; $1EC completion event, $1F4 first frame,
    $1F5 previous surface validity, $1F8 page turn, $1FC animating,
    $200 saved page surface, $204 page-turn mode. }
  TAoWBookWindow = class(TAOWWindow)
  public
    FOnAnimationComplete: TNotifyEvent; { $1EC }
    FFirstAnimationFrame: Boolean; { $1F4 }
    FPreviousSurfaceValid: Boolean; { $1F5 }
    FPageTurn: TPageTurnControl; { $1F8 }
    FAnimating: Boolean; { $1FC }
    FPageSurface: TSurface; { $200 }
    FPageTurnMode: TPageTurnMode; { $204 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Update; override;
    procedure SetVisible(Value: Boolean); override;
    procedure DrawSurface(Surface: GFXE.TSurface); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Blt(Surface: GFXE.TSurface); override;
    procedure StartAnim(Mode: TPageTurnMode);
  end;

procedure Register;

implementation

constructor TAoWBookWindow.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FPageTurn := TPageTurnControl.Create;
end;

destructor TAoWBookWindow.Destroy;
var S: TSurface;
begin
  FPageTurn.Free;
  S := FPageSurface;
  if S <> nil then S.Free;
  inherited Destroy;
end;

procedure TAoWBookWindow.SetVisible(Value: Boolean);
var S: TSurface;
begin
  if Value <> FVisible then
  begin
    FAnimating := False;
    if FFreeSurfaceOnHide then
    begin
      S := FPageSurface;
      if S <> nil then
      begin
        S.Free;
        FPageSurface := nil;
      end;
    end;
  end;
  inherited SetVisible(Value);
end;

procedure TAoWBookWindow.Update;
begin
  if FVisible and FAnimating then
  begin
    FSurfaceValid := False;
    if not FPageTurn.UpdateScene then
    begin
      FAnimating := False;
      if Assigned(FOnAnimationComplete) then FOnAnimationComplete(Self);
    end;
  end;
  inherited Update;
end;

procedure TAoWBookWindow.StartAnim(Mode: TPageTurnMode);
var Source, Dest: TSurfaceDesc; R: TRect;
begin
  if (FBackSurface <> nil) and (FPageSurface <> nil) then
  begin
    R := Rect(0, 0, FWinWidth, FWinHeight);
    FBackSurface.Lock(Source);
    FPageSurface.Lock(Dest);
    BltSDRectClipped(Source, R, Dest, 0, 0);
    FPageSurface.Unlock;
    FBackSurface.Unlock;
    FPageTurn.SetPageDimensions(271, 368);
    FPageTurn.FSpeed := 15;
    FPageTurn.Start(Mode);
    FPageTurnMode := Mode;
    FDrawn := False;
    FAnimating := True;
    FFirstAnimationFrame := True;
  end;
end;

procedure TAoWBookWindow.DrawSurface(Surface: GFXE.TSurface);
begin
  FPreviousSurfaceValid := FSurfaceValid;
  inherited DrawSurface(Surface);
  if FPreviousSurfaceValid and FAnimating then Blt(Surface);
end;

procedure TAoWBookWindow.Blt(Surface: GFXE.TSurface);
var
  Flags: TDDSCreationFlags;
  Dest, Source, OldPage: TSurfaceDesc;
  R: TRect;
begin
  if FPageSurface <> nil then
    if (FPageSurface.PixelFormatID <> FBackSurface.PixelFormatID) or
      (FPageSurface.Width <> FBackSurface.Width) or
      (FPageSurface.Height <> FBackSurface.Height) or
      ((FPageSurface is TDDrawSurface) xor (FBackSurface is TDDrawSurface)) then
    begin
      FPageSurface.Free;
      FPageSurface := nil;
    end;
  if FPageSurface = nil then
  begin
    if FBackSurface is TDDrawSurface then
    begin
      if (ssVideoMemory in TDDrawSurface(FBackSurface).Status) and FUseVMem then
        Flags := [cfVideoMemory, cfSystemMemory]
      else Flags := [cfSystemMemory];
      FPageSurface := TDDrawSurface.Create;
      TDDrawSurface(FPageSurface).CreateSurface(FWinWidth, FWinHeight,
        FBackSurface.PixelFormatID, Flags);
    end
    else FPageSurface := TDataSurface.Create(FWinWidth, FWinHeight,
      FBackSurface.PixelFormatID, nil);
    R := Rect(0, 0, FWinWidth, FWinHeight);
    FBackSurface.BltClipped(FPageSurface, @R, 0, 0);
  end;
  if FAnimating then
  begin
    if FFirstAnimationFrame or not FPreviousSurfaceValid then
    begin
      R := Rect(0, 0, FWinWidth, FWinHeight);
      case FPageTurnMode of
        ptLeft:
          if not FMasked then FBackSurface.BltClipped(Surface, @R, FWinLeft, FWinTop)
          else FBackSurface.BltColorKeyClipped(Surface, @R, FWinLeft, FWinTop,
            Color2PixelInfo(FMaskColor, FBackSurface.PixelFormatID, nil));
        ptRight:
          if not FMasked then FPageSurface.BltClipped(Surface, @R, FWinLeft, FWinTop)
          else FPageSurface.BltColorKeyClipped(Surface, @R, FWinLeft, FWinTop,
            Color2PixelInfo(FMaskColor, FPageSurface.PixelFormatID, nil));
      end;
      FFirstAnimationFrame := False;
    end;
    Surface.Lock(Dest);
    FBackSurface.Lock(Source);
    FPageSurface.Lock(OldPage);
    FPageTurn.RenderScene(FWinLeft + FBorderWidth, FWinTop + FBorderHeight,
      Dest, FBorderWidth, FBorderHeight, OldPage, FBorderWidth, FBorderHeight, Source, R);
    FPageSurface.Unlock;
    FBackSurface.Unlock;
    Surface.Unlock;
    FBackRect.Top := R.Top;
    if (FWinTop > FBackRect.Top) or (FBackRect.Top > FWinTop + FFrameTop) then
      FBackRect.Top := FWinTop - 1;
    FBackRect.Bottom := FWinTop - R.Top + FWinHeight;
    FSurfaceValid := True;
    if Assigned(FOnDrawSurface) then FOnDrawSurface(Self, Surface, FWinLeft, FWinTop);
  end
  else inherited Blt(Surface);
end;

procedure TAoWBookWindow.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  FHandled := FAnimating;
  if not FAnimating then inherited CheckMouseDown(Button, Shift, X, Y)
  else if (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and
    (Y > FWinTop - 1) and (Y < FWinTop + FWinHeight) then
  begin
    FSurfaceValid := False;
    FAnimating := False;
    if Assigned(FOnAnimationComplete) then FOnAnimationComplete(Self);
  end;
end;

procedure TAoWBookWindow.CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  FHandled := FAnimating;
  if not FAnimating then inherited CheckMouseUp(Button, Shift, X, Y);
end;

procedure TAoWBookWindow.CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer);
begin
  FHandled := FAnimating;
  if not FAnimating then inherited CheckMouseMove(Shift, X, Y);
end;

procedure Register;
begin
  RegisterComponents('AOW Tools', [TAoWBookWindow]);
end;


initialization
finalization

end.
