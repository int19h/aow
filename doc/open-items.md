# Open items in the recovered source

This file lists work on the recovered source that is known to be open. Checker work is in
[checker-plan.md](checker-plan.md), and the functions that still differ from the original are in
[../data/equiv-review/](../data/equiv-review/).

## Access classes

Four "cracker" classes read protected fields of Engine and HSEngine classes from other units. They
exist because those fields were private when the other units were recovered. Engine now declares
the fields protected. Replace each cast with direct access, then run `sh tools/checkall.sh` to make
sure that the code stays the same:

- `src/delphi3/SoundP/Sound.pas`: `TENodeAccess = class(TECustomNode)`, in the SFX list methods.
- `src/delphi3/Network/NetworkE.pas`: `TENodeView = class(TECustomNode)`.
- `src/delphi3/HSEPack/Terrain.pas`: `TENodeAccess = class(TENode)`.
- `src/delphi3/HSEPack/inc/HSMAP.PAS`: `TMapFieldTandO = class(TECustomNode)`, used to reach
  `TMapField.FTandO`. Make the field protected in HSEngine instead.

## Raw layout views in AoWEPACK

AoWEPACK reads some fields through layout views instead of field names. Examples are
`TRawObject(Pointer(AoWEngine)^).Fields[$48 div 4]`, `PMapState(Pointer(AoWHSMap))^.Day` and
`TIsoFields(Pointer(Self)^).Sides`. Workers wrote these views when the fields had no name, the wrong
type, or private visibility in another unit. Most of those fields have names now.

A survey on 2026-10-24 resolved 147 of the 162 `Fields[$N div 4]` views:

- 130 land on a named public field.
- 11 land on private fields of `THSMap` and `THSEngine` in HSEngine.
- 6 are `TArmyHS.FArmy` reads through a variable typed `THexagonSprite`.

Of 62 uses of view records, 33 resolved: 27 on named public fields and 6 on private fields in
another package. Test compiles with `tools/dcc_probe.py` gave the same code for a view and for
plain field access. So the views can become plain field access without losing matches. The
private fields need a visibility change or an accessor, and the `FArmy` reads need a
`TArmyHS(...)` cast.

The pointer views to package variables are different. Examples are `WorldMap: PAoWHSMap =
@AoWE.AoWHSMap` and `RandomSeed: ^Integer = @System.RandSeed`. They change the generated code
(rules K02 and K45 in [delphi3-codegen.md](delphi3-codegen.md)), and the matches depend on them.
Keep them.

## Unit initialization order

`tools/buildgame.py` reads the unit initialization table of each original module, and
`PACKAGEINFO`. It compares both with the rebuilt modules and writes `initialization-order.json`.
The order read from the original modules is in `data/initialization-order.json` (`tools/portdata/make_init_order.py`). In modules that import AoWEPACK, some units come before units that their recovered uses clauses name, for example AoWReg and Sound in AoW.exe. Either the table is not strict dependency order, or our uses clauses differ from the originals; check this.

## classes.json is incomplete

[../data/classes.json](../data/classes.json) lists only some fields of some classes. For example,
it lists 84 fields of `TAoWHSMap`, where the source declares 120 with offsets. The source class
declarations are the authority for field names and offsets.

## Forms that do not convert back exactly

`tools/buildgame.py` converts the text forms in `data/forms/` with `convert.exe`. Three AoWEd forms come back 3 bytes shorter than the originals, because `convert.exe` drops the child position `[n]` of a non-inherited `object`. The build does not compare the rebuilt forms with the originals.
