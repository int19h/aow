unit UnitTabC;

{ Draft declarations of UnitTabC, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TUnitTabControl = class;


  { TUnitTabControl (instance size 336, VMT 55800EA4) }
  TUnitTabControl = class(TTabControl)
  public
    F_UnitTabControl_140: array[0..3] of Byte;
    F_UnitTabControl_144: Integer;
    F_UnitTabControl_148: array[0..7] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Change;  { draft }
    procedure SetUnitIndexGrid(A1: Integer);  { draft }
    procedure UnitIndexGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure UpdateUnitIndexGrid;  { draft }
    procedure UpdateSelection;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TUnitTabControl.Create(AOwner: Classes.TComponent);
begin end;

destructor TUnitTabControl.Destroy;
begin end;

procedure TUnitTabControl.Change;
begin end;

procedure TUnitTabControl.SetUnitIndexGrid(A1: Integer);
begin end;

procedure TUnitTabControl.UnitIndexGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitTabControl.UpdateUnitIndexGrid;
begin end;

procedure TUnitTabControl.UpdateSelection;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
