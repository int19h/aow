unit AbilPack;

{ AbilityP.dpl plug-in recovered from the original machine code.
  The legacy ability layout below predates the shipped AoWEPACK ABI. }

{$O-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  { Legacy AoWE.TAbility imported by AbilityP (instance size 20, five VMT slots).
    The recovered AoWEPACK TAbility is a different ABI (size 36); keep this stub local.
    Subclasses add their ability ID at $14 and have instance size 24. }
  TAbilityFlags = set of 0..7;
  TAbilityKinds = set of 0..7;
  TAbility = class(TObject)
  public
    FName: string; { $04 }
    FReserved: Integer; { $08 }
    FMoveTypes: TAbilityKinds; { $0C }
    FStrikeTypes: TAbilityKinds; { $0D }
    FImmunityTypes: TAbilityKinds; { $0E }
    FFlags: TAbilityFlags; { $0F }
    FCost: Integer; { $10 }
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

uses MoveAb, ImmAb, StrikeAb, ShootAb, UnitAb;

var AbilityPlugIn: TAbililtyPlugIn;

function TAbililtyPlugIn.Name: string;
begin
  Result := 'Abilities';
end;

function TAbililtyPlugIn.Initialize(AEngine: Engine.TEngine): Boolean;
begin
  if AEngine is TAoWEngine then
  begin
    Result := inherited Initialize(AEngine);
    if Result then
    begin
      RegisterMoveAbilities(TAoWEngine(AEngine).FGameSet);
      RegisterImmunityAbilities(TAoWEngine(AEngine).FGameSet);
      RegisterStrikeAbilities(TAoWEngine(AEngine).FGameSet);
      RegisterShootAbilities(TAoWEngine(AEngine).FGameSet);
      RegisterUnitAbilities(TAoWEngine(AEngine).FGameSet);
    end;
  end
  else
    Result := False;
end;

function TAbililtyPlugIn.Finalize(AEngine: Engine.TEngine): Boolean;
begin
  AddRef;
  Result := inherited Finalize(AEngine);
  if Result then
  begin
    UnRegisterMoveAbilities(TAoWEngine(AEngine).FGameSet);
    UnRegisterImmunityAbilities(TAoWEngine(AEngine).FGameSet);
    UnRegisterStrikeAbilities(TAoWEngine(AEngine).FGameSet);
    UnRegisterShootAbilities(TAoWEngine(AEngine).FGameSet);
    UnRegisterUnitAbilities(TAoWEngine(AEngine).FGameSet);
  end;
  Release;
end;


initialization
  AbilityPlugIn := TAbililtyPlugIn.Create;
finalization
  AbilityPlugIn.Release;

end.
