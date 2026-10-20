{ P1 shared world globals; original addresses $558FA048 and $558FA040. }
var
  AoWEngine: TAoWEngine;
  AoWHSMap: TAoWHSMap;
  AoWHSSet: TAoWHSSet;  { $558FA044 }

const
  dtAll: TDamageTypes = [dtFire..dtNone]; { $558E8044 }
  ExplosionSFX: array[0..1] of string = ('SFX\ATTACK\STORM.WAV', 'SFX\ATTACK\EXPLOD1.WAV'); { $558E8030 }
  alsPureGood: TAlignments = [alPureGood, alGood, alNone]; { $558E8050 }
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
  TAbilityTypeRStr: array[TAbilityType] of string;
  TCombatModeRStr: array[TCombatMode] of string;
  TStatusRStr: TStatusNames;
  TDamageTypeRStr: array[TDamageType] of string;
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
  XDayLeftRStr = '%s day left';
  XDaysLeftRStr = '%s days left';
