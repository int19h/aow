unit CombatTerrain;

{ CombatTerrain, AoWTCPCK.dpl. Layouts and VMT order follow the original.
  Terrain: $14 shadow, $18 hit points, $1C damaged, $20 defense.
  Shadow: $08 terrain. Resource: $49 defense; $48/$4A/$4B persisted values. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC;

type
  TCombatTerrainShadow = class;
  TCombatTerrain = class;
  TCombatTerrainResource = class;


  { TCombatTerrainShadow (instance size 12, VMT 0040FB0C) }
  TCombatTerrainShadow = class(THexagonSprite)
  public
    FTerrain: TCombatTerrain; { $08 }
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TCombatTerrain (instance size 36, VMT 0040FCA0) }
  TCombatTerrain = class(TTerrainMO)
  public
    FShadow: TCombatTerrainShadow; { $14 }
    FHitPoints: Integer; { $18 }
    FDamaged: Boolean; { $1C }
    F_CombatTerrain_1D: array[0..2] of Byte;
    FDefense: Integer; { $20 }
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean; override;
    procedure DestroyShadow;
    procedure CreateShadow;
    procedure SetHitPoints(Value: Integer);
    procedure ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
  end;

  { TCombatTerrainResource (instance size 76, VMT 0040FE54) }
  TCombatTerrainResource = class(TTerrainMOR)
  public
    F_CombatTerrainResource_48: Byte;
    FDefense: Shortint; { $49 }
    F_CombatTerrainResource_4A: Byte;
    F_CombatTerrainResource_4B: Boolean;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCombatTerrain(AEngine: TEngine);

implementation

function TCombatTerrainShadow.GetShowPriority: Integer;
begin
  Result := (FTerrain.GetShowPriority and $3FFFFFF) - $8000000;
end;

procedure TCombatTerrainShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  FTerrain.ShowShadow(XhpSurf, YhpSurf, SurfaceDesc);
end;

class function TCombatTerrain.ClassID: Integer;
begin Result := $220166; end;

destructor TCombatTerrain.Destroy;
begin
  DestroyShadow;
  inherited Destroy;
end;

function TCombatTerrain.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin
  Result := AoWHSSet.FCombatResources;
end;

procedure TCombatTerrain.DestroyShadow;
begin
  if FShadow <> nil then
  begin
    if GetVisible then FResource.Engine.HSMap.DynamicVisibleHS.RemoveChild(FShadow);
    FShadow.Free;
    FShadow := nil;
  end;
end;

function TCombatTerrain.CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean;
begin
  Result := inherited CanPlaceOnHS(HS) or (HS is TAbstractRoad);
end;

procedure TCombatTerrain.CreateShadow;
begin
  if FResource.ImageSequenceList.GetImageSequence(40) <> nil then
  begin
    if FShadow <> nil then DestroyShadow;
    if (AoWHSMap = nil) or AoWHSMap.FShowUnitShadows then
    begin
      FShadow := TCombatTerrainShadow.Create(nil);
      FShadow.FTerrain := Self;
    end;
  end;
end;

procedure TCombatTerrain.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  if not (moVisible in FStatus) then
  begin
    inherited MakeVisible(VisibilityList);
    if FShadow <> nil then VisibilityList.AddSortChild(FShadow, FShadow.GetShowPriority);
  end;
end;

procedure TCombatTerrain.SetHitPoints(Value: Integer);
begin
  FDamaged := True; { Original ignores Value and only marks the terrain damaged. }
end;

procedure TCombatTerrain.ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  X, Y: Integer;
begin
  HXtoHP(FXhx, FYhx, X, Y);
  XhpSurf := X - XhpSurf;
  YhpSurf := Y - YhpSurf;
  FResource.ShowComplexImage(XhpSurf, YhpSurf, SurfaceDesc, 40,
    TMapField(Owner).Xhx + (TMapField(Owner).Yhx shl 4));
end;

procedure TCombatTerrain.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
var
  AbilityInfo: TAbilityCombatInfo;
  SpellInfo: TSpellCombatInfo;
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.HN = 0 then
  begin
    if TTerrainMOR(FResource).DecorationType in [1..3] then
      case Msg.MsgID of
        $31000:
          begin
            AoWHSSet.FAbilityControl.GetAbility(65).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - FDefense));
          end;
        $31001:
          begin
            AoWHSSet.FAbilityControl.GetAbility(24).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - FDefense));
          end;
        $31002:
          begin
            AoWHSSet.FAbilityControl.GetAbility(44).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - FDefense));
          end;
        $31003:
          begin
            AoWHSSet.FSpellControl.GetSpell(117).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - FDefense));
          end;
        $3100A:
          begin
            AoWHSSet.FAbilityControl.GetAbility(31).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - FDefense));
          end;
        $3100B:
          begin
            AoWHSSet.FSpellControl.GetSpell(113).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - FDefense));
          end;
        $31012:
          begin
            if (Msg.Param[1] = 30) or (Msg.Param[1] = 86) then
            begin
            AoWHSSet.FAbilityControl.GetAbility(Msg.Param[1]).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - FDefense));
            end;
          end;
        $31013:
          begin
            if Msg.Param[1] = 114 then
            begin
            AoWHSSet.FSpellControl.GetSpell(Msg.Param[1]).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - FDefense));
            end;
          end;
        $31006:
          begin
            AoWHSSet.FSpellControl.GetSpell(116).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - FDefense));
          end;
        $3100D:
          begin
            AoWHSSet.FSpellControl.GetSpell(127).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - FDefense));
          end;
        $3100E:
          begin
            AoWHSSet.FSpellControl.GetSpell(128).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - FDefense));
          end;
        $31004:
          begin
            FDamaged := Msg.Param[1] = 0;
            AoWHSSet.FSpellControl.GetSpell(112).GetCombatInfo(TCombatUnit(Msg.Param[0]).FUnit, SpellInfo);
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(SpellInfo.Damage, SpellInfo.Attack - FDefense));
            Msg.Param[1] := 1;
          end;
        $31007:
          begin
            RandSeed := AoWHSMap.Random($FFFFFF);
            SetHitPoints(FHitPoints - ExecuteDamageRole(TCDamage[1], TCAttack[1] - FDefense));
          end;
      end;
    case Msg.MsgID of
      $21001:
        if (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) and
          (Msg.Param[0] < TCombatTerrainResource(FResource).FDefense) then
          Msg.Param[0] := TCombatTerrainResource(FResource).FDefense;
    end;
  end;
end;

procedure TCombatTerrain.Activate;
begin
  inherited Activate;
  if TTerrainMOR(FResource).DecorationType in [1..3] then FHitPoints := 3
  else FHitPoints := 0;
  FDefense := -2;
  CreateShadow;
end;

procedure TCombatTerrain.Deactivate;
begin
  DestroyShadow;
  inherited Deactivate;
end;

function TCombatTerrain.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then UpdateMapFields(TMapLevel(Owner.Owner), Xhx, Yhx);
end;

procedure TCombatTerrain.RemoveFromMap;
var
  MapLevel: TMapLevel;
begin
  MapLevel := TMapLevel(Owner.Owner);
  inherited RemoveFromMap;
  UpdateMapFields(MapLevel, FXhx, FYhx);
end;

procedure TCombatTerrain.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  inherited UpdateMapField(Info);
  if Info.HN < FResource.TerrainList.Count then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $4000;
end;

procedure TCombatTerrain.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled(59) then
    if FResource.TerrainList.GetOverlay(Info.HN) = 8 then
    begin
      MoveResult.Code := -1;
      MoveResult.Done := True;
    end;
end;

class function TCombatTerrainResource.ClassID: Integer;
begin Result := $220167; end;

function TCombatTerrainResource.ResourceUserClassID: Integer;
begin Result := $220166; end;

class function TCombatTerrainResource.ResourceEditName: string;
begin Result := 'Combat Terrain'; end;

procedure TCombatTerrainResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FDefense), 20);
  Stream.rwByte(F_CombatTerrainResource_48, 21);
  Stream.rwByte(F_CombatTerrainResource_4A, 22);
  Stream.rwBool(F_CombatTerrainResource_4B, 23);
end;

procedure RegisterCombatTerrain(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCombatTerrain, TCombatTerrainResource]);
end;


initialization
finalization

end.
