program matchtest;

{ Host program for the byte-matching of AbilityP.dpl: it references every class and every
  non-virtual method so that the linker keeps them; it is linked, never run. Build from this
  directory with the original compiler into a directory with a short path (DCC32 crashes on
  long paths):
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -Q "-U..\AoWEPACK;..\HSEPack;..;..\Gfxepack;..\Ilpack;..\Dcpack;..\SoundP;..\Network;..\aowFXpck;..\aowInt;..\Localize"
      -O.. -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  AbilPack in 'AbilPack.pas',
  AbilityP in 'AbilityP.pas',
  ImmAb in 'ImmAb.pas',
  MoveAb in 'MoveAb.pas',
  ShootAb in 'ShootAb.pas',
  StrikeAb in 'StrikeAb.pas',
  UnitAb in 'UnitAb.pas';

var
  C: TClass;
  P: Pointer;

procedure Use(C: TClass; P: Pointer);
begin
  Writeln(Integer(C), Integer(P));
end;

begin
  Use(AbilPack.TAbility, nil);
  Use(AbilPack.TAbililtyPlugIn, nil);
  Use(ImmAb.TImmunityAbility, nil);
  Use(MoveAb.TMoveAbility, nil);
  Use(ShootAb.TShootAbility, nil);
  Use(StrikeAb.TStrikeAbility, nil);
  Use(UnitAb.TUnitAbility, nil);
  Use(nil, @AbilityP.GetPackageInfoTable);
  Use(nil, @AbilityP.PackageLoad);
  Use(nil, @AbilityP.PackageUnload);
  Use(nil, @ImmAb.TImmunityAbility.Create);
  Use(nil, @ImmAb.RegisterImmunityAbilities);
  Use(nil, @ImmAb.UnRegisterImmunityAbilities);
  Use(nil, @MoveAb.TMoveAbility.Create);
  Use(nil, @MoveAb.RegisterMoveAbilities);
  Use(nil, @MoveAb.UnRegisterMoveAbilities);
  Use(nil, @ShootAb.TShootAbility.Create);
  Use(nil, @ShootAb.RegisterShootAbilities);
  Use(nil, @ShootAb.UnRegisterShootAbilities);
  Use(nil, @StrikeAb.TStrikeAbility.Create);
  Use(nil, @StrikeAb.RegisterStrikeAbilities);
  Use(nil, @StrikeAb.UnRegisterStrikeAbilities);
  Use(nil, @UnitAb.TUnitAbility.Create);
  Use(nil, @UnitAb.RegisterUnitAbilities);
  Use(nil, @UnitAb.UnRegisterUnitAbilities);
  { per-package host additions: one include line per package (hosts\Pkg.inc), nothing else here }
  {$I hosts\T4.inc}
end.
