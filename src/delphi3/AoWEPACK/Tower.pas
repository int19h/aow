unit Tower;

{ Draft declarations of Tower, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TTower = class;
  TTowerResource = class;
  TTowerConstructionControl = class;


  { TTower (instance size 64, VMT 557C31A8) }
  TTower = class(TPlayerStructure)
  public
    F_Tower_3C: Byte;
    F_Tower_3D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Priority: Integer); override;
    procedure VisibilityRange; override;
    procedure GetDefaultAITargetPriority; override;
  end;

  { TTowerResource (instance size 116, VMT 557C3434) }
  TTowerResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TTowerConstructionControl (instance size 8, VMT 557C352C) }
  TTowerConstructionControl = class(TStructureConstructionControl)
  public
    procedure GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure CanConstruct(A1: Integer; A2: Integer); override;
    procedure ID; override;
    procedure StructureResource(A1: Integer; A2: Integer); override;
  end;

procedure RegisterTower;  { draft }

implementation

class function TTower.ClassID: Integer;
begin Result := 0; end;

procedure TTower.VisibilityRange;
begin end;

procedure TTower.GetDefaultAITargetPriority;
begin end;

procedure TTower.UpdateAITarget(const Info: TAITargetInfo; var Priority: Integer);
begin end;

function TTower.GetRazed: Boolean;
begin end;

procedure TTower.SetRazed(Value: Boolean);
begin end;

procedure TTower.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTower.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

constructor TTowerResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TTowerResource.ResourceEditName: string;
begin Result := ''; end;

class function TTowerResource.ClassID: Integer;
begin Result := 0; end;

function TTowerResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TTowerConstructionControl.ID;
begin end;

procedure TTowerConstructionControl.StructureResource(A1: Integer; A2: Integer);
begin end;

procedure TTowerConstructionControl.GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTowerConstructionControl.CanConstruct(A1: Integer; A2: Integer);
begin end;

procedure RegisterTower;
begin end;


initialization
finalization

end.
