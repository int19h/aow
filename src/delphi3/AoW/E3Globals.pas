unit E3Globals;

{ Executable module references used by E3. }
interface
uses aowIntGfxMod, FontMod, AoWUnit, AoWItemBanner, AoWSWindow,
  AOWMWindow, AoWTBWindow, AoWPInfoWin, AOWControlWin, AoWUnitSelDlg,
  AoWUnitWindow, AoWTargetSelection, AoWArmyInfoDlg, AoWDisjunctionDlg,
  AOWChatWin, AoWTCUnit, AoWTCScanner, AoWInfoWin, AoWRealm, AoWMagic, AoWEmailSettingsDlg, AoWEmailGameSettingsDlg, AOWTitleWindow, AOWDialogWin, AoWProgressDialog, Forms, Controls, Classes, AoWWorldMap, AoWTitleScene, AoWVideoDlg, AoWSpellBook, AOWMultiWin, AoWResultsWin;
var
  IntGfxMod: TIntGfxMod;
  FontModule: TFontModule;
  MainForm: TMainForm;
  ItemBanner: TItemBanner absolute AoWItemBanner.ItemBanner; { $45B05C }
  { conflict: ItemBanner: TItemBanner; }
  ItemID: Integer absolute AoWItemBanner.ItemID; { $45B060 }
  { conflict: ItemID: Integer; }
  IWindow: TIWindow;
  RealmWin: TRealmWin;
  MagicWin: TMagicWin;
  SWindow: TSWindow;
  MWindow: TMWindow;
  TBWindow: TTBWindow;
  PInfoW: TPInfoW absolute AoWPInfoWin.PInfoW;
  ControlWin: TControlWin;
  UnitSelectionDlg: TUnitSelectionDlg;
  UnitWindow: TUnitWindow;
  TargetSelectionDlg: TTargetSelectionDlg;
  ArmyInfoDlg: TArmyInfoDlg;
  DisjunctionDlg: TDisjunctionDlg;
  ChatWindow: TChatWindow;
  TCUnit: TTCUnit;
  TCScanner: TTCScanner;
  EmailSettingsDlg: TEmailSettingsDlg;
  EmailGameSettingsDlg: TEmailGameSettingsDlg;
  TitleWindow: TTitleWindow;
  DialogWin: TDWin;
  ProgressDialog: TProgressDialog;
  WorldMap: TWorldMap;
  TitleScene: TTitleScene;
  SpellBook: TSpellBook;
  MultiWindow: TMultiWindow;
  ResultsWin: TResultsWin;
procedure ShowResults(Window: TResultsWin);
procedure HideItemSelection(Window: TIWindow);
procedure RefreshMagicWindow(Window: TMagicWin);
procedure MagicPlayerChanged(Window: TMagicWin; Player: Shortint);
procedure RefreshGlobalMagic(Window: TMagicWin);
procedure GlobalMagicChanged(Window: TMagicWin);
procedure ShowTitleScene(Scene: TTitleScene; Music: Boolean);
procedure SetMainCursor(Form: TMainForm; Cursor: TCursor);
procedure ShowDemoMessage;
procedure ShowEmailSettings(Dialog: TEmailSettingsDlg);

resourcestring
  DisbandUnitRStr = 'Disband this unit?';
  ConfirmRStr = 'Confirm';

implementation

uses AoWE, AoWExeForms, AoWWinMan, Sound, SysUtils, AoWCheckBox;

procedure ShowEmailSettings(Dialog: TEmailSettingsDlg);
begin
  Dialog.LocalEmailAddressEdit.Text := AoWEngine.FRegistry.GetLocalEmailAddress;
  Dialog.SMTPServerEdit.Text := AoWEngine.FRegistry.GetSMTPServer;
  Dialog.AttachmentDirectoryEdit.Text := AoWEngine.FRegistry.GetAttachmentDirectory;
  Dialog.Dlg.Visible := True;
end;

procedure ShowDemoMessage;
begin
  ResetMessageDialog(AoWExeForms.MessageDlg);
  AoWExeForms.MessageDlg.MessageMemo.Items.Add('');
  AoWExeForms.MessageDlg.MessageMemo.Items.Add(TranslateRStr(DemoVersionMessageRStr));
  AoWExeForms.MessageDlg.OKPnl.Visible := True;
  AoWExeForms.MessageDlg.Dlg.Visible := True;
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
    if Control.FResearchSpellID = 0 then Window.SpellPnl.Visible := False
    else
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(Control.FResearchSpellID);
      Window.SpellName.Text := Spell.FSpellName;
      Window.SpellClass.Text := TranslateRStr(TMagicSphereRStr[Spell.FMagicSphere]) + ', ' + TranslateRStr(LevelRStr) + ' ' + IntToStr(Spell.FSpellLevel);
      Window.SpellCost.Text := TranslateRStr(CastingCostRStr) + ': ' + IntToStr(Spell.FBaseManaCost) + ' ' + TranslateRStr(ManaRStr);
      Turns := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.GetResearchTurnsLeft;
      if Turns >= 999 then Window.ResearchTurnsLeft.Text := AoWE.Format(TranslateRStr(XTurnsRStr), ['?'])
      else Window.ResearchTurnsLeft.Text := FmtTurnsLeftStr(Turns);
      Window.SpellPnl.Visible := True;
    end;
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

procedure ShowResults(Window: TResultsWin);
var I: Integer;
begin
  if AoWEngine.FDemo then PlaySongEx('Songs\Special\end2.s3m', 2, 2, True)
  else PlaySongEx('Songs\Special\Sunset.it', 2, 2, True);
  SetMusicVolume(0);
  FadeMusicVolume(AoWExeForms.SoundDlg.MusicVolume.Position, 1);
  Window.FPlayers.Clear;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptIndependent then Window.FPlayers.Add(I);
  for I := 0 to 11 do
  begin
    TAOWCheckBox(Window.FControls[I]).Visible := I < Window.FPlayers.Count;
    TAOWCheckBox(Window.FControls[I]).Checked := (I < Window.FPlayers.Count) and (Window.FPlayers[I] = AoWHSMap.FSeatedPlayer);
  end;
  if (AoWEngine.FCampaign <> nil) and
    (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGameOverStatus = goLost) then
  begin Window.ContinueBtn.Text := TranslateRStr(ReplayRStr); Window.ExitBtn.Visible := True; end
  else
  begin Window.ContinueBtn.Text := TranslateRStr(ContinueRStr); Window.ExitBtn.Visible := False; end;
  ResultsWin.ResultsPnl.Visible := True;
end;

procedure HideItemSelection(Window: TIWindow);
begin
  Window.InfoWin.Visible := False;
  Window.FItemBag := nil;
end;

end.
