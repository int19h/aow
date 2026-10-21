{ Interface declaration run owned by P4. }
  TAbilityDamageValues = record
    SourceDamage, SourceCost, TargetDamage, TargetCost: Integer;
    DamageTypes: TDamageTypes;
  end;
  TAbilityCombatInfo = packed record
    Kind: TCombatModes;
    Attack, Damage: Shortint;
    DamageTypes: TDamageTypes;
    RepeatCount: Shortint;
  end;
  TMeleeStrike = record
    AttackBonus, DamageBonus, DamageValue: Integer;
    Side: TCombatSideIndex; { $0C }
    F_0D: array[0..6] of Byte;
  end;
  { TEnchantment (instance size 24, VMT 5570A98C; $08 ID, $0C source,
    $10 upkeep, $14 signed dispel resistance) }
  TEnchantment = class(TEObject)
  public
    FEnchantmentID: Integer; { $08 }
    FSource: Shortint;  { $0C }
    F_Enchantment_0D: array[0..2] of Byte;
    FUpkeep: Integer; { $10 }
    FDispelResistance: Shortint; { $14; 5577C1A0 }
    F_Enchantment_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName: string; virtual;
    function GetBinding: string; virtual;
    procedure SetUpkeep(A1: Integer); virtual;
    procedure SetSource(Player: Shortint); virtual;
    function GetAIUpkeepPriority: Integer; virtual;
    procedure GetLocation(var A1, A2, A3: Shortint); virtual;
    function CenterToLocation: Boolean; virtual; { +064; 5577BFA4 }
    function Dispel: Boolean; virtual;
    procedure Select; virtual; { +06C; 5577C0B4 }
    function DispelChance(A1: Integer): Integer;
  end;

  { TEnchantmentList (instance size 12, VMT 5570AA70) }
  TEnchantmentList = class(TENode)
  public
    function GetEnchantments(A1: Integer): TEnchantment;
    function IndexOfID(A1: Integer): Integer; { 5577C1D8 }
    function FindID(A1: Integer): TEnchantment;
  end;

  { TChangePlayerMagicTE (instance size 28, VMT 5570ABDC; $10 mode, $11 player, $14/$18 values) }
  TChangePlayerMagicTE = class(TTokenEvent)
  public
    FMode: TChangePlayerMagicMode; { $10 }
    FPlayerIndex: Byte; { $11 }
    F_ChangePlayerMagicTE_12: array[0..1] of Byte;
    FValue: Integer; { $14 }
    FExtraValue: Integer; { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TPlayerMagicEventLog (instance size 44, VMT 5570AD0C; $18 mode,
    $1C location, $20 spell ID, $24 value, $28 enchantment name) }
  TPlayerMagicEventLog = class(TEventLog)
  public
    FMode: TPlayerMagicEventMode; { $18 }
    F_PlayerMagicEventLog_19: array[0..2] of Byte;
    FLocation: TXYL; { $1C }
    FSpellID: Integer; { $20 }
    FValue: Integer; { $24 }
    FEnchantmentName: string; { $28 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation; override;
  end;

  { TPowerSource (instance size 8, VMT 5570AE18) }
  TPowerSource = class(TEObject)
  public
    function Name: string; virtual;
    function Power: Integer; virtual;
    procedure GetLocation(var A1, A2, A3: Shortint); virtual;
    procedure CenterToLocation(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure Select; virtual;
  end;

  { TExternalPowerSource (instance size 12, VMT 5570AEEC; $08 external power control) }
  TExternalPowerSource = class(TPowerSource)
  public
    FExternalPowerControl: TPlayerMagicControl; { $08 }
    function Name: string; override;
    function Power: Integer; override;
  end;

  { TPowerSourceList (instance size 12, VMT 5570AFD0) }
  TPowerSourceList = class(TENode)
  public
    function GetItems(A1: Integer): TPowerSource; { 5577CA19 }
  end;

  { TPlayerMagicControl (instance size 76, VMT 5570B198; $08 next ID,
    $0C cheat, $10 player, $14 updates, $18/$1C external mana/power,
    $20 external source, $24 mana, $28 spheres, $2C research percentage,
    $30 spells, $34 research spell, $38 points, $3C enchantments,
    $40 power sources, $44/$45 enchantment sets, $48 changed events) }
  TPlayerMagicControl = class(TEObject)
  public
    FNextEnchantmentID: Integer; { $08 }
    FCheatEnabled: Boolean; { $0C }
    F_PlayerMagicControl_0D: array[0..2] of Byte;
    FPlayer: TPlayer; { $10 }
    FUpdateCount: Integer; { $14 }
    FExternalMana: Integer; { $18 }
    FExternalPower: Integer; { $1C }
    FExternalPowerSource: TExternalPowerSource; { $20 }
    FMana: Integer; { $24 }
    FSpheres: TMagicSpheres; { $28 }
    F_PlayerMagicControl_2A: array[0..1] of Byte;
    FResearchPercentage: Integer; { $2C }
    FSpells: TIntegerList; { $30 }
    FResearchSpellID: Integer; { $34 }
    FResearchPointsLeft: Integer; { $38 }
    FEnchantments: TEnchantmentList; { $3C }
    FPowerSources: TPowerSourceList; { $40 }
    FActiveEnchantments: TPlayerEnchantmentTypes; { $44; 557EFE57 }
    FEnemyEnchantments: TPlayerEnchantmentTypes; { $45 }
    { conflict: FGlobalEnchantmentFlags: Byte; }
    F_PlayerMagicControl_46: array[0..1] of Byte;
    FChangedEvents: TEventList; { $48 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCheatEnabled: Boolean;
    procedure SetActiveEnchantments(Value: TPlayerEnchantmentTypes);
    procedure UpdateEnemyEnchantments;
    function GetManaIncome: Integer;
    function GetManaUpkeep: Integer;
    procedure SetMana(A1: Integer);
    function GetPower: Integer; { 5577CA00 }
    procedure OutOfMana(A1: Integer); { 5577CA34 }
    procedure RemoveEnchantments; { 5577CB9C }
    function ValidateEnchantmentsUpkeep: Boolean; { 5577CBC4 }
    function ExecuteSpellResearched(A1: Integer): Boolean; { 5577CBF8 }
    procedure NewTurn; { 5577CC2C }
    procedure SetSpheres(Value: TMagicSpheres); { 5577CE60 }
    function GetNetPower: Integer; { 5577CEC4 }
    function GetNetPowerToMana: Integer; { 5577CEE4 }
    function GetNetPowerToResearch: Integer; { 5577B829 }
    function ResearchTurns(Power, Points: Integer): Integer; { 5577B839 }
    function GetResearchTurnsLeft: Integer; { 5577CFD8 }
    function ValidResearchSpell(Spell: TSpell): Boolean; { 5577CFF0 }
    procedure ListResearchSpells(var List: TSpellList; SpellTypes: TSpellTypes);
    procedure ListSpells(var List: TSpellList; SpellTypes: TSpellTypes);
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure Update;
    procedure ValidateEnchantmentID(Enchantment: TEnchantment); { 5577D2A8 }
    function RegisterEnchantment(Enchantment: TEnchantment): Boolean;
    function UnregisterEnchantment(Enchantment: TEnchantment): Boolean;
    function RegisterPowerSource(Source: TPowerSource): Boolean;
    function UnregisterPowerSource(Source: TPowerSource): Boolean;
    function CreateChangeMagicTE: TChangePlayerMagicTE;
    function ExecuteDispelEnchantment(Index: Integer): Boolean;
    function DispelEnchantment(Enchantment: TEnchantment): Boolean;
    function ExecuteChangePowerSettings(Percentage: Integer): Boolean;
    function ChangePowerSettings(Percentage: Integer): Boolean;
    function ExecuteResearchSpell(SpellID: Integer): Boolean;
    function ResearchSpell(SpellID: Integer): Boolean;
    function AIRequestOverrideUpkeep(Priority: Integer): Integer;
    function AIOverrideUpkeep(Priority, Amount: Integer): Integer;
  end;

  { TGlobalEnchantment (instance size 36, VMT 5570B398; $08 ID, $0C references,
    $10 status, $11 mode, $14 dispel mana, $18 type, $19 player, $1C name, $20 upkeep) }
  TGlobalEnchantment = class(TEObject)
  public
    FEnchantmentID: Integer; { $08 }
    FRefCount: Integer; { $0C }
    FEnchantmentStatus: TGlobalEnchantmentStatus; { $10 }
    FEnchantmentMode: TGlobalEnchantmentMode; { $11 }
    F_GlobalEnchantment_12: array[0..1] of Byte;
    FDispelMana: Integer; { $14; 557EB619 }
    FEnchantmentType: TGlobalEnchantmentType; { $18 }
    FPlayerIndex: Shortint; { $19 }
    { conflict: FEnchantmentPlayer: Shortint; }
    F_GlobalEnchantment_1A: array[0..1] of Byte;
    FName: string; { $1C; 557EFCFF }
    FEnchantmentManaUpkeep: Integer; { $20 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetName: string; virtual;  { +04C }
    function GetUpkeep: Integer; virtual; { +050 }
    function GetLocation: TXYL; virtual;  { +054 }
    function GetAIUpkeepPriority: Integer; virtual;  { +058 }
    function CanDeactivate(Player: Byte; var Reason: string): Boolean; virtual; { +05C }
    function Deactivate(Player: Byte): Boolean; virtual;  { +060 }
    function CanActivate(Player: Shortint; var Reason: string): Boolean; virtual; { +064 }
    function Activate(Player: Shortint): Boolean; virtual;
    function CanCast(Player: Shortint; var Reason: string): Boolean; virtual; { +06C }
    function Cast(Player: Shortint): Boolean; virtual; { +070 }
    function CanDispel(Player: Shortint; var Reason: string): Boolean; virtual; { +074; 557EBE5C }
    function Dispel(Player: Byte): Boolean; virtual; { +078; 5577DDA4 }
    function CanRemove(Player: Shortint; var Reason: string): Boolean; virtual; { +07C; 5577DF28 }
    function Remove(Player: Byte): Boolean; virtual; { +080; 5577DF44 }
    function VisibleForPlayer(Player: Shortint): Boolean; virtual;  { +084 }
    procedure CenterToLocation; virtual; { +088; 5577D970 }
    procedure Setup(Kind: TGlobalEnchantmentType; Name: string; Upkeep: Integer); { 5577DA8C }
  end;

  { TGlobalEnchantmentEventLog (instance size 36, VMT 5570B4B8; $20 enchantment player) }
  TGlobalEnchantmentEventLog = class(TLocationTextEventLog)
  public
    FEnchantmentPlayer: Shortint; { $20 }
    F_GlobalEnchantmentEventLog_21: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetLeftIcon: Integer; override;
  end;

  { TGlobalEnchantmentList (instance size 12, VMT 5570B5C0) }
  TGlobalEnchantmentList = class(TENode)
  public
    function GetEnchantments(A1: Integer): TGlobalEnchantment;
  end;

  { TChangeGlobalMagicTE (instance size 28, VMT 5570B724):
    $10 mode, $11 player, $14 enchantment ID, $18 value. }
  TChangeGlobalMagicTE = class(TTokenEvent)
  public
    FMode: TChangeGlobalMagicMode; { $10 }
    FPlayerIndex: Byte; { $11 }
    F_ChangeGlobalMagicTE_12: array[0..1] of Byte;
    FEnchantmentID: Integer; { $14 }
    FValue: Integer; { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TGlobalMagicControl: size $40, VMT 5570B7F8; $08 next ID, $0C update count, $10 active types, $14 enchantments, $18..38 double-mana counters, $3C changed events. }
  TGlobalMagicControl = class(TEObject)
  public
    FNextEnchantmentID: Integer; { $08 }
    FUpdateCount: Integer; { $0C }
    FActiveEnchantments: TGlobalEnchantmentTypes; { $10 }
    F_GlobalMagicControl_11: array[0..2] of Byte;
    FEnchantments: TGlobalEnchantmentList; { $14 }
    FDoubleSphereManaCount: array[TMagicSphere] of Integer; { $18 }
    FChangedEvents: TEventList; { $3C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure IncDoubleSphereManaCount(A1: TMagicSphere);
    procedure DecDoubleSphereManaCount(A1: TMagicSphere);
    function GetSphereManaDoubled(A1: TMagicSphere): Boolean;
    procedure OutOfMana(Player: Shortint; Mana: Integer);
    procedure RemovePlayerEnchantments(Player: Shortint);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure TriggerChangedEvent;
    procedure Update;
    function GetEnchantmentUpkeep(Player: Shortint): Integer; { 5577C9A0 }
    procedure UpdateActiveEnchantments;
    function IndexOfID(A1: Integer): Integer;
    function ValidateEnchantmentID(Enchantment: TGlobalEnchantment): Boolean; { 5577E4EC }
    function CreateChangeMagicTE: TChangeGlobalMagicTE;
    function ExecuteDispelEnchantment(Player: Shortint; EnchantmentID: Integer): Boolean;
    function DispelEnchantment(Player: Shortint; Enchantment: TGlobalEnchantment): Boolean;
    function ExecuteRemoveEnchantment(Player: Shortint; EnchantmentID: Integer): Boolean;
    function RemoveEnchantment(Player: Shortint; Enchantment: TGlobalEnchantment): Boolean;
  end;

