## Animation.TImageSequenceAnimation

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FImageSequence | undefined4 | setter |
| +$40 | FXhpOffset | undefined4 | setter |
| +$44 | FYhpOffset | undefined4 | setter |

## Animation.TTwinkleAnimation

| offset | field | c type | from |
|---|---|---|---|
| +$3C | Fup | undefined4 | setter |

## AoWE.TAIBudgetManager

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAIBudgetList | TAIBudgetList | delegation |

## AoWE.TAIGroup

| offset | field | c type | from |
|---|---|---|---|
| +$40 | FGoldBudget |  | getter |
| +$44 | FManaBudget |  | getter |

## AoWE.TAIGroupControlTarget

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FTargetGold |  | getter |

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

## AoWE.TAIMoveControlSettings

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FSourcePos | undefined4 | setter |
| +$1C | FDestinationPos | undefined4 | setter |

## AoWE.TAIMoveExecuter

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FAIMoveExecuterUnitList | TAIMoveExecuterUnitList | delegation |

## AoWE.TAIPlayerAction

| offset | field | c type | from |
|---|---|---|---|
| +$0C | Fup | int | setter |

## AoWE.TAbstractAoWHSMap

| offset | field | c type | from |
|---|---|---|---|
| +$A4 | FCurrentPlayer |  | setter |
| +$A5 | FSeatedPlayer |  | setter |

## AoWE.TAbstractUnit

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityCount |  | getter |

## AoWE.TAbstractUnitResource

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FUnitGFXResourceIndex |  | setter |

## AoWE.TAdjacentArmy

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FMovepath | TMovepath | delegation |

## AoWE.TAdjustableAbility

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FAbilityType |  | getter |

## AoWE.TAdjustableUnit

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FAttack |  | getter |
| +$3D | FDefense |  | getter |
| +$3E | FResistance |  | getter |
| +$3F | FHits |  | getter |
| +$40 | FDamage |  | getter |
| +$41 | FImmunityTypes |  | getter |
| +$43 | FProtectionTypes |  | getter |
| +$45 | FHitPoints |  | getter |

## AoWE.TAoWCampaign

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FStream | TStream | delegation |

## AoWE.TArmy

| offset | field | c type | from |
|---|---|---|---|
| +$12 | FPlayer |  | getter |
| +$13 | FXYL |  | setter |
| +$18 | FUpkeep |  | getter |
| +$25 | FDestinationPos |  | setter |

## AoWE.TCombatData

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FCombatPlayerList | TCombatPlayerList | delegation |

## AoWE.TCombatTypeRequestEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$1B | FCenterLocation |  | setter |

## AoWE.TCombatUnit

| offset | field | c type | from |
|---|---|---|---|
| +$0C | Fup |  | setter |
| +$4C | FAbilityOwner |  | getter |

## AoWE.TCombatWall

| offset | field | c type | from |
|---|---|---|---|
| +$0C | Fup |  | setter |
| +$4D | FHitPoints |  | getter |
| +$4E | FLocked |  | getter |

## AoWE.TCommandAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityID |  | getter |

## AoWE.TCommandedAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityID |  | getter |

## AoWE.TCustomAbilityList

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbCount |  | getter |

## AoWE.TDamageCA

| offset | field | c type | from |
|---|---|---|---|
| +$13 | Fup |  | setter |

## AoWE.TDiplomaticRelationHistoryList

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEObjectList | TEObjectList | delegation |

## AoWE.TDurationAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0E | FAbilityID |  | getter |

## AoWE.TFastCombat

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FCombatData | TCombatData | delegation |

## AoWE.TFire

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FShowPriority |  | getter |

## AoWE.TGlobalEnchantment

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FUpkeep |  | getter |

## AoWE.TGlobalMagicControl

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FGlobalEnchantmentList | TGlobalEnchantmentList | delegation |

## AoWE.THero

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FFaceIndex |  | setter |
| +$48 | FExperience |  | getter |
| +$4C | FUnitLevel |  | getter |
| +$69 | FGender |  | getter |
| +$70 | FHeroItems | THeroItems | delegation |
| +$79 | FMovePoints |  | getter |
| +$7A | FHitPoints |  | getter |
| +$80 | FCastingPoints |  | getter |

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
| +$40 | FItemGFXIndex |  | setter |

## AoWE.TItemHS

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FMapField | TMapField | delegation |

## AoWE.TItemHSList

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FOwner | undefined4 | setter |

## AoWE.TLeader

| offset | field | c type | from |
|---|---|---|---|
| +$9C | FSpherePicksMax |  | setter |

## AoWE.TMeleeRound

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FCapacity | int | setter |

## AoWE.TMoveControlSettings

| offset | field | c type | from |
|---|---|---|---|
| +$7C | FSourcePos | undefined4 | setter |
| +$88 | FDestinationPos | undefined4 | setter |

## AoWE.TMoveSelector

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FCurrentMove | undefined4 | setter |

## AoWE.TMultiLevelAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0E | FAbilityID |  | getter |

## AoWE.TPlayer

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FArmyList | TArmyList | delegation |
| +$A5 | FRace |  | setter |
| +$A6 | FPlayerIndex |  | setter |
| +$C4 | FGems |  | setter |
| +$C8 | FArmyUpkeep | undefined4 | setter |
| +$CC | FMagicUpkeep | undefined4 | setter |
| +$D4 | FLeader |  | setter |

## AoWE.TPlayerList

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEObjectList | TEObjectList | delegation |

## AoWE.TPlayerMagicControl

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FEnchantmentList | TEnchantmentList | delegation |
| +$40 | FPowerSourceList | TPowerSourceList | delegation |
| +$44 | FActiveEnchantments |  | setter |

## AoWE.TPlayerStructureIncomeSource

| offset | field | c type | from |
|---|---|---|---|
| +$08 | Fup | undefined4 | setter |

## AoWE.TPlayerStructurePowerSource

| offset | field | c type | from |
|---|---|---|---|
| +$08 | Fup | undefined4 | setter |

## AoWE.TProductionControl

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FProductionQueue | TProductionQueue | delegation |
| +$1C | FUnitProductionList | TUnitProductionList | delegation |

## AoWE.TRace

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FRace |  | setter |

## AoWE.TRaceResource

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FRaceIndex |  | getter |

## AoWE.TRangedAttackAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FRangeRA |  | getter |
| +$2B | FDamageTypesRA |  | getter |
| +$2D | FAttackRepeatRA |  | getter |

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
| +$3C | FExperience |  | getter |
| +$3D | FMovePoints |  | getter |
| +$3E | FHitPoints |  | getter |
| +$40 | FUnitResource | TUnitResource | delegation |

## AoWE.TUnitEnchantmentAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityID |  | getter |

## AoWE.TUnitGFXResource

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FIndex |  | getter |
| +$20 | FCustomImageLibrary | TCustomImageLibrary | delegation |
| +$28 | FImageSequenceList | TImageSequenceList | delegation |

## AoWE.TUnitHS

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FShowPriority |  | getter |
| +$10 | FUnitGFXResource | TUnitGFXResource | delegation |

## AoWE.TUnitResource

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FAbilityOwner | TAbilityOwner | delegation |
| +$4C | FObtainValue |  | getter |

## AoWE.TUnitSelectionControl

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FUnitCategoryList | TUnitCategoryList | delegation |
| +$4C | FSelectedHero | undefined4 | setter |

## AoWE.TWallUnit

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FWallType |  | setter |
| +$3D | FHitPoints |  | getter |
| +$3E | FHits |  | getter |

## AoWSetup.TSetupControl

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FSetupSettings | TSetupSettings | delegation |

## City.TCity

| offset | field | c type | from |
|---|---|---|---|
| +$45 | FRace |  | getter |
| +$4C | FWallType |  | setter |

## Crops.TCrop

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FCropOwner | undefined4 | setter |

## Crops.TPlayerCropStructure

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FIncome |  | getter |

## EventLog.TLocationTextEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FLocation |  | setter |

## GlobalSpells.TDisjunctionSpellCaster

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FEnchantmentID | undefined4 | setter |
| +$18 | FDispelChance | int | setter |

## ItemGrid.TItemGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1E4 | FItems | undefined4 | setter |

## PageTurnCtrl.TPageTurnControl

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FPageDimensions | undefined4 | setter |

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

## RaceBox.TRaceBox

| offset | field | c type | from |
|---|---|---|---|
| +$17C | FRaces | undefined4 | setter |

## UnitGrid.TUnitGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1E0 | FUnits | int | setter |
| +$1E5 | FShowUnitLevel | undefined1 | setter |

## UnitIGrd.TUnitIndexGrid

| offset | field | c type | from |
|---|---|---|---|
| +$79 | FShowUnitLevel | undefined1 | setter |
| +$1DC | FUnitIndexList | int | setter |

## UnitTabC.TUnitTabControl

| offset | field | c type | from |
|---|---|---|---|
| +$144 | FUnitIndexGrid | int | setter |
