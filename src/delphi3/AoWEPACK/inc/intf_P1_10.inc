{ Interface declaration run owned by P1. }
  { TFlagControl: size $14; $0C race resources, $10 flag library. VMT 557149F8. }
  TFlagControl = class(TEControlStyleObject)
  public
    FRaceResources: TRaceResourceList; { $0C }
    FFlags: TCustomImageLibrary; { $10 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ShowFlag(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc);
    procedure ShowFlagEx(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc; ShowBase: Boolean);
    procedure ShowStructureFlag(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc);
    procedure ShowStructureFlagEx(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc; ShowBase: Boolean);
  end;

  { TAoWHSSet: instance size $A0, inherited $00..$47; fields $48..$9C
    listed below. VMT 55714AB8. Shared resources and controls for a game pack. }
  TAoWHSSet = class(THSSet)
  public
    FGeneralImages: TCustomImageLibrary;  { $48 }
    FCursorImages: TCustomImageLibrary;  { $4C }
    FCombatImages: TCustomImageLibrary;  { $50 }
    FRaceResources: TRaceResourceList;  { $54 }
    FPadControl: TPadControl;  { $58 }
    FUnitResources: TUnitResourceList;  { $5C }
    FUnitGFXResources: TUnitGFXResourceList;  { $60 }
    FHeroResources: THeroResourceList;  { $64 }
    FItemGFXResources: TItemGFXList;  { $68 }
    FItemLibraries: TItemLibraryManager;  { $6C }
    FHeroLibraries: THeroLibraryManager;  { $70 }
    FFaceResources: TFaceResourceList;  { $74 }
    FFlagControl: TFlagControl;  { $78 }
    FFireControl: TFireControl;  { $7C }
    FAbilityControl: TAbilityControl;  { $80 }
    FSpellControl: TSpellControl;  { $84 }
    FCombatResources: TMapObjectResourceList;  { $88 }
    FCombatHexagons: THexagonControl;  { $8C }
    FCombatRoads: TRoadControl;  { $90 }
    FImageSequences: TImageSequenceList;  { $94 }
    FTextControl: TTextControl;  { $98 }
    FHSSCRC: Integer;  { $9C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetFileCRC(const FileName: string; AtEnd: Boolean): Integer;
    function RetrieveHSSCRC: Integer;
  end;

