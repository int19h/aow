unit MoveOnEvents;

{ Draft declarations of MoveOnEvents, from AoWEPACK.dpl.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Bodies recovered from the original instruction stream; declaration workarounds are marked needs. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, EventLog, AoWE;

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
    FRadius: Byte; { $10 }
    FReserved11: array[0..2] of Byte; { $11 }
    FTriggerPlayers: Integer; { $14 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure MovedOnTrigger(Player: Shortint); virtual;  { +11C }
    procedure ArmyPlaced(Army: Pointer); virtual;  { +120 }
    function GetTriggerPlayer(Player: Shortint): Boolean;
    procedure SetTriggerPlayer(Player: Shortint; Value: Boolean);
    procedure SetRadius(Value: Byte);
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
    FSongFileName: string; { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MovedOnTrigger(Player: Shortint); override;
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
    FSampleFileName: string; { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MovedOnTrigger(Player: Shortint); override;
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
    FMessage: TStringList; { $18 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MovedOnTrigger(Player: Shortint); override;
  end;

  { TShowMessageMoveOnEventResource (instance size 52, VMT 557D3434) }
  TShowMessageMoveOnEventResource = class(TMoveOnEventResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMoveOnEvents(AEngine: TEngine);

implementation

type
  PPlayerID = ^Shortint;
  PObjectAddress = ^Integer;
  PMapView = ^TMapView;
  TMapView = record
    Reserved: array[0..$A4] of Byte;
    SeatedPlayer: Shortint;
  end;
  PPlayerView = ^TPlayerView;
  TPlayerView = record
    Reserved: array[0..$11] of Byte;
    ID: Shortint;
  end;
  PArmyView = ^TArmyView;
  TArmyView = record
    Reserved: array[0..$1B] of Byte;
    Player: PPlayerView;
  end;

function TMoveOnEvent.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Result := True;
end;

function TMoveOnEvent.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  Result := msEditting in AoWHSMap.Status;
end;

function TMoveOnEvent.GetTriggerPlayer(Player: Shortint): Boolean;
begin
  Result := (Player > 0) and ((FTriggerPlayers and (1 shl (Player - 1))) <> 0);
end;

procedure TMoveOnEvent.SetTriggerPlayer(Player: Shortint; Value: Boolean);
begin
  if Player > 0 then
    if not Value then FTriggerPlayers := FTriggerPlayers and not (1 shl (Player - 1))
    else FTriggerPlayers := FTriggerPlayers or (1 shl (Player - 1));
end;

procedure TMoveOnEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FTriggerPlayers, 30);
  Stream.rwByte(FRadius, 31);
end;

procedure TMoveOnEvent.Activate;
begin
  inherited Activate;
end;

procedure TMoveOnEvent.Deactivate;
begin
  inherited Deactivate;
end;

procedure TMoveOnEvent.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  if msEditting in AoWHSMap.Status then inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

procedure TMoveOnEvent.MovedOnTrigger(Player: Shortint);
begin
end;

procedure TMoveOnEvent.ArmyPlaced(Army: Pointer);
begin
  { needs: the army-view player reference at +$1C, player id at +$12 (557D35DA). }
  if GetTriggerPlayer(TArmyView(Army^).Player^.ID) then
  begin
    MovedOnTrigger(TArmyView(Army^).Player^.ID);
    if (FTriggerPlayers = 0) and not (msEditting in AoWHSMap.Status) then Destroy;
  end;
end;

procedure TMoveOnEvent.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1102 then ArmyPlaced(Pointer(Msg.Param[0]));
end;

procedure TMoveOnEvent.Connect;
var
  Walk: THNWalkData;
  MapLevel: TMapLevel;
  MapField: TMapField;
begin
  if not (moPlacedOnMap in FStatus) then
  begin
    FStatus := FStatus + [moPlacedOnMap];
    with TMapField(Owner) do
    begin
      MapLevel := TMapLevel(Owner);
      InitHNWalk(Walk, Xhx, Yhx, 0);
    end;
    with Walk do
    begin
    while Radius <= FRadius do
    begin
      if (X >= 0) and (Y >= 0) and (X < MapLevel.Width) and (Y < MapLevel.Height) then
      begin
        MapField := MapLevel.GetField(X, Y);
        if MapField = Owner then MapField.RemoveHS(Self);
        MapField.AddHS(Self, HN);
      end;
      WalkToNextHN(Walk);
    end;
    end;
  end;
end;

procedure TMoveOnEvent.Disconnect;
var
  Walk: THNWalkData;
  MapLevel: TMapLevel;
begin
  if moPlacedOnMap in FStatus then
  begin
    MapLevel := TMapLevel(Owner.Owner);
    FStatus := FStatus - [moPlacedOnMap];
    InitHNWalk(Walk, TMapField(Owner).Xhx, TMapField(Owner).Yhx, 0);
    while Walk.Radius <= FRadius do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
        MapLevel.GetField(Walk.X, Walk.Y).RemoveHS(Self);
      WalkToNextHN(Walk);
    end;
    FStatus := FStatus - [moPlacedOnMap];
    SetOwner(nil);
  end;
end;

procedure TMoveOnEvent.SetRadius(Value: Byte);
var
  MapField: TECustomNode;
begin
  if Value > 10 then Value := 10;
  if Value <> FRadius then
    if moPlacedOnMap in FStatus then
    begin
      MapField := Owner;
      Disconnect;
      FRadius := Value;
      SetOwner(MapField);
      Connect;
    end
    else FRadius := Value;
end;

constructor TMoveOnEventResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  Level := 27;
end;

procedure TMoveOnEventResource.SetLevel(Value: Byte);
begin
  inherited SetLevel(27);
end;

class function TMoveOnEventResource.ResourceEditName: string;
begin
  Result := 'MoveOnEvent';
end;

class function TChangeSongMoveOnEvent.ClassID: Integer;
begin Result := $2054B; end;

procedure TChangeSongMoveOnEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FSongFileName, 40);
end;

procedure TChangeSongMoveOnEvent.MovedOnTrigger(Player: Shortint);
begin
  { needs: seated-player field at AoWHSMap +$A5 (557D3878). }
  if Player = PMapView(AoWHSMap)^.SeatedPlayer then
    if CompareText(PlayingSongFileName, FSongFileName) <> 0 then
      PlaySongEx(FSongFileName, 2, 0, False);
  SetTriggerPlayer(Player, False);
end;

class function TChangeSongMoveOnEventResource.ResourceEditName: string;
begin
  { needs: TranslateRStr(const S: string): string; explicit hidden result. }
  Result := AoWE.TranslateRStr(ChangeSongEventRStr);
end;

class function TChangeSongMoveOnEventResource.ClassID: Integer;
begin Result := $2054C; end;

function TChangeSongMoveOnEventResource.ResourceUserClassID: Integer;
begin Result := $2054B; end;

class function TPlaySampleMoveOnEvent.ClassID: Integer;
begin Result := $2055D; end;

procedure TPlaySampleMoveOnEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FSampleFileName, 40);
end;

procedure TPlaySampleMoveOnEvent.MovedOnTrigger(Player: Shortint);
begin
  if Player = PMapView(AoWHSMap)^.SeatedPlayer then PlaySample(FSampleFileName);
  SetTriggerPlayer(Player, False);
end;

class function TPlaySampleMoveOnEventResource.ResourceEditName: string;
begin
  { needs: TranslateRStr(const S: string): string; explicit hidden result. }
  Result := AoWE.TranslateRStr(PlaySampleEventRStr);
end;

class function TPlaySampleMoveOnEventResource.ClassID: Integer;
begin Result := $2055E; end;

function TPlaySampleMoveOnEventResource.ResourceUserClassID: Integer;
begin Result := $2055D; end;

constructor TShowMessageMoveOnEvent.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMessage := TStringList.Create;
end;

destructor TShowMessageMoveOnEvent.Destroy;
begin
  FMessage.Free;
  inherited Destroy;
end;

class function TShowMessageMoveOnEvent.ClassID: Integer;
begin Result := $2054D; end;

procedure TShowMessageMoveOnEvent.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FMessage, 40);
end;

procedure TShowMessageMoveOnEvent.MovedOnTrigger(Player: Shortint);
var
  Log: TShowMessageEventLog;
begin
  if PMapView(AoWHSMap)^.SeatedPlayer = Player then
  begin
    Log := TShowMessageEventLog.Create(nil);
    Log.FMessage.Text := FMessage.Text;
    AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
    Log.Release;
  end;
  SetTriggerPlayer(Player, False);
end;

class function TShowMessageMoveOnEventResource.ResourceEditName: string;
begin
  { needs: TranslateRStr(const S: string): string; explicit hidden result. }
  Result := AoWE.TranslateRStr(ShowMessageEventRStr);
end;

class function TShowMessageMoveOnEventResource.ClassID: Integer;
begin Result := $2054E; end;

function TShowMessageMoveOnEventResource.ResourceUserClassID: Integer;
begin Result := $2054D; end;

procedure RegisterMoveOnEvents(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TChangeSongMoveOnEventResource, TChangeSongMoveOnEvent]);
  AEngine.RegisterEClasses([TPlaySampleMoveOnEventResource, TPlaySampleMoveOnEvent]);
  AEngine.RegisterEClasses([TShowMessageMoveOnEventResource, TShowMessageMoveOnEvent]);
end;

initialization
finalization

end.
