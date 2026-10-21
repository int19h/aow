unit AoWCityScreen;

{ Draft declarations of AoWCityScreen, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox;

type
  TCityScreen = class;


  { TCityScreen (instance size 732, VMT 00439F68) }
  TCityScreen = class(TDataModule)
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
    P1CB: TAOWCheckBox; { +00B4 }
    P2CB: TAOWCheckBox; { +00B8 }
    P3CB: TAOWCheckBox; { +00BC }
    P4CB: TAOWCheckBox; { +00C0 }
    P5CB: TAOWCheckBox; { +00C4 }
    P6CB: TAOWCheckBox; { +00C8 }
    P7CB: TAOWCheckBox; { +00CC }
    P8CB: TAOWCheckBox; { +00D0 }
    P9CB: TAOWCheckBox; { +00D4 }
    P10CB: TAOWCheckBox; { +00D8 }
    P11CB: TAOWCheckBox; { +00DC }
    P12CB: TAOWCheckBox; { +00E0 }
    B4CB: TAOWCheckBox; { +00E4 }
    B5CB: TAOWCheckBox; { +00E8 }
    B6CB: TAOWCheckBox; { +00EC }
    B1CB: TAOWCheckBox; { +00F0 }
    B2CB: TAOWCheckBox; { +00F4 }
    B3CB: TAOWCheckBox; { +00F8 }
    T2SBar: TAOWVScrollBar; { +00FC }
    AbilPnl: TAOWPanel; { +0100 }
    UpgradePnl: TAOWPanel; { +0104 }
    UpgradeLbl: TAOWLabel; { +0108 }
    UpgradeMemoFr: TAOWPanel; { +010C }
    UpgradeMemo: TAOWMemo; { +0110 }
    RightPnl: TAOWPanel; { +0114 }
    QueuePnl: TAOWPanel; { +0118 }
    Oval: TAOWImage; { +011C }
    ShadowL: TAOWImage; { +0120 }
    ShadowR: TAOWImage; { +0124 }
    CityBtn3: TAOWButton; { +0128 }
    CityBtn1: TAOWButton; { +012C }
    QueueLB: TAOWListBox; { +0130 }
    ActivityPnl: TAOWPanel; { +0134 }
    InfoPnl2: TAOWPanel; { +0138 }
    ActiveAction: TAOWLabel; { +013C }
    ActiveActionTurns: TAOWLabel; { +0140 }
    SepBar: TAOWImage; { +0144 }
    ActivityPnl2: TAOWPanel; { +0148 }
    ActiveActionTurnsBar: TAoWGauge; { +014C }
    CityBtn2: TAOWButton; { +0150 }
    InfoPnl: TAOWPanel; { +0154 }
    IPPnl: TAOWPanel; { +0158 }
    IPPicFr: TAoWFrame; { +015C }
    PopulationMemo: TAOWMemo; { +0160 }
    PopulationHdr: TAOWMemo; { +0164 }
    IIPnl: TAOWPanel; { +0168 }
    IIPicFr: TAoWFrame; { +016C }
    IncomeMemo: TAOWMemo; { +0170 }
    IncomeHdr: TAOWMemo; { +0174 }
    IEPnl: TAOWPanel; { +0178 }
    IEPicFr: TAoWFrame; { +017C }
    EnhancementsMemo: TAOWMemo; { +0180 }
    EnhancementsHdr: TAOWMemo; { +0184 }
    CurrentInfo: TAOWPanel; { +0188 }
    RPillar: TAoWFrame; { +018C }
    LPillar: TAoWFrame; { +0190 }
    QueueInfo: TAOWPanel; { +0194 }
    QueueLbl: TAOWLabel; { +0198 }
    LoopQueueBox: TAOWCheckBox; { +019C }
    RepeatLbl: TAOWLabel; { +01A0 }
    ActiveActionPnl: TAOWPanel; { +01A4 }
    CurrentActionImage: TAOWImage; { +01A8 }
    RacePortrait: TAOWImage; { +01AC }
    AoWFrame1: TAoWFrame; { +01B0 }
    BlackBg: TAOWImage; { +01B4 }
    BlackBg2: TAOWImage; { +01B8 }
    UPictureFramePnl: TAOWPanel; { +01BC }
    UStatFr1: TAOWPanel; { +01C0 }
    UStatFr2: TAOWPanel; { +01C4 }
    UInfoFr: TAOWPanel; { +01C8 }
    CostFr: TAOWPanel; { +01CC }
    TurnsFr: TAOWPanel; { +01D0 }
    UpgPicPnl: TAOWPanel; { +01D4 }
    UpgradePic: TAOWImage; { +01D8 }
    UpgPicFr: TAOWPanel; { +01DC }
    UpgCostPnl: TAOWPanel; { +01E0 }
    UpgCostLbl: TAOWLabel; { +01E4 }
    UpgradeCost: TAOWLabel; { +01E8 }
    UpgTurnsLbl: TAOWLabel; { +01EC }
    UpgradeTurns: TAOWLabel; { +01F0 }
    UpgCostFr: TAOWPanel; { +01F4 }
    UpgTurnsFr: TAOWPanel; { +01F8 }
    MigratePnl: TAOWPanel; { +01FC }
    NewRaceLbl: TAOWLabel; { +0200 }
    MigrateMainFr: TAOWPanel; { +0204 }
    MigPicPnl: TAOWPanel; { +0208 }
    MigratePic: TAOWImage; { +020C }
    MigPicFr: TAOWPanel; { +0210 }
    MigCostPnl: TAOWPanel; { +0214 }
    MigCostLbl: TAOWLabel; { +0218 }
    MigrateCost: TAOWLabel; { +021C }
    MigTurnsLbl: TAOWLabel; { +0220 }
    MigrateTurns: TAOWLabel; { +0224 }
    MigCostFr: TAOWPanel; { +0228 }
    MigTurnsFr: TAOWPanel; { +022C }
    MigrationRaceLB: TAOWListBox; { +0230 }
    MigrationRelationLB: TAOWListBox; { +0234 }
    MigrationTurnsLB: TAOWListBox; { +0238 }
    SortMigrationRaces: TAOWButton; { +023C }
    SortMigrationTurns: TAOWButton; { +0240 }
    SortMigrationRelation: TAOWButton; { +0244 }
    T3LBPnl: TAOWPanel; { +0248 }
    MigrationSB: TAOWVScrollBar; { +024C }
    T3RaceLbl: TAOWLabel; { +0250 }
    CurrentRace: TAOWLabel; { +0254 }
    T3RelLbl: TAOWLabel; { +0258 }
    CurrentRelation: TAOWLabel; { +025C }
    CurrentRacePnl: TAOWPanel; { +0260 }
    CurrentRaceFr: TAOWPanel; { +0264 }
    CurrentRaceLbl: TAOWLabel; { +0268 }
    UpgBtm: TAOWPanel; { +026C }
    UpgradeInfo: TAOWLabel; { +0270 }
    RelIcn: TAOWImage; { +0274 }
    QueueVSB: TAOWVScrollBar; { +0278 }
    IPVSB: TAOWVScrollBar; { +027C }
    IIVSB: TAOWVScrollBar; { +0280 }
    IEVSB: TAOWVScrollBar; { +0284 }
    IncomeGoldMemo: TAOWMemo; { +0288 }
    Migrate: TAOWLabel; { +028C }
    UFace: TaowUserDrawBox; { +0290 }
    MigrateInfoPnl: TAOWPanel; { +0294 }
    MigrateInfo: TAOWLabel; { +0298 }
    MapView: TaowUserDrawBox; { +029C }
    InfoSep: TAOWImage; { +02A0 }
    PNext: TAOWButton; { +02A4 }
    PPrev: TAOWButton; { +02A8 }
    Translator: TIvTranslator; { +02AC }
    public
    F_CityScreen_2B0: Integer;
    F_CityScreen_2B4: Integer;
    F_CityScreen_2B8: Integer;
    F_CityScreen_2BC: Integer;
    F_CityScreen_2C0: Byte;
    F_CityScreen_2C1: array[0..2] of Byte;
    F_CityScreen_2C4: Integer;
    F_CityScreen_2C8: Integer;
    F_CityScreen_2CC: Byte;
    F_CityScreen_2CD: array[0..6] of Byte;
    F_CityScreen_2D4: Integer;
    F_CityScreen_2D8: Integer;
    procedure CityScreenCreate;  { draft }
    procedure CityScreenDestroy;  { draft }
    procedure ActivityChange(A1: Integer);  { draft }
    procedure ActivityDoubleClick(A1: Integer);  { draft }
    procedure ProductionChange(A1: Integer);  { draft }
    procedure ProductionDoubleClick(A1: Integer);  { draft }
    procedure ProductionsUpdate(A1: Integer);  { draft }
    procedure ActivityPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure CityBtn1Click;  { draft }
    procedure CityBtn2Click(A1: Integer; A2: Integer);  { draft }
    procedure CityBtn3Click;  { draft }
    procedure PreDrawProductions(A1: Integer; A2: Integer);  { draft }
    procedure SortMigrationRacesClick;  { draft }
    procedure SortMigrationTurnsClick;  { draft }
    procedure SortMigrationRelationClick;  { draft }
    procedure MigrationChange(A1: Integer);  { draft }
    procedure MigrationSBChange(A1: Integer);  { draft }
    procedure UFaceDraw(A1: Integer; A2: Integer);  { draft }
    procedure QueueLBChange(A1: Integer);  { draft }
    procedure CurrentActionImageDraw(A1: Integer; A2: Integer);  { draft }
    procedure LoopQueueBoxChange;  { draft }
    procedure RacePortraitDraw(A1: Integer; A2: Integer);  { draft }
    procedure MapViewDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer);  { draft }
    procedure MapViewUpdate;  { draft }
    procedure DlgHide;  { draft }
    procedure UAbilitiesLBMouseDown(A1: Integer; A2: Byte);  { draft }
    procedure PPrevClick(A1: Integer; A2: Integer);  { draft }
    procedure PNextClick(A1: Integer; A2: Integer);  { draft }
  end;


implementation

procedure TCityScreen.CityScreenCreate;
begin end;

procedure TCityScreen.CityScreenDestroy;
begin end;

procedure TCityScreen.ActivityChange(A1: Integer);
begin end;

procedure TCityScreen.ActivityDoubleClick(A1: Integer);
begin end;

procedure TCityScreen.ProductionChange(A1: Integer);
begin end;

procedure TCityScreen.ProductionDoubleClick(A1: Integer);
begin end;

procedure TCityScreen.ProductionsUpdate(A1: Integer);
begin end;

procedure TCityScreen.ActivityPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.CityBtn1Click;
begin end;

procedure TCityScreen.CityBtn2Click(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.CityBtn3Click;
begin end;

procedure TCityScreen.PreDrawProductions(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.SortMigrationRacesClick;
begin end;

procedure TCityScreen.SortMigrationTurnsClick;
begin end;

procedure TCityScreen.SortMigrationRelationClick;
begin end;

procedure TCityScreen.MigrationChange(A1: Integer);
begin end;

procedure TCityScreen.MigrationSBChange(A1: Integer);
begin end;

procedure TCityScreen.UFaceDraw(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.QueueLBChange(A1: Integer);
begin end;

procedure TCityScreen.CurrentActionImageDraw(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.LoopQueueBoxChange;
begin end;

procedure TCityScreen.RacePortraitDraw(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.MapViewDraw(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.DlgKeyDown(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.MapViewUpdate;
begin end;

procedure TCityScreen.DlgHide;
begin end;

procedure TCityScreen.UAbilitiesLBMouseDown(A1: Integer; A2: Byte);
begin end;

procedure TCityScreen.PPrevClick(A1: Integer; A2: Integer);
begin end;

procedure TCityScreen.PNextClick(A1: Integer; A2: Integer);
begin end;


end.
