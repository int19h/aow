unit E2Globals;

{ Form references and resource strings accessed by executable E2 routines. }
interface
uses AoWTutorialWin, AoWUnit, AoWCampaignJoin, AoWProgressDialog, AoWSyncDlg, AoWWindow, AoWLabel, AOWGauge, AoWTitleScene, AOWTitleWindow,
  AoWCampaignTransferDlg, AoWTargetSelection, AoWLeaderSetup, AoWFileDialog, AoWGamePlayDlg,
  AoWPowerDlg, AoWIntroScene, AOWDialogWin, AoWCampaignSettings;
var
  GamePlayDialog: TGamePlayDlg;
  TitleScene: TTitleScene;
  CampaignJoinDlg: TCampaignJoinDlg;
  TutorialWindow: TTutorialWindow;
  TitleWindow: TTitleWindow;
  CampaignTransferDlg: TCampaignTransferDlg;
  TargetSelectionDlg: TTargetSelectionDlg;
  LeaderSetupWin: TLeaderSetupWin;
  FileDlgWindow: TFileDlgWindow absolute AoWFileDialog.FileDlgWindow;
  IntroScene: TIntroScene;
  PowerDlg: TPowerDlg;
  SynchronizeDlg: TSynchronizeDlg;
  DialogWin: TDWin;
  CampaignSettingsDlg: TCampaignSettingsDlg;
  ProgressDialog: TProgressDialog;
  DeferredSetupAction: Byte absolute AoWUnit.DeferredSetupAction; { $45B2B5 }
  DisplayActivated: Boolean absolute AoWUnit.DisplayActivated; { $45B2B4 }

resourcestring
  LoadingRStr = 'Loading';
  FileNotFoundRStr = 'File not found';
  WarningRStr = 'Warning';
  ConnectionLostRStr = 'Connection Lost!';
  BackgroundRStr = 'Background';
  SurfaceRStr = 'Surface';
  CavernsRStr = 'Caverns';
  DepthsRStr = 'Depths';

resourcestring
  ChooseFactionRStr = 'Choose a Faction';
  HideInfoRStr = 'Hide Info';
  ShowInfoRStr = 'Show Info';
  ViewSummaryRStr = 'View Summary';
  CultOfStormsRStr = 'The Cult of Storms';
  KeepersRStr = 'The Keepers';
  QuitCampaignRStr = 'Quit the Campaign?';
  QuitCombatRStr = 'Surrender your forces?';
  ConfirmRStr = 'Confirm';

implementation
end.
