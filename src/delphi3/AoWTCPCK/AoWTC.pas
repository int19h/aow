unit AoWTC;

{ Draft declarations of AoWTC, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TTCAbility = class;
  TROb = class;
  TAoWNewCombatMapSettings = class;
  TaiMove = class;
  TCAI = class;
  TAoWCombatMapField = class;
  TAoWCombatMapLevel = class;
  TRangedPathHS = class;
  TfxHS = class;
  TCItemHS = class;
  TUnitPositionHS = class;
  TCBloodHS = class;
  TCCorpseHS = class;
  TCOozeHS = class;
  TUnitPositionControl = class;
  TCombatMoveControlSettings = class;
  TCombatMoveControl = class;
  TTacticalCombatUnit = class;
  TTacticalCombatUnitHS = class;
  TCombatUnitSelectionControl = class;
  TTacticalCombatPlayer = class;
  TTacticalCombatPlayerList = class;
  TAoWCombatMapMouse = class;
  TAoWCombatMap = class;
  TTacticalCombat = class;
  TRndTacHsm = class;

  TCombatMoveMode = set of (mmWallCrushing, mmMelee, mmMoveRanged, mmaiMove, mmaiWall, mmClimbing); { ot=1 }
  TFireStart = (fsNew, fsSpread);  { ot=1 }
  TTCDeathMethod = (dmNormal, dmExplode);  { ot=1 }
  TTCAction = (caMove, caMeleeHit, caMeleeMiss, caAbility, caHit, caKilled, caStepUp, caStepBack, caBusy, caRoundAttack, caRoundAttackHit, caFreeStruck, caBreathAttack);  { ot=1 }
  TfxType = (fxNone, fxArrow, fxRock, fxComet, fxTouch, fxBreath, fxCometBall, fxEffect, fxFBExplosion, fxScreenNESW, fxScreenNS, fxRay, fxChain, fxSwarm, fxScreenSwarm, fxSFOverlay, fxDamLightning, fxDamFire, fxDamPoison, fxDamMagic, fxDamHoly, fxDamDeath, fxDamCold, fxSacredWrath, fxSWComet, fxDispel, fxWallSmoke, fxBlood, fxAltArrow, fxTremors, fxGeyser, fxGeyserWater, fxHailImpact, fxCloud, fxCloudPuff, fxHitGround, fxHitWater, fxHighPrayer, fxPrayerGlow, fxResurrect, fxFrostBeam, fxFrost, fxMindDecay, fxDecayLeg, fxShockWave, fxDecayComet, fxSacFlame, fxWinds, fxSacFire, fxBreathDam);  { ot=1 }
  TRndHexMask = (rndNone, rndCenter, rndNorth, rndNE, rndSE, rndSouth, rndSW, rndNW, rndNWSW, rndNESE, rndNNW, rndNNE, rndSSW, rndSSE, rndCN, rndCNE, rndCSE, rndCS, rndCSW, rndCNW, rndRC, rndRN, rndRNE, rndRSE, rndRS, rndRSW, rndRNW);  { ot=1 }
  TTCAbil = (tcWallCrushing, tcFire, tcabMax);  { ot=1 }
  TaiStatus = (aiIdle, aiBusy, aiDone);  { ot=1 }
  TaiMoveType = (aiMove, aiTouch, aiMelee, aiRanged, aiFake, aiMoveRanged, aiWallTouch, aiWallRanged);  { ot=1 }

  { TTCAbility (instance size 12, VMT 00411A60) }
  TTCAbility = class(TObject)
  public
    F_TCAbility_04: array[0..7] of Byte;
  end;

  { TROb (instance size 12, VMT 00411AD0) }
  TROb = class(TObject)
  public
    F_ROb_04: array[0..7] of Byte;
  end;

  { TAoWNewCombatMapSettings (instance size 32, VMT 00411B34) }
  TAoWNewCombatMapSettings = class(TNewHSMapSettings)
  public
    function Create(A1: Byte): Integer;  { draft }
  end;

  { TaiMove (instance size 32, VMT 00411BC0) }
  TaiMove = class(TObject)
  public
    F_aiMove_04: array[0..27] of Byte;
  end;

  { TCAI (instance size 56, VMT 00411C28) }
  TCAI = class(TObject)
  public
    F_CAI_04: Byte;
    F_CAI_05: array[0..2] of Byte;
    F_CAI_08: Integer;
    F_CAI_0C: Integer;
    F_CAI_10: Integer;
    F_CAI_14: Integer;
    F_CAI_18: Integer;
    F_CAI_1C: Integer;
    F_CAI_20: Integer;
    F_CAI_24: Integer;
    F_CAI_28: Integer;
    F_CAI_2C: Integer;
    F_CAI_30: Integer;
    F_CAI_34: Byte;
    F_CAI_35: Byte;
    F_CAI_36: Byte;
    F_CAI_37: array[0..0] of Byte;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Reset(A1: Integer; A2: Integer);  { draft }
    procedure BeginTurn(A1: Integer; A2: Integer);  { draft }
    procedure ContinueTurn(A1: Integer; A2: Integer);  { draft }
    procedure CreateMove(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);  { draft }
    function tcDVtoDEV(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Integer;  { draft }
    function ChargeFromPos(A1: Integer): Byte;  { draft }
    function UnitSafe(A1: Integer; A2: Integer; A3: Integer): Integer;  { draft }
    function MakeTerrainPath(A1: Integer; A2: Integer): Integer;  { draft }
    function MultDEV(A1: Integer; A2: Integer): Integer;  { draft }
    procedure EvalAll(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure EvalHex(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer);  { draft }
    procedure EvalArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer);  { draft }
    function EvalPath(A1: Integer; A2: Integer): Integer;  { draft }
    function EvalBreath(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer): Integer;  { draft }
    procedure CheckUnit(A1: Integer; A2: Integer);  { draft }
    procedure EvalBattle;  { draft }
  end;

  { TAoWCombatMapField (instance size 28, VMT 00411C8C) }
  TAoWCombatMapField = class(TAoWMapField)
  public
    class function ClassID: Integer; override;
    function GetDefenseValue: Integer;  { draft }
  end;

  { TAoWCombatMapLevel (instance size 128, VMT 00411D98) }
  TAoWCombatMapLevel = class(TAoWMapLevel)
  public
    class function ClassID: Integer; override;
    function MapFieldClass: Engine.TEObjectClass; override;
  end;

  { TRangedPathHS (instance size 32, VMT 00411EA8) }
  TRangedPathHS = class(TFixedVisibleHS)
  public
    F_RangedPathHS_0C: Integer;
    F_RangedPathHS_10: Integer;
    F_RangedPathHS_14: Word;
    F_RangedPathHS_16: Word;
    F_RangedPathHS_18: Integer;
    F_RangedPathHS_1C: Word;
    F_RangedPathHS_1E: array[0..1] of Byte;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
  end;

  { TfxHS (instance size 56, VMT 00412028) }
  TfxHS = class(TFixedVisibleHS)
  public
    F_fxHS_0C: Byte;
    F_fxHS_0D: Byte;
    F_fxHS_0E: array[0..1] of Byte;
    F_fxHS_10: Integer;
    F_fxHS_14: Integer;
    F_fxHS_18: Integer;
    F_fxHS_1C: Integer;
    F_fxHS_20: Integer;
    F_fxHS_24: Integer;
    F_fxHS_28: Integer;
    F_fxHS_2C: Integer;
    F_fxHS_30: array[0..3] of Byte;
    F_fxHS_34: Byte;
    F_fxHS_35: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewFrame(A1: Integer);  { draft }
  end;

  { TCItemHS (instance size 20, VMT 00412198) }
  TCItemHS = class(TItemHS)
  public
    procedure Deactivate; override;
  end;

  { TUnitPositionHS (instance size 28, VMT 00412314) }
  TUnitPositionHS = class(TSingleHS)
  public
    F_UnitPositionHS_0C: Byte;
    F_UnitPositionHS_0D: Byte;
    F_UnitPositionHS_0E: array[0..1] of Byte;
    F_UnitPositionHS_10: Integer;
    F_UnitPositionHS_14: Integer;
    F_UnitPositionHS_18: Byte;
    F_UnitPositionHS_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure UpdateImageIndex(A1: Integer; A2: Integer);  { draft }
  end;

  { TCBloodHS (instance size 28, VMT 0041249C) }
  TCBloodHS = class(TSingleHS)
  public
    F_CBloodHS_0C: array[0..3] of Byte;
    F_CBloodHS_10: Integer;
    F_CBloodHS_14: Integer;
    F_CBloodHS_18: Integer;
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
  end;

  { TCCorpseHS (instance size 44, VMT 0041261C) }
  TCCorpseHS = class(TSingleHS)
  public
    F_CCorpseHS_0C: Integer;
    F_CCorpseHS_10: Integer;
    F_CCorpseHS_14: array[0..3] of Byte;
    F_CCorpseHS_18: Integer;
    F_CCorpseHS_1C: Integer;
    F_CCorpseHS_20: Integer;
    F_CCorpseHS_24: Integer;
    F_CCorpseHS_28: Integer;
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewFrame(A1: Integer);  { draft }
  end;

  { TCOozeHS (instance size 12, VMT 0041279C) }
  TCOozeHS = class(TSingleHS)
  public
    class function ClassID: Integer; override;
    function GetOverlay(HN: Integer): Shortint; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
  end;

  { TUnitPositionControl (instance size 12, VMT 00412918) }
  TUnitPositionControl = class(TEObject)
  public
    F_UnitPositionControl_08: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetUnitPosition(A1: Integer; A2: Integer): Integer;  { draft }
    procedure SetUnitPosition(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function ValidatePosition(A1: Integer; A2: Integer): Byte;  { draft }
  end;

  { TCombatMoveControlSettings (instance size 432, VMT 004129E8) }
  TCombatMoveControlSettings = class(TMoveControlSettings)
  public
    F_CombatMoveControlSettings_1AC: array[0..3] of Byte;
  end;

  { TCombatMoveControl (instance size 488, VMT 00412AC4) }
  TCombatMoveControl = class(TMoveControl)
  public
    F_CombatMoveControl_1E0: Integer;
    F_CombatMoveControl_1E4: Byte;
    F_CombatMoveControl_1E5: array[0..2] of Byte;
    procedure ProcessMove(A1: AoWE.TMoveControlSettings); override;
  end;

  { TTacticalCombatUnit (instance size 104, VMT 00412B4C) }
  TTacticalCombatUnit = class(TCombatUnit)
  public
    F_TacticalCombatUnit_5C: Integer;
    F_TacticalCombatUnit_60: Integer;
    F_TacticalCombatUnit_64: Byte;
    F_TacticalCombatUnit_65: Byte;
    F_TacticalCombatUnit_66: array[0..0] of Byte;
    F_TacticalCombatUnit_67: Byte;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure NewTurn(A1: Byte); override;
    function ExecuteDamage(A1: Integer): Integer; override;
    function GetPosValue: Integer;  { draft }
    procedure MovedTo(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TTacticalCombatUnitHS (instance size 72, VMT 00412D08) }
  TTacticalCombatUnitHS = class(TUnitHS)
  public
    F_TacticalCombatUnitHS_1C: Integer;
    F_TacticalCombatUnitHS_20: Word;
    F_TacticalCombatUnitHS_22: Word;
    F_TacticalCombatUnitHS_24: Byte;
    F_TacticalCombatUnitHS_25: Byte;
    F_TacticalCombatUnitHS_26: Word;
    F_TacticalCombatUnitHS_28: array[0..3] of Byte;
    F_TacticalCombatUnitHS_2C: Integer;
    F_TacticalCombatUnitHS_30: Integer;
    F_TacticalCombatUnitHS_34: Integer;
    F_TacticalCombatUnitHS_38: Integer;
    F_TacticalCombatUnitHS_3C: Integer;
    F_TacticalCombatUnitHS_40: Integer;
    F_TacticalCombatUnitHS_44: Byte;
    F_TacticalCombatUnitHS_45: array[0..2] of Byte;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure Select; override;
    procedure Unselect; override;
    procedure ShowShadow(X, Y: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function GetMoveSteps: Integer; override;
    procedure Initialize(A1: Integer);  { draft }
    procedure NewFrame(A1: Integer; A2: Integer);  { draft }
    function MeleeMoveTC(A1: Integer): Byte;  { draft }
    function SelectAbility(A1: Integer): Integer;  { draft }
    function SelectSpell(A1: Integer): Integer;  { draft }
    procedure CreateTCAbList;  { draft }
    procedure ListAbilities(A1: Integer; A2: Integer);  { draft }
    procedure SetAction(A1: Byte);  { draft }
    function AbTouchMoveTC(A1: Integer): Byte;  { draft }
    function AbRangedTC(A1: Word; A2: Word): Byte;  { draft }
  end;

  { TCombatUnitSelectionControl (instance size 60, VMT 00412EB4) }
  TCombatUnitSelectionControl = class(TMoveSelector)
  public
    F_CombatUnitSelectionControl_18: Byte;
    F_CombatUnitSelectionControl_19: array[0..2] of Byte;
    F_CombatUnitSelectionControl_1C: Integer;
    F_CombatUnitSelectionControl_20: Integer;
    F_CombatUnitSelectionControl_24: Integer;
    F_CombatUnitSelectionControl_28: Integer;
    F_CombatUnitSelectionControl_2C: Word;
    F_CombatUnitSelectionControl_2E: Word;
    F_CombatUnitSelectionControl_30: Integer;
    F_CombatUnitSelectionControl_34: Integer;
    F_CombatUnitSelectionControl_38: Integer;
    destructor Destroy; override;
    procedure MouseDownEvent(Sender: TObject); override;
    procedure CalculateMovePath(Index: Integer; X, Y, L: Shortint); override;
    procedure UpdateMoveCursor; override;
    function CreateMCS: AoWE.TMoveControlSettings; override;
    procedure SetCurrentMove(A1: Integer); override;
    procedure Unselect; override;
    procedure ShowMovePaths(const Surface: GFXE.TSurfaceDesc); override;
    function Create(A1: Byte): Integer;  { draft }
    function AddUnit(A1: Integer): Integer;  { draft }
    function GetTCUnitHS: Integer;  { draft }
    function GetMoveTypes: Byte;  { draft }
    procedure RectangleSelectEvent(A1: Integer);  { draft }
    procedure MoveSelectionEvent(A1: Integer);  { draft }
    procedure CalculateRangedPath(A1: Byte; A2: Byte);  { draft }
    procedure MoveSelectedRoute;  { draft }
    procedure MoveUnits;  { draft }
    procedure ExecuteMoveSelection;  { draft }
    function ValidMultiMoveSelection(A1: Integer): Byte;  { draft }
    procedure ActivateMoveSelection(A1: Integer; A2: Integer);  { draft }
    procedure DeactivateMoveSelection(A1: Integer; A2: Integer);  { draft }
    procedure Update(A1: Integer; A2: Integer);  { draft }
    procedure SetTCUnitHS(A1: Integer);  { draft }
    procedure Select(A1: Integer);  { draft }
    procedure DeactivateRangedPath(A1: Integer; A2: Integer);  { draft }
  end;

  { TTacticalCombatPlayer (instance size 28, VMT 00412F78) }
  TTacticalCombatPlayer = class(TCombatPlayer)
  public
    F_TacticalCombatPlayer_0C: Byte;
    F_TacticalCombatPlayer_0D: array[0..0] of Byte;
    F_TacticalCombatPlayer_0E: Byte;
    F_TacticalCombatPlayer_0F: array[0..12] of Byte;
    procedure SetAuto(A1: Byte);  { draft }
  end;

  { TTacticalCombatPlayerList (instance size 8, VMT 0041304C) }
  TTacticalCombatPlayerList = class(TObject)
  public
    F_TacticalCombatPlayerList_04: Integer;
    function GetCount: Integer;  { draft }
    function GetPlayers(A1: Byte): Integer;  { draft }
  end;

  { TAoWCombatMapMouse (instance size 80, VMT 004130DC) }
  TAoWCombatMapMouse = class(TAbstractAoWHSMapMouse)
  public
  end;

  { TAoWCombatMap (instance size 312, VMT 00413184) }
  TAoWCombatMap = class(TAbstractAoWCombatMap)
  public
    F_AoWCombatMap_E0: Integer;
    F_AoWCombatMap_E4: Integer;
    F_AoWCombatMap_E8: Integer;
    F_AoWCombatMap_EC: Byte;
    F_AoWCombatMap_ED: Byte;
    F_AoWCombatMap_EE: array[0..1] of Byte;
    F_AoWCombatMap_F0: Integer;
    F_AoWCombatMap_F4: Integer;
    F_AoWCombatMap_F8: Integer;
    F_AoWCombatMap_FC: Integer;
    F_AoWCombatMap_100: Integer;
    F_AoWCombatMap_104: Integer;
    F_AoWCombatMap_108: Integer;
    F_AoWCombatMap_10C: array[0..3] of Byte;
    F_AoWCombatMap_110: Integer;
    F_AoWCombatMap_114: Integer;
    F_AoWCombatMap_118: Integer;
    F_AoWCombatMap_11C: Integer;
    F_AoWCombatMap_120: Integer;
    F_AoWCombatMap_124: Integer;
    F_AoWCombatMap_128: Byte;
    F_AoWCombatMap_129: array[0..0] of Byte;
    F_AoWCombatMap_12A: Byte;
    F_AoWCombatMap_12B: array[0..8] of Byte;
    F_AoWCombatMap_134: Byte;
    F_AoWCombatMap_135: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function CreateMouse: HSEngine.THSMapMouse; override;
    procedure InitializeNewMap; override;
    procedure DrawDynamicScene(var SD: GFXE.TSurfaceDesc); override;
    procedure NewFrame; override;
    procedure DropHeroItem(Hero: AoWE.THero; Item: AoWE.TItem); override;
    function GetHeroItemsOnGround(Hero: AoWE.THero): AoWE.TItemList; override;
    procedure SetCombat(A1: Integer);  { draft }
    procedure MouseMoveEvent(A1: Integer);  { draft }
    procedure SetSeatedCombatPlayer(A1: Byte);  { draft }
    procedure NewTurn(A1: Byte);  { draft }
    procedure DrawMoveRoute(A1: Integer);  { draft }
    function EndTurn(A1: Byte): Byte;  { draft }
    procedure CancelEndTurn(A1: Integer; A2: Integer);  { draft }
    function GetEndTurnStatus: Byte;  { draft }
    function GetNextUnit(A1: Integer; A2: Byte; A3: Integer): Integer;  { draft }
    function AddEffect(A1: Byte): Integer;  { draft }
    procedure UpdateCursor(A1: Integer; A2: Integer);  { draft }
    procedure EndCombat(A1: Integer);  { draft }
    procedure SelectNextUnit(A1: Byte);  { draft }
    procedure GetUnitLocation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure Surrender(A1: Byte);  { draft }
  end;

  { TTacticalCombat (instance size 80, VMT 00413314) }
  TTacticalCombat = class(TCombat)
  public
    F_TacticalCombat_4C: Byte;
    F_TacticalCombat_4D: array[0..2] of Byte;
    class function ClassID: Integer; override;
    function CreateCombatUnit: AoWE.TCombatUnit; override;
    function CreateCombatPlayer: Integer; override;
    function Execute: Byte; override;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Deactivate; override;
    function ValidateWallCombat: Byte;  { draft }
  end;

  { TRndTacHsm (instance size 3708, VMT 0041340C) }
  TRndTacHsm = class(TObject)
  public
    F_RndTacHsm_04: Integer;
    F_RndTacHsm_08: Byte;
    F_RndTacHsm_09: array[0..2] of Byte;
    F_RndTacHsm_0C: Byte;
    F_RndTacHsm_0D: array[0..2] of Byte;
    F_RndTacHsm_10: Integer;
    F_RndTacHsm_14: Integer;
    F_RndTacHsm_18: array[0..3] of Byte;
    F_RndTacHsm_1C: Integer;
    F_RndTacHsm_20: Integer;
    F_RndTacHsm_24: array[0..15] of Byte;
    F_RndTacHsm_34: Integer;
    F_RndTacHsm_38: Integer;
    F_RndTacHsm_3C: array[0..19] of Byte;
    F_RndTacHsm_50: Integer;
    F_RndTacHsm_54: Integer;
    F_RndTacHsm_58: array[0..3] of Byte;
    F_RndTacHsm_5C: Byte;
    F_RndTacHsm_5D: array[0..74] of Byte;
    F_RndTacHsm_A8: Integer;
    F_RndTacHsm_AC: Integer;
    F_RndTacHsm_B0: Integer;
    F_RndTacHsm_B4: Integer;
    F_RndTacHsm_B8: Integer;
    F_RndTacHsm_BC: Integer;
    F_RndTacHsm_C0: Integer;
    F_RndTacHsm_C4: Integer;
    F_RndTacHsm_C8: Integer;
    F_RndTacHsm_CC: array[0..3] of Byte;
    F_RndTacHsm_D0: Integer;
    F_RndTacHsm_D4: Integer;
    F_RndTacHsm_D8: Integer;
    F_RndTacHsm_DC: Integer;
    F_RndTacHsm_E0: Integer;
    F_RndTacHsm_E4: Integer;
    F_RndTacHsm_E8: Integer;
    F_RndTacHsm_EC: array[0..7] of Byte;
    F_RndTacHsm_F4: Integer;
    F_RndTacHsm_F8: Integer;
    F_RndTacHsm_FC: Integer;
    F_RndTacHsm_100: Integer;
    F_RndTacHsm_104: Integer;
    F_RndTacHsm_108: Integer;
    F_RndTacHsm_10C: Integer;
    F_RndTacHsm_110: Integer;
    F_RndTacHsm_114: Integer;
    F_RndTacHsm_118: array[0..3] of Byte;
    F_RndTacHsm_11C: Integer;
    F_RndTacHsm_120: Integer;
    F_RndTacHsm_124: Integer;
    F_RndTacHsm_128: Integer;
    F_RndTacHsm_12C: Integer;
    F_RndTacHsm_130: Integer;
    F_RndTacHsm_134: Integer;
    F_RndTacHsm_138: array[0..7] of Byte;
    F_RndTacHsm_140: Integer;
    F_RndTacHsm_144: Integer;
    F_RndTacHsm_148: Integer;
    F_RndTacHsm_14C: Integer;
    F_RndTacHsm_150: Integer;
    F_RndTacHsm_154: Integer;
    F_RndTacHsm_158: Integer;
    F_RndTacHsm_15C: Integer;
    F_RndTacHsm_160: Integer;
    F_RndTacHsm_164: array[0..3] of Byte;
    F_RndTacHsm_168: Integer;
    F_RndTacHsm_16C: Integer;
    F_RndTacHsm_170: Integer;
    F_RndTacHsm_174: Integer;
    F_RndTacHsm_178: Integer;
    F_RndTacHsm_17C: Integer;
    F_RndTacHsm_180: Integer;
    F_RndTacHsm_184: array[0..7] of Byte;
    F_RndTacHsm_18C: Integer;
    F_RndTacHsm_190: Integer;
    F_RndTacHsm_194: Integer;
    F_RndTacHsm_198: Integer;
    F_RndTacHsm_19C: Integer;
    F_RndTacHsm_1A0: Integer;
    F_RndTacHsm_1A4: Integer;
    F_RndTacHsm_1A8: Integer;
    F_RndTacHsm_1AC: Integer;
    F_RndTacHsm_1B0: array[0..3] of Byte;
    F_RndTacHsm_1B4: Integer;
    F_RndTacHsm_1B8: Integer;
    F_RndTacHsm_1BC: Integer;
    F_RndTacHsm_1C0: Integer;
    F_RndTacHsm_1C4: Integer;
    F_RndTacHsm_1C8: Integer;
    F_RndTacHsm_1CC: Integer;
    F_RndTacHsm_1D0: array[0..7] of Byte;
    F_RndTacHsm_1D8: Integer;
    F_RndTacHsm_1DC: Integer;
    F_RndTacHsm_1E0: Integer;
    F_RndTacHsm_1E4: Integer;
    F_RndTacHsm_1E8: Integer;
    F_RndTacHsm_1EC: Integer;
    F_RndTacHsm_1F0: Integer;
    F_RndTacHsm_1F4: Integer;
    F_RndTacHsm_1F8: Integer;
    F_RndTacHsm_1FC: array[0..3] of Byte;
    F_RndTacHsm_200: Integer;
    F_RndTacHsm_204: Integer;
    F_RndTacHsm_208: Integer;
    F_RndTacHsm_20C: Integer;
    F_RndTacHsm_210: Integer;
    F_RndTacHsm_214: Integer;
    F_RndTacHsm_218: Integer;
    F_RndTacHsm_21C: array[0..7] of Byte;
    F_RndTacHsm_224: Integer;
    F_RndTacHsm_228: Integer;
    F_RndTacHsm_22C: Integer;
    F_RndTacHsm_230: Integer;
    F_RndTacHsm_234: Integer;
    F_RndTacHsm_238: Integer;
    F_RndTacHsm_23C: Integer;
    F_RndTacHsm_240: Integer;
    F_RndTacHsm_244: Integer;
    F_RndTacHsm_248: array[0..3] of Byte;
    F_RndTacHsm_24C: Integer;
    F_RndTacHsm_250: Integer;
    F_RndTacHsm_254: Integer;
    F_RndTacHsm_258: Integer;
    F_RndTacHsm_25C: Integer;
    F_RndTacHsm_260: Integer;
    F_RndTacHsm_264: Integer;
    F_RndTacHsm_268: array[0..387] of Byte;
    F_RndTacHsm_3EC: Integer;
    F_RndTacHsm_3F0: Integer;
    F_RndTacHsm_3F4: Integer;
    F_RndTacHsm_3F8: Integer;
    F_RndTacHsm_3FC: Integer;
    F_RndTacHsm_400: Integer;
    F_RndTacHsm_404: Integer;
    F_RndTacHsm_408: Integer;
    F_RndTacHsm_40C: Integer;
    F_RndTacHsm_410: array[0..3] of Byte;
    F_RndTacHsm_414: Integer;
    F_RndTacHsm_418: Integer;
    F_RndTacHsm_41C: Integer;
    F_RndTacHsm_420: Integer;
    F_RndTacHsm_424: Integer;
    F_RndTacHsm_428: Integer;
    F_RndTacHsm_42C: Integer;
    F_RndTacHsm_430: Integer;
    F_RndTacHsm_434: array[0..235] of Byte;
    F_RndTacHsm_520: Byte;
    F_RndTacHsm_521: array[0..78] of Byte;
    F_RndTacHsm_570: Integer;
    F_RndTacHsm_574: Integer;
    F_RndTacHsm_578: array[0..11] of Byte;
    F_RndTacHsm_584: Integer;
    F_RndTacHsm_588: Integer;
    F_RndTacHsm_58C: Integer;
    F_RndTacHsm_590: array[0..3] of Byte;
    F_RndTacHsm_594: Integer;
    F_RndTacHsm_598: array[0..39] of Byte;
    F_RndTacHsm_5C0: Integer;
    F_RndTacHsm_5C4: array[0..11] of Byte;
    F_RndTacHsm_5D0: Integer;
    F_RndTacHsm_5D4: Integer;
    F_RndTacHsm_5D8: Integer;
    F_RndTacHsm_5DC: array[0..3] of Byte;
    F_RndTacHsm_5E0: Integer;
    F_RndTacHsm_5E4: array[0..43] of Byte;
    F_RndTacHsm_610: Integer;
    F_RndTacHsm_614: Integer;
    F_RndTacHsm_618: array[0..71] of Byte;
    F_RndTacHsm_660: Integer;
    F_RndTacHsm_664: array[0..19] of Byte;
    F_RndTacHsm_678: Integer;
    F_RndTacHsm_67C: array[0..47] of Byte;
    F_RndTacHsm_6AC: Integer;
    F_RndTacHsm_6B0: Integer;
    F_RndTacHsm_6B4: array[0..15] of Byte;
    F_RndTacHsm_6C4: Integer;
    F_RndTacHsm_6C8: array[0..55] of Byte;
    F_RndTacHsm_700: Integer;
    F_RndTacHsm_704: Integer;
    F_RndTacHsm_708: Integer;
    F_RndTacHsm_70C: array[0..83] of Byte;
    F_RndTacHsm_760: Integer;
    F_RndTacHsm_764: array[0..7] of Byte;
    F_RndTacHsm_76C: Integer;
    F_RndTacHsm_770: array[0..3] of Byte;
    F_RndTacHsm_774: Integer;
    F_RndTacHsm_778: array[0..47] of Byte;
    F_RndTacHsm_7A8: Integer;
    F_RndTacHsm_7AC: Integer;
    F_RndTacHsm_7B0: Integer;
    F_RndTacHsm_7B4: array[0..7] of Byte;
    F_RndTacHsm_7BC: Integer;
    F_RndTacHsm_7C0: array[0..51] of Byte;
    F_RndTacHsm_7F4: Integer;
    F_RndTacHsm_7F8: array[0..35] of Byte;
    F_RndTacHsm_81C: Integer;
    F_RndTacHsm_820: array[0..15] of Byte;
    F_RndTacHsm_830: Integer;
    F_RndTacHsm_834: Integer;
    F_RndTacHsm_838: Integer;
    F_RndTacHsm_83C: array[0..3] of Byte;
    F_RndTacHsm_840: Integer;
    F_RndTacHsm_844: array[0..39] of Byte;
    F_RndTacHsm_86C: Integer;
    F_RndTacHsm_870: array[0..11] of Byte;
    F_RndTacHsm_87C: Integer;
    F_RndTacHsm_880: Integer;
    F_RndTacHsm_884: Integer;
    F_RndTacHsm_888: array[0..3] of Byte;
    F_RndTacHsm_88C: Integer;
    F_RndTacHsm_890: array[0..75] of Byte;
    F_RndTacHsm_8DC: Integer;
    F_RndTacHsm_8E0: array[0..3] of Byte;
    F_RndTacHsm_8E4: Integer;
    F_RndTacHsm_8E8: Integer;
    F_RndTacHsm_8EC: array[0..3] of Byte;
    F_RndTacHsm_8F0: Integer;
    F_RndTacHsm_8F4: array[0..51] of Byte;
    F_RndTacHsm_928: Integer;
    F_RndTacHsm_92C: array[0..7] of Byte;
    F_RndTacHsm_934: Integer;
    F_RndTacHsm_938: array[0..3] of Byte;
    F_RndTacHsm_93C: Integer;
    F_RndTacHsm_940: array[0..175] of Byte;
    F_RndTacHsm_9F0: Byte;
    F_RndTacHsm_9F1: array[0..5] of Byte;
    F_RndTacHsm_9F7: Byte;
    F_RndTacHsm_9F8: array[0..7] of Byte;
    F_RndTacHsm_A00: Byte;
    F_RndTacHsm_A01: array[0..1142] of Byte;
    F_RndTacHsm_E78: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    function RandomMap(A1: Integer; A2: Integer): Integer;  { draft }
    procedure PlaceCombatUnits;  { draft }
    procedure SetupUnit(A1: Byte; A2: Integer);  { draft }
    procedure InitTables(A1: Integer; A2: Integer);  { draft }
  end;

procedure MakeAbilPath(A1: Byte; A2: Word; A3: Word);  { draft }
procedure MakeRangedPath(A1: Byte; A2: Word; A3: Word; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer; A12: Integer; A13: Integer);  { draft }
procedure RegisterAoWTCClasses(A1: Integer);  { draft }
function GetMeleeDirIndex(A1: Integer; A2: Integer; A3: Integer): Word;  { draft }
function GetRangedDirIndex(A1: Integer; A2: Integer): Integer;  { draft }

implementation

constructor TCAI.Create;
begin end;

destructor TCAI.Destroy;
begin end;

procedure TCAI.Reset(A1: Integer; A2: Integer);
begin end;

procedure TCAI.BeginTurn(A1: Integer; A2: Integer);
begin end;

procedure TCAI.ContinueTurn(A1: Integer; A2: Integer);
begin end;

procedure TCAI.CreateMove(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);
begin end;

function TCAI.tcDVtoDEV(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Integer;
begin Result := 0; end;

function TCAI.ChargeFromPos(A1: Integer): Byte;
begin Result := 0; end;

function TCAI.UnitSafe(A1: Integer; A2: Integer; A3: Integer): Integer;
begin Result := 0; end;

function TCAI.MakeTerrainPath(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

function TCAI.MultDEV(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TCAI.EvalAll(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCAI.EvalHex(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer);
begin end;

procedure TCAI.EvalArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer);
begin end;

function TCAI.EvalPath(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

function TCAI.EvalBreath(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer): Integer;
begin Result := 0; end;

procedure TCAI.CheckUnit(A1: Integer; A2: Integer);
begin end;

procedure TCAI.EvalBattle;
begin end;

function TAoWNewCombatMapSettings.Create(A1: Byte): Integer;
begin Result := 0; end;

class function TAoWCombatMapField.ClassID: Integer;
begin Result := 0; end;

function TAoWCombatMapField.GetDefenseValue: Integer;
begin Result := 0; end;

class function TAoWCombatMapLevel.ClassID: Integer;
begin Result := 0; end;

function TAoWCombatMapLevel.MapFieldClass: Engine.TEObjectClass;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TAoWCombatMap.ClassID: Integer;
begin Result := 0; end;

constructor TAoWCombatMap.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAoWCombatMap.Destroy;
begin end;

function TAoWCombatMap.CreateMouse: HSEngine.THSMapMouse;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAoWCombatMap.SetCombat(A1: Integer);
begin end;

procedure TAoWCombatMap.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAoWCombatMap.MouseMoveEvent(A1: Integer);
begin end;

procedure TAoWCombatMap.InitializeNewMap;
begin end;

procedure TAoWCombatMap.SetSeatedCombatPlayer(A1: Byte);
begin end;

procedure TAoWCombatMap.NewTurn(A1: Byte);
begin end;

procedure TAoWCombatMap.DrawDynamicScene(var SD: GFXE.TSurfaceDesc);
begin end;

procedure TAoWCombatMap.DrawMoveRoute(A1: Integer);
begin end;

function TAoWCombatMap.EndTurn(A1: Byte): Byte;
begin Result := 0; end;

procedure TAoWCombatMap.CancelEndTurn(A1: Integer; A2: Integer);
begin end;

function TAoWCombatMap.GetEndTurnStatus: Byte;
begin Result := 0; end;

function TAoWCombatMap.GetNextUnit(A1: Integer; A2: Byte; A3: Integer): Integer;
begin Result := 0; end;

procedure TAoWCombatMap.NewFrame;
begin end;

function TAoWCombatMap.AddEffect(A1: Byte): Integer;
begin Result := 0; end;

procedure TAoWCombatMap.UpdateCursor(A1: Integer; A2: Integer);
begin end;

procedure TAoWCombatMap.EndCombat(A1: Integer);
begin end;

procedure TAoWCombatMap.SelectNextUnit(A1: Byte);
begin end;

procedure TAoWCombatMap.DropHeroItem(Hero: AoWE.THero; Item: AoWE.TItem);
begin end;

function TAoWCombatMap.GetHeroItemsOnGround(Hero: AoWE.THero): AoWE.TItemList;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAoWCombatMap.GetUnitLocation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWCombatMap.Surrender(A1: Byte);
begin end;

procedure TCItemHS.Deactivate;
begin end;

function TTacticalCombatUnit.GetPosValue: Integer;
begin Result := 0; end;

procedure TTacticalCombatUnit.NewTurn(A1: Byte);
begin end;

procedure TTacticalCombatUnit.MovedTo(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTacticalCombatUnit.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

function TTacticalCombatUnit.ExecuteDamage(A1: Integer): Integer;
begin Result := 0; end;

procedure TCombatMoveControl.ProcessMove(A1: AoWE.TMoveControlSettings);
begin end;

function TCombatUnitSelectionControl.Create(A1: Byte): Integer;
begin Result := 0; end;

destructor TCombatUnitSelectionControl.Destroy;
begin end;

function TCombatUnitSelectionControl.CreateMCS: AoWE.TMoveControlSettings;
begin FillChar(Result, SizeOf(Result), 0); end;

function TCombatUnitSelectionControl.AddUnit(A1: Integer): Integer;
begin Result := 0; end;

procedure TCombatUnitSelectionControl.SetCurrentMove(A1: Integer);
begin end;

function TCombatUnitSelectionControl.GetTCUnitHS: Integer;
begin Result := 0; end;

function TCombatUnitSelectionControl.GetMoveTypes: Byte;
begin Result := 0; end;

procedure TCombatUnitSelectionControl.RectangleSelectEvent(A1: Integer);
begin end;

procedure TCombatUnitSelectionControl.MoveSelectionEvent(A1: Integer);
begin end;

procedure TCombatUnitSelectionControl.CalculateMovePath(Index: Integer; X, Y, L: Shortint);
begin end;

procedure TCombatUnitSelectionControl.CalculateRangedPath(A1: Byte; A2: Byte);
begin end;

procedure TCombatUnitSelectionControl.MoveSelectedRoute;
begin end;

procedure TCombatUnitSelectionControl.MoveUnits;
begin end;

procedure TCombatUnitSelectionControl.ExecuteMoveSelection;
begin end;

function TCombatUnitSelectionControl.ValidMultiMoveSelection(A1: Integer): Byte;
begin Result := 0; end;

procedure TCombatUnitSelectionControl.MouseDownEvent(Sender: TObject);
begin end;

procedure TCombatUnitSelectionControl.UpdateMoveCursor;
begin end;

procedure TCombatUnitSelectionControl.ActivateMoveSelection(A1: Integer; A2: Integer);
begin end;

procedure TCombatUnitSelectionControl.DeactivateMoveSelection(A1: Integer; A2: Integer);
begin end;

procedure TCombatUnitSelectionControl.ShowMovePaths(const Surface: GFXE.TSurfaceDesc);
begin end;

procedure TCombatUnitSelectionControl.Update(A1: Integer; A2: Integer);
begin end;

procedure TCombatUnitSelectionControl.SetTCUnitHS(A1: Integer);
begin end;

procedure TCombatUnitSelectionControl.Unselect;
begin end;

procedure TCombatUnitSelectionControl.Select(A1: Integer);
begin end;

procedure TCombatUnitSelectionControl.DeactivateRangedPath(A1: Integer; A2: Integer);
begin end;

procedure TTacticalCombatUnitHS.Deactivate;
begin end;

class function TTacticalCombatUnitHS.ClassID: Integer;
begin Result := 0; end;

procedure TTacticalCombatUnitHS.Initialize(A1: Integer);
begin end;

function TTacticalCombatUnitHS.GetMoveSteps: Integer;
begin Result := 0; end;

procedure TTacticalCombatUnitHS.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

procedure TTacticalCombatUnitHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TTacticalCombatUnitHS.Activate;
begin end;

procedure TTacticalCombatUnitHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TTacticalCombatUnitHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TTacticalCombatUnitHS.NewFrame(A1: Integer; A2: Integer);
begin end;

procedure TTacticalCombatUnitHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TTacticalCombatUnitHS.Select;
begin end;

procedure TTacticalCombatUnitHS.Unselect;
begin end;

function TTacticalCombatUnitHS.MeleeMoveTC(A1: Integer): Byte;
begin Result := 0; end;

procedure TTacticalCombatUnitHS.ShowShadow(X, Y: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

function TTacticalCombatUnitHS.SelectAbility(A1: Integer): Integer;
begin Result := 0; end;

function TTacticalCombatUnitHS.SelectSpell(A1: Integer): Integer;
begin Result := 0; end;

procedure TTacticalCombatUnitHS.CreateTCAbList;
begin end;

procedure TTacticalCombatUnitHS.ListAbilities(A1: Integer; A2: Integer);
begin end;

procedure TTacticalCombatUnitHS.SetAction(A1: Byte);
begin end;

function TTacticalCombatUnitHS.AbTouchMoveTC(A1: Integer): Byte;
begin Result := 0; end;

function TTacticalCombatUnitHS.AbRangedTC(A1: Word; A2: Word): Byte;
begin Result := 0; end;

procedure TCCorpseHS.Deactivate;
begin end;

class function TCCorpseHS.ClassID: Integer;
begin Result := 0; end;

procedure TCCorpseHS.NewFrame(A1: Integer);
begin end;

procedure TCCorpseHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

function TCCorpseHS.GetLevel: Byte;
begin Result := 0; end;

function TCCorpseHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TCCorpseHS.Activate;
begin end;

procedure TCCorpseHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

class function TCOozeHS.ClassID: Integer;
begin Result := 0; end;

function TCOozeHS.GetOverlay(HN: Integer): Shortint;
begin Result := 0; end;

procedure TCOozeHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

function TCOozeHS.GetLevel: Byte;
begin Result := 0; end;

function TCOozeHS.GetShowPriority: Integer;
begin Result := 0; end;

function TCOozeHS.PlaceOnMap: Boolean;
begin Result := False; end;

constructor TRndTacHsm.Create;
begin end;

destructor TRndTacHsm.Destroy;
begin end;

function TRndTacHsm.RandomMap(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TRndTacHsm.PlaceCombatUnits;
begin end;

procedure TRndTacHsm.SetupUnit(A1: Byte; A2: Integer);
begin end;

procedure TRndTacHsm.InitTables(A1: Integer; A2: Integer);
begin end;

procedure TRangedPathHS.Deactivate;
begin end;

class function TRangedPathHS.ClassID: Integer;
begin Result := 0; end;

function TRangedPathHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TRangedPathHS.Activate;
begin end;

procedure TRangedPathHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TUnitPositionControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TUnitPositionControl.Destroy;
begin end;

function TUnitPositionControl.GetUnitPosition(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TUnitPositionControl.SetUnitPosition(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TUnitPositionControl.ValidatePosition(A1: Integer; A2: Integer): Byte;
begin Result := 0; end;

procedure TUnitPositionControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TUnitPositionHS.Create(AOwner: Engine.TECustomNode);
begin end;

class function TUnitPositionHS.ClassID: Integer;
begin Result := 0; end;

function TUnitPositionHS.GetLevel: Byte;
begin Result := 0; end;

procedure TUnitPositionHS.UpdateImageIndex(A1: Integer; A2: Integer);
begin end;

procedure TUnitPositionHS.Activate;
begin end;

procedure TUnitPositionHS.Deactivate;
begin end;

procedure TUnitPositionHS.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TUnitPositionHS.CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

procedure TUnitPositionHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TTacticalCombat.ClassID: Integer;
begin Result := 0; end;

function TTacticalCombat.CreateCombatUnit: AoWE.TCombatUnit;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TTacticalCombat.Deactivate;
begin end;

procedure TTacticalCombat.Initialize;
begin end;

procedure TTacticalCombat.Finalize;
begin end;

function TTacticalCombat.ValidateWallCombat: Byte;
begin Result := 0; end;

function TTacticalCombat.CreateCombatPlayer: Integer;
begin Result := 0; end;

function TTacticalCombat.Execute: Byte;
begin Result := 0; end;

procedure TfxHS.Deactivate;
begin end;

constructor TfxHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TfxHS.Destroy;
begin end;

class function TfxHS.ClassID: Integer;
begin Result := 0; end;

procedure TfxHS.Activate;
begin end;

function TfxHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TfxHS.NewFrame(A1: Integer);
begin end;

procedure TfxHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCBloodHS.Deactivate;
begin end;

class function TCBloodHS.ClassID: Integer;
begin Result := 0; end;

function TCBloodHS.GetLevel: Byte;
begin Result := 0; end;

function TCBloodHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TCBloodHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCBloodHS.Activate;
begin end;

procedure TTacticalCombatPlayer.SetAuto(A1: Byte);
begin end;

function TTacticalCombatPlayerList.GetCount: Integer;
begin Result := 0; end;

function TTacticalCombatPlayerList.GetPlayers(A1: Byte): Integer;
begin Result := 0; end;

procedure MakeAbilPath(A1: Byte; A2: Word; A3: Word);
begin end;

procedure MakeRangedPath(A1: Byte; A2: Word; A3: Word; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer; A12: Integer; A13: Integer);
begin end;

procedure RegisterAoWTCClasses(A1: Integer);
begin end;

function GetMeleeDirIndex(A1: Integer; A2: Integer; A3: Integer): Word;
begin Result := 0; end;

function GetRangedDirIndex(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;


initialization
finalization

end.
