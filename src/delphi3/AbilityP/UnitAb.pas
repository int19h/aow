unit UnitAb;

{ UnitAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration remains blocked by the older imported AoWE ABI.
  Unregistration uses the recovered control directly; its offset changed from $74 to $80. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AbilPack;

type
  TUnitAbility = class;


  { TUnitAbility (instance size 24, VMT 00402F40) }
  TUnitAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; Flags: TAbilityFlags; Cost: Integer);
  end;

procedure RegisterUnitAbilities(GameSet: TAoWHSSet);
procedure UnRegisterUnitAbilities(GameSet: TAoWHSSet);

implementation

constructor TUnitAbility.Create(AbilityID: Integer; AName: string; Flags: TAbilityFlags; Cost: Integer);
begin
  inherited Create;
  FName := AName;
  FAbilityID := AbilityID;
  FFlags := Flags;
  FCost := Cost;
end;

function TUnitAbility.GetAbilityID: Integer;
begin
  Result := FAbilityID;
end;

procedure RegisterUnitAbilities(GameSet: TAoWHSSet);
begin
  { Blocked: the legacy TAbility and resource-string imports are absent from current AoWEPACK. }
end;

procedure UnRegisterUnitAbilities(GameSet: TAoWHSSet);
var Control: TAbilityControl;
begin
  Control := GameSet.FAbilityControl;
  Control.UnregisterAbility(Control.GetAbility(35));
  Control.UnregisterAbility(Control.GetAbility(36));
  Control.UnregisterAbility(Control.GetAbility(37));
  Control.UnregisterAbility(Control.GetAbility(38));
  Control.UnregisterAbility(Control.GetAbility(39));
  Control.UnregisterAbility(Control.GetAbility(40));
  Control.UnregisterAbility(Control.GetAbility(41));
  Control.UnregisterAbility(Control.GetAbility(42));
  Control.UnregisterAbility(Control.GetAbility(43));
  Control.UnregisterAbility(Control.GetAbility(44));
  Control.UnregisterAbility(Control.GetAbility(45));
  Control.UnregisterAbility(Control.GetAbility(46));
  Control.UnregisterAbility(Control.GetAbility(47));
  Control.UnregisterAbility(Control.GetAbility(48));
  Control.UnregisterAbility(Control.GetAbility(49));
  Control.UnregisterAbility(Control.GetAbility(50));
  Control.UnregisterAbility(Control.GetAbility(51));
  Control.UnregisterAbility(Control.GetAbility(52));
  Control.UnregisterAbility(Control.GetAbility(53));
  Control.UnregisterAbility(Control.GetAbility(54));
  Control.UnregisterAbility(Control.GetAbility(55));
  Control.UnregisterAbility(Control.GetAbility(56));
  Control.UnregisterAbility(Control.GetAbility(57));
  Control.UnregisterAbility(Control.GetAbility(58));
  Control.UnregisterAbility(Control.GetAbility(59));
  Control.UnregisterAbility(Control.GetAbility(60));
  Control.UnregisterAbility(Control.GetAbility(61));
  Control.UnregisterAbility(Control.GetAbility(62));
  Control.UnregisterAbility(Control.GetAbility(63));
  Control.UnregisterAbility(Control.GetAbility(64));
  Control.UnregisterAbility(Control.GetAbility(65));
  Control.UnregisterAbility(Control.GetAbility(66));
  Control.UnregisterAbility(Control.GetAbility(67));
  Control.UnregisterAbility(Control.GetAbility(70));
  Control.UnregisterAbility(Control.GetAbility(71));
  Control.UnregisterAbility(Control.GetAbility(72));
  Control.UnregisterAbility(Control.GetAbility(73));
end;


initialization
finalization

end.
