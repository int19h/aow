unit MainAG;

{ Draft declarations of MainAG, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TPassiveAG = class;
  TPassiveAGC = class;
  TFortifyAG = class;
  TFortifyAGC = class;
  TSuicidalAG = class;
  TSuicidalAGC = class;
  TTransportAG = class;
  TTransportAGC = class;


  { TPassiveAG (instance size 80, VMT 557D9ED8) }
  TPassiveAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetLoc(A1: Integer; A2: Integer); override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
    procedure GetRecruitableUnits(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TPassiveAGC (instance size 368, VMT 557DA028) }
  TPassiveAGC = class(TAIGroupControl)
  public
    procedure ProcessStates(A1: Integer; A2: Integer); override;
    procedure CombinePassiveGroups;  { draft }
  end;

  { TFortifyAG (instance size 80, VMT 557DA118) }
  TFortifyAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TFortifyAGC (instance size 384, VMT 557DA268) }
  TFortifyAGC = class(TAIGroupControl)
  public
    F_FortifyAGC_170: array[0..15] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
    procedure Split; override;
    procedure FortifyCity;  { draft }
    procedure GetSurroundingEnemyStrength(A1: Integer; A2: Integer);  { draft }
    procedure UpdateRequiredStrength(A1: Integer; A2: Integer);  { draft }
    procedure MakeUselessUnitsPassive(A1: Integer; A2: Integer);  { draft }
    procedure CanBreachWall;  { draft }
  end;

  { TSuicidalAG (instance size 80, VMT 557DA358) }
  TSuicidalAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TSuicidalAGC (instance size 368, VMT 557DA4A8) }
  TSuicidalAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone; override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
  end;

  { TTransportAG (instance size 80, VMT 557DA5A0) }
  TTransportAG = class(TAIGroup)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TTransportAGC (instance size 368, VMT 557DA6F8) }
  TTransportAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone; override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
    procedure SetupME(A1: Integer; A2: Integer); override;
  end;


implementation

constructor TPassiveAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPassiveAG.ClassID: Integer;
begin Result := 0; end;

procedure TPassiveAG.Behavior;
begin end;

procedure TPassiveAG.GroupControlClass;
begin end;

procedure TPassiveAG.GetLoc(A1: Integer; A2: Integer);
begin end;

procedure TPassiveAG.GetRecruitableUnits(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPassiveAGC.CombinePassiveGroups;
begin end;

procedure TPassiveAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

constructor TFortifyAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFortifyAG.ClassID: Integer;
begin Result := 0; end;

procedure TFortifyAG.Behavior;
begin end;

procedure TFortifyAG.GroupControlClass;
begin end;

constructor TFortifyAGC.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TFortifyAGC.Destroy;
begin end;

procedure TFortifyAGC.FortifyCity;
begin end;

procedure TFortifyAGC.Split;
begin end;

procedure TFortifyAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TFortifyAGC.GetSurroundingEnemyStrength(A1: Integer; A2: Integer);
begin end;

procedure TFortifyAGC.UpdateRequiredStrength(A1: Integer; A2: Integer);
begin end;

procedure TFortifyAGC.MakeUselessUnitsPassive(A1: Integer; A2: Integer);
begin end;

procedure TFortifyAGC.CanBreachWall;
begin end;

procedure TFortifyAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

constructor TSuicidalAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSuicidalAG.ClassID: Integer;
begin Result := 0; end;

procedure TSuicidalAG.Behavior;
begin end;

procedure TSuicidalAG.GroupControlClass;
begin end;

procedure TSuicidalAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSuicidalAGC.MoveExecuterDone;
begin end;

procedure TSuicidalAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

constructor TTransportAG.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TTransportAG.Destroy;
begin end;

class function TTransportAG.ClassID: Integer;
begin Result := 0; end;

procedure TTransportAG.Behavior;
begin end;

procedure TTransportAG.GroupControlClass;
begin end;

procedure TTransportAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTransportAGC.MoveExecuterDone;
begin end;

procedure TTransportAGC.SetupME(A1: Integer; A2: Integer);
begin end;

procedure TTransportAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;


initialization
finalization

end.
