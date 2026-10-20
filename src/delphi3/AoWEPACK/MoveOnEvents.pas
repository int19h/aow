unit MoveOnEvents;

{ Draft declarations of MoveOnEvents, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TMoveOnEvent = class;
  TMoveOnEventResource = class;
  TChangeSongMoveOnEvent = class;
  TChangeSongMoveOnEventResource = class;
  TPlaySampleMoveOnEvent = class;
  TPlaySampleMoveOnEventResource = class;
  TShowMessageMoveOnEvent = class;
  TShowMessageMoveOnEventResource = class;


  { TMoveOnEvent (instance size 24, VMT 557D2A34) }
  TMoveOnEvent = class(TMapObject)
  public
    F_MoveOnEvent_10: Byte;
    F_MoveOnEvent_11: array[0..2] of Byte;
    F_MoveOnEvent_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure MovedOnTrigger(A1: Integer); virtual;  { +11C draft }
    procedure ArmyPlaced(A1: Integer); virtual;  { +120 draft }
    procedure GetTriggerPlayer(A1: Byte);  { draft }
    procedure SetTriggerPlayer(A1: Byte; A2: Byte);  { draft }
    procedure SetRadius(A1: Integer);  { draft }
  end;

  { TMoveOnEventResource (instance size 52, VMT 557D2BD4) }
  TMoveOnEventResource = class(TMapObjectResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ResourceEditName: string; override;
    procedure SetLevel(Value: Byte); override;
  end;

  { TChangeSongMoveOnEvent (instance size 28, VMT 557D2CD0) }
  TChangeSongMoveOnEvent = class(TMoveOnEvent)
  public
    F_ChangeSongMoveOnEvent_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MovedOnTrigger(A1: Integer); override;
  end;

  { TChangeSongMoveOnEventResource (instance size 52, VMT 557D2E98) }
  TChangeSongMoveOnEventResource = class(TMoveOnEventResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TPlaySampleMoveOnEvent (instance size 28, VMT 557D2FA8) }
  TPlaySampleMoveOnEvent = class(TMoveOnEvent)
  public
    F_PlaySampleMoveOnEvent_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MovedOnTrigger(A1: Integer); override;
  end;

  { TPlaySampleMoveOnEventResource (instance size 52, VMT 557D3170) }
  TPlaySampleMoveOnEventResource = class(TMoveOnEventResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TShowMessageMoveOnEvent (instance size 28, VMT 557D3280) }
  TShowMessageMoveOnEvent = class(TMoveOnEvent)
  public
    F_ShowMessageMoveOnEvent_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MovedOnTrigger(A1: Integer); override;
  end;

  { TShowMessageMoveOnEventResource (instance size 52, VMT 557D3434) }
  TShowMessageMoveOnEventResource = class(TMoveOnEventResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMoveOnEvents(A1: Integer);  { draft }

implementation

function TMoveOnEvent.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

function TMoveOnEvent.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TMoveOnEvent.GetTriggerPlayer(A1: Byte);
begin end;

procedure TMoveOnEvent.SetTriggerPlayer(A1: Byte; A2: Byte);
begin end;

procedure TMoveOnEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TMoveOnEvent.Activate;
begin end;

procedure TMoveOnEvent.Deactivate;
begin end;

procedure TMoveOnEvent.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TMoveOnEvent.MovedOnTrigger(A1: Integer);
begin end;

procedure TMoveOnEvent.ArmyPlaced(A1: Integer);
begin end;

procedure TMoveOnEvent.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TMoveOnEvent.Connect;
begin end;

procedure TMoveOnEvent.Disconnect;
begin end;

procedure TMoveOnEvent.SetRadius(A1: Integer);
begin end;

constructor TMoveOnEventResource.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TMoveOnEventResource.SetLevel(Value: Byte);
begin end;

class function TMoveOnEventResource.ResourceEditName: string;
begin Result := ''; end;

class function TChangeSongMoveOnEvent.ClassID: Integer;
begin Result := 0; end;

procedure TChangeSongMoveOnEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TChangeSongMoveOnEvent.MovedOnTrigger(A1: Integer);
begin end;

class function TChangeSongMoveOnEventResource.ResourceEditName: string;
begin Result := ''; end;

class function TChangeSongMoveOnEventResource.ClassID: Integer;
begin Result := 0; end;

function TChangeSongMoveOnEventResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TPlaySampleMoveOnEvent.ClassID: Integer;
begin Result := 0; end;

procedure TPlaySampleMoveOnEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlaySampleMoveOnEvent.MovedOnTrigger(A1: Integer);
begin end;

class function TPlaySampleMoveOnEventResource.ResourceEditName: string;
begin Result := ''; end;

class function TPlaySampleMoveOnEventResource.ClassID: Integer;
begin Result := 0; end;

function TPlaySampleMoveOnEventResource.ResourceUserClassID: Integer;
begin Result := 0; end;

constructor TShowMessageMoveOnEvent.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TShowMessageMoveOnEvent.Destroy;
begin end;

class function TShowMessageMoveOnEvent.ClassID: Integer;
begin Result := 0; end;

procedure TShowMessageMoveOnEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TShowMessageMoveOnEvent.MovedOnTrigger(A1: Integer);
begin end;

class function TShowMessageMoveOnEventResource.ResourceEditName: string;
begin Result := ''; end;

class function TShowMessageMoveOnEventResource.ClassID: Integer;
begin Result := 0; end;

function TShowMessageMoveOnEventResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterMoveOnEvents(A1: Integer);
begin end;


initialization
finalization

end.
