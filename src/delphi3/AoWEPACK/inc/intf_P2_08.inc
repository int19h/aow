{ Interface declaration run owned by P2. }
  { TAoWEngine (instance size 128, VMT 557244F0) }
  TAoWEngine = class(THSEngine)
  public
    F_AoWEngine_58: Integer;
    FRegistry: TAoWRegistry; { $5C }
    { conflict: FRegistry: TRegistry; }
    F_AoWEngine_60: Integer;
    FGameSet: TAoWHSSet; { $64 }
    { conflict: FHSSet: TAoWHSSet; }
    FCombatFont: TImageLibraryFont; { $68 }
    { conflict: FUnitFont: TImageLibraryFont; }
    F_AoWEngine_6C: Byte;
    FAnimationDetail: Byte; { $6D }
    F_AoWEngine_6E: Byte;
    F_AoWEngine_6F: array[0..0] of Byte;
    FCampaign: TAoWCampaign; { $70 }
    F_AoWEngine_74: Integer;
    F_AoWEngine_78: Integer;
    F_AoWEngine_7C: Byte;
    F_AoWEngine_7D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure UpdateStartupDirectory; override;
    function TranslateText(const Text: string): string; override;
    procedure CreateHSSet; override;
    procedure SetHSMap(Value: HSEngine.THSMap); override;
    procedure CloseHSM(AProgress: Engine.TProgressEvent); override;
    procedure TranslateEObject(A1: Integer; A2: Integer);  { draft }
    procedure TranslateEObjectFromFile(A1: Integer; A2: Integer);  { draft }
    procedure ExportTextToFile(A1: Integer; A2: Integer);  { draft }
    function TranslateRStr(const S: string): string;
    procedure GetMajorVersion;  { draft }
    procedure GetMinorVersion;  { draft }
    procedure GetBuildNumber;  { draft }
    procedure SetVersion(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetVersionStr(A1: Integer);  { draft }
    procedure RegisteredVersion;  { draft }
    procedure RegisteredTo(A1: Integer);  { draft }
    procedure RequestAccess(A1: Integer; A2: Integer);  { draft }
    procedure CloseCampaign;  { draft }
    procedure LoadCampaignMap(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure LoadCampaign(A1: Integer);  { draft }
    procedure SaveCampaign(const FileName: string);
    procedure NewCampaign(A1: Integer);  { draft }
  end;

  { TAgeOfWondersEngine (instance size 64, VMT 55724618) }
  TAgeOfWondersEngine = class(THexagonSpriteEngine)
  public
    F_AgeOfWondersEngine_3C: array[0..3] of Byte;
    destructor Destroy; override;
    procedure SetHSEngine(Value: HSEngine.THSEngine); override;
    procedure CreateEngine; override;
  end;

