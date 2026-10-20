{ Interface declaration run owned by P1. }
  { TStructureConstructionControl (instance size 8, VMT 557246C8) }
  TStructureConstructionControl = class(TConstructionControl)
  public
    procedure CanConstruct(A1: Integer; A2: Integer); override;
    procedure Construct(A1: Integer); override;
    function ValidateLocation(AUnit: TAbstractUnit; var Reason: string): Boolean; virtual;  { +05C }
    function StructureResource(AUnit: TAbstractUnit): TStructureResource; virtual;  { +060 }
  end;

  { TConstructStructureTE (instance size 28, VMT 557247C0) }
  TConstructStructureTE = class(TTokenEvent)
  public
    F_ConstructStructureTE_10: Integer;
    F_ConstructStructureTE_14: Byte;
    F_ConstructStructureTE_15: array[0..2] of Byte;
    F_ConstructStructureTE_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

