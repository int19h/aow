unit Teleport;

{ Draft declarations of Teleport, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TTeleport = class;
  TTeleportResource = class;


  { TTeleport (instance size 52, VMT 557A4A28) }
  TTeleport = class(TStructure)
  public
    F_Teleport_30: Byte;
    F_Teleport_31: Byte;
    F_Teleport_32: Byte;
    F_Teleport_33: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure MoveExclusive(const Info: HSEngine.THSSenderInfo); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure SetRazed(A1: Integer); override;
    procedure GetRazed; override;
    procedure ValidateMap(A1: Integer); override;
    procedure ShowTeleportAnimations;  { draft }
    procedure CanTeleportArmy(A1: Integer; A2: Integer);  { draft }
    procedure CanTeleport(A1: Integer);  { draft }
    procedure Teleport(A1: Byte);  { draft }
  end;

  { TTeleportResource (instance size 100, VMT 557A4C88) }
  TTeleportResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterTeleport;  { draft }

implementation

constructor TTeleport.Create(AOwner: Engine.TECustomNode);
begin end;

class function TTeleport.ClassID: Integer;
begin Result := 0; end;

procedure TTeleport.GetRazed;
begin end;

procedure TTeleport.SetRazed(A1: Integer);
begin end;

procedure TTeleport.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTeleport.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TTeleport.MoveExclusive(const Info: HSEngine.THSSenderInfo);
begin end;

procedure TTeleport.ShowTeleportAnimations;
begin end;

procedure TTeleport.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TTeleport.Activate;
begin end;

procedure TTeleport.Deactivate;
begin end;

procedure TTeleport.CanTeleportArmy(A1: Integer; A2: Integer);
begin end;

procedure TTeleport.CanTeleport(A1: Integer);
begin end;

procedure TTeleport.Teleport(A1: Byte);
begin end;

procedure TTeleport.ValidateMap(A1: Integer);
begin end;

constructor TTeleportResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TTeleportResource.ClassID: Integer;
begin Result := 0; end;

class function TTeleportResource.ResourceEditName: string;
begin Result := ''; end;

function TTeleportResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterTeleport;
begin end;


initialization
finalization

end.
