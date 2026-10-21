unit HSSetDlg;

{ Draft declarations of HSSetDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWDlg, checklst;

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
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  end;


implementation

procedure THSSetDialog.FormCreate(Sender: TObject);
var
  I: Integer;
  PlugIn: TPlugIn;
begin
  HSSNameEdit.Text := AoWHSSet.Name;
  with PlugInListBox do
  begin
    Items.Clear;
    I := 0;
    PlugIn := GetPlugIn(I);
    while PlugIn <> nil do
    begin
      Checked[Items.Add(PlugIn.Name)] := AoWHSSet.PlugInControl.UsedPlugIns.IndexOf(PlugIn.Name) <> -1;
      Inc(I);
      PlugIn := GetPlugIn(I);
    end;
  end;
end;


procedure THSSetDialog.OKBtnClick(Sender: TObject);
var I: Integer;
begin
  AoWHSSet.Name := HSSNameEdit.Text;
  with PlugInListBox do
  begin
    for I := Items.Count - 1 downto 0 do
      if not Checked[I] then Items.Delete(I);
    AoWHSSet.PlugInControl.UsedPlugIns := Items;
  end;
end;



end.
