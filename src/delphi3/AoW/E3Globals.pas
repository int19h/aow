unit E3Globals;

{ Executable module references used by E3. }
interface
uses aowIntGfxMod, FontMod, AoWUnit, AoWItemBanner, AoWSWindow,
  AOWMWindow, AoWTBWindow, AoWPInfoWin, AOWControlWin, AoWUnitSelDlg,
  AoWUnitWindow, AoWTargetSelection, AoWArmyInfoDlg, AoWDisjunctionDlg,
  AOWChatWin, AoWTCUnit, AoWTCScanner, AoWInfoWin, AoWRealm, AoWMagic;
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
  PInfoW: TPInfoW;
  ControlWin: TControlWin;
  UnitSelectionDlg: TUnitSelectionDlg;
  UnitWindow: TUnitWindow;
  TargetSelectionDlg: TTargetSelectionDlg;
  ArmyInfoDlg: TArmyInfoDlg;
  DisjunctionDlg: TDisjunctionDlg;
  ChatWindow: TChatWindow;
  TCUnit: TTCUnit;
  TCScanner: TTCScanner;
implementation
end.
