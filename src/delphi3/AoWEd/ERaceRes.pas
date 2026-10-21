unit ERaceRes;

{ Draft declarations of ERaceRes, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AlgnmBox, AoWREFrm, UnitIGrd;

type
  TRaceResourceEditForm = class;
  TRaceResourceEditor = class;


  { TRaceResourceEditForm (instance size 632, VMT 00411264) }
  TRaceResourceEditForm = class(TAoWResourceEditForm)
  public
    published
    PageControl1: TPageControl; { +01FC }
    GeneralSheet: TTabSheet; { +0200 }
    UnitSheet: TTabSheet; { +0204 }
    Label1: TLabel; { +0208 }
    Label2: TLabel; { +020C }
    Label3: TLabel; { +0210 }
    Label4: TLabel; { +0214 }
    Label6: TLabel; { +0218 }
    ILManagerComboBox: TILManagerComboBox; { +021C }
    AlignmentBox: TAlignmentBox; { +0220 }
    RaceNameAdjectiveEdit: TEdit; { +0224 }
    RaceNamePluralEdit: TEdit; { +0228 }
    RaceNameEdit: TEdit; { +022C }
    AddBtn: TButton; { +0230 }
    DeleteBtn: TButton; { +0234 }
    UnitIndexGrid: TUnitIndexGrid; { +0238 }
    CitySheet: TTabSheet; { +023C }
    GroupBox1: TGroupBox; { +0240 }
    DefaultUnitProdGrid: TUnitIndexGrid; { +0244 }
    Label5: TLabel; { +0248 }
    Label7: TLabel; { +024C }
    Label8: TLabel; { +0250 }
    Label9: TLabel; { +0254 }
    AddProdBtn: TButton; { +0258 }
    DeleteProdBtn: TButton; { +025C }
    RaceColorBtn: TButton; { +0260 }
    ColorBox: TShape; { +0264 }
    ColorDialog: TColorDialog; { +0268 }
    DescriptionSheet: TTabSheet; { +026C }
    Panel8: TPanel; { +0270 }
    DescriptionMemo: TMemo; { +0274 }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
    procedure FormDestroy;  { draft }
    procedure AddBtnClick;  { draft }
    procedure DeleteBtnClick;  { draft }
    procedure FormShow;  { draft }
    procedure AddProdBtnClick;  { draft }
    procedure DeleteProdBtnClick(A1: Integer; A2: Integer);  { draft }
    procedure RaceColorBtnClick;  { draft }
  end;

  { TRaceResourceEditor (instance size 8, VMT 0041167C) }
  TRaceResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TRaceResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TRaceResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TRaceResourceEditForm.FormCreate;
begin end;

procedure TRaceResourceEditForm.OKBtnClick;
begin end;

procedure TRaceResourceEditForm.FormDestroy;
begin end;

procedure TRaceResourceEditForm.AddBtnClick;
begin end;

procedure TRaceResourceEditForm.DeleteBtnClick;
begin end;

procedure TRaceResourceEditForm.FormShow;
begin end;

procedure TRaceResourceEditForm.AddProdBtnClick;
begin end;

procedure TRaceResourceEditForm.DeleteProdBtnClick(A1: Integer; A2: Integer);
begin end;

procedure TRaceResourceEditForm.RaceColorBtnClick;
begin end;


end.
