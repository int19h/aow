  { AoWE.TItemControl: the item library of a map. Items without an owner are stored under ids
    10, 11, ... (rwCreateEObject with a nil owner) until a nil entry ends the list. }
  public
    FInt9: Integer;                     { id 9 }
    FItems: TList;                      { TItem, owned by the control }
    constructor Create(AOwner: TEObject); override;
    destructor Destroy; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
