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
  WaitingRStr = 'Waiting';
  ActionAlreadyQueuedRStr = 'Action already queued';
  ProduceXRStr = 'Produce %s';
  InstallXRStr = 'Install %s';
  SummonXRStr = 'Summon %s';
  ProducingXRStr = 'Producing %s';
  InstallingXRStr = 'Installing %s';
  SummoningXRStr = 'Summoning %s';

resourcestring
  ConfirmRStr = 'Confirm';
  YourAboutToExitAMultiPlayerGameRStr = 'You''re about to exit a multi-player game!';
  DoYouWantToContinueExitingRStr = 'Do you want to continue exiting?';
  MessageRStr = 'Message';
  PleaseWaitTillItIsYourTurnRStr = 'Please, wait till it is your turn.';
  SaveGameToXRStr = 'Save game to %s?';
  DoYouWantToSaveThisGameRStr = 'Do you want to save this game?';
  PasswordFailedRStr = 'Password failed!';
  DoYouWantToTryAgainRStr = 'Do you want to try again?';

resourcestring
  ConnectionLostRStr = 'Connection Lost!';
  ConnectionXLostRStr = 'Connection to %s lost!';
  ConnectionXTimeOutRStr = 'Connection to %s timed out!';
  OutOfSyncRStr = 'Out of sync!';
  TerminateGameSaveRStr = 'The game will be terminated, do you want to save?';
  LetTheGameBeginRStr = 'Let the game begin';
  TheGameContinuesRStr = 'The game continues';
  AgeOfWondersEmailGameRStr = 'Age of Wonders email game';
  AoWEmailGameXRStr = 'AoW email game (%s)';
  DoYouWantToContinueRStr = 'Do you want to continue?';
  GameRestartEventLogXRStr = 'Game is restarted for unknown reason, contact %s for more information';
  GameSavedRStr = '%s saved';
  GameSuccessfullySavedRStr = 'Game successfully saved';
  MapXRStr = 'Map: %s';
  NameXRStr = 'Name: %s';
  PBEMGameEndedRStr = 'This game''s turn has been ended. Restarting is only allowed for resend purposes.';
  PBEMRestartCheatRStr = 'This game isn''t the original game. Restarting it qualifies you as a cheater!';
  PlayersRStr = 'Players';
  SaveEmailGameRStr = 'Save email game...';
  TurnXRStr = 'Turn: %s';
  WarningRStr = 'Warning';
  XatYRStr = '%0:s at %1:s';
  ItsYourTurnRStr = 'It''s your turn!';
  YourTurnContinuesRStr = 'Your turn continues';
  IndependentsAreMovingRStr = 'Independents are moving';
  PlayerIsMovingRStr = '%s is moving';
  AreMovingRStr = '%s are moving';
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
  Enabled := FPadControl.FTerrainTypes;
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
  if Stream.StorageMode * [smRead, smTextOnly, smCompare] = [smRead] then
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

function TUnitSelector.Select: Boolean;
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

function TUnitSelector.CanSelectUnit(A1: TUnit): Boolean;
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
    FSourceUnitID := Integer(PSourceInfo(Source).Source);
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

procedure TAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
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

procedure TAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
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

function TAbility.ExpandName(A1: TAbilityOwner): string;
begin
  Result := FAbilityName;
end;

function TAbility.ExpandCost(A1: TAbilityOwner): Integer;
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

function TAbility.GetSkillPoints(A1: TAbilityOwner): Integer;

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

function TAbility.CanActivate(A1: TAbilityOwner; var A2: string): Boolean;
begin
  A2 := '';
  { needs: Boolean result; P4 overrides remain unmarked procedures. }
  asm
    MOV EDX,A1
    MOV EAX,Self
    MOV ECX,[EAX]
    CALL DWORD PTR [ECX+$98]
    AND EAX,1
  end;
end;

function TAbility.Activate(A1: TAbilityOwner; var A2: string): Boolean;
var
  Info: TActivateAbilityInfo;
begin
  { needs: Boolean result; P4 has unmarked procedure overrides. }
  if CanActivate(A1, A2) then
  begin
    Info := TActivateAbilityInfo.Create(nil);
    Info.FAbilityID := FAbilityID;
    if TObject(A1) is TAbstractUnit then
      Info.FUnitID := TAbstractUnit(A1).FUnitID
    else Info.FUnitID := 0;
    TEventList(AoWHSMap.FOnActivateAbility).TriggerNotifyEvents(Info);
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
    TEventList(PP1Pointer(Integer(AoWHSMap.FCombatMap) + $DC)^).TriggerNotifyEvents(Info);
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
  FStatus := psIdle;
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
  FViewX := $FF;
  FViewY := $FF;
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
  if Maximum < Result then Result := Maximum;
end;

function TPlayer.GetIdealHeroJoinDay: Integer;
var
  Average, Maximum: Integer;
begin
  Result := FLastHeroJoinDay;
  Average := AoWHSMap.FPlayers.GetAverageHeroCount;
  Maximum := AoWHSMap.FPlayers.GetMaxHeroCount;
  if (Maximum > Average) and (FHeroes.Count = Maximum) then
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

procedure TPlayer.MakeHeroEmerge(Mode: THeroEmergeMode);
var
  Chance: Integer;
  Heroes: TDoubleItemList;
  Log: THeroEmergeEventLog;
  Locations: TXYLList;
  Structure: TStructure;
  Item: TDoubleItem;
  I: Integer;
  Hero: THero;
begin
  Heroes := TDoubleItemList.Create;
  if Mode = hemNormal then
    for I := AoWHSMap.FHeroControl.GetCount - 1 downto 0 do
    begin
      Hero := AoWHSMap.FHeroControl.GetHero(I);
      if not (hsDied in Hero.FHeroStatus) and (Hero.FPlayer <= 0) and
        (Hero.Owner = nil) and Hero.CanJoin(FPlayerIndex) then
      begin
        Chance := GetHeroJoinChance(Hero.GetLevel);
        if (Chance > 0) and (Hero.JoinAmount(FPlayerIndex) < FGems) then
          Heroes.AddAB(Integer(Hero), Chance * Chance);
      end;
    end
  else if Mode = hemFirstHero then
    for I := AoWHSMap.FHeroControl.GetCount - 1 downto 0 do
    begin
      Hero := AoWHSMap.FHeroControl.GetHero(I);
      if not (hsDied in Hero.FHeroStatus) and (Hero.FPlayer <= 0) and
        (Hero.Owner = nil) and Hero.GetAbilityEnabled($34) and
        (Hero.GetLevel >= 2) and (Hero.GetLevel <= 3) then
        if (AoWHSMap.FRaces.GetRace(Hero.FRace).GetPlayerRelation(FPlayerIndex) in
          [sPolite, sFriendly]) and (Hero.JoinAmount(FPlayerIndex) < FGems) then
          Heroes.AddAB(Integer(Hero), (Hero.GetLevel - 2) * 1000 + 1);
    end;
  if Heroes.Count <> 0 then
  begin
    Locations := TXYLList.Create;
    for I := FStructures.Count - 1 downto 0 do
    begin
      Structure := FStructures.GetStructure(I);
      if Structure.ClassID = $20108 then
        Locations.AddXYL(Structure.GetXhx, Structure.GetYhx, Structure.GetLhx);
    end;
    if Locations.Count <> 0 then
    begin
      FLastHeroEmergeDay := AoWHSMap.FDay;
      RandSeed := AoWHSMap.Random($FFFFF);
      I := Heroes.RandomChanceItemB(0);
      Item := Heroes[I];
      Hero := THero(Item.A);
      I := AoWHSMap.Random(Locations.Count);
      FEmergingHeroID := Hero.FUnitID;
      Hero.UpdateSettings;
      Hero.Place(Locations[I].X, Locations[I].Y, Locations[I].L,
        0, [pmScanArea, pmCreateNewArmy]);
      Structure := TStructure(AoWHSMap.MapContainer.GetField(
        Locations[I].X, Locations[I].Y, Locations[I].L).
        FindNoneTransparentHS(TStructure));
      Log := THeroEmergeEventLog.Create(nil);
      Log.Setup(Hero, FPlayerIndex, hjmEmerged);
      if Structure <> nil then Log.FLocationName := Structure.GetName
      else Log.FLocationName := TranslateRStr(UnknownRStr);
      FEventLogbook.AddEvent(Log);
      if (FPlayerIndex = AoWHSMap.FSeatedPlayer) and
        (AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).FPlayerType = ptHuman) then
        Log.Execute(False, etEvent, nil);
      Log.Release;
    end;
    Locations.Free;
  end;
  Heroes.Free;
end;

procedure TPlayer.UpdateHeroJoin;
var
  I, Days: Integer;
begin
  for I := FHeroes.Count - 1 downto 0 do
    if FHeroes.GetHero(I).GetLevel > FHighestHeroLevel then
      FHighestHeroLevel := FHeroes.GetHero(I).GetLevel;
  FBaseHeroJoinLevel := AoWHSMap.FPlayers.GetAverageHeroLevel;
  if FBaseHeroJoinLevel = 0 then
    FBaseHeroJoinLevel := AoWHSMap.FHeroControl.GetMinFreeHeroLevel;
  if FHighestHeroLevel <> 0 then
    FBaseHeroJoinLevel := (FBaseHeroJoinLevel + FHighestHeroLevel + 1) div 2;
  if FHeroes.Count = GetHeroCountMax then ResetBaseHeroJoinDay;
  FEmergingHeroID := 0;
  Days := GetIdealHeroEmergeDay - AoWHSMap.FDay;
  if (AoWHSMap.FDay = 1) and (FHeroes.Count = 1) and not AoWHSMap.FFixedLeaders then
  begin
    MakeHeroEmerge(hemFirstHero);
    Exit;
  end;
  if Days <= 0 then
    if AoWHSMap.Random(4) = 1 then MakeHeroEmerge(hemNormal);
end;

function TPlayer.GetHeroJoinChance(Level: Integer): Integer;
var
  Maximum: Integer;
begin
  Maximum := GetHeroJoinLevelMax;
  if Level <= Maximum then
  begin
    Result := Round((Maximum + 2) / (Level + 2) * 20);
    if Result > 40 then Result := 40;
  end
  else Result := 0;
end;

function TPlayer.GetHeroJoinLevelMax: Integer;
var
  Days: Integer;
begin
  Result := FBaseHeroJoinLevel;
  Days := AoWHSMap.FDay - GetIdealHeroJoinDay;
  if Days > 0 then Inc(Result, Days div 5);
  if Days < 0 then
  begin
    Inc(Result, Round((Result * Days + 2.5) / 5));
    if Result < 0 then Result := 0;
  end;
  if (Result < 3) and not AoWHSMap.FFixedLeaders and (AoWHSMap.FDay = 1) then
    Result := 3;
end;

procedure TPlayer.ValidateLeader;
var
  FaceIndex, ResourceIndex: Integer;
  HeroType: THeroType;
  Name: string;
begin
  if (AoWHSMap <> nil) and (FPlayerIndex <> 0) then
  begin
    HeroType := htHeroLeader;
    if (FLeader <> nil) and (FLeader.GetHeroType <> HeroType) then
    begin
      Name := FLeader.FHeroName;
      FaceIndex := FLeader.FFaceIndex;
      FLeader.Deactivate;
      ResourceIndex := AoWHSSet.FHeroResources.Find(FPlayerRace, HeroType);
      FLeader.SetHeroResourceIndex(ResourceIndex);
      FLeader.FHeroName := Name;
      FLeader.SetFaceIndex(FaceIndex);
      FLeader.Activate;
    end
    else if FLeader = nil then
    begin
      ResourceIndex := AoWHSSet.FHeroResources.Find(FPlayerRace, HeroType);
      if ResourceIndex <> -1 then
      begin
        FLeader := TLeader.Create(nil);
        FLeader.SetHeroResourceIndex(ResourceIndex);
        FLeader.FPlayer := FPlayerIndex;
        FLeader.Activate;
      end;
    end
    else if (FLeader <> nil) and not AoWHSMap.FFixedLeaders and
      (AoWHSMap.FGameType <> gtCampaign) and not (msEditting in AoWHSMap.Status) then
      FLeader.Owner := nil;
  end;
end;

procedure TPlayer.SetLeader(Value: TLeader);
begin
  FLeader := Value;
end;

procedure TPlayer.SetRace(Value: Shortint);
begin
  FPlayerRace := Value;
end;

procedure TPlayer.SetEndTurn(Value: Boolean);
begin
  if Value <> FSingleProcessCycle then
  begin
    FSingleProcessCycle := Value;
    AoWHSMap.TriggerEndTurnEvent(FPlayerIndex);
  end;
end;

procedure TPlayer.UpdateLogbook;
begin
  while (FEventLogbook.GetCount <> 0) and
    (AoWHSMap.FDay - FEventLogbook.GetLogs(0).FDay >= 3) do
    FEventLogbook.RemoveEvent(FEventLogbook.GetLogs(0));
end;

procedure TPlayer.UpdateTurnInfo;
var
  Info: TTurnInfoItem;
  I, J: Integer;
  Army: TArmy;
  AUnit: TAbstractUnit;
begin
  Info := TTurnInfoItem.Create(FStatistics.FTurnInfo);
  if FGameOverStatus <> goLost then
  begin
    Info.FGold := FGems;
    Info.FMana := FMagicControl.FMana;
    Info.FStructures := FStructures.Count;
    Info.FHeroes := FHeroes.Count;
    for I := 0 to FArmies.Count - 1 do
    begin
      Army := FArmies.GetArmy(I);
      for J := Army.Count - 1 downto 0 do
      begin
        AUnit := Army.GetUnit(J);
        if Info.FArmyStrength < $3FFFFFFF then
          Inc(Info.FArmyStrength, AUnit.GetStrengthMax(dtAll - [dtWall]));
      end;
    end;
  end;
end;

procedure TPlayer.UpdateAlliedPlayersSeen;
var
  I: Integer;
begin
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> FPlayerIndex then
      if AoWHSMap.FPlayers.GetDiplomaticRelation(FPlayerIndex, I) = drAlliance then
        PlayerSeen(I);
end;

procedure TPlayer.SetupAIValidAttackPlayers;
var
  I: Integer;
begin
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> FPlayerIndex then
      FAIValidAttackPlayers[I] := FDiplomaticRelations.GetDiplomaticRelation(I) = drWar;
end;

procedure TPlayer.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  FDiplomaticRelations.MsgProc(Msg, Sender);
  if (Msg.MsgID = $20000008) and (AoWHSMap.FDay = 0) then
  begin
    FFirstDaySeen.Clear;
    FLastDaySeen.Clear;
  end;
  if Msg.MsgID = $20020005 then ValidateLeader;
  if Msg.MsgID = $20020001 then
    try
      UpdateLogbook;
      if AoWHSMap.FDay = 1 then
      begin
        FViewX := $FF;
        if (AoWHSMap.FGameType <> gtCampaign) and not AoWHSMap.FFixedLeaders and
          (FLeader <> nil) then
        begin
          FLeader.Owner := nil;
          FMagicControl.UnregisterPowerSource(FLeader.FPowerSource);
          FHeroes.RemoveChild(Self); { Original removes the player, not the leader. }
        end;
        UpdateAlliedPlayersSeen;
        SetupAIValidAttackPlayers;
      end;
    except
    end;
  if Msg.MsgID = $20020103 then
    if not Validate(TStrings(Msg.Value)) then Msg.Data[0] := 1;
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayerIndex) then
    UpdateAlliedPlayersSeen;
  if (Msg.MsgID = $20020003) and (Msg.Value = FPlayerIndex) then
  begin
    UpdateTurnInfo;
    if FPlayerIndex <> 0 then UpdateHeroJoin;
  end;
  if (Msg.MsgID = $20000008) and (AoWHSMap.FDay = 0) then
  begin
    FViewX := $FF;
    FViewY := $FF;
    FViewL := $FF;
  end;
  FMagicControl.MsgProc(Msg, Sender);
  FAIControl.MsgProc(Msg, Sender);
  FAIBudget.MsgProc(Msg, Sender);
  FEventLogbook.MsgProc(Msg, Sender);
end;

procedure TPlayer.ReadWrite(Stream: Engine.TEStorageStream);
var
  X, Y, L: Integer;
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayerRace), 2);
  Stream.rwData(FPlayerType, 1, 3);
  Stream.rwBool(FParticipating, 4);
  Stream.rwInteger(FInitialGold, 5);
  Stream.rwInteger(FBaseIncome, 6);
  Stream.rwData(FStatus, 1, $A);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FSettings, $B);
  Stream.rwString(FDescription, $C);
  Stream.rwInteger(FGems, $10);
  Stream.rwByte(Byte(FPlayerIndex), $12);
  if (AoWEngine.Status * [esLoadingHSM, esSavingHSM] <> []) or
    (smTextOnly in Stream.StorageMode) then
    if not (smWrite in Stream.StorageMode) then
    begin
      Stream.rwCreateEObject(TEObject(FLeader), nil, $13);
      if (FLeader <> nil) and not (smPreview in Stream.StorageMode) then
      begin
        FLeader.FPlayer := FPlayerIndex;
        AoWHSMap.FHeroControl.RegisterHero(FLeader);
      end;
    end;
  if smWrite in Stream.StorageMode then
  begin
    if (AoWHSMap.FSeatedPlayer = FPlayerIndex) and (AoWHSMap.FConnectionType <> pcNetwork) then
    begin
      AoWHSMap.GetViewCenter(X, Y, L);
      FViewX := X; FViewY := Y; FViewL := L;
      Stream.rwByte(FViewX, $14);
      Stream.rwByte(FViewY, $15);
      Stream.rwByte(FViewL, $16);
    end;
  end
  else
  begin
    Stream.rwByte(FViewX, $14);
    Stream.rwByte(FViewY, $15);
    Stream.rwByte(FViewL, $16);
  end;
  if not (smPreview in Stream.StorageMode) then Stream.rwEObject(FEventLogbook, $17);
  Stream.rwString(FPassword, $18);
  Stream.rwData(FGameOverStatus, 1, $19);
  if smRead in Stream.StorageMode then
    Stream.rwStreamProc($1A, FLegacyNewRelations.LoadFromStream, FLegacyNewRelations.SaveToStream);
  Stream.rwByte(Byte(FMoraleValue), $1B);
  Stream.rwEObject(FAIControl, $1C);
  Stream.rwData(FBehavior, 1, $1D);
  if FPlayerIndex <> 0 then
    if (smWrite in Stream.StorageMode) and (msEditting in AoWHSMap.Status) and
      (FLeader <> nil) then Stream.rwEObject(FLeader, $1E)
    else Stream.rwEObject(FLeaderSetup, $1E);
  Stream.rwEObject(FMagicControl, $1F);
  Stream.rwStreamProc($20, FFirstDaySeen.LoadFromStream, FFirstDaySeen.SaveToStream);
  Stream.rwStreamProc($21, FLastDaySeen.LoadFromStream, FLastDaySeen.SaveToStream);
  Stream.rwInteger(FDay, $22);
  Stream.rwEObject(FStatistics, $23);
  Stream.rwInteger(FBaseHeroJoinLevel, $24);
  Stream.rwInteger(FLastHeroJoinDay, $25);
  Stream.rwInteger(FLastHeroEmergeDay, $26);
  Stream.rwInteger(FHighestHeroLevel, $27);
  if smRead in Stream.StorageMode then
  begin
    SetRace(FPlayerRace);
    FEventLogbook.FPlayer := FPlayerIndex;
    FLegacyNewRelations.Default := Ord(drUnknown);
  end;
  Stream.rwStrings(FMessages, $28);
  if smRead in Stream.StorageMode then
    Stream.rwStreamProc($29, FLegacyRelations.LoadFromStream, FLegacyRelations.SaveToStream);
  Stream.rwInteger(FEmergingHeroID, $32);
  Stream.rwEObject(FAIBudget, $33);
  Stream.rwEObject(FDiplomaticActions, $34);
  Stream.rwStreamProc($35, FAIValidAttackPlayers.LoadFromStream, FAIValidAttackPlayers.SaveToStream);
  Stream.rwEObject(FPBEMSettings, $36);
  Stream.rwBool(FHeroEmerging, $38);
  if (smRead in Stream.StorageMode) or (AoWHSMap.FConnectionType <> pcNetwork) then
    Stream.rwInteger(FBaseHeroJoinDay, $39);
  Stream.rwEObject(FDiplomaticRelations, $3A);
  if FPlayerIndex = 0 then FPlayerType := ptIndependent;
end;

function TPlayer.GetFirstDaySeen(Player: Shortint): Integer;
begin
  if Player <> FPlayerIndex then
    if Player < FFirstDaySeen.Count then Result := FFirstDaySeen[Player]
    else Result := -1
  else Result := 0;
end;

function TPlayer.GetLastDaySeen(Player: Shortint): Integer;
begin
  if Player <> FPlayerIndex then
    if Player < FLastDaySeen.Count then Result := FLastDaySeen[Player]
    else Result := -1
  else Result := AoWHSMap.FDay;
end;

procedure TPlayer.PlayerSeen(Player: Shortint);
begin
  if not (msEditting in AoWHSMap.Status) and
    ((Player >= FLastDaySeen.Count) or (FLastDaySeen[Player] <> AoWHSMap.FDay)) then
  begin
    FLastDaySeen[Player] := AoWHSMap.FDay;
    if GetFirstDaySeen(Player) = -1 then FFirstDaySeen[Player] := AoWHSMap.FDay;
  end;
end;

procedure TPlayer.GetLeaderLocation(var X, Y, L: Shortint);
begin
  if (FLeader <> nil) and (FLeader.Owner <> nil) then
    TUnitList(FLeader.Owner).GetLocation(X, Y, L)
  else
  begin
    X := -1;
    Y := -1;
    L := -1;
  end;
end;

function TPlayer.GetLocal: Boolean;
var
  Control: TPlayerCommunicationControl;
begin
  Control := AoWHSMap.FPlayerCommunicator.PCC;
  if Control <> nil then
    case Control.GetPlayers(FPlayerIndex).ConnectionMode of
      cmLocal, cmGlobal: begin Result := True; Exit; end;
    else Result := False;
    end
  else Result := True;
end;

procedure TPlayer.RegisterVictoryLocation(Structure: TPlayerStructure);
begin
  FVictoryLocations.AddChild(Structure);
end;

procedure TPlayer.UnregisterVictoryLocation(Structure: TPlayerStructure);
begin
  FVictoryLocations.RemoveChild(Structure);
end;

procedure TPlayer.CheckCaptureLocations;
begin
  if AoWHSMap.FVictoryCondition = vcCaptureLocations then
    if CaptureLocationsLeft = 0 then AoWHSMap.GameOver(FPlayerIndex, goWon);
end;

function TPlayer.CaptureLocationsLeft: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FVictoryLocations.Count - 1 do
    if FVictoryLocations.GetStructure(I).FPlayer <> FPlayerIndex then
      if not ((FVictoryLocations.GetStructure(I).FPlayer > 0) and
        (AoWHSMap.FPlayers.GetDiplomaticRelation(
          FVictoryLocations.GetStructure(I).FPlayer, FPlayerIndex) = drAlliance) and
        AoWHSMap.FAlliedVictory) then Inc(Result);
end;

function TPlayer.CreateDiplomaticAction(Action: TDiplomaticActionType; Target, Other: Shortint): TDiplomaticAction;
begin
  if AoWHSMap.FPlayers.GetPlayers(Target).FStatus = psPlaying then
  begin
    Result := TDiplomaticAction.Create(nil);
    Result.FSource := FPlayerIndex;
    Result.FTarget := Target;
    Result.FOtherPlayer := Other;
    Result.FActionType := Action;
    RetrieveDefaultDiplomaticActionMessage(FPlayerIndex, Target, Other,
      Action, darNone, Result.FMessage);
  end
  else Result := nil;
end;

function TPlayer.DiplomaticActionAleadySend(Action: TDiplomaticActionType; Target, Other: Shortint): Boolean;
var
  Logbook: TEventLogbook;
  I: Integer;
  Item: TDiplomaticAction;
begin
  Logbook := AoWHSMap.FPlayers.GetPlayers(Target).FEventLogbook;
  Result := False;
  I := Logbook.GetCount;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    if Logbook.GetLogs(I).FDay = AoWHSMap.FDay then
      if Logbook.GetLogs(I) is TDiplomaticActionEventLog then
      begin
        Item := TDiplomaticActionEventLog(Logbook.GetLogs(I)).FAction;
        Result := (Item.FActionType = Action) and
          (Item.FSource = FPlayerIndex) and (Item.FTarget = Target) and
          ((Other = -1) or (Item.FOtherPlayer = Other));
      end;
  end;
end;

function TPlayer.ListDiplomaticActions(Player: Shortint; var Actions: TDiplomaticActionList): Integer;
var
  Count, I: Integer;
  Relation: TDiplomaticRelation;
  Action: TDiplomaticAction;
begin
  if (Player <> FPlayerIndex) and (GetFirstDaySeen(Player) <> -1) then
  begin
    Count := Actions.Count;
    Relation := AoWHSMap.FPlayers.GetDiplomaticRelation(Player, FPlayerIndex);
    if (FPlayerType = ptHuman) and (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) then
    begin
      Action := CreateDiplomaticAction(daSendMessage, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    if (Relation in [drWar, drUnknown]) and not DiplomaticActionAleadySend(daOfferPeace, Player, -1) then
    begin
      Action := CreateDiplomaticAction(daOfferPeace, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    if (Relation <> drWar) and (Relation <> drAlliance) then
    begin
      Action := CreateDiplomaticAction(daDeclareWar, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    if (Relation in [drPeace]) and not DiplomaticActionAleadySend(daProposeAlliance, Player, -1) then
    begin
      Action := CreateDiplomaticAction(daProposeAlliance, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    if (Relation in [drPeace, drUnknown]) and not DiplomaticActionAleadySend(daThreatenToAttack, Player, -1) then
    begin
      Action := CreateDiplomaticAction(daThreatenToAttack, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    Action := CreateDiplomaticAction(daMakeTribute, Player, -1);
    if Action <> nil then
    begin
      Actions.AddChild(Action);
      Action.Release;
    end;
    if Relation = drAlliance then
    begin
      Action := CreateDiplomaticAction(daBreakAlliance, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    for I := 1 to AoWHSMap.FPlayers.Count - 1 do
      if (I <> Player) and (I <> FPlayerIndex) and
        (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) then
        if not DiplomaticActionAleadySend(daDeclareWarToY, Player, I) and
          (AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).GetFirstDaySeen(I) <> -1) and
          (AoWHSMap.FPlayers.GetPlayers(Player).GetFirstDaySeen(I) <> -1) and
          (AoWHSMap.FPlayers.GetDiplomaticRelation(Player, I) in [drPeace, drUnknown]) then
        begin
          Action := CreateDiplomaticAction(daDeclareWarToY, Player, I);
          if Action <> nil then
          begin
            Actions.AddChild(Action);
            Action.Release;
          end;
        end;
    for I := 1 to AoWHSMap.FPlayers.Count - 1 do
      if (I <> Player) and (I <> FPlayerIndex) and
        (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) then
        if not DiplomaticActionAleadySend(daBreakAllianceWithY, Player, I) and
          (AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).GetFirstDaySeen(I) <> -1) and
          (AoWHSMap.FPlayers.GetPlayers(Player).GetFirstDaySeen(I) <> -1) and
          (AoWHSMap.FPlayers.GetDiplomaticRelation(Player, I) = drAlliance) then
        begin
          Action := CreateDiplomaticAction(daBreakAllianceWithY, Player, I);
          if Action <> nil then
          begin
            Actions.AddChild(Action);
            Action.Release;
          end;
        end;
    if (FPlayerRace = 5) and FHeroEmerging and (FPlayerType = ptHuman) and
      (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) then
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        if (I <> Player) and (I <> FPlayerIndex) and
          (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) and
          (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman) then
          if (AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).GetFirstDaySeen(I) <> -1) and
            (AoWHSMap.FPlayers.GetPlayers(Player).GetFirstDaySeen(I) <> -1) and
            (AoWHSMap.FPlayers.GetPlayers(I).GetFirstDaySeen(Player) <> -1) then
          begin
            Action := CreateDiplomaticAction(daSendMessageAsY, Player, I);
            if Action <> nil then
            begin
              Actions.AddChild(Action);
              Action.Release;
            end;
          end;
    Result := Actions.Count - Count;
  end
  else Result := 0;
end;

function TPlayer.ValidAttackRelation(Player, IndependentRelation: Shortint): Boolean;
begin
  Assert(FPlayerIndex <> 0);
  if FPlayerType in [ptCPU1, ptCPU2, ptCPU3, ptCPU4, ptCPU5] then
    Result := FAIValidAttackPlayers[Player]
  else
    Result := DiplomaticRelation(FPlayerIndex, 0, Player, IndependentRelation) in
      [drWar, drUnknown];
end;

function TPlayer.ChangePlayerSettings(const Settings: string): Boolean;
var
  Event: TChangePlayerSettingsTE;
begin
  if not GetBusy then
  begin
    Event := TChangePlayerSettingsTE.Create(nil);
    Event.FPlayer := FPlayerIndex;
    Event.FSettings := Settings;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayerIndex).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

constructor TPlayerList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
  SetNumberOfPlayers(2);
  F_PlayerList_14 := Integer(TByteList.Create);
  FLocalHumanPlayers := TByteList.Create;
  FActivePlayers := TByteList.Create;
  FLocalPlayers := TByteList.Create;
end;

destructor TPlayerList.Destroy;
begin
  inherited Destroy;
  TByteList(F_PlayerList_14).Free;
  FLocalHumanPlayers.Free;
  FActivePlayers.Free;
  FLocalPlayers.Free;
end;

function TPlayerList.GetDiplomaticRelationCount(Player: Shortint; Relations: TDiplomaticRelations): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> Player then
      if GetPlayers(I).FStatus = psPlaying then
        if GetDiplomaticRelation(Player, I) in Relations then Inc(Result);
end;

function TPlayerList.GetDiplomaticRelation(Player, OtherPlayer: Shortint): TDiplomaticRelation;
begin
  Result := TPlayer(FChildren.List^[Player]).FDiplomaticRelations.GetDiplomaticRelation(OtherPlayer);
end;

procedure TPlayerList.SetDiplomaticRelation(Player, OtherPlayer: Shortint; Relation: TDiplomaticRelation);
var
  I, J: Integer;
begin
  if (TPlayer(FChildren.List^[Player]).FDiplomaticRelations.GetDiplomaticRelation(OtherPlayer) <> Relation) or
    (TPlayer(FChildren.List^[OtherPlayer]).FDiplomaticRelations.GetDiplomaticRelation(Player) <> Relation) then
  begin
    if Relation = drAlliance then
      for I := 1 to Count - 1 do
      begin
        if (GetPlayers(Player).GetFirstDaySeen(I) = -1) and
          (GetPlayers(OtherPlayer).GetFirstDaySeen(I) <> -1) then GetPlayers(Player).PlayerSeen(I);
        if (GetPlayers(OtherPlayer).GetFirstDaySeen(I) = -1) and
          (GetPlayers(Player).GetFirstDaySeen(I) <> -1) then GetPlayers(OtherPlayer).PlayerSeen(I);
      end;
    TPlayer(FChildren.List^[Player]).FDiplomaticRelations.SetDiplomaticRelation(OtherPlayer, Relation);
    TPlayer(FChildren.List^[OtherPlayer]).FDiplomaticRelations.SetDiplomaticRelation(Player, Relation);
    if Relation = drWar then
    begin
      TPlayer(FChildren.List^[Player]).FAIValidAttackPlayers[OtherPlayer] := True;
      TPlayer(FChildren.List^[OtherPlayer]).FAIValidAttackPlayers[Player] := True;
    end;
    if Relation in [drPeace, drAlliance] then
    begin
      TPlayer(FChildren.List^[Player]).FAIValidAttackPlayers[OtherPlayer] := False;
      TPlayer(FChildren.List^[OtherPlayer]).FAIValidAttackPlayers[Player] := False;
    end;
    AoWHSMap.FDiplomaticRelationsChangedEvents.TriggerNotifyEvents(Self);
    for J := Count - 1 downto 1 do
      TPlayer(FChildren.List^[J]).FMagicControl.UpdateEnemyEnchantments;
    AoWHSMap.UpdateVisibility;
  end;
end;

function TPlayerList.GetActivePlayers: Integer;
var
  I: Integer;
begin
  I := 1;
  Result := 0;
  { Original tests the active count, not the index, and can run past the list. }
  while Result <> FChildren.Count do
  begin
    if TPlayer(FChildren.List^[I]).FGameOverStatus <> goLost then Inc(Result);
    Inc(I);
  end;
end;

procedure TPlayerList.Update;
var
  I: Integer;
  Player: TPlayer;
begin
  if AoWHSMap.FPlayerCommunicator.PCC <> nil then
  begin
    TByteList(F_PlayerList_14).Clear;
    FLocalHumanPlayers.Clear;
    FLocalPlayers.Clear;
    FActivePlayers.Clear;
    for I := 0 to FChildren.Count - 1 do
    begin
      Player := TPlayer(FChildren.List^[I]);
      if Player.FStatus = psPlaying then
      begin
        if (Player.FGameOverStatus <> goLost) and (I <> 0) then FActivePlayers.Add(I);
        if Player.GetLocal then
        begin
          TByteList(F_PlayerList_14).Add(I);
          if Player.FPlayerType = ptHuman then FLocalHumanPlayers.Add(I);
        end;
        if Player.FPlayerType = ptHuman then FLocalPlayers.Add(I);
      end;
    end;
  end;
end;

procedure TPlayerList.BeginUpdate;
var
  I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    TPlayer(FChildren.List^[I]).BeginUpdate;
end;

procedure TPlayerList.EndUpdate;
var
  I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    TPlayer(FChildren.List^[I]).EndUpdate;
  Update;
end;

procedure TPlayerList.Assign(Source: Engine.TEObject; AEngine: Engine.TEngine);
var
  I: Integer;
begin
  SetNumberOfPlayers(TPlayerList(Source).GetNumberOfPlayers);
  for I := 0 to FChildren.Count - 1 do
    TPlayer(FChildren.List^[I]).Assign(TPlayerList(Source).GetPlayers(I), AoWEngine);
end;

function TPlayerList.GetPlayers(Index: Integer): TPlayer;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TPlayer(FChildren.List^[Index])
  else Result := nil;
end;

function TPlayerList.GetActivePlayersAllied: Boolean;
var
  I, J: Integer;
begin
  Result := True;
  I := FActivePlayers.Count;
  while Result and (I <> 0) do
  begin
    Dec(I);
    J := FActivePlayers.Count;
    while Result and (J <> 0) do
    begin
      Dec(J);
      if J <> I then Result := GetDiplomaticRelation(FActivePlayers[J], FActivePlayers[I]) = drAlliance;
    end;
  end;
end;

function TPlayerList.GetAverageHeroLevel: Integer;
var
  Count, I, J: Integer;
  Player: TPlayer;
begin
  Count := 0;
  Result := 0;
  for I := 1 to FChildren.Count - 1 do
  begin
    Player := TPlayer(FChildren.EObjects[I]);
    for J := Player.FHeroes.Count - 1 downto 0 do
    begin
      Inc(Result, Player.FHeroes.GetHero(J).GetLevel);
      Inc(Count);
    end;
  end;
  if Count <> 0 then Result := Result div Count
  else Result := 0;
end;

function TPlayerList.GetAverageHeroCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to FChildren.Count - 1 do
    Inc(Result, TPlayer(FChildren.EObjects[I]).FHeroes.Count);
  Result := Result div (FChildren.Count - 1);
end;

function TPlayerList.GetMaxHeroCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to FChildren.Count - 1 do
    if TPlayer(FChildren.EObjects[I]).FHeroes.Count > Result then
      Result := TPlayer(FChildren.EObjects[I]).FHeroes.Count;
end;

function TPlayerList.GetNumberOfPlayers: Byte;
begin
  Result := FChildren.Count - 1;
end;

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

procedure TPlayerList.SetNumberOfPlayers(Value: Byte);
var
  Player: TPlayer;
begin
  if Value < 2 then Value := 2;
  if Value > 12 then Value := 12;
  while Count <= Value do
  begin
    Player := TPlayer.Create(nil);
    Player.SetPlayerIndex(Count);
    if Count = 0 then Player.FPlayerType := ptIndependent;
    Player.FPlayerRace := Count - 1;
    Player.SetArrayOwner(Self, Count);
  end;
  while Count > Value + 1 do
  begin
    GetPlayers(Count - 1).Destroy;
    FChildren.Delete(Count - 1);
  end;
end;

procedure TPlayerList.ValidateRaces(Races: TRaceList);
var
  Available, Invalid: TIntegerList;
  I, Index, DefaultRace: Integer;
begin
  Available := TIntegerList.Create;
  Invalid := TIntegerList.Create;
  for I := 0 to Races.Count - 1 do
    if Races.GetRace(I).FEnabled then Available.Add(I);
  for I := 1 to FChildren.Count - 1 do
  begin
    Index := Available.IndexOf(TPlayer(FChildren.List^[I]).FPlayerRace);
    if Index = -1 then Invalid.Add(I)
    else Available.Delete(Index);
  end;
  I := 0;
  DefaultRace := -1;
  while (I <> AoWHSSet.FRaceResources.Count) and (DefaultRace = -1) do
  begin
    if AoWHSSet.FRaceResources.GetRaceResource(I) <> nil then
      if (Races = nil) or Races.GetRace(I).FEnabled then DefaultRace := I;
    Inc(I);
  end;
  for I := 0 to Invalid.Count - 1 do
    if Available.Count = 0 then TPlayer(FChildren.List^[Invalid[I]]).SetRace(DefaultRace)
    else
    begin
      TPlayer(FChildren.List^[Invalid[I]]).SetRace(Available[0]);
      Available.Delete(0);
    end;
  Invalid.Free;
  Available.Free;
end;

function TPlayerList.VerifyRaces(Races: TRaceList): Integer;
var
  Valid: Boolean;
  I, J: Integer;
  Player: TPlayer;
begin
  Valid := True;
  I := 1;
  while Valid and (I < FChildren.Count) do
  begin
    Player := TPlayer(FChildren.List^[I]);
    Valid := (Player.FPlayerRace <> -1) and Races.GetRace(Player.FPlayerRace).FEnabled;
    if Valid then
    begin
      J := 1;
      while Valid and (J <> FChildren.Count) do
      begin
        Valid := (J = I) or (GetPlayers(J).FPlayerRace <> Player.FPlayerRace);
        Inc(J);
      end;
    end;
    if Valid then Inc(I);
  end;
  if Valid then Result := 0
  else Result := I;
end;

function TPlayerList.GetSuperiorPlayer: Shortint;
var
  Maximum, BestPlayer, I, Value: Integer;
begin
  Maximum := 0;
  BestPlayer := -1;
  for I := 1 to Count - 1 do
    if GetPlayers(I).FStatus = psPlaying then
    begin
      Value := GetPlayers(I).GetSuperiority;
      if Value > Maximum then
      begin
        Maximum := Value;
        BestPlayer := I;
      end;
    end;
  Result := BestPlayer;
end;

function TPlayerList.IndexOfPlayerType(PlayerType: TPlayerType): Integer;
var
  I: Integer;
begin
  I := Count;
  repeat
    if I = 0 then
    begin
      Result := -1;
      Exit;
    end;
    Dec(I);
  until GetPlayers(I).FPlayerType = PlayerType;
  Result := I;
end;

constructor TLeaderSetupControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FItems := TIntegerList.Create;
  FOriginalLeader := TLeader.Create(nil);
  FLeader := TLeader.Create(nil);
  FRefCount := 1;
  FMode := [lsmLook, lsmSettings, lsmSpheres];
  TMethod(FOnDone).Code := nil;
  TMethod(FOnDone).Data := nil;
end;

destructor TLeaderSetupControl.Destroy;
begin
  FOriginalLeader.Free;
  FLeader.Free;
  FItems.Free;
  inherited Destroy;
end;

function TLeaderSetupControl.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TLeaderSetupControl.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if Result = 0 then Destroy;
end;

function TLeaderSetupControl.Done: Boolean;
begin
  if Assigned(FOnDone) then FOnDone(Self);
  Result := True;
end;

constructor TPlayerControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDisconnectedPlayers := TDoubleItemList.Create;
end;

destructor TPlayerControl.Destroy;
begin
  if (AoWHSMap <> nil) and (AoWHSMap.FTokenManager <> nil) then
    with AoWHSMap.FTokenManager.TokenExecuter do
    begin
      OnGetSyncValue := nil;
      OnSyncError := nil;
    end;
  FDisconnectedPlayers.Free;
  inherited Destroy;
end;

procedure TPlayerControl.Setup;
var
  I: Integer;
  PCC: TLocalPCC;
begin
  if (AoWHSMap.FConnectionType = pcNetwork) and not (msEditting in AoWHSMap.Status) then
  begin
    if AoWHSMap.FPlayerCommunicator.PCC = nil then
      raise Exception.Create('Please setup DirectPlayPCC');
    with AoWHSMap.FTokenManager.TokenExecuter do
    begin
      OnGetSyncValue := Self.GetSyncValue;
      OnSyncError := OutOfSync;
    end;
  end
  else if ((msEditting in AoWHSMap.Status) or (AoWHSMap.FConnectionType in [pcLocal, pcEmail])) and
    (AoWHSMap.FPlayerCommunicator.PCC = nil) then
  begin
    PCC := TLocalPCC.Create;
    PCC.Setup(AoWHSMap.FPlayers.Count);
    for I := 0 to AoWHSMap.FPlayers.Count - 1 do
      if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman then
        PCC.SetConnectionMode(I, cmLocal)
      else PCC.SetConnectionMode(I, cmGlobal);
    AoWHSMap.FPlayerCommunicator.ActivatePCC(PCC);
    PCC.Release;
    AoWHSMap.FPlayers.Update;
  end;
end;

procedure TPlayerControl.GetSyncValue(var Value: Integer);
begin
  Value := AoWHSMap.FDefendersSeed;
end;

procedure TPlayerControl.OutOfSync(Sender: TObject);
var
  Log: TPlayerConnectionEventLog;
begin
  if AoWHSMap.FTokenManager.TokenExecuter.ActiveTC.Active then
    if not FOutOfSyncShown then
    begin
      Log := TPlayerConnectionEventLog.Create(nil);
      Log.Setup(-1, 3);
      AoWHSMap.TriggerExecuteEventLog(Log, AoWHSMap.FCombat <> nil, nil);
      Log.Release;
      FOutOfSyncShown := True;
    end
    else AoWHSMap.FTokenManager.TokenExecuter.Lock;
end;

procedure TPlayerControl.NewFrame;
begin
  ValidateTurnTiming;
  ValidateDisconnectedPlayers;
end;

procedure TPlayerControl.NewDay;
var
  Msg: TEMsg;
  Log: TTextEventLog;
  MessageLog: TMessageEventLog;
  I: Integer;
begin
  Inc(AoWHSMap.FDay);
  AoWHSMap.FPlayers.BeginUpdate;
  AoWHSMap.LockRelationsChanged;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
  begin
    Log := TNewDayEventLog.Create(nil);
    Log.FText := Format(TranslateRStr(NewDayRStr), [AoWHSMap.FDay]);
    if (AoWHSMap.FDayLimit <> 0) and (AoWHSMap.FDayLimit - AoWHSMap.FDay <= 10) then
      Log.FText := Log.FText + ' (' + FmtDaysLeftStr(AoWHSMap.FDayLimit - AoWHSMap.FDay) + ')';
    Log.FPlayer := I;
    AoWHSMap.FPlayers.GetPlayers(I).FEventLogbook.AddEvent(Log);
    Log.Release;
  end;
  if AoWHSMap.FTurnOrderMode = toChanging then AoWHSMap.GenerateNewTurnOrder;
  if AoWHSMap.FDay = 1 then
  begin
    AoWHSMap.FRaces.ResetPlayerRelations;
    if AoWHSMap.FConnectionType = pcLocal then
    begin
      Randomize;
      AoWHSMap.FInitialRandomSeed := RandSeed;
    end;
    AoWHSMap.FDefendersSeed := AoWHSMap.FInitialRandomSeed;
  end;
  try
    InitMsg(Msg, $20020001, Self);
    AoWHSMap.SendMsg(Msg, Self);
  except
  end;
  try
    AoWHSMap.FNewDayEvents.TriggerNotifyEvents(Self);
  except
  end;
  if AoWHSMap.FDayLimit = AoWHSMap.FDay then
  begin
    MessageLog := TMessageEventLog.Create(nil);
    MessageLog.FTitle := TranslateRStr(InfoRStr);
    MessageLog.FButtons := mebOk;
    MessageLog.FLayout := melNormal;
    MessageLog.FMessage.Text := TranslateRStr(TurnLimitReachedRStr);
    AoWHSMap.TriggerExecuteEventLog(MessageLog, False, nil);
    MessageLog.Release;
    AoWHSMap.GameOver(AoWHSMap.FSeatedPlayer, goLost);
    for I := 1 to AoWHSMap.FPlayers.Count - 1 do AoWHSMap.GameOver(I, goLost);
  end;
  AoWHSMap.UnlockRelationsChanged;
  AoWHSMap.TriggerRelationsChanged;
  AoWHSMap.FPlayers.EndUpdate;
end;

procedure TPlayerControl.AutoSave;
var
  FileName: string;
begin
  if AoWHSMap.FGameType = gtCampaign then
    try
      FileName := 'autosave.acg';
      AoWEngine.SaveCampaign(AoWEngine.StartupDirectory + 'Save\' + FileName);
    except
      AoWHSMap.ShowWarning(Format(TranslateRStr(CouldNotSaveXRStr), [FileName]));
    end
  else
    try
      FileName := 'autosave.asg';
      AoWEngine.SaveHSM(AoWEngine.StartupDirectory + 'Save\' + FileName, nil);
    except
      AoWHSMap.ShowWarning(Format(TranslateRStr(CouldNotSaveXRStr), [FileName]));
    end;
end;

procedure TPlayerControl.EndTurn(Player: Shortint);
var
  Msg: TEMsg;
  X, Y, L: Integer;
  P: TPlayer;
begin
  AoWHSMap.LockRelationsChanged;
  if Player = AoWHSMap.FSeatedPlayer then
  begin
    P := AoWHSMap.FPlayers.GetPlayers(Player);
    P.SetEndTurn(True);
    if P <> nil then
    begin
      AoWHSMap.GetViewCenter(X, Y, L);
      P.FViewX := X; P.FViewY := Y; P.FViewL := L;
    end;
  end;
  InitMsg(Msg, $20020007, Self);
  Msg.Value := Player;
  AoWHSMap.SendMsg(Msg, Self);
  AoWHSMap.UnlockRelationsChanged;
  AoWHSMap.TriggerRelationsChanged;
end;

procedure TPlayerControl.NewTurn(Player: Shortint);
var
  Msg: TEMsg;
begin
  if AoWHSMap.FDay <> 1 then
  begin
    AoWHSMap.FPlayers.GetPlayers(Player).SetGems(
      AoWHSMap.FPlayers.GetPlayers(Player).FGems +
      AoWHSMap.FPlayers.GetPlayers(Player).FIncome -
      AoWHSMap.FPlayers.GetPlayers(Player).GetUpkeep);
    if AoWHSMap.FPlayers.GetPlayers(Player).FGems < 0 then
    begin
      AoWHSMap.FPlayers.GetPlayers(Player).SetGems(0);
      Dec(AoWHSMap.FPlayers.GetPlayers(Player).FMoraleValue, 5);
      if AoWHSMap.FPlayers.GetPlayers(Player).FMoraleValue < -50 then
        AoWHSMap.FPlayers.GetPlayers(Player).FMoraleValue := -50;
    end
    else AoWHSMap.FPlayers.GetPlayers(Player).FMoraleValue := 0;
    AoWHSMap.FPlayers.GetPlayers(Player).SetEndTurn(False);
  end;
  Inc(AoWHSMap.FPlayers.GetPlayers(Player).FDay);
  AoWHSMap.LockUpdateVisibility;
  InitMsg(Msg, $20020002, Self);
  Msg.Value := Player;
  AoWHSMap.SendMsg(Msg, Self);
  AoWHSMap.FNewTurnEvents.TriggerNotifyEvents(TObject(Integer(Player)));
  InitMsg(Msg, $20020003, Self);
  Msg.Value := Player;
  AoWHSMap.SendMsg(Msg, Self);
  AoWHSMap.UnLockUpdateVisibility;
  if AoWHSMap.FDebugSave then
    try
      if AoWHSMap.FPlayMode = pmSimultaneous then
      begin
        if Player = 0 then
          AoWEngine.SaveHSM(AoWEngine.StartupDirectory + 'DEBUG\' + AoWHSMap.FMapName +
            IntToStr(AoWHSMap.FDay) + '_p' + IntToStr(AoWHSMap.FSeatedPlayer) +
            '.asg', nil);
      end
      else
        AoWEngine.SaveHSM(AoWEngine.StartupDirectory + 'DEBUG\' + AoWHSMap.FMapName +
          IntToStr(AoWHSMap.FDay) + '-' + IntToStr(Player) + '_p' +
          IntToStr(AoWHSMap.FSeatedPlayer) + '.asg', nil);
    except
    end;
end;

procedure TPlayerControl.StartNewMap;
var
  I: Integer;
begin
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    if (I = 0) or (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptIndependent) then
      AoWHSMap.FPlayers.GetPlayers(I).FStatus := psPlaying;
end;

procedure TPlayerControl.StartLoadedMap;
begin end;

procedure TPlayerControl.SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus);
begin
  AoWHSMap.FPlayers.GetPlayers(Player).SetGameOverStatus(Status);
end;

procedure TPlayerControl.GameOver(Player: Shortint; Status: TGameOverStatus);
var
  I: Integer;
begin
  if (AoWHSMap.FPlayers.GetPlayers(Player).FGameOverStatus <> Status) and
    (AoWHSMap.FPlayers.GetPlayers(Player).FStatus <> psTerminated) then
  begin
    AoWHSMap.LockGameOverEvent;
    SetPlayerGameOverStatus(Player, Status);
    if Status = goLost then
    begin
      if not AoWHSMap.FAlliedVictory then
      begin
        if AoWHSMap.FPlayers.FActivePlayers.Count = 1 then
          GameOver(AoWHSMap.FPlayers.FActivePlayers[0], goWon);
      end
      else if AoWHSMap.FPlayers.GetActivePlayersAllied then
        for I := 1 to AoWHSMap.FPlayers.Count - 1 do
          if (I <> Player) and (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) and
            (AoWHSMap.FPlayers.GetPlayers(I).FGameOverStatus <> goLost) then
            SetPlayerGameOverStatus(I, goWon);
    end
    else if Status = goWon then
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        if (I <> Player) and (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) and
          (AoWHSMap.FPlayers.GetPlayers(I).FGameOverStatus <> goLost) then
          if (AoWHSMap.FPlayers.GetDiplomaticRelation(Player, I) = drAlliance) and
            AoWHSMap.FAlliedVictory then SetPlayerGameOverStatus(I, goWon)
          else SetPlayerGameOverStatus(I, goLost);
    AoWHSMap.UnlockGameOverEvent;
  end;
end;

procedure TPlayerControl.GameOverEventHandled(Player: Shortint);
begin
  AoWHSMap.FPlayers.GetPlayers(Player).FStatus := psTerminated;
end;

procedure TPlayerControl.SetSeatedPlayer(Player: Shortint);
begin
  if Player <> AoWHSMap.FSeatedPlayer then
  begin
    AoWHSMap.FSeatedPlayer := Player;
    AoWHSMap.SeatedPlayerChanged;
    AoWHSMap.ResetSeatedPlayerView;
  end;
end;

function TPlayerControl.LockAI: Boolean;
begin
  Result := (AoWHSMap.FConnectionType = pcLocal) and (AoWHSMap.FRequestCombatType = False) and
    (AoWHSMap.FAILockCount <> 0);
end;

procedure TPlayerControl.ListPlayerInfo(Strings: TStrings);
var
  I, Race: Integer;
  Text: string;
  PCC: TPlayerCommunicationControl;
begin
  PCC := AoWHSMap.FPlayerCommunicator.PCC;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
  begin
    Text := 'Player ' + IntToStr(I);
    Race := AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace;
    if Race <> -1 then Text := Text + '(' + TranslateRStr(RaceNamesPluralRStr[Race]) + ')';
    Text := Text + ' at system ' + IntToStr(PCC.Players[I].SystemID);
    if Strings <> nil then Strings.Add(Text);
    AoWEngine.OutputDebugStr(Text);
  end;
end;

procedure TPlayerControl.ExitSaveGameCallBack(Log: TEventLog);
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
  begin
    if AoWEngine.FCampaign <> nil then AoWEngine.SaveCampaign(TSaveGameEventLog(Log).FFileName)
    else AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
    AoWHSMap.ExecuteExitGame;
    if Assigned(FExitCallBack) then FExitCallBack(FExitMode, True);
  end
  else if Assigned(FExitCallBack) then FExitCallBack(FExitMode, False);
  FExitCallBack := nil;
end;

procedure TPlayerControl.SaveGameOnExitCallBack(Log: TEventLog);
var
  SaveLog: TSaveGameEventLog;
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
  begin
    if ((AoWEngine.FCampaign = nil) and ((AoWHSMap.FileName = '') or
      (CompareText(ExtractFileExt(AoWHSMap.FileName), '.hsm') = 0))) or
      ((AoWEngine.FCampaign <> nil) and ((AoWEngine.FCampaign.FFileName = '') or
      (CompareText(ExtractFileExt(AoWHSMap.FileName), '.csm') = 0))) then
    begin
      SaveLog := TSaveGameEventLog.Create(nil);
      if AoWHSMap.FileName <> '' then
      begin
        SaveLog.FDefaultName := ExtractFileName(AoWHSMap.FileName);
        if Pos('.', SaveLog.FDefaultName) <> 0 then
          SaveLog.FDefaultName := System.Copy(SaveLog.FDefaultName, 1, Pos('.', SaveLog.FDefaultName) - 1);
      end
      else SaveLog.FDefaultName := AoWHSMap.FMapName;
      SaveLog.FDirectory := AoWEngine.StartupDirectory + 'Save\';
      AoWHSMap.TriggerExecuteEventLog(SaveLog, False, ExitSaveGameCallBack);
      SaveLog.Release;
    end
    else
    begin
      with AoWEngine do
        if FCampaign <> nil then SaveCampaign(FCampaign.FFileName)
        else SaveHSM(AoWHSMap.FileName, nil);
      AoWHSMap.ExecuteExitGame;
      if Assigned(FExitCallBack) then FExitCallBack(FExitMode, True);
      FExitCallBack := nil;
    end;
  end
  else if TMessageEventLog(Log).FPressedButton = pebNo then
  begin
    AoWHSMap.ExecuteExitGame;
    if Assigned(FExitCallBack) then FExitCallBack(FExitMode, True);
    FExitCallBack := nil;
  end
  else if TMessageEventLog(Log).FPressedButton = pebCancel then
  begin
    if Assigned(FExitCallBack) then FExitCallBack(FExitMode, False);
    FExitCallBack := nil;
  end;
end;

procedure TPlayerControl.ExitNetworkGameCallBack(Log: TEventLog);
var
  TE: TTerminatePlayerTE;
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
    if (AoWHSMap.FPlayMode = pmSimultaneous) or (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) then
    begin
      TE := TTerminatePlayerTE.Create(nil);
      TE.FPlayer := AoWHSMap.FSeatedPlayer;
      TE.FExitCallBack := FExitCallBack;
      TE.FExitMode := FExitMode;
      AoWHSMap.FTokenManager.GetTokenControl(AoWHSMap.FSeatedPlayer).AddEvent(TE);
      TE.Release;
    end;
end;

procedure TPlayerControl.ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack);
var
  Log: TMessageEventLog;
begin
  if AoWHSMap.FCombat = nil then
  begin
    if (AoWHSMap.FConnectionType = pcNetwork) and (AoWHSMap.FGameStatus <> gsTerminated) and
      (AoWHSMap.FGameType <> gtTutorial) and (AoWHSMap.FPlayers.FLocalPlayers.Count > 1) then
    begin
      if (AoWHSMap.FPlayMode = pmSimultaneous) or (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) then
      begin
        FExitMode := Mode;
        FExitCallBack := Done;
        Log := TMessageEventLog.Create(nil);
        Log.FTitle := TranslateRStr(ConfirmRStr);
        Log.FButtons := mebYesNoCancel;
        Log.FLayout := melNormal;
        Log.FMessage.Add(TranslateRStr(YourAboutToExitAMultiPlayerGameRStr));
        Log.FMessage.Add(TranslateRStr(DoYouWantToContinueExitingRStr));
        AoWHSMap.TriggerExecuteEventLog(Log, False, ExitNetworkGameCallBack);
        Log.Release;
      end
      else
      begin
        Log := TMessageEventLog.Create(nil);
        Log.FTitle := TranslateRStr(MessageRStr);
        Log.FButtons := mebOk;
        Log.FLayout := melNormal;
        Log.FMessage.Add(TranslateRStr(PleaseWaitTillItIsYourTurnRStr));
        AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
        Log.Release;
      end;
    end
    else if (msModified in AoWHSMap.Status) and (AoWHSMap.FGameStatus <> gsTerminated) and
      (AoWHSMap.FGameType <> gtTutorial) then
    begin
      if not Assigned(FExitCallBack) then
      begin
        if Mode <> egmReload then
        begin
          FExitMode := Mode;
          FExitCallBack := Done;
          Log := TMessageEventLog.Create(nil);
          Log.FTitle := TranslateRStr(ConfirmRStr);
          Log.FButtons := mebYesNoCancel;
          if (AoWEngine.FCampaign = nil) and (AoWHSMap.FileName <> '') and
            (CompareText(ExtractFileExt(AoWHSMap.FileName), '.hsm') <> 0) then
          begin
            Log.FLayout := melNormal;
            Log.FMessage.Add(Format(TranslateRStr(SaveGameToXRStr), [ExtractFileName(AoWHSMap.FileName)]));
          end
          else if (AoWEngine.FCampaign <> nil) and (AoWEngine.FCampaign.FFileName <> '') and
            (CompareText(ExtractFileExt(AoWHSMap.FileName), '.csm') <> 0) then
          begin
            { Original tests the map extension when saving a campaign. }
            Log.FLayout := melNormal;
            Log.FMessage.Add(Format(TranslateRStr(SaveGameToXRStr), [ExtractFileName(AoWEngine.FCampaign.FFileName)]));
          end
          else
          begin
            Log.FLayout := melNormal;
            Log.FMessage.Add(TranslateRStr(DoYouWantToSaveThisGameRStr));
          end;
          AoWHSMap.TriggerExecuteEventLog(Log, False, SaveGameOnExitCallBack);
          Log.Release;
        end
        else Done(Mode, True);
      end
      else FExitCallBack(FExitMode, False);
    end
    else AoWHSMap.ExecuteExitGame;
  end
  else if Assigned(Done) then Done(Mode, False);
end;

procedure TPlayerControl.PasswordFailed;
begin
  AoWHSMap.ExecuteExitGame;
end;

procedure TPlayerControl.PasswordValidated;
begin end;

procedure TPlayerControl.PasswordTryAgainCallBack(Log: TEventLog);
var
  PasswordLog: TPasswordEventLog;
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
  begin
    PasswordLog := TPasswordEventLog.Create(nil);
    AoWHSMap.TriggerExecuteEventLog(PasswordLog, False, ValidatePasswordCallBack);
    PasswordLog.Release;
  end
  else PasswordFailed;
end;

procedure TPlayerControl.ValidatePasswordCallBack(Log: TEventLog);
var
  Password: string;
  MessageLog: TMessageEventLog;
begin
  Password := Encode(TPasswordEventLog(Log).FPassword, 0);
  if (TPasswordEventLog(Log).FPressedButton <> pebOk) or (Password <> FPassword) then
  begin
    MessageLog := TMessageEventLog.Create(nil);
    MessageLog.FTitle := TranslateRStr(WarningRStr);
    MessageLog.FButtons := mebYesNo;
    MessageLog.FMessage.Text := TranslateRStr(PasswordFailedRStr);
    MessageLog.FMessage.Add('');
    MessageLog.FMessage.Add(TranslateRStr(DoYouWantToTryAgainRStr));
    AoWHSMap.TriggerExecuteEventLog(MessageLog, False, PasswordTryAgainCallBack);
    MessageLog.Release;
  end
  else PasswordValidated;
end;

procedure TPlayerControl.ValidatePassword(const Password: string);
var
  Log: TPasswordEventLog;
begin
  if AoWHSMap.FSeatedPlayer <> -1 then SetSeatedPlayer(-1);
  FPassword := Password;
  Log := TPasswordEventLog.Create(nil);
  AoWHSMap.TriggerExecuteEventLog(Log, False, ValidatePasswordCallBack);
  Log.Release;
end;

procedure TPlayerControl.ValidateTurnTiming;
begin end;

procedure TPlayerControl.ValidateDisconnectedPlayers;
var
  I, Player, Count: Integer;
  Log: TPlayerConnectionEventLog;
begin
  for I := FDisconnectedPlayers.Count - 1 downto 0 do
  begin
    Player := FDisconnectedPlayers[I].A;
    if AoWHSMap.FPlayers.GetPlayers(Player).FGameOverStatus = goNone then
    begin
      if AoWHSMap.FTokenManager.PlayerReady(AoWHSMap.FCurrentPlayer) and
        (AoWHSMap.FTokenManager.TokenExecuter.ActiveTC.Count = 0) then
      begin
        Count := FDisconnectedPlayers[I].B;
        if Count > 0 then
        begin
          Dec(Count);
          FDisconnectedPlayers.List^[I].B := Count;
        end;
        if Count = 0 then
        begin
          Log := TPlayerConnectionEventLog.Create(nil);
          Log.Setup(Player, 2);
          AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
          Log.Release;
          FDisconnectedPlayers.Delete(I);
        end;
      end;
    end
    else FDisconnectedPlayers.Delete(I);
  end;
end;

procedure TPlayerControl.PlayerDisconnected(Player: Shortint);
begin
  if FDisconnectedPlayers.IndexOfItemA(Player) = -1 then FDisconnectedPlayers.AddAB(Player, 150);
end;

procedure TPlayerControl.ConnectionLost;
var
  Log: TPlayerConnectionEventLog;
begin
  Log := TPlayerConnectionEventLog.Create(nil);
  Log.Setup(-1, 2);
  AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
  Log.Release;
end;

function EndPlayerTurn(Player: Shortint): Boolean;
var
  Event: TEndTurnTE;
begin
  Event := TEndTurnTE.Create(nil);
  Event.FPlayer := Player;
  Event.FDay := AoWHSMap.FDay;
  Event.FMode := emEndTurn;
  AoWHSMap.FTokenManager.TokenControls[Player].AddEvent(Event);
  Event.Release;
  Result := True;
end;

class function TTurnPlayerControl.ClassID: Integer;
begin Result := $20250; end;

procedure TTurnPlayerControl.Setup;
begin
  inherited Setup;
  AoWHSMap.FTokenManager.TokenExecuter.HoldTC := True;
end;

procedure TTurnPlayerControl.NewDay;
var
  Player: Integer;
begin
  if AoWHSMap.FRequestCombatType then
  begin
    Player := AoWHSMap.FSeatedPlayer;
    AoWHSMap.FSeatedPlayer := -1;
    inherited NewDay;
    AoWHSMap.FSeatedPlayer := Player;
  end
  else inherited NewDay;
end;

procedure TTurnPlayerControl.NewTurn(Player: Shortint);
var
  Log: TNewTurnEventLog;
  BookLog: TShowBookEventLog;
  Spells: TSpellList;
  MagicLog: TPlayerMagicEventLog;
begin
  AoWHSMap.LockMapChangedEvent;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(Player);
  if AoWHSMap.FRequestCombatType then
  begin
    if AoWHSMap.FSeatedPlayer <> -1 then AoWHSMap.SetSeatedPlayer(-1);
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman then
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(ItsYourTurnRStr);
      AoWHSMap.TriggerExecuteEventLog(Log, False, ShowNewTurnCallBack);
      Log.Release;
    end
    else
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [];
      if Player = 0 then Log.FText := TranslateRStr(IndependentsAreMovingRStr)
      else Log.FText := Format(TranslateRStr(PlayerIsMovingRStr), [AoWHSMap.FPlayers.GetPlayers(Player).GetName]);
      AoWHSMap.TriggerExecuteEventLog(Log, True, nil);
      Log.Release;
    end;
  end
  else if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) and
    (Player = AoWHSMap.FSeatedPlayer) then
  begin
    if (AoWHSMap.FGameType <> gtTutorial) or (AoWHSMap.FDay <> 1) then
    begin
      AoWHSMap.ResetTurnTimer;
      AoWHSMap.EnableTurnTimer;
      AoWHSMap.ResetSeatedPlayerView;
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := Player;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(ItsYourTurnRStr);
      AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
      Log.Release;
      ReplayLogbook;
    end
    else AoWHSMap.FTutorialControl.ShowMessage(50, False, True);
  end;
  inherited NewTurn(Player);
  if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) and
    (AoWHSMap.FConnectionType <> pcEmail) and AoWEngine.FRegistry.GetAutoSave then AutoSave;
  AoWHSMap.UnlockMapChangedEvent;
  AoWHSMap.InvalidateMap;
  if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then
  begin
    AoWHSMap.FAIExecuter.ActivatePlayer(Player);
    if Player = 0 then AoWHSMap.ShowMessage(Format(TranslateRStr(AreMovingRStr), [TranslateRStr(IndependentsRStr)]))
    else AoWHSMap.ShowMessage(Format(TranslateRStr(AreMovingRStr),
      [TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace])]));
  end
  else
  begin
    PlaySample('SFX\EVENTS\NEWTURN.WAV');
    if (AoWHSMap.FDay = 1) and (AoWHSMap.FRequestCombatType or (Player = AoWHSMap.FSeatedPlayer)) then
    begin
      if AoWHSMap.FGameType in [gtCustom, gtTutorial] then
          begin
            BookLog := TShowBookEventLog.Create(nil);
            AoWHSMap.TriggerExecuteEventLog(BookLog, False, nil);
            BookLog.Release;
          end;
      if AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FResearchSpellID = 0 then
      begin
        Spells := TSpellList.Create;
        AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.ListResearchSpells(Spells, [stCombat, stUnit, stGlobal]);
        if Spells.GetCount > 0 then
        begin
          MagicLog := TPlayerMagicEventLog.Create(nil);
          MagicLog.FMode := pmemStartResearch;
          AoWHSMap.TriggerExecuteEventLog(MagicLog, False, nil);
          MagicLog.Release;
        end;
        Spells.Free;
      end;
      AoWHSMap.FTutorialControl.ShowMessage(52, False, True);
    end;
  end;
end;

procedure TTurnPlayerControl.ReplayLogbook;
var
  Book: TEventLogbook;
  Index, I: Integer;
begin
  Book := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FEventLogbook;
  Index := Book.FindFirstLogEx($202E3, AoWHSMap.FCurrentPlayer, AoWHSMap.FDay - 1);
  for I := Index + 1 to Book.GetCount - 1 do Book.GetLogs(I).Execute(False, etNewTurn, nil);
end;

procedure TTurnPlayerControl.SetSeatedPlayer(Player: Shortint);
begin
  AoWHSMap.LockMapChangedEvent;
  inherited SetSeatedPlayer(Player);
  AoWHSMap.UnlockMapChangedEvent;
  AoWHSMap.InvalidateMap;
end;

procedure TTurnPlayerControl.ShowNewTurnCallBack(Log: TEventLog);
begin
  SetSeatedPlayer(AoWHSMap.FCurrentPlayer);
  AoWHSMap.ResetTurnTimer;
  AoWHSMap.EnableTurnTimer;
  if AoWHSMap.FCurrentPlayer <> -1 then ReplayLogbook;
end;

procedure TTurnPlayerControl.StartGameCallBack(Log: TEventLog);
begin
  if AoWHSMap.FSeatedPlayer = -1 then SetSeatedPlayer(AoWHSMap.FCurrentPlayer);
  AoWHSMap.EnableTurnTimer;
end;

procedure TTurnPlayerControl.EndTurn(Player: Shortint);
var
  Log: TEndTurnEventLog;
  Index: Integer;
  Found: Boolean;
  NextPlayer: Shortint;
begin
  inherited EndTurn(Player);
  if Player = AoWHSMap.FSeatedPlayer then
  begin
    AoWHSMap.ZeroTurnTimer;
    if AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psPlaying then AoWHSMap.ClearExecuteEventLogBuffer;
    AoWHSMap.Selection.UnselectLocation;
  end;
  if Player = AoWHSMap.FCurrentPlayer then
  begin
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then AoWHSMap.FAIExecuter.DeactivatePlayer(Player);
    Log := TEndTurnEventLog.Create(nil);
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FEventLogbook.AddEvent(Log);
    Log.Release;
    Index := AoWHSMap.FTurnOrder.IndexOf(AoWHSMap.FCurrentPlayer);
    Found := False;
    while not Found do
    begin
      Inc(Index);
      if Index = AoWHSMap.FTurnOrder.Count then
      begin
        NewDay;
        Index := 0;
      end;
      NextPlayer := AoWHSMap.FTurnOrder[Index];
      Found := AoWHSMap.FPlayers.GetPlayers(NextPlayer).FStatus = psPlaying;
      if not Found then
      begin
        inherited NewTurn(NextPlayer);
        inherited EndTurn(NextPlayer);
      end;
    end;
    if AoWHSMap.FTurnOrder.Count <> 0 then NewTurn(AoWHSMap.FTurnOrder[Index])
    else NewTurn(0);
  end;
end;

procedure TTurnPlayerControl.DefaultStartMap;
begin
  AoWHSMap.FPlayers.Update;
  AoWHSMap.FRequestCombatType := (AoWHSMap.FConnectionType = pcEmail) or
    ((AoWHSMap.FConnectionType = pcLocal) and (AoWHSMap.FPlayers.FLocalHumanPlayers.Count > 1));
  AoWHSMap.FShowIndependentMoves := not AoWHSMap.FRequestCombatType;
end;

procedure TTurnPlayerControl.StartNewMap;
begin
  inherited StartNewMap;
  DefaultStartMap;
  NewDay;
  if not AoWHSMap.FRequestCombatType then
  begin
    AoWHSMap.SetSeatedPlayer(AoWHSMap.FPlayers.FLocalHumanPlayers[0]);
    AoWHSMap.ResetSeatedPlayerView;
  end;
  NewTurn(AoWHSMap.FTurnOrder[1]);
end;

procedure TTurnPlayerControl.StartLoadedMapEx;
var
  Log: TNewTurnEventLog;
begin
  DefaultStartMap;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
  if AoWHSMap.FRequestCombatType then
  begin
    AoWHSMap.SetSeatedPlayer(-1);
    if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPlayerType = ptHuman then
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(YourTurnContinuesRStr);
      AoWHSMap.TriggerExecuteEventLog(Log, False, StartGameCallBack);
      Log.Release;
    end
    else
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [];
      if AoWHSMap.FCurrentPlayer = 0 then Log.FText := TranslateRStr(IndependentsAreMovingRStr)
      else Log.FText := Format(TranslateRStr(PlayerIsMovingRStr),
        [AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).GetName]);
      AoWHSMap.TriggerExecuteEventLog(Log, True, nil);
      Log.Release;
    end;
  end
  else
  begin
    AoWHSMap.SetSeatedPlayer(AoWHSMap.FPlayers.FLocalHumanPlayers[0]);
    AoWHSMap.ResetSeatedPlayerView;
    if (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPlayerType = ptHuman) and
      (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) then
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FSeatedPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(YourTurnContinuesRStr);
      AoWHSMap.TriggerExecuteEventLog(Log, False, StartGameCallBack);
      Log.Release;
    end;
  end;
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPlayerType <> ptHuman then
    AoWHSMap.FAIExecuter.ActivatePlayer(AoWHSMap.FCurrentPlayer);
  AoWEngine.OutputDebugStr('Random Seed: ' + IntToStr(AoWHSMap.FDefendersSeed));
end;

procedure TTurnPlayerControl.PasswordValidated;
begin StartLoadedMapEx; end;

procedure TTurnPlayerControl.StartLoadedMap;
begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FSettings <> '' then
    ValidatePassword(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FSettings)
  else StartLoadedMapEx;
end;

procedure TTurnPlayerControl.GameOverEventHandled(Player: Shortint);
begin
  if AoWHSMap.FRequestCombatType then
  begin
    AoWHSMap.FPlayers.GetPlayers(Player).FStatus := psTerminated;
    AoWHSMap.FPlayers.Update;
    AoWHSMap.TriggerPlayerTerminatedEvent(Player);
    if AoWHSMap.FPlayers.FLocalHumanPlayers.Count = 0 then AoWHSMap.TriggerGameTerminatedEvent
    else EndPlayerTurn(AoWHSMap.FCurrentPlayer);
  end;
end;

procedure TTurnPlayerControl.SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus);
begin
  inherited SetPlayerGameOverStatus(Player, Status);
  if not AoWHSMap.FRequestCombatType or (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) then
  begin
    AoWHSMap.FPlayers.GetPlayers(Player).FStatus := psTerminated;
    AoWHSMap.FPlayers.Update;
    AoWHSMap.TriggerPlayerTerminatedEvent(Player);
    if (AoWHSMap.FCurrentPlayer = Player) and AoWHSMap.FPlayers.GetPlayers(Player).GetLocal then
      EndPlayerTurn(AoWHSMap.FCurrentPlayer);
    if AoWHSMap.FPlayers.FLocalHumanPlayers.Count = 0 then AoWHSMap.TriggerGameTerminatedEvent;
  end;
end;

procedure TTurnPlayerControl.GameOver(Player: Shortint; Status: TGameOverStatus);
begin
  AoWHSMap.LockGameOverEvent;
  inherited GameOver(Player, Status);
  AoWHSMap.UnlockGameOverEvent;
end;

procedure TTurnPlayerControl.ValidateTurnTiming;
begin
  if AoWHSMap.GetTurnTimerEnabled and (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) and
    (AoWHSMap.GetTurnTimeLeft <= 0) then
    if (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGameOverStatus = goNone) and
      (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSingleProcessCycle = False) then
      if AoWHSMap.FTokenManager.PlayerReady(AoWHSMap.FSeatedPlayer) then EndPlayerTurn(AoWHSMap.FSeatedPlayer);
end;

class function TPBEMPlayerControl.ClassID: Integer;
begin Result := $20253; end;

procedure TPBEMPlayerControl.TerminateEmailGame;
begin AoWHSMap.ExitGame(egmExit, nil); end;

procedure TPBEMPlayerControl.TerminateEmailGameCallBack(Log: TEventLog);
begin TerminateEmailGame; end;

procedure TPBEMPlayerControl.SendEmailGameAutomatedCallBack(Log: TEventLog);
var
  SendLog: TSendEmailGameEventLog;
begin
  Windows.DeleteFile(PChar(TSMTPEventLog(Log).FFileName));
  if not TSMTPEventLog(Log).FSuccess then
  begin
    SendLog := TSendEmailGameEventLog.Create(nil);
    SendLog.FMode := 1;
    SendLog.FSendPlayer := AoWHSMap.FCurrentPlayer;
    AoWHSMap.TriggerExecuteEventLog(SendLog, False, SendEmailGameCallBack);
    SendLog.Release;
  end
  else TerminateEmailGame;
end;

procedure TPBEMPlayerControl.SendEmailGameManualCallBack(Log: TEventLog);
var
  Failed: Boolean;
  MessageLog: TMessageEventLog;
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
    try
      AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
      AoWHSMap.ShowMessage(Format(TranslateRStr(GameSavedRStr), [TSaveGameEventLog(Log).FFileName]));
      Failed := False;
    except Failed := True;
    end
  else Failed := True;
  if Failed then
  begin
    MessageLog := TMessageEventLog.Create(nil);
    MessageLog.FMessage.Text := Format(TranslateRStr(CouldNotSaveXRStr) + '.', [TSaveGameEventLog(Log).FFileName]);
    AoWHSMap.TriggerExecuteEventLog(MessageLog, False, TerminateEmailGameCallBack);
    MessageLog.Release;
  end
  else
  begin
    MessageLog := TMessageEventLog.Create(nil);
    MessageLog.FMessage.Text := Format(TranslateRStr(GameSuccessfullySavedRStr) + '.', [TSaveGameEventLog(Log).FFileName]);
    AoWHSMap.TriggerExecuteEventLog(MessageLog, False, TerminateEmailGameCallBack);
    MessageLog.Release;
  end;
end;

procedure TPBEMPlayerControl.SendEmailGameCallBack(Log: TEventLog);
var
  SMTPLog: TSMTPEventLog;
  SaveLog: TSaveGameEventLog;
  TempPath: array[0..500] of Char;
  I: Integer;
begin
  case TSendEmailGameEventLog(Log).FMode of
    2: TerminateEmailGame;
    1:
      begin
        SaveLog := TSaveGameEventLog.Create(nil);
        SaveLog.FTitle := TranslateRStr(SaveEmailGameRStr);
        SaveLog.FDefaultName := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName;
        SaveLog.FDirectory := AoWEngine.StartupDirectory + 'EmailOut\';
        AoWHSMap.TriggerExecuteEventLog(SaveLog, False, SendEmailGameManualCallBack);
        SaveLog.Release;
      end;
    0:
      begin
        GetTempPath(SizeOf(TempPath), TempPath);
        SMTPLog := TSMTPEventLog.Create(nil);
        SMTPLog.FSubject := Format(TranslateRStr(AoWEmailGameXRStr),
          [AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName]);
        SMTPLog.FFromAddress := AoWEngine.FRegistry.GetLocalEmailAddress;
        SMTPLog.FToAddress := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FEmailAddress;
        SMTPLog.FFileName := TempPath + AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName + '.asg';
        SMTPLog.FMessage.Add(TranslateRStr(AgeOfWondersEmailGameRStr));
        SMTPLog.FMessage.Add('--------------------------------------------------------');
        SMTPLog.FMessage.Add(Format(TranslateRStr(NameXRStr),
          [AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName]));
        SMTPLog.FMessage.Add(Format(TranslateRStr(MapXRStr), [AoWHSMap.FMapName]));
        SMTPLog.FMessage.Add(Format(TranslateRStr(TurnXRStr), [IntToStr(AoWHSMap.FDay)]));
        SMTPLog.FMessage.Add('');
        SMTPLog.FMessage.Add(TranslateRStr(PlayersRStr) + ':');
        for I := 1 to AoWHSMap.FPlayers.Count - 1 do
          if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman then
            SMTPLog.FMessage.Add(Format(TranslateRStr(XatYRStr),
              [AoWHSMap.FPlayers.GetPlayers(I).GetName, AoWHSMap.FPlayers.GetPlayers(I).FPBEMSettings.FEmailGame.FEmailAddress]));
        AoWEngine.SaveHSM(SMTPLog.FFileName, nil);
        AoWHSMap.TriggerExecuteEventLog(SMTPLog, False, SendEmailGameAutomatedCallBack);
        SMTPLog.Release;
      end;
  end;
end;

procedure TPBEMPlayerControl.NewTurn(Player: Shortint);
var
  Log: TSendEmailGameEventLog;
begin
  if (pbsNewTurn in AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus) or
    (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) or
    (AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psTerminated) then
  begin
    inherited NewTurn(Player);
    AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus - [pbsNewTurn, pbsTurnDone] + [pbsPlaying];
  end
  else
  begin
    if (AoWHSMap.FPlayers.FLocalPlayers.Count > 1) or (Player <> FLocalPlayer) then
    begin
      AoWHSMap.SetCurrentPlayer(Player);
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
        AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus + [pbsNewTurn];
      Log := TSendEmailGameEventLog.Create(nil);
      Log.FMode := 2;
      Log.FSendPlayer := Player;
      AoWHSMap.TriggerExecuteEventLog(Log, False, SendEmailGameCallBack);
      Log.Release;
    end
    else
    begin
      inherited NewTurn(Player);
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
        AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus - [pbsNewTurn, pbsTurnDone] + [pbsPlaying];
    end;
  end;
end;

procedure TPBEMPlayerControl.TriggerGameRestartedEvents(Player: Shortint);
var
  Log: TRestartGameEventLog;
begin
  AoWHSMap.SynchroniseBegin;
  Log := TRestartGameEventLog.Create(nil);
  Log.FPlayer := Player;
  Log.FMessage.Text := Format(TranslateRStr(GameRestartEventLogXRStr), [AoWHSMap.FPlayers.GetPlayers(Player).GetName]);
  DistributeEventLog(Log, False);
  Log.Release;
  AoWHSMap.SynchroniseEnd;
end;

procedure TPBEMPlayerControl.EndTurnGameSavedCallBack(Log: TEventLog);
var
  Failed: Boolean;
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
    try
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus :=
        (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus + [pbsTurnDone]) - [pbsPlaying];
      AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
      AoWHSMap.ShowMessage(Format(TranslateRStr(GameSavedRStr), [TSaveGameEventLog(Log).FFileName]));
      AoWHSMap.SynchroniseBegin;
      inherited EndTurn(AoWHSMap.FCurrentPlayer);
      AoWHSMap.SynchroniseEnd;
      Failed := False;
    except
      AoWHSMap.ShowWarning(Format(TranslateRStr(CouldNotSaveXRStr), [TSaveGameEventLog(Log).FFileName]));
      Failed := True;
    end
  else Failed := True;
  if Failed then AoWHSMap.TriggerEndTurnEvent(AoWHSMap.FCurrentPlayer);
end;

procedure TPBEMPlayerControl.EndTurn(Player: Shortint);
var
  SaveLog: TSaveGameEventLog;
  MessageLog: TMessageEventLog;
  Saved: Boolean;
begin
  if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) and
    (AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psPlaying) then
  begin
    if CompareText(ExtractFileExt(AoWHSMap.FileName), '.hsm') = 0 then
    begin
      SaveLog := TSaveGameEventLog.Create(nil);
      SaveLog.FTitle := TranslateRStr(SaveEmailGameRStr);
      if AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FEmailGame.FName <> '' then
        SaveLog.FDefaultName := AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FEmailGame.FName + '.asg';
      SaveLog.FDirectory := AoWEngine.StartupDirectory + 'EmailIn\';
      AoWHSMap.TriggerExecuteEventLog(SaveLog, False, EndTurnGameSavedCallBack);
      SaveLog.Release;
    end
    else
    begin
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
        (AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus + [pbsTurnDone]) - [pbsPlaying];
      try
        AoWEngine.SaveHSM(AoWHSMap.FileName, nil);
        Saved := True;
      except Saved := False;
      end;
      if Saved then inherited EndTurn(AoWHSMap.FCurrentPlayer)
      else
      begin
        MessageLog := TMessageEventLog.Create(nil);
        MessageLog.FMessage.Text := Format(TranslateRStr(CouldNotSaveXRStr) + '.', [AoWHSMap.FileName]);
        AoWHSMap.TriggerExecuteEventLog(MessageLog, False, TerminateEmailGameCallBack);
        MessageLog.Release;
      end;
    end;
  end
  else inherited EndTurn(AoWHSMap.FCurrentPlayer); { Original uses current player, ignoring Player here. }
end;

procedure TPBEMPlayerControl.StartLoadedEmailGame;
begin
  AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FLastDay := AoWHSMap.FDay;
  AoWEngine.FEmailGames.UpdateGame(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame);
  AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus :=
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus + [pbsPlaying];
  if pbsNewTurn in AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus then
  begin
    AoWHSMap.SynchroniseBegin;
    DefaultStartMap;
    AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
    NewTurn(AoWHSMap.FCurrentPlayer);
    AoWHSMap.SynchroniseEnd;
  end
  else StartLoadedMapEx;
end;

procedure TPBEMPlayerControl.ContinueRestartedGameCallBack(Log: TEventLog);
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
  begin
    AoWHSMap.SynchroniseBegin;
    TriggerGameRestartedEvents(AoWHSMap.FCurrentPlayer);
    AoWHSMap.SynchroniseEnd;
    StartLoadedEmailGame;
  end
  else AoWHSMap.ExecuteExitGame;
end;

procedure TPBEMPlayerControl.ContinueTurnDoneGameCallBack(Log: TEventLog);
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
  begin
    AoWHSMap.SynchroniseBegin;
    DefaultStartMap;
    AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
    EndTurn(AoWHSMap.FCurrentPlayer);
    AoWHSMap.SynchroniseEnd;
  end
  else AoWHSMap.ExecuteExitGame;
end;

procedure TPBEMPlayerControl.ValidateLoadedMap;
var
  Restarted: Boolean;
  Log: TMessageEventLog;
begin
  FLocalPlayer := AoWHSMap.FCurrentPlayer;
  if AoWEngine.FEmailGames.FindEmailGame(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame) = nil then
  begin
    Restarted := AoWEngine.FEmailGames.EmailGameRestarted(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame);
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.SetGame(AoWEngine.FEmailGames.CreateEmailGame(
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName,
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FEmailAddress));
    if Restarted then TriggerGameRestartedEvents(AoWHSMap.FCurrentPlayer);
    StartLoadedEmailGame;
  end
  else
  begin
    if AoWEngine.FEmailGames.EmailGameRestarted(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame) then
    begin
      SetSeatedPlayer(-1);
      Log := TMessageEventLog.Create(nil);
      Log.FButtons := mebYesNo;
      Log.FTitle := TranslateRStr(WarningRStr);
      Log.FMessage.Text := TranslateRStr(PBEMRestartCheatRStr);
      Log.FMessage.Add('');
      Log.FMessage.Add(TranslateRStr(DoYouWantToContinueRStr));
      AoWHSMap.TriggerExecuteEventLog(Log, False, ContinueRestartedGameCallBack);
      Log.Release;
    end
    else
    begin
      SetSeatedPlayer(-1);
      if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus * [pbsNewTurn, pbsTurnDone] = [pbsTurnDone] then
      begin
        Log := TMessageEventLog.Create(nil);
        Log.FTitle := TranslateRStr(WarningRStr);
        Log.FButtons := mebYesNo;
        Log.FMessage.Text := TranslateRStr(PBEMGameEndedRStr);
        Log.FMessage.Add('');
        Log.FMessage.Add(TranslateRStr(DoYouWantToContinueRStr));
        AoWHSMap.TriggerExecuteEventLog(Log, False, ContinueTurnDoneGameCallBack);
        Log.Release;
      end
      else StartLoadedEmailGame;
    end;
  end;
end;

procedure TPBEMPlayerControl.PasswordValidated;
begin ValidateLoadedMap; end;

procedure TPBEMPlayerControl.StartLoadedMap;
begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FSettings <> '' then
    ValidatePassword(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FSettings)
  else ValidateLoadedMap;
end;

procedure TPBEMPlayerControl.StartNewMap;
var
  I: Integer;
  Player: Byte;
begin
  DefaultStartMap;
  NewDay;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    if (I = 0) or (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptIndependent) then
      AoWHSMap.FPlayers.GetPlayers(I).FStatus := psPlaying;
  I := 0;
  while (I < AoWHSMap.FTurnOrder.Count) and
    (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FTurnOrder[I]).FPlayerType <> ptHuman) do Inc(I);
  Player := AoWHSMap.FTurnOrder[I];
  if (AoWEngine.FEmailGames.FindEmailGame(AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FEmailGame) <> nil) and
    (CompareText(AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FEmailGame.FEmailAddress, AoWEngine.FRegistry.GetLocalEmailAddress) = 0) then
  begin
    FLocalPlayer := Player;
    AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus + [pbsNewTurn];
  end
  else AoWHSMap.SetSeatedPlayer(-1);
  NewTurn(AoWHSMap.FTurnOrder[1]);
end;

procedure TPBEMPlayerControl.ExitGameSaveAsCallBack(Log: TEventLog);
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
    try
      AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
      AoWHSMap.ExecuteExitGame;
    except
      AoWHSMap.ShowWarning(Format(TranslateRStr(CouldNotSaveXRStr), [TSaveGameEventLog(Log).FFileName]));
    end;
end;

procedure TPBEMPlayerControl.ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack);
var
  Log: TSaveGameEventLog;
begin
  if pbsPlaying in AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus then
  begin
    if CompareText(ExtractFileExt(AoWHSMap.FileName), '.hsm') = 0 then
    begin
      Log := TSaveGameEventLog.Create(nil);
      Log.FTitle := TranslateRStr(SaveEmailGameRStr);
      if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName <> '' then
        Log.FDefaultName := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName + '.asg';
      Log.FDirectory := AoWEngine.StartupDirectory + 'EmailIn\';
      AoWHSMap.TriggerExecuteEventLog(Log, False, ExitGameSaveAsCallBack);
      Log.Release;
    end
    else
    begin
      AoWEngine.SaveHSM(AoWHSMap.FileName, nil);
      AoWHSMap.ExecuteExitGame;
    end;
  end
  else AoWHSMap.ExecuteExitGame;
end;

class function TSimultaniousPlayerControl.ClassID: Integer;
begin Result := $20251; end;

procedure TSimultaniousPlayerControl.NewTurn(Player: Shortint);
var
  Log: TEventLog;
  Spells: TSpellList;
begin
  if Player = AoWHSMap.FSeatedPlayer then
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman then
    begin
      if AoWHSMap.FDay = 1 then
      begin
        if AoWHSMap.FGameType = gtCustom then
        begin
          Log := TShowBookEventLog.Create(nil);
          AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
          Log.Release;
        end;
        if AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FResearchSpellID = 0 then
        begin
          Spells := TSpellList.Create;
          AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.ListResearchSpells(Spells, [stCombat, stUnit, stGlobal]);
          if Spells.GetCount > 0 then
          begin
            Log := TPlayerMagicEventLog.Create(nil);
            TPlayerMagicEventLog(Log).FMode := pmemStartResearch;
            AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
            Log.Release;
          end;
          Spells.Free;
        end;
      end
      else
      begin
        AoWHSMap.ResetTurnTimer;
        AoWHSMap.EnableTurnTimer;
      end;
    end;
  inherited NewTurn(Player);
  if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then
    if AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psPlaying then AoWHSMap.FAIExecuter.ActivatePlayer(Player);
end;

procedure TSimultaniousPlayerControl.Setup;
begin
  inherited Setup;
  AoWHSMap.FTokenManager.TokenExecuter.HoldTC := False;
end;

procedure TSimultaniousPlayerControl.EndTurn(Player: Shortint);
var
  I: Integer;
  AllDone: Boolean;
  Log: TEndTurnEventLog;
  Msg: TEMsg;
begin
  AoWHSMap.FPlayers.GetPlayers(Player).SetEndTurn(True);
  AllDone := True;
  I := 1;
  while AllDone and (I <> AoWHSMap.FPlayers.Count) do
  begin
    AllDone := (AoWHSMap.FPlayers.GetPlayers(I).FStatus <> psPlaying) or
      AoWHSMap.FPlayers.GetPlayers(I).FSingleProcessCycle;
    Inc(I);
  end;
  if AllDone then
  begin
    if AoWHSMap.FSeatedPlayer = Player then AoWHSMap.ClearExecuteEventLogBuffer;
    AoWHSMap.LockRelationsChanged;
    for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    begin
      if AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying then
      begin
        if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptHuman then AoWHSMap.FAIExecuter.DeactivatePlayer(I);
        Log := TEndTurnEventLog.Create(nil);
        AoWHSMap.FPlayers.GetPlayers(I).FEventLogbook.AddEvent(Log);
        Log.Release;
      end;
      InitMsg(Msg, $20020007, Self);
      Msg.Value := I;
      AoWHSMap.SendMsg(Msg, Self);
    end;
    AoWHSMap.UnlockRelationsChanged;
    NewDay;
  end;
end;

procedure TSimultaniousPlayerControl.NewDay;
var
  I: Integer;
begin
  AoWHSMap.Selection.UnselectLocation;
  inherited NewDay;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do NewTurn(I);
  PlaySample('SFX\EVENTS\NEWTURN.WAV');
  if AoWEngine.FRegistry.GetAutoSave then AutoSave;
end;

procedure TSimultaniousPlayerControl.StartGameCallBack(Log: TEventLog);
begin
  if AoWHSMap.FConnectionType <> pcNetwork then
  begin
    AoWHSMap.FAIExecuter.Unlock;
    AoWHSMap.ResetTurnTimer;
    AoWHSMap.EnableTurnTimer;
  end;
end;

procedure TSimultaniousPlayerControl.StartNewMap;
var
  I: Integer;
  Log: TNewTurnEventLog;
begin
  inherited StartNewMap;
  AoWHSMap.FShowIndependentMoves := False;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    if (I = 0) or (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptIndependent) then
      AoWHSMap.FPlayers.GetPlayers(I).FStatus := psPlaying;
  AoWHSMap.FPlayers.Update;
  AoWHSMap.FCurrentPlayer := 0;
  AoWHSMap.SetSeatedPlayer(AoWHSMap.FPlayers.FLocalHumanPlayers[0]);
  AoWHSMap.SeatedPlayerChanged;
  Assert(AoWHSMap.FSeatedPlayer <> 0);
  AoWHSMap.ResetSeatedPlayerView;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
  Log := TNewTurnEventLog.Create(nil);
  Log.FTurnPlayer := AoWHSMap.FSeatedPlayer;
  Log.FMode := ntDialog;
  Log.FDialogStyle := [nsCloseable];
  Log.FText := TranslateRStr(LetTheGameBeginRStr);
  AoWHSMap.TriggerExecuteEventLog(Log, False, StartGameCallBack);
  Log.Release;
  if AoWHSMap.FConnectionType = pcNetwork then
  begin
    AoWHSMap.ResetTurnTimer;
    AoWHSMap.EnableTurnTimer;
  end
  else AoWHSMap.FAIExecuter.Lock;
  NewDay;
end;

procedure TSimultaniousPlayerControl.StartLoadedMapEx;
var
  I: Integer;
  Log: TNewTurnEventLog;
  Player: TPlayer;
begin
  AoWHSMap.FShowIndependentMoves := False;
  AoWHSMap.SetSeatedPlayer(AoWHSMap.FPlayers.FLocalHumanPlayers[0]);
  AoWHSMap.SeatedPlayerChanged;
  AoWHSMap.ResetSeatedPlayerView;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
  begin
    Player := AoWHSMap.FPlayers.GetPlayers(I);
    if (Player.FStatus = psPlaying) and (Player.FPlayerType <> ptHuman) then AoWHSMap.FAIExecuter.ActivatePlayer(I);
  end;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    if AoWHSMap.FPlayers.GetPlayers(I).FStatus <> psPlaying then AoWHSMap.FTokenManager.TokenControls[I].Active := False;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
  Log := TNewTurnEventLog.Create(nil);
  Log.FTurnPlayer := AoWHSMap.FSeatedPlayer;
  Log.FMode := ntDialog;
  Log.FDialogStyle := [nsCloseable];
  Log.FText := TranslateRStr(TheGameContinuesRStr);
  AoWHSMap.TriggerExecuteEventLog(Log, False, StartGameCallBack);
  Log.Release;
  if AoWHSMap.FConnectionType = pcNetwork then
  begin
    AoWHSMap.ResetTurnTimer;
    AoWHSMap.EnableTurnTimer;
  end
  else AoWHSMap.FAIExecuter.Lock;
end;

procedure TSimultaniousPlayerControl.PasswordValidated;
begin StartLoadedMapEx; end;

procedure TSimultaniousPlayerControl.StartLoadedMap;
begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FPlayers.FLocalHumanPlayers[0]).FSettings <> '' then
    ValidatePassword(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FPlayers.FLocalHumanPlayers[0]).FSettings)
  else StartLoadedMapEx;
end;

procedure TSimultaniousPlayerControl.GameOverEventHandled(Player: Shortint);
begin
  AoWHSMap.SetSeatedPlayer(-1);
  AoWHSMap.TriggerGameTerminatedEvent;
end;

procedure TSimultaniousPlayerControl.SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus);
begin
  inherited SetPlayerGameOverStatus(Player, Status);
  AoWHSMap.FPlayers.GetPlayers(Player).FStatus := psTerminated;
  AoWHSMap.FTokenManager.TokenExecuter.GetTC(Player).Active := False;
  AoWHSMap.FPlayers.Update;
  AoWHSMap.TriggerPlayerTerminatedEvent(Player);
  if AoWHSMap.FPlayers.FLocalHumanPlayers.Count = 0 then AoWHSMap.TriggerGameTerminatedEvent
  else EndTurn(Player);
end;

procedure TSimultaniousPlayerControl.ValidateTurnTiming;
begin
  if AoWHSMap.GetTurnTimerEnabled and (AoWHSMap.GetTurnTimeLeft <= 0) then
    if (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGameOverStatus = goNone) and
      (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSingleProcessCycle = False) then
      if AoWHSMap.FTokenManager.PlayerReady(AoWHSMap.FSeatedPlayer) then EndPlayerTurn(AoWHSMap.FSeatedPlayer);
end;

procedure TPlayerConnectionEventLog.Setup(Player: Shortint; Reason: Byte);
begin
  FReason := Reason;
  FDisconnectedPlayer := Player;
  case FReason of
    3:
      begin
        FButtons := mebYesNo;
        FMessage.Text := TranslateRStr(OutOfSyncRStr);
        FMessage.Add(TranslateRStr(TerminateGameSaveRStr));
      end;
    1:
      begin
        FButtons := mebYesNo;
        FMessage.Text := Format(TranslateRStr(ConnectionXTimeOutRStr),
          [AoWHSMap.FPlayers.GetPlayers(FDisconnectedPlayer).GetName]);
        FMessage.Add('');
        FMessage.Add(TranslateRStr(TerminateGameSaveRStr));
      end;
    2:
      begin
        FButtons := mebYesNo;
        if FDisconnectedPlayer = -1 then FMessage.Text := TranslateRStr(ConnectionLostRStr)
        else FMessage.Text := Format(TranslateRStr(ConnectionXLostRStr),
          [AoWHSMap.FPlayers.GetPlayers(FDisconnectedPlayer).GetName]);
        FMessage.Add('');
        FMessage.Add(TranslateRStr(TerminateGameSaveRStr));
      end;
  end;
end;

procedure TPlayerConnectionEventLog.ExitSaveGameCallBack(Log: TEventLog);
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
  begin
    if AoWEngine.FCampaign <> nil then AoWEngine.SaveCampaign(TSaveGameEventLog(Log).FFileName)
    else AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
  end
  else AoWHSMap.ExecuteExitGame; { Original exits twice when the dialog is canceled. }
  AoWHSMap.ExecuteExitGame;
end;

function TPlayerConnectionEventLog.Yes: Boolean;
var
  Log: TSaveGameEventLog;
begin
  Log := TSaveGameEventLog.Create(nil);
  Log.FDefaultName := '';
  Log.FDirectory := AoWEngine.StartupDirectory + 'Save\';
  AoWHSMap.TriggerExecuteEventLog(Log, False, ExitSaveGameCallBack);
  Log.Release;
  Result := True;
end;

function TPlayerConnectionEventLog.No: Boolean;
begin
  AoWHSMap.ExecuteExitGame;
  Result := True;
end;

constructor TRaceResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIndexes := TUnitIndexList.Create;
  FSpecialUnitIndexes := TUnitIndexList.Create;
  FHeroNames := TStringList.Create;
end;

destructor TRaceResource.Destroy;
begin
  ReleaseIL;
  FUnitIndexes.Free;
  FSpecialUnitIndexes.Free;
  FHeroNames.Free;
  inherited Destroy;
end;

function TRaceResource.GetEngine: Engine.TEngine;
begin Result := AoWEngine; end;

function TRaceResource.GetFace: TLibraryImage;
var
  Images: TCustomImageLibrary;
begin
  AddRef;
  Images := FFaceLibrary;
  if Images <> nil then Result := Images.GetSafe(GetRaceIndex)
  else Result := nil;
  Release;
end;

function TRaceResource.GetRaceIndex: Integer;
begin Result := EditIndex; end;

procedure TRaceResource.LinkToIL;
begin
  if FImageLibrary = nil then
  begin
    if FImageLibraryName <> '' then
      FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName);
    FFaceLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'FACES\R_FACES.ILB');
  end;
end;

procedure TRaceResource.ReleaseIL;
begin
  if FImageLibrary <> nil then { Original leaves the face library linked when the city library is nil. }
  begin
    if FImageLibraryName <> '' then
      AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'FACES\R_FACES.ILB');
    FFaceLibrary := nil;
    FImageLibrary := nil;
  end;
end;

procedure TRaceResource.SetImageLibraryName(Value: string);
begin
  if Value <> FImageLibraryName then
  begin
    ReleaseIL;
    FImageLibraryName := Value;
    if FReferences <> 0 then LinkToIL;
  end;
end;

function TRaceResource.AddRef: Integer;
begin
  if FReferences = 0 then LinkToIL;
  Inc(FReferences);
  Result := FReferences;
end;

function TRaceResource.Release: Integer;
begin
  Dec(FReferences);
  if FReferences = 0 then ReleaseIL;
  Result := FReferences;
end;

class function TRaceResource.ClassID: Integer;
begin Result := $20201; end;

class function TRaceResource.ResourceEditName: string;
begin Result := 'Race'; end;

function TRaceResource.GetCellImage: ImageLib.TLibraryImage;
var
  I: Integer;
begin
  AddRef;
  Result := nil;
  if FImageLibrary <> nil then
  begin
    I := 0;
    while (I < FImageLibrary.Count) and (Result = nil) do
    begin
      Result := FImageLibrary[I];
      Inc(I);
    end;
  end;
  Release;
end;

procedure TRaceResource.SetCellImage(Value: ImageLib.TLibraryImage);
begin end;

function TRaceResource.GetCityImage(Size, Terrain, Level: Integer): TLibraryImage;
var
  Index: Integer;
begin
  if Terrain = 5 then Index := Size + 60 - 1
  else Index := Terrain * 10 + 70 + (Size - 1);
  if FImageLibrary.ImageExist(Index) then Result := FImageLibrary[Index]
  else Result := nil;
  if Result = nil then
  begin
    if Level = 0 then Index := Size + 50 - 1
    else Index := Size + 60 - 1;
    if FImageLibrary.ImageExist(Index) then Result := FImageLibrary[Index];
  end;
end;

procedure TRaceResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then FUnitIndexes.VerifyUnits(True);
end;

procedure TRaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 5);
  Stream.rwString(FRaceName, 6);
  Stream.rwString(FDescription, 7);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FImageLibraryName, 8);
  Stream.rwData(FAlignments, 1, 9);
  Stream.rwStreamProc(10, FUnitIndexes.LoadFromStream, FUnitIndexes.SaveToStream);
  Stream.rwStreamProc(11, FSpecialUnitIndexes.LoadFromStream, FSpecialUnitIndexes.SaveToStream);
  Stream.rwInteger(FHeroUnitIndex, 12);
  Stream.rwStrings(FHeroNames, 13);
end;

function TRaceResource.GetAlignment: TAlignment;
begin
  if FAlignments = alsPureGood then
  begin
    Result := alPureGood;
    Exit;
  end;
  if FAlignments = alsGood then Result := alGood
  else if FAlignments = alsNeutral then Result := alNeutral
  else if FAlignments = alsEvil then Result := alEvil
  else if FAlignments = alsPureEvil then Result := alPureEvil
  else if FAlignments = alsPureNeutral then Result := alPureNeutral
  else Result := alNone;
end;

constructor TRaceResourceList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

function TRaceResourceList.GetRaceResource(Index: Integer): TRaceResource;
begin
  if (Index < GetCount) and (Index >= 0) then
    Result := TRaceResource(FChildren.List^[Index])
  else Result := nil;
end;

function TRaceResourceList.GetMaxRaceIndex: Integer;
begin
  Result := Count - 1;
  while (Result > 0) and (FChildren.List^[Result] = nil) do Dec(Result);
end;

constructor TFlagControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  with TAoWHSSet(AOwner) do
  begin
    FFlags := ImageLibraryManager.LinkToIL([icDisk], 'Flags.ILB');
    Self.FRaceResources := FRaceResources;
  end;
  SetControlStyle([csFixedChild]);
end;

destructor TFlagControl.Destroy;
begin
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'Flags.ILB');
  FFlags := nil;
  inherited Destroy;
end;

procedure TFlagControl.ShowFlag(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc);
begin
  FFlags.Images[4].Show(X, Y, SurfaceDesc);
  FrameOffset := (FrameOffset shr 2) mod 12;
  if FlagID and $20 <> 0 then
    FFlags.Images[FrameOffset + 22].Show(X - 21, Y - 16, SurfaceDesc)
  else
    FRaceResources.GetRaceResource(FlagID and $1F).FImageLibrary.Images[FrameOffset + 12].Show(X - 21, Y - 16, SurfaceDesc);
end;

procedure TFlagControl.ShowFlagEx(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc; ShowBase: Boolean);
begin
  if ShowBase then FFlags.Images[4].Show(X, Y, SurfaceDesc);
  FrameOffset := (FrameOffset shr 2) mod 12;
  if FlagID and $20 <> 0 then
    FFlags.Images[FrameOffset + 22].Show(X - 21, Y - 16, SurfaceDesc)
  else
    FRaceResources.GetRaceResource(FlagID and $1F).FImageLibrary.Images[FrameOffset + 12].Show(X - 21, Y - 16, SurfaceDesc);
end;

procedure TFlagControl.ShowStructureFlag(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc);
begin
  FFlags.Images[FlagID shr 6].Show(X, Y, SurfaceDesc);
  FrameOffset := (FrameOffset shr 1) mod 12;
  if FlagID and $20 <> 0 then
    FFlags.Images[FrameOffset + 10].Show(X - 21, Y - 16, SurfaceDesc)
  else
    FRaceResources.GetRaceResource(FlagID and $1F).FImageLibrary.Images[FrameOffset].Show(X - 21, Y - 16, SurfaceDesc);
end;

procedure TFlagControl.ShowStructureFlagEx(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc; ShowBase: Boolean);
begin
  if ShowBase then FFlags.Images[FlagID shr 6].Show(X, Y, SurfaceDesc);
  FrameOffset := (FrameOffset shr 1) mod 12;
  if FlagID and $20 <> 0 then
    FFlags.Images[FrameOffset + 10].Show(X - 21, Y - 16, SurfaceDesc)
  else
    FRaceResources.GetRaceResource(FlagID and $1F).FImageLibrary.Images[FrameOffset].Show(X - 21, Y - 16, SurfaceDesc);
end;

class function TProductionEventLog.ClassID: Integer;
begin Result := $202F9; end;

class function TUnitProduction.ClassID: Integer;
begin Result := $20299; end;

procedure TUnitProduction.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitIndex, 20);
  Stream.rwBool(FResearched, 21);
end;

function TUnitProductionList.GetItem(Index: Integer): TUnitProduction;
begin
  if (Index >= 0) and (Index < Count) then Result := FChildren.List^[Index]
  else Result := nil;
end;

procedure TUnitProductionList.Add(UnitIndex: Integer; Researched: Boolean);
begin
  with TUnitProduction.Create(Self) do
  begin
    FUnitIndex := UnitIndex;
    FResearched := Researched;
  end;
end;

function TUnitProductionList.IndexOf(Index: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if Index = GetItem(Result).FUnitIndex then Exit;
  end;
  Result := -1;
end;

function CompareUnitProductionLevel(Item1, Item2: Pointer): Integer;
var
  Level1, Level2: Integer;
begin
  with TUnitProduction(Item1) do
    if AoWHSSet.FUnitResources.GetUnitResource(FUnitIndex) <> nil then
      Level1 := AoWHSSet.FUnitResources.GetUnitResource(FUnitIndex).FLevel * 2
    else Level1 := 0;
  if AoWHSSet.FUnitResources.GetUnitResource(TUnitProduction(Item2).FUnitIndex) <> nil then
    Level2 := AoWHSSet.FUnitResources.GetUnitResource(TUnitProduction(Item2).FUnitIndex).FLevel * 2
  else Level2 := 0;
  Result := Level1 - Level2;
  if Result = 0 then Result := TUnitProduction(Item1).FUnitIndex - TUnitProduction(Item2).FUnitIndex;
end;

procedure TUnitProductionList.SortOnLevel;
begin
  FChildren.Sort(CompareUnitProductionLevel);
end;

class function TProductionItem.ClassID: Integer;
begin Result := $20297; end;

procedure TProductionItem.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FProductionID, 20);
  Stream.rwInteger(FParameter, 21);
  Stream.rwInteger(FGroupID, 22);
end;

function TProductionItem.GetName: string;
begin
  if Owner <> nil then Result := TProductionQueue(Owner).FProductionControl.GetProductionName(Self)
  else Result := TranslateRStr(UnknownRStr);
end;

function TProductionItem.GetNameProgressive: string;
begin
  if Owner <> nil then Result := TProductionQueue(Owner).FProductionControl.GetProductionNameProgressive(Self)
  else Result := TranslateRStr(UnknownRStr);
end;

function TProductionQueue.GetItem(Index: Integer): TProductionItem;
begin
  if (Index >= 0) and (Index < Count) then Result := FChildren.List^[Index]
  else Result := nil;
end;

function TProductionQueue.IndexOfID(ID: Integer): Integer;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if ID = TProductionItem(FChildren.List^[Result]).FProductionID then Exit;
  end;
  Result := -1;
end;

function TProductionQueue.IndexOf(ID, Parameter, GroupID: Integer): Integer;
var
  Item: TProductionItem;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    Item := FChildren.List^[Result];
    if (ID = Item.FProductionID) and (Parameter = Item.FParameter) and (Item.FGroupID = GroupID) then Exit;
  end;
  Result := -1;
end;

destructor TProductionSettings.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TProductionSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FGold, 10);
  Stream.rwInteger(FMana, 11);
  Stream.rwByte(Byte(FTurnsLeft), 12);
  Stream.rwByte(Byte(FTurnsTotal), 13);
  Stream.rwByte(Byte(FPlayer), 14);
  Stream.rwInteger(FGroupID, 15);
  Stream.rwInteger(FUnitProductionIndex, 16);
  Stream.rwCreateEObject(TEObject(FUnit), nil, 17);
  Stream.rwInteger(FGoldUpkeep, 18);
  Stream.rwInteger(FManaUpkeep, 19);
end;

procedure TProductionSettings.Clear;
var
  U: TAbstractUnit;
begin
  FTurnsLeft := 0;
  FGold := 0;
  FMana := 0;
  FTurnsTotal := 0;
  FPlayer := 0;
  FGroupID := 0;
  FUnitProductionIndex := -1;
  U := FUnit;
  if U <> nil then
  begin
    U.Release;
    FUnit := nil;
  end;
  { Original leaves the upkeep fields unchanged. }
end;

destructor TProductionTE.Destroy;
begin
  if FItem <> nil then
  begin
    FItem.Free;
    FItem := nil;
  end;
  inherited Destroy;
end;

class function TProductionTE.ClassID: Integer;
begin Result := $20298; end;

procedure TProductionTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FCommand, 20);
  Stream.rwByte(Byte(FX), 21);
  Stream.rwByte(Byte(FY), 22);
  Stream.rwByte(Byte(FL), 23);
  Stream.rwByte(Byte(FPlayer), 24);
  Stream.rwCreateEObject(TEObject(FItem), nil, 25);
  Stream.rwInteger(FIndex, 26);
  Stream.rwInteger(FReserved, 27);
  Stream.rwBool(FQueue, 28);
end;

function TProductionTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Control: TProductionControl;
begin
  Control := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetProductionControl;
  if Control <> nil then Result := Control.ExecuteProductionTE(Self)
  else Result := erDoneHalt;
end;

constructor TProductionControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSettings := TProductionSettings.Create(nil);
  FUnitProductions := TUnitProductionList.Create(nil);
  FQueue := TProductionQueue.Create(nil);
  FQueue.FProductionControl := Self;
  FStatus := pcsIdle;
  Clear;
end;

destructor TProductionControl.Destroy;
begin
  FSettings.Free;
  FUnitProductions.Free;
  FQueue.Free;
  inherited Destroy;
end;

procedure TProductionControl.BeginUpdate;
begin Inc(FUpdateCount); end;

procedure TProductionControl.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then Update;
end;

procedure TProductionControl.Update;
begin
  if FUpdateCount = 0 then
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TProductionControl.Activate;
begin RegisterGroupProduction; end;

procedure TProductionControl.Deactivate;
begin UnregisterGroupProduction; end;

function TProductionControl.GetProduceUnitLevelMax: Integer;
var
  I: Integer;
  Resource: TUnitResource;
begin
  Result := 0;
  for I := FUnitProductions.Count - 1 downto 0 do
    if (FUnitProductions.GetItem(I).FResearched) and (FUnitProductions.GetItem(I).FUnitIndex >= 0) then
    begin
      Resource := AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(I).FUnitIndex);
      if Resource <> nil then
        if Result < Resource.FLevel then Result := Resource.FLevel;
    end;
end;

function TProductionControl.GetResearchUnitLevelMax: Integer;
var
  I: Integer;
  Resource: TUnitResource;
begin
  Result := 0;
  for I := FUnitProductions.Count - 1 downto 0 do
    if (not FUnitProductions.GetItem(I).FResearched) and (FUnitProductions.GetItem(I).FUnitIndex >= 0) then
    begin
      Resource := AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(I).FUnitIndex);
      if Resource <> nil then
        if Result < Resource.FLevel then Result := Resource.FLevel;
    end;
end;

function TProductionControl.CancelProductionReturnGold: Integer;
begin
  if FStatus = pcsProducing then
    with FSettings do
      if FTurnsTotal <> 0 then Result := Round(FTurnsLeft * FGold / FTurnsTotal)
      else Result := 0
  else Result := 0;
end;

function TProductionControl.CancelProductionReturnMana: Integer;
begin
  if FStatus = pcsProducing then
    with FSettings do
      if FTurnsTotal <> 0 then Result := Round(FTurnsLeft * FMana / FTurnsTotal)
      else Result := 0
  else Result := 0;
end;

function TProductionControl.GetQueueSizeMax: Integer;
begin Result := 5; end;

function TProductionControl.GetQueueLocked: Boolean;
var
  I: Integer;
begin
  I := FQueue.Count;
  Result := I >= GetQueueSizeMax;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := LockQueueProduction(FQueue.GetItem(I));
  end;
end;

procedure TProductionControl.ExecuteCancelProduction;
var
  Player: Shortint;
begin
  if FStatus = pcsProducing then
  begin
    if FSettings.FGroupID <> 0 then UnregisterGroupProduction;
    Player := GetPlayer;
    if Player > -1 then
    begin
      AoWHSMap.FPlayers.GetPlayers(Player).SetGems(
        AoWHSMap.FPlayers.GetPlayers(Player).FGems + CancelProductionReturnGold);
      AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.SetMana(
        AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FMana + CancelProductionReturnMana);
    end;
    FSettings.Clear;
    FStatus := pcsWaiting;
    Update;
  end;
end;

procedure TProductionControl.RegisterGroupProduction;
var
  Group: TAIGroup;
begin
  if (FStatus = pcsProducing) and (FSettings.FGroupID <> 0) then
  begin
    Group := AoWHSMap.FAIGroupManager.FindID(FSettings.FGroupID);
    if Group <> nil then Group.FProductions.Add(Self, FSettings.FUnit);
  end;
end;

procedure TProductionControl.UnregisterGroupProduction;
var
  Group: TAIGroup;
begin
  if (FStatus = pcsProducing) and (FSettings.FGroupID <> 0) then
  begin
    Group := AoWHSMap.FAIGroupManager.FindID(FSettings.FGroupID);
    if Group <> nil then Group.FProductions.DeleteUnit(FSettings.FUnit);
    FSettings.FGroupID := 0;
  end;
end;

procedure TProductionControl.GroupProductionProduced(AUnit: TAbstractUnit; GroupID: Integer);
var
  Group: TAIGroup;
begin
  Group := AoWHSMap.FPlayers.GetPlayers(GetPlayer).FAIGroups.FindID(GroupID);
  if Group <> nil then Group.UnitProduced(Self, AUnit);
end;

procedure TProductionControl.PlayerChanged;
var
  I: Integer;
begin
  for I := FQueue.Count - 1 downto 1 do FQueue.GetItem(I).Free;
  UnregisterGroupProduction;
  FLoopQueue := False;
  if (FQueue.Count <> 0) and (FStatus <> pcsProducing) then
  begin
    FQueue.GetItem(0).Free;
    FStatus := pcsIdle;
  end;
end;

function TProductionControl.CanExecuteProduction(Item: TProductionItem; var Reason: string): Boolean;
begin
  if FStatus = pcsWaiting then Reason := '(' + LowerCase(TranslateRStr(WaitingRStr)) + ')';
  { Original continues checking costs after assigning the waiting text. }
  case Item.FProductionID of
    1:
      if UnitProductionGold(Item.FParameter) <= AoWHSMap.FPlayers.GetPlayers(GetPlayer).FGems then
        if UnitProductionMana(Item.FParameter) <= AoWHSMap.FPlayers.GetPlayers(GetPlayer).FMagicControl.FMana then
          Result := True
        else
        begin
          Result := False;
          Reason := TranslateRStr(NotEnoughManaRStr);
        end
      else
      begin
        Result := False;
        Reason := TranslateRStr(NotEnoughGoldRStr);
      end;
    2:
      if UnitResearchGold(Item.FParameter) <= AoWHSMap.FPlayers.GetPlayers(GetPlayer).FGems then
        Result := True
      else
      begin
        Result := False;
        Reason := TranslateRStr(NotEnoughGoldRStr);
      end;
  else Result := False;
  end;
end;

function TProductionControl.ExecuteProduction(Item: TProductionItem): Boolean;
var
  Reason: string;
begin
  if CanExecuteProduction(Item, Reason) then
  begin
    BeginUpdate;
    ExecuteCancelProduction;
    FStatus := pcsWaiting;
    case Item.FProductionID of
      1:
        begin
          FSettings.Clear;
          FSettings.FUnitProductionIndex := Item.FParameter;
          FSettings.FUnit := CreateUnitProduction(Item.FParameter);
          FSettings.FGold := UnitProductionGold(Item.FParameter);
          FSettings.FMana := UnitProductionMana(Item.FParameter);
          FSettings.FGoldUpkeep := UnitProductionGoldUpkeep(Item.FParameter);
          FSettings.FManaUpkeep := UnitProductionManaUpkeep(Item.FParameter);
          FSettings.FGroupID := Item.FGroupID;
          FSettings.FTurnsTotal := UnitProductionTime(Item.FParameter);
          FSettings.FPlayer := GetPlayer;
          FSettings.FTurnsLeft := FSettings.FTurnsTotal;
          with AoWHSMap.FPlayers.GetPlayers(FSettings.FPlayer) do
          begin
            SetGems(FGems - Self.FSettings.FGold);
            FMagicControl.SetMana(FMagicControl.FMana - Self.FSettings.FMana);
          end;
          FStatus := pcsProducing;
          if FSettings.FGroupID <> 0 then RegisterGroupProduction;
        end;
      2:
        begin
          FSettings.Clear;
          FSettings.FUnitProductionIndex := Item.FParameter;
          FSettings.FGold := UnitResearchGold(Item.FParameter);
          FSettings.FMana := 0;
          FSettings.FTurnsTotal := UnitResearchTime(Item.FParameter);
          FSettings.FPlayer := GetPlayer;
          FSettings.FTurnsLeft := FSettings.FTurnsTotal;
          with AoWHSMap.FPlayers.GetPlayers(FSettings.FPlayer) do
          begin
            SetGems(FGems - Self.FSettings.FGold);
            FMagicControl.SetMana(FMagicControl.FMana - Self.FSettings.FMana);
          end;
          FStatus := pcsProducing;
        end;
    end;
    EndUpdate;
    Result := True;
  end
  else
  begin
    FStatus := pcsWaiting;
    Result := False;
  end;
end;

procedure TProductionControl.ExecuteAddProduction(Item: TProductionItem);
var
  NewItem: TProductionItem;
begin
  BeginUpdate;
  NewItem := TProductionItem(Item.Copy(AoWEngine));
  NewItem.SetOwner(FQueue);
  if FQueue.Count = 1 then ExecuteProduction(NewItem);
  EndUpdate;
end;

procedure TProductionControl.ExecuteDeleteProduction(Index: Integer);
begin
  BeginUpdate;
  if Index = 0 then
  begin
    ExecuteCancelProduction;
    FQueue.GetItem(Index).Free;
    if FQueue.Count <> 0 then ExecuteProduction(FQueue.GetItem(0))
    else FStatus := pcsIdle;
  end
  else FQueue.GetItem(Index).Free;
  EndUpdate;
end;

procedure TProductionControl.ExecuteDeleteProductions;
begin
  BeginUpdate;
  ExecuteCancelProduction;
  FQueue.Clear;
  EndUpdate;
end;

function TProductionControl.ExecuteAIProduction(Index, GroupID: Integer): Boolean;
var
  Item: TProductionItem;
begin
  ExecuteDeleteProductions;
  Item := TProductionItem.Create(nil);
  Item.FProductionID := 1;
  Item.FParameter := Index;
  Item.FGroupID := GroupID;
  ExecuteAddProduction(Item);
  Item.Free;
  Result := True;
end;

function TProductionControl.ExecuteAIResearch(Index: Integer): Boolean;
var
  Item: TProductionItem;
begin
  if not FUnitProductions.GetItem(Index).FResearched then
  begin
    ExecuteDeleteProductions;
    Item := TProductionItem.Create(nil);
    Item.FProductionID := 2;
    Item.FParameter := Index;
    ExecuteAddProduction(Item);
    Item.Free;
    Result := True;
  end
  else Result := True;
end;

function TProductionControl.ExecuteProductionTE(Event: TProductionTE): TExecuteResult;
begin
  case Event.FCommand of
    0:
      begin
        BeginUpdate;
        if not Event.FQueue then ExecuteDeleteProductions;
        ExecuteAddProduction(Event.FItem);
        Result := erDone;
        EndUpdate;
      end;
    1:
      begin
        ExecuteDeleteProduction(Event.FIndex);
        Result := erDone;
      end;
    2:
      begin
        ExecuteDeleteProductions;
        Result := erDone;
      end;
    3:
      begin
        if (FQueue.Count <> 0) and (FStatus = pcsWaiting) then
          ExecuteProduction(FQueue.GetItem(0));
        Result := erDone;
      end;
    4:
      begin
        FLoopQueue := Event.FIndex = 1;
        Update;
        Result := erDone;
      end;
  else Result := erDone;
  end;
end;

function TProductionControl.CreateProductionTE: TProductionTE;
var
  Event: TProductionTE;
begin
  Event := TProductionTE.Create(nil);
  GetLocation(Event.FX, Event.FY, Event.FL);
  Event.FPlayer := GetPlayer;
  Result := Event;
end;

function TProductionControl.UnitProduced: Boolean;
begin Result := False; end;

function TProductionControl.CreateUnitProduction(Index: Integer): TUnit;
var
  AUnit: TUnit;
begin
  if FUnitProductions.GetItem(Index) <> nil then
  begin
    AUnit := TUnit.Create(nil);
    AUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(Index).FUnitIndex));
    Result := AUnit;
  end
  else Result := nil;
end;

function TProductionControl.UnitProductionGold(Index: Integer): Integer;
var
  UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex).FObtainValue;
end;

function TProductionControl.UnitProductionGoldUpkeep(Index: Integer): Integer;
begin
  Result := (AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(Index).FUnitIndex).FLevel + 1) * 2;
end;

function TProductionControl.UnitProductionMana(Index: Integer): Integer;
begin Result := 0; end;

function TProductionControl.UnitProductionManaUpkeep(Index: Integer): Integer;
begin Result := 0; end;

function TProductionControl.UnitProductionTime(Index: Integer): Integer;
var
  UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex).FLevel;
end;

function TProductionControl.CanProduceUnit(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin Result := True; end;

function TProductionControl.ProduceUnitEx(Index, GroupID: Integer; Queue: Boolean): Boolean;
var
  Event: TProductionTE;
  Reason: string;
begin
  if CanProduceUnit(Index, Queue, Reason) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 0;
    Event.FQueue := Queue;
    Event.FItem := TProductionItem.Create(nil);
    with Event.FItem do
    begin
      FProductionID := 1;
      FParameter := Index;
      FGroupID := GroupID;
    end;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TProductionControl.ProduceUnit(Index: Integer; Queue: Boolean): Boolean;
begin
  Result := ProduceUnitEx(Index, 0, Queue);
end;

procedure TProductionControl.UnitResearched;
begin
  FUnitProductions.GetItem(FSettings.FUnitProductionIndex).FResearched := True;
end;

function TProductionControl.UnitResearchGold(Index: Integer): Integer;
var
  UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex).FObtainValue;
end;

function TProductionControl.UnitResearchMana(Index: Integer): Integer;
begin Result := 0; end;

function TProductionControl.UnitResearchTime(Index: Integer): Integer;
var
  UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex).FLevel;
end;

function TProductionControl.CanResearchUnit(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin
  if not Queue or (FQueue.IndexOf(2, Index, 0) = -1) then Result := True
  else
  begin
    Result := False;
    Reason := TranslateRStr(ActionAlreadyQueuedRStr);
  end;
end;

function TProductionControl.ResearchUnit(Index: Integer; Queue: Boolean): Boolean;
var
  Event: TProductionTE;
  Reason: string;
begin
  if CanResearchUnit(Index, Queue, Reason) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 0;
    Event.FQueue := Queue;
    Event.FItem := TProductionItem.Create(nil);
    with Event.FItem do
    begin
      FProductionID := 2;
      FParameter := Index;
    end;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := False; { Original returns False after successfully queueing research. }
  end
  else Result := True;
end;

function TProductionControl.Produce(Item: TProductionItem; Queue: Boolean): Boolean;
var
  Event: TProductionTE;
begin
  if not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 0;
    Event.FQueue := Queue;
    Event.FItem := TProductionItem(Item.Copy(AoWEngine));
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := False; { Original returns False after successfully queueing production. }
  end
  else Result := True;
end;

function TProductionControl.DeleteProduction(Index: Integer): Boolean;
var
  Event: TProductionTE;
begin
  if (Index >= 0) and (Index < FQueue.Count) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 1;
    Event.FIndex := Index;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TProductionControl.DeleteProductions: Boolean;
var
  Event: TProductionTE;
begin
  if (FQueue.Count <> 0) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 2;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TProductionControl.RetryProductionExecution(var Reason: string): Boolean;
var
  Event: TProductionTE;
begin
  if (FQueue.Count <> 0) and (FStatus = pcsWaiting) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    if CanExecuteProduction(FQueue.GetItem(0), Reason) then
    begin
      Event := CreateProductionTE;
      Event.FCommand := 3;
      AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
      Event.Release;
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
end;

function TProductionControl.SetLoopQueueTo(Value: Boolean): Boolean;
var
  Event: TProductionTE;
begin
  if (Value <> FLoopQueue) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 4;
    if Value then Event.FIndex := 1 else Event.FIndex := 0;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TProductionControl.GetLocation(var X, Y, L: Shortint);
begin
  X := -1;
  Y := -1;
  L := -1;
end;

procedure TProductionControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FQueue, 20);
  Stream.rwEObject(FUnitProductions, 21);
  Stream.rwEObject(FSettings, 22);
  Stream.rwData(FStatus, SizeOf(FStatus), 23);
  Stream.rwBool(FLoopQueue, 24);
end;

procedure TProductionControl.ProductionDone;
begin
  BeginUpdate;
  if FLoopQueue and LoopableProduction(FQueue.GetItem(0)) then
    FQueue.FChildren.Move(0, FQueue.Count - 1)
  else FQueue.GetItem(0).Free;
  if FQueue.Count <> 0 then ExecuteProduction(FQueue.GetItem(0))
  else FStatus := pcsIdle;
  EndUpdate;
end;

procedure TProductionControl.NewTurn(Player: Shortint);
begin
  if (FStatus = pcsWaiting) and (Player = GetPlayer) then
  begin
    if FQueue.Count <> 0 then ExecuteProduction(FQueue.GetItem(0))
    else FStatus := pcsIdle;
  end
  else if (FStatus = pcsProducing) and (Player = FSettings.FPlayer) then
  begin
    if FSettings.FTurnsLeft > 0 then Dec(FSettings.FTurnsLeft);
    if FSettings.FTurnsLeft = 0 then
      case FQueue.GetItem(0).FProductionID of
        1:
          if UnitProduced then
          begin
            if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) and (FSettings.FGroupID <> 0) then
              GroupProductionProduced(FSettings.FUnit, FSettings.FGroupID);
            FSettings.Clear;
            ProductionDone;
          end;
        2:
          begin
            UnitResearched;
            FSettings.Clear;
            ProductionDone;
          end;
      end;
  end;
end;

function TProductionControl.LockQueueProduction(Item: TProductionItem): Boolean;
begin Result := False; end;

function TProductionControl.LoopableProduction(Item: TProductionItem): Boolean;
begin Result := Item.FProductionID <> 2; end;

function TProductionControl.GetProductionName(Item: TProductionItem): string;
var
  Production: TUnitProduction;
begin
  case Item.FProductionID of
    1:
      begin
        Production := FUnitProductions.GetItem(Item.FParameter);
        if Production <> nil then
          if UnitProductionGold(Item.FParameter) <> 0 then
            Result := Format(TranslateRStr(ProduceXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
          else Result := Format(TranslateRStr(SummonXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
        else Result := TranslateRStr(UnknownRStr);
      end;
    2:
      begin
        Production := FUnitProductions.GetItem(Item.FParameter);
        if Production <> nil then
          Result := Format(TranslateRStr(InstallXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
        else Result := TranslateRStr(UnknownRStr);
      end;
  else Result := TranslateRStr(UnknownRStr);
  end;
end;

function TProductionControl.GetProductionNameProgressive(Item: TProductionItem): string;
var
  Production: TUnitProduction;
begin
  case Item.FProductionID of
    1:
      begin
        Production := FUnitProductions.GetItem(Item.FParameter);
        if Production <> nil then
          if UnitProductionGold(Item.FParameter) <> 0 then
            Result := Format(TranslateRStr(ProducingXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
          else Result := Format(TranslateRStr(SummoningXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
        else Result := TranslateRStr(UnknownRStr);
      end;
    2:
      begin
        Production := FUnitProductions.GetItem(Item.FParameter);
        if Production <> nil then
          Result := Format(TranslateRStr(InstallingXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
        else Result := TranslateRStr(UnknownRStr);
      end;
  else Result := TranslateRStr(UnknownRStr);
  end;
end;

function TProductionControl.FindOptimalResearchProduction(Predictor: TCombatPredictor; Gold: Integer): Integer;
var
  Player: TPlayer;
  AUnit: TUnit;
  Productions: TDoubleItemList;
  I, Priority, Minimum: Integer;
  Include: Boolean;
begin
  Player := AoWHSMap.FPlayers.GetPlayers(GetPlayer);
  AUnit := TUnit.Create(nil);
  Productions := TDoubleItemList.Create;
  for I := FUnitProductions.Count - 1 downto 0 do
    if not FUnitProductions.GetItem(I).FResearched then
    begin
      Include := UnitResearchGold(I) <= Gold;
      if Predictor <> nil then
      begin
        AUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(I).FUnitIndex));
        Priority := Predictor.Usefullness(AUnit);
        Include := Priority and $800000 <> 0; { Original replaces the affordability check here. }
      end
      else Priority := GetUnitIndexAIPriority(FUnitProductions.GetItem(I).FUnitIndex, Player.FPlayerIndex, 0);
      if Include then Productions.AddAB(I, Priority);
    end;
  if Productions.Count <> 0 then
  begin
    Productions.SortDescendingItemB;
    Result := 0;
    Minimum := Round(Productions[0].B * 0.8);
    while (Result + 1 < Productions.Count) and (Productions[Result + 1].B >= Minimum) do Inc(Result);
    if AoWHSMap.Random(2) = 1 then Result := 0
    else Result := AoWHSMap.Random(Result + 1);
    Result := Productions[Result].A;
  end
  else Result := -1;
  Productions.Free;
  AUnit.Free;
end;

function TProductionControlList.GetPC(Index: Integer): TProductionControl;
begin
  Result := TProductionControl(List^[Index]);
end;

destructor TStructureShadow.Destroy;
begin
  if sssVisible in FShadowStatus then AoWHSMap.StaticVisibleHS.RemoveChild(Self);
  inherited Destroy;
end;

procedure TStructureShadow.SetVisible(Value: Boolean);
begin
  if Value then FShadowStatus := FShadowStatus + [sssVisible]
  else FShadowStatus := FShadowStatus - [sssVisible];
end;

function TStructureShadow.GetVisible: Boolean;
begin
  Result := sssVisible in FShadowStatus;
end;

procedure TStructureShadow.Connect;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
begin
  if not (sssConnected in FShadowStatus) then
  begin
    FShadowStatus := FShadowStatus + [sssConnected];
    Count := FStructure.GetTerrainCount;
    Level := TMapLevel(FStructure.Owner.Owner);
    InitHNWalk(Walk, TMapField(FStructure.Owner).Xhx, TMapField(FStructure.Owner).Yhx, 0);
    while Walk.HN < Count do
    begin
      if ((FStructure.GetTerrain(Walk.HN) >= -1) or (FStructure.GetOverlay(Walk.HN) >= -1)) and
        (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        Level.GetField(Walk.X, Walk.Y).AddHS(Self, Walk.HN);
      WalkToNextHN(Walk);
    end;
  end;
end;

procedure TStructureShadow.Disconnect;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
begin
  if sssConnected in FShadowStatus then
  begin
    Count := FStructure.GetTerrainCount;
    FShadowStatus := FShadowStatus - [sssConnected];
    Level := TMapLevel(FStructure.Owner.Owner);
    InitHNWalk(Walk, TMapField(FStructure.Owner).Xhx, TMapField(FStructure.Owner).Yhx, 0);
    while Walk.HN < Count do
    begin
      if ((FStructure.GetTerrain(Walk.HN) >= -1) or (FStructure.GetOverlay(Walk.HN) >= -1)) and
        (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        Level.GetField(Walk.X, Walk.Y).RemoveHS(Self);
      WalkToNextHN(Walk);
    end;
  end;
end;

function TStructureShadow.GetShowPriority: Integer;
begin
  Result := (FStructure.GetShowPriority and $03FFFFFF) + $30000000;
end;

procedure TStructureShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  FStructure.ShowShadow(XhpSurf, YhpSurf, SurfaceDesc);
end;

class function TStructure.ClassID: Integer;
begin
  Result := $2034A;
end;

constructor TStructure.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FBuildingPlayer := -1;
  FFogged := True;
end;

destructor TStructure.Destroy;
begin
  if FShadow <> nil then DestroyShadow;
  if (Owner <> nil) and (moResourceLinked in FStatus) and TStructureResource(FResource).FTerrainBound then
    Owner.DestroyChildren($20106);
  inherited Destroy;
  if (AoWHSMap <> nil) and not (msDestroying in AoWHSMap.Status) then
    AoWHSMap.StructureDestroyed(Self);
end;

procedure TStructure.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TStructure.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then AoWHSMap.StructureChanged(Self);
end;

procedure TStructure.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FBuildingDays, 0);
  Stream.rwInteger(FStructureID, $62);
  Stream.rwByteEx(Byte(FBuildingPlayer), $FF, $63);
end;

function TStructure.ExecuteAI(Player: Shortint; Phase: Integer): Boolean;
begin Result := False; end;

procedure TStructure.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
begin
end;

function TStructure.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin
  if GetRazed then
    if TerrainType = 3 then Result := 23
    else if TerrainType = 5 then Result := 24
    else Result := 22
  else if GetBuilding then
    if TerrainType = 3 then Result := 26
    else if TerrainType = 5 then Result := 27
    else Result := 25
  else Result := inherited GetTerrainTypeImage(TerrainType);
end;

procedure TStructure.UpdateRoads(MapField: TMapField);
var
  Level: TMapLevel;
  Table: TWordList;
  I, X, Y: Integer;
  Road: TAbstractRoad;
begin
  Level := TMapLevel(MapField.Owner);
  Table := FResource.TerrainList.CreateSurroundingHNTable;
  for I := 0 to Table.Count - 1 do
  begin
    CenterHNtoHX(MapField.Xhx, MapField.Yhx, Table[I], X, Y);
    if (X >= 0) and (Y >= 0) and (X < Level.Width) and (Y < Level.Height) then
    begin
      Road := TAbstractRoad(Level.GetField(X, Y).FindOwnedHS(TAbstractRoad));
      if Road <> nil then Road.UpdateTransitions;
    end;
  end;
  Table.Free;
end;

function TStructure.GetPlayer: Shortint;
begin
  Result := TAoWMapField(Owner).GetPlayer;
end;

function TStructure.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if not GetEditMode then UpdateRoads(TMapField(Owner));
end;

procedure TStructure.RemoveFromMap;
var
  MapField: TMapField;
begin
  MapField := TMapField(Owner);
  inherited RemoveFromMap;
  if (MapField <> nil) and not GetEditMode then UpdateRoads(MapField);
end;

procedure TStructure.CreateShadow;
begin
  if FShadow <> nil then DestroyShadow;
  FShadow := TStructureShadow.Create(nil);
  FShadow.FStructure := Self;
  FShadow.Connect;
end;

procedure TStructure.DestroyShadow;
begin
  if FShadow <> nil then
  begin
    if sssConnected in FShadow.FShadowStatus then FShadow.Disconnect;
    FShadow.Free;
    FShadow := nil;
  end;
end;

procedure TStructure.Update;
begin
  if FUpdateCount = 0 then AoWHSMap.StructureChanged(Self);
end;

function TStructure.CreateTE: TStructureTE;
begin
  Result := TStructureTE.Create(nil);
end;

procedure TStructure.SetupTE(A1: TStructureTE);
begin
  A1.Initialize(ClassID, GetXhx, GetYhx, GetLhx);
end;

function TStructure.ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult;
var
  AUnit: TAbstractUnit;
begin
  if A1.FAction = -1 then
    if ExecuteRaze(A1.FParam) then Result := erDone else Result := erDoneHalt
  else if A1.FAction = -2 then
  begin
    AUnit := AoWHSMap.FUnitControl.FindUnit(A1.FParam);
    if (AUnit <> nil) and ExecuteRebuild(AUnit) then
    begin
      AUnit.Killed;
      Result := erDone;
    end
    else Result := erDoneHalt;
  end
  else Result := erDoneHalt;
end;

function TStructure.ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin
  if MapLevel.Lhx <> 0 then Result := 12 else Result := -1;
end;

function TStructure.GetName: string;
begin
  Result := EditName;
end;

function TStructure.GetCurrentActivityText: string;
begin
  Result := '-';
end;

function TStructure.GetDescription: TStrings;
begin
  Result := TStructureResource(FResource).FDescription;
end;

function TStructure.CanDblClick: Boolean;
begin
  Result := False;
end;

function TStructure.CanSelect(Xhp, Yhp: Integer): Boolean;
var
  X, Y, HN: Integer;
begin
  if (AoWHSMap.FFogEnabled = 0) or not FFogged then
  begin
    HPtoHX(Xhp, Yhp, X, Y);
    HN := dHXtoHN(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
    if (HN >= FResource.TerrainList.Count) or
      ((FResource.TerrainList.Terrain[HN] < 0) and (FResource.TerrainList.Overlay[HN] < 0)) then
      Result := False
    else Result := True;
  end
  else Result := False;
end;

procedure TStructure.PlaySelectSample;
begin
  if not GetRazed and (TStructureResource(FResource).FSelectSFX <> '') then
    Sound.PlaySample(TStructureResource(FResource).FSelectSFX);
end;

procedure TStructure.Select;
begin
  inherited Select;
  if not (msEditting in AoWHSMap.Status) then PlaySelectSample;
end;

procedure TStructure.Unselect;
begin
  inherited Unselect;
end;

procedure TStructure.FogChanged;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
begin
  FFogged := AoWHSMap.FFogEnabled <> 0;
  if FFogged then
  begin
    Count := GetTerrainCount;
    Level := TMapLevel(Owner.Owner);
    InitHNWalk(Walk, FXhx, FYhx, 0);
    while (Walk.HN < Count) and FFogged do
    begin
      if (FResource.TerrainList.Terrain[Walk.HN] >= 0) and
        (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        FFogged := not (msVisible in Level.GetField(Walk.X, Walk.Y).Status);
      WalkToNextHN(Walk);
    end;
  end;
end;

function TStructure.GetTopBorderImage: TLibraryImage;
var
  Sequences: TImageSequenceList;
begin
  Sequences := FResource.ImageSequenceList;
  if Sequences <> nil then
    if Sequences.GetImageSequence(30) <> nil then
      Result := FResource.ImageSequenceList.GetImageSequence(30).GetPreviewImage
    else Result := nil
  else Result := FResource.ImageLibrary.GetImage(30);
end;

function TStructure.GetMiddleBorderImage: TLibraryImage;
var
  Sequences: TImageSequenceList;
begin
  Sequences := FResource.ImageSequenceList;
  if Sequences <> nil then
    if Sequences.GetImageSequence(31) <> nil then
      Result := FResource.ImageSequenceList.GetImageSequence(31).GetPreviewImage
    else Result := nil
  else Result := FResource.ImageLibrary.GetImage(31);
end;

function TStructure.GetBottomBorderImage: TLibraryImage;
var
  Sequences: TImageSequenceList;
begin
  Sequences := FResource.ImageSequenceList;
  if Sequences <> nil then
    if Sequences.GetImageSequence(32) <> nil then
      Result := FResource.ImageSequenceList.GetImageSequence(32).GetPreviewImage
    else Result := nil
  else Result := FResource.ImageLibrary.GetImage(32);
end;

function TStructure.GetOverlay(Index: Integer): Shortint;
begin
  Result := FResource.TerrainList.Terrain[Index];
  if Result >= 0 then Result := 7;
end;

function TStructure.GetTerrain(Index: Integer): ShortInt;
begin
  Result := FResource.TerrainList.Terrain[Index];
  if Result >= 0 then Result := FTerrainType;
end;

function TStructure.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin
  Result := TStructureResource(FResource).FTerrainBound or inherited CanChangeTerrain(Info);
end;

function TStructure.ValidTerrainType(TerrainType: Integer): Boolean;
begin
  Result := (TStructureResource(FResource).FTerrainBound and AoWHSSet.FPadControl.FTerrainTypes[TerrainType]) or inherited ValidTerrainType(TerrainType);
end;

procedure TStructure.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    if TStructureResource(FResource).FTerrainBound then
    begin
      FTerrainType := Info.TerrainType;
      FImageIndex := GetTerrainTypeImage(FTerrainType);
    end
    else inherited TerrainChanged(Info);
end;

function TStructure.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  if TStructureResource(FResource).FTerrainBound then
    Result := AoWHSSet.FPadControl.CanPlacePad(Xhx, Yhx, Lhx, TStructureResource(FResource).FFlagType)
  else Result := inherited CanPlace(MapContainer, Xhx, Yhx, Lhx);
end;

function TStructure.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var
  Pad: TILTerrainMO;
begin
  if GetEditMode or CanPlace(MapContainer, Xhx, Yhx, Lhx) then
    if TStructureResource(FResource).FTerrainBound then
    begin
      if not GetEditMode then
        Pad := AoWHSSet.FPadControl.PlacePad(Xhx, Yhx, Lhx, TStructureResource(FResource).FFlagType)
      else Pad := nil;
      if (Pad <> nil) or GetEditMode then
      begin
        if Pad <> nil then FTerrainType := Pad.TerrainType;
        Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
      end
      else Result := False;
    end
    else Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx)
  else Result := False;
end;

function TStructure.GetRazeable: Boolean;
begin
  Result := TStructureResource(FResource).FRazeable;
end;

function TStructure.GetRazed: Boolean;
begin
  Result := False;
end;

procedure TStructure.SetRazed(Value: Boolean);
begin end;

function TStructure.VisibleForPlayer(Player: Shortint): Boolean;
var
  Walk: THNWalkData;
begin
  Result := False;
  if Player >= 0 then
  begin
    InitHNWalk(Walk, FXhx, FYhx, 0);
    while (Walk.HN < GetTerrainCount) and not Result do
    begin
      if FResource.TerrainList.Used[Walk.HN] then
        Result := AoWHSMap.VisibleForPlayer(Walk.X, Walk.Y, GetLhx, Player);
      WalkToNextHN(Walk);
    end;
  end;
end;

function TStructure.ValidateObservation(Player: Shortint): Boolean;
var
  Walk: THNWalkData;
  Level: TMapLevel;
begin
  Result := False;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while (Walk.HN < GetTerrainCount) and not Result do
  begin
    if FResource.TerrainList.Used[Walk.HN] and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      Result := AoWHSMap.ValidateObservation(Player, Walk.X, Walk.Y, GetLhx, 0);
    WalkToNextHN(Walk);
  end;
end;

function TStructure.ExecuteRebuild(AUnit: TAbstractUnit): Boolean;
var
  Cost, Time: Integer;
  Reason: string;
begin
  Result := CanRebuild(AUnit, Reason);
  if Result then
  begin
    GetRebuildInfo(Cost, Time);
    AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).SetGems(AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FGems - Cost);
    FBuildingDays := Time;
    FBuildingPlayer := AUnit.FPlayer;
    ValidateObservation(AUnit.FPlayer);
    FImageIndex := GetTerrainTypeImage(FTerrainType);
  end;
end;

function TStructure.ExecuteBuild(AUnit: TAbstractUnit; Days: Integer): Boolean;
begin
  FBuildingDays := Days;
  FBuildingPlayer := AUnit.FPlayer;
  FImageIndex := GetTerrainTypeImage(FTerrainType);
  ValidateObservation(AUnit.FPlayer);
  Result := True;
end;

function TStructure.GetBuilding: Boolean;
begin
  Result := FBuildingPlayer <> -1;
end;

procedure TStructure.BuildingDone;
var
  Log: TLocationTextEventLog;
begin
  Log := TLocationTextEventLog.Create(nil);
  Log.FPlayer := FBuildingPlayer;
  if GetRazed then Log.FText := Format(TranslateRStr(StructureRebuiltRStr), [EditName])
  else Log.FText := Format(TranslateRStr(StructureBuiltRStr), [EditName]);
  Log.SetLocation(GetXhx, GetYhx, GetLhx);
  DistributeLocationEventLog(Log, FBuildingPlayer, GetXhx, GetYhx, GetLhx, 0);
  Log.Release;
  SetRazed(False);
  FBuildingPlayer := -1;
  FImageIndex := GetTerrainTypeImage(FTerrainType);
end;

procedure TStructure.GetRebuildInfo(var Cost, Time: Integer);
begin
  with TStructureResource(FResource) do
  begin
    Cost := FRebuildGold;
    Time := FRebuildDays;
  end;
end;

function TStructure.CanRebuild(AUnit: TAbstractUnit; var Reason: string): Boolean;
var
  Cost, Time: Integer;
begin
  if GetRazed then
    if not GetBuilding then
    begin
      GetRebuildInfo(Cost, Time);
      if AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FGems >= Cost then Result := True
      else
      begin
        Reason := TranslateRStr(NotEnoughGoldRStr);
        Result := False;
      end;
    end
    else Result := False
  else Result := False;
end;

function TStructure.Rebuild(AUnit: TAbstractUnit): Boolean;
var
  Reason: string;
  Event: TStructureTE;
begin
  if CanRebuild(AUnit, Reason) and not AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).GetBusy then
  begin
    Event := CreateTE;
    SetupTE(Event);
    Event.FAction := -2;
    Event.FParam := AUnit.FUnitID;
    AoWHSMap.FTokenManager.GetTokenControl(AUnit.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TStructure.NewDay;
begin end;

procedure TStructure.NewTurn(Player: Shortint);
begin
  if Player = FBuildingPlayer then
  begin
    if FBuildingDays <> 0 then Dec(FBuildingDays);
    if FBuildingDays = 0 then BuildingDone;
  end;
end;

procedure TStructure.ArmyPlaced(A1: TArmyHS);
begin end;

procedure TStructure.ArmyRemoved(Army: TArmyHS);
begin end;

procedure TStructure.ArmyChanged(Army: TArmyHS);
begin end;

procedure TStructure.SeatedPlayerChanged;
begin
  FogChanged;
end;

function TStructure.GetDefensePriority: TDefensePriority;
begin Result := dpNone; end;

function TStructure.GetDefenseRequirements(Player: Shortint; var Requirements: TDefenseRequirements): Boolean;
begin Result := False; end;

function TStructure.ListUnits(List: TUnitList): Integer;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
  Army: TArmyHS;
begin
  Result := 0;
  Count := GetTerrainCount;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while Walk.HN < Count do
  begin
    if (FResource.TerrainList.Terrain[Walk.HN] >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Army := TAoWMapField(Level.GetField(Walk.X, Walk.Y)).GetArmyHS;
      if Army <> nil then
      begin
        List.AddUnits(Army.FArmy);
        Inc(Result, Army.FArmy.Count);
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TStructure.ListArmies(List: TArmyHSList): Integer;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
  Army: TEObject;
begin
  List.BeginUpdate;
  Result := 0;
  Count := GetTerrainCount;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while Walk.HN < Count do
  begin
    if (FResource.TerrainList.Terrain[Walk.HN] >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Army := Level.GetField(Walk.X, Walk.Y).FindOwnedChild($20217);
      if Army <> nil then
      begin
        List.AddChild(Army);
        Inc(Result);
      end;
    end;
    WalkToNextHN(Walk);
  end;
  List.EndUpdate;
end;

function TStructure.ValidateMap(Messages: TStrings): Boolean;
begin
  Result := True;
end;

function TStructure.MainValidateMap(Messages: TStrings): Boolean;
var
  Errors: TStringList;
  I: Integer;
begin
  Errors := TStringList.Create;
  Result := ValidateMap(Errors);
  if Errors.Count <> 0 then
  begin
    Messages.Add(Format(TranslateRStr(XatLocationYRStr), [EditName,
      '(' + IntToStr(GetXhx) + ', ' + IntToStr(GetYhx) + ', ' + IntToStr(GetLhx) + ')']));
    for I := 0 to Errors.Count - 1 do Messages.Add('  ' + Errors[I]);
  end;
  Errors.Free;
end;

procedure TStructure.Activate;
begin
  inherited Activate;
  AoWHSMap.FStructureControl.Register(Self);
  if AoWHSMap.FShowUnitShadows and TStructureResource(FResource).FCastsShadow and not GetEditMode then
    CreateShadow;
end;

procedure TStructure.Deactivate;
begin
  AoWHSMap.FStructureControl.Unregister(Self);
  inherited Deactivate;
end;

procedure TStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
    if Msg.MsgID = $1106 then FogChanged
    else if Msg.MsgID = $1200 then
    begin
      UpdateAITarget(TAITargetInfo(Pointer(Msg.Param[0])^), TAITargetData(Pointer(Msg.Param[1])^));
      if TAITargetData(Pointer(Msg.Param[1])^).Priority < 0 then Msg.Result := 1;
    end
    else if Msg.MsgID = $1124 then ArmyChanged(TArmyHS(Msg.Param[0]))
    else if Msg.MsgID = $1102 then ArmyPlaced(TArmyHS(Msg.Param[0]))
    else if Msg.MsgID = $1103 then ArmyRemoved(TArmyHS(Msg.Param[0]))
    else if Msg.MsgID = $1131 then
    begin
      if TStructureResource(FResource).FConnectRoads then Msg.Param[1] := 1;
    end
    else if Msg.MsgID = $1122 then Msg.Result := TStructureResource(FResource).FScannerIcon
    else if Msg.MsgID = $1126 then Msg.Result := Ord(GetDefensePriority)
    else if Msg.MsgID = $1127 then
    begin
      if GetDefenseRequirements(Msg.Param[0], TDefenseRequirements(Pointer(Msg.Param[1])^)) then Msg.Result := 1;
    end
    else if (Msg.MsgID = $110C) and (Msg.HN = 0) then
    begin
      if (FResource.TerrainList.Terrain[Msg.HN] >= 0) and ((AoWHSMap.FFogEnabled = 0) or not FFogged) then
        Inc(Msg.Param[0], $E00);
    end;
end;

procedure TStructure.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020001 then NewDay
  else if Msg.MsgID = $20020002 then NewTurn(Msg.Data[0])
  else if Msg.MsgID = $20020006 then SeatedPlayerChanged
  else if Msg.MsgID = $20020103 then
    if not MainValidateMap(TStrings(Msg.Data[0])) then Msg.Result := 1;
end;

procedure TStructure.ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  FResource.ImageSequenceList.Show(90, Xhp - XhpSurf, Yhp - YhpSurf, 0, SurfaceDesc);
end;

procedure TStructure.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  TStructureResource(FResource).Show(Xhp - XhpSurf, Yhp - YhpSurf, SurfaceDesc, Self);
end;

function TStructure.ShowBorderImage(SurfaceDesc: TSurfaceDesc; R: TRect): Boolean;
var
  TopImage, MiddleImage, BottomImage: TLibraryImage;
  Height, Y, I: Integer;
begin
  Result := False;
  if GetTopBorderImage <> nil then
  begin
    if SurfaceDesc.ClipRect.Right > R.Right then SurfaceDesc.ClipRect.Right := R.Right;
    if SurfaceDesc.ClipRect.Bottom > R.Bottom then SurfaceDesc.ClipRect.Bottom := R.Bottom;
    Height := R.Bottom - R.Top;
    TopImage := GetTopBorderImage;
    MiddleImage := GetMiddleBorderImage;
    BottomImage := GetBottomBorderImage;
    if (BottomImage <> nil) and (TopImage <> nil) and (MiddleImage <> nil) then
    begin
      { Original uses the height, rather than R.Bottom, for the bottom image. }
      BottomImage.Show(R.Left, Height - BottomImage.Height, SurfaceDesc);
      if Height > BottomImage.Height then
      begin
        Y := R.Bottom - BottomImage.Height - MiddleImage.Height;
        for I := 0 to (Height - BottomImage.Height) div MiddleImage.Height do
        begin
          MiddleImage.Show(R.Left, Y, SurfaceDesc);
          Dec(Y, MiddleImage.Height);
        end;
        TopImage.Show(R.Left, R.Top, SurfaceDesc);
      end;
      Result := True;
    end;
  end;
end;

function TStructure.ShowBorderImageDC(DC: HDC; R: TRect): Boolean;
var
  Surface: TDIB16Surface;
  SurfaceDesc: TSurfaceDesc;
begin
  Result := False;
  if GetBottomBorderImage <> nil then
  begin
    Surface := TDIB16Surface.Create(R.Right - R.Left, R.Bottom - R.Top, pfRGB565);
    try
      Surface.Lock(SurfaceDesc);
      Result := ShowBorderImage(SurfaceDesc, Rect(0, 0, R.Right - R.Left, R.Bottom - R.Top));
      Surface.Unlock;
      Surface.BltDC(DC, nil, @R);
    finally
      Surface.Free;
    end;
  end;
end;

function TStructure.CanRaze(Player: Shortint; var Reason: string): Boolean;
var
  Predictor: TCombatPredictor;
  Defenders, Units: TUnitList;
  I: Integer;
begin
  if not GetRazed and GetRazeable then
  begin
    Predictor := TCombatPredictor.Create;
    Defenders := TUnitList.Create(nil);
    Units := TUnitUserList.Create(nil);
    ListUnits(Units);
    for I := 0 to Units.Count - 1 do
      if Units.GetUnit(I).FPlayer = Player then Predictor.AddUnit(Units.GetUnit(I));
    Units.Free;
    GenerateRazeDefenders(Player, Defenders);
    for I := 0 to Defenders.Count - 1 do Predictor.AddOpponent(Defenders.GetUnit(I), 0);
    Predictor.Execute;
    Result := (Predictor.FResult in [3, 4, 6]) and (Predictor.GetSuperiority > 50);
    if not Result then Reason := TranslateRStr(NotEnoughForcesRStr);
    Defenders.Free;
    Predictor.Free;
  end
  else Result := False;
end;

function TStructure.GenerateRazeDefenders(Player: Shortint; Units: TUnitList): Boolean;
var
  Collection: Integer;
  Indexes: TUnitIndexList;
  I: Integer;
begin
  RandSeed := GetXhx + AoWHSMap.FInitialRandomSeed + GetYhx;
  Collection := TStructureResource(FResource).FDefenders.GetRndCollection;
  if Collection <> -1 then
  begin
    Indexes := TUnitIndexList.Create;
    with TStructureResource(FResource).FDefenders do
      for I := GetCollectionCount(Collection) - 1 downto 0 do Indexes.Add(GetU(Collection, I));
    FillWithRandomUnits(Indexes, Units, 4, TStructureResource(FResource).FRazeDefenderBudget,
      [utHumanoid, utCreature, utMachine]);
    while Units.Count > 8 do Units.DeleteUnit(Units.GetUnit(Units.Count - 1));
    Indexes.Free;
  end;
  Result := True;
end;

procedure TStructure.SetupRazeDefenderAG(Attackers, Defenders: TUnitList);
var
  Group: THuntAG;
  I: Integer;
begin
  Group := THuntAG(AoWHSMap.FAIGroupManager.CreateGroup(0, UnitsToIndependentRelation(Defenders, 5), gbHunt));
  Group.AddUnits(Defenders);
  for I := Attackers.Count - 1 downto 0 do
    if Attackers.GetUnit(I).FPlayer <> 0 then Group.FTargetUnitIDs.Add(Attackers.GetUnit(I).FUnitID);
  Group.Release;
end;

function TStructure.PlaceRazeDefenders(Player: Shortint): Boolean;
var
  Defenders, Placed, Attackers: TUnitList;
  I: Integer;
  AUnit: TAbstractUnit;
begin
  Defenders := TUnitList.Create(nil);
  Placed := TUnitUserList.Create(nil);
  Attackers := TUnitUserList.Create(nil);
  GenerateRazeDefenders(Player, Defenders);
  if Defenders.Count <> 0 then
  begin
    for I := Defenders.Count - 1 downto 0 do
    begin
      AUnit := Defenders.GetUnit(I);
      Placed.AddUnit(AUnit);
      AUnit.Place(GetXhx, GetYhx, GetLhx, 0, [pmScanArea]);
    end;
    ListUnits(Attackers);
    SetupRazeDefenderAG(Attackers, Placed);
    Result := True;
  end
  else Result := False;
  Attackers.Free;
  Placed.Free;
  Defenders.Free;
end;

procedure TStructure.ShowRazeAnimation(Animation: TAnimation; X, Y: Integer; const SurfaceDesc: TSurfaceDesc);
begin
  if (TImageSequenceAnimation(Animation).FImageSequence.GetUnloopedFrameIndex(Animation.FFrameCounter) = 0) and
    (AoWEngine.FAnimationDetail <> 0) then Sound.PlaySample(ExplosionSFX[System.Random(2)]);
end;

function TStructure.ExecuteRaze(Player: Shortint): Boolean;
var
  Reason: string;
  Log: TLocationTextEventLog;
  Animation: TImageSequenceAnimation;
begin
  if CanRaze(Player, Reason) then
  begin
    BeginUpdate;
    Log := TLocationTextEventLog.Create(nil);
    Log.FPlayer := Player;
    Log.FText := Format(TranslateRStr(StructureRazedRStr), [EditName]);
    Log.SetLocation(GetXhx, GetYhx, GetLhx);
    DistributeLocationEventLog(Log, Player, GetXhx, GetYhx, GetLhx, 0);
    Log.Release;
    if FResource.ImageSequenceList.GetImageSequence(20) <> nil then
    begin
      Animation := TImageSequenceAnimation.Create(nil);
      Animation.SetImageSequence(FResource.ImageSequenceList.GetImageSequence(20));
      Animation.SetXhpOffset(Animation.FXhpOffset - 16);
      Animation.SetYhpOffset(Animation.FYhpOffset - 16);
      Animation.FOnShow := ShowRazeAnimation;
      AoWHSMap.PlaceHX(Animation, GetXhx, GetYhx, GetLhx);
    end;
    if FResource.ImageSequenceList.GetImageSequence(21) <> nil then
    begin
      Animation := TImageSequenceAnimation.Create(nil);
      Animation.SetImageSequence(FResource.ImageSequenceList.GetImageSequence(21));
      Animation.FFrameCount := 300;
      Animation.SetXhpOffset(Animation.FXhpOffset - 16);
      Animation.SetYhpOffset(Animation.FYhpOffset - 16);
      Animation.FLooped := True;
      AoWHSMap.PlaceHX(Animation, GetXhx, GetYhx, GetLhx);
    end;
    ValidateObservation(Player);
    SetRazed(True);
    PlaceRazeDefenders(Player);
    EndUpdate;
    Result := True;
  end
  else Result := False;
end;

function TStructure.RazeEx(Player: Shortint): Boolean;
var
  Reason: string;
  Event: TStructureTE;
begin
  if CanRaze(Player, Reason) and not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy then
  begin
    Event := CreateTE;
    SetupTE(Event);
    Event.FAction := -1;
    Event.FParam := Player;
    AoWHSMap.FTokenManager.GetTokenControl(Player).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TStructure.Raze(Player: Shortint): Boolean;
var
  Reason: string;
  Log: TRazeStructureEventLog;
begin
  if CanRaze(Player, Reason) and not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy then
  begin
    if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) then Result := RazeEx(Player)
    else
    begin
      Log := TRazeStructureEventLog.Create(nil);
      Log.FStructure := Self;
      Log.FButtons := mebYesNo;
      Log.FTitle := TranslateRStr(WarningRStr);
      Log.FMessage.Add(TranslateRStr(RazeStructureWarningRStr));
      Log.FMessage.Add(TranslateRStr(DoYouWishToContinueRStr));
      Log.Execute(True, etUser, nil);
      Log.Release;
      Result := True;
    end;
  end
  else Result := False;
end;

procedure TStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $08000000;
end;

constructor TStructureResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetLevel(26);
  FConnectRoads := True;
  FTerrainBound := True;
  FDescription := TStringList.Create;
  FDefenders := TUnitIndexListCollection.Create;
  FRazeDefenderBudget := 50;
  FRazeable := False;
end;

destructor TStructureResource.Destroy;
begin
  FDescription.Free;
  FDefenders.Free;
  inherited Destroy;
end;

class function TStructureResource.ClassID: Integer;
begin Result := $2034B; end;

class function TStructureResource.ResourceEditName: string;
begin Result := ''; end;

function TStructureResource.ResourceUserClassID: Integer;
begin Result := $2034A; end;

procedure TStructureResource.CalculatePadIndex;
var
  I: Integer;
begin
  FFlagType := 0;
  for I := 0 to FTerrainList.Count - 1 do
    if FTerrainList.Terrain[I] >= 0 then Inc(FFlagType);
end;

procedure TStructureResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(F_StructureResource_4C, 20);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FSelectSFX, 21);
  Stream.rwStrings(FDescription, 22);
  Stream.rwInteger(FScannerIcon, 23);
  Stream.rwStreamProc(28, FDefenders.SaveToStream, FDefenders.LoadFromStream);
  if smRead in Stream.StorageMode then CalculatePadIndex;
end;

procedure TStructureResource.Show(X, Y: Integer; const SurfaceDesc: TSurfaceDesc; Structure: TStructure);
var
  Index, Offset, FrameIndex: Integer;
  Sequence: TImageSequence;
begin
  if Structure.GetSelected and (AoWHSMap.Frame and 6 = 6) then
  begin
    Index := Structure.ImageIndex;
    Offset := TMapField(Structure.Owner).Xhx + TMapField(Structure.Owner).Yhx * 16;
    if FImageSequenceList <> nil then
    begin
      Sequence := FImageSequenceList.List^[Index];
      while Sequence <> nil do
      begin
        FrameIndex := Sequence.GetFrameIndex(AoWHSMap.Frame, Offset);
        if FrameIndex <> -1 then
          if Sequence.ImageLibrary[FrameIndex].ShowInfo.ShowMode = smOpaque then
            Sequence.ImageLibrary[FrameIndex].ShowTransparent(X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc)
          else Sequence.ImageLibrary[FrameIndex].Show(X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc);
        Sequence := Sequence.Next;
      end;
    end
    else FImageLibrary[Index].ShowTransparent(X + FdXImage, Y + FdYImage, SurfaceDesc);
  end
  else
    if FImageSequenceList = nil then FImageLibrary[Structure.ImageIndex].Show(X, Y, SurfaceDesc)
    else ShowComplexImage(X, Y, SurfaceDesc, Structure.ImageIndex,
      TMapField(Structure.Owner).Xhx + TMapField(Structure.Owner).Yhx * 16);
end;

constructor TPlayerStructure.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FVictoryLocations := TBitList.Create;
  FUnfogRange := 0;
end;

destructor TPlayerStructure.Destroy;
begin
  inherited Destroy;
  FVictoryLocations.Free;
end;

class function TPlayerStructure.ClassID: Integer;
begin Result := $2034C; end;

function TPlayerStructure.GetVictoryLocation(Player: Shortint): Boolean;
begin
  Result := FVictoryLocations[Player];
end;

procedure TPlayerStructure.SetVictoryLocation(Player: Shortint; Value: Boolean);
begin
  if FVictoryLocations[Player] <> Value then
  begin
    FVictoryLocations[Player] := Value;
    if Value then AoWHSMap.FPlayers.GetPlayers(Player).RegisterVictoryLocation(Self)
    else AoWHSMap.FPlayers.GetPlayers(Player).UnregisterVictoryLocation(Self);
    Update;
  end;
end;

procedure TPlayerStructure.RegisterVictoryLocations;
var
  I: Integer;
begin
  for I := 1 to FVictoryLocations.Count - 1 do
    if FVictoryLocations[I] then
      if AoWHSMap.FPlayers.GetPlayers(I) <> nil then
        AoWHSMap.FPlayers.GetPlayers(I).RegisterVictoryLocation(Self)
      else FVictoryLocations[I] := False;
end;

procedure TPlayerStructure.UnregisterVictoryLocations;
var
  I: Integer;
begin
  for I := 1 to FVictoryLocations.Count - 1 do
    if FVictoryLocations[I] and (AoWHSMap.FPlayers.GetPlayers(I) <> nil) then
      AoWHSMap.FPlayers.GetPlayers(I).UnregisterVictoryLocation(Self);
end;

procedure TPlayerStructure.BuildingDone;
begin
  inherited BuildingDone;
  UpdatePlayer;
  UpdateExploration;
  UpdateUnfog;
end;

function TPlayerStructure.CanRebuild(AUnit: TAbstractUnit; var Reason: string): Boolean;
begin
  Result := inherited CanRebuild(AUnit, Reason);
end;

function TPlayerStructure.ExecuteRebuild(AUnit: TAbstractUnit): Boolean;
begin
  Result := inherited ExecuteRebuild(AUnit);
  if Result then SetPlayer(AUnit.FPlayer);
end;

function TPlayerStructure.ExecuteBuild(AUnit: TAbstractUnit; Days: Integer): Boolean;
begin
  Result := inherited ExecuteBuild(AUnit, Days);
  if Result then SetPlayer(AUnit.FPlayer);
end;

function TPlayerStructure.UpdatePlayer: Boolean;
var
  Player: Shortint;
  Different: Boolean;
  Count: Integer;
  Level: TMapLevel;
  Walk: THNWalkData;
  Army: TArmyHS;
begin
  Player := -1;
  Different := False;
  Count := GetTerrainCount;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while (Walk.HN < Count) and not Different do
  begin
    if (FResource.TerrainList.Terrain[Walk.HN] >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Army := TArmyHS(Level.GetField(Walk.X, Walk.Y).FindOwnedChild($20217));
      if Army <> nil then
        if Player <> -1 then Different := Army.FArmy.FPlayer <> Player
        else Player := Army.FArmy.FPlayer;
    end;
    WalkToNextHN(Walk);
  end;
  if Player <> -1 then
    if Different then SetPlayer(-1) else SetPlayer(Player);
  Result := not Different;
end;

procedure TPlayerStructure.NewTurn(Player: Shortint);
begin
  inherited NewTurn(Player);
  if (Player = FPlayer) and (FProductionPriority <> $FF) then Inc(FProductionPriority);
end;

procedure TPlayerStructure.NewDay;
begin
  inherited NewDay;
  if (AoWHSMap.FDay = 1) and (FPlayer > 0) then
  begin
    UpdateExploration;
    UpdatePlayerSeen;
  end;
end;

procedure TPlayerStructure.StructureCaptured(OldPlayer, NewPlayer: Shortint);
var
  Log: TLocationTextEventLog;
  Text: string;
begin
  if not GetRazed and not GetBuilding and (OldPlayer = 0) and
    not (msEditting in AoWHSMap.Status) and (moActivated in FStatus) and
    not TPlayerStructureResource(FResource).FClaimed then
  begin
    Log := TLocationTextEventLog.Create(nil);
    Log.FPlayer := NewPlayer;
    Text := Format(TranslateRStr(StructureCapturedRStr), [EditName]);
    Log.FText := Text;
    Log.FXhx := GetXhx;
    Log.FYhx := GetYhx;
    Log.FLhx := GetLhx;
    DistributeLocationEventLog(Log, FPlayer, GetXhx, GetYhx, GetLhx, 0);
    Log.Release;
  end;
end;

function TPlayerStructure.GetCombatEventText(Combat: TCombat): string;
begin
  if not GetRazed then
    if Combat.FCombatResult in [crVictory, crNoDefenders] then
      Result := Format(TranslateRStr(StructureCapturedRStr), [EditName])
    else Result := '';
  { Original leaves the result unchanged for a razed structure. }
end;

procedure TPlayerStructure.FinalizeCombat(Combat: TCombat);
begin
  if Combat.FCombatResult in [crVictory, crNoDefenders] then
    with Combat.FCombatData do SetPlayer(FPlayers.GetPlayers(FAttackerPlayer).FPlayer);
end;

procedure TPlayerStructure.SetPlayer(Player: Shortint);
var
  I: Integer;
begin
  if Player <> FPlayer then
  begin
    if GetRazed and not GetBuilding then Exit;
    FProductionPriority := 0;
    if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FStructures.RemoveChild(Self);
    if AoWHSMap.FDay > 0 then StructureCaptured(FPlayer, Player);
    FPlayer := Player;
    UpdateUnfog;
    UpdatePlayerSeen;
    UpdateExploration;
    AoWHSMap.ScannerIconsChangedRad(GetXhx, GetYhx, GetLhx, HNtoRad(FResource.TerrainList.Count));
    UpdateFlagID;
    FogChanged;
    AoWHSMap.NotifyPlayerChanged(GetXhx, GetYhx, GetLhx);
    if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FStructures.AddChild(Self);
    if (FPlayer > 0) and (AoWHSMap.FVictoryCondition = vcCaptureLocations) then
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        if FVictoryLocations[I] then
          if (I = FPlayer) or (AoWHSMap.FAlliedVictory and
            (AoWHSMap.FPlayers.GetDiplomaticRelation(FPlayer, I) = drAlliance)) then
            AoWHSMap.FPlayers.GetPlayers(I).CheckCaptureLocations;
    Update;
  end;
end;

procedure TPlayerStructure.UpdateFlagID;
begin
  if not (moEditMode in FStatus) then
    if FPlayer < 1 then
      if not TPlayerStructureResource(FResource).FClaimed then FFlagID := $3F
      else FFlagID := $20
    else FFlagID := AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace
  else FFlagID := $3F;
end;

procedure TPlayerStructure.ArmyPlaced(A1: TArmyHS);
begin UpdatePlayer; end;

procedure TPlayerStructure.ArmyChanged(Army: TArmyHS);
begin UpdatePlayer; end;

function TPlayerStructure.GetIncome: Integer;
begin Result := 0; end;

function TPlayerStructure.GetPower: Integer;
begin Result := 0; end;

procedure TPlayerStructure.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), 5);
  Stream.rwStreamProc(6, FVictoryLocations.SaveToStream, FVictoryLocations.LoadFromStream);
  Stream.rwByte(FProductionPriority, 7);
end;

procedure TPlayerStructure.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  if (FFlagID <> $3F) and ((AoWHSMap.FFogEnabled = 0) or not FFogged) then
    with TPlayerStructureResource(FResource) do
      if FFlagType <= 1 then
        AoWHSSet.FFlagControl.ShowFlag(FFlagX + XhpSurf, FFlagY + YhpSurf,
          Engine.HSMap.Frame + Xhp, FFlagID, SurfaceDesc)
      else FFlagControl.ShowStructureFlag(FFlagX + XhpSurf, FFlagY + YhpSurf,
          Engine.HSMap.Frame + Xhp, FFlagID, SurfaceDesc);
  TPlayerStructureResource(FResource).Show(XhpSurf, YhpSurf, SurfaceDesc, Self);
end;

function TPlayerStructure.TrueVisionRange: Integer;
begin Result := 1; end;

function TPlayerStructure.VisibilityRange: Integer;
begin
  if not GetBuilding then
  begin
    Result := 6;
    if (GetLhx <> 0) or ((FPlayer > 0) and
      (Byte(AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FEnemyEnchantments) and 8 <> 0)) then
      Result := (Result + 1) shr 1;
  end
  else Result := 4;
end;

procedure TPlayerStructure.UpdatePlayerSeen;
var
  I, X, Y: Integer;
begin
  if (moPlacedOnMap in FStatus) and (FPlayer > 0) then
    for I := 0 to FResource.TerrainList.Count - 1 do
      if FResource.TerrainList.Terrain[I] >= 0 then
      begin
        CenterHNtoHX(FXhx, FYhx, I, X, Y);
        AoWHSMap.UpdatePlayerSeen(FPlayer, X, Y, GetLhx, VisibilityRange, TrueVisionRange);
      end;
end;

procedure TPlayerStructure.UpdateExploration;
var
  Player, I, X, Y: Integer;
begin
  if (moPlacedOnMap in FStatus) and (FPlayer > 0) then
    for Player := 1 to AoWHSMap.FPlayers.Count - 1 do
      if (Player = FPlayer) or
        (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Player) = drAlliance) then
        for I := 0 to FResource.TerrainList.Count - 1 do
          if FResource.TerrainList.Terrain[I] >= 0 then
          begin
            CenterHNtoHX(FXhx, FYhx, I, X, Y);
            AoWHSMap.ExploreArea(X, Y, TMapField(Owner).Lhx, Player, VisibilityRange);
          end;
end;

procedure TPlayerStructure.UpdateUnfog;
var
  Range, I, X, Y: Integer;
begin
  if not (moPlacedOnMap in FStatus) then Exit;
  if (moActivated in FStatus) and (FPlayer <> -1) and (AoWHSMap.FSeatedPlayer <> -1) and
    ((AoWHSMap.FSeatedPlayer = FPlayer) or
    (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(AoWHSMap.FSeatedPlayer) = drAlliance)) then
    Range := VisibilityRange
  else Range := 0;
  if Range <> FUnfogRange then
  begin
    if FUnfogRange <> 0 then
      for I := 0 to FResource.TerrainList.Count - 1 do
        if FResource.TerrainList.Terrain[I] >= 0 then
        begin
          CenterHNtoHX(FXhx, FYhx, I, X, Y);
          AoWHSMap.FogArea(X, Y, TMapField(Owner).Lhx, FUnfogRange);
        end;
    FUnfogRange := Range;
    if FUnfogRange <> 0 then
      for I := 0 to FResource.TerrainList.Count - 1 do
        if FResource.TerrainList.Terrain[I] >= 0 then
        begin
          CenterHNtoHX(FXhx, FYhx, I, X, Y);
          AoWHSMap.UnFogArea(X, Y, TMapField(Owner).Lhx, FUnfogRange);
        end;
  end;
end;

procedure TPlayerStructure.SeatedPlayerChanged;
begin
  inherited SeatedPlayerChanged;
  UpdateUnfog;
end;

procedure TPlayerStructure.Activate;
begin
  inherited Activate;
  UpdateFlagID;
  UpdateUnfog;
  RegisterVictoryLocations;
  if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FStructures.AddChild(Self);
end;

procedure TPlayerStructure.Deactivate;
begin
  if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FStructures.RemoveChild(Self);
  UnregisterVictoryLocations;
  inherited Deactivate;
  UpdateUnfog;
end;

procedure TPlayerStructure.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    if not GetRazed and (FPlayer <> -1) and (TMoveControl(Info.Sender).FPlayer <> FPlayer) and
      (Info.MoveOverCode <> 1) then
    begin
      MoveResult.Code := -1;
      MoveResult.Done := True;
    end;
end;

function TPlayerStructure.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if (FResource.TerrainList.Terrain[Info.HN] >= 0) and (not GetRazed or GetBuilding) then
  begin
    if FPlayer = 0 then
      if (TMoveControl(Info.Sender).FPlayer = FPlayer) or not TPlayerStructureResource(FResource).FClaimed then
        Result := 1
      else Result := 0
    else
      if (TMoveControl(Info.Sender).FPlayer = FPlayer) or (FPlayer = -1) then Result := 1
      else Result := 0;
  end
  else Result := 1;
end;

procedure TPlayerStructure.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then
  begin
    if AoWHSMap.FPlayers.GetNumberOfPlayers < FPlayer then SetPlayer(0);
    UpdateFlagID;
  end
  else if Msg.MsgID = $20020008 then
  begin
    UpdateExploration;
    UpdateUnfog;
  end;
end;

procedure TPlayerStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $0B007000;
end;

function TPlayerStructure.GetDefaultAITargetPriority: Integer;
begin Result := 10; end;

procedure TPlayerStructure.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
begin
  if GetRazed and not GetBuilding then Exit;
  case Info.Mode of
    tmAttack:
      if (Info.Player <> FPlayer) and not GetRazed then
        if (FPlayer = 0) or ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, 0) then
          Data.Priority := GetDefaultAITargetPriority;
  end;
end;

function TPlayerStructure.GetMoveAction(Player: Shortint; Action: TMoveAction): TMoveAction;
begin
  if (Player <> FPlayer) and not GetRazed and
    ((FPlayer <> 0) or TPlayerStructureResource(FResource).FClaimed) then Action := maAttack;
  Result := Action;
end;

procedure TPlayerStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if (Msg.MsgID = $110C) and (Msg.HN = 0) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
  begin
    if (AoWHSMap.FFogEnabled = 0) or not FFogged then
    begin
      if FPlayer < 0 then Inc(Msg.Param[0], $E00)
      else if FPlayer < 1 then Inc(Msg.Param[0], $D00)
      else Inc(Msg.Param[0], (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace + 1) * $100);
      if (AoWHSMap.FVictoryCondition = vcCaptureLocations) and FVictoryLocations[AoWHSMap.FSeatedPlayer] then
        Msg.Param[0] := Msg.Param[0] or $1000000;
    end
    else Inc(Msg.Param[0], $E00);
  end
  else inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1100 then
  begin
    if (FResource.TerrainList.Terrain[Msg.HN] >= 0) and not GetRazed then
      if FPlayer = 0 then
        if not TPlayerStructureResource(FResource).FClaimed then Msg.Result := -1 else Msg.Result := 0
      else Msg.Result := FPlayer;
  end
  else if (Msg.MsgID = $110D) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
  begin
    if (FPlayer > 0) and (Msg.Param[0] <= VisibilityRange) then
      AoWHSMap.UpdatePlayerSeen(FPlayer, Msg.MapField.Xhx, Msg.MapField.Yhx, Msg.MapField.Lhx,
        Msg.Param[0], TrueVisionRange);
  end
  else if (Msg.MsgID = $1130) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then Msg.Result := FPlayer
  else if (Msg.MsgID = $1101) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
    Msg.Param[1] := Ord(GetMoveAction(Msg.Param[0], TMoveAction(Msg.Param[1])))
  else if (Msg.MsgID = $110A) and (FPlayer > 0) then
  begin
    if (FPlayer = Msg.Param[1]) or
      (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Msg.Param[1]) = drAlliance) then
      if Msg.Param[0] <= VisibilityRange then Msg.Result := 1;
  end;
  if (Msg.MsgID = $110B) and (FPlayer > 0) then
  begin
    if (FPlayer = Msg.Param[1]) or
      (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Msg.Param[1]) = drAlliance) then
      if Msg.Param[0] <= TrueVisionRange then Msg.Result := 1;
  end
  else if (Msg.MsgID = $1110) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
    FinalizeCombat(TCombat(Msg.Param[0]))
  else if (Msg.MsgID = $1109) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
    string(Pointer(Msg.Result)^) := GetCombatEventText(TCombat(Msg.Param[0]));
end;

{ TPlayerStructureResource (instance size 116; $64 claimed, $68/$6C flag position, $70 flag control). }
constructor TPlayerStructureResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FClaimed := True;
  FFlagX := 20;
  FFlagY := -35;
end;

destructor TPlayerStructureResource.Destroy;
begin
  inherited Destroy;
end;

class function TPlayerStructureResource.ClassID: Integer;
begin
  Result := $2034D;
end;

function TPlayerStructureResource.ResourceUserClassID: Integer;
begin
  Result := $2034C;
end;

procedure TPlayerStructureResource.GenerateFlagPositions;
begin
  if FTerrainBound then
    case FFlagType of
      1: begin FFlagX := 20; FFlagY := -30; end;
      2: begin FFlagX := 35; FFlagY := -50; end;
      3: begin FFlagX := 5; FFlagY := -45; end;
      4: begin FFlagX := 30; FFlagY := -60; end;
    end;
end;

procedure TPlayerStructureResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if smRead in Stream.StorageMode then GenerateFlagPositions;
end;

procedure TPlayerStructureResource.ActivateMsg;
begin
  FFlagControl := TAoWHSSet(Engine.HSSet).FFlagControl;
end;

procedure TPlayerStructureResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then ActivateMsg;
end;

function TPlayerStructureResource.PlaceResourceUser(HSMap: HSEngine.THSMap; Xhx, Yhx, Lhx: Shortint): HSEngine.TMapObject;
begin
  Result := inherited PlaceResourceUser(HSMap, Xhx, Yhx, Lhx);
  if (Result <> nil) and (msEditting in AoWHSMap.Status) then
    TPlayerStructure(Result).SetPlayer(AoWHSMap.FEditorPlayer);
end;

{ TPlayerStructureIncomeSource (instance size 12; $08 FStructure). }
procedure TPlayerStructureIncomeSource.Setup(Structure: TPlayerStructure);
begin
  FStructure := Structure;
end;

function TPlayerStructureIncomeSource.Name: string;
begin
  Result := FStructure.GetName;
end;

function TPlayerStructureIncomeSource.Income: Integer;
begin
  Result := FStructure.GetIncome;
end;

procedure TPlayerStructureIncomeSource.GetLocation(var X, Y, L: Shortint);
begin
  X := FStructure.Xhx;
  Y := FStructure.Yhx;
  L := FStructure.Lhx;
end;

{ TPlayerStructurePowerSource (instance size 12; $08 FStructure). }
procedure TPlayerStructurePowerSource.Setup(Structure: TPlayerStructure);
begin
  FStructure := Structure;
end;

function TPlayerStructurePowerSource.Name: string;
begin
  Result := FStructure.GetName;
end;

function TPlayerStructurePowerSource.Power: Integer;
begin
  Result := FStructure.GetPower;
end;

procedure TPlayerStructurePowerSource.GetLocation(var X, Y, L: Shortint);
begin
  X := FStructure.Xhx;
  Y := FStructure.Yhx;
  L := FStructure.Lhx;
end;

procedure TPlayerStructurePowerSource.Select;
begin
  AoWHSMap.Select(FStructure, True);
end;

{ TStructureTE (instance size 40; $10/$11/$12 coordinates, $13 player, $14 class ID, $18 action, $1C razed, $20/$24 parameters). }
class function TStructureTE.ClassID: Integer;
begin
  Result := $21110;
end;

procedure TStructureTE.Initialize(AClassID: Integer; X, Y, L: Shortint);
var
  MapField: TAoWMapField;
  Structure: TStructure;
begin
  FX := X;
  FY := Y;
  FL := L;
  MapField := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
  Structure := TStructure(MapField.FindOwnedChild(AClassID));
  Assert(AClassID = Structure.ClassID, 'Invalid position (StructureTE)');
  FStructureClassID := AClassID;
  FRazed := Structure.GetRazed;
  FPlayer := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetPlayer;
end;

procedure TStructureTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAction, 15);
  Stream.rwByte(Byte(FX), 16);
  Stream.rwByte(Byte(FY), 17);
  Stream.rwByte(Byte(FL), 18);
  Stream.rwByte(Byte(FPlayer), 19);
  Stream.rwInteger(FStructureClassID, 20);
  Stream.rwBool(FRazed, 21);
  Stream.rwInteger(FParam, 22);
  Stream.rwInteger(FParam2, 23);
end;

function TStructureTE.Validate: Boolean;
var
  Structure: TStructure;
  MapField: TAoWMapField;
begin
  MapField := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
  Structure := TStructure(MapField.FindOwnedChild(FStructureClassID));
  if (Structure <> nil) and (Structure.ClassID = FStructureClassID) then
    Result := MapField.GetPlayer = FPlayer
  else Result := False;
end;

function TStructureTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin
  if (TE.ExecuteCount <> 0) or Validate then
    Result := TStructure(AoWHSMap.MapContainer.GetField(FX, FY, FL).
      FindOwnedChild(FStructureClassID)).ExecuteTE(Self, TE)
  else Result := erDoneHalt;
end;

{ TRazeStructureEventLog (instance size 44; $28 FStructure). }
function TRazeStructureEventLog.Yes: Boolean;
begin
  FStructure.RazeEx(AoWHSMap.FSeatedPlayer);
  Result := True;
end;

{ TConstructStructureTE (instance size 28; $10 unit ID, $14 player, $18 construction control ID). }
class function TConstructStructureTE.ClassID: Integer;
begin
  Result := $2131A;
end;

procedure TConstructStructureTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FControlID, 20);
  Stream.rwInteger(FUnitID, 21);
  Stream.rwByte(Byte(FPlayer), 22);
end;

function TConstructStructureTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  AUnit: TAbstractUnit;
  Control: TStructureConstructionControl;
  Resource: TStructureResource;
  Structure: TStructure;
  Reason, Text: string;
  Gold, Days: Integer;
  Owner: TEChangeNotifyNode;
  X, Y, L: Shortint;
  Level: TMapLevel;
  Walk: THNWalkData;
begin
  Result := erDoneHalt;
  inherited Execute(TE);
  AUnit := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  Control := TStructureConstructionControl(TConstructAbility(
    AoWHSSet.FAbilityControl.GetAbility(125)).FConstructionControls.FindID(FControlID));
  if (Control <> nil) and (AUnit <> nil) and (AUnit.FPlayer = FPlayer) and
    Control.CanConstruct(AUnit, Reason) then
  begin
    Resource := Control.StructureResource(AUnit);
    if Resource <> nil then
    begin
      AUnit.GetLocation(X, Y, L);
      Level := AoWHSMap.MapContainer.GetMapLevel(L);
      InitHNWalk(Walk, X, Y, 0);
      while Walk.HN < Resource.TerrainList.Count do
      begin
        if (Walk.X >= 0) and (Walk.Y >= 0) and (Level.Width > Walk.X) and
          (Level.Height > Walk.Y) and Resource.TerrainList.GetUsed(Walk.HN) then
          AoWHSMap.ClearTerrain(Walk.X, Walk.Y, L, 0, -1);
        WalkToNextHN(Walk);
      end;
      Owner := TEChangeNotifyNode(AUnit.Owner);
      Owner.BeginUpdate;
      Structure := TStructure(Resource.PlaceResourceUser(AoWHSMap, X, Y, L));
      if Structure <> nil then
      begin
        Control.GetInfo(AUnit, Text, Gold, Days);
        Structure.ExecuteBuild(AUnit, Days);
        AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).SetGems(
          AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FGems - Gold);
        AUnit.Killed;
        Result := erDone;
      end;
      Owner.EndUpdate;
    end;
  end;
end;

resourcestring
  CannotBuildOnCurrentLocationRStr = 'Cannot build on current location';

{ TStructureConstructionControl (instance size 8; no additional fields). }
function TStructureConstructionControl.StructureResource(AUnit: TAbstractUnit): TStructureResource;
{ conflict: function TStructureConstructionControl.StructureResource: TStructureResource; }
begin Result := nil; end;

function TStructureConstructionControl.ValidateLocation(AUnit: TAbstractUnit; var Reason: string): Boolean;
var
  Resource: TStructureResource;
  X, Y, L: Shortint;
  Level: TMapLevel;
  MapField: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := True;
  Resource := StructureResource(AUnit);
  AUnit.GetLocation(X, Y, L);
  Level := AoWHSMap.MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Resource.TerrainList.Count > Walk.HN) and Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and
      (Walk.Y < Level.Height) then
    begin
      if Resource.TerrainList.GetUsed(Walk.HN) then
      begin
        MapField := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
        Result := (MapField.GetPlayer = -1) or (MapField.GetPlayer = AUnit.FPlayer);
        Result := Result and (MapField.FindNoneTransparentHS(TStructure) = nil);
        Result := Result and not (MapField.OverlayType in [0, 2]);
        Result := Result and (MapField.TerrainType in [1..5, 12]);
      end;
    end
    else Result := False;
    WalkToNextHN(Walk);
  end;
  if not Result then Reason := TranslateRStr(CannotBuildOnCurrentLocationRStr);
end;

function TStructureConstructionControl.CanConstruct(A1: TAbstractUnit; var A2: string): Boolean;
begin
  Result := ValidateLocation(A1, A2);
  if Result then Result := inherited CanConstruct(A1, A2) and (StructureResource(A1) <> nil);
end;

function TStructureConstructionControl.Construct(AUnit: TAbstractUnit): Boolean;
var
  Event: TConstructStructureTE;
  Reason: string;
begin
  if CanConstruct(AUnit, Reason) and not AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).GetBusy then
  begin
    Event := TConstructStructureTE.Create(nil);
    Event.FUnitID := AUnit.FUnitID;
    Event.FPlayer := AUnit.FPlayer;
    Event.FControlID := ID;
    AoWHSMap.FTokenManager.GetTokenControl(AUnit.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

{ TStructureControl (instance size 20; $08 structures, $0C next ID, $10 city count). }
constructor TStructureControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FStructures := TENode.Create(nil);
  FNextID := 0;
end;

destructor TStructureControl.Destroy;
begin
  FStructures.Free;
  inherited Destroy;
end;

function TStructureControl.GetStructure(Index: Integer): TStructure;
begin
  if (Index >= 0) and (Index < GetCount) then
    Result := FStructures.FChildren.List^[Index]
  else Result := nil;
end;

function TStructureControl.GetCount: Integer;
begin
  Result := FStructures.GetCount;
end;

procedure TStructureControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FNextID, 20);
  Stream.rwInteger(FCityCount, 21);
end;

function TStructureControl.CreateUniqueID: Integer;
begin
  repeat
    Inc(FNextID);
    if FNextID > $0FFFFFFF then FNextID := 0;
  until IndexOfID(FNextID) = -1;
  Result := FNextID;
end;

function TStructureControl.IndexOfID(ID: Integer): Integer;
begin
  Result := GetCount;
  if Result <> 0 then
    repeat
      Dec(Result);
      if ID = TStructure(FStructures.FChildren.List^[Result]).FStructureID then Exit;
    until Result = 0;
  Result := -1;
end;

function TStructureControl.FindID(ID: Integer): TStructure;
var
  Index: Integer;
begin
  Index := IndexOfID(ID);
  if Index <> -1 then Result := FStructures.FChildren.List^[Index]
  else Result := nil;
end;

procedure TStructureControl.Register(Structure: TStructure);
begin
  Assert(FStructures.FChildren.IndexOf(Structure) = -1);
  if (Structure.FStructureID = 0) or (IndexOfID(Structure.FStructureID) <> -1) then
    Structure.FStructureID := CreateUniqueID;
  FStructures.AddChild(Structure);
  if Structure.ClassID = $20108 then Inc(FCityCount);
end;

procedure TStructureControl.Unregister(Structure: TStructure);
begin
  FStructures.FChildren.Remove(Structure);
  if Structure.ClassID = $20108 then Dec(FCityCount);
end;

procedure TStructureControl.Activate;
begin
  FCityCount := 0;
end;

{ TStructureAIPA (instance size 28; $14 phase, $18 structure IDs). }
constructor TStructureAIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FStructureIDs := TIntegerList.Create;
end;

destructor TStructureAIPA.Destroy;
begin
  FStructureIDs.Free;
  inherited Destroy;
end;

function TStructureAIPA.Activate: Boolean;
var
  I: Integer;
begin
  inherited Activate;
  if FControl.FPlayer.FPlayerIndex > 0 then
  begin
    for I := 0 to AoWHSMap.FStructureControl.GetCount - 1 do
      FStructureIDs.Add(AoWHSMap.FStructureControl.GetStructure(I).FStructureID);
    Result := True;
  end
  else Result := False;
end;

function TStructureAIPA.Process: Boolean;
var
  Waiting: Boolean;
  Structure: TStructure;
begin
  Waiting := False;
  while not Waiting and (FStructureIDs.Count <> 0) and
    (AoWHSMap.FAIExecuter.GetProcessTimeLeft > 0) and not FControl.FPlayer.GetBusy do
  begin
    Structure := AoWHSMap.FStructureControl.FindID(FStructureIDs[FStructureIDs.Count - 1]);
    if Structure <> nil then Waiting := Structure.ExecuteAI(FControl.FPlayer.FPlayerIndex, FPhase);
    if not Waiting then FStructureIDs.Delete(FStructureIDs.Count - 1);
  end;
  Result := FStructureIDs.Count <> 0;
end;

{ TStructurePhase1AIPA (instance size 28; inherited $14 phase). }
constructor TStructurePhase1AIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPhase := 1;
end;

class function TStructurePhase1AIPA.Priority: Integer;
begin
  Result := 21;
end;

{ TStructurePhase2AIPA (instance size 28): inherited $14 FPhase. }
constructor TStructurePhase2AIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPhase := 2;
end;

class function TStructurePhase2AIPA.Priority: Integer;
begin
  Result := 15;
end;

{ TFire (instance size 44): $1C mode, $1D lifetime, $1E age,
  $20 priority, $24 owner player, $28 explosion frame. }
constructor TFire.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTurnsLeft := 3;
  FAge := 0;
  FPlayer := 0;
  FShowPriority := $68000000;
  FMode := [fmExpandable];
  FExplosionFrame := 0;
end;

class function TFire.ClassID: Integer;
begin
  Result := $2077E;
end;

procedure TFire.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FTurnsLeft, 5);
  Stream.rwData(FMode, 1, 6);
  Stream.rwByte(Byte(FPlayer), 7);
  Stream.rwByte(FAge, 8);
end;

function TFire.GetTerrain(Index: Integer): ShortInt;
begin
  Result := FResource.TerrainList.GetTerrain(Index);
  if Result >= 0 then Result := -1;
end;

function TFire.GetShowPriority: Integer;
begin
  Result := FShowPriority;
end;

procedure TFire.CalcShowPriority(MapField: TMapField);
var
  X, Y: Integer;
  HS: THexagonSprite;
begin
  HXtoHP(MapField.Xhx, MapField.Yhx, X, Y);
  HS := MapField.GetMaxLevelNoneTransparentHS;
  FShowPriority := $68000000 + (Y + 36) shl 13 + (X + 16);
  if (HS <> Self) and (HS <> nil) then
    if HS.GetShowPriority >= FShowPriority then
      FShowPriority := HS.GetShowPriority + 1;
end;

function TFire.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  CalcShowPriority(MapContainer.GetField(Xhx, Yhx, Lhx));
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
end;

function TFire.GetMostFrequentMapFieldTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx, Default: Shortint): Shortint;
var
  Terrains: TTerrainList;
  Counts: array[0..127] of Byte;
  Walk: THNWalkData;
  TerrainType: Shortint;
begin
  Result := Default;
  Terrains := FResource.TerrainList;
  if Result < 0 then Result := 0;
  FillChar(Counts, SizeOf(Counts), 0);
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Walk.HN < Terrains.Count do
  begin
    if (FResource.TerrainList.GetTerrain(Walk.HN) >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
    begin
      TerrainType := MapLevel.GetField(Walk.X, Walk.Y).TerrainType;
      if TerrainType >= 0 then
      begin
        Inc(Counts[TerrainType]);
        if Counts[TerrainType] > Counts[Result] then Result := TerrainType;
      end;
    end;
    WalkToNextHN(Walk);
  end;
  if Default >= 0 then
    if Counts[Result] = Counts[Default] then Result := Default;
end;

procedure TFire.Connect;
begin
  CalcShowPriority(TMapField(Owner));
  inherited Connect;
end;

function TFire.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then TMapField(Owner).UpdateMapField;
end;

procedure TFire.RemoveFromMap;
var
  MapField: TMapField;
begin
  MapField := TMapField(Owner);
  if MapField <> nil then
    with MapField do
    begin
      inherited RemoveFromMap;
      UpdateMapField;
    end;
end;

function TFire.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  Result := inherited CanPlace(MapContainer, Xhx, Yhx, Lhx);
  if Result then Result := MapContainer.GetField(Xhx, Yhx, Lhx).FindOwnedChild(ClassID) = nil;
end;

procedure TFire.SetupExplosion(Delay: Integer);
begin
  if FResource.ImageSequenceList.GetImageSequence(20) <> nil then
    FExplosionFrame := Delay + AoWHSMap.Frame;
end;

procedure TFire.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  if not (moVisible in FStatus) and (FExplosionFrame <> 0) and
    (AoWHSMap.Frame = FExplosionFrame) then
    PlaySample(ExplosionSFX[(GetXhx + AoWHSMap.Frame) mod 2]);
  inherited MakeVisible(VisibilityList);
end;

procedure TFire.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Frame, X, Y: Integer;
begin
  if FExplosionFrame <> 0 then
  begin
    Frame := AoWHSMap.Frame - FExplosionFrame;
    if (Frame >= 0) and
      (Frame < FResource.ImageSequenceList.GetImageSequence(20).GetTotalSequenceFrames) then
    begin
      HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
      FResource.ImageSequenceList.Show(20, X - XhpSurf, Y - YhpSurf, Frame, SurfaceDesc);
    end
    else if (Frame < -1000) or (Frame >= 0) then
    begin
      FExplosionFrame := 0;
      inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
    end;
  end
  else inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

procedure TFire.TriggerDamage;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1105;
  Msg.Param[0] := Integer(Self);
  Msg.Result := 0;
  TMapField(Owner).SendMapFieldMsg(Msg);
end;

function TFire.CanDoDamage(Units: TUnitList): Boolean;
var
  I: Integer;
  AUnit: TAbstractUnit;
begin
  Result := False;
  I := Units.GetCount;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    AUnit := Units.GetUnit(I);
    Result := not (dtFire in AUnit.GetImmunityTypes);
  end;
end;

procedure TFire.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $2000;
end;

function TFire.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
  begin
    if not CanDoDamage(TMoveControl(Info.Sender).FSettings.FUnits) then Result := 1
    else
    begin
      Result := 0;
      Exit;
    end;
  end
  else Result := 1;
end;

procedure TFire.ArmyPlaced(ArmyHS: TArmyHS);
begin
  if not (msEditting in AoWHSMap.Status) then ArmyHS.FArmy.TriggerFireDamage;
end;

procedure TFire.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if (Msg.MsgID <> $10) or (msEditting in AoWHSMap.Status) then inherited MapFieldMsgProc(Msg);
  if (Msg.MsgID = $1142) and (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) then
  begin
    ArmyPlaced(TArmyHS(Msg.Param[0]));
    Exit;
  end;
  if (Msg.MsgID = $1120) and (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) then
    if not (dtFire in TArmyHS(Msg.Param[0]).FArmy.ImmunityTypes($FF)) then Msg.Result := 1;
end;

procedure TFire.NewTurn;
begin
  if FAge < 99 then Inc(FAge);
end;

procedure TFire.NewTurnDone;
var
  Walk: THNWalkData;
  MapLevel: TMapLevel;
  Chance: Integer;
  Fire: TFire;
begin
  if FAge > 0 then
  begin
    MapLevel := TMapLevel(TMapField(Owner).Owner);
    InitHNWalk(Walk, GetXhx, GetYhx, 1);
    while Walk.Radius = 1 do
    begin
      { Original excludes the top row when spreading fire. }
      if (Walk.X >= 0) and (Walk.X < MapLevel.Width) and
        (Walk.Y > 0) and (Walk.Y < MapLevel.Height) then
      begin
        Chance := IgnitionChance(TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y)));
        if Chance > AoWHSMap.Random(1000) then
        begin
          RandSeed := AoWHSMap.Random($FFFFFF);
          Fire := AoWHSSet.FFireControl.PlaceFire(Walk.X, Walk.Y, GetLhx, ftLarge);
          if Fire <> nil then
          begin
            Fire.FPlayer := FPlayer;
            Fire.FTurnsLeft := 3;
          end;
        end;
      end;
      WalkToNextHN(Walk);
    end;
  end;
  if FTurnsLeft <> 0 then
  begin
    Dec(FTurnsLeft);
    if FTurnsLeft <> 0 then TriggerDamage else Destroy;
  end
  else TriggerDamage;
end;

procedure TFire.WaterMasteryCast;
begin
  if FTurnsLeft <> 0 then Destroy;
end;

procedure TFire.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayer) then
  begin
    NewTurn;
    Exit;
  end;
  if (Msg.MsgID = $20020003) and (Msg.Value = FPlayer) then NewTurnDone
  else if (Msg.MsgID = $20020102) and (Byte(Msg.Param[1]) = 6) then WaterMasteryCast;
end;

{ TFireResource (instance size 72): $44 FFireType. }
destructor TFireResource.Destroy;
begin
  if (FEngine <> nil) and not (ssDestroying in AoWHSSet.Status) then
    AoWHSSet.FFireControl.UnregisterFireResource(Self);
  inherited Destroy;
end;

resourcestring
    FireRStr = 'Fire';

class function TFireResource.ResourceEditName: string;
begin
  Result := TranslateRStr(FireRStr);
end;

class function TFireResource.ClassID: Integer;
begin
  Result := $2077F;
end;

function TFireResource.ResourceUserClassID: Integer;
begin
  Result := $2077E;
end;

procedure TFireResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FFireType, 1, 20);
end;

procedure TFireResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then AoWHSSet.FFireControl.RegisterFireResource(Self);
end;

{ TFireControl (instance size 8): $04 FResources. }
constructor TFireControl.Create;
begin
  inherited Create;
  FResources := TList.Create;
end;

destructor TFireControl.Destroy;
begin
  FResources.Free;
  inherited Destroy;
end;

function TFireControl.GetRndFireResource(FireType: TFireType): TFireResource;
var
  I: Integer;
  Resources: TList;
begin
  Resources := TList.Create;
  for I := 0 to FResources.Count - 1 do
    if TFireResource(FResources.List^[I]).FFireType = FireType then
      Resources.Add(FResources.List^[I]);
  if Resources.Count <> 0 then
    Result := TFireResource(Resources.List^[System.Random(Resources.Count)])
  else Result := nil;
  Resources.Free;
end;

function TFireControl.PlaceFire(X, Y, L: Integer; FireType: TFireType): TFire;
var
  Resource: TFireResource;
  Fire: TFire;
begin
  Resource := GetRndFireResource(FireType);
  if Resource <> nil then
  begin
    Fire := TFire(Resource.CreateResourceUser);
    Fire.FPlayer := AoWHSMap.FCurrentPlayer;
    if not AoWHSMap.PlaceHX(Fire, X, Y, L) then
    begin
      Fire.Free;
      Result := nil;
    end
    else
    begin
      Result := Fire;
      Fire.TriggerDamage;
    end;
  end
  else Result := nil;
end;

procedure TFireControl.RegisterFireResource(Resource: TFireResource);
begin
  FResources.Add(Resource);
end;

procedure TFireControl.UnregisterFireResource(Resource: TFireResource);
begin
  FResources.Remove(Resource);
end;

{ TTargetSelectionControl (instance size 92): $04 images, $08 HNs,
  $0C status, $0D mode, $10/$18 callbacks, $20 range, $24..$2C source
  coordinates, $30 source, $34 change events, $38 change, $39..$3B target,
  $3C text, $40 title, $44 cancel text, $50/$54/$58 images. }
constructor TTargetSelectionControl.Create;
begin
  inherited Create;
  FOnChange := TEventList.Create;
  FHNs := TShortIntList.Create;
  FText := TStringList.Create;
end;

destructor TTargetSelectionControl.Destroy;
begin
  FText.Free;
  FOnChange.Free;
  FOnChange := nil;
  FHNs.Free;
  FHNs := nil;
  if FImageLibrary <> nil then
  begin
    { Original links the image library again when destroying the control. }
    AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'TARGHEX.ILB');
    FImageLibrary := nil;
  end;
  inherited Destroy;
end;

procedure TTargetSelectionControl.TriggerOnChangeEvent(Change: TTargetSelectionChange);
begin
  FChange := Change;
  FOnChange.TriggerNotifyEvents(Self);
  FChange := tscNone;
end;

procedure TTargetSelectionControl.DeselectHS(Sender: TObject);
begin
  if tsActivated in FStatus then Deactivate;
end;

procedure TTargetSelectionControl.MouseDownEvent(Sender: TObject);
var
  Mouse: THSMapMouse;
begin
  if tsActivated in FStatus then
  begin
    if (AoWHSMap.Mouse.Capture <> Self) or (AoWHSMap.Mouse.Button = mbRight) then
    begin
      Deactivate;
      AoWHSMap.FSelectedArmy.FIgnoreMouseDown := True;
    end
    else
    begin
      Mouse := AoWHSMap.Mouse;
      if (Mouse.Capture = Self) and (Mouse.Button = mbLeft) then
      if ValidTarget(FTargetX, FTargetY, FTargetL) then
      begin
        TriggerOnChangeEvent(tscSelected);
        if not (tsActivated in FStatus) then AoWHSMap.FSelectedArmy.FIgnoreMouseDown := True;
      end;
    end;
  end;
end;

function TTargetSelectionControl.ValidTarget(X, Y, L: Shortint): Boolean;
var
  MapField: TMapField;
begin
  if (X <> -1) and (Y <> -1) then
  begin
    if tmValidateDistance in FTargetMode then
      Result := dHXtoRad(FSourceX, FSourceY, X, Y) <= FRange
    else Result := True;
    if tmFixedLevel in FTargetMode then Result := Result and (L = FSourceL);
    MapField := AoWHSMap.MapContainer.GetField(X, Y, L);
    Result := Result and (Smallint(MapField.TerrainType) <> 15);
    if Result and Assigned(FOnValidateTarget) then FOnValidateTarget(Self, X, Y, L, Result);
  end
  else Result := False;
end;

procedure TTargetSelectionControl.NewFrameEvent(Sender: TObject);
begin
  if tsActivated in FStatus then
    if tsVisible in FStatus then
    begin
      AoWHSMap.Mouse.SetCursor(110 + (AoWHSMap.Frame shr 2) mod 10);
      AoWHSMap.Mouse.CursorVisible := True;
    end
    else
    begin
      AoWHSMap.Mouse.SetCursor(120);
      AoWHSMap.Mouse.CursorVisible := False;
    end;
end;

procedure TTargetSelectionControl.MouseMoveEvent(Sender: TObject);
begin
  if tsActivated in FStatus then
  begin
    FTargetX := AoWHSMap.Mouse.GetXhx;
    FTargetY := AoWHSMap.Mouse.GetYhx;
    FTargetL := AoWHSMap.ViewL;
    if (AoWHSMap.Mouse.GetXhx <> -1) and (AoWHSMap.Mouse.GetYhx <> -1) and
      ValidTarget(AoWHSMap.Mouse.GetXhx, AoWHSMap.Mouse.GetYhx, AoWHSMap.ViewL) then
      FStatus := FStatus + [tsVisible]
    else FStatus := FStatus - [tsVisible];
  end;
end;

procedure TTargetSelectionControl.ShowSelection(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  I, DX, DY, X, Y, XS, YS: Integer;
begin
  if (tsActivated in FStatus) and (FTargetX <> -1) and (tsVisible in FStatus) then
  begin
    HXtoHP(FTargetX, FTargetY, X, Y);
    Dec(X, XhpSurf);
    Dec(Y, YhpSurf);
    for I := 0 to FHNs.Count - 1 do
      if FHNs[I] >= 0 then
      begin
        HNtoHP(I, DX, DY);
        XS := X + DX;
        YS := Y + DY;
        if tmOwnerDraw in FTargetMode then
        begin
          if Assigned(FOnShow) then FOnShow(Self, I, XS, YS, SurfaceDesc);
        end
        else FImageLibrary.Get(FHNs[I]).Show(XS - 8, YS, SurfaceDesc);
      end;
  end;
end;

procedure TTargetSelectionControl.Initialize(A1: TObject);
begin
  if FImageLibrary = nil then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'TARGHEX.ILB');
  if not (tsActivated in FStatus) then
  begin
    FHNs.Clear;
    FSource := A1;
    FTargetMode := [tmFixedLevel];
  end
  else raise Exception.Create('please deactivate before initializing (TTargetSelectionControl)');
end;

procedure TTargetSelectionControl.Activate;
begin
  if not (tsActivated in FStatus) then
  begin
    FStatus := FStatus + [tsActivated];
    AoWHSMap.Mouse.SetCapture(Self);
    AoWHSMap.Mouse.OnDown.Add(MouseDownEvent);
    AoWHSMap.Mouse.OnMove.Add(MouseMoveEvent);
    AoWHSMap.NewFrameEvents.Add(NewFrameEvent);
    AoWHSMap.Selection.OnDeselect.Add(DeselectHS);
    AoWHSMap.Mouse.CursorMode := $100;
    AoWHSMap.FKeyboard.Lock;
    TriggerOnChangeEvent(tscActivated);
    MouseMoveEvent(Self);
  end
  else raise Exception.Create('Already activated');
end;

procedure TTargetSelectionControl.Deactivate;
var
  ArmyHS: TArmyHS;
begin
  if tsActivated in FStatus then
  begin
    FStatus := FStatus - [tsActivated];
    AoWHSMap.Mouse.OnDown.Remove(MouseDownEvent);
    AoWHSMap.Mouse.OnMove.Remove(MouseMoveEvent);
    AoWHSMap.NewFrameEvents.Remove(NewFrameEvent);
    AoWHSMap.Selection.OnDeselect.Remove(DeselectHS);
    if AoWHSMap.Mouse.Capture = Self then
      if AoWHSMap.FSelectedArmy.GetArmyHS <> nil then
      begin
        ArmyHS := AoWHSMap.FSelectedArmy.GetArmyHS;
        AoWHSMap.Mouse.SetCapture(nil);
        AoWHSMap.Selection.UnselectLocation;
        AoWHSMap.Selection.SelectLocationHS(ArmyHS);
      end
      else AoWHSMap.Mouse.SetCapture(nil);
    AoWHSMap.FKeyboard.Unlock;
    TriggerOnChangeEvent(tscDeactivated);
    FSource := nil;
    FOnShow := nil;
    FOnValidateTarget := nil;
  end;
end;

procedure TTargetSelectionControl.UnitChanged(AUnit: TAbstractUnit);
begin
  if (tsActivated in FStatus) and (FSource <> nil) and (AUnit = FSource) and
    (usKilled in AUnit.FUnitStatus) then Deactivate;
end;

{ TMovepath (instance size 20): inherited $04 locations and $08 count. }
function TMovepath.MovePointsToPos(MovePoints: Integer): Integer;
begin
  if MovePoints >= 0 then
  begin
    Result := Count;
    while (Result > 0) and (MovePoints >= 0) do
    begin
      Dec(Result);
      Dec(MovePoints, List^[Result].Flag);
    end;
    if MovePoints < 0 then Inc(Result);
  end
  else Result := Count - 1;
end;

function TMovepath.PosToMovePoints(Pos: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Count - 1 downto Pos do Inc(Result, List^[I].Flag);
end;

function TMovepath.GetMovePoints: Integer;
begin
  Result := PosToMovePoints(0);
end;

{ TMoveSettings (instance size 44): $08 path, $0C path cost, $10 object,
  $14 available points, $1C priority, $20 selection, $24 position, $28 valid. }
constructor TMoveSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPath := TMovepath.Create;
  FPriority := 1;
end;

destructor TMoveSettings.Destroy;
begin
  FPath.Free;
  inherited Destroy;
end;

function TMoveSettings.GetMoveLoc: TXYL;
begin
  if (FPath.Count > FMovePos) and (FMovePos >= 0) then
  begin
    Result := FPath.List^[FMovePos];
    Result.Flag := 0;
  end
  else Integer(Result) := $FFFFFF;
end;

function TMoveSettings.GetMovePrio: Integer;
begin
  Result := (FPath.Count - FMovePos) * FPriority;
end;

{ TMoveSettingsList (instance size 12): inherited $08 FChildren. }
function TMoveSettingsList.GetMoveSettings(Index: Integer): TMoveSettings;
begin
  Result := TMoveSettings(FChildren.List^[Index]);
end;

function TMoveSettingsList.GetNoneValidMove: Integer;
var
  I, MinPriority, Priority: Integer;
begin
  Result := -1;
  MinPriority := $FFFFFF;
  for I := GetCount - 1 downto 0 do
    with TMoveSettings(FChildren.List^[I]) do
      if not FValid then
      begin
        Priority := GetMovePrio;
        if Priority <= MinPriority then
        begin
          Result := I;
          MinPriority := Priority;
        end;
      end;
end;

function TMoveSettingsList.IndexOfMoveObject(MoveObject: TObject): Integer;
begin
  Result := GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    if MoveObject = TMoveSettings(FChildren.List^[Result]).FMoveObject then Exit;
  end;
  Result := -1;
end;

procedure TMoveSettingsList.CalculateMovePositions(Validate: TValidateMovePositionProc);
var
  I, Index: Integer;
  Settings: TMoveSettings;
begin
  for I := GetCount - 1 downto 0 do
  begin
    Settings := GetMoveSettings(I);
    Settings.FMovePos := Settings.FPath.MovePointsToPos(Settings.FMovePoints);
    Settings.FValid := (Settings.FPath.Count = 0) or (Settings.FMovePos = Settings.FPath.Count - 1);
  end;
  Index := GetNoneValidMove;
  while not (Index = -1) do
  begin
    if Validate(Self, Index) then
    begin
      GetMoveSettings(Index).FValid := True;
      for I := 0 to GetCount - 1 do
        if Index <> I then
          if Integer(GetMoveSettings(Index).GetMoveLoc) = Integer(GetMoveSettings(I).GetMoveLoc) then
            if GetMoveSettings(Index).GetMovePrio < GetMoveSettings(I).GetMovePrio then
              GetMoveSettings(I).FValid := False;
    end
    else
    begin
      Inc(GetMoveSettings(Index).FMovePos);
      GetMoveSettings(Index).FValid := GetMoveSettings(Index).FMovePos = GetMoveSettings(Index).FPath.Count - 1;
    end;
    Index := GetNoneValidMove;
  end;
end;

{ TMoveSelector (instance size 24): $04 control settings, $08 moves, $0C current move,
  $10 map, $14 status. }
constructor TMoveSelector.Create;
begin
  inherited Create;
  FMoveControlSettings := CreateMCS;
  FMoveSettingsList := TMoveSettingsList.Create(nil);
  FCurrentMove := -1;
  FMap := nil;
end;

destructor TMoveSelector.Destroy;
begin
  Clear;
  FMoveControlSettings.Release;
  FMoveSettingsList.Free;
  inherited Destroy;
end;

function TMoveSelector.CreateMCS: TMoveControlSettings;
begin
  Result := TMoveControlSettings.Create(nil);
end;

procedure TMoveSelector.Clear;
begin
  FMoveControlSettings.Clear;
  FMoveSettingsList.Clear;
  FCurrentMove := -1;
end;

procedure TMoveSelector.SetCurrentMove(A1: Integer);
begin
  FCurrentMove := A1;
end;

procedure TMoveSelector.Unselect;
begin
  Deactivate;
  Clear;
end;

function TMoveSelector.ValidateSelection(Field: TAoWMapField): Boolean;
begin
  Result := True;
end;

procedure TMoveSelector.ExecuteMove;
begin end;

function TMoveSelector.AddMoveObject(Obj: THexagonSprite): Integer;
var
  Settings: TMoveSettings;
begin
  Settings := TMoveSettings.Create(nil);
  Settings.FMoveObject := Obj;
  Settings.SetOwner(FMoveSettingsList);
  Result := FMoveSettingsList.Count - 1;
end;

procedure TMoveSelector.DeleteMoveObject(A1: Integer);
var
  Obj: TObject;
begin
  if FCurrentMove <> -1 then
    Obj := FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject
  else Obj := nil;
  TObject(FMoveSettingsList.FChildren.List^[A1]).Free;
  if Obj <> nil then
  begin
    A1 := FMoveSettingsList.IndexOfMoveObject(Obj);
    if A1 = -1 then SetCurrentMove(FMoveSettingsList.Count - 1)
    else SetCurrentMove(A1);
  end;
end;

procedure TMoveSelector.DeleteMoves;
begin
  while FMoveSettingsList.Count <> 0 do
    DeleteMoveObject(FMoveSettingsList.Count - 1);
end;

procedure TMoveSelector.UpdateMoveCursor;
begin end;

procedure TMoveSelector.MouseMoveEvent(Sender: TObject);
begin
  UpdateMoveCursor;
end;

procedure TMoveSelector.CalculateMovePath(Index: Integer; X, Y, L: Shortint);
begin end;

procedure TMoveSelector.SelectPath(X, Y, L: Shortint);
begin
  if (FCurrentMove <> -1) and (X <> -1) then
  begin
    with FMoveSettingsList.GetMoveSettings(FCurrentMove) do
    if (FPath.Count <> 0) and (FPath[0].X = X) and
      (FPath[0].Y = Y) and (FPath[0].L = L) then
      ExecuteMove
    else if ValidateSelection(TAoWMapField(FMap.MapContainer.GetField(X, Y, L))) then
      CalculateMovePath(FCurrentMove, X, Y, L)
    else FPath.Clear;
  end;
end;

procedure TMoveSelector.MouseDownEvent(Sender: TObject);
begin
  if ((FMap.Mouse.Capture <> Self) and
    (FMap.Mouse.Capture <> AoWHSMap.FTargetSelection)) or
    (FMap.Mouse.Button = mbRight) then Unselect
    else
      with FMap.Mouse do
        if (Capture = Self) and (Button = mbLeft) then
          SelectPath(Xhx, FMap.Mouse.Yhx, FMap.ViewL);
end;

procedure TMoveSelector.Activate(Map: TAoWHSMap);
begin
  if mssActivated in FStatus then Deactivate;
  FMap := Map;
  FMap.Mouse.SetCapture(Self);
  FMap.Mouse.OnDown.Add(MouseDownEvent);
  FMap.Mouse.OnMove.Add(MouseMoveEvent);
  FMap.Mouse.OnCaptureChanged.Add(MouseDownEvent);
  FMap.Mouse.CursorMode := $100;
  UpdateMoveCursor;
  FStatus := FStatus + [mssActivated];
  FMap.ShowHexagonSelector;
end;

procedure TMoveSelector.Deactivate;
begin
  if mssActivated in FStatus then
  begin
    FStatus := FStatus - [mssActivated];
    FMap.Mouse.OnDown.Remove(MouseDownEvent);
    FMap.Mouse.OnMove.Remove(MouseMoveEvent);
    FMap.Mouse.OnCaptureChanged.Remove(MouseDownEvent);
    if FMap.Mouse.Capture = Self then FMap.Mouse.SetCapture(nil);
    FMap.HideHexagonSelector;
    UpdateMoveCursor;
  end;
end;

procedure TMoveSelector.ShowMovePaths(const Surface: TSurfaceDesc);
var
  X1, Y1, X2, Y2, I, J, ImageIndex, MaxX, MaxY, Xhp, Yhp, PointsLeft, Direction: Integer;
  Settings: TMoveSettings;
  MapField: TMapField;
begin
  if (mssActivated in FStatus) and (FMoveSettingsList.Count <> 0) then
  begin
    with FMap do
    begin
      MaxX := ViewXhx + ViewWidthHX - 1;
      MaxY := ViewYhx + ViewHeightHX - 1;
    end;
    for I := 0 to FMoveSettingsList.Count - 1 do
    begin
      Settings := FMoveSettingsList.GetMoveSettings(I);
      PointsLeft := Settings.FPathMovePoints;
      if Settings.FPath.Count > 1 then
      begin
        for J := 0 to Settings.FPath.Count - 2 do
        begin
          if (Settings.FPath[J].X >= FMap.ViewXhx) and
            (Settings.FPath[J].X <= MaxX) and
            (Settings.FPath[J].Y >= FMap.ViewYhx) and
            (Settings.FPath[J].Y <= MaxY) and
            (Settings.FPath[J].L = FMap.ViewL) then
          begin
            X1 := Settings.FPath[J].X;
            Y1 := Settings.FPath[J].Y;
            X2 := Settings.FPath[J + 1].X;
            Y2 := Settings.FPath[J + 1].Y;
            if dHXtoRad(X1, Y1, X2, Y2) = 1 then
            begin
              Direction := dHXtoHNfast(X1, Y1, X2, Y2);
              if Direction <> 0 then
              begin
                if PointsLeft <= Settings.FMovePoints then ImageIndex := Direction + 34
                else ImageIndex := Direction + 41;
                HXtoHP(X1, Y1, Xhp, Yhp);
                if (FCurrentMove = I) or (FCurrentMove = -1) then
                  AoWHSSet.FCursorImages[ImageIndex].Show(Xhp - FMap.ViewXhp - 8,
                    Yhp - FMap.ViewYhp - 8, Surface)
                else
                  AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp - FMap.ViewXhp - 8,
                    Yhp - FMap.ViewYhp - 8, Surface);
              end;
            end
            else if FCurrentMove = I then
            begin
              if PointsLeft <= Settings.FMovePoints then ImageIndex := 41 else ImageIndex := 48;
              HXtoHP(X1, Y1, Xhp, Yhp);
              AoWHSSet.FCursorImages[ImageIndex].Show(Xhp - FMap.ViewXhp - 8,
                Yhp - FMap.ViewYhp - 8, Surface);
              if (PointsLeft - Settings.FPath[J].Flag <> 0) and
                (Settings.FPath[J + 1].L = FMap.ViewL) then
              begin
                if PointsLeft - Settings.FPath[J].Flag <= Settings.FMovePoints then
                  ImageIndex := 41 else ImageIndex := 48;
                HXtoHP(X2, Y2, Xhp, Yhp);
                AoWHSSet.FCursorImages[ImageIndex].Show(Xhp - FMap.ViewXhp - 8,
                  Yhp - FMap.ViewYhp - 8, Surface);
              end;
            end
            else
            begin
              if PointsLeft <= Settings.FMovePoints then ImageIndex := 41 else ImageIndex := 48;
              HXtoHP(X1, Y1, Xhp, Yhp);
              AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp - FMap.ViewXhp - 8,
                Yhp - FMap.ViewYhp - 8, Surface);
              if PointsLeft - Settings.FPath[J].Flag <= Settings.FMovePoints then
                ImageIndex := 41 else ImageIndex := 48;
              HXtoHP(X2, Y2, Xhp, Yhp);
              AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp - FMap.ViewXhp - 8,
                Yhp - FMap.ViewYhp - 8, Surface);
            end;
          end;
          Dec(PointsLeft, Settings.FPath[J].Flag);
        end;
        if (Settings.FPath[0].X >= FMap.ViewXhx) and
          (Settings.FPath[0].X <= MaxX) and
          (Settings.FPath[0].Y >= FMap.ViewYhx) and
          (Settings.FPath[0].Y <= MaxY) and
          (Settings.FPath[0].L = FMap.ViewL) then
        begin
          MapField := FMap.MapContainer.GetField(Settings.FPath[0].X,
            Settings.FPath[0].Y, Settings.FPath[0].L);
          HXtoHP(MapField.Xhx, MapField.Yhx, Xhp, Yhp);
          Xhp := Xhp - FMap.ViewXhp - 8;
          Yhp := Yhp - FMap.ViewYhp - 8;
          if Settings.FMovePoints < Settings.FPathMovePoints then
          begin
            ImageIndex := 48;
            AoWHSSet.FCursorImages[ImageIndex].Show(Xhp, Yhp, Surface);
            { Original sets the font color before checking the font for nil. }
            AoWEngine.FCombatFont.Color := 0;
            if AoWEngine.FCombatFont <> nil then
              AoWEngine.FCombatFont.SetTextCentered(Xhp + 25, Yhp + 9,
                IntToStr((Settings.FPathMovePoints - Settings.FMovePoints - 1) div Settings.FMoves + 1),
                Surface);
          end
          else
          begin
            ImageIndex := 41;
            if (FCurrentMove = I) or (FCurrentMove = -1) then
              AoWHSSet.FCursorImages[ImageIndex].Show(Xhp, Yhp, Surface)
            else AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp, Yhp, Surface);
          end;
        end;
        if Settings.FMovePoints < Settings.FPathMovePoints then
        begin
          J := Settings.FPath.MovePointsToPos(Settings.FMovePoints);
          if (J > 0) and (J < Settings.FPath.Count - 1) and
            (Settings.FPath[J].X >= FMap.ViewXhx) and
            (Settings.FPath[J].X <= MaxX) and
            (Settings.FPath[J].Y >= FMap.ViewYhx) and
            (Settings.FPath[J].Y <= MaxY) and
            (Settings.FPath[J].L = FMap.ViewL) then
          begin
            HXtoHP(Settings.FPath[J].X, Settings.FPath[J].Y, Xhp, Yhp);
            Xhp := Xhp - FMap.ViewXhp - 8;
            Yhp := Yhp - FMap.ViewYhp - 8;
            ImageIndex := 41;
            if (FCurrentMove = I) or (FCurrentMove = -1) then
              AoWHSSet.FCursorImages[ImageIndex].Show(Xhp, Yhp, Surface)
            else AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp, Yhp, Surface);
          end;
        end;
      end
      else if (Settings.FPath.Count = 1) and (AoWHSMap.FCombat <> nil) then
      begin
        MapField := FMap.MapContainer.GetField(Settings.FPath[0].X,
          Settings.FPath[0].Y, Settings.FPath[0].L);
        HXtoHP(MapField.Xhx, MapField.Yhx, Xhp, Yhp);
        Xhp := Xhp - FMap.ViewXhp - 8;
        Yhp := Yhp - FMap.ViewYhp - 8;
        AoWHSSet.FCursorImages[41].Show(Xhp, Yhp, Surface);
      end;
    end;
  end;
end;

constructor TTextControlItem.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FText := TStringList.Create;
end;

destructor TTextControlItem.Destroy;
begin
  FText.Free;
  inherited Destroy;
end;

class function TTextControlItem.ClassID: Integer;
begin
  Result := $2029A;
end;

procedure TTextControlItem.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FID, 9);
  Stream.rwStrings(FText, 10);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FName, 11);
end;

function TTextControl.GetItem(Index: Integer): TTextControlItem;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TTextControlItem(FChildren.List^[Index])
  else Result := nil;
end;

procedure TTextControl.Delete(Index: Integer);
begin
  if GetItem(Index) <> nil then GetItem(Index).Free;
end;

function TTextControl.New: TTextControlItem;
begin
  Result := TTextControlItem.Create(Self);
end;

function TTextControl.FindID(ID: Integer): TTextControlItem;
var
  I: Integer;
begin
  I := Count;
  Result := nil;
  while (Result = nil) and (I <> 0) do
  begin
    Dec(I);
    if TTextControlItem(FChildren.List^[I]).FID = ID then
      Result := TTextControlItem(FChildren.List^[I]);
  end;
end;

function CompareTextControlItems(Item1, Item2: Pointer): Integer;
begin
  Result := TTextControlItem(Item1).FID - TTextControlItem(Item2).FID;
  if Result = 0 then
    Result := TTextControlItem(Item1).FText.Count - TTextControlItem(Item2).FText.Count;
  if Result = 0 then Result := Integer(Item1) - Integer(Item2);
end;

procedure TTextControl.Sort;
begin
  FChildren.Sort(CompareTextControlItems);
end;

function TTextControl.IndexOf(Item: TTextControlItem): Integer;
begin
  Result := FindChildIndex(Item);
end;

procedure TTextControl.RetrieveText(ID: Integer; Text: TStrings);
var
  Item: TTextControlItem;
begin
  Text.Clear;
  Item := FindID(ID);
  if Item <> nil then Text.Text := Item.FText.Text;
end;

class function TFrozenWaterHS.ClassID: Integer;
begin
  Result := $2016C;
end;

function TFrozenWaterHS.GetLevel: Byte;
begin
  Result := $1C;
end;

procedure TFrozenWaterHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwShortint(FDaysRemaining, $1E);
  Stream.rwShortint(FCasterPlayer, $1F);
end;

procedure TFrozenWaterHS.MeltIce;
begin
  if TMapField(Owner).TerrainType = 6 then
    AoWHSMap.ChangeTerrain(Self, Xhx, Yhx, Lhx, 0, 0)
  else if TMapField(Owner).TerrainType = 13 then
    AoWHSMap.ChangeTerrain(Self, Xhx, Yhx, Lhx, 0, 10)
  else Destroy;
end;

procedure TFrozenWaterHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  inherited TerrainChanged(Info);
  if (Info.HN = 0) and not (Info.TerrainType in [6, 13]) then Destroy;
end;

procedure TFrozenWaterHS.NewTurn(Player: Shortint);
begin
  if Player = FCasterPlayer then
  begin
    Dec(FDaysRemaining);
    if FDaysRemaining <= 0 then MeltIce;
  end;
end;

procedure TFrozenWaterHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then NewTurn(Msg.Value);
end;

procedure TFrozenWaterHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X, Y: Integer;
begin
  HXtoHP(Xhx, Yhx, X, Y);
  X := X - XhpSurf + 16;
  Y := Y - YhpSurf + 16;
  AoWHSSet.FImageSequences.ShowLoopedEx(70, X, Y, AoWHSMap.Frame,
    Xhx + Yhx + Yhx * 2, SurfaceDesc);
end;

constructor TTutorialControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FShownMessages := TIntegerList.Create;
end;

destructor TTutorialControl.Destroy;
begin
  FShownMessages.Free;
  inherited Destroy;
end;

procedure TTutorialControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc($14, FShownMessages.LoadFromStream, FShownMessages.SaveToStream);
end;

procedure TTutorialControl.ShowMessage(ID: Integer; Immediate, OnceOnly: Boolean);
var
  Log: TTutorialMessageEventLog;
begin
  if (AoWHSMap.FGameType = gtTutorial) and (AoWHSMap.FTextControl.FindID(ID) <> nil) then
  begin
    if OnceOnly and (FShownMessages.IndexOf(ID) <> -1) then Exit;
    Log := TTutorialMessageEventLog.Create(nil);
    Log.FMessage.Assign(AoWHSMap.FTextControl.FindID(ID).FText);
    AoWHSMap.TriggerExecuteEventLog(Log, Immediate, nil);
    Log.Release;
    FShownMessages.Add(ID);
  end;
end;

class function TAoWMapField.ClassID: Integer;
begin
  Result := $20012;
end;

function TAoWMapField.GetExplored(Player: Integer): Boolean;
asm
  STC
  MOV ECX, EDX
  MOV EDX, [EAX].FFieldFlags
  RCR EDX, CL
  JC @@Explored
  XOR AL, AL
  RET
@@Explored:
  MOV AL, 1
end;

procedure TAoWMapField.SetExplored(Player: Integer; Value: Boolean);
asm
  { Original tests the entire ECX register for a Boolean passed in CL. }
  TEST ECX, ECX
  JZ @@Clear
  LEA ECX, [EDX-1]
  MOV EDX, 1
  SHL EDX, CL
  OR [EAX].FFieldFlags, EDX
  RET
@@Clear:
  LEA ECX, [EDX-1]
  MOV EDX, 1
  SHL EDX, CL
  NOT EDX
  AND [EAX].FFieldFlags, EDX
end;

procedure TAoWMapField.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwWord(LongRec(FFieldFlags).Lo, 4);
end;

procedure TAoWMapField.FogChanged;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1106;
  SendMapFieldMsg(Msg);
end;

procedure TAoWMapField.SetFogCount(Value: Byte);
begin
  if ((Value = 0) and (WordRec(LongRec(FFieldFlags).Hi).Lo <> 0)) or
    ((Value <> 0) and (WordRec(LongRec(FFieldFlags).Hi).Lo = 0)) then
  begin
    WordRec(LongRec(FFieldFlags).Hi).Lo := Value;
    FogChanged;
  end
  else WordRec(LongRec(FFieldFlags).Hi).Lo := Value;
end;

procedure TAoWMapField.UpdateMapField;
begin
  FFieldFlags := FFieldFlags and $FFFF1FFF;
  inherited UpdateMapField;
end;

function TAoWMapField.GetPlayer: Shortint;
var
  Msg: TMapFieldMsg;
begin
  if FFieldFlags and $02000000 <> 0 then
  begin
    Msg.MsgID := $1100;
    Msg.Result := -1;
    SendMapFieldMsg(Msg);
    Result := Msg.Result;
  end
  else Result := -1;
end;

function TAoWMapField.GetScannerIcon: Integer;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $110C;
  Msg.Param[0] := 0;
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Param[0];
end;

function TAoWMapField.GetCombatTerrainTag: Integer;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1122;
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Result;
end;

function TAoWMapField.GetConcealmentActive: Boolean;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1128;
  Msg.Result := 0;
  Msg.Param[0] := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Param[0] <> 0;
end;

function TAoWMapField.GetMagicShieldActive: Boolean;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1129;
  Msg.Result := 0;
  Msg.Param[0] := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Param[0] <> 0;
end;

function TAoWMapField.GetProductionControl: TProductionControl;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1201;
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := TProductionControl(Msg.Result);
end;

function TAoWMapField.GetAITarget(Control: TAIGroupControl; const Info: TAITargetInfo; var Data: TAITargetData): Boolean;
var
  Msg: TMapFieldMsg;
begin
  FillChar(Data, SizeOf(Data), 0);
  Data.TargetType := Low(TAITargetType);
  Msg.MsgID := $1200;
  Msg.Param[0] := Integer(@Info);
  Msg.Param[1] := Integer(@Data);
  Msg.Param[2] := Integer(Control);
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := Data.Priority <> 0;
end;

function TAoWMapField.GetMoveAction(Player: Shortint): TMoveAction;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1101;
  Msg.Param[0] := Player;
  Msg.Param[1] := 0;
  SendMapFieldMsg(Msg);
  Result := TMoveAction(Msg.Param[1]);
end;

function TAoWMapField.GetIndependentRelation: Byte;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1125;
  Msg.Result := -1;
  SendMapFieldMsg(Msg);
  Result := Msg.Result;
end;

function TAoWMapField.GetDefensePriority: Byte;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1126;
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Result;
end;

procedure TAoWMapField.GetDefenseRequirements(Player: Shortint; var Requirements: TDefenseRequirements);
var
  Msg: TMapFieldMsg;
begin
  FillChar(Requirements, SizeOf(Requirements), 0);
  Msg.MsgID := $1127;
  Msg.Param[0] := Player;
  Msg.Param[1] := Integer(@Requirements);
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
end;

function TAoWMapField.GetWallType: TWallType;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1123;
  Msg.Param[0] := Integer(Self);
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := TWallType(Msg.Result);
end;

function TAoWMapField.GetArmyHS: TArmyHS;
begin
  Result := TArmyHS(FindOwnedChild($20217));
end;

procedure TAoWMapField.RestoreTerrain;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1132;
  Msg.Param[0] := Integer(Self);
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
end;

class function TAoWMapLevel.ClassID: Integer;
begin
  Result := $20013;
end;

function TAoWMapLevel.MapFieldClass: Engine.TEObjectClass;
begin
  Result := TAoWMapField;
end;

function TAoWMapLevel.FogArea(X, Y, Radius: Integer): Boolean;
var
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  Result := False;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < FWidth) and (Walk.Y < FHeight) then
    begin
      Field := TAoWMapField(FXOffsets^[Walk.X] + FYOffsets^[Walk.Y]);
      if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 1 then Result := True;
      Field.SetFogCount(WordRec(LongRec(Field.FFieldFlags).Hi).Lo - 1);
    end;
    WalkToNextHN(Walk);
  end;
end;

function TAoWMapLevel.UnFogArea(X, Y, Radius: Integer): Boolean;
var
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  Result := False;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < FWidth) and (Walk.Y < FHeight) then
    begin
      Field := TAoWMapField(FXOffsets^[Walk.X] + FYOffsets^[Walk.Y]);
      if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 0 then Result := True;
      Field.SetFogCount(WordRec(LongRec(Field.FFieldFlags).Hi).Lo + 1);
    end;
    WalkToNextHN(Walk);
  end;
end;

function TAoWMapLevel.UnFogExploreArea(X, Y: Integer; Player: Shortint; Radius: Integer): TFogExplorationChanged;
var
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  Assert(Player >= 0, 'Invalid Player Index');
  Result := [];
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < FWidth) and (Walk.Y < FHeight) then
    begin
      Field := TAoWMapField(FXOffsets^[Walk.X] + FYOffsets^[Walk.Y]);
      if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 0 then Result := Result + [feFog];
      Field.SetFogCount(WordRec(LongRec(Field.FFieldFlags).Hi).Lo + 1);
      if not Field.GetExplored(Player) then
      begin
        Result := Result + [feExploration];
        Field.SetExplored(Player, True);
        if TAbstractAoWHSMap(FMap).FExplorationEnabled and
          (TAbstractAoWHSMap(FMap).FSeatedPlayer = Player) then
          FMap.InvalidateStaticScene(Walk.X, Walk.Y, FLhx);
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TAoWMapLevel.ExploreArea(X, Y: Integer; Player: Shortint; Radius: Integer): Boolean;
var
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  Result := False;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < FWidth) and (Walk.Y < FHeight) then
    begin
      Field := TAoWMapField(FXOffsets^[Walk.X] + FYOffsets^[Walk.Y]);
      if not Field.GetExplored(Player) then
      begin
        Field.SetExplored(Player, True);
        if TAbstractAoWHSMap(FMap).FExplorationEnabled and
          (TAbstractAoWHSMap(FMap).FSeatedPlayer = Player) then
          FMap.InvalidateStaticScene(Walk.X, Walk.Y, FLhx);
        Result := True;
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure TAoWMapLevel.ResetFog;
var
  I, N: Integer;
  Field: TAoWMapField;
begin
  N := Count - 1;
  Field := FFields;
  for I := 0 to N do
  begin
    Field.SetFogCount(0);
    Field := Pointer(Integer(Field) + FFieldSize);
  end;
end;

procedure TAoWMapLevel.ResetUnFog;
var
  I, N: Integer;
  Field: TAoWMapField;
begin
  N := Count - 1;
  Field := FFields;
  for I := 0 to N do
  begin
    Field.SetFogCount(1);
    Field := Pointer(Integer(Field) + FFieldSize);
  end;
end;

procedure TAoWMapLevel.Reset;
var
  I, N: Integer;
  Field: TAoWMapField;
begin
  N := Count - 1;
  Field := FFields;
  for I := 0 to N do
  begin
    Field.FFieldFlags := 0;
    Field := Pointer(Integer(Field) + FFieldSize);
  end;
end;

constructor TAbstractAoWHSMap.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FShowMessageEvents := TEventList.Create;
  FMapChangedEvents := TEventList.Create;
  FScannerIconsChangedEvents := TEventList.Create;
  FBackHexagonSelector := TCustomFixedVisibleHS.Create(nil);
  FBackHexagonSelector.OnShow := ShowBackHexagonSelector;
  FFrontHexagonSelector := TCustomFixedVisibleHS.Create(nil);
  FFrontHexagonSelector.OnShow := ShowFrontHexagonSelector;
  FHexagonSelectorVisible := False;
  FExplorationEnabled := True;
  FFogEnabled := 1;
  FSeatedPlayer := 1;
  FFPS := 30;
end;

destructor TAbstractAoWHSMap.Destroy;
begin
  FShowMessageEvents.Clear;
  FMapChangedEvents.Clear;
  HideHexagonSelector;
  FBackHexagonSelector.Free;
  FFrontHexagonSelector.Free;
  FScannerIconsChangedEvents.Free;
  inherited Destroy;
  FShowMessageEvents.Free;
  FMapChangedEvents.Free;
end;

function TAbstractAoWHSMap.CreateMouse: HSEngine.THSMapMouse;
begin
  Result := TAbstractAoWHSMapMouse.Create;
end;

procedure TAbstractAoWHSMap.SetFogEnabled(Value: Byte);
begin
  if Value <> FFogEnabled then
  begin
    FFogEnabled := Value;
    InvalidateMap;
  end;
end;

procedure TAbstractAoWHSMap.SetExplorationEnabled(Value: Boolean);
begin
  if Value <> FExplorationEnabled then
  begin
    FExplorationEnabled := Value;
    StaticSceneInvalid := True;
    InvalidateMap;
  end;
end;

procedure TAbstractAoWHSMap.PlayCenterAnimation(X, Y, L: Shortint);
var
  Animation: TImageSequenceAnimation;
begin
  Animation := TImageSequenceAnimation.Create(nil);
  Animation.SetImageSequence(AoWHSSet.FImageSequences.GetImageSequence(11));
  PlaceHX(Animation, X, Y, L);
  PlaySample('SFX\INT\CENTER.WAV');
end;

procedure TAbstractAoWHSMap.LockMapChangedEvent;
begin
  Inc(FMapChangedLockCount);
end;

procedure TAbstractAoWHSMap.UnlockMapChangedEvent;
begin
  Assert(FMapChangedLockCount <> 0, 'Invalid MapChanged Lock usage');
  Dec(FMapChangedLockCount);
end;

procedure TAbstractAoWHSMap.TriggerTerrainChangedEvent(const R: Windows.TRect; L: Shortint);
begin
  inherited TriggerTerrainChangedEvent(R, L);
  if FMapChangedLockCount = 0 then TriggerMapChangedEvent(R, L);
end;

procedure TAbstractAoWHSMap.MapChanged(const R: TRect; L: Integer);
begin
  if (FMapChangedLockCount = 0) and (msActivated in Status) then
    TriggerTerrainChangedEvent(R, L);
end;

procedure TAbstractAoWHSMap.MapChangedRad(X, Y, L, Radius: Integer);
var
  R: TRect;
  Level: TMapLevel;
begin
  Level := MapContainer.GetMapLevel(L);
  R.Left := X - Radius;
  if R.Left < 0 then R.Left := 0;
  R.Right := X + Radius + 1;
  if R.Right > Level.Width then R.Right := Level.Width;
  R.Top := Y - Radius;
  if R.Top < 0 then R.Top := 0;
  R.Bottom := Y + Radius + 1;
  if R.Bottom > Level.Height then R.Bottom := Level.Height;
  TerrainChanged(R, L);
end;

procedure TAbstractAoWHSMap.InvalidateMap;
var
  R: TRect;
  I: Integer;
begin
  R.Left := 0;
  R.Right := MapContainer.Width;
  R.Top := 0;
  R.Bottom := MapContainer.Height;
  for I := 0 to MapContainer.LevelCount - 1 do MapChanged(R, I);
end;

procedure TAbstractAoWHSMap.TriggerMapChangedEvent(const R: TRect; L: Integer);
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

procedure TAbstractAoWHSMap.SetSeatedPlayer(A1: Shortint);
begin end;

procedure TAbstractAoWHSMap.SetCurrentPlayer(A1: Shortint);
begin end;

function TAbstractAoWHSMap.FogArea(X, Y, Level: Integer; Range: Integer): Boolean;
begin Result := False; end;

function TAbstractAoWHSMap.UnFogArea(X, Y, Level: Integer; Range: Integer): Boolean;
begin Result := False; end;

function TAbstractAoWHSMap.ExploreArea(X, Y, Level: Integer; Player: Shortint; Range: Integer): Boolean;
begin Result := False; end;

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

procedure TAbstractAoWHSMap.ShowBackHexagonSelector(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin end;

procedure TAbstractAoWHSMap.ShowFrontHexagonSelector(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
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

procedure TAbstractAoWHSMap.DropHeroItem(Hero: THero; Item: TItem);
begin end;

function TAbstractAoWHSMap.GetHeroItemsOnGround(Hero: THero): TItemList;
begin Result := nil; end;

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

constructor TAbstractAoWHSMapMouse.Create;
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
var
  CombatMap: TAbstractAoWCombatMap;
begin
  CombatMap := AoWHSMap.FCombatMap;
  if CombatMap <> nil then Result := CombatMap.Mouse.GetCursor
  else Result := inherited GetCursor;
end;

procedure TAoWHSMapMouse.Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  if AoWHSMap.FCombatMap <> nil then
    AoWHSMap.FCombatMap.Mouse.Down(Button, Shift, X, Y)
  else
    inherited Down(Button, Shift, X, Y);
  if AoWEngine.FRegistry.GetDebugMode then
    AoWEngine.OutputDebugStr('Location (' + IntToStr(Xhx) + ',' + IntToStr(Yhx) + ') selected');
end;

procedure TAoWHSMapMouse.Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  if AoWHSMap.FCombatMap <> nil then
    AoWHSMap.FCombatMap.Mouse.Up(Button, Shift, X, Y)
  else
    inherited Up(Button, Shift, X, Y);
end;

procedure TAoWHSMapMouse.Move(Shift: Classes.TShiftState; X, Y: Integer);
var
  CombatMap: TAbstractAoWCombatMap;
begin
  CombatMap := AoWHSMap.FCombatMap;
  if CombatMap <> nil then CombatMap.Mouse.Move(Shift, X, Y)
  else inherited Move(Shift, X, Y);
end;

procedure TAoWHSMapMouse.DblClick;
var
  CombatMap: TAbstractAoWCombatMap;
  SelectStructure: Boolean;
  Structure: TStructure;
begin
  CombatMap := AoWHSMap.FCombatMap;
  if CombatMap <> nil then
  begin
    CombatMap.Mouse.DblClick;
    Exit;
  end;
  SelectStructure := Capture = nil;
  if Capture = AoWHSMap.FSelectedArmy then
    SelectStructure := (AoWHSMap.FSelectedArmy.GetArmyHS <> nil) and
      (AoWHSMap.FSelectedArmy.FMoveSettingsList.Count = 1) and
      (AoWHSMap.FSelectedArmy.GetArmyHS.Xhx = Xhx) and
      (AoWHSMap.FSelectedArmy.GetArmyHS.Yhx = Yhx) and
      (AoWHSMap.FSelectedArmy.GetArmyHS.Lhx = AoWHSMap.ViewL);
  if SelectStructure and (Xhx <> -1) then
  begin
    Structure := TStructure(AoWHSMap.MapContainer.GetField(Xhx, Yhx, AoWHSMap.ViewL).FindNoneTransparentHS(TStructure));
    if (Structure <> nil) and Structure.CanDblClick then
    begin
      AoWHSMap.Selection.UnselectLocation;
      AoWHSMap.Selection.SelectLocationHS(Structure);
    end;
  end;
  inherited DblClick;
end;

resourcestring
  FileNotFoundRStr = 'File not found'; { $557083A4 }

constructor TStartupSongList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  Songs.OnChange := OriginalSongsChanged;
end;

procedure TStartupSongList.OriginalSongsChanged(Sender: TObject);
var
  I: Integer;
  Name: string;
begin
  SongNames.Clear;
  for I := Songs.Count - 1 downto 0 do
  begin
    try
      Name := GetSongName(Songs[I]);
    except
      Name := TranslateRStr(FileNotFoundRStr);
    end;
    SongNames.Insert(0, Name);
  end;
end;

constructor TAoWHSMap.Create(AOwner: Engine.TECustomNode);
var
  UnitChangedEvent: TNotifyEvent;
begin
  inherited Create(AOwner);
  FItemControl := TItemControl.Create(nil);
  FTokenManager := TAoWTokenManager.Create(AoWEngine);
  FTokenManager.TokenExecuter.OnActivateTC.Add(TokenControlActivatedEvent);
  FTokenManager.TokenExecuter.OnExecuteTokenEvent := OnExecuteTokenEvent;
  FTokenManager.OnMessage := OnTokenManagerMessage;
  FPlayerCommunicator := TPlayerCommunicator.Create(nil);
  FPlayerCommunicator.Engine := AoWEngine;
  FConnectionType := pcLocal;
  FAIExecuter := TAIExecuter.Create(nil);
  FAIGroupManager := TAIGroupManager.Create(nil);
  FAIPlayerActionManager := TAIPlayerActionManager.Create(nil);
  FAIPlayerActionManager.RegisterClasses([TEndTurnAIPA, TGroupControlAIPA,
    TGroupControlLoopAIPA, TInitializeAIPA, TBudgetManagerAIPA, TAutoProduceAIPA,
    TDiplomacyAIPA, TProcessEventlogAIPA, TResearchSpellAIPA, TCastSpellAIPA,
    TStructurePhase1AIPA, TStructurePhase2AIPA]);
  FTokenManager.TokenExecuter.OnEventsExecuted.Add(FAIExecuter.TokenControlDoneEvent);
  FAIGroupManager.RegisterAIGroupClasses([THuntAG]);
  FPlayMode := pmNone;
  FKeyboard := TAoWHSMapKeyboard.Create(nil);
  FTargetSelection := TTargetSelectionControl.Create;
  FEffects := TList.Create;
  FDefendersSeed := 0;
  FHeroCountMax := 5;
  FSelectedArmy := TSelectedArmy.Create;
  TAbstractAoWHSMapMouse(Mouse).FRectangleSelectEvents.Add(FSelectedArmy.RectangleSelectEvent);
  FMoveControl := TMoveControl.Create(Self);
  FGlobalMagicControl := TGlobalMagicControl.Create(nil);
  FMapName := 'noname';
  FAuthor := '';
  FCampaignMapIndex := -1;
  FSphereCount := 5;
  FVictoryGold := 5000;
  FVictoryMana := 5000;
  FDescription := TStringList.Create;
  FObjectives := TStringList.Create;
  FIndependentAIMode := iaNormal;
  FPlayers := TPlayerList.Create(nil);
  FRaces := TRaceList.Create(nil);
  FPlayerChangedEvents := TEventList.Create;
  FFixedLeaders := True;
  FAlliedVictory := False;
  FCurrentPlayer := 0;
  FUseTurnTimer := True;
  FExecuteEventLogBuffer := TEventLogList.Create(nil);
  FDebugSave := False;
  FTutorialControl := TTutorialControl.Create(nil);
  FTurnOrderMode := toFixed;
  FTurnOrder := TByteList.Create;
  FDay := 0;
  FGameStatus := gsIdle;
  FGameResult := grNone;
  FSessionName := '';
  FShowUnitShadows := AoWEngine.FRegistry.GetDetailLevel in [dtlNormal, dtlHigh];
  FHeroControl := THeroControl.Create(nil);
  FUnitControl := TUnitControl.Create(nil);
  FStructureControl := TStructureControl.Create(nil);
  FOnLeaderChanged := TEventList.Create;
  FTextControl := TTextControl.Create(nil);
  FNewDayEvents := TEventList.Create;
  FNewTurnEvents := TEventList.Create;
  FEndTurnEvents := TEventList.Create;
  FCurrentPlayerChangedEvents := TEventList.Create;
  FSeatedPlayerChangedEvents := TEventList.Create;
  FArmyChangedEvents := TEventList.Create;
  FStructureChangedEvents := TEventList.Create;
  FTokenControlActivatedEvents := TEventList.Create;
  FUnitChangedEvents := TEventList.Create;
  TMethod(UnitChangedEvent).Code := @TTargetSelectionControl.UnitChanged;
  TMethod(UnitChangedEvent).Data := FTargetSelection;
  FUnitChangedEvents.Add(UnitChangedEvent);
  FArmyDestroyedEvents := TEventList.Create;
  FArmyDestroyedEvents.Add(FSelectedArmy.OnDestroyArmy);
  FStructureDestroyedEvents := TEventList.Create;
  FUnitDestroyedEvents := TEventList.Create;
  FCombatEvents := TEventList.Create;
  FExecuteEventLogEvents := TEventList.Create;
  FExecuteEventLogCallBacks := TExecuteEventLogCallBackList.Create;
  FCosmeticSurgeryEvents := TEventList.Create;
  FOnActivateAbility := TEventList.Create;
  FStartupSongs := TStartupSongList.Create(nil);
  FGameSongs := TSonglist.Create(nil);
  FPlayerTerminatedEvents := TEventList.Create;
  FGameOverEvents := TEventList.Create;
  FGameTerminatedEvents := TEventList.Create;
  FDiplomaticRelationsChangedEvents := TEventList.Create;
  FUpdateVisibilityEvents := TEventList.Create;
  FCombatMapCreatedEvents := TEventList.Create;
  FCombatMapDestroyedEvents := TEventList.Create;
  FExitEvents := TEventList.Create;
  FCampaignSettings := TAoWMapCampaignSettings.Create(nil);
  Mouse.OnMove.Add(MouseMoved);
end;

destructor TAoWHSMap.Destroy;
var
  I: Integer;
begin
  StopTokenEventLogging;
  LockMapChangedEvent;
  OnViewLevel := nil;
  OnCenterView := nil;
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'GENERAL.ILB');
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'CURSORS.ILB');
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'COMBAT.ILB');
  FMoveControl.Free;
  for I := FEffects.Count - 1 downto 0 do
  begin
    DynamicFixedVisibleHS.RemoveChild(TAnimation(FEffects[I]));
    DynamicVisibleHS.RemoveChild(TAnimation(FEffects[I]));
    TObject(FEffects[I]).Free;
  end;
  FEffects.Free;
  FTutorialControl.Free;
  FPlayers.BeginUpdate;
  FArmyChangedEvents.Clear;
  FStructureChangedEvents.Clear;
  FUnitChangedEvents.Clear;
  FSeatedPlayerChangedEvents.Clear;
  FCurrentPlayerChangedEvents.Clear;
  FNewTurnEvents.Clear;
  FNewDayEvents.Clear;
  FOnLeaderChanged.Clear;
  FDescription.Clear;
  FObjectives.Clear;
  FTurnOrder.Clear;
  FStructureDestroyedEvents.Clear;
  FUnitDestroyedEvents.Clear;
  FCombatMapCreatedEvents.Clear;
  FCombatMapDestroyedEvents.Clear;
  FUpdateVisibilityEvents.Clear;
  FDiplomaticRelationsChangedEvents.Clear;
  FCosmeticSurgeryEvents.Clear;
  FOnActivateAbility.Clear;
  FTokenControlActivatedEvents.Clear;
  FPlayerChangedEvents.Clear;
  FExitEvents.Clear;
  Mouse.OnMove.Remove(MouseMoved);
  if FCombat <> nil then DestroyCombat;
  if FCombatMap <> nil then
  begin
    FCombatMap.Free;
    FCombatMap := nil;
  end;
  inherited Destroy;
  FItemControl.Deactivate;
  FGlobalMagicControl.Free;
  FGlobalMagicControl := nil;
  FPlayerCommunicator.Free;
  FTokenManager.Free;
  FTokenManager := nil;
  FCampaignSettings.Free;
  FAIExecuter.Free;
  FSelectedArmy.Free;
  FSeatedPlayerChangedEvents.Free;
  FExecuteEventLogBuffer.Free;
  FNewTurnEvents.Free;
  FEndTurnEvents.Free;
  FCurrentPlayerChangedEvents.Free;
  FNewDayEvents.Free;
  FArmyChangedEvents.Free;
  FStructureChangedEvents.Free;
  FUnitChangedEvents.Free;
  FArmyDestroyedEvents.Free;
  FStructureDestroyedEvents.Free;
  FUnitDestroyedEvents.Free;
  FOnLeaderChanged.Free;
  FDescription.Free;
  FObjectives.Free;
  FTurnOrder.Free;
  FPlayerControl.Free;
  FTextControl.Free;
  FCombatEvents.Free;
  FPlayerChangedEvents.Free;
  FExecuteEventLogEvents.Free;
  FExecuteEventLogCallBacks.Free;
  FCosmeticSurgeryEvents.Free;
  FOnActivateAbility.Free;
  FGameSongs.Free;
  FStartupSongs.Free;
  FExitEvents.Free;
  FItemControl.Free;
  FItemControl := nil;
  FHeroControl.Free;
  FHeroControl := nil;
  FUnitControl.Free;
  FUnitControl := nil;
  FStructureControl.Free;
  FStructureControl := nil;
  FAIGroupManager.Free;
  FAIGroupManager := nil;
  FAIPlayerActionManager.Free;
  FPlayers.Free;
  FRaces.Free;
  FPlayerTerminatedEvents.Free;
  FGameOverEvents.Free;
  FGameTerminatedEvents.Free;
  FTargetSelection.Free;
  FCombatMapCreatedEvents.Free;
  FCombatMapDestroyedEvents.Free;
  FDiplomaticRelationsChangedEvents.Free;
  FKeyboard.Free;
  FUpdateVisibilityEvents.Free;
  FTokenControlActivatedEvents.Free;
  UnlockMapChangedEvent;
end;

procedure TAoWHSMap.StartTokenEventLogging;
begin
  if not FTokenEventLogging and not (msEditting in AoWHSMap.Status) then
  try
    {$I-}
    AssignFile(FTokenEventLog, AoWEngine.StartupDirectory + 'Debug\' +
      'SYNC_LOG' + IntToStr(GetElapsedMilliSeconds) + '.TXT');
    Rewrite(FTokenEventLog);
    WriteLn(FTokenEventLog, 'Map Session: ' + FMapName);
    WriteLn(FTokenEventLog, 'Local Player: ' + IntToStr(AoWHSMap.FPlayers.FLocalHumanPlayers[0]));
    WriteLn(FTokenEventLog, 'Local Race: ' + TranslateRStr(RaceNamesPluralRStr[
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FPlayers.FLocalHumanPlayers[0]).FPlayerRace]));
    {$I+}
    FTokenEventLogging := True;
  except
  end;
end;

procedure TAoWHSMap.StopTokenEventLogging;
begin
  if FTokenEventLogging then
  begin
    {$I-} CloseFile(FTokenEventLog); {$I+}
    FTokenEventLogging := False;
  end;
end;

procedure TAoWHSMap.SynchroniseBegin;
begin
  Inc(FSynchroniseCount);
end;

procedure TAoWHSMap.SynchroniseEnd;
begin
  Dec(FSynchroniseCount);
end;

function TAoWHSMap.GetSynchronised: Boolean;
begin
  if (FSynchroniseCount = 0) and not FTokenManager.TokenExecuter.Executing and
    not (msEditting in Status) then Result := False
  else Result := True;
end;

procedure TAoWHSMap.OnExecuteTokenEvent(Event: TTokenEvent);
begin
  if Event.ClassID <> $554 then SetModified;
  if FTokenEventLogging and (FTokenManager.TokenExecuter.ExecuteCount = 0) then
  begin
    {$I-}
    WriteLn(FTokenEventLog, Event.ClassName + ' (P:' +
      IntToStr(FTokenManager.TokenExecuter.ActiveTCIndex) + '/T:' +
      IntToStr(Event.TokenCounter) + '/S:' + IntToStr(FDefendersSeed) +
      '/D:' + IntToStr(AoWHSMap.FDay) + '/AIPC:' +
      IntToStr(AoWHSMap.FAIExecuter.FProcessCycles));
    Flush(FTokenEventLog);
    {$I+}
  end;
end;

procedure TAoWHSMap.PlayerDisconnected(Player: Shortint);
begin
  FPlayerControl.PlayerDisconnected(Player);
end;

procedure TAoWHSMap.PlayerConnectionLost;
begin
  FPlayerControl.ConnectionLost;
end;

procedure TAoWHSMap.OnTokenManagerMessage(Sender: TObject; const Msg: string);
begin
  {$I-} if FTokenEventLogging then WriteLn(FTokenEventLog, Msg); {$I+}
  AoWEngine.OutputDebugStr(Msg);
end;

function TAoWHSMap.GetIndependentAIMode: TIndependentAIMode;
begin
  Result := FIndependentAIMode;
  if not (msEditting in AoWHSMap.Status) and
    (getFireMastery in AoWHSMap.FGlobalMagicControl.FActiveEnchantments) then
    if Result = iaOff then Result := iaNormal
    else Result := iaAggressive;
end;

function TAoWHSMap.SaveGame(FileName: string): Boolean;
var
  Event: TSaveGameTE;
begin
  if AoWHSMap.FSeatedPlayer <> -1 then
  begin
    Event := TSaveGameTE.Create(nil);
    Event.FFileName := ExpandFileName(FileName);
    AoWHSMap.FTokenManager.GetTokenControl(AoWHSMap.FSeatedPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TAoWHSMap.CreateMouse: HSEngine.THSMapMouse;
begin
  Result := TAoWHSMapMouse.Create;
end;

procedure TAoWHSMap.SetSeatedPlayer(A1: Shortint);
begin
  FPlayerControl.SetSeatedPlayer(A1);
end;

function TAoWHSMap.TerrainVisible(X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := AoWHSMap.FExplorationEnabled; { Original returns true immediately when exploration is enabled. }
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= Radius) and not Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and
      (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      Result := Field.GetExplored(AoWHSMap.FSeatedPlayer);
    end;
    if not Result then WalkToNextHN(Walk);
  end;
end;

function TAoWHSMap.Visible(X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := False;
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= Radius) and not Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and
      (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      Result := ((WordRec(LongRec(Field.FFieldFlags).Hi).Lo <> 0) or (AoWHSMap.FFogEnabled = 0)) and
        (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled);
    end;
    if not Result then WalkToNextHN(Walk);
  end;
end;

function TAoWHSMap.WatchingTerrain(X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := False;
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= Radius) and not Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and
      (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      Result := (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled) and
        Viewing(Walk.X, Walk.Y, L);
    end;
    if not Result then WalkToNextHN(Walk);
  end;
end;

function TAoWHSMap.Watching(X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := False;
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= Radius) and not Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and
      (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      Result := ((WordRec(LongRec(Field.FFieldFlags).Hi).Lo <> 0) or (AoWHSMap.FFogEnabled = 0)) and
        (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled) and
        Viewing(Walk.X, Walk.Y, L);
    end;
    if not Result then WalkToNextHN(Walk);
  end;
end;

function TAoWHSMap.ValidateTerrainObservation(Player, X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
  WX: Integer;
begin
  if FShowIndependentMoves and (Player <> AoWHSMap.FSeatedPlayer) then
  begin
    Result := False;
    MapLevel := MapContainer.GetMapLevel(L);
    InitHNWalk(Walk, X, Y, 0);
    while (Walk.Radius <= Radius) and not Result do
    begin
      WX := Walk.X;
      if (WX >= 0) and (Walk.Y >= 0) and (WX < MapLevel.Width) and
        (Walk.Y < MapLevel.Height) then
      begin
        Field := TAoWMapField(MapLevel.GetField(WX, Walk.Y));
        Result := (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled);
      end;
      if not Result then WalkToNextHN(Walk);
    end;
    if Result then MakeVisible(Walk.X, Walk.Y, L, 3);
  end
  else Result := False;
end;

function TAoWHSMap.ValidateObservation(Player, X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
  WX: Integer;
begin
  if FShowIndependentMoves and (Player <> AoWHSMap.FSeatedPlayer) then
  begin
    Result := False;
    MapLevel := MapContainer.GetMapLevel(L);
    InitHNWalk(Walk, X, Y, 0);
    while (Walk.Radius <= Radius) and not Result do
    begin
      WX := Walk.X;
      if (WX >= 0) and (Walk.Y >= 0) and (WX < MapLevel.Width) and
        (Walk.Y < MapLevel.Height) then
      begin
        Field := TAoWMapField(MapLevel.GetField(WX, Walk.Y));
        Result := ((WordRec(LongRec(Field.FFieldFlags).Hi).Lo <> 0) or (AoWHSMap.FFogEnabled = 0)) and
        (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled);
      end;
      if not Result then WalkToNextHN(Walk);
    end;
    if Result then MakeVisible(Walk.X, Walk.Y, L, 3);
  end
  else Result := False;
end;

procedure TAoWHSMap.UnlockGameOverEventCallBack;
begin
  UnlockGameOverEvent;
end;

function TAoWHSMap.SelectNextHero: Boolean;
var
  Player: TPlayer;
  I, Left: Integer;
  Army: TArmy;
  Xhp, Yhp: Integer;
begin
  Player := FPlayers.GetPlayers(FSeatedPlayer);
  if Player.FArmies.Count <> 0 then
  begin
    Left := Player.FArmies.Count;
    I := Player.FHeroJoinDay;
    if (I < 0) or (I >= Player.FArmies.Count) then I := 0;
    repeat
      Inc(I);
      Dec(Left);
      if I = Player.FArmies.Count then I := 0;
    until (Left = 0) or (Player.FArmies.GetArmy(I).Hero($FF, [htHero, htLeader, htHeroLeader, htMerchant]) <> nil);
    if Player.FArmies.GetArmy(I).Hero($FF, [htHero, htLeader, htHeroLeader, htMerchant]) <> nil then
    begin
      Army := FPlayers.GetPlayers(FSeatedPlayer).FArmies.GetArmy(I);
      CenterViewTo(Army.FX, Army.FY, Army.FL);
      Selection.UnselectLocation;
      HXtoHP(Army.FX, Army.FY, Xhp, Yhp);
      Selection.SelectLocation(Xhp, Yhp, Army.FL);
      Player.FHeroJoinDay := I;
    end
    else Selection.UnselectLocation;
  end;
  Result := True;
end;

function TAoWHSMap.SelectNextArmy: Boolean;
var
  Player: TPlayer;
  I, Left: Integer;
  Army: TArmy;
  Xhp, Yhp: Integer;
begin
  Player := FPlayers.GetPlayers(FSeatedPlayer);
  if Player.FArmies.Count <> 0 then
  begin
    Left := Player.FArmies.Count;
    I := Player.FBaseHeroJoinDay;
    if (I < 0) or (I >= Player.FArmies.Count) then I := 0;
    repeat
      Inc(I);
      Dec(Left);
      if I = Player.FArmies.Count then I := 0;
    until (Left = 0) or ((Smallint(Player.FArmies.GetArmy(I).MovePoints($FF)) > 1) and
          (Player.FArmies.GetArmy(I).FUserMode * [aumGuard, aumTurnDone] = []));
    if (Smallint(Player.FArmies.GetArmy(I).MovePoints($FF)) > 1) and
          (Player.FArmies.GetArmy(I).FUserMode * [aumGuard, aumTurnDone] = []) then
    begin
      Army := FPlayers.GetPlayers(FSeatedPlayer).FArmies.GetArmy(I);
      CenterViewTo(Army.FX, Army.FY, Army.FL);
      Selection.UnselectLocation;
      HXtoHP(Army.FX, Army.FY, Xhp, Yhp);
      Selection.SelectLocation(Xhp, Yhp, Army.FL);
      Player.FBaseHeroJoinDay := I;
    end
    else Selection.UnselectLocation;
  end;
  Result := True;
end;

function TAoWHSMap.SelectPrevArmy: Boolean;
var
  Player: TPlayer;
  I, Left: Integer;
  Army: TArmy;
  Xhp, Yhp: Integer;
begin
  Player := FPlayers.GetPlayers(FSeatedPlayer);
  if Player.FArmies.Count <> 0 then
  begin
    I := Player.FBaseHeroJoinDay;
    if (I < 0) or (I >= Player.FArmies.Count) then I := 0;
    Left := Player.FArmies.Count;
    repeat
      Dec(I);
      Dec(Left);
      if I < 0 then I := Player.FArmies.Count - 1;
    until (Left = 0) or ((Smallint(Player.FArmies.GetArmy(I).MovePoints($FF)) > 1) and
          (Player.FArmies.GetArmy(I).FUserMode * [aumGuard, aumTurnDone] = []));
    if (Smallint(Player.FArmies.GetArmy(I).MovePoints($FF)) > 1) and
          (Player.FArmies.GetArmy(I).FUserMode * [aumGuard, aumTurnDone] = []) then
    begin
      Army := FPlayers.GetPlayers(FSeatedPlayer).FArmies.GetArmy(I);
      CenterViewTo(Army.FX, Army.FY, Army.FL);
      Selection.UnselectLocation;
      HXtoHP(Army.FX, Army.FY, Xhp, Yhp);
      Selection.SelectLocation(Xhp, Yhp, Army.FL);
      Player.FBaseHeroJoinDay := I;
    end
    else Selection.UnselectLocation;
  end;
  Result := True;
end;

procedure TAoWHSMap.SeatedPlayerChanged;
var
  Msg: TEMsg;
begin
  Selection.UnselectAll;
  InitMsg(Msg, $20020006, Self);
  MapContainer.SendMsg(Msg, Self);
  InitMsg(Msg, $20020009, Self);
  MapContainer.SendMsg(Msg, Self);
  FSeatedPlayerChangedEvents.TriggerNotifyEvents(AoWHSMap);
  ShowMessage('');
end;

procedure TAoWHSMap.BeginUnitUpdate;
begin
  Inc(FUnitUpdateCount);
end;

procedure TAoWHSMap.EndUnitUpdate;
begin
  Dec(FUnitUpdateCount);
  if FUnitUpdateCount = 0 then UnitChanged(nil);
end;

procedure TAoWHSMap.UnitChanged(AUnit: TAbstractUnit);
begin
  if FUnitUpdateCount = 0 then FUnitChangedEvents.TriggerNotifyEvents(AUnit);
end;

procedure TAoWHSMap.UnitDestroyed(AUnit: TAbstractUnit);
begin
  if not (msDestroying in AoWHSMap.Status) then
  FUnitDestroyedEvents.TriggerNotifyEvents(AUnit);
end;

procedure TAoWHSMap.BeginArmyUpdate;
begin
  Inc(FArmyUpdateCount);
end;

procedure TAoWHSMap.EndArmyUpdate;
begin
  Dec(FArmyUpdateCount);
  if FArmyUpdateCount = 0 then ArmyChanged(nil);
end;

procedure TAoWHSMap.ArmyChanged(Army: TArmy);
begin
  if FArmyUpdateCount = 0 then FArmyChangedEvents.TriggerNotifyEvents(Army);
end;

procedure TAoWHSMap.ArmyDestroyed(Army: TArmyHS);
{ conflict: procedure TAoWHSMap.ArmyDestroyed(Army: TArmy); }
begin
  FArmyDestroyedEvents.TriggerNotifyEvents(Army);
end;

procedure TAoWHSMap.BeginStructureUpdate;
begin
  Inc(FStructureUpdateCount);
end;

procedure TAoWHSMap.EndStructureUpdate;
begin
  Dec(FStructureUpdateCount);
  if FStructureUpdateCount = 0 then StructureChanged(nil);
end;

procedure TAoWHSMap.StructureChanged(Structure: TStructure);
begin
  if FStructureUpdateCount = 0 then FStructureChangedEvents.TriggerNotifyEvents(Structure);
end;

procedure TAoWHSMap.StructureDestroyed(Structure: TStructure);
begin
  FStructureDestroyedEvents.TriggerNotifyEvents(Structure);
end;

procedure TAoWHSMap.TriggerCombatEvent;
begin
  FCombatEvents.TriggerNotifyEvents(Combat);
end;

procedure TAoWHSMap.TriggerGameTerminatedEvent;
begin
  FGameStatus := gsTerminated;
  FGameOverEvents.TriggerNotifyEvents(Self); { Original dispatches through $1B8. }
end;

procedure TAoWHSMap.ExecuteExitGame;
begin
  FExitPending := True;
  FExitEvents.TriggerNotifyEvents(Self);
end;

procedure TAoWHSMap.ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack);
var
  PlayerControl: TPlayerControl;
begin
  if not FExitPending then
  begin
    PlayerControl := FPlayerControl;
    if PlayerControl <> nil then PlayerControl.ExitGame(Mode, Done)
    else
    begin
      ExecuteExitGame;
      if Assigned(Done) then Done(Mode, True);
    end;
  end
  else if Assigned(Done) then Done(Mode, True);
end;

procedure TAoWHSMap.TriggerEndTurnEvent(Player: Shortint);
begin
  FEndTurnEvents.TriggerNotifyEvents(TObject(Player));
end;

procedure TAoWHSMap.ClearExecuteEventLogBuffer;
begin
  while FExecuteEventLogCallBacks.GetCount > 0 do
  begin
    if Assigned(FExecuteEventLogCallBacks.GetItem(0)^.Done) then
      FExecuteEventLogCallBacks.GetItem(0)^.Done(FExecuteEventLogCallBacks.GetItem(1)^.Log);
      { Original passes the second record's log to the first callback, even for a one-item list. }
    FExecuteEventLogCallBacks.Delete(0);
  end;
end;

procedure TAoWHSMap.ExecuteNextEventLog;
var
  Info: TExecuteEventLogInfo;
begin
  if FExecuteEventLogCallBacks.GetCount <> 0 then
  begin
    Inc(FAILockCount);
    Info := FExecuteEventLogCallBacks.GetItem(0)^;
    Info.Done := ExecuteEventLogDone;
    FExecuteEventLogEvents.TriggerNotifyEvents(TObject(@Info));
  end;
end;

procedure TAoWHSMap.SetExecuteEventLogDelay(Value: Integer);
begin
  if FExecuteEventLogDelay = 0 then
  begin
    FExecuteEventLogDelay := Value;
    LockExecuteEventLog;
  end
  else if FExecuteEventLogDelay < Value then FExecuteEventLogDelay := Value;
end;

procedure TAoWHSMap.UpdateExecuteEventLogDelay;
begin
  if FExecuteEventLogDelay <> 0 then
  begin
    Dec(FExecuteEventLogDelay);
    if FExecuteEventLogDelay = 0 then UnlockExecuteEventLog;
  end;
end;

procedure TAoWHSMap.ExecuteEventLogDone(Log: TEventLog);
var
  Info: TExecuteEventLogInfo;
begin
  if (FExecuteEventLogCallBacks.GetCount > 0) and
    (Log = FExecuteEventLogCallBacks.GetItem(0)^.Log) then
  begin
    Info := FExecuteEventLogCallBacks.GetItem(0)^;
    FExecuteEventLogCallBacks.Delete(0);
    if Assigned(Info.Done) then Info.Done(Info.Log);
    Info.Log.Release;
  end;
  SetExecuteEventLogDelay(2);
  UnlockExecuteEventLog;
end;

procedure TAoWHSMap.LockExecuteEventLog;
begin
  Inc(FAILockCount);
end;

procedure TAoWHSMap.UnlockExecuteEventLog;
begin
  Dec(FAILockCount);
  if FAILockCount = 0 then ExecuteNextEventLog;
end;

procedure TAoWHSMap.TriggerExecuteEventLog(Log: TEventLog; Immediate: Boolean; Done: TExecuteDoneEvent);
var
  Info: TExecuteEventLogInfo;
begin
  Info.Log := Log;
  Info.Done := Done;
  Info.Immediate := Immediate;
  if not Immediate then
  begin
    Log.AddRef;
    FExecuteEventLogCallBacks.Add(Info);
    if FAILockCount = 0 then ExecuteNextEventLog;
  end
  else FExecuteEventLogEvents.TriggerNotifyEvents(TObject(@Info));
end;

procedure TAoWHSMap.TriggerPlayerTerminatedEvent(Player: Integer);
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

procedure TAoWHSMap.MouseMoved(Sender: TObject);
begin end;

procedure TAoWHSMap.UpdateCursor;
begin end;

procedure TAoWHSMap.ResetSeatedPlayerView;
begin end;

procedure TAoWHSMap.Select(A1: THexagonSprite; A2: Boolean);
begin end;

procedure TAoWHSMap.PlayerChanged;
begin end;

procedure TAoWHSMap.TokenControlActivatedEvent(Sender: TObject);
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

procedure TAoWHSMap.RetrieveBattleFieldInfo(X, Y, L, Radius: Integer; var Info: TBattleFieldInfo);
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

function TAoWHSMap.ChangeTerrain(MO: Engine.TEObject; X, Y, L, Radius, TerrainType: Integer): Integer;
begin Result := 0; end;

function TAoWHSMap.ChangeTerrainEx(MO: Engine.TEObject; X, Y, L, Radius: Integer; ChangeTerrainProc: HSEngine.TChangeTerrainProc; TerrainChangedProc: HSEngine.TTerrainChangedProc): Integer;
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
      Data.FX, Data.FY, Data.FL, I) or
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

function FmtDaysLeftStr(Days: Integer): string;
begin
  if Days = 1 then Result := Format(TranslateRStr(XDayLeftRStr), ['1'])
  else Result := Format(TranslateRStr(XDaysLeftRStr), [IntToStr(Days)]);
end;

function HitPointsToHitPcnt(A1, A2: Shortint): Integer;
begin Result := 0; end;

procedure ShowHitPcnt(A1: Integer; A2: Integer; const A3: TSurfaceDesc; A4: Integer);
begin end;

procedure ShowDamageIcon(X, Y: Integer; const Surface: TSurfaceDesc; Damage: Integer; DamageType: TDamageType);
begin end;

procedure ShowDamageEffects(A1: Word; A2: Integer; A3: Integer; A4: Integer; const A5: TSurfaceDesc);
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

function CombatRangeToCombatMode(A1: TCombatRange): TCombatMode;
begin Result := cmNone; end;

procedure PlaceRandomUnits(X, Y, L: Integer; Player: Shortint; Units: TUnitIndexList; Count, Value: Integer; Mode: TUnitPlaceMode);
begin end;

function FillWithRandomUnits(Indexes: TIntegerList; Units: TUnitList; Level, Value: Integer; Types: TUnitTypes): Integer;
begin Result := 0; end;

procedure FillWithRandomUnitIndexes(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TriggerStormDamage(Storm: TStormType; X, Y, L, InnerRadius, OuterRadius, Player: Shortint);
begin end;

procedure RetrieveStormDamageInfo(Player: Shortint; Storm: TStormType; X, Y, L, InnerRadius, OuterRadius: Shortint; var Info: TStormDamageInfo);
begin end;

procedure dAlignmentToDiplomaticRelation(A1: Integer; A2: Integer);
begin end;

procedure StatusToDiplomaticRelation(A1: Byte);
begin end;

function GetCombatSide(A1: Byte; A2: Byte; A3: Byte; A4: Byte; A5: Byte; A6: Byte): TCombatSideIndex;
begin Result := csNeutral; end;

procedure AlignmentToIR(A1: Byte);
begin end;

procedure IRtoAlignment(A1: Integer);
begin end;

function DiplomaticRelation(Player, IndependentRelation, OtherPlayer, OtherIndependentRelation: Shortint): TDiplomaticRelation;
begin Result := drPeace; end;

function ValidAttackRelation(Player, IndependentRelation, TargetPlayer, TargetRace: Shortint): Boolean;
begin Result := False; end;

function GetUnitIndexAIPriority(UnitIndex: Integer; Player: Shortint; Relation: Shortint): Integer;
begin Result := 0; end;

function UnitsToIndependentRelation(Units: TUnitList; DefaultRelation: Shortint): Shortint;
begin Result := 0; end;

procedure DegreesRadToCo(A1: Integer; A2: Integer; var A3: Integer; var A4: Integer);
var
  Radians: Single;
begin
  Radians := A1 * Pi / 180;
  A3 := Round(Cos(Radians) * A2);
  A4 := Round(Sin(Radians) * A2);
end;

function Encode(Text: string; Mode: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Text) do
    Result := Result + Char(Ord(Text[I]) xor ((Length(Text) + I + 5) and $FF));
end;

procedure SetupBattleFieldInfo(var Info: TBattleFieldInfo; Player, Relation: Shortint; Requests: TBattleFieldInfoRequests; DamageTypes: TDamageTypes);
begin end;

function StrengthInfoMax(const Strengths): Integer;
begin Result := 0; end;

procedure InvertDamageTypes(A1: Word);
begin end;

function ListMovementGaps(Map: TAoWHSMap; Path: TMovepath; const Table: TMovePointTable; Ends, Starts: TIntegerList): Integer;
begin Result := 0; end;

function GetMovepathBattleFieldStrength(Player, IndependentRelation: Shortint; Movepath: TMovepath; TargetRange, Range, Step: Integer): Integer;
begin Result := 0; end;

function GetBattleFieldStrengthAdvantage(Location: Integer; Player, Relation: Shortint; DamageTypes: TDamageTypes; EnemyRadius, FriendlyRadius: Integer; Units: TUnitList): Integer;
begin Result := 0; end;

function IgnitionChance(MapField: TAoWMapField): Integer;
begin Result := 0; end;

function CreateEnhancementAbility(ID: Integer; const Name: string; SelectionTypes: TAbilitySelectionTypes): TEnhancementAbility;
begin Result := nil; end;

function MeleeDamageTypes(A1: TCombatObject): TDamageTypes;
begin Result := []; end;

function StrikeDV(A1, A2: TCombatObject): Integer;
begin Result := 0; end;

function CreateStrikeCA(A1, A2: TCombatObject; A3: Boolean): TStrikeCA;
begin Result := nil; end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;

function ValidateAoWEngine: Boolean;
begin Result := False; end;

