{ Interface declaration run owned by P2. }
  { TWorldFXHS (instance size 40, VMT 55709CA8): $14 Xhp, $18 Yhp, $1C layer. }
  TWorldFXHS = class(TFixedVisibleHS)
  public
    FDone: Boolean; { $0C; 55779027 }
    F_WorldFXHS_0D: array[0..2] of Byte;
    F_WorldFXHS_10: Integer;
    FX: Integer; { $14; 557ED3B2 }
    FY: Integer; { $18; 557ED3BB }
    FLayer: Integer; { $1C; 557ED3C2 }
    F_WorldFXHS_20: Integer;
    FEffectType: TworldFXType; { $24; 5577908E }
    F_WorldFXHS_25: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewFrame(A1: Integer);  { draft }
  end;

