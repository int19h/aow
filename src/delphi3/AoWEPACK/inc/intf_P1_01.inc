{ Interface declaration run owned by P1. }
type
  TWorldFXHS = class;
  TPlayerStructureList = class;
  TArmyList = class;
  TUnitProduction = class;
  TUnitProductionList = class;
  TProductionItem = class;
  TProductionQueue = class;
  TProductionSettings = class;
  TProductionEventLog = class;
  TProductionTE = class;
  TProductionControl = class;
  TProductionControlList = class;
  TEnchantment = class;
  TEnchantmentList = class;
  TChangePlayerMagicTE = class;
  TPlayerMagicEventLog = class;
  TPowerSource = class;
  TExternalPowerSource = class;
  TPowerSourceList = class;
  TPlayerMagicControl = class;
  TGlobalEnchantment = class;
  TGlobalEnchantmentEventLog = class;
  TGlobalEnchantmentList = class;
  TChangeGlobalMagicTE = class;
  TGlobalMagicControl = class;
  TRace = class;
  TRaceList = class;
  TDiplomaticRelationList = class;
  TDiplomaticRelationHistoryItem = class;
  TDiplomaticRelationHistoryList = class;
  TPlayerDiplomaticRelations = class;
  TLeaderSetupControl = class;
  TTurnInfoItem = class;
  TTurnInfo = class;
  TPlayerStatistics = class;
  TIncomeSource = class;
  TIncomeSourceList = class;
  TPBEMPlayerSettings = class;
  TPlayer = class;
  TPlayerList = class;
  TAoWNewHSMapSettings = class;
  TAoWMapField = class;
  TAoWMapLevel = class;
  TSubMove = class;
  TSubMoveList = class;
  TMoveControlSettings = class;
  TMoveControl = class;
  TAoWTokenManager = class;
  TPlayerConnectionEventLog = class;
  TPlayerControl = class;
  TTextControlItem = class;
  TTextControl = class;
  TNewTurnEventLog = class;
  TTurnPlayerControl = class;
  TSendEmailGameEventLog = class;
  TPBEMPlayerControl = class;
  TSimultaniousPlayerControl = class;
  TMovepath = class;
  TMoveSettings = class;
  TMoveSettingsList = class;
  TMoveSelector = class;
  TSelectedArmy = class;
  TTargetSelectionControl = class;
  TAoWHSMapKeyboard = class;
  TAbstractAoWHSMapMouse = class;
  TAoWHSMapMouse = class;
  TAbstractAoWHSMap = class;
  TAbstractAoWCombatMap = class;
  TTutorialControl = class;
  TStartupSongList = class;
  TAoWHSMap = class;
  TUnitGFXResource = class;
  TUnitGFXResourceList = class;
  TAoWMapObjectEditor = class;
  TUnitShadowHS = class;
  TUnitHS = class;
  TAbilityData = class;
  TActivateAbilityInfo = class;
  TAbility = class;
  TCustomAbilityList = class;
  TAbilityList = class;
  TAbilityOwner = class;
  TAbilityTypeList = class;
  TAbilityControl = class;
  TItemGFX = class;
  TItemGFXList = class;
  TItemTE = class;
  TItem = class;
  TItemList = class;
  TItemLibrary = class;
  TItemLibraryManager = class;
  TItemControl = class;
  TItemHSList = class;
  TItemHS = class;
  TFaceResource = class;
  TFaceResourceList = class;
  TUnitControl = class;
  TAbstractUnit = class;
  TAbstractUnitResource = class;
  TUnitResource = class;
  TUnitResourceList = class;
  TUnit = class;
  TUnitList = class;
  TUnitUserList = class;
  TUnitIndexList = class;
  TUnitIndexListCollection = class;
  TUnitCategoryList = class;
  TUnitSelectionControl = class;
  TUnitSelector = class;
  TUnitSelectorAAI = class;
  THeroInventory = class;
  THeroItems = class;
  THeroUpgradeTE = class;
  THeroUpdateTE = class;
  THeroPowerSource = class;
  THeroUpgradeEventLog = class;
  TJoinEventLog = class;
  THeroJoinEventLog = class;
  THeroEmergeEventLog = class;
  THero = class;
  TLeader = class;
  THeroList = class;
  THeroControl = class;
  THeroLibrary = class;
  THeroLibraryManager = class;
  THeroResource = class;
  THeroResourceList = class;
  TAdjustableUnit = class;
  TWallUnit = class;
  TArmyID = class;
  TArmy = class;
  TArmyView = class;
  TArmyHS = class;
  TArmyHSList = class;
  TArmyEventLog = class;
  TArmyInfoEventLog = class;
  TRaceResource = class;
  TRaceResourceList = class;
  TStructureShadow = class;
  TStructure = class;
  TStructureControl = class;
  TStructureResource = class;
  TRazeStructureEventLog = class;
  TPlayerStructureIncomeSource = class;
  TPlayerStructurePowerSource = class;
  TPlayerStructure = class;
  TPlayerStructureResource = class;
  TStructureTE = class;
  TFrozenWaterHS = class;
  TPadControl = class;
  TFlagControl = class;
  TAoWHSSet = class;
  TEmailGame = class;
  TEmailGameList = class;
  TEmailGameControl = class;
  TRestartGameEventLog = class;
  TSMTPEventLog = class;
  TFire = class;
  TFireResource = class;
  TFireControl = class;
  TCombatPredictorUnit = class;
  TCombatPredictorUnitList = class;
  TCombatPredictorSide = class;
  TCombatPredictor = class;
  TCombatObject = class;
  TCombatUnit = class;
  TCombatWall = class;
  TCombatSide = class;
  TFastCombatCommand = class;
  TFastCombatCommandList = class;
  TCombatViewer = class;
  TCombatAction = class;
  TSingleTargetCA = class;
  TDamageCA = class;
  TDamageEffectCA = class;
  TUpdateHeaderCA = class;
  TNewCombatTurnCA = class;
  TNewCombatRoundCA = class;
  TCombatObjectTurnDoneCA = class;
  TMoveWallCA = class;
  TFleeCA = class;
  TCombatActionList = class;
  TCombatParty = class;
  TCombatPartyList = class;
  TCombatPlayer = class;
  TCombatPlayerList = class;
  TCombatData = class;
  TCombatLogbook = class;
  TCombat = class;
  TCombatEventLog = class;
  TCombatTypeRequestEventLog = class;
  TAIPlayerAction = class;
  TAIPlayerActionList = class;
  TAIPlayerActionManager = class;
  TAIGroupList = class;
  TAIPlayerControl = class;
  TAIExecuter = class;
  TAIMoveControlSettings = class;
  TAIMoveControl = class;
  TMoveTarget = class;
  TMoveTargetList = class;
  TAIMoveTargetSelector = class;
  TAIMoveExecuterUnit = class;
  TAIMoveExecuterUnitList = class;
  TAIMoveExecuterArmy = class;
  TAIMoveExecuterArmyList = class;
  TAIMoveExecuterMove = class;
  TAIMoveExecuterMoveQueue = class;
  TAIMoveExecuterControl = class;
  TDefaultMEC = class;
  TAdjacentArmy = class;
  TAdjacentArmyList = class;
  TAdjacentMEC = class;
  TTransportMEC = class;
  TAIMoveExecuter = class;
  TEndTurnAIPA = class;
  TInitializeAIPA = class;
  TGroupControlAIPA = class;
  TGroupControlLoopAIPA = class;
  TAIBudget = class;
  TAISavingsBudget = class;
  TAITransporterBudget = class;
  TAIBudgetList = class;
  TAIBudgetManager = class;
  TBudgetManagerAIPA = class;
  TAutoProduceAIPA = class;
  TProcessEventlogAIPA = class;
  TStructureAIPA = class;
  TStructurePhase1AIPA = class;
  TStructurePhase2AIPA = class;
  TAIGroupProduction = class;
  TAIGroupProductionList = class;
  TAIGroup = class;
  TAIGroupManager = class;
  TAIGroupControlTarget = class;
  TAIGroupControlTargetList = class;
  TAIRecruitmentGroup = class;
  TAIRecruitmentGroupList = class;
  TAIGroupProductionLocation = class;
  TAIGroupProductionLocationList = class;
  TAIGroupControlPlugin = class;
  TAIGroupControl = class;
  TAIGroupTargetFinder = class;
  TGroupDefenseSelector = class;
  TAIGroupDefenseControl = class;
  TAIRecruitmentGroupFinder = class;
  TAIGroupRecruitControl = class;
  TAIGroupCooperationControl = class;
  TAIProductionLocationFinder = class;
  TAIGroupUnitProduction = class;
  TAIGroupUnitProductionList = class;
  TAIGroupProductionControl = class;
  TAIGroupTargetPrioritySettings = class;
  TAIGroupTargetSelector = class;
  THuntAG = class;
  THuntAGC = class;
  TGroupControl = class;
  TGuardGC = class;
  TPassiveGC = class;
  TGuardAreaGC = class;
  TSuicidalGC = class;
  TPatrolGC = class;
  TScoutGC = class;
  TRefugeGC = class;
  TEndTurnTE = class;
  TChangePlayerSettingsTE = class;
  TMoveTE = class;
  TMultiMoveTE = class;
  TMoveArmyTE = class;
  TArmyDefaultMoveTE = class;
  TArmyNegotiateMoveTE = class;
  TArmyCombineMoveTE = class;
  TArmyCombatMoveTE = class;
  TCombatRestoreHotseatEventLog = class;
  TNegotiateTE = class;
  TNegotiateRequestEventLog = class;
  TGameOverTE = class;
  TSaveGameTE = class;
  TCheatTE = class;
  TDisbandUnitTE = class;
  TCombatFlowControlTE = class;
  TTerminatePlayerTE = class;
  TFastCombatUnit = class;
  TFastCombatParty = class;
  TCombatObjectList = class;
  TFastCombat = class;
  TAbilityPlugIn = class;
  TAdjustableAbility = class;
  TEnhancementAbility = class;
  TDurationAbilityData = class;
  TDurationAbility = class;
  TMultiLevelAbilityData = class;
  TMultiLevelAbility = class;
  TTransportAbility = class;
  TStrikeCA = class;
  TMeleeRound = class;
  TStrikeEnhancementAbility = class;
  TStrikeAbility = class;
  TRangedAttackCA = class;
  TRangedAttackAbility = class;
  TBoltsAbility = class;
  TBreathAbility = class;
  TFlameThrowingAbility = class;
  TTouchAbility = class;
  TPossessCA = class;
  TPossessAbility = class;
  TPossessedAbilityData = class;
  TPossessedAbility = class;
  TWebCA = class;
  TWebAbility = class;
  TEntangleCA = class;
  TEntangleAbility = class;
  TInvokeDeathCA = class;
  TInvokeDeathAbility = class;
  TTurnUndeadCA = class;
  TTurnUndeadAbility = class;
  TRoundAttackAbility = class;
  TCommandedAbilityData = class;
  TCommandedAbility = class;
  TCommandCA = class;
  TCommandAbilityData = class;
  TCommandAbility = class;
  TDominatedAbility = class;
  TDominateAbility = class;
  TCharmedAbility = class;
  TCharmAbility = class;
  TSeducedAbility = class;
  TSeduceAbility = class;
  TSelfDestructCA = class;
  TSelfDestructAbility = class;
  TWallCrushingAbility = class;
  THealingCA = class;
  THealingAbilityData = class;
  THealingTE = class;
  THealingUnitSelector = class;
  THealingAbility = class;
  TDispelMagicCA = class;
  TDispelMagicAbilityCA = class;
  TDispelMagicAbilityTE = class;
  TDispelMagicAbilityData = class;
  TDispelMagicAbilityUnitSelector = class;
  TDispelMagicAbility = class;
  TLeadershipAbilityData = class;
  TLeadershipAbility = class;
  TUnitEnchantment = class;
  TUnitEnchantmentAbilityData = class;
  TUnitEnchantmentAbility = class;
  TConstructionControl = class;
  TConstructionControlList = class;
  TConstructAbility = class;
  TCosmeticSurgeryEnchantment = class;
  TCosmeticSurgeryAbility = class;
  TSpellCastingAbility = class;
  TSpellCC = class;
  TSpell = class;
  TSpellControl = class;
  TSpellList = class;
  TSpellTE = class;
  TSpellCaster = class;
  TCombatSpellCaster = class;
  TSpellCastEventLog = class;
  TUnitSpellCaster = class;
  TUnitSpellTE = class;
  TUnitSpellCA = class;
  TUnitSpell = class;
  TResearchSpellAIPA = class;
  TAICastSpellAction = class;
  TAICastSpellActionList = class;
  TCastSpellAIPA = class;
  TAoWMapCampaignSettings = class;
  TAoWCampaignTransferSettings = class;
  TAoWCampaignScenario = class;
  TAoWCampaignScenarioList = class;
  TAoWCampaign = class;
  TDiplomaticAction = class;
  TDiplomaticActionList = class;
  TDiplomaticActionTE = class;
  TDiplomaticActionEventLog = class;
  TDiplomacyAIPA = class;
  TAoWDictionary = class;
  TAoWEngine = class;
  TAgeOfWondersEngine = class;
  TStructureConstructionControl = class;
  TConstructStructureTE = class;
  TExportTextStream = class;
  TTranslateTextStream = class;
  TRebuildConstructionControl = class;
  TBuildRoadsControl = class;
  TUnitResourceAbilityOwner = class;
  THeroResourceAbilityOwner = class;

  TAoWTerrainType = (ttWater, ttGrass, ttDesert, ttSnow, ttSteppe, ttWasteland, ttIce, ttEarth, ttRock, ttLaval, ttUndergroundWater, ttReserved, ttDirt, ttUndergroundIce, ttCost, ttBorder);  { ot=1 }
  TAoWTerrainTypes = set of TAoWTerrainType; { ot=3 }
  TPlayerBehavior = (pbNormal, pbAggressor, pbDefender, pbExpander, pbScorcher, pbRandom);  { ot=1 }
  TGroupBehavior = (gbNone, gbPatrol, gbGuard, gbGuardArea, gbScout, gbRefuge, gbRaid, gbAggressive, gbDefensive, gbFortify, gbSuicidal, gbPassive, gbUndefined, gbHunt, gbExpand, gbScorch, gbNormal, gbSkirmish, gbTransport);  { ot=1 }
  TStormType = (stNone, stFire, stDeath, stHoly, stIce, stLightning, stPestilence);  { ot=1 }
  { Storm damage summary (20 bytes): $0C friendly damage, $10 enemy damage. }
  TStormDamageInfo = record
    Player, IndependentRelation: Shortint; FriendlyRelations, EnemyRelations: set of 0..7; FriendlyValue, EnemyValue: Integer; { $00..08; 55790333..55790482 }
    FriendlyDamage: Integer;
    EnemyDamage: Integer;
  end;
  TPlayerType = (ptHuman, ptCPU1, ptCPU2, ptCPU3, ptIndependent, ptFree, ptCPU4, ptCPU5);  { ot=1 }
  TPlayerTypes = set of TPlayerType; { ot=1 }
  TGameOverStatus = (goNone, goWon, goLost);  { ot=1 }
  TGameType = (gtCustom, gtCampaign, gtTutorial);  { ot=1 }
  TGameStatus = (gsIdle, gsPlaying, gsTerminated);  { ot=1 }
  TGameResult = (grNone, grFailed, grSucceeded);  { ot=1 }
  TPlayerStatus = (psIdle, psPlaying, psTerminated);  { ot=1 }
  TUnitRank = (urNone, urSilver, urGold);  { ot=1 }
  TBehaviour = (btNormal, btLawful, btChaotic);  { ot=1 }
  TUnitType = (utHumanoid, utCreature, utMachine);  { ot=1 }
  TUnitTypes = set of TUnitType; { ot=1 }
  TUnitGender = (ugMale, ugFemale, ugNeutral);  { ot=1 }
  TMoveType = (mtWalking, mtFlying, mtSwimming, mtForestry, mtCaveCrawling, mtMountaineering, mtLavaCrossing, mtTunneling);  { ot=1 }
  TMoveTypes = set of TMoveType; { ot=1 }
  TCampaignDifficultyLevel = (cdlEasy, cdlNormal, cdlHard);  { ot=1 }
  TDamageType = (dtFire, dtCold, dtLightning, dtMagic, dtPoison, dtDeath, dtHoly, dtPhysical, dtWall, dtNone);  { ot=1 }
  TDamageTypes = set of TDamageType; { ot=3 }
  TVictoryCondition = (vcNone, vcCaptureLocations, vcAccumulateGold, vcAccumulateMana);  { ot=1 }
  TTurnOrderMode = (toFixed, toRandom, toChanging);  { ot=1 }
  TIndependentAIMode = (iaOff, iaPassive, iaNormal, iaAggressive);  { ot=1 }
  TItemType = (itHead, itTorso, itAttack, itDefense, itRing, itScroll, itUse);  { ot=1 }
  TItemTypes = set of TItemType; { ot=1 }
  TItemAvailability = (iaExceptional, iaRare, iaCommon, iaFrequent);  { ot=1 }
  THeroType = (htHero, htLeader, htHeroLeader, htMerchant);  { ot=1 }
  THeroTypes = set of THeroType; { ot=1 }
  TPlayMode = (pmNone, pmTurn, pmSimultaneous);  { ot=1 }
  TPlayerConnectionType = (pcLocal, pcNetwork, pcEmail);  { ot=1 }
  TMoveAction = (maNormal, maAttack, maNegotiate, maCombine);  { ot=1 }
  TBloodType = (btNone, btRed, btBlue, btGreen);  { ot=1 }
  TCityTerrainSet = set of 0..15;
  TRaceTerrainInfo = record Bonus, Penalty: TCityTerrainSet; end;
  TRaceTerrainTable = array[0..11] of TRaceTerrainInfo;
  TDefensePriority = (dpNone, dpLow, dpAverage, dpHigh);  { ot=1 }
  TAbilitySelectionType = (astUnit, astHeadItem, astTorsoItem, astAttackItem, astDefenseItem, astRingItem, astUseItem, astCustomizeLeader, astHeroUpgrade, astEditor);  { ot=1 }
  TAbilitySelectionTypes = set of TAbilitySelectionType; { ot=3 }
  TAbilityControlType = set of (acAction, acCombatAction); { ot=1 }
  TAbilityType = (atEnhancement, atHandicap, atMovement, atCombat, atEnchantment);  { ot=1 }
  TAlignment = (alPureGood, alGood, alPureNeutral, alNeutral, alEvil, alPureEvil, alNone);  { ot=1 }
  TAlignments = set of TAlignment; { ot=1 }
  TDiplomaticRelation = (drPeace, drWar, drAlliance, drUnknown);  { ot=1 }
  TDiplomaticRelations = set of TDiplomaticRelation; { ot=1 }
  TDiplomaticActionType = (daDeclareWar, daOfferPeace, daProposeAlliance, daSendMessage, daThreatenToAttack, daMakeTribute, daBreakAlliance, daSendMessageAsY, daBreakAllianceWithY, daDeclareWarToY);  { ot=1 }
  TDiplomaticActionReaction = (darNone, darAccept, darReject, darIgnore);  { ot=1 }
  TDamageRollType = (drtDefense, drtResistance);  { ot=1 }
  TUnitSize = (usSmall, usMedium, usLarge, usExtraLarge);  { ot=1 }
  TMorale = (mTerrible, mPoor, mOK, mGood, mHigh);  { ot=1 }
  TStatus = (sHostile, sWary, sNeutral, sPolite, sFriendly);  { ot=1 }
  TStatusNames = array[TStatus] of string;
  TWallType = (wtNone, wtWood, wtStone);  { ot=1 }
  TWallSituation = (wsNone, wsSource, wsTarget);  { ot=1 }
  TExitGameMode = (egmLoad, egmReload, egmExit, egmTerminate);  { ot=1 }
  TCombatTargetType = set of (cttFriend, cttEnemy); { ot=1 }
  TTacticalCombatAvailability = (tcaNever, tcaBetweenHumans, tcaAlways);  { ot=1 }
  TCombatMode = (cmNone, cmMelee, cmTouch, cmShortRange, cmMediumRange, cmLongRange);  { ot=1 }
  TCombatModes = set of TCombatMode; { ot=1 }
  TCombatSideIndex = (csAttacker, csDefender, csNeutral);  { ot=1 }
  TWallCombatFeatures = set of (wcWallBreaching, wcWallPassing, wcParticipate); { ot=1 }
  TFogExplorationChanged = set of (feFog, feExploration); { ot=1 }
  TMagicSphere = (msCosmos, msLife, msDeath, msEarth, msAir, msFire, msWater, msSecret, msNone);  { ot=1 }
  TMagicSpheres = set of TMagicSphere; { ot=3 }
  TSpellType = (stCombat, stUnit, stGlobal);  { ot=1 }
  TSpellTypes = set of TSpellType; { ot=1 }
  TPartyStatus = (psUnruly, psUnrest, psStable, psContent, psCheerful);  { ot=1 }
  TAITargetMode = (tmAttack, tmRaid, tmRecruit, tmProduce, tmHunt, tmFortify, tmDefend, tmGuardArea, tmAttackArmies);  { ot=1 }
  TAITargetType = (attAttack, attNegotiate);  { ot=1 }
  TMovePointTable = array[0..15, -1..14] of Shortint; { $100; 557D7848 }
  TAITargetInfo = record Player, IndependentRelation: Shortint; Mode: TAITargetMode; Reserved03: Byte; Reserved04, Reserved08: Integer; end; { $0C; 557D779E }
  TworldFXType = (fxHatred, fxCrusade, fxWaterMastery, fxSpellWard, fxWMParticle, fxWMLParticle, fxHatredParticle, fxSWParticle, fxSWBeamParticle, fxEarthMastery, fxEMParticle, fxTranquility, fxTranqParticle);  { ot=1 }
  TBattleFieldInfoRequests = set of (bfrWallPassing, bfrReturnImmunityTypes, bfrIgnorePassiveIndependents, bfrEffectiveStrength, bfrIgnoreIndependents); { ot=1 }
  TBattleFieldRelations = set of 0..7;
  TBattleFieldInfo = packed record
    Player, IndependentRelation: Shortint; Requests: TBattleFieldInfoRequests;
    DamageTypes: TDamageTypes; Reserved05: array[0..2] of Byte; Units: TUnitList; { $08; 5578C334 }
    FriendlyRelations, EnemyRelations: TBattleFieldRelations; { $0C, $0D }
    Reserved0E: array[0..1] of Byte;
    FriendlyStrength: Integer; { $10 }
    Strength: Integer; { $14 } Reserved18: Integer;
  end;
  TDamageStrengths = array[TDamageType] of Integer; TDefenseRequirements = record case Integer of 0: (Reserved00: array[0..27] of Byte; Strength: Integer; Reserved20: array[0..7] of Byte); 1: (DamageStrengths: TDamageStrengths); end; { $28; 55771E58 }
  TAITargetData = record Priority: Integer; TargetType: TAITargetType; Cost: Integer; Reserved0C: array[0..11] of Byte; end; { $18; 557D77C1 }
  TProductionControlStatus = (pcsIdle, pcsWaiting, pcsProducing);  { ot=1 }
  TProductionUpdateMode = (umProduce, umResearch, umCancel);  { ot=1 }
  TChangePlayerMagicMode = (cmmDispelEnchantment, cmmChangePowerSettings, cmmResearchSpell);  { ot=1 }
  TPlayerMagicEventMode = (pmemSpellResearched, pmemOutOfMana, pmemStartResearch);  { ot=1 }
  TPlayerEnchantmentType = (petNone, petEnchantedRoads, petAirMastery, petWaterMastery, petLifeMastery, petDeathMastery, petFireMastery, petEarthMastery);  { ot=1 }
  TPlayerEnchantmentTypes = set of TPlayerEnchantmentType; { ot=1 }
  TGlobalEnchantmentType = (getNone, getHatred, getHarmony, getPowerLeak, getFlood, getFireMastery, getSpellWard);  { ot=1 }
  TGlobalEnchantmentTypes = set of TGlobalEnchantmentType; { ot=1 }
  TGlobalEnchantmentMode = set of (gemTrueGlobal, gemOwned); { ot=1 }
  TGlobalEnchantmentStatus = set of (getActivated); { ot=1 }
  TChangeGlobalMagicMode = (cgmDispelEnchantment, cgmRemoveEnchantment);  { ot=1 }
  TLeaderSetupMode = set of (lsmLook, lsmSettings, lsmSpheres, lsmCampaign); { ot=1 }
  TLeaderSetupStatus = (lssNone, lssBusy, lssDone, lssCanceled);  { ot=1 }
  TPBEMPlayerStatus = set of (pbsNewTurn, pbsPlaying, pbsTurnDone); { ot=1 }
  THeroEmergeMode = (hemNormal, hemFirstHero);  { ot=1 }
  TMoveOnMovePointProc = function(MapF: TAoWMapField; MoveOverCode: Integer): Integer of object;
  TMoveMode = set of (mmLogProcessedMapFields, mmExploredTerrainOnly, mmAI, mmIgnoreArmies, mmAvoidArmies, mmSurround); { ot=1 }
  TMoveControlSettingsStatus = (mcssIdle, mcssProcessing, mcssProcessed, mcssFailed);  { ot=1 }
  TCanMoveMode = set of (mmFast, mmExact); { ot=1 }
  TMoveControlStatus = set of (mcsActivated); { ot=1 }
  TPlayerConnectionFailure = (pcfNone, pcfTimeOut, pcfDisconnected, pcfOutOfSync);  { ot=1 }
  TExitGameCallBack = procedure(Mode: TExitGameMode; Exited: Boolean) of object;
  THotSeatMode = (hmWaiting, hmShowNextLog, hmShowingLog, hmIdle);  { ot=1 }
  TNewTurnEventLogMode = (ntDialog, ntClose);  { ot=1 }
  TNewTurnEventLogDialogStyle = set of (nsUseOverlay, nsCloseable); { ot=1 }
  TEmailSendMode = (esmAutomated, esmManual, esmCancel);  { ot=1 }
  TMoveSelectorStatus = set of (mssActivated, mssShowSelector); { ot=1 }
  TSelectedArmyMode = (samDefault, samBuildRoads);  { ot=1 }
  TTargetSelectionStatus = set of (tsActivated, tsVisible); { ot=1 }
  TTargetSelectionMode = set of (tmOwnerDraw, tmFixedLevel, tmValidateDistance, tmExternalFloater); { ot=1 }
  TShowTargetSelectionEvent = procedure(TargetSelection: TTargetSelectionControl; HN: Integer; Xs: Integer; Ys: Integer; const SurfaceDesc: TSurfaceDesc) of object;
  TValidateTargetEvent = procedure(TargetSelection: TTargetSelectionControl; Xt: Shortint; Yt: Shortint; Lt: Shortint; var Valid: Boolean) of object;
  TTargetSelectionChange = (tscNone, tscActivated, tscSelected, tscDeactivated);  { ot=1 }
  TAoWHSMapKeyboardMode = (kmDefault, kmCheat);  { ot=1 }
  TRectangleSelectEvent = procedure(const SelectionRect: TRect) of object;
  TMoveSpeed = (msSlow, msNormal, msFast, msVeryFast);  { ot=1 }
  TAbilityInfoMode = set of (aimID, aimDescription, aimStatistics, aimStrength); { ot=1 }
  TItemTokenEventMode = (itmUse);  { ot=1 }
  TItemStatus = set of (isActivated, isRegistered, isReadonly); { ot=1 }
  TItemControlStatus = set of (icsActivated); { ot=1 }
  TItemGenerateMode = (igUserDefined, igLow, igAverage, igHigh, igRandom);  { ot=1 }
  TUnitPlaceMode = set of (pmScanArea, pmNeglectEmptyPlayerLocation, pmCreateNewArmy); { ot=1 }
  TUnitOverlayModes = set of (uoHitPoints, uoRank, uoCombat); { ot=1 }
  TUnitAnimation = (uaStandStill, uaMove, uaAttack, uaHit, uaNone);  { ot=1 }
  TUnitStatus = set of (usRegistered, usActivated, usMoving, usMoveDone, usKilled, usEnchanted); { ot=1 }
  TJoinMode = (jmDefault);  { ot=1 }
  TUnitViewStatus = set of (uvPoisoned); { ot=1 }
  THeroItemPosition = (ipAttackSlot, ipHeadSlot, ipDefenseSlot, ipLeftRingSlot, ipTorsoSlot, ipRightRingSlot, ipInventorySlot1, ipInventorySlot2, ipInventorySlot3, ipInventorySlot4, ipInventorySlot5, ipInventorySlot6, ipInventorySlot7, ipInventorySlot8, ipGround, ipNone);  { ot=1 }
  THeroStatus = set of (hsDied); { ot=1 }
  THeroMode = set of (hmUpdatingFromLibrary, hmSkipLibraryUpdate); { ot=1 }
  THeroUpdateMode = (hmPlaceItem, hmSwapItem, hmStartCasting, hmCancelCasting);  { ot=1 }
  THeroJoinMode = (hjmEmerged, hjmResurrected);  { ot=1 }
  THeroSortMode = (smName, smLevel);  { ot=1 }
  THeroesUpdatedEvent = procedure(HeroList: THeroList) of object;
  TArmyStatus = set of (asActivated, asUnfogEnabled, asSelected, asConcealed, asFullyConcealed, asShowCrown); { ot=1 }
  TAddUnitsResult = (arOK, arInvalidMoveType, arTooManyUnits, arMultipleTransporters);  { ot=1 }
  TArmyMode = set of (amFixedBehavior, amAIMoveDone, amMoving, amDisableTerrainValidation); { ot=1 }
  TArmyUserMode = set of (aumGuard, aumTurnDone); { ot=1 }
  TArmyPlaceMode = set of (apSafe, apScanArea, apEnableOwnPlayerLocation); { ot=1 }
  TStructureShadowStatus = set of (sssConnected, sssVisible); { ot=1 }
  TFireMode = set of (fmExpandable); { ot=1 }
  TFireType = (ftSmall, ftLarge);  { ot=1 }
  TCombatType = (ctNone, ctFast, ctTactical);  { ot=1 }
  TCombatObjectStatus = set of (csDestroyed, csTurnDone, csActivated, csFled, csDamaged); { ot=1 }
  TCombatObjectControlMode = set of (cmConquerObject); { ot=1 }
  TCombatRange = (crTouch, crShort, crMedium, crLong);  { ot=1 }
  TCombatResult = (crIdle, crBusy, crCannotInflictDamage, crVictory, crDefeat, crBothDefeated, crNoDefenders, crUndecided, crCannotBreachWall, crFled);  { ot=1 }
  TFinalizeMode = (fmOriginal, fmOriginalRetry, fmAll);  { ot=1 }
  TCombatSFXType = (csMelee, csMeleeMiss, csHit, csDie);  { ot=1 }
  TCombatPredictorUnitStatus = set of (usUseless, usDestroyed); { ot=1 }
  TFastCombatExecuteResult = (fcerExecuted, fcerWaiting, fcerDone);  { ot=1 }
  TCombatViewerStatus = set of (vsInitialized, vsPlaying, vsPaused); { ot=1 }
  TSingleTargetMode = set of (smDefensive); { ot=1 }
  TDamageCombatActionMode = set of (dmShowInverted); { ot=1 }
  TMoveWallMode = (mwmOutside, mwmInside);  { ot=1 }
  TCombatStatus = set of (cExecuting, cActivated, cLogCombatActions); { ot=1 }
  TCombatExecutedEvent = procedure(pCombat: TCombat) of object;
  TCombatPlaceID = (cpiNone, cpiExplorationSite, cpiNoneAdjacent);  { ot=1 }
  TAIPlayerProcessPhase = (appNone, appMain, appLoop);  { ot=1 }
  TAIPlayerProcessPhases = set of TAIPlayerProcessPhase; { ot=1 }
  TProcessTimeMode = (ptmStatic, ptmDynamic);  { ot=1 }
  TAIExecuterStatus = set of (aesEnabled, aesTokenLocked, aesExecuting); { ot=1 }
  TAIMoveControlStatus = (amsIdle, amsProcessing, amsDone, amsCanceled);  { ot=1 }
  TAIMoveControlMode = (mcsCanMove, mcsTransporterCanMove);  { ot=1 }
  TMoveTargetFoundEvent = procedure(Target: TMoveTarget; var SearchDone: Boolean) of object;
  TAIMoveTargetSelectorStatus = (atsIdle, atsSearching, atsDone, atsFailed, atsInvalidated);  { ot=1 }
  TAIMoveTargetSelectorMode = set of (tsmCreateMovepaths); { ot=1 }
  TAIMoveResult = (mrNone, mrSuccessfull, mrDone, mrFailed);  { ot=1 }
  TAIMoveExecuterMode = set of (memAdjacent, memSimultaneous, memAttack); { ot=1 }
  TAIMoveExecuterUnitStatus = (esIdle, esReady, esQueued, esMoving, esDone, esLost, esFailed);  { ot=1 }
  TAIMoveExecuterUnitStatusSet = set of TAIMoveExecuterUnitStatus; { ot=1 }
  TAIMoveExecuterTransportStatus = (mtsIdle, mtsBoarding, mtsTransporting, mtsArriving, mtsGuarding, mtsDumping, mtsDumped, mtsDone);  { ot=1 }
  TCreateMoveResult = (cmrOutOfMovePoints, cmrCannotMoveCloser, cmrDone, cmrFailed);  { ot=1 }
  TCreateMoveMode = set of (cmmDontQueue, cmmSurround, cmmSurroundEx); { ot=1 }
  TAIMoveExecuterStatus = (mesIdle, mesBusy, mesFailed, mesDone, mesOutOfMovePoints, mesInvalidated);  { ot=1 }
  TBudgetExpenseMode = (bemBudget, bemBudgetThenPool, bemPoolThenBudget);  { ot=1 }
  TRecruitmentGroupFinderMode = set of (rcmRecruit, rcmProduce); { ot=1 }
  TAIGroupControlStatus = set of (gcsActivated, gcsLoop); { ot=1 }
  TAIGroupStatus = set of (agsActivated, agsDone, agsChanged, agsEmpty, agsSplit); { ot=1 }
  TAIGroupTargetStatus = (gtsNone, gtsSetup, gtsExecute, gtsIdle);  { ot=1 }
  TAIGroupTargetType = (attNone, attWander, attDefend);  { ot=1 }
  TAIGroupControlTargetStatus = set of (gtsDone, gtsValid, gtsRecruit, gtsProduce, gtsCooperate, gtsReady); { ot=1 }
  TAIGroupControlPluginStatus = set of (gpsActivated); { ot=1 }
  TAIGroupTargetFinderMode = set of (tfmCalculateMovepathBFS); { ot=1 }
  TGroupDefendMode = (gdmSplit, gdmWait, gdmCustom);  { ot=1 }
  TGroupDefenseControlMode = set of (gdmProduce, gdmRecruit, gdmOptimizeLocation); { ot=1 }
  TAIRecruitmentGroupFinderMode = set of (rfmCalculateMovepathBFS); { ot=1 }
  TAIGroupRecruitControlMode = (rcmNone, rcmAutoRecruit, rcmCompleteRecruitOnly, rcmForceRecruit);  { ot=1 }
  TAIGroupCooperateControlMode = (ccmNone, ccmAutoCooperate, ccmCompleteCooperateOnly);  { ot=1 }
  TAIProductionLocationFinderMode = set of (pfmCalculateMovepathBFS); { ot=1 }
  TAIGroupProductionControlMode = (pcmNone, pcmAutoProduce, pcmCompleteProduceOnly);  { ot=1 }
  TAIGroupTargetSelectorMode = set of (tsmMultiTargets, tsmCooperate, tsmRecruit, tsmProduce); { ot=1 }
  TAIGroupTargetSelectorStatus = (tssIdle, tssBusy, tssSettingupTarget, tssExecutingTarget, tssNoTargetsFound, tssTargetConquered, tssFailed);  { ot=1 }
  TEndTurnMode = (emEndTurn, emCancelEndTurn);  { ot=1 }
  TMoveStatus = (msIdle, msMoving, msFailed, msDone, msFinished);  { ot=1 }
  TArmyMoveMode = set of (mmSelectEndLocation, mmBuildRoads, mmDontNegotiate); { ot=1 }
  TCombatMoveMode = (cmMoving, cmRequestingCombatType, cmSetupReady, cmCombatExecuted, cmCancelCombat, cmSetupHotseat, cmRestoringHotseat);  { ot=1 }
  TNegotiateOffer = (noOfferBribe, noForceOffer);  { ot=1 }
  TNegotiateObject = (noHero, noCity, noArmy);  { ot=1 }
  TNegotiateMode = set of (nmAttackOnReject, nmMoveOnAccept, nmPrisonerJoin); { ot=1 }
  TNegotiateResult = (nrUnknown, nrAccept, nrReject);  { ot=1 }
  TCombatFlowControlMode = set of (cfmSetAutoSwitch, cfmLockAIExecuter, cfmUnlockAIExecuter, cfmActivateTC, cfmEnableTurnTimer, cfmDisableTurnTimer); { ot=1 }
  TFastCombatUnitState = set of (fsOutsideWall, fsWallSiegeObjectRegistered, fsVulnerable); { ot=1 }
  TDurationMode = (dmNone, dmDay, dmCombatTurn, dmEntireCombat);  { ot=1 }
  TStrikeMode = set of (smCausedFear, smLifeStealing, smEntangled); { ot=1 }
  TMeleeStrikeResult = (srMissed, srHitted, srKilled);  { ot=1 }
  TSpellControlType = set of (sctGlobal, sctCombat); { ot=1 }
  TCampaignAutoSaveType = (casScenarioFinished);  { ot=1 }

