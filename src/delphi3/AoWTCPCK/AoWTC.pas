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
    Ability, Spell: Integer; { $04, $08 }
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
    $04 MoveType; $06 Ability; $08 Spell; $0C Value; $10 GroupValue;
    $14 UnitHS; $18 Target; $1C X; $1E Y. }
  TaiMove = class(TObject)
  public
    MoveType: TaiMoveType; { $04 }
    F_aiMove_05: Byte;
    Ability: Smallint; { $06 }
    Spell: Smallint; { $08 }
    F_aiMove_0A: array[0..1] of Byte;
    Value: Integer; { $0C }
    GroupValue: Integer; { $10 }
    UnitHS: TTacticalCombatUnitHS; { $14 }
    Target: TCombatObject; { $18 }
    X: Word; { $1C }
    Y: Word; { $1E }
  end;

  { TCAI (instance size 56, VMT 00411C28)
    $04 FSide; $08 Units; $0C Allies; $10 Enemies; $14 Moves; $18 Walls;
    $1C CurrentMove; $20 FUnitIndex; $24 FUnitLimit; $28 FMinMoves; $2C FHeroMoves; $30 FNormalUnits; $34 FIgnoreWalls; $35 FFlee; $36 Status. }
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
    FUnitIndex: Integer; { $20 }
    FUnitLimit: Integer; { $24 }
    FMinMoves: Integer; { $28 }
    FHeroMoves: Integer; { $2C }
    FNormalUnits: Integer; { $30 }
    FIgnoreWalls: Boolean; { $34 }
    FFlee: Boolean; { $35 }
    Status: TaiStatus; { $36 }
    F_CAI_37: array[0..0] of Byte;
    destructor Destroy; override;
    constructor Create;
    procedure Reset;
    procedure BeginTurn;
    procedure ContinueTurn;
    procedure CreateMove(MoveType: TaiMoveType; X, Y, Value, Ability, Spell: Integer; U: TTacticalCombatUnit; Target: TCombatObject);
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
    procedure CheckUnit(X, Y, HitPoints, Hits: Integer; Settings: TCombatMoveControlSettings; U: TTacticalCombatUnit; Target: TCombatObject; Abilities: TList; Wall: TObject);
    procedure EvalBattle;
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

  { TRangedPathHS (instance size 32, VMT 00411EA8): $0C FMiscImages; $10 FTargetImages; $14 FFrame; $16 FFrameCount; $18 FSelection; $1C FRange. }
  TRangedPathHS = class(TFixedVisibleHS)
  public
    FMiscImages: TCustomImageLibrary; { $0C }
    FTargetImages: TCustomImageLibrary; { $10 }
    FFrame: Word;
    FFrameCount: Word;
    FSelection: TCombatUnitSelectionControl; { $18 }
    FRange: Word;
    F_RangedPathHS_1E: array[0..1] of Byte;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
  end;

  { TfxHS (instance size 56, VMT 00412028)
    $0C FDone; $0D FCancelled; $10 FFrame; $14 FAbilityIndex; $18 FSpellIndex;
    $1C FPath; $20 FVariant; $24 FTargetX; $28 FTargetY; $2C FTarget; $34 FEffectType. }
  TfxHS = class(TFixedVisibleHS)
  public
    FDone: Boolean; { $0C }
    FCancelled: Boolean; { $0D }
    { conflict: FHit: Boolean; }
    F_fxHS_0E: array[0..1] of Byte;
    FFrame: Integer; { $10 }
    FAbilityIndex: Integer; { $14 }
    { conflict: FAbilityID: Integer; }
    FSpellIndex: Integer; { $18 }
    { conflict: FSpellID: Integer; }
    FPath: TXYZList; { $1C }
    FVariant: Integer; { $20 }
    { conflict: FDirection: Integer; }
    FTargetX: Integer; { $24 }
    FTargetY: Integer; { $28 }
    FTarget: TCombatObject; { $2C }
    { conflict: FTarget: TTacticalCombatUnit; }
    FCombatAction: TCombatAction; { $30; $40c44b }
    FEffectType: TfxType; { $34 }
    F_fxHS_35: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewFrame(Sender: TObject);
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
    $5C FMovePoints; $60 FUnitHS; $64 FPositionIndex; $65 FPositionGroup; $66 FCanFlee; $67 FDeathMethod. }
  TTacticalCombatUnit = class(TCombatUnit)
  public
    FMovePoints: Integer; { $5C }
    FUnitHS: TTacticalCombatUnitHS; { $60 }
    FPositionIndex: Byte; { $64 }
    FPositionGroup: Byte; { $65 }
    FCanFlee: Boolean; { $66 }
    FDeathMethod: TTCDeathMethod; { $67 }
    { conflict: FUsedAbility: Boolean; }
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure NewTurn(A1: Byte); override;
    function ExecuteDamage(A1: Integer): Integer; override;
    function GetPosValue: Integer;
    procedure MovedTo(OldField, NewField: TAoWMapField; MoveCost: Integer);
  end;

  { TTacticalCombatUnitHS (instance size 72, VMT 00412D08): $1C FUnit;
    $20 FMoveIndicator; $22 FIndicatorStep; $24 FAction; $25 FActionDone; $26 FActionFrame; $2C FOffsetX; $30 FOffsetY; $34 FSelectedAbility;
    $38 FSelectedSpell; $3C FCombatAbilityCount; $40 FAbilities; $44 FBusy. }
  TTacticalCombatUnitHS = class(TUnitHS)
  public
    FUnit: TTacticalCombatUnit; { $1C }
    { conflict: FCombatUnit: TTacticalCombatUnit; }
    FMoveIndicator: Smallint; { $20 }
    FIndicatorStep: Smallint; { $22 }
    FAction: TTCAction; { $24 }
    FActionDone: Boolean; { $25 }
    FActionFrame: Smallint; { $26 }
    F_TacticalCombatUnitHS_28: array[0..3] of Byte;
    FOffsetX: Integer; { $2C }
    FOffsetY: Integer; { $30 }
    FSelectedAbility: Integer; { $34 }
    FSelectedSpell: Integer; { $38 }
    FCombatAbilityCount: Integer; { $3C }
    FAbilities: TList; { $40 }
    FBusy: Boolean; { $44 }
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
    function SelectAbility(A1: Integer): Integer;
    function SelectSpell(A1: Integer): Integer;
    procedure CreateTCAbList;
    procedure ListAbilities(Names, Types, Sources: TStrings);
    procedure SetAction(Action: TTCAction);
    function AbTouchMoveTC(Path: TMovepath): Boolean;
    function AbRangedTC(X, Y: Word): Boolean;
  end;

  { TCombatUnitSelectionControl (instance size 60, VMT 00412EB4): $18 FPathInvalid;
    $1C FTargetImages; $20 FRangedPathHS; $24 FTargetX; $28 FTargetY; $2C FCursorImage; $2E FCursorFrame; $34 FRangedPath; $38 FObstacles. }
  TCombatUnitSelectionControl = class(TMoveSelector)
  public
    FPathInvalid: set of (piMove, piRanged); { $18 }
    F_CombatUnitSelectionControl_19: array[0..2] of Byte;
    FTargetImages: TCustomImageLibrary; { $1C }
    FRangedPathHS: TRangedPathHS; { $20 }
    FTargetX: Integer; { $24 }
    FTargetY: Integer; { $28 }
    FCursorImage: Word;
    FCursorFrame: Word;
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
    procedure MoveSelectionEvent(Sender: TObject);
    procedure CalculateRangedPath(X, Y: Shortint);
    procedure MoveSelectedRoute;
    procedure MoveUnits;
    procedure ExecuteMoveSelection;
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
    FCenterViewLocation: TMapObject; { $10C; $435a3e }
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
    procedure EndCombat(Sender: TObject);
    procedure SelectNextUnit(Forward: Boolean);
    procedure GetUnitLocation(U: TAbstractUnit; var X, Y, L: Shortint);
    procedure Surrender(Mode: Boolean);
  end;

  { TTacticalCombat (instance size 80, VMT 00413314)
    Inherited combat layout; $4C FHostPlayer. }
  TTacticalCombat = class(TCombat)
  public
    FHostPlayer: Shortint; { $4C }
    F_TacticalCombat_4D: array[0..2] of Byte;
    class function ClassID: Integer; override;
    function CreateCombatUnit: AoWE.TCombatUnit; override;
    function CreateCombatPlayer: TCombatPlayer; override;
    function Execute: Byte; override;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Deactivate; override;
    function ValidateWallCombat: Boolean;
  end;

  { TRndTacHsm (instance size 3708, VMT 0041340C)
    $04 FItems; $08 FRandomTerrain; $0C neighbor weights; $5C terrain weights;
    $520 terrain-tag weights; $9F0 terrain samples; $9F7 tag samples; $A00 resource lists; $E78 FHomePosition. }
  TRndTacHsm = class(TObject)
  public
    FItems: TECustomNode; { $04 }
    FRandomTerrain: Boolean; { $08 }
    F_RndTacHsm_09: array[0..2] of Byte;
    FNeighborWeights: array[0..19] of Integer; { $0C }
    FTerrainWeights: array[0..304] of Integer; { $5C }
    FTagWeights: array[0..307] of Integer; { $520 }
    FTerrain: array[0..6] of Shortint; { $9F0 }
    FTags: array[0..6] of Shortint; { $9F7 }
    F_RndTacHsm_9FE: array[0..1] of Byte;
    FResources: array[0..285] of TList; { $A00; original allocates one extra list }
    FHomePosition: Integer; { $E78 }
    destructor Destroy; override;
    constructor Create;
    function RandomMap(Combat: TTacticalCombat; X, Y, L: Integer): TAoWCombatMap;
    procedure PlaceCombatUnits;
    procedure SetupUnit(Side: TCombatSideIndex; Index: Integer; var Direction: Integer);
    procedure InitTables;
  end;

procedure MakeAbilPath(Side: TCombatSideIndex; Ability, Spell: Smallint;
  X1, Y1, X2, Y2: Smallint; var Path: TXYZList; var Obstacles: TList);
procedure MakeRangedPath(Side: TCombatSideIndex; Speed, Arc, UnusedHeight: Smallint;
  X1, Y1, X2, Y2, OffsetX, OffsetY: Smallint; IncludeUnits: Boolean;
  var Path: TXYZList; var Obstacles: TList);
{ conflict: procedure MakeRangedPath(Side: TCombatSideIndex; Height, Step, Arc: Smallint; X1, Y1, X2, Y2: Smallint; Ignore: TMapObject; Mode: Boolean; Z: Smallint; var Path: TXYZList; var Obstacles: TList); }
{ conflict: procedure MakeRangedPath(Side: TCombatSideIndex; Height, Step, Arc: Smallint; X1, Y1, X2, Y2: Smallint; OffsetX, OffsetY: Smallint; Mode: Boolean; var Path: TXYZList; var Obstacles: TList); }
procedure RegisterAoWTCClasses(AEngine: TEngine);
function GetMeleeDirIndex(A1: Integer; A2: Integer; A3: Integer): Word;
function GetRangedDirIndex(A1: Integer; A2: Integer): Word;
{ conflict: function GetRangedDirIndex(A1: Integer; A2: Integer): Integer; }

var
  AoWCombatMap: TAoWCombatMap;
  CombatXLoc, CombatYLoc, CombatLLoc: Integer; { $46C058..$46C064 }
  TCAttack, TCDamage: array[0..1] of Integer;
  { conflict: const TCAttack: array[0..1] of Integer = (6, 10); }
  { conflict: const TCDamage: array[0..1] of Integer = (6, 1); }
const
  raDir: array[0..17] of Integer = (0,0,0,1,0,2,3,4,5,6,0,0,0,0,0,0,0,0);
  { conflict: raDir: array[0..16] of Integer = (0, 0, 0, 1, 0, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0); }
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
  StatusAbilities: array[0..13] of Integer = (149, 150, 48, 92, 93, 94, 95, 96, 97, 98, 107, 163, 127, 34);
  WallISIndex: array[0..1] of Integer = (30, 0);
  rndHex: array[0..18] of Integer = (6, 0, 1, 3, 4, 5, 2, 18, 12, 7, 11, 10, 17, 15, 9, 16, 13, 8, 14);
  BreathHit: array[0..11] of Integer = (0, 1, 4, 7, 8, 2, 5, 9, 10, 3, 6, 11);
  WallMaxHP: array[0..1] of Integer = (7, 13);

resourcestring
  IndRStr = 'Independents';
  BeginRoundRStr = 'begin their round.';

implementation

uses CityWall, CombatTE, CombatFire, AoWReg, CombatTerrain, HxBridge, City, FleeLoc;
type
  PCombatMapBytes = ^TCombatMapBytes;
  TCombatMapBytes = array[0..3769] of Byte;
const
  DefPosX: array[0..47] of Integer = (32,30,34,32,28,36,30,34,34,36,32,38,30,36,32,34,36,34,38,32,36,30,34,32,32,34,30,32,36,28,34,30,30,28,32,26,34,28,32,30,28,30,26,32,28,34,30,32);
  DefPosY: array[0..47] of Integer = (26,27,27,28,28,28,29,29,27,28,26,29,27,30,28,29,30,31,29,32,28,31,29,30,32,31,31,30,30,30,29,29,31,30,32,29,31,28,30,29,28,27,29,26,30,27,29,28);
  MapShape: TCombatMapBytes = (
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 11, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 10, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 11, 11, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 11, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 11, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 10, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 11, 11, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 11, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 11, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 10, 10, 2, 14, 2, 14, 2, 14, 2, 14, 2, 11, 11, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 19, 14, 1, 14, 1, 14, 1, 14, 1, 14, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 19, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 19, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 19, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 19, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 19, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 19, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 15, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 8, 8, 8, 8, 19, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 15, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 18, 18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 16, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 18, 18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 16, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 18, 18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 16, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 18, 18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 16, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 18, 18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 16, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 18, 18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 16, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 18, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 17, 16, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 12, 5, 17, 17, 17, 17, 17, 17, 17, 17, 17, 5, 13, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 12, 12, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 13, 13, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 12, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 13, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 12, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 13, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 12, 12, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 13, 13, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 12, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 13, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 12, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 13, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 12, 12, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 13, 13, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  MapRoads: TCombatMapBytes = (
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 26, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 22, 22, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 26, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 22, 22, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 7, 26, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 22, 22, 3, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 7, 26, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 22, 22, 3, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 7, 26, 26, 0, 0, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 0, 0, 22, 22, 3, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 7, 26, 26, 0, 0, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 0, 0, 22, 22, 3, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 7, 26, 26, 0, 0, 0, 0, 21, 2, 2, 2, 21, 0, 0, 0, 0, 22, 22, 3, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 7, 26, 26, 0, 0, 21, 2, 2, 2, 21, 0, 0, 22, 22, 3, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 7, 26, 26, 21, 2, 2, 2, 21, 22, 22, 3, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 7, 21, 2, 2, 2, 21, 3, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 7, 7, 7, 1, 1, 1, 3, 3, 3, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 7, 7, 1, 1, 1, 1, 1, 3, 3, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 1, 1, 1, 1, 1, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 1, 1, 1, 1, 1, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 6, 6, 6, 5, 1, 5, 4, 4, 4, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 6, 6, 6, 25, 24, 5, 5, 5, 24, 23, 4, 4, 4, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 6, 6, 6, 25, 25, 0, 24, 5, 5, 5, 24, 0, 23, 23, 4, 4, 4, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 6, 6, 6, 25, 25, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 23, 23, 4, 4, 4, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 6, 6, 6, 25, 25, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 23, 23, 4, 4, 4, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 6, 6, 6, 25, 25, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 23, 23, 4, 4, 4, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 6, 6, 6, 25, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 4, 4, 4, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 6, 6, 6, 6, 6, 6, 25, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 4, 4, 4, 4, 4, 4, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 25, 6, 6, 6, 6, 6, 6, 25, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 4, 4, 4, 4, 4, 4, 23, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 25, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 25, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 5, 5, 5, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  ClusterCheck: array[0..17] of Integer = (1, 2, 6, 16, 7, 8, 9, 17, 18, 19, 20, 21, 22, 23, 33, 34, 35, 36);

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

procedure TCAI.CreateMove(MoveType: TaiMoveType; X, Y, Value, Ability, Spell: Integer; U: TTacticalCombatUnit; Target: TCombatObject);
var M: TaiMove;
begin
  M := TaiMove.Create;
  M.UnitHS := U.FUnitHS;
  M.Target := Target;
  M.MoveType := MoveType;
  M.Ability := Ability;
  M.Spell := Spell;
  M.X := X;
  M.Y := Y;
  M.Value := Value;
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
          if AoWCombatMap.FCombat.FCombatData.FWallType <> 0 then begin
            Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].
              Field[Path[I].X, Path[I].Y].FindOwnedChild($220504));
            if Wall = nil then
              Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].
                Field[Path[I].X, Path[I].Y].FindOwnedChild($220506));
          end else Wall := nil;
          Path.List[I].Flag := MCS.FMovePointTable[AoWCombatMap.MapContainer.MapLevels[0].
            Field[Path[I].X, Path[I].Y].TerrainType * 2,
            AoWCombatMap.MapContainer.MapLevels[0].Field[Path[I].X, Path[I].Y].OverlayType];
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
          MakeRangedPath(U.GetSide, 50, 20, 50, X1, Y1, X2, Y2, 0, 0, False, Path, Obstacles)
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

procedure TCAI.CheckUnit(X, Y, HitPoints, Hits: Integer; Settings: TCombatMoveControlSettings; U: TTacticalCombatUnit; Target: TCombatObject; Abilities: TList; Wall: TObject);
var
  SafeValue, I, V, Distance, AbilityIndex, Range, Cost, BestIndex, BestValue, D: Integer;
  NX, NY, OriginalX, OriginalY, AX, AY: Integer;
  PathCost, TerrainValue, PathValue, Ability, Spell, Value: Integer;
  Path, DetourPath, BasePath: TXYLList;
  Round: TMeleeRound;
  AbilityInfo: TAbilityCombatInfo;
  SpellInfo: TSpellCombatInfo;
  CityWall: TCityWall;
  Adjacent: Boolean;
  Values: TAbilityDamageValues;
begin
  Path := TMovepath.Create;
  BasePath := TMovepath.Create;
  DetourPath := TMovepath.Create;
  TerrainValue := 0;
  OriginalX := X;
  OriginalY := Y;
  Distance := dHXtoRad(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, X, Y);
  if U.FMovePoints > 0 then begin
    AoWCombatMap.FMoveControl.CalculatePath(Settings, TMovepath(BasePath), X, Y, 0);
    PathCost := MakeTerrainPath(Settings, BasePath, TerrainValue, U, TTacticalCombatUnit(Target),
      True, (Target is TTacticalCombatUnit) and (FSide = csAttacker), 1);
    for I := 0 to BasePath.Count - 1 do Path.Add(BasePath[I]);
  end else PathCost := Distance * 4;
  if PathCost <> -1 then begin
    try
      if (Target is TCombatUnit) and (Target.GetSide <> U.GetSide) and (MeleeDamageTypes(U) <> []) and
        (U.GetAbilityEnabled(1) or not Target.GetAbilityEnabled(1)) then begin
        Ability := 0;
        Spell := 0;
        Round := TMeleeRound.Create;
        Round.Calculate(U, Target);
        if Round.GetAttackerDV > 0 then begin
          Adjacent := TMovepath(Path).MovePointsToPos(U.FMovePoints) = 0;
          U.FCanFlee := False;
          if Target is TCombatWall then FFlee := False;
          Value := MultDEV(tcDVtoDEV(Round.GetAttackerDV, Round.GetDefenderDV, Target, U), HitPoints, Hits) + TerrainValue;
          if (Target.GetTargetStrength < 1) and (Enemies.Count > 1) then Dec(Value, 10000);
          Cost := (PathCost - U.FMovePoints) * 10;
          if Cost < 1 then Cost := 1;
          if U.FUnit is THero then begin
            I := -1;
            BestIndex := TMovepath(Path).MovePointsToPos(U.FMovePoints);
            SafeValue := UnitSafe(U, Path[BestIndex].X, Path[BestIndex].Y);
            while (BestIndex < Path.Count - 1) and (SafeValue < 0) do begin
              SafeValue := UnitSafe(U, Path[BestIndex].X, Path[BestIndex].Y);
              if SafeValue >= 0 then I := BestIndex;
              Inc(BestIndex);
            end;
            if I >= 0 then
              for V := 0 to I - 1 do Path.Delete(0);
          end else SafeValue := 0;
          if Path.Count > 1 then
            if ((SafeValue < 0) and (FNormalUnits <> 0)) or not Adjacent then begin
              if FIgnoreWalls or ChargeFromPos(U.FPosition shr 4) then
                if ((SafeValue < 0) and (FNormalUnits <> 0)) or (U.FMovePoints < 1) or
                  ((Path[Path.Count - 2].Flag > U.FMovePoints) and (Path[Path.Count - 2].Flag < 16)) then
                  CreateMove(aiFake, X, Y, MultDEV(Value, U.GetMoves, Cost), Ability, Spell, U, Target)
                else begin
                  Inc(FHeroMoves);
                  CreateMove(aiMove, Path[0].X, Path[0].Y, MultDEV(Value, U.GetMoves, Cost), Ability, Spell, U, Target);
                end;
            end else if (Value > 0) or (FNormalUnits = 0) or not (U.FUnit is THero) or (Units.Count < 2) then begin
              Inc(FHeroMoves);
              if U.FUnit is THero then I := 50 else I := 100;
              CreateMove(aiMelee, X, Y, MultDEV(Value, I, 1), Ability, Spell, U, Target);
            end;
        end;
        Round.Free;
      end;
    except on E: Exception do MessageBox(0, PChar('Error - TCAI ' + E.Message), 'Error during Melee Check', 0); end;
    for AbilityIndex := 0 to Abilities.Count - 1 do begin
      Path.Clear;
      for I := 0 to BasePath.Count - 1 do Path.Add(BasePath[I]);
      Ability := TTCAbility(Abilities[AbilityIndex]).Ability;
      Spell := 0;
      X := OriginalX;
      Y := OriginalY;
      AoWHSSet.FAbilityControl.GetAbility(Ability).GetCombatInfo(U.FUnit, AbilityInfo);
      if Ability = $34 then begin
        try
          if not (Target is TCombatWall) or not AoWCombatMap.FCombat.FCombatData.FWallBreached then begin
            Spell := TTCAbility(Abilities[AbilityIndex]).Spell;
            case SpellTypes[Spell] of
              fxArrow, fxRock, fxComet, fxBreath, fxCometBall, fxEffect, fxScreenNESW, fxScreenNS,
              fxRay, fxChain, fxSwarm, fxScreenSwarm, fxSacredWrath, fxSWComet, fxDispel,
              fxBlood, fxAltArrow, fxTremors, fxHailImpact, fxHighPrayer, fxMindDecay, fxShockWave, fxSacFlame, fxWinds: begin
                AoWHSSet.FSpellControl.GetSpell(Spell).GetCombatInfo(U.FUnit, SpellInfo);
                AoWHSSet.FSpellControl.GetSpell(Spell).tcGetDamageValueEx(U, Target, Values);
                if Values.SourceDamage > 0 then begin
                  U.FCanFlee := False;
                  if Target is TCombatWall then FFlee := False;
                  PathValue := 0;
                  Range := SpellInfo.Range;
                  if (Spell = 108) or (Spell = 114) then Range := 4;
                  if Range = -1 then Range := 100;
                  case Spell of
                    8, 15..17, 32, 33, 36, 37, 40, 42, 43, 49, 56, 77, 102, 106, 110, 111:
                      Value := tcDVtoDEV(Values.SourceDamage, 0, Target, U);
                  else Value := MultDEV(tcDVtoDEV(Values.SourceDamage, 0, Target, U), HitPoints, Hits);
                  end;
                  if (Target.GetTargetStrength < 1) and (Enemies.Count > 1) then Dec(Value, 10000);
                  if U.FMovePoints > 0 then begin
                    I := TMovepath(Path).MovePointsToPos(U.FMovePoints);
                    D := dHXtoRad(Path[I].X, Path[I].Y, X, Y);
                    if (D <= Range) or (Distance <= Range) then begin
                      Cost := Value;
                      if Distance <= Range then
                        case Spell of
                          117: begin
                            PathValue := EvalPath(Value, Target, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, X, Y, True, U, Wall);
                            EvalArea(Value, Target, Ability, Spell, X, Y, True, True, True, U, Wall);
                            BestIndex := X;
                            BestValue := Y;
                            for I := 1 to 6 do begin
                              CenterHNtoHX(X, Y, I, NX, NY);
                              if dHXtoRad(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, NX, NY) <= Range then begin
                                D := Cost;
                                V := EvalPath(D, Target, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, NX, NY, True, U, Wall);
                                EvalArea(D, Target, Ability, Spell, NX, NY, True, True, True, U, Wall);
                                if D > Value then begin Value := D; PathValue := V; BestIndex := NX; BestValue := NY; end;
                              end;
                            end;
                            X := BestIndex;
                            Y := BestValue;
                          end;
                          127: begin
                            Value := 0;
                            Cost := 0;
                            for I := 1 to 36 do begin
                              CenterHNtoHX(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, I, NX, NY);
                              EvalHex(nil, Ability, Spell, NX, NY, Value, True, True, U, Wall);
                            end;
                          end;
                          128: begin
                            EvalHex(Target, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, Value, True, True, U, Wall);
                            for I := 0 to 18 do begin
                              CenterHNtoHX(X, Y, I, NX, NY);
                              EvalHex(Target, Ability, Spell, NX, NY, Value, True, True, U, Wall);
                            end;
                            BestIndex := X;
                            BestValue := Y;
                            for I := 1 to 18 do begin
                              CenterHNtoHX(X, Y, I, NX, NY);
                              if dHXtoRad(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, NX, NY) <= Range then begin
                                D := Cost;
                                EvalHex(Target, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, D, True, True, U, Wall);
                                for V := 0 to 18 do begin
                                  CenterHNtoHX(NX, NY, V, AX, AY);
                                  EvalHex(Target, Ability, Spell, AX, AY, D, True, True, U, Wall);
                                end;
                                if D > Value then begin Value := D; BestIndex := NX; BestValue := NY; end;
                              end;
                            end;
                            X := BestIndex;
                            Y := BestValue;
                          end;
                          100, 103, 119, 122, 123:
                            PathValue := EvalPath(Value, Target, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, X, Y, False, U, Wall);
                          116: begin
                            EvalArea(Value, Target, Ability, Spell, X, Y, True, True, True, U, Wall);
                            BestIndex := X;
                            BestValue := Y;
                            for I := 1 to 6 do begin
                              CenterHNtoHX(X, Y, I, NX, NY);
                              if dHXtoRad(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, NX, NY) <= Range then begin
                                D := Cost;
                                EvalArea(D, Target, Ability, Spell, NX, NY, True, True, True, U, Wall);
                                if D > Value then begin Value := D; BestIndex := NX; BestValue := NY; end;
                              end;
                            end;
                            X := BestIndex;
                            Y := BestValue;
                          end;
                          104, 120: begin
                            EvalArea(Value, Target, Ability, Spell, X, Y, False, True, True, U, Wall);
                            BestIndex := X;
                            BestValue := Y;
                            for I := 1 to 6 do begin
                              CenterHNtoHX(X, Y, I, NX, NY);
                              if dHXtoRad(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, NX, NY) <= Range then begin
                                D := Cost;
                                EvalArea(D, Target, Ability, Spell, NX, NY, False, True, True, U, Wall);
                                if D > Value then begin Value := D; BestIndex := NX; BestValue := NY; end;
                              end;
                            end;
                            X := BestIndex;
                            Y := BestValue;
                          end;
                          106: begin
                            EvalArea(Value, Target, Ability, Spell, X, Y, False, False, False, U, Wall);
                            BestIndex := X;
                            BestValue := Y;
                            for I := 1 to 6 do begin
                              CenterHNtoHX(X, Y, I, NX, NY);
                              if dHXtoRad(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, NX, NY) <= Range then begin
                                D := Cost;
                                EvalArea(D, Target, Ability, Spell, NX, NY, False, False, False, U, Wall);
                                if D > Value then begin Value := D; BestIndex := NX; BestValue := NY; end;
                              end;
                            end;
                            X := BestIndex;
                            Y := BestValue;
                          end;
                          112: if (FSide = csDefender) and (AoWCombatMap.FCombat.FCombatData.FWallType <> 0) then Value := -9999
                            else begin
                              EvalAll(Value, Enemies, Target, Spell, U);
                              EvalAll(Value, Allies, Target, Spell, U);
                              EvalAll(Value, Units, Target, Spell, U);
                            end;
                          125: begin
                            EvalAll(Value, Enemies, Target, Spell, U);
                            EvalAll(Value, Allies, Target, Spell, U);
                            EvalAll(Value, Units, Target, Spell, U);
                          end;
                          102: EvalAll(Value, Units, Target, Spell, U);
                          105: EvalAll(Value, Enemies, Target, Spell, U);
                          108, 114: PathValue := EvalBreath(Value, Target, Ability, Spell,
                            U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, X, Y, U);
                        end;
                    end;
                    if (D <= Range) and ((PathValue > 0) or (Value > 0)) then begin
                      if (PathValue <> 0) and (Value < Cost) then begin
                        BestIndex := 0;
                        BestValue := Value;
                        D := Cost;
                        I := Path.Count - 2;
                        while I > 0 do begin
                          CityWall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[Path[I].X, Path[I].Y].FindOwnedChild($220504));
                          if (CityWall = nil) and (FSide = csAttacker) then
                            CityWall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[Path[I].X, Path[I].Y].FindOwnedChild($220506));
                          if (CityWall = nil) or (CityWall.FHitPoints < 1) or U.GetAbilityEnabled(1) or U.GetAbilityEnabled($24) or U.GetAbilityEnabled($42) then begin
                            if dHXtoRad(Path[0].X, Path[0].Y, Path[I].X, Path[I].Y) <= Range then begin
                              V := EvalPath(Cost, Target, Ability, Spell, Path[I].X, Path[I].Y, X, Y, Spell = $75, U, Wall);
                              Cost := D;
                              if V < PathValue then begin
                                BestValue := BestValue + PathValue - V;
                                PathValue := V;
                                BestIndex := I;
                              end;
                            end;
                          end else I := 1;
                          Dec(I);
                        end;
                        if BestIndex > 0 then begin
                          DetourPath.Clear;
                          for I := BestIndex to Path.Count - 1 do DetourPath.Add(Path[I]);
                          TerrainValue := 0;
                          PathCost := MakeTerrainPath(Settings, DetourPath, TerrainValue, U, TTacticalCombatUnit(Target), True, False, 1);
                          Inc(PathValue, BestValue);
                          PathCost := TMovepath(Path).PosToMovePoints(0);
                        end;
                      end;
                      BestIndex := 0;
                      for I := 1 to Path.Count - 2 do
                        if (dHXtoRad(X, Y, Path[I].X, Path[I].Y) <= Range) and
                          (TMovepath(Path).PosToMovePoints(I) <= U.FMovePoints) then begin
                          Cost := 1000;
                          V := EvalPath(Cost, Target, Ability, Spell, Path[I].X, Path[I].Y, X, Y, Spell = $75, U, Wall);
                          if (V = 0) and (Cost = 1000) then BestIndex := I;
                        end;
                      if BestIndex > 0 then
                        for I := 0 to BestIndex - 1 do Path.Delete(0);
                      PathCost := TMovepath(Path).PosToMovePoints(0);
                    end;
                  end;
                  Cost := (PathCost - U.FMovePoints - Range * 4) * 10;
                  if Cost < 1 then Cost := 1;
                  if U.FUnit is THero then begin
                    I := -1;
                    BestIndex := TMovepath(Path).MovePointsToPos(U.FMovePoints);
                    SafeValue := UnitSafe(U, Path[BestIndex].X, Path[BestIndex].Y);
                    while (BestIndex < Path.Count - 1) and (SafeValue < 0) do begin
                      SafeValue := UnitSafe(U, Path[BestIndex].X, Path[BestIndex].Y);
                      if SafeValue >= 0 then I := BestIndex;
                      Inc(BestIndex);
                    end;
                    if I >= 0 then
                      for V := 0 to I - 1 do Path.Delete(0);
                  end else SafeValue := 0;
                  if ((PathValue = 0) or (Value <> 0)) and (Distance <= Range) and (U.GetMoves = U.FMovePoints) then begin
                    Inc(FHeroMoves);
                    I := Abs(Value + PathValue);
                    if I < 1 then I := 1;
                    CreateMove(aiRanged, X, Y, MultDEV(Value, Value * 100 div I, 1), Ability, Spell, U, Target);
                    if (PathValue > 0) and (U.FMovePoints > 0) and (DetourPath.Count > 1) then
                      if not ((DetourPath[DetourPath.Count - 2].Flag > U.FMovePoints) and
                        (DetourPath[DetourPath.Count - 2].Flag < 16)) then begin
                        Inc(FHeroMoves);
                        CreateMove(aiMoveRanged, DetourPath[0].X, DetourPath[0].Y,
                          MultDEV(PathValue + TerrainValue, 100 * PathValue div I, 1), Ability, Spell, U, Target);
                      end;
                  end else begin
                    if (Path.Count > 1) and (FIgnoreWalls or ChargeFromPos(U.FPosition shr 4)) then
                      if ((SafeValue < 0) and (FNormalUnits <> 0)) or (U.FMovePoints < 1) or (Path.Count < 2) or
                        ((Path[Path.Count - 2].Flag > U.FMovePoints) and (Path[Path.Count - 2].Flag < 16)) then
                        CreateMove(aiFake, X, Y, MultDEV(MultDEV(PathValue, 100, 1) + TerrainValue + Value, U.GetMoves, Cost), Ability, Spell, U, Target)
                      else
                        CreateMove(aiMoveRanged, Path[0].X, Path[0].Y, MultDEV(PathValue + TerrainValue + Value, U.GetMoves, Cost), Ability, Spell, U, Target);
                  end;
                end;
              end;
            end;
          end;
        except on E: Exception do MessageBox(0, PChar('Error - TCAI ' + E.Message), 'Error during Spell Check', 0); end;
      end else
        case AbilTypes[Ability] of
          fxTouch:
            if (Target is TCombatWall) or ((Target is TCombatUnit) and TTouchAbility(AoWHSSet.FAbilityControl.GetAbility(Ability)).CanTouch(U, Target)) then begin
              try
                AoWHSSet.FAbilityControl.GetAbility(Ability).tcGetDamageValueEx(U, Target, Values);
                if Values.SourceDamage > 0 then begin
                  Adjacent := TMovepath(Path).MovePointsToPos(U.FMovePoints) = 0;
                  U.FCanFlee := False;
                  if Target is TCombatWall then FFlee := False;
                  if Ability = $41 then Values.TargetDamage := 0;
                  Value := MultDEV(tcDVtoDEV(Values.SourceDamage, Values.TargetDamage, Target, U), HitPoints, Hits) + TerrainValue;
                  case Ability of
                    $1B..$1D, $28, $3C, $6A, $6B, $94: Value := tcDVtoDEV(Values.SourceDamage, 0, Target, U);
                  else Value := MultDEV(tcDVtoDEV(Values.SourceDamage, 0, Target, U), HitPoints, Hits);
                  end;
                  if (Ability = $75) and (MeleeDamageTypes(U) = []) then Value := MultDEV(Value, 100, 1);
                  if (Target.GetTargetStrength < 1) and (Enemies.Count > 1) then Dec(Value, 10000);
                  if (U.FMovePoints > 0) and (TMovepath(Path).MovePointsToPos(U.FMovePoints) = 0) then
                    if Ability = $41 then EvalArea(Value, Target, Ability, Spell, Path[1].X, Path[1].Y, True, False, True, U, Wall)
                    else if Ability = $72 then EvalArea(Value, Target, Ability, Spell, Path[1].X, Path[1].Y, False, False, True, U, Wall);
                  Cost := (PathCost - U.FMovePoints) * 10;
                  if Cost < 1 then Cost := 1;
                  if U.FUnit is THero then begin
                    I := -1;
                    BestIndex := TMovepath(Path).MovePointsToPos(U.FMovePoints);
                    SafeValue := UnitSafe(U, Path[BestIndex].X, Path[BestIndex].Y);
                    while (BestIndex < Path.Count - 1) and (SafeValue < 0) do begin
                      SafeValue := UnitSafe(U, Path[BestIndex].X, Path[BestIndex].Y);
                      if SafeValue >= 0 then I := BestIndex;
                      Inc(BestIndex);
                    end;
                    if I >= 0 then
                      for V := 0 to I - 1 do Path.Delete(0);
                  end else SafeValue := 0;
                  if Path.Count > 1 then
                    if ((SafeValue < 0) and (FNormalUnits <> 0)) or not Adjacent then begin
                      if FIgnoreWalls or ChargeFromPos(U.FPosition shr 4) then
                        if ((SafeValue < 0) and (FNormalUnits <> 0)) or (U.FMovePoints < 1) or
                          ((Path[Path.Count - 2].Flag > U.FMovePoints) and (Path[Path.Count - 2].Flag < 16)) then
                          CreateMove(aiFake, X, Y, MultDEV(Value, U.GetMoves, Cost), Ability, Spell, U, Target)
                        else begin
                          Inc(FHeroMoves);
                          CreateMove(aiMove, Path[0].X, Path[0].Y, MultDEV(Value, U.GetMoves, Cost), Ability, Spell, U, Target);
                        end;
                    end else if (Value > 0) or (FNormalUnits = 0) or not (U.FUnit is THero) or (Units.Count < 2) then begin
                      Inc(FHeroMoves);
                      if U.FUnit is THero then I := 50 else I := 100;
                      CreateMove(aiTouch, X, Y, MultDEV(Value, I, 1), Ability, Spell, U, Target);
                    end;
                end;
              except on E: Exception do MessageBox(0, PChar('Error - TCAI ' + E.Message), 'Error during Touch Check', 0); end;
            end;
          fxArrow, fxRock, fxComet, fxBreath, fxCometBall, fxEffect, fxScreenNESW, fxScreenNS,
          fxRay, fxChain, fxSwarm, fxScreenSwarm, fxSacredWrath, fxSWComet, fxDispel,
          fxBlood, fxAltArrow, fxTremors, fxHailImpact, fxHighPrayer: begin
            try
              Cost := AoWHSSet.FAbilityControl.GetAbility(Ability).tcGetDamageValue(U, Target);
              if Cost > 0 then begin
                U.FCanFlee := False;
                if Target is TCombatWall then FFlee := False;
                PathValue := 0;
                if AoWHSSet.FAbilityControl.GetAbility(Ability).GetCombatMode(U.FUnit) = cmLongRange then Range := 12
                else if AoWHSSet.FAbilityControl.GetAbility(Ability).GetCombatMode(U.FUnit) = cmMediumRange then Range := 8
                else Range := 4;
                Value := MultDEV(tcDVtoDEV(Cost, 0, Target, U), HitPoints, Hits);
                if (Target.GetTargetStrength < 1) and (Enemies.Count > 1) then Dec(Value, 10000);
                if U.FMovePoints > 0 then begin
                  I := TMovepath(Path).MovePointsToPos(U.FMovePoints);
                  D := dHXtoRad(Path[I].X, Path[I].Y, X, Y);
                  if (D <= Range) or (Distance <= Range) then begin
                    Cost := Value;
                    if Distance <= Range then
                      case Ability of
                        $16, $19, $2D, $37, $39, $3A, $3D, $3E, $78..$7C:
                          PathValue := EvalPath(Value, Target, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, X, Y, False, U, Wall);
                        $18, $2C: PathValue := EvalPath(Value, Target, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, X, Y, True, U, Wall);
                        $1E, $56..$5A: PathValue := EvalBreath(Value, Target, Ability, Spell, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, X, Y, U);
                      end;
                  end;
                  if (D <= Range) and ((PathValue > 0) or (Value > 0)) then begin
                    if (PathValue <> 0) and (Value < Cost) then begin
                      BestIndex := 0;
                      BestValue := Value;
                      D := Cost;
                      I := Path.Count - 2;
                      while I > 0 do begin
                        CityWall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[Path[I].X, Path[I].Y].FindOwnedChild($220504));
                        if (CityWall = nil) and (FSide = csAttacker) then
                          CityWall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[Path[I].X, Path[I].Y].FindOwnedChild($220506));
                        if (CityWall = nil) or (CityWall.FHitPoints < 1) or U.GetAbilityEnabled(1) or U.GetAbilityEnabled($24) or U.GetAbilityEnabled($42) then begin
                          if dHXtoRad(Path[0].X, Path[0].Y, Path[I].X, Path[I].Y) <= Range then begin
                            V := EvalPath(Cost, Target, Ability, Spell, Path[I].X, Path[I].Y, X, Y, (Ability = $18) or (Ability = $2C), U, Wall);
                            Cost := D;
                            if V < PathValue then begin
                              BestValue := BestValue + PathValue - V;
                              PathValue := V;
                              BestIndex := I;
                            end;
                          end;
                        end else I := 1;
                        Dec(I);
                      end;
                      if BestIndex > 0 then begin
                        DetourPath.Clear;
                        for I := BestIndex to Path.Count - 1 do DetourPath.Add(Path[I]);
                        TerrainValue := 0;
                        PathCost := MakeTerrainPath(Settings, DetourPath, TerrainValue, U, TTacticalCombatUnit(Target), True, False, 1);
                        Inc(PathValue, BestValue);
                        PathCost := TMovepath(Path).PosToMovePoints(0);
                      end;
                    end;
                    BestIndex := 0;
                    for I := 1 to Path.Count - 2 do
                      if (dHXtoRad(X, Y, Path[I].X, Path[I].Y) <= Range) and
                        (TMovepath(Path).PosToMovePoints(I) <= U.FMovePoints) then begin
                        Cost := 1000;
                        V := EvalPath(Cost, Target, Ability, Spell, Path[I].X, Path[I].Y, X, Y, Spell = $75, U, Wall);
                        if (V = 0) and (Cost = 1000) then BestIndex := I;
                      end;
                    if BestIndex > 0 then
                      for I := 0 to BestIndex - 1 do Path.Delete(0);
                    PathCost := TMovepath(Path).PosToMovePoints(0);
                  end;
                end;
                Cost := (PathCost - U.FMovePoints - Range * 4) * 10;
                if Cost < 1 then Cost := 1;
                if U.FUnit is THero then begin
                  I := -1;
                  BestIndex := TMovepath(Path).MovePointsToPos(U.FMovePoints);
                  SafeValue := UnitSafe(U, Path[BestIndex].X, Path[BestIndex].Y);
                  while (BestIndex < Path.Count - 1) and (SafeValue < 0) do begin
                    SafeValue := UnitSafe(U, Path[BestIndex].X, Path[BestIndex].Y);
                    if SafeValue >= 0 then I := BestIndex;
                    Inc(BestIndex);
                  end;
                  if I >= 0 then
                    for V := 0 to I - 1 do Path.Delete(0);
                end else SafeValue := 0;
                if (UnitSafe(U, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx) < 0) and (FNormalUnits <> 0) or
                  ((PathValue <> 0) and (Value = 0)) or (Distance > Range) or (U.GetMoves <> U.FMovePoints) then begin
                  if (Path.Count > 1) and (FIgnoreWalls or ChargeFromPos(U.FPosition shr 4)) then
                    if ((SafeValue < 0) and (FNormalUnits <> 0)) or (U.FMovePoints < 1) or (Path.Count < 2) or
                      ((Path[Path.Count - 2].Flag > U.FMovePoints) and (Path[Path.Count - 2].Flag < 16)) then
                      CreateMove(aiFake, X, Y, MultDEV(MultDEV(PathValue, 100, 1) + TerrainValue + Value, U.GetMoves, Cost), Ability, Spell, U, Target)
                    else
                      CreateMove(aiMoveRanged, Path[0].X, Path[0].Y, MultDEV(PathValue + TerrainValue + Value, U.GetMoves, Cost), Ability, Spell, U, Target);
                end else begin
                  Inc(FHeroMoves);
                  if (Target is TCombatWall) and AoWCombatMap.FCombat.FCombatData.FWallBreached and (AoWCombatMap.FRound > 1) then I := 10 else I := 100;
                  V := Abs(Value + PathValue);
                  if V < 1 then V := 1;
                  CreateMove(aiRanged, X, Y, MultDEV(Value, I * Value div V, 1), Ability, Spell, U, Target);
                  if (PathValue > 0) and (U.FMovePoints > 0) and (DetourPath.Count > 1) then
                    if not ((DetourPath[DetourPath.Count - 2].Flag > U.FMovePoints) and
                      (DetourPath[DetourPath.Count - 2].Flag < 16)) then begin
                      Inc(FHeroMoves);
                      CreateMove(aiMoveRanged, DetourPath[0].X, DetourPath[0].Y,
                        MultDEV(PathValue + TerrainValue, I * PathValue div V, 1), Ability, Spell, U, Target);
                    end;
                end;
              end;
            except on E: Exception do MessageBox(0, PChar('Error - TCAI ' + E.Message), 'Error during Ranged Check', 0); end;
          end;
        end;
    end;
  end;
  Path.Free;
  BasePath.Free;
  DetourPath.Free;
end;

procedure TCAI.EvalBattle;
var
  I, J, K, L, N, Value: Integer;
  Move, OtherMove: TaiMove;
  U, Target: TTacticalCombatUnit;
  Settings: TCombatMoveControlSettings;
  Moved, Found, Visible: Boolean;
  Abilities: TList;
  PathCost, TerrainCost: Integer;
  Path: TXYLList;
  Reason: string;
  Bonuses: TList;
  AIInfo: TAbilityCombatInfo;
  SpellInfo: TSpellCombatInfo;
  Wall: TCityWall;
begin
  Status := aiBusy;
  if AoWHSMap.FTokenManager.PlayerReady(AoWCombatMap.FCurrentPlayer) then
    case CurrentMove of
      0: try
        FUnitIndex := 0;
        FHeroMoves := 0;
        Units.Clear;
        Allies.Clear;
        Enemies.Clear;
        for I := 0 to Moves.Count - 1 do TObject(Moves[I]).Free;
        Moves.Clear;
        Walls.Clear;
        FSide := TCombatSideIndex(AoWCombatMap.FCombat.FCombatData.FPlayers.GetPlayers(AoWCombatMap.FCombat.FCombatData.FCurrentPlayer).FSideIndex);
        FNormalUnits := 0;
        for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
          if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) <> nil) and
            (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
            AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled then begin
            Visible := False;
            J := 0;
            while not Visible and (J < 19) do begin
              CenterHNtoHX(TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.GetXhx,
                TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.GetYhx, J, K, L);
              if not AoWCombatMap.FExplorationEnabled or
                TAoWMapField(AoWCombatMap.MapContainer.GetField(K, L, 0)).GetExplored(AoWCombatMap.FSeatedPlayer) then
                Visible := True
              else Inc(J);
            end;
            if Visible then
              if AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetSide = FSide then
                if AoWCombatMap.FCombat.FCombatData.GetObjects(I).FCombatPlayer = AoWCombatMap.FCombat.FCombatData.FCurrentPlayer then begin
                  if not AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetLocked then
                    if TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnit is THero then
                      Units.Add(AoWCombatMap.FCombat.FCombatData.GetObjects(I))
                    else begin
                      Inc(FNormalUnits);
                      Units.Insert(0, AoWCombatMap.FCombat.FCombatData.GetObjects(I));
                    end;
                end else Allies.Add(AoWCombatMap.FCombat.FCombatData.GetObjects(I))
              else Enemies.Add(AoWCombatMap.FCombat.FCombatData.GetObjects(I));
          end;
        AoWEngine.OutputDebugStr('AI found ' + IntToStr(Units.Count) + ' Own units.');
        AoWEngine.OutputDebugStr('AI found ' + IntToStr(Allies.Count) + ' Ally units.');
        AoWEngine.OutputDebugStr('AI found ' + IntToStr(Enemies.Count) + ' Enemy units.');
        FIgnoreWalls := FSide = csAttacker;
        FFlee := (FSide = csAttacker) and (AoWCombatMap.FCombat.FCombatData.FWallType <> 0) and
          not AoWCombatMap.FCombat.FCombatData.FWallBreached;
        FMinMoves := 100;
        for I := 0 to Units.Count - 1 do begin
          U := Units[I];
          U.FCanFlee := FSide = csAttacker;
          if U.GetMoves < FMinMoves then FMinMoves := U.GetMoves;
          for J := 0 to Enemies.Count - 1 do begin
            Target := Enemies[J];
            if not FIgnoreWalls and (Target.GetSide <> U.GetSide) then begin
              K := dHXtoRad(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, Target.FUnitHS.GetXhx, Target.FUnitHS.GetYhx);
              for L := 22 to 169 do
                if Target.GetAbilityEnabled(L) then
                  if (L = $34) and (Target.FUnit is THero) then begin
                    for N := 0 to 130 do
                      if (Target.FUnit.FPlayer > 0) and (SpellTypes[N] <> fxNone) and
                        (AoWHSMap.FPlayers.GetPlayers(Target.FUnit.FPlayer).FMagicControl.FSpells.IndexOf(N) <> -1) and
                        THero(Target.FUnit).CanCastSpellInstantly(N, AoWHSSet.FSpellControl.GetSpell(N).FBaseManaCost, Reason) then begin
                        AoWHSSet.FSpellControl.GetSpell(N).GetCombatInfo(Target.FUnit, SpellInfo);
                        if (cttEnemy in SpellInfo.TargetTypes) and ((K <= SpellInfo.Range) or (SpellInfo.Range = -1)) then begin
                          Value := AoWHSSet.FSpellControl.GetSpell(N).tcGetDamageValue(Target, U);
                          if Value > 0 then
                            if SpellTypes[N] in [fxArrow, fxRock, fxComet, fxBreath, fxCometBall, fxRay] then begin
                              EvalPath(Value, U, L, N, Target.FUnitHS.GetXhx, Target.FUnitHS.GetYhx,
                                U.FUnitHS.GetYhx, U.FUnitHS.GetXhx, False, Target, nil);
                              if Value > 0 then FIgnoreWalls := True;
                            end else FIgnoreWalls := True;
                        end;
                      end;
                  end else if (AbilTypes[L] <> fxNone) and (AbilTypes[L] <> fxTouch) then begin
                    AoWHSSet.FAbilityControl.GetAbility(L).GetCombatInfo(Target.FUnit, AIInfo);
                    if Byte(AIInfo.TargetTypes) and 2 <> 0 then begin
                      if AoWHSSet.FAbilityControl.GetAbility(L).GetCombatMode(Target.FUnit) = cmLongRange then N := 12
                      else if AoWHSSet.FAbilityControl.GetAbility(L).GetCombatMode(Target.FUnit) = cmMediumRange then N := 8
                      else N := 4;
                      if K <= N then begin
                        Value := AoWHSSet.FAbilityControl.GetAbility(L).tcGetDamageValue(Target, U);
                        if Value > 0 then
                          if AbilTypes[L] in [fxArrow, fxRock, fxComet, fxBreath, fxCometBall, fxRay] then begin
                            EvalPath(Value, U, L, 0, Target.FUnitHS.GetXhx, Target.FUnitHS.GetYhx,
                              U.FUnitHS.GetYhx, U.FUnitHS.GetXhx, False, Target, nil);
                            if Value > 0 then FIgnoreWalls := True;
                          end else FIgnoreWalls := True;
                      end;
                    end;
                  end;
            end;
          end;
        end;
        Inc(CurrentMove);
        FUnitIndex := 0;
        FUnitLimit := 0;
      except MessageBox(0, 'Error - TCAI', 'Error during Create Unit List', 0); end;
      1: try
        while (FUnitIndex < Units.Count) and (FUnitLimit < 1) do begin
          U := Units[FUnitIndex];
          if not U.GetLocked then begin
            Abilities := TList.Create;
            try
            for J := 0 to 169 do
              if U.GetAbilityEnabled(J) then begin
                if J in [1, $24, $42, $75] then FFlee := False;
                if (J = $34) and (U.FUnit is THero) then begin
                  for K := 0 to 130 do
                    if (U.FUnit.FPlayer > 0) and (SpellTypes[K] <> fxNone) and
                      (AoWHSMap.FPlayers.GetPlayers(U.FUnit.FPlayer).FMagicControl.FSpells.IndexOf(K) <> -1) and
                      THero(U.FUnit).CanCastSpellInstantly(K, AoWHSSet.FSpellControl.GetSpell(K).FBaseManaCost, Reason) then begin
                      AoWHSSet.FSpellControl.GetSpell(K).GetCombatInfo(U.FUnit, SpellInfo);
                      if cttEnemy in SpellInfo.TargetTypes then begin
                        Abilities.Add(TTCAbility.Create);
                        TTCAbility(Abilities[Abilities.Count - 1]).Ability := J;
                        TTCAbility(Abilities[Abilities.Count - 1]).Spell := K;
                      end;
                    end;
                end else if AbilTypes[J] <> fxNone then begin
                  AoWHSSet.FAbilityControl.GetAbility(J).GetCombatInfo(U.FUnit, AIInfo);
                  if Byte(AIInfo.TargetTypes) and 2 <> 0 then begin
                    Abilities.Add(TTCAbility.Create);
                    TTCAbility(Abilities[Abilities.Count - 1]).Ability := J;
                  end;
                end;
              end;
            except on E: Exception do MessageBox(0, PChar('Error - TCAI ' + E.Message), 'Error during Eval Enemies', 0); end;
            Settings := TCombatMoveControlSettings.Create(nil);
            if U.FMovePoints > 0 then begin
              Settings.SetSourcePos(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, 0);
              Settings.FArmyHS := U.FUnitHS;
              Settings.FMoveFlags := $1A;
              U.FUnit.CreateMovePointTable(Settings.FMovePointTable);
              Settings.FPlayer := U.GetPlayer;
              Settings.FMovePointsMax := 200;
              AoWCombatMap.FMoveControl.ProcessMove(Settings);
            end;
            if (Abilities.Count > 0) or (MeleeDamageTypes(U) <> []) then
              for J := 0 to Enemies.Count - 1 do begin
                Target := Enemies[J];
                if not (U.FUnit is THero) or (FHeroMoves = 0) then
                  CheckUnit(Target.FUnitHS.GetXhx, Target.FUnitHS.GetYhx, Target.GetHits, Target.GetHitPoints,
                    Settings, U, Target, Abilities, nil);
              end;
            for I := 0 to Abilities.Count - 1 do TObject(Abilities[I]).Free;
            Abilities.Clear;
            try
            for J := 22 to 169 do
              if U.GetAbilityEnabled(J) then begin
                if (J = $34) and (U.FUnit is THero) then begin
                  for K := 0 to 130 do
                    if (SpellTypes[K] <> fxNone) and
                      (AoWHSMap.FPlayers.GetPlayers(U.FUnit.FPlayer).FMagicControl.FSpells.IndexOf(K) <> -1) and
                      THero(U.FUnit).CanCastSpellInstantly(K, AoWHSSet.FSpellControl.GetSpell(K).FBaseManaCost, Reason) then begin
                      AoWHSSet.FSpellControl.GetSpell(K).GetCombatInfo(U.FUnit, SpellInfo);
                      if cttFriend in SpellInfo.TargetTypes then begin
                        Abilities.Add(TTCAbility.Create);
                        TTCAbility(Abilities[Abilities.Count - 1]).Ability := J;
                        TTCAbility(Abilities[Abilities.Count - 1]).Spell := K;
                      end;
                    end;
                end else if AbilTypes[J] <> fxNone then begin
                  AoWHSSet.FAbilityControl.GetAbility(J).GetCombatInfo(U.FUnit, AIInfo);
                  if Byte(AIInfo.TargetTypes) and 1 <> 0 then begin
                    Abilities.Add(TTCAbility.Create);
                    TTCAbility(Abilities[Abilities.Count - 1]).Ability := J;
                  end;
                end;
              end;
            except on E: Exception do MessageBox(0, PChar('Error - TCAI ' + E.Message), 'Error during Eval Friends', 0); end;
            if Abilities.Count > 0 then
              for J := 0 to Units.Count - 1 do begin
                Target := Units[J];
                if not (U.FUnit is THero) or (FHeroMoves = 0) then
                  CheckUnit(Target.FUnitHS.GetXhx, Target.FUnitHS.GetYhx, Target.GetHits, Target.GetHitPoints,
                    Settings, U, Target, Abilities, nil);
              end;
            Settings.Free;
            for I := 0 to Abilities.Count - 1 do TObject(Abilities[I]).Free;
            Abilities.Free;
          end;
          Inc(FUnitIndex);
          Inc(FUnitLimit);
        end;
        if FUnitIndex >= Units.Count then begin
          Inc(CurrentMove);
          try
            if (AoWCombatMap.FCombat.FCombatData.FWallType <> 0) and
              (AoWCombatMap.FCombat.FCombatData.FWall <> nil) and (FSide = csAttacker) then
              for J := 0 to AoWCombatMap.FWalls.Count - 1 do
                if (TCityWall(AoWCombatMap.FWalls[J]).FHitPoints > 0) and
                  (TCityWall(AoWCombatMap.FWalls[J]).FHitPoints < WallMaxHP[TCityWall(AoWCombatMap.FWalls[J]).FWallType - 1]) then begin
                  Found := True;
                  K := 0;
                  while Found and (K < Walls.Count) do
                    if Walls[K] = AoWCombatMap.FWalls[J] then Found := False else Inc(K);
                  if Found then Walls.Add(AoWCombatMap.FWalls[J]);
                end;
            if (AoWCombatMap.FCombat.FCombatData.FWallType = 0) or
              (AoWCombatMap.FCombat.FCombatData.FWall = nil) or (FSide = csDefender) then Inc(CurrentMove);
            FUnitIndex := 0;
            AoWEngine.OutputDebugStr('AI calculated ' + IntToStr(Units.Count * Enemies.Count) + ' Attack paths.');
            AoWEngine.OutputDebugStr('AI calculated ' + IntToStr(Moves.Count) + ' Moves.');
          except MessageBox(0, 'Error - TCAI ', 'Error during Eval Ending', 0); end;
        end;
        FUnitLimit := 0;
      except MessageBox(0, 'Error - TCAI', 'Error during Create Move List', 0); end;
      2: try
        while (FUnitIndex < Units.Count) and (FUnitLimit < 1) do begin
          U := Units[FUnitIndex];
          if not U.GetLocked then begin
            Abilities := TList.Create;
            for J := 0 to 169 do
              if U.GetAbilityEnabled(J) then begin
                if J in [1, $24, $42, $75] then FFlee := False;
                if (J = $34) and (U.FUnit is THero) then begin
                  if U.FUnit.FPlayer > 0 then
                  for K := 0 to 130 do
                    if (SpellTypes[K] <> fxNone) and
                      (AoWHSMap.FPlayers.GetPlayers(U.FUnit.FPlayer).FMagicControl.FSpells.IndexOf(K) <> -1) and
                      THero(U.FUnit).CanCastSpellInstantly(K, AoWHSSet.FSpellControl.GetSpell(K).FBaseManaCost, Reason) then begin
                      AoWHSSet.FSpellControl.GetSpell(K).GetCombatInfo(U.FUnit, SpellInfo);
                      if dtWall in SpellInfo.DamageTypes then begin
                        FFlee := False;
                        Abilities.Add(TTCAbility.Create);
                        TTCAbility(Abilities[Abilities.Count - 1]).Ability := J;
                        TTCAbility(Abilities[Abilities.Count - 1]).Spell := K;
                      end;
                    end;
                end else if AbilTypes[J] <> fxNone then begin
                  AoWHSSet.FAbilityControl.GetAbility(J).GetCombatInfo(U.FUnit, AIInfo);
                  if dtWall in AIInfo.DamageTypes then begin
                    FFlee := False;
                    Abilities.Add(TTCAbility.Create);
                    TTCAbility(Abilities[Abilities.Count - 1]).Ability := J;
                  end;
                end;
              end;
            if Abilities.Count > 0 then begin
              Settings := TCombatMoveControlSettings.Create(nil);
            if U.FMovePoints > 0 then begin
              Settings.SetSourcePos(U.FUnitHS.GetXhx, U.FUnitHS.GetYhx, 0);
              Settings.FArmyHS := U.FUnitHS;
              Settings.FMoveFlags := $1A;
              if U.GetAbilityEnabled($41) or U.GetAbilityEnabled($75) then Settings.FMoveFlags := Settings.FMoveFlags or 1;
              U.FUnit.CreateMovePointTable(Settings.FMovePointTable);
              Settings.FPlayer := U.GetPlayer;
              Settings.FMovePointsMax := 200;
              AoWCombatMap.FMoveControl.ProcessMove(Settings);
            end;
              for J := 0 to Walls.Count - 1 do begin
                Wall := Walls[J];
                if not (U.FUnit is THero) or (FHeroMoves = 0) then
                  CheckUnit(Wall.GetXhx, Wall.GetYhx, Wall.FHitPoints, WallMaxHP[Wall.FWallType - 1] * 2,
                    Settings, U, AoWCombatMap.FCombat.FCombatData.FWall, Abilities, Wall);
              end;
              if Walls.Count = 0 then begin
                L := 100;
                Wall := nil;
                for J := 0 to AoWCombatMap.FWalls.Count - 1 do begin
                  N := dHXtoRad(TCityWall(AoWCombatMap.FWalls[J]).GetXhx, TCityWall(AoWCombatMap.FWalls[J]).GetYhx,
                    U.FUnitHS.GetXhx, U.FUnitHS.GetYhx);
                  if (TCityWall(AoWCombatMap.FWalls[J]).FHitPoints > 0) and (N < L) then begin
                    Wall := AoWCombatMap.FWalls[J];
                    L := N;
                  end;
                end;
                if Wall <> nil then
                  CheckUnit(Wall.GetXhx, Wall.GetYhx, Wall.FHitPoints * 2, WallMaxHP[Wall.FWallType - 1],
                    Settings, U, AoWCombatMap.FCombat.FCombatData.FWall, Abilities, Wall);
              end;
              Settings.Free;
            for I := 0 to Abilities.Count - 1 do TObject(Abilities[I]).Free;
            end;
            Abilities.Free;
          end;
          Inc(FUnitIndex);
          Inc(FUnitLimit);
        end;
        if FUnitIndex >= Units.Count then begin
          Inc(CurrentMove);
          Walls.Clear;
          FUnitIndex := 0;
          AoWEngine.OutputDebugStr('AI calculated ' + IntToStr(Units.Count * Enemies.Count) + ' Attack paths.');
          AoWEngine.OutputDebugStr('AI calculated ' + IntToStr(Moves.Count) + ' Moves.');
        end;
        FUnitLimit := 0;
      except MessageBox(0, 'Error - TCAI', 'Error during Create WallCrush List', 0); end;
      3: try
        Bonuses := TList.Create;
        for I := 0 to Units.Count - 1 do Bonuses.Add(nil);
        while (FUnitIndex < Moves.Count) and (FUnitLimit < 50) do begin
          Move := Moves[FUnitIndex];
          if Move.MoveType <> aiFake then begin
            for J := 0 to Units.Count - 1 do Bonuses[J] := nil;
            for J := 0 to Moves.Count - 1 do begin
              OtherMove := Moves[J];
              if Move.UnitHS.FUnit <> OtherMove.UnitHS.FUnit then begin
                K := dHXtoRad(Move.X, Move.Y, OtherMove.X, OtherMove.Y) * 4 - OtherMove.UnitHS.FUnit.FMovePoints;
                if K < 4 then K := 4;
                L := OtherMove.UnitHS.FUnit.GetMoves * (OtherMove.Value div (K * 10));
                K := Units.IndexOf(OtherMove.UnitHS.FUnit);
                if Integer(Bonuses[K]) < L then Bonuses[K] := Pointer(L);
              end;
            end;
            for J := 0 to Units.Count - 1 do
              if (Move.GroupValue > -1000000) and (Move.GroupValue < 1000000) then
                Inc(Move.GroupValue, Integer(Bonuses[J]));
          end;
          Inc(FUnitIndex);
          Inc(FUnitLimit);
        end;
        if FUnitIndex >= Moves.Count then Inc(CurrentMove);
        FUnitLimit := 0;
        Bonuses.Free;
      except MessageBox(0, 'Error - TCAI', 'Error during Build Group Bonuses', 0); end;
      4: try
        for I := 0 to Units.Count - 1 do begin
          U := Units[I];
          if (U.FUnit is THero) and (FHeroMoves = 0) and (U.FMovePoints > 0) then begin
            Value := UnitSafe(U, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx);
            N := -1;
            K := Value;
            for J := 0 to Units.Count - 1 do begin
              Target := Units[J];
              if U <> Target then begin
                L := UnitSafe(U, Target.FUnitHS.GetXhx, Target.FUnitHS.GetYhx);
                if L > K then begin N := J; K := L; end;
              end;
            end;
            if K > Value then begin
              Settings := TCombatMoveControlSettings.Create(nil);
              Settings.SetSourcePos(U.FUnitHS.GetXhx, U.FUnitHS.GetXhx, 0); { Original uses X for both coordinates. }
              Settings.SetDestinationPos(TTacticalCombatUnit(Units[N]).FUnitHS.GetXhx,
                TTacticalCombatUnit(Units[N]).FUnitHS.GetYhx, 0);
              Settings.FArmyHS := U.FUnitHS;
              Settings.FMoveFlags := $1A;
              U.FUnit.CreateMovePointTable(Settings.FMovePointTable);
              Settings.FPlayer := U.GetPlayer;
              AoWCombatMap.FMoveControl.ProcessMove(Settings);
              if Settings.FPath.Count > 2 then begin
                Settings.FPath.Delete(0);
                CreateMove(aiMove, Settings.FPath[0].X, Settings.FPath[0].Y, K, 0, 0, U, nil);
              end;
              Settings.Free;
            end else if FSide = csAttacker then U.FCanFlee := True;
          end;
        end;
        if FSide = csAttacker then
          for I := 0 to Units.Count - 1 do begin
            U := Units[I];
            if (not (U.FUnit is THero) or (FHeroMoves = 0) or ((U.FUnit is THero) and (Units.Count = 1))) and
              U.GetEnabled and not U.GetLocked and (U.FMovePoints > 0) and (FFlee or U.FCanFlee) then
              for J := 0 to AoWCombatMap.FFleeLocations.Count - 1 do
                CreateMove(aiMove, THexagonSprite(AoWCombatMap.FFleeLocations[J]).GetXhx,
                  THexagonSprite(AoWCombatMap.FFleeLocations[J]).GetYhx,
                  110000000 - dHXtoRad(THexagonSprite(AoWCombatMap.FFleeLocations[J]).GetXhx,
                    THexagonSprite(AoWCombatMap.FFleeLocations[J]).GetYhx, U.FUnitHS.GetXhx, U.FUnitHS.GetYhx) * 10,
                  0, 0, U, nil);
          end;
        I := 0;
        while I < Moves.Count do begin
          Move := Moves[I];
          if Move.MoveType = aiFake then begin
            Move.Free;
            Moves.Delete(I);
          end else begin
            if (Move.Value > -100000000) and (Move.Value < 100000000) then Inc(Move.Value, Move.GroupValue div 4);
            Inc(I);
          end;
        end;
        for I := 1 to Moves.Count - 1 do begin
          Move := Moves[I];
          J := 0;
          K := -1;
          while J < I do begin
            OtherMove := Moves[J];
            if OtherMove.Value < Move.Value then begin K := J; J := I; end else Inc(J);
          end;
          if K >= 0 then Moves.Move(I, K);
        end;
        Inc(CurrentMove);
      except MessageBox(0, 'Error - TCAI', 'Error during Add Group Bonuses', 0); end;
      5: try
        Moved := False;
        while (Moves.Count > 0) and not Moved do begin
          Move := Moves[0];
          case Move.MoveType of
            aiMove, aiMoveRanged: begin
              if ((Move.UnitHS.FUnit.FUnit is THero) or ((FSide = csAttacker) and (AoWCombatMap.FRound = 1))) and
                (Move.UnitHS.FUnit.FMovePoints > FMinMoves) then Move.UnitHS.FUnit.FMovePoints := FMinMoves;
              Settings := TCombatMoveControlSettings.Create(nil);
              Settings.SetSourcePos(Move.UnitHS.GetXhx, Move.UnitHS.GetYhx, Move.UnitHS.GetLhx);
              Settings.SetDestinationPos(Move.X, Move.Y, 0);
              Settings.FArmyHS := Move.UnitHS;
              if (Move.MoveType = aiMoveRanged) or (MeleeDamageTypes(Move.UnitHS.FUnit) = []) then
                Settings.FMoveFlags := 4 else Settings.FMoveFlags := 2;
              if AoWCombatMap.FCombat.FCombatData.FWallType <> 0 then
                if not (AoWCombatMap.FCombat.FCombatData.FWallBreached and
                  (AoWCombatMap.MapContainer.MapLevels[0].Field[Move.X, Move.Y].FindOwnedChild($220504) = nil) and
                  (AoWCombatMap.MapContainer.MapLevels[0].Field[Move.X, Move.Y].FindOwnedChild($220506) = nil)) then
                  if not FIgnoreWalls or not ChargeFromPos(Move.UnitHS.FUnit.FPosition shr 4) or (FSide = csAttacker) then
                    Settings.FMoveFlags := Settings.FMoveFlags or $10;
              Move.UnitHS.FUnit.FUnit.CreateMovePointTable(Settings.FMovePointTable);
              Settings.FPlayer := Move.UnitHS.FUnit.GetPlayer;
              AoWCombatMap.FMoveControl.ProcessMove(Settings);
              if (Settings.FPath.Count < 2) and (Settings.FMoveFlags and $10 = 0) then begin
                Settings.FMoveFlags := Settings.FMoveFlags or $10;
                AoWCombatMap.FMoveControl.ProcessMove(Settings);
              end;
              Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[Move.X, Move.Y].FindOwnedChild($220504));
              if Wall = nil then Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[Move.X, Move.Y].FindOwnedChild($220506));
              if (Settings.FPath.Count = 2) and (Move.MoveType = aiMoveRanged) and (Wall <> nil) then
                Move.UnitHS.FUnit.FMovePoints := 0
              else if Settings.FPath.Count > 1 then begin
                Path := Settings.FPath;
                PathCost := MakeTerrainPath(Settings, Path, TerrainCost, Move.UnitHS.FUnit, nil, False, False, 0);
                if (Path.Count > 1) and (PathCost >= 0) then
                  if (Path[Path.Count - 1].Flag <> 0) and (Path[Path.Count - 1].Flag <= Move.UnitHS.FUnit.FMovePoints) then begin
                    if Move.MoveType = aiMoveRanged then begin
                      Value := TMovepath(Path).PosToMovePoints(0);
                      if Value < Move.UnitHS.FUnit.FMovePoints then Move.UnitHS.FUnit.FMovePoints := Value;
                    end;
                    Value := TMovepath(Path).MovePointsToPos(Move.UnitHS.FUnit.FMovePoints);
                    Value := TMovepath(Path).PosToMovePoints(Value);
                    if (Value > 0) and (Value < Move.UnitHS.FUnit.FMovePoints) then Move.UnitHS.FUnit.FMovePoints := Value;
                    AoWEngine.OutputDebugStr('AI moves to X: ' + IntToStr(Move.X) + ' Y: ' + IntToStr(Move.X)); { Original repeats X. }
                    Moved := MoveCombatUnit(Move.UnitHS.FUnit, TMovepath(Path));
                    if Move.UnitHS.FUnit.FCombatPlayer = AoWCombatMap.FSeatedPlayer then
                      AoWCombatMap.MakeVisible(Move.UnitHS.GetXhx, Move.UnitHS.GetYhx, 0, 2);
                  end else Move.UnitHS.FUnit.FMovePoints := 0;
              end;
              Settings.Free;
            end;
            aiTouch: begin
              AoWHSSet.FAbilityControl.GetAbility(Move.Ability).GetCombatInfo(Move.UnitHS.FUnit.FUnit, AIInfo);
              Settings := TCombatMoveControlSettings.Create(nil);
              Settings.SetSourcePos(Move.UnitHS.GetXhx, Move.UnitHS.GetYhx, 0);
              Settings.SetDestinationPos(Move.X, Move.Y, 0);
              Settings.FArmyHS := Move.UnitHS;
              Settings.FMoveFlags := 2;
              if dtWall in AIInfo.DamageTypes then Settings.FMoveFlags := Settings.FMoveFlags or 1;
              Move.UnitHS.FUnit.FUnit.CreateMovePointTable(Settings.FMovePointTable);
              Settings.FPlayer := Move.UnitHS.FUnit.GetPlayer;
              Move.UnitHS.FSelectedAbility := Move.Ability;
              AoWCombatMap.FMoveControl.ProcessMove(Settings);
              if Settings.FPath.Count > 1 then begin
                Path := Settings.FPath;
                PathCost := MakeTerrainPath(Settings, Path, TerrainCost, Move.UnitHS.FUnit, nil, False, False, 1);
                if (Path.Count > 1) and (PathCost >= 0) then
                  if Path[Path.Count - 1].Flag <= Move.UnitHS.FUnit.FMovePoints then begin
                    Move.UnitHS.FSelectedAbility := Move.Ability;
                    AoWEngine.OutputDebugStr('AI melees at X: ' + IntToStr(Move.X) + ' Y: ' + IntToStr(Move.X));
                    Moved := Move.UnitHS.AbTouchMoveTC(TMovepath(Path));
                    if Move.UnitHS.FUnit.FCombatPlayer = AoWCombatMap.FSeatedPlayer then
                      AoWCombatMap.MakeVisible(Move.UnitHS.GetXhx, Move.UnitHS.GetYhx, 0, 2);
                  end;
              end;
              Settings.Free;
            end;
            aiMelee: begin
              Settings := TCombatMoveControlSettings.Create(nil);
              Settings.SetSourcePos(Move.UnitHS.GetXhx, Move.UnitHS.GetYhx, 0);
              Settings.SetDestinationPos(Move.X, Move.Y, 0);
              Settings.FArmyHS := Move.UnitHS;
              Settings.FMoveFlags := 2;
              Move.UnitHS.FUnit.FUnit.CreateMovePointTable(Settings.FMovePointTable);
              Settings.FPlayer := Move.UnitHS.FUnit.GetPlayer;
              AoWCombatMap.FMoveControl.ProcessMove(Settings);
              if Settings.FPath.Count > 1 then begin
                Path := Settings.FPath;
                PathCost := MakeTerrainPath(Settings, Path, TerrainCost, Move.UnitHS.FUnit, nil, False, False, 1);
                if (Path.Count > 1) and (PathCost >= 0) then
                  if Path[Path.Count - 1].Flag <= Move.UnitHS.FUnit.FMovePoints then begin
                    AoWEngine.OutputDebugStr('AI touches at X: ' + IntToStr(Move.X) + ' Y: ' + IntToStr(Move.X));
                    Moved := Move.UnitHS.MeleeMoveTC(TMovepath(Path));
                    if Move.UnitHS.FUnit.FCombatPlayer = AoWCombatMap.FSeatedPlayer then
                      AoWCombatMap.MakeVisible(Move.UnitHS.GetXhx, Move.UnitHS.GetYhx, 0, 2);
                  end;
              end;
              Settings.Free;
            end;
            aiRanged: begin
              Move.UnitHS.FSelectedAbility := Move.Ability;
              Move.UnitHS.FSelectedSpell := Move.Spell;
              AoWEngine.OutputDebugStr('AI ranged at X: ' + IntToStr(Move.X) + ' Y: ' + IntToStr(Move.X));
              Moved := Move.UnitHS.AbRangedTC(Move.X, Move.Y);
              if Move.UnitHS.FUnit.FCombatPlayer = AoWCombatMap.FSeatedPlayer then
                AoWCombatMap.MakeVisible(Move.UnitHS.GetXhx, Move.UnitHS.GetYhx, 0, 2);
            end;
          end;
          TObject(Moves[0]).Free;
          Moves.Delete(0);
        end;
        if not Moved then Status := aiDone;
        for I := 0 to Moves.Count - 1 do TObject(Moves[I]).Free;
        Moves.Clear;
        CurrentMove := 0;
      except MessageBox(0, 'Error - TCAI', 'Error during Execute Moves', 0); end;
    end;
end;

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
var
  U: TTacticalCombatUnit;
  I: Integer;
  Msg: TEMsg;
begin
  FCurrentCombatPlayer := Player;
  if Player = 0 then Inc(FRound);
  SetCurrentPlayer(FPlayers.GetPlayers(FCurrentCombatPlayer).FPlayer);
  FCombat.NewTurn(Byte(FCurrentCombatPlayer));
  FUnitSelection.Unselect;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(FCurrentPlayer);
  if FPlayers.GetPlayers(FCurrentCombatPlayer).FPlayer = 0 then
    ShowMessage(TranslateRStr(BeginRoundRStr) + ' ' + TranslateRStr(IndRStr))
  else ShowMessage(TranslateRStr(BeginRoundRStr) + ' ' +
    TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(FPlayers.GetPlayers(FCurrentCombatPlayer).FPlayer).FPlayerRace]));
  if AoWHSMap.FPlayers.GetPlayers(FPlayers.GetPlayers(FCurrentCombatPlayer).FPlayer).FPlayerType = ptHuman then
    if AoWHSMap.FPlayerCommunicator.PCC.GetPlayers(FPlayers.GetPlayers(FCurrentCombatPlayer).FPlayer).ConnectionMode <> cmRemote then begin
      SetSeatedCombatPlayer(FCurrentCombatPlayer);
      if FPlayers.GetPlayers(FCurrentCombatPlayer).FLastX = 0 then begin
        U := GetNextUnit(nil, True, True);
        if U <> nil then begin
          FPlayers.GetPlayers(FCurrentCombatPlayer).FLastX := U.FUnitHS.GetXhx;
          FPlayers.GetPlayers(FCurrentCombatPlayer).FLastY := U.FUnitHS.GetYhx;
          if FExplorationEnabled then
            for I := 0 to FPlayers.GetCount - 1 do
              if FCurrentCombatPlayer <> I then begin
                FPlayers.GetPlayers(I).FLastX := U.FUnitHS.GetXhx;
                FPlayers.GetPlayers(I).FLastY := U.FUnitHS.GetYhx;
              end;
        end;
      end;
      CenterViewTo(FPlayers.GetPlayers(FSeatedCombatPlayer).FLastX, FPlayers.GetPlayers(FSeatedCombatPlayer).FLastY, 0);
    end;
  PlaySample('Sfx\Events\NewEvent.wav');
  InitMsg(Msg, $20021001, Self);
  SendMsg(Msg, Self);
  if FExplorationEnabled then TriggerMapChangedEvent(Rect(0, 0, 65, 58), 0);
  FUnitSelection.Unselect;
  FChangeTurnEvents.TriggerNotifyEvents(TObject(Integer(FCurrentCombatPlayer)));
end;

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
var I: Integer; Effect: TfxHS;
begin
  if not (msEditting in Status) then begin
    I := 0;
    while I < FEffects.Count do begin
      Effect := FEffects[I];
      if Effect.FDone then begin
        DynamicFixedVisibleHS.RemoveChild(Effect);
        DynamicVisibleHS.RemoveChild(Effect);
        Effect.Free;
        FEffects.Delete(I);
      end else Inc(I);
    end;
  end;
  inherited NewFrame;
  if not (msEditting in Status) and (FCombat <> nil) then begin
    UpdateCursor;
    if FEndTurnPending and
      (((AoWHSMap.FPlayers.GetPlayers(FCurrentPlayer).FPlayerType <> ptHuman) and
        (AoWHSMap.FPlayerCommunicator.PCC.GetPlayers(FCombat.FHostPlayer).ConnectionMode <> cmRemote)) or
       (FPlayers.GetPlayers(FCurrentCombatPlayer).FAuto and
        (AoWHSMap.FPlayerCommunicator.PCC.GetPlayers(FCurrentPlayer).ConnectionMode <> cmRemote))) then
      case FAI.Status of
        aiIdle: begin
          AoWEngine.OutputDebugStr('AI for Player ' + IntToStr(FCurrentPlayer) + ' turn begins.');
          FAI.BeginTurn;
        end;
        aiBusy: FAI.ContinueTurn;
        aiDone: if EndTurn(True) then begin
          FAI.Status := aiIdle;
          AoWEngine.OutputDebugStr('AI for Player ' + IntToStr(FCurrentPlayer) + ' turn ends.');
        end;
      end;
  end;
end;

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
  if not (((FSeatedPlayer = -1) or AoWHSMap.FTokenManager.PlayerReady(FSeatedPlayer)) and
    (FSeatedPlayer = FCurrentPlayer) and not FPlayers.GetPlayers(FCurrentCombatPlayer).FAuto and
    (AoWCombatMap.FSeatedCombatPlayer = AoWCombatMap.FCurrentCombatPlayer)) then Mouse.Cursor := (Frame div 4) mod 4 + 6
  else begin
    if FUnitSelection.GetTCUnitHS <> nil then FUnitSelection.UpdateMoveCursor;
    case Mouse.CursorMode of
      0: Mouse.Cursor := 0;
      $101: Mouse.Cursor := (Frame div 4) mod 4 + $34;
      $102: Mouse.Cursor := (Frame div 4) mod 2 + $31;
    end;
  end;
end;
procedure TAoWCombatMap.EndCombat(Sender: TObject);
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
var ItemHS: TItemHS; Items: TECustomNode; I: Integer;
begin
  FItems.FOnChanged := nil;
  if AoWCombatMap.FCombat.FExplorationSite = 1 then begin
    Items := TECustomNode(AoWCombatMap.FCombat.FItems);
    for I := FItems.GetCount - 1 downto 0 do FItems.GetItem(I).SetOwner(Items);
  end else begin
    ItemHS := TItemHS(AoWHSMap.MapContainer.GetField(AoWCombatMap.FCombat.FCombatData.FX,
      AoWCombatMap.FCombat.FCombatData.FY, AoWCombatMap.FCombat.FCombatData.FL).FindOwnedChild($20271));
    if ItemHS = nil then begin
      ItemHS := TItemHS.Create(nil);
      AoWHSMap.PlaceHX(ItemHS, AoWCombatMap.FCombat.FCombatData.FX, AoWCombatMap.FCombat.FCombatData.FY, AoWCombatMap.FCombat.FCombatData.FL);
    end;
    for I := FItems.GetCount - 1 downto 0 do FItems.GetItem(I).SetOwner(ItemHS.FItems);
  end;
  inherited Deactivate;
end;

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
var
  Corpse: TCCorpseHS;
  Sequence: TImageSequence;
  Effect: TfxHS;
  Speed, VZ, Gravity, Z: Single;
  J, X, Y, I: Integer;
  R: TRect;

  procedure MakeBlood;
  var Count, X, Y, Direction: Integer;
      Blood: TCBloodHS;
  begin
    if GetEnabled and (FUnitHS <> nil) and (FUnit.GetBloodType <> btNone) then begin
      if (A1 >= GetHitPoints) and (GetAbilityEnabled($83) or (FDeathMethod = dmExplode)) then
        Count := Random(5) + 10
      else Count := Random(A1 + 7) - 4;
      while Count > 0 do begin
        Direction := Random(12);
        if Direction > 6 then Direction := 0;
        CenterHNtoHX(FUnitHS.GetXhx, FUnitHS.GetYhx, Direction, X, Y);
        if (AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].TerrainType <> 0) and
          (AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].TerrainType <> 9) then begin
          Blood := TCBloodHS.Create(AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y]);
          Blood.Activate;
          Blood.FOffsetX := Random(32) - 32;
          Blood.FOffsetY := Random(32) - 32;
          Blood.FFrame := Random(AoWHSSet.FImageSequences.ImageSequences[4].GetTotalSequenceFrames);
        end;
        Dec(Count);
      end;
    end;
  end;

begin
  MakeBlood;
  Result := inherited ExecuteDamage(A1);
  if not GetEnabled then begin
    if FUnitHS <> nil then begin
      if GetAbilityEnabled($83) then begin
        MakeHitBlood(Self, 100);
        for I := 0 to 9 do begin
          Effect := AoWCombatMap.AddEffect(fxDecayComet);
          Effect.FAbilityIndex := $34;
          Effect.FSpellIndex := $6A;
          HXtoHP(FUnitHS.GetXhx, FUnitHS.GetYhx, X, Y);
          Effect.FPath.Add(TXYZ.Create);
          Effect.FPath[0].X := X + 16;
          Effect.FPath[0].Y := Y + 8;
          for J := 0 to 10 do begin
            VZ := (Random(50) + 50) * 0.05;
            Gravity := 1.5;
            Speed := (Random(25) + 25) * 0.05;
            Z := 0;
            MakeArcPath(Effect.FPath[Effect.FPath.Count - 1].X,
              Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z,
              Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
          end;
        end;
      end else begin
        if (AoWCombatMap.MapContainer.MapLevels[0].Field[FUnitHS.GetXhx, FUnitHS.GetYhx].TerrainType <> 0) and
          (AoWCombatMap.MapContainer.MapLevels[0].Field[FUnitHS.GetXhx, FUnitHS.GetYhx].TerrainType <> 9) then begin
          Corpse := TCCorpseHS.Create(AoWCombatMap.MapContainer.MapLevels[0].Field[FUnitHS.GetXhx, FUnitHS.GetYhx]);
          Corpse.FUnitGFX := FUnitHS.FUnitGFXResource;
          Sequence := Corpse.FUnitGFX.FSequences.ImageSequences[30];
          if Sequence <> nil then Corpse.FFrame := Random(Sequence.GetTotalSequenceFrames);
          if FDeathMethod = dmNormal then begin
            if FUnit.GetBloodType = btNone then Corpse.FSequenceIndex := -1
            else begin
              Corpse.FSequenceIndex := (Ord(FUnit.GetUnitSize) and $7F) + 30;
              if Corpse.FSequenceIndex > 32 then Corpse.FSequenceIndex := 32;
            end;
          end else if FDeathMethod = dmExplode then Corpse.FSequenceIndex := -1;
          Corpse.FOffsetX := Random(10) - 5;
          Corpse.FOffsetY := Random(10) - 5;
          if FUnit.GetUnitType <> utMachine then Corpse.FUnit := Self;
          Corpse.Activate;
        end;
      end;
      R := Rect(FUnitHS.GetXhx, FUnitHS.GetYhx, FUnitHS.GetXhx + 1, FUnitHS.GetYhx + 1);
      FUnitHS.Free;
      FUnitHS := nil;
      AoWCombatMap.TriggerMapChangedEvent(R, 0);
    end;
  end else if FUnitHS <> nil then FUnitHS.SetUnitGFXResourceIndex(FUnit.GetUnitGFXResourceIndex);
end;

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
var I, X, Y, X1, Y1, X2, Y2, PX, PY: Integer;
    UnitHS: TTacticalCombatUnitHS; Field: TMapField; Level: TMapLevel; Units: TList; R: TRect;
begin
  Units := TList.Create;
  R := TAbstractAoWHSMapMouse(Sender).FSelectionRectangle;
  Level := AoWCombatMap.MapContainer.MapLevels[AoWCombatMap.ViewL];
  HPtoHX(R.Left, R.Top, X1, Y1); HPtoHX(R.Right, R.Bottom, X2, Y2);
  for X := X1 - 1 to X2 + 1 do
    for Y := Y1 - 1 to Y2 + 1 do begin
      HXtoHP(X, Y, PX, PY); Inc(PX, 16); Inc(PY, 8);
      if (X >= 0) and (X < Level.Width) and (Y > 0) and (Y < Level.Height) and
        (PX >= R.Left) and (PX < R.Right) and (PY >= R.Top) and (PY < R.Bottom) then begin
        Field := Level.Field[X, Y];
        UnitHS := TTacticalCombatUnitHS(Field.FindOwnedChild($220104));
        if (UnitHS <> nil) and (UnitHS.FUnit.FCombatPlayer = AoWCombatMap.FSeatedCombatPlayer) then Units.Add(UnitHS);
      end;
    end;
  if Units.Count <> 0 then begin
    Clear; AoWCombatMap.Selection.UnselectLocation;
    for I := 0 to Units.Count - 1 do begin
      AddUnit(TTacticalCombatUnitHS(Units[I]));
      AoWCombatMap.Selection.SelectLocationHS(THexagonSprite(Units[I]));
    end;
    if Units.Count = 1 then SetCurrentMove(0) else SetCurrentMove(-1);
    Update;
  end;
  Units.Free;
end;

procedure TCombatUnitSelectionControl.MoveSelectionEvent(Sender: TObject);
begin
  if AoWCombatMap.FSeatedCombatPlayer = AoWCombatMap.FCurrentCombatPlayer then
    if AoWCombatMap.Mouse.Capture <> Self then AoWCombatMap.Selection.UnselectLocation
    else begin
      if AoWCombatMap.Mouse.Button = mbRight then
        if FRangedPath.Count = 0 then AoWCombatMap.Selection.UnselectLocation
        else begin
          FRangedPath.Clear;
          FMouseOverTarget := nil;
          AoWCombatMap.FUnitChangedEvents.TriggerNotifyEvents(FMouseOverTarget);
        end
      else if (AoWCombatMap.Mouse.Capture = Self) and (AoWCombatMap.Mouse.Button = mbLeft) then ExecuteMoveSelection;
    end;
end;

procedure TCombatUnitSelectionControl.CalculateMovePath(Index: Integer; X, Y, L: Shortint);
var
  UnitHS: TTacticalCombatUnitHS;
  I: Integer;
  Temporary: TList;
  Movement: TMovementHS;
begin
  with FMoveSettingsList.GetMoveSettings(Index) do begin
  Temporary := TList.Create;
  if FMoveSettingsList.GetCount > 0 then
    for I := 0 to FMoveSettingsList.GetCount - 1 do
      if I <> Index then
        if FMoveSettingsList.GetMoveSettings(I).FPath.Count > 1 then begin
          Movement := TMovementHS.Create(nil);
          AoWCombatMap.PlaceHX(Movement,
            FMoveSettingsList.GetMoveSettings(I).FPath[FMoveSettingsList.GetMoveSettings(I).FPath.Count - 1].X,
            FMoveSettingsList.GetMoveSettings(I).FPath[FMoveSettingsList.GetMoveSettings(I).FPath.Count - 1].Y, 0);
          Movement.FEnabled := True;
          Temporary.Add(Movement);
          Movement := TMovementHS.Create(nil);
          AoWCombatMap.PlaceHX(Movement, FMoveSettingsList.GetMoveSettings(I).FPath[0].X,
            FMoveSettingsList.GetMoveSettings(I).FPath[0].Y, 0);
          Movement.FEnabled := False;
          Temporary.Add(Movement);
        end;
  FPathMovePoints := 0;
  UnitHS := TTacticalCombatUnitHS(FMoveObject);
  if (GetTCUnitHS <> nil) and ((GetTCUnitHS.FSelectedAbility = $75) or (GetTCUnitHS.FSelectedAbility = $41)) then
    TCombatMoveControlSettings(FMoveControlSettings).FMoveFlags := Byte(FPathInvalid) or 1
  else TCombatMoveControlSettings(FMoveControlSettings).FMoveFlags := Byte(FPathInvalid);
  FMoveControlSettings.Reset;
  FMoveControlSettings.SetSourcePos(UnitHS.GetXhx, UnitHS.GetYhx, UnitHS.GetLhx);
  FMoveControlSettings.FPlayer := UnitHS.FUnit.GetPlayer;
  FMoveControlSettings.FArmyHS := UnitHS;
  FMoveControlSettings.FSelection := 0;
  FMoveControlSettings.SetDestinationPos(X, Y, L);
  UnitHS.FUnit.FUnit.CreateMovePointTable(FMoveControlSettings.FMovePointTable);
  AoWCombatMap.FMoveControl.ProcessMove(FMoveControlSettings);
  FMoveSettingsList.GetMoveSettings(Index).FPath.Assign(FMoveControlSettings.FPath);
  FMoveSettingsList.GetMoveSettings(Index).FMovePoints := UnitHS.FUnit.FMovePoints;
  FMoveSettingsList.GetMoveSettings(Index).FMoves := UnitHS.FUnit.GetMoves;
  if FMoveControlSettings.FPath.Count <> 0 then begin
    for I := 0 to FMoveControlSettings.FPath.Count - 2 do
      if (AoWCombatMap.MapContainer.MapLevels[0].Field[FMoveControlSettings.FPath[I].X,
        FMoveControlSettings.FPath[I].Y].FindOwnedChild($220504) <> nil) or
        (AoWCombatMap.MapContainer.MapLevels[0].Field[FMoveControlSettings.FPath[I].X,
        FMoveControlSettings.FPath[I].Y].FindOwnedChild($220506) <> nil) then
        FPath.List^[I].Flag := FMoveControlSettings.FMovePointTable[
          AoWCombatMap.MapContainer.MapLevels[0].Field[FMoveControlSettings.FPath[I].X,
          FMoveControlSettings.FPath[I].Y].TerrainType, -1]
      else
        FPath.List^[I].Flag := FMoveControlSettings.FMovePointTable[
          AoWCombatMap.MapContainer.MapLevels[0].Field[FMoveControlSettings.FPath[I].X,
          FMoveControlSettings.FPath[I].Y].TerrainType,
          AoWCombatMap.MapContainer.MapLevels[0].Field[FMoveControlSettings.FPath[I].X,
          FMoveControlSettings.FPath[I].Y].OverlayType];
    FPathMovePoints := FPath.PosToMovePoints(0);
    FMoveControlSettings.FPath.Clear;
  end;
  for I := 0 to Temporary.Count - 1 do TObject(Temporary[I]).Free;
  Temporary.Free;
  end;
end;

procedure TCombatUnitSelectionControl.CalculateRangedPath(X, Y: Shortint);
var UnitHS: TTacticalCombatUnitHS; Range: Word; Info: TSpellCombatInfo; Direction, NX, NY: Integer;
begin
  FRangedPath.Clear;
  for Direction := 0 to FObstacles.Count - 1 do TObject(FObstacles[Direction]).Free;
  FObstacles.Clear;
  UnitHS := GetTCUnitHS;
  if AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].TerrainType <> 15 then begin
    if UnitHS.FSelectedAbility = $34 then begin
      AoWHSSet.FSpellControl.GetSpell(UnitHS.FSelectedSpell).GetCombatInfo(UnitHS.FUnit.FUnit, Info);
      if Info.Range < 1 then Range := 100 else Range := Info.Range;
    end else if AoWHSSet.FAbilityControl.GetAbility(UnitHS.FSelectedAbility).GetCombatMode(GetTCUnitHS.FUnit.FUnit) = cmLongRange then Range := 12
    else if AoWHSSet.FAbilityControl.GetAbility(UnitHS.FSelectedAbility).GetCombatMode(GetTCUnitHS.FUnit.FUnit) = cmMediumRange then Range := 8 else Range := 4;
    if (UnitHS.FUnit.GetMoves = UnitHS.FUnit.FMovePoints) and (X > 0) and (dHXtoRad(X, Y, UnitHS.GetXhx, UnitHS.GetYhx) <= Range) then begin
      GetTCUnitHS;
      FTargetX := X; FTargetY := Y;
      Direction := dHXtoHN(UnitHS.GetXhx, UnitHS.GetYhx, X, Y);
      NX := X; NY := Y;
      case GetTCUnitHS.FSelectedAbility of
        $1E, $56..$5A: CenterHNtoHX(UnitHS.GetXhx, UnitHS.GetYhx, BreathHN[BreathDirection[Direction] * 12 - 12], NX, NY);
        $34: if SpellTypes[UnitHS.FSelectedSpell] = fxBreath then
          CenterHNtoHX(UnitHS.GetXhx, UnitHS.GetYhx, BreathHN[BreathDirection[Direction] * 12 - 12], NX, NY);
      end;
      MakeAbilPath(GetTCUnitHS.FUnit.GetSide, GetTCUnitHS.FSelectedAbility, GetTCUnitHS.FSelectedSpell,
        GetTCUnitHS.GetXhx, GetTCUnitHS.GetYhx, NX, NY, FRangedPath, FObstacles);
    end;
  end;
  FRangedPathHS.FSelection := Self;
  AoWCombatMap.DynamicFixedVisibleHS.AddChild(FRangedPathHS);
end;

procedure TCombatUnitSelectionControl.MoveSelectedRoute;
var UnitHS: TTacticalCombatUnitHS; Target: TEObject; MovePoints: Integer;
begin
  if FMoveSettingsList.GetCount > 0 then
    if GetTCUnitHS <> nil then
      if FMoveSettingsList.GetMoveSettings(0).FPath.Count > 0 then
        with FMoveSettingsList.GetMoveSettings(0) do begin
          UnitHS := GetTCUnitHS;
          if UnitHS.FSelectedAbility <> $75 then
            Target := AoWCombatMap.MapContainer.MapLevels[0].Field[FPath[0].X, FPath[0].Y].FindOwnedChild($220104)
          else begin
            Target := AoWCombatMap.MapContainer.MapLevels[0].Field[FPath[0].X, FPath[0].Y].FindOwnedChild($220504);
            if Target = nil then Target := AoWCombatMap.MapContainer.MapLevels[0].Field[FPath[0].X, FPath[0].Y].FindOwnedChild($220506);
          end;
          if (FMoveSettingsList.GetMoveSettings(0).FPath.MovePointsToPos(UnitHS.FUnit.FMovePoints) = 0) and
            ((Target <> nil) or (UnitHS.FSelectedAbility = $41) or (UnitHS.FSelectedAbility = $72)) then begin
            MovePoints := GetTCUnitHS.FUnit.FMovePoints;
            if MovePoints > 0 then
              if UnitHS.FSelectedAbility = -1 then begin
                if GetTCUnitHS.MeleeMoveTC(FPath) then FPath.Clear;
              end else if AoWHSSet.FAbilityControl.GetAbility(UnitHS.FSelectedAbility).GetCombatMode(UnitHS.FUnit.FUnit) = cmTouch then
                if GetTCUnitHS.AbTouchMoveTC(FPath) then begin FPath.Clear; UpdateMoveCursor; end;
          end else if MoveCombatUnit(UnitHS.FUnit, FPath) then FPath.Clear;
        end;
end;
procedure TCombatUnitSelectionControl.MoveUnits;
var I: Integer;
begin
  if FMoveSettingsList.GetCount > 0 then
    if FMoveSettingsList.GetCount > 1 then begin
      if SetupMultiTCUnitMove(FMoveSettingsList) then
        for I := 0 to FMoveSettingsList.GetCount - 1 do with FMoveSettingsList.GetMoveSettings(I) do FPath.Clear;
      AoWCombatMap.Selection.UnselectLocation;
      DeactivateMoveSelection;
      Clear;
    end else MoveSelectedRoute;
end;

procedure TCombatUnitSelectionControl.ExecuteMoveSelection;
var
  UnitHS: TTacticalCombatUnitHS;
  EffectType: TfxType;
  I, X, Y: Integer;
  Settings: TMoveSettings;
  A, B: Integer;

  function AllPathsValid: Boolean;
  var I: Integer;
  begin
    Result := (FMoveSettingsList.GetMoveSettings(0).FPath.Count > 0) and
      (FMoveSettingsList.GetMoveSettings(0).FPath[0].X = AoWCombatMap.Mouse.Xhx) and
      (FMoveSettingsList.GetMoveSettings(0).FPath[0].Y = AoWCombatMap.Mouse.Yhx);
    I := FMoveSettingsList.GetCount;
    while Result and (I <> 0) do begin
      Dec(I);
      with FMoveSettingsList.GetMoveSettings(I) do Result := FPath.Count <> 0;
    end;
  end;

begin
  DeactivateRangedPath;
  if FMoveSettingsList.GetCount <= 1 then begin
    if (GetTCUnitHS.FSelectedAbility = -1) and (GetTCUnitHS.GetXhx = AoWCombatMap.Mouse.Xhx) and
      (GetTCUnitHS.GetYhx = AoWCombatMap.Mouse.Yhx) then begin
      AoWCombatMap.Selection.SelectLocationHX(GetTCUnitHS.GetXhx, GetTCUnitHS.GetYhx, GetTCUnitHS.GetLhx);
      Exit;
    end;
    if not GetTCUnitHS.FUnit.GetLocked and AoWHSMap.FTokenManager.PlayerReady(AoWCombatMap.FCurrentPlayer) then begin
      UnitHS := GetTCUnitHS;
      if AllPathsValid then MoveUnits
      else if (FRangedPath.Count > 0) and (FTargetX = AoWCombatMap.Mouse.Xhx) and (FTargetY = AoWCombatMap.Mouse.Yhx) then begin
        if UnitHS.AbRangedTC(FTargetX, FTargetY) then begin
          FRangedPath.Clear;
          UpdateMoveCursor;
        end;
      end else begin
        if (UnitHS.FSelectedAbility = -1) and (UnitHS.GetXhx = AoWCombatMap.Mouse.Xhx) and
          (UnitHS.GetYhx = AoWCombatMap.Mouse.Yhx) then begin
          AoWCombatMap.Selection.SelectLocationHX(UnitHS.GetXhx, UnitHS.GetYhx, UnitHS.GetLhx);
          Exit;
        end;
        if not UnitHS.Moving then
          if UnitHS.FSelectedAbility = -1 then begin
            if (UnitHS.FUnit.FMovePoints > 0) and not UnitHS.FUnit.GetLocked then begin
              if AoWCombatMap.FExplorationEnabled then
                if not TAoWMapField(AoWCombatMap.MapContainer.GetField(AoWCombatMap.Mouse.Xhx,
                  AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL)).GetExplored(AoWCombatMap.FSeatedPlayer) then Exit;
              CalculateMovePath(FCurrentMove, AoWCombatMap.Mouse.Xhx, AoWCombatMap.Mouse.Yhx, 0);
            end;
          end else begin
            if UnitHS.FSelectedAbility = $34 then EffectType := SpellTypes[UnitHS.FSelectedSpell]
            else EffectType := AbilTypes[UnitHS.FSelectedAbility];
            if EffectType = fxNone then UnitHS.SelectAbility(-1)
            else if EffectType = fxTouch then begin
              if AoWCombatMap.FExplorationEnabled then
                if not TAoWMapField(AoWCombatMap.MapContainer.GetField(AoWCombatMap.Mouse.Xhx,
                  AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL)).GetExplored(AoWCombatMap.FSeatedPlayer) then Exit;
              if not UnitHS.FUnit.GetLocked then CalculateMovePath(0, AoWCombatMap.Mouse.Xhx, AoWCombatMap.Mouse.Yhx, 0);
            end else begin
              CalculateRangedPath(AoWCombatMap.Mouse.Xhx, AoWCombatMap.Mouse.Yhx);
              if FRangedPath.Count > 0 then begin
                FMouseOverTarget := THexagonSprite(AoWCombatMap.MapContainer.MapLevels[0].Field[AoWCombatMap.Mouse.Xhx,
                  AoWCombatMap.Mouse.Yhx].FindOwnedChild($220104));
                AoWCombatMap.FUnitChangedEvents.TriggerNotifyEvents(FMouseOverTarget);
              end;
            end;
          end;
      end;
    end;
  end else if FCurrentMove = -1 then begin
    if AllPathsValid then MoveUnits
    else begin
      if AoWCombatMap.FExplorationEnabled then
        if not TAoWMapField(AoWCombatMap.MapContainer.GetField(AoWCombatMap.Mouse.Xhx,
          AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL)).GetExplored(AoWCombatMap.FSeatedPlayer) then begin
          for I := 0 to FMoveSettingsList.GetCount - 1 do FMoveSettingsList.GetMoveSettings(I).FPath.Clear;
          Exit;
        end;
      for I := 0 to FMoveSettingsList.GetCount - 1 do FMoveSettingsList.GetMoveSettings(I).FPath.Clear;
      for A := 0 to FMoveSettingsList.GetCount - 1 do
        for B := A + 1 to FMoveSettingsList.GetCount - 1 do
          if dHXtoRad(AoWCombatMap.Mouse.Xhx, AoWCombatMap.Mouse.Yhx,
            THexagonSprite(FMoveSettingsList.GetMoveSettings(B).FMoveObject).GetXhx,
            THexagonSprite(FMoveSettingsList.GetMoveSettings(B).FMoveObject).GetYhx) <
            dHXtoRad(AoWCombatMap.Mouse.Xhx, AoWCombatMap.Mouse.Yhx,
            THexagonSprite(FMoveSettingsList.GetMoveSettings(A).FMoveObject).GetXhx,
            THexagonSprite(FMoveSettingsList.GetMoveSettings(A).FMoveObject).GetYhx) then
            FMoveSettingsList.FChildren.Exchange(A, B);
      if not TTacticalCombatUnitHS(FMoveSettingsList.GetMoveSettings(0).FMoveObject).FUnit.GetLocked then
        CalculateMovePath(0, AoWCombatMap.Mouse.Xhx, AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL)
      else FMoveSettingsList.GetMoveSettings(0).FPath.Clear;
      if FMoveSettingsList.GetMoveSettings(0).FPath.Count > 1 then
        for I := 1 to FMoveSettingsList.GetCount - 1 do
          if not TTacticalCombatUnitHS(FMoveSettingsList.GetMoveSettings(I).FMoveObject).FUnit.GetLocked then begin
            CenterHNtoHX(FMoveSettingsList.GetMoveSettings(0).FPath[0].X, FMoveSettingsList.GetMoveSettings(0).FPath[0].Y,
              dHXtoHN(THexagonSprite(FMoveSettingsList.GetMoveSettings(0).FMoveObject).GetXhx,
                THexagonSprite(FMoveSettingsList.GetMoveSettings(0).FMoveObject).GetYhx,
                THexagonSprite(FMoveSettingsList.GetMoveSettings(I).FMoveObject).GetXhx,
                THexagonSprite(FMoveSettingsList.GetMoveSettings(I).FMoveObject).GetYhx), X, Y);
            CalculateMovePath(I, X, Y, 0);
          end else FMoveSettingsList.GetMoveSettings(I).FPath.Clear;
    end;
  end else begin
    with FMoveSettingsList.GetMoveSettings(FCurrentMove) do
      if (FPath.Count <> 0) and (FPath[0].X = AoWCombatMap.Mouse.Xhx) and
        (FPath[0].Y = AoWCombatMap.Mouse.Yhx) and (FPath[0].L = AoWCombatMap.ViewL) then begin
        MoveUnits;
        Exit;
      end;
    if not TTacticalCombatUnitHS(FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject).FUnit.GetLocked then
      CalculateMovePath(FCurrentMove, AoWCombatMap.Mouse.Xhx, AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL)
    else FMoveSettingsList.GetMoveSettings(FCurrentMove).FPath.Clear;
  end;
end;

function TCombatUnitSelectionControl.ValidMultiMoveSelection(Field: TAoWMapField): Boolean;
var Player: Shortint;
begin
  Player := Field.GetPlayer;
  Result := Player = -1;
end;

procedure TCombatUnitSelectionControl.MouseDownEvent(Sender: TObject);
var
  UnitHS: TTacticalCombatUnitHS;
  Index, DX, DY: Integer;
  Targets: TCombatTargetType;
  SpellInfo: TSpellCombatInfo;
  AbilityInfo: TAbilityCombatInfo;
begin
  if AoWCombatMap.FSeatedCombatPlayer = AoWCombatMap.FCurrentCombatPlayer then begin
    if not AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FAuto then
      if AoWCombatMap.Mouse.Button = mbRight then begin
        if (GetTCUnitHS <> nil) and (GetTCUnitHS.FSelectedAbility >= 0) then begin
          GetTCUnitHS.SelectAbility(-1);
          Exit;
        end;
        Unselect;
      end else if ssShift in AoWCombatMap.Mouse.Shift then begin
        if (FMoveSettingsList.GetCount = 1) and (FMoveSettingsList.GetMoveSettings(0).FPath.Count <> 0) then
          if not ValidMultiMoveSelection(TAoWMapField(AoWCombatMap.MapContainer.GetField(FMoveSettingsList.GetMoveSettings(0).FPath[0].X,
            FMoveSettingsList.GetMoveSettings(0).FPath[0].Y, FMoveSettingsList.GetMoveSettings(0).FPath[0].L))) then Exit;
        if AoWCombatMap.Mouse.Xhx <> -1 then begin
          UnitHS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.GetField(AoWCombatMap.Mouse.Xhx,
            AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL).FindOwnedChild($220104));
          if (UnitHS <> nil) and (UnitHS.FUnit.FCombatPlayer = AoWCombatMap.FSeatedCombatPlayer) then begin
            Index := FMoveSettingsList.IndexOfMoveObject(UnitHS);
            if Index = -1 then begin
              AddUnit(UnitHS);
              Update;
              AoWCombatMap.Selection.SelectLocationHS(UnitHS);
              if not UnitHS.FUnit.GetLocked then begin
                if FMoveSettingsList.GetMoveSettings(0).FPath.Count > 0 then begin
                  DX := UnitHS.GetXhx - FMoveSettingsList.GetMoveSettings(0).FPath[FMoveSettingsList.GetMoveSettings(0).FPath.Count - 1].X;
                  DY := UnitHS.GetYhx - FMoveSettingsList.GetMoveSettings(0).FPath[FMoveSettingsList.GetMoveSettings(0).FPath.Count - 1].Y;
                  CalculateMovePath(FMoveSettingsList.IndexOfMoveObject(UnitHS),
                    FMoveSettingsList.GetMoveSettings(0).FPath[0].X + DX, FMoveSettingsList.GetMoveSettings(0).FPath[0].Y + DY, 0);
                end;
              end else FMoveSettingsList.GetMoveSettings(FMoveSettingsList.IndexOfMoveObject(UnitHS)).FPath.Clear;
              SetCurrentMove(-1);
            end else begin
              UnitHS.Unselect;
              DeleteMoveObject(Index);
              SetCurrentMove(FMoveSettingsList.GetCount - 1);
              Update;
            end;
          end;
        end;
      end else if ssCtrl in AoWCombatMap.Mouse.Shift then begin
        if (FMoveSettingsList.GetCount > 0) and (AoWCombatMap.Mouse.Xhx <> -1) then begin
          UnitHS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.GetField(AoWCombatMap.Mouse.Xhx,
            AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL).FindOwnedChild($220104));
          if (UnitHS <> nil) and (UnitHS.FUnit.FCombatPlayer = AoWCombatMap.FSeatedCombatPlayer) then begin
            Index := FMoveSettingsList.IndexOfMoveObject(UnitHS);
            if Index = -1 then begin
              AddUnit(UnitHS);
              Update;
              AoWCombatMap.Selection.SelectLocationHS(UnitHS);
              if not UnitHS.FUnit.GetLocked then begin
                if FMoveSettingsList.GetMoveSettings(0).FPath.Count > 0 then begin
                  DX := UnitHS.GetXhx - FMoveSettingsList.GetMoveSettings(0).FPath[FMoveSettingsList.GetMoveSettings(0).FPath.Count - 1].X;
                  DY := UnitHS.GetYhx - FMoveSettingsList.GetMoveSettings(0).FPath[FMoveSettingsList.GetMoveSettings(0).FPath.Count - 1].Y;
                  CalculateMovePath(FMoveSettingsList.IndexOfMoveObject(UnitHS),
                    FMoveSettingsList.GetMoveSettings(0).FPath[0].X + DX, FMoveSettingsList.GetMoveSettings(0).FPath[0].Y + DY, 0);
                end;
              end else FMoveSettingsList.GetMoveSettings(FMoveSettingsList.IndexOfMoveObject(UnitHS)).FPath.Clear;
              SetCurrentMove(FMoveSettingsList.IndexOfMoveObject(UnitHS));
            end else if FCurrentMove = Index then SetCurrentMove(-1)
            else begin SetCurrentMove(Index); Update; end;
          end;
        end;
      end else
        if AoWCombatMap.Mouse.Xhx <> -1 then
          if GetTCUnitHS = nil then ExecuteMoveSelection
          else begin
            UnitHS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.GetField(AoWCombatMap.Mouse.Xhx,
              AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL).FindOwnedChild($220104));
            if GetTCUnitHS.FSelectedAbility = -1 then Targets := [cttEnemy]
            else if GetTCUnitHS.FSelectedAbility = $34 then begin
              AoWHSSet.FSpellControl.GetSpell(GetTCUnitHS.FSelectedSpell).GetCombatInfo(GetTCUnitHS.FUnit.FUnit, SpellInfo);
              Targets := SpellInfo.TargetTypes;
            end else begin
              AoWHSSet.FAbilityControl.GetAbility(GetTCUnitHS.FSelectedAbility).GetCombatInfo(GetTCUnitHS.FUnit.FUnit, AbilityInfo);
              Targets := AbilityInfo.TargetTypes;
            end;
            if UnitHS = nil then ExecuteMoveSelection
            else if (UnitHS.FUnit.GetPlayer = GetTCUnitHS.FUnit.GetPlayer) and not (cttFriend in Targets) then begin
              AoWCombatMap.Selection.UnselectLocation;
              AoWCombatMap.Selection.SelectLocationHS(UnitHS);
            end else if ((UnitHS.FUnit.GetPlayer = GetTCUnitHS.FUnit.GetPlayer) and (cttFriend in Targets)) or
              ((UnitHS.FUnit.GetPlayer <> GetTCUnitHS.FUnit.GetPlayer) and (cttEnemy in Targets)) then ExecuteMoveSelection;
          end;
  end else begin
    UnitHS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.GetField(AoWCombatMap.Mouse.Xhx,
      AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL).FindOwnedChild($220104));
    AoWCombatMap.Selection.UnselectLocation;
    if (UnitHS <> nil) and (AoWCombatMap.Mouse.Button = mbLeft) then AoWCombatMap.Selection.SelectLocationHS(UnitHS);
  end;
end;

procedure TCombatUnitSelectionControl.UpdateMoveCursor;
label FinishCursor;
var
  Field: TAoWMapField;
  Cost: Integer;
  UnitHS, TargetHS: TTacticalCombatUnitHS;
  Targets: TCombatTargetType;
  Wall: TCityWall;
  SpellInfo: TSpellCombatInfo;
  AbilityInfo: TAbilityCombatInfo;
begin
  if AoWCombatMap = nil then Exit;
  UnitHS := GetTCUnitHS;
  AoWCombatMap.Mouse.CursorMode := 0;
  if AoWCombatMap.Mouse.Xhx = -1 then Exit;
  if AoWCombatMap.Mouse.Yhx = -1 then Exit;
  if UnitHS = nil then Exit;
  Field := TAoWMapField(AoWCombatMap.MapContainer.GetField(AoWCombatMap.Mouse.Xhx, AoWCombatMap.Mouse.Yhx, AoWCombatMap.ViewL));
  if AoWCombatMap.FExplorationEnabled and not Field.GetExplored(AoWCombatMap.FSeatedPlayer) then goto FinishCursor;
  TargetHS := TTacticalCombatUnitHS(Field.FindOwnedChild($220104));
  if (UnitHS.FUnit.FCombatPlayer <> AoWCombatMap.FSeatedCombatPlayer) and (TargetHS <> nil) then begin
    AoWCombatMap.Mouse.CursorMode := $101; goto FinishCursor;
  end;
  if UnitHS.FSelectedAbility < 0 then begin
    if (TargetHS <> nil) and (TargetHS <> UnitHS) then
      if TargetHS.FUnit.GetPlayer = UnitHS.FUnit.GetPlayer then AoWCombatMap.Mouse.CursorMode := $101
      else if not UnitHS.FUnit.GetAbilityEnabled(1) and TargetHS.FUnit.GetAbilityEnabled(1) then begin
        FCursorImage := $59;
        AoWCombatMap.Mouse.CursorMode := $100;
        AoWCombatMap.Mouse.Cursor := FCursorImage;
      end else AoWCombatMap.Mouse.CursorMode := $102;
    goto FinishCursor;
  end;
  Inc(FCursorFrame);
  if FCursorFrame > 4 then begin FCursorFrame := 0; Inc(FCursorImage); end;
  if UnitHS.FSelectedAbility = $34 then begin
    AoWHSSet.FSpellControl.GetSpell(UnitHS.FSelectedSpell).GetCombatInfo(UnitHS.FUnit.FUnit, SpellInfo);
    Targets := SpellInfo.TargetTypes;
  end else begin
    AoWHSSet.FAbilityControl.GetAbility(UnitHS.FSelectedAbility).GetCombatInfo(UnitHS.FUnit.FUnit, AbilityInfo);
    Targets := AbilityInfo.TargetTypes;
  end;
  if (TargetHS = nil) or ((TargetHS = UnitHS) and not (cttFriend in Targets)) then begin
    if (FCursorImage < $55) or (FCursorImage > $58) then FCursorImage := $55;
  end else
    if AoWHSSet.FAbilityControl.GetAbility(UnitHS.FSelectedAbility).GetCombatMode(UnitHS.FUnit.FUnit) = cmTouch then begin
      if (((cttFriend in Targets) and (UnitHS.FUnit.GetSide = TargetHS.FUnit.GetSide)) or
        ((cttEnemy in Targets) and (UnitHS.FUnit.GetSide <> TargetHS.FUnit.GetSide))) and
        TTouchAbility(AoWHSSet.FAbilityControl.GetAbility(UnitHS.FSelectedAbility)).CanTouch(UnitHS.FUnit, TargetHS.FUnit) then begin
        if (FCursorImage < $69) or (FCursorImage > $6B) then FCursorImage := $69;
      end else FCursorImage := $59;
    end else
      if ((cttFriend in Targets) and (UnitHS.FUnit.GetSide = TargetHS.FUnit.GetSide)) or
        ((cttEnemy in Targets) and (UnitHS.FUnit.GetSide <> TargetHS.FUnit.GetSide)) then begin
        if (FCursorImage < $50) or (FCursorImage > $53) then FCursorImage := $50;
      end else FCursorImage := $59;
  AoWCombatMap.Mouse.CursorMode := $100;
  AoWCombatMap.Mouse.Cursor := FCursorImage;
FinishCursor:
  if AoWCombatMap.Mouse.CursorMode <> 0 then Exit;
  if UnitHS.FUnit.GetPlayer = AoWCombatMap.FSeatedPlayer then begin
    if mtFlying in GetMoveTypes then AoWCombatMap.Mouse.Cursor := $40
    else if mtSwimming in GetMoveTypes then AoWCombatMap.Mouse.Cursor := $42
    else if mtWalking in GetMoveTypes then AoWCombatMap.Mouse.Cursor := $44;
    Cost := FMoveControlSettings.FMovePointTable[Field.TerrainType, Field.OverlayType];
    if UnitHS.FUnit.FMovePoints = 0 then Cost := 0
    else begin
      Wall := TCityWall(Field.FindOwnedChild($220504));
      if Wall = nil then Wall := TCityWall(Field.FindOwnedChild($220506));
      if Wall <> nil then begin
        if not (Wall is TCityWallDoor) or (UnitHS.FUnit.GetSide = csAttacker) then Cost := -1;
        if not (Wall is TCityWallDoor) and UnitHS.FUnit.FUnit.GetAbilityEnabled($24) then Cost := 1;
        if UnitHS.FUnit.FUnit.GetAbilityEnabled($42) or UnitHS.FUnit.FUnit.GetAbilityEnabled(1) then Cost := 1;
      end;
    end;
    if (Cost < 1) or (AoWCombatMap.FExplorationEnabled and not Field.GetExplored(AoWCombatMap.FSeatedPlayer)) then
      AoWCombatMap.Mouse.Cursor := AoWCombatMap.Mouse.Cursor + 1;
    AoWCombatMap.Mouse.CursorMode := $100;
  end;
end;

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
  if FRangedPathHS.FSelection <> nil then begin
    AoWCombatMap.DynamicFixedVisibleHS.RemoveChild(FRangedPathHS);
    FRangedPathHS.FSelection := nil;
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
var
  X, Y: Integer;
  Movement: TMovementHS;
  AbilityInfo, EnemyInfo: TAbilityCombatInfo;
begin
  if Info.HN <> 0 then begin
    CenterHNtoHX(GetXhx, GetYhx, Info.HN, X, Y);
    if MoveResult.Code < 30 then
      MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, Info.MapField.OverlayType];
    if MoveResult.Code < 0 then Exit;
    if Info.HN > 6 then Exit;
    if (GetXhx = TCombatMoveControl(Info.Sender).FDestinationX) and
      (GetYhx = TCombatMoveControl(Info.Sender).FDestinationY) then Exit;
    if FUnit.GetSide = TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetSide then Exit;
    if MeleeDamageTypes(FUnit) = [] then Exit;
    if FUnit.GetLocked then Exit;
    if FUnit.GetAbilityEnabled(1) <> TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled(1) then Exit;
    if (TCombatMoveControl(Info.Sender).FDestinationX >= 0) and
      (TCombatMoveControl(Info.Sender).FDestinationY >= 0) and
      (dHXtoRad(X, Y, TCombatMoveControl(Info.Sender).FDestinationX,
        TCombatMoveControl(Info.Sender).FDestinationY) < 2) then
      if AoWCombatMap.MapContainer.MapLevels[0].Field[TCombatMoveControl(Info.Sender).FDestinationX,
        TCombatMoveControl(Info.Sender).FDestinationY].FindOwnedChild($220104) <> nil then Exit;
    if MoveResult.Code > 96 then begin MoveResult.Code := 127; Exit; end;
    Inc(MoveResult.Code, 30);
    Exit;
  end;
  MoveResult.Code := -1;
  MoveResult.Done := True;
  Movement := TMovementHS(AoWCombatMap.MapContainer.MapLevels[0].Field[GetXhx, GetYhx].FindOwnedChild($22010A));
  if (Movement <> nil) and Movement.FEnabled then
    if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetSide = FUnit.GetSide then begin
      MoveResult.Code := 0; MoveResult.Done := False; Exit;
    end;
  if (GetXhx <> TCombatMoveControl(Info.Sender).FDestinationX) and
    (TCombatMoveControl(Info.Sender).FDestinationX <> -1) then Exit;
  if (GetYhx <> TCombatMoveControl(Info.Sender).FDestinationY) and
    (TCombatMoveControl(Info.Sender).FDestinationY <> -1) then Exit;
  if (TCombatMoveControl(Info.Sender).FMoveFlags and 8 = 0) and
    (TCombatMoveControl(Info.Sender).FMoveFlags and 4 = 0) and
    (AoWCombatMap.FUnitSelection.FMoveSettingsList.GetCount > 1) then Exit;
  if (TCombatMoveControl(Info.Sender).FUnitHS.FSelectedAbility < 0) and
    ((MeleeDamageTypes(TCombatMoveControl(Info.Sender).FUnitHS.FUnit) = []) or
      (FUnit.GetAbilityEnabled(1) and not TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled(1))) and
    (TCombatMoveControl(Info.Sender).FMoveFlags and 4 = 0) and
    (TCombatMoveControl(Info.Sender).FMoveFlags and 8 = 0) then Exit;
  if TCombatMoveControl(Info.Sender).FUnitHS.FSelectedAbility = -1 then begin
    if (TCombatMoveControl(Info.Sender).FMoveFlags and 8 = 0) and
      (TCombatMoveControl(Info.Sender).FMoveFlags and 4 = 0) then
      if FUnit.GetSide = TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetSide then Exit;
    MoveResult.Code := 0;
    Exit;
  end;
  AoWHSSet.FAbilityControl.GetAbility(TCombatMoveControl(Info.Sender).FUnitHS.FSelectedAbility).GetCombatInfo(
    TCombatMoveControl(Info.Sender).FUnitHS.FUnit.FUnit, AbilityInfo);
  if (cttFriend in AbilityInfo.TargetTypes) and (FUnit.GetSide = TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetSide) then begin
    if TTouchAbility(AoWHSSet.FAbilityControl.GetAbility(TCombatMoveControl(Info.Sender).FUnitHS.FSelectedAbility)).CanTouch(
      TCombatMoveControl(Info.Sender).FUnitHS.FUnit, FUnit) then MoveResult.Code := 0;
    Exit;
  end;
  AoWHSSet.FAbilityControl.GetAbility(TCombatMoveControl(Info.Sender).FUnitHS.FSelectedAbility).GetCombatInfo(
    TCombatMoveControl(Info.Sender).FUnitHS.FUnit.FUnit, EnemyInfo);
  if not (cttEnemy in EnemyInfo.TargetTypes) then Exit;
  if FUnit.GetSide = TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetSide then Exit;
  if TTouchAbility(AoWHSSet.FAbilityControl.GetAbility(TCombatMoveControl(Info.Sender).FUnitHS.FSelectedAbility)).CanTouch(
    TCombatMoveControl(Info.Sender).FUnitHS.FUnit, FUnit) then MoveResult.Code := 0;
end;

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
  FActionFrame := -1;
  FSelectedAbility := -1;
  FSelectedSpell := -1;
end;

procedure TTacticalCombatUnitHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
var SelfDestruct: TSelfDestructCA; SpellDamage: TDamageCA; RangedDamage: TRangedAttackCA;
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $110C then begin
    if (Msg.HN = 0) and (not AoWCombatMap.FFogEnabled or (Byte(TAoWMapField(Owner).FFieldFlags shr 16) <> 0)) then
      if FUnit.GetPlayer = 0 then Msg.Param[0] := Msg.Param[0] or $D
      else Msg.Param[0] := Msg.Param[0] or (AoWHSMap.FPlayers.GetPlayers(FUnit.GetPlayer).FPlayerRace + 1);
  end else if (Msg.MsgID = $1100) and (Msg.HN = 0) then Msg.Result := FUnit.GetPlayer
  else if (Msg.MsgID = $31000) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SelfDestruct := TSelfDestructCA(TSelfDestructAbility(AoWHSSet.FAbilityControl.GetAbility($41)).CreateSelfDestructCA(TCombatObject(Msg.Param[0]), FUnit));
    if SelfDestruct.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SelfDestruct);
    SelfDestruct.Release;
  end
  else if (Msg.MsgID = $31003) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell($75).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
    if SpellDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
    SpellDamage.Release;
  end
  else if (Msg.MsgID = $3100B) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell($71).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
    if SpellDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
    SpellDamage.Release;
  end
  else if (Msg.MsgID = $3100A) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    RangedDamage := TRangedAttackCA(TRangedAttackAbility(AoWHSSet.FAbilityControl.GetAbility($1F)).CreateRangedAttackCA(TCombatObject(Msg.Param[0]), FUnit, 0));
    if RangedDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(RangedDamage);
    RangedDamage.Release;
  end
  else if (Msg.MsgID = $31013) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell(Msg.Param[1]).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
    if SpellDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
    SpellDamage.Release;
  end
  else if (Msg.MsgID = $31012) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    RangedDamage := TRangedAttackCA(TRangedAttackAbility(AoWHSSet.FAbilityControl.GetAbility(Msg.Param[1])).CreateRangedAttackCA(TCombatObject(Msg.Param[0]), FUnit, 0));
    if RangedDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(RangedDamage);
    RangedDamage.Release;
  end
  else if (Msg.MsgID = $31005) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell($68).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
    if SpellDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
    SpellDamage.Release;
  end
  else if (Msg.MsgID = $3100C) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell($78).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
    if SpellDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
    SpellDamage.Release;
  end
  else if (Msg.MsgID = $31006) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell($74).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
    if SpellDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
    SpellDamage.Release;
  end
  else if (Msg.MsgID = $3100D) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell($7F).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
    if SpellDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
    SpellDamage.Release;
  end
  else if (Msg.MsgID = $3100E) and (Msg.HN = 0) then begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell($80).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
    if SpellDamage.FDamage <> 0 then SetAction(caHit);
    AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
    SpellDamage.Release;
  end
  else if (Msg.MsgID = $3100F) and (Msg.HN = 0) then begin
    SetDirection(FDirection + 1);
    if FDirection > 6 then SetDirection(1);
  end else if (Msg.MsgID = $31010) and (Msg.HN = 0) then begin
    FOffsetX := Random(Msg.Param[0] * 2) - Msg.Param[0];
    FOffsetY := Random(Msg.Param[0] * 2) - Msg.Param[0];
  end else if (Msg.MsgID = $31011) and (Msg.HN = 0) then begin
    FOffsetX := 0;
    FOffsetY := 0;
  end else if (Msg.MsgID = $31004) and (Msg.HN = 0) then
    if not (mtFlying in FUnit.FUnit.GetMoveTypes) and (TMapField(Owner).TerrainType <> 0) and (TMapField(Owner).TerrainType <> 9) then begin
      RandSeed := AoWHSMap.Random($FFFFFF);
      SpellDamage := TDamageCA(AoWHSSet.FSpellControl.GetSpell($70).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False));
      if SpellDamage.FDamage <> 0 then SetAction(caHit);
      AoWCombatMap.FCombat.ExecuteCombatAction(SpellDamage);
      SpellDamage.Release;
    end;
end;

procedure TTacticalCombatUnitHS.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID <> $20010017) and (Msg.MsgID and $40000000 = 0) and (FUnit <> nil) then
    FUnit.MsgProc(Msg, Sender);
end;

procedure TTacticalCombatUnitHS.NewFrame(Sender: TObject);
var Sequence: TImageSequence;
begin
  if FActionDone then SetAction(caMove);
  if FMoveIndicator = 0 then begin FMoveIndicator := Random(5) + 1; FIndicatorStep := 1; end
  else begin
    FMoveIndicator := FMoveIndicator + FIndicatorStep;
    if FMoveIndicator = 1 then FIndicatorStep := 1
    else if FMoveIndicator = 6 then FIndicatorStep := -1;
  end;
  case FAction of
    caStepUp:
      if FActionFrame > GetMoveSteps then begin
        HNtoHP(FDirection, FOffsetX, FOffsetY);
        FOffsetX := FOffsetX div 2; FOffsetY := FOffsetY div 2; FActionDone := True;
      end else begin
        HNtoHP(FDirection, FOffsetX, FOffsetY);
        FOffsetX := FActionFrame * FOffsetX div (GetMoveSteps * 2);
        FOffsetY := FActionFrame * FOffsetY div (GetMoveSteps * 2);
        Inc(FActionFrame, 2);
      end;
    caStepBack:
      if FActionFrame > GetMoveSteps then begin FOffsetX := 0; FOffsetY := 0; FActionDone := True; end
      else begin
        HNtoHP(FDirection, FOffsetX, FOffsetY);
        FOffsetX := (GetMoveSteps - FActionFrame) * FOffsetX div (GetMoveSteps * 2);
        FOffsetY := (GetMoveSteps - FActionFrame) * FOffsetY div (GetMoveSteps * 2);
        Inc(FActionFrame, 2);
      end;
    caMeleeHit, caMeleeMiss, caAbility: begin
      Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 11];
      if Sequence <> nil then begin
        Inc(FActionFrame);
        if FActionFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
          FActionFrame := Sequence.GetTotalSequenceFrames - 1; FActionDone := True;
        end;
      end;
    end;
    caBreathAttack: begin
      Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 11];
      if Sequence <> nil then
        if FActionFrame < Sequence.GetTotalSequenceFrames - 1 then Inc(FActionFrame)
        else FActionDone := True;
    end;
    caHit: begin
      Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 17];
      if Sequence <> nil then begin
        Inc(FActionFrame);
        if FActionFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
          FActionFrame := Sequence.GetTotalSequenceFrames - 1; FActionDone := True;
        end;
      end;
    end;
    caRoundAttack, caRoundAttackHit: begin
      Sequence := AoWHSSet.FImageSequences.ImageSequences[FDirection + 16];
      if Sequence <> nil then begin
        Inc(FActionFrame);
        if FActionFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
          FActionFrame := Sequence.GetTotalSequenceFrames - 1; FActionDone := True;
        end;
      end;
    end;
  else FActionFrame := -1;
  end;
  case FAction of
    caMove, caStepUp, caStepBack:
      if FMoveStep <> -1 then begin
        Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 5];
        if (Sequence <> nil) and (Sequence.SpeedCount = Sequence.SequenceSpeed) and AoWCombatMap.FPlaySounds then
          FUnitGFXResource.FSFXLibraries[1].Play(Sequence.GetFrameIndex(AoWHSMap.Frame,
            (Integer(Self) shr 2) and $FFFF) mod 100);
      end;
    caMeleeHit, caMeleeMiss, caAbility, caBreathAttack:
      if (FActionFrame = 0) and AoWCombatMap.FPlaySounds then
        if FSelectedAbility < 0 then
          if FAction = caMeleeMiss then FUnitGFXResource.FSFXLibraries[2].Play(1)
          else FUnitGFXResource.FSFXLibraries[2].Play(0)
        else if FSelectedAbility = $34 then begin
          if (FSelectedSpell <> $70) and (FSelectedSpell <> $7A) and (FSelectedSpell <> $77) then
            AoWHSSet.FSpellControl.GetSpell(FSelectedSpell).FCastSounds.Play(0);
        end else AoWHSSet.FAbilityControl.GetAbility(FSelectedAbility).FSFXLibrary.Play(0);
    caHit, caKilled:
      if (FActionFrame = 0) and AoWCombatMap.FPlaySounds then
        if FAction = caHit then FUnitGFXResource.FSFXLibraries[3].Play(0)
        else FUnitGFXResource.FSFXLibraries[4].Play(0);
    caRoundAttack, caRoundAttackHit:
      if (FActionFrame < 18) and AoWCombatMap.FPlaySounds and (raDir[FActionFrame] > 0) then
        if FAction = caRoundAttack then FUnitGFXResource.FSFXLibraries[2].Play(1)
        else FUnitGFXResource.FSFXLibraries[2].Play(0);
  end;
end;

procedure TTacticalCombatUnitHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  Index, X, Y, DX, DY: Integer;
  Progress: Real;
  I, NX, NY, FlyingOffset, Race: Integer;
  Wall, NextWall: TCityWall;
  SD: TSurfaceDesc;
begin
  try
    Assert(FDirection < FUnitGFXResource.FSequences.Count, 'Invalid Unit Index');
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
    XhpSurf := X - XhpSurf + FOffsetX;
    YhpSurf := Y - YhpSurf - 8 + FOffsetY;
    if FUnit.GetPlayer > 0 then Race := AoWHSMap.FPlayers.GetPlayers(FUnit.GetPlayer).FPlayerRace else Race := 32;
    if FUnit.GetAbilityEnabled(1) then FlyingOffset := -8 else FlyingOffset := 0;
    if FUnit.GetAbilityEnabled($24) then begin
      Wall := TCityWall(Owner.FindOwnedChild($220504));
      if Wall = nil then Wall := TCityWall(Owner.FindOwnedChild($220506));
      if FMoveStep = -1 then begin
        if (Wall <> nil) and (Wall.FHitPoints > 0) then Dec(YhpSurf, 32);
      end else begin
        CenterHNtoHX(GetXhx, GetYhx, FDirection, NX, NY);
        NextWall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[NX, NY].FindOwnedChild($220504));
        if NextWall = nil then NextWall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[NX, NY].FindOwnedChild($220506));
        if FMoveStep < GetMoveSteps div 2 then begin
          if (Wall <> nil) and (Wall.FHitPoints > 0) then
            if (NextWall = nil) or (NextWall.FHitPoints < 1) then Dec(YhpSurf, (GetMoveSteps - FMoveStep) * 32 div GetMoveSteps)
            else Dec(YhpSurf, 32);
        end else if (NextWall <> nil) and (NextWall.FHitPoints > 0) then
          if (Wall = nil) or (Wall.FHitPoints < 1) then Dec(YhpSurf, FMoveStep * 32 div GetMoveSteps)
          else Dec(YhpSurf, 32);
      end;
    end;
    case FAction of
      caMove, caBusy, caFreeStruck: begin
        if (FAction = caMove) and (FMoveStep <> -1) then begin
          HNtoHP(FDirection, DX, DY);
          Progress := FMoveStep / GetMoveSteps;
          Inc(XhpSurf, Round(DX * Progress));
          Inc(YhpSurf, Round(DY * Progress));
          Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 5];
        end else Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection - 1];
        while Sequence <> nil do begin
          Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
          if Index <> -1 then Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift, SurfaceDesc);
          Sequence := Sequence.Next;
        end;
      end;
      caMeleeHit, caMeleeMiss, caAbility, caBreathAttack: begin
        Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 11];
        if Sequence <> nil then
          while Sequence <> nil do begin
          Index := Sequence.GetUnloopedFrameIndex(FActionFrame);
            if Index <> -1 then Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift, SurfaceDesc);
            Sequence := Sequence.Next;
          end;
      end;
      caHit: begin
        Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 17];
        if Sequence <> nil then
          while Sequence <> nil do begin
          Index := Sequence.GetUnloopedFrameIndex(FActionFrame);
            if Index <> -1 then Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift, SurfaceDesc);
            Sequence := Sequence.Next;
          end;
      end;
      caStepUp, caStepBack: begin
        Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 5];
        if Sequence <> nil then
          while Sequence <> nil do begin
          Index := Sequence.GetFrameIndex(AoWHSMap.Frame + FActionFrame, (Integer(Self) shr 2) and $FFFF);
            if Index <> -1 then Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift, SurfaceDesc);
            Sequence := Sequence.Next;
          end;
      end;
      caRoundAttack, caRoundAttackHit: begin
        Sequence := AoWHSSet.FImageSequences.ImageSequences[FDirection + 15];
        if Sequence <> nil then
          while Sequence <> nil do begin
            Index := Sequence.GetUnloopedFrameIndex(FActionFrame);
            if Index <> -1 then
              if Sequence.Layer = 0 then begin
                while not FUnitGFXResource.FSequences.ImageSequences[FDirection + 11].ImageLibrary.ImageExist(Index) do Dec(Index);
                FUnitGFXResource.FSequences.ImageSequences[FDirection + 11].ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift,
                  YhpSurf + FlyingOffset + Sequence.dYshift, SurfaceDesc);
              end else Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift + FlyingOffset, SurfaceDesc);
            Sequence := Sequence.Next;
          end;
      end;
    end;
    if usEnchanted in FUnit.FUnit.FUnitStatus then
      AoWHSSet.FImageSequences.ShowLooped(70, XhpSurf + 16, YhpSurf + 18 + FlyingOffset, AoWHSMap.Frame, SurfaceDesc);
    for I := 0 to 13 do
      if FUnit.GetAbilityEnabled(StatusAbilities[I]) then begin
        Sequence := AoWHSSet.FAbilityControl.GetAbility(StatusAbilities[I]).FImageSequences.ImageSequences[0];
        while Sequence <> nil do begin
          Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
          if Index <> -1 then Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift + 15, SurfaceDesc);
          Sequence := Sequence.Next;
        end;
      end;
    if not GetSelected or (AoWCombatMap.Frame and 6 <> 6) then begin
      if Race = 32 then
        if (FUnit.FMovePoints = 0) or (FUnit.FCombatPlayer <> AoWCombatMap.FSeatedCombatPlayer) then
          AoWHSSet.FFlagControl.FFlags[70].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc)
        else AoWHSSet.FFlagControl.FFlags[FMoveIndicator + 69].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc)
      else if (FUnit.FMovePoints = 0) or (FUnit.FCombatPlayer <> AoWCombatMap.FSeatedCombatPlayer) then
        AoWHSSet.FRaceResources.GetRaceResource(Race).FImageLibrary[70].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc)
      else AoWHSSet.FRaceResources.GetRaceResource(Race).FImageLibrary[FMoveIndicator + 69].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc);
      SD := SurfaceDesc;
      I := FUnit.GetHitPoints * 10 div FUnit.GetHits;
      if I = 0 then I := 1;
      if XhpSurf - 4 + I < SD.ClipRect.Right then SD.ClipRect.Right := XhpSurf - 4 + I;
      AoWHSSet.FCombatImages[1].ShowClipped(XhpSurf - 4, YhpSurf - 4, SD);
    end;
  except MessageBox(0, PChar('Error - ' + FUnit.FUnit.GetName), 'Error during ShowUnit', 0); end;
end;

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
var Sequence: TImageSequence; Progress: Single; PX, PY, Index, DX, DY: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, PX, PY);
  X := PX - X + FOffsetX;
  if FBusy then Y := PY - Y - 8 else Y := PY - Y - 8 + FOffsetY;
  if FMoveStep <> -1 then begin
    HNtoHP(FDirection, DX, DY); Progress := FMoveStep / GetMoveSteps;
    Inc(X, Round(DX * Progress)); Inc(Y, Round(DY * Progress));
  end;
  Sequence := FUnitGFXResource.FSequences.ImageSequences[FDirection + 23];
  while Sequence <> nil do begin
    Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
    if Index <> -1 then Sequence.ImageLibrary[Index].Show(X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc);
    Sequence := Sequence.Next;
  end;
end;

function TTacticalCombatUnitHS.SelectAbility(A1: Integer): Integer;
var I, Index: Integer; Reason: string;
begin
  AoWCombatMap.FUnitSelection.DeactivateRangedPath;
  FSelectedAbility := -1;
  Result := -1; Index := -1;
  if AoWCombatMap.FCurrentCombatPlayer = AoWCombatMap.FSeatedCombatPlayer then begin
    for I := 0 to FAbilities.Count - 1 do if TTCAbility(FAbilities[I]).Ability = A1 then Index := I;
    if not FUnit.GetLocked and (FUnit.FMovePoints > 0) and
      (FUnit.FCombatPlayer = AoWCombatMap.FCurrentCombatPlayer) and (Index < FCombatAbilityCount) and (Index > -1) then
      if A1 = $34 then begin
        if FUnit.FUnit.GetMoves = FUnit.FMovePoints then begin
          AoWHSSet.FAbilityControl.GetAbility(A1).ActivateCombat(FUnit.FUnit, Reason);
          FSelectedSpell := -1; FSelectedAbility := A1; Result := Index;
        end;
      end else
        if AoWHSSet.FAbilityControl.GetAbility(A1).GetCombatMode(FUnit.FUnit) in [cmShortRange, cmMediumRange, cmLongRange] then begin
          if FUnit.FUnit.GetMoves = FUnit.FMovePoints then begin
            if AoWHSSet.FAbilityControl.GetAbility(A1).GetCombatMode(FUnit.FUnit) = cmShortRange then AoWCombatMap.FUnitSelection.FRangedPathHS.FRange := 4
            else if AoWHSSet.FAbilityControl.GetAbility(A1).GetCombatMode(FUnit.FUnit) = cmMediumRange then AoWCombatMap.FUnitSelection.FRangedPathHS.FRange := 8
            else AoWCombatMap.FUnitSelection.FRangedPathHS.FRange := 12;
            AoWCombatMap.FUnitSelection.FRangedPathHS.FSelection := AoWCombatMap.FUnitSelection;
            AoWCombatMap.DynamicFixedVisibleHS.AddChild(AoWCombatMap.FUnitSelection.FRangedPathHS);
            FSelectedAbility := A1; Result := Index;
          end;
        end else begin FSelectedAbility := A1; Result := Index; end;
  end;
  for I := 0 to AoWCombatMap.FUnitSelection.FMoveSettingsList.GetCount - 1 do
    with AoWCombatMap.FUnitSelection.FMoveSettingsList.GetMoveSettings(I) do FPath.Clear;
  AoWCombatMap.FUnitSelection.FRangedPath.Clear;
  AoWCombatMap.FUnitSelection.UpdateMoveCursor;
  AoWCombatMap.FMouseOverTargetEvents.TriggerNotifyEvents(Self);
end;

function TTacticalCombatUnitHS.SelectSpell(A1: Integer): Integer;
var I: Integer; Info: TSpellCombatInfo;
begin
  AoWCombatMap.FUnitSelection.DeactivateRangedPath;
  FSelectedSpell := A1;
  AoWHSSet.FSpellControl.GetSpell(FSelectedSpell).GetCombatInfo(FUnit.FUnit, Info);
  if Info.Range <> 0 then begin
    if Info.Range = -1 then AoWCombatMap.FUnitSelection.FRangedPathHS.FRange := 100
    else AoWCombatMap.FUnitSelection.FRangedPathHS.FRange := Info.Range;
    AoWCombatMap.FUnitSelection.FRangedPathHS.FSelection := AoWCombatMap.FUnitSelection;
    AoWCombatMap.DynamicFixedVisibleHS.AddChild(AoWCombatMap.FUnitSelection.FRangedPathHS);
  end;
  Result := A1;
  for I := 0 to AoWCombatMap.FUnitSelection.FMoveSettingsList.GetCount - 1 do
    with AoWCombatMap.FUnitSelection.FMoveSettingsList.GetMoveSettings(I) do FPath.Clear;
  AoWCombatMap.FUnitSelection.FRangedPath.Clear;
  case SpellTypes[A1] of
    fxScreenNESW, fxSacredWrath, fxTremors, fxHighPrayer, fxShockWave: begin
      AbRangedTC(0, 0); Result := -1; Unselect;
    end;
  end;
  AoWCombatMap.FUnitSelection.UpdateMoveCursor;
  AoWCombatMap.FMouseOverTargetEvents.TriggerNotifyEvents(Self);
end;

procedure TTacticalCombatUnitHS.CreateTCAbList;
var I: Integer; Ability: TTCAbility;
begin
  for I := 0 to FAbilities.Count - 1 do TObject(FAbilities[I]).Free;
  FAbilities.Clear; FCombatAbilityCount := 0;
  for I := 1 to 169 do
    if FUnit.GetAbilityEnabled(I) then begin
      Ability := TTCAbility.Create; Ability.Ability := I;
      if (acCombatAction in AoWHSSet.FAbilityControl.GetAbility(I).GetControlType(FUnit.FUnit)) and
        (AoWHSSet.FAbilityControl.GetAbility(I).GetCombatMode(FUnit.FUnit) <> cmMelee) then begin
        FAbilities.Insert(FCombatAbilityCount, Ability); Inc(FCombatAbilityCount);
      end else FAbilities.Add(Ability);
    end;
end;

procedure TTacticalCombatUnitHS.ListAbilities(Names, Types, Sources: TStrings);
var I: Integer;
begin
  Names.Clear;
  if Types <> nil then Types.Clear;
  if Sources <> nil then Sources.Clear;
  for I := 0 to FAbilities.Count - 1 do begin
    Names.AddObject(AoWHSSet.FAbilityControl.GetAbility(TTCAbility(FAbilities[I]).Ability).GetName(FUnit.FUnit), TObject(TTCAbility(FAbilities[I]).Ability));
    if Types <> nil then Types.Add(TranslateRStr(TAbilityTypeRStr[AoWHSSet.FAbilityControl.GetAbility(TTCAbility(FAbilities[I]).Ability).GetAbilityType]));
    if Sources <> nil then Sources.Add(AoWHSSet.FAbilityControl.GetAbility(TTCAbility(FAbilities[I]).Ability).GetSourceName(FUnit.FUnit));
  end;
end;

procedure TTacticalCombatUnitHS.SetAction(Action: TTCAction);
begin
  FActionDone := False;
  case Action of
    caStepUp, caStepBack: FActionFrame := 0;
    caRoundAttack, caRoundAttackHit:
      if (FAction <> caRoundAttack) and (FAction <> caRoundAttackHit) then FActionFrame := -1;
  else FActionFrame := -1;
  end;
  FAction := Action;
end;

function TTacticalCombatUnitHS.AbTouchMoveTC(Path: TMovepath): Boolean;
var TE: TTokenEvent; Info: TAbilityCombatInfo;
begin
  Result := False;
  if AoWHSMap.FTokenManager.PlayerReady(FUnit.GetPlayer) and (Path.Count > 0) then
    if Path.Count > 1 then begin
      TE := CreateTCAbTouchMoveTE(FUnit, Path, FSelectedAbility);
      if TE <> nil then begin
        AoWHSMap.FTokenManager.GetTokenControl(FUnit.GetPlayer).AddEvent(TE);
        TE.Release;
        Result := True;
      end;
    end else begin
      AoWHSSet.FAbilityControl.GetAbility(FSelectedAbility).GetCombatInfo(FUnit.FUnit, Info);
      if cttFriend in Info.TargetTypes then AbRangedTC(Path[0].X, Path[0].Y);
    end;
end;
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
var
  RaiseAction, AnimateAction: TCombatAction;
  UnitHS: TTacticalCombatUnitHS;
  N, I, Ring, X, Y, DX, DY: Integer;
  Effect: TfxHS;
  Speed, VZ, Gravity, Z: Single;
begin
  inherited MapFieldMsgProc(Msg);
  if FUnit <> nil then begin
    if (Msg.MsgID = $31008) and (Msg.HN = 0) then
      if AoWCombatMap.MapContainer.MapLevels[0].Field[GetXhx, GetYhx].FindOwnedChild($220104) = nil then begin
        AoWCombatMap.MakeVisible(GetXhx, GetYhx, 0, 5);
        HXtoHP(GetXhx, GetYhx, X, Y);
        for Ring := 1 to 3 do begin
          N := Random(5);
          DX := Random(20) + Ring * 30;
          DY := Random(20) + Ring * 30;
          for I := 0 to 17 do begin
            Effect := AoWCombatMap.AddEffect(fxGeyserWater);
            Effect.FAbilityIndex := $34;
            Effect.FSpellIndex := Msg.Param[1];
            DX := -DX;
            if I in [1,3,5,7,9,11,13,15,17] then DY := -DY;
            MakeLinePath(Round(Cos((I * 5 + N) * Pi / 180) * DX) + X + 16,
              Round(Sin((I * 5 + N) * Pi / 180) * DY) div 2 + Y + 16,
              X + 16, Y + 16, 100, Effect.FPath);
          end;
        end;
        Exit;
      end;
    if (Msg.MsgID = $31009) and (Msg.HN = 0) then
      if AoWCombatMap.MapContainer.MapLevels[0].Field[GetXhx, GetYhx].FindOwnedChild($220104) = nil then begin
        HXtoHP(GetXhx, GetYhx, X, Y);
        N := Random(6) + 25;
        for I := 1 to N - 1 do begin
          Effect := AoWCombatMap.AddEffect(fxGeyserWater);
          Effect.FAbilityIndex := $34;
          Effect.FSpellIndex := Msg.Param[1];
          VZ := (Random(10) + 10) * 0.05;
          Gravity := 0.5;
          Speed := (Random(50) + 50) * 0.05;
          Z := 0;
          MakeArcPath(X + 16, Y + 16, I * 360 div N, Z, Speed, VZ, Gravity, Effect.FPath);
        end;
        if Msg.Param[1] = $81 then begin
          RandSeed := AoWHSMap.Random($FFFFFF);
          RaiseAction := AoWHSSet.FSpellControl.GetSpell($81).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False);
          AoWCombatMap.FCombat.ExecuteCombatAction(RaiseAction);
          RaiseAction.Release;
        end else if Msg.Param[1] = $82 then begin
          RandSeed := AoWHSMap.Random($FFFFFF);
          AnimateAction := AoWHSSet.FSpellControl.GetSpell($82).CreateCA(TCombatObject(Msg.Param[0]), FUnit, False);
          AoWCombatMap.FCombat.ExecuteCombatAction(AnimateAction);
          AnimateAction.Release;
        end;
        if FUnit.GetEnabled then begin
          UnitHS := TTacticalCombatUnitHS.Create(nil);
          UnitHS.Initialize(FUnit);
          UnitHS.SetDirection(Random(6) + 1);
          AoWCombatMap.PlaceHX(UnitHS, GetXhx, GetYhx, 0);
        end;
        Free;
      end;
  end;
end;

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
var I, J: Integer;
begin
  inherited Create;
  for I := 0 to 285 do FResources[I] := TList.Create;
  for J := 0 to AoWHSSet.FCombatResources.GetCount - 1 do
    if AoWHSSet.FCombatResources.MORs[J] is TCombatTerrainResource then
      FResources[Shortint(TCombatTerrainResource(AoWHSSet.FCombatResources.MORs[J]).TerrainType) * 19 +
        TCombatTerrainResource(AoWHSSet.FCombatResources.MORs[J]).DecorationType].Add(AoWHSSet.FCombatResources.MORs[J]);
  InitTables;
end;

destructor TRndTacHsm.Destroy;
var I: Integer;
begin
  for I := 0 to 285 do FResources[I].Free;
  inherited Destroy;
end;

function TRndTacHsm.RandomMap(Combat: TTacticalCombat; X, Y, L: Integer): TAoWCombatMap;
var
  TerrainBuffer: PCombatMapBytes;
  I, J, K, NX, Col, Row, TerrainType, Tag: Integer;
  ShapeBuffer: PCombatMapBytes;
  Shape: Byte;
  HasUnit, SiteCombat, RandomTerrain: Boolean;
  FileName: string;
  Structure: THexagonSprite;
  Weights: array[0..19] of Integer;

  function Blocked(X, Y, First, Last: Integer): Boolean;
  var I, Kind, NX, NY: Integer;
  begin
    Result := False;
    for I := First to Last do begin
      CenterHNtoHX(X, Y, ClusterCheck[I], NX, NY);
      Kind := Byte(PChar(TerrainBuffer)[NY * 65 + NX]);
      Result := Result or (Kind = 1) or (Kind = 2) or (Kind = 3) or (Kind = 5) or (Kind = 6) or (Kind = 7) or (Kind = 11) or (Kind = 14) or (Kind = 15) or (Kind = 16) or (Kind = 17) or (Kind = 18) or (Kind = 252) or (Kind = 253) or (Kind = 254);
    end;
  end;

begin
  FItems := nil;
  if Combat = nil then begin
    SiteCombat := False;
    RandomTerrain := True;
  end else begin
    SiteCombat := Combat.FExplorationSite = 1;
    RandomTerrain := not (SiteCombat or (Combat.FExplorationSite = 2));
  end;
  FRandomTerrain := RandomTerrain;
  CombatXLoc := X;
  CombatYLoc := Y;
  CombatLLoc := L;
  RandSeed := Y * 128 + X + L * 16384 + AoWHSMap.FInitialRandomSeed;
  for I := 0 to 6 do begin
    CenterHNtoHX(X, Y, I, J, K);
    FTerrain[I] := AoWHSMap.MapContainer.MapLevels[L].Field[J, K].TerrainType;
    FTags[I] := TAoWMapField(AoWHSMap.MapContainer.MapLevels[L].Field[J, K]).GetCombatTerrainTag;
  end;
  if FTerrain[0] in [0, 9, 10] then
    for I := 1 to 6 do FTerrain[I] := FTerrain[0]
  else
    for I := 1 to 6 do
      if FTerrain[I] in [0, 15, 10, 9] then FTerrain[I] := FTerrain[0];
  FileName := 'TCMaps\';
  Structure := AoWHSMap.MapContainer.MapLevels[L].Field[X, Y].FindNoneTransparentHS(TStructure);
  if Structure = nil then Structure := AoWHSMap.MapContainer.MapLevels[L].Field[X, Y].FindNoneTransparentHS(THexagonBridge);
  if Structure <> nil then begin
    case Structure.ClassID of
      $20108: begin
        FileName := FileName + '0';
        for I := 1 to 6 do begin
          CenterHNtoHX(X, Y, I, J, K);
          if AoWHSMap.MapContainer.MapLevels[L].Field[J, K].FindNoneTransparentHS(TCity) <> nil then begin
            FileName := FileName + IntToStr(I);
            FTags[I] := 127;
          end;
        end;
        while Length(FileName) < 11 do FileName := FileName + 'x';
        FileName := FileName + 'C000';
      end;
      $2036E: FileName := FileName + 'Farmx000';
      $2037A: FileName := FileName + 'Minex000';
      $20100: FileName := FileName + 'SLife000';
      $2094E: FileName := FileName + 'NodeA000';
      $204AE: FileName := FileName + 'NodeD000';
      $2019A: FileName := FileName + 'NodeC000';
      $204CE: FileName := FileName + 'NodeE000';
      $203DE: FileName := FileName + 'NodeF000';
      $20371: FileName := FileName + 'NodeL000';
      $204B3: FileName := FileName + 'NodeW000';
      $2063E: FileName := FileName + 'RPool000';
      $2092E: FileName := FileName + 'BGuil000';
      $204BE: FileName := FileName + 'SYard000';
      $2043E: FileName := FileName + 'TFort000';
      $2037E: if RandomTerrain then FileName := FileName + 'CaveN000' else FileName := FileName + 'CaveE000';
      $20104: begin
        if FRandomTerrain then FileName := FileName + 'TeleN000' else FileName := FileName + 'Telep000';
        RandomTerrain := True;
      end;
      $2032E: if SiteCombat then begin
        FItems := TECustomNode(Combat.FItems);
        FileName := FileName + 'eMrLr00' + IntToStr(Random(4));
        for I := 1 to 6 do FTags[I] := 127;
      end else FileName := FileName + 'Blank000';
      $2038E: if SiteCombat then begin
        FItems := TECustomNode(Combat.FItems);
        FileName := FileName + 'eZigg00' + IntToStr(Random(2));
        for I := 1 to 6 do FTags[I] := 127;
      end else FileName := FileName + 'Blank000';
      $2030A: if SiteCombat then begin
        FItems := TECustomNode(Combat.FItems);
        FileName := FileName + 'eCrpt00' + IntToStr(Random(2));
        for I := 1 to 6 do FTags[I] := 127;
      end else FileName := FileName + 'Blank000';
      $2039A: if SiteCombat then begin
        FItems := TECustomNode(Combat.FItems);
        FileName := FileName + 'eRuin00' + IntToStr(Random(2));
        for I := 1 to 6 do FTags[I] := 127;
      end else FileName := FileName + 'Blank000';
      $2032A: if SiteCombat then begin
        FileName := FileName + 'eDung00' + IntToStr(Random(2));
        for I := 1 to 6 do FTags[I] := 127;
      end else FileName := FileName + 'Blank000';
      $2087A: begin
        RandomTerrain := False;
        FRandomTerrain := False;
        FileName := FileName + 'Br';
        case FTerrain[0] of
          10: FileName := FileName + 'UW';
          6: FileName := FileName + 'Ic';
          9: FileName := FileName + 'La';
          13: FileName := FileName + 'UI';
        else FileName := FileName + 'Wa';
        end;
        if THexagonBridge(Structure).FDirection = 1 then FileName := FileName + 'A000'
        else if THexagonBridge(Structure).FDirection = 2 then FileName := FileName + 'B000'
        else FileName := FileName + 'C000';
      end;
    else FileName := FileName + 'Blank000';
    end;
    FTags[0] := 127;
  end;
  if FTags[0] <> 127 then FileName := FileName + 'Blank000';
  FileName := FileName + '.HSM';
  if Combat = nil then AoWEngine.LoadHSMEx(AoWEngine.StartupDirectory + FileName, False, nil)
  else AoWHSMap.InitializeCombatMap(Combat, FileName);
  AoWCombatMap.SetCombat(Combat);
  AoWCombatMap.SetExplorationEnabled(SiteCombat);
  AoWCombatMap.SetFogEnabled(False);
  if Combat <> nil then PlaceCombatUnits;
  if RandomTerrain then begin
    AoWCombatMap.LockMapChangedEvent;
    ShapeBuffer := AllocMem($EBA);
    TerrainBuffer := AllocMem($EBA);
    for Row := 6 to 52 do
      for Col := 6 to 58 do begin
        Shape := MapShape[Row * 65 + Col];
        case Shape of
          8: if Random(100) < 50 then Shape := 7 else Shape := 6;
          9: if Random(100) < 50 then Shape := 3 else Shape := 4;
          10: if Random(100) < 50 then Shape := 2 else Shape := 7;
          11: if Random(100) < 50 then Shape := 2 else Shape := 3;
          12: if Random(100) < 50 then Shape := 5 else Shape := 6;
          13: if Random(100) < 50 then Shape := 5 else Shape := 4;
          14: if Random(100) < 50 then Shape := 1 else Shape := 2;
          15: if Random(100) < 50 then Shape := 1 else Shape := 3;
          16: if Random(100) < 50 then Shape := 1 else Shape := 4;
          17: if Random(100) < 50 then Shape := 1 else Shape := 5;
          18: if Random(100) < 50 then Shape := 1 else Shape := 6;
          19: if Random(100) < 50 then Shape := 1 else Shape := 7;
        end;
        if AoWCombatMap.MapContainer.MapLevels[0].Field[Col, Row].GetDecorationType = 9 then begin
          case Shape of
            1: J := 0;
            2: J := 1;
            3: J := 2;
            4: J := 3;
            5: J := 4;
            6: J := 5;
            7: J := 6;
          else J := -1;
          end;
          if J >= 0 then begin
            CenterHNtoHX(X, Y, J, K, NX);
            if AoWHSMap.MapContainer.MapLevels[L].Field[K, NX].FindOwnedChild($2036A) = nil then
              AoWCombatMap.ClearTerrain(Col, Row, -1, 0, 0);
          end;
        end;
        ShapeBuffer^[Row * 65 + Col] := Shape;
      end;
    if AoWHSMap.MapContainer.MapLevels[L].Field[X, Y].OverlayType = 4 then begin
      for I := 0 to 6 do begin
        CenterHNtoHX(X, Y, I, J, K);
        Weights[I] := AoWHSMap.MapContainer.MapLevels[L].Field[J, K].OverlayType;
      end;
      for Row := 6 to 52 do
        for Col := 6 to 58 do begin
          Shape := MapRoads[Row * 65 + Col];
          case MapRoads[Row * 65 + Col] of
            21: if Random(100) < 50 then Shape := 0 else Shape := 2;
            22: if Random(100) < 50 then Shape := 0 else Shape := 3;
            23: if Random(100) < 50 then Shape := 0 else Shape := 4;
            24: if Random(100) < 50 then Shape := 0 else Shape := 5;
            25: if Random(100) < 50 then Shape := 0 else Shape := 6;
            26: if Random(100) < 50 then Shape := 0 else Shape := 7;
          end;
          if Shape in [1..7] then
            if (FTags[Shape - 1] <> 127) and (Weights[Shape - 1] = 4) then begin
              AoWHSSet.FCombatRoads.Place(AoWCombatMap.MapContainer, Col, Row, 0, 1);
              TerrainBuffer^[Row * 65 + Col] := 251;
            end;
        end;
    end;
    for Row := 6 to 52 do begin
      for Col := 3 to 29 do begin
        I := ShapeBuffer^[Row * 65 + Col * 2];
        if I <> 0 then
          if (FTags[I - 1] = 127) or (TerrainBuffer^[Row * 65 + Col * 2] = 251) then I := 0;
        if I > 0 then begin
          TerrainType := FTerrain[I - 1];
          Tag := FTags[I - 1];
          for I := 0 to 18 do begin
            Weights[I] := FTerrainWeights[TerrainType * 19 + I];
            if Tag < 14 then Inc(Weights[I], FTagWeights[Tag * 19 + I]);
          end;
          for I := 0 to 2 do begin
            CenterHNtoHX(Col * 2, Row, ClusterCheck[I], J, K);
            Tag := TerrainBuffer^[K * 65 + J];
            if Tag < 20 then Inc(Weights[Tag], FNeighborWeights[Tag]);
            if Tag in [1, 2, 3] then begin
              Inc(Weights[5], 10);
              Inc(Weights[10], 10);
              Inc(Weights[4], 10);
            end else if (Tag = 14) or (Tag = 16) then Inc(Weights[11], FNeighborWeights[11]);
          end;
          HasUnit := AoWCombatMap.MapContainer.MapLevels[0].Field[Col * 2, Row].FindChild($220104) <> nil;
          if (HasUnit or Blocked(Col * 2, Row, 0, 2)) and
            (HasUnit or Blocked(Col * 2, Row, 4, 8)) and (HasUnit or Blocked(Col * 2, Row, 9, 17)) then begin
            Weights[1] := 0;
            Weights[2] := 0;
            Weights[3] := 0;
            Weights[5] := 0;
            Weights[6] := 0;
            Weights[7] := 0;
            Weights[11] := 0;
            Weights[14] := 0;
            Weights[15] := 0;
            Weights[16] := 0;
            Weights[17] := 0;
            Weights[18] := 0;
          end else if (HasUnit or Blocked(Col * 2, Row, 4, 8)) and (HasUnit or Blocked(Col * 2, Row, 9, 17)) then begin
            Weights[14] := 0;
            Weights[15] := 0;
            Weights[16] := 0;
          end;
          J := 0;
          for I := 0 to 18 do Inc(J, Weights[I]);
          Tag := Random(J) - Weights[0];
          J := 0;
          while (Tag > 0) and (J < 18) do begin
            Inc(J);
            Dec(Tag, Weights[J]);
          end;
          if TerrainType = 8 then J := 17;
          case J of
            14: begin
              CenterHNtoHX(Col * 2, Row, 6, K, NX);
              TerrainBuffer^[NX * 65 + K] := 252;
            end;
            15: begin
              CenterHNtoHX(Col * 2, Row, 6, K, NX);
              TerrainBuffer^[NX * 65 + K] := 253;
            end;
            16: begin
              CenterHNtoHX(Col * 2, Row, 1, K, NX);
              TerrainBuffer^[NX * 65 + K] := 254;
              CenterHNtoHX(Col * 2, Row, 2, K, NX);
              TerrainBuffer^[NX * 65 + K] := 254;
              CenterHNtoHX(Col * 2, Row, 6, K, NX);
              TerrainBuffer^[NX * 65 + K] := 254;
            end;
          end;
          TerrainBuffer^[Row * 65 + Col * 2] := J;
        end;
      end;
      for Col := 3 to 29 do begin
        I := ShapeBuffer^[Row * 65 + Col * 2 + 1];
        if I <> 0 then
          if (FTags[I - 1] = 127) or (TerrainBuffer^[Row * 65 + Col * 2 + 1] = 251) then I := 0;
        if I > 0 then begin
          TerrainType := FTerrain[I - 1];
          Tag := FTags[I - 1];
          for I := 0 to 18 do begin
            Weights[I] := FTerrainWeights[TerrainType * 19 + I];
            if Tag < 14 then Inc(Weights[I], FTagWeights[Tag * 19 + I]);
          end;
          for I := 0 to 2 do begin
            CenterHNtoHX(Col * 2 + 1, Row, ClusterCheck[I], J, K);
            Tag := TerrainBuffer^[K * 65 + J];
            if Tag < 20 then Inc(Weights[Tag], FNeighborWeights[Tag]);
            if Tag in [1, 2, 3] then begin
              Inc(Weights[5], 10);
              Inc(Weights[10], 10);
              Inc(Weights[4], 10);
            end else if (Tag = 14) or (Tag = 16) then Inc(Weights[11], FNeighborWeights[11]);
          end;
          HasUnit := AoWCombatMap.MapContainer.MapLevels[0].Field[Col * 2 + 1, Row].FindChild($220104) <> nil;
          if (HasUnit or Blocked(Col * 2 + 1, Row, 0, 2)) and
            (HasUnit or Blocked(Col * 2 + 1, Row, 4, 8)) and (HasUnit or Blocked(Col * 2 + 1, Row, 9, 17)) then begin
            Weights[1] := 0;
            Weights[2] := 0;
            Weights[3] := 0;
            Weights[5] := 0;
            Weights[6] := 0;
            Weights[7] := 0;
            Weights[11] := 0;
            Weights[14] := 0;
            Weights[15] := 0;
            Weights[16] := 0;
            Weights[17] := 0;
            Weights[18] := 0;
          end else if (HasUnit or Blocked(Col * 2 + 1, Row, 4, 8)) and (HasUnit or Blocked(Col * 2 + 1, Row, 9, 17)) then begin
            Weights[14] := 0;
            Weights[15] := 0;
            Weights[16] := 0;
          end;
          J := 0;
          for I := 0 to 18 do Inc(J, Weights[I]);
          Tag := Random(J) - Weights[0];
          J := 0;
          while (Tag > 0) and (J < 18) do begin
            Inc(J);
            Dec(Tag, Weights[J]);
          end;
          if TerrainType = 8 then J := 17;
          case J of
            14: begin
              CenterHNtoHX(Col * 2 + 1, Row, 6, K, NX);
              TerrainBuffer^[NX * 65 + K] := 252;
            end;
            15: begin
              CenterHNtoHX(Col * 2 + 1, Row, 6, K, NX);
              TerrainBuffer^[NX * 65 + K] := 253;
            end;
            16: begin
              CenterHNtoHX(Col * 2 + 1, Row, 1, K, NX);
              TerrainBuffer^[NX * 65 + K] := 254;
              CenterHNtoHX(Col * 2 + 1, Row, 2, K, NX);
              TerrainBuffer^[NX * 65 + K] := 254;
              CenterHNtoHX(Col * 2 + 1, Row, 6, K, NX);
              TerrainBuffer^[NX * 65 + K] := 254;
            end;
          end;
          TerrainBuffer^[Row * 65 + Col * 2 + 1] := J;
        end;
      end;
    end;
    for Row := 6 to 52 do
      for Col := 6 to 58 do begin
        I := ShapeBuffer^[Row * 65 + Col];
        if I <> 0 then begin
          J := TerrainBuffer^[Row * 65 + Col];
          if J = 17 then AoWCombatMap.MapContainer.MapLevels[0].Field[Col, Row].TerrainType := 7
          else begin
            AoWCombatMap.MapContainer.MapLevels[0].Field[Col, Row].TerrainType := FTerrain[I - 1];
            if (J > 0) and (J < 19) then
              if FResources[FTerrain[I - 1] * 19 + J].Count > 0 then
                TMapObjectResource(FResources[FTerrain[I - 1] * 19 + J][Random(FResources[FTerrain[I - 1] * 19 + J].Count)]).PlaceResourceUser(AoWCombatMap, Col, Row, 0);
          end;
        end;
      end;
    for Row := 6 to 52 do
      for Col := 6 to 58 do AoWCombatMap.MapContainer.MapLevels[0].Field[Col, Row].TerrainChanged;
    FreeMem(ShapeBuffer);
    FreeMem(TerrainBuffer);
    AoWCombatMap.UnlockMapChangedEvent;
  end;
  Result := AoWCombatMap;
end;

procedure TRndTacHsm.PlaceCombatUnits;
var
  Position, I, J, Temp: Integer;
  Units: TList;
  U, Other: TTacticalCombatUnit;
  Direction: Integer;
  Used: array[0..7] of Boolean;
  ItemHS: TCItemHS;
begin
  Direction := 32;
  FHomePosition := -1;
  Units := TList.Create;
  for Position := 0 to 7 do begin
    Units.Clear;
    for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
      if AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit then
        if AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled then
          if AoWCombatMap.FCombat.FCombatData.GetObjects(I).FPosition shr 4 = Position then begin
            Units.Add(AoWCombatMap.FCombat.FCombatData.GetObjects(I));
            U := TTacticalCombatUnit(Units[Units.Count - 1]);
            U.FPositionIndex := U.FPosition and $F;
            U.FPositionGroup := U.FPosition shr 4;
            if U.FPositionGroup = 7 then U.FPositionGroup := 1;
            if U.FPositionGroup = 0 then FHomePosition := 0;
            if FHomePosition = -1 then
              if U.GetSide = csDefender then
                if AoWHSMap.MapContainer.MapLevels[AoWCombatMap.FCombat.FCombatData.FL].Field[
                  AoWCombatMap.FCombat.FCombatData.FX, AoWCombatMap.FCombat.FCombatData.FY].FindNoneTransparentHS(TCity) <> nil then;
            if (FHomePosition > 0) and (U.FPositionGroup = FHomePosition) then U.FPositionGroup := 0;
            AoWCombatMap.FPositionStatus[U.FPositionGroup] := Ord(U.GetSide);
          end;
    for I := 0 to Units.Count - 1 do begin
      U := TTacticalCombatUnit(Units[I]);
      for J := I + 1 to Units.Count - 1 do begin
        Other := TTacticalCombatUnit(Units[J]);
        if U.GetPosValue < Other.GetPosValue then begin
          Temp := U.FPositionIndex;
          U.FPositionIndex := Other.FPositionIndex;
          Other.FPositionIndex := Temp;
        end;
      end;
    end;
  end;
  if AoWCombatMap.FPositionStatus[0] <> Ord(csDefender) then
    if (AoWHSMap.MapContainer.MapLevels[AoWCombatMap.FCombat.FCombatData.FL].Field[
      AoWCombatMap.FCombat.FCombatData.FX, AoWCombatMap.FCombat.FCombatData.FY].FindNoneTransparentHS(TCity) <> nil) and
      (AoWCombatMap.FCombat.FCombatData.FWallType <> 0) then begin
      Position := 1;
      while Position < 7 do begin
        if AoWCombatMap.FPositionStatus[Position] = Ord(csDefender) then begin
          CenterHNtoHX(AoWCombatMap.FCombat.FCombatData.FX, AoWCombatMap.FCombat.FCombatData.FY, Position, Temp, J);
          if AoWHSMap.MapContainer.MapLevels[AoWCombatMap.FCombat.FCombatData.FL].Field[Temp, J].FindNoneTransparentHS(TCity) <> nil then begin
            FHomePosition := Position;
            AoWCombatMap.FPositionStatus[Position] := Ord(csNeutral);
            AoWCombatMap.FPositionStatus[0] := Ord(csDefender);
            Position := 7;
          end;
        end;
        Inc(Position);
      end;
    end;
  for Position := 0 to AoWCombatMap.FCombat.FSides[csAttacker].GetCount - 1 do
    if AoWCombatMap.FCombat.FSides[csAttacker].GetObjects(Position).GetEnabled then
      SetupUnit(csAttacker, Position, Direction);
  for Position := 0 to AoWCombatMap.FCombat.FSides[csDefender].GetCount - 1 do
    if AoWCombatMap.FCombat.FSides[csDefender].GetObjects(Position) is TCombatUnit then
      if AoWCombatMap.FCombat.FSides[csDefender].GetObjects(Position).GetEnabled then
        SetupUnit(csDefender, Position, Direction);
  Units.Free;
  if FItems <> nil then begin
    for Position := 0 to 7 do Used[Position] := False;
    Position := 0;
    while Position < FItems.GetCount do begin
      I := Random(AoWCombatMap.FUnitPositions.FPositions.Count - 16);
      J := I - 1;
      if J < 0 then J := AoWCombatMap.FUnitPositions.FPositions.Count - 17;
      { Original indexes its eight-slot occupancy array with the position-list index. }
      while Used[I] and (I <> J) do begin
        Inc(I);
        if I > AoWCombatMap.FUnitPositions.FPositions.Count - 17 then I := 0;
      end;
      Used[I] := True;
      J := AoWCombatMap.FUnitPositions.GetUnitPosition(2, I).X;
      Temp := AoWCombatMap.FUnitPositions.GetUnitPosition(2, I).Y;
      ItemHS := TCItemHS.Create(nil);
      if not AoWCombatMap.PlaceHX(ItemHS, J, Temp, 0) then Inc(Position)
      else FItems.GetChild(Position).SetOwner(ItemHS.FItems);
    end;
  end;
end;

procedure TRndTacHsm.SetupUnit(Side: TCombatSideIndex; Index: Integer; var Direction: Integer);
var
  UnitHS: TTacticalCombatUnitHS;
  TargetHS: TTacticalCombatUnitHS;
  X, Y, Position, Slot, HN, NX, NY: Integer;
begin
  UnitHS := TTacticalCombatUnitHS.Create(nil);
  UnitHS.Initialize(TTacticalCombatUnit(AoWCombatMap.FCombat.FSides[Side].GetObjects(Index)));
  if UnitHS.FUnit.FPositionGroup = FHomePosition then UnitHS.FUnit.FPositionGroup := 0;
  Position := UnitHS.FUnit.FPositionGroup;
  Slot := UnitHS.FUnit.FPositionIndex;
  X := AoWCombatMap.FUnitPositions.GetUnitPosition(Position, Slot).X;
  Y := AoWCombatMap.FUnitPositions.GetUnitPosition(Position, Slot).Y;
  if (Side = csDefender) and FRandomTerrain then begin
    case Position of
      0:
        if Direction > 0 then begin
          X := DefPosX[(Direction - 1) * 8 + Slot];
          Y := DefPosY[(Direction - 1) * 8 + Slot];
          UnitHS.SetDirection(Direction);
        end else
          case Slot of
            0: UnitHS.SetDirection(1); 1: UnitHS.SetDirection(4);
            2,6: UnitHS.SetDirection(5); 3,7: UnitHS.SetDirection(2);
            4: UnitHS.SetDirection(3); 5: UnitHS.SetDirection(6);
          end;

      1: Inc(Y, 2);
      2: begin Dec(X, 2); Inc(Y); end;
      3: begin Dec(X, 2); Dec(Y); end;
      4: Dec(Y, 2);
      5: begin Inc(X, 2); Dec(Y); end;
      6: begin Inc(X, 2); Inc(Y); end;
    end;
  end else if Direction <> Position then
    if Direction = 32 then Direction := Position else Direction := 0;
  if not FRandomTerrain then UnitHS.SetDirection(AoWCombatMap.FUnitPositions.GetUnitPosition(Position, Slot).Flag)
  else case Position of
    1: UnitHS.SetDirection(4); 2: UnitHS.SetDirection(5); 3: UnitHS.SetDirection(6);
    4: UnitHS.SetDirection(1); 5: UnitHS.SetDirection(2); 6: UnitHS.SetDirection(3);
  end;
  HN := 0;
  repeat
    CenterHNtoHX(X, Y, HN, NX, NY);
    Slot := AoWCombatMap.MapContainer.MapLevels[0].Field[NX, NY].OverlayType;
    TargetHS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].Field[NX, NY].FindOwnedChild($220104));
    Inc(HN);
  until (Slot <> 8) and (TargetHS = nil);
  AoWCombatMap.PlaceHX(UnitHS, NX, NY, 0);
  if (dHXtoHN(AoWCombatMap.FCombat.FCombatData.FX, AoWCombatMap.FCombat.FCombatData.FY,
    AoWCombatMap.FCombat.FCombatData.FAttackerX, AoWCombatMap.FCombat.FCombatData.FAttackerY) = Position) and
    (AoWCombatMap.FPlayers.GetPlayers(UnitHS.FUnit.FCombatPlayer).FLastX = 0) then begin
    AoWCombatMap.FPlayers.GetPlayers(UnitHS.FUnit.FCombatPlayer).FLastX := UnitHS.GetXhx;
    AoWCombatMap.FPlayers.GetPlayers(UnitHS.FUnit.FCombatPlayer).FLastY := UnitHS.GetYhx;
  end;
end;

procedure TRndTacHsm.InitTables;
begin
  FNeighborWeights[1] := 500;
  FNeighborWeights[2] := 500;
  FNeighborWeights[4] := 1500;
  FNeighborWeights[5] := 200;
  FNeighborWeights[10] := 1500;
  FNeighborWeights[11] := 500;
  FNeighborWeights[17] := 2000;
  FNeighborWeights[18] := 1500;
  FTerrainWeights[19] := 2500;
  FTerrainWeights[20] := 0;
  FTerrainWeights[21] := 35;
  FTerrainWeights[22] := 0;
  FTerrainWeights[23] := 6;
  FTerrainWeights[24] := 2;
  FTerrainWeights[25] := 1;
  FTerrainWeights[26] := 2;
  FTerrainWeights[27] := 5;
  FTerrainWeights[29] := 90;
  FTerrainWeights[30] := 60;
  FTerrainWeights[31] := 2;
  FTerrainWeights[32] := 30;
  FTerrainWeights[33] := 10;
  FTerrainWeights[34] := 0;
  FTerrainWeights[35] := 3;
  FTerrainWeights[38] := 2500;
  FTerrainWeights[39] := 5;
  FTerrainWeights[40] := 0;
  FTerrainWeights[41] := 0;
  FTerrainWeights[42] := 6;
  FTerrainWeights[43] := 0;
  FTerrainWeights[44] := 5;
  FTerrainWeights[45] := 5;
  FTerrainWeights[46] := 2;
  FTerrainWeights[48] := 35;
  FTerrainWeights[49] := 20;
  FTerrainWeights[50] := 5;
  FTerrainWeights[51] := 30;
  FTerrainWeights[52] := 5;
  FTerrainWeights[53] := 2;
  FTerrainWeights[54] := 1;
  FTerrainWeights[57] := 2500;
  FTerrainWeights[58] := 8;
  FTerrainWeights[59] := 0;
  FTerrainWeights[60] := 0;
  FTerrainWeights[61] := 6;
  FTerrainWeights[62] := 0;
  FTerrainWeights[63] := 2;
  FTerrainWeights[64] := 2;
  FTerrainWeights[65] := 1;
  FTerrainWeights[67] := 15;
  FTerrainWeights[68] := 20;
  FTerrainWeights[69] := 2;
  FTerrainWeights[70] := 30;
  FTerrainWeights[71] := 5;
  FTerrainWeights[72] := 1;
  FTerrainWeights[73] := 1;
  FTerrainWeights[76] := 2500;
  FTerrainWeights[77] := 8;
  FTerrainWeights[78] := 0;
  FTerrainWeights[79] := 0;
  FTerrainWeights[80] := 6;
  FTerrainWeights[81] := 0;
  FTerrainWeights[82] := 2;
  FTerrainWeights[83] := 2;
  FTerrainWeights[84] := 1;
  FTerrainWeights[86] := 15;
  FTerrainWeights[87] := 20;
  FTerrainWeights[88] := 2;
  FTerrainWeights[89] := 20;
  FTerrainWeights[90] := 5;
  FTerrainWeights[91] := 1;
  FTerrainWeights[92] := 1;
  FTerrainWeights[95] := 2500;
  FTerrainWeights[96] := 5;
  FTerrainWeights[97] := 0;
  FTerrainWeights[98] := 1;
  FTerrainWeights[99] := 3;
  FTerrainWeights[100] := 0;
  FTerrainWeights[101] := 5;
  FTerrainWeights[102] := 5;
  FTerrainWeights[103] := 4;
  FTerrainWeights[105] := 10;
  FTerrainWeights[106] := 45;
  FTerrainWeights[107] := 5;
  FTerrainWeights[108] := 12;
  FTerrainWeights[109] := 10;
  FTerrainWeights[110] := 4;
  FTerrainWeights[111] := 3;
  FTerrainWeights[114] := 2500;
  FTerrainWeights[115] := 0;
  FTerrainWeights[116] := 0;
  FTerrainWeights[117] := 0;
  FTerrainWeights[118] := 0;
  FTerrainWeights[119] := 0;
  FTerrainWeights[120] := 0;
  FTerrainWeights[121] := 0;
  FTerrainWeights[122] := 0;
  FTerrainWeights[124] := 0;
  FTerrainWeights[125] := 0;
  FTerrainWeights[126] := 0;
  FTerrainWeights[127] := 0;
  FTerrainWeights[128] := 0;
  FTerrainWeights[129] := 0;
  FTerrainWeights[130] := 0;
  FTerrainWeights[228] := 2500;
  FTerrainWeights[229] := 0;
  FTerrainWeights[230] := 0;
  FTerrainWeights[231] := 0;
  FTerrainWeights[232] := 0;
  FTerrainWeights[233] := 10;
  FTerrainWeights[234] := 0;
  FTerrainWeights[235] := 0;
  FTerrainWeights[236] := 0;
  FTerrainWeights[238] := 30;
  FTerrainWeights[239] := 70;
  FTerrainWeights[240] := 4;
  FTerrainWeights[241] := 0;
  FTerrainWeights[242] := 50;
  FTerrainWeights[243] := 4;
  FTerrainWeights[244] := 10;
  FTerrainWeights[245] := 80;
  FTagWeights[20] := 800;
  FTagWeights[21] := 100;
  FTagWeights[29] := 300;
  FTagWeights[25] := 20;
  FTagWeights[26] := 40;
  FTagWeights[27] := 10;
  FTagWeights[40] := 900;
  FTagWeights[48] := 400;
  FTagWeights[44] := 20;
  FTagWeights[45] := 40;
  FTagWeights[46] := 10;
  FTagWeights[60] := 250;
  FTagWeights[61] := 200;
  FTagWeights[86] := 300;
  FTagWeights[80] := 500;
  FTagWeights[100] := 500;
  FTagWeights[105] := 200;
  FTagWeights[99] := 100;
  FTagWeights[120] := 250;
  FTagWeights[121] := 250;
  FTagWeights[122] := 100;
  FTagWeights[144] := 600;
  FTagWeights[147] := 250;
  FTagWeights[149] := 150;
  FTagWeights[164] := 250;
  FTagWeights[167] := 100;
  FTagWeights[163] := 200;
  FTagWeights[162] := 200;
  FTagWeights[181] := 500;
  FTagWeights[191] := 450;
  FTagWeights[200] := 150;
  FTagWeights[196] := 40;
  FTagWeights[197] := 20;
  FTagWeights[198] := 10;
  FTagWeights[211] := 450;
  FTagWeights[219] := 150;
  FTagWeights[215] := 20;
  FTagWeights[216] := 20;
  FTagWeights[217] := 40;
  FTagWeights[241] := 500;
  FTagWeights[239] := 200;
  FTagWeights[242] := 50;
  FTagWeights[244] := 20;
  FTagWeights[258] := 600;
  FTagWeights[261] := 350;
  FTagWeights[263] := 300;
  FTagWeights[181] := 600;
end;

procedure TRangedPathHS.Deactivate;
begin
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'TCombat\Misc.ILB');
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'TargHex.ILB');
  inherited Deactivate;
end;

class function TRangedPathHS.ClassID: Integer;
begin Result := $220105; end;

function TRangedPathHS.GetShowPriority: Integer;
begin Result := $6C000000; end;

procedure TRangedPathHS.Activate;
begin
  inherited Activate;
  FMiscImages := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'TCombat\Misc.ILB');
  FTargetImages := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'TargHex.ILB');
end;

procedure TRangedPathHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  I, X, Y, Count, First, Last, NX, NY, PX, PY: Integer;
  EffectType: TfxType;
begin
  if FSelection <> nil then begin
    if FRange < 100 then begin
      Count := 6;
      First := 1;
      for I := 0 to FRange - 2 do begin
        Inc(First, Count);
        Inc(Count, 6);
      end;
      Last := First + Count;
      for I := First to Last - 1 do begin
        CenterHNtoHX(FSelection.GetTCUnitHS.GetXhx, FSelection.GetTCUnitHS.GetYhx, I, NX, NY);
        HXtoHP(NX, NY, PX, PY);
        FTargetImages[2].Show(PX - XhpSurf, PY - YhpSurf, SurfaceDesc);
      end;
    end;
    if FSelection.FRangedPath.Count > 0 then begin
      Inc(FFrameCount);
      if FFrameCount > 4 then begin FFrameCount := 0; Inc(FFrame); end;
      if FFrame > 1 then FFrame := 0;
      if FSelection.GetTCUnitHS.FSelectedAbility = $34 then EffectType := SpellTypes[FSelection.GetTCUnitHS.FSelectedSpell]
      else EffectType := AbilTypes[FSelection.GetTCUnitHS.FSelectedAbility];
      if EffectType = fxBreath then begin
        HPtoHX(FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].X,
          FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].Y, X, Y);
        for I := 0 to 11 do begin
          CenterHNtoHX(FSelection.GetTCUnitHS.GetXhx, FSelection.GetTCUnitHS.GetYhx,
            BreathHN[dHXtoHN(FSelection.GetTCUnitHS.GetXhx, FSelection.GetTCUnitHS.GetYhx, X, Y) * 12 + I - 12], NX, NY);
          HXtoHP(NX, NY, PX, PY);
          FTargetImages[0].ShowClipped(PX - 8 - XhpSurf, PY + 2 - YhpSurf, SurfaceDesc);
        end;
      end else
        if FSelection.GetTCUnitHS.FSelectedAbility = $34 then
          case FSelection.GetTCUnitHS.FSelectedSpell of
            $68, $6A, $74, $75, $78, $81, $82: for I := 0 to 6 do begin
              HPtoHX(FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].X,
                FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].Y, X, Y);
              CenterHNtoHX(X, Y, I, NX, NY);
              HXtoHP(NX, NY, PX, PY);
              FTargetImages[0].ShowClipped(PX - 8 - XhpSurf, PY + 2 - YhpSurf, SurfaceDesc);
            end;
            $7C, $80: for I := 0 to 18 do begin
              HPtoHX(FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].X,
                FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].Y, X, Y);
              CenterHNtoHX(X, Y, I, NX, NY);
              HXtoHP(NX, NY, PX, PY);
              FTargetImages[0].ShowClipped(PX - 8 - XhpSurf, PY + 2 - YhpSurf, SurfaceDesc);
            end;
          else
            FMiscImages[FFrame + 3].ShowClipped(FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].X - 21 - XhpSurf,
              FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].Y - 20 - YhpSurf, SurfaceDesc);
          end
        else
          FMiscImages[FFrame + 3].ShowClipped(FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].X - 21 - XhpSurf,
            FSelection.FRangedPath[FSelection.FRangedPath.Count - 1].Y - 20 - YhpSurf, SurfaceDesc);
      for I := 0 to FSelection.FRangedPath.Count - 1 do
        FMiscImages[2].Show(FSelection.FRangedPath[I].X - XhpSurf, FSelection.FRangedPath[I].Y - YhpSurf, SurfaceDesc);
      for I := 0 to FSelection.FRangedPath.Count - 1 do
        FMiscImages[0].Show(FSelection.FRangedPath[I].X - XhpSurf,
          FSelection.FRangedPath[I].Y - FSelection.FRangedPath[I].Z - 8 - YhpSurf, SurfaceDesc);
      for I := 0 to FSelection.FObstacles.Count - 1 do begin
        HPtoHX(FSelection.FRangedPath[TROb(FSelection.FObstacles[I]).PathIndex].X,
          FSelection.FRangedPath[TROb(FSelection.FObstacles[I]).PathIndex].Y, NX, NY);
        HXtoHP(NX, NY, PX, PY);
        FMiscImages[1].Show(PX + 5 - XhpSurf, PY + 5 - YhpSurf, SurfaceDesc);
        AoWEngine.FCombatFont.Color := 0;
        AoWEngine.FCombatFont.SetTextCentered(PX + 16 - XhpSurf, PY + 12 - YhpSurf,
          IntToStr(TROb(FSelection.FObstacles[I]).Chance), SurfaceDesc);
      end;
    end;
  end;
end;

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
begin
  Result := TTacticalCombatUnit.Create(nil);
end;

procedure TTacticalCombat.Deactivate;
begin
  if FCombatResult <> crCannotBreachWall then UpdateStatus;
  inherited Deactivate;
end;

procedure TTacticalCombat.Initialize;
var I: Integer;
begin
  inherited Initialize;
  FCombatData.FTurnOrder.Clear;
  FCombatData.FTurnOrder.Add(FCombatData.FAttackerPlayer);
  FHostPlayer := -1;
  for I := 0 to AoWHSMap.FPlayers.GetCount - 1 do
    if FHostPlayer = -1 then
      if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman then
        if AoWHSMap.FPlayers.GetPlayers(I).FStatus <> psTerminated then FHostPlayer := I;
  for I := 0 to FCombatData.FPlayers.GetCount - 1 do begin
    if FCombatData.FTurnOrder.IndexOf(I) = -1 then
      if FCombatData.FPlayers.GetPlayers(I).FSideIndex = 0 then FCombatData.FTurnOrder.Add(I);
    if AoWHSMap.FPlayers.GetPlayers(FCombatData.FPlayers.GetPlayers(I).FPlayer).FPlayerType <> ptHuman then
      if AoWHSMap.FPlayerCommunicator.PCC is TRemotePCC then begin
        TRemotePCC(AoWHSMap.FPlayerCommunicator.PCC).SetConnectionMode(FCombatData.FPlayers.GetPlayers(I).FPlayer,
          AoWHSMap.FPlayerCommunicator.PCC.GetPlayers(FHostPlayer).ConnectionMode);
        TRemotePCC(AoWHSMap.FPlayerCommunicator.PCC).SetSystemID(FCombatData.FPlayers.GetPlayers(I).FPlayer,
          AoWHSMap.FPlayerCommunicator.PCC.GetPlayers(FHostPlayer).SystemID);
      end;
  end;
  for I := 0 to AoWHSMap.FTokenManager.GetCount - 1 do
    if AoWHSMap.FTokenManager.GetTokenControl(I).Local or AoWHSMap.FTokenManager.GetTokenControl(I).Global then
      AoWHSMap.FTokenManager.GetTokenControl(I).ClearEvents;
  FCombatData.FTurnOrder.Add(FCombatData.FDefenderPlayer);
  for I := 0 to FCombatData.FPlayers.GetCount - 1 do
    if FCombatData.FTurnOrder.IndexOf(I) = -1 then
      if FCombatData.FPlayers.GetPlayers(I).FSideIndex = 1 then FCombatData.FTurnOrder.Add(I);
  SetLogCombatActions(1);
end;

procedure TTacticalCombat.Finalize;
var I: Integer;
begin
  for I := 0 to FCombatData.FPlayers.GetCount - 1 do
    if AoWHSMap.FPlayers.GetPlayers(FCombatData.FPlayers.GetPlayers(I).FPlayer).FPlayerType <> ptHuman then begin
      TRemotePCC(AoWHSMap.FPlayerCommunicator.PCC).SetConnectionMode(FCombatData.FPlayers.GetPlayers(I).FPlayer, cmGlobal);
      TRemotePCC(AoWHSMap.FPlayerCommunicator.PCC).SetSystemID(FCombatData.FPlayers.GetPlayers(I).FPlayer, 0);
    end;
  if AoWCombatMap <> nil then begin
    AoWCombatMap.FUnitSelection.Clear;
    AoWCombatMap.FSelectEvents.TriggerNotifyEvents(Self);
    AoWHSMap.ReleaseCombatMap;
  end;
  inherited Finalize;
end;

function TTacticalCombat.ValidateWallCombat: Boolean;
var I: Integer; Side: TCombatSide;
begin
  Side := FSides[csAttacker];
  Result := FCombatData.FParties.GetParty(0).FWall = 0;
  I := Side.GetCount;
  while not Result and (I > 0) do begin
    Dec(I);
    Result := Side.GetObjects(I).WallCombatFeatures * [wcWallBreaching, wcWallPassing] <> [];
  end;
end;

function TTacticalCombat.CreateCombatPlayer: TCombatPlayer;
begin
  Result := TTacticalCombatPlayer.Create(nil);
end;

function TTacticalCombat.Execute: Byte;
var
  Generator: TRndTacHsm;
  I, Seated: Integer;
begin
  if not ValidateWallCombat then begin
    SetLogCombatActions(1);
    SetLogbookHeader(TranslateRStr(CannotBreachWallRStr));
    FCombatResult := crCannotBreachWall;
    Result := Ord(FCombatResult);
  end else begin
    if FSides[csAttacker].GetCount = FSides[csAttacker].FConquerCount then begin
      SetLogCombatActions(1);
      SetLogbookHeader(TranslateRStr(CannotInflictDamageRStr));
      FCombatResult := crCannotInflictDamage;
      Result := Ord(FCombatResult);
    end else if FSides[csAttacker].GetCount = 0 then Result := Ord(crNoDefenders)
    else begin
      AoWHSMap.FTokenManager.TokenExecuter.HoldTC := True;
      Generator := TRndTacHsm.Create;
      Generator.RandomMap(Self, FCombatData.FX, FCombatData.FY, FCombatData.FL);
      Generator.Free;
      AoWCombatMap.FPlaySounds := AoWHSMap.FStartingGame or
        AoWHSMap.VisibleForPlayer(FCombatData.FX, FCombatData.FY, FCombatData.FL, AoWHSMap.FSeatedPlayer);
      if not AoWCombatMap.FPlaySounds then
        for I := 0 to FCombatData.FPlayers.GetCount - 1 do
          if AoWHSMap.FPlayers.GetPlayers(FCombatData.FPlayers.GetPlayers(I).FPlayer).FPlayerType = ptHuman then
            if AoWHSMap.FPlayers.GetPlayers(FCombatData.FPlayers.GetPlayers(I).FPlayer).GetLocal then AoWCombatMap.FPlaySounds := True;
      AoWCombatMap.FDeselectEvents.TriggerNotifyEvents(Self);
      Seated := -1;
      for I := 0 to FCombatData.FPlayers.GetCount - 1 do
        if Seated = -1 then
          if AoWHSMap.FPlayers.GetPlayers(FCombatData.FPlayers.GetPlayers(I).FPlayer).FPlayerType = ptHuman then
            if AoWHSMap.FPlayerCommunicator.PCC.GetPlayers(FCombatData.FPlayers.GetPlayers(I).FPlayer).ConnectionMode <> cmRemote then
              if Ord(AoWHSMap.FPlayers.GetPlayers(FCombatData.FPlayers.GetPlayers(I).FPlayer).FStatus) <> 2 then Seated := I;
      AoWCombatMap.SetSeatedCombatPlayer(Seated);
      AoWCombatMap.CenterViewTo(32, 29, 0);
      AoWCombatMap.FCombat.NewRound;
      AoWCombatMap.NewTurn(FCombatData.FTurnOrder[0]);
      Result := Ord(crBusy);
      FOnTerminated := AoWCombatMap.EndCombat;
      SetLogCombatActions(1);
    end;
  end;
end;

procedure TfxHS.Deactivate;
begin
  AoWCombatMap.NewFrameEvents.Remove(NewFrame);
  inherited Deactivate;
end;

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
begin
  inherited Activate;
  AoWCombatMap.NewFrameEvents.Add(NewFrame);
  FFrame := -1;
end;

function TfxHS.GetShowPriority: Integer;
begin
  Result := $6C000000;
end;

procedure TfxHS.NewFrame(Sender: TObject);
var
  Effect: TfxHS;
  J, I: Integer;
  Sequence: TImageSequence;
  NewPath: TXYZList;
  K, X, Y: Integer;
  Z, Speed, VZ, Gravity: Single;
  Effect2: TfxHS;
  UnitHS: TTacticalCombatUnitHS;
  Msg: TMapFieldMsg;

  procedure MakeCloud(Count, Radius: Integer);
  var N: Integer;
  begin
    for N := 1 to Count - 1 do begin
      Effect := AoWCombatMap.AddEffect(fxCloudPuff);
      Effect.FAbilityIndex := FAbilityIndex;
      Effect.FSpellIndex := FSpellIndex;
      Effect.FPath.Add(TXYZ.Create);
      J := Random(70) + 10;
      Effect.FPath[0].X := FPath[0].X + Round(Cos(J * Pi / 180) * (Random(Radius) - Radius div 2));
      Effect.FPath[0].Y := FPath[0].Y + Round(Sin(J * Pi / 180) * (Random(Radius) - Radius div 2)) div 2;
    end;
  end;

  procedure MakeImpact;
  begin
    Effect := nil;
    HPtoHX(FPath[FFrame].X, FPath[FFrame].Y, I, J);
    if AoWCombatMap.MapContainer.MapLevels[0].Field[I, J].TerrainType = 0 then
      Effect := AoWCombatMap.AddEffect(fxHitWater)
    else if (AoWCombatMap.MapContainer.MapLevels[0].Field[I, J].OverlayType <> 8) and
      (AoWCombatMap.MapContainer.MapLevels[0].Field[I, J].FindOwnedChild($220504) = nil) and
      (AoWCombatMap.MapContainer.MapLevels[0].Field[I, J].FindOwnedChild($220506) = nil) then
      Effect := AoWCombatMap.AddEffect(fxHitGround);
    if Effect <> nil then begin
      Effect.FPath.Add(TXYZ.Create);
      Effect.FPath[0].X := FPath[FFrame].X;
      Effect.FPath[0].Y := FPath[FFrame].Y;
    end;
  end;

begin
  try
    if FCancelled then FFrame := -1
    else begin
      Inc(FFrame);
      case FEffectType of
        fxArrow, fxRock, fxComet, fxBreath, fxCometBall, fxSwarm: begin
          case FAbilityIndex of
            $34: if FSpellIndex = $75 then Inc(FFrame);
            $2C, $2D, $39, $3A, $7B: Inc(FFrame);
          end;
          if (FFrame = 0) and AoWCombatMap.FPlaySounds and (FAbilityIndex = $34) and (FSpellIndex = $7A) then
            AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(0);
          if FFrame >= FPath.Count - 1 then begin
            if AoWCombatMap.FPlaySounds then
              if FAbilityIndex = $34 then
                AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
              else
                AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
            FFrame := FPath.Count - 1;
            FDone := True;
            if FTarget = nil then MakeImpact;
            HPtoHX(FPath[FFrame].X, FPath[FFrame].Y - FPath[FFrame].Z, I, J);
            AoWCombatMap.MakeVisible(I, J, 0, 2);
          end;
        end;
        fxDecayComet: begin
          if (FFrame = 0) and AoWCombatMap.FPlaySounds and (FAbilityIndex = $34) then
            AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(0);
          if FFrame >= FPath.Count - 1 then begin
            if AoWCombatMap.FPlaySounds then
              if FAbilityIndex = $34 then
                AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
              else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
            FFrame := FPath.Count - 1;
            FDone := True;
          end;
        end;
        fxTremors: begin
          case FFrame of
            0: begin
              FPath.Add(TXYZ.Create);
              FPath[0].X := AoWCombatMap.ViewXhp;
              FPath[0].Y := AoWCombatMap.ViewYhp;
            end;
            1..29: AoWCombatMap.ChangeViewTo(FPath[0].X + Random(FFrame div 3) - FFrame div 6,
              FPath[0].Y + Random(FFrame div 3) - FFrame div 6, AoWCombatMap.ViewL);
            30..89: AoWCombatMap.ChangeViewTo(FPath[0].X + Random(10) - 5,
              FPath[0].Y + Random(10) - 5, AoWCombatMap.ViewL);
            90..119: AoWCombatMap.ChangeViewTo(FPath[0].X + Random((119 - FFrame) div 3) - (119 - FFrame) div 6,
              FPath[0].Y + Random((119 - FFrame) div 3) - (119 - FFrame) div 6, AoWCombatMap.ViewL);
            120: FFrame := -1;
          end;
        end;
        fxScreenNS: begin
          Inc(FFrame);
          if FFrame >= FPath.Count - 1 then begin
            if AoWCombatMap.FPlaySounds then
              if FAbilityIndex = $34 then
                AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
              else
                AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
            FFrame := FPath.Count - 1;
            FDone := True;
            Effect := AoWCombatMap.AddEffect(fxHailImpact);
            Effect.FAbilityIndex := FAbilityIndex;
            Effect.FSpellIndex := FSpellIndex;
            Effect.FPath.Add(TXYZ.Create);
            Effect.FPath[0].X := FPath[FFrame].X;
            Effect.FPath[0].Y := FPath[FFrame].Y;
          end;
        end;
        fxCloud: begin
          case FFrame of
            1..149: MakeCloud(FFrame, FFrame);
            150..199: MakeCloud(150, 150);
            200..249: MakeCloud((250 - FFrame) * 3, 150);
            250: FFrame := -1;
          end;
        end;
        fxPrayerGlow: begin
          if FAbilityIndex = $34 then
            Sequence := AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastImages.ImageSequences[1]
          else Sequence := AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FImageSequences.ImageSequences[1];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxSFOverlay: begin
          if FFrame >= FPath.Count - 1 then begin
            FFrame := FPath.Count - 1;
            FDone := True;
          end;
        end;
        fxScreenSwarm: begin
          if FFrame = 0 then FFrame := 1;
          if FFrame >= FPath.Count - 1 then begin
            if AoWCombatMap.FPlaySounds then
              if (FAbilityIndex = $34) and (FTarget <> nil) then
                AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
              else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
            FFrame := FPath.Count - 1;
            FDone := True;
          end;
        end;
        fxRay: begin
          Inc(FFrame, 12);
          if FFrame >= FPath.Count - 1 then begin
            if AoWCombatMap.FPlaySounds then
              if FAbilityIndex = $34 then
                AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
              else
                AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
            FFrame := FPath.Count - 1;
            FDone := True;
          end;
        end;
        fxFrostBeam: begin
          case FFrame of
            0..999: begin
              Inc(FFrame);
              if FFrame >= FPath.Count - 1 then FFrame := 999;
              J := Random(5) + 5;
              HXtoHP(FTargetX, FTargetY, K, X);
              for I := 0 to J do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
                MakeArcPathXY(K - 200, X - 200, Random(100) + K - 50,
                  Random(100) + X - 50, Random(5) + 5, 100, Effect.FPath);
              end;
              J := Random(10) + 10;
              for I := 0 to J do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(50) + 20) / 10;
              Gravity := 0.5;
              VZ := Random(10) / 10;
              Z := 100;
              MakeArcPath(K - 200, X - 200, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
              end;
            end;
            1000..1029: begin
              HXtoHP(FTargetX, FTargetY, K, X);
              J := Random(5) + 5;
              for I := 0 to J do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
                MakeArcPathXY(K - 200, X - 200, Random(100) + K - 50,
                  Random(100) + X - 50, Random(5) + 5, 100, Effect.FPath);
              end;
              J := Random(10) + 10;
              for I := 0 to J do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(50) + 20) / 10;
              Gravity := 0.5;
              VZ := Random(10) / 10;
              Z := 100;
              MakeArcPath(K - 200, X - 200, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
              end;
              J := Random(5) + 5;
              for I := 0 to J do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(20) + 20) / 10;
              Gravity := 0.5;
              VZ := (Random(50) + 20) / 10;
              Z := 0;
              MakeArcPath(FPath[FPath.Count - 1].X, FPath[FPath.Count - 1].Y - FPath[FPath.Count - 1].Z, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
              end;
            end;
            1030: FFrame := 1999;
            2000..2999: begin
              Inc(FFrame);
              if FFrame >= FPath.Count + 2000 - 1 then FFrame := 2999;
              J := Random(5) + 5;
              for I := 0 to J do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(20) + 20) / 10;
              Gravity := 0.5;
              VZ := (Random(50) + 20) / 10;
              Z := 0;
              MakeArcPath(FPath[FPath.Count - 1].X, FPath[FPath.Count - 1].Y - FPath[FPath.Count - 1].Z, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
              end;
            end;
            3000: begin
              if AoWCombatMap.FPlaySounds then
                if FAbilityIndex = $34 then
                  AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
                else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
              for I := 0 to FPath.Count - 1 do begin
              Effect := AoWCombatMap.AddEffect(fxFrost);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(25) + 25) / 10;
              Gravity := 0.5;
              VZ := (Random(50) + 40) / 10;
              Z := 0;
              MakeArcPath(FPath[I].X, FPath[I].Y - FPath[I].Z, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
              end;
              J := Random(10) + 100;
              for I := 0 to J do begin
              Effect := AoWCombatMap.AddEffect(fxFrost);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(50) + 50) / 10;
              Gravity := 0.1;
              VZ := (Random(5) + 5) / 10;
              Z := 0;
              MakeArcPath(FPath[FPath.Count - 1].X, FPath[FPath.Count - 1].Y - FPath[FPath.Count - 1].Z, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
              end;
              FDone := True;
              FTarget := nil;
            end;
          end;
        end;
        fxShockWave: begin
          case FFrame of
            0..29: begin
              if (FFrame = 0) and AoWCombatMap.FPlaySounds then begin
                if AoWCombatMap.FPlaySounds then
                  if FAbilityIndex = $34 then
                    AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(0)
                  else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(0);
              end;
              for I := 1 to 20 do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
                MakeSwarmPath(Random(10) + 10, Random(10) + FFrame div 4,
                  (I mod 6) * 60 + FFrame, Random(360), FPath[0].X, FPath[0].Y,
                  TSwarmDirection(Random(2)), Effect.FPath);
              end;
            end;
            30..59: begin
              for I := 1 to 20 do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
                MakeSwarmPath(Random(10) + 10, Random(10) + (60 - FFrame) div 4,
                  (I mod 6) * 60 + FFrame, Random(360), FPath[0].X, FPath[0].Y,
                  TSwarmDirection(Random(2)), Effect.FPath);
              end;
            end;
            60..89: begin
              for I := 1 to 20 do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
                MakeSwarmPath(Random(10) + 10, Random(10) + (FFrame - 60) div 2,
                  (I mod 6) * 60 + FFrame, Random(360), FPath[0].X, FPath[0].Y,
                  TSwarmDirection(Random(2)), Effect.FPath);
              end;
            end;
            90..119: begin
              for I := 1 to 20 do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
                MakeSwarmPath(Random(10) + 10, Random(10) + (120 - FFrame) div 2,
                  (I mod 6) * 60 + FFrame, Random(360), FPath[0].X, FPath[0].Y,
                  TSwarmDirection(Random(2)), Effect.FPath);
              end;
            end;
            150: begin
              if AoWCombatMap.FPlaySounds then
                if FAbilityIndex = $34 then
                  AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
                else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
              X := 200;
              Y := 200;
              J := Random(5);
              for I := 0 to 359 do begin
              Effect := AoWCombatMap.AddEffect(fxGeyserWater);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
                X := -X;
                MakeLinePath(FPath[0].X, FPath[0].Y,
                  FPath[0].X + Round(Cos((I + J) * Pi / 180) * (Random(10) + X)),
                  FPath[0].Y + Round(Sin((I + J) * Pi / 180) * (Random(10) + Y)) div 2,
                  75, Effect.FPath);
                if I mod 10 = 0 then
                  for K := 1 to 10 do begin
                    Effect2 := AoWCombatMap.AddEffect(fxGeyserWater);
                    Effect2.FAbilityIndex := FAbilityIndex;
                    Effect2.FSpellIndex := FSpellIndex;
                    MakeLinePath(FPath[0].X, FPath[0].Y, Effect.FPath[Effect.FPath.Count - 1].X,
                      Effect.FPath[Effect.FPath.Count - 1].Y, K * 5 + 75, Effect2.FPath);
                  end;
              end;
            end;
            151..169, 210..229: begin
              HPtoHX(FPath[0].X, FPath[0].Y, X, Y);
              Msg.MsgID := $31010;
              Msg.Param[0] := 1;
              Msg.Result := -1;
              for I := 1 to 36 do begin
                CenterHNtoHX(X, Y, I, J, K);
                AoWCombatMap.MapContainer.MapLevels[0].Field[J, K].SendMapFieldMsg(Msg);
              end;
            end;
            170..184, 195..209: begin
              HPtoHX(FPath[0].X, FPath[0].Y, X, Y);
              Msg.MsgID := $31010;
              Msg.Param[0] := 2;
              Msg.Result := -1;
              for I := 1 to 36 do begin
                CenterHNtoHX(X, Y, I, J, K);
                AoWCombatMap.MapContainer.MapLevels[0].Field[J, K].SendMapFieldMsg(Msg);
              end;
            end;
            185..194: begin
              HPtoHX(FPath[0].X, FPath[0].Y, X, Y);
              Msg.MsgID := $31010;
              Msg.Param[0] := 3;
              Msg.Result := -1;
              for I := 1 to 36 do begin
                CenterHNtoHX(X, Y, I, J, K);
                AoWCombatMap.MapContainer.MapLevels[0].Field[J, K].SendMapFieldMsg(Msg);
              end;
            end;
            230: begin
              HPtoHX(FPath[0].X, FPath[0].Y, X, Y);
              Msg.MsgID := $31011;
              Msg.Result := -1;
              for I := 1 to 36 do begin
                CenterHNtoHX(X, Y, I, J, K);
                AoWCombatMap.MapContainer.MapLevels[0].Field[J, K].SendMapFieldMsg(Msg);
              end;
              FFrame := -1;
            end;
          end;
        end;
        fxWinds: begin
          case FFrame of
            0..1999:
              if FFrame < FPath.Count + 20 then begin
                if AoWCombatMap.FPlaySounds and ((FFrame = FTargetX) or (FFrame = FTargetY)) then begin
                  if AoWCombatMap.FPlaySounds then
                    if FAbilityIndex = $34 then
                      AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(0)
                    else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(0);
                end;
                if (FTarget <> nil) and FTarget.GetEnabled then
                  if (FFrame - 20 < FPath.Count) and (FFrame > 19) then begin
                    TTacticalCombatUnit(FTarget).FUnitHS.FOffsetX := FPath[FFrame - 20].X - FPath[0].X;
                    TTacticalCombatUnit(FTarget).FUnitHS.FOffsetY := FPath[FFrame - 20].Y - FPath[FFrame - 20].Z - FPath[0].Y;
                    TTacticalCombatUnit(FTarget).FUnitHS.SetDirection(TTacticalCombatUnit(FTarget).FUnitHS.FDirection + 1);
                    if TTacticalCombatUnit(FTarget).FUnitHS.FDirection > 6 then
                      TTacticalCombatUnit(FTarget).FUnitHS.SetDirection(1);
                    TTacticalCombatUnit(FTarget).FUnitHS.FBusy := True;
                  end;
                for I := FFrame - 20 to FFrame do
                  if (I >= 0) and (I < FPath.Count) then begin
                    Effect := AoWCombatMap.AddEffect(fxGeyserWater);
                    Effect.FAbilityIndex := FAbilityIndex;
                    Effect.FSpellIndex := FSpellIndex;
                    MakeSwarmPath(Random(5) + 20, (FPath.Count - I) div 5, 0, Random(360),
                      FPath[I].X + Random(10) - 5,
                      FPath[I].Y - FPath[I].Z + Random(10) - 5,
                      TSwarmDirection(Random(2)), Effect.FPath);
                  end;
              end else begin
                if (FTarget <> nil) and FTarget.GetEnabled then begin
                  if AoWCombatMap.FPlaySounds then
                    if FAbilityIndex = $34 then
                      AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
                    else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
                  HPtoHX(FPath[FPath.Count - 1].X, FPath[FPath.Count - 1].Y, J, K);
                  TTacticalCombatUnit(FTarget).FUnitHS.MoveTo(AoWCombatMap.MapContainer.MapLevels[0].Field[J, K], 0);
                  TTacticalCombatUnit(FTarget).FUnitHS.FOffsetX := 0;
                  TTacticalCombatUnit(FTarget).FUnitHS.FOffsetY := 0;
                  TTacticalCombatUnit(FTarget).FUnitHS.FBusy := False;
                end;
                FFrame := -1;
              end;
          end;
        end;
        fxSacFlame: begin
          case FFrame of
            0..99: begin
              if (FFrame = 0) and AoWCombatMap.FPlaySounds then begin
                if AoWCombatMap.FPlaySounds then
                  if FAbilityIndex = $34 then
                    AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(0)
                  else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(0);
              end;
              J := Random(6) + 10;
              HXtoHP(TTacticalCombatUnit(FTarget).FUnitHS.GetXhx,
                TTacticalCombatUnit(FTarget).FUnitHS.GetYhx, K, X);
              for I := 1 to J - 1 do begin
              Effect := AoWCombatMap.AddEffect(fxFrost);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(25) + 25) / 10;
              Gravity := 0.5;
              VZ := (Random(50) + FFrame) / 10;
              Z := 0;
              MakeArcPath(K + 16, X + 16, I * 360 div J, Z, Speed, VZ, Gravity, Effect.FPath);
              end;
              case FFrame of
                0, 20, 40, 60, 75, 85, 90, 94, 97, 99: begin
                  if AoWCombatMap.FPlaySounds then
                    if FAbilityIndex = $34 then
                      AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
                    else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
                  J := Random(10) + 100;
                  for I := 0 to J do begin
                    Effect := AoWCombatMap.AddEffect(fxFrost);
                    Effect.FAbilityIndex := FAbilityIndex;
                    Effect.FSpellIndex := FSpellIndex;
                    Speed := (Random(50) + 50) / 10;
                    Gravity := 0.1;
                    VZ := (Random(5) + 5) / 10;
                    Z := 0;
                    MakeArcPath(K + 16, X + 16, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
                  end;
                end;
              end;
            end;
            125..199: begin
              if FFrame = 125 then begin
                HPtoHX(FPath[0].X, FPath[0].Y, I, J);
                AoWCombatMap.CenterViewTo(I, J - 3, 0);
              end;
              if AoWCombatMap.FPlaySounds then
                if FAbilityIndex = $34 then
                  AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
                else AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
              J := Random(6) + 10;
              K := FPath[0].X + Random(160) - 80;
              X := FPath[0].Y + Random(80) - 40;
              for I := 1 to J - 1 do begin
              Effect := AoWCombatMap.AddEffect(fxFrost);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(50) + 25) / 10;
              Gravity := 0.5;
              VZ := (Random(50) + 100) / 10;
              Z := 0;
              MakeArcPath(K, X, I * 360 div J, Z, Speed, VZ, Gravity, Effect.FPath);
              end;
              J := Random(10) + 50;
              for I := 0 to J do begin
              Effect := AoWCombatMap.AddEffect(fxFrost);
              Effect.FAbilityIndex := FAbilityIndex;
              Effect.FSpellIndex := FSpellIndex;
              Speed := (Random(50) + 50) / 10;
              Gravity := 0.1;
              VZ := (Random(5) + 5) / 10;
              Z := 0;
              MakeArcPath(K, X, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
              end;
            end;
            200: FFrame := -1;
          end;
        end;
        fxMindDecay: begin
          case FFrame of
            0..49:
              if FFrame mod 2 > 0 then
                for I := 0 to FFrame do
                  for J := 0 to I div 25 do begin
                    Effect := AoWCombatMap.AddEffect(fxGeyserWater);
                    Effect.FAbilityIndex := FAbilityIndex;
                    Effect.FSpellIndex := FSpellIndex;
                    MakeSwarmPath(Random(10) + 10, I div 2, 45, Random(360),
                      FPath[0].X + 100 - I, FPath[0].Y - 200 - 50 + I,
                      TSwarmDirection(Random(2)), Effect.FPath);
                  end;
            50..149: begin
              if FFrame mod 2 > 0 then
                for I := 0 to 50 do
                  for J := 0 to I div 25 do begin
                    Effect := AoWCombatMap.AddEffect(fxGeyserWater);
                    Effect.FAbilityIndex := FAbilityIndex;
                    Effect.FSpellIndex := FSpellIndex;
                    MakeSwarmPath(Random(10) + 10, I div 2, 45, Random(360),
                      FPath[0].X + 100 - I, FPath[0].Y - 200 - 50 + I,
                      TSwarmDirection(Random(2)), Effect.FPath);
                  end;
              if (FFrame mod 5 = 0) and (FFrame <= 84) then begin
                Effect := AoWCombatMap.AddEffect(fxDecayComet);
                Effect.FAbilityIndex := FAbilityIndex;
                Effect.FSpellIndex := FSpellIndex;
                MakeArcPathXY(FPath[0].X + Random(50) + 25, FPath[0].Y + Random(50) - 225,
                  FPath[0].X + Random(50) - 25, FPath[0].Y + Random(50) - 25,
                  Random(5) + 5, 100, Effect.FPath);
                for I := 0 to 10 do begin
                  Speed := (Random(50) + 50) / 10;
                  Gravity := 1.5;
                  VZ := (Random(25) + 25) / 10;
                  Z := 0;
                  MakeArcPath(Effect.FPath[Effect.FPath.Count - 1].X, Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
                end;
                CenterHNtoHX(FTargetX, FTargetY, (FFrame - 50) div 5, J, K);
                HXtoHP(J, K, X, Y); { Original swaps the converted hex coordinates. }
                UnitHS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].Field[J, K].FindOwnedChild($220104));
                if (UnitHS <> nil) and (UnitHS.FUnit.GetSide <> FTarget.GetSide) then
                  Effect.FTarget := UnitHS.FUnit
                else Effect.FTarget := nil;
                if Effect.FTarget <> nil then begin
                  MakeArcPathXY(Effect.FPath[Effect.FPath.Count - 1].X,
                    Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z,
                    X + 16, Y - 8, Random(3) + 6, 100, Effect.FPath);
                  for I := 0 to Random(3) + 5 do begin
                    MakeLinePath(Effect.FPath[Effect.FPath.Count - 1].X,
                      Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z,
                      Effect.FPath[Effect.FPath.Count - 1].X,
                      Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z - 6,
                      3, Effect.FPath);
                    MakeLinePath(Effect.FPath[Effect.FPath.Count - 1].X,
                      Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z,
                      Effect.FPath[Effect.FPath.Count - 1].X,
                      Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z + 6,
                      3, Effect.FPath);
                  end;
                end;
              end;
            end;
            200: begin FFrame := -1; FTarget := nil; end;
          end;
        end;
        fxChain: begin
          NewPath := TXYZList.Create;
          I := 0;
          J := 0;
          K := 0;
          while I < FPath.Count do begin
            if FPath[I].Z > 0 then begin
              if FPath[I].Z > 1 then K := FPath[I].Z;
              MakeLightningPath(FPath[J].X, FPath[J].Y, FPath[I].X, FPath[I].Y, NewPath);
              case K of
                -1: begin
                  NewPath[NewPath.Count - 1].Z := 16;
                  FFrame := NewPath.Count - 1;
                  K := 0;
                end;
                2..16: begin
                  NewPath[NewPath.Count - 1].Z := K - 1;
                  FFrame := NewPath.Count - 1;
                  if K = 2 then K := -1 else K := 0;
                end;
              end;
              J := I;
            end;
            Inc(I);
          end;
          FPath.Free;
          FPath := NewPath;
          if FFrame >= FPath.Count - 1 then begin
            FFrame := FPath.Count - 1;
            if FPath[FFrame].Z < 2 then FDone := True;
          end;
          if FPath[FFrame].Z = 15 then begin
            if AoWCombatMap.FPlaySounds then
              if FAbilityIndex = $34 then
                AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
              else
                AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
            HPtoHX(FPath[FFrame].X, FPath[FFrame].Y - FPath[FFrame].Z, I, J);
            AoWCombatMap.MakeVisible(I, J, 0, 3);
          end;
        end;
        fxTouch, fxEffect: begin
          if (FFrame = 0) and AoWCombatMap.FPlaySounds and (FAbilityIndex = $41) then
            AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(0);
          if FAbilityIndex = $34 then
            Sequence := AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastImages.ImageSequences[0]
          else Sequence := AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FImageSequences.ImageSequences[0];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
            if AoWCombatMap.FPlaySounds then
              if FAbilityIndex = $34 then
                AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
              else
                AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxSacredWrath: begin
          if FAbilityIndex = $34 then
            Sequence := AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastImages.ImageSequences[1]
          else Sequence := AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FImageSequences.ImageSequences[1];
          if Sequence = nil then FFrame := -1;
        end;
        fxFBExplosion: begin
          Sequence := AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastImages.ImageSequences[1];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxScreenNESW: begin
          if FFrame = 0 then
            if FPath[0].X = 0 then begin
              FPath[0].X := 100;
              FPath[0].Y := Random(50);
            end else begin
              FPath[0].X := Random(50) + 50;
              FPath[0].Y := 0;
            end
          else begin
            Dec(FPath[0].X, 3);
            Inc(FPath[0].Y, 3);
            if (FPath[0].X < 0) or (FPath[0].Y > 100) then FFrame := -1;
          end;
        end;
        fxDamLightning, fxDamFire, fxDamPoison, fxDamMagic, fxDamHoly, fxDamDeath, fxDamCold,
        fxGeyserWater, fxFrost, fxSacFire: begin
          if FFrame >= FPath.Count - 1 then begin
            FFrame := FPath.Count - 1;
            FDone := True;
          end;
        end;
        fxHailImpact: begin
          if FAbilityIndex = $34 then
            Sequence := AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastImages.ImageSequences[2]
          else Sequence := AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FImageSequences.ImageSequences[2];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxBlood: begin
          Sequence := AoWHSSet.FImageSequences.ImageSequences[FPath[0].Z];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxHitGround: begin
          Sequence := AoWHSSet.FImageSequences.ImageSequences[9];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames then begin
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxHitWater: begin
          Sequence := AoWHSSet.FImageSequences.ImageSequences[10];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames then begin
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxAltArrow: begin
          if (FFrame = 0) and AoWCombatMap.FPlaySounds and (FAbilityIndex = $34) then
            AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(0);
          Inc(FFrame, 3);
          if FFrame >= FPath.Count - 1 then begin
            if AoWCombatMap.FPlaySounds then
              if FAbilityIndex = $34 then
                AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
              else
                AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
            FFrame := FPath.Count - 1;
            FDone := True;
            if FTarget = nil then MakeImpact;
            HPtoHX(FPath[FFrame].X, FPath[FFrame].Y - FPath[FFrame].Z, I, J);
            AoWCombatMap.MakeVisible(I, J, 0, 2);
          end;
        end;
        fxGeyser: begin
          case FFrame of
            0..99: begin
              if AoWCombatMap.FPlaySounds and (FFrame mod 30 = 29) then begin
                if AoWCombatMap.FPlaySounds then
                  if FAbilityIndex = $34 then
                    AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(0)
                  else
                    AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(0);
              end;
              if (FTarget <> nil) and FTarget.GetEnabled then begin
                TTacticalCombatUnit(FTarget).FUnitHS.FOffsetY := Random(2) + -(FFrame * 3 div 2) - 1;
                TTacticalCombatUnit(FTarget).FUnitHS.FBusy := True;
              end;
              J := Random(6) + 20;
              for I := 1 to J - 1 do begin
                Effect := AoWCombatMap.AddEffect(fxGeyserWater);
                Effect.FAbilityIndex := FAbilityIndex;
                Effect.FSpellIndex := FSpellIndex;
                Speed := (Random(10) + 10) / 10;
                Gravity := 0.5;
                VZ := (Random(50) + FFrame * 3 * 0.5) / 10;
                Z := 0;
                MakeArcPath(FPath[0].X, FPath[0].Y, I * 360 div J, Z, Speed, VZ, Gravity, Effect.FPath);
              end;
            end;
            125..149: if (FTarget <> nil) and FTarget.GetEnabled then begin
              TTacticalCombatUnit(FTarget).FUnitHS.FOffsetY := (FFrame - 150) * 6;
              TTacticalCombatUnit(FTarget).FUnitHS.SetDirection(FFrame mod 6);
            end;
            150: begin
              FFrame := -1;
              if (FTarget <> nil) and FTarget.GetEnabled then begin
                if AoWCombatMap.FPlaySounds then
                  if FAbilityIndex = $34 then
                    AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastSounds.Play(1)
                  else
                    AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FSFXLibrary.Play(1);
                TTacticalCombatUnit(FTarget).FUnitHS.FOffsetY := 0;
                TTacticalCombatUnit(FTarget).FUnitHS.FBusy := False;
              end;
              if (FTarget <> nil) and (mtFlying in TTacticalCombatUnit(FTarget).FUnit.GetMoveTypes) then FTarget := nil;
            end;
          end;
        end;
        fxCloudPuff: begin
          if FAbilityIndex = $34 then
            Sequence := AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastImages.ImageSequences[0]
          else Sequence := AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FImageSequences.ImageSequences[0];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames - 1 then begin
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxHighPrayer: begin
          case FFrame of
            0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95:
              for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
                if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
                  AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled and
                  (AoWCombatMap.FCombat.FCombatData.GetObjects(I).FCombatPlayer = FTarget.FCombatPlayer) then begin
                  Effect := AoWCombatMap.AddEffect(fxGeyserWater);
                  HXtoHP(TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.GetXhx,
                    TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.GetYhx, J, K);
                  J := Random(20) + (J + 6);
                  K := Random(20) + (K + 6);
                  MakeLinePath(J, K - 100, J, K, 50, Effect.FPath);
                  Effect.FAbilityIndex := FAbilityIndex;
                  Effect.FSpellIndex := FSpellIndex;
                end;
            100: begin
              for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
                if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
                  AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled and
                  (AoWCombatMap.FCombat.FCombatData.GetObjects(I).FCombatPlayer = FTarget.FCombatPlayer) then begin
                  Effect := AoWCombatMap.AddEffect(fxPrayerGlow);
                  HXtoHP(TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.GetXhx,
                    TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.GetYhx, J, K);
                  Effect.FPath.Add(TXYZ.Create);
                  Effect.FPath[0].X := J + 16;
                  Effect.FPath[0].Y := K + 16;
                  Effect.FAbilityIndex := FAbilityIndex;
                  Effect.FSpellIndex := FSpellIndex;
                  Effect.FTarget := AoWCombatMap.FCombat.FCombatData.GetObjects(I);
                end;
              FFrame := -1;
              FTarget := nil;
            end;
          end;
        end;
        fxResurrect: if FFrame = 100 then FFrame := -1;
        fxDecayLeg: if FFrame >= FPath.Count then FFrame := -1;
        fxWallSmoke: begin
          Sequence := AoWHSSet.FImageSequences.ImageSequences[5];
          if Sequence = nil then FFrame := -1
          else if FFrame >= Sequence.GetTotalSequenceFrames then begin
            FFrame := Sequence.GetTotalSequenceFrames - 1;
            FDone := True;
          end;
        end;
        fxSWComet: ;
      else FFrame := -1;
      end;
    end;
    if FFrame = -1 then FDone := True;
  except
    MessageBox(0, PChar('Error - fxHS ' + IntToStr(FAbilityIndex) + ' ' + IntToStr(FSpellIndex)),
      'Error during NewFrame', 0);
  end;
end;

procedure TfxHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  Index: Integer;
  FirstSequence: TImageSequence;
  I, J: Integer;

  procedure SelectSequence(Number: Integer);
  begin
    if FAbilityIndex = $34 then
      Sequence := AoWHSSet.FSpellControl.GetSpell(FSpellIndex).FCastImages.ImageSequences[Number]
    else Sequence := AoWHSSet.FAbilityControl.GetAbility(FAbilityIndex).FImageSequences.ImageSequences[Number];
  end;

  procedure SelectFrame;
  begin
    if Sequence <> nil then Index := Sequence.GetUnloopedFrameIndex(FFrame);
    FirstSequence := Sequence;
  end;

  procedure SelectDamageSequence;
  var N: Integer;
  begin
    case FEffectType of
      fxDamLightning: N := 40; fxDamFire: N := 41; fxDamPoison: N := 42;
      fxDamMagic: N := 43; fxDamHoly: N := 44; fxDamDeath: N := 45;
    else N := 46;
    end;
    Sequence := AoWHSSet.FImageSequences.ImageSequences[N];
  end;

  procedure ShowMovingLoop;
  begin
    while Sequence <> nil do begin
      Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
      if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
        Sequence.ImageLibrary[Index].ShowClipped(
          FPath[FFrame].X - XhpSurf + Sequence.dXshift,
          FPath[FFrame].Y - FPath[FFrame].Z - YhpSurf + Sequence.dYshift, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
  end;

  procedure ShowSecondaryFrame;
  begin
    while Sequence <> nil do begin
      Index := Sequence.GetUnloopedFrameIndex(FVariant);
      if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
        Sequence.ImageLibrary[Index].ShowClipped(
          FPath[FFrame].X - XhpSurf + Sequence.dXshift,
          FPath[FFrame].Y - FPath[FFrame].Z - YhpSurf + Sequence.dYshift, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
  end;

  procedure ShowTrail;
  var N, LastFrame, Half: Integer;
  begin
    if Sequence <> nil then begin
      LastFrame := Sequence.GetTotalSequenceFrames - 1;
      for N := 0 to LastFrame do begin
        Half := N div 2;
        if (FFrame - 9 + Half + 5 > -1) and (FFrame - 9 + Half + 5 < FPath.Count) then begin
          Index := Sequence.GetUnloopedFrameIndex(LastFrame - N);
          if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
            if (FFrame - 9 + Half + 5 <> FPath.Count - 1) and (Half * 2 <> N) then
              Sequence.ImageLibrary[Index].ShowClipped(
                (FPath[FFrame - 9 + Half + 5].X + FPath[FFrame - 9 + Half + 6].X) div 2 -
                  XhpSurf + Sequence.dXshift,
                (FPath[FFrame - 9 + Half + 5].Y - FPath[FFrame - 9 + Half + 5].Z +
                  FPath[FFrame - 9 + Half + 6].Y - FPath[FFrame - 9 + Half + 6].Z) div 2 -
                  YhpSurf + Sequence.dYshift, SurfaceDesc)
            else
              Sequence.ImageLibrary[Index].ShowClipped(
                FPath[FFrame - 9 + Half + 5].X - XhpSurf + Sequence.dXshift,
                FPath[FFrame - 9 + Half + 5].Y - FPath[FFrame - 9 + Half + 5].Z -
                  YhpSurf + Sequence.dYshift, SurfaceDesc);
        end;
      end;
    end;
  end;

  procedure ShowRay;
  var N: Integer;
  begin
    if Sequence <> nil then
      for N := 0 to FFrame do begin
        Index := Sequence.GetUnloopedFrameIndex(0);
        if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
          Sequence.ImageLibrary[Index].ShowClipped(
            FPath[N].X - XhpSurf + Sequence.dXshift,
            FPath[N].Y - FPath[N].Z - YhpSurf + Sequence.dYshift, SurfaceDesc);
      end;
  end;

  procedure ShowFrostBeam;
  var N, Alpha: Integer;
  begin
    case FFrame of 0..1999: SelectSequence(0); else SelectSequence(1); end;
    if Sequence <> nil then begin
      N := 0;
      while N <= FFrame do begin
        case FFrame of
          0..1999: begin
            Alpha := 25;
            { Original uses the object address as the animation phase. }
            Index := Sequence.GetUnloopedFrameIndex(Integer(Self) mod Sequence.GetTotalSequenceFrames);
          end;
          2000..2998:
            if N > FFrame - 2000 then begin
              if N = FFrame - 1999 then SelectSequence(0);
              Alpha := 25;
              Index := Sequence.GetUnloopedFrameIndex(Integer(Self) mod Sequence.GetTotalSequenceFrames);
            end else begin
              Alpha := (FFrame - 2000) * 75 div (FPath.Count - 1) + 25;
              Index := Sequence.GetUnloopedFrameIndex(0);
            end;
        else Alpha := 100; Index := Sequence.GetUnloopedFrameIndex(0);
        end;
        if N >= FPath.Count then Exit;
        if Index <> -1 then
          Sequence.ImageLibrary[Index].ShowBlended(
            FPath[N].X - XhpSurf + Sequence.dXshift,
            FPath[N].Y - FPath[N].Z - YhpSurf + Sequence.dYshift,
            SurfaceDesc, IntensityBlendTable.LookupTables[Alpha]);
        Inc(N);
      end;
    end;
  end;

  procedure ShowAtStart;
  begin
    while Sequence <> nil do begin
      Index := Sequence.GetUnloopedFrameIndex(FFrame);
      if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
        Sequence.ImageLibrary[Index].ShowClipped(
          FPath[0].X - XhpSurf + Sequence.dXshift,
          FPath[0].Y - YhpSurf + Sequence.dYshift, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
  end;

  procedure ShowAtStartLooped;
  begin
    while Sequence <> nil do begin
      Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
      if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
        Sequence.ImageLibrary[Index].ShowClipped(
          FPath[0].X - XhpSurf + Sequence.dXshift,
          FPath[0].Y - YhpSurf + Sequence.dYshift, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
  end;

  procedure ShowScreen;
  begin
    while Sequence <> nil do begin
      if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
        Sequence.ImageLibrary[Index].ShowClipped(
          (Sequence.ImageLibrary[Index].Width + SurfaceDesc.Width) * FPath[0].X div 100 -
            Sequence.ImageLibrary[Index].Width,
          (Sequence.ImageLibrary[Index].Height + SurfaceDesc.Height) * FPath[0].Y div 100 -
            Sequence.ImageLibrary[Index].Height, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
  end;

  procedure ShowScreenSwarm;
  var Alpha: Integer;
  begin
    Alpha := (100 - FPath[FFrame].Z) div 2 - ((FFrame mod 10) * 2 + Integer(Self)) mod 20;
    if Alpha < 0 then Alpha := 0;
    while Sequence <> nil do begin
      Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
      if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
        Sequence.ImageLibrary[Index].ShowBlended(
          (XhpSurf + SurfaceDesc.Width - FPath[0].X + 100) * FPath[FFrame].Z div 100 +
            (FPath[0].X - XhpSurf) + FPath[FFrame].X,
          (FPath[0].Y - YhpSurf + 100) * (100 - FPath[FFrame].Z) div 100 + FPath[FFrame].Y - 100,
          SurfaceDesc, IntensityBlendTable.LookupTables[Alpha]);
      Sequence := Sequence.Next;
    end;
  end;

  procedure ShowParticle(Shadow: Boolean);
  var Alpha: Integer;
  begin
    Alpha := 100 - FFrame * 100 div FPath.Count - ((FFrame mod 10) * 2 + Integer(Self)) mod 20;
    if Alpha < 0 then Alpha := 0;
    if Shadow then Inc(Alpha, 20);
    if Alpha > 100 then Alpha := 100;
    while Sequence <> nil do begin
      { Original uses the object address rather than the current frame. }
      Index := Sequence.GetUnloopedFrameIndex(Integer(Self) mod 3);
      if Index <> -1 then
        if Shadow then begin
          if Sequence.ImageLibrary.ImageExist(Index) then
            Sequence.ImageLibrary[Index].ShowBlended(
              FPath[FFrame].X - XhpSurf + Sequence.dXshift,
              FPath[FFrame].Y - FPath[FFrame].Z - YhpSurf + Sequence.dYshift,
              SurfaceDesc, ShadowBlendTable.LookupTables[Alpha]);
        end else begin
          if Sequence.ImageLibrary.ImageExist(Index) then
            Sequence.ImageLibrary[Index].ShowBlended(
              FPath[FFrame].X - XhpSurf + Sequence.dXshift,
              FPath[FFrame].Y - FPath[FFrame].Z - YhpSurf + Sequence.dYshift,
              SurfaceDesc, IntensityBlendTable.LookupTables[Alpha]);
        end;
      Sequence := Sequence.Next;
    end;
  end;

  procedure FinishPath;
  begin
    if FFrame >= FPath.Count - 1 then begin FDone := True; FFrame := -1; end;
  end;

  procedure FinishSequence;
  begin
    if (FirstSequence = nil) or ((FirstSequence <> nil) and
      (FFrame >= FirstSequence.GetTotalSequenceFrames - 1)) then begin
      FDone := True;
      FFrame := -1;
    end;
  end;

begin
  try
    if FFrame >= 0 then begin
      Sequence := nil;
      Index := 0;
      case FEffectType of
        fxArrow: begin SelectSequence(FVariant); ShowMovingLoop; FinishPath; end;
        fxRock: begin SelectSequence(0); ShowMovingLoop; FinishPath; end;
        fxBreath: begin SelectSequence(0); ShowTrail; FinishPath; end;
        fxCometBall, fxScreenNS: begin SelectSequence(0); ShowMovingLoop; SelectSequence(1); ShowTrail; FinishPath; end;
        fxComet, fxDecayComet: begin SelectSequence(0); ShowTrail; FinishPath; end;
        fxTouch, fxEffect: begin SelectSequence(0); SelectFrame; ShowAtStart; FinishSequence; end;
        fxFBExplosion: begin
          SelectSequence(1);
          if Sequence <> nil then begin SelectFrame; ShowAtStart; FinishSequence; end;
        end;
        fxScreenNESW: begin
          SelectSequence(Integer(Self) mod 3);
          Index := Sequence.GetUnloopedFrameIndex(0);
          ShowScreen;
        end;
        fxRay: begin SelectSequence(0); ShowRay; FinishPath; end;
        fxChain: begin
          SelectSequence(0); ShowRay;
          if (FFrame >= FPath.Count - 1) and (FPath[FFrame].Z = 1) then FFrame := -1;
        end;
        fxSwarm: begin SelectSequence(0); ShowMovingLoop; FinishPath; end;
        fxScreenSwarm: begin SelectSequence(0); ShowScreenSwarm; FinishPath; end;
        fxSFOverlay: begin
          SelectSequence(2);
          if Sequence <> nil then begin
            Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
            ShowAtStart; FinishPath;
          end;
        end;
        fxDamLightning..fxDamCold: begin SelectDamageSequence; ShowParticle(FEffectType = fxDamDeath); FinishPath; end;
        fxSacredWrath: begin
          if FFrame in [5..6] then begin
            SelectSequence(2);
            while Sequence <> nil do begin
              Index := Sequence.GetUnloopedFrameIndex(0);
              if (Index <> -1) and Sequence.ImageLibrary.ImageExist(Index) then
                for I := 0 to SurfaceDesc.Width div Sequence.ImageLibrary[Index].Width do
                  for J := 0 to SurfaceDesc.Height div Sequence.ImageLibrary[Index].Height do
                    Sequence.ImageLibrary[Index].ShowClipped(
                      Sequence.ImageLibrary[Index].Width * I, Sequence.ImageLibrary[Index].Height * J, SurfaceDesc);
              Sequence := Sequence.Next;
            end;
          end;
          SelectSequence(1);
          if Sequence <> nil then begin SelectFrame; ShowAtStart; FinishSequence; end;
        end;
        fxSWComet: begin
          HXtoHP(TTacticalCombatUnit(FTarget).FUnitHS.GetXhx, TTacticalCombatUnit(FTarget).FUnitHS.GetYhx, I, J);
          MakeArcPathXY(SurfaceDesc.Width div 2 + XhpSurf, SurfaceDesc.Height div 2 + YhpSurf, I, J, 25, 50, FPath);
          FEffectType := fxComet;
          SelectSequence(0); ShowTrail;
        end;
        fxWallSmoke: begin Sequence := AoWHSSet.FImageSequences.ImageSequences[5]; SelectFrame; ShowAtStart; FinishSequence; end;
        fxBlood: begin Sequence := AoWHSSet.FImageSequences.ImageSequences[FPath[0].Z]; SelectFrame; ShowAtStart; FinishSequence; end;
        fxAltArrow: begin SelectSequence(0); ShowSecondaryFrame; SelectSequence(1); ShowTrail; FinishPath; end;
        fxTremors:
          if FFrame < 5 then begin SelectSequence(1); ShowAtStart; end
          else begin SelectSequence(2); ShowAtStartLooped; end;
        fxGeyser: begin SelectSequence(0); ShowParticle((FSpellIndex = $82) or (FSpellIndex = $6A)); FinishPath; end;
        fxGeyserWater: begin SelectSequence(2); SelectFrame; ShowAtStart; FinishSequence; end;
        fxCloudPuff: begin SelectSequence(0); SelectFrame; ShowAtStart; FinishSequence; end;
        fxHitGround: begin Sequence := AoWHSSet.FImageSequences.ImageSequences[9]; SelectFrame; ShowAtStart; FinishSequence; end;
        fxHitWater: begin Sequence := AoWHSSet.FImageSequences.ImageSequences[10]; SelectFrame; ShowAtStart; FinishSequence; end;
        fxPrayerGlow: begin SelectSequence(1); SelectFrame; ShowAtStart; FinishSequence; end;
        fxFrostBeam: ShowFrostBeam;
        fxFrost: begin SelectSequence(1); ShowParticle(FSpellIndex = $82); FinishPath; end;
        fxDecayLeg: begin SelectSequence(0); ShowRay; FCancelled := True; end;
        fxSacFire: begin SelectSequence(0); ShowMovingLoop; FinishPath; end;
      end;
    end;
  except
    MessageBox(0, PChar('Error - fxHS ' + IntToStr(FAbilityIndex) + ' ' + IntToStr(FSpellIndex)), 'Error during Show', 0);
  end;
end;

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
var X, Y: Integer;
begin
  case Ability of
    $37: MakeRangedPath(Side, 25, 0, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
    $16, $18, $19: MakeRangedPath(Side, 50, 100, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
    $2C, $2D, $39, $3A, $7B: MakeRangedPath(Side, 50, 20, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
    $1E, $1F, $56..$5A: begin
      Path.Add(TXYZ.Create);
      HXtoHP(X1, Y1, X, Y);
      Path[0].X := X + 12;
      Path[0].Y := Y + 12;
      Obstacles.Clear;
    end;
    $34: begin
      case Spell of
        $64: MakeRangedPath(Side, 50, 35, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
        $67: MakeRangedPath(Side, 25, 0, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
        $6B: begin
          MakeRangedPath(Side, 25, 0, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
          Obstacles.Clear;
        end;
        $75: MakeRangedPath(Side, 50, 50, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
        $77: MakeRangedPath(Side, 50, 20, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
      else
        case SpellTypes[Spell] of
          fxBreath, fxEffect, fxScreenNS, fxScreenSwarm, fxGeyser, fxTremors,
          fxCloud, fxResurrect, fxFrostBeam, fxMindDecay, fxShockWave, fxSacFlame, fxWinds: begin
            Path.Add(TXYZ.Create);
            HXtoHP(X1, Y1, X, Y);
            Path[0].X := X + 12;
            Path[0].Y := Y + 12;
            Obstacles.Clear;
          end;
        else MakeRangedPath(Side, 50, 50, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
        end;
      end;
    end;
  else MakeRangedPath(Side, 50, 50, 50, X1, Y1, X2, Y2, 0, 0, True, Path, Obstacles);
  end;
end;

procedure MakeRangedPath(Side: TCombatSideIndex; Speed, Arc, UnusedHeight: Smallint;
  X1, Y1, X2, Y2, OffsetX, OffsetY: Smallint; IncludeUnits: Boolean;
  var Path: TXYZList; var Obstacles: TList);
var
  I, A, B, NX, NY, Steps: Integer;
  X, Y, LastX, LastY, StartX, StartY, EndX, EndY: Integer;
  Point: TXYZ;
  Height: Single;
  Obstacle: TROb;
  UnitHS: TTacticalCombatUnitHS;
  Wall: TCityWall;
begin
  Path.Clear;
  Obstacles.Clear;
  HXtoHP(X1, Y1, X, Y);
  HXtoHP(X2, Y2, LastX, LastY);
  Inc(X, 13);
  Inc(Y, 13);
  LastX := LastX + 13 + OffsetX;
  LastY := LastY + 13 + OffsetY;
  I := 0;
  A := Abs(X2 - X1);
  B := Abs(Y2 - Y1);
  Steps := (A + B) * 100 div Speed;
  if Steps < 2 then Steps := 2;
  while I <= Steps do begin
    Point := TXYZ.Create;
    Path.Add(Point);
    Point.X := (LastX - X) * I div Steps + X;
    Point.Y := (LastY - Y) * I div Steps + Y;
    B := Steps div 2;
    if I > B then A := Steps - I + 1
    else if I = B then A := I
    else A := I + 1;
    if Arc = 0 then Point.Z := 0
    else begin
      Height := A * Steps * Arc div 10;
      Point.Z := Round(Sqrt(Height)) - Steps * 10 div Arc;
    end;
    Inc(I);
  end;
  LastX := 0;
  LastY := 0;
  Point := Path[0];
  HPtoHX(Point.X, Point.Y, StartX, StartY);
  Point := Path[Path.Count - 1];
  HPtoHX(Point.X, Point.Y, EndX, EndY);
  for I := 0 to Path.Count - 1 do begin
    Point := Path[I];
    HPtoHX(Point.X, Point.Y, X, Y);
    if ((X <> StartX) or (Y <> StartY)) and ((X <> EndX) or (Y <> EndY)) then begin
      Steps := 0;
      if AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].TerrainType = 15 then Steps := 3
      else if AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].TerrainType = 7 then Steps := 3
      else begin
        A := dHXtoRad(X, Y, StartX, StartY);
        if IncludeUnits then UnitHS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].FindOwnedChild($220104))
        else UnitHS := nil;
        Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].FindOwnedChild($220504));
        if (Wall = nil) and (Side = csAttacker) then Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].FindOwnedChild($220506));
        if A = 1 then begin
          if (UnitHS <> nil) and (UnitHS.FUnit.GetSide <> Side) then Steps := 1;
          if (Wall <> nil) and (Wall.FHitPoints > 0) and (Side = csAttacker) then Steps := 4;
        end else if A > 1 then begin
          if UnitHS <> nil then Steps := 1;
          if Wall <> nil then begin
            if Wall.FHitPoints > 0 then
              if A < 3 then begin
                Wall := nil;
                B := 1;
                while (Wall = nil) and (B < 7) do begin
                  CenterHNtoHX(StartX, StartY, B, NX, NY);
                  Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[NX, NY].FindOwnedChild($220504));
                  if Wall = nil then Wall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].Field[NX, NY].FindOwnedChild($220506));
                  Inc(B);
                end;
                if Wall = nil then Steps := 2;
              end else Steps := 2;
          end else if AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].OverlayType = 8 then Steps := 1;
        end;
      end;
      if Steps > 0 then begin
        if Steps = 1 then begin
          HXtoHP(X, Y, A, B);
          A := Point.X + 11 - A;
          if A > 23 then A := 47 - A;
          B := Point.Y + 3 - B;
          if B > 15 then B := 31 - B;
          A := (A + B - Point.Z) * 2;
        end else if Steps = 2 then A := 200 - Point.Z * 3
        else if Steps = 3 then A := 100
        else if Steps = 4 then A := 50;
        if A > 0 then begin
          if (X = LastX) and (Y = LastY) then begin
            Obstacle := Obstacles[Obstacles.Count - 1];
            if (Steps = 2) and (Obstacle.Chance < A) then Obstacle.Chance := A;
          end else begin
            Obstacle := TROb.Create;
            Obstacle.PathIndex := I;
            Obstacles.Add(Obstacle);
            LastX := X;
            LastY := Y;
            Steps := 1;
          end;
          if (Steps <> 2) and (Steps <> 4) then Inc(Obstacle.Chance, A);
          if Obstacle.Chance > 100 then Obstacle.Chance := 100;
        end;
      end;
    end;
  end;
end;

procedure RegisterAoWTCClasses(AEngine: TEngine);
begin
  AoWEngine.RegisterEClasses([TAoWCombatMap, TAoWCombatMapLevel, TUnitPositionHS, TTacticalCombat]);
end;

function GetMeleeDirIndex(A1: Integer; A2: Integer; A3: Integer): Word;
begin
  Result := 1;
  case A3 of
    -1: case A2 of -1: Result := 3; 0: Result := 4; 1: Result := 5; end;
    0: case A2 of
      -1: if A1 div 2 * 2 = A1 then Result := 3 else Result := 2;
      1: if A1 div 2 * 2 = A1 then Result := 5 else Result := 6;
    end;
    1: case A2 of -1: Result := 2; 0: Result := 1; 1: Result := 6; end;
  end;
end;
function GetRangedDirIndex(A1: Integer; A2: Integer): Word;
var Ratio: Integer;
begin
  if A1 = 0 then Result := 0
  else begin
    Ratio := Abs(A2 * 100 div A1);
    case Ratio of
      0..12: Result := 6;
      13..40: Result := 5;
      41..76: Result := 4;
      77..129: Result := 3;
      130..240: Result := 2;
      241..759: Result := 1;
    else Result := 0;
    end;
  end;
  if A2 > 0 then Result := 12 - Result;
  if (A1 < 0) and (Result <> 0) then Result := 24 - Result;
end;


initialization
finalization

end.
