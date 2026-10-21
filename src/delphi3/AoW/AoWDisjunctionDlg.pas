unit AoWDisjunctionDlg;

{ Draft declarations of AoWDisjunctionDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox;

type
  TDisjunctionDlg = class;


  { TDisjunctionDlg (instance size 176, VMT 0043285C) }
  TDisjunctionDlg = class(TDataModule)
  public
    published
    TitleIcon: TAOWImage; { +0044 }
    Title: TAOWLabel; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    CancelBtn: TAOWButton; { +0050 }
    CastBtn: TAOWButton; { +0054 }
    Dlg: TAOWWindow; { +0058 }
    DisjunctionChance: TAOWLabel; { +005C }
    DisjunctionChanceLbl: TAOWLabel; { +0060 }
    DisjunctionChancePnl: TAOWPanel; { +0064 }
    DisjunctionMana: TAOWLabel; { +0068 }
    DisjunctionManaLbl: TAOWLabel; { +006C }
    DisjunctionManaPnl: TAOWPanel; { +0070 }
    T4LBPnl: TAOWPanel; { +0074 }
    OwnerList: TAOWListBox; { +0078 }
    EnchantmentList: TAOWListBox; { +007C }
    Sort: TAOWButton; { +0080 }
    SortEnchantment: TAOWButton; { +0084 }
    EnchantmentsScrollBar: TAOWVScrollBar; { +0088 }
    Spell: TAOWLabel; { +008C }
    ChanceSlider: TAOWHScrollBar; { +0090 }
    Close: TAOWButton; { +0094 }
    Translator: TIvTranslator; { +0098 }
    MapViewPnl: TAOWPanel; { +009C }
    MapView: TaowUserDrawBox; { +00A0 }
    public
    F_DisjunctionDlg_A4: Integer;
    F_DisjunctionDlg_A8: Integer;
    F_DisjunctionDlg_AC: Byte;
    F_DisjunctionDlg_AD: Byte;
    F_DisjunctionDlg_AE: Byte;
    F_DisjunctionDlg_AF: array[0..0] of Byte;
    procedure CancelBtnClick;  { draft }
    procedure CastBtnClick;  { draft }
    procedure EnchantmentListChange;  { draft }
    procedure OwnerListChange;  { draft }
    procedure ChanceSliderChange;  { draft }
    procedure EnchantmentsScrollBarChange;  { draft }
    procedure SortEnchantmentClick;  { draft }
    procedure SortClick;  { draft }
    procedure DlgHide;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure MapViewDraw(A1: Integer; A2: Integer);  { draft }
    procedure MapViewUpdate;  { draft }
  end;


implementation

procedure TDisjunctionDlg.CancelBtnClick;
begin end;

procedure TDisjunctionDlg.CastBtnClick;
begin end;

procedure TDisjunctionDlg.EnchantmentListChange;
begin end;

procedure TDisjunctionDlg.OwnerListChange;
begin end;

procedure TDisjunctionDlg.ChanceSliderChange;
begin end;

procedure TDisjunctionDlg.EnchantmentsScrollBarChange;
begin end;

procedure TDisjunctionDlg.SortEnchantmentClick;
begin end;

procedure TDisjunctionDlg.SortClick;
begin end;

procedure TDisjunctionDlg.DlgHide;
begin end;

procedure TDisjunctionDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TDisjunctionDlg.MapViewDraw(A1: Integer; A2: Integer);
begin end;

procedure TDisjunctionDlg.MapViewUpdate;
begin end;


end.
