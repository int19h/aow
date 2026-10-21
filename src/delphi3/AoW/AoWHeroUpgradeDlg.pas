unit AoWHeroUpgradeDlg;

{ Draft declarations of AoWHeroUpgradeDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  THeroUpgradeDlg = class;


  { THeroUpgradeDlg (instance size 480, VMT 004458C8) }
  THeroUpgradeDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    CancelBtn: TAOWButton; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    Done: TAOWButton; { +0050 }
    Title: TAOWLabel; { +0054 }
    Close: TAOWButton; { +0058 }
    TitleIcon: TAOWImage; { +005C }
    CeltM: TAOWImage; { +0060 }
    CeltL: TAOWImage; { +0064 }
    CeltR: TAOWImage; { +0068 }
    TCeltL: TAoWFrame; { +006C }
    TCelt: TAOWImage; { +0070 }
    UpgradePnl: TAOWPanel; { +0074 }
    HeaderLbl: TAOWLabel; { +0078 }
    SkillPointsLbl: TAOWLabel; { +007C }
    AvailableAbilities: TAOWListBox; { +0080 }
    AvailableAbilitiesSB: TAOWVScrollBar; { +0084 }
    SelectedAbilities: TAOWListBox; { +0088 }
    SelectedAbilitiesSB: TAOWVScrollBar; { +008C }
    SelectedAbilitiesSort: TAOWButton; { +0090 }
    AvailableAbilityCostSort: TAOWButton; { +0094 }
    AvailableAbilitiesCost: TAOWListBox; { +0098 }
    AvailableAbilitiesSort: TAOWButton; { +009C }
    AddAbilityBtn: TAOWButton; { +00A0 }
    RemoveBtn: TAOWButton; { +00A4 }
    FaceFrame: TAOWImage; { +00A8 }
    UnitName: TAOWEdit; { +00AC }
    Alignment: TAOWEdit; { +00B0 }
    TopPnl: TAOWPanel; { +00B4 }
    StatisicsPnl: TAOWPanel; { +00B8 }
    AttValue: TAOWLabel; { +00BC }
    AttLbl: TAOWLabel; { +00C0 }
    AttPnl: TAOWPanel; { +00C4 }
    DamValue: TAOWLabel; { +00C8 }
    DamLbl: TAOWLabel; { +00CC }
    DamPnl: TAOWPanel; { +00D0 }
    DefValue: TAOWLabel; { +00D4 }
    DefLbl: TAOWLabel; { +00D8 }
    DefPnl: TAOWPanel; { +00DC }
    ResValue: TAOWLabel; { +00E0 }
    ResLbl: TAOWLabel; { +00E4 }
    ResPnl: TAOWPanel; { +00E8 }
    HitValue: TAOWLabel; { +00EC }
    HitLbl: TAOWLabel; { +00F0 }
    HitPnl: TAOWPanel; { +00F4 }
    MovValue: TAOWLabel; { +00F8 }
    MovLbl: TAOWLabel; { +00FC }
    MovPnl: TAOWPanel; { +0100 }
    AttI: TAOWLabel; { +0104 }
    DamI: TAOWLabel; { +0108 }
    DefI: TAOWLabel; { +010C }
    ResI: TAOWLabel; { +0110 }
    HitI: TAOWLabel; { +0114 }
    MovI: TAOWLabel; { +0118 }
    AttA: TAOWLabel; { +011C }
    DamA: TAOWLabel; { +0120 }
    DefA: TAOWLabel; { +0124 }
    ResA: TAOWLabel; { +0128 }
    HitA: TAOWLabel; { +012C }
    MovA: TAOWLabel; { +0130 }
    AttP: TAOWLabel; { +0134 }
    DamP: TAOWLabel; { +0138 }
    DefP: TAOWLabel; { +013C }
    ResP: TAOWLabel; { +0140 }
    HitP: TAOWLabel; { +0144 }
    MovP: TAOWLabel; { +0148 }
    AttB: TAOWLabel; { +014C }
    DamB: TAOWLabel; { +0150 }
    DefB: TAOWLabel; { +0154 }
    ResB: TAOWLabel; { +0158 }
    HitB: TAOWLabel; { +015C }
    MovB: TAOWLabel; { +0160 }
    AttUp: TAOWButton; { +0164 }
    AttDn: TAOWButton; { +0168 }
    DamUp: TAOWButton; { +016C }
    DamDn: TAOWButton; { +0170 }
    DefUp: TAOWButton; { +0174 }
    DefDn: TAOWButton; { +0178 }
    ResUp: TAOWButton; { +017C }
    ResDn: TAOWButton; { +0180 }
    HitUp: TAOWButton; { +0184 }
    HitDn: TAOWButton; { +0188 }
    MovUp: TAOWButton; { +018C }
    MovDn: TAOWButton; { +0190 }
    AttIc: TAOWImage; { +0194 }
    DamIcn: TAOWImage; { +0198 }
    DefIc: TAOWImage; { +019C }
    ResIc: TAOWImage; { +01A0 }
    HitIc: TAOWImage; { +01A4 }
    MovIc: TAOWImage; { +01A8 }
    SelectedAbilitiesCostSort: TAOWButton; { +01AC }
    SelectedAbilitiesCost: TAOWListBox; { +01B0 }
    InfoPnl: TAOWPanel; { +01B4 }
    LevelLbl: TAOWLabel; { +01B8 }
    SkillPoints: TAOWLabel; { +01BC }
    Translator: TIvTranslator; { +01C0 }
    public
    F_HeroUpgradeDlg_1C4: array[0..11] of Byte;
    F_HeroUpgradeDlg_1D0: Integer;
    F_HeroUpgradeDlg_1D4: Integer;
    F_HeroUpgradeDlg_1D8: Integer;
    F_HeroUpgradeDlg_1DC: Integer;
    procedure CloseClick;  { draft }
    procedure FaceFramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure AttUpClick;  { draft }
    procedure AttDnClick;  { draft }
    procedure DefUpClick;  { draft }
    procedure DefDnClick;  { draft }
    procedure DamUpClick;  { draft }
    procedure DamDnClick;  { draft }
    procedure ResUpClick;  { draft }
    procedure ResDnClick;  { draft }
    procedure HitUpClick;  { draft }
    procedure HitDnClick;  { draft }
    procedure MovUpClick;  { draft }
    procedure MovDnClick;  { draft }
    procedure SelectedAbilitiesChange;  { draft }
    procedure SelectedAbilitiesCostChange;  { draft }
    procedure SelectedAbilitiesSBChange;  { draft }
    procedure AvailableAbilitiesChange;  { draft }
    procedure AvailableAbilitiesCostChange;  { draft }
    procedure AvailableAbilitiesSBChange;  { draft }
    procedure AddAbilityBtnClick;  { draft }
    procedure RemoveBtnClick;  { draft }
    procedure SelectedAbilitiesSortClick;  { draft }
    procedure SelectedAbilitiesCostSortClick;  { draft }
    procedure AvailableAbilitiesSortClick;  { draft }
    procedure AvailableAbilityCostSortClick;  { draft }
    procedure DoneClick;  { draft }
    procedure DlgHide;  { draft }
    procedure AvailableAbilitiesMouseDown(A1: Integer; A2: Byte);  { draft }
    procedure SelectedAbilitiesMouseDown(A1: Integer; A2: Byte);  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure THeroUpgradeDlg.CloseClick;
begin end;

procedure THeroUpgradeDlg.FaceFramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure THeroUpgradeDlg.AttUpClick;
begin end;

procedure THeroUpgradeDlg.AttDnClick;
begin end;

procedure THeroUpgradeDlg.DefUpClick;
begin end;

procedure THeroUpgradeDlg.DefDnClick;
begin end;

procedure THeroUpgradeDlg.DamUpClick;
begin end;

procedure THeroUpgradeDlg.DamDnClick;
begin end;

procedure THeroUpgradeDlg.ResUpClick;
begin end;

procedure THeroUpgradeDlg.ResDnClick;
begin end;

procedure THeroUpgradeDlg.HitUpClick;
begin end;

procedure THeroUpgradeDlg.HitDnClick;
begin end;

procedure THeroUpgradeDlg.MovUpClick;
begin end;

procedure THeroUpgradeDlg.MovDnClick;
begin end;

procedure THeroUpgradeDlg.SelectedAbilitiesChange;
begin end;

procedure THeroUpgradeDlg.SelectedAbilitiesCostChange;
begin end;

procedure THeroUpgradeDlg.SelectedAbilitiesSBChange;
begin end;

procedure THeroUpgradeDlg.AvailableAbilitiesChange;
begin end;

procedure THeroUpgradeDlg.AvailableAbilitiesCostChange;
begin end;

procedure THeroUpgradeDlg.AvailableAbilitiesSBChange;
begin end;

procedure THeroUpgradeDlg.AddAbilityBtnClick;
begin end;

procedure THeroUpgradeDlg.RemoveBtnClick;
begin end;

procedure THeroUpgradeDlg.SelectedAbilitiesSortClick;
begin end;

procedure THeroUpgradeDlg.SelectedAbilitiesCostSortClick;
begin end;

procedure THeroUpgradeDlg.AvailableAbilitiesSortClick;
begin end;

procedure THeroUpgradeDlg.AvailableAbilityCostSortClick;
begin end;

procedure THeroUpgradeDlg.DoneClick;
begin end;

procedure THeroUpgradeDlg.DlgHide;
begin end;

procedure THeroUpgradeDlg.AvailableAbilitiesMouseDown(A1: Integer; A2: Byte);
begin end;

procedure THeroUpgradeDlg.SelectedAbilitiesMouseDown(A1: Integer; A2: Byte);
begin end;

procedure THeroUpgradeDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
