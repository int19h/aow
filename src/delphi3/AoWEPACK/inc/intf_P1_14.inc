{ P1 shared world globals; original addresses $558FA048 and $558FA040. }
var
  AoWEngine: TAoWEngine;
  AoWHSMap: TAoWHSMap;
  AoWHSSet: TAoWHSSet;  { $558FA044 }

const
  RaceColors: array[0..12] of TColor = ($00E03430, $0066A4FF, $00AFCB2C,
    $00FEDA87, $0060EF41, $0015FDFD, $00A5C1E4, $00F7FFFD, $00B370BC,
    $005050E9, $004266BB, $00797898, $00A8A8A8); { $558E8294 }
  dAlignmentToStatusValue: array[TAlignment, TAlignment] of Shortint = (
    (100,90,30,40,10,0,50), (90,90,40,50,10,10,50),
    (30,40,70,50,40,30,50), (40,50,50,50,50,40,50),
    (10,10,40,50,90,90,50), (0,10,30,40,90,100,50),
    (50,50,50,50,50,50,50)); { $558E8480 }
  dtAll: TDamageTypes = [dtFire..dtNone]; { $558E8044 }
  ExplosionSFX: array[0..1] of string = ('SFX\ATTACK\STORM.WAV', 'SFX\ATTACK\EXPLOD1.WAV'); { $558E8030 }
  alsPureGood: TAlignments = [alPureGood, alGood, alNone]; { $558E8050 }
  alsGood: TAlignments = [alPureGood, alGood, alNeutral, alNone]; { $558E8054 }
  alsNeutral: TAlignments = [alGood, alNeutral, alEvil, alNone]; { $558E8058 }
  alsEvil: TAlignments = [alNeutral, alEvil, alPureEvil, alNone]; { $558E805C }
  alsPureNeutral: TAlignments = [alNeutral, alNone]; { $558E8064 }
  alsPureEvil: TAlignments = [alEvil, alPureEvil, alNone]; { $558E8060 }
  { Original alsAll at $558E8068 excludes alPureNeutral. }
  RaceTerrain: TRaceTerrainTable = (
    (Bonus: []; Penalty: []),
    (Bonus: [2]; Penalty: [3, 6, 13]),
    (Bonus: [0]; Penalty: [2, 5]),
    (Bonus: [3, 6, 13]; Penalty: [2]),
    (Bonus: [1]; Penalty: [5]),
    (Bonus: [1]; Penalty: [5]),
    (Bonus: [12]; Penalty: []),
    (Bonus: []; Penalty: []),
    (Bonus: [12]; Penalty: []),
    (Bonus: []; Penalty: []),
    (Bonus: [12]; Penalty: []),
    (Bonus: [5]; Penalty: [1])); { $558E8394 }
  alsAll: TAlignments = [alPureGood, alGood, alNeutral, alEvil, alPureEvil, alNone];
var
  UnitTypePluralRStr: array[TUnitType] of string;  { $558E8088, initially empty }
  TAbilityTypeRStr: array[TAbilityType] of string; TAbilitySelectionTypeRStr: array[TAbilitySelectionType] of string; { AoWEd 0042C336 }
  TPlayerTypeRStr: array[0..7] of string; { $558E81A0 } TCampaignDifficultyLevelRStr: array[TCampaignDifficultyLevel] of string = ('Easy', 'Normal', 'Hard'); TPlayModeRStr: array[TPlayMode] of string = ('None', 'Classic', 'Simultaneous'); { AoW 0041B3CA / 0041B43B }
  TCombatModeRStr: array[TCombatMode] of string; TCombatResolveModeRStr: array[TCombatResolveMode] of string; { $558E81DC; AoW 00422576 }
  TGroupBehaviorStr: array[TGroupBehavior] of string; { $558E8154; 5579389C }
  TAlignmentRStr: array[TAlignment] of string = ('Pure Good', 'Good', 'Pure Neutral', 'Neutral', 'Evil', 'Pure Evil', 'None'); { export $558E80E4; AoW 0043C43C } TStatusRStr: TStatusNames; TPartyStatusRStr: array[TPartyStatus] of string = ('Unruly', 'Unrest', 'Stable', 'Content', 'Cheerful'); { 0040667C }
  TMoraleRStr: array[TMorale] of string = ('Terrible', 'Poor', 'Okay', 'Good', 'High'); { AoW 00409284 / 004092EA }
  TDamageTypeRStr: array[TDamageType] of string; astAll: TAbilitySelectionTypes = [astUnit..astEditor]; msAll: TMagicSpheres = [msCosmos..msNone]; { AoWEd 0042A5A4 / 0042A5E1 }
  { RaceNamesPluralRStr export $558E82FC spans $34 bytes to the next export; ListDebugInfo
    ($55730868) reads its entries. AIDID $558FA050 goes to TEngine.OutputDebugMessage. (P5) }
  RaceNamesPluralRStr: array[0..12] of string;
  AIDID: Integer;

var
  RaceNamesRStr: array[0..12] of string;

resourcestring
  CouldNotSaveXRStr = 'Could not save %s';
  InfoRStr = 'Info';
  NewDayRStr = 'Day %d dawns';
  TurnLimitReachedRStr = 'Sorry, turn limit reached!';

resourcestring
  MapSuccessfullyValidatedRStr = 'Map validated successfully';
  MapValidationFailedRStr = 'Map validation failed!';
  LoadingLevelRStr = 'Loading Level ';
  InitializingLevelRStr = 'Initializing Level ';
  UpdatingTerrainLevelRStr = 'Updating Terrain Level ';
  ActivatingLevelRStr = 'Activating Level ';
  SavingLevelRStr = 'Saving Level ';
  DestroyingLevelRStr = 'Destroying Level ';
  XTurnRStr = '%s turn';
  XTurnsRStr = '%s turns';
  XTurnLeftRStr = '%s turn left';
  XTurnsLeftRStr = '%s turns left';
  XDayRStr = '%s day';
  XDaysRStr = '%s days';
  XDayLeftRStr = '%s day left';
  XDaysLeftRStr = '%s days left';

resourcestring
  StructureRazedRStr = '%s razed';
  StructureBuiltRStr = '%s built';
  StructureRebuiltRStr = '%s rebuilt';
  XatLocationYRStr = '%0:s at location %1:s';
  NotEnoughForcesRStr = 'Your forces aren''t sufficient';
  RazeStructureWarningRStr = 'You''re about to raze this structure.';
  DoYouWishToContinueRStr = 'Do you wish to continue?';

resourcestring
  MessageRStr = 'Message';
