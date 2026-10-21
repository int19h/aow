unit ShootAb;

{ Draft declarations of ShootAb, from AbilityP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TShootAbility = class;


  { TShootAbility (instance size 24, VMT 004028F4) }
  TShootAbility = class(TAbility)
  public
    F_ShootAbility_14: Integer;
    function GetAbilityID: Integer; override;
    function Create(A1: Byte): Integer;  { draft }
  end;

procedure RegisterShootAbilities(A1: Integer);  { draft }
procedure UnRegisterShootAbilities(A1: Integer);  { draft }

implementation

function TShootAbility.Create(A1: Byte): Integer;
begin Result := 0; end;

function TShootAbility.GetAbilityID: Integer;
begin Result := 0; end;

procedure RegisterShootAbilities(A1: Integer);
begin end;

procedure UnRegisterShootAbilities(A1: Integer);
begin end;


initialization
finalization

end.
