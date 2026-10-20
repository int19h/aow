unit PoisonC;

{ Draft declarations of PoisonC, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TPoisonCloud = class;
  TPoisonCloudResource = class;


  { TPoisonCloud (instance size 32, VMT 557CA640) }
  TPoisonCloud = class(TMultiHexMO)
  public
    F_PoisonCloud_14: Byte;
    F_PoisonCloud_15: array[0..2] of Byte;
    F_PoisonCloud_18: Integer;
    F_PoisonCloud_1C: Byte;
    F_PoisonCloud_1D: Byte;
    F_PoisonCloud_1E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetShowPriority: Integer; override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure UpdateMapFields(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure CanDoDamage(A1: Integer);  { draft }
    procedure ArmyPlaced(A1: Integer);  { draft }
    procedure TriggerDamage;  { draft }
    procedure ValidMoveDir(A1: Integer);  { draft }
    procedure UpdateCloud;  { draft }
  end;

  { TPoisonCloudResource (instance size 68, VMT 557CA7E0) }
  TPoisonCloudResource = class(TMultiHexMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterPoisonCloud;  { draft }

implementation

constructor TPoisonCloud.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPoisonCloud.ClassID: Integer;
begin Result := 0; end;

function TPoisonCloud.GetShowPriority: Integer;
begin Result := 0; end;

function TPoisonCloud.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TPoisonCloud.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

function TPoisonCloud.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TPoisonCloud.UpdateMapFields(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPoisonCloud.RemoveFromMap;
begin end;

function TPoisonCloud.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TPoisonCloud.CanDoDamage(A1: Integer);
begin end;

procedure TPoisonCloud.ArmyPlaced(A1: Integer);
begin end;

procedure TPoisonCloud.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPoisonCloud.TriggerDamage;
begin end;

procedure TPoisonCloud.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TPoisonCloud.Activate;
begin end;

procedure TPoisonCloud.ValidMoveDir(A1: Integer);
begin end;

procedure TPoisonCloud.UpdateCloud;
begin end;

procedure TPoisonCloud.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

class function TPoisonCloudResource.ClassID: Integer;
begin Result := 0; end;

class function TPoisonCloudResource.ResourceEditName: string;
begin Result := ''; end;

function TPoisonCloudResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterPoisonCloud;
begin end;


initialization
finalization

end.
