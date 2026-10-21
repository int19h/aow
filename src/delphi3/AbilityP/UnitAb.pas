unit UnitAb;

{ UnitAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration routines remain draft because the imported AoWE API is an older ABI. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TUnitAbility = class;


  { TUnitAbility (instance size 24, VMT 00402F40) }
  TUnitAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; Flags: TAbilityFlags; Cost: Integer);
  end;

procedure RegisterUnitAbilities(A1: Integer);  { draft }
procedure UnRegisterUnitAbilities(A1: Integer);  { draft }

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

procedure RegisterUnitAbilities(A1: Integer);
begin end;

procedure UnRegisterUnitAbilities(A1: Integer);
begin end;


initialization
finalization

end.
