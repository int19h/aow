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
  TExecuteTrigger = (etEvent, etUser, etNewTurn);  { ot=1 }
  TExecuteTriggers = set of TExecuteTrigger; { ot=1 }
  TMessageEventLogButtons = (mebOk, mebOkCancel, mebYesNo, mebYesNoCancel);  { ot=1 }
  TPressedEventLogButton = (pebNone, pebOk, pebCancel, pebYes, pebNo);  { ot=1 }
  TMessageEventLogLayout = (melNormal, melHeader);  { ot=1 }
  TSaveGameEventLogMode = set of (sgmDisableCancel); { ot=1 }

  { TEventLog (instance size 24, VMT 557FC1C8) }
  TEventLog = class(TEObject)
  public
    F_EventLog_08: Integer;
    F_EventLog_0C: Integer;
    FPlayer: Shortint;  { $10 }
    F_EventLog_11: array[0..2] of Byte;
    F_EventLog_14: Integer;
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
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +064 draft }
    procedure PlayLoggedSFX(A1: Integer); virtual;  { +068 draft }
    procedure NotifyLogged(A1: Integer); virtual;  { +06C draft }
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; virtual;
    procedure ViewLocation(A1: Integer; A2: Integer); virtual;  { +074 draft }
    procedure CenterViewTo(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TTextEventLog (instance size 28, VMT 557FC564) }
  TTextEventLog = class(TEventLog)
  public
    FText: string;  { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
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
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure SetLocation(X, Y, L: Shortint);
  end;

  { TMessageEventLog (instance size 40, VMT 557FCD24) }
  TMessageEventLog = class(TEventLog)
  public
    F_MessageEventLog_18: Integer;
    F_MessageEventLog_1C: array[0..3] of Byte;
    F_MessageEventLog_20: Integer;
    F_MessageEventLog_24: Byte;
    F_MessageEventLog_25: Byte;
    F_MessageEventLog_26: Byte;
    F_MessageEventLog_27: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure OK; virtual;  { +078 draft }
    procedure Cancel; virtual;  { +07C draft }
    procedure Yes; virtual;  { +080 draft }
    procedure No; virtual;  { +084 draft }
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

  { TExecuteEventLogCallBackList (instance size 8, VMT 557FC130) }
  TExecuteEventLogCallBackList = class(TObject)
  public
    F_ExecuteEventLogCallBackList_04: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Clear;  { draft }
    procedure GetCount;  { draft }
    procedure GetItem(A1: Integer);  { draft }
    procedure Add(A1: Integer);  { draft }
    procedure Delete(A1: Integer);  { draft }
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
    procedure GetEvents(A1: Integer);  { draft }
    procedure AddEvent;  { draft }
    procedure RemoveEvent;  { draft }
    procedure FindID(A1: Integer);  { draft }
  end;

  { TEventLogbook (instance size 20, VMT 557FC3B0) }
  TEventLogbook = class(TEObject)
  public
    F_EventLogbook_08: Integer;
    F_EventLogbook_0C: array[0..3] of Byte;
    F_EventLogbook_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetCount;  { draft }
    procedure GetOnChanged(A1: Integer);  { draft }
    procedure SetOnChanged(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ListEvents(A1: Integer);  { draft }
    procedure GetLogs(A1: Integer);  { draft }
    procedure CreateUniqueID;  { draft }
    function FindID(ID: Integer): TEventLog;
    procedure FindFirstLog(A1: Integer; A2: Integer);  { draft }
    procedure FindFirstLogEx(A1: Integer; A2: Integer; A3: Integer);  { draft }
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
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
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
    F_GameOverEventLog_18: Integer;
    F_GameOverEventLog_1C: array[0..3] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure Handled;  { draft }
  end;

  { TNewDayEventLog (instance size 28, VMT 557FCA54) }
  TNewDayEventLog = class(TTextEventLog)
  public
    class function ClassID: Integer; override;
    function GetLeftIcon: Integer; override;
    procedure PlayLoggedSFX(A1: Integer); override;
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

  { TSaveGameEventLog (instance size 44, VMT 557FD0A4) }
  TSaveGameEventLog = class(TEventLog)
  public
    F_SaveGameEventLog_18: Byte;
    F_SaveGameEventLog_19: array[0..14] of Byte;
    F_SaveGameEventLog_28: Byte;
    F_SaveGameEventLog_29: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TPasswordEventLog (instance size 40, VMT 557FD1C4) }
  TPasswordEventLog = class(TEventLog)
  public
    F_PasswordEventLog_18: Byte;
    F_PasswordEventLog_19: array[0..2] of Byte;
    F_PasswordEventLog_1C: Byte;
    F_PasswordEventLog_1D: array[0..2] of Byte;
    F_PasswordEventLog_20: Byte;
    F_PasswordEventLog_21: array[0..2] of Byte;
    F_PasswordEventLog_24: Byte;
    F_PasswordEventLog_25: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

procedure RegisterEventLog;  { draft }
procedure DistributeEventLog(A1: Integer; A2: Byte);  { draft }
procedure DistributeLocationEventLog(Log: TEventLog; Player: Shortint; X, Y, L: Shortint; Radius: Integer);

implementation

constructor TExecuteEventLogCallBackList.Create;
begin end;

destructor TExecuteEventLogCallBackList.Destroy;
begin end;

procedure TExecuteEventLogCallBackList.Clear;
begin end;

procedure TExecuteEventLogCallBackList.GetCount;
begin end;

procedure TExecuteEventLogCallBackList.GetItem(A1: Integer);
begin end;

procedure TExecuteEventLogCallBackList.Add(A1: Integer);
begin end;

procedure TExecuteEventLogCallBackList.Delete(A1: Integer);
begin end;

constructor TEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEventLog.SetOwner(AOwner: Engine.TECustomNode);
begin end;

function TEventLog.AddRef: Integer;
begin Result := 0; end;

function TEventLog.Release: Integer;
begin Result := 0; end;

procedure TEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TEventLog.GetVisible: Boolean;
begin Result := False; end;

function TEventLog.GetText: string;
begin Result := ''; end;

function TEventLog.GetTextColor: TColor;
begin Result := 0; end;

function TEventLog.GetLeftIcon: Integer;
begin Result := 0; end;

function TEventLog.GetMiddleIcon: Integer;
begin Result := 0; end;

function TEventLog.GetRightIcon: Integer;
begin Result := 0; end;

function TEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

procedure TEventLog.CenterViewTo(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TEventLog.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

procedure TEventLog.PlayLoggedSFX(A1: Integer);
begin end;

procedure TEventLog.NotifyLogged(A1: Integer);
begin end;

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

procedure TEventLogList.GetEvents(A1: Integer);
begin end;

procedure TEventLogList.AddEvent;
begin end;

procedure TEventLogList.RemoveEvent;
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

procedure TEventLogbook.GetCount;
begin end;

procedure TEventLogbook.GetOnChanged(A1: Integer);
begin end;

procedure TEventLogbook.SetOnChanged(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TEventLogbook.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TEventLogbook.ListEvents(A1: Integer);
begin end;

procedure TEventLogbook.GetLogs(A1: Integer);
begin end;

procedure TEventLogbook.CreateUniqueID;
begin end;

function TEventLogbook.FindID(ID: Integer): TEventLog;
begin Result := nil; end;

procedure TEventLogbook.FindFirstLog(A1: Integer; A2: Integer);
begin end;

procedure TEventLogbook.FindFirstLogEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

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

function TTextEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

constructor TLocationTextEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

class function TLocationTextEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TLocationTextEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TLocationTextEventLog.SetLocation(X, Y, L: Shortint);
begin end;

procedure TLocationTextEventLog.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TLocationTextEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

function TEndTurnEventLog.GetVisible: Boolean;
begin Result := False; end;

class function TEndTurnEventLog.ClassID: Integer;
begin Result := 0; end;

function TEndTurnEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
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

function TGameOverEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

class function TNewDayEventLog.ClassID: Integer;
begin Result := 0; end;

function TNewDayEventLog.GetLeftIcon: Integer;
begin Result := 0; end;

procedure TNewDayEventLog.PlayLoggedSFX(A1: Integer);
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

procedure TMessageEventLog.Yes;
begin end;

procedure TMessageEventLog.No;
begin end;

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

procedure RegisterEventLog;
begin end;

procedure DistributeEventLog(A1: Integer; A2: Byte);
begin end;

procedure DistributeLocationEventLog(Log: TEventLog; Player: Shortint; X, Y, L: Shortint; Radius: Integer);
begin end;


initialization
finalization

end.
