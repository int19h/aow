unit ItemSel;

{ Draft declarations of ItemSel, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWDlg;

type
  TItemSelectionDlg = class;


  { TItemSelectionDlg (instance size 524, VMT 004128BC) }
  TItemSelectionDlg = class(TAoWDialog)
  public
    published
    Panel1: TPanel; { +01E0 }
    CancelBtn: TButton; { +01E4 }
    OKBtn: TButton; { +01E8 }
    ClientPnl: TPanel; { +01EC }
    MainPageControl: TPageControl; { +01F0 }
    GeneralSheet: TTabSheet; { +01F4 }
    ItemGrid: TImageDrawGrid; { +01F8 }
    Label1: TLabel; { +01FC }
    public
    F_ItemSelectionDlg_200: Byte;
    F_ItemSelectionDlg_201: array[0..2] of Byte;
    F_ItemSelectionDlg_204: Integer;
    F_ItemSelectionDlg_208: Integer;
    procedure ItemGridCellUpdated(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure FormCreate;  { draft }
    procedure FormDeactivate;  { draft }
    procedure OKBtnClick;  { draft }
  end;


implementation

procedure TItemSelectionDlg.ItemGridCellUpdated(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TItemSelectionDlg.FormCreate;
begin end;

procedure TItemSelectionDlg.FormDeactivate;
begin end;

procedure TItemSelectionDlg.OKBtnClick;
begin end;


end.
