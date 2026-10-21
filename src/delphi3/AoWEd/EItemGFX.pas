unit EItemGFX;

{ Draft declarations of EItemGFX, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TItemGFXEditForm $230 bytes; $22C FItemGFX is the edited resource. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWREFrm, SpinEdit;

type
  TItemGFXEditForm = class;
  TItemGFXEditor = class;


  { TItemGFXEditForm (instance size 560, VMT 004166B4) }
  TItemGFXEditForm = class(TAoWResourceEditForm)
  public
    published
    MainPageControl: TPageControl; { +01FC }
    ImageSheet: TTabSheet; { +0200 }
    GroupBox4: TGroupBox; { +0204 }
    Label1: TLabel; { +0208 }
    Label2: TLabel; { +020C }
    ImagePanel: TImageLibraryPanel; { +0210 }
    ImageLibraryPreviewGrid: TImageLibraryGrid; { +0214 }
    ILManagerComboBox: TILManagerComboBox; { +0218 }
    ImageIndexSpin: TSpin; { +021C }
    Label3: TLabel; { +0220 }
    ItemTypeBox: TComboBox; { +0224 }
    DesignerOnlyBox: TCheckBox; { +0228 }
    public
    FItemGFX: TItemGFX; { $22C }
    constructor vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent); override;
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
    procedure ILManagerComboBoxChange;  { draft }
    procedure ImageIndexSpinUpdate;  { draft }
    procedure FormClose(Sender: TObject; var Action: TCloseAction);  { draft }
  end;

  { TItemGFXEditor (instance size 8, VMT 00416934) }
  TItemGFXEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TItemGFXEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin TItemGFXEditForm.vmt80(AEngine, TEResource(Obj), Done); end;

constructor TItemGFXEditForm.vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent);
begin
  FItemGFX := TItemGFX(Resource);
  inherited vmt80(AEngine, Resource, Done);
end;

procedure TItemGFXEditForm.FormCreate;
begin
  with FItemGFX do
  begin
    AddRef;
    ItemTypeBox.ItemIndex := Ord(FItemType);
    DesignerOnlyBox.Checked := FHidden;
    ILManagerComboBox.ILManager := AoWHSSet.ImageLibraryManager;
    ILManagerComboBox.ImageLibraryName := FImageLibraryName;
    ImagePanel.ImageLibrary := FImageLibrary;
    ImagePanel.ImageIndex := FImageIndex;
    ImageLibraryPreviewGrid.ImageLibrary := FImageLibrary;
    ImageIndexSpin.Value := FImageIndex;
  end;
end;

procedure TItemGFXEditForm.OKBtnClick;
begin
  with FItemGFX do
  begin
    FItemType := TItemType(ItemTypeBox.ItemIndex);
    FHidden := DesignerOnlyBox.Checked;
  end;
end;

procedure TItemGFXEditForm.ILManagerComboBoxChange;
begin
  with FItemGFX do
  begin
    SetImageLibraryName(ILManagerComboBox.ImageLibraryName);
    ImagePanel.ImageLibrary := FImageLibrary;
    ImageLibraryPreviewGrid.ImageLibrary := FImageLibrary;
  end;
end;

procedure TItemGFXEditForm.ImageIndexSpinUpdate;
begin
  with FItemGFX do
  begin
    FImageIndex := ImageIndexSpin.Value;
    ImagePanel.ImageIndex := ImageIndexSpin.Value;
  end;
end;

procedure TItemGFXEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FItemGFX.Release;
  inherited FormClose(Sender, Action);
end;


end.
