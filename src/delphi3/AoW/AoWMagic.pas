unit AoWMagic;

{ Draft declarations of AoWMagic, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TMagicWin = class;


  { TMagicWin (instance size 332, VMT 0042C190) }
  TMagicWin = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    OWTitle: TAOWLabel; { +0048 }
    OWTitleIc: TAOWImage; { +004C }
    HeaderTab: TAOWTabPanel; { +0050 }
    OWRPillar: TAoWFrame; { +0054 }
    OWLPillar: TAoWFrame; { +0058 }
    T1Pnl: TAOWPanel; { +005C }
    ResearchPoints: TAOWLabel; { +0060 }
    ResLbl: TAOWLabel; { +0064 }
    T2Pnl: TAOWPanel; { +0068 }
    T2LBPnl: TAOWPanel; { +006C }
    EnchantmentList: TAOWListBox; { +0070 }
    EnchantmentSortBtn: TAOWButton; { +0074 }
    UpkeepList: TAOWListBox; { +0078 }
    UpkeepSortBtn: TAOWButton; { +007C }
    BindingList: TAOWListBox; { +0080 }
    BindingSortBtn: TAOWButton; { +0084 }
    ResPnl: TAOWPanel; { +0088 }
    NetMana: TAOWLabel; { +008C }
    NetMamaLbl: TAOWLabel; { +0090 }
    NetManaPnl: TAOWPanel; { +0094 }
    T3Pnl: TAOWPanel; { +0098 }
    T3LBPnl: TAOWPanel; { +009C }
    GlobalEnchantmentList: TAOWListBox; { +00A0 }
    GlobalEnchantmentSortBtn: TAOWButton; { +00A4 }
    GlobalUpkeepList: TAOWListBox; { +00A8 }
    GlobalUpkeepSortBtn: TAOWButton; { +00AC }
    GlobalNameList: TAOWListBox; { +00B0 }
    GlobalNameSortBtn: TAOWButton; { +00B4 }
    RightPnl: TAOWPanel; { +00B8 }
    SpellName: TAOWLabel; { +00BC }
    GlobalDispelBtn: TAOWButton; { +00C0 }
    DispelBtn: TAOWButton; { +00C4 }
    ResearchBtn: TAOWButton; { +00C8 }
    ResearchTurnsLeft: TAOWLabel; { +00CC }
    SpellClass: TAOWLabel; { +00D0 }
    SpellPnl: TAOWPanel; { +00D4 }
    SpellCost: TAOWLabel; { +00D8 }
    SpellIcn: TAOWImage; { +00DC }
    Minimize: TAOWButton; { +00E0 }
    ChangePowerBut: TAOWButton; { +00E4 }
    Power: TAOWLabel; { +00E8 }
    PowerLbl: TAOWLabel; { +00EC }
    PowePnl: TAOWPanel; { +00F0 }
    LeftPnl: TAOWPanel; { +00F4 }
    NonePnl: TAOWPanel; { +00F8 }
    NoneMsg: TAOWLabel; { +00FC }
    T4Pnl: TAOWPanel; { +0100 }
    T4LBPnl: TAOWPanel; { +0104 }
    PowerValueList: TAOWListBox; { +0108 }
    PowerValueSortBtn: TAOWButton; { +010C }
    PowerSourceList: TAOWListBox; { +0110 }
    PowerSourceSortBtn: TAOWButton; { +0114 }
    T2BottonPnl: TAOWPanel; { +0118 }
    EnchantmentSB: TAOWVScrollBar; { +011C }
    GlobalEnchantmentSB: TAOWVScrollBar; { +0120 }
    PowerSB: TAOWVScrollBar; { +0124 }
    T3BottomPnl: TAOWPanel; { +0128 }
    LeftFr: TAOWPanel; { +012C }
    T2ButtonPnl: TAOWPanel; { +0130 }
    T3ButtonPnl: TAOWPanel; { +0134 }
    Translator: TIvTranslator; { +0138 }
    Help: TAOWButton; { +013C }
    public
    F_MagicWin_140: Integer;
    F_MagicWin_144: Integer;
    F_MagicWin_148: Integer;
    procedure EnchantmentListDoubleClick;  { draft }
    procedure EnchantmentListMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DispelBtnClick;  { draft }
    procedure EnchantmentListChange;  { draft }
    procedure BindingListChange;  { draft }
    procedure UpkeepListChange;  { draft }
    procedure GlobalDispelBtnClick;  { draft }
    procedure GlobalEnchantmentListChange;  { draft }
    procedure GlobalNameListChange;  { draft }
    procedure GlobalUpkeepListChange;  { draft }
    procedure PowerSourceListChange;  { draft }
    procedure PowerValueListChange;  { draft }
    procedure ResearchBtnClick;  { draft }
    procedure ChangePowerButClick;  { draft }
    procedure SpellIcnDraw(A1: Integer; A2: Integer);  { draft }
    procedure PowerSourceListDoubleClick;  { draft }
    procedure PowerValueListMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure PowerSBChange;  { draft }
    procedure GlobalEnchantmentSBChange;  { draft }
    procedure EnchantmentSBChange;  { draft }
    procedure EnchantmentSortBtnClick;  { draft }
    procedure BindingSortBtnClick;  { draft }
    procedure UpkeepSortBtnClick;  { draft }
    procedure GlobalEnchantmentSortBtnClick;  { draft }
    procedure GlobalNameSortBtnClick;  { draft }
    procedure GlobalUpkeepSortBtnClick;  { draft }
    procedure PowerSourceSortBtnClick;  { draft }
    procedure PowerValueSortBtnClick;  { draft }
    procedure HeaderTabChange;  { draft }
    procedure DlgResize;  { draft }
    procedure DlgShow;  { draft }
    procedure DlgHide;  { draft }
    procedure HelpClick;  { draft }
    procedure GlobalEnchantmentMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;


implementation

procedure TMagicWin.EnchantmentListDoubleClick;
begin end;

procedure TMagicWin.EnchantmentListMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMagicWin.DispelBtnClick;
begin end;

procedure TMagicWin.EnchantmentListChange;
begin end;

procedure TMagicWin.BindingListChange;
begin end;

procedure TMagicWin.UpkeepListChange;
begin end;

procedure TMagicWin.GlobalDispelBtnClick;
begin end;

procedure TMagicWin.GlobalEnchantmentListChange;
begin end;

procedure TMagicWin.GlobalNameListChange;
begin end;

procedure TMagicWin.GlobalUpkeepListChange;
begin end;

procedure TMagicWin.PowerSourceListChange;
begin end;

procedure TMagicWin.PowerValueListChange;
begin end;

procedure TMagicWin.ResearchBtnClick;
begin end;

procedure TMagicWin.ChangePowerButClick;
begin end;

procedure TMagicWin.SpellIcnDraw(A1: Integer; A2: Integer);
begin end;

procedure TMagicWin.PowerSourceListDoubleClick;
begin end;

procedure TMagicWin.PowerValueListMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMagicWin.PowerSBChange;
begin end;

procedure TMagicWin.GlobalEnchantmentSBChange;
begin end;

procedure TMagicWin.EnchantmentSBChange;
begin end;

procedure TMagicWin.EnchantmentSortBtnClick;
begin end;

procedure TMagicWin.BindingSortBtnClick;
begin end;

procedure TMagicWin.UpkeepSortBtnClick;
begin end;

procedure TMagicWin.GlobalEnchantmentSortBtnClick;
begin end;

procedure TMagicWin.GlobalNameSortBtnClick;
begin end;

procedure TMagicWin.GlobalUpkeepSortBtnClick;
begin end;

procedure TMagicWin.PowerSourceSortBtnClick;
begin end;

procedure TMagicWin.PowerValueSortBtnClick;
begin end;

procedure TMagicWin.HeaderTabChange;
begin end;

procedure TMagicWin.DlgResize;
begin end;

procedure TMagicWin.DlgShow;
begin end;

procedure TMagicWin.DlgHide;
begin end;

procedure TMagicWin.HelpClick;
begin end;

procedure TMagicWin.GlobalEnchantmentMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;


end.
