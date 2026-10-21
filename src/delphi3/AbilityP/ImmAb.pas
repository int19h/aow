unit ImmAb;

{ ImmAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration remains blocked by the older imported AoWE ABI.
  Unregistration uses the recovered control directly; its offset changed from $74 to $80. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AbilPack;

type
  TImmunityAbility = class;


  { TImmunityAbility (instance size 24, VMT 0040201C) }
  TImmunityAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; ImmunityTypes: TAbilityKinds);
  end;

procedure RegisterImmunityAbilities(GameSet: TAoWHSSet);
procedure UnRegisterImmunityAbilities(GameSet: TAoWHSSet);

implementation

constructor TImmunityAbility.Create(AbilityID: Integer; AName: string; ImmunityTypes: TAbilityKinds);
begin
  inherited Create;
  FName := AName;
  FAbilityID := AbilityID;
  if not (3 in ImmunityTypes) then
    FFlags := [0, 4, 5, 7]
  else
    FFlags := [0];
  FImmunityTypes := ImmunityTypes;
  FCost := 10;
end;

function TImmunityAbility.GetAbilityID: Integer;
begin
  Result := FAbilityID;
end;

procedure RegisterImmunityAbilities(GameSet: TAoWHSSet);
begin
  { Blocked: the legacy TAbility and resource-string imports are absent from current AoWEPACK. }
end;

procedure UnRegisterImmunityAbilities(GameSet: TAoWHSSet);
var Control: TAbilityControl;
begin
  Control := GameSet.FAbilityControl;
  Control.UnregisterAbility(Control.GetAbility(7));
  Control.UnregisterAbility(Control.GetAbility(8));
  Control.UnregisterAbility(Control.GetAbility(9));
  Control.UnregisterAbility(Control.GetAbility(10));
  Control.UnregisterAbility(Control.GetAbility(11));
  Control.UnregisterAbility(Control.GetAbility(12));
  Control.UnregisterAbility(Control.GetAbility(13));
  Control.UnregisterAbility(Control.GetAbility(74));
end;


initialization
finalization

end.
