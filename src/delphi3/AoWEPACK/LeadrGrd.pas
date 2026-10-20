unit LeadrGrd;

{ Draft declarations of LeadrGrd, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TLeaderGrid = class;


  { TLeaderGrid (instance size 488, VMT 55803A10) }
  TLeaderGrid = class(TCustomImageDrawGrid)
  public
    F_LeaderGrid_1DC: array[0..3] of Byte;
    F_LeaderGrid_1E0: Integer;
    F_LeaderGrid_1E4: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure LeadersUpdated;  { draft }
    procedure SetAoWHSMap(A1: Integer);  { draft }
    procedure GetLeader(A1: Integer);  { draft }
    procedure GetSelectedLeader;  { draft }
    procedure SetSelectedLeader(A1: Integer);  { draft }
    procedure RemoveFromMap;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TLeaderGrid.Create(AOwner: Classes.TComponent);
begin end;

destructor TLeaderGrid.Destroy;
begin end;

procedure TLeaderGrid.LeadersUpdated;
begin end;

procedure TLeaderGrid.SetAoWHSMap(A1: Integer);
begin end;

procedure TLeaderGrid.GetLeader(A1: Integer);
begin end;

procedure TLeaderGrid.GetSelectedLeader;
begin end;

procedure TLeaderGrid.SetSelectedLeader(A1: Integer);
begin end;

procedure TLeaderGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure TLeaderGrid.RemoveFromMap;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
