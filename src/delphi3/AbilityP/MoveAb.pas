unit MoveAb;

{ MoveAb from AbilityP.dpl: the ability class is recovered and byte-matched.
  Registration routines remain draft because the imported AoWE API is an older ABI. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TMoveAbility = class;


  { TMoveAbility (instance size 24, VMT 00401C1C) }
  TMoveAbility = class(TAbility)
  public
    FAbilityID: Integer; { $14; instance size $18 }
    function GetAbilityID: Integer; override;
    constructor Create(AbilityID: Integer; AName: string; MoveTypes: TAbilityKinds);
  end;

procedure RegisterMoveAbilities(A1: Integer);  { draft }
procedure UnRegisterMoveAbilities(A1: Integer);  { draft }

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

procedure RegisterMoveAbilities(A1: Integer);
begin end;

procedure UnRegisterMoveAbilities(A1: Integer);
begin end;


initialization
finalization

end.
