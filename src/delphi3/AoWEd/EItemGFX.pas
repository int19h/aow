unit EItemGFX;

{ Draft declarations of EItemGFX, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWREFrm, SpinEdit;

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
    F_ItemGFXEditForm_22C: Integer;
    constructor vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent); override;
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
    procedure ILManagerComboBoxChange;  { draft }
    procedure ImageIndexSpinUpdate;  { draft }
    procedure FormClose(A1: Integer; A2: Integer);  { draft }
  end;

  { TItemGFXEditor (instance size 8, VMT 00416934) }
  TItemGFXEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TItemGFXEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

constructor TItemGFXEditForm.vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent);
begin end;

procedure TItemGFXEditForm.FormCreate;
begin end;

procedure TItemGFXEditForm.OKBtnClick;
begin end;

procedure TItemGFXEditForm.ILManagerComboBoxChange;
begin end;

procedure TItemGFXEditForm.ImageIndexSpinUpdate;
begin end;

procedure TItemGFXEditForm.FormClose(A1: Integer; A2: Integer);
begin end;


end.
