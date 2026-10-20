{ Interface declaration run owned by P5. }
  { TAoWMapCampaignSettings (instance size 28, VMT 55723A60).
    $08 allied victory; $09 padding; $0C points; $10 gold; $14 mana; $18 next scenario. }
  TAoWMapCampaignSettings = class(TEObject)
  public
    FAlliedVictory: Boolean;
    F_AoWMapCampaignSettings_09: array[0..2] of Byte;
    FTransferPointsMax: Integer;
    FTransferGoldMax: Integer;
    FTransferManaMax: Integer;
    FNextScenarioID: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TAoWCampaignTransferSettings (instance size $50, VMT 55723B34).
    $08 leader; $0C heroes; $10 items; $14 units; $18 research percentage;
    $1C spells; $20 research spell ID; $24 research points left; $28/$2C/$30
    selected heroes/items/units; $34/$38 gold/mana; $3C spheres;
    $40 points max; $44 gold max; $48 mana max; $4C points left. }
  TAoWCampaignTransferSettings = class(TEObject)
  public
    FLeader: TLeader; { $08 }
    FHeroes: THeroList; { $0C }
    FItems: TItemList; { $10 }
    FUnits: TUnitList; { $14 }
    FResearchPercentage: Integer; { $18 }
    FSpells: TIntegerList; { $1C }
    FResearchSpellID: Integer; { $20 }
    FResearchPointsLeft: Integer; { $24 }
    FSelectedHeroes: TIntegerList; { $28 }
    FSelectedItems: TIntegerList; { $2C }
    FSelectedUnits: TIntegerList; { $30 }
    FSelectedTransferGold: Integer; { $34 }
    FSelectedTransferMana: Integer; { $38 }
    FSelectedSpheres: TByteList; { $3C }
    FTransferPointsMax: Integer; { $40 }
    FTransferGoldMax: Integer; { $44 }
    FTransferManaMax: Integer; { $48 }
    FTransferPointsLeft: Integer; { $4C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure SetLeader(Leader: TLeader);
    procedure GenerateTransferUnits(Units: TUnitList);
    procedure Retrieve;
    procedure ClearSelection;
    function AddItem(Index: Integer): Boolean;
    function DeleteItem(Index: Integer): Boolean;
    function AddHero(Index: Integer): Boolean;
    function DeleteHero(Index: Integer): Boolean;
    function AddUnit(Index: Integer): Boolean;
    function DeleteUnit(Index: Integer): Boolean;
    procedure SetSelectedTransferGold(Value: Integer);
    procedure SetSelectedTransferMana(Value: Integer);
    procedure SetupSelection(const FileName: string);
    procedure AutoSelect;
    procedure ExecuteSelection;
  end;

  { TAoWCampaignScenario (instance size $14, VMT 55723C14).
    $08 ID; $0C name; $10 map file name. }
  TAoWCampaignScenario = class(TEObject)
  public
    FID: Integer; { $08 }
    FName: string; { $0C }
    FFileName: string; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAoWCampaignScenarioList (instance size 12, VMT 55723CFC) }
  TAoWCampaignScenarioList = class(TENode)
  public
    function GetScenario(Index: Integer): TAoWCampaignScenario;
    function CreateUniqueID: Integer;
    function IndexOfID(ID: Integer): Integer;
    function FindID(ID: Integer): TAoWCampaignScenario;
  end;

  { TAoWCampaign (instance size $34, VMT 55723E4C).
    $08 name; $0C map stream; $10 scenarios; $14 completed scenario IDs;
    $18 race history; $1C scenario started; $20 transfer settings;
    $24 current ID; $28 next ID; $30 difficulty; $31 play mode. }
  TAoWCampaign = class(TEObject)
  public
    FName: string; { $08 }
    FStream: TMemoryStream; { $0C }
    FScenarios: TAoWCampaignScenarioList; { $10 }
    FCompletedScenarios: TIntegerList; { $14 }
    FRaceHistory: TByteList; { $18 }
    { conflict: FRaces: TByteList; }
    FScenarioStarted: Boolean; { $1C }
    F_AoWCampaign_1D: array[0..2] of Byte;
    FTransferSettings: TAoWCampaignTransferSettings; { $20 }
    FCurrentScenarioID: Integer; { $24 }
    FNextScenarioID: Integer; { $28 }
    F_AoWCampaign_2C: array[0..3] of Byte;
    FDifficultyLevel: TCampaignDifficultyLevel; { $30 }
    FPlayMode: TPlayMode; { $31 }
    F_AoWCampaign_32: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    function CreateScenario: TAoWCampaignScenario; virtual; { $4C }
    function GetAutoSaveFileName(Auto: TCampaignAutoSaveType): string; virtual; { $50 }
    procedure SelectNextScenario(ID: Integer); virtual; { $54 }
    procedure ResetNextScenario; virtual; { $058 }
    procedure StartScenario(ID: Integer; const FileName: string; Progress: TProgressEvent); virtual; { $5C }
    procedure SetupScenario; virtual; { $060 }
    procedure FinishScenario; virtual; { $064 }
    procedure RestartScenario; virtual; { $068 }
    function AddScenario: TAoWCampaignScenario; virtual; { $6C }
    function GetContainsMap: Boolean;
  end;

  { TDiplomaticAction (instance size $30, VMT 55723F48).
    $08 RefCount, $0C Day, $10 Source, $11 Target, $12 OtherPlayer,
    $13 ActionType, $14 Reaction, $18 Gold, $1C Mana, $20 Message,
    $24 EscrowGold, $28 EscrowMana, $2C EventLogID. }
  TDiplomaticAction = class(TEObject)
  public
    FRefCount: Integer;
    FDay: Integer;
    FSource: Shortint; { $10 }
    FTarget: Shortint; { $11 }
    FOtherPlayer: Shortint; { $12 }
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
    function GetText: string; override;
    function GetTextColor: TColor; override;
    function GetLeftIcon: Integer; override;
    function GetMiddleIcon: Integer; override;
    function GetRightIcon: Integer; override;
    function GetVisible: Boolean; override;
    procedure PlayLoggedSFX(A1: Integer); override;
    procedure NotifyLogged(A1: Integer); override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure SetDiplomaticAction(Action: TDiplomaticAction);
  end;

  { TDiplomacyAIPA (instance size 24, VMT 55724318) }
  TDiplomacyAIPA = class(TAIPlayerAction)
  public
    FNextPlayer: Shortint;
    F_DiplomacyAIPA_15: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function Priority: Integer; override;
    function Activate: Boolean; override;
    function Process: Boolean; override;
    function CreateDA(Action: TDiplomaticActionType; Target, Other: Shortint; MinDays: Integer): TDiplomaticAction;
    function ExecuteDiplomacy(Player: Shortint): Boolean;
    procedure ListDebugInfo;
  end;

  { TAoWDictionary (instance size 152, VMT 557243F4) }
  TAoWDictionary = class(TIvBinaryDictionary)
  public
  end;

