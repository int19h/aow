unit EventLog;

{ Draft declarations of EventLog, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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

  { TTextEventLog (instance size 28, VMT 557FC564) }
  TTextEventLog = class(TEventLog)
  public
    FText: string;  { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
  end;

  { TLocationTextEventLog (instance size 32, VMT 557FC664) }
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
    F_MessageEventLog_1C: array[0..3] of Byte;
    FMessage: TStrings; { $20 }
    FLayout: TMessageEventLogLayout; { $24 }
    FButtons: TMessageEventLogButtons; { $25 }
    FPressedButton: TPressedEventLogButton; { $26 }
    F_MessageEventLog_27: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure OK; virtual;  { +078 draft }
    procedure Cancel; virtual;  { +07C draft }
    function Yes: Boolean; virtual;
    function No: Boolean; virtual;
  end;

  { THelpMessageEventLog (instance size 36, VMT 557FCE44) }
  THelpMessageEventLog = class(TEventLog)
  public
    FMessage: TStringList; { $18 }
    FHelpFileName: string; { $1C }
    F_HelpMessageEventLog_20: Byte;
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

  { TEventLogList (instance size 24, VMT 557FC2B0) }
  TEventLogList = class(TENode)
  public
    F_EventLogList_0C: Integer;
    F_EventLogList_10: Byte;
    F_EventLogList_11: array[0..0] of Byte;
    F_EventLogList_12: Word;
    F_EventLogList_14: Integer;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure Changed;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    function GetEvents(Index: Integer): TEventLog;
    procedure AddEvent(Event: TEventLog);
    procedure RemoveEvent(Event: TEventLog);
    procedure FindID(A1: Integer);  { draft }
  end;

  { TEventLogbook (instance size 20, VMT 557FC3B0) }
  TEventLogbook = class(TEObject)
  public
    F_EventLogbook_08: Integer;
    FPlayer: Shortint; { $0C }
    FReserved0D: array[0..2] of Byte;
    F_EventLogbook_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCount: Integer;
    procedure GetOnChanged(A1: Integer);  { draft }
    procedure SetOnChanged(Value: TNotifyEvent);
    procedure ListEvents(A1: Integer);  { draft }
    function GetLogs(Index: Integer): TEventLog;
    procedure CreateUniqueID;  { draft }
    function FindID(ID: Integer): TEventLog;
    procedure FindFirstLog(A1: Integer; A2: Integer);  { draft }
    function FindFirstLogEx(ClassID: Integer; Player: Integer; Day: Integer): Integer;
    { conflict: function FindFirstLogEx(ClassID, Player, Day: Integer): Integer; }
    procedure AddEvent(Event: TEventLog);
    procedure RemoveEvent(Event: TEventLog);
  end;

  { TUserEventLog (instance size 32, VMT 557FC474) }
  TUserEventLog = class(TEventLog)
  public
    F_UserEventLog_18: array[0..7] of Byte;
  end;

  { TEndTurnEventLog (instance size 24, VMT 557FC764) }
  TEndTurnEventLog = class(TEventLog)
  public
    class function ClassID: Integer; override;
    function GetVisible: Boolean; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
  end;

  { TShowMessageEventLog (instance size 28, VMT 557FC85C) }
  TShowMessageEventLog = class(TEventLog)
  public
    F_ShowMessageEventLog_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TGameOverEventLog (instance size 32, VMT 557FC95C) }
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
    procedure Handled;  { draft }
  end;

  { TNewDayEventLog (instance size 28, VMT 557FCA54) }
  TNewDayEventLog = class(TTextEventLog)
  public
    class function ClassID: Integer; override;
    function GetLeftIcon: Integer; override;
    procedure PlayLoggedSFX(A1: TEventLogbook); override;
  end;

  { TShowBookEventLog (instance size 24, VMT 557FCB48) }
  TShowBookEventLog = class(TEventLog)
  public
    class function ClassID: Integer; override;
    function GetVisible: Boolean; override;
  end;

  { TTutorialMessageEventLog (instance size 36, VMT 557FCF54) }
  TTutorialMessageEventLog = class(THelpMessageEventLog)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSaveGameEventLog: size $2C; $1C directory, $20 default name, $24 file name, $28 title. VMT 557FD0A4. }
  TSaveGameEventLog = class(TEventLog)
  public
    F_SaveGameEventLog_18: Byte;
    FReserved19: array[0..2] of Byte;
    FDirectory: string; { $1C }
    FDefaultName: string; { $20 }
    FFileName: string; { $24 }
    FTitle: string; { $28 }
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TPasswordEventLog (instance size 40, VMT 557FD1C4) }
  TPasswordEventLog = class(TEventLog)
  public
    FPassword: string; { $18; 557563E0 }
    F_PasswordEventLog_1C: Byte;
    F_PasswordEventLog_1D: array[0..2] of Byte;
    F_PasswordEventLog_20: Byte;
    F_PasswordEventLog_21: array[0..2] of Byte;
    FPressedButton: TPressedEventLogButton; { $24; 557563EA }
    F_PasswordEventLog_25: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

procedure RegisterEventLog(AEngine: TEngine);
procedure DistributeEventLog(Log: TEventLog; Execute: Boolean);
procedure DistributeLocationEventLog(Log: TEventLog; Player: Shortint; X, Y, L: Shortint; Radius: Integer);

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
begin Result := 0; end;

function TEventLogList.RemoveChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

procedure TEventLogList.Clear;
begin end;

procedure TEventLogList.DestroyAllChildren;
begin end;

procedure TEventLogList.MainReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TEventLogList.Changed;
begin end;

procedure TEventLogList.BeginUpdate;
begin end;

procedure TEventLogList.EndUpdate;
begin end;

function TEventLogList.GetEvents(Index: Integer): TEventLog;
begin Result := nil; end;

procedure TEventLogList.AddEvent(Event: TEventLog);
begin end;

procedure TEventLogList.RemoveEvent(Event: TEventLog);
begin end;

procedure TEventLogList.FindID(A1: Integer);
begin end;

constructor TEventLogbook.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TEventLogbook.Destroy;
begin end;

class function TEventLogbook.ClassID: Integer;
begin Result := 0; end;

procedure TEventLogbook.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

function TEventLogbook.GetCount: Integer;
begin Result := 0; end;

procedure TEventLogbook.GetOnChanged(A1: Integer);
begin end;

procedure TEventLogbook.SetOnChanged(Value: TNotifyEvent);
begin end;

procedure TEventLogbook.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TEventLogbook.ListEvents(A1: Integer);
begin end;

function TEventLogbook.GetLogs(Index: Integer): TEventLog;
begin Result := nil; end;

procedure TEventLogbook.CreateUniqueID;
begin end;

function TEventLogbook.FindID(ID: Integer): TEventLog;
begin Result := nil; end;

procedure TEventLogbook.FindFirstLog(A1: Integer; A2: Integer);
begin end;

function TEventLogbook.FindFirstLogEx(ClassID: Integer; Player: Integer; Day: Integer): Integer;
{ conflict: function TEventLogbook.FindFirstLogEx(ClassID, Player, Day: Integer): Integer; }
begin Result := 0; end;

procedure TEventLogbook.AddEvent(Event: TEventLog);
begin end;

procedure TEventLogbook.RemoveEvent(Event: TEventLog);
begin end;

class function TTextEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TTextEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TTextEventLog.GetText: string;
begin Result := ''; end;

function TTextEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

constructor TLocationTextEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

class function TLocationTextEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TLocationTextEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TLocationTextEventLog.SetLocation(X, Y, L: Shortint);
begin end;

procedure TLocationTextEventLog.GetLocation(var X, Y, L: Shortint);
begin end;

function TLocationTextEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

function TEndTurnEventLog.GetVisible: Boolean;
begin Result := False; end;

class function TEndTurnEventLog.ClassID: Integer;
begin Result := 0; end;

function TEndTurnEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

constructor TShowMessageEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TShowMessageEventLog.Destroy;
begin end;

class function TShowMessageEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TShowMessageEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TGameOverEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TGameOverEventLog.Destroy;
begin end;

class function TGameOverEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TGameOverEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TGameOverEventLog.GetText: string;
begin Result := ''; end;

procedure TGameOverEventLog.Handled;
begin end;

function TGameOverEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

class function TNewDayEventLog.ClassID: Integer;
begin Result := 0; end;

function TNewDayEventLog.GetLeftIcon: Integer;
begin Result := 0; end;

procedure TNewDayEventLog.PlayLoggedSFX(A1: TEventLogbook);
begin end;

class function TShowBookEventLog.ClassID: Integer;
begin Result := 0; end;

function TShowBookEventLog.GetVisible: Boolean;
begin Result := False; end;

constructor TMessageEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMessageEventLog.Destroy;
begin end;

procedure TMessageEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TMessageEventLog.OK;
begin end;

procedure TMessageEventLog.Cancel;
begin end;

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
begin end;

destructor THelpMessageEventLog.Destroy;
begin end;

constructor TTutorialMessageEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSaveGameEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TPasswordEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

procedure RegisterEventLog(AEngine: TEngine);
begin end;

procedure DistributeEventLog(Log: TEventLog; Execute: Boolean);
begin end;

procedure DistributeLocationEventLog(Log: TEventLog; Player: Shortint; X, Y, L: Shortint; Radius: Integer);
begin end;


initialization
finalization

end.
