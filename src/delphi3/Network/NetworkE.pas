unit NetworkE;

{ The NetworkE unit of Network.dpl (the network message layer of Age of Wonders: the player
  communication controls that move data packages between the players' systems, and the token
  system that orders the game's token events and executes them on every system in the same order)
  written for the original compiler (Delphi 3.02), class by class: tools/match.py compares the code
  DCC32 generates for every method with the code in the game's module. Declarations follow the
  original instance layouts and VMT orders (notes/classes.json); the field names are made up, the
  module has no RTTI for them. Network.dpl was compiled with the default switches.

  A data package travels as a stored TEObject: TPlayerCommunicator.SendDataPackage stores it in a
  memory stream with TEngine.StoreEObject and hands the stream to the active player communication
  control (TLocalPCC queues it for itself, TRemotePCC sends it through OnSendData to every other
  system); TPlayerCommunicator.Process retrieves the packages that arrived and triggers OnReceive.
  The token manager keeps one token control per player; the token executer activates them in turn,
  lets the active one prefetch its events (a local player sends them to the others in a token
  package, a TPassTokenTE ends the turn of the token) and executes them in token counter order. }

interface

uses
  Windows, SysUtils, Classes, Dialogs, Engine;

const
  { TRemotePCC.SendPackageData / TTokenControl.TokenEventsPrefetched: the package goes to every
    player }
  AllPlayers = $8000;

  { Class IDs }
  CID_TokenPackage = $550;
  CID_TokenEvent = $551;
  CID_TokenEventList = $552;
  CID_PassTokenTE = $554;
  CID_SyncTE = $555;

type
  TPlayerCommunicator = class;
  TTokenEvent = class;
  TTokenEventList = class;
  TTokenControl = class;
  TTokenExecuter = class;
  TTokenManager = class;

  { TPlayerCommunicationSettings.ConnectionMode: where the player sits }
  TConnectionMode = (cmLocal, cmRemote, cmGlobal);

  { TTokenEvent.Execute: erRetry leaves the event in the queue, erDone removes it and goes on with
    the next one, erDoneHalt removes it and stops executing for this call of Process }
  TExecuteResult = (erRetry, erDone, erDoneHalt);

  { TTokenExecuter.State }
  TTokenExecuterState = (tsPrefetching, tsExecuting, tsTCActivated);
  TTokenExecuterStates = set of TTokenExecuterState;

  TSendDataEvent = function(Data: Pointer; Size: Integer; SystemID: Integer): Boolean of object;
  TGetSyncValueEvent = procedure(var Value: Integer) of object;
  TTokenEventEvent = procedure(TE: TTokenEvent) of object;
  TNetworkMessageEvent = procedure(Sender: TObject; const Msg: string) of object;

  { The original reaches TENode's child list (Engine.TENode.FChildren, +8) from this unit; the
    recovered Engine.pas keeps the field private, so this layout view of TENode reads it (a
    typecast of a field or parameter compiles to no code) }
  TENodeView = class(TECustomNode)
  public
    FChildren: TEObjectList;
  end;

  { NetworkE.TDataPackage (instance size 20): +8 FSender, +$C FReceiver (player indices, stored
    with ids 1 and 2), +$10 FRefCount. The base of the packages that TPlayerCommunicator sends. }
  TDataPackage = class(TEObject)
  private
    FSender: Integer;
    FReceiver: Integer;
    FRefCount: Integer;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    procedure MainReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function Name: string; virtual;
    property Sender: Integer read FSender write FSender;
    property Receiver: Integer read FReceiver write FReceiver;
  end;

  { NetworkE.TPlayerCommunicationSettings (instance size 16): +8 FConnectionMode (stored with id 5),
    +$C FSystemID (id 6). One per player. }
  TPlayerCommunicationSettings = class(TEObject)
  private
    FConnectionMode: TConnectionMode;
    FSystemID: Integer;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    property ConnectionMode: TConnectionMode read FConnectionMode write FConnectionMode;
    property SystemID: Integer read FSystemID write FSystemID;
  end;

  { NetworkE.TPlayerCommunicationSettingsList (instance size 12): the node that owns the players'
    settings }
  TPlayerCommunicationSettingsList = class(TENode)
  public
    function GetPlayers(Index: Integer): TPlayerCommunicationSettings;
    property Players[Index: Integer]: TPlayerCommunicationSettings read GetPlayers;
  end;

  { NetworkE.TPlayerCommunicationControl (instance size 16): +4 FRefCount, +8 FPlayerCommunicator,
    +$C FPCSList. The base player communication control: one system, no transport. }
  TPlayerCommunicationControl = class(TObject)
  private
    FRefCount: Integer;
    FPlayerCommunicator: TPlayerCommunicator;
    FPCSList: TPlayerCommunicationSettingsList;
  public
    function GetLocalSystemID: Integer; virtual;
    function GetSystemCount: Integer; virtual;
    function Activate(PC: TPlayerCommunicator): Boolean; virtual;
    function CreatePCS: TPlayerCommunicationSettings; virtual;
    function Name: string; virtual;
    function ReceivePackageData(Stream: TMemoryStream): Boolean; virtual;
    function SendPackageData(APlayer: Integer; Stream: TMemoryStream): Boolean; virtual;
    constructor Create;
    destructor Destroy; override;
    procedure AddRef;
    procedure Release;
    function GetPlayers(Index: Integer): TPlayerCommunicationSettings;
    function GetCount: Integer;
    function Setup(ACount: Integer): Boolean;
    function IndexOfSystemID(ASystemID: Integer): Integer;
    property Count: Integer read GetCount;
    property Players[Index: Integer]: TPlayerCommunicationSettings read GetPlayers;
    property PlayerCommunicator: TPlayerCommunicator read FPlayerCommunicator;
    property PCSList: TPlayerCommunicationSettingsList read FPCSList;
  end;

  { NetworkE.TPlayerCommunicator (instance size 36): +8 FEngine, +$C FOnReceive, +$10
    FReceivedPackage, +$14 FSendStream, +$18 FReceiveStream, +$1C FPCC, +$20 FOnProcess. }
  TPlayerCommunicator = class(TEObject)
  private
    FEngine: TEngine;
    FOnReceive: TEventList;
    FReceivedPackage: TDataPackage;
    FSendStream: TMemoryStream;
    FReceiveStream: TMemoryStream;
    FPCC: TPlayerCommunicationControl;
    FOnProcess: TEventList;
  public
    constructor Create(AOwner: TECustomNode); override;
    function ActivatePCC(PCC: TPlayerCommunicationControl): Boolean; virtual;
    procedure Process; virtual;
    destructor Destroy; override;
    function ReceiveDataPackage: Boolean;
    function SendDataPackage(Package: TDataPackage; ASender, AReceiver: Integer): Boolean;
    property Engine: TEngine read FEngine write FEngine;
    property OnReceive: TEventList read FOnReceive;
    property ReceivedPackage: TDataPackage read FReceivedPackage;
    property PCC: TPlayerCommunicationControl read FPCC;
    property OnProcess: TEventList read FOnProcess;
  end;

  { NetworkE.TPackageDataList (instance size 8): +4 FList, the memory streams of the packages that
    wait to be received }
  TPackageDataList = class(TObject)
  private
    FList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCount: Integer;
    function GetPackageData(Index: Integer): TMemoryStream;
    procedure Clear;
    procedure Add(Stream: TMemoryStream);
    procedure AddData(Data: Pointer; Size: Integer);
    procedure Insert(Index: Integer; Stream: TMemoryStream);
    procedure Delete(Index: Integer);
    property Count: Integer read GetCount;
    property PackageData[Index: Integer]: TMemoryStream read GetPackageData;
  end;

  { NetworkE.TRemotePCC (instance size 32): +$10 FLocalSystemID, +$14 FPackageDataList, +$18
    FOnSendData. The control of a network game: the transport sends through OnSendData and hands
    what arrives to DataReceived. }
  TRemotePCC = class(TPlayerCommunicationControl)
  private
    FLocalSystemID: Integer;
    FPackageDataList: TPackageDataList;
    FOnSendData: TSendDataEvent;
  public
    function GetLocalSystemID: Integer; override;
    function GetSystemCount: Integer; override;
    function Name: string; override;
    function ReceivePackageData(Stream: TMemoryStream): Boolean; override;
    function SendPackageData(APlayer: Integer; Stream: TMemoryStream): Boolean; override;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure SetConnectionMode(Index: Integer; Mode: TConnectionMode);
    procedure SetSystemID(Index: Integer; ASystemID: Integer);
    procedure Setup(ACount: Integer; ALocalSystemID: Integer);
    procedure DataReceived(Data: Pointer; Size: Integer; SystemID: Integer);
    function SendData(Data: Pointer; Size: Integer; SystemID: Integer): Boolean;
    property OnSendData: TSendDataEvent read FOnSendData write FOnSendData;
  end;

  { NetworkE.TLocalPCC (instance size 20): +$10 FPackageDataList. The control of a game on one
    system: what is sent is received again. }
  TLocalPCC = class(TPlayerCommunicationControl)
  private
    FPackageDataList: TPackageDataList;
  public
    function GetSystemCount: Integer; override;
    function Name: string; override;
    function ReceivePackageData(Stream: TMemoryStream): Boolean; override;
    function SendPackageData(APlayer: Integer; Stream: TMemoryStream): Boolean; override;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Setup(ACount: Integer);
    procedure SetConnectionMode(Index: Integer; Mode: TConnectionMode);
  end;

  { NetworkE.TTokenEvent (instance size 16): +8 FRefCount, +$C FTokenCounter (stored with id 10;
    -1 until the executer numbers the event). The base of the game's token events. }
  TTokenEvent = class(TEObject)
  private
    FRefCount: Integer;
    FTokenCounter: Integer;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function Execute(TE: TTokenExecuter): TExecuteResult; virtual;
    property TokenCounter: Integer read FTokenCounter write FTokenCounter;
  end;

  { NetworkE.TTokenPackage (instance size 24): +$14 FTokenEvents (stored with id 5) }
  TTokenPackage = class(TDataPackage)
  private
    FTokenEvents: TTokenEventList;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    destructor Destroy; override;
    property TokenEvents: TTokenEventList read FTokenEvents;
  end;

  { NetworkE.TTokenEventList (instance size 12): +8 FList (stored with id 5), a reference node of
    token events }
  TTokenEventList = class(TEObject)
  private
    FList: TEReferenceNode;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure Assign(Source: TEObject; AEngine: TEngine); override;
    destructor Destroy; override;
    function IndexOfTokenCounter(ATokenCounter: Integer): Integer;
    function FindTE(AClassID: Integer): Integer;
    function GetEvent(Index: Integer): TTokenEvent;
    function GetCount: Integer;
    procedure SortOnTokenCounter;
    procedure AddEvents(Events: TTokenEventList);
    procedure Add(TE: TTokenEvent);
    procedure Delete(Index: Integer);
    procedure Insert(Index: Integer; TE: TTokenEvent);
    property Count: Integer read GetCount;
    property Events[Index: Integer]: TTokenEvent read GetEvent; default;
  end;

  { NetworkE.TTokenPackageDistributer (instance size 12): +4 FTokenManager, +8 FPC. Sends the token
    events of the local players in token packages and files the received ones with their players'
    token controls. }
  TTokenPackageDistributer = class(TObject)
  private
    FTokenManager: TTokenManager;
    FPC: TPlayerCommunicator;
  public
    procedure TokenPackageReceived(TP: TTokenPackage); virtual;
    constructor Create(AManager: TTokenManager); virtual;
    procedure SendTokenEvents(APlayer, AReceiver: Integer; Events: TTokenEventList); virtual;
    procedure SetPC(PC: TPlayerCommunicator);
    procedure DataPackageReceived(Sender: TObject);
    property PC: TPlayerCommunicator read FPC write SetPC;
  end;

  { NetworkE.TTokenControl (instance size 20): +4 FEvents, +8 FTokenManager, +$C FPlayer, +$10
    FActive. The token events of one player. }
  TTokenControl = class(TObject)
  private
    FEvents: TTokenEventList;
    FTokenManager: TTokenManager;
    FPlayer: Integer;
    FActive: Boolean;
  public
    procedure Add(TE: TTokenEvent); virtual;
    function PrefetchTokenEvents(Executer: TTokenExecuter): Boolean; virtual;
    procedure TokenEventsPrefetched(Executer: TTokenExecuter; Events: TTokenEventList); virtual;
    constructor Create(AManager: TTokenManager; APlayer: Integer); virtual;
    procedure AddEvent(TE: TTokenEvent); virtual;
    procedure AddEventEx(TE: TTokenEvent); virtual;
    procedure AddEvents(Events: TTokenEventList); virtual;
    destructor Destroy; override;
    procedure ClearEvents;
    function GetEvent(Index: Integer): TTokenEvent;
    function GetCount: Integer;
    function Local: Boolean;
    function Global: Boolean;
    function Remote: Boolean;
    function GetPrefetchableTokenEvents(Executer: TTokenExecuter): Integer;
    property Events: TTokenEventList read FEvents;
    property Player: Integer read FPlayer;
    property Active: Boolean read FActive write FActive;
    property Count: Integer read GetCount;
  end;

  { NetworkE.TTokenExecuter (instance size 92): +4 FActiveTC, +8 FPrefetchTC, +$C FActiveTCIndex,
    +$10 FEvents, +$14 FTCList, +$18 FTokenCounter, +$1C FRound, +$20 FExecuteCount, +$24 FState,
    +$28 FOnEventsExecuted, +$2C FOnActivateTC, +$30 FOnSyncError, +$38 FOnGetSyncValue, +$40
    FOnExecuteTokenEvent, +$48 FExecuting, +$4C FLockCount, +$50 FSystemEvents, +$54 FHoldTC,
    +$58 FTokenManager. }
  TTokenExecuter = class(TObject)
  private
    FActiveTC: TTokenControl;
    FPrefetchTC: TTokenControl;
    FActiveTCIndex: Integer;
    FEvents: TTokenEventList;
    FTCList: TList;
    FTokenCounter: Integer;
    FRound: Integer;
    FExecuteCount: Integer;
    FState: TTokenExecuterStates;
    FOnEventsExecuted: TEventList;
    FOnActivateTC: TEventList;
    FOnSyncError: TNotifyEvent;
    FOnGetSyncValue: TGetSyncValueEvent;
    FOnExecuteTokenEvent: TTokenEventEvent;
    FExecuting: Boolean;
    FLockCount: Integer;
    FSystemEvents: TTokenEventList;
    FHoldTC: Boolean;
    FTokenManager: TTokenManager;
  public
    function ExecuteTokenEvent(TE: TTokenEvent): TExecuteResult; virtual;
    constructor Create(AManager: TTokenManager);
    destructor Destroy; override;
    function GetSyncValue: Integer;
    function GetTC(Index: Integer): TTokenControl;
    procedure AddTC(TC: TTokenControl);
    procedure DeleteTC(Index: Integer);
    procedure RemoveTC(TC: TTokenControl);
    procedure InsertTC(Index: Integer; TC: TTokenControl);
    procedure Reset;
    procedure PrefetchTokenEvent(TE: TTokenEvent);
    function GetExecutingTokenEvent: TTokenEvent;
    function InsertExecuteEvent(TE: TTokenEvent): Boolean;
    procedure Initialize(AIndex: Integer);
    procedure ActivateTC(Index: Integer);
    procedure ActivateNextTC;
    procedure Lock;
    procedure Unlock;
    function GetLocked: Boolean;
    function ProcessSystemTokenEvents: Boolean;
    procedure AddSystemEvent(TE: TTokenEvent);
    procedure Process;
    property ActiveTC: TTokenControl read FActiveTC;
    property PrefetchTC: TTokenControl read FPrefetchTC;
    property ActiveTCIndex: Integer read FActiveTCIndex;
    property TokenCounter: Integer read FTokenCounter;
    property Round: Integer read FRound; property ExecuteCount: Integer read FExecuteCount;
    property State: TTokenExecuterStates read FState;
    property Locked: Boolean read GetLocked;
    property HoldTC: Boolean read FHoldTC write FHoldTC;
    property Executing: Boolean read FExecuting;
    property OnEventsExecuted: TEventList read FOnEventsExecuted;
    property OnActivateTC: TEventList read FOnActivateTC;
    property OnSyncError: TNotifyEvent read FOnSyncError write FOnSyncError;
    property OnGetSyncValue: TGetSyncValueEvent read FOnGetSyncValue write FOnGetSyncValue;
    property OnExecuteTokenEvent: TTokenEventEvent read FOnExecuteTokenEvent write FOnExecuteTokenEvent;
  end;

  { NetworkE.TTokenManager (instance size 28): +4 FTokenExecuter, +8 FTokenPackageDistributer, +$C
    FOwner, +$10 FTokenControls (one per player, nil for a free slot), +$14 FOnMessage. }
  TTokenManager = class(TObject)
  private
    FTokenExecuter: TTokenExecuter;
    FTokenPackageDistributer: TTokenPackageDistributer;
    FOwner: TObject;
    FTokenControls: TList;
    FOnMessage: TNetworkMessageEvent;
  public
    function CreateTokenExecuter: TTokenExecuter; virtual;
    function CreateTokenPackageDistributer: TTokenPackageDistributer; virtual;
    function CreateTokenControl(APlayer: Integer): TTokenControl; virtual;
    procedure Initialize(PC: TPlayerCommunicator); virtual;
    procedure Process; virtual;
    function PlayerReady(APlayer: Integer): Boolean; virtual;
    procedure CreatePlayer(APlayer: Integer); virtual;
    procedure DeletePlayer(APlayer: Integer); virtual;
    procedure ClearPlayers; virtual;
    constructor Create(AOwner: TObject);
    destructor Destroy; override;
    function GetCount: Integer;
    function GetTokenControl(APlayer: Integer): TTokenControl;
    procedure TriggerMessage(const Msg: string);
    property TokenExecuter: TTokenExecuter read FTokenExecuter;
    property TokenPackageDistributer: TTokenPackageDistributer read FTokenPackageDistributer;
    property Owner: TObject read FOwner;
    property Count: Integer read GetCount;
    property TokenControls[APlayer: Integer]: TTokenControl read GetTokenControl;
    property OnMessage: TNetworkMessageEvent read FOnMessage write FOnMessage;
  end;

  { NetworkE.TPassTokenTE (instance size 16): ends the turn of the token control that prefetched
    it }
  TPassTokenTE = class(TTokenEvent)
  public
    class function ClassID: Integer; override;
  end;

  { NetworkE.TSyncTE (instance size 20): +$10 FSyncValue (stored with id $14), the sync value of the
    system that sent it; another value on execution triggers OnSyncError }
  TSyncTE = class(TTokenEvent)
  private
    FSyncValue: Integer;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: TTokenExecuter): TExecuteResult; override;
    property SyncValue: Integer read FSyncValue write FSyncValue;
  end;

procedure RegisterNetworkEngine(AEngine: TEngine);

var
  NetworkEngineDID: Integer;

implementation

{ TPlayerCommunicationSettings }

constructor TPlayerCommunicationSettings.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FConnectionMode := cmLocal;
end;

procedure TPlayerCommunicationSettings.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FConnectionMode, SizeOf(FConnectionMode), 5);
  Stream.rwInteger(FSystemID, 6);
end;

{ TPlayerCommunicationSettingsList }

function TPlayerCommunicationSettingsList.GetPlayers(Index: Integer): TPlayerCommunicationSettings;
begin
  Result := TPlayerCommunicationSettings(TENodeView(Self).FChildren.List[Index]);
end;

{ TPlayerCommunicationControl }

constructor TPlayerCommunicationControl.Create;
begin
  inherited Create;
  FRefCount := 1;
  FPCSList := TPlayerCommunicationSettingsList.Create(nil);
end;

destructor TPlayerCommunicationControl.Destroy;
begin
  FPCSList.Free;
  inherited Destroy;
end;

procedure TPlayerCommunicationControl.AddRef;
begin
  Inc(FRefCount);
end;

procedure TPlayerCommunicationControl.Release;
begin
  Dec(FRefCount);
  if FRefCount = 0 then
    Destroy;
end;

function TPlayerCommunicationControl.Name: string;
begin
  Result := '';
end;

function TPlayerCommunicationControl.CreatePCS: TPlayerCommunicationSettings;
begin
  Result := TPlayerCommunicationSettings.Create(nil);
end;

function TPlayerCommunicationControl.GetPlayers(Index: Integer): TPlayerCommunicationSettings;
begin
  if (Index >= 0) and (Index < FPCSList.Count) then
    Result := FPCSList.Players[Index]
  else
    Result := nil;
end;

function TPlayerCommunicationControl.GetCount: Integer;
begin
  Result := FPCSList.Count;
end;

function TPlayerCommunicationControl.Activate(PC: TPlayerCommunicator): Boolean;
begin
  FPlayerCommunicator := PC;
  Result := True;
end;

function TPlayerCommunicationControl.Setup(ACount: Integer): Boolean;
var
  I: Integer;
begin
  FPCSList.Clear;
  for I := 0 to ACount - 1 do
    CreatePCS.Owner := FPCSList;
  Result := True;
end;

function TPlayerCommunicationControl.GetSystemCount: Integer;
begin
  Result := 1;
end;

function TPlayerCommunicationControl.IndexOfSystemID(ASystemID: Integer): Integer;
begin
  Result := GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    if FPCSList.Players[Result].FSystemID = ASystemID then
      Exit;
  end;
  Result := -1;
end;

function TPlayerCommunicationControl.GetLocalSystemID: Integer;
begin
  Result := 1;
end;

function TPlayerCommunicationControl.ReceivePackageData(Stream: TMemoryStream): Boolean;
begin
  Result := False;
end;

function TPlayerCommunicationControl.SendPackageData(APlayer: Integer; Stream: TMemoryStream): Boolean;
begin
  Result := False;
end;

{ TDataPackage }

constructor TDataPackage.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
end;

function TDataPackage.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TDataPackage.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if Result = 0 then
    Destroy;
end;

function TDataPackage.Name: string;
begin
  Result := ClassName;
end;

{ The original does not call the inherited ReadWrite. }
procedure TDataPackage.ReadWrite(Stream: TEStorageStream);
begin
  Stream.rwInteger(FSender, 1);
  Stream.rwInteger(FReceiver, 2);
end;

procedure TDataPackage.MainReadWrite(Stream: TEStorageStream);
begin
  ReadWrite(Stream);
end;

{ TPlayerCommunicator }

constructor TPlayerCommunicator.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FReceivedPackage := nil;
  FOnReceive := TEventList.Create;
  FSendStream := TMemoryStream.Create;
  FReceiveStream := TMemoryStream.Create;
  FOnProcess := TEventList.Create;
end;

destructor TPlayerCommunicator.Destroy;
begin
  FOnReceive.Free;
  FSendStream.Free;
  FReceiveStream.Free;
  FOnProcess.Free;
  if FPCC <> nil then
  begin
    FPCC.Release;
    FPCC := nil;
  end;
  inherited Destroy;
end;

function TPlayerCommunicator.ActivatePCC(PCC: TPlayerCommunicationControl): Boolean;
begin
  if FPCC <> nil then
  begin
    FPCC.Release;
    FPCC := nil;
  end;
  FPCC := PCC;
  if FPCC <> nil then
  begin
    FPCC.AddRef;
    Result := FPCC.Activate(Self);
    if not Result then
    begin
      FPCC.Release;
      FPCC := nil;
    end;
  end
  else
    Result := True;
end;

procedure TPlayerCommunicator.Process;
begin
  while ReceiveDataPackage do
    ;
  FOnProcess.TriggerNotifyEvents(Self);
end;

function TPlayerCommunicator.ReceiveDataPackage: Boolean;
var
  Obj: TEObject;
begin
  FReceiveStream.Clear;
  FReceiveStream.Position := 0;
  if FPCC.ReceivePackageData(FReceiveStream) then
  begin
    try
      Obj := FEngine.RetrieveEObject(FReceiveStream, nil);
      if Obj is TDataPackage then
      begin
        FReceivedPackage := TDataPackage(Obj);
        FOnReceive.TriggerNotifyEvents(Self);
        FReceivedPackage.Release;
      end
      else
        Obj.Free;
    except
    end;
    FReceivedPackage := nil;
    Result := True;
  end
  else
    Result := False;
end;

function TPlayerCommunicator.SendDataPackage(Package: TDataPackage; ASender, AReceiver: Integer): Boolean;
begin
  Package.FSender := ASender;
  Package.FReceiver := AReceiver;
  FSendStream.Clear;
  FEngine.StoreEObject(FSendStream, Package, nil);
  FSendStream.Position := 0;
  Result := FPCC.SendPackageData(AReceiver, FSendStream);
end;

{ TLocalPCC }

constructor TLocalPCC.Create;
begin
  inherited Create;
  FPackageDataList := TPackageDataList.Create;
end;

destructor TLocalPCC.Destroy;
begin
  FPackageDataList.Free;
  inherited Destroy;
end;

function TLocalPCC.GetSystemCount: Integer;
begin
  Result := 1;
end;

function TLocalPCC.Name: string;
begin
  Result := 'Local';
end;

procedure TLocalPCC.Clear;
begin
  FPackageDataList.Clear;
end;

function TLocalPCC.ReceivePackageData(Stream: TMemoryStream): Boolean;
begin
  if FPackageDataList.Count <> 0 then
  begin
    Stream.Size := FPackageDataList.PackageData[0].Size;
    Move(FPackageDataList.PackageData[0].Memory^, Stream.Memory^, Stream.Size);
    FPackageDataList.Delete(0);
    Result := True;
  end
  else
    Result := False;
end;

function TLocalPCC.SendPackageData(APlayer: Integer; Stream: TMemoryStream): Boolean;
begin
  FPackageDataList.Add(Stream);
  Result := True;
end;

procedure TLocalPCC.Setup(ACount: Integer);
var
  I: Integer;
begin
  inherited Setup(ACount);
  for I := FPCSList.Count - 1 downto 0 do
    FPCSList.Players[I].FSystemID := GetLocalSystemID;
end;

procedure TLocalPCC.SetConnectionMode(Index: Integer; Mode: TConnectionMode);
begin
  FPCSList.Players[Index].FConnectionMode := Mode;
end;

{ TRemotePCC }

constructor TRemotePCC.Create;
begin
  inherited Create;
  FPackageDataList := TPackageDataList.Create;
end;

destructor TRemotePCC.Destroy;
begin
  FPackageDataList.Free;
  inherited Destroy;
end;

procedure TRemotePCC.Clear;
begin
  FPackageDataList.Clear;
end;

function TRemotePCC.Name: string;
begin
  Result := 'Remote';
end;

{ The number of different system IDs among the players }
function TRemotePCC.GetSystemCount: Integer;
var
  I, J, ID: Integer;
  Unique: Boolean;
begin
  Result := 0;
  for I := 0 to FPCSList.Count - 1 do
  begin
    ID := FPCSList.Players[I].FSystemID;
    Unique := True;
    J := 0;
    while (J <> I) and Unique do
    begin
      Unique := ID <> FPCSList.Players[J].FSystemID;
      Inc(J);
    end;
    if Unique then
      Inc(Result);
  end;
end;

procedure TRemotePCC.SetConnectionMode(Index: Integer; Mode: TConnectionMode);
begin
  FPCSList.Players[Index].FConnectionMode := Mode;
end;

procedure TRemotePCC.SetSystemID(Index: Integer; ASystemID: Integer);
begin
  FPCSList.Players[Index].FSystemID := ASystemID;
end;

procedure TRemotePCC.Setup(ACount: Integer; ALocalSystemID: Integer);
begin
  inherited Setup(ACount);
  FLocalSystemID := ALocalSystemID;
end;

function TRemotePCC.GetLocalSystemID: Integer;
begin
  Result := FLocalSystemID;
end;

function TRemotePCC.ReceivePackageData(Stream: TMemoryStream): Boolean;
begin
  if FPackageDataList.Count <> 0 then
  begin
    Stream.Size := FPackageDataList.PackageData[0].Size;
    Move(FPackageDataList.PackageData[0].Memory^, Stream.Memory^, Stream.Size);
    FPackageDataList.Delete(0);
    Result := True;
  end
  else
    Result := False;
end;

procedure TRemotePCC.DataReceived(Data: Pointer; Size: Integer; SystemID: Integer);
begin
  FPackageDataList.AddData(Data, Size);
end;

function TRemotePCC.SendData(Data: Pointer; Size: Integer; SystemID: Integer): Boolean;
begin
  if Assigned(FOnSendData) then
    Result := FOnSendData(Data, Size, SystemID)
  else
    Result := False;
end;

{ A package for every player (AllPlayers) goes to system 0, the transport's broadcast; a package
  for every player or for a player on this system is also received here. }
function TRemotePCC.SendPackageData(APlayer: Integer; Stream: TMemoryStream): Boolean;
var
  SystemID: Integer;
begin
  if APlayer = AllPlayers then
    SystemID := 0
  else
    SystemID := FPCSList.Players[APlayer].FSystemID;
  if SystemID <> FLocalSystemID then
    Result := SendData(Stream.Memory, Stream.Size, SystemID)
  else
    Result := True;
  if (APlayer = AllPlayers) or (SystemID = FLocalSystemID) then
    FPackageDataList.Add(Stream);
end;

{ TPackageDataList }

constructor TPackageDataList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TPackageDataList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

function TPackageDataList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPackageDataList.GetPackageData(Index: Integer): TMemoryStream;
begin
  Result := TMemoryStream(FList.List[Index]);
end;

procedure TPackageDataList.Clear;
var
  L: TList;
begin
  L := FList;
  while L.Count <> 0 do
  begin
    TObject(L.List[L.Count - 1]).Free;
    L.Delete(L.Count - 1);
  end;
end;

procedure TPackageDataList.Add(Stream: TMemoryStream);
var
  S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  S.Size := Stream.Size;
  Move(Stream.Memory^, S.Memory^, S.Size);
  FList.Add(S);
end;

procedure TPackageDataList.AddData(Data: Pointer; Size: Integer);
var
  S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  S.Size := Size;
  Move(Data^, S.Memory^, Size);
  FList.Add(S);
end;

procedure TPackageDataList.Insert(Index: Integer; Stream: TMemoryStream);
var
  S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  S.Size := Stream.Size;
  Move(Stream.Memory^, S.Memory^, S.Size);
  FList.Insert(Index, S);
end;

procedure TPackageDataList.Delete(Index: Integer);
begin
  TObject(FList.List[Index]).Free;
  FList.Delete(Index);
end;

{ TTokenEvent }

constructor TTokenEvent.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FTokenCounter := -1;
end;

class function TTokenEvent.ClassID: Integer;
begin
  Result := CID_TokenEvent;
end;

function TTokenEvent.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TTokenEvent.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if Result = 0 then
    Destroy;
end;

procedure TTokenEvent.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FTokenCounter, 10);
end;

function TTokenEvent.Execute(TE: TTokenExecuter): TExecuteResult;
begin
  Result := erDone;
end;

{ TTokenEventList }

constructor TTokenEventList.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FList := TEReferenceNode.Create(nil);
end;

destructor TTokenEventList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

class function TTokenEventList.ClassID: Integer;
begin
  Result := CID_TokenEventList;
end;

procedure TTokenEventList.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FList, 5);
end;

procedure TTokenEventList.Assign(Source: TEObject; AEngine: TEngine);
begin
  FList.Clear;
  AddEvents(TTokenEventList(Source));
end;

function TTokenEventList.IndexOfTokenCounter(ATokenCounter: Integer): Integer;
begin
  Result := FList.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TTokenEvent(TENodeView(FList).FChildren.List[Result]).FTokenCounter = ATokenCounter then
      Exit;
  end;
  Result := -1;
end;

function TTokenEventList.FindTE(AClassID: Integer): Integer;
var
  C: Integer;
begin
  Result := 0;
  C := FList.Count;
  while (Result <> C) and (TTokenEvent(TENodeView(FList).FChildren.List[Result]).ClassID <> AClassID) do
    Inc(Result);
  if Result = C then
    Result := -1;
end;

function TTokenEventList.GetEvent(Index: Integer): TTokenEvent;
begin
  Result := TTokenEvent(TENodeView(FList).FChildren.List[Index]);
end;

function TTokenEventList.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TTokenEventList.Clear;
begin
  FList.Clear;
end;

function CompareTokenCounter(Item1, Item2: Pointer): Integer;
begin
  Result := TTokenEvent(Item1).FTokenCounter - TTokenEvent(Item2).FTokenCounter;
end;

procedure TTokenEventList.SortOnTokenCounter;
begin
  TENodeView(FList).FChildren.Sort(CompareTokenCounter);
end;

procedure TTokenEventList.AddEvents(Events: TTokenEventList);
var
  I: Integer;
begin
  for I := 0 to Events.Count - 1 do
    FList.AddChild(Events[I]);
end;

procedure TTokenEventList.Add(TE: TTokenEvent);
begin
  FList.AddChild(TE);
end;

procedure TTokenEventList.Delete(Index: Integer);
begin
  FList.RemoveChild(FList.Children[Index]);
end;

{ Inserts without TEReferenceNode.AddChild, so the reference is taken here }
procedure TTokenEventList.Insert(Index: Integer; TE: TTokenEvent);
begin
  TE.AddRef;
  TENodeView(FList).FChildren.Insert(Index, TE);
end;

{ TTokenPackage }

constructor TTokenPackage.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FTokenEvents := TTokenEventList.Create(nil);
end;

destructor TTokenPackage.Destroy;
begin
  FTokenEvents.Free;
  inherited Destroy;
end;

class function TTokenPackage.ClassID: Integer;
begin
  Result := CID_TokenPackage;
end;

procedure TTokenPackage.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FTokenEvents, 5);
end;

{ TTokenPackageDistributer }

constructor TTokenPackageDistributer.Create(AManager: TTokenManager);
begin
  inherited Create;
  FTokenManager := AManager;
end;

procedure TTokenPackageDistributer.SetPC(PC: TPlayerCommunicator);
begin
  if FPC <> nil then
    FPC.FOnReceive.Remove(DataPackageReceived);
  FPC := PC;
  if FPC <> nil then
    FPC.FOnReceive.Add(DataPackageReceived);
end;

procedure TTokenPackageDistributer.DataPackageReceived(Sender: TObject);
begin
  if TPlayerCommunicator(Sender).FReceivedPackage is TTokenPackage then
    TokenPackageReceived(TTokenPackage(TPlayerCommunicator(Sender).FReceivedPackage));
end;

{ The token events of a package from another system go to the token control of the sending player,
  unless they were already executed or are already there. }
procedure TTokenPackageDistributer.TokenPackageReceived(TP: TTokenPackage);
var
  I: Integer;
begin
  if FTokenManager <> nil then
    if FPC.FPCC.GetLocalSystemID <> FPC.FPCC.GetPlayers(TP.FSender).FSystemID then
      for I := 0 to TP.FTokenEvents.Count - 1 do
        if TP.FTokenEvents[I].FTokenCounter >= FTokenManager.FTokenExecuter.FTokenCounter then
        begin
          if FTokenManager.GetTokenControl(TP.FSender).FEvents.IndexOfTokenCounter(TP.FTokenEvents[I].FTokenCounter) = -1 then
          begin
            FTokenManager.GetTokenControl(TP.FSender).Add(TP.FTokenEvents[I]);
            FTokenManager.GetTokenControl(TP.FSender).FEvents.SortOnTokenCounter;
          end
          else
            FTokenManager.TriggerMessage('TokenEvent already exists');
        end
        else
          FTokenManager.TriggerMessage('TokenEvent already executed');
end;

procedure TTokenPackageDistributer.SendTokenEvents(APlayer, AReceiver: Integer; Events: TTokenEventList);
var
  TP: TTokenPackage;
begin
  TP := TTokenPackage.Create(nil);
  TP.FTokenEvents.Assign(Events, nil);
  FPC.SendDataPackage(TP, APlayer, AReceiver);
  TP.Release;
end;

{ TTokenControl }

constructor TTokenControl.Create(AManager: TTokenManager; APlayer: Integer);
begin
  inherited Create;
  FEvents := TTokenEventList.Create(nil);
  FTokenManager := AManager;
  FPlayer := APlayer;
  FActive := True;
  if (FTokenManager <> nil) and (FTokenManager.FTokenExecuter <> nil) then
    FTokenManager.FTokenExecuter.AddTC(Self);
end;

destructor TTokenControl.Destroy;
begin
  if (FTokenManager <> nil) and (FTokenManager.FTokenExecuter <> nil) then
    FTokenManager.FTokenExecuter.RemoveTC(Self);
  FEvents.Free;
  inherited Destroy;
end;

{ Keeps the events sorted on their token counters; an event without one goes to the end }
procedure TTokenControl.Add(TE: TTokenEvent);
var
  I: Integer;
begin
  if TE.FTokenCounter <> -1 then
  begin
    I := 0;
    while (I <> FEvents.Count) and (FEvents[I].FTokenCounter < TE.FTokenCounter) do
      Inc(I);
    if I < FEvents.Count then
    begin
      if FEvents[I].FTokenCounter = TE.FTokenCounter then
        raise Exception.Create('Double TokenCounter defined');
      FEvents.Insert(I, TE);
    end
    else
      FEvents.Add(TE);
  end
  else
    FEvents.Add(TE);
end;

procedure TTokenControl.AddEvent(TE: TTokenEvent);
begin
  if Remote then
    raise Exception.Create('Cannot Add Remote events');
  Add(TE);
end;

procedure TTokenControl.AddEventEx(TE: TTokenEvent);
begin
  Add(TE);
end;

procedure TTokenControl.ClearEvents;
begin
  FEvents.Clear;
end;

function TTokenControl.GetEvent(Index: Integer): TTokenEvent;
begin
  Result := FEvents[Index];
end;

function TTokenControl.GetCount: Integer;
begin
  Result := FEvents.Count;
end;

procedure TTokenControl.AddEvents(Events: TTokenEventList);
var
  I: Integer;
begin
  for I := 0 to Events.Count - 1 do
    AddEvent(Events[I]);
end;

function TTokenControl.Local: Boolean;
begin
  with FTokenManager.FTokenPackageDistributer.FPC.FPCC do
    Result := GetPlayers(FPlayer).FConnectionMode = cmLocal;
end;

function TTokenControl.Global: Boolean;
begin
  with FTokenManager.FTokenPackageDistributer.FPC.FPCC do
    Result := GetPlayers(FPlayer).FConnectionMode = cmGlobal;
end;

function TTokenControl.Remote: Boolean;
begin
  with FTokenManager.FTokenPackageDistributer.FPC.FPCC do
    Result := GetPlayers(FPlayer).FConnectionMode = cmRemote;
end;

{ The number of events of a remote player that can be executed now: they must follow the
  executer's token counter without a gap, up to and including the first TPassTokenTE }
function TTokenControl.GetPrefetchableTokenEvents(Executer: TTokenExecuter): Integer;
var
  I: Integer;
  InOrder, PassToken: Boolean;
begin
  if Remote then
  begin
    I := 0;
    InOrder := True;
    PassToken := False;
    while InOrder and not PassToken and (I < FEvents.Count) do
    begin
      InOrder := FEvents[I].FTokenCounter = Executer.FTokenCounter + I;
      PassToken := FEvents[I].ClassID = CID_PassTokenTE;
      Inc(I);
    end;
    if InOrder then
      Result := I
    else
      Result := 0;
  end
  else
    Result := FEvents.Count;
end;

{ A local player's events end with a TPassTokenTE (after a TSyncTE when the executer checks the
  sync); a remote player's events are prefetched only when they are complete }
function TTokenControl.PrefetchTokenEvents(Executer: TTokenExecuter): Boolean;
var
  I, N: Integer;
  TE: TTokenEvent;
begin
  if Global or Local then
  begin
    if (FEvents.Count <> 0) or (Executer.FHoldTC <> True) then
    begin
      if Local then
      begin
        if Assigned(Executer.FOnSyncError) then
        begin
          TE := TSyncTE.Create(nil);
          TSyncTE(TE).FSyncValue := Executer.GetSyncValue;
          FEvents.Insert(0, TE);
          TE.Release;
        end;
        TE := TPassTokenTE.Create(nil);
        FEvents.Add(TE);
        TE.Release;
      end;
      for I := 0 to FEvents.Count - 1 do
        Executer.PrefetchTokenEvent(FEvents[I]);
      FEvents.Clear;
      Result := True;
    end
    else
      Result := True;
  end
  else if Remote then
  begin
    N := GetPrefetchableTokenEvents(Executer);
    if N > 0 then
    begin
      for I := 0 to N - 1 do
        Executer.PrefetchTokenEvent(FEvents[I]);
      for I := N - 1 downto 0 do
        FEvents.Delete(I);
      Result := True;
    end
    else
      Result := False;
  end
  else
    Result := True;
end;

{ A local player's prefetched events go to every other player }
procedure TTokenControl.TokenEventsPrefetched(Executer: TTokenExecuter; Events: TTokenEventList);
begin
  if Local and not Global and (Events.Count <> 0) then
    FTokenManager.FTokenPackageDistributer.SendTokenEvents(FPlayer, AllPlayers, Events);
end;

{ TTokenExecuter }

constructor TTokenExecuter.Create(AManager: TTokenManager);
begin
  inherited Create;
  FTokenManager := AManager;
  FEvents := TTokenEventList.Create(nil);
  FTCList := TList.Create;
  FOnEventsExecuted := TEventList.Create;
  FOnActivateTC := TEventList.Create;
  FSystemEvents := TTokenEventList.Create(nil);
end;

destructor TTokenExecuter.Destroy;
begin
  Reset;
  FEvents.Free;
  FTCList.Free;
  FOnEventsExecuted.Free;
  FOnActivateTC.Free;
  FSystemEvents.Free;
  inherited Destroy;
end;

function TTokenExecuter.GetSyncValue: Integer;
begin
  if Assigned(FOnGetSyncValue) then
    FOnGetSyncValue(Result)
  else
    Result := 0;
end;

function TTokenExecuter.GetTC(Index: Integer): TTokenControl;
begin
  Result := TTokenControl(FTCList.List[Index]);
end;

procedure TTokenExecuter.AddTC(TC: TTokenControl);
begin
  FTCList.Add(TC);
end;

procedure TTokenExecuter.DeleteTC(Index: Integer);
begin
  FTCList.Delete(Index);
end;

procedure TTokenExecuter.RemoveTC(TC: TTokenControl);
begin
  FTCList.Remove(TC);
end;

procedure TTokenExecuter.InsertTC(Index: Integer; TC: TTokenControl);
begin
  FTCList.Insert(Index, TC);
end;

procedure TTokenExecuter.Reset;
begin
  FTCList.Clear;
  FActiveTC := nil;
  FActiveTCIndex := -1;
  FState := [];
  FRound := 0;
  FTokenCounter := 0;
end;

{ Numbers an event that has no token counter yet (or an old one) and queues it }
procedure TTokenExecuter.PrefetchTokenEvent(TE: TTokenEvent);
begin
  if tsPrefetching in FState then
  begin
    if (TE.FTokenCounter >= FTokenCounter) or (TE.FTokenCounter = -1) then
    begin
      TE.FTokenCounter := FEvents.Count + FTokenCounter;
      FEvents.Add(TE);
    end;
    FExecuteCount := 0;
  end;
end;

function TTokenExecuter.ExecuteTokenEvent(TE: TTokenEvent): TExecuteResult;
begin
  FExecuting := True;
  if Assigned(FOnExecuteTokenEvent) then
    FOnExecuteTokenEvent(TE);
  try
    Result := TE.Execute(Self);
  except
    ShowMessage('Exception occured during ' + TE.ClassName);
    Result := erDone;
  end;
  Inc(FExecuteCount);
  FExecuting := False;
end;

function TTokenExecuter.GetExecutingTokenEvent: TTokenEvent;
begin
  if (tsExecuting in FState) and (FEvents.Count <> 0) then
    Result := FEvents[0]
  else
    Result := nil;
end;

function TTokenExecuter.InsertExecuteEvent(TE: TTokenEvent): Boolean;
begin
  if tsExecuting in FState then
  begin
    FEvents.Add(TE);
    Result := True;
  end
  else
    Result := False;
end;

procedure TTokenExecuter.Initialize(AIndex: Integer);
begin
  FState := [];
  if AIndex < FTCList.Count then
  begin
    FActiveTC := FTCList[AIndex];
    FActiveTCIndex := AIndex;
    FRound := 0;
  end;
end;

procedure TTokenExecuter.ActivateTC(Index: Integer);
begin
  FActiveTC := FTCList[Index];
  FActiveTC.FActive := True;
  FActiveTCIndex := Index;
  FOnActivateTC.TriggerNotifyEvents(Self);
  if tsExecuting in FState then
    FState := FState + [tsTCActivated];
end;

{ The next active token control after the current one; a wrap starts the next round }
procedure TTokenExecuter.ActivateNextTC;
var
  N: Integer;
begin
  N := 0;
  repeat
    Inc(FActiveTCIndex);
    Inc(N);
    if FTCList.Count <= FActiveTCIndex then
    begin
      FActiveTCIndex := 0;
      Inc(FRound);
    end;
  until TTokenControl(FTCList[FActiveTCIndex]).FActive or (N > FTCList.Count);
  if TTokenControl(FTCList[FActiveTCIndex]).FActive then
    ActivateTC(FActiveTCIndex);
end;

procedure TTokenExecuter.Lock;
begin
  Inc(FLockCount);
end;

procedure TTokenExecuter.Unlock;
begin
  Dec(FLockCount);
end;

function TTokenExecuter.GetLocked: Boolean;
begin
  Result := FLockCount <> 0;
end;

{ The system events run between the token controls' events; True while some remain }
function TTokenExecuter.ProcessSystemTokenEvents: Boolean;
var
  R: TExecuteResult;
begin
  if not (tsExecuting in FState) and (FSystemEvents.Count > 0) and (FLockCount = 0) then
  begin
    if FSystemEvents[0].FTokenCounter = -1 then
    begin
      FExecuteCount := 0;
      FSystemEvents[0].FTokenCounter := FTokenCounter;
    end;
    R := ExecuteTokenEvent(FSystemEvents[0]);
    if (R = erDone) or (R = erDoneHalt) then
    begin
      FSystemEvents.Delete(0);
      Inc(FTokenCounter);
      FExecuteCount := 0;
    end;
    Result := FSystemEvents.Count <> 0;
  end
  else
    Result := False;
end;

procedure TTokenExecuter.AddSystemEvent(TE: TTokenEvent);
begin
  FSystemEvents.Add(TE);
end;

{ Lets the active token control prefetch its events, executes them and activates the next token
  control, for at most one round of token controls }
procedure TTokenExecuter.Process;
var
  I: Integer;
  Prefetched: Boolean;
  R: TExecuteResult;
begin
  if (FActiveTC <> nil) and not ProcessSystemTokenEvents then
  begin
    I := 0;
    Prefetched := True;
    R := erDone;
    while (FLockCount = 0) and (Prefetched = True) and (R = erDone) and (I < FTCList.Count) do
    begin
      if not (tsExecuting in FState) then
      begin
        FState := FState + [tsPrefetching];
        FEvents.Clear;
        Prefetched := FActiveTC.PrefetchTokenEvents(Self);
        FState := FState - [tsPrefetching];
        if Prefetched = True then
        begin
          FState := FState + [tsExecuting];
          FPrefetchTC := FActiveTC;
          FActiveTC.TokenEventsPrefetched(Self, FEvents);
        end;
      end;
      if tsExecuting in FState then
      begin
        while (R = erDone) and (FEvents.Count <> 0) do
        begin
          R := ExecuteTokenEvent(FEvents[0]);
          if (R = erDone) or (R = erDoneHalt) then
          begin
            FEvents.Delete(0);
            Inc(FTokenCounter);
            FExecuteCount := 0;
          end;
        end;
        if FEvents.Count = 0 then
        begin
          FState := FState - [tsExecuting];
          FOnEventsExecuted.TriggerNotifyEvents(Self);
          if not FHoldTC and not (tsTCActivated in FState) then
            ActivateNextTC;
          FState := FState - [tsTCActivated];
          FPrefetchTC := nil;
          Inc(I);
        end;
      end;
    end;
  end;
end;

{ TTokenManager }

{ The original does not call the inherited constructor. }
constructor TTokenManager.Create(AOwner: TObject);
begin
  FOwner := AOwner;
  FTokenControls := TList.Create;
  FTokenExecuter := CreateTokenExecuter;
  FTokenPackageDistributer := CreateTokenPackageDistributer;
end;

destructor TTokenManager.Destroy;
begin
  ClearPlayers;
  FTokenControls.Free;
  FTokenExecuter.Free;
  FTokenPackageDistributer.Free;
  inherited Destroy;
end;

function TTokenManager.GetCount: Integer;
begin
  Result := FTokenControls.Count;
end;

procedure TTokenManager.Initialize(PC: TPlayerCommunicator);
var
  I: Integer;
begin
  FTokenPackageDistributer.SetPC(PC);
  if PC.FPCC.GetCount > 0 then
  begin
    ClearPlayers;
    for I := 0 to PC.FPCC.GetCount - 1 do
      CreatePlayer(I);
  end;
  FTokenExecuter.Initialize(0);
end;

function TTokenManager.CreateTokenExecuter: TTokenExecuter;
begin
  Result := TTokenExecuter.Create(Self);
end;

function TTokenManager.CreateTokenPackageDistributer: TTokenPackageDistributer;
begin
  Result := TTokenPackageDistributer.Create(Self);
end;

function TTokenManager.CreateTokenControl(APlayer: Integer): TTokenControl;
begin
  Result := TTokenControl.Create(Self, APlayer);
end;

procedure TTokenManager.Process;
begin
  if FTokenExecuter <> nil then
    FTokenExecuter.Process;
end;

procedure TTokenManager.CreatePlayer(APlayer: Integer);
begin
  if (APlayer >= FTokenControls.Count) or (FTokenControls[APlayer] = nil) then
  begin
    while APlayer >= FTokenControls.Count do
      FTokenControls.Add(nil);
    FTokenControls[APlayer] := CreateTokenControl(APlayer);
  end;
end;

procedure TTokenManager.DeletePlayer(APlayer: Integer);
begin
  if (APlayer < FTokenControls.Count) and (FTokenControls[APlayer] <> nil) then
  begin
    TObject(FTokenControls[APlayer]).Free;
    FTokenControls[APlayer] := nil;
  end;
end;

procedure TTokenManager.ClearPlayers;
begin
  while FTokenControls.Count <> 0 do
  begin
    if FTokenControls[FTokenControls.Count - 1] <> nil then
      TObject(FTokenControls[FTokenControls.Count - 1]).Free;
    FTokenControls.Delete(FTokenControls.Count - 1);
  end;
end;

{ A player is ready when nothing of his waits: no system events, no token events, and his events
  are not being executed }
function TTokenManager.PlayerReady(APlayer: Integer): Boolean;
begin
  if (APlayer < FTokenControls.Count) and (FTokenControls[APlayer] <> nil) then
  begin
    if (FTokenExecuter.FSystemEvents.Count <> 0) or
      (TTokenControl(FTokenControls[APlayer]).GetCount <> 0) or
      ((FTokenExecuter.FPrefetchTC = FTokenControls[APlayer]) and
      (tsExecuting in FTokenExecuter.FState)) then
      Result := False
    else
      Result := True;
  end
  else
    Result := False;
end;

function TTokenManager.GetTokenControl(APlayer: Integer): TTokenControl;
begin
  if APlayer < FTokenControls.Count then
    Result := TTokenControl(FTokenControls[APlayer])
  else
    Result := nil;
end;

procedure TTokenManager.TriggerMessage(const Msg: string);
begin
  if Assigned(FOnMessage) then
    FOnMessage(Self, Msg);
end;

{ TPassTokenTE }

class function TPassTokenTE.ClassID: Integer;
begin
  Result := CID_PassTokenTE;
end;

{ TSyncTE }

class function TSyncTE.ClassID: Integer;
begin
  Result := CID_SyncTE;
end;

procedure TSyncTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FSyncValue, $14);
end;

function TSyncTE.Execute(TE: TTokenExecuter): TExecuteResult;
begin
  Result := inherited Execute(TE);
  if (TE.GetSyncValue <> FSyncValue) and Assigned(TE.FOnSyncError) then
    TE.FOnSyncError(TE);
end;

procedure RegisterNetworkEngine(AEngine: TEngine);
begin
  NetworkEngineDID := AEngine.RegisterDebugID('Network Engine');
  AEngine.RegisterEClasses([TTokenPackage, TPassTokenTE, TSyncTE]);
end;

end.
