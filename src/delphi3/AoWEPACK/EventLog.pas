unit EventLog;

{ EventLog from AoWEPACK.dpl, recovered against Delphi 3.02.
  Instance layouts and callback signatures follow the original code.
  Remaining byte differences are register, branch, and Assert layout choices. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TEventLog = class;
  TTextEventLog = class;
  TLocationTextEventLog = class;
  TMessageEventLog = class;
  THelpMessageEventLog = class;
  TExecuteEventLogCallBackList = class;
  TEventLogList = class;
  TEventLogbook = class;
  TUserEventLog = class;
  TEndTurnEventLog = class;
  TShowMessageEventLog = class;
  TGameOverEventLog = class;
  TNewDayEventLog = class;
  TShowBookEventLog = class;
  TTutorialMessageEventLog = class;
  TSaveGameEventLog = class;
  TPasswordEventLog = class;

  TExecuteDoneEvent = procedure(Log: TEventLog) of object;
  PExecuteEventLogInfo = ^TExecuteEventLogInfo;
  TExecuteEventLogInfo = record
    Log: TEventLog; { $00 }
    Done: TExecuteDoneEvent; { $04 }
    Immediate: Boolean; { $0C; size $10 }
  end;
  TExecuteTrigger = (etEvent, etUser, etNewTurn);  { ot=1 }
  TExecuteTriggers = set of TExecuteTrigger; { ot=1 }
  TMessageEventLogButtons = (mebOk, mebOkCancel, mebYesNo, mebYesNoCancel);  { ot=1 }
  TPressedEventLogButton = (pebNone, pebOk, pebCancel, pebYes, pebNo);  { ot=1 }
  TMessageEventLogLayout = (melNormal, melHeader);  { ot=1 }
  TSaveGameEventLogMode = set of (sgmDisableCancel); { ot=1 }

  { TEventLog: size $18; $08 day, $0C unique ID, $10 player,
    $14 reference count. VMT 557FC1C8. }
  TEventLog = class(TEObject)
  public
    FDay: Integer; { $08 }
    FID: Integer; { $0C }
    FPlayer: Shortint;  { $10 }
    F_EventLog_11: array[0..2] of Byte;
    FRefCount: Integer; { $14 }
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetText: string; virtual;  { $04C }
    function GetTextColor: TColor; virtual;  { $050 }
    function GetLeftIcon: Integer; virtual;  { $054 }
    function GetMiddleIcon: Integer; virtual;  { $058 }
    function GetRightIcon: Integer; virtual;  { $05C }
    function GetVisible: Boolean; virtual;  { $060 }
    procedure GetLocation(var X, Y, L: Shortint); virtual; { $064 }
    procedure PlayLoggedSFX(A1: TEventLogbook); virtual; { $068 }
    procedure NotifyLogged(A1: TEventLogbook); virtual; { $06C }
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; virtual;
    procedure ViewLocation; virtual; { +074 }
    procedure CenterViewTo(X, Y, L: Shortint);
  end;

  { TTextEventLog: size $1C; $18 text. VMT 557FC564. }
  TTextEventLog = class(TEventLog)
  public
    FText: string;  { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
  end;

  { TLocationTextEventLog: size $20; $1C/$1D/$1E location. VMT 557FC664. }
  TLocationTextEventLog = class(TTextEventLog)
  public
    FXhx: Shortint;  { $1C }
    FYhx: Shortint;  { $1D }
    FLhx: Shortint;  { $1E }
    F_LocationTextEventLog_1F: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetLocation(var X, Y, L: Shortint); override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure SetLocation(X, Y, L: Shortint);
  end;

  { TMessageEventLog: size $28; $18 title, $20 message, $24 layout, $25 buttons, $26 pressed button. VMT 557FCD24. }
  TMessageEventLog = class(TEventLog)
  public
    FTitle: string; { $18 }
    FHeader: string; { $1C; 0040E89C }
    FMessage: TStrings; { $20 }
    FLayout: TMessageEventLogLayout; { $24 }
    FButtons: TMessageEventLogButtons; { $25 }
    FPressedButton: TPressedEventLogButton; { $26 }
    F_MessageEventLog_27: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function OK: Boolean; virtual; { $078; 557FE1A8 }
    function Cancel: Boolean; virtual; { $07C; 557FE1B0 }
    function Yes: Boolean; virtual;
    function No: Boolean; virtual;
  end;

  { THelpMessageEventLog: size $24; $18 message, $1C help title, $20 mode. VMT 557FCE44. }
  THelpMessageEventLog = class(TEventLog)
  public
    FMessage: TStringList; { $18 }
    FHelpFileName: string; { $1C }
    FMode: Byte; { $20 }
    F_HelpMessageEventLog_21: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TExecuteEventLogCallBackList: size $08; $04 list of $10-byte callback records. VMT 557FC130. }
  TExecuteEventLogCallBackList = class(TObject)
  public
    FList: TList; { $04 }
    destructor Destroy; override;
    constructor Create;
    procedure Clear;
    function GetCount: Integer;
    function GetItem(Index: Integer): PExecuteEventLogInfo;
    procedure Add(const Info: TExecuteEventLogInfo);
    procedure Delete(Index: Integer);
  end;

  { TEventLogList: size $18; $0C update count, $10 changed callback. VMT 557FC2B0. }
  TEventLogList = class(TENode)
  public
    FUpdateCount: Integer; { $0C }
    FOnChanged: TNotifyEvent; { $10 }
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure Changed;
    procedure BeginUpdate;
    procedure EndUpdate;
    function GetEvents(Index: Integer): TEventLog;
    procedure AddEvent(Event: TEventLog);
    procedure RemoveEvent(Event: TEventLog);
    function FindID(ID: Integer): TEventLog;
  end;

  { TEventLogbook: size $14; $08 events, $0C player, $10 next ID. VMT 557FC3B0. }
  TEventLogbook = class(TEObject)
  public
    FEvents: TEventLogList; { $08 }
    FPlayer: Shortint; { $0C }
    FReserved0D: array[0..2] of Byte;
    FNextID: Integer; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCount: Integer;
    function GetOnChanged: TNotifyEvent;
    procedure SetOnChanged(Value: TNotifyEvent);
    procedure ListEvents(Strings: TStrings);
    function GetLogs(Index: Integer): TEventLog;
    function CreateUniqueID: Integer;
    function FindID(ID: Integer): TEventLog;
    function FindFirstLog(Player, Day: Integer): Integer;
    function FindFirstLogEx(ClassID: Integer; Player: Integer; Day: Integer): Integer;
    { conflict: function FindFirstLogEx(ClassID, Player, Day: Integer): Integer; }
    procedure AddEvent(Event: TEventLog);
    procedure RemoveEvent(Event: TEventLog);
  end;

  { TUserEventLog (instance size 32, VMT 557FC474) }
  TUserEventLog = class(TEventLog)
  public
    FData: TObject; FReserved1C: array[0..3] of Byte; { $18; 55749C0D }
  end;

  { TEndTurnEventLog: size $18; no additional fields. VMT 557FC764. }
  TEndTurnEventLog = class(TEventLog)
  public
    class function ClassID: Integer; override;
    function GetVisible: Boolean; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
  end;

  { TShowMessageEventLog: size $1C; $18 message. VMT 557FC85C. }
  TShowMessageEventLog = class(TEventLog)
  public
    FMessage: TStringList; { $18 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TGameOverEventLog: size $20; $18 message, inherited $10 player. VMT 557FC95C. }
  TGameOverEventLog = class(TEventLog)
  public
    FMessage: TStringList; { $18 }
    FTargetPlayer: Shortint; { $1C; 55776744 }
    F_GameOverEventLog_1D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure Handled;
  end;

  { TNewDayEventLog: size $1C; inherited $18 text. VMT 557FCA54. }
  TNewDayEventLog = class(TTextEventLog)
  public
    class function ClassID: Integer; override;
    function GetLeftIcon: Integer; override;
    procedure PlayLoggedSFX(A1: TEventLogbook); override;
  end;

  { TShowBookEventLog: size $18; no additional fields. VMT 557FCB48. }
  TShowBookEventLog = class(TEventLog)
  public
    class function ClassID: Integer; override;
    function GetVisible: Boolean; override;
  end;

  { TTutorialMessageEventLog: size $24; inherited $18 message and $1C title. VMT 557FCF54. }
  TTutorialMessageEventLog = class(THelpMessageEventLog)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSaveGameEventLog: size $2C; $1C directory, $20 default name, $24 file name, $28 title. VMT 557FD0A4. }
  TSaveGameEventLog = class(TEventLog)
  public
    FMode: TSaveGameEventLogMode; { $18 }
    FReserved19: array[0..2] of Byte;
    FDirectory: string; { $1C }
    FDefaultName: string; { $20 }
    FFileName: string; { $24 }
    FTitle: string; { $28 }
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TPasswordEventLog: size $28; $18 password, $1C title, $20 prompt, $24 button. VMT 557FD1C4. }
  TPasswordEventLog = class(TEventLog)
  public
    FPassword: string; { $18; 557563E0 }
    FTitle: string; { $1C }
    FPrompt: string; { $20 }
    FPressedButton: TPressedEventLogButton; { $24; 557563EA }
    F_PasswordEventLog_25: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

procedure RegisterEventLog(AEngine: TEngine);
procedure DistributeEventLog(Log: TEventLog; Execute: Boolean);
procedure DistributeLocationEventLog(Log: TEventLog; Player: Shortint; X, Y, L: Shortint; Execute: Boolean);

implementation

uses AoWE;

constructor TExecuteEventLogCallBackList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TExecuteEventLogCallBackList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TExecuteEventLogCallBackList.Clear;
begin
  while FList.Count <> 0 do Delete(FList.Count - 1);
end;

function TExecuteEventLogCallBackList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TExecuteEventLogCallBackList.GetItem(Index: Integer): PExecuteEventLogInfo;
begin
  Result := FList.List[Index];
end;

procedure TExecuteEventLogCallBackList.Add(const Info: TExecuteEventLogInfo);
var
  Item: PExecuteEventLogInfo;
begin
  New(Item);
  Item^ := Info;
  FList.Add(Item);
end;

procedure TExecuteEventLogCallBackList.Delete(Index: Integer);
begin
  if Index < FList.Count then
  begin
    Dispose(PExecuteEventLogInfo(FList.List[Index]));
    FList.Delete(Index);
  end;
end;

constructor TEventLog.Create(AOwner: Engine.TECustomNode);
begin
  if AoWHSMap <> nil then
  begin
    FDay := AoWHSMap.FDay;
    FPlayer := AoWHSMap.FCurrentPlayer;
  end;
  inherited Create(AOwner);
  FRefCount := 1;
end;

procedure TEventLog.SetOwner(AOwner: Engine.TECustomNode);
begin
  if FRefCount <> 0 then
  begin
    AddRef;
    inherited SetOwner(AOwner);
    Release;
  end
  else inherited SetOwner(AOwner);
end;

function TEventLog.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TEventLog.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if Result = 0 then Destroy;
end;

procedure TEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FDay, 10);
  Stream.rwByte(Byte(FPlayer), 11);
  Stream.rwInteger(FID, 12);
end;

function TEventLog.GetVisible: Boolean;
begin
  Result := True;
end;

function TEventLog.GetText: string;
begin
  Result := 'Default TEventLog';
end;

function TEventLog.GetTextColor: TColor;
var
  Index: Integer;
begin
  if (FPlayer > 0) and (AoWHSMap.FPlayers.GetCount > FPlayer) then
    Index := AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace
  else Index := 12;
  Result := RaceColors[Index];
end;

function TEventLog.GetLeftIcon: Integer;
begin
  if (FPlayer > 0) and (AoWHSMap.FPlayers.GetCount > FPlayer) then
    Result := AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace
  else Result := 12;
end;

function TEventLog.GetMiddleIcon: Integer;
begin
  Result := -1;
end;

function TEventLog.GetRightIcon: Integer;
begin
  Result := -1;
end;

function TEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin
  if (Trigger = etUser) or
    (((Trigger = etEvent) or ((Trigger = etNewTurn) and AoWHSMap.FRequestCombatType)) and
    (AoWHSMap.FSeatedPlayer = FPlayer)) then
  begin
    AoWHSMap.TriggerExecuteEventLog(Self, Mode, Done);
    Result := True;
  end
  else
  begin
    if Trigger = etEvent then PlaySample('SFX\EVENTS\NEWEVENT.WAV');
    Result := False;
  end;
end;

procedure TEventLog.CenterViewTo(X, Y, L: Shortint);
begin
  AoWHSMap.CenterViewTo(X, Y, L);
  AoWHSMap.PlayCenterAnimation(X, Y, L);
end;

procedure TEventLog.GetLocation(var X, Y, L: Shortint);
begin
  X := -1;
  Y := -1;
  L := -1;
end;

procedure TEventLog.ViewLocation;
var
  X, Y, L: Shortint;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
  begin
    AoWHSMap.CenterViewTo(X, Y, L);
    AoWHSMap.PlayCenterAnimation(X, Y, L);
  end;
end;

procedure TEventLog.PlayLoggedSFX(A1: TEventLogbook);
begin
  PlaySample('SFX\EVENTS\NEWEVENT.WAV');
end;

procedure TEventLog.NotifyLogged(A1: TEventLogbook);
begin
  if (AoWHSMap.FSeatedPlayer = A1.FPlayer) and
    (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGameOverStatus = goNone) then
    PlayLoggedSFX(A1);
end;

function TEventLogList.AddChild(Child: Engine.TEObject): Integer;
begin
  FChildren.Add(Child);
  if Child.AddRef = -1 then raise Exception.Create('EObject doesn''t support ReferenceCounting');
  Result := FChildren.Count - 1;
  Changed;
end;

function TEventLogList.RemoveChild(Child: Engine.TEObject): Integer;
begin
  Result := FChildren.Remove(Child);
  if Result <> -1 then
  begin Child.SetOwner(nil); Child.Release; Changed; end;
end;

procedure TEventLogList.Clear;
var I: Integer;
begin
  for I := GetCount - 1 downto 0 do TEObject(FChildren.List^[I]).Release;
  FChildren.Clear;
end;

procedure TEventLogList.DestroyAllChildren;
begin Clear; end;

procedure TEventLogList.MainReadWrite(Stream: Engine.TEStorageStream);
var I: Integer;
begin
  if smRead in Stream.StorageMode then BeginUpdate;
  inherited MainReadWrite(Stream);
  if smRead in Stream.StorageMode then
  begin
    if Stream.StorageMode * [smRead, smCompare, smTranslate] = [smRead] then
      for I := 0 to FChildren.Count - 1 do TEObject(FChildren.List^[I]).Release;
    EndUpdate;
  end;
end;

procedure TEventLogList.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanged) then FOnChanged(Self);
end;

procedure TEventLogList.BeginUpdate;
begin Inc(FUpdateCount); end;

procedure TEventLogList.EndUpdate;
begin Dec(FUpdateCount); if FUpdateCount = 0 then Changed; end;

function TEventLogList.GetEvents(Index: Integer): TEventLog;
begin Result := FChildren.List^[Index]; end;

procedure TEventLogList.AddEvent(Event: TEventLog);
begin AddChild(Event); end;

procedure TEventLogList.RemoveEvent(Event: TEventLog);
begin RemoveChild(Event); end;

function TEventLogList.FindID(ID: Integer): TEventLog;
var I: Integer; Log: TEventLog;
begin
  I := GetCount;
  while I <> 0 do
  begin
    Dec(I); Log := FChildren.List^[I];
    if Log.FID = ID then begin Result := Log; Exit; end;
  end;
  Result := nil;
end;

constructor TEventLogbook.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FEvents := TEventLogList.Create(nil); end;

destructor TEventLogbook.Destroy;
begin FEvents.Free; inherited Destroy; end;

class function TEventLogbook.ClassID: Integer;
begin Result := $202E0; end;

procedure TEventLogbook.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin inherited MsgProc(Msg, Sender); FEvents.MsgProc(Msg, Sender); end;

function TEventLogbook.GetCount: Integer;
begin Result := FEvents.GetCount; end;

function TEventLogbook.GetOnChanged: TNotifyEvent;
begin Result := FEvents.FOnChanged; end;

procedure TEventLogbook.SetOnChanged(Value: TNotifyEvent);
begin FEvents.FOnChanged := Value; end;

procedure TEventLogbook.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwEObject(FEvents, 10); Stream.rwInteger(FNextID, 11); end;

procedure TEventLogbook.ListEvents(Strings: TStrings);
var I: Integer;
begin
  for I := 0 to FEvents.FChildren.Count - 1 do
    if TEventLog(FEvents.FChildren.List^[I]).GetVisible then
      Strings.AddObject(TEventLog(FEvents.FChildren.List^[I]).GetText, TObject(I));
end;

function TEventLogbook.GetLogs(Index: Integer): TEventLog;
begin Result := FEvents.FChildren.List^[Index]; end;

function TEventLogbook.CreateUniqueID: Integer;
begin
  Inc(FNextID);
  while FindID(FNextID) <> nil do
  begin
    Inc(FNextID);
    if FNextID > $FFFFFF then FNextID := 1;
  end;
  Result := FNextID;
end;

function TEventLogbook.FindID(ID: Integer): TEventLog;
begin Result := FEvents.FindID(ID); end;

function TEventLogbook.FindFirstLog(Player, Day: Integer): Integer;
begin
  with FEvents do
  begin
  Result := 0;
  while (Result <> FChildren.Count) and
    ((TEventLog(FChildren.List^[Result]).FPlayer <> Player) or
     (TEventLog(FChildren.List^[Result]).FDay <> Day)) do Inc(Result);
  if Result = FChildren.Count then Result := -1;
  end;
end;

function TEventLogbook.FindFirstLogEx(ClassID: Integer; Player: Integer; Day: Integer): Integer;
begin
  with FEvents do
  begin
  Result := 0;
  while (Result <> FChildren.Count) and
    ((TEventLog(FChildren.List^[Result]).FPlayer <> Player) or
     (TEventLog(FChildren.List^[Result]).FDay <> Day) or
     (TEventLog(FChildren.List^[Result]).ClassID <> ClassID)) do Inc(Result);
  if Result = FChildren.Count then Result := -1;
  end;
end;

procedure TEventLogbook.AddEvent(Event: TEventLog);
begin






































































































  Assert(AoWHSMap.GetSynchronised);
  Event.SetOwner(FEvents);
  Event.FID := CreateUniqueID;
  Event.NotifyLogged(Self);
end;

procedure TEventLogbook.RemoveEvent(Event: TEventLog);
begin FEvents.RemoveChild(Event); end;

class function TTextEventLog.ClassID: Integer;
begin Result := $202E1; end;

procedure TTextEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwString(FText, 15); end;

function TTextEventLog.GetText: string;
begin Result := FText; end;

function TTextEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin Result := False; end;

constructor TLocationTextEventLog.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FXhx := -1; FYhx := -1; FLhx := -1; end;

class function TLocationTextEventLog.ClassID: Integer;
begin Result := $202E8; end;

procedure TLocationTextEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FXhx), 20); Stream.rwByte(Byte(FYhx), 21); Stream.rwByte(Byte(FLhx), 22);
end;

procedure TLocationTextEventLog.SetLocation(X, Y, L: Shortint);
begin FXhx := X; FYhx := Y; FLhx := L; end;

procedure TLocationTextEventLog.GetLocation(var X, Y, L: Shortint);
begin X := FXhx; Y := FYhx; L := FLhx; end;

function TLocationTextEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin
  inherited Execute(Mode, Trigger, Done);
  if Trigger = etUser then ViewLocation;
  Result := False;
end;

function TEndTurnEventLog.GetVisible: Boolean;
begin Result := False; end;

class function TEndTurnEventLog.ClassID: Integer;
begin Result := $202E3; end;

function TEndTurnEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin Result := False; end;

constructor TShowMessageEventLog.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FMessage := TStringList.Create; end;

destructor TShowMessageEventLog.Destroy;
begin FMessage.Free; inherited Destroy; end;

class function TShowMessageEventLog.ClassID: Integer;
begin Result := $202F6; end;

procedure TShowMessageEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwStrings(FMessage, 20); end;

constructor TGameOverEventLog.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FMessage := TStringList.Create; end;

destructor TGameOverEventLog.Destroy;
begin FMessage.Free; inherited Destroy; end;

class function TGameOverEventLog.ClassID: Integer;
begin Result := $202E4; end;

procedure TGameOverEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwStrings(FMessage, 20); end;

function TGameOverEventLog.GetText: string;
begin
  case AoWHSMap.FPlayers.GetPlayers(FPlayer).FGameOverStatus of
    goLost: Result := SysUtils.Format(TranslateRStr(GameOverDefeatEventLogRStr), [AoWHSMap.FPlayers.GetPlayers(FPlayer).GetName]);
    goWon: Result := SysUtils.Format(TranslateRStr(GameOverVictoryEventLogRStr), [AoWHSMap.FPlayers.GetPlayers(FPlayer).GetName]);
  end;
end;

procedure TGameOverEventLog.Handled;
begin AoWHSMap.GameOverEventHandled(FPlayer); end;

function TGameOverEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin
  case Trigger of
    etUser:
      if AoWHSMap.FSeatedPlayer <> FPlayer then
      begin AoWHSMap.TriggerExecuteEventLog(Self, Mode, Done); Result := True; end
      else Result := False;
    etEvent:
      begin AoWHSMap.TriggerExecuteEventLog(Self, Mode, Done); Result := True; end;
    etNewTurn:
      begin AoWHSMap.TriggerExecuteEventLog(Self, Mode, Done); Result := True; end;
  else Result := False;
  end;
end;

class function TNewDayEventLog.ClassID: Integer;
begin Result := $202E5; end;

function TNewDayEventLog.GetLeftIcon: Integer;
begin Result := 18; end;

procedure TNewDayEventLog.PlayLoggedSFX(A1: TEventLogbook);
begin if AoWHSMap.FDay > 1 then inherited PlayLoggedSFX(A1); end;

class function TShowBookEventLog.ClassID: Integer;
begin Result := $202EA; end;

function TShowBookEventLog.GetVisible: Boolean;
begin Result := False; end;

constructor TMessageEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMessage := TStringList.Create;
  FTitle := TranslateRStr(MessageRStr);
  FButtons := mebOk; FPressedButton := pebNone; FLayout := melNormal;
end;

destructor TMessageEventLog.Destroy;
begin FMessage.Free; inherited Destroy; end;

procedure TMessageEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FMessage, 30); Stream.rwData(FLayout, 1, 31);
  Stream.rwData(FButtons, 1, 32); Stream.rwString(FTitle, 33);
end;

function TMessageEventLog.OK: Boolean;
begin FPressedButton := pebOk; Result := True; end;

function TMessageEventLog.Cancel: Boolean;
begin FPressedButton := pebCancel; Result := True; end;

function TMessageEventLog.Yes: Boolean;
begin
  FPressedButton := pebYes;
  Result := True;
end;

function TMessageEventLog.No: Boolean;
begin
  FPressedButton := pebNo;
  Result := True;
end;

constructor THelpMessageEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMessage := TStringList.Create;
  FHelpFileName := TranslateRStr(HelpRStr);
  FMode := 0;
end;

destructor THelpMessageEventLog.Destroy;
begin FMessage.Free; inherited Destroy; end;

constructor TTutorialMessageEventLog.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FHelpFileName := TranslateRStr(TutorialRStr); end;

constructor TSaveGameEventLog.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FTitle := TranslateRStr(SaveRStr); FMode := []; end;

constructor TPasswordEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPassword := '';
  FPrompt := TranslateRStr(EnterPasswordRStr);
  FTitle := TranslateRStr(PasswordVerificationRStr);
  FPressedButton := pebNone;
end;

procedure RegisterEventLog(AEngine: TEngine);
begin AEngine.RegisterEClasses([TTextEventLog, TEndTurnEventLog, TGameOverEventLog, TLocationTextEventLog]); end;

procedure DistributeEventLog(Log: TEventLog; Execute: Boolean);
var I: Integer; Player: TPlayer; CopyLog: TEventLog;
begin
  for I := 0 to AoWHSMap.FPlayers.GetCount - 1 do
  begin
    Player := AoWHSMap.FPlayers.GetPlayers(I);
    if Player.FStatus = psPlaying then
    begin
      CopyLog := TEventLog(Log.Copy(AoWEngine));
      Player.FEventLogbook.AddEvent(CopyLog);
      if (I = AoWHSMap.FSeatedPlayer) and Execute then CopyLog.Execute(False, etEvent, nil);
      CopyLog.Release;
    end;
  end;
end;

procedure DistributeLocationEventLog(Log: TEventLog; Player: Shortint; X, Y, L: Shortint; Execute: Boolean);
var I: Integer; TargetPlayer: TPlayer; CopyLog: TEventLog;
begin
  for I := 0 to AoWHSMap.FPlayers.GetCount - 1 do
  begin
    TargetPlayer := AoWHSMap.FPlayers.GetPlayers(I);
    if (TargetPlayer.FStatus = psPlaying) and
      ((I = Player) or not AoWHSMap.FoggedForPlayer(X, Y, L, I)) then
    begin
      CopyLog := TEventLog(Log.Copy(AoWEngine));
      TargetPlayer.FEventLogbook.AddEvent(CopyLog);
      if (I = AoWHSMap.FSeatedPlayer) and
        (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman) and Execute then CopyLog.Execute(False, etEvent, nil);
      CopyLog.Release;
    end;
  end;
end;


initialization
finalization

end.
