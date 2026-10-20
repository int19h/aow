unit DPlay;

{ The DPlay unit of aowDPlay.dpl: the DirectPlay declarations (dplay.h of DirectX 6) that the
  aowDPlayComp unit uses, written for the original compiler (Delphi 3.02). The unit has no code of
  its own (only the unit init/fini pair); its exported data are the GUID typed constants below
  and the type info of the interfaces. Only IDirectPlay3A and IDirectPlay4A carry a GUID in the
  original type info. Every method of IDirectPlay4A is declared because the component calls it
  through its vtable slot; the ANSI string fields of the structures are declared as PChar. }

interface

uses
  Windows;

type
  DPID = DWORD;
  PDPID = ^DPID;

const
  DP_OK = 0;
  DPERR_BUFFERTOOSMALL = HResult($8877001E);
  DPERR_PENDING = HResult($8000000A);

  DPID_SYSMSG = 0;
  DPID_ALLPLAYERS = 0;

  DPOPEN_JOIN = $00000001;
  DPOPEN_CREATE = $00000002;

  DPSEND_GUARANTEED = $00000001;
  DPSEND_ASYNC = $00000200;

  DPRECEIVE_ALL = $00000001;

  DPENUMSESSIONS_AVAILABLE = $00000001;
  DPENUMSESSIONS_ALL = $00000002;
  DPENUMSESSIONS_ASYNC = $00000010;
  DPENUMSESSIONS_STOPASYNC = $00000020;

  DPENUMPLAYERS_SESSION = $00000080;

  DPPLAYERTYPE_GROUP = $00000000;
  DPPLAYERTYPE_PLAYER = $00000001;

  DPSESSION_MIGRATEHOST = $00000004;
  DPSESSION_JOINDISABLED = $00000020;
  DPSESSION_KEEPALIVE = $00000040;
  DPSESSION_DIRECTPLAYPROTOCOL = $00002000;

  DPMESSAGEQUEUE_SEND = $00000001;

  { system message types (DPMSG_GENERIC.dwType) }
  DPSYS_CREATEPLAYERORGROUP = $0003;
  DPSYS_DESTROYPLAYERORGROUP = $0005;
  DPSYS_SESSIONLOST = $0031;
  DPSYS_HOST = $0101;
  DPSYS_SETPLAYERORGROUPNAME = $0103;
  DPSYS_SENDCOMPLETE = $010D;

  IID_IDirectPlay: TGUID = (D1: $5454E9A0; D2: $DB65; D3: $11CE; D4: ($92, $1C, $00, $AA, $00, $6C, $49, $72));
  IID_IDirectPlay2: TGUID = (D1: $2B74F7C0; D2: $9154; D3: $11CF; D4: ($A9, $CD, $00, $AA, $00, $68, $86, $E3));
  IID_IDirectPlay2A: TGUID = (D1: $9D460580; D2: $A822; D3: $11CF; D4: ($96, $0C, $00, $80, $C7, $53, $4E, $82));
  IID_IDirectPlay3: TGUID = (D1: $133EFE40; D2: $32DC; D3: $11D0; D4: ($9C, $FB, $00, $A0, $C9, $0A, $43, $CB));
  IID_IDirectPlay3A: TGUID = (D1: $133EFE41; D2: $32DC; D3: $11D0; D4: ($9C, $FB, $00, $A0, $C9, $0A, $43, $CB));
  IID_IDirectPlay4: TGUID = (D1: $0AB1C530; D2: $4745; D3: $11D1; D4: ($A7, $A1, $00, $00, $F8, $03, $AB, $FC));
  IID_IDirectPlay4A: TGUID = (D1: $0AB1C531; D2: $4745; D3: $11D1; D4: ($A7, $A1, $00, $00, $F8, $03, $AB, $FC));
  CLSID_DirectPlay: TGUID = (D1: $D1EB6D20; D2: $8923; D3: $11D0; D4: ($9D, $97, $00, $A0, $C9, $0A, $43, $CB));
  { service providers }
  DPSPGUID_IPX: TGUID = (D1: $685BC400; D2: $9D2C; D3: $11CF; D4: ($A9, $CD, $00, $AA, $00, $68, $86, $E3));
  DPSPGUID_TCPIP: TGUID = (D1: $36E95EE0; D2: $8577; D3: $11CF; D4: ($96, $0C, $00, $80, $C7, $53, $4E, $82));
  DPSPGUID_SERIAL: TGUID = (D1: $0F1D6860; D2: $88D9; D3: $11CF; D4: ($9C, $4E, $00, $A0, $C9, $05, $42, $5E));
  DPSPGUID_MODEM: TGUID = (D1: $44EAA760; D2: $CB68; D3: $11CF; D4: ($9C, $4E, $00, $A0, $C9, $05, $42, $5E));

type
  { DPNAME (16 bytes) }
  PDPName = ^TDPName;
  TDPName = record
    dwSize: DWORD;
    dwFlags: DWORD;
    lpszShortNameA: PChar;
    lpszLongNameA: PChar;
  end;

  { DPSESSIONDESC2 (80 bytes) }
  PDPSessionDesc2 = ^TDPSessionDesc2;
  TDPSessionDesc2 = record
    dwSize: DWORD;
    dwFlags: DWORD;
    guidInstance: TGUID;
    guidApplication: TGUID;
    dwMaxPlayers: DWORD;
    dwCurrentPlayers: DWORD;
    lpszSessionNameA: PChar;
    lpszPasswordA: PChar;
    dwReserved1: DWORD;
    dwReserved2: DWORD;
    dwUser1: DWORD;
    dwUser2: DWORD;
    dwUser3: DWORD;
    dwUser4: DWORD;
  end;

  { DPCAPS (40 bytes) }
  PDPCaps = ^TDPCaps;
  TDPCaps = record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwMaxBufferSize: DWORD;
    dwMaxQueueSize: DWORD;
    dwMaxPlayers: DWORD;
    dwHundredBaud: DWORD;
    dwLatency: DWORD;
    dwMaxLocalPlayers: DWORD;
    dwHeaderLength: DWORD;
    dwTimeout: DWORD;
  end;

  { DPMSG_CREATEPLAYERORGROUP (48 bytes) }
  TDPMsgCreatePlayerOrGroup = record
    dwType: DWORD;
    dwPlayerType: DWORD;
    dpId: DPID;
    dwCurrentPlayers: DWORD;
    lpData: Pointer;
    dwDataSize: DWORD;
    dpnName: TDPName;
    dpIdParent: DPID;
    dwFlags: DWORD;
  end;

  { DPMSG_DESTROYPLAYERORGROUP (52 bytes) }
  TDPMsgDestroyPlayerOrGroup = record
    dwType: DWORD;
    dwPlayerType: DWORD;
    dpId: DPID;
    lpLocalData: Pointer;
    dwLocalDataSize: DWORD;
    lpRemoteData: Pointer;
    dwRemoteDataSize: DWORD;
    dpnName: TDPName;
    dpIdParent: DPID;
    dwFlags: DWORD;
  end;

  { DPMSG_SETPLAYERORGROUPNAME (28 bytes) }
  TDPMsgSetPlayerOrGroupName = record
    dwType: DWORD;
    dwPlayerType: DWORD;
    dpId: DPID;
    dpnName: TDPName;
  end;

  { DPMSG_SENDCOMPLETE (40 bytes) }
  TDPMsgSendComplete = record
    dwType: DWORD;
    idFrom: DPID;
    idTo: DPID;
    dwFlags: DWORD;
    dwPriority: DWORD;
    dwTimeout: DWORD;
    lpvContext: Pointer;
    dwMsgID: DWORD;
    hr: HResult;
    dwSendTime: DWORD;
  end;

  { the DirectX 3 interface (not used by the component) }
  IDirectPlay = interface(IUnknown)
    function AddPlayerToGroup(pidGroup, pidPlayer: DPID): HResult; stdcall;
    function Close: HResult; stdcall;
    function CreatePlayer(lppidID: PDPID; lpPlayerFriendlyName, lpPlayerFormalName: PChar;
      lpEvent: PHandle): HResult; stdcall;
    function CreateGroup(lppidID: PDPID; lpGroupFriendlyName, lpGroupFormalName: PChar): HResult; stdcall;
    function DeletePlayerFromGroup(pidGroup, pidPlayer: DPID): HResult; stdcall;
    function DestroyPlayer(pidID: DPID): HResult; stdcall;
    function DestroyGroup(pidID: DPID): HResult; stdcall;
    function EnableNewPlayers(bEnable: BOOL): HResult; stdcall;
    function EnumGroupPlayers(pidGroupPID: DPID; lpEnumPlayersCallback: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumGroups(dwSessionID: DWORD; lpEnumPlayersCallback: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumPlayers(dwSessionID: DWORD; lpEnumPlayersCallback: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumSessions(lpSDesc: Pointer; dwTimeout: DWORD; lpEnumSessionsCallback: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function GetCaps(lpDPCaps: PDPCaps): HResult; stdcall;
    function GetMessageCount(pidID: DPID; var lpdwCount: DWORD): HResult; stdcall;
    function GetPlayerCaps(pidID: DPID; lpDPPlayerCaps: PDPCaps): HResult; stdcall;
    function GetPlayerName(pidID: DPID; lpPlayerFriendlyName: PChar; var lpdwFriendlyNameLength: DWORD;
      lpPlayerFormalName: PChar; var lpdwFormalNameLength: DWORD): HResult; stdcall;
    function Initialize(lpGUID: PGUID): HResult; stdcall;
    function Open(lpSDesc: Pointer): HResult; stdcall;
    function Receive(var lppidFrom, lppidTo: DPID; dwFlags: DWORD; lpvBuffer: Pointer;
      var lpdwSize: DWORD): HResult; stdcall;
    function SaveSession(lpSessionName: PChar): HResult; stdcall;
    function Send(pidFrom, pidTo: DPID; dwFlags: DWORD; lpvBuffer: Pointer; dwBuffSize: DWORD): HResult; stdcall;
    function SetPlayerName(pidPlayer: DPID; lpPlayerFriendlyName, lpPlayerFormalName: PChar): HResult; stdcall;
  end;

  { the DirectX 5 interface: IDirectPlayLobby.Connect returns it }
  IDirectPlay2 = interface(IUnknown)
    function AddPlayerToGroup(idGroup, idPlayer: DPID): HResult; stdcall;
    function Close: HResult; stdcall;
    function CreateGroup(lpidGroup: PDPID; lpGroupName: PDPName; lpData: Pointer; dwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function CreatePlayer(lpidPlayer: PDPID; lpPlayerName: PDPName; hEvent: THandle; lpData: Pointer;
      dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function DeletePlayerFromGroup(idGroup, idPlayer: DPID): HResult; stdcall;
    function DestroyGroup(idGroup: DPID): HResult; stdcall;
    function DestroyPlayer(idPlayer: DPID): HResult; stdcall;
    function EnumGroupPlayers(idGroup: DPID; lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function EnumGroups(lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumPlayers(lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumSessions(lpsd: PDPSessionDesc2; dwTimeout: DWORD; lpEnumSessionsCallback2: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function GetCaps(lpDPCaps: PDPCaps; dwFlags: DWORD): HResult; stdcall;
    function GetGroupData(idGroup: DPID; lpData: Pointer; var lpdwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetGroupName(idGroup: DPID; lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function GetMessageCount(idPlayer: DPID; var lpdwCount: DWORD): HResult; stdcall;
    function GetPlayerAddress(idPlayer: DPID; lpAddress: Pointer; var lpdwAddressSize: DWORD): HResult; stdcall;
    function GetPlayerCaps(idPlayer: DPID; lpPlayerCaps: PDPCaps; dwFlags: DWORD): HResult; stdcall;
    function GetPlayerData(idPlayer: DPID; lpData: Pointer; var lpdwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetPlayerName(idPlayer: DPID; lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function GetSessionDesc(lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function Initialize(lpGUID: PGUID): HResult; stdcall;
    function Open(lpsd: PDPSessionDesc2; dwFlags: DWORD): HResult; stdcall;
    function Receive(var lpidFrom, lpidTo: DPID; dwFlags: DWORD; lpData: Pointer;
      var lpdwDataSize: DWORD): HResult; stdcall;
    function Send(idFrom, lpidTo: DPID; dwFlags: DWORD; lpData: Pointer; lpdwDataSize: DWORD): HResult; stdcall;
    function SetGroupData(idGroup: DPID; lpData: Pointer; dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function SetGroupName(idGroup: DPID; lpGroupName: PDPName; dwFlags: DWORD): HResult; stdcall;
    function SetPlayerData(idPlayer: DPID; lpData: Pointer; dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function SetPlayerName(idPlayer: DPID; lpPlayerName: PDPName; dwFlags: DWORD): HResult; stdcall;
    function SetSessionDesc(lpSessDesc: PDPSessionDesc2; dwFlags: DWORD): HResult; stdcall;
  end;

  IDirectPlay2A = IDirectPlay2;

  IDirectPlay3 = interface(IUnknown)
    { IDirectPlay2 methods }
    function AddPlayerToGroup(idGroup, idPlayer: DPID): HResult; stdcall;
    function Close: HResult; stdcall;
    function CreateGroup(lpidGroup: PDPID; lpGroupName: PDPName; lpData: Pointer; dwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function CreatePlayer(lpidPlayer: PDPID; lpPlayerName: PDPName; hEvent: THandle; lpData: Pointer;
      dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function DeletePlayerFromGroup(idGroup, idPlayer: DPID): HResult; stdcall;
    function DestroyGroup(idGroup: DPID): HResult; stdcall;
    function DestroyPlayer(idPlayer: DPID): HResult; stdcall;
    function EnumGroupPlayers(idGroup: DPID; lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function EnumGroups(lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumPlayers(lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumSessions(lpsd: PDPSessionDesc2; dwTimeout: DWORD; lpEnumSessionsCallback2: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function GetCaps(lpDPCaps: PDPCaps; dwFlags: DWORD): HResult; stdcall;
    function GetGroupData(idGroup: DPID; lpData: Pointer; var lpdwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetGroupName(idGroup: DPID; lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function GetMessageCount(idPlayer: DPID; var lpdwCount: DWORD): HResult; stdcall;
    function GetPlayerAddress(idPlayer: DPID; lpAddress: Pointer; var lpdwAddressSize: DWORD): HResult; stdcall;
    function GetPlayerCaps(idPlayer: DPID; lpPlayerCaps: PDPCaps; dwFlags: DWORD): HResult; stdcall;
    function GetPlayerData(idPlayer: DPID; lpData: Pointer; var lpdwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetPlayerName(idPlayer: DPID; lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function GetSessionDesc(lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function Initialize(lpGUID: PGUID): HResult; stdcall;
    function Open(lpsd: PDPSessionDesc2; dwFlags: DWORD): HResult; stdcall;
    function Receive(var lpidFrom, lpidTo: DPID; dwFlags: DWORD; lpData: Pointer;
      var lpdwDataSize: DWORD): HResult; stdcall;
    function Send(idFrom, lpidTo: DPID; dwFlags: DWORD; lpData: Pointer; lpdwDataSize: DWORD): HResult; stdcall;
    function SetGroupData(idGroup: DPID; lpData: Pointer; dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function SetGroupName(idGroup: DPID; lpGroupName: PDPName; dwFlags: DWORD): HResult; stdcall;
    function SetPlayerData(idPlayer: DPID; lpData: Pointer; dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function SetPlayerName(idPlayer: DPID; lpPlayerName: PDPName; dwFlags: DWORD): HResult; stdcall;
    function SetSessionDesc(lpSessDesc: PDPSessionDesc2; dwFlags: DWORD): HResult; stdcall;
    { IDirectPlay3 methods }
    function AddGroupToGroup(idParentGroup, idGroup: DPID): HResult; stdcall;
    function CreateGroupInGroup(idParentGroup: DPID; lpidGroup: PDPID; lpGroupName: PDPName;
      lpData: Pointer; dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function DeleteGroupFromGroup(idParentGroup, idGroup: DPID): HResult; stdcall;
    function EnumConnections(lpguidApplication: PGUID; lpEnumCallback: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumGroupsInGroup(idGroup: DPID; lpguidInstance: PGUID; lpEnumCallback: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function GetGroupConnectionSettings(dwFlags: DWORD; idGroup: DPID; lpData: Pointer;
      var lpdwDataSize: DWORD): HResult; stdcall;
    function InitializeConnection(lpConnection: Pointer; dwFlags: DWORD): HResult; stdcall;
    function SecureOpen(lpsd: PDPSessionDesc2; dwFlags: DWORD; lpSecurity: Pointer;
      lpCredentials: Pointer): HResult; stdcall;
    function SendChatMessage(idFrom, idTo: DPID; dwFlags: DWORD; lpChatMessage: Pointer): HResult; stdcall;
    function SetGroupConnectionSettings(dwFlags: DWORD; idGroup: DPID; lpConnection: Pointer): HResult; stdcall;
    function StartSession(dwFlags: DWORD; idGroup: DPID): HResult; stdcall;
    function GetGroupFlags(idGroup: DPID; var lpdwFlags: DWORD): HResult; stdcall;
    function GetGroupParent(idGroup: DPID; var lpidParent: DPID): HResult; stdcall;
    function GetPlayerAccount(idPlayer: DPID; dwFlags: DWORD; lpData: Pointer;
      var lpdwDataSize: DWORD): HResult; stdcall;
    function GetPlayerFlags(idPlayer: DPID; var lpdwFlags: DWORD): HResult; stdcall;
  end;

  IDirectPlay3A = interface(IDirectPlay3)
    ['{133EFE41-32DC-11D0-9CFB-00A0C90A43CB}']
  end;

  { the DirectX 6 interface; the component uses its ANSI version (IID_IDirectPlay4A). Vtable
    slots used: CreatePlayer 6, EnumPlayers 12, EnumSessions 13, GetCaps 14, GetMessageCount 17,
    GetPlayerCaps 19, Open 24, Receive 25, SetPlayerName 30, SetSessionDesc 31, EnumConnections
    35, InitializeConnection 38, SendEx 49, GetMessageQueue 50 (and Close 4) }
  IDirectPlay4 = interface(IUnknown)
    { IDirectPlay2 methods }
    function AddPlayerToGroup(idGroup, idPlayer: DPID): HResult; stdcall;
    function Close: HResult; stdcall;
    function CreateGroup(lpidGroup: PDPID; lpGroupName: PDPName; lpData: Pointer; dwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function CreatePlayer(lpidPlayer: PDPID; lpPlayerName: PDPName; hEvent: THandle; lpData: Pointer;
      dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function DeletePlayerFromGroup(idGroup, idPlayer: DPID): HResult; stdcall;
    function DestroyGroup(idGroup: DPID): HResult; stdcall;
    function DestroyPlayer(idPlayer: DPID): HResult; stdcall;
    function EnumGroupPlayers(idGroup: DPID; lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function EnumGroups(lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumPlayers(lpguidInstance: PGUID; lpEnumPlayersCallback2: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumSessions(lpsd: PDPSessionDesc2; dwTimeout: DWORD; lpEnumSessionsCallback2: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function GetCaps(lpDPCaps: PDPCaps; dwFlags: DWORD): HResult; stdcall;
    function GetGroupData(idGroup: DPID; lpData: Pointer; var lpdwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetGroupName(idGroup: DPID; lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function GetMessageCount(idPlayer: DPID; var lpdwCount: DWORD): HResult; stdcall;
    function GetPlayerAddress(idPlayer: DPID; lpAddress: Pointer; var lpdwAddressSize: DWORD): HResult; stdcall;
    function GetPlayerCaps(idPlayer: DPID; lpPlayerCaps: PDPCaps; dwFlags: DWORD): HResult; stdcall;
    function GetPlayerData(idPlayer: DPID; lpData: Pointer; var lpdwDataSize: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetPlayerName(idPlayer: DPID; lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function GetSessionDesc(lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function Initialize(lpGUID: PGUID): HResult; stdcall;
    function Open(lpsd: PDPSessionDesc2; dwFlags: DWORD): HResult; stdcall;
    function Receive(var lpidFrom, lpidTo: DPID; dwFlags: DWORD; lpData: Pointer;
      var lpdwDataSize: DWORD): HResult; stdcall;
    function Send(idFrom, lpidTo: DPID; dwFlags: DWORD; lpData: Pointer; lpdwDataSize: DWORD): HResult; stdcall;
    function SetGroupData(idGroup: DPID; lpData: Pointer; dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function SetGroupName(idGroup: DPID; lpGroupName: PDPName; dwFlags: DWORD): HResult; stdcall;
    function SetPlayerData(idPlayer: DPID; lpData: Pointer; dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function SetPlayerName(idPlayer: DPID; lpPlayerName: PDPName; dwFlags: DWORD): HResult; stdcall;
    function SetSessionDesc(lpSessDesc: PDPSessionDesc2; dwFlags: DWORD): HResult; stdcall;
    { IDirectPlay3 methods }
    function AddGroupToGroup(idParentGroup, idGroup: DPID): HResult; stdcall;
    function CreateGroupInGroup(idParentGroup: DPID; lpidGroup: PDPID; lpGroupName: PDPName;
      lpData: Pointer; dwDataSize: DWORD; dwFlags: DWORD): HResult; stdcall;
    function DeleteGroupFromGroup(idParentGroup, idGroup: DPID): HResult; stdcall;
    function EnumConnections(lpguidApplication: PGUID; lpEnumCallback: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function EnumGroupsInGroup(idGroup: DPID; lpguidInstance: PGUID; lpEnumCallback: Pointer;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function GetGroupConnectionSettings(dwFlags: DWORD; idGroup: DPID; lpData: Pointer;
      var lpdwDataSize: DWORD): HResult; stdcall;
    function InitializeConnection(lpConnection: Pointer; dwFlags: DWORD): HResult; stdcall;
    function SecureOpen(lpsd: PDPSessionDesc2; dwFlags: DWORD; lpSecurity: Pointer;
      lpCredentials: Pointer): HResult; stdcall;
    function SendChatMessage(idFrom, idTo: DPID; dwFlags: DWORD; lpChatMessage: Pointer): HResult; stdcall;
    function SetGroupConnectionSettings(dwFlags: DWORD; idGroup: DPID; lpConnection: Pointer): HResult; stdcall;
    function StartSession(dwFlags: DWORD; idGroup: DPID): HResult; stdcall;
    function GetGroupFlags(idGroup: DPID; var lpdwFlags: DWORD): HResult; stdcall;
    function GetGroupParent(idGroup: DPID; var lpidParent: DPID): HResult; stdcall;
    function GetPlayerAccount(idPlayer: DPID; dwFlags: DWORD; lpData: Pointer;
      var lpdwDataSize: DWORD): HResult; stdcall;
    function GetPlayerFlags(idPlayer: DPID; var lpdwFlags: DWORD): HResult; stdcall;
    { IDirectPlay4 methods }
    function GetGroupOwner(idGroup: DPID; var lpidOwner: DPID): HResult; stdcall;
    function SetGroupOwner(idGroup, idOwner: DPID): HResult; stdcall;
    function SendEx(idFrom, idTo: DPID; dwFlags: DWORD; lpData: Pointer; dwDataSize: DWORD;
      dwPriority: DWORD; dwTimeout: DWORD; lpContext: Pointer; lpdwMsgID: PDWORD): HResult; stdcall;
    function GetMessageQueue(idFrom, idTo: DPID; dwFlags: DWORD; lpdwNumMsgs: PDWORD;
      lpdwNumBytes: PDWORD): HResult; stdcall;
    function CancelMessage(dwMsgID: DWORD; dwFlags: DWORD): HResult; stdcall;
    function CancelPriority(dwMinPriority, dwMaxPriority: DWORD; dwFlags: DWORD): HResult; stdcall;
  end;

  IDirectPlay4A = interface(IDirectPlay4)
    ['{0AB1C531-4745-11D1-A7A1-0000F803ABFC}']
  end;

implementation

end.
