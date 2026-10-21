unit AoWProdScreen;

{ Draft declarations of AoWProdScreen, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, PrdPlace, AOWGauge, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox;

type
  TProductionScreen = class;


  { TProductionScreen (instance size 512, VMT 0043E654) }
  TProductionScreen = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    UnitPnl: TAOWPanel; { +0048 }
    UAbilitiesLB: TAOWListBox; { +004C }
    UAttackIcon: TAOWImage; { +0050 }
    UDefenseIcon: TAOWImage; { +0054 }
    UMovesIcon: TAOWImage; { +0058 }
    UDamageIcon: TAOWImage; { +005C }
    UResistanceIcon: TAOWImage; { +0060 }
    UHitsIcon: TAOWImage; { +0064 }
    UAttack: TAOWLabel; { +0068 }
    UDefense: TAOWLabel; { +006C }
    UMoves: TAOWLabel; { +0070 }
    UDamage: TAOWLabel; { +0074 }
    UResistance: TAOWLabel; { +0078 }
    UHits: TAOWLabel; { +007C }
    UStatPnl: TAOWPanel; { +0080 }
    UStatP1: TAOWPanel; { +0084 }
    UStatP2: TAOWPanel; { +0088 }
    UAlignment: TAOWLabel; { +008C }
    ULevel: TAOWLabel; { +0090 }
    UPicturePnl: TAOWPanel; { +0094 }
    UCostPnl: TAOWPanel; { +0098 }
    StructName: TAOWLabel; { +009C }
    CostLbl: TAOWLabel; { +00A0 }
    UCost: TAOWLabel; { +00A4 }
    UnitLbl: TAOWLabel; { +00A8 }
    TurnsLbl: TAOWLabel; { +00AC }
    UTurns: TAOWLabel; { +00B0 }
    B4CB: TAOWCheckBox; { +00B4 }
    B5CB: TAOWCheckBox; { +00B8 }
    B6CB: TAOWCheckBox; { +00BC }
    B1CB: TAOWCheckBox; { +00C0 }
    B2CB: TAOWCheckBox; { +00C4 }
    B3CB: TAOWCheckBox; { +00C8 }
    T2SBar: TAOWVScrollBar; { +00CC }
    AbilPnl: TAOWPanel; { +00D0 }
    UpgradePnl: TAOWPanel; { +00D4 }
    UpgradeLbl: TAOWLabel; { +00D8 }
    UpgradeMemoFr: TAOWPanel; { +00DC }
    UpgradeMemo: TAOWMemo; { +00E0 }
    RightPnl: TAOWPanel; { +00E4 }
    QueuePnl: TAOWPanel; { +00E8 }
    Oval: TAOWImage; { +00EC }
    ShadowL: TAOWImage; { +00F0 }
    ShadowR: TAOWImage; { +00F4 }
    MainBtn3: TAOWButton; { +00F8 }
    MainBtn1: TAOWButton; { +00FC }
    QueueLB: TAOWListBox; { +0100 }
    ActivityPnl: TAOWPanel; { +0104 }
    InfoPnl2: TAOWPanel; { +0108 }
    ActiveAction: TAOWLabel; { +010C }
    ActiveActionTurns: TAOWLabel; { +0110 }
    SepBar: TAOWImage; { +0114 }
    ActivityPnl2: TAOWPanel; { +0118 }
    ActiveActionTurnsBar: TAoWGauge; { +011C }
    MainBtn2: TAOWButton; { +0120 }
    InfoPnl: TAOWPanel; { +0124 }
    IPPnl: TAOWPanel; { +0128 }
    IPPicFr: TAoWFrame; { +012C }
    PlaceInfoMemo: TAOWMemo; { +0130 }
    IIPnl: TAOWPanel; { +0134 }
    IncomePicture: TAoWFrame; { +0138 }
    IncomeMemo: TAOWMemo; { +013C }
    IncomeHdr: TAOWMemo; { +0140 }
    CurrentInfo: TAOWPanel; { +0144 }
    RPillar: TAoWFrame; { +0148 }
    LPillar: TAoWFrame; { +014C }
    QueueInfo: TAOWPanel; { +0150 }
    QueueLbl: TAOWLabel; { +0154 }
    LoopQueueBox: TAOWCheckBox; { +0158 }
    RepeatLbl: TAOWLabel; { +015C }
    ActiveActionPnl: TAOWPanel; { +0160 }
    CurrentActionImage: TAOWImage; { +0164 }
    AoWFrame1: TAoWFrame; { +0168 }
    BlackBg2: TAOWImage; { +016C }
    UPictureFramePnl: TAOWPanel; { +0170 }
    UStatFr1: TAOWPanel; { +0174 }
    UStatFr2: TAOWPanel; { +0178 }
    UInfoFr: TAOWPanel; { +017C }
    CostFr: TAOWPanel; { +0180 }
    TurnsFr: TAOWPanel; { +0184 }
    UpgPicPnl: TAOWPanel; { +0188 }
    UpgradePic: TAOWImage; { +018C }
    UpgPicFr: TAOWPanel; { +0190 }
    UpgCostPnl: TAOWPanel; { +0194 }
    UpgCostLbl: TAOWLabel; { +0198 }
    UpgradeCost: TAOWLabel; { +019C }
    UpgTurnsLbl: TAOWLabel; { +01A0 }
    UpgradeTurns: TAOWLabel; { +01A4 }
    UpgCostFr: TAOWPanel; { +01A8 }
    UpgTurnsFr: TAOWPanel; { +01AC }
    RelIcn: TAOWImage; { +01B0 }
    QueueVSB: TAOWVScrollBar; { +01B4 }
    IPVSB: TAOWVScrollBar; { +01B8 }
    IIVSB: TAOWVScrollBar; { +01BC }
    IncomeValuesMemo: TAOWMemo; { +01C0 }
    UFace: TaowUserDrawBox; { +01C4 }
    InfoSep: TAOWImage; { +01C8 }
    Sphere: TAOWButton; { +01CC }
    MapView: TaowUserDrawBox; { +01D0 }
    PNext: TAOWButton; { +01D4 }
    PPrev: TAOWButton; { +01D8 }
    Translator: TIvTranslator; { +01DC }
    public
    F_ProductionScreen_1E0: Integer;
    F_ProductionScreen_1E4: Integer;
    F_ProductionScreen_1E8: Integer;
    F_ProductionScreen_1EC: Integer;
    F_ProductionScreen_1F0: Integer;
    F_ProductionScreen_1F4: Byte;
    F_ProductionScreen_1F5: array[0..2] of Byte;
    F_ProductionScreen_1F8: Integer;
    F_ProductionScreen_1FC: Integer;
    procedure ShowPlace(Place: TProductionPlace); { draft; 0043F1F4 }
    procedure ProductionScreenCreate;  { draft }
    procedure ProductionScreenDestroy;  { draft }
    procedure ActivityChange(A1: Integer);  { draft }
    procedure ActivityDoubleClick(A1: Integer);  { draft }
    procedure ActivityPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure MainBtn1Click;  { draft }
    procedure MainBtn2Click;  { draft }
    procedure MainBtn3Click;  { draft }
    procedure UFaceDraw(A1: Integer; A2: Integer);  { draft }
    procedure QueueLBChange;  { draft }
    procedure B4CBUpdate(A1: Integer);  { draft }
    procedure LoopQueueBoxChange;  { draft }
    procedure CurrentActionImageDraw(A1: Integer; A2: Integer);  { draft }
    procedure MapViewDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer);  { draft }
    procedure MapViewUpdate;  { draft }
    procedure DlgHide;  { draft }
    procedure UAbilitiesLBMouseDown(A1: Integer; A2: Byte);  { draft }
    procedure PPrevClick(A1: Integer; A2: Integer);  { draft }
    procedure PNextClick(A1: Integer; A2: Integer);  { draft }
  end;


var
  ProductionScreen: TProductionScreen;

implementation

procedure TProductionScreen.ShowPlace(Place: TProductionPlace);
begin end;


procedure TProductionScreen.ProductionScreenCreate;
begin end;

procedure TProductionScreen.ProductionScreenDestroy;
begin end;

procedure TProductionScreen.ActivityChange(A1: Integer);
begin end;

procedure TProductionScreen.ActivityDoubleClick(A1: Integer);
begin end;

procedure TProductionScreen.ActivityPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TProductionScreen.MainBtn1Click;
begin end;

procedure TProductionScreen.MainBtn2Click;
begin end;

procedure TProductionScreen.MainBtn3Click;
begin end;

procedure TProductionScreen.UFaceDraw(A1: Integer; A2: Integer);
begin end;

procedure TProductionScreen.QueueLBChange;
begin end;

procedure TProductionScreen.B4CBUpdate(A1: Integer);
begin end;

procedure TProductionScreen.LoopQueueBoxChange;
begin end;

procedure TProductionScreen.CurrentActionImageDraw(A1: Integer; A2: Integer);
begin end;

procedure TProductionScreen.MapViewDraw(A1: Integer; A2: Integer);
begin end;

procedure TProductionScreen.DlgKeyDown(A1: Integer; A2: Integer);
begin end;

procedure TProductionScreen.MapViewUpdate;
begin end;

procedure TProductionScreen.DlgHide;
begin end;

procedure TProductionScreen.UAbilitiesLBMouseDown(A1: Integer; A2: Byte);
begin end;

procedure TProductionScreen.PPrevClick(A1: Integer; A2: Integer);
begin end;

procedure TProductionScreen.PNextClick(A1: Integer; A2: Integer);
begin end;


end.
