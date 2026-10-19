  { AoWE.TCustomAbilityList (instance size 16): +8 FAbSet (bit set, one bit per ability id),
    +$C FAbCount. Hand-written: the rwData size is computed from FAbCount. }
  public
    FAbSet: PByte;
    FAbCount: Integer;
    destructor Destroy; override;
    procedure SetAbCount(Value: Integer);            { AoWE.TCustomAbilityList.SetAbCount }
    function GetAbSet(Index: Integer): Boolean;      { slot +$4C }
    procedure SetAbSet(Index: Integer; Value: Boolean);   { slot +$50 }
    procedure ReadWrite(Stream: TEStorageStream); override;
