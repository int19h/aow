{ P1 shared world globals; original addresses $558FA048 and $558FA040. }
var
  AoWEngine: TAoWEngine;
  AoWHSMap: TAoWHSMap;
  AoWHSSet: TAoWHSSet;  { $558FA044 }

const
  ExplosionSFX: array[0..1] of string = ('SFX\ATTACK\STORM.WAV', 'SFX\ATTACK\EXPLOD1.WAV'); { $558E8030 }
  { Original alsAll at $558E8068 excludes alPureNeutral. }
  alsAll: TAlignments = [alPureGood, alGood, alNeutral, alEvil, alPureEvil, alNone];
var
  UnitTypePluralRStr: array[TUnitType] of string;  { $558E8088, initially empty }
  TAbilityTypeRStr: array[TAbilityType] of string;
  TCombatModeRStr: array[TCombatMode] of string;
  TDamageTypeRStr: array[TDamageType] of string;
  { RaceNamesPluralRStr export $558E82FC spans $34 bytes to the next export; ListDebugInfo
    ($55730868) reads its entries. AIDID $558FA050 goes to TEngine.OutputDebugMessage. (P5) }
  RaceNamesPluralRStr: array[0..12] of string;
  AIDID: Integer;

var
  RaceNamesRStr: array[0..12] of string;
