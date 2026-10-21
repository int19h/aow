{ Interface declaration run owned by P1. }
  { TStructureAIPA (instance size 28, VMT 5571999C) }
  TStructureAIPA = class(TAIPlayerAction)
  public
    FPhase: Integer; { $14; 557626E3 }
    FStructureIDs: TIntegerList; { $18 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Activate: Boolean; override;
    function Process: Boolean; override;
  end;

  { TStructurePhase1AIPA (instance size 28, VMT 55719A78) }
  TStructurePhase1AIPA = class(TStructureAIPA)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function Priority: Integer; override;
  end;

  { TStructurePhase2AIPA (instance size 28, VMT 55719B60) }
  TStructurePhase2AIPA = class(TStructureAIPA)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function Priority: Integer; override;
  end;

  { TAIGroupProduction (instance size 16, VMT 55719DDC) }
  TAIGroupProduction = class(TEObject)
  public
    FUnit: TAbstractUnit; { $08 } FControl: TProductionControl; { $0C }
  end;

