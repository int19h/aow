unit aowMapEvents;

{ Draft declarations of aowMapEvents, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, MapCtrl, AoWE;

type
  TMapEvents = class;


  { TMapEvents (instance size $48, VMT 0044E554); $44 map control. }
  TMapEvents = class(TDataModule)
  public
    published
    TheMap: TAoWMapControl; { +0044 }
    public
    procedure TheMapActivateAbility(Request: TActivateAbilityInfo);
    procedure TheMapArmyChanged(A1: Integer);  { draft }
    procedure TheMapArmyDeselected;
    procedure TheMapArmyDestroyed(Army: TArmy);
    procedure TheMapArmySelected(A1: Integer; A2: Integer);  { draft }
    procedure TheMapDayChanged(Day: Integer);
    procedure TheMapDeactivateHSM;  { draft }
    procedure TheMapEndTurn(Player: Shortint; Cancelled: Boolean);
    procedure TheMapExecuteEventLog(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure TheMapGameOver;  { draft }
    procedure TheMapGemsChanged(Player: Shortint);
    procedure TheMapGlobalMagicChanged;  { draft }
    procedure TheMapIncomeChanged(Player: Shortint);
    procedure TheMapMapChanged(var Info: TMapChangedInfo);
    procedure TheMapScannerIconsChanged(var Info: TMapChangedInfo);
    procedure TheMapPlayerMagicChanged(Player: Shortint); { $44FA8D }
    procedure TheMapSeatedPlayerChanged(Player: Shortint);  { draft }
    procedure TheMapShowMessage(var Info: TShowMessageInfo);
    procedure TheMapStructureChanged(A1: Integer);  { draft }
    procedure TheMapStructureDeselected;  { draft }
    procedure TheMapStructureDestroyed(Structure: TStructure);
    procedure TheMapStructureSelected(A1: Integer);  { draft }
    procedure TheMapItemsDeselected;  { draft }
    procedure TheMapItemsSelected;  { draft }
    procedure TheMapTargetSelectionChange;  { draft }
    procedure TheMapUnitChanged(U: TAbstractUnit);
    procedure TheMapCastSpell(A1: Integer);  { draft }
    procedure TheMapHSChanged(A1: Integer);  { draft }
    procedure TheMapRelationsChanged;  { draft }
    procedure TheMapDiplomaticChange;  { draft }
    procedure TheMapStructureDblClick(Structure: TStructure);
  end;


implementation

uses E3Globals, AoWWinMan, AoWUnitBanner, aowSetupEvents, AoWExeForms, E1Globals, City, PrdPlace, WizardsTower, Arena, AoWCityScreen, AoWProdScreen;

procedure TMapEvents.TheMapActivateAbility(Request: TActivateAbilityInfo);
begin
  if Request.FAbilityID = 52 then SpellBook.ShowCasting(Request)
  else if Request.FAbilityID = 125 then ConstructDlg.Execute(Request)
  else if Request is TUnitSelectorAAI then UnitSelectionDlg.Execute(TUnitSelectorAAI(Request));
end;

procedure TMapEvents.TheMapArmyChanged(A1: Integer);
begin end;

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
  if RealmWin.Dlg.Visible and (RealmWin.HeaderTab.Selected = 3) then RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapArmySelected(A1: Integer; A2: Integer);
begin end;

procedure TMapEvents.TheMapDayChanged(Day: Integer);
begin
  if msActivated in AoWHSMap.Status then TBWindow.TurnButton.FLastPlayer := -1;
  PInfoW.Turn.Text := AoWE.Format(TranslateRStr(DayXRStr), [Day]);
  E1Globals.MapEvents.TheMapGemsChanged(AoWHSMap.FSeatedPlayer);
  E1Globals.MapEvents.TheMapIncomeChanged(AoWHSMap.FSeatedPlayer);
  if RealmWin.Dlg.Visible then RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapDeactivateHSM;
begin
  try
    General.SaveLayout; General.HideWindows;
    MWindow.MapViewer.HSMap := nil;
    SetupEvents.DPlay.DisConnect;
    if SetupEvents.FLobbyGame then MainForm.Close;
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

procedure TMapEvents.TheMapExecuteEventLog(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

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
      if RealmWin.Dlg.Visible and (RealmWin.HeaderTab.Selected = 0) then RealmWin.UpdateOverview;
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
      if RealmWin.Dlg.Visible and (RealmWin.HeaderTab.Selected = 0) then RealmWin.UpdateOverview;
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
    TBWindow.TurnButton.FLastPlayer := 12;
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
    TBWindow.CurP.Visible := AoWHSMap.FPlayMode = pmSimultaneous;
    PInfoW.UpdatePlayer;
    if RealmWin.Dlg.Visible then RealmWin.UpdateOverview;
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

procedure TMapEvents.TheMapStructureChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapStructureDeselected;
begin
  if General.FSign <> nil then
    General.FSign.ChangeText(AoWHSMap.FSeatedPlayer, IWindow.SignText.Items);
  General.FStructure := nil; General.FCity := nil; General.FProductionPlace := nil;
  General.FExplorationSite := nil; General.FSign := nil;
  IWindow.StructNameLbl.Text := ''; IWindow.StructLine.Visible := False;
  IWindow.InfoWin.Visible := False; TBWindow.StructButton.Visible := False;
end;

procedure TMapEvents.TheMapStructureDestroyed(Structure: TStructure);
begin
  if (Structure <> nil) and (Structure = General.FStructure) then TheMapStructureDeselected;
  if RealmWin.Dlg.Visible and ((RealmWin.HeaderTab.Selected = 2) or (RealmWin.HeaderTab.Selected = 1)) then RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapStructureSelected(A1: Integer);
begin end;

procedure TMapEvents.TheMapItemsDeselected;
begin HideItemSelection(IWindow); end;

procedure TMapEvents.TheMapItemsSelected;
begin end;

procedure TMapEvents.TheMapTargetSelectionChange;
begin end;

procedure TMapEvents.TheMapUnitChanged(U: TAbstractUnit);
begin
  if U = General.FSelectedUnit then
  begin
    if UnitWindow.UnitWin.Visible then UnitWindow.ShowUnit;
    if UnitBanner.BannerPopup.Visible then UnitBanner.BannerPopupShow(Self);
  end;
  SpellBook.UnitChanged(U);
end;

procedure TMapEvents.TheMapCastSpell(A1: Integer);
begin end;

procedure TMapEvents.TheMapHSChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapRelationsChanged;
begin end;

procedure TMapEvents.TheMapDiplomaticChange;
begin end;

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

end.
