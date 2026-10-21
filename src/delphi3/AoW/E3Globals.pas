unit E3Globals;

{ Executable module references used by E3. }
interface
uses AoWE, aowIntGfxMod, FontMod, AoWUnit, AoWItemBanner, AoWSWindow,
  AOWMWindow, AoWTBWindow, AoWPInfoWin, AOWControlWin, AoWUnitSelDlg,
  AoWUnitWindow, AoWTargetSelection, AoWArmyInfoDlg, AoWDisjunctionDlg,
  AOWChatWin, AoWTCUnit, AoWTCScanner, AoWInfoWin, AoWRealm, AoWMagic, AoWEmailSettingsDlg, AoWEmailGameSettingsDlg, AOWTitleWindow, AOWDialogWin, AoWProgressDialog, Forms, Controls, Classes, AoWWorldMap, AoWTitleScene, AoWVideoDlg, AoWSpellBook, AOWMultiWin, AoWResultsWin, AoWExeForms, E1Globals, E2Globals, AoWPOP3Dlg, AoWCastUnitSpellDlg, AoWDeformFaceDlg;
var
  IntGfxMod: TIntGfxMod absolute aowIntGfxMod.IntGfxMod; { $45B03C }
  FontModule: TFontModule absolute AoWExeForms.FontModule; { $45B034 }
  MainForm: TMainForm absolute AoWUnit.MainForm; { $45B2B0 }
  ItemBanner: TItemBanner absolute AoWItemBanner.ItemBanner; { $45B05C }
  { conflict: ItemBanner: TItemBanner; }
  ItemID: Integer absolute AoWItemBanner.ItemID; { $45B060 }
  { conflict: ItemID: Integer; }
  IWindow: TIWindow absolute AoWInfoWin.IWindow;
  RealmWin: TRealmWin absolute AoWRealm.RealmWin; { $45B240 }
  MagicWin: TMagicWin absolute AoWExeForms.MagicWin; { $45B180 }
  SWindow: TSWindow absolute AoWSWindow.SWindow; { $45B2A0 }
  MWindow: TMWindow absolute AOWMWindow.MWindow; { $45B298 }
  TBWindow: TTBWindow absolute AoWExeForms.TBWindow; { $45B2C8 }
  PInfoW: TPInfoW absolute AoWPInfoWin.PInfoW;
  ControlWin: TControlWin absolute AOWControlWin.ControlWin; { $45B054; 00404F58 }
  UnitSelectionDlg: TUnitSelectionDlg;
  UnitWindow: TUnitWindow absolute AoWUnitWindow.UnitWindow; { $45B070 }
  TargetSelectionDlg: TTargetSelectionDlg absolute AoWWorldMap.TargetSelectionDlg;
  ArmyInfoDlg: TArmyInfoDlg;
  DisjunctionDlg: TDisjunctionDlg;
  ChatWindow: TChatWindow absolute AoWExeForms.ChatWindow; { $45B0B0 }
  TCUnit: TTCUnit absolute AoWExeForms.TCUnit; { $45B1A8 }
  TCScanner: TTCScanner absolute AoWExeForms.TCScanner; { $45B290 }
  EmailSettingsDlg: TEmailSettingsDlg;
  EmailGameSettingsDlg: TEmailGameSettingsDlg;
  TitleWindow: TTitleWindow absolute E2Globals.TitleWindow; { $45B15C }
  DialogWin: TDWin absolute E2Globals.DialogWin; { $45B288 }
  ProgressDialog: TProgressDialog absolute E2Globals.ProgressDialog; { $45B0B8 }
  WorldMap: TWorldMap absolute E1Globals.WorldMap; { $45B0F8 }
  TitleScene: TTitleScene absolute E2Globals.TitleScene; { $45B0E8 }
  SpellBook: TSpellBook absolute AoWExeForms.SpellBook; { $45B188 }
  MultiWindow: TMultiWindow absolute AoWExeForms.MultiWindow; { $45B16C }
  ResultsWin: TResultsWin absolute AoWResultsWin.ResultsWin; { $45B14C }
  POP3Dlg: TPOP3Dlg;
  CastUnitSpellDlg: TCastUnitSpellDlg;
  DeformFaceDlg: TDeformFaceDlg;


procedure HideItemSelection(Window: TIWindow);
procedure RefreshMagicWindow(Window: TMagicWin);
procedure MagicPlayerChanged(Window: TMagicWin; Player: Shortint);
procedure RefreshGlobalMagic(Window: TMagicWin);
procedure GlobalMagicChanged(Window: TMagicWin);
procedure ShowTitleScene(Scene: TTitleScene; Music: Boolean);
procedure SetMainCursor(Form: TMainForm; Cursor: TCursor);
procedure ShowEmailSettings(Dialog: TEmailSettingsDlg);

resourcestring
  DisbandUnitRStr = 'Disband this unit?';
  ConfirmRStr = 'Confirm';

resourcestring
  PartyActionRStr = 'Party Action:';
  PatrollingRStr = 'Patrolling';
  GuardingRStr = 'Guarding';
  ScoutingRStr = 'Scouting';
  SeekingRefugeRStr = 'Seeking Refuge';
  RaidingRStr = 'Raiding';
  HuntingRStr = 'Hunting';
  ProtectingRStr = 'Protecting';
  FortifiedRStr = 'Fortified';
  BerserkRStr = 'Berserk';
  WanderingRStr = 'Wandering';

resourcestring
  PartyJoinRStr = 'Party Join';
  XMadeALevelRStr = '%s made a level';
  XMadeYLevelsRStr = '%s made %d levels';

const
  TTacticalCombatAvailabilityRStr: array[0..2] of string = ('Never', 'Between Humans', 'Always');

resourcestring
  IndependentsRStr = 'Independents';
  ItemBagRStr = 'Item Bag';
  MapSettingsRStr = 'Scenario Info:';
  DayLimitXRStr = 'Turn Limit: %s';
const
  TVictoryConditionRStr: array[TVictoryCondition] of string = ('None', 'Conquer locations', 'Accumulate gold', 'Accumulate mana');
  TPlayerConnectionTypeRStr: array[TPlayerConnectionType] of string = ('Single Computer', 'Internet/Lan', 'Play by email');

implementation

uses E1Resources, AoWComp, AoWWinMan, Sound, SysUtils, AoWCheckBox, AoWMessageDlg;

procedure ShowEmailSettings(Dialog: TEmailSettingsDlg);
begin
  Dialog.LocalEmailAddressEdit.Text := AoWEngine.FRegistry.GetLocalEmailAddress;
  Dialog.SMTPServerEdit.Text := AoWEngine.FRegistry.GetSMTPServer;
  Dialog.AttachmentDirectoryEdit.Text := AoWEngine.FRegistry.GetAttachmentDirectory;
  Dialog.Dlg.Visible := True;
end;


procedure SetMainCursor(Form: TMainForm; Cursor: TCursor);
begin
  Form.FCursor := Abs(Cursor);
end;

procedure ShowTitleScene(Scene: TTitleScene; Music: Boolean);
begin
  if Music then
    if (SongPlayer.CurrentIndex = -1) or (SongPlayer.CurrentIndex >= SongPlayer.Songs.Count) or
      (SongPlayer.Songs[SongPlayer.CurrentIndex] <> 'SONGS\TITLE.IT') then
    begin SongPlayer.Songs.Clear; SongPlayer.Songs.Add('SONGS\TITLE.IT'); SongPlayer.Play(0); end;
  General.Manager.OverlayPriority := 0;
  Scene.TitleSceneIL.LoadDiscardableImageData;
  VideoDialog.SetSceneSize(640, 480);
  SetVideoMode(VideoDialog, scmTitle);
  VideoDialog.ApplyMode;
  MainForm.Display.FrameRate := 30;
  MainForm.DXDC.UseVerticalBlank := True;
  Scene.FRedrawBackground := True;
  Scene.FPressedButton := -1; Scene.FHoverButton := -1;
  Scene.FFont := FontModule.AoW15WhiteGrey;
  Scene.FCreditsFont := FontModule.AoW15WhiteGrey;
  Scene.Window.WinManager.SetILBIndex(4);
  Scene.Window.Visible := True;
end;

procedure RefreshMagicWindow(Window: TMagicWin);
var Control: TPlayerMagicControl; I, Turns: Integer; Spell: TSpell;
begin
  if AoWHSMap.FSeatedPlayer <> -1 then
  begin
    Control := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl;
    Window.EnchantmentList.Items.Clear; Window.BindingList.Items.Clear; Window.UpkeepList.Items.Clear;
    for I := 0 to Control.FEnchantments.Count - 1 do
    begin
      Window.EnchantmentList.Items.AddObject(Control.FEnchantments.GetEnchantments(I).GetName, Control.FEnchantments.GetEnchantments(I));
      Window.BindingList.Items.Add(Control.FEnchantments.GetEnchantments(I).GetBinding);
      Window.UpkeepList.Items.Add(IntToStr(Control.FEnchantments.GetEnchantments(I).FUpkeep));
    end;
    Window.PowerSourceList.Items.Clear; Window.PowerValueList.Items.Clear;
    for I := 0 to Control.FPowerSources.Count - 1 do
      if Control.FPowerSources.GetItems(I).Power > 0 then
      begin
        Window.PowerSourceList.Items.AddObject(Control.FPowerSources.GetItems(I).Name, Control.FPowerSources.GetItems(I));
        Window.PowerValueList.Items.Add(IntToStr(Control.FPowerSources.GetItems(I).Power));
      end;
    Window.Power.Text := IntToStr(Control.GetPower);
    Window.NetMana.Text := IntToStr(Control.GetManaIncome) + '-' + IntToStr(Control.GetManaUpkeep) + '=' +
      IntToStr(Control.GetManaIncome - Control.GetManaUpkeep);
    Window.ResearchPoints.Text := IntToStr(Control.GetNetPowerToResearch);
    if Control.FResearchSpellID <> 0 then
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(Control.FResearchSpellID);
      Window.SpellName.Text := Spell.FSpellName;
      Window.SpellClass.Text := TranslateRStr(TMagicSphereRStr[Spell.FMagicSphere]) + ', ' + TranslateRStr(LevelRStr) + ' ' + IntToStr(Spell.FSpellLevel);
      Window.SpellCost.Text := TranslateRStr(CastingCostRStr) + ': ' + IntToStr(Spell.FBaseManaCost) + ' ' + TranslateRStr(ManaRStr);
      Turns := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.GetResearchTurnsLeft;
      if Turns < 999 then Window.ResearchTurnsLeft.Text := FmtTurnsLeftStr(Turns)
      else Window.ResearchTurnsLeft.Text := AoWE.Format(TranslateRStr(XTurnsRStr), ['?']);
      Window.SpellPnl.Visible := True;
    end
    else Window.SpellPnl.Visible := False;
    Window.SortEnchantments;
    Window.SelectEnchantment(Window.EnchantmentList.Selected);
  end;
  Window.Dlg.FDrawn := False;
end;

procedure MagicPlayerChanged(Window: TMagicWin; Player: Shortint);
begin
  if Window.Dlg.Visible and (Player = AoWHSMap.FSeatedPlayer) then RefreshMagicWindow(Window);
end;

procedure RefreshGlobalMagic(Window: TMagicWin);
var Control: TGlobalMagicControl; I: Integer;
begin
  Control := AoWHSMap.FGlobalMagicControl;
  Window.GlobalEnchantmentList.Items.Clear; Window.GlobalNameList.Items.Clear; Window.GlobalUpkeepList.Items.Clear;
  for I := 0 to Control.FEnchantments.Count - 1 do
    if Control.FEnchantments.GetEnchantments(I).VisibleForPlayer(AoWHSMap.FSeatedPlayer) then
    begin
      Window.GlobalEnchantmentList.Items.AddObject(Control.FEnchantments.GetEnchantments(I).GetName, Control.FEnchantments.GetEnchantments(I));
      Window.GlobalNameList.Items.Add(AoWHSMap.FPlayers.GetPlayers(Control.FEnchantments.GetEnchantments(I).FPlayerIndex).FLeader.FHeroName);
      Window.GlobalUpkeepList.Items.Add(IntToStr(Control.FEnchantments.GetEnchantments(I).GetUpkeep));
    end;
  Window.SortGlobalEnchantments;
  Window.SelectGlobalEnchantment(Window.GlobalEnchantmentList.Selected);
  Window.Dlg.FDrawn := False;
end;

procedure GlobalMagicChanged(Window: TMagicWin);
begin
  if Window.Dlg.Visible then RefreshGlobalMagic(Window);
end;
























procedure HideItemSelection(Window: TIWindow);
begin
  Window.InfoWin.Visible := False;
  Window.FItemBag := nil;
end;



































































































































end.
