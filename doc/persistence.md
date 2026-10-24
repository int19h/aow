# Persistence: how the engine saves and loads objects

## Mechanism

Engine objects descend from `Engine.TEObject` (Enginep.dpl). Each class overrides one virtual method,
`ReadWrite(Stream: TEStorageStream)`, which both reads and writes. The stream decides the direction:
`TEReadStorageStream` reads, `TEWriteStorageStream` writes, `TCompareStorageStream` compares two states
(used for desync checks in multiplayer), and `TTranslateStorageStream` rewrites strings (localization).
The storage stream offers typed calls: `rwBool`, `rwByte`, `rwShortint`, `rwWord`, `rwInteger`, `rwString`,
`rwStrings`, `rwData`, `rwEObject`, `rwChildren`, `rwCreateEObject`, and `rwStreamProc`. The `...Ex` forms
take a default value. `OpenPropertyStream` and `TPropertyTable` give each class's data a named or numbered
slot, so that fields can be added without breaking older files (`TEObject.ClassVersion`).

As a result, every persisted field of every engine class is listed, in order and with its type, in that class's
`ReadWrite`. Decompiling the `ReadWrite` methods of the `AoWE` unit yields the data model. Only one class in
AoWEPACK uses a plain `LoadFromStream`/`SaveToStream` pair.

`tools/readwrite_table.py` extracts those calls from the decompiled output into `data/persisted-fields.md`
(218 classes), `tools/field_names.py` names offsets from trivial getters and setters, and `tools/class_layout.py`
merges both with the RTTI sizes into `doc/engine-classes.md`.

### TEStorageStream VMT

Decompiled code calls the stream through its VMT, for example `(**(code **)(*stream + 0x30))(stream, Self + 0x26, 6)`.
The slots are:

| slot | method | arguments after Self |
|---|---|---|
| +$00 | StorageMode | returns a flag byte: 1 read, 2 write, 4 compare, 8 and $10 unknown, $20 unknown, $40 translate |
| +$04 | OpenPropertyStream | |
| +$08 | rwCreateEObject | var Obj; ?; id |
| +$0C | rwEObject | Obj; id |
| +$10 | rwEObjectStream | |
| +$14 | rwChildren | |
| +$18 | rwStreamProc | id; Obj; LoadProc; SaveProc |
| +$1C | rwData | var Buf; Size; id |
| +$20 | rwString | var S; id |
| +$24 | rwStrings | Strings; id |
| +$28 | rwStringsEx | |
| +$2C | rwInteger | var I; id |
| +$30 | rwByte | var B; id |
| +$34 | rwWord | var W; id |
| +$38 | rwBool | var B; id |
| +$3C | rwShortint | var S; id |
| +$40 | rwIntegerEx | var I; Default; id |
| +$44 | rwByteEx | var B; Default; id |
| +$48 | rwWordEx | var W; Default; id |
| +$4C | rwShortintEx | var S; Default; id |

Property ids are small integers unique within a class. A read checks `TPropertyTable.PropertyExist(id)`
before older optional properties, which is how files from earlier versions stay loadable.

### On-disk layout of one object (from `TEReadStorageStream` in Enginep.dpl)

An object is a property table followed by its data. `TPropertyTable.LoadFromStream` reads:

1. One count byte. If bit 7 is set, the low 7 bits are the count of short entries and an `Integer` count
   of long entries follows.
2. `count` short entries of two bytes: property id, then offset.
3. The long entries, each `Integer` id and `Integer` offset.

`FDataBase` is the stream position right after the table. Every `rw*` call looks its id up in the table
(`FindOffset`), seeks to `FDataBase + offset` when needed, and reads the raw value (`rwInteger` reads 4 bytes,
`rwByte` 1, `rwString` a length-prefixed string). A missing id leaves the default value.

`rwEObject(obj, id)` (an object owned inline): seek to the property, read a nested property table, set
`FDataBase` to the position after it, call `obj.MainReadWrite(stream)`, then restore the outer table and base.
`MainReadWrite` calls `Clear` first in read mode, then `ReadWrite`.

`rwCreateEObject(var obj, owner, id)`: read an `Integer` class id at the property. If it is 0 the object is nil.
Otherwise read the nested table, ask the engine for a new instance of that class id (`TEngine` VMT slot +$90,
`CreateEObject(ClassID)`), set its owner, and run `MainReadWrite` as above. Class ids are the values returned by
each class's `ClassID` method, which is how the file stays independent of class names.

`rwStreamProc(id, obj, LoadProc, SaveProc)`: seek to the property and call a plain `LoadFromStream` or
`SaveToStream` method, used for lists such as `TIntegerList`.

`rwChildren(node, id)`: a nested property table whose entries are the children. Each entry's id is the
child's slot and its value is `Integer` class id plus the child's own table, exactly like `rwCreateEObject`.
`TECustomNode.MainReadWrite` calls `ReadWrite` and then `ReadWriteChildren`, which is `rwChildren(Self, 1)`,
so every node class (players, units, armies, structures, all the lists) keeps its children under id 1 even
though no `ReadWrite` method mentions it. Lists that are not nodes (`TItemControl`, `TAbilityOwner`) store
their items with `rwCreateEObject` under computed ids (a base plus the index), which the walker recognizes
by the class id at the start of the entry.

Strings (`rwString`): one length byte, or `$FF` followed by an `Integer` length, then the characters.

### File header

The inflated map or save data starts with a 16-byte record: `Integer 16` (its size), `'HSM'#0`, `Integer 0`,
`Integer ClassID` of the root object (131089 = `TAoWHSMap`). `THSEngine.LoadHSMfromStream` seeks to byte 16,
creates the root object from the class id, and runs `TEngine.ReadEObject`: a `TEReadStorageStream` whose
constructor reads the root property table (one entry, id 0, offset 0) and then `rwEObject(root, 0)`.

### Round trip (2026-10-19)

`tests/roundtrip.pas` loads a file through the generated object model (`src/model/AoWModel.pas`, built on
`src/recovered/Engine.pas` and `EngineLists.pas`), writes it back with `TEWriteStorageStream`, and compares
the bytes. Both shipped saves (`After the Fall.asg`, 790,598 bytes inflated, and `autosave.asg`) come back
byte-identical: 40,741 objects, 1,428 children, 2 map levels with all their fields, units, structures and
ability data. Two model aids made the last bytes match without changing the file semantics: embedded
objects are flagged shared (`TEObject.EmbeddedShared`) so that `Clear` keeps them and `rwChildren` skips
them, and a child remembers the slot it was read from (`TEObject.StoredIndex`) because the original owners
have a few unstored children in front of the stored ones.

The 23 shipped maps (`.hsm`) do not come back identical, because they were written by older versions and
carry properties the 1.36 code reads but never writes (for example `TPlayer` id $1A, a legacy relation list,
and the `TAoWHSMap` scenario-only conditions on `prop31`). For them the test does a second pass: loading our
output and writing it again gives identical bytes for all 23, which is the same behavior as the game's own
load-and-save.

### Validation

`tools/asg_dump.py` walks a real file with this description and the schema in `classes.json`. On the shipped
`After the Fall.asg` it reads the map name, the scenario set path `RELEASE\Release.hss`, the player, race,
item, hero, structure and AI control objects, and the 48 items of the item library with their ability data,
and it lists every property id the schema does not explain. Remaining gaps are ids whose last argument
Ghidra dropped from the call (`rwIntegerEx`, `rwData`) and `rwStreamProc` payloads.

With this, a Python reader for `.asg` and `.hsm` files is a straightforward next tool: inflate, read the root
object's table, and walk `TAoWHSMap.ReadWrite` using `data/persisted-fields.md` as the schema.

### Worked example: THero

From `THero.ReadWrite` plus the getters: `+$44 FHeroResourceIndex: Integer` (id 8, read first so that
`LinkToResource` can run), `+$3C FFaceIndex` (7), `+$60 FName: String` (10), `+$64 FNickname: String` ($0B),
`+$68` byte ($0C), `+$80 FCastingPoints: Byte` ($0D), `+$84` Integer ($0E), `+$69 FGender: Byte` ($0F, written
with rwData), six bytes `+$6A..+$6F` ($10..$15: the hero's own attack, defense, damage, resistance, hits, moves
by position in the unit stat block), `+$4C FUnitLevel: Byte` ($16), `+$54` Boolean ($17), `+$48 FExperience:
Integer` ($18, defaulting to `LevelToExperience(1)`), `+$58` Integer ($1A), `+$5C` byte ($1B), `+$79 FMovePoints`
($1D), `+$7A FHitPoints` ($1E), `+$88` Integer ($1F), `+$78` Boolean ($21), `+$8C` Integer ($22), `+$90`
Integer default -1 ($23), `+$74` and `+$70 FHeroItems` as embedded objects ($24, $25), `+$94: String` ($26,
skipped in compare mode), `+$50` Integer ($27).

Classes with `ReadWrite` include `TAbility`, `TAbilityOwner`, `TAbstractUnit`, `TUnit`, `THero`, `TArmy`,
`TStructure`, `TPlayer`, and `TAoWHSMap` (which also has `MainReadWrite` and `SaveGame`).

## Save file container (`.asg`)

A saved game starts with the four bytes `43 46 53 00` ("CFS\0"), one version byte (2 in v1.36 files),
and then a zlib stream (`78 9C`). `After the Fall.asg` inflates from 87,834 to 790,598 bytes.
The inflated data holds no property names, only values and the strings of the game state (hero names,
event texts), so field names must come from the code. The container is `Engine.TCompressStream`
(`SaveToFileEx`, `LoadFromFile`), built on the zlib unit in Enginep.dpl.

Map files (`.hsm`) use the same container: `After the Fall.HSM` starts with `CFS\0`, version 2, zlib.
Campaign files (`.cam`) and the scenario set `Release.hss` do not. `Keepers.CAM` starts with
`01 00 00 00 50 22 00 82 05 00 00 00`, and `Release.hss` starts with `34 00 00 00 04 "HSS" 00 07 "RELEASE"`,
which looks like a length-prefixed record with short strings: an uncompressed `TEStorageStream` layout.
