unit TextCtrlEd;

{ Draft declarations of TextCtrlEd, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, SpinEdit;

type
  TTextControlEditForm = class;


  { TTextControlEditForm (instance size 532, VMT 00421798) }
  TTextControlEditForm = class(TForm)
  public
    published
    Panel10: TPanel; { +01DC }
    Label7: TLabel; { +01E0 }
    TextIDEdit: TSpin; { +01E4 }
    TextMemo: TMemo; { +01E8 }
    NewText: TButton; { +01EC }
    DeleteText: TButton; { +01F0 }
    FindText: TButton; { +01F4 }
    TextScrollBar: TScrollBar; { +01F8 }
    CloseBtn: TButton; { +01FC }
    Label1: TLabel; { +0200 }
    Label2: TLabel; { +0204 }
    DescriptionEdit: TEdit; { +0208 }
    public
    F_TextControlEditForm_20C: Integer;
    F_TextControlEditForm_210: Integer;
    procedure TextIDEditChange;  { draft }
    procedure NewTextClick;  { draft }
    procedure DeleteTextClick;  { draft }
    procedure FindTextClick;  { draft }
    procedure TextMemoChange;  { draft }
    procedure TextScrollBarChange;  { draft }
    procedure DescriptionEditChange;  { draft }
  end;


implementation

procedure TTextControlEditForm.TextIDEditChange;
begin end;

procedure TTextControlEditForm.NewTextClick;
begin end;

procedure TTextControlEditForm.DeleteTextClick;
begin end;

procedure TTextControlEditForm.FindTextClick;
begin end;

procedure TTextControlEditForm.TextMemoChange;
begin end;

procedure TTextControlEditForm.TextScrollBarChange;
begin end;

procedure TTextControlEditForm.DescriptionEditChange;
begin end;


end.
