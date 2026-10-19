## AoWE.TCombatUnit : AoWE.TCombatObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x15 | rwBool | +$54 | 1 |  |

## AoWE.TCombatWall : AoWE.TCombatObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$4C | 1 |  |
| 0x15 | rwByte | +$4D | 1 |  |

## AoWE.TCombatObject : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwByte | +$46 | 1 |  |
| 0xc | rwByte | +$45 | 1 |  |
| 0xd | rwData | +$47 | 1 |  |
| 0xe | rwData | +$0C | 1 |  |

## AoWE.TCombat : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwEObject | +$1C | 4 |  |
| 0xb | rwEObject | +$20 | 4 |  |
| 0xd | rwEObject | +$0C | 4 |  |

## AoWE.TCombatParty : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xb | rwInteger | +$0C | 4 |  |
| 0xc | rwInteger | +$10 | 4 |  |
| 0xd | rwInteger | +$14 | 4 |  |
| 0xe | rwByte | +$1A | 1 |  |
| 0xf | rwData | +$18 | 1 |  |
| 0x10 | rwByte | +$19 | 1 |  |

## AoWE.TCombatPlayer : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$08 | 1 |  |
| 0x15 | rwByte | +$09 | 1 |  |
| 0x16 | rwData | +$0A | 1 |  |

## AoWE.TCombatData : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwInteger | +$08 | 4 |  |
| 0xb | rwInteger | +$0C | 4 |  |
| 0xc | rwInteger | +$10 | 4 |  |
| 0xd | rwData | +$22 | 2 |  |
| 0xe | rwByte | +$24 | 1 |  |
| 0xf | rwByte | +$25 | 1 |  |
| 0x10 | rwData | +$30 | 1 |  |
| 0x11 | rwInteger | +$44 | 4 |  |
| 0x12 | rwEObject | +$38 | 4 |  |
| 0x13 | rwEObject | +$34 | 4 |  |
| 0x14 | rwEObject | +$3C | 4 |  |
| 0x15 | rwString | +$48 | 4 |  |
| 0x16 | rwInteger | +$14 | 4 |  |
| 0x17 | rwInteger | +$18 | 4 |  |
| 0x18 | rwInteger | +$1C | 4 |  |
| 0x19 | rwStreamProc |  |  | indirect: *param_2 |
| 0x1a | rwStreamProc |  |  | indirect: *param_2 |
| 0x1b | rwData | +$4C | 1 |  |
| 0x1c | rwBool | +$4D | 1 |  |
| 0x1d | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TCombatLogbook : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwEObject | +$0C | 4 |  |
| 6 | rwEObject | +$10 | 4 |  |
| 7 | rwEObject | +$14 | 4 |  |
| 8 | rwBool | +$19 | 1 |  |

## AoWE.TCombatEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|

## AoWE.TSingleTargetCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwByte | +$0D | 1 |  |
| 0xb | rwByte | +$0E | 1 |  |
| 0xc | rwData | +$0C | 1 |  |

## AoWE.TDamageCA : AoWE.TSingleTargetCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwByte | +$10 | 1 |  |
| 0x10 | rwData | +$13 | 2 |  |
| 0x11 | rwData | +$11 | 2 |  |

## AoWE.TDamageEffectCA : AoWE.TSingleTargetCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwData | +$10 | 1 |  |

## AoWE.TUpdateHeaderCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwString | +$0C | 4 |  |

## AoWE.TNewCombatTurnCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$0C | 1 |  |

## AoWE.TCombatObjectTurnDoneCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$0C | 1 |  |

## AoWE.TMoveWallCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$0C | 1 |  |
| 0x15 | rwData | +$0D | 1 |  |

## AoWE.TFleeCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$0C | 1 |  |

## AoWE.TJoinEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x15 | rwInteger | +$18 | 4 |  |
| 0x16 | rwStreamProc |  |  | indirect: *param_2 |
| 0x17 | rwByte | +$24 | 1 |  |
| 0x18 | rwStrings | +$2C | 4 |  |
| 0x19 | rwInteger | +$30 | 4 |  |
| 0x1a | rwInteger | +$20 | 4 |  |
| 0x1b | rwData | +$34 | 1 |  |
| 0x1c | rwString | +$38 | 4 |  |
| 0x1d | rwIntegerEx | +$28 | 4 | default 0xffffffff |

## AoWE.TNegotiateTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$10 | 4 |  |
| 0x1f | rwData | +$14 | 1 |  |
| 0x20 | rwByte | +$15 | 1 |  |
| 0x21 | rwByte | +$16 | 1 |  |
| 0x22 | rwByte | +$17 | 1 |  |
| 0x23 | rwByte | +$1C | 1 |  |
| 0x24 | rwByte | +$1D | 1 |  |
| 0x25 | rwData | +$24 | 1 |  |
| 0x26 | rwInteger | +$28 | 4 |  |
| 0x27 | rwInteger | +$34 | 4 |  |
| 0x28 | rwInteger | +$38 | 4 |  |
| 0x29 | rwData | +$2D | 1 |  |
| 0x2a | rwData | +$2E | 1 |  |
| 0x2c | rwIntegerEx | +$30 | 4 | default 0xffffffff |

## AoWE.TNegotiateRequestEventLog : AoWE.TJoinEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwByte | +$3C | 1 |  |
| 0x29 | rwByte | +$3D | 1 |  |
| 0x2a | rwByte | +$3E | 1 |  |
| 0x2b | rwData | +$48 | 1 |  |
| 0x2c | rwInteger | +$4C | 4 |  |
| 0x2d | rwInteger | +$50 | 4 |  |

## AoWE.TDiplomaticAction : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$10 | 1 |  |
| 0x15 | rwByte | +$11 | 1 |  |
| 0x16 | rwByte | +$12 | 1 |  |
| 0x17 | rwInteger | +$18 | 4 |  |
| 0x18 | rwInteger | +$1C | 4 |  |
| 0x19 | rwData | +$13 | 1 |  |
| 0x1a | rwData | +$14 | 1 |  |
| 0x1b | rwStrings | +$20 | 4 |  |
| 0x1c | rwInteger | +$24 | 4 |  |
| 0x1d | rwInteger | +$28 | 4 |  |
| 0x1e | rwInteger | +$2C | 4 |  |
| 0x1f | rwInteger | +$0C | 4 |  |

## AoWE.TDiplomaticActionTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x15 | rwInteger | +$10 | 4 |  |

## AoWE.TDiplomaticActionEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|

## AoWE.TAoWMapCampaignSettings : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$0C | 4 |  |
| 0x15 | rwInteger | +$10 | 4 |  |
| 0x16 | rwInteger | +$14 | 4 |  |
| 0x17 | rwInteger | +$18 | 4 |  |
| 0x18 | rwBool | +$08 | 1 |  |

## AoWE.TAoWCampaignScenario : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 9 | rwInteger | +$08 | 4 |  |
| 10 | rwString | +$0C | 4 |  |
| 0xb | rwString | +$10 | 4 |  |

## AoWE.TAoWCampaign : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwInteger |  | 4 | indirect: &uStack_14 |
| 6 | rwData |  | uStack_14 | indirect: *(undefined4 *)(*(int *)(param_1 + 0xc) + 4) |
| 5 | rwInteger |  | 4 | indirect: &uStack_14 |
| 6 | rwData |  | uStack_14 | indirect: *(undefined4 *)(*(int *)(param_1 + 0xc) + 4) |
| 7 | rwEObject | +$20 | 4 |  |
| 10 | rwEObject | +$10 | 4 |  |
| 0xc | rwString | +$08 | 4 |  |
| 0xd | rwInteger | +$24 | 4 |  |
| 0xe | rwStreamProc |  |  | indirect: *param_2 |
| 0xf | rwBool | +$1C | 1 |  |
| 0x10 | rwStreamProc |  |  | indirect: *param_2 |
| 0x11 | rwData | +$31 | 1 |  |
| 0x13 | rwData | +$30 | 1 |  |

## AoWE.TEmailGame : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwString | +$08 | 4 |  |
| 0x15 | rwInteger | +$0C | 4 |  |
| 0x16 | rwInteger | +$10 | 4 |  |
| 0x17 | rwString | +$18 | 4 |  |
| 0x18 | rwInteger | +$14 | 4 |  |

## AoWE.TAIPlayerControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwData | +$24 | 4 |  |

## AoWE.TAIBudget : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$08 | 4 |  |
| 0x1f | rwInteger | +$0C | 4 |  |
| 0x20 | rwInteger | +$10 | 4 |  |
| 0x21 | rwInteger | +$14 | 4 |  |
| 0x22 | rwInteger | +$18 | 4 |  |
| 0x23 | rwInteger | +$30 | 4 |  |
| 0x24 | rwInteger | +$34 | 4 |  |
| 0x25 | rwInteger | +$1C | 4 |  |
| 0x26 | rwInteger | +$20 | 4 |  |
| 0x27 | rwInteger | +$24 | 4 |  |
| 0x28 | rwInteger | +$28 | 4 |  |
| 0x29 | rwInteger | +$2C | 4 |  |

## AoWE.TAIBudgetManager : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwEObject | +$0C | 4 |  |
| 0x15 | rwInteger | +$30 | 4 |  |
| 0x16 | rwInteger | +$34 | 4 |  |
| 0x17 | rwInteger | +$28 | 4 |  |
| 0x18 | rwInteger | +$2C | 4 |  |
| 0x19 | rwInteger | +$20 | 4 |  |
| 0x1a | rwInteger | +$24 | 4 |  |

## AoWE.TAIGroup : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$24 | 4 |  |
| 0x15 | rwIntegerEx | +$30 | 4 | default 0xffffffff |
| 0x16 | rwIntegerEx | +$2C | 4 | default 0xffffffff |
| 0x17 | rwInteger | +$38 | 4 |  |
| 0x18 | rwData | +$3C | 1 |  |
| 0x19 | rwByte | +$28 | 1 |  |
| 0x1a | rwData | +$34 | 1 |  |
| 0x1b | rwByte | +$4D | 1 |  |
| 0x1c | rwByte | +$4E | 1 |  |
| 0x1d | rwInteger | +$40 | 4 |  |
| 0x1e | rwInteger | +$44 | 4 |  |
| 0x1f | rwInteger | +$48 | 4 |  |
| 0x20 | rwData | +$4C | 1 |  |

## AoWE.TAIGroupManager : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwIntegerEx | +$0C | 4 | default 1 |

## AoWE.THuntAG : AoWE.TAIGroup

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TFastCombatUnit : AoWE.TCombatUnit

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwData | +$60 | 1 |  |

## AoWE.TSaveGameTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwString | +$10 | 4 |  |

## AoWE.TChangePlayerSettingsTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwByte | +$10 | 1 |  |
| 0x1f | rwString | +$14 | 4 |  |

## AoWE.TEndTurnTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$14 | 4 |  |
| 0x15 | rwByte | +$10 | 1 |  |
| 0x16 | rwData | +$18 | 1 |  |

## AoWE.TMoveTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TMoveArmyTE : AoWE.TMoveTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwStreamProc |  |  | indirect: *param_2 |
| 0x1f | rwByte | +$2C | 1 |  |
| 0x20 | rwByte | +$2E | 1 |  |
| 0x21 | rwByte | +$2F | 1 |  |
| 0x22 | rwByte | +$30 | 1 |  |
| 0x23 | rwByte | +$2D | 1 |  |
| 0x24 | rwData | +$1C | 1 |  |
| 0x25 | rwByte | +$31 | 1 |  |
| 0x26 | rwByte | +$32 | 1 |  |
| 0x27 | rwByte | +$33 | 1 |  |

## AoWE.TArmyCombatMoveTE : AoWE.TMoveArmyTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x32 | rwData | +$39 | 1 |  |

## AoWE.TGameOverTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$10 | 1 |  |
| 0x15 | rwData | +$11 | 1 |  |

## AoWE.TTerminatePlayerTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$10 | 1 |  |

## AoWE.TMultiMoveTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwEObject | +$10 | 4 |  |
| 0x15 | rwBool | +$14 | 1 |  |

## AoWE.TCheatTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$10 | 1 |  |
| 0x15 | rwInteger | +$14 | 4 |  |

## AoWE.TDisbandUnitTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$14 | 1 |  |
| 0x15 | rwInteger | +$10 | 4 |  |

## AoWE.TCombatFlowControlTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwData | +$10 | 1 |  |
| 0x1f | rwInteger | +$14 | 4 |  |

## AoWE.TAoWHSSet : HSEngine.THSSet

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwEObject | +$54 | 4 |  |
| 0xb | rwEObject | +$6C | 4 |  |
| 0x6f | rwEObject | +$5C | 4 |  |
| 0x70 | rwEObject | +$60 | 4 |  |
| 0x71 | rwEObject | +$64 | 4 |  |
| 0x72 | rwEObject | +$68 | 4 |  |
| 0x73 | rwEObject | +$74 | 4 |  |
| 0x75 | rwEObject | +$84 | 4 |  |
| 0x76 | rwEObject | +$80 | 4 |  |
| 0x77 | rwEObject | +$98 | 4 |  |
| 0x11 | rwEObject | +$70 | 4 |  |
| 0x12 | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TRace : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 2 | rwByte | +$08 | 1 |  |
|  | rwStreamProc |  |  | indirect: 3 |
| 4 | rwBool |  | 1 | indirect: &pcStack_20 |
| 4 | rwBool | +$14 | 1 |  |
| 5 | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TRaceList : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$10 | 4 |  |

## AoWE.TFaceResource : Engine.TEResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwString | +$18 | 4 |  |
| 6 | rwInteger | +$1C | 4 |  |
| 7 | rwBool | +$28 | 1 |  |

## AoWE.TCustomAbilityList

| id | rw | offset | size | note |
|---|---|---|---|---|
| 2 | rwInteger | +$0C | 4 |  |
| 3 | rwData | +$08 | param_1[3] + 7U >> 3 |  |
| 2 | rwInteger |  | 4 | indirect: &iStack_10 |
| 3 | rwData | +$08 | param_1[3] + 7U >> 3 |  |

## AoWE.TAbility : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwStrings | +$10 | 4 |  |
| 6 | rwInteger | +$14 | 4 |  |
| 7 | rwEObject | +$18 | 4 |  |
| 8 | rwStreamProc |  |  | indirect: *param_2 |
| 9 | rwData | +$20 | 2 |  |

## AoWE.TAbilityOwner : AoWE.TCustomAbilityList

| id | rw | offset | size | note |
|---|---|---|---|---|
|  | rwStreamProc |  |  | indirect: 0x31 |
| 0x31 | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TAbilityControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| iVar3 + 10 | rwEObject |  | 4 | indirect: uVar2 |

## AoWE.TDiplomaticRelationHistoryItem : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$08 | 4 |  |
| 0x15 | rwData | +$0C | 1 |  |

## AoWE.TPlayerDiplomaticRelations : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwStreamProc |  |  | indirect: *param_2 |
| 0x15 | rwEObject | +$10 | 4 |  |

## AoWE.TTurnInfoItem : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwInteger | +$08 | 4 |  |
| 0x1a | rwInteger | +$0C | 4 |  |
| 0x1b | rwInteger | +$10 | 4 |  |
| 0x1c | rwInteger | +$14 | 4 |  |
| 0x1d | rwByte | +$18 | 1 |  |

## AoWE.TPlayerStatistics : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwEObject | +$08 | 4 |  |
| 0x15 | rwInteger | +$0C | 4 |  |
| 0x16 | rwInteger | +$10 | 4 |  |

## AoWE.TPBEMPlayerSettings : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$08 | 1 |  |
| 0x15 | rwEObject | +$0C | 4 |  |

## AoWE.TPlayer : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 2 | rwByte | +$A5 | 1 |  |
|  | rwData | +$A7 | 1 |  |
| 4 | rwBool | +$A9 | 1 |  |
| 5 | rwInteger | +$AC | 4 |  |
| 6 | rwInteger | +$B0 | 4 |  |
|  | rwData | +$45 | 1 |  |
| 0xb | rwString | +$BC | 4 |  |
| 0xc | rwString | +$C0 | 4 |  |
| 0x10 | rwInteger | +$C4 | 4 |  |
| 0x12 | rwByte | +$A6 | 1 |  |
| 0x14 | rwByte | +$2D | 1 |  |
| 0x15 | rwByte | +$2E | 1 |  |
| 0x16 | rwByte | +$2F | 1 |  |
| 0x14 | rwByte | +$2D | 1 |  |
| 0x15 | rwByte | +$2E | 1 |  |
| 0x16 | rwByte | +$2F | 1 |  |
| 0x17 | rwEObject | +$D8 | 4 |  |
| 0x18 | rwString | +$30 | 4 |  |
| 0x19 | rwData | +$44 | 1 |  |
| 0x1a | rwStreamProc |  |  | indirect: *param_2 |
| 0x1b | rwByte | +$50 | 1 |  |
| 0x1c | rwEObject | +$88 | 4 |  |
| 0x1d | rwData | +$A8 | 1 |  |
| 0x1e | rwEObject | +$58 | 4 |  |
| 0x1e | rwEObject | +$D4 | 4 |  |
| 0x1f | rwEObject | +$54 | 4 |  |
| 0x20 | rwStreamProc |  |  | indirect: *param_2 |
| 0x21 | rwStreamProc |  |  | indirect: *param_2 |
| 0x22 | rwInteger | +$5C | 4 |  |
| 0x23 | rwEObject | +$60 | 4 |  |
| 0x24 | rwInteger | +$6C | 4 |  |
| 0x25 | rwInteger | +$70 | 4 |  |
| 0x26 | rwInteger | +$78 | 4 |  |
| 0x27 | rwInteger | +$7C | 4 |  |
| 0x28 | rwStrings | +$34 | 4 |  |
| 0x29 | rwStreamProc |  |  | indirect: *param_2 |
| 0x32 | rwInteger | +$74 | 4 |  |
| 0x33 | rwEObject | +$8C | 4 |  |
| 0x34 | rwEObject | +$90 | 4 |  |
| 0x35 | rwStreamProc |  |  | indirect: *param_2 |
| 0x36 | rwEObject | +$A0 | 4 |  |
| 0x38 | rwBool | +$A4 | 1 |  |
| 0x39 | rwInteger | +$B4 | 4 |  |
| 0x3a | rwEObject | +$40 | 4 |  |

## AoWE.TRaceResource : Engine.TEResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwString | +$24 | 4 |  |
| 6 | rwString | +$28 | 4 |  |
| 7 | rwString | +$2C | 4 |  |
| 8 | rwString | +$20 | 4 |  |
| 9 | rwData | +$30 | 1 |  |
| 10 | rwStreamProc |  |  | indirect: *param_2 |
| 0xb | rwStreamProc |  |  | indirect: *param_2 |
| 0xc | rwInteger | +$3C | 4 |  |
| 0xd | rwStrings | +$44 | 4 |  |

## AoWE.TUnitProduction : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$08 | 4 |  |
| 0x15 | rwBool | +$0C | 1 |  |

## AoWE.TProductionItem : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$08 | 4 |  |
| 0x15 | rwInteger | +$0C | 4 |  |
| 0x16 | rwInteger | +$10 | 4 |  |

## AoWE.TProductionSettings : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwInteger | +$08 | 4 |  |
| 0xb | rwInteger | +$0C | 4 |  |
| 0xc | rwByte | +$10 | 1 |  |
| 0xd | rwByte | +$1C | 1 |  |
| 0xe | rwByte | +$1D | 1 |  |
| 0xf | rwInteger | +$20 | 4 |  |
| 0x10 | rwInteger | +$28 | 4 |  |
| 0x12 | rwInteger | +$14 | 4 |  |
| 0x13 | rwInteger | +$18 | 4 |  |

## AoWE.TProductionTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$14 | 4 |  |
| 0x15 | rwByte | +$10 | 1 |  |
| 0x16 | rwByte | +$11 | 1 |  |
| 0x17 | rwByte | +$12 | 1 |  |
| 0x18 | rwByte | +$13 | 1 |  |
| 0x1a | rwInteger | +$20 | 4 |  |
| 0x1b | rwInteger | +$24 | 4 |  |
| 0x1c | rwBool | +$1C | 1 |  |

## AoWE.TProductionControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwEObject | +$14 | 4 |  |
| 0x15 | rwEObject | +$1C | 4 |  |
| 0x16 | rwEObject | +$24 | 4 |  |
| 0x17 | rwData | +$20 | 1 |  |
| 0x18 | rwBool | +$18 | 1 |  |

## AoWE.TStructure : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0 | rwByte | +$25 | 1 |  |
| 0x62 | rwInteger | +$1C | 4 |  |
| 99 | rwByteEx | +$24 | 1 | default 0xff |

## AoWE.TStructureResource : HSEngine.TMultiHexMOR

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwBool | +$4C | 1 |  |
| 0x15 | rwString | +$48 | 4 |  |
| 0x16 | rwStrings | +$50 | 4 |  |
| 0x17 | rwInteger | +$54 | 4 |  |
| 0x1c | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TPlayerStructure : AoWE.TStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwByte | +$30 | 1 |  |
| 6 | rwStreamProc |  |  | indirect: *param_2 |
| 7 | rwByte | +$31 | 1 |  |

## AoWE.TPlayerStructureResource : AoWE.TStructureResource

| id | rw | offset | size | note |
|---|---|---|---|---|

## AoWE.TStructureTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwInteger | +$18 | 4 |  |
| 0x10 | rwByte | +$10 | 1 |  |
| 0x11 | rwByte | +$11 | 1 |  |
| 0x12 | rwByte | +$12 | 1 |  |
| 0x13 | rwByte | +$13 | 1 |  |
| 0x14 | rwInteger | +$14 | 4 |  |
| 0x15 | rwBool | +$1C | 1 |  |
| 0x16 | rwInteger | +$20 | 4 |  |
| 0x17 | rwInteger | +$24 | 4 |  |

## AoWE.TConstructStructureTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$18 | 4 |  |
| 0x15 | rwInteger | +$10 | 4 |  |
| 0x16 | rwByte | +$14 | 1 |  |

## AoWE.TStructureControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$0C | 4 |  |
| 0x15 | rwInteger | +$10 | 4 |  |

## AoWE.TFire : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwByte | +$1D | 1 |  |
| 6 | rwData | +$1C | 1 |  |
| 7 | rwByte | +$24 | 1 |  |
| 8 | rwByte | +$1E | 1 |  |

## AoWE.TFireResource : HSEngine.TMultiHexMOR

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$44 | 1 |  |

## AoWE.TTextControlItem : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 9 | rwInteger | +$08 | 4 |  |
| 10 | rwStrings | +$0C | 4 |  |
| 0xb | rwString | +$10 | 4 |  |

## AoWE.TFrozenWaterHS : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwShortint | +$0C | 1 |  |
| 0x1f | rwShortint | +$0D | 1 |  |

## AoWE.TDurationAbilityData : AoWE.TAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xb | rwByte | +$0C | 1 |  |
| 0xc | rwWord | +$0E | 2 |  |
| 0xd | rwByte | +$0D | 1 |  |
| 0xe | rwInteger | +$10 | 4 |  |

## AoWE.TMultiLevelAbilityData : AoWE.TAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwByte | +$0C | 1 |  |
| 0xb | rwWord | +$0E | 2 |  |

## AoWE.TUnitEnchantmentAbilityData : AoWE.TAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwWord | +$0C | 2 |  |
| 0x11 | rwShortintEx | +$0F | 1 | default 0xffffffff |
| 0x12 | rwShortintEx | +$0E | 1 | default 0xffffffff |

## AoWE.TUnitEnchantment : AoWE.TEnchantment

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$1C | 4 |  |
| 0x15 | rwInteger | +$18 | 4 |  |

## AoWE.TCosmeticSurgeryEnchantment : AoWE.TUnitEnchantment

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwInteger | +$20 | 4 |  |

## AoWE.TLeadershipAbilityData : AoWE.TMultiLevelAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwByte | +$10 | 1 |  |
| 0x1a | rwString | +$14 | 4 |  |

## AoWE.TStrikeCA : AoWE.TDamageCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$18 | 1 |  |

## AoWE.TPossessCA : AoWE.TSingleTargetCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwBool | +$10 | 1 |  |

## AoWE.TPossessedAbilityData : AoWE.TAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$0C | 4 |  |

## AoWE.TWebCA : AoWE.TSingleTargetCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwBool | +$10 | 1 |  |

## AoWE.TEntangleCA : AoWE.TSingleTargetCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwBool | +$10 | 1 |  |

## AoWE.TInvokeDeathCA : AoWE.TSingleTargetCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwBool | +$10 | 1 |  |

## AoWE.THealingAbilityData : AoWE.TAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwBool | +$0C | 1 |  |

## AoWE.THealingTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwInteger | +$10 | 4 |  |
| 0x1a | rwByte | +$14 | 1 |  |
| 0x1b | rwInteger | +$18 | 4 |  |
| 0x1c | rwByte | +$1C | 1 |  |

## AoWE.TDispelMagicCA : AoWE.TSingleTargetCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x32 | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TDispelMagicAbilityData : AoWE.TAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwBool | +$0C | 1 |  |
| 0xb | rwByte | +$0D | 1 |  |

## AoWE.TDispelMagicAbilityTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwInteger | +$10 | 4 |  |
| 0x1a | rwByte | +$14 | 1 |  |
| 0x1b | rwInteger | +$18 | 4 |  |
| 0x1c | rwByte | +$1C | 1 |  |

## AoWE.TRangedAttackCA : AoWE.TDamageCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$18 | 4 |  |

## AoWE.TCommandAbilityData : AoWE.TAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$0C | 4 |  |
| 0x15 | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TCommandedAbilityData : AoWE.TAbilityData

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$0C | 4 |  |
| 0x15 | rwInteger | +$14 | 4 |  |
| 0x16 | rwByte | +$10 | 1 |  |
| 0x17 | rwByte | +$18 | 1 |  |

## AoWE.TCommandCA : AoWE.TSingleTargetCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$10 | 4 |  |
| 0x15 | rwBool | +$14 | 1 |  |

## AoWE.TTutorialControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TAoWMapField : HSEngine.TMapField

| id | rw | offset | size | note |
|---|---|---|---|---|
| 4 | rwWord | +$18 | 2 |  |

## AoWE.TAoWHSMap : HSEngine.THSMap

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1f | rwData | +$13A | 1 |  |
| 7 | rwString | +$E8 | 4 |  |
| 0xb | rwStrings | +$F0 | 4 |  |
| 0xc | rwStrings | +$108 | 4 |  |
| 0xd | rwData | +$104 | 1 |  |
| 0x10 | rwByte | +$A4 | 1 |  |
| 0x11 | rwData | +$16C | 1 |  |
| 0x12 | rwStreamProc |  |  | indirect: *param_2 |
| 0x13 | rwInteger | +$174 | 4 |  |
| 0x14 | rwString | +$178 | 4 |  |
| 0x15 | rwEObject | +$140 | 4 |  |
| 0x16 | rwEObject | +$144 | 4 |  |
| 0x17 | rwBool | +$C9 | 1 |  |
| 0x18 | rwEObject | +$F8 | 4 |  |
| 0x19 | rwString | +$E4 | 4 |  |
| 0x1a | rwBool | +$C8 | 1 |  |
| 0x1b | rwByte | +$10C | 1 |  |
| 0x1c | rwInteger | +$230 | 4 |  |
| 0x1d | rwEObject | +$110 | 4 |  |
| 0x1e | rwEObject | +$F4 | 4 |  |
| 0x22 | rwData | +$118 | 1 |  |
| 0x23 | rwData | +$119 | 1 |  |
| 0x24 | rwInteger | +$22C | 4 |  |
| 0x25 | rwData | +$11A | 1 |  |
| 0x26 | rwEObject | +$FC | 4 |  |
| 0x27 | rwData | +$239 | 1 |  |
| 0x28 | rwEObject | +$188 | 4 |  |
|  | rwIntegerEx | +$EC | 4 | default 5 |
| 0x2a | rwEObject | +$13C | 4 |  |
| 0x2b | rwEObject | +$18C | 4 |  |
| 0x2c | rwEObject | +$F8 | 4 |  |
| 0x2d | rwData | +$14D | 1 |  |
| 0x2e | rwInteger | +$150 | 4 |  |
| 0x2f | rwInteger | +$154 | 4 |  |
| 0x30 | rwBool | +$148 | 1 |  |
| 0x31 | rwBool | +$14B | 1 |  |
| 0x32 | rwEObject | +$130 | 4 |  |
| 0x33 | rwInteger | +$158 | 4 |  |
| 0x34 | rwInteger | +$15C | 4 |  |
| 0x35 | rwBool | +$138 | 1 |  |
| 0x36 | rwEObject | +$100 | 4 |  |
| 0x37 | rwInteger | +$160 | 4 |  |
| 0x38 | rwEObject | +$124 | 4 |  |
| 0x3a | rwInteger | +$164 | 4 |  |
| 0x3b | rwBool | +$149 | 1 |  |
| 0x3c | rwEObject | +$114 | 4 |  |
| 0x3d | rwBool | +$14A | 1 |  |
| 0x3e | rwBool | +$191 | 1 |  |
|  | rwData | +$14C | 1 |  |

## AoWE.TSpell : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwStrings | +$24 | 4 |  |
| 0xb | rwEObject | +$28 | 4 |  |
| 0xc | rwStreamProc |  |  | indirect: *param_2 |
| 0xd | rwInteger | +$14 | 4 |  |
| 0xe | rwInteger | +$1C | 4 |  |
| 0xf | rwInteger | +$18 | 4 |  |
| 0x10 | rwData | +$20 | 1 |  |
| 0x11 | rwByte | +$21 | 1 |  |

## AoWE.TSpellTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwInteger | +$10 | 4 |  |
| 0x10 | rwInteger | +$14 | 4 |  |
| 0x11 | rwByte | +$18 | 1 |  |
| 0x12 | rwInteger | +$1C | 4 |  |

## AoWE.TSpellControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| iVar3 + 10 | rwEObject |  | 4 | indirect: uVar2 |

## AoWE.TSpellCastEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$18 | 4 |  |
| 0x15 | rwInteger | +$1C | 4 |  |

## AoWE.TUnitSpellCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$0C | 4 |  |
| 0x15 | rwByte | +$10 | 1 |  |
| 0x16 | rwByte | +$11 | 1 |  |
| 0x17 | rwData | +$14 | 8 |  |
| 0x18 | rwInteger | +$1C | 4 |  |

## AoWE.TUnitSpellTE : AoWE.TSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwStreamProc |  |  | indirect: *param_2 |
| 0x1f | rwData | +$2C | 8 |  |
| 0x20 | rwByte | +$28 | 1 |  |

## AoWE.TEnchantment : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwByte | +$14 | 1 |  |
| 0xb | rwByte | +$0C | 1 |  |
| 0xc | rwInteger | +$10 | 4 |  |
| 0xd | rwInteger | +$08 | 4 |  |

## AoWE.TPlayerMagicEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$18 | 1 |  |
| 0x15 | rwInteger | +$20 | 4 |  |
| 0x16 | rwInteger | +$24 | 4 |  |
| 0x17 | rwString | +$28 | 4 |  |
| 0x18 | rwInteger | +$1C | 4 |  |

## AoWE.TPlayerMagicControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$24 | 4 |  |
| 0x15 | rwIntegerEx | +$2C | 4 | default 0x32 |
| 0x16 | rwStreamProc |  |  | indirect: *param_2 |
| 0x17 | rwInteger | +$34 | 4 |  |
| 0x18 | rwInteger | +$38 | 4 |  |
| 0x19 | rwEObject | +$3C | 4 |  |
| 0x1a | rwData | +$44 | 1 |  |
| 0x1b | rwInteger | +$18 | 4 |  |
| 0x1c | rwInteger | +$1C | 4 |  |
| 0x1d | rwBool | +$0C | 1 |  |
| 0x1e | rwInteger | +$08 | 4 |  |

## AoWE.TChangePlayerMagicTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$10 | 1 |  |
| 0x15 | rwByte | +$11 | 1 |  |
| 0x16 | rwInteger | +$14 | 4 |  |
| 0x17 | rwInteger | +$18 | 4 |  |

## AoWE.TGlobalEnchantment : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwInteger | +$08 | 4 |  |
| 0xb | rwData | +$18 | 1 |  |
| 0xc | rwByte | +$19 | 1 |  |
| 0xd | rwString | +$1C | 4 |  |
| 0xe | rwInteger | +$20 | 4 |  |
| 0xf | rwInteger | +$14 | 4 |  |

## AoWE.TGlobalEnchantmentEventLog : EventLog.TLocationTextEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwByte | +$20 | 1 |  |

## AoWE.TGlobalMagicControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwEObject | +$14 | 4 |  |
| 0xb | rwInteger | +$08 | 4 |  |
| 0 | rwData | +$18 | 0x24 |  |

## AoWE.TChangeGlobalMagicTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$10 | 1 |  |
| 0x15 | rwByte | +$11 | 1 |  |
| 0x16 | rwInteger | +$14 | 4 |  |
| 0x17 | rwInteger | +$18 | 4 |  |

## AoWE.TUnitControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwInteger | +$08 | 4 |  |

## AoWE.TAbstractUnit : AoWE.TAbilityOwner

| id | rw | offset | size | note |
|---|---|---|---|---|
| 4 | rwInteger | +$1C | 4 |  |
|  | rwIntegerEx | +$18 | 4 | default 0xffffffff |
| 6 | rwByte | +$26 | 1 |  |
| 0x2f | rwByte | +$24 | 1 |  |

## AoWE.TUnit : AoWE.TAbstractUnit

| id | rw | offset | size | note |
|---|---|---|---|---|
| 7 | rwByte | +$3C | 1 |  |
| 8 | rwByte | +$3D | 1 |  |
| 9 | rwByte | +$3E | 1 |  |
| 10 | rwWord |  | 2 | indirect: (int)&uStack_8 + 2 |
| 10 | rwWord |  | 2 | indirect: (int)&uStack_8 + 2 |
| 10 | rwWord |  | 2 | indirect: (int)&uStack_8 + 2 |

## AoWE.TUnitGFXResource : Engine.TEResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwStreamProc |  |  | indirect: *param_2 |
| 6 | rwString | +$24 | 4 |  |
| 7 | rwString | +$18 | 4 |  |
| 8 | rwInteger | +$1C | 4 |  |
| 10 | rwData | +$30 | 1 |  |
| 0xf | rwEObject | +$34 | 4 |  |
| 0x10 | rwEObject | +$38 | 4 |  |
| 0x11 | rwEObject | +$3C | 4 |  |
| 0x12 | rwEObject | +$40 | 4 |  |
| 0x13 | rwEObject | +$44 | 4 |  |

## AoWE.TUnitHS : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 9 | rwByte | +$14 | 1 |  |

## AoWE.TAbstractUnitResource : Engine.TEResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 8 | rwInteger | +$18 | 4 |  |

## AoWE.TUnitResource : AoWE.TAbstractUnitResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwString | +$1C | 4 |  |
| 0xb | rwString | +$24 | 4 |  |
| 0xc | rwData | +$28 | 1 |  |
| 0xd | rwByte | +$20 | 1 |  |
| 0xe | rwByte | +$29 | 1 |  |
| 0xf | rwByte | +$2A | 1 |  |
| 0x10 | rwByte | +$2B | 1 |  |
| 0x11 | rwByte | +$2C | 1 |  |
| 0x12 | rwByte | +$2D | 1 |  |
| 0x13 | rwByte | +$2E | 1 |  |
| 0x14 | rwByte | +$2F | 1 |  |
| 0x15 | rwData | +$30 | 1 |  |
| 0x16 | rwData | +$21 | 1 |  |
| 0x17 | rwData | +$31 | 1 |  |
| 0x18 | rwByte | +$44 | 1 |  |
| 0x19 | rwEObject | +$38 | 4 |  |
| 0x1a | rwStrings | +$48 | 4 |  |
| 0x1b | rwInteger | +$4C | 4 |  |
| 0x1c | rwData | +$50 | 1 |  |
| 0x1d | rwData | +$51 | 1 |  |
| 0x1e | rwEObject | +$3C | 4 |  |
| 0x1f | rwEObject | +$40 | 4 |  |

## AoWE.THeroUpgradeTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwByte | +$15 | 1 |  |
| 0x1f | rwByte | +$16 | 1 |  |
| 0x20 | rwByte | +$17 | 1 |  |
| 0x21 | rwByte | +$18 | 1 |  |
| 0x22 | rwByte | +$19 | 1 |  |
| 0x23 | rwByte | +$1A | 1 |  |
| 0x24 | rwEObject | +$1C | 4 |  |
| 0x25 | rwInteger | +$10 | 4 |  |
| 0x26 | rwByte | +$14 | 1 |  |

## AoWE.THeroUpgradeEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwInteger | +$18 | 4 |  |
| 0x1a | rwByte | +$1C | 1 |  |
| 0x1b | rwByte | +$1D | 1 |  |
| 0x1c | rwInteger | +$20 | 4 |  |

## AoWE.THeroEmergeEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x27 | rwInteger | +$18 | 4 |  |
| 0x28 | rwInteger | +$1C | 4 |  |
| 0x29 | rwString | +$20 | 4 |  |
| 0x2a | rwString | +$28 | 4 |  |
| 0x2b | rwData | +$24 | 1 |  |

## AoWE.THero : AoWE.TAbstractUnit

| id | rw | offset | size | note |
|---|---|---|---|---|
| 8 | rwInteger | +$44 | 4 |  |
| 7 | rwInteger | +$3C | 4 |  |
| 9 | rwInteger |  | 4 | indirect: &uStack_14 |
| 10 | rwString | +$60 | 4 |  |
| 0xb | rwString | +$64 | 4 |  |
| 0xc | rwByte | +$68 | 1 |  |
| 0xd | rwByte | +$80 | 1 |  |
| 0xe | rwInteger | +$84 | 4 |  |
| 0xf | rwData | +$69 | 1 |  |
| 0x10 | rwByte | +$6A | 1 |  |
| 0x11 | rwByte | +$6B | 1 |  |
| 0x12 | rwByte | +$6C | 1 |  |
| 0x13 | rwByte | +$6D | 1 |  |
| 0x14 | rwByte | +$6E | 1 |  |
| 0x15 | rwByte | +$6F | 1 |  |
| 0x16 | rwByte | +$4C | 1 |  |
| 0x17 | rwBool | +$54 | 1 |  |
| 0x18 | rwInteger | +$48 | 4 |  |
|  | rwData | +$55 | 1 |  |
| 0x1a | rwInteger | +$58 | 4 |  |
| 0x1b | rwByte | +$5C | 1 |  |
| 0x1d | rwByte | +$79 | 1 |  |
| 0x1e | rwByte | +$7A | 1 |  |
| 0x1f | rwInteger | +$88 | 4 |  |
| 0x21 | rwBool | +$78 | 1 |  |
| 0x22 | rwInteger | +$8C | 4 |  |
| 0x23 | rwIntegerEx | +$90 | 4 | default 0xffffffff |
| 0x24 | rwEObject | +$74 | 4 |  |
| 0x25 | rwEObject | +$70 | 4 |  |
| 0x26 | rwString | +$94 | 4 |  |
| 0x27 | rwInteger | +$50 | 4 |  |

## AoWE.THeroUpdateTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$10 | 4 |  |
| 0x15 | rwData | +$14 | 1 |  |
| 0x16 | rwInteger | +$18 | 4 |  |
| 0x17 | rwInteger | +$1C | 4 |  |

## AoWE.THeroResource : AoWE.TAbstractUnitResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwString | +$1C | 4 |  |
| 0xb | rwByte | +$20 | 1 |  |
| 0xc | rwData | +$21 | 1 |  |
| 0xd | rwData | +$22 | 1 |  |
| 0xe | rwBool | +$23 | 1 |  |
| 0xf | rwByte | +$24 | 1 |  |
| 0x10 | rwByte | +$25 | 1 |  |
| 0x11 | rwByte | +$26 | 1 |  |
| 0x12 | rwByte | +$27 | 1 |  |
| 0x13 | rwByte | +$28 | 1 |  |
| 0x14 | rwByte | +$29 | 1 |  |
| 0x1d | rwEObject | +$2C | 4 |  |
| 0x1e | rwInteger | +$30 | 4 |  |

## AoWE.THeroControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwEObject | +$14 | 4 |  |

## AoWE.THeroLibrary : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwString | +$0C | 4 |  |
| 0x15 | rwInteger | +$10 | 4 |  |

## AoWE.THeroLibraryManager : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwEObject | +$08 | 4 |  |

## AoWE.TLeader : AoWE.THero

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x2d | rwByteEx | +$9C | 1 | default 5 |
| 0x2e | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TArmyID : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwByte | +$0C | 1 |  |
| 0xb | rwInteger | +$10 | 4 |  |
| 0xc | rwStreamProc |  |  | indirect: *param_2 |

## AoWE.TArmyView : AoWE.TArmy

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwData | +$2C | 0x10 |  |
| 0x29 | rwWord | +$3C | 2 |  |
| 0x2a | rwData | +$40 | 0x20 |  |

## AoWE.TArmyEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwEObject | +$18 | 4 |  |
| 0x10 | rwString | +$1C | 4 |  |
| 0x11 | rwStrings | +$20 | 4 |  |
| 0x12 | rwInteger | +$24 | 4 |  |
| 0x13 | rwStreamProc |  |  | indirect: *param_2 |
| 0x14 | rwStreamProc |  |  | indirect: *param_2 |
| 0x15 | rwBool | +$30 | 1 |  |

## AoWE.TArmyInfoEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwEObject | +$18 | 4 |  |
| 0x10 | rwStrings | +$20 | 4 |  |
| 0x11 | rwData | +$1C | 1 |  |
| 0x12 | rwString | +$24 | 4 |  |
| 0x13 | rwString | +$28 | 4 |  |
| 0x14 | rwString | +$2C | 4 |  |

## AoWE.TArmy : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 4 | rwByte | +$12 | 1 |  |
| 5 | rwByte | +$13 | 1 |  |
| 6 | rwByte | +$14 | 1 |  |
| 7 | rwByte | +$15 | 1 |  |
| 8 | rwByte | +$25 | 1 |  |
| 9 | rwByte | +$26 | 1 |  |
| 10 | rwByte | +$27 | 1 |  |
| 0xd | rwData | +$28 | 1 |  |
| 0xb | rwData | +$24 | 1 |  |
| 0xc | rwData | +$11 | 1 |  |

## AoWE.TArmyHS : AoWE.TUnitHS

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwEObject | +$1C | 4 |  |

## AoWE.TItemTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$10 | 4 |  |
| 0x15 | rwData | +$14 | 1 |  |
| 0x16 | rwInteger | +$18 | 4 |  |

## AoWE.TItem : AoWE.TAbilityOwner

| id | rw | offset | size | note |
|---|---|---|---|---|
| 7 | rwInteger | +$40 | 4 |  |
| 8 | rwString | +$18 | 4 |  |
| 9 | rwString | +$30 | 4 |  |
| 10 | rwData | +$45 | 1 |  |
| 0xb | rwByte | +$46 | 1 |  |
| 0xc | rwByte | +$47 | 1 |  |
| 0xd | rwByte | +$48 | 1 |  |
| 0xe | rwByte | +$49 | 1 |  |
| 0xf | rwData | +$34 | 1 |  |
| 0x10 | rwBool | +$44 | 1 |  |
| 0x11 | rwInteger | +$14 | 4 |  |
| 0x12 | rwStrings | +$3C | 4 |  |
| 0x13 | rwInteger | +$2C | 4 |  |
| 0x14 | rwInteger | +$38 | 4 |  |
| 0x15 | rwIntegerEx | +$24 | 4 | default 0xffffffff |
| 0x16 | rwString | +$28 | 4 |  |

## AoWE.TItemControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 9 | rwInteger | +$18 | 4 |  |

## AoWE.TItemLibrary : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwString | +$18 | 4 |  |
| 0x15 | rwInteger | +$1C | 4 |  |

## AoWE.TItemLibraryManager : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwEObject | +$08 | 4 |  |

## AoWE.TItemGFX : Engine.TEResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 6 | rwString | +$18 | 4 |  |
| 7 | rwInteger | +$1C | 4 |  |
| 8 | rwData | +$20 | 1 |  |
| 9 | rwBool | +$2C | 1 |  |

## AoWE.TItemHS : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 4 | rwEObject | +$0C | 4 |  |
| 5 | rwData | +$10 | 1 |  |

## AoWTer.TAoWTerrainResource : Terrain.TTerrainMOR

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$48 | 4 |  |

## SmokeCloud.TSmokeCloud : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwByte | +$14 | 1 |  |
| 0x10 | rwInteger | +$18 | 4 |  |
| 0x11 | rwBool | +$1C | 1 |  |
| 0x12 | rwByte | +$1D | 1 |  |
| 0x13 | rwEObject | +$20 | 4 |  |

## GlobalTargetSpells.TGlobalTargetSpellTE : AoWE.TSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$20 | 4 |  |

## GlobalTargetSpells.TWatcherHS : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwEObject | +$10 | 4 |  |

## GlobalTargetSpells.TTornadoTE : GlobalTargetSpells.TGlobalTargetSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|

## GlobalTargetSpells.TVortexTE : GlobalTargetSpells.TGlobalTargetSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|

## Mountain.TRaisedMountain : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwShortintEx | +$1D | 1 | default 0xffffffff |
| 0x29 | rwShortintEx | +$1E | 1 | default 0xffffffff |
| 0x2a | rwShortintEx | +$1F | 1 | default 0xffffffff |

## Sign.TSign : AoWE.TStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 7 | rwStrings | +$30 | 4 |  |
| 8 | rwStreamProc |  |  | indirect: *param_2 |

## Sign.TUpdateSignTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwStrings | +$10 | 4 |  |
| 0x10 | rwByte | +$14 | 1 |  |
| 0x11 | rwByte | +$15 | 1 |  |
| 0x12 | rwByte | +$16 | 1 |  |

## Teleport.TTeleport : AoWE.TStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 7 | rwByte | +$30 | 1 |  |
| 8 | rwByte | +$31 | 1 |  |
| 9 | rwByte | +$32 | 1 |  |
| 10 | rwData | +$33 | 1 |  |

## City.TCity : AoWE.TPlayerStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xc | rwString | +$48 | 4 |  |
| 0xd | rwByte | +$45 | 1 |  |
| 0xf | rwData | +$4C | 1 |  |
| 0x10 | rwByte | +$4D | 1 |  |
| 0x12 | rwEObject | +$50 | 4 |  |
| 0x16 | rwData | +$44 | 1 |  |
| 0x1b | rwData | +$74 | 1 |  |
| 0x1d | rwEObject | +$58 | 4 |  |

## City.TCityRebellionEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$18 | 4 |  |
| 0x15 | rwInteger | +$1C | 4 |  |
| 0x16 | rwInteger | +$20 | 4 |  |
| 0x17 | rwString | +$24 | 4 |  |

## City.TCityEnchantment : AoWE.TGlobalEnchantment

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$24 | 1 |  |
| 0x15 | rwInteger | +$28 | 4 |  |

## CitySpells.TCityTargetSpellTE : AoWE.TSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$20 | 4 |  |
| 0x15 | rwByte | +$24 | 1 |  |

## CitySpells.TTownGateTE : CitySpells.TCityTargetSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$2C | 4 |  |

## Farm.TFarm : AoWE.TPlayerStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$44 | 1 |  |

## Cave.TCave : AoWE.TStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 6 | rwData | +$30 | 1 |  |

## Mine.TMine : AoWE.TPlayerStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$3C | 1 |  |

## ManaCrystals.TManaCrystals : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwInteger | +$1C | 4 |  |
| 6 | rwData | +$20 | 1 |  |

## PrdPlace.TProductionPlace : AoWE.TPlayerStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 8 | rwEObject | +$44 | 4 |  |
| 9 | rwData | +$49 | 1 |  |
| 10 | rwData | +$48 | 1 |  |

## PrdPlace.TProductionPlaceResource : AoWE.TPlayerStructureResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x12 | rwStreamProc |  |  | indirect: *param_2 |

## ExploreS.TExplorationSite : AoWE.TStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwEObject | +$34 | 4 |  |
| 6 | rwData | +$30 | 1 |  |

## ExploreS.TExplorationSiteResource : AoWE.TStructureResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x19 | rwStreamProc |  |  | indirect: *param_2 |

## ItemExpS.TItemExplorationSite : ExploreS.TExplorationSite

| id | rw | offset | size | note |
|---|---|---|---|---|
| 8 | rwEObject | +$3C | 4 |  |
| 9 | rwData | +$38 | 1 |  |

## ItemExpS.TItemExplorationSiteEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwStreamProc |  |  | indirect: *param_2 |
| 0x15 | rwStrings | +$1C | 4 |  |
| 0x16 | rwString | +$20 | 4 |  |

## Tower.TTower : AoWE.TPlayerStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$3C | 1 |  |

## PoisonP.TPoisonPlant : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwShortintEx | +$1D | 1 | default 0xffffffff |
| 0x29 | rwShortintEx | +$1E | 1 | default 0xffffffff |
| 0x2a | rwShortintEx | +$1F | 1 | default 0xffffffff |

## Gems.TGems : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 5 | rwInteger | +$1C | 4 |  |
| 6 | rwData | +$20 | 1 |  |

## Dungeon.TDungeon : ExploreS.TExplorationSite

| id | rw | offset | size | note |
|---|---|---|---|---|
| 8 | rwEObject | +$38 | 4 |  |
| 9 | rwData | +$3C | 1 |  |

## Dungeon.TDungeonResource : ExploreS.TExplorationSiteResource

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwStreamProc |  |  | indirect: *param_2 |

## HolyG.THolyGround : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwShortintEx | +$1D | 1 | default 0xffffffff |
| 0x29 | rwShortintEx | +$1E | 1 | default 0xffffffff |
| 0x2a | rwShortintEx | +$1F | 1 | default 0xffffffff |

## UnHolyG.TUnHolyGround : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwShortintEx | +$1D | 1 | default 0xffffffff |
| 0x29 | rwShortintEx | +$1E | 1 | default 0xffffffff |
| 0x2a | rwShortintEx | +$1F | 1 | default 0xffffffff |

## PoisonC.TPoisonCloud : HSEngine.TMultiHexMO

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwByte | +$14 | 1 |  |
| 0x10 | rwInteger | +$18 | 4 |  |
| 0x11 | rwBool | +$1C | 1 |  |
| 0x12 | rwByte | +$1D | 1 |  |

## Storms.TStormSpellTE : AoWE.TSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$24 | 1 |  |
| 0x15 | rwByte | +$25 | 1 |  |
| 0x16 | rwByte | +$26 | 1 |  |

## Altar.TAltar : AoWE.TPlayerStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwByte | +$41 | 1 |  |
| 0x10 | rwData | +$40 | 1 |  |

## PowerNode.TPowerNode : AoWE.TPlayerStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwData | +$3C | 1 |  |

## FlagEvents.TFlagEvent : HSEngine.TMapObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$14 | 4 |  |
| 0x1f | rwData | +$10 | 1 |  |

## FlagEvents.TFlagMessageEvent : FlagEvents.TFlagEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwStrings | +$1C | 4 |  |
| 0x29 | rwString | +$18 | 4 |  |

## FlagEvents.TTutorialMessageEvent : FlagEvents.TFlagEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwStrings | +$18 | 4 |  |

## MoveOnEvents.TMoveOnEvent : HSEngine.TMapObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$14 | 4 |  |
| 0x1f | rwByte | +$10 | 1 |  |

## MoveOnEvents.TChangeSongMoveOnEvent : MoveOnEvents.TMoveOnEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwString | +$18 | 4 |  |

## MoveOnEvents.TPlaySampleMoveOnEvent : MoveOnEvents.TMoveOnEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwString | +$18 | 4 |  |

## MoveOnEvents.TShowMessageMoveOnEvent : MoveOnEvents.TMoveOnEvent

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwStrings | +$18 | 4 |  |

## OverlayObject.TOverlayObjectResource : HSEngine.TMultiHexMOR

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwInteger | +$44 | 4 |  |

## WizardsTower.TWizardsTower : AoWE.TStructure

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwBool | +$30 | 1 |  |
| 0x1f | rwData | +$31 | 2 |  |
| 0x20 | rwByte | +$33 | 1 |  |
| 0x21 | rwData | +$34 | 4 |  |

## Arena.TArenaTE : AoWE.TStructureTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwStreamProc |  |  | indirect: *param_2 |

## IndependentAG.TGuardAreaAG : AoWE.TAIGroup

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x32 | rwInteger | +$50 | 4 |  |

## IndependentAG.TPatrolAG : AoWE.TAIGroup

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x28 | rwInteger | +$50 | 4 |  |
| 0x29 | rwInteger | +$54 | 4 |  |
| 0x2a | rwByte | +$58 | 1 |  |
| 0x2b | rwInteger | +$5C | 4 |  |

## AoWSetup.TSetupPackage : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$08 | 4 |  |
| 0x15 | rwInteger | +$0C | 4 |  |
| 0x16 | rwInteger | +$10 | 4 |  |

## AoWSetup.TRemotePlayer : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwString | +$08 | 4 |  |
| 0x15 | rwData | +$0C | 4 |  |
| 0x16 | rwByte | +$10 | 1 |  |
| 0x17 | rwData | +$11 | 1 |  |
| 0x18 | rwInteger | +$14 | 4 |  |

## AoWSetup.TPlayerSetupSettings : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwByte | +$20 | 1 |  |
| 0xb | rwData | +$08 | 8 |  |
| 0xc | rwByte | +$18 | 1 |  |
| 0xd | rwData | +$21 | 1 |  |
| 0xe | rwEObject | +$1C | 4 |  |
| 0xf | rwData | +$19 | 1 |  |
| 0x10 | rwData | +$10 | 8 |  |

## AoWSetup.TSetupSettings : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwString | +$10 | 4 |  |
| 0xb | rwData | +$24 | 1 |  |
| 0xc | rwBool | +$25 | 1 |  |
| 0xd | rwString | +$14 | 4 |  |
| 0xe | rwData | +$28 | 1 |  |
| 0xf | rwData | +$29 | 1 |  |
| 0x10 | rwBool | +$2A | 1 |  |
| 0x11 | rwInteger | +$2C | 4 |  |
| 0x12 | rwBool | +$26 | 1 |  |
| 0x13 | rwInteger | +$30 | 4 |  |
| 0x14 | rwInteger | +$34 | 4 |  |
| 0x15 | rwEObject | +$38 | 4 |  |
| 0x16 | rwInteger | +$0C | 4 |  |
| 0x17 | rwInteger | +$20 | 4 |  |
| 0x18 | rwBool | +$27 | 1 |  |
| 0x19 | rwData | +$3C | 1 |  |
| 0x1a | rwInteger | +$18 | 4 |  |
| 0x1b | rwInteger | +$1C | 4 |  |
| 0x1c | rwData | +$3D | 1 |  |
| 0x1d | rwBool | +$3E | 1 |  |

## SummonSpells.TSummonSpellTE : AoWE.TSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwStreamProc |  |  | indirect: *param_2 |

## UnitSpells.TDispelMagicSpellCA : AoWE.TDispelMagicCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x3c | rwInteger | +$14 | 4 |  |
| 0x3d | rwInteger | +$18 | 4 |  |

## GlobalSpells.TWarpPartyTE : AoWE.TSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$24 | 4 |  |

## GlobalSpells.TDisjunctionTE : AoWE.TSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$24 | 4 |  |
| 0x15 | rwInteger | +$20 | 4 |  |

## GlobalEnchantmentSpells.TGlobalEnchantmentSpellTE : AoWE.TSpellTE

| id | rw | offset | size | note |
|---|---|---|---|---|

## GlobalEnchantmentSpells.THatredEnchantment : AoWE.TGlobalEnchantment

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$24 | 4 |  |

## GlobalEnchantmentSpells.THarmonyEnchantment : AoWE.TGlobalEnchantment

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$24 | 4 |  |

## GlobalEnchantmentSpells.TFloodControl : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$08 | 4 |  |
| 0x15 | rwInteger | +$0C | 4 |  |
| 0x16 | rwData | +$10 | *(int *)(param_1 + 8) * *(int *)(param_1 + 0xc) * 2 |  |

## GlobalEnchantmentSpells.TFloodEnchantment : AoWE.TGlobalEnchantment

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwInteger | +$28 | 4 |  |
| 0x15 | rwEObject | +$2C | 4 |  |
| 0x16 | rwBool | +$24 | 1 |  |
| 0x17 | rwByte | +$26 | 1 |  |
| 0x18 | rwShortintEx | +$25 | 1 | default 0xffffffff |

## CombatSpells.TCombatSpellCA : AoWE.TDamageCA

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwInteger | +$18 | 4 |  |
| 0x1f | rwInteger | +$1C | 4 |  |

## CombatSpells.TExclusiveCombatSpellCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$0C | 1 |  |
| 0x15 | rwByte | +$0D | 1 |  |
| 0x16 | rwInteger | +$10 | 4 |  |
| 0x17 | rwBool | +$14 | 1 |  |
| 0x18 | rwInteger | +$18 | 4 |  |

## CombatSpells.TMultiTargetCombatSpellCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$0C | 1 |  |
| 0x15 | rwStreamProc |  |  | indirect: *param_2 |
| 0x16 | rwInteger | +$14 | 4 |  |
| 0x17 | rwBool | +$18 | 1 |  |
| 0x18 | rwInteger | +$1C | 4 |  |

## CombatSpells.TTacticalCombatTerrorCA : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$0C | 1 |  |
| 0x15 | rwByte | +$0D | 1 |  |
| 0x16 | rwInteger | +$10 | 4 |  |
| 0x17 | rwBool | +$14 | 1 |  |

## Animation.TAnimation : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwData | +$14 | 0x10 |  |
| 0xb | rwByte | +$08 | 1 |  |
| 0xc | rwByte | +$09 | 1 |  |
| 0xd | rwByte | +$0A | 1 |  |
| 0xe | rwInteger | +$10 | 4 |  |

## Animation.TAnimationTE : NetworkE.TTokenEvent

| id | rw | offset | size | note |
|---|---|---|---|---|

## EventLog.TEventLog : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwInteger | +$08 | 4 |  |
| 0xb | rwByte | +$10 | 1 |  |
| 0xc | rwInteger | +$0C | 4 |  |

## EventLog.TEventLogbook : Engine.TEObject

| id | rw | offset | size | note |
|---|---|---|---|---|
| 10 | rwEObject | +$08 | 4 |  |
| 0xb | rwInteger | +$10 | 4 |  |

## EventLog.TTextEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0xf | rwString | +$18 | 4 |  |

## EventLog.TLocationTextEventLog : EventLog.TTextEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwByte | +$1C | 1 |  |
| 0x15 | rwByte | +$1D | 1 |  |
| 0x16 | rwByte | +$1E | 1 |  |

## EventLog.TShowMessageEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwStrings | +$18 | 4 |  |

## EventLog.TGameOverEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x14 | rwStrings | +$18 | 4 |  |

## EventLog.TMessageEventLog : EventLog.TEventLog

| id | rw | offset | size | note |
|---|---|---|---|---|
| 0x1e | rwStrings | +$20 | 4 |  |
| 0x1f | rwData | +$24 | 1 |  |
| 0x20 | rwData | +$25 | 1 |  |
| 0x21 | rwString | +$18 | 4 |  |
