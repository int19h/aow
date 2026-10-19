## Animation.TAnimation

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FXhx | undefined1 | getter |
| +$09 | FYhx | undefined1 | getter |
| +$0A | FLhx | undefined1 | getter |
| +$0B | FLevel | undefined1 | getter |

## AoWE.TAIBudgetManager

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAIBudgetList | TAIBudgetList | delegation |

## AoWE.TAIGroup

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FLeader | int | setter |
| +$40 | FGoldBudget | undefined4 | getter |
| +$44 | FManaBudget | undefined4 | getter |

## AoWE.TAIGroupControlTarget

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FTargetGold | undefined4 | getter |

## AoWE.TAIGroupCooperationControl

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FAIRecruitmentGroupList | TAIRecruitmentGroupList | delegation |

## AoWE.TAIGroupProductionControl

| offset | field | c type | from |
|---|---|---|---|
| +$34 | FAIGroupUnitProductionList | TAIGroupUnitProductionList | delegation |

## AoWE.TAIGroupRecruitControl

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FUnitList | TUnitList | delegation |

## AoWE.TAIGroupUnitProductionList

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEObjectList | TEObjectList | delegation |

## AoWE.TAIMoveExecuter

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FAIMoveExecuterUnitList | TAIMoveExecuterUnitList | delegation |

## AoWE.TAIPlayerControl

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FProcessCyclesMax | undefined4 | getter |

## AoWE.TAbstractUnit

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityCount | undefined4 | getter |

## AoWE.TAdjacentArmy

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FMovepath | TMovepath | delegation |

## AoWE.TAdjustableAbility

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FAbilityType | undefined1 | getter |

## AoWE.TAdjustableUnit

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FAttack | undefined1 | getter |
| +$3D | FDefense | undefined1 | getter |
| +$3E | FResistance | undefined1 | getter |
| +$3F | FHits | undefined1 | getter |
| +$40 | FDamage | undefined1 | getter |
| +$41 | FImmunityTypes | undefined2 | getter |
| +$43 | FProtectionTypes | undefined2 | getter |
| +$45 | FHitPoints | undefined1 | getter |

## AoWE.TAgeOfWondersEngine

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FHSEngine | undefined4 | setter |

## AoWE.TAoWCampaign

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FStream | TStream | delegation |

## AoWE.TArmy

| offset | field | c type | from |
|---|---|---|---|
| +$12 | FPlayer | undefined1 | getter |
| +$18 | FUpkeep | undefined1 | getter |

## AoWE.TArmyEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FText | String | getter |

## AoWE.TArmyInfoEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FText | String | getter |

## AoWE.TCombatData

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FCombatPlayerList | TCombatPlayerList | delegation |

## AoWE.TCombatUnit

| offset | field | c type | from |
|---|---|---|---|
| +$4C | FAbilityOwner | undefined4 | getter |
| +$50 | FParty | int | setter |

## AoWE.TCombatViewer

| offset | field | c type | from |
|---|---|---|---|
| +$0D | FSpeed | char | setter |

## AoWE.TCombatWall

| offset | field | c type | from |
|---|---|---|---|
| +$4D | FHitPoints | undefined1 | getter |
| +$4E | FLocked | undefined1 | getter |

## AoWE.TCommandAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityID | undefined4 | getter |

## AoWE.TCommandedAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityID | undefined4 | getter |

## AoWE.TCustomAbilityList

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbCount | undefined4 | getter |

## AoWE.TDiplomaticRelationHistoryList

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEObjectList | TEObjectList | delegation |

## AoWE.TDurationAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0E | FAbilityID | undefined2 | getter |

## AoWE.TFastCombat

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FCombatData | TCombatData | delegation |

## AoWE.TFire

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FShowPriority | undefined4 | getter |

## AoWE.TGlobalEnchantment

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FName | String | getter |
| +$20 | FUpkeep | undefined4 | getter |

## AoWE.TGlobalMagicControl

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FGlobalEnchantmentList | TGlobalEnchantmentList | delegation |

## AoWE.THero

| offset | field | c type | from |
|---|---|---|---|
| +$44 | FHeroResourceIndex | int | setter |
| +$48 | FExperience | undefined4 | getter |
| +$4C | FUnitLevel | undefined1 | getter |
| +$60 | FName | String | getter |
| +$64 | FNickname | String | getter |
| +$69 | FGender | undefined1 | getter |
| +$70 | FHeroItems | THeroItems | delegation |
| +$79 | FMovePoints | undefined1 | getter |
| +$7A | FHitPoints | undefined1 | getter |
| +$80 | FCastingPoints | undefined1 | getter |

## AoWE.THeroEmergeEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FText | String | getter |

## AoWE.THeroInventory

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FAbstractUnit | TAbstractUnit | delegation |

## AoWE.THeroItems

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FAbstractUnit | TAbstractUnit | delegation |

## AoWE.THeroPowerSource

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FAbstractUnit | TAbstractUnit | delegation |

## AoWE.TItem

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FOwnerName | String | getter |
| +$2C | FObtainValue | int | getter |

## AoWE.TMeleeRound

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FCapacity | int | setter |
| +$18 | FAttackerDV | undefined4 | getter |
| +$1C | FDefenderDV | undefined4 | getter |

## AoWE.TMultiLevelAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0E | FAbilityID | undefined2 | getter |

## AoWE.TPlayer

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FArmyList | TArmyList | delegation |

## AoWE.TPlayerList

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEObjectList | TEObjectList | delegation |

## AoWE.TPlayerMagicControl

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FCheatEnabled | undefined1 | getter |
| +$24 | FMana | int | setter |
| +$3C | FEnchantmentList | TEnchantmentList | delegation |
| +$40 | FPowerSourceList | TPowerSourceList | delegation |

## AoWE.TProductionControl

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FUnitProductionList | TUnitProductionList | delegation |

## AoWE.TRaceResource

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FRaceIndex | undefined4 | getter |

## AoWE.TRangedAttackAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FRangeRA | undefined1 | getter |
| +$2B | FDamageTypesRA | undefined2 | getter |
| +$2D | FAttackRepeatRA | undefined1 | getter |

## AoWE.TSelectedArmy

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FMoveSettingsList | TMoveSettingsList | delegation |

## AoWE.TStrikeAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FMeleeRound | TMeleeRound | delegation |

## AoWE.TStructure

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FAoWMapField | TAoWMapField | delegation |

## AoWE.TUnit

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FExperience | undefined1 | getter |
| +$3D | FMovePoints | undefined1 | getter |
| +$3E | FHitPoints | undefined1 | getter |
| +$40 | FUnitResource | int | setter |

## AoWE.TUnitEnchantmentAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityID | undefined2 | getter |
| +$10 | FEnchantment | undefined4 | setter |

## AoWE.TUnitGFXResource

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FIndex | undefined4 | getter |

## AoWE.TUnitHS

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FShowPriority | undefined4 | getter |
| +$10 | FUnitGFXResource | TUnitGFXResource | delegation |

## AoWE.TUnitIndexList

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FUnitIndex | undefined4 | getter |

## AoWE.TUnitResource

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FAbilityOwner | TAbilityOwner | delegation |
| +$4C | FObtainValue | undefined4 | getter |

## AoWE.TUnitSelectionControl

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FUnitCategoryList | TUnitCategoryList | delegation |

## AoWE.TUnitSelectorAAI

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FUnitSelector | int | setter |

## AoWE.TWallUnit

| offset | field | c type | from |
|---|---|---|---|
| +$3D | FHitPoints | undefined1 | getter |
| +$3E | FHits | undefined1 | getter |

## AoWSetup.TSetupControl

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FSetupSettings | TSetupSettings | delegation |

## City.TCity

| offset | field | c type | from |
|---|---|---|---|
| +$45 | FRace | undefined1 | getter |
| +$48 | FName | String | getter |

## City.TCityEnchantment

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FLocation | undefined3 | getter |

## City.TCityOverlayHS

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FMode | char | setter |

## Crops.TPlayerCropStructure

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FIncome | undefined1 | getter |

## EventLog.TTextEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FText | String | getter |

## HeroGrid.THeroGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1E0 | FHeroList | THeroList | delegation |

## HxBridge.THexagonBridge

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FTerrain | undefined1 | getter |

## MoveOnEvents.TMoveOnEvent

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FRadius | byte | setter |

## PassiveAb.TImmunityAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FImmunityTypes | undefined2 | getter |

## PassiveAb.TMovementAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FMoveTypes | undefined1 | getter |

## PassiveAb.TProtectionAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FProtectionTypes | undefined2 | getter |
