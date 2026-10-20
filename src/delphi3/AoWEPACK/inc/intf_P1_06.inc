{ Interface declaration run owned by P1. }
  { TAbilityData (instance size 12, VMT 5570F05C) }
  TAbilityData = class(TEObject)
  public
    F_AbilityData_08: array[0..3] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure GetAbilityID; virtual;  { +04C draft }
  end;

  { TActivateAbilityInfo (instance size 28, VMT 5570F120) }
  TActivateAbilityInfo = class(TEObject)
  public
    F_ActivateAbilityInfo_08: Integer;
    F_ActivateAbilityInfo_0C: Integer;
    F_ActivateAbilityInfo_10: Integer;
    F_ActivateAbilityInfo_14: array[0..7] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
  end;

  { TAbility (instance size 36, VMT 5570F254) }
  TAbility = class(TEObject)
  public
    F_Ability_08: Integer;
    F_Ability_0C: Integer;
    F_Ability_10: Integer;
    F_Ability_14: Integer;
    F_Ability_18: Integer;
    F_Ability_1C: Integer;
    F_Ability_20: Word;
    F_Ability_22: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Execute; virtual;  { +04C draft }
    procedure GetHidden; virtual;  { +050 draft }
    procedure GetAbilityType; virtual;  { +054 draft }
    procedure GetName(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure GetAttack; virtual;  { +05C draft }
    procedure GetDefense; virtual;  { +060 draft }
    procedure GetResistance; virtual;  { +064 draft }
    procedure GetDamage; virtual;  { +068 draft }
    procedure GetMoveTypes; virtual;  { +06C draft }
    procedure GetLevel(A1: Integer); virtual;  { +070 draft }
    procedure GetEnabled(A1: Integer); virtual;  { +074 draft }
    procedure GetImmunityTypes; virtual;  { +078 draft }
    procedure GetProtectionTypes; virtual;  { +07C draft }
    procedure GetSkillPoints(A1: Integer); virtual;  { +080 draft }
    procedure GetCombatMode(A1: Integer); virtual;  { +084 draft }
    procedure GetWallCombatFeatures(A1: Integer); virtual;  { +088 draft }
    procedure GetSourceName(A1: Integer; A2: Integer); virtual;  { +08C draft }
    procedure GetInherent(A1: Integer); virtual;  { +090 draft }
    procedure GetInherentLevel(A1: Integer); virtual;  { +094 draft }
    procedure GetControlType; virtual;  { +098 draft }
    procedure fcValidRoundDistance(A1: Integer; A2: Integer); virtual;  { +09C draft }
    procedure fcPrefetchCombatCommands(A1: Integer); virtual;  { +0A0 draft }
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); virtual;  { +0A4 draft }
    procedure NewDay(A1: Integer); virtual;  { +0A8 draft }
    procedure NewTurn(A1: Integer; A2: Integer); virtual;  { +0AC draft }
    procedure CanActivate(A1: Integer; A2: Integer); virtual;  { +0B0 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +0B4 draft }
    procedure CanActivateCombat(A1: Integer; A2: Integer); virtual;  { +0B8 draft }
    procedure ActivateCombat(A1: Integer; A2: Integer); virtual;  { +0BC draft }
    procedure ListSpells; virtual;  { +0C0 draft }
    procedure CanExpand(A1: Integer); virtual;  { +0C4 draft }
    procedure ExpandCost; virtual;  { +0C8 draft }
    procedure ExpandName(A1: Integer; A2: Integer); virtual;  { +0CC draft }
    procedure Expand(A1: Integer; A2: Integer); virtual;  { +0D0 draft }
    procedure Remove(A1: Integer; A2: Integer); virtual;  { +0D4 draft }
    procedure GetDamageValue(A1: Integer; A2: Integer); virtual;  { +0D8 draft }
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0DC draft }
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0E0 draft }
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0E4 draft }
    procedure fcGetDamageValue(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0E8 draft }
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0EC draft }
    procedure tcGetDamageValue(A1: Integer); virtual;  { +0F0 draft }
    procedure CombatObjectDestroyed(A1: Integer); virtual;  { +0F4 draft }
    procedure NewCombatTurn(A1: Integer; A2: Integer); virtual;  { +0F8 draft }
    procedure CombatDone(A1: Integer); virtual;  { +0FC draft }
    procedure ListInfo(A1: Integer; A2: Byte); virtual;  { +100 draft }
    procedure GetCombatInfo(A1: Integer; A2: Integer); virtual;  { +104 draft }
    procedure AbilityDataClass; virtual;  { +108 draft }
    procedure ShowInfo(A1: Integer; A2: Integer);  { draft }
    procedure SetAb(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TCustomAbilityList (instance size 16, VMT 5570F3DC) }
  TCustomAbilityList = class(TEObject)
  public
    F_CustomAbilityList_08: Byte;
    F_CustomAbilityList_09: array[0..2] of Byte;
    F_CustomAbilityList_0C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
    procedure GetAbSet(A1: Integer); virtual;  { +04C draft }
    procedure SetAbSet(A1: Integer; A2: Byte); virtual;  { +050 draft }
    procedure GetAbCount; virtual;  { +054 draft }
    procedure ListAbilitiesEx(A1: Integer; A2: Word); virtual;  { +058 draft }
    procedure SetAbCount(A1: Integer);  { draft }
    procedure AssignAb(A1: Integer; A2: Integer);  { draft }
    procedure CompareAb(A1: Integer);  { draft }
    procedure ComposeAb(A1: Integer);  { draft }
    procedure GetItemString(A1: Integer);  { draft }
    procedure SetItemString(A1: Integer);  { draft }
  end;

  { TAbilityList (instance size 16, VMT 5570F4B8) }
  TAbilityList = class(TCustomAbilityList)
  public
  end;

  { TAbilityOwner (instance size 20, VMT 5570F588) }
  TAbilityOwner = class(TCustomAbilityList)
  public
    F_AbilityOwner_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure SetAbSet(A1: Integer; A2: Byte); override;
    procedure ListAbilitiesEx(A1: Integer; A2: Word); override;
    procedure Execute; virtual;  { +05C draft }
    procedure GetOwnerName(A1: Integer); virtual;  { +060 draft }
    procedure GetAbName(A1: Integer; A2: Integer); virtual;  { +064 draft }
    procedure GetAbAttack(A1: Integer); virtual;  { +068 draft }
    procedure GetAbDefense(A1: Integer); virtual;  { +06C draft }
    procedure GetAbResistance(A1: Integer); virtual;  { +070 draft }
    procedure GetAbDamage(A1: Integer); virtual;  { +074 draft }
    procedure GetAbMoveTypes(A1: Integer); virtual;  { +078 draft }
    procedure GetAbProtectionTypes(A1: Integer); virtual;  { +07C draft }
    procedure GetAbImmunityTypes(A1: Integer); virtual;  { +080 draft }
    procedure GetAbLevel(A1: Integer); virtual;  { +084 draft }
    procedure GetAbEnabled(A1: Integer); virtual;  { +088 draft }
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); virtual;  { +08C draft }
    procedure Changed; virtual;  { +090 draft }
    procedure ExpandAbility(A1: Integer); virtual;  { +094 draft }
    procedure RemoveAbility(A1: Integer); virtual;  { +098 draft }
    procedure ValidateOwnerTypeAbilities;  { draft }
    procedure GetAbilityData(A1: Integer);  { draft }
    procedure AssignAb(A1: Integer);  { draft }
    procedure AddAbilityData(A1: Integer);  { draft }
    procedure RemoveAbilityData(A1: Integer);  { draft }
    procedure RemoveAbilityDataID(A1: Integer);  { draft }
    procedure UpdateDefaultAbilities(A1: Integer);  { draft }
    procedure GetAbAttackAll;  { draft }
    procedure GetAbDefenseAll;  { draft }
    procedure GetAbResistanceAll;  { draft }
    procedure GetAbDamageAll;  { draft }
    procedure GetAbMoveTypesAll;  { draft }
    procedure GetAbWallCombatFeatures;  { draft }
    procedure GetAbProtectionTypesAll;  { draft }
    procedure GetAbImmunityTypesAll;  { draft }
    procedure TriggerNewDay;  { draft }
    procedure TriggerNewTurn(A1: Byte; A2: Integer);  { draft }
    procedure TriggerNewCombatTurn(A1: Integer; A2: Byte);  { draft }
    procedure TriggerCombatDone(A1: Integer);  { draft }
    procedure ListAbilities(A1: Integer);  { draft }
  end;

  { TAbilityTypeList (instance size 16, VMT 5570F698) }
  TAbilityTypeList = class(TList)
  public
    procedure GetAbility(A1: Integer);  { draft }
  end;

  { TAbilityControl (instance size 32, VMT 5570F71C) }
  TAbilityControl = class(TEObject)
  public
    F_AbilityControl_08: Integer;
    F_AbilityControl_0C: Byte;
    F_AbilityControl_0D: array[0..18] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    function GetAbility(A1: Integer): TAbility;
    procedure RegisterAbility(A1: Integer);  { draft }
    procedure UnregisterAbility(A1: Integer);  { draft }
    procedure UnregisterAll;  { draft }
    procedure UnregisterAbilityID(A1: Integer);  { draft }
    procedure ListAbilities(A1: Integer; A2: Word);  { draft }
    procedure ListAbilityInfo(A1: Integer; A2: Byte; A3: Integer);  { draft }
  end;

