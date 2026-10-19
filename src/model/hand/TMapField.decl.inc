  { HSEngine.TMapField: one hex of a level. Its map objects are its children, but they are stored in
    the field's own property table under ids from $32 upward (not under id 1). The original keeps
    the children in a small inline array (+8, count byte at +$D) and overrides NewInstance so that
    all fields of a level live in one block; the model uses the TENode list. }
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    procedure ReadWriteChildren(Stream: TEStorageStream); override;
