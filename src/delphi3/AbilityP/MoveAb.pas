unit MoveAb;

{ MoveAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration remains blocked by the older imported AoWE ABI.
  Unregistration uses the recovered control directly; its offset changed from $74 to $80. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AbilPack;

type
  TMoveAbility = class;


  { TMoveAbility (instance size 24, VMT 00401C1C) }
  TMoveAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; MoveTypes: TAbilityKinds);
  end;

procedure RegisterMoveAbilities(GameSet: TAoWHSSet);
procedure UnRegisterMoveAbilities(GameSet: TAoWHSSet);

implementation

constructor TMoveAbility.Create(AbilityID: Integer; AName: string; MoveTypes: TAbilityKinds);
begin
  inherited Create;
  FName := AName;
  FAbilityID := AbilityID;
  FMoveTypes := MoveTypes;
  FFlags := [0, 5];
  FCost := 0;
end;

function TMoveAbility.GetAbilityID: Integer;
begin
  Result := FAbilityID;
end;

procedure RegisterMoveAbilities(GameSet: TAoWHSSet);
begin
  { Blocked: the legacy TAbility and resource-string imports are absent from current AoWEPACK. }
end;

procedure UnRegisterMoveAbilities(GameSet: TAoWHSSet);
var Control: TAbilityControl;
begin
  Control := GameSet.FAbilityControl;
  Control.UnregisterAbility(Control.GetAbility(0));
  Control.UnregisterAbility(Control.GetAbility(1));
  Control.UnregisterAbility(Control.GetAbility(2));
  Control.UnregisterAbility(Control.GetAbility(3));
  Control.UnregisterAbility(Control.GetAbility(4));
  Control.UnregisterAbility(Control.GetAbility(5));
  Control.UnregisterAbility(Control.GetAbility(6));
end;


initialization
finalization

end.
