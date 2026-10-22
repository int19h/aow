unit CityWall;

{ Combat city walls and gates recovered from AoWTCPCK.dpl. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatILTer, AoWE, City, Tower;

type
  TCityWall = class;
  TCityWallResource = class;
  TCityWallDoor = class;
  TCityWallDoorResource = class;


  { TCityWall (instance size 48, VMT 00405008) }
  TCityWall = class(TCombatILTerrain)
  public
    FHitPoints: Integer; { $20 }
    FDamageImage: Integer; { $24 }
    FFlagID: Integer; { $28 }
    FPlaySound: Boolean; { $2C }
    FWallType: Byte; { $2D }
    F_CityWall_2E: array[0..1] of Byte;
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function ValidTerrainType(TerrainType: Integer): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function GetDirection: Byte;
    function GetDefense: Integer;
    procedure SetHitPoints(Value: Integer);
  end;

  { TCityWallResource (instance size 76, VMT 004051B4) }
  TCityWallResource = class(TCombatILTerrainResource)
  public
    FDirection: Byte; { $48 }
    F_CityWallResource_49: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TCityWallDoor (instance size 48, VMT 004052AC) }
  TCityWallDoor = class(TCityWall)
  public
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
  end;

  { TCityWallDoorResource (instance size 76, VMT 00405460) }
  TCityWallDoorResource = class(TCityWallResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCityWall(AEngine: TEngine);

implementation
uses AoWTC;

class function TCityWall.ClassID: Integer;
begin Result := $220504; end;

procedure TCityWall.Activate;
var
  Structure: TPlayerStructure;
  Razed: Boolean;
begin
  inherited Activate;
  if not (msEditting in AoWCombatMap.Status) then
  begin
    Razed := False;
    FPlaySound := True;
    Structure := TPlayerStructure(AoWHSMap.MapContainer.GetMapLevel(CombatLLoc).
      GetField(CombatXLoc, CombatYLoc).FindNoneTransparentHS(TCity));
    if Structure <> nil then
    begin
      FWallType := TCity(Structure).FWallType;
      Razed := Structure.GetRazed;
      if Structure.FPlayer = -1 then FFlagID := -1
      else FFlagID := AoWHSMap.FPlayers.GetPlayers(Structure.FPlayer).FPlayerRace;
    end
    else
    begin
      Structure := TPlayerStructure(AoWHSMap.MapContainer.GetMapLevel(CombatLLoc).
        GetField(CombatXLoc, CombatYLoc).FindNoneTransparentHS(TTower));
      if Structure <> nil then
      begin
        FWallType := 1;
        Razed := Structure.GetRazed;
        if Structure.FPlayer = -1 then FFlagID := -1
        else FFlagID := AoWHSMap.FPlayers.GetPlayers(Structure.FPlayer).FPlayerRace;
      end
      else FWallType := 0;
    end;
    if FWallType = 0 then
    begin
      RemoveFromMap;
      UpdateMapFields(AoWCombatMap.MapContainer.GetMapLevel(0), GetXhx, GetYhx);
      Free;
    end
    else
    begin
      if Razed then SetHitPoints(0)
      else SetHitPoints(WallMaxHP[FWallType - 1]);
      if FFlagID = -1 then FFlagID := 32;
      AoWCombatMap.FWalls.Add(Self);
    end;
  end
  else FWallType := 2;
end;

function TCityWall.GetDirection: Byte;
begin Result := TCityWallResource(FResource).FDirection; end;

function TCityWall.GetOverlay(Index: Integer): Shortint;
begin
  if Index = 0 then
    if FHitPoints = 0 then Result := 6
    else Result := 8
  else Result := inherited GetOverlay(Index);
end;

function TCityWall.ValidTerrainType(TerrainType: Integer): Boolean;
begin Result := True; end;

function TCityWall.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

procedure TCityWall.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  inherited UpdateMapField(Info);
  if Info.HN = 0 then
    TAoWMapField(Info.MapField).FFieldFlags :=
      TAoWMapField(Info.MapField).FFieldFlags or $4000 or $2000;
end;

procedure TCityWall.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if Info.HN = 0 then
  begin
    if FHitPoints = 0 then
      MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, 6]
    else if (mmaiWall in TCombatMoveControl(Info.Sender).FMoveFlags) then
    begin
      MoveResult.Code := 25;
      MoveResult.Done := True;
    end
    else if ((mmWallCrushing in TCombatMoveControl(Info.Sender).FMoveFlags)) and
      (GetXhx = TCombatMoveControl(Info.Sender).FDestinationX) and
      (GetYhx = TCombatMoveControl(Info.Sender).FDestinationY) then MoveResult.Code := 0
    else if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled(1) or
      TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($42) or
      TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($24) then
      MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, -1]
    else if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($3B) then
      MoveResult.Code := -1
    else MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, 8];
    MoveResult.Done := True;
  end;
end;

function TCityWall.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if Info.HN = 0 then
  begin
    if (FHitPoints = 0) or
      TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($42) or
      TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($24) or
      ((mmClimbing in TCombatMoveControl(Info.Sender).FMoveFlags)) or
      ((mmaiWall in TCombatMoveControl(Info.Sender).FMoveFlags)) then Result := 1
    else if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($3B) then Result := 0
    else if TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, 8] <> 0 then
      Result := 1
    else Result := 0;
  end
  else Result := 1;
end;

function TCityWall.GetDefense: Integer;
begin Result := -2; end;

procedure TCityWall.SetHitPoints(Value: Integer);
var
  Effect: TfxHS;
  Point: TXYZ;
begin
  if Value < 0 then Value := 0;
  if Value < FHitPoints then
    if Value = 0 then
    begin
      AoWCombatMap.FCombat.FCombatData.FWallBreached := True;
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
  if WallMaxHP[FWallType - 1] = FHitPoints then FDamageImage := 0
  else if WallMaxHP[FWallType - 1] div 2 < FHitPoints then FDamageImage := 1
  else if FHitPoints > 0 then FDamageImage := 2
  else FDamageImage := 3;
  FPlaySound := True;
end;

procedure TCityWall.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
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
        if FWallType = 1 then
        begin
          AoWHSSet.FAbilityControl.GetAbility($1f).GetCombatInfo(
            TCombatUnit(Msg.Param[0]).FUnit, AbilityInfo);
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(AbilityInfo.Damage, AbilityInfo.Attack - GetDefense));
        end;
      $3100b:
        if FWallType = 1 then
        begin
          AoWHSSet.FSpellControl.GetSpell($71).GetCombatInfo(
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
        if FWallType = 1 then
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
        if FWallType = 1 then
        begin
          RandSeed := AoWHSMap.Random($FFFFFF);
          SetHitPoints(FHitPoints - ExecuteDamageRole(TCDamage[1], TCAttack[1] - GetDefense));
        end;
    end;
end;

procedure TCityWall.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  ImageIndex: Integer;
  Xhp, Yhp: Integer;
  TerrainOffset: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  case AoWCombatMap.MapContainer.GetMapLevel(0).GetField(GetXhx, GetYhx).TerrainType of
    3: TerrainOffset := 10;
    5, 7, 12: TerrainOffset := 20;
  else TerrainOffset := 0;
  end;
  Sequence := FResource.ImageSequenceList.GetImageSequence(
    WallISIndex[FWallType - 1] + (TerrainOffset + FDamageImage));
  if Sequence <> nil then
    repeat
      case Sequence.Layer of
        7:
          begin
            ImageIndex := Sequence.GetFrameIndex(AoWCombatMap.Frame, (Integer(Self) shr 2) and $FFFF);
            if ImageIndex <> -1 then
              if not (msEditting in AoWCombatMap.Status) then
                AoWHSSet.FFlagControl.ShowFlagEx(
                  XhpSurf + 21 + Sequence.dXshift, YhpSurf + Sequence.dYshift + 16,
                  GetXhx + AoWHSMap.Frame + GetYhx * 100, FFlagID, SurfaceDesc, False);
          end;
      else
        begin
          ImageIndex := Sequence.GetUnloopedFrameIndex(FImageIndex);
          if ImageIndex <> -1 then
            Sequence.ImageLibrary[ImageIndex].Show(
              XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift, SurfaceDesc);
        end;
      end;
      Sequence := Sequence.Next;
    until Sequence = nil;
end;

procedure TCityWall.ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin end;

class function TCityWallResource.ClassID: Integer;
begin Result := $220505; end;

procedure TCityWallResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FDirection, 25);
end;

class function TCityWallResource.ResourceEditName: string;
begin Result := 'Combat City Wall'; end;

function TCityWallResource.ResourceUserClassID: Integer;
begin Result := $220504; end;

class function TCityWallDoor.ClassID: Integer;
begin Result := $220506; end;

procedure TCityWallDoor.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if Info.HN = 0 then
  begin
    if FHitPoints = 0 then
      MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, 6]
    else if (mmaiWall in TCombatMoveControl(Info.Sender).FMoveFlags) then
    begin
      MoveResult.Code := 25;
      MoveResult.Done := True;
    end
    else if ((mmWallCrushing in TCombatMoveControl(Info.Sender).FMoveFlags)) and
      (GetXhx = TCombatMoveControl(Info.Sender).FDestinationX) and
      (GetYhx = TCombatMoveControl(Info.Sender).FDestinationY) then MoveResult.Code := 0
    else if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled(1) or
      TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($42) or
      (TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetSide = csDefender) then
      MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, -1]
    else if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($3B) then
      MoveResult.Code := -1
    else MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, 8];
    MoveResult.Done := True;
  end;
end;

function TCityWallDoor.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if Info.HN = 0 then
  begin
    if (FHitPoints = 0) or
      (TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetSide = csDefender) or
      TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($42) or
      TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($24) or
      ((mmClimbing in TCombatMoveControl(Info.Sender).FMoveFlags)) or
      ((mmaiWall in TCombatMoveControl(Info.Sender).FMoveFlags)) then Result := 1
    else if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled($3B) then Result := 0
    else if TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, 8] <> 0 then
      Result := 1
    else Result := 0;
  end
  else Result := 1;
end;


function TCityWallDoor.GetOverlay(Index: Integer): Shortint;
begin Result := -1; end;

procedure TCityWallDoor.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  CombatUnit: TTacticalCombatUnitHS;
begin
  if (msEditting in AoWCombatMap.Status) or (AoWCombatMap.FCombat = nil) then
    inherited Show(XhpSurf, YhpSurf, SurfaceDesc)
  else
  begin
    CombatUnit := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.GetMapLevel(0).
      GetField(GetXhx, GetYhx).FindOwnedChild($220104));
    if CombatUnit <> nil then
      if CombatUnit.FUnit.GetSide <> csDefender then CombatUnit := nil;
    if (FHitPoints = 0) or
      ((AoWCombatMap.FCombat.FCombatData.FPlayers.GetPlayers(
        AoWCombatMap.FCombat.FCombatData.FPlayers.IndexOfPlayer(Byte(AoWCombatMap.FCurrentPlayer))).FSideIndex <> 1) and
      (CombatUnit = nil)) then
      inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
  end;
end;

class function TCityWallDoorResource.ClassID: Integer;
begin Result := $220507; end;

class function TCityWallDoorResource.ResourceEditName: string;
begin Result := 'Combat City Door'; end;

function TCityWallDoorResource.ResourceUserClassID: Integer;
begin Result := $220506; end;

procedure RegisterCityWall(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCityWall, TCityWallResource, TCityWallDoor, TCityWallDoorResource]);
end;

initialization
finalization

end.
