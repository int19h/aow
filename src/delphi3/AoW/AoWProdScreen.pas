unit AoWProdScreen;

{ The production-place screen of AoW.exe, including production queues and tactical previews.
  Layouts follow the original RTTI; named handlers and supporting routines are recovered
  from the executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, PrdPlace, AoWE, AoWTC, AoWComp, AOWGauge, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox;

type
  TProductionScreen = class;


  { TProductionScreen: size $200; $1E0/$1E4 view, $1E8 place, $1EC production,
    $1F0 queue, $1F4 mode, $1F8 preview, $1FC images. VMT 0043E654. }
  TProductionScreen = class(TDataModule)
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
    B4CB: TAOWCheckBox; { +00B4 }
    B5CB: TAOWCheckBox; { +00B8 }
    B6CB: TAOWCheckBox; { +00BC }
    B1CB: TAOWCheckBox; { +00C0 }
    B2CB: TAOWCheckBox; { +00C4 }
    B3CB: TAOWCheckBox; { +00C8 }
    T2SBar: TAOWVScrollBar; { +00CC }
    AbilPnl: TAOWPanel; { +00D0 }
    UpgradePnl: TAOWPanel; { +00D4 }
    UpgradeLbl: TAOWLabel; { +00D8 }
    UpgradeMemoFr: TAOWPanel; { +00DC }
    UpgradeMemo: TAOWMemo; { +00E0 }
    RightPnl: TAOWPanel; { +00E4 }
    QueuePnl: TAOWPanel; { +00E8 }
    Oval: TAOWImage; { +00EC }
    ShadowL: TAOWImage; { +00F0 }
    ShadowR: TAOWImage; { +00F4 }
    MainBtn3: TAOWButton; { +00F8 }
    MainBtn1: TAOWButton; { +00FC }
    QueueLB: TAOWListBox; { +0100 }
    ActivityPnl: TAOWPanel; { +0104 }
    InfoPnl2: TAOWPanel; { +0108 }
    ActiveAction: TAOWLabel; { +010C }
    ActiveActionTurns: TAOWLabel; { +0110 }
    SepBar: TAOWImage; { +0114 }
    ActivityPnl2: TAOWPanel; { +0118 }
    ActiveActionTurnsBar: TAoWGauge; { +011C }
    MainBtn2: TAOWButton; { +0120 }
    InfoPnl: TAOWPanel; { +0124 }
    IPPnl: TAOWPanel; { +0128 }
    IPPicFr: TAoWFrame; { +012C }
    PlaceInfoMemo: TAOWMemo; { +0130 }
    IIPnl: TAOWPanel; { +0134 }
    IncomePicture: TAoWFrame; { +0138 }
    IncomeMemo: TAOWMemo; { +013C }
    IncomeHdr: TAOWMemo; { +0140 }
    CurrentInfo: TAOWPanel; { +0144 }
    RPillar: TAoWFrame; { +0148 }
    LPillar: TAoWFrame; { +014C }
    QueueInfo: TAOWPanel; { +0150 }
    QueueLbl: TAOWLabel; { +0154 }
    LoopQueueBox: TAOWCheckBox; { +0158 }
    RepeatLbl: TAOWLabel; { +015C }
    ActiveActionPnl: TAOWPanel; { +0160 }
    CurrentActionImage: TAOWImage; { +0164 }
    AoWFrame1: TAoWFrame; { +0168 }
    BlackBg2: TAOWImage; { +016C }
    UPictureFramePnl: TAOWPanel; { +0170 }
    UStatFr1: TAOWPanel; { +0174 }
    UStatFr2: TAOWPanel; { +0178 }
    UInfoFr: TAOWPanel; { +017C }
    CostFr: TAOWPanel; { +0180 }
    TurnsFr: TAOWPanel; { +0184 }
    UpgPicPnl: TAOWPanel; { +0188 }
    UpgradePic: TAOWImage; { +018C }
    UpgPicFr: TAOWPanel; { +0190 }
    UpgCostPnl: TAOWPanel; { +0194 }
    UpgCostLbl: TAOWLabel; { +0198 }
    UpgradeCost: TAOWLabel; { +019C }
    UpgTurnsLbl: TAOWLabel; { +01A0 }
    UpgradeTurns: TAOWLabel; { +01A4 }
    UpgCostFr: TAOWPanel; { +01A8 }
    UpgTurnsFr: TAOWPanel; { +01AC }
    RelIcn: TAOWImage; { +01B0 }
    QueueVSB: TAOWVScrollBar; { +01B4 }
    IPVSB: TAOWVScrollBar; { +01B8 }
    IIVSB: TAOWVScrollBar; { +01BC }
    IncomeValuesMemo: TAOWMemo; { +01C0 }
    UFace: TaowUserDrawBox; { +01C4 }
    InfoSep: TAOWImage; { +01C8 }
    Sphere: TAOWButton; { +01CC }
    MapView: TaowUserDrawBox; { +01D0 }
    PNext: TAOWButton; { +01D4 }
    PPrev: TAOWButton; { +01D8 }
    Translator: TIvTranslator; { +01DC }
    public
    FViewX: Integer; { $1E0 }
    FViewY: Integer; { $1E4 }
    FPlace: TProductionPlace; { $1E8 }
    FProductionIndex: Integer; { $1EC }
    FQueueIndex: Integer; { $1F0 }
    FMode: Byte; { $1F4 }
    F_ProductionScreen_1F5: array[0..2] of Byte;
    FPreview: TAoWCombatMap; { $1F8 }
    FImages: TIntegerList; { $1FC }
    procedure FreePreview;
    procedure ReleaseImages;
    procedure LoadUnitImages(Index: Integer);
    procedure ResetChecks;
    procedure Reset;
    procedure ClosePlace;
    procedure SetMode(Mode: Byte);
    procedure SelectDefaultAction;
    procedure ProductionEvent(Event: TProductionPlaceEventLog);
    procedure PlaceChanged(Sender: TObject);
    function ActivityImage(Item: TProductionItem) : Integer;
    procedure SelectProduction(Index: Integer);
    procedure UpdateInfo;
    procedure ShowPlace(Place: TProductionPlace);
    published procedure ProductionScreenCreate; public
    published procedure ProductionScreenDestroy; public
    published procedure ActivityChange(Sender: TObject); public
    published procedure ActivityDoubleClick(Sender: TObject); public
    published procedure ActivityPreDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure MainBtn1Click(Sender: TObject); public
    published procedure MainBtn2Click; public
    published procedure MainBtn3Click; public
    published procedure UFaceDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure QueueLBChange(Sender: TObject); public
    published procedure B4CBUpdate(Sender: TObject); public
    published procedure LoopQueueBoxChange; public
    published procedure CurrentActionImageDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure MapViewDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
    published procedure MapViewUpdate; public
    published procedure DlgHide; public
    published procedure UAbilitiesLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure PPrevClick; public
    published procedure PNextClick; public
  end;


var
  ProductionScreen: TProductionScreen;

function SphereImage(Sphere: TMagicSphere): Integer;

implementation

uses AoWExeForms, AoWWinMan, OverviewUnit, Shipyard;

procedure TProductionScreen.ShowPlace(Place: TProductionPlace);
var
  I: Integer;
  Army: TArmyHS;
  Generator: TRndTacHsm; Center: THexagonSprite;
begin
  Reset;
  FPlace := Place;
  UpdateInfo;
  SetMode(0);
  PlaceInfoMemo.Items.Text := Place.GetDescription.Text;
  for I := 0 to FPlace.FProductionControl.FUnitProductions.GetCount - 1 do
    LoadUnitImages(FPlace.FProductionControl.FUnitProductions.GetItem(I).FUnitIndex);
  FreePreview;
  Generator := TRndTacHsm.Create;
  FPreview := Generator.RandomMap(nil, FPlace.GetXhx, FPlace.GetYhx, FPlace.GetLhx);
  Generator.Free;
  Army := TAoWMapField(FPlace.Owner).GetArmyHS;
  if Army <> nil then
    for I := 0 to Army.FArmy.GetCount - 1 do
      PlaceOverviewUnit(FPreview, Army.FArmy.GetUnit(I), 0, I);
  B5CB.CaptureInput := FPlace.GetBaseIncome <> 0;
  Center := FPreview.FCenterViewLocation;
  begin
    if Center <> nil then
    begin
      HXtoHP(Center.GetXhx, FPreview.FCenterViewLocation.GetYhx, FViewX, FViewY);
      FViewX := FViewX + 16 - MapView.WinWidth div 2;
      FViewY := FViewY + 16 - MapView.WinHeight div 2;
    end
    else
    begin
      FViewX := 800;
      FViewY := 800;
    end;
  end;
  General.Manager.OverlayPriority := 49;
  Dlg.Visible := True;
end;


procedure TProductionScreen.ProductionScreenCreate;
begin
  FImages := TIntegerList.Create;
end;

procedure TProductionScreen.ProductionScreenDestroy;
begin
  FImages.Free;
end;

procedure TProductionScreen.ActivityChange(Sender: TObject);
begin
  General.PlayButtonSound(1);
  if TAOWCheckBox(Sender).Checked then
  begin
    ResetChecks;
    SelectProduction(TAOWCheckBox(Sender).Tag);
    TAOWCheckBox(Sender).Checked := True;
  end;
end;

procedure TProductionScreen.ActivityDoubleClick(Sender: TObject);
begin
  ResetChecks;
  SelectProduction(TAOWCheckBox(Sender).Tag);
  TAOWCheckBox(Sender).Checked := True;
  MainBtn1Click(nil);
end;

procedure TProductionScreen.ActivityPreDraw(Sender: TObject; SD: TSurfaceDesc);
var
  R: TRect;
  Info: TP2UnitShowInfo;
  U: TUnit;
  Item: TProductionItem;
begin
  R := Rect(ActivityPnl2.WinLeft + TAoWComponent(Sender).WinLeft,
    ActivityPnl2.WinTop + TAoWComponent(Sender).WinTop,
    ActivityPnl2.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth,
    ActivityPnl2.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight);
  case TAoWComponent(Sender).Tag of
    0..3: begin
      U := FPlace.FProductionControl.CreateUnitProduction(TAoWComponent(Sender).Tag);
      if U <> nil then
      begin
        Info.Direction := 3;
        Info.Overlays := [];
        Info.Animation := TUnitAnimation(0);
        Info.Frame := 0;
        Info.Looped := False;
        if not FPlace.FProductionControl.FUnitProductions.GetItem(TAoWComponent(Sender).Tag).FResearched then
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
        U.Release;
      end
      else IntGfxMod.CityWin[62].Show(R.Left + 2, R.Top + 2, SD);
    end;
    4: if FPlace.GetBaseIncome <> 0 then
    begin
      Item := TProductionItem.Create(nil);
      Item.FProductionID := 10;
      IntGfxMod.CityWin[ActivityImage(Item)].Show(R.Left + 2, R.Top + 2, SD);
      Item.Free;
    end
    else IntGfxMod.CityWin[62].Show(R.Left + 2, R.Top + 2, SD);
    5: IntGfxMod.CityWin[46].Show(R.Left + 2, R.Top + 2, SD);
  end;
end;

procedure TProductionScreen.MainBtn1Click(Sender: TObject);
var
  Reason: string;
begin
  case FMode of
    0: begin
      SetMode(1);
      SelectDefaultAction;
    end;
    1: case FProductionIndex of
      0..3:
        if FPlace.FProductionControl.FUnitProductions.GetItem(FProductionIndex).FResearched then
        begin
          if FPlace.CanProduce(FProductionIndex, False, Reason) then
          begin
            FPlace.Produce(FProductionIndex, False);
            SetMode(0);
          end
          else AoWHSMap.ShowWarning(Reason);
        end
        else
        begin
          if FPlace.CanResearch(FProductionIndex, False, Reason) then
          begin
            FPlace.Research(FProductionIndex, False);
            SetMode(0);
          end
          else AoWHSMap.ShowWarning(Reason);
        end;
      4:
        if FPlace.CanTrade(False, Reason) then
        begin
          FPlace.Trade(False);
          SetMode(0);
        end
        else AoWHSMap.ShowWarning(Reason);
      5:
        if FPlace.CanRaze(AoWHSMap.FSeatedPlayer, Reason) then
        begin
          FPlace.Raze(AoWHSMap.FSeatedPlayer);
          Dlg.Visible := False;
        end
        else AoWHSMap.ShowWarning(Reason);
    end;
    2: if QueueLB.Selected <> -1 then FPlace.FProductionControl.DeleteProduction(QueueLB.Selected);
  end;
end;

procedure TProductionScreen.MainBtn2Click;
var
  Reason: string;
begin
  case FMode of
    1: case FProductionIndex of
      0..3:
        if FPlace.FProductionControl.FUnitProductions.GetItem(FProductionIndex).FResearched then
        begin
          if FPlace.CanProduce(FProductionIndex, True, Reason) then
          begin
            FPlace.Produce(FProductionIndex, True);
          end
          else AoWHSMap.ShowWarning(Reason);
        end
        else
        begin
          if FPlace.CanResearch(FProductionIndex, True, Reason) then
          begin
            FPlace.Research(FProductionIndex, True);
          end
          else AoWHSMap.ShowWarning(Reason);
        end;
      4:
        if FPlace.CanTrade(True, Reason) then
        begin
          FPlace.Trade(True);
        end
        else AoWHSMap.ShowWarning(Reason);
    end;
    2: if FQueueIndex = 0 then
      if FPlace.FProductionControl.RetryProductionExecution(Reason) then SetMode(0)
      else AoWHSMap.ShowWarning(Reason);
  end;
end;

procedure TProductionScreen.MainBtn3Click;
begin
  General.PlayButtonSound(0);
  if FMode = 0 then Dlg.Visible := False else SetMode(0);
end;

procedure TProductionScreen.UFaceDraw(Sender: TObject; SD: TSurfaceDesc);
var
  U: TUnit;
  R: TRect;
begin
  U := FPlace.FProductionControl.CreateUnitProduction(FProductionIndex);
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

procedure TProductionScreen.QueueLBChange(Sender: TObject);
begin
  if (QueueLB.Selected < FPlace.FProductionControl.FQueue.GetCount) and (FMode <> 0) then
  begin
    if QueueLB.Selected <> -1 then
    begin
      FQueueIndex := QueueLB.Selected;
      if FPlace.FProductionControl.FQueue.GetItem(FQueueIndex).FProductionID = 1 then
        SelectProduction(FPlace.FProductionControl.FQueue.GetItem(FQueueIndex).FParameter)
      else SelectProduction(4);
      SetMode(2);
      QueueLB.Selected := FQueueIndex;
      MainBtn1.Visible := True;
      MainBtn1.Text := TranslateRStr(DeleteRStr);
      if (FQueueIndex = 0) and (FPlace.FProductionControl.FStatus = pcsWaiting) then
      begin
        MainBtn2.Visible := True;
        MainBtn2.Text := TranslateRStr(ExecuteRStr);
      end
      else MainBtn2.Visible := False;
      PPrev.Visible := False;
      PNext.Visible := False;
    end
    else
    begin
      SetMode(1);
      SelectDefaultAction;
    end;
  end
  else if FMode = 2 then QueueLB.Selected := FQueueIndex
  else QueueLB.Selected := -1;
end;

procedure TProductionScreen.B4CBUpdate(Sender: TObject);
begin
  if TAOWCheckBox(Sender).Tag <= 3 then
    TAOWCheckBox(Sender).CaptureInput := FPlace.FProductionControl.FUnitProductions.GetItem(TAOWCheckBox(Sender).Tag) <> nil;
end;

procedure TProductionScreen.LoopQueueBoxChange;
begin
  FPlace.FProductionControl.SetLoopQueueTo(LoopQueueBox.Checked);
end;

procedure TProductionScreen.CurrentActionImageDraw(Sender: TObject; SD: TSurfaceDesc);
var
  Info: TP2UnitShowInfo;
  R: TRect;
  U: TUnit;
begin
  if FPlace.FProductionControl.FQueue.GetCount <> 0 then
    if (FPlace.FProductionControl.FQueue.GetItem(0).FProductionID = 1) or
      (FPlace.FProductionControl.FQueue.GetItem(0).FProductionID = 2) then
    begin
      R := Rect(ActiveActionPnl.WinLeft + TAoWComponent(Sender).WinLeft,
        ActiveActionPnl.WinTop + TAoWComponent(Sender).WinTop,
        ActiveActionPnl.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth,
        ActiveActionPnl.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight);
      with FPlace.FProductionControl do
      if FUnitProductions.GetItem(FSettings.FUnitProductionIndex) <> nil then
      begin
        U := FPlace.FProductionControl.CreateUnitProduction(FPlace.FProductionControl.FSettings.FUnitProductionIndex);
        if U <> nil then
        begin
          Info.Direction := 3;
          Info.Overlays := [];
          Info.Animation := TUnitAnimation(0);
          Info.Frame := 0;
          Info.Looped := False;
          U.ShowEx(R.Left - 12, R.Top - 5, SD, Info);
          U.Release;
        end;
      end;
    end;
end;


procedure TProductionScreen.MapViewDraw(Sender: TObject; SD: TSurfaceDesc);
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

procedure TProductionScreen.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT: begin Dec(FViewX, 16); MapView.FDrawn := False; end;
    VK_RIGHT: begin Inc(FViewX, 16); MapView.FDrawn := False; end;
    VK_UP: begin Dec(FViewY, 16); MapView.FDrawn := False; end;
    VK_DOWN: begin Inc(FViewY, 16); MapView.FDrawn := False; end;
    VK_ESCAPE: Dlg.Visible := False;
  end;
end;

procedure TProductionScreen.MapViewUpdate;
var
  Preview: TAoWCombatMap;
begin
  Preview := FPreview;
  if Preview <> nil then Preview.NewFrame;
  MapView.FDrawn := MapView.FDrawn and Odd(AoWHSMap.Frame);
end;

procedure TProductionScreen.DlgHide;
begin
  ClosePlace;
end;

procedure TProductionScreen.UAbilitiesLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  A: TAbility;
begin
  if (Button = mbRight) and (UAbilitiesLB.Selected > -1) then
  begin
    A := AoWHSSet.FAbilityControl.GetAbility(Integer(UAbilitiesLB.Items.Objects[UAbilitiesLB.Selected]));
    if A <> nil then SetInfoBanner(InfoBanner, A.GetName(nil), A.FDescription);
  end;
end;

procedure TProductionScreen.PPrevClick;
var
  Start, Index: Integer;
  S: TPlayerStructure;
begin
  Start := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.FindChildIndex(FPlace);
  Index := Start;
  Dec(Index);
  if Index < 0 then Index := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetCount - 1;
  while Index <> Start do
  begin
    S := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetStructure(Index);
    if (S is TProductionPlace) and (TProductionPlace(S).GetMagicSphere = msNone) then
    begin
      Index := Start + 1;
      ShowPlace(TProductionPlace(S));
    end;
    Inc(Index, -1);
    if Index < 0 then Index := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetCount - 1;
  end;
end;

procedure TProductionScreen.PNextClick;
var
  Start, Index: Integer;
  S: TPlayerStructure;
begin
  Start := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.FindChildIndex(FPlace);
  Index := Start + (1);
  if Index >= AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetCount then Index := 0;
  while Index <> Start do
  begin
    S := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetStructure(Index);
    if (S is TProductionPlace) and (TProductionPlace(S).GetMagicSphere = msNone) then
    begin
      Index := Start - 1;
      ShowPlace(TProductionPlace(S));
    end;
    Inc(Index, 1);
    if Index >= AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStructures.GetCount then Index := 0;
  end;
end;


procedure TProductionScreen.FreePreview;
begin
  if FPreview <> nil then
  begin
    FPreview.Free;
    FPreview := nil;
  end;
end;

procedure TProductionScreen.ReleaseImages;
var
  I: Integer;
begin
  for I := FImages.Count - 1 downto 0 do
    AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FImages[I]).Release;
  FImages.Clear;
end;

procedure TProductionScreen.LoadUnitImages(Index: Integer);
var
  Gfx: Integer;
begin
  Gfx := AoWHSSet.FUnitResources.GetUnitResource(Index).FUnitGFXResourceIndex;
  AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Gfx).AddRef;
  FImages.Add(Gfx);
end;

procedure TProductionScreen.ResetChecks;
begin
  B1CB.Checked := False;
  B2CB.Checked := False;
  B3CB.Checked := False;
  B4CB.Checked := False;
  B5CB.Checked := False;
  B6CB.Checked := False;
end;

procedure TProductionScreen.Reset;
begin
  ReleaseImages;
  FMode := 0;
  InfoPnl.Visible := True;
  InfoPnl2.Visible := True;
  ActivityPnl.Visible := False;
  ActivityPnl2.Visible := False;
  UnitPnl.Visible := False;
  UpgradePnl.Visible := False;
  MainBtn1.Visible := True;
  MainBtn1.Text := TranslateRStr(OptionsRStr);
  MainBtn2.Visible := False;
  PPrev.Visible := not MainBtn2.Visible;
  PNext.Visible := not MainBtn2.Visible;
  ShadowL.Visible := AoWEngine.FAnimationDetail <> 0;
  ShadowR.Visible := AoWEngine.FAnimationDetail <> 0;
  Oval.Visible := AoWEngine.FAnimationDetail <> 0;
  FQueueIndex := -1;
  QueueLB.Selected := -1;
  QueueLbl.Text := TranslateRStr(QueueRStr);
  RepeatLbl.Text := TranslateRStr(RepeatRStr);
  FreePreview;
end;

procedure TProductionScreen.ClosePlace;
begin
  Reset;
  FPlace := nil;
  General.Manager.OverlayPriority := 0;
end;

procedure TProductionScreen.SetMode(Mode: Byte);
begin
  FMode := Mode;
  case FMode of
    0: begin
      InfoPnl.Visible := True;
      InfoPnl2.Visible := True;
      ActivityPnl.Visible := False;
      ActivityPnl2.Visible := False;
      MainBtn1.Text := TranslateRStr(ChangeRStr);
      MainBtn2.Visible := False;
      PPrev.Visible := not MainBtn2.Visible;
      PNext.Visible := not MainBtn2.Visible;
      MainBtn3.Text := TranslateRStr(ExitRStr);
      QueueLB.Selected := -1;
    end;
    1: begin
      ResetChecks;
      QueueLB.Selected := -1;
      InfoPnl.Visible := False;
      InfoPnl2.Visible := False;
      ActivityPnl.Visible := True;
      ActivityPnl2.Visible := True;
      MainBtn1.Text := TranslateRStr(InfoRStr);
      MainBtn3.Text := TranslateRStr(DoneRStr);
    end;
    2: begin
      ResetChecks;
      QueueLB.Selected := -1;
      InfoPnl.Visible := False;
      InfoPnl2.Visible := False;
      ActivityPnl.Visible := True;
      ActivityPnl2.Visible := True;
      MainBtn1.Text := TranslateRStr(InfoRStr);
      MainBtn3.Text := TranslateRStr(DoneRStr);
    end;
  end;
end;

procedure TProductionScreen.SelectDefaultAction;
begin
  ResetChecks;
  B1CB.Checked := True;
  SelectProduction(0);
end;

procedure TProductionScreen.ProductionEvent(Event: TProductionPlaceEventLog);
begin
  ShowPlace(Event.GetProductionPlace);
  SetMode(1);
  SelectDefaultAction;
end;

procedure TProductionScreen.PlaceChanged(Sender: TObject);
begin
  if Dlg.Visible and (Sender = FPlace) then
    if FPlace.FPlayer = AoWHSMap.FSeatedPlayer then UpdateInfo
    else Dlg.Visible := False;
end;

function TProductionScreen.ActivityImage(Item: TProductionItem) : Integer;
begin
  case Item.FProductionID of
    1: Result := 4;
    10: if FPlace.GetMagicSphere <> msNone then Result := 48
        else Result := 47;
  else Result := 4;
  end;
end;

procedure TProductionScreen.SelectProduction(Index: Integer);
var
  U: TUnit;
  Item: TProductionItem;
begin
  if FMode <> 1 then SetMode(1);
  UpgradePnl.Visible := False;
  UnitPnl.Visible := False;
  FProductionIndex := Index;
  UpgradePic.CurrentImage := 21;
  UpgradeCost.Text := '-';
  UpgradeTurns.Text := '-';
  MainBtn1.Visible := False;
  MainBtn2.Visible := False;
  PPrev.Visible := not MainBtn2.Visible;
  PNext.Visible := not MainBtn2.Visible;
  case FProductionIndex of
    0..3: begin
      U := FPlace.FProductionControl.CreateUnitProduction(FProductionIndex);
      if U <> nil then
      begin
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
      UAbilitiesLB.Items.Clear;
      U.ListAbilities(UAbilitiesLB.Items);
        if FPlace.FProductionControl.FUnitProductions.GetItem(FProductionIndex).FResearched then
        begin
          MainBtn1.Visible := True;
          MainBtn1.Text := TranslateRStr(ProduceRStr);
          MainBtn2.Visible := not FPlace.FProductionControl.GetQueueLocked;
          MainBtn2.Text := TranslateRStr(QueueRStr);
          UnitLbl.Text := AoWE.Format(TranslateRStr(ProduceXRStr), [U.GetName]);
          UCost.Text := IntToStr(FPlace.FProductionControl.UnitProductionGold(FProductionIndex));
          UTurns.Text := IntToStr(FPlace.FProductionControl.UnitProductionTime(FProductionIndex));
        end
        else
        begin
          MainBtn1.Visible := True;
          MainBtn1.Text := TranslateRStr(InstallRStr);
          MainBtn2.Visible := not FPlace.FProductionControl.GetQueueLocked;
          MainBtn2.Text := TranslateRStr(QueueRStr);
          UnitLbl.Text := AoWE.Format(TranslateRStr(InstallXRStr), [U.GetName]);
          UCost.Text := IntToStr(FPlace.FProductionControl.UnitResearchGold(FProductionIndex));
          UTurns.Text := IntToStr(FPlace.FProductionControl.UnitResearchTime(FProductionIndex));
        end;
        PPrev.Visible := not MainBtn2.Visible;
        PNext.Visible := not MainBtn2.Visible;
        U.Release;
      end
      else UnitPnl.Visible := False;
    end;
    4: begin
      MainBtn1.Visible := True;
      Item := TProductionItem.Create(nil);
      Item.FProductionID := 10;
      MainBtn1.Text := FPlace.GetProductionName(Item);
      Item.Free;
      MainBtn2.Visible := not FPlace.FProductionControl.GetQueueLocked;
      MainBtn2.Text := TranslateRStr(QueueRStr);
      PPrev.Visible := not MainBtn2.Visible;
      PNext.Visible := not MainBtn2.Visible;
      if FPlace.GetMagicSphere = msNone then UpgradeMemo.Items.Text := TranslateRStr(ProduceMerchandiseTextRStr)
      else UpgradeMemo.Items.Text := TranslateRStr(GenerateExtraPowerTextRStr);
      UpgradePnl.Visible := True;
      if FPlace.GetMagicSphere <> msNone then UpgradePic.CurrentImage := 28
      else UpgradePic.CurrentImage := 27;
      UpgradeLbl.Text := MainBtn1.Text;
    end;
    5: begin
      MainBtn1.Visible := True;
      MainBtn1.Text := TranslateRStr(RazeRStr) + '...';
      PPrev.Visible := False;
      PNext.Visible := False;
      UpgradeMemo.Items.Text := AoWE.Format(TranslateRStr(ProductionPlaceXRazeRStr), [FPlace.GetName]);
      UpgradePnl.Visible := True;
      UpgradePic.CurrentImage := 26;
      UpgradeLbl.Text := TranslateRStr(RazeRStr);
    end;
  end;
end;

function SphereImage(Sphere: TMagicSphere): Integer;
begin
  case Sphere of
    TMagicSphere(1): Result := 27;
    TMagicSphere(5): Result := 42;
    TMagicSphere(3): Result := 33;
    TMagicSphere(4): Result := 36;
    TMagicSphere(6): Result := 39;
    TMagicSphere(2): Result := 30;
  else Result := -1;
  end;
end;

procedure TProductionScreen.UpdateInfo;
var
  Reason: string;
  I, J: Integer;
  Item: TProductionItem;
begin
  IncomeHdr.Items.Clear;
  StructName.Text := FPlace.GetName;
  IncomeHdr.Items.Add(TranslateRStr(IncomeRStr));
  if FPlace.GetMagicSphere <> msNone then
    IncomeHdr.Items.Add(AoWE.Format(' ' + TranslateRStr(XPowerRStr), [IntToStr(FPlace.GetPower)]));
  if FPlace.GetIncome <> 0 then
    IncomeHdr.Items.Add(AoWE.Format(' ' + TranslateRStr(XGoldRStr), [IntToStr(FPlace.GetIncome)]));
  if FPlace.GetMagicSphere <> msNone then
  begin
    IncomePicture.ILIndexTexture := 64;
    IPPicFr.ILTexture := nil;
    Sphere.SetILUIndex(SphereImage(FPlace.GetMagicSphere));
    Sphere.Visible := True;
  end
  else
  begin
    if FPlace is TShipyard then
    begin
      IncomeHdr.Items.Clear;
      IncomePicture.ILIndexTexture := 68;
    end
    else IncomePicture.ILIndexTexture := 65;
    IPPicFr.ILTexture := IntGfxMod.CityWin;
    if FPlace is TShipyard then IPPicFr.ILIndexTexture := 67
    else IPPicFr.ILIndexTexture := 66;
    Sphere.Visible := False;
  end;
  IncomeMemo.Items.Clear;
  IncomeValuesMemo.Items.Clear;
  FPlace.ListIncomeInfo(IncomeMemo.Items, IncomeValuesMemo.Items);
  QueueLB.Items.Clear;
  for I := 0 to FPlace.FProductionControl.FQueue.GetCount - 1 do
    QueueLB.Items.Add(IntToStr(I + 1) + '. ' + FPlace.FProductionControl.FQueue.GetItem(I).GetName);
  for I := FPlace.FProductionControl.FQueue.GetCount to 4 do
    QueueLB.Items.Add(IntToStr(I + 1) + '. ' + TranslateRStr(EmptyQueueRStr));
  if QueueLB.Selected >= FPlace.FProductionControl.FQueue.GetCount then
  begin
    QueueLB.Selected := FPlace.FProductionControl.FQueue.GetCount - 1;
    FQueueIndex := QueueLB.Selected;
  end;
  LoopQueueBox.Checked := FPlace.FProductionControl.FLoopQueue;
  if FPlace.FProductionControl.FStatus = pcsProducing then
  begin
    ActiveAction.Text := FPlace.FProductionControl.FQueue.GetItem(0).GetNameProgressive;
    if FPlace.FProductionControl.FSettings.FTurnsLeft <> -1 then
    begin
      ActiveActionTurns.Text := FmtTurnsLeftStr(FPlace.FProductionControl.FSettings.FTurnsLeft);
      ActiveActionTurns.Visible := True;
      ActiveActionTurns.TextColor := $678376;
      with ActiveActionTurnsBar do
      begin
        Min := 0;
        Max := FPlace.FProductionControl.FSettings.FTurnsTotal;
        Position := FPlace.FProductionControl.FSettings.FTurnsTotal - FPlace.FProductionControl.FSettings.FTurnsLeft;
      end;
      ActiveActionTurnsBar.Visible := True;
    end
    else
    begin
      ActiveActionTurns.Visible := False;
      ActiveActionTurnsBar.Visible := False;
    end;
    CurrentActionImage.CurrentImage := ActivityImage(FPlace.FProductionControl.FQueue.GetItem(0));
  end
  else if FPlace.FProductionControl.FStatus = pcsIdle then
  begin
    ActiveAction.Text := FPlace.GetCurrentActivityText;
    ActiveActionTurns.Text := '(' + LowerCase(TranslateRStr(DefaultRStr)) + ')';
    ActiveActionTurns.TextColor := $678376;
    if CompareText(ActiveAction.Text, TranslateRStr(NoneRStr)) <> 0 then
    begin
      ActiveActionTurns.Visible := True;
      Item := TProductionItem.Create(nil);
      Item.FProductionID := 10;
      CurrentActionImage.CurrentImage := ActivityImage(Item);
      Item.Free;
    end
    else
    begin
      ActiveActionTurns.Visible := False;
      CurrentActionImage.CurrentImage := 62;
    end;
    ActiveActionTurnsBar.Visible := False;
  end
  else if FPlace.FProductionControl.FStatus = pcsWaiting then
  begin
    Reason := '';
    ActiveAction.Text := FPlace.FProductionControl.FQueue.GetItem(0).GetNameProgressive;
    FPlace.FProductionControl.CanExecuteProduction(FPlace.FProductionControl.FQueue.GetItem(0), Reason);
    ActiveActionTurns.Text := Reason;
    ActiveActionTurns.TextColor := $FF;
    ActiveActionTurns.Visible := True;
    ActiveActionTurnsBar.Visible := False;
    CurrentActionImage.CurrentImage := ActivityImage(FPlace.FProductionControl.FQueue.GetItem(0));
  end;
  case FMode of
    1: if FProductionIndex <> -1 then SelectProduction(FProductionIndex);
    2: QueueLBChange(Self);
  end;
  Dlg.FDrawn := False;
end;

end.
