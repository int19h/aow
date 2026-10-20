{ Interface declaration run owned by P2. }
  { THeroInventory (instance size 24, VMT 5571162C): inherited +04 FOwner is the hero;
    +08 FChildren holds inventory slots. }
  THeroInventory = class(TItemList)
  public
    destructor Destroy; override;
    function GetControlStyle: Engine.TEControlStyles; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(var X, Y, L: Shortint); override;
    function GetFreeSlot: Integer;
    function GetAbilityCount: Integer;
    function GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
    function GetAbilityEnabled(AbilityID: Integer): Boolean;
    function GetAbilitySet(AbilityID: Integer): Boolean;
    function GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
    function GetSlot(Position: THeroItemPosition): TItem;
  end;

  { THeroItems (instance size 24, VMT 55711738): inherited +04 FOwner is the hero;
    +08 FChildren holds six equipment slots. }
  THeroItems = class(TItemList)
  public
    destructor Destroy; override;
    function GetControlStyle: Engine.TEControlStyles; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(var X, Y, L: Shortint); override;
    function GetAttack: Shortint;
    function GetDefense: Shortint;
    function GetDamage: Shortint;
    function GetResistance: Shortint;
    function GetMoveTypes: TMoveTypes;
    function GetImmunityTypes: TDamageTypes;
    function GetProtectionTypes: TDamageTypes;
    function GetAbilityCount: Integer;
    function GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
    function GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
    function GetAbilityEnabled(AbilityID: Integer): Boolean;
    function GetAbilitySet(AbilityID: Integer): Boolean;
    function GetPositionItem(Position: THeroItemPosition): TItem;
    function GetPositionItemType(Position: THeroItemPosition): TItemType;
    function GetItemTypePosition(ItemType: TItemType): THeroItemPosition;
    function CanPlaceItem(Item: TItem; Position: THeroItemPosition): Boolean;
    function PlaceItem(Item: TItem; Position: THeroItemPosition): Boolean;
  end;

  { THeroUpgradeTE (instance size 32, VMT 55711920): +10 FUnitID; +14 FPlayer;
    +15..1A statistic upgrades; +1C FAbilities. }
  THeroUpgradeTE = class(TTokenEvent)
  public
    FUnitID: Integer;  { $10 }
    FPlayer: Shortint;  { $14 }
    FAttack: Shortint;  { $15 }
    FDefense: Shortint;  { $16 }
    FResistance: Shortint;  { $17 }
    FDamage: Shortint;  { $18 }
    FMoves: Shortint;  { $19 }
    FHits: Shortint;  { $1A }
    F_HeroUpgradeTE_1B: array[0..0] of Byte;
    FAbilities: TAbilityOwner;  { $1C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Setup(Hero: THero);
  end;

  { THeroUpdateTE (instance size 32, VMT 557119E8): +10 FUnitID;
    +14 FMode; +18 FItemID (also spell ID); +1C FParameter. }
  THeroUpdateTE = class(TTokenEvent)
  public
    FUnitID: Integer; { $10 }
    FMode: THeroUpdateMode; { $14 }
    F_HeroUpdateTE_15: array[0..2] of Byte;
    FItemID: Integer; { $18 }
    FParameter: Integer; { $1C }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { THeroPowerSource (instance size 12, VMT 55711AAC): +08 FHero. }
  THeroPowerSource = class(TPowerSource)
  public
    FHero: THero;  { $08 }
    function Name: string; override;
    function Power: Integer; override;
    procedure GetLocation(var A1, A2, A3: Shortint); override;
    procedure Select; override;
  end;

  { THeroUpgradeEventLog (instance size 36, VMT 55711B88): +18 FUnitID;
    +1C FOldLevel; +1D FNewLevel; +20 FDay. }
  THeroUpgradeEventLog = class(TEventLog)
  public
    FUnitID: Integer;  { $18 }
    FOldLevel: Byte;  { $1C }
    FNewLevel: Byte;  { $1D }
    F_HeroUpgradeEventLog_1E: array[0..1] of Byte;
    FDay: Integer;  { $20 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
  end;

