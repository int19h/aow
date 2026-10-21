unit AbilPack;

{ Draft declarations of AbilPack, from AbilityP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  { Legacy AoWE.TAbility imported by AbilityP (instance size 20, five VMT slots).
    The recovered AoWEPACK TAbility is a different ABI (size 36); keep this stub local.
    Subclasses add their ability ID at $14 and have instance size 24. }
  TAbility = class(TObject)
  public
    F_Ability_04: array[0..15] of Byte;
    procedure Execute; virtual; abstract; { +000 draft }
    function GetAbilityID: Integer; virtual; abstract; { +004 }
    procedure NewDay; virtual; abstract; { +008 draft }
    procedure NewCombatTurn; virtual; abstract; { +00C draft }
    function AbilityDataClass: TEObjectClass; virtual; abstract; { +010 draft }
  end;

  TAbililtyPlugIn = class;


  { TAbililtyPlugIn (instance size 16, VMT 00403BFC) }
  TAbililtyPlugIn = class(TPlugIn)
  public
    function Name: string; override;
    function Initialize(AEngine: Engine.TEngine): Boolean; override;
    function Finalize(AEngine: Engine.TEngine): Boolean; override;
  end;


implementation

function TAbililtyPlugIn.Name: string;
begin Result := ''; end;

function TAbililtyPlugIn.Initialize(AEngine: Engine.TEngine): Boolean;
begin Result := False; end;

function TAbililtyPlugIn.Finalize(AEngine: Engine.TEngine): Boolean;
begin Result := False; end;


initialization
finalization

end.
