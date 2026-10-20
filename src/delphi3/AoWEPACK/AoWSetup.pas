unit AoWSetup;

{ Draft declarations of AoWSetup, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TSetupPackage = class;
  TRemotePlayer = class;
  TRemotePlayerList = class;
  TPlayerSetupSettings = class;
  TSetupSettings = class;
  TCustomizeLeaderControl = class;
  TSetupControl = class;

  TSetupStatus = set of (ssBusy, ssAborted, ssRemote); { ot=1 }
  TSetupPhase = (spIdle, spSetupPlayers, spCustomizeLeaders, spSendMap, spLoadMap, spSynchronize, spSetupMap);  { ot=1 }
  TMapValidationInfo = (mviUnknown, mviInvalid, mviInvalidMap, mviValid);  { ot=1 }
  TPlayerSetupStatus = set of (pssFixed, pssForced, pssLeaderCustomized, pssLoaded); { ot=1 }
  TSetupControlEvent = procedure(SetupControl: TSetupControl) of object;
  TCustomizeLeaderEvent = procedure(SetupControl: TSetupControl; CLC: TCustomizeLeaderControl) of object;
  TLoadMapEvent = procedure(SetupControl: TSetupControl; const Filename: String) of object;
  TEjectPlayerEvent = procedure(SetupControl: TSetupControl; RemoteID: Integer) of object;
  TIncompatibleVersionEvent = procedure(SetupControl: TSetupControl; MajorVersion: Integer; MinorVersion: Integer) of object;
  TSendMapEvent = procedure(SetupControl: TSetupControl; Data: Pointer; Size: Integer; Recipient: Integer) of object;

  { TSetupPackage (instance size 24, VMT 557DE814) }
  TSetupPackage = class(TEObject)
  public
    F_SetupPackage_08: Integer;
    F_SetupPackage_0C: Integer;
    F_SetupPackage_10: Integer;
    F_SetupPackage_14: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TRemotePlayer (instance size 24, VMT 557DE92C) }
  TRemotePlayer = class(TEObject)
  public
    F_RemotePlayer_08: Integer;
    F_RemotePlayer_0C: Integer;
    F_RemotePlayer_10: Byte;
    F_RemotePlayer_11: Byte;
    F_RemotePlayer_12: array[0..1] of Byte;
    F_RemotePlayer_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TRemotePlayerList (instance size 12, VMT 557DEA00) }
  TRemotePlayerList = class(TENode)
  public
    procedure GetPlayers(A1: Integer);  { draft }
    procedure IndexOfRemoteID(A1: Integer);  { draft }
  end;

  { TPlayerSetupSettings (instance size 40, VMT 557DEB70) }
  TPlayerSetupSettings = class(TEObject)
  public
    F_PlayerSetupSettings_08: array[0..15] of Byte;
    F_PlayerSetupSettings_18: Byte;
    F_PlayerSetupSettings_19: Byte;
    F_PlayerSetupSettings_1A: array[0..1] of Byte;
    F_PlayerSetupSettings_1C: Integer;
    F_PlayerSetupSettings_20: Byte;
    F_PlayerSetupSettings_21: Byte;
    F_PlayerSetupSettings_22: array[0..5] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TSetupSettings (instance size 68, VMT 557DEC54) }
  TSetupSettings = class(TENode)
  public
    F_SetupSettings_0C: Integer;
    F_SetupSettings_10: Integer;
    F_SetupSettings_14: Integer;
    F_SetupSettings_18: Integer;
    F_SetupSettings_1C: Integer;
    F_SetupSettings_20: Integer;
    F_SetupSettings_24: Byte;
    F_SetupSettings_25: Byte;
    F_SetupSettings_26: Byte;
    F_SetupSettings_27: Byte;
    F_SetupSettings_28: Byte;
    F_SetupSettings_29: Byte;
    F_SetupSettings_2A: Byte;
    F_SetupSettings_2B: array[0..0] of Byte;
    F_SetupSettings_2C: Integer;
    F_SetupSettings_30: Integer;
    F_SetupSettings_34: Integer;
    F_SetupSettings_38: Integer;
    F_SetupSettings_3C: Byte;
    F_SetupSettings_3D: Byte;
    F_SetupSettings_3E: Byte;
    F_SetupSettings_3F: array[0..0] of Byte;
    F_SetupSettings_40: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Reset;  { draft }
    procedure GetSettings(A1: Integer);  { draft }
    procedure IndexOfPlayer(A1: Byte);  { draft }
    procedure IndexOfRemoteID(A1: Integer);  { draft }
    procedure IndexOfRace(A1: Byte);  { draft }
  end;

  { TCustomizeLeaderControl (instance size 48, VMT 557DED7C) }
  TCustomizeLeaderControl = class(TLeaderSetupControl)
  public
    F_CustomizeLeaderControl_28: Byte;
    F_CustomizeLeaderControl_29: array[0..6] of Byte;
    procedure Done; override;
  end;

  { TSetupControl (instance size 160, VMT 557DF040) }
  TSetupControl = class(TComponent)
  public
    F_SetupControl_24: Byte;
    F_SetupControl_25: Byte;
    F_SetupControl_26: array[0..1] of Byte;
    F_SetupControl_28: Integer;
    F_SetupControl_2C: Integer;
    F_SetupControl_30: Integer;
    F_SetupControl_34: Integer;
    F_SetupControl_38: array[0..3] of Byte;
    F_SetupControl_3C: Integer;
    F_SetupControl_40: array[0..3] of Byte;
    F_SetupControl_44: Integer;
    F_SetupControl_48: array[0..3] of Byte;
    F_SetupControl_4C: Integer;
    F_SetupControl_50: array[0..3] of Byte;
    F_SetupControl_54: Integer;
    F_SetupControl_58: array[0..11] of Byte;
    F_SetupControl_64: Integer;
    F_SetupControl_68: array[0..3] of Byte;
    F_SetupControl_6C: Integer;
    F_SetupControl_70: array[0..3] of Byte;
    F_SetupControl_74: Integer;
    F_SetupControl_78: array[0..3] of Byte;
    F_SetupControl_7C: Integer;
    F_SetupControl_80: array[0..3] of Byte;
    F_SetupControl_84: Integer;
    F_SetupControl_88: array[0..3] of Byte;
    F_SetupControl_8C: Integer;
    F_SetupControl_90: array[0..3] of Byte;
    F_SetupControl_94: Integer;
    F_SetupControl_98: array[0..3] of Byte;
    F_SetupControl_9C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure SendData(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SendPackage(A1: Integer; A2: Integer);  { draft }
    procedure SendMessage(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure SendHostMessage(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DataReceived(A1: Integer; A2: Integer);  { draft }
    procedure ValidateCompatibleVersion(A1: Integer);  { draft }
    procedure hConnectPlayer(A1: Integer);  { draft }
    procedure hDisconnectPlayer(A1: Integer);  { draft }
    procedure hUpdatePlayer(A1: Integer);  { draft }
    procedure CanSetHostRemoteID(A1: Integer);  { draft }
    procedure hSetHostRemoteID(A1: Integer);  { draft }
    procedure ValidateMap;  { draft }
    procedure PackageReceived(A1: Integer; A2: Byte);  { draft }
    procedure LoadMap;  { draft }
    procedure hValidateSendMap;  { draft }
    procedure hSendMap;  { draft }
    procedure MapReceived(A1: Integer; A2: Integer);  { draft }
    procedure hMapLoaded(A1: Integer);  { draft }
    procedure MapLoaded;  { draft }
    procedure hLeaderCustomized(A1: Integer; A2: Integer);  { draft }
    procedure CustomizeLeaders(A1: Integer; A2: Integer);  { draft }
    procedure LeaderCustomized(A1: Integer);  { draft }
    procedure ListPCCInfo(A1: Integer);  { draft }
    procedure RemoveIndependentPlayers;  { draft }
    procedure SetupMap;  { draft }
    procedure hValidateSetupMap;  { draft }
    procedure UpdateSettings;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure GetRemote;  { draft }
    procedure GetHost;  { draft }
    procedure Reset;  { draft }
    procedure Disconnect;  { draft }
    procedure GetPlayerName(A1: Integer);  { draft }
    procedure SetPlayerName(A1: Integer; A2: Integer);  { draft }
    procedure GetPreferredRace;  { draft }
    procedure SetPreferredRace(A1: Byte);  { draft }
    procedure ResetPlayerSettings(A1: Integer);  { draft }
    procedure UpdatePreferredRaces;  { draft }
    procedure ListAvailablePlayers(A1: Integer);  { draft }
    procedure ValidatePlayerName(A1: Integer; A2: Integer);  { draft }
    procedure PlayerNameToPlayerID(A1: Integer; A2: Integer);  { draft }
    procedure GetPlayerSetupValid(A1: Integer; A2: Integer);  { draft }
    procedure GetAllMapsValid;  { draft }
    procedure hPlayerSetupDone;  { draft }
    procedure hSetPlayerBehavior(A1: Integer; A2: Integer);  { draft }
    procedure hSetExplorationEnabled(A1: Integer);  { draft }
    procedure hSetLeadersOnMap(A1: Integer);  { draft }
    procedure hSetTacticalCombatAvailability(A1: Integer);  { draft }
    procedure hSetAlwaysViewTC(A1: Integer);  { draft }
    procedure hSetAlliedVictory(A1: Integer);  { draft }
    procedure hSetCustomizeLeaders(A1: Integer);  { draft }
    procedure hSetTurnLimitation(A1: Integer);  { draft }
    procedure hSetTurnTimeLimitation(A1: Integer);  { draft }
    procedure hSetPlayerID(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure hSetPlayMode(A1: Integer);  { draft }
    procedure hSetIndependentAIMode(A1: Integer);  { draft }
    procedure hPickMap(A1: Integer);  { draft }
    procedure hEjectPlayer(A1: Integer);  { draft }
    procedure SetupHost(A1: Integer; A2: Byte);  { draft }
    procedure SetupUser(A1: Integer; A2: Integer);  { draft }
  end;

procedure RegisterSetupClasses;  { draft }
procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TSetupPackage.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSetupPackage.Destroy;
begin end;

class function TSetupPackage.ClassID: Integer;
begin Result := 0; end;

procedure TSetupPackage.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function TRemotePlayer.ClassID: Integer;
begin Result := 0; end;

procedure TRemotePlayer.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TRemotePlayerList.GetPlayers(A1: Integer);
begin end;

procedure TRemotePlayerList.IndexOfRemoteID(A1: Integer);
begin end;

constructor TPlayerSetupSettings.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerSetupSettings.Destroy;
begin end;

class function TPlayerSetupSettings.ClassID: Integer;
begin Result := 0; end;

procedure TPlayerSetupSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TSetupSettings.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSetupSettings.Destroy;
begin end;

procedure TSetupSettings.Reset;
begin end;

class function TSetupSettings.ClassID: Integer;
begin Result := 0; end;

procedure TSetupSettings.GetSettings(A1: Integer);
begin end;

procedure TSetupSettings.IndexOfPlayer(A1: Byte);
begin end;

procedure TSetupSettings.IndexOfRemoteID(A1: Integer);
begin end;

procedure TSetupSettings.IndexOfRace(A1: Byte);
begin end;

procedure TSetupSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCustomizeLeaderControl.Done;
begin end;

constructor TSetupControl.Create(AOwner: Classes.TComponent);
begin end;

destructor TSetupControl.Destroy;
begin end;

procedure TSetupControl.SendData(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSetupControl.SendPackage(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.SendMessage(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TSetupControl.SendHostMessage(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSetupControl.DataReceived(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.ValidateCompatibleVersion(A1: Integer);
begin end;

procedure TSetupControl.hConnectPlayer(A1: Integer);
begin end;

procedure TSetupControl.hDisconnectPlayer(A1: Integer);
begin end;

procedure TSetupControl.hUpdatePlayer(A1: Integer);
begin end;

procedure TSetupControl.CanSetHostRemoteID(A1: Integer);
begin end;

procedure TSetupControl.hSetHostRemoteID(A1: Integer);
begin end;

procedure TSetupControl.ValidateMap;
begin end;

procedure TSetupControl.PackageReceived(A1: Integer; A2: Byte);
begin end;

procedure TSetupControl.LoadMap;
begin end;

procedure TSetupControl.hValidateSendMap;
begin end;

procedure TSetupControl.hSendMap;
begin end;

procedure TSetupControl.MapReceived(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.hMapLoaded(A1: Integer);
begin end;

procedure TSetupControl.MapLoaded;
begin end;

procedure TSetupControl.hLeaderCustomized(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.CustomizeLeaders(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.LeaderCustomized(A1: Integer);
begin end;

procedure TSetupControl.ListPCCInfo(A1: Integer);
begin end;

procedure TSetupControl.RemoveIndependentPlayers;
begin end;

procedure TSetupControl.SetupMap;
begin end;

procedure TSetupControl.hValidateSetupMap;
begin end;

procedure TSetupControl.UpdateSettings;
begin end;

procedure TSetupControl.BeginUpdate;
begin end;

procedure TSetupControl.EndUpdate;
begin end;

procedure TSetupControl.GetRemote;
begin end;

procedure TSetupControl.GetHost;
begin end;

procedure TSetupControl.Reset;
begin end;

procedure TSetupControl.Disconnect;
begin end;

procedure TSetupControl.GetPlayerName(A1: Integer);
begin end;

procedure TSetupControl.SetPlayerName(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.GetPreferredRace;
begin end;

procedure TSetupControl.SetPreferredRace(A1: Byte);
begin end;

procedure TSetupControl.ResetPlayerSettings(A1: Integer);
begin end;

procedure TSetupControl.UpdatePreferredRaces;
begin end;

procedure TSetupControl.ListAvailablePlayers(A1: Integer);
begin end;

procedure TSetupControl.ValidatePlayerName(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.PlayerNameToPlayerID(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.GetPlayerSetupValid(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.GetAllMapsValid;
begin end;

procedure TSetupControl.hPlayerSetupDone;
begin end;

procedure TSetupControl.hSetPlayerBehavior(A1: Integer; A2: Integer);
begin end;

procedure TSetupControl.hSetExplorationEnabled(A1: Integer);
begin end;

procedure TSetupControl.hSetLeadersOnMap(A1: Integer);
begin end;

procedure TSetupControl.hSetTacticalCombatAvailability(A1: Integer);
begin end;

procedure TSetupControl.hSetAlwaysViewTC(A1: Integer);
begin end;

procedure TSetupControl.hSetAlliedVictory(A1: Integer);
begin end;

procedure TSetupControl.hSetCustomizeLeaders(A1: Integer);
begin end;

procedure TSetupControl.hSetTurnLimitation(A1: Integer);
begin end;

procedure TSetupControl.hSetTurnTimeLimitation(A1: Integer);
begin end;

procedure TSetupControl.hSetPlayerID(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSetupControl.hSetPlayMode(A1: Integer);
begin end;

procedure TSetupControl.hSetIndependentAIMode(A1: Integer);
begin end;

procedure TSetupControl.hPickMap(A1: Integer);
begin end;

procedure TSetupControl.hEjectPlayer(A1: Integer);
begin end;

procedure TSetupControl.SetupHost(A1: Integer; A2: Byte);
begin end;

procedure TSetupControl.SetupUser(A1: Integer; A2: Integer);
begin end;

procedure RegisterSetupClasses;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
