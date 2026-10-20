unit FlagEvents;

{ Draft declarations of FlagEvents, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Bodies recovered in signature order; remaining declaration blockers are marked needs. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EventLog, AoWE;

type
  TFlagEvent = class;
  TFlagEventResource = class;
  TFlagMessageEventLog = class;
  TFlagMessageEvent = class;
  TFlagMessageEventResource = class;
  TTutorialMessageEvent = class;
  TTutorialMessageEventResource = class;

  TFlagEventTriggerMode = (etmInstant, etmNewTurn);  { ot=1 }

  { TFlagEvent (instance size 24, VMT 557D085C):
    +$10 FTriggerMode, +$14 FTriggerPlayers (player 1 is bit 0). }
  TFlagEvent = class(TMapObject)
  public
    FTriggerMode: TFlagEventTriggerMode;
    FReserved11: array[0..2] of Byte;
    FTriggerPlayers: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function Trigger(Player: Shortint): Boolean; virtual; { +11C }
    function GetTriggerPlayer(Player: Shortint): Boolean;
    procedure SetTriggerPlayer(Player: Shortint; Value: Boolean);
    procedure UpdateInstantTrigger;
    procedure UpdateNewTurnTrigger(Player: Shortint);
  end;

  { TFlagEventResource (instance size 52, VMT 557D09F0): no additional fields. }
  TFlagEventResource = class(TMapObjectResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetLevel(Value: Byte); override;
  end;

  { TFlagMessageEventLog (instance size 36, VMT 557D0AE4): no additional fields. }
  TFlagMessageEventLog = class(THelpMessageEventLog)
  public
  end;

  { TFlagMessageEvent (instance size 32, VMT 557D0BE8): +$18 FHelpFileName, +$1C FMessage. }
  TFlagMessageEvent = class(TFlagEvent)
  public
    FHelpFileName: string;
    FMessage: TStringList;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Trigger(Player: Shortint): Boolean; override;
  end;

  { TFlagMessageEventResource (instance size 52, VMT 557D0D9C): no additional fields. }
  TFlagMessageEventResource = class(TFlagEventResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TTutorialMessageEvent (instance size 28, VMT 557D0EA0): +$18 FMessage. }
  TTutorialMessageEvent = class(TFlagEvent)
  public
    FMessage: TStringList;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Trigger(Player: Shortint): Boolean; override;
  end;

  { TTutorialMessageEventResource (instance size 52, VMT 557D104C): no additional fields. }
  TTutorialMessageEventResource = class(TFlagEventResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterFlagEvents(AEngine: TEngine);

implementation

type
  { needs: AoWE.TAoWMapField.GetPlayer must return Shortint (557D11BB).
    The procedural cast calls the existing method with its recovered ABI. }
  PFlagMapView = ^TFlagMapView;
  TFlagMapView = record Reserved: array[0..$A4] of Byte; SeatedPlayer: Shortint; end;
  TMessageLogView = class(TObject) Reserved: array[4..$17] of Byte; Message: TStrings; HelpFile: string; end;

function MapFieldGetPlayer(MapField: TAoWMapField): Shortint; assembler;
asm jmp TAoWMapField.GetPlayer end;

procedure TFlagEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FTriggerPlayers, 30);
  Stream.rwData(FTriggerMode, SizeOf(FTriggerMode), 31);
end;

function TFlagEvent.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Result := True;
end;

function TFlagEvent.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  { needs: AoWE.AoWHSMap global; original tests msEditting in its Status at 557D1158. }
  Result := msEditting in AoWHSMap.Status;
end;

function TFlagEvent.GetTriggerPlayer(Player: Shortint): Boolean;
begin
  Result := (Player > 0) and ((FTriggerPlayers and (1 shl (Player - 1))) <> 0);
end;

procedure TFlagEvent.SetTriggerPlayer(Player: Shortint; Value: Boolean);
begin
  if Player > 0 then
    if not Value then
      FTriggerPlayers := FTriggerPlayers and not (1 shl (Player - 1))
    else
      FTriggerPlayers := FTriggerPlayers or (1 shl (Player - 1));
end;

function TFlagEvent.Trigger(Player: Shortint): Boolean;
begin
  Result := True;
end;

procedure TFlagEvent.UpdateInstantTrigger;
var
  Player: Shortint;
begin
  Player := MapFieldGetPlayer(TAoWMapField(Owner));
  if (Player <> -1) and GetTriggerPlayer(Player) and Trigger(Player) then
    SetTriggerPlayer(Player, False);
end;

procedure TFlagEvent.UpdateNewTurnTrigger(Player: Shortint);
begin
  if (Player = MapFieldGetPlayer(TAoWMapField(Owner))) and
    GetTriggerPlayer(Player) and Trigger(Player) then
    SetTriggerPlayer(Player, False);
end;

procedure TFlagEvent.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if (Msg.MsgID = $110D) and (FTriggerMode = etmInstant) then
    UpdateInstantTrigger;
end;

procedure TFlagEvent.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020003) and (FTriggerMode = etmNewTurn) then
    UpdateNewTurnTrigger(Shortint(Msg.Value));
end;

procedure TFlagEvent.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  if msEditting in AoWHSMap.Status then inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

constructor TFlagEventResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  Level := 27;
end;

procedure TFlagEventResource.SetLevel(Value: Byte);
begin
  inherited SetLevel(27);
end;

constructor TFlagMessageEvent.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMessage := TStringList.Create;
end;

destructor TFlagMessageEvent.Destroy;
begin
  FMessage.Free;
  inherited Destroy;
end;

class function TFlagMessageEvent.ClassID: Integer;
begin
  Result := $2056D;
end;

procedure TFlagMessageEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FMessage, 40);
  Stream.rwString(FHelpFileName, 41);
end;

function TFlagMessageEvent.Trigger(Player: Shortint): Boolean;
var Log: TFlagMessageEventLog;
begin
  if PFlagMapView(AoWHSMap)^.SeatedPlayer = Player then
  begin
    Log := TFlagMessageEventLog.Create(nil);
    TMessageLogView(Log).HelpFile := FHelpFileName;
    TMessageLogView(Log).Message.Text := FMessage.Text;
    AoWHSMap.TriggerExecuteEventLog(Integer(Log), Ord(FTriggerMode = etmInstant), 0, 0);
    Log.Release;
  end;
  Result := True;
end;

class function TFlagMessageEventResource.ClassID: Integer;
begin
  Result := $2056E;
end;

class function TFlagMessageEventResource.ResourceEditName: string;
begin
  { needs: AoWE.TranslateRStr(const S: string): string; pass its
    hidden result address explicitly until P1 corrects the declaration. }
  Result := AoWE.TranslateRStr(FlagMessageEventRStr);
end;

function TFlagMessageEventResource.ResourceUserClassID: Integer;
begin
  Result := $2056D;
end;

constructor TTutorialMessageEvent.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMessage := TStringList.Create;
end;

destructor TTutorialMessageEvent.Destroy;
begin
  FMessage.Free;
  inherited Destroy;
end;

class function TTutorialMessageEvent.ClassID: Integer;
begin
  Result := $2056B;
end;

procedure TTutorialMessageEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FMessage, 40);
end;

function TTutorialMessageEvent.Trigger(Player: Shortint): Boolean;
var Log: TTutorialMessageEventLog;
begin
  if PFlagMapView(AoWHSMap)^.SeatedPlayer = Player then
  begin
    Log := TTutorialMessageEventLog.Create(nil);
    TMessageLogView(Log).Message.Text := FMessage.Text;
    AoWHSMap.TriggerExecuteEventLog(Integer(Log), Ord(FTriggerMode = etmInstant), 0, 0);
    Log.Release;
  end;
  Result := True;
end;

class function TTutorialMessageEventResource.ClassID: Integer;
begin
  Result := $2056C;
end;

class function TTutorialMessageEventResource.ResourceEditName: string;
begin
  { needs: AoWE.TranslateRStr(const S: string): string; pass its
    hidden result address explicitly until P1 corrects the declaration. }
  Result := AoWE.TranslateRStr(TutorialMessageEventRStr);
end;

function TTutorialMessageEventResource.ResourceUserClassID: Integer;
begin
  Result := $2056B;
end;

procedure RegisterFlagEvents(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TFlagMessageEvent, TFlagMessageEventResource,
    TTutorialMessageEvent, TTutorialMessageEventResource]);
end;

initialization
finalization

end.
