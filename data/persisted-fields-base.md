## CombatILTer.TCombatILTerrainResource : HSEngine.TMultiHexMOR

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$45 | 1 |  |
| 0x15 | rwByte | +$44 | 1 |  |

## CityWall.TCityWallResource : CombatILTer.TCombatILTerrainResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwByte | +$48 | 1 |  |

## CombatTE.TCAbTouchMoveTE : AoWE.TMoveTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$3C | 4 |  |

## CombatTE.TCAbRangedTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$14 | 4 |  |
| 0x1f | rwInteger | +$18 | 4 |  |
| 0x20 | rwWord | +$20 | 2 |  |
| 0x21 | rwWord | +$22 | 2 |  |
| 0x22 | rwWord | +$1C | 2 |  |
| 0x23 | rwWord | +$1E | 2 |  |

## CombatTerrain.TCombatTerrainResource : Terrain.TTerrainMOR

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$49 | 1 |  |
| 0x15 | rwByte | +$48 | 1 |  |
| 0x16 | rwByte | +$4A | 1 |  |
| 0x17 | rwBool | +$4B | 1 |  |

## AoWTC.TUnitPositionHS : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwByte | +$0C | 1 |  |
| 0x1a | rwByte | +$0D | 1 |  |
| 0x1b | rwByte | +$18 | 1 |  |

## Engine.TEControlStyleNode

| id | rw | offset | size | note |
|---|---|---|---|---|
| 2 | rwData | +$0C | 1 |  |

## Engine.TEControlStyleObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 1 | rwData | +$08 | 1 |  |

## Engine.TECustomOwner

| id | rw | offset | size | note |
|---|---|---|---|---|
| 2 | rwData | +$10 | 1 |  |

## Engine.TEResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 1 | rwInteger | +$0C | 4 |  |
| 2 | rwInteger | +$10 | 4 |  |
| 3 | rwInteger | +$14 | 4 |  |

## Engine.TEResourceEditSettings : Engine.TEControlStyleObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 3 | rwStringsEx | +$0C | 4 |  |

## Engine.TPlugInControl

| id | rw | offset | size | note |
|---|---|---|---|---|
| 1 | rwStrings | +$0C | 4 |  |

## HSEngine.THPBasedHS : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 4 | rwInteger | +$0C | 4 |  |
| 5 | rwInteger | +$10 | 4 |  |
| 6 | rwByte | +$14 | 1 |  |

## HSEngine.TMapField

| id | rw | offset | size | note |
|---|---|---|---|---|
| iStack_18 | rwCreateEObject |  | 4 | indirect: &piStack_14 |
| iVar1 | rwCreateEObject |  | 4 | indirect: &piStack_14 |

## HSEngine.TMapLevel : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 3 | rwByte |  | 1 | indirect: &bStack_24 |
| 4 | rwByte |  | 1 | indirect: &bStack_23 |
| 5 | rwByte |  | 1 | indirect: abStack_22 |
|  | OpenPropertyStream |  |  | indirect: 6 |
| iStack_28 + 100 | rwEObjectStream |  |  | indirect: iVar4 |

## HSEngine.TMapContainer : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 3 | rwByte |  | 1 | indirect: &uStack_10 |
| 4 | rwByte |  | 1 | indirect: (int)&uStack_10 + 1 |
| 5 | rwByte |  | 1 | indirect: (int)&uStack_10 + 2 |

## HSEngine.THSSet : Engine.TECustomOwner

| id | rw | offset | size | note |
|---|---|---|---|---|
| 4 | rwString | +$38 | 4 |  |
| 5 | rwEObject | +$24 | 4 |  |
| 6 | rwEObject | +$28 | 4 |  |
| 7 | rwEObject | +$34 | 4 |  |

## HSEngine.TMapObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 1 | rwInteger |  | 4 | indirect: &local_8 |
| 1 | rwInteger | +$08 | 4 |  |

## HSEngine.TMapObjectResource : Engine.TEResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 4 | rwInteger | +$1C | 4 |  |
| 5 | rwByte | +$2C | 1 |  |
| 6 | rwString | +$30 | 4 |  |
|  | rwStreamProc |  |  | indirect: 7 |
|  | rwStreamProc |  |  | indirect: 8 |
| 9 | rwBool |  | 1 | indirect: &uStack_30 |
| 9 | rwBool |  | 1 | indirect: &uStack_30 |
| 10 | rwStreamProc |  |  | indirect: stream->vtbl |

## HSEngine.TMultiHexMO : HSEngine.TMapObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 3 | rwByte | +$10 | 1 |  |
| 4 | rwByte | +$11 | 1 |  |

## HSEngine.TMultiHexMOR

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xc | rwInteger | +$34 | 4 |  |
| 0xd | rwInteger | +$38 | 4 |  |
| 0xe | rwInteger | +$3C | 4 |  |
| 0xf | rwInteger | +$40 | 4 |  |

## HSEngine.THSMap : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 2 | rwString | +$38 | 4 |  |
| 3 | rwByte |  | 1 | indirect: &local_5 |
| 4 | rwInteger | +$80 | 4 |  |
| 5 | rwInteger | +$84 | 4 |  |
| 6 | rwInteger | +$88 | 4 |  |

## HSEngine.TLibraryImageHS : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 1 | rwData | +$08 | 1 |  |
| 2 | rwInteger | +$1C | 4 |  |
| 3 | rwInteger | +$10 | 4 |  |
| 4 | rwInteger | +$14 | 4 |  |
| 5 | rwByte | +$18 | 1 |  |

## Terrain.TTerrainMOR

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x11 | rwByte | +$45 | 1 |  |
| 0x12 | rwByte | +$44 | 1 |  |

## NetworkE.TPlayerCommunicationSettings : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwData | +$08 | 1 |  |
| 6 | rwInteger | +$0C | 4 |  |

## NetworkE.TDataPackage

| id | rw | offset | size | note |
|---|---|---|---|---|
| 1 | rwInteger | +$08 | 4 |  |
| 2 | rwInteger | +$0C | 4 |  |

## NetworkE.TTokenEvent : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwInteger | +$0C | 4 |  |

## NetworkE.TTokenEventList : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwEObject | +$08 | 4 |  |

## NetworkE.TTokenPackage : NetworkE.TDataPackage

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwEObject | +$14 | 4 |  |

## NetworkE.TSyncTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$10 | 4 |  |
