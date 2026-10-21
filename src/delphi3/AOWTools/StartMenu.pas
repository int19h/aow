unit StartMenu;

{ Start menu from AOWTools.dpl, recovered from the original machine code. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenu, AOWWinManager, AOWMenuBar;

type
  TStartMenu = class;


  { TStartMenu: instance size $258; $254 whole-menu image library. }
  TStartMenu = class(TAOWMenu)
  public
    FILWholeMenu: TImageLibrary; { $254 }
    procedure SetSize; override;
    procedure SetVisible(Value: Boolean); override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
  end;

procedure Register;

implementation

procedure TStartMenu.SetSize;
var M: TAOWWinManager;
begin
  inherited SetSize;
  FWinHeight := 377;
  M := FWinManager;
  if (M <> nil) and (FOwnerMenuBar <> nil) then
    FWinTop := M.FWinHeight - 393;
  FWinLeft := 0;
end;

procedure TStartMenu.SetVisible(Value: Boolean);
var M: TAOWWinManager; B: TAOWMenuBar;
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    if FVisible = True then
    begin
      FHighlighted := -1;
      FWinHeight := 377;
      M := FWinManager;
      if (M <> nil) and (FOwnerMenuBar <> nil) then
        FWinTop := M.FWinHeight - 393;
      FWinLeft := 0;
      FDrawn := False;
      if not FHidden then
      begin
        FBackRect.Right := FWinWidth;
        FBackRect.Bottom := FWinHeight;
        FBackRect.Top := FWinTop;
        FBackRect.Left := FWinLeft;
      end;
      if Assigned(FOnShow) then FOnShow(Self);
    end
    else
    begin
      B := FOwnerMenuBar;
      if B <> nil then
      begin
        B.FSelected := -1;
        B.FDrawn := False;
      end;
      FHidden := True;
      if Assigned(FOnHide) then FOnHide(Self);
    end;
  end;
  if FVisible then
  begin
    if not FValid or not FAligned or not FSized then Setup;
    Update;
    ReAlign;
    FDrawn := False;
    SetPriority(FPriority);
  end;
end;

procedure TStartMenu.Draw(SurfDesc: GFXE.TSurfaceDesc);
var I: Integer; OldClip: TRect;
begin
  try
    if FValid and FVisible then
    begin
      if not FDrawn then
      begin
        OldClip := SurfDesc.ClipRect;
        FAOWFont.Color := FColor;
        FILWholeMenu[FHighlighted + 1].ShowClipped(0, 0, SurfDesc);
        for I := 0 to FItems.Count - 1 do
          if FItems.Count > 0 then
          begin
            if FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 2].Width < OldClip.Right then
              SurfDesc.ClipRect.Right := FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 2].Width;
            if I = FHighlighted then FAOWFont.Color := FSelColor;
            FAOWFont.SetText(FWinLeft + FBorderWidth + FILFrame[FILIndexFrame + 3].Width,
              FWinTop + FBorderHeight + FILFrame[FILIndexFrame].Height + FItemHeight * I,
              FItems[I], SurfDesc);
            if I = FHighlighted then FAOWFont.Color := FColor;
            FDrawItem := I;
            FDrawItemRect := Rect(FWinLeft + FILFrame[FILIndexFrame + 3].Width,
              FWinTop + FILFrame[FILIndexFrame + 1].Height + FItemHeight * I,
              FWinLeft + FWinWidth, FWinTop + FILFrame[FILIndexFrame + 1].Height + (I + 1) * FItemHeight);
            if Assigned(FOnDrawItem) then FOnDrawItem(Self);
            SurfDesc.ClipRect := OldClip;
          end;
      end;
      if Assigned(FOnDraw) then FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TStartMenu.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  if FValid then
  begin
    Dec(FWinHeight, FILFrame[FILIndexFrame + 6].Height);
    inherited CheckMouseDown(Button, Shift, X, Y);
    Inc(FWinHeight, FILFrame[FILIndexFrame + 6].Height);
  end;
end;

procedure Register;
begin
  RegisterComponents('AOW Tools', [TStartMenu]);
end;


initialization
finalization

end.
