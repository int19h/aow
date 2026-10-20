unit FlagEvents;

{ Draft declarations of FlagEvents, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EventLog;

type
  TFlagEvent = class;
  TFlagEventResource = class;
  TFlagMessageEventLog = class;
  TFlagMessageEvent = class;
  TFlagMessageEventResource = class;
  TTutorialMessageEvent = class;
  TTutorialMessageEventResource = class;

  TFlagEventTriggerMode = (etmInstant, etmNewTurn);  { ot=1 }

  { TFlagEvent (instance size 24, VMT 557D085C) }
  TFlagEvent = class(TMapObject)
  public
    F_FlagEvent_10: Byte;
    F_FlagEvent_11: array[0..2] of Byte;
    F_FlagEvent_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure Trigger(A1: Byte); virtual;  { +11C draft }
    procedure GetTriggerPlayer(A1: Byte);  { draft }
    procedure SetTriggerPlayer(A1: Byte; A2: Byte);  { draft }
    procedure UpdateInstantTrigger;  { draft }
    procedure UpdateNewTurnTrigger(A1: Integer);  { draft }
  end;

  { TFlagEventResource (instance size 52, VMT 557D09F0) }
  TFlagEventResource = class(TMapObjectResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetLevel(Value: Byte); override;
  end;

  { TFlagMessageEventLog (instance size 36, VMT 557D0AE4) }
  TFlagMessageEventLog = class(THelpMessageEventLog)
  public
  end;

  { TFlagMessageEvent (instance size 32, VMT 557D0BE8) }
  TFlagMessageEvent = class(TFlagEvent)
  public
    F_FlagMessageEvent_18: Integer;
    F_FlagMessageEvent_1C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Trigger(A1: Byte); override;
  end;

  { TFlagMessageEventResource (instance size 52, VMT 557D0D9C) }
  TFlagMessageEventResource = class(TFlagEventResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TTutorialMessageEvent (instance size 28, VMT 557D0EA0) }
  TTutorialMessageEvent = class(TFlagEvent)
  public
    F_TutorialMessageEvent_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Trigger(A1: Byte); override;
  end;

  { TTutorialMessageEventResource (instance size 52, VMT 557D104C) }
  TTutorialMessageEventResource = class(TFlagEventResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterFlagEvents;  { draft }

implementation

procedure TFlagEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TFlagEvent.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

function TFlagEvent.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TFlagEvent.GetTriggerPlayer(A1: Byte);
begin end;

procedure TFlagEvent.SetTriggerPlayer(A1: Byte; A2: Byte);
begin end;

procedure TFlagEvent.Trigger(A1: Byte);
begin end;

procedure TFlagEvent.UpdateInstantTrigger;
begin end;

procedure TFlagEvent.UpdateNewTurnTrigger(A1: Integer);
begin end;

procedure TFlagEvent.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TFlagEvent.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TFlagEvent.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TFlagEventResource.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFlagEventResource.SetLevel(Value: Byte);
begin end;

constructor TFlagMessageEvent.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TFlagMessageEvent.Destroy;
begin end;

class function TFlagMessageEvent.ClassID: Integer;
begin Result := 0; end;

procedure TFlagMessageEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFlagMessageEvent.Trigger(A1: Byte);
begin end;

class function TFlagMessageEventResource.ClassID: Integer;
begin Result := 0; end;

class function TFlagMessageEventResource.ResourceEditName: string;
begin Result := ''; end;

function TFlagMessageEventResource.ResourceUserClassID: Integer;
begin Result := 0; end;

constructor TTutorialMessageEvent.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TTutorialMessageEvent.Destroy;
begin end;

class function TTutorialMessageEvent.ClassID: Integer;
begin Result := 0; end;

procedure TTutorialMessageEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTutorialMessageEvent.Trigger(A1: Byte);
begin end;

class function TTutorialMessageEventResource.ClassID: Integer;
begin Result := 0; end;

class function TTutorialMessageEventResource.ResourceEditName: string;
begin Result := ''; end;

function TTutorialMessageEventResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterFlagEvents;
begin end;


initialization
finalization

end.
