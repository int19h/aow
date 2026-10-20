{ P3 combat implementation. Recovered methods precede the remaining drafts.
  TCombatUnit.Setup retains an ABI view for the one-argument SetCombatPlayer;
  its P5 override must be fixed before the shared declaration can be corrected.
  The two damage-effects entry-point casts preserve the original result while
  P2 still declares those functions as procedures. }
type
  { needs: P2 nonvirtual damage-effects routines return TDamageTypes. The typed
    entry-point casts preserve the register ABI until the declarations are fixed. }
  TP3ExecuteCombatDamageEffects = function(U: TAbstractUnit; Combat: Integer;
    Effects: TDamageTypes): TDamageTypes;
  TP3ExecuteDamageEffectsRole = function(U: TAbstractUnit; Effects: TDamageTypes): TDamageTypes;
  { ABI view only; never instantiated. needs: P2 TAbstractUnit's two
    procedure drafts at +$144/+$148 are Integer/Boolean getters. }
  TP3AbstractUnitAccess = class(TAbilityOwner)
  public
    procedure Slot09C; virtual; abstract; { +$09C }
    procedure Slot0A0; virtual; abstract; { +$0A0 }
    procedure Slot0A4; virtual; abstract; { +$0A4 }
    procedure Slot0A8; virtual; abstract; { +$0A8 }
    procedure Slot0AC; virtual; abstract; { +$0AC }
    procedure Slot0B0; virtual; abstract; { +$0B0 }
    procedure Slot0B4; virtual; abstract; { +$0B4 }
    procedure Slot0B8; virtual; abstract; { +$0B8 }
    procedure Slot0BC; virtual; abstract; { +$0BC }
    procedure Slot0C0; virtual; abstract; { +$0C0 }
    procedure Slot0C4; virtual; abstract; { +$0C4 }
    procedure Slot0C8; virtual; abstract; { +$0C8 }
    procedure Slot0CC; virtual; abstract; { +$0CC }
    procedure Slot0D0; virtual; abstract; { +$0D0 }
    procedure Slot0D4; virtual; abstract; { +$0D4 }
    procedure Slot0D8; virtual; abstract; { +$0D8 }
    procedure Slot0DC; virtual; abstract; { +$0DC }
    procedure Slot0E0; virtual; abstract; { +$0E0 }
    procedure Slot0E4; virtual; abstract; { +$0E4 }
    procedure Slot0E8; virtual; abstract; { +$0E8 }
    procedure Slot0EC; virtual; abstract; { +$0EC }
    procedure Slot0F0; virtual; abstract; { +$0F0 }
    procedure Slot0F4; virtual; abstract; { +$0F4 }
    procedure Slot0F8; virtual; abstract; { +$0F8 }
    procedure Slot0FC; virtual; abstract; { +$0FC }
    procedure Slot100; virtual; abstract; { +$100 }
    procedure Slot104; virtual; abstract; { +$104 }
    procedure Slot108; virtual; abstract; { +$108 }
    procedure Slot10C; virtual; abstract; { +$10C }
    procedure Slot110; virtual; abstract; { +$110 }
    procedure Slot114; virtual; abstract; { +$114 }
    procedure Slot118; virtual; abstract; { +$118 }
    procedure Slot11C; virtual; abstract; { +$11C }
    procedure Slot120; virtual; abstract; { +$120 }
    procedure Slot124; virtual; abstract; { +$124 }
    procedure Slot128; virtual; abstract; { +$128 }
    procedure Slot12C; virtual; abstract; { +$12C }
    procedure Slot130; virtual; abstract; { +$130 }
    procedure Slot134; virtual; abstract; { +$134 }
    procedure Slot138; virtual; abstract; { +$138 }
    procedure Slot13C; virtual; abstract; { +$13C }
    procedure Slot140; virtual; abstract; { +$140 }
    function GetAbilityLevel(Ability: Integer): Integer; virtual; abstract;
    function GetAbilityEnabled(Ability: Integer): Boolean; virtual; abstract;
  end;
  { needs: P3 TCombatObject.SetCombatPlayer takes one Byte; changing its
    declaration also requires P5 TFastCombatUnit's override to be corrected. }
  TP3CombatPlayerAccess = class(TEObject)
  public
    procedure Slot04C; virtual; abstract;
    procedure Slot050; virtual; abstract;
    procedure Slot054; virtual; abstract;
    procedure Slot058; virtual; abstract;
    procedure Slot05C; virtual; abstract;
    procedure Slot060; virtual; abstract;
    procedure Slot064; virtual; abstract;
    procedure SetCombatPlayer(Player: Byte); virtual; abstract;
  end;

constructor TCombatUnit.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FControlMode := [cmConquerObject];
  FUnitGFXResourceIndex := -1;
end;

destructor TCombatUnit.Destroy;
begin
  SetUnit(0);
  inherited Destroy;
end;

class function TCombatUnit.ClassID: Integer;
begin Result := $202A1; end;

procedure TCombatUnit.Setup(A1: Byte; A2: Integer; A3: Integer; A4: Byte; A5: Byte);
begin
  FID := A1;
  FPosition := A4;
  with TP3CombatPlayerAccess(Self) do SetCombatPlayer(A5);
  SetUnit(A3);
end;

function TCombatUnit.GetVisibilityRange: Integer;
var
  Level: Integer;
  U: TAbstractUnit;
begin
  U := FUnit;
  if U <> nil then
  begin
    { needs: P2 TAbstractUnit.GetAbilityLevel returns Integer (+$144),
      GetAbilityEnabled returns Boolean (+$148); original calls at $55724AE2/$55724B0D. }
    Level := TP3AbstractUnitAccess(U).GetAbilityLevel($40);
    if Level <> 0 then
      Result := Level * 2 + 4
    else
      Result := 4;
    if (TCombat(F_CombatObject_08).F_Combat_40 = 1) and
       not TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($27) then
      Result := (Result + 1) div 2;
  end
  else Result := 0;
end;

procedure TCombatUnit.NewTurn(A1: Byte);
var
  U: TAbstractUnit;
begin
  inherited NewTurn(A1);
  U := FUnit;
  if U <> nil then U.TriggerNewCombatTurn(Integer(Self), A1);
end;

procedure TCombatUnit.NewRound;
begin inherited NewRound; end;

procedure TCombatUnit.CombatDone;
var
  U: TAbstractUnit;
begin
  inherited CombatDone;
  U := FUnit;
  if U <> nil then U.TriggerCombatDone(Integer(Self));
end;

function TCombatUnit.GetEnabled: Boolean;
begin
  Result := (FUnit <> nil) and ([csDestroyed, csFled] * FStatus = []) and
    not FDisabled;
end;

function TCombatUnit.GetLocked: Boolean;
begin
  { needs: P2 Boolean result for TAbstractUnit.GetAbilityEnabled. }
  Result := TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($5F) or
    TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($61) or
    TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($5C) or
    TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($5E) or
    TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($22);
end;

function TCombatUnit.WallCombatFeatures: TWallCombatFeatures;
begin Result := FWallCombatFeatures; end;

function TCombatUnit.ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes;
begin
  { needs: P2 TAbstractUnit.ExecuteCombatDamageEffects(Combat, Effects): TDamageTypes;
    $55724C2F calls it with Self in EAX, combat in EDX, effects in CX. }
  Result := TP3ExecuteCombatDamageEffects(@TAbstractUnit.ExecuteCombatDamageEffects)(
    FUnit, F_CombatObject_08, A1);
end;

function TCombatUnit.ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes;
begin
  { needs: P2 TAbstractUnit.ExecuteDamageEffectsRole(Effects): TDamageTypes;
    $55724C4C consumes the damage-effect set result from AX. }
  Result := TP3ExecuteDamageEffectsRole(@TAbstractUnit.ExecuteDamageEffectsRole)(FUnit, A1);
end;

procedure TCombatUnit.UpdateWallCombatFeatures;
begin end;

procedure TCombatUnit.Activate(A1: Integer);
begin end;

procedure TCombatUnit.Deactivate;
begin end;

procedure TCombatUnit.Initialize(A1: Integer);
begin end;

procedure TCombatUnit.Finalize(A1: Integer);
begin end;

procedure TCombatUnit.PlaySFX(A1: Byte);
begin end;

procedure TCombatUnit.GetMoves;
begin end;

procedure TCombatUnit.GetAlignment;
begin end;

procedure TCombatUnit.GetAbilityOwner;
begin end;

procedure TCombatUnit.GetAbilityEnabled;
begin end;

procedure TCombatUnit.SetAbilityEnabled;
begin end;

procedure TCombatUnit.GetAbilityLevel;
begin end;

procedure TCombatUnit.GetAbilityCount;
begin end;

procedure TCombatUnit.GetHits;
begin end;

procedure TCombatUnit.GetHitPoints;
begin end;

procedure TCombatUnit.SetHitPoints(A1: Byte);
begin end;

procedure TCombatUnit.SetParty(A1: Integer);
begin end;

procedure TCombatUnit.UpdateParty;
begin end;

procedure TCombatUnit.UpdateUnitGFXResource;
begin end;

procedure TCombatUnit.ReleaseUnitGFXResource;
begin end;

procedure TCombatUnit.SetUnit(A1: Integer);
begin end;

procedure TCombatUnit.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombatUnit.ObjectDestroyed(A1: Integer);
begin end;

procedure TCombatUnit.GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatUnit.GetTargetWallCV(A1: Integer);
begin end;

procedure TCombatUnit.GetAttack;
begin end;

procedure TCombatUnit.GetDefense;
begin end;

procedure TCombatUnit.GetResistance;
begin end;

procedure TCombatUnit.GetDamage;
begin end;

procedure TCombatUnit.GetImmunityTypes;
begin end;

procedure TCombatUnit.GetProtectionTypes;
begin end;

procedure TCombatUnit.GetExperience;
begin end;

procedure TCombatUnit.SetExperience;
begin end;

procedure TCombatUnit.GetLevel;
begin end;

procedure TCombatUnit.IDStr(A1: Integer);
begin end;

procedure TCombatUnit.SupportCombatMode(A1: Byte; A2: Integer);
begin end;

procedure TCombatUnit.SetStatus(A1: Byte; A2: Integer);
begin end;

procedure TCombatUnit.KillUnit;
begin end;

procedure TCombatUnit.DestroyObject;
begin end;

procedure TCombatUnit.Surrender;
begin end;

procedure TCombatUnit.GetTargetPriority;
begin end;

procedure TCombatUnit.GetTargetStrength;
begin end;

procedure TCombatUnit.CommandingTargetPriority(A1: Integer; A2: Integer);
begin end;

procedure TCombatUnit.CommandingTargetStrength(A1: Integer; A2: Integer);
begin end;

procedure TCombatUnit.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatUnit.ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatUnit.ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

constructor TCombatWall.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombatWall.Destroy;
begin end;

class function TCombatWall.ClassID: Integer;
begin Result := 0; end;

procedure TCombatWall.GetTargetPriority;
begin end;

procedure TCombatWall.GetTargetStrength;
begin end;

procedure TCombatWall.fcRoundDistance;
begin end;

procedure TCombatWall.Setup(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TCombatWall.Activate(A1: Integer);
begin end;

procedure TCombatWall.Deactivate;
begin end;

procedure TCombatWall.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombatWall.GetDefense;
begin end;

procedure TCombatWall.GetResistance;
begin end;

procedure TCombatWall.IDStr(A1: Integer);
begin end;

procedure TCombatWall.GetHits;
begin end;

procedure TCombatWall.GetHitPoints;
begin end;

procedure TCombatWall.GetImmunityTypes;
begin end;

function TCombatWall.GetLocked: Boolean;
begin Result := F_CombatWall_4E <> 0; end;

procedure TCombatWall.SetHitPoints(A1: Byte);
begin end;

procedure TCombatWall.DestroyObject;
begin end;

procedure TCombatWall.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatWall.ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatWall.ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

constructor TCombatObject.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombatObject.Destroy;
begin end;

procedure TCombatObject.TargetsChanged;
begin end;

procedure TCombatObject.AddTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombatObject.DeleteTarget(A1: Integer);
begin end;

procedure TCombatObject.RemoveTarget(A1: Integer);
begin end;

procedure TCombatObject.ResetTargets;
begin end;

procedure TCombatObject.GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatObject.GetTargetWallCV(A1: Integer);
begin end;

procedure TCombatObject.GetTargetPriority;
begin end;

procedure TCombatObject.GetTargetStrength;
begin end;

procedure TCombatObject.SetupTargets;
begin end;

procedure TCombatObject.ObjectSideChanged(A1: Integer);
begin end;

procedure TCombatObject.fcExecute(A1: Integer);
begin end;

procedure TCombatObject.fcBehindWall;
begin end;

procedure TCombatObject.fcWallInBetween(A1: Integer);
begin end;

procedure TCombatObject.fcRoundDistance;
begin end;

function TCombatObject.GetVisibilityRange: Integer;
begin Result := 0; end;

procedure TCombatObject.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCombatObject.WallCombatFeatures: TWallCombatFeatures;
begin Result := []; end;

function TCombatObject.GetEnabled: Boolean;
begin Result := [csDestroyed, csFled] * FStatus = []; end;

procedure TCombatObject.GetSide;
begin end;

procedure TCombatObject.GetOpponentSide;
begin end;

procedure TCombatObject.NewTurn(A1: Byte);
begin end;

procedure TCombatObject.NewRound;
begin end;

procedure TCombatObject.CombatDone;
begin end;

procedure TCombatObject.TurnDone;
begin end;

procedure TCombatObject.Activate(A1: Integer);
begin end;

procedure TCombatObject.Deactivate;
begin end;

procedure TCombatObject.Initialize(A1: Integer);
begin end;

procedure TCombatObject.Finalize(A1: Integer);
begin end;

procedure TCombatObject.PlaySFX(A1: Byte);
begin end;

function TCombatObject.GetLocked: Boolean;
begin Result := False; end;

procedure TCombatObject.SetCombatPlayer(A1: Integer; A2: Integer);
begin end;

procedure TCombatObject.GetAttack;
begin end;

procedure TCombatObject.GetDefense;
begin end;

procedure TCombatObject.GetResistance;
begin end;

procedure TCombatObject.GetDamage;
begin end;

procedure TCombatObject.GetImmunityTypes;
begin end;

procedure TCombatObject.GetProtectionTypes;
begin end;

procedure TCombatObject.GetMoves;
begin end;

procedure TCombatObject.GetHits;
begin end;

procedure TCombatObject.SetHitPoints(A1: Byte);
begin end;

procedure TCombatObject.GetHitPoints;
begin end;

procedure TCombatObject.GetExperience;
begin end;

procedure TCombatObject.SetExperience;
begin end;

procedure TCombatObject.GetLevel;
begin end;

procedure TCombatObject.IDStr(A1: Integer);
begin end;

procedure TCombatObject.GetAlignment;
begin end;

procedure TCombatObject.GetAbilityOwner;
begin end;

procedure TCombatObject.GetAbilityEnabled;
begin end;

procedure TCombatObject.SetAbilityEnabled;
begin end;

procedure TCombatObject.GetAbilityLevel;
begin end;

procedure TCombatObject.GetAbilityCount;
begin end;

procedure TCombatObject.GetPlayer;
begin end;

procedure TCombatObject.GetPlayerIR;
begin end;

procedure TCombatObject.ObjectDestroyed(A1: Integer);
begin end;

procedure TCombatObject.SupportCombatMode(A1: Byte; A2: Integer);
begin end;

procedure TCombatObject.GetOptimalDamageType(A1: Word; A2: Integer);
begin end;

procedure TCombatObject.ExecuteDamageRole(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatObject.ExecuteDamageRoleEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

function TCombatObject.ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes;
begin Result := []; end;

function TCombatObject.ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes;
begin Result := []; end;

procedure TCombatObject.DoDamage(A1: Integer; A2: Integer);
begin end;

procedure TCombatObject.DestroyObject;
begin end;

procedure TCombatObject.Surrender;
begin end;

function TCombatObject.ExecuteDamage(A1: Integer): Integer;
begin Result := 0; end;

procedure TCombatObject.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatObject.ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatObject.ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

constructor TCombatSide.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCombatSide.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

destructor TCombatSide.Destroy;
begin end;

procedure TCombatSide.GetObjects(A1: Integer);
begin end;

procedure TCombatSide.IndexOfID(A1: Integer);
begin end;

procedure TCombatSide.GetDestroyedObjects;
begin end;

procedure TCombatSide.GetUndestroyedConquerObjects;
begin end;

procedure TCombatSide.OutputDebugInfo;
begin end;

procedure TCombatSide.UpdateSettings;
begin end;

constructor TCombat.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombat.Destroy;
begin end;

procedure TCombat.GetLogCombatActions;
begin end;

procedure TCombat.SetLogCombatActions(A1: Byte);
begin end;

procedure TCombat.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombat.GetRound;
begin end;

procedure TCombat.ExecuteCombatAction(A1: Integer);
begin end;

procedure TCombat.PlayerTypeInvolved(A1: Byte; A2: Integer);
begin end;

procedure TCombat.CreateUniqueCOID;
begin end;

procedure TCombat.Clear;
begin end;

procedure TCombat.Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer);
begin end;

function TCombat.CreateCombatUnit: Integer;
begin Result := 0; end;

procedure TCombat.NewRound;
begin end;

procedure TCombat.UpdateSidesSettings;
begin end;

procedure TCombat.NewTurn(A1: Integer);
begin end;

procedure TCombat.NextTurn;
begin end;

procedure TCombat.Terminate;
begin end;

procedure TCombat.CheckTerminate;
begin end;

procedure TCombat.ObjectSideChanged(A1: Integer);
begin end;

procedure TCombat.ObjectDestroyed(A1: Integer);
begin end;

procedure TCombat.SetLogbookHeader(A1: Integer; A2: Integer);
begin end;

procedure TCombat.AddAdjacentArmies;
begin end;

procedure TCombat.GetPartyPosition(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TCombat.CreateCombatPlayer: Integer;
begin Result := 0; end;

procedure TCombat.AddCombatPlayer(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombat.AddArmy(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombat.AddArmyEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TCombat.AddEmptyArmy(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombat.InitDefaultArmies(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombat.Initialize;
begin end;

procedure TCombat.Finalize;
begin end;

procedure TCombat.LockExecuted;
begin end;

procedure TCombat.UnlockExecuted;
begin end;

procedure TCombat.Activate;
begin end;

procedure TCombat.Deactivate(A1: Integer; A2: Integer);
begin end;

function TCombat.Execute: Byte;
begin Result := 0; end;

procedure TCombat.UpdateStatus;
begin end;

procedure TCombat.GetCombatResultText(A1: Integer);
begin end;

procedure TCombat.DefendersAvailable;
begin end;

destructor TCombatTypeRequestEventLog.Destroy;
begin end;

procedure TCombatTypeRequestEventLog.SetTokenEvent(A1: Integer);
begin end;

procedure TCombatTypeRequestEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombatTypeRequestEventLog.Select(A1: Byte);
begin end;

procedure TCombatTypeRequestEventLog.SetCenterLocation(A1: Byte; A2: Byte; A3: Integer);
begin end;

constructor TCombatParty.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombatParty.Destroy;
begin end;

class function TCombatParty.ClassID: Integer;
begin Result := 0; end;

procedure TCombatParty.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombatParty.Activate(A1: Integer);
begin end;

procedure TCombatParty.Deactivate;
begin end;

function TCombatPartyList.GetControlStyle: Engine.TEControlStyles;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCombatPartyList.CreateParty(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TCombatPartyList.GetParty(A1: Integer);
begin end;

procedure TCombatPartyList.Activate(A1: Integer);
begin end;

procedure TCombatPartyList.Deactivate(A1: Integer);
begin end;

class function TCombatPlayer.ClassID: Integer;
begin Result := 0; end;

procedure TCombatPlayer.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TCombatPlayerList.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombatPlayerList.Destroy;
begin end;

procedure TCombatPlayerList.GetPlayers(A1: Byte);
begin end;

procedure TCombatPlayerList.IndexOfPlayer(A1: Byte);
begin end;

procedure TCombatPlayerList.IndexOf(A1: Byte; A2: Byte);
begin end;

procedure TCombatPlayerList.Delete(A1: Integer);
begin end;

constructor TCombatData.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombatData.Destroy;
begin end;

class function TCombatData.ClassID: Integer;
begin Result := 0; end;

procedure TCombatData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombatData.GetSideLeaderInvolved(A1: Integer);
begin end;

procedure TCombatData.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TCombatData.GetCount;
begin end;

procedure TCombatData.GetObjects(A1: Integer);
begin end;

procedure TCombatData.Clear;
begin end;

procedure TCombatData.IndexOfID(A1: Integer);
begin end;

procedure TCombatData.FindID(A1: Integer);
begin end;

procedure TCombatData.FindPosition(A1: Byte);
begin end;

procedure TCombatData.AddObject(A1: Integer);
begin end;

constructor TCombatLogbook.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombatLogbook.Destroy;
begin end;

procedure TCombatLogbook.SetInitialData;
begin end;

procedure TCombatLogbook.SetFinalData;
begin end;

procedure TCombatLogbook.Clear;
begin end;

class function TCombatLogbook.ClassID: Integer;
begin Result := 0; end;

function TCombatLogbook.AddRef: Integer;
begin Result := 0; end;

function TCombatLogbook.Release: Integer;
begin Result := 0; end;

procedure TCombatLogbook.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

destructor TCombatEventLog.Destroy;
begin end;

class function TCombatEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TCombatEventLog.SetCombatLogbook(A1: Integer);
begin end;

procedure TCombatEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombatEventLog.GetTextColor;
begin end;

procedure TCombatEventLog.GetLeftIcon;
begin end;

procedure TCombatEventLog.GetMiddleIcon;
begin end;

procedure TCombatEventLog.GetRightIcon;
begin end;

procedure TCombatEventLog.GetText(A1: Integer);
begin end;

procedure TCombatEventLog.PlayLoggedSFX(A1: Integer);
begin end;

procedure TCombatEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombatEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

constructor TCombatViewer.Create;
begin end;

destructor TCombatViewer.Destroy;
begin end;

procedure TCombatViewer.Initialize(A1: Integer);
begin end;

procedure TCombatViewer.Finalize;
begin end;

procedure TCombatViewer.GetEndPosition;
begin end;

procedure TCombatViewer.SetSpeed(A1: Byte);
begin end;

procedure TCombatViewer.SetPosition(A1: Integer);
begin end;

procedure TCombatViewer.Play;
begin end;

procedure TCombatViewer.Pause;
begin end;

procedure TCombatViewer.Update;
begin end;

procedure TCombatViewer.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TCombatViewer.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TCombatViewer.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombatViewer.DefaultShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

constructor TCombatAction.Create(AOwner: Engine.TECustomNode);
begin end;

function TCombatAction.AddRef: Integer;
begin Result := 0; end;

function TCombatAction.Release: Integer;
begin Result := 0; end;

procedure TCombatAction.GetName(A1: Integer);
begin end;

procedure TCombatAction.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TCombatAction.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TCombatAction.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatActionList.GetCombatActions(A1: Integer);
begin end;

procedure TSingleTargetCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSingleTargetCA.GetDefensive;
begin end;

procedure TSingleTargetCA.SetDefensive(A1: Byte);
begin end;

procedure TSingleTargetCA.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TSingleTargetCA.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

class function TDamageCA.ClassID: Integer;
begin Result := 0; end;

procedure TDamageCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TDamageCA.Setup(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TDamageCA.Generate(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TDamageCA.GenerateEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TDamageCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TDamageCA.Play(A1: Integer);
begin end;

procedure TDamageCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

class function TDamageEffectCA.ClassID: Integer;
begin Result := 0; end;

procedure TDamageEffectCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TDamageEffectCA.Initialize(A1: Byte; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TDamageEffectCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TDamageEffectCA.Play(A1: Integer);
begin end;

procedure TDamageEffectCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

class function TUpdateHeaderCA.ClassID: Integer;
begin Result := 0; end;

procedure TUpdateHeaderCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUpdateHeaderCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TUpdateHeaderCA.Play(A1: Integer);
begin end;

class function TNewCombatTurnCA.ClassID: Integer;
begin Result := 0; end;

procedure TNewCombatTurnCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TNewCombatTurnCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TNewCombatTurnCA.Play(A1: Integer);
begin end;

class function TNewCombatRoundCA.ClassID: Integer;
begin Result := 0; end;

procedure TNewCombatRoundCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TNewCombatRoundCA.Play(A1: Integer);
begin end;

class function TCombatObjectTurnDoneCA.ClassID: Integer;
begin Result := 0; end;

procedure TCombatObjectTurnDoneCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombatObjectTurnDoneCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TCombatObjectTurnDoneCA.Play(A1: Integer);
begin end;

class function TMoveWallCA.ClassID: Integer;
begin Result := 0; end;

procedure TMoveWallCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TMoveWallCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TMoveWallCA.Play(A1: Integer);
begin end;

class function TFleeCA.ClassID: Integer;
begin Result := 0; end;

procedure TFleeCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFleeCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TFleeCA.Play(A1: Integer);
begin end;

constructor TCombatPredictorUnit.Create;
begin end;

destructor TCombatPredictorUnit.Destroy;
begin end;

procedure TCombatPredictorUnit.Setup(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatPredictorUnit.SetEnabled(A1: Byte);
begin end;

procedure TCombatPredictorUnit.UpdateTargets;
begin end;

procedure TCombatPredictorUnit.UpdateWallTargets(A1: Integer; A2: Integer);
begin end;

procedure TCombatPredictorUnit.InvalidateTargets;
begin end;

procedure TCombatPredictorUnit.ResetCombat;
begin end;

procedure TCombatPredictorUnit.ResetRoundTargets;
begin end;

procedure TCombatPredictorUnit.SetupRoundTargets(A1: Byte);
begin end;

procedure TCombatPredictorUnit.UpdateRoundTargetPriority;
begin end;

procedure TCombatPredictorUnit.SortRoundTargets;
begin end;

procedure TCombatPredictorUnit.ExecuteRound;
begin end;

procedure TCombatPredictorUnit.FinishCombat;
begin end;

procedure TCombatPredictorUnitList.GetUnits(A1: Integer);
begin end;

procedure TCombatPredictorUnitList.IndexOfUnit(A1: Integer);
begin end;

procedure TCombatPredictorUnitList.IndexOfCPUID(A1: Integer);
begin end;

procedure TCombatPredictorSide.Reset;
begin end;

procedure TCombatPredictorSide.GetStrength(A1: Integer);
begin end;

procedure TCombatPredictorSide.GetStrengthMax(A1: Word; A2: Integer);
begin end;

constructor TCombatPredictor.Create;
begin end;

destructor TCombatPredictor.Destroy;
begin end;

procedure TCombatPredictor.Reset;
begin end;

procedure TCombatPredictor.CreateUniqueCPUID;
begin end;

procedure TCombatPredictor.EnableAllUnits;
begin end;

procedure TCombatPredictor.Validate;
begin end;

procedure TCombatPredictor.ResetCombat;
begin end;

procedure TCombatPredictor.SetupCombat(A1: Integer);
begin end;

procedure TCombatPredictor.ExecuteCombatRound;
begin end;

procedure TCombatPredictor.CanPassWall;
begin end;

procedure TCombatPredictor.FinishCombat;
begin end;

procedure TCombatPredictor.Execute;
begin end;

procedure TCombatPredictor.DeleteUnit(A1: Integer; A2: Integer);
begin end;

procedure TCombatPredictor.AddUnitEx(A1: Integer; A2: Byte; A3: Integer);
begin end;

procedure TCombatPredictor.AddUnit;
begin end;

procedure TCombatPredictor.AddUnits(A1: Integer);
begin end;

procedure TCombatPredictor.AddOpponent(A1: Integer; A2: Integer);
begin end;

procedure TCombatPredictor.AddOpponents(A1: Integer; A2: Integer);
begin end;

procedure TCombatPredictor.AddWall(A1: Integer);
begin end;

procedure TCombatPredictor.DeleteWall;
begin end;

procedure TCombatPredictor.DeleteUnits;
begin end;

procedure TCombatPredictor.DeleteOpponents;
begin end;

procedure TCombatPredictor.InitAdjacentArmies(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TCombatPredictor.InitAdjacentOpponents(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatPredictor.GetSuperiority(A1: Integer; A2: Integer);
begin end;

procedure TCombatPredictor.GetEfficiency;
begin end;

procedure TCombatPredictor.ListRequiredUnitsEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombatPredictor.ListRequiredUnits(A1: Integer; A2: Integer);
begin end;

procedure TCombatPredictor.ListOptionalUnits(A1: Integer; A2: Integer);
begin end;

procedure TCombatPredictor.ListUselessUnits(A1: Integer);
begin end;

procedure TCombatPredictor.Usefullness(A1: Integer; A2: Integer);
begin end;

