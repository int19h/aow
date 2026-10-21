unit HSSetDlg;

{ Draft declarations of HSSetDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWDlg, checklst;

type
  THSSetDialog = class;


  { THSSetDialog (instance size 512, VMT 004240A8) }
  THSSetDialog = class(TAoWDialog)
  public
    published
    Panel1: TPanel; { +01E0 }
    GroupBox1: TGroupBox; { +01E4 }
    Label1: TLabel; { +01E8 }
    HSSNameEdit: TEdit; { +01EC }
    Label2: TLabel; { +01F0 }
    PlugInListBox: TCheckListBox; { +01F4 }
    OKBtn: TButton; { +01F8 }
    CancelBtn: TButton; { +01FC }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
  end;


implementation

procedure THSSetDialog.FormCreate;
begin end;

procedure THSSetDialog.OKBtnClick;
begin end;


end.
