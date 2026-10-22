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
    function GetInherentLevel(Owner: TAbilityOwner): Integer; virtual; abstract;
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
{ ProduceXRStr is declared in the interface. }
{ InstallXRStr is declared in the interface. }
  SummonXRStr = 'Summon %s';
  ProducingXRStr = 'Producing %s';
  InstallingXRStr = 'Installing %s';
  SummoningXRStr = 'Summoning %s';

resourcestring
  ConfirmRStr = 'Confirm';
  YourAboutToExitAMultiPlayerGameRStr = 'You''re about to exit a multi-player game!';
  DoYouWantToContinueExitingRStr = 'Do you want to continue exiting?';
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
  { WarningRStr is exported in intf_P1_14.inc. }
  XatYRStr = '%0:s at %1:s';
  ItsYourTurnRStr = 'It''s your turn!';
  YourTurnContinuesRStr = 'Your turn continues';
  IndependentsAreMovingRStr = 'Independents are moving';
  PlayerIsMovingRStr = '%s is moving';
  AreMovingRStr = '%s are moving';
  { PlayerRStr is declared in the interface; AoWEd 004289AF. }
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
  { MountainRStr is declared in the interface for Mountain.ResourceEditName. }
  DenseVegetationRStr = 'Dense Vegetation';
  { HillRStr is declared in the interface for Hill.ResourceEditName. }
  VegetationRStr = 'Vegetation';
  RoadRStr = 'Road';
  BridgeRStr = 'Bridge';
  RubbleRStr = 'Rubble';
  { StructureRStr is public in the interface; AoWEd 00425694. }
  { ObstacleRStr is exported in the interface. }
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

resourcestring
  CannotBuildOnCurrentLocationRStr = 'Cannot build on current location';

{ Exported resourcestring declaration recovered from AoW 00433E4D. }
    { FireRStr is exported from the interface; AoW 00433E4D. }

resourcestring
  ObserveEnabledRStr = 'Observe enabled';
  ObserveDisabledRStr = 'Observe disabled';
const
  CheatNames: array[0..9] of string = ('gold', 'mana', 'explore', 'fog', 'spells',
    'win', 'freemove', 'towns', 'lose', 'research');

resourcestring
  FileNotFoundRStr = 'File not found'; { $557083A4 }
{ P2 recovery in original code order. }
type
  TP2HeroLevel = record
    DailyExperience, Experience: Integer;
  end;
const
  HeroExperienceTable: array[0..5] of TP2HeroLevel = (
    (DailyExperience: 1; Experience: 15), (DailyExperience: 1; Experience: 15),
    (DailyExperience: 1; Experience: 20), (DailyExperience: 1; Experience: 20),
    (DailyExperience: 1; Experience: 25), (DailyExperience: 1; Experience: 25));
{ Use the P1 shared AoWHSSet at $558FA044. }



const
  { needs: P1 shared dAlignmentToStatusValue, original 558E8480. }
  P2AlignmentToStatusValue: array[TAlignment, TAlignment] of Shortint =
    ((100,90,30,40,10,0,50), (90,90,40,50,10,10,50),
     (30,40,70,50,40,30,50), (40,50,50,50,50,40,50),
     (10,10,40,50,90,90,50), (0,10,30,40,90,100,50),
     (50,50,50,50,50,50,50));

type
  TP2RaceTerrain = record
    Preferred, Disliked: TAoWTerrainTypes;
  end;
const
  { needs: P1 shared RaceTerrain at 558E8394, 12 pairs of two-byte terrain sets. }
  P2RaceTerrain: array[0..11] of TP2RaceTerrain = (
    (Preferred: []; Disliked: []),
    (Preferred: [ttDesert]; Disliked: [ttSnow, ttIce, ttUndergroundIce]),
    (Preferred: [ttWater]; Disliked: [ttDesert, ttWasteland]),
    (Preferred: [ttSnow, ttIce, ttUndergroundIce]; Disliked: [ttDesert]),
    (Preferred: [ttGrass]; Disliked: [ttWasteland]),
    (Preferred: [ttGrass]; Disliked: [ttWasteland]),
    (Preferred: [ttDirt]; Disliked: []),
    (Preferred: []; Disliked: []),
    (Preferred: [ttDirt]; Disliked: []),
    (Preferred: []; Disliked: []),
    (Preferred: [ttDirt]; Disliked: []),
    (Preferred: [ttWasteland]; Disliked: [ttGrass]));

type
  { Local views of unmarked foreign fields; no foreign layout is changed. }
  TP2NodeFields = class(TObject)
    Owner: Pointer;
    Children: TList;
  end;
  TP2AbilityControlFields = class(TObject)
    Reserved: array[4..23] of Byte;
    CombatAbilities: TAbilityTypeList;
    Enchantments: TAbilityTypeList;
  end;

type
  { Local VMT view while foreign draft result types remain undeclared.
    Offsets proved by calls 5577F57C, 5577F599, 5577F5D1, 5577F60C, 5577F651. }
  { Damage-value record, five dwords at 5577F9FF..5577FA24. }
  TP2DamageValue = record
    Damage, Reserved, Cost, Reserved2, Reserved3: Integer;
  end;
  TP2AbilityCalls = class(TObject)
    ReservedFields: array[4..11] of Byte;
    AbilityID: Integer;
    procedure Slot00; virtual; abstract;
    procedure Slot04; virtual; abstract;
    procedure Slot08; virtual; abstract;
    procedure Slot0C; virtual; abstract;
    procedure Slot10; virtual; abstract;
    procedure Slot14; virtual; abstract;
    procedure Slot18; virtual; abstract;
    procedure Slot1C; virtual; abstract;
    procedure Slot20; virtual; abstract;
    procedure Slot24; virtual; abstract;
    procedure Slot28; virtual; abstract;
    procedure Slot2C; virtual; abstract;
    procedure Slot30; virtual; abstract;
    procedure Slot34; virtual; abstract;
    procedure Slot38; virtual; abstract;
    procedure Slot3C; virtual; abstract;
    procedure Slot40; virtual; abstract;
    procedure Slot44; virtual; abstract;
    procedure Slot48; virtual; abstract;
    function GetAbSet(Index: Integer): Boolean; virtual; abstract;
    procedure Slot50; virtual; abstract;
    function AbilityType: TAbilityType; virtual; abstract;
    function AbilityName(AOwner: TAbilityOwner): string; virtual; abstract;
    procedure Slot5C; virtual; abstract;
    procedure Slot60; virtual; abstract;
    procedure Slot64; virtual; abstract;
    procedure Slot68; virtual; abstract;
    procedure Slot6C; virtual; abstract;
    function AbilityLevel(AOwner: TAbilityOwner): Integer; virtual; abstract;
    function AbilityEnabled(AOwner: TAbilityOwner): Boolean; virtual; abstract;
    procedure Slot78; virtual; abstract;
    procedure Slot7C; virtual; abstract;
    procedure Slot80; virtual; abstract;
    procedure Slot84; virtual; abstract;
    procedure Slot88; virtual; abstract;
    function SourceName(AOwner: TAbilityOwner): string; virtual; abstract;
    function AbilityInherent(AOwner: TAbilityOwner): Boolean; virtual; abstract;
    function AbilityInherentLevel(AOwner: TAbilityOwner): Integer; virtual; abstract;
    procedure Slot98; virtual; abstract;
    procedure Slot9C; virtual; abstract;
    procedure SlotA0; virtual; abstract;
    function CanAddUnit(AUnit: TAbstractUnit): Boolean; virtual; abstract;
    procedure SlotA8; virtual; abstract;
    function AddUnit(AUnit: TAbstractUnit): Boolean; virtual; abstract;
    procedure SlotB0; virtual; abstract;
    procedure SlotB4; virtual; abstract;
    procedure SlotB8; virtual; abstract;
    procedure SlotBC; virtual; abstract;
    procedure SlotC0; virtual; abstract;
    procedure SlotC4; virtual; abstract;
    procedure SlotC8; virtual; abstract;
    procedure SlotCC; virtual; abstract;
    class function GroupBehavior: TGroupBehavior; virtual; abstract;
    procedure SlotD4; virtual; abstract;
    procedure SlotD8; virtual; abstract;
    procedure DamageValueEx(AOwner: TAbilityOwner; Target: TAbstractUnit;
      Mode: Byte; var Info: TP2DamageValue); virtual; abstract;
    procedure OffensiveStrength(AOwner: TAbilityOwner; var Strength: Integer;
      var DamageTypes: TDamageTypes); virtual; abstract;
  end;
  TP2PString = ^string;

resourcestring
  P2InherentRStr = 'Inherent'; { original resource at 5570716C }

const
  { needs: original shared ability-type text table at 558E8250.
    These defaults follow the recovered ability-type enumeration. }
  P2AbilityTypeNames: array[TAbilityType] of string =
    ('Enhancement', 'Handicap', 'Movement', 'Combat', 'Enchantment');

type
  { VMT +94 is ExpandAbility for an owner; +54/+58 are enchantment setters. }
  TP2OwnerCalls = class(TObject)
    procedure Slot00; virtual; abstract;
    procedure Slot04; virtual; abstract;
    procedure Slot08; virtual; abstract;
    procedure Slot0C; virtual; abstract;
    procedure Slot10; virtual; abstract;
    procedure Slot14; virtual; abstract;
    procedure Slot18; virtual; abstract;
    procedure Slot1C; virtual; abstract;
    procedure Slot20; virtual; abstract;
    procedure Slot24; virtual; abstract;
    procedure Slot28; virtual; abstract;
    procedure Slot2C; virtual; abstract;
    procedure Slot30; virtual; abstract;
    procedure Slot34; virtual; abstract;
    procedure Slot38; virtual; abstract;
    procedure Slot3C; virtual; abstract;
    procedure Slot40; virtual; abstract;
    procedure Slot44; virtual; abstract;
    procedure Slot48; virtual; abstract;
    procedure Slot4C; virtual; abstract;
    procedure Slot50; virtual; abstract;
    procedure Slot54; virtual; abstract;
    procedure Slot58; virtual; abstract;
    procedure Slot5C; virtual; abstract;
    procedure Slot60; virtual; abstract;
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
    procedure Slot8C; virtual; abstract;
    procedure Slot90; virtual; abstract;
    function Expand(ID: Integer): Boolean; virtual; abstract;
  end;
  TP2EnchantmentCalls = class(TObject)
    Reserved: array[4..19] of Byte;
    Duration: Byte;
    procedure Slot00; virtual; abstract;
    procedure Slot04; virtual; abstract;
    procedure Slot08; virtual; abstract;
    procedure Slot0C; virtual; abstract;
    procedure Slot10; virtual; abstract;
    procedure Slot14; virtual; abstract;
    procedure Slot18; virtual; abstract;
    procedure Slot1C; virtual; abstract;
    procedure Slot20; virtual; abstract;
    procedure Slot24; virtual; abstract;
    procedure Slot28; virtual; abstract;
    procedure Slot2C; virtual; abstract;
    procedure Slot30; virtual; abstract;
    procedure Slot34; virtual; abstract;
    procedure Slot38; virtual; abstract;
    procedure Slot3C; virtual; abstract;
    procedure Slot40; virtual; abstract;
    procedure Slot44; virtual; abstract;
    procedure Slot48; virtual; abstract;
    procedure Slot4C; virtual; abstract;
    procedure Slot50; virtual; abstract;
    procedure SetUpkeep(Value: Integer); virtual; abstract;
    procedure SetSource(Player: Shortint); virtual; abstract;
  end;
  TP2SpellFields = class(TObject)
    Reserved: array[4..59] of Byte;
    Duration: Byte;
  end;
const
  StormDamageType: array[TStormType] of TDamageType = { 558E8330; original seven-byte table. }
    (dtNone,dtFire,dtDeath,dtHoly,dtCold,dtLightning,dtPoison);

type
  TP2CombatTurnFields = class(TObject)
    Reserved: array[4..48] of Byte;
    Turn: Byte;
  end;
  { Obsolete serialized behavior object, VMT +4C read at 55782176. }
  TP2LegacyBehaviorCalls = class(TObject)
    procedure Slot00; virtual; abstract;
    procedure Slot04; virtual; abstract;
    procedure Slot08; virtual; abstract;
    procedure Slot0C; virtual; abstract;
    procedure Slot10; virtual; abstract;
    procedure Slot14; virtual; abstract;
    procedure Slot18; virtual; abstract;
    procedure Slot1C; virtual; abstract;
    procedure Slot20; virtual; abstract;
    procedure Slot24; virtual; abstract;
    procedure Slot28; virtual; abstract;
    procedure Slot2C; virtual; abstract;
    procedure Slot30; virtual; abstract;
    procedure Slot34; virtual; abstract;
    procedure Slot38; virtual; abstract;
    procedure Slot3C; virtual; abstract;
    procedure Slot40; virtual; abstract;
    procedure Slot44; virtual; abstract;
    procedure Slot48; virtual; abstract;
    class function Behavior: Byte; virtual; abstract; { Class call at 55782176. }
  end;

resourcestring
  P2RefugeJoinRStr = 'This one begs to join your cause.';
  P2RefugeesJoinRStr = 'This group wishes to join your forces.';
  P2BribeUnitJoinRStr = 'For %s gold pieces, this one offers to join you.';
  P2BribeUnitsJoinRStr = 'For %s gold pieces, they offer to join you.';

type TP2ShortintPointer = ^Shortint;
  TP2MapPlayerFields = class(TObject)
    Reserved: array[4..164] of Byte;
    Player: Shortint;
  end;

{ Rank and morale tables read at 557829DD..55782B75. }
const
  P2RankDefense: array[TUnitRank] of Shortint = (0,1,1);
  P2RankAttack: array[TUnitRank] of Shortint = (0,1,1);
  P2RankDamage: array[TUnitRank] of Shortint = (0,0,1);
  P2RankResistance: array[TUnitRank] of Shortint = (0,0,1);
  P2RankHits: array[TUnitRank] of Shortint = (0,1,2);
  P2MoraleResistance: array[TMorale] of Shortint = (-2,-1,0,0,0);
  P2MoraleDefense: array[TMorale] of Shortint = (-2,-1,0,0,0);

type
  TP2FaceEnchantmentFields = class(TObject)
    Reserved: array[4..31] of Byte;
    FaceIndex: Integer;
  end;

resourcestring
  P2WoodenWallRStr = 'Wooden Wall';
  P2StoneWallRStr = 'Stone Wall';
  P2UndefinedWallRStr = 'Undefined';

resourcestring
  XMadeALevelRStr = '%s made a level';
  XMadeYLevelsRStr = '%s made %d levels';
  CanOnlyUpgradeHeroOnceRStr = 'Can only upgrade hero once';
  CanOnlyUpgradeOnTheDayALevelIsMadeRStr = 'Can only upgrade on the day a level is made';
  XOffersToJoinRStr = '%s offers to join!';
  XAlreadyJoinedRStr = '%s already joined';
  XDoesntWantToJoinAnymoreRStr = '%s doesn''t want to join anymore';
  XEmergedAtYAndOffersToJoinYouForZgpRStr = '%0:s emerged at %1:s and offers to join you for %d gold';
  XwasResurrectedAndOffersToJoinYouForZgpRStr = '%s was resurrected and offers to join you for %d gold';

resourcestring
  UnitsDrownRStr = 'Units Drowned';
  UnitsBurnedRStr = 'Units Burned';
  UnitsCrushedRStr = 'Units Crushed';
  ArmyInherentRStr = 'Inherent';
const
  ArmySelectionMasks: array[0..8] of Byte = (0, 1, 3, 7, 15, 31, 63, 127, 255);

resourcestring
  DesertionRStr = 'Desertion';
  TheLeaderOfThePartyStepsForwardRStr = 'The leader of the party steps forward';
  OneUnitDesertedRStr = '1 unit deserted';
  XUnitsDesertedRStr = '%s units deserted';
  DesertUnitNoUpkeepRStr = 'This one abandons you, refusing a voucher for pay.';
  DesertUnitsNoUpkeepRStr = 'Without sufficient funds for support, these troops desert you.';
  DesertUnitLowMoraleRStr = 'With no common cause, this one deserts you.';
  DesertUnitsLowMoraleRStr = 'No longer sharing your cause, these desert you.';
  DesertUnitLowMoraleSplitRStr = 'Lacking faith, this one abandons your ranks';
  DesertUnitsLowMoraleSplitRStr = 'Troubled and weary, these abandon your ranks.';

resourcestring
  P2PartyJoinHeaderRStr = 'The leader of the party steps forward:';
  P2PartyJoinRStr = 'Party Join';
  P2OneUnitJoinedRStr = '1 unit joined';
  P2AUnitJoinedTheForcesofYRStr = 'A unit joined the forces of %s';
  P2XUnitsJoinedRStr = '%s units joined';
  P2XUnitsJoinedTheForcesofYRStr = '%d units joined the forces of %s';
  P2XJoinedRStr = '%s joined';
  P2XJoinedTheForcesOfYRStr = '%0:s joined the forces of %1:s';
  P2FireDamageRStr = 'Fire damage';
const
  TStormTypeRStr: array[TStormType] of string =
    (NoneRStr, FireStormRStr, DeathStormRStr, DivineStormRStr, IceStormRStr, LightningStormRStr, PestilenceStormRStr);

resourcestring
  P2ArmyRStr = 'Army';

resourcestring
  SelectRoadConstructionPathRStr = 'Select road construction path';
  ArmyNotEnoughMovePointsRStr = 'Not enough move points';
  ArmyRoadConstructionCostRStr = 'Constructing road will cost %s gold';
  ArmyNotAtWarRStr = 'Not at war with the %s';

resourcestring
  ItemSpellResearchedRStr = '%s researched';
  ItemSpellAlreadyResearchedRStr = '%s already researched';
  ItemNotUseableRStr = 'This is not an usable item';
  ItemSystemLibraryRStr = 'System';

resourcestring
  SystemItemLibraryRStr = 'System';

resourcestring
  ItemBagRStr = 'Item Bag';

resourcestring
  P2UndeadPluralRStr = 'Undead(plural)';
  P2UndeadRStr = 'Undead';

const
  P2MovementTemplates: array[0..7] of TMovePointTable = (
  (
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, 3, 3, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (4, -1, -1, -1, 4, -1, -1, 4, 4, -1, 4, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, -1, -1, 4, 4, -1, 4, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, -1, -1, 4, 4, -1, 4, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (4, -1, -1, -1, 4, -1, 4, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, -1, -1, -1, -1, 4, 4, -1, 4, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, -1, 4, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (4, -1, -1, -1, 4, 4, 4, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (4, -1, -1, -1, 4, 4, -1, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (4, -1, 4, -1, 4, 4, -1, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 4, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, -1, 4, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, 3, 3, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, 3, 3, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (3, -1, 6, -1, 3, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, 3, 3, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, -1, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ));
var
  CombatDID, TMPDID, MAGICDID: Integer;
{ P3 combat implementation. }
resourcestring
  BattleWonRStr = 'Battle Won';
  BattleLostRStr = 'Battle Lost';
  BattleDrawnRStr = 'Battle Drawn';


type
  PP3String = ^string;
  TP3NodeAccess = class(TENode)
  public
    property ChildrenList: TEObjectList read FChildren;
  end;
var
  P3HitProbabilities: array[0..19] of Single;

{ P4 abilities and magic.
  Adjustable, duration, multilevel, unit-enchantment, cosmetic-surgery, leadership,
  strike, touch, invoke-death, healing and dispel-magic abilities and their combat
  actions are recovered; healing token events and selectors are recovered.
  Dispel-magic token events/selectors, spellcasting, ranged/bolt/breath/flame
  attacks and command ability data/commanded abilities are recovered.
  Command, dominate, charm, seduce, construction controls, spell-cast event logs,
  unit-spell combat actions and unit-spell token events are recovered.
  Unit spells, research/casting AI, enchantments and player-magic logs are recovered.
  Player-magic control is recovered through GetNetPowerToResearch.
  Player-magic control, its token event, global enchantments and their logs/list
  and global-magic control and token events are recovered.
  The base spell, spell events/control/list/casters and power sources are recovered.
  Compatibility declarations preserve calls to other packages' draft APIs; these
  adapters never create instances of their declaration-only views. }

type
  P4LongString = ^string;
  P4ShortInt = ^ShortInt;
  TUnitControlCallViewP4 = class(TUnitControl)
    function FindUnitResult(ID: Integer): TAbstractUnit;
  end;
  { P1's unmarked $FC field is still Integer. This local view changes no layout. }
  TP4MapUnitControl = record
    Reserved: array[0..$FB] of Byte;
    UnitControl: TUnitControlCallViewP4;
  end;
  PP4MapUnitControl = ^TP4MapUnitControl;
  TSpellTECallViewP4 = class(TTokenEvent)
    function ValidateValue(Source: TAbstractUnit): Boolean; virtual; abstract;
    function ProcessValue(Source: TAbstractUnit; Pass: Integer): Boolean; virtual; abstract;
  end;
  TP4TokenExecuterState = record
    Reserved: array[0..$1F] of Byte;
    ExecuteCount: Integer;
  end;
  PP4TokenExecuterState = ^TP4TokenExecuterState;
  THeroCastingViewP4 = class(THero)
    function SpellMana(Spell: TSpell): Integer;
  end;
  TP4DamageValue = record
    V0, V1, V2, V3: Integer;
    DamageTypes: TDamageTypes;
  end;
  PP4DamageValue = ^TP4DamageValue;
  TP4CombatInfo = record
    V0, V1: Byte;
    DamageTypes: TDamageTypes;
    V4, V5, V6: Byte;
    Modes: TCombatModes;
  end;
  PP4CombatInfo = ^TP4CombatInfo;
  { Temporary declaration views: no instances are created. }
  TDurationReturnView = class(TAbility)
    function GetDuration(AbilityOwner: TAbilityOwner): Byte; virtual; abstract;
    function GetTotalDuration: Integer; virtual; abstract;
  end;
  { needs: P3 TCombatObject.GetAbilityOwner: TAbilityOwner at VMT $B8.
    This declaration-only view preserves TEObject's slots through $48 and
    the TCombatObject slots $4C..$B8; no instances are created. }
  { Only VMT $128/$12C are called; this view is never instantiated. }
  TCastingPointsReturnViewP4 = class(TDurationReturnView)
    procedure Slot114; virtual; abstract;
    procedure Slot118; virtual; abstract;
    procedure Slot11C; virtual; abstract;
    procedure Slot120; virtual; abstract;
    procedure Slot124; virtual; abstract;
    function CastingPointsMax: ShortInt; virtual; abstract;
    function CastingPoints: ShortInt; virtual; abstract;
  end;

const
  { CommandAbilityIDs is declared in the interface (557F8492). }
  P4LeadershipAttack: array[0..4] of Shortint = (0, 1, 1, 2, 2);
  P4LeadershipDefense: array[0..4] of Shortint = (2, 0, 1, 1, 2);
  { Class-reference constants used by the recovered multilevel implementation. }
  P4CommandDataClass: TEObjectClass = TCommandAbilityData;
  P4CommandedDataClass: TEObjectClass = TCommandedAbilityData;
  P4PossessedDataClass: TEObjectClass = TPossessedAbilityData;
  P4DispelMagicDataClass: TEObjectClass = TDispelMagicAbilityData;
  P4HealingDataClass: TEObjectClass = THealingAbilityData;
  P4DurationDataClass: TEObjectClass = TDurationAbilityData;
  P4MultiLevelDataClass: TEObjectClass = TMultiLevelAbilityData;
  P4SelectionMasks: array[0..8] of Byte = (0, 1, 3, 7, 15, 31, 63, 127, 255);
  P4EmptySelection: Word = 0;
  P4EmptyDamageTypes: TDamageTypes = [];
  P4EmptyCombatModes: TCombatModes = [];
  P4CastSpellActionClass: TEObjectClass = TAICastSpellAction;
  P4CombatCasterClass: TEObjectClass = TCombatSpellCaster;
  P4ImageAnimationClass: TEObjectClass = TImageSequenceAnimation;
  P4UnitSelectionClass: TEObjectClass = TUnitUserList;

resourcestring
  P4XResearchedRStr = '%s researched';
  P4XRemovedOutOfManaRStr = '%s removed (out of mana)';
  P4XRemovedRStr = '%s removed';
  P4XDispelledRStr = '%s dispelled';
  P4UndefinedRStr = 'Undefined';
  P4SelectTargetPartyForXRStr = 'Select target party for %s on map';
  P4CastXRStr = 'Cast %s';
  P4XCastingReadyRStr = '%s ready';
  P4RebuildXRStr = 'Rebuild %s';
  P4StructureRStr = 'Structure';
  P4NoRazedStructuresRStr = 'No razed structure found';
  P4BuildRoadRStr = 'Build Roads';
  P4CannotBuildUndergroundRStr = 'Cannot build %s underground';
  P4RoadsRStr = 'Roads';
  P4NotEnoughGoldRStr = 'Not enough gold.';
  P4ConstructRStr = 'Construct';
  P4AbilitiesRStr = 'Abilities';
  DominatedRStr = 'Dominated';
  DominateRStr = 'Dominate';
  CharmedRStr = 'Charmed';
  CharmRStr = 'Charm';
  SeducedRStr = 'Seduced';
  SeduceRStr = 'Seduce';
  PossessedRStr = 'Possessed';
  PossessRStr = 'Possess';
  WebRStr = 'Web';
  InvokeDeathRStr = 'Invoke Death';
  HealingRStr = 'Healing';
  { DispelMagicRStr is declared in the interface. }
  { DispelMagicFailedRStr is declared in the interface. }
  { XSpellsSuccessfullyDispelledRStr is declared in the interface. }
  SpellCastingRStr = 'Spell Casting';
  FlameThrowingRStr = 'Flame Throwing';
  { UsedRStr is declared in the interface. }
  SelectUnitForXRStr = 'Select unit for %s';
  { EntangleRStr is declared in the interface (557F8A68). }
  { TurnUndeadRStr is declared in the interface (557F7B94). }
  StrikeRStr = 'Strike';
  WallCrushingRStr = 'Wall Crushing';
  SelfDestructRStr = 'Self Destruct';
  RoundAttackRStr = 'Round Attack';
  LeadershipRStr = 'Leadership';
  NotEnoughCastingPointsRStr = 'Not enough channeling points';
  P4SpellWardBlocksCastRStr = 'Spell Ward locks all global enchantments';
  P4ExternalPowerRStr = 'External';
  CosmeticSurgeryRStr = 'Cosmagic Surgery';
  P4TransportUnitsRStr = 'Transport (%s units)';
  XIsOutOfSightRStr = '%s is out of sight';
  P4ManaRStr = 'Mana';
  DurationDaysRStr = '(%s/%s days)';
  DurationCombatTurnRStr = '(%s/%s turns)';
  DurationEntireCombatRStr = '(combat only)';
{ P5: AI, diplomacy, campaign and turn movement. }

type
  { ABI views for the still-unmarked EventLog/P2 override declarations.
    Never instantiated; EventLog size $18, JoinEventLog size $3C. }
  TP5EventLogABI = class(TEObject)
    FReserved: array[0..15] of Byte;
    procedure Slot4C; virtual; abstract;
    procedure Slot50; virtual; abstract;
    procedure Slot54; virtual; abstract;
    procedure Slot58; virtual; abstract;
    procedure Slot5C; virtual; abstract;
    procedure Slot60; virtual; abstract;
    procedure Slot64; virtual; abstract;
    procedure Slot68; virtual; abstract;
    procedure Slot6C; virtual; abstract;
    function Execute(Immediate, Auto: Boolean; Data, Done: Pointer): Boolean;
      virtual; abstract; { $70 }
  end;


{ TMPDID is declared with the shared engine globals. }

resourcestring
  { needs: P1 NotEnoughGoldRStr (5570719C, string resource 65215). }
  P5NotEnoughGoldRStr = 'Not enough gold.';
  GameRestartedRStr = 'Game Restarted';
  P5FinishedTheirTurnRStr = 'finished their turn';
  P5CannotCombineArmiesRStr = 'Cannot combine armies';
  P5CannotCombineTransportersRStr = 'Cannot combine two transporters';
  P5IndependentsAreMovingRStr = 'Independents are moving';
  P5PlayerIsMovingRStr = '%s is moving';
  P5YouAreBeingAttackedRStr = 'You''re being attacked!';
  P5XLeftTheGameRStr = '%s left the game!';
  P5ExplorationEnabledRStr = 'Exploration Enabled';
  P5ExplorationDisabledRStr = 'Exploration Disabled';
  P5FogEnabledRStr = 'Fog Enabled';
  P5FogDisabledRStr = 'Fog Disabled';
  P5SpellCheatEnabledRStr = 'All spells enabled';
  P5SpellCheatDisabledRStr = 'All spells disabled';
  P5FreeMovementEnabledRStr = 'Free movement enabled';
  P5FreeMovementDisabledRStr = 'Free movement disabled';



const P5DefaultMsgProc: Pointer = @RetrieveDefaultDiplomaticActionMessage;

resourcestring
  P5DeclareWarRStr = 'Declare war';
  P5OfferPeaceRStr = 'Offer peace';
  P5ProposeAllianceRStr = 'Propose alliance';
  P5SendMessageRStr = 'Send Message';
  P5ThreatenToAttackRStr = 'Threaten to attack';
  P5MakeTributeRStr = 'Make tribute';
  P5BreakAllianceRStr = 'Break alliance';
  P5SendMessageAsXRStr = 'Send message as %s';
  P5SuggestAllianceBreakWithYRStr = 'Suggest alliance break with %s';
  P5SuggestWarWithYRStr = 'Suggest war with %s';
  P5NotEnoughManaRStr = 'Not enough mana.';
  P5NoGoldManaSpecifiedRStr = 'No gold/mana specified';
  P5WarDeclaredRStr = 'War declared';
  P5AllianceBrokenRStr = 'Alliance broken';
  P5MessageSentRStr = 'Message sent';

const
  P5RaceColors: array[0..12] of TColor = ($00E03430, $0066A4FF, $00AFCB2C, $00FEDA87, $0060EF41, $0015FDFD, $00A5C1E4, $00F7FFFD, $00B370BC, $005050E9, $004266BB, $00797898, $00A8A8A8);

resourcestring
  P5WarRStr = 'War';
  P5PeaceOfferRStr = 'Peace offer';
  P5XRejectedRStr = '%s rejected';
  P5XAcceptedRStr = '%s accepted';
  P5XIgnoredRStr = '%s ignored';
  P5PeaceRStr = 'Peace';
  P5AllianceProposalRStr = 'Alliance proposal';
  P5MadeAllianceRStr = 'Made alliance';
  P5MessageRStr = 'Message';
  P5ThreatRStr = 'Threat';
  P5TributeRStr = 'Tribute';
  P5BreakAllianceSuggestionRStr = 'Break alliance suggestion';
  P5DeclareWarSuggestionRStr = 'Declare war suggestion';

const
  Player2GroupBehaviorTable: array[pbNormal..pbScorcher, 0..9] of TGroupBehavior =
    ((gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal),
     (gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive),
     (gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive),
     (gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand),
     (gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch));
  IndependentGroupBehaviorTable: array[TIndependentAIMode, 0..9] of TGroupBehavior =
    ((gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive),
     (gbPatrol,gbScout,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive),
     (gbPatrol,gbPatrol,gbScout,gbScout,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive),
     (gbPatrol,gbPatrol,gbScout,gbScout,gbSuicidal,gbSuicidal,gbRaid,gbPassive,gbPassive,gbPassive));

var
  DefenseSortGroupID: Integer; { $558FA0B4 }
  DefenseSortUnits: TUnitList; { $558FA0B0 }

resourcestring
  P5RoundXRStr = 'Round: %s';

const
  P5OppositeDirections: array[0..6] of Integer = (0,4,5,6,1,2,3);
  P5SideDirections: array[0..6, 0..1] of Integer =
    ((-1,-1),(6,2),(1,3),(2,4),(3,5),(4,6),(5,1));
  P5OddDirections: array[1..6, 0..2] of Byte =
    ((1,3,5),(3,1,5),(3,5,1),(5,3,1),(5,1,3),(1,5,3));
  P5EvenDirections: array[1..6, 0..2] of Byte =
    ((2,4,6),(4,2,6),(4,6,2),(6,4,2),(6,2,4),(2,6,4));

resourcestring
  P5SavingGameRStr = 'saving: %s';
  P5ErrorSavingRStr = 'Error saving: %s';


function TranslateRStr(const S: string): string;
begin
  if AoWEngine <> nil then
  begin
    Result := AoWEngine.TranslateRStr(S);
    Exit;
  end;
  Result := S;
end;
  { CombatDID is declared with the shared engine globals. }

constructor TCombatUnit.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FControlMode := [cmConquerObject];
  FUnitGFXResourceIndex := -1;
end;

destructor TCombatUnit.Destroy;
begin
  SetUnit(nil);
  inherited Destroy;
end;

class function TCombatUnit.ClassID: Integer;
begin Result := $202A1; end;

procedure TCombatUnit.Setup(A1: Byte; A2: Byte; A3: TAbstractUnit; A4: Byte; A5: Byte); { Near miss: Self uses ESI rather than EBX after three variants. }
begin
  FID := A1;
  FPosition := A4;
  SetCombatPlayer(A5);
  SetUnit(TAbstractUnit(A3));
end;

function TCombatUnit.GetVisibilityRange: Integer;
var
  Level: Integer;
  U: TAbstractUnit;
begin
  U := FUnit;
  if U <> nil then
  begin
    Level := TAbstractUnit(U).GetAbilityLevel($40);
    if Level <> 0 then
      Result := Level * 2 + 4
    else
      Result := 4;
    if (TCombat(FCombat).FExplorationSite = 1) and
       not TAbstractUnit(FUnit).GetAbilityEnabled($27) then
      Result := (Result + 1) div 2;
  end
  else Result := 0;
end;

procedure TCombatUnit.NewTurn(A1: Byte);
var
  U: TAbstractUnit;
begin
  inherited NewTurn(A1);
  U := FUnit;
  if U <> nil then U.TriggerNewCombatTurn(Self, A1);
end;

procedure TCombatUnit.NewRound;
begin inherited NewRound; end;

procedure TCombatUnit.CombatDone;
var
  U: TAbstractUnit;
begin
  inherited CombatDone;
  U := FUnit;
  if U <> nil then U.TriggerCombatDone(Self);
end;

function TCombatUnit.GetEnabled: Boolean;
begin
  Result := (FUnit <> nil) and ([csDestroyed, csFled] * FStatus = []) and
    not FDisabled;
end;

function TCombatUnit.GetLocked: Boolean;
begin
  Result := TAbstractUnit(FUnit).GetAbilityEnabled($5F) or
    TAbstractUnit(FUnit).GetAbilityEnabled($61) or
    TAbstractUnit(FUnit).GetAbilityEnabled($5C) or
    TAbstractUnit(FUnit).GetAbilityEnabled($5E) or
    TAbstractUnit(FUnit).GetAbilityEnabled($22);
end;

function TCombatUnit.WallCombatFeatures: TWallCombatFeatures;
begin Result := FWallCombatFeatures; end;

function TCombatUnit.ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes;
begin
  Result := FUnit.ExecuteCombatDamageEffects(TCombat(FCombat), A1);
end;

function TCombatUnit.ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes;
begin
  Result := FUnit.ExecuteDamageEffectsRole(A1);
end;

procedure TCombatUnit.UpdateWallCombatFeatures;
var U: TAbstractUnit;
begin
  U := FUnit;
  if (U <> nil) and not (csDestroyed in FStatus) then
  begin
    FWallCombatFeatures := U.GetWallCombatFeatures;
    if FUnit.GetAbilityEnabled($34) and
      TSpellCastingAbility(AoWHSSet.FAbilityControl.GetAbility($34)).CanCastBreachWallSpell(FUnit) then
      FWallCombatFeatures := FWallCombatFeatures + [wcWallBreaching];
  end
  else FWallCombatFeatures := [];
end;

procedure TCombatUnit.Activate(A1: Integer);
begin
  inherited Activate(A1);
  UpdateParty;
  UpdateWallCombatFeatures;
  UpdateUnitGFXResource;
end;

procedure TCombatUnit.Deactivate;
begin
  inherited Deactivate;
  UpdateParty;
  ReleaseUnitGFXResource;
end;

procedure TCombatUnit.Initialize(A1: Integer);
begin
  inherited Initialize(A1);
  if FUnit is TLeader then
    TByteList(TCombatData(TCombat(A1).FCombatData).F_CombatData_28).Add(FCombatPlayer);
end;

procedure TCombatUnit.Finalize(A1: TFinalizeMode); { Near miss: saved registers differ after three variants. }
var Party: TCombatParty; Placed: TArmyHS;
begin
  if not (csDestroyed in FStatus) and not FUnit.GetAbilityEnabled($82) and not FUnit.GetAbilityEnabled($83) then
  begin
    if A1 <> fmAll then
    begin
      if FPosition and $F <= 7 then
      begin
        Party := TCombatPartyList(TCombatData(TCombat(FCombat).FCombatData).FParties).GetParty(FPosition shr 4);
        if (Party <> nil) and (Shortint(Party.FPlayerIndex) = FCombatPlayer) then
        begin
          if AoWHSMap.FPlayers.GetPlayers(GetPlayer).FGameOverStatus = goLost then
          begin
            Placed := FUnit.Place(Party.F_CombatParty_0C, Party.F_CombatParty_10, Party.F_CombatParty_14, 0, [pmNeglectEmptyPlayerLocation]);
          end
          else Placed := FUnit.Place(Party.F_CombatParty_0C, Party.F_CombatParty_10, Party.F_CombatParty_14, GetPlayer, [pmNeglectEmptyPlayerLocation]);
          if Placed <> nil then Destroy;
        end;
      end;
    end
    else
    begin
      if FPosition and $F <= 7 then
        Party := TCombatPartyList(TCombatData(TCombat(FCombat).FCombatData).FParties).GetParty(FPosition shr 4)
      else Party := nil;
      if (Party = nil) or (Party.F_CombatParty_0C <> -1) then
      begin
        if AoWHSMap.FPlayers.GetPlayers(GetPlayer).FGameOverStatus = goLost then
          FUnit.Place(TCombatData(TCombat(FCombat).FCombatData).FX,
            TCombatData(TCombat(FCombat).FCombatData).FY,
            TCombatData(TCombat(FCombat).FCombatData).FL, 0, [pmScanArea])
        else
          FUnit.Place(TCombatData(TCombat(FCombat).FCombatData).FX,
            TCombatData(TCombat(FCombat).FCombatData).FY,
            TCombatData(TCombat(FCombat).FCombatData).FL, GetPlayer, [pmScanArea]);
        Destroy;
      end
      else if (Party <> nil) and (Shortint(Party.FPlayerIndex) <> FCombatPlayer) then
        FUnit.Place(TCombatData(TCombat(FCombat).FCombatData).FX,
          TCombatData(TCombat(FCombat).FCombatData).FY,
          TCombatData(TCombat(FCombat).FCombatData).FL, GetPlayer, [pmScanArea]);
    end;
  end
  else Destroy;
end;

procedure TCombatUnit.PlaySFX(A1: Byte);
begin
  case A1 of
    0: AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnit.GetUnitGFXResourceIndex).FSFXLibraries[2].Play(0);
    1: AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnit.GetUnitGFXResourceIndex).FSFXLibraries[2].Play(1);
    2: AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnit.GetUnitGFXResourceIndex).FSFXLibraries[3].Play(0);
    3: AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnit.GetUnitGFXResourceIndex).FSFXLibraries[4].Play(0);
  end;
end;

function TCombatUnit.GetMoves: Integer;
begin Result := TAbstractUnit(FUnit).GetMoves; end;

function TCombatUnit.GetAlignment: TAlignment;
begin Result := TAbstractUnit(FUnit).GetAlignment; end;

function TCombatUnit.GetAbilityOwner: TAbilityOwner;
begin Result := FUnit; end;

function TCombatUnit.GetAbilityEnabled(A1: Integer): Boolean;
begin
  if FUnit <> nil then Result := TAbstractUnit(FUnit).GetAbilityEnabled(A1) else Result := False;
end;

procedure TCombatUnit.SetAbilityEnabled(A1: Integer; A2: Boolean);
begin FUnit.SetAbSet(A1, Byte(A2)); end;

function TCombatUnit.GetAbilityLevel(A1: Integer): Integer;
begin Result := TAbstractUnit(FUnit).GetAbilityLevel(A1); end;

function TCombatUnit.GetAbilityCount: Integer;
begin
  if FUnit <> nil then Result := TAbstractUnit(FUnit).GetAbilityCount else Result := 0;
end;

function TCombatUnit.GetHits: Shortint; { Near miss: three variants retain a redundant move or different register. }
var U: TAbstractUnit;
begin
  U := TAbstractUnit(FUnit);
  if U <> nil then Result := FUnit.GetHits else Result := 0;
end;

function TCombatUnit.GetHitPoints: Shortint; { Near miss: three variants retain a redundant move or different register. }
var U: TAbstractUnit;
begin
  U := TAbstractUnit(FUnit);
  if U <> nil then Result := FUnit.GetHitPoints else Result := 0;
end;

procedure TCombatUnit.SetHitPoints(A1: Byte); { Near miss: three variants retain an extra nil-test move or different saved registers. }
var U: TAbstractUnit;
begin
  U := TAbstractUnit(FUnit);
  if U <> nil then FUnit.SetHitPoints(A1);
end;

procedure TCombatUnit.SetParty(Party: TCombatParty);
var P: TCombatParty;
begin
  if Party <> FParty then
  begin
    if (FParty <> nil) and (FUnit <> nil) then FUnit.SetOwner(nil);
    Pointer(FParty) := Pointer(Party);
    P := FParty;
    if (P <> nil) and (FUnit <> nil) then
    begin
      FUnit.SetOwner(TArmy(P.FArmy));
      TArmy(FParty.FArmy).UpdateFormation;
    end;
  end;
end;

procedure TCombatUnit.UpdateParty;
var Party: TCombatParty;
begin
  if csActivated in FStatus then
  begin
    Party := TCombatPartyList(TCombatData(TCombat(FCombat).FCombatData).FParties).GetParty(FPosition shr 4);
    if (Byte(FCombatPlayer) <> Party.FPlayerIndex) or (csDestroyed in FStatus) then Party := nil;
  end
  else Party := nil;
  SetParty(Party);
end;

procedure TCombatUnit.UpdateUnitGFXResource;
var Index: Integer; U: TAbstractUnit;
begin
  U := FUnit;
  if U <> nil then Index := U.GetUnitGFXResourceIndex else Index := -1;
  if Index <> FUnitGFXResourceIndex then
  begin
    ReleaseUnitGFXResource;
    if Index <> -1 then
    begin
      AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Index).AddRef;
      FUnitGFXResourceIndex := Index;
    end;
  end;
end;

procedure TCombatUnit.ReleaseUnitGFXResource;
var Index: Integer;
begin
  Index := FUnitGFXResourceIndex;
  if Index <> -1 then
  begin
    AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Index).Release;
    FUnitGFXResourceIndex := -1;
  end;
end;

procedure TCombatUnit.SetUnit(AUnit: TAbstractUnit);
var U: TAbstractUnit; Party: TCombatParty;
begin
  U := FUnit;
  if U <> AUnit then
  begin
    if U <> nil then
    begin
      Party := FParty;
      if (Party <> nil) and (FUnit.Owner = TArmy(Party.FArmy)) then FUnit.SetOwner(nil);
      FUnit.Release;
    end;
    FUnit := AUnit;
    U := FUnit;
    if U <> nil then
    begin
      U.AddRef;
      Party := FParty;
      if (Party <> nil) and not (csDestroyed in FStatus) then TArmy(Party.FArmy).AddUnit(FUnit);
    end;
  end;
  if csActivated in FStatus then UpdateUnitGFXResource;
end;

procedure TCombatUnit.ReadWrite(Stream: Engine.TEStorageStream);
var U: TAbstractUnit;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smRead, smTranslate] = [smRead] then
  begin
    Stream.rwCreateEObject(TEObject(U), nil, $14);
    SetUnit(U);
    if U <> nil then U.Release;
  end
  else Stream.rwCreateEObject(TEObject(FUnit), nil, $14);
  Stream.rwBool(FDisabled, $15);
end;

procedure TCombatUnit.ObjectDestroyed(A1: TCombatObject); { Near miss: cast-local register allocation differs after three variants. }
var C: TCombatUnit; U: TAbstractUnit;
begin
  inherited ObjectDestroyed(A1);
  if FDisabled and (A1 is TCombatUnit) then
  begin
    C := TCombatUnit(A1);
    U := C.FUnit;
    if (U <> nil) and U.GetTransporter and (C.FPosition shr 4 = FPosition shr 4) then DestroyObject;
  end;
end;

procedure TCombatUnit.GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer);
var U: TAbstractUnit; Abilities: TAbilityTypeList; Values: TAbilityDamageValues;
  I, V: Integer; Ability: TAbility;
begin
  if not (csDestroyed in FStatus) then
  begin
    U := FUnit;
    CV := 0;
    DV := 0;
    Abilities := AoWHSSet.FAbilityControl.FAbilitiesByType[atCombat];
    for I := Abilities.Count - 1 downto 0 do
    begin
      Ability := Abilities.GetAbility(I);
      if U.GetAbilityEnabled(Ability.FAbilityID) then
      begin
        Ability.tcGetDamageValueEx(Self, Target, Values);
        if Values.SourceDamage > 0 then
        begin
          V := (Values.SourceDamage * Values.SourceDamage) div (Values.TargetDamage + Values.SourceDamage);
          if V <= 0 then V := 1;
          if V > CV then CV := V;
          if Values.SourceDamage > DV then DV := Values.SourceDamage;
        end;
      end;
    end;
    if U.GetAbilityEnabled($34) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility($34);
      Ability.tcGetDamageValueEx(Self, Target, Values);
      if Values.SourceDamage > 0 then
      begin
        V := (Values.SourceDamage * Values.SourceDamage) div (Values.TargetDamage + Values.SourceDamage);
        if V <= 0 then V := 1;
        if V > CV then CV := V;
        if Values.SourceDamage > DV then DV := Values.SourceDamage;
      end;
    end;
  end
  else
  begin CV := 0; DV := 0; end;
end;

function TCombatUnit.GetTargetWallCV(Target: TCombatObject): Integer;
begin
  if (Target is TCombatUnit) and not (csDestroyed in Target.FStatus) then
    if TCombatPlayerList(FCombat.FCombatData.FPlayers).GetPlayers(FCombatPlayer).FSideIndex = 1 then
      Result := FUnit.GetCombatValue(TCombatUnit(Target).FUnit, 1)
    else Result := FUnit.GetCombatValue(TCombatUnit(Target).FUnit, 2)
  else Result := 0;
end;

function TCombatUnit.GetAttack: Shortint;
begin Result := TAbstractUnit(FUnit).GetAttack; end;

function TCombatUnit.GetDefense: Shortint;
begin Result := TAbstractUnit(FUnit).GetDefense; end;

function TCombatUnit.GetResistance: Shortint;
begin Result := TAbstractUnit(FUnit).GetResistance; end;

function TCombatUnit.GetDamage: Shortint;
begin Result := TAbstractUnit(FUnit).GetDamage; end;

function TCombatUnit.GetImmunityTypes: TDamageTypes;
begin Result := TAbstractUnit(FUnit).GetImmunityTypes + TCombatData(TCombat(FCombat).FCombatData).F_CombatData_22; end;

function TCombatUnit.GetProtectionTypes: TDamageTypes;
begin Result := TAbstractUnit(FUnit).GetProtectionTypes; end;

function TCombatUnit.GetExperience: Integer;
begin Result := TAbstractUnit(FUnit).GetExperience; end;

procedure TCombatUnit.SetExperience(A1: Integer);
begin FUnit.SetExperience(A1); end;

function TCombatUnit.GetLevel: Byte;
begin Result := TAbstractUnit(FUnit).GetUnitLevel; end;

function TCombatUnit.IDStr: string;
begin
  if TCombatPlayerList(TCombatData(TCombat(FCombat).FCombatData).FPlayers).GetPlayers(Shortint(FCombatPlayer)).FSideIndex = 0 then Result := 'A'
  else Result := 'D';
  if FUnit <> nil then Result := Result + '(' + IntToStr(FPosition) + ')=' + FUnit.GetName
  else Result := Result + '(' + IntToStr(FPosition) + ')';
end;

function TCombatUnit.SupportCombatMode(Modes: TCombatModes): Boolean;
var U: TAbstractUnit; I: Integer;
begin
  U := FUnit;
  if (U <> nil) and (U.GetHitPoints > 0) then
  begin
    Result := False;
    I := FUnit.GetAbilityCount;
    while (I <> 0) and not Result do
    begin
      Dec(I);
      Result := FUnit.GetAbilityEnabled(I) and
        (AoWHSSet.FAbilityControl.GetAbility(I).GetCombatMode(FUnit) in Modes);
    end;
  end
  else Result := False;
end;

procedure TCombatUnit.SetStatus(Status: TCombatObjectStatus);
begin
  if (csFled in Status) and not (csFled in FStatus) then
  begin
    FStatus := Status;
    TCombat(FCombat).CheckTerminate;
  end
  else FStatus := Status;
end;

procedure TCombatUnit.KillUnit;
begin FUnit.Killed; end;

procedure TCombatUnit.DestroyObject;
var U: TAbstractUnit; I: Integer;
begin
  if GetHitPoints <> 0 then SetHitPoints(0);
  FStatus := FStatus + [csDestroyed];
  U := FUnit;
  if U <> nil then
    for I := U.GetAbilityCount - 1 downto 0 do
      if FUnit.GetAbilityEnabled(I) then
        AoWHSSet.FAbilityControl.GetAbility(I).CombatObjectDestroyed(Self);
  if csDestroyed in FStatus then
  begin
    ResetTargets;
    if FUnit is TLeader then TByteList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_2C).Add(FCombatPlayer);
    TCombat(FCombat).ObjectDestroyed(Self);
    if FUnit <> nil then KillUnit;
  end;
end;

procedure TCombatUnit.Surrender;
begin
  if GetHitPoints <> 0 then SetHitPoints(0);
  FStatus := FStatus + [csDestroyed];
  ResetTargets;
  if FUnit is TLeader then TByteList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_2C).Add(FCombatPlayer);
  TCombat(FCombat).ObjectDestroyed(Self);
  if FUnit <> nil then KillUnit;
end;

function TCombatUnit.GetTargetPriority: Integer;
begin
  if FTargetPriorityInvalid then
  begin
    inherited GetTargetPriority;
    Inc(FTargetPriority, CommandingTargetPriority);
    Result := FTargetPriority;
    Exit;
  end;
  Result := FTargetPriority;
end;

function TCombatUnit.GetTargetStrength: Integer;
begin
  if FTargetStrengthInvalid then
  begin
    inherited GetTargetStrength;
    Inc(FTargetStrength, CommandingTargetStrength);
    Result := FTargetStrength;
    Exit;
  end;
  Result := FTargetStrength;
end;

function TCombatUnit.CommandingTargetPriority: Integer;
var I: Integer; Data: TCommandAbilityData;
const CommandAbilityIDs: array[0..2] of Integer = (29, 28, 148);
begin
  Result := 0;
  for I := 0 to 2 do
    if GetAbilityEnabled(CommandAbilityIDs[I]) then
    begin
      Data := TCommandAbilityData(FUnit.GetAbilityData(CommandAbilityIDs[I]));
      if Data <> nil then Inc(Result, Data.CommandingTargetPriority(TCombat(FCombat)));
    end;
end;

function TCombatUnit.CommandingTargetStrength: Integer;
var I: Integer; Data: TCommandAbilityData;
const CommandAbilityIDs: array[0..2] of Integer = (29, 28, 148);
begin
  Result := 0;
  for I := 0 to 2 do
    if GetAbilityEnabled(CommandAbilityIDs[I]) then
    begin
      Data := TCommandAbilityData(FUnit.GetAbilityData(CommandAbilityIDs[I]));
      if Data <> nil then Inc(Result, Data.CommandingTargetStrength(TCombat(FCombat)));
    end;
end;

procedure TCombatUnit.Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc);
var U: TAbstractUnit; Info: TP2UnitShowInfo;
begin
  U := FUnit;
  if U <> nil then
  begin
    Info.Direction := Byte(Direction);
    Info.Overlays := [uoHitPoints, uoRank, uoCombat];
    Info.Animation := uaStandStill;
    if [csDestroyed, csFled] * FStatus <> [] then
    begin
      Info.Frame := 0;
      Info.Looped := False;
    end
    else
    begin
      Info.Frame := Frame;
      Info.Looped := True;
    end;
    U.ShowEx(X,Y,Surface,Info);
    if csFled in FStatus then AoWHSSet.FCombatImages[7].Show(X+18,Y+10,Surface);
  end;
end;

function TCombatUnit.ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
var U: TAbstractUnit; Info: TP2UnitShowInfo;
begin
  U := FUnit;
  if U <> nil then
  begin
    Info.Direction := Byte(Direction);
    Info.Overlays := [uoHitPoints, uoRank, uoCombat];
    Info.Animation := uaAttack;
    Info.Frame := Frame;
    Info.Looped := False;
    Result := U.ShowEx(X,Y,Surface,Info);
  end
  else Result := -1;
end;

function TCombatUnit.ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
var U: TAbstractUnit; Info: TP2UnitShowInfo;
begin
  U := FUnit;
  if U <> nil then
  begin
    Info.Direction := Byte(Direction);
    Info.Overlays := [uoHitPoints, uoRank, uoCombat];
    Info.Animation := uaHit;
    Info.Frame := Frame;
    Info.Looped := False;
    Result := U.ShowEx(X,Y,Surface,Info);
  end
  else Result := -1;
end;

constructor TCombatWall.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPosition := $80;
  FControlMode := [];
end;

destructor TCombatWall.Destroy;
begin inherited Destroy; end;

class function TCombatWall.ClassID: Integer;
begin Result := $202AF; end;

function TCombatWall.GetTargetPriority: Integer;
var I, Count: Integer; Obj: TCombatObject;
begin
  if FTargetPriorityInvalid then
  begin
    Count := 0;
    for I := TQuadItemList(FTargetedBy).Count - 1 downto 0 do
      if TQuadItemList(FTargetedBy).List^[I].B = 0 then Inc(Count);
    FTargetPriority := 0;
    for I := TCombatSide(TCombat(FCombat).FSides[csDefender]).Count - 1 downto 0 do
    begin
      Obj := TCombatSide(TCombat(FCombat).FSides[csDefender]).GetObjects(I);
      Inc(FTargetPriority, Obj.FIncomingCombatValue - Obj.FIncomingWallCombatValue);
    end;
    FTargetPriority := (Count + 2) * FTargetPriority;
    FTargetPriorityInvalid := False;
  end;
  Result := FTargetPriority;
end;

function TCombatWall.GetTargetStrength: Integer;
begin
  if not FLocked then
    if not TCombatData(TCombat(FCombat).FCombatData).FWallBreached then Result := 10
    else Result := 1
  else Result := 0;
end;

function TCombatWall.fcRoundDistance: Integer;
begin Result := 0; end;

procedure TCombatWall.Setup(A1: Byte; A2: Byte; A3: Byte);
begin
  FID := A1;
  FWallType := A2;
  FHitPoints := GetHits;
  SetCombatPlayer(Byte(A3));
end;

procedure TCombatWall.Activate(A1: Integer);
begin
  inherited Activate(A1);
  TCombatData(TCombat(A1).FCombatData).FWall := Self;
end;

procedure TCombatWall.Deactivate;
begin
  TCombatData(TCombat(FCombat).FCombatData).FWall := nil;
  inherited Deactivate;
end;

procedure TCombatWall.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FWallType, 1, $14);
  Stream.rwByte(FHitPoints, $15);
end;

function TCombatWall.GetDefense: Shortint;
begin Result := 0; end;

function TCombatWall.GetResistance: Shortint;
begin Result := 3; end;

function TCombatWall.IDStr: string;
begin Result := 'Wall'; end;

function TCombatWall.GetHits: Shortint;
begin if FWallType = 2 then Result := 10 else Result := 5; end;

function TCombatWall.GetHitPoints: Shortint;
begin Result := FHitPoints; end;

function TCombatWall.GetImmunityTypes: TDamageTypes;
begin
  Result := [dtWall];
  Result := [Low(TDamageType)..High(TDamageType)] - Result;
end;

function TCombatWall.GetLocked: Boolean;
begin Result := FLocked; end;

procedure TCombatWall.SetHitPoints(A1: Byte);
begin FHitPoints := A1; end;

procedure TCombatWall.DestroyObject;
begin
  inherited DestroyObject;
  TCombatData(TCombat(FCombat).FCombatData).FWallBreached := True;
end;

procedure TCombatWall.Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc);
begin
  case FWallType of
    1: AoWHSSet.FCombatImages[21].Show(X+15,Y+5,Surface);
    2: AoWHSSet.FCombatImages[22].Show(X+15,Y+5,Surface);
  end;
  ShowHitPcnt(X,Y-10,Surface,HitPointsToHitPcnt(FHitPoints,GetHits));
end;

function TCombatWall.ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Show(Frame,Direction,X,Y,Surface); Result := 0; end;

function TCombatWall.ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Show(Frame,Direction,X,Y,Surface); Result := 0; end;

procedure P3InitializeHitProbabilities;
var I: Integer;
begin
  for I := 0 to 19 do P3HitProbabilities[I] := (20 - I) * 0.05;
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

function DMDCtoDV(Damage, AttackDefense: Integer): Integer; { Near miss: LEA versus ADD and INC after three variants. }
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
      Threshold := Threshold + ((((Damage - 1) * Threshold * Threshold + (Threshold + 19)) div
        (Threshold + 19)) shr 1) + 1;
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

function P3LimitedDamage(Attack, Defense, Damage: Integer): Integer;
begin
  if Defense > 10 then Defense := 10;
  Result := (Attack * Defense * Damage) div 2;
end;

constructor TCombatObject.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargets := TQuadItemList.Create;
  FTargetedBy := TQuadItemList.Create;
  FCombatPlayer := -1;
end;

destructor TCombatObject.Destroy;
begin
  if csActivated in FStatus then Deactivate;
  FTargets.Free;
  FTargetedBy.Free;
  inherited Destroy;
end;

procedure TCombatObject.TargetsChanged;
begin FTargetPriorityInvalid := True; FTargetStrengthInvalid := True; end;

procedure TCombatObject.AddTarget(Target: TCombatObject; CV, WallCV, DV: Integer);
begin










































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































  Assert(FTargets.IndexOfItemA(Integer(Target)) = -1, 'target already exists use update target');
  Inc(FCombatValue, CV);
  Inc(FWallCombatValue, WallCV);
  FTargets.AddABCD(Integer(Target), CV, WallCV, DV);
  Target.FTargetedBy.AddABCD(Integer(Self), CV, WallCV, DV);
  Inc(Target.FIncomingCombatValue, CV);
  Inc(Target.FIncomingWallCombatValue, WallCV);
  if CV > 0 then
  begin Inc(FTargetCount); Inc(Target.FAttackerCount); end;
  if WallCV > 0 then
  begin Inc(FWallTargetCount); Inc(Target.FWallAttackerCount); end;
  TargetsChanged;
  Target.TargetsChanged;
end;

procedure TCombatObject.DeleteTarget(Index: Integer);
var Target: TCombatObject; CV, DV: Integer;
begin
  if Index <> -1 then
  begin
    Target := TCombatObject(FTargets.List^[Index].A);
    CV := FTargets.List^[Index].B;
    DV := FTargets.List^[Index].C;
    Dec(FCombatValue, CV);
    Dec(FWallCombatValue, DV);
    FTargets.Delete(Index);
    if CV > 0 then Dec(FTargetCount);
    if DV > 0 then Dec(FWallTargetCount);
    TargetsChanged;
    Index := Target.FTargetedBy.IndexOfItemA(Integer(Self));
    if Index <> -1 then
    begin
      Dec(Target.FIncomingCombatValue, Target.FTargetedBy.List^[Index].B);
      { Original bug: FIncomingWallCombatValue is not decremented. }
      Target.FTargetedBy.Delete(Index);
      if CV > 0 then Dec(Target.FAttackerCount);
      if DV > 0 then Dec(Target.FWallAttackerCount);
      Target.TargetsChanged;
    end;
  end;
end;

procedure TCombatObject.RemoveTarget(Target: TCombatObject);
begin DeleteTarget(FTargets.IndexOfItemA(Integer(Target))); end;

procedure TCombatObject.ResetTargets;
var I: Integer;
begin
  for I := FTargets.Count - 1 downto 0 do DeleteTarget(I);
end;

procedure TCombatObject.GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer);
begin CV := 0; DV := 0; end;

function TCombatObject.GetTargetWallCV(Target: TCombatObject): Integer;
begin Result := 0; end;

function TCombatObject.GetTargetPriority: Integer;
var I, CV: Integer; Target: TCombatObject; Count: Integer;
begin
  if FTargetPriorityInvalid then
  begin
    FTargetPriority := 0;
    Count := 0;
    for I := FTargetedBy.Count - 1 downto 0 do
      if FTargetedBy.List^[I].B = 0 then Inc(Count);
    for I := FTargets.Count - 1 downto 0 do
    begin
      CV := FTargets.List^[I].B;
      if CV <> 0 then
      begin
        Target := TCombatObject(FTargets.List^[I].A);
        CV := Round((CV * CV) / Target.FIncomingCombatValue);
        Inc(FTargetPriority, CV);
      end;
    end;
    FTargetPriority := (Count + 2) * FTargetPriority;
    I := FTargetedBy.Count;
    { Original bug: the normalized priority is stored in FTargetStrength. }
    if I <> 0 then FTargetStrength := FTargetPriority div I
    else FTargetStrength := 0;
    FTargetPriorityInvalid := False;
  end;
  Result := FTargetPriority;
end;

function TCombatObject.GetTargetStrength: Integer;
var I: Integer;
begin
  if FTargetStrengthInvalid then
  begin
    FTargetStrength := 0;
    for I := TQuadItemList(FTargets).Count - 1 downto 0 do
      Inc(FTargetStrength, TQuadItemList(FTargets).List^[I].D);
    if FTargetStrength <> 0 then FTargetStrength := FTargetStrength div TQuadItemList(FTargets).Count;
    FTargetStrengthInvalid := False;
    Result := FTargetStrength;
    Exit;
  end;
  Result := FTargetStrength;
end;

procedure TCombatObject.SetupTargets;
var I, CV, DV, WallCV: Integer; Target: TCombatObject; Side: TCombatSide;
begin
  Side := FCombat.FSides[GetOpponentSide];
  for I := Side.Count - 1 downto 0 do
  begin
    Target := Side.GetObjects(I);
    if not (csDestroyed in Target.FStatus) then
    begin
      GetTargetCVDV(Target, CV, DV);
      if TCombatData(FCombat.FCombatData).FWallType <> 0 then WallCV := GetTargetWallCV(Target)
      else WallCV := 0;
      AddTarget(Target, CV, WallCV, DV);
    end;
  end;
end;

procedure TCombatObject.ObjectSideChanged(A1: TCombatObject);
var CV, DV, WallCV: Integer;
begin
  if A1.GetSide <> GetSide then
  begin
    GetTargetCVDV(A1, CV, DV);
    if FCombat.FCombatData.FWallType <> 0 then WallCV := GetTargetWallCV(A1)
    else WallCV := 0;
    AddTarget(A1, CV, WallCV, DV);
  end
  else RemoveTarget(A1);
end;

function TCombatObject.fcExecute(A1: Integer): Boolean;
begin Result := False; end;

function TCombatObject.fcBehindWall: Boolean;
begin Result := False; end;

function TCombatObject.fcWallInBetween(A1: Byte): Boolean;
begin Result := False; end;

function TCombatObject.fcRoundDistance: Integer;
begin Result := 0; end;

function TCombatObject.GetVisibilityRange: Integer;
begin Result := 0; end;

procedure TCombatObject.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FPosition, $A);
  Stream.rwByte(Byte(FCombatPlayer), $C);
  Stream.rwData(FStatus, 1, $D);
  Stream.rwData(FID, 1, $E);
  if smRead in Stream.StorageMode then FStatus := FStatus - [csActivated];
end;

function TCombatObject.WallCombatFeatures: TWallCombatFeatures;
begin Result := []; end;

function TCombatObject.GetEnabled: Boolean;
begin Result := [csDestroyed, csFled] * FStatus = []; end;

function TCombatObject.GetSide: TCombatSideIndex;
var Player: Shortint;
begin
  Player := Shortint(FCombatPlayer);
  if Player <> -1 then
    Result := TCombatSideIndex(TCombatPlayerList(TCombatData(TCombat(FCombat).FCombatData).FPlayers).GetPlayers(Player).FSideIndex)
  else Result := csNeutral;
end;

function TCombatObject.GetOpponentSide: TCombatSideIndex;
var Player: Shortint;
begin
  Player := Shortint(FCombatPlayer);
  if Player <> -1 then
    Result := TCombatSideIndex(TCombatPlayerList(TCombatData(TCombat(FCombat).FCombatData).FPlayers).GetPlayers(Player).FSideIndex xor 1)
  else Result := csNeutral;
end;

procedure TCombatObject.NewTurn(A1: Byte);
begin if A1 = Byte(FCombatPlayer) then FStatus := FStatus - [csTurnDone]; end;

procedure TCombatObject.NewRound;
begin end;

procedure TCombatObject.CombatDone;
begin end;

procedure TCombatObject.TurnDone;
var A: TCombatObjectTurnDoneCA;
begin
  A := TCombatObjectTurnDoneCA.Create(nil);
  A.F_CombatObjectTurnDoneCA_0C := FID;
  TCombat(FCombat).ExecuteCombatAction(A);
  A.Release;
end;

procedure TCombatObject.Activate(A1: Integer);
var Player: Byte; Combat: TCombat;
begin
  FCombat := TCombat(A1);
  FStatus := FStatus + [csActivated];
  Player := FCombatPlayer;
  if Player <> $FF then
  begin
    Combat := FCombat;
    Combat.FSides[TCombatSideIndex(TCombatPlayerList(TCombatData(Combat.FCombatData).FPlayers).GetPlayers(Player).FSideIndex)].AddChild(Self);
  end;
end;

procedure TCombatObject.Deactivate;
var Player: Byte; Combat: TCombat;
begin
  FStatus := FStatus - [csActivated];
  Player := FCombatPlayer;
  if Player <> $FF then
  begin
    Combat := FCombat;
    Combat.FSides[TCombatSideIndex(TCombatPlayerList(TCombatData(Combat.FCombatData).FPlayers).GetPlayers(Player).FSideIndex)].RemoveChild(Self);
  end;
end;

procedure TCombatObject.Initialize(A1: Integer);
begin FCombat := TCombat(A1); end;

procedure TCombatObject.Finalize(A1: TFinalizeMode);
begin Destroy; end;

procedure TCombatObject.PlaySFX(A1: Byte);
begin end;

function TCombatObject.GetLocked: Boolean;
begin Result := False; end;

procedure TCombatObject.SetCombatPlayer(Player: Byte);
var ChangedSide: Boolean; Combat, NewCombat: TCombat;
begin
  if csActivated in FStatus then
  begin
    ChangedSide := (Player <> $FF) and
      (TCombatSideIndex(TCombatPlayerList(TCombatData(FCombat.FCombatData).FPlayers).GetPlayers(Player).FSideIndex) <> GetSide);
    if FCombatPlayer <> -1 then
    begin
      Combat := FCombat;
      Combat.FSides[TCombatSideIndex(TCombatPlayerList(TCombatData(Combat.FCombatData).FPlayers).GetPlayers(FCombatPlayer).FSideIndex)].RemoveChild(Self);
    end;
    FCombatPlayer := Player;
    if FCombatPlayer <> -1 then
    begin
      NewCombat := FCombat;
      NewCombat.FSides[TCombatSideIndex(TCombatPlayerList(TCombatData(NewCombat.FCombatData).FPlayers).GetPlayers(FCombatPlayer).FSideIndex)].AddChild(Self);
    end;
    if ChangedSide then
    begin
      ResetTargets;
      SetupTargets;
      FCombat.ObjectSideChanged(Self);
    end;
  end
  else FCombatPlayer := Player;
end;

function TCombatObject.GetAttack: Shortint;
begin Result := 0; end;

function TCombatObject.GetDefense: Shortint;
begin Result := 0; end;

function TCombatObject.GetResistance: Shortint;
begin Result := 0; end;

function TCombatObject.GetDamage: Shortint;
begin Result := 0; end;

function TCombatObject.GetImmunityTypes: TDamageTypes;
begin Result := []; end;

function TCombatObject.GetProtectionTypes: TDamageTypes;
begin Result := []; end;

function TCombatObject.GetMoves: Integer;
begin Result := 0; end;

function TCombatObject.GetHits: Shortint;
begin Result := 0; end;

procedure TCombatObject.SetHitPoints(A1: Byte);
begin end;

function TCombatObject.GetHitPoints: Shortint;
begin Result := 0; end;

function TCombatObject.GetExperience: Integer;
begin Result := 0; end;

procedure TCombatObject.SetExperience(A1: Integer);
begin end;

function TCombatObject.GetLevel: Byte;
begin Result := 0; end;

function TCombatObject.IDStr: string;
begin Result := 'TCombatObject'; end;

function TCombatObject.GetAlignment: TAlignment;
begin Result := alNone; end;

function TCombatObject.GetAbilityOwner: TAbilityOwner;
begin Result := nil; end;

function TCombatObject.GetAbilityEnabled(A1: Integer): Boolean;
begin Result := False; end;

procedure TCombatObject.SetAbilityEnabled(A1: Integer; A2: Boolean);
begin end;

function TCombatObject.GetAbilityLevel(A1: Integer): Integer;
begin Result := 0; end;

function TCombatObject.GetAbilityCount: Integer;
begin Result := 0; end;

function TCombatObject.GetPlayer: Shortint;
var Player: Byte;
begin
  Player := FCombatPlayer;
  if Player <> $FF then Result := Shortint(TCombatPlayerList(TCombatData(FCombat.FCombatData).FPlayers).GetPlayers(Player).FPlayer)
  else Result := -1;
end;

function TCombatObject.GetPlayerIR: Shortint;
var Player: Byte;
begin
  Player := FCombatPlayer;
  if Player <> $FF then Result := Shortint(TCombatPlayerList(TCombatData(FCombat.FCombatData).FPlayers).GetPlayers(Player).FIndependentRelation)
  else Result := -1;
end;

procedure TCombatObject.ObjectDestroyed(A1: TCombatObject);
begin
  if A1.GetSide <> GetSide then RemoveTarget(A1);
end;

function TCombatObject.SupportCombatMode(Modes: TCombatModes): Boolean;
begin Result := False; end;

function TCombatObject.GetOptimalDamageType(Types: TDamageTypes): TDamageType;
var Available, Protection: TDamageTypes;
begin
  Result := dtNone;
  Available := Types - GetImmunityTypes;
  if Available <> [] then
  begin
    Protection := GetProtectionTypes;
    if (Protection = []) or (Available - Protection = []) then
      while not (Result in Available) do Dec(Result)
    else
      while not (Result in Available) or (Result in Protection) do Dec(Result);
  end;
end;

function TCombatObject.ExecuteDamageRole(A1: Integer; A2: Integer; A3: TDamageTypes): Integer;
var Types: TDamageTypes; Attack: Integer;
begin
  Result := 0;
  Types := A3 - GetImmunityTypes;
  if Types <> [] then
  begin
    Attack := A1 - GetDefense;
    Result := AoWE.ExecuteDamageRole(A2, Attack);
    if Types - GetProtectionTypes = [] then Result := (Result + 1) div 2;
  end;
end;

function TCombatObject.ExecuteDamageRoleEx(A1: Integer; A2: Integer; A3: TDamageTypes; A4: Byte): Integer;
var Types: TDamageTypes; Attack: Integer;
begin
  Result := 0;
  Types := A3 - GetImmunityTypes;
  if Types <> [] then
  begin
    if A4 = 1 then Attack := A1 - GetResistance else Attack := A1 - GetDefense;
    Result := AoWE.ExecuteDamageRole(A2, Attack);
    if Types - GetProtectionTypes = [] then Result := (Result + 1) div 2;
  end;
end;

function TCombatObject.ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes;
begin Result := []; end;

function TCombatObject.ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes;
begin Result := []; end;

function TCombatObject.DoDamage(A1: TCombatObject; A2: Integer): Integer;
begin
  if (A2 <> 0) and TCombatObject(A1).GetEnabled then
  begin
    Result := TCombatObject(A1).ExecuteDamage(A2);
    if (csDestroyed in TCombatObject(A1).FStatus) and
      not TCombatObject(A1).GetAbilityEnabled($81) and
      not TCombatObject(A1).GetAbilityEnabled($80) then
      SetExperience(GetExperience + TCombatObject(A1).GetLevel);
  end
  else Result := 0;
end;

procedure TCombatObject.DestroyObject;
var I: Integer;
begin
  SetHitPoints(0);
  FStatus := FStatus + [csDestroyed];
  for I := GetAbilityCount - 1 downto 0 do
    if GetAbilityEnabled(I) then AoWHSSet.FAbilityControl.GetAbility(I).CombatObjectDestroyed(Self);
  if csDestroyed in FStatus then
  begin
    ResetTargets;
    FCombat.ObjectDestroyed(Self);
  end;
end;

procedure TCombatObject.Surrender;
begin
  SetHitPoints(0);
  FStatus := FStatus + [csDestroyed];
  ResetTargets;
  FCombat.ObjectDestroyed(Self);
end;

function TCombatObject.ExecuteDamage(A1: Integer): Integer;
var Hits: Integer;
begin












































































  Assert((A1 >= 0) and (A1 < 50), 'Invalid Damage Value (TCombatUnit.ExecuteDamage)');
  Hits := GetHitPoints;
  if Hits < A1 then Result := Hits else Result := A1;
  SetHitPoints(Hits - Result);
  if A1 <> 0 then FStatus := FStatus + [csDamaged];
  if (Result <> 0) and (GetHitPoints = 0) then DestroyObject;
end;

procedure TCombatObject.Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc);
begin end;

function TCombatObject.ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Result := 0; end;

function TCombatObject.ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Result := 0; end;

constructor TCombatSide.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

procedure TCombatSide.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); end;

destructor TCombatSide.Destroy;
begin inherited Destroy; end;

function TCombatSide.GetObjects(A1: Integer): TCombatObject;
begin Result := TCombatObject(FChildren.List^[A1]); end;

function TCombatSide.IndexOfID(A1: Integer): Integer;
begin
  for Result := Count - 1 downto 0 do
    if TCombatObject(FChildren.List^[Result]).FID = A1 then Exit;
  Result := -1;
end;

function TCombatSide.GetDestroyedObjects: Integer;
var I: Integer;
begin
  Result := 0;
  for I := Count - 1 downto 0 do
    if csDestroyed in TCombatObject(FChildren.List^[I]).FStatus then Inc(Result);
end;

function TCombatSide.GetUndestroyedConquerObjects: Integer;
var I: Integer; Obj: TCombatObject;
begin
  Result := 0;
  for I := Count - 1 downto 0 do
  begin
    Obj := TCombatObject(FChildren.List^[I]);
    if ([csDestroyed, csFled] * Obj.FStatus = []) and
      (cmConquerObject in Obj.FControlMode) then Inc(Result);
  end;
end;

procedure TCombatSide.OutputDebugInfo;
var I: Integer; S: string;
begin
  if FSideIndex = 0 then AoWEngine.OutputDebugMessage(CombatDID, '--- Combat Side Attacker ---')
  else AoWEngine.OutputDebugMessage(CombatDID, '--- Combat Side Defender ---');
  for I := 0 to FChildren.Count - 1 do
  begin
    S := '(' + IntToStr(I) + '):' + GetObjects(I).IDStr + ' (Priority:' +
      IntToStr(GetObjects(I).GetTargetPriority) + '/Strength:' +
      IntToStr(GetObjects(I).GetTargetStrength) + ')';
    AoWEngine.OutputDebugMessage(CombatDID, S);
  end;
end;

procedure TCombatSide.UpdateSettings;
var I, N: Integer; Obj: TCombatObject;
begin
  FStrength := 0;
  FConquerCount := 0;
  for I := FChildren.Count - 1 downto 0 do
  begin
    Obj := TCombatObject(FChildren.List^[I]);
    N := TQuadItemList(Obj.FTargets).Count;
    if N > 0 then Inc(FStrength, Obj.FCombatValue div N);
    if (TQuadItemList(Obj.FTargetedBy).Count > 0) and
      (Obj.FAttackerCount = 0) then Inc(FConquerCount);
  end;
end;

constructor TCombat.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FExecutedEvents := TEventList.Create;
  FSides[csAttacker] := TCombatSide.Create(nil);
  FSides[csDefender] := TCombatSide.Create(nil);
  TCombatSide(FSides[csAttacker]).FSideIndex := 0;
  TCombatSide(FSides[csDefender]).FSideIndex := 1;
  TCombatSide(FSides[csAttacker]).FOpponent := TCombatSide(FSides[csDefender]);
  TCombatSide(FSides[csDefender]).FOpponent := TCombatSide(FSides[csAttacker]);
  FCombatData := TCombatData.Create(nil);
  FLogbook := TCombatLogbook.Create(nil);
  Clear;
end;

destructor TCombat.Destroy;
begin
  if cActivated in FStatus then Deactivate;
  if cExecuting in FStatus then Finalize;
  TObject(FExecutedEvents).Free;
  TObject(FSides[csAttacker]).Free;
  TObject(FSides[csDefender]).Free;
  TObject(FCombatData).Free;
  TCombatLogbook(FLogbook).Release;
  inherited Destroy;
end;

function TCombat.GetLogCombatActions: Boolean;
begin Result := cLogCombatActions in FStatus; end;

procedure TCombat.SetLogCombatActions(A1: Byte);
begin
  if A1 <> 0 then FStatus := FStatus + [cLogCombatActions]
  else FStatus := FStatus - [cLogCombatActions];
end;

procedure TCombat.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(TEObject(FSides[csAttacker]), $0A);
  Stream.rwEObject(TEObject(FSides[csDefender]), $0B);
  Stream.rwCreateEObject(TEObject(FLogbook), nil, $0C);
  Stream.rwEObject(TEObject(FCombatData), $0D);
end;

function TCombat.GetRound: Integer;
begin Result := TCombatData(FCombatData).FRound; end;

procedure TCombat.ExecuteCombatAction(A1: TCombatAction);
begin
  if cLogCombatActions in FStatus then TCombatActionList(TCombatLogbook(FLogbook).FActions).AddChild(TCombatAction(A1));
  TCombatAction(A1).Execute(Self);
end;

function TCombat.PlayerTypeInvolved(Types: TPlayerTypes): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 0 to TCombatPartyList(TCombatData(FCombatData).FParties).Count - 1 do
    if TCombatPartyList(TCombatData(FCombatData).FParties).GetParty(I) <> nil then
      if AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(TCombatData(FCombatData).FPlayers).GetPlayers(
        Shortint(TCombatPartyList(TCombatData(FCombatData).FParties).GetParty(I).FPlayerIndex)).FPlayer)).FPlayerType in Types then Result := True;
end;

function TCombat.CreateUniqueCOID: Byte;
begin Result := FNextCOID; Inc(FNextCOID); end;

procedure TCombat.Clear;
begin
  inherited Clear;
  TCombatLogbook(FLogbook).Clear;
  FNextCOID := 1;
  TCombatData(FCombatData).Clear;
  FStatus := [];
end;

function TCombat.Setup(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Byte; A7: Byte; A8: Integer; A9: Integer; A10: Integer; A11: Boolean): Boolean;
var Data: TCombatData;
begin
  Clear;
  if A11 then FStatus := FStatus + [cLogCombatActions]
  else FStatus := FStatus - [cLogCombatActions];
  Data := FCombatData;
  Data.FX := A8;
  Data.FY := A9;
  Data.FL := A10;
  Data.FAttackerX := A3;
  Data.FAttackerY := A4;
  Data.FAttackerL := A5;
  Data.FAttackerPlayer := AddCombatPlayer(A1, A2, csAttacker);
  Data.FDefenderPlayer := AddCombatPlayer(A6, A7, csDefender);
  Data.F_CombatData_20[0] := AoWHSMap.MapContainer.GetField(Data.FX, Data.FY, Data.FL).TerrainType;
  Data.F_CombatData_20[1] := AoWHSMap.MapContainer.GetField(Data.FX, Data.FY, Data.FL).OverlayType;
  Result := True;
end;

function TCombat.CreateCombatUnit: TCombatUnit;
begin
  Result := TFastCombatUnit.Create(nil);
  TCombatUnit(Result).FID := CreateUniqueCOID;
end;

procedure TCombat.NewRound;
var A: TNewCombatRoundCA;
begin
  A := TNewCombatRoundCA.Create(nil);
  ExecuteCombatAction(A);
  A.Release;
end;

procedure TCombat.UpdateSidesSettings;
begin TCombatSide(FSides[csAttacker]).UpdateSettings; TCombatSide(FSides[csDefender]).UpdateSettings; end;

procedure TCombat.NewTurn(A1: Byte);
var A: TNewCombatTurnCA;
begin
  A := TNewCombatTurnCA.Create(nil);
  A.F_NewCombatTurnCA_0C := A1;
  ExecuteCombatAction(A);
  A.Release;
  UpdateSidesSettings;
end;

procedure TCombat.NextTurn;
var I: Integer;
begin
  if TByteList(TCombatData(FCombatData).FTurnOrder).Count <> 0 then
  begin
    I := TByteList(TCombatData(FCombatData).FTurnOrder).IndexOf(TCombatData(FCombatData).FCurrentPlayer) + 1;
    if I >= TByteList(TCombatData(FCombatData).FTurnOrder).Count then I := 0;
    NewTurn(TByteList(TCombatData(FCombatData).FTurnOrder)[I]);
  end;
end;

procedure TCombat.Terminate;
begin
  if not FTerminated then
  begin
    FTerminated := True;
    if Assigned(FOnTerminated) then FOnTerminated(Self);
  end;
end;

procedure TCombat.CheckTerminate;
begin
  if not FTerminated then
    if (TCombatSide(FSides[csAttacker]).GetUndestroyedConquerObjects = 0) or
      (TCombatSide(FSides[csDefender]).GetUndestroyedConquerObjects = 0) or
      (TByteList(TCombatData(FCombatData).F_CombatData_2C).Count <> 0) then Terminate;
end;

procedure TCombat.ObjectSideChanged(A1: TCombatObject);
var I: Integer;
begin
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    if not (csDestroyed in A1.FStatus) then
      TCombatData(FCombatData).GetObjects(I).ObjectSideChanged(A1);
  CheckTerminate;
end;

procedure TCombat.ObjectDestroyed(A1: TCombatObject);
var I: Integer;
begin
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    TCombatData(FCombatData).GetObjects(I).ObjectDestroyed(A1);
  TEventList(FExecutedEvents).TriggerNotifyEvents(Self);
  CheckTerminate;
end;

procedure TCombat.SetLogbookHeader(A1: string);
var A: TUpdateHeaderCA;
begin
  A := TUpdateHeaderCA.Create(nil);
  A.F_UpdateHeaderCA_0C := A1;
  ExecuteCombatAction(A);
  A.Release;
end;

procedure TCombat.AddAdjacentArmies;
var Data: TCombatData; Level: TMapLevel; Walk: THNWalkData;
    ArmyHS: TArmyHS; Side: TCombatSideIndex;
begin
  Data := FCombatData;
  Level := AoWHSMap.MapContainer.GetMapLevel(Data.FL);
  InitHNWalk(Walk, Data.FX, Data.FY, 0);
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      ArmyHS := TArmyHS(Level.GetField(Walk.X, Walk.Y).FindOwnedChild($20217));
      if ArmyHS <> nil then
      begin
        if Walk.HN <> 0 then
          Side := GetCombatSide(
            TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer,
            TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FIndependentRelation,
            TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer,
            TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FIndependentRelation,
            ArmyHS.FArmy.FPlayer, ArmyHS.FArmy.FIndependentRelation)
        else Side := csDefender;
        if Side <> csNeutral then
          AddArmy(ArmyHS.FArmy, Side, Walk.X, Walk.Y, Data.FL);
      end
      else if Walk.HN = 0 then
        AddEmptyArmy(
          TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer,
          TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FIndependentRelation,
          Walk.X, Walk.Y, Data.FL);
    end;
    WalkToNextHN(Walk);
  end;
end;

function TCombat.GetPartyPosition(X, Y, Layer: Integer): Byte;
var Data: TCombatData;
begin
  Data := TCombatData(FCombatData);
  if (Layer = Data.FL) and (dHXtoRad(Data.FX,Data.FY,X,Y) <= 1) then
    Result := dHXtoHNfast(Data.FX,Data.FY,X,Y)
  else Result := 7;
end;

function TCombat.CreateCombatPlayer: TCombatPlayer;
begin Result := TCombatPlayer.Create(nil); end;

function TCombat.AddCombatPlayer(A1: Byte; A2: Byte; A3: TCombatSideIndex): Byte;
var Player: TCombatPlayer;
begin
  Player := TCombatPlayer(CreateCombatPlayer);
  Player.SetOwner(TCombatPlayerList(FCombatData.FPlayers));
  Player.FPlayer := A1;
  Player.FIndependentRelation := A2;
  Player.FSideIndex := Ord(A3);
  Result := TCombatPlayerList(FCombatData.FPlayers).Count - 1;
end;

function TCombat.AddArmy(A1: TArmy; A2: TCombatSideIndex; A3: Integer; A4: Integer; A5: Integer): TCombatParty; { Near miss: three variants keep the combat data in EBX instead of ESI. }
var Party: TCombatParty; Valid, Transport: Boolean; Player, Position: Byte;
    Index, I: Integer; UnitObj: TCombatUnit; Msg: TMapFieldMsg; Data: TCombatData;
    Transporter: TAbstractUnit;
begin
  A1.BeginUpdate;
  Player := TCombatPlayerList(FCombatData.FPlayers).IndexOf(A1.FPlayer, A1.FIndependentRelation);
  if Player = $FF then Player := AddCombatPlayer(A1.FPlayer, A1.FIndependentRelation, A2);
  Position := GetPartyPosition(A3, A4, A5);
  Party := TCombatPartyList(FCombatData.FParties).CreateParty(Integer(Self), Position, Player, A3, A4, A5, Integer(A1));
  Transporter := A1.Transporter($FF);
  Transport := (Transporter <> nil) and Transporter.ValidTerrain(FCombatData.F_CombatData_20[0], FCombatData.F_CombatData_20[1]);
  Index := 0;
  for I := A1.Count - 1 downto 0 do
  begin
    Valid := A1.GetUnit(I).ValidTerrain(FCombatData.F_CombatData_20[0], FCombatData.F_CombatData_20[1]);
    if Valid or Transport then
    begin
      UnitObj := TCombatUnit(CreateCombatUnit);
      UnitObj.Setup(CreateUniqueCOID, Ord(A2), A1.GetUnit(I), (Position shl 4) + Index, Player);
      if not Valid then
      begin
        UnitObj.FDisabled := True;
        UnitObj.FControlMode := UnitObj.FControlMode - [cmConquerObject];
      end;
      FCombatData.AddObject(UnitObj);
      Inc(Index);
    end;
  end;
  if A3 <> -1 then
  begin
    Msg.MsgID := $1123;
    Msg.Param[0] := Integer(AoWHSMap.MapContainer.GetField(A3, A4, A5));
    Msg.Result := 0;
    Data := FCombatData;
    AoWHSMap.MapContainer.GetField(Data.FX, Data.FY, Data.FL).SendMapFieldMsg(Msg);
    if Msg.Result <> 0 then Party.FWall := Msg.Result;
  end;
  A1.EndUpdate;
  Result := Party;
end;

function TCombat.AddArmyEx(A1: TArmy; A2: TCombatSideIndex; A3: Integer; A4: Integer; A5: Integer; A6: Byte): TCombatParty; { Near miss: three variants retain a different argument evaluation order. }
var Party: TCombatParty; Player: Byte; Index, I: Integer; UnitObj: TCombatUnit;
begin
  A1.BeginUpdate;
  Player := TCombatPlayerList(FCombatData.FPlayers).IndexOf(A1.FPlayer, A1.FIndependentRelation);
  if Player = $FF then Player := AddCombatPlayer(A1.FPlayer, A1.FIndependentRelation, A2);
  Party := TCombatPartyList(FCombatData.FParties).CreateParty(Integer(Self), A6, Player, A3, A4, A5, Integer(A1));
  Index := 0;
  for I := A1.Count - 1 downto 0 do
  begin
    UnitObj := TCombatUnit(CreateCombatUnit);
    UnitObj.Setup(CreateUniqueCOID, Ord(A2), A1.GetUnit(I), (A6 shl 4) + Index, Player);
    FCombatData.AddObject(UnitObj);
    Inc(Index);
  end;
  A1.EndUpdate;
  Result := Party;
end;

procedure TCombat.AddEmptyArmy(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
var Data: TCombatData; Position, Player: Byte; Side: TCombatSideIndex; Party: TCombatParty; Msg: TMapFieldMsg;
begin
  Data := FCombatData;
  Position := GetPartyPosition(A3, A4, A5);
  Side := GetCombatSide(
    TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer,
    TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FIndependentRelation,
    TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer,
    TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FIndependentRelation,
    A1, A2);
  Player := TCombatPlayerList(FCombatData.FPlayers).IndexOf(A1, A2);
  if Player = $FF then Player := AddCombatPlayer(A1, A2, Side);
  Party := TCombatPartyList(FCombatData.FParties).CreateParty(Integer(Self), Position, Player, A3, A4, A5, 0);
  Msg.MsgID := $1123;
  Msg.Param[0] := Integer(AoWHSMap.MapContainer.GetField(A3, A4, A5));
  Msg.Result := 0;
  AoWHSMap.MapContainer.GetField(A3, A4, A5).SendMapFieldMsg(Msg);
  if Msg.Result <> 0 then Party.FWall := Msg.Result;
end;

procedure TCombat.InitDefaultArmies(Army: TArmy; X, Y, L: Integer);
var Data: TCombatData; ArmyHS: TArmyHS;
begin
  Data := FCombatData;
  if GetPartyPosition(X, Y, L) = 7 then
  begin
    FExplorationSite := 2;
    AddArmy(Army, csAttacker, X, Y, L);
    ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(Data.FX, Data.FY, Data.FL).FindOwnedChild($20217));
    if ArmyHS <> nil then
      AddArmy(ArmyHS.FArmy, csDefender, Data.FX, Data.FY, Data.FL)
    else
      AddEmptyArmy(
        TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer,
        TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FIndependentRelation,
        Data.FX, Data.FY, Data.FL);
  end
  else AddAdjacentArmies;
end;

procedure TCombat.Initialize; { Near miss: loop and Self registers differ after three variants. }
var I, J: Integer; Wall: TCombatWall; WallType, Player: Byte;
begin
  LockExecuted;
  FStatus := FStatus + [cExecuting];
  WallType := 0;
  J := 0;
  while (WallType = 0) and (J <> TCombatPartyList(FCombatData.FParties).Count) do
  begin
    if TCombatPartyList(FCombatData.FParties).GetParty(J) <> nil then
      WallType := TCombatPartyList(FCombatData.FParties).GetParty(J).FWall;
    Inc(J);
  end;
  if WallType <> 0 then
  begin
    Wall := TCombatWall.Create(nil);
    Wall.Setup(CreateUniqueCOID, WallType, FCombatData.FDefenderPlayer);
    FCombatData.AddObject(Wall);
  end;
  if TCombatPartyList(FCombatData.FParties).GetParty(0) <> nil then
    FCombatData.FWallType := TCombatPartyList(FCombatData.FParties).GetParty(0).FWall;
  TByteList(FCombatData.FTurnOrder).Add(FCombatData.FDefenderPlayer);
  for I := 0 to TCombatPlayerList(FCombatData.FPlayers).Count - 1 do
  begin
    Player := I;
    if (TByteList(FCombatData.FTurnOrder).IndexOf(Player) = -1) and
      (TCombatPlayerList(FCombatData.FPlayers).GetPlayers(Player).FSideIndex = 1) then
      TByteList(FCombatData.FTurnOrder).Add(Player);
  end;
  TByteList(FCombatData.FTurnOrder).Add(FCombatData.FAttackerPlayer);
  for I := 0 to TCombatPlayerList(FCombatData.FPlayers).Count - 1 do
  begin
    Player := I;
    if (TByteList(FCombatData.FTurnOrder).IndexOf(Player) = -1) and
      (TCombatPlayerList(FCombatData.FPlayers).GetPlayers(Player).FSideIndex = 0) then
      TByteList(FCombatData.FTurnOrder).Add(Player);
  end;
  for I := FCombatData.GetCount - 1 downto 0 do FCombatData.GetObjects(I).Initialize(Integer(Self));
  TCombatLogbook(FLogbook).SetInitialData(FCombatData);
end;

procedure TCombat.Finalize;
var I, PlayerIndex, ArmyIndex, UnitIndex: Integer; Player: TPlayer;
    Alive: Boolean; Mode: TFinalizeMode; Data, FinalData: TCombatData; Msg: TMapFieldMsg;
begin









































































  Assert(FStatus * [cExecuting, cActivated] = [cExecuting], 'Combat Finalize Failure');
  for I := 0 to TByteList(FCombatData.F_CombatData_2C).Count - 1 do
  begin
    Data := FCombatData;
    AoWHSMap.GameOver(TCombatPlayerList(Data.FPlayers).GetPlayers(TByteList(Data.F_CombatData_2C)[I]).FPlayer, goLost);
    TCombatLogbook(FLogbook).F_CombatLogbook_19 := True;
  end;
  TCombatLogbook(FLogbook).SetFinalData(FCombatData);
  FStatus := FStatus - [cExecuting];
  Data := FCombatData;
  for I := Data.GetCount - 1 downto 0 do FCombatData.GetObjects(I).CombatDone;
  for Mode := fmOriginal to fmAll do
    for I := Data.GetCount - 1 downto 0 do FCombatData.GetObjects(I).Finalize(Mode);
  TCombatLogbook(FLogbook).FFinalData.FHeader := GetCombatResultText;
  TCombatLogbook(FLogbook).FFinalData.F_CombatData_30 := Ord(FCombatResult);
  PlayerIndex := TCombatPlayerList(FCombatData.FPlayers).Count;
  while (PlayerIndex <> 0) and not TCombatLogbook(FLogbook).F_CombatLogbook_19 do
  begin
    Dec(PlayerIndex);
    Player := AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(FCombatData.FPlayers).GetPlayers(PlayerIndex).FPlayer));
    ArmyIndex := Player.FArmies.Count;
    Alive := False;
    while (ArmyIndex <> 0) and not Alive do
    begin
      Dec(ArmyIndex);
      UnitIndex := Player.FArmies.GetArmy(ArmyIndex).Count;
      while not Alive and (UnitIndex <> 0) do
      begin
        Dec(UnitIndex);
        Alive := Player.FArmies.GetArmy(ArmyIndex).GetUnit(UnitIndex).GetHitPoints <> 0;
      end;
    end;
    TCombatLogbook(FLogbook).F_CombatLogbook_19 := not Alive;
  end;
  FinalData := FCombatData;
  if FinalData.FX <> -1 then
  begin
    Msg.MsgID := $1110;
    Msg.Param[0] := Integer(Self);
    Msg.Result := 0;
    AoWHSMap.MapContainer.GetField(FinalData.FX, FinalData.FY, FinalData.FL).SendMapFieldMsg(Msg);
  end;
  UnlockExecuted;
end;

procedure TCombat.LockExecuted;
begin Inc(FExecutedLock); end;

procedure TCombat.UnlockExecuted;
begin
  Dec(FExecutedLock);
  if (FExecutedLock = 0) and Assigned(FOnExecuted) then FOnExecuted(Self);
end;

procedure TCombat.Activate;
var I: Integer;
begin















  Assert(not (cActivated in FStatus), 'Combat already activated');
  FStatus := FStatus + [cActivated];
  TCombatPartyList(TCombatData(FCombatData).FParties).Activate(Integer(Self));
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    TCombatData(FCombatData).GetObjects(I).Activate(Integer(Self));
  if cExecuting in FStatus then
  begin
    for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
      TCombatData(FCombatData).GetObjects(I).SetupTargets;
    UpdateSidesSettings;
  end;
end;

procedure TCombat.Deactivate;
var I: Integer;
begin

  Assert(cActivated in FStatus, 'Combat Failure during Deactivating');
  FStatus := FStatus - [cActivated];
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    TCombatData(FCombatData).GetObjects(I).Deactivate;
  TCombatPartyList(TCombatData(FCombatData).FParties).Deactivate(Integer(Self));
end;

function TCombat.Execute: TCombatResult;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Result := crIdle;
end;

procedure TCombat.UpdateStatus;
var Attackers, Defenders, I: Integer;
begin
  Attackers := FSides[csAttacker].GetUndestroyedConquerObjects;
  Defenders := FSides[csDefender].GetUndestroyedConquerObjects;
  if (Attackers <> 0) and (Defenders = 0) then FCombatResult := crVictory
  else if (Attackers = 0) and (Defenders <> 0) then FCombatResult := crDefeat
  else if (Attackers = 0) and (Defenders = 0) then FCombatResult := crBothDefeated
  else if (Attackers <> 0) and (Defenders <> 0) and (FCombatResult <> crUndecided) then
    FCombatResult := crCannotInflictDamage;
  case Ord(FCombatResult) of
    4..5:
      for I := FCombatData.GetCount - 1 downto 0 do
        if csFled in FCombatData.GetObjects(I).FStatus then FCombatResult := crFled;
  end;
end;

function TCombat.GetCombatResultText: string;
var Data: TCombatData; Msg: TMapFieldMsg;
begin
  Result := '';
  Msg.MsgID := $1109;
  Msg.Result := Integer(@Result);
  Msg.Param[0] := Integer(Self);
  Data := FCombatData;
  AoWHSMap.MapContainer.GetField(Data.FX, Data.FY, Data.FL).SendMapFieldMsg(Msg);
  if Result = '' then
    if FCombatResult = crVictory then Result := TranslateRStr(BattleWonRStr)
    else if FCombatResult = crDefeat then Result := TranslateRStr(BattleLostRStr)
    else if FCombatResult = crCannotBreachWall then Result := TranslateRStr(CannotBreachWallRStr)
    else if FCombatResult = crCannotInflictDamage then Result := TranslateRStr(CannotInflictDamageRStr)
    else Result := TranslateRStr(BattleDrawnRStr);
end;

function TCombat.DefendersAvailable: Boolean;
var I: Integer; Obj: TCombatObject;
begin
  Result := False;
  I := 0;
  while not Result and (I <> TCombatData(FCombatData).GetCount) do
  begin
    Obj := TCombatData(FCombatData).GetObjects(I);
    Result := (Obj.FCombatPlayer <> -1) and
      (TCombatPlayerList(TCombatData(FCombatData).FPlayers).GetPlayers(Shortint(Obj.FCombatPlayer)).FSideIndex = 1) and
      not (csDestroyed in Obj.FStatus);
    Inc(I);
  end;
end;

