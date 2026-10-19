  { HSEngine.TMapLevel: one layer of the map. Width and height (ids 3, 4) and the level index
    (id 5) are bytes in the file; the fields themselves are a run of rwEObjectStream records under
    id 6, one per field, in row order. The original allocates all fields in one memory block
    (+$2C pointer, +$28 stride, +$14 count); the model keeps them in a TList. }
  public
    FWidth, FHeight, FLevelIndex: Byte;
    FFields: TList;                      { TMapField descendants, owned }
    constructor Create(AOwner: TEObject); override;
    destructor Destroy; override;
    function CreateMapField: TEObject; virtual;      { the field class differs per game: TAoWMapField }
    procedure CreateMapFieldList(W, H: Integer);     { HSEngine.TMapLevel.CreateMapFieldList }
    procedure ReadWrite(Stream: TEStorageStream); override;
