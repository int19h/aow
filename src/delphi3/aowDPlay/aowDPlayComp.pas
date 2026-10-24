unit aowDPlayComp;

{ The aowDPlayComp unit of aowDPlay.dpl: TGDPlay, the DirectPlay component behind the game's
  multiplayer (LAN/TCP, IPX, modem, serial and lobby launched games), written for the original
  compiler (Delphi 3.02) and compared function by function with the shipped module
  (tools/match.py). Declarations follow the original instance layouts (data/classes.json,
  data/rtti/aowDPlay.dpl.txt).

  How it talks to DirectPlay: TGDPlay creates the DirectPlay 4 object (CLSID_DirectPlay,
  IDirectPlay4A, in process) and the lobby object (CLSID_DirectPlayLobby, IDirectPlayLobby3A) with
  CoCreateInstance. GetConnections enumerates the service providers (EnumConnections), Connect
  initializes one (InitializeConnection, either with the provider's own connection data so that
  DirectPlay shows its setup dialogs, or with an address built by IDirectPlayLobby.CreateAddress
  from TCPPort, ModemPhoneNumber or the serial port settings). CreateSession opens a new session
  (Open with DPOPEN_CREATE), GetSessions enumerates the sessions of the provider (EnumSessions),
  JoinSession opens one of them (DPOPEN_JOIN); both create the local player (CreatePlayer).
  CheckLobby takes over a session that a lobby application started (GetConnectionSettings,
  SetConnectionSettings, Connect). Every message is sent guaranteed and asynchronously
  (SendEx, DPSEND_GUARANTEED or DPSEND_ASYNC); CheckMessages, called by the game's loop, polls
  GetMessageCount and Receive and turns the DirectPlay system messages (player created or
  destroyed, renamed, now host, session lost, send complete) and the component's own messages
  into events. CloseSession and DisConnect only set a flag; CheckMessages closes the session
  (Close) once the send queue is empty (GetMessageQueue).

  The component's own messages start with a code byte and a '0' byte (CreateMsg, when UseCodes):
  $FF chat text, $F9 game data (OnMessage), $FC ping (answered with $F8 carrying the time stamp),
  $FE eject, and a file transfer protocol: $FD offers a file (ID, size, name); the receiver
  answers $F6 to accept ($F7 and $F5 refuse), then the sender sends chunks of FilePacketSize
  bytes, either as $F4 (each one answered with $F3 and the next position) or, in burst mode, as
  $F1 back to back (progress comes from DPSYS_SENDCOMPLETE). The chunk headers carry the file ID
  and the position as a decimal string with its length in front.

  The connection, session and player lists are unit globals (Cons/ConItems, Sess/SDescs,
  Plays/SPlayers), shared by all instances and created again by every constructor.

  On modern Windows: everything depends on the DirectPlay 4 COM objects of dplayx.dll (and the
  TCP/IP service provider dpwsockx.dll), which Windows 8 and later only have when the optional
  "DirectPlay" legacy component is installed. When CoCreateInstance fails, FDPlay stays nil:
  GetConnections then returns 0 with an empty list, but Connect, CreateSession, JoinSession and
  CheckLobby call FDPlay without checking it. The IPX provider no longer exists. The TCP address
  is passed without its terminating zero (Connect), and the protocol relies on DirectPlay's
  guaranteed, asynchronous SendEx and on DPSYS_SENDCOMPLETE for burst file transfers.

  The unit was compiled with optimization off and range and overflow checks on ($O-,R+,Q+). }

{$O-,R+,Q+}

interface

uses
  Windows, SysUtils, Classes, ActiveX, MMSystem, DPlay, DPLobby;

const
  { message codes: the first byte of a message sent with UseCodes }
  gdcFileBurstData = $F1;   { file chunk, burst mode }
  gdcFileNext = $F3;        { receiver: send the chunk at this position }
  gdcFileData = $F4;        { file chunk, reply mode }
  gdcFileSkip = $F5;        { file start response: refused }
  gdcFileAccept = $F6;      { file start response: accepted (send from position 0) }
  gdcFileReject = $F7;      { file start response: refused }
  gdcPingReply = $F8;
  gdcUserMessage = $F9;
  gdcPing = $FC;
  gdcFileStart = $FD;
  gdcEject = $FE;
  gdcChat = $FF;

type
  TConnectionType = (conNone, conUnknown, conTCP, conIPX, conModem, conSerial);
  TFileStatus = (fsSend, fsRecieve);
  TFileSendMode = (fsmReply, fsmFast, fsmBurst);

  { aowDPlayComp.TGuidItem (instance size 20): +4 FGuid. Not used by the code. }
  TGuidItem = class(TObject)
  public
    FGuid: TGUID;
  end;

  { aowDPlayComp.TGDConnection (instance size 32): a service provider found by EnumConnections.
    +4 FGuid (service provider), +$14 FConnection (copy of the connection data, never freed),
    +$18 FSize, +$1C FType. }
  TGDConnection = class(TObject)
  public
    FGuid: TGUID;
    FConnection: Pointer;
    FSize: Integer;
    FType: TConnectionType;
  end;

  { aowDPlayComp.TGDSession (instance size 124): a session description. +4 FDesc, +$54 FCaps. }
  TGDSession = class(TObject)
  public
    FDesc: TDPSessionDesc2;
    FCaps: TDPCaps;
  end;

  { aowDPlayComp.TGDPlayer (instance size 52): +4 FID, +8 FCaps, +$30 FPing (round trip in ms). }
  TGDPlayer = class(TObject)
  public
    FID: DPID;
    FCaps: TDPCaps;
    FPing: Integer;
  end;

  { aowDPlayComp.TCapsItem (instance size 44): +4 FCaps. }
  TCapsItem = class(TObject)
  public
    FCaps: TDPCaps;
  end;

  { aowDPlayComp.TGDFile (instance size 24): a file being sent or received. +4 FData, +8 FSize,
    +$C FPosition, +$10 FName, +$14 FID, +$15 FStatus, +$16 FMode. }
  TGDFile = class(TObject)
  public
    FData: Pointer;
    FSize: Integer;
    FPosition: Integer;
    FName: string;
    FID: Byte;
    FStatus: TFileStatus;
    FMode: TFileSendMode;
    destructor Destroy; override;
  end;

  { aowDPlayComp.TGDMessage (instance size 16): a message to send. +4 FData, +8 FSize, +$C
    FToID. }
  TGDMessage = class(TObject)
  public
    FData: Pointer;
    FSize: Integer;
    FToID: Integer;
    destructor Destroy; override;
  end;

  { aowDPlayComp.TgdSentMsg (instance size 20): a burst mode chunk waiting for its
    DPSYS_SENDCOMPLETE. +4 FMsgID, +8 FPosition (-1: last chunk), +$C FSize, +$10 FCode. }
  TgdSentMsg = class(TObject)
  public
    FMsgID: DWORD;
    FPosition: Integer;
    FSize: Integer;
    FCode: Byte;
  end;

  TGDMessageEvent = procedure(var Data: Pointer; var Size: Integer; var ToID: Integer;
    var FromID: Integer) of object;
  TGDChatMessageEvent = procedure(var ChatMsg: string; var ToID: Integer; var FromID: Integer) of object;
  TGDPingMessageEvent = procedure(PingMS: Integer; PingPlayer: Integer) of object;
  TGDFileStartMessageEvent = procedure(ID: Integer; var Name: string; Size: Integer;
    var Response: Byte) of object;
  TGDFileProgressMessageEvent = procedure(ID: Integer; Position: Integer; Size: Integer) of object;
  TGDFileDoneMessageEvent = procedure(ID: Integer; const gdFile: TGDFile) of object;
  TGDMessageErrorEvent = procedure(ID: Integer; Result: Integer) of object;
  TGDCreatePlayerEvent = procedure(ID: Integer; NumPlayers: Integer) of object;
  TGDCreateGroupEvent = procedure(ID: Integer) of object;
  TGDDestroyPlayerEvent = procedure(ID: Integer; NumPlayers: Integer) of object;
  TGDDestroyGroupEvent = procedure(ID: Integer) of object;
  TGDNameChangeEvent = procedure(ID: Integer) of object;
  TGDSessionLostEvent = procedure of object;
  TGDNowHostingEvent = procedure of object;
  TGDDebugEvent = procedure(const DebugMsg: string) of object;

  { aowDPlayComp.TGDPlay (instance size 544). +$24 FSessionName, +$28 FPlayerName, +$2C
    FMaxPlayers, +$30..+$BF the events, +$C0 FGauranteeMsgs, +$C4 FFromID and +$C8 FToID (of the
    last message received), +$CC FBuffer and +$D0 FBufferSize (receive buffer), +$D4 FAddress
    and +$D8 FAddressSize (CreateAddress buffer), +$DC FUseCodes, +$E0 FMsgType, +$E4 FCreateMsg,
    +$114 FDestroyMsg, +$148 FNameMsg, +$164 FSendCompleteMsg (the last system messages), +$18C
    FModemPhoneNumber, +$190 FTCPPort, +$194 FUseSetupDialogs, +$198 FFiles, +$19C FSentMsgs,
    +$1A0 FFilePacketSize, +$1A4 FFileID, +$1A8 FOnDebugMessage, +$1B0 FDPlay, +$1B4 FLobby,
    +$1B8 FSessionItems, +$1BC FConnectionItems, +$1C0 FPlayerItems, +$1C4 FServiceProvider,
    +$1D4 FCaps, +$1D8 FSession, +$1DC FCurrentPlayer, +$1E0 FConnections, +$1E4 FSessions,
    +$1E8 FPlayers, +$1EC FAsyncEnum (TCP or IPX: sessions are enumerated asynchronously),
    +$1ED FConnected, +$1EE FInSession, +$1EF FIsHost, +$1F0 FCloseSession, +$1F1 FDisconnect,
    +$1F4 FPlayerID, +$1F8 FAppGUID, +$208 FComPort, +$21C FConnectionType. }
  TGDPlay = class(TComponent)
  private
    FSessionName: string;
    FPlayerName: string;
    FMaxPlayers: Integer;
    FOnMessage: TGDMessageEvent;
    FOnChatMessage: TGDChatMessageEvent;
    FOnPingMessage: TGDPingMessageEvent;
    FOnFileStartMessage: TGDFileStartMessageEvent;
    FOnFileProgressMessage: TGDFileProgressMessageEvent;
    FOnFileDoneMessage: TGDFileDoneMessageEvent;
    FOnMessageError: TGDMessageErrorEvent;
    FOnCreatePlayer: TGDCreatePlayerEvent;
    FOnCreateGroup: TGDCreateGroupEvent;
    FOnDestroyPlayer: TGDDestroyPlayerEvent;
    FOnDestroyGroup: TGDDestroyGroupEvent;
    FOnSessionLost: TGDSessionLostEvent;
    FOnNowHosting: TGDNowHostingEvent;
    FOnPlayerNameChange: TGDNameChangeEvent;
    FOnGroupNameChange: TGDNameChangeEvent;
    FOnEjected: TNotifyEvent;
    FOnSessionClosed: TNotifyEvent;
    FOnDisconnected: TNotifyEvent;
    FGauranteeMsgs: Boolean;
    FFromID: DPID;
    FToID: DPID;
    FBuffer: Pointer;
    FBufferSize: Integer;
    FAddress: Pointer;
    FAddressSize: Integer;
    FUseCodes: Boolean;
    FMsgType: DWORD;
    FCreateMsg: TDPMsgCreatePlayerOrGroup;
    FDestroyMsg: TDPMsgDestroyPlayerOrGroup;
    FNameMsg: TDPMsgSetPlayerOrGroupName;
    FSendCompleteMsg: TDPMsgSendComplete;
    FModemPhoneNumber: string;
    FTCPPort: string;
    FUseSetupDialogs: Boolean;
    FFiles: TList;
    FSentMsgs: TList;
    FFilePacketSize: Integer;
    FFileID: Byte;
    FOnDebugMessage: TGDDebugEvent;
    FDPlay: IDirectPlay4A;
    FLobby: IDirectPlayLobby3A;
    FSessionItems: TList;
    FConnectionItems: TList;
    FPlayerItems: TList;
    FServiceProvider: TGUID;
    FCaps: TCapsItem;
    FSession: TGDSession;
    FCurrentPlayer: TGDPlayer;
    FConnections: TStrings;
    FSessions: TStrings;
    FPlayers: TStrings;
  public FAsyncEnum: Boolean; private { $1EC; AoW 0042AEEA }
    FConnected: Boolean;
    FInSession: Boolean;
    FIsHost: Boolean;
    FCloseSession: Boolean;
    FDisconnect: Boolean;
    FPlayerID: DPID;
    FAppGUID: TGUID;
    FComPort: TDPComPortAddress;
    FConnectionType: TConnectionType;
    procedure SetGMsgs(Value: Boolean);
    procedure SetUseCodes(Value: Boolean);
    procedure SetPlayerName(Value: string);
  public
    { the methods in the order of the original; the public properties below are not visible in
      the module (they compile to field accesses) and are named after their fields }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CheckLobby: Boolean;
    function GetConnections: HResult;
    function CreateSession: HResult;
    procedure CloseSession;
    function GetSessions(Async: Boolean): HResult;
    function Connect(Index: Integer): HResult;
    procedure DisConnect;
    function JoinSession(Index: Integer): HResult;
    function LockSession: HResult;
    function CreatePlayer(Name: string): HResult;
    function GetPlayers(Index: Integer): HResult;
    function GetPlayerIndex(ID: Integer): Integer;
    function CreateMsg(ToID: Integer; Data: Pointer; Code: Byte; Size: Integer): TGDMessage;
    function SendMessage(ToID: Integer; Data: Pointer; Size: Integer): HResult;
    function SendChatMessage(ToID: Integer; const Text: string): HResult;
    function SendPingMessage(ToID: Integer): HResult;
    function SendFileMessage(ToID: Integer; var FileName: string; Mode: TFileSendMode): HResult;
    function SendFileDataMessage(ToID: Integer; Data: Pointer; Size: Integer; Name: string;
      Mode: TFileSendMode): HResult;
    function CheckMessages: HResult;
    function EjectPlayer(ID: Integer): HResult;
    function UpdateSessionInfo: HResult;
    function UpdatePlayerInfo(Index: Integer): HResult;
    property Connections: TStrings read FConnections;
    property Sessions: TStrings read FSessions;
    property Players: TStrings read FPlayers;
    property ConnectionItems: TList read FConnectionItems;
    property SessionItems: TList read FSessionItems;
    property PlayerItems: TList read FPlayerItems;
    property Session: TGDSession read FSession;
    property CurrentPlayer: TGDPlayer read FCurrentPlayer;
    property PlayerID: DPID read FPlayerID;
    property Connected: Boolean read FConnected;
    property InSession: Boolean read FInSession;
    property IsHost: Boolean read FIsHost;
    property ConnectionType: TConnectionType read FConnectionType;
    property ServiceProvider: TGUID read FServiceProvider;
    property AppGUID: TGUID read FAppGUID write FAppGUID;
    property ComPort: TDPComPortAddress read FComPort write FComPort;
    property DPlay: IDirectPlay4A read FDPlay;
  published
    property SessionName: string read FSessionName write FSessionName;
    property MaxPlayers: Integer read FMaxPlayers write FMaxPlayers;
    property PlayerName: string read FPlayerName write SetPlayerName;
    property OnMessage: TGDMessageEvent read FOnMessage write FOnMessage;
    property OnChatMessage: TGDChatMessageEvent read FOnChatMessage write FOnChatMessage;
    property OnPingMessage: TGDPingMessageEvent read FOnPingMessage write FOnPingMessage;
    property OnFileStartMessage: TGDFileStartMessageEvent read FOnFileStartMessage write FOnFileStartMessage;
    property OnFileProgressMessage: TGDFileProgressMessageEvent read FOnFileProgressMessage
      write FOnFileProgressMessage;
    property OnFileDoneMessage: TGDFileDoneMessageEvent read FOnFileDoneMessage write FOnFileDoneMessage;
    property OnCreatePlayer: TGDCreatePlayerEvent read FOnCreatePlayer write FOnCreatePlayer;
    property OnCreateGroup: TGDCreateGroupEvent read FOnCreateGroup write FOnCreateGroup;
    property OnDestroyPlayer: TGDDestroyPlayerEvent read FOnDestroyPlayer write FOnDestroyPlayer;
    property OnDestroyGroup: TGDDestroyGroupEvent read FOnDestroyGroup write FOnDestroyGroup;
    property OnSessionLost: TGDSessionLostEvent read FOnSessionLost write FOnSessionLost;
    property OnNowHosting: TGDNowHostingEvent read FOnNowHosting write FOnNowHosting;
    property OnMessageError: TGDMessageErrorEvent read FOnMessageError write FOnMessageError;
    property OnPlayerNameChange: TGDNameChangeEvent read FOnPlayerNameChange write FOnPlayerNameChange;
    property OnGroupNameChange: TGDNameChangeEvent read FOnGroupNameChange write FOnGroupNameChange;
    property GauranteeMsgs: Boolean read FGauranteeMsgs write SetGMsgs;
    property UseCodes: Boolean read FUseCodes write SetUseCodes;
    property OnEjected: TNotifyEvent read FOnEjected write FOnEjected;
    property OnSessionClosed: TNotifyEvent read FOnSessionClosed write FOnSessionClosed;
    property OnDisconnected: TNotifyEvent read FOnDisconnected write FOnDisconnected;
    property TCPPort: string read FTCPPort write FTCPPort;
    property ModemPhoneNumber: string read FModemPhoneNumber write FModemPhoneNumber;
    property UseSetupDialogs: Boolean read FUseSetupDialogs write FUseSetupDialogs;
    property FilePacketSize: Integer read FFilePacketSize write FFilePacketSize;
    property OnDebugMessage: TGDDebugEvent read FOnDebugMessage write FOnDebugMessage;
  end;

{ The DirectPlay enumeration callbacks (stdcall, called back from EnumConnections, EnumSessions
  and EnumPlayers): each adds a name to the string list and an item to the object list. }
function GotConnection(const lpguidSP: TGUID; lpConnection: Pointer; dwConnectionSize: DWORD;
  lpName: PDPName; dwFlags: DWORD; lpContext: Pointer): BOOL; stdcall;
function GotSession(const lpThisSD: TDPSessionDesc2; lpdwTimeOut: PDWORD; dwFlags: DWORD;
  lpContext: Pointer): BOOL; stdcall;
function GotPlayer(dpId: DPID; dwPlayerType: DWORD; lpName: PDPName; dwFlags: DWORD;
  lpContext: Pointer): BOOL; stdcall;

procedure Register;

var
  Cons: TStringList;
  Sess: TStringList;
  Plays: TStringList;
  SDescs: TList;
  ConItems: TList;
  SPlayers: TList;
  ConItem: TGDConnection;
  SDescItem: TGDSession;
  PlayerItem: TGDPlayer;

implementation

{ TGDMessage }

destructor TGDMessage.Destroy;
begin
  if FData <> nil then
    FreeMem(FData, FSize);
  inherited Destroy;
end;

{ TGDFile }

destructor TGDFile.Destroy;
begin
  if FData <> nil then
    FreeMem(FData, FSize);
  inherited Destroy;
end;

{ TGDPlay }

{ Creates the global lists and the session and caps items and initializes COM (CoInitialize):
  the DirectPlay objects themselves are created when first needed. }
constructor TGDPlay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Cons := TStringList.Create;
  Sess := TStringList.Create;
  Plays := TStringList.Create;
  ConItems := TList.Create;
  SDescs := TList.Create;
  SPlayers := TList.Create;
  FFiles := TList.Create;
  FSentMsgs := TList.Create;
  FCaps := TCapsItem.Create;
  FCaps.FCaps.dwSize := SizeOf(TDPCaps);
  FSession := TGDSession.Create;
  FMaxPlayers := 2;
  FGauranteeMsgs := True;
  FUseCodes := True;
  FUseSetupDialogs := True;
  FBufferSize := 1000;
  FAddressSize := 100;
  FFilePacketSize := 1024;
  FBuffer := AllocMem(FBufferSize);
  FAddress := AllocMem(FAddressSize);
  FAppGUID := GUID_NULL;
  CoInitialize(nil);
end;

{ Releases the DirectPlay and lobby objects (without closing the session) and COM. The list of
  sent burst messages is not freed (a leak of the original). }
destructor TGDPlay.Destroy;
var
  I: Integer;
  Con: TGDConnection;
  Player: TGDPlayer;
  Desc: TGDSession;
begin
  Cons.Free;
  Sess.Free;
  Plays.Free;
  for I := 0 to ConItems.Count - 1 do
  begin
    Con := ConItems[I];
    Con.Free;
  end;
  ConItems.Free;
  for I := 0 to SDescs.Count - 1 do
  begin
    Desc := SDescs[I];
    Desc.Free;
  end;
  SDescs.Free;
  for I := 0 to SPlayers.Count - 1 do
  begin
    Player := SPlayers[I];
    Player.Free;
  end;
  for I := 0 to FFiles.Count - 1 do
    TGDFile(FFiles[I]).Free;
  for I := 0 to FSentMsgs.Count - 1 do
    TgdSentMsg(FSentMsgs[I]).Free;
  FFiles.Free;
  SPlayers.Free;
  FCaps.Free;
  FSession.Free;
  if FBuffer <> nil then
    FreeMem(FBuffer, FBufferSize);
  if FAddress <> nil then
    FreeMem(FAddress, FAddressSize);
  FDPlay := nil;
  FLobby := nil;
  CoUninitialize;
  inherited Destroy;
end;

procedure TGDPlay.SetGMsgs(Value: Boolean);
begin
  FGauranteeMsgs := Value;
  if FGauranteeMsgs = True then
    FUseCodes := True;
end;

{ Guaranteed messages always use codes. }
procedure TGDPlay.SetUseCodes(Value: Boolean);
begin
  FUseCodes := Value;
  if FGauranteeMsgs = True then
    FUseCodes := True;
end;

{ Renames the local player; in a session also through IDirectPlay4.SetPlayerName. }
procedure TGDPlay.SetPlayerName(Value: string);
var
  P: PChar;
  Name: TDPName;
begin
  if Value <> FPlayerName then
  begin
    FPlayerName := Value;
    if FConnected and FInSession then
    begin
      Name.dwSize := SizeOf(TDPName);
      Name.dwFlags := 0;
      P := Pointer(FPlayerName);
      Name.lpszShortNameA := P;
      FDPlay.SetPlayerName(FPlayerID, @Name, 0);
    end;
  end;
end;

{ Takes over a session that a lobby application launched the game for: reads the lobby's
  connection settings (IDirectPlayLobby.GetConnectionSettings, DPERR_NOTLOBBIED when there is
  none), sets the session flags and the maximum player count, connects through the lobby
  (Connect returns an IDirectPlay2, queried for IDirectPlay4A) and creates the local player with
  the lobby's player name. Original bug: IsHost becomes True when the lobby asked to join
  (DPLCONNECTION_JOINSESSION) instead of create. }
function TGDPlay.CheckLobby: Boolean;
var
  DP2: IDirectPlay2;
  Conn: PDPLConnection;
  Size: DWORD;
  Unk: Pointer;
  hr: HResult;
begin
  Result := False;
  if FDPlay = nil then
    CoCreateInstance(CLSID_DirectPlay, nil, CLSCTX_INPROC_SERVER, IID_IDirectPlay4A, FDPlay);
  if FLobby = nil then
    CoCreateInstance(CLSID_DirectPlayLobby, nil, CLSCTX_INPROC_SERVER, IID_IDirectPlayLobby3A, FLobby);
  if FLobby <> nil then
  begin
    hr := FLobby.GetConnectionSettings(0, nil, Size);
    if hr <> DPERR_NOTLOBBIED then
    begin
      Conn := nil;
      Unk := nil;
      ReallocMem(Conn, Size);
      hr := FLobby.GetConnectionSettings(0, Conn, Size);
      if Succeeded(hr) then
      begin
        Conn^.lpSessionDesc^.dwFlags := DPSESSION_DIRECTPLAYPROTOCOL or DPSESSION_KEEPALIVE or
          DPSESSION_MIGRATEHOST;
        Conn^.lpSessionDesc^.dwMaxPlayers := FMaxPlayers;
      end;
      if Succeeded(hr) then
        hr := FLobby.SetConnectionSettings(0, 0, Conn);
      if Succeeded(hr) then
        hr := FLobby.Connect(0, DP2, Unk);
      if Succeeded(hr) then
      begin
        hr := DP2.QueryInterface(IID_IDirectPlay4A, FDPlay);
        DP2 := nil;
      end;
      if Succeeded(hr) then
      begin
        Result := True;
        FConnected := True;
        FInSession := True;
        FPlayerName := Conn^.lpPlayerName^.lpszShortNameA;
        CreatePlayer(FPlayerName);
        SPlayers.Clear;
        Plays.Clear;
        GetPlayers(0);
        FPlayerItems := SPlayers;
        FPlayers := Plays;
        FIsHost := Conn^.dwFlags = DPLCONNECTION_JOINSESSION;
      end;
      ReallocMem(Conn, 0);
    end;
  end;
end;

{ Lists the service providers (IDirectPlay4.EnumConnections with GotConnection) into Connections
  and ConnectionItems, creating the DirectPlay and lobby objects first. }
function TGDPlay.GetConnections: HResult;
var
  I: Integer;
begin
  Cons.Clear;
  for I := 0 to ConItems.Count - 1 do
    TGDConnection(ConItems[I]).Free;
  ConItems.Clear;
  if FDPlay = nil then
    CoCreateInstance(CLSID_DirectPlay, nil, CLSCTX_INPROC_SERVER, IID_IDirectPlay4A, FDPlay);
  if FLobby = nil then
    CoCreateInstance(CLSID_DirectPlayLobby, nil, CLSCTX_INPROC_SERVER, IID_IDirectPlayLobby3A, FLobby);
  if FDPlay = nil then
    Result := 0
  else
    Result := FDPlay.EnumConnections(nil, @GotConnection, nil, 0);
  FConnections := Cons;
  FConnectionItems := ConItems;
end;

{ Hosts a new session (IDirectPlay4.Open with DPOPEN_CREATE) named SessionName for MaxPlayers
  players with the DirectPlay protocol, keep-alive and host migration, then creates the local
  player. }
function TGDPlay.CreateSession: HResult;
var
  hr: HResult;
  I: Integer;
  Player: TGDPlayer;
begin
  if FConnected then
  begin
    FSession.FDesc.dwSize := SizeOf(TDPSessionDesc2);
    FSession.FDesc.dwFlags := DPSESSION_DIRECTPLAYPROTOCOL or DPSESSION_KEEPALIVE or
      DPSESSION_MIGRATEHOST;
    FSession.FDesc.dwMaxPlayers := FMaxPlayers;
    FSession.FDesc.guidApplication := FAppGUID;
    FSession.FDesc.lpszSessionNameA := Pointer(FSessionName);
    hr := FDPlay.Open(@FSession.FDesc, DPOPEN_CREATE);
    if hr = DP_OK then
    begin
      FInSession := True;
      Plays.Clear;
      for I := 0 to SPlayers.Count - 1 do
      begin
        Player := SPlayers[I];
        Player.Free;
      end;
      SPlayers.Clear;
      hr := CreatePlayer(FPlayerName);
      FIsHost := True;
    end;
    Result := hr;
  end
  else
    Result := E_FAIL;
end;

{ Asks CheckMessages to close the session once the send queue is empty. }
procedure TGDPlay.CloseSession;
begin
  if FInSession then
    FCloseSession := True;
end;

{ Lists the sessions of the connected provider (IDirectPlay4.EnumSessions with GotSession) into
  Sessions and SessionItems. On TCP and IPX the enumeration is asynchronous: Async starts it
  (DPENUMSESSIONS_ASYNC), False stops it (DPENUMSESSIONS_STOPASYNC). }
function TGDPlay.GetSessions(Async: Boolean): HResult;
var
  hr: HResult;
  I: Integer;
begin
  if FConnected then
  begin
    Sess.Clear;
    for I := 0 to SDescs.Count - 1 do
      TGDSession(SDescs[I]).Free;
    SDescs.Clear;
    FSession.FDesc.dwSize := SizeOf(TDPSessionDesc2);
    FSession.FDesc.guidApplication := FAppGUID;
    if not FAsyncEnum then
      I := 0
    else if Async then
      I := DPENUMSESSIONS_ASYNC
    else
      I := DPENUMSESSIONS_STOPASYNC;
    hr := FDPlay.EnumSessions(@FSession.FDesc, 0, @GotSession, nil, I);
    Result := hr;
    FSessions := Sess;
    FSessionItems := SDescs;
  end
  else
    Result := E_FAIL;
end;

{ Initializes the service provider Connections[Index] (IDirectPlay4.InitializeConnection). With
  UseSetupDialogs the provider's own connection data are used, so DirectPlay asks for the
  address; otherwise the address is built with IDirectPlayLobby.CreateAddress: TCP from TCPPort
  (as DPAID_INet, the host name or IP address), modem from ModemPhoneNumber (DPAID_Phone) and
  serial from ComPort (DPAID_ComPort); the address buffer grows on DPERR_BUFFERTOOSMALL. An
  already connected object is replaced by a new one first. Original bugs: the TCP address size
  leaves out the terminating zero, and the modem branch passes the address of the string
  variable instead of its characters. }
function TGDPlay.Connect(Index: Integer): HResult;
var
  Con: TGDConnection;
  Size: DWORD;
begin
  if Index < FConnections.Count then
  begin
    if FDPlay = nil then
      CoCreateInstance(CLSID_DirectPlay, nil, CLSCTX_INPROC_SERVER, IID_IDirectPlay4A, FDPlay);
    if FLobby = nil then
      CoCreateInstance(CLSID_DirectPlayLobby, nil, CLSCTX_INPROC_SERVER, IID_IDirectPlayLobby3A, FLobby);
    if FConnected then
    begin
      FDPlay := nil;
      CoCreateInstance(CLSID_DirectPlay, nil, CLSCTX_INPROC_SERVER, IID_IDirectPlay4A, FDPlay);
    end;
    Con := FConnectionItems[Index];
    if FUseSetupDialogs then
    begin
      Result := FDPlay.InitializeConnection(Con.FConnection, 0);
      FServiceProvider := Con.FGuid;
      FConnectionType := Con.FType;
    end
    else
      case Con.FType of
        conTCP:
          begin
            Size := FAddressSize;
            Result := FLobby.CreateAddress(DPSPGUID_TCPIP, DPAID_INet, Pointer(FTCPPort),
              Length(FTCPPort), FAddress, Size);
            if Result = DPERR_BUFFERTOOSMALL then
            begin
              if FAddress <> nil then
                FreeMem(FAddress, FAddressSize);
              FAddressSize := Size;
              FAddress := AllocMem(FAddressSize);
              Result := FLobby.CreateAddress(DPSPGUID_TCPIP, DPAID_INet, Pointer(FTCPPort),
                Length(FTCPPort), FAddress, Size);
            end;
            if Result = DP_OK then
            begin
              Result := FDPlay.InitializeConnection(FAddress, 0);
              FServiceProvider := Con.FGuid;
              FConnectionType := Con.FType;
            end;
          end;
        conModem:
          begin
            Size := FAddressSize;
            Result := FLobby.CreateAddress(DPSPGUID_MODEM, DPAID_Phone, @FModemPhoneNumber,
              Length(FModemPhoneNumber) + 1, FAddress, Size);
            if Result = DPERR_BUFFERTOOSMALL then
            begin
              if FAddress <> nil then
                FreeMem(FAddress, FAddressSize);
              FAddressSize := Size;
              FAddress := AllocMem(FAddressSize);
              Result := FLobby.CreateAddress(DPSPGUID_MODEM, DPAID_Phone, @FModemPhoneNumber,
                Length(FModemPhoneNumber) + 1, FAddress, Size);
            end;
            if Result = DP_OK then
            begin
              Result := FDPlay.InitializeConnection(FAddress, 0);
              FServiceProvider := Con.FGuid;
              FConnectionType := Con.FType;
            end;
          end;
        conSerial:
          begin
            Size := FAddressSize;
            Result := FLobby.CreateAddress(DPSPGUID_SERIAL, DPAID_ComPort, @FComPort,
              SizeOf(TDPComPortAddress), FAddress, Size);
            if Result = DPERR_BUFFERTOOSMALL then
            begin
              if FAddress <> nil then
                FreeMem(FAddress, FAddressSize);
              FAddressSize := Size;
              FAddress := AllocMem(FAddressSize);
              Result := FLobby.CreateAddress(DPSPGUID_SERIAL, DPAID_ComPort, @FComPort,
                SizeOf(TDPComPortAddress), FAddress, Size);
            end;
            if Result = DP_OK then
            begin
              Result := FDPlay.InitializeConnection(FAddress, 0);
              FServiceProvider := Con.FGuid;
              FConnectionType := Con.FType;
            end;
          end;
      else
        begin
          Result := FDPlay.InitializeConnection(Con.FConnection, 0);
          FServiceProvider := Con.FGuid;
          FConnectionType := Con.FType;
        end;
      end;
    if Result = DP_OK then
    begin
      if (FConnectionType = conTCP) or (FConnectionType = conIPX) then
        FAsyncEnum := True
      else
        FAsyncEnum := False;
      FConnected := True;
    end
    else
      FConnected := False;
  end
  else
    Result := E_FAIL;
end;

{ Asks CheckMessages to close the session and release DirectPlay once the send queue is empty. }
procedure TGDPlay.DisConnect;
begin
  if FConnected then
    FDisconnect := True;
end;

{ Joins Sessions[Index] (IDirectPlay4.Open with DPOPEN_JOIN), creates the local player and
  lists the players (EnumPlayers). The player lists are cleared after CreatePlayer, so the
  local player's own entry is dropped (and leaks) until EnumPlayers adds it again. }
function TGDPlay.JoinSession(Index: Integer): HResult;
var
  I: Integer;
  hr: HResult;
  Desc: TGDSession;
  Player: TGDPlayer;
begin
  if Index < FSessions.Count then
  begin
    Desc := FSessionItems[Index];
    hr := FDPlay.Open(@Desc.FDesc, DPOPEN_JOIN);
    if hr = DP_OK then
    begin
      FInSession := True;
      for I := 0 to SPlayers.Count - 1 do
      begin
        Player := SPlayers[I];
        Player.Free;
      end;
      CreatePlayer(FPlayerName);
      SPlayers.Clear;
      Plays.Clear;
      FDPlay.EnumPlayers(nil, @GotPlayer, nil, 0);
      FPlayerItems := SPlayers;
      FPlayers := Plays;
      FIsHost := False;
    end;
    Result := hr;
  end
  else
    Result := E_FAIL;
end;

{ The host closes the session to new players (DPSESSION_JOINDISABLED, SetSessionDesc). }
function TGDPlay.LockSession: HResult;
begin
  Result := DP_OK;
  if FIsHost and FConnected and FInSession then
  begin
    FSession.FDesc.dwFlags := DPSESSION_DIRECTPLAYPROTOCOL or DPSESSION_KEEPALIVE or
      DPSESSION_JOINDISABLED or DPSESSION_MIGRATEHOST;
    Result := FDPlay.SetSessionDesc(@FSession.FDesc, 0);
  end;
end;

{ Creates the local player (IDirectPlay4.CreatePlayer) and adds it to the player lists. Original
  bugs: the flags of the name are not initialized, and OnCreatePlayer is called with the ID and
  player count of the last DPSYS_CREATEPLAYERORGROUP message. }
function TGDPlay.CreatePlayer(Name: string): HResult;
var
  Player: TGDPlayer;
  P: PChar;
  DPName: TDPName;
begin
  Player := TGDPlayer.Create;
  DPName.dwSize := SizeOf(TDPName);
  P := Pointer(Name);
  DPName.lpszShortNameA := P;
  Result := FDPlay.CreatePlayer(@Player.FID, @DPName, 0, nil, 0, 0);
  if Result = DP_OK then
  begin
    FPlayerID := Player.FID;
    Plays.Add(Name);
    FPlayers := Plays;
    SPlayers.Add(TGDPlayer.Create);
    FPlayerItems := SPlayers;
    PlayerItem := SPlayers[SPlayers.Count - 1];
    PlayerItem.FID := Player.FID;
    PlayerItem.FCaps.dwSize := SizeOf(TDPCaps);
    PlayerItem := nil;
    if Assigned(FOnCreatePlayer) then
      FOnCreatePlayer(FCreateMsg.dpId, FCreateMsg.dwCurrentPlayers + 1);
  end;
  Player.Destroy;
end;

{ Lists the players (IDirectPlay4.EnumPlayers with GotPlayer): of the current session, or of
  Sessions[Index] (DPENUMPLAYERS_SESSION) when not in a session. }
function TGDPlay.GetPlayers(Index: Integer): HResult;
var
  I: Integer;
  hr: HResult;
  Desc: TGDSession;
  Player: TGDPlayer;
begin
  if FConnected = True then
  begin
    for I := 0 to SPlayers.Count - 1 do
    begin
      Player := SPlayers[I];
      Player.Free;
    end;
    SPlayers.Clear;
    Plays.Clear;
    if FInSession = True then
      hr := FDPlay.EnumPlayers(nil, @GotPlayer, nil, 0)
    else if Index < FSessions.Count then
    begin
      Desc := FSessionItems[Index];
      hr := FDPlay.EnumPlayers(@Desc.FDesc.guidInstance, @GotPlayer, nil, DPENUMPLAYERS_SESSION);
    end
    else
      hr := E_FAIL;
    FPlayerItems := SPlayers;
    FPlayers := Plays;
    Result := hr;
  end
  else
    Result := E_FAIL;
end;

{ The index of the player with DirectPlay ID ID in PlayerItems, -1 if none. }
function TGDPlay.GetPlayerIndex(ID: Integer): Integer;
var
  I: Integer;
  Player: TGDPlayer;
begin
  Result := -1;
  I := 0;
  while I < FPlayerItems.Count do
  begin
    Player := FPlayerItems[I];
    if Player.FID = ID then
    begin
      Result := I;
      I := FPlayerItems.Count;
    end;
    Inc(I);
  end;
end;

{ A message with the code byte and a '0' byte in front of Size bytes of Data (only when
  GauranteeMsgs; otherwise an empty message). }
function TGDPlay.CreateMsg(ToID: Integer; Data: Pointer; Code: Byte; Size: Integer): TGDMessage;
var
  Src: Pointer;
  P: PChar;
begin
  if FGauranteeMsgs then
  begin
    Src := Data;
    Result := TGDMessage.Create;
    Result.FToID := ToID;
    Result.FData := AllocMem(Size + 2);
    Result.FSize := Size + 2;
    P := PChar(Integer(Result.FData) + 2);
    Move(Src^, P^, Size);
    P := Result.FData;
    P^ := Chr(Code);
    P[1] := '0';
  end
  else
    Result := TGDMessage.Create;
end;

{ Sends Size bytes of game data to ToID (IDirectPlay4.SendEx, guaranteed and asynchronous);
  OnMessageError reports a failure other than DPERR_PENDING. Original bug: without UseCodes the
  message takes Data itself and frees it when it is freed. }
function TGDPlay.SendMessage(ToID: Integer; Data: Pointer; Size: Integer): HResult;
var
  Msg: TGDMessage;
  Code: Byte;
  MsgID: DWORD;
begin
  Result := E_FAIL;
  if FConnected and FInSession then
  begin
    if FUseCodes then
    begin
      Code := gdcUserMessage;
      Msg := CreateMsg(ToID, Data, Code, Size);
    end
    else
    begin
      Msg := TGDMessage.Create;
      Msg.FData := Data;
      Msg.FSize := Size;
    end;
    Result := FDPlay.SendEx(FPlayerID, ToID, DPSEND_GUARANTEED or DPSEND_ASYNC, Msg.FData, Msg.FSize,
      0, 0, nil, @MsgID);
    if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
      FOnMessageError(ToID, Result);
    Msg.Free;
  end;
end;

{ Sends a chat line (code $FF, with its terminating zero). }
function TGDPlay.SendChatMessage(ToID: Integer; const Text: string): HResult;
var
  Msg: TGDMessage;
  MsgID: DWORD;
begin
  Result := E_FAIL;
  if FConnected and FInSession then
  begin
    Msg := CreateMsg(ToID, Pointer(Text), gdcChat, Length(Text) + 1);
    Result := FDPlay.SendEx(FPlayerID, ToID, DPSEND_GUARANTEED or DPSEND_ASYNC, Msg.FData, Msg.FSize,
      0, 0, nil, @MsgID);
    if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
      FOnMessageError(ToID, Result);
    Msg.Free;
  end;
end;

{ Sends a ping (code $FC) with the current timeGetTime; the receiver sends it back as $F8. }
function TGDPlay.SendPingMessage(ToID: Integer): HResult;
var
  Msg: TGDMessage;
  P: Pointer;
  Time: PDWORD;
  MsgID: DWORD;
begin
  Result := E_FAIL;
  if FConnected and FInSession then
  begin
    P := AllocMem(6);
    Time := P;
    Time^ := timeGetTime;
    Msg := CreateMsg(ToID, P, gdcPing, 6);
    FreeMem(P);
    Result := FDPlay.SendEx(FPlayerID, ToID, DPSEND_GUARANTEED or DPSEND_ASYNC, Msg.FData, Msg.FSize,
      0, 0, nil, @MsgID);
    if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
      FOnMessageError(ToID, Result);
    Msg.Free;
  end;
end;

{ Offers the file FileName to ToID (code $FD: file ID, size, name); the transfer continues in
  CheckMessages when the receiver accepts. Original bug: BlockRead reads the file over the TGDFile
  object (into the FData field) instead of into the allocated buffer. }
function TGDPlay.SendFileMessage(ToID: Integer; var FileName: string; Mode: TFileSendMode): HResult;
var
  Msg: TGDMessage;
  GDFile: TGDFile;
  S: string;
  MsgID: DWORD;
  F: file;
begin
  Result := E_FAIL;
  if FConnected and FInSession and FileExists(FileName) then
  begin
    FFileID := FFileID mod 250 + 1;
    GDFile := TGDFile.Create;
    FFiles.Add(GDFile);
    AssignFile(F, FileName);
    Reset(F, 1);
    GDFile.FSize := FileSize(F);
    GDFile.FName := ExtractFileName(FileName);
    GDFile.FID := FFileID;
    GDFile.FData := AllocMem(GDFile.FSize);
    BlockRead(F, GDFile.FData, GDFile.FSize);
    GDFile.FStatus := fsSend;
    GDFile.FMode := Mode;
    CloseFile(F);
    S := Chr(GDFile.FID) + Chr(Length(IntToStr(GDFile.FSize))) + IntToStr(GDFile.FSize) + GDFile.FName;
    Msg := CreateMsg(ToID, Pointer(S), gdcFileStart, Length(S) + 1);
    Result := FDPlay.SendEx(FPlayerID, ToID, DPSEND_GUARANTEED or DPSEND_ASYNC, Msg.FData, Msg.FSize,
      0, 0, nil, @MsgID);
    if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
      FOnMessageError(ToID, Result);
    Msg.Free;
  end;
end;

{ Like SendFileMessage for a block of memory: offers Size bytes of Data under the name Name. }
function TGDPlay.SendFileDataMessage(ToID: Integer; Data: Pointer; Size: Integer; Name: string;
  Mode: TFileSendMode): HResult;
var
  GDFile: TGDFile;
  Msg: TGDMessage;
  S: string;
  MsgID: DWORD;
  Src: Pointer;
  Dst: Pointer;
begin
  Result := E_FAIL;
  if FConnected and FInSession then
  begin
    FFileID := FFileID mod 250 + 1;
    GDFile := TGDFile.Create;
    FFiles.Add(GDFile);
    GDFile.FSize := Size;
    GDFile.FID := FFileID;
    GDFile.FData := AllocMem(GDFile.FSize);
    GDFile.FName := Name;
    Src := Data;
    Dst := GDFile.FData;
    Move(Src^, Dst^, Size);
    GDFile.FStatus := fsSend;
    GDFile.FMode := Mode;
    S := Chr(GDFile.FID) + Chr(Length(IntToStr(GDFile.FSize))) + IntToStr(GDFile.FSize) + GDFile.FName;
    Msg := CreateMsg(ToID, Pointer(S), gdcFileStart, Length(S) + 1);
    Result := FDPlay.SendEx(FPlayerID, ToID, DPSEND_GUARANTEED or DPSEND_ASYNC, Msg.FData, Msg.FSize,
      0, 0, nil, @MsgID);
    if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
      FOnMessageError(ToID, Result);
    Msg.Free;
  end;
end;

{ The message pump, called by the game's loop: receives every queued message
  (IDirectPlay4.GetMessageCount, Receive with DPRECEIVE_ALL; the receive buffer grows on
  DPERR_BUFFERTOOSMALL) and dispatches it. System messages (from DPID_SYSMSG) update the player
  lists and fire the player, host and session events; the component's own messages (see the unit
  header) are handled here, game data go to OnMessage. Then a pending CloseSession or DisConnect
  is carried out once the send queue is empty (GetMessageQueue, Close; DisConnect also releases
  the DirectPlay and lobby objects). Original bugs: OnMessage gets the size including the two
  code bytes, OnPingMessage gets the sender's time stamp instead of the round trip time, and the
  file accept answer carries the position '0' behind a length byte of '1' (49). }
function TGDPlay.CheckMessages: HResult;
var
  I: Integer;
  J: Integer;
  K: Integer;
  Count: DWORD;
  Flags: DWORD;
  PlayerIndex: Integer;
  P: PChar;
  Data: PChar;
  PName: PChar;
  Player: TGDPlayer;
  GDFile: TGDFile;
  Size: Integer;
  S1: string;
  S2: string;
  S3: string;
  Msg: TGDMessage;
  PingTime: DWORD;
  Len: Integer;
  Position: Integer;
  Response: Byte;
  FileID: Byte;
  Buf: Pointer;
  Src: Pointer;
  Dst: Pointer;
  MsgID: DWORD;
  NumBytes: DWORD;
  More: Boolean;
  SentMsg: TgdSentMsg;
begin
  if not FConnected then
    Result := DP_OK
  else
  begin
    Result := E_FAIL;
    if FDPlay <> nil then
      Result := FDPlay.GetMessageCount(FPlayerID, Count);
    if Result = DP_OK then
    begin
      Flags := DPRECEIVE_ALL;
      for I := 0 to Count - 1 do
      begin
        Size := FBufferSize;
        Result := FDPlay.Receive(FFromID, FToID, Flags, FBuffer, Size);
        while Result = DPERR_BUFFERTOOSMALL do
        begin
          if FBuffer <> nil then
            FreeMem(FBuffer, FBufferSize);
          FBufferSize := Size;
          FBuffer := AllocMem(FBufferSize);
          Result := FDPlay.Receive(FFromID, FToID, Flags, FBuffer, Size);
        end;
        if (Result = DP_OK) and (FBuffer <> nil) then
          if FFromID = DPID_SYSMSG then
          begin
            Move(FBuffer^, FMsgType, 4);
            case FMsgType of
              DPSYS_CREATEPLAYERORGROUP:
                begin
                  Move(FBuffer^, FCreateMsg, SizeOf(FCreateMsg));
                  if FCreateMsg.dwPlayerType = DPPLAYERTYPE_PLAYER then
                  begin
                    P := FCreateMsg.dpnName.lpszShortNameA;
                    Plays.Add(P);
                    FPlayers := Plays;
                    SPlayers.Add(TGDPlayer.Create);
                    FPlayerItems := SPlayers;
                    PlayerItem := SPlayers[SPlayers.Count - 1];
                    PlayerItem.FID := FCreateMsg.dpId;
                    PlayerItem.FCaps.dwSize := SizeOf(TDPCaps);
                    PlayerItem := nil;
                    if Assigned(FOnCreatePlayer) then
                      FOnCreatePlayer(FCreateMsg.dpId, FCreateMsg.dwCurrentPlayers + 1);
                  end
                  else if Assigned(FOnCreateGroup) then
                    FOnCreateGroup(FCreateMsg.dpId);
                end;
              DPSYS_DESTROYPLAYERORGROUP:
                begin
                  Move(FBuffer^, FDestroyMsg, SizeOf(FDestroyMsg));
                  if FDestroyMsg.dwPlayerType = DPPLAYERTYPE_PLAYER then
                  begin
                    J := 0;
                    while J < FPlayerItems.Count do
                    begin
                      Player := FPlayerItems[J];
                      if Player.FID = FDestroyMsg.dpId then
                      begin
                        Player.Free;
                        FPlayerItems.Delete(J);
                        FPlayers.Delete(J);
                        J := FPlayerItems.Count;
                      end;
                      Inc(J);
                    end;
                    if Assigned(FOnDestroyPlayer) then
                      FOnDestroyPlayer(FDestroyMsg.dpId, FPlayerItems.Count);
                  end
                  else if Assigned(FOnDestroyGroup) then
                    FOnDestroyGroup(FDestroyMsg.dpId);
                end;
              DPSYS_HOST:
                begin
                  FIsHost := True;
                  if Assigned(FOnNowHosting) then
                    FOnNowHosting;
                end;
              DPSYS_SESSIONLOST:
                begin
                  FConnected := False;
                  FInSession := False;
                  if Assigned(FOnSessionLost) then
                    FOnSessionLost;
                end;
              DPSYS_SETPLAYERORGROUPNAME:
                begin
                  Move(FBuffer^, FNameMsg, SizeOf(FNameMsg));
                  if FNameMsg.dwPlayerType = DPPLAYERTYPE_PLAYER then
                  begin
                    J := 0;
                    while J < FPlayerItems.Count do
                    begin
                      Player := FPlayerItems[J];
                      if Player.FID = FNameMsg.dpId then
                      begin
                        PName := FNameMsg.dpnName.lpszShortNameA;
                        FPlayers[J] := PName;
                      end;
                      Inc(J);
                    end;
                    if Assigned(FOnPlayerNameChange) then
                      FOnPlayerNameChange(FNameMsg.dpId);
                  end
                  else if Assigned(FOnGroupNameChange) then
                    FOnGroupNameChange(FNameMsg.dpId);
                end;
              DPSYS_SENDCOMPLETE:
                begin
                  Move(FBuffer^, FSendCompleteMsg, SizeOf(FSendCompleteMsg));
                  if FSendCompleteMsg.hr = DP_OK then
                  begin
                    J := 0;
                    while J < FSentMsgs.Count do
                    begin
                      SentMsg := FSentMsgs[J];
                      if SentMsg.FMsgID = FSendCompleteMsg.dwMsgID then
                      begin
                        if SentMsg.FPosition = -1 then
                        begin
                          if Assigned(FOnFileDoneMessage) then
                            FOnFileDoneMessage(FSendCompleteMsg.idTo, nil);
                        end
                        else if Assigned(FOnFileProgressMessage) then
                          FOnFileProgressMessage(FSendCompleteMsg.idTo, SentMsg.FPosition, SentMsg.FSize);
                        SentMsg.Free;
                        FSentMsgs.Delete(J);
                        J := FSentMsgs.Count;
                      end;
                      Inc(J);
                    end;
                  end
                  else if Assigned(FOnMessageError) then
                    FOnMessageError(FSendCompleteMsg.idTo, FSendCompleteMsg.hr);
                end;
            end;
          end
          else
          begin
            PlayerIndex := GetPlayerIndex(FFromID);
            if PlayerIndex > -1 then
              if FUseCodes then
              begin
                P := FBuffer;
                Data := PChar(Integer(P) + 2);
                case Byte(P^) of
                  gdcEject:
                    begin
                      CloseSession;
                      if Assigned(FOnEjected) then
                        FOnEjected(Self);
                    end;
                  gdcChat:
                    begin
                      S1 := Data;
                      if Assigned(FOnChatMessage) then
                        FOnChatMessage(S1, Integer(FToID), Integer(FFromID));
                    end;
                  gdcPing:
                    begin
                      P^ := Chr(gdcPingReply);
                      Result := FDPlay.SendEx(FPlayerID, FFromID, DPSEND_GUARANTEED or DPSEND_ASYNC,
                        P, 8, 0, 0, nil, @MsgID);
                      if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
                        FOnMessageError(FFromID, Result);
                    end;
                  gdcPingReply:
                    begin
                      PingTime := PDWORD(P + 2)^;
                      TGDPlayer(FPlayerItems[PlayerIndex]).FPing := timeGetTime - PingTime;
                      if Assigned(FOnPingMessage) then
                        FOnPingMessage(PingTime, FFromID);
                    end;
                  gdcFileStart:
                    begin
                      S1 := Copy(P, 5, Ord(P[3]));
                      FileID := Ord(P[2]);
                      Len := StrToInt(S1);
                      S3 := Copy(P, Ord(P[3]) + 5, Size - 4 - Ord(P[3]));
                      Response := gdcFileAccept;
                      if Assigned(FOnFileStartMessage) then
                        FOnFileStartMessage(FFromID, S3, Len, Response);
                      if (Response <> gdcFileReject) and (Response <> gdcFileSkip) then
                      begin
                        S2 := P[2] + '10';
                        GDFile := TGDFile.Create;
                        FFiles.Add(GDFile);
                        GDFile.FID := FileID;
                        GDFile.FName := S3;
                        GDFile.FSize := Len;
                        GDFile.FData := AllocMem(GDFile.FSize);
                        GDFile.FStatus := fsRecieve;
                        Msg := CreateMsg(FFromID, Pointer(S2), gdcFileAccept, Length(S2) + 1);
                        Result := FDPlay.SendEx(FPlayerID, FFromID, DPSEND_GUARANTEED or DPSEND_ASYNC,
                          Msg.FData, Msg.FSize, 0, 0, nil, @MsgID);
                        if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
                          FOnMessageError(FFromID, Result);
                        Msg.Free;
                      end;
                    end;
                  gdcFileNext, gdcFileAccept:
                    begin
                      S1 := Copy(P, 5, Ord(P[3]));
                      FileID := Ord(P[2]);
                      Position := StrToInt(S1);
                      GDFile := nil;
                      for K := 0 to FFiles.Count - 1 do
                        if (TGDFile(FFiles[K]).FID = FileID) and (TGDFile(FFiles[K]).FStatus = fsSend) then
                          GDFile := FFiles[K];
                      if GDFile <> nil then
                      begin
                        GDFile.FPosition := Position;
                        if GDFile.FPosition + FFilePacketSize > GDFile.FSize then
                          Len := GDFile.FSize - GDFile.FPosition
                        else
                          Len := FFilePacketSize;
                        if Len <= 0 then
                        begin
                          if Assigned(FOnFileDoneMessage) then
                            FOnFileDoneMessage(FFromID, GDFile);
                          FFiles.Delete(FFiles.IndexOf(GDFile));
                          GDFile.Free;
                        end
                        else
                        begin
                          More := True;
                          while More do
                          begin
                            J := Length(IntToStr(GDFile.FPosition)) + 2;
                            Buf := AllocMem(J + Len);
                            S2 := Chr(GDFile.FID) + Chr(Length(IntToStr(GDFile.FPosition))) +
                              IntToStr(GDFile.FPosition);
                            Src := Pointer(S2);
                            Move(Src^, Buf^, J);
                            Src := Pointer(Integer(GDFile.FData) + GDFile.FPosition);
                            Dst := Pointer(Integer(Buf) + J);
                            Move(Src^, Dst^, Len);
                            case GDFile.FMode of
                              fsmBurst: Msg := CreateMsg(FFromID, Buf, gdcFileBurstData, J + Len);
                            else
                              Msg := CreateMsg(FFromID, Buf, gdcFileData, J + Len);
                            end;
                            Result := FDPlay.SendEx(FPlayerID, FFromID, DPSEND_GUARANTEED or DPSEND_ASYNC,
                              Msg.FData, Msg.FSize, 0, 0, nil, @MsgID);
                            if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
                              FOnMessageError(FFromID, Result);
                            FreeMem(Buf, J + Len);
                            Msg.Free;
                            case GDFile.FMode of
                              fsmBurst:
                                begin
                                  SentMsg := TgdSentMsg.Create;
                                  FSentMsgs.Add(SentMsg);
                                  SentMsg.FMsgID := MsgID;
                                  SentMsg.FCode := gdcFileBurstData;
                                  Inc(GDFile.FPosition, Len);
                                  if GDFile.FPosition >= GDFile.FSize then
                                  begin
                                    More := False;
                                    SentMsg.FPosition := -1;
                                    FFiles.Delete(FFiles.IndexOf(GDFile));
                                    GDFile.Free;
                                  end
                                  else
                                  begin
                                    SentMsg.FPosition := GDFile.FPosition;
                                    SentMsg.FSize := GDFile.FSize;
                                    if GDFile.FPosition + FFilePacketSize > GDFile.FSize then
                                      Len := GDFile.FSize - GDFile.FPosition
                                    else
                                      Len := FFilePacketSize;
                                  end;
                                end;
                            else
                              begin
                                More := False;
                                if Assigned(FOnFileProgressMessage) then
                                  FOnFileProgressMessage(FFromID, GDFile.FPosition, GDFile.FSize);
                              end;
                            end;
                          end;
                        end;
                      end;
                    end;
                  gdcFileBurstData, gdcFileData:
                    begin
                      S1 := Copy(P, 5, Ord(P[3]));
                      FileID := Ord(P[2]);
                      Position := StrToInt(S1);
                      Len := Size - 4 - Ord(P[3]);
                      GDFile := nil;
                      for K := 0 to FFiles.Count - 1 do
                        if (TGDFile(FFiles[K]).FID = FileID) and (TGDFile(FFiles[K]).FStatus = fsRecieve) then
                          GDFile := FFiles[K];
                      if GDFile <> nil then
                      begin
                        if GDFile.FPosition + Len > GDFile.FSize then
                          Len := GDFile.FSize - GDFile.FPosition;
                        if GDFile.FPosition <> Position then
                          Len := 0;
                        if Len > 0 then
                        begin
                          Buf := Pointer(Integer(FBuffer) + 4 + Ord(P[3]));
                          Src := Pointer(Integer(GDFile.FData) + GDFile.FPosition);
                          Move(Buf^, Src^, Len);
                          Inc(GDFile.FPosition, Len);
                          if Assigned(FOnFileProgressMessage) then
                            FOnFileProgressMessage(FFromID, GDFile.FPosition, GDFile.FSize);
                          if (GDFile <> nil) and (GDFile.FPosition = GDFile.FSize) then
                          begin
                            if Assigned(FOnFileDoneMessage) then
                              FOnFileDoneMessage(FFromID, GDFile);
                            FFiles.Delete(FFiles.IndexOf(GDFile));
                            GDFile.Free;
                            GDFile := nil;
                          end;
                        end;
                      end;
                      if P^ = Chr(gdcFileData) then
                      begin
                        if GDFile = nil then
                          S2 := Chr(FileID) + Chr(Length(IntToStr(Position + Len))) +
                            IntToStr(Position + Len)
                        else
                          S2 := Chr(GDFile.FID) + Chr(Length(IntToStr(GDFile.FPosition))) +
                            IntToStr(GDFile.FPosition);
                        Msg := CreateMsg(FFromID, Pointer(S2), gdcFileNext, Length(S2) + 1);
                        Result := FDPlay.SendEx(FPlayerID, FFromID, DPSEND_GUARANTEED or DPSEND_ASYNC,
                          Msg.FData, Msg.FSize, 0, 0, nil, @MsgID);
                        if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
                          FOnMessageError(FFromID, Result);
                        Msg.Free;
                      end;
                    end;
                  gdcFileReject: ;
                else
                  begin
                    Buf := Data;
                    if Assigned(FOnMessage) then
                      FOnMessage(Buf, Size, Integer(FToID), Integer(FFromID));
                  end;
                end;
              end
              else if Assigned(FOnMessage) then
                FOnMessage(FBuffer, Size, Integer(FToID), Integer(FFromID));
          end;
      end;
      if FCloseSession or FDisconnect then
      begin
        Result := FDPlay.GetMessageQueue(0, 0, DPMESSAGEQUEUE_SEND, @MsgID, @NumBytes);
        if (Result = DP_OK) and (MsgID = 0) then
        begin
          Result := FDPlay.Close;
          if Result = DP_OK then
          begin
            FCloseSession := False;
            FInSession := False;
            if Assigned(FOnSessionClosed) then
              FOnSessionClosed(Self);
          end;
          if (Result = DP_OK) and FDisconnect and (MsgID = 0) then
          begin
            FInSession := False;
            FConnected := False;
            FDisconnect := False;
            FConnectionType := conNone;
            FDPlay := nil;
            FLobby := nil;
            if Assigned(FOnDisconnected) then
              FOnDisconnected(Self);
          end;
        end;
      end;
    end;
  end;
end;

{ Sends the eject code ($FE) to player ID, whose CheckMessages then closes its session. }
function TGDPlay.EjectPlayer(ID: Integer): HResult;
var
  Code: Byte;
  MsgID: DWORD;
begin
  Result := E_FAIL;
  if (FInSession = True) and FUseCodes then
  begin
    Code := gdcEject;
    Result := FDPlay.SendEx(FPlayerID, ID, DPSEND_GUARANTEED or DPSEND_ASYNC, @Code, 1, 0, 0, nil,
      @MsgID);
    if (Result <> DP_OK) and (Result <> DPERR_PENDING) and Assigned(FOnMessageError) then
      FOnMessageError(ID, Result);
  end;
end;

{ Reads the session's capabilities into Session.FCaps (IDirectPlay4.GetCaps). }
function TGDPlay.UpdateSessionInfo: HResult;
begin
  Result := E_FAIL;
  if FInSession then
  begin
    FSession.FCaps.dwSize := SizeOf(TDPCaps);
    Result := FDPlay.GetCaps(@FSession.FCaps, 0);
  end;
end;

{ Makes PlayerItems[Index] the current player and reads its capabilities (GetPlayerCaps). }
function TGDPlay.UpdatePlayerInfo(Index: Integer): HResult;
begin
  Result := E_FAIL;
  if FInSession then
  begin
    FCurrentPlayer := FPlayerItems[Index];
    Result := FDPlay.GetPlayerCaps(FCurrentPlayer.FID, @FCurrentPlayer.FCaps, 0);
  end;
end;

{ EnumConnections callback: keeps a copy of the connection data and classifies the service
  provider. }
function GotConnection(const lpguidSP: TGUID; lpConnection: Pointer; dwConnectionSize: DWORD;
  lpName: PDPName; dwFlags: DWORD; lpContext: Pointer): BOOL; stdcall;
var
  Data: Pointer;
begin
  if @lpguidSP = nil then
    Result := False
  else
  begin
    Cons.Add(lpName^.lpszShortNameA);
    Data := AllocMem(dwConnectionSize);
    Move(lpConnection^, Data^, dwConnectionSize);
    ConItems.Add(TGDConnection.Create);
    ConItem := ConItems[ConItems.Count - 1];
    ConItem.FGuid := lpguidSP;
    ConItem.FConnection := Data;
    ConItem.FSize := dwConnectionSize;
    if CompareMem(@ConItem.FGuid, @DPSPGUID_TCPIP, 16) then
      ConItem.FType := conTCP
    else if CompareMem(@ConItem.FGuid, @DPSPGUID_IPX, 16) then
      ConItem.FType := conIPX
    else if CompareMem(@ConItem.FGuid, @DPSPGUID_MODEM, 16) then
      ConItem.FType := conModem
    else if CompareMem(@ConItem.FGuid, @DPSPGUID_SERIAL, 16) then
      ConItem.FType := conSerial;
    ConItem := nil;
    Result := True;
  end;
end;

{ EnumSessions callback (lpThisSD is nil when an enumeration timed out). The copied description
  keeps the pointer to the session name, which is only valid during the callback. }
function GotSession(const lpThisSD: TDPSessionDesc2; lpdwTimeOut: PDWORD; dwFlags: DWORD;
  lpContext: Pointer): BOOL; stdcall;
begin
  if @lpThisSD = nil then
    Result := False
  else
  begin
    Sess.Add(lpThisSD.lpszSessionNameA);
    SDescs.Add(TGDSession.Create);
    SDescItem := SDescs[SDescs.Count - 1];
    SDescItem.FDesc := lpThisSD;
    SDescItem := nil;
    Result := True;
  end;
end;

{ EnumPlayers callback. }
function GotPlayer(dpId: DPID; dwPlayerType: DWORD; lpName: PDPName; dwFlags: DWORD;
  lpContext: Pointer): BOOL; stdcall;
var
  P: PChar;
begin
  P := lpName^.lpszShortNameA;
  Plays.Add(P);
  SPlayers.Add(TGDPlayer.Create);
  PlayerItem := SPlayers[SPlayers.Count - 1];
  PlayerItem.FID := dpId;
  PlayerItem.FCaps.dwSize := SizeOf(TDPCaps);
  PlayerItem := nil;
  Result := True;
end;

procedure Register;
begin
  RegisterComponents('GT DirectX', [TGDPlay]);
end;

end.
