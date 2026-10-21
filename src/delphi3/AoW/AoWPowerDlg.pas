unit AoWPowerDlg;

{ Draft declarations of AoWPowerDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TPowerDlg = class;


  { TPowerDlg (instance size 172, VMT 0042B9B0) }
  TPowerDlg = class(TDataModule)
  public
    published
    TitleIcon: TAOWImage; { +0044 }
    Close: TAOWButton; { +0048 }
    Title: TAOWLabel; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    SetBtn: TAOWButton; { +0058 }
    Dlg: TAOWWindow; { +005C }
    NetMana: TAOWLabel; { +0060 }
    NetMamaLbl: TAOWLabel; { +0064 }
    UpkeePnl: TAOWPanel; { +0068 }
    ResearchLeft: TAOWLabel; { +006C }
    SpellName: TAOWLabel; { +0070 }
    ResearchPnl: TAOWPanel; { +0074 }
    SliderPnl: TAOWPanel; { +0078 }
    PowerLbl: TAOWLabel; { +007C }
    Power: TAOWLabel; { +0080 }
    Mana: TAOWLabel; { +0084 }
    Research: TAOWLabel; { +0088 }
    ManaPnl: TAOWPanel; { +008C }
    ResPnl: TAOWPanel; { +0090 }
    ManaLbl: TAOWLabel; { +0094 }
    ResearchLbl: TAOWLabel; { +0098 }
    PowerSlider: TAOWHScrollBar; { +009C }
    PAMana: TAOWImage; { +00A0 }
    PARes: TAOWImage; { +00A4 }
    Translator: TIvTranslator; { +00A8 }
    public
    procedure CancelBtnClick;  { draft }
    procedure PowerSliderChange;  { draft }
    procedure SetBtnClick;  { draft }
    procedure PAManaDraw(A1: Integer; A2: Integer);  { draft }
    procedure PAResDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TPowerDlg.CancelBtnClick;
begin end;

procedure TPowerDlg.PowerSliderChange;
begin end;

procedure TPowerDlg.SetBtnClick;
begin end;

procedure TPowerDlg.PAManaDraw(A1: Integer; A2: Integer);
begin end;

procedure TPowerDlg.PAResDraw(A1: Integer; A2: Integer);
begin end;

procedure TPowerDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
