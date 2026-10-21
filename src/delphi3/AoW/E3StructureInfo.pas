unit E3StructureInfo;

{ Structure and item information routines reached by E3 map events in AoW.exe.
  TIWindow layout: size $1B4, published controls $44..$1AC, item bag $1B0. }
interface
uses AoWE, AoWInfoWin;
procedure ShowStructureInfo(Dialog: TIWindow; Structure: TStructure);
procedure UpdateStructureInfo(Dialog: TIWindow; Structure: TStructure);
procedure ShowItemSelection(Dialog: TIWindow; Items: TItemHS);
procedure UpdateItemSelection(Dialog: TIWindow; Items: TItemHS);

implementation
uses SysUtils, Classes, Engine, AoWWinMan, E3Globals, E2CampaignSupport, AoWComp,
  City, PrdPlace, Mine, PowerNode, Farm, Tower, Altar, Sign, Cave, Teleport, ExploreS, WizardsTower, Arena;

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
      if Structure.FProduction.FQueue.GetItem(0).FProductionID = 1 then
      begin
        UnitObject := Structure.FProduction.CreateUnitProduction(Structure.FProduction.FQueue.GetItem(0).FParameter);
        ActiveCityActionMemo.Items.Clear;
        ActiveCityActionMemo.Items.Add(TranslateRStr(ProducingRStr));
        ActiveCityActionMemo.Items.Add(UnitObject.GetName);
        UnitObject.Release;
      end
      else if Structure.FProduction.FQueue.GetItem(0).FProductionID = 2 then
      begin
        UnitObject := Structure.FProduction.CreateUnitProduction(Structure.FProduction.FQueue.GetItem(0).FParameter);
        ActiveCityActionMemo.Items.Add(TranslateRStr(InstallingRStr));
        ActiveCityActionMemo.Items.Add(UnitObject.GetName);
        UnitObject.Release;
      end
      else ActiveCityActionMemo.Items.Text := Structure.FProduction.FQueue.GetItem(0).GetNameProgressive;
      if Structure.FProduction.FStatus = pcsProducing then
        if Structure.FProduction.FSettings.FTurnsLeft = -1 then
          ActiveCityActionMemo.Items.Add(LowerCase(TranslateRStr(UnlimitedRStr)))
        else ActiveCityActionMemo.Items.Add(FmtTurnsLeftStr(Structure.FProduction.FSettings.FTurnsLeft))
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
      if Structure.GetBaseIncome = 0 then
      begin IncomeLbl.Visible := False; IncomeTypeIcon.Visible := False; IncomeValueLbl.Visible := False; end
      else begin IncomeTypeIcon.CurrentImage := 31; IncomeValueLbl.Text := IntToStr(Structure.GetIncome); end;
    ProductionPlacePnl.Visible := True;
    StructNameLbl.Text := Structure.GetName;
    if Structure.FProductionControl.FQueue.GetCount = 0 then
      if Structure.GetMagicSphere = msNone then
      begin
        ActiveActionMemo.Items.Add('');
        if Structure.GetBaseIncome = 0 then ActiveActionMemo.Items.Add(TranslateRStr(NoneRStr))
        else ActiveActionMemo.Items.Add(TranslateRStr(ProducingMerchandiseRStr));
      end
      else ActiveActionMemo.Items.Add(TranslateRStr(GeneratingExtraPowerRStr))
    else
    begin
      if Structure.FProductionControl.FQueue.GetItem(0).FProductionID = 1 then
      begin
        UnitObject := Structure.FProductionControl.CreateUnitProduction(Structure.FProductionControl.FQueue.GetItem(0).FParameter);
        ActiveActionMemo.Items.Clear; ActiveActionMemo.Items.Add(TranslateRStr(ProducingRStr));
        ActiveActionMemo.Items.Add(UnitObject.GetName); UnitObject.Release;
      end
      else if Structure.FProductionControl.FQueue.GetItem(0).FProductionID = 2 then
      begin
        UnitObject := Structure.FProductionControl.CreateUnitProduction(Structure.FProductionControl.FQueue.GetItem(0).FParameter);
        ActiveActionMemo.Items.Add(TranslateRStr(InstallingRStr));
        ActiveActionMemo.Items.Add(UnitObject.GetName); UnitObject.Release;
      end
      else ActiveActionMemo.Items.Text := Structure.FProductionControl.FQueue.GetItem(0).GetNameProgressive;
      if Structure.FProductionControl.FStatus = pcsProducing then
        if Structure.FProductionControl.FSettings.FTurnsLeft = -1 then
          ActiveCityActionMemo.Items.Add(LowerCase(TranslateRStr(UnlimitedRStr))) { Original writes the city memo in this branch. }
        else ActiveActionMemo.Items.Add(FmtTurnsLeftStr(Structure.FProductionControl.FSettings.FTurnsLeft))
      else if Structure.FProductionControl.FStatus = pcsWaiting then
      begin
        Structure.FProductionControl.CanExecuteProduction(Structure.FProductionControl.FQueue.GetItem(0), Reason);
        CurrentActivityWarningLbl.Text := Reason; CurrentActivityWarningLbl.Visible := True;
      end;
    end;
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
  Name: string;
begin
  ResetStructureInfo(Dialog); SetStructureHeader(Dialog, Structure);
  with Dialog do
  begin
    SingleButPnl.Visible := True;
    if Structure is TCity then Name := AoWE.Format(TranslateRStr(CityOfXRStr), [Structure.GetName])
    else Name := Structure.GetName;
    SBmemo.Items.Text := AoWE.Format(TranslateRStr(TheXliesInRuinsRStr), [Name]);
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
  if not TBWindow.StructButton.Visible then E3Globals.IWindow.InfoWin.Visible := True;
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
