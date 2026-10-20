{ Interface declaration run owned by P1. }
  { TFire (instance size 44, VMT 557150AC) }
  { TFire (instance size 44): $1C FMode, $1D FTurnsLeft, $1E FAge,
    $20 FShowPriority, $24 FPlayer, $28 FExplosionFrame. }
  TFire = class(TILTerrainMO)
  public
    FMode: TFireMode; { $1C }
    FTurnsLeft: Byte; { $1D }
    FAge: Byte; { $1E }
    F_Fire_1F: array[0..0] of Byte;
    FShowPriority: Integer; { $20 }
    FPlayer: Shortint; { $24 }
    F_Fire_25: array[0..2] of Byte;
    FExplosionFrame: Integer; { $28 }
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
    procedure CalcShowPriority(MapField: TMapField);
    procedure SetupExplosion(Delay: Integer);
    procedure TriggerDamage;
    function CanDoDamage(Units: TUnitList): Boolean;
    procedure ArmyPlaced(ArmyHS: TArmyHS);
    procedure NewTurn;
    procedure NewTurnDone;
    procedure WaterMasteryCast;
  end;

  { TFireResource (instance size 72, VMT 55715274) }
  { TFireResource (instance size 72): $44 FFireType. }
  TFireResource = class(TILTerrainMOR)
  public
    FFireType: TFireType; { $44 }
    F_FireResource_45: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TFireControl (instance size 8, VMT 55715360) }
  { TFireControl (instance size 8): $04 FResources. }
  TFireControl = class(TObject)
  public
    FResources: TList; { $04 }
    destructor Destroy; override;
    constructor Create;
    function GetRndFireResource(FireType: TFireType): TFireResource;
    function PlaceFire(X, Y, L: Integer; FireType: TFireType): TFire;
    procedure RegisterFireResource(Resource: TFireResource);
    procedure UnregisterFireResource(Resource: TFireResource);
  end;

