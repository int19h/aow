{ Interface declaration run owned by P1. }
  { TRaceResource (instance size 72, VMT 55713838) }
  TRaceResource = class(TEResource)
  public
    F_RaceResource_18: Integer;
    F_RaceResource_1C: Integer;
    F_RaceResource_20: Integer;
    F_RaceResource_24: Integer;
    FRaceName: string;  { $28 }
    F_RaceResource_2C: Integer;
    F_RaceResource_30: Byte;
    F_RaceResource_31: array[0..2] of Byte;
    F_RaceResource_34: Integer;
    FUnitIndexes: TIntegerList;  { $38 }
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
    function GetRaceResource(Index: Integer): TRaceResource;
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
    FUpdateCount: Integer; { $20 }
    FBuildingPlayer: Shortint; { $24 }
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
    function GetTopBorderImage: TLibraryImage; virtual;
    function GetMiddleBorderImage: TLibraryImage; virtual;
    function GetBottomBorderImage: TLibraryImage; virtual;
    procedure GetDescription; virtual;  { +144 draft }
    function GetName: string; virtual;
    procedure SetRazed(Value: Boolean); virtual;
    function GetRazed: Boolean; virtual;
    procedure GetRazeable; virtual;  { +154 draft }
    procedure RazeEx(A1: Integer); virtual;  { +158 draft }
    procedure SetupRazeDefenderAG(A1: Integer; A2: Integer); virtual;  { +15C draft }
    procedure CreateTE; virtual;  { +160 draft }
    procedure SetupTE(A1: Integer); virtual;  { +164 draft }
    procedure ExecuteTE(A1: Integer; A2: Integer); virtual;  { +168 draft }
    procedure GetDefenseRequirements(A1: Integer; A2: Integer); virtual;  { +16C draft }
    procedure GetDefensePriority; virtual;  { +170 draft }
    procedure NewDay; virtual;  { +174 draft }
    procedure NewTurn(Player: Shortint); virtual;
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
    function GetCurrentActivityText: string; virtual;
    function ValidateMap(A1: Integer): Boolean; virtual;  { +1B8  }
    procedure MainValidateMap(A1: Integer); virtual;  { +1BC draft }
    procedure ExecuteAI(A1: Integer; A2: Integer); virtual;  { +1C0 draft }
    procedure UpdateAITarget(const Info: TAITargetInfo; var Priority: Integer); virtual;
    procedure Update; virtual;  { +1C8 draft }
    procedure VisibleForPlayer(A1: Byte); virtual;  { +1CC draft }
    function CanDblClick: Boolean; virtual;
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
    function GetBuilding: Boolean;
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
    FRazeable: Boolean;  { $58 }
    F_StructureResource_59: Byte;
    F_StructureResource_5A: Byte;
    F_StructureResource_5B: Byte;
    FDefenders: TUnitIndexListCollection;  { $5C }
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
    procedure Setup(Structure: TPlayerStructure);
  end;

  { TPlayerStructurePowerSource (instance size 12, VMT 55714250) }
  TPlayerStructurePowerSource = class(TPowerSource)
  public
    F_PlayerStructurePowerSource_08: Integer;
    procedure Name(A1: Integer); override;
    procedure Power; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Select(A1: Integer; A2: Integer); override;
    procedure Setup(Structure: TPlayerStructure);
  end;

  { TPlayerStructure (instance size 60, VMT 55714340) }
  TPlayerStructure = class(TStructure)
  public
    FPlayer: Shortint;  { $30 }
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
    procedure NewTurn(Player: Shortint); override;
    procedure SeatedPlayerChanged; override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure ArmyChanged; override;
    procedure BuildingDone; override;
    procedure ExecuteRebuild(A1: Integer); override;
    procedure ExecuteBuild(A1: Integer; A2: Byte); override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Priority: Integer); override;
    procedure CanRebuild(A1: Integer; A2: Integer); override;
    procedure SetPlayer(Player: Shortint); virtual;
    function GetIncome: Integer; virtual;
    function GetPower: Integer; virtual;
    procedure UpdateFlagID; virtual;  { +1FC draft }
    procedure VisibilityRange; virtual;  { +200 draft }
    procedure UpdateUnfog; virtual;  { +204 draft }
    procedure UpdateExploration; virtual;  { +208 draft }
    procedure FinalizeCombat(A1: Integer); virtual;  { +20C draft }
    procedure GetCombatEventText(A1: Integer; A2: Integer); virtual;  { +210 draft }
    procedure StructureCaptured(OldPlayer, NewPlayer: Shortint); virtual;
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
    FClaimed: Boolean;  { $64 }
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

