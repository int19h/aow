unit HeroLibF;

{ Draft declarations of HeroLibF, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, HeroGrid;

type
  THeroLibraryEditForm = class;


  { THeroLibraryEditForm (instance size 564, VMT 004245B4) }
  THeroLibraryEditForm = class(TForm)
  public
    published
    Panel1: TPanel; { +01DC }
    CloseBtn: TButton; { +01E0 }
    AddBtn: TButton; { +01E4 }
    CopyBtn: TButton; { +01E8 }
    LibraryHeroGrid: THeroGrid; { +01EC }
    ItemToolbar: TToolBar; { +01F0 }
    ToolButton3: TToolButton; { +01F4 }
    NewLibrary: TToolButton; { +01F8 }
    DeleteLibrary: TToolButton; { +01FC }
    ToolButton6: TToolButton; { +0200 }
    EditHeroBtn: TToolButton; { +0204 }
    NewHero: TToolButton; { +0208 }
    DeleteHero: TToolButton; { +020C }
    ToolButton8: TToolButton; { +0210 }
    SortOnNamesBtn: TToolButton; { +0214 }
    SortOnLevelBtn: TToolButton; { +0218 }
    HeroImageList: TImageList; { +021C }
    Panel2: TPanel; { +0220 }
    LibraryLbl: TLabel; { +0224 }
    LibraryCB: TComboBox; { +0228 }
    Translator: TIvTranslator; { +022C }
    public
    F_HeroLibraryEditForm_230: Integer;
    procedure FormShow;  { draft }
    procedure AddBtnClick;  { draft }
    procedure CopyBtnClick;  { draft }
    procedure LibraryCBChange;  { draft }
    procedure SortOnNameBtnClick;  { draft }
    procedure SortOnLevelClick;  { draft }
    procedure NewHeroClick;  { draft }
    procedure NewLibraryClick;  { draft }
    procedure DeleteLibraryClick;  { draft }
    procedure CloseBtnClick;  { draft }
    procedure EditHeroBtnClick;  { draft }
    procedure DeleteHeroClick;  { draft }
  end;


implementation

procedure THeroLibraryEditForm.FormShow;
begin end;

procedure THeroLibraryEditForm.AddBtnClick;
begin end;

procedure THeroLibraryEditForm.CopyBtnClick;
begin end;

procedure THeroLibraryEditForm.LibraryCBChange;
begin end;

procedure THeroLibraryEditForm.SortOnNameBtnClick;
begin end;

procedure THeroLibraryEditForm.SortOnLevelClick;
begin end;

procedure THeroLibraryEditForm.NewHeroClick;
begin end;

procedure THeroLibraryEditForm.NewLibraryClick;
begin end;

procedure THeroLibraryEditForm.DeleteLibraryClick;
begin end;

procedure THeroLibraryEditForm.CloseBtnClick;
begin end;

procedure THeroLibraryEditForm.EditHeroBtnClick;
begin end;

procedure THeroLibraryEditForm.DeleteHeroClick;
begin end;


end.
