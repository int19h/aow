program AoW;

{$APPTYPE GUI}
{$R '..\..\res\AoW.res'}

{ Unit order from the original PACKAGEINFO; form order from the original startup code. }
uses
  Windows,
  SysUtils,
  Classes,
  Forms,
  Dialogs,
  { Initialization dependencies imported by the original executable. }
  IvCommon,
  IvStamp,
  IvDemoD,
  IvParser,
  IvMLDFil,
  IvMlRead,
  IvReader,
  Galaxy,
  GalSndS,
  EList,
  LicenseF,
  AoWHTMLMemo,
  FileCtrl,
  AoWLenLine,
  ProgDlg,
  agConst,
  agtypes,
  msCls,
  msaddred,
  msutils,
  msmime,
  agwsock,
  agrasAPI,
  agRasCmp,
  msconst,
  mspop3cl,
  msnwscls,
  msuucode,
  mspars,
  mspop3,
  AoWE,
  AoWReg,
  AoWTCReg,
  HSEdMod,
  AoWCampaignSettings,
  AoWWinMan,
  AoWUnit,
  AoWTBWindow,
  FontMod,
  AoWPWindows,
  AOWDialogWin,
  AoWUnitWindow,
  AOWControlWin,
  AoWUnitBanner,
  aowIntGfxMod,
  aowHelpWin,
  AoWItemBanner,
  AoWInfoBanner,
  aowMapEvents,
  AoWSpellBook,
  AOWMultiWin,
  AOWTitleWindow,
  AoWVideoDlg,
  AOWMWindow,
  AoWSWindow,
  AoWTCScanner,
  AoWFileDialog,
  AoWWorldMap,
  AoWCampaignTransferDlg,
  AoWTitleScene,
  AoWSelFactionWin,
  AoWCampaignJoin,
  AoWLeaderSetup,
  AoWMessageDlg,
  aowSetupEvents,
  AoWScenSetup,
  AoWEmailGameSettingsDlg,
  AoWEmailSettingsDlg,
  AOWChatWin,
  AoWProgressDialog,
  AoWSyncDlg,
  AoWSoundDlg,
  AOWPyreScrn,
  AoWResultsWin,
  AoWPOP3Dlg,
  AoWMagic,
  AoWPowerDlg,
  AoWConstructDlg,
  AoWCastUnitSpellDlg,
  AoWDisjunctionDlg,
  AoWTCUnit,
  FastCombatWin,
  AoWArmyEventDlg,
  AoWCityRebelDlg,
  AoWRelations,
  AoWPInfoWin,
  AoWCityJoinDlg,
  AoWPartyJoin,
  AoWHeroJoinDlg,
  AoWMsgReceiveDlg,
  AoWNewTurnDialog,
  TCFCDlg,
  AoWInfoWin,
  AoWCityScreen,
  AoWProdScreen,
  AoWTargetSelection,
  AoWUnitSelDlg,
  AoWDeformFaceDlg,
  AoWHeroUpgradeDlg,
  AoWArmyInfoDlg,
  AoWHeroInfoDlg,
  AoWRealm,
  AoWWizardsTowerDlg,
  AoWArenaDlg,
  AoWItemsFoundDlg,
  AoWSendEmailGameDlg,
  AoWSMTPDlg,
  AoWPasswordDlg,
  AoWTutorialWin,
  AoWGamePlayDlg,
  AoWIntroScene,
  aowTCMapEvents,
  AoWExeForms,
  E1GameFlow,
  E1Globals,
  E1Resources,
  E1TacticalSupport,
  E2CampaignSupport,
  E2DirectSound,
  E2GameFlow,
  E2Globals,
  E2WindowLayout,
  E3EventDialogs,
  E3Globals,
  E3IMSTypes,
  E3StructureInfo;

var
  InstanceMapping: THandle;
  InstanceTTCMapEvents: aowTCMapEvents.TTCMapEvents;

function CanStartGame: Boolean;
var
  Status: TMemoryStatus;
begin
  Result := AoWEngine.FDemo or GuaranteeAoWCD(
    TranslateRStr(PleaseInsertTheAoWCDRStr), TranslateRStr(PleaseInsertTheAoWCDRetryRStr));
  if not Result then Exit;
  Status.dwLength := SizeOf(Status);
  GlobalMemoryStatus(Status);
  Result := Integer((Status.dwAvailPhys shr 20) + (Status.dwAvailVirtual shr 20)) >= 50;
  if not Result then ShowMessage(TranslateRStr(LowSytemResourcesRStr));
end;

begin
  InstanceMapping := CreateFileMapping(THandle(-1), nil, PAGE_READWRITE, 0, 32, 'AOW');
  try
    if not CanStartGame then Exit;
    Application.Title := TranslateRStr(AgeOfWondersRStr);
    Application.Initialize;
    Application.CreateForm(aowIntGfxMod.TIntGfxMod, aowIntGfxMod.IntGfxMod);
    Application.CreateForm(FontMod.TFontModule, AoWExeForms.FontModule);
    Application.CreateForm(AoWWinMan.TGeneral, AoWWinMan.General);
    Application.CreateForm(AoWTargetSelection.TTargetSelectionDlg, AoWWorldMap.TargetSelectionDlg);
    Application.CreateForm(aowSetupEvents.TSetupEvents, aowSetupEvents.SetupEvents);
    Application.CreateForm(aowMapEvents.TMapEvents, aowMapEvents.MapEvents);
    Application.CreateForm(aowTCMapEvents.TTCMapEvents, InstanceTTCMapEvents);
    Application.CreateForm(AOWTitleWindow.TTitleWindow, E2Globals.TitleWindow);
    Application.CreateForm(AoWPWindows.TPopupWindows, E1Globals.PopupWindows);
    Application.CreateForm(AoWTBWindow.TTBWindow, AoWExeForms.TBWindow);
    Application.CreateForm(AoWSWindow.TSWindow, AoWSWindow.SWindow);
    Application.CreateForm(AOWMWindow.TMWindow, AOWMWindow.MWindow);
    Application.CreateForm(AoWInfoWin.TIWindow, AoWInfoWin.IWindow);
    Application.CreateForm(AOWDialogWin.TDWin, E2Globals.DialogWin);
    Application.CreateForm(AOWControlWin.TControlWin, AOWControlWin.ControlWin);
    Application.CreateForm(AoWUnitBanner.TUnitBanner, AoWUnitBanner.UnitBanner);
    Application.CreateForm(AoWUnitWindow.TUnitWindow, AoWUnitWindow.UnitWindow);
    Application.CreateForm(AOWChatWin.TChatWindow, AoWExeForms.ChatWindow);
    Application.CreateForm(AOWMultiWin.TMultiWindow, AoWExeForms.MultiWindow);
    Application.CreateForm(AoWFileDialog.TFileDlgWindow, AoWFileDialog.FileDlgWindow);
    Application.CreateForm(AoWPInfoWin.TPInfoW, AoWPInfoWin.PInfoW);
    Application.CreateForm(AoWProgressDialog.TProgressDialog, E2Globals.ProgressDialog);
    Application.CreateForm(AoWSoundDlg.TSoundDlg, AoWExeForms.SoundDlg);
    Application.CreateForm(AoWVideoDlg.TVideoDialog, AoWVideoDlg.VideoDialog);
    Application.CreateForm(FastCombatWin.TFastCombatWindow, E3EventDialogs.FastCombatWindow);
    Application.CreateForm(AOWPyreScrn.TPyreScreen, AOWPyreScrn.PyreScreen);
    Application.CreateForm(AoWNewTurnDialog.TNewTurnDlg, E3EventDialogs.NewTurnDlg);
    Application.CreateForm(AoWArmyEventDlg.TArmyEventDlg, E3EventDialogs.ArmyEventDlg);
    Application.CreateForm(AoWCityJoinDlg.TCityJoinDlg, E3EventDialogs.CityJoinDlg);
    Application.CreateForm(AoWItemBanner.TItemBanner, AoWItemBanner.ItemBanner);
    E3Globals.ItemBanner := AoWItemBanner.ItemBanner;
    Application.CreateForm(AoWCityRebelDlg.TCityRebelDlg, E3EventDialogs.CityRebelDlg);
    Application.CreateForm(AoWSelFactionWin.TSelFactionWin, AoWSelFactionWin.SelFactionWin);
    Application.CreateForm(AoWMsgReceiveDlg.TMsgReceiveDlg, E3EventDialogs.MsgReceiveDlg);
    Application.CreateForm(AoWHeroInfoDlg.THeroInfoDlg, E3EventDialogs.HeroInfoDlg);
    Application.CreateForm(AoWPartyJoin.TPartyJoinDlg, E3EventDialogs.PartyJoinDlg);
    Application.CreateForm(AoWArmyInfoDlg.TArmyInfoDlg, E3Globals.ArmyInfoDlg);
    Application.CreateForm(AoWWorldMap.TWorldMap, AoWWorldMap.WorldMap);
    Application.CreateForm(AoWTCUnit.TTCUnit, AoWTCUnit.TCUnit);
    Application.CreateForm(AoWTCScanner.TTCScanner, AoWExeForms.TCScanner);
    Application.CreateForm(AoWScenSetup.TScenSetup, AoWExeForms.ScenSetup);
    Application.CreateForm(TCFCDlg.TTCFCDialog, E3EventDialogs.TCFCDialog);
    Application.CreateForm(AoWRelations.TRelWindow, E1Globals.RelWindow);
    Application.CreateForm(AoWUnitSelDlg.TUnitSelectionDlg, E3Globals.UnitSelectionDlg);
    Application.CreateForm(AoWArenaDlg.TArenaDlg, E3EventDialogs.ArenaDlg);
    Application.CreateForm(AoWConstructDlg.TConstructDlg, AoWExeForms.ConstructDlg);
    Application.CreateForm(AoWMagic.TMagicWin, AoWExeForms.MagicWin);
    Application.CreateForm(AoWWizardsTowerDlg.TWizardsTowerDlg, E3EventDialogs.WizardsTowerDlg);
    Application.CreateForm(AoWPowerDlg.TPowerDlg, E2Globals.PowerDlg);
    Application.CreateForm(AoWSpellBook.TSpellBook, AoWExeForms.SpellBook);
    Application.CreateForm(AoWLeaderSetup.TLeaderSetupWin, AoWLeaderSetup.LeaderSetupWin);
    Application.CreateForm(AoWDeformFaceDlg.TDeformFaceDlg, E3Globals.DeformFaceDlg);
    Application.CreateForm(AoWHeroUpgradeDlg.THeroUpgradeDlg, E3EventDialogs.HeroUpgradeDlg);
    Application.CreateForm(AoWEmailGameSettingsDlg.TEmailGameSettingsDlg, E3Globals.EmailGameSettingsDlg);
    Application.CreateForm(AoWCastUnitSpellDlg.TCastUnitSpellDlg, E3Globals.CastUnitSpellDlg);
    Application.CreateForm(AoWDisjunctionDlg.TDisjunctionDlg, AoWExeForms.DisjunctionDlg);
    E3Globals.DisjunctionDlg := AoWExeForms.DisjunctionDlg;
    Application.CreateForm(AoWHeroJoinDlg.THeroJoinDlg, E3EventDialogs.HeroJoinDlg);
    Application.CreateForm(AoWResultsWin.TResultsWin, AoWResultsWin.ResultsWin);
    Application.CreateForm(AoWSyncDlg.TSynchronizeDlg, E2Globals.SynchronizeDlg);
    Application.CreateForm(AoWCityScreen.TCityScreen, AoWCityScreen.CityScreen);
    Application.CreateForm(AoWProdScreen.TProductionScreen, AoWProdScreen.ProductionScreen);
    Application.CreateForm(AoWRealm.TRealmWin, AoWRealm.RealmWin);
    Application.CreateForm(AoWCampaignTransferDlg.TCampaignTransferDlg, E2Globals.CampaignTransferDlg);
    Application.CreateForm(AoWTitleScene.TTitleScene, E2Globals.TitleScene);
    Application.CreateForm(AoWIntroScene.TIntroScene, E1Globals.IntroScene);
    E2Globals.IntroScene := E1Globals.IntroScene;
    Application.CreateForm(AoWSendEmailGameDlg.TSendEmailGameDlg, E3EventDialogs.SendEmailGameDlg);
    Application.CreateForm(AoWEmailSettingsDlg.TEmailSettingsDlg, E3Globals.EmailSettingsDlg);
    Application.CreateForm(AoWPOP3Dlg.TPOP3Dlg, E3Globals.POP3Dlg);
    Application.CreateForm(AoWSMTPDlg.TSMTPDlg, AoWSMTPDlg.SMTPDlg);
    Application.CreateForm(aowHelpWin.THelpWindow, aowHelpWin.HelpWindow);
    Application.CreateForm(AoWCampaignJoin.TCampaignJoinDlg, E2Globals.CampaignJoinDlg);
    Application.CreateForm(AoWItemsFoundDlg.TItemsFoundDlg, E3EventDialogs.ItemsFoundDlg);
    Application.CreateForm(AoWGamePlayDlg.TGamePlayDlg, E2Globals.GamePlayDialog);
    Application.CreateForm(AoWPasswordDlg.TPasswordDlg, E3EventDialogs.PasswordDlg);
    Application.CreateForm(AoWInfoBanner.TInfoBanner, AoWInfoBanner.InfoBanner);
    Application.CreateForm(AoWMessageDlg.TMessageDlg, AoWMessageDlg.MessageDlg);
    Application.CreateForm(AoWTutorialWin.TTutorialWindow, E2Globals.TutorialWindow);
    Application.CreateForm(AoWCampaignSettings.TCampaignSettingsDlg, E2Globals.CampaignSettingsDlg);
    Application.CreateForm(AoWUnit.TMainForm, AoWUnit.MainForm);
    Application.Run;
  finally
    if InstanceMapping <> 0 then CloseHandle(InstanceMapping);
  end;
end.
