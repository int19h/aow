unit UnitAb;

{ Draft declarations of UnitAb, from AbilityP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TUnitAbility = class;


  { TUnitAbility (instance size 24, VMT 00402F40) }
  TUnitAbility = class(TAbility)
  public
    F_UnitAbility_14: Integer;
    function GetAbilityID: Integer; override;
    function Create(A1: Byte): Integer;  { draft }
  end;

procedure RegisterUnitAbilities(A1: Integer);  { draft }
procedure UnRegisterUnitAbilities(A1: Integer);  { draft }

implementation

function TUnitAbility.Create(A1: Byte): Integer;
begin Result := 0; end;

function TUnitAbility.GetAbilityID: Integer;
begin Result := 0; end;

procedure RegisterUnitAbilities(A1: Integer);
begin end;

procedure UnRegisterUnitAbilities(A1: Integer);
begin end;


initialization
finalization

end.
