unit E3Globals;

{ Executable module references used by E3. }
interface
uses aowIntGfxMod, FontMod, AoWUnit, AoWItemBanner, AoWSWindow,
  AOWMWindow, AoWTBWindow, AoWPInfoWin, AOWControlWin, AoWUnitSelDlg,
  AoWUnitWindow, AoWTargetSelection, AoWArmyInfoDlg, AoWDisjunctionDlg,
  AOWChatWin, AoWTCUnit, AoWTCScanner, AoWInfoWin, AoWRealm, AoWMagic, AoWEmailSettingsDlg, AoWEmailGameSettingsDlg, AOWTitleWindow;
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
procedure ShowEmailSettings(Dialog: TEmailSettingsDlg);

implementation

uses AoWE;

procedure ShowEmailSettings(Dialog: TEmailSettingsDlg);
begin
  Dialog.LocalEmailAddressEdit.Text := AoWEngine.FRegistry.GetLocalEmailAddress;
  Dialog.SMTPServerEdit.Text := AoWEngine.FRegistry.GetSMTPServer;
  Dialog.AttachmentDirectoryEdit.Text := AoWEngine.FRegistry.GetAttachmentDirectory;
  Dialog.Dlg.Visible := True;
end;
end.
