unit Tower;

{ Tower of AoWEPACK.dpl: original instance layouts; TTowerResource recovered.
  TTower and TTowerConstructionControl remain draft bodies. }

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
    procedure UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer); override;
    procedure VisibilityRange; override;
    procedure GetDefaultAITargetPriority; override;
  end;

  { TTowerResource (instance size 116, VMT 557C3434): no additional fields. }
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
    procedure GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer); override;
    procedure CanConstruct(A1: Integer; A2: Integer); override;
    function ID: Integer; override;
    function StructureResource(AUnit: TAbstractUnit): TStructureResource; override;
  end;

procedure RegisterTower;  { draft }

implementation

class function TTower.ClassID: Integer;
begin Result := 0; end;

procedure TTower.VisibilityRange;
begin end;

procedure TTower.GetDefaultAITargetPriority;
begin end;

procedure TTower.UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer);
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
begin
  inherited Create(AOwner);
  FTerrainBound := True;
  FClaimed := False;
  FRazeable := True;
  FRazeDefenderBudget := 50;
  FRebuildGold := 25;
  FRebuildDays := 2;
end;

class function TTowerResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@TowerRStr)); end;

class function TTowerResource.ClassID: Integer;
begin Result := $2043F; end;

function TTowerResource.ResourceUserClassID: Integer;
begin Result := $2043E; end;

function TTowerConstructionControl.ID: Integer;
begin Result := 0; end;

function TTowerConstructionControl.StructureResource(AUnit: TAbstractUnit): TStructureResource;
begin Result := nil; end;

procedure TTowerConstructionControl.GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer);
begin end;

procedure TTowerConstructionControl.CanConstruct(A1: Integer; A2: Integer);
begin end;

procedure RegisterTower;
begin end;


initialization
finalization

end.
