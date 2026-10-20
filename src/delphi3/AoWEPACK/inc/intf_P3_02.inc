{ Interface declaration run owned by P3. }
  TP3PackedDamageTypes = packed record
    Value: TDamageTypes;
  end;
  { TCombatViewer (instance size $1C, VMT 55716040):
    $04 FStatus; $08 FCombat; $0C FDelay; $0D FSpeed; $10 FPosition; $14 FTime; $18 FLogbook. }
  TCombatViewer = class(TObject)
  public
    FStatus: TCombatViewerStatus;
    F_CombatViewer_05: array[0..2] of Byte;
    FCombat: TCombat;  { $08 }
    FDelay: Byte;
    FSpeed: Byte;
    F_CombatViewer_0E: array[0..1] of Byte;
    FPosition: Integer;
    FTime: Integer;
    FLogbook: TCombatLogbook;  { $18 }
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Initialize(A1: TCombatLogbook);
    procedure Finalize;  { draft }
    function GetEndPosition: Integer;  { draft }
    procedure SetSpeed(A1: Byte);  { draft }
    procedure SetPosition(A1: Integer);  { draft }
    procedure Play;  { draft }
    procedure Pause;  { draft }
    procedure Update;  { draft }
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DefaultShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
  end;

  { TCombatAction: instance size $0C, VMT 557160B4; $08 FRefCount. }
  TCombatAction = class(TEObject)
  public
    FRefCount: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetName: string; virtual;  { +04C }
    procedure Execute(A1: TCombat); virtual; abstract;  { +050 }
    function Play(A1: TCombatViewer): Boolean; virtual; abstract;  { +054 }
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { +058 draft }
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { +05C draft }
    procedure ShowFightingObjects(A1: TCombatViewer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +060 draft }
  end;

  { TSingleTargetCA: instance size $10, VMT 557161CC;
    $0C FMode; $0D FSourceID; $0E FTargetID. }
  TSingleTargetCA = class(TCombatAction)
  public
    FMode: TSingleTargetMode;
    FSourceID: Byte;
    FTargetID: Byte;
    F_SingleTargetCA_0F: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure ShowFightingObjects(A1: TCombatViewer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    function GetDefensive: Boolean;  { draft }
    procedure SetDefensive(A1: Byte);  { draft }
  end;

  { TDamageCA (instance size $18, VMT 557162F4):
    $10 FDamage; $11 FDamageTypes; $13 FEffects; $15 FDamageTaken.
    The two damage sets are deliberately unaligned packed fields. }
  TDamageCA = class(TSingleTargetCA)
  public
    FDamage: Byte;  { $10 }
    FDamageTypes: TP3PackedDamageTypes;
    FEffects: TP3PackedDamageTypes;
    FDamageDone: Byte;  { $15 }
    { conflict: FDamageTaken: Byte; }
    F_DamageCA_16: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Setup(A1: Byte; A2: Byte; A3: Byte; A4: TDamageTypes; A5: TDamageTypes; A6: Boolean); virtual;  { +064 draft }
    procedure Generate(A1, A2: TCombatObject; A3, A4: Shortint; A5: TDamageTypes); virtual;
    procedure GenerateEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer); virtual;  { +06C draft }
  end;

  { TDamageEffectCA: instance size $14, VMT 557163D0; $10 FDamageType. }
  TDamageEffectCA = class(TSingleTargetCA)
  public
    FDamageType: TDamageType;  { $10 }
    F_DamageEffectCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Byte; A4: Boolean);  { draft }
  end;

  { TUpdateHeaderCA (instance size 16, VMT 557164AC) }
  TUpdateHeaderCA = class(TCombatAction)
  public
    F_UpdateHeaderCA_0C: string;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
  end;

  { TNewCombatTurnCA (instance size 16, VMT 5571659C) }
  TNewCombatTurnCA = class(TCombatAction)
  public
    F_NewCombatTurnCA_0C: Byte;
    F_NewCombatTurnCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
  end;

  { TNewCombatRoundCA (instance size 12, VMT 5571667C) }
  TNewCombatRoundCA = class(TCombatAction)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
  end;

  { TCombatObjectTurnDoneCA (instance size 16, VMT 5571675C) }
  TCombatObjectTurnDoneCA = class(TCombatAction)
  public
    F_CombatObjectTurnDoneCA_0C: Byte;
    F_CombatObjectTurnDoneCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
  end;

  { TMoveWallCA (instance size 16, VMT 55716880) }
  TMoveWallCA = class(TCombatAction)
  public
    F_MoveWallCA_0C: Byte;
    F_MoveWallCA_0D: Byte;
    F_MoveWallCA_0E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
  end;

  { TFleeCA (instance size 16, VMT 55716954) }
  TFleeCA = class(TCombatAction)
  public
    F_FleeCA_0C: Byte;
    F_FleeCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
  end;

  { TCombatActionList (instance size 12, VMT 55716A20) }
  TCombatActionList = class(TEReferenceNode)
  public
    function GetCombatActions(A1: Integer): TCombatAction;  { draft }
  end;

  { TCombatParty (instance size 28, VMT 55716B24) }
  TCombatParty = class(TEObject)
  public
    F_CombatParty_08: Integer;
    F_CombatParty_0C: Integer;
    F_CombatParty_10: Integer;
    F_CombatParty_14: Integer;
    F_CombatParty_18: Byte;
    F_CombatParty_19: Byte;
    F_CombatParty_1A: Byte;
    F_CombatParty_1B: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Activate(A1: Integer);  { draft }
    procedure Deactivate(A1: Integer);  { draft }
  end;

  { TCombatPartyList (instance size 12, VMT 55716BE4) }
  TCombatPartyList = class(TENode)
  public
    function GetControlStyle: Engine.TEControlStyles; override;
    function CreateParty(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer): TCombatParty;  { draft }
    function GetParty(A1: Byte): TCombatParty;  { draft }
    procedure Activate(A1: Integer);  { draft }
    procedure Deactivate(A1: Integer);  { draft }
  end;

  { TCombatPlayer (instance size 12, VMT 55716CE8) }
  TCombatPlayer = class(TEObject)
  public
    FPlayer: Shortint; { $08 }
    F_CombatPlayer_09: Byte;
    F_CombatPlayer_0A: Byte;
    F_CombatPlayer_0B: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TCombatPlayerList (instance size 12, VMT 55716DA8) }
  TCombatPlayerList = class(TENode)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetPlayers(A1: Shortint): TCombatPlayer;  { draft }
    function IndexOfPlayer(A1: Byte): Integer;
    function IndexOf(A1: Byte; A2: Byte): Integer;  { draft }
    procedure Delete(A1: Integer);  { draft }
  end;

  { TCombatData (instance size $54, VMT 55716EAC):
    $22 damage set; $28/$2C/$40 byte lists; $34 objects; $38 players;
    $3C parties; $44 round; $48 header string; $4D Boolean; $50 combat wall. }
  TCombatData = class(TEObject)
  public
    F_CombatData_08: Integer;
    F_CombatData_0C: Integer;
    F_CombatData_10: Integer;
    F_CombatData_14: Integer;
    F_CombatData_18: Integer;
    F_CombatData_1C: Integer;
    F_CombatData_20: array[0..1] of Byte;
    F_CombatData_22: TDamageTypes;
    F_CombatData_24: Byte;
    F_CombatData_25: Byte;
    F_CombatData_26: array[0..1] of Byte;
    F_CombatData_28: Integer;
    F_CombatData_2C: Integer;
    F_CombatData_30: Byte;
    FCurrentPlayer: Shortint; { $31 }
    F_CombatData_32: array[0..1] of Byte;
    F_CombatData_34: Integer;
    FPlayers: TCombatPlayerList; { $38 }
    F_CombatData_3C: Integer;
    F_CombatData_40: Integer;
    F_CombatData_44: Integer;
    F_CombatData_48: string;
    F_CombatData_4C: Byte;
    F_CombatData_4D: Boolean;
    F_CombatData_4E: array[0..1] of Byte;
    F_CombatData_50: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetSideLeaderInvolved(A1: Byte): Boolean;  { draft }
    function GetCount: Integer;  { draft }
    function GetObjects(A1: Integer): TCombatObject;  { draft }
    function IndexOfID(A1: Integer): Integer;  { draft }
    function FindID(A1: Integer): TCombatObject;  { draft }
    function FindPosition(A1: Byte): TCombatObject;  { draft }
    procedure AddObject(A1: TCombatObject);  { draft }
  end;

  { TCombatLogbook: instance size $1C, VMT 55716F7C; $08 FRefCount;
    $0C FInitialData; $10 FFinalData; $14 FActions; $19 result flag. }
  TCombatLogbook = class(TEObject)
  public
    FRefCount: Integer;
    FInitialData: TCombatData;  { $0C }
    FFinalData: TCombatData;  { $10 }
    FActions: TCombatActionList;  { $14 }
    F_CombatLogbook_18: array[0..0] of Byte;
    F_CombatLogbook_19: Boolean;
    F_CombatLogbook_1A: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure SetInitialData(Data: TCombatData);
    procedure SetFinalData(Data: TCombatData);
  end;

  { TCombat (instance size $4C, VMT 55717114):
    $08 status; $0C data; $10 ID; $18 logbook; $1C/$20 sides; $24 events;
    $28 lock count; $2C FOnExecuted; $34 terminated; $38 FOnTerminated. }
  TCombat = class(TEObject)
  public
    F_Combat_08: TCombatStatus;
    F_Combat_09: array[0..2] of Byte;
    FCombatData: TCombatData;  { $0C }
    F_Combat_10: Integer;
    F_Combat_14: Byte;
    F_Combat_15: array[0..2] of Byte;
    F_Combat_18: Integer;
    FSides: array[csAttacker..csDefender] of TCombatSide;  { $1C..$20 }
    F_Combat_24: Integer;
    F_Combat_28: Integer;
    FOnExecuted: TCombatExecutedEvent;
    F_Combat_34: Boolean;
    F_Combat_35: array[0..2] of Byte;
    FOnTerminated: TCombatExecutedEvent;
    F_Combat_40: Byte;
    F_Combat_41: array[0..2] of Byte;
    F_Combat_44: Byte;
    F_Combat_45: array[0..6] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure UpdateStatus; virtual;  { +04C draft }
    procedure ObjectDestroyed(A1: Integer); virtual;  { +050 draft }
    procedure ObjectSideChanged(A1: Integer); virtual;  { +054 draft }
    function CreateCombatUnit: Integer; virtual;  { +058 draft }
    function CreateCombatPlayer: Integer; virtual;  { +05C draft }
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer); virtual;  { +060 draft }
    function Execute: Byte; virtual;  { +064 draft }
    procedure Initialize; virtual;  { +068 draft }
    procedure Finalize; virtual;  { +06C draft }
    procedure Activate; virtual;  { +070 draft }
    procedure Deactivate; virtual;  { +074 }
    procedure NewTurn(A1: Byte); virtual;  { +078 draft }
    procedure NewRound; virtual;  { +07C draft }
    function GetLogCombatActions: Boolean;  { draft }
    procedure SetLogCombatActions(A1: Byte);  { draft }
    function GetRound: Integer;  { draft }
    procedure ExecuteCombatAction(A1: TCombatAction);
    function PlayerTypeInvolved(Types: TPlayerTypes): Boolean;
    function CreateUniqueCOID: Byte;  { draft }
    procedure UpdateSidesSettings;  { draft }
    procedure NextTurn;  { draft }
    procedure Terminate;  { draft }
    procedure CheckTerminate;  { draft }
    procedure SetLogbookHeader(A1: string);  { draft }
    procedure AddAdjacentArmies;  { draft }
    function GetPartyPosition(X, Y, Layer: Integer): Byte;
    procedure AddCombatPlayer(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure AddArmy(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure AddArmyEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure AddEmptyArmy(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure InitDefaultArmies(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure LockExecuted;  { draft }
    procedure UnlockExecuted;  { draft }
    procedure GetCombatResultText(A1: Integer);  { draft }
    function DefendersAvailable: Boolean;  { draft }
  end;

  { TCombatEventLog (instance size 28, VMT 557171FC) }
  TCombatEventLog = class(TEventLog)
  public
    F_CombatEventLog_18: TCombatLogbook;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function GetTextColor: TColor; override;
    function GetLeftIcon: Integer; override;
    function GetMiddleIcon: Integer; override;
    function GetRightIcon: Integer; override;
    procedure PlayLoggedSFX(A1: Integer); override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
    procedure SetCombatLogbook(Logbook: TCombatLogbook);
  end;

  { TCombatTypeRequestEventLog (instance size $2C, VMT 557172EC):
    $18 selection; $1B/$1C/$1D location; $20 FTokenEvent; $28 owned object. }
  TCombatTypeRequestEventLog = class(TEventLog)
  public
    F_CombatTypeRequestEventLog_18: Byte;
    F_CombatTypeRequestEventLog_19: Byte;
    F_CombatTypeRequestEventLog_1A: Byte;
    F_CombatTypeRequestEventLog_1B: Byte;
    F_CombatTypeRequestEventLog_1C: Byte;
    F_CombatTypeRequestEventLog_1D: Byte;
    F_CombatTypeRequestEventLog_1E: array[0..1] of Byte;
    FTokenEvent: TEObject;
    F_CombatTypeRequestEventLog_24: Byte;
    F_CombatTypeRequestEventLog_25: array[0..2] of Byte;
    F_CombatTypeRequestEventLog_28: Integer;
    destructor Destroy; override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure SetTokenEvent(A1: Integer);  { draft }
    procedure Select(A1: Byte);  { draft }
    procedure SetCenterLocation(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

