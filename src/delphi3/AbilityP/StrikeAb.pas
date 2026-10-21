unit StrikeAb;

{ StrikeAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration remains blocked by the older imported AoWE ABI.
  Unregistration uses the recovered control directly; its offset changed from $74 to $80. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AbilPack;

type
  TStrikeAbility = class;


  { TStrikeAbility (instance size 24, VMT 0040248C) }
  TStrikeAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; StrikeTypes: TAbilityKinds; Cost: Integer);
  end;

procedure RegisterStrikeAbilities(GameSet: TAoWHSSet);
procedure UnRegisterStrikeAbilities(GameSet: TAoWHSSet);

implementation

constructor TStrikeAbility.Create(AbilityID: Integer; AName: string; StrikeTypes: TAbilityKinds; Cost: Integer);
begin
  inherited Create;
  FName := AName;
  FAbilityID := AbilityID;
  FFlags := [0];
  FStrikeTypes := StrikeTypes;
  FCost := Cost;
end;

function TStrikeAbility.GetAbilityID: Integer;
begin
  Result := FAbilityID;
end;

procedure RegisterStrikeAbilities(GameSet: TAoWHSSet);
begin
  { Blocked: the legacy TAbility and resource-string imports are absent from current AoWEPACK. }
end;

procedure UnRegisterStrikeAbilities(GameSet: TAoWHSSet);
var Control: TAbilityControl;
begin
  Control := GameSet.FAbilityControl;
  Control.UnregisterAbility(Control.GetAbility(14));
  Control.UnregisterAbility(Control.GetAbility(15));
  Control.UnregisterAbility(Control.GetAbility(16));
  Control.UnregisterAbility(Control.GetAbility(17));
  Control.UnregisterAbility(Control.GetAbility(18));
  Control.UnregisterAbility(Control.GetAbility(19));
  Control.UnregisterAbility(Control.GetAbility(20));
  Control.UnregisterAbility(Control.GetAbility(21));
end;


initialization
finalization

end.
