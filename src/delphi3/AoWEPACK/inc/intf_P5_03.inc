{ Interface declaration run owned by P5. }
  { TPadControl (instance size 20, VMT 5571493C) }
  TPadControl = class(TEControlStyleObject)
  public
    F_PadControl_0C: Integer;
    FTerrainTypes: TBitList; { $10; 5575EC58 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetPadResource(A1: Integer);  { draft }
    procedure SetPadResource(A1: Integer; A2: Integer);  { draft }
    procedure RegisterPadResource(Resource: TMapObjectResource; Size: Integer);
    procedure UnregisterPadResource(Resource: TMapObjectResource; Size: Integer);
    function CanPlacePad(X, Y, L: Shortint; Size: Integer): Boolean;
    function PlacePad(X, Y, L: Shortint; Size: Integer): TILTerrainMO;
  end;

