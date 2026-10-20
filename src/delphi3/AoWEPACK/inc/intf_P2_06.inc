{ Interface declaration run owned by P2. }
  { THeroInventory (instance size 24, VMT 5571162C) }
  THeroInventory = class(TItemList)
  public
    destructor Destroy; override;
    function GetControlStyle: Engine.TEControlStyles; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetFreeSlot(A1: Integer; A2: Integer);  { draft }
    procedure GetAbilityCount(A1: Integer; A2: Integer);  { draft }
    procedure GetSuperlativeEnabledAbOwner(A1: Integer);  { draft }
    procedure GetAbilityEnabled(A1: Integer);  { draft }
    procedure GetAbilitySet(A1: Integer);  { draft }
    procedure GetSuperlativeAbOwner(A1: Integer);  { draft }
    procedure GetSlot(A1: Integer);  { draft }
  end;

  { THeroItems (instance size 24, VMT 55711738) }
  THeroItems = class(TItemList)
  public
    destructor Destroy; override;
    function GetControlStyle: Engine.TEControlStyles; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetAttack;  { draft }
    procedure GetDefense;  { draft }
    procedure GetDamage;  { draft }
    procedure GetResistance;  { draft }
    procedure GetMoveTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetImmunityTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetProtectionTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetAbilityCount(A1: Integer; A2: Integer);  { draft }
    procedure GetSuperlativeEnabledAbOwner(A1: Integer);  { draft }
    procedure GetSuperlativeAbOwner(A1: Integer);  { draft }
    procedure GetAbilityEnabled(A1: Integer; A2: Integer);  { draft }
    procedure GetAbilitySet(A1: Integer; A2: Integer);  { draft }
    procedure GetPositionItem(A1: Integer);  { draft }
    procedure GetPositionItemType(A1: Byte);  { draft }
    procedure GetItemTypePosition(A1: Byte);  { draft }
    procedure CanPlaceItem(A1: Integer; A2: Integer);  { draft }
    procedure PlaceItem(A1: Integer; A2: Integer);  { draft }
  end;

  { THeroUpgradeTE (instance size 32, VMT 55711920) }
  THeroUpgradeTE = class(TTokenEvent)
  public
    F_HeroUpgradeTE_10: Integer;
    F_HeroUpgradeTE_14: Byte;
    F_HeroUpgradeTE_15: Byte;
    F_HeroUpgradeTE_16: Byte;
    F_HeroUpgradeTE_17: Byte;
    F_HeroUpgradeTE_18: Byte;
    F_HeroUpgradeTE_19: Byte;
    F_HeroUpgradeTE_1A: Byte;
    F_HeroUpgradeTE_1B: array[0..0] of Byte;
    F_HeroUpgradeTE_1C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Setup(A1: Integer);  { draft }
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

  { THeroUpgradeEventLog (instance size 36, VMT 55711B88) }
  THeroUpgradeEventLog = class(TEventLog)
  public
    F_HeroUpgradeEventLog_18: Integer;
    F_HeroUpgradeEventLog_1C: Byte;
    F_HeroUpgradeEventLog_1D: Byte;
    F_HeroUpgradeEventLog_1E: array[0..1] of Byte;
    F_HeroUpgradeEventLog_20: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
  end;

