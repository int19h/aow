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
  { TEnchantment (instance size 24, VMT 5570A98C; $08 ID, $0C source, $14 dispel resistance) }
  TEnchantment = class(TEObject)
  public
    FEnchantmentID: Integer; { $08 }
    FSource: Shortint;  { $0C }
    F_Enchantment_0D: array[0..2] of Byte;
    F_Enchantment_10: Integer;
    FDispelResistance: Byte;  { $14 }
    F_Enchantment_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName: string; virtual;
    function GetBinding: string; virtual;
    procedure SetUpkeep(A1: Integer); virtual;
    procedure SetSource(Player: Shortint); virtual;
    function GetAIUpkeepPriority: Integer; virtual;
    procedure GetLocation(var A1, A2, A3: Shortint); virtual;
    procedure CenterToLocation; virtual;  { +064 draft }
    function Dispel: Boolean; virtual;
    procedure Select; virtual;  { +06C draft }
    function DispelChance(A1: Integer): Integer;
  end;

  { TEnchantmentList (instance size 12, VMT 5570AA70) }
  TEnchantmentList = class(TENode)
  public
    function GetEnchantments(A1: Integer): TEnchantment;
    procedure IndexOfID(A1: Integer);  { draft }
    function FindID(A1: Integer): TEnchantment;
  end;

  { TChangePlayerMagicTE (instance size 28, VMT 5570ABDC) }
  TChangePlayerMagicTE = class(TTokenEvent)
  public
    F_ChangePlayerMagicTE_10: Byte;
    F_ChangePlayerMagicTE_11: Byte;
    F_ChangePlayerMagicTE_12: array[0..1] of Byte;
    F_ChangePlayerMagicTE_14: Integer;
    F_ChangePlayerMagicTE_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TPlayerMagicEventLog (instance size 44, VMT 5570AD0C) }
  TPlayerMagicEventLog = class(TEventLog)
  public
    FMode: Byte; { $18 }
    F_PlayerMagicEventLog_19: array[0..2] of Byte;
    F_PlayerMagicEventLog_1C: Integer;
    F_PlayerMagicEventLog_20: Integer;
    F_PlayerMagicEventLog_24: Integer;
    F_PlayerMagicEventLog_28: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
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
    FExternalPowerControl: Integer;
    function Name: string; override;
    function Power: Integer; override;
  end;

  { TPowerSourceList (instance size 12, VMT 5570AFD0) }
  TPowerSourceList = class(TENode)
  public
    procedure GetItems(A1: Integer);  { draft }
  end;

  { TPlayerMagicControl (instance size 76, VMT 5570B198) }
  TPlayerMagicControl = class(TEObject)
  public
    F_PlayerMagicControl_08: Integer;
    F_PlayerMagicControl_0C: Byte;
    F_PlayerMagicControl_0D: array[0..2] of Byte;
    FPlayer: TPlayer; { $10 }
    F_PlayerMagicControl_14: Integer;
    F_PlayerMagicControl_18: Integer;
    F_PlayerMagicControl_1C: Integer;
    F_PlayerMagicControl_20: Integer;
    FMana: Integer; { $24 }
    F_PlayerMagicControl_28: Word;
    F_PlayerMagicControl_2A: array[0..1] of Byte;
    FResearchPercentage: Integer; { $2C }
    FSpells: TIntegerList; { $30 }
    FResearchSpellID: Integer; { $34 }
    FResearchPointsLeft: Integer; { $38 }
    F_PlayerMagicControl_3C: Integer;
    F_PlayerMagicControl_40: Integer;
    F_PlayerMagicControl_44: Byte;
    FEnemyEnchantments: Byte; { $45 }
    { conflict: FGlobalEnchantmentFlags: Byte; }
    F_PlayerMagicControl_46: array[0..1] of Byte;
    F_PlayerMagicControl_48: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCheatEnabled: Boolean;
    procedure SetActiveEnchantments(A1: Byte; A2: Integer);  { draft }
    procedure UpdateEnemyEnchantments;
    procedure GetManaIncome;  { draft }
    procedure GetManaUpkeep;  { draft }
    procedure SetMana(A1: Integer);
    procedure GetPower;  { draft }
    procedure OutOfMana(A1: Integer);  { draft }
    procedure RemoveEnchantments;  { draft }
    procedure ValidateEnchantmentsUpkeep;  { draft }
    procedure ExecuteSpellResearched(A1: Integer);  { draft }
    procedure NewTurn;  { draft }
    procedure SetSpheres(A1: Word; A2: Integer);  { draft }
    procedure GetNetPower;  { draft }
    procedure GetNetPowerToMana(A1: Integer; A2: Integer);  { draft }
    procedure GetNetPowerToResearch(A1: Integer; A2: Integer);  { draft }
    procedure ResearchTurns(A1: Integer; A2: Integer);  { draft }
    procedure GetResearchTurnsLeft;  { draft }
    procedure ValidResearchSpell(A1: Integer);  { draft }
    procedure ListResearchSpells(var List: TSpellList; SpellTypes: TSpellTypes);
    procedure ListSpells(var List: TSpellList; SpellTypes: TSpellTypes);
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure Update;
    procedure ValidateEnchantmentID(A1: Integer);  { draft }
    procedure RegisterEnchantment(Enchantment: TEnchantment);
    procedure UnregisterEnchantment(Enchantment: TEnchantment);
    procedure RegisterPowerSource(Source: TPowerSource);
    procedure UnregisterPowerSource(Source: TPowerSource);
    procedure CreateChangeMagicTE;  { draft }
    procedure ExecuteDispelEnchantment(A1: Integer);  { draft }
    procedure DispelEnchantment;  { draft }
    procedure ExecuteChangePowerSettings(A1: Integer);  { draft }
    procedure ChangePowerSettings(A1: Integer);  { draft }
    procedure ExecuteResearchSpell(A1: Integer);  { draft }
    procedure ResearchSpell(A1: Integer);  { draft }
    procedure AIRequestOverrideUpkeep(A1: Integer; A2: Integer);  { draft }
    procedure AIOverrideUpkeep(A1: Integer; A2: Integer);  { draft }
  end;

  { TGlobalEnchantment (instance size 36, VMT 5570B398) }
  TGlobalEnchantment = class(TEObject)
  public
    F_GlobalEnchantment_08: Integer;
    F_GlobalEnchantment_0C: Integer;
    F_GlobalEnchantment_10: Byte;
    F_GlobalEnchantment_11: Byte;
    F_GlobalEnchantment_12: array[0..1] of Byte;
    FEnchantmentSpellID: Integer; { $14 }
    F_GlobalEnchantment_18: Byte;
    FPlayerIndex: Byte; { $19 }
    { conflict: FEnchantmentPlayer: Shortint; }
    F_GlobalEnchantment_1A: array[0..1] of Byte;
    F_GlobalEnchantment_1C: Integer;
    FEnchantmentManaUpkeep: Integer; { $20 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure GetName(A1: Integer); virtual;  { +04C draft }
    procedure GetUpkeep; virtual;  { +050 draft }
    procedure GetLocation(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure GetAIUpkeepPriority; virtual;  { +058 draft }
    procedure CanDeactivate(A1: Integer; A2: Integer); virtual;  { +05C draft }
    procedure Deactivate(A1: Byte); virtual;  { +060 draft }
    procedure CanActivate(A1: Integer; A2: Integer); virtual;  { +064 draft }
    procedure Activate(A1: Byte); virtual;
    procedure CanCast; virtual;  { +06C draft }
    procedure Cast(A1: Integer); virtual;  { +070 draft }
    procedure CanDispel; virtual;  { +074 draft }
    procedure Dispel(A1: Byte); virtual;  { +078 draft }
    procedure CanRemove(A1: Byte; A2: Integer); virtual;  { +07C draft }
    procedure Remove(A1: Byte); virtual;  { +080 draft }
    procedure VisibleForPlayer(A1: Integer; A2: Integer); virtual;  { +084 draft }
    procedure CenterToLocation(A1: Integer; A2: Integer); virtual;  { +088 draft }
    procedure Setup(A1: Integer; A2: Integer);  { draft }
  end;

  { TGlobalEnchantmentEventLog (instance size 36, VMT 5570B4B8) }
  TGlobalEnchantmentEventLog = class(TLocationTextEventLog)
  public
    F_GlobalEnchantmentEventLog_20: Byte;
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

  { TChangeGlobalMagicTE (instance size 28, VMT 5570B724) }
  TChangeGlobalMagicTE = class(TTokenEvent)
  public
    F_ChangeGlobalMagicTE_10: Byte;
    F_ChangeGlobalMagicTE_11: Byte;
    F_ChangeGlobalMagicTE_12: array[0..1] of Byte;
    F_ChangeGlobalMagicTE_14: Integer;
    F_ChangeGlobalMagicTE_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TGlobalMagicControl (instance size 64, VMT 5570B7F8) }
  TGlobalMagicControl = class(TEObject)
  public
    F_GlobalMagicControl_08: Integer;
    F_GlobalMagicControl_0C: Integer;
    FActiveEnchantments: TGlobalEnchantmentTypes; { $10 }
    F_GlobalMagicControl_11: array[0..2] of Byte;
    F_GlobalMagicControl_14: Integer;
    F_GlobalMagicControl_18: Byte;
    F_GlobalMagicControl_19: array[0..34] of Byte;
    F_GlobalMagicControl_3C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure IncDoubleSphereManaCount(A1: Integer);  { draft }
    procedure DecDoubleSphereManaCount(A1: Integer);  { draft }
    function GetSphereManaDoubled(A1: TMagicSphere): Boolean;
    procedure OutOfMana(A1: Byte; A2: Integer);  { draft }
    procedure RemovePlayerEnchantments(Player: Shortint);
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure TriggerChangedEvent;  { draft }
    procedure Update;  { draft }
    procedure GetEnchantmentUpkeep(A1: Integer);  { draft }
    procedure UpdateActiveEnchantments(A1: Integer; A2: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure ValidateEnchantmentID(A1: Integer);  { draft }
    procedure CreateChangeMagicTE;  { draft }
    procedure ExecuteDispelEnchantment(A1: Integer; A2: Integer);  { draft }
    procedure DispelEnchantment(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteRemoveEnchantment(A1: Integer; A2: Integer);  { draft }
    procedure RemoveEnchantment(A1: Integer; A2: Integer);  { draft }
  end;

