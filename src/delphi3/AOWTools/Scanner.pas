unit Scanner;

{ Scanner from AOWTools.dpl. Map and object drawing routines remain draft. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWControl, AOWInterfaceImgLib, AoWE;

type
  TScanner = class;

  TOType = (otBuilding, otArmy, otNatural);  { ot=1 }

  { TScanner: instance size $184; $114 half-row inset, $118/$11C/$120 libraries,
    $124 icons, $128..$134 viewport, $13C change event, $144 update steps,
    $148 map, $14C frame library, $150 frame index, $154/$158 map dimensions,
    $15C level, $160 icons drawn, $164/$168 previous size,
    $170 drawable height, $174/$178 terrain/icon surfaces, $17C update step, $180 incremental. }
  TScanner = class(TAOWControl)
  public
    FHalfRowInset: Integer; { $114 }
    FTilesImageLib: TImageLibrary; { $118 }
    FHighlightImageLib: TImageLibrary; { $11C }
    FFogImageLib: TImageLibrary; { $120 }
    FObjectsImageLib: TImageLibrary; { $124 }
    FTTop: Integer; { $128 }
    FTHeight: Integer; { $12C }
    FTLeft: Integer; { $130 }
    FTWidth: Integer; { $134 }
    FReserved138: Byte;
    FBuildings: Boolean; { $139 }
    FArmies: Boolean; { $13A }
    FNaturals: Boolean; { $13B }
    FOnMapPositionChange: TNotifyEvent; { $13C }
    FSteps: Integer; { $144 }
    FMap: TAbstractAoWHSMap; { $148 }
    FILFrame: TInterfaceIL; { $14C }
    FILIndexFrame: Integer; { $150 }
    FMapWidth: Integer; { $154 }
    FMapHeight: Integer; { $158 }
    FLevel: TMapLevel; { $15C }
    FObjectsDrawn: Boolean; { $160 }
    FPreviousWidth: Integer; { $164 }
    FPreviousHeight: Integer; { $168 }
    FReserved16C: Integer;
    FDrawableHeight: Integer; { $170 }
    FMapSurface: TSurface; { $174 }
    FObjectSurface: TSurface; { $178 }
    FUpdateStep: Integer; { $17C }
    FIncremental: Boolean; { $180 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure SetILFrame(Value: TInterfaceIL); virtual;
    procedure SetILFIndex(A1: Integer);
    procedure SetObjIL(Value: TImageLibrary);
    procedure SetArmies(Value: Boolean);
    procedure SetBuildings(Value: Boolean);
    procedure SetNaturals(Value: Boolean);
    procedure SetLevel(Value: TMapLevel);
    procedure SetMapWidth(A1: Integer);
    procedure SetMapHeight(A1: Integer);
    function GetTerrain(A1: Integer; A2: Integer): Byte;
    procedure SetTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function GetOverlay(X, Y: Integer): Integer;
    procedure SetOverlay(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function GetExplored(X, Y: Integer): Byte;
    procedure SetExplored(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function GetObject(X, Y: Integer): Integer;
    function GetObjectSize: Byte;
    procedure SetObjectSize(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetImgLib(Value: TImageLibrary);
    procedure SetHimgLib(Value: TImageLibrary);
    procedure SetFogimgLib(Value: TImageLibrary);
    procedure SetSteps(A1: Integer);
    procedure SetObDrawn(Value: Boolean);
    procedure SetTLeft(A1: Integer);
    procedure SetTTop(A1: Integer);
    procedure SetTWidth(A1: Integer);
    procedure SetTHeight(A1: Integer);
    procedure SetMap(Value: TAbstractAoWHSMap);
    procedure DrawMap(X, Y, Width, Height: Integer); { draft body }
    procedure DrawObjects;  { draft }
  end;

procedure Register;

implementation

constructor TScanner.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FSteps := 1;
  FTLeft := -1;
  FTTop := -1;
  FTWidth := -1;
  FTHeight := -1;
end;

destructor TScanner.Destroy;
begin
  if FMapSurface <> nil then FMapSurface.Destroy;
  if FObjectSurface <> nil then FObjectSurface.Destroy;
  inherited Destroy;
end;

procedure TScanner.SetILFIndex(A1: Integer);
begin
  if A1 <> FILIndexFrame then
  begin
    FILIndexFrame := A1;
    FValid := False;
  end;
end;

procedure TScanner.SetILFrame(Value: TInterfaceIL);
begin
  if Value <> FILFrame then
  begin
    FValid := False;
    FILFrame := Value;
  end;
end;

procedure TScanner.SetObjIL(Value: TImageLibrary);
begin
  if Value <> FObjectsImageLib then
  begin
    FValid := False;
    FObjectsImageLib := Value;
  end;
end;

procedure TScanner.SetArmies(Value: Boolean);
begin
  if Value <> FArmies then
  begin
    FArmies := Value;
    SetObDrawn(False);
    FDrawn := False;
  end;
end;

procedure TScanner.SetBuildings(Value: Boolean);
begin
  if Value <> FBuildings then
  begin
    FBuildings := Value;
    SetObDrawn(False);
    FDrawn := False;
  end;
end;

procedure TScanner.SetNaturals(Value: Boolean);
begin
  if Value <> FNaturals then
  begin
    FNaturals := Value;
    SetObDrawn(False);
    FDrawn := False;
  end;
end;

procedure TScanner.SetLevel(Value: TMapLevel);
begin
  FLevel := Value;
  if AoWHSMap.FCombatMap <> nil then
  begin
    FMapWidth := FLevel.Width - 16;
    FMapHeight := FLevel.Height - 12;
  end
  else
  begin
    FMapWidth := FLevel.Width - 12;
    FMapHeight := FLevel.Height - 12;
  end;
end;

procedure TScanner.SetMapWidth(A1: Integer);
begin
  if AoWHSMap.FCombatMap <> nil then FMapWidth := A1 - 16
  else FMapWidth := A1 - 12;
end;

procedure TScanner.SetMapHeight(A1: Integer);
begin
  if AoWHSMap.FCombatMap <> nil then FMapHeight := A1 - 12
  else FMapHeight := A1 - 12; { Both original branches subtract 12. }
end;

function TScanner.GetTerrain(A1: Integer; A2: Integer): Byte;
begin
  if AoWHSMap.FCombatMap <> nil then Result := FLevel.GetField(A1 + 8, A2 + 6).TerrainType
  else Result := FLevel.GetField(A1 + 6, A2 + 6).TerrainType;
end;

procedure TScanner.SetTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TScanner.GetOverlay(X, Y: Integer): Integer;
begin
  if AoWHSMap.FCombatMap <> nil then
    case FLevel.GetField(X + 8, Y + 6).GetDecorationType of
      1, 2, 3, 9: Result := 1;
      4, 5: Result := 9;
      6, 7, 8, 14..18: Result := 8;
      10: Result := 3;
      11, 12: Result := 6;
      13: Result := 2;
    else
      Result := FLevel.GetField(X + 8, Y + 6).OverlayType;
    end
  else
    Result := FLevel.GetField(X + 6, Y + 6).OverlayType;
end;

procedure TScanner.SetOverlay(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TScanner.GetExplored(X, Y: Integer): Byte;
var Field: TAoWMapField;
begin
  if AoWHSMap.FCombatMap <> nil then
    Field := TAoWMapField(FLevel.GetField(X + 8, Y + 6))
  else
    Field := TAoWMapField(FLevel.GetField(X + 6, Y + 6));
  if FMap.FExplorationEnabled then
  begin
    if Field.GetExplored(FMap.FSeatedPlayer) then
    begin
      if FMap.FFogEnabled then
      begin
        if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 0 then Result := 2
        else Result := 1;
      end
      else Result := 1;
    end
    else Result := 0;
  end
  else
  begin
    if FMap.FFogEnabled then
    begin
      if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 0 then Result := 2
      else Result := 1;
    end
    else Result := 1;
  end;
end;

procedure TScanner.SetExplored(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TScanner.GetObject(X, Y: Integer): Integer;
begin
  if AoWHSMap.FCombatMap <> nil then
    Result := TAoWMapField(FLevel.GetField(X + 8, Y + 6)).GetScannerIcon
  else Result := TAoWMapField(FLevel.GetField(X + 6, Y + 6)).GetScannerIcon;
end;

function TScanner.GetObjectSize: Byte;
begin
  Result := 1;
end;

procedure TScanner.SetObjectSize(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TScanner.SetImgLib(Value: TImageLibrary);
begin
  FTilesImageLib := Value;
  FValid := False;
end;

procedure TScanner.SetHimgLib(Value: TImageLibrary);
begin
  FHighlightImageLib := Value;
  FValid := False;
end;

procedure TScanner.SetFogimgLib(Value: TImageLibrary);
begin
  FFogImageLib := Value;
  FValid := False;
end;

procedure TScanner.SetSteps(A1: Integer);
begin
  FSteps := A1;
  if FSteps < 1 then FSteps := 1;
end;

procedure TScanner.SetObDrawn(Value: Boolean);
begin
  FObjectsDrawn := Value;
  if not FObjectsDrawn then FDrawn := False;
end;

procedure TScanner.Update;
begin
  inherited Update;
  if FVisible and (FMapSurface <> nil) then
  begin
    if not FIncremental then FIncremental := True;
    if FUpdateStep < FSteps then
    begin
      if FUpdateStep > -1 then
        DrawMap(0, FMapHeight * FUpdateStep div FSteps,
          FMapWidth, FMapHeight div FSteps + 1);
      Inc(FUpdateStep);
    end;
  end;
end;

procedure TScanner.SetTLeft(A1: Integer);
begin
  if A1 <> FTLeft then
  begin
    FDrawn := False;
    FTLeft := A1;
  end;
end;

procedure TScanner.SetTTop(A1: Integer);
begin
  if A1 <> FTTop then
  begin
    FDrawn := False;
    FTTop := A1;
  end;
end;

procedure TScanner.SetTWidth(A1: Integer);
begin
  if A1 <> FTWidth then
  begin
    FDrawn := False;
    FTWidth := A1;
  end;
end;

procedure TScanner.SetTHeight(A1: Integer);
begin
  if A1 <> FTHeight then
  begin
    FDrawn := False;
    FTHeight := A1;
  end;
end;

procedure TScanner.SetMap(Value: TAbstractAoWHSMap);
begin
  FMap := Value;
  if FMap <> nil then
  begin
    FLevel := FMap.MapContainer.GetMapLevel(0);
    if AoWHSMap.FCombatMap <> nil then
    begin
      FMapWidth := FLevel.Width - 16;
      FMapHeight := FLevel.Height - 12;
    end
    else
    begin
      FMapWidth := FLevel.Width - 12;
      FMapHeight := FLevel.Height - 12;
    end;
    FIncremental := False;
    FSized := False;
  end;
end;

procedure TScanner.Validate;
var Frame: TInterfaceIL;
begin
  Frame := FILFrame;
  if Frame <> nil then FILFrame := Frame.CheckIL(FILIndexFrame, 8, Self);
  if (FILFrame <> nil) and (FTilesImageLib <> nil) and (FObjectsImageLib <> nil) and
    (FMap <> nil) and (FFogImageLib <> nil) and (FHighlightImageLib <> nil) then
    FValid := True;
  inherited Validate;
end;

procedure TScanner.SetSize;
var X, Y: Integer; SD: TSurfaceDesc;
begin
  if ((FWinWidth <> FPreviousWidth) or (FWinHeight <> FPreviousHeight)) and
    (FWinWidth > 0) and (FWinHeight > 0) then
  begin
    FHalfRowInset := FWinHeight div FMapHeight div 2;
    FDrawableHeight := FWinHeight - FHalfRowInset;
    if FMapSurface <> nil then
    begin
      FObjectSurface.Resize(FWinWidth, FWinHeight);
      FObjectSurface.Cls($FF00);
      FMapSurface.Resize(FWinWidth, FWinHeight);
      FMapSurface.Lock(SD);
      for X := 0 to FWinWidth div FFogImageLib[0].Width do
        for Y := 0 to FWinHeight div FFogImageLib[0].Height do
          FFogImageLib[0].ShowClipped(X * FFogImageLib[0].Width, Y * FFogImageLib[0].Height, SD);
      FMapSurface.Unlock;
      if not FIncremental then
      begin
        DrawMap(0, 0, FMapWidth, FMapHeight);
        FUpdateStep := FSteps;
      end
      else FUpdateStep := -1;
    end;
    FPreviousWidth := FWinWidth;
    FPreviousHeight := FWinHeight;
  end;
  inherited SetSize;
end;

procedure TScanner.DrawMap(X, Y, Width, Height: Integer);
begin end;

procedure TScanner.DrawObjects;
begin end;

procedure TScanner.Draw(SurfDesc: GFXE.TSurfaceDesc);
begin end;

procedure TScanner.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
var OldLeft, OldTop: Integer; begin if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then begin FMouseDown := True; X := (X - FAOWWindow.FWinLeft - FWinLeft) * FMapWidth div FWinWidth; Y := (Y - FAOWWindow.FWinTop - FWinTop) * FMapHeight div FDrawableHeight; OldLeft := FTLeft; OldTop := FTTop; FTLeft := X - FTWidth div 2; FTTop := Y - FTHeight div 2; if (FTTop <> OldTop) or (OldLeft <> FTLeft) then begin FDrawn := False; if Assigned(FOnMapPositionChange) then FOnMapPositionChange(Self); end; end; end;

procedure TScanner.CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin FHandled := False; if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then begin FHandled := True; if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y); end; FMouseDown := False; end;

procedure TScanner.CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer);
var MapX, MapY, OldLeft, OldTop: Integer; begin inherited CheckMouseMove(Shift, X, Y); FHandled := False; if (X >= FAOWWindow.FWinLeft + FWinLeft) and (X <= FAOWWindow.FWinLeft + FWinLeft + FWinWidth - 1) and (Y >= FAOWWindow.FWinTop + FWinTop) and (Y <= FAOWWindow.FWinTop + FWinTop + FWinHeight - 1) then begin FHandled := True; if FMouseDown = True then begin OldLeft := FTLeft; OldTop := FTTop; MapX := (X - FAOWWindow.FWinLeft - FWinLeft) * FMapWidth div FWinWidth; MapY := (Y - FAOWWindow.FWinTop - FWinTop) * FMapHeight div FDrawableHeight; FTLeft := MapX - FTWidth div 2; FTTop := MapY - FTHeight div 2; if (FTTop <> OldTop) or (FTLeft <> OldLeft) then begin FDrawn := False; if Assigned(FOnMapPositionChange) then FOnMapPositionChange(Self); end; end; if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y); end; end;

procedure Register;
begin
  RegisterComponents('AOW Tools', [TScanner]);
end;


initialization
finalization

end.
