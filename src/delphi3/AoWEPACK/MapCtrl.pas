unit MapCtrl;

{ Draft declarations of MapCtrl, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWMapControl = class;


  { TAoWMapControl (instance size 404, VMT 55804D8C) }
  TAoWMapControl = class(TComponent)
  public
    F_AoWMapControl_24: array[0..367] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure LinkToHSM;  { draft }
    procedure ReleaseHSM;  { draft }
    procedure ActivateHSM(A1: Integer);  { draft }
    procedure DeactivateHSM(A1: Integer);  { draft }
    procedure DblClick;  { draft }
    procedure MapChanged;  { draft }
    procedure ScannerIconsChanged;  { draft }
    procedure MapSettingsChanged;  { draft }
    procedure SelectHS;  { draft }
    procedure DeselectHS;  { draft }
    procedure PlayerChanged;  { draft }
    procedure ExitGameEvent;  { draft }
    procedure NewTurn;  { draft }
    procedure EndTurn(A1: Integer);  { draft }
    procedure SeatedPlayerChanged;  { draft }
    procedure GemsChanged(A1: Integer);  { draft }
    procedure IncomeChanged(A1: Integer);  { draft }
    procedure UpkeepChanged(A1: Integer);  { draft }
    procedure PlayerMagicChanged(A1: Integer);  { draft }
    procedure GlobalMagicChanged;  { draft }
    procedure ShowMessage;  { draft }
    procedure ChangeDay;  { draft }
    procedure CombatEvent;  { draft }
    procedure LogbookChanged(A1: Integer);  { draft }
    procedure StructureChanged;  { draft }
    procedure StructureDestroyed;  { draft }
    procedure ArmyChanged;  { draft }
    procedure ArmyDestroyed;  { draft }
    procedure HSChanged;  { draft }
    procedure UnitChanged;  { draft }
    procedure UnitDestroyed;  { draft }
    procedure GameOver;  { draft }
    procedure GameTerminated;  { draft }
    procedure PlayerTerminated;  { draft }
    procedure ExecuteEventLog(A1: Integer);  { draft }
    procedure ActivateCombatMap;  { draft }
    procedure DeactivateCombatMap;  { draft }
    procedure TargetSelectionChange(A1: Integer);  { draft }
    procedure CastSpell;  { draft }
    procedure ViewPortChange;  { draft }
    procedure ActivateAbility;  { draft }
    procedure DiplomaticChange;  { draft }
    procedure RelationsChanged;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TAoWMapControl.Create(AOwner: Classes.TComponent);
begin end;

destructor TAoWMapControl.Destroy;
begin end;

procedure TAoWMapControl.LinkToHSM;
begin end;

procedure TAoWMapControl.ReleaseHSM;
begin end;

procedure TAoWMapControl.ActivateHSM(A1: Integer);
begin end;

procedure TAoWMapControl.DeactivateHSM(A1: Integer);
begin end;

procedure TAoWMapControl.DblClick;
begin end;

procedure TAoWMapControl.MapChanged;
begin end;

procedure TAoWMapControl.ScannerIconsChanged;
begin end;

procedure TAoWMapControl.MapSettingsChanged;
begin end;

procedure TAoWMapControl.SelectHS;
begin end;

procedure TAoWMapControl.DeselectHS;
begin end;

procedure TAoWMapControl.PlayerChanged;
begin end;

procedure TAoWMapControl.ExitGameEvent;
begin end;

procedure TAoWMapControl.NewTurn;
begin end;

procedure TAoWMapControl.EndTurn(A1: Integer);
begin end;

procedure TAoWMapControl.SeatedPlayerChanged;
begin end;

procedure TAoWMapControl.GemsChanged(A1: Integer);
begin end;

procedure TAoWMapControl.IncomeChanged(A1: Integer);
begin end;

procedure TAoWMapControl.UpkeepChanged(A1: Integer);
begin end;

procedure TAoWMapControl.PlayerMagicChanged(A1: Integer);
begin end;

procedure TAoWMapControl.GlobalMagicChanged;
begin end;

procedure TAoWMapControl.ShowMessage;
begin end;

procedure TAoWMapControl.ChangeDay;
begin end;

procedure TAoWMapControl.CombatEvent;
begin end;

procedure TAoWMapControl.LogbookChanged(A1: Integer);
begin end;

procedure TAoWMapControl.StructureChanged;
begin end;

procedure TAoWMapControl.StructureDestroyed;
begin end;

procedure TAoWMapControl.ArmyChanged;
begin end;

procedure TAoWMapControl.ArmyDestroyed;
begin end;

procedure TAoWMapControl.HSChanged;
begin end;

procedure TAoWMapControl.UnitChanged;
begin end;

procedure TAoWMapControl.UnitDestroyed;
begin end;

procedure TAoWMapControl.GameOver;
begin end;

procedure TAoWMapControl.GameTerminated;
begin end;

procedure TAoWMapControl.PlayerTerminated;
begin end;

procedure TAoWMapControl.ExecuteEventLog(A1: Integer);
begin end;

procedure TAoWMapControl.ActivateCombatMap;
begin end;

procedure TAoWMapControl.DeactivateCombatMap;
begin end;

procedure TAoWMapControl.TargetSelectionChange(A1: Integer);
begin end;

procedure TAoWMapControl.CastSpell;
begin end;

procedure TAoWMapControl.ViewPortChange;
begin end;

procedure TAoWMapControl.ActivateAbility;
begin end;

procedure TAoWMapControl.DiplomaticChange;
begin end;

procedure TAoWMapControl.RelationsChanged;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
