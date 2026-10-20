{ Interface declaration run owned by P5. }
  { TPadControl (instance size 20, VMT 5571493C) }
  TPadControl = class(TEControlStyleObject)
  public
    F_PadControl_0C: Integer;
    F_PadControl_10: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetPadResource(A1: Integer);  { draft }
    procedure SetPadResource(A1: Integer; A2: Integer);  { draft }
    procedure RegisterPadResource(A1: Integer; A2: Integer);  { draft }
    procedure UnregisterPadResource(A1: Integer; A2: Integer);  { draft }
    procedure CanPlacePad(A1: Byte; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure PlacePad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

