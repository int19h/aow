unit AoWHeroUpgradeDlg;

{ AoWHeroUpgradeDlg handlers recovered from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AoWWinMan, AoWInfoBanner, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  THeroUpgradeDlg = class;


  { THeroUpgradeDlg: size $1E0; $1C4 close callback, $1CC referenced hero,
    $1D0/$1D4 list sort orders, $1D8 live hero, $1DC editable copy. VMT 004458C8. }
  THeroUpgradeDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    CancelBtn: TAOWButton; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    Done: TAOWButton; { +0050 }
    Title: TAOWLabel; { +0054 }
    Close: TAOWButton; { +0058 }
    TitleIcon: TAOWImage; { +005C }
    CeltM: TAOWImage; { +0060 }
    CeltL: TAOWImage; { +0064 }
    CeltR: TAOWImage; { +0068 }
    TCeltL: TAoWFrame; { +006C }
    TCelt: TAOWImage; { +0070 }
    UpgradePnl: TAOWPanel; { +0074 }
    HeaderLbl: TAOWLabel; { +0078 }
    SkillPointsLbl: TAOWLabel; { +007C }
    AvailableAbilities: TAOWListBox; { +0080 }
    AvailableAbilitiesSB: TAOWVScrollBar; { +0084 }
    SelectedAbilities: TAOWListBox; { +0088 }
    SelectedAbilitiesSB: TAOWVScrollBar; { +008C }
    SelectedAbilitiesSort: TAOWButton; { +0090 }
    AvailableAbilityCostSort: TAOWButton; { +0094 }
    AvailableAbilitiesCost: TAOWListBox; { +0098 }
    AvailableAbilitiesSort: TAOWButton; { +009C }
    AddAbilityBtn: TAOWButton; { +00A0 }
    RemoveBtn: TAOWButton; { +00A4 }
    FaceFrame: TAOWImage; { +00A8 }
    UnitName: TAOWEdit; { +00AC }
    Alignment: TAOWEdit; { +00B0 }
    TopPnl: TAOWPanel; { +00B4 }
    StatisicsPnl: TAOWPanel; { +00B8 }
    AttValue: TAOWLabel; { +00BC }
    AttLbl: TAOWLabel; { +00C0 }
    AttPnl: TAOWPanel; { +00C4 }
    DamValue: TAOWLabel; { +00C8 }
    DamLbl: TAOWLabel; { +00CC }
    DamPnl: TAOWPanel; { +00D0 }
    DefValue: TAOWLabel; { +00D4 }
    DefLbl: TAOWLabel; { +00D8 }
    DefPnl: TAOWPanel; { +00DC }
    ResValue: TAOWLabel; { +00E0 }
    ResLbl: TAOWLabel; { +00E4 }
    ResPnl: TAOWPanel; { +00E8 }
    HitValue: TAOWLabel; { +00EC }
    HitLbl: TAOWLabel; { +00F0 }
    HitPnl: TAOWPanel; { +00F4 }
    MovValue: TAOWLabel; { +00F8 }
    MovLbl: TAOWLabel; { +00FC }
    MovPnl: TAOWPanel; { +0100 }
    AttI: TAOWLabel; { +0104 }
    DamI: TAOWLabel; { +0108 }
    DefI: TAOWLabel; { +010C }
    ResI: TAOWLabel; { +0110 }
    HitI: TAOWLabel; { +0114 }
    MovI: TAOWLabel; { +0118 }
    AttA: TAOWLabel; { +011C }
    DamA: TAOWLabel; { +0120 }
    DefA: TAOWLabel; { +0124 }
    ResA: TAOWLabel; { +0128 }
    HitA: TAOWLabel; { +012C }
    MovA: TAOWLabel; { +0130 }
    AttP: TAOWLabel; { +0134 }
    DamP: TAOWLabel; { +0138 }
    DefP: TAOWLabel; { +013C }
    ResP: TAOWLabel; { +0140 }
    HitP: TAOWLabel; { +0144 }
    MovP: TAOWLabel; { +0148 }
    AttB: TAOWLabel; { +014C }
    DamB: TAOWLabel; { +0150 }
    DefB: TAOWLabel; { +0154 }
    ResB: TAOWLabel; { +0158 }
    HitB: TAOWLabel; { +015C }
    MovB: TAOWLabel; { +0160 }
    AttUp: TAOWButton; { +0164 }
    AttDn: TAOWButton; { +0168 }
    DamUp: TAOWButton; { +016C }
    DamDn: TAOWButton; { +0170 }
    DefUp: TAOWButton; { +0174 }
    DefDn: TAOWButton; { +0178 }
    ResUp: TAOWButton; { +017C }
    ResDn: TAOWButton; { +0180 }
    HitUp: TAOWButton; { +0184 }
    HitDn: TAOWButton; { +0188 }
    MovUp: TAOWButton; { +018C }
    MovDn: TAOWButton; { +0190 }
    AttIc: TAOWImage; { +0194 }
    DamIcn: TAOWImage; { +0198 }
    DefIc: TAOWImage; { +019C }
    ResIc: TAOWImage; { +01A0 }
    HitIc: TAOWImage; { +01A4 }
    MovIc: TAOWImage; { +01A8 }
    SelectedAbilitiesCostSort: TAOWButton; { +01AC }
    SelectedAbilitiesCost: TAOWListBox; { +01B0 }
    InfoPnl: TAOWPanel; { +01B4 }
    LevelLbl: TAOWLabel; { +01B8 }
    SkillPoints: TAOWLabel; { +01BC }
    Translator: TIvTranslator; { +01C0 }
    public
    FOnClose: TNotifyEvent; { $1C4 }
    FReferencedHero: THero; { $1CC }
    FSelectedSort: Integer; { $1D0 }
    FAvailableSort: Integer; { $1D4 }
    FHero: THero; { $1D8 }
    FEditedHero: THero; { $1DC }
    procedure ClearHero;
    function ValidateHero: Boolean;
    procedure UpdateStatistics;
    procedure RefreshStatistics;
    procedure SortSelected;
    procedure SortAvailable;
    procedure RefreshAbilities;
    procedure SetAvailableIndex(Index: Integer);
    procedure SetSelectedIndex(Index: Integer);
    function CanAddAbility(AbilityID: Integer): Boolean;
    procedure CloseClick;
    procedure FaceFramePreDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure AttUpClick;
    procedure AttDnClick;
    procedure DefUpClick;
    procedure DefDnClick;
    procedure DamUpClick;
    procedure DamDnClick;
    procedure ResUpClick;
    procedure ResDnClick;
    procedure HitUpClick;
    procedure HitDnClick;
    procedure MovUpClick;
    procedure MovDnClick;
    procedure SelectedAbilitiesChange;
    procedure SelectedAbilitiesCostChange;
    procedure SelectedAbilitiesSBChange;
    procedure AvailableAbilitiesChange;
    procedure AvailableAbilitiesCostChange;
    procedure AvailableAbilitiesSBChange;
    procedure AddAbilityBtnClick;
    procedure RemoveBtnClick;
    procedure SelectedAbilitiesSortClick;
    procedure SelectedAbilitiesCostSortClick;
    procedure AvailableAbilitiesSortClick;
    procedure AvailableAbilityCostSortClick;
    procedure DoneClick;
    procedure DlgHide;
    procedure AvailableAbilitiesMouseDown(Sender: TObject; Button: TMouseButton);
    procedure SelectedAbilitiesMouseDown(Sender: TObject; Button: TMouseButton);
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

procedure THeroUpgradeDlg.RefreshAbilities;
var
  Name, Cost: string;
  Ability: TAbility;
  I: Integer;
begin
  AvailableAbilities.Items.Clear;
  AvailableAbilitiesCost.Items.Clear;
  for I := 1 to AoWHSSet.FAbilityControl.GetCount - 1 do
  begin
    Ability := AoWHSSet.FAbilityControl.GetAbility(I);
    if (Ability <> nil) and Ability.CanExpand(FEditedHero) and
      (astHeroUpgrade in Ability.FSelectionTypes) then
    begin
      AvailableAbilities.Items.AddObject(Ability.ExpandName(FEditedHero), TObject(I));
      AvailableAbilitiesCost.Items.Add(IntToStr(Ability.ExpandCost(FEditedHero)));
    end;
  end;
  SelectedAbilities.Items.Clear;
  SelectedAbilitiesCost.Items.Clear;
  for I := 1 to FEditedHero.GetAbCount - 1 do
    if FEditedHero.GetInherentAbility(I) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(I);
      Name := Ability.GetName(FEditedHero);
      if FHero.GetAbEnabled(I) and
        (FHero.GetInherentAbilityLevel(I) = FEditedHero.GetInherentAbilityLevel(I)) then
      begin
        Name := Name + ' (' + TranslateRStr(FixedRStr) + ')';
        Cost := '-';
      end
      else
        Cost := IntToStr(Ability.GetSkillPoints(FEditedHero) - Ability.GetSkillPoints(FHero));
      SelectedAbilitiesCost.Items.Add(Cost);
      SelectedAbilities.Items.AddObject(Name, TObject(I));
    end;
  AvailableAbilitiesSB.Max := AvailableAbilities.Items.Count - 1;
  SelectedAbilitiesSB.Max := SelectedAbilities.Items.Count - 1;
  SortAvailable;
  SortSelected;
end;

function THeroUpgradeDlg.CanAddAbility(AbilityID: Integer): Boolean;
begin
  if not AoWHSSet.FAbilityControl.GetAbility(AbilityID).CanExpand(FEditedHero) or
    (AoWHSSet.FAbilityControl.GetAbility(AbilityID).ExpandCost(FEditedHero) > FEditedHero.GetSkillPoints) then
    Result := False
  else Result := True;
end;

procedure THeroUpgradeDlg.SetSelectedIndex(Index: Integer);
begin
  SelectedAbilities.Selected := Index;
  SelectedAbilitiesCost.Selected := Index;
end;

procedure THeroUpgradeDlg.SetAvailableIndex(Index: Integer);
begin
  AvailableAbilities.Selected := Index;
  AvailableAbilitiesCost.Selected := Index;
end;

procedure THeroUpgradeDlg.SortAvailable;
begin
  case FAvailableSort of
    0: SortStringsAscending(AvailableAbilities.Items, [AvailableAbilitiesCost.Items]);
    1: SortStringsDescending(AvailableAbilities.Items, [AvailableAbilitiesCost.Items]);
    2: SortStringsNumericalAscending(AvailableAbilitiesCost.Items, [AvailableAbilities.Items]);
    3: SortStringsNumericalDescending(AvailableAbilitiesCost.Items, [AvailableAbilities.Items]);
  end;
end;

procedure THeroUpgradeDlg.SortSelected;
begin
  case FSelectedSort of
    0: SortStringsAscending(SelectedAbilities.Items, [SelectedAbilitiesCost.Items]);
    1: SortStringsDescending(SelectedAbilities.Items, [SelectedAbilitiesCost.Items]);
    2: SortStringsNumericalAscending(SelectedAbilitiesCost.Items, [SelectedAbilities.Items]);
    3: SortStringsNumericalDescending(SelectedAbilitiesCost.Items, [SelectedAbilities.Items]);
  end;
end;

procedure THeroUpgradeDlg.RefreshStatistics;
begin
  UpdateStatistics;
end;

procedure THeroUpgradeDlg.UpdateStatistics;
begin
  AttB.Text := IntToStr(FHero.GetInherentAttack);
  DefB.Text := IntToStr(FHero.GetInherentDefense);
  DamB.Text := IntToStr(FHero.GetInherentDamage);
  ResB.Text := IntToStr(FHero.GetInherentResistance);
  HitB.Text := IntToStr(FHero.GetHits);
  MovB.Text := IntToStr(FHero.GetMoves);
  AttA.Text := IntToStr(FEditedHero.FUnitAttack - FHero.FUnitAttack);
  DefA.Text := IntToStr(FEditedHero.FUnitDefense - FHero.FUnitDefense);
  DamA.Text := IntToStr(FEditedHero.FUnitDamage - FHero.FUnitDamage);
  ResA.Text := IntToStr(FEditedHero.FUnitResistance - FHero.FUnitResistance);
  HitA.Text := IntToStr(FEditedHero.FUnitHits - FHero.FUnitHits);
  MovA.Text := IntToStr(FEditedHero.FUnitMoves - FHero.FUnitMoves);
  AttValue.Text := IntToStr(FEditedHero.GetInherentAttack);
  DefValue.Text := IntToStr(FEditedHero.GetInherentDefense);
  DamValue.Text := IntToStr(FEditedHero.GetInherentDamage);
  ResValue.Text := IntToStr(FEditedHero.GetInherentResistance);
  HitValue.Text := IntToStr(FEditedHero.GetHits);
  MovValue.Text := IntToStr(FEditedHero.GetMoves);
  SkillPoints.Text := IntToStr(FEditedHero.GetSkillPoints) + '/' + IntToStr(FHero.GetSkillPoints);
end;

function THeroUpgradeDlg.ValidateHero: Boolean;
begin
  FHero := THero(AoWHSMap.FUnitControl.FindUnit(FReferencedHero.FUnitID));
  Result := FHero <> nil;
  if not Result then Dlg.Visible := False;
end;

procedure THeroUpgradeDlg.ClearHero;
var
  OnClose: TNotifyEvent;
  Hero: THero;
begin
  OnClose := FOnClose;
  Hero := FReferencedHero;
  FOnClose := nil;
  FReferencedHero := nil;
  if Assigned(OnClose) then OnClose(Hero);
  if Hero <> nil then Hero.Release;
  FEditedHero.Free;
  FEditedHero := nil;
end;

procedure THeroUpgradeDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure THeroUpgradeDlg.FaceFramePreDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  R: TRect;
begin
  if ValidateHero then
  begin
    with TAOWImage(Sender) do
      R := Rect(TopPnl.WinLeft + WinLeft + 2,
        TopPnl.WinTop + WinTop,
        TopPnl.WinLeft + WinLeft + WinWidth - 2,
        TopPnl.WinTop + WinTop + WinHeight - 2);
    FHero.GetFace.ShowStretched(R, SurfDesc);
  end;
end;

procedure THeroUpgradeDlg.AttUpClick;
begin
  General.PlayButtonSound(0);
  FEditedHero.SetUnitAttack(FEditedHero.FUnitAttack + 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.AttDnClick;
begin
  General.PlayButtonSound(0);
  if FEditedHero.FUnitAttack <> FHero.FUnitAttack then
    FEditedHero.SetUnitAttack(FEditedHero.FUnitAttack - 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.DefUpClick;
begin
  General.PlayButtonSound(0);
  FEditedHero.SetUnitDefense(FEditedHero.FUnitDefense + 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.DefDnClick;
begin
  General.PlayButtonSound(0);
  if FEditedHero.FUnitDefense <> FHero.FUnitDefense then
    FEditedHero.SetUnitDefense(FEditedHero.FUnitDefense - 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.DamUpClick;
begin
  General.PlayButtonSound(0);
  FEditedHero.SetUnitDamage(FEditedHero.FUnitDamage + 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.DamDnClick;
begin
  General.PlayButtonSound(0);
  if FEditedHero.FUnitDamage <> FHero.FUnitDamage then
    FEditedHero.SetUnitDamage(FEditedHero.FUnitDamage - 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.ResUpClick;
begin
  General.PlayButtonSound(0);
  FEditedHero.SetUnitResistance(FEditedHero.FUnitResistance + 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.ResDnClick;
begin
  General.PlayButtonSound(0);
  if FEditedHero.FUnitResistance <> FHero.FUnitResistance then
    FEditedHero.SetUnitResistance(FEditedHero.FUnitResistance - 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.HitUpClick;
begin
  General.PlayButtonSound(0);
  FEditedHero.SetUnitHits(FEditedHero.FUnitHits + 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.HitDnClick;
begin
  General.PlayButtonSound(0);
  if FEditedHero.FUnitHits <> FHero.FUnitHits then
    FEditedHero.SetUnitHits(FEditedHero.FUnitHits - 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.MovUpClick;
begin
  General.PlayButtonSound(0);
  FEditedHero.SetUnitMoves(FEditedHero.FUnitMoves + 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.MovDnClick;
begin
  General.PlayButtonSound(0);
  if FEditedHero.FUnitMoves <> FHero.FUnitMoves then
    FEditedHero.SetUnitMoves(FEditedHero.FUnitMoves - 1);
  RefreshStatistics;
end;

procedure THeroUpgradeDlg.SelectedAbilitiesChange;
begin
  SetSelectedIndex(SelectedAbilities.Selected);
end;

procedure THeroUpgradeDlg.SelectedAbilitiesCostChange;
begin
  SetSelectedIndex(SelectedAbilitiesCost.Selected);
end;

procedure THeroUpgradeDlg.SelectedAbilitiesSBChange;
begin
  SelectedAbilities.ListOffset := SelectedAbilitiesSB.Position;
  SelectedAbilitiesCost.ListOffset := SelectedAbilitiesSB.Position;
end;

procedure THeroUpgradeDlg.AvailableAbilitiesChange;
begin
  SetAvailableIndex(AvailableAbilities.Selected);
end;

procedure THeroUpgradeDlg.AvailableAbilitiesCostChange;
begin
  SetAvailableIndex(AvailableAbilitiesCost.Selected);
end;

procedure THeroUpgradeDlg.AvailableAbilitiesSBChange;
begin
  AvailableAbilities.ListOffset := AvailableAbilitiesSB.Position;
  AvailableAbilitiesCost.ListOffset := AvailableAbilitiesSB.Position;
end;

procedure THeroUpgradeDlg.AddAbilityBtnClick;
var
  List: TAOWListBox;
  Index, AbilityID: Integer;
begin
  General.PlayButtonSound(0);
  List := AvailableAbilities;
  Index := List.Selected;
  if Index <> -1 then
  begin
    AbilityID := Integer(List.Items.Objects[Index]);
    if CanAddAbility(AbilityID) then
    begin
      FEditedHero.ExpandAbility(AbilityID);
      RefreshAbilities;
      RefreshStatistics;
    end;
  end;
end;

procedure THeroUpgradeDlg.RemoveBtnClick;
var
  List: TAOWListBox;
  Index, AbilityID: Integer;
begin
  General.PlayButtonSound(0);
  List := SelectedAbilities;
  Index := List.Selected;
  if Index <> -1 then
  begin
    AbilityID := Integer(List.Items.Objects[Index]);
    if FHero.GetInherentAbility(AbilityID) then
      if FHero.GetInherentAbilityLevel(AbilityID) =
        FEditedHero.GetInherentAbilityLevel(AbilityID) then Exit;
    FEditedHero.RemoveAbility(AbilityID);
    RefreshAbilities;
    RefreshStatistics;
  end;
end;

procedure THeroUpgradeDlg.SelectedAbilitiesSortClick;
begin
  General.PlayButtonSound(0);
  if FSelectedSort = 0 then FSelectedSort := 1
  else FSelectedSort := 0;
  SortSelected;
end;

procedure THeroUpgradeDlg.SelectedAbilitiesCostSortClick;
begin
  General.PlayButtonSound(0);
  if FSelectedSort = 2 then FSelectedSort := 3
  else FSelectedSort := 2;
  SortSelected;
end;

procedure THeroUpgradeDlg.AvailableAbilitiesSortClick;
begin
  General.PlayButtonSound(0);
  if FAvailableSort = 0 then FAvailableSort := 1
  else FAvailableSort := 0;
  SortAvailable;
end;

procedure THeroUpgradeDlg.AvailableAbilityCostSortClick;
begin
  General.PlayButtonSound(0);
  if FAvailableSort = 2 then FAvailableSort := 3
  else FAvailableSort := 2;
  SortAvailable;
end;

procedure THeroUpgradeDlg.DoneClick;
var
  Event: THeroUpgradeTE;
begin
  if ValidateHero then
    if not AoWHSMap.FPlayers.GetPlayers(FHero.FPlayer).GetBusy then
    begin
      Event := THeroUpgradeTE.Create(nil);
      Event.Setup(FHero);
      Event.FAttack := FEditedHero.FUnitAttack - FHero.FUnitAttack;
      Event.FDefense := FEditedHero.FUnitDefense - FHero.FUnitDefense;
      Event.FDamage := FEditedHero.FUnitDamage - FHero.FUnitDamage;
      Event.FResistance := FEditedHero.FUnitResistance - FHero.FUnitResistance;
      Event.FHits := FEditedHero.FUnitHits - FHero.FUnitHits;
      Event.FMoves := FEditedHero.FUnitMoves - FHero.FUnitMoves;
      Event.FAbilities.AssignAb(FEditedHero);
      AoWHSMap.FTokenManager.GetTokenControl(FHero.FPlayer).AddEvent(Event);
      Event.Release;
      Dlg.Visible := False;
    end;
end;

procedure THeroUpgradeDlg.DlgHide;
begin
  ClearHero;
end;

procedure THeroUpgradeDlg.AvailableAbilitiesMouseDown(Sender: TObject; Button: TMouseButton);
var
  Ability: TAbility;
begin
  if (Button = mbRight) and (AvailableAbilities.Selected <> -1) then
  begin
    Ability := AoWHSSet.FAbilityControl.GetAbility(Integer(AvailableAbilities.Items.Objects[AvailableAbilities.Selected]));
    if Ability <> nil then
      InfoBanner.ShowInfo(Ability.GetName(nil), Ability.FDescription);
  end;
end;

procedure THeroUpgradeDlg.SelectedAbilitiesMouseDown(Sender: TObject; Button: TMouseButton);
var
  Ability: TAbility;
begin
  if (Button = mbRight) and (SelectedAbilities.Selected <> -1) then
  begin
    Ability := AoWHSSet.FAbilityControl.GetAbility(Integer(SelectedAbilities.Items.Objects[SelectedAbilities.Selected]));
    if Ability <> nil then
      InfoBanner.ShowInfo(Ability.GetName(nil), Ability.FDescription);
  end;
end;

procedure THeroUpgradeDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Dlg.Visible := False;
end;


end.
