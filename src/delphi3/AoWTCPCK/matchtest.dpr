program matchtest;

{ Host program for the byte-matching of AoWTCPCK.dpl: it references every class and every
  non-virtual method so that the linker keeps them; it is linked, never run. Build from this
  directory with the original compiler into a directory with a short path (DCC32 crashes on
  long paths):
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -Q "-U..\AoWEPACK;..\HSEPack;..;..\Gfxepack;..\Ilpack;..\Dcpack;..\SoundP;..\Network;..\aowFXpck;..\aowInt;..\Localize"
      -O.. -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  AoWTC in 'AoWTC.pas',
  AoWTCPCK in 'AoWTCPCK.pas',
  AoWTCReg in 'AoWTCReg.pas',
  CMapCtrl in 'CMapCtrl.pas',
  CenterViewLoc in 'CenterViewLoc.pas',
  CityWall in 'CityWall.pas',
  CombatFire in 'CombatFire.pas',
  CombatHex in 'CombatHex.pas',
  CombatILTer in 'CombatILTer.pas',
  CombatObstacle in 'CombatObstacle.pas',
  CombatRoad in 'CombatRoad.pas',
  CombatStructure in 'CombatStructure.pas',
  CombatTE in 'CombatTE.pas',
  CombatTerrain in 'CombatTerrain.pas',
  FleeLoc in 'FleeLoc.pas',
  House in 'House.pas',
  IsoCombatHex in 'IsoCombatHex.pas',
  MainStructure in 'MainStructure.pas',
  OverviewUnit in 'OverviewUnit.pas',
  SingleCombatHex in 'SingleCombatHex.pas',
  Townhall in 'Townhall.pas',
  WorkShop in 'WorkShop.pas';

var
  C: TClass;
  P: Pointer;

procedure Use(C: TClass; P: Pointer);
begin
  Writeln(Integer(C), Integer(P));
end;

begin
  Use(AoWTC.TTCAbility, nil);
  Use(AoWTC.TROb, nil);
  Use(AoWTC.TAoWNewCombatMapSettings, nil);
  Use(AoWTC.TaiMove, nil);
  Use(AoWTC.TCAI, nil);
  Use(AoWTC.TAoWCombatMapField, nil);
  Use(AoWTC.TAoWCombatMapLevel, nil);
  Use(AoWTC.TRangedPathHS, nil);
  Use(AoWTC.TfxHS, nil);
  Use(AoWTC.TCItemHS, nil);
  Use(AoWTC.TUnitPositionHS, nil);
  Use(AoWTC.TCBloodHS, nil);
  Use(AoWTC.TCCorpseHS, nil);
  Use(AoWTC.TCOozeHS, nil);
  Use(AoWTC.TUnitPositionControl, nil);
  Use(AoWTC.TCombatMoveControlSettings, nil);
  Use(AoWTC.TCombatMoveControl, nil);
  Use(AoWTC.TTacticalCombatUnit, nil);
  Use(AoWTC.TTacticalCombatUnitHS, nil);
  Use(AoWTC.TCombatUnitSelectionControl, nil);
  Use(AoWTC.TTacticalCombatPlayer, nil);
  Use(AoWTC.TTacticalCombatPlayerList, nil);
  Use(AoWTC.TAoWCombatMapMouse, nil);
  Use(AoWTC.TAoWCombatMap, nil);
  Use(AoWTC.TTacticalCombat, nil);
  Use(AoWTC.TRndTacHsm, nil);
  Use(CMapCtrl.TAoWCombatMapControl, nil);
  Use(CenterViewLoc.TCenterViewLocation, nil);
  Use(CenterViewLoc.TCenterViewLocationResource, nil);
  Use(CityWall.TCityWall, nil);
  Use(CityWall.TCityWallResource, nil);
  Use(CityWall.TCityWallDoor, nil);
  Use(CityWall.TCityWallDoorResource, nil);
  Use(CombatFire.TCombatFire, nil);
  Use(CombatFire.TCombatFireResource, nil);
  Use(CombatHex.TCombatHexagon, nil);
  Use(CombatHex.TCombatHexagonResource, nil);
  Use(CombatHex.TWaterCombatHexagon, nil);
  Use(CombatHex.TWaterCombatHexagonResource, nil);
  Use(CombatILTer.TCombatILTerrainShadow, nil);
  Use(CombatILTer.TCombatILTerrain, nil);
  Use(CombatILTer.TCombatILTerrainResource, nil);
  Use(CombatILTer.TCombatFixedILTerrain, nil);
  Use(CombatILTer.TCombatFixedILTerrainResource, nil);
  Use(CombatObstacle.TCombatObstacleShadow, nil);
  Use(CombatObstacle.TCombatObstacleOverlay, nil);
  Use(CombatObstacle.TCombatObstacle, nil);
  Use(CombatObstacle.TCombatObstacleResource, nil);
  Use(CombatRoad.TCombatRoad, nil);
  Use(CombatRoad.TCombatRoadResource, nil);
  Use(CombatStructure.TCombatStructure, nil);
  Use(CombatStructure.TCombatStructureResource, nil);
  Use(CombatTE.TCEndTurnTE, nil);
  Use(CombatTE.TCEndCombatTE, nil);
  Use(CombatTE.TCombatMoveTE, nil);
  Use(CombatTE.TCMeleeMoveTE, nil);
  Use(CombatTE.TCAbTouchMoveTE, nil);
  Use(CombatTE.TCAbRangedTE, nil);
  Use(CombatTE.TTerminateCombatTE, nil);
  Use(CombatTerrain.TCombatTerrainShadow, nil);
  Use(CombatTerrain.TCombatTerrain, nil);
  Use(CombatTerrain.TCombatTerrainResource, nil);
  Use(FleeLoc.TFleeLocation, nil);
  Use(FleeLoc.TFleeLocationResource, nil);
  Use(FleeLoc.TMovementHS, nil);
  Use(House.THouse, nil);
  Use(House.THouseResource, nil);
  Use(IsoCombatHex.TIsometricCombatHexagon, nil);
  Use(IsoCombatHex.TIsometricCombatHexagonResource, nil);
  Use(MainStructure.TMainStructure, nil);
  Use(MainStructure.TMainStructureResource, nil);
  Use(OverviewUnit.TOverviewUnitHS, nil);
  Use(SingleCombatHex.TSingleCombatHexagon, nil);
  Use(SingleCombatHex.TSingleCombatHexagonResource, nil);
  Use(Townhall.TTownhall, nil);
  Use(Townhall.TTownhallResource, nil);
  Use(WorkShop.TWorkshop, nil);
  Use(WorkShop.TWorkshopResource, nil);
  Use(nil, @AoWTC.TAoWNewCombatMapSettings.Create);
  Use(nil, @AoWTC.TCAI.Create);
  Use(nil, @AoWTC.TCAI.Reset);
  Use(nil, @AoWTC.TCAI.BeginTurn);
  Use(nil, @AoWTC.TCAI.ContinueTurn);
  Use(nil, @AoWTC.TCAI.CreateMove);
  Use(nil, @AoWTC.TCAI.tcDVtoDEV);
  Use(nil, @AoWTC.TCAI.ChargeFromPos);
  Use(nil, @AoWTC.TCAI.UnitSafe);
  Use(nil, @AoWTC.TCAI.MakeTerrainPath);
  Use(nil, @AoWTC.TCAI.MultDEV);
  Use(nil, @AoWTC.TCAI.EvalAll);
  Use(nil, @AoWTC.TCAI.EvalHex);
  Use(nil, @AoWTC.TCAI.EvalArea);
  Use(nil, @AoWTC.TCAI.EvalPath);
  Use(nil, @AoWTC.TCAI.EvalBreath);
  Use(nil, @AoWTC.TCAI.CheckUnit);
  Use(nil, @AoWTC.TCAI.EvalBattle);
  Use(nil, @AoWTC.TAoWCombatMapField.GetDefenseValue);
  Use(nil, @AoWTC.TfxHS.NewFrame);
  Use(nil, @AoWTC.TUnitPositionHS.UpdateImageIndex);
  Use(nil, @AoWTC.TCCorpseHS.NewFrame);
  Use(nil, @AoWTC.TUnitPositionControl.GetUnitPosition);
  Use(nil, @AoWTC.TUnitPositionControl.SetUnitPosition);
  Use(nil, @AoWTC.TUnitPositionControl.ValidatePosition);
  Use(nil, @AoWTC.TTacticalCombatUnit.GetPosValue);
  Use(nil, @AoWTC.TTacticalCombatUnit.MovedTo);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.Initialize);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.NewFrame);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.MeleeMoveTC);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.SelectAbility);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.SelectSpell);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.CreateTCAbList);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.ListAbilities);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.SetAction);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.AbTouchMoveTC);
  Use(nil, @AoWTC.TTacticalCombatUnitHS.AbRangedTC);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.Create);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.AddUnit);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.GetTCUnitHS);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.GetMoveTypes);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.RectangleSelectEvent);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.MoveSelectionEvent);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.CalculateRangedPath);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.MoveSelectedRoute);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.MoveUnits);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.ExecuteMoveSelection);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.ValidMultiMoveSelection);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.ActivateMoveSelection);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.DeactivateMoveSelection);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.Update);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.SetTCUnitHS);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.Select);
  Use(nil, @AoWTC.TCombatUnitSelectionControl.DeactivateRangedPath);
  Use(nil, @AoWTC.TTacticalCombatPlayer.SetAuto);
  Use(nil, @AoWTC.TTacticalCombatPlayerList.GetCount);
  Use(nil, @AoWTC.TTacticalCombatPlayerList.GetPlayers);
  Use(nil, @AoWTC.TAoWCombatMap.SetCombat);
  Use(nil, @AoWTC.TAoWCombatMap.MouseMoveEvent);
  Use(nil, @AoWTC.TAoWCombatMap.SetSeatedCombatPlayer);
  Use(nil, @AoWTC.TAoWCombatMap.NewTurn);
  Use(nil, @AoWTC.TAoWCombatMap.DrawMoveRoute);
  Use(nil, @AoWTC.TAoWCombatMap.EndTurn);
  Use(nil, @AoWTC.TAoWCombatMap.CancelEndTurn);
  Use(nil, @AoWTC.TAoWCombatMap.GetEndTurnStatus);
  Use(nil, @AoWTC.TAoWCombatMap.GetNextUnit);
  Use(nil, @AoWTC.TAoWCombatMap.AddEffect);
  Use(nil, @AoWTC.TAoWCombatMap.UpdateCursor);
  Use(nil, @AoWTC.TAoWCombatMap.EndCombat);
  Use(nil, @AoWTC.TAoWCombatMap.SelectNextUnit);
  Use(nil, @AoWTC.TAoWCombatMap.GetUnitLocation);
  Use(nil, @AoWTC.TAoWCombatMap.Surrender);
  Use(nil, @AoWTC.TTacticalCombat.ValidateWallCombat);
  Use(nil, @AoWTC.TRndTacHsm.Create);
  Use(nil, @AoWTC.TRndTacHsm.RandomMap);
  Use(nil, @AoWTC.TRndTacHsm.PlaceCombatUnits);
  Use(nil, @AoWTC.TRndTacHsm.SetupUnit);
  Use(nil, @AoWTC.TRndTacHsm.InitTables);
  Use(nil, @AoWTC.MakeAbilPath);
  Use(nil, @AoWTC.MakeRangedPath);
  Use(nil, @AoWTC.RegisterAoWTCClasses);
  Use(nil, @AoWTC.GetMeleeDirIndex);
  Use(nil, @AoWTC.GetRangedDirIndex);
  Use(nil, @AoWTCPCK.GetPackageInfoTable);
  Use(nil, @AoWTCPCK.PackageLoad);
  Use(nil, @AoWTCPCK.PackageUnload);
  Use(nil, @AoWTCReg.RegisterTacticalCombat);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.LinkToHSM);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.ReleaseHSM);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.ActivateHSM);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.DeactivateHSM);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.MapChanged);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.SelectHS);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.DeselectHS);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.MouseOverTarget);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.UnitChanged);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.PlayerChanged);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.SeatedPlayerChanged);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.GemsChanged);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.IncomeChanged);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.UpkeepChanged);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.ShowMessage);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.ChangeTurn);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.LogbookChanged);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.ExecuteEventLog);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.ActivateMap);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.DeactivateMap);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.CastSpell);
  Use(nil, @CMapCtrl.TAoWCombatMapControl.ActivateAbility);
  Use(nil, @CMapCtrl.Register);
  Use(nil, @CenterViewLoc.RegisterCenterViewLocation);
  Use(nil, @CityWall.TCityWall.GetDirection);
  Use(nil, @CityWall.TCityWall.GetDefense);
  Use(nil, @CityWall.TCityWall.SetHitPoints);
  Use(nil, @CityWall.RegisterCityWall);
  Use(nil, @CombatFire.TCombatFire.NewTurn);
  Use(nil, @CombatFire.CreateFire);
  Use(nil, @CombatFire.RegisterCombatFire);
  Use(nil, @CombatHex.TCombatHexagon.UpdateTransition);
  Use(nil, @CombatHex.RegisterCombatHexagon);
  Use(nil, @CombatILTer.TCombatILTerrain.GetDefense);
  Use(nil, @CombatILTer.TCombatILTerrain.GetBurnValue);
  Use(nil, @CombatILTer.TCombatILTerrain.DestroyShadow);
  Use(nil, @CombatILTer.TCombatILTerrain.CreateShadow);
  Use(nil, @CombatILTer.RegisterCombatILTerrain);
  Use(nil, @CombatObstacle.TCombatObstacle.CreateShadow);
  Use(nil, @CombatObstacle.TCombatObstacle.DestroyShadow);
  Use(nil, @CombatObstacle.TCombatObstacle.CreateOverlay);
  Use(nil, @CombatObstacle.TCombatObstacle.DestroyOverlay);
  Use(nil, @CombatObstacle.TCombatObstacle.ShowShadow);
  Use(nil, @CombatObstacle.TCombatObstacle.ShowOverlay);
  Use(nil, @CombatObstacle.RegisterCombatObstacle);
  Use(nil, @CombatRoad.TCombatRoad.UpdateTransition);
  Use(nil, @CombatRoad.RegisterCombatRoad);
  Use(nil, @CombatStructure.TCombatStructure.SetHitPoints);
  Use(nil, @CombatTE.TCombatMoveTE.ExecuteDefaultMove);
  Use(nil, @CombatTE.TCMeleeMoveTE.NextStrike);
  Use(nil, @CombatTE.TCMeleeMoveTE.ExecuteStrike);
  Use(nil, @CombatTE.TCAbRangedTE.NextStrike);
  Use(nil, @CombatTE.MakeDEHSList);
  Use(nil, @CombatTE.CreateTCEndCombatTE);
  Use(nil, @CombatTE.CreateTCEndTurnTE);
  Use(nil, @CombatTE.CreateTCCancelEndTurnTE);
  Use(nil, @CombatTE.MakeHitBlood);
  Use(nil, @CombatTE.CreateTCMeleeMoveTE);
  Use(nil, @CombatTE.CreateTCAbTouchMoveTE);
  Use(nil, @CombatTE.CreateTCAbRangedTE);
  Use(nil, @CombatTE.CreateCombatMoveTE);
  Use(nil, @CombatTE.MoveCombatUnit);
  Use(nil, @CombatTE.SetupMultiTCUnitMove);
  Use(nil, @CombatTE.RegisterCombatTE);
  Use(nil, @CombatTerrain.TCombatTerrain.DestroyShadow);
  Use(nil, @CombatTerrain.TCombatTerrain.CreateShadow);
  Use(nil, @CombatTerrain.TCombatTerrain.SetHitPoints);
  Use(nil, @CombatTerrain.TCombatTerrain.ShowShadow);
  Use(nil, @CombatTerrain.RegisterCombatTerrain);
  Use(nil, @FleeLoc.TFleeLocation.NewFrame);
  Use(nil, @FleeLoc.RegisterFleeLocation);
  Use(nil, @House.RegisterHouse);
  Use(nil, @IsoCombatHex.RegisterIsometricCombatHexagon);
  Use(nil, @MainStructure.RegisterMainStructure);
  Use(nil, @OverviewUnit.TOverviewUnitHS.SetU);
  Use(nil, @OverviewUnit.PlaceOverviewUnit);
  Use(nil, @SingleCombatHex.RegisterSingleCombatHexagon);
  Use(nil, @Townhall.RegisterTownhall);
  Use(nil, @WorkShop.RegisterWorkshop);
  { per-package host additions: one include line per package (hosts\Pkg.inc), nothing else here }
  {$I hosts\T1.inc}
end.
