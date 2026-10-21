program matchtest;

{ Host program for the byte-matching of AoWEd.dpl: it references every class and every
  non-virtual method so that the linker keeps them; it is linked, never run. Build from this
  directory with the original compiler into a directory with a short path (DCC32 crashes on
  long paths):
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -Q "-U..\AoWEPACK;..\AoWTCPCK;..\AbilityP;..\AOWTools;..\ILToolsP;..\HSEPack;..;..\Gfxepack;..\Ilpack;..\Dcpack;..\SoundP;..\Network;..\aowFXpck;..\aowInt;..\Localize"
      -O.. -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  AboutDialog in 'AboutDialog.pas',
  AoWDlg in 'AoWDlg.pas',
  AoWEMod in 'AoWEMod.pas',
  AoWMapEF in 'AoWMapEF.pas',
  AoWREFrm in 'AoWREFrm.pas',
  EAoWMO in 'EAoWMO.pas',
  EArmy in 'EArmy.pas',
  EAUnitRes in 'EAUnitRes.pas',
  EChangeSong in 'EChangeSong.pas',
  Ecity in 'Ecity.pas',
  EConstr in 'EConstr.pas',
  EDungeon in 'EDungeon.pas',
  EExplorS in 'EExplorS.pas',
  EFaceRes in 'EFaceRes.pas',
  EFarm in 'EFarm.pas',
  EFire in 'EFire.pas',
  EFlagEvent in 'EFlagEvent.pas',
  EFlagMsgEvent in 'EFlagMsgEvent.pas',
  EGems in 'EGems.pas',
  EHero in 'EHero.pas',
  EHeroRes in 'EHeroRes.pas',
  EItem in 'EItem.pas',
  EItemGFX in 'EItemGFX.pas',
  EItemHS in 'EItemHS.pas',
  EItmExpS in 'EItmExpS.pas',
  EManaC in 'EManaC.pas',
  EMoveOnEvent in 'EMoveOnEvent.pas',
  EPlaySample in 'EPlaySample.pas',
  EPoisonC in 'EPoisonC.pas',
  EProdP in 'EProdP.pas',
  ERaceRes in 'ERaceRes.pas',
  EShowMessage in 'EShowMessage.pas',
  ESign in 'ESign.pas',
  ESmokeC in 'ESmokeC.pas',
  ETCUnitPos in 'ETCUnitPos.pas',
  ETeleprt in 'ETeleprt.pas',
  ETutorialMessageEvent in 'ETutorialMessageEvent.pas',
  EUGFXGen in 'EUGFXGen.pas',
  EUnitGFX in 'EUnitGFX.pas',
  EUnitRes in 'EUnitRes.pas',
  EWizardsTower in 'EWizardsTower.pas',
  FaceSel in 'FaceSel.pas',
  FontMod in 'FontMod.pas',
  GameSDlg in 'GameSDlg.pas',
  HeroLibF in 'HeroLibF.pas',
  HSSetDlg in 'HSSetDlg.pas',
  ItemFlt in 'ItemFlt.pas',
  ItemLibF in 'ItemLibF.pas',
  ItemSel in 'ItemSel.pas',
  MapSDlg in 'MapSDlg.pas',
  MDIForm in 'MDIForm.pas',
  NewMapDialog in 'NewMapDialog.pas',
  PasswordDialog in 'PasswordDialog.pas',
  PlInfFlt in 'PlInfFlt.pas',
  RAoWTer in 'RAoWTer.pas',
  RBridge in 'RBridge.pas',
  RCILTer in 'RCILTer.pas',
  RCity in 'RCity.pas',
  RConstr in 'RConstr.pas',
  RCTerrain in 'RCTerrain.pas',
  RDungeon in 'RDungeon.pas',
  ResEForm in 'ResEForm.pas',
  RExploreS in 'RExploreS.pas',
  RFire in 'RFire.pas',
  RHexagon in 'RHexagon.pas',
  RILTer in 'RILTer.pas',
  RIsoHex in 'RIsoHex.pas',
  RMapObj in 'RMapObj.pas',
  RMultiHx in 'RMultiHx.pas',
  ROverlay in 'ROverlay.pas',
  RPad in 'RPad.pas',
  RPlayerStructure in 'RPlayerStructure.pas',
  RProdP in 'RProdP.pas',
  RRoad in 'RRoad.pas',
  RTerrain in 'RTerrain.pas',
  ScannerFlt in 'ScannerFlt.pas',
  SelAbDlg in 'SelAbDlg.pas',
  Spin in 'Spin.pas',
  SplashFrm in 'SplashFrm.pas',
  TerTSFrm in 'TerTSFrm.pas',
  TextCtrlEd in 'TextCtrlEd.pas',
  TextEdDlg in 'TextEdDlg.pas',
  UnitFlt in 'UnitFlt.pas',
  ValidateMapDlg in 'ValidateMapDlg.pas';

var
  C: TClass;
  P: Pointer;

procedure Use(C: TClass; P: Pointer);
begin
  Writeln(Integer(C), Integer(P));
end;

begin
  Use(AboutDialog.TAboutDlg, nil);
  Use(AoWDlg.TAoWDialog, nil);
  Use(AoWEMod.TAoWEngineModule, nil);
  Use(AoWMapEF.TAoWMapEditForm, nil);
  Use(AoWREFrm.TAoWResourceEditForm, nil);
  Use(EAoWMO.TAoWMapObjEditForm, nil);
  Use(EArmy.TArmyEditForm, nil);
  Use(EArmy.TArmyHSEditor, nil);
  Use(EArmy.TArmyPlaceControl, nil);
  Use(EAUnitRes.TAbstractUnitResourceEditForm, nil);
  Use(EChangeSong.TChangeSongEditForm, nil);
  Use(EChangeSong.TChangeSongEditor, nil);
  Use(Ecity.TCityEditForm, nil);
  Use(Ecity.TCityEditor, nil);
  Use(EConstr.TPlayerConstructionEditForm, nil);
  Use(EConstr.TPlayerConstructionEditor, nil);
  Use(EDungeon.TDungeonEditForm, nil);
  Use(EDungeon.TDungeonEditor, nil);
  Use(EExplorS.TExplorationSiteEditForm, nil);
  Use(EExplorS.TExplorationSiteEditor, nil);
  Use(EFaceRes.TFaceResourceEditForm, nil);
  Use(EFaceRes.TFaceResourceEditor, nil);
  Use(EFarm.TFarmEditForm, nil);
  Use(EFarm.TFarmEditor, nil);
  Use(EFire.TFireEditForm, nil);
  Use(EFire.TFireEditor, nil);
  Use(EFlagEvent.TFlagEventEditForm, nil);
  Use(EFlagMsgEvent.TFlagMessageEventEditForm, nil);
  Use(EFlagMsgEvent.TFlagMessageEventEditor, nil);
  Use(EGems.TGemsEditForm, nil);
  Use(EGems.TGemsEditor, nil);
  Use(EHero.THeroEditForm, nil);
  Use(EHeroRes.THeroResourceEditForm, nil);
  Use(EHeroRes.THeroResourceEditor, nil);
  Use(EItem.TItemEditForm, nil);
  Use(EItemGFX.TItemGFXEditForm, nil);
  Use(EItemGFX.TItemGFXEditor, nil);
  Use(EItemHS.TItemHSEditForm, nil);
  Use(EItemHS.TItemHSEditor, nil);
  Use(EItemHS.TItemPlaceControl, nil);
  Use(EItmExpS.TItemExplorationSiteEditForm, nil);
  Use(EItmExpS.TItemExplorationSiteEditor, nil);
  Use(EManaC.TManaCrystalsEditForm, nil);
  Use(EManaC.TManaCrystalsEditor, nil);
  Use(EMoveOnEvent.TMoveOnEventForm, nil);
  Use(EPlaySample.TPlaySampleEditForm, nil);
  Use(EPlaySample.TPlaySampleEditor, nil);
  Use(EPoisonC.TPoisonCloudEditForm, nil);
  Use(EPoisonC.TPoisonCloudEditor, nil);
  Use(EProdP.TProductionPlaceEditForm, nil);
  Use(EProdP.TProductionPlaceEditor, nil);
  Use(ERaceRes.TRaceResourceEditForm, nil);
  Use(ERaceRes.TRaceResourceEditor, nil);
  Use(EShowMessage.TShowMessageEditForm, nil);
  Use(EShowMessage.TShowMessageEditor, nil);
  Use(ESign.TSignEditForm, nil);
  Use(ESign.TSignEditor, nil);
  Use(ESmokeC.TSmokeCloudEditForm, nil);
  Use(ESmokeC.TSmokeCloudEditor, nil);
  Use(ETCUnitPos.TTCUnitPositionEditForm, nil);
  Use(ETCUnitPos.TUnitPositionEditor, nil);
  Use(ETeleprt.TTeleportEditForm, nil);
  Use(ETeleprt.TTeleportEditor, nil);
  Use(ETutorialMessageEvent.TTutorialMessageEventEditForm, nil);
  Use(ETutorialMessageEvent.TTutorialMessageEventEditor, nil);
  Use(EUGFXGen.TUnitGFXGeneraterDlg, nil);
  Use(EUnitGFX.TEditStringGrid, nil);
  Use(EUnitGFX.TUnitGFXResourceEditForm, nil);
  Use(EUnitGFX.TUnitGFXResourceEditor, nil);
  Use(EUnitRes.TUnitResourceEditForm, nil);
  Use(EUnitRes.TUnitResourceEditor, nil);
  Use(EWizardsTower.TWizardsTowerEditForm, nil);
  Use(EWizardsTower.TWizardsTowerEditor, nil);
  Use(FaceSel.TFaceSelectionDlg, nil);
  Use(FontMod.TFontModule, nil);
  Use(GameSDlg.TGameSettingsDlg, nil);
  Use(HeroLibF.THeroLibraryEditForm, nil);
  Use(HSSetDlg.THSSetDialog, nil);
  Use(ItemFlt.TItemFloater, nil);
  Use(ItemLibF.TItemLibraryEditForm, nil);
  Use(ItemSel.TItemSelectionDlg, nil);
  Use(MapSDlg.TMapSettingsDlg, nil);
  Use(MDIForm.TMainForm, nil);
  Use(NewMapDialog.TNewMapDlg, nil);
  Use(PasswordDialog.TPasswordDlg, nil);
  Use(PlInfFlt.TPlayerInfoFloater, nil);
  Use(RAoWTer.TAoWTerrainResourceEditForm, nil);
  Use(RAoWTer.TAoWTerrainResourceEditor, nil);
  Use(RBridge.TBridgeResourceEditForm, nil);
  Use(RBridge.TBridgeResourceEditor, nil);
  Use(RCILTer.TCombatILTerrainResourceEditForm, nil);
  Use(RCILTer.TCombatILTerrainResourceEditor, nil);
  Use(RCity.TCityResourceEditForm, nil);
  Use(RCity.TCityResourceEditor, nil);
  Use(RConstr.TConstructionResourceEditForm, nil);
  Use(RConstr.TConstructionResourceEditor, nil);
  Use(RCTerrain.TCombatTerrainResourceEditForm, nil);
  Use(RCTerrain.TCombatTerrainResourceEditor, nil);
  Use(RDungeon.TDungeonResourceEditForm, nil);
  Use(RDungeon.TDungeonResourceEditor, nil);
  Use(ResEForm.TResourceEditForm, nil);
  Use(RExploreS.TExplorationSiteResourceEditForm, nil);
  Use(RExploreS.TExplorationSiteResourceEditor, nil);
  Use(RFire.TFireResourceEditForm, nil);
  Use(RFire.TFireResourceEditor, nil);
  Use(RHexagon.THexagonResourceEditForm, nil);
  Use(RHexagon.THexagonResourceEditor, nil);
  Use(RILTer.TILTerrainResourceEditForm, nil);
  Use(RILTer.TILTerrainResourceEditor, nil);
  Use(RIsoHex.TIsometricHexagonEditForm, nil);
  Use(RIsoHex.TIsometricHexagonResourceEditor, nil);
  Use(RMapObj.TMapObjectResourceEditForm, nil);
  Use(RMapObj.TMapObjectResourceEditor, nil);
  Use(RMultiHx.TMultiHexResourceEditForm, nil);
  Use(RMultiHx.TMultiHexResourceEditor, nil);
  Use(ROverlay.TOverlayObjectResourceEditForm, nil);
  Use(ROverlay.TOverlayObjectResourceEditor, nil);
  Use(RPad.TPadEditForm, nil);
  Use(RPad.TPadResourceEditor, nil);
  Use(RPlayerStructure.TPlayerStructureResourceEditForm, nil);
  Use(RPlayerStructure.TPlayerStructureResourceEditor, nil);
  Use(RProdP.TProdPlaceResEditForm, nil);
  Use(RProdP.TProductionPlaceResourceEditor, nil);
  Use(RRoad.TRoadResourceEditForm, nil);
  Use(RRoad.TRoadResourceEditor, nil);
  Use(RTerrain.TTerrainResourceEditForm, nil);
  Use(ScannerFlt.TScannerFloater, nil);
  Use(SelAbDlg.TAbilitySelectionDlg, nil);
  Use(Spin.TSpinButton, nil);
  Use(Spin.TSpinEdit, nil);
  Use(Spin.TTimerSpeedButton, nil);
  Use(SplashFrm.TSplashForm, nil);
  Use(TerTSFrm.TTerrainTypeSelectionForm, nil);
  Use(TextCtrlEd.TTextControlEditForm, nil);
  Use(TextEdDlg.TTextEditDlg, nil);
  Use(UnitFlt.TUnitFloater, nil);
  Use(ValidateMapDlg.TMapValidationDlg, nil);
  Use(nil, @AboutDialog.TAboutDlg.FormCreate);
  Use(nil, @AoWDlg.TAoWDialog.FormShow);
  Use(nil, @AoWEMod.TAoWEngineModule.AoWEngineModuleCreate);
  Use(nil, @AoWMapEF.TAoWMapEditForm.FormClose);
  Use(nil, @AoWMapEF.TAoWMapEditForm.FormShow);
  Use(nil, @AoWMapEF.TAoWMapEditForm.OKBtnClick);
  Use(nil, @EArmy.TArmyEditForm.FormCreate);
  Use(nil, @EArmy.TArmyEditForm.CloseBtnClick);
  Use(nil, @EArmy.TArmyEditForm.PlayerComboBoxChange);
  Use(nil, @EArmy.TArmyEditForm.BehaviourComboBoxChange);
  Use(nil, @EArmy.TArmyEditForm.FormShow);
  Use(nil, @EArmy.TArmyEditForm.FormDestroy);
  Use(nil, @EArmy.TArmyEditForm.AddBtnClick);
  Use(nil, @EArmy.TArmyEditForm.DeleteBtnClick);
  Use(nil, @EArmy.TArmyEditForm.UnitGridSelectCell);
  Use(nil, @EArmy.TArmyEditForm.EditBtnClick);
  Use(nil, @EArmy.TArmyEditForm.UnitGridDblClick);
  Use(nil, @EArmy.TArmyEditForm.DirectionChanged);
  Use(nil, @EAUnitRes.TAbstractUnitResourceEditForm.FormCreate);
  Use(nil, @EAUnitRes.TAbstractUnitResourceEditForm.UnitGFXBoxChange);
  Use(nil, @EAUnitRes.TAbstractUnitResourceEditForm.PreviewImagePanelDraw);
  Use(nil, @EChangeSong.TChangeSongEditForm.FormCreate);
  Use(nil, @EChangeSong.TChangeSongEditForm.FormDestroy);
  Use(nil, @EChangeSong.TChangeSongEditForm.SongCBChange);
  Use(nil, @EChangeSong.TChangeSongEditForm.PlaySongClick);
  Use(nil, @Ecity.TCityEditForm.FormCreate);
  Use(nil, @Ecity.TCityEditForm.RaceCBChange);
  Use(nil, @Ecity.TCityEditForm.RazedBoxClick);
  Use(nil, @Ecity.TCityEditForm.OKBtnClick);
  Use(nil, @Ecity.TCityEditForm.FormClose);
  Use(nil, @Ecity.TCityEditForm.PlayerComboBoxChange);
  Use(nil, @Ecity.TCityEditForm.DefendersCBChange);
  Use(nil, @EConstr.TPlayerConstructionEditForm.FormCreate);
  Use(nil, @EConstr.TPlayerConstructionEditForm.OKBtnClick);
  Use(nil, @EConstr.TPlayerConstructionEditForm.BorderPanelDraw);
  Use(nil, @EConstr.TPlayerConstructionEditForm.RazedBoxClick);
  Use(nil, @EDungeon.TDungeonEditForm.MainPageControlChange);
  Use(nil, @EDungeon.TDungeonEditForm.OKBtnClick);
  Use(nil, @EDungeon.TDungeonEditForm.PrisonersModeBoxChange);
  Use(nil, @EDungeon.TDungeonEditForm.AutoGeneratePrisBtnClick);
  Use(nil, @EDungeon.TDungeonEditForm.UserDefinedPrisBtnClick);
  Use(nil, @EDungeon.TDungeonEditForm.AddPrisBtnClick);
  Use(nil, @EDungeon.TDungeonEditForm.DeletePrisBtnClick);
  Use(nil, @EDungeon.TDungeonEditForm.FormCreate);
  Use(nil, @EDungeon.TDungeonEditForm.FormShow);
  Use(nil, @EExplorS.TExplorationSiteEditForm.AddBtnClick);
  Use(nil, @EExplorS.TExplorationSiteEditForm.DeleteBtnClick);
  Use(nil, @EExplorS.TExplorationSiteEditForm.MainPageControlChange);
  Use(nil, @EExplorS.TExplorationSiteEditForm.FormCreate);
  Use(nil, @EExplorS.TExplorationSiteEditForm.UserDefinedBtnClick);
  Use(nil, @EExplorS.TExplorationSiteEditForm.AutoGenerateBtnClick);
  Use(nil, @EExplorS.TExplorationSiteEditForm.FormDestroy);
  Use(nil, @EExplorS.TExplorationSiteEditForm.DefendersModeBoxChange);
  Use(nil, @EExplorS.TExplorationSiteEditForm.OKBtnClick);
  Use(nil, @EExplorS.TExplorationSiteEditForm.FormShow);
  Use(nil, @EExplorS.TExplorationSiteEditForm.BorderPanelDraw);
  Use(nil, @EFaceRes.TFaceResourceEditForm.FormCreate);
  Use(nil, @EFaceRes.TFaceResourceEditForm.OKBtnClick);
  Use(nil, @EFaceRes.TFaceResourceEditForm.ILManagerComboBoxChange);
  Use(nil, @EFaceRes.TFaceResourceEditForm.ImageIndexSpinUpdate);
  Use(nil, @EFaceRes.TFaceResourceEditForm.FormClose);
  Use(nil, @EFarm.TFarmEditForm.FormCreate);
  Use(nil, @EFire.TFireEditForm.FormCreate);
  Use(nil, @EFire.TFireEditForm.OKBtnClick);
  Use(nil, @EFlagEvent.TFlagEventEditForm.FormCreate);
  Use(nil, @EFlagEvent.TFlagEventEditForm.OKBtnClick);
  Use(nil, @EFlagMsgEvent.TFlagMessageEventEditForm.FormCreate);
  Use(nil, @EFlagMsgEvent.TFlagMessageEventEditForm.OKBtnClick);
  Use(nil, @EGems.TGemsEditForm.GemsSpinChange);
  Use(nil, @EGems.TGemsEditForm.FormCreate);
  Use(nil, @EGems.TGemsEditForm.OKBtnClick);
  Use(nil, @EGems.TGemsEditForm.AutoGenerateClick);
  Use(nil, @EGems.TGemsEditForm.UserDefinedClick);
  Use(nil, @EGems.TGemsEditForm.GenerateModeBoxChange);
  Use(nil, @EHero.THeroEditForm.FormCreate);
  Use(nil, @EHero.THeroEditForm.FormDestroy);
  Use(nil, @EHero.THeroEditForm.HeroResourceComboBoxChange);
  Use(nil, @EHero.THeroEditForm.EditFaceBtnClick);
  Use(nil, @EHero.THeroEditForm.PreviewImagePanelDraw);
  Use(nil, @EHero.THeroEditForm.OKBtnClick);
  Use(nil, @EHero.THeroEditForm.ResetBtnClick);
  Use(nil, @EHero.THeroEditForm.HeroLevelEditChange);
  Use(nil, @EHero.THeroEditForm.AttackEditChange);
  Use(nil, @EHero.THeroEditForm.DefenseEditChange);
  Use(nil, @EHero.THeroEditForm.ResistanceEditChange);
  Use(nil, @EHero.THeroEditForm.DamageEditChange);
  Use(nil, @EHero.THeroEditForm.HitsEditChange);
  Use(nil, @EHero.THeroEditForm.MovesEditChange);
  Use(nil, @EHero.THeroEditForm.AddBtnClick);
  Use(nil, @EHero.THeroEditForm.DeleteBtnClick);
  Use(nil, @EHero.THeroEditForm.AvailableAbBoxClick);
  Use(nil, @EHero.THeroEditForm.SelectedAbBoxClick);
  Use(nil, @EHero.THeroEditForm.AddItemBtnClick);
  Use(nil, @EHero.THeroEditForm.DeleteItemBtnClick);
  Use(nil, @EHero.THeroEditForm.MainPageControlChange);
  Use(nil, @EHero.THeroEditForm.NicknameEditChange);
  Use(nil, @EHero.THeroEditForm.NameEditChange);
  Use(nil, @EHero.THeroEditForm.ItemGridSelectCell);
  Use(nil, @EHero.THeroEditForm.BodyGridSelectCell);
  Use(nil, @EHero.THeroEditForm.BodyGridDblClick);
  Use(nil, @EHero.THeroEditForm.ItemGridDblClick);
  Use(nil, @EHero.THeroEditForm.SphereEditChange);
  Use(nil, @EHeroRes.THeroResourceEditForm.FormCreate);
  Use(nil, @EHeroRes.THeroResourceEditForm.FormDestroy);
  Use(nil, @EHeroRes.THeroResourceEditForm.AbilityBtnClick);
  Use(nil, @EHeroRes.THeroResourceEditForm.OKBtnClick);
  Use(nil, @EHeroRes.THeroResourceEditForm.LevelPointsChanged);
  Use(nil, @EHeroRes.THeroResourceEditForm.SelectFaceBtnClick);
  Use(nil, @EHeroRes.THeroResourceEditForm.FaceDrawPanelDraw);
  Use(nil, @EItem.TItemEditForm.FormCreate);
  Use(nil, @EItem.TItemEditForm.FormDestroy);
  Use(nil, @EItem.TItemEditForm.EditBtnClick);
  Use(nil, @EItem.TItemEditForm.PreviewImagePanelDraw);
  Use(nil, @EItem.TItemEditForm.ItemTypeBoxChange);
  Use(nil, @EItem.TItemEditForm.ItemNameEditChange);
  Use(nil, @EItem.TItemEditForm.DefenseChange);
  Use(nil, @EItem.TItemEditForm.ResistanceChange);
  Use(nil, @EItem.TItemEditForm.AttackChange);
  Use(nil, @EItem.TItemEditForm.DamageChange);
  Use(nil, @EItem.TItemEditForm.AvailabilityBoxChange);
  Use(nil, @EItem.TItemEditForm.AbilityBtnClick);
  Use(nil, @EItem.TItemEditForm.DescriptionEditChange);
  Use(nil, @EItem.TItemEditForm.CostEditChange);
  Use(nil, @EItem.TItemEditForm.SpellComboBoxChange);
  Use(nil, @EItemGFX.TItemGFXEditForm.FormCreate);
  Use(nil, @EItemGFX.TItemGFXEditForm.OKBtnClick);
  Use(nil, @EItemGFX.TItemGFXEditForm.ILManagerComboBoxChange);
  Use(nil, @EItemGFX.TItemGFXEditForm.ImageIndexSpinUpdate);
  Use(nil, @EItemGFX.TItemGFXEditForm.FormClose);
  Use(nil, @EItemHS.TItemHSEditForm.FormCreate);
  Use(nil, @EItemHS.TItemHSEditForm.FormShow);
  Use(nil, @EItemHS.TItemHSEditForm.FormDestroy);
  Use(nil, @EItemHS.TItemHSEditForm.AddItemBtnClick);
  Use(nil, @EItemHS.TItemHSEditForm.DeleteItemBtnClick);
  Use(nil, @EItemHS.TItemHSEditForm.GenerateItemBoxChange);
  Use(nil, @EItemHS.TItemHSEditForm.AutoGenerateItemsBtnClick);
  Use(nil, @EItemHS.TItemHSEditForm.UserDefinedItemsBtnClick);
  Use(nil, @EItemHS.TItemHSEditForm.OKBtnClick);
  Use(nil, @EItemHS.TItemHSEditForm.ItemGridDblClick);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.FormCreate);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.FormDestroy);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.MainPageControlChange);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.OKBtnClick);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.GenerateItemBoxChange);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.AutoGenerateItemsBtnClick);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.UserDefinedItemsBtnClick);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.AddItemBtnClick);
  Use(nil, @EItmExpS.TItemExplorationSiteEditForm.DeleteItemBtnClick);
  Use(nil, @EManaC.TManaCrystalsEditForm.ManaSpinChange);
  Use(nil, @EManaC.TManaCrystalsEditForm.OKBtnClick);
  Use(nil, @EManaC.TManaCrystalsEditForm.AutoGenerateClick);
  Use(nil, @EManaC.TManaCrystalsEditForm.UserDefinedClick);
  Use(nil, @EManaC.TManaCrystalsEditForm.GenerateModeBoxChange);
  Use(nil, @EMoveOnEvent.TMoveOnEventForm.FormCreate);
  Use(nil, @EMoveOnEvent.TMoveOnEventForm.OKBtnClick);
  Use(nil, @EPlaySample.TPlaySampleEditForm.FormCreate);
  Use(nil, @EPlaySample.TPlaySampleEditForm.PlaySongClick);
  Use(nil, @EPlaySample.TPlaySampleEditForm.OKBtnClick);
  Use(nil, @EPoisonC.TPoisonCloudEditForm.FormCreate);
  Use(nil, @EPoisonC.TPoisonCloudEditForm.OKBtnClick);
  Use(nil, @EProdP.TProductionPlaceEditForm.FormCreate);
  Use(nil, @EProdP.TProductionPlaceEditForm.PlayerComboBoxChange);
  Use(nil, @EProdP.TProductionPlaceEditForm.OKBtnClick);
  Use(nil, @ERaceRes.TRaceResourceEditForm.FormCreate);
  Use(nil, @ERaceRes.TRaceResourceEditForm.OKBtnClick);
  Use(nil, @ERaceRes.TRaceResourceEditForm.FormDestroy);
  Use(nil, @ERaceRes.TRaceResourceEditForm.AddBtnClick);
  Use(nil, @ERaceRes.TRaceResourceEditForm.DeleteBtnClick);
  Use(nil, @ERaceRes.TRaceResourceEditForm.FormShow);
  Use(nil, @ERaceRes.TRaceResourceEditForm.AddProdBtnClick);
  Use(nil, @ERaceRes.TRaceResourceEditForm.DeleteProdBtnClick);
  Use(nil, @ERaceRes.TRaceResourceEditForm.RaceColorBtnClick);
  Use(nil, @EShowMessage.TShowMessageEditForm.OKBtnClick);
  Use(nil, @EShowMessage.TShowMessageEditForm.FormCreate);
  Use(nil, @ESign.TSignEditForm.FormCreate);
  Use(nil, @ESign.TSignEditForm.OKBtnClick);
  Use(nil, @ESmokeC.TSmokeCloudEditForm.FormCreate);
  Use(nil, @ESmokeC.TSmokeCloudEditForm.OKBtnClick);
  Use(nil, @ETCUnitPos.TTCUnitPositionEditForm.FormCreate);
  Use(nil, @ETCUnitPos.TTCUnitPositionEditForm.DirectionChanged);
  Use(nil, @ETeleprt.TTeleportEditForm.FormCreate);
  Use(nil, @ETeleprt.TTeleportEditForm.BorderPanelDraw);
  Use(nil, @ETeleprt.TTeleportEditForm.OKBtnClick);
  Use(nil, @ETutorialMessageEvent.TTutorialMessageEventEditForm.FormCreate);
  Use(nil, @ETutorialMessageEvent.TTutorialMessageEventEditForm.OKBtnClick);
  Use(nil, @EUGFXGen.TUnitGFXGeneraterDlg.GenerateBtnClick);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.FormCreate);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.ILManagerComboBoxChange);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.LayerSpinUpdate);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.SequenceModeBoxChange);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.SequenceSpeedBoxChange);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.FrameTableEditChange);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.ImageSequencerChange);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.OpenLayerBtnClick);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.CloseLayerBtnClick);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.ImageIndexSelectorSelectCell);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.SequenceDisplayEditorStartUpdateFrame);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.SequenceDisplayEditorResizeBackSurface);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.ImageSequencerCreateImageSequence);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.UnitGFXNameEditChange);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.FaceIndexSpinUpdate);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.FaceILManagerComboBoxChange);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.GenerateBtnClick);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.MoveSpeedBoxChange);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.SequenceDisplayEditorShowImageSequence);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.EditStandstillSFXClick);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.EditMoveSFXClick);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.EditMeleeSFXClick);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.EditDieSFXClick);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.Button1Click);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.ImageIndexSelectorKeyDown);
  Use(nil, @EUnitGFX.TUnitGFXResourceEditForm.ChangeColorClick);
  Use(nil, @EUnitRes.TUnitResourceEditForm.FormCreate);
  Use(nil, @EUnitRes.TUnitResourceEditForm.FormDestroy);
  Use(nil, @EUnitRes.TUnitResourceEditForm.RaceBoxChange);
  Use(nil, @EUnitRes.TUnitResourceEditForm.AbilityBtnClick);
  Use(nil, @EUnitRes.TUnitResourceEditForm.OKBtnClick);
  Use(nil, @EUnitRes.TUnitResourceEditForm.AbilityRankTabsChange);
  Use(nil, @EWizardsTower.TWizardsTowerEditForm.FormCreate);
  Use(nil, @EWizardsTower.TWizardsTowerEditForm.OKBtnClick);
  Use(nil, @EWizardsTower.TWizardsTowerEditForm.CustomRBClick);
  Use(nil, @EWizardsTower.TWizardsTowerEditForm.BorderPanelDraw);
  Use(nil, @FaceSel.TFaceSelectionDlg.FacesGridCellUpdated);
  Use(nil, @FaceSel.TFaceSelectionDlg.FormCreate);
  Use(nil, @FaceSel.TFaceSelectionDlg.FormDeactivate);
  Use(nil, @FaceSel.TFaceSelectionDlg.OKBtnClick);
  Use(nil, @FontMod.TFontModule.FontModuleCreate);
  Use(nil, @GameSDlg.TGameSettingsDlg.FormCreate);
  Use(nil, @GameSDlg.TGameSettingsDlg.OKBtnClick);
  Use(nil, @GameSDlg.TGameSettingsDlg.GameTypeCBChange);
  Use(nil, @HeroLibF.THeroLibraryEditForm.FormShow);
  Use(nil, @HeroLibF.THeroLibraryEditForm.AddBtnClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.CopyBtnClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.LibraryCBChange);
  Use(nil, @HeroLibF.THeroLibraryEditForm.SortOnNameBtnClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.SortOnLevelClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.NewHeroClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.NewLibraryClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.DeleteLibraryClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.CloseBtnClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.EditHeroBtnClick);
  Use(nil, @HeroLibF.THeroLibraryEditForm.DeleteHeroClick);
  Use(nil, @HSSetDlg.THSSetDialog.FormCreate);
  Use(nil, @HSSetDlg.THSSetDialog.OKBtnClick);
  Use(nil, @ItemFlt.TItemFloater.FormShow);
  Use(nil, @ItemFlt.TItemFloater.FormHide);
  Use(nil, @ItemFlt.TItemFloater.ItemControlGridDblClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.AddBtnClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.CopyBtnClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.FormShow);
  Use(nil, @ItemLibF.TItemLibraryEditForm.LibraryCBChange);
  Use(nil, @ItemLibF.TItemLibraryEditForm.SortOnNamesBtnClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.SortOnTypeBtnClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.DeleteItemClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.NewLibraryClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.DeleteLibraryClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.CloseBtnClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.LibraryItemGridDblClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.EditItemBtnClick);
  Use(nil, @ItemLibF.TItemLibraryEditForm.NewItemClick);
  Use(nil, @ItemSel.TItemSelectionDlg.ItemGridCellUpdated);
  Use(nil, @ItemSel.TItemSelectionDlg.FormCreate);
  Use(nil, @ItemSel.TItemSelectionDlg.FormDeactivate);
  Use(nil, @ItemSel.TItemSelectionDlg.OKBtnClick);
  Use(nil, @MapSDlg.TMapSettingsDlg.FormCreate);
  Use(nil, @MapSDlg.TMapSettingsDlg.FormDestroy);
  Use(nil, @MapSDlg.TMapSettingsDlg.RaceListCheckBoxClickCheck);
  Use(nil, @MapSDlg.TMapSettingsDlg.PlayerCBChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.ObjectiveMemoChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.ExternalGoldIncomeEditChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.StartGoldEditChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.PlayerFixedClick);
  Use(nil, @MapSDlg.TMapSettingsDlg.PlayerRaceBoxChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.PlayerTypeBoxChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.BehaviorCBChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.StartManaEditChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.ExternalPowerIncomeEditChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.OKBtnClick);
  Use(nil, @MapSDlg.TMapSettingsDlg.AddSongClick);
  Use(nil, @MapSDlg.TMapSettingsDlg.DeleteSongClick);
  Use(nil, @MapSDlg.TMapSettingsDlg.ObjectiveBoxooClick);
  Use(nil, @MapSDlg.TMapSettingsDlg.NumberOfPlayersEditChange);
  Use(nil, @MapSDlg.TMapSettingsDlg.RelationGridSelectCell);
  Use(nil, @MapSDlg.TMapSettingsDlg.RelationGridDrawCell);
  Use(nil, @MapSDlg.TMapSettingsDlg.RelationGridMouseMove);
  Use(nil, @MapSDlg.TMapSettingsDlg.ChangePasswordBtnClick);
  Use(nil, @MapSDlg.TMapSettingsDlg.VictoryConditionClick);
  Use(nil, @MapSDlg.TMapSettingsDlg.FormCloseQuery);
  Use(nil, @MDIForm.TMainForm.FormCreate);
  Use(nil, @MDIForm.TMainForm.CutItemClick);
  Use(nil, @MDIForm.TMainForm.PasteItemClick);
  Use(nil, @MDIForm.TMainForm.CopyItemClick);
  Use(nil, @MDIForm.TMainForm.DeleteItemClick);
  Use(nil, @MDIForm.TMainForm.HSMEditUpdateFrame);
  Use(nil, @MDIForm.TMainForm.Brush1BtnClick);
  Use(nil, @MDIForm.TMainForm.Brush2BtnClick);
  Use(nil, @MDIForm.TMainForm.Brush3BtnClick);
  Use(nil, @MDIForm.TMainForm.OpenBtnClick);
  Use(nil, @MDIForm.TMainForm.SaveBtnClick);
  Use(nil, @MDIForm.TMainForm.CloseItemClick);
  Use(nil, @MDIForm.TMainForm.NewItemClick);
  Use(nil, @MDIForm.TMainForm.SaveAsItemClick);
  Use(nil, @MDIForm.TMainForm.ExitItemClick);
  Use(nil, @MDIForm.TMainForm.FormCloseQuery);
  Use(nil, @MDIForm.TMainForm.LevelDownBtnClick);
  Use(nil, @MDIForm.TMainForm.LevelUpBtnClick);
  Use(nil, @MDIForm.TMainForm.HSMEditDeactivate);
  Use(nil, @MDIForm.TMainForm.HSMEditActivate);
  Use(nil, @MDIForm.TMainForm.NewMapsetClick);
  Use(nil, @MDIForm.TMainForm.HSSEditActivate);
  Use(nil, @MDIForm.TMainForm.HSSEditDeactivate);
  Use(nil, @MDIForm.TMainForm.HSMEditUpdateCaption);
  Use(nil, @MDIForm.TMainForm.HSMEditShowMessage);
  Use(nil, @MDIForm.TMainForm.HSMEditStaticSceneUpdated);
  Use(nil, @MDIForm.TMainForm.DebugModeClick);
  Use(nil, @MDIForm.TMainForm.About1Click);
  Use(nil, @MDIForm.TMainForm.RaceGridLinkToResourceList);
  Use(nil, @MDIForm.TMainForm.MapSettingsClick);
  Use(nil, @MDIForm.TMainForm.UnitGFXGridLinkToResourceList);
  Use(nil, @MDIForm.TMainForm.UnitsGridLinkToResourceList);
  Use(nil, @MDIForm.TMainForm.PreviewBtnClick);
  Use(nil, @MDIForm.TMainForm.N640x480Click);
  Use(nil, @MDIForm.TMainForm.N800x600Click);
  Use(nil, @MDIForm.TMainForm.N1024x768Click);
  Use(nil, @MDIForm.TMainForm.N1280x1024Click);
  Use(nil, @MDIForm.TMainForm.HSMEditMouseMove);
  Use(nil, @MDIForm.TMainForm.HeroGridLinkToResourceList);
  Use(nil, @MDIForm.TMainForm.ItemResourceGridLinkToResourceList);
  Use(nil, @MDIForm.TMainForm.FaceGridLinkToResourceList);
  Use(nil, @MDIForm.TMainForm.UnitTabControlSelectUnit);
  Use(nil, @MDIForm.TMainForm.SortNameBtnClick);
  Use(nil, @MDIForm.TMainForm.SortLevelBtnClick);
  Use(nil, @MDIForm.TMainForm.OpenHeroLibraryClick);
  Use(nil, @MDIForm.TMainForm.SortItemsNameClick);
  Use(nil, @MDIForm.TMainForm.SortTypeBtnClick);
  Use(nil, @MDIForm.TMainForm.HeroControlGridSelectCell);
  Use(nil, @MDIForm.TMainForm.DeleteHeroBtnClick);
  Use(nil, @MDIForm.TMainForm.RemoveFromMapClick);
  Use(nil, @MDIForm.TMainForm.DeleteItemBtnClick);
  Use(nil, @MDIForm.TMainForm.RemoveItemClick);
  Use(nil, @MDIForm.TMainForm.RemoveLeaderFromMapClick);
  Use(nil, @MDIForm.TMainForm.OpenItemLibraryClick);
  Use(nil, @MDIForm.TMainForm.NewItemBtnClick);
  Use(nil, @MDIForm.TMainForm.EditItemClick);
  Use(nil, @MDIForm.TMainForm.NewHeroBtnClick);
  Use(nil, @MDIForm.TMainForm.WaterBtnClick);
  Use(nil, @MDIForm.TMainForm.GrassBtnClick);
  Use(nil, @MDIForm.TMainForm.SteppeBtnClick);
  Use(nil, @MDIForm.TMainForm.DesertBtnClick);
  Use(nil, @MDIForm.TMainForm.WastelandBtnClick);
  Use(nil, @MDIForm.TMainForm.SnowBtnClick);
  Use(nil, @MDIForm.TMainForm.IceBtnClick);
  Use(nil, @MDIForm.TMainForm.RoadBtnClick);
  Use(nil, @MDIForm.TMainForm.EraseBtnClick);
  Use(nil, @MDIForm.TMainForm.SelectHSBtnClick);
  Use(nil, @MDIForm.TMainForm.HSMEditSelectPlaceHS);
  Use(nil, @MDIForm.TMainForm.OverrideBtnClick);
  Use(nil, @MDIForm.TMainForm.ChangeTerrainBtnClick);
  Use(nil, @MDIForm.TMainForm.uWaterBtnClick);
  Use(nil, @MDIForm.TMainForm.DirtBtnClick);
  Use(nil, @MDIForm.TMainForm.LavaBtnClick);
  Use(nil, @MDIForm.TMainForm.uIceBtnClick);
  Use(nil, @MDIForm.TMainForm.EarthBtnClick);
  Use(nil, @MDIForm.TMainForm.RockBtnClick);
  Use(nil, @MDIForm.TMainForm.ArmyBtnClick);
  Use(nil, @MDIForm.TMainForm.ItemBtnClick);
  Use(nil, @MDIForm.TMainForm.EditHeroClick);
  Use(nil, @MDIForm.TMainForm.ItemControlGridSelectCell);
  Use(nil, @MDIForm.TMainForm.HSMEditDeselectPlaceHS);
  Use(nil, @MDIForm.TMainForm.OpenMapSetClick);
  Use(nil, @MDIForm.TMainForm.ExportTextClick);
  Use(nil, @MDIForm.TMainForm.ImportTextClick);
  Use(nil, @MDIForm.TMainForm.MapSetSettingsClick);
  Use(nil, @MDIForm.TMainForm.LeaderSelectionGridSelectCell);
  Use(nil, @MDIForm.TMainForm.FogofWarClick);
  Use(nil, @MDIForm.TMainForm.PlayerInfoClick);
  Use(nil, @MDIForm.TMainForm.RemoveMapLevelClick);
  Use(nil, @MDIForm.TMainForm.AddMapLevelClick);
  Use(nil, @MDIForm.TMainForm.FormShow);
  Use(nil, @MDIForm.TMainForm.SpellListBoxClick);
  Use(nil, @MDIForm.TMainForm.AbilityListBoxClick);
  Use(nil, @MDIForm.TMainForm.AbilitySelectionCLBClickCheck);
  Use(nil, @MDIForm.TMainForm.AbilityLevelPointsChange);
  Use(nil, @MDIForm.TMainForm.AbilityDescriptionChange);
  Use(nil, @MDIForm.TMainForm.EditAbilityTextClick);
  Use(nil, @MDIForm.TMainForm.SpellDescriptionChange);
  Use(nil, @MDIForm.TMainForm.EditSpellTextClick);
  Use(nil, @MDIForm.TMainForm.SphereEditChange);
  Use(nil, @MDIForm.TMainForm.SphereLevelEditChange);
  Use(nil, @MDIForm.TMainForm.SpellManaChange);
  Use(nil, @MDIForm.TMainForm.SpellResearchPointsChange);
  Use(nil, @MDIForm.TMainForm.SpellUpkeepChange);
  Use(nil, @MDIForm.TMainForm.EditAbilitySFXBtnClick);
  Use(nil, @MDIForm.TMainForm.EditSpellSFXClick);
  Use(nil, @MDIForm.TMainForm.GotoItemClick);
  Use(nil, @MDIForm.TMainForm.ItemControlGridUnselect);
  Use(nil, @MDIForm.TMainForm.HeroControlGridUnselect);
  Use(nil, @MDIForm.TMainForm.GoToHeroClick);
  Use(nil, @MDIForm.TMainForm.GoToLeaderClick);
  Use(nil, @MDIForm.TMainForm.ValidateMapBtnClick);
  Use(nil, @MDIForm.TMainForm.NewCombatMapClick);
  Use(nil, @MDIForm.TMainForm.LinkToCombatResources);
  Use(nil, @MDIForm.TMainForm.UnitPositionBtnClick);
  Use(nil, @MDIForm.TMainForm.BorderBtnClick);
  Use(nil, @MDIForm.TMainForm.EditAnimationsClick);
  Use(nil, @MDIForm.TMainForm.AbGFXEditClick);
  Use(nil, @MDIForm.TMainForm.EditSpellGFXClick);
  Use(nil, @MDIForm.TMainForm.ScannerItemClick);
  Use(nil, @MDIForm.TMainForm.EditTextBtnClick);
  Use(nil, @MDIForm.TMainForm.EditLeaderClick);
  Use(nil, @MDIForm.TMainForm.HeroPopupMenuPopup);
  Use(nil, @MDIForm.TMainForm.ItemPopupMenuPopup);
  Use(nil, @MDIForm.TMainForm.GameSettingsClick);
  Use(nil, @MDIForm.TMainForm.ExportAbilityInfoClick);
  Use(nil, @MDIForm.TMainForm.HSMEditActivateDC);
  Use(nil, @MDIForm.TMainForm.RemoveLeadersMIClick);
  Use(nil, @MDIForm.TMainForm.MapTextEditorMIClick);
  Use(nil, @MDIForm.TMainForm.ExportForMultilizerClick);
  Use(nil, @MDIForm.TMainForm.HSMEditKeyDown);
  Use(nil, @NewMapDialog.TNewMapDlg.OKBtnClick);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.PlayerInfoMapControlActivateHSM);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.PlayerInfoMapControlDeactivateHSM);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.FormShow);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.PlayerInfoMapControlGemsChanged);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.PlayerInfoMapControlUpkeepChanged);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.PlayerInfoMapControlIncomeChanged);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.PlayerInfoMapControlStructureChanged);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.PlayerComboBoxChange);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.StructureGridDblClick);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.PlayerInfoMapControlMapSettingsChanged);
  Use(nil, @PlInfFlt.TPlayerInfoFloater.FormClose);
  Use(nil, @RAoWTer.TAoWTerrainResourceEditForm.FormCreate);
  Use(nil, @RAoWTer.TAoWTerrainResourceEditForm.CombatTerrainTagBoxChange);
  Use(nil, @RCILTer.TCombatILTerrainResourceEditForm.FormCreate);
  Use(nil, @RCILTer.TCombatILTerrainResourceEditForm.CloseBtnClick);
  Use(nil, @RCILTer.TCombatILTerrainResourceEditForm.CityWallDirectionEditUpdate);
  Use(nil, @RCity.TCityResourceEditForm.ComplexBoxClick);
  Use(nil, @RConstr.TConstructionResourceEditForm.LoopBoxClick);
  Use(nil, @RConstr.TConstructionResourceEditForm.PlaySampleClick);
  Use(nil, @RConstr.TConstructionResourceEditForm.SFXManagerBoxChange);
  Use(nil, @RConstr.TConstructionResourceEditForm.CloseBtnClick);
  Use(nil, @RConstr.TConstructionResourceEditForm.CombatTerrainTagEditChange);
  Use(nil, @RConstr.TConstructionResourceEditForm.AddRazeDefenderClick);
  Use(nil, @RConstr.TConstructionResourceEditForm.DeleteRazeDefenderClick);
  Use(nil, @RConstr.TConstructionResourceEditForm.MainPageControlChange);
  Use(nil, @RConstr.TConstructionResourceEditForm.FormHide);
  Use(nil, @RCTerrain.TCombatTerrainResourceEditForm.FormCreate);
  Use(nil, @RDungeon.TDungeonResourceEditForm.MainPageControlChange);
  Use(nil, @RDungeon.TDungeonResourceEditForm.AddPrisonerClick);
  Use(nil, @RDungeon.TDungeonResourceEditForm.DeletePrisonersClick);
  Use(nil, @RDungeon.TDungeonResourceEditForm.FormCreate);
  Use(nil, @ResEForm.TResourceEditForm.FormClose);
  Use(nil, @RExploreS.TExplorationSiteResourceEditForm.FormCreate);
  Use(nil, @RExploreS.TExplorationSiteResourceEditForm.MainPageControlChange);
  Use(nil, @RExploreS.TExplorationSiteResourceEditForm.FormDestroy);
  Use(nil, @RExploreS.TExplorationSiteResourceEditForm.AddDefenderClick);
  Use(nil, @RExploreS.TExplorationSiteResourceEditForm.DeleteDefenderClick);
  Use(nil, @RFire.TFireResourceEditForm.FireTypeBoxChange);
  Use(nil, @RFire.TFireResourceEditForm.FormCreate);
  Use(nil, @RHexagon.THexagonResourceEditForm.FormCreate);
  Use(nil, @RIsoHex.TIsometricHexagonEditForm.FormCreate);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.FormCreate);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.FormClose);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.CloseBtnClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.CancelBtnClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.MORComboBoxChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ComplexBoxClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.TerrainComboBoxChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.OverlayComboBoxChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.LevelBoxChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.NameEditChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.LoadImageSetBtnClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ImageIndexSelectorDrawCell);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.PreviewFramesEditChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.MainPageControlChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.DisplayKeyDown);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.DisplayUpdateFrame);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.FrameTableEditChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ILManagerComboBoxChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ImageSequencerChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ImageSequencerCreateImageSequence);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.LayerSpinUpdate);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.SequenceDisplayEditorResizeBackSurface);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.SequenceDisplayEditorUpdateFrame);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.SequenceModeBoxChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.SequenceSpeedBoxChange);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.SequenceDisplayEditorActivateDC);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.OpenLayerBtnClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.CloseLayerBtnClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ImageIndexSelectorSelectCell);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.PlayBtnClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.PlayLoopedClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ChangeBKColorClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ExEditClick);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ImageIndexSelectorKeyDown);
  Use(nil, @RMapObj.TMapObjectResourceEditForm.ResourceIDEditChange);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.DisplayUpdateFrame);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.DisplayMouseDown);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.DisplayMouseMove);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.DisplayMouseUp);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.SelectBtnClick);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.DragBtnClick);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.MainPBtnClick);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.TerrainComboBoxChange);
  Use(nil, @RMultiHx.TMultiHexResourceEditForm.ComplexBoxClick);
  Use(nil, @ROverlay.TOverlayObjectResourceEditForm.CombatTerrainTagEditChange);
  Use(nil, @RProdP.TProdPlaceResEditForm.FormCreate);
  Use(nil, @RProdP.TProdPlaceResEditForm.FormDestroy);
  Use(nil, @RProdP.TProdPlaceResEditForm.AddBtnClick);
  Use(nil, @RProdP.TProdPlaceResEditForm.DeleteBtnClick);
  Use(nil, @RProdP.TProdPlaceResEditForm.MainPageControlChange);
  Use(nil, @RProdP.TProdPlaceResEditForm.CloseBtnClick);
  Use(nil, @RTerrain.TTerrainResourceEditForm.TerrainComboBoxChange);
  Use(nil, @RTerrain.TTerrainResourceEditForm.FormCreate);
  Use(nil, @RTerrain.TTerrainResourceEditForm.DecorationComboBoxChange);
  Use(nil, @ScannerFlt.TScannerFloater.DisplayResize);
  Use(nil, @ScannerFlt.TScannerFloater.DisplayMouseDown);
  Use(nil, @ScannerFlt.TScannerFloater.DisplayMouseMove);
  Use(nil, @ScannerFlt.TScannerFloater.DisplayMouseUp);
  Use(nil, @ScannerFlt.TScannerFloater.TheMapMapChanged);
  Use(nil, @ScannerFlt.TScannerFloater.DisplayBltSurface);
  Use(nil, @ScannerFlt.TScannerFloater.FormClose);
  Use(nil, @ScannerFlt.TScannerFloater.TheMapViewPortChange);
  Use(nil, @ScannerFlt.TScannerFloater.ScannerChangeTileBox);
  Use(nil, @ScannerFlt.TScannerFloater.TheMapScannerIconsChanged);
  Use(nil, @SelAbDlg.TAbilitySelectionDlg.AddBtnClick);
  Use(nil, @SelAbDlg.TAbilitySelectionDlg.DeleteBtnClick);
  Use(nil, @SelAbDlg.TAbilitySelectionDlg.FormShow);
  Use(nil, @SelAbDlg.TAbilitySelectionDlg.AvailableAbBoxClick);
  Use(nil, @SelAbDlg.TAbilitySelectionDlg.SelectedAbBoxClick);
  Use(nil, @SplashFrm.TSplashForm.FormKeyDown);
  Use(nil, @SplashFrm.TSplashForm.Image1Click);
  Use(nil, @SplashFrm.TSplashForm.FormCreate);
  Use(nil, @TextCtrlEd.TTextControlEditForm.TextIDEditChange);
  Use(nil, @TextCtrlEd.TTextControlEditForm.NewTextClick);
  Use(nil, @TextCtrlEd.TTextControlEditForm.DeleteTextClick);
  Use(nil, @TextCtrlEd.TTextControlEditForm.FindTextClick);
  Use(nil, @TextCtrlEd.TTextControlEditForm.TextMemoChange);
  Use(nil, @TextCtrlEd.TTextControlEditForm.TextScrollBarChange);
  Use(nil, @TextCtrlEd.TTextControlEditForm.DescriptionEditChange);
  Use(nil, @UnitFlt.TUnitFloater.HeroControlGridSelectCell);
  Use(nil, @UnitFlt.TUnitFloater.HeroSelectionSheetEnter);
  Use(nil, @UnitFlt.TUnitFloater.FormShow);
  Use(nil, @UnitFlt.TUnitFloater.MapControlActivateHSM);
  Use(nil, @UnitFlt.TUnitFloater.MapControlDeactivateHSM);
end.
