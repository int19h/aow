unit AoWInfoWin;

{ Information-window actions, drawing and alignment recovered from AoW.exe.
  Layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AOWGauge, AoWArnoLine, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TIWindow = class;


  { TIWindow: size $1B4; $1B0 item bag. VMT 00441930. }
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
    FItemBag: TItemHS; { $1B0; 0044252F }
    procedure InfoWinResize;
    procedure MinClick;
    procedure CloseClick(Sender: TObject);
    procedure ProdOrb2Draw;
    procedure ProdOrb1Draw;
    procedure CenterClick;
    procedure RazeBtnClick;
    procedure MainBtnClick;
    procedure ItembagLBDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; const Surface: TSurfaceDesc);
    procedure HelpClick;
    procedure ESSBChange;
  end;


implementation

uses AoWWinMan, AoWExeForms, AoWCityScreen, AoWProdScreen, City, PrdPlace, Cave, Teleport, ExploreS, WizardsTower, Arena, Altar, aowHelpWin, E2CampaignSupport;

procedure TIWindow.InfoWinResize;
begin
  with InfoWin do
  begin
    Alignment.RightOffset := FWinManager.WinWidth - WinLeft - WinWidth;
    Alignment.TopOffset := WinTop;
  end;
end;

procedure TIWindow.MinClick;
begin
  General.PlayButtonSound(0);
  InfoWin.Visible := False;
end;

procedure TIWindow.CloseClick(Sender: TObject);
begin
  if Sender <> nil then General.PlayButtonSound(0);
  InfoWin.Visible := False;
  TBWindow.StructButton.Visible := False;
end;

procedure TIWindow.ProdOrb2Draw;
begin end;

procedure TIWindow.ProdOrb1Draw;
begin end;

procedure TIWindow.CenterClick;
begin
  General.PlayButtonSound(0);
  if FItemBag <> nil then
  begin
    with FItemBag do AoWHSMap.CenterViewTo(Xhx, FItemBag.Yhx, FItemBag.Lhx);
    AoWHSMap.PlayCenterAnimation(FItemBag.Xhx, FItemBag.Yhx, FItemBag.Lhx);
  end
  else
  begin
    AoWHSMap.CenterViewTo(General.FStructure.Xhx, General.FStructure.Yhx, General.FStructure.Lhx);
    AoWHSMap.PlayCenterAnimation(General.FStructure.Xhx, General.FStructure.Yhx, General.FStructure.Lhx);
  end;
end;

procedure TIWindow.RazeBtnClick;
var Reason: string;
begin
  General.PlayButtonSound(0);
  if General.FStructure <> nil then
    if General.FStructure.CanRaze(AoWHSMap.FSeatedPlayer, Reason) then
      General.FStructure.Raze(AoWHSMap.FSeatedPlayer)
    else AoWHSMap.ShowWarning(Reason);
end;

procedure TIWindow.MainBtnClick;
var
  Army: TArmyHS;
  Reason: string;
begin
  General.PlayButtonSound(0);
  if General.FStructure <> nil then
  begin
    if General.FStructure is TCity then CityScreen.ShowCity(TCity(General.FStructure))
    else if General.FStructure is TProductionPlace then ProductionScreen.ShowPlace(TProductionPlace(General.FStructure))
    else if General.FStructure is TCave then TCave(General.FStructure).Enter(AoWHSMap.FSeatedPlayer)
    else if General.FStructure is TTeleport then TTeleport(General.FStructure).Teleport(AoWHSMap.FSeatedPlayer)
    else if General.FStructure is TExplorationSite then TExplorationSite(General.FStructure).Search
    else if General.FStructure is TWizardsTower then TWizardsTower(General.FStructure).Enter
    else if General.FStructure is TArena then TArena(General.FStructure).Enter
    else if General.FStructure is TAltar then
      if not TAltar(General.FStructure).GetTargeting then
      begin
        if TAltar(General.FStructure).CanTarget(Reason) then TAltar(General.FStructure).Target
        else AoWHSMap.ShowWarning(Reason);
      end
      else TAltar(General.FStructure).CancelTargeting;
  end
  else if FItemBag <> nil then
  begin
    Army := TAoWMapField(FItemBag.Owner).GetArmyHS;
    if (Army <> nil) and (Army.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
      if Army.FArmy.Hero($FF, AllHeroTypes) <> nil then
      begin
        General.FSelectedUnit := Army.FArmy.Hero($FF, AllHeroTypes);
        UnitWindow.ShowUnit;
        UnitWindow.UnitTab.Selected := 2;
      end;
  end;
end;

procedure TIWindow.ItembagLBDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; const Surface: TSurfaceDesc);
begin
  if FItemBag <> nil then
    if FItemBag.FItems.Count > ItembagLB.ListOffset then { Original uses the scroll offset for every row. }
      FItemBag.FItems.GetItem(ItembagLB.ListOffset).Show(DrawRect.Left + 10, DrawRect.Top + 10, Surface);
end;

procedure TIWindow.HelpClick;
begin ShowHelp(504); end;

procedure TIWindow.ESSBChange;
begin
  ESMemo.FDrawn := False;
  InfoWin.FDrawn := False;
end;

end.
