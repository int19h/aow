unit BehaviorAG;

{ Draft declarations of BehaviorAG, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TAbstractBehaviorAG = class;
  TAbstractBehaviorAGC = class;
  TSkirmishAG = class;
  TSkirmishAGC = class;
  TNormalAG = class;
  TNormalAGC = class;
  TDefenderAG = class;
  TDefenderAGC = class;
  TAggressorAG = class;
  TAggressorAGC = class;
  TExpanderAG = class;
  TExpanderAGC = class;
  TScorcherAG = class;
  TScorcherAGC = class;


  { TAbstractBehaviorAG (instance size 80, VMT 557DC2CC) }
  TAbstractBehaviorAG = class(TAIGroup)
  public
    function CooperateWithGroup(Group: TAIGroup; Target: TAIGroupControlTarget): Boolean; override;
  end;

  { TAbstractBehaviorAGC (instance size 372, VMT 557DC430) }
  TAbstractBehaviorAGC = class(TAIGroupControl)
  public
    F_AbstractBehaviorAGC_170: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSkirmishAG (instance size 80, VMT 557DC53C) }
  TSkirmishAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TSkirmishAGC (instance size 372, VMT 557DC690) }
  TSkirmishAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TNormalAG (instance size 80, VMT 557DC78C) }
  TNormalAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TNormalAGC (instance size 372, VMT 557DC8E0) }
  TNormalAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TDefenderAG (instance size 80, VMT 557DC9D4) }
  TDefenderAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TDefenderAGC (instance size 372, VMT 557DCB28) }
  TDefenderAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TAggressorAG (instance size 80, VMT 557DCC24) }
  TAggressorAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TAggressorAGC (instance size 372, VMT 557DCD80) }
  TAggressorAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TExpanderAG (instance size 80, VMT 557DCE7C) }
  TExpanderAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TExpanderAGC (instance size 372, VMT 557DCFD0) }
  TExpanderAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TScorcherAG (instance size 80, VMT 557DD0CC) }
  TScorcherAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TScorcherAGC (instance size 372, VMT 557DD220) }
  TScorcherAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;


implementation

function TAbstractBehaviorAG.CooperateWithGroup(Group: TAIGroup; Target: TAIGroupControlTarget): Boolean;
begin Result := False; end;

constructor TAbstractBehaviorAGC.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAbstractBehaviorAGC.Destroy;
begin end;

constructor TNormalAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TNormalAG.ClassID: Integer;
begin Result := 0; end;

class function TNormalAG.Behavior: TGroupBehavior;
begin Result := gbNone; end;

class function TNormalAG.GroupControlClass: TAIGroupControlClass;
begin Result := nil; end;

procedure TNormalAGC.ProcessStates;
begin end;

constructor TDefenderAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TDefenderAG.ClassID: Integer;
begin Result := 0; end;

class function TDefenderAG.Behavior: TGroupBehavior;
begin Result := gbNone; end;

class function TDefenderAG.GroupControlClass: TAIGroupControlClass;
begin Result := nil; end;

procedure TDefenderAGC.ProcessStates;
begin end;

constructor TAggressorAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAggressorAG.ClassID: Integer;
begin Result := 0; end;

class function TAggressorAG.Behavior: TGroupBehavior;
begin Result := gbNone; end;

class function TAggressorAG.GroupControlClass: TAIGroupControlClass;
begin Result := nil; end;

procedure TAggressorAGC.ProcessStates;
begin end;

constructor TExpanderAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TExpanderAG.ClassID: Integer;
begin Result := 0; end;

class function TExpanderAG.Behavior: TGroupBehavior;
begin Result := gbNone; end;

class function TExpanderAG.GroupControlClass: TAIGroupControlClass;
begin Result := nil; end;

procedure TExpanderAGC.ProcessStates;
begin end;

constructor TScorcherAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TScorcherAG.ClassID: Integer;
begin Result := 0; end;

class function TScorcherAG.Behavior: TGroupBehavior;
begin Result := gbNone; end;

class function TScorcherAG.GroupControlClass: TAIGroupControlClass;
begin Result := nil; end;

procedure TScorcherAGC.ProcessStates;
begin end;

constructor TSkirmishAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSkirmishAG.ClassID: Integer;
begin Result := 0; end;

class function TSkirmishAG.Behavior: TGroupBehavior;
begin Result := gbNone; end;

class function TSkirmishAG.GroupControlClass: TAIGroupControlClass;
begin Result := nil; end;

procedure TSkirmishAGC.ProcessStates;
begin end;


initialization
finalization

end.
