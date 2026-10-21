{ Interface declaration run owned by P2. }
  { TWorldFXHS (instance size $28, VMT 55709CA8): $0C FFinished, $10 FFrame,
    $14 FX, $18 FY, $1C FLayer, $20 FPath, $24 FEffectType. }
  TWorldFXHS = class(TFixedVisibleHS)
  public
    FDone: Boolean; { $0C; 55779027 }
    { conflict: FFinished: Boolean; }
    F_WorldFXHS_0D: array[0..2] of Byte;
    FFrame: Integer; { $10 }
    FX: Integer; { $14; 557ED3B2 }
    FY: Integer; { $18; 557ED3BB }
    FLayer: Integer; { $1C; 557ED3C2 }
    FPath: TXYZList; { $20 }
    FEffectType: TworldFXType; { $24; 5577908E }
    F_WorldFXHS_25: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewFrame(Sender: TObject);
  end;

