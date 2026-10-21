unit ImmAb;

{ ImmAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration routines remain draft because the imported AoWE API is an older ABI. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TImmunityAbility = class;


  { TImmunityAbility (instance size 24, VMT 0040201C) }
  TImmunityAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; ImmunityTypes: TAbilityKinds);
  end;

procedure RegisterImmunityAbilities(A1: Integer);  { draft }
procedure UnRegisterImmunityAbilities(A1: Integer);  { draft }

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

procedure RegisterImmunityAbilities(A1: Integer);
begin end;

procedure UnRegisterImmunityAbilities(A1: Integer);
begin end;


initialization
finalization

end.
