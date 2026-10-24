# Hand-verified field names

Same table format as `field-names.md`; `tools/build_classdb.py` reads this file after the generated ones,
so a row here wins. Add a row only after reading the code that uses the field.

## Engine.TENode

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FChildren | TList | manual: AddChild calls TList.Add on it and returns Count-1 |

## Engine.TEReadStorageStream

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FStream | TStream | manual: rwInteger seeks and reads through it |
| +$10 | FPropertyTable | TPropertyTable | manual: rwInteger calls TPropertyTable.FindOffset on it |
| +$28 | FDataBase | int | manual: property offset is added to it before seeking |

## AoWE.TAbstractUnit

| offset | field | c type | from |
|---|---|---|---|
| +$26 | FMoraleValue | char | manual: GetMorale passes it to MoraleValueToMorale |

## AoWE.TUnit

| offset | field | c type | from |
|---|---|---|---|
| +$40 | FUnitResource | TUnitResource | manual: ReadWrite stores UnitResourceIndex of it |

## AoWE.THero

| offset | field | c type | from |
|---|---|---|---|
| +$70 | FHeroItems | THeroItems | delegation from THero getters |
| +$74 | FInventory | THeroInventory | manual: second embedded item list in ReadWrite (id $24); class guessed from THeroInventory existing |
