const
  P1EmptySelectionTypes: TAbilitySelectionTypes = [];

const
  P1EmptyMoveTypes: TMoveTypes = [];
  P1EmptyDamageTypes: TDamageTypes = [];
  P1EmptyWallFeatures: TWallCombatFeatures = [];
  P1EmptyControlType: TAbilityControlType = [];

type
  PP1Pointer = ^Pointer;
  PP1DamageValues = ^TP1DamageValues;
  TP1DamageValues = record
    Damage, CounterDamage, Experience, CounterExperience, Reserved: Integer;
  end;
  PP1CombatInfo = ^TP1CombatInfo;
  TP1CombatInfo = packed record
    Kind: Byte;
    Attack, Damage: Shortint;
    Types: TDamageTypes;
    RepeatCount: Shortint;
  end;
  TP1OwnerView = class(TEObject)
    function HasAbility(Index: Integer): Boolean; virtual; abstract;
    procedure SetAbility(Index: Integer; Value: Byte); virtual; abstract;
    procedure Slot54; virtual; abstract;
    procedure Slot58; virtual; abstract;
    procedure Slot5C; virtual; abstract;
    function OwnerName: string; virtual; abstract;
    procedure Slot64; virtual; abstract;
    procedure Slot68; virtual; abstract;
    procedure Slot6C; virtual; abstract;
    procedure Slot70; virtual; abstract;
    procedure Slot74; virtual; abstract;
    procedure Slot78; virtual; abstract;
    procedure Slot7C; virtual; abstract;
    procedure Slot80; virtual; abstract;
    procedure Slot84; virtual; abstract;
    procedure Slot88; virtual; abstract;
    function SelectionTypes: TAbilitySelectionTypes; virtual; abstract;
  end;
  TP1AbilityView = class(TEObject)
    procedure Execute; virtual; abstract;
    function GetHidden: Boolean; virtual; abstract;
    function GetAbilityType: TAbilityType; virtual; abstract;
    function GetName(Owner: TAbilityOwner): string; virtual; abstract;
    function GetAttack(Owner: TAbilityOwner): Shortint; virtual; abstract;
    function GetDefense(Owner: TAbilityOwner): Shortint; virtual; abstract;
    function GetResistance(Owner: TAbilityOwner): Shortint; virtual; abstract;
    function GetDamage(Owner: TAbilityOwner): Shortint; virtual; abstract;
    function GetMoveTypes(Owner: TAbilityOwner): TMoveTypes; virtual; abstract;
    function GetLevel(Owner: TAbilityOwner): Shortint; virtual; abstract;
    function GetEnabled(Owner: TAbilityOwner): Boolean; virtual; abstract;
    function GetImmunityTypes(Owner: TAbilityOwner): TDamageTypes; virtual; abstract;
    function GetProtectionTypes(Owner: TAbilityOwner): TDamageTypes; virtual; abstract;
    function GetSkillPoints(Owner: TAbilityOwner): Integer; virtual; abstract;
    function GetCombatMode(Owner: TAbilityOwner): TCombatMode; virtual; abstract;
    function GetWallCombatFeatures(Owner: TAbilityOwner): TWallCombatFeatures; virtual; abstract;
    function GetSourceName(Owner: TAbilityOwner): string; virtual; abstract;
    function GetInherent(Owner: TAbilityOwner): Boolean; virtual; abstract;
    function GetInherentLevel(Owner: TAbilityOwner): Shortint; virtual; abstract;
    function GetControlType(Owner: TAbilityOwner): TAbilityControlType; virtual; abstract;
    function fcValidRoundDistance(Source, Target: TCombatObject): Boolean; virtual; abstract;
    procedure fcPrefetchCombatCommands(Owner: TAbilityOwner); virtual; abstract;
    function fcExecuteCombatCommand(Owner: TAbilityOwner; Command: Pointer): Boolean; virtual; abstract;
    procedure NewDay(Owner: TAbilityOwner); virtual; abstract;
    procedure NewTurn(Owner: TAbilityOwner; Info: Pointer); virtual; abstract;
    function CanActivate(Owner: TAbilityOwner; var Reason: string): Boolean; virtual; abstract;
    function Activate(Owner: TAbilityOwner; var Reason: string): Boolean; virtual; abstract;
    function CanActivateCombat(Owner: TAbilityOwner; var Reason: string): Boolean; virtual; abstract;
    function ActivateCombat(Owner: TAbilityOwner; var Reason: string): Boolean; virtual; abstract;
    procedure ListSpells; virtual; abstract;
    function CanExpand(Owner: TAbilityOwner): Boolean; virtual; abstract;
    function ExpandCost: Integer; virtual; abstract;
    function ExpandName(Owner: TAbilityOwner): string; virtual; abstract;
    function Expand(Owner: TAbilityOwner): Boolean; virtual; abstract;
    function Remove(Owner: TAbilityOwner): Boolean; virtual; abstract;
    function GetDamageValue(Source, Target: TCombatObject): Integer; virtual; abstract;
    procedure GetDamageValueEx(Source, Target: TCombatObject; Defensive: Boolean; var Values: TP1DamageValues); virtual; abstract;
    procedure GetOffensiveStrength(Owner: TAbilityOwner; var Strength: Integer; var Types: TDamageTypes); virtual; abstract;
    procedure fcGetDamageValueEx(Source, Target: TCombatObject; Defensive: Boolean; var Values: TP1DamageValues); virtual; abstract;
    function fcGetDamageValue(Source, Target: TCombatObject; Defensive: Boolean): Integer; virtual; abstract;
    procedure tcGetDamageValueEx(Source, Target: TCombatObject; var Values: TP1DamageValues); virtual; abstract;
    function tcGetDamageValue(Source, Target: TCombatObject): Integer; virtual; abstract;
    procedure CombatObjectDestroyed(Obj: TCombatObject); virtual; abstract;
    procedure NewCombatTurn(Owner: TAbilityOwner; Info: Pointer); virtual; abstract;
    procedure CombatDone(Owner: TAbilityOwner); virtual; abstract;
    procedure ListInfo(Strings: TStrings; Mode: Byte); virtual; abstract;
    procedure GetCombatInfo(Owner: TAbilityOwner; var Info: TP1CombatInfo); virtual; abstract;
    function AbilityDataClass: TClass; virtual; abstract;
  end;
  { TAbility name-return ABI at VMT +$58; declarations in other packages remain unchanged. }
  TP1AbilityNameView = class(TEObject)
    procedure Execute; virtual; abstract;
    procedure GetHidden; virtual; abstract;
    procedure GetAbilityType; virtual; abstract;
    function GetName(Owner: Pointer): string; virtual; abstract;
  end;
  TP1AbilityKinds = set of 0..15;
  { ABI-only view of TUnitSelector: Boolean CanSelectUnit at VMT +$04. }
  TSelectorView = class(TObject)
    procedure SetSelection; virtual; abstract;
    function CanSelectUnit(Unit_: TUnit): Boolean; virtual; abstract;
  end;

resourcestring
  PlayerRStr = 'Player';
  IndependentsRStr = 'Independents';
  PlayerNameExRStr = '%0:s of the %1:s';

resourcestring
  GameOverDefeatMessageRStr = 'On day %0:s, the empire of the %1:s, led by %2:s was defeated.';
  GameOverVictoryMessageRStr = 'On day %0:s, the empire of the %1:s, led by %2:s was victorious.';
  XLeaderRStr = '%s leader';
  NotAllSpheresAssignedRStr = 'not all spheres assigned';
  NotPlacedOnMapRStr = 'not placed on map';
  NotAllSkillPointsAssignedRStr = 'not all skill points assigned';

resourcestring
  NoUnitSelectedRStr = 'No unit selected';

resourcestring
  WaterRStr = 'Water';
  GrassRStr = 'Grass';
  DesertRStr = 'Desert';
  SnowRStr = 'Snow';
  SteppeRStr = 'Steppe';
  WastelandRStr = 'Wasteland';
  IceRStr = 'Ice';
  EarthRStr = 'Earth';
  RockRStr = 'Rock';
  LavaRStr = 'Lava';
  ReservedRStr = 'Reserved';
  DirtRStr = 'Dirt';
  CoastRStr = 'Coast';
  BorderRStr = 'Border';
  MountainRStr = 'Mountain';
  DenseVegetationRStr = 'Dense Vegetation';
  HillRStr = 'Hill';
  VegetationRStr = 'Vegetation';
  RoadRStr = 'Road';
  BridgeRStr = 'Bridge';
  RubbleRStr = 'Rubble';
  StructureRStr = 'Structure';
  ObstacleRStr = 'Obstacle';
  LightVegetationRStr = 'Light Vegetation';
  SolidRStr = 'Solid';
  RocksRStr = 'Rocks';
  BonesRStr = 'Bones';
  DeadTreeRStr = 'Dead Tree';
  ToadstoolsRStr = 'Toadstools';
  LoadingGamePackRStr = 'Loading Game Pack';
  LoadingUnitsRStr = 'Loading Units';
  LoadingHeroesRStr = 'Loading Heroes';
  LoadingItemsRStr = 'Loading Items';
  GamePackLoadedRStr = 'Game Pack Loaded';

const
  DefaultRaceRelations: array[0..11, 0..11] of TStatus = (
    (sFriendly, sPolite, sPolite, sPolite, sNeutral, sNeutral, sNeutral, sPolite, sNeutral, sNeutral, sNeutral, sWary),
    (sPolite, sFriendly, sPolite, sNeutral, sNeutral, sNeutral, sNeutral, sWary, sNeutral, sNeutral, sNeutral, sWary),
    (sPolite, sPolite, sFriendly, sPolite, sNeutral, sNeutral, sNeutral, sWary, sNeutral, sNeutral, sNeutral, sWary),
    (sPolite, sNeutral, sPolite, sFriendly, sNeutral, sNeutral, sNeutral, sWary, sNeutral, sNeutral, sNeutral, sWary),
    (sNeutral, sNeutral, sNeutral, sNeutral, sFriendly, sFriendly, sPolite, sFriendly, sHostile, sHostile, sHostile, sHostile),
    (sNeutral, sNeutral, sNeutral, sNeutral, sFriendly, sFriendly, sFriendly, sPolite, sHostile, sHostile, sHostile, sHostile),
    (sNeutral, sNeutral, sNeutral, sNeutral, sPolite, sFriendly, sFriendly, sFriendly, sHostile, sHostile, sHostile, sHostile),
    (sPolite, sWary, sWary, sWary, sFriendly, sPolite, sFriendly, sFriendly, sHostile, sHostile, sHostile, sHostile),
    (sNeutral, sNeutral, sNeutral, sNeutral, sHostile, sHostile, sHostile, sHostile, sFriendly, sFriendly, sPolite, sPolite),
    (sNeutral, sNeutral, sNeutral, sNeutral, sHostile, sHostile, sHostile, sHostile, sFriendly, sFriendly, sFriendly, sPolite),
    (sNeutral, sNeutral, sNeutral, sNeutral, sHostile, sHostile, sHostile, sHostile, sPolite, sFriendly, sFriendly, sPolite),
    (sWary, sWary, sWary, sWary, sHostile, sHostile, sHostile, sHostile, sPolite, sPolite, sPolite, sFriendly));

type
  TP1DistanceCombatView = class(TObject)
    procedure DistanceSlot00; virtual; abstract;
    procedure DistanceSlot04; virtual; abstract;
    procedure DistanceSlot08; virtual; abstract;
    procedure DistanceSlot0C; virtual; abstract;
    procedure DistanceSlot10; virtual; abstract;
    procedure DistanceSlot14; virtual; abstract;
    procedure DistanceSlot18; virtual; abstract;
    procedure DistanceSlot1C; virtual; abstract;
    procedure DistanceSlot20; virtual; abstract;
    procedure DistanceSlot24; virtual; abstract;
    procedure DistanceSlot28; virtual; abstract;
    procedure DistanceSlot2C; virtual; abstract;
    procedure DistanceSlot30; virtual; abstract;
    procedure DistanceSlot34; virtual; abstract;
    procedure DistanceSlot38; virtual; abstract;
    procedure DistanceSlot3C; virtual; abstract;
    procedure DistanceSlot40; virtual; abstract;
    procedure DistanceSlot44; virtual; abstract;
    procedure DistanceSlot48; virtual; abstract;
    procedure DistanceSlot4C; virtual; abstract;
    procedure DistanceSlot50; virtual; abstract;
    procedure DistanceSlot54; virtual; abstract;
    procedure DistanceSlot58; virtual; abstract;
    procedure DistanceSlot5C; virtual; abstract;
    procedure DistanceSlot60; virtual; abstract;
    procedure DistanceSlot64; virtual; abstract;
    procedure DistanceSlot68; virtual; abstract;
    procedure DistanceSlot6C; virtual; abstract;
    procedure DistanceSlot70; virtual; abstract;
    procedure DistanceSlot74; virtual; abstract;
    procedure DistanceSlot78; virtual; abstract;
    procedure DistanceSlot7C; virtual; abstract;
    procedure DistanceSlot80; virtual; abstract;
    procedure DistanceSlot84; virtual; abstract;
    procedure DistanceSlot88; virtual; abstract;
    procedure DistanceSlot8C; virtual; abstract;
    procedure DistanceSlot90; virtual; abstract;
    function Speed: Integer; virtual; abstract;
    procedure DistanceSlot98; virtual; abstract;
    procedure DistanceSlot9C; virtual; abstract;
    procedure DistanceSlotA0; virtual; abstract;
    procedure DistanceSlotA4; virtual; abstract;
    procedure DistanceSlotA8; virtual; abstract;
    procedure DistanceSlotAC; virtual; abstract;
    procedure DistanceSlotB0; virtual; abstract;
    procedure DistanceSlotB4; virtual; abstract;
    procedure DistanceSlotB8; virtual; abstract;
    procedure DistanceSlotBC; virtual; abstract;
    procedure DistanceSlotC0; virtual; abstract;
    procedure DistanceSlotC4; virtual; abstract;
    procedure DistanceSlotC8; virtual; abstract;
    procedure DistanceSlotCC; virtual; abstract;
    procedure DistanceSlotD0; virtual; abstract;
    function LastRound: Integer; virtual; abstract;
  end;
  TP1FastRound = function(Combat: TFastCombat): Integer;

constructor TAoWHSSet.Create(AOwner: Engine.TECustomNode);
var
  Enabled: TBitList;
begin
  inherited Create(AOwner);
  FCombatResources := TMapObjectResourceList.Create(Self);
  FCombatResources.SetControlStyle([csSaveLoad, csFixedChild]);
  FCombatHexagons := THexagonControl.Create(Self);
  FCombatHexagons.MOClass := TAbstractHexagon;
  FCombatRoads := TRoadControl.Create(Self);
  FCombatRoads.MOClass := TAbstractRoad;
  ImageLibraryManager.ExecutePathSearch(AoWEngine.StartupDirectory + 'IMAGES');
  SFXManager.ExecutePathSearch(AoWEngine.StartupDirectory + 'SFX');
  FImageSequences := TImageSequenceList.Create(ImageLibraryManager, nil);
  TerrainTypes.Add(TranslateRStr(WaterRStr));
  TerrainTypes.Add(TranslateRStr(GrassRStr));
  TerrainTypes.Add(TranslateRStr(DesertRStr));
  TerrainTypes.Add(TranslateRStr(SnowRStr));
  TerrainTypes.Add(TranslateRStr(SteppeRStr));
  TerrainTypes.Add(TranslateRStr(WastelandRStr));
  TerrainTypes.Add(TranslateRStr(IceRStr));
  TerrainTypes.Add(TranslateRStr(EarthRStr));
  TerrainTypes.Add(TranslateRStr(RockRStr));
  TerrainTypes.Add(TranslateRStr(LavaRStr));
  TerrainTypes.Add(TranslateRStr(WaterRStr));
  TerrainTypes.Add(TranslateRStr(ReservedRStr));
  TerrainTypes.Add(TranslateRStr(DirtRStr));
  TerrainTypes.Add(TranslateRStr(IceRStr));
  TerrainTypes.Add(TranslateRStr(CoastRStr));
  TerrainTypes.Add(TranslateRStr(BorderRStr));
  OverlayTypes.Add(TranslateRStr(MountainRStr));
  OverlayTypes.Add(TranslateRStr(DenseVegetationRStr));
  OverlayTypes.Add(TranslateRStr(HillRStr));
  OverlayTypes.Add(TranslateRStr(VegetationRStr));
  OverlayTypes.Add(TranslateRStr(RoadRStr));
  OverlayTypes.Add(TranslateRStr(BridgeRStr));
  OverlayTypes.Add(TranslateRStr(RubbleRStr));
  OverlayTypes.Add(TranslateRStr(StructureRStr));
  OverlayTypes.Add(TranslateRStr(ObstacleRStr));
  OverlayTypes.Add(TranslateRStr(LightVegetationRStr));
  OverlayTypes.Add(TranslateRStr(SolidRStr));
  DecorationTypes.Add(TranslateRStr(NoneRStr));
  DecorationTypes.Add(TranslateRStr(RocksRStr));
  DecorationTypes.Add(TranslateRStr(BonesRStr));
  DecorationTypes.Add(TranslateRStr(DeadTreeRStr));
  DecorationTypes.Add(TranslateRStr(ToadstoolsRStr));
  FPadControl := TPadControl.Create(Self);
  Enabled := TBitList(FPadControl.F_PadControl_10);
  Enabled[1] := True;
  Enabled[2] := True;
  Enabled[3] := True;
  Enabled[4] := True;
  Enabled[5] := True;
  Enabled[6] := True;
  Enabled[12] := True;
  FRaceResources := TRaceResourceList.Create(Self);
  FFlagControl := TFlagControl.Create(Self);
  FFireControl := TFireControl.Create;
  FUnitResources := TUnitResourceList.Create(Self);
  FUnitGFXResources := TUnitGFXResourceList.Create(Self);
  FHeroResources := THeroResourceList.Create(Self);
  FItemGFXResources := TItemGFXList.Create(Self);
  FFaceResources := TFaceResourceList.Create(Self);
  FItemLibraries := TItemLibraryManager.Create(nil);
  FHeroLibraries := THeroLibraryManager.Create(nil);
  FAbilityControl := TAbilityControl.Create(nil);
  FSpellControl := TSpellControl.Create(nil);
  FTextControl := TTextControl.Create(nil);
  FGeneralImages := ImageLibraryManager.LinkToIL([icDisk], 'GENERAL.ILB');
  FCursorImages := ImageLibraryManager.LinkToIL([icDisk], 'CURSORS.ILB');
  FCombatImages := ImageLibraryManager.LinkToIL([icDisk], 'COMBAT.ILB');
end;

destructor TAoWHSSet.Destroy;
begin
  FFireControl.Free;
  FImageSequences.Free;
  FTextControl.Free;
  FAbilityControl.UnregisterAll;
  FSpellControl.UnregisterAll;
  FItemLibraries.Free;
  FHeroLibraries.Free;
  inherited Destroy;
  FAbilityControl.Free;
  FSpellControl.Free;
end;

class function TAoWHSSet.ClassID: Integer;
begin Result := $20010; end;

function TAoWHSSet.GetFileCRC(const FileName: string; AtEnd: Boolean): Integer;
var
  FileStream: TFileStream;
begin
  Result := 0;
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    if AtEnd then
    begin
      FileStream.Position := FileStream.Size - 4;
      FileStream.Read(Result, 4);
    end
    else FileStream.Read(Result, 4);
  finally
    FileStream.Free;
  end;
end;

function TAoWHSSet.RetrieveHSSCRC: Integer;
var
  CRCs: TIntegerList;
  Path: string;
begin
  CRCs := TIntegerList.Create;
  Path := ExtractFilePath(AoWEngine.HSSFileName);
  { Original includes ABILITY.PFS twice and does not free CRCs on a read error. }
  CRCs.Add(GetFileCRC(Path + 'ABILITY.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'ABILITY.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'UNITRES.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'UNITGFX.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'HERORES.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'ITEMGFX.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'FACERES.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'COMB_RES.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'SPELLS.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'RELEASE.HSS', True));
  Result := GetCRC32(CRCs.List, CRCs.Count * 4);
  CRCs.Free;
end;

procedure TAoWHSSet.ReadWrite(Stream: Engine.TEStorageStream);
var
  Path: string;
  Loaded: Boolean;
begin
  if smRead in Stream.StorageMode then
    Stream.ShowProgress(Self, TranslateRStr(LoadingGamePackRStr), 0);
  inherited ReadWrite(Stream);
  Stream.rwEObject(FRaceResources, $0A);
  Stream.rwEObject(FItemLibraries, $0B);
  if not (smTextOnly in Stream.StorageMode) then
  begin
    Path := ExtractFilePath(AoWEngine.HSSFileName);
    if smRead in Stream.StorageMode then
    begin
      Loaded := AoWEngine.ReadFromFileCRC(Path + 'ABILITY.PFS', FAbilityControl, nil);
      Stream.ShowProgress(Self, TranslateRStr(LoadingUnitsRStr), 70);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'UNITRES.PFS', FUnitResources, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'UNITGFX.PFS', FUnitGFXResources, nil);
      Stream.ShowProgress(Self, TranslateRStr(LoadingHeroesRStr), 80);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'HERORES.PFS', FHeroResources, nil);
      Stream.ShowProgress(Self, TranslateRStr(LoadingItemsRStr), 90);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'ITEMGFX.PFS', FItemGFXResources, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'FACERES.PFS', FFaceResources, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'COMB_RES.PFS', FCombatResources, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'SPELLS.PFS', FSpellControl, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'TEXT.PFS', FTextControl, nil);
      if not Loaded then raise Exception.Create('CRC-CHECK FAILED');
      Stream.ShowProgress(Self, TranslateRStr(GamePackLoadedRStr), 100);
    end
    else
    begin
      AoWEngine.WriteToFileCRC(Path + 'ABILITY.PFS', FAbilityControl, nil);
      AoWEngine.WriteToFileCRC(Path + 'UNITRES.PFS', FUnitResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'UNITGFX.PFS', FUnitGFXResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'HERORES.PFS', FHeroResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'ITEMGFX.PFS', FItemGFXResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'FACERES.PFS', FFaceResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'COMB_RES.PFS', FCombatResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'SPELLS.PFS', FSpellControl, nil);
      AoWEngine.WriteToFileCRC(Path + 'TEXT.PFS', FTextControl, nil);
    end;
  end
  else
  begin
    Stream.rwEObject(FUnitResources, $6F);
    Stream.rwEObject(FUnitGFXResources, $70);
    Stream.rwEObject(FHeroResources, $71);
    Stream.rwEObject(FItemGFXResources, $72);
    Stream.rwEObject(FFaceResources, $73);
    Stream.rwEObject(FSpellControl, $75);
    Stream.rwEObject(FAbilityControl, $76);
    Stream.rwEObject(FTextControl, $77);
  end;
  Stream.rwEObject(FHeroLibraries, $11);
  Stream.rwStreamProc($12, FImageSequences.LoadFromStream, FImageSequences.SaveToStream);
  if smRead in Stream.StorageMode then
  begin
    FImageSequences.LinkToIL;
    FHSSCRC := RetrieveHSSCRC;
  end;
end;

procedure TAoWHSSet.MainReadWrite(Stream: Engine.TEStorageStream);
var
  DictionaryFile: string;
begin
  inherited MainReadWrite(Stream);
  if Stream.StorageMode * [smRead, smTextOnly, smPreview] = [smRead] then
  begin
    DictionaryFile := AoWEngine.StartupDirectory + 'Dict\' + 'Release' + '.mld';
    { needs: P2 TranslateEObjectFromFile(Obj: TEObject; const FileName: string). }
    AoWEngine.TranslateEObjectFromFile(Integer(Self), Integer(Pointer(DictionaryFile)));
  end;
end;

procedure TAoWHSSet.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  FItemLibraries.MsgProc(Msg, Sender);
end;

constructor TRace.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPlayerRelations := TIntegerList.Create;
  FDefaultRelations := TByteList.Create;
  FRace := -1;
  FEnabled := False;
end;

destructor TRace.Destroy;
begin
  SetEnabled(False);
  FPlayerRelations.Free;
  FDefaultRelations.Free;
  inherited Destroy;
end;

function TRace.GetRelationValue(Race: Shortint): Integer;
var
  Player: Integer;
begin
  Player := AoWHSMap.FPlayers.RaceToPlayer(Race);
  if Player = -1 then Result := StatusToStatusValue(TStatus(FDefaultRelations[Race]))
  else Result := FPlayerRelations[Player - 1];
  Result := Result + TRaceList(Owner).FRelationOffset;
end;

function TRace.GetRelation(Race: Shortint): TStatus;
var
  Player: Integer;
begin
  Player := AoWHSMap.FPlayers.RaceToPlayer(Race);
  if Player = -1 then
    Result := StatusValueToStatus(StatusToStatusValue(TStatus(FDefaultRelations[Race])) + AoWHSMap.FRaces.FRelationOffset)
  else Result := StatusValueToStatus(FPlayerRelations[Player - 1] + AoWHSMap.FRaces.FRelationOffset);
end;

procedure TRace.SetPlayerRelationValue(Player: Shortint; Value: Integer);
begin
  if Player > 0 then
  begin
    { Original dereferences AoWHSMap before the nil check below. }
    FPlayerRelations[Player - 1] := Value - AoWHSMap.FRaces.FRelationOffset;
    if AoWHSMap <> nil then AoWHSMap.TriggerRelationsChanged;
  end;
end;

function TRace.GetPlayerRelationValue(Player: Shortint): Integer;
begin
  if Player > 0 then Result := FPlayerRelations[Player - 1] + AoWHSMap.FRaces.FRelationOffset
  else Result := 50;
end;

function TRace.GetPlayerRelation(Player: Shortint): TStatus;
begin
  if Player > 0 then Result := StatusValueToStatus(FPlayerRelations[Player - 1] + AoWHSMap.FRaces.FRelationOffset)
  else Result := sNeutral;
end;

procedure TRace.NewDay;
type
  TControlBits = set of 0..7;
var
  I, DefaultValue: Integer;
begin
  if AoWHSMap.FDay <> 1 then
  begin
    if AoWHSMap.FGlobalMagicControl.FActiveEnchantments * [getHatred, getHarmony] = [] then
      for I := 0 to FPlayerRelations.Count - 1 do
      begin
        DefaultValue := StatusToStatusValue(TStatus(FDefaultRelations[AoWHSMap.FPlayers.GetPlayers(I + 1).FPlayerRace]));
        if FPlayerRelations[I] > DefaultValue then
        begin
          FPlayerRelations[I] := FPlayerRelations[I] - 1;
          if FPlayerRelations[I] < DefaultValue then FPlayerRelations[I] := DefaultValue;
        end;
        if FPlayerRelations[I] < DefaultValue then
        begin
          FPlayerRelations[I] := FPlayerRelations[I] + 1;
          if FPlayerRelations[I] > DefaultValue then FPlayerRelations[I] := DefaultValue;
        end;
      end;
  end
  else ResetPlayerRelations;
end;

function TRace.GetDefaultRaceRelation(Race: Shortint): TStatus;
begin
  if (Race >= 0) and (Race < FDefaultRelations.Count) then
    Result := TStatus(FDefaultRelations[Race])
  else Result := sNeutral;
end;

class function TRace.ClassID: Integer;
begin Result := $20202; end;

procedure TRace.ResetDefaultRaceRelations;
var
  I: Integer;
begin
  FDefaultRelations.Clear;
  if (Smallint(FRace) >= 0) and (Smallint(FRace) <= 11) then
    for I := 0 to 11 do FDefaultRelations.Add(Ord(DefaultRaceRelations[FRace, I]));
end;

procedure TRace.ResetPlayerRelations;
var
  I: Integer;
begin
  FPlayerRelations.Clear;
  for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
    FPlayerRelations.Add(StatusToStatusValue(TStatus(FDefaultRelations[AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace])));
end;

procedure TRace.SetRace(Value: Shortint);
begin
  FRace := Value;
  ResetDefaultRaceRelations;
end;

procedure TRace.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
    if AoWHSSet.FRaceResources.GetRaceResource(FRace) <> nil then
    begin
      if Value then AoWHSSet.FRaceResources.GetRaceResource(FRace).AddRef
      else AoWHSSet.FRaceResources.GetRaceResource(FRace).Release;
      FEnabled := Value;
    end;
end;

procedure TRace.ReadWrite(Stream: Engine.TEStorageStream);
var
  Enabled: Boolean;
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FRace), 2);
  Stream.rwStreamProc(3, FPlayerRelations.LoadFromStream, FPlayerRelations.SaveToStream);
  if Stream.StorageMode * [smRead, smTextOnly, smCompare] = [smRead] then
  begin
    { Original leaves this local uninitialized if property 4 is absent. }
    Stream.rwBool(Enabled, 4);
    SetEnabled(Enabled);
  end
  else Stream.rwBool(FEnabled, 4);
  Stream.rwStreamProc(5, FDefaultRelations.LoadFromStream, FDefaultRelations.SaveToStream);
  if (smRead in Stream.StorageMode) and (FDefaultRelations.Count = 0) then ResetDefaultRaceRelations;
end;

procedure TRace.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020001 then NewDay;
end;

constructor TRaceList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

procedure TRaceList.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FRelationOffset, 20);
end;

function TRaceList.GetRace(Index: Integer): TRace;
begin
  if (Index >= 0) and (Index < FChildren.Count) then Result := TRace(FChildren.List^[Index])
  else Result := nil;
end;

function TRaceList.GetEnabledRaces: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FChildren.Count - 1 do
    if (FChildren.List^[I] <> nil) and TRace(FChildren.List^[I]).FEnabled then Inc(Result);
end;

function TRaceList.GetRandomRace: Shortint;
var
  I: Integer;
  Races: TList;
begin
  Races := TList.Create;
  for I := 0 to FChildren.Count - 1 do
    if (FChildren.List^[I] <> nil) and TRace(FChildren.List^[I]).FEnabled then Races.Add(FChildren.List^[I]);
  if Races.Count <> 0 then Result := TRace(Races.List^[Random(Races.Count)]).FRace
  else Result := -1;
  Races.Free;
end;

procedure TRaceList.ResetPlayerRelations;
var
  I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    if FChildren.List^[I] <> nil then TRace(FChildren.List^[I]).ResetPlayerRelations;
end;

procedure TRaceList.ResetDefaultRelations;
var
  I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    if FChildren.List^[I] <> nil then TRace(FChildren.List^[I]).ResetDefaultRaceRelations;
end;

procedure TRaceList.Update;
var
  I: Integer;
  Race: TRace;
begin
  for I := 0 to AoWHSSet.FRaceResources.GetCount - 1 do
    if AoWHSSet.FRaceResources.GetRaceResource(I) <> nil then
    begin
      if GetRace(I) = nil then
      begin
        Race := TRace.Create(nil);
        Race.FRace := I;
        Race.SetArrayOwner(Self, I);
        Race.SetEnabled(True);
      end;
    end
    else GetRace(I).Free;
end;

class function TFaceResource.ClassID: Integer;
begin Result := $20270; end;

function TFaceResource.GetEngine: Engine.TEngine;
begin Result := AoWEngine; end;

function TFaceResource.FaceResourceIndex: Integer;
begin Result := Owner.FindChildIndex(Self); end;

procedure TFaceResource.LinkToIL;
begin
  ReleaseIL;
  if FImageLibraryName <> '' then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName)
  else FImageLibrary := nil;
end;

procedure TFaceResource.ReleaseIL;
begin
  if FImageLibrary <> nil then
  begin
    if FImageLibraryName <> '' then
      AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
end;

procedure TFaceResource.SetImageLibraryName(Value: string);
begin
  if FImageLibraryName <> '' then
  begin
    { Original releases the old name even when this resource has no references. }
    AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
  FImageLibraryName := Value;
  if (FImageLibraryName <> '') and (FReferences <> 0) then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName);
end;

function TFaceResource.AddRef: Integer;
begin
  if FReferences = 0 then LinkToIL;
  Inc(FReferences);
  Result := FReferences;
end;

function TFaceResource.Release: Integer;
begin
  Dec(FReferences);
  if FReferences = 0 then ReleaseIL;
  Result := FReferences;
end;

function TFaceResource.GetCellImage: ImageLib.TLibraryImage;
begin
  AddRef;
  Result := FImageLibrary[FImageIndex];
  Release;
end;

function TFaceResource.GetFaceImage: TLibraryImage;
var
  Images: TCustomImageLibrary;
begin
  Images := FImageLibrary;
  if Images <> nil then Result := Images[FImageIndex]
  else Result := nil;
end;

procedure TFaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FImageLibraryName, 5);
  Stream.rwInteger(FImageIndex, 6);
  Stream.rwBool(FDeveloperOnly, 7);
end;

constructor TFaceResourceList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

function TFaceResourceList.IndexOfFaceImage(Image: TLibraryImage): Integer;
var
  Face: TFaceResource;
begin
  Result := GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    Face := TFaceResource(FChildren.List^[Result]);
    if (Face <> nil) and (Face.GetFaceImage = Image) then Exit;
  end;
  Result := -1;
end;

function TFaceResourceList.GetFaceResource(Index: Integer): TFaceResource;
begin
  if (Index < FChildren.Count) and (Index >= 0) then
    Result := TFaceResource(FChildren.List^[Index])
  else Result := nil;
end;

function TFaceResourceList.PrevFace(Index: Integer): Integer;
var
  Developer: Boolean;
begin
  Result := Index;
  Developer := TAoWRegistry(AoWEngine.FRegistry).GetDeveloper;
  { Original assumes the list contains a selectable face. }
  repeat
    Dec(Result);
    if Result < 0 then Result := FChildren.Count - 1;
  until (FChildren.List^[Result] <> nil) and
    (Developer or not TFaceResource(FChildren.List^[Result]).FDeveloperOnly);
end;

function TFaceResourceList.NextFace(Index: Integer): Integer;
var
  Developer: Boolean;
begin
  Result := Index;
  Developer := TAoWRegistry(AoWEngine.FRegistry).GetDeveloper;
  { Original assumes the list contains a selectable face. }
  repeat
    Inc(Result);
    if Result >= FChildren.Count then Result := 0;
  until (FChildren.List^[Result] <> nil) and
    (Developer or not TFaceResource(FChildren.List^[Result]).FDeveloperOnly);
end;

constructor TUnitSelector.Create;
begin
  inherited Create;
  FUnits := TUnitUserList.Create(nil);
  FReferences := 1;
  FCanceled := False;
end;

destructor TUnitSelector.Destroy;
begin
  FUnits.Free;
  inherited Destroy;
end;

function TUnitSelector.AddRef: Integer;
begin
  Inc(FReferences);
  Result := FReferences;
end;

function TUnitSelector.Release: Integer;
var
  Count: Integer;
begin
  Dec(FReferences);
  Count := FReferences;
  Result := Count;
  if Count = 0 then Destroy;
end;

procedure TUnitSelector.SetSelection(Value: Byte);
begin
  FSelection := Value and FSelectable;
end;

function TUnitSelector.GetSelectionCount: Integer;
var
  Bits: Cardinal;
begin
  Result := 0;
  Bits := Byte(FSelection);
  while Bits <> 0 do
  begin
    if Bits and 1 <> 0 then Inc(Result);
    Bits := Bits shr 1;
  end;
end;

function TUnitSelector.CanSelect(var Error: string): Boolean;
begin
  if FSelection = 0 then
  begin
    Error := TranslateRStr(NoUnitSelectedRStr);
    Result := False;
  end
  else Result := True;
end;

procedure TUnitSelector.Select;
asm
  { needs: function Select: Boolean; P4 has unmarked procedure overrides. }
  PUSH EBX
  PUSH ESI
  MOV BL, 1
  CMP WORD PTR [EAX+$1E], 0
  JE @@Done
  MOV ESI, EAX
  MOV EDX, EAX
  MOV EAX, [ESI+$20]
  CALL DWORD PTR [ESI+$1C]
@@Done:
  MOV EAX, EBX
  POP ESI
  POP EBX
end;

procedure TUnitSelector.Cancel;
begin
  if Assigned(FOnCancel) then FOnCancel(Self);
end;

procedure TUnitSelector.CanSelectUnit(A1: Integer);
asm
  { needs: function CanSelectUnit(Unit: TUnit): Boolean; unmarked P4 overrides. }
  MOV AL, 1
end;

procedure TUnitSelector.Setup(Source: Pointer; Units: TUnitList);
type
  PSourceInfo = ^TSourceInfo;
  TSourceInfo = record
    Reserved00: array[0..$17] of Byte;
    Source: Pointer;
    Reserved1C: array[$1C..$23] of Byte;
    Player: Shortint;
  end;
var
  I: Integer;
begin
  if Source <> nil then
  begin
    FSource := PSourceInfo(Source).Source;
    FPlayer := PSourceInfo(Source).Player;
  end;
  FUnits.Clear;
  FUnits.AddUnits(Units);
  FUnits.SortUnits;
  { Original accumulates FSelectable rather than clearing it on a new setup. }
  for I := FUnits.GetCount - 1 downto 0 do
  begin
    Source := Pointer(FUnits.GetUnit(I));
    if TSelectorView(Self).CanSelectUnit(TUnit(Source)) then FSelectable := FSelectable or (Byte(1) shl I);
  end;
end;

constructor TUnitSelectorAAI.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitSelector := nil;
end;

destructor TUnitSelectorAAI.Destroy;
var
  Selector: TUnitSelector;
begin
  Selector := FUnitSelector;
  if Selector <> nil then
  begin
    Selector.Release;
    FUnitSelector := nil;
  end;
  inherited Destroy;
end;

procedure TUnitSelectorAAI.SetUnitSelector(Value: TUnitSelector);
var
  Old: TUnitSelector;
begin
  Old := FUnitSelector;
  if Old <> Value then
  begin
    if Old <> nil then Old.Release;
    Old := Value;
    FUnitSelector := Old;
    if Old <> nil then Old.AddRef;
  end;
end;

destructor TUnitCategoryList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TUnitCategoryList.GetCategory(Index: Integer): TUnitIndexList;
begin
  if (Index >= 0) and (Index < Count) then
    Result := TUnitIndexList(Items[Index])
  else Result := nil;
end;

procedure TUnitCategoryList.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if List^[I] <> nil then TUnitIndexList(List^[I]).Free;
  inherited Clear;
end;

procedure TUnitCategoryList.SortUnits;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if List^[I] <> nil then TUnitIndexList(List^[I]).SortUnits;
end;

procedure TUnitCategoryList.AddUnit(Category, UnitIndex: Integer);
begin
  while Category >= Count do Add(nil);
  { Original does not reject negative category indexes. }
  if List^[Category] = nil then
      List^[Category] := TUnitIndexList.Create;
  if TUnitIndexList(List^[Category]).IndexOf(UnitIndex) = -1 then
    TUnitIndexList(List^[Category]).Add(UnitIndex);
end;

constructor TUnitSelectionControl.Create;
begin
  inherited Create;
  FRacesEnabled := TBitList.Create;
  with FRacesEnabled do Default := True;
  FTypesEnabled := TBitList.Create;
  with FTypesEnabled do Default := True;
  FRaceUnits := TUnitCategoryList.Create;
  FTypeUnits := TUnitCategoryList.Create;
  FAllUnits := TUnitIndexList.Create;
  Reset;
end;

destructor TUnitSelectionControl.Destroy;
begin
  Clear;
  FRacesEnabled.Free;
  FTypesEnabled.Free;
  FRaceUnits.Free;
  FTypeUnits.Free;
  FAllUnits.Free;
  inherited Destroy;
end;

procedure TUnitSelectionControl.SetSelectedUnitIndex(Value: Integer);
var
  Resource: TUnitResource;
begin
  if AoWHSSet <> nil then
  begin
      Resource := AoWHSSet.FUnitResources.GetUnitResource(Value);
    if Resource <> nil then
      FSelectedUnitIndex := Value
    else FSelectedUnitIndex := -1;
    FSelectedHero := nil;
  end;
end;

procedure TUnitSelectionControl.SetSelectedHero(Value: THero);
begin
  FSelectedHero := Value;
  FSelectedUnitIndex := -1;
end;

function TUnitSelectionControl.GetUnitCategoryList(Category: Shortint): TUnitIndexList;
begin
  if Category >= 0 then Result := FRaceUnits.GetCategory(Category)
  else if Category = -16 then Result := FAllUnits
  else Result := FTypeUnits.GetCategory(Shortint(Abs(Category)) - 1);
end;

function TUnitSelectionControl.GetUnitCategoryEnabled(Category: Shortint): Boolean;
begin
  if Category >= 0 then Result := FRacesEnabled[Category]
  else Result := FTypesEnabled[Shortint(Abs(Category)) - 1];
end;

procedure TUnitSelectionControl.SetUnitCategoryEnabled(Category: Shortint; Value: Boolean);
begin
  if Category >= 0 then FRacesEnabled[Category] := Value
  else FTypesEnabled[Shortint(Abs(Category)) - 1] := Value;
end;

procedure TUnitSelectionControl.Reset;
var
  I: Integer;
begin
  FAlignments := alsAll;
  FMinimumLevel := 0;
  FMaximumLevel := 255;
  FRacesEnabled.Clear;
  FTypesEnabled.Clear;
  FAllUnits.Clear;
  FSelectedUnitIndex := -1;
  FSelectedHero := nil;
  FShowRaceCategories := True;
  FShowAllCategory := False;
  FShowTypeCategories := True;
  if AoWHSMap <> nil then
    for I := 0 to AoWHSMap.FRaces.GetCount - 1 do
      if AoWHSMap.FRaces.GetRace(I) <> nil then
        FRacesEnabled[I] := AoWHSMap.FRaces.GetRace(I).FEnabled;
end;

procedure TUnitSelectionControl.DisableAllCategories;
var
  I: Integer;
begin
  for I := 0 to AoWHSSet.FRaceResources.GetCount - 1 do FRacesEnabled[I] := False;
  for I := 0 to FTypesEnabled.Count - 1 do FTypesEnabled[I] := False;
end;

procedure TUnitSelectionControl.UpdateSelection;
var
  Index: Integer;
  Resources: TUnitResourceList;
  I, J: Integer;
  Resource: TUnitResource;
  UnitType_: TUnitType;
begin
  FRaceUnits.Clear;
  FTypeUnits.Clear;
  FAllUnits.Clear;
  Resources := AoWHSSet.FUnitResources;
  { Original intersects FAlignments with itself, ignoring the unit alignment. }
  if FShowAllCategory then
    for I := 0 to Resources.GetCount - 1 do
      if Resources.GetUnitResource(I) <> nil then
      begin
        Resource := Resources.GetUnitResource(I);
        if (Smallint(Shortint(Resource.FLevel)) >= Smallint(FMinimumLevel)) and
          (Smallint(Shortint(Resource.FLevel)) <= Smallint(FMaximumLevel)) and
          (FAlignments * FAlignments <> []) then FAllUnits.Add(I);
      end;
  if FShowTypeCategories then
    for I := 0 to Resources.GetCount - 1 do
      if Resources.GetUnitResource(I) <> nil then
      begin
        Resource := Resources.GetUnitResource(I);
        if (Smallint(Shortint(Resource.FLevel)) >= Smallint(FMinimumLevel)) and
          (Smallint(Shortint(Resource.FLevel)) <= Smallint(FMaximumLevel)) and
          (FAlignments * FAlignments <> []) then FTypeUnits.AddUnit(Integer(Resource.FUnitType), I);
      end;
  if FShowRaceCategories then
    { Original bounds this race loop by the unit-resource count. }
    for I := 0 to Resources.GetCount - 1 do
      if FRacesEnabled[I] and (AoWHSSet.FRaceResources.GetRaceResource(I) <> nil) then
        for J := 0 to AoWHSSet.FRaceResources.GetRaceResource(I).FUnitIndexes.Count - 1 do
        begin
          Index := AoWHSSet.FRaceResources.GetRaceResource(I).FUnitIndexes[J];
          if Index <> -1 then
          begin
            Resource := Resources.GetUnitResource(Index);
            if (Smallint(Shortint(Resource.FLevel)) >= Smallint(FMinimumLevel)) and
              (Smallint(Shortint(Resource.FLevel)) <= Smallint(FMaximumLevel)) and
              (FAlignments * FAlignments <> []) then FRaceUnits.AddUnit(I, Index);
          end;
        end;
  FTypeUnits.SortUnits;
  FRaceUnits.SortUnits;
  FAllUnits.SortUnits;
  Clear;
  if FShowAllCategory and ((FAllUnits.Count <> 0) or FShowEmptyCategories) then
    AddObject('All', TObject(-16));
  if FShowTypeCategories then
    for UnitType_ := Low(TUnitType) to High(TUnitType) do
      if FTypesEnabled[Ord(UnitType_)] and
        (FTypeUnits.GetCategory(Ord(UnitType_)) <> nil) and
        ((FTypeUnits.GetCategory(Ord(UnitType_)).Count <> 0) or FShowEmptyCategories) then
        AddObject(TranslateRStr(UnitTypePluralRStr[UnitType_]), TObject(-(Ord(UnitType_) + 1)));
  if FShowRaceCategories then
    for I := 0 to AoWHSSet.FRaceResources.GetCount - 1 do
      if FRacesEnabled[I] and (FRaceUnits.GetCategory(I) <> nil) and
        ((FRaceUnits.GetCategory(I).Count <> 0) or FShowEmptyCategories) then
        AddObject(AoWHSSet.FRaceResources.GetRaceResource(I).FRaceName, TObject(I));
end;

constructor TActivateAbilityInfo.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FReferences := 1;
end;

function TActivateAbilityInfo.AddRef: Integer;
begin
  Inc(FReferences);
  Result := FReferences;
end;

function TActivateAbilityInfo.Release: Integer;
var
  Count: Integer;
begin
  Dec(FReferences);
  Count := FReferences;
  Result := Count;
  if Count = 0 then Destroy;
end;

destructor TCustomAbilityList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TCustomAbilityList.Clear;
begin
  inherited Clear;
  SetAbCount(0);
end;

procedure TCustomAbilityList.SetAbSet(Index: Integer; Value: Byte);
asm
  CMP EDX,[EAX].FAbilityCount
  JAE @@grow
@@set:
  MOV EAX,[EAX].FAbilityBits
  OR CL,CL
  JZ @@clear
  BTS [EAX],EDX
  RET
@@clear:
  BTR [EAX],EDX
  RET
@@grow:
  PUSH EAX
  PUSH EDX
  PUSH ECX
  INC EDX
  CALL TCustomAbilityList.SetAbCount
  POP ECX
  POP EDX
  POP EAX
  JMP @@set
end;

function TCustomAbilityList.GetAbSet(A1: Integer): Boolean;
{ needs: Boolean result; P2 has an unmarked procedure override. }
asm
  CMP EDX,[EAX].FAbilityCount
  JAE @@none
  MOV EAX,[EAX].FAbilityBits
  BT [EAX],EDX
  SBB EAX,EAX
  AND EAX,1
  RET
@@none:
  MOV AL,0
  AND EAX,1
end;

procedure TCustomAbilityList.SetAbCount(Value: Integer);
var
  OldSize, NewSize: Integer;
begin
  { Original assertion accepts every Integer: its bounds predicate uses OR. }
  Assert(not ((Value < 0) and (Value >= $07FFFFFF)), 'Invalid AbCount Value (TArrayList)');
  OldSize := (FAbilityCount + 7) shr 3;
  NewSize := (Value + 7) shr 3;
  if OldSize <> NewSize then
  begin
    ReallocMem(FAbilityBits, NewSize);
    if OldSize < NewSize then
      FillChar(Pointer(Integer(FAbilityBits) + OldSize)^, NewSize - OldSize, 0);
  end;
  FAbilityCount := Value;
end;

function TCustomAbilityList.GetAbCount: Integer;
begin
  Result := FAbilityCount;
end;

procedure TCustomAbilityList.AssignAb(Source: TCustomAbilityList);
var
  Count, I: Integer;
begin
  if Source.GetAbCount > GetAbCount then Count := Source.GetAbCount
  else Count := GetAbCount;
  for I := 0 to Count - 1 do
    if Source.GetAbSet(I) <> GetAbSet(I) then
      SetAbSet(I, Ord(Source.GetAbSet(I)));
end;

function TCustomAbilityList.CompareAb(Source: TCustomAbilityList): Boolean;
begin
  Result := Source.GetAbCount = FAbilityCount;
  if Result then Result := CompareMem(FAbilityBits, Source.FAbilityBits, (GetAbCount + 7) shr 3);
end;

function TCustomAbilityList.ComposeAb(Source: TCustomAbilityList): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Source.GetAbCount - 1 do
    if Source.GetAbSet(I) and not GetAbSet(I) then
    begin
      SetAbSet(I, 1);
      Result := True;
    end;
end;

procedure TCustomAbilityList.ReadWrite(Stream: Engine.TEStorageStream);
var
  I: Integer;
begin
  if Stream.StorageMode * [smTextOnly, smCompare] = [] then
  begin
    if smRead in Stream.StorageMode then
    begin
      Stream.rwInteger(I, 2);
      SetAbCount(I);
      Stream.rwData(FAbilityBits^, (FAbilityCount + 7) shr 3, 3);
    end
    else
    begin
      Stream.rwInteger(FAbilityCount, 2);
      Stream.rwData(FAbilityBits^, (FAbilityCount + 7) shr 3, 3);
    end;
  end;
  if not (smPreview in Stream.StorageMode) then
    for I := 0 to FAbilityCount - 1 do
      if GetAbSet(I) and (AoWHSSet.FAbilityControl.GetAbility(I) = nil) then
        SetAbSet(I, 0);
end;

function TCustomAbilityList.GetItemString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FAbilityCount - 1 do
    if GetAbSet(I) then Result := Result + IntToStr(I) + ',';
  if Result <> '' then Result := System.Copy(Result, 1, Length(Result) - 1);
end;

procedure TCustomAbilityList.SetItemString(S: string);
var
  Part: string;
  P: Integer;
begin
  Clear;
  P := Pos(',', S);
  while S <> '' do
  begin
    if P <> 0 then
    begin
      Part := System.Copy(S, 1, P - 1);
      Delete(S, 1, P);
    end
    else
    begin
      Part := S;
      S := '';
    end;
    if Part <> '' then SetAbSet(StrToInt(Part), 1);
    P := Pos(',', S);
  end;
end;

procedure TCustomAbilityList.ListAbilitiesEx(A1: TStrings; A2: TAbilitySelectionTypes);
var
  I: Integer;
  Ability: TAbility;
begin
  TStrings(A1).Clear;
  for I := 0 to FAbilityCount - 1 do
    if GetAbSet(I) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(I);
      if TP1AbilityKinds(Ability.FSelectionTypes) * TP1AbilityKinds(A2) <> [] then
        { needs: TAbility.GetName(Owner): string; unmarked overrides stay untouched. }
        TStrings(A1).AddObject(Ability.GetName(nil), TObject(I));
    end;
end;

function TAbilityData.GetAbilityID: Integer;
{ needs: Integer result; unmarked overrides retain the draft procedure ABI. }
asm
  OR EAX,-1
end;

procedure TAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
end;

constructor TAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDescription := TStringList.Create;
  FSFXLibrary := TSFXLibrary.Create(nil);
  FImageSequences := TImageSequenceList.Create(AoWHSSet.ImageLibraryManager, nil);
end;

destructor TAbility.Destroy;
begin
  FDescription.Free;
  FSFXLibrary.Free;
  FImageSequences.Free;
  inherited Destroy;
end;

procedure TAbility.ShowInfo(Owner: TAbilityOwner; Font: TImageLibraryFont; X, Y: Integer; const Surface: TSurfaceDesc);
begin
  Font.SetText(X, Y, Self.GetName(Owner), Surface);
end;

function TAbility.GetSourceName(A1: TAbilityOwner): string;
begin
  Result := A1.GetOwnerName;
end;

procedure TAbility.SetAb(Owner: TAbilityOwner; Index: Integer; Value: Byte);
begin
  Owner.SetAbSet(Index, Value);
end;

function TAbility.GetControlType: TAbilityControlType;
{ needs: set result; preserve existing procedure-header return ABI. }
asm
  MOV AL,P1EmptyControlType
end;

function TAbility.GetCombatMode(A1: TAbilityOwner): TCombatMode;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

function TAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

procedure TAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues);
begin
  with PP1DamageValues(@A4)^ do
  begin
    Damage := 0;
    Experience := 0;
    CounterDamage := 0;
    CounterExperience := 0;
    { Original leaves Reserved untouched. }
  end;
end;

procedure TAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues);
begin
  with PP1DamageValues(@A4)^ do
  begin
    Damage := 0;
    Experience := 0;
    CounterDamage := 0;
    CounterExperience := 0;
    { Original leaves Reserved untouched. }
  end;
end;

function TAbility.fcValidRoundDistance(A1, A2: TCombatObject): Boolean;
var
  Distance: Integer;
  Value: Boolean;
begin
  { needs: Boolean result; P4 has an unmarked procedure override. }
  { needs: P5 GetRoundDistance: Integer; P3 Speed/LastRound result signatures. }
  Distance := TP1FastRound(@TFastCombat.GetRoundDistance)(TFastCombat(TCombatObject(A1).FCombat));
  if TP1DistanceCombatView(A1).Speed >= 32 then Inc(Distance, 2);
  Value := Distance >= TP1DistanceCombatView(A2).LastRound;
  if Value and (TCombatObject(A1) is TCombatUnit) and
    (TObject(TCombatUnit(A1).FUnit) is THero) then
    Value := Value and (((Byte(TCombatObject(A1).FStatus) and $10) <> 0) or
      (TP1DistanceCombatView(A1).LastRound <=
       TP1FastRound(@TFastCombat.GetRoundDistance)(TFastCombat(TCombatObject(A1).FCombat)) + 2));
  asm MOV AL,Value end;
end;

function TAbility.fcGetDamageValue(Source, Target: TCombatObject; Defensive: Boolean): Integer;
var
  Values: TP1DamageValues;
begin
  TP1AbilityView(Self).fcGetDamageValueEx(Source, Target, Defensive, Values);
  Result := Values.Damage;
end;

procedure TAbility.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  TP1AbilityView(Self).fcGetDamageValueEx(A1, A2, False, TP1DamageValues(A3));
end;

function TAbility.tcGetDamageValue(Source, Target: TCombatObject): Integer;
var
  Values: TP1DamageValues;
begin
  TP1AbilityView(Self).tcGetDamageValueEx(Source, Target, Values);
  Result := Values.Damage;
end;

procedure TAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  with PP1CombatInfo(@A2)^ do
  begin
    Attack := -1;
    Damage := -1;
    Types := [];
    RepeatCount := -1;
  end;
end;

function TAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
{ needs: set result; preserve existing procedure-header return ABI. }
asm
  MOV AL,P1EmptyWallFeatures
end;

function TAbility.CanExpand(A1: TAbilityOwner): Boolean;
{ needs: Boolean result; preserve unmarked P4 procedure overrides. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI,EDX
  MOV EBX,EAX
  MOV EDX,[EBX].FAbilityID
  MOV EAX,ESI
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
  TEST AL,AL
  JNZ @@none
  MOV EAX,ESI
  MOV EDX,[EAX]
  CALL DWORD PTR [EDX+$8C]
  AND AX,[EBX].FSelectionTypes
  MOV DX,P1EmptySelectionTypes
  CMP DX,AX
  JNZ @@yes
@@none:
  XOR EAX,EAX
  POP ESI
  POP EBX
  RET
@@yes:
  MOV AL,1
  POP ESI
  POP EBX
end;

procedure TAbility.ExpandName(A1: Integer; A2: Integer);
begin
  PString(A2)^ := FAbilityName;
end;

procedure TAbility.ExpandCost;
asm
  MOV EAX,[EAX].FSkillPointCost
end;

function TAbility.Expand(A1: TAbilityOwner): Boolean;
begin
  A1.SetAbSet(FAbilityID, 1);
  Result := True;
end;

function TAbility.Remove(A1: TAbilityOwner): Boolean;
{ needs: Boolean result; preserve unmarked P4 procedure overrides. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI,EDX
  MOV EBX,EAX
  MOV EDX,[EBX].FAbilityID
  MOV EAX,ESI
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
  TEST AL,AL
  JZ @@none
  XOR ECX,ECX
  MOV EDX,[EBX].FAbilityID
  MOV EAX,ESI
  MOV EBX,[EAX]
  CALL DWORD PTR [EBX+$50]
  MOV AL,1
  POP ESI
  POP EBX
  RET
@@none:
  XOR EAX,EAX
  POP ESI
  POP EBX
end;

function TAbility.GetInherent(A1: TAbilityOwner): Boolean;
asm
  MOV EAX,[EAX].FAbilityID
  XCHG EDX,EAX
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
end;

procedure TAbility.GetInherentLevel(A1: Integer);
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

procedure TAbility.GetSkillPoints(A1: Integer);
{ needs: Integer result; preserve the unmarked P4 override's procedure header. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI,EDX
  MOV EBX,EAX
  MOV EDX,[EBX].FAbilityID
  MOV EAX,ESI
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
  TEST AL,AL
  JZ @@none
  MOV EAX,[EBX].FSkillPointCost
  POP ESI
  POP EBX
  RET
@@none:
  XOR EAX,EAX
  POP ESI
  POP EBX
end;

function TAbility.AbilityDataClass: TEObjectClass;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

function TAbility.GetName(A1: TAbilityOwner): string;
begin
  Result := FAbilityName;
end;

function TAbility.GetAttack(A1: TAbilityOwner): Shortint;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

function TAbility.GetDefense(A1: TAbilityOwner): Shortint;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

function TAbility.GetResistance(A1: TAbilityOwner): Shortint;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

function TAbility.GetDamage(A1: TAbilityOwner): Shortint;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

function TAbility.GetMoveTypes(A1: TAbilityOwner): TMoveTypes;
{ needs: set result; preserve existing procedure-header return ABI. }
asm
  MOV AL,P1EmptyMoveTypes
end;

procedure TAbility.GetHidden;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

function TAbility.GetLevel(A1: TAbilityOwner): Integer;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

procedure TAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  A2 := 0;
  A3 := P1EmptyDamageTypes;
end;

procedure TAbility.ListInfo(A1: TStrings; A2: TAbilityInfoMode);
var
  Info: TP1CombatInfo;
  Strength: Integer;
  Types: TDamageTypes;
  DamageNames: string;
  DamageType_: TDamageType;
begin
  TStrings(A1).Add('Name: ' + Self.GetName(nil));
  TStrings(A1).Add('-------------------------------------------------');
  if aimID in A2 then TStrings(A1).Add('ID: ' + IntToStr(FAbilityID));
  TStrings(A1).Add('Type: ' + TranslateRStr(TAbilityTypeRStr[TP1AbilityView(Self).GetAbilityType]));
  if Self.GetAttack(nil) <> 0 then
    TStrings(A1).Add('Attack modifier: ' + IntToStr(Self.GetAttack(nil)));
  if Self.GetDefense(nil) <> 0 then
    TStrings(A1).Add('Defense modifier: ' + IntToStr(Self.GetDefense(nil)));
  if Self.GetDamage(nil) <> 0 then
    TStrings(A1).Add('Damage modifier: ' + IntToStr(Self.GetDamage(nil)));
  if Self.GetResistance(nil) <> 0 then
    TStrings(A1).Add('Resistance modifier: ' + IntToStr(Self.GetResistance(nil)));
  if aimDescription in A2 then
  begin
    TStrings(A1).Add('Description: ');
    TStrings(A1).AddStrings(FDescription);
  end;
  if TP1AbilityView(Self).GetCombatMode(nil) <> cmNone then
    TStrings(A1).Add('Combat mode: ' + TranslateRStr(TCombatModeRStr[TP1AbilityView(Self).GetCombatMode(nil)]));
  if aimStatistics in A2 then
  begin
    TP1AbilityView(Self).GetCombatInfo(nil, Info);
    if Info.Attack <> -1 then TStrings(A1).Add('Attack: ' + IntToStr(Info.Attack));
    if Info.Damage <> -1 then TStrings(A1).Add('Damage: ' + IntToStr(Info.Damage));
    if Info.RepeatCount <> -1 then TStrings(A1).Add('Repeat: ' + IntToStr(Info.RepeatCount));
    if Info.Types <> [] then
    begin
      DamageNames := '';
      for DamageType_ := Low(TDamageType) to High(TDamageType) do
        if DamageType_ in Info.Types then
        begin
          if DamageNames <> '' then DamageNames := DamageNames + ',';
          DamageNames := DamageNames + TranslateRStr(TDamageTypeRStr[DamageType_]);
        end;
      TStrings(A1).Add('Damage Types: ' + DamageNames);
    end;
  end;
  if aimStrength in A2 then
  begin
    TP1AbilityView(Self).GetOffensiveStrength(nil, Strength, Types);
    if Strength <> 0 then TStrings(A1).Add('Strength: ' + IntToStr(Strength));
  end;
end;

function TAbility.GetEnabled(A1: TAbilityOwner): Boolean;
asm
  MOV EAX,[EAX].FAbilityID
  XCHG EDX,EAX
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
end;

function TAbility.GetImmunityTypes(A1: TAbilityOwner): TDamageTypes;
{ needs: set result; preserve existing procedure-header return ABI. }
asm
  MOV AX,P1EmptyDamageTypes
end;

function TAbility.GetProtectionTypes(A1: TAbilityOwner): TDamageTypes;
{ needs: set result; preserve existing procedure-header return ABI. }
asm
  MOV AX,P1EmptyDamageTypes
end;

procedure TAbility.ListSpells;
begin
end;

function TAbility.GetAbilityType: TAbilityType;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

procedure TAbility.CombatObjectDestroyed(A1: TCombatObject);
begin
end;

procedure TAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
begin
end;

function TAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;

procedure TAbility.Execute;
begin
end;

procedure TAbility.NewDay(A1: TAbilityOwner);
begin
end;

procedure TAbility.NewTurn(A1: TAbilityOwner; A2: Shortint);
begin
end;

procedure TAbility.NewCombatTurn(A1: TCombatObject; A2: Shortint);
begin
end;

procedure TAbility.CombatDone(A1: TCombatObject);
begin
end;

procedure TAbility.CanActivate(A1: Integer; A2: Integer);
begin
  PString(A2)^ := '';
  { needs: Boolean result; P4 overrides remain unmarked procedures. }
  asm
    MOV EDX,A1
    MOV EAX,Self
    MOV ECX,[EAX]
    CALL DWORD PTR [ECX+$98]
    AND EAX,1
  end;
end;

procedure TAbility.Activate(A1: Integer; A2: Integer);
var
  Info: TActivateAbilityInfo;
begin
  { needs: Boolean result; P4 has unmarked procedure overrides. }
  if TP1AbilityView(Self).CanActivate(TAbilityOwner(A1), PString(A2)^) then
  begin
    Info := TActivateAbilityInfo.Create(nil);
    Info.FAbilityID := FAbilityID;
    if TObject(A1) is TAbstractUnit then
      Info.FUnitID := TAbstractUnit(A1).FUnitID
    else Info.FUnitID := 0;
    TEventList(AoWHSMap.F_AoWHSMap_1E4).TriggerNotifyEvents(Info);
    Info.Release;
    asm MOV AL,1 end;
  end
  else asm XOR EAX,EAX end;
end;

procedure TAbility.CanActivateCombat(A1: Integer; A2: Integer);
begin
  PString(A2)^ := '';
  { needs: Boolean result; P4 overrides remain unmarked procedures. }
  asm
    MOV EDX,A1
    MOV EAX,Self
    MOV ECX,[EAX]
    CALL DWORD PTR [ECX+$98]
    AND EAX,2
    SHR EAX,1
  end;
end;

function TAbility.ActivateCombat(Owner: TAbilityOwner; var Reason: string): Boolean;
var
  Info: TActivateAbilityInfo;
begin
  if TP1AbilityView(Self).CanActivateCombat(Owner, Reason) then
  begin
    Info := TActivateAbilityInfo.Create(nil);
    Info.FAbilityID := FAbilityID;
    if Owner is TAbstractUnit then
      Info.FUnitID := TAbstractUnit(Owner).FUnitID
    else Info.FUnitID := 0;
    TEventList(PP1Pointer(AoWHSMap.F_AoWHSMap_11C + $DC)^).TriggerNotifyEvents(Info);
    Info.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TAbility.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FDescription, 5);
  Stream.rwInteger(FSkillPointCost, 6);
  Stream.rwEObject(FSFXLibrary, 7);
  Stream.rwStreamProc(8, FImageSequences.LoadFromStream, FImageSequences.SaveToStream);
  Stream.rwData(FSelectionTypes, 2, 9);
end;

constructor TAbilityOwner.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

procedure TAbilityOwner.Clear;
begin
  inherited Clear;
  while FAbilityData <> nil do RemoveAbilityData(FAbilityData);
end;

function TAbilityOwner.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin
  Result := [];
end;

function TAbilityOwner.GetOwnerName: string;
begin Result := ''; end;

procedure TAbilityOwner.ValidateOwnerTypeAbilities;
var
  Types: TAbilitySelectionTypes;
  I: Integer;
begin
  Types := GetAbilitySelectionTypes;
  for I := GetAbCount - 1 downto 0 do
    if GetAbSet(I) and (AoWHSSet.FAbilityControl.GetAbility(I).FSelectionTypes * Types = []) then
      SetAbSet(I, 0);
end;

function TAbilityOwner.GetAbilityData(AbilityID: Integer): TAbilityData;
var
  Data: TAbilityData;
begin
  Data := FAbilityData;
  while (Data <> nil) and (Data.GetAbilityID <> AbilityID) do Data := Data.FNext;
  Result := Data;
end;

procedure TAbilityOwner.AssignAb(Source: TAbilityOwner);
var
  I: Integer;
  Data: TAbilityData;
begin
  while FAbilityData <> nil do RemoveAbilityData(FAbilityData);
  SetAbCount(Source.GetAbCount);
  for I := Source.GetAbCount - 1 downto 0 do
    if Source.GetAbSet(I) <> GetAbSet(I) then SetAbSet(I, Ord(Source.GetAbSet(I)));
  Data := Source.FAbilityData;
  while Data <> nil do
  begin
    AddAbilityData(TAbilityData(Data.Copy(AoWEngine)));
    Data := Data.FNext;
  end;
end;

procedure TAbilityOwner.AddAbilityData(Data: TAbilityData);
begin
  Data.FNext := FAbilityData;
  FAbilityData := Data;
end;

procedure TAbilityOwner.RemoveAbilityData(Data: TAbilityData);
var
  Current, Previous: TAbilityData;
begin
  Current := FAbilityData;
  Previous := nil;
  while (Current <> nil) and (Current <> Data) do
  begin
    Previous := Current;
    Current := Current.FNext;
  end;
  if Current = Data then
  begin
    { Original dereferences nil when Data is nil. }
    if Previous <> nil then Previous.FNext := Current.FNext
    else FAbilityData := Current.FNext;
    Current.Free;
  end;
end;

procedure TAbilityOwner.RemoveAbilityDataID(AbilityID: Integer);
var
  Current, Previous: TAbilityData;
begin
  Current := FAbilityData;
  Previous := nil;
  while (Current <> nil) and (Current.GetAbilityID <> AbilityID) do
  begin
    Previous := Current;
    Current := Current.FNext;
  end;
  if (Current <> nil) and (Current.GetAbilityID = AbilityID) then
  begin
    if Previous <> nil then Previous.FNext := Current.FNext
    else FAbilityData := Current.FNext;
    Current.Free;
  end;
end;

procedure TAbilityOwner.SetAbSet(A1: Integer; A2: Byte);
begin
  inherited SetAbSet(A1, A2);
end;

function TAbilityOwner.Execute: Integer;
begin
  Result := 1;
end;

procedure TAbilityOwner.ReadWrite(Stream: Engine.TEStorageStream);
var
  Previous, Data: TAbilityData;
  IDs: TIntegerList;
  I: Integer;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smRead, smCompare] = [smRead] then
  begin
    { Original tests property 3 before reading the data-ID list at $31. }
    if Stream.PropertyTable.PropertyExist(3) then
    begin
      Previous := nil;
      IDs := TIntegerList.Create;
      Stream.rwStreamProc($31, IDs.LoadFromStream, IDs.SaveToStream);
      for I := 0 to IDs.Count - 1 do
      begin
        Stream.rwCreateEObject(TEObject(Data), nil, IDs[I] + $32);
        if Previous <> nil then Previous.FNext := Data;
        Previous := Data;
        if FAbilityData = nil then FAbilityData := Data;
      end;
      IDs.Free;
    end;
  end
  else if Stream.StorageMode * [smWrite] = [smWrite] then
  begin
    if FAbilityData <> nil then
    begin
      IDs := TIntegerList.Create;
      Data := FAbilityData;
      while Data <> nil do
      begin
        IDs.Add(Data.GetAbilityID);
        Data := Data.FNext;
      end;
      Stream.rwStreamProc($31, IDs.LoadFromStream, IDs.SaveToStream);
      Data := FAbilityData;
      while Data <> nil do
      begin
        Stream.rwCreateEObject(TEObject(Data), nil, Data.GetAbilityID + $32);
        Data := Data.FNext;
      end;
      IDs.Free;
    end;
  end
  else if Stream.StorageMode * [smCompare] = [smCompare] then
  begin
    Data := FAbilityData;
    while Data <> nil do
    begin
      Stream.rwCreateEObject(TEObject(Data), nil, Data.GetAbilityID + $32);
      Data := Data.FNext;
    end;
  end;
end;

procedure TAbilityOwner.UpdateDefaultAbilities(Source: TAbilityOwner);
{ conflict: procedure TAbilityOwner.UpdateDefaultAbilities(A1: TCustomAbilityList); }
var
  I: Integer;
  Data: TAbilityData;
begin
  for I := Source.GetAbCount - 1 downto 0 do
    if Source.GetAbSet(I) and (not GetAbSet(I) or (Source.GetAbLevel(I) > GetAbLevel(I))) then
    begin
      Data := Source.GetAbilityData(I);
      if Data <> nil then
      begin
        RemoveAbilityDataID(I);
        Data := TAbilityData(Data.Copy(AoWEngine));
        AddAbilityData(Data);
      end;
      SetAbSet(I, 1);
    end;
end;

procedure TAbilityOwner.Changed;
begin
end;

function TAbilityOwner.ExpandAbility(AbilityID: Integer): Boolean;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).Expand(Self);
  if Result then Changed;
end;

function TAbilityOwner.RemoveAbility(A1: Integer): Boolean;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(A1).Remove(Self);
  if Result then Changed;
end;

function TAbilityOwner.GetAbAttackAll: Shortint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetAbCount - 1 do
    if GetAbEnabled(I) then Result := Result + AoWHSSet.FAbilityControl.GetAbility(I).GetAttack(Self);
end;

function TAbilityOwner.GetAbDefenseAll: Shortint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetAbCount - 1 do
    if GetAbEnabled(I) then Result := Result + AoWHSSet.FAbilityControl.GetAbility(I).GetDefense(Self);
end;

function TAbilityOwner.GetAbResistanceAll: Shortint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetAbCount - 1 do
    if GetAbEnabled(I) then Result := Result + AoWHSSet.FAbilityControl.GetAbility(I).GetResistance(Self);
end;

function TAbilityOwner.GetAbDamageAll: Shortint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetAbCount - 1 do
    if GetAbEnabled(I) then Result := Result + AoWHSSet.FAbilityControl.GetAbility(I).GetDamage(Self);
end;

function TAbilityOwner.GetAbMoveTypesAll: TMoveTypes;
begin
  Result := [];
  if GetAbEnabled(0) then Result := Result + [mtWalking];
  if GetAbEnabled(1) or GetAbEnabled(165) or GetAbEnabled(59) then Result := Result + [mtFlying];
  if GetAbEnabled(2) or GetAbEnabled(23) or GetAbEnabled(164) or GetAbEnabled(166) then Result := Result + [mtSwimming];
  if GetAbEnabled(3) or GetAbEnabled(157) then Result := Result + [mtForestry];
  if GetAbEnabled(4) or GetAbEnabled(157) then Result := Result + [mtCaveCrawling];
  if GetAbEnabled(5) or GetAbEnabled(157) then Result := Result + [mtMountaineering];
  if GetAbEnabled(7) or GetAbEnabled(163) then Result := Result + [mtTunneling];
  if GetAbEnabled(42) then Result := Result + [mtLavaCrossing];
end;

function TAbilityOwner.GetAbWallCombatFeatures: TWallCombatFeatures;
var
  I: Integer;
begin
  Result := [];
  { Original intersects into an empty set, so the result is always empty. }
  for I := GetAbCount - 1 downto 0 do
    if GetAbEnabled(I) then Result := Result * AoWHSSet.FAbilityControl.GetAbility(I).GetWallCombatFeatures(Self);
end;

function TAbilityOwner.GetAbProtectionTypesAll: TDamageTypes;
begin
  Result := [];
  if GetAbEnabled(77) or GetAbEnabled(166) then Result := Result + [dtPhysical];
  if GetAbEnabled(71) or GetAbEnabled(167) then Result := Result + [dtFire];
  if GetAbEnabled(75) then Result := Result + [dtMagic];
  if GetAbEnabled(76) then Result := Result + [dtCold];
  if GetAbEnabled(74) then Result := Result + [dtLightning];
  if GetAbEnabled(73) then Result := Result + [dtPoison];
  if GetAbEnabled(70) or GetAbEnabled(158) then Result := Result + [dtDeath];
  if GetAbEnabled(72) then Result := Result + [dtHoly];
end;

function TAbilityOwner.GetAbImmunityTypesAll: TDamageTypes;
begin
  Result := [];
  if GetAbEnabled(13) then Result := Result + [dtPhysical];
  if GetAbEnabled(7) or GetAbEnabled(163) then Result := Result + [dtFire];
  if GetAbEnabled(6) then Result := Result + [dtMagic];
  if GetAbEnabled(8) then Result := Result + [dtCold];
  if GetAbEnabled(9) then Result := Result + [dtLightning];
  if GetAbEnabled(10) then Result := Result + [dtPoison];
  if GetAbEnabled(11) then Result := Result + [dtDeath];
  if GetAbEnabled(12) then Result := Result + [dtHoly];
end;

function TAbilityOwner.GetAbName(AbilityID: Integer): string;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetName(Self);
end;

function TAbilityOwner.GetAbAttack(AbilityID: Integer): Shortint;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetAttack(Self);
end;

function TAbilityOwner.GetAbDefense(AbilityID: Integer): Shortint;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetDefense(Self);
end;

function TAbilityOwner.GetAbResistance(AbilityID: Integer): Shortint;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetResistance(Self);
end;

function TAbilityOwner.GetAbDamage(AbilityID: Integer): Shortint;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetDamage(Self);
end;

function TAbilityOwner.GetAbMoveTypes(AbilityID: Integer): TMoveTypes;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetMoveTypes(Self);
end;

function TAbilityOwner.GetAbProtectionTypes(AbilityID: Integer): TDamageTypes;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetProtectionTypes(Self);
end;

function TAbilityOwner.GetAbImmunityTypes(AbilityID: Integer): TDamageTypes;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetImmunityTypes(Self);
end;

function TAbilityOwner.GetAbLevel(AbilityID: Integer): Integer;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetLevel(Self);
end;

function TAbilityOwner.GetAbEnabled(AbilityID: Integer): Boolean;
begin
  Result := GetAbSet(AbilityID) and AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetEnabled(Self);
end;

procedure TAbilityOwner.TriggerNewDay;
var
  I: Integer;
begin
  try
    for I := 0 to GetAbCount - 1 do
      if GetAbSet(I) then AoWHSSet.FAbilityControl.GetAbility(I).NewDay(Self);
  except
  end;
end;

procedure TAbilityOwner.TriggerNewTurn(Player: Shortint);
var
  I: Integer;
begin
  for I := 0 to GetAbCount - 1 do
    if GetAbSet(I) then AoWHSSet.FAbilityControl.GetAbility(I).NewTurn(Self, Player);
end;

procedure TAbilityOwner.TriggerNewCombatTurn(Combat: TCombatObject; Player: Shortint);
var
  I: Integer;
begin
  for I := 0 to GetAbCount - 1 do
    if GetAbSet(I) then AoWHSSet.FAbilityControl.GetAbility(I).NewCombatTurn(Combat, Player);
end;

procedure TAbilityOwner.TriggerCombatDone(Combat: TCombatObject);
var
  I: Integer;
begin
  for I := 0 to GetAbCount - 1 do
    if GetAbSet(I) then AoWHSSet.FAbilityControl.GetAbility(I).CombatDone(Combat);
end;

procedure TAbilityOwner.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020001 then TriggerNewDay
  else if Msg.MsgID = $20020002 then TriggerNewTurn(Shortint(Msg.Value));
end;

procedure TAbilityOwner.ListAbilitiesEx(A1: TStrings; A2: TAbilitySelectionTypes);
var
  I: Integer;
  Ability: TAbility;
begin
  A1.Clear;
  for I := 0 to FAbilityCount - 1 do
    if GetAbSet(I) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(I);
      if Ability.FSelectionTypes * A2 <> [] then
        A1.AddObject(Ability.GetName(Self), TObject(I));
    end;
end;

procedure TAbilityOwner.ListAbilities(Text: TStrings);
var
  I: Integer;
  Ability: TAbility;
  Name: string;
begin
  Text.Clear;
  for I := 0 to FAbilityCount - 1 do
    if GetAbSet(I) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(I);
      Name := Ability.GetName(Self);
      if Name <> '' then Text.AddObject(Name, TObject(I));
    end;
end;

function TAbilityTypeList.GetAbility(A1: Integer): TAbility;
begin Result := TAbility(Items[A1]); end;

constructor TAbilityControl.Create(AOwner: Engine.TECustomNode);
var
  Kind: TAbilityType;
begin
  inherited Create(AOwner);
  FAbilities := TList.Create;
  for Kind := Low(TAbilityType) to High(TAbilityType) do
    FAbilitiesByType[Kind] := TAbilityTypeList.Create;
end;

destructor TAbilityControl.Destroy;
var
  Kind: TAbilityType;
begin
  UnregisterAll;
  for Kind := Low(TAbilityType) to High(TAbilityType) do FAbilitiesByType[Kind].Free;
  FAbilities.Free;
  inherited Destroy;
end;

procedure TAbilityControl.ReadWrite(Stream: Engine.TEStorageStream);
var
  I: Integer;
begin
  inherited ReadWrite(Stream);
  for I := 0 to FAbilities.Count - 1 do
    if FAbilities[I] <> nil then Stream.rwEObject(TAbility(FAbilities[I]), I + 10);
end;

function TAbilityControl.GetCount: Integer;
begin
  Result := FAbilities.Count;
end;

function TAbilityControl.GetAbility(Index: Integer): TAbility;
var
  Items: PIntegerArray;
begin
  Assert(Index >= 0, 'Invalid AbilityID');
  if Index < FAbilities.Count then
  begin
    Items := PIntegerArray(FAbilities.List);
    Result := TAbility(Items^[Index]);
  end
  else Result := nil;
end;

procedure TAbilityControl.RegisterAbility(Ability: TAbility);
var
  ID: Integer;
begin
  ID := Ability.FAbilityID;
  if ID <> -1 then
  begin
    with FAbilities do
      if (ID < Count) and (Items[ID] <> nil) then
        raise Exception.Create('Ability already registered (' + IntToStr(ID) + ')');
    while ID >= FAbilities.Count do FAbilities.Add(nil);
    FAbilities.List^[ID] := Ability;
    FAbilitiesByType[Ability.GetAbilityType].Add(Ability);
    Ability.FImageSequences.LinkToIL;
  end
  else raise Exception.Create('Invalid AbilityID (' + Ability.ClassName + ')');
end;

procedure TAbilityControl.UnregisterAbility(Ability: TAbility);
var
  ID: Integer;
begin
  ID := Ability.FAbilityID;
  if ID <> -1 then
  begin
    if (ID < 0) or (ID >= FAbilities.Count) or (FAbilities[ID] <> Ability) then
      raise Exception.Create('Cannot Unregister Ability (' + IntToStr(ID) + ')');
    if FAbilities.List^[ID] <> nil then
    begin
      FAbilitiesByType[Ability.GetAbilityType].Remove(Ability);
      TAbility(FAbilities.List^[ID]).FImageSequences.ReleaseIL;
      TObject(FAbilities.List^[ID]).Free;
      FAbilities.List^[ID] := nil;
    end;
  end
  else raise Exception.Create('Invalid AbilityID (' + Ability.ClassName + ')');
end;

procedure TAbilityControl.UnregisterAll;
var
  I: Integer;
begin
  for I := FAbilities.Count - 1 downto 0 do
    if FAbilities[I] <> nil then UnregisterAbility(FAbilities[I]);
end;

procedure TAbilityControl.UnregisterAbilityID(ID: Integer);
begin
  if FAbilities.List^[ID] <> nil then UnregisterAbility(FAbilities.List^[ID]);
end;

procedure TAbilityControl.ListAbilities(Text: TStrings; Types: TAbilitySelectionTypes);
var
  I: Integer;
begin
  Text.Clear;
  with FAbilities do
    for I := 0 to Count - 1 do
      if List^[I] <> nil then
        if (TAbility(List^[I]).FSelectionTypes * Types <> []) or
          ((Types = [Low(TAbilitySelectionType)..High(TAbilitySelectionType)]) and
          (TAbility(List^[I]).FSelectionTypes = [])) then
          Text.AddObject(TAbility(List^[I]).GetName(nil), TObject(I));
end;

function CompareAbilityNames(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(TAbility(Item1).GetName(nil), TAbility(Item2).GetName(nil));
end;

procedure TAbilityControl.ListAbilityInfo(Text: TStrings; SortByName: Boolean; Mode: TAbilityInfoMode);
var
  List: TList;
  I: Integer;
begin
  List := TList.Create;
  for I := 0 to FAbilities.Count - 1 do
    if FAbilities.List^[I] <> nil then List.Add(FAbilities.List^[I]);
  if SortByName then List.Sort(CompareAbilityNames);
  { Original frees the temporary list only after all ability callbacks succeed. }
  for I := 0 to List.Count - 1 do
  begin
    TAbility(List[I]).ListInfo(Text, Mode);
    Text.Add('-------------------------------------------------');
    Text.Add('');
  end;
  List.Free;
end;

function TPlayerStructureList.GetStructure(Index: Integer): TPlayerStructure;
begin
  Result := FChildren.List^[Index];
end;

function TArmyList.GetArmy(Index: Integer): TArmy;
begin
  Result := FChildren.List^[Index];
end;

constructor TDiplomaticRelationList.Create;
begin
  inherited Create;
  Default := Ord(drUnknown);
end;

function TDiplomaticRelationList.GetDiplomaticRelation(Index: Integer): TDiplomaticRelation;
begin
  if Index < Count then Result := TDiplomaticRelation(List^[Index])
  else Result := drUnknown;
end;

procedure TDiplomaticRelationList.SetDiplomaticRelation(Index: Integer; Value: TDiplomaticRelation);
begin
  Items[Index] := Ord(Value);
end;

class function TDiplomaticRelationHistoryItem.ClassID: Integer;
begin
  Result := $2011A;
end;

procedure TDiplomaticRelationHistoryItem.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FDay, 20);
  Stream.rwData(FRelation, 1, 21);
end;

class function TDiplomaticRelationHistoryList.ClassID: Integer;
begin
  Result := $2011B;
end;

function TDiplomaticRelationHistoryList.GetItems(Index: Integer): TDiplomaticRelationHistoryItem;
begin
  Result := TDiplomaticRelationHistoryItem(FChildren[Index]);
end;

function TDiplomaticRelationHistoryList.GetLastModifiedOnDay: Integer;
begin
  if Count <> 0 then Result := GetItems(Count - 1).FDay
  else Result := 0;
end;

function TDiplomaticRelationHistoryList.GetRelationOnDay(Day: Integer): TDiplomaticRelation;
var
  I: Integer;
begin
  Result := drUnknown;
  I := 0;
  while (I < Count) and (GetItems(I).FDay <= Day) do
  begin
    Result := GetItems(I).FRelation;
    Inc(I);
  end;
end;

procedure TDiplomaticRelationHistoryList.Add(Relation: TDiplomaticRelation; Day: Integer);
begin
  with TDiplomaticRelationHistoryItem.Create(Self) do
  begin
    FDay := Day;
    FRelation := Relation;
  end;
end;

constructor TPlayerDiplomaticRelations.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRelations := TByteList.Create;
  FHistory := TENode.Create(nil);
end;

destructor TPlayerDiplomaticRelations.Destroy;
begin
  FRelations.Free;
  FHistory.Free;
  inherited Destroy;
end;

procedure TPlayerDiplomaticRelations.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(20, FRelations.LoadFromStream, FRelations.SaveToStream);
  Stream.rwEObject(FHistory, 21);
  if smRead in Stream.StorageMode then FRelations.Default := Ord(drUnknown);
end;

function TPlayerDiplomaticRelations.GetDiplomaticRelation(Player: Shortint): TDiplomaticRelation;
begin
  if Player < FRelations.Count then
    Result := TDiplomaticRelation(FRelations.List^[Player])
  else Result := drUnknown;
end;

procedure TPlayerDiplomaticRelations.SetDiplomaticRelation(Player: Shortint; Value: TDiplomaticRelation);
begin
  FRelations[Player] := Ord(Value);
  if not (msEditting in AoWHSMap.Status) and (AoWHSMap.FDay > 0) then
    GetHistory(Player).Add(Value, AoWHSMap.FDay);
end;

function TPlayerDiplomaticRelations.GetHistory(Player: Shortint): TDiplomaticRelationHistoryList;
begin
  Result := FHistory.FChildren.List^[Player - 1];
end;

procedure TPlayerDiplomaticRelations.ValidateHistory;
begin
  while FHistory.Count + 1 < AoWHSMap.FPlayers.Count do
    TDiplomaticRelationHistoryList.Create(nil).Owner := FHistory;
  while FHistory.Count + 1 > AoWHSMap.FPlayers.Count do
    FHistory.Children[FHistory.Count - 1].Free;
end;

procedure TPlayerDiplomaticRelations.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
var
  Player: Shortint;
  I: Integer;
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin
    ValidateHistory;
    if FPlayer.FLegacyNewRelations.Count <> 0 then
    begin
      FRelations.Assign(FPlayer.FLegacyNewRelations);
      FPlayer.FLegacyNewRelations.Clear;
    end;
    if (AoWHSMap.FDay = 0) and not (msEditting in AoWHSMap.Status) then
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
      begin
        Player := I;
        GetHistory(Player).Add(GetDiplomaticRelation(Player), 0);
      end
    else if FPlayer.FLegacyRelations.Count <> 0 then
    begin
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        GetHistory(I).Add(FPlayer.FLegacyRelations.GetDiplomaticRelation(I), 0);
      FPlayer.FLegacyRelations.Clear;
    end;
  end;
end;

class function TTurnInfoItem.ClassID: Integer;
begin
  Result := $2029B;
end;

procedure TTurnInfoItem.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FGold, 25);
  Stream.rwInteger(FMana, 26);
  Stream.rwInteger(FStructures, 27);
  Stream.rwInteger(FArmyStrength, 28);
  Stream.rwByte(FHeroes, 29);
end;

function TTurnInfoItem.GetSuperiority: Integer;
begin
  Result := FArmyStrength div 100 + FStructures * 10 +
    (FGold shr 3) + (FMana shr 3) + FHeroes * 100;
end;

function TTurnInfo.GetTurnInfo(Index: Integer): TTurnInfoItem;
begin
  Result := FChildren.List^[Index];
end;

constructor TPlayerStatistics.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTurnInfo := TTurnInfo.Create(nil);
end;

destructor TPlayerStatistics.Destroy;
begin
  FTurnInfo.Free;
  inherited Destroy;
end;

procedure TPlayerStatistics.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FTurnInfo, 20);
  Stream.rwInteger(FUnitsKilled, 21);
  Stream.rwInteger(FUnitsLost, 22);
end;

function TIncomeSource.Name: string;
begin
  Result := '';
end;

function TIncomeSource.Income: Integer;
begin
  Result := 0;
end;

procedure TIncomeSource.GetLocation(var X, Y, L: Shortint);
begin
  X := -1;
  Y := -1;
  L := -1;
end;

procedure TIncomeSource.CenterToLocation;
var
  X, Y, L: Shortint;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
  begin
    AoWHSMap.CenterViewTo(X, Y, L);
    AoWHSMap.PlayCenterAnimation(X, Y, L);
  end;
end;

function TIncomeSourceList.GetItems(Index: Integer): TIncomeSource;
begin
  Result := FChildren.List^[Index];
end;

constructor TPBEMPlayerSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FStatus := [];
  FEmailGame := TEmailGame.Create(nil);
end;

destructor TPBEMPlayerSettings.Destroy;
begin
  FEmailGame.Free;
  inherited Destroy;
end;

procedure TPBEMPlayerSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FStatus, 1, 20);
  Stream.rwEObject(FEmailGame, 21);
end;

procedure TPBEMPlayerSettings.SetGame(Game: TEObject);
begin
  FEmailGame.Assign(Game, AoWEngine);
end;

constructor TPlayer.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FIncomeChangedEvents := TEventList.Create;
  FGemsChangedEvents := TEventList.Create;
  FUpkeepChangedEvents := TEventList.Create;
  FStructures := TPlayerStructureList.Create(nil);
  FStructures.FPlayer := Self;
  FArmies := TArmyList.Create(nil);
  FAIControl := TAIPlayerControl.Create(nil);
  FAIControl.FPlayer := Self;
  FAIBudget := TAIBudgetManager.Create(nil);
  FAIBudget.FPlayer := Self;
  FAIGroups := TAIGroupList.Create(nil);
  FMagicControl := TPlayerMagicControl.Create(nil);
  FMagicControl.FPlayer := Self;
  FStatistics := TPlayerStatistics.Create(nil);
  FArmies.FPlayer := Self;
  FArmies.Events.Add(ArmiesChanged);
  FHeroes := THeroList.Create(nil);
  FInitialGold := 250;
  FBaseIncome := 0;
  FPlayerIndex := -1;
  FParticipating := False;
  FEventLogbook := TEventLogbook.Create(nil);
  FEventLogbook.SetOnChanged(LogbookChangedEvent);
  FLogbookChangedEvents := TEventList.Create;
  FDiplomaticRelations := TPlayerDiplomaticRelations.Create(nil);
  FDiplomaticRelations.FPlayer := Self;
  FLegacyNewRelations := TDiplomaticRelationList.Create;
  FProductionControls := TProductionControlList.Create;
  FIncomeSources := TIncomeSourceList.Create(nil);
  FLeaderSetup := TLeader.Create(nil);
  FEndTurn := False;
  FGameOverStatus := goNone;
  FFirstDaySeen := TIntegerList.Create;
  FFirstDaySeen.Default := -1;
  FLastDaySeen := TIntegerList.Create;
  FLastDaySeen.Default := -1;
  FVictoryLocations := TPlayerStructureList.Create(nil);
  FKnownStructures := TPlayerStructureList.Create(nil);
  FMessages := TStringList.Create;
  FDiplomaticActions := TDiplomaticActionList.Create(nil);
  FAIValidAttackPlayers := TBitList.Create;
  FPBEMSettings := TPBEMPlayerSettings.Create(nil);
  FLegacyRelations := TDiplomaticRelationList.Create;
  FHeroEmerging := False;
  FBaseHeroJoinDay := -1;
  FHeroJoinDay := -1;
  FPlayerRace := -1;
  F_Player_2D := $FF;
  F_Player_2E := $FF;
end;

destructor TPlayer.Destroy;
var
  I: Integer;
begin
  try
    FIncomeChangedEvents.Clear;
    FGemsChangedEvents.Clear;
    FUpkeepChangedEvents.Clear;
    try
      if (AoWHSMap <> nil) and (msDestroying in AoWHSMap.Status) then
      begin
        Assert(FVictoryLocations.Count = 0, 'Victory Locations not correctly cleared (TPlayer)');
        Assert(FStructures.Count = 0, 'Registered Player Structures not correctly cleared (TPlayer)');
        Assert(FArmies.Count = 0, 'Registered Player Armies not correctly cleared (TPlayer)');
      end
      else
      begin
        for I := FStructures.Count - 1 downto 0 do
          FStructures.GetStructure(I).SetPlayer(0);
        for I := FArmies.Count - 1 downto 0 do
          FArmies.GetArmy(I).SetPlayer(0);
      end;
    except
    end;
    FMessages.Free;
    FMessages := nil;
    FDiplomaticActions.Free;
    FDiplomaticActions := nil;
    FAIValidAttackPlayers.Free;
    FAIValidAttackPlayers := nil;
    FLegacyRelations.Free;
    try
      FLogbookChangedEvents.Clear;
      FEventLogbook.Free;
      FLogbookChangedEvents.Free;
    except
    end;
    try
      FLegacyNewRelations.Free;
      FDiplomaticRelations.Free;
    except
    end;
    try FProductionControls.Free; except end;
    try FAIControl.Free; except end;
    try FStatistics.Free; except end;
    try FMagicControl.Free; except end;
    try FLeaderSetup.Free; except end;
    try
      FFirstDaySeen.Free;
      FLastDaySeen.Free;
    except
    end;
    try FHeroes.Free; except end;
    try
      FArmies.Free;
      FAIGroups.Free;
      FAIBudget.Free;
      FStructures.Free;
      FVictoryLocations.Free;
      FIncomeSources.Free;
      FKnownStructures.Free;
    except
    end;
    try inherited Destroy; except end;
    FPBEMSettings.Free;
    FPBEMSettings := nil;
    FIncomeChangedEvents.Free;
    FIncomeChangedEvents := nil;
    FGemsChangedEvents.Free;
    FGemsChangedEvents := nil;
    FUpkeepChangedEvents.Free;
    FUpkeepChangedEvents := nil;
  except
  end;
end;

class function TPlayer.ClassID: Integer;
begin
  Result := $20020;
end;

function TPlayer.GetBusy: Boolean;
begin
  Result := (FBusyCount <> 0) or not AoWHSMap.FTokenManager.PlayerReady(FPlayerIndex);
  Result := Result or ((AoWHSMap.FCombat = nil) and
    (AoWHSMap.FPlayMode = pmTurn) and (AoWHSMap.FCurrentPlayer <> FPlayerIndex));
  Result := Result or ((AoWHSMap.FCombat <> nil) and
    (AoWHSMap.FCombat.FCombatData.FPlayers.GetPlayers(
      AoWHSMap.FCombat.FCombatData.FCurrentPlayer).FPlayer <> FPlayerIndex));
  Result := Result or (FGameOverStatus <> goNone) or not GetLocal;
  Result := Result or ((FPlayerType = ptHuman) and
    AoWHSMap.GetTurnTimerEnabled and (AoWHSMap.GetTurnTimeLeft <= 0));
end;

function TPlayer.GetSuperiority: Integer;
begin
  if FStatistics.FTurnInfo.Count <> 0 then
    Result := FStatistics.FTurnInfo.GetTurnInfo(FStatistics.FTurnInfo.Count - 1).GetSuperiority
  else Result := 0;
end;

function TPlayer.GetUnitCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FArmies.Count - 1 downto 0 do
    Inc(Result, FArmies.GetArmy(I).Count);
end;

procedure TPlayer.SetPlayerIndex(Value: Shortint);
begin
  FPlayerIndex := Value;
  FEventLogbook.FPlayer := Value;
end;

procedure TPlayer.SetGameOverStatus(Value: TGameOverStatus);
var
  Text: string;
  Event: TGameOverEventLog;
  I: Integer;
  Campaign: TAoWCampaign;
begin
  if (FGameOverStatus <> Value) and (FGameOverStatus = goNone) then
  begin
    FGameOverStatus := Value;
    AoWHSMap.FAIExecuter.DeactivatePlayer(FPlayerIndex);
    if (AoWHSMap.FGameType = gtCampaign) and (FPlayerType = ptHuman) then
    begin
      if FGameOverStatus = goLost then
      begin
        AoWHSMap.FGameResult := grFailed;
        Campaign := AoWEngine.FCampaign;
        if Campaign <> nil then Campaign.RestartScenario;
      end
      else if FGameOverStatus = goWon then
      begin
        AoWHSMap.FGameResult := grSucceeded;
        Campaign := AoWEngine.FCampaign;
        if Campaign <> nil then Campaign.FinishScenario;
      end;
    end;
    if FGameOverStatus = goLost then
    begin
      BeginUpdate;
      FMagicControl.RemoveEnchantments;
      for I := FStructures.Count - 1 downto 0 do
        FStructures.GetStructure(I).SetPlayer(0);
      for I := FArmies.Count - 1 downto 0 do
        FArmies.GetArmy(I).SetPlayer(0);
      FMagicControl.SetMana(0);
      FGems := 0;
      EndUpdate;
      AoWHSMap.FPlayers.Update;
    end;
    Event := TGameOverEventLog.Create(nil);
    Event.FPlayer := FPlayerIndex;
    if Value = goLost then
    begin
      Text := Format(TranslateRStr(GameOverDefeatMessageRStr),
        [IntToStr(AoWHSMap.FDay), TranslateRStr(RaceNamesPluralRStr[FPlayerRace]), GetName]);
      Event.FMessage.Text := Text;
    end
    else
    begin
      Text := Format(TranslateRStr(GameOverVictoryMessageRStr),
        [IntToStr(AoWHSMap.FDay), TranslateRStr(RaceNamesPluralRStr[FPlayerRace]), GetName]);
      Event.FMessage.Text := Text;
    end;
    AoWHSMap.ExecuteGameOverEvent(Event);
    Event.Release;
    if FGameOverStatus = goLost then
      AoWHSMap.FGlobalMagicControl.RemovePlayerEnchantments(FPlayerIndex);
  end;
end;

function TPlayer.Surrender: Boolean;
var
  TE: TGameOverTE;
begin
  if not GetBusy and (FGameOverStatus = goNone) then
  begin
    TE := TGameOverTE.Create(nil);
    TE.FPlayer := FPlayerIndex;
    TE.FGameOverStatus := goLost;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayerIndex).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function TPlayer.Win: Boolean;
var
  TE: TGameOverTE;
begin
  if not GetBusy and (FGameOverStatus = goNone) then
  begin
    TE := TGameOverTE.Create(nil);
    TE.FPlayer := FPlayerIndex;
    TE.FGameOverStatus := goWon;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayerIndex).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function TPlayer.Validate(Errors: TStrings): Boolean;
var
  S, LeaderName: string;
begin
  if FPlayerIndex > 0 then
  begin
    Result := True;
    if FLeader.GetSphereCount <> AoWHSMap.FSphereCount then
    begin
      LeaderName := Format(XLeaderRStr, [TranslateRStr(RaceNamesRStr[FPlayerRace])]);
      S := LeaderName + ': ' + TranslateRStr(NotAllSpheresAssignedRStr);
      Errors.Add(S);
      Result := False;
    end;
    if FLeader.Owner = nil then
    begin
      LeaderName := Format(XLeaderRStr, [TranslateRStr(RaceNamesRStr[FPlayerRace])]);
      S := LeaderName + ': ' + TranslateRStr(NotPlacedOnMapRStr);
      Errors.Add(S);
      Result := False;
    end;
    if FLeader.GetSkillPoints <> 0 then
    begin
      LeaderName := Format(XLeaderRStr, [TranslateRStr(RaceNamesRStr[FPlayerRace])]);
      S := LeaderName + ': ' + TranslateRStr(NotAllSkillPointsAssignedRStr);
      Errors.Add(S);
      { Original reports unassigned skill points without failing validation. }
    end;
  end
  else Result := True;
end;

procedure TPlayer.LockBusy;
begin
  Inc(FBusyCount);
end;

procedure TPlayer.UnlockBusy;
begin
  Assert(FBusyCount <> 0, 'Invalid busy counter usage');
  Dec(FBusyCount);
end;

procedure TPlayer.LogbookChangedEvent(Sender: TObject);
begin
  if FUpdateCount = 0 then FLogbookChangedEvents.TriggerNotifyEvents(Self);
end;

procedure TPlayer.BeginUpdate;
begin
  Inc(FUpdateCount);
  FStructures.BeginUpdate;
  FArmies.BeginUpdate;
  FMagicControl.BeginUpdate;
end;

procedure TPlayer.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    FGemsChangedEvents.TriggerNotifyEvents(Self);
    FUpkeepChangedEvents.TriggerNotifyEvents(Self);
    UpdateIncome;
    FLogbookChangedEvents.TriggerNotifyEvents(Self);
  end;
  FStructures.EndUpdate;
  FArmies.EndUpdate;
  FMagicControl.EndUpdate;
end;

procedure TPlayer.ArmiesChanged(Sender: TObject);
begin
  if FArmies.Count = 0 then AoWHSMap.GameOver(FPlayerIndex, goLost);
end;

procedure TPlayer.SetGems(Value: Integer);
begin
  FGems := Value;
  if FUpdateCount = 0 then FGemsChangedEvents.TriggerNotifyEvents(Self);
  if (AoWHSMap.FVictoryCondition = vcAccumulateGold) and
    (AoWHSMap.FVictoryGold <= FGems) then
    AoWHSMap.GameOver(FPlayerIndex, goWon);
end;

procedure TPlayer.UpdateIncome;
var
  I: Integer;
begin
  FIncome := FBaseIncome;
  for I := FIncomeSources.Count - 1 downto 0 do
    Inc(FIncome, TIncomeSource(FIncomeSources.FChildren.List^[I]).Income);
  if FPlayerType = ptCPU2 then FIncome := Round(FIncome * 1.0)
  else if FPlayerType = ptCPU3 then FIncome := Round(FIncome * 2.0)
  else if FPlayerType = ptCPU4 then FIncome := Round(FIncome * 2.5) + 50
  else if FPlayerType = ptCPU5 then FIncome := Round(FIncome * 3) + 100;
  if FUpdateCount = 0 then FIncomeChangedEvents.TriggerNotifyEvents(Self);
end;

procedure TPlayer.RegisterIncomeSource(Source: TIncomeSource);
begin
  if FIncomeSources.FChildren.IndexOf(Source) = -1 then
  begin
    FIncomeSources.FChildren.Add(Source);
    if FUpdateCount = 0 then UpdateIncome;
  end;
end;

procedure TPlayer.UnregisterIncomeSource(Source: TIncomeSource);
begin
  if (FIncomeSources.FChildren.Remove(Source) <> -1) and (FUpdateCount = 0) then
    UpdateIncome;
end;

function TPlayer.GetUpkeep: Integer;
begin
  Result := FArmyUpkeep + FMagicUpkeep;
end;

procedure TPlayer.SetArmyUpkeep(Value: Integer);
begin
  FArmyUpkeep := Value;
  if FUpdateCount = 0 then FUpkeepChangedEvents.TriggerNotifyEvents(Self);
end;

procedure TPlayer.SetMagicUpkeep(Value: Integer);
begin
  FMagicUpkeep := Value;
  if FUpdateCount = 0 then FUpkeepChangedEvents.TriggerNotifyEvents(Self);
end;

function TPlayer.GetName: string;
begin
  if FPlayerIndex <> 0 then
  begin
    if FLeader <> nil then
    begin
      Result := FLeader.FHeroName;
      if FLeader.GetNickname <> '' then
        Result := Result + ' ' + FLeader.GetNickname;
    end
    else Result := FName;
    if Result = '' then
      Result := TranslateRStr(PlayerRStr) + ' ' + IntToStr(FPlayerIndex);
  end
  else Result := TranslateRStr(IndependentsRStr);
end;

function TPlayer.GetNameEx: string;
begin
  if FPlayerIndex <> 0 then
    Result := Format(TranslateRStr(PlayerNameExRStr),
      [GetName, TranslateRStr(RaceNamesPluralRStr[FPlayerRace])])
  else Result := GetName;
end;

procedure TPlayer.SetName(Value: string);
begin
  if FPlayerIndex <> 0 then
    if FLeader <> nil then
    begin
      FLeader.FHeroName := Value;
      FLeader.SetNickname('');
    end
    else FName := Value;
end;

function TPlayer.GetFace: TLibraryImage;
begin
  if FLeader <> nil then Result := FLeader.GetFace
  else Result := nil;
end;

function TPlayer.GetHeroCountMax: Integer;
var
  Strength, Maximum: Integer;
begin
  Strength := FStatistics.FTurnInfo.GetTurnInfo(FStatistics.FTurnInfo.Count - 1).FArmyStrength;
  if Strength < 10 then Result := 1
  else if Strength < 40 then Result := 2
  else if Strength < 80 then Result := 3
  else if Strength < 120 then Result := 4
  else if Strength < 200 then Result := 5
  else Result := (Strength - 200) div 100 + 5;
  Maximum := AoWHSMap.FHeroCountMax;
  if Result > Maximum then Result := Maximum;
end;

function TPlayer.GetIdealHeroJoinDay: Integer;
var
  Average, Maximum: Integer;
begin
  Result := FLastHeroJoinDay;
  Average := AoWHSMap.FPlayers.GetAverageHeroCount;
  Maximum := AoWHSMap.FPlayers.GetMaxHeroCount;
  if (Average < Maximum) and (FHeroes.Count = Maximum) then
    Inc(Result, 15)
  else if (Average <= FHeroes.Count) and (FHeroes.Count <> 0) and (AoWHSMap.FDay > 15) then
    Inc(Result, 10)
  else Inc(Result, 5);
end;

function TPlayer.GetIdealHeroEmergeDay: Integer;
var
  Average, Maximum, Earliest: Integer;
begin
  Result := GetIdealHeroJoinDay;
  Average := AoWHSMap.FPlayers.GetAverageHeroCount;
  Maximum := AoWHSMap.FPlayers.GetMaxHeroCount;
  if (Average < Maximum) and (FHeroes.Count = Maximum) then
    Inc(Result, 15)
  else if (Average < FHeroes.Count) and (FHeroes.Count <> 0) and (AoWHSMap.FDay > 10) then
    Inc(Result, 10)
  else Inc(Result, 5);
  Earliest := FLastHeroEmergeDay + 5;
  if Result < Earliest then Result := Earliest;
end;

procedure TPlayer.ResetBaseHeroJoinDay;
begin
  FLastHeroJoinDay := AoWHSMap.FDay;
end;

procedure TPlayer.MakeHeroEmerge(A1: Integer);
begin end;

procedure TPlayer.UpdateHeroJoin;
begin end;

procedure TPlayer.GetHeroJoinChance(A1: Integer);
begin end;

procedure TPlayer.GetHeroJoinLevelMax(A1: Integer; A2: Integer);
begin end;

procedure TPlayer.ValidateLeader;
begin end;

procedure TPlayer.SetLeader(A1: Integer);
begin end;

procedure TPlayer.SetRace(A1: Byte);
begin end;

procedure TPlayer.SetEndTurn(A1: Byte);
begin end;

procedure TPlayer.UpdateLogbook;
begin end;

procedure TPlayer.UpdateTurnInfo;
begin end;

procedure TPlayer.UpdateAlliedPlayersSeen;
begin end;

procedure TPlayer.SetupAIValidAttackPlayers;
begin end;

procedure TPlayer.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TPlayer.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayer.GetFirstDaySeen(A1: Byte);
begin end;

procedure TPlayer.GetLastDaySeen(A1: Byte);
begin end;

procedure TPlayer.PlayerSeen(A1: Integer);
begin end;

procedure TPlayer.GetLeaderLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TPlayer.GetLocal: Boolean;
begin Result := False; end;

procedure TPlayer.RegisterVictoryLocation;
begin end;

procedure TPlayer.UnregisterVictoryLocation;
begin end;

procedure TPlayer.CheckCaptureLocations;
begin end;

procedure TPlayer.CaptureLocationsLeft;
begin end;

function TPlayer.CreateDiplomaticAction(Action: TDiplomaticActionType; Target, Other: Shortint): TDiplomaticAction;
begin Result := nil; end;

procedure TPlayer.DiplomaticActionAleadySend(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TPlayer.ListDiplomaticActions(A1: Integer; A2: Integer);
begin end;

procedure TPlayer.ValidAttackRelation(A1: Integer; A2: Integer);
begin end;

procedure TPlayer.ChangePlayerSettings(A1: Integer);
begin end;

constructor TPlayerList.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerList.Destroy;
begin end;

procedure TPlayerList.GetDiplomaticRelationCount(A1: Integer; A2: Byte);
begin end;

function TPlayerList.GetDiplomaticRelation(Player, OtherPlayer: Shortint): TDiplomaticRelation;
{ conflict: function TPlayerList.GetDiplomaticRelation(Source, Target: Shortint): TDiplomaticRelation; }
begin Result := drPeace; end;

procedure TPlayerList.SetDiplomaticRelation(A1: Integer; A2: Byte; A3: Integer);
begin end;

procedure TPlayerList.GetActivePlayers(A1: Integer; A2: Integer);
begin end;

procedure TPlayerList.Update;
begin end;

procedure TPlayerList.BeginUpdate;
begin end;

procedure TPlayerList.EndUpdate;
begin end;

procedure TPlayerList.Assign(Source: Engine.TEObject; AEngine: Engine.TEngine);
begin end;

function TPlayerList.GetPlayers(Index: Integer): TPlayer;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TPlayer(FChildren.List^[Index])
  else Result := nil;
end;

procedure TPlayerList.GetActivePlayersAllied;
begin end;

procedure TPlayerList.GetAverageHeroLevel;
begin end;

function TPlayerList.GetAverageHeroCount: Integer;
begin Result := 0; end;

function TPlayerList.GetMaxHeroCount: Integer;
begin Result := 0; end;

procedure TPlayerList.GetNumberOfPlayers;
begin end;

function TPlayerList.RaceToPlayer(Race: Shortint): Integer;
var
  I: Integer;
begin
  Result := -1;
  I := 1;
  { Original uses <> Count and assumes at least the independent player exists. }
  while (Result = -1) and (I <> FChildren.Count) do
  begin
    if TPlayer(FChildren.List^[I]).FPlayerRace = Race then Result := I;
    Inc(I);
  end;
end;

procedure TPlayerList.SetNumberOfPlayers(A1: Integer);
begin end;

procedure TPlayerList.ValidateRaces(A1: Integer);
begin end;

procedure TPlayerList.VerifyRaces(A1: Integer; A2: Integer);
begin end;

procedure TPlayerList.GetSuperiorPlayer(A1: Integer; A2: Integer);
begin end;

procedure TPlayerList.IndexOfPlayerType(A1: Integer);
begin end;

constructor TLeaderSetupControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TLeaderSetupControl.Destroy;
begin end;

function TLeaderSetupControl.AddRef: Integer;
begin Result := 0; end;

function TLeaderSetupControl.Release: Integer;
begin Result := 0; end;

procedure TLeaderSetupControl.Done;
begin end;

constructor TPlayerControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerControl.Destroy;
begin end;

procedure TPlayerControl.Setup;
begin end;

procedure TPlayerControl.GetSyncValue(A1: Integer);
begin end;

procedure TPlayerControl.OutOfSync;
begin end;

procedure TPlayerControl.NewFrame;
begin end;

procedure TPlayerControl.NewDay;
begin end;

procedure TPlayerControl.AutoSave;
begin end;

procedure TPlayerControl.EndTurn(A1: Integer; A2: Integer);
begin end;

procedure TPlayerControl.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TPlayerControl.StartNewMap;
begin end;

procedure TPlayerControl.StartLoadedMap;
begin end;

procedure TPlayerControl.SetPlayerGameOverStatus(A1: Integer; A2: Integer);
begin end;

procedure TPlayerControl.GameOver(A1: Integer; A2: Integer);
begin end;

procedure TPlayerControl.GameOverEventHandled(A1: Integer);
begin end;

procedure TPlayerControl.SetSeatedPlayer(A1: Integer);
begin end;

procedure TPlayerControl.LockAI;
begin end;

procedure TPlayerControl.ListPlayerInfo(A1: Integer);
begin end;

procedure TPlayerControl.ExitSaveGameCallBack(A1: Integer);
begin end;

procedure TPlayerControl.SaveGameOnExitCallBack(A1: Integer);
begin end;

procedure TPlayerControl.ExitNetworkGameCallBack(A1: Integer);
begin end;

procedure TPlayerControl.ExitGame(A1: Byte);
begin end;

procedure TPlayerControl.PasswordFailed;
begin end;

procedure TPlayerControl.PasswordValidated;
begin end;

procedure TPlayerControl.PasswordTryAgainCallBack(A1: Integer);
begin end;

procedure TPlayerControl.ValidatePasswordCallBack(A1: Integer);
begin end;

procedure TPlayerControl.ValidatePassword(A1: Integer);
begin end;

procedure TPlayerControl.ValidateTurnTiming;
begin end;

procedure TPlayerControl.ValidateDisconnectedPlayers;
begin end;

procedure TPlayerControl.PlayerDisconnected(A1: Integer);
begin end;

procedure TPlayerControl.ConnectionLost;
begin end;

class function TTurnPlayerControl.ClassID: Integer;
begin Result := 0; end;

procedure TTurnPlayerControl.Setup;
begin end;

procedure TTurnPlayerControl.NewDay;
begin end;

procedure TTurnPlayerControl.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TTurnPlayerControl.ReplayLogbook;
begin end;

procedure TTurnPlayerControl.SetSeatedPlayer(A1: Integer);
begin end;

procedure TTurnPlayerControl.ShowNewTurnCallBack;
begin end;

procedure TTurnPlayerControl.StartGameCallBack;
begin end;

procedure TTurnPlayerControl.EndTurn(A1: Integer; A2: Integer);
begin end;

procedure TTurnPlayerControl.DefaultStartMap;
begin end;

procedure TTurnPlayerControl.StartNewMap;
begin end;

procedure TTurnPlayerControl.StartLoadedMapEx;
begin end;

procedure TTurnPlayerControl.PasswordValidated;
begin end;

procedure TTurnPlayerControl.StartLoadedMap;
begin end;

procedure TTurnPlayerControl.GameOverEventHandled(A1: Integer);
begin end;

procedure TTurnPlayerControl.SetPlayerGameOverStatus(A1: Integer; A2: Integer);
begin end;

procedure TTurnPlayerControl.GameOver(A1: Integer; A2: Integer);
begin end;

procedure TTurnPlayerControl.ValidateTurnTiming;
begin end;

class function TPBEMPlayerControl.ClassID: Integer;
begin Result := 0; end;

procedure TPBEMPlayerControl.TerminateEmailGame;
begin end;

procedure TPBEMPlayerControl.TerminateEmailGameCallBack;
begin end;

procedure TPBEMPlayerControl.SendEmailGameAutomatedCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.SendEmailGameManualCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.SendEmailGameCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TPBEMPlayerControl.TriggerGameRestartedEvents(A1: Integer);
begin end;

procedure TPBEMPlayerControl.EndTurnGameSavedCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.EndTurn(A1: Integer; A2: Integer);
begin end;

procedure TPBEMPlayerControl.StartLoadedEmailGame;
begin end;

procedure TPBEMPlayerControl.ContinueRestartedGameCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.ContinueTurnDoneGameCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.ValidateLoadedMap;
begin end;

procedure TPBEMPlayerControl.PasswordValidated;
begin end;

procedure TPBEMPlayerControl.StartLoadedMap;
begin end;

procedure TPBEMPlayerControl.StartNewMap;
begin end;

procedure TPBEMPlayerControl.ExitGameSaveAsCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.ExitGame(A1: Byte);
begin end;

class function TSimultaniousPlayerControl.ClassID: Integer;
begin Result := 0; end;

procedure TSimultaniousPlayerControl.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TSimultaniousPlayerControl.Setup;
begin end;

procedure TSimultaniousPlayerControl.EndTurn(A1: Integer; A2: Integer);
begin end;

procedure TSimultaniousPlayerControl.NewDay;
begin end;

procedure TSimultaniousPlayerControl.StartGameCallBack;
begin end;

procedure TSimultaniousPlayerControl.StartNewMap;
begin end;

procedure TSimultaniousPlayerControl.StartLoadedMapEx;
begin end;

procedure TSimultaniousPlayerControl.PasswordValidated;
begin end;

procedure TSimultaniousPlayerControl.StartLoadedMap;
begin end;

procedure TSimultaniousPlayerControl.GameOverEventHandled(A1: Integer);
begin end;

procedure TSimultaniousPlayerControl.SetPlayerGameOverStatus(A1: Integer; A2: Integer);
begin end;

procedure TSimultaniousPlayerControl.ValidateTurnTiming;
begin end;

procedure TPlayerConnectionEventLog.Setup(A1: Byte; A2: Byte);
begin end;

procedure TPlayerConnectionEventLog.ExitSaveGameCallBack(A1: Integer);
begin end;

procedure TPlayerConnectionEventLog.Yes;
begin end;

procedure TPlayerConnectionEventLog.No;
begin end;

constructor TRaceResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TRaceResource.Destroy;
begin end;

function TRaceResource.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TRaceResource.GetFace;
begin end;

procedure TRaceResource.GetRaceIndex;
begin end;

procedure TRaceResource.LinkToIL;
begin end;

procedure TRaceResource.ReleaseIL;
begin end;

procedure TRaceResource.SetImageLibraryName(A1: Integer; A2: Integer);
begin end;

function TRaceResource.AddRef: Integer;
begin Result := 0; end;

function TRaceResource.Release: Integer;
begin Result := 0; end;

class function TRaceResource.ClassID: Integer;
begin Result := 0; end;

class function TRaceResource.ResourceEditName: string;
begin Result := ''; end;

function TRaceResource.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TRaceResource.SetCellImage(Value: ImageLib.TLibraryImage);
begin end;

procedure TRaceResource.GetCityImage(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRaceResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TRaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TRaceResource.GetAlignment: TAlignment;
begin Result := alNone; end;

constructor TRaceResourceList.Create(AOwner: Engine.TECustomNode);
begin end;

function TRaceResourceList.GetRaceResource(Index: Integer): TRaceResource;
begin
  if (Index < GetCount) and (Index >= 0) then
    Result := TRaceResource(FChildren.List^[Index])
  else Result := nil;
end;

procedure TRaceResourceList.GetMaxRaceIndex;
begin end;

constructor TFlagControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TFlagControl.Destroy;
begin end;

procedure TFlagControl.ShowFlag(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TFlagControl.ShowFlagEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TFlagControl.ShowStructureFlag(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TFlagControl.ShowStructureFlagEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

class function TProductionEventLog.ClassID: Integer;
begin Result := 0; end;

class function TUnitProduction.ClassID: Integer;
begin Result := 0; end;

procedure TUnitProduction.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TUnitProductionList.GetItem(Index: Integer): TUnitProduction;
begin end;

procedure TUnitProductionList.Add(UnitIndex: Integer; Researched: Boolean);
begin end;

procedure TUnitProductionList.IndexOf(A1: Integer);
begin end;

procedure TUnitProductionList.SortOnLevel;
begin end;

class function TProductionItem.ClassID: Integer;
begin Result := 0; end;

procedure TProductionItem.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TProductionItem.GetName(A1: Integer);
begin end;

procedure TProductionItem.GetNameProgressive(A1: Integer);
begin end;

function TProductionQueue.GetItem(Index: Integer): TProductionItem;
begin end;

procedure TProductionQueue.IndexOfID(A1: Integer);
begin end;

procedure TProductionQueue.IndexOf(A1: Integer; A2: Integer; A3: Integer);
begin end;

destructor TProductionSettings.Destroy;
begin end;

procedure TProductionSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TProductionSettings.Clear;
begin end;

destructor TProductionTE.Destroy;
begin end;

class function TProductionTE.ClassID: Integer;
begin Result := 0; end;

procedure TProductionTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TProductionTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TProductionControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TProductionControl.Destroy;
begin end;

procedure TProductionControl.BeginUpdate;
begin end;

procedure TProductionControl.EndUpdate;
begin end;

procedure TProductionControl.Update;
begin end;

procedure TProductionControl.Activate;
begin end;

procedure TProductionControl.Deactivate;
begin end;

procedure TProductionControl.GetProduceUnitLevelMax;
begin end;

procedure TProductionControl.GetResearchUnitLevelMax;
begin end;

procedure TProductionControl.CancelProductionReturnGold;
begin end;

procedure TProductionControl.CancelProductionReturnMana;
begin end;

procedure TProductionControl.GetQueueSizeMax;
begin end;

procedure TProductionControl.GetQueueLocked;
begin end;

procedure TProductionControl.ExecuteCancelProduction;
begin end;

procedure TProductionControl.RegisterGroupProduction;
begin end;

procedure TProductionControl.UnregisterGroupProduction;
begin end;

procedure TProductionControl.GroupProductionProduced(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.PlayerChanged;
begin end;

function TProductionControl.CanExecuteProduction(Item: TProductionItem; var Reason: string): Boolean;
begin end;

function TProductionControl.ExecuteProduction(Item: TProductionItem): Boolean;
begin end;

procedure TProductionControl.ExecuteAddProduction(A1: Integer);
begin end;

procedure TProductionControl.ExecuteDeleteProduction(A1: Integer);
begin end;

procedure TProductionControl.ExecuteDeleteProductions;
begin end;

procedure TProductionControl.ExecuteAIProduction(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.ExecuteAIResearch(A1: Integer);
begin end;

procedure TProductionControl.ExecuteProductionTE(A1: Integer);
begin end;

procedure TProductionControl.CreateProductionTE;
begin end;

function TProductionControl.UnitProduced: Boolean;
begin end;

function TProductionControl.CreateUnitProduction(A1: Integer): TUnit;
begin Result := nil; end;

function TProductionControl.UnitProductionGold(Index: Integer): Integer;
begin end;

function TProductionControl.UnitProductionGoldUpkeep(Index: Integer): Integer;
begin end;

function TProductionControl.UnitProductionMana(Index: Integer): Integer;
begin end;

function TProductionControl.UnitProductionManaUpkeep(Index: Integer): Integer;
begin end;

function TProductionControl.UnitProductionTime(Index: Integer): Integer;
begin end;

function TProductionControl.CanProduceUnit(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin end;

procedure TProductionControl.ProduceUnitEx(A1: Integer; A2: Integer);
begin end;

function TProductionControl.ProduceUnit(Index: Integer; Queue: Boolean): Boolean;
begin end;

procedure TProductionControl.UnitResearched;
begin end;

function TProductionControl.UnitResearchGold(Index: Integer): Integer;
begin end;

function TProductionControl.UnitResearchMana(Index: Integer): Integer;
begin end;

function TProductionControl.UnitResearchTime(Index: Integer): Integer;
begin end;

function TProductionControl.CanResearchUnit(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin end;

function TProductionControl.ResearchUnit(Index: Integer; Queue: Boolean): Boolean;
begin end;

function TProductionControl.Produce(Item: TProductionItem; Queue: Boolean): Boolean;
begin end;

procedure TProductionControl.DeleteProduction(A1: Integer);
begin end;

procedure TProductionControl.DeleteProductions;
begin end;

procedure TProductionControl.RetryProductionExecution(A1: Integer);
begin end;

procedure TProductionControl.SetLoopQueueTo(A1: Integer);
begin end;

procedure TProductionControl.GetLocation(var X, Y, L: Shortint);
begin end;

procedure TProductionControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TProductionControl.ProductionDone;
begin end;

procedure TProductionControl.NewTurn(Player: Shortint);
begin end;

function TProductionControl.LockQueueProduction(A1: Integer): Boolean;
begin Result := False; end;

function TProductionControl.LoopableProduction(A1: Integer): Boolean;
begin Result := False; end;

function TProductionControl.GetProductionName(Item: TProductionItem): string;
begin end;

function TProductionControl.GetProductionNameProgressive(Item: TProductionItem): string;
begin end;

procedure TProductionControl.FindOptimalResearchProduction(A1: Integer; A2: Integer);
begin end;

procedure TProductionControlList.GetPC(A1: Integer);
begin end;

destructor TStructureShadow.Destroy;
begin end;

procedure TStructureShadow.SetVisible(Value: Boolean);
begin end;

function TStructureShadow.GetVisible: Boolean;
begin Result := False; end;

procedure TStructureShadow.Connect;
begin end;

procedure TStructureShadow.Disconnect;
begin end;

function TStructureShadow.GetShowPriority: Integer;
begin Result := 0; end;

procedure TStructureShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TStructure.ClassID: Integer;
begin Result := 0; end;

constructor TStructure.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStructure.Destroy;
begin end;

procedure TStructure.BeginUpdate;
begin end;

procedure TStructure.EndUpdate;
begin end;

procedure TStructure.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStructure.ExecuteAI(A1: Integer; A2: Integer);
begin end;

procedure TStructure.UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer);
begin end;

function TStructure.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

procedure TStructure.UpdateRoads(A1: Integer);
begin end;

procedure TStructure.GetPlayer;
begin end;

function TStructure.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TStructure.RemoveFromMap;
begin end;

procedure TStructure.CreateShadow;
begin end;

procedure TStructure.DestroyShadow;
begin end;

procedure TStructure.Update;
begin end;

function TStructure.CreateTE: TStructureTE;
begin Result := nil; end;

procedure TStructure.SetupTE(A1: TStructureTE);
begin end;

function TStructure.ExecuteTE(A1: TStructureTE): TExecuteResult;
begin Result := erRetry; end;

function TStructure.ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin Result := 0; end;

function TStructure.GetName: string;
begin end;

function TStructure.GetCurrentActivityText: string;
begin end;

procedure TStructure.GetDescription;
begin end;

function TStructure.CanDblClick: Boolean;
begin end;

function TStructure.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TStructure.PlaySelectSample;
begin end;

procedure TStructure.Select;
begin end;

procedure TStructure.Unselect;
begin end;

procedure TStructure.FogChanged;
begin end;

function TStructure.GetTopBorderImage: TLibraryImage;
begin Result := nil; end;

function TStructure.GetMiddleBorderImage: TLibraryImage;
begin Result := nil; end;

function TStructure.GetBottomBorderImage: TLibraryImage;
begin Result := nil; end;

function TStructure.GetOverlay(Index: Integer): Shortint;
begin Result := 0; end;

function TStructure.GetTerrain(Index: Integer): ShortInt;
begin Result := 0; end;

function TStructure.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin Result := False; end;

function TStructure.ValidTerrainType(TerrainType: Integer): Boolean;
begin Result := False; end;

procedure TStructure.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

function TStructure.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

function TStructure.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

procedure TStructure.GetRazeable;
begin end;

function TStructure.GetRazed: Boolean;
begin end;

procedure TStructure.SetRazed(Value: Boolean);
begin end;

procedure TStructure.VisibleForPlayer(A1: Byte);
begin end;

procedure TStructure.ValidateObservation(A1: Byte);
begin end;

procedure TStructure.ExecuteRebuild(A1: Integer);
begin end;

procedure TStructure.ExecuteBuild(A1: Integer; A2: Byte);
begin end;

function TStructure.GetBuilding: Boolean;
begin end;

procedure TStructure.BuildingDone;
begin end;

procedure TStructure.GetRebuildInfo(A1: Integer; A2: Integer);
begin end;

procedure TStructure.CanRebuild(A1: Integer; A2: Integer);
begin end;

procedure TStructure.Rebuild(A1: Integer);
begin end;

procedure TStructure.NewDay;
begin end;

procedure TStructure.NewTurn(Player: Shortint);
begin end;

procedure TStructure.ArmyPlaced(A1: Integer);
begin end;

procedure TStructure.ArmyRemoved;
begin end;

procedure TStructure.ArmyChanged;
begin end;

procedure TStructure.SeatedPlayerChanged;
begin end;

procedure TStructure.GetDefensePriority;
begin end;

procedure TStructure.GetDefenseRequirements(A1: Integer; A2: Integer);
begin end;

procedure TStructure.ListUnits(A1: Integer);
begin end;

procedure TStructure.ListArmies(A1: TArmyHSList);
begin end;

function TStructure.ValidateMap(A1: Integer): Boolean;
begin Result := False; end;

procedure TStructure.MainValidateMap(A1: Integer);
begin end;

procedure TStructure.Activate;
begin end;

procedure TStructure.Deactivate;
begin end;

procedure TStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TStructure.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TStructure.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TStructure.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TStructure.ShowBorderImage(A1: Integer; A2: Integer);
begin end;

procedure TStructure.ShowBorderImageDC(A1: Integer; A2: Integer);
begin end;

procedure TStructure.CanRaze(A1: Byte; A2: Integer);
begin end;

procedure TStructure.GenerateRazeDefenders(A1: Integer; A2: Integer);
begin end;

procedure TStructure.SetupRazeDefenderAG(A1: Integer; A2: Integer);
begin end;

procedure TStructure.PlaceRazeDefenders(A1: Byte);
begin end;

procedure TStructure.ShowRazeAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TStructure.ExecuteRaze(A1: Integer; A2: Integer);
begin end;

procedure TStructure.RazeEx(A1: Integer);
begin end;

procedure TStructure.Raze(A1: Integer);
begin end;

procedure TStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

constructor TStructureResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStructureResource.Destroy;
begin end;

class function TStructureResource.ClassID: Integer;
begin Result := 0; end;

class function TStructureResource.ResourceEditName: string;
begin Result := ''; end;

function TStructureResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TStructureResource.CalculatePadIndex;
begin end;

procedure TStructureResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStructureResource.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TPlayerStructure.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerStructure.Destroy;
begin end;

class function TPlayerStructure.ClassID: Integer;
begin Result := 0; end;

procedure TPlayerStructure.GetVictoryLocation(A1: Byte);
begin end;

procedure TPlayerStructure.SetVictoryLocation(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.RegisterVictoryLocations;
begin end;

procedure TPlayerStructure.UnregisterVictoryLocations;
begin end;

procedure TPlayerStructure.BuildingDone;
begin end;

procedure TPlayerStructure.CanRebuild(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.ExecuteRebuild(A1: Integer);
begin end;

procedure TPlayerStructure.ExecuteBuild(A1: Integer; A2: Byte);
begin end;

procedure TPlayerStructure.UpdatePlayer;
begin end;

procedure TPlayerStructure.NewTurn(Player: Shortint);
begin end;

procedure TPlayerStructure.NewDay;
begin end;

procedure TPlayerStructure.StructureCaptured(OldPlayer, NewPlayer: Shortint);
begin end;

procedure TPlayerStructure.GetCombatEventText(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.FinalizeCombat(A1: Integer);
begin end;

procedure TPlayerStructure.SetPlayer(Player: Shortint);
begin end;

procedure TPlayerStructure.UpdateFlagID;
begin end;

procedure TPlayerStructure.ArmyPlaced(A1: Integer);
begin end;

procedure TPlayerStructure.ArmyChanged;
begin end;

function TPlayerStructure.GetIncome: Integer;
begin end;

function TPlayerStructure.GetPower: Integer;
begin end;

procedure TPlayerStructure.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayerStructure.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TPlayerStructure.TrueVisionRange;
begin end;

function TPlayerStructure.VisibilityRange: Integer;
begin Result := 0; end;

procedure TPlayerStructure.UpdatePlayerSeen;
begin end;

procedure TPlayerStructure.UpdateExploration;
begin end;

procedure TPlayerStructure.UpdateUnfog;
begin end;

procedure TPlayerStructure.SeatedPlayerChanged;
begin end;

procedure TPlayerStructure.Activate;
begin end;

procedure TPlayerStructure.Deactivate;
begin end;

procedure TPlayerStructure.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

function TPlayerStructure.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TPlayerStructure.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TPlayerStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

function TPlayerStructure.GetDefaultAITargetPriority: Integer;
begin Result := 0; end;

procedure TPlayerStructure.UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer);
begin end;

procedure TPlayerStructure.GetMoveAction(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

constructor TPlayerStructureResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerStructureResource.Destroy;
begin end;

class function TPlayerStructureResource.ClassID: Integer;
begin Result := 0; end;

function TPlayerStructureResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TPlayerStructureResource.GenerateFlagPositions;
begin end;

procedure TPlayerStructureResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayerStructureResource.ActivateMsg;
begin end;

procedure TPlayerStructureResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

function TPlayerStructureResource.PlaceResourceUser(HSMap: HSEngine.THSMap; Xhx, Yhx, Lhx: Shortint): HSEngine.TMapObject;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TPlayerStructureIncomeSource.Setup(Structure: TPlayerStructure);
begin end;

function TPlayerStructureIncomeSource.Name: string;
begin Result := ''; end;

function TPlayerStructureIncomeSource.Income: Integer;
begin Result := 0; end;

procedure TPlayerStructureIncomeSource.GetLocation(var X, Y, L: Shortint);
begin end;

procedure TPlayerStructurePowerSource.Setup(Structure: TPlayerStructure);
begin end;

procedure TPlayerStructurePowerSource.Name(A1: Integer);
begin end;

procedure TPlayerStructurePowerSource.Power;
begin end;

procedure TPlayerStructurePowerSource.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPlayerStructurePowerSource.Select(A1: Integer; A2: Integer);
begin end;

class function TStructureTE.ClassID: Integer;
begin Result := 0; end;

procedure TStructureTE.Initialize(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TStructureTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStructureTE.Validate;
begin end;

function TStructureTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TRazeStructureEventLog.Yes;
begin end;

class function TConstructStructureTE.ClassID: Integer;
begin Result := 0; end;

procedure TConstructStructureTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TConstructStructureTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

function TStructureConstructionControl.StructureResource(AUnit: TAbstractUnit): TStructureResource;
{ conflict: function TStructureConstructionControl.StructureResource: TStructureResource; }
begin Result := nil; end;

function TStructureConstructionControl.ValidateLocation(AUnit: TAbstractUnit; var Reason: string): Boolean;
begin Result := False; end;

function TStructureConstructionControl.CanConstruct(A1: TAbstractUnit; var A2: string): Boolean;
begin Result := False; end;

procedure TStructureConstructionControl.Construct(A1: Integer);
begin end;

constructor TStructureControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStructureControl.Destroy;
begin end;

procedure TStructureControl.GetStructure(A1: Integer);
begin end;

procedure TStructureControl.GetCount;
begin end;

procedure TStructureControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStructureControl.CreateUniqueID;
begin end;

procedure TStructureControl.IndexOfID(A1: Integer);
begin end;

procedure TStructureControl.FindID;
begin end;

procedure TStructureControl.Register(A1: Integer);
begin end;

procedure TStructureControl.Unregister(A1: Integer);
begin end;

procedure TStructureControl.Activate;
begin end;

constructor TStructureAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStructureAIPA.Destroy;
begin end;

function TStructureAIPA.Activate: Boolean;
begin Result := False; end;

function TStructureAIPA.Process: Boolean;
begin Result := False; end;

constructor TStructurePhase1AIPA.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStructurePhase1AIPA.Priority;
begin end;

constructor TStructurePhase2AIPA.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStructurePhase2AIPA.Priority;
begin end;

constructor TFire.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFire.ClassID: Integer;
begin Result := 0; end;

procedure TFire.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TFire.GetTerrain(Index: Integer): ShortInt;
begin Result := 0; end;

function TFire.GetShowPriority: Integer;
begin Result := 0; end;

procedure TFire.CalcShowPriority(A1: Integer);
begin end;

function TFire.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

function TFire.GetMostFrequentMapFieldTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx, Default: Shortint): Shortint;
begin Result := 0; end;

procedure TFire.Connect;
begin end;

function TFire.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TFire.RemoveFromMap;
begin end;

function TFire.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

procedure TFire.SetupExplosion(A1: Integer);
begin end;

procedure TFire.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

procedure TFire.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TFire.TriggerDamage;
begin end;

procedure TFire.CanDoDamage(A1: Integer);
begin end;

procedure TFire.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

function TFire.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TFire.ArmyPlaced(A1: Integer);
begin end;

procedure TFire.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TFire.NewTurn;
begin end;

procedure TFire.NewTurnDone;
begin end;

procedure TFire.WaterMasteryCast;
begin end;

procedure TFire.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

destructor TFireResource.Destroy;
begin end;

class function TFireResource.ResourceEditName: string;
begin Result := ''; end;

class function TFireResource.ClassID: Integer;
begin Result := 0; end;

function TFireResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TFireResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFireResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TFireControl.Create;
begin end;

destructor TFireControl.Destroy;
begin end;

procedure TFireControl.GetRndFireResource(A1: Byte; A2: Integer);
begin end;

function TFireControl.PlaceFire(A1: Integer; A2: Integer; A3: Integer; A4: Boolean): TFire;
begin Result := nil; end;

procedure TFireControl.RegisterFireResource;
begin end;

procedure TFireControl.UnregisterFireResource;
begin end;

constructor TTargetSelectionControl.Create;
begin end;

destructor TTargetSelectionControl.Destroy;
begin end;

procedure TTargetSelectionControl.TriggerOnChangeEvent(A1: Byte);
begin end;

procedure TTargetSelectionControl.DeselectHS;
begin end;

procedure TTargetSelectionControl.MouseDownEvent;
begin end;

procedure TTargetSelectionControl.ValidTarget(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTargetSelectionControl.NewFrameEvent;
begin end;

procedure TTargetSelectionControl.MouseMoveEvent;
begin end;

procedure TTargetSelectionControl.ShowSelection(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTargetSelectionControl.Initialize(A1: TAbstractUnit);
begin end;

procedure TTargetSelectionControl.Activate;
begin end;

procedure TTargetSelectionControl.Deactivate;
begin end;

procedure TTargetSelectionControl.UnitChanged(A1: Integer);
begin end;

function TMovepath.MovePointsToPos(A1: Integer): Integer;
begin Result := 0; end;

procedure TMovepath.PosToMovePoints(A1: Integer);
begin end;

procedure TMovepath.GetMovePoints;
begin end;

constructor TMoveSettings.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMoveSettings.Destroy;
begin end;

procedure TMoveSettings.GetMoveLoc(A1: Integer; A2: Integer);
begin end;

procedure TMoveSettings.GetMovePrio;
begin end;

procedure TMoveSettingsList.GetMoveSettings(A1: Integer);
begin end;

procedure TMoveSettingsList.GetNoneValidMove;
begin end;

procedure TMoveSettingsList.IndexOfMoveObject(A1: Integer);
begin end;

procedure TMoveSettingsList.CalculateMovePositions(A1: Integer; A2: Integer);
begin end;

constructor TMoveSelector.Create;
begin end;

destructor TMoveSelector.Destroy;
begin end;

function TMoveSelector.CreateMCS: Integer;
begin Result := 0; end;

procedure TMoveSelector.Clear;
begin end;

procedure TMoveSelector.SetCurrentMove(A1: Integer);
begin end;

procedure TMoveSelector.Unselect(A1: Integer; A2: Integer);
begin end;

procedure TMoveSelector.ValidateSelection(A1: Integer);
begin end;

procedure TMoveSelector.ExecuteMove;
begin end;

procedure TMoveSelector.AddMoveObject(A1: Integer);
begin end;

procedure TMoveSelector.DeleteMoveObject(A1: Integer);
begin end;

procedure TMoveSelector.DeleteMoves;
begin end;

procedure TMoveSelector.UpdateMoveCursor;
begin end;

procedure TMoveSelector.MouseMoveEvent;
begin end;

procedure TMoveSelector.CalculateMovePath(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TMoveSelector.SelectPath(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TMoveSelector.MouseDownEvent(A1: Integer);
begin end;

procedure TMoveSelector.Activate(A1: Integer);
begin end;

procedure TMoveSelector.Deactivate;
begin end;

procedure TMoveSelector.ShowMovePaths(A1: Integer);
begin end;

constructor TTextControlItem.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TTextControlItem.Destroy;
begin end;

class function TTextControlItem.ClassID: Integer;
begin Result := 0; end;

procedure TTextControlItem.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTextControl.GetItem(A1: Integer);
begin end;

procedure TTextControl.Delete(A1: Integer);
begin end;

procedure TTextControl.New;
begin end;

procedure TTextControl.FindID(A1: Integer);
begin end;

procedure TTextControl.Sort;
begin end;

procedure TTextControl.IndexOf;
begin end;

procedure TTextControl.RetrieveText(ID: Integer; Text: TStrings);
begin end;

class function TFrozenWaterHS.ClassID: Integer;
begin Result := 0; end;

function TFrozenWaterHS.GetLevel: Byte;
begin Result := 0; end;

procedure TFrozenWaterHS.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFrozenWaterHS.MeltIce;
begin end;

procedure TFrozenWaterHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

procedure TFrozenWaterHS.NewTurn(A1: Byte);
begin end;

procedure TFrozenWaterHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TFrozenWaterHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TTutorialControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TTutorialControl.Destroy;
begin end;

procedure TTutorialControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTutorialControl.ShowMessage(A1: Integer; A2: Byte; A3: Integer);
begin end;

class function TAoWMapField.ClassID: Integer;
begin Result := 0; end;

function TAoWMapField.GetExplored(A1: Integer): Boolean;
begin Result := False; end;

procedure TAoWMapField.SetExplored(A1: Integer; A2: Integer);
begin end;

procedure TAoWMapField.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWMapField.FogChanged;
begin end;

procedure TAoWMapField.SetFogCount(A1: Byte);
begin end;

procedure TAoWMapField.UpdateMapField;
begin end;

function TAoWMapField.GetPlayer: Shortint;
begin Result := 0; end;

procedure TAoWMapField.GetScannerIcon;
begin end;

procedure TAoWMapField.GetCombatTerrainTag;
begin end;

procedure TAoWMapField.GetConcealmentActive;
begin end;

function TAoWMapField.GetMagicShieldActive: Boolean;
begin Result := False; end;

procedure TAoWMapField.GetProductionControl;
begin end;

procedure TAoWMapField.GetAITarget(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TAoWMapField.GetMoveAction(A1: Byte): TMoveAction;
begin Result := maNormal; end;

procedure TAoWMapField.GetIndependentRelation;
begin end;

procedure TAoWMapField.GetDefensePriority;
begin end;

procedure TAoWMapField.GetDefenseRequirements(A1: Integer; A2: Integer);
begin end;

procedure TAoWMapField.GetWallType;
begin end;

function TAoWMapField.GetArmyHS: TArmyHS;
begin Result := nil; end;

procedure TAoWMapField.RestoreTerrain;
begin end;

class function TAoWMapLevel.ClassID: Integer;
begin Result := 0; end;

function TAoWMapLevel.MapFieldClass: Engine.TEObjectClass;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAoWMapLevel.FogArea(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWMapLevel.UnFogArea(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWMapLevel.UnFogExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWMapLevel.ExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWMapLevel.ResetFog;
begin end;

procedure TAoWMapLevel.ResetUnFog;
begin end;

procedure TAoWMapLevel.Reset;
begin end;

constructor TAbstractAoWHSMap.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAbstractAoWHSMap.Destroy;
begin end;

function TAbstractAoWHSMap.CreateMouse: HSEngine.THSMapMouse;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAbstractAoWHSMap.SetFogEnabled(A1: Byte);
begin end;

procedure TAbstractAoWHSMap.SetExplorationEnabled(A1: Byte);
begin end;

procedure TAbstractAoWHSMap.PlayCenterAnimation(X, Y, L: Shortint);
begin end;

procedure TAbstractAoWHSMap.LockMapChangedEvent;
begin end;

procedure TAbstractAoWHSMap.UnlockMapChangedEvent;
begin end;

procedure TAbstractAoWHSMap.TriggerTerrainChangedEvent(const R: Windows.TRect; L: Shortint);
begin end;

procedure TAbstractAoWHSMap.MapChanged(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.MapChangedRad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbstractAoWHSMap.InvalidateMap;
begin end;

procedure TAbstractAoWHSMap.TriggerMapChangedEvent(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMap.LockScannerIconsChangedEvent;
begin end;

procedure TAbstractAoWHSMap.UnlockScannerIconsChangedEvent;
begin end;

procedure TAbstractAoWHSMap.ScannerIconsChanged(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMap.ScannerIconsChangedRad(Xhx, Yhx, Lhx, Radius: Integer);
begin end;

procedure TAbstractAoWHSMap.InvalidateScannerIcons;
begin end;

procedure TAbstractAoWHSMap.TriggerScannerIconsChangedEvent(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMap.UpdateShowMessage;
begin end;

procedure TAbstractAoWHSMap.ShowWarning(const Text: string);
begin end;

procedure TAbstractAoWHSMap.ShowMessage(const A1: string);
begin end;

procedure TAbstractAoWHSMap.SetSeatedPlayer(A1: Byte);
begin end;

procedure TAbstractAoWHSMap.SetCurrentPlayer(A1: Byte);
begin end;

procedure TAbstractAoWHSMap.FogArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbstractAoWHSMap.UnFogArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbstractAoWHSMap.ExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAbstractAoWHSMap.UnFogExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAbstractAoWHSMap.DrawGrid(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.DrawFog(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.ShowHexagonSelector;
begin end;

procedure TAbstractAoWHSMap.HideHexagonSelector;
begin end;

procedure TAbstractAoWHSMap.ShowBackHexagonSelector(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractAoWHSMap.ShowFrontHexagonSelector(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractAoWHSMap.UpdateHexagonSelector;
begin end;

procedure TAbstractAoWHSMap.UpdateStaticScene;
begin end;

procedure TAbstractAoWHSMap.UpdateDynamicScene;
begin end;

procedure TAbstractAoWHSMap.NewFrame;
begin end;

procedure TAbstractAoWHSMap.UpdateFPS(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.DropHeroItem(A1: Integer; A2: Integer);
begin end;

function TAbstractAoWHSMap.GetHeroItemsOnGround(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TAbstractAoWHSMap.DrawSelectionRect(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TAbstractAoWCombatMap.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAbstractAoWCombatMap.Destroy;
begin end;

procedure TAoWNewHSMapSettings.Create(A1: Byte);
begin end;

procedure TAoWHSMapKeyboard.Lock;
begin end;

procedure TAoWHSMapKeyboard.Unlock;
begin end;

procedure TAoWHSMapKeyboard.RunDefaultTest;
begin end;

procedure TAoWHSMapKeyboard.KeyDown(A1: Integer; A2: Byte);
begin end;

procedure TAbstractAoWHSMapMouse.Create(A1: Byte);
begin end;

destructor TAbstractAoWHSMapMouse.Destroy;
begin end;

procedure TAbstractAoWHSMapMouse.ResetRectangleSelection;
begin end;

procedure TAbstractAoWHSMapMouse.GetSelectingRectangle;
begin end;

procedure TAbstractAoWHSMapMouse.StartRectangleSelection(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.UpdateRectangleSelection(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.StopRectangleSelection(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.Move(Shift: Classes.TShiftState; X, Y: Integer);
begin end;

function TAoWHSMapMouse.GetCursor: Integer;
begin Result := 0; end;

procedure TAoWHSMapMouse.Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWHSMapMouse.Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWHSMapMouse.Move(Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWHSMapMouse.DblClick;
begin end;

constructor TStartupSongList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStartupSongList.OriginalSongsChanged;
begin end;

constructor TAoWHSMap.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAoWHSMap.Destroy;
begin end;

procedure TAoWHSMap.StartTokenEventLogging;
begin end;

procedure TAoWHSMap.StopTokenEventLogging;
begin end;

procedure TAoWHSMap.SynchroniseBegin;
begin end;

procedure TAoWHSMap.SynchroniseEnd;
begin end;

procedure TAoWHSMap.GetSynchronised;
begin end;

procedure TAoWHSMap.OnExecuteTokenEvent(A1: Integer);
begin end;

procedure TAoWHSMap.PlayerDisconnected;
begin end;

procedure TAoWHSMap.PlayerConnectionLost;
begin end;

procedure TAoWHSMap.OnTokenManagerMessage(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.GetIndependentAIMode;
begin end;

procedure TAoWHSMap.SaveGame(A1: Integer);
begin end;

function TAoWHSMap.CreateMouse: HSEngine.THSMapMouse;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAoWHSMap.SetSeatedPlayer(A1: Byte);
begin end;

function TAoWHSMap.TerrainVisible(A1: Shortint; A2: Shortint; A3: Shortint; A4: Integer): Boolean;
begin Result := False; end;

function TAoWHSMap.Visible(X, Y, L: Shortint; Mode: Integer): Boolean;
begin Result := False; end;

function TAoWHSMap.WatchingTerrain(A1: Shortint; A2: Shortint; A3: Shortint; A4: Integer): Boolean;
begin Result := False; end;

function TAoWHSMap.Watching(A1: Shortint; A2: Shortint; A3: Shortint; A4: Integer): Boolean;
begin Result := False; end;

procedure TAoWHSMap.ValidateTerrainObservation(A1: Byte; A2: Shortint; A3: Shortint; A4: Shortint; A5: Integer);
begin end;

procedure TAoWHSMap.ValidateObservation(A1: Byte; A2: Shortint; A3: Shortint; A4: Shortint; A5: Integer);
begin end;

procedure TAoWHSMap.UnlockGameOverEventCallBack;
begin end;

procedure TAoWHSMap.SelectNextHero;
begin end;

procedure TAoWHSMap.SelectNextArmy;
begin end;

procedure TAoWHSMap.SelectPrevArmy;
begin end;

procedure TAoWHSMap.SeatedPlayerChanged;
begin end;

procedure TAoWHSMap.BeginUnitUpdate;
begin end;

procedure TAoWHSMap.EndUnitUpdate;
begin end;

procedure TAoWHSMap.UnitChanged;
begin end;

procedure TAoWHSMap.UnitDestroyed;
begin end;

procedure TAoWHSMap.BeginArmyUpdate;
begin end;

procedure TAoWHSMap.EndArmyUpdate;
begin end;

procedure TAoWHSMap.ArmyChanged;
begin end;

procedure TAoWHSMap.ArmyDestroyed;
begin end;

procedure TAoWHSMap.BeginStructureUpdate;
begin end;

procedure TAoWHSMap.EndStructureUpdate;
begin end;

procedure TAoWHSMap.StructureChanged;
begin end;

procedure TAoWHSMap.StructureDestroyed;
begin end;

procedure TAoWHSMap.TriggerCombatEvent;
begin end;

procedure TAoWHSMap.TriggerGameTerminatedEvent;
begin end;

procedure TAoWHSMap.ExecuteExitGame;
begin end;

procedure TAoWHSMap.ExitGame(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.TriggerEndTurnEvent(A1: Byte);
begin end;

procedure TAoWHSMap.ClearExecuteEventLogBuffer;
begin end;

procedure TAoWHSMap.ExecuteNextEventLog;
begin end;

procedure TAoWHSMap.SetExecuteEventLogDelay(A1: Integer);
begin end;

procedure TAoWHSMap.UpdateExecuteEventLogDelay;
begin end;

procedure TAoWHSMap.ExecuteEventLogDone(A1: Integer);
begin end;

procedure TAoWHSMap.LockExecuteEventLog;
begin end;

procedure TAoWHSMap.UnlockExecuteEventLog;
begin end;

procedure TAoWHSMap.TriggerExecuteEventLog(Log: TEventLog; Immediate: Boolean; Done: TExecuteDoneEvent);
begin end;

procedure TAoWHSMap.TriggerPlayerTerminatedEvent;
begin end;

procedure TAoWHSMap.GameOverEventHandled;
begin end;

procedure TAoWHSMap.ExecuteGameOverEvent(Event: TGameOverEventLog);
begin end;

procedure TAoWHSMap.UnlockGameOverEvent;
begin end;

procedure TAoWHSMap.LockGameOverEvent;
begin end;

procedure TAoWHSMap.GameOver(Player: Shortint; Status: TGameOverStatus);
begin end;

procedure TAoWHSMap.VerifyAddOnPacks;
begin end;

procedure TAoWHSMap.ValidateMap(A1: Integer);
begin end;

procedure TAoWHSMap.OnStreamError(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.NotifyProgress(const Progress: HSEngine.TMapProgress);
begin end;

procedure TAoWHSMap.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWHSMap.MainReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function TAoWHSMap.ClassID: Integer;
begin Result := 0; end;

procedure TAoWHSMap.InitializeMapLevel(A1: Byte);
begin end;

procedure TAoWHSMap.InitializeNewMap;
begin end;

function TAoWHSMap.AddMapLevel: Boolean;
begin Result := False; end;

function TAoWHSMap.CreateNewMap(Settings: HSEngine.TNewHSMapSettings): Boolean;
begin Result := False; end;

procedure TAoWHSMap.NotifyPlayerChangedEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.UpdatePlayerSeen(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TAoWHSMap.NotifyPlayerChanged(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TAoWHSMap.VisibleForPlayer(X, Y, Level: Integer; Player: Shortint): Boolean;
begin Result := False; { draft body } end;

procedure TAoWHSMap.FoggedForPlayer(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.MouseMoved;
begin end;

procedure TAoWHSMap.UpdateCursor;
begin end;

procedure TAoWHSMap.ResetSeatedPlayerView(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.Select(A1: TArmyHS; A2: Boolean);
begin end;

procedure TAoWHSMap.PlayerChanged;
begin end;

procedure TAoWHSMap.TokenControlActivatedEvent;
begin end;

procedure TAoWHSMap.NewFrame;
begin end;

procedure TAoWHSMap.StartNewMap;
begin end;

procedure TAoWHSMap.StartLoadedMap;
begin end;

procedure TAoWHSMap.SetupPlayerControl(Mode: TPlayMode; Connection: TPlayerConnectionType);
begin end;

procedure TAoWHSMap.Activate;
begin end;

procedure TAoWHSMap.ActivateMsg;
begin end;

function TAoWHSMap.Random(Range: Integer): Integer;
begin Result := 0; end;

procedure TAoWHSMap.GenerateNewTurnOrder;
begin end;

procedure TAoWHSMap.EndTurn;
begin end;

procedure TAoWHSMap.CancelEndTurn;
begin end;

procedure TAoWHSMap.LockUpdateVisibility;
begin end;

procedure TAoWHSMap.UnLockUpdateVisibility;
begin end;

procedure TAoWHSMap.UpdateVisibility;
begin end;

procedure TAoWHSMap.ResetMapLevels;
begin end;

procedure TAoWHSMap.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAoWHSMap.SendMsg(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAoWHSMap.ExecuteNegotiateMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAoWHSMap.InitializeCombatMap(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.ReleaseCombatMap;
begin end;

function TAoWHSMap.CreateCombat(A1: Integer): TCombat;
begin Result := nil; end;

procedure TAoWHSMap.ShowSeatedPlayerCallBack;
begin end;

procedure TAoWHSMap.DestroyCombat;
begin end;

procedure TAoWHSMap.DrawDynamicScene(var SD: GFXE.TSurfaceDesc);
begin end;

procedure TAoWHSMap.RetrieveBattleFieldInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAoWHSMap.TriggerRelationsChanged;
begin end;

procedure TAoWHSMap.LockRelationsChanged;
begin end;

procedure TAoWHSMap.UnlockRelationsChanged;
begin end;

procedure TAoWHSMap.UpdateTurnTimeBeep;
begin end;

procedure TAoWHSMap.ResetTurnTimer;
begin end;

function TAoWHSMap.GetTurnTimeLeft: Integer;
begin Result := 0; end;

function TAoWHSMap.GetTurnTimerEnabled: Boolean;
begin Result := False; end;

procedure TAoWHSMap.EnableTurnTimer;
begin end;

procedure TAoWHSMap.DisableTurnTimer;
begin end;

procedure TAoWHSMap.ZeroTurnTimer;
begin end;

function TAoWHSMap.ChangeTerrain(MO: HSEngine.TMapObject; X, Y, L, Radius, TerrainType: Integer): Integer;
begin Result := 0; end;

function TAoWHSMap.ChangeTerrainEx(MO: HSEngine.TMapObject; X, Y, L, Radius: Integer; ChangeTerrainProc: HSEngine.TChangeTerrainProc; TerrainChangedProc: HSEngine.TTerrainChangedProc): Integer;
begin Result := 0; end;

procedure TAoWHSMap.CenterOnLeader(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWHSMap.PlaceTerrain(A1: Shortint; A2: Shortint; A3: Shortint; A4: Shortint; A5: Shortint);
begin end;

procedure TAoWHSMap.UpdateEffects;
begin end;

procedure TAoWHSMap.AddEffect(A1: Integer);
begin end;

function TranslateRStr(const S: string): string;
begin
  if AoWEngine <> nil then
  begin
    Result := AoWEngine.TranslateRStr(S);
    Exit;
  end;
  Result := S;
end;

function HitRole(AttackDefense: Integer): Boolean;
begin
  AttackDefense := AttackDefense * 10 + 50;
  if AttackDefense < 10 then AttackDefense := 10;
  if AttackDefense > 90 then AttackDefense := 90;
  Result := Random(100) < AttackDefense;
end;

function HitRoleProbability(AttackDefense: Integer): Single;
var
  Chance: Integer;
begin
  Chance := AttackDefense * 10 + 50;
  if Chance < 10 then Chance := 10;
  if Chance > 90 then Chance := 90;
  Result := Chance / 100;
end;

function DMmaxDCtoDV(Damage, AttackDefense, Maximum: Integer): Integer;
begin
  if Damage > 0 then
  begin
    Result := DMDCtoDV(Damage, AttackDefense);
    { Original updates only the unused Maximum parameter, leaving Result uncapped. }
    if Damage > Maximum then Maximum := Damage;
  end
  else Result := 0;
end;

function DMDCtoDV(Damage, AttackDefense: Integer): Integer;
var
  Threshold: Integer;
begin
  if Damage > 0 then
  begin
    Threshold := 10 - AttackDefense * 2;
    if Threshold > 18 then Result := Damage
    else if Threshold >= 0 then
    begin
      Result := ((Damage - 1) * (18 - Threshold) + 1) shr 1 +
        (Damage + (18 - Threshold));
      if Threshold <> 0 then Inc(Result);
    end
    else
    begin
      Result := Damage + 1 + (18 - Threshold) +
        (((Damage - 1) * (18 - Threshold) + 1) shr 1);
      Threshold := -Threshold;
      Inc(Threshold, ((((Damage - 1) * Threshold * Threshold + (Threshold + 19)) div
        (Threshold + 19)) shr 1) + 1);
      Result := Result - Threshold;
    end;
    Result := Result * 5;
  end
  else Result := 0;
end;

function ExecuteDamageRole(Damage, AttackDefense: Integer): Integer;
var
  Roll: Integer;
begin
  if Damage > 0 then
  begin
    Roll := Random(20);
    if Roll <= 1 then Result := 0
    else if Roll >= 18 then Result := Damage
    else
    begin
      AttackDefense := 10 - AttackDefense * 2;
      if (Roll >= AttackDefense) and (AttackDefense < 18) then
        Result := ((Damage - 1) * (Roll - AttackDefense) +
          ((18 - AttackDefense) shr 1)) div (18 - AttackDefense) + 1
      else Result := 0;
    end;
  end
  else Result := 0;
end;

function DVtoDEV(SourceDV, TargetDV: Integer; Source, Target: TCombatObject): Integer;
begin
  if Target.GetTargetPriority <> 0 then
  begin
    Result := Target.GetTargetPriority +
      Round(Target.GetTargetPriority * (SourceDV / (Target.GetHitPoints * 100)));
    if TargetDV <> 0 then
      Result := Result - (Source.GetTargetPriority +
        Round(Source.GetTargetPriority * (TargetDV / (Source.GetHitPoints * 100))));
  end
  else Result := SourceDV + (-99999) - Source.GetTargetPriority * TargetDV;
end;

function StatisticsToMaxDamage(Damage: Integer; DamageTypes, ImmunityTypes, ProtectionTypes: TDamageTypes): Integer;
begin
  DamageTypes := DamageTypes - ImmunityTypes;
  if DamageTypes <> [] then
  begin
    if DamageTypes - ProtectionTypes = [] then
      Result := (Damage + 1) shr 1
    else Result := Damage;
  end
  else Result := 0;
end;

function StatisticsToDV(Attack, Damage: Integer; DamageTypes: TDamageTypes; Defense, Resistance: Integer; ImmunityTypes, ProtectionTypes: TDamageTypes): Integer;
begin
  DamageTypes := DamageTypes - ImmunityTypes;
  if DamageTypes <> [] then
  begin
    Attack := Attack - Defense;
    if DamageTypes - ProtectionTypes = [] then Damage := (Damage + 1) shr 1;
    Result := DMDCtoDV(Damage, Attack);
  end
  else Result := 0;
end;

function StatisticsToLimitedDV(Attack, Damage: Integer; DamageTypes: TDamageTypes; Maximum, Defense, Resistance: Integer; ImmunityTypes, ProtectionTypes: TDamageTypes): Integer;
var
  Limit: Integer;
begin
  Limit := Maximum;
  DamageTypes := DamageTypes - ImmunityTypes;
  if DamageTypes <> [] then
  begin
    Attack := Attack - Defense;
    if DamageTypes - ProtectionTypes = [] then Damage := (Damage + 1) shr 1;
    Result := DMmaxDCtoDV(Damage, Attack, Limit);
    if Limit * 100 < Result then Result := Limit * 100;
  end
  else Result := 0;
end;

procedure DistributeCombatEvent(Logbook: TCombatLogbook; Execute: Boolean);
var
  Data: TCombatData;
  I: Integer;
  Event: TCombatEventLog;
begin
  Data := TCombatData(Logbook.FFinalData);
  for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
    if AoWHSMap.VisibleForPlayer(
      Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10, I) or
      (TCombatPlayerList(TCombatData(Logbook.FInitialData).FPlayers).IndexOfPlayer(I) <> -1) then
    begin
      Event := TCombatEventLog.Create(nil);
      Event.SetCombatLogbook(Logbook);
      AoWHSMap.FPlayers.GetPlayers(I).FEventLogbook.AddEvent(Event);
      if Execute and (I = AoWHSMap.FSeatedPlayer) and
        (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman) and
        (TCombatData(Logbook.FFinalData).F_CombatData_30 <> 6) then
        Event.Execute(False, etEvent, nil);
      Event.Release;
    end;
end;

function CreateDamageCA(Source, Target: TCombatObject; Damage: Integer; Defensive: Boolean; DamageTypes: TDamageTypes): TDamageCA;
var
  Action: TDamageCA;
begin
  Action := TDamageCA.Create(nil);
  Action.Generate(Source, Target, Shortint(Damage), Shortint(Defensive), DamageTypes);
  Result := Action;
end;

procedure RetrieveDefaultDiplomaticActionMessage(Source, Target, Other: Shortint; Action: TDiplomaticActionType; Reaction: TDiplomaticActionReaction; Text: TStrings);
var
  SourceRace, TargetRace, OtherRace: string;
  Relation: TDiplomaticRelation;
  TextControl: TTextControl;
  Alignment: Integer;
begin
  Text.Clear;
  TextControl := AoWHSSet.FTextControl;
  Relation := AoWHSMap.FPlayers.GetDiplomaticRelation(Source, Target);
  SourceRace := TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Source).FPlayerRace]);
  TargetRace := TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Target).FPlayerRace]);
  if Other > 0 then
    OtherRace := TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Other).FPlayerRace])
  else OtherRace := '';
  if AoWHSSet.FRaceResources.GetRaceResource(AoWHSMap.FPlayers.GetPlayers(Source).FPlayerRace).GetAlignment in [alPureGood, alGood] then Alignment := 0
  else if AoWHSSet.FRaceResources.GetRaceResource(AoWHSMap.FPlayers.GetPlayers(Source).FPlayerRace).GetAlignment in [alEvil, alPureEvil] then Alignment := 2
  else Alignment := 1;
  case Action of
    daDeclareWar:
      begin
        if Relation = drUnknown then TextControl.RetrieveText(Alignment + 151, Text)
        else TextControl.RetrieveText(Alignment + 100, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end;
    daOfferPeace:
      if Reaction = darNone then
      begin
        if Relation = drUnknown then TextControl.RetrieveText(Alignment + 103, Text)
        else TextControl.RetrieveText(Alignment + 154, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 127, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 130, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end;
    daProposeAlliance:
      if Reaction = darNone then
      begin
        TextControl.RetrieveText(Alignment + 106, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 121, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 124, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end;
    daBreakAlliance:
      begin
        TextControl.RetrieveText(Alignment + 109, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end;
    daThreatenToAttack:
      begin
        TextControl.RetrieveText(Alignment + 112, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end;
    daMakeTribute:
      if Reaction = darNone then
      begin
        TextControl.RetrieveText(Alignment + 118, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 133, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 136, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end;
    daBreakAllianceWithY:
      if Reaction = darNone then
      begin
        TextControl.RetrieveText(Alignment + 160, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace, OtherRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 139, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace, OtherRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 142, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace, OtherRace]);
      end;
    daDeclareWarToY:
      if Reaction = darNone then
      begin
        TextControl.RetrieveText(Alignment + 157, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace, OtherRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 145, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace, OtherRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 148, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace, OtherRace]);
      end;
  end;
end;


procedure MaximizeMovePointTable(var Table; const Other);
type
  TMoveTable = array[0..15, 0..15] of Shortint;
var
  I, J: Integer;
  OldValue, Value: Shortint;
begin
  for I := 0 to 12 do
    for J := 0 to 15 do
    begin
      OldValue := TMoveTable(Table)[J, I];
      Value := TMoveTable(Other)[J, I];
      if (OldValue <> -1) and
        ((OldValue < Value) or
        (Value = -1)) then
        TMoveTable(Table)[J, I] := Value;
    end;
end;

function CreateArmyMoveTE(Army: TArmyHS; Selection: Byte; Path: TMovepath; Action: TMoveAction; Mode: TArmyMoveMode): TMoveArmyTE;
var
  Move: TMoveArmyTE;
begin
  Result := nil;
  case Action of
    maNormal: Move := TArmyDefaultMoveTE.Create(nil);
    maCombine: Move := TArmyCombineMoveTE.Create(nil);
    maAttack: Move := TArmyCombatMoveTE.Create(nil);
    maNegotiate: Move := TArmyNegotiateMoveTE.Create(nil);
  else Move := nil;
  end;
  if Move <> nil then
    if not Move.Setup(Army, Selection, Path, Mode) then
    begin
      Result := nil;
      Move.Release;
    end
    else Result := Move;
end;

function CreateArmyMoveXYLTE(Army: TArmyHS; Selection: Byte; X, Y, L: Shortint; Action: TMoveAction; Mode: TArmyMoveMode): TMoveArmyTE;
var
  Settings: TMoveControlSettings;
begin
  Settings := TMoveControlSettings.Create(nil);
  Settings.SetSourcePos(Army.GetXhx, Army.GetYhx, Army.GetLhx);
  Settings.FPlayer := Army.FArmy.FPlayer;
  Settings.FArmyHS := Army;
  Settings.FSelection := Selection;
  Settings.SetDestinationPos(X, Y, L);
  Army.FArmy.CreateMovePointTable(Selection, Settings.FMovePointTable);
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  if Settings.FPath.Count <> 0 then
    Result := CreateArmyMoveTE(Army, Selection, Settings.FPath, Action, [])
  else Result := nil;
  Settings.Release;
end;

function MoveArmyEx(Army: TArmyHS; Selection: Byte; Path: TMovepath; Mode: TArmyMoveMode; Force: Boolean): Boolean;
var
  Pos: Integer;
  Move: TMoveArmyTE;
  Action: TMoveAction;
  Moved: Boolean;
begin
  Moved := False;
  if Force or not AoWHSMap.FPlayers.GetPlayers(Army.FArmy.FPlayer).GetBusy then
    if Path.Count > 1 then
    begin
      Pos := Path.MovePointsToPos(Army.FArmy.MovePoints(Selection));
      if Pos = 0 then
        Action := TAoWMapField(AoWHSMap.MapContainer.GetField(Path[Pos].X, Path[Pos].Y, Path[Pos].L)).GetMoveAction(Army.FArmy.FPlayer)
      else Action := maNormal;
      if (Action = maAttack) and
        (AoWHSMap.FPlayers.GetPlayers(Army.FArmy.FPlayer).FPlayerType = ptHuman) and
        not AoWHSMap.VisibleForPlayer(Path[0].X, Path[0].Y, Path[0].L, Army.FArmy.FPlayer) then
        Action := maNormal;
      Move := CreateArmyMoveTE(Army, Selection, Path, Action, Mode);
      if Move <> nil then
      begin
        AoWHSMap.FTokenManager.GetTokenControl(Army.FArmy.FPlayer).AddEvent(Move);
        Move.Release;
        Moved := True;
      end;
    end;
  Result := Moved;
end;

function MoveArmy(Army: TArmyHS; Selection: Byte; Path: TMovepath): Boolean;
begin
  Result := MoveArmyEx(Army, Selection, Path, [mmSelectEndLocation], False);
end;

function MoveArmyXYL(Army: TArmyHS; Selection: Byte; X, Y, L: Shortint; Force: Boolean): Boolean;
var
  Settings: TMoveControlSettings;
begin
  Settings := TMoveControlSettings.Create(nil);
  Settings.SetSourcePos(Army.GetXhx, Army.GetYhx, Army.GetLhx);
  Settings.FPlayer := Army.FArmy.FPlayer;
  Settings.FArmyHS := Army;
  Settings.FSelection := Selection;
  Settings.SetDestinationPos(X, Y, L);
  Army.FArmy.CreateMovePointTable(Selection, Settings.FMovePointTable);
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  if Settings.FPath.Count <> 0 then
    Result := MoveArmyEx(Army, Selection, Settings.FPath, [], Force)
  else Result := False;
  Settings.Release;
end;

function MoveArmyXYLEx(Player: Shortint; Army: TArmyHS; Selection: Byte; X, Y, L: Shortint; Action: TMoveAction; Force: Boolean): TMoveArmyTE;
var
  Settings: TMoveControlSettings;
begin
  Settings := TMoveControlSettings.Create(nil);
  Settings.SetSourcePos(Army.GetXhx, Army.GetYhx, Army.GetLhx);
  Settings.FPlayer := Army.FArmy.FPlayer;
  Settings.FArmyHS := Army;
  Settings.FSelection := Selection;
  Settings.SetDestinationPos(X, Y, L);
  Army.FArmy.CreateMovePointTable(Selection, Settings.FMovePointTable);
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  if Settings.FPath.Count <> 0 then
  begin
    if (Force or AoWHSMap.FTokenManager.PlayerReady(Player)) and (Settings.FPath.Count > 1) then
    begin
      Result := CreateArmyMoveTE(Army, Selection, Settings.FPath, Action, []);
      if Result <> nil then
      begin
        AoWHSMap.FTokenManager.GetTokenControl(Player).AddEvent(Result);
        { Original returns the token-event pointer after releasing its reference. }
        Result.Release;
      end
      else Result := nil;
    end
    else Result := nil;
  end
  else Result := nil;
  Settings.Release;
end;

function Format(const S: string; const Args: array of const): string;
{ conflict: function Format(const Fmt: string; const Args: array of const): string; }
begin
  try
    Result := SysUtils.Format(S, Args);
  except
    Result := S;
  end;
end;

procedure FmtTurnsStr(A1: Integer; A2: Integer);
begin end;

procedure FmtTurnsLeftStr(A1: Integer; A2: Integer);
begin end;

procedure FmtDaysStr(A1: Integer; A2: Integer);
begin end;

procedure FmtDaysLeftStr(A1: Integer; A2: Integer);
begin end;

function HitPointsToHitPcnt(A1, A2: Shortint): Integer;
begin Result := 0; end;

procedure ShowHitPcnt(A1: Integer; A2: Integer; const A3: TSurfaceDesc; A4: Integer);
begin end;

procedure ShowDamageIcon(X, Y: Integer; const Surface: TSurfaceDesc; Damage: Integer; DamageType: TDamageType);
begin end;

procedure ShowDamageEffects(A1: Word; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

function DamageEffectsAnimationFrames(A1: TDamageTypes): Integer;
begin Result := 0; end;

function StatusToStatusValue(Status: TStatus): Integer;
begin
  case Ord(Status) of
    0: Result := 10;
    1: Result := 30;
    2: Result := 50;
    3: Result := 70;
    4: Result := 90;
  else
    Result := 50;
    { Original constructs and leaks this exception without raising it. }
    Exception.Create('Invalid TStatus Value');
  end;
end;

function StatusValueToStatus(Value: Integer): TStatus;
begin
  if Value <= 20 then Result := sHostile
  else if Value > 80 then Result := sFriendly
  else
    case Value of
      21..40: Result := sWary;
      41..60: Result := sNeutral;
      61..80: Result := sPolite;
    else
      Result := sNeutral;
      { Original constructs and leaks this exception without raising it. }
      Exception.Create('Invalid StatusValue');
    end;
end;

procedure MoraleToMoraleValue(A1: Integer);
begin end;

procedure MoraleValueToMorale(A1: Integer);
begin end;

procedure dAlignmentsToStatus(A1: Byte; A2: Byte; A3: Integer);
begin end;

function DamageTypesToDamageType(A1: TDamageTypes): TDamageType;
begin Result := dtNone; end;

procedure dAlignmentToStatus(A1: Integer; A2: Integer);
begin end;

procedure AlsToInt(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure IntToAls(A1: Integer; A2: Integer; A3: Integer);
begin end;

function Land(Terrain: Shortint): Boolean;
begin Result := False; end;

procedure MoveTypesToInt(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure IntToMoveTypes(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure CombatRangeToCombatMode(A1: Byte);
begin end;

procedure PlaceRandomUnits(X, Y, L: Integer; Player: Shortint; Units: TUnitIndexList; Count, Value: Integer; Mode: TUnitPlaceMode);
begin end;

function FillWithRandomUnits(A1: TUnitIndexList; A2: TUnitList; A3: Integer; A4: Integer; A5: TUnitTypes): Integer;
begin Result := 0; end;

procedure FillWithRandomUnitIndexes(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TriggerStormDamage(A1: Byte; A2: Byte; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure RetrieveStormDamageInfo(A1: Integer; A2: Byte; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);
begin end;

procedure dAlignmentToDiplomaticRelation(A1: Integer; A2: Integer);
begin end;

procedure StatusToDiplomaticRelation(A1: Byte);
begin end;

procedure GetCombatSide(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure AlignmentToIR(A1: Byte);
begin end;

procedure IRtoAlignment(A1: Integer);
begin end;

procedure DiplomaticRelation(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

function ValidAttackRelation(Player, IndependentRelation, TargetPlayer: Shortint; Mode: Boolean): Boolean;
begin end;

procedure GetUnitIndexAIPriority(A1: Integer; A2: Byte; A3: Integer);
begin end;

procedure UnitsToIndependentRelation(A1: Integer; A2: Byte);
begin end;

procedure DegreesRadToCo(A1: Integer; A2: Integer; var A3: Integer; var A4: Integer);
begin end;

procedure Encode(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure SetupBattleFieldInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure StrengthInfoMax(A1: Integer);
begin end;

procedure InvertDamageTypes(A1: Word);
begin end;

procedure ListMovementGaps(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure GetMovepathBattleFieldStrength(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure GetBattleFieldStrengthAdvantage(A1: Integer; A2: Integer; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure IgnitionChance(A1: Integer);
begin end;

procedure CreateEnhancementAbility(A1: Integer; A2: Integer; A3: Integer);
begin end;

function MeleeDamageTypes(A1: TCombatObject): TDamageTypes;
begin Result := []; end;

function StrikeDV(A1, A2: TCombatObject): Integer;
begin Result := 0; end;

function CreateStrikeCA(A1, A2: TCombatObject; A3: Boolean): TStrikeCA;
begin Result := nil; end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure ValidateAoWEngine;
begin end;

