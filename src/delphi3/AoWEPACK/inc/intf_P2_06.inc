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
    function GetPositionItem(Position: Integer): TItem;
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

  { THeroUpdateTE (instance size 32, VMT 557119E8) }
  THeroUpdateTE = class(TTokenEvent)
  public
    F_HeroUpdateTE_10: Integer;
    F_HeroUpdateTE_14: Byte;
    F_HeroUpdateTE_15: array[0..2] of Byte;
    F_HeroUpdateTE_18: Integer;
    F_HeroUpdateTE_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { THeroPowerSource (instance size 12, VMT 55711AAC) }
  THeroPowerSource = class(TPowerSource)
  public
    F_HeroPowerSource_08: Integer;
    procedure Name(A1: Integer); override;
    procedure Power; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Select(A1: Integer; A2: Integer); override;
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

