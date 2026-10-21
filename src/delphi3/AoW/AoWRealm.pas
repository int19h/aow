unit AoWRealm;

{ AoWRealm handlers recovered from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, aowIntGfxMod, AoWWinMan, AoWUnitWindow, AoWCityScreen, AoWProdScreen, PrdPlace, City, aowHelpWin, AoWUnitBanner, AOWGauge, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TRealmWin = class;


  { TRealmWin (instance size 412, VMT 004484F0) }
  TRealmWin = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    OWTitle: TAOWLabel; { +0048 }
    OWTitleIc: TAOWImage; { +004C }
    HeaderTab: TAOWTabPanel; { +0050 }
    T1Pnl: TAOWPanel; { +0054 }
    T2Pnl: TAOWPanel; { +0058 }
    T2LBPnl: TAOWPanel; { +005C }
    T3Pnl: TAOWPanel; { +0060 }
    T3LBPnl: TAOWPanel; { +0064 }
    Minimize: TAOWButton; { +0068 }
    T4Pnl: TAOWPanel; { +006C }
    T4LBPnl: TAOWPanel; { +0070 }
    T2NameLB: TAOWListBox; { +0074 }
    T2RaceLB: TAOWListBox; { +0078 }
    T2IncomeLB: TAOWListBox; { +007C }
    T2LevelLB: TAOWListBox; { +0080 }
    T2WallLB: TAOWListBox; { +0084 }
    T2SizeLB: TAOWListBox; { +0088 }
    T2EncLB: TAOWListBox; { +008C }
    T2SName: TAOWButton; { +0090 }
    T2SRace: TAOWButton; { +0094 }
    T2SIn: TAOWButton; { +0098 }
    T2SWall: TAOWButton; { +009C }
    T2SLvl: TAOWButton; { +00A0 }
    T2SSize: TAOWButton; { +00A4 }
    T2SEnc: TAOWButton; { +00A8 }
    T2ActLB: TAOWListBox; { +00AC }
    T2SAct: TAOWButton; { +00B0 }
    T2RelLB: TAOWListBox; { +00B4 }
    T2SRel: TAOWButton; { +00B8 }
    T2MorLB: TAOWListBox; { +00BC }
    T2SMor: TAOWButton; { +00C0 }
    CitySB: TAOWVScrollBar; { +00C4 }
    T3Name: TAOWListBox; { +00C8 }
    T3SName: TAOWButton; { +00CC }
    T3ActLB: TAOWListBox; { +00D0 }
    T3Activity: TAOWButton; { +00D4 }
    PlaceSB: TAOWVScrollBar; { +00D8 }
    UnitFr: TAoWFrame; { +00DC }
    UnitGg: TAoWGauge; { +00E0 }
    Unit1LB: TAOWListBox; { +00E4 }
    Unit2LB: TAOWListBox; { +00E8 }
    Unit3LB: TAOWListBox; { +00EC }
    Unit4LB: TAOWListBox; { +00F0 }
    Unit5LB: TAOWListBox; { +00F4 }
    Unit6LB: TAOWListBox; { +00F8 }
    Unit7LB: TAOWListBox; { +00FC }
    Unit8LB: TAOWListBox; { +0100 }
    PartySb: TAOWVScrollBar; { +0104 }
    HeroPnl: TAOWPanel; { +0108 }
    T5MainPnl: TAOWPanel; { +010C }
    T5Name: TAOWListBox; { +0110 }
    T5Health: TAOWListBox; { +0114 }
    T5Level: TAOWListBox; { +0118 }
    T5SName: TAOWButton; { +011C }
    T5SHealth: TAOWButton; { +0120 }
    T5SLevel: TAOWButton; { +0124 }
    T5HeroInf: TAOWPanel; { +0128 }
    T5LBFr: TAOWPanel; { +012C }
    HInfoBtn: TAOWButton; { +0130 }
    HeroSB: TAOWVScrollBar; { +0134 }
    TotalPnl: TAOWPanel; { +0138 }
    IncomePnl: TAOWPanel; { +013C }
    IncomeMem: TAOWMemo; { +0140 }
    IncomeBtm: TAOWPanel; { +0144 }
    IncomeSB: TAOWVScrollBar; { +0148 }
    IncomeLbl: TAOWLabel; { +014C }
    Income: TAOWLabel; { +0150 }
    UpkeepPnl: TAOWPanel; { +0154 }
    UpkeepMem: TAOWMemo; { +0158 }
    UpkeepBtm: TAOWPanel; { +015C }
    UpkeepSB: TAOWVScrollBar; { +0160 }
    UpkeepLbl: TAOWLabel; { +0164 }
    Upkeep: TAOWLabel; { +0168 }
    Totallbl: TAOWLabel; { +016C }
    NetInc: TAOWLabel; { +0170 }
    TotalBtm: TAOWPanel; { +0174 }
    TreasuryLbl: TAOWLabel; { +0178 }
    Treasury: TAOWLabel; { +017C }
    TreasuryPnl: TAOWPanel; { +0180 }
    IncomeValue: TAOWMemo; { +0184 }
    UpkeepValue: TAOWMemo; { +0188 }
    GoldAnim: TAOWImage; { +018C }
    PicPnl: TAOWPanel; { +0190 }
    Help: TAOWButton; { +0194 }
    Translator: TIvTranslator; { +0198 }
    public
    procedure UpdateOverview; { draft; 00449B30 }
    procedure DrawArmyUnit(Column: Integer; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc); { 0044A030 }
    procedure OWMinIconClick;
    procedure T2WallLBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
    procedure Unit1LBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
    procedure HeaderTabChange;
    procedure PartyVSBChange;
    procedure Unit1LBChange(Sender: TObject);
    procedure T2MorLBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
    procedure CityListMouseDown(Sender: TAOWListBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CityListChange(Sender: TObject);
    procedure CityDoubleClick(Sender: TObject);
    procedure PlaceListDoubleClick(Sender: TObject);
    procedure PlacesListMouseDown(Sender: TAOWListBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HeroListDoubleClick(Sender: TObject);
    procedure HeroListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HeroInfoClick;
    procedure T2LevelLBDoubleClick;
    procedure T2WallLBDoubleClick;
    procedure T2RaceLBDoubleClick;
    procedure T2ActLBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
    procedure T2ActLBDoubleClick;
    procedure T2RelLBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
    procedure OverWindowResize;
    procedure T2SBChange;
    procedure T3NameChange(Sender: TObject);
    procedure T3SBChange;
    procedure T2SNameClick(Sender: TObject; Button: Integer);
    procedure T2SRaceClick(Sender: TObject; Button: Integer);
    procedure T2SInClick(Sender: TObject; Button: Integer);
    procedure T2SLvlClick(Sender: TObject; Button: Integer);
    procedure T2SWallClick(Sender: TObject; Button: Integer);
    procedure T2SSizeClick(Sender: TObject; Button: Integer);
    procedure T2SRelClick(Sender: TObject; Button: Integer);
    procedure T2SMorClick(Sender: TObject; Button: Integer);
    procedure T2SActClick(Sender: TObject; Button: Integer);
    procedure T2SEncClick(Sender: TObject; Button: Integer);
    procedure T3SNameClick(Sender: TObject; Button: Integer);
    procedure HeroListChange(Sender: TObject);
    procedure HeroVSBChange;
    procedure T5HeroInfDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure Unit1LBDoubleClick(Sender: TObject);
    procedure T5SNameClick(Sender: TObject; Button: Integer);
    procedure T5SHealthClick(Sender: TObject; Button: Integer);
    procedure T5SLevelClick(Sender: TObject; Button: Integer);
    procedure GotoButClick;
    procedure T4PnlShow(Sender: TObject);
    procedure T4PnlHide(Sender: TObject);
    procedure OverWindowShow;
    procedure OverWindowHide;
    procedure IncomeSBChange;
    procedure T3ActivityClick(Sender: TObject; Button: Integer);
    procedure UpkeepSBChange;
    procedure DlgShow;
    procedure DlgHide;
    procedure HelpClick;
  end;


var
  RealmWin: TRealmWin;

implementation

procedure TRealmWin.UpdateOverview;
begin end;

procedure TRealmWin.DrawArmyUnit(Column: Integer; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
var
  U: TAbstractUnit;
  OldClip: TRect;
begin
  if Column < AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(DrawItem).GetCount then
  begin
    OldClip := SurfDesc.ClipRect;
    SurfDesc.ClipRect.Left := DrawRect.Left + 2;
    SurfDesc.ClipRect.Top := DrawRect.Top + 1;
    SurfDesc.ClipRect.Right := DrawRect.Right - 2;
    SurfDesc.ClipRect.Bottom := DrawRect.Top + Unit1LB.ItemHeight - 6;
    if DrawRect.Bottom - DrawRect.Top < Unit1LB.ItemHeight - 6 then SurfDesc.ClipRect.Bottom := DrawRect.Bottom;
    U := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(DrawItem).GetUnit(Column);
    if (Ord(U.GetAlignment) and $7F) < IntGfxMod.UnitBGs.Count then
      IntGfxMod.UnitBGs[Ord(U.GetAlignment)].ShowClipped(
        DrawRect.Left - (IntGfxMod.UnitBGs[Ord(U.GetAlignment)].Width - (DrawRect.Right - DrawRect.Left)) div 2,
        DrawRect.Top - (IntGfxMod.UnitBGs[Ord(U.GetAlignment)].Height - (DrawRect.Bottom - DrawRect.Top - 10)) div 2,
        SurfDesc);
    U.ShowEx(DrawRect.Left - (U.GetPreviewImage.Width - (DrawRect.Right - DrawRect.Left)) div 2,
      DrawRect.Top - (U.GetPreviewImage.Height - (Unit1LB.ItemHeight - 10)) div 2, SurfDesc, General.FUnitShowInfo);
    with UnitGg do
    begin
      Visible := True;
      Max := U.GetHits;
      Position := U.GetHitPoints;
      WinLeft := DrawRect.Left - T4LBPnl.WinLeft + 5;
      WinWidth := DrawRect.Right - DrawRect.Left - 10;
      WinTop := DrawRect.Top + Unit1LB.ItemHeight - T4LBPnl.WinTop - 9;
      ReAlign;
      DrawSurfDesc(SurfDesc);
      Visible := False;
    end;
    SurfDesc.ClipRect := OldClip;
  end;
end;

procedure TRealmWin.OWMinIconClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TRealmWin.T2WallLBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
begin
  case PChar(T2WallLB.Items[DrawItem])^ of
    '1': IntGfxMod.LBIcons[7].ShowClipped(DrawRect.Left + (DrawRect.Right - DrawRect.Left) div 2 -
      IntGfxMod.LBIcons[7].Width div 2, DrawRect.Top, SurfDesc);
    '2': IntGfxMod.LBIcons[8].ShowClipped(DrawRect.Left + (DrawRect.Right - DrawRect.Left) div 2 -
      IntGfxMod.LBIcons[8].Width div 2, DrawRect.Top, SurfDesc);
  end;
end;

procedure TRealmWin.Unit1LBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
begin
  DrawArmyUnit(Sender.Tag, DrawRect, DrawItem, SurfDesc);
end;

procedure TRealmWin.HeaderTabChange;
begin
  General.PlayButtonSound(0);
  UpdateOverview;
end;

procedure TRealmWin.PartyVSBChange;
begin
  Unit1LB.ListOffset := PartySb.Position;
  Unit2LB.ListOffset := PartySb.Position;
  Unit3LB.ListOffset := PartySb.Position;
  Unit4LB.ListOffset := PartySb.Position;
  Unit5LB.ListOffset := PartySb.Position;
  Unit6LB.ListOffset := PartySb.Position;
  Unit7LB.ListOffset := PartySb.Position;
  Unit8LB.ListOffset := PartySb.Position;
end;

procedure TRealmWin.Unit1LBChange(Sender: TObject);
begin
  with TAOWListBox(Sender) do
  begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(Selected).GetCount > 0 then
  begin
    PopupMenu := UnitBanner.BannerPopup;
    General.FSelectedUnit := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(Selected).GetUnit(Tag);
    AoWHSMap.Select(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(Selected).GetArmyHS, True);
    Dlg.Priority := Dlg.Priority;
  end
  else
  begin
    PopupMenu := nil;
    Selected := -1;
  end;
  if Sender <> Unit1LB then Unit1LB.Selected := -1;
  if Sender <> Unit2LB then Unit2LB.Selected := -1;
  if Sender <> Unit3LB then Unit3LB.Selected := -1;
  if Sender <> Unit4LB then Unit4LB.Selected := -1;
  if Sender <> Unit5LB then Unit5LB.Selected := -1;
  if Sender <> Unit6LB then Unit6LB.Selected := -1;
  if Sender <> Unit7LB then Unit7LB.Selected := -1;
  if Sender <> Unit8LB then Unit8LB.Selected := -1;
  end;
end;

procedure TRealmWin.T2MorLBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
var
  Icon: Integer;
begin
  Icon := Ord(PChar(T2MorLB.Items[DrawItem])^) - Ord('0');
  IntGfxMod.LBIcons[Icon + 9].ShowClipped(DrawRect.Left + (DrawRect.Right - DrawRect.Left) div 2 -
      IntGfxMod.LBIcons[Icon + 9].Width div 2, DrawRect.Top, SurfDesc);
end;

procedure TRealmWin.CityListMouseDown(Sender: TAOWListBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Sprite: THexagonSprite;
begin
  if (Button = mbRight) and (Sender.Selected <> -1) then
  begin
    Sprite := THexagonSprite(T2NameLB.Items.Objects[Sender.Selected]);
    AoWHSMap.CenterViewTo(Sprite.GetXhx, Sprite.GetYhx, Sprite.GetLhx);
    AoWHSMap.PlayCenterAnimation(Sprite.GetXhx, Sprite.GetYhx, Sprite.GetLhx);
  end;
end;

procedure TRealmWin.CityListChange(Sender: TObject);
begin
  with TAOWListBox(Sender) do
  begin
  T2NameLB.Selected := Selected;
  T2RaceLB.Selected := Selected;
  T2IncomeLB.Selected := Selected;
  T2LevelLB.Selected := Selected;
  T2WallLB.Selected := Selected;
  T2SizeLB.Selected := Selected;
  T2RelLB.Selected := Selected;
  T2MorLB.Selected := Selected;
  T2ActLB.Selected := Selected;
  T2EncLB.Selected := Selected;
  end;
end;

procedure TRealmWin.CityDoubleClick(Sender: TObject);
begin
  if TAOWListBox(Sender).Selected <> -1 then
    CityScreen.ShowCity(TCity(T2NameLB.Items.Objects[TAOWListBox(Sender).Selected]));
end;

procedure TRealmWin.PlaceListDoubleClick(Sender: TObject);
begin
  if TAOWListBox(Sender).Selected <> -1 then
    if T3Name.Items.Objects[TAOWListBox(Sender).Selected] is TProductionPlace then
      ProductionScreen.ShowPlace(TProductionPlace(T3Name.Items.Objects[TAOWListBox(Sender).Selected]))
    else
      AoWHSMap.Select(THexagonSprite(T3Name.Items.Objects[TAOWListBox(Sender).Selected]), True);
end;

procedure TRealmWin.PlacesListMouseDown(Sender: TAOWListBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Sprite: THexagonSprite;
begin
  if (Button = mbRight) and (Sender.Selected <> -1) then
  begin
    Sprite := THexagonSprite(T3Name.Items.Objects[Sender.Selected]);
    AoWHSMap.CenterViewTo(Sprite.GetXhx, Sprite.GetYhx, Sprite.GetLhx);
    AoWHSMap.PlayCenterAnimation(Sprite.GetXhx, Sprite.GetYhx, Sprite.GetLhx);
  end;
end;

procedure TRealmWin.HeroListDoubleClick(Sender: TObject);
begin
  with TAOWListBox(Sender) do
  begin
  if Selected <> -1 then
    AoWHSMap.Select(TArmy(T5Name.Items.Objects[Selected]).GetArmyHS, True);
  end;
end;

procedure TRealmWin.HeroListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Sprite: THexagonSprite;
begin
  with TAOWListBox(Sender) do
  begin
  if Selected <> -1 then
  begin
    Sprite := TArmy(T5Name.Items.Objects[Selected]).GetArmyHS;
    AoWHSMap.CenterViewTo(Sprite.GetXhx, Sprite.GetYhx, Sprite.GetLhx);
    AoWHSMap.PlayCenterAnimation(Sprite.GetXhx, Sprite.GetYhx, Sprite.GetLhx);
  end;
  end;
end;

procedure TRealmWin.HeroInfoClick;
var
  Index: Integer;
begin
  General.PlayButtonSound(0);
  Index := T5Name.Selected;
  if Index <> -1 then
  begin
    General.FSelectedUnit := THero(T5Health.Items.Objects[Index]);
    UnitWindow.ShowUnit;
  end;
end;

procedure TRealmWin.T2LevelLBDoubleClick;
begin
  RealmWin.UpdateOverview;
  RealmWin.Dlg.Visible := True;
end;

procedure TRealmWin.T2WallLBDoubleClick;
begin
  RealmWin.UpdateOverview;
  RealmWin.Dlg.Visible := True;
end;

procedure TRealmWin.T2RaceLBDoubleClick;
begin
  RealmWin.UpdateOverview;
  RealmWin.Dlg.Visible := True;
end;

procedure TRealmWin.T2ActLBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
var
  Icon: Char;
begin
  Icon := PChar(T2ActLB.Items[DrawItem])^;
  if Icon <> '-' then
    IntGfxMod.LBIcons[Ord(Icon) - 23].ShowClipped(DrawRect.Left + (DrawRect.Right - DrawRect.Left) div 2 -
      IntGfxMod.LBIcons[Ord(Icon) - 23].Width div 2, DrawRect.Top, SurfDesc);
end;

procedure TRealmWin.T2ActLBDoubleClick;
begin
  RealmWin.UpdateOverview;
  RealmWin.Dlg.Visible := True;
end;

procedure TRealmWin.T2RelLBDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
var
  Icon: Integer;
begin
  Icon := Ord(PChar(T2RelLB.Items[DrawItem])^) - Ord('0');
  IntGfxMod.LBIcons[Icon + 14].ShowClipped(DrawRect.Left + (DrawRect.Right - DrawRect.Left) div 2 -
      IntGfxMod.LBIcons[Icon + 14].Width div 2, DrawRect.Top, SurfDesc);
end;

procedure TRealmWin.OverWindowResize;
begin
  with Dlg do
  begin
    Alignment.AlignWidth := awLeft;
    Alignment.AlignHeight := ahTop;
    Alignment.LeftOffset := WinLeft;
    Alignment.TopOffset := WinTop;
  end;
end;

procedure TRealmWin.T2SBChange;
begin
  T2NameLB.ListOffset := CitySB.Position;
  T2RaceLB.ListOffset := CitySB.Position;
  T2IncomeLB.ListOffset := CitySB.Position;
  T2LevelLB.ListOffset := CitySB.Position;
  T2WallLB.ListOffset := CitySB.Position;
  T2SizeLB.ListOffset := CitySB.Position;
  T2RelLB.ListOffset := CitySB.Position;
  T2MorLB.ListOffset := CitySB.Position;
  T2ActLB.ListOffset := CitySB.Position;
end;

procedure TRealmWin.T3NameChange(Sender: TObject);
begin
  with TAOWListBox(Sender) do
  begin
  T3Name.Selected := Selected;
  T3ActLB.Selected := Selected;
  end;
end;

procedure TRealmWin.T3SBChange;
begin
  T3Name.ListOffset := PlaceSB.Position;
end;

procedure TRealmWin.T2SNameClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2ActLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 0);
end;

procedure TRealmWin.T2SRaceClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2RaceLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2ActLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 0);
end;

procedure TRealmWin.T2SInClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2IncomeLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2ActLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 2);
end;

procedure TRealmWin.T2SLvlClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2LevelLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2ActLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 1);
end;

procedure TRealmWin.T2SWallClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2WallLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2ActLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 1);
end;

procedure TRealmWin.T2SSizeClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2SizeLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2ActLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 1);
end;

procedure TRealmWin.T2SRelClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2RelLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2ActLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 1);
end;

procedure TRealmWin.T2SMorClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2MorLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2ActLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 1);
end;

procedure TRealmWin.T2SActClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2ActLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2EncLB);
  General.SortLists(Lists, 1);
end;

procedure TRealmWin.T2SEncClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T2EncLB);
  Lists.Add(T2NameLB);
  Lists.Add(T2RaceLB);
  Lists.Add(T2IncomeLB);
  Lists.Add(T2LevelLB);
  Lists.Add(T2WallLB);
  Lists.Add(T2SizeLB);
  Lists.Add(T2RelLB);
  Lists.Add(T2MorLB);
  Lists.Add(T2ActLB);
  General.SortLists(Lists, 0);
end;

procedure TRealmWin.T3SNameClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T3Name);
  Lists.Add(T3ActLB);
  General.SortLists(Lists, 0);
end;

procedure TRealmWin.HeroListChange(Sender: TObject);
begin
  with TAOWListBox(Sender) do
  begin
  T5Name.Selected := Selected;
  T5Health.Selected := Selected;
  T5Level.Selected := Selected;
  end;
end;

procedure TRealmWin.HeroVSBChange;
begin
  { Original bug: the hero scrollbar moves T3Name instead of T5Name. }
  T3Name.ListOffset := HeroSB.Position;
  T5Health.ListOffset := HeroSB.Position;
  T5Level.ListOffset := HeroSB.Position;
end;

procedure TRealmWin.T5HeroInfDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  Index: Integer;
  Hero: THero;
  R: TRect;
begin
  Index := T5Name.Selected;
  if Index > -1 then
  begin
    Hero := THero(T5Health.Items.Objects[Index]);
    R := Rect(T5HeroInf.WinLeft + 1, T5HeroInf.WinTop + 1,
      T5HeroInf.WinLeft + T5HeroInf.WinWidth - 1,
      T5HeroInf.WinTop + T5HeroInf.WinHeight - 1);
    if Hero.GetFace <> nil then Hero.ShowFace(R, SurfDesc);
  end;
end;

procedure TRealmWin.Unit1LBDoubleClick(Sender: TObject);
begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(TAOWListBox(Sender).Selected).GetCount > 0 then
  begin
    General.FSelectedUnit := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(TAOWListBox(Sender).Selected).GetUnit(TAOWListBox(Sender).Tag);
    UnitWindow.ShowUnit;
  end;
end;

procedure TRealmWin.T5SNameClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T5Name);
  Lists.Add(T5Health);
  Lists.Add(T5Level);
  General.SortLists(Lists, 0);
end;

procedure TRealmWin.T5SHealthClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T5Health);
  Lists.Add(T5Name);
  Lists.Add(T5Level);
  General.SortLists(Lists, 1);
end;

procedure TRealmWin.T5SLevelClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T5Level);
  Lists.Add(T5Name);
  Lists.Add(T5Health);
  General.SortLists(Lists, 2);
end;

procedure TRealmWin.GotoButClick;
begin
  General.PlayButtonSound(0);
end;

procedure TRealmWin.T4PnlShow(Sender: TObject);
var
  I, J: Integer;
begin
  for I := 0 to AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetCount - 1 do
    for J := 0 to AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(I).GetCount - 1 do
      AoWHSSet.FUnitGFXResources.GetUnitGFXResource(
        AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(I).GetUnit(J).GetUnitGFXResourceIndex).AddRef;
end;

procedure TRealmWin.T4PnlHide(Sender: TObject);
var
  I, J: Integer;
begin
  for I := 0 to AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetCount - 1 do
    for J := 0 to AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(I).GetCount - 1 do
      AoWHSSet.FUnitGFXResources.GetUnitGFXResource(
        AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FArmies.GetArmy(I).GetUnit(J).GetUnitGFXResourceIndex).Release;
end;

procedure TRealmWin.OverWindowShow;
begin
  if T4Pnl.Visible then T4PnlShow(Self);
end;

procedure TRealmWin.OverWindowHide;
begin
  if T4Pnl.Visible then T4PnlHide(Self);
end;

procedure TRealmWin.IncomeSBChange;
begin
  IncomeValue.ListOffset := IncomeSB.Position;
end;

procedure TRealmWin.T3ActivityClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T3ActLB);
  Lists.Add(T3Name);
  General.SortLists(Lists, 1);
end;

procedure TRealmWin.UpkeepSBChange;
begin
  UpkeepValue.ListOffset := UpkeepSB.Position;
end;

procedure TRealmWin.DlgShow;
begin
  General.RegisterDialog(Dlg);
end;

procedure TRealmWin.DlgHide;
begin
  General.UnregisterDialog(Dlg);
end;

procedure TRealmWin.HelpClick;
begin
  ShowHelp(505);
end;


end.
