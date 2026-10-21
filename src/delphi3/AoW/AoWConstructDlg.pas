unit AoWConstructDlg;

{ Draft declarations of AoWConstructDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TConstructDlg = class;


  { TConstructDlg (instance size 152, VMT 00431368) }
  TConstructDlg = class(TDataModule)
  public
    published
    TitleIcon: TAOWImage; { +0044 }
    Close: TAOWButton; { +0048 }
    Title: TAOWLabel; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    ConstructBtn: TAOWButton; { +0058 }
    Dlg: TAOWWindow; { +005C }
    ConstructPnl: TAOWPanel; { +0060 }
    ConstructionList: TAOWListBox; { +0064 }
    SortConstructionsBtn: TAOWButton; { +0068 }
    SortConstructionCostBtn: TAOWButton; { +006C }
    ConstructionCostList: TAOWListBox; { +0070 }
    ConstructionTurnsList: TAOWListBox; { +0074 }
    SortConstructionTurnsBtn: TAOWButton; { +0078 }
    AOWLabel1: TAOWLabel; { +007C }
    ConSB: TAOWVScrollBar; { +0080 }
    CeltM: TAOWImage; { +0084 }
    AOWButton2: TAOWButton; { +0088 }
    T4VSB: TAOWVScrollBar; { +008C }
    Translator: TIvTranslator; { +0090 }
    public
    F_ConstructDlg_94: Integer;
    procedure CancelBtnClick;  { draft }
    procedure ConstructionListChange;  { draft }
    procedure ConstructionCostListChange;  { draft }
    procedure ConstructionTurnsListChange;  { draft }
    procedure ConstructBtnClick;  { draft }
    procedure SortConstructionsBtnClick;  { draft }
    procedure SortConstructionCostBtnClick;  { draft }
    procedure SortConstructionTurnsBtnClick;  { draft }
    procedure DlgHide;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TConstructDlg.CancelBtnClick;
begin end;

procedure TConstructDlg.ConstructionListChange;
begin end;

procedure TConstructDlg.ConstructionCostListChange;
begin end;

procedure TConstructDlg.ConstructionTurnsListChange;
begin end;

procedure TConstructDlg.ConstructBtnClick;
begin end;

procedure TConstructDlg.SortConstructionsBtnClick;
begin end;

procedure TConstructDlg.SortConstructionCostBtnClick;
begin end;

procedure TConstructDlg.SortConstructionTurnsBtnClick;
begin end;

procedure TConstructDlg.DlgHide;
begin end;

procedure TConstructDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
