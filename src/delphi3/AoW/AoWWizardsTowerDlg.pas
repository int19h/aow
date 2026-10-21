unit AoWWizardsTowerDlg;

{ Draft declarations of AoWWizardsTowerDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  TWizardsTowerDlg = class;


  { TWizardsTowerDlg (instance size 148, VMT 0044B6EC) }
  TWizardsTowerDlg = class(TDataModule)
  public
    published
    TitleIcon: TAOWImage; { +0044 }
    Close: TAOWButton; { +0048 }
    Title: TAOWLabel; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    BuyBtn: TAOWButton; { +0058 }
    Dlg: TAOWWindow; { +005C }
    ResearchPnl: TAOWPanel; { +0060 }
    SpellName: TAOWLabel; { +0064 }
    SpellIcn: TAOWImage; { +0068 }
    SpellClass: TAOWLabel; { +006C }
    SpellCost: TAOWLabel; { +0070 }
    ResearchMemo: TAOWMemo; { +0074 }
    PriceLbl: TAOWLabel; { +0078 }
    OfferText: TAOWLabel; { +007C }
    PicPnl: TAOWPanel; { +0080 }
    Translator: TIvTranslator; { +0084 }
    public
    F_WizardsTowerDlg_88: array[0..7] of Byte;
    F_WizardsTowerDlg_90: Integer;
    procedure CancelBtnClick;  { draft }
    procedure BuyBtnClick;  { draft }
    procedure DlgHide;  { draft }
    procedure SpellIcnDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TWizardsTowerDlg.CancelBtnClick;
begin end;

procedure TWizardsTowerDlg.BuyBtnClick;
begin end;

procedure TWizardsTowerDlg.DlgHide;
begin end;

procedure TWizardsTowerDlg.SpellIcnDraw(A1: Integer; A2: Integer);
begin end;

procedure TWizardsTowerDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
