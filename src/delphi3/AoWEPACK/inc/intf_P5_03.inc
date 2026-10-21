{ Interface declaration run owned by P5. }
  { TPadControl: size $14, VMT 5571493C; $0C pad resources, $10 terrain types. }
  TPadControl = class(TEControlStyleObject)
  public
    FPadResources: TList; { $0C }
    FTerrainTypes: TBitList; { $10; 5575EC58 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetPadResource(Size: Integer): TMapObjectResource;
    procedure SetPadResource(Size: Integer; Resource: TMapObjectResource);
    procedure RegisterPadResource(Resource: TMapObjectResource; Size: Integer);
    procedure UnregisterPadResource(Resource: TMapObjectResource; Size: Integer);
    function CanPlacePad(X, Y, L: Shortint; Size: Integer): Boolean;
    function PlacePad(X, Y, L: Shortint; Size: Integer): TILTerrainMO;
  end;

