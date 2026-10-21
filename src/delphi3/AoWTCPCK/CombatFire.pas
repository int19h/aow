unit CombatFire;

{ Draft declarations of CombatFire, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TCombatFire = class;
  TCombatFireResource = class;


  { TCombatFire (instance size 28, VMT 00406B24) }
  TCombatFire = class(TSingleHS)
  public
    F_CombatFire_0C: Integer;
    F_CombatFire_10: Integer;
    F_CombatFire_14: Integer;
    F_CombatFire_18: Byte;
    F_CombatFire_19: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    procedure SetVisible(Value: Boolean); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    procedure NewTurn;  { draft }
  end;

  { TCombatFireResource (instance size 68, VMT 00406CA8) }
  TCombatFireResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure CreateFire(A1: Byte; A2: Integer; A3: Integer; A4: Integer);  { draft }
procedure RegisterCombatFire(A1: Integer);  { draft }

implementation

procedure TCombatFire.Deactivate;
begin end;

constructor TCombatFire.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombatFire.Destroy;
begin end;

procedure TCombatFire.SetVisible(Value: Boolean);
begin end;

procedure TCombatFire.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

class function TCombatFire.ClassID: Integer;
begin Result := 0; end;

function TCombatFire.GetLevel: Byte;
begin Result := 0; end;

function TCombatFire.GetShowPriority: Integer;
begin Result := 0; end;

procedure TCombatFire.Activate;
begin end;

procedure TCombatFire.NewTurn;
begin end;

procedure TCombatFire.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TCombatFire.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCombatFire.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

class function TCombatFireResource.ClassID: Integer;
begin Result := 0; end;

class function TCombatFireResource.ResourceEditName: string;
begin Result := ''; end;

function TCombatFireResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure CreateFire(A1: Byte; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure RegisterCombatFire(A1: Integer);
begin end;


initialization
finalization

end.
