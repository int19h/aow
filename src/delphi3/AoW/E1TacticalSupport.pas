unit E1TacticalSupport;

{ Original unnamed combat-unit panel refresh routine, AoW.exe $00433A1C..$004346F0.
  TAbstractUnit/THero and the six/eight-byte combat-info records retain their recovered layouts. }

interface

uses AoWTCUnit;

procedure RefreshCombatUnit(Window: TTCUnit);

implementation

uses SysUtils, AoWE, AoWTC, AoWWinMan, AoWComp, E3Globals, E1Resources;

procedure RefreshCombatUnit(Window: TTCUnit);
var
  AbilityInfo: TAbilityCombatInfo;
  SpellInfo: TSpellCombatInfo;
  U: TAbstractUnit;
  Hero: THero;
begin
  if General.FCombatUnit <> nil then
  begin
    U := General.FCombatUnit.FUnit.FUnit;
    if U is THero then Hero := THero(U) else Hero := nil;
    if not Window.TCUnitWin.Visible then
    begin
      Window.UnitMana.Visible := False;
      TBWindow.TCUnitBtn.Visible := True;
    end;
    if Hero <> nil then
    begin
      if Hero.GetCastingPointsMax > 0 then
      begin
        Window.UnitMana.Visible := True;
        Window.UnitMana.Max := Hero.GetCastingPointsMax;
        Window.UnitMana.Position := Hero.GetCastingPoints;
      end;
      with Window.UnitFr do
      begin
        Alignment.TopOffset := 7;
        WinHeight := 54;
      end;
    end
    else
      with Window.UnitFr do
      begin
        Alignment.TopOffset := 0;
        WinHeight := 61;
      end;
    Window.UnitFr.FAligned := False;
    if U <> nil then
    begin
      if General.FCombatUnit.FSelectedAbility = -1 then
      begin
        Window.TCUnitPnl.Visible := True;
        Window.TCAbilPnl.Visible := False;
        Window.TargetSelPnl.Visible := False;
        Window.UHits.Text := IntToStr(U.GetHitPoints) + '/' + IntToStr(U.GetHits);
        Window.UMoves.Text := IntToStr(General.FCombatUnit.FUnit.FMovePoints) + '/' + IntToStr(U.GetMoves);
        Window.UAttack.Text := IntToStr(U.GetAttack);
        Window.UDamage.Text := IntToStr(U.GetDamage);
        Window.UDefense.Text := IntToStr(U.GetDefense);
        Window.UResistance.Text := IntToStr(U.GetResistance);
        Window.UMovesIcon.SetCurrent(General.MTtoInt(U.GetMoveTypes));
        General.FCombatUnit.ListAbilities(Window.UAbilLB.Items, nil, nil);
        Window.UAbilLB.Selected := -1;
        Window.UAbilLB.F188 := -1;
        Window.UAbilLB.ListOffset := 0;
      end
      else if (General.FCombatUnit.FSelectedAbility = $34) and (General.FCombatUnit.FSelectedSpell > -1) then
      begin
        Window.TCUnitPnl.Visible := False;
        Window.TCAbilPnl.Visible := True;
        Window.TargetSelPnl.Visible := False;
        AoWHSSet.FSpellControl.GetSpell(General.FCombatUnit.FSelectedSpell).GetCombatInfo(
          General.FCombatUnit.FUnit.FUnit, SpellInfo);
        Window.AbilNameLbl.Text := AoWHSSet.FSpellControl.GetSpell(General.FCombatUnit.FSelectedSpell).FSpellName;
        if SpellInfo.Attack > 0 then Window.AbilAttLbl.Text := IntToStr(SpellInfo.Attack)
        else Window.AbilAttLbl.Text := '-';
        if SpellInfo.Damage > 0 then Window.AbilDamLbl.Text := IntToStr(SpellInfo.Damage)
        else Window.AbilDamLbl.Text := '-';
        Window.AbilStat.Items.Clear;
        if dtFire in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(FireRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtCold in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(ColdRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtLightning in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(LightningRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtMagic in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(MagicRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtPoison in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(PoisonRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtDeath in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(DeathRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtHoly in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(HolyRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtPhysical in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(PhysicalRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtWall in SpellInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(WallRStr) + ' ' + TranslateRStr(E1DamageRStr));
      end
      else
      begin
        Window.TCUnitPnl.Visible := False;
        Window.TCAbilPnl.Visible := True;
        Window.TargetSelPnl.Visible := False;
        AoWHSSet.FAbilityControl.GetAbility(General.FCombatUnit.FSelectedAbility).GetCombatInfo(
          General.FCombatUnit.FUnit.FUnit, AbilityInfo);
        Window.AbilNameLbl.Text := AoWHSSet.FAbilityControl.GetAbility(General.FCombatUnit.FSelectedAbility).GetName(
          General.FCombatUnit.FUnit.FUnit);
        if AbilityInfo.Attack > 0 then Window.AbilAttLbl.Text := IntToStr(AbilityInfo.Attack)
        else Window.AbilAttLbl.Text := '-';
        if AbilityInfo.Damage > 0 then Window.AbilDamLbl.Text := IntToStr(AbilityInfo.Damage)
        else Window.AbilDamLbl.Text := '-';
        Window.AbilStat.Items.Clear;
        if dtFire in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(FireRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtCold in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(ColdRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtLightning in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(LightningRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtMagic in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(MagicRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtPoison in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(PoisonRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtDeath in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(DeathRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtHoly in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(HolyRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtPhysical in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(PhysicalRStr) + ' ' + TranslateRStr(E1DamageRStr));
        if dtWall in AbilityInfo.DamageTypes then
          Window.AbilStat.Items.Add(TranslateRStr(WallRStr) + ' ' + TranslateRStr(E1DamageRStr));
      end;
      Window.UnitName.Items.Clear;
      Window.UnitName.Items.Add(U.GetName);
      Window.UnitHits.Max := U.GetHits;
      Window.UnitHits.Position := U.GetHitPoints;
    end;
  end;
  TCUnit.TCUnitWin.Visible := True;
end;

end.
