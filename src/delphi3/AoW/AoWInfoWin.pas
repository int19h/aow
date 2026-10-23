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
    published procedure InfoWinResize; public
    published procedure MinClick; public
    published procedure CloseClick(Sender: TObject); public
    published procedure ProdOrb2Draw; public
    published procedure ProdOrb1Draw; public
    published procedure CenterClick; public
    published procedure RazeBtnClick; public
    published procedure MainBtnClick; public
    published procedure ItembagLBDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; const Surface: TSurfaceDesc); public
    published procedure HelpClick; public
    published procedure ESSBChange; public
  end;


var IWindow: TIWindow;

procedure ShowStructureInfo(Dialog: TIWindow; Structure: TStructure);
procedure UpdateStructureInfo(Dialog: TIWindow; Structure: TStructure);
procedure ShowItemSelection(Dialog: TIWindow; Items: TItemHS);
procedure UpdateItemSelection(Dialog: TIWindow; Items: TItemHS);

implementation

uses E3Globals, Mine, PowerNode, Farm, Tower, Sign, AoWWinMan, AoWExeForms, AoWCityScreen, AoWProdScreen, City, PrdPlace, Cave, Teleport, ExploreS, WizardsTower, Arena, Altar, aowHelpWin, E2CampaignSupport;

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

procedure ResetStructureInfo(Dialog: TIWindow);
begin
  with Dialog do
  begin
    StructLine.Visible := True;
    StructLine.FSized := False;
    InfoWin.FAligned := False;
    CityPanel.Visible := False; CityBorderPnl.Visible := False;
    ProductionPlacePnl.Visible := False; SignPnl.Visible := False;
    NotYoursPnl.Visible := False; SingleButPnl.Visible := False;
    MainBtn.Visible := True; RazeBtn.Visible := True;
    ExplorationSitePnl.Visible := False; AltarPnl.Visible := False;
    IncomePnl.Visible := False; ItemPnl.Visible := False;
    ConstructionPnl.Visible := False; ProdOrb.Visible := False;
    ProdOrbTime.Visible := False; ProdOrbTurnsLbl.Visible := False; RazePnl.Visible := False;
    MainBtn.Visible := False; SBmemo.Items.Clear;
    PopulationRaceLbl.Visible := False; PopulationLbl.Visible := False;
    Title.Text := TranslateRStr(StructureRStr);
  end;
end;

procedure SetStructureHeader(Dialog: TIWindow; Structure: TStructure);
begin
  with Dialog do
  begin
    StructNameLbl.Text := Structure.GetName;
    if Structure.GetBottomBorderImage <> nil then
    begin
      StructLine.ImageTop := Structure.GetTopBorderImage;
      StructLine.ImageMiddle := Structure.GetMiddleBorderImage;
      StructLine.ImageBottom := Structure.GetBottomBorderImage;
    end;
    StructLine.Visible := True;
  end;
end;

procedure ShowMineInfo(Dialog: TIWindow; Structure: TMine);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    IncomePnl.Visible := True;
    IncomeMemo.Items.Assign(Structure.GetDescription);
    IncomeTypeImage.CurrentImage := 31;
    IncomeAmountLbl.Text := IntToStr(Structure.GetIncome);
    RazePnl.Visible := True;
  end;
end;

procedure ShowPowerNodeInfo(Dialog: TIWindow; Structure: TPowerNode);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    IncomePnl.Visible := True;
    IncomeMemo.Items.Assign(Structure.GetDescription);
    IncomeTypeImage.CurrentImage := 33;
    IncomeAmountLbl.Text := IntToStr(Structure.GetPower);
    RazePnl.Visible := True;
  end;
end;

procedure ShowProductionIncome(Dialog: TIWindow; Structure: TProductionPlace);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    IncomePnl.Visible := True;
    IncomeMemo.Items.Assign(Structure.GetDescription);
    IncomeTypeImage.CurrentImage := 33;
    IncomeAmountLbl.Text := IntToStr(Structure.GetPower);
    RazePnl.Visible := True;
  end;
end;

procedure ShowFarmInfo(Dialog: TIWindow; Structure: TFarm);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    SingleButPnl.Visible := True; SBmemo.Items.Assign(Structure.GetDescription);
    SBmemo.Items.Add('');
    SBmemo.Items.Add(AoWE.Format(TranslateRStr(IncomeXRStr), [IntToStr(Structure.FIncome)]));
    RazePnl.Visible := True;
  end;
end;

procedure ShowSignInfo(Dialog: TIWindow; Structure: TSign);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  General.FSign := Structure;
  Dialog.SignPnl.Visible := True;
  Dialog.SignText.Items.Assign(Structure.FText);
end;

procedure ShowTeleportInfo(Dialog: TIWindow; Structure: TTeleport);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    SingleButPnl.Visible := True;
    SBmemo.Items.Assign(General.FStructure.GetDescription);
    SBmemo.FSized := False;
    MainBtn.Visible := Structure.CanTeleport(AoWHSMap.FSeatedPlayer);
    MainBtn.Text := TranslateRStr(TeleportRStr);
    RazePnl.Visible := MainBtn.Visible;
  end;
end;

procedure ShowTowerInfo(Dialog: TIWindow; Structure: TWizardsTower);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    SingleButPnl.Visible := True; SBmemo.Items.Assign(Structure.GetDescription);
    MainBtn.Visible := Structure.CanEnter(AoWHSMap.FSeatedPlayer);
    MainBtn.Text := TranslateRStr(EnterRStr);
  end;
end;

procedure ShowArenaInfo(Dialog: TIWindow; Structure: TArena);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    SingleButPnl.Visible := True; SBmemo.Items.Assign(Structure.GetDescription);
    MainBtn.Visible := Structure.CanEnter(AoWHSMap.FSeatedPlayer);
    MainBtn.Text := TranslateRStr(EnterRStr);
  end;
end;

procedure ShowCaveInfo(Dialog: TIWindow; Structure: TCave);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    SingleButPnl.Visible := True; SBmemo.Items.Assign(Structure.GetDescription);
    MainBtn.Visible := Structure.CanEnter(AoWHSMap.FSeatedPlayer);
    case Structure.FEntrance of
      ceUp: MainBtn.Text := TranslateRStr(GoUpRStr);
      ceDown: MainBtn.Text := TranslateRStr(GoDownRStr);
    end;
  end;
end;

procedure ShowWatchTowerInfo(Dialog: TIWindow; Structure: TTower);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  Dialog.SingleButPnl.Visible := True;
  Dialog.SBmemo.Items.Assign(Structure.GetDescription);
  Dialog.RazePnl.Visible := True;
end;

procedure ShowExplorationInfo(Dialog: TIWindow; Structure: TExplorationSite);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    ExplorationSitePnl.Visible := True;
    ESMemo.Items.Assign(General.FStructure.GetDescription);
    ESLbl.Text := TranslateRStr(StatusRStr) + ':';
    if Structure.GetExplored then ESStatusLbl.Text := TranslateRStr(ExploredRStr)
    else ESStatusLbl.Text := TranslateRStr(UnexploredRStr);
    MainBtn.Visible := TExplorationSite(General.FStructure).CanSearch(AoWHSMap.FSeatedPlayer);
    MainBtn.Text := TranslateRStr(SearchRStr);
  end;
end;

procedure ShowAltarInfo(Dialog: TIWindow; Structure: TAltar);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    AltarPnl.Visible := True;
    if Structure.GetTargeting then MainBtn.Text := TranslateRStr(CancelRStr)
    else MainBtn.Text := TranslateRStr(TargetRStr);
    MainBtn.Visible := True;
    Bar.Max := Structure.GetRechargeDays; Bar.Position := Structure.FRechargeDays;
    ChargePcntLbl.Text := IntToStr(Round(Structure.FRechargeDays * 100 / Structure.GetRechargeDays)) + '%';
    DayLbl.Text := IntToStr(Structure.GetRechargeDays - Structure.FRechargeDays);
    GemLbl.Text := IntToStr(Structure.TargetMana);
    RazePnl.Visible := True;
  end;
end;

procedure ShowWarCityInfo(Dialog: TIWindow; Structure: TCity);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    SingleButPnl.Visible := True;
    SBmemo.Items.Add(''); SBmemo.Items.Add(''); SBmemo.Items.Add('');
    SBmemo.Items.Add(''); SBmemo.Items.Add(''); SBmemo.Items.Add('');
    SBmemo.Items.Add(TranslateRStr(StatusWarmodeRStr));
  end;
end;

procedure ShowCityInfo(Dialog: TIWindow; Structure: TCity);
var
  UnitObject: TUnit;
  Reason: string;
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    MainBtn.Text := TranslateRStr(EnterRStr); MainBtn.Visible := True;
    General.FCity := Structure;
    CityPanel.Visible := True; ProductionWarningLbl.Visible := False;
    ActiveCityActionMemo.Items.Clear;
    StructNameLbl.Text := General.FCity.GetName;
    CityRaceLbl.Text := AoWE.Format(TranslateRStr(RaceXRStr), [TranslateRStr(RaceNamesRStr[General.FCity.FRace])]);
    CityLevelLbl.Text := IntToStr(Structure.FUpgradeLevel);
    CityIncomeLbl.Text := IntToStr(Structure.FIncome);
    CivilStatusLbl.Text := AoWE.Format(TranslateRStr(StatusXRStr), [TranslateRStr(TCivilStatusRStr[Structure.GetCivilStatus])]);
    if Structure.FProduction.FQueue.GetCount <> 0 then
    begin
      case Structure.FProduction.FQueue.GetItem(0).FProductionID of
      2:
      begin
        UnitObject := Structure.FProduction.CreateUnitProduction(Structure.FProduction.FQueue.GetItem(0).FParameter);
        ActiveCityActionMemo.Items.Add(TranslateRStr(InstallingRStr));
        ActiveCityActionMemo.Items.Add(UnitObject.GetName);
        UnitObject.Release;
      end;
      1:
      begin
        UnitObject := Structure.FProduction.CreateUnitProduction(Structure.FProduction.FQueue.GetItem(0).FParameter);
        ActiveCityActionMemo.Items.Clear;
        ActiveCityActionMemo.Items.Add(TranslateRStr(ProducingRStr));
        ActiveCityActionMemo.Items.Add(UnitObject.GetName);
        UnitObject.Release;
      end;
      else ActiveCityActionMemo.Items.Text := Structure.FProduction.FQueue.GetItem(0).GetNameProgressive;
      end;
      if Structure.FProduction.FStatus = pcsProducing then
        if Structure.FProduction.FSettings.FTurnsLeft <> -1 then
          ActiveCityActionMemo.Items.Add(FmtTurnsLeftStr(Structure.FProduction.FSettings.FTurnsLeft))
        else ActiveCityActionMemo.Items.Add(LowerCase(TranslateRStr(UnlimitedRStr)))
      else if Structure.FProduction.FStatus = pcsWaiting then
      begin
        Structure.FProduction.CanExecuteProduction(Structure.FProduction.FQueue.GetItem(0), Reason);
        ProductionWarningLbl.Text := Reason; ProductionWarningLbl.Visible := True;
      end;
    end
    else
    begin
      ActiveCityActionMemo.Items.Add('');
      ActiveCityActionMemo.Items.Add(TranslateRStr(ProducingMerchandiseRStr));
    end;
    RaceRelationIcon.CurrentImage := Ord(AoWHSMap.FRaces.GetRace(Structure.FRace).GetPlayerRelation(Structure.FPlayer)) + 11;
    RazePnl.Visible := True;
  end;
end;

procedure ShowProductionInfo(Dialog: TIWindow; Structure: TProductionPlace);
var
  UnitObject: TUnit;
  Reason: string;
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    MainBtn.Text := TranslateRStr(EnterRStr); MainBtn.Visible := True;
    General.FProductionPlace := TProductionPlace(General.FStructure);
    ProductionPlacePnl.Visible := True;
    General.FProductionControl := General.FProductionPlace.FProductionControl;
    CurrentActivityWarningLbl.Visible := False;
    ActiveActionMemo.Items.Clear;
    IncomeLbl.Visible := True; IncomeTypeIcon.Visible := True; IncomeValueLbl.Visible := True;
    if Structure.GetMagicSphere <> msNone then
    begin IncomeTypeIcon.CurrentImage := 33; IncomeValueLbl.Text := IntToStr(Structure.GetPower); end
    else
      if Structure.GetBaseIncome <> 0 then
      begin IncomeTypeIcon.CurrentImage := 31; IncomeValueLbl.Text := IntToStr(Structure.GetIncome); end
      else begin IncomeLbl.Visible := False; IncomeTypeIcon.Visible := False; IncomeValueLbl.Visible := False; end;
    ProductionPlacePnl.Visible := True;
    StructNameLbl.Text := Structure.GetName;
    if Structure.FProductionControl.FQueue.GetCount <> 0 then
    begin
      case Structure.FProductionControl.FQueue.GetItem(0).FProductionID of
      2:
      begin
        UnitObject := Structure.FProductionControl.CreateUnitProduction(Structure.FProductionControl.FQueue.GetItem(0).FParameter);
        ActiveActionMemo.Items.Add(TranslateRStr(InstallingRStr));
        ActiveActionMemo.Items.Add(UnitObject.GetName); UnitObject.Release;
      end;
      1:
      begin
        UnitObject := Structure.FProductionControl.CreateUnitProduction(Structure.FProductionControl.FQueue.GetItem(0).FParameter);
        ActiveActionMemo.Items.Clear; ActiveActionMemo.Items.Add(TranslateRStr(ProducingRStr));
        ActiveActionMemo.Items.Add(UnitObject.GetName); UnitObject.Release;
      end;
      else ActiveActionMemo.Items.Text := Structure.FProductionControl.FQueue.GetItem(0).GetNameProgressive;
      end;
      if Structure.FProductionControl.FStatus = pcsProducing then
        if Structure.FProductionControl.FSettings.FTurnsLeft <> -1 then
          ActiveActionMemo.Items.Add(FmtTurnsLeftStr(Structure.FProductionControl.FSettings.FTurnsLeft))
        else ActiveCityActionMemo.Items.Add(LowerCase(TranslateRStr(UnlimitedRStr))) { Original writes the city memo in this branch. }
      else if Structure.FProductionControl.FStatus = pcsWaiting then
      begin
        Structure.FProductionControl.CanExecuteProduction(Structure.FProductionControl.FQueue.GetItem(0), Reason);
        CurrentActivityWarningLbl.Text := Reason; CurrentActivityWarningLbl.Visible := True;
      end;
    end
    else
      if Structure.GetMagicSphere = msNone then
      begin
        ActiveActionMemo.Items.Add('');
        if Structure.GetBaseIncome <> 0 then ActiveActionMemo.Items.Add(TranslateRStr(ProducingMerchandiseRStr))
        else ActiveActionMemo.Items.Add(TranslateRStr(NoneRStr));
      end
      else ActiveActionMemo.Items.Add(TranslateRStr(GeneratingExtraPowerRStr));
    RazePnl.Visible := True;
  end;
end;

procedure ShowBuildingInfo(Dialog: TIWindow; Structure: TStructure);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  Dialog.ConstructionPnl.Visible := True;
  Dialog.ConstructionDaysLeftLbl.Text := FmtDaysLeftStr(Structure.FBuildingDays);
  Dialog.ConstructionMemo.Items.Assign(Structure.GetDescription);
end;

procedure ShowRazedInfo(Dialog: TIWindow; Structure: TStructure);
var
  Text: string;
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    SingleButPnl.Visible := True;
    if Structure is TCity then Text := AoWE.Format(TranslateRStr(CityOfXRStr), [Structure.GetName])
    else Text := Structure.GetName;
    SBmemo.Items.Text := AoWE.Format(TranslateRStr(TheXliesInRuinsRStr), [Text]);
    SBmemo.Items.Insert(0, ''); SBmemo.Items.Insert(0, '');
  end;
end;

procedure ShowOtherPlayerInfo(Dialog: TIWindow; Structure: TPlayerStructure);
var
  RaceIndex: Integer;
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    NotYoursPnl.Visible := True;
    if (Structure is TCity) and (Structure.FPlayer = 0) then
    begin
      PopulationRaceLbl.Visible := True;
      PopulationRaceLbl.Text := TranslateRStr(RaceNamesPluralRStr[TCity(Structure).FRace]);
      PopulationLbl.Visible := True;
      NotYoursMemo.Items.Clear;
    end
    else NotYoursMemo.Items.Assign(Structure.GetDescription);
    if Structure.FPlayer <> -1 then
    begin
      RaceIndex := AoWHSMap.FPlayers.GetPlayers(Structure.FPlayer).FPlayerRace;
      if RaceIndex = -1 then RaceIndex := 12;
      OwnerRaceLbl.Text := TranslateRStr(RaceNamesPluralRStr[RaceIndex]);
      OwnerRaceLbl.Visible := True; LShield.CurrentImage := RaceIndex + 26; LShield.Visible := True;
    end
    else
    begin OwnerRaceLbl.Visible := False; LShield.Visible := False; end;
  end;
end;

procedure ShowGenericInfo(Dialog: TIWindow; Structure: TStructure);
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  Dialog.SingleButPnl.Visible := True;
  Dialog.SBmemo.Items.Assign(Structure.GetDescription);
end;

procedure ShowStructureInfo(Dialog: TIWindow; Structure: TStructure);
begin
  if Structure.GetBuilding then ShowBuildingInfo(Dialog, Structure)
  else if Structure.GetRazed then ShowRazedInfo(Dialog, Structure)
  else if Structure is TPlayerStructure then
    if (TPlayerStructure(Structure).FPlayer = AoWHSMap.FSeatedPlayer) or AoWEngine.FDebug then
      if Structure is TCity then
        if cmWarmode in TCity(Structure).FMode then ShowWarCityInfo(Dialog, TCity(Structure))
        else ShowCityInfo(Dialog, TCity(Structure))
      else if Structure is TProductionPlace then
        if TProductionPlace(Structure).GetMagicSphere = msNone then ShowProductionInfo(Dialog, TProductionPlace(Structure))
        else ShowProductionIncome(Dialog, TProductionPlace(Structure))
      else if Structure is TMine then ShowMineInfo(Dialog, TMine(Structure))
      else if Structure is TPowerNode then ShowPowerNodeInfo(Dialog, TPowerNode(Structure))
      else if Structure is TFarm then ShowFarmInfo(Dialog, TFarm(Structure))
      else if Structure is TTower then ShowWatchTowerInfo(Dialog, TTower(Structure))
      else if Structure is TAltar then ShowAltarInfo(Dialog, TAltar(Structure))
      else ShowGenericInfo(Dialog, Structure)
    else if (Structure is TCity) and (cmWarmode in TCity(Structure).FMode) then
      ShowWarCityInfo(Dialog, TCity(Structure))
    else ShowOtherPlayerInfo(Dialog, TPlayerStructure(Structure))
  else if Structure is TSign then ShowSignInfo(Dialog, TSign(Structure))
  else if Structure is TCave then ShowCaveInfo(Dialog, TCave(Structure))
  else if Structure is TTeleport then ShowTeleportInfo(Dialog, TTeleport(Structure))
  else if Structure is TExplorationSite then ShowExplorationInfo(Dialog, TExplorationSite(Structure))
  else if Structure is TWizardsTower then ShowTowerInfo(Dialog, TWizardsTower(Structure))
  else if Structure is TArena then ShowArenaInfo(Dialog, TArena(Structure))
  else ShowGenericInfo(Dialog, Structure);
  if not TBWindow.StructButton.Visible then AoWInfoWin.IWindow.InfoWin.Visible := True;
  TBWindow.StructButton.Visible := True;
end;

procedure UpdateStructureInfo(Dialog: TIWindow; Structure: TStructure);
begin
  if Dialog.InfoWin.Visible then
  begin
    if Structure = nil then
    begin
      Structure := General.FStructure;
      if Structure <> nil then if not Structure.Selected then Structure := nil;
    end;
    if Structure <> nil then if Structure.Selected then ShowStructureInfo(Dialog, Structure);
  end;
end;

procedure ShowItemSelection(Dialog: TIWindow; Items: TItemHS);
var
  I: Integer;
  Army: TArmyHS;
begin
  ResetStructureInfo(Dialog);
  with Dialog do
  begin
    Title.Text := TranslateRStr(ItemBagRStr);
    FItemBag := Items; ItemPnl.Visible := True; InfoWin.Visible := True;
    StructNameLbl.Text := '';
    StructLine.ImageTop := IntGfxMod.MiscArt[35]; StructLine.ImageMiddle := IntGfxMod.MiscArt[36];
    StructLine.ImageBottom := IntGfxMod.MiscArt[37];
    Army := TAoWMapField(Items.Owner).GetArmyHS;
    if (Army <> nil) and (Army.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
    begin
      ItemBagMemo.Visible := False;
      MainBtn.Visible := Army.FArmy.Hero($FF, AllHeroTypes) <> nil;
      MainBtn.Text := TranslateRStr(PickupRStr);
      ItembagLB.Visible := True; ItembagLB.Items.Clear; ItembagSB.Visible := True;
      for I := 0 to Items.FItems.Count - 1 do ItembagLB.Items.Add('');
      ItemsInBagLbl.Visible := True;
    end
    else
    begin
      ItemBagMemo.Visible := True; ItembagLB.Visible := False; ItemsInBagLbl.Visible := False;
      ItembagSB.Visible := False; MainBtn.Visible := False;
    end;
  end;
end;

procedure UpdateItemSelection(Dialog: TIWindow; Items: TItemHS);
begin
  if Dialog.InfoWin.Visible and (Items = Dialog.FItemBag) then ShowItemSelection(Dialog, Dialog.FItemBag);
end;

end.
