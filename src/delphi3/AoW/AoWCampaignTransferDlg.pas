unit AoWCampaignTransferDlg;

{ Draft declarations of AoWCampaignTransferDlg, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWComp, AoWE, AoWBookWindow, AoWButton, AoWCheckBox, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWPanel;

type
  TCampaignTransferDlg = class;


  { TCampaignTransferDlg (instance size $1D0, VMT 0040C058).
    $1A8/$1AC hero scroll; $1B0/$1B4 unit scroll; $1B8/$1BC item scroll;
    $1C0/$1C4 left selection kind/index; $1C8/$1CC right selection kind/index. }
  TCampaignTransferDlg = class(TDataModule)
  public
    published
    LHero1: TAOWCheckBox; { +0044 }
    LHero2: TAOWCheckBox; { +0048 }
    LHero3: TAOWCheckBox; { +004C }
    LHero4: TAOWCheckBox; { +0050 }
    LItem1: TAOWCheckBox; { +0054 }
    LItemPnl: TAOWPanel; { +0058 }
    LItem2: TAOWCheckBox; { +005C }
    LItem3: TAOWCheckBox; { +0060 }
    LItem4: TAOWCheckBox; { +0064 }
    LUnit1: TAOWCheckBox; { +0068 }
    LUnitPnl: TAOWPanel; { +006C }
    LUnit2: TAOWCheckBox; { +0070 }
    LUnit3: TAOWCheckBox; { +0074 }
    LUnit4: TAOWCheckBox; { +0078 }
    Available: TAOWLabel; { +007C }
    TransBookWin: TAoWBookWindow; { +0080 }
    BookStart: TAOWButton; { +0084 }
    Cancel: TAOWButton; { +0088 }
    PnlL: TAOWPanel; { +008C }
    Title: TAOWLabel; { +0090 }
    PnlR: TAOWPanel; { +0094 }
    TransferPointsLbl: TAOWLabel; { +0098 }
    AddBtn: TAOWButton; { +009C }
    LGoldLbl: TAOWLabel; { +00A0 }
    GoldLeftLbl: TAOWLabel; { +00A4 }
    LManaLbl: TAOWLabel; { +00A8 }
    ManaLeftLbl: TAOWLabel; { +00AC }
    Next: TAOWLabel; { +00B0 }
    LSep1: TAoWFrame; { +00B4 }
    LHeroImgL: TAOWImage; { +00B8 }
    LHeroPnl: TAOWPanel; { +00BC }
    LItemImgL: TAOWImage; { +00C0 }
    LUnitImgL: TAOWImage; { +00C4 }
    LHeroImgR: TAOWImage; { +00C8 }
    LItemImgR: TAOWImage; { +00CC }
    LUnitImgR: TAOWImage; { +00D0 }
    RHero1: TAOWCheckBox; { +00D4 }
    RHero2: TAOWCheckBox; { +00D8 }
    RHero3: TAOWCheckBox; { +00DC }
    RHero4: TAOWCheckBox; { +00E0 }
    RItem1: TAOWCheckBox; { +00E4 }
    RItemPnl: TAOWPanel; { +00E8 }
    RItem2: TAOWCheckBox; { +00EC }
    RItem3: TAOWCheckBox; { +00F0 }
    RItem4: TAOWCheckBox; { +00F4 }
    RUnit1: TAOWCheckBox; { +00F8 }
    RUnitPnl: TAOWPanel; { +00FC }
    RUnit2: TAOWCheckBox; { +0100 }
    RUnit3: TAOWCheckBox; { +0104 }
    RUnit4: TAOWCheckBox; { +0108 }
    RHeroImgL: TAOWImage; { +010C }
    RHeroPnl: TAOWPanel; { +0110 }
    RItemImgL: TAOWImage; { +0114 }
    RUnitImgL: TAOWImage; { +0118 }
    RHeroImgR: TAOWImage; { +011C }
    RItemImgR: TAOWImage; { +0120 }
    RUnitImgR: TAOWImage; { +0124 }
    RSep1: TAoWFrame; { +0128 }
    RemoveBtn: TAOWButton; { +012C }
    LSep2: TAoWFrame; { +0130 }
    RSep2: TAoWFrame; { +0134 }
    GoldSlider: TAOWHScrollBar; { +0138 }
    ManaSlider: TAOWHScrollBar; { +013C }
    LHeroLB: TAOWButton; { +0140 }
    AutoBtn: TAOWButton; { +0144 }
    LItemLB: TAOWButton; { +0148 }
    LUnitLB: TAOWButton; { +014C }
    LHeroRB: TAOWButton; { +0150 }
    LItemRB: TAOWButton; { +0154 }
    LUnitRB: TAOWButton; { +0158 }
    RHeroLB: TAOWButton; { +015C }
    RItemLB: TAOWButton; { +0160 }
    RUnitLB: TAOWButton; { +0164 }
    RHeroRB: TAOWButton; { +0168 }
    RItemRB: TAOWButton; { +016C }
    RUnitRB: TAOWButton; { +0170 }
    CostImg: TAOWImage; { +0174 }
    CostPnl: TAOWPanel; { +0178 }
    CostLbl: TAOWLabel; { +017C }
    LGoldImg: TAOWImage; { +0180 }
    LManaImg: TAOWImage; { +0184 }
    TGoldLbl: TAOWLabel; { +0188 }
    TransferGoldLbl: TAOWLabel; { +018C }
    TManaLbl: TAOWLabel; { +0190 }
    TransferManaLbl: TAOWLabel; { +0194 }
    RGoldImg: TAOWImage; { +0198 }
    RManaImg: TAOWImage; { +019C }
    ResBackG: TAOWImage; { +01A0 }
    Translator: TIvTranslator; { +01A4 }
    public
    FLeftHero: Integer; { $1A8 }
    FRightHero: Integer; { $1AC }
    FLeftUnit: Integer; { $1B0 }
    FRightUnit: Integer; { $1B4 }
    FLeftItem: Integer; { $1B8 }
    FRightItem: Integer; { $1BC }
    FLeftKind: Byte; { $1C0 }
    F_CampaignTransferDlg_1C1: array[0..2] of Byte;
    FLeftSelection: Integer; { $1C4 }
    FRightKind: Byte; { $1C8 }
    F_CampaignTransferDlg_1C9: array[0..2] of Byte;
    FRightSelection: Integer; { $1CC }
    procedure UpdateControls;
    procedure ResetSelection;
    procedure ClearLeftSelection;
    procedure ClearRightSelection;
    procedure Execute;
    published procedure BookStartClick(Sender: TObject); public  { draft }
    published procedure CancelClick; public  { draft }
    published procedure GoldSliderChange(Sender: TObject); public
    published procedure ManaSliderChange(Sender: TObject); public
    published procedure LHeroLBClick(Sender: TObject); public
    published procedure LHeroRBClick(Sender: TObject); public
    published procedure LItemLBClick(Sender: TObject); public
    published procedure LItemRBClick(Sender: TObject); public
    published procedure LUnitLBClick(Sender: TObject); public
    published procedure LUnitRBClick(Sender: TObject); public
    published procedure RHeroLBClick(Sender: TObject); public
    published procedure RHeroRBClick(Sender: TObject); public
    published procedure RItemLBClick(Sender: TObject); public
    published procedure RItemRBClick(Sender: TObject); public
    published procedure RUnitLBClick(Sender: TObject); public
    published procedure RUnitRBClick(Sender: TObject); public
    published procedure LHeroesDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc); public
    published procedure RHeroesDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc); public
    published procedure LUnitsDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc); public
    published procedure RUnitsDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc); public
    published procedure LItemsDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc); public
    published procedure RItemsDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc); public
    published procedure LHeroesSelect(Sender: TObject); public
    published procedure LItemsSelect(Sender: TObject); public
    published procedure LUnitSelect(Sender: TObject); public
    published procedure RHeroesSelect(Sender: TObject); public
    published procedure RItemsSelect(Sender: TObject); public
    published procedure RUnitsSelect(Sender: TObject); public
    published procedure AddBtnClick(Sender: TObject); public
    published procedure RemoveBtnClick(Sender: TObject); public
    published procedure LHeroesUpdate(Sender: TObject); public
    published procedure LItemsUpdate(Sender: TObject); public
    published procedure LUnitsUpdate(Sender: TObject); public
    published procedure RHeroesUpdate(Sender: TObject); public
    published procedure RItemsUpdate(Sender: TObject); public
    published procedure RUnitsUpdate(Sender: TObject); public
    published procedure AutoBtnClick(Sender: TObject); public
  end;


implementation

uses E3Globals;

procedure TCampaignTransferDlg.BookStartClick(Sender: TObject);
begin
  TransBookWin.Visible := False;
  PlaySample('Sfx\Int\BookClse.wav');
  Inc(WorldMap.GetCampaign.FState);
  WorldMap.UpdateCampaignState;
end;

procedure TCampaignTransferDlg.CancelClick;
begin
  TransBookWin.Visible := False;
  AoWEngine.FCampaign.ResetNextScenario;
  PlaySample('Sfx\Int\BookClse.wav');
  WorldMap.GetCampaign.FState := 1;
  WorldMap.UpdateCampaignState;
end;

procedure TCampaignTransferDlg.GoldSliderChange(Sender: TObject);
begin
  with AoWEngine.FCampaign.FTransferSettings do
    SetSelectedTransferGold(GoldSlider.Position);
  UpdateControls;
end;

procedure TCampaignTransferDlg.ManaSliderChange(Sender: TObject);
begin
  with AoWEngine.FCampaign.FTransferSettings do
    SetSelectedTransferMana(ManaSlider.Position);
  UpdateControls;
end;

procedure TCampaignTransferDlg.LHeroLBClick(Sender: TObject);
begin
  if FLeftHero <> 0 then Dec(FLeftHero);
  LHeroPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.LHeroRBClick(Sender: TObject);
begin
  if AoWEngine.FCampaign.FTransferSettings.FHeroes.Count > FLeftHero + 4 then Inc(FLeftHero);
  LHeroPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.LItemLBClick(Sender: TObject);
begin
  if FLeftItem <> 0 then Dec(FLeftItem);
  LItemPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.LItemRBClick(Sender: TObject);
begin
  if AoWEngine.FCampaign.FTransferSettings.FItems.Count > FLeftItem + 4 then Inc(FLeftItem);
  LItemPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.LUnitLBClick(Sender: TObject);
begin
  if FLeftUnit <> 0 then Dec(FLeftUnit);
  LUnitPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.LUnitRBClick(Sender: TObject);
begin
  if AoWEngine.FCampaign.FTransferSettings.FUnits.Count > FLeftUnit + 4 then Inc(FLeftUnit);
  LUnitPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.RHeroLBClick(Sender: TObject);
begin
  if FRightHero <> 0 then Dec(FRightHero);
  RHeroPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.RHeroRBClick(Sender: TObject);
begin
  if FRightHero + 4 < AoWEngine.FCampaign.FTransferSettings.FSelectedHeroes.Count then Inc(FRightHero);
  RHeroPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.RItemLBClick(Sender: TObject);
begin
  if FRightItem <> 0 then Dec(FRightItem);
  RItemPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.RItemRBClick(Sender: TObject);
begin
  if FRightItem + 4 < AoWEngine.FCampaign.FTransferSettings.FSelectedItems.Count then Inc(FRightItem);
  RItemPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.RUnitLBClick(Sender: TObject);
begin
  if FRightUnit <> 0 then Dec(FRightUnit);
  RUnitPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.RUnitRBClick(Sender: TObject);
begin
  if FRightUnit + 4 < AoWEngine.FCampaign.FTransferSettings.FSelectedUnits.Count then Inc(FRightUnit);
  RUnitPnl.FDrawn := False;
  UpdateControls;
end;

procedure TCampaignTransferDlg.LHeroesDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  Obj: THero;
  S: TAoWCampaignTransferSettings;
  R: TRect;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  Obj := S.FHeroes.GetHero(FLeftHero + Sender.Tag);
  if Obj <> nil then
  begin
    with TAOWCheckBox(Sender) do
    R := Classes.Rect(LHeroPnl.WinLeft + WinLeft + 1,
      LHeroPnl.WinTop + WinTop + 2,
      LHeroPnl.WinLeft + WinLeft + WinWidth - 2,
      LHeroPnl.WinTop + WinTop + WinHeight - 2);
    Inc(R.Left);
    Obj.ShowFace(R, SurfDesc);
    Dec(R.Left);
    if S.FSelectedHeroes.IndexOf(FLeftHero + Sender.Tag) <> -1 then
      IntGfxMod.CityWin[5].ShowBlended(R.Left, R.Top, SurfDesc, AlphaBlendTable.LookupTables[65]);
    if TAOWCheckBox(Sender).FLit then
      IntGfxMod.CampaignTrans[20].ShowBlended(R.Left - 1, R.Top - 2, SurfDesc, IntensityBlendTable.LookupTables[50]);
    IntGfxMod.CampaignTrans[31].Show(R.Left + 10, R.Top + 55, SurfDesc);
    FontModule.Age8.Color := $FFFFFF;
    FontModule.Age8.SetTextCentered(R.Left + 24, R.Top + 56, IntToStr(Obj.GetCampaignTransferPoints), SurfDesc);
  end;
end;

procedure TCampaignTransferDlg.RHeroesDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  Obj: THero;
  S: TAoWCampaignTransferSettings;
  R: TRect;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  if FRightHero + Sender.Tag < S.FSelectedHeroes.Count then
  begin
  Obj := S.FHeroes.GetHero(S.FSelectedHeroes[FRightHero + Sender.Tag]);
  if Obj <> nil then
  begin
    with TAOWCheckBox(Sender) do
    R := Classes.Rect(RHeroPnl.WinLeft + WinLeft + 1,
      RHeroPnl.WinTop + WinTop + 2,
      RHeroPnl.WinLeft + WinLeft + WinWidth - 2,
      RHeroPnl.WinTop + WinTop + WinHeight - 2);
    Inc(R.Left);
    Obj.ShowFace(R, SurfDesc);
    Dec(R.Left);
    if TAOWCheckBox(Sender).FLit then
      IntGfxMod.CampaignTrans[20].ShowBlended(R.Left - 1, R.Top - 2, SurfDesc, IntensityBlendTable.LookupTables[50]);
    IntGfxMod.CampaignTrans[31].Show(R.Left + 10, R.Top + 55, SurfDesc);
    FontModule.Age8.Color := $FFFFFF;
    FontModule.Age8.SetTextCentered(R.Left + 24, R.Top + 56, IntToStr(Obj.GetCampaignTransferPoints), SurfDesc);
  end;
  end;
end;

procedure TCampaignTransferDlg.LUnitsDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  Obj: TAbstractUnit;
  S: TAoWCampaignTransferSettings;
  Info: TP2UnitShowInfo;
  R: TRect;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  if FLeftUnit + Sender.Tag < S.FUnits.Count then
  begin
  Obj := S.FUnits.GetUnit(FLeftUnit + Sender.Tag);
  if Obj <> nil then
  begin
    with TAOWCheckBox(Sender) do
    R := Classes.Rect(LUnitPnl.WinLeft + WinLeft + 1,
      LUnitPnl.WinTop + WinTop + 2,
      LUnitPnl.WinLeft + WinLeft + WinWidth - 2,
      LUnitPnl.WinTop + WinTop + WinHeight - 2);
    IntGfxMod.CityWin[4].Show(R.Left + 1, R.Top, SurfDesc);
    Info.Direction := 3;
    Info.Overlays := [uoRank];
    Info.Animation := uaStandStill;
    Info.Frame := 0;
    Info.Looped := False;
    Obj.ShowEx(R.Left - 8, R.Top, SurfDesc, Info);
    if S.FSelectedUnits.IndexOf(FLeftUnit + Sender.Tag) <> -1 then
      IntGfxMod.CityWin[5].ShowBlended(R.Left, R.Top, SurfDesc, AlphaBlendTable.LookupTables[65]);
    if TAOWCheckBox(Sender).FLit then
      IntGfxMod.CampaignTrans[20].ShowBlended(R.Left - 1, R.Top - 2, SurfDesc, IntensityBlendTable.LookupTables[50]);
    IntGfxMod.CampaignTrans[31].Show(R.Left + 10, R.Top + 55, SurfDesc);
    FontModule.Age8.Color := $FFFFFF;
    FontModule.Age8.SetTextCentered(R.Left + 24, R.Top + 56, IntToStr(Obj.GetCampaignTransferPoints), SurfDesc);
  end;
  end;
end;

procedure TCampaignTransferDlg.RUnitsDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc); { Tried name repeated rectangle X; rectangle declaration before object locals; no exact match. }
var
  Obj: TAbstractUnit;
  S: TAoWCampaignTransferSettings;
  Info: TP2UnitShowInfo;
  R: TRect;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  if FRightUnit + Sender.Tag < S.FSelectedUnits.Count then
  begin
  Obj := S.FUnits.GetUnit(S.FSelectedUnits[FRightUnit + Sender.Tag]);
  if Obj <> nil then
  begin
    with TAOWCheckBox(Sender) do
    R := Classes.Rect(RUnitPnl.WinLeft + WinLeft + 1,
      RUnitPnl.WinTop + WinTop + 2,
      RUnitPnl.WinLeft + WinLeft + WinWidth - 2,
      RUnitPnl.WinTop + WinTop + WinHeight - 2);
    IntGfxMod.CityWin[4].Show(R.Left + 1, R.Top, SurfDesc);
    Info.Direction := 3;
    Info.Overlays := [uoRank];
    Info.Animation := uaStandStill;
    Info.Frame := 0;
    Info.Looped := False;
    Obj.ShowEx(R.Left - 8, R.Top, SurfDesc, Info);
    if TAOWCheckBox(Sender).FLit then
      IntGfxMod.CampaignTrans[20].ShowBlended(R.Left - 1, R.Top - 2, SurfDesc, IntensityBlendTable.LookupTables[50]);
    IntGfxMod.CampaignTrans[31].Show(R.Left + 10, R.Top + 55, SurfDesc);
    FontModule.Age8.Color := $FFFFFF;
    FontModule.Age8.SetTextCentered(R.Left + 24, R.Top + 56, IntToStr(Obj.GetCampaignTransferPoints), SurfDesc);
  end;
  end;
end;

procedure TCampaignTransferDlg.LItemsDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  Obj: TItem;
  S: TAoWCampaignTransferSettings;
  R: TRect;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  Obj := S.FItems.GetItem(FLeftItem + Sender.Tag);
  if Obj <> nil then
  begin
    with TAOWCheckBox(Sender) do
    R := Classes.Rect(LItemPnl.WinLeft + WinLeft + 2,
      LItemPnl.WinTop + WinTop + 2,
      LItemPnl.WinLeft + WinLeft + WinWidth - 4,
      LItemPnl.WinTop + WinTop + WinHeight - 2);
    IntGfxMod.CityWin[4].Show(R.Left, R.Top, SurfDesc);
    Obj.Show(R.Left + 5, R.Top + 10, SurfDesc);
    if S.FSelectedItems.IndexOf(FLeftItem + Sender.Tag) <> -1 then
      IntGfxMod.CityWin[5].ShowBlended(R.Left, R.Top, SurfDesc, AlphaBlendTable.LookupTables[65]);
    if TAOWCheckBox(Sender).FLit then
      IntGfxMod.CampaignTrans[20].ShowBlended(R.Left - 1, R.Top - 2, SurfDesc, IntensityBlendTable.LookupTables[50]);
    IntGfxMod.CampaignTrans[31].Show(R.Left + 10, R.Top + 55, SurfDesc);
    FontModule.Age8.Color := $FFFFFF;
    FontModule.Age8.SetTextCentered(R.Left + 24, R.Top + 56, IntToStr(Obj.GetCampaignTransferPoints), SurfDesc);
  end;
end;

procedure TCampaignTransferDlg.RItemsDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc); { Tried name repeated rectangle X; rectangle declaration before object locals; no exact match. }
var
  Obj: TItem;
  S: TAoWCampaignTransferSettings;
  R: TRect;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  if FRightItem + Sender.Tag < S.FSelectedItems.Count then
  begin
  Obj := S.FItems.GetItem(S.FSelectedItems[FRightItem + Sender.Tag]);
  if Obj <> nil then
  begin
    with TAOWCheckBox(Sender) do
    R := Classes.Rect(RItemPnl.WinLeft + WinLeft + 2,
      RItemPnl.WinTop + WinTop + 2,
      RItemPnl.WinLeft + WinLeft + WinWidth - 4,
      RItemPnl.WinTop + WinTop + WinHeight - 2);
    IntGfxMod.CityWin[4].Show(R.Left, R.Top, SurfDesc);
    Obj.Show(R.Left + 5, R.Top + 10, SurfDesc);
    if TAOWCheckBox(Sender).FLit then
      IntGfxMod.CampaignTrans[20].ShowBlended(R.Left - 1, R.Top - 2, SurfDesc, IntensityBlendTable.LookupTables[50]);
    IntGfxMod.CampaignTrans[31].Show(R.Left + 10, R.Top + 55, SurfDesc);
    FontModule.Age8.Color := $FFFFFF;
    FontModule.Age8.SetTextCentered(R.Left + 24, R.Top + 56, IntToStr(Obj.GetCampaignTransferPoints), SurfDesc);
  end;
  end;
end;

procedure TCampaignTransferDlg.LHeroesSelect(Sender: TObject);
begin
  if TAOWCheckBox(Sender).Checked then
  begin
  ClearLeftSelection;
  with TAOWCheckBox(Sender) do
  begin
    Checked := True;
    FLeftKind := 1;
    FLeftSelection := Tag + FLeftHero;
  end;
  end;
end;

procedure TCampaignTransferDlg.LItemsSelect(Sender: TObject);
begin
  ClearLeftSelection;
  with TAOWCheckBox(Sender) do
  begin
    Checked := True;
    FLeftKind := 2;
    FLeftSelection := Tag + FLeftItem;
  end;
end;

procedure TCampaignTransferDlg.LUnitSelect(Sender: TObject);
begin
  ClearLeftSelection;
  with TAOWCheckBox(Sender) do
  begin
    Checked := True;
    FLeftKind := 3;
    FLeftSelection := Tag + FLeftUnit;
  end;
end;

procedure TCampaignTransferDlg.RHeroesSelect(Sender: TObject);
begin
  ClearRightSelection;
  with TAOWCheckBox(Sender) do
  begin
    Checked := True;
    FRightKind := 1;
    FRightSelection := Tag + FRightHero;
  end;
end;

procedure TCampaignTransferDlg.RItemsSelect(Sender: TObject);
begin
  ClearRightSelection;
  with TAOWCheckBox(Sender) do
  begin
    Checked := True;
    FRightKind := 2;
    FRightSelection := Tag + FRightItem;
  end;
end;

procedure TCampaignTransferDlg.RUnitsSelect(Sender: TObject);
begin
  ClearRightSelection;
  with TAOWCheckBox(Sender) do
  begin
    Checked := True;
    FRightKind := 3;
    FRightSelection := Tag + FRightUnit;
  end;
end;

procedure TCampaignTransferDlg.AddBtnClick(Sender: TObject);
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  case FLeftKind of
    1: if S.AddHero(FLeftSelection) then
      begin
        LHeroPnl.FDrawn := False;
        RHeroPnl.FDrawn := False;
        UpdateControls;
        ClearLeftSelection;
      end;
    2: if S.AddItem(FLeftSelection) then
      begin
        LItemPnl.FDrawn := False;
        RItemPnl.FDrawn := False;
        UpdateControls;
        ClearLeftSelection;
      end;
    3: if S.AddUnit(FLeftSelection) then
      begin
        LUnitPnl.FDrawn := False;
        RUnitPnl.FDrawn := False;
        UpdateControls;
        ClearLeftSelection;
      end;
  end;
end;

procedure TCampaignTransferDlg.RemoveBtnClick(Sender: TObject);
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  case FRightKind of
    1: if S.DeleteHero(S.FSelectedHeroes[FRightSelection]) then
      begin
        LHeroPnl.FDrawn := False;
        RHeroPnl.FDrawn := False;
        PnlR.FDrawn := False;
        UpdateControls;
        ClearRightSelection;
        TransBookWin.FDrawn := False;
      end;
    2: if S.DeleteItem(S.FSelectedItems[FRightSelection]) then
      begin
        LItemPnl.FDrawn := False;
        RItemPnl.FDrawn := False;
        PnlR.FDrawn := False;
        UpdateControls;
        ClearRightSelection;
        TransBookWin.FDrawn := False;
      end;
    3: if S.DeleteUnit(S.FSelectedUnits[FRightSelection]) then
      begin
        LUnitPnl.FDrawn := False;
        RUnitPnl.FDrawn := False;
        PnlR.FDrawn := False;
        UpdateControls;
        ClearRightSelection;
        TransBookWin.FDrawn := False;
      end;
  end;
end;

procedure TCampaignTransferDlg.LHeroesUpdate(Sender: TObject);
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  TAOWCheckBox(Sender).Checked := (FLeftKind = 1) and
    (TAOWCheckBox(Sender).Tag + FLeftHero = FLeftSelection);
  with TAOWCheckBox(Sender) do
    FCaptureInput := not Checked and (S.FHeroes.Count > Tag + FLeftHero) and
      (S.FSelectedHeroes.IndexOf(Tag + FLeftHero) = -1);
end;

procedure TCampaignTransferDlg.LItemsUpdate(Sender: TObject);
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  TAOWCheckBox(Sender).Checked := (FLeftKind = 2) and
    (TAOWCheckBox(Sender).Tag + FLeftItem = FLeftSelection);
  with TAOWCheckBox(Sender) do
    FCaptureInput := not Checked and (S.FItems.Count > Tag + FLeftItem) and
      (S.FSelectedItems.IndexOf(Tag + FLeftItem) = -1);
end;

procedure TCampaignTransferDlg.LUnitsUpdate(Sender: TObject);
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  TAOWCheckBox(Sender).Checked := (FLeftKind = 3) and
    (TAOWCheckBox(Sender).Tag + FLeftUnit = FLeftSelection);
  with TAOWCheckBox(Sender) do
    FCaptureInput := not Checked and (S.FUnits.Count > Tag + FLeftUnit) and
      (S.FSelectedUnits.IndexOf(Tag + FLeftUnit) = -1);
end;

procedure TCampaignTransferDlg.RHeroesUpdate(Sender: TObject);
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  TAOWCheckBox(Sender).Checked := (FRightKind = 1) and
    (TAOWCheckBox(Sender).Tag + FRightHero = FRightSelection);
  with TAOWCheckBox(Sender) do
    FCaptureInput := not Checked and (Tag + FRightHero < S.FSelectedHeroes.Count);
end;

procedure TCampaignTransferDlg.RItemsUpdate(Sender: TObject);
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  TAOWCheckBox(Sender).Checked := (FRightKind = 2) and
    (TAOWCheckBox(Sender).Tag + FRightItem = FRightSelection);
  with TAOWCheckBox(Sender) do
    FCaptureInput := not Checked and (Tag + FRightItem < S.FSelectedItems.Count);
end;

procedure TCampaignTransferDlg.RUnitsUpdate(Sender: TObject);
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  TAOWCheckBox(Sender).Checked := (FRightKind = 3) and
    (TAOWCheckBox(Sender).Tag + FRightUnit = FRightSelection);
  with TAOWCheckBox(Sender) do
    FCaptureInput := not Checked and (Tag + FRightUnit < S.FSelectedUnits.Count);
end;

procedure TCampaignTransferDlg.AutoBtnClick(Sender: TObject);
begin
  AoWEngine.FCampaign.FTransferSettings.AutoSelect;
  UpdateControls;
  TransBookWin.FDrawn := False;
end;



procedure TCampaignTransferDlg.UpdateControls;
var
  S: TAoWCampaignTransferSettings;
begin
  S := AoWEngine.FCampaign.FTransferSettings;
  TransferPointsLbl.Text := IntToStr(S.FTransferPointsLeft) + '/' + IntToStr(S.FTransferPointsMax);
  TransferManaLbl.Text := IntToStr(S.FSelectedTransferMana);
  TransferGoldLbl.Text := IntToStr(S.FSelectedTransferGold);
  ManaLeftLbl.Text := IntToStr(S.FTransferManaMax - S.FSelectedTransferMana);
  GoldLeftLbl.Text := IntToStr(S.FTransferGoldMax - S.FSelectedTransferGold);
  ManaSlider.Position := S.FSelectedTransferMana;
  GoldSlider.Position := S.FSelectedTransferGold;
  LHeroLB.Visible := FLeftHero <> 0;
  LHeroRB.Visible := S.FHeroes.Count > FLeftHero + 4;
  LItemLB.Visible := FLeftItem <> 0;
  LItemRB.Visible := S.FItems.Count > FLeftItem + 4;
  LUnitLB.Visible := FLeftUnit <> 0;
  LUnitRB.Visible := S.FUnits.Count > FLeftUnit + 4;
  RHeroLB.Visible := FRightHero <> 0;
  RHeroRB.Visible := FRightHero + 4 < S.FSelectedHeroes.Count;
  RItemLB.Visible := FRightItem <> 0;
  RItemRB.Visible := FRightItem + 4 < S.FSelectedItems.Count;
  RUnitLB.Visible := FRightUnit <> 0;
  RUnitRB.Visible := FRightUnit + 4 < S.FSelectedUnits.Count;
  TransBookWin.FDrawn := False;
end;

procedure TCampaignTransferDlg.ResetSelection;
begin
  FLeftHero := 0;
  FRightHero := 0;
  FLeftUnit := 0;
  FRightUnit := 0;
  FLeftItem := 0;
  FRightItem := 0;
  ClearLeftSelection;
  ClearRightSelection;
end;

procedure TCampaignTransferDlg.ClearLeftSelection;
begin
  LHero1.Checked := False;
  LHero2.Checked := False;
  LHero3.Checked := False;
  LHero4.Checked := False;
  LItem1.Checked := False;
  LItem2.Checked := False;
  LItem3.Checked := False;
  LItem4.Checked := False;
  LUnit1.Checked := False;
  LUnit2.Checked := False;
  LUnit3.Checked := False;
  LUnit4.Checked := False;
  FLeftKind := 0;
  FLeftSelection := -1;
end;

procedure TCampaignTransferDlg.ClearRightSelection;
begin
  RHero1.Checked := False;
  RHero2.Checked := False;
  RHero3.Checked := False;
  RHero4.Checked := False;
  RItem1.Checked := False;
  RItem2.Checked := False;
  RItem3.Checked := False;
  RItem4.Checked := False;
  RUnit1.Checked := False;
  RUnit2.Checked := False;
  RUnit3.Checked := False;
  RUnit4.Checked := False;
  FRightKind := 0;
  FRightSelection := -1;
end;

procedure TCampaignTransferDlg.Execute;
var
  C: TAoWCampaign;
begin
  C := AoWEngine.FCampaign;
  ResetSelection;
  C.FTransferSettings.SetupSelection(AoWEngine.StartupDirectory + '\Maps\' +
    C.FScenarios.GetScenario(C.FNextScenarioID).FFileName);
  if C.FTransferSettings.FTransferPointsMax > 0 then
  begin
    GoldSlider.Max := C.FTransferSettings.FTransferGoldMax;
    ManaSlider.Max := C.FTransferSettings.FTransferManaMax;
    UpdateControls;
    TransBookWin.Visible := True;
  end
  else
    BookStartClick(Self);
end;

end.
