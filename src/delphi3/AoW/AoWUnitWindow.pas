unit AoWUnitWindow;

{ Draft declarations of AoWUnitWindow, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TUnitWindow = class;


  { TUnitWindow (instance size 584, VMT 0040710C) }
  TUnitWindow = class(TDataModule)
  public
    published
    UnitWin: TAOWWindow; { +0044 }
    UnitFrameLeft: TAOWImage; { +0048 }
    UnitTab: TAOWTabPanel; { +004C }
    Close: TAOWButton; { +0050 }
    Title: TAOWLabel; { +0054 }
    Help: TAOWButton; { +0058 }
    TitleIcon: TAOWImage; { +005C }
    BCloseBtn: TAOWButton; { +0060 }
    CeltLineR: TAOWImage; { +0064 }
    T2Memo: TAOWMemo; { +0068 }
    ManaIcon: TAOWImage; { +006C }
    Mana: TAOWLabel; { +0070 }
    T1AbilityLB: TAOWListBox; { +0074 }
    T1UseBut: TAOWButton; { +0078 }
    T1SortName: TAOWButton; { +007C }
    T1SortType: TAOWButton; { +0080 }
    T1SortSource: TAOWButton; { +0084 }
    T1UseMsg: TAOWLabel; { +0088 }
    T1Panel: TAOWPanel; { +008C }
    T2Panel: TAOWPanel; { +0090 }
    T1TypeLB: TAOWListBox; { +0094 }
    T1SrcLB: TAOWListBox; { +0098 }
    T1ListPnl: TAOWPanel; { +009C }
    T1SBar: TAOWVScrollBar; { +00A0 }
    T2SBar: TAOWVScrollBar; { +00A4 }
    T2Text: TAOWPanel; { +00A8 }
    T2Leader: TAOWPanel; { +00AC }
    Sel4: TAOWButton; { +00B0 }
    SelPnl: TAOWPanel; { +00B4 }
    Sel3: TAOWButton; { +00B8 }
    Sel2: TAOWButton; { +00BC }
    Sel1: TAOWButton; { +00C0 }
    Sel5: TAOWButton; { +00C4 }
    Sel6: TAOWButton; { +00C8 }
    Sel7: TAOWButton; { +00CC }
    AAlignment: TAOWImage; { +00D0 }
    AAlignmentLbl: TAOWLabel; { +00D4 }
    T2Alignnl: TAOWPanel; { +00D8 }
    AlFr: TAoWFrame; { +00DC }
    TypeIcn: TAOWImage; { +00E0 }
    TypeV: TAOWLabel; { +00E4 }
    T2TypePnl: TAOWPanel; { +00E8 }
    TypeFr: TAoWFrame; { +00EC }
    LdrFr: TAoWFrame; { +00F0 }
    SphereLbl: TAOWLabel; { +00F4 }
    T3Panel: TAOWPanel; { +00F8 }
    BP1: TAOWCheckBox; { +00FC }
    BPLbl1: TAOWLabel; { +0100 }
    BP2: TAOWCheckBox; { +0104 }
    BP3: TAOWCheckBox; { +0108 }
    BP4: TAOWCheckBox; { +010C }
    BP5: TAOWCheckBox; { +0110 }
    BP6: TAOWCheckBox; { +0114 }
    BP7: TAOWCheckBox; { +0118 }
    BP8: TAOWCheckBox; { +011C }
    BPLbl2: TAOWLabel; { +0120 }
    BodyLbl: TAOWLabel; { +0124 }
    Head: TAOWCheckBox; { +0128 }
    Torso: TAOWCheckBox; { +012C }
    Attack: TAOWCheckBox; { +0130 }
    Defend: TAOWCheckBox; { +0134 }
    RingL: TAOWCheckBox; { +0138 }
    RingR: TAOWCheckBox; { +013C }
    Gnd3: TAOWCheckBox; { +0140 }
    Gnd2: TAOWCheckBox; { +0144 }
    Gnd1: TAOWCheckBox; { +0148 }
    Gnd4: TAOWCheckBox; { +014C }
    Gnd5: TAOWCheckBox; { +0150 }
    GndLbl: TAOWLabel; { +0154 }
    SlotBack: TAOWImage; { +0158 }
    DisbandBtn: TAOWButton; { +015C }
    ItemUsePnl: TAOWPanel; { +0160 }
    ItemUseBtn: TAOWButton; { +0164 }
    ItemPic: TAOWImage; { +0168 }
    UnitMainPnl: TAOWPanel; { +016C }
    UnitName: TAOWLabel; { +0170 }
    UnitFrRight: TAOWImage; { +0174 }
    UAttackIcon: TAOWImage; { +0178 }
    UDefenseIcon: TAOWImage; { +017C }
    UMovesIcon: TAOWImage; { +0180 }
    UDamageIcon: TAOWImage; { +0184 }
    UResistanceIcon: TAOWImage; { +0188 }
    UHitsIcon: TAOWImage; { +018C }
    UAttack: TAOWLabel; { +0190 }
    UDefense: TAOWLabel; { +0194 }
    UMoves: TAOWLabel; { +0198 }
    UDamage: TAOWLabel; { +019C }
    UResistance: TAOWLabel; { +01A0 }
    UHits: TAOWLabel; { +01A4 }
    UStatPnl: TAOWPanel; { +01A8 }
    UStatP1: TAOWPanel; { +01AC }
    UStatP2: TAOWPanel; { +01B0 }
    UnitFr: TAOWPanel; { +01B4 }
    Level: TAOWLabel; { +01B8 }
    UnitLine1: TAOWImage; { +01BC }
    UnitLine2: TAOWImage; { +01C0 }
    FrLSh: TAOWImage; { +01C4 }
    FrRSh: TAOWImage; { +01C8 }
    RightFramePnl: TAOWPanel; { +01CC }
    MoraleLbl: TAOWLabel; { +01D0 }
    UpkeepIcon: TAOWImage; { +01D4 }
    UpKeep: TAOWLabel; { +01D8 }
    BCeltL: TAoWFrame; { +01DC }
    CeltLineL: TAOWImage; { +01E0 }
    GroundL: TAOWButton; { +01E4 }
    GroundR: TAOWButton; { +01E8 }
    RelationIcn: TAOWImage; { +01EC }
    RelationV: TAOWLabel; { +01F0 }
    T2RelPnl: TAOWPanel; { +01F4 }
    RelFr: TAoWFrame; { +01F8 }
    RelRing: TAOWImage; { +01FC }
    RelationLbl: TAOWLabel; { +0200 }
    AlignLbl: TAOWLabel; { +0204 }
    TypeLbl: TAOWLabel; { +0208 }
    XP: TAOWLabel; { +020C }
    PNext: TAOWButton; { +0210 }
    PPrev: TAOWButton; { +0214 }
    Translator: TIvTranslator; { +0218 }
    public
    F_UnitWindow_21C: Integer;
    F_UnitWindow_220: Byte;
    F_UnitWindow_221: array[0..2] of Byte;
    F_UnitWindow_224: Integer;
    F_UnitWindow_228: Byte;
    F_UnitWindow_229: array[0..2] of Byte;
    F_UnitWindow_22C: Integer;
    F_UnitWindow_230: Integer;
    F_UnitWindow_234: Integer;
    F_UnitWindow_238: array[0..3] of Byte;
    F_UnitWindow_23C: Byte;
    F_UnitWindow_23D: Byte;
    F_UnitWindow_23E: array[0..9] of Byte;
    procedure ShowUnit; { draft; 00407DB8 }
    procedure PreDrawAbilityItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure HelpClick;  { draft }
    procedure T1AbilityLBChange(A1: Integer);  { draft }
    procedure T1SbarChange;  { draft }
    procedure ItemRHMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure UnitWinResize;  { draft }
    procedure UnitWindowCreate;  { draft }
    procedure UnitWinUpdate(A1: Integer; A2: Byte);  { draft }
    procedure T1SortNameClick(A1: Integer; A2: Integer);  { draft }
    procedure T1SortTypeClick(A1: Integer; A2: Integer);  { draft }
    procedure T1SortSourceClick(A1: Integer; A2: Integer);  { draft }
    procedure UseAbility;  { draft }
    procedure UseItemClick;  { draft }
    procedure UnitTabChange;  { draft }
    procedure UnitWinMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure UnitWinEnter;  { draft }
    procedure UnitWinExit;  { draft }
    procedure UnitWinShow;  { draft }
    procedure GroundRClick;  { draft }
    procedure GroundLClick;  { draft }
    procedure CloseClick;  { draft }
    procedure Gnd1Draw(A1: Integer; A2: Integer);  { draft }
    procedure FrLShPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure FrRShPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure Gnd1Change(A1: Integer);  { draft }
    procedure Gnd3MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure HeadDraw(A1: Integer; A2: Integer);  { draft }
    procedure TorsoDraw(A1: Integer; A2: Integer);  { draft }
    procedure AttackDraw(A1: Integer; A2: Integer);  { draft }
    procedure DefendDraw(A1: Integer; A2: Integer);  { draft }
    procedure RingLDraw(A1: Integer; A2: Integer);  { draft }
    procedure DisbandBtnClick;  { draft }
    procedure T1AbilityLBMouseDown(A1: Integer; A2: Byte);  { draft }
    procedure UnitWinKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PPrevClick;  { draft }
    procedure PNextClick;  { draft }
  end;


var
  UnitWindow: TUnitWindow;

implementation

procedure TUnitWindow.ShowUnit;
begin end;


procedure TUnitWindow.PreDrawAbilityItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitWindow.HelpClick;
begin end;

procedure TUnitWindow.T1AbilityLBChange(A1: Integer);
begin end;

procedure TUnitWindow.T1SbarChange;
begin end;

procedure TUnitWindow.ItemRHMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TUnitWindow.UnitWinResize;
begin end;

procedure TUnitWindow.UnitWindowCreate;
begin end;

procedure TUnitWindow.UnitWinUpdate(A1: Integer; A2: Byte);
begin end;

procedure TUnitWindow.T1SortNameClick(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.T1SortTypeClick(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.T1SortSourceClick(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.UseAbility;
begin end;

procedure TUnitWindow.UseItemClick;
begin end;

procedure TUnitWindow.UnitTabChange;
begin end;

procedure TUnitWindow.UnitWinMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TUnitWindow.UnitWinEnter;
begin end;

procedure TUnitWindow.UnitWinExit;
begin end;

procedure TUnitWindow.UnitWinShow;
begin end;

procedure TUnitWindow.GroundRClick;
begin end;

procedure TUnitWindow.GroundLClick;
begin end;

procedure TUnitWindow.CloseClick;
begin end;

procedure TUnitWindow.Gnd1Draw(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.FrLShPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.FrRShPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.Gnd1Change(A1: Integer);
begin end;

procedure TUnitWindow.Gnd3MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TUnitWindow.HeadDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.TorsoDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.AttackDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.DefendDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.RingLDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitWindow.DisbandBtnClick;
begin end;

procedure TUnitWindow.T1AbilityLBMouseDown(A1: Integer; A2: Byte);
begin end;

procedure TUnitWindow.UnitWinKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitWindow.PPrevClick;
begin end;

procedure TUnitWindow.PNextClick;
begin end;


end.
