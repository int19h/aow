{ P1 shared world globals; original addresses $558FA048 and $558FA040. }
var
  AoWEngine: TAoWEngine;
  AoWHSMap: TAoWHSMap;
  AoWHSSet: TAoWHSSet;  { $558FA044 }

const
  { Original alsAll at $558E8068 excludes alPureNeutral. }
  alsAll: TAlignments = [alPureGood, alGood, alNeutral, alEvil, alPureEvil, alNone];
var
  UnitTypePluralRStr: array[TUnitType] of string;  { $558E8088, initially empty }
  TAbilityTypeRStr: array[TAbilityType] of string;
  TCombatModeRStr: array[TCombatMode] of string;
  TDamageTypeRStr: array[TDamageType] of string;
