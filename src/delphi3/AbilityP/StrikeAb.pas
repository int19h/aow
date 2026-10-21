unit StrikeAb;

{ StrikeAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration routines remain draft because the imported AoWE API is an older ABI. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TStrikeAbility = class;


  { TStrikeAbility (instance size 24, VMT 0040248C) }
  TStrikeAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; StrikeTypes: TAbilityKinds; Cost: Integer);
  end;

procedure RegisterStrikeAbilities(A1: Integer);  { draft }
procedure UnRegisterStrikeAbilities(A1: Integer);  { draft }

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

procedure RegisterStrikeAbilities(A1: Integer);
begin end;

procedure UnRegisterStrikeAbilities(A1: Integer);
begin end;


initialization
finalization

end.
