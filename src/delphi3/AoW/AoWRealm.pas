unit AoWRealm;

{ Draft declarations of AoWRealm, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TRealmWin = class;


  { TRealmWin (instance size 412, VMT 004484F0) }
  TRealmWin = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    OWTitle: TAOWLabel; { +0048 }
    OWTitleIc: TAOWImage; { +004C }
    HeaderTab: TAOWTabPanel; { +0050 }
    T1Pnl: TAOWPanel; { +0054 }
    T2Pnl: TAOWPanel; { +0058 }
    T2LBPnl: TAOWPanel; { +005C }
    T3Pnl: TAOWPanel; { +0060 }
    T3LBPnl: TAOWPanel; { +0064 }
    Minimize: TAOWButton; { +0068 }
    T4Pnl: TAOWPanel; { +006C }
    T4LBPnl: TAOWPanel; { +0070 }
    T2NameLB: TAOWListBox; { +0074 }
    T2RaceLB: TAOWListBox; { +0078 }
    T2IncomeLB: TAOWListBox; { +007C }
    T2LevelLB: TAOWListBox; { +0080 }
    T2WallLB: TAOWListBox; { +0084 }
    T2SizeLB: TAOWListBox; { +0088 }
    T2EncLB: TAOWListBox; { +008C }
    T2SName: TAOWButton; { +0090 }
    T2SRace: TAOWButton; { +0094 }
    T2SIn: TAOWButton; { +0098 }
    T2SWall: TAOWButton; { +009C }
    T2SLvl: TAOWButton; { +00A0 }
    T2SSize: TAOWButton; { +00A4 }
    T2SEnc: TAOWButton; { +00A8 }
    T2ActLB: TAOWListBox; { +00AC }
    T2SAct: TAOWButton; { +00B0 }
    T2RelLB: TAOWListBox; { +00B4 }
    T2SRel: TAOWButton; { +00B8 }
    T2MorLB: TAOWListBox; { +00BC }
    T2SMor: TAOWButton; { +00C0 }
    CitySB: TAOWVScrollBar; { +00C4 }
    T3Name: TAOWListBox; { +00C8 }
    T3SName: TAOWButton; { +00CC }
    T3ActLB: TAOWListBox; { +00D0 }
    T3Activity: TAOWButton; { +00D4 }
    PlaceSB: TAOWVScrollBar; { +00D8 }
    UnitFr: TAoWFrame; { +00DC }
    UnitGg: TAoWGauge; { +00E0 }
    Unit1LB: TAOWListBox; { +00E4 }
    Unit2LB: TAOWListBox; { +00E8 }
    Unit3LB: TAOWListBox; { +00EC }
    Unit4LB: TAOWListBox; { +00F0 }
    Unit5LB: TAOWListBox; { +00F4 }
    Unit6LB: TAOWListBox; { +00F8 }
    Unit7LB: TAOWListBox; { +00FC }
    Unit8LB: TAOWListBox; { +0100 }
    PartySb: TAOWVScrollBar; { +0104 }
    HeroPnl: TAOWPanel; { +0108 }
    T5MainPnl: TAOWPanel; { +010C }
    T5Name: TAOWListBox; { +0110 }
    T5Health: TAOWListBox; { +0114 }
    T5Level: TAOWListBox; { +0118 }
    T5SName: TAOWButton; { +011C }
    T5SHealth: TAOWButton; { +0120 }
    T5SLevel: TAOWButton; { +0124 }
    T5HeroInf: TAOWPanel; { +0128 }
    T5LBFr: TAOWPanel; { +012C }
    HInfoBtn: TAOWButton; { +0130 }
    HeroSB: TAOWVScrollBar; { +0134 }
    TotalPnl: TAOWPanel; { +0138 }
    IncomePnl: TAOWPanel; { +013C }
    IncomeMem: TAOWMemo; { +0140 }
    IncomeBtm: TAOWPanel; { +0144 }
    IncomeSB: TAOWVScrollBar; { +0148 }
    IncomeLbl: TAOWLabel; { +014C }
    Income: TAOWLabel; { +0150 }
    UpkeepPnl: TAOWPanel; { +0154 }
    UpkeepMem: TAOWMemo; { +0158 }
    UpkeepBtm: TAOWPanel; { +015C }
    UpkeepSB: TAOWVScrollBar; { +0160 }
    UpkeepLbl: TAOWLabel; { +0164 }
    Upkeep: TAOWLabel; { +0168 }
    Totallbl: TAOWLabel; { +016C }
    NetInc: TAOWLabel; { +0170 }
    TotalBtm: TAOWPanel; { +0174 }
    TreasuryLbl: TAOWLabel; { +0178 }
    Treasury: TAOWLabel; { +017C }
    TreasuryPnl: TAOWPanel; { +0180 }
    IncomeValue: TAOWMemo; { +0184 }
    UpkeepValue: TAOWMemo; { +0188 }
    GoldAnim: TAOWImage; { +018C }
    PicPnl: TAOWPanel; { +0190 }
    Help: TAOWButton; { +0194 }
    Translator: TIvTranslator; { +0198 }
    public
    procedure OWMinIconClick;  { draft }
    procedure T2WallLBDrawItem(A1: Integer; A2: Integer);  { draft }
    procedure Unit1LBDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure HeaderTabChange;  { draft }
    procedure PartyVSBChange;  { draft }
    procedure Unit1LBChange(A1: Integer);  { draft }
    procedure T2MorLBDrawItem(A1: Integer; A2: Integer);  { draft }
    procedure CityListMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure CityListChange(A1: Integer);  { draft }
    procedure CityDoubleClick(A1: Integer);  { draft }
    procedure PlaceListDoubleClick(A1: Integer);  { draft }
    procedure PlacesListMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure HeroListDoubleClick(A1: Integer);  { draft }
    procedure HeroListMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure HeroInfoClick;  { draft }
    procedure T2LevelLBDoubleClick;  { draft }
    procedure T2WallLBDoubleClick;  { draft }
    procedure T2RaceLBDoubleClick;  { draft }
    procedure T2ActLBDrawItem(A1: Integer; A2: Integer);  { draft }
    procedure T2ActLBDoubleClick;  { draft }
    procedure T2RelLBDrawItem(A1: Integer; A2: Integer);  { draft }
    procedure OverWindowResize;  { draft }
    procedure T2SBChange;  { draft }
    procedure T3NameChange(A1: Integer);  { draft }
    procedure T3SBChange;  { draft }
    procedure T2SNameClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SRaceClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SInClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SLvlClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SWallClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SSizeClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SRelClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SMorClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SActClick(A1: Integer; A2: Integer);  { draft }
    procedure T2SEncClick(A1: Integer; A2: Integer);  { draft }
    procedure T3SNameClick(A1: Integer; A2: Integer);  { draft }
    procedure HeroListChange(A1: Integer);  { draft }
    procedure HeroVSBChange;  { draft }
    procedure T5HeroInfDraw(A1: Integer; A2: Integer);  { draft }
    procedure Unit1LBDoubleClick(A1: Integer);  { draft }
    procedure T5SNameClick(A1: Integer; A2: Integer);  { draft }
    procedure T5SHealthClick(A1: Integer; A2: Integer);  { draft }
    procedure T5SLevelClick(A1: Integer; A2: Integer);  { draft }
    procedure GotoButClick;  { draft }
    procedure T4PnlShow(A1: Integer; A2: Integer);  { draft }
    procedure T4PnlHide(A1: Integer; A2: Integer);  { draft }
    procedure OverWindowShow;  { draft }
    procedure OverWindowHide;  { draft }
    procedure IncomeSBChange;  { draft }
    procedure T3ActivityClick(A1: Integer; A2: Integer);  { draft }
    procedure UpkeepSBChange;  { draft }
    procedure DlgShow;  { draft }
    procedure DlgHide;  { draft }
    procedure HelpClick;  { draft }
  end;


implementation

procedure TRealmWin.OWMinIconClick;
begin end;

procedure TRealmWin.T2WallLBDrawItem(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.Unit1LBDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRealmWin.HeaderTabChange;
begin end;

procedure TRealmWin.PartyVSBChange;
begin end;

procedure TRealmWin.Unit1LBChange(A1: Integer);
begin end;

procedure TRealmWin.T2MorLBDrawItem(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.CityListMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TRealmWin.CityListChange(A1: Integer);
begin end;

procedure TRealmWin.CityDoubleClick(A1: Integer);
begin end;

procedure TRealmWin.PlaceListDoubleClick(A1: Integer);
begin end;

procedure TRealmWin.PlacesListMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TRealmWin.HeroListDoubleClick(A1: Integer);
begin end;

procedure TRealmWin.HeroListMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TRealmWin.HeroInfoClick;
begin end;

procedure TRealmWin.T2LevelLBDoubleClick;
begin end;

procedure TRealmWin.T2WallLBDoubleClick;
begin end;

procedure TRealmWin.T2RaceLBDoubleClick;
begin end;

procedure TRealmWin.T2ActLBDrawItem(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2ActLBDoubleClick;
begin end;

procedure TRealmWin.T2RelLBDrawItem(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.OverWindowResize;
begin end;

procedure TRealmWin.T2SBChange;
begin end;

procedure TRealmWin.T3NameChange(A1: Integer);
begin end;

procedure TRealmWin.T3SBChange;
begin end;

procedure TRealmWin.T2SNameClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SRaceClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SInClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SLvlClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SWallClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SSizeClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SRelClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SMorClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SActClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T2SEncClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T3SNameClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.HeroListChange(A1: Integer);
begin end;

procedure TRealmWin.HeroVSBChange;
begin end;

procedure TRealmWin.T5HeroInfDraw(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.Unit1LBDoubleClick(A1: Integer);
begin end;

procedure TRealmWin.T5SNameClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T5SHealthClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T5SLevelClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.GotoButClick;
begin end;

procedure TRealmWin.T4PnlShow(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.T4PnlHide(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.OverWindowShow;
begin end;

procedure TRealmWin.OverWindowHide;
begin end;

procedure TRealmWin.IncomeSBChange;
begin end;

procedure TRealmWin.T3ActivityClick(A1: Integer; A2: Integer);
begin end;

procedure TRealmWin.UpkeepSBChange;
begin end;

procedure TRealmWin.DlgShow;
begin end;

procedure TRealmWin.DlgHide;
begin end;

procedure TRealmWin.HelpClick;
begin end;


end.
