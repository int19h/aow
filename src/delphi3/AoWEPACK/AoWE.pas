unit AoWE;

{ Draft declarations of AoWE, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EventLog;

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
  TworldFXType = (fxHatred, fxCrusade, fxWaterMastery, fxSpellWard, fxWMParticle, fxWMLParticle, fxHatredParticle, fxSWParticle, fxSWBeamParticle, fxEarthMastery, fxEMParticle, fxTranquility, fxTranqParticle);  { ot=1 }
  TBattleFieldInfoRequests = set of (bfrWallPassing, bfrReturnImmunityTypes, bfrIgnorePassiveIndependents, bfrEffectiveStrength, bfrIgnoreIndependents); { ot=1 }
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

  { TWorldFXHS (instance size 40, VMT 55709CA8) }
  TWorldFXHS = class(TFixedVisibleHS)
  public
    F_WorldFXHS_0C: Byte;
    F_WorldFXHS_0D: array[0..2] of Byte;
    F_WorldFXHS_10: Integer;
    F_WorldFXHS_14: Integer;
    F_WorldFXHS_18: Integer;
    F_WorldFXHS_1C: Integer;
    F_WorldFXHS_20: Integer;
    F_WorldFXHS_24: Byte;
    F_WorldFXHS_25: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewFrame(A1: Integer);  { draft }
  end;

  { TPlayerStructureList (instance size 24, VMT 55709EC8) }
  TPlayerStructureList = class(TEChangeNotifyEventList)
  public
    F_PlayerStructureList_14: array[0..3] of Byte;
    procedure GetStructure(A1: Integer);  { draft }
  end;

  { TArmyList (instance size 24, VMT 55709FD8) }
  TArmyList = class(TEChangeNotifyEventList)
  public
    F_ArmyList_14: Byte;
    F_ArmyList_15: array[0..2] of Byte;
    procedure GetArmy(A1: Integer);  { draft }
  end;

  { TUnitProduction (instance size 16, VMT 5570A0D0) }
  TUnitProduction = class(TEObject)
  public
    F_UnitProduction_08: Integer;
    F_UnitProduction_0C: Byte;
    F_UnitProduction_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TUnitProductionList (instance size 12, VMT 5570A194) }
  TUnitProductionList = class(TENode)
  public
    procedure GetItem(A1: Integer);  { draft }
    procedure Add(A1: Integer; A2: Integer);  { draft }
    procedure IndexOf(A1: Integer);  { draft }
    procedure SortOnLevel;  { draft }
  end;

  { TProductionItem (instance size 20, VMT 5570A29C) }
  TProductionItem = class(TEObject)
  public
    F_ProductionItem_08: Integer;
    F_ProductionItem_0C: Integer;
    F_ProductionItem_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); virtual;  { +04C draft }
    procedure GetNameProgressive(A1: Integer);  { draft }
  end;

  { TProductionQueue (instance size 16, VMT 5570A364) }
  TProductionQueue = class(TENode)
  public
    F_ProductionQueue_0C: array[0..3] of Byte;
    procedure GetItem(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure IndexOf(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TProductionSettings (instance size 44, VMT 5570A4B4) }
  TProductionSettings = class(TEObject)
  public
    F_ProductionSettings_08: Integer;
    F_ProductionSettings_0C: Integer;
    F_ProductionSettings_10: Byte;
    F_ProductionSettings_11: array[0..2] of Byte;
    F_ProductionSettings_14: Integer;
    F_ProductionSettings_18: Integer;
    F_ProductionSettings_1C: Byte;
    F_ProductionSettings_1D: Byte;
    F_ProductionSettings_1E: array[0..1] of Byte;
    F_ProductionSettings_20: Integer;
    F_ProductionSettings_24: Integer;
    F_ProductionSettings_28: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
  end;

  { TProductionEventLog (instance size 32, VMT 5570A580) }
  TProductionEventLog = class(TLocationTextEventLog)
  public
    class function ClassID: Integer; override;
  end;

  { TProductionTE (instance size 40, VMT 5570A6C0) }
  TProductionTE = class(TTokenEvent)
  public
    F_ProductionTE_10: Byte;
    F_ProductionTE_11: Byte;
    F_ProductionTE_12: Byte;
    F_ProductionTE_13: Byte;
    F_ProductionTE_14: Integer;
    F_ProductionTE_18: Integer;
    F_ProductionTE_1C: Byte;
    F_ProductionTE_1D: array[0..2] of Byte;
    F_ProductionTE_20: Integer;
    F_ProductionTE_24: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TProductionControl (instance size 40, VMT 5570A784) }
  TProductionControl = class(TEObject)
  public
    F_ProductionControl_08: Byte;
    F_ProductionControl_09: array[0..0] of Byte;
    F_ProductionControl_0A: Word;
    F_ProductionControl_0C: Integer;
    F_ProductionControl_10: Integer;
    F_ProductionControl_14: Integer;
    F_ProductionControl_18: Byte;
    F_ProductionControl_19: array[0..2] of Byte;
    F_ProductionControl_1C: Integer;
    F_ProductionControl_20: Byte;
    F_ProductionControl_21: array[0..2] of Byte;
    F_ProductionControl_24: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CancelProductionReturnGold; virtual;  { +04C draft }
    procedure CancelProductionReturnMana; virtual;  { +050 draft }
    procedure ExecuteCancelProduction; virtual;  { +054 draft }
    procedure ExecuteAIProduction(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure ExecuteAIResearch(A1: Integer); virtual;  { +05C draft }
    procedure ExecuteProduction(A1: Integer); virtual;  { +060 draft }
    procedure ExecuteAddProduction(A1: Integer); virtual;  { +064 draft }
    procedure ExecuteDeleteProduction(A1: Integer); virtual;  { +068 draft }
    procedure ExecuteDeleteProductions; virtual;  { +06C draft }
    procedure ExecuteProductionTE(A1: Integer); virtual;  { +070 draft }
    procedure CreateProductionTE; virtual;  { +074 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +078 draft }
    procedure GetPlayer; virtual; abstract;  { +07C draft }
    procedure GetQueueSizeMax; virtual;  { +080 draft }
    procedure GetQueueLocked; virtual;  { +084 draft }
    procedure LoopableProduction(A1: Integer); virtual;  { +088 draft }
    procedure LockQueueProduction(A1: Integer); virtual;  { +08C draft }
    procedure UnitProduced; virtual;  { +090 draft }
    procedure UnitResearched; virtual;  { +094 draft }
    procedure Update; virtual;  { +098 draft }
    procedure CreateUnitProduction(A1: Integer); virtual;  { +09C draft }
    procedure Activate; virtual;  { +0A0 draft }
    procedure Deactivate; virtual;  { +0A4 draft }
    procedure NewTurn(A1: Integer); virtual;  { +0A8 draft }
    procedure PlayerChanged; virtual;  { +0AC draft }
    procedure CanExecuteProduction(A1: Integer; A2: Integer); virtual;  { +0B0 draft }
    procedure DeleteProduction(A1: Integer); virtual;  { +0B4 draft }
    procedure DeleteProductions; virtual;  { +0B8 draft }
    procedure GetProductionName(A1: Integer; A2: Integer); virtual;  { +0BC draft }
    procedure GetProductionNameProgressive(A1: Integer; A2: Integer); virtual;  { +0C0 draft }
    procedure UnitProductionGold(A1: Integer); virtual;  { +0C4 draft }
    procedure UnitProductionMana(A1: Integer); virtual;  { +0C8 draft }
    procedure UnitProductionGoldUpkeep(A1: Integer); virtual;  { +0CC draft }
    procedure UnitProductionManaUpkeep(A1: Integer); virtual;  { +0D0 draft }
    procedure UnitProductionTime(A1: Integer); virtual;  { +0D4 draft }
    procedure CanProduceUnit(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0D8 draft }
    procedure ProduceUnitEx(A1: Integer; A2: Integer); virtual;  { +0DC draft }
    procedure ProduceUnit(A1: Integer; A2: Integer); virtual;  { +0E0 draft }
    procedure UnitResearchGold(A1: Integer); virtual;  { +0E4 draft }
    procedure UnitResearchMana; virtual;  { +0E8 draft }
    procedure UnitResearchTime(A1: Integer); virtual;  { +0EC draft }
    procedure CanResearchUnit(A1: Integer; A2: Integer); virtual;  { +0F0 draft }
    procedure ResearchUnit(A1: Integer; A2: Byte); virtual;  { +0F4 draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure GetProduceUnitLevelMax;  { draft }
    procedure GetResearchUnitLevelMax;  { draft }
    procedure RegisterGroupProduction;  { draft }
    procedure UnregisterGroupProduction;  { draft }
    procedure GroupProductionProduced(A1: Integer; A2: Integer);  { draft }
    procedure Produce(A1: Integer; A2: Integer);  { draft }
    procedure RetryProductionExecution(A1: Integer);  { draft }
    procedure SetLoopQueueTo(A1: Integer);  { draft }
    procedure ProductionDone;  { draft }
    procedure FindOptimalResearchProduction(A1: Integer; A2: Integer);  { draft }
  end;

  { TProductionControlList (instance size 16, VMT 5570A8FC) }
  TProductionControlList = class(TList)
  public
    procedure GetPC(A1: Integer);  { draft }
  end;

  { TEnchantment (instance size 24, VMT 5570A98C) }
  TEnchantment = class(TEObject)
  public
    F_Enchantment_08: Integer;
    F_Enchantment_0C: Byte;
    F_Enchantment_0D: array[0..2] of Byte;
    F_Enchantment_10: Integer;
    F_Enchantment_14: Byte;
    F_Enchantment_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer); virtual;  { +04C draft }
    procedure GetBinding(A1: Integer); virtual;  { +050 draft }
    procedure SetUpkeep(A1: Integer); virtual;  { +054 draft }
    procedure SetSource(A1: Integer); virtual;  { +058 draft }
    procedure GetAIUpkeepPriority; virtual;  { +05C draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +060 draft }
    procedure CenterToLocation; virtual;  { +064 draft }
    procedure Dispel; virtual;  { +068 draft }
    procedure Select; virtual;  { +06C draft }
    procedure DispelChance(A1: Integer);  { draft }
  end;

  { TEnchantmentList (instance size 12, VMT 5570AA70) }
  TEnchantmentList = class(TENode)
  public
    procedure GetEnchantments(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure FindID;  { draft }
  end;

  { TChangePlayerMagicTE (instance size 28, VMT 5570ABDC) }
  TChangePlayerMagicTE = class(TTokenEvent)
  public
    F_ChangePlayerMagicTE_10: Byte;
    F_ChangePlayerMagicTE_11: Byte;
    F_ChangePlayerMagicTE_12: array[0..1] of Byte;
    F_ChangePlayerMagicTE_14: Integer;
    F_ChangePlayerMagicTE_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TPlayerMagicEventLog (instance size 44, VMT 5570AD0C) }
  TPlayerMagicEventLog = class(TEventLog)
  public
    F_PlayerMagicEventLog_18: Byte;
    F_PlayerMagicEventLog_19: array[0..2] of Byte;
    F_PlayerMagicEventLog_1C: Integer;
    F_PlayerMagicEventLog_20: Integer;
    F_PlayerMagicEventLog_24: Integer;
    F_PlayerMagicEventLog_28: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
  end;

  { TPowerSource (instance size 8, VMT 5570AE18) }
  TPowerSource = class(TEObject)
  public
    procedure Name(A1: Integer); virtual;  { +04C draft }
    procedure Power; virtual;  { +050 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +054 draft }
    procedure CenterToLocation(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure Select(A1: Integer; A2: Integer); virtual;  { +05C draft }
  end;

  { TExternalPowerSource (instance size 12, VMT 5570AEEC) }
  TExternalPowerSource = class(TPowerSource)
  public
    F_ExternalPowerSource_08: Integer;
    procedure Name(A1: Integer); override;
    procedure Power; override;
  end;

  { TPowerSourceList (instance size 12, VMT 5570AFD0) }
  TPowerSourceList = class(TENode)
  public
    procedure GetItems(A1: Integer);  { draft }
  end;

  { TPlayerMagicControl (instance size 76, VMT 5570B198) }
  TPlayerMagicControl = class(TEObject)
  public
    F_PlayerMagicControl_08: Integer;
    F_PlayerMagicControl_0C: Byte;
    F_PlayerMagicControl_0D: array[0..2] of Byte;
    F_PlayerMagicControl_10: Integer;
    F_PlayerMagicControl_14: Integer;
    F_PlayerMagicControl_18: Integer;
    F_PlayerMagicControl_1C: Integer;
    F_PlayerMagicControl_20: Integer;
    F_PlayerMagicControl_24: Integer;
    F_PlayerMagicControl_28: Word;
    F_PlayerMagicControl_2A: array[0..1] of Byte;
    F_PlayerMagicControl_2C: Integer;
    F_PlayerMagicControl_30: Integer;
    F_PlayerMagicControl_34: Integer;
    F_PlayerMagicControl_38: Integer;
    F_PlayerMagicControl_3C: Integer;
    F_PlayerMagicControl_40: Integer;
    F_PlayerMagicControl_44: Byte;
    F_PlayerMagicControl_45: Byte;
    F_PlayerMagicControl_46: array[0..1] of Byte;
    F_PlayerMagicControl_48: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetCheatEnabled;  { draft }
    procedure SetActiveEnchantments(A1: Byte; A2: Integer);  { draft }
    procedure UpdateEnemyEnchantments;  { draft }
    procedure GetManaIncome;  { draft }
    procedure GetManaUpkeep;  { draft }
    procedure SetMana(A1: Integer);  { draft }
    procedure GetPower;  { draft }
    procedure OutOfMana(A1: Integer);  { draft }
    procedure RemoveEnchantments;  { draft }
    procedure ValidateEnchantmentsUpkeep;  { draft }
    procedure ExecuteSpellResearched(A1: Integer);  { draft }
    procedure NewTurn;  { draft }
    procedure SetSpheres(A1: Word; A2: Integer);  { draft }
    procedure GetNetPower;  { draft }
    procedure GetNetPowerToMana(A1: Integer; A2: Integer);  { draft }
    procedure GetNetPowerToResearch(A1: Integer; A2: Integer);  { draft }
    procedure ResearchTurns(A1: Integer; A2: Integer);  { draft }
    procedure GetResearchTurnsLeft;  { draft }
    procedure ValidResearchSpell(A1: Integer);  { draft }
    procedure ListResearchSpells(A1: Integer; A2: Byte);  { draft }
    procedure ListSpells(A1: Integer; A2: Byte);  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure Update;  { draft }
    procedure ValidateEnchantmentID(A1: Integer);  { draft }
    procedure RegisterEnchantment(A1: Integer);  { draft }
    procedure UnregisterEnchantment(A1: Integer);  { draft }
    procedure RegisterPowerSource(A1: Integer);  { draft }
    procedure UnregisterPowerSource(A1: Integer);  { draft }
    procedure CreateChangeMagicTE;  { draft }
    procedure ExecuteDispelEnchantment(A1: Integer);  { draft }
    procedure DispelEnchantment;  { draft }
    procedure ExecuteChangePowerSettings(A1: Integer);  { draft }
    procedure ChangePowerSettings(A1: Integer);  { draft }
    procedure ExecuteResearchSpell(A1: Integer);  { draft }
    procedure ResearchSpell(A1: Integer);  { draft }
    procedure AIRequestOverrideUpkeep(A1: Integer; A2: Integer);  { draft }
    procedure AIOverrideUpkeep(A1: Integer; A2: Integer);  { draft }
  end;

  { TGlobalEnchantment (instance size 36, VMT 5570B398) }
  TGlobalEnchantment = class(TEObject)
  public
    F_GlobalEnchantment_08: Integer;
    F_GlobalEnchantment_0C: Integer;
    F_GlobalEnchantment_10: Byte;
    F_GlobalEnchantment_11: Byte;
    F_GlobalEnchantment_12: array[0..1] of Byte;
    F_GlobalEnchantment_14: Integer;
    F_GlobalEnchantment_18: Byte;
    F_GlobalEnchantment_19: Byte;
    F_GlobalEnchantment_1A: array[0..1] of Byte;
    F_GlobalEnchantment_1C: Integer;
    F_GlobalEnchantment_20: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure GetName(A1: Integer); virtual;  { +04C draft }
    procedure GetUpkeep; virtual;  { +050 draft }
    procedure GetLocation(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure GetAIUpkeepPriority; virtual;  { +058 draft }
    procedure CanDeactivate(A1: Integer; A2: Integer); virtual;  { +05C draft }
    procedure Deactivate(A1: Byte); virtual;  { +060 draft }
    procedure CanActivate(A1: Integer; A2: Integer); virtual;  { +064 draft }
    procedure Activate(A1: Byte; A2: Integer); virtual;  { +068 draft }
    procedure CanCast; virtual;  { +06C draft }
    procedure Cast(A1: Integer); virtual;  { +070 draft }
    procedure CanDispel; virtual;  { +074 draft }
    procedure Dispel(A1: Byte); virtual;  { +078 draft }
    procedure CanRemove(A1: Byte; A2: Integer); virtual;  { +07C draft }
    procedure Remove(A1: Byte); virtual;  { +080 draft }
    procedure VisibleForPlayer(A1: Integer; A2: Integer); virtual;  { +084 draft }
    procedure CenterToLocation(A1: Integer; A2: Integer); virtual;  { +088 draft }
    procedure Setup(A1: Integer; A2: Integer);  { draft }
  end;

  { TGlobalEnchantmentEventLog (instance size 36, VMT 5570B4B8) }
  TGlobalEnchantmentEventLog = class(TLocationTextEventLog)
  public
    F_GlobalEnchantmentEventLog_20: Byte;
    F_GlobalEnchantmentEventLog_21: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetLeftIcon; override;
  end;

  { TGlobalEnchantmentList (instance size 12, VMT 5570B5C0) }
  TGlobalEnchantmentList = class(TENode)
  public
    procedure GetEnchantments(A1: Integer);  { draft }
  end;

  { TChangeGlobalMagicTE (instance size 28, VMT 5570B724) }
  TChangeGlobalMagicTE = class(TTokenEvent)
  public
    F_ChangeGlobalMagicTE_10: Byte;
    F_ChangeGlobalMagicTE_11: Byte;
    F_ChangeGlobalMagicTE_12: array[0..1] of Byte;
    F_ChangeGlobalMagicTE_14: Integer;
    F_ChangeGlobalMagicTE_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TGlobalMagicControl (instance size 64, VMT 5570B7F8) }
  TGlobalMagicControl = class(TEObject)
  public
    F_GlobalMagicControl_08: Integer;
    F_GlobalMagicControl_0C: Integer;
    F_GlobalMagicControl_10: Byte;
    F_GlobalMagicControl_11: array[0..2] of Byte;
    F_GlobalMagicControl_14: Integer;
    F_GlobalMagicControl_18: Byte;
    F_GlobalMagicControl_19: array[0..34] of Byte;
    F_GlobalMagicControl_3C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure IncDoubleSphereManaCount(A1: Integer);  { draft }
    procedure DecDoubleSphereManaCount(A1: Integer);  { draft }
    procedure GetSphereManaDoubled(A1: Integer);  { draft }
    procedure OutOfMana(A1: Byte; A2: Integer);  { draft }
    procedure RemovePlayerEnchantments(A1: Integer);  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure TriggerChangedEvent;  { draft }
    procedure Update;  { draft }
    procedure GetEnchantmentUpkeep(A1: Integer);  { draft }
    procedure UpdateActiveEnchantments(A1: Integer; A2: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure ValidateEnchantmentID(A1: Integer);  { draft }
    procedure CreateChangeMagicTE;  { draft }
    procedure ExecuteDispelEnchantment(A1: Integer; A2: Integer);  { draft }
    procedure DispelEnchantment(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteRemoveEnchantment(A1: Integer; A2: Integer);  { draft }
    procedure RemoveEnchantment(A1: Integer; A2: Integer);  { draft }
  end;

  { TRace (instance size 24, VMT 5570B8C4) }
  TRace = class(TEObject)
  public
    F_Race_08: Byte;
    F_Race_09: array[0..2] of Byte;
    F_Race_0C: Integer;
    F_Race_10: Integer;
    F_Race_14: Byte;
    F_Race_15: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetRelationValue(A1: Integer);  { draft }
    procedure GetRelation(A1: Integer);  { draft }
    procedure SetPlayerRelationValue(A1: Byte; A2: Integer);  { draft }
    procedure GetPlayerRelationValue(A1: Integer);  { draft }
    procedure GetPlayerRelation(A1: Integer);  { draft }
    procedure NewDay;  { draft }
    procedure GetDefaultRaceRelation(A1: Integer);  { draft }
    procedure ResetDefaultRaceRelations;  { draft }
    procedure ResetPlayerRelations;  { draft }
    procedure SetRace(A1: Byte);  { draft }
    procedure SetEnabled(A1: Integer);  { draft }
  end;

  { TRaceList (instance size 20, VMT 5570B974) }
  TRaceList = class(TEControlStyleNode)
  public
    F_RaceList_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetRace(A1: Integer);  { draft }
    procedure GetEnabledRaces;  { draft }
    procedure GetRandomRace;  { draft }
    procedure ResetPlayerRelations;  { draft }
    procedure ResetDefaultRelations;  { draft }
    procedure Update(A1: Integer; A2: Integer);  { draft }
  end;

  { TDiplomaticRelationList (instance size 20, VMT 5570BA68) }
  TDiplomaticRelationList = class(TByteList)
  public
    procedure Create(A1: Byte);  { draft }
    procedure GetDiplomaticRelation(A1: Integer);  { draft }
    procedure SetDiplomaticRelation;  { draft }
  end;

  { TDiplomaticRelationHistoryItem (instance size 16, VMT 5570BB04) }
  TDiplomaticRelationHistoryItem = class(TEObject)
  public
    F_DiplomaticRelationHistoryItem_08: Integer;
    F_DiplomaticRelationHistoryItem_0C: Byte;
    F_DiplomaticRelationHistoryItem_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TDiplomaticRelationHistoryList (instance size 12, VMT 5570BBE8) }
  TDiplomaticRelationHistoryList = class(TENode)
  public
    class function ClassID: Integer; override;
    procedure GetItems(A1: Integer);  { draft }
    procedure GetLastModifiedOnDay;  { draft }
    procedure GetRelationOnDay(A1: Integer);  { draft }
    procedure Add(A1: Integer; A2: Integer);  { draft }
  end;

  { TPlayerDiplomaticRelations (instance size 20, VMT 5570BD08) }
  TPlayerDiplomaticRelations = class(TEObject)
  public
    F_PlayerDiplomaticRelations_08: Integer;
    F_PlayerDiplomaticRelations_0C: Integer;
    F_PlayerDiplomaticRelations_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetDiplomaticRelation(A1: Byte);  { draft }
    procedure SetDiplomaticRelation(A1: Integer; A2: Integer);  { draft }
    procedure GetHistory(A1: Byte);  { draft }
    procedure ValidateHistory;  { draft }
  end;

  { TLeaderSetupControl (instance size 40, VMT 5570BE8C) }
  TLeaderSetupControl = class(TEObject)
  public
    F_LeaderSetupControl_08: Integer;
    F_LeaderSetupControl_0C: Integer;
    F_LeaderSetupControl_10: Byte;
    F_LeaderSetupControl_11: array[0..2] of Byte;
    F_LeaderSetupControl_14: Integer;
    F_LeaderSetupControl_18: Integer;
    F_LeaderSetupControl_1C: array[0..3] of Byte;
    F_LeaderSetupControl_20: Integer;
    F_LeaderSetupControl_24: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Done; virtual;  { +04C draft }
  end;

  { TTurnInfoItem (instance size 28, VMT 5570BF5C) }
  TTurnInfoItem = class(TEObject)
  public
    F_TurnInfoItem_08: Integer;
    F_TurnInfoItem_0C: Integer;
    F_TurnInfoItem_10: Integer;
    F_TurnInfoItem_14: Integer;
    F_TurnInfoItem_18: Byte;
    F_TurnInfoItem_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetSuperiority;  { draft }
  end;

  { TTurnInfo (instance size 12, VMT 5570C01C) }
  TTurnInfo = class(TENode)
  public
    procedure GetTurnInfo(A1: Integer);  { draft }
  end;

  { TPlayerStatistics (instance size 20, VMT 5570C110) }
  TPlayerStatistics = class(TEObject)
  public
    F_PlayerStatistics_08: Integer;
    F_PlayerStatistics_0C: Integer;
    F_PlayerStatistics_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TIncomeSource (instance size 8, VMT 5570C1D8) }
  TIncomeSource = class(TEObject)
  public
    procedure Name(A1: Integer); virtual;  { +04C draft }
    procedure Income; virtual;  { +050 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +054 draft }
    procedure CenterToLocation(A1: Integer; A2: Integer); virtual;  { +058 draft }
  end;

  { TIncomeSourceList (instance size 12, VMT 5570C2A8) }
  TIncomeSourceList = class(TENode)
  public
    procedure GetItems(A1: Integer);  { draft }
  end;

  { TPBEMPlayerSettings (instance size 16, VMT 5570C400) }
  TPBEMPlayerSettings = class(TEObject)
  public
    F_PBEMPlayerSettings_08: Byte;
    F_PBEMPlayerSettings_09: array[0..2] of Byte;
    F_PBEMPlayerSettings_0C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetGame;  { draft }
  end;

  { TPlayer (instance size 220, VMT 5570C508) }
  TPlayer = class(TEObject)
  public
    F_Player_08: Integer;
    F_Player_0C: Integer;
    F_Player_10: Integer;
    F_Player_14: Integer;
    F_Player_18: Integer;
    F_Player_1C: Integer;
    F_Player_20: Integer;
    F_Player_24: Integer;
    F_Player_28: Integer;
    F_Player_2C: Byte;
    F_Player_2D: Byte;
    F_Player_2E: Byte;
    F_Player_2F: Byte;
    F_Player_30: Integer;
    F_Player_34: Integer;
    F_Player_38: Integer;
    F_Player_3C: Integer;
    F_Player_40: Integer;
    F_Player_44: Byte;
    F_Player_45: Byte;
    F_Player_46: array[0..1] of Byte;
    F_Player_48: Integer;
    F_Player_4C: Integer;
    F_Player_50: Byte;
    F_Player_51: array[0..2] of Byte;
    F_Player_54: Integer;
    F_Player_58: Integer;
    F_Player_5C: Integer;
    F_Player_60: Integer;
    F_Player_64: Integer;
    F_Player_68: Integer;
    F_Player_6C: Integer;
    F_Player_70: Integer;
    F_Player_74: Integer;
    F_Player_78: Integer;
    F_Player_7C: Integer;
    F_Player_80: Integer;
    F_Player_84: Integer;
    F_Player_88: Integer;
    F_Player_8C: Integer;
    F_Player_90: Integer;
    F_Player_94: Integer;
    F_Player_98: Integer;
    F_Player_9C: Integer;
    F_Player_A0: Integer;
    F_Player_A4: Byte;
    F_Player_A5: Byte;
    F_Player_A6: Byte;
    F_Player_A7: Byte;
    F_Player_A8: Byte;
    F_Player_A9: Byte;
    F_Player_AA: array[0..1] of Byte;
    F_Player_AC: Integer;
    F_Player_B0: Integer;
    F_Player_B4: Integer;
    F_Player_B8: Integer;
    F_Player_BC: Integer;
    F_Player_C0: Integer;
    F_Player_C4: Integer;
    F_Player_C8: Integer;
    F_Player_CC: Integer;
    F_Player_D0: Integer;
    F_Player_D4: Integer;
    F_Player_D8: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetBusy;  { draft }
    procedure GetSuperiority;  { draft }
    procedure GetUnitCount;  { draft }
    procedure SetPlayerIndex(A1: Byte);  { draft }
    procedure SetGameOverStatus(A1: Byte);  { draft }
    procedure Surrender;  { draft }
    procedure Win;  { draft }
    procedure Validate(A1: Integer);  { draft }
    procedure LockBusy;  { draft }
    procedure UnlockBusy;  { draft }
    procedure LogbookChangedEvent;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure ArmiesChanged;  { draft }
    procedure SetGems(A1: Integer);  { draft }
    procedure UpdateIncome(A1: Integer; A2: Integer);  { draft }
    procedure RegisterIncomeSource(A1: Integer);  { draft }
    procedure UnregisterIncomeSource(A1: Integer);  { draft }
    procedure GetUpkeep;  { draft }
    procedure SetArmyUpkeep(A1: Integer);  { draft }
    procedure SetMagicUpkeep(A1: Integer);  { draft }
    procedure GetName(A1: Integer);  { draft }
    procedure GetNameEx(A1: Integer);  { draft }
    procedure SetName(A1: Integer; A2: Integer);  { draft }
    procedure GetFace;  { draft }
    procedure GetHeroCountMax;  { draft }
    procedure GetIdealHeroJoinDay;  { draft }
    procedure GetIdealHeroEmergeDay;  { draft }
    procedure ResetBaseHeroJoinDay;  { draft }
    procedure MakeHeroEmerge(A1: Integer);  { draft }
    procedure UpdateHeroJoin;  { draft }
    procedure GetHeroJoinChance(A1: Integer);  { draft }
    procedure GetHeroJoinLevelMax(A1: Integer; A2: Integer);  { draft }
    procedure ValidateLeader;  { draft }
    procedure SetLeader(A1: Integer);  { draft }
    procedure SetRace(A1: Byte);  { draft }
    procedure SetEndTurn(A1: Byte);  { draft }
    procedure UpdateLogbook;  { draft }
    procedure UpdateTurnInfo;  { draft }
    procedure UpdateAlliedPlayersSeen;  { draft }
    procedure SetupAIValidAttackPlayers;  { draft }
    procedure GetFirstDaySeen(A1: Byte);  { draft }
    procedure GetLastDaySeen(A1: Byte);  { draft }
    procedure PlayerSeen(A1: Integer);  { draft }
    procedure GetLeaderLocation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetLocal;  { draft }
    procedure RegisterVictoryLocation;  { draft }
    procedure UnregisterVictoryLocation;  { draft }
    procedure CheckCaptureLocations;  { draft }
    procedure CaptureLocationsLeft;  { draft }
    procedure CreateDiplomaticAction(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure DiplomaticActionAleadySend(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure ListDiplomaticActions(A1: Integer; A2: Integer);  { draft }
    procedure ValidAttackRelation(A1: Integer; A2: Integer);  { draft }
    procedure ChangePlayerSettings(A1: Integer);  { draft }
  end;

  { TPlayerList (instance size 32, VMT 5570C5E8) }
  TPlayerList = class(TEControlStyleNode)
  public
    F_PlayerList_10: Integer;
    F_PlayerList_14: Integer;
    F_PlayerList_18: Integer;
    F_PlayerList_1C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Assign(Source: Engine.TEObject; AEngine: Engine.TEngine); override;
    procedure GetDiplomaticRelationCount(A1: Integer; A2: Byte);  { draft }
    procedure GetDiplomaticRelation(A1: Byte; A2: Integer);  { draft }
    procedure SetDiplomaticRelation(A1: Integer; A2: Byte; A3: Integer);  { draft }
    procedure GetActivePlayers(A1: Integer; A2: Integer);  { draft }
    procedure Update;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure GetPlayers(A1: Integer);  { draft }
    procedure GetActivePlayersAllied;  { draft }
    procedure GetAverageHeroLevel;  { draft }
    procedure GetAverageHeroCount;  { draft }
    procedure GetMaxHeroCount;  { draft }
    procedure GetNumberOfPlayers;  { draft }
    procedure RaceToPlayer(A1: Byte);  { draft }
    procedure SetNumberOfPlayers(A1: Integer);  { draft }
    procedure ValidateRaces(A1: Integer);  { draft }
    procedure VerifyRaces(A1: Integer; A2: Integer);  { draft }
    procedure GetSuperiorPlayer(A1: Integer; A2: Integer);  { draft }
    procedure IndexOfPlayerType(A1: Integer);  { draft }
  end;

  { TAoWNewHSMapSettings (instance size 32, VMT 5570C6E0) }
  TAoWNewHSMapSettings = class(TNewHSMapSettings)
  public
    procedure Create(A1: Byte);  { draft }
  end;

  { TAoWMapField (instance size 28, VMT 5570C764) }
  TAoWMapField = class(TMapField)
  public
    F_AoWMapField_18: Word;
    F_AoWMapField_1A: Byte;
    F_AoWMapField_1B: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure UpdateMapField; override;
    procedure GetExplored(A1: Integer);  { draft }
    procedure SetExplored(A1: Integer; A2: Integer);  { draft }
    procedure FogChanged;  { draft }
    procedure SetFogCount(A1: Byte);  { draft }
    procedure GetPlayer;  { draft }
    procedure GetScannerIcon;  { draft }
    procedure GetCombatTerrainTag;  { draft }
    procedure GetConcealmentActive;  { draft }
    procedure GetMagicShieldActive;  { draft }
    procedure GetProductionControl;  { draft }
    procedure GetAITarget(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetMoveAction(A1: Byte);  { draft }
    procedure GetIndependentRelation;  { draft }
    procedure GetDefensePriority;  { draft }
    procedure GetDefenseRequirements(A1: Integer; A2: Integer);  { draft }
    procedure GetWallType;  { draft }
    procedure GetArmyHS;  { draft }
    procedure RestoreTerrain;  { draft }
  end;

  { TAoWMapLevel (instance size 128, VMT 5570C864) }
  TAoWMapLevel = class(TMapLevel)
  public
    F_AoWMapLevel_7C: array[0..3] of Byte;
    class function ClassID: Integer; override;
    function MapFieldClass: Engine.TEObjectClass; override;
    procedure FogArea(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure UnFogArea(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure UnFogExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ResetFog;  { draft }
    procedure ResetUnFog;  { draft }
    procedure Reset;  { draft }
  end;

  { TSubMove (instance size 20, VMT 5570CA40) }
  TSubMove = class(TEObject)
  public
    F_SubMove_08: Integer;
    F_SubMove_0C: Integer;
    F_SubMove_10: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AddMovePointLine;  { draft }
  end;

  { TSubMoveList (instance size 12, VMT 5570CAF8) }
  TSubMoveList = class(TENode)
  public
    procedure GetSubMove(A1: Integer);  { draft }
    procedure DeleteXYL(A1: Integer);  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure IndexOfXYL(A1: Integer);  { draft }
  end;

  { TMoveControlSettings (instance size 428, VMT 5570CC54) }
  TMoveControlSettings = class(TEObject)
  public
    F_MoveControlSettings_08: Integer;
    F_MoveControlSettings_0C: Integer;
    F_MoveControlSettings_10: Integer;
    F_MoveControlSettings_14: array[0..3] of Byte;
    F_MoveControlSettings_18: Integer;
    F_MoveControlSettings_1C: Integer;
    F_MoveControlSettings_20: Integer;
    F_MoveControlSettings_24: Byte;
    F_MoveControlSettings_25: array[0..30] of Byte;
    F_MoveControlSettings_44: Byte;
    F_MoveControlSettings_45: array[0..30] of Byte;
    F_MoveControlSettings_64: Byte;
    F_MoveControlSettings_65: Byte;
    F_MoveControlSettings_66: Byte;
    F_MoveControlSettings_67: array[0..0] of Byte;
    F_MoveControlSettings_68: Integer;
    F_MoveControlSettings_6C: Byte;
    F_MoveControlSettings_6D: array[0..2] of Byte;
    F_MoveControlSettings_70: Integer;
    F_MoveControlSettings_74: Integer;
    F_MoveControlSettings_78: Integer;
    F_MoveControlSettings_7C: Integer;
    F_MoveControlSettings_80: Integer;
    F_MoveControlSettings_84: Integer;
    F_MoveControlSettings_88: Integer;
    F_MoveControlSettings_8C: Integer;
    F_MoveControlSettings_90: Integer;
    F_MoveControlSettings_94: array[0..3] of Byte;
    F_MoveControlSettings_98: Integer;
    F_MoveControlSettings_9C: Integer;
    F_MoveControlSettings_A0: Integer;
    F_MoveControlSettings_A4: array[0..3] of Byte;
    F_MoveControlSettings_A8: Integer;
    F_MoveControlSettings_AC: Byte;
    F_MoveControlSettings_AD: array[0..254] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure ResetState;  { draft }
    procedure Reset;  { draft }
    procedure SetSourcePos(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetDestinationPos(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetupArmy(A1: Integer; A2: Integer);  { draft }
    procedure SetupLevel(A1: Integer);  { draft }
    procedure SetupMovePointData(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ClearMovePoints;  { draft }
    procedure GetMovePoints(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetMovePoints(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure GetMovePointLevelData(A1: Integer);  { draft }
    procedure GetMovePointsXYL(A1: Integer; A2: Integer);  { draft }
    procedure SetMovePointsXYL(A1: Integer; A2: Integer);  { draft }
  end;

  { TMoveControl (instance size 480, VMT 5570CDA8) }
  TMoveControl = class(TObject)
  public
    F_MoveControl_04: Integer;
    F_MoveControl_08: Byte;
    F_MoveControl_09: Byte;
    F_MoveControl_0A: Byte;
    F_MoveControl_0B: array[0..0] of Byte;
    F_MoveControl_0C: Integer;
    F_MoveControl_10: Integer;
    F_MoveControl_14: Integer;
    F_MoveControl_18: Integer;
    F_MoveControl_1C: Integer;
    F_MoveControl_20: Integer;
    F_MoveControl_24: Integer;
    F_MoveControl_28: Integer;
    F_MoveControl_2C: Integer;
    F_MoveControl_30: Byte;
    F_MoveControl_31: Byte;
    F_MoveControl_32: array[0..253] of Byte;
    F_MoveControl_130: Integer;
    F_MoveControl_134: Integer;
    F_MoveControl_138: Integer;
    F_MoveControl_13C: Integer;
    F_MoveControl_140: Byte;
    F_MoveControl_141: array[0..2] of Byte;
    F_MoveControl_144: Integer;
    F_MoveControl_148: Byte;
    F_MoveControl_149: array[0..2] of Byte;
    F_MoveControl_14C: Byte;
    F_MoveControl_14D: array[0..58] of Byte;
    F_MoveControl_188: Byte;
    F_MoveControl_189: array[0..62] of Byte;
    F_MoveControl_1C8: Integer;
    F_MoveControl_1CC: Integer;
    F_MoveControl_1D0: Integer;
    F_MoveControl_1D4: array[0..3] of Byte;
    F_MoveControl_1D8: Integer;
    F_MoveControl_1DC: Integer;
    destructor Destroy; override;
    procedure SetupMove; virtual;  { +000 draft }
    procedure ProcessMove(A1: Integer); virtual;  { +004 draft }
    constructor Create;  { draft }
    procedure Clear;  { draft }
    procedure SetMapL(A1: Integer);  { draft }
    procedure DefaultMoveOnMovePointProc(A1: Integer; A2: Integer);  { draft }
    procedure FindSubMoveOrigin(A1: Integer);  { draft }
    procedure CalculateMovePointLine(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ProcessHexagon(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ValidLocation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ExecuteExternalMove(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetupSubMove(A1: Integer; A2: Integer);  { draft }
    procedure ProcessSubMove(A1: Integer);  { draft }
    procedure Process;  { draft }
    procedure CalculatePathEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure CalculatePath(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ExploredOnlyMoveOnMovePointProc(A1: Integer; A2: Integer);  { draft }
    procedure Activate(A1: Integer);  { draft }
    procedure Deactivate;  { draft }
    procedure CanMove(A1: Integer; A2: Integer);  { draft }
    procedure ValidPath(A1: Integer; A2: Integer);  { draft }
    procedure CalculateGaps(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CalculateTurnAroundMovePoints(A1: Integer);  { draft }
    procedure GetMovePointsCostFast(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TAoWTokenManager (instance size 28, VMT 5570CE24) }
  TAoWTokenManager = class(TTokenManager)
  public
  end;

  { TPlayerConnectionEventLog (instance size 44, VMT 5570CF20) }
  TPlayerConnectionEventLog = class(TMessageEventLog)
  public
    F_PlayerConnectionEventLog_28: Byte;
    F_PlayerConnectionEventLog_29: Byte;
    F_PlayerConnectionEventLog_2A: array[0..1] of Byte;
    procedure Yes; override;
    procedure No; override;
    procedure Setup(A1: Byte; A2: Byte);  { draft }
    procedure ExitSaveGameCallBack(A1: Integer);  { draft }
  end;

  { TPlayerControl (instance size 32, VMT 5570D074) }
  TPlayerControl = class(TEObject)
  public
    F_PlayerControl_08: Integer;
    F_PlayerControl_0C: Integer;
    F_PlayerControl_10: Byte;
    F_PlayerControl_11: array[0..2] of Byte;
    F_PlayerControl_14: Integer;
    F_PlayerControl_18: Integer;
    F_PlayerControl_1C: Byte;
    F_PlayerControl_1D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewFrame; virtual;  { +04C draft }
    procedure NewDay; virtual;  { +050 draft }
    procedure NewTurn(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure AutoSave; virtual;  { +058 draft }
    procedure ValidateTurnTiming; virtual;  { +05C draft }
    procedure Setup; virtual;  { +060 draft }
    procedure StartNewMap; virtual;  { +064 draft }
    procedure StartLoadedMap; virtual;  { +068 draft }
    procedure PasswordFailed; virtual;  { +06C draft }
    procedure PasswordValidated; virtual;  { +070 draft }
    procedure SetPlayerGameOverStatus(A1: Integer; A2: Integer); virtual;  { +074 draft }
    procedure GameOver(A1: Integer; A2: Integer); virtual;  { +078 draft }
    procedure GameOverEventHandled(A1: Integer); virtual;  { +07C draft }
    procedure ExitGame(A1: Byte); virtual;  { +080 draft }
    procedure EndTurn(A1: Integer; A2: Integer); virtual;  { +084 draft }
    procedure SetSeatedPlayer(A1: Integer); virtual;  { +088 draft }
    procedure ValidateDisconnectedPlayers; virtual;  { +08C draft }
    procedure ConnectionLost; virtual;  { +090 draft }
    procedure LockAI; virtual;  { +094 draft }
    procedure GetSyncValue(A1: Integer);  { draft }
    procedure OutOfSync;  { draft }
    procedure ListPlayerInfo(A1: Integer);  { draft }
    procedure ExitSaveGameCallBack(A1: Integer);  { draft }
    procedure SaveGameOnExitCallBack(A1: Integer);  { draft }
    procedure ExitNetworkGameCallBack(A1: Integer);  { draft }
    procedure PasswordTryAgainCallBack(A1: Integer);  { draft }
    procedure ValidatePasswordCallBack(A1: Integer);  { draft }
    procedure ValidatePassword(A1: Integer);  { draft }
    procedure PlayerDisconnected(A1: Integer);  { draft }
  end;

  { TTextControlItem (instance size 20, VMT 5570D198) }
  TTextControlItem = class(TEObject)
  public
    F_TextControlItem_08: Integer;
    F_TextControlItem_0C: Integer;
    F_TextControlItem_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TTextControl (instance size 12, VMT 5570D270) }
  TTextControl = class(TENode)
  public
    procedure GetItem(A1: Integer);  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure New;  { draft }
    procedure FindID(A1: Integer);  { draft }
    procedure Sort;  { draft }
    procedure IndexOf;  { draft }
    procedure RetrieveText(A1: Integer; A2: Integer);  { draft }
  end;

  { TNewTurnEventLog (instance size 36, VMT 5570D448) }
  TNewTurnEventLog = class(TEventLog)
  public
    F_NewTurnEventLog_18: array[0..11] of Byte;
  end;

  { TTurnPlayerControl (instance size 32, VMT 5570D54C) }
  TTurnPlayerControl = class(TPlayerControl)
  public
    class function ClassID: Integer; override;
    procedure NewDay; override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure ValidateTurnTiming; override;
    procedure Setup; override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure SetPlayerGameOverStatus(A1: Integer; A2: Integer); override;
    procedure GameOver(A1: Integer; A2: Integer); override;
    procedure GameOverEventHandled(A1: Integer); override;
    procedure EndTurn(A1: Integer; A2: Integer); override;
    procedure SetSeatedPlayer(A1: Integer); override;
    procedure StartLoadedMapEx; virtual;  { +098 draft }
    procedure ReplayLogbook;  { draft }
    procedure ShowNewTurnCallBack;  { draft }
    procedure StartGameCallBack;  { draft }
    procedure DefaultStartMap;  { draft }
  end;

  { TSendEmailGameEventLog (instance size 28, VMT 5570D6AC) }
  TSendEmailGameEventLog = class(TEventLog)
  public
    F_SendEmailGameEventLog_18: array[0..3] of Byte;
  end;

  { TPBEMPlayerControl (instance size 36, VMT 5570D7AC) }
  TPBEMPlayerControl = class(TTurnPlayerControl)
  public
    F_PBEMPlayerControl_20: Byte;
    F_PBEMPlayerControl_21: array[0..2] of Byte;
    class function ClassID: Integer; override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure ExitGame(A1: Byte); override;
    procedure EndTurn(A1: Integer; A2: Integer); override;
    procedure TerminateEmailGame;  { draft }
    procedure TerminateEmailGameCallBack;  { draft }
    procedure SendEmailGameAutomatedCallBack(A1: Integer);  { draft }
    procedure SendEmailGameManualCallBack(A1: Integer);  { draft }
    procedure SendEmailGameCallBack(A1: Integer);  { draft }
    procedure TriggerGameRestartedEvents(A1: Integer);  { draft }
    procedure EndTurnGameSavedCallBack(A1: Integer);  { draft }
    procedure StartLoadedEmailGame;  { draft }
    procedure ContinueRestartedGameCallBack(A1: Integer);  { draft }
    procedure ContinueTurnDoneGameCallBack(A1: Integer);  { draft }
    procedure ValidateLoadedMap;  { draft }
    procedure ExitGameSaveAsCallBack(A1: Integer);  { draft }
  end;

  { TSimultaniousPlayerControl (instance size 32, VMT 5570D8C8) }
  TSimultaniousPlayerControl = class(TPlayerControl)
  public
    class function ClassID: Integer; override;
    procedure NewDay; override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure ValidateTurnTiming; override;
    procedure Setup; override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure SetPlayerGameOverStatus(A1: Integer; A2: Integer); override;
    procedure GameOverEventHandled(A1: Integer); override;
    procedure EndTurn(A1: Integer; A2: Integer); override;
    procedure StartGameCallBack;  { draft }
    procedure StartLoadedMapEx;  { draft }
  end;

  { TMovepath (instance size 20, VMT 5570D9F0) }
  TMovepath = class(TXYLList)
  public
    procedure MovePointsToPos(A1: Integer);  { draft }
    procedure PosToMovePoints(A1: Integer);  { draft }
    procedure GetMovePoints;  { draft }
  end;

  { TMoveSettings (instance size 44, VMT 5570DA70) }
  TMoveSettings = class(TEObject)
  public
    F_MoveSettings_08: Integer;
    F_MoveSettings_0C: array[0..15] of Byte;
    F_MoveSettings_1C: Integer;
    F_MoveSettings_20: array[0..3] of Byte;
    F_MoveSettings_24: Integer;
    F_MoveSettings_28: Byte;
    F_MoveSettings_29: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetMoveLoc(A1: Integer; A2: Integer);  { draft }
    procedure GetMovePrio;  { draft }
  end;

  { TMoveSettingsList (instance size 12, VMT 5570DB30) }
  TMoveSettingsList = class(TENode)
  public
    procedure GetMoveSettings(A1: Integer);  { draft }
    procedure GetNoneValidMove;  { draft }
    procedure IndexOfMoveObject(A1: Integer);  { draft }
    procedure CalculateMovePositions(A1: Integer; A2: Integer);  { draft }
  end;

  { TMoveSelector (instance size 24, VMT 5570DC88) }
  TMoveSelector = class(TObject)
  public
    F_MoveSelector_04: Integer;
    F_MoveSelector_08: Integer;
    F_MoveSelector_0C: Integer;
    F_MoveSelector_10: Integer;
    F_MoveSelector_14: Byte;
    F_MoveSelector_15: array[0..2] of Byte;
    destructor Destroy; override;
    procedure MouseMoveEvent; virtual;  { +000 draft }
    procedure MouseDownEvent(A1: Integer); virtual;  { +004 draft }
    procedure CalculateMovePath(A1: Integer; A2: Byte; A3: Integer; A4: Integer); virtual;  { +008 draft }
    procedure UpdateMoveCursor; virtual;  { +00C draft }
    function CreateMCS: Integer; virtual;  { +010 draft }
    procedure SetCurrentMove(A1: Integer); virtual;  { +014 draft }
    procedure SelectPath(A1: Byte; A2: Integer; A3: Integer); virtual;  { +018 draft }
    procedure Unselect(A1: Integer; A2: Integer); virtual;  { +01C draft }
    procedure ValidateSelection(A1: Integer); virtual;  { +020 draft }
    procedure ExecuteMove; virtual;  { +024 draft }
    procedure Activate(A1: Integer); virtual;  { +028 draft }
    procedure Deactivate; virtual;  { +02C draft }
    procedure ShowMovePaths(A1: Integer); virtual;  { +030 draft }
    constructor Create;  { draft }
    procedure Clear;  { draft }
    procedure AddMoveObject(A1: Integer);  { draft }
    procedure DeleteMoveObject(A1: Integer);  { draft }
    procedure DeleteMoves;  { draft }
  end;

  { TSelectedArmy (instance size 40, VMT 5570DD70) }
  TSelectedArmy = class(TMoveSelector)
  public
    F_SelectedArmy_18: Byte;
    F_SelectedArmy_19: array[0..2] of Byte;
    F_SelectedArmy_1C: Integer;
    F_SelectedArmy_20: Integer;
    F_SelectedArmy_24: Byte;
    F_SelectedArmy_25: array[0..2] of Byte;
    destructor Destroy; override;
    procedure MouseDownEvent(A1: Integer); override;
    procedure CalculateMovePath(A1: Integer; A2: Byte; A3: Integer; A4: Integer); override;
    procedure UpdateMoveCursor; override;
    procedure SetCurrentMove(A1: Integer); override;
    procedure SelectPath(A1: Byte; A2: Integer; A3: Integer); override;
    procedure Unselect(A1: Integer; A2: Integer); override;
    procedure ValidateSelection(A1: Integer); override;
    procedure ExecuteMove; override;
    procedure Deactivate; override;
    procedure ShowMovePaths(A1: Integer); override;
    procedure Create(A1: Byte);  { draft }
    procedure AddMoveArmy(A1: Integer; A2: Integer);  { draft }
    procedure GetArmyHS;  { draft }
    procedure GetSelection;  { draft }
    procedure SetSelection(A1: Integer);  { draft }
    procedure GetMoveTypes;  { draft }
    procedure ResetSelectedUnitGFX;  { draft }
    procedure UpdateSelectedUnitGFX(A1: Integer; A2: Integer);  { draft }
    procedure OnDestroyArmy(A1: Integer);  { draft }
    procedure RectangleSelectEvent(A1: Integer);  { draft }
    procedure ValidMultiMoveSelection(A1: Integer);  { draft }
    procedure ActivateMoveSelection;  { draft }
    procedure DeactivateMoveSelection;  { draft }
    procedure Update;  { draft }
    procedure OutputGroupInfo;  { draft }
    procedure SetArmyHS(A1: Integer);  { draft }
    procedure Select(A1: Integer);  { draft }
    procedure SelectBuildRoad(A1: Integer);  { draft }
    procedure Center;  { draft }
    procedure TurnDone;  { draft }
    procedure ToggleGuard;  { draft }
  end;

  { TTargetSelectionControl (instance size 92, VMT 5570E03C) }
  TTargetSelectionControl = class(TObject)
  public
    F_TargetSelectionControl_04: Integer;
    F_TargetSelectionControl_08: Integer;
    F_TargetSelectionControl_0C: Byte;
    F_TargetSelectionControl_0D: Byte;
    F_TargetSelectionControl_0E: array[0..1] of Byte;
    F_TargetSelectionControl_10: Integer;
    F_TargetSelectionControl_14: Integer;
    F_TargetSelectionControl_18: Integer;
    F_TargetSelectionControl_1C: Integer;
    F_TargetSelectionControl_20: Integer;
    F_TargetSelectionControl_24: Integer;
    F_TargetSelectionControl_28: Integer;
    F_TargetSelectionControl_2C: Integer;
    F_TargetSelectionControl_30: Integer;
    F_TargetSelectionControl_34: Integer;
    F_TargetSelectionControl_38: Byte;
    F_TargetSelectionControl_39: Byte;
    F_TargetSelectionControl_3A: Byte;
    F_TargetSelectionControl_3B: Byte;
    F_TargetSelectionControl_3C: Integer;
    F_TargetSelectionControl_40: Byte;
    F_TargetSelectionControl_41: array[0..2] of Byte;
    F_TargetSelectionControl_44: Byte;
    F_TargetSelectionControl_45: array[0..2] of Byte;
    F_TargetSelectionControl_48: Integer;
    F_TargetSelectionControl_4C: array[0..3] of Byte;
    F_TargetSelectionControl_50: Integer;
    F_TargetSelectionControl_54: Integer;
    F_TargetSelectionControl_58: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure TriggerOnChangeEvent(A1: Byte);  { draft }
    procedure DeselectHS;  { draft }
    procedure MouseDownEvent;  { draft }
    procedure ValidTarget(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure NewFrameEvent;  { draft }
    procedure MouseMoveEvent;  { draft }
    procedure ShowSelection(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure Initialize(A1: Integer);  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
    procedure UnitChanged(A1: Integer);  { draft }
  end;

  { TAoWHSMapKeyboard (instance size 20, VMT 5570E11C) }
  TAoWHSMapKeyboard = class(TEObject)
  public
    F_AoWHSMapKeyboard_08: Integer;
    F_AoWHSMapKeyboard_0C: Byte;
    F_AoWHSMapKeyboard_0D: array[0..2] of Byte;
    F_AoWHSMapKeyboard_10: Integer;
    procedure KeyDown(A1: Integer; A2: Byte); virtual;  { +04C draft }
    procedure Lock;  { draft }
    procedure Unlock;  { draft }
    procedure RunDefaultTest;  { draft }
  end;

  { TAbstractAoWHSMapMouse (instance size 80, VMT 5570E22C) }
  TAbstractAoWHSMapMouse = class(THSMapMouse)
  public
    F_AbstractAoWHSMapMouse_3C: Integer;
    F_AbstractAoWHSMapMouse_40: Integer;
    F_AbstractAoWHSMapMouse_44: Integer;
    F_AbstractAoWHSMapMouse_48: Integer;
    F_AbstractAoWHSMapMouse_4C: Integer;
    destructor Destroy; override;
    procedure Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Move(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Create(A1: Byte);  { draft }
    procedure ResetRectangleSelection;  { draft }
    procedure GetSelectingRectangle;  { draft }
    procedure StartRectangleSelection(A1: Integer; A2: Integer);  { draft }
    procedure UpdateRectangleSelection(A1: Integer; A2: Integer);  { draft }
    procedure StopRectangleSelection(A1: Integer; A2: Integer);  { draft }
  end;

  { TAoWHSMapMouse (instance size 80, VMT 5570E2DC) }
  TAoWHSMapMouse = class(TAbstractAoWHSMapMouse)
  public
    function GetCursor: Integer; override;
    procedure Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Move(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
  end;

  { TAbstractAoWHSMap (instance size 216, VMT 5570E37C) }
  TAbstractAoWHSMap = class(THSMap)
  public
    F_AbstractAoWHSMap_A4: Integer;
    F_AbstractAoWHSMap_A8: Integer;
    F_AbstractAoWHSMap_AC: Integer;
    F_AbstractAoWHSMap_B0: Byte;
    F_AbstractAoWHSMap_B1: array[0..2] of Byte;
    F_AbstractAoWHSMap_B4: Integer;
    F_AbstractAoWHSMap_B8: Integer;
    F_AbstractAoWHSMap_BC: Integer;
    F_AbstractAoWHSMap_C0: Integer;
    F_AbstractAoWHSMap_C4: Integer;
    F_AbstractAoWHSMap_C8: Byte;
    F_AbstractAoWHSMap_C9: Byte;
    F_AbstractAoWHSMap_CA: Byte;
    F_AbstractAoWHSMap_CB: array[0..0] of Byte;
    F_AbstractAoWHSMap_CC: Integer;
    F_AbstractAoWHSMap_D0: Integer;
    F_AbstractAoWHSMap_D4: Byte;
    F_AbstractAoWHSMap_D5: Byte;
    F_AbstractAoWHSMap_D6: Byte;
    F_AbstractAoWHSMap_D7: array[0..0] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateMouse: HSEngine.THSMapMouse; override;
    procedure TriggerTerrainChangedEvent(const R: Windows.TRect; L: Shortint); override;
    procedure UpdateStaticScene; override;
    procedure UpdateDynamicScene; override;
    procedure NewFrame; override;
    procedure ShowBackHexagonSelector(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0EC draft }
    procedure ShowFrontHexagonSelector(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0F0 draft }
    procedure UpdateHexagonSelector; virtual;  { +0F4 draft }
    procedure SetSeatedPlayer(A1: Byte); virtual;  { +0F8 draft }
    procedure SetCurrentPlayer(A1: Byte); virtual;  { +0FC draft }
    procedure SetFogEnabled(A1: Byte); virtual;  { +100 draft }
    procedure SetExplorationEnabled(A1: Byte); virtual;  { +104 draft }
    procedure DropHeroItem(A1: Integer; A2: Integer); virtual;  { +108 draft }
    function GetHeroItemsOnGround(A1: Integer; A2: Integer): Integer; virtual;  { +10C draft }
    procedure ShowMessage(A1: Integer); virtual;  { +110 draft }
    procedure ShowWarning(A1: Integer); virtual;  { +114 draft }
    procedure PlayCenterAnimation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure LockMapChangedEvent;  { draft }
    procedure UnlockMapChangedEvent;  { draft }
    procedure MapChanged(A1: Integer);  { draft }
    procedure MapChangedRad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure InvalidateMap;  { draft }
    procedure TriggerMapChangedEvent(A1: Integer; A2: Integer);  { draft }
    procedure LockScannerIconsChangedEvent;  { draft }
    procedure UnlockScannerIconsChangedEvent;  { draft }
    procedure ScannerIconsChanged(A1: Integer; A2: Integer);  { draft }
    procedure ScannerIconsChangedRad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure InvalidateScannerIcons;  { draft }
    procedure TriggerScannerIconsChangedEvent(A1: Integer; A2: Integer);  { draft }
    procedure UpdateShowMessage;  { draft }
    procedure FogArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure UnFogArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure UnFogExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DrawGrid(A1: Integer);  { draft }
    procedure DrawFog(A1: Integer);  { draft }
    procedure ShowHexagonSelector;  { draft }
    procedure HideHexagonSelector;  { draft }
    procedure UpdateFPS(A1: Integer);  { draft }
    procedure DrawSelectionRect(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TAbstractAoWCombatMap (instance size 224, VMT 5570E548) }
  TAbstractAoWCombatMap = class(TAbstractAoWHSMap)
  public
    F_AbstractAoWCombatMap_D8: Integer;
    F_AbstractAoWCombatMap_DC: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TTutorialControl (instance size 12, VMT 5570E6E4) }
  TTutorialControl = class(TEObject)
  public
    F_TutorialControl_08: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ShowMessage(A1: Integer; A2: Byte; A3: Integer);  { draft }
  end;

  { TStartupSongList (instance size 16, VMT 5570E7AC) }
  TStartupSongList = class(TSonglist)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure OriginalSongsChanged;  { draft }
  end;

  { TAoWHSMap (instance size 1052, VMT 5570E874) }
  TAoWHSMap = class(TAbstractAoWHSMap)
  public
    F_AoWHSMap_D8: Integer;
    F_AoWHSMap_DC: Byte;
    F_AoWHSMap_DD: array[0..2] of Byte;
    F_AoWHSMap_E0: Integer;
    F_AoWHSMap_E4: Integer;
    F_AoWHSMap_E8: Integer;
    F_AoWHSMap_EC: Integer;
    F_AoWHSMap_F0: Integer;
    F_AoWHSMap_F4: Integer;
    F_AoWHSMap_F8: Integer;
    F_AoWHSMap_FC: Integer;
    F_AoWHSMap_100: Integer;
    F_AoWHSMap_104: Byte;
    F_AoWHSMap_105: array[0..2] of Byte;
    F_AoWHSMap_108: Integer;
    F_AoWHSMap_10C: Byte;
    F_AoWHSMap_10D: array[0..2] of Byte;
    F_AoWHSMap_110: Integer;
    F_AoWHSMap_114: Integer;
    F_AoWHSMap_118: Byte;
    F_AoWHSMap_119: Byte;
    F_AoWHSMap_11A: Byte;
    F_AoWHSMap_11B: array[0..0] of Byte;
    F_AoWHSMap_11C: Integer;
    F_AoWHSMap_120: Integer;
    F_AoWHSMap_124: Integer;
    F_AoWHSMap_128: Integer;
    F_AoWHSMap_12C: Integer;
    F_AoWHSMap_130: Integer;
    F_AoWHSMap_134: Integer;
    F_AoWHSMap_138: Byte;
    F_AoWHSMap_139: Byte;
    F_AoWHSMap_13A: Byte;
    F_AoWHSMap_13B: array[0..0] of Byte;
    F_AoWHSMap_13C: Integer;
    F_AoWHSMap_140: Integer;
    F_AoWHSMap_144: Integer;
    F_AoWHSMap_148: Byte;
    F_AoWHSMap_149: Byte;
    F_AoWHSMap_14A: Byte;
    F_AoWHSMap_14B: Byte;
    F_AoWHSMap_14C: Byte;
    F_AoWHSMap_14D: Byte;
    F_AoWHSMap_14E: array[0..1] of Byte;
    F_AoWHSMap_150: Integer;
    F_AoWHSMap_154: Integer;
    F_AoWHSMap_158: Integer;
    F_AoWHSMap_15C: Integer;
    F_AoWHSMap_160: Integer;
    F_AoWHSMap_164: Integer;
    F_AoWHSMap_168: Integer;
    F_AoWHSMap_16C: Byte;
    F_AoWHSMap_16D: array[0..2] of Byte;
    F_AoWHSMap_170: Integer;
    F_AoWHSMap_174: Integer;
    F_AoWHSMap_178: Integer;
    F_AoWHSMap_17C: Integer;
    F_AoWHSMap_180: Byte;
    F_AoWHSMap_181: array[0..2] of Byte;
    F_AoWHSMap_184: Integer;
    F_AoWHSMap_188: Integer;
    F_AoWHSMap_18C: Integer;
    F_AoWHSMap_190: array[0..0] of Byte;
    F_AoWHSMap_191: Byte;
    F_AoWHSMap_192: array[0..1] of Byte;
    F_AoWHSMap_194: Integer;
    F_AoWHSMap_198: Integer;
    F_AoWHSMap_19C: Integer;
    F_AoWHSMap_1A0: Integer;
    F_AoWHSMap_1A4: Integer;
    F_AoWHSMap_1A8: Integer;
    F_AoWHSMap_1AC: Integer;
    F_AoWHSMap_1B0: Integer;
    F_AoWHSMap_1B4: Integer;
    F_AoWHSMap_1B8: Integer;
    F_AoWHSMap_1BC: Integer;
    F_AoWHSMap_1C0: Byte;
    F_AoWHSMap_1C1: array[0..2] of Byte;
    F_AoWHSMap_1C4: Integer;
    F_AoWHSMap_1C8: Integer;
    F_AoWHSMap_1CC: Integer;
    F_AoWHSMap_1D0: Integer;
    F_AoWHSMap_1D4: Integer;
    F_AoWHSMap_1D8: Integer;
    F_AoWHSMap_1DC: Integer;
    F_AoWHSMap_1E0: Integer;
    F_AoWHSMap_1E4: Integer;
    F_AoWHSMap_1E8: Integer;
    F_AoWHSMap_1EC: Integer;
    F_AoWHSMap_1F0: Integer;
    F_AoWHSMap_1F4: Integer;
    F_AoWHSMap_1F8: Byte;
    F_AoWHSMap_1F9: array[0..2] of Byte;
    F_AoWHSMap_1FC: Integer;
    F_AoWHSMap_200: Integer;
    F_AoWHSMap_204: Integer;
    F_AoWHSMap_208: Integer;
    F_AoWHSMap_20C: Integer;
    F_AoWHSMap_210: Integer;
    F_AoWHSMap_214: Integer;
    F_AoWHSMap_218: Integer;
    F_AoWHSMap_21C: Integer;
    F_AoWHSMap_220: Integer;
    F_AoWHSMap_224: Integer;
    F_AoWHSMap_228: Integer;
    F_AoWHSMap_22C: Integer;
    F_AoWHSMap_230: Integer;
    F_AoWHSMap_234: Integer;
    F_AoWHSMap_238: Byte;
    F_AoWHSMap_239: Byte;
    F_AoWHSMap_23A: array[0..1] of Byte;
    F_AoWHSMap_23C: Integer;
    F_AoWHSMap_240: Integer;
    F_AoWHSMap_244: Integer;
    F_AoWHSMap_248: Byte;
    F_AoWHSMap_249: Byte;
    F_AoWHSMap_24A: array[0..1] of Byte;
    F_AoWHSMap_24C: Byte;
    F_AoWHSMap_24D: array[0..458] of Byte;
    F_AoWHSMap_418: Byte;
    F_AoWHSMap_419: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure SendMsg(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function CreateMouse: HSEngine.THSMapMouse; override;
    procedure NotifyProgress(const Progress: HSEngine.TMapProgress); override;
    procedure InitializeNewMap; override;
    function AddMapLevel: Boolean; override;
    procedure Activate; override;
    function CreateNewMap(Settings: HSEngine.TNewHSMapSettings): Boolean; override;
    function ChangeTerrain(MO: HSEngine.TMapObject; X, Y, L, Radius, TerrainType: Integer): Integer; override;
    function ChangeTerrainEx(MO: HSEngine.TMapObject; X, Y, L, Radius: Integer; ChangeTerrainProc: HSEngine.TChangeTerrainProc; TerrainChangedProc: HSEngine.TTerrainChangedProc): Integer; override;
    procedure DrawDynamicScene(var SD: GFXE.TSurfaceDesc); override;
    procedure NewFrame; override;
    procedure SetSeatedPlayer(A1: Byte); override;
    procedure TriggerCombatEvent; virtual;  { +118 draft }
    procedure TriggerGameTerminatedEvent; virtual;  { +11C draft }
    procedure TriggerPlayerTerminatedEvent; virtual;  { +120 draft }
    procedure StartNewMap; virtual;  { +124 draft }
    procedure StartLoadedMap; virtual;  { +128 draft }
    procedure TriggerExecuteEventLog(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +12C draft }
    procedure StartTokenEventLogging;  { draft }
    procedure StopTokenEventLogging;  { draft }
    procedure SynchroniseBegin;  { draft }
    procedure SynchroniseEnd;  { draft }
    procedure GetSynchronised;  { draft }
    procedure OnExecuteTokenEvent(A1: Integer);  { draft }
    procedure PlayerDisconnected;  { draft }
    procedure PlayerConnectionLost;  { draft }
    procedure OnTokenManagerMessage(A1: Integer; A2: Integer);  { draft }
    procedure GetIndependentAIMode;  { draft }
    procedure SaveGame(A1: Integer);  { draft }
    procedure TerrainVisible(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure Visible(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure WatchingTerrain(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure Watching(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure ValidateTerrainObservation(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ValidateObservation(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure UnlockGameOverEventCallBack;  { draft }
    procedure SelectNextHero;  { draft }
    procedure SelectNextArmy;  { draft }
    procedure SelectPrevArmy;  { draft }
    procedure SeatedPlayerChanged;  { draft }
    procedure BeginUnitUpdate;  { draft }
    procedure EndUnitUpdate;  { draft }
    procedure UnitChanged;  { draft }
    procedure UnitDestroyed;  { draft }
    procedure BeginArmyUpdate;  { draft }
    procedure EndArmyUpdate;  { draft }
    procedure ArmyChanged;  { draft }
    procedure ArmyDestroyed;  { draft }
    procedure BeginStructureUpdate;  { draft }
    procedure EndStructureUpdate;  { draft }
    procedure StructureChanged;  { draft }
    procedure StructureDestroyed;  { draft }
    procedure ExecuteExitGame;  { draft }
    procedure ExitGame(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure TriggerEndTurnEvent(A1: Byte);  { draft }
    procedure ClearExecuteEventLogBuffer;  { draft }
    procedure ExecuteNextEventLog;  { draft }
    procedure SetExecuteEventLogDelay(A1: Integer);  { draft }
    procedure UpdateExecuteEventLogDelay;  { draft }
    procedure ExecuteEventLogDone(A1: Integer);  { draft }
    procedure LockExecuteEventLog;  { draft }
    procedure UnlockExecuteEventLog;  { draft }
    procedure GameOverEventHandled;  { draft }
    procedure ExecuteGameOverEvent(A1: Integer);  { draft }
    procedure UnlockGameOverEvent;  { draft }
    procedure LockGameOverEvent;  { draft }
    procedure GameOver(A1: Byte; A2: Integer);  { draft }
    procedure VerifyAddOnPacks;  { draft }
    procedure ValidateMap(A1: Integer);  { draft }
    procedure OnStreamError(A1: Integer; A2: Integer);  { draft }
    procedure InitializeMapLevel(A1: Byte);  { draft }
    procedure NotifyPlayerChangedEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure UpdatePlayerSeen(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure NotifyPlayerChanged(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure VisibleForPlayer(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure FoggedForPlayer(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure MouseMoved;  { draft }
    procedure UpdateCursor;  { draft }
    procedure ResetSeatedPlayerView(A1: Integer; A2: Integer);  { draft }
    procedure Select(A1: Integer; A2: Integer);  { draft }
    procedure PlayerChanged;  { draft }
    procedure TokenControlActivatedEvent;  { draft }
    procedure SetupPlayerControl(A1: Integer; A2: Integer);  { draft }
    procedure ActivateMsg;  { draft }
    procedure Random(A1: Integer);  { draft }
    procedure GenerateNewTurnOrder;  { draft }
    procedure EndTurn;  { draft }
    procedure CancelEndTurn;  { draft }
    procedure LockUpdateVisibility;  { draft }
    procedure UnLockUpdateVisibility;  { draft }
    procedure UpdateVisibility;  { draft }
    procedure ResetMapLevels;  { draft }
    procedure ExecuteNegotiateMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure InitializeCombatMap(A1: Integer; A2: Integer);  { draft }
    procedure ReleaseCombatMap;  { draft }
    procedure CreateCombat(A1: Integer);  { draft }
    procedure ShowSeatedPlayerCallBack;  { draft }
    procedure DestroyCombat;  { draft }
    procedure RetrieveBattleFieldInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure TriggerRelationsChanged;  { draft }
    procedure LockRelationsChanged;  { draft }
    procedure UnlockRelationsChanged;  { draft }
    procedure UpdateTurnTimeBeep;  { draft }
    procedure ResetTurnTimer;  { draft }
    procedure GetTurnTimeLeft;  { draft }
    procedure GetTurnTimerEnabled;  { draft }
    procedure EnableTurnTimer;  { draft }
    procedure DisableTurnTimer;  { draft }
    procedure ZeroTurnTimer;  { draft }
    procedure CenterOnLeader(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PlaceTerrain(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure UpdateEffects;  { draft }
    procedure AddEffect(A1: Integer);  { draft }
  end;

  { TUnitGFXResource (instance size 72, VMT 5570EA70) }
  TUnitGFXResource = class(TEResource)
  public
    F_UnitGFXResource_18: Integer;
    F_UnitGFXResource_1C: Integer;
    F_UnitGFXResource_20: Integer;
    F_UnitGFXResource_24: Integer;
    F_UnitGFXResource_28: Integer;
    F_UnitGFXResource_2C: Integer;
    F_UnitGFXResource_30: Byte;
    F_UnitGFXResource_31: array[0..2] of Byte;
    F_UnitGFXResource_34: Integer;
    F_UnitGFXResource_38: Integer;
    F_UnitGFXResource_3C: Integer;
    F_UnitGFXResource_40: Integer;
    F_UnitGFXResource_44: Integer;
    destructor Destroy; override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    procedure LinkToIL;  { draft }
    procedure ReleaseIL;  { draft }
    procedure SetFaceImageLibraryName(A1: Integer; A2: Integer);  { draft }
    procedure GetFaceImage;  { draft }
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure GetIndex;  { draft }
  end;

  { TUnitGFXResourceList (instance size 20, VMT 5570EB68) }
  TUnitGFXResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetUnitGFXResource(A1: Integer);  { draft }
    procedure CreateUnitGFXSelectionList(A1: Integer; A2: Integer);  { draft }
  end;

  { TAoWMapObjectEditor (instance size 8, VMT 5570EC78) }
  TAoWMapObjectEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
  end;

  { TUnitShadowHS (instance size 12, VMT 5570ED54) }
  TUnitShadowHS = class(THexagonSprite)
  public
    F_UnitShadowHS_08: Byte;
    F_UnitShadowHS_09: array[0..2] of Byte;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TUnitHS (instance size 28, VMT 5570EED0) }
  TUnitHS = class(THexagonSprite)
  public
    F_UnitHS_08: Byte;
    F_UnitHS_09: array[0..2] of Byte;
    F_UnitHS_0C: Integer;
    F_UnitHS_10: Integer;
    F_UnitHS_14: Byte;
    F_UnitHS_15: Byte;
    F_UnitHS_16: Byte;
    F_UnitHS_17: array[0..0] of Byte;
    F_UnitHS_18: Integer;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure TimerEvent(Tick: Integer; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetSelected: Boolean; override;
    function GetXhx: Shortint; override;
    function GetYhx: Shortint; override;
    function GetLhx: Shortint; override;
    function GetEditMode: Boolean; override;
    procedure SetEditMode(Value: Boolean); override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    function Place(Map: HSEngine.TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
    procedure Remove; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure Select; override;
    procedure Unselect; override;
    procedure CalcShowPriority; virtual;  { +108 draft }
    procedure MoveTo(A1: Integer; A2: Integer); virtual;  { +10C draft }
    procedure PlaceHX(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +110 draft }
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer); virtual;  { +114 draft }
    procedure UpdateFlagID; virtual;  { +118 draft }
    procedure MoveFirst(A1: Integer; A2: Integer); virtual;  { +11C draft }
    function GetMoveSteps: Integer; virtual;  { +120 draft }
    procedure CreateShadow;  { draft }
    procedure DestroyShadow;  { draft }
    procedure GetUnitGFXResourceIndex;  { draft }
    procedure SetUnitGFXResourceIndex(A1: Integer);  { draft }
    procedure SetDirection(A1: Integer);  { draft }
    procedure GetMoveStatus;  { draft }
    procedure SetMoveStatus(A1: Integer);  { draft }
    procedure MoveNext;  { draft }
    procedure Moving;  { draft }
    procedure PauseMove;  { draft }
    procedure CancelMove;  { draft }
  end;

  { TAbilityData (instance size 12, VMT 5570F05C) }
  TAbilityData = class(TEObject)
  public
    F_AbilityData_08: array[0..3] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure GetAbilityID; virtual;  { +04C draft }
  end;

  { TActivateAbilityInfo (instance size 28, VMT 5570F120) }
  TActivateAbilityInfo = class(TEObject)
  public
    F_ActivateAbilityInfo_08: Integer;
    F_ActivateAbilityInfo_0C: Integer;
    F_ActivateAbilityInfo_10: Integer;
    F_ActivateAbilityInfo_14: array[0..7] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
  end;

  { TAbility (instance size 36, VMT 5570F254) }
  TAbility = class(TEObject)
  public
    F_Ability_08: Integer;
    F_Ability_0C: Integer;
    F_Ability_10: Integer;
    F_Ability_14: Integer;
    F_Ability_18: Integer;
    F_Ability_1C: Integer;
    F_Ability_20: Word;
    F_Ability_22: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Execute; virtual;  { +04C draft }
    procedure GetHidden; virtual;  { +050 draft }
    procedure GetAbilityType; virtual;  { +054 draft }
    procedure GetName(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure GetAttack; virtual;  { +05C draft }
    procedure GetDefense; virtual;  { +060 draft }
    procedure GetResistance; virtual;  { +064 draft }
    procedure GetDamage; virtual;  { +068 draft }
    procedure GetMoveTypes; virtual;  { +06C draft }
    procedure GetLevel(A1: Integer); virtual;  { +070 draft }
    procedure GetEnabled(A1: Integer); virtual;  { +074 draft }
    procedure GetImmunityTypes; virtual;  { +078 draft }
    procedure GetProtectionTypes; virtual;  { +07C draft }
    procedure GetSkillPoints(A1: Integer); virtual;  { +080 draft }
    procedure GetCombatMode(A1: Integer); virtual;  { +084 draft }
    procedure GetWallCombatFeatures(A1: Integer); virtual;  { +088 draft }
    procedure GetSourceName(A1: Integer; A2: Integer); virtual;  { +08C draft }
    procedure GetInherent(A1: Integer); virtual;  { +090 draft }
    procedure GetInherentLevel(A1: Integer); virtual;  { +094 draft }
    procedure GetControlType; virtual;  { +098 draft }
    procedure fcValidRoundDistance(A1: Integer; A2: Integer); virtual;  { +09C draft }
    procedure fcPrefetchCombatCommands(A1: Integer); virtual;  { +0A0 draft }
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); virtual;  { +0A4 draft }
    procedure NewDay(A1: Integer); virtual;  { +0A8 draft }
    procedure NewTurn(A1: Integer; A2: Integer); virtual;  { +0AC draft }
    procedure CanActivate(A1: Integer; A2: Integer); virtual;  { +0B0 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +0B4 draft }
    procedure CanActivateCombat(A1: Integer; A2: Integer); virtual;  { +0B8 draft }
    procedure ActivateCombat(A1: Integer; A2: Integer); virtual;  { +0BC draft }
    procedure ListSpells; virtual;  { +0C0 draft }
    procedure CanExpand(A1: Integer); virtual;  { +0C4 draft }
    procedure ExpandCost; virtual;  { +0C8 draft }
    procedure ExpandName(A1: Integer; A2: Integer); virtual;  { +0CC draft }
    procedure Expand(A1: Integer; A2: Integer); virtual;  { +0D0 draft }
    procedure Remove(A1: Integer; A2: Integer); virtual;  { +0D4 draft }
    procedure GetDamageValue(A1: Integer; A2: Integer); virtual;  { +0D8 draft }
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0DC draft }
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0E0 draft }
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0E4 draft }
    procedure fcGetDamageValue(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0E8 draft }
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0EC draft }
    procedure tcGetDamageValue(A1: Integer); virtual;  { +0F0 draft }
    procedure CombatObjectDestroyed(A1: Integer); virtual;  { +0F4 draft }
    procedure NewCombatTurn(A1: Integer; A2: Integer); virtual;  { +0F8 draft }
    procedure CombatDone(A1: Integer); virtual;  { +0FC draft }
    procedure ListInfo(A1: Integer; A2: Byte); virtual;  { +100 draft }
    procedure GetCombatInfo(A1: Integer; A2: Integer); virtual;  { +104 draft }
    procedure AbilityDataClass; virtual;  { +108 draft }
    procedure ShowInfo(A1: Integer; A2: Integer);  { draft }
    procedure SetAb(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TCustomAbilityList (instance size 16, VMT 5570F3DC) }
  TCustomAbilityList = class(TEObject)
  public
    F_CustomAbilityList_08: Byte;
    F_CustomAbilityList_09: array[0..2] of Byte;
    F_CustomAbilityList_0C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
    procedure GetAbSet(A1: Integer); virtual;  { +04C draft }
    procedure SetAbSet(A1: Integer; A2: Byte); virtual;  { +050 draft }
    procedure GetAbCount; virtual;  { +054 draft }
    procedure ListAbilitiesEx(A1: Integer; A2: Word); virtual;  { +058 draft }
    procedure SetAbCount(A1: Integer);  { draft }
    procedure AssignAb(A1: Integer; A2: Integer);  { draft }
    procedure CompareAb(A1: Integer);  { draft }
    procedure ComposeAb(A1: Integer);  { draft }
    procedure GetItemString(A1: Integer);  { draft }
    procedure SetItemString(A1: Integer);  { draft }
  end;

  { TAbilityList (instance size 16, VMT 5570F4B8) }
  TAbilityList = class(TCustomAbilityList)
  public
  end;

  { TAbilityOwner (instance size 20, VMT 5570F588) }
  TAbilityOwner = class(TCustomAbilityList)
  public
    F_AbilityOwner_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure SetAbSet(A1: Integer; A2: Byte); override;
    procedure ListAbilitiesEx(A1: Integer; A2: Word); override;
    procedure Execute; virtual;  { +05C draft }
    procedure GetOwnerName(A1: Integer); virtual;  { +060 draft }
    procedure GetAbName(A1: Integer; A2: Integer); virtual;  { +064 draft }
    procedure GetAbAttack(A1: Integer); virtual;  { +068 draft }
    procedure GetAbDefense(A1: Integer); virtual;  { +06C draft }
    procedure GetAbResistance(A1: Integer); virtual;  { +070 draft }
    procedure GetAbDamage(A1: Integer); virtual;  { +074 draft }
    procedure GetAbMoveTypes(A1: Integer); virtual;  { +078 draft }
    procedure GetAbProtectionTypes(A1: Integer); virtual;  { +07C draft }
    procedure GetAbImmunityTypes(A1: Integer); virtual;  { +080 draft }
    procedure GetAbLevel(A1: Integer); virtual;  { +084 draft }
    procedure GetAbEnabled(A1: Integer); virtual;  { +088 draft }
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); virtual;  { +08C draft }
    procedure Changed; virtual;  { +090 draft }
    procedure ExpandAbility(A1: Integer); virtual;  { +094 draft }
    procedure RemoveAbility(A1: Integer); virtual;  { +098 draft }
    procedure ValidateOwnerTypeAbilities;  { draft }
    procedure GetAbilityData(A1: Integer);  { draft }
    procedure AssignAb(A1: Integer);  { draft }
    procedure AddAbilityData(A1: Integer);  { draft }
    procedure RemoveAbilityData(A1: Integer);  { draft }
    procedure RemoveAbilityDataID(A1: Integer);  { draft }
    procedure UpdateDefaultAbilities(A1: Integer);  { draft }
    procedure GetAbAttackAll;  { draft }
    procedure GetAbDefenseAll;  { draft }
    procedure GetAbResistanceAll;  { draft }
    procedure GetAbDamageAll;  { draft }
    procedure GetAbMoveTypesAll;  { draft }
    procedure GetAbWallCombatFeatures;  { draft }
    procedure GetAbProtectionTypesAll;  { draft }
    procedure GetAbImmunityTypesAll;  { draft }
    procedure TriggerNewDay;  { draft }
    procedure TriggerNewTurn(A1: Byte; A2: Integer);  { draft }
    procedure TriggerNewCombatTurn(A1: Integer; A2: Byte);  { draft }
    procedure TriggerCombatDone(A1: Integer);  { draft }
    procedure ListAbilities(A1: Integer);  { draft }
  end;

  { TAbilityTypeList (instance size 16, VMT 5570F698) }
  TAbilityTypeList = class(TList)
  public
    procedure GetAbility(A1: Integer);  { draft }
  end;

  { TAbilityControl (instance size 32, VMT 5570F71C) }
  TAbilityControl = class(TEObject)
  public
    F_AbilityControl_08: Integer;
    F_AbilityControl_0C: Byte;
    F_AbilityControl_0D: array[0..18] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    procedure GetAbility(A1: Integer);  { draft }
    procedure RegisterAbility(A1: Integer);  { draft }
    procedure UnregisterAbility(A1: Integer);  { draft }
    procedure UnregisterAll;  { draft }
    procedure UnregisterAbilityID(A1: Integer);  { draft }
    procedure ListAbilities(A1: Integer; A2: Word);  { draft }
    procedure ListAbilityInfo(A1: Integer; A2: Byte; A3: Integer);  { draft }
  end;

  { TItemGFX (instance size 48, VMT 5570F7E0) }
  TItemGFX = class(TEResource)
  public
    F_ItemGFX_18: Integer;
    F_ItemGFX_1C: Integer;
    F_ItemGFX_20: Byte;
    F_ItemGFX_21: array[0..2] of Byte;
    F_ItemGFX_24: Integer;
    F_ItemGFX_28: Integer;
    F_ItemGFX_2C: Byte;
    F_ItemGFX_2D: array[0..2] of Byte;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    procedure ItemGFXIndex;  { draft }
    procedure LinkToIL;  { draft }
    procedure ReleaseIL;  { draft }
    procedure SetImageLibraryName(A1: Integer; A2: Integer);  { draft }
    procedure GetItemImage;  { draft }
  end;

  { TItemGFXList (instance size 20, VMT 5570F8C0) }
  TItemGFXList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetItemGFX(A1: Integer);  { draft }
    procedure FindItemTypeGFX(A1: Byte);  { draft }
  end;

  { TItemTE (instance size 28, VMT 5570F9F0) }
  TItemTE = class(TTokenEvent)
  public
    F_ItemTE_10: Integer;
    F_ItemTE_14: Byte;
    F_ItemTE_15: array[0..2] of Byte;
    F_ItemTE_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TItem (instance size 76, VMT 5570FAFC) }
  TItem = class(TAbilityOwner)
  public
    F_Item_14: Integer;
    F_Item_18: Integer;
    F_Item_1C: Byte;
    F_Item_1D: array[0..2] of Byte;
    F_Item_20: Integer;
    F_Item_24: Integer;
    F_Item_28: Integer;
    F_Item_2C: Integer;
    F_Item_30: Integer;
    F_Item_34: Byte;
    F_Item_35: array[0..2] of Byte;
    F_Item_38: Integer;
    F_Item_3C: Integer;
    F_Item_40: Integer;
    F_Item_44: Byte;
    F_Item_45: Byte;
    F_Item_46: Byte;
    F_Item_47: Byte;
    F_Item_48: Byte;
    F_Item_49: Byte;
    F_Item_4A: array[0..1] of Byte;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure SetArrayOwner(AOwner: Engine.TECustomNode; Index: Integer); override;
    procedure GetOwnerName(A1: Integer); override;
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); override;
    procedure Changed; override;
    procedure CanUse(A1: Integer; A2: Integer); virtual;  { +09C draft }
    procedure Use(A1: Integer); virtual;  { +0A0 draft }
    procedure ExecuteUse(A1: Integer); virtual;  { +0A4 draft }
    procedure Show(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0A8 draft }
    procedure Activate; virtual;  { +0AC draft }
    procedure Deactivate; virtual;  { +0B0 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetCampaignTransferPoints;  { draft }
    procedure GetImage;  { draft }
    procedure GetLibraryItem;  { draft }
    procedure GetLibraryName(A1: Integer);  { draft }
    procedure UpdateFromLibrary;  { draft }
    procedure SetItemGFXIndex(A1: Integer);  { draft }
    procedure SetItemType(A1: Integer);  { draft }
    procedure GetObtainValue;  { draft }
    procedure PlaceOnMap(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure EditDropMsg(A1: Integer);  { draft }
  end;

  { TItemList (instance size 24, VMT 5570FC34) }
  TItemList = class(TEChangeNotifyNode)
  public
    F_ItemList_10: Byte;
    F_ItemList_11: array[0..0] of Byte;
    F_ItemList_12: Word;
    F_ItemList_14: Integer;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure Changed; override;
    procedure GetItem(A1: Integer); virtual;  { +08C draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +090 draft }
    procedure FindItem(A1: Integer; A2: Integer);  { draft }
    procedure Update;  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnType;  { draft }
    procedure RegisterItems;  { draft }
    procedure LockChanged;  { draft }
    procedure UnlockChanged;  { draft }
  end;

  { TItemLibrary (instance size 32, VMT 5570FD34) }
  TItemLibrary = class(TItemList)
  public
    F_ItemLibrary_18: Integer;
    F_ItemLibrary_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure GetName(A1: Integer); virtual;  { +094 draft }
    procedure CreateUniqueLibraryID;  { draft }
    procedure FindLibraryID(A1: Integer);  { draft }
    procedure CreateItem;  { draft }
    procedure LoadFromFile;  { draft }
    procedure SaveToFile;  { draft }
  end;

  { TItemLibraryManager (instance size 16, VMT 5570FE50) }
  TItemLibraryManager = class(TEObject)
  public
    F_ItemLibraryManager_08: Integer;
    F_ItemLibraryManager_0C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLibrary(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure ReadUserLibraries;  { draft }
    procedure WriteUserLibraries;  { draft }
    procedure IndexOfLibraryName(A1: Integer);  { draft }
    procedure IndexOfLibrary;  { draft }
    procedure FindItem(A1: Integer; A2: Integer);  { draft }
    procedure CreateLibrary(A1: Integer);  { draft }
    procedure DeleteLibrary(A1: Integer);  { draft }
  end;

  { TItemControl (instance size 32, VMT 5570FF60) }
  TItemControl = class(TEObject)
  public
    F_ItemControl_08: Integer;
    F_ItemControl_0C: Integer;
    F_ItemControl_10: Integer;
    F_ItemControl_14: Integer;
    F_ItemControl_18: Integer;
    F_ItemControl_1C: Byte;
    F_ItemControl_1D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetItem(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure FindItem(A1: Integer);  { draft }
    procedure ItemChanged;  { draft }
    procedure Changed;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure CreateUniqueID;  { draft }
    procedure ValidateItem(A1: Integer);  { draft }
    procedure UpdateLibraryItems;  { draft }
    procedure RegisterItem(A1: Integer);  { draft }
    procedure UnRegisterItem(A1: Integer);  { draft }
    procedure GenerateItem(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure GenerateItems(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
  end;

  { TItemHSList (instance size 24, VMT 55710020) }
  TItemHSList = class(TItemList)
  public
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TItemHS (instance size 20, VMT 55710178) }
  TItemHS = class(TSingleHS)
  public
    F_ItemHS_0C: Integer;
    F_ItemHS_10: Byte;
    F_ItemHS_11: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function EditName: string; override;
    function CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure ItemsChanged;  { draft }
    procedure GenerateItems;  { draft }
  end;

  { TFaceResource (instance size 44, VMT 557102F0) }
  TFaceResource = class(TEResource)
  public
    F_FaceResource_18: Integer;
    F_FaceResource_1C: Integer;
    F_FaceResource_20: Integer;
    F_FaceResource_24: Integer;
    F_FaceResource_28: Byte;
    F_FaceResource_29: array[0..2] of Byte;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    procedure FaceResourceIndex;  { draft }
    procedure LinkToIL;  { draft }
    procedure ReleaseIL;  { draft }
    procedure SetImageLibraryName(A1: Integer; A2: Integer);  { draft }
    procedure GetFaceImage;  { draft }
  end;

  { TFaceResourceList (instance size 20, VMT 557103D8) }
  TFaceResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure IndexOfFaceImage(A1: Integer);  { draft }
    procedure GetFaceResource(A1: Integer);  { draft }
    procedure PrevFace(A1: Integer);  { draft }
    procedure NextFace(A1: Integer);  { draft }
  end;

  { TUnitControl (instance size 20, VMT 557105E8) }
  TUnitControl = class(TEObject)
  public
    F_UnitControl_08: Integer;
    F_UnitControl_0C: Integer;
    F_UnitControl_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    procedure TriggerUnitsChanged;  { draft }
    procedure GetUnit(A1: Integer);  { draft }
    procedure FindUnit(A1: Integer);  { draft }
    procedure GetFreeID;  { draft }
    procedure RegisterUnit(A1: Integer);  { draft }
    procedure UnRegisterUnit(A1: Integer);  { draft }
  end;

  { TAbstractUnit (instance size 60, VMT 55710740) }
  TAbstractUnit = class(TAbilityOwner)
  public
    F_AbstractUnit_14: Integer;
    F_AbstractUnit_18: Integer;
    F_AbstractUnit_1C: Integer;
    F_AbstractUnit_20: Integer;
    F_AbstractUnit_24: Byte;
    F_AbstractUnit_25: Byte;
    F_AbstractUnit_26: Byte;
    F_AbstractUnit_27: array[0..0] of Byte;
    F_AbstractUnit_28: Byte;
    F_AbstractUnit_29: array[0..8] of Byte;
    F_AbstractUnit_32: Byte;
    F_AbstractUnit_33: array[0..0] of Byte;
    F_AbstractUnit_34: Integer;
    F_AbstractUnit_38: Byte;
    F_AbstractUnit_39: array[0..2] of Byte;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetOwnerName(A1: Integer); override;
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); override;
    procedure Changed; override;
    procedure RemoveAbility(A1: Integer); override;
    procedure GetUpkeep; virtual;  { +09C draft }
    procedure GetUnitLevel; virtual;  { +0A0 draft }
    procedure GetRace; virtual;  { +0A4 draft }
    procedure GetInherentAttack; virtual;  { +0A8 draft }
    procedure GetInherentDefense; virtual;  { +0AC draft }
    procedure GetInherentDamage; virtual;  { +0B0 draft }
    procedure GetInherentResistance; virtual;  { +0B4 draft }
    procedure GetInherentAbility(A1: Integer); virtual;  { +0B8 draft }
    procedure GetInherentAbilityLevel(A1: Integer); virtual;  { +0BC draft }
    procedure GetAttack(A1: Integer; A2: Integer); virtual;  { +0C0 draft }
    procedure GetDefense(A1: Integer; A2: Integer); virtual;  { +0C4 draft }
    procedure GetDamage(A1: Integer; A2: Integer); virtual;  { +0C8 draft }
    procedure GetResistance(A1: Integer; A2: Integer); virtual;  { +0CC draft }
    procedure GetHits; virtual;  { +0D0 draft }
    procedure GetMoves; virtual;  { +0D4 draft }
    procedure GetMovePoints; virtual;  { +0D8 draft }
    procedure SetMovePoints(A1: Integer); virtual;  { +0DC draft }
    procedure GetHitPoints; virtual;  { +0E0 draft }
    procedure SetHitPoints(A1: Integer); virtual;  { +0E4 draft }
    procedure GetMoveTypes; virtual;  { +0E8 draft }
    procedure GetImmunityTypes; virtual;  { +0EC draft }
    procedure GetProtectionTypes; virtual;  { +0F0 draft }
    procedure GetFace; virtual;  { +0F4 draft }
    procedure GetName(A1: Integer); virtual;  { +0F8 draft }
    procedure GetAlignment; virtual;  { +0FC draft }
    procedure GetPreviewImage; virtual;  { +100 draft }
    procedure GetTransportCapacity; virtual;  { +104 draft }
    procedure GetTransporter; virtual;  { +108 draft }
    procedure GetGender; virtual;  { +10C draft }
    procedure GetBloodType; virtual;  { +110 draft }
    procedure GetUnitType; virtual;  { +114 draft }
    procedure GetUnitGFXResourceIndex; virtual;  { +118 draft }
    procedure CanAddToList; virtual;  { +11C draft }
    procedure GetWallCombatFeatures; virtual;  { +120 draft }
    procedure GetCampaignTransferPoints; virtual;  { +124 draft }
    procedure GetCastingPointsMax; virtual;  { +128 draft }
    procedure GetCastingPoints; virtual;  { +12C draft }
    procedure SetCastingPoints(A1: Integer); virtual;  { +130 draft }
    procedure GetPowerGeneration; virtual;  { +134 draft }
    procedure NewDay(A1: Integer; A2: Integer); virtual;  { +138 draft }
    procedure NewTurn(A1: Integer; A2: Integer); virtual;  { +13C draft }
    procedure NewTurnDone(A1: Byte); virtual;  { +140 draft }
    procedure GetAbilityLevel(A1: Integer); virtual;  { +144 draft }
    procedure GetAbilityEnabled(A1: Integer); virtual;  { +148 draft }
    procedure GetAbilitySet(A1: Integer); virtual;  { +14C draft }
    procedure GetAbilityName(A1: Integer; A2: Integer); virtual;  { +150 draft }
    procedure GetAbilityOwner(A1: Integer); virtual;  { +154 draft }
    procedure GetAbilityCount; virtual;  { +158 draft }
    procedure GetExperience; virtual;  { +15C draft }
    procedure SetExperience(A1: Integer; A2: Integer); virtual;  { +160 draft }
    procedure GetNextLevelExperience; virtual;  { +164 draft }
    procedure GetDescription; virtual;  { +168 draft }
    procedure SetPlayer(A1: Integer); virtual;  { +16C draft }
    procedure GetIndependentRelation; virtual;  { +170 draft }
    procedure GetObtainValue; virtual;  { +174 draft }
    procedure GetUnitSize; virtual;  { +178 draft }
    procedure GetUnitMoraleValue(A1: Integer; A2: Byte); virtual;  { +17C draft }
    procedure CanActivate; virtual;  { +180 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +184 draft }
    procedure Deactivate; virtual;  { +188 draft }
    procedure MovedTo(A1: Integer; A2: Integer; A3: Integer); virtual;  { +18C draft }
    procedure CanDisband; virtual;  { +190 draft }
    procedure CanJoin(A1: Byte; A2: Integer); virtual;  { +194 draft }
    procedure JoinAmount(A1: Integer; A2: Integer); virtual;  { +198 draft }
    procedure OfferToJoin(A1: Integer); virtual;  { +19C draft }
    procedure GetJoinMessage(A1: Integer; A2: Integer); virtual;  { +1A0 draft }
    procedure ShowEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +1A4 draft }
    procedure UnitKilled; virtual;  { +1A8 draft }
    procedure Killed; virtual;  { +1AC draft }
    procedure Resurrect; virtual;  { +1B0 draft }
    procedure Animate; virtual;  { +1B4 draft }
    procedure RetrieveDamageInfo(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetRelationValue(A1: Byte; A2: Integer);  { draft }
    procedure GetRelation(A1: Integer; A2: Integer);  { draft }
    procedure UnitRelation(A1: Integer; A2: Integer);  { draft }
    procedure UpdateMoraleValue;  { draft }
    procedure GetMorale;  { draft }
    procedure UpdateEnchanted;  { draft }
    procedure RemoveEnchantments;  { draft }
    procedure RemoveHandicaps;  { draft }
    procedure RegisterEnchantments;  { draft }
    procedure UnregisterEnchantments;  { draft }
    procedure AbilityToEnchantment;  { draft }
    procedure CanDispelEnchantment(A1: Integer);  { draft }
    procedure ListEnchantments(A1: Integer; A2: Integer);  { draft }
    procedure UpdateDefensiveStrength;  { draft }
    procedure UpdateOffensiveStrength;  { draft }
    procedure GetStrength(A1: Integer);  { draft }
    procedure GetStrengthMax(A1: Word; A2: Integer);  { draft }
    procedure GetCombatValue(A1: Integer; A2: Byte);  { draft }
    procedure ListAbilityInfo(A1: Integer; A2: Integer);  { draft }
    procedure GetManaUpkeep;  { draft }
    procedure GetTransporting(A1: Integer; A2: Integer);  { draft }
    procedure CreateMovePointTable(A1: Integer);  { draft }
    procedure ValidTerrain(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteTrailOfDarkness(A1: Integer);  { draft }
    procedure PathOfLifeTerrainChange(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PathOfDecayTerrainChange(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PathOfFrostTerrainChange(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PathOfFrostTerrainChanged(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure UpdatePathOfFrost(A1: Integer; A2: Integer);  { draft }
    procedure ConcealedOnMapF(A1: Integer);  { draft }
    procedure ExecuteStormDamage(A1: Byte);  { draft }
    procedure MovePointCost(A1: Integer; A2: Byte);  { draft }
    procedure ResetEarthMasteryStoneSkin;  { draft }
    procedure SetEarthMasteryStoneSkin;  { draft }
    procedure ResetFireMasteryProtection;  { draft }
    procedure SetFireMasteryProtection;  { draft }
    procedure ResetLifeMasteryBlessing;  { draft }
    procedure SetLifeMasteryBlessing;  { draft }
    procedure ResetLifeMasteryFear;  { draft }
    procedure ExecuteLifeMasteryFearRole;  { draft }
    procedure ValidateLifeMastery;  { draft }
    procedure ExecuteDeathMasteryCurseRole;  { draft }
    procedure ValidateDeathMastery;  { draft }
    procedure VisibilityRange(A1: Integer; A2: Integer);  { draft }
    procedure TrueVisionRange;  { draft }
    procedure CanPlace(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure Place(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ValidateCrusader;  { draft }
    procedure Show(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ShowFace(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteDamageRole(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ExecuteResistanceRole(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteDamageEffectsRole(A1: Word);  { draft }
    procedure ExecuteDamageEffects(A1: Word; A2: Integer);  { draft }
    procedure ExecuteCombatDamageEffects(A1: Integer; A2: Integer);  { draft }
    procedure OptimalDamageType(A1: Word; A2: Integer);  { draft }
    procedure Disband;  { draft }
  end;

  { TAbstractUnitResource (instance size 28, VMT 5571096C) }
  TAbstractUnitResource = class(TEResource)
  public
    F_AbstractUnitResource_18: Integer;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    class function ResourceEditName: string; override;
    procedure DropUnit(A1: Integer; A2: Integer; A3: Integer); virtual;  { +064 draft }
    procedure GetPreviewImage; virtual;  { +068 draft }
    procedure GetFace; virtual;  { +06C draft }
    procedure GetObtainValue; virtual;  { +070 draft }
    procedure SetUnitGFXResourceIndex(A1: Integer);  { draft }
    procedure EditDropMsg(A1: Integer);  { draft }
  end;

  { TUnitResource (instance size 84, VMT 55710A64) }
  TUnitResource = class(TAbstractUnitResource)
  public
    F_UnitResource_1C: Integer;
    F_UnitResource_20: Byte;
    F_UnitResource_21: Byte;
    F_UnitResource_22: array[0..1] of Byte;
    F_UnitResource_24: Integer;
    F_UnitResource_28: Byte;
    F_UnitResource_29: Byte;
    F_UnitResource_2A: Byte;
    F_UnitResource_2B: Byte;
    F_UnitResource_2C: Byte;
    F_UnitResource_2D: Byte;
    F_UnitResource_2E: Byte;
    F_UnitResource_2F: Byte;
    F_UnitResource_30: Byte;
    F_UnitResource_31: Byte;
    F_UnitResource_32: array[0..5] of Byte;
    F_UnitResource_38: Integer;
    F_UnitResource_3C: Integer;
    F_UnitResource_40: Integer;
    F_UnitResource_44: Byte;
    F_UnitResource_45: array[0..2] of Byte;
    F_UnitResource_48: Integer;
    F_UnitResource_4C: Integer;
    F_UnitResource_50: Byte;
    F_UnitResource_51: Byte;
    F_UnitResource_52: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function ResourceUserClassID: Integer; override;
    function CreateResourceUser: Engine.TEObject; override;
    procedure DropUnit(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetObtainValue; override;
    procedure GetMoveTypes;  { draft }
    procedure GetTransportCapacity;  { draft }
    procedure GetUpkeep;  { draft }
    procedure SetDescription;  { draft }
    procedure UnitResourceIndex;  { draft }
    procedure GetUnitName(A1: Integer);  { draft }
  end;

  { TUnitResourceList (instance size 20, VMT 55710B64) }
  TUnitResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetUnitResource(A1: Integer);  { draft }
  end;

  { TUnit (instance size 72, VMT 55710CAC) }
  TUnit = class(TAbstractUnit)
  public
    F_Unit_3C: Byte;
    F_Unit_3D: Byte;
    F_Unit_3E: Byte;
    F_Unit_3F: array[0..0] of Byte;
    F_Unit_40: Integer;
    F_Unit_44: Byte;
    F_Unit_45: Byte;
    F_Unit_46: Byte;
    F_Unit_47: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Changed; override;
    procedure GetUnitLevel; override;
    procedure GetRace; override;
    procedure GetInherentAttack; override;
    procedure GetInherentDefense; override;
    procedure GetInherentDamage; override;
    procedure GetInherentResistance; override;
    procedure GetAttack(A1: Integer; A2: Integer); override;
    procedure GetDefense(A1: Integer; A2: Integer); override;
    procedure GetDamage(A1: Integer; A2: Integer); override;
    procedure GetResistance(A1: Integer; A2: Integer); override;
    procedure GetHits; override;
    procedure GetMoves; override;
    procedure GetMovePoints; override;
    procedure SetMovePoints(A1: Integer); override;
    procedure GetHitPoints; override;
    procedure SetHitPoints(A1: Integer); override;
    procedure GetFace; override;
    procedure GetName(A1: Integer); override;
    procedure GetAlignment; override;
    procedure GetPreviewImage; override;
    procedure GetTransportCapacity; override;
    procedure GetTransporter; override;
    procedure GetGender; override;
    procedure GetBloodType; override;
    procedure GetUnitType; override;
    procedure GetUnitGFXResourceIndex; override;
    procedure NewDay(A1: Integer; A2: Integer); override;
    procedure GetExperience; override;
    procedure SetExperience(A1: Integer; A2: Integer); override;
    procedure GetNextLevelExperience; override;
    procedure GetDescription; override;
    procedure GetObtainValue; override;
    procedure GetUnitSize; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure ShowEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure UnitKilled; override;
    procedure Killed; override;
    procedure GetRank;  { draft }
    procedure SetRank(A1: Integer);  { draft }
    procedure SetUnitResource(A1: Integer; A2: Integer);  { draft }
  end;

  { TUnitList (instance size 16, VMT 55710EC8) }
  TUnitList = class(TEChangeNotifyNode)
  public
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure GetPlayer; virtual;  { +08C draft }
    procedure GetStrength(A1: Integer); virtual;  { +090 draft }
    procedure GetStrengthMax(A1: Word; A2: Integer); virtual;  { +094 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +098 draft }
    procedure SortUnits; virtual;  { +09C draft }
    procedure SortOnMoves; virtual;  { +0A0 draft }
    procedure CanAddUnit(A1: Integer; A2: Integer); virtual;  { +0A4 draft }
    procedure CanDeleteUnit(A1: Integer); virtual;  { +0A8 draft }
    procedure AddUnit(A1: Integer); virtual;  { +0AC draft }
    procedure DeleteUnit(A1: Integer); virtual;  { +0B0 draft }
    procedure AddUnits(A1: Integer); virtual;  { +0B4 draft }
    procedure IndexOf;  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure IndexOfBehavior(A1: Integer);  { draft }
    procedure IndexOfGroup(A1: Integer);  { draft }
    procedure IndexOfGroupID(A1: Integer);  { draft }
    procedure FindID(A1: Integer);  { draft }
    procedure GetUnit(A1: Integer);  { draft }
    procedure SetUnit(A1: Integer; A2: Integer);  { draft }
  end;

  { TUnitUserList (instance size 16, VMT 55710FEC) }
  TUnitUserList = class(TUnitList)
  public
    procedure Clear; override;
    procedure AddUnit(A1: Integer); override;
    procedure DeleteUnit(A1: Integer); override;
    procedure AddUnitsEx(A1: Integer; A2: Integer);  { draft }
  end;

  { TUnitIndexList (instance size 20, VMT 55711118) }
  TUnitIndexList = class(TIntegerList)
  public
    procedure Create(A1: Byte);  { draft }
    procedure GetUnitIndex(A1: Integer);  { draft }
    procedure VerifyUnits(A1: Byte);  { draft }
    procedure SetUnitIndex(A1: Integer; A2: Integer);  { draft }
    procedure SortUnits;  { draft }
  end;

  { TUnitIndexListCollection (instance size 12, VMT 557111A4) }
  TUnitIndexListCollection = class(TObject)
  public
    F_UnitIndexListCollection_04: Integer;
    F_UnitIndexListCollection_08: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure LoadFromStream;  { draft }
    procedure SaveToStream;  { draft }
    procedure GetCollectionCount(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure GetU(A1: Integer; A2: Integer);  { draft }
    procedure AddUnit(A1: Integer; A2: Integer);  { draft }
    procedure DeleteUnit(A1: Integer; A2: Integer);  { draft }
    procedure GetRndCollection;  { draft }
  end;

  { TUnitCategoryList (instance size 16, VMT 55711230) }
  TUnitCategoryList = class(TList)
  public
    destructor Destroy; override;
    procedure GetCategory(A1: Integer);  { draft }
    procedure Clear;  { draft }
    procedure SortUnits;  { draft }
    procedure AddUnit(A1: Integer; A2: Integer);  { draft }
  end;

  { TUnitSelectionControl (instance size 80, VMT 557112B4) }
  TUnitSelectionControl = class(TStringList)
  public
    F_UnitSelectionControl_2C: Byte;
    F_UnitSelectionControl_2D: Byte;
    F_UnitSelectionControl_2E: Byte;
    F_UnitSelectionControl_2F: array[0..0] of Byte;
    F_UnitSelectionControl_30: Integer;
    F_UnitSelectionControl_34: Integer;
    F_UnitSelectionControl_38: Integer;
    F_UnitSelectionControl_3C: Integer;
    F_UnitSelectionControl_40: Integer;
    F_UnitSelectionControl_44: Integer;
    F_UnitSelectionControl_48: Byte;
    F_UnitSelectionControl_49: Byte;
    F_UnitSelectionControl_4A: Byte;
    F_UnitSelectionControl_4B: Byte;
    F_UnitSelectionControl_4C: Integer;
    destructor Destroy; override;
    procedure Create(A1: Byte);  { draft }
    procedure SetSelectedUnitIndex(A1: Integer);  { draft }
    procedure SetSelectedHero(A1: Integer);  { draft }
    procedure GetUnitCategoryList(A1: Integer);  { draft }
    procedure GetUnitCategoryEnabled(A1: Integer);  { draft }
    procedure SetUnitCategoryEnabled(A1: Integer; A2: Integer);  { draft }
    procedure Reset;  { draft }
    procedure DisableAllCategories;  { draft }
    procedure UpdateSelection;  { draft }
  end;

  { TUnitSelector (instance size 44, VMT 557113B8) }
  TUnitSelector = class(TObject)
  public
    F_UnitSelector_04: Integer;
    F_UnitSelector_08: Byte;
    F_UnitSelector_09: array[0..2] of Byte;
    F_UnitSelector_0C: Byte;
    F_UnitSelector_0D: array[0..2] of Byte;
    F_UnitSelector_10: Integer;
    F_UnitSelector_14: Byte;
    F_UnitSelector_15: Byte;
    F_UnitSelector_16: Byte;
    F_UnitSelector_17: array[0..0] of Byte;
    F_UnitSelector_18: Integer;
    F_UnitSelector_1C: Byte;
    F_UnitSelector_1D: array[0..0] of Byte;
    F_UnitSelector_1E: Word;
    F_UnitSelector_20: Integer;
    F_UnitSelector_24: Byte;
    F_UnitSelector_25: array[0..0] of Byte;
    F_UnitSelector_26: Word;
    F_UnitSelector_28: Integer;
    destructor Destroy; override;
    procedure SetSelection(A1: Byte); virtual;  { +000 draft }
    procedure CanSelectUnit(A1: Integer); virtual;  { +004 draft }
    procedure Setup(A1: Integer; A2: Integer); virtual;  { +008 draft }
    procedure CanSelect(A1: Integer); virtual;  { +00C draft }
    procedure Select; virtual;  { +010 draft }
    procedure Cancel; virtual;  { +014 draft }
    constructor Create;  { draft }
    procedure AddRef;  { draft }
    procedure Release;  { draft }
    procedure GetSelectionCount;  { draft }
  end;

  { TUnitSelectorAAI (instance size 32, VMT 55711454) }
  TUnitSelectorAAI = class(TActivateAbilityInfo)
  public
    F_UnitSelectorAAI_1C: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetUnitSelector(A1: Integer);  { draft }
  end;

  { THeroInventory (instance size 24, VMT 5571162C) }
  THeroInventory = class(TItemList)
  public
    destructor Destroy; override;
    function GetControlStyle: Engine.TEControlStyles; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetFreeSlot(A1: Integer; A2: Integer);  { draft }
    procedure GetAbilityCount(A1: Integer; A2: Integer);  { draft }
    procedure GetSuperlativeEnabledAbOwner(A1: Integer);  { draft }
    procedure GetAbilityEnabled(A1: Integer);  { draft }
    procedure GetAbilitySet(A1: Integer);  { draft }
    procedure GetSuperlativeAbOwner(A1: Integer);  { draft }
    procedure GetSlot(A1: Integer);  { draft }
  end;

  { THeroItems (instance size 24, VMT 55711738) }
  THeroItems = class(TItemList)
  public
    destructor Destroy; override;
    function GetControlStyle: Engine.TEControlStyles; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetAttack;  { draft }
    procedure GetDefense;  { draft }
    procedure GetDamage;  { draft }
    procedure GetResistance;  { draft }
    procedure GetMoveTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetImmunityTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetProtectionTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetAbilityCount(A1: Integer; A2: Integer);  { draft }
    procedure GetSuperlativeEnabledAbOwner(A1: Integer);  { draft }
    procedure GetSuperlativeAbOwner(A1: Integer);  { draft }
    procedure GetAbilityEnabled(A1: Integer; A2: Integer);  { draft }
    procedure GetAbilitySet(A1: Integer; A2: Integer);  { draft }
    procedure GetPositionItem(A1: Integer);  { draft }
    procedure GetPositionItemType(A1: Byte);  { draft }
    procedure GetItemTypePosition(A1: Byte);  { draft }
    procedure CanPlaceItem(A1: Integer; A2: Integer);  { draft }
    procedure PlaceItem(A1: Integer; A2: Integer);  { draft }
  end;

  { THeroUpgradeTE (instance size 32, VMT 55711920) }
  THeroUpgradeTE = class(TTokenEvent)
  public
    F_HeroUpgradeTE_10: Integer;
    F_HeroUpgradeTE_14: Byte;
    F_HeroUpgradeTE_15: Byte;
    F_HeroUpgradeTE_16: Byte;
    F_HeroUpgradeTE_17: Byte;
    F_HeroUpgradeTE_18: Byte;
    F_HeroUpgradeTE_19: Byte;
    F_HeroUpgradeTE_1A: Byte;
    F_HeroUpgradeTE_1B: array[0..0] of Byte;
    F_HeroUpgradeTE_1C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Setup(A1: Integer);  { draft }
  end;

  { THeroUpdateTE (instance size 32, VMT 557119E8) }
  THeroUpdateTE = class(TTokenEvent)
  public
    F_HeroUpdateTE_10: Integer;
    F_HeroUpdateTE_14: Byte;
    F_HeroUpdateTE_15: array[0..2] of Byte;
    F_HeroUpdateTE_18: Integer;
    F_HeroUpdateTE_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { THeroPowerSource (instance size 12, VMT 55711AAC) }
  THeroPowerSource = class(TPowerSource)
  public
    F_HeroPowerSource_08: Integer;
    procedure Name(A1: Integer); override;
    procedure Power; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Select(A1: Integer; A2: Integer); override;
  end;

  { THeroUpgradeEventLog (instance size 36, VMT 55711B88) }
  THeroUpgradeEventLog = class(TEventLog)
  public
    F_HeroUpgradeEventLog_18: Integer;
    F_HeroUpgradeEventLog_1C: Byte;
    F_HeroUpgradeEventLog_1D: Byte;
    F_HeroUpgradeEventLog_1E: array[0..1] of Byte;
    F_HeroUpgradeEventLog_20: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
  end;

  { TJoinEventLog (instance size 60, VMT 55711C84) }
  TJoinEventLog = class(TEventLog)
  public
    F_JoinEventLog_18: Integer;
    F_JoinEventLog_1C: Integer;
    F_JoinEventLog_20: Integer;
    F_JoinEventLog_24: Byte;
    F_JoinEventLog_25: array[0..2] of Byte;
    F_JoinEventLog_28: Integer;
    F_JoinEventLog_2C: Integer;
    F_JoinEventLog_30: Integer;
    F_JoinEventLog_34: Byte;
    F_JoinEventLog_35: array[0..2] of Byte;
    F_JoinEventLog_38: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Validate(A1: Integer; A2: Integer); virtual;  { +078 draft }
    procedure ListJoinUnits(A1: Integer; A2: Integer); virtual;  { +07C draft }
    procedure Accept(A1: Integer; A2: Integer); virtual;  { +080 draft }
    procedure Cancel; virtual;  { +084 draft }
    procedure Reject; virtual;  { +088 draft }
    procedure SetupJoinArmy(A1: Integer; A2: Byte; A3: Integer);  { draft }
  end;

  { THeroJoinEventLog (instance size 60, VMT 55711D94) }
  THeroJoinEventLog = class(TJoinEventLog)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure Accept(A1: Integer; A2: Integer); override;
    procedure ExecuteAI;  { draft }
  end;

  { THeroEmergeEventLog (instance size 44, VMT 55711ED8) }
  THeroEmergeEventLog = class(TEventLog)
  public
    F_HeroEmergeEventLog_18: Integer;
    F_HeroEmergeEventLog_1C: Integer;
    F_HeroEmergeEventLog_20: Integer;
    F_HeroEmergeEventLog_24: Byte;
    F_HeroEmergeEventLog_25: array[0..2] of Byte;
    F_HeroEmergeEventLog_28: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer; A2: Byte);  { draft }
    procedure CreateHeroJoinEventLog;  { draft }
    procedure ExecuteAI;  { draft }
  end;

  { THero (instance size 156, VMT 55711FEC) }
  THero = class(TAbstractUnit)
  public
    F_Hero_3C: Integer;
    F_Hero_40: Integer;
    F_Hero_44: Integer;
    F_Hero_48: Integer;
    F_Hero_4C: Byte;
    F_Hero_4D: array[0..2] of Byte;
    F_Hero_50: Integer;
    F_Hero_54: Byte;
    F_Hero_55: Byte;
    F_Hero_56: array[0..1] of Byte;
    F_Hero_58: Integer;
    F_Hero_5C: Byte;
    F_Hero_5D: Byte;
    F_Hero_5E: array[0..1] of Byte;
    F_Hero_60: Integer;
    F_Hero_64: Integer;
    F_Hero_68: Byte;
    F_Hero_69: Byte;
    F_Hero_6A: Byte;
    F_Hero_6B: Byte;
    F_Hero_6C: Byte;
    F_Hero_6D: Byte;
    F_Hero_6E: Byte;
    F_Hero_6F: Byte;
    F_Hero_70: Integer;
    F_Hero_74: Integer;
    F_Hero_78: Byte;
    F_Hero_79: Byte;
    F_Hero_7A: Byte;
    F_Hero_7B: array[0..0] of Byte;
    F_Hero_7C: Integer;
    F_Hero_80: Byte;
    F_Hero_81: array[0..2] of Byte;
    F_Hero_84: Integer;
    F_Hero_88: Integer;
    F_Hero_8C: Integer;
    F_Hero_90: Integer;
    F_Hero_94: Integer;
    F_Hero_98: Byte;
    F_Hero_99: array[0..2] of Byte;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetAbSet(A1: Integer); override;
    procedure SetAbSet(A1: Integer; A2: Byte); override;
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); override;
    procedure Changed; override;
    procedure GetUpkeep; override;
    procedure GetUnitLevel; override;
    procedure GetRace; override;
    procedure GetInherentAttack; override;
    procedure GetInherentDefense; override;
    procedure GetInherentDamage; override;
    procedure GetInherentResistance; override;
    procedure GetAttack(A1: Integer; A2: Integer); override;
    procedure GetDefense(A1: Integer; A2: Integer); override;
    procedure GetDamage(A1: Integer; A2: Integer); override;
    procedure GetResistance(A1: Integer; A2: Integer); override;
    procedure GetHits; override;
    procedure GetMoves; override;
    procedure GetMovePoints; override;
    procedure SetMovePoints(A1: Integer); override;
    procedure GetHitPoints; override;
    procedure SetHitPoints(A1: Integer); override;
    procedure GetMoveTypes; override;
    procedure GetImmunityTypes; override;
    procedure GetProtectionTypes; override;
    procedure GetFace; override;
    procedure GetName(A1: Integer); override;
    procedure GetAlignment; override;
    procedure GetPreviewImage; override;
    procedure GetGender; override;
    procedure GetUnitType; override;
    procedure GetUnitGFXResourceIndex; override;
    procedure GetCampaignTransferPoints; override;
    procedure GetCastingPointsMax; override;
    procedure GetCastingPoints; override;
    procedure SetCastingPoints(A1: Integer); override;
    procedure GetPowerGeneration; override;
    procedure NewDay(A1: Integer; A2: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure GetAbilityLevel(A1: Integer); override;
    procedure GetAbilityEnabled(A1: Integer); override;
    procedure GetAbilitySet(A1: Integer); override;
    procedure GetAbilityName(A1: Integer; A2: Integer); override;
    procedure GetAbilityOwner(A1: Integer); override;
    procedure GetAbilityCount; override;
    procedure GetExperience; override;
    procedure SetExperience(A1: Integer; A2: Integer); override;
    procedure GetNextLevelExperience; override;
    procedure GetDescription; override;
    procedure SetPlayer(A1: Integer); override;
    procedure GetObtainValue; override;
    procedure CanActivate; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Deactivate; override;
    procedure CanJoin(A1: Byte; A2: Integer); override;
    procedure OfferToJoin(A1: Integer); override;
    procedure ShowEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure Killed; override;
    procedure Resurrect; override;
    procedure Animate; override;
    procedure GetNickname(A1: Integer); virtual;  { +1B8 draft }
    procedure SetNickname(A1: Integer; A2: Integer); virtual;  { +1BC draft }
    procedure SetHeroResourceIndex(A1: Integer); virtual;  { +1C0 draft }
    procedure EditDropMsg(A1: Integer); virtual;  { +1C4 draft }
    procedure GetLibraryName(A1: Integer);  { draft }
    procedure UpdateFromLibraryBegin;  { draft }
    procedure UpdateFromLibraryEnd;  { draft }
    procedure UpdateFromLibrary;  { draft }
    procedure GetLibraryHero;  { draft }
    procedure UsedSkillPoints;  { draft }
    procedure EmergedToPlayer;  { draft }
    procedure DropItemsOnMap(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CompatibleHero(A1: Integer; A2: Integer);  { draft }
    procedure GetSkillPoints;  { draft }
    procedure GetSkillPointsMax;  { draft }
    procedure GetLevelMax;  { draft }
    procedure LevelToExperience(A1: Integer);  { draft }
    procedure ExperienceToLevel(A1: Integer);  { draft }
    procedure GetLevel;  { draft }
    procedure SetLevel(A1: Integer);  { draft }
    procedure GetHeroType;  { draft }
    procedure SetUnitAttack(A1: Integer);  { draft }
    procedure SetUnitDefense(A1: Integer);  { draft }
    procedure SetUnitDamage(A1: Integer);  { draft }
    procedure SetUnitHits(A1: Integer);  { draft }
    procedure SetUnitMoves(A1: Integer);  { draft }
    procedure SetUnitResistance(A1: Integer);  { draft }
    procedure LinkToResource;  { draft }
    procedure Loaded;  { draft }
    procedure ListSpells(A1: Integer);  { draft }
    procedure ExecuteUpgradeHeroAI;  { draft }
    procedure ValidateHeroUpgrade(A1: Integer; A2: Integer);  { draft }
    procedure GetUnitAbilityEnabled;  { draft }
    procedure GetSuperlativeEnabledAbOwner(A1: Integer; A2: Integer);  { draft }
    procedure GetSuperlativeAbOwner(A1: Integer; A2: Integer);  { draft }
    procedure ResetSkillPoints;  { draft }
    procedure ResetResourceSettings;  { draft }
    procedure UpdateSettings;  { draft }
    procedure SetRace(A1: Byte; A2: Integer);  { draft }
    procedure SetFaceIndex(A1: Integer);  { draft }
    procedure CreateHeroUpdateTE;  { draft }
    procedure GetItemsOnGround;  { draft }
    procedure CanUseItem(A1: Integer; A2: Integer);  { draft }
    procedure UseItem;  { draft }
    procedure CanPlaceItem(A1: Integer; A2: Byte);  { draft }
    procedure CanSwapItem(A1: Integer; A2: Integer);  { draft }
    procedure SwapItem(A1: Integer; A2: Integer);  { draft }
    procedure PlaceItem(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteSwapItem(A1: Integer; A2: Integer);  { draft }
    procedure AutoPlaceItem(A1: Integer; A2: Integer);  { draft }
    procedure ExecutePlaceItem(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteStartCasting(A1: Integer);  { draft }
    procedure RemoveCastingReadyEventLog;  { draft }
    procedure ExecuteCancelCasting;  { draft }
    procedure CastingDone(A1: Integer; A2: Integer);  { draft }
    procedure CastingMana(A1: Integer);  { draft }
    procedure CastingTurns;  { draft }
    procedure Casting;  { draft }
    procedure CastingReady;  { draft }
    procedure CastingTurnsLeft;  { draft }
    procedure CanCastSpellInstantly(A1: Integer; A2: Integer);  { draft }
    procedure CanCastSpell(A1: Integer; A2: Integer);  { draft }
    procedure CastSpell(A1: Integer; A2: Integer);  { draft }
    procedure CanCastCombatSpell(A1: Integer; A2: Integer);  { draft }
    procedure CastCombatSpell(A1: Integer; A2: Integer);  { draft }
    procedure CancelCasting;  { draft }
  end;

  { TLeader (instance size 164, VMT 55712238) }
  TLeader = class(THero)
  public
    F_Leader_9C: Byte;
    F_Leader_9D: array[0..2] of Byte;
    F_Leader_A0: Integer;
    destructor Destroy; override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Changed; override;
    procedure GetUpkeep; override;
    procedure GetPowerGeneration; override;
    procedure SetPlayer(A1: Integer); override;
    procedure GetUnitMoraleValue(A1: Integer; A2: Byte); override;
    procedure CanActivate; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Deactivate; override;
    procedure CanDisband; override;
    procedure Killed; override;
    procedure GetNickname(A1: Integer); override;
    procedure SetNickname(A1: Integer; A2: Integer); override;
    procedure SetHeroResourceIndex(A1: Integer); override;
    procedure EditDropMsg(A1: Integer); override;
    procedure GetSpherePicks(A1: Byte);  { draft }
    procedure GetSpheres(A1: Integer);  { draft }
    procedure GetSphereCount;  { draft }
    procedure SetSpherePicksMax(A1: Byte);  { draft }
    procedure CanAddSphere(A1: Integer);  { draft }
    procedure AddSphere(A1: Byte; A2: Integer);  { draft }
    procedure DeleteSphereIndex(A1: Integer);  { draft }
    procedure DeleteSphere(A1: Byte; A2: Integer);  { draft }
    procedure ClearSpheres;  { draft }
  end;

  { THeroList (instance size 12, VMT 557124C8) }
  THeroList = class(TEReferenceNode)
  public
    procedure FindHero(A1: Integer);  { draft }
    procedure GetHero(A1: Integer);  { draft }
  end;

  { THeroControl (instance size 24, VMT 557125BC) }
  THeroControl = class(TEObject)
  public
    F_HeroControl_08: Integer;
    F_HeroControl_0C: Integer;
    F_HeroControl_10: Integer;
    F_HeroControl_14: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Changed;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure UpdateLibraryHeroes;  { draft }
    procedure GetHero(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure FindID;  { draft }
    procedure IndexOf;  { draft }
    procedure IndexOfLibraryEx(A1: Integer; A2: Integer);  { draft }
    procedure ValidateLibraryHeroes;  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
    procedure RegisterHero(A1: Integer);  { draft }
    procedure UnRegisterHero(A1: Integer);  { draft }
    procedure HeroChanged;  { draft }
    procedure GetAverageFreeHeroLevel(A1: Integer; A2: Integer);  { draft }
    procedure GetMinFreeHeroLevel;  { draft }
    procedure ListDeadHeroes(A1: Integer);  { draft }
  end;

  { THeroLibrary (instance size 20, VMT 5571267C) }
  THeroLibrary = class(THeroList)
  public
    F_HeroLibrary_0C: Integer;
    F_HeroLibrary_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure CreateUniqueLibraryID;  { draft }
    procedure CreateHero;  { draft }
    procedure GetName(A1: Integer);  { draft }
    procedure FindLibraryID(A1: Integer);  { draft }
    procedure LoadFromFile;  { draft }
    procedure SaveToFile;  { draft }
  end;

  { THeroLibraryManager (instance size 16, VMT 55712788) }
  THeroLibraryManager = class(TEObject)
  public
    F_HeroLibraryManager_08: Integer;
    F_HeroLibraryManager_0C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLibrary(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure ReadUserLibraries;  { draft }
    procedure WriteUserLibraries;  { draft }
    procedure IndexOfLibraryName(A1: Integer);  { draft }
    procedure IndexOfLibrary;  { draft }
    procedure FindHero(A1: Integer; A2: Integer);  { draft }
    procedure CreateLibrary(A1: Integer);  { draft }
    procedure DeleteLibrary(A1: Integer);  { draft }
  end;

  { THeroResource (instance size 52, VMT 55712854) }
  THeroResource = class(TAbstractUnitResource)
  public
    F_HeroResource_1C: Integer;
    F_HeroResource_20: Byte;
    F_HeroResource_21: Byte;
    F_HeroResource_22: Byte;
    F_HeroResource_23: Byte;
    F_HeroResource_24: Byte;
    F_HeroResource_25: Byte;
    F_HeroResource_26: Byte;
    F_HeroResource_27: Byte;
    F_HeroResource_28: Byte;
    F_HeroResource_29: Byte;
    F_HeroResource_2A: array[0..1] of Byte;
    F_HeroResource_2C: Integer;
    F_HeroResource_30: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function ResourceUserClassID: Integer; override;
    procedure HeroResourceIndex;  { draft }
    procedure UsedSkillPoints;  { draft }
  end;

  { THeroResourceList (instance size 20, VMT 5571294C) }
  THeroResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetHeroResource(A1: Integer);  { draft }
    procedure CreateHeroResourceStrings(A1: Byte);  { draft }
    procedure Find(A1: Integer; A2: Byte);  { draft }
  end;

  { TAdjustableUnit (instance size 72, VMT 55712A54) }
  TAdjustableUnit = class(TAbstractUnit)
  public
    F_AdjustableUnit_3C: Integer;
    F_AdjustableUnit_40: Integer;
    F_AdjustableUnit_44: array[0..0] of Byte;
    F_AdjustableUnit_45: Byte;
    F_AdjustableUnit_46: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack(A1: Integer; A2: Integer); override;
    procedure GetDefense(A1: Integer; A2: Integer); override;
    procedure GetDamage(A1: Integer; A2: Integer); override;
    procedure GetResistance(A1: Integer; A2: Integer); override;
    procedure GetHits; override;
    procedure GetHitPoints; override;
    procedure SetHitPoints(A1: Integer); override;
    procedure GetImmunityTypes; override;
    procedure GetProtectionTypes; override;
    procedure MakeDefaultLevelUnit(A1: Byte);  { draft }
  end;

  { TWallUnit (instance size 64, VMT 55712C84) }
  TWallUnit = class(TAbstractUnit)
  public
    F_WallUnit_3C: Integer;
    procedure GetDefense(A1: Integer; A2: Integer); override;
    procedure GetHits; override;
    procedure GetHitPoints; override;
    procedure GetImmunityTypes; override;
    procedure GetName(A1: Integer); override;
    procedure GetUnitType; override;
    procedure SetWallType(A1: Integer);  { draft }
  end;

  { TArmyID (instance size 20, VMT 55712FF4) }
  TArmyID = class(TEObject)
  public
    F_ArmyID_08: Integer;
    F_ArmyID_0C: Byte;
    F_ArmyID_0D: array[0..2] of Byte;
    F_ArmyID_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Valid;  { draft }
    procedure RetrieveArmy(A1: Integer; A2: Integer);  { draft }
  end;

  { TArmy (instance size 44, VMT 557130EC) }
  TArmy = class(TUnitList)
  public
    F_Army_10: Byte;
    F_Army_11: Byte;
    F_Army_12: Byte;
    F_Army_13: Byte;
    F_Army_14: Byte;
    F_Army_15: Byte;
    F_Army_16: Byte;
    F_Army_17: Byte;
    F_Army_18: Integer;
    F_Army_1C: Integer;
    F_Army_20: Integer;
    F_Army_24: Byte;
    F_Army_25: Byte;
    F_Army_26: Byte;
    F_Army_27: Byte;
    F_Army_28: Byte;
    F_Army_29: Byte;
    F_Army_2A: Byte;
    F_Army_2B: array[0..0] of Byte;
    destructor Destroy; override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure Changed; override;
    procedure GetPlayer; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CanAddUnit(A1: Integer; A2: Integer); override;
    procedure CanDeleteUnit(A1: Integer); override;
    procedure AddUnit(A1: Integer); override;
    procedure AddUnits(A1: Integer); override;
    procedure GetUnitConcealedForPlayer(A1: Integer; A2: Integer); virtual;  { +0B8 draft }
    procedure GetConcealedForPlayer(A1: Byte); virtual;  { +0BC draft }
    procedure Kill(A1: Integer);  { draft }
    procedure GetStrengthEx(A1: Integer; A2: Integer);  { draft }
    procedure GetStrengthMaxEx(A1: Integer; A2: Integer);  { draft }
    procedure ReturnBattleFieldInfo(A1: Integer; A2: Integer);  { draft }
    procedure HealUnits(A1: Integer);  { draft }
    procedure CreateGroupID(A1: Integer);  { draft }
    procedure GetGroup(A1: Byte);  { draft }
    procedure SetGroup(A1: Integer; A2: Integer);  { draft }
    procedure GetGroupSelection(A1: Integer);  { draft }
    procedure GetBehavior;  { draft }
    procedure SetBehavior(A1: Integer; A2: Integer);  { draft }
    procedure GetOldAIBehavior;  { draft }
    procedure InitializeGroupBehavior;  { draft }
    procedure UpdateGroupBehavior(A1: Integer; A2: Integer);  { draft }
    procedure CreateID(A1: Integer; A2: Integer);  { draft }
    procedure GetArmyHS(A1: Integer; A2: Integer);  { draft }
    procedure AssignSettings(A1: Integer);  { draft }
    procedure SetFullyConcealed(A1: Byte);  { draft }
    procedure GetFullyConcealed;  { draft }
    procedure UpdateConcealment(A1: Integer; A2: Integer);  { draft }
    procedure SetXYL(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure GetRace(A1: Integer);  { draft }
    procedure GetUpkeep;  { draft }
    procedure ResetDestinationPos;  { draft }
    procedure SetDestinationPos(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure ConcealedUnitsCount;  { draft }
    procedure UpdateConcealedUnits;  { draft }
    procedure UpdateUpkeep;  { draft }
    procedure ValidateTerrainEx(A1: Byte; A2: Byte);  { draft }
    procedure ValidateTerrain;  { draft }
    procedure Validate;  { draft }
    procedure UpdateFormation;  { draft }
    procedure Update;  { draft }
    procedure TriggerOnUpdateEvent;  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
    procedure ValidateSelection(A1: Byte);  { draft }
    procedure SelectionCount(A1: Byte);  { draft }
    procedure ValidateMoveSelection(A1: Integer; A2: Integer);  { draft }
    procedure Select;  { draft }
    procedure Unselect;  { draft }
    procedure GetUnitConcealed(A1: Integer);  { draft }
    procedure GetUnitsConcealedForPlayer(A1: Integer; A2: Integer);  { draft }
    procedure SetPlayer(A1: Integer);  { draft }
    procedure ImmunityTypes(A1: Integer);  { draft }
    procedure ObtainValue(A1: Integer; A2: Integer);  { draft }
    procedure MovePoints(A1: Integer);  { draft }
    procedure Moves(A1: Integer);  { draft }
    procedure MoveTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetPartyMoves(A1: Byte);  { draft }
    procedure MoveOnMovePoints(A1: Integer; A2: Byte; A3: Integer);  { draft }
    procedure CreateMovePointTable(A1: Integer; A2: Integer);  { draft }
    procedure ValidTerrainEx(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure ValidTerrain(A1: Byte; A2: Integer);  { draft }
    procedure CanPlace(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure MovedTo(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure MaxSize(A1: Integer; A2: Integer);  { draft }
    procedure Hero(A1: Integer; A2: Byte);  { draft }
    procedure Leader(A1: Integer);  { draft }
    procedure Transporter(A1: Integer);  { draft }
    procedure IndexOfTransporter(A1: Integer);  { draft }
    procedure UnitsInTransporter;  { draft }
    procedure UpdateVisibilityRanges(A1: Integer; A2: Integer);  { draft }
    procedure VisibilityRange;  { draft }
    procedure TrueVisionRange;  { draft }
    procedure TurnUnFogOff;  { draft }
    procedure UpdateExploration;  { draft }
    procedure UpdateUnfog;  { draft }
    procedure CanAddUnits(A1: Integer; A2: Integer);  { draft }
    procedure CanAddUnitSelection(A1: Integer; A2: Integer);  { draft }
    procedure AddUnitSelection(A1: Integer; A2: Integer);  { draft }
    procedure SelectionUnit(A1: Byte; A2: Integer);  { draft }
    procedure MakeIndependent(A1: Integer; A2: Integer);  { draft }
    procedure UpdateIndependentRelation;  { draft }
    procedure Desert(A1: Byte);  { draft }
    procedure GetPartyStatus(A1: Integer);  { draft }
    procedure UpdateDesertion;  { draft }
    procedure ValidateCrusaders;  { draft }
    procedure NewTurn(A1: Byte);  { draft }
    procedure NewTurnDone(A1: Byte);  { draft }
    procedure NewDay;  { draft }
    procedure CanActivate;  { draft }
    procedure GetMoveAction(A1: Byte; A2: Integer);  { draft }
    procedure GetCanJoinSelection(A1: Byte; A2: Integer);  { draft }
    procedure GetJoinSelection(A1: Byte; A2: Integer);  { draft }
    procedure JoinAmount(A1: Byte; A2: Integer);  { draft }
    procedure IncommingNegotiateRequest(A1: Integer);  { draft }
    procedure IncommingNegotiateOffer(A1: Integer);  { draft }
    procedure TriggerFireDamage;  { draft }
    procedure RetrieveStormDamageInfo(A1: Byte);  { draft }
    procedure IncommingStorm(A1: Byte; A2: Integer);  { draft }
    procedure UpdateAITarget(A1: Integer; A2: Integer);  { draft }
    procedure AIMovePriority;  { draft }
    procedure ResetMoveDone;  { draft }
    procedure CanCombine(A1: Integer; A2: Integer);  { draft }
  end;

  { TArmyView (instance size 96, VMT 55713210) }
  TArmyView = class(TArmy)
  public
    F_ArmyView_2C: Byte;
    F_ArmyView_2D: array[0..14] of Byte;
    F_ArmyView_3C: Word;
    F_ArmyView_3E: array[0..1] of Byte;
    F_ArmyView_40: Byte;
    F_ArmyView_41: array[0..30] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetUnitConcealedForPlayer(A1: Integer; A2: Integer); override;
    procedure GetConcealedForPlayer(A1: Byte); override;
    procedure Setup(A1: Integer; A2: Byte); virtual;  { +0C0 draft }
    procedure SetConcealedForPlayer(A1: Byte; A2: Integer);  { draft }
    procedure SetUnitConcealedForPlayer(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TArmyHS (instance size 36, VMT 557133A0) }
  TArmyHS = class(TUnitHS)
  public
    F_ArmyHS_1C: Integer;
    F_ArmyHS_20: Byte;
    F_ArmyHS_21: Byte;
    F_ArmyHS_22: Byte;
    F_ArmyHS_23: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetSelected: Boolean; override;
    function CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure Select; override;
    procedure Unselect; override;
    function EditName: string; override;
    procedure MoveTo(A1: Integer; A2: Integer); override;
    procedure PlaceHX(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer); override;
    procedure UpdateFlagID; override;
    procedure MoveFirst(A1: Integer; A2: Integer); override;
    function GetMoveSteps: Integer; override;
    procedure GetFogEnabled;  { draft }
    procedure VisibleForSeatedPlayer;  { draft }
    procedure ArmyUpdated(A1: Integer);  { draft }
    procedure UpdateUnitGFXResource;  { draft }
    procedure PlacePrivate(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure PlayMoveSFX;  { draft }
    procedure ShowEnchantments(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PlaceEx(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
  end;

  { TArmyHSList (instance size 20, VMT 5571352C) }
  TArmyHSList = class(TEChangeNotifyEventList)
  public
    procedure GetArmyHS(A1: Integer);  { draft }
  end;

  { TArmyEventLog (instance size 52, VMT 55713628) }
  TArmyEventLog = class(TEventLog)
  public
    F_ArmyEventLog_18: Integer;
    F_ArmyEventLog_1C: Integer;
    F_ArmyEventLog_20: Integer;
    F_ArmyEventLog_24: Integer;
    F_ArmyEventLog_28: Integer;
    F_ArmyEventLog_2C: Integer;
    F_ArmyEventLog_30: Byte;
    F_ArmyEventLog_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure GetLeftIcon; override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
    procedure SetArmyView;  { draft }
    procedure LeaderKilled;  { draft }
    procedure PartyDestroyed;  { draft }
    procedure ValidateGameOver;  { draft }
  end;

  { TArmyInfoEventLog (instance size 52, VMT 55713724) }
  TArmyInfoEventLog = class(TEventLog)
  public
    F_ArmyInfoEventLog_18: Integer;
    F_ArmyInfoEventLog_1C: Byte;
    F_ArmyInfoEventLog_1D: array[0..2] of Byte;
    F_ArmyInfoEventLog_20: Integer;
    F_ArmyInfoEventLog_24: Integer;
    F_ArmyInfoEventLog_28: Integer;
    F_ArmyInfoEventLog_2C: Integer;
    F_ArmyInfoEventLog_30: Byte;
    F_ArmyInfoEventLog_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
    procedure SetArmyView;  { draft }
  end;

  { TRaceResource (instance size 72, VMT 55713838) }
  TRaceResource = class(TEResource)
  public
    F_RaceResource_18: Integer;
    F_RaceResource_1C: Integer;
    F_RaceResource_20: Integer;
    F_RaceResource_24: Integer;
    F_RaceResource_28: Integer;
    F_RaceResource_2C: Integer;
    F_RaceResource_30: Byte;
    F_RaceResource_31: array[0..2] of Byte;
    F_RaceResource_34: Integer;
    F_RaceResource_38: Integer;
    F_RaceResource_3C: Integer;
    F_RaceResource_40: Integer;
    F_RaceResource_44: Integer;
    destructor Destroy; override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    procedure SetCellImage(Value: ImageLib.TLibraryImage); override;
    class function ResourceEditName: string; override;
    procedure GetFace;  { draft }
    procedure GetRaceIndex;  { draft }
    procedure LinkToIL;  { draft }
    procedure ReleaseIL;  { draft }
    procedure SetImageLibraryName(A1: Integer; A2: Integer);  { draft }
    procedure GetCityImage(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetAlignment;  { draft }
  end;

  { TRaceResourceList (instance size 20, VMT 55713938) }
  TRaceResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetRaceResource(A1: Integer);  { draft }
    procedure GetMaxRaceIndex;  { draft }
  end;

  { TStructureShadow (instance size 16, VMT 55713A94) }
  TStructureShadow = class(THexagonSprite)
  public
    F_StructureShadow_08: Byte;
    F_StructureShadow_09: array[0..2] of Byte;
    F_StructureShadow_0C: Integer;
    destructor Destroy; override;
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TStructure (instance size 48, VMT 55713C18) }
  TStructure = class(TFixedILTerrainMO)
  public
    F_Structure_1C: Integer;
    F_Structure_20: Integer;
    F_Structure_24: Byte;
    F_Structure_25: Byte;
    F_Structure_26: array[0..1] of Byte;
    F_Structure_28: Integer;
    F_Structure_2C: Byte;
    F_Structure_2D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetTerrain(Index: Integer): ShortInt; override;
    function GetOverlay(Index: Integer): Shortint; override;
    function CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure Select; override;
    procedure Unselect; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function ValidTerrainType(TerrainType: Integer): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    function ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt; override;
    procedure GetTopBorderImage; virtual;  { +138 draft }
    procedure GetMiddleBorderImage; virtual;  { +13C draft }
    procedure GetBottomBorderImage; virtual;  { +140 draft }
    procedure GetDescription; virtual;  { +144 draft }
    procedure GetName(A1: Integer); virtual;  { +148 draft }
    procedure SetRazed(A1: Integer); virtual;  { +14C draft }
    procedure GetRazed; virtual;  { +150 draft }
    procedure GetRazeable; virtual;  { +154 draft }
    procedure RazeEx(A1: Integer); virtual;  { +158 draft }
    procedure SetupRazeDefenderAG(A1: Integer; A2: Integer); virtual;  { +15C draft }
    procedure CreateTE; virtual;  { +160 draft }
    procedure SetupTE(A1: Integer); virtual;  { +164 draft }
    procedure ExecuteTE(A1: Integer; A2: Integer); virtual;  { +168 draft }
    procedure GetDefenseRequirements(A1: Integer; A2: Integer); virtual;  { +16C draft }
    procedure GetDefensePriority; virtual;  { +170 draft }
    procedure NewDay; virtual;  { +174 draft }
    procedure NewTurn(A1: Integer); virtual;  { +178 draft }
    procedure SeatedPlayerChanged; virtual;  { +17C draft }
    procedure ArmyPlaced(A1: Integer); virtual;  { +180 draft }
    procedure ArmyRemoved; virtual;  { +184 draft }
    procedure ArmyChanged; virtual;  { +188 draft }
    procedure PlaySelectSample; virtual;  { +18C draft }
    procedure CreateShadow; virtual;  { +190 draft }
    procedure DestroyShadow; virtual;  { +194 draft }
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer); virtual;  { +198 draft }
    procedure BuildingDone; virtual;  { +19C draft }
    procedure ExecuteRebuild(A1: Integer); virtual;  { +1A0 draft }
    procedure ExecuteBuild(A1: Integer; A2: Byte); virtual;  { +1A4 draft }
    procedure GenerateRazeDefenders(A1: Integer; A2: Integer); virtual;  { +1A8 draft }
    procedure PlaceRazeDefenders(A1: Byte); virtual;  { +1AC draft }
    procedure ExecuteRaze(A1: Integer; A2: Integer); virtual;  { +1B0 draft }
    procedure GetCurrentActivityText(A1: Integer); virtual;  { +1B4 draft }
    procedure ValidateMap(A1: Integer); virtual;  { +1B8 draft }
    procedure MainValidateMap(A1: Integer); virtual;  { +1BC draft }
    procedure ExecuteAI(A1: Integer; A2: Integer); virtual;  { +1C0 draft }
    procedure UpdateAITarget(A1: Integer; A2: Integer); virtual;  { +1C4 draft }
    procedure Update; virtual;  { +1C8 draft }
    procedure VisibleForPlayer(A1: Byte); virtual;  { +1CC draft }
    procedure CanDblClick; virtual;  { +1D0 draft }
    procedure ListUnits(A1: Integer); virtual;  { +1D4 draft }
    procedure ListArmies(A1: Integer); virtual;  { +1D8 draft }
    procedure GetRebuildInfo(A1: Integer; A2: Integer); virtual;  { +1DC draft }
    procedure CanRebuild(A1: Integer; A2: Integer); virtual;  { +1E0 draft }
    procedure Rebuild(A1: Integer); virtual;  { +1E4 draft }
    procedure Raze(A1: Integer); virtual;  { +1E8 draft }
    procedure CanRaze(A1: Byte; A2: Integer); virtual;  { +1EC draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure UpdateRoads(A1: Integer);  { draft }
    procedure GetPlayer;  { draft }
    procedure FogChanged;  { draft }
    procedure ValidateObservation(A1: Byte);  { draft }
    procedure GetBuilding;  { draft }
    procedure ShowBorderImage(A1: Integer; A2: Integer);  { draft }
    procedure ShowBorderImageDC(A1: Integer; A2: Integer);  { draft }
    procedure ShowRazeAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TStructureControl (instance size 20, VMT 55713E78) }
  TStructureControl = class(TEObject)
  public
    F_StructureControl_08: Integer;
    F_StructureControl_0C: Integer;
    F_StructureControl_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetStructure(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure CreateUniqueID;  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure FindID;  { draft }
    procedure Register(A1: Integer);  { draft }
    procedure Unregister(A1: Integer);  { draft }
    procedure Activate;  { draft }
  end;

  { TStructureResource (instance size 100, VMT 55713F40) }
  TStructureResource = class(TFixedILTerrainMOR)
  public
    F_StructureResource_44: Byte;
    F_StructureResource_45: Byte;
    F_StructureResource_46: Byte;
    F_StructureResource_47: array[0..0] of Byte;
    F_StructureResource_48: Integer;
    F_StructureResource_4C: Byte;
    F_StructureResource_4D: array[0..2] of Byte;
    F_StructureResource_50: Integer;
    F_StructureResource_54: Integer;
    F_StructureResource_58: Byte;
    F_StructureResource_59: Byte;
    F_StructureResource_5A: Byte;
    F_StructureResource_5B: Byte;
    F_StructureResource_5C: Integer;
    F_StructureResource_60: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +078 draft }
    procedure CalculatePadIndex;  { draft }
  end;

  { TRazeStructureEventLog (instance size 44, VMT 55714050) }
  TRazeStructureEventLog = class(TMessageEventLog)
  public
    F_RazeStructureEventLog_28: Byte;
    F_RazeStructureEventLog_29: array[0..2] of Byte;
    procedure Yes; override;
  end;

  { TPlayerStructureIncomeSource (instance size 12, VMT 55714160) }
  TPlayerStructureIncomeSource = class(TIncomeSource)
  public
    F_PlayerStructureIncomeSource_08: Integer;
    procedure Name(A1: Integer); override;
    procedure Income; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Setup(A1: Integer);  { draft }
  end;

  { TPlayerStructurePowerSource (instance size 12, VMT 55714250) }
  TPlayerStructurePowerSource = class(TPowerSource)
  public
    F_PlayerStructurePowerSource_08: Integer;
    procedure Name(A1: Integer); override;
    procedure Power; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Select(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer);  { draft }
  end;

  { TPlayerStructure (instance size 60, VMT 55714340) }
  TPlayerStructure = class(TStructure)
  public
    F_PlayerStructure_30: Byte;
    F_PlayerStructure_31: Byte;
    F_PlayerStructure_32: Byte;
    F_PlayerStructure_33: array[0..0] of Byte;
    F_PlayerStructure_34: Integer;
    F_PlayerStructure_38: Byte;
    F_PlayerStructure_39: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure NewDay; override;
    procedure NewTurn(A1: Integer); override;
    procedure SeatedPlayerChanged; override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure ArmyChanged; override;
    procedure BuildingDone; override;
    procedure ExecuteRebuild(A1: Integer); override;
    procedure ExecuteBuild(A1: Integer; A2: Byte); override;
    procedure UpdateAITarget(A1: Integer; A2: Integer); override;
    procedure CanRebuild(A1: Integer; A2: Integer); override;
    procedure SetPlayer(A1: Integer; A2: Integer); virtual;  { +1F0 draft }
    procedure GetIncome(A1: Integer; A2: Integer); virtual;  { +1F4 draft }
    procedure GetPower; virtual;  { +1F8 draft }
    procedure UpdateFlagID; virtual;  { +1FC draft }
    procedure VisibilityRange; virtual;  { +200 draft }
    procedure UpdateUnfog; virtual;  { +204 draft }
    procedure UpdateExploration; virtual;  { +208 draft }
    procedure FinalizeCombat(A1: Integer); virtual;  { +20C draft }
    procedure GetCombatEventText(A1: Integer; A2: Integer); virtual;  { +210 draft }
    procedure StructureCaptured(A1: Integer; A2: Byte); virtual;  { +214 draft }
    procedure GetMoveAction(A1: Integer; A2: Integer); virtual;  { +218 draft }
    procedure GetDefaultAITargetPriority; virtual;  { +21C draft }
    procedure UpdatePlayer; virtual;  { +220 draft }
    procedure GetVictoryLocation(A1: Byte);  { draft }
    procedure SetVictoryLocation(A1: Integer; A2: Integer);  { draft }
    procedure RegisterVictoryLocations;  { draft }
    procedure UnregisterVictoryLocations;  { draft }
    procedure TrueVisionRange;  { draft }
    procedure UpdatePlayerSeen;  { draft }
  end;

  { TPlayerStructureResource (instance size 116, VMT 557145E0) }
  TPlayerStructureResource = class(TStructureResource)
  public
    F_PlayerStructureResource_64: Byte;
    F_PlayerStructureResource_65: array[0..2] of Byte;
    F_PlayerStructureResource_68: Integer;
    F_PlayerStructureResource_6C: Integer;
    F_PlayerStructureResource_70: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function ResourceUserClassID: Integer; override;
    function PlaceResourceUser(HSMap: HSEngine.THSMap; Xhx, Yhx, Lhx: Shortint): HSEngine.TMapObject; override;
    procedure GenerateFlagPositions; virtual;  { +07C draft }
    procedure ActivateMsg;  { draft }
  end;

  { TStructureTE (instance size 40, VMT 557146EC) }
  TStructureTE = class(TTokenEvent)
  public
    F_StructureTE_10: Byte;
    F_StructureTE_11: Byte;
    F_StructureTE_12: Byte;
    F_StructureTE_13: Byte;
    F_StructureTE_14: Integer;
    F_StructureTE_18: Integer;
    F_StructureTE_1C: Byte;
    F_StructureTE_1D: array[0..2] of Byte;
    F_StructureTE_20: Integer;
    F_StructureTE_24: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Validate; virtual;  { +050 draft }
    procedure Initialize(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
  end;

  { TFrozenWaterHS (instance size 16, VMT 557147B4) }
  TFrozenWaterHS = class(TSingleHS)
  public
    F_FrozenWaterHS_0C: Byte;
    F_FrozenWaterHS_0D: Byte;
    F_FrozenWaterHS_0E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MeltIce;  { draft }
    procedure NewTurn(A1: Byte);  { draft }
  end;

  { TPadControl (instance size 20, VMT 5571493C) }
  TPadControl = class(TEControlStyleObject)
  public
    F_PadControl_0C: Integer;
    F_PadControl_10: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetPadResource(A1: Integer);  { draft }
    procedure SetPadResource(A1: Integer; A2: Integer);  { draft }
    procedure RegisterPadResource(A1: Integer; A2: Integer);  { draft }
    procedure UnregisterPadResource(A1: Integer; A2: Integer);  { draft }
    procedure CanPlacePad(A1: Byte; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure PlacePad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TFlagControl (instance size 20, VMT 557149F8) }
  TFlagControl = class(TEControlStyleObject)
  public
    F_FlagControl_0C: Integer;
    F_FlagControl_10: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ShowFlag(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ShowFlagEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure ShowStructureFlag(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ShowStructureFlagEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
  end;

  { TAoWHSSet (instance size 160, VMT 55714AB8) }
  TAoWHSSet = class(THSSet)
  public
    F_AoWHSSet_48: Integer;
    F_AoWHSSet_4C: Integer;
    F_AoWHSSet_50: Integer;
    F_AoWHSSet_54: Integer;
    F_AoWHSSet_58: Integer;
    F_AoWHSSet_5C: Integer;
    F_AoWHSSet_60: Integer;
    F_AoWHSSet_64: Integer;
    F_AoWHSSet_68: Integer;
    F_AoWHSSet_6C: Integer;
    F_AoWHSSet_70: Integer;
    F_AoWHSSet_74: Integer;
    F_AoWHSSet_78: Integer;
    F_AoWHSSet_7C: Integer;
    F_AoWHSSet_80: Integer;
    F_AoWHSSet_84: Integer;
    F_AoWHSSet_88: Integer;
    F_AoWHSSet_8C: Integer;
    F_AoWHSSet_90: Integer;
    F_AoWHSSet_94: Integer;
    F_AoWHSSet_98: Integer;
    F_AoWHSSet_9C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetFileCRC(A1: Integer; A2: Integer);  { draft }
    procedure RetrieveHSSCRC;  { draft }
  end;

  { TEmailGame (instance size 32, VMT 55714BAC) }
  TEmailGame = class(TEObject)
  public
    F_EmailGame_08: Integer;
    F_EmailGame_0C: Integer;
    F_EmailGame_10: Integer;
    F_EmailGame_14: Integer;
    F_EmailGame_18: Integer;
    F_EmailGame_1C: array[0..3] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TEmailGameList (instance size 12, VMT 55714C84) }
  TEmailGameList = class(TENode)
  public
    procedure GetEmailGames(A1: Integer);  { draft }
    procedure IndexOfUniqueLocalID(A1: Integer);  { draft }
  end;

  { TEmailGameControl (instance size 12, VMT 55714D84) }
  TEmailGameControl = class(TEObject)
  public
    F_EmailGameControl_08: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateUniqueLocalID;  { draft }
    procedure Load;  { draft }
    procedure Save;  { draft }
    procedure FindEmailGame(A1: Integer);  { draft }
    procedure EmailGameRestarted(A1: Integer);  { draft }
    procedure GenerateSecurityID;  { draft }
    procedure UpdateGame(A1: Integer);  { draft }
    procedure CreateEmailGame(A1: Integer; A2: Integer);  { draft }
    procedure ValidateIncommingGame(A1: Integer; A2: Integer);  { draft }
  end;

  { TRestartGameEventLog (instance size 40, VMT 55714E4C) }
  TRestartGameEventLog = class(TMessageEventLog)
  public
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TSMTPEventLog (instance size 52, VMT 55714F58) }
  TSMTPEventLog = class(TEventLog)
  public
    F_SMTPEventLog_18: array[0..11] of Byte;
    F_SMTPEventLog_24: Integer;
    F_SMTPEventLog_28: array[0..11] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFire (instance size 44, VMT 557150AC) }
  TFire = class(TILTerrainMO)
  public
    F_Fire_1C: Byte;
    F_Fire_1D: Byte;
    F_Fire_1E: Byte;
    F_Fire_1F: array[0..0] of Byte;
    F_Fire_20: Integer;
    F_Fire_24: Byte;
    F_Fire_25: array[0..2] of Byte;
    F_Fire_28: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetTerrain(Index: Integer): ShortInt; override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function GetMostFrequentMapFieldTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx, Default: Shortint): Shortint; override;
    procedure CalcShowPriority(A1: Integer);  { draft }
    procedure SetupExplosion(A1: Integer);  { draft }
    procedure TriggerDamage;  { draft }
    procedure CanDoDamage(A1: Integer);  { draft }
    procedure ArmyPlaced(A1: Integer);  { draft }
    procedure NewTurn;  { draft }
    procedure NewTurnDone;  { draft }
    procedure WaterMasteryCast;  { draft }
  end;

  { TFireResource (instance size 72, VMT 55715274) }
  TFireResource = class(TILTerrainMOR)
  public
    F_FireResource_44: Byte;
    F_FireResource_45: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TFireControl (instance size 8, VMT 55715360) }
  TFireControl = class(TObject)
  public
    F_FireControl_04: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure GetRndFireResource(A1: Byte; A2: Integer);  { draft }
    procedure PlaceFire(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure RegisterFireResource;  { draft }
    procedure UnregisterFireResource;  { draft }
  end;

  { TCombatPredictorUnit (instance size 84, VMT 5571567C) }
  TCombatPredictorUnit = class(TObject)
  public
    F_CombatPredictorUnit_04: Integer;
    F_CombatPredictorUnit_08: Integer;
    F_CombatPredictorUnit_0C: Integer;
    F_CombatPredictorUnit_10: Integer;
    F_CombatPredictorUnit_14: Byte;
    F_CombatPredictorUnit_15: array[0..2] of Byte;
    F_CombatPredictorUnit_18: Integer;
    F_CombatPredictorUnit_1C: Byte;
    F_CombatPredictorUnit_1D: Byte;
    F_CombatPredictorUnit_1E: array[0..1] of Byte;
    F_CombatPredictorUnit_20: Integer;
    F_CombatPredictorUnit_24: Integer;
    F_CombatPredictorUnit_28: Integer;
    F_CombatPredictorUnit_2C: Integer;
    F_CombatPredictorUnit_30: Byte;
    F_CombatPredictorUnit_31: Byte;
    F_CombatPredictorUnit_32: array[0..1] of Byte;
    F_CombatPredictorUnit_34: Integer;
    F_CombatPredictorUnit_38: Integer;
    F_CombatPredictorUnit_3C: Integer;
    F_CombatPredictorUnit_40: Integer;
    F_CombatPredictorUnit_44: Integer;
    F_CombatPredictorUnit_48: Integer;
    F_CombatPredictorUnit_4C: Integer;
    F_CombatPredictorUnit_50: Byte;
    F_CombatPredictorUnit_51: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Setup(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetEnabled(A1: Byte);  { draft }
    procedure UpdateTargets;  { draft }
    procedure UpdateWallTargets(A1: Integer; A2: Integer);  { draft }
    procedure InvalidateTargets;  { draft }
    procedure ResetCombat;  { draft }
    procedure ResetRoundTargets;  { draft }
    procedure SetupRoundTargets(A1: Byte);  { draft }
    procedure UpdateRoundTargetPriority;  { draft }
    procedure SortRoundTargets;  { draft }
    procedure ExecuteRound;  { draft }
    procedure FinishCombat;  { draft }
  end;

  { TCombatPredictorUnitList (instance size 16, VMT 55715700) }
  TCombatPredictorUnitList = class(TList)
  public
    procedure GetUnits(A1: Integer);  { draft }
    procedure IndexOfUnit(A1: Integer);  { draft }
    procedure IndexOfCPUID(A1: Integer);  { draft }
  end;

  { TCombatPredictorSide (instance size 60, VMT 55715794) }
  TCombatPredictorSide = class(TCombatPredictorUnitList)
  public
    F_CombatPredictorSide_10: array[0..3] of Byte;
    F_CombatPredictorSide_14: Byte;
    F_CombatPredictorSide_15: array[0..38] of Byte;
    procedure Reset;  { draft }
    procedure GetStrength(A1: Integer);  { draft }
    procedure GetStrengthMax(A1: Word; A2: Integer);  { draft }
  end;

  { TCombatPredictor (instance size 52, VMT 55715820) }
  TCombatPredictor = class(TObject)
  public
    F_CombatPredictor_04: Integer;
    F_CombatPredictor_08: Integer;
    F_CombatPredictor_0C: Integer;
    F_CombatPredictor_10: Integer;
    F_CombatPredictor_14: Byte;
    F_CombatPredictor_15: array[0..2] of Byte;
    F_CombatPredictor_18: Integer;
    F_CombatPredictor_1C: Integer;
    F_CombatPredictor_20: Integer;
    F_CombatPredictor_24: Integer;
    F_CombatPredictor_28: Integer;
    F_CombatPredictor_2C: Byte;
    F_CombatPredictor_2D: array[0..2] of Byte;
    F_CombatPredictor_30: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Reset;  { draft }
    procedure CreateUniqueCPUID;  { draft }
    procedure EnableAllUnits;  { draft }
    procedure Validate;  { draft }
    procedure ResetCombat;  { draft }
    procedure SetupCombat(A1: Integer);  { draft }
    procedure ExecuteCombatRound;  { draft }
    procedure CanPassWall;  { draft }
    procedure FinishCombat;  { draft }
    procedure Execute;  { draft }
    procedure DeleteUnit(A1: Integer; A2: Integer);  { draft }
    procedure AddUnitEx(A1: Integer; A2: Byte; A3: Integer);  { draft }
    procedure AddUnit;  { draft }
    procedure AddUnits(A1: Integer);  { draft }
    procedure AddOpponent(A1: Integer; A2: Integer);  { draft }
    procedure AddOpponents(A1: Integer; A2: Integer);  { draft }
    procedure AddWall(A1: Integer);  { draft }
    procedure DeleteWall;  { draft }
    procedure DeleteUnits;  { draft }
    procedure DeleteOpponents;  { draft }
    procedure InitAdjacentArmies(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure InitAdjacentOpponents(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure GetSuperiority(A1: Integer; A2: Integer);  { draft }
    procedure GetEfficiency;  { draft }
    procedure ListRequiredUnitsEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ListRequiredUnits(A1: Integer; A2: Integer);  { draft }
    procedure ListOptionalUnits(A1: Integer; A2: Integer);  { draft }
    procedure ListUselessUnits(A1: Integer);  { draft }
    procedure Usefullness(A1: Integer; A2: Integer);  { draft }
  end;

  { TCombatObject (instance size 76, VMT 557158EC) }
  TCombatObject = class(TEObject)
  public
    F_CombatObject_08: Integer;
    F_CombatObject_0C: Byte;
    F_CombatObject_0D: array[0..2] of Byte;
    F_CombatObject_10: Integer;
    F_CombatObject_14: Integer;
    F_CombatObject_18: Integer;
    F_CombatObject_1C: Integer;
    F_CombatObject_20: Integer;
    F_CombatObject_24: array[0..3] of Byte;
    F_CombatObject_28: Integer;
    F_CombatObject_2C: Integer;
    F_CombatObject_30: Integer;
    F_CombatObject_34: array[0..3] of Byte;
    F_CombatObject_38: Integer;
    F_CombatObject_3C: Byte;
    F_CombatObject_3D: array[0..2] of Byte;
    F_CombatObject_40: Integer;
    F_CombatObject_44: Byte;
    F_CombatObject_45: Byte;
    F_CombatObject_46: Byte;
    F_CombatObject_47: Byte;
    F_CombatObject_48: Byte;
    F_CombatObject_49: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer); virtual;  { +04C draft }
    procedure GetTargetWallCV(A1: Integer); virtual;  { +050 draft }
    procedure TargetsChanged; virtual;  { +054 draft }
    procedure GetTargetPriority; virtual;  { +058 draft }
    procedure GetTargetStrength; virtual;  { +05C draft }
    procedure GetEnabled; virtual;  { +060 draft }
    procedure GetLocked; virtual;  { +064 draft }
    procedure SetCombatPlayer(A1: Integer; A2: Integer); virtual;  { +068 draft }
    procedure GetAttack; virtual;  { +06C draft }
    procedure GetDefense; virtual;  { +070 draft }
    procedure GetResistance; virtual;  { +074 draft }
    procedure GetDamage; virtual;  { +078 draft }
    procedure GetImmunityTypes; virtual;  { +07C draft }
    procedure GetProtectionTypes; virtual;  { +080 draft }
    procedure GetHits; virtual;  { +084 draft }
    procedure GetHitPoints; virtual;  { +088 draft }
    procedure SetHitPoints(A1: Byte); virtual;  { +08C draft }
    procedure GetAlignment; virtual;  { +090 draft }
    procedure GetMoves; virtual;  { +094 draft }
    procedure GetExperience; virtual;  { +098 draft }
    procedure SetExperience; virtual;  { +09C draft }
    procedure GetLevel; virtual;  { +0A0 draft }
    procedure GetVisibilityRange; virtual;  { +0A4 draft }
    procedure GetAbilityEnabled; virtual;  { +0A8 draft }
    procedure SetAbilityEnabled; virtual;  { +0AC draft }
    procedure GetAbilityLevel; virtual;  { +0B0 draft }
    procedure GetAbilityCount; virtual;  { +0B4 draft }
    procedure GetAbilityOwner; virtual;  { +0B8 draft }
    procedure Activate(A1: Integer); virtual;  { +0BC draft }
    procedure Deactivate; virtual;  { +0C0 draft }
    procedure ObjectDestroyed(A1: Integer); virtual;  { +0C4 draft }
    procedure ObjectSideChanged(A1: Integer); virtual;  { +0C8 draft }
    procedure Initialize(A1: Integer); virtual;  { +0CC draft }
    procedure Finalize(A1: Integer); virtual;  { +0D0 draft }
    procedure fcRoundDistance; virtual;  { +0D4 draft }
    procedure fcExecute(A1: Integer); virtual;  { +0D8 draft }
    procedure fcBehindWall; virtual;  { +0DC draft }
    procedure fcWallInBetween(A1: Integer); virtual;  { +0E0 draft }
    procedure SupportCombatMode(A1: Byte; A2: Integer); virtual;  { +0E4 draft }
    procedure WallCombatFeatures; virtual;  { +0E8 draft }
    procedure PlaySFX(A1: Byte); virtual;  { +0EC draft }
    procedure NewTurn(A1: Integer); virtual;  { +0F0 draft }
    procedure NewRound; virtual;  { +0F4 draft }
    procedure CombatDone; virtual;  { +0F8 draft }
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +0FC draft }
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +100 draft }
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +104 draft }
    procedure DoDamage(A1: Integer; A2: Integer); virtual;  { +108 draft }
    procedure GetOptimalDamageType(A1: Word; A2: Integer); virtual;  { +10C draft }
    procedure ExecuteDamageRole(A1: Integer; A2: Integer; A3: Integer); virtual;  { +110 draft }
    procedure ExecuteDamageRoleEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +114 draft }
    procedure ExecuteDamageEffectsRole(A1: Word; A2: Integer); virtual;  { +118 draft }
    procedure Surrender; virtual;  { +11C draft }
    procedure DestroyObject; virtual;  { +120 draft }
    function ExecuteDamage(A1: Integer): Integer; virtual;  { +124 draft }
    procedure ExecuteDamageEffects(A1: Word; A2: Integer); virtual;  { +128 draft }
    procedure TurnDone; virtual;  { +12C draft }
    procedure IDStr(A1: Integer); virtual;  { +130 draft }
    procedure AddTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DeleteTarget(A1: Integer);  { draft }
    procedure RemoveTarget(A1: Integer);  { draft }
    procedure ResetTargets;  { draft }
    procedure SetupTargets;  { draft }
    procedure GetSide;  { draft }
    procedure GetOpponentSide;  { draft }
    procedure GetPlayer;  { draft }
    procedure GetPlayerIR;  { draft }
  end;

  { TCombatUnit (instance size 92, VMT 55715A94) }
  TCombatUnit = class(TCombatObject)
  public
    F_CombatUnit_4C: Integer;
    F_CombatUnit_50: array[0..3] of Byte;
    F_CombatUnit_54: Byte;
    F_CombatUnit_55: Byte;
    F_CombatUnit_56: array[0..1] of Byte;
    F_CombatUnit_58: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetTargetWallCV(A1: Integer); override;
    procedure GetTargetPriority; override;
    procedure GetTargetStrength; override;
    procedure GetEnabled; override;
    procedure GetLocked; override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetResistance; override;
    procedure GetDamage; override;
    procedure GetImmunityTypes; override;
    procedure GetProtectionTypes; override;
    procedure GetHits; override;
    procedure GetHitPoints; override;
    procedure SetHitPoints(A1: Byte); override;
    procedure GetAlignment; override;
    procedure GetMoves; override;
    procedure GetExperience; override;
    procedure SetExperience; override;
    procedure GetLevel; override;
    procedure GetVisibilityRange; override;
    procedure GetAbilityEnabled; override;
    procedure SetAbilityEnabled; override;
    procedure GetAbilityLevel; override;
    procedure GetAbilityCount; override;
    procedure GetAbilityOwner; override;
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    procedure ObjectDestroyed(A1: Integer); override;
    procedure Initialize(A1: Integer); override;
    procedure Finalize(A1: Integer); override;
    procedure SupportCombatMode(A1: Byte; A2: Integer); override;
    procedure WallCombatFeatures; override;
    procedure PlaySFX(A1: Byte); override;
    procedure NewTurn(A1: Integer); override;
    procedure NewRound; override;
    procedure CombatDone; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ExecuteDamageEffectsRole(A1: Word; A2: Integer); override;
    procedure Surrender; override;
    procedure DestroyObject; override;
    procedure ExecuteDamageEffects(A1: Word; A2: Integer); override;
    procedure IDStr(A1: Integer); override;
    procedure SetUnit(A1: Integer); virtual;  { +134 draft }
    procedure KillUnit; virtual;  { +138 draft }
    procedure Setup(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure UpdateWallCombatFeatures;  { draft }
    procedure SetParty(A1: Integer);  { draft }
    procedure UpdateParty;  { draft }
    procedure UpdateUnitGFXResource;  { draft }
    procedure ReleaseUnitGFXResource;  { draft }
    procedure SetStatus(A1: Byte; A2: Integer);  { draft }
    procedure CommandingTargetPriority(A1: Integer; A2: Integer);  { draft }
    procedure CommandingTargetStrength(A1: Integer; A2: Integer);  { draft }
  end;

  { TCombatWall (instance size 80, VMT 55715C40) }
  TCombatWall = class(TCombatObject)
  public
    F_CombatWall_4C: Byte;
    F_CombatWall_4D: Byte;
    F_CombatWall_4E: Byte;
    F_CombatWall_4F: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetTargetPriority; override;
    procedure GetTargetStrength; override;
    procedure GetLocked; override;
    procedure GetDefense; override;
    procedure GetResistance; override;
    procedure GetImmunityTypes; override;
    procedure GetHits; override;
    procedure GetHitPoints; override;
    procedure SetHitPoints(A1: Byte); override;
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    procedure fcRoundDistance; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure DestroyObject; override;
    procedure IDStr(A1: Integer); override;
    procedure Setup(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TCombatSide (instance size 28, VMT 55715DE4) }
  TCombatSide = class(TENode)
  public
    F_CombatSide_0C: Byte;
    F_CombatSide_0D: array[0..6] of Byte;
    F_CombatSide_14: Integer;
    F_CombatSide_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetObjects(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure GetDestroyedObjects;  { draft }
    procedure GetUndestroyedConquerObjects;  { draft }
    procedure OutputDebugInfo;  { draft }
    procedure UpdateSettings;  { draft }
  end;

  { TFastCombatCommand (instance size 28, VMT 55715EDC) }
  TFastCombatCommand = class(TObject)
  public
    F_FastCombatCommand_04: Integer;
    F_FastCombatCommand_08: array[0..15] of Byte;
    F_FastCombatCommand_18: Byte;
    F_FastCombatCommand_19: array[0..2] of Byte;
    procedure GetName(A1: Integer); virtual;  { +000 draft }
    constructor Create;  { draft }
  end;

  { TFastCombatCommandList (instance size 24, VMT 55715F60) }
  TFastCombatCommandList = class(TObject)
  public
    F_FastCombatCommandList_04: Integer;
    F_FastCombatCommandList_08: Integer;
    F_FastCombatCommandList_0C: Integer;
    F_FastCombatCommandList_10: Integer;
    F_FastCombatCommandList_14: Integer;
    destructor Destroy; override;
    constructor Create(A1: Integer; A2: Integer);  { draft }
    procedure Clear;  { draft }
    procedure GetCommands(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure Add;  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure Sort;  { draft }
  end;

  { TCombatViewer (instance size 28, VMT 55716040) }
  TCombatViewer = class(TObject)
  public
    F_CombatViewer_04: Byte;
    F_CombatViewer_05: array[0..2] of Byte;
    F_CombatViewer_08: Integer;
    F_CombatViewer_0C: Byte;
    F_CombatViewer_0D: array[0..2] of Byte;
    F_CombatViewer_10: Integer;
    F_CombatViewer_14: Integer;
    F_CombatViewer_18: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Initialize(A1: Integer);  { draft }
    procedure Finalize;  { draft }
    procedure GetEndPosition;  { draft }
    procedure SetSpeed(A1: Byte);  { draft }
    procedure SetPosition(A1: Integer);  { draft }
    procedure Play;  { draft }
    procedure Pause;  { draft }
    procedure Update;  { draft }
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DefaultShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
  end;

  { TCombatAction (instance size 12, VMT 557160B4) }
  TCombatAction = class(TEObject)
  public
    F_CombatAction_08: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure GetName(A1: Integer); virtual;  { +04C draft }
    procedure Execute(A1: Integer; A2: Integer); virtual; abstract;  { +050 draft }
    procedure Play(A1: Integer); virtual; abstract;  { +054 draft }
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { +058 draft }
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { +05C draft }
    procedure ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +060 draft }
  end;

  { TSingleTargetCA (instance size 16, VMT 557161CC) }
  TSingleTargetCA = class(TCombatAction)
  public
    F_SingleTargetCA_0C: Byte;
    F_SingleTargetCA_0D: Byte;
    F_SingleTargetCA_0E: Byte;
    F_SingleTargetCA_0F: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure GetDefensive;  { draft }
    procedure SetDefensive(A1: Byte);  { draft }
  end;

  { TDamageCA (instance size 24, VMT 557162F4) }
  TDamageCA = class(TSingleTargetCA)
  public
    F_DamageCA_10: Byte;
    F_DamageCA_11: Byte;
    F_DamageCA_12: array[0..0] of Byte;
    F_DamageCA_13: Byte;
    F_DamageCA_14: array[0..0] of Byte;
    F_DamageCA_15: Byte;
    F_DamageCA_16: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Setup(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer); virtual;  { +064 draft }
    procedure Generate(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +068 draft }
    procedure GenerateEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer); virtual;  { +06C draft }
  end;

  { TDamageEffectCA (instance size 20, VMT 557163D0) }
  TDamageEffectCA = class(TSingleTargetCA)
  public
    F_DamageEffectCA_10: Byte;
    F_DamageEffectCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
  end;

  { TUpdateHeaderCA (instance size 16, VMT 557164AC) }
  TUpdateHeaderCA = class(TCombatAction)
  public
    F_UpdateHeaderCA_0C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TNewCombatTurnCA (instance size 16, VMT 5571659C) }
  TNewCombatTurnCA = class(TCombatAction)
  public
    F_NewCombatTurnCA_0C: Byte;
    F_NewCombatTurnCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TNewCombatRoundCA (instance size 12, VMT 5571667C) }
  TNewCombatRoundCA = class(TCombatAction)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TCombatObjectTurnDoneCA (instance size 16, VMT 5571675C) }
  TCombatObjectTurnDoneCA = class(TCombatAction)
  public
    F_CombatObjectTurnDoneCA_0C: Byte;
    F_CombatObjectTurnDoneCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TMoveWallCA (instance size 16, VMT 55716880) }
  TMoveWallCA = class(TCombatAction)
  public
    F_MoveWallCA_0C: Byte;
    F_MoveWallCA_0D: Byte;
    F_MoveWallCA_0E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TFleeCA (instance size 16, VMT 55716954) }
  TFleeCA = class(TCombatAction)
  public
    F_FleeCA_0C: Byte;
    F_FleeCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TCombatActionList (instance size 12, VMT 55716A20) }
  TCombatActionList = class(TEReferenceNode)
  public
    procedure GetCombatActions(A1: Integer);  { draft }
  end;

  { TCombatParty (instance size 28, VMT 55716B24) }
  TCombatParty = class(TEObject)
  public
    F_CombatParty_08: Integer;
    F_CombatParty_0C: Integer;
    F_CombatParty_10: Integer;
    F_CombatParty_14: Integer;
    F_CombatParty_18: Byte;
    F_CombatParty_19: Byte;
    F_CombatParty_1A: Byte;
    F_CombatParty_1B: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Activate(A1: Integer);  { draft }
    procedure Deactivate;  { draft }
  end;

  { TCombatPartyList (instance size 12, VMT 55716BE4) }
  TCombatPartyList = class(TENode)
  public
    function GetControlStyle: Engine.TEControlStyles; override;
    procedure CreateParty(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);  { draft }
    procedure GetParty(A1: Integer);  { draft }
    procedure Activate(A1: Integer);  { draft }
    procedure Deactivate(A1: Integer);  { draft }
  end;

  { TCombatPlayer (instance size 12, VMT 55716CE8) }
  TCombatPlayer = class(TEObject)
  public
    F_CombatPlayer_08: Byte;
    F_CombatPlayer_09: Byte;
    F_CombatPlayer_0A: Byte;
    F_CombatPlayer_0B: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TCombatPlayerList (instance size 12, VMT 55716DA8) }
  TCombatPlayerList = class(TENode)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetPlayers(A1: Byte);  { draft }
    procedure IndexOfPlayer(A1: Byte);  { draft }
    procedure IndexOf(A1: Byte; A2: Byte);  { draft }
    procedure Delete(A1: Integer);  { draft }
  end;

  { TCombatData (instance size 84, VMT 55716EAC) }
  TCombatData = class(TEObject)
  public
    F_CombatData_08: Integer;
    F_CombatData_0C: Integer;
    F_CombatData_10: Integer;
    F_CombatData_14: Integer;
    F_CombatData_18: Integer;
    F_CombatData_1C: Integer;
    F_CombatData_20: array[0..1] of Byte;
    F_CombatData_22: Word;
    F_CombatData_24: Byte;
    F_CombatData_25: Byte;
    F_CombatData_26: array[0..1] of Byte;
    F_CombatData_28: Integer;
    F_CombatData_2C: Integer;
    F_CombatData_30: Byte;
    F_CombatData_31: Byte;
    F_CombatData_32: array[0..1] of Byte;
    F_CombatData_34: Integer;
    F_CombatData_38: Integer;
    F_CombatData_3C: Integer;
    F_CombatData_40: Integer;
    F_CombatData_44: Integer;
    F_CombatData_48: Integer;
    F_CombatData_4C: Byte;
    F_CombatData_4D: Byte;
    F_CombatData_4E: array[0..5] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetSideLeaderInvolved(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure GetObjects(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure FindID(A1: Integer);  { draft }
    procedure FindPosition(A1: Byte);  { draft }
    procedure AddObject(A1: Integer);  { draft }
  end;

  { TCombatLogbook (instance size 28, VMT 55716F7C) }
  TCombatLogbook = class(TEObject)
  public
    F_CombatLogbook_08: Integer;
    F_CombatLogbook_0C: Integer;
    F_CombatLogbook_10: Integer;
    F_CombatLogbook_14: Integer;
    F_CombatLogbook_18: array[0..0] of Byte;
    F_CombatLogbook_19: Byte;
    F_CombatLogbook_1A: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure SetInitialData;  { draft }
    procedure SetFinalData;  { draft }
  end;

  { TCombat (instance size 76, VMT 55717114) }
  TCombat = class(TEObject)
  public
    F_Combat_08: Byte;
    F_Combat_09: array[0..2] of Byte;
    F_Combat_0C: Integer;
    F_Combat_10: Integer;
    F_Combat_14: Byte;
    F_Combat_15: array[0..2] of Byte;
    F_Combat_18: Integer;
    F_Combat_1C: Integer;
    F_Combat_20: Integer;
    F_Combat_24: Integer;
    F_Combat_28: Integer;
    F_Combat_2C: Byte;
    F_Combat_2D: array[0..0] of Byte;
    F_Combat_2E: Word;
    F_Combat_30: Integer;
    F_Combat_34: Byte;
    F_Combat_35: array[0..2] of Byte;
    F_Combat_38: Byte;
    F_Combat_39: array[0..0] of Byte;
    F_Combat_3A: Word;
    F_Combat_3C: Integer;
    F_Combat_40: Byte;
    F_Combat_41: array[0..2] of Byte;
    F_Combat_44: Byte;
    F_Combat_45: array[0..6] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure UpdateStatus; virtual;  { +04C draft }
    procedure ObjectDestroyed(A1: Integer); virtual;  { +050 draft }
    procedure ObjectSideChanged(A1: Integer); virtual;  { +054 draft }
    function CreateCombatUnit: Integer; virtual;  { +058 draft }
    function CreateCombatPlayer: Integer; virtual;  { +05C draft }
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer); virtual;  { +060 draft }
    function Execute: Byte; virtual;  { +064 draft }
    procedure Initialize; virtual;  { +068 draft }
    procedure Finalize; virtual;  { +06C draft }
    procedure Activate; virtual;  { +070 draft }
    procedure Deactivate(A1: Integer; A2: Integer); virtual;  { +074 draft }
    procedure NewTurn(A1: Integer); virtual;  { +078 draft }
    procedure NewRound; virtual;  { +07C draft }
    procedure GetLogCombatActions;  { draft }
    procedure SetLogCombatActions(A1: Byte);  { draft }
    procedure GetRound;  { draft }
    procedure ExecuteCombatAction(A1: Integer);  { draft }
    procedure PlayerTypeInvolved(A1: Byte; A2: Integer);  { draft }
    procedure CreateUniqueCOID;  { draft }
    procedure UpdateSidesSettings;  { draft }
    procedure NextTurn;  { draft }
    procedure Terminate;  { draft }
    procedure CheckTerminate;  { draft }
    procedure SetLogbookHeader(A1: Integer; A2: Integer);  { draft }
    procedure AddAdjacentArmies;  { draft }
    procedure GetPartyPosition(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure AddCombatPlayer(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure AddArmy(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure AddArmyEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure AddEmptyArmy(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure InitDefaultArmies(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure LockExecuted;  { draft }
    procedure UnlockExecuted;  { draft }
    procedure GetCombatResultText(A1: Integer);  { draft }
    procedure DefendersAvailable;  { draft }
  end;

  { TCombatEventLog (instance size 28, VMT 557171FC) }
  TCombatEventLog = class(TEventLog)
  public
    F_CombatEventLog_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure GetTextColor; override;
    procedure GetLeftIcon; override;
    procedure GetMiddleIcon; override;
    procedure GetRightIcon; override;
    procedure PlayLoggedSFX(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
    procedure SetCombatLogbook(A1: Integer);  { draft }
  end;

  { TCombatTypeRequestEventLog (instance size 44, VMT 557172EC) }
  TCombatTypeRequestEventLog = class(TEventLog)
  public
    F_CombatTypeRequestEventLog_18: Byte;
    F_CombatTypeRequestEventLog_19: Byte;
    F_CombatTypeRequestEventLog_1A: Byte;
    F_CombatTypeRequestEventLog_1B: Byte;
    F_CombatTypeRequestEventLog_1C: Byte;
    F_CombatTypeRequestEventLog_1D: Byte;
    F_CombatTypeRequestEventLog_1E: array[0..1] of Byte;
    F_CombatTypeRequestEventLog_20: Byte;
    F_CombatTypeRequestEventLog_21: array[0..2] of Byte;
    F_CombatTypeRequestEventLog_24: Byte;
    F_CombatTypeRequestEventLog_25: array[0..2] of Byte;
    F_CombatTypeRequestEventLog_28: Integer;
    destructor Destroy; override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure SetTokenEvent(A1: Integer);  { draft }
    procedure Select(A1: Byte);  { draft }
    procedure SetCenterLocation(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TAIPlayerAction (instance size 20, VMT 55717458) }
  TAIPlayerAction = class(TEObject)
  public
    F_AIPlayerAction_08: Integer;
    F_AIPlayerAction_0C: Integer;
    F_AIPlayerAction_10: Byte;
    F_AIPlayerAction_11: array[0..2] of Byte;
    procedure Priority; virtual; abstract;  { +04C draft }
    procedure SupportedPhases; virtual;  { +050 draft }
    procedure Setup(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure Deactivate; virtual;  { +05C draft }
    procedure Process(A1: Integer; A2: Integer); virtual;  { +060 draft }
  end;

  { TAIPlayerActionList (instance size 12, VMT 55717534) }
  TAIPlayerActionList = class(TENode)
  public
    procedure GetActions(A1: Integer);  { draft }
    procedure IndexOf;  { draft }
  end;

  { TAIPlayerActionManager (instance size 12, VMT 5571763C) }
  TAIPlayerActionManager = class(TEObject)
  public
    F_AIPlayerActionManager_08: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    procedure GetRegisteredClasses(A1: Integer);  { draft }
    procedure RegisterClasses(A1: Integer; A2: Integer);  { draft }
    procedure UnRegisterClasses(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIGroupList (instance size 12, VMT 55717710) }
  TAIGroupList = class(TENode)
  public
    procedure GetGroups(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure FindID;  { draft }
    procedure SortOnProcessPriority;  { draft }
  end;

  { TAIPlayerControl (instance size 40, VMT 5571780C) }
  TAIPlayerControl = class(TEObject)
  public
    F_AIPlayerControl_08: Integer;
    F_AIPlayerControl_0C: Integer;
    F_AIPlayerControl_10: Integer;
    F_AIPlayerControl_14: Integer;
    F_AIPlayerControl_18: Integer;
    F_AIPlayerControl_1C: Integer;
    F_AIPlayerControl_20: Byte;
    F_AIPlayerControl_21: array[0..2] of Byte;
    F_AIPlayerControl_24: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure ListAvailableTransporters(A1: Integer);  { draft }
    procedure UnitIndexToPriority(A1: Integer);  { draft }
    procedure Reset;  { draft }
    procedure SetupProcessPhase(A1: Integer);  { draft }
    procedure GetProcessCyclesMax;  { draft }
    procedure Activate(A1: Integer; A2: Integer);  { draft }
    procedure Deactivate;  { draft }
    procedure GetRandomGroupBehavior;  { draft }
    procedure UpdateSkirmishGroups;  { draft }
    procedure ActivateAction(A1: Integer);  { draft }
    procedure DeactivateAction;  { draft }
    procedure ListPeaceWarUnknownPlayers(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ListIdealPeaceWarPlayers(A1: Integer; A2: Integer);  { draft }
    procedure CanOfferPeace(A1: Integer);  { draft }
    procedure CanDeclareWar(A1: Integer);  { draft }
    procedure CanProposeAlliance(A1: Integer; A2: Integer);  { draft }
    procedure Process(A1: Integer);  { draft }
  end;

  { TAIExecuter (instance size 52, VMT 55717968) }
  TAIExecuter = class(TEObject)
  public
    F_AIExecuter_08: Integer;
    F_AIExecuter_0C: Integer;
    F_AIExecuter_10: Byte;
    F_AIExecuter_11: array[0..2] of Byte;
    F_AIExecuter_14: Integer;
    F_AIExecuter_18: Byte;
    F_AIExecuter_19: Byte;
    F_AIExecuter_1A: Byte;
    F_AIExecuter_1B: array[0..0] of Byte;
    F_AIExecuter_1C: Integer;
    F_AIExecuter_20: Integer;
    F_AIExecuter_24: Integer;
    F_AIExecuter_28: Integer;
    F_AIExecuter_2C: Integer;
    F_AIExecuter_30: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure RequestProcessTime(A1: Integer);  { draft }
    procedure GetProcessTimeLeft;  { draft }
    procedure GetProcessTimeElapsed;  { draft }
    procedure UseProcessTime(A1: Integer);  { draft }
    procedure ActivatePlayer(A1: Integer);  { draft }
    procedure DeactivatePlayer(A1: Integer);  { draft }
    procedure TokenControlDoneEvent;  { draft }
    procedure Lock;  { draft }
    procedure Unlock;  { draft }
    procedure CaptureTokenCycles(A1: Integer);  { draft }
    procedure TokenCyclesCaptured;  { draft }
    procedure Process(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIMoveControlSettings (instance size 360, VMT 55717A78) }
  TAIMoveControlSettings = class(TEObject)
  public
    F_AIMoveControlSettings_08: Integer;
    F_AIMoveControlSettings_0C: Byte;
    F_AIMoveControlSettings_0D: array[0..2] of Byte;
    F_AIMoveControlSettings_10: Integer;
    F_AIMoveControlSettings_14: Integer;
    F_AIMoveControlSettings_18: Integer;
    F_AIMoveControlSettings_1C: Integer;
    F_AIMoveControlSettings_20: Integer;
    F_AIMoveControlSettings_24: Integer;
    F_AIMoveControlSettings_28: Byte;
    F_AIMoveControlSettings_29: array[0..254] of Byte;
    F_AIMoveControlSettings_128: Byte;
    F_AIMoveControlSettings_129: array[0..2] of Byte;
    F_AIMoveControlSettings_12C: Byte;
    F_AIMoveControlSettings_12D: array[0..2] of Byte;
    F_AIMoveControlSettings_130: Integer;
    F_AIMoveControlSettings_134: Integer;
    F_AIMoveControlSettings_138: Integer;
    F_AIMoveControlSettings_13C: Byte;
    F_AIMoveControlSettings_13D: array[0..2] of Byte;
    F_AIMoveControlSettings_140: Byte;
    F_AIMoveControlSettings_141: array[0..2] of Byte;
    F_AIMoveControlSettings_144: Integer;
    F_AIMoveControlSettings_148: Integer;
    F_AIMoveControlSettings_14C: array[0..3] of Byte;
    F_AIMoveControlSettings_150: Integer;
    F_AIMoveControlSettings_154: Integer;
    F_AIMoveControlSettings_158: Byte;
    F_AIMoveControlSettings_159: array[0..2] of Byte;
    F_AIMoveControlSettings_15C: Byte;
    F_AIMoveControlSettings_15D: array[0..2] of Byte;
    F_AIMoveControlSettings_160: Byte;
    F_AIMoveControlSettings_161: array[0..3] of Byte;
    F_AIMoveControlSettings_165: Byte;
    F_AIMoveControlSettings_166: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure SetSourcePos(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetDestinationPos(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { TAIMoveControl (instance size 544, VMT 55717B94) }
  TAIMoveControl = class(TEObject)
  public
    F_AIMoveControl_08: Byte;
    F_AIMoveControl_09: array[0..2] of Byte;
    F_AIMoveControl_0C: Integer;
    F_AIMoveControl_10: Integer;
    F_AIMoveControl_14: Byte;
    F_AIMoveControl_15: Byte;
    F_AIMoveControl_16: array[0..253] of Byte;
    F_AIMoveControl_114: Byte;
    F_AIMoveControl_115: Byte;
    F_AIMoveControl_116: array[0..253] of Byte;
    F_AIMoveControl_214: Byte;
    F_AIMoveControl_215: Byte;
    F_AIMoveControl_216: array[0..1] of Byte;
    F_AIMoveControl_218: Integer;
    F_AIMoveControl_21C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure ProcessingDone(A1: Byte);  { draft }
    procedure ProcessCanMove;  { draft }
    procedure SelectCombinedTransporterArmyMpT(A1: Integer);  { draft }
    procedure CalculateTransportGaps(A1: Integer; A2: Integer);  { draft }
    procedure ProcessTransporterCanMove(A1: Integer; A2: Integer);  { draft }
    procedure Initialize(A1: Integer);  { draft }
    procedure CanMove(A1: Integer);  { draft }
    procedure Cancel;  { draft }
    procedure Reset;  { draft }
    procedure Process;  { draft }
  end;

  { TMoveTarget (instance size 52, VMT 55717C58) }
  TMoveTarget = class(TEObject)
  public
    F_MoveTarget_08: Integer;
    F_MoveTarget_0C: array[0..35] of Byte;
    F_MoveTarget_30: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
  end;

  { TMoveTargetList (instance size 12, VMT 55717D14) }
  TMoveTargetList = class(TEReferenceNode)
  public
    procedure GetTarget(A1: Integer);  { draft }
    procedure IndexOfXYL(A1: Integer);  { draft }
    procedure AddTargetEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure SortOnMovePoints;  { draft }
  end;

  { TAIMoveTargetSelector (instance size 592, VMT 55717F10) }
  TAIMoveTargetSelector = class(TEObject)
  public
    F_AIMoveTargetSelector_08: Integer;
    F_AIMoveTargetSelector_0C: Integer;
    F_AIMoveTargetSelector_10: Byte;
    F_AIMoveTargetSelector_11: array[0..2] of Byte;
    F_AIMoveTargetSelector_14: Integer;
    F_AIMoveTargetSelector_18: Byte;
    F_AIMoveTargetSelector_19: array[0..2] of Byte;
    F_AIMoveTargetSelector_1C: Integer;
    F_AIMoveTargetSelector_20: Integer;
    F_AIMoveTargetSelector_24: Integer;
    F_AIMoveTargetSelector_28: Integer;
    F_AIMoveTargetSelector_2C: Byte;
    F_AIMoveTargetSelector_2D: Byte;
    F_AIMoveTargetSelector_2E: array[0..253] of Byte;
    F_AIMoveTargetSelector_12C: Integer;
    F_AIMoveTargetSelector_130: Byte;
    F_AIMoveTargetSelector_131: Byte;
    F_AIMoveTargetSelector_132: array[0..9] of Byte;
    F_AIMoveTargetSelector_13C: Byte;
    F_AIMoveTargetSelector_13D: Byte;
    F_AIMoveTargetSelector_13E: array[0..253] of Byte;
    F_AIMoveTargetSelector_23C: Integer;
    F_AIMoveTargetSelector_240: Integer;
    F_AIMoveTargetSelector_244: Integer;
    F_AIMoveTargetSelector_248: Integer;
    F_AIMoveTargetSelector_24C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetTransporter(A1: Integer);  { draft }
    procedure Reset(A1: Integer; A2: Integer);  { draft }
    procedure SetupArmy(A1: Integer; A2: Integer);  { draft }
    procedure SetupTransport(A1: Integer; A2: Byte);  { draft }
    procedure Done;  { draft }
    procedure TriggerTargetFound(A1: Integer; A2: Integer);  { draft }
    procedure ProcessBufferedTargets;  { draft }
    procedure ProcessBufferedTransportTargets(A1: Integer; A2: Integer);  { draft }
    procedure ProcessStates(A1: Integer);  { draft }
    procedure Process(A1: Integer; A2: Integer);  { draft }
    procedure Search(A1: Integer);  { draft }
  end;

  { TAIMoveExecuterUnit (instance size 56, VMT 5571819C) }
  TAIMoveExecuterUnit = class(TEObject)
  public
    F_AIMoveExecuterUnit_08: Integer;
    F_AIMoveExecuterUnit_0C: Integer;
    F_AIMoveExecuterUnit_10: Byte;
    F_AIMoveExecuterUnit_11: Byte;
    F_AIMoveExecuterUnit_12: Byte;
    F_AIMoveExecuterUnit_13: Byte;
    F_AIMoveExecuterUnit_14: Byte;
    F_AIMoveExecuterUnit_15: Byte;
    F_AIMoveExecuterUnit_16: Byte;
    F_AIMoveExecuterUnit_17: Byte;
    F_AIMoveExecuterUnit_18: Byte;
    F_AIMoveExecuterUnit_19: Byte;
    F_AIMoveExecuterUnit_1A: Byte;
    F_AIMoveExecuterUnit_1B: Byte;
    F_AIMoveExecuterUnit_1C: array[0..7] of Byte;
    F_AIMoveExecuterUnit_24: Byte;
    F_AIMoveExecuterUnit_25: array[0..2] of Byte;
    F_AIMoveExecuterUnit_28: Byte;
    F_AIMoveExecuterUnit_29: array[0..2] of Byte;
    F_AIMoveExecuterUnit_2C: Byte;
    F_AIMoveExecuterUnit_2D: array[0..2] of Byte;
    F_AIMoveExecuterUnit_30: Byte;
    F_AIMoveExecuterUnit_31: array[0..2] of Byte;
    F_AIMoveExecuterUnit_34: Byte;
    F_AIMoveExecuterUnit_35: Byte;
    F_AIMoveExecuterUnit_36: array[0..1] of Byte;
    procedure Initialize(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure Validate;  { draft }
    procedure ResetTransporterSettings;  { draft }
  end;

  { TAIMoveExecuterUnitList (instance size 12, VMT 55718268) }
  TAIMoveExecuterUnitList = class(TENode)
  public
    procedure GetUnits(A1: Integer);  { draft }
    procedure IndexOfUnitID(A1: Integer);  { draft }
    procedure IndexOfUnit(A1: Integer);  { draft }
    procedure FindStatusUnit(A1: Integer);  { draft }
    procedure ValidateSelection(A1: Byte);  { draft }
    procedure SelectionCount;  { draft }
    procedure Transporter(A1: Integer; A2: Integer);  { draft }
    procedure SetMoveResult(A1: Integer; A2: Integer);  { draft }
    procedure SetTransportStatus(A1: Integer; A2: Integer);  { draft }
    procedure SetStatus(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIMoveExecuterArmy (instance size 48, VMT 55718378) }
  TAIMoveExecuterArmy = class(TAIMoveExecuterUnitList)
  public
    F_AIMoveExecuterArmy_0C: Integer;
    F_AIMoveExecuterArmy_10: Integer;
    F_AIMoveExecuterArmy_14: Byte;
    F_AIMoveExecuterArmy_15: array[0..2] of Byte;
    F_AIMoveExecuterArmy_18: Integer;
    F_AIMoveExecuterArmy_1C: Integer;
    F_AIMoveExecuterArmy_20: Integer;
    F_AIMoveExecuterArmy_24: Integer;
    F_AIMoveExecuterArmy_28: Byte;
    F_AIMoveExecuterArmy_29: Byte;
    F_AIMoveExecuterArmy_2A: array[0..5] of Byte;
    procedure Setup(A1: Integer);  { draft }
    procedure CanAdd(A1: Integer);  { draft }
    procedure RetrieveArmy(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ResetTransporterSettings;  { draft }
    procedure WaitingForTransport;  { draft }
    procedure Moves(A1: Integer; A2: Integer);  { draft }
    procedure MovePoints(A1: Integer; A2: Integer);  { draft }
    procedure ValidTerrain(A1: Integer; A2: Byte; A3: Integer);  { draft }
  end;

  { TAIMoveExecuterArmyList (instance size 12, VMT 55718480) }
  TAIMoveExecuterArmyList = class(TENode)
  public
    procedure GetArmies(A1: Integer);  { draft }
    procedure IndexOf(A1: Integer; A2: Byte);  { draft }
    procedure IndexOfXYL(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure IndexOfLoc(A1: Integer; A2: Integer);  { draft }
    procedure IndexOfTransportStatus(A1: Integer);  { draft }
    procedure SortOnMovePoints;  { draft }
  end;

  { TAIMoveExecuterMove (instance size 32, VMT 55718590) }
  TAIMoveExecuterMove = class(TAIMoveExecuterUnitList)
  public
    F_AIMoveExecuterMove_0C: Integer;
    F_AIMoveExecuterMove_10: Integer;
    F_AIMoveExecuterMove_14: Integer;
    F_AIMoveExecuterMove_18: Byte;
    F_AIMoveExecuterMove_19: Byte;
    F_AIMoveExecuterMove_1A: Byte;
    F_AIMoveExecuterMove_1B: Byte;
    F_AIMoveExecuterMove_1C: Byte;
    F_AIMoveExecuterMove_1D: Byte;
    F_AIMoveExecuterMove_1E: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AddUnits(A1: Integer; A2: Integer);  { draft }
    procedure AddUnit;  { draft }
    procedure SetUnitStatus(A1: Integer);  { draft }
    procedure RetrieveArmy(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIMoveExecuterMoveQueue (instance size 12, VMT 55718698) }
  TAIMoveExecuterMoveQueue = class(TENode)
  public
    procedure Clear; override;
    procedure GetMoves(A1: Integer);  { draft }
    procedure Reset;  { draft }
  end;

  { TAIMoveExecuterControl (instance size 20, VMT 55718868) }
  TAIMoveExecuterControl = class(TEObject)
  public
    F_AIMoveExecuterControl_08: Integer;
    F_AIMoveExecuterControl_0C: Integer;
    F_AIMoveExecuterControl_10: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateMove(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { +04C draft }
    procedure CanMoveTo(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer); virtual;  { +050 draft }
    procedure CalculateMoves(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure Activate(A1: Integer); virtual;  { +058 draft }
    procedure Deactivate; virtual;  { +05C draft }
    procedure Done; virtual;  { +060 draft }
    procedure Process; virtual;  { +064 draft }
  end;

  { TDefaultMEC (instance size 20, VMT 55718958) }
  TDefaultMEC = class(TAIMoveExecuterControl)
  public
    procedure CalculateMoves(A1: Integer; A2: Integer); override;
  end;

  { TAdjacentArmy (instance size 24, VMT 55718A30) }
  TAdjacentArmy = class(TEObject)
  public
    F_AdjacentArmy_08: array[0..3] of Byte;
    F_AdjacentArmy_0C: Integer;
    F_AdjacentArmy_10: array[0..3] of Byte;
    F_AdjacentArmy_14: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetMovementDays;  { draft }
  end;

  { TAdjacentArmyList (instance size 12, VMT 55718AF0) }
  TAdjacentArmyList = class(TENode)
  public
    procedure GetAdjacentArmies(A1: Integer);  { draft }
    procedure IndexOfLoc(A1: Integer; A2: Integer);  { draft }
    procedure GetSlowestArmy;  { draft }
    procedure GetAdjacent;  { draft }
  end;

  { TAdjacentMEC (instance size 28, VMT 55718BF4) }
  TAdjacentMEC = class(TAIMoveExecuterControl)
  public
    F_AdjacentMEC_14: Integer;
    F_AdjacentMEC_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CalculateMoves(A1: Integer; A2: Integer); override;
    procedure ExecuteSurroundMove;  { draft }
    procedure CalculateMeetingPoint;  { draft }
    procedure ExecuteMeetingPointMove;  { draft }
  end;

  { TTransportMEC (instance size 24, VMT 55718CD0) }
  TTransportMEC = class(TAIMoveExecuterControl)
  public
    F_TransportMEC_14: Integer;
    procedure CalculateMoves(A1: Integer; A2: Integer); override;
    procedure Done; override;
    procedure CreateTransporterMove(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure TransportDone;  { draft }
    procedure DumpTransportUnits(A1: Integer);  { draft }
    procedure UpdateTransportMeetingPoint;  { draft }
    procedure CalculateTransportPathCallBack;  { draft }
  end;

  { TAIMoveExecuter (instance size 60, VMT 55718E18) }
  TAIMoveExecuter = class(TEObject)
  public
    F_AIMoveExecuter_08: Integer;
    F_AIMoveExecuter_0C: Integer;
    F_AIMoveExecuter_10: Integer;
    F_AIMoveExecuter_14: Integer;
    F_AIMoveExecuter_18: Integer;
    F_AIMoveExecuter_1C: Integer;
    F_AIMoveExecuter_20: Integer;
    F_AIMoveExecuter_24: Byte;
    F_AIMoveExecuter_25: array[0..2] of Byte;
    F_AIMoveExecuter_28: Integer;
    F_AIMoveExecuter_2C: Byte;
    F_AIMoveExecuter_2D: Byte;
    F_AIMoveExecuter_2E: array[0..1] of Byte;
    F_AIMoveExecuter_30: Integer;
    F_AIMoveExecuter_34: Integer;
    F_AIMoveExecuter_38: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure ActivateMEC(A1: Integer);  { draft }
    procedure DeactivateMEC;  { draft }
    procedure AddUnit(A1: Integer; A2: Integer);  { draft }
    procedure AddUnits(A1: Integer);  { draft }
    procedure AddArmy(A1: Integer; A2: Integer);  { draft }
    procedure AddTransporter(A1: Integer; A2: Integer);  { draft }
    procedure InvalidateMove;  { draft }
    procedure Reset;  { draft }
    procedure Validate;  { draft }
    procedure CreateArmies(A1: Byte);  { draft }
    procedure FinishMoves;  { draft }
    procedure ExecuteMoves;  { draft }
    procedure UnitsMoveDone;  { draft }
    procedure GetTransporting;  { draft }
    procedure UpdateMoveResult;  { draft }
    procedure ProcessExecuteMoves;  { draft }
    procedure ProcessMECS;  { draft }
    procedure Process;  { draft }
    procedure SetupTransporter(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteMove(A1: Byte; A2: Integer; A3: Integer);  { draft }
  end;

  { TEndTurnAIPA (instance size 20, VMT 55718EDC) }
  TEndTurnAIPA = class(TAIPlayerAction)
  public
    destructor Destroy; override;
    procedure Priority; override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TInitializeAIPA (instance size 20, VMT 55718FB4) }
  TInitializeAIPA = class(TAIPlayerAction)
  public
    procedure Priority; override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TGroupControlAIPA (instance size 28, VMT 55719090) }
  TGroupControlAIPA = class(TAIPlayerAction)
  public
    F_GroupControlAIPA_14: Integer;
    F_GroupControlAIPA_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ActivateGroupControl(A1: Integer);  { draft }
    procedure DeactivateGroupControl;  { draft }
  end;

  { TGroupControlLoopAIPA (instance size 28, VMT 55719170) }
  TGroupControlLoopAIPA = class(TAIPlayerAction)
  public
    F_GroupControlLoopAIPA_14: Integer;
    F_GroupControlLoopAIPA_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    procedure SupportedPhases; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ActivateGroupControl(A1: Integer);  { draft }
    procedure DeactivateGroupControl;  { draft }
  end;

  { TAIBudget (instance size 56, VMT 55719258) }
  TAIBudget = class(TEObject)
  public
    F_AIBudget_08: Integer;
    F_AIBudget_0C: Integer;
    F_AIBudget_10: Integer;
    F_AIBudget_14: Integer;
    F_AIBudget_18: Integer;
    F_AIBudget_1C: Integer;
    F_AIBudget_20: Integer;
    F_AIBudget_24: Integer;
    F_AIBudget_28: Integer;
    F_AIBudget_2C: Integer;
    F_AIBudget_30: Integer;
    F_AIBudget_34: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetReady; virtual;  { +04C draft }
    procedure OutputDebugInfo; virtual;  { +050 draft }
    procedure Done; virtual;  { +054 draft }
    procedure UpdateDayRequirements; virtual;  { +058 draft }
  end;

  { TAISavingsBudget (instance size 56, VMT 55719320) }
  TAISavingsBudget = class(TAIBudget)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAITransporterBudget (instance size 56, VMT 557193F8) }
  TAITransporterBudget = class(TAIBudget)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAIBudgetList (instance size 12, VMT 557194D8) }
  TAIBudgetList = class(TENode)
  public
    procedure GetBudgets(A1: Integer);  { draft }
  end;

  { TAIBudgetManager (instance size 60, VMT 55719628) }
  TAIBudgetManager = class(TEObject)
  public
    F_AIBudgetManager_08: Integer;
    F_AIBudgetManager_0C: Integer;
    F_AIBudgetManager_10: Integer;
    F_AIBudgetManager_14: Integer;
    F_AIBudgetManager_18: Integer;
    F_AIBudgetManager_1C: Integer;
    F_AIBudgetManager_20: Integer;
    F_AIBudgetManager_24: Integer;
    F_AIBudgetManager_28: Integer;
    F_AIBudgetManager_2C: Integer;
    F_AIBudgetManager_30: Integer;
    F_AIBudgetManager_34: Integer;
    F_AIBudgetManager_38: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetBudgetGoldUpkeep;  { draft }
    procedure GetBudgetManaUpkeep;  { draft }
    procedure GetReservedBudgetGold;  { draft }
    procedure GetReservedBudgetMana;  { draft }
    procedure GetRequiredBudgetDayGold;  { draft }
    procedure GetRequiredBudgetDayMana;  { draft }
    procedure UpdateBudgetDayRequirements;  { draft }
    procedure UpdateProductionUpkeep;  { draft }
    procedure GetGroupsGoldBudget;  { draft }
    procedure GetGroupsManaBudget;  { draft }
    procedure ReserveForBudgets(A1: Integer; A2: Integer);  { draft }
    procedure ReturnFromBudgets(A1: Integer; A2: Integer);  { draft }
    procedure ValidateReservations;  { draft }
    procedure OutputDebugInfo;  { draft }
    procedure ValidateManaUpkeep;  { draft }
    procedure UpdateBudgets;  { draft }
    procedure RequestProductionExpense(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure RequestProductionExpenseEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ProductionExpenseMade(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure RequestBudgetExpense(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure BudgetExpenseMade(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure RequestBudgetExpenseEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure BudgetExpenseMadeEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure RequestExpense(A1: Integer; A2: Integer);  { draft }
    procedure ExpenseMade(A1: Integer; A2: Integer);  { draft }
    procedure ReturnExpense(A1: Integer; A2: Integer);  { draft }
  end;

  { TBudgetManagerAIPA (instance size 20, VMT 557196F0) }
  TBudgetManagerAIPA = class(TAIPlayerAction)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TAutoProduceAIPA (instance size 40, VMT 557197D4) }
  TAutoProduceAIPA = class(TAIPlayerAction)
  public
    F_AutoProduceAIPA_14: Integer;
    F_AutoProduceAIPA_18: Integer;
    F_AutoProduceAIPA_1C: Integer;
    F_AutoProduceAIPA_20: Integer;
    F_AutoProduceAIPA_24: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure UpdateProductions(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteProduce(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteResearch(A1: Integer; A2: Integer);  { draft }
    procedure TransporterPriority;  { draft }
    procedure ResearchTransporter(A1: Integer);  { draft }
    procedure ProduceTransporter(A1: Integer);  { draft }
    procedure FindAvailableTransporter;  { draft }
    procedure TransporterProductionControlExists;  { draft }
    procedure ProducingTransporter;  { draft }
    procedure ResearchingTransporter;  { draft }
  end;

  { TProcessEventlogAIPA (instance size 24, VMT 557198B4) }
  TProcessEventlogAIPA = class(TAIPlayerAction)
  public
    F_ProcessEventlogAIPA_14: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TStructureAIPA (instance size 28, VMT 5571999C) }
  TStructureAIPA = class(TAIPlayerAction)
  public
    F_StructureAIPA_14: Integer;
    F_StructureAIPA_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TStructurePhase1AIPA (instance size 28, VMT 55719A78) }
  TStructurePhase1AIPA = class(TStructureAIPA)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
  end;

  { TStructurePhase2AIPA (instance size 28, VMT 55719B60) }
  TStructurePhase2AIPA = class(TStructureAIPA)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
  end;

  { TAIGroupProduction (instance size 16, VMT 55719DDC) }
  TAIGroupProduction = class(TEObject)
  public
    F_AIGroupProduction_08: array[0..7] of Byte;
  end;

  { TAIGroupProductionList (instance size 12, VMT 55719EA8) }
  TAIGroupProductionList = class(TENode)
  public
    procedure GetProductions(A1: Integer);  { draft }
    procedure GetStrengthMax(A1: Word; A2: Integer);  { draft }
    procedure Add(A1: Integer; A2: Integer);  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure DeleteUnit;  { draft }
    procedure ChangeGroup(A1: Integer; A2: Integer);  { draft }
    procedure IndexOfU(A1: Integer);  { draft }
  end;

  { TAIGroup (instance size 80, VMT 55719FB8) }
  TAIGroup = class(TUnitUserList)
  public
    F_AIGroup_10: Byte;
    F_AIGroup_11: array[0..2] of Byte;
    F_AIGroup_14: Integer;
    F_AIGroup_18: array[0..3] of Byte;
    F_AIGroup_1C: Integer;
    F_AIGroup_20: Integer;
    F_AIGroup_24: Integer;
    F_AIGroup_28: Byte;
    F_AIGroup_29: array[0..2] of Byte;
    F_AIGroup_2C: Integer;
    F_AIGroup_30: Integer;
    F_AIGroup_34: Byte;
    F_AIGroup_35: array[0..2] of Byte;
    F_AIGroup_38: Integer;
    F_AIGroup_3C: Byte;
    F_AIGroup_3D: array[0..2] of Byte;
    F_AIGroup_40: Integer;
    F_AIGroup_44: Integer;
    F_AIGroup_48: Integer;
    F_AIGroup_4C: Byte;
    F_AIGroup_4D: Byte;
    F_AIGroup_4E: Byte;
    F_AIGroup_4F: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure AddUnit(A1: Integer); override;
    procedure DeleteUnit(A1: Integer); override;
    procedure AddUnits(A1: Integer); override;
    procedure GetGoldBudget; virtual;  { +0B8 draft }
    procedure GetManaBudget; virtual;  { +0BC draft }
    procedure GetLoc(A1: Integer; A2: Integer); virtual;  { +0C0 draft }
    procedure GroupControlClass; virtual;  { +0C4 draft }
    procedure NewTurn(A1: Byte); virtual;  { +0C8 draft }
    procedure CreateGroupControl; virtual;  { +0CC draft }
    procedure Behavior; virtual;  { +0D0 draft }
    procedure DefendLocation(A1: Integer); virtual;  { +0D4 draft }
    procedure CooperateWithGroup(A1: Integer); virtual;  { +0D8 draft }
    procedure GetRecruitableUnits(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0DC draft }
    procedure GetProcessPriority;  { draft }
    procedure GetAdjacent(A1: Integer; A2: Integer);  { draft }
    procedure SetLeader(A1: Integer);  { draft }
    procedure GetMovePointsMin;  { draft }
    procedure GetMovesMin;  { draft }
    procedure ResetTargetExpense;  { draft }
    procedure ReturnTargetExpense;  { draft }
    procedure RequestTargetExpense(A1: Integer; A2: Integer);  { draft }
    procedure MakeTargetExpense(A1: Integer; A2: Integer);  { draft }
    procedure SetupTargetEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);  { draft }
    procedure SetupTarget(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ValidateEmpty;  { draft }
    procedure AddTransporter(A1: Integer);  { draft }
    procedure UnitProduced(A1: Integer; A2: Integer);  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
    procedure SetPlayer(A1: Integer);  { draft }
  end;

  { TAIGroupManager (instance size 20, VMT 5571A104) }
  TAIGroupManager = class(TAIGroupList)
  public
    F_AIGroupManager_0C: Integer;
    F_AIGroupManager_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure RegisterAIGroupClasses(A1: Integer; A2: Integer);  { draft }
    procedure UnregisterAIGroupClasses(A1: Integer; A2: Integer);  { draft }
    procedure CreateGroup(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure CreateUniqueID;  { draft }
  end;

  { TAIGroupControlTarget (instance size 76, VMT 5571A280) }
  TAIGroupControlTarget = class(TEObject)
  public
    F_AIGroupControlTarget_08: Integer;
    F_AIGroupControlTarget_0C: Byte;
    F_AIGroupControlTarget_0D: array[0..10] of Byte;
    F_AIGroupControlTarget_18: Integer;
    F_AIGroupControlTarget_1C: Byte;
    F_AIGroupControlTarget_1D: array[0..2] of Byte;
    F_AIGroupControlTarget_20: Integer;
    F_AIGroupControlTarget_24: array[0..11] of Byte;
    F_AIGroupControlTarget_30: Integer;
    F_AIGroupControlTarget_34: Integer;
    F_AIGroupControlTarget_38: Integer;
    F_AIGroupControlTarget_3C: Byte;
    F_AIGroupControlTarget_3D: array[0..2] of Byte;
    F_AIGroupControlTarget_40: Integer;
    F_AIGroupControlTarget_44: Integer;
    F_AIGroupControlTarget_48: array[0..3] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate(A1: Integer); virtual;  { +04C draft }
    procedure GetTargetGold;  { draft }
    procedure GetTargetMana;  { draft }
    procedure GetDebugInfo(A1: Integer);  { draft }
  end;

  { TAIGroupControlTargetList (instance size 16, VMT 5571A354) }
  TAIGroupControlTargetList = class(TEReferenceNode)
  public
    F_AIGroupControlTargetList_0C: Integer;
    procedure GetTargets(A1: Integer);  { draft }
    procedure SortOnPriority;  { draft }
    procedure SortOnDataB;  { draft }
    procedure Add;  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure Validate;  { draft }
    procedure IndexOfXYL(A1: Integer);  { draft }
  end;

  { TAIRecruitmentGroup (instance size 40, VMT 5571A468) }
  TAIRecruitmentGroup = class(TEObject)
  public
    F_AIRecruitmentGroup_08: Integer;
    F_AIRecruitmentGroup_0C: Integer;
    F_AIRecruitmentGroup_10: Integer;
    F_AIRecruitmentGroup_14: Integer;
    F_AIRecruitmentGroup_18: Integer;
    F_AIRecruitmentGroup_1C: Integer;
    F_AIRecruitmentGroup_20: array[0..7] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate(A1: Integer; A2: Integer); virtual;  { +04C draft }
    procedure SetGroup(A1: Integer);  { draft }
  end;

  { TAIRecruitmentGroupList (instance size 12, VMT 5571A538) }
  TAIRecruitmentGroupList = class(TEReferenceNode)
  public
    procedure GetRecruitmentGroups(A1: Integer);  { draft }
    procedure SortOnMovePoints;  { draft }
    procedure OutputDebugInfo;  { draft }
    procedure Add;  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure Validate(A1: Integer; A2: Integer);  { draft }
    procedure UnitExists(A1: Integer);  { draft }
    procedure FindUnit(A1: Integer);  { draft }
  end;

  { TAIGroupProductionLocation (instance size 40, VMT 5571A648) }
  TAIGroupProductionLocation = class(TEObject)
  public
    F_AIGroupProductionLocation_08: Integer;
    F_AIGroupProductionLocation_0C: array[0..27] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate; virtual;  { +04C draft }
  end;

  { TAIGroupProductionLocationList (instance size 12, VMT 5571A728) }
  TAIGroupProductionLocationList = class(TEReferenceNode)
  public
    procedure GetProductionLocation(A1: Integer);  { draft }
    procedure SortOnMovePoints;  { draft }
    procedure Add;  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure IndexOfPC(A1: Integer);  { draft }
    procedure FindPC;  { draft }
    procedure Validate(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIGroupControlPlugin (instance size 28, VMT 5571A894) }
  TAIGroupControlPlugin = class(TEObject)
  public
    F_AIGroupControlPlugin_08: Integer;
    F_AIGroupControlPlugin_0C: Integer;
    F_AIGroupControlPlugin_10: Integer;
    F_AIGroupControlPlugin_14: Byte;
    F_AIGroupControlPlugin_15: array[0..2] of Byte;
    F_AIGroupControlPlugin_18: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate; virtual;  { +04C draft }
    procedure GetBusy; virtual;  { +050 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure Deactivate; virtual;  { +058 draft }
    procedure Process(A1: Integer; A2: Integer); virtual;  { +05C draft }
    procedure Done;  { draft }
    procedure MainProcess;  { draft }
  end;

  { TAIGroupControl (instance size 368, VMT 5571A978) }
  TAIGroupControl = class(TEObject)
  public
    F_AIGroupControl_08: Integer;
    F_AIGroupControl_0C: Integer;
    F_AIGroupControl_10: Byte;
    F_AIGroupControl_11: array[0..2] of Byte;
    F_AIGroupControl_14: Integer;
    F_AIGroupControl_18: Integer;
    F_AIGroupControl_1C: Integer;
    F_AIGroupControl_20: Byte;
    F_AIGroupControl_21: array[0..2] of Byte;
    F_AIGroupControl_24: Integer;
    F_AIGroupControl_28: Byte;
    F_AIGroupControl_29: array[0..38] of Byte;
    F_AIGroupControl_50: Integer;
    F_AIGroupControl_54: Byte;
    F_AIGroupControl_55: array[0..254] of Byte;
    F_AIGroupControl_154: Word;
    F_AIGroupControl_156: array[0..1] of Byte;
    F_AIGroupControl_158: Integer;
    F_AIGroupControl_15C: Integer;
    F_AIGroupControl_160: Integer;
    F_AIGroupControl_164: Integer;
    F_AIGroupControl_168: Integer;
    F_AIGroupControl_16C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MoveExecuterDone; virtual;  { +04C draft }
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); virtual;  { +050 draft }
    procedure RecruitmentGroupFoundEvent(A1: Integer; A2: Integer; A3: Integer); virtual;  { +054 draft }
    procedure ProductionLocationFoundEvent(A1: Integer; A2: Integer; A3: Integer); virtual;  { +058 draft }
    procedure Validate; virtual;  { +05C draft }
    procedure ProcessStates(A1: Integer; A2: Integer); virtual;  { +060 draft }
    procedure ProcessStatesLooped; virtual;  { +064 draft }
    procedure Split; virtual;  { +068 draft }
    procedure Activate; virtual;  { +06C draft }
    procedure Deactivate; virtual;  { +070 draft }
    procedure ResetME; virtual;  { +074 draft }
    procedure SetupME(A1: Integer; A2: Integer); virtual;  { +078 draft }
    procedure ExecuteME(A1: Integer; A2: Integer; A3: Integer); virtual;  { +07C draft }
    procedure Done;  { draft }
    procedure GetStrengthMax(A1: Word; A2: Integer);  { draft }
    procedure UpdateGroupChanges;  { draft }
    procedure RetrieveGroupArmy(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure CombineIdleGroups(A1: Integer; A2: Integer);  { draft }
    procedure ResetCP;  { draft }
    procedure SetupCP(A1: Integer);  { draft }
    procedure ActivatePlugin(A1: Integer);  { draft }
    procedure DeactivatePlugin;  { draft }
    procedure MainProcessStates(A1: Integer);  { draft }
    procedure Process(A1: Byte);  { draft }
    procedure FindAvailableTransporter;  { draft }
  end;

  { TAIGroupTargetFinder (instance size 56, VMT 5571AAC4) }
  TAIGroupTargetFinder = class(TAIGroupControlPlugin)
  public
    F_AIGroupTargetFinder_1C: Integer;
    F_AIGroupTargetFinder_20: Integer;
    F_AIGroupTargetFinder_24: Byte;
    F_AIGroupTargetFinder_25: array[0..2] of Byte;
    F_AIGroupTargetFinder_28: Integer;
    F_AIGroupTargetFinder_2C: Integer;
    F_AIGroupTargetFinder_30: Integer;
    F_AIGroupTargetFinder_34: Word;
    F_AIGroupTargetFinder_36: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Reset; virtual;  { +060 draft }
    procedure Setup(A1: Integer); virtual;  { +064 draft }
    procedure TargetFoundEvent(A1: Integer; A2: Integer);  { draft }
  end;

  { TGroupDefenseSelector (instance size 16, VMT 5571ABB0) }
  TGroupDefenseSelector = class(TObject)
  public
    F_GroupDefenseSelector_04: array[0..3] of Byte;
    F_GroupDefenseSelector_08: Integer;
    F_GroupDefenseSelector_0C: Integer;
    destructor Destroy; override;
    procedure Create(A1: Byte); virtual;  { +000 draft }
    procedure GetDefenders(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure EnoughStrength(A1: Integer);  { draft }
    procedure UsefullUnit(A1: Integer; A2: Integer);  { draft }
    procedure UpdateDefenseLocation(A1: Integer);  { draft }
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { TAIGroupDefenseControl (instance size 40, VMT 5571ACDC) }
  TAIGroupDefenseControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupDefenseControl_1C: Integer;
    F_AIGroupDefenseControl_20: Integer;
    F_AIGroupDefenseControl_24: Byte;
    F_AIGroupDefenseControl_25: Byte;
    F_AIGroupDefenseControl_26: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TAIRecruitmentGroupFinder (instance size 52, VMT 5571AE1C) }
  TAIRecruitmentGroupFinder = class(TAIGroupControlPlugin)
  public
    F_AIRecruitmentGroupFinder_1C: Integer;
    F_AIRecruitmentGroupFinder_20: Integer;
    F_AIRecruitmentGroupFinder_24: Integer;
    F_AIRecruitmentGroupFinder_28: Integer;
    F_AIRecruitmentGroupFinder_2C: Integer;
    F_AIRecruitmentGroupFinder_30: Byte;
    F_AIRecruitmentGroupFinder_31: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer); virtual;  { +060 draft }
    procedure RecruitGroupFoundEvent(A1: Integer; A2: Integer);  { draft }
    procedure Reset;  { draft }
  end;

  { TAIGroupRecruitControl (instance size 152, VMT 5571AF78) }
  TAIGroupRecruitControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupRecruitControl_1C: Byte;
    F_AIGroupRecruitControl_1D: array[0..2] of Byte;
    F_AIGroupRecruitControl_20: Integer;
    F_AIGroupRecruitControl_24: Byte;
    F_AIGroupRecruitControl_25: array[0..2] of Byte;
    F_AIGroupRecruitControl_28: Integer;
    F_AIGroupRecruitControl_2C: Byte;
    F_AIGroupRecruitControl_2D: array[0..38] of Byte;
    F_AIGroupRecruitControl_54: Integer;
    F_AIGroupRecruitControl_58: Integer;
    F_AIGroupRecruitControl_5C: Word;
    F_AIGroupRecruitControl_5E: array[0..1] of Byte;
    F_AIGroupRecruitControl_60: Byte;
    F_AIGroupRecruitControl_61: array[0..38] of Byte;
    F_AIGroupRecruitControl_88: Integer;
    F_AIGroupRecruitControl_8C: Byte;
    F_AIGroupRecruitControl_8D: array[0..2] of Byte;
    F_AIGroupRecruitControl_90: Integer;
    F_AIGroupRecruitControl_94: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup; virtual;  { +060 draft }
    procedure GetRecruitedStrength;  { draft }
    procedure GetRecruitStrengthEx(A1: Integer);  { draft }
    procedure SetRecruitStrengthEx(A1: Integer; A2: Integer);  { draft }
    procedure GetRecruitMoveDays;  { draft }
    procedure UsefullRecruitUnit(A1: Integer);  { draft }
    procedure UpdateCompletion;  { draft }
    procedure AddRecruitUnit(A1: Integer);  { draft }
    procedure DeleteRecruitUnit(A1: Integer);  { draft }
    procedure ExecuteRecruitment;  { draft }
    procedure ValidRecruitmentGroup(A1: Integer);  { draft }
    procedure RecruitFromGroup(A1: Integer);  { draft }
    procedure Reset;  { draft }
  end;

  { TAIGroupCooperationControl (instance size 148, VMT 5571B0C8) }
  TAIGroupCooperationControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupCooperationControl_1C: Byte;
    F_AIGroupCooperationControl_1D: array[0..2] of Byte;
    F_AIGroupCooperationControl_20: Integer;
    F_AIGroupCooperationControl_24: Integer;
    F_AIGroupCooperationControl_28: Byte;
    F_AIGroupCooperationControl_29: array[0..2] of Byte;
    F_AIGroupCooperationControl_2C: Integer;
    F_AIGroupCooperationControl_30: Byte;
    F_AIGroupCooperationControl_31: array[0..38] of Byte;
    F_AIGroupCooperationControl_58: Integer;
    F_AIGroupCooperationControl_5C: Integer;
    F_AIGroupCooperationControl_60: Integer;
    F_AIGroupCooperationControl_64: Word;
    F_AIGroupCooperationControl_66: array[0..1] of Byte;
    F_AIGroupCooperationControl_68: Byte;
    F_AIGroupCooperationControl_69: array[0..38] of Byte;
    F_AIGroupCooperationControl_90: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer; A2: Integer); virtual;  { +060 draft }
    procedure GetCooperateMoveDays(A1: Integer; A2: Integer);  { draft }
    procedure GetCooperatedStrength;  { draft }
    procedure GetCooperateStrengthEx(A1: Integer);  { draft }
    procedure SetCooperateStrengthEx(A1: Integer; A2: Integer);  { draft }
    procedure UpdateCompletion;  { draft }
    procedure Reset;  { draft }
    procedure AddCooperationGroup(A1: Integer; A2: Integer);  { draft }
    procedure ValidCooperationGroup(A1: Integer);  { draft }
    procedure ExecuteCooperation(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIProductionLocationFinder (instance size 52, VMT 5571B218) }
  TAIProductionLocationFinder = class(TAIGroupControlPlugin)
  public
    F_AIProductionLocationFinder_1C: Integer;
    F_AIProductionLocationFinder_20: Integer;
    F_AIProductionLocationFinder_24: Byte;
    F_AIProductionLocationFinder_25: array[0..2] of Byte;
    F_AIProductionLocationFinder_28: Integer;
    F_AIProductionLocationFinder_2C: Integer;
    F_AIProductionLocationFinder_30: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer); virtual;  { +060 draft }
    procedure ProductionLocationFoundEvent(A1: Integer; A2: Integer);  { draft }
    procedure Reset;  { draft }
  end;

  { TAIGroupUnitProduction (instance size 48, VMT 5571B36C) }
  TAIGroupUnitProduction = class(TEObject)
  public
    F_AIGroupUnitProduction_08: Integer;
    F_AIGroupUnitProduction_0C: Integer;
    F_AIGroupUnitProduction_10: Integer;
    F_AIGroupUnitProduction_14: Integer;
    F_AIGroupUnitProduction_18: Integer;
    F_AIGroupUnitProduction_1C: Integer;
    F_AIGroupUnitProduction_20: Integer;
    F_AIGroupUnitProduction_24: Integer;
    F_AIGroupUnitProduction_28: Integer;
    F_AIGroupUnitProduction_2C: Byte;
    F_AIGroupUnitProduction_2D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure SetU(A1: Integer);  { draft }
    procedure SetProductionLocation(A1: Integer);  { draft }
  end;

  { TAIGroupUnitProductionList (instance size 12, VMT 5571B440) }
  TAIGroupUnitProductionList = class(TEReferenceNode)
  public
    procedure GetUnitProductions(A1: Integer);  { draft }
  end;

  { TAIGroupProductionControl (instance size 192, VMT 5571B558) }
  TAIGroupProductionControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupProductionControl_1C: Integer;
    F_AIGroupProductionControl_20: Byte;
    F_AIGroupProductionControl_21: Byte;
    F_AIGroupProductionControl_22: array[0..1] of Byte;
    F_AIGroupProductionControl_24: Integer;
    F_AIGroupProductionControl_28: Integer;
    F_AIGroupProductionControl_2C: Integer;
    F_AIGroupProductionControl_30: Integer;
    F_AIGroupProductionControl_34: Integer;
    F_AIGroupProductionControl_38: Integer;
    F_AIGroupProductionControl_3C: Byte;
    F_AIGroupProductionControl_3D: array[0..38] of Byte;
    F_AIGroupProductionControl_64: Integer;
    F_AIGroupProductionControl_68: Integer;
    F_AIGroupProductionControl_6C: Word;
    F_AIGroupProductionControl_6E: array[0..1] of Byte;
    F_AIGroupProductionControl_70: Byte;
    F_AIGroupProductionControl_71: array[0..38] of Byte;
    F_AIGroupProductionControl_98: Integer;
    F_AIGroupProductionControl_9C: Byte;
    F_AIGroupProductionControl_9D: array[0..2] of Byte;
    F_AIGroupProductionControl_A0: Integer;
    F_AIGroupProductionControl_A4: Integer;
    F_AIGroupProductionControl_A8: Integer;
    F_AIGroupProductionControl_AC: Byte;
    F_AIGroupProductionControl_AD: array[0..2] of Byte;
    F_AIGroupProductionControl_B0: Integer;
    F_AIGroupProductionControl_B4: Byte;
    F_AIGroupProductionControl_B5: array[0..2] of Byte;
    F_AIGroupProductionControl_B8: Integer;
    F_AIGroupProductionControl_BC: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer); virtual;  { +060 draft }
    procedure GetProducedStrength;  { draft }
    procedure GetProduceStrengthEx(A1: Integer);  { draft }
    procedure SetProduceStrengthEx(A1: Integer; A2: Integer);  { draft }
    procedure UnitProductionPriority(A1: Integer);  { draft }
    procedure GetCurrentProductionTime;  { draft }
    procedure GetCompleteProductionTime;  { draft }
    procedure UpdateCompletion;  { draft }
    procedure ExecuteProductions(A1: Integer);  { draft }
    procedure AddProduction(A1: Integer);  { draft }
    procedure DeleteProduction(A1: Integer);  { draft }
    procedure Reset;  { draft }
    procedure ListProduceableUnits(A1: Integer);  { draft }
    procedure ValidProductionLocation(A1: Integer);  { draft }
    procedure UpdateProduceableUnits;  { draft }
  end;

  { TAIGroupTargetPrioritySettings (instance size 60, VMT 5571B750) }
  TAIGroupTargetPrioritySettings = class(TObject)
  public
    F_AIGroupTargetPrioritySettings_04: array[0..55] of Byte;
  end;

  { TAIGroupTargetSelector (instance size 136, VMT 5571B7E8) }
  TAIGroupTargetSelector = class(TAIGroupControlPlugin)
  public
    F_AIGroupTargetSelector_1C: Byte;
    F_AIGroupTargetSelector_1D: array[0..2] of Byte;
    F_AIGroupTargetSelector_20: Integer;
    F_AIGroupTargetSelector_24: Integer;
    F_AIGroupTargetSelector_28: Integer;
    F_AIGroupTargetSelector_2C: Integer;
    F_AIGroupTargetSelector_30: Byte;
    F_AIGroupTargetSelector_31: array[0..2] of Byte;
    F_AIGroupTargetSelector_34: Integer;
    F_AIGroupTargetSelector_38: Integer;
    F_AIGroupTargetSelector_3C: Integer;
    F_AIGroupTargetSelector_40: Integer;
    F_AIGroupTargetSelector_44: Integer;
    F_AIGroupTargetSelector_48: Integer;
    F_AIGroupTargetSelector_4C: Integer;
    F_AIGroupTargetSelector_50: Integer;
    F_AIGroupTargetSelector_54: Integer;
    F_AIGroupTargetSelector_58: Word;
    F_AIGroupTargetSelector_5A: array[0..1] of Byte;
    F_AIGroupTargetSelector_5C: Integer;
    F_AIGroupTargetSelector_60: Integer;
    F_AIGroupTargetSelector_64: Integer;
    F_AIGroupTargetSelector_68: Integer;
    F_AIGroupTargetSelector_6C: Integer;
    F_AIGroupTargetSelector_70: Integer;
    F_AIGroupTargetSelector_74: Integer;
    F_AIGroupTargetSelector_78: Integer;
    F_AIGroupTargetSelector_7C: Byte;
    F_AIGroupTargetSelector_7D: array[0..2] of Byte;
    F_AIGroupTargetSelector_80: Integer;
    F_AIGroupTargetSelector_84: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Validate; override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure TargetOverlapFound(A1: Integer; A2: Integer);  { draft }
    procedure ValidateTargetOverlap(A1: Integer; A2: Integer);  { draft }
    procedure GetValidTargets;  { draft }
    procedure Reset;  { draft }
    procedure ActivatePlugin(A1: Integer);  { draft }
    procedure DeactivatePlugin;  { draft }
    procedure GetTargetSetupPriority(A1: Integer; A2: Integer);  { draft }
    procedure Setup(A1: Integer);  { draft }
    procedure TargetProcessed;  { draft }
    procedure GetRequiredSuperiority(A1: Integer);  { draft }
    procedure GetRequiredCombatPredictorSuperiority(A1: Integer);  { draft }
    procedure GetRequiredTargetStrength(A1: Integer);  { draft }
    procedure GetRequiredBattleFieldSuperiority(A1: Integer);  { draft }
    procedure GetRequiredBattleFieldStrength(A1: Integer);  { draft }
    procedure GetRequiredStrength(A1: Integer);  { draft }
    procedure ValidateTargetRequirements(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ValidMultiTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ShowTargetInfo;  { draft }
    procedure NoTargetsFound;  { draft }
    procedure AllowMultiTargets(A1: Integer; A2: Integer);  { draft }
  end;

  { THuntAG (instance size 84, VMT 5571B8D0) }
  THuntAG = class(TAIGroup)
  public
    F_HuntAG_50: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
    procedure HuntingPlayer(A1: Integer);  { draft }
  end;

  { THuntAGC (instance size 368, VMT 5571BA18) }
  THuntAGC = class(TAIGroupControl)
  public
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
  end;

  { TGroupControl (instance size 8, VMT 5571BB04) }
  TGroupControl = class(TEObject)
  public
    procedure Behavior; virtual;  { +04C draft }
  end;

  { TGuardGC (instance size 8, VMT 5571BBC8) }
  TGuardGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TPassiveGC (instance size 8, VMT 5571BC84) }
  TPassiveGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TGuardAreaGC (instance size 8, VMT 5571BD44) }
  TGuardAreaGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TSuicidalGC (instance size 8, VMT 5571BE08) }
  TSuicidalGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TPatrolGC (instance size 8, VMT 5571BEC8) }
  TPatrolGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TScoutGC (instance size 8, VMT 5571BF84) }
  TScoutGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TRefugeGC (instance size 8, VMT 5571C040) }
  TRefugeGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TEndTurnTE (instance size 28, VMT 5571C138) }
  TEndTurnTE = class(TTokenEvent)
  public
    F_EndTurnTE_10: Byte;
    F_EndTurnTE_11: array[0..2] of Byte;
    F_EndTurnTE_14: Integer;
    F_EndTurnTE_18: Byte;
    F_EndTurnTE_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TChangePlayerSettingsTE (instance size 24, VMT 5571C1F8) }
  TChangePlayerSettingsTE = class(TTokenEvent)
  public
    F_ChangePlayerSettingsTE_10: Byte;
    F_ChangePlayerSettingsTE_11: array[0..2] of Byte;
    F_ChangePlayerSettingsTE_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TMoveTE (instance size 28, VMT 5571C330) }
  TMoveTE = class(TTokenEvent)
  public
    F_MoveTE_10: Byte;
    F_MoveTE_11: array[0..2] of Byte;
    F_MoveTE_14: Integer;
    F_MoveTE_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    function GetMapF(A1: Integer; A2: Integer): Integer; virtual;  { +050 draft }
    procedure ProcessMove; virtual;  { +054 draft }
    function Validate: Integer; virtual;  { +058 draft }
    procedure InitializeMove; virtual;  { +05C draft }
    procedure FinishMove; virtual;  { +060 draft }
    procedure Move; virtual;  { +064 draft }
    function LastMove(A1: Integer; A2: Byte): Byte; virtual;  { +068 draft }
    function DefaultMove: Byte; virtual;  { +06C draft }
    procedure GetDirection(A1: Integer);  { draft }
    procedure GetHT(A1: Integer);  { draft }
  end;

  { TMultiMoveTE (instance size 24, VMT 5571C408) }
  TMultiMoveTE = class(TTokenEvent)
  public
    F_MultiMoveTE_10: Integer;
    F_MultiMoveTE_14: Byte;
    F_MultiMoveTE_15: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TMoveArmyTE (instance size 56, VMT 5571C52C) }
  TMoveArmyTE = class(TMoveTE)
  public
    F_MoveArmyTE_1C: Byte;
    F_MoveArmyTE_1D: array[0..2] of Byte;
    F_MoveArmyTE_20: Integer;
    F_MoveArmyTE_24: Byte;
    F_MoveArmyTE_25: array[0..2] of Byte;
    F_MoveArmyTE_28: Integer;
    F_MoveArmyTE_2C: Byte;
    F_MoveArmyTE_2D: Byte;
    F_MoveArmyTE_2E: Byte;
    F_MoveArmyTE_2F: Byte;
    F_MoveArmyTE_30: Byte;
    F_MoveArmyTE_31: Byte;
    F_MoveArmyTE_32: Byte;
    F_MoveArmyTE_33: Byte;
    F_MoveArmyTE_34: Byte;
    F_MoveArmyTE_35: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Validate: Integer; override;
    procedure InitializeMove; override;
    procedure FinishMove; override;
    function DefaultMove: Byte; override;
    procedure Animating; virtual;  { +070 draft }
    procedure UpdateAnimation; virtual;  { +074 draft }
    procedure SetupNextMove; virtual;  { +078 draft }
    procedure CanMoveNext; virtual;  { +07C draft }
    procedure ExecuteMove; virtual;  { +080 draft }
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +084 draft }
    procedure GetNoneMovingArmyHS(A1: Integer);  { draft }
    procedure ObserveMove;  { draft }
    procedure MoveVisible(A1: Integer);  { draft }
  end;

  { TArmyDefaultMoveTE (instance size 56, VMT 5571C624) }
  TArmyDefaultMoveTE = class(TMoveArmyTE)
  public
    class function ClassID: Integer; override;
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TArmyNegotiateMoveTE (instance size 56, VMT 5571C72C) }
  TArmyNegotiateMoveTE = class(TMoveArmyTE)
  public
    class function ClassID: Integer; override;
    function Validate: Integer; override;
    procedure Animating; override;
    procedure CanMoveNext; override;
    procedure ExecuteMove; override;
  end;

  { TArmyCombineMoveTE (instance size 56, VMT 5571C838) }
  TArmyCombineMoveTE = class(TMoveArmyTE)
  public
    class function ClassID: Integer; override;
    procedure CanMoveNext; override;
    procedure ShowCombineFailure(A1: Byte);  { draft }
  end;

  { TArmyCombatMoveTE (instance size 60, VMT 5571C9D4) }
  TArmyCombatMoveTE = class(TMoveArmyTE)
  public
    F_ArmyCombatMoveTE_38: Byte;
    F_ArmyCombatMoveTE_39: Byte;
    F_ArmyCombatMoveTE_3A: Byte;
    F_ArmyCombatMoveTE_3B: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure ProcessMove; override;
    function Validate: Integer; override;
    procedure InitializeMove; override;
    procedure Animating; override;
    procedure CanMoveNext; override;
    procedure ExecuteMove; override;
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure RequestCombatTypeCallBack(A1: Integer);  { draft }
    procedure RestoreHotseatMode(A1: Integer);  { draft }
    procedure RestoreHotSeatModeCallBack;  { draft }
    procedure ShowHotSeatPlayerCallBack(A1: Integer);  { draft }
    procedure SetupCombat;  { draft }
    procedure CombatExecuted(A1: Integer);  { draft }
    procedure ExecuteCombat;  { draft }
    procedure ExecuteLastMove;  { draft }
  end;

  { TCombatRestoreHotseatEventLog (instance size 28, VMT 5571CAD8) }
  TCombatRestoreHotseatEventLog = class(TEventLog)
  public
    F_CombatRestoreHotseatEventLog_18: Byte;
    F_CombatRestoreHotseatEventLog_19: array[0..2] of Byte;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TNegotiateTE (instance size 60, VMT 5571CCFC) }
  TNegotiateTE = class(TTokenEvent)
  public
    F_NegotiateTE_10: Integer;
    F_NegotiateTE_14: Byte;
    F_NegotiateTE_15: Byte;
    F_NegotiateTE_16: Byte;
    F_NegotiateTE_17: Byte;
    F_NegotiateTE_18: Integer;
    F_NegotiateTE_1C: Byte;
    F_NegotiateTE_1D: Byte;
    F_NegotiateTE_1E: array[0..1] of Byte;
    F_NegotiateTE_20: Integer;
    F_NegotiateTE_24: Byte;
    F_NegotiateTE_25: array[0..2] of Byte;
    F_NegotiateTE_28: Integer;
    F_NegotiateTE_2C: Byte;
    F_NegotiateTE_2D: Byte;
    F_NegotiateTE_2E: Byte;
    F_NegotiateTE_2F: array[0..0] of Byte;
    F_NegotiateTE_30: Integer;
    F_NegotiateTE_34: Integer;
    F_NegotiateTE_38: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Validate; virtual;  { +050 draft }
    procedure Accept; virtual;  { +054 draft }
    procedure Reject; virtual;  { +058 draft }
  end;

  { TNegotiateRequestEventLog (instance size 84, VMT 5571CDCC) }
  TNegotiateRequestEventLog = class(TJoinEventLog)
  public
    F_NegotiateRequestEventLog_3C: Byte;
    F_NegotiateRequestEventLog_3D: Byte;
    F_NegotiateRequestEventLog_3E: Byte;
    F_NegotiateRequestEventLog_3F: array[0..0] of Byte;
    F_NegotiateRequestEventLog_40: Integer;
    F_NegotiateRequestEventLog_44: Integer;
    F_NegotiateRequestEventLog_48: Byte;
    F_NegotiateRequestEventLog_49: array[0..2] of Byte;
    F_NegotiateRequestEventLog_4C: Integer;
    F_NegotiateRequestEventLog_50: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure Accept(A1: Integer; A2: Integer); override;
    procedure Cancel; override;
    procedure Reject; override;
    procedure CreateNegotiateTE; virtual;  { +08C draft }
  end;

  { TGameOverTE (instance size 20, VMT 5571CEE8) }
  TGameOverTE = class(TTokenEvent)
  public
    F_GameOverTE_10: Byte;
    F_GameOverTE_11: Byte;
    F_GameOverTE_12: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TSaveGameTE (instance size 20, VMT 5571CFA8) }
  TSaveGameTE = class(TTokenEvent)
  public
    F_SaveGameTE_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TCheatTE (instance size 24, VMT 5571D07C) }
  TCheatTE = class(TTokenEvent)
  public
    F_CheatTE_10: Byte;
    F_CheatTE_11: array[0..2] of Byte;
    F_CheatTE_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TDisbandUnitTE (instance size 24, VMT 5571D138) }
  TDisbandUnitTE = class(TTokenEvent)
  public
    F_DisbandUnitTE_10: Integer;
    F_DisbandUnitTE_14: Byte;
    F_DisbandUnitTE_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TCombatFlowControlTE (instance size 24, VMT 5571D2A8) }
  TCombatFlowControlTE = class(TTokenEvent)
  public
    F_CombatFlowControlTE_10: Byte;
    F_CombatFlowControlTE_11: array[0..2] of Byte;
    F_CombatFlowControlTE_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TTerminatePlayerTE (instance size 32, VMT 5571D37C) }
  TTerminatePlayerTE = class(TTokenEvent)
  public
    F_TerminatePlayerTE_10: Byte;
    F_TerminatePlayerTE_11: array[0..2] of Byte;
    F_TerminatePlayerTE_14: Byte;
    F_TerminatePlayerTE_15: array[0..0] of Byte;
    F_TerminatePlayerTE_16: Word;
    F_TerminatePlayerTE_18: Integer;
    F_TerminatePlayerTE_1C: Byte;
    F_TerminatePlayerTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TFastCombatUnit (instance size 100, VMT 5571D4BC) }
  TFastCombatUnit = class(TCombatUnit)
  public
    F_FastCombatUnit_5C: Integer;
    F_FastCombatUnit_60: Byte;
    F_FastCombatUnit_61: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetTargetWallCV(A1: Integer); override;
    procedure GetTargetPriority; override;
    procedure SetCombatPlayer(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    procedure Initialize(A1: Integer); override;
    procedure fcRoundDistance; override;
    procedure fcExecute(A1: Integer); override;
    procedure fcBehindWall; override;
    procedure fcWallInBetween(A1: Integer); override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure DestroyObject; override;
    procedure SetUnit(A1: Integer); override;
    procedure KillUnit; override;
    procedure CanCastWallSiegeSpell;  { draft }
    procedure UpdateWallSiegeObjectRegistration;  { draft }
  end;

  { TFastCombatParty (instance size 28, VMT 5571D670) }
  TFastCombatParty = class(TCombatParty)
  public
  end;

  { TCombatObjectList (instance size 16, VMT 5571D738) }
  TCombatObjectList = class(TList)
  public
    procedure GetObject(A1: Integer);  { draft }
  end;

  { TFastCombat (instance size 80, VMT 5571D7BC) }
  TFastCombat = class(TCombat)
  public
    F_FastCombat_4C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function CreateCombatUnit: Integer; override;
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer); override;
    function Execute: Byte; override;
    procedure Initialize; override;
    procedure Activate; override;
    procedure Deactivate(A1: Integer; A2: Integer); override;
    procedure GetRoundDistance;  { draft }
    procedure GetRoundDistanceMax;  { draft }
    procedure GetWallInBetween(A1: Integer; A2: Integer);  { draft }
    procedure GetWallSituation(A1: Integer; A2: Integer);  { draft }
    procedure AttackerCanCrushWall;  { draft }
    procedure GetAttackerBalisticCV(A1: Integer; A2: Integer);  { draft }
    procedure GetDefenderBalisticCV(A1: Integer; A2: Integer);  { draft }
    procedure ValidateWallBreaching;  { draft }
    procedure ExecuteCombatRound;  { draft }
  end;

  { TAbilityPlugIn (instance size 16, VMT 5571D8AC) }
  TAbilityPlugIn = class(TPlugIn)
  public
    function Name: string; override;
    function Initialize(AEngine: Engine.TEngine): Boolean; override;
    function Finalize(AEngine: Engine.TEngine): Boolean; override;
  end;

  { TAdjustableAbility (instance size 40, VMT 5571D930) }
  TAdjustableAbility = class(TAbility)
  public
    F_AdjustableAbility_24: Integer;
    procedure GetAbilityType; override;
  end;

  { TEnhancementAbility (instance size 40, VMT 5571DABC) }
  TEnhancementAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TDurationAbilityData (instance size 20, VMT 5571DC94) }
  TDurationAbilityData = class(TAbilityData)
  public
    F_DurationAbilityData_0C: Byte;
    F_DurationAbilityData_0D: Byte;
    F_DurationAbilityData_0E: Word;
    F_DurationAbilityData_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
  end;

  { TDurationAbility (instance size 44, VMT 5571DD68) }
  TDurationAbility = class(TAdjustableAbility)
  public
    F_DurationAbility_28: Byte;
    F_DurationAbility_29: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure NewDay(A1: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure NewCombatTurn(A1: Integer; A2: Integer); override;
    procedure CombatDone(A1: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetDuration(A1: Integer); virtual;  { +10C draft }
    procedure GetTotalDuration; virtual;  { +110 draft }
  end;

  { TMultiLevelAbilityData (instance size 16, VMT 5571DEF8) }
  TMultiLevelAbilityData = class(TAbilityData)
  public
    F_MultiLevelAbilityData_0C: Byte;
    F_MultiLevelAbilityData_0D: array[0..0] of Byte;
    F_MultiLevelAbilityData_0E: Word;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
  end;

  { TMultiLevelAbility (instance size 48, VMT 5571DFD0) }
  TMultiLevelAbility = class(TAdjustableAbility)
  public
    F_MultiLevelAbility_28: Integer;
    F_MultiLevelAbility_2C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetLevel(A1: Integer); override;
    procedure GetSkillPoints(A1: Integer); override;
    procedure GetInherentLevel(A1: Integer); override;
    procedure CanExpand(A1: Integer); override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetLevelName(A1: Integer; A2: Integer); virtual;  { +10C draft }
  end;

  { TTransportAbility (instance size 48, VMT 5571E160) }
  TTransportAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLevelName(A1: Integer; A2: Integer); override;
  end;

  { TStrikeCA (instance size 28, VMT 5571E344) }
  TStrikeCA = class(TDamageCA)
  public
    F_StrikeCA_18: Byte;
    F_StrikeCA_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure Generate(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
  end;

  { TMeleeRound (instance size 52, VMT 5571E460) }
  TMeleeRound = class(TObject)
  public
    F_MeleeRound_04: array[0..3] of Byte;
    F_MeleeRound_08: Integer;
    F_MeleeRound_0C: Integer;
    F_MeleeRound_10: Integer;
    F_MeleeRound_14: Integer;
    F_MeleeRound_18: Integer;
    F_MeleeRound_1C: Integer;
    F_MeleeRound_20: Integer;
    F_MeleeRound_24: Integer;
    F_MeleeRound_28: Integer;
    F_MeleeRound_2C: Integer;
    F_MeleeRound_30: Word;
    F_MeleeRound_32: Word;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure SetCapacity(A1: Integer);  { draft }
    procedure SetCount(A1: Integer);  { draft }
    procedure GetMeleeStrike(A1: Integer; A2: Integer);  { draft }
    procedure Reset;  { draft }
    procedure CalculateUnitStrikes(A1: Byte);  { draft }
    procedure CalculateFreeUnitSwing(A1: Integer; A2: Integer);  { draft }
    procedure CalculateUnit(A1: Integer; A2: Integer);  { draft }
    procedure CalculateStrikes(A1: Byte);  { draft }
    procedure Calculate(A1: Integer; A2: Integer);  { draft }
    procedure CalculateSingleSide(A1: Integer; A2: Integer);  { draft }
    procedure CreateStrikeCA(A1: Integer);  { draft }
    procedure CalculateDV(A1: Integer; A2: Integer);  { draft }
    procedure GetAttackerDV;  { draft }
    procedure GetDefenderDV;  { draft }
  end;

  { TStrikeEnhancementAbility (instance size 40, VMT 5571E4D0) }
  TStrikeEnhancementAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanExpand(A1: Integer); override;
  end;

  { TStrikeAbility (instance size 44, VMT 5571E668) }
  TStrikeAbility = class(TAdjustableAbility)
  public
    F_StrikeAbility_28: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatMode(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure CanExecuteMelee(A1: Integer; A2: Integer);  { draft }
    procedure GetDamageTypes(A1: Integer);  { draft }
  end;

  { TRangedAttackCA (instance size 28, VMT 5571E7EC) }
  TRangedAttackCA = class(TDamageCA)
  public
    F_RangedAttackCA_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
  end;

  { TRangedAttackAbility (instance size 48, VMT 5571E8D4) }
  TRangedAttackAbility = class(TAdjustableAbility)
  public
    F_RangedAttackAbility_28: Integer;
    F_RangedAttackAbility_2C: array[0..0] of Byte;
    F_RangedAttackAbility_2D: Byte;
    F_RangedAttackAbility_2E: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatMode(A1: Integer); override;
    procedure GetWallCombatFeatures(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcValidRoundDistance(A1: Integer; A2: Integer); override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure GetRangeRA; virtual;  { +10C draft }
    procedure GetDamageRA(A1: Integer); virtual;  { +110 draft }
    procedure GetAttackRA(A1: Integer); virtual;  { +114 draft }
    procedure GetAttackRepeatRA; virtual;  { +118 draft }
    procedure GetDamageTypesRA; virtual;  { +11C draft }
    procedure CreateRangedAttackCA(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TBoltsAbility (instance size 48, VMT 5571EA78) }
  TBoltsAbility = class(TRangedAttackAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TBreathAbility (instance size 48, VMT 5571EC0C) }
  TBreathAbility = class(TRangedAttackAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TFlameThrowingAbility (instance size 48, VMT 5571EDA4) }
  TFlameThrowingAbility = class(TBreathAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TTouchAbility (instance size 40, VMT 5571EF48) }
  TTouchAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatMode(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure GetTouchAttack(A1: Integer); virtual;  { +10C draft }
    procedure CombatTouchRole(A1: Integer; A2: Integer); virtual;  { +110 draft }
    procedure CombatTouchRoleProbability(A1: Integer; A2: Integer); virtual;  { +114 draft }
    procedure TouchRoleProbability(A1: Integer; A2: Integer); virtual;  { +118 draft }
    procedure CanTouch(A1: Integer; A2: Integer); virtual;  { +11C draft }
    procedure CanTouchUnit(A1: Integer; A2: Integer); virtual;  { +120 draft }
    procedure fcValidateMoveOutsideWall(A1: Integer; A2: Integer);  { draft }
  end;

  { TPossessCA (instance size 20, VMT 5571F0E0) }
  TPossessCA = class(TSingleTargetCA)
  public
    F_PossessCA_10: Byte;
    F_PossessCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TPossessAbility (instance size 40, VMT 5571F1B4) }
  TPossessAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure CreatePossessCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TPossessedAbilityData (instance size 16, VMT 5571F350) }
  TPossessedAbilityData = class(TAbilityData)
  public
    F_PossessedAbilityData_0C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
  end;

  { TPossessedAbility (instance size 40, VMT 5571F424) }
  TPossessedAbility = class(TPossessAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure CombatObjectDestroyed(A1: Integer); override;
    procedure AbilityDataClass; override;
  end;

  { TWebCA (instance size 20, VMT 5571F5C4) }
  TWebCA = class(TSingleTargetCA)
  public
    F_WebCA_10: Byte;
    F_WebCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TWebAbility (instance size 40, VMT 5571F690) }
  TWebAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CreateWebCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TEntangleCA (instance size 20, VMT 5571F824) }
  TEntangleCA = class(TSingleTargetCA)
  public
    F_EntangleCA_10: Byte;
    F_EntangleCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TEntangleAbility (instance size 40, VMT 5571F8F8) }
  TEntangleAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CreateEntangleCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TInvokeDeathCA (instance size 20, VMT 5571FA98) }
  TInvokeDeathCA = class(TSingleTargetCA)
  public
    F_InvokeDeathCA_10: Byte;
    F_InvokeDeathCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TInvokeDeathAbility (instance size 40, VMT 5571FB74) }
  TInvokeDeathAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure CreateCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TTurnUndeadCA (instance size 24, VMT 5571FD18) }
  TTurnUndeadCA = class(TDamageCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure GetSuccessfull;  { draft }
  end;

  { TTurnUndeadAbility (instance size 40, VMT 5571FDFC) }
  TTurnUndeadAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetLevel(A1: Integer); override;
    procedure GetSkillPoints(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure CanExpand(A1: Integer); override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure GetLevelName(A1: Integer; A2: Integer);  { draft }
    procedure GetTurnUndeadDamage(A1: Integer);  { draft }
    procedure CreateTurnUndeadCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TRoundAttackAbility (instance size 40, VMT 5571FFA0) }
  TRoundAttackAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
  end;

  { TCommandedAbilityData (instance size 28, VMT 55720144) }
  TCommandedAbilityData = class(TAbilityData)
  public
    F_CommandedAbilityData_0C: Integer;
    F_CommandedAbilityData_10: Byte;
    F_CommandedAbilityData_11: array[0..2] of Byte;
    F_CommandedAbilityData_14: Integer;
    F_CommandedAbilityData_18: Byte;
    F_CommandedAbilityData_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
  end;

  { TCommandedAbility (instance size 40, VMT 55720218) }
  TCommandedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure CombatObjectDestroyed(A1: Integer); override;
    procedure CombatDone(A1: Integer); override;
    procedure AbilityDataClass; override;
  end;

  { TCommandCA (instance size 24, VMT 557203A0) }
  TCommandCA = class(TSingleTargetCA)
  public
    F_CommandCA_10: Integer;
    F_CommandCA_14: Byte;
    F_CommandCA_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TCommandAbilityData (instance size 20, VMT 55720474) }
  TCommandAbilityData = class(TAbilityData)
  public
    F_CommandAbilityData_0C: Integer;
    F_CommandAbilityData_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
    procedure CommandingTargetPriority(A1: Integer; A2: Integer);  { draft }
    procedure CommandingTargetStrength(A1: Integer; A2: Integer);  { draft }
  end;

  { TCommandAbility (instance size 44, VMT 55720544) }
  TCommandAbility = class(TTouchAbility)
  public
    F_CommandAbility_28: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAbilityType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure CombatObjectDestroyed(A1: Integer); override;
    procedure CombatDone(A1: Integer); override;
    procedure AbilityDataClass; override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure Command(A1: Integer; A2: Integer); virtual;  { +124 draft }
    procedure CreateCommandCA(A1: Integer; A2: Integer); virtual;  { +128 draft }
    procedure ResetCommandedUnits(A1: Integer; A2: Integer); virtual;  { +12C draft }
    procedure Uncommand(A1: Integer); virtual;  { +130 draft }
  end;

  { TDominatedAbility (instance size 40, VMT 557206F0) }
  TDominatedAbility = class(TCommandedAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TDominateAbility (instance size 44, VMT 55720878) }
  TDominateAbility = class(TCommandAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTouchAttack(A1: Integer); override;
  end;

  { TCharmedAbility (instance size 40, VMT 55720A28) }
  TCharmedAbility = class(TCommandedAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TCharmAbility (instance size 44, VMT 55720BAC) }
  TCharmAbility = class(TCommandAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
  end;

  { TSeducedAbility (instance size 40, VMT 55720D54) }
  TSeducedAbility = class(TCommandedAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSeduceAbility (instance size 44, VMT 55720ED8) }
  TSeduceAbility = class(TCommandAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
  end;

  { TSelfDestructCA (instance size 24, VMT 55721084) }
  TSelfDestructCA = class(TDamageCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
  end;

  { TSelfDestructAbility (instance size 40, VMT 5572116C) }
  TSelfDestructAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetWallCombatFeatures(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure CreateSelfDestructCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TWallCrushingAbility (instance size 40, VMT 55721314) }
  TWallCrushingAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetWallCombatFeatures(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
  end;

  { THealingCA (instance size 16, VMT 557214BC) }
  THealingCA = class(TSingleTargetCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte);  { draft }
  end;

  { THealingAbilityData (instance size 16, VMT 55721590) }
  THealingAbilityData = class(TAbilityData)
  public
    F_HealingAbilityData_0C: Byte;
    F_HealingAbilityData_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
  end;

  { THealingTE (instance size 32, VMT 55721660) }
  THealingTE = class(TTokenEvent)
  public
    F_HealingTE_10: Integer;
    F_HealingTE_14: Byte;
    F_HealingTE_15: array[0..2] of Byte;
    F_HealingTE_18: Integer;
    F_HealingTE_1C: Byte;
    F_HealingTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { THealingUnitSelector (instance size 44, VMT 55721720) }
  THealingUnitSelector = class(TUnitSelector)
  public
    procedure CanSelectUnit(A1: Integer); override;
    procedure Select; override;
  end;

  { THealingAbility (instance size 40, VMT 557217BC) }
  THealingAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetEnabled(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure AbilityDataClass; override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure SetEnabled(A1: Integer; A2: Integer);  { draft }
    procedure GetHealHitPoints(A1: Integer);  { draft }
    procedure CreateHealingCA(A1: Integer; A2: Integer);  { draft }
    procedure HealUnit(A1: Integer);  { draft }
  end;

  { TDispelMagicCA (instance size 20, VMT 55721958) }
  TDispelMagicCA = class(TSingleTargetCA)
  public
    F_DispelMagicCA_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Generate(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TDispelMagicAbilityCA (instance size 20, VMT 55721A34) }
  TDispelMagicAbilityCA = class(TDispelMagicCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
  end;

  { TDispelMagicAbilityTE (instance size 32, VMT 55721B1C) }
  TDispelMagicAbilityTE = class(TTokenEvent)
  public
    F_DispelMagicAbilityTE_10: Integer;
    F_DispelMagicAbilityTE_14: Byte;
    F_DispelMagicAbilityTE_15: array[0..2] of Byte;
    F_DispelMagicAbilityTE_18: Integer;
    F_DispelMagicAbilityTE_1C: Byte;
    F_DispelMagicAbilityTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TDispelMagicAbilityData (instance size 16, VMT 55721BF0) }
  TDispelMagicAbilityData = class(TAbilityData)
  public
    F_DispelMagicAbilityData_0C: Byte;
    F_DispelMagicAbilityData_0D: Byte;
    F_DispelMagicAbilityData_0E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
  end;

  { TDispelMagicAbilityUnitSelector (instance size 44, VMT 55721CC8) }
  TDispelMagicAbilityUnitSelector = class(TUnitSelector)
  public
    procedure CanSelectUnit(A1: Integer); override;
    procedure Select; override;
  end;

  { TDispelMagicAbility (instance size 40, VMT 55721D78) }
  TDispelMagicAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetLevel(A1: Integer); override;
    procedure GetEnabled(A1: Integer); override;
    procedure GetSkillPoints(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure CanExpand(A1: Integer); override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure AbilityDataClass; override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure SetEnabled(A1: Integer; A2: Integer);  { draft }
    procedure GetDispelMana(A1: Integer);  { draft }
    procedure GetLevelName(A1: Integer; A2: Integer);  { draft }
    procedure CreateCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TLeadershipAbilityData (instance size 24, VMT 55721F1C) }
  TLeadershipAbilityData = class(TMultiLevelAbilityData)
  public
    F_LeadershipAbilityData_10: Byte;
    F_LeadershipAbilityData_11: array[0..2] of Byte;
    F_LeadershipAbilityData_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TLeadershipAbility (instance size 48, VMT 55722008) }
  TLeadershipAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetLevel(A1: Integer); override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
    procedure GetInherent(A1: Integer); override;
    procedure CanExpand(A1: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetLevelName(A1: Integer; A2: Integer); override;
    procedure SetExternalSource(A1: Integer; A2: Integer);  { draft }
    procedure ResetExternalSource(A1: Integer);  { draft }
  end;

  { TUnitEnchantment (instance size 32, VMT 55722198) }
  TUnitEnchantment = class(TEnchantment)
  public
    F_UnitEnchantment_18: Integer;
    F_UnitEnchantment_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); override;
    procedure GetBinding(A1: Integer); override;
    procedure GetAIUpkeepPriority; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Dispel; override;
    procedure Select; override;
  end;

  { TUnitEnchantmentAbilityData (instance size 20, VMT 55722284) }
  TUnitEnchantmentAbilityData = class(TAbilityData)
  public
    F_UnitEnchantmentAbilityData_0C: Word;
    F_UnitEnchantmentAbilityData_0E: Byte;
    F_UnitEnchantmentAbilityData_0F: Byte;
    F_UnitEnchantmentAbilityData_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
    procedure SetEnchantment(A1: Integer);  { draft }
  end;

  { TUnitEnchantmentAbility (instance size 40, VMT 55722364) }
  TUnitEnchantmentAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure NewCombatTurn(A1: Integer; A2: Integer); override;
    procedure CombatDone(A1: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetDurationMode; virtual;  { +10C draft }
    procedure GetDuration(A1: Integer); virtual;  { +110 draft }
    procedure GetAIUpkeepPriority(A1: Integer); virtual;  { +114 draft }
    procedure GetTotalDuration; virtual;  { +118 draft }
    procedure CreateEnchantment; virtual;  { +11C draft }
  end;

  { TConstructionControl (instance size 8, VMT 5572250C) }
  TConstructionControl = class(TEObject)
  public
    procedure GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +04C draft }
    procedure CanConstruct(A1: Integer; A2: Integer); virtual;  { +050 draft }
    procedure Construct(A1: Integer); virtual;  { +054 draft }
    procedure ID; virtual;  { +058 draft }
  end;

  { TConstructionControlList (instance size 12, VMT 557225EC) }
  TConstructionControlList = class(TENode)
  public
    procedure GetConstructionControl(A1: Integer);  { draft }
    procedure FindID(A1: Integer);  { draft }
  end;

  { TConstructAbility (instance size 44, VMT 55722700) }
  TConstructAbility = class(TAdjustableAbility)
  public
    F_ConstructAbility_28: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetControlType; override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure RegisterConstructionControl(A1: Integer);  { draft }
  end;

  { TCosmeticSurgeryEnchantment (instance size 36, VMT 55722888) }
  TCosmeticSurgeryEnchantment = class(TUnitEnchantment)
  public
    F_CosmeticSurgeryEnchantment_20: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); override;
  end;

  { TCosmeticSurgeryAbility (instance size 40, VMT 55722988) }
  TCosmeticSurgeryAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateEnchantment; override;
  end;

  { TSpellCastingAbility (instance size 48, VMT 55722B30) }
  TSpellCastingAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetLevelName(A1: Integer; A2: Integer); override;
    procedure CanCastBreachWallSpell(A1: Integer);  { draft }
    procedure AICanCastCombatSpell(A1: Integer);  { draft }
  end;

  { TSpellCC (instance size 32, VMT 55722D0C) }
  TSpellCC = class(TFastCombatCommand)
  public
    F_SpellCC_1C: Integer;
    procedure GetName(A1: Integer); override;
  end;

  { TSpell (instance size 52, VMT 55722D7C) }
  TSpell = class(TEObject)
  public
    F_Spell_08: Integer;
    F_Spell_0C: Byte;
    F_Spell_0D: array[0..2] of Byte;
    F_Spell_10: Integer;
    F_Spell_14: Integer;
    F_Spell_18: Integer;
    F_Spell_1C: Integer;
    F_Spell_20: Byte;
    F_Spell_21: Byte;
    F_Spell_22: Byte;
    F_Spell_23: array[0..0] of Byte;
    F_Spell_24: Integer;
    F_Spell_28: Integer;
    F_Spell_2C: Integer;
    F_Spell_30: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +04C draft }
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); virtual;  { +050 draft }
    procedure CreateCastSpellAction; virtual;  { +054 draft }
    procedure SetupCastSpellAction(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure AIPrefetchCastSpellActions(A1: Integer; A2: Integer); virtual;  { +05C draft }
    procedure AIExecuteCastSpellAction(A1: Integer); virtual;  { +060 draft }
    procedure GetEnabled; virtual;  { +064 draft }
    procedure CanActivate(A1: Integer; A2: Integer); virtual;  { +068 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +06C draft }
    procedure CanActivateCombat(A1: Integer; A2: Integer); virtual;  { +070 draft }
    procedure ActivateCombat(A1: Integer); virtual;  { +074 draft }
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); virtual;  { +078 draft }
    procedure GetCombatInfo(A1: Integer; A2: Integer); virtual;  { +07C draft }
    procedure GetCombatDamageValue(A1: Integer; A2: Integer); virtual;  { +080 draft }
    procedure GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +084 draft }
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +088 draft }
    procedure tcGetDamageValue; virtual;  { +08C draft }
    procedure fcPrefetchCombatCommands(A1: Integer); virtual;  { +090 draft }
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); virtual;  { +094 draft }
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +098 draft }
    procedure CastingDone(A1: Integer; A2: Integer);  { draft }
    procedure CombatCastingDone(A1: Integer; A2: Integer);  { draft }
    procedure CombatSpellCast(A1: Integer);  { draft }
    procedure AIRequestCastSpellExpense(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure AICastSpellExpenseMade(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TSpellControl (instance size 12, VMT 55722E94) }
  TSpellControl = class(TEObject)
  public
    F_SpellControl_08: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    procedure GetSpell(A1: Integer);  { draft }
    procedure RegisterSpell(A1: Integer);  { draft }
    procedure UnregisterSpell(A1: Integer);  { draft }
    procedure UnregisterSpellID(A1: Integer);  { draft }
    procedure UnregisterAll;  { draft }
    procedure ListSpells(A1: Integer; A2: Word);  { draft }
    procedure GetRandomSpell(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TSpellList (instance size 8, VMT 55722F54) }
  TSpellList = class(TObject)
  public
    F_SpellList_04: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure GetSpell(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure Add;  { draft }
    procedure Delete;  { draft }
    procedure Clear;  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnLevel;  { draft }
  end;

  { TSpellTE (instance size 32, VMT 55722FC4) }
  TSpellTE = class(TTokenEvent)
  public
    F_SpellTE_10: Integer;
    F_SpellTE_14: Integer;
    F_SpellTE_18: Byte;
    F_SpellTE_19: array[0..2] of Byte;
    F_SpellTE_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Validate(A1: Integer); virtual;  { +050 draft }
    procedure Process(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure Initialize(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure GetSource;  { draft }
  end;

  { TSpellCaster (instance size 20, VMT 5572308C) }
  TSpellCaster = class(TEObject)
  public
    F_SpellCaster_08: Integer;
    F_SpellCaster_0C: Integer;
    F_SpellCaster_10: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure CanCast(A1: Integer); virtual;  { +04C draft }
    procedure Cast; virtual;  { +050 draft }
    procedure GetSource;  { draft }
  end;

  { TCombatSpellCaster (instance size 20, VMT 55723154) }
  TCombatSpellCaster = class(TEObject)
  public
    F_CombatSpellCaster_08: array[0..7] of Byte;
    F_CombatSpellCaster_10: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
  end;

  { TSpellCastEventLog (instance size 32, VMT 55723220) }
  TSpellCastEventLog = class(TEventLog)
  public
    F_SpellCastEventLog_18: Integer;
    F_SpellCastEventLog_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
  end;

  { TUnitSpellCaster (instance size 28, VMT 55723318) }
  TUnitSpellCaster = class(TSpellCaster)
  public
    F_UnitSpellCaster_14: Integer;
    F_UnitSpellCaster_18: Byte;
    F_UnitSpellCaster_19: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanCast(A1: Integer); override;
    procedure Cast; override;
    procedure SetSelection(A1: Byte; A2: Integer);  { draft }
    procedure GetSelectionCount;  { draft }
    procedure GetRequiredMana;  { draft }
    procedure GetRequiredDays;  { draft }
    procedure Valid;  { draft }
  end;

  { TUnitSpellTE (instance size 52, VMT 557233E8) }
  TUnitSpellTE = class(TSpellTE)
  public
    F_UnitSpellTE_20: Integer;
    F_UnitSpellTE_24: Integer;
    F_UnitSpellTE_28: Byte;
    F_UnitSpellTE_29: array[0..10] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Initialize(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TUnitSpellCA (instance size 32, VMT 557234B8) }
  TUnitSpellCA = class(TCombatAction)
  public
    F_UnitSpellCA_0C: Integer;
    F_UnitSpellCA_10: Byte;
    F_UnitSpellCA_11: Byte;
    F_UnitSpellCA_12: array[0..9] of Byte;
    F_UnitSpellCA_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TUnitSpell (instance size 68, VMT 55723590) }
  TUnitSpell = class(TSpell)
  public
    F_UnitSpell_34: Byte;
    F_UnitSpell_35: array[0..2] of Byte;
    F_UnitSpell_38: Integer;
    F_UnitSpell_3C: Byte;
    F_UnitSpell_3D: array[0..2] of Byte;
    F_UnitSpell_40: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AIPrefetchCastSpellActions(A1: Integer; A2: Integer); override;
    procedure AIExecuteCastSpellAction(A1: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure CanActivateCombat(A1: Integer; A2: Integer); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); virtual;  { +09C draft }
    procedure ValidateUnitSelection(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0A0 draft }
    procedure SetupUSC(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0A4 draft }
    procedure CastSpell(A1: Integer; A2: Integer); virtual;  { +0A8 draft }
    procedure ValidTargetParty(A1: Integer; A2: Integer); virtual;  { +0AC draft }
    procedure TargetPartySelected(A1: Integer; A2: Integer); virtual;  { +0B0 draft }
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0B4 draft }
    procedure CreateCAEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0B8 draft }
    procedure ExecuteCA(A1: Integer; A2: Integer); virtual;  { +0BC draft }
    procedure AIRetrieveOptimalTargetUnit(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0C0 draft }
    procedure OnValidateTarget(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure OnTargetSelectionChange(A1: Integer; A2: Integer);  { draft }
    procedure ResetTargetSelection;  { draft }
    procedure SetupTargetSelection(A1: Integer; A2: Integer);  { draft }
  end;

  { TResearchSpellAIPA (instance size 20, VMT 557236C4) }
  TResearchSpellAIPA = class(TAIPlayerAction)
  public
    procedure Priority; override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TAICastSpellAction (instance size 28, VMT 557237A8) }
  TAICastSpellAction = class(TEObject)
  public
    F_AICastSpellAction_08: array[0..19] of Byte;
  end;

  { TAICastSpellActionList (instance size 12, VMT 55723874) }
  TAICastSpellActionList = class(TENode)
  public
    procedure GetCastSpellActions(A1: Integer);  { draft }
    procedure SortOnPriority;  { draft }
  end;

  { TCastSpellAIPA (instance size 40, VMT 55723984) }
  TCastSpellAIPA = class(TAIPlayerAction)
  public
    F_CastSpellAIPA_14: Integer;
    F_CastSpellAIPA_18: Integer;
    F_CastSpellAIPA_1C: Integer;
    F_CastSpellAIPA_20: Integer;
    F_CastSpellAIPA_24: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure PrefetchCastSpellActions(A1: Integer);  { draft }
    procedure CastingHeroesMax;  { draft }
    procedure ProcessStates;  { draft }
  end;

  { TAoWMapCampaignSettings (instance size 28, VMT 55723A60) }
  TAoWMapCampaignSettings = class(TEObject)
  public
    F_AoWMapCampaignSettings_08: Byte;
    F_AoWMapCampaignSettings_09: array[0..2] of Byte;
    F_AoWMapCampaignSettings_0C: Integer;
    F_AoWMapCampaignSettings_10: Integer;
    F_AoWMapCampaignSettings_14: Integer;
    F_AoWMapCampaignSettings_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TAoWCampaignTransferSettings (instance size 80, VMT 55723B34) }
  TAoWCampaignTransferSettings = class(TEObject)
  public
    F_AoWCampaignTransferSettings_08: Integer;
    F_AoWCampaignTransferSettings_0C: Integer;
    F_AoWCampaignTransferSettings_10: Integer;
    F_AoWCampaignTransferSettings_14: Integer;
    F_AoWCampaignTransferSettings_18: Integer;
    F_AoWCampaignTransferSettings_1C: Integer;
    F_AoWCampaignTransferSettings_20: Integer;
    F_AoWCampaignTransferSettings_24: Integer;
    F_AoWCampaignTransferSettings_28: Integer;
    F_AoWCampaignTransferSettings_2C: Integer;
    F_AoWCampaignTransferSettings_30: Integer;
    F_AoWCampaignTransferSettings_34: Integer;
    F_AoWCampaignTransferSettings_38: Integer;
    F_AoWCampaignTransferSettings_3C: Integer;
    F_AoWCampaignTransferSettings_40: Integer;
    F_AoWCampaignTransferSettings_44: Integer;
    F_AoWCampaignTransferSettings_48: Integer;
    F_AoWCampaignTransferSettings_4C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure SetLeader(A1: Integer);  { draft }
    procedure GenerateTransferUnits(A1: Integer);  { draft }
    procedure Retrieve;  { draft }
    procedure ClearSelection;  { draft }
    procedure AddItem(A1: Integer);  { draft }
    procedure DeleteItem(A1: Integer);  { draft }
    procedure AddHero(A1: Integer);  { draft }
    procedure DeleteHero(A1: Integer);  { draft }
    procedure AddUnit(A1: Integer);  { draft }
    procedure DeleteUnit(A1: Integer);  { draft }
    procedure SetSelectedTransferGold(A1: Integer);  { draft }
    procedure SetSelectedTransferMana(A1: Integer);  { draft }
    procedure SetupSelection(A1: Integer; A2: Integer);  { draft }
    procedure AutoSelect;  { draft }
    procedure ExecuteSelection;  { draft }
  end;

  { TAoWCampaignScenario (instance size 20, VMT 55723C14) }
  TAoWCampaignScenario = class(TEObject)
  public
    F_AoWCampaignScenario_08: Integer;
    F_AoWCampaignScenario_0C: Integer;
    F_AoWCampaignScenario_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAoWCampaignScenarioList (instance size 12, VMT 55723CFC) }
  TAoWCampaignScenarioList = class(TENode)
  public
    procedure GetScenario(A1: Integer);  { draft }
    procedure CreateUniqueID;  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure FindID;  { draft }
  end;

  { TAoWCampaign (instance size 52, VMT 55723E4C) }
  TAoWCampaign = class(TEObject)
  public
    F_AoWCampaign_08: Integer;
    F_AoWCampaign_0C: Byte;
    F_AoWCampaign_0D: array[0..2] of Byte;
    F_AoWCampaign_10: Integer;
    F_AoWCampaign_14: Integer;
    F_AoWCampaign_18: Integer;
    F_AoWCampaign_1C: Byte;
    F_AoWCampaign_1D: array[0..2] of Byte;
    F_AoWCampaign_20: Integer;
    F_AoWCampaign_24: Integer;
    F_AoWCampaign_28: Integer;
    F_AoWCampaign_2C: array[0..3] of Byte;
    F_AoWCampaign_30: Byte;
    F_AoWCampaign_31: Byte;
    F_AoWCampaign_32: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure CreateScenario; virtual;  { +04C draft }
    procedure GetAutoSaveFileName(A1: Integer; A2: Integer); virtual;  { +050 draft }
    procedure SelectNextScenario(A1: Integer); virtual;  { +054 draft }
    procedure ResetNextScenario; virtual;  { +058 draft }
    procedure StartScenario(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +05C draft }
    procedure SetupScenario; virtual;  { +060 draft }
    procedure FinishScenario; virtual;  { +064 draft }
    procedure RestartScenario; virtual;  { +068 draft }
    procedure AddScenario; virtual;  { +06C draft }
    procedure GetContainsMap;  { draft }
  end;

  { TDiplomaticAction (instance size 48, VMT 55723F48) }
  TDiplomaticAction = class(TEObject)
  public
    F_DiplomaticAction_08: Integer;
    F_DiplomaticAction_0C: Integer;
    F_DiplomaticAction_10: Byte;
    F_DiplomaticAction_11: Byte;
    F_DiplomaticAction_12: Byte;
    F_DiplomaticAction_13: Byte;
    F_DiplomaticAction_14: Byte;
    F_DiplomaticAction_15: array[0..2] of Byte;
    F_DiplomaticAction_18: Integer;
    F_DiplomaticAction_1C: Integer;
    F_DiplomaticAction_20: Integer;
    F_DiplomaticAction_24: Integer;
    F_DiplomaticAction_28: Integer;
    F_DiplomaticAction_2C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure ExecuteSend; virtual;  { +04C draft }
    procedure ExecuteAccept(A1: Integer; A2: Integer); virtual;  { +050 draft }
    procedure ExecuteReject; virtual;  { +054 draft }
    procedure ExecuteAI(A1: Byte); virtual;  { +058 draft }
    procedure CanSend(A1: Integer); virtual;  { +05C draft }
    procedure Send(A1: Integer); virtual;  { +060 draft }
    procedure CanAccept; virtual;  { +064 draft }
    procedure Accept(A1: Integer); virtual;  { +068 draft }
    procedure CanReject; virtual;  { +06C draft }
    procedure Reject(A1: Integer); virtual;  { +070 draft }
    procedure GetName(A1: Integer; A2: Integer);  { draft }
    procedure GetRelationModifier(A1: Integer; A2: Byte);  { draft }
    procedure CreateEventLog;  { draft }
    procedure UpdateAIDiplomaticActionsLog(A1: Byte; A2: Integer);  { draft }
  end;

  { TDiplomaticActionList (instance size 12, VMT 55724038) }
  TDiplomaticActionList = class(TEReferenceNode)
  public
    procedure GetDiplomaticActions(A1: Integer);  { draft }
    procedure FindLastAction(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { TDiplomaticActionTE (instance size 24, VMT 55724144) }
  TDiplomaticActionTE = class(TTokenEvent)
  public
    F_DiplomaticActionTE_10: Integer;
    F_DiplomaticActionTE_14: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure SetDiplomaticAction(A1: Integer);  { draft }
  end;

  { TDiplomaticActionEventLog (instance size 28, VMT 55724214) }
  TDiplomaticActionEventLog = class(TEventLog)
  public
    F_DiplomaticActionEventLog_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetText(A1: Integer); override;
    procedure GetTextColor; override;
    procedure GetLeftIcon; override;
    procedure GetMiddleIcon; override;
    procedure GetRightIcon; override;
    procedure GetVisible; override;
    procedure PlayLoggedSFX(A1: Integer); override;
    procedure NotifyLogged(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure SetDiplomaticAction(A1: Integer);  { draft }
  end;

  { TDiplomacyAIPA (instance size 24, VMT 55724318) }
  TDiplomacyAIPA = class(TAIPlayerAction)
  public
    F_DiplomacyAIPA_14: Byte;
    F_DiplomacyAIPA_15: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure CreateDA(A1: Byte; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ExecuteDiplomacy(A1: Integer);  { draft }
    procedure ListDebugInfo;  { draft }
  end;

  { TAoWDictionary (instance size 152, VMT 557243F4) }
  TAoWDictionary = class(TIvBinaryDictionary)
  public
  end;

  { TAoWEngine (instance size 128, VMT 557244F0) }
  TAoWEngine = class(THSEngine)
  public
    F_AoWEngine_58: Integer;
    F_AoWEngine_5C: Integer;
    F_AoWEngine_60: Integer;
    F_AoWEngine_64: Integer;
    F_AoWEngine_68: array[0..3] of Byte;
    F_AoWEngine_6C: Byte;
    F_AoWEngine_6D: Byte;
    F_AoWEngine_6E: Byte;
    F_AoWEngine_6F: array[0..0] of Byte;
    F_AoWEngine_70: Integer;
    F_AoWEngine_74: Integer;
    F_AoWEngine_78: Integer;
    F_AoWEngine_7C: Byte;
    F_AoWEngine_7D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure UpdateStartupDirectory; override;
    function TranslateText(const Text: string): string; override;
    procedure CreateHSSet; override;
    procedure SetHSMap(Value: HSEngine.THSMap); override;
    procedure CloseHSM(AProgress: Engine.TProgressEvent); override;
    procedure TranslateEObject(A1: Integer; A2: Integer);  { draft }
    procedure TranslateEObjectFromFile(A1: Integer; A2: Integer);  { draft }
    procedure ExportTextToFile(A1: Integer; A2: Integer);  { draft }
    procedure TranslateRStr(A1: Integer; A2: Integer);  { draft }
    procedure GetMajorVersion;  { draft }
    procedure GetMinorVersion;  { draft }
    procedure GetBuildNumber;  { draft }
    procedure SetVersion(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetVersionStr(A1: Integer);  { draft }
    procedure RegisteredVersion;  { draft }
    procedure RegisteredTo(A1: Integer);  { draft }
    procedure RequestAccess(A1: Integer; A2: Integer);  { draft }
    procedure CloseCampaign;  { draft }
    procedure LoadCampaignMap(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure LoadCampaign(A1: Integer);  { draft }
    procedure SaveCampaign(A1: Integer);  { draft }
    procedure NewCampaign(A1: Integer);  { draft }
  end;

  { TAgeOfWondersEngine (instance size 64, VMT 55724618) }
  TAgeOfWondersEngine = class(THexagonSpriteEngine)
  public
    F_AgeOfWondersEngine_3C: array[0..3] of Byte;
    destructor Destroy; override;
    procedure SetHSEngine(Value: HSEngine.THSEngine); override;
    procedure CreateEngine; override;
  end;

  { TStructureConstructionControl (instance size 8, VMT 557246C8) }
  TStructureConstructionControl = class(TConstructionControl)
  public
    procedure CanConstruct(A1: Integer; A2: Integer); override;
    procedure Construct(A1: Integer); override;
    procedure ValidateLocation(A1: Integer; A2: Integer); virtual;  { +05C draft }
    procedure StructureResource(A1: Integer; A2: Integer); virtual;  { +060 draft }
  end;

  { TConstructStructureTE (instance size 28, VMT 557247C0) }
  TConstructStructureTE = class(TTokenEvent)
  public
    F_ConstructStructureTE_10: Integer;
    F_ConstructStructureTE_14: Byte;
    F_ConstructStructureTE_15: array[0..2] of Byte;
    F_ConstructStructureTE_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TExportTextStream (instance size 44, VMT 55724894) }
  TExportTextStream = class(TEWriteTextStorageStream)
  public
    procedure rwString(var S: string; ID: Integer); override;
    procedure rwStrings(Strings: Classes.TStrings; ID: Integer); override;
  end;

  { TTranslateTextStream (instance size 40, VMT 55724960) }
  TTranslateTextStream = class(TTranslateStorageStream)
  public
    F_TranslateTextStream_24: Integer;
    procedure TranslateStrings(var Strings: Classes.TStrings); override;
    procedure TranslateString(var S: string); override;
  end;

  { TRebuildConstructionControl (instance size 8, VMT 55770A28) }
  TRebuildConstructionControl = class(TConstructionControl)
  public
    procedure GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure CanConstruct(A1: Integer; A2: Integer); override;
    procedure Construct(A1: Integer); override;
    procedure ID; override;
  end;

  { TBuildRoadsControl (instance size 8, VMT 55770AE0) }
  TBuildRoadsControl = class(TConstructionControl)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure CanConstruct(A1: Integer; A2: Integer); override;
    procedure Construct(A1: Integer); override;
    procedure ID; override;
  end;

  { TUnitResourceAbilityOwner (instance size 20, VMT 55784B80) }
  TUnitResourceAbilityOwner = class(TAbilityOwner)
  public
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); override;
  end;

  { THeroResourceAbilityOwner (instance size 20, VMT 55789DE8) }
  THeroResourceAbilityOwner = class(TAbilityOwner)
  public
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); override;
  end;

procedure TranslateRStr(A1: Integer; A2: Integer);  { draft }
procedure HitRole(A1: Integer);  { draft }
procedure HitRoleProbability(A1: Integer);  { draft }
procedure DMmaxDCtoDV(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure DMDCtoDV(A1: Integer; A2: Integer);  { draft }
procedure ExecuteDamageRole(A1: Integer; A2: Integer);  { draft }
procedure DVtoDEV(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
procedure StatisticsToMaxDamage(A1: Integer; A2: Word; A3: Integer; A4: Integer);  { draft }
procedure StatisticsToDV(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);  { draft }
procedure StatisticsToLimitedDV(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);  { draft }
procedure DistributeCombatEvent(A1: Integer; A2: Byte);  { draft }
procedure CreateDamageCA(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
procedure RetrieveDefaultDiplomaticActionMessage(A1: Integer; A2: Byte; A3: Byte);  { draft }
procedure MaximizeMovePointTable(A1: Integer; A2: Integer);  { draft }
procedure CreateArmyMoveTE(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
procedure CreateArmyMoveXYLTE(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);  { draft }
procedure MoveArmyEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
procedure MoveArmy;  { draft }
procedure MoveArmyXYL(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
procedure MoveArmyXYLEx(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);  { draft }
procedure Format(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure FmtTurnsStr(A1: Integer; A2: Integer);  { draft }
procedure FmtTurnsLeftStr(A1: Integer; A2: Integer);  { draft }
procedure FmtDaysStr(A1: Integer; A2: Integer);  { draft }
procedure FmtDaysLeftStr(A1: Integer; A2: Integer);  { draft }
procedure HitPointsToHitPcnt(A1: Integer; A2: Integer);  { draft }
procedure ShowHitPcnt(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
procedure ShowDamageIcon(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure ShowDamageEffects(A1: Word; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
procedure DamageEffectsAnimationFrames(A1: Word; A2: Integer; A3: Integer);  { draft }
procedure StatusToStatusValue(A1: Integer);  { draft }
procedure StatusValueToStatus(A1: Integer);  { draft }
procedure MoraleToMoraleValue(A1: Integer);  { draft }
procedure MoraleValueToMorale(A1: Integer);  { draft }
procedure dAlignmentsToStatus(A1: Byte; A2: Byte; A3: Integer);  { draft }
procedure DamageTypesToDamageType(A1: Word; A2: Integer; A3: Integer);  { draft }
procedure dAlignmentToStatus(A1: Integer; A2: Integer);  { draft }
procedure AlsToInt(A1: Byte; A2: Integer; A3: Integer);  { draft }
procedure IntToAls(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure Land(A1: Byte);  { draft }
procedure MoveTypesToInt(A1: Byte; A2: Integer; A3: Integer);  { draft }
procedure IntToMoveTypes(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure CombatRangeToCombatMode(A1: Byte);  { draft }
procedure PlaceRandomUnits(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);  { draft }
procedure FillWithRandomUnits(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
procedure FillWithRandomUnitIndexes(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
procedure TriggerStormDamage(A1: Byte; A2: Byte; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer);  { draft }
procedure RetrieveStormDamageInfo(A1: Integer; A2: Byte; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);  { draft }
procedure dAlignmentToDiplomaticRelation(A1: Integer; A2: Integer);  { draft }
procedure StatusToDiplomaticRelation(A1: Byte);  { draft }
procedure GetCombatSide(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
procedure AlignmentToIR(A1: Byte);  { draft }
procedure IRtoAlignment(A1: Integer);  { draft }
procedure DiplomaticRelation(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
procedure ValidAttackRelation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
procedure GetUnitIndexAIPriority(A1: Integer; A2: Byte; A3: Integer);  { draft }
procedure UnitsToIndependentRelation(A1: Integer; A2: Byte);  { draft }
procedure DegreesRadToCo(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
procedure Encode(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure SetupBattleFieldInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
procedure StrengthInfoMax(A1: Integer);  { draft }
procedure InvertDamageTypes(A1: Word);  { draft }
procedure ListMovementGaps(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
procedure GetMovepathBattleFieldStrength(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
procedure GetBattleFieldStrengthAdvantage(A1: Integer; A2: Integer; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer);  { draft }
procedure IgnitionChance(A1: Integer);  { draft }
procedure CreateEnhancementAbility(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure MeleeDamageTypes(A1: Integer);  { draft }
procedure StrikeDV(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure CreateStrikeCA(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure ValidateAoWEngine;  { draft }

resourcestring
  AWarRelationIsRequiredForXRStr = 'A state of WAR is required for %s';
  AcceptAllianceRStr = 'Accept alliance';
  AcceptRStr = 'Accept';
  AccumulateGoldRStr = 'Accumulate gold';
  AccumulateManaRStr = 'Accumulate mana';
  AdditionalDesignRStr = 'Additional Design';
  AfterLiberationOneUnitJoinedTheForcesOfXRStr = 'After liberation 1 unit joined the forces of %s';
  AfterLiberationXJoinedTheForcesOfYRStr = 'After liberation %s joined the forces of %s';
  AfterLiberationXunitsJoinedTheForcesOfYRStr = 'After liberation %d units joined the forces of %s';
  AgeOfWondersRStr = 'Age of Wonders';
  AggressiveRStr = 'Aggressive';
  AggressorRStr = 'Aggressor';
  AirMasteryRStr = 'Air Mastery';
  AirNodeRStr = 'Air Node';
  AirRStr = 'Air';
  AlignmentXRStr = 'Alignment: %s';
  AllPlayersRStr = 'All players';
  AllSlotsAreInUseRStr = 'All slots are in use...';
  AllianceAcceptedRStr = 'Alliance accepted';
  AllianceRStr = 'Alliance';
  AlliedVictoryXRStr = 'Allied victory: %s';
  AltarOfDeathRStr = 'Altar of Death';
  AltarOfFireRStr = 'Altar of Fire';
  AltarOfIceRStr = 'Altar of Ice';
  AltarOfLifeRStr = 'Altar of Life';
  AltarOfLightningRStr = 'Altar of Lightning';
  AltarOfPestilenceRStr = 'Altar of Pestilence';
  AlwaysFastCombatRStr = 'Always fast combat';
  AlwaysRStr = 'Always';
  AlwaysTacticalCombatRStr = 'Always tactical combat';
  AnarchyRStr = 'Anarchy';
  AndRStr = 'And';
  AnimateDeadRStr = 'Animate Dead';
  AnimateHeroRStr = 'Animate Hero';
  AnimateRuinsRStr = 'Animate Ruins';
  AnimatedRStr = 'Animated';
  AntiMagicShellRStr = 'Anti Magic Shell';
  AoWAlreadyRunningRStr = 'Age Of Wonders is already running';
  AoWEdRStr = 'AoWEd';
  ArenaRStr = 'Arena';
  ArmageddonRStr = 'Armageddon';
  ArmiesRStr = 'Armies';
  ArtistsRStr = 'Artists';
  AssignXNewSpheresRStr = 'Assign %s new spheres!';
  AttachmentDirectoryXRStr = 'Attachment directory: %s';
  AttackItemRStr = 'Attack item';
  AttackRStr = 'Attack';
  AutoRStr = 'Auto';
  AverageRStr = 'Average';
  AzracPluralRStr = 'Azracs';
  AzracRStr = 'Azrac';
  BardsSkillsRStr = 'Bard''s Skills';
  BaseIncomeRStr = 'Base Income';
  BasePowerRStr = 'Base Power';
  BerserkRStr = 'Fury';
  BetweenHumansRStr = 'Between Humans';
  BirdsViewRStr = 'Bird''s View';
  BizzRStr = 'Bizz';
  BlackCurseRStr = 'Black Curse';
  BlessRStr = 'Bless';
  BlessedRStr = 'Blessed';
  BloodShrineRStr = 'Blood Shrine';
  BloodlustRStr = 'Bloodlust';
  BribeRStr = 'Bribe';
  BuildXRStr = 'Build %s';
  BuildersGuildRStr = 'Builders Guild';
  BuildersGuildsRStr = 'Builder Guilds';
  BuildingWallsRStr = 'Building';
  BurningRStr = 'Burning';
  CPUEmperorRStr = 'CPU Emperor';
  CPUKingRStr = 'CPU King';
  CPUKnightRStr = 'CPU Knight';
  CPULordRStr = 'CPU Lord';
  CPUWarriorRStr = 'CPU Squire';
  CallHeroRStr = 'Call Hero';
  CallLightningRStr = 'Call Lightning';
  CampaignMapRStr = 'Campaign map';
  CampaignRStr = 'Campaign';
  CanOnlyBuildNextToWaterRStr = 'Can only be built next to water';
  CancelSpellResearchRStr = 'Cancels current spell research';
  CannotCastSpellInUndergoundRStr = 'Cannot cast spell underground';
  CannotDispelWhenSpellWardIsActiveRStr = 'Cannot dispel when Spell Ward is active';
  CannotInflicDamageRStr = 'Cannot Inflict Damage';
  CastXSpellRStr = 'Cast %s Spell';
  CasterMustBeInsideCityRStr = 'Can only cast from inside city';
  CastingCostRStr = 'Casting Cost';
  CastingPointsRStr = 'Channeling Points';
  CastingRStr = 'Casting';
  CastingReadyRStr = 'Casting Ready';
  CastleRuinRStr = 'Castle Ruin';
  CauseFearRStr = 'Cause Fear';
  CaveCrawlingRStr = 'Cave Crawling';
  CaveRStr = 'Cave';
  ChainLightningRStr = 'Chain Lighting';
  ChangePasswordRStr = 'Change Password';
  ChangeRStr = 'Change';
  ChangeSongEventRStr = 'Change Song Event';
  ChargingRStr = 'Charging';
  CheerfulRStr = 'Cheerful';
  ChooseRStr = 'Choose';
  CitiesRStr = 'Cities';
  CityBattleDrawnRStr = 'Battle of %s drawn';
  CityBattleLostRStr = 'Battle of %s lost';
  CityBattleWonRStr = '%s captured';
  CityFortifiedRStr = '%s fortified';
  CityFortifyRStr = 'Improves town defenses. Ground based attackers must breach the wall to enter town. First level of fortification is a wooden pallisade, the second level is a stone wall.';
  CityFreeJoinRStr = 'The city council eagerly vows its loyalty and awaits your orders.';
  CityJoinHeaderRStr = 'A herald from %s:';
  CityLootRStr = 'Pillages the town, taking 1 turn per city hex, after which the town is turned to ruins. The amount of gold depends on the city size. Looting decreases your relation with the population''s race!';
  CityLootedRStr = '%0:s looted (%1:s gold gained)';
  CityLootingRStr = '%s is being looted';
  CityMigratedToRStr = '%0:s migrated to %1:s';
  CityOfXRStr = 'city of %s';
  CityRStr = 'City';
  CityRazeRStr = 'Destroys the town instantly by burning it to the ground. Razing is faster as the loot option, but doens''t deliver any gold. Razing decreases your relation with the population''s race!';
  CityRebellionRStr = '%s rebelled';
  CityTradeRStr = 'When producing merchandise, a city''s income increases by 25%.';
  CityTributeJoinRStr = 'The city council offers its allegiance for %s pieces of gold.';
  CityUpgradeRStr = 'Upgrades the infrastructure of the town with the technology to buy more powerful units.';
  ClassicRStr = 'Classic';
  ClickToBeginRStr = 'Click to begin';
  CloseRStr = 'Close';
  CoDevelopedByRStr = 'Co-developed by:';
  CoPublishedByRStr = '                ';
  ColdImmunityRStr = 'Cold Immunity';
  ColdProtectionRStr = 'Cold Protection';
  ColdRStr = 'Cold';
  CombatRStr = 'Combat';
  CommonRStr = 'Common';
  ConcealAreaRStr = 'Conceal Area';
  ConcealmentRStr = 'Concealment';
  ConfirmPasswordRStr = 'Confirm Password';
  ConfirmationFailedRStr = 'Confirmation failed';
  ConquerLocationsRStr = 'Conquer locations';
  ConquerTheMapRStr = 'Conquer the map';
  ContentRStr = 'Content';
  ContinueRStr = 'Continue';
  CosmeticSurgeryOnXRStr = 'Cosmagic Surgery on %s';
  CosmosRStr = 'Cosmos';
  CostXRStr = 'Cost: %d';
  CouldntChangePasswordRStr = 'Couldn''t change password!';
  CreateNewLibraryRStr = 'Create New Library';
  CreatureRStr = 'Creature';
  CreaturesRStr = 'Creatures';
  CropRStr = 'Crops';
  CrusadeRStr = 'Crusade';
  CrusaderRStr = 'Crusader';
  CryptRStr = 'Crypt';
  CurrentRStr = 'Current';
  CurrentlyResearchingRStr = 'Currently Researching';
  CurseRStr = 'Curse';
  CursedRStr = 'Cursed';
  CustomMapRStr = 'Custom map';
  CustomizeLeaderRStr = 'Customize Leader';
  DarkElfPluralRStr = 'Dark Elves';
  DarkElfRStr = 'DarkElf';
  DarkGiftRStr = 'Dark Gift';
  DayRStr = 'Day';
  DayXRStr = 'Day %d';
  DaysRStr = 'Days';
  DeadOakRStr = 'Dead Oak';
  DeadPineRStr = 'Dead Pine';
  DeadTrunkRStr = 'Dead Trunk';
  DeathImmunityRStr = 'Death Immunity';
  DeathMasteryRStr = 'Death Mastery';
  DeathNodeRStr = 'Death Node';
  DeathProtectionRStr = 'Death Protection';
  DeathRStr = 'Death';
  DeathRayRStr = 'Death Ray';
  DeathStormRStr = 'Death Storm';
  DebugSaveDisabledRStr = 'Debug save disabled';
  DebugSaveEnabledRStr = 'Debug save enabled';
  DecayRStr = 'Decay';
  DeclineRStr = 'Decline';
  DefaultRStr = 'Default';
  DefeatRStr = 'Defeat';
  DefendRStr = 'Defend';
  DefenderRStr = 'Defender';
  DefenseItemRStr = 'Defense item';
  DefensiveRStr = 'Defensive';
  DeformFaceRStr = 'Cosmagic Surgery';
  DeleteRStr = 'Delete';
  DemoVersionMessageRStr = 'Sorry, this function isn''t available in the demo.';
  DesertConcealmentRStr = 'Desert Concealment';
  DesignerAndDirectorRStr = 'Designer & Director';
  DesktopWindowRStr = 'Desktop Window';
  DestroyAllEnemiesRStr = 'Destroy all enemies';
  DevelopedByRStr = 'Developed by';
  DiplomacyRStr = 'Diplomacy';
  DisabledRStr = 'Disabled';
  DiseaseCloudRStr = 'Disease Cloud';
  DisjunctionRStr = 'Disjunction';
  DivineDraftRStr = 'Divine Draft';
  DivineStormRStr = 'Divine Storm';
  DoneRStr = 'Done';
  DragonRStr = 'Dragon';
  DrinkRStr = 'Drink';
  DungeonExploredRStr = 'Dungeon Explored';
  DungeonPrisonersJoinHeaderRStr = 'A rescued prisoner steps forward:';
  DungeonRStr = 'Dungeon';
  DwarfPluralRStr = 'Dwarves';
  DwarfRStr = 'Dwarf';
  EarthMasteryRStr = 'Earth Mastery';
  EarthNodeRStr = 'Earth Node';
  EasyRStr = 'Easy';
  EditorRStr = 'Editor';
  ElfPluralRStr = 'Elves';
  ElfRStr = 'Elf';
  EmptyQueueRStr = '<empty>';
  EnabledRStr = 'Enabled';
  EnchantWeaponRStr = 'Enchant Weapon';
  EnchantedRoadsRStr = 'Enchanted Roads';
  EnchantedWeaponRStr = 'Enchanted Weapon';
  EnchantmentRStr = 'Enchantment';
  EnhancementRStr = 'Enhancement';
  EnhancementsRStr = 'Enhancements';
  EntangledRStr = 'Entangled';
  EnterLibraryNameRStr = 'Enter library name';
  EnterNewPasswordRStr = 'Enter new password:';
  EnterPasswordRStr = 'Enter password:';
  EnterRStr = 'Enter';
  EuropeRStr = '      ';
  EvilRStr = 'Evil';
  ExceptionalRStr = 'Exceptional';
  ExecuteRStr = 'Execute';
  ExitRStr = 'Exit';
  ExpandRStr = 'Expand';
  ExpanderRStr = 'Expander';
  ExploredRStr = 'Explored';
  ExternalIncomeRStr = 'External Income';
  ExtraLargeMapAbrRStr = 'XL';
  ExtraPowerRStr = 'Extra Power';
  FarmBattleWonRStr = 'Farm captured';
  FarmRStr = 'Farm';
  FarmsRStr = 'Farms';
  FearlessRStr = 'Fearless';
  FileNameXRStr = 'File name: %s';
  FinishRStr = 'Finish';
  FireAuraRStr = 'Fire Halo';
  FireBallRStr = 'Fireball';
  FireBarrierRStr = 'Fire Barrier';
  FireImmunityRStr = 'Fire Immunity';
  FireMasteryRStr = 'Fire Mastery';
  FireNodeRStr = 'Fire Node';
  FireProtectionRStr = 'Fire Protection';
  FireStormRStr = 'Fire Storm';
  FixedRStr = 'Fixed';
  FlagMessageEventRStr = 'Flag Message Event';
  FlamingArrowRStr = 'Flaming Arrow';
  FloatingRStr = 'Floating';
  FloodRStr = 'Flood';
  FlowerRStr = 'Flower';
  FlyingRStr = 'Flying';
  ForXGoldRStr = 'For %s gold';
  ForcedRStr = '(forced)';
  ForestryRStr = 'Forestry';
  FortifyRStr = 'Fortify';
  FortifyingRStr = 'Fortifying';
  FountainOfLifeRStr = 'Fountain Of Life';
  FreeMovementRStr = 'Free Movement';
  FreeRStr = 'Free';
  FreezeRStr = 'Freeze';
  FreezeWaterRStr = 'Freeze Water';
  FrequentRStr = 'Frequent';
  FriendlyRStr = 'Friendly';
  FromTheRStr = 'From the %s';
  FrostBeamsRStr = 'Frost Beam';
  FrostlingPluralRStr = 'Frostlings';
  FrostlingRStr = 'Frostling';
  FrozenRStr = 'Frozen';
  FullScreenRStr = 'Full Screen';
  FuryRStr = 'Fury';
  GalaxySoundSystemRStr = 'Galaxy Sound System';
  GameOverDefeatEventLogRStr = '%s is defeated!';
  GameOverVictoryEventLogRStr = '%s is victorious!';
  GameSuccessfullySentRStr = 'Game successfully sent';
  GameTerminatedRStr = 'Game terminated';
  GametypeXRStr = 'Game type: %s';
  GenerateExtraPowerRStr = 'Generate Extra Power';
  GenerateExtraPowerTextRStr = 'Increases the power generated by the node by 25%.';
  GeneratingExtraPowerRStr = 'Generating Extra Power';
  GeneratingXPowerRStr = 'Generating %s power';
  GeyserRStr = 'Geyser';
  GlobalRStr = 'Global';
  GoDownRStr = 'Go Down';
  GoUpRStr = 'Go Up';
  GoblinPluralRStr = 'Goblins';
  GoblinRStr = 'Goblin';
  GoldFoundRStr = '%s gold pieces found';
  GoldRStr = 'Gold';
  GoldRushRStr = 'Gold Rush';
  GoodRStr = 'Good';
  GrassConcealmentRStr = 'Grass Concealment';
  GreatHailRStr = 'Great Hail';
  GuardAreaRStr = 'Guard Area';
  GuardRStr = 'Guard';
  HalflingPluralRStr = 'Halflings';
  HalflingRStr = 'Halfling';
  HandicapRStr = 'Handicap';
  HardRStr = 'Hard';
  HarmonyRStr = 'Tranquility';
  HasteRStr = 'Haste';
  HatredRStr = 'Hatred';
  HeadItemRStr = 'Head item';
  HealingShowersRStr = 'Healing Showers';
  HealingWaterRStr = 'Healing Water';
  HeatWaveRStr = 'Heat Wave';
  HelpRStr = 'Help';
  HeroRStr = 'Hero';
  HeroUpgradeRStr = 'Hero upgrade';
  HiddenmovementPleaseWaitRStr = 'Hidden movement, please wait';
  HighPrayerBlessingRStr = 'Blessed';
  HighPrayerRStr = 'High Prayer';
  HighRStr = 'High';
  HighmanPluralRStr = 'Highmen';
  HighmanRStr = 'Highman';
  HolyChampionRStr = 'Holy Champion';
  HolyFearRStr = 'Holy Fear';
  HolyGroundDamageRStr = 'Holy Ground Damage';
  HolyGroundRStr = 'Holy Ground';
  HolyGroundsRStr = 'Holy Woods';
  HolyImmunityRStr = 'Holy Immunity';
  HolyProtectionRStr = 'Holy Protection';
  HolyRStr = 'Holy';
  HostileRStr = 'Hostile';
  HotSeatRStr = 'Hot Seat';
  HumanPluralRStr = 'Humans';
  HumanRStr = 'Human';
  HumanoidRStr = 'Humanoid';
  HumanoidsRStr = 'Humanoids';
  HuntRStr = 'Hunt';
  HurlFireSkullRStr = 'Hurl Fire Skull';
  IPXRStr = 'IPX';
  IceShardsRStr = 'Ice Shards';
  IceStormRStr = 'Ice Storm';
  IdleRStr = 'Idle';
  IgnitionRStr = 'Ignition';
  IncomeRStr = 'Income';
  IncomeXRStr = 'Income: %s';
  IncompatibleVersionRStr = 'Incompatible Version';
  IndependentRStr = 'Independent';
  InstallRStr = 'Install';
  InstallingRStr = 'Installing';
  InstantRStr = 'Instant';
  InternetLanRStr = 'Internet/Lan';
  InternetMailSuiteRStr = 'Internet Mail Suite';
  IntroVoiceRStr = 'Intro Voice';
  InvalidLocationSpecifiedRStr = 'invalid location specified';
  InvalidPasswordRStr = 'Invalid password';
  InvisibilityRStr = 'Invisibility';
  ItemsExploredRStr = '"From the %s","you recovered the following items:"';
  ItemsFoundRStr = 'Items Found';
  ItemsRStr = 'Items';
  KillTheLeadersRStr = 'Kill enemy leaders';
  LargeMapAbrRStr = 'L';
  LeadProgrammerRStr = 'Lead Programmer';
  LeadScenarioDesignerRStr = 'Lead Scenario Designer';
  LeaderOfTheXRStr = 'Leader of the %s';
  LeaderRStr = 'Leader';
  LevelRStr = 'Level';
  LevelTerrainRStr = 'Level Terrain';
  LevelXRStr = 'Level %s';
  LiberatePrisonerMessageRStr = 'In gratitude for rescue, the captive offers to join you. Do you accept?';
  LiberatePrisonersMessageRStr = 'Grateful to be rescued, the captives offer to join you. Do you accept?';
  LifeDrainRStr = 'Life Drain';
  LifeMasteryRStr = 'Life Mastery';
  LifeNodeRStr = 'Life Node';
  LifeRStr = 'Life';
  LightningImmunityRStr = 'Lightning Immunity';
  LightningProtectionRStr = 'Lightning Protection';
  LightningRStr = 'Lightning';
  LightningStormRStr = 'Lightning Storm';
  LiquidFormRStr = 'Liquid Form';
  LizardPluralRStr = 'Lizards';
  LizardRStr = 'Lizard';
  LoadGameRStr = 'Load Game';
  LoadingMapDataRStr = 'Loading Map';
  LoadingXRStr = 'Loading: %s...';
  LocalRStr = 'Single Computer';
  LongRangeRStr = 'Long Range';
  LootRStr = 'Loot';
  LootingRStr = 'Looting';
  LowSytemResourcesRStr = 'Low System Resources! Age of Wonders requires at least 50MB of free virtual memory.  Please close down other programs, free up disk space, and/or reboot before trying to play the game again.';
  MachineRStr = 'Machine';
  MachinesRStr = 'Machines';
  MagicImmunityRStr = 'Magic Immunity';
  MagicProtectionRStr = 'Magic Protection';
  MagicRStr = 'Magic';
  MagicSanctuaryRStr = 'Magic Sanctuary';
  ManaCrystalsFoundRStr = '%s mana crystals found';
  ManaCrystalsRStr = 'Mana Crystals';
  ManaPoolRStr = 'Mana Pool';
  MapRStr = 'Map';
  MarksmanshipRStr = 'Marksmanship';
  MaxFortifyLevelReachedRStr = 'Max. fortify level reached.';
  MaxUpgradeLevelReachedRStr = 'Max. upgrade level reached.';
  MaximumPlayerHeroesXRStr = 'Maximum player heroes: %s';
  MaximumSphereLevelXRStr = 'Maximum sphere level: %s';
  MediumMapAbrRStr = 'M';
  MediumRangeRStr = 'Medium Range';
  MeleeRStr = 'Melee';
  MerchantRStr = 'Merchant';
  MessageFromXRStr = 'Message from %s';
  MessageReceivedRStr = 'Message Received';
  MigrateRStr = 'Migrate';
  MigrateToXRStr = 'Migrate to %s';
  MigratingRStr = 'Migrating';
  MigratingToXRStr = 'Migrating to %s';
  MindDecayRStr = 'Mind Decay';
  MineBattleWonRStr = 'Mine captured';
  MineRStr = 'Mine';
  MinesRStr = 'Mines';
  MissingPlayerRStr = 'Missing player %d';
  ModemRStr = 'Modem';
  MonsterLairRStr = 'Monster Lair';
  MoraleRStr = 'Morale';
  MoraleXRStr = 'Morale: %s';
  MountaineeringRStr = 'Mountaineering';
  MovementRStr = 'Movement';
  MusicRStr = 'Music';
  NameRStr = 'Name';
  NaturesBlessingRStr = 'Nature''s Blessing';
  NeutralRStr = 'Neutral';
  NeverRStr = 'Never';
  NextPlayerXRStr = 'Next Player: %s';
  NextRStr = 'Next';
  NightVisionRStr = 'Night Vision';
  NoContactRStr = 'No Contact';
  NoGlobalOpponentEnchantmentsActiveRStr = 'No global opponent enchantments active';
  NoHeroAnsweredYourCallRStr = 'No hero answered your call';
  NoHeroAnswersYourCallRStr = 'Nobody answers your call...';
  NoJoinAnimateRStr = 'Who dares to call me! Do you really think I would serve you?!';
  NoJoinResurrectionRStr = 'I needed that... Goodbye.';
  NoLimitRStr = 'No Limit';
  NoNameSpecifiedRStr = 'no name specified';
  NoSummonLocationFoundRStr = 'No nearby summon location found';
  NoTimerRStr = 'No Timer';
  NonameRStr = 'Noname';
  NormalRStr = 'Normal';
  NorthAmericaRStr = '             ';
  NotImplementedRStr = 'Not implemented';
  NotImplementedYetRStr = 'Not implemented yet...';
  OKRStr = 'OK';
  OakRStr = 'Oak';
  ObjectiveValidationFailedRStr = 'Objective (%s) failed with message: %s';
  ObjectiveXRStr = 'Objective: %s';
  OccupationForcesXRStr = 'Occupation Forces: %s';
  OkayRStr = 'Okay';
  OneMomentPleaseRStr = 'One moment please...';
  OnePrisonerLiberatedRStr = '1 prisoner liberated';
  OneUnitTrainedRStr = '1 unit trained';
  OozeRStr = 'Ooze';
  OpenRStr = 'Open';
  OppressedRStr = 'Oppressed';
  OptionsRStr = 'Options';
  OrcPluralRStr = 'Orcs';
  OrcRStr = 'Orc';
  OverlayObjectRStr = 'Overlay Object';
  PanickedRStr = 'Panicked';
  PartyOwnerXRStr = 'Party Owner: %s';
  PassWallRStr = 'Pass Wall';
  PassiveRStr = 'Passive';
  PasswordConfirmationRStr = 'Password confirmation';
  PasswordVerificationRStr = 'Password Verification';
  PathOfDecayRStr = 'Path Of Decay';
  PathOfFrostRStr = 'Path Of Frost';
  PathOfLifeRStr = 'Path Of Life';
  PatrolRStr = 'Patrol';
  PestilenceRStr = 'Pestilence';
  PestilenceStormRStr = 'Pestilence cloud';
  PhaseRStr = 'Phase';
  PhysicalImmunityRStr = 'Physical Immunity';
  PhysicalProtectionRStr = 'Physical Protection';
  PhysicalRStr = 'Physical';
  PickupRStr = 'Pickup';
  PineRStr = 'Pine';
  PlayByEmailRStr = 'Play by email';
  PlaySampleEventRStr = 'Play Sample';
  PlayerNameXRStr = 'Player name: %s';
  PlayersOnMapXRStr = 'Players on map: %s';
  PleaseAssignAllSpheresRStr = 'Please assign all spheres!';
  PleaseFillInAllSettingsRStr = 'Please fill in all settings.';
  PleaseInsertTheAoWCDRStr = 'Please insert the Age of Wonders CD.';
  PleaseInsertTheAoWCDRetryRStr = 'Couldn''t find the Age of Wonders CD, do you want to retry?';
  PleaseSetupEmailSettingsFirstRStr = 'Please setup email settings first!';
  PoisonCloudDamageRStr = 'Poison Cloud Damage';
  PoisonCloudRStr = 'Poison Cloud';
  PoisonImmunityRStr = 'Poison Immunity';
  PoisonPlantDamageRStr = 'Poison Plant Damage';
  PoisonPlantRStr = 'Poison Plant';
  PoisonPlantsRStr = 'Poison Plants';
  PoisonProtectionRStr = 'Poison Protection';
  PoisonRStr = 'Poison';
  PoisonedRStr = 'Poisoned';
  PoliteRStr = 'Polite';
  PoorRStr = 'Poor';
  PopulationRStr = 'Population';
  PowerLeakRStr = 'Power Leak';
  PowerNodeBattleWonRStr = 'Power Node captured';
  PowerNodeRStr = 'Power Node';
  PowerRStr = 'Power';
  PowerXRStr = 'Power: %s';
  PrisonerLiberationRStr = 'Prisoner Liberation';
  ProduceMerchandiseRStr = 'Produce Merchandise';
  ProduceMerchandiseTextRStr = 'When producing merchandise the income is increased by 25%.';
  ProduceRStr = 'Produce';
  ProducingMerchandiseRStr = 'Producing Merchandise';
  ProducingRStr = 'Producing';
  ProducingXIncomeRStr = 'Producing %s income';
  ProductionPlaceXRazeRStr = 'Destroys the %s instantly by burning it to the ground.';
  ProgrammerRStr = 'Programmer';
  PropertiesRStr = 'Properties';
  PublishedByRStr = 'Published by';
  PureEvilRStr = 'Pure Evil';
  PureGoodRStr = 'Pure Good';
  PureNeutralRStr = 'Pure Neutral';
  PyramidRStr = 'Pyramid';
  QACoreRStr = 'QA Core';
  QueueRStr = 'Queue';
  RaceRelationXRStr = 'Race Relation: %s';
  RaceXHaveNoValidCaptureLocationRStr = '%s have no valid capture locations';
  RaceXRStr = 'Race: %s';
  RaceXReachedGoldAmountRStr = '%s reached the gold amount for victory';
  RaidRStr = 'Raid';
  RaiseTerrainRStr = 'Raise Terrain';
  RaisedMountainRStr = 'Raised Mountain';
  RandomNodeRStr = 'Random Node';
  RandomRStr = 'Random';
  RareRStr = 'Rare';
  RazeRStr = 'Raze';
  RazedRStr = 'Razed';
  ReadyRStr = 'Ready';
  RecallSpiritRStr = 'Recall Spirits';
  RecipientXRStr = 'Recipient: %s';
  RedDragonRStr = 'Red Dragon';
  ReenterNewPasswordRStr = 'Confirm new password:';
  ReenterPasswordRStr = 'Confirm password:';
  ReflectingPoolRStr = 'Reflecting Pool';
  RefugeRStr = 'Refuge';
  RegenerationRStr = 'Regeneration';
  RejectRStr = 'Reject';
  RejuvenateRStr = 'Rejuvenate';
  RemedyRStr = 'Remedy';
  RepeatRStr = 'Repeat';
  ReplayRStr = 'Replay';
  RequiredManaRStr = 'Required Mana';
  ResearchNewSpellRStr = 'Research new spell';
  ResearchPointsRStr = 'Research Points';
  ResearchRStr = 'Research';
  ResearchSpellRStr = 'Research Spell';
  ResearchXspellRStr = 'Research %s Spell';
  ResearchedRStr = 'Researched';
  ResurrectHeroRStr = 'Resurrect Hero';
  ResurrectedRStr = 'Resurrected';
  RingItemRStr = 'Ring item';
  RuinRStr = 'Ruin';
  SacredWrathRStr = 'Sacred Wrath';
  SacrificialFlameRStr = 'Sacrificial Flame';
  SailingRStr = 'Sailing';
  SaveGameAsRStr = 'Save game as...';
  SaveRStr = 'Save';
  ScenarioDesignersRStr = 'Scenario Designers';
  ScenarioRStr = 'Scenario';
  ScenarioXRStr = 'Scenario: %s';
  ScorchRStr = 'Scorch';
  ScorcherRStr = 'Scorcher';
  ScoutRStr = 'Scout';
  SearchRStr = 'Search';
  SecretRStr = 'Secret';
  SelectAFileToLoadRStr = 'Select a File to Load...';
  SelectAMapRStr = 'Select a Map...';
  SelectRStr = 'Select';
  SelectTargetCityForXOnMapRStr = 'Select target city for %s on map.';
  SelectTargetLocationForXOnMapRStr = 'Select target location for %s on map.';
  SelectTargetRStr = 'Select Target';
  SelectUnitForDispelMagicRStr = 'Select unit for "Dispel Magic"';
  SelectedSpheresRStr = 'Selected Spheres';
  SendingEmailGameRStr = 'Sending email game...';
  SerialRStr = 'Serial';
  ShipyardRStr = 'Shipyard';
  ShockwaveRStr = 'Shock Wave';
  ShortRangeRStr = 'Short Range';
  ShowMessageEventRStr = 'Show Message Event';
  SignRStr = 'Sign';
  SimultaneousRStr = 'Simultaneous';
  SkillPointsRStr = 'Skill Points';
  SkirmishRStr = 'Skirmish';
  SlaveryRStr = 'Enslaved';
  SlowRStr = 'Slow';
  SlugSlimeRStr = 'Slug Slime';
  SmallMapAbrRStr = 'S';
  SmokeCloudRStr = 'Cloud of Ashes';
  SnowConcealmentRStr = 'Snow Concealment';
  SolarBlastRStr = 'Solar Blast';
  SolarFlareRStr = 'Solar Flare';
  SoundFXRStr = 'Sound FX';
  SourceLibraryXRStr = 'Source Library: %s';
  SpecialThanksRStr = 'Special Thanks';
  SpellIsAlreadyResearchedRStr = 'Spell already researched';
  SpellRStr = 'Spell';
  SpellWardRStr = 'Spell Ward';
  SplitOnEnterCaveWarningRStr = 'Entering the cave will split your party. Do you wish to continue?';
  SpringOfLifeRStr = 'Spring of Life';
  StableRStr = 'Stable';
  StatusRStr = 'Status';
  StatusWarmodeRStr = 'Status: Warmode';
  StatusXRStr = 'Status: %s';
  Step1CustomizeLeaderRStr = 'Step 1: Customize Leader';
  Step2AssignSkillPointsRStr = 'Step 2: Assign Skill Points';
  Step3AssignSpheresRStr = 'Step 3: Assign Spheres';
  SteppeConcealmentRStr = 'Steppe Concealment';
  StoneSkinRStr = 'Stone Skin';
  StoningRStr = 'Stoning';
  StormRStr = 'Storm';
  StoryAndEditingRStr = 'Story and Editing';
  StrongRStr = 'Strong';
  StunnedRStr = 'Stunned';
  SuggestSplitWithYRStr = 'Suggest split with %s';
  SuicidalRStr = 'Suicidal';
  SuicidedRStr = 'Commited Suicide';
  SummonAirElementalRStr = 'Summon Air Elemental';
  SummonBlackDragonRStr = 'Summon Black Dragon';
  SummonBlackSpiderRStr = 'Summon Black Spider';
  SummonBoarRStr = 'Summon Boar';
  SummonEarthElementalRStr = 'Summon Earth Elemental';
  SummonFireElementalRStr = 'Summon Fire Elemental';
  SummonFireSpriteRStr = 'Summon Fire Sprite';
  SummonFrogRStr = 'Summon Frog';
  SummonGoldDragonRStr = 'Summon Gold Dragon';
  SummonGreatEagleRStr = 'Summon Great Eagle';
  SummonMermaidRStr = 'Summon Mermaid';
  SummonSyronRStr = 'Summon Syron';
  SummonWaterElementalRStr = 'Summon Water Elemental';
  SummonedRStr = 'Summoned';
  SurrenderYourEmpireRStr = 'Surrender your empire?';
  SwarmRStr = 'Swarm';
  SwimmingRStr = 'Swimming';
  TCPIPRStr = 'TCP/IP';
  TakenRStr = '(taken)';
  TargetRStr = 'Target';
  TeleportRStr = 'Teleport';
  TerrainBonusXRStr = 'Terrain Bonus: %s';
  TerrainPenaltyXRStr = 'Terrain Penalty: %s';
  TerribleRStr = 'Terrible';
  TerrorRStr = 'Terror';
  TheLeaderStepsForewardRStr = 'The leader of the party steps forward:';
  TheXliesInRuinsRStr = 'The %s lies in ruins.';
  TheyTaughtYouTheSpellXRStr = 'They taught you the spell %s';
  TitleRStr = 'Title';
  ToadRStr = 'Toad';
  TornadoRStr = 'Tornado';
  TorsoItemRStr = 'Torso item';
  TotalCostXRStr = 'Total Cost: %s';
  TouchRStr = 'Touch';
  TowerRStr = 'Tower';
  TownGateRStr = 'Town Gate';
  TownQuakeDamageRStr = 'Town Quake Damage';
  TownQuakeRStr = 'Town Quake';
  TrailOfDarknessRStr = 'Trail Of Darkness';
  TrainingCompletedRStr = 'Training completed';
  TransparentRStr = 'Transparent';
  TransportRStr = 'Transport';
  TremorsRStr = 'Tremors';
  TrueVisionRStr = 'True Seeing';
  TunnelingRStr = 'Tunneling';
  TurnModeXRStr = 'Turn mode: %s';
  TurnRStr = 'Turn';
  TurnedUndeadRStr = 'Turned Undead';
  TurnsRStr = 'Turns';
  TurnsXRStr = 'Turns: %s';
  TutorialMessageEventRStr = 'Tutorial Message Event';
  TutorialRStr = 'Tutorial';
  UnavailableRStr = 'Unavailable';
  UncommonRStr = 'Uncommon';
  UndergroundConcealmentRStr = 'Underground Concealment';
  UnexploredRStr = 'Unexplored';
  UnholyChampionRStr = 'Unholy Champion';
  UnholyGroundDamageRStr = 'Unholy Ground Damage';
  UnholyGroundRStr = 'Unholy Ground';
  UnholyGroundsRStr = 'Evil Woods';
  UniqueRStr = 'Unique';
  UnitRStr = 'Unit';
  UnlimitedRStr = 'Unlimited';
  UnrestRStr = 'Unrest';
  UnrulyRStr = 'Unruly';
  UpgradeLevelXRStr = 'Upgrade Level: %s';
  UpgradeRStr = 'Upgrade';
  UpgradingRStr = 'Upgrading';
  UpkeepRStr = 'Upkeep';
  UpkeepXRStr = 'Upkeep: %d';
  UseItemRStr = 'Use item';
  UseXRStr = 'Use %s';
  UserRStr = 'user';
  VaporizeRStr = 'Vaporize';
  VersionXRStr = 'Version: %s';
  VersionXYRequiredRStr = '(Version %0:s.%1:s required)';
  VersusRStr = 'vs.';
  VertigoRStr = 'Vertigo';
  VeryRareRStr = 'Very Rare';
  VictoryRStr = 'Victory';
  ViewallTCRStr = 'View all TC';
  VisionRStr = 'Vision';
  VortexDamageRStr = 'Vortex Damage';
  VortexRStr = 'Vortex';
  WalkingRStr = 'Walking';
  WallBreachRStr = 'Wall Breach';
  WallClimbingRStr = 'Wall Climbing';
  WallRStr = 'Wall';
  WarmodeRStr = 'Warmode';
  WarmongerRStr = 'Warmonger';
  WarpPartyRStr = 'Warp Party';
  WaryRStr = 'Wary';
  WastelandConcealmentRStr = 'Wasteland Concealment';
  WatcherRStr = 'Watcher';
  WaterConcealmentRStr = 'Water Concealment';
  WaterHexagonRStr = 'Water/Ice Hexagon';
  WaterMasteryRStr = 'Water Mastery';
  WaterNodeRStr = 'Water Node';
  WaterWalkingRStr = 'Water Walking';
  WeakRStr = 'Weak';
  WebbedRStr = 'Webbed';
  WillowRStr = 'Willow';
  WindWalkingRStr = 'Wind Walking';
  WindsOfFuryRStr = 'Winds Of Fury';
  WizardsTowerRStr = 'Wizards Tower';
  WonRStr = 'Won';
  WraithsDelightRStr = 'Wraith''s delight';
  WriterRStr = 'Writer';
  XAlreadyActiveRStr = '%s already active';
  XAlreadyExistsRStr = '%s already exists';
  XAlreadyRemovedRStr = '%s already removed';
  XAnimatedRStr = '%s animated';
  XCropFieldsRStr = '%s Crop Fields';
  XExploredRStr = '%s explored';
  XGoldRStr = '%s gold';
  XHostYRStr = '%0:s Host: %1:s';
  XInstalledAtYRStr = '%0:s installed at %1:s';
  XLiberatedRStr = '%s liberated';
  XMinutesRStr = '%s minutes';
  XOverthrownRStr = '%s overthrown';
  XPowerRStr = '%s power';
  XPrisonersLiberatedRStr = '%s prisoners liberated';
  XProducedAtYRStr = '%0:s produced at %1:s';
  XRazedRStr = '%s razed';
  XRelationMinusYRStr = '%s Relation %d';
  XRelationPlusYRStr = '%s Relation +%d';
  XResurrectedRStr = '%s resurrected';
  XSelectedRStr = '%s selected';
  XSpellsRStr = '%s Spells';
  XSuccessfullyDispelledRStr = '%s successfully dispelled';
  XUnitsTrainedRStr = '%s units trained';
  XUpgradedRStr = '%s upgraded';
  XinYdaysRStr = '%s in %d day(s)';
  XsGameRStr = '%s''s Game';
  XtimeYSphereRStr = '%0:sx %1:s sphere';
  YouCannotChannelPowerFromThisNodeRStr = 'You cannot channel power from this node';
  YouNeed2HumanPlayersToPlayAnEmailGameRStr = 'You need 2 human players to play an email game.';
  YouWereEjectedByTheHostRStr = 'You were ejected by the host.';
  YouWhereVictoriousRStr = 'you were victorious!';
  YourReignHasEndedRStr = 'your reign has ended!';
  spRStr = 'sp';

implementation

{$I inc\P1.inc}
{$I inc\P2.inc}
{$I inc\P3.inc}
{$I inc\P4.inc}
{$I inc\P5.inc}

initialization
finalization

end.
