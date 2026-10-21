{ Interface declaration run owned by P4. }
  { TRebuildConstructionControl (instance size 8, VMT 55770A28) }
  TRebuildConstructionControl = class(TConstructionControl)
  public
    function GetStructure(AUnit: TAbstractUnit): TStructure; { 55770B58 }
    procedure GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer); override;
    function CanConstruct(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Construct(AUnit: TAbstractUnit): Boolean; override;
    class function ID: Integer; override;
  end;

  { TBuildRoadsControl (instance size 8, VMT 55770AE0) }
  TBuildRoadsControl = class(TConstructionControl)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer); override;
    function CanConstruct(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Construct(AUnit: TAbstractUnit): Boolean; override;
    class function ID: Integer; override;
  end;

