  { HSEngine.TMapContainer (instance size 32): the node between the map and its levels.
    +$C, +$10, +$14 are Integers in memory but stored as bytes (ids 3, 4, 5). }
  public
    FByte3, FByte4, FByte5: Byte;
    procedure ReadWrite(Stream: TEStorageStream); override;
