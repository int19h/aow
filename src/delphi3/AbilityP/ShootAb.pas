unit ShootAb;

{ ShootAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration remains blocked by the older imported AoWE ABI.
  Unregistration uses the recovered control directly; its offset changed from $74 to $80. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AbilPack;

type
  TShootAbility = class;


  { TShootAbility (instance size 24, VMT 004028F4) }
  TShootAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; Flags: TAbilityFlags; Cost: Integer);
  end;

procedure RegisterShootAbilities(GameSet: TAoWHSSet);
procedure UnRegisterShootAbilities(GameSet: TAoWHSSet);

implementation

constructor TShootAbility.Create(AbilityID: Integer; AName: string; Flags: TAbilityFlags; Cost: Integer);
begin
  inherited Create;
  FName := AName;
  FAbilityID := AbilityID;
  FFlags := Flags;
  FCost := Cost;
end;

function TShootAbility.GetAbilityID: Integer;
begin
  Result := FAbilityID;
end;

procedure RegisterShootAbilities(GameSet: TAoWHSSet);
begin
  { Blocked: the legacy TAbility and resource-string imports are absent from current AoWEPACK. }
end;

procedure UnRegisterShootAbilities(GameSet: TAoWHSSet);
var Control: TAbilityControl;
begin
  Control := GameSet.FAbilityControl;
  Control.UnregisterAbility(Control.GetAbility(22));
  Control.UnregisterAbility(Control.GetAbility(23));
  Control.UnregisterAbility(Control.GetAbility(24));
  Control.UnregisterAbility(Control.GetAbility(25));
  Control.UnregisterAbility(Control.GetAbility(26));
  Control.UnregisterAbility(Control.GetAbility(27));
  Control.UnregisterAbility(Control.GetAbility(28));
  Control.UnregisterAbility(Control.GetAbility(29));
  Control.UnregisterAbility(Control.GetAbility(30));
  Control.UnregisterAbility(Control.GetAbility(31));
  Control.UnregisterAbility(Control.GetAbility(32));
  Control.UnregisterAbility(Control.GetAbility(33));
  Control.UnregisterAbility(Control.GetAbility(34));
  Control.UnregisterAbility(Control.GetAbility(75));
  Control.UnregisterAbility(Control.GetAbility(76));
end;


initialization
finalization

end.
