{ Interface declaration run owned by P2. }
  { TAoWEngine (instance size $80, VMT 557244F0): $58 FVersion, $5C FRegistry,
    $60 FGameMap, $64 FGameSet, $68 FCombatFont, $6C FDebugMode, $6D FAnimationDetail,
    $6E FDemo, $70 FCampaign, $74 FEmailGames, $78 FDictionary, $7C FLanguage. }
  TAoWEngine = class(THSEngine)
  public
    FVersion: Integer; { $58 }
    FRegistry: TAoWRegistry; { $5C }
    { conflict: FRegistry: TRegistry; }
    FGameMap: TAoWHSMap; { $60 }
    FGameSet: TAoWHSSet; { $64 }
    { conflict: FHSSet: TAoWHSSet; }
    FCombatFont: TImageLibraryFont; { $68 }
    { conflict: FUnitFont: TImageLibraryFont; }
    FDebug: Boolean; { $6C; 55773E51 }
    { conflict: FDebugMode: Boolean; }
    { conflict: FDeveloper: Boolean; }
    FAnimationDetail: Byte; { $6D }
    { conflict: FAnimationDetail: TDetailLevel; }
    FDemo: Boolean; { $6E; 5578B227 }
    F_AoWEngine_6F: array[0..0] of Byte;
    FCampaign: TAoWCampaign; { $70 }
    FEmailGames: TEmailGameControl; { $74 }
    FDictionary: TAoWDictionary; { $78 }
    FLanguage: Byte; { $7C; 55773B82 }
    { conflict: FLanguage: TAoWLanguage; }
    F_AoWEngine_7D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure UpdateStartupDirectory; override;
    function TranslateText(const Text: string): string; override;
    procedure CreateHSSet; override;
    procedure SetHSMap(Value: HSEngine.THSMap); override;
    procedure CloseHSM(AProgress: Engine.TProgressEvent); override;
    procedure TranslateEObject(Obj: TEObject; Dictionary: TIvDictionary);
    procedure TranslateEObjectFromFile(Obj: TEObject; const FileName: string);
    procedure ExportTextToFile(const FileName: string; Obj: TEObject);
    function TranslateRStr(const S: string): string;
    function GetMajorVersion: Integer;
    function GetMinorVersion: Integer;
    function GetBuildNumber: Integer;
    procedure SetVersion(Major, Minor, Build: Integer);
    function GetVersionStr: string;
    function RegisteredVersion: Boolean;
    function RegisteredTo: string;
    function RequestAccess(const Name, Code: string): Boolean;
    procedure CloseCampaign;
    procedure LoadCampaignMap(AProgress: Engine.TProgressEvent);
    procedure LoadCampaign(const FileName: string);
    procedure SaveCampaign(const FileName: string);
    procedure NewCampaign(AClassID: Integer);
  end;

  { TAgeOfWondersEngine (instance size $40, VMT 55724618): $3C FGameEngine. }
  TAgeOfWondersEngine = class(THexagonSpriteEngine)
  public
    FGameEngine: THSEngine; { $3C }
    destructor Destroy; override;
    procedure SetHSEngine(Value: HSEngine.THSEngine); override;
    procedure CreateEngine; override;
  end;

