unit MoveAb;

{ Draft declarations of MoveAb, from AbilityP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AbilPack;

type
  TMoveAbility = class;


  { TMoveAbility (instance size 24, VMT 00401C1C) }
  TMoveAbility = class(TAbility)
  public
    F_MoveAbility_14: Integer;
    function GetAbilityID: Integer; override;
    function Create(A1: Byte): Integer;  { draft }
  end;

procedure RegisterMoveAbilities(A1: Integer);  { draft }
procedure UnRegisterMoveAbilities(A1: Integer);  { draft }

implementation

function TMoveAbility.Create(A1: Byte): Integer;
begin Result := 0; end;

function TMoveAbility.GetAbilityID: Integer;
begin Result := 0; end;

procedure RegisterMoveAbilities(A1: Integer);
begin end;

procedure UnRegisterMoveAbilities(A1: Integer);
begin end;


initialization
finalization

end.
