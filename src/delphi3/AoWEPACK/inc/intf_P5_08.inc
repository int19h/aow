{ Interface declaration run owned by P5. }
  { TAoWMapCampaignSettings (instance size 28, VMT 55723A60).
    $08 FFlag; $09 padding; $0C points; $10 gold; $14 mana; $18 next scenario. }
  TAoWMapCampaignSettings = class(TEObject)
  public
    FFlag: Boolean;
    F_AoWMapCampaignSettings_09: array[0..2] of Byte;
    FTransferPointsMax: Integer;
    FTransferGoldMax: Integer;
    FTransferManaMax: Integer;
    FNextScenarioID: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TAoWCampaignTransferSettings (instance size 80, VMT 55723B34) }
  TAoWCampaignTransferSettings = class(TEObject)
  public
    F_AoWCampaignTransferSettings_08: Integer;
    F_AoWCampaignTransferSettings_0C: Integer;
    F_AoWCampaignTransferSettings_10: Integer;
    F_AoWCampaignTransferSettings_14: Integer;
    F_AoWCampaignTransferSettings_18: Integer;
    F_AoWCampaignTransferSettings_1C: Integer;
    F_AoWCampaignTransferSettings_20: Integer;
    F_AoWCampaignTransferSettings_24: Integer;
    F_AoWCampaignTransferSettings_28: Integer;
    F_AoWCampaignTransferSettings_2C: Integer;
    F_AoWCampaignTransferSettings_30: Integer;
    F_AoWCampaignTransferSettings_34: Integer;
    F_AoWCampaignTransferSettings_38: Integer;
    F_AoWCampaignTransferSettings_3C: Integer;
    F_AoWCampaignTransferSettings_40: Integer;
    F_AoWCampaignTransferSettings_44: Integer;
    F_AoWCampaignTransferSettings_48: Integer;
    F_AoWCampaignTransferSettings_4C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure SetLeader(A1: Integer);  { draft }
    procedure GenerateTransferUnits(A1: Integer);  { draft }
    procedure Retrieve;  { draft }
    procedure ClearSelection;  { draft }
    procedure AddItem(A1: Integer);  { draft }
    procedure DeleteItem(A1: Integer);  { draft }
    procedure AddHero(A1: Integer);  { draft }
    procedure DeleteHero(A1: Integer);  { draft }
    procedure AddUnit(A1: Integer);  { draft }
    procedure DeleteUnit(A1: Integer);  { draft }
    procedure SetSelectedTransferGold(A1: Integer);  { draft }
    procedure SetSelectedTransferMana(A1: Integer);  { draft }
    procedure SetupSelection(A1: Integer; A2: Integer);  { draft }
    procedure AutoSelect;  { draft }
    procedure ExecuteSelection;  { draft }
  end;

  { TAoWCampaignScenario (instance size 20, VMT 55723C14) }
  TAoWCampaignScenario = class(TEObject)
  public
    F_AoWCampaignScenario_08: Integer;
    F_AoWCampaignScenario_0C: Integer;
    F_AoWCampaignScenario_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAoWCampaignScenarioList (instance size 12, VMT 55723CFC) }
  TAoWCampaignScenarioList = class(TENode)
  public
    procedure GetScenario(A1: Integer);  { draft }
    procedure CreateUniqueID;  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure FindID;  { draft }
  end;

  { TAoWCampaign (instance size 52, VMT 55723F48) }
  TAoWCampaign = class(TEObject)
  public
    F_AoWCampaign_08: Integer;
    F_AoWCampaign_0C: Byte;
    F_AoWCampaign_0D: array[0..2] of Byte;
    F_AoWCampaign_10: Integer;
    F_AoWCampaign_14: Integer;
    F_AoWCampaign_18: Integer;
    F_AoWCampaign_1C: Byte;
    F_AoWCampaign_1D: array[0..2] of Byte;
    F_AoWCampaign_20: Integer;
    F_AoWCampaign_24: Integer;
    F_AoWCampaign_28: Integer;
    F_AoWCampaign_2C: array[0..3] of Byte;
    F_AoWCampaign_30: Byte;
    F_AoWCampaign_31: Byte;
    F_AoWCampaign_32: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure CreateScenario; virtual;  { +04C draft }
    procedure GetAutoSaveFileName(A1: Integer; A2: Integer); virtual;  { +050 draft }
    procedure SelectNextScenario(A1: Integer); virtual;  { +054 draft }
    procedure ResetNextScenario; virtual;  { +058 draft }
    procedure StartScenario(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +05C draft }
    procedure SetupScenario; virtual;  { +060 draft }
    procedure FinishScenario; virtual;  { +064 draft }
    procedure RestartScenario; virtual;  { +068 draft }
    procedure AddScenario; virtual;  { +06C draft }
    procedure GetContainsMap;  { draft }
  end;

  { TDiplomaticAction (instance size $30, VMT 55723F48).
    $08 RefCount, $0C Day, $10 Source, $11 Target, $12 OtherPlayer,
    $13 ActionType, $14 Reaction, $18 Gold, $1C Mana, $20 Message,
    $24 EscrowGold, $28 EscrowMana, $2C EventLogID. }
  TDiplomaticAction = class(TEObject)
  public
    FRefCount: Integer;
    FDay: Integer;
    FSource: Byte;
    FTarget: Byte;
    FOtherPlayer: Byte;
    FActionType: TDiplomaticActionType;
    FReaction: TDiplomaticActionReaction;
    FReserved: array[0..2] of Byte;
    FGold: Integer;
    FMana: Integer;
    FMessage: TStringList;
    FEscrowGold: Integer;
    FEscrowMana: Integer;
    FEventLogID: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure ExecuteSend(TE: TDiplomaticActionTE); virtual; { $4C }
    procedure ExecuteAccept(TE: TDiplomaticActionTE); virtual; { $50 }
    procedure ExecuteReject(TE: TDiplomaticActionTE); virtual; { $54 }
    procedure ExecuteAI(Player: Shortint); virtual; { $58 }
    function CanSend(var ErrorText: string): Boolean; virtual; { $5C }
    function Send(var ErrorText: string): Boolean; virtual; { $60 }
    function CanAccept(var ErrorText: string): Boolean; virtual; { $64 }
    function Accept(var ErrorText: string): Boolean; virtual; { $68 }
    function CanReject(var ErrorText: string): Boolean; virtual; { $6C }
    function Reject(var ErrorText: string): Boolean; virtual; { $70 }
    function GetName(Player: Shortint): string;
    function GetRelationModifier(Player, Race: Shortint): Integer;
    function CreateEventLog: TDiplomaticActionEventLog;
    procedure UpdateAIDiplomaticActionsLog(Player: Shortint);
  end;

  { TDiplomaticActionList (instance size 12, VMT 55724038) }
  TDiplomaticActionList = class(TEReferenceNode)
  public
    function GetDiplomaticActions(Index: Integer): TDiplomaticAction;
    function FindLastAction(Action: TDiplomaticActionType; Reaction: TDiplomaticActionReaction; Source, Target, Other: Shortint): TDiplomaticAction;
  end;

  { TDiplomaticActionTE (instance size $18, VMT 55724144): $10 Operation, $14 Action. }
  TDiplomaticActionTE = class(TTokenEvent)
  public
    FOperation: Integer;
    FAction: TDiplomaticAction;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure SetDiplomaticAction(Action: TDiplomaticAction);
  end;

  { TDiplomaticActionEventLog (instance size $1C, VMT 55724214): $18 Action. }
  TDiplomaticActionEventLog = class(TEventLog)
  public
    FAction: TDiplomaticAction;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetText(A1: Integer); override;
    procedure GetTextColor; override;
    procedure GetLeftIcon; override;
    procedure GetMiddleIcon; override;
    procedure GetRightIcon; override;
    procedure GetVisible; override;
    procedure PlayLoggedSFX(A1: Integer); override;
    procedure NotifyLogged(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure SetDiplomaticAction(Action: TDiplomaticAction);
  end;

  { TDiplomacyAIPA (instance size 24, VMT 55724318) }
  TDiplomacyAIPA = class(TAIPlayerAction)
  public
    FNextPlayer: Shortint;
    F_DiplomacyAIPA_15: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    function CreateDA(Action: TDiplomaticActionType; Target, Other: Shortint; MinDays: Integer): TDiplomaticAction;
    function ExecuteDiplomacy(Player: Shortint): Boolean;
    procedure ListDebugInfo;
  end;

  { TAoWDictionary (instance size 152, VMT 557243F4) }
  TAoWDictionary = class(TIvBinaryDictionary)
  public
  end;

