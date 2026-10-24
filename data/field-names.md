## AGCPlugins.TAIGroupDefendTargetSelector

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FAIMoveTargetSelector | TAIMoveTargetSelector | constructor |
| +$24 | FAIGroupControlTargetList | TAIGroupControlTargetList | constructor |

## AGCPlugins.TAIGroupWanderControl

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FMoveControlSettings | TMoveControlSettings | constructor |

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

## AoWE.TAIExecuter

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FByteList | TByteList | constructor |

## AoWE.TAIGroup

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FAIGroupProductionList | TAIGroupProductionList | constructor |
| +$40 | FGoldBudget |  | getter |
| +$44 | FManaBudget |  | getter |

## AoWE.TAIGroupControl

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FAIGroupControlTargetList | TAIGroupControlTargetList | constructor |
| +$158 | FCombatPredictor | TCombatPredictor | constructor |
| +$160 | FAIRecruitmentGroupList | TAIRecruitmentGroupList | constructor |
| +$164 | FAIGroupProductionLocationList | TAIGroupProductionLocationList | constructor |

## AoWE.TAIGroupControlTarget

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FTargetGold |  | getter |

## AoWE.TAIGroupCooperationControl

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FAIRecruitmentGroupList | TAIRecruitmentGroupList | delegation |

## AoWE.TAIGroupDefenseControl

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FGroupDefenseSelector | TGroupDefenseSelector | constructor |

## AoWE.TAIGroupManager

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FList | TList | constructor |

## AoWE.TAIGroupProductionControl

| offset | field | c type | from |
|---|---|---|---|
| +$34 | FAIGroupUnitProductionList | TAIGroupUnitProductionList | delegation |
| +$38 | FAIGroupUnitProductionList | TAIGroupUnitProductionList | constructor |

## AoWE.TAIGroupRecruitControl

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FUnitList | TUnitList | delegation |

## AoWE.TAIGroupTargetFinder

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FAIMoveTargetSelector | TAIMoveTargetSelector | constructor |

## AoWE.TAIGroupTargetSelector

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FAIGroupRecruitControl | TAIGroupRecruitControl | constructor |
| +$28 | FAIGroupProductionControl | TAIGroupProductionControl | constructor |
| +$2C | FAIGroupCooperationControl | TAIGroupCooperationControl | constructor |
| +$40 | FUnitUserList | TUnitUserList | constructor |
| +$84 | FAIGroupTargetPrioritySettings | TAIGroupTargetPrioritySettings | constructor |

## AoWE.TAIGroupUnitProductionList

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEObjectList | TEObjectList | delegation |

## AoWE.TAIMoveControl

| offset | field | c type | from |
|---|---|---|---|
| +$21C | FMoveControlSettings | TMoveControlSettings | constructor |

## AoWE.TAIMoveControlSettings

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FSourcePos | undefined4 | setter |
| +$1C | FDestinationPos | undefined4 | setter |
| +$154 | FMovepath | TMovepath | constructor |

## AoWE.TAIMoveExecuter

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FIntegerList | TIntegerList | constructor |
| +$14 | FAIMoveExecuterMoveQueue | TAIMoveExecuterMoveQueue | constructor |
| +$18 | FAIMoveExecuterUnitList | TAIMoveExecuterUnitList | delegation |

## AoWE.TAIMoveExecuterControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FAIMoveControl | TAIMoveControl | constructor |

## AoWE.TAIMoveExecuterMove

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FMovepath | TMovepath | constructor |

## AoWE.TAIMoveTargetSelector

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FMoveTargetList | TMoveTargetList | constructor |
| +$14 | FMoveControlSettings | TMoveControlSettings | constructor |
| +$1C | FMoveTargetList | TMoveTargetList | constructor |
| +$248 | FUnitUserList | TUnitUserList | constructor |

## AoWE.TAIPlayerAction

| offset | field | c type | from |
|---|---|---|---|
| +$0C | Fup | int | setter |

## AoWE.TAIPlayerActionManager

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FList | TList | constructor |

## AoWE.TAIPlayerControl

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAIPlayerActionList | TAIPlayerActionList | constructor |
| +$18 | FProcessCyclesMax |  | getter |
| +$1C | FAIMoveExecuter | TAIMoveExecuter | constructor |

## AoWE.TAIProductionLocationFinder

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FAIMoveTargetSelector | TAIMoveTargetSelector | constructor |

## AoWE.TAIRecruitmentGroupFinder

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FAIMoveTargetSelector | TAIMoveTargetSelector | constructor |

## AoWE.TAbility

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FStringList | TStringList | constructor |
| +$18 | FSFXLibrary | TSFXLibrary | constructor |
| +$1C | FImageSequenceList | TImageSequenceList | constructor |

## AoWE.TAbilityControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FList | TList | constructor |

## AoWE.TAbstractAoWCombatMap

| offset | field | c type | from |
|---|---|---|---|
| +$D8 | FEventList | TEventList | constructor |
| +$DC | FEventList | TEventList | constructor |

## AoWE.TAbstractAoWHSMap

| offset | field | c type | from |
|---|---|---|---|
| +$A4 | FCurrentPlayer |  | setter |
| +$A5 | FSeatedPlayer |  | setter |
| +$A8 | FEventList | TEventList | constructor |
| +$BC | FEventList | TEventList | constructor |
| +$C0 | FEventList | TEventList | constructor |
| +$CC | FCustomFixedVisibleHS | TCustomFixedVisibleHS | constructor |
| +$D0 | FCustomFixedVisibleHS | TCustomFixedVisibleHS | constructor |

## AoWE.TAbstractAoWHSMapMouse

| offset | field | c type | from |
|---|---|---|---|
| +$4C | FEventList | TEventList | constructor |

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

## AoWE.TAdjacentMEC

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FAdjacentArmyList | TAdjacentArmyList | constructor |

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
| +$10 | FAoWCampaignScenarioList | TAoWCampaignScenarioList | constructor |
| +$14 | FIntegerList | TIntegerList | constructor |
| +$18 | FByteList | TByteList | constructor |
| +$20 | FAoWCampaignTransferSettings | TAoWCampaignTransferSettings | constructor |

## AoWE.TAoWCampaignTransferSettings

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FHeroList | THeroList | constructor |
| +$10 | FItemList | TItemList | constructor |
| +$14 | FUnitList | TUnitList | constructor |
| +$1C | FIntegerList | TIntegerList | constructor |
| +$28 | FIntegerList | TIntegerList | constructor |
| +$2C | FIntegerList | TIntegerList | constructor |
| +$30 | FIntegerList | TIntegerList | constructor |
| +$3C | FByteList | TByteList | constructor |

## AoWE.TAoWEngine

| offset | field | c type | from |
|---|---|---|---|
| +$5C | FAoWRegistry | TAoWRegistry | constructor |
| +$74 | FEmailGameControl | TEmailGameControl | constructor |
| +$78 | FAoWDictionary | TAoWDictionary | constructor |

## AoWE.TAoWHSMap

| offset | field | c type | from |
|---|---|---|---|
| +$D8 | FSelectedArmy | TSelectedArmy | constructor |
| +$E0 | FTargetSelectionControl | TTargetSelectionControl | constructor |
| +$F0 | FStringList | TStringList | constructor |
| +$F4 | FItemControl | TItemControl | constructor |
| +$F8 | FHeroControl | THeroControl | constructor |
| +$FC | FUnitControl | TUnitControl | constructor |
| +$100 | FStructureControl | TStructureControl | constructor |
| +$108 | FStringList | TStringList | constructor |
| +$110 | FStartupSongList | TStartupSongList | constructor |
| +$114 | FSonglist | TSonglist | constructor |
| +$124 | FTutorialControl | TTutorialControl | constructor |
| +$128 | FAIExecuter | TAIExecuter | constructor |
| +$130 | FAIGroupManager | TAIGroupManager | constructor |
| +$134 | FAoWHSMapKeyboard | TAoWHSMapKeyboard | constructor |
| +$13C | FTextControl | TTextControl | constructor |
| +$140 | FPlayerList | TPlayerList | constructor |
| +$144 | FRaceList | TRaceList | constructor |
| +$170 | FByteList | TByteList | constructor |
| +$17C | FEventList | TEventList | constructor |
| +$184 | FMoveControl | TMoveControl | constructor |
| +$188 | FGlobalMagicControl | TGlobalMagicControl | constructor |
| +$18C | FAoWMapCampaignSettings | TAoWMapCampaignSettings | constructor |
| +$198 | FEventList | TEventList | constructor |
| +$19C | FEventList | TEventList | constructor |
| +$1A0 | FEventList | TEventList | constructor |
| +$1A4 | FEventList | TEventList | constructor |
| +$1A8 | FEventList | TEventList | constructor |
| +$1AC | FEventList | TEventList | constructor |
| +$1B0 | FEventList | TEventList | constructor |
| +$1B4 | FEventList | TEventList | constructor |
| +$1B8 | FEventList | TEventList | constructor |
| +$1BC | FEventList | TEventList | constructor |
| +$1C4 | FEventList | TEventList | constructor |
| +$1CC | FEventLogList | TEventLogList | constructor |
| +$1D0 | FEventList | TEventList | constructor |
| +$1D4 | FExecuteEventLogCallBackList | TExecuteEventLogCallBackList | constructor |
| +$1E0 | FEventList | TEventList | constructor |
| +$1E4 | FEventList | TEventList | constructor |
| +$1E8 | FEventList | TEventList | constructor |
| +$1EC | FEventList | TEventList | constructor |
| +$1F0 | FList | TList | constructor |
| +$208 | FEventList | TEventList | constructor |
| +$20C | FEventList | TEventList | constructor |
| +$210 | FEventList | TEventList | constructor |
| +$214 | FEventList | TEventList | constructor |
| +$218 | FEventList | TEventList | constructor |
| +$21C | FEventList | TEventList | constructor |
| +$220 | FEventList | TEventList | constructor |
| +$224 | FEventList | TEventList | constructor |
| +$228 | FEventList | TEventList | constructor |
| +$23C | FAoWTokenManager | TAoWTokenManager | constructor |
| +$240 | FPlayerCommunicator | TPlayerCommunicator | constructor |

## AoWE.TAoWHSSet

| offset | field | c type | from |
|---|---|---|---|
| +$48 | FFireControl | TFireControl | constructor |
| +$4C | FFireControl | TFireControl | constructor |
| +$50 | FFireControl | TFireControl | constructor |
| +$54 | FRaceResourceList | TRaceResourceList | constructor |
| +$58 | FPadControl | TPadControl | constructor |
| +$5C | FUnitResourceList | TUnitResourceList | constructor |
| +$60 | FUnitGFXResourceList | TUnitGFXResourceList | constructor |
| +$64 | FHeroResourceList | THeroResourceList | constructor |
| +$68 | FItemGFXList | TItemGFXList | constructor |
| +$6C | FItemLibraryManager | TItemLibraryManager | constructor |
| +$70 | FHeroLibraryManager | THeroLibraryManager | constructor |
| +$74 | FFaceResourceList | TFaceResourceList | constructor |
| +$78 | FFlagControl | TFlagControl | constructor |
| +$7C | FFireControl | TFireControl | constructor |
| +$80 | FAbilityControl | TAbilityControl | constructor |
| +$84 | FSpellControl | TSpellControl | constructor |
| +$88 | FMapObjectResourceList | TMapObjectResourceList | constructor |
| +$8C | FHexagonControl | THexagonControl | constructor |
| +$90 | FRoadControl | TRoadControl | constructor |
| +$94 | FImageSequenceList | TImageSequenceList | constructor |
| +$98 | FTextControl | TTextControl | constructor |

## AoWE.TArmy

| offset | field | c type | from |
|---|---|---|---|
| +$12 | FPlayer |  | getter |
| +$13 | FXYL |  | setter |
| +$18 | FUpkeep |  | getter |
| +$25 | FDestinationPos |  | setter |

## AoWE.TArmyEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FArmy | TArmy | constructor |
| +$1C | FText | String | getter |
| +$20 | FStringList | TStringList | constructor |
| +$28 | FByteList | TByteList | constructor |
| +$2C | FByteList | TByteList | constructor |

## AoWE.TArmyHS

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FArmy | TArmy | constructor |

## AoWE.TArmyID

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FIntegerList | TIntegerList | constructor |

## AoWE.TArmyInfoEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FArmy | TArmy | constructor |
| +$20 | FStringList | TStringList | constructor |
| +$28 | FText | String | getter |

## AoWE.TAutoProduceAIPA

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FQuadItemList | TQuadItemList | constructor |

## AoWE.TCastSpellAIPA

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FIntegerList | TIntegerList | constructor |
| +$1C | FIntegerList | TIntegerList | constructor |
| +$20 | FIntegerList | TIntegerList | constructor |
| +$24 | FAICastSpellActionList | TAICastSpellActionList | constructor |

## AoWE.TCombat

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FCombatData | TCombatData | constructor |
| +$18 | FCombatLogbook | TCombatLogbook | constructor |
| +$1C | FCombatSide | TCombatSide | constructor |
| +$20 | FCombatSide | TCombatSide | constructor |
| +$24 | FEventList | TEventList | constructor |

## AoWE.TCombatData

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FByteList | TByteList | constructor |
| +$2C | FByteList | TByteList | constructor |
| +$34 | FENode | TENode | constructor |
| +$38 | FCombatPlayerList | TCombatPlayerList | delegation |
| +$3C | FCombatPartyList | TCombatPartyList | constructor |
| +$40 | FByteList | TByteList | constructor |

## AoWE.TCombatLogbook

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FCombatData | TCombatData | constructor |
| +$10 | FCombatData | TCombatData | constructor |
| +$14 | FCombatActionList | TCombatActionList | constructor |

## AoWE.TCombatObject

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FQuadItemList | TQuadItemList | constructor |
| +$14 | FQuadItemList | TQuadItemList | constructor |

## AoWE.TCombatParty

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FArmy | TArmy | constructor |

## AoWE.TCombatPredictor

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FCombatPredictorUnitList | TCombatPredictorUnitList | constructor |
| +$08 | FCombatPredictorUnitList | TCombatPredictorUnitList | constructor |
| +$0C | FCombatPredictorSide | TCombatPredictorSide | constructor |
| +$10 | FCombatPredictorSide | TCombatPredictorSide | constructor |

## AoWE.TCombatPredictorUnit

| offset | field | c type | from |
|---|---|---|---|
| +$34 | FQuadItemList | TQuadItemList | constructor |

## AoWE.TCombatTypeRequestEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$1B | FCenterLocation |  | setter |

## AoWE.TCombatUnit

| offset | field | c type | from |
|---|---|---|---|
| +$0C | Fup |  | setter |
| +$4C | FAbilityOwner |  | getter |

## AoWE.TCombatViewer

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FCombat | TCombat | constructor |

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
| +$10 | FByteList | TByteList | constructor |

## AoWE.TCommandedAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbilityID |  | getter |

## AoWE.TConstructAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FConstructionControlList | TConstructionControlList | constructor |

## AoWE.TCustomAbilityList

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FAbCount |  | getter |

## AoWE.TDamageCA

| offset | field | c type | from |
|---|---|---|---|
| +$13 | Fup |  | setter |

## AoWE.TDiplomaticAction

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FStringList | TStringList | constructor |

## AoWE.TDiplomaticRelationHistoryList

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEObjectList | TEObjectList | delegation |

## AoWE.TDispelMagicCA

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FIntegerList | TIntegerList | constructor |

## AoWE.TDurationAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0E | FAbilityID |  | getter |

## AoWE.TEmailGameControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEmailGameList | TEmailGameList | constructor |

## AoWE.TFastCombat

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FCombatData | TCombatData | delegation |

## AoWE.TFastCombatCommandList

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FList | TList | constructor |

## AoWE.TFire

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FShowPriority |  | getter |

## AoWE.TFireControl

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FList | TList | constructor |

## AoWE.TGlobalEnchantment

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FName | String | getter |
| +$20 | FUpkeep |  | getter |

## AoWE.TGlobalMagicControl

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FGlobalEnchantmentList | TGlobalEnchantmentList | delegation |
| +$3C | FEventList | TEventList | constructor |

## AoWE.TGroupDefenseSelector

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FUnitUserList | TUnitUserList | constructor |

## AoWE.THero

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FFaceIndex |  | setter |
| +$48 | FExperience |  | getter |
| +$4C | FUnitLevel |  | getter |
| +$60 | FName | String | getter |
| +$64 | FNickname | String | getter |
| +$69 | FGender |  | getter |
| +$70 | FHeroItems | THeroItems | delegation |
| +$74 | FHeroInventory | THeroInventory | constructor |
| +$79 | FMovePoints |  | getter |
| +$7A | FHitPoints |  | getter |
| +$7C | FHeroPowerSource | THeroPowerSource | constructor |
| +$80 | FCastingPoints |  | getter |

## AoWE.THeroControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEventList | TEventList | constructor |
| +$10 | FEventList | TEventList | constructor |
| +$14 | FHeroList | THeroList | constructor |

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

## AoWE.THeroLibraryManager

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FHeroLibrary | THeroLibrary | constructor |
| +$0C | FENode | TENode | constructor |

## AoWE.THeroPowerSource

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FAbstractUnit | TAbstractUnit | delegation |

## AoWE.THeroResource

| offset | field | c type | from |
|---|---|---|---|
| +$2C | FAbilityOwner | TAbilityOwner | constructor |

## AoWE.THeroUpgradeTE

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FAbilityOwner | TAbilityOwner | constructor |

## AoWE.THuntAG

| offset | field | c type | from |
|---|---|---|---|
| +$50 | FIntegerList | TIntegerList | constructor |

## AoWE.TItem

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FOwnerName | String | getter |
| +$2C | FObtainValue |  | getter |
| +$3C | FStringList | TStringList | constructor |
| +$40 | FItemGFXIndex |  | setter |

## AoWE.TItemControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FList | TList | constructor |
| +$0C | FEventList | TEventList | constructor |
| +$14 | FEventList | TEventList | constructor |

## AoWE.TItemHS

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FMapField | TMapField | delegation |
| +$0C | FItemList | TItemList | constructor |

## AoWE.TItemHSList

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FOwner | undefined4 | setter |

## AoWE.TItemLibraryManager

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FItemList | TItemList | constructor |
| +$0C | FENode | TENode | constructor |

## AoWE.TJoinEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FIntegerList | TIntegerList | constructor |
| +$2C | FStringList | TStringList | constructor |

## AoWE.TLeader

| offset | field | c type | from |
|---|---|---|---|
| +$9C | FSpherePicksMax |  | setter |
| +$A0 | FByteList | TByteList | constructor |

## AoWE.TLeaderSetupControl

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FLeader | TLeader | constructor |
| +$14 | FLeader | TLeader | constructor |
| +$18 | FIntegerList | TIntegerList | constructor |

## AoWE.TMeleeRound

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FCapacity | int | setter |
| +$18 | FAttackerDV |  | getter |
| +$1C | FDefenderDV |  | getter |

## AoWE.TMoveArmyTE

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FIntegerList | TIntegerList | constructor |

## AoWE.TMoveControl

| offset | field | c type | from |
|---|---|---|---|
| +$1C8 | FXYLList | TXYLList | constructor |
| +$1CC | FXYLList | TXYLList | constructor |
| +$1D0 | FXYLList | TXYLList | constructor |

## AoWE.TMoveControlSettings

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FSubMoveList | TSubMoveList | constructor |
| +$18 | FList | TList | constructor |
| +$68 | FMovepath | TMovepath | constructor |
| +$7C | FSourcePos | undefined4 | setter |
| +$88 | FDestinationPos | undefined4 | setter |
| +$A8 | FUnitUserList | TUnitUserList | constructor |

## AoWE.TMoveSelector

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FMoveSettingsList | TMoveSettingsList | constructor |
| +$0C | FCurrentMove | undefined4 | setter |

## AoWE.TMoveSettings

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FMovepath | TMovepath | constructor |

## AoWE.TMoveTE

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FMovepath | TMovepath | constructor |

## AoWE.TMultiLevelAbility

| offset | field | c type | from |
|---|---|---|---|
| +$2C | FIntegerList | TIntegerList | constructor |

## AoWE.TMultiLevelAbilityData

| offset | field | c type | from |
|---|---|---|---|
| +$0E | FAbilityID |  | getter |

## AoWE.TMultiMoveTE

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FTokenEventList | TTokenEventList | constructor |

## AoWE.TPBEMPlayerSettings

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FEmailGame | TEmailGame | constructor |

## AoWE.TPadControl

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FList | TList | constructor |
| +$10 | FBitList | TBitList | constructor |

## AoWE.TPlayer

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FEventList | TEventList | constructor |
| +$10 | FEventList | TEventList | constructor |
| +$14 | FEventList | TEventList | constructor |
| +$18 | FEventList | TEventList | constructor |
| +$1C | FPlayerStructureList | TPlayerStructureList | constructor |
| +$20 | FPlayerStructureList | TPlayerStructureList | constructor |
| +$24 | FProductionControlList | TProductionControlList | constructor |
| +$28 | FArmyList | TArmyList | delegation |
| +$34 | FStringList | TStringList | constructor |
| +$38 | FDiplomaticRelationList | TDiplomaticRelationList | constructor |
| +$3C | FDiplomaticRelationList | TDiplomaticRelationList | constructor |
| +$40 | FPlayerDiplomaticRelations | TPlayerDiplomaticRelations | constructor |
| +$54 | FPlayerMagicControl | TPlayerMagicControl | constructor |
| +$60 | FPlayerStatistics | TPlayerStatistics | constructor |
| +$64 | FIncomeSourceList | TIncomeSourceList | constructor |
| +$68 | FPlayerStructureList | TPlayerStructureList | constructor |
| +$80 | FHeroList | THeroList | constructor |
| +$84 | FAIGroupList | TAIGroupList | constructor |
| +$88 | FAIPlayerControl | TAIPlayerControl | constructor |
| +$8C | FAIBudgetManager | TAIBudgetManager | constructor |
| +$90 | FDiplomaticActionList | TDiplomaticActionList | constructor |
| +$94 | FBitList | TBitList | constructor |
| +$98 | FIntegerList | TIntegerList | constructor |
| +$9C | FIntegerList | TIntegerList | constructor |
| +$A0 | FPBEMPlayerSettings | TPBEMPlayerSettings | constructor |
| +$A5 | FRace |  | setter |
| +$A6 | FPlayerIndex |  | setter |
| +$C4 | FGems |  | setter |
| +$C8 | FArmyUpkeep | undefined4 | setter |
| +$CC | FMagicUpkeep | undefined4 | setter |
| +$D4 | FLeader |  | setter |
| +$D8 | FEventLogbook | TEventLogbook | constructor |

## AoWE.TPlayerControl

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FDoubleItemList | TDoubleItemList | constructor |

## AoWE.TPlayerDiplomaticRelations

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FByteList | TByteList | constructor |
| +$10 | FENode | TENode | constructor |

## AoWE.TPlayerList

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEObjectList | TEObjectList | delegation |
| +$10 | FByteList | TByteList | constructor |
| +$14 | FByteList | TByteList | constructor |
| +$18 | FByteList | TByteList | constructor |
| +$1C | FByteList | TByteList | constructor |

## AoWE.TPlayerMagicControl

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FCheatEnabled |  | getter |
| +$20 | FExternalPowerSource | TExternalPowerSource | constructor |
| +$30 | FIntegerList | TIntegerList | constructor |
| +$3C | FEnchantmentList | TEnchantmentList | delegation |
| +$40 | FPowerSourceList | TPowerSourceList | delegation |
| +$44 | FActiveEnchantments |  | setter |
| +$48 | FEventList | TEventList | constructor |

## AoWE.TPlayerStatistics

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FTurnInfo | TTurnInfo | constructor |

## AoWE.TPlayerStructure

| offset | field | c type | from |
|---|---|---|---|
| +$34 | FBitList | TBitList | constructor |

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
| +$24 | FProductionSettings | TProductionSettings | constructor |

## AoWE.TRace

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FRace |  | setter |
| +$0C | FByteList | TByteList | constructor |
| +$10 | FIntegerList | TIntegerList | constructor |

## AoWE.TRaceResource

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FRaceIndex |  | getter |
| +$38 | FUnitIndexList | TUnitIndexList | constructor |
| +$40 | FUnitIndexList | TUnitIndexList | constructor |
| +$44 | FStringList | TStringList | constructor |

## AoWE.TRangedAttackAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FRangeRA |  | getter |
| +$2B | FDamageTypesRA |  | getter |
| +$2D | FAttackRepeatRA |  | getter |

## AoWE.TSMTPEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$24 | FStringList | TStringList | constructor |

## AoWE.TSelectedArmy

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FMoveSettingsList | TMoveSettingsList | delegation |
| +$20 | FIntegerList | TIntegerList | constructor |

## AoWE.TSpell

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FStringList | TStringList | constructor |
| +$28 | FSFXLibrary | TSFXLibrary | constructor |
| +$2C | FImageSequenceList | TImageSequenceList | constructor |

## AoWE.TSpellControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FList | TList | constructor |

## AoWE.TSpellList

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FList | TList | constructor |

## AoWE.TStrikeAbility

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FMeleeRound | TMeleeRound | delegation |

## AoWE.TStructure

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FAoWMapField | TAoWMapField | delegation |

## AoWE.TStructureAIPA

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FIntegerList | TIntegerList | constructor |

## AoWE.TStructureControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FENode | TENode | constructor |

## AoWE.TStructureResource

| offset | field | c type | from |
|---|---|---|---|
| +$50 | FStringList | TStringList | constructor |
| +$5C | FUnitIndexListCollection | TUnitIndexListCollection | constructor |

## AoWE.TSubMove

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FDoubleItemList | TDoubleItemList | constructor |

## AoWE.TTargetSelectionControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FShortIntList | TShortIntList | constructor |
| +$34 | FEventList | TEventList | constructor |
| +$3C | FStringList | TStringList | constructor |

## AoWE.TTextControlItem

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FStringList | TStringList | constructor |

## AoWE.TTutorialControl

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FIntegerList | TIntegerList | constructor |

## AoWE.TUnit

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FExperience |  | getter |
| +$3D | FMovePoints |  | getter |
| +$3E | FHitPoints |  | getter |
| +$40 | FUnitResource | TUnitResource | delegation |

## AoWE.TUnitControl

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FIntegerHashTable256 | TIntegerHashTable256 | constructor |
| +$10 | FList | TList | constructor |

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
| +$34 | FSFXLibrary | TSFXLibrary | constructor |
| +$38 | FSFXLibrary | TSFXLibrary | constructor |
| +$3C | FSFXLibrary | TSFXLibrary | constructor |
| +$40 | FSFXLibrary | TSFXLibrary | constructor |
| +$44 | FSFXLibrary | TSFXLibrary | constructor |

## AoWE.TUnitHS

| offset | field | c type | from |
|---|---|---|---|
| +$0C | FShowPriority |  | getter |
| +$10 | FUnitGFXResource | TUnitGFXResource | delegation |

## AoWE.TUnitIndexList

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FUnitIndex |  | getter |

## AoWE.TUnitIndexListCollection

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FUnitIndexList | TUnitIndexList | constructor |

## AoWE.TUnitResource

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FAbilityOwner | TAbilityOwner | delegation |
| +$48 | FStringList | TStringList | constructor |
| +$4C | FObtainValue |  | getter |

## AoWE.TUnitSelectionControl

| offset | field | c type | from |
|---|---|---|---|
| +$30 | FBitList | TBitList | constructor |
| +$34 | FBitList | TBitList | constructor |
| +$38 | FUnitCategoryList | TUnitCategoryList | delegation |
| +$3C | FUnitCategoryList | TUnitCategoryList | constructor |
| +$40 | FUnitIndexList | TUnitIndexList | constructor |
| +$4C | FSelectedHero | undefined4 | setter |

## AoWE.TUnitSelector

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FUnitUserList | TUnitUserList | constructor |

## AoWE.TUnitSpellCaster

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FUnitUserList | TUnitUserList | constructor |

## AoWE.TUnitSpellTE

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FIntegerList | TIntegerList | constructor |
| +$24 | FUnitUserList | TUnitUserList | constructor |

## AoWE.TWallUnit

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FWallType |  | setter |
| +$3D | FHitPoints |  | getter |
| +$3E | FHits |  | getter |

## AoWE.TWorldFXHS

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FXYZList | TXYZList | constructor |

## AoWSetup.TPlayerSetupSettings

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FLeader | TLeader | constructor |

## AoWSetup.TSetupControl

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FSetupSettings | TSetupSettings | delegation |
| +$2C | FMemoryStream | TMemoryStream | constructor |
| +$34 | FRemotePlayer | TRemotePlayer | constructor |

## AoWSetup.TSetupSettings

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FRemotePlayerList | TRemotePlayerList | constructor |

## Arena.TArenaTE

| offset | field | c type | from |
|---|---|---|---|
| +$28 | FIntegerList | TIntegerList | constructor |

## Arena.TEnterArenaEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FIntegerList | TIntegerList | constructor |

## BehaviorAG.TAbstractBehaviorAGC

| offset | field | c type | from |
|---|---|---|---|
| +$170 | FAIGroupTargetSelector | TAIGroupTargetSelector | constructor |

## City.TCity

| offset | field | c type | from |
|---|---|---|---|
| +$45 | FRace |  | getter |
| +$48 | FName | String | getter |
| +$4C | FWallType |  | setter |
| +$50 | FProductionControl | TProductionControl | constructor |
| +$58 | FGlobalEnchantmentList | TGlobalEnchantmentList | constructor |
| +$60 | FCityOverlayHS | TCityOverlayHS | constructor |

## CombatSpells.TMultiTargetCombatSpellCA

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FByteList | TByteList | constructor |

## Crops.TCrop

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FCropOwner | undefined4 | setter |

## Crops.TPlayerCropStructure

| offset | field | c type | from |
|---|---|---|---|
| +$3C | FIncome |  | getter |

## Dungeon.TDungeon

| offset | field | c type | from |
|---|---|---|---|
| +$38 | FArmy | TArmy | constructor |

## Dungeon.TDungeonResource

| offset | field | c type | from |
|---|---|---|---|
| +$68 | FUnitIndexListCollection | TUnitIndexListCollection | constructor |

## EventLog.TEventLogbook

| offset | field | c type | from |
|---|---|---|---|
| +$08 | FEventLogList | TEventLogList | constructor |

## EventLog.TExecuteEventLogCallBackList

| offset | field | c type | from |
|---|---|---|---|
| +$04 | FList | TList | constructor |

## EventLog.TGameOverEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FStringList | TStringList | constructor |

## EventLog.THelpMessageEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FStringList | TStringList | constructor |

## EventLog.TLocationTextEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FLocation |  | setter |

## EventLog.TMessageEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FStringList | TStringList | constructor |

## EventLog.TShowMessageEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FStringList | TStringList | constructor |

## EventLog.TTextEventLog

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FText | String | getter |

## ExploreS.TExplorationSite

| offset | field | c type | from |
|---|---|---|---|
| +$34 | FArmy | TArmy | constructor |

## ExploreS.TExplorationSiteResource

| offset | field | c type | from |
|---|---|---|---|
| +$64 | FUnitIndexListCollection | TUnitIndexListCollection | constructor |

## FlagEvents.TFlagMessageEvent

| offset | field | c type | from |
|---|---|---|---|
| +$1C | FStringList | TStringList | constructor |

## FlagEvents.TTutorialMessageEvent

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FStringList | TStringList | constructor |

## GlobalEnchantmentSpells.TFloodEnchantment

| offset | field | c type | from |
|---|---|---|---|
| +$2C | FFloodControl | TFloodControl | constructor |

## GlobalSpells.TBirdsViewHS

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FIntegerList | TIntegerList | constructor |

## GlobalSpells.TConcealAreaHS

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FIntegerList | TIntegerList | constructor |

## GlobalSpells.TDisjunctionSpellCaster

| offset | field | c type | from |
|---|---|---|---|
| +$14 | FEnchantmentID | undefined4 | setter |
| +$18 | FDispelChance | int | setter |

## GlobalTargetSpells.TWatcherHS

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FWatcherEnchantment | TWatcherEnchantment | constructor |
| +$18 | FIntegerList | TIntegerList | constructor |

## HeroCtrl.THeroControlGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1DC | FIntegerList | TIntegerList | constructor |
| +$1E4 | FMemoryStream | TMemoryStream | constructor |

## HeroGrid.THeroGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1DC | FIntegerList | TIntegerList | constructor |
| +$1E8 | FMemoryStream | TMemoryStream | constructor |

## HxBridge.THexagonBridge

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FTerrain | undefined1 | getter |
| +$14 | FByteList | TByteList | constructor |
| +$18 | FByteList | TByteList | constructor |

## ItemCtrl.TItemControlGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1DC | FIntegerList | TIntegerList | constructor |
| +$1E0 | FMemoryStream | TMemoryStream | constructor |

## ItemGrid.TItemGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1E0 | FIntegerList | TIntegerList | constructor |
| +$1E4 | FItems | undefined4 | setter |
| +$1E8 | FMemoryStream | TMemoryStream | constructor |

## LeadrGrd.TLeaderGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1E0 | FMemoryStream | TMemoryStream | constructor |

## MoveOnEvents.TShowMessageMoveOnEvent

| offset | field | c type | from |
|---|---|---|---|
| +$18 | FStringList | TStringList | constructor |

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

## Sign.TUpdateSignTE

| offset | field | c type | from |
|---|---|---|---|
| +$10 | FStringList | TStringList | constructor |

## SmokeCloud.TSmokeCloud

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FSmokeCloudEnchantment | TSmokeCloudEnchantment | constructor |

## SummonSpells.TSummonSpellTE

| offset | field | c type | from |
|---|---|---|---|
| +$20 | FUnitIndexList | TUnitIndexList | constructor |

## UnitGrid.TUnitGrid

| offset | field | c type | from |
|---|---|---|---|
| +$1E0 | FUnits | int | setter |
| +$1E5 | FShowUnitLevel | undefined1 | setter |
| +$1F0 | FMemoryStream | TMemoryStream | constructor |

## UnitIGrd.TUnitIndexGrid

| offset | field | c type | from |
|---|---|---|---|
| +$79 | FShowUnitLevel | undefined1 | setter |
| +$1DC | FUnitIndexList | int | setter |

## UnitTabC.TUnitTabControl

| offset | field | c type | from |
|---|---|---|---|
| +$144 | FUnitIndexGrid | int | setter |
