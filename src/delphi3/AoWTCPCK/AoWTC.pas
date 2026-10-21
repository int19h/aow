unit AoWTC;

{ AoWTC of AoWTCPCK.dpl: tactical combat, AI, sprites and unit positioning.
  Recovered routines use the original Delphi 3 switches and match the shipped code.
  Layouts and VMT order follow the original; remaining guesses are marked draft,
  and unrecovered bodies remain placeholders. }

{$O-,R+,Q+}

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

  { TROb (instance size 12, VMT 00411AD0): $04 PathIndex; $08 Chance. }
  TROb = class(TObject)
  public
    PathIndex: Integer; { $04 }
    Chance: Integer; { $08 }
  end;

  { TAoWNewCombatMapSettings (instance size 32, VMT 00411B34)
    Inherited $04 Width; $08 Height; $0C Levels; $10 HSSFileName; $14 HSMapClassID; $1C MapLevelClassID. }
  TAoWNewCombatMapSettings = class(TNewHSMapSettings)
  public
    constructor Create;
  end;

  { TaiMove (instance size 32, VMT 00411BC0)
    $04 MoveType; $06 X; $08 Y; $0C Ability; $14 UnitHS; $18 Path; $1C Value; $1E Cost. }
  TaiMove = class(TObject)
  public
    MoveType: TaiMoveType; { $04 }
    F_aiMove_05: Byte;
    X: Smallint; { $06 }
    Y: Smallint; { $08 }
    F_aiMove_0A: array[0..1] of Byte;
    Ability: TAbility; { $0C }
    F_aiMove_10: Integer;
    UnitHS: TTacticalCombatUnitHS; { $14 }
    Path: TXYLList; { $18 }
    Value: Word; { $1C }
    Cost: Word; { $1E }
  end;

  { TCAI (instance size 56, VMT 00411C28)
    $04 FSide; $08 Units; $0C Allies; $10 Enemies; $14 Moves; $18 Walls;
    $1C CurrentMove; $34 FIgnoreWalls; $36 Status. }
  TCAI = class(TObject)
  public
    FSide: TCombatSideIndex; { $04 }
    F_CAI_05: array[0..2] of Byte;
    Units: TList; { $08 }
    Allies: TList; { $0C }
    Enemies: TList; { $10 }
    Moves: TList; { $14 }
    Walls: TList; { $18 }
    CurrentMove: Integer; { $1C }
    F_CAI_20: Integer;
    F_CAI_24: Integer;
    F_CAI_28: Integer;
    F_CAI_2C: Integer;
    F_CAI_30: Integer;
    FIgnoreWalls: Boolean; { $34 }
    F_CAI_35: Byte;
    Status: TaiStatus; { $36 }
    F_CAI_37: array[0..0] of Byte;
    destructor Destroy; override;
    constructor Create;
    procedure Reset;
    procedure BeginTurn;
    procedure ContinueTurn;
    procedure CreateMove(MoveType: TaiMoveType; Value, Cost: Integer; Ability: TAbility; X, Y: Integer; U: TTacticalCombatUnit; Path: TXYLList);
    function tcDVtoDEV(DV1, DV2: Integer; Source, Target: TCombatObject): Integer;
    function ChargeFromPos(Position: Integer): Boolean;
    function UnitSafe(U: TTacticalCombatUnit; X, Y: Integer): Integer;
    function MakeTerrainPath(MCS: TCombatMoveControlSettings; var Path: TXYLList;
      var Value: Integer; U, Ignore: TTacticalCombatUnit; FreeStrikes, FindWalls: Boolean; Cost: Integer): Integer;
    function MultDEV(Value, Multiplier, Divider: Integer): Integer;
    procedure EvalAll(var Value: Integer; List: TList; Ignore: TCombatObject;
      Spell: Integer; U: TTacticalCombatUnit);
    procedure EvalHex(Ignore: TCombatObject; Ability, Spell, X, Y: Integer; var Value: Integer;
      HitWalls, Friendly: Boolean; U: TTacticalCombatUnit; IgnoreWall: TObject);
    procedure EvalArea(var Value: Integer; Ignore: TCombatObject; Ability, Spell, X, Y: Integer;
      HitWalls, IncludeCenter, Friendly: Boolean; U: TTacticalCombatUnit; IgnoreWall: TObject);
    function EvalPath(var Value: Integer; Ignore: TCombatObject; Ability, Spell, X1, Y1, X2, Y2: Integer;
      HitWalls: Boolean; U: TTacticalCombatUnit; IgnoreWall: TObject): Integer;
    function EvalBreath(var Value: Integer; Ignore: TCombatObject; Ability, Spell, X1, Y1, X2, Y2: Integer; U: TTacticalCombatUnit): Integer;
    procedure CheckUnit(A1: Integer; A2: Integer);  { draft }
    procedure EvalBattle;  { draft }
  end;

  { TAoWCombatMapField (instance size 28, VMT 00411C8C)
    Inherited world-map field layout; no additional fields. }
  TAoWCombatMapField = class(TAoWMapField)
  public
    class function ClassID: Integer; override;
    function GetDefenseValue: Shortint;
  end;

  { TAoWCombatMapLevel (instance size 128, VMT 00411D98)
    Inherited world-map level layout; no additional fields. }
  TAoWCombatMapLevel = class(TAoWMapLevel)
  public
    class function ClassID: Integer; override;
    function MapFieldClass: Engine.TEObjectClass; override;
  end;

  { TRangedPathHS (instance size 32, VMT 00411EA8) }
  TRangedPathHS = class(TFixedVisibleHS)
  public
    FMiscImages: TCustomImageLibrary; { $0C }
    FTargetImages: TCustomImageLibrary; { $10 }
    F_RangedPathHS_14: Word;
    F_RangedPathHS_16: Word;
    FPath: TXYZList; { $18 }
    F_RangedPathHS_1C: Word;
    F_RangedPathHS_1E: array[0..1] of Byte;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
  end;

  { TfxHS (instance size 56, VMT 00412028)
    $10 FFrame; $1C FPath. }
  TfxHS = class(TFixedVisibleHS)
  public
    F_fxHS_0C: Byte;
    F_fxHS_0D: Byte;
    F_fxHS_0E: array[0..1] of Byte;
    FFrame: Integer; { $10 }
    F_fxHS_14: Integer;
    F_fxHS_18: Integer;
    FPath: TXYZList; { $1C }
    F_fxHS_20: Integer;
    F_fxHS_24: Integer;
    F_fxHS_28: Integer;
    F_fxHS_2C: Integer;
    F_fxHS_30: array[0..3] of Byte;
    FEffectType: TfxType; { $34 }
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

  { TUnitPositionHS (instance size 28, VMT 00412314)
    $0C FPosition; $0D FIndex; $10 FImageIndex; $14 FImages; $18 FDirection. }
  TUnitPositionHS = class(TSingleHS)
  public
    FPosition: Shortint; { $0C }
    FIndex: Shortint; { $0D }
    F_UnitPositionHS_0E: array[0..1] of Byte;
    FImageIndex: Integer; { $10 }
    FImages: TCustomImageLibrary; { $14 }
    FDirection: Byte; { $18 }
    F_UnitPositionHS_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure UpdateImageIndex;
  end;

  { TCBloodHS (instance size 28, VMT 0041249C)
    $10 FFrame; $14 FOffsetX; $18 FOffsetY. }
  TCBloodHS = class(TSingleHS)
  public
    F_CBloodHS_0C: array[0..3] of Byte;
    FFrame: Integer; { $10 }
    FOffsetX: Integer; { $14 }
    FOffsetY: Integer; { $18 }
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
  end;

  { TCCorpseHS (instance size 44, VMT 0041261C)
    $0C FUnit; $10 FUnitGFX; $18 FFrame; $1C FOffsetX; $20 FOffsetY; $24 FSequenceIndex; $28 FSequenceFrame. }
  TCCorpseHS = class(TSingleHS)
  public
    FUnit: TTacticalCombatUnit; { $0C }
    FUnitGFX: TUnitGFXResource; { $10 }
    F_CCorpseHS_14: array[0..3] of Byte;
    FFrame: Integer; { $18 }
    FOffsetX: Integer; { $1C }
    FOffsetY: Integer; { $20 }
    FSequenceIndex: Integer; { $24 }
    FSequenceFrame: Integer; { $28 }
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewFrame(Sender: TObject);
  end;

  { TCOozeHS (instance size 12, VMT 0041279C)
    Inherited single-hexagon sprite layout; no additional fields. }
  TCOozeHS = class(TSingleHS)
  public
    class function ClassID: Integer; override;
    function GetOverlay(HN: Integer): Shortint; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
  end;

  { TUnitPositionControl (instance size 12, VMT 00412918)
    $08 FPositions: packed XYL entries, eight per army position. }
  TUnitPositionControl = class(TEObject)
  public
    FPositions: TXYLList; { $08 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetUnitPosition(Position, Index: Integer): TXYL;
    procedure SetUnitPosition(Position, Index: Integer; Value: TXYL);
    function ValidatePosition(var Position, Index: Shortint): Boolean;
  end;

  { TCombatMoveControlSettings (instance size 432, VMT 004129E8): $1AC FMoveFlags. }
  TCombatMoveControlSettings = class(TMoveControlSettings)
  public
    FMoveFlags: Byte; { $1AC }
    F_CombatMoveControlSettings_1AD: array[0..2] of Byte;
  end;

  { TCombatMoveControl (instance size 488, VMT 00412AC4) }
  TCombatMoveControl = class(TMoveControl)
  public
    FUnitHS: TTacticalCombatUnitHS; { $1E0 }
    FMoveFlags: Byte; { $1E4; $405884 }
    F_CombatMoveControl_1E5: array[0..2] of Byte;
    procedure ProcessMove(A1: AoWE.TMoveControlSettings); override;
  end;

  { TTacticalCombatUnit (instance size 104, VMT 00412B4C)
    $5C FMovePoints; $60 FUnitHS; $64..$67 remain unrecovered. }
  TTacticalCombatUnit = class(TCombatUnit)
  public
    FMovePoints: Integer; { $5C }
    FUnitHS: TTacticalCombatUnitHS; { $60 }
    F_TacticalCombatUnit_64: Byte;
    F_TacticalCombatUnit_65: Byte;
    F_TacticalCombatUnit_66: array[0..0] of Byte;
    F_TacticalCombatUnit_67: Byte;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure NewTurn(A1: Byte); override;
    function ExecuteDamage(A1: Integer): Integer; override;
    function GetPosValue: Integer;  { draft }
    procedure MovedTo(OldField, NewField: TAoWMapField; MoveCost: Integer);
  end;

  { TTacticalCombatUnitHS (instance size 72, VMT 00412D08): $1C FUnit;
    $24 FAction; $25 FActionDone; $26 FActionFrame; $34 FSelectedAbility;
    $38 FSelectedSpell; $3C FCombatAbilityCount; $40 FAbilities. }
  TTacticalCombatUnitHS = class(TUnitHS)
  public
    FUnit: TTacticalCombatUnit; { $1C }
    { conflict: FCombatUnit: TTacticalCombatUnit; }
    F_TacticalCombatUnitHS_20: Word;
    F_TacticalCombatUnitHS_22: Word;
    FAction: TTCAction; { $24 }
    FActionDone: Boolean; { $25 }
    FActionFrame: Word; { $26 }
    F_TacticalCombatUnitHS_28: array[0..3] of Byte;
    F_TacticalCombatUnitHS_2C: Integer;
    F_TacticalCombatUnitHS_30: Integer;
    FSelectedAbility: Integer; { $34 }
    FSelectedSpell: Integer; { $38 }
    FCombatAbilityCount: Integer; { $3C }
    FAbilities: TList; { $40 }
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
    procedure Initialize(U: TTacticalCombatUnit);
    procedure NewFrame(Sender: TObject);
    function MeleeMoveTC(Path: TMovepath): Boolean;
    function SelectAbility(A1: Integer): Integer;  { draft }
    function SelectSpell(A1: Integer): Integer;  { draft }
    procedure CreateTCAbList;  { draft }
    procedure ListAbilities(A1: Integer; A2: Integer);  { draft }
    procedure SetAction(Action: TTCAction);
    function AbTouchMoveTC(A1: Integer): Byte;  { draft }
    function AbRangedTC(X, Y: Word): Boolean;
  end;

  { TCombatUnitSelectionControl (instance size 60, VMT 00412EB4): $18 FPathInvalid;
    $1C FTargetImages; $20 FRangedPathHS; $34 FRangedPath; $38 FObstacles. }
  TCombatUnitSelectionControl = class(TMoveSelector)
  public
    FPathInvalid: set of (piMove, piRanged); { $18 }
    F_CombatUnitSelectionControl_19: array[0..2] of Byte;
    FTargetImages: TCustomImageLibrary; { $1C }
    FRangedPathHS: TRangedPathHS; { $20 }
    F_CombatUnitSelectionControl_24: Integer;
    F_CombatUnitSelectionControl_28: Integer;
    F_CombatUnitSelectionControl_2C: Word;
    F_CombatUnitSelectionControl_2E: Word;
    FMouseOverTarget: THexagonSprite; { $30; $436B53 }
    FRangedPath: TXYZList; { $34 }
    FObstacles: TList; { $38 }
    destructor Destroy; override;
    procedure MouseDownEvent(Sender: TObject); override;
    procedure CalculateMovePath(Index: Integer; X, Y, L: Shortint); override;
    procedure UpdateMoveCursor; override;
    function CreateMCS: AoWE.TMoveControlSettings; override;
    procedure SetCurrentMove(A1: Integer); override;
    procedure Unselect; override;
    procedure ShowMovePaths(const Surface: GFXE.TSurfaceDesc); override;
    constructor Create;
    function AddUnit(U: TTacticalCombatUnitHS): Integer;
    function GetTCUnitHS: TTacticalCombatUnitHS;
    function GetMoveTypes: TMoveTypes;
    procedure RectangleSelectEvent(Sender: TObject);
    procedure MoveSelectionEvent(A1: Integer);  { draft }
    procedure CalculateRangedPath(A1: Byte; A2: Byte);  { draft }
    procedure MoveSelectedRoute;  { draft }
    procedure MoveUnits;  { draft }
    procedure ExecuteMoveSelection;  { draft }
    function ValidMultiMoveSelection(Field: TAoWMapField): Boolean;
    procedure ActivateMoveSelection;
    procedure DeactivateMoveSelection;
    procedure Update;
    procedure SetTCUnitHS(U: TTacticalCombatUnitHS);
    procedure Select(U: TTacticalCombatUnitHS);
    procedure DeactivateRangedPath;
  end;

  { TTacticalCombatPlayer (instance size 28, VMT 00412F78)
    $0C FAuto; $0D FEndTurn; $0E FIndex; $10 FLastX; $14 FLastY; $18 FLastUnit. }
  TTacticalCombatPlayer = class(TCombatPlayer)
  public
    FAuto: Boolean; { $0C }
    FEndTurn: Boolean; { $0D }
    FIndex: Shortint; { $0E }
    FReserved0F: Byte; FLastX, FLastY: Integer; FLastUnit: TTacticalCombatUnit; { $10, $14, $18 }
    procedure SetAuto(Value: Boolean);
  end;

  { TTacticalCombatPlayerList (instance size 8, VMT 0041304C)
    $04 FPlayers. }
  TTacticalCombatPlayerList = class(TObject)
  public
    FPlayers: TCombatPlayerList; { $04 }
    function GetCount: Integer;
    function GetPlayers(Index: Shortint): TTacticalCombatPlayer;
    { conflict: function GetPlayers(Player: Shortint): TTacticalCombatPlayer; }
  end;

  { TAoWCombatMapMouse (instance size 80, VMT 004130DC) }
  TAoWCombatMapMouse = class(TAbstractAoWHSMapMouse)
  public
  end;

  { TAoWCombatMap (instance size 312, VMT 00413184)
    $E0 FPlayers; $E4 FCombat; $E8 FUnitPositions; $EC FSeatedCombatPlayer;
    $ED FCurrentCombatPlayer; $F0..$F8 turn/player events; $FC FMoveControl;
    $100 FUnitSelection; $104..$114 selection/unit events; $118 FAI; $11C FEffects;
    $120 FWalls; $124 FFleeLocations; $128 FEndTurnPending; $129 FPlaySounds;
    $12A FPositionStatus; $134 FRound. }
  TAoWCombatMap = class(TAbstractAoWCombatMap)
  public
    FPlayers: TTacticalCombatPlayerList; { $E0 }
    FCombat: TTacticalCombat; { $E4 }
    FUnitPositions: TUnitPositionControl; { $E8 }
    FSeatedCombatPlayer: Shortint; { $EC }
    { conflict: FSeatedCombatPlayer: Byte; }
    FCurrentCombatPlayer: Shortint; { $ED }
    { conflict: FCurrentCombatPlayer: Shortint; }
    F_AoWCombatMap_EE: array[0..1] of Byte;
    FChangeTurnEvents: TEventList; { $F0 }
    { conflict: FTurnChangedEvents: TEventList; }
    FPlayerChangedEvents: TEventList; { $F4 }
    FSeatedPlayerChangedEvents: TEventList; { $F8 }
    FMoveControl: TCombatMoveControl; { $FC }
    FUnitSelection: TCombatUnitSelectionControl; { $100 }
    FSelectEvents: TEventList; { $104 }
    { conflict: FDeactivateMapEvents: TEventList; }
    FDeselectEvents: TEventList; { $108 }
    { conflict: FActivateMapEvents: TEventList; }
    F_AoWCombatMap_10C: array[0..3] of Byte;
    FUnitChangedEvents: TEventList; { $110 }
    { conflict: FMouseOverTargetEvents: TEventList; }
    FMouseOverTargetEvents: TEventList; { $114 }
    { conflict: FUnitChangedEvents: TEventList; }
    FAI: TCAI; { $118 }
    FEffects: TList; { $11C }
    FWalls: TList; { $120; $405741 }
    FFleeLocations: TList; { $124 }
    FEndTurnPending: Boolean; { $128 }
    FPlaySounds: Boolean; { $129; $405B38 }
    FPositionStatus: array[0..7] of Byte; { $12A }
    F_AoWCombatMap_132: array[0..1] of Byte;
    FRound: Integer; { $134 }
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
    procedure SetCombat(Combat: TTacticalCombat);
    procedure MouseMoveEvent(Sender: TObject);
    procedure SetSeatedCombatPlayer(Player: Shortint);
    procedure NewTurn(Player: Shortint);
    procedure DrawMoveRoute(const SD: TSurfaceDesc);
    function EndTurn(Automatic: Boolean): Boolean;
    procedure CancelEndTurn;
    function GetEndTurnStatus: Boolean;
    function GetNextUnit(U: TTacticalCombatUnit; AllUnits, Forward: Boolean): TTacticalCombatUnit;
    function AddEffect(EffectType: TfxType): TfxHS;
    { conflict: function AddEffect(Effect: Byte): TfxHS; }
    procedure UpdateCursor;
    procedure EndCombat(A1: Integer);  { draft }
    procedure SelectNextUnit(Forward: Boolean);
    procedure GetUnitLocation(U: TAbstractUnit; var X, Y, L: Shortint);
    procedure Surrender(Mode: Boolean);
  end;

  { TTacticalCombat (instance size 80, VMT 00413314)
    Inherited combat layout; $4C remains unrecovered. }
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

procedure MakeAbilPath(Side: TCombatSideIndex; Ability, Spell: Smallint;
  X1, Y1, X2, Y2: Smallint; var Path: TXYZList; var Obstacles: TList);
procedure MakeRangedPath(Side: TCombatSideIndex; Height, Step, Arc: Smallint;
  X1, Y1, X2, Y2: Smallint; Ignore: TMapObject; Mode: Boolean;
  Z: Smallint; var Path: TXYZList; var Obstacles: TList);
procedure RegisterAoWTCClasses(A1: Integer);  { draft }
function GetMeleeDirIndex(A1: Integer; A2: Integer; A3: Integer): Word;  { draft }
function GetRangedDirIndex(A1: Integer; A2: Integer): Integer;  { draft }

var
  AoWCombatMap: TAoWCombatMap;
  CombatXLoc, CombatYLoc, CombatLLoc: Integer; { $46C058..$46C064 }
  TCAttack, TCDamage: array[0..1] of Integer;
  { conflict: const TCAttack: array[0..1] of Integer = (6, 10); }
  { conflict: const TCDamage: array[0..1] of Integer = (6, 1); }
const
  AbilTypes: array[0..169] of TfxType = (
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxArrow, fxNone,
    fxRock, fxRock, fxNone, fxTouch, fxTouch, fxTouch, fxBreath, fxEffect, fxNone, fxNone, fxNone, fxTouch,
    fxNone, fxNone, fxTouch, fxNone, fxTouch, fxNone, fxNone, fxNone, fxRock, fxRock, fxNone, fxTouch,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxRay, fxNone, fxArrow, fxArrow, fxNone,
    fxTouch, fxArrow, fxComet, fxNone, fxNone, fxTouch, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxBreath, fxBreath, fxBreath, fxBreath, fxBreath, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxTouch, fxTouch,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxTouch, fxNone, fxNone, fxTouch, fxNone, fxNone,
    fxComet, fxComet, fxComet, fxComet, fxComet, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxTouch, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone);
  SpellTypes: array[0..130] of TfxType = (
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxEffect, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxEffect, fxEffect, fxEffect, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxEffect, fxEffect, fxNone, fxEffect,
    fxEffect, fxEffect, fxNone, fxEffect, fxEffect, fxEffect, fxEffect, fxEffect, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxEffect, fxNone, fxNone, fxNone, fxNone, fxNone, fxEffect, fxEffect, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxEffect, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone, fxNone,
    fxNone, fxNone, fxNone, fxNone, fxCometBall, fxEffect, fxHighPrayer, fxRay, fxCloud, fxScreenNESW, fxMindDecay, fxChain,
    fxBreath, fxNone, fxEffect, fxEffect, fxTremors, fxEffect, fxBreath, fxScreenSwarm, fxScreenNS, fxRock, fxGeyser, fxAltArrow,
    fxFrostBeam, fxEffect, fxRock, fxCometBall, fxScreenNS, fxSacredWrath, fxWinds, fxShockWave, fxSacFlame, fxResurrect, fxResurrect);
  BreathHN: array[0..71] of Integer = (
    1, 18, 7, 8, 36, 19, 20, 59, 60, 37, 38, 39,
    2, 8, 9, 10, 21, 22, 23, 39, 40, 41, 42, 43,
    3, 10, 11, 12, 24, 25, 26, 43, 44, 45, 46, 47,
    4, 12, 13, 14, 27, 28, 29, 47, 48, 49, 50, 51,
    5, 14, 15, 16, 30, 31, 32, 51, 52, 53, 54, 55,
    6, 16, 17, 18, 33, 34, 35, 55, 56, 57, 58, 59);
  BreathDirection: array[1..60] of Integer = (
    1, 2, 3, 4, 5, 6, 1, 1, 2, 2, 3, 3,
    4, 4, 5, 5, 6, 6, 1, 1, 2, 2, 2, 3,
    3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 1,
    1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4,
    4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 1);
  WallISIndex: array[0..1] of Integer = (30, 0);
  WallMaxHP: array[0..1] of Integer = (7, 13);

implementation

uses CityWall, CombatTE, CombatFire, AoWReg;
constructor TCAI.Create;
begin
  inherited Create;
  Units := TList.Create;
  Allies := TList.Create;
  Enemies := TList.Create;
  Moves := TList.Create;
  Walls := TList.Create;
end;

destructor TCAI.Destroy;
var I: Integer;
begin
  Units.Free;
  Allies.Free;
  Enemies.Free;
  Walls.Free;
  for I := 0 to Moves.Count - 1 do TObject(Moves[I]).Free;
  Moves.Free;
  inherited Destroy;
end;

procedure TCAI.Reset;
begin
  Status := aiIdle;
  CurrentMove := 0;
end;

procedure TCAI.BeginTurn;
begin
  EvalBattle;
end;

procedure TCAI.ContinueTurn;
begin
  EvalBattle;
end;

procedure TCAI.CreateMove(MoveType: TaiMoveType; Value, Cost: Integer; Ability: TAbility; X, Y: Integer; U: TTacticalCombatUnit; Path: TXYLList);
var M: TaiMove;
begin
  M := TaiMove.Create;
  M.UnitHS := U.FUnitHS;
  M.Path := Path;
  M.MoveType := MoveType;
  M.X := X;
  M.Y := Y;
  M.Value := Value;
  M.Cost := Cost;
  M.Ability := Ability;
  Moves.Add(M);
end;

function TCAI.tcDVtoDEV(DV1, DV2: Integer; Source, Target: TCombatObject): Integer;
var Strength: Integer;
begin
  Strength := Target.GetTargetStrength;
  if Target is TTacticalCombatUnit then begin
    if TTacticalCombatUnit(Target).FUnit is THero then Strength := Strength * 2;
    if TTacticalCombatUnit(Target).FUnit is TLeader then Strength := Strength * 2;
  end;
  Result := Strength * DV1;
  Strength := Source.GetTargetStrength;
  if Source is TTacticalCombatUnit then begin
    if TTacticalCombatUnit(Source).FUnit is THero then Strength := Strength * 2;
    if TTacticalCombatUnit(Source).FUnit is TLeader then Strength := Strength * 2;
  end;
  Result := Result - Strength * DV2;
  Result := Result div 100;
end;

function TCAI.ChargeFromPos(Position: Integer): Boolean;
var
  I, J, Empty: Integer;
begin
  if Position = 0 then begin
    Result := False;
    Empty := 0;
    if (FSide = csDefender) and (AoWCombatMap.FCombat.FCombatData.FWallType <> 0) and
       not AoWCombatMap.FCombat.FCombatData.FWallBreached then
      Result := True
    else begin
      for I := 1 to 6 do begin
        if AoWCombatMap.FPositionStatus[I] = 1 then begin
          J := I - 1;
          if J = 0 then J := 6;
          if AoWCombatMap.FPositionStatus[J] = 0 then Result := True;
          J := I + 1;
          if J = 7 then J := 1;
          if AoWCombatMap.FPositionStatus[J] = 0 then Result := True;
        end else if AoWCombatMap.FPositionStatus[I] = 0 then Inc(Empty);
      end;
      if Empty > 1 then Result := True;
    end;
  end else Result := True;
end;

function TCAI.UnitSafe(U: TTacticalCombatUnit; X, Y: Integer): Integer;
var
  I, Distance: Integer;
begin
  if not (U.FUnit is THero) or ((Units.Count = 1) and (FSide = csDefender)) then
    Result := 0
  else begin
    Result := U.GetTargetStrength * 20 * U.GetHitPoints div U.GetHits;
    if U.FUnit is TLeader then Result := Result div 2;
    for I := 0 to Enemies.Count - 1 do begin
      Distance := dHXtoRad(X, Y, TTacticalCombatUnit(Enemies[I]).FUnitHS.GetXhx,
        TTacticalCombatUnit(Enemies[I]).FUnitHS.GetYhx);
      if (Distance < 15) and (TTacticalCombatUnit(Enemies[I]).GetTargetStrength > 0) then
        Result := Result - TTacticalCombatUnit(Enemies[I]).GetTargetStrength * (15 - Distance);
    end;
    for I := 0 to Units.Count - 1 do
      if TTacticalCombatUnit(Units[I]) <> U then begin
        Distance := dHXtoRad(X, Y, TTacticalCombatUnit(Units[I]).FUnitHS.GetXhx,
          TTacticalCombatUnit(Units[I]).FUnitHS.GetYhx);
        if (Distance < 15) and (TTacticalCombatUnit(Units[I]).GetTargetStrength > 0) then
          Result := Result + TTacticalCombatUnit(Units[I]).GetTargetStrength * (15 - Distance);
      end;
    for I := 0 to Allies.Count - 1 do begin
      Distance := dHXtoRad(X, Y, TTacticalCombatUnit(Allies[I]).FUnitHS.GetXhx,
        TTacticalCombatUnit(Allies[I]).FUnitHS.GetYhx);
      if (Distance < 15) and (TTacticalCombatUnit(Allies[I]).GetTargetStrength > 0) then
        Result := Result + TTacticalCombatUnit(Allies[I]).GetTargetStrength * (15 - Distance);
    end;
  end;
end;

function TCAI.MakeTerrainPath(MCS: TCombatMoveControlSettings; var Path: TXYLList;
  var Value: Integer; U, Ignore: TTacticalCombatUnit; FreeStrikes, FindWalls: Boolean; Cost: Integer): Integer;
var
  I, J, X, Y: Integer;
  HS: TTacticalCombatUnitHS;
  Wall: TCityWall;
  NewWall: Boolean;
begin
  if Path.Count < 2 then Result := -1 else Result := 0;
  try
    Value := 0;
    if Result <> -1 then
      for I := 0 to Path.Count - 1 do begin
        HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].
          Field[Path.List[I].X, Path.List[I].Y].FindOwnedChild($220104));
        if FreeStrikes and ((HS = nil) or ((HS = U.FUnitHS) and (I - 1 >= 0) and
          (AoWCombatMap.MapContainer.MapLevels[0].Field[Path.List[I - 1].X,
            Path.List[I - 1].Y].FindOwnedChild($220104) = nil))) then
          for J := 1 to 6 do begin
            CenterHNtoHX(Path.List[I].X, Path.List[I].Y, J, X, Y);
            HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].
              Field[X, Y].FindOwnedChild($220104));
            if (HS <> nil) and (HS.FUnit <> Ignore) and
              (HS.FUnit.GetSide <> U.GetSide) and (MeleeDamageTypes(HS.FUnit) <> []) and
              not HS.FUnit.GetLocked and (HS.FUnit.GetAbilityEnabled(1) = U.GetAbilityEnabled(1)) then
              Value := Value - tcDVtoDEV(StrikeDV(HS.FUnit, U), 0, HS.FUnit, U) * 10;
          end;
        if I < Path.Count - 1 then begin
          if AoWCombatMap.FCombat.FCombatData.FWallType = 0 then Wall := nil
          else begin
            Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].
              Field[Path[I].X, Path[I].Y].FindOwnedChild($220504));
            if Wall = nil then
              Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].
                Field[Path[I].X, Path[I].Y].FindOwnedChild($220506));
          end;
          Path.List[I].Flag := MCS.FMovePointTable[AoWCombatMap.MapContainer.MapLevels[0].
            Field[Path[I].X, Path[I].Y].TerrainType * 2,
            AoWCombatMap.MapContainer.MapLevels[0].Field[Path[I].X, Path[I].Y].OverlayType + 1];
          if Wall <> nil then begin
            { Original bug: the next terrain lookup uses Path[0].Y. }
            if (FSide = csAttacker) and (U.GetAbilityEnabled($41) or
              U.GetAbilityEnabled($75)) and (I = 0) then
              Path.List[I].Flag := MCS.FMovePointTable[AoWCombatMap.MapContainer.MapLevels[0].
                Field[Path[I].X, Path[0].Y].TerrainType * 2, 0]
            else if ((FSide = csAttacker) or AoWCombatMap.FCombat.FCombatData.FWallBreached or FIgnoreWalls) and
              ((Wall.FHitPoints = 0) or ((FSide = csDefender) and (Wall is TCityWallDoor)) or
              AoWCombatMap.FMoveControl.FUnitHS.FUnit.GetAbilityEnabled(1) or
              AoWCombatMap.FMoveControl.FUnitHS.FUnit.GetAbilityEnabled($42) or
              AoWCombatMap.FMoveControl.FUnitHS.FUnit.GetAbilityEnabled($24)) then
              Path.List[I].Flag := MCS.FMovePointTable[AoWCombatMap.MapContainer.MapLevels[0].
                Field[Path[I].X, Path[I].Y].TerrainType * 2, 0]
            else Path.List[I].Flag := 100;
            if FindWalls and (Wall.FHitPoints > 0) then begin
              NewWall := True;
              J := 0;
              while NewWall and (J < Walls.Count) do
                if Walls[J] = Wall then NewWall := False else Inc(J);
              if NewWall then Walls.Add(Wall);
            end;
          end;
          if AoWCombatMap.MapContainer.MapLevels[0].Field[Path[I].X, Path[I].Y].
            FindOwnedChild($220104) <> nil then
            Path.List[I].Flag := MCS.FMovePointTable[AoWCombatMap.MapContainer.MapLevels[0].
              Field[Path[I].X, Path[I].Y].TerrainType * 2, 0];
        end;
        Result := Result + Path.List[I].Flag;
      end;
  except
    MessageBox(0, 'Error during Eval Movepath', PChar('Error - TCAI ' + U.FUnit.GetName), 0);
  end;
end;

function TCAI.MultDEV(Value, Multiplier, Divider: Integer): Integer;
begin
  Result := Value;
  if Value >= 0 then begin
    try
      if Multiplier <> 1 then Result := Result * Multiplier;
      if (Divider <> 1) and (Divider <> 0) then Result := Result div Divider;
    except
      try
        if (Divider <> 1) and (Divider <> 0) then Result := Result div Divider;
        if Multiplier <> 1 then Result := Result * Multiplier;
      except Result := 1000000; end;
    end;
  end else begin
    try
      if Divider <> 1 then Result := Result * Divider;
      if (Multiplier <> 1) and (Multiplier <> 0) then Result := Result div Multiplier;
    except
      try
        if (Multiplier <> 1) and (Multiplier <> 0) then Result := Result div Multiplier;
        if Divider <> 1 then Result := Result * Divider;
      except Result := -1000000; end;
    end;
  end;
  if Result > 1000000 then Result := 1000000;
  if Result < -1000000 then Result := -1000000;
end;

procedure TCAI.EvalAll(var Value: Integer; List: TList; Ignore: TCombatObject;
  Spell: Integer; U: TTacticalCombatUnit);
var
  I: Integer;
  Target: TCombatObject;
  DV: TAbilityDamageValues;
begin
  for I := 0 to List.Count - 1 do
    if TCombatObject(List[I]) <> Ignore then begin
      Target := TCombatObject(List[I]);
      AoWHSSet.FSpellControl.GetSpell(Spell).tcGetDamageValueEx(U, Target, DV);
      if DV.SourceDamage > 0 then
        case Spell of
          $66:
            if Target.GetSide <> FSide then
              Value := Value - tcDVtoDEV(DV.SourceDamage, 0, U, Target)
            else Value := Value + tcDVtoDEV(DV.SourceDamage, 0, U, Target);
        else
          if Target.GetSide <> FSide then
            Value := Value + MultDEV(tcDVtoDEV(DV.SourceDamage, 0, U, Target),
              Target.GetHits, Target.GetHitPoints)
          else Value := Value - MultDEV(tcDVtoDEV(DV.SourceDamage, 0, U, Target),
              Target.GetHits, Target.GetHitPoints);
        end;
    end;
end;

procedure TCAI.EvalHex(Ignore: TCombatObject; Ability, Spell, X, Y: Integer; var Value: Integer;
  HitWalls, Friendly: Boolean; U: TTacticalCombatUnit; IgnoreWall: TObject);
var
  HS: TTacticalCombatUnitHS;
  Wall: TCityWall;
  DV: TAbilityDamageValues;
begin
  HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].
    Field[X, Y].FindOwnedChild($220104));
  if (HS <> nil) and (HS.FUnit <> Ignore) and
    (Friendly or (HS.FUnit.GetSide <> U.GetSide)) then begin
    if Ability = $34 then
      AoWHSSet.FSpellControl.GetSpell(Spell).tcGetDamageValueEx(U, HS.FUnit, DV)
    else if AbilTypes[Ability] = fxTouch then
      AoWHSSet.FAbilityControl.GetAbility(Ability).tcGetDamageValueEx(U, HS.FUnit, DV)
    else AoWHSSet.FAbilityControl.GetAbility(Ability).tcGetDamageValueEx(U, HS.FUnit, DV);
    if Ability = $41 then DV.TargetDamage := 0;
    if DV.SourceDamage > 0 then begin
      case Ability of
        $34: begin
        case Spell of
          $6A:
            if HS.FUnit.GetSide <> U.GetSide then
              Value := Value + tcDVtoDEV(DV.SourceDamage, 0, U, HS.FUnit)
            else Value := Value - tcDVtoDEV(DV.SourceDamage, 0, U, HS.FUnit);
        else
          if HS.FUnit.GetSide <> U.GetSide then
            Value := Value + MultDEV(tcDVtoDEV(DV.SourceDamage, 0, U, HS.FUnit),
              HS.FUnit.GetHits, HS.FUnit.GetHitPoints)
          else Value := Value - MultDEV(tcDVtoDEV(DV.SourceDamage, 0, U, HS.FUnit),
              HS.FUnit.GetHits, HS.FUnit.GetHitPoints);
        end;
      end;
      else
        if HS.FUnit.GetSide <> U.GetSide then
          Value := Value + MultDEV(tcDVtoDEV(DV.SourceDamage, 0, U, HS.FUnit),
            HS.FUnit.GetHits, HS.FUnit.GetHitPoints)
        else Value := Value - MultDEV(tcDVtoDEV(DV.SourceDamage, 0, U, HS.FUnit),
            HS.FUnit.GetHits, HS.FUnit.GetHitPoints);
      end;
    end;
  end;
  if HitWalls and (AoWCombatMap.FCombat.FCombatData.FWallType <> 0) then begin
    Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].FindOwnedChild($220504));
    if Wall = nil then
      Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].FindOwnedChild($220506));
    if not AoWCombatMap.FCombat.FCombatData.FWallBreached and (IgnoreWall <> nil) and
      (Wall <> nil) and ((Ignore = nil) or not (Ignore is TCombatWall) or
      ((Ignore is TCombatWall) and (IgnoreWall <> Wall))) then begin
      if Ability = $34 then
        AoWHSSet.FSpellControl.GetSpell(Spell).tcGetDamageValueEx(U, AoWCombatMap.FCombat.FCombatData.FWall, DV)
      else if AbilTypes[Ability] = fxTouch then
        AoWHSSet.FAbilityControl.GetAbility(Ability).tcGetDamageValueEx(U, AoWCombatMap.FCombat.FCombatData.FWall, DV)
      else AoWHSSet.FAbilityControl.GetAbility(Ability).tcGetDamageValueEx(U, AoWCombatMap.FCombat.FCombatData.FWall, DV);
      if Ability = $41 then DV.TargetDamage := 0;
      if DV.SourceDamage > 0 then
        if U.GetSide = csAttacker then
          Value := Value + MultDEV(tcDVtoDEV(DV.SourceDamage, 0, U, AoWCombatMap.FCombat.FCombatData.FWall),
            WallMaxHP[Wall.FWallType - 1], Wall.FHitPoints)
        else Value := Value - MultDEV(tcDVtoDEV(DV.SourceDamage, 0, U, AoWCombatMap.FCombat.FCombatData.FWall),
            WallMaxHP[Wall.FWallType - 1], Wall.FHitPoints);
    end;
  end;
end;

procedure TCAI.EvalArea(var Value: Integer; Ignore: TCombatObject; Ability, Spell, X, Y: Integer;
  HitWalls, IncludeCenter, Friendly: Boolean; U: TTacticalCombatUnit; IgnoreWall: TObject);
var
  I, X1, Y1: Integer;
begin
  for I := 0 to 6 do begin
    CenterHNtoHX(X, Y, I, X1, Y1);
    if IncludeCenter or (U.FUnitHS.GetXhx <> X1) or (U.FUnitHS.GetYhx <> Y1) then
      EvalHex(Ignore, Ability, Spell, X1, Y1, Value, HitWalls, Friendly, U, IgnoreWall);
  end;
end;

function TCAI.EvalPath(var Value: Integer; Ignore: TCombatObject; Ability, Spell, X1, Y1, X2, Y2: Integer;
  HitWalls: Boolean; U: TTacticalCombatUnit; IgnoreWall: TObject): Integer;
var
  Path: TXYZList;
  Obstacles: TList;
  I, X, Y, V, Total, Original, Chance: Integer;
  FX: TfxType;
begin
  if Ability = $34 then FX := SpellTypes[Spell] else FX := AbilTypes[Ability];
  case FX of
    fxArrow, fxRock, fxComet, fxBreath, fxCometBall, fxRay, fxAltArrow:
      begin
        Path := TXYZList.Create;
        Obstacles := TList.Create;
        if FX = fxBreath then
          MakeRangedPath(U.GetSide, 50, 20, 50, X1, Y1, X2, Y2, nil, False, 0, Path, Obstacles)
        else MakeAbilPath(U.GetSide, Ability, Spell, X1, Y1, X2, Y2, Path, Obstacles);
        Total := 0;
        Original := Value;
        Chance := 100;
        for I := 0 to Obstacles.Count - 1 do begin
          HPtoHX(Path[TROb(Obstacles[I]).PathIndex].X, Path[TROb(Obstacles[I]).PathIndex].Y, X, Y);
          V := 0;
          EvalHex(Ignore, Ability, Spell, X, Y, V, HitWalls, True, U, IgnoreWall);
          try
            Total := Total + (V * Chance div 100) * TROb(Obstacles[I]).Chance div 100;
          except
            Total := Total + TROb(Obstacles[I]).Chance * (V div 100 * Chance div 100);
          end;
          Chance := (100 - TROb(Obstacles[I]).Chance) * Chance div 100;
        end;
        try
          Value := Value * Chance div 100;
        except
          Value := Value div 100 * Chance;
        end;
        Value := Value + Total;
        Path.Free;
        for I := 0 to Obstacles.Count - 1 do TObject(Obstacles[I]).Free;
        Obstacles.Free;
        Result := Original - Value;
      end;
  else Result := 0;
  end;
end;

function TCAI.EvalBreath(var Value: Integer; Ignore: TCombatObject; Ability, Spell, X1, Y1, X2, Y2: Integer;
  U: TTacticalCombatUnit): Integer;
var
  I, V, X, Y: Integer;
begin
  Result := EvalPath(Value, Ignore, Ability, Spell, U.FUnitHS.GetXhx,
    U.FUnitHS.GetYhx, X2, Y2, False, U, nil);
  for I := 0 to 11 do begin
    V := 0;
    CenterHNtoHX(X1, Y1, BreathHN[BreathDirection[dHXtoHN(X1, Y1, X2, Y2)] * 12 + I - 12], X, Y);
    EvalHex(Ignore, Ability, Spell, X, Y, V, True, True, U, nil);
    if V <> 0 then
      EvalPath(V, Ignore, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx,
        X, Y, False, U, nil);
    Value := Value + V;
    Result := Result - V;
  end;
end;

procedure TCAI.CheckUnit(A1: Integer; A2: Integer);
begin end;

procedure TCAI.EvalBattle;
begin end;

constructor TAoWNewCombatMapSettings.Create;
begin
  inherited Create;
  HSMapClassID := $220100;
  MapLevelClassID := $220102;
  Width := 65;
  Height := 59;
  Levels := 1;
  HSSFileName := AoWEngine.HSSFileName;
end;

class function TAoWCombatMapField.ClassID: Integer;
begin
  Result := $220101;
end;

function TAoWCombatMapField.GetDefenseValue: Shortint;
var Msg: TMapFieldMsg;
begin
  Msg.MsgID := $21001;
  Msg.Result := -1;
  Msg.Param[0] := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Param[0];
end;

class function TAoWCombatMapLevel.ClassID: Integer;
begin
  Result := $220102;
end;

function TAoWCombatMapLevel.MapFieldClass: Engine.TEObjectClass;
begin
  Result := TAoWMapField; { Original uses the world-map field class. }
end;

class function TAoWCombatMap.ClassID: Integer;
begin Result := $220100; end;

constructor TAoWCombatMap.Create(AOwner: TECustomNode);
var I: Integer;
begin
  AoWCombatMap := Self;
  inherited Create(AOwner);
  FUnitPositions := TUnitPositionControl.Create(nil);
  FChangeTurnEvents := TEventList.Create;
  FPlayerChangedEvents := TEventList.Create;
  FSeatedPlayerChangedEvents := TEventList.Create;
  FMoveControl := TCombatMoveControl.Create(Self);
  FSelectEvents := TEventList.Create;
  FDeselectEvents := TEventList.Create;
  FUnitChangedEvents := TEventList.Create;
  FMouseOverTargetEvents := TEventList.Create;
  FPlayers := TTacticalCombatPlayerList.Create;
  FUnitSelection := TCombatUnitSelectionControl.Create;
  TAoWCombatMapMouse(Mouse).FRectangleSelectEvents.Add(FUnitSelection.RectangleSelectEvent);
  FEffects := TList.Create;
  FWalls := TList.Create;
  FFleeLocations := TList.Create;
  FAI := TCAI.Create;
  Mouse.SetCapture(Self);
  Mouse.OnMove.Add(MouseMoveEvent);
  Mouse.CursorMode := $100;
  for I := 0 to 7 do FPositionStatus[I] := 2;
end;

destructor TAoWCombatMap.Destroy;
begin
  while FEffects.Count > 0 do begin
    DynamicFixedVisibleHS.RemoveChild(THexagonSprite(FEffects[0]));
    DynamicVisibleHS.RemoveChild(THexagonSprite(FEffects[0]));
    TObject(FEffects[0]).Free;
    FEffects.Delete(0);
  end;
  inherited Destroy;
  AoWCombatMap := nil;
  FUnitPositions.Free;
  FChangeTurnEvents.Free;
  FPlayerChangedEvents.Free;
  FSeatedPlayerChangedEvents.Free;
  FSelectEvents.Free;
  FDeselectEvents.Free;
  FUnitChangedEvents.Free;
  FMouseOverTargetEvents.Free;
  FMoveControl.Free;
  FPlayers.Free;
  FUnitSelection.Free;
  FEffects.Free;
  FWalls.Free;
  FFleeLocations.Free;
  FAI.Free;
end;

function TAoWCombatMap.CreateMouse: THSMapMouse;
begin Result := TAoWCombatMapMouse.Create; end;

procedure TAoWCombatMap.SetCombat(Combat: TTacticalCombat);
begin
  FCombat := Combat;
  if FCombat <> nil then FPlayers.FPlayers := FCombat.FCombatData.FPlayers;
end;

procedure TAoWCombatMap.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if (Msg.MsgID = $20000008) and not (msEditting in Status) then
    SetCombat(TTacticalCombat(AoWHSMap.FCombat));
  inherited MsgProc(Msg, Sender);
end;

procedure TAoWCombatMap.MouseMoveEvent(Sender: TObject);
var HS: TTacticalCombatUnitHS;
begin
  if not (msEditting in AoWCombatMap.Status) and not FPlayers.GetPlayers(FCurrentCombatPlayer).FAuto and
    (Mouse.Xhx <> -1) and (Mouse.Yhx <> -1) and (Mouse.Capture = nil) then begin
    Mouse.CursorMode := 0;
    HS := TTacticalCombatUnitHS(MapContainer.MapLevels[0].Field[Mouse.Xhx, Mouse.Yhx].FindOwnedChild($220104));
    if HS <> nil then Mouse.CursorMode := $101;
  end;
end;

procedure TAoWCombatMap.InitializeNewMap;
var
  Control: THexagonControl;
  X, Y: Integer;
begin
  for X := 6 to MapContainer.Width - 7 do
    for Y := 6 to MapContainer.Height - 7 do
      AoWHSSet.FCombatHexagons.Place(MapContainer, X, Y, 0, 1);
  Control := Engine.HSSet.HexagonControl;
  with Control do begin
    for X := 0 to MapContainer.Width - 1 do begin
      for Y := 0 to 5 do Place(MapContainer, X, Y, 0, 15);
      for Y := MapContainer.Height - 6 to MapContainer.Height - 1 do Place(MapContainer, X, Y, 0, 15);
    end;
    for Y := 6 to MapContainer.Height - 7 do begin
      for X := 0 to 5 do Place(MapContainer, X, Y, 0, 15);
      for X := MapContainer.Width - 6 to MapContainer.Width - 1 do Place(MapContainer, X, Y, 0, 15);
    end;
  end;
end;

procedure TAoWCombatMap.SetSeatedCombatPlayer(Player: Shortint);
begin
  FSeatedCombatPlayer := Player;
  if Player = -1 then SetSeatedPlayer(-1)
  else SetSeatedPlayer(FCombat.FCombatData.FPlayers.GetPlayers(FSeatedCombatPlayer).FPlayer);
  FSeatedPlayerChangedEvents.TriggerNotifyEvents(TObject(FCurrentCombatPlayer));
end;

procedure TAoWCombatMap.NewTurn(Player: Shortint);
begin end;

procedure TAoWCombatMap.DrawDynamicScene(var SD: TSurfaceDesc);
begin
  inherited DrawDynamicScene(SD);
  if AoWHSMap <> nil then DrawFog(SD);
  if FShowGrid then DrawGrid(SD);
  DrawMoveRoute(SD);
  if TAoWCombatMapMouse(Mouse).FSelectionRectangle.Left <> -1 then
    DrawSelectionRect(ViewXhp, ViewYhp, TAoWCombatMapMouse(Mouse).FSelectionRectangle, SD);
end;

procedure TAoWCombatMap.DrawMoveRoute(const SD: TSurfaceDesc);
begin FUnitSelection.ShowMovePaths(SD); end;

function TAoWCombatMap.EndTurn(Automatic: Boolean): Boolean;
var TE: TCEndTurnTE;
begin
  Result := False;
  if not Automatic then begin
    if AoWHSMap.FPlayers.GetPlayers(FCurrentPlayer).FPlayerType <> ptHuman then Exit;
    if AoWCombatMap.FSeatedCombatPlayer <> AoWCombatMap.FCurrentCombatPlayer then Exit;
  end;
  if AoWHSMap.FTokenManager.PlayerReady(FCurrentPlayer) then begin
    TE := CreateTCEndTurnTE(FCurrentPlayer);
    if TE <> nil then begin
      AoWHSMap.FTokenManager.GetTokenControl(FCurrentPlayer).AddEvent(TE);
      TE.Release;
      Result := True;
      FEndTurnPending := False;
    end;
  end;
end;

procedure TAoWCombatMap.CancelEndTurn;
begin { Intentionally empty in the original. } end;

function TAoWCombatMap.GetEndTurnStatus: Boolean;
var I: Integer;
begin
  Result := True;
  for I := 0 to FPlayers.GetCount - 1 do
    Result := Result and FPlayers.GetPlayers(I).FEndTurn;
end;

function TAoWCombatMap.GetNextUnit(U: TTacticalCombatUnit; AllUnits, Forward: Boolean): TTacticalCombatUnit;
var
  Index, I, Start, Step: Integer;
begin
  if (U <> nil) and not U.GetEnabled then U := nil;
  Result := U;
  if Forward then Step := 1 else Step := -1;
  with FCombat do begin
    Index := 0;
    I := 0;
    Start := 0;
    if U <> nil then
      while I < FCombatData.GetCount do begin
        if FCombatData.GetObjects(I) = U then begin
          Index := I + Step;
          Start := I;
          I := FCombatData.GetCount;
        end;
        Inc(I);
      end;
    while (Index < FCombatData.GetCount) and (Index > -1) do begin
      if (FCombatData.GetObjects(Index) <> nil) and
        (FCombatData.GetObjects(Index) is TCombatUnit) and
        (AllUnits or (TTacticalCombatUnit(FCombatData.GetObjects(Index)).FMovePoints > 0)) and
        FCombatData.GetObjects(Index).GetEnabled and
        (FCombatData.GetObjects(Index).FCombatPlayer = FCurrentCombatPlayer) then begin
        Result := TTacticalCombatUnit(FCombatData.GetObjects(Index));
        Index := -10;
      end;
      Index := Index + Step;
    end;
    if Result = U then begin
      if Forward then Index := 0 else Index := FCombatData.GetCount - 1;
      while (Index <> Start) and (Index > -1) and (Index < FCombatData.GetCount) do begin
        if (FCombatData.GetObjects(Index) <> nil) and
          (FCombatData.GetObjects(Index) is TCombatUnit) and
          (AllUnits or (TTacticalCombatUnit(FCombatData.GetObjects(Index)).FMovePoints > 0)) and
          FCombatData.GetObjects(Index).GetEnabled and
          (FCombatData.GetObjects(Index).FCombatPlayer = FCurrentCombatPlayer) then begin
          Result := TTacticalCombatUnit(FCombatData.GetObjects(Index));
          Index := -10;
        end;
        Index := Index + Step;
      end;
    end;
  end;
end;

procedure TAoWCombatMap.NewFrame;
begin end;

function TAoWCombatMap.AddEffect(EffectType: TfxType): TfxHS;
begin
  Result := TfxHS.Create(nil);
  FEffects.Add(Result);
  Result.Activate;
  Result.FEffectType := EffectType;
  DynamicFixedVisibleHS.AddChild(Result);
end;

procedure TAoWCombatMap.UpdateCursor;
begin
  if ((FSeatedPlayer = -1) or AoWHSMap.FTokenManager.PlayerReady(FSeatedPlayer)) and
    (FSeatedPlayer = FCurrentPlayer) and not FPlayers.GetPlayers(FCurrentCombatPlayer).FAuto and
    (AoWCombatMap.FSeatedCombatPlayer = AoWCombatMap.FCurrentCombatPlayer) then begin
    if FUnitSelection.GetTCUnitHS <> nil then FUnitSelection.UpdateMoveCursor;
    case Mouse.CursorMode of
      0: Mouse.Cursor := 0;
      $101: Mouse.Cursor := (Frame div 4) mod 4 + $34;
      $102: Mouse.Cursor := (Frame div 4) mod 2 + $31;
    end;
  end else Mouse.Cursor := (Frame div 4) mod 4 + 6;
end;

procedure TAoWCombatMap.EndCombat(A1: Integer);
var TE: TTerminateCombatTE;
begin
  TE := TTerminateCombatTE.Create(nil);
  AoWHSMap.FTokenManager.TokenExecuter.AddSystemEvent(TE);
  TE.Release;
end;

procedure TAoWCombatMap.SelectNextUnit(Forward: Boolean);
var
  U: TTacticalCombatUnit;
  X, Y: Integer;
begin
  if FSeatedCombatPlayer = FCurrentCombatPlayer then begin
    U := GetNextUnit(FPlayers.GetPlayers(FSeatedCombatPlayer).FLastUnit, False, Forward);
    if U <> nil then
      if FUnitSelection.GetTCUnitHS <> U.FUnitHS then begin
        FPlayers.GetPlayers(FSeatedCombatPlayer).FLastUnit := U;
        CenterViewTo(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, 0);
        Selection.UnselectLocation;
        HXtoHP(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, X, Y);
        Selection.SelectLocation(X, Y, 0);
      end;
  end;
end;

procedure TAoWCombatMap.DropHeroItem(Hero: THero; Item: TItem);
var
  X, Y, L: Shortint;
  HS: TItemHS;
  I: Integer;
begin
  X := -1;
  Y := -1;
  L := -1;
  I := FCombat.FCombatData.GetCount;
  while (I <> 0) and (X = -1) do begin
    Dec(I);
    if (FCombat.FCombatData.GetObjects(I) is TTacticalCombatUnit) and
      (TTacticalCombatUnit(FCombat.FCombatData.GetObjects(I)).FUnit = Hero) then begin
      X := TTacticalCombatUnit(FCombat.FCombatData.GetObjects(I)).FUnitHS.GetXhx;
      Y := TTacticalCombatUnit(FCombat.FCombatData.GetObjects(I)).FUnitHS.GetYhx;
      L := 0;
    end;
  end;
  if X > -1 then begin
    HS := TItemHS(MapContainer.GetField(X, Y, L).FindOwnedChild($20271));
    if HS = nil then begin
      HS := TCItemHS.Create(nil);
      { Original bug: a failed placement leaves the new item sprite allocated. }
      if AoWCombatMap.PlaceHX(HS, X, Y, L) then Item.SetOwner(HS.FItems);
    end else Item.SetOwner(HS.FItems);
  end;
end;

function TAoWCombatMap.GetHeroItemsOnGround(Hero: THero): TItemList;
var
  HS: TItemHS;
  X, Y, L: Shortint;
begin
  Result := nil;
  GetUnitLocation(Hero, X, Y, L);
  if X > -1 then begin
    HS := TItemHS(MapContainer.GetField(X, Y, L).FindOwnedChild($20271));
    if HS <> nil then Result := HS.FItems;
  end;
end;

procedure TAoWCombatMap.GetUnitLocation(U: TAbstractUnit; var X, Y, L: Shortint);
var I: Integer;
begin
  X := -1;
  I := 0;
  while I < FCombat.FCombatData.GetCount do
    if (TTacticalCombatUnit(FCombat.FCombatData.GetObjects(I)).FUnit = U) and
      FCombat.FCombatData.GetObjects(I).GetEnabled then begin
      X := TTacticalCombatUnit(FCombat.FCombatData.GetObjects(I)).FUnitHS.GetXhx;
      Y := TTacticalCombatUnit(FCombat.FCombatData.GetObjects(I)).FUnitHS.GetYhx;
      L := 0;
      I := FCombat.FCombatData.GetCount;
    end else Inc(I);
end;

procedure TAoWCombatMap.Surrender(Mode: Boolean);
var TE: TCEndCombatTE;
begin
  if AoWHSMap.FTokenManager.PlayerReady(AoWCombatMap.FCurrentPlayer) and
    (FCurrentCombatPlayer = FSeatedCombatPlayer) then begin
    FUnitSelection.Unselect;
    TE := CreateTCEndCombatTE;
    if TE <> nil then begin
      AoWHSMap.FTokenManager.GetTokenControl(FCurrentPlayer).AddEvent(TE);
      TE.Release;
    end;
  end;
end;

procedure TCItemHS.Deactivate;
begin end;

function TTacticalCombatUnit.GetPosValue: Integer;
begin
  Result := GetAttack + GetDamage + GetDefense + GetMoves div 3;
  if SupportCombatMode([cmMediumRange]) then Result := Result - 100;
  if SupportCombatMode([cmLongRange]) then Result := Result - 200;
end;

procedure TTacticalCombatUnit.NewTurn(A1: Byte);
begin
  inherited NewTurn(A1);
  if (A1 = Byte(FCombatPlayer)) and GetEnabled then FMovePoints := GetMoves;
end;

procedure TTacticalCombatUnit.MovedTo(OldField, NewField: TAoWMapField; MoveCost: Integer);
begin
  FMovePoints := FMovePoints - MoveCost;
  if FMovePoints < 0 then FMovePoints := 0;
  if GetAbilityEnabled($2B) then CreateFire(False, 50, FUnitHS.GetXhx, FUnitHS.GetYhx);
  AoWCombatMap.FMouseOverTargetEvents.TriggerNotifyEvents(FUnitHS);
end;

procedure TTacticalCombatUnit.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin inherited MsgProc(Msg, Sender); end;

function TTacticalCombatUnit.ExecuteDamage(A1: Integer): Integer;
begin Result := 0; end;

procedure TCombatMoveControl.ProcessMove(A1: TMoveControlSettings);
begin
  FUnitHS := TTacticalCombatUnitHS(A1.FArmyHS);
  FMoveFlags := TCombatMoveControlSettings(A1).FMoveFlags;
  inherited ProcessMove(A1);
end;

constructor TCombatUnitSelectionControl.Create;
begin
  inherited Create;
  FRangedPath := TXYZList.Create;
  FObstacles := TList.Create;
  FRangedPathHS := TRangedPathHS.Create(nil);
  FRangedPathHS.Activate;
  FTargetImages := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'TargHex.ILB');
end;

destructor TCombatUnitSelectionControl.Destroy;
var I: Integer;
begin
  for I := 0 to FObstacles.Count - 1 do TObject(FObstacles[I]).Free;
  FObstacles.Free;
  FRangedPath.Free;
  FRangedPathHS.Free;
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'TargHex.ILB');
  inherited Destroy;
end;

function TCombatUnitSelectionControl.CreateMCS: TMoveControlSettings;
begin Result := TCombatMoveControlSettings.Create(nil); end;

function TCombatUnitSelectionControl.AddUnit(U: TTacticalCombatUnitHS): Integer;
begin
  Result := AddMoveObject(U);
  FMoveSettingsList.GetMoveSettings(Result).FMovePoints := U.FUnit.FMovePoints;
  FMoveSettingsList.GetMoveSettings(Result).FMoves := U.FUnit.GetMoves;
end;

procedure TCombatUnitSelectionControl.SetCurrentMove(A1: Integer);
begin
  if (FCurrentMove <> -1) and (GetTCUnitHS <> nil) then
    AoWCombatMap.Selection.TriggerDeselectEvent(GetTCUnitHS);
  inherited SetCurrentMove(A1);
  if (FCurrentMove <> -1) and (GetTCUnitHS <> nil) then
    AoWCombatMap.Selection.TriggerSelectEvent(GetTCUnitHS);
end;

function TCombatUnitSelectionControl.GetTCUnitHS: TTacticalCombatUnitHS;
begin
  if FCurrentMove <> -1 then
    Result := TTacticalCombatUnitHS(FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject)
  else Result := nil;
end;

function TCombatUnitSelectionControl.GetMoveTypes: TMoveTypes;
begin
  if FCurrentMove <> -1 then
    Result := TTacticalCombatUnitHS(FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject).FUnit.FUnit.GetMoveTypes
  else Result := [];
end;

procedure TCombatUnitSelectionControl.RectangleSelectEvent(Sender: TObject);
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

function TCombatUnitSelectionControl.ValidMultiMoveSelection(Field: TAoWMapField): Boolean;
var Player: Shortint;
begin
  Player := Field.GetPlayer;
  Result := Player = -1;
end;

procedure TCombatUnitSelectionControl.MouseDownEvent(Sender: TObject);
begin end;

procedure TCombatUnitSelectionControl.UpdateMoveCursor;
begin end;

procedure TCombatUnitSelectionControl.ActivateMoveSelection;
begin
  if not (mssActivated in FStatus) then Activate(AoWCombatMap);
end;

procedure TCombatUnitSelectionControl.DeactivateMoveSelection;
begin
  if mssActivated in FStatus then begin
    Deactivate;
    FRangedPath.Clear;
    FMoveSettingsList.Clear;
    AoWCombatMap.MouseMoveEvent(Self);
  end;
end;

procedure TCombatUnitSelectionControl.ShowMovePaths(const Surface: TSurfaceDesc);
var
  I, X, Y, Xhp, Yhp: Integer;
begin
  inherited ShowMovePaths(Surface);
  if GetTCUnitHS <> nil then begin
    if (GetTCUnitHS.FSelectedAbility <> $41) and (GetTCUnitHS.FSelectedAbility <> $72) then Exit;
    if (FMoveSettingsList.GetCount = 1) and
      (FMoveSettingsList.GetMoveSettings(0).FPath.Count > 1) then
      for I := 1 to 6 do begin
        CenterHNtoHX(FMoveSettingsList.GetMoveSettings(0).FPath[1].X,
          FMoveSettingsList.GetMoveSettings(0).FPath[1].Y, I, X, Y);
        HXtoHP(X, Y, Xhp, Yhp);
        FTargetImages[0].Show(Xhp - AoWCombatMap.ViewXhp - 8,
          Yhp - AoWCombatMap.ViewYhp + 2, Surface);
      end;
  end;
end;

procedure TCombatUnitSelectionControl.Update;
begin
  if GetTCUnitHS <> nil then
    GetTCUnitHS.FUnit.FUnit.CreateMovePointTable(FMoveControlSettings.FMovePointTable);
  FPathInvalid := [piRanged];
end;

procedure TCombatUnitSelectionControl.SetTCUnitHS(U: TTacticalCombatUnitHS);
begin
  if GetTCUnitHS <> U then
    if FMoveSettingsList.GetCount <= 1 then begin
      Clear;
      if (U <> nil) and (U.FUnit.GetPlayer = AoWCombatMap.FSeatedPlayer) then begin
        ActivateMoveSelection;
        AddUnit(U);
        SetCurrentMove(0);
        Update;
      end else DeactivateMoveSelection;
      FRangedPath.Clear;
      UpdateMoveCursor;
    end;
end;

procedure TCombatUnitSelectionControl.Unselect;
begin
  DeactivateRangedPath;
  if GetTCUnitHS <> nil then GetTCUnitHS.FSelectedAbility := -1;
  AoWCombatMap.Selection.UnselectLocation;
  DeactivateMoveSelection;
  inherited Unselect;
end;

procedure TCombatUnitSelectionControl.Select(U: TTacticalCombatUnitHS);
begin
  AoWCombatMap.Selection.UnselectLocation;
  if U <> nil then AoWCombatMap.Selection.SelectLocationHS(U);
end;

procedure TCombatUnitSelectionControl.DeactivateRangedPath;
begin
  if FRangedPathHS.FPath <> nil then begin
    AoWCombatMap.DynamicFixedVisibleHS.RemoveChild(FRangedPathHS);
    FRangedPathHS.FPath := nil;
  end;
end;

procedure TTacticalCombatUnitHS.Deactivate;
var I: Integer;
begin
  if AoWCombatMap <> nil then AoWCombatMap.NewFrameEvents.Remove(NewFrame);
  for I := 0 to FAbilities.Count - 1 do TObject(FAbilities[I]).Free;
  FAbilities.Free;
  inherited Deactivate;
end;

class function TTacticalCombatUnitHS.ClassID: Integer;
begin Result := $220104; end;

procedure TTacticalCombatUnitHS.Initialize(U: TTacticalCombatUnit);
begin
  FUnit := U;
  FUnit.FUnitHS := Self;
end;

function TTacticalCombatUnitHS.GetMoveSteps: Integer;
begin
  case AoWEngine.FRegistry.GetMovementSpeed of
    mmsFast:
      begin
        Result := inherited GetMoveSteps;
        if Result > 8 then Result := Result - 4 else Result := 4;
      end;
    mmsTurbo: Result := 2;
  else Result := inherited GetMoveSteps;
  end;
end;

procedure TTacticalCombatUnitHS.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

procedure TTacticalCombatUnitHS.UpdateMapField(const Info: THSMapFieldInfo);
begin
  if Info.HN = 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $4000 or $2000 or $2000000
  else if Info.HN <= 6 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $4000;
end;

procedure TTacticalCombatUnitHS.Activate;
begin
  inherited Activate;
  SetUnitGFXResourceIndex(FUnit.FUnit.GetUnitGFXResourceIndex);
  FAbilities := TList.Create;
  CreateTCAbList;
  AoWCombatMap.NewFrameEvents.Add(NewFrame);
  if AoWCombatMap.FExplorationEnabled then
    AoWCombatMap.ExploreArea(GetXhx, GetYhx, 0, FUnit.GetPlayer, FUnit.GetVisibilityRange);
  FActionFrame := $FFFF;
  FSelectedAbility := -1;
  FSelectedSpell := -1;
end;

procedure TTacticalCombatUnitHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TTacticalCombatUnitHS.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID <> $20010017) and (Msg.MsgID and $40000000 = 0) and (FUnit <> nil) then
    FUnit.MsgProc(Msg, Sender);
end;

procedure TTacticalCombatUnitHS.NewFrame(Sender: TObject);
begin end;

procedure TTacticalCombatUnitHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TTacticalCombatUnitHS.Select;
begin
  inherited Select;
  CreateTCAbList;
  FSelectedAbility := -1;
  if AoWCombatMap.FUnitSelection.GetTCUnitHS <> Self then
    AoWCombatMap.FUnitSelection.SetTCUnitHS(Self);
  FUnitGFXResource.FSFXLibraries[0].Play(0);
  if AoWCombatMap.FSeatedCombatPlayer = FUnit.FCombatPlayer then
    AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FSeatedCombatPlayer).FLastUnit := FUnit;
end;

procedure TTacticalCombatUnitHS.Unselect;
begin
  inherited Unselect;
  if AoWCombatMap <> nil then
    if AoWCombatMap.FUnitSelection.GetTCUnitHS = Self then
      AoWCombatMap.FUnitSelection.Unselect;
end;

function TTacticalCombatUnitHS.MeleeMoveTC(Path: TMovepath): Boolean;
var TE: TCMeleeMoveTE;
begin
  Result := False;
  if AoWHSMap.FTokenManager.PlayerReady(FUnit.GetPlayer) and (Path.Count > 1) then begin
    TE := CreateTCMeleeMoveTE(FUnit, Path);
    if TE <> nil then begin
      AoWHSMap.FTokenManager.GetTokenControl(FUnit.GetPlayer).AddEvent(TE);
      TE.Release;
      Result := True;
    end;
  end;
end;

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

procedure TTacticalCombatUnitHS.SetAction(Action: TTCAction);
begin
  FActionDone := False;
  case Action of
    caStepUp, caStepBack: FActionFrame := 0;
    caRoundAttack, caRoundAttackHit:
      if (FAction <> caRoundAttack) and (FAction <> caRoundAttackHit) then FActionFrame := $FFFF;
  else FActionFrame := $FFFF;
  end;
  FAction := Action;
end;

function TTacticalCombatUnitHS.AbTouchMoveTC(A1: Integer): Byte;
begin Result := 0; end;

function TTacticalCombatUnitHS.AbRangedTC(X, Y: Word): Boolean;
var TE: TCAbRangedTE;
begin
  Result := False;
  if AoWHSMap.FTokenManager.PlayerReady(FUnit.GetPlayer) then begin
    TE := CreateTCAbRangedTE(FUnit, X, Y, FSelectedAbility, FSelectedSpell);
    if TE <> nil then begin
      AoWHSMap.FTokenManager.GetTokenControl(FUnit.GetPlayer).AddEvent(TE);
      TE.Release;
      Result := True;
    end;
  end;
end;

procedure TCCorpseHS.Deactivate;
begin
  AoWCombatMap.NewFrameEvents.Remove(NewFrame);
  FUnitGFX.Release;
  inherited Deactivate;
end;

class function TCCorpseHS.ClassID: Integer;
begin
  Result := $220108;
end;

procedure TCCorpseHS.NewFrame(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := AoWHSSet.FImageSequences.ImageSequences[FSequenceIndex];
  if FSequenceFrame + 1 < Sequence.GetTotalSequenceFrames then Inc(FSequenceFrame);
end;

procedure TCCorpseHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var Frame, X, Y: Integer; Sequence: TImageSequence;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
  XhpSurf := X - XhpSurf - 15;
  YhpSurf := Y - YhpSurf - 25;
  if FSequenceIndex > -1 then begin
    Sequence := AoWHSSet.FImageSequences.ImageSequences[FSequenceIndex];
    while Sequence <> nil do begin
      Frame := Sequence.GetUnloopedFrameIndex(FSequenceFrame);
      if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf + FOffsetX - 5, YhpSurf + FOffsetY + 10, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
  end;
  Sequence := FUnitGFX.FSequences.ImageSequences[30];
  while Sequence <> nil do begin
    Frame := Sequence.GetUnloopedFrameIndex(FFrame);
    if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf + FOffsetX, YhpSurf + FOffsetY, SurfaceDesc);
    Sequence := Sequence.Next;
  end;
end;

function TCCorpseHS.GetLevel: Byte;
begin
  Result := 26;
end;

function TCCorpseHS.GetShowPriority: Integer;
begin
  Result := $68000000 + (FOffsetY shl 13) + FOffsetX;
end;

procedure TCCorpseHS.Activate;
begin
  inherited Activate;
  if FSequenceIndex > -1 then AoWCombatMap.NewFrameEvents.Add(NewFrame);
  FUnitGFX.AddRef;
  FSequenceFrame := -1;
end;

procedure TCCorpseHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

class function TCOozeHS.ClassID: Integer;
begin
  Result := $220109;
end;

function TCOozeHS.GetOverlay(HN: Integer): Shortint;
begin
  Result := 11;
end;

procedure TCOozeHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var Frame, X, Y: Integer; Sequence: TImageSequence;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
  XhpSurf := X - XhpSurf - 16;
  YhpSurf := Y - 48 - YhpSurf;
  case TMapField(Owner).TerrainType of
    3, 6, 13: Sequence := AoWHSSet.FImageSequences.ImageSequences[26];
    12: Sequence := AoWHSSet.FImageSequences.ImageSequences[27];
  else
    Sequence := AoWHSSet.FImageSequences.ImageSequences[25];
  end;
  while Sequence <> nil do begin
    Frame := Sequence.GetUnloopedFrameIndex(Integer(Self) mod Sequence.GetTotalSequenceFrames);
    if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf, YhpSurf, SurfaceDesc);
    Sequence := Sequence.Next;
  end;
end;

function TCOozeHS.GetLevel: Byte;
begin
  Result := 26;
end;

function TCOozeHS.GetShowPriority: Integer;
begin
  Result := $68000000 + (GetYhx shl 13) + GetXhx;
end;

function TCOozeHS.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  TMapField(Owner).UpdateTerrain;
end;

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
begin
  inherited Create(AOwner);
  FPositions := TXYLList.Create;
  FPositions.Default := PackXYL(-1, -1, -1);
end;

destructor TUnitPositionControl.Destroy;
begin
  FPositions.Free;
  FPositions := nil;
  inherited Destroy;
end;

function TUnitPositionControl.GetUnitPosition(Position, Index: Integer): TXYL;
var I: Integer;
begin
  I := Position * 8 + Index;
  if I < FPositions.Count then
    Result := FPositions[I]
  else begin
    Result.X := -1;
    Result.Y := -1;
    Result.L := -1;
  end;
end;

procedure TUnitPositionControl.SetUnitPosition(Position, Index: Integer; Value: TXYL);
begin
  if (Position < 7) and (Index < 8) then
    FPositions[Position * 8 + Index] := Value;
end;

function TUnitPositionControl.ValidatePosition(var Position, Index: Shortint): Boolean;
begin
  Result := FPositions[Position * 8 + Index].X = -1;
  if not Result then begin
    Index := 0;
    while (FPositions[Position * 8 + Index].X <> -1) and (Index <> 8) do Inc(Index);
    Result := Index <> 8;
  end;
  if Result = False then begin
    Position := 0;
    while (Result = False) and (Position < 7) do begin
      while (FPositions[Position * 8 + Index].X <> -1) and (Index <> 8) do Inc(Index);
      Result := Index <> 8;
      if not Result then begin
        Index := 0;
        Inc(Position);
      end;
    end;
  end;
end;

procedure TUnitPositionControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
var HS: TUnitPositionHS; X, Y, L: Integer;
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10005 then begin
    L := Msg.Data[1];
    HPtoHX(Msg.Value, Msg.Data[0], X, Y);
    if AoWCombatMap.MapContainer.GetField(X, Y, L).TerrainType <> 15 then begin
      HS := TUnitPositionHS(AoWCombatMap.MapContainer.GetField(X, Y, L).FindOwnedChild($220103));
      if HS = nil then begin
        HS := TUnitPositionHS.Create(nil);
        if not AoWCombatMap.PlaceHX(HS, X, Y, L) then begin HS.Free; HS := nil; end;
      end;
      if HS <> nil then;
    end;
  end;
end;

constructor TUnitPositionHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPosition := 0;
  FIndex := 0;
  FDirection := 1;
end;

class function TUnitPositionHS.ClassID: Integer;
begin
  Result := $220103;
end;

function TUnitPositionHS.GetLevel: Byte;
begin
  Result := 27;
end;

procedure TUnitPositionHS.UpdateImageIndex;
begin
  FImageIndex := FPosition * 8 + FIndex;
end;

procedure TUnitPositionHS.Activate;
var P: TXYL;
begin
  inherited Activate;
  if (msEditting in AoWCombatMap.Status) and AoWCombatMap.FUnitPositions.ValidatePosition(FPosition, FIndex) then begin
    AoWCombatMap.FUnitPositions.SetUnitPosition(FPosition, FIndex, PackXYL(GetXhx, GetYhx, 0));
    FImages := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'TCUNITS.ILB');
    UpdateImageIndex;
  end else begin
    P.X := GetXhx;
    P.Y := GetYhx;
    P.L := 0;
    P.Flag := FDirection;
    AoWCombatMap.FUnitPositions.SetUnitPosition(FPosition, FIndex, P);
    Destroy;
  end;
end;

procedure TUnitPositionHS.Deactivate;
begin
  if Activated and (msEditting in TMapLevel(TMapField(Owner).Owner).Map.Status) then begin
    AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'TCUNITS.ILB');
    if (AoWCombatMap.FUnitPositions.GetUnitPosition(FPosition, FIndex).X = GetXhx) and
       (AoWCombatMap.FUnitPositions.GetUnitPosition(FPosition, FIndex).Y = GetYhx) then
      AoWCombatMap.FUnitPositions.SetUnitPosition(FPosition, FIndex, PackXYL(-1, -1, -1));
  end;
  inherited Deactivate;
end;

procedure TUnitPositionHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPosition), $19);
  Stream.rwByte(Byte(FIndex), $1A);
  Stream.rwByte(FDirection, $1B);
end;

function TUnitPositionHS.CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Result := (Map.GetField(Xhx, Yhx, Lhx).FindOwnedChild($220103) = nil) and
    AoWCombatMap.FUnitPositions.ValidatePosition(FPosition, FIndex);
end;

procedure TUnitPositionHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var X, Y: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
  FImages[FImageIndex].ShowClipped(X - XhpSurf - 8, Y - YhpSurf - 8, SurfaceDesc);
end;

class function TTacticalCombat.ClassID: Integer;
begin
  Result := $220110;
end;

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
begin
  inherited Create(AOwner);
  FPath := TXYZList.Create;
  FFrame := -1;
end;

destructor TfxHS.Destroy;
begin
  FPath.Free;
  inherited Destroy;
end;

class function TfxHS.ClassID: Integer;
begin
  Result := $220106;
end;

procedure TfxHS.Activate;
begin end;

function TfxHS.GetShowPriority: Integer;
begin
  Result := $6C000000;
end;

procedure TfxHS.NewFrame(A1: Integer);
begin end;

procedure TfxHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCBloodHS.Deactivate;
begin
  inherited Deactivate;
end;

class function TCBloodHS.ClassID: Integer;
begin
  Result := $220107;
end;

function TCBloodHS.GetLevel: Byte;
begin
  Result := 26;
end;

function TCBloodHS.GetShowPriority: Integer;
begin
  Result := $68000000 + (FOffsetY shl 13) + FOffsetX;
end;

procedure TCBloodHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var Frame: Integer; Sequence: TImageSequence; X, Y: Integer;
begin
  Sequence := AoWHSSet.FImageSequences.ImageSequences[4];
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
  if Sequence <> nil then begin
    Frame := Sequence.GetUnloopedFrameIndex(FFrame);
    Sequence.ImageLibrary[Frame].ShowClipped(X - XhpSurf + FOffsetX, Y - YhpSurf + FOffsetY, SurfaceDesc);
  end;
end;

procedure TCBloodHS.Activate;
begin
  inherited Activate;
end;

procedure TTacticalCombatPlayer.SetAuto(Value: Boolean);
begin
  FAuto := Value;
  if (AoWCombatMap.FSeatedCombatPlayer = FIndex) and
     (AoWCombatMap.FSeatedCombatPlayer = AoWCombatMap.FCurrentCombatPlayer) then AoWCombatMap.FAI.Reset;
end;

function TTacticalCombatPlayerList.GetCount: Integer;
begin
  if FPlayers <> nil then Result := FPlayers.GetCount else Result := 0;
end;

function TTacticalCombatPlayerList.GetPlayers(Index: Shortint): TTacticalCombatPlayer;
begin
  Result := TTacticalCombatPlayer(FPlayers.GetPlayers(Index));
end;

procedure MakeAbilPath(Side: TCombatSideIndex; Ability, Spell: Smallint;
  X1, Y1, X2, Y2: Smallint; var Path: TXYZList; var Obstacles: TList);
begin end;

procedure MakeRangedPath(Side: TCombatSideIndex; Height, Step, Arc: Smallint;
  X1, Y1, X2, Y2: Smallint; Ignore: TMapObject; Mode: Boolean;
  Z: Smallint; var Path: TXYZList; var Obstacles: TList);
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
