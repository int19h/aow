{ Interface declaration run owned by P1. }
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
    function PlaceFire(A1: Integer; A2: Integer; A3: Integer; A4: Boolean): TFire;
    procedure RegisterFireResource;  { draft }
    procedure UnregisterFireResource;  { draft }
  end;

