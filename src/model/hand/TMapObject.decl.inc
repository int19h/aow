  { HSEngine.TMapObject: anything that sits on a map field. Persisted as the id of its resource
    (id 1); on load the original links the object to that resource and raises
    EMapObjectResourceMissing when it is gone. }
  public
    FResourceID: Integer;
    procedure ReadWrite(Stream: TEStorageStream); override;
