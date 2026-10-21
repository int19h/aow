unit CombatFire;

{ Combat fire, recovered from AoWTCPCK.dpl. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TCombatFire = class;
  TCombatFireResource = class;


  { TCombatFire (instance size 28, VMT 00406B24) }
  TCombatFire = class(TSingleHS)
  public
    FXShift: Integer; { $0C }
    FYShift: Integer; { $10 }
    FPlayer: Integer; { $14 }
    FFirstTurn: Boolean; { $18 }
    F_CombatFire_19: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    procedure SetVisible(Value: Boolean); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure DeActivate; override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    procedure NewTurn;
  end;

  { TCombatFireResource (instance size 68, VMT 00406CA8) }
  TCombatFireResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure CreateFire(Spread: Boolean; Chance, Xhx, Yhx: Integer);
procedure RegisterCombatFire(AEngine: TEngine);

implementation

uses AoWE, AoWTC, CombatILTer, CityWall;

procedure TCombatFire.DeActivate;
begin
  inherited Deactivate;
end;

constructor TCombatFire.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

destructor TCombatFire.Destroy;
begin
  inherited Destroy;
end;

procedure TCombatFire.SetVisible(Value: Boolean);
begin
  inherited SetVisible(Value);
end;

procedure TCombatFire.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  inherited MakeVisible(VisibilityList);
end;

class function TCombatFire.ClassID: Integer;
begin Result := $22054A; end;

function TCombatFire.GetLevel: Byte;
begin Result := 27; end;

function TCombatFire.GetShowPriority: Integer;
begin Result := $6C000000; end;

procedure TCombatFire.Activate;
begin
  inherited Activate;
  FXShift := Random(10) + 11;
  FYShift := Random(10) + 11;
  FPlayer := AoWCombatMap.FCurrentCombatPlayer;
  FFirstTurn := True;
end;

procedure TCombatFire.NewTurn;
var
  I, Xhx, Yhx: Integer;
  Msg: TMapFieldMsg;
begin
  if FFirstTurn then FFirstTurn := False
  else if AoWCombatMap.FCurrentCombatPlayer = FPlayer then
  begin
    Msg.MsgID := $31007;
    Msg.Param[0] := Integer(Self);
    Msg.Result := -1;
    AoWCombatMap.MapContainer.GetMapLevel(0).GetField(GetXhx, GetYhx).SendMapFieldMsg(Msg);
    for I := 1 to 6 do
    begin
      CenterHNtoHX(GetXhx, GetYhx, I, Xhx, Yhx);
      if (Xhx > 0) and (Yhx > 0) then CreateFire(True, 50, Xhx, Yhx);
    end;
    Free;
  end;
end;

procedure TCombatFire.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20021001 then
    if not (msEditting in AoWCombatMap.Status) then NewTurn;
end;

procedure TCombatFire.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  ImageIndex, Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  Sequence := AoWHSSet.FImageSequences.GetImageSequence(60);
  if Sequence <> nil then
    repeat
      ImageIndex := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
      if ImageIndex <> -1 then
        Sequence.ImageLibrary.Get(ImageIndex).Show(
          XhpSurf + Sequence.dXshift + FXShift,
          YhpSurf + Sequence.dYshift + FYShift, SurfaceDesc);
      Sequence := Sequence.Next;
    until Sequence = nil;
end;

procedure TCombatFire.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
var
  Penalty: Integer;
begin
  if Info.HN = 0 then
  begin
    if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled(7) then Penalty := 0
    else if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($47) then Penalty := 10
    else Penalty := 20;
    if MoveResult.Code > 127 - Penalty then MoveResult.Code := 127
    else Inc(MoveResult.Code, Penalty);
  end;
end;

class function TCombatFireResource.ClassID: Integer;
begin Result := $22054B; end;

class function TCombatFireResource.ResourceEditName: string;
begin Result := 'Combat Fire'; end;

function TCombatFireResource.ResourceUserClassID: Integer;
begin Result := $22054A; end;

procedure CreateFire(Spread: Boolean; Chance, Xhx, Yhx: Integer);
var
  Fire: TCombatFire;
  CanBurn: Boolean;
  Terrain: TCombatILTerrain;
  Wall: TCityWall;
begin
  if AoWCombatMap.MapContainer.GetMapLevel(0).GetField(Xhx, Yhx).TerrainType <> 15 then
    if AoWCombatMap.MapContainer.GetMapLevel(0).GetField(Xhx, Yhx).FindOwnedChild($22054A) = nil then
      if AoWHSMap.Random(100) < Chance then
      begin
        CanBurn := False;
        if (AoWCombatMap.MapContainer.GetMapLevel(0).GetField(Xhx, Yhx).GetDecorationType = 9) or
          (AoWCombatMap.MapContainer.GetMapLevel(0).GetField(Xhx, Yhx).GetDecorationType = 1) or
          (AoWCombatMap.MapContainer.GetMapLevel(0).GetField(Xhx, Yhx).GetDecorationType = 2) or
          (AoWCombatMap.MapContainer.GetMapLevel(0).GetField(Xhx, Yhx).GetDecorationType = 3) then
          CanBurn := True
        else
        begin
          Terrain := TCombatILTerrain(AoWCombatMap.MapContainer.GetMapLevel(0).GetField(Xhx, Yhx).FindOwnedChild($220136));
          if Terrain <> nil then
            if Terrain.GetBurnValue > 0 then CanBurn := True;
          Wall := TCityWall(AoWCombatMap.MapContainer.GetMapLevel(0).GetField(Xhx, Yhx).FindOwnedChild($220504));
          if Wall <> nil then
            if Wall.FWallType = 1 then
              if Wall.FHitPoints > 0 then CanBurn := True;
        end;
        if CanBurn then
        begin
          Fire := TCombatFire.Create(nil);
          if not AoWCombatMap.PlaceHX(Fire, Xhx, Yhx, 0) then Fire.Free;
        end;
      end;
end;

procedure RegisterCombatFire(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCombatFire, TCombatFireResource]);
end;

initialization
finalization

end.
