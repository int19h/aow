unit FaceSel;

{ Draft declarations of FaceSel, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWDlg;

type
  TFaceSelectionDlg = class;


  { TFaceSelectionDlg (instance size 524, VMT 00411AA4) }
  TFaceSelectionDlg = class(TAoWDialog)
  public
    published
    Panel1: TPanel; { +01E0 }
    CancelBtn: TButton; { +01E4 }
    OKBtn: TButton; { +01E8 }
    ClientPnl: TPanel; { +01EC }
    MainPageControl: TPageControl; { +01F0 }
    GeneralSheet: TTabSheet; { +01F4 }
    FacesGrid: TImageDrawGrid; { +01F8 }
    Label1: TLabel; { +01FC }
    Translator: TIvTranslator; { +0200 }
    public
    F_FaceSelectionDlg_204: Integer;
    F_FaceSelectionDlg_208: Integer;
    procedure FacesGridCellUpdated(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure FormCreate;  { draft }
    procedure FormDeactivate;  { draft }
    procedure OKBtnClick;  { draft }
  end;


implementation

procedure TFaceSelectionDlg.FacesGridCellUpdated(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TFaceSelectionDlg.FormCreate;
begin end;

procedure TFaceSelectionDlg.FormDeactivate;
begin end;

procedure TFaceSelectionDlg.OKBtnClick;
begin end;


end.
