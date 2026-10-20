{ Interface declaration run owned by P4. }
  { TRebuildConstructionControl (instance size 8, VMT 55770A28) }
  TRebuildConstructionControl = class(TConstructionControl)
  public
    procedure GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer); override;
    function CanConstruct(A1: TAbstractUnit; var A2: string): Boolean; override;
    procedure Construct(A1: Integer); override;
    function ID: Integer; override;
  end;

  { TBuildRoadsControl (instance size 8, VMT 55770AE0) }
  TBuildRoadsControl = class(TConstructionControl)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer); override;
    function CanConstruct(A1: TAbstractUnit; var A2: string): Boolean; override;
    procedure Construct(A1: Integer); override;
    function ID: Integer; override;
  end;

