{ Interface declaration run owned by P1. }
  { TStructureConstructionControl (instance size 8, VMT 557246C8) }
  TStructureConstructionControl = class(TConstructionControl)
  public
    function CanConstruct(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Construct(AUnit: TAbstractUnit): Boolean; override;
    function ValidateLocation(AUnit: TAbstractUnit; var Reason: string): Boolean; virtual;  { +05C }
    function StructureResource(AUnit: TAbstractUnit): TStructureResource; virtual;  { +060 }
    { conflict: function StructureResource: TStructureResource; virtual; }
  end;

  { TConstructStructureTE (instance size 28, VMT 557247C0) }
  TConstructStructureTE = class(TTokenEvent)
  public
    FUnitID: Integer; { $10 }
    FPlayer: Shortint; { $14 }
    F_ConstructStructureTE_15: array[0..2] of Byte;
    FControlID: Integer; { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

