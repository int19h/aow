unit CombatStructure;

{ Destructible combat structures, recovered from AoWTCPCK.dpl. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatILTer;

type
  TCombatStructure = class;
  TCombatStructureResource = class;


  { TCombatStructure (instance size 40, VMT 0043258C) }
  TCombatStructure = class(TCombatFixedILTerrain)
  public
    FHitPoints: Integer; { $20 }
    FPlaySound: Boolean; { $24 }
    F_CombatStructure_25: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean; override;
    function ValidTerrainType(TerrainType: Integer): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    procedure SetHitPoints(Value: Integer);
  end;

  { TCombatStructureResource (instance size 72, VMT 00432750) }
  TCombatStructureResource = class(TCombatFixedILTerrainResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;


implementation

uses AoWE, AoWTC, CombatRoad;

constructor TCombatStructure.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetHitPoints(5);
end;

class function TCombatStructure.ClassID: Integer;
begin Result := $220506; end;

procedure TCombatStructure.Activate;
var
  Structure: TPlayerStructure;
  Razed: Boolean;
begin
  inherited Activate;
  if not (msEditting in AoWCombatMap.Status) then
  begin
    FPlaySound := True;
    Razed := False;
    Structure := TPlayerStructure(AoWHSMap.MapContainer.GetMapLevel(CombatLLoc).
      GetField(CombatXLoc, CombatYLoc).FindNoneTransparentHS(TPlayerStructure));
    if Structure <> nil then Razed := Structure.GetRazed;
    if Razed then SetHitPoints(0)
    else SetHitPoints(5);
  end
  else SetHitPoints(5);
end;

procedure TCombatStructure.SetHitPoints(Value: Integer);
var
  Effect: TfxHS;
  Point: TXYZ;
begin
  if Value < 0 then Value := 0;
  if Value < FHitPoints then
    if Value = 0 then
    begin
      if FPlaySound and AoWCombatMap.FPlaySounds then
        PlaySample('SFX\HIT_DEATH\D_WOODLG.WAV');
      Effect := AoWCombatMap.AddEffect(fxWallSmoke);
      Point := TXYZ.Create;
      Effect.FPath.Add(Point);
      HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Point.X, Point.Y);
      Point.X := Random(20) + Point.X + 6;
      Point.Y := Random(20) + Point.Y - 20;
    end
    else
      if FPlaySound and AoWCombatMap.FPlaySounds then
        PlaySample('SFX\HIT_DEATH\D_WOODMD.WAV');
  FHitPoints := Value;
  FPlaySound := True;
end;

procedure TCombatStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
var
  AbilityInfo: TAbilityCombatInfo;
  SpellInfo: TSpellCombatInfo;
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.HN = 0 then
    case Msg.MsgID of
      $31000:
        begin
          AoWHSSet.FAbilityControl.GetAbility($41).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - GetDefense));
        end;
      $31001:
        begin
          AoWHSSet.FAbilityControl.GetAbility($18).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - GetDefense));
        end;
      $31002:
        begin
          AoWHSSet.FAbilityControl.GetAbility($2c).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - GetDefense));
        end;
      $31003:
        begin
          AoWHSSet.FSpellControl.GetSpell($75).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - GetDefense));
        end;
      $3100a:
        begin
          AoWHSSet.FAbilityControl.GetAbility($1f).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - GetDefense));
        end;
      $3100b:
        begin
          AoWHSSet.FSpellControl.GetSpell($71).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - GetDefense));
        end;
      $31012:
        if (Msg.Param[1] = $1E) or (Msg.Param[1] = $56) then
        begin
          AoWHSSet.FAbilityControl.GetAbility(Msg.Param[1]).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - GetDefense));
        end;
      $31013:
        if Msg.Param[1] = $72 then
        begin
          AoWHSSet.FSpellControl.GetSpell(Msg.Param[1]).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - GetDefense));
        end;
      $31006:
        begin
          AoWHSSet.FSpellControl.GetSpell($74).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - GetDefense));
        end;
      $3100d:
        begin
          AoWHSSet.FSpellControl.GetSpell($7f).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - GetDefense));
        end;
      $3100e:
        begin
          AoWHSSet.FSpellControl.GetSpell($80).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - GetDefense));
        end;
      $31004:
        begin
          FPlaySound := Msg.Param[1] = 0;
          AoWHSSet.FSpellControl.GetSpell($70).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - GetDefense));
          Msg.Param[1] := 1;
        end;
      $31007:
        begin
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(TCDamage[1], TCAttack[1] - GetDefense));
        end;
    end;
end;

procedure TCombatStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  inherited UpdateMapField(Info);
  if Info.HN = 0 then
    TAoWMapField(Info.MapField).FFieldFlags :=
      TAoWMapField(Info.MapField).FFieldFlags or $4000 or $2000;
end;

procedure TCombatStructure.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if FResource.TerrainList.GetUsed(Info.HN) then
  begin
    if FHitPoints = 0 then
      MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, 6]
    else if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($3B) then
      MoveResult.Code := -1
    else MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, 8];
    MoveResult.Done := True;
  end;
end;

function TCombatStructure.GetOverlay(Index: Integer): Shortint;
begin
  if FResource.TerrainList.GetTerrain(Index) >= 0 then
    if FHitPoints = 0 then Result := 6
    else Result := 8
  else Result := -1;
end;

function TCombatStructure.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin
  if TerrainType = 3 then Result := 20
  else if TerrainType in [5, 12] then Result := 40
  else Result := 0;
end;

procedure TCombatStructure.ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin end;

function TCombatStructure.ValidTerrainType(TerrainType: Integer): Boolean;
begin Result := True; end;

function TCombatStructure.CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean;
begin Result := inherited CanPlaceOnHS(HS) or (HS is TCombatRoad); end;

function TCombatStructure.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := inherited CanPlace(MapContainer, Xhx, Yhx, Lhx); end;

class function TCombatStructureResource.ClassID: Integer;
begin Result := $220507; end;

class function TCombatStructureResource.ResourceEditName: string;
begin Result := 'Combat Structure'; end;

function TCombatStructureResource.ResourceUserClassID: Integer;
begin Result := $220506; end;

initialization
finalization

end.
