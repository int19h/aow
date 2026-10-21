unit AoWInfoWin;

{ Draft declarations of AoWInfoWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWArnoLine, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TIWindow = class;


  { TIWindow (instance size 436, VMT 00441930) }
  TIWindow = class(TDataModule)
  public
    published
    InfoWin: TAOWWindow; { +0044 }
    Min: TAOWButton; { +0048 }
    Close: TAOWButton; { +004C }
    Title: TAOWLabel; { +0050 }
    SIcon: TAOWImage; { +0054 }
    MainBtn: TAOWButton; { +0058 }
    CeltFrame: TAoWFrame; { +005C }
    StructLine: TAoWArnoLine; { +0060 }
    StructNameLbl: TAOWLabel; { +0064 }
    ProductionPlacePnl: TAOWPanel; { +0068 }
    NamePnl: TAOWPanel; { +006C }
    ActiveActionMemo: TAOWMemo; { +0070 }
    SignPnl: TAOWPanel; { +0074 }
    SignText: TAOWMemo; { +0078 }
    SignLbl: TAOWLabel; { +007C }
    SignTLine: TAoWFrame; { +0080 }
    SignTDecoL: TAOWImage; { +0084 }
    SignTDecoR: TAOWImage; { +0088 }
    SignBLine: TAoWFrame; { +008C }
    SignBDecoL: TAOWImage; { +0090 }
    SingBDemoR: TAOWImage; { +0094 }
    SignTextSB: TAOWVScrollBar; { +0098 }
    CityPanel: TAOWPanel; { +009C }
    CityRaceLbl: TAOWLabel; { +00A0 }
    CityBorderPnl: TAOWPanel; { +00A4 }
    ProdOrb: TAOWImage; { +00A8 }
    SingleButPnl: TAOWPanel; { +00AC }
    SBmemo: TAOWMemo; { +00B0 }
    AltarPnl: TAOWPanel; { +00B4 }
    Bar: TAoWGauge; { +00B8 }
    ChargeLbl: TAOWLabel; { +00BC }
    GemLbl: TAOWLabel; { +00C0 }
    ChargePcntLbl: TAOWLabel; { +00C4 }
    T2GemI: TAOWImage; { +00C8 }
    T2TurnI: TAOWImage; { +00CC }
    DayLbl: TAOWLabel; { +00D0 }
    LShield: TAOWImage; { +00D4 }
    NotYoursPnl: TAOWPanel; { +00D8 }
    NotYoursMemo: TAOWMemo; { +00DC }
    Ownerlbl: TAOWLabel; { +00E0 }
    OwnerRaceLbl: TAOWLabel; { +00E4 }
    ProdOrbTurnsLbl: TAOWLabel; { +00E8 }
    orLbl: TAOWLabel; { +00EC }
    AltarInfoPnl: TAOWPanel; { +00F0 }
    ProdOrbTime: TAOWImage; { +00F4 }
    Center: TAOWButton; { +00F8 }
    ConstructionPnl: TAOWPanel; { +00FC }
    ConstructionMemo: TAOWMemo; { +0100 }
    UnderConstructionLbl: TAOWLabel; { +0104 }
    ConstructionDaysLeftLbl: TAOWLabel; { +0108 }
    RazePnl: TAOWPanel; { +010C }
    RazeBg: TAOWImage; { +0110 }
    RazeBtn: TAOWButton; { +0114 }
    CivilStatusLbl: TAOWLabel; { +0118 }
    RaceRelationIcon: TAOWImage; { +011C }
    CityIncomeLbl: TAOWLabel; { +0120 }
    GoldIcn: TAOWImage; { +0124 }
    UgradeI: TAOWImage; { +0128 }
    CityLevelLbl: TAOWLabel; { +012C }
    InfoPnl: TAOWPanel; { +0130 }
    ProductionPlaceInfoPnl: TAOWPanel; { +0134 }
    IncomeTypeIcon: TAOWImage; { +0138 }
    IncomeValueLbl: TAOWLabel; { +013C }
    ActiveCityActionMemo: TAOWMemo; { +0140 }
    CostToFireLbl: TAOWLabel; { +0144 }
    CurrentActivityLbl: TAOWLabel; { +0148 }
    IncomeLbl: TAOWLabel; { +014C }
    ProductionWarningLbl: TAOWLabel; { +0150 }
    CurrentActivityWarningLbl: TAOWLabel; { +0154 }
    IncomePnl: TAOWPanel; { +0158 }
    IncomInfoPnl: TAOWPanel; { +015C }
    IncomeTypeImage: TAOWImage; { +0160 }
    IncomeAmountLbl: TAOWLabel; { +0164 }
    IncomeTextLbl: TAOWLabel; { +0168 }
    IncomeMemo: TAOWMemo; { +016C }
    ItemPnl: TAOWPanel; { +0170 }
    ItemsInBagLbl: TAOWLabel; { +0174 }
    ItembagLB: TAOWListBox; { +0178 }
    ItembagSB: TAOWVScrollBar; { +017C }
    ItemBagMemo: TAOWMemo; { +0180 }
    SBSB: TAOWVScrollBar; { +0184 }
    NotYoursMemoSB: TAOWVScrollBar; { +0188 }
    ExplorationSitePnl: TAOWPanel; { +018C }
    ESMemo: TAOWMemo; { +0190 }
    ESSB: TAOWVScrollBar; { +0194 }
    ESLbl: TAOWLabel; { +0198 }
    ESStatusLbl: TAOWLabel; { +019C }
    Help: TAOWButton; { +01A0 }
    PopulationRaceLbl: TAOWLabel; { +01A4 }
    PopulationLbl: TAOWLabel; { +01A8 }
    Translator: TIvTranslator; { +01AC }
    public
    F_IWindow_1B0: Integer;
    procedure InfoWinResize;  { draft }
    procedure MinClick;  { draft }
    procedure CloseClick(A1: Integer);  { draft }
    procedure ProdOrb2Draw;  { draft }
    procedure ProdOrb1Draw;  { draft }
    procedure CenterClick;  { draft }
    procedure RazeBtnClick;  { draft }
    procedure MainBtnClick;  { draft }
    procedure ItembagLBDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure HelpClick;  { draft }
    procedure ESSBChange;  { draft }
  end;


implementation

procedure TIWindow.InfoWinResize;
begin end;

procedure TIWindow.MinClick;
begin end;

procedure TIWindow.CloseClick(A1: Integer);
begin end;

procedure TIWindow.ProdOrb2Draw;
begin end;

procedure TIWindow.ProdOrb1Draw;
begin end;

procedure TIWindow.CenterClick;
begin end;

procedure TIWindow.RazeBtnClick;
begin end;

procedure TIWindow.MainBtnClick;
begin end;

procedure TIWindow.ItembagLBDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TIWindow.HelpClick;
begin end;

procedure TIWindow.ESSBChange;
begin end;


end.
