unit AoWTCUnit;

{ Draft declarations of AoWTCUnit, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox, AoWE, AoWTC;

type
  TTCUnit = class;


  { TTCUnit (instance size $154, VMT 00433494); components $44..$150. }
  TTCUnit = class(TDataModule)
  public
    published
    TCUnitWin: TAOWWindow; { +0044 }
    SIcon: TAOWImage; { +0048 }
    Min: TAOWButton; { +004C }
    Close: TAOWButton; { +0050 }
    IWTitle: TAOWLabel; { +0054 }
    UAttackIcon: TAOWImage; { +0058 }
    UDefenseIcon: TAOWImage; { +005C }
    UMovesIcon: TAOWImage; { +0060 }
    UDamageIcon: TAOWImage; { +0064 }
    UResistanceIcon: TAOWImage; { +0068 }
    UHitsIcon: TAOWImage; { +006C }
    UAttack: TAOWLabel; { +0070 }
    UDefense: TAOWLabel; { +0074 }
    UMoves: TAOWLabel; { +0078 }
    UDamage: TAOWLabel; { +007C }
    UResistance: TAOWLabel; { +0080 }
    UHits: TAOWLabel; { +0084 }
    UnitName: TAOWMemo; { +0088 }
    UStatPnl: TAOWPanel; { +008C }
    UAbilLB: TAOWListBox; { +0090 }
    AbilNameLbl: TAOWLabel; { +0094 }
    TCUnitPnl: TAOWPanel; { +0098 }
    AOWImage1: TAOWImage; { +009C }
    AUnitName: TAOWMemo; { +00A0 }
    USelAbilLb: TAOWListBox; { +00A4 }
    TCAbilPnl: TAOWPanel; { +00A8 }
    AbilAtt: TAOWImage; { +00AC }
    AbilAttLbl: TAOWLabel; { +00B0 }
    AbilStatBox: TAOWPanel; { +00B4 }
    AbilStat: TAOWListBox; { +00B8 }
    AbilDam: TAOWImage; { +00BC }
    AbilDamLbl: TAOWLabel; { +00C0 }
    TargetLbl: TAOWLabel; { +00C4 }
    TargetULbl: TAOWLabel; { +00C8 }
    TargetSelPnl: TAOWPanel; { +00CC }
    NoTargetPnl: TAOWPanel; { +00D0 }
    TargetMessage: TAOWMemo; { +00D4 }
    UnitHits: TAoWGauge; { +00D8 }
    UnitMana: TAoWGauge; { +00DC }
    CelticCross: TAOWImage; { +00E0 }
    UStatP1: TAOWPanel; { +00E4 }
    UStatP2: TAOWPanel; { +00E8 }
    AAttackIcon: TAOWImage; { +00EC }
    ADefenseIcon: TAOWImage; { +00F0 }
    AMovesIcon: TAOWImage; { +00F4 }
    ADamageIcon: TAOWImage; { +00F8 }
    AResistanceIcon: TAOWImage; { +00FC }
    AHitsIcons: TAOWImage; { +0100 }
    AAttack: TAOWLabel; { +0104 }
    ADefense: TAOWLabel; { +0108 }
    AMoves: TAOWLabel; { +010C }
    ADamage: TAOWLabel; { +0110 }
    AResistance: TAOWLabel; { +0114 }
    AHits: TAOWLabel; { +0118 }
    AStatPnl: TAOWPanel; { +011C }
    AStatP1: TAOWPanel; { +0120 }
    AStatP2: TAOWPanel; { +0124 }
    Center: TAOWButton; { +0128 }
    AbilSB: TAOWVScrollBar; { +012C }
    UAbilSB: TAOWVScrollBar; { +0130 }
    AOWVScrollBar1: TAOWVScrollBar; { +0134 }
    AbilFr: TAOWPanel; { +0138 }
    ANameFr: TAOWPanel; { +013C }
    TargerFr: TAOWPanel; { +0140 }
    TNamePnl: TAOWPanel; { +0144 }
    UnitFr: TAOWPanel; { +0148 }
    UnitBox: TaowUserDrawBox; { +014C }
    Translator: TIvTranslator; { +0150 }
    public
    published procedure TCUnitWinResize; public
    published procedure MinClick; public
    published procedure UAbilLBPreDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc); public
    published procedure TCUnitPnlDrawBack(Sender: TObject; SD: TSurfaceDesc); public
    published procedure UAbilLBUpdate; public
    published procedure UAbilLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure UAbilLBMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); public
    published procedure HeroSMapMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure CenterClick; public
    published procedure CloseClick; public
  end;

var TCUnit: TTCUnit; procedure RefreshCombatUnit(Window: TTCUnit);
implementation

uses AoWExeForms, E1Resources, AoWComp, E3Globals, AoWWinMan, AoWInfoBanner;

procedure TTCUnit.TCUnitWinResize;
begin
  with TCUnitWin do
  begin
    Alignment.RightOffset := WinManager.WinWidth - WinLeft - WinWidth;
    Alignment.BottomOffset := WinManager.WinHeight - WinTop - WinHeight;
  end;
end;


procedure TTCUnit.MinClick;
begin
  General.PlayButtonSound(0);
  TCUnitWin.Visible := False;
end;


procedure TTCUnit.UAbilLBPreDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
begin
  if General.FCombatUnit <> nil then
    if (General.FCombatUnit.FUnit.GetPlayer = AoWCombatMap.FSeatedPlayer) and
       (General.FCombatUnit.FUnit.FMovePoints > 0) and
       (DrawItem < General.FCombatUnit.FCombatAbilityCount) and
       ((not (AoWHSSet.FAbilityControl.GetAbility(TTCAbility(General.FCombatUnit.FAbilities[DrawItem]).Ability).
          GetCombatMode(General.FCombatUnit.FUnit.FUnit) in [cmShortRange..cmLongRange]) and
          (TTCAbility(General.FCombatUnit.FAbilities[DrawItem]).Ability <> $34)) or
        (General.FCombatUnit.FUnit.FMovePoints = General.FCombatUnit.FUnit.FUnit.GetMoves)) then
      UAbilLB.TextColor := $FFFFFF
    else UAbilLB.TextColor := $C0C0C0;
end;


procedure TTCUnit.TCUnitPnlDrawBack(Sender: TObject; SD: TSurfaceDesc);
begin
  if General.FCombatUnit <> nil then
    General.FCombatUnit.FUnit.FUnit.ShowEx(TCUnitPnl.WinLeft - 10,
      TCUnitPnl.WinTop - 2, SD, General.FUnitShowInfo);
end;


procedure TTCUnit.UAbilLBUpdate;
begin
  if UAbilLB.F188 <> UAbilLB.Selected then UAbilLB.Selected := UAbilLB.F188;
end;


procedure TTCUnit.UAbilLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Ability: TAbility;
begin
  if UAbilLB.Selected > -1 then
    if Button = mbLeft then
      UAbilLB.Selected := General.FCombatUnit.SelectAbility(Integer(UAbilLB.Items.Objects[UAbilLB.Selected]))
    else if (Button = mbRight) and (General.FCombatUnit <> nil) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(Integer(UAbilLB.Items.Objects[UAbilLB.Selected]));
      if Ability <> nil then
        AoWExeForms.SetInfoBanner(InfoBanner, Ability.GetName(General.FCombatUnit.FUnit.FUnit), Ability.FDescription);
    end;
end;


procedure TTCUnit.UAbilLBMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); { Tried reload final movement operand through global; no exact match. }
begin
  if General.FCombatUnit <> nil then
  begin
    if (General.FCombatUnit.FUnit.GetPlayer = AoWCombatMap.FSeatedPlayer) and
       (General.FCombatUnit.FUnit.FMovePoints <> 0) and
       (UAbilLB.F188 < General.FCombatUnit.FCombatAbilityCount) then
    begin
      if not (AoWHSSet.FAbilityControl.GetAbility(TTCAbility(General.FCombatUnit.FAbilities[UAbilLB.F188]).Ability).
        GetCombatMode(General.FCombatUnit.FUnit.FUnit) in [cmShortRange..cmLongRange]) and
        (TTCAbility(General.FCombatUnit.FAbilities[UAbilLB.F188]).Ability <> $34) then Exit;
      with General.FCombatUnit.FUnit do
        if FUnit.GetMoves <= FMovePoints then Exit;
    end;
    UAbilLB.F188 := -1;
  end;
end;


procedure TTCUnit.HeroSMapMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  General.FSelectedUnit := General.FCombatUnit.FUnit.FUnit;
  UnitWindow.ShowUnit;
end;


procedure TTCUnit.CenterClick; begin General.PlayButtonSound(0); AoWCombatMap.CenterViewTo(General.FCombatUnit.GetXhx, General.FCombatUnit.GetYhx, General.FCombatUnit.GetLhx); AoWCombatMap.PlayCenterAnimation(General.FCombatUnit.GetXhx, General.FCombatUnit.GetYhx, General.FCombatUnit.GetLhx); end;
procedure TTCUnit.CloseClick; begin General.PlayButtonSound(0); TCUnitWin.Visible := False; end;

procedure RefreshCombatUnit(Window: TTCUnit); var AbilityInfo: TAbilityCombatInfo; SpellInfo: TSpellCombatInfo; U: TAbstractUnit; Hero: THero; begin if General.FCombatUnit <> nil then begin U := General.FCombatUnit.FUnit.FUnit; if U is THero then Hero := THero(U) else Hero := nil; if not Window.TCUnitWin.Visible then begin Window.UnitMana.Visible := False; AoWExeForms.TBWindow.TCUnitBtn.Visible := True; end; if Hero <> nil then begin if Hero.GetCastingPointsMax > 0 then begin Window.UnitMana.Visible := True; Window.UnitMana.Max := Hero.GetCastingPointsMax; Window.UnitMana.Position := Hero.GetCastingPoints; end; with Window.UnitFr do begin Alignment.TopOffset := 7; WinHeight := 54; end; end else with Window.UnitFr do begin Alignment.TopOffset := 0; WinHeight := 61; end; Window.UnitFr.FAligned := False; if U <> nil then begin if General.FCombatUnit.FSelectedAbility = -1 then begin Window.TCUnitPnl.Visible := True;
Window.TCAbilPnl.Visible := False; Window.TargetSelPnl.Visible := False; Window.UHits.Text := IntToStr(U.GetHitPoints) + '/' + IntToStr(U.GetHits); Window.UMoves.Text := IntToStr(General.FCombatUnit.FUnit.FMovePoints) + '/' + IntToStr(U.GetMoves); Window.UAttack.Text := IntToStr(U.GetAttack); Window.UDamage.Text := IntToStr(U.GetDamage); Window.UDefense.Text := IntToStr(U.GetDefense); Window.UResistance.Text := IntToStr(U.GetResistance); Window.UMovesIcon.SetCurrent(General.MTtoInt(U.GetMoveTypes)); General.FCombatUnit.ListAbilities(Window.UAbilLB.Items, nil, nil); Window.UAbilLB.Selected := -1; Window.UAbilLB.F188 := -1; Window.UAbilLB.ListOffset := 0; end else if (General.FCombatUnit.FSelectedAbility = $34) and (General.FCombatUnit.FSelectedSpell > -1) then begin Window.TCUnitPnl.Visible := False; Window.TCAbilPnl.Visible := True; Window.TargetSelPnl.Visible := False;
AoWHSSet.FSpellControl.GetSpell(General.FCombatUnit.FSelectedSpell).GetCombatInfo( General.FCombatUnit.FUnit.FUnit, SpellInfo); Window.AbilNameLbl.Text := AoWHSSet.FSpellControl.GetSpell(General.FCombatUnit.FSelectedSpell).FSpellName; if SpellInfo.Attack > 0 then Window.AbilAttLbl.Text := IntToStr(SpellInfo.Attack) else Window.AbilAttLbl.Text := '-'; if SpellInfo.Damage > 0 then Window.AbilDamLbl.Text := IntToStr(SpellInfo.Damage) else Window.AbilDamLbl.Text := '-'; Window.AbilStat.Items.Clear; if dtFire in SpellInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(FireRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtCold in SpellInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(ColdRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtLightning in SpellInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(LightningRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtMagic in SpellInfo.DamageTypes then
Window.AbilStat.Items.Add(TranslateRStr(MagicRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtPoison in SpellInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(PoisonRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtDeath in SpellInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(DeathRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtHoly in SpellInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(HolyRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtPhysical in SpellInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(PhysicalRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtWall in SpellInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(WallRStr) + ' ' + TranslateRStr(E1DamageRStr)); end else begin Window.TCUnitPnl.Visible := False; Window.TCAbilPnl.Visible := True; Window.TargetSelPnl.Visible := False;
AoWHSSet.FAbilityControl.GetAbility(General.FCombatUnit.FSelectedAbility).GetCombatInfo( General.FCombatUnit.FUnit.FUnit, AbilityInfo); Window.AbilNameLbl.Text := AoWHSSet.FAbilityControl.GetAbility(General.FCombatUnit.FSelectedAbility).GetName( General.FCombatUnit.FUnit.FUnit); if AbilityInfo.Attack > 0 then Window.AbilAttLbl.Text := IntToStr(AbilityInfo.Attack) else Window.AbilAttLbl.Text := '-'; if AbilityInfo.Damage > 0 then Window.AbilDamLbl.Text := IntToStr(AbilityInfo.Damage) else Window.AbilDamLbl.Text := '-'; Window.AbilStat.Items.Clear; if dtFire in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(FireRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtCold in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(ColdRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtLightning in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(LightningRStr) + ' ' +
TranslateRStr(E1DamageRStr)); if dtMagic in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(MagicRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtPoison in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(PoisonRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtDeath in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(DeathRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtHoly in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(HolyRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtPhysical in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(PhysicalRStr) + ' ' + TranslateRStr(E1DamageRStr)); if dtWall in AbilityInfo.DamageTypes then Window.AbilStat.Items.Add(TranslateRStr(WallRStr) + ' ' + TranslateRStr(E1DamageRStr)); end; Window.UnitName.Items.Clear; Window.UnitName.Items.Add(U.GetName); Window.UnitHits.Max := U.GetHits;
Window.UnitHits.Position := U.GetHitPoints; end; end; TCUnit.TCUnitWin.Visible := True; end;






end.
