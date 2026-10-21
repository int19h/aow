{ Interface declaration run owned by P1. }
  { TAbilityData (instance size $0C, +$08 FNext, VMT 5570F05C) }
  TAbilityData = class(TEObject)
  public
    FNext: TAbilityData;  { $08 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    function GetAbilityID: Integer; virtual;
  end;

  { TActivateAbilityInfo (instance size 28, VMT 5570F120) }
  TActivateAbilityInfo = class(TEObject)
  public
    FReferences: Integer;  { $08 }
    FUnitID: Integer;  { $0C }
    FAbilityID: Integer;  { $10 }
    F_ActivateAbilityInfo_14: array[0..7] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
  end;

  { TAbility: size $24; $08 name, $0C ID, $10 description, $14 cost,
    $18 SFX library, $1C image sequences, $20 selection types.
    Procedure return-ABI adapters preserve unmarked overrides in other packages. }
  TAbility = class(TEObject)
  public
    FAbilityName: string;  { $08 }
    FAbilityID: Integer;  { $0C }
    FDescription: TStringList;  { $10 }
    FSkillPointCost: Integer;  { $14 }
    FSFXLibrary: TSFXLibrary;  { $18 }
    FImageSequences: TImageSequenceList;  { $1C }
    FSelectionTypes: TAbilitySelectionTypes;  { $20 }
    F_Ability_22: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Execute; virtual;  { +04C draft }
    procedure GetHidden; virtual;  { +050 draft }
    function GetAbilityType: TAbilityType; virtual;
    function GetName(A1: TAbilityOwner): string; virtual;
    function GetAttack(A1: TAbilityOwner): Shortint; virtual;
    function GetDefense(A1: TAbilityOwner): Shortint; virtual;
    function GetResistance(A1: TAbilityOwner): Shortint; virtual;  { +064 }
    function GetDamage(A1: TAbilityOwner): Shortint; virtual;  { +068 }
    function GetMoveTypes(A1: TAbilityOwner): TMoveTypes; virtual;  { +06C }
    function GetLevel(A1: TAbilityOwner): Integer; virtual;
    function GetEnabled(A1: TAbilityOwner): Boolean; virtual;  { +074 }
    function GetImmunityTypes(A1: TAbilityOwner): TDamageTypes; virtual;  { +078 }
    function GetProtectionTypes(A1: TAbilityOwner): TDamageTypes; virtual;  { +07C }
    function GetSkillPoints(A1: TAbilityOwner): Integer; virtual; { +080 }
    function GetCombatMode(A1: TAbilityOwner): TCombatMode; virtual;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; virtual;  { +088 }
    function GetSourceName(A1: TAbilityOwner): string; virtual;
    function GetInherent(A1: TAbilityOwner): Boolean; virtual;
    function GetInherentLevel(Owner: TAbilityOwner): Integer; virtual; { $094; AoW 0044719D }
    function GetControlType(Owner: TAbilityOwner): TAbilityControlType; virtual;
    function fcValidRoundDistance(A1, A2: TCombatObject): Boolean; virtual;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); virtual;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; virtual;
    procedure NewDay(A1: TAbilityOwner); virtual;  { +0A8 }
    procedure NewTurn(A1: TAbilityOwner; A2: Shortint); virtual;
    function CanActivate(A1: TAbilityOwner; var A2: string): Boolean; virtual; { +0B0 }
    function Activate(A1: TAbilityOwner; var A2: string): Boolean; virtual; { +0B4 }
    function CanActivateCombat(A1: TAbilityOwner; var A2: string): Boolean; virtual; { +0B8; 5574EFDC }
    function ActivateCombat(Owner: TAbilityOwner; var Reason: string): Boolean; virtual;
    procedure ListSpells; virtual;  { +0C0 draft }
    function CanExpand(A1: TAbilityOwner): Boolean; virtual;
    function ExpandCost(A1: TAbilityOwner): Integer; virtual; { +0C8 }
    function ExpandName(A1: TAbilityOwner): string; virtual; { +0CC }
    function Expand(A1: TAbilityOwner): Boolean; virtual;
    function Remove(A1: TAbilityOwner): Boolean; virtual;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; virtual;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); virtual;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); virtual;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); virtual;
    function fcGetDamageValue(Source, Target: TCombatObject; Defensive: Boolean): Integer; virtual;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); virtual; { +0EC }
    function tcGetDamageValue(Source, Target: TCombatObject): Integer; virtual;
    procedure CombatObjectDestroyed(A1: TCombatObject); virtual;  { +0F4 }
    procedure NewCombatTurn(A1: TCombatObject; A2: Shortint); virtual;
    procedure CombatDone(A1: TCombatObject); virtual;
    procedure ListInfo(A1: TStrings; A2: TAbilityInfoMode); virtual;  { +100 }
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); virtual;
    function AbilityDataClass: TEObjectClass; virtual;
    procedure ShowInfo(Owner: TAbilityOwner; Font: TImageLibraryFont; X, Y: Integer; const Surface: TSurfaceDesc);
    procedure SetAb(Owner: TAbilityOwner; Index: Integer; Value: Byte);
  end;

  { TCustomAbilityList: size $10; $08 ability-bit buffer, $0C bit count. }
  TCustomAbilityList = class(TEObject)
  public
    FAbilityBits: Pointer;  { $08 }
    FAbilityCount: Integer;  { $0C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
    function GetAbSet(A1: Integer): Boolean; virtual;
    procedure SetAbSet(Index: Integer; Value: Byte); virtual;
    function GetAbCount: Integer; virtual;
    procedure ListAbilitiesEx(A1: TStrings; A2: TAbilitySelectionTypes); virtual;  { +058 draft }
    procedure SetAbCount(Value: Integer);
    procedure AssignAb(Source: TCustomAbilityList);
    function CompareAb(Source: TCustomAbilityList): Boolean;
    function ComposeAb(Source: TCustomAbilityList): Boolean;
    function GetItemString: string;
    procedure SetItemString(S: string);
  end;

  { TAbilityList (instance size 16, VMT 5570F4B8) }
  TAbilityList = class(TCustomAbilityList)
  public
  end;

  { TAbilityOwner (instance size $14, +$10 FAbilityData, VMT 5570F588) }
  TAbilityOwner = class(TCustomAbilityList)
  public
    FAbilityData: TAbilityData;  { $10 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure SetAbSet(A1: Integer; A2: Byte); override;
    procedure ListAbilitiesEx(A1: TStrings; A2: TAbilitySelectionTypes); override;
    function Execute: Integer; virtual;  { +05C }
    function GetOwnerName: string; virtual;  { +060 }
    function GetAbName(AbilityID: Integer): string; virtual;  { +064 }
    function GetAbAttack(AbilityID: Integer): Shortint; virtual;  { +068 }
    function GetAbDefense(AbilityID: Integer): Shortint; virtual;  { +06C }
    function GetAbResistance(AbilityID: Integer): Shortint; virtual;  { +070 }
    function GetAbDamage(AbilityID: Integer): Shortint; virtual;  { +074 }
    function GetAbMoveTypes(AbilityID: Integer): TMoveTypes; virtual;  { +078 }
    function GetAbProtectionTypes(AbilityID: Integer): TDamageTypes; virtual;  { +07C }
    function GetAbImmunityTypes(AbilityID: Integer): TDamageTypes; virtual;  { +080 }
    function GetAbLevel(AbilityID: Integer): Integer; virtual;  { +084 }
    function GetAbEnabled(AbilityID: Integer): Boolean; virtual;  { +088 }
    function GetAbilitySelectionTypes: TAbilitySelectionTypes; virtual;  { +08C }
    procedure Changed; virtual;  { +090 }
    function ExpandAbility(AbilityID: Integer): Boolean; virtual;
    function RemoveAbility(A1: Integer): Boolean; virtual;  { +098 }
    procedure ValidateOwnerTypeAbilities;
    function GetAbilityData(AbilityID: Integer): TAbilityData;
    procedure AssignAb(Source: TAbilityOwner);
    procedure AddAbilityData(Data: TAbilityData);
    procedure RemoveAbilityData(Data: TAbilityData);
    procedure RemoveAbilityDataID(AbilityID: Integer);
    procedure UpdateDefaultAbilities(Source: TAbilityOwner);
    { conflict: procedure UpdateDefaultAbilities(A1: TCustomAbilityList); }
    function GetAbAttackAll: Shortint;
    function GetAbDefenseAll: Shortint;
    function GetAbResistanceAll: Shortint;
    function GetAbDamageAll: Shortint;
    function GetAbMoveTypesAll: TMoveTypes;
    function GetAbWallCombatFeatures: TWallCombatFeatures;
    function GetAbProtectionTypesAll: TDamageTypes;
    function GetAbImmunityTypesAll: TDamageTypes;
    procedure TriggerNewDay;
    procedure TriggerNewTurn(Player: Shortint);
    procedure TriggerNewCombatTurn(Combat: TCombatObject; Player: Shortint);
    procedure TriggerCombatDone(Combat: TCombatObject);
    procedure ListAbilities(Text: TStrings);
  end;

  { TAbilityTypeList (instance size 16, VMT 5570F698) }
  TAbilityTypeList = class(TList)
  public
    function GetAbility(A1: Integer): TAbility;
  end;

  { TAbilityControl (instance size $20, +$08 FAbilities, +$0C..$1C FAbilitiesByType, VMT 5570F71C) }
  TAbilityControl = class(TEObject)
  public
    FAbilities: TList;  { $08 }
    FAbilitiesByType: array[TAbilityType] of TAbilityTypeList;  { $0C..$1C }
    { conflict: FCombatAbilities: TAbilityTypeList; }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCount: Integer;
    function GetAbility(Index: Integer): TAbility;
    procedure RegisterAbility(Ability: TAbility);
    procedure UnregisterAbility(Ability: TAbility);
    procedure UnregisterAll;
    procedure UnregisterAbilityID(ID: Integer);
    procedure ListAbilities(Text: TStrings; Types: TAbilitySelectionTypes);
    procedure ListAbilityInfo(Text: TStrings; SortByName: Boolean; Mode: TAbilityInfoMode);
  end;

