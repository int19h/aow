{ Interface declaration run owned by P1. }
  { TRaceResource: size $48; $18 face library, $1C city library, $20 library name,
    $24 name, $28 race name, $2C description, $30 alignments, $34 references,
    $38 units, $3C hero unit, $40 special units, $44 hero names. VMT 55713838. }
  TRaceResource = class(TEResource)
  public
    FFaceLibrary: TCustomImageLibrary; { $18 }
    FImageLibrary: TCustomImageLibrary; { $1C }
    { conflict: FImageLibrary: TImageLibrary; }
    FImageLibraryName: string; { $20 }
    FName: string; { $24 }
    FRaceName: string;  { $28 }
    FDescription: string; { $2C }
    FAlignments: TAlignments; { $30 }
    F_RaceResource_31: array[0..2] of Byte;
    FReferences: Integer; { $34 }
    FUnitIndexes: TUnitIndexList;  { $38 }
    FHeroUnitIndex: Integer; { $3C }
    FSpecialUnitIndexes: TUnitIndexList; { $40 }
    FHeroNames: TStringList; { $44 }
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
    function GetFace: TLibraryImage;
    function GetRaceIndex: Integer;
    procedure LinkToIL;
    procedure ReleaseIL;
    procedure SetImageLibraryName(Value: string);
    function GetCityImage(Size, Terrain, Level: Integer): TLibraryImage;
    function GetAlignment: TAlignment;
  end;

  { TRaceResourceList: size $14, no added fields. VMT 55713938. }
  TRaceResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetRaceResource(Index: Integer): TRaceResource;
    function GetMaxRaceIndex: Integer;
  end;

  { TStructureShadow: size $10; $08 connected/visible flags, $0C structure. VMT 55713A94. }
  TStructureShadow = class(THexagonSprite)
  public
    FShadowStatus: TStructureShadowStatus; { $08 }
    F_StructureShadow_09: array[0..2] of Byte;
    FStructure: TStructure; { $0C }
    destructor Destroy; override;
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TStructure: size $30; $1C ID, $20 update count, $24 building player,
    $25 days left, $28 shadow, $2C fogged. VMT 55713C18. }
  TStructure = class(TFixedILTerrainMO)
  public
    FStructureID: Integer; { $1C }
    FUpdateCount: Integer; { $20 }
    FBuildingPlayer: Shortint; { $24 }
    FBuildingDays: Byte; { $25 }
    F_Structure_26: array[0..1] of Byte;
    FShadow: TStructureShadow; { $28 }
    FFogged: Boolean; { $2C }
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
    function GetTopBorderImage: TLibraryImage; virtual;
    function GetMiddleBorderImage: TLibraryImage; virtual;
    function GetBottomBorderImage: TLibraryImage; virtual;
    function GetDescription: TStrings; virtual; { $144 }
    function GetName: string; virtual;
    procedure SetRazed(Value: Boolean); virtual;
    function GetRazed: Boolean; virtual;
    function GetRazeable: Boolean; virtual; { $154; 557D7523 }
    function RazeEx(Player: Shortint): Boolean; virtual;  { $158 }
    procedure SetupRazeDefenderAG(Attackers, Defenders: TUnitList); virtual;
    function CreateTE: TStructureTE; virtual;
    procedure SetupTE(A1: TStructureTE); virtual;
    function ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult; virtual;
    function GetDefenseRequirements(Player: Shortint; var Requirements: TDefenseRequirements): Boolean; virtual;
    function GetDefensePriority: TDefensePriority; virtual;
    procedure NewDay; virtual;  { $174 }
    procedure NewTurn(Player: Shortint); virtual;
    procedure SeatedPlayerChanged; virtual;  { $17C }
    procedure ArmyPlaced(A1: TArmyHS); virtual; { +180 }
    procedure ArmyRemoved(Army: TArmyHS); virtual;  { $184 }
    procedure ArmyChanged(Army: TArmyHS); virtual;  { $188 }
    procedure PlaySelectSample; virtual;  { $18C }
    procedure CreateShadow; virtual;  { $190 }
    procedure DestroyShadow; virtual;  { $194 }
    procedure ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); virtual; { $198 }
    procedure BuildingDone; virtual;  { $19C }
    function ExecuteRebuild(AUnit: TAbstractUnit): Boolean; virtual; { $1A0 }
    function ExecuteBuild(AUnit: TAbstractUnit; Days: Integer): Boolean; virtual;  { $1A4 }
    function GenerateRazeDefenders(Player: Shortint; Units: TUnitList): Boolean; virtual;
    function PlaceRazeDefenders(Player: Shortint): Boolean; virtual;  { $1AC }
    function ExecuteRaze(Player: Shortint): Boolean; virtual;
    function GetCurrentActivityText: string; virtual;
    function ValidateMap(Messages: TStrings): Boolean; virtual;  { +1B8  }
    function MainValidateMap(Messages: TStrings): Boolean; virtual;  { $1BC }
    function ExecuteAI(Player: Shortint; Phase: Integer): Boolean; virtual;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); virtual;
    procedure Update; virtual;  { $1C8 }
    function VisibleForPlayer(Player: Shortint): Boolean; virtual;
    function CanDblClick: Boolean; virtual;
    function ListUnits(List: TUnitList): Integer; virtual;
    function ListArmies(List: TArmyHSList): Integer; virtual;
    procedure GetRebuildInfo(var Cost, Time: Integer); virtual;
    function CanRebuild(AUnit: TAbstractUnit; var Reason: string): Boolean; virtual;  { $1E0 }
    function Rebuild(AUnit: TAbstractUnit): Boolean; virtual;  { $1E4 }
    function Raze(Player: Shortint): Boolean; virtual; { $1E8; 557D7432 }
    function CanRaze(Player: Shortint; var Reason: string): Boolean; virtual;  { $1EC }
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure UpdateRoads(MapField: TMapField);
    function GetPlayer: Shortint;
    procedure FogChanged;
    function ValidateObservation(Player: Shortint): Boolean;
    function GetBuilding: Boolean;
    function ShowBorderImage(SurfaceDesc: TSurfaceDesc; R: TRect): Boolean;
    function ShowBorderImageDC(DC: HDC; R: TRect): Boolean;
    procedure ShowRazeAnimation(Animation: TAnimation; X, Y: Integer; const SurfaceDesc: TSurfaceDesc);
  end;

  { TStructureControl (instance size 20, VMT 55713E78) }
  TStructureControl = class(TEObject)
  public
    FStructures: TENode; { $08 }
    FNextID: Integer; { $0C }
    FCityCount: Integer; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetStructure(Index: Integer): TStructure;
    function GetCount: Integer;
    function CreateUniqueID: Integer;
    function IndexOfID(ID: Integer): Integer;
    function FindID(ID: Integer): TStructure;
    procedure Register(Structure: TStructure);
    procedure Unregister(Structure: TStructure);
    procedure Activate;
  end;

  { TStructureResource: size $64; $48 selection SFX, $50 description,
    $54 scanner icon. VMT 55713F40; other recovered resource fields below. }
  TStructureResource = class(TFixedILTerrainMOR)
  public
    FTerrainBound: Boolean; { $44 }
    { conflict: FUsePad: Boolean; }
    FConnectRoads: Boolean; { $45 }
    FFlagType: Byte; { $46 }
    F_StructureResource_47: array[0..0] of Byte;
    FSelectSFX: string; { $48; 5575EA18 }
    FSelectSFXLooped: Boolean; { $4C; AoWEd 00408F6D }
    F_StructureResource_4D: array[0..2] of Byte;
    FDescription: TStrings; { $50; 5575E988 }
    FScannerIcon: Integer; { $54; 5575F817 }
    FRazeable: Boolean;  { $58 }
    FCastsShadow: Boolean; { $59; $5575F6ED, $557D6C7F }
    FRebuildGold: Byte; { $5A }
    FRebuildDays: Byte; { $5B }
    FDefenders: TUnitIndexListCollection;  { $5C }
    FRazeDefenderBudget: Integer; { $60 }
    { conflict: FRazeDefenderStrength: Integer; }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure Show(X, Y: Integer; const SurfaceDesc: TSurfaceDesc; Structure: TStructure); virtual;
    procedure CalculatePadIndex;
  end;

  { TRazeStructureEventLog: size $2C; $28 structure. VMT 55714050. }
  TRazeStructureEventLog = class(TMessageEventLog)
  public
    FStructure: TStructure; { $28; 5576039B }
    function Yes: Boolean; override;
  end;

  { TPlayerStructureIncomeSource (instance size 12, VMT 55714160) }
  TPlayerStructureIncomeSource = class(TIncomeSource)
  public
    FStructure: TPlayerStructure; { $08 }
    function Name: string; override;
    function Income: Integer; override;
    procedure GetLocation(var X, Y, L: Shortint); override;
    procedure Setup(Structure: TPlayerStructure);
  end;

  { TPlayerStructurePowerSource (instance size 12, VMT 55714250) }
  TPlayerStructurePowerSource = class(TPowerSource)
  public
    FStructure: TPlayerStructure; { $08 }
    function Name: string; override;
    function Power: Integer; override;
    procedure GetLocation(var X, Y, L: Shortint); override;
    procedure Select; override;
    procedure Setup(Structure: TPlayerStructure);
  end;

  { TPlayerStructure: size $3C; $30 player, $31 turns owned (FProductionPriority),
    $32 flag ID, $34 victory-location bits, $38 unfog range. VMT 55714340. }
  TPlayerStructure = class(TStructure)
  public
    FPlayer: Shortint;  { $30 }
    FProductionPriority: Byte; { $31 }
    FFlagID: Byte; { $32 }
    F_PlayerStructure_33: array[0..0] of Byte;
    FVictoryLocations: TBitList; { $34 }
    FUnfogRange: Byte; { $38; $557D50FC }
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
    procedure NewTurn(Player: Shortint); override;
    procedure SeatedPlayerChanged; override;
    procedure ArmyPlaced(A1: TArmyHS); override;
    procedure ArmyChanged(Army: TArmyHS); override;
    procedure BuildingDone; override;
    function ExecuteRebuild(AUnit: TAbstractUnit): Boolean; override;
    function ExecuteBuild(AUnit: TAbstractUnit; Days: Integer): Boolean; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    function CanRebuild(AUnit: TAbstractUnit; var Reason: string): Boolean; override;
    procedure SetPlayer(Player: Shortint); virtual;
    function GetIncome: Integer; virtual;
    function GetPower: Integer; virtual;
    procedure UpdateFlagID; virtual; { $1FC }
    function VisibilityRange: Integer; virtual;
    procedure UpdateUnfog; virtual; { $204 }
    procedure UpdateExploration; virtual; { $208 }
    procedure FinalizeCombat(Combat: TCombat); virtual;
    function GetCombatEventText(Combat: TCombat): string; virtual; { +210; $557D066C }
    procedure StructureCaptured(OldPlayer, NewPlayer: Shortint); virtual;
    function GetMoveAction(Player: Shortint; Action: TMoveAction): TMoveAction; virtual;
    function GetDefaultAITargetPriority: Integer; virtual;
    function UpdatePlayer: Boolean; virtual;
    function GetVictoryLocation(Player: Shortint): Boolean; { 557607AC }
    procedure SetVictoryLocation(Player: Shortint; Value: Boolean); { 557607B8 }
    procedure RegisterVictoryLocations;
    procedure UnregisterVictoryLocations;
    function TrueVisionRange: Integer;
    procedure UpdatePlayerSeen;
  end;

  { TPlayerStructureResource (instance size 116, VMT 557145E0) }
  TPlayerStructureResource = class(TStructureResource)
  public
    FClaimed: Boolean;  { $64 }
    F_PlayerStructureResource_65: array[0..2] of Byte;
    FFlagX: Integer; { $68 }
    FFlagY: Integer; { $6C }
    FFlagControl: TFlagControl; { $70; 5576103D }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function ResourceUserClassID: Integer; override;
    function PlaceResourceUser(HSMap: HSEngine.THSMap; Xhx, Yhx, Lhx: Shortint): HSEngine.TMapObject; override;
    procedure GenerateFlagPositions; virtual; { $7C }
    procedure ActivateMsg;
  end;

  { TStructureTE (instance size 40, VMT 557146EC) }
  TStructureTE = class(TTokenEvent)
  public
    FX: Shortint; { $10 }
    FY: Shortint; { $11 }
    FL: Shortint; { $12 }
    FPlayer: Shortint; { $13 }
    FStructureClassID: Integer; { $14 }
    FAction: Integer; { $18 }
    FRazed: Boolean; { $1C }
    F_StructureTE_1D: array[0..2] of Byte;
    FParam: Integer; { $20 }
    FParam2: Integer; { $24 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    function Validate: Boolean; virtual; { $50; 55761D9B }
    procedure Initialize(AClassID: Integer; X, Y, L: Shortint);
  end;

  { TFrozenWaterHS (instance size 16, VMT 557147B4) }
  { TFrozenWaterHS: size $10; +$0C signed days remaining, +$0D caster player. }
  TFrozenWaterHS = class(TSingleHS)
  public
    FDaysRemaining: Shortint; { $0C; 557CCEC1 }
    FCasterPlayer: Shortint; { $0D; 557CCEC7 }
    F_FrozenWaterHS_0E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MeltIce;
    procedure NewTurn(Player: Shortint);
  end;

