  { AoWE.TRace (instance size 72): race id, a TIntegerList (id 3), the enabled flag (id 4, read
    through SetEnabled) and the race relations as a TByteList (id 5). }
  public
    FRace: Byte;
    FIntegerList: TIntegerList;
    FEnabled: Boolean;
    FRelations: TByteList;
    constructor Create(AOwner: TEObject); override;
    destructor Destroy; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
