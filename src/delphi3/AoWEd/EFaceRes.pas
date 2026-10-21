unit EFaceRes;

{ Draft declarations of EFaceRes, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWREFrm, SpinEdit;

type
  TFaceResourceEditForm = class;
  TFaceResourceEditor = class;


  { TFaceResourceEditForm (instance size 556, VMT 00416C1C) }
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
    F_FaceResourceEditForm_228: Integer;
    function vmt80(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer; override;
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
    procedure ILManagerComboBoxChange;  { draft }
    procedure ImageIndexSpinUpdate;  { draft }
    procedure FormClose(A1: Integer; A2: Integer);  { draft }
  end;

  { TFaceResourceEditor (instance size 8, VMT 00416E98) }
  TFaceResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TFaceResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TFaceResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

function TFaceResourceEditForm.vmt80(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer;
begin Result := 0; end;

procedure TFaceResourceEditForm.FormCreate;
begin end;

procedure TFaceResourceEditForm.OKBtnClick;
begin end;

procedure TFaceResourceEditForm.ILManagerComboBoxChange;
begin end;

procedure TFaceResourceEditForm.ImageIndexSpinUpdate;
begin end;

procedure TFaceResourceEditForm.FormClose(A1: Integer; A2: Integer);
begin end;


end.
