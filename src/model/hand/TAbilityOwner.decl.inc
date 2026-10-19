  { AoWE.TAbilityOwner (instance size 20): +$10 head of a linked list of ability data objects
    (TMultiLevelAbilityData, TLeadershipAbilityData, ...), each stored under id + $32 after a
    TIntegerList of the ids under $31. The model keeps the objects in a TList with their ids. }
  public
    FAbilityData: TList;                 { TEObject instances, owned }
    FAbilityIDs: TIntegerList;           { the id of each entry, same order }
    constructor Create(AOwner: TEObject); override;
    destructor Destroy; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
