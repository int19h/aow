unit AoWSetup;
{ Draft declarations of AoWSetup, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Setup, synchronization and map selection bodies are recovered. }
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;
type
  TSetupPackage = class;
  TSetupPlayerBehavior = record
    PlayerType: Byte;
    Reserved: array[0..2] of Byte;
    Flags: Integer;
  end;
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
    FMessageID: Integer; { +$08 }
    FParam2: Integer; { +$0C }
    FParam1: Integer; { +$10 }
    FData: TEObject; { +$14 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;
  { TRemotePlayer (instance size 24, VMT 557DE92C) }
  TRemotePlayer = class(TEObject)
  public
    FName: string; { +$08 }
    FRemoteID: Integer; { +$0C }
    FPreferredRace: Byte; { +$10 }
    FMapValidation: TMapValidationInfo; { +$11 }
    F_RemotePlayer_12: array[0..1] of Byte;
    FVersion: Integer; { +$14 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;
  { TRemotePlayerList (instance size 12, VMT 557DEA00) }
  TRemotePlayerList = class(TENode)
  public
    function GetPlayers(Index: Integer): TRemotePlayer;
    function IndexOfRemoteID(RemoteID: Integer): Integer;
  end;
  { TPlayerSetupSettings (instance size 40, VMT 557DEB70); $08/$10 behaviors, $18 race, $19 status, $1C leader, $20 player, $21 behavior, $24 email. }
  TPlayerSetupSettings = class(TEObject)
  public
    FBehavior: TSetupPlayerBehavior; { +$08 }
    FOriginalBehavior: TSetupPlayerBehavior; { +$10 }
    FRace: Shortint; { $18; AoW.exe 00413613 }
    FStatus: TPlayerSetupStatus; { +$19 }
    F_PlayerSetupSettings_1A: array[0..1] of Byte;
    FLeader: TLeader; { +$1C }
    FPlayerID: Byte; { +$20 }
    FBehaviorMode: Byte; { +$21 }
    F_PlayerSetupSettings_22: array[0..1] of Byte;
    FEmailAddress: string; { $24; 557E0C29 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;
  { TSetupSettings (instance size 68, VMT 557DEC54); $18/$1C CRCs, $20 day, $24 play mode, $28 victory, $29 independent AI, $2C seed, $30/$34 limits, $38 players, $3C connection, $3D tactical combat, $40 email game name. }
  TSetupSettings = class(TENode)
  public
    FHostRemoteID: Integer;
    FFileName: string; { +$10 }
    FMapName: string; { +$14 }
    FMapCRC: Integer; { $18 }
    FSetCRC: Integer; { $1C }
    FMapDay: Integer; { $20 }
    FPlayMode: Byte; { $24 }
    FExplorationEnabled: Boolean; { +$25 }
    FLeadersOnMap: Boolean; { +$26 }
    FAlliedVictory: Boolean; { +$27 }
    FVictoryCondition: Byte; { $28 }
    FIndependentAIMode: Byte; { $29 }
    FCustomizeLeaders: Boolean; { +$2A }
    F_SetupSettings_2B: array[0..0] of Byte;
    FRandomSeed: Integer; { $2C }
    FDayLimit: Integer; { $30 }
    FTurnTime: Integer; { $34 }
    FRemotePlayers: TRemotePlayerList; { +$38 }
    FConnectionType: Byte; { $3C }
    FTacticalCombatAvailability: Byte; { $3D }
    FAlwaysViewTC: Boolean; { +$3E }
    F_SetupSettings_3F: array[0..0] of Byte;
    FEmailGameName: string; { $40; 557E0C66 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Reset;
    function GetSettings(Index: Integer): TPlayerSetupSettings;
    function IndexOfPlayer(Player: Byte): Integer;
    function IndexOfRemoteID(RemoteID: Integer): Integer;
    function IndexOfRace(Race: Byte): Integer;
  end;
  { TCustomizeLeaderControl (instance size 48, VMT 557DED7C) }
  TCustomizeLeaderControl = class(TLeaderSetupControl)
  public
    FSetupControl: TSetupControl; { +$28 }
    FPlayerIndex: Integer; { +$2C }
    function Done: Boolean; override;
  end;
  { TSetupControl (instance size 160, VMT 557DF040) }
  TSetupControl = class(TComponent)
  public
    FStatus: TSetupStatus; { +$24 }
    FPhase: TSetupPhase; { +$25 }
    FReserved26: array[0..1] of Byte;
    FSettings: TSetupSettings; { +$28 }
    FStream: TMemoryStream; { +$2C }
    FUpdateCount: Integer; { +$30 }
    FRemotePlayer: TRemotePlayer; { +$34 }
    FOnSettingChanged: TSetupControlEvent; { +$38 }
    FOnLoadMap: TLoadMapEvent; { +$40 }
    FOnSetupMap: TSetupControlEvent; { +$48 }
    FOnStart: TSetupControlEvent; { +$50 }
    FOnAbort: TSetupControlEvent; { +$58 }
    FOnCustomizeLeader: TCustomizeLeaderEvent; { +$60 }
    FOnSynchronize: TSetupControlEvent; { +$68 }
    FOnPlayerSetupDone: TSetupControlEvent; { +$70 }
    FOnEjectPlayer: TEjectPlayerEvent; { +$78 }
    FOnIncompatibleVersion: TIncompatibleVersionEvent; { +$80 }
    FOnSendData: TSendDataEvent; { +$88 }
    FOnSendMap: TSendMapEvent; { +$90 }
    FOnSendingMaps: TSetupControlEvent; { +$98 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure SendData(Data: Pointer; Size, Recipient: Integer);
    procedure SendPackage(Package: TSetupPackage; Recipient: Integer);
    procedure SendMessage(MessageID: Integer; Obj: TEObject; Param2, Param1, Recipient: Integer);
    procedure SendHostMessage(MessageID: Integer; Obj: TEObject; Param2, Param1: Integer);
    procedure DataReceived(Data: Pointer; Size, SenderID: Integer);
    function ValidateCompatibleVersion(Version: Integer): Boolean;
    procedure hConnectPlayer(Player: TRemotePlayer);
    procedure hDisconnectPlayer(RemoteID: Integer);
    procedure hUpdatePlayer(Player: TRemotePlayer);
    function CanSetHostRemoteID(RemoteID: Integer): Boolean;
    procedure hSetHostRemoteID(RemoteID: Integer);
    procedure ValidateMap;
    procedure PackageReceived(Package: TSetupPackage; SenderID: Integer);
    procedure LoadMap;
    function hValidateSendMap: Boolean;
    procedure hSendMap;
    procedure MapReceived(Data: Pointer; Size: Integer);
    procedure hMapLoaded(Index: Integer);
    procedure MapLoaded;
    procedure hLeaderCustomized(Index: Integer; Leader: TLeader);
    function CustomizeLeaders: Boolean;
    procedure LeaderCustomized(Control: TCustomizeLeaderControl);
    procedure ListPCCInfo(PCC: TPlayerCommunicationControl);
    procedure RemoveIndependentPlayers;
    procedure SetupMap;
    function hValidateSetupMap: Boolean;
    procedure UpdateSettings;
    procedure BeginUpdate;
    procedure EndUpdate;
    function GetRemote: Boolean;
    function GetHost: Boolean;
    procedure Reset;  { draft }
    procedure Disconnect;
    function GetPlayerName: string;
    procedure SetPlayerName(Value: string);
    function GetPreferredRace: Shortint;
    procedure SetPreferredRace(Value: Byte);
    procedure ResetPlayerSettings(Index: Integer);
    function UpdatePreferredRaces: Boolean;
    procedure ListAvailablePlayers(List: TStrings);
    function ValidatePlayerName(const Name: string): string;
    function PlayerNameToPlayerID(const Name: string; var Behavior: TSetupPlayerBehavior): Boolean;
    function GetPlayerSetupValid: Boolean;
    function GetAllMapsValid: Boolean;
    function hPlayerSetupDone: Boolean;
    procedure hSetPlayerBehavior(Index: Integer; Value: Byte);
    procedure hSetExplorationEnabled(Value: Boolean);
    procedure hSetLeadersOnMap(Value: Boolean);
    procedure hSetTacticalCombatAvailability(Value: Byte);
    procedure hSetAlwaysViewTC(Value: Boolean);
    procedure hSetAlliedVictory(Value: Boolean);
    procedure hSetCustomizeLeaders(Value: Boolean);
    procedure hSetTurnLimitation(Value: Integer);
    procedure hSetTurnTimeLimitation(Value: Integer);
    procedure hSetPlayerID(Index: Integer; const Behavior: TSetupPlayerBehavior; Forced: Boolean);
    procedure hSetPlayMode(Value: Byte);
    procedure hSetIndependentAIMode(Value: Byte);
    function hPickMap(const FileName: string): Boolean;
    procedure hEjectPlayer(RemoteID: Integer);
    function SetupHost(const Name: string; Mode: Byte; RemoteID: Integer): Boolean;
    function SetupUser(const Name: string; RemoteID: Integer): Boolean;
  end;
procedure RegisterSetupClasses(AEngine: TEngine);
procedure Register;
implementation
type
  TLeaderSetupView = class(TObject)
    Reserved04: array[4..$B] of Byte;
    OriginalLeader: TLeader;
    Options: set of 0..7;
    Reserved11: array[$11..$13] of Byte;
    Leader: TLeader;
    Races: TIntegerList;
  end;
  TSetupHeroView = class(TObject)
    Reserved: array[4..$5F] of Byte;
    Name: string;
  end;
const
  CPUBehavior: TSetupPlayerBehavior = (PlayerType: 1; Reserved: (0,0,0); Flags: 0);
  FreeBehavior: TSetupPlayerBehavior = (PlayerType: 5; Reserved: (0,0,0); Flags: 0);
  DefaultBehavior: TSetupPlayerBehavior = (PlayerType: 0; Reserved: (0,0,0); Flags: 0);
  DefaultOriginalBehavior: TSetupPlayerBehavior = (PlayerType: 5; Reserved: (0,0,0); Flags: 0);

function MajorVersion(AEngine: TAoWEngine): Integer; assembler;
asm jmp TAoWEngine.GetMajorVersion end;
function MinorVersion(AEngine: TAoWEngine): Integer; assembler;
asm jmp TAoWEngine.GetMinorVersion end;






constructor TSetupPackage.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

destructor TSetupPackage.Destroy;
var
  Data: TEObject;
begin
  Data := FData;
  if Data <> nil then Data.Free;
  inherited Destroy;
end;

class function TSetupPackage.ClassID: Integer;
begin Result := $20261; end;

procedure TSetupPackage.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FMessageID, 20);
  Stream.rwInteger(FParam2, 21);
  Stream.rwInteger(FParam1, 22);
  Stream.rwCreateEObject(FData, nil, 23);
end;

class function TRemotePlayer.ClassID: Integer;
begin Result := $20262; end;

procedure TRemotePlayer.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 20);
  Stream.rwData(FRemoteID, SizeOf(FRemoteID), 21);
  Stream.rwByte(FPreferredRace, 22);
  Stream.rwData(FMapValidation, SizeOf(FMapValidation), 23);
  Stream.rwInteger(FVersion, 24);
end;

function TRemotePlayerList.GetPlayers(Index: Integer): TRemotePlayer;
begin
  Result := TRemotePlayer(FChildren.List^[Index]);
end;

function TRemotePlayerList.IndexOfRemoteID(RemoteID: Integer): Integer;
var I: Integer;
begin
  Result := -1;
  I := 0;
  while (Result = -1) and (I <> FChildren.Count) do
  begin
    if TRemotePlayer(FChildren.List^[I]).FRemoteID = RemoteID then Result := I;
    Inc(I);
  end;
end;

constructor TPlayerSetupSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FStatus := [];
  FBehavior := DefaultBehavior;
  FOriginalBehavior := DefaultOriginalBehavior;
  FLeader := TLeader.Create(nil);
end;

destructor TPlayerSetupSettings.Destroy;
begin
  FLeader.Free;
  FLeader := nil;
  inherited Destroy;
end;

class function TPlayerSetupSettings.ClassID: Integer;
begin Result := $20263; end;

procedure TPlayerSetupSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FPlayerID, 10);
  Stream.rwData(FBehavior, SizeOf(FBehavior), 11);
  Stream.rwByte(Byte(FRace), 12);
  Stream.rwData(FBehaviorMode, SizeOf(FBehaviorMode), 13);
  Stream.rwEObject(FLeader, 14);
  Stream.rwData(FStatus, SizeOf(FStatus), 15);
  Stream.rwData(FOriginalBehavior, SizeOf(FOriginalBehavior), 16);
end;

constructor TSetupSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRemotePlayers := TRemotePlayerList.Create(nil);
  Reset;
end;

destructor TSetupSettings.Destroy;
begin
  FRemotePlayers.Free;
  inherited Destroy;
end;

procedure TSetupSettings.Reset;
begin
  Clear;
  FTacticalCombatAvailability := 1;
  FCustomizeLeaders := False;
  FTurnTime := 0;
  FDayLimit := 0;
  FPlayMode := 2;
  FExplorationEnabled := True;
  FLeadersOnMap := True;
  FRemotePlayers.Clear;
  FMapName := '';
  FFileName := '';
  FAlwaysViewTC := False;
end;

class function TSetupSettings.ClassID: Integer;
begin Result := $20260; end;

function TSetupSettings.GetSettings(Index: Integer): TPlayerSetupSettings;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TPlayerSetupSettings(FChildren.List^[Index])
  else Result := nil;
end;

function TSetupSettings.IndexOfPlayer(Player: Byte): Integer;
var I: Integer;
begin
  Result := -1;
  I := 0;
  while (Result = -1) and (I <> FChildren.Count) do
  begin
    if TPlayerSetupSettings(FChildren.List^[I]).FPlayerID = Player then Result := I;
    Inc(I);
  end;
end;

function TSetupSettings.IndexOfRemoteID(RemoteID: Integer): Integer;
var I: Integer;
begin
  Result := -1;
  I := 0;
  while (Result = -1) and (I <> FChildren.Count) do
  begin
    if TPlayerSetupSettings(FChildren.List^[I]).FBehavior.Flags = RemoteID then Result := I;
    Inc(I);
  end;
end;

function TSetupSettings.IndexOfRace(Race: Byte): Integer;
var I: Integer;
begin
  Result := -1;
  I := 0;
  while (Result = -1) and (I <> FChildren.Count) do
  begin
    if Race = Byte(TPlayerSetupSettings(FChildren.List^[I]).FRace) then Result := I;
    Inc(I);
  end;
end;

procedure TSetupSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FFileName, 10);
  Stream.rwData(FPlayMode, 1, 11);
  Stream.rwBool(FExplorationEnabled, 12);
  Stream.rwString(FMapName, 13);
  Stream.rwData(FVictoryCondition, 1, 14);
  Stream.rwData(FIndependentAIMode, 1, 15);
  Stream.rwBool(FCustomizeLeaders, 16);
  Stream.rwInteger(FRandomSeed, 17);
  Stream.rwBool(FLeadersOnMap, 18);
  Stream.rwInteger(FDayLimit, 19);
  Stream.rwInteger(FTurnTime, 20);
  Stream.rwEObject(FRemotePlayers, 21);
  Stream.rwInteger(FHostRemoteID, 22);
  Stream.rwInteger(FMapDay, 23);
  Stream.rwBool(FAlliedVictory, 24);
  Stream.rwData(FConnectionType, 1, 25);
  Stream.rwInteger(FMapCRC, 26);
  Stream.rwInteger(FSetCRC, 27);
  Stream.rwData(FTacticalCombatAvailability, 1, 28);
  Stream.rwBool(FAlwaysViewTC, 29);
end;

function TCustomizeLeaderControl.Done: Boolean; assembler;
asm
  { needs: TLeaderSetupControl.Done returns Boolean (557DF7EA); its draft is a procedure. }
  mov edx, eax
  mov eax, [eax+$28]
  call TSetupControl.LeaderCustomized
  mov al, 1
end;

constructor TSetupControl.Create(AOwner: Classes.TComponent); { Near miss: single-use player local is optimized away after three variants. }
var Player: TRemotePlayer;
begin
  inherited Create(AOwner);
  FSettings := TSetupSettings.Create(nil);
  Player := TRemotePlayer.Create(nil);
  FRemotePlayer := Player;
  Player.FRemoteID := 0;
  Player.FPreferredRace := 255;
  FStream := TMemoryStream.Create;
end;

destructor TSetupControl.Destroy;
begin
  FSettings.Free;
  FRemotePlayer.Free;
  FStream.Free;
  inherited Destroy;
end;

procedure TSetupControl.SendData(Data: Pointer; Size, Recipient: Integer);
begin
  if Assigned(FOnSendData) then FOnSendData(Data, Size, Recipient);
end;

procedure TSetupControl.SendPackage(Package: TSetupPackage; Recipient: Integer);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    AoWEngine.StoreEObject(Stream, Package, nil);
    SendData(Stream.Memory, Stream.Size, Recipient);
    AoWEngine.OutputDebugMessage(NetworkEngineDID, 'SetupPackage Send (ID:' + IntToStr(Package.FMessageID) +
      '/Size:' + IntToStr(Stream.Size) + ') to ' + IntToStr(Recipient));
  finally
    Stream.Free;
  end;
end;

procedure TSetupControl.SendMessage(MessageID: Integer; Obj: TEObject; Param2, Param1, Recipient: Integer);
var
  Package: TSetupPackage;
begin
  if GetRemote then
  begin
    Package := TSetupPackage.Create(nil);
    Package.FMessageID := MessageID;
    if Obj <> nil then Package.FData := Obj.Copy(AoWEngine);
    Package.FParam2 := Param2;
    Package.FParam1 := Param1;
    SendPackage(Package, Recipient);
    Package.Free;
  end;
end;

procedure TSetupControl.SendHostMessage(MessageID: Integer; Obj: TEObject; Param2, Param1: Integer);
var
  Package: TSetupPackage;
begin
  if GetRemote then
  begin
    Package := TSetupPackage.Create(nil);
    Package.FMessageID := MessageID;
    if Obj <> nil then Package.FData := Obj.Copy(AoWEngine);
    Package.FParam2 := Param2;
    Package.FParam1 := Param1;
    if not GetHost then SendPackage(Package, 0)
    else PackageReceived(Package, FRemotePlayer.FRemoteID);
    Package.Free;
  end;
end;

procedure TSetupControl.DataReceived(Data: Pointer; Size, SenderID: Integer);
var Obj: TEObject; Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  Stream.Size := Size;
  Move(Data^, Stream.Memory^, Size);
  Stream.Position := 0;
  try
    Obj := AoWEngine.RetrieveEObject(Stream, nil);
    if Obj is TSetupPackage then
    begin
      AoWEngine.OutputDebugMessage(NetworkEngineDID, 'SetupPackage Received (ID:' + IntToStr(TSetupPackage(Obj).FMessageID) +
        '/Size:' + IntToStr(Stream.Size) + ') from ' + IntToStr(SenderID));
      PackageReceived(TSetupPackage(Obj), SenderID);
    end;
    Obj.Free;
  except Stream.Free; { Original swallows the exception and frees the stream again below. }
  end;
  Stream.Free;
end;

function TSetupControl.ValidateCompatibleVersion(Version: Integer): Boolean;
var Major: Integer;
begin
  Major := AoWEngine.FVersion and $FFFF0000 shr 16;
  Version := Version and $FFFF0000 shr 16; Result := Major = Version;
end;

procedure TSetupControl.hConnectPlayer(Player: TRemotePlayer);
begin
  if (FPhase = spSetupPlayers) and (ValidateCompatibleVersion(Player.FVersion) or (FRemotePlayer.FRemoteID = Player.FRemoteID)) then
  begin
    if FSettings.FRemotePlayers.IndexOfRemoteID(Player.FRemoteID) = -1 then
    begin
      Player := TRemotePlayer(Player.Copy(AoWEngine));
      Player.FName := ValidatePlayerName(Player.FName);
      Player.FMapValidation := mviUnknown;
      Player.SetOwner(FSettings.FRemotePlayers);
      UpdateSettings;
    end;
  end else
    if ((Player.FVersion shr 24) = 1) and (((Player.FVersion shr 16) and $FF) <= 10) then
    begin
      if Assigned(FOnEjectPlayer) then FOnEjectPlayer(Self, Player.FRemoteID);
    end else SendMessage(9, nil, MajorVersion(AoWEngine), MinorVersion(AoWEngine), Player.FRemoteID);
end;

procedure TSetupControl.hDisconnectPlayer(RemoteID: Integer);
var I, J: Integer;
begin
  I := FSettings.FRemotePlayers.IndexOfRemoteID(RemoteID);
  if I <> -1 then
  begin
    J := FSettings.IndexOfRemoteID(RemoteID);
    if J <> -1 then ResetPlayerSettings(J);
    FSettings.FRemotePlayers.GetPlayers(I).Free;
    UpdateSettings;
  end;
end;

procedure TSetupControl.hUpdatePlayer(Player: TRemotePlayer);
var I: Integer;
begin
  I := FSettings.FRemotePlayers.IndexOfRemoteID(Player.FRemoteID);
  if I <> -1 then
  begin
    FSettings.FRemotePlayers.GetPlayers(I).Assign(Player, AoWEngine);
    FSettings.FRemotePlayers.GetPlayers(I).FName := '';
    FSettings.FRemotePlayers.GetPlayers(I).FName := ValidatePlayerName(Player.FName);
    UpdatePreferredRaces;
    UpdateSettings;
  end;
end;

function TSetupControl.CanSetHostRemoteID(RemoteID: Integer): Boolean;
var I: Integer;
begin
  if GetHost and (RemoteID <> FSettings.FHostRemoteID) then
  begin
    I := FSettings.FRemotePlayers.IndexOfRemoteID(RemoteID);
    if I <> -1 then Result := FSettings.FRemotePlayers.GetPlayers(I).FMapValidation = mviValid
    else begin Result := False; Exit; end;
  end else Result := False;
end;

procedure TSetupControl.hSetHostRemoteID(RemoteID: Integer);
begin
  if CanSetHostRemoteID(RemoteID) then
  begin
    FSettings.FHostRemoteID := RemoteID;
    if GetRemote then SendMessage(4, FSettings, 0, 0, 0);
    if Assigned(FOnSettingChanged) then FOnSettingChanged(Self);
  end;
end;

procedure TSetupControl.ValidateMap;
var FileName: string; Validation: TMapValidationInfo;
begin
  if (FSettings.FMapName <> '') and (FRemotePlayer.FMapValidation <> mviValid) then
  begin
    if AoWHSSet.FHSSCRC = FSettings.FSetCRC then
    begin
      FileName := AoWEngine.StartupDirectory + FSettings.FMapName;
      if FileExists(FileName) then
        if GetFileCRC32(FileName) = FSettings.FMapCRC then Validation := mviValid
        else Validation := mviInvalidMap
      else Validation := mviInvalidMap;
    end else Validation := mviInvalid;
    if (Validation = mviInvalidMap) and (FStream.Size <> 0) and
      (GetCRC32(FStream.Memory, FStream.Size) = FSettings.FMapCRC) then Validation := mviValid;
    if Validation <> FRemotePlayer.FMapValidation then
    begin
      FRemotePlayer.FMapValidation := Validation;
      SendHostMessage(3, FRemotePlayer, 0, 0);
    end;
  end;
end;

procedure TSetupControl.PackageReceived(Package: TSetupPackage; SenderID: Integer);
var I: Integer;
begin
  case Package.FMessageID of
    1: hConnectPlayer(TRemotePlayer(Package.FData));
    2: if GetHost then hDisconnectPlayer(Package.FParam2);
    3: if GetHost then hUpdatePlayer(TRemotePlayer(Package.FData));
    4: if not GetHost and (FPhase = spSetupPlayers) then
      begin
        FSettings.Assign(Package.FData, AoWEngine);
        I := FSettings.FRemotePlayers.IndexOfRemoteID(FRemotePlayer.FRemoteID);
        if I <> -1 then
        begin
          FRemotePlayer.FName := FSettings.FRemotePlayers.GetPlayers(I).FName;
          FRemotePlayer.FPreferredRace := FSettings.FRemotePlayers.GetPlayers(I).FPreferredRace;
          FRemotePlayer.FMapValidation := FSettings.FRemotePlayers.GetPlayers(I).FMapValidation;
          if FRemotePlayer.FMapValidation = mviUnknown then ValidateMap;
        end;
        if Assigned(FOnSettingChanged) then FOnSettingChanged(Self);
      end;
    5: if not GetHost then
      begin
        FSettings.Assign(Package.FData, AoWEngine);
        I := FSettings.FRemotePlayers.IndexOfRemoteID(FRemotePlayer.FRemoteID);
        if I <> -1 then
        begin
          FRemotePlayer.FName := FSettings.FRemotePlayers.GetPlayers(I).FName;
          FRemotePlayer.FPreferredRace := FSettings.FRemotePlayers.GetPlayers(I).FPreferredRace;
          FRemotePlayer.FMapValidation := FSettings.FRemotePlayers.GetPlayers(I).FMapValidation;
          if FRemotePlayer.FMapValidation = mviUnknown then ValidateMap;
          if Assigned(FOnSettingChanged) then FOnSettingChanged(Self);
          LoadMap;
        end;
      end;
    8: if GetHost then hLeaderCustomized(Package.FParam2, TLeader(Package.FData));
    7: if GetHost then hMapLoaded(Package.FParam2);
    6: if not GetHost then
      begin
        FSettings.Assign(Package.FData, AoWEngine);
        SetupMap;
      end;
    10: if not GetHost then
      begin
        FPhase := spSendMap;
        if Assigned(FOnSendingMaps) then FOnSendingMaps(Self);
      end;
    11: if GetHost and hValidateSendMap then
      begin
        SendMessage(5, FSettings, 0, 0, 0);
        LoadMap;
      end;
    9: if not GetHost then
         if Assigned(FOnIncompatibleVersion) then FOnIncompatibleVersion(Self, Package.FParam2, Package.FParam1);
  end;
end;

procedure TSetupControl.LoadMap;
begin
  FPhase := spLoadMap;
  if Assigned(FOnLoadMap) then FOnLoadMap(Self, AoWEngine.StartupDirectory + FSettings.FMapName);
end;

function TSetupControl.hValidateSendMap: Boolean;
var Stream: TMemoryStream; I, RemoteID, J: Integer;
begin
  I := FSettings.Count;
  RemoteID := 0;
  while (I <> 0) and (RemoteID = 0) do
  begin
    Dec(I);
    if (FSettings.GetSettings(I).FBehavior.PlayerType = 0) and GetRemote and
      (FSettings.GetSettings(I).FBehavior.Flags <> FRemotePlayer.FRemoteID) then
    begin
      J := FSettings.FRemotePlayers.IndexOfRemoteID(FSettings.GetSettings(I).FBehavior.Flags);
      if (J <> -1) and (FSettings.FRemotePlayers.GetPlayers(J).FMapValidation = mviInvalidMap) then
        RemoteID := FSettings.GetSettings(I).FBehavior.Flags;
    end;
  end;
  if RemoteID <> 0 then
  begin
    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(AoWEngine.StartupDirectory + FSettings.FMapName);
    if Assigned(FOnSendMap) then FOnSendMap(Self, Stream.Memory, Stream.Size, RemoteID);
    Stream.Free;
    Result := False;
  end else Result := True;
end;

procedure TSetupControl.hSendMap;
begin
  FPhase := spSendMap;
  if Assigned(FOnSendingMaps) then FOnSendingMaps(Self);
  SendMessage(10, FSettings, 0, 0, 0);
  if hValidateSendMap then
  begin
    SendMessage(5, FSettings, 0, 0, 0);
    LoadMap;
  end;
end;

procedure TSetupControl.MapReceived(Data: Pointer; Size: Integer);
begin
  if not GetHost then
  begin
    FStream.Size := Size;
    Move(Data^, FStream.Memory^, Size);
    ValidateMap;
    SendHostMessage(11, FRemotePlayer, 0, 0);
  end;
end;

procedure TSetupControl.hMapLoaded(Index: Integer);
begin
  if GetHost then
  begin
    FSettings.GetSettings(Index).FStatus := FSettings.GetSettings(Index).FStatus + [pssLoaded];
    if not hValidateSetupMap then UpdateSettings;
  end;
end;

procedure TSetupControl.MapLoaded;
var I: Integer;
begin
  if (FSettings.FMapDay <> 0) or not FSettings.FCustomizeLeaders then
  begin
    FPhase := spSynchronize;
    if Assigned(FOnSynchronize) then FOnSynchronize(Self);
  end;
  if GetRemote then
  begin
    I := FSettings.IndexOfRemoteID(FRemotePlayer.FRemoteID);
    if GetHost then hMapLoaded(I) else SendHostMessage(7, nil, I, 0);
  end else
  begin
    for I := 0 to FSettings.Count - 1 do
      if FSettings.GetSettings(I).FBehavior.PlayerType = 0 then
        FSettings.GetSettings(I).FStatus := FSettings.GetSettings(I).FStatus + [pssLoaded];
    if not hValidateSetupMap then UpdateSettings;
  end;
  if (FSettings.FMapDay = 0) and FSettings.FCustomizeLeaders then CustomizeLeaders;
end;
procedure TSetupControl.hLeaderCustomized(Index: Integer; Leader: TLeader);
begin
  if GetHost then
  begin
    FSettings.GetSettings(Index).FLeader.Assign(Leader, AoWEngine);
    FSettings.GetSettings(Index).FStatus := FSettings.GetSettings(Index).FStatus + [pssLeaderCustomized];
    if not hValidateSetupMap then UpdateSettings;
  end;
end;
function TSetupControl.CustomizeLeaders: Boolean;
var Found: Boolean; I: Integer; CLC: TCustomizeLeaderControl;
begin
  FPhase := spCustomizeLeaders;
  Result := False;
  Found := False;
  I := 0;
  while not Found and (I <> FSettings.Count) do
  begin
    Found := (FSettings.GetSettings(I).FBehavior.PlayerType = 0) and
      (not GetRemote or (FSettings.GetSettings(I).FBehavior.Flags = FRemotePlayer.FRemoteID)) and
      not (pssLeaderCustomized in FSettings.GetSettings(I).FStatus);
    if not Found then Inc(I);
  end;
  if Found then
  begin
    CLC := TCustomizeLeaderControl.Create(nil);
    CLC.FSetupControl := Self;
    CLC.FPlayerIndex := I;
    TLeaderSetupView(CLC).Races.Add(Shortint(FSettings.GetSettings(I).FRace));
    TLeaderSetupView(CLC).OriginalLeader.Assign(FSettings.GetSettings(I).FLeader, AoWEngine);
    TLeaderSetupView(CLC).Leader.Assign(FSettings.GetSettings(I).FLeader, AoWEngine);
    if GetRemote then
    begin
      TSetupHeroView(TLeaderSetupView(CLC).OriginalLeader).Name := FRemotePlayer.FName;
      TSetupHeroView(TLeaderSetupView(CLC).Leader).Name := FRemotePlayer.FName;
    end;
    if not FSettings.FLeadersOnMap then TLeaderSetupView(CLC).Options := TLeaderSetupView(CLC).Options - [1];
    if Assigned(FOnCustomizeLeader) then
    begin
      FOnCustomizeLeader(Self, CLC);
      Result := True;
    end;
    CLC.Release;
  end else
  begin
    FPhase := spSynchronize;
    if Assigned(FOnSynchronize) then FOnSynchronize(Self);
  end;
end;
procedure TSetupControl.LeaderCustomized(Control: TCustomizeLeaderControl);
begin
  if not GetHost then
  begin
    SendHostMessage(8, Control.FOriginalLeader, Control.FPlayerIndex, 0);
    FSettings.GetSettings(Control.FPlayerIndex).FLeader.Assign(Control.FOriginalLeader, AoWEngine);
  end else hLeaderCustomized(Control.FPlayerIndex, Control.FOriginalLeader);
  if ssBusy in FStatus then
  begin
    FSettings.GetSettings(Control.FPlayerIndex).FStatus := FSettings.GetSettings(Control.FPlayerIndex).FStatus + [pssLeaderCustomized];
    CustomizeLeaders;
  end;
end;
procedure TSetupControl.ListPCCInfo(PCC: TPlayerCommunicationControl);
var I: Integer; S: string;
begin
  for I := 0 to PCC.Count - 1 do
  begin
    S := 'Player (' + IntToStr(I) + ') at system:' + IntToStr(PCC.Players[I].SystemID) + ' CM:';
    case PCC.Players[I].ConnectionMode of
      cmGlobal: S := S + 'Global';
      cmLocal: S := S + 'Local';
      cmRemote: S := S + 'Remote';
    end;
    AoWEngine.OutputDebugMessage(NetworkEngineDID, S);
  end;
end;
procedure TSetupControl.RemoveIndependentPlayers;
var I, J: Integer; Player: TPlayer; begin for I := AoWHSMap.FPlayers.GetCount - 1 downto 1 do begin Player := AoWHSMap.FPlayers.GetPlayers(I); if Player.FPlayerType = ptIndependent then begin for J := Player.FStructures.GetCount - 1 downto 0 do Player.FStructures.GetStructure(J).SetPlayer(0); for J := Player.FArmies.GetCount - 1 downto 0 do Player.FArmies.GetArmy(J).SetPlayer(0); Player.FLeader.SetOwner(nil); Player.FStatus := psTerminated; end; end; end;

procedure TSetupControl.SetupMap;
var I, Index: Integer; Player: TPlayer; RemotePCC: TRemotePCC; LocalPCC: TLocalPCC; begin FPhase := spSetupMap; for I := 0 to FSettings.GetCount - 1 do begin Player := AoWHSMap.FPlayers.GetPlayers(Shortint(FSettings.GetSettings(I).FPlayerID)); Player.FPlayerType := TPlayerType(FSettings.GetSettings(I).FBehavior.PlayerType); Player.FBehavior := TPlayerBehavior(FSettings.GetSettings(I).FBehaviorMode); if FSettings.FConnectionType = 2 then begin if
CompareText(FSettings.GetSettings(I).FEmailAddress, AoWEngine.FRegistry.GetLocalEmailAddress) <> 0 then begin Player.FPBEMSettings.FEmailGame.FEmailAddress := FSettings.GetSettings(I).FEmailAddress; Player.FPBEMSettings.FEmailGame.FName := FSettings.FEmailGameName; end else Player.FPBEMSettings.SetGame(AoWEngine.FEmailGames.CreateEmailGame( FSettings.FEmailGameName, FSettings.GetSettings(I).FEmailAddress)); end; if FSettings.FMapDay = 0 then begin Player.FLeader.UpdateFromLibraryBegin;
Player.FLeader.Assign(FSettings.GetSettings(I).FLeader, AoWEngine); Player.FLeader.UpdateFromLibraryEnd; end; if GetRemote then if (FSettings.GetSettings(I).FBehavior.PlayerType = 0) and ((FSettings.FMapDay <> 0) or not FSettings.FCustomizeLeaders) then begin Index := FSettings.FRemotePlayers.IndexOfRemoteID(FSettings.GetSettings(I).FBehavior.Flags); if Index <> -1 then Player.FLeader.FHeroName := FSettings.FRemotePlayers.GetPlayers(Index).FName; end; end; AoWHSMap.FConnectionType :=
TPlayerConnectionType(FSettings.FConnectionType); if GetRemote then begin RemotePCC := TRemotePCC.Create; RemotePCC.Setup(AoWHSMap.FPlayers.GetCount, FRemotePlayer.FRemoteID); RemotePCC.SetConnectionMode(0, cmGlobal); RemotePCC.SetSystemID(0, FRemotePlayer.FRemoteID); for I := 0 to FSettings.GetCount - 1 do if FSettings.GetSettings(I).FBehavior.PlayerType <> 0 then begin RemotePCC.SetConnectionMode(Shortint(FSettings.GetSettings(I).FPlayerID), cmGlobal);
RemotePCC.SetSystemID(Shortint(FSettings.GetSettings(I).FPlayerID), FRemotePlayer.FRemoteID); end else begin if FSettings.GetSettings(I).FBehavior.Flags = FRemotePlayer.FRemoteID then RemotePCC.SetConnectionMode(Shortint(FSettings.GetSettings(I).FPlayerID), cmLocal) else RemotePCC.SetConnectionMode(Shortint(FSettings.GetSettings(I).FPlayerID), cmRemote); RemotePCC.SetSystemID(Shortint(FSettings.GetSettings(I).FPlayerID), FSettings.GetSettings(I).FBehavior.Flags); end;
AoWHSMap.FPlayerCommunicator.ActivatePCC(RemotePCC); RemotePCC.OnSendData := FOnSendData; ListPCCInfo(RemotePCC); RemotePCC.Release; end else begin LocalPCC := TLocalPCC.Create; LocalPCC.Setup(AoWHSMap.FPlayers.GetCount); LocalPCC.SetConnectionMode(0, cmGlobal); for I := 0 to FSettings.GetCount - 1 do if FSettings.GetSettings(I).FBehavior.PlayerType = 0 then LocalPCC.SetConnectionMode(Shortint(FSettings.GetSettings(I).FPlayerID), cmLocal) else
LocalPCC.SetConnectionMode(Shortint(FSettings.GetSettings(I).FPlayerID), cmGlobal); AoWHSMap.FPlayerCommunicator.ActivatePCC(LocalPCC); ListPCCInfo(LocalPCC); LocalPCC.Release; end; if FSettings.FMapDay = 0 then begin AoWHSMap.FInitialRandomSeed := FSettings.FRandomSeed; AoWHSMap.FFixedLeaders := FSettings.FLeadersOnMap; AoWHSMap.FAlliedVictory := FSettings.FAlliedVictory; AoWHSMap.SetExplorationEnabled(FSettings.FExplorationEnabled); AoWHSMap.SetFogEnabled(True); end; AoWHSMap.FDayLimit :=
FSettings.FDayLimit; AoWHSMap.FTurnTime := FSettings.FTurnTime; AoWHSMap.FVictoryMode := FSettings.FTacticalCombatAvailability; AoWHSMap.FLeadersFixed := FSettings.FCustomizeLeaders; AoWHSMap.FStartingGame := FSettings.FAlwaysViewTC; RemoveIndependentPlayers; AoWHSMap.SetupPlayerControl(TPlayMode(FSettings.FPlayMode), TPlayerConnectionType(FSettings.FConnectionType)); if Assigned(FOnSetupMap) then try FOnSetupMap(Self); except end; Reset; if Assigned(FOnStart) then try FOnStart(Self); except
end; end;

function TSetupControl.hValidateSetupMap: Boolean;
var I: Integer;
begin
  if GetHost then
  begin
    Result := True;
    I := FSettings.Count;
    while Result and (I <> 0) do
    begin
      Dec(I);
      if FSettings.GetSettings(I).FBehavior.PlayerType = 0 then
        Result := (pssLoaded in FSettings.GetSettings(I).FStatus) and
          (not FSettings.FCustomizeLeaders or (pssLeaderCustomized in FSettings.GetSettings(I).FStatus));
    end;
    if Result then
    begin
      SendMessage(6, FSettings, 0, 0, 0);
      SetupMap;
    end;
  end else Result := False;
end;
procedure TSetupControl.UpdateSettings;
begin
  if (FUpdateCount = 0) and GetHost then
  begin
    Inc(FUpdateCount);
    if GetRemote then SendMessage(4, FSettings, 0, 0, 0);
    if Assigned(FOnSettingChanged) then FOnSettingChanged(Self);
    Dec(FUpdateCount);
  end;
end;
procedure TSetupControl.BeginUpdate;
begin
  Inc(FUpdateCount);
end;
procedure TSetupControl.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then UpdateSettings;
end;
function TSetupControl.GetRemote: Boolean;
begin
  Result := ssRemote in FStatus;
end;
function TSetupControl.GetHost: Boolean;
begin
  Result := FSettings.FHostRemoteID = FRemotePlayer.FRemoteID;
end;
procedure TSetupControl.Reset;
begin
  FPhase := spIdle;
  FStatus := [];
  FRemotePlayer.FName := '';
  FRemotePlayer.FMapValidation := mviUnknown;
  FRemotePlayer.FPreferredRace := 255;
  FSettings.Reset;
  FStream.Clear;
end;
procedure TSetupControl.Disconnect;
begin
  SendHostMessage(2, nil, FRemotePlayer.FRemoteID, 0);
end;
function TSetupControl.GetPlayerName: string;
begin
  Result := FRemotePlayer.FName;
end;
procedure TSetupControl.SetPlayerName(Value: string);
begin
  if Value <> FRemotePlayer.FName then
  begin
    FRemotePlayer.FName := Value;
    SendHostMessage(3, FRemotePlayer, 0, 0);
  end;
end;
function TSetupControl.GetPreferredRace: Shortint;
begin
  Result := Shortint(FRemotePlayer.FPreferredRace);
end;
procedure TSetupControl.SetPreferredRace(Value: Byte);
begin
  if Value <> FRemotePlayer.FPreferredRace then
  begin
    FRemotePlayer.FPreferredRace := Value;
    SendHostMessage(3, FRemotePlayer, 0, 0);
  end;
end;
procedure TSetupControl.ListAvailablePlayers(List: TStrings);
var I: Integer;
begin
  if GetRemote then
  begin
    List.Add(TranslateRStr(TPlayerTypeRStr[5]));
    for I := 0 to FSettings.FRemotePlayers.Count - 1 do List.Add(FSettings.FRemotePlayers.GetPlayers(I).FName);
    List.Add(TranslateRStr(TPlayerTypeRStr[1]));
    List.Add(TranslateRStr(TPlayerTypeRStr[2]));
    List.Add(TranslateRStr(TPlayerTypeRStr[3]));
    List.Add(TranslateRStr(TPlayerTypeRStr[6]));
    List.Add(TranslateRStr(TPlayerTypeRStr[7]));
    List.Add(TranslateRStr(TPlayerTypeRStr[4]));
  end
  else
  begin
    List.Add(TranslateRStr(TPlayerTypeRStr[0]));
    List.Add(TranslateRStr(TPlayerTypeRStr[1]));
    List.Add(TranslateRStr(TPlayerTypeRStr[2]));
    List.Add(TranslateRStr(TPlayerTypeRStr[3]));
    List.Add(TranslateRStr(TPlayerTypeRStr[6]));
    List.Add(TranslateRStr(TPlayerTypeRStr[7]));
    List.Add(TranslateRStr(TPlayerTypeRStr[4]));
  end;
end;

function TSetupControl.ValidatePlayerName(const Name: string): string;
var Done: Boolean; List: TStringList; I: Integer; Unique: Boolean;
begin
  List := TStringList.Create;
  ListAvailablePlayers(List);
  Done := False;
  Result := Name;
  while not Done do
  begin
    I := 0;
    Unique := True;
    while (I <> List.Count) and Unique do
    begin
      Unique := CompareText(Result, List[I]) <> 0;
      Inc(I);
    end;
    if not Unique then
      { Original reads the last character without guarding an empty name. }
      if Result[Length(Result)] in ['1'..'8'] then
        Result := Copy(Result, 1, Length(Result) - 1) + IntToStr(Ord(Result[Length(Result)]) + 1 - Ord('0'))
      else Result := Result + '1'
    else Done := True;
  end;
  List.Free;
end;
function TSetupControl.PlayerNameToPlayerID(const Name: string; var Behavior: TSetupPlayerBehavior): Boolean;
var I: Integer; PlayerType: Byte;
begin
  Result := False;
  I := FSettings.FRemotePlayers.Count;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    if CompareText(FSettings.FRemotePlayers.GetPlayers(I).FName, Name) = 0 then
    begin
      Result := True;
      Behavior.PlayerType := 0;
      Behavior.Flags := FSettings.FRemotePlayers.GetPlayers(I).FRemoteID;
    end;
  end;
  if not Result then
  begin
    PlayerType := 0;
    while not Result and (PlayerType <= 7) do
      if CompareText(Name, TranslateRStr(TPlayerTypeRStr[PlayerType])) = 0 then
      begin
        Result := True;
        Behavior.PlayerType := PlayerType;
        Behavior.Flags := 0;
      end else Inc(PlayerType);
  end;
  if not Result then
  begin
    Behavior.PlayerType := 5;
    Behavior.Flags := 0;
  end;
end;
function TSetupControl.GetPlayerSetupValid: Boolean;
var I, J, PlayerCount: Integer; Human: Boolean;
begin
  Human := False;
  PlayerCount := 0;
  Result := FSettings.Count <> 0;
  I := FSettings.Count;
  while Result and (I <> 0) do
  begin
    Dec(I);
    Result := FSettings.GetSettings(I).FBehavior.PlayerType <> 5;
    if FSettings.GetSettings(I).FBehavior.PlayerType in [0..3, 6, 7] then Inc(PlayerCount);
    Human := Human or (FSettings.GetSettings(I).FBehavior.PlayerType = 0);
    if Result and (FSettings.GetSettings(I).FBehavior.PlayerType = 0) and GetRemote then
    begin
      J := FSettings.FRemotePlayers.IndexOfRemoteID(FSettings.GetSettings(I).FBehavior.Flags);
      Result := (J <> -1) and (FSettings.FRemotePlayers.GetPlayers(J).FMapValidation in [mviInvalidMap, mviValid]);
    end;
  end;
  Result := Result and Human and (PlayerCount > 1);
end;
function TSetupControl.GetAllMapsValid: Boolean;
var I, J: Integer;
begin
  I := FSettings.Count;
  Result := True;
  while Result and (I <> 0) do
  begin
    Dec(I);
    Result := True;
    if Result and (FSettings.GetSettings(I).FBehavior.PlayerType = 0) and GetRemote then
    begin
      J := FSettings.FRemotePlayers.IndexOfRemoteID(FSettings.GetSettings(I).FBehavior.Flags);
      if J <> -1 then Result := FSettings.FRemotePlayers.GetPlayers(J).FMapValidation = mviValid;
    end;
  end;
end;
function TSetupControl.hPlayerSetupDone: Boolean;
var I: Integer;
begin
  if GetHost and GetPlayerSetupValid then
  begin
    if Assigned(FOnPlayerSetupDone) then FOnPlayerSetupDone(Self);
    if GetRemote then
      for I := FSettings.FRemotePlayers.Count - 1 downto 0 do
        if FSettings.IndexOfRemoteID(FSettings.FRemotePlayers.GetPlayers(I).FRemoteID) = -1 then
        begin
          if Assigned(FOnEjectPlayer) then FOnEjectPlayer(Self, FSettings.FRemotePlayers.GetPlayers(I).FRemoteID);
          FSettings.FRemotePlayers.GetPlayers(I).Free;
        end;
    if GetAllMapsValid then
    begin
      SendMessage(5, FSettings, 0, 0, 0);
      LoadMap;
    end else hSendMap;
    Result := True;
  end else Result := False;
end;
procedure TSetupControl.hSetPlayerBehavior(Index: Integer; Value: Byte);
begin
  if GetHost and (Value <> FSettings.GetSettings(Index).FBehaviorMode) then
  begin
    FSettings.GetSettings(Index).FBehaviorMode := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetExplorationEnabled(Value: Boolean);
begin
  if GetHost and (Value <> FSettings.FExplorationEnabled) and (FSettings.FMapDay = 0) then
  begin
    FSettings.FExplorationEnabled := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetLeadersOnMap(Value: Boolean);
begin
  if GetHost and (Value <> FSettings.FLeadersOnMap) and (FSettings.FMapDay = 0) then
  begin
    FSettings.FLeadersOnMap := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetTacticalCombatAvailability(Value: Byte);
begin
  if GetHost and (Value <> FSettings.FTacticalCombatAvailability) then
  begin
    FSettings.FTacticalCombatAvailability := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetAlwaysViewTC(Value: Boolean);
begin
  if GetHost and (Value <> FSettings.FAlwaysViewTC) then
  begin
    FSettings.FAlwaysViewTC := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetAlliedVictory(Value: Boolean);
begin
  if GetHost and (Value <> FSettings.FAlliedVictory) and (FSettings.FMapDay = 0) then
  begin
    FSettings.FAlliedVictory := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetCustomizeLeaders(Value: Boolean);
begin
  if GetHost and (Value <> FSettings.FCustomizeLeaders) and (FSettings.FMapDay = 0) then
  begin
    FSettings.FCustomizeLeaders := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetTurnLimitation(Value: Integer);
begin
  if GetHost and (Value <> FSettings.FDayLimit) then
  begin
    FSettings.FDayLimit := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetTurnTimeLimitation(Value: Integer);
begin
  if GetHost and (Value <> FSettings.FTurnTime) then
  begin
    FSettings.FTurnTime := Value;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetPlayerID(Index: Integer; const Behavior: TSetupPlayerBehavior; Forced: Boolean);
var I, PlayerIndex: Integer;
begin
  if GetHost then
  begin
    PlayerIndex := Index; if (FSettings.GetSettings(PlayerIndex).FBehavior.PlayerType = Behavior.PlayerType) and
      (FSettings.GetSettings(PlayerIndex).FBehavior.Flags = Behavior.Flags) then Exit;
    if (Behavior.Flags <> 0) and (FSettings.FRemotePlayers.IndexOfRemoteID(Behavior.Flags) = -1) then Exit;
    if not GetRemote and (FSettings.FPlayMode = 2) and (Behavior.PlayerType = 0) then
      for I := 0 to FSettings.Count - 1 do
        if FSettings.GetSettings(I).FBehavior.PlayerType = 0 then ResetPlayerSettings(I);
    if GetRemote and (Behavior.PlayerType = 0) and (Behavior.Flags <> 0) then
    begin
      I := FSettings.IndexOfRemoteID(Behavior.Flags);
      if I <> -1 then ResetPlayerSettings(I);
    end;
    ResetPlayerSettings(PlayerIndex);
    FSettings.GetSettings(PlayerIndex).FBehavior := Behavior;
    if Forced and (Behavior.PlayerType <> 5) then
      FSettings.GetSettings(PlayerIndex).FStatus := FSettings.GetSettings(PlayerIndex).FStatus + [pssForced]
    else FSettings.GetSettings(PlayerIndex).FStatus := FSettings.GetSettings(PlayerIndex).FStatus - [pssForced];
    UpdatePreferredRaces;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetPlayMode(Value: Byte);
var I: Integer; First: Boolean;
begin
  if GetHost and (Value <> FSettings.FPlayMode) then
  begin
    FSettings.FPlayMode := Value;
    if not GetRemote and (Value = 2) then
    begin
      First := True;
      for I := 0 to FSettings.Count - 1 do
        if FSettings.GetSettings(I).FBehavior.PlayerType = 0 then
        begin
          if not First then ResetPlayerSettings(I);
          First := False;
        end;
    end;
    UpdateSettings;
  end;
end;
procedure TSetupControl.hSetIndependentAIMode(Value: Byte);
begin
  if GetHost and (Value <> FSettings.FIndependentAIMode) then
  begin
    FSettings.FIndependentAIMode := Value;
    UpdateSettings;
  end;
end;
function TSetupControl.hPickMap(const FileName: string): Boolean;
var FirstHuman: Boolean; Settings: TPlayerSetupSettings; Preview: TAoWHSMap; I: Integer; begin Preview := TAoWHSMap(AoWEngine.CreatePreviewHSM(AoWEngine.StartupDirectory + FileName)); if GetHost and (Preview <> nil) and (not AoWEngine.FDemo or Preview.FShowAllPlayers) and (Preview.FConnectionType <> pcEmail) then begin AoWEngine.InitializeHSSet(AoWEngine.StartupDirectory + Preview.HSSFileName, nil); Randomize; FSettings.Clear; FSettings.FMapName := FileName; FSettings.FMapDay
:= Preview.FDay; FSettings.FFileName := Preview.FMapName; FSettings.FMapCRC := GetFileCRC32(AoWEngine.StartupDirectory + FileName); FSettings.FSetCRC := AoWHSSet.FHSSCRC; FSettings.FRandomSeed := RandSeed; FSettings.FVictoryCondition := Ord(Preview.FVictoryCondition); if Preview.FDay <> 0 then begin FSettings.FLeadersOnMap := Preview.FFixedLeaders; FSettings.FAlliedVictory := Preview.FAlliedVictory; FSettings.FTurnTime := Preview.FTurnTime; FSettings.FDayLimit := Preview.FDayLimit;
FSettings.FAlwaysViewTC := Preview.FStartingGame; FSettings.FTacticalCombatAvailability := Preview.FVictoryMode; end; FirstHuman := True; FRemotePlayer.FPreferredRace := $FF; FRemotePlayer.FMapValidation := mviValid; for I := 0 to FSettings.FRemotePlayers.GetCount - 1 do begin FSettings.FRemotePlayers.GetPlayers(I).FPreferredRace := $FF; if FSettings.FRemotePlayers.GetPlayers(I).FRemoteID = FRemotePlayer.FRemoteID then FSettings.FRemotePlayers.GetPlayers(I).FMapValidation := mviValid else
FSettings.FRemotePlayers.GetPlayers(I).FMapValidation := mviUnknown; end; for I := 1 to Preview.FPlayers.GetCount - 1 do begin with Preview.FPlayers.GetPlayers(I) do begin if FStatus <> psTerminated then begin Settings := TPlayerSetupSettings.Create(Self.FSettings); Settings.FPlayerID := I; Settings.FRace := FPlayerRace; Settings.FLeader.Assign(FLeaderSetup, AoWEngine); Settings.FBehaviorMode := Ord(FBehavior); if FParticipating then Settings.FStatus :=
Settings.FStatus + [pssFixed]; if GetRemote and not FParticipating then begin Settings.FBehavior.PlayerType := 5; Settings.FOriginalBehavior.PlayerType := 5; end else begin Settings.FBehavior.PlayerType := Ord(FPlayerType); Settings.FOriginalBehavior.PlayerType := Ord(FPlayerType); if FPlayerType = ptHuman then begin if not FirstHuman then Settings.FBehavior.PlayerType := 1; FirstHuman := False; end; end; end; end; end; UpdateSettings; Preview.Free; Result := True; end
else Result := False; { Original leaks a rejected preview map. } end;

procedure TSetupControl.hEjectPlayer(RemoteID: Integer);
var I, J: Integer;
begin
  if GetHost and GetRemote and (RemoteID <> 0) then
  begin
    I := FSettings.FRemotePlayers.IndexOfRemoteID(RemoteID);
    if I <> -1 then
    begin
      FSettings.FRemotePlayers.GetPlayers(I).Free;
      if Assigned(FOnEjectPlayer) then FOnEjectPlayer(Self, RemoteID);
      J := FSettings.IndexOfRemoteID(RemoteID);
      if J <> -1 then
      begin
        ResetPlayerSettings(J);
        UpdatePreferredRaces;
      end;
      UpdateSettings;
    end;
  end;
end;
function TSetupControl.SetupHost(const Name: string; Mode: Byte; RemoteID: Integer): Boolean;
begin
  Reset;
  FPhase := spSetupPlayers;
  with FSettings do
  begin
    FHostRemoteID := RemoteID;
    FConnectionType := Mode;
    case Mode of
      2: FPlayMode := 1;
      else FPlayMode := 2;
    end;
  end;
  FRemotePlayer.FName := ValidatePlayerName(Name);
  with FRemotePlayer do
  begin
    FRemoteID := RemoteID;
    FPreferredRace := 255;
    FVersion := AoWEngine.FVersion;
  end;
  FStatus := FStatus + [ssBusy];
  if RemoteID <> 0 then
  begin
    hConnectPlayer(FRemotePlayer);
    FStatus := FStatus + [ssRemote];
  end;
  Result := True;
end;
function TSetupControl.SetupUser(const Name: string; RemoteID: Integer): Boolean;
begin
  Reset;
  FRemotePlayer.FName := Name;
  FRemotePlayer.FRemoteID := RemoteID;
  FRemotePlayer.FPreferredRace := 255;
  FRemotePlayer.FVersion := AoWEngine.FVersion;
  FStatus := FStatus + [ssBusy, ssRemote];
  SendHostMessage(1, FRemotePlayer, 0, 0);
  FPhase := spSetupPlayers;
  Result := True;
end;
procedure TSetupControl.ResetPlayerSettings(Index: Integer);
begin
  Assert(GetHost);
  if not GetRemote then
    if FSettings.GetSettings(Index).FOriginalBehavior.PlayerType <> 0 then
      FSettings.GetSettings(Index).FBehavior := FSettings.GetSettings(Index).FOriginalBehavior
    else FSettings.GetSettings(Index).FBehavior := CPUBehavior
  else FSettings.GetSettings(Index).FBehavior := FreeBehavior;
  FSettings.GetSettings(Index).FStatus := FSettings.GetSettings(Index).FStatus - [pssForced];
end;



function TSetupControl.UpdatePreferredRaces: Boolean;
var I, Target, Old, Race: Integer; Again: Boolean;
begin
  Assert(GetHost);
  Again := True;
  Result := False;
  while Again do
  begin
    Again := False;
    for I := 0 to FSettings.FRemotePlayers.Count - 1 do
    begin
      Race := Shortint(FSettings.FRemotePlayers.GetPlayers(I).FPreferredRace);
      if Race <> -1 then
      begin
        Target := FSettings.IndexOfRace(Race);
        if (Target <> -1) and (FSettings.GetSettings(Target).FBehavior.Flags = 0) and
          ((FSettings.GetSettings(Target).FStatus * [pssFixed, pssForced]) = []) then
        begin
          Old := FSettings.IndexOfRemoteID(FSettings.FRemotePlayers.GetPlayers(I).FRemoteID);
          if (Old = -1) or not (pssForced in FSettings.GetSettings(Old).FStatus) then
          begin
            if Old <> -1 then
            begin
              ResetPlayerSettings(Old);
              Again := True;
            end;
            FSettings.GetSettings(Target).FBehavior.PlayerType := 0;
            FSettings.GetSettings(Target).FBehavior.Flags := FSettings.FRemotePlayers.GetPlayers(I).FRemoteID;
            Result := True;
          end;
        end;
      end else
      begin
        Old := FSettings.IndexOfRemoteID(FSettings.FRemotePlayers.GetPlayers(I).FRemoteID);
        if (Old <> -1) and not (pssForced in FSettings.GetSettings(Old).FStatus) then
        begin
          ResetPlayerSettings(Old);
          Again := True;
        end;
      end;
    end;
  end;
end;


procedure RegisterSetupClasses(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TSetupSettings, TPlayerSetupSettings, TSetupPackage, TRemotePlayer]);
end;

procedure Register;
begin RegisterComponents('AoW', [TSetupControl]); end;


initialization
finalization

end.
