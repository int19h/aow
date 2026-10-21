unit CMapCtrl;

{ Draft declarations of CMapCtrl, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  { AoWE names this map-event payload TMapChangedInfo in the recovered source. }
  TMapAreaInfo = AoWE.TMapChangedInfo;

  TAoWCombatMapControl = class;

  TOnMessageEvent = procedure(var EMsg: TEMsg) of object;
  TSelectHSEvent = procedure(HS: THexagonSprite) of object;
  TDeselectHSEvent = procedure(HS: THexagonSprite) of object;
  TPlayerChangedEvent = procedure(Player: Shortint) of object;
  TShowMessageEvent = procedure(const Info: TShowMessageInfo) of object;
  TTurnChangedEvent = procedure(Turn: Integer) of object;
  TMapChangedEvent = procedure(const ChangedArea: TMapAreaInfo) of object;
  TOnGameOverEvent = procedure(Player: Shortint) of object;
  TOnExecuteEventLogEvent = procedure(EventLog: TEventLog; ExecuteDoneEvent: TExecuteDoneEvent) of object;
  TCastCombatSpellEvent = procedure(SC: TCombatSpellCaster) of object;
  TActivateCombatAbilityEvent = procedure(AAI: TActivateAbilityInfo) of object;

  { TAoWCombatMapControl (instance size 196, VMT 00435F38) }
  TAoWCombatMapControl = class(TComponent)
  public
    F_AoWCombatMapControl_24: array[0..3] of Byte;
    F_AoWCombatMapControl_28: Integer;
    F_AoWCombatMapControl_2C: array[0..3] of Byte;
    F_AoWCombatMapControl_30: Integer;
    F_AoWCombatMapControl_34: array[0..3] of Byte;
    F_AoWCombatMapControl_38: Integer;
    F_AoWCombatMapControl_3C: array[0..3] of Byte;
    F_AoWCombatMapControl_40: Integer;
    F_AoWCombatMapControl_44: array[0..3] of Byte;
    F_AoWCombatMapControl_48: Integer;
    F_AoWCombatMapControl_4C: array[0..3] of Byte;
    F_AoWCombatMapControl_50: Integer;
    F_AoWCombatMapControl_54: array[0..3] of Byte;
    F_AoWCombatMapControl_58: Integer;
    F_AoWCombatMapControl_5C: array[0..3] of Byte;
    F_AoWCombatMapControl_60: Integer;
    F_AoWCombatMapControl_64: array[0..3] of Byte;
    F_AoWCombatMapControl_68: Integer;
    F_AoWCombatMapControl_6C: array[0..3] of Byte;
    F_AoWCombatMapControl_70: Integer;
    F_AoWCombatMapControl_74: array[0..3] of Byte;
    F_AoWCombatMapControl_78: Integer;
    F_AoWCombatMapControl_7C: array[0..3] of Byte;
    F_AoWCombatMapControl_80: Integer;
    F_AoWCombatMapControl_84: array[0..3] of Byte;
    F_AoWCombatMapControl_88: Integer;
    F_AoWCombatMapControl_8C: array[0..3] of Byte;
    F_AoWCombatMapControl_90: Integer;
    F_AoWCombatMapControl_94: array[0..3] of Byte;
    F_AoWCombatMapControl_98: Integer;
    F_AoWCombatMapControl_9C: array[0..3] of Byte;
    F_AoWCombatMapControl_A0: Integer;
    F_AoWCombatMapControl_A4: array[0..3] of Byte;
    F_AoWCombatMapControl_A8: Integer;
    F_AoWCombatMapControl_AC: array[0..3] of Byte;
    F_AoWCombatMapControl_B0: Integer;
    F_AoWCombatMapControl_B4: array[0..3] of Byte;
    F_AoWCombatMapControl_B8: Integer;
    F_AoWCombatMapControl_BC: array[0..3] of Byte;
    F_AoWCombatMapControl_C0: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure LinkToHSM;  { draft }
    procedure ReleaseHSM;  { draft }
    procedure ActivateHSM(A1: Integer);  { draft }
    procedure DeactivateHSM(A1: Integer);  { draft }
    procedure MapChanged(A1: Integer);  { draft }
    procedure SelectHS(A1: Integer);  { draft }
    procedure DeselectHS(A1: Integer);  { draft }
    procedure MouseOverTarget(A1: Integer);  { draft }
    procedure UnitChanged(A1: Integer);  { draft }
    procedure PlayerChanged(A1: Integer);  { draft }
    procedure SeatedPlayerChanged(A1: Integer);  { draft }
    procedure GemsChanged(A1: Integer);  { draft }
    procedure IncomeChanged(A1: Integer);  { draft }
    procedure UpkeepChanged(A1: Integer);  { draft }
    procedure ShowMessage(A1: Integer);  { draft }
    procedure ChangeTurn(A1: Integer);  { draft }
    procedure LogbookChanged(A1: Integer);  { draft }
    procedure ExecuteEventLog(A1: Integer);  { draft }
    procedure ActivateMap(A1: Integer);  { draft }
    procedure DeactivateMap(A1: Integer);  { draft }
    procedure CastSpell(A1: Integer);  { draft }
    procedure ActivateAbility(A1: Integer);  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TAoWCombatMapControl.Create(AOwner: Classes.TComponent);
begin end;

destructor TAoWCombatMapControl.Destroy;
begin end;

procedure TAoWCombatMapControl.LinkToHSM;
begin end;

procedure TAoWCombatMapControl.ReleaseHSM;
begin end;

procedure TAoWCombatMapControl.ActivateHSM(A1: Integer);
begin end;

procedure TAoWCombatMapControl.DeactivateHSM(A1: Integer);
begin end;

procedure TAoWCombatMapControl.MapChanged(A1: Integer);
begin end;

procedure TAoWCombatMapControl.SelectHS(A1: Integer);
begin end;

procedure TAoWCombatMapControl.DeselectHS(A1: Integer);
begin end;

procedure TAoWCombatMapControl.MouseOverTarget(A1: Integer);
begin end;

procedure TAoWCombatMapControl.UnitChanged(A1: Integer);
begin end;

procedure TAoWCombatMapControl.PlayerChanged(A1: Integer);
begin end;

procedure TAoWCombatMapControl.SeatedPlayerChanged(A1: Integer);
begin end;

procedure TAoWCombatMapControl.GemsChanged(A1: Integer);
begin end;

procedure TAoWCombatMapControl.IncomeChanged(A1: Integer);
begin end;

procedure TAoWCombatMapControl.UpkeepChanged(A1: Integer);
begin end;

procedure TAoWCombatMapControl.ShowMessage(A1: Integer);
begin end;

procedure TAoWCombatMapControl.ChangeTurn(A1: Integer);
begin end;

procedure TAoWCombatMapControl.LogbookChanged(A1: Integer);
begin end;

procedure TAoWCombatMapControl.ExecuteEventLog(A1: Integer);
begin end;

procedure TAoWCombatMapControl.ActivateMap(A1: Integer);
begin end;

procedure TAoWCombatMapControl.DeactivateMap(A1: Integer);
begin end;

procedure TAoWCombatMapControl.CastSpell(A1: Integer);
begin end;

procedure TAoWCombatMapControl.ActivateAbility(A1: Integer);
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
