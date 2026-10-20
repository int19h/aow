{ Interface declaration run owned by P3. }
  { TCombatViewer (instance size 28, VMT 55716040) }
  TCombatViewer = class(TObject)
  public
    F_CombatViewer_04: Byte;
    F_CombatViewer_05: array[0..2] of Byte;
    F_CombatViewer_08: Integer;
    F_CombatViewer_0C: Byte;
    F_CombatViewer_0D: array[0..2] of Byte;
    F_CombatViewer_10: Integer;
    F_CombatViewer_14: Integer;
    F_CombatViewer_18: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Initialize(A1: Integer);  { draft }
    procedure Finalize;  { draft }
    procedure GetEndPosition;  { draft }
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

  { TCombatAction (instance size 12, VMT 557160B4) }
  TCombatAction = class(TEObject)
  public
    F_CombatAction_08: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure GetName(A1: Integer); virtual;  { +04C draft }
    procedure Execute(A1: Integer; A2: Integer); virtual; abstract;  { +050 draft }
    procedure Play(A1: Integer); virtual; abstract;  { +054 draft }
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { +058 draft }
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { +05C draft }
    procedure ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +060 draft }
  end;

  { TSingleTargetCA (instance size 16, VMT 557161CC) }
  TSingleTargetCA = class(TCombatAction)
  public
    F_SingleTargetCA_0C: Byte;
    F_SingleTargetCA_0D: Byte;
    F_SingleTargetCA_0E: Byte;
    F_SingleTargetCA_0F: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure GetDefensive;  { draft }
    procedure SetDefensive(A1: Byte);  { draft }
  end;

  { TDamageCA (instance size 24, VMT 557162F4) }
  TDamageCA = class(TSingleTargetCA)
  public
    F_DamageCA_10: Byte;
    F_DamageCA_11: Byte;
    F_DamageCA_12: array[0..0] of Byte;
    F_DamageCA_13: Byte;
    F_DamageCA_14: array[0..0] of Byte;
    F_DamageCA_15: Byte;
    F_DamageCA_16: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Setup(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer); virtual;  { +064 draft }
    procedure Generate(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +068 draft }
    procedure GenerateEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer); virtual;  { +06C draft }
  end;

  { TDamageEffectCA (instance size 20, VMT 557163D0) }
  TDamageEffectCA = class(TSingleTargetCA)
  public
    F_DamageEffectCA_10: Byte;
    F_DamageEffectCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
  end;

  { TUpdateHeaderCA (instance size 16, VMT 557164AC) }
  TUpdateHeaderCA = class(TCombatAction)
  public
    F_UpdateHeaderCA_0C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TNewCombatTurnCA (instance size 16, VMT 5571659C) }
  TNewCombatTurnCA = class(TCombatAction)
  public
    F_NewCombatTurnCA_0C: Byte;
    F_NewCombatTurnCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TNewCombatRoundCA (instance size 12, VMT 5571667C) }
  TNewCombatRoundCA = class(TCombatAction)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TCombatObjectTurnDoneCA (instance size 16, VMT 5571675C) }
  TCombatObjectTurnDoneCA = class(TCombatAction)
  public
    F_CombatObjectTurnDoneCA_0C: Byte;
    F_CombatObjectTurnDoneCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TMoveWallCA (instance size 16, VMT 55716880) }
  TMoveWallCA = class(TCombatAction)
  public
    F_MoveWallCA_0C: Byte;
    F_MoveWallCA_0D: Byte;
    F_MoveWallCA_0E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TFleeCA (instance size 16, VMT 55716954) }
  TFleeCA = class(TCombatAction)
  public
    F_FleeCA_0C: Byte;
    F_FleeCA_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
  end;

  { TCombatActionList (instance size 12, VMT 55716A20) }
  TCombatActionList = class(TEReferenceNode)
  public
    procedure GetCombatActions(A1: Integer);  { draft }
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
    procedure Deactivate;  { draft }
  end;

  { TCombatPartyList (instance size 12, VMT 55716BE4) }
  TCombatPartyList = class(TENode)
  public
    function GetControlStyle: Engine.TEControlStyles; override;
    procedure CreateParty(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);  { draft }
    procedure GetParty(A1: Integer);  { draft }
    procedure Activate(A1: Integer);  { draft }
    procedure Deactivate(A1: Integer);  { draft }
  end;

  { TCombatPlayer (instance size 12, VMT 55716CE8) }
  TCombatPlayer = class(TEObject)
  public
    F_CombatPlayer_08: Byte;
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
    procedure GetPlayers(A1: Byte);  { draft }
    procedure IndexOfPlayer(A1: Byte);  { draft }
    procedure IndexOf(A1: Byte; A2: Byte);  { draft }
    procedure Delete(A1: Integer);  { draft }
  end;

  { TCombatData (instance size 84, VMT 55716EAC) }
  TCombatData = class(TEObject)
  public
    F_CombatData_08: Integer;
    F_CombatData_0C: Integer;
    F_CombatData_10: Integer;
    F_CombatData_14: Integer;
    F_CombatData_18: Integer;
    F_CombatData_1C: Integer;
    F_CombatData_20: array[0..1] of Byte;
    F_CombatData_22: Word;
    F_CombatData_24: Byte;
    F_CombatData_25: Byte;
    F_CombatData_26: array[0..1] of Byte;
    F_CombatData_28: Integer;
    F_CombatData_2C: Integer;
    F_CombatData_30: Byte;
    F_CombatData_31: Byte;
    F_CombatData_32: array[0..1] of Byte;
    F_CombatData_34: Integer;
    F_CombatData_38: Integer;
    F_CombatData_3C: Integer;
    F_CombatData_40: Integer;
    F_CombatData_44: Integer;
    F_CombatData_48: Integer;
    F_CombatData_4C: Byte;
    F_CombatData_4D: Byte;
    F_CombatData_4E: array[0..5] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetSideLeaderInvolved(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure GetObjects(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure FindID(A1: Integer);  { draft }
    procedure FindPosition(A1: Byte);  { draft }
    procedure AddObject(A1: Integer);  { draft }
  end;

  { TCombatLogbook (instance size 28, VMT 55716F7C) }
  TCombatLogbook = class(TEObject)
  public
    F_CombatLogbook_08: Integer;
    F_CombatLogbook_0C: Integer;
    F_CombatLogbook_10: Integer;
    F_CombatLogbook_14: Integer;
    F_CombatLogbook_18: array[0..0] of Byte;
    F_CombatLogbook_19: Byte;
    F_CombatLogbook_1A: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure SetInitialData;  { draft }
    procedure SetFinalData;  { draft }
  end;

  { TCombat (instance size 76, VMT 55717114) }
  TCombat = class(TEObject)
  public
    F_Combat_08: Byte;
    F_Combat_09: array[0..2] of Byte;
    F_Combat_0C: Integer;
    F_Combat_10: Integer;
    F_Combat_14: Byte;
    F_Combat_15: array[0..2] of Byte;
    F_Combat_18: Integer;
    F_Combat_1C: Integer;
    F_Combat_20: Integer;
    F_Combat_24: Integer;
    F_Combat_28: Integer;
    F_Combat_2C: Byte;
    F_Combat_2D: array[0..0] of Byte;
    F_Combat_2E: Word;
    F_Combat_30: Integer;
    F_Combat_34: Byte;
    F_Combat_35: array[0..2] of Byte;
    F_Combat_38: Byte;
    F_Combat_39: array[0..0] of Byte;
    F_Combat_3A: Word;
    F_Combat_3C: Integer;
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
    procedure Deactivate(A1: Integer; A2: Integer); virtual;  { +074 draft }
    procedure NewTurn(A1: Integer); virtual;  { +078 draft }
    procedure NewRound; virtual;  { +07C draft }
    procedure GetLogCombatActions;  { draft }
    procedure SetLogCombatActions(A1: Byte);  { draft }
    procedure GetRound;  { draft }
    procedure ExecuteCombatAction(A1: Integer);  { draft }
    procedure PlayerTypeInvolved(A1: Byte; A2: Integer);  { draft }
    procedure CreateUniqueCOID;  { draft }
    procedure UpdateSidesSettings;  { draft }
    procedure NextTurn;  { draft }
    procedure Terminate;  { draft }
    procedure CheckTerminate;  { draft }
    procedure SetLogbookHeader(A1: Integer; A2: Integer);  { draft }
    procedure AddAdjacentArmies;  { draft }
    procedure GetPartyPosition(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure AddCombatPlayer(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure AddArmy(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure AddArmyEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure AddEmptyArmy(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure InitDefaultArmies(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure LockExecuted;  { draft }
    procedure UnlockExecuted;  { draft }
    procedure GetCombatResultText(A1: Integer);  { draft }
    procedure DefendersAvailable;  { draft }
  end;

  { TCombatEventLog (instance size 28, VMT 557171FC) }
  TCombatEventLog = class(TEventLog)
  public
    F_CombatEventLog_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure GetTextColor; override;
    procedure GetLeftIcon; override;
    procedure GetMiddleIcon; override;
    procedure GetRightIcon; override;
    procedure PlayLoggedSFX(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
    procedure SetCombatLogbook(A1: Integer);  { draft }
  end;

  { TCombatTypeRequestEventLog (instance size 44, VMT 557172EC) }
  TCombatTypeRequestEventLog = class(TEventLog)
  public
    F_CombatTypeRequestEventLog_18: Byte;
    F_CombatTypeRequestEventLog_19: Byte;
    F_CombatTypeRequestEventLog_1A: Byte;
    F_CombatTypeRequestEventLog_1B: Byte;
    F_CombatTypeRequestEventLog_1C: Byte;
    F_CombatTypeRequestEventLog_1D: Byte;
    F_CombatTypeRequestEventLog_1E: array[0..1] of Byte;
    F_CombatTypeRequestEventLog_20: Byte;
    F_CombatTypeRequestEventLog_21: array[0..2] of Byte;
    F_CombatTypeRequestEventLog_24: Byte;
    F_CombatTypeRequestEventLog_25: array[0..2] of Byte;
    F_CombatTypeRequestEventLog_28: Integer;
    destructor Destroy; override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure SetTokenEvent(A1: Integer);  { draft }
    procedure Select(A1: Byte);  { draft }
    procedure SetCenterLocation(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

