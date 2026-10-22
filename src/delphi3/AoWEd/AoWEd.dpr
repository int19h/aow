program AoWEd;

{$APPTYPE GUI}
{$R '..\..\res\AoWEd.res'}

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
  IvTests,
  IvTestDi,
  RandomNode,
  AoWE,
  AoWReg,
  AoWTCReg,
  HSEdMod,
  Spin,
  TerTSFrm,
  EFlagMsgEvent,
  AoWMapEF,
  MDIForm,
  AoWDlg,
  PasswordDialog,
  TextEdDlg,
  PlInfFlt,
  EItemHS,
  EItem,
  SelAbDlg,
  ItemSel,
  AoWREFrm,
  ResEForm,
  ItemFlt,
  UnitFlt,
  AoWEMod,
  ETutorialMessageEvent,
  EAoWMO,
  EFlagEvent,
  EPlaySample,
  EMoveOnEvent,
  EShowMessage,
  EChangeSong,
  EPoisonC,
  ETCUnitPos,
  EProdP,
  EConstr,
  EFarm,
  EFire,
  ESmokeC,
  EWizardsTower,
  EManaC,
  EItmExpS,
  EExplorS,
  EDungeon,
  EGems,
  EArmy,
  EHero,
  FaceSel,
  RMapObj,
  ETeleprt,
  Ecity,
  ESign,
  EFaceRes,
  EItemGFX,
  EHeroRes,
  EAUnitRes,
  ERaceRes,
  EUnitRes,
  EUnitGFX,
  EUGFXGen,
  RPlayerStructure,
  RMultiHx,
  RConstr,
  RCILTer,
  RILTer,
  RCTerrain,
  RTerrain,
  RDungeon,
  RExploreS,
  RFire,
  RProdP,
  RCity,
  ROverlay,
  RAoWTer,
  RIsoHex,
  RRoad,
  RHexagon,
  RBridge,
  RPad,
  FontMod,
  HeroLibF,
  ValidateMapDlg,
  HSSetDlg,
  AboutDialog,
  MapSDlg,
  TextCtrlEd,
  ScannerFlt,
  SplashFrm,
  ItemLibF,
  GameSDlg,
  NewMapDialog;

var
  InstanceMapping: THandle;
  InstanceTAoWEngineModule: AoWEMod.TAoWEngineModule;
  InstanceTAboutDlg: AboutDialog.TAboutDlg;
  InstanceTMapValidationDlg: ValidateMapDlg.TMapValidationDlg;
  Splash: SplashFrm.TSplashForm;

begin
  InstanceMapping := CreateFileMapping(THandle(-1), nil, PAGE_READWRITE, 0, 32, 'AOWED');
  try
    if (InstanceMapping <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
    begin
      ShowMessage('Age of Wonders Editor is already running.');
      Exit;
    end;
    Splash := SplashFrm.TSplashForm.Create(Application);
    Splash.Show;
    Splash.Update;
    Application.Initialize;
    Application.Title := 'Age of Wonders Editor';
    Application.CreateForm(HSEdMod.THSEditModule, HSEdMod.HSEditModule);
    Application.CreateForm(FontMod.TFontModule, FontMod.FontModule);
    Application.CreateForm(AoWEMod.TAoWEngineModule, InstanceTAoWEngineModule);
    Application.CreateForm(MDIForm.TMainForm, MDIForm.MainForm);
    Application.CreateForm(UnitFlt.TUnitFloater, UnitFlt.UnitFloater);
    Application.CreateForm(ItemFlt.TItemFloater, ItemFlt.ItemFloater);
    Application.CreateForm(PlInfFlt.TPlayerInfoFloater, PlInfFlt.PlayerInfoFloater);
    Application.CreateForm(ScannerFlt.TScannerFloater, ScannerFlt.ScannerFloater);
    Application.CreateForm(AboutDialog.TAboutDlg, InstanceTAboutDlg);
    Application.CreateForm(ValidateMapDlg.TMapValidationDlg, InstanceTMapValidationDlg);
    MDIForm.MainForm.Show;
    MDIForm.MainForm.Update;
    Splash.Hide;
    Splash.Free;
    Application.Run;
  finally
    if InstanceMapping <> 0 then CloseHandle(InstanceMapping);
  end;
end.
