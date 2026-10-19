  { AoWE.TPlayer (instance size 220). Hand-written from AoWE.TPlayer.ReadWrite: the leader is
    persisted under id $1E as an embedded object (id $13 is only read by the editor), three view
    bytes ($14..$16) are written only for the current player, two legacy stream procs ($1A, $29)
    are read-only, and several conditions depend on the map state, which the model records as
    "was present" flags so that a round trip reproduces them. }
  public
    FRace: Byte;                        { +$A5, id 2 }
    FByte3: Byte;                       { +$A7, id 3 }
    FBool4: Boolean;                    { +$A9, id 4 }
    FInt5, FInt6: Integer;              { +$AC, +$B0, ids 5, 6 }
    FByte10: Byte;                      { +$45, id 10 }
    FStr11, FStr12: string;             { +$BC, +$C0, ids $B, $C }
    FGems: Integer;                     { +$C4, id $10 }
    FPlayerIndex: Byte;                 { +$A6, id $12 }
    FLeader: TEObject;                  { id $13, editor files only }
    FView14, FView15, FView16: Byte;    { ids $14..$16 }
    FHasView: Boolean;
    FEventLogbook: TEventLogbook;       { +$D8, id $17 }
    FName: string;                      { +$30, id $18 }
    FByte25: Byte;                      { +$44, id $19 }
    FLegacyRelations: TByteList;        { id $1A, read only }
    FByte27: Byte;                      { +$50, id $1B }
    FAIPlayerControl: TAIPlayerControl; { +$88, id $1C }
    FByte29: Byte;                      { +$A8, id $1D }
    FLeaderObject: TLeader;             { +$58, id $1E }
    FPlayerMagicControl: TPlayerMagicControl;   { +$54, id $1F }
    FIntList32, FIntList33: TIntegerList;       { ids $20, $21 }
    FInt34: Integer;                    { +$5C, id $22 }
    FPlayerStatistics: TPlayerStatistics;       { +$60, id $23 }
    FInt36, FInt37, FInt38, FInt39: Integer;    { +$6C..+$7C, ids $24..$27 }
    FStrings40: TStringList;            { +$34, id $28 }
    FLegacyRelations2: TByteList;       { id $29, read only }
    FInt50: Integer;                    { +$74, id $32 }
    FAIBudgetManager: TAIBudgetManager; { +$8C, id $33 }
    FDiplomaticActionList: TDiplomaticActionList;   { +$90, id $34 }
    FBitList53: TBitList;               { id $35 }
    FPBEMPlayerSettings: TPBEMPlayerSettings;   { +$A0, id $36 }
    FBool56: Boolean;                   { +$A4, id $38 }
    FInt57: Integer;                    { +$B4, id $39 }
    FHas57: Boolean;
    FPlayerDiplomaticRelations: TPlayerDiplomaticRelations;   { +$40, id $3A }
    constructor Create(AOwner: TEObject); override;
    destructor Destroy; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
