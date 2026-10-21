unit Scanner;

{ Draft declarations of Scanner, from AOWTools.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWControl;

type
  TScanner = class;

  TOType = (otBuilding, otArmy, otNatural);  { ot=1 }

  { TScanner (instance size 388, VMT 5970213C) }
  TScanner = class(TAOWControl)
  public
    F_Scanner_114: Integer;
    F_Scanner_118: array[0..31] of Byte;
    F_Scanner_138: Byte;
    F_Scanner_139: Byte;
    F_Scanner_13A: Byte;
    F_Scanner_13B: Byte;
    F_Scanner_13C: array[0..3] of Byte;
    F_Scanner_140: Integer;
    F_Scanner_144: array[0..3] of Byte;
    F_Scanner_148: Integer;
    F_Scanner_14C: array[0..7] of Byte;
    F_Scanner_154: Integer;
    F_Scanner_158: Integer;
    F_Scanner_15C: Integer;
    F_Scanner_160: Byte;
    F_Scanner_161: array[0..2] of Byte;
    F_Scanner_164: Byte;
    F_Scanner_165: array[0..2] of Byte;
    F_Scanner_168: Byte;
    F_Scanner_169: array[0..6] of Byte;
    F_Scanner_170: Integer;
    F_Scanner_174: Integer;
    F_Scanner_178: Integer;
    F_Scanner_17C: Integer;
    F_Scanner_180: Byte;
    F_Scanner_181: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure SetILFrame(A1: Integer); virtual;  { +098 draft }
    procedure SetILFIndex(A1: Integer);  { draft }
    procedure SetObjIL(A1: Integer);  { draft }
    procedure SetArmies(A1: Byte);  { draft }
    procedure SetBuildings(A1: Byte);  { draft }
    procedure SetNaturals(A1: Byte);  { draft }
    procedure SetLevel(A1: Integer);  { draft }
    procedure SetMapWidth(A1: Integer);  { draft }
    procedure SetMapHeight(A1: Integer);  { draft }
    function GetTerrain(A1: Integer; A2: Integer): Byte;  { draft }
    procedure SetTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function GetOverlay(A1: Integer; A2: Integer): Integer;  { draft }
    procedure SetOverlay(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function GetExplored(A1: Integer; A2: Integer): Integer;  { draft }
    procedure SetExplored(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetObject(A1: Integer; A2: Integer);  { draft }
    function GetObjectSize: Byte;  { draft }
    procedure SetObjectSize(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetImgLib(A1: Integer);  { draft }
    procedure SetHimgLib(A1: Integer);  { draft }
    procedure SetFogimgLib(A1: Integer);  { draft }
    procedure SetSteps(A1: Integer);  { draft }
    procedure SetObDrawn(A1: Integer);  { draft }
    procedure SetTLeft(A1: Integer);  { draft }
    procedure SetTTop(A1: Integer);  { draft }
    procedure SetTWidth(A1: Integer);  { draft }
    procedure SetTHeight(A1: Integer);  { draft }
    procedure SetMap(A1: Integer);  { draft }
    procedure DrawMap(A1: Integer; A2: Integer);  { draft }
    procedure DrawObjects;  { draft }
  end;

procedure Register;

implementation

constructor TScanner.Create(AOwner: Classes.TComponent);
begin end;

destructor TScanner.Destroy;
begin end;

procedure TScanner.SetILFIndex(A1: Integer);
begin end;

procedure TScanner.SetILFrame(A1: Integer);
begin end;

procedure TScanner.SetObjIL(A1: Integer);
begin end;

procedure TScanner.SetArmies(A1: Byte);
begin end;

procedure TScanner.SetBuildings(A1: Byte);
begin end;

procedure TScanner.SetNaturals(A1: Byte);
begin end;

procedure TScanner.SetLevel(A1: Integer);
begin end;

procedure TScanner.SetMapWidth(A1: Integer);
begin end;

procedure TScanner.SetMapHeight(A1: Integer);
begin end;

function TScanner.GetTerrain(A1: Integer; A2: Integer): Byte;
begin Result := 0; end;

procedure TScanner.SetTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TScanner.GetOverlay(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TScanner.SetOverlay(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TScanner.GetExplored(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TScanner.SetExplored(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TScanner.GetObject(A1: Integer; A2: Integer);
begin end;

function TScanner.GetObjectSize: Byte;
begin Result := 0; end;

procedure TScanner.SetObjectSize(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TScanner.SetImgLib(A1: Integer);
begin end;

procedure TScanner.SetHimgLib(A1: Integer);
begin end;

procedure TScanner.SetFogimgLib(A1: Integer);
begin end;

procedure TScanner.SetSteps(A1: Integer);
begin end;

procedure TScanner.SetObDrawn(A1: Integer);
begin end;

procedure TScanner.Update;
begin end;

procedure TScanner.SetTLeft(A1: Integer);
begin end;

procedure TScanner.SetTTop(A1: Integer);
begin end;

procedure TScanner.SetTWidth(A1: Integer);
begin end;

procedure TScanner.SetTHeight(A1: Integer);
begin end;

procedure TScanner.SetMap(A1: Integer);
begin end;

procedure TScanner.Validate;
begin end;

procedure TScanner.SetSize;
begin end;

procedure TScanner.DrawMap(A1: Integer; A2: Integer);
begin end;

procedure TScanner.DrawObjects;
begin end;

procedure TScanner.Draw(SurfDesc: GFXE.TSurfaceDesc);
begin end;

procedure TScanner.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TScanner.CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TScanner.CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure Register;
begin
  RegisterComponents('AOW Tools', [TScanner]);
end;


initialization
finalization

end.
