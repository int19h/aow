unit StrikeAb;

{ Draft declarations of StrikeAb, from AbilityP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TStrikeAbility = class;


  { TStrikeAbility (instance size 24, VMT 0040248C) }
  TStrikeAbility = class(TAbility)
  public
    F_StrikeAbility_14: Integer;
    function GetAbilityID: Integer; override;
    function Create(A1: Byte): Integer;  { draft }
  end;

procedure RegisterStrikeAbilities(A1: Integer);  { draft }
procedure UnRegisterStrikeAbilities(A1: Integer);  { draft }

implementation

function TStrikeAbility.Create(A1: Byte): Integer;
begin Result := 0; end;

function TStrikeAbility.GetAbilityID: Integer;
begin Result := 0; end;

procedure RegisterStrikeAbilities(A1: Integer);
begin end;

procedure UnRegisterStrikeAbilities(A1: Integer);
begin end;


initialization
finalization

end.
