unit AGCPlugins;

{ Draft declarations of AGCPlugins, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TAIGroupRazeControl = class;
  TAIGroupDefendTargetSelector = class;
  TAIGroupWanderControl = class;

  TAIGroupRazeControlMode = set of (rcmCannotDefend, rcmOnMigrate, rcmAlways); { ot=1 }
  TAIGroupDefendTargetSelectorMode = set of (dtmCalculateMovepathBFS); { ot=1 }
  TAIGroupWanderMode = set of (wmTransportersAllowed); { ot=1 }

  { TAIGroupRazeControl (instance size 44, VMT 557D70AC) }
  TAIGroupRazeControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupRazeControl_1C: Integer;
    F_AIGroupRazeControl_20: Byte;
    F_AIGroupRazeControl_21: Byte;
    F_AIGroupRazeControl_22: array[0..1] of Byte;
    F_AIGroupRazeControl_24: Integer;
    F_AIGroupRazeControl_28: Integer;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Reset;  { draft }
    procedure Setup;  { draft }
    procedure ExecuteRaze(A1: Integer);  { draft }
    procedure ValidateRazeCity(A1: Integer; A2: Integer);  { draft }
    procedure ValidateRazeStructure(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIGroupDefendTargetSelector (instance size 60, VMT 557D71EC) }
  TAIGroupDefendTargetSelector = class(TAIGroupControlPlugin)
  public
    F_AIGroupDefendTargetSelector_1C: Integer;
    F_AIGroupDefendTargetSelector_20: Integer;
    F_AIGroupDefendTargetSelector_24: Integer;
    F_AIGroupDefendTargetSelector_28: Byte;
    F_AIGroupDefendTargetSelector_29: array[0..2] of Byte;
    F_AIGroupDefendTargetSelector_2C: Integer;
    F_AIGroupDefendTargetSelector_30: Integer;
    F_AIGroupDefendTargetSelector_34: Word;
    F_AIGroupDefendTargetSelector_36: array[0..1] of Byte;
    F_AIGroupDefendTargetSelector_38: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Reset;  { draft }
    procedure GetMovepathBattleFieldStrength(A1: Integer);  { draft }
    procedure TargetFoundEvent(A1: Integer);  { draft }
    procedure Setup(A1: Integer);  { draft }
  end;

  { TAIGroupWanderControl (instance size 44, VMT 557D7334) }
  TAIGroupWanderControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupWanderControl_1C: Byte;
    F_AIGroupWanderControl_1D: array[0..2] of Byte;
    F_AIGroupWanderControl_20: Integer;
    F_AIGroupWanderControl_24: Integer;
    F_AIGroupWanderControl_28: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Reset;  { draft }
    procedure Setup;  { draft }
  end;


implementation

procedure TAIGroupRazeControl.Reset;
begin end;

procedure TAIGroupRazeControl.Setup;
begin end;

procedure TAIGroupRazeControl.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupRazeControl.ExecuteRaze(A1: Integer);
begin end;

procedure TAIGroupRazeControl.ValidateRazeCity(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupRazeControl.ValidateRazeStructure(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupRazeControl.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIGroupDefendTargetSelector.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupDefendTargetSelector.Destroy;
begin end;

procedure TAIGroupDefendTargetSelector.Reset;
begin end;

procedure TAIGroupDefendTargetSelector.GetMovepathBattleFieldStrength(A1: Integer);
begin end;

procedure TAIGroupDefendTargetSelector.TargetFoundEvent(A1: Integer);
begin end;

procedure TAIGroupDefendTargetSelector.Setup(A1: Integer);
begin end;

procedure TAIGroupDefendTargetSelector.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupDefendTargetSelector.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIGroupWanderControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupWanderControl.Destroy;
begin end;

procedure TAIGroupWanderControl.Reset;
begin end;

procedure TAIGroupWanderControl.Setup;
begin end;

procedure TAIGroupWanderControl.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupWanderControl.Process(A1: Integer; A2: Integer);
begin end;


initialization
finalization

end.
