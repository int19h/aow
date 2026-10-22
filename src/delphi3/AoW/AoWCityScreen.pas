unit AoWCityScreen;

{ The city screen of AoW.exe, including production queues, migration and tactical previews.
  Layouts follow the original RTTI; named handlers and supporting routines are recovered
  from the executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, City, AoWE, AoWTC, AoWComp, AOWGauge, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox;

type
  TCityScreen = class;


  { TCityScreen: size $2DC; $2B0 city, $2B4 preview, $2B8/$2BC view, $2C0 action,
    $2C4 production, $2C8 queue, $2CC mode, $2D0 migrations, $2D4 sort, $2D8 images. VMT 00439F68. }
  TCityScreen = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    UnitPnl: TAOWPanel; { +0048 }
    UAbilitiesLB: TAOWListBox; { +004C }
    UAttackIcon: TAOWImage; { +0050 }
    UDefenseIcon: TAOWImage; { +0054 }
    UMovesIcon: TAOWImage; { +0058 }
    UDamageIcon: TAOWImage; { +005C }
    UResistanceIcon: TAOWImage; { +0060 }
    UHitsIcon: TAOWImage; { +0064 }
    UAttack: TAOWLabel; { +0068 }
    UDefense: TAOWLabel; { +006C }
    UMoves: TAOWLabel; { +0070 }
    UDamage: TAOWLabel; { +0074 }
    UResistance: TAOWLabel; { +0078 }
    UHits: TAOWLabel; { +007C }
    UStatPnl: TAOWPanel; { +0080 }
    UStatP1: TAOWPanel; { +0084 }
    UStatP2: TAOWPanel; { +0088 }
    UAlignment: TAOWLabel; { +008C }
    ULevel: TAOWLabel; { +0090 }
    UPicturePnl: TAOWPanel; { +0094 }
    UCostPnl: TAOWPanel; { +0098 }
    StructName: TAOWLabel; { +009C }
    CostLbl: TAOWLabel; { +00A0 }
    UCost: TAOWLabel; { +00A4 }
    UnitLbl: TAOWLabel; { +00A8 }
    TurnsLbl: TAOWLabel; { +00AC }
    UTurns: TAOWLabel; { +00B0 }
    P1CB: TAOWCheckBox; { +00B4 }
    P2CB: TAOWCheckBox; { +00B8 }
    P3CB: TAOWCheckBox; { +00BC }
    P4CB: TAOWCheckBox; { +00C0 }
    P5CB: TAOWCheckBox; { +00C4 }
    P6CB: TAOWCheckBox; { +00C8 }
    P7CB: TAOWCheckBox; { +00CC }
    P8CB: TAOWCheckBox; { +00D0 }
    P9CB: TAOWCheckBox; { +00D4 }
    P10CB: TAOWCheckBox; { +00D8 }
    P11CB: TAOWCheckBox; { +00DC }
    P12CB: TAOWCheckBox; { +00E0 }
    B4CB: TAOWCheckBox; { +00E4 }
    B5CB: TAOWCheckBox; { +00E8 }
    B6CB: TAOWCheckBox; { +00EC }
    B1CB: TAOWCheckBox; { +00F0 }
    B2CB: TAOWCheckBox; { +00F4 }
    B3CB: TAOWCheckBox; { +00F8 }
    T2SBar: TAOWVScrollBar; { +00FC }
    AbilPnl: TAOWPanel; { +0100 }
    UpgradePnl: TAOWPanel; { +0104 }
    UpgradeLbl: TAOWLabel; { +0108 }
    UpgradeMemoFr: TAOWPanel; { +010C }
    UpgradeMemo: TAOWMemo; { +0110 }
    RightPnl: TAOWPanel; { +0114 }
    QueuePnl: TAOWPanel; { +0118 }
    Oval: TAOWImage; { +011C }
    ShadowL: TAOWImage; { +0120 }
    ShadowR: TAOWImage; { +0124 }
    CityBtn3: TAOWButton; { +0128 }
    CityBtn1: TAOWButton; { +012C }
    QueueLB: TAOWListBox; { +0130 }
    ActivityPnl: TAOWPanel; { +0134 }
    InfoPnl2: TAOWPanel; { +0138 }
    ActiveAction: TAOWLabel; { +013C }
    ActiveActionTurns: TAOWLabel; { +0140 }
    SepBar: TAOWImage; { +0144 }
    ActivityPnl2: TAOWPanel; { +0148 }
    ActiveActionTurnsBar: TAoWGauge; { +014C }
    CityBtn2: TAOWButton; { +0150 }
    InfoPnl: TAOWPanel; { +0154 }
    IPPnl: TAOWPanel; { +0158 }
    IPPicFr: TAoWFrame; { +015C }
    PopulationMemo: TAOWMemo; { +0160 }
    PopulationHdr: TAOWMemo; { +0164 }
    IIPnl: TAOWPanel; { +0168 }
    IIPicFr: TAoWFrame; { +016C }
    IncomeMemo: TAOWMemo; { +0170 }
    IncomeHdr: TAOWMemo; { +0174 }
    IEPnl: TAOWPanel; { +0178 }
    IEPicFr: TAoWFrame; { +017C }
    EnhancementsMemo: TAOWMemo; { +0180 }
    EnhancementsHdr: TAOWMemo; { +0184 }
    CurrentInfo: TAOWPanel; { +0188 }
    RPillar: TAoWFrame; { +018C }
    LPillar: TAoWFrame; { +0190 }
    QueueInfo: TAOWPanel; { +0194 }
    QueueLbl: TAOWLabel; { +0198 }
    LoopQueueBox: TAOWCheckBox; { +019C }
    RepeatLbl: TAOWLabel; { +01A0 }
    ActiveActionPnl: TAOWPanel; { +01A4 }
    CurrentActionImage: TAOWImage; { +01A8 }
    RacePortrait: TAOWImage; { +01AC }
    AoWFrame1: TAoWFrame; { +01B0 }
    BlackBg: TAOWImage; { +01B4 }
    BlackBg2: TAOWImage; { +01B8 }
    UPictureFramePnl: TAOWPanel; { +01BC }
    UStatFr1: TAOWPanel; { +01C0 }
    UStatFr2: TAOWPanel; { +01C4 }
    UInfoFr: TAOWPanel; { +01C8 }
    CostFr: TAOWPanel; { +01CC }
    TurnsFr: TAOWPanel; { +01D0 }
    UpgPicPnl: TAOWPanel; { +01D4 }
    UpgradePic: TAOWImage; { +01D8 }
    UpgPicFr: TAOWPanel; { +01DC }
    UpgCostPnl: TAOWPanel; { +01E0 }
    UpgCostLbl: TAOWLabel; { +01E4 }
    UpgradeCost: TAOWLabel; { +01E8 }
    UpgTurnsLbl: TAOWLabel; { +01EC }
    UpgradeTurns: TAOWLabel; { +01F0 }
    UpgCostFr: TAOWPanel; { +01F4 }
    UpgTurnsFr: TAOWPanel; { +01F8 }
    MigratePnl: TAOWPanel; { +01FC }
    NewRaceLbl: TAOWLabel; { +0200 }
    MigrateMainFr: TAOWPanel; { +0204 }
    MigPicPnl: TAOWPanel; { +0208 }
    MigratePic: TAOWImage; { +020C }
    MigPicFr: TAOWPanel; { +0210 }
    MigCostPnl: TAOWPanel; { +0214 }
    MigCostLbl: TAOWLabel; { +0218 }
    MigrateCost: TAOWLabel; { +021C }
    MigTurnsLbl: TAOWLabel; { +0220 }
    MigrateTurns: TAOWLabel; { +0224 }
    MigCostFr: TAOWPanel; { +0228 }
    MigTurnsFr: TAOWPanel; { +022C }
    MigrationRaceLB: TAOWListBox; { +0230 }
    MigrationRelationLB: TAOWListBox; { +0234 }
    MigrationTurnsLB: TAOWListBox; { +0238 }
    SortMigrationRaces: TAOWButton; { +023C }
    SortMigrationTurns: TAOWButton; { +0240 }
    SortMigrationRelation: TAOWButton; { +0244 }
    T3LBPnl: TAOWPanel; { +0248 }
    MigrationSB: TAOWVScrollBar; { +024C }
    T3RaceLbl: TAOWLabel; { +0250 }
    CurrentRace: TAOWLabel; { +0254 }
    T3RelLbl: TAOWLabel; { +0258 }
    CurrentRelation: TAOWLabel; { +025C }
    CurrentRacePnl: TAOWPanel; { +0260 }
    CurrentRaceFr: TAOWPanel; { +0264 }
    CurrentRaceLbl: TAOWLabel; { +0268 }
    UpgBtm: TAOWPanel; { +026C }
    UpgradeInfo: TAOWLabel; { +0270 }
    RelIcn: TAOWImage; { +0274 }
    QueueVSB: TAOWVScrollBar; { +0278 }
    IPVSB: TAOWVScrollBar; { +027C }
    IIVSB: TAOWVScrollBar; { +0280 }
    IEVSB: TAOWVScrollBar; { +0284 }
    IncomeGoldMemo: TAOWMemo; { +0288 }
    Migrate: TAOWLabel; { +028C }
    UFace: TaowUserDrawBox; { +0290 }
    MigrateInfoPnl: TAOWPanel; { +0294 }
    MigrateInfo: TAOWLabel; { +0298 }
    MapView: TaowUserDrawBox; { +029C }
    InfoSep: TAOWImage; { +02A0 }
    PNext: TAOWButton; { +02A4 }
    PPrev: TAOWButton; { +02A8 }
    Translator: TIvTranslator; { +02AC }
    public
    FCity: TCity; { $2B0 }
    FPreview: TAoWCombatMap; { $2B4 }
    FViewX: Integer; { $2B8 }
    FViewY: Integer; { $2BC }
    FAction: TCityAction; { $2C0 }
    F_CityScreen_2C1: array[0..2] of Byte;
    FProductionIndex: Integer; { $2C4 }
    FQueueIndex: Integer; { $2C8 }
    FMode: Byte; { $2CC }
    FReserved2CD: array[0..2] of Byte; FMigrations: TMigrationList; { $2D0 }
    FMigrationSort: Integer; { $2D4 }
    FImages: TIntegerList; { $2D8 }
    procedure FreePreview;
    procedure ReleaseImages;
    procedure LoadUnitImages(Index: Integer);
    procedure ResetChecks;
    procedure Reset;
    procedure CloseCity;
    procedure SetMode(Mode: Byte);
    procedure SortMigration;
    function ActivityImage(Action: TCityAction) : Integer;
    procedure SelectDefaultAction;
    procedure SelectProduction(Index: Integer);
    procedure SelectMigration(Index: Integer);
    procedure SelectAction(Action: TCityAction);
    procedure UpdateInfo;
    procedure ProductionEvent(Event: TCityProductionEventLog);
    procedure CityChanged(Sender: TObject);
    procedure ShowCity(City: TCity);
    published procedure CityScreenCreate; public
    published procedure CityScreenDestroy; public
    published procedure ActivityChange(Sender: TObject); public
    published procedure ActivityDoubleClick(Sender: TObject); public
    published procedure ProductionChange(Sender: TObject); public
    published procedure ProductionDoubleClick(Sender: TObject); public
    published procedure ProductionsUpdate(Sender: TObject); public
    published procedure ActivityPreDraw(Sender: TAoWComponent; SD: TSurfaceDesc); public
    published procedure CityBtn1Click(Sender: TObject); public
    published procedure CityBtn2Click; public
    published procedure CityBtn3Click; public
    published procedure PreDrawProductions(Sender: TObject; SD: TSurfaceDesc); public
    published procedure SortMigrationRacesClick; public
    published procedure SortMigrationTurnsClick; public
    published procedure SortMigrationRelationClick; public
    published procedure MigrationChange(Sender: TAOWListBox); public
    published procedure MigrationSBChange(Sender: TObject); public
    published procedure UFaceDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure QueueLBChange(Sender: TAOWListBox); public
    published procedure CurrentActionImageDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure LoopQueueBoxChange; public
    published procedure RacePortraitDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure MapViewDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
    published procedure MapViewUpdate; public
    published procedure DlgHide; public
    published procedure UAbilitiesLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure PPrevClick; public
    published procedure PNextClick; public
  end;


var
  CityScreen: TCityScreen;

implementation

uses AoWExeForms, AoWWinMan, OverviewUnit;

procedure TCityScreen.ShowCity(City: TCity);
var
  I, J, Direction: Integer;
  Army: TArmyHS;
  Armies: TArmyHSList;
  Generator: TRndTacHsm;
begin
  Reset;
  FCity := City;
  UpdateInfo;
  SetMode(0);
  FreePreview;
  for I := 0 to FCity.FProduction.FUnitProductions.GetCount - 1 do
    LoadUnitImages(FCity.FProduction.FUnitProductions.GetItem(I).FUnitIndex);
  Generator := TRndTacHsm.Create;
  FPreview := Generator.RandomMap(nil, FCity.GetXhx, FCity.GetYhx, FCity.GetLhx);
  Generator.Free;
  Armies := TArmyHSList.Create(nil);
  FCity.ListArmies(Armies);
  for I := 0 to Armies.GetCount - 1 do
  begin
    Army := Armies.GetArmyHS(I);
    Direction := dHXtoHN(FCity.GetXhx, FCity.GetYhx, Army.GetXhx, Army.GetYhx);
    for J := 0 to Army.FArmy.GetCount - 1 do
      PlaceOverviewUnit(FPreview, Army.FArmy.GetUnit(J), Direction, J);
  end;
  Armies.Free;
  with FPreview.FCenterViewLocation do
  begin
    if FPreview.FCenterViewLocation <> nil then
    begin
      HXtoHP(GetXhx, GetYhx, FViewX, FViewY);
      FViewX := FViewX + 16 - MapView.WinWidth div 2;
      FViewY := FViewY + 16 - MapView.WinHeight div 2;
    end
    else
    begin
      FViewX := 800;
      FViewY := 800;
    end;
  end;
  AoWHSMap.FTutorialControl.ShowMessage($38, True, True);
  General.Manager.OverlayPriority := 49;
  Dlg.Visible := True;
end;


procedure TCityScreen.CityScreenCreate;
begin
  FImages := TIntegerList.Create;
end;

procedure TCityScreen.CityScreenDestroy;
begin
  FImages.Free;
end;

procedure TCityScreen.ActivityChange(Sender: TObject);
begin
  General.PlayButtonSound(1);
  if TAOWCheckBox(Sender).Checked then
  begin
    ResetChecks;
    SelectAction(TCityAction(Byte(TAOWCheckBox(Sender).Tag) + 1));
    TAOWCheckBox(Sender).Checked := True;
  end;
end;

procedure TCityScreen.ActivityDoubleClick(Sender: TObject);
begin
  if TCityAction(Byte(TAOWCheckBox(Sender).Tag) + 1) <> caMigrate then
  begin
    ResetChecks;
    SelectAction(TCityAction(Byte(TAOWCheckBox(Sender).Tag) + 1));
    TAOWCheckBox(Sender).Checked := True;
    CityBtn1Click(nil);
  end;
end;

procedure TCityScreen.ProductionChange(Sender: TObject);
begin
  General.PlayButtonSound(1);
  if TAOWCheckBox(Sender).Checked then
  begin
    ResetChecks;
    SelectProduction(TAOWCheckBox(Sender).Tag);
    TAOWCheckBox(Sender).Checked := True;
  end;
end;

procedure TCityScreen.ProductionDoubleClick(Sender: TObject);
begin
  ResetChecks;
  SelectProduction(TAOWCheckBox(Sender).Tag);
  TAOWCheckBox(Sender).Checked := True;
  CityBtn1Click(nil);
end;

procedure TCityScreen.ProductionsUpdate(Sender: TObject);
begin
  TAOWCheckBox(Sender).CaptureInput := FCity.FProduction.FUnitProductions.GetItem(TAOWCheckBox(Sender).Tag) <> nil;
end;

procedure TCityScreen.ActivityPreDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var Image: Integer; begin
  Image := ActivityImage(TCityAction(Byte(Sender.Tag) + 1)); IntGfxMod.CityWin[Image].Show(
    ActivityPnl2.WinLeft + Sender.WinLeft + 2, ActivityPnl2.WinTop + Sender.WinTop + 2, SD);
end;

procedure TCityScreen.CityBtn1Click(Sender: TObject);
var
  Reason: string;
  Race: Shortint;
begin
  case FMode of
    0: begin
      SetMode(1);
      SelectDefaultAction;
      AoWHSMap.FTutorialControl.ShowMessage($39, True, True);
    end;
    1: case FAction of
      caTrade: begin
        if FCity.CanTrade(False, Reason) then
        begin
          FCity.Trade(False);
          SetMode(0);
        end
        else AoWHSMap.ShowWarning(Reason);
      end;
      caLoot: begin
        if FCity.CanLoot(Reason) then
        begin
          FCity.Loot;
          SetMode(0);
        end
        else AoWHSMap.ShowWarning(Reason);
      end;
      caRaze: begin
        if FCity.CanRaze(AoWHSMap.FSeatedPlayer, Reason) then
        begin
          FCity.Raze(AoWHSMap.FSeatedPlayer);
          Dlg.Visible := False;
        end
        else AoWHSMap.ShowWarning(Reason);
      end;
      caUpgrade: begin
        if FCity.CanUpgrade(False, Reason) then
        begin
          FCity.Upgrade(False);
          SetMode(0);
        end
        else AoWHSMap.ShowWarning(Reason);
      end;
      caFortify: begin
        if FCity.CanFortify(False, Reason) then
        begin
          FCity.Fortify(False);
          SetMode(0);
        end
        else AoWHSMap.ShowWarning(Reason);
      end;
      caProduce: begin
        if FCity.CanProduce(FProductionIndex, False, Reason) then
        begin
          AoWHSMap.FTutorialControl.ShowMessage($3B, True, True);
          FCity.Produce(FProductionIndex, False);
          SetMode(0);
        end
        else AoWHSMap.ShowWarning(Reason);
      end;      caResearch: begin
        if FCity.CanResearch(FProductionIndex, False, Reason) then
        begin
          FCity.Research(FProductionIndex, False);
          SetMode(0);
        end
        else AoWHSMap.ShowWarning(Reason);
      end;
      caMigrate: begin
        Race := TMigrationItem(MigrationRaceLB.Items.Objects[MigrationRaceLB.Selected]).FRace;
        if FCity.CanMigrate(Race, Reason) then
        begin
          AoWHSMap.FTutorialControl.ShowMessage($42, True, True);
          FCity.Migrate(Race);
          SetMode(0);
        end;
      end;

    end;
    2: if FQueueIndex <> -1 then FCity.FProduction.DeleteProduction(FQueueIndex);
  end;
end;

procedure TCityScreen.CityBtn2Click;
var
  Reason: string;
begin
  case FMode of
    1: case FAction of
      caTrade:
        if FCity.CanTrade(True, Reason) then FCity.Trade(True)
        else AoWHSMap.ShowWarning(Reason);
      caUpgrade:
        if FCity.CanUpgrade(True, Reason) then FCity.Upgrade(True)
        else AoWHSMap.ShowWarning(Reason);
      caFortify:
        if FCity.CanFortify(True, Reason) then FCity.Fortify(True)
        else AoWHSMap.ShowWarning(Reason);
      caProduce:
        if FCity.CanProduce(FProductionIndex, True, Reason) then FCity.Produce(FProductionIndex, True)
        else AoWHSMap.ShowWarning(Reason);      caResearch:
        if FCity.CanResearch(FProductionIndex, True, Reason) then FCity.Research(FProductionIndex, True)
        else AoWHSMap.ShowWarning(Reason);

    end;
    2: if FQueueIndex = 0 then
      if FCity.FProduction.RetryProductionExecution(Reason) then SetMode(0)
      else AoWHSMap.ShowWarning(Reason);
  end;
end;

procedure TCityScreen.CityBtn3Click;
begin
  General.PlayButtonSound(0);
  if FMode = 0 then Dlg.Visible := False else SetMode(0);
  AoWHSMap.FTutorialControl.ShowMessage($3C, True, True);
end;

procedure TCityScreen.PreDrawProductions(Sender: TObject; SD: TSurfaceDesc);
var
  R: TRect;
  Info: TP2UnitShowInfo;
  U: TUnit;
  P: TUnitProduction;
begin
  R := Rect(ActivityPnl.WinLeft + TAoWComponent(Sender).WinLeft, ActivityPnl.WinTop + TAoWComponent(Sender).WinTop,
    ActivityPnl2.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth,
    ActivityPnl.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight); { Original uses two different panels. }
  P := FCity.FProduction.FUnitProductions.GetItem(TAoWComponent(Sender).Tag);
  if P <> nil then
  begin
    U := FCity.FProduction.CreateUnitProduction(TAoWComponent(Sender).Tag);
    Info.Direction := 3;
    Info.Overlays := [];
    Info.Animation := TUnitAnimation(0);
    Info.Frame := 0;
    Info.Looped := False;
    if not P.FResearched then
    begin
      IntGfxMod.CityWin[5].Show(R.Left + 2, R.Top + 2, SD);
      Info.Direction := 5;
      if U <> nil then U.ShowEx(R.Left - 4, R.Top, SD, Info);
      IntGfxMod.CityWin[5].ShowBlended(R.Left + 2, R.Top + 2, SD, AlphaBlendTable.GetLookupTables(45));
    end
    else
    begin
      IntGfxMod.CityWin[4].Show(R.Left + 2, R.Top + 2, SD);
      if U <> nil then U.ShowEx(R.Left - 4, R.Top, SD, Info);
    end;
    if U <> nil then U.Release;
  end
  else IntGfxMod.CityWin[62].Show(R.Left + 2, R.Top + 2, SD);
end;

procedure TCityScreen.SortMigrationRacesClick;
begin
  if FMigrationSort = 2 then FMigrationSort := 3
  else FMigrationSort := 2;
  SortMigration;
end;

procedure TCityScreen.SortMigrationTurnsClick;
begin
  if FMigrationSort = 0 then FMigrationSort := 1
  else FMigrationSort := 0;
  SortMigration;
end;

procedure TCityScreen.SortMigrationRelationClick;
begin
  if FMigrationSort = 4 then FMigrationSort := 5
  else FMigrationSort := 4;
  SortMigration;
end;

procedure TCityScreen.MigrationChange(Sender: TAOWListBox);
begin
  if FMode <> 2 then SelectMigration(Sender.Selected);
end;

procedure TCityScreen.MigrationSBChange(Sender: TObject);
begin
  MigrationRaceLB.ListOffset := TAOWVScrollBar(Sender).Position;
  MigrationTurnsLB.ListOffset := TAOWVScrollBar(Sender).Position;
  MigrationRelationLB.ListOffset := TAOWVScrollBar(Sender).Position;
end;

procedure TCityScreen.UFaceDraw(Sender: TObject; SD: TSurfaceDesc);
var
  U: TUnit;
  R: TRect;
begin
  U := FCity.FProduction.CreateUnitProduction(FProductionIndex);
  if U <> nil then
  begin
    R := Rect(UPictureFramePnl.WinLeft + TAoWComponent(Sender).WinLeft + 2,
      UPictureFramePnl.WinTop + TAoWComponent(Sender).WinTop + 2,
      UPictureFramePnl.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth - 4,
      UPictureFramePnl.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight - 2);
    U.ShowFace(R, SD);
    U.Release;
  end;
end;

procedure TCityScreen.QueueLBChange(Sender: TAOWListBox);
var
  Action: TCityAction;
begin
  if (QueueLB.Selected < FCity.FProduction.FQueue.GetCount) and (FMode <> 0) then
  begin
    if QueueLB.Selected <> -1 then
    begin
      FQueueIndex := QueueLB.Selected;
      Action := ProductionIDToCityAction(FCity.FProduction.FQueue.GetItem(FQueueIndex).FProductionID);
      if Action = caProduce then
      begin
        FProductionIndex := FCity.FProduction.FQueue.GetItem(FQueueIndex).FParameter;
        if (FProductionIndex < 0) or (FProductionIndex >= FCity.FProduction.FUnitProductions.GetCount) then FProductionIndex := 0;
      end;
      SelectAction(Action);
      SetMode(2);
      QueueLB.Selected := FQueueIndex;
      CityBtn1.Visible := True;
      CityBtn1.Text := TranslateRStr(DeleteRStr);
      if (FQueueIndex = 0) and (FCity.FProduction.FStatus = pcsWaiting) then
      begin
        CityBtn2.Visible := True;
        CityBtn2.Text := TranslateRStr(ExecuteRStr);
      end
      else CityBtn2.Visible := False;
      PPrev.Visible := False;
      PNext.Visible := False;
    end
    else
    begin
      SetMode(1);
      SelectDefaultAction;
    end;
  end
  else if FMode = 2 then Sender.Selected := FQueueIndex
  else Sender.Selected := -1;
end;

procedure TCityScreen.CurrentActionImageDraw(Sender: TObject; SD: TSurfaceDesc);
var
  Info: TP2UnitShowInfo;
  R: TRect;
  U: TUnit;
begin
  if FCity.FProduction.FQueue.GetCount <> 0 then
    case FCity.FProduction.FQueue.GetItem(0).FProductionID of
      1, 2: begin
        R := Rect(ActiveActionPnl.WinLeft + TAoWComponent(Sender).WinLeft, ActiveActionPnl.WinTop + TAoWComponent(Sender).WinTop,
          ActiveActionPnl.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth,
          ActiveActionPnl.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight);
        U := FCity.FProduction.CreateUnitProduction(FCity.FProduction.FQueue.GetItem(0).FParameter);
        if U <> nil then
        begin
          Info.Direction := 3;
          Info.Overlays := [];
          Info.Animation := TUnitAnimation(0);
          Info.Frame := 0;
          Info.Looped := False;
          if not FCity.FProduction.FUnitProductions.GetItem(FCity.FProduction.FQueue.GetItem(0).FParameter).FResearched then
            Info.Direction := 5;
          U.ShowEx(R.Left - 8, R.Top - 5, SD, Info);
          U.Release;
        end;
      end;
    end;
end;

procedure TCityScreen.LoopQueueBoxChange;
begin
  FCity.FProduction.SetLoopQueueTo(LoopQueueBox.Checked);
end;

procedure TCityScreen.RacePortraitDraw(Sender: TObject; SD: TSurfaceDesc);
var
  R: TRect;
begin
  R := Rect(IPPnl.WinLeft + TAoWComponent(Sender).WinLeft, IPPnl.WinTop + TAoWComponent(Sender).WinTop,
    IPPnl.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth,
    IPPnl.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight);
  AoWHSSet.FRaceResources.GetRaceResource(FCity.FRace).GetFace.ShowStretched(R, SD);
end;

procedure TCityScreen.MapViewDraw(Sender: TObject; SD: TSurfaceDesc);
var
  ViewSD: TSurfaceDesc;
  R: TRect;
  W, H, Width: Integer;
begin
  if FPreview <> nil then
  begin
    R := Rect(Dlg.WinLeft + TAoWComponent(Sender).WinLeft, Dlg.WinTop + TAoWComponent(Sender).WinTop,
      Dlg.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth, Dlg.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight);
    Width := R.Right - R.Left; W := Width;
    H := R.Bottom - R.Top;
    if FViewX + W + 16 > FPreview.GetMaxXhp then FViewX := FPreview.GetMaxXhp - W - 16;
    if FViewY + H + 16 > FPreview.GetMaxYhp then FViewY := FPreview.GetMaxYhp - H - 16;
    if FViewX < 16 then FViewX := 16;
    if FViewY < 16 then FViewY := 16;
    CreateSDfromSD(SD, R, ViewSD);
    FPreview.SetExplorationEnabled(False);
    FPreview.SetFogEnabled(False);
    FPreview.SetViewPort(FViewX, FViewY, 0, Width, R.Bottom - R.Top);
    FPreview.UpdateStaticScene;
    FPreview.UpdateDynamicScene;
    FPreview.DrawStaticScene(ViewSD);
    FPreview.DrawDynamicScene(ViewSD);
  end;
end;

procedure TCityScreen.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT: begin Dec(FViewX, 16); MapView.FDrawn := False; end;
    VK_RIGHT: begin Inc(FViewX, 16); MapView.FDrawn := False; end;
    VK_UP: begin Dec(FViewY, 16); MapView.FDrawn := False; end;
    VK_DOWN: begin Inc(FViewY, 16); MapView.FDrawn := False; end;
    VK_ESCAPE: Dlg.Visible := False;
  end;
end;

procedure TCityScreen.MapViewUpdate;
var
  Preview: TAoWCombatMap;
begin
  Preview := FPreview;
  if Preview <> nil then Preview.NewFrame;
  MapView.FDrawn := MapView.FDrawn and Odd(AoWHSMap.Frame);
end;

procedure TCityScreen.DlgHide;
begin
  CloseCity;
end;

procedure TCityScreen.UAbilitiesLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  A: TAbility;
begin
  if (Button = mbRight) and (UAbilitiesLB.Selected > -1) then
  begin
    A := AoWHSSet.FAbilityControl.GetAbility(Integer(UAbilitiesLB.Items.Objects[UAbilitiesLB.Selected]));
    if A <> nil then SetInfoBanner(InfoBanner, A.GetName(nil), A.FDescription);
  end;
end;

procedure TCityScreen.PPrevClick;
var
  Start, Index: Integer;
  S: TPlayerStructure;
begin
  Start := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.FindChildIndex(FCity);
  Index := Start;
  Dec(Index);
  if Index < 0 then Index := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetCount - 1;
  while Index <> Start do
  begin
    S := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetStructure(Index);
    if S is TCity then
    begin
      Index := Start + 1;
      ShowCity(TCity(S));
    end;
    Inc(Index, -1);
    if Index < 0 then Index := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetCount - 1;
  end;
end;

procedure TCityScreen.PNextClick;
var
  Start, Index: Integer;
  S: TPlayerStructure;
begin
  Start := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.FindChildIndex(FCity);
  Index := Start + (1);
  if Index >= AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetCount then Index := 0;
  while Index <> Start do
  begin
    S := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetStructure(Index);
    if S is TCity then
    begin
      Index := Start - 1;
      ShowCity(TCity(S));
    end;
    Inc(Index, 1);
    if Index >= AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetCount then Index := 0;
  end;
end;


procedure TCityScreen.FreePreview;
begin
  if FPreview <> nil then
  begin
    FPreview.Free;
    FPreview := nil;
  end;
end;

procedure TCityScreen.ReleaseImages;
var
  I: Integer;
begin
  for I := FImages.Count - 1 downto 0 do
    AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FImages[I]).Release;
  FImages.Clear;
end;

procedure TCityScreen.LoadUnitImages(Index: Integer);
var
  Gfx: Integer;
begin
  Gfx := AoWHSSet.FUnitResources.GetUnitResource(Index).FUnitGFXResourceIndex;
  AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Gfx).AddRef;
  FImages.Add(Gfx);
end;

procedure TCityScreen.ResetChecks;
begin
  P1CB.Checked := False;
  P2CB.Checked := False;
  P3CB.Checked := False;
  P4CB.Checked := False;
  P5CB.Checked := False;
  P6CB.Checked := False;
  P7CB.Checked := False;
  P8CB.Checked := False;
  P9CB.Checked := False;
  P10CB.Checked := False;
  P11CB.Checked := False;
  P12CB.Checked := False;
  B1CB.Checked := False;
  B2CB.Checked := False;
  B3CB.Checked := False;
  B4CB.Checked := False;
  B5CB.Checked := False;
  B6CB.Checked := False;
end;

procedure TCityScreen.Reset;
begin
  ReleaseImages;
  FMode := 0;
  InfoPnl.Visible := True;
  InfoPnl2.Visible := True;
  ActivityPnl.Visible := False;
  ActivityPnl2.Visible := False;
  UnitPnl.Visible := False;
  UpgradePnl.Visible := False;
  MigratePnl.Visible := False;
  CityBtn1.Visible := True;
  CityBtn1.Text := TranslateRStr(OptionsRStr);
  CityBtn2.Visible := False;
  PPrev.Visible := not CityBtn2.Visible;
  PNext.Visible := not CityBtn2.Visible;
  ShadowL.Visible := AoWEngine.FAnimationDetail <> 0;
  ShadowR.Visible := AoWEngine.FAnimationDetail <> 0;
  Oval.Visible := AoWEngine.FAnimationDetail <> 0;
  FMigrationSort := 0;
  FProductionIndex := 0;
  QueueLB.Selected := -1;
  FreePreview;
  QueueLbl.Text := TranslateRStr(QueueRStr);
  RepeatLbl.Text := TranslateRStr(RepeatRStr);
  if FMigrations <> nil then
  begin
    FMigrations.Free;
    FMigrations := nil;
  end;
end;

procedure TCityScreen.CloseCity;
begin
  Reset;
  FCity := nil;
  General.Manager.OverlayPriority := 0;
end;

procedure TCityScreen.SetMode(Mode: Byte);
begin
  FMode := Mode;
  case FMode of
    0: begin
      InfoPnl.Visible := True;
      InfoPnl2.Visible := True;
      ActivityPnl.Visible := False;
      ActivityPnl2.Visible := False;
      CityBtn1.Text := TranslateRStr(ChangeRStr);
      CityBtn1.Visible := True;
      CityBtn2.Visible := False;
      PPrev.Visible := not CityBtn2.Visible;
      PNext.Visible := not CityBtn2.Visible;
      CityBtn3.Text := TranslateRStr(ExitRStr);
      QueueLB.Selected := -1;
      LPillar.Visible := True;
      RPillar.Visible := True;
      MapView.WinHeight := InfoPnl.WinTop - MapView.WinTop;
    end;
    1: begin
      QueueLB.Selected := -1;
      InfoPnl.Visible := False;
      InfoPnl2.Visible := False;
      ActivityPnl.Visible := True;
      ActivityPnl2.Visible := True;
      CityBtn1.Text := TranslateRStr(InfoRStr);
      CityBtn3.Text := TranslateRStr(DoneRStr);
      LPillar.Visible := False;
      RPillar.Visible := False;
      MapView.WinHeight := ActivityPnl.WinTop - MapView.WinTop;
      MigrationRaceLB.CaptureInput := True;
      MigrationTurnsLB.CaptureInput := True;
      MigrationRelationLB.CaptureInput := True;
    end;
    2: begin
      ResetChecks;
      QueueLB.Selected := -1;
      InfoPnl.Visible := False;
      InfoPnl2.Visible := False;
      ActivityPnl.Visible := True;
      ActivityPnl2.Visible := True;
      LPillar.Visible := False;
      RPillar.Visible := False;
      CityBtn1.Text := TranslateRStr(InfoRStr);
      CityBtn3.Text := TranslateRStr(DoneRStr);
      MigrationRaceLB.CaptureInput := False;
      MigrationTurnsLB.CaptureInput := False;
      MigrationRelationLB.CaptureInput := False;
      MigrationRaceLB.Selected := -1;
      MigrationTurnsLB.Selected := -1;
      MigrationRelationLB.Selected := -1;
    end;
  end;
end;

procedure TCityScreen.SortMigration;
begin
  case FMigrationSort of
    0: SortStringsNumericalAscending(MigrationTurnsLB.Items, [MigrationRaceLB.Items, MigrationRelationLB.Items]);
    1: SortStringsNumericalDescending(MigrationTurnsLB.Items, [MigrationRaceLB.Items, MigrationRelationLB.Items]);
    2: SortStringsAscending(MigrationRaceLB.Items, [MigrationTurnsLB.Items, MigrationRelationLB.Items]);
    3: SortStringsDescending(MigrationRaceLB.Items, [MigrationTurnsLB.Items, MigrationRelationLB.Items]);
    4: SortStringsAscending(MigrationRelationLB.Items, [MigrationTurnsLB.Items, MigrationRaceLB.Items]);
    5: SortStringsDescending(MigrationRelationLB.Items, [MigrationTurnsLB.Items, MigrationRaceLB.Items]);
  end;
end;

function TCityScreen.ActivityImage(Action: TCityAction) : Integer;
begin
  case Action of
    caTrade: Result := 40;
    caUpgrade: Result := 43;
    caFortify: if FCity.FWallType = 0 then Result := 41 else Result := 42;
    caMigrate: Result := 44;
    caLoot: Result := 45;
    caRaze: Result := 46;
    caProduce: Result := 4;
    caResearch: Result := 5;
  else Result := 40;
  end;
end;

procedure TCityScreen.SelectDefaultAction;
begin
  ResetChecks;
  B1CB.Checked := True;
  SelectAction(caTrade);
end;

procedure TCityScreen.SelectProduction(Index: Integer);
var
  P: TUnitProduction;
begin
  P := FCity.FProduction.FUnitProductions.GetItem(Index);
  if P <> nil then
  begin
    FProductionIndex := Index;
    if P.FResearched then
    begin
      SelectAction(caProduce);
      AoWHSMap.FTutorialControl.ShowMessage($3A, True, True);
    end
    else SelectAction(caResearch);
  end;
end;

procedure TCityScreen.SelectMigration(Index: Integer);
var
  Item: TMigrationItem;
begin
  if (Index >= 0) and (Index < MigrationRaceLB.Items.Count) then
  begin
    Item := TMigrationItem(MigrationRaceLB.Items.Objects[Index]);
    MigrationRaceLB.Selected := Index;
    MigrationTurnsLB.Selected := Index;
    MigrationRelationLB.Selected := Index;
    MigrateTurns.Text := IntToStr(Item.FTime);
    MigrateInfo.Text := AoWE.Format(TranslateRStr(XRelationMinusYRStr), [TranslateRStr(RaceNamesRStr[FCity.FRace]), -15]);
    MigrateInfo.Text := MigrateInfo.Text + '   ';
    MigrateInfo.Text := MigrateInfo.Text + AoWE.Format(TranslateRStr(XRelationPlusYRStr), [TranslateRStr(RaceNamesRStr[Item.FRace]), 10]);
    CityBtn1.Visible := True;
    CityBtn1.Text := TranslateRStr(MigrateRStr);
  end
  else
  begin
    MigrationRaceLB.Selected := -1;
    MigrationTurnsLB.Selected := -1;
    MigrationRelationLB.Selected := -1;
    MigrateInfo.Text := '';
    MigrateTurns.Text := '-';
    UpgradeInfo.Text := '';
    CityBtn1.Visible := False;
  end;
end;

procedure TCityScreen.SelectAction(Action: TCityAction);
var
  U: TUnit;
begin
  if FMode <> 1 then SetMode(1);
  FAction := Action;
  UpgradePnl.Visible := False;
  UnitPnl.Visible := False;
  MigratePnl.Visible := False;
  UpgradePic.CurrentImage := 21;
  UpgradeCost.Text := '-';
  UpgradeTurns.Text := '-';
  UpgradeInfo.Text := '';
  CityBtn1.Visible := False;
  CityBtn2.Visible := False;
  case FAction of
    caTrade: begin
      CityBtn1.Visible := True;
      CityBtn1.Text := TranslateRStr(ProduceMerchandiseRStr);
      CityBtn2.Visible := not FCity.FProduction.GetQueueLocked;
      CityBtn2.Text := TranslateRStr(QueueRStr);
      UpgradeMemo.Items.Text := TranslateRStr(CityTradeRStr);
      UpgradePnl.Visible := True;
      UpgradePic.CurrentImage := 20;
      UpgradeLbl.Text := TranslateRStr(ProduceMerchandiseRStr);
    end;
    caUpgrade: begin
      CityBtn1.Visible := True;
      CityBtn1.Text := TranslateRStr(UpgradeRStr);
      CityBtn2.Visible := not FCity.FProduction.GetQueueLocked;
      CityBtn2.Text := TranslateRStr(QueueRStr);
      UpgradeMemo.Items.Text := TranslateRStr(CityUpgradeRStr);
      UpgradePnl.Visible := True;
      UpgradePic.CurrentImage := 23;
      UpgradeCost.Text := IntToStr(FCity.UpgradeCost);
      UpgradeTurns.Text := IntToStr(FCity.UpgradeTime);
      UpgradeLbl.Text := TranslateRStr(UpgradeRStr);
      UpgradeInfo.Text := AoWE.Format(TranslateRStr(XRelationPlusYRStr), [TranslateRStr(RaceNamesPluralRStr[FCity.FRace]), 5]);
    end;
    caFortify: begin
      CityBtn1.Visible := True;
      CityBtn1.Text := TranslateRStr(FortifyRStr);
      CityBtn2.Visible := not FCity.FProduction.GetQueueLocked;
      CityBtn2.Text := TranslateRStr(QueueRStr);
      UpgradeMemo.Items.Text := TranslateRStr(CityFortifyRStr);
      UpgradePnl.Visible := True;
      if FCity.FWallType = 0 then UpgradePic.CurrentImage := 21
      else UpgradePic.CurrentImage := 22;
      if FCity.FortifyCost > 0 then
      begin
        UpgradeCost.Text := IntToStr(FCity.FortifyCost);
        UpgradeTurns.Text := IntToStr(FCity.FortifyTime);
      end
      else
      begin
        UpgradeCost.Text := '-';
        UpgradeTurns.Text := '-';
      end;
      UpgradeLbl.Text := TranslateRStr(FortifyRStr);
      UpgradeInfo.Text := AoWE.Format(TranslateRStr(XRelationPlusYRStr), [TranslateRStr(RaceNamesRStr[FCity.FRace]), 5]);
    end;
    caMigrate: begin
      MigratePnl.Visible := True;
      SelectMigration(0);
    end;
    caLoot: begin
      CityBtn1.Visible := True;
      CityBtn1.Text := TranslateRStr(LootRStr);
      UpgradeMemo.Items.Text := TranslateRStr(CityLootRStr);
      UpgradePnl.Visible := True;
      UpgradePic.CurrentImage := 25;
      UpgradeLbl.Text := TranslateRStr(LootRStr);
      UpgradeInfo.Text := AoWE.Format(TranslateRStr(XRelationMinusYRStr), [TranslateRStr(RaceNamesRStr[FCity.FRace]), -30]);
    end;
    caRaze: begin
      CityBtn1.Visible := True;
      CityBtn1.Text := TranslateRStr(RazeRStr) + '...';
      UpgradeMemo.Items.Text := TranslateRStr(CityRazeRStr);
      UpgradePnl.Visible := True;
      UpgradePic.CurrentImage := 26;
      UpgradeLbl.Text := TranslateRStr(RazeRStr);
      UpgradeInfo.Text := AoWE.Format(TranslateRStr(XRelationMinusYRStr), [TranslateRStr(RaceNamesRStr[FCity.FRace]), -30]);
    end;
    caResearch, caProduce: begin
      U := FCity.FProduction.CreateUnitProduction(FProductionIndex);
      UnitPnl.Visible := True;
      UAttack.Text := IntToStr(U.GetAttack);
      UDefense.Text := IntToStr(U.GetDefense);
      UResistance.Text := IntToStr(U.GetResistance);
      UDamage.Text := IntToStr(U.GetDamage);
      UHits.Text := IntToStr(U.GetHits);
      UMoves.Text := IntToStr(U.GetMoves);
      UMovesIcon.CurrentImage := General.MTtoInt(U.GetMoveTypes);
      UAlignment.Text := AoWE.Format(TranslateRStr(AlignmentXRStr), [TranslateRStr(TAlignmentRStr[U.GetAlignment])]);
      ULevel.Text := AoWE.Format(TranslateRStr(LevelXRStr), [IntToStr(U.GetUnitLevel)]) + ' / ' +
        AoWE.Format(TranslateRStr(UpkeepXRStr), [Byte(U.GetUpkeep)]);
      if AoWEngine.FDebug then
        AoWHSMap.ShowMessage('AI Prio:' + IntToStr(GetUnitIndexAIPriority(U.FUnitResource.UnitResourceIndex, FCity.FPlayer, 0)));
      UAbilitiesLB.Items.Clear;
      U.ListAbilities(UAbilitiesLB.Items);
      if FAction = caProduce then
      begin
        CityBtn1.Visible := True;
        CityBtn1.Text := TranslateRStr(ProduceRStr);
        CityBtn2.Visible := not FCity.FProduction.GetQueueLocked;
        CityBtn2.Text := TranslateRStr(QueueRStr);
        UnitLbl.Text := AoWE.Format(TranslateRStr(ProduceXRStr), [U.GetName]);
        UCost.Text := IntToStr(FCity.FProduction.UnitProductionGold(FProductionIndex));
        UTurns.Text := IntToStr(FCity.FProduction.UnitProductionTime(FProductionIndex));
      end
      else
      begin
        CityBtn1.Visible := True;
        CityBtn1.Text := TranslateRStr(InstallRStr);
        CityBtn2.Visible := not FCity.FProduction.GetQueueLocked;
        CityBtn2.Text := TranslateRStr(QueueRStr);
        UnitLbl.Text := AoWE.Format(TranslateRStr(InstallXRStr), [U.GetName]);
        UCost.Text := IntToStr(FCity.FProduction.UnitResearchGold(FProductionIndex));
        UTurns.Text := IntToStr(FCity.FProduction.UnitResearchTime(FProductionIndex));
      end;
      U.Release;
    end;
  end;
  PPrev.Visible := False;
  PNext.Visible := False;
end;

procedure TCityScreen.UpdateInfo;
var
  Reason: string;
  I, J: Integer;
begin
  StructName.Text := FCity.GetName;
  PopulationHdr.Items.Clear;
  PopulationHdr.Items.Add(TranslateRStr(PopulationRStr) + ':');
  PopulationHdr.Items.Add(' ' + TranslateRStr(RaceNamesPluralRStr[FCity.FRace]));
  PopulationHdr.Items.Add(TranslateRStr(StatusRStr) + ':');
  PopulationHdr.Items.Add(' ' + TranslateRStr(TCivilStatusRStr[FCity.GetCivilStatus]));
  PopulationMemo.Items.Clear;
  FCity.ListCivilStatusInfo(PopulationMemo.Items);
  IncomeHdr.Items.Clear;
  IncomeHdr.Items.Add(TranslateRStr(IncomeRStr));
  IncomeHdr.Items.Add(AoWE.Format(' ' + TranslateRStr(XGoldRStr), [IntToStr(FCity.FIncome)]));
  IncomeMemo.Items.Clear;
  IncomeGoldMemo.Items.Clear;
  FCity.ListIncomeInfo(IncomeMemo.Items, IncomeGoldMemo.Items);
  EnhancementsHdr.Items.Clear;
  EnhancementsHdr.Items.Add(TranslateRStr(EnhancementsRStr));
  EnhancementsMemo.Items.Clear;
  FCity.ListEnhancementsInfo(EnhancementsMemo.Items);
  if FMigrations <> nil then
  begin
    FMigrations.Free;
    FMigrations := nil;
  end;
  FMigrations := FCity.CreateMigrationSelection;
  CurrentRace.Text := TranslateRStr(RaceNamesPluralRStr[FCity.FRace]);
  CurrentRelation.Text := TranslateRStr(TStatusRStr[AoWHSMap.FRaces.GetRace(FCity.FRace).GetPlayerRelation(FCity.FPlayer)]);
  MigrationRaceLB.Items.Clear;
  MigrationTurnsLB.Items.Clear;
  MigrationRelationLB.Items.Clear;
  if FMigrations <> nil then
    for I := 0 to FMigrations.GetCount - 1 do
    begin
      MigrationRaceLB.Items.AddObject(TranslateRStr(RaceNamesPluralRStr[FMigrations.GetItems(I).FRace]), FMigrations.GetItems(I));
      MigrationTurnsLB.Items.Add(IntToStr(FMigrations.GetItems(I).FTime));
      MigrationRelationLB.Items.Add(TranslateRStr(TStatusRStr[FMigrations.GetItems(I).FRelation]));
    end;
  SortMigration;
  QueueLB.Items.Clear;
  for I := 0 to FCity.FProduction.FQueue.GetCount - 1 do
    QueueLB.Items.Add(IntToStr(I + 1) + '. ' + FCity.FProduction.FQueue.GetItem(I).GetName);
  for I := FCity.FProduction.FQueue.GetCount to 4 do
    QueueLB.Items.Add(IntToStr(I + 1) + '. ' + TranslateRStr(EmptyQueueRStr));
  if QueueLB.Selected >= FCity.FProduction.FQueue.GetCount then
  begin
    QueueLB.Selected := FCity.FProduction.FQueue.GetCount - 1;
    FQueueIndex := QueueLB.Selected;
  end;
  LoopQueueBox.Checked := FCity.FProduction.FLoopQueue;
  if FCity.GetActiveAction <> caNone then
  begin
    ActiveAction.Text := FCity.FProduction.FQueue.GetItem(0).GetNameProgressive;
    if FCity.FProduction.FSettings.FTurnsLeft <> -1 then
    begin
      ActiveActionTurns.Text := FmtTurnsLeftStr(FCity.FProduction.FSettings.FTurnsLeft);
      ActiveActionTurns.Visible := True;
      ActiveActionTurns.TextColor := $678376;
      with ActiveActionTurnsBar do
      begin
        Min := 0;
        Max := FCity.FProduction.FSettings.FTurnsTotal;
        Position := FCity.FProduction.FSettings.FTurnsTotal - FCity.FProduction.FSettings.FTurnsLeft;
      end;
      ActiveActionTurnsBar.Visible := True;
    end
    else
    begin
      ActiveActionTurns.Visible := False;
      ActiveActionTurnsBar.Visible := False;
    end;
    CurrentActionImage.CurrentImage := ActivityImage(FCity.GetActiveAction);
  end
  else
  begin
    if FCity.FProduction.FQueue.GetCount = 0 then
    begin
      ActiveAction.Text := TranslateRStr(ProducingMerchandiseRStr);
      ActiveActionTurns.Text := '(' + LowerCase(TranslateRStr(DefaultRStr)) + ')';
      ActiveActionTurns.TextColor := $678376;
      ActiveActionTurnsBar.Visible := False;
      CurrentActionImage.CurrentImage := ActivityImage(FCity.GetActiveAction);
    end
    else
    begin
      Reason := '';
      ActiveAction.Text := FCity.FProduction.FQueue.GetItem(0).GetNameProgressive;
      FCity.FProduction.CanExecuteProduction(FCity.FProduction.FQueue.GetItem(0), Reason);
      ActiveActionTurns.Text := Reason;
      ActiveActionTurns.TextColor := $FF;
      ActiveActionTurnsBar.Visible := False;
      CurrentActionImage.CurrentImage := ActivityImage(ProductionIDToCityAction(FCity.FProduction.FQueue.GetItem(0).FProductionID));
    end;
  end;
  if (FMode = 1) and (FAction <> caNone) then SelectAction(FAction);
  Dlg.FDrawn := False;
end;

procedure TCityScreen.ProductionEvent(Event: TCityProductionEventLog);
begin
  ShowCity(Event.GetCity);
  SetMode(1);
  SelectDefaultAction;
end;

procedure TCityScreen.CityChanged(Sender: TObject);
begin
  if Dlg.Visible and (Sender = FCity) then
    if FCity.FPlayer = AoWHSMap.FSeatedPlayer then UpdateInfo
    else Dlg.Visible := False;
end;

end.
