{ Interface declaration run owned by P1. }
  { TStructureAIPA (instance size 28, VMT 5571999C) }
  TStructureAIPA = class(TAIPlayerAction)
  public
    F_StructureAIPA_14: Integer;
    F_StructureAIPA_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TStructurePhase1AIPA (instance size 28, VMT 55719A78) }
  TStructurePhase1AIPA = class(TStructureAIPA)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
  end;

  { TStructurePhase2AIPA (instance size 28, VMT 55719B60) }
  TStructurePhase2AIPA = class(TStructureAIPA)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
  end;

  { TAIGroupProduction (instance size 16, VMT 55719DDC) }
  TAIGroupProduction = class(TEObject)
  public
    F_AIGroupProduction_08: array[0..7] of Byte;
  end;

