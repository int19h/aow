unit ImmAb;

{ Draft declarations of ImmAb, from AbilityP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TImmunityAbility = class;


  { TImmunityAbility (instance size 24, VMT 0040201C) }
  TImmunityAbility = class(TAbility)
  public
    F_ImmunityAbility_14: Integer;
    function GetAbilityID: Integer; override;
    function Create(A1: Byte): Integer;  { draft }
  end;

procedure RegisterImmunityAbilities(A1: Integer);  { draft }
procedure UnRegisterImmunityAbilities(A1: Integer);  { draft }

implementation

function TImmunityAbility.Create(A1: Byte): Integer;
begin Result := 0; end;

function TImmunityAbility.GetAbilityID: Integer;
begin Result := 0; end;

procedure RegisterImmunityAbilities(A1: Integer);
begin end;

procedure UnRegisterImmunityAbilities(A1: Integer);
begin end;


initialization
finalization

end.
