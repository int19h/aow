unit EFaceRes;

{ EFaceRes editor routines recovered from AoWEd.exe. Remaining stubs are marked draft. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWREFrm, SpinEdit, AoWE;

type
  TFaceResourceEditForm = class;
  TFaceResourceEditor = class;


  { TFaceResourceEditForm: size $22C; $228 edited face resource. VMT 00416C1C. }
  TFaceResourceEditForm = class(TAoWResourceEditForm)
  public
    published
    MainPageControl: TPageControl; { +01FC }
    SettingsSheet: TTabSheet; { +0200 }
    ImageSheet: TTabSheet; { +0204 }
    GroupBox4: TGroupBox; { +0208 }
    Label1: TLabel; { +020C }
    Label2: TLabel; { +0210 }
    ImagePanel: TImageLibraryPanel; { +0214 }
    ImageLibraryPreviewGrid: TImageLibraryGrid; { +0218 }
    ILManagerComboBox: TILManagerComboBox; { +021C }
    ImageIndexSpin: TSpin; { +0220 }
    DesignerOnlyBox: TCheckBox; { +0224 }
    public
    FFaceResource: TFaceResource; { $228 }
    constructor vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent); override;
    procedure FormCreate;
    procedure OKBtnClick;
    procedure ILManagerComboBoxChange;
    procedure ImageIndexSpinUpdate;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

  { TFaceResourceEditor (instance size 8, VMT 00416E98) }
  TFaceResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TFaceResourceEditor.EditorClassID: Integer;
begin Result := $20270; end;


class procedure TFaceResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TFaceResourceEditForm.vmt80(AEngine, TEResource(Obj), Done);
end;


constructor TFaceResourceEditForm.vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent);
begin
  FFaceResource := TFaceResource(Resource);
  inherited vmt80(AEngine, Resource, Done);
end;


procedure TFaceResourceEditForm.FormCreate;
begin
  MainPageControl.ActivePage := ImageSheet;
  with FFaceResource do
  begin
    AddRef;
    DesignerOnlyBox.Checked := FDeveloperOnly;
    ILManagerComboBox.ILManager := AoWHSSet.ImageLibraryManager;
    ILManagerComboBox.ImageLibraryName := FImageLibraryName;
    ImagePanel.ImageLibrary := FImageLibrary;
    ImagePanel.ImageIndex := FImageIndex;
    ImageLibraryPreviewGrid.ImageLibrary := FImageLibrary;
    ImageIndexSpin.Value := FImageIndex;
  end;
end;


procedure TFaceResourceEditForm.OKBtnClick;
begin
  with FFaceResource do FDeveloperOnly := DesignerOnlyBox.Checked;
end;


procedure TFaceResourceEditForm.ILManagerComboBoxChange;
begin
  with FFaceResource do
  begin
    SetImageLibraryName(ILManagerComboBox.ImageLibraryName);
    ImagePanel.ImageLibrary := FImageLibrary;
    ImageLibraryPreviewGrid.ImageLibrary := FImageLibrary;
  end;
end;


procedure TFaceResourceEditForm.ImageIndexSpinUpdate;
begin
  with FFaceResource do FImageIndex := ImageIndexSpin.Value;
  ImagePanel.ImageIndex := ImageIndexSpin.Value;
end;


procedure TFaceResourceEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FFaceResource.Release;
  inherited FormClose(Sender, Action);
end;



end.
