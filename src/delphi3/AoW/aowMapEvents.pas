unit aowMapEvents;

{ Strategic map events and event-log dispatch recovered from AoW.exe.
  TMapEvents has instance size $48; its map control is at $44. }

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, MapCtrl, AoWE, EventLog, City, WizardsTower, Arena, FlagEvents, Dungeon, ItemExpS,
  AoWArmyEventDlg, AoWCityRebelDlg, AoWMsgReceiveDlg, AoWTutorialWin, AoWArmyInfoDlg, AoWWizardsTowerDlg, AoWArenaDlg, FastCombatWin, AoWPartyJoin, AoWHeroJoinDlg, AoWHeroInfoDlg, AoWHeroUpgradeDlg, AoWMessageDlg, AoWFileDialog, AoWPasswordDlg, AoWMagic, AoWRelations, AoWCastUnitSpellDlg, AoWTargetSelection, AoWCityJoinDlg, AoWItemsFoundDlg;

type
  TMapEvents = class;


  { TMapEvents (instance size $48, VMT 0044E554); $44 map control. }
  TMapEvents = class(TDataModule)
  public
    published
    TheMap: TAoWMapControl; { +0044 }
    public
    procedure TheMapActivateAbility(Request: TActivateAbilityInfo);
    procedure TheMapArmyChanged(Army: TArmy);
    procedure TheMapArmyDeselected;
    procedure TheMapArmyDestroyed(Army: TArmy);
    procedure TheMapArmySelected(Army: TArmy);
    procedure TheMapDayChanged(Day: Integer);
    procedure TheMapDeactivateHSM;  { draft }
    procedure TheMapEndTurn(Player: Shortint; Cancelled: Boolean);
    procedure TheMapExecuteEventLog(Event: TEventLog; Mode: Boolean; Done: TExecuteDoneEvent);
    procedure TheMapGameOver;  { draft }
    procedure TheMapGemsChanged(Player: Shortint);
    procedure TheMapGlobalMagicChanged;  { draft }
    procedure TheMapIncomeChanged(Player: Shortint);
    procedure TheMapMapChanged(var Info: TMapChangedInfo);
    procedure TheMapScannerIconsChanged(var Info: TMapChangedInfo);
    procedure TheMapPlayerMagicChanged(Player: Shortint); { $44FA8D }
    procedure TheMapSeatedPlayerChanged(Player: Shortint);  { draft }
    procedure TheMapShowMessage(var Info: TShowMessageInfo);
    procedure TheMapStructureChanged(Structure: TStructure);
    procedure TheMapStructureDeselected;  { draft }
    procedure TheMapStructureDestroyed(Structure: TStructure);
    procedure TheMapStructureSelected(Structure: TStructure);
    procedure TheMapItemsDeselected;  { draft }
    procedure TheMapItemsSelected(Items: TItemHS);
    procedure TheMapTargetSelectionChange(Control: TTargetSelectionControl; Change: TTargetSelectionChange);
    procedure TheMapUnitChanged(U: TAbstractUnit);
    procedure TheMapCastSpell(Caster: TSpellCaster);
    procedure TheMapHSChanged(HS: THexagonSprite);
    procedure TheMapRelationsChanged;  { draft }
    procedure TheMapDiplomaticChange;  { draft }
    procedure TheMapStructureDblClick(Structure: TStructure);
  end;


procedure ShowItemsFound(Dialog: TItemsFoundDlg; Event: TItemExplorationSiteEventLog; Done: TExecuteDoneEvent);
procedure ShowCityNegotiation(Dialog: TCityJoinDlg; Event: TNegotiateRequestEventLog; Done: TExecuteDoneEvent);
procedure ShowTargetSelection(Dialog: TTargetSelectionDlg; Control: TTargetSelectionControl; Change: TTargetSelectionChange);
procedure ShowUnitSpellCaster(Dialog: TCastUnitSpellDlg; Caster: TUnitSpellCaster);
procedure RefreshRelations(Dialog: TRelWindow);

procedure ShowRebellion(Dialog: TCityRebelDlg; Event: TCityRebellionEventLog; Done: TExecuteDoneEvent);
procedure ShowReceivedMessage(Dialog: TMsgReceiveDlg; Event: TEventLog; Done: TExecuteDoneEvent);
procedure ShowTutorialEvent(Dialog: TTutorialWindow; Event: TTutorialMessageEventLog; Unused: Boolean; Done: TExecuteDoneEvent);
procedure ShowFlagMessage(Dialog: TTutorialWindow; Event: TFlagMessageEventLog; Unused: Boolean; Done: TExecuteDoneEvent);
procedure ShowArmyInfo(Dialog: TArmyInfoDlg; Event: TArmyInfoEventLog; Done: TExecuteDoneEvent);
procedure ShowTower(Dialog: TWizardsTowerDlg; Event: TEnterWizardsTowerEventLog; Done: TExecuteDoneEvent);

procedure ResetPartyJoin(Dialog: TPartyJoinDlg);
procedure UpdatePartyJoin(Dialog: TPartyJoinDlg);
procedure ResetHeroJoin(Dialog: THeroJoinDlg);
procedure UpdateHeroJoin(Dialog: THeroJoinDlg);
procedure ShowPartyJoin(Dialog: TPartyJoinDlg; Event: TNegotiateRequestEventLog; Done: TExecuteDoneEvent);
procedure ShowPrisonersJoin(Dialog: TPartyJoinDlg; Event: TPrisonersJoinEventLog; Done: TExecuteDoneEvent);
procedure ShowHeroJoin(Dialog: THeroJoinDlg; Event: THeroJoinEventLog; Done: TExecuteDoneEvent);
procedure ShowHeroNegotiation(Dialog: THeroJoinDlg; Event: TNegotiateRequestEventLog; Done: TExecuteDoneEvent);
procedure ShowPrisonerHero(Dialog: THeroJoinDlg; Event: TPrisonersJoinEventLog; Done: TExecuteDoneEvent);
procedure ShowHeroUpgrade(Dialog: THeroUpgradeDlg; Event: THeroUpgradeEventLog; Completed: TExecuteDoneEvent);
procedure ShowMessageEvent(Dialog: TMessageDlg; Event: TMessageEventLog; Done: TExecuteDoneEvent);
procedure ShowSaveGameEvent(Dialog: TFileDlgWindow; Event: TSaveGameEventLog; Done: TExecuteDoneEvent);
procedure ShowPasswordEvent(Dialog: TPasswordDlg; Event: TPasswordEventLog; Done: TExecuteDoneEvent);
procedure ShowMagicWindow(Window: TMagicWin);
procedure ShowMagicEvent(Window: TMagicWin; Event: TPlayerMagicEventLog; Done: TExecuteDoneEvent);

var
  MapEvents: TMapEvents;

implementation

uses AoWUnit, AoWRealm, AoWInfoWin, E3Globals, AoWWinMan, AoWUnitBanner, aowSetupEvents, AoWExeForms, E1Globals, PrdPlace, AoWCityScreen, AoWProdScreen, E2CampaignSupport, GlobalSpells, UnitSpells, E3EventDialogs, E3StructureInfo, AoWNewTurnDialog, AoWSendEmailGameDlg, AoWSMTPDlg, TCFCDlg, AoWPInfoWin, aowHelpWin, AoWUnitWindow;

procedure TMapEvents.TheMapActivateAbility(Request: TActivateAbilityInfo);
begin
  if Request.FAbilityID = 52 then SpellBook.ShowCasting(Request)
  else if Request.FAbilityID = 125 then ConstructDlg.Execute(Request)
  else if Request is TUnitSelectorAAI then UnitSelectionDlg.Execute(TUnitSelectorAAI(Request));
end;

procedure TMapEvents.TheMapArmyChanged(Army: TArmy);
begin
  if Army <> nil then
  begin
    if Army = General.FUnitList then
    begin
      TheMapArmySelected(Army);
      if UnitWindow.UnitWin.Visible then UnitWindow.ShowUnit;
      if UnitBanner.BannerPopup.Visible then UnitBanner.BannerPopupShow(Self);
    end;
    if (AoWHSMap.FSeatedPlayer = Army.FPlayer) and AoWRealm.RealmWin.Dlg.Visible and
      (AoWRealm.RealmWin.HeaderTab.Selected = 3) then AoWRealm.RealmWin.UpdateOverview;
  end
  else
    if AoWRealm.RealmWin.Dlg.Visible and (AoWRealm.RealmWin.HeaderTab.Selected = 3) then AoWRealm.RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapArmyDeselected;
begin
  General.FAbilities.Clear;
  General.FUnitList := nil;
  ControlWin.MovesLbl.Text := '';
  ControlWin.MoveIcon.Visible := False;
  ControlWin.Emp1Fr.Visible := True;
  ControlWin.Emp1Chk.Visible := True;
  ControlWin.Emp2Fr.Visible := True;
  ControlWin.Emp2Chk.Visible := True;
  ControlWin.Emp3Fr.Visible := True;
  ControlWin.Emp3Chk.Visible := True;
  ControlWin.Emp4Fr.Visible := True;
  ControlWin.Emp4Chk.Visible := True;
  ControlWin.Emp5Fr.Visible := True;
  ControlWin.Emp5Chk.Visible := True;
  ControlWin.Emp6Fr.Visible := True;
  ControlWin.Emp6Chk.Visible := True;
  ControlWin.Emp7Fr.Visible := True;
  ControlWin.Emp7Chk.Visible := True;
  ControlWin.Emp8Fr.Visible := True;
  ControlWin.Emp8Chk.Visible := True;
  ControlWin.ControlWindow.Visible := False;
  TBWindow.ConButton.Visible := False;
  if UnitWindow.UnitWin.Visible then UnitWindow.UnitWin.Visible := False;
end;

procedure TMapEvents.TheMapArmyDestroyed(Army: TArmy);
begin
  if (Army <> nil) and (Army = General.FUnitList) then TheMapArmyDeselected;
  if AoWRealm.RealmWin.Dlg.Visible and (AoWRealm.RealmWin.HeaderTab.Selected = 3) then AoWRealm.RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapArmySelected(Army: TArmy);
var
  I, Count: Integer;
begin
  Count := 0;
  for I := 0 to 7 do General.FSelectedUnits[I] := -1;
  for I := 0 to Army.GetCount - 1 do
    if not Army.GetUnitConcealedForPlayer(I, AoWHSMap.FSeatedPlayer) then
    begin
      General.FSelectedUnits[Count] := I;
      Inc(Count);
    end;
  General.FUnitList := Army;
  ControlWin.UpdateArmy;
  if AoWHSMap.FSeatedPlayer = Army.FPlayer then AoWHSMap.FTutorialControl.ShowMessage(63, True, True);
end;

procedure TMapEvents.TheMapDayChanged(Day: Integer);
begin
  if msActivated in AoWHSMap.Status then TBWindow.TurnButton.FLastPlayer := -1;
  PInfoW.Turn.Text := AoWE.Format(TranslateRStr(DayXRStr), [Day]);
  aowMapEvents.MapEvents.TheMapGemsChanged(AoWHSMap.FSeatedPlayer);
  aowMapEvents.MapEvents.TheMapIncomeChanged(AoWHSMap.FSeatedPlayer);
  if AoWRealm.RealmWin.Dlg.Visible then AoWRealm.RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapDeactivateHSM;
begin
  try
    General.SaveLayout; General.HideWindows;
    MWindow.MapViewer.HSMap := nil;
    SetupEvents.DPlay.DisConnect;
    if SetupEvents.FLobbyGame then AoWUnit.MainForm.Close;
  except
  end;
end;

procedure TMapEvents.TheMapEndTurn(Player: Shortint; Cancelled: Boolean);
begin
  if AoWHSMap.FSeatedPlayer = Player then
    if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGameOverStatus = goNone then
      if not Cancelled then General.HideTransientWindows
      else
        with TBWindow.TurnButton do
        begin FDrawn := False; FButtonChecked := False; end;
  TBWindow.PInd.FDrawn := False;
end;

procedure TMapEvents.TheMapExecuteEventLog(Event: TEventLog; Mode: Boolean; Done: TExecuteDoneEvent);
var
  ArmyHS: TArmyHS;
  UnitObject: TAbstractUnit;
begin
  if not Mode then General.HideTransientWindows;
  if Event is TCombatEventLog then
    ShowCombatEvent(FastCombatWindow, TCombatEventLog(Event), Done)
  else if Event is TArmyEventLog then
    ShowArmyEvent(ArmyEventDlg, TArmyEventLog(Event), Done)
  else if Event is TCityRebellionEventLog then
    ShowRebellion(CityRebelDlg, TCityRebellionEventLog(Event), Done)
  else if Event is TDiplomaticActionEventLog then
    ShowDiplomaticEvent(RelWindow, TDiplomaticActionEventLog(Event), Done)
  else if Event is TNegotiateRequestEventLog then
  begin
    with TNegotiateRequestEventLog(Event) do
      if FObject = noCity then ShowCityNegotiation(CityJoinDlg, TNegotiateRequestEventLog(Event), Done)
      else if FObject = noArmy then
      begin
        ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(FX, FY, FL).FindOwnedChild($20217));
        if ArmyHS <> nil then
          if ArmyHS.FArmy.Hero(ArmyHS.FArmy.GetJoinSelection(FPlayer), AllHeroTypes) = nil then
            ShowPartyJoin(PartyJoinDlg, TNegotiateRequestEventLog(Event), Done)
          else ShowHeroNegotiation(HeroJoinDlg, TNegotiateRequestEventLog(Event), Done);
      end;
  end
  else if Event is TGameOverEventLog then
    if AoWHSMap.FSeatedPlayer = Event.FPlayer then
      PyreScreen.ShowGameOver(TGameOverEventLog(Event), Done)
    else ShowReceivedMessage(MsgReceiveDlg, Event, Done)
  else if Event is TNewTurnEventLog then
    NewTurnDlg.ShowNewTurn(TNewTurnEventLog(Event), Done)
  else if Event is TCombatTypeRequestEventLog then
    ShowCombatType(TCFCDialog, TCombatTypeRequestEventLog(Event), Done)
  else if Event is TShowBookEventLog then
    ShowInformationBook(WorldMap, TShowBookEventLog(Event), Done)
  else if Event is TPlayerMagicEventLog then
  begin
    with TPlayerMagicEventLog(Event) do
      case FMode of
        pmemSpellResearched: SpellBook.ShowResearchedEvent(TPlayerMagicEventLog(Event), Done);
        pmemOutOfMana: ShowMagicEvent(MagicWin, TPlayerMagicEventLog(Event), Done);
        pmemStartResearch: SpellBook.ShowResearchEvent(TPlayerMagicEventLog(Event), Done);
      end;
  end
  else if Event is THeroUpgradeEventLog then
    ShowHeroUpgrade(HeroUpgradeDlg, THeroUpgradeEventLog(Event), Done)
  else if Event is THeroJoinEventLog then
    ShowHeroJoin(HeroJoinDlg, THeroJoinEventLog(Event), Done)
  else if Event is TArmyInfoEventLog then
    with TArmyInfoEventLog(Event) do
      if FArmyView.Hero(FSelection, AllHeroTypes) = nil then
        ShowArmyInfo(ArmyInfoDlg, TArmyInfoEventLog(Event), Done)
      else ShowHeroInfo(HeroInfoDlg, TArmyInfoEventLog(Event), Done)
  else if Event is TPrisonersJoinEventLog then
  begin
    UnitObject := AoWHSMap.FUnitControl.FindUnit(TPrisonersJoinEventLog(Event).FFirstUnitID);
    if (UnitObject <> nil) and (UnitObject is THero) then
      ShowPrisonerHero(HeroJoinDlg, TPrisonersJoinEventLog(Event), Done)
    else ShowPrisonersJoin(PartyJoinDlg, TPrisonersJoinEventLog(Event), Done);
  end
  else if Event is TEnterWizardsTowerEventLog then
    ShowTower(WizardsTowerDlg, TEnterWizardsTowerEventLog(Event), Done)
  else if Event is TEnterArenaEventLog then
    ShowArena(ArenaDlg, TEnterArenaEventLog(Event), Done)
  else if Event is TMessageEventLog then
    ShowMessageEvent(MessageDlg, TMessageEventLog(Event), Done)
  else if Event is TTutorialMessageEventLog then
    ShowTutorialEvent(TutorialWindow, TTutorialMessageEventLog(Event), Mode, Done)
  else if Event is TFlagMessageEventLog then
    ShowFlagMessage(TutorialWindow, TFlagMessageEventLog(Event), Mode, Done)
  else if Event is THelpMessageEventLog then
    HelpWindow.ShowHelpEvent(THelpMessageEventLog(Event), Mode, Done)
  else if Event is TSaveGameEventLog then
    ShowSaveGameEvent(FileDlgWindow, TSaveGameEventLog(Event), Done)
  else if Event is TSendEmailGameEventLog then
    SendEmailGameDlg.ShowSendDialog(TSendEmailGameEventLog(Event), Done)
  else if Event is TSMTPEventLog then
    ShowSMTPEvent(SMTPDlg, TSMTPEventLog(Event), Done)
  else if Event is TPasswordEventLog then
    ShowPasswordEvent(PasswordDlg, TPasswordEventLog(Event), Done)
  else if Event is TItemExplorationSiteEventLog then
    ShowItemsFound(ItemsFoundDlg, TItemExplorationSiteEventLog(Event), Done)
  else if Event is TCityProductionEventLog then CityScreen.ProductionEvent(TCityProductionEventLog(Event))
  else if Event is TProductionPlaceEventLog then ProductionScreen.ProductionEvent(TProductionPlaceEventLog(Event))
  else if Event is TUserEventLog then Done(Event);
end;

procedure TMapEvents.TheMapGameOver;
begin end;

procedure TMapEvents.TheMapGemsChanged(Player: Shortint);
var
  Update: Boolean;
begin
  Update := False;
  if AoWHSMap.FSeatedPlayer = Player then Update := True
  else if AoWHSMap.FCombatMap <> nil then
    if AoWHSMap.FCombatMap.FSeatedPlayer = Player then Update := True;
  if Update then
  begin
    if Player = -1 then Update := False
    else if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then Update := False;
    if not Update then
    begin
      { The original clears both income signs when the gold display is cleared. }
      TBWindow.WGTLbl.Text := '';
      TBWindow.WGSign.Text := '';
      TBWindow.WMTSign.Text := '';
    end
    else
    begin
      TBWindow.WGTLbl.Text := IntToStr(AoWHSMap.FPlayers.GetPlayers(Player).FGems);
      if AoWRealm.RealmWin.Dlg.Visible and (AoWRealm.RealmWin.HeaderTab.Selected = 0) then AoWRealm.RealmWin.UpdateOverview;
    end;
    TBWindow.TGTLbl.Text := TBWindow.WGTLbl.Text;
    TBWindow.TGSign.Text := TBWindow.WGSign.Text;
    TBWindow.TMTSign.Text := TBWindow.WMTSign.Text;
  end;
end;

procedure TMapEvents.TheMapGlobalMagicChanged;
begin GlobalMagicChanged(MagicWin); end;

procedure TMapEvents.TheMapIncomeChanged(Player: Shortint);
var
  Update: Boolean;
  NetIncome: Integer;
begin
  Update := False;
  if AoWHSMap.FSeatedPlayer = Player then Update := True
  else if AoWHSMap.FCombatMap <> nil then
    if AoWHSMap.FCombatMap.FSeatedPlayer = Player then Update := True;
  if Update then
  begin
    if Player = -1 then Update := False
    else if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then Update := False;
    if not Update then TBWindow.WGILbl.Text := ''
    else
    begin
      NetIncome := AoWHSMap.FPlayers.GetPlayers(Player).FIncome - AoWHSMap.FPlayers.GetPlayers(Player).GetUpkeep;
      if NetIncome >= 0 then
      begin
        TBWindow.WGSign.Text := '+';
        TBWindow.WGSign.TextColor := $77FF77;
        TBWindow.WGILbl.TextColor := $77FF77;
      end
      else
      begin
        TBWindow.WGSign.Text := '-';
        TBWindow.WGSign.TextColor := $77;
        TBWindow.WGILbl.TextColor := $77;
      end;
      TBWindow.WGILbl.Text := IntToStr(Abs(NetIncome));
      if AoWRealm.RealmWin.Dlg.Visible and (AoWRealm.RealmWin.HeaderTab.Selected = 0) then AoWRealm.RealmWin.UpdateOverview;
    end;
    TBWindow.TGILbl.Text := TBWindow.WGILbl.Text;
    TBWindow.TGSign.Text := TBWindow.WGSign.Text;
    TBWindow.TGSign.TextColor := TBWindow.WGSign.TextColor;
    TBWindow.TGILbl.TextColor := TBWindow.WGILbl.TextColor;
  end;
end;

procedure TMapEvents.TheMapMapChanged(var Info: TMapChangedInfo);
begin
  if Info.MapLevel = SWindow.Scanner.FLevel then
    SWindow.Scanner.DrawMap(Info.Bounds.Left - 6, Info.Bounds.Top - 6,
      Info.Bounds.Right - Info.Bounds.Left,
      Info.Bounds.Bottom - Info.Bounds.Top);
end;

procedure TMapEvents.TheMapScannerIconsChanged(var Info: TMapChangedInfo);
begin
  if Info.MapLevel = SWindow.Scanner.FLevel then SWindow.Scanner.SetObDrawn(False);
end;

procedure TMapEvents.TheMapPlayerMagicChanged(Player: Shortint);
var Update: Boolean; NetIncome: Integer;
begin
  MagicPlayerChanged(MagicWin, Player);
  SpellBook.PlayerChanged(Player);
  Update := False;
  if AoWHSMap.FSeatedPlayer = Player then Update := True
  else if AoWHSMap.FCombatMap <> nil then
    if AoWHSMap.FCombatMap.FSeatedPlayer = Player then Update := True;
  if Update then
  begin
    if Player = -1 then Update := False
    else if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then Update := False;
    if not Update then
    begin TBWindow.WMTLbl.Text := ''; TBWindow.WMILbl.Text := ''; end
    else
    begin
      TBWindow.WMTLbl.Text := IntToStr(AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FMana);
      NetIncome := AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.GetManaIncome -
        AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.GetManaUpkeep;
      if NetIncome >= 0 then
      begin TBWindow.WMTSign.Text := '+'; TBWindow.WMTSign.TextColor := $77FF77; TBWindow.WMILbl.TextColor := $77FF77; end
      else
      begin TBWindow.WMTSign.Text := '-'; TBWindow.WMTSign.TextColor := $77; TBWindow.WMILbl.TextColor := $77; end;
      TBWindow.WMILbl.Text := IntToStr(Abs(NetIncome));
    end;
    TBWindow.TMTLbl.Text := TBWindow.WMTLbl.Text;
    TBWindow.TMILbl.Text := TBWindow.WMILbl.Text;
    TBWindow.TMTSign.Text := TBWindow.WMTSign.Text;
    TBWindow.TMTSign.TextColor := TBWindow.WMTSign.TextColor;
    TBWindow.TMILbl.TextColor := TBWindow.WMILbl.TextColor;
  end;
end;

procedure TMapEvents.TheMapSeatedPlayerChanged(Player: Shortint);
begin
  if Player = -1 then
  begin
    General.HideWindows;
    General.Manager.OverlayPriority := 0;
    TBWindow.CurP.Visible := False;
    TBWindow.FWorldClockDelay := 0;
    TBWindow.TurnButton.FCurPlayer := 12;
    TBWindow.TurnButton.FLastPlayer := TBWindow.TurnButton.FCurPlayer;
    TBWindow.TurnButton.FAnimationFrame := TBWindow.TurnButton.FCurPlayer * 7;
  end
  else
  begin
    General.ShowWindows;
    with TBWindow.TurnButton do
      if (msActivated in AoWHSMap.Status) and not FAnimating then
      begin
        if Player > -1 then FCurPlayer := AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace else FCurPlayer := -2;
        if FCurPlayer = -1 then FCurPlayer := 12;
        FLastPlayer := -1;
      end;
    TBWindow.CurP.Visible := AoWHSMap.FPlayMode = pmTurn;
    PInfoW.UpdatePlayer;
    if AoWRealm.RealmWin.Dlg.Visible then AoWRealm.RealmWin.UpdateOverview;
  end;
  TheMapGemsChanged(Player); TheMapIncomeChanged(Player); TheMapPlayerMagicChanged(Player);
  TBWindow.PInd.FDrawn := False;
  PInfoW.UpdateEvents;
end;

procedure TMapEvents.TheMapShowMessage(var Info: TShowMessageInfo);
begin
  TBWindow.TBMessEdit.TextColor := Info.Color;
  TBWindow.TBMessEdit.Text := Info.Text;
end;

procedure TMapEvents.TheMapStructureChanged(Structure: TStructure);
begin
  UpdateStructureInfo(IWindow, Structure);
  if Structure <> nil then
  begin
    CityScreen.CityChanged(Structure);
    ProductionScreen.PlaceChanged(Structure);
  end;
  if AoWRealm.RealmWin.Dlg.Visible and (AoWRealm.RealmWin.HeaderTab.Selected < 3) then AoWRealm.RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapStructureDeselected;
begin
  if General.FSign <> nil then
    General.FSign.ChangeText(AoWHSMap.FSeatedPlayer, IWindow.SignText.Items);
  General.FStructure := nil; General.FCity := nil; General.FProductionPlace := nil;
  General.FProductionControl := nil; General.FSign := nil;
  IWindow.StructNameLbl.Text := ''; IWindow.StructLine.Visible := False;
  IWindow.InfoWin.Visible := False; TBWindow.StructButton.Visible := False;
end;

procedure TMapEvents.TheMapStructureDestroyed(Structure: TStructure);
begin
  if (Structure <> nil) and (Structure = General.FStructure) then TheMapStructureDeselected;
  if AoWRealm.RealmWin.Dlg.Visible then if (AoWRealm.RealmWin.HeaderTab.Selected = 2) or (AoWRealm.RealmWin.HeaderTab.Selected = 1) then AoWRealm.RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapStructureSelected(Structure: TStructure);
begin
  General.FPreviousStructure := General.FStructure;
  General.FStructure := Structure;
  General.FProductionControl := nil;
  ShowStructureInfo(IWindow, Structure);
end;

procedure TMapEvents.TheMapItemsDeselected;
begin HideItemSelection(IWindow); end;

procedure TMapEvents.TheMapItemsSelected(Items: TItemHS);
begin ShowItemSelection(IWindow, Items); end;

procedure TMapEvents.TheMapTargetSelectionChange(Control: TTargetSelectionControl; Change: TTargetSelectionChange);
begin ShowTargetSelection(TargetSelectionDlg, Control, Change); end;

procedure TMapEvents.TheMapUnitChanged(U: TAbstractUnit);
begin
  if U = General.FSelectedUnit then
  begin
    if UnitWindow.UnitWin.Visible then UnitWindow.ShowUnit;
    if UnitBanner.BannerPopup.Visible then UnitBanner.BannerPopupShow(Self);
  end;
  SpellBook.UnitChanged(U);
end;

procedure TMapEvents.TheMapCastSpell(Caster: TSpellCaster);
begin
  if Caster is TUnitSpellCaster then ShowUnitSpellCaster(CastUnitSpellDlg, TUnitSpellCaster(Caster))
  else if Caster is TDisjunctionSpellCaster then DisjunctionDlg.Execute(TDisjunctionSpellCaster(Caster))
  else if Caster is TCosmeticSurgerySpellCaster then DeformFaceDlg.Execute(TCosmeticSurgerySpellCaster(Caster));
end;

procedure TMapEvents.TheMapHSChanged(HS: THexagonSprite);
begin
  if HS is TItemHS then UpdateItemSelection(IWindow, TItemHS(HS));
end;

procedure TMapEvents.TheMapRelationsChanged;
begin RefreshRelations(RelWindow); end;

procedure TMapEvents.TheMapDiplomaticChange;
begin RefreshRelations(RelWindow); end;

procedure TMapEvents.TheMapStructureDblClick(Structure: TStructure);
begin
  if Structure = General.FStructure then
    if (General.FStructure is TCity) and (TCity(General.FStructure).FPlayer = AoWHSMap.FSeatedPlayer) then
      CityScreen.ShowCity(TCity(General.FStructure))
    else if (General.FStructure is TProductionPlace) and TProductionPlace(General.FStructure).CanDblClick and
      (TPlayerStructure(General.FStructure).FPlayer = AoWHSMap.FSeatedPlayer) then
      ProductionScreen.ShowPlace(TProductionPlace(General.FStructure))
    else if General.FStructure is TWizardsTower then TWizardsTower(General.FStructure).Enter
    else if General.FStructure is TArena then TArena(General.FStructure).Enter;
end;


procedure ShowRebellion(Dialog: TCityRebelDlg; Event: TCityRebellionEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    FOnClose := Done;
    FEvent := Event;
    FEvent.AddRef;
    CityNameLabel.Text := FEvent.FCityName;
    RebelWin.Visible := True;
  end;
end;

procedure ShowReceivedMessage(Dialog: TMsgReceiveDlg; Event: TEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    FEvent := Event;
    FEvent.AddRef;
    FDone := Done;
    HeaderMemo.Items.Text := Event.GetText;
    MessageMemo.Items.Text := TGameOverEventLog(Event).FMessage.Text;
    LShield.CurrentImage := AoWHSMap.FPlayers.GetPlayers(Event.FPlayer).FPlayerRace + 13;
    RShield.CurrentImage := LShield.CurrentImage;
    MsgReceiveWin.Visible := True;
  end;
end;

procedure ShowTutorialEvent(Dialog: TTutorialWindow; Event: TTutorialMessageEventLog; Unused: Boolean; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    AbVSB.Position := 0;
    FinishDialog;
    FEvent := Event;
    FEvent.AddRef;
    FDone := Done;
    HeaderMemo.Items.Clear;
    if Event.FMessage.Count > 0 then HeaderMemo.Items.Add(Event.FMessage[0]);
    MessageMemo.Items.Clear;
    MessageMemo.Items.AddStrings(Event.FMessage);
    if MessageMemo.Items.Count > 0 then MessageMemo.Items.Delete(0);
    if (MessageMemo.Items.Count > 0) and (MessageMemo.Items[0] = '') then MessageMemo.Items.Delete(0);
    Dlg.Visible := True;
  end;
end;

procedure ShowFlagMessage(Dialog: TTutorialWindow; Event: TFlagMessageEventLog; Unused: Boolean; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    AbVSB.Position := 0;
    FinishDialog;
    FEvent := Event;
    FEvent.AddRef;
    FDone := Done;
    HeaderMemo.Items.Clear;
    HeaderMemo.Items.Add(Event.FHelpFileName);
    MessageMemo.Items.Clear;
    MessageMemo.Items.AddStrings(Event.FMessage);
    Dlg.Visible := True;
  end;
end;

procedure ShowArmyInfo(Dialog: TArmyInfoDlg; Event: TArmyInfoEventLog; Done: TExecuteDoneEvent);
var
  Log: TArmyInfoEventLog;
begin
  with Dialog do
  begin
    FOnClose := Done;
    FEvent := Event;
    FEvent.AddRef;
    Message.Items.Text := Event.FMessages.Text;
    Title.Text := Event.FTitle;
    HeaderLbl.Text := Event.FDescription;
    Dlg.Visible := True;
    FUnitInfoShown := False;
  end;
end;

procedure ShowTower(Dialog: TWizardsTowerDlg; Event: TEnterWizardsTowerEventLog; Done: TExecuteDoneEvent);
var
  Tower: TWizardsTower;
  Spell: TSpell;
begin
  with Dialog do
  begin
    FOnClose := Done;
    FEvent := Event;
    FEvent.AddRef;
    Tower := FEvent.FTower;
    if Tower.FSpellID <> 0 then
    begin
      PriceLbl.Text := AoWE.Format(TranslateRStr(ForXGoldRStr), [IntToStr(FEvent.FTower.BuyCost)]) + '.';
      Spell := AoWHSSet.FSpellControl.GetSpell(Tower.FSpellID);
      SpellName.Text := Spell.FSpellName;
      SpellClass.Text := TranslateRStr(TMagicSphereRStr[Spell.FMagicSphere]) + ', ' +
        TranslateRStr(LevelRStr) + ' ' + IntToStr(Spell.FSpellLevel);
      SpellCost.Text := TranslateRStr(CastingCostRStr) + ': ' + IntToStr(Spell.FBaseManaCost) + ' ' + TranslateRStr(ManaRStr);
      ResearchMemo.Items.Text := Spell.FSpellText.Text;
    end
    else
    begin
      PriceLbl.Text := '';
      SpellName.Text := TranslateRStr(NoneRStr);
      SpellClass.Text := '';
      SpellCost.Text := '';
      ResearchMemo.Items.Text := '';
    end;
    Dlg.Visible := True;
  end;
end;




procedure ResetPartyJoin(Dialog: TPartyJoinDlg);
begin
  with Dialog do
  begin
    LeftBtn.Visible := True; MiddleBtn.Visible := True; RightBtn.Visible := True;
    Title.Text := TranslateRStr(PartyJoinRStr);
  end;
end;

procedure UpdatePartyJoin(Dialog: TPartyJoinDlg);
begin
  with Dialog do
    if ValidateJoin then
    begin
      FUnits.Clear;
      FFaceUnit := AoWHSMap.FUnitControl.FindUnit(FJoinEvent.FFirstUnitID);
      FJoinEvent.ListJoinUnits(FUnits, FSelection);
      JoinMemo.Items.Text := FJoinEvent.FJoinMessage.Text;
    end;
end;

procedure ResetHeroJoin(Dialog: THeroJoinDlg);
begin
  with Dialog do
  begin
    LeftBtn.Visible := True; MiddleBtn.Visible := True; RightBtn.Visible := True;
  end;
end;

procedure UpdateHeroJoin(Dialog: THeroJoinDlg);
begin
  with Dialog do
    if ValidateJoin then
    begin
      FUnits.Clear;
      FFaceUnit := AoWHSMap.FUnitControl.FindUnit(FJoinEvent.FFirstUnitID);
      FJoinEvent.ListJoinUnits(FUnits, FSelection);
      HeroLevel.Text := AoWE.Format(TranslateRStr(LevelXRStr), [IntToStr(THero(FFaceUnit).GetLevel)]);
      HeroName.Text := THero(FFaceUnit).FHeroName;
      JoinMemo.Items.Text := FJoinEvent.FJoinMessage.Text;
    end;
end;

procedure ShowPartyJoin(Dialog: TPartyJoinDlg; Event: TNegotiateRequestEventLog; Done: TExecuteDoneEvent);
begin
  ResetPartyJoin(Dialog);
  with Dialog do
  begin
    Dlg.Visible := True;
    FJoinEvent := Event; FJoinEvent.AddRef;
    FDone := Done;
    LeftBtn.Text := TranslateRStr(AcceptRStr);
    MiddleBtn.Text := TranslateRStr(AttackRStr);
    RightBtn.Text := TranslateRStr(CancelRStr);
    UpdatePartyJoin(Dialog);
    AoWHSMap.FTutorialControl.ShowMessage(70, True, True);
  end;
end;

procedure ShowPrisonersJoin(Dialog: TPartyJoinDlg; Event: TPrisonersJoinEventLog; Done: TExecuteDoneEvent);
begin
  ResetPartyJoin(Dialog);
  with Dialog do
  begin
    Dlg.Visible := True;
    Title.Text := TranslateRStr(PrisonerLiberationRStr);
    FJoinEvent := Event; FJoinEvent.AddRef;
    FDone := Done;
    LeftBtn.Text := TranslateRStr(AcceptRStr);
    MiddleBtn.Visible := False;
    RightBtn.Text := TranslateRStr(RejectRStr);
    UpdatePartyJoin(Dialog);
  end;
end;

procedure ShowHeroJoin(Dialog: THeroJoinDlg; Event: THeroJoinEventLog; Done: TExecuteDoneEvent);
begin
  ResetHeroJoin(Dialog);
  with Dialog do
  begin
    FJoinEvent := Event; FJoinEvent.AddRef; FDone := Done;
    LeftBtn.Text := TranslateRStr(AcceptRStr);
    MiddleBtn.Visible := False;
    RightBtn.Text := TranslateRStr(CancelRStr);
    UpdateHeroJoin(Dialog);
    Dlg.Visible := True;
  end;
end;

procedure ShowHeroNegotiation(Dialog: THeroJoinDlg; Event: TNegotiateRequestEventLog; Done: TExecuteDoneEvent);
begin
  ResetHeroJoin(Dialog);
  with Dialog do
  begin
    FJoinEvent := Event; FJoinEvent.AddRef; FDone := Done;
    LeftBtn.Text := TranslateRStr(AcceptRStr);
    MiddleBtn.Text := TranslateRStr(AttackRStr);
    RightBtn.Text := TranslateRStr(CancelRStr);
    UpdateHeroJoin(Dialog);
    Dlg.Visible := True;
  end;
end;

procedure ShowPrisonerHero(Dialog: THeroJoinDlg; Event: TPrisonersJoinEventLog; Done: TExecuteDoneEvent);
begin
  ResetHeroJoin(Dialog);
  with Dialog do
  begin
    FJoinEvent := Event; FJoinEvent.AddRef; FDone := Done;
    LeftBtn.Text := TranslateRStr(AcceptRStr);
    MiddleBtn.Visible := False;
    RightBtn.Text := TranslateRStr(RejectRStr);
    UpdateHeroJoin(Dialog);
    Dlg.Visible := True;
  end;
end;


























procedure ShowHeroUpgrade(Dialog: THeroUpgradeDlg; Event: THeroUpgradeEventLog; Completed: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    FReferencedHero := Event; FReferencedHero.AddRef; FOnClose := Completed;
    if ValidateHero then
    begin
      FEditedHero := THero(FHero.Copy(AoWEngine));
      UpdateStatistics;
      RefreshAbilities;
      UnitName.Text := FHero.FHeroName;
      LevelLbl.Text := TranslateRStr(LevelRStr) + ' ' + IntToStr(FHero.GetLevel);
      if FReferencedHero.FNewLevel - FReferencedHero.FOldLevel > 1 then
        HeaderLbl.Text := AoWE.Format(TranslateRStr(XMadeYLevelsRStr),
          [FHero.FHeroName, FReferencedHero.FNewLevel - FReferencedHero.FOldLevel]) + '!'
      else
        HeaderLbl.Text := AoWE.Format(TranslateRStr(XMadeALevelRStr), [FHero.FHeroName]) + '!';
      Dlg.Visible := True;
    end;
  end;
end;

procedure ShowMessageEvent(Dialog: TMessageDlg; Event: TMessageEventLog; Done: TExecuteDoneEvent);
var
  Log: TMessageEventLog;
begin
  ResetMessageDialog(Dialog);
  with Dialog do
  begin
    FDone := Done; FEvent := Event; FEvent.AddRef;
    Log := FEvent;
    TitleLbl.Text := Log.FTitle;
    case Log.FLayout of
      melNormal:
      begin
      MessageMemo.Items.Text := Log.FMessage.Text;
      if Length(MessageMemo.Items.Text) < 80 then MessageMemo.Items.Insert(0, '');
      end;
      melHeader:
      begin
      MemoPnl.Visible := False; HeaderMemoPnl.Visible := True;
      HeaderLbl.Text := Log.FHeader;
      HeaderMemo.Items.Text := Log.FMessage.Text;
      end;
    end;
    case Log.FButtons of
      mebOK: OKPnl.Visible := True;
      mebOKCancel: OKCancelPnl.Visible := True;
      mebYesNo: YesNoPnl.Visible := True;
      mebYesNoCancel: YesNoCancelPnl.Visible := True;
    end;
    Dlg.Visible := True;
  end;
end;

procedure ShowSaveGameEvent(Dialog: TFileDlgWindow; Event: TSaveGameEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    FDone := Done; FSaveEvent := Event; FSaveEvent.AddRef;
    FMode := 1;
    FileDialog.Visible := True;
    if Event.FDirectory <> '' then SetCurrentDirectory(PChar(Event.FDirectory));
    SFileName.Text := Event.FDefaultName;
    Title.Text := Event.FTitle;
    FindFiles;
  end;
end;

procedure ShowPasswordEvent(Dialog: TPasswordDlg; Event: TPasswordEventLog; Done: TExecuteDoneEvent);
var
  Log: TPasswordEventLog;
begin
  with Dialog do
  begin
    Reset;
    FDone := Done; FPasswordEvent := Event; FPasswordEvent.AddRef;
    Log := FPasswordEvent;
    TitleLbl.Text := Log.FTitle;
    PasswordLbl.Text := Log.FPrompt;
    PasswordEdit.Text := Log.FPassword;
    PasswordEdit.FRedraw := True;
    Dlg.Visible := True;
  end;
end;

procedure ShowMagicWindow(Window: TMagicWin);
begin
  if not Window.Dlg.Visible then
  begin
    RefreshMagicWindow(Window);
    RefreshGlobalMagic(Window);
  end;
  Window.Dlg.Visible := True;
end;

procedure ShowMagicEvent(Window: TMagicWin; Event: TPlayerMagicEventLog; Done: TExecuteDoneEvent);
begin
  ShowMagicWindow(Window);
  if Assigned(Done) then Done(Event);
end;

procedure RefreshRelations(Dialog: TRelWindow);
begin
  with Dialog do
    if RelWin.Visible then
    begin
      FillPlayers;
      RelPnl.FAligned := False;
      RelWin.FDrawn := False;
      if FSelectedPlayer <> -1 then HighlightPlayer(FSelectedPlayer);
      if FInfoPlayer <> -1 then
        if RNewActionPnl.Visible then ShowPlayerActions(FInfoPlayer)
        else ShowPlayerInformation(FInfoPlayer)
      else
        if FSelectedRace <> -1 then HighlightRace(FSelectedRace);
      if FInfoRace <> -1 then ShowRaceInformation(FInfoRace);
    end;
end;

procedure ShowUnitSpellCaster(Dialog: TCastUnitSpellDlg; Caster: TUnitSpellCaster);
var
  Hero: THero;
  Spell: TSpell;
begin
  with Dialog do
  begin
    if FCaster <> nil then FCaster.Release;
    FCaster := Caster;
    FCaster.AddRef;
    Hero := THero(AoWHSMap.FUnitControl.FindUnit(FCaster.FCasterSourceID));
    if Hero <> nil then
    begin
      CasterNameLbl.Text := Hero.GetName;
      CastingPointsLbl.Text := TranslateRStr(CastingPointsRStr) + ': ' +
        IntToStr(Hero.GetCastingPoints) + '/' + IntToStr(Hero.GetCastingPointsMax);
    end;
    Spell := AoWHSSet.FSpellControl.GetSpell(FCaster.FCasterSpellID);
    SpellNameLbl.Text := Spell.FSpellName;
    { Original still uses Hero below if the source-unit lookup failed. }
    SpellManaLbl.Text := TranslateRStr(CastingCostRStr) + ': ' +
      IntToStr(Hero.CastingMana(Spell)) + ' ' + TranslateRStr(ManaRStr);
    SpellUpkeepLbl.Text := TranslateRStr(UpkeepRStr) + ': ' +
      IntToStr(Spell.FManaUpkeep) + ' ' + TranslateRStr(ManaRStr);
    CastingManaLbl.Text := TranslateRStr(ManaRStr) + ': ' +
      IntToStr(AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FMagicControl.FMana);
    U1.Checked := False; U2.Checked := False; U3.Checked := False; U4.Checked := False;
    U5.Checked := False; U6.Checked := False; U7.Checked := False; U8.Checked := False;
    SelectionInfoLbl.Text := '';
    Dlg.Visible := True;
  end;
end;

procedure ShowTargetSelection(Dialog: TTargetSelectionDlg; Control: TTargetSelectionControl; Change: TTargetSelectionChange);
begin
  with Dialog do
    if Change = tscActivated then
    begin
      HeaderLbl.Text := Control.FTitle;
      MainBtn.Text := Control.FCancelText;
      DefaultMemo.Items.Assign(Control.FText);
      Dlg.Visible := True;
      if not (tmValidateDistance in Control.FTargetMode) then
        TargetLbl.Text := LowerCase(TranslateRStr(UnlimitedRStr))
      else TargetLbl.Text := IntToStr(Control.FRange);
      BorderImage.ImageTop := Control.FSourceImage;
      BorderImage.ImageMiddle := Control.FValidTargetImage;
      BorderImage.ImageBottom := Control.FInvalidTargetImage;
      General.Manager.OverlayPriority := 49;
      with MWindow.MapWindow do
      begin
        FModal := True;
        Priority := 500;
      end;
      SWindow.ScannerWindow.Priority := Dlg.Priority;
    end
    else if Change = tscDeactivated then
    begin
      Dlg.Visible := False;
      MWindow.MapWindow.Priority := 0;
      MWindow.MapWindow.FModal := False;
      SWindow.ScannerWindow.Priority := 10;
      General.Manager.OverlayPriority := 0;
    end;
end;

procedure ShowCityNegotiation(Dialog: TCityJoinDlg; Event: TNegotiateRequestEventLog; Done: TExecuteDoneEvent);
var
  Log: TNegotiateRequestEventLog;
  Town: TCity;
begin
  with Dialog do
  begin
    FDone := Done;
    FEvent := Event;
    FEvent.AddRef;
    Log := FEvent;
    Memo.Items.Text := Log.FJoinMessage.Text;
    ApproachLbl.Text := Log.FText;
    Town := TCity(AoWHSMap.MapContainer.GetField(Log.FX, Log.FY, Log.FL).FindNoneTransparentHS(TCity));
    FRace := Town.FRace;
    CityPicLine.ImageTop := Town.GetTopCityActionImage(caNone);
    CityPicLine.ImageMiddle := Town.GetMiddleCityActionImage(caNone);
    CityPicLine.ImageBottom := Town.GetBottomCityActionImage(caNone);
    Dlg.Visible := True;
    AoWHSMap.FTutorialControl.ShowMessage(62, True, True);
  end;
end;

procedure ShowItemsFound(Dialog: TItemsFoundDlg; Event: TItemExplorationSiteEventLog; Done: TExecuteDoneEvent);
var
  Log: TItemExplorationSiteEventLog;
begin
  with Dialog do
  begin
    Reset;
    FOnDone := Done;
    FEvent := Event;
    FEvent.AddRef;
    Log := FEvent;
    TitleLbl.Text := Log.FTitle;
    MessageMemo.Items.Text := Log.FMessages.Text;
    LeftBtn.Visible := Log.FItemIDs.Count > 5;
    RightBtn.Visible := Log.FItemIDs.Count > 5;
    if GetHero = nil then OKPnl.Visible := True
    else PickupPnl.Visible := True;
    AoWHSMap.FTutorialControl.ShowMessage(54, True, True);
    Dlg.FDrawn := False;
    Dlg.Visible := True;
  end;
end;

end.
