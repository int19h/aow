unit DPLobby;

{ The DPLobby unit of aowDPlay.dpl: the DirectPlayLobby declarations (dplobby.h of DirectX 6) that
  the aowDPlayComp unit uses, written for the original compiler (Delphi 3.02). Like DPlay, the
  unit has no code of its own; its exported data are the GUID typed constants below and the type
  info of the three lobby interfaces (declared without GUIDs). The component uses
  IDirectPlayLobby3A for CreateAddress (slot 4), GetConnectionSettings (8),
  SetConnectionSettings (12) and Connect (3). }

interface

uses
  Windows, DPlay;

const
  DPERR_NOTLOBBIED = HResult($8877042E);

  DPLCONNECTION_CREATESESSION = $00000001;
  DPLCONNECTION_JOINSESSION = $00000002;

  IID_IDirectPlayLobby: TGUID = (D1: $AF465C71; D2: $9588; D3: $11CF; D4: ($A0, $20, $00, $AA, $00, $61, $57, $AC));
  IID_IDirectPlayLobbyA: TGUID = (D1: $26C66A70; D2: $B367; D3: $11CF; D4: ($A0, $24, $00, $AA, $00, $61, $57, $AC));
  IID_IDirectPlayLobby2: TGUID = (D1: $0194C220; D2: $A303; D3: $11D0; D4: ($9C, $4F, $00, $A0, $C9, $05, $42, $5E));
  { sic: the original has 00 00 where dplobby.h has 00 A0 }
  IID_IDirectPlayLobby2A: TGUID = (D1: $1BB4AF80; D2: $A303; D3: $11D0; D4: ($9C, $4F, $00, $00, $C9, $05, $42, $5E));
  IID_IDirectPlayLobby3: TGUID = (D1: $2DB72490; D2: $652C; D3: $11D1; D4: ($A7, $A8, $00, $00, $F8, $03, $AB, $FC));
  IID_IDirectPlayLobby3A: TGUID = (D1: $2DB72491; D2: $652C; D3: $11D1; D4: ($A7, $A8, $00, $00, $F8, $03, $AB, $FC));
  CLSID_DirectPlayLobby: TGUID = (D1: $2FE8F810; D2: $B2A5; D3: $11D0; D4: ($A7, $87, $00, $00, $F8, $03, $AB, $FC));
  DPLPROPERTY_MessagesSupported: TGUID = (D1: $762CCDA1; D2: $D916; D3: $11D0; D4: ($BA, $39, $00, $C0, $4F, $D7, $ED, $67));
  DPLPROPERTY_LobbyGuid: TGUID = (D1: $F56920A0; D2: $D218; D3: $11D0; D4: ($BA, $39, $00, $C0, $4F, $D7, $ED, $67));
  DPLPROPERTY_PlayerGuid: TGUID = (D1: $B4319322; D2: $D20D; D3: $11D0; D4: ($BA, $39, $00, $C0, $4F, $D7, $ED, $67));
  DPLPROPERTY_PlayerScore: TGUID = (D1: $48784000; D2: $D219; D3: $11D0; D4: ($BA, $39, $00, $C0, $4F, $D7, $ED, $67));
  { address data types (DirectPlay address chunks) }
  DPAID_TotalSize: TGUID = (D1: $1318F560; D2: $912C; D3: $11D0; D4: ($9D, $AA, $00, $A0, $C9, $0A, $43, $CB));
  DPAID_ServiceProvider: TGUID = (D1: $07D916C0; D2: $E0AF; D3: $11CF; D4: ($9C, $4E, $00, $A0, $C9, $05, $42, $5E));
  DPAID_LobbyProvider: TGUID = (D1: $59B95640; D2: $9667; D3: $11D0; D4: ($A7, $7D, $00, $00, $F8, $03, $AB, $FC));
  DPAID_Phone: TGUID = (D1: $78EC89A0; D2: $E0AF; D3: $11CF; D4: ($9C, $4E, $00, $A0, $C9, $05, $42, $5E));
  DPAID_PhoneW: TGUID = (D1: $BA5A7A70; D2: $9DBF; D3: $11D0; D4: ($9C, $C1, $00, $A0, $C9, $05, $42, $5E));
  DPAID_Modem: TGUID = (D1: $F6DCC200; D2: $A2FE; D3: $11D0; D4: ($9C, $4F, $00, $A0, $C9, $05, $42, $5E));
  DPAID_ModemW: TGUID = (D1: $01FD92E0; D2: $A2FF; D3: $11D0; D4: ($9C, $4F, $00, $A0, $C9, $05, $42, $5E));
  DPAID_INet: TGUID = (D1: $C4A54DA0; D2: $E0AF; D3: $11CF; D4: ($9C, $4E, $00, $A0, $C9, $05, $42, $5E));
  DPAID_INetW: TGUID = (D1: $E63232A0; D2: $9DBF; D3: $11D0; D4: ($9C, $C1, $00, $A0, $C9, $05, $42, $5E));
  DPAID_INetPort: TGUID = (D1: $E4524541; D2: $8EA5; D3: $11D1; D4: ($8A, $96, $00, $60, $97, $B0, $14, $11));
  DPAID_ComPort: TGUID = (D1: $F2F0CE00; D2: $E0AF; D3: $11CF; D4: ($9C, $4E, $00, $A0, $C9, $05, $42, $5E));

type
  { DPLCONNECTION (40 bytes) }
  PDPLConnection = ^TDPLConnection;
  TDPLConnection = record
    dwSize: DWORD;
    dwFlags: DWORD;
    lpSessionDesc: PDPSessionDesc2;
    lpPlayerName: PDPName;
    guidSP: TGUID;
    lpAddress: Pointer;
    dwAddressSize: DWORD;
  end;

  { DPCOMPORTADDRESS (20 bytes): the DPAID_ComPort address chunk }
  PDPComPortAddress = ^TDPComPortAddress;
  TDPComPortAddress = record
    dwComPort: DWORD;
    dwBaudRate: DWORD;
    dwStopBits: DWORD;
    dwParity: DWORD;
    dwFlowControl: DWORD;
  end;

  IDirectPlayLobby = interface(IUnknown)
    function Connect(dwFlags: DWORD; var lplpDP: IDirectPlay2; pUnk: Pointer): HResult; stdcall;
    function CreateAddress(const guidSP, guidDataType: TGUID; lpData: Pointer; dwDataSize: DWORD;
      lpAddress: Pointer; var lpdwAddressSize: DWORD): HResult; stdcall;
    function EnumAddress(lpEnumAddressCallback: Pointer; lpAddress: Pointer; dwAddressSize: DWORD;
      lpContext: Pointer): HResult; stdcall;
    function EnumAddressTypes(lpEnumAddressTypeCallback: Pointer; const guidSP: TGUID;
      lpContext: Pointer; dwFlags: DWORD): HResult; stdcall;
    function EnumLocalApplications(lpEnumLocalAppCallback: Pointer; lpContext: Pointer;
      dwFlags: DWORD): HResult; stdcall;
    function GetConnectionSettings(dwAppID: DWORD; lpData: PDPLConnection;
      var lpdwDataSize: DWORD): HResult; stdcall;
    function ReceiveLobbyMessage(dwFlags: DWORD; dwAppID: DWORD; var lpdwMessageFlags: DWORD;
      lpData: Pointer; var lpdwDataSize: DWORD): HResult; stdcall;
    function RunApplication(dwFlags: DWORD; var lpdwAppID: DWORD; lpConn: PDPLConnection;
      hReceiveEvent: THandle): HResult; stdcall;
    function SendLobbyMessage(dwFlags: DWORD; dwAppID: DWORD; lpData: Pointer;
      dwDataSize: DWORD): HResult; stdcall;
    function SetConnectionSettings(dwFlags: DWORD; dwAppID: DWORD; lpConn: PDPLConnection): HResult; stdcall;
    function SetLobbyMessageEvent(dwFlags: DWORD; dwAppID: DWORD; hReceiveEvent: THandle): HResult; stdcall;
  end;

  IDirectPlayLobbyA = IDirectPlayLobby;

  IDirectPlayLobby2 = interface(IDirectPlayLobby)
    function CreateCompoundAddress(lpElements: Pointer; dwElementCount: DWORD; lpAddress: Pointer;
      var lpdwAddressSize: DWORD): HResult; stdcall;
  end;

  IDirectPlayLobby2A = IDirectPlayLobby2;

  IDirectPlayLobby3 = interface(IDirectPlayLobby2)
    function ConnectEx(dwFlags: DWORD; const riid: TGUID; var lplpDP: Pointer;
      pUnk: Pointer): HResult; stdcall;
    function RegisterApplication(dwFlags: DWORD; lpAppDesc: Pointer): HResult; stdcall;
    function UnregisterApplication(dwFlags: DWORD; const guidApplication: TGUID): HResult; stdcall;
    function WaitForConnectionSettings(dwFlags: DWORD): HResult; stdcall;
  end;

  IDirectPlayLobby3A = IDirectPlayLobby3;

implementation

end.
