function TSpellCC.GetName: string;
begin
  Result := Format(TranslateRStr(P4CastXRStr), [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]);

  if FTarget <> nil then Result := Result + ' on ' + FTarget.IDStr;
end;



constructor TSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellText := TStringList.Create;
  FCastSounds := TSFXLibrary.Create(nil);
  FCastImages := TImageSequenceList.Create(AoWHSSet.ImageLibraryManager, nil);
  FResearchCost := 1;
  FSpellControlTypes := [sctGlobal];
end;

destructor TSpell.Destroy;
begin
  FCastSounds.Free;
  FCastImages.Free;
  FSpellText.Free;
  inherited Destroy;
end;
function TSpell.GetEnabled: Boolean;
asm
  MOV AL, 1
end;
procedure TSpell.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FSpellText, 10);
  Stream.rwEObject(FCastSounds, 11);
  Stream.rwStreamProc(12, FCastImages.LoadFromStream, FCastImages.SaveToStream);
  Stream.rwInteger(FBaseManaCost, 13);
  Stream.rwInteger(FManaUpkeep, 14);
  Stream.rwInteger(FResearchCost, 15);
  Stream.rwData(FMagicSphere, 1, 16);
  Stream.rwByte(FSpellLevel, 17);
end;
function TSpell.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
begin
  if FSpellType = stGlobal then
    if getSpellWard in AoWHSMap.FGlobalMagicControl.FActiveEnchantments then
    begin
      A2 := TranslateRStr(CannotCastGlobalEnchantmentWhenSpellWardIsActiveRStr);
      Result := False;
    end
    else Result := True
  else Result := True;
end;
function TSpell.Activate(A1: TAbstractUnit): Boolean;
var
  X, Y, L: Shortint;
begin
  if AoWHSMap.FSeatedPlayer = A1.FPlayer then
  begin
    A1.GetLocation(X, Y, L);
    if X <> -1 then AoWHSMap.MakeVisible(X, Y, L, 3);
  end;
  Result := False; { Original returns False after optionally centering the view. }
end;



















function TSpell.CanActivateCombat(A1: TAbstractUnit; var A2: string): Boolean;
asm
  MOV EAX, [AoWHSMap]
  CMP DWORD PTR [EAX + $120], 0
  SETNE AL
end;
function TSpell.ActivateCombat(A1: TAbstractUnit): Boolean;
var
  Caster: TCombatSpellCaster;
  Reason: string;
begin
  if CanActivateCombat(A1, Reason) then
  begin
    Caster := TCombatSpellCaster.Create(nil);
    Caster.FCombatCasterSpellID := FSpellID;
    Caster.FCombatCasterSourceID := A1.FUnitID;
    AoWHSMap.FCombatMap.FCombatStartedEvents.TriggerNotifyEvents(Caster);
    Caster.Release;
    Result := True;
  end
  else Result := False;
end;




















































function TSpell.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
asm
  XOR EAX, EAX
end;
procedure TSpell.GetCombatInfo(Source: TAbstractUnit; var Info: TSpellCombatInfo);
{ ECX points to the eight-byte TSpellCombatInfo record. }
asm
  PUSH EBX
  MOV EBX, ECX
  MOV [EBX].TP4CombatInfo.V0, 0
  MOV [EBX].TP4CombatInfo.V1, 0
  MOV AX, [P4EmptyDamageTypes]
  MOV [EBX].TP4CombatInfo.DamageTypes, AX
  MOV [EBX].TP4CombatInfo.V4, 1
  MOV [EBX].TP4CombatInfo.V5, 0
  MOV [EBX].TP4CombatInfo.V6, 0
  MOV AL, [P4EmptyCombatModes]
  MOV [EBX].TP4CombatInfo.Modes, AL
  POP EBX
end;
function TSpell.GetCombatDamageValue(A1, A2: TCombatObject): Integer;
asm
  XOR EAX, EAX
end;
procedure TSpell.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  with PP4DamageValue(@A3)^ do
  begin
    V0 := 0;
    V1 := 0;
    V2 := 0;
    V3 := 0;
    DamageTypes := [];
  end;
end;
procedure TSpell.CastingDone(Source: TAbstractUnit; Mana: Integer);
begin
  if Source is THero then
    THero(Source).CastingDone(FSpellID, Mana);
end;
procedure TSpell.CombatCastingDone(Source: TCombatObject; Mana: Integer);
begin
  if (Source is TCombatUnit) and
    (TObject(TCombatUnit(Source).FUnit) is THero) then
    with TCombatUnit(Source) do
    begin
      THero(FUnit).CastingDone(FSpellID, Mana);
      UpdateWallCombatFeatures;
      if TObject(Source.FCombat) is TFastCombat then
        TFastCombatUnit(Source).UpdateWallSiegeObjectRegistration;
    end;
end;
function THeroCastingViewP4.SpellMana(Spell: TSpell): Integer; assembler;
{ needs: P2 THero.CastingMana(Spell: TSpell): Integer; 55779557 returns EAX. }
asm
  JMP THero.CastingMana
end;
procedure TSpell.CombatSpellCast(Source: TCombatUnit);
var
  Hero: THeroCastingViewP4;
  Mana: Integer;
begin
  Hero := THeroCastingViewP4(Source.FUnit);
  Mana := Hero.SpellMana(Self);
  CombatCastingDone(Source, Mana);
end;
procedure TSpell.PlayDefaultCastEffects(Player, X, Y, Layer: Shortint);
var
  Animation: TImageSequenceAnimation;
begin
  if AoWHSMap.Visible(X, Y, Layer, 0) then
  begin
    AoWHSMap.ValidateObservation(Player, X, Y, Layer, 0);
    if AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(0) <> nil then
    begin
      Animation := TImageSequenceAnimation.Create(nil);
      Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(0));
      AoWHSMap.PlaceHX(Animation, X, Y, Layer);
    end;
    if (AoWHSMap.FSeatedPlayer = Player) or AoWHSMap.Watching(X, Y, Layer, 0) then
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
  end;
end;







































































function TSpell.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
asm
  XOR EAX, EAX
end;
procedure TSpell.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  FillChar(A4, 20, 0);
end;
procedure TSpell.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
begin end;
function TSpell.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
asm
  XOR EAX, EAX
end;
procedure TSpell.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EAX
  MOV EAX, A3
  PUSH EAX
  MOV EAX, ESI
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $84]
  POP ESI
  POP EBX
end;
function TSpell.tcGetDamageValue(Source, Target: TCombatObject): Integer;
asm
  PUSH EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $80]
  POP EBX
end;
function TSpell.CreateCastSpellAction: TAICastSpellAction;
asm
  XOR ECX, ECX
  MOV DL, 1
  MOV EAX, [P4CastSpellActionClass]
  CALL TEObject.Create
end;
procedure TSpell.SetupCastSpellAction(A1: TAbstractUnit; A2: TAICastSpellAction);
asm
  MOV EAX, [EAX].TSpell.FSpellID
  MOV [ECX + $0C], EAX
  MOV EAX, [EDX + $18]
  MOV [ECX + $08], EAX
end;
function P4GetPlayer(Players: TPlayerList; PlayerIndex: Integer): TPlayer; assembler;
{ needs: P1 TPlayerList.GetPlayers returns TPlayer; EAX is consumed at 55779710. }
asm
  JMP TPlayerList.GetPlayers
end;
function P4RequestBudget(Manager: TAIBudgetManager; A1, A2, A3, A4, A5, A6: Integer): Boolean; assembler;
{ needs: P5 RequestBudgetExpenseEx returns Boolean; 55779781 tests AL. }
asm
  POP EBP
  JMP TAIBudgetManager.RequestBudgetExpenseEx
end;
function TSpell.AIRequestCastSpellExpense(Source: TAbstractUnit; Budget, Mana, Upkeep: Integer): Boolean;
var
  Manager: TAIBudgetManager;
begin
  if Upkeep > 0 then
  begin
    Dec(Mana, AoWHSMap.FPlayers.GetPlayers(ShortInt(Source.FPlayer)).FMagicControl.AIRequestOverrideUpkeep(
      Round(Upkeep * 0.8)));
    if Mana < 0 then
      Mana := 0;
  end;
  Manager := TAIBudgetManager(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
    ShortInt(Source.FPlayer)).FAIBudget);
  if not TPlayerMagicControl(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
    ShortInt(Source.FPlayer)).FMagicControl).GetCheatEnabled then
    Result := P4RequestBudget(Manager, 0, Budget, 0, Mana, Integer(Manager.FDefaultBudget), 1)
  else
    Result := True;
end;
function P4BudgetMade(Manager: TAIBudgetManager; A1, A2, A3, A4, A5, A6: Integer): Boolean; assembler;
{ needs: P5 BudgetExpenseMadeEx returns Boolean; 5577980F leaves AL for return. }
asm
  POP EBP
  JMP TAIBudgetManager.BudgetExpenseMadeEx
end;
function TSpell.AICastSpellExpenseMade(Source: TAbstractUnit; Budget, Mana, Upkeep: Integer): Boolean;
var
  Manager: TAIBudgetManager;
begin
  if AIRequestCastSpellExpense(Source, Budget, Mana, Upkeep) then
  begin
    Manager := TAIBudgetManager(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
      ShortInt(Source.FPlayer)).FAIBudget);
    if not TPlayerMagicControl(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
      ShortInt(Source.FPlayer)).FMagicControl).GetCheatEnabled then
      Result := P4BudgetMade(Manager, 0, Budget, 0, Mana, Integer(Manager.FDefaultBudget), 2)
    else
      Result := True;
  end
  else
    Result := False;
end;
procedure TSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
begin end;
function TSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
asm
  XOR EAX, EAX
end;
class function TSpellTE.ClassID: Integer;
begin
  Result := $21300;
end;
procedure TSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FEventSpellID, 15);
  Stream.rwInteger(FEventSourceID, 16);
  Stream.rwByte(FEventPlayerIndex, 17);
  Stream.rwInteger(FEventMana, 18);
end;
procedure TSpellTE.Initialize(SpellID: Integer; PlayerIndex: Byte; SourceID, Mana: Integer);
begin
  FEventSpellID := SpellID;
  FEventSourceID := SourceID;
  FEventPlayerIndex := PlayerIndex;
  FEventMana := Mana;
end;
function TSpellTE.GetSource: TAbstractUnit;
asm
  MOV EDX, [AoWHSMap]
  MOV EDX, [EDX + $FC]
  MOV EAX, [EAX].TSpellTE.FEventSourceID
  XCHG EDX, EAX
  CALL TUnitControl.FindUnit
end;
function TSpellTE.Validate(A1: THero): Boolean;
{ AL is Boolean. The original assumes the source supports THero's instant-cast API. }
asm
  PUSH EBP
  MOV EBP, ESP
  PUSH 0
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  XOR EAX, EAX
  PUSH EBP
  PUSH OFFSET @@Exception
  PUSH DWORD PTR FS:[EAX]
  MOV DWORD PTR FS:[EAX], ESP
  MOV AL, [ESI + $24]
  CMP AL, [EBX].TSpellTE.FEventPlayerIndex
  JNE @@No
  LEA EAX, [EBP - 4]
  PUSH EAX
  MOV ECX, [EBX].TSpellTE.FEventMana
  MOV EDX, [EBX].TSpellTE.FEventSpellID
  MOV EAX, ESI
  CALL THero.CanCastSpellInstantly
  TEST AL, AL
  JNE @@Yes
@@No:
  XOR EAX, EAX
  JMP @@Finally
@@Yes:
  MOV AL, 1
@@Finally:
  MOV EBX, EAX
  XOR EAX, EAX
  POP EDX
  POP ECX
  POP ECX
  MOV DWORD PTR FS:[EAX], EDX
  PUSH OFFSET @@Return
@@Clear:
  LEA EAX, [EBP - 4]
  CALL System.@LStrClr
  RET
@@Exception:
  JMP System.@HandleFinally
  JMP @@Clear
@@Return:
  MOV EAX, EBX
  POP ESI
  POP EBX
  POP ECX
  POP EBP
end;
function TSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EDI, ECX
  MOV ESI, EDX
  MOV EBX, EAX
  PUSH EDI
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  MOV EDX, [EBX].TSpellTE.FEventSpellID
  CALL TSpellControl.GetSpell
  MOV ECX, ESI
  MOV EDX, EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $50]
  POP EDI
  POP ESI
  POP EBX
end;
{ These adapters retain byte coordinates while the P1 interface has Integer drafts. }
function TUnitControlCallViewP4.FindUnitResult(ID: Integer): TAbstractUnit; assembler;
{ needs: P2 TUnitControl.FindUnit returns TAbstractUnit; 55779966. }
asm
  JMP TUnitControl.FindUnit
end;
function TSpellTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Control: TUnitControlCallViewP4;
  Source: TAbstractUnit;
begin
  inherited Execute(TE);
  Control := TUnitControlCallViewP4(AoWHSMap.FUnitControl);
  Source := Control.FindUnitResult(FEventSourceID);
  if (Source <> nil) and ((PP4TokenExecuterState(TE)^.ExecuteCount <> 0) or
    TSpellTECallViewP4(Self).ValidateValue(Source)) then
  begin
    if TSpellTECallViewP4(Self).ProcessValue(Source, PP4TokenExecuterState(TE)^.ExecuteCount) then
      Result := erRetry
    else
      Result := erDone;
  end
  else
    Result := erDoneHalt;
end;
procedure TSpellTE.PlayDefaultCastEffects(A1: Integer; A2: Integer);
{ The draft A1/A2 are unused; the event's source provides player and location. }
asm
  PUSH EBX
  PUSH ECX
  MOV EBX, EAX
  LEA EAX, [ESP + 2]
  PUSH EAX
  MOV EAX, EBX
  CALL TSpellTE.GetSource
  LEA ECX, [ESP + 5]
  LEA EDX, [ESP + 4]
  CALL TAbstractUnit.GetLocation
  MOV AL, BYTE PTR [ESP + 1]
  PUSH EAX
  MOV AL, BYTE PTR [ESP + 6]
  PUSH EAX
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  MOV EDX, [EBX].TSpellTE.FEventSpellID
  CALL TSpellControl.GetSpell
  PUSH EAX
  MOV EAX, EBX
  CALL TSpellTE.GetSource
  MOV DL, [EAX + $24]
  MOV CL, BYTE PTR [ESP + $0C]
  POP EAX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $4C]
  POP EDX
  POP EBX
end;
constructor TSpellControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRegisteredSpells := TList.Create;
end;
destructor TSpellControl.Destroy;
begin
  UnregisterAll;
  FRegisteredSpells.Free;
  inherited Destroy;
end;
procedure TSpellControl.ReadWrite(Stream: Engine.TEStorageStream);
var
  I: Integer;
begin
  inherited ReadWrite(Stream);
  for I := 0 to FRegisteredSpells.Count - 1 do
    if FRegisteredSpells[I] <> nil then
      Stream.rwEObject(TSpell(FRegisteredSpells[I]), I + 10);
end;
function TSpellControl.GetCount: Integer;
begin
  Result := FRegisteredSpells.Count;
end;
function TSpellControl.GetSpell(Index: Integer): TSpell;
type TOriginalAssertText = packed record RefCount, Len: Integer; Text: array[0..127] of Char; end; const OriginalAssertFile: TOriginalAssertText = (RefCount:-1; Len:29; Text:'D:\AoWDev\AoWE\inc\Spells.PAS'#0); OriginalAssertMessage: TOriginalAssertText = (RefCount:-1; Len:15; Text:'Invalid SpellID'#0); var P: Pointer;
begin
  if Index < 0 then asm MOV ECX,$D6CD; MOV EDX,OFFSET OriginalAssertFile.Text; MOV EAX,OFFSET OriginalAssertMessage.Text; CALL System.@Assert end; { Preserve the original assertion diagnostic. }
  if Index < FRegisteredSpells.Count then
    begin P := FRegisteredSpells[Index]; Result := TSpell(P); end
  else
    Result := nil;
end;
procedure TSpellControl.RegisterSpell(Spell: TSpell);
var
  ID: Integer;
begin
  ID := Spell.FSpellID;
  if ID <> 0 then
  begin
    if (ID < FRegisteredSpells.Count) and (FRegisteredSpells[ID] <> nil) then
      raise Exception.Create('Spell already registered (' + IntToStr(ID) + ')');
    while FRegisteredSpells.Count <= ID do
      FRegisteredSpells.Add(nil);
    FRegisteredSpells.List^[ID] := Spell;
    Spell.FCastImages.LinkToIL;
  end
  else
    raise Exception.Create('Invalid SpellID (' + Spell.ClassName + ')');
end;
procedure TSpellControl.UnregisterSpell(Spell: TSpell);
var
  ID: Integer;
begin
  ID := Spell.FSpellID;
  if ID <> 0 then
  begin
    if (ID < 0) or (ID >= FRegisteredSpells.Count) or (FRegisteredSpells[ID] <> Spell) then
      raise Exception.Create('Cannot Unregister Spell (' + IntToStr(ID) + ')');
    if FRegisteredSpells.List^[ID] <> nil then
    begin
      Spell.FCastImages.ReleaseIL;
      TSpell(FRegisteredSpells.List^[ID]).Free;
      FRegisteredSpells.List^[ID] := nil;
    end;
  end
  else
    raise Exception.Create('Invalid SpellID (' + Spell.ClassName + ')');
end;
procedure TSpellControl.UnregisterSpellID(A1: Integer);
begin
  if FRegisteredSpells.List^[A1] <> nil then
    UnregisterSpell(TSpell(FRegisteredSpells.List^[A1]));
end;
procedure TSpellControl.UnregisterAll;
var
  I: Integer;
begin
  for I := FRegisteredSpells.Count - 1 downto 0 do
    if FRegisteredSpells[I] <> nil then
      UnregisterSpell(TSpell(FRegisteredSpells[I]));
end;
procedure TSpellControl.ListSpells(SpellStrings: TStrings; Spheres: TMagicSpheres);
var
  I: Integer;
begin
  SpellStrings.Clear;
  with FRegisteredSpells do
    for I := 0 to Count - 1 do
      if (List^[I] <> nil) and (TSpell(List^[I]).FMagicSphere in Spheres) then
        SpellStrings.AddObject(TSpell(List^[I]).FSpellName, TObject(I));
end;
function P4MapRandom(Map: TAoWHSMap; Range: Integer): Integer; assembler;
{ needs: P1 TAoWHSMap.Random returns Integer; used at 55779F7A. }
asm
  JMP TAoWHSMap.Random
end;
function TSpellControl.GetRandomSpell(MinLevel, MaxLevel: Integer; Spheres: TMagicSpheres): Integer;
var
  Candidates: TIntegerList;
  I: Integer;
  Spell: TSpell;
begin
  Candidates := TIntegerList.Create;
  with FRegisteredSpells do
    for I := Count - 1 downto 0 do
    begin
      Spell := TSpell(List^[I]);
      if (Spell <> nil) and (Spell.FMagicSphere in Spheres) and
        (Spell.FSpellLevel >= MinLevel) and (Spell.FSpellLevel <= MaxLevel) then
        Candidates.Add(I);
    end;
  if Candidates.Count <> 0 then
    Result := Candidates[P4MapRandom(AoWHSMap, Candidates.Count)]
  else
    Result := 0;
  Candidates.Free;
end;
constructor TSpellList.Create;
begin
  inherited Create;
  FSpells := TList.Create;
end;
destructor TSpellList.Destroy;
begin
  FSpells.Free;
  inherited Destroy;
end;
function TSpellList.GetSpell(Index: Integer): TSpell;
begin
  if (Index >= 0) and (Index < GetCount) then
    Result := TSpell(FSpells[Index])
  else
    Result := nil;
end;
function TSpellList.GetCount: Integer;
begin
  Result := FSpells.Count;
end;
procedure TSpellList.Add(Spell: TSpell);
begin
  FSpells.Add(Spell);
end;
procedure TSpellList.Delete(Index: Integer);
begin
  FSpells.Delete(Index);
end;
procedure TSpellList.Clear;
begin
  FSpells.Clear;
end;
function P4CompareSpellNames(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(TSpell(Item1).FSpellName, TSpell(Item2).FSpellName);
  if Result = 0 then
    Result := TSpell(Item1).FSpellLevel - TSpell(Item2).FSpellLevel;
end;
procedure TSpellList.SortOnName;
begin
  FSpells.Sort(P4CompareSpellNames);
end;
function P4CompareSpellLevels(Item1, Item2: Pointer): Integer;
begin
  Result := TSpell(Item1).FSpellLevel - TSpell(Item2).FSpellLevel;
  if Result = 0 then
    Result := CompareText(TSpell(Item1).FSpellName, TSpell(Item2).FSpellName);
end;
procedure TSpellList.SortOnLevel;
begin
  FSpells.Sort(P4CompareSpellLevels);
end;
constructor TSpellCaster.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCasterRefCount := 1;
end;
function TSpellCaster.AddRef: Integer;
begin
  Inc(FCasterRefCount);
  Result := FCasterRefCount;
end;
function TSpellCaster.Release: Integer;
var
  Count, ReleasedCount: Integer;
begin
  Dec(FCasterRefCount);
  Count := FCasterRefCount;
  ReleasedCount := Count;
  if Count = 0 then
    Destroy;
  Result := ReleasedCount;
end;
function TSpellCaster.GetSource: TAbstractUnit;
{ needs: P2 TUnitControl.FindUnit returns TAbstractUnit; 5577A140. }
asm
  MOV EDX, [AoWHSMap]
  MOV EDX, [EDX + $FC]
  MOV EAX, [EAX].TSpellCaster.FCasterSourceID
  XCHG EDX, EAX
  CALL TUnitControl.FindUnit
end;
function TSpellCaster.CanCast(var Reason: string): Boolean;
{ Reason is unused; AL reports whether the source still exists. }
asm
  MOV EDX, [AoWHSMap]
  MOV EDX, [EDX + $FC]
  MOV EAX, [EAX].TSpellCaster.FCasterSourceID
  XCHG EDX, EAX
  CALL TUnitControl.FindUnit
  TEST EAX, EAX
  SETNE AL
end;
function TSpellCaster.Cast: Boolean;
asm
  MOV AL, 1
end;
constructor TCombatSpellCaster.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCombatCasterRefCount := 1;
end;
function TCombatSpellCaster.AddRef: Integer;
begin
  Inc(FCombatCasterRefCount);
  Result := FCombatCasterRefCount;
end;
function TCombatSpellCaster.Release: Integer;
var
  Count, ReleasedCount: Integer;
begin
  Dec(FCombatCasterRefCount);
  Count := FCombatCasterRefCount;
  ReleasedCount := Count;
  if Count = 0 then
    Destroy;
  Result := ReleasedCount;
end;
class function TSpellCastEventLog.ClassID: Integer;
begin
  Result := $202EF;
end;
function TSpellCastEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var
  Show: Boolean;
  Hero: TAbstractUnit;
  Reason: string;
begin
  Show := Trigger = etUser;
  Show := Show or ((AoWHSMap.FPlayMode = pmTurn) and
    (wpSpellReady in AoWEngine.FRegistry.GetClassicWindowPopupEvents));
  Show := Show or ((AoWHSMap.FPlayMode = pmSimultaneous) and
    (wpSpellReady in AoWEngine.FRegistry.GetSimultaneousWindowPopupEvents));
  if Show then
  begin
    Hero := AoWHSMap.FUnitControl.FindUnit(FUnitID);
    if (Hero is THero) and (THero(Hero).FCastingSpellID = FSpellID) and THero(Hero).CastingReady then
      AoWHSSet.FAbilityControl.GetAbility(52).Activate(Hero, Reason);
  end;
  Result := False;
end;
procedure TSpellCastEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitID, 20);
  Stream.rwInteger(FSpellID, 21);
end;
procedure TSpellCastEventLog.ViewLocation;
var
  AUnit: TAbstractUnit;
  X, Y, L: Shortint;
begin
  AUnit := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if AUnit <> nil then
  begin
    AUnit.GetLocation(X, Y, L);
    CenterViewTo(X, Y, L);
  end;
end;
function TSpellCastEventLog.GetText: string;
begin
  Result := Format(TranslateRStr(P4XCastingReadyRStr), [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]);
end;
constructor TUnitSpellCaster.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargetUnits := TUnitUserList.Create(nil);
end;
destructor TUnitSpellCaster.Destroy;
begin
  FTargetUnits.Free;
  inherited Destroy;
end;
procedure TUnitSpellCaster.SetSelection(Selection: Byte);
asm
  PUSH EBX
  PUSH ESI
  PUSH ECX
  MOV BYTE PTR [ESP], DL
  MOV EBX, EAX
  MOV EAX, [AoWHSMap]
  MOV EAX, [EAX + $FC]
  MOV EDX, [EBX].TSpellCaster.FCasterSourceID
  CALL TUnitControl.FindUnit
  MOV ESI, EAX
  PUSH ESP
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  MOV EDX, [EBX].TSpellCaster.FCasterSpellID
  CALL TSpellControl.GetSpell
  MOV ECX, [EBX].TUnitSpellCaster.FTargetUnits
  MOV EDX, ESI
  MOV ESI, [EAX]
  CALL DWORD PTR [ESI + $A0]
  MOV AL, BYTE PTR [ESP]
  MOV [EBX].TUnitSpellCaster.FSelectionMask, AL
  POP EDX
  POP ESI
  POP EBX
end;
function TUnitSpellCaster.GetSelectionCount: Integer;
var
  Bits: Integer;
begin
  Result := 0;
  Bits := FSelectionMask;
  while Bits <> 0 do
  begin
    if (Bits and 1) <> 0 then
      Inc(Result);
    Bits := Bits shr 1;
  end;
end;
function TUnitSpellCaster.GetRequiredMana: Integer;
var
  Hero: THeroCastingViewP4;
  Mana, Count: Integer;
begin
  Hero := THeroCastingViewP4(PP4MapUnitControl(AoWHSMap)^.UnitControl.FindUnitResult(FCasterSourceID));
  if Hero <> nil then
  begin
    Mana := Hero.SpellMana(TSpellControl(AoWHSSet.FSpellControl).GetSpell(FCasterSpellID));
    Count := GetSelectionCount;
    Mana := Mana * Count;
    Result := Mana;
  end
  else
    Result := -1;
end;
function TUnitSpellCaster.GetRequiredDays: Integer;
var
  Hero: TCastingPointsReturnViewP4;
  Deficit: Integer;
begin
  Hero := TCastingPointsReturnViewP4(PP4MapUnitControl(AoWHSMap)^.UnitControl.FindUnitResult(FCasterSourceID));
  if (Hero <> nil) and (Hero.CastingPointsMax <> 0) then
  begin
    Deficit := GetRequiredMana - Hero.CastingPoints;
    if Deficit > 0 then
    begin
      Result := Deficit div Hero.CastingPointsMax;
      { Original bug: the remainder uses current points, not maximum points. }
      if Deficit mod Hero.CastingPoints <> 0 then
        Inc(Result);
    end
    else
      Result := 0;
  end
  else
    Result := 0;
end;
function TUnitSpellCaster.CanCast(var Reason: string): Boolean;
var Hero: THero; Mana: Integer;
{ conflict: Caster: THero; }
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FCasterSourceID));
  if (Hero <> nil) and not (usKilled in Hero.FUnitStatus) then
    if FSelectionMask <> 0 then
      if not AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FMagicControl.GetCheatEnabled then
      begin
        Mana := GetRequiredMana;
        if Hero.CastingReady and (Hero.FCastingSpellID = FCasterSpellID) then
          Dec(Mana, AoWHSSet.FSpellControl.GetSpell(FCasterSpellID).FBaseManaCost);
        if Mana <= Hero.GetCastingPoints then
          if Mana <= AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FMagicControl.FMana then
            Result := True
          else
          begin
            Result := False;
            Reason := TranslateRStr(NotEnoughManaRStr);
          end
        else
        begin
          Result := False;
          Reason := TranslateRStr(P2NotEnoughCastingPointsRStr);
        end;
      end
      else Result := True
    else
    begin
      Result := False;
      Reason := TranslateRStr(NoUnitSelectedRStr);
    end
  else Result := False;
end;
function TUnitSpellCaster.Cast: Boolean;
var
  Targets: TUnitUserList;
  Reason: string;
  Source: TAbstractUnit;
  I: Integer;
begin
  if CanCast(Reason) then
  begin
    Source := AoWHSMap.FUnitControl.FindUnit(FCasterSourceID);
    if Source <> nil then
    begin
      Targets := TUnitUserList.Create(nil);
      for I := 0 to FTargetUnits.Count - 1 do
        if ((1 shl I) and FSelectionMask) <> 0 then
          Targets.AddUnit(FTargetUnits.GetUnit(I));
      Result := TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FCasterSpellID)).CastSpell(Source, Targets);
      Targets.Free;
    end
    else Result := True;
  end
  else Result := False;
end;

















































































function TUnitSpellCaster.Valid: Boolean; { Match: the result cast retains Self before FindUnit. }
{ Original 5577A7F0 saves Self in EBX before FindUnit.
  Casting the lookup result through TObject and TAbstractUnit retains that save
  and the original argument order without changing the returned object. }
var
  Source: TAbstractUnit;
begin
  Source := TAbstractUnit(TObject(PP4MapUnitControl(AoWHSMap)^.UnitControl.FindUnitResult(FCasterSourceID)));
  if (Source = nil) or ((Byte(Source.FUnitStatus) and $10) <> 0) then
    Result := False
  else
    Result := True;
end;
class function TUnitSpellCA.ClassID: Integer;
begin
  Result := $202C3;
end;
procedure TUnitSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FSpellID, 20);
  Stream.rwByte(FSourceID, 21);
  Stream.rwByte(FTargetID, 22);
  Stream.rwData(FSpellData, 8, 23);
  Stream.rwInteger(FMana, 24);
end;
procedure TUnitSpellCA.Execute(A1: TCombat);
begin
  TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FSpellID)).ExecuteCA(A1, Self);
end;
function TUnitSpellCA.Play(A1: TCombatViewer): Boolean;
begin
  Execute(A1.FCombat);
  Result := False;
end;
constructor TUnitSpellTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargetUnitIDs := TIntegerList.Create;
  FTargetUnits := TUnitUserList.Create(nil);
end;
destructor TUnitSpellTE.Destroy;
begin
  FTargetUnitIDs.Free;
  FTargetUnits.Free;
  inherited Destroy;
end;
class function TUnitSpellTE.ClassID: Integer;
begin
  Result := $21308;
end;
procedure TUnitSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(30, FTargetUnitIDs.LoadFromStream, FTargetUnitIDs.SaveToStream);
  Stream.rwData(FSpellData, 8, 31);
  Stream.rwByte(FTargetPlayer, 32);
end;
procedure TUnitSpellTE.Initialize(SpellID: Integer; Source: TAbstractUnit; Targets: TUnitList; Mana: Integer);
var
  I: Integer;
begin
  FEventSpellID := SpellID;
  FEventPlayerIndex := Source.FPlayer;
  FEventSourceID := Source.FUnitID;
  FEventMana := Mana;
  if (Targets <> nil) and (Targets.GetCount <> 0) then
  begin
    FTargetPlayer := Targets.GetUnit(0).FPlayer;
    for I := 0 to Targets.GetCount - 1 do
      FTargetUnitIDs.Add(Targets.GetUnit(I).FUnitID);
  end
  else FTargetPlayer := $FF;
end;
function TUnitSpellTE.Validate(A1: THero): Boolean;
var
  I: Integer;
  Target: TAbstractUnit;
  X, Y, L, TargetX, TargetY, TargetL: Shortint;
begin
  Result := inherited Validate(A1);
  A1.GetLocation(X, Y, L);
  I := FTargetUnitIDs.Count;
  while Result and (I <> 0) do
  begin
    Dec(I);
    Target := AoWHSMap.FUnitControl.FindUnit(FTargetUnitIDs[I]);
    if Target <> nil then
    begin
      Target.GetLocation(TargetX, TargetY, TargetL);
      Result := (Target.GetHitPoints <> 0) and (Byte(Target.FPlayer) = FTargetPlayer);
      if Result then
        if TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).FTargetRange <> -1 then
          Result := dHXtoRad(X, Y, TargetX, TargetY) <=
            TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).FTargetRange;
      FTargetUnits.AddUnit(Target);
    end
    else Result := False;
  end;
end;
function TUnitSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  X, Y, L: Shortint;
  Target: TAbstractUnit;
  I: Integer;
begin
  inherited Process(A1, A2);
  if FTargetUnits.GetCount <> 0 then
  begin
    FTargetUnits.GetUnit(0).GetLocation(X, Y, L);
    AoWHSSet.FSpellControl.GetSpell(FEventSpellID).PlayDefaultCastEffects(A1.FPlayer, X, Y, L);
    for I := 0 to FTargetUnits.GetCount - 1 do
    begin
      Target := FTargetUnits.GetUnit(I);
      Target.AddRef;
      if TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).ExecuteSpell(A1, Target, FEventMana, FSpellData) then
      begin
        AoWHSSet.FSpellControl.GetSpell(FEventSpellID).CastingDone(A1, FEventMana);
        Target.Changed;
      end;
      Target.Release;
    end;
  end;
  Result := False;
end;
constructor TUnitSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAIValue := -1;
  FSpellType := stUnit;
  FAllowMultipleTargets := True;
  FTargetRange := 0;
end;
procedure TUnitSpell.GetCombatInfo(Source: TAbstractUnit; var Info: TSpellCombatInfo); { Near miss: compiler omits saved parameters after three variants. }
begin
  inherited GetCombatInfo(Source, Info);
  Info.TargetTypes := [cttFriend];
  Info.Range := -1;
end;
function TUnitSpell.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
begin Result := False; end;
function TUnitSpell.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin Result := True; end;
procedure TUnitSpell.ValidateUnitSelection(Source: TAbstractUnit; Targets: TUnitList; var Selection: Byte);
var
  I: Integer;
begin
  Selection := Selection and P4SelectionMasks[Targets.GetCount];
  for I := 0 to Targets.GetCount - 1 do
    if (Selection and (1 shl I)) <> 0 then
      if not ValidTargetUnit(Source, Targets.GetUnit(I)) then
        Selection := Selection and not (Byte(1) shl I);
end;
procedure TUnitSpell.SetupUSC(Caster: TUnitSpellCaster; Source: TAbstractUnit; Targets: TUnitList);
var
  I: Integer;
begin
  Caster.FCasterSourceID := Source.FUnitID;
  Caster.FCasterSpellID := FSpellID;
  for I := 0 to Targets.GetCount - 1 do
    if not TArmy(Targets).GetUnitConcealedForPlayer(I, Source.FPlayer) then
      Caster.FTargetUnits.AddUnit(Targets.GetUnit(I));
  Caster.FTargetUnits.SortUnits;
  Caster.FAllowMultipleTargets := FAllowMultipleTargets;
  Caster.FValidSelection := 0;
  for I := Caster.FTargetUnits.GetCount - 1 downto 0 do
    if ValidTargetUnit(Source, Caster.FTargetUnits.GetUnit(I)) then
      Caster.FValidSelection := Caster.FValidSelection or (Byte(1) shl I);
end;
function TUnitSpell.CastSpell(Source: TAbstractUnit; Targets: TUnitList): Boolean;
var
  Event: TUnitSpellTE;
begin
  ResetTargetSelection;
  if not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).GetBusy then
  begin
    Event := TUnitSpellTE.Create(nil);
    Event.Initialize(FSpellID, Source, Targets, THero(Source).CastingMana(Self));
    AoWHSMap.FTokenManager.GetTokenControl(Source.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;
procedure TUnitSpell.OnValidateTarget(Control: TTargetSelectionControl; X, Y, L: Shortint; var Valid: Boolean);
var
  Source: TAbstractUnit;
  Party: TArmyHS;
begin
  Source := AoWHSMap.FUnitControl.FindUnit(Control.FSourceUnitID);
  if Source <> nil then
  begin
    if AoWHSMap.Visible(X, Y, L, 0) then
    begin
      Party := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetArmyHS;
      if (Party <> nil) and ((Party.FArmy.FPlayer = Source.FPlayer) or
        not TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetMagicShieldActive) then
        Valid := ValidTargetParty(Source, Party)
      else Valid := False;
    end
    else Valid := False;
  end
  else ResetTargetSelection;
end;
procedure TUnitSpell.OnTargetSelectionChange(Sender: TObject);
var
  Control: TTargetSelectionControl;
  Source: TAbstractUnit;
  Party: TArmyHS;
begin
  Control := TTargetSelectionControl(Sender);
  Source := AoWHSMap.FUnitControl.FindUnit(Control.FSourceUnitID);
  if Source <> nil then
    case Control.FChange of
      tscDeactivated: ResetTargetSelection;
      tscSelected:
        if Control.FTargetX <> -1 then
        begin
          Party := TAoWMapField(AoWHSMap.MapContainer.GetField(Control.FTargetX, Control.FTargetY, Control.FTargetL)).GetArmyHS;
          if (Party <> nil) and ValidTargetParty(Source, Party) then
            TargetPartySelected(Source, Party);
        end;
    end
  else ResetTargetSelection;
end;
procedure TUnitSpell.ResetTargetSelection;
begin
  with AoWHSMap.FTargetSelection do
  begin
    FOnChange.Remove(OnTargetSelectionChange);
    Deactivate;
  end;
end;
procedure TUnitSpell.SetupTargetSelection(Source: TAbstractUnit; Control: TTargetSelectionControl);
var
  X, Y, L: Shortint;
begin
  Control.Initialize(Source);
  Control.FTargetMode := Control.FTargetMode + [tmExternalFloater];
  if FTargetRange <> -1 then
  begin
    Control.FTargetMode := Control.FTargetMode + [tmValidateDistance];
    Control.FRange := FTargetRange;
  end
  else Control.FRange := 0;
  Source.GetLocation(X, Y, L);
  Control.FSourceX := X;
  Control.FSourceY := Y;
  Control.FSourceL := L;
  Control.FOnChange.Add(OnTargetSelectionChange);
  Control.FOnValidateTarget := OnValidateTarget;
  Control.FText.Text := Format(TranslateRStr(P4SelectTargetPartyForXRStr), [FSpellName]);
  Control.FTitle := FSpellName;
  Control.FCancelText := TranslateRStr(CancelRStr);
  Control.FSourceUnitID := Source.FUnitID;
  Control.FSourceImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(20).GetPreviewImage;
  Control.FValidTargetImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(21).GetPreviewImage;
  Control.FInvalidTargetImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(22).GetPreviewImage;
end;
function TUnitSpell.ValidTargetParty(Source: TAbstractUnit; Party: TArmyHS): Boolean;
begin Result := not (asFullyConcealed in Party.FArmy.FStatus); end;
procedure TUnitSpell.TargetPartySelected(Source: TAbstractUnit; Party: TArmyHS);
var
  Caster: TUnitSpellCaster;
begin
  Caster := TUnitSpellCaster.Create(nil);
  SetupUSC(Caster, Source, Party.FArmy);
  AoWHSMap.FCosmeticSurgeryEvents.TriggerNotifyEvents(Caster);
  Caster.Release;
end;
function TUnitSpell.Activate(A1: TAbstractUnit): Boolean;
var
  Caster: TUnitSpellCaster;
  Reason: string;
begin
  inherited Activate(A1);
  if CanActivate(A1, Reason) then
  begin
    if FTargetRange = 0 then
    begin
      Caster := TUnitSpellCaster.Create(nil);
      SetupUSC(Caster, A1, TUnitList(A1.Owner));
      AoWHSMap.FCosmeticSurgeryEvents.TriggerNotifyEvents(Caster);
      Caster.Release;
    end
    else
    begin
      SetupTargetSelection(A1, AoWHSMap.FTargetSelection);
      AoWHSMap.FTargetSelection.Activate;
    end;
    Result := True;
  end
  else Result := False;
end;
function TUnitSpell.CanActivateCombat(A1: TAbstractUnit; var A2: string): Boolean;
begin
  if not (sctCombat in FSpellControlTypes) or not inherited CanActivateCombat(A1, A2) then
    Result := False
  else Result := True;
end;
function TUnitSpell.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TUnitSpellCA;
begin
  if sctCombat in FSpellControlTypes then
  begin
    Action := TUnitSpellCA.Create(nil);
    Action.FSpellID := FSpellID;
    Action.FSourceID := A1.FID;
    Action.FTargetID := A2.FID;
    if A3 then Action.FMana := FBaseManaCost;
    Result := Action;
  end
  else Result := nil;
end;
function TUnitSpell.CreateCAEx(Source, Target: TCombatObject; Mana: Integer): TUnitSpellCA;
begin
  if sctCombat in FSpellControlTypes then
  begin
    Result := TUnitSpellCA.Create(nil);
    Result.FSpellID := FSpellID;
    Result.FSourceID := Source.FID;
    Result.FTargetID := Target.FID;
  end
  else Result := nil;
end;
procedure TUnitSpell.ExecuteCA(Combat: TCombat; Action: TUnitSpellCA);
var
  Source, Target: TCombatObject;
begin
  Source := Combat.FCombatData.FindID(Action.FSourceID);
  Target := Combat.FCombatData.FindID(Action.FTargetID);
  if (Source is TCombatUnit) and (Target is TCombatUnit) then
    if ExecuteSpell(TCombatUnit(Source).FUnit, TCombatUnit(Target).FUnit, Action.FMana, Action.FSpellData) then
      if (Action.FMana <> 0) and (Byte(Combat.FStatus) and 1 <> 0) then
        AoWHSSet.FSpellControl.GetSpell(FSpellID).CombatCastingDone(Source, Action.FMana);
end;
function TUnitSpell.AIRetrieveOptimalTargetUnit(Source: TAbstractUnit; Targets: TUnitList; var Target: TAbstractUnit; var Priority: Integer): Boolean;
var
  List: TDoubleItemList;
  I, Value: Integer;
begin
  List := TDoubleItemList.Create;
  for I := 0 to Targets.GetCount - 1 do
    if ValidTargetUnit(Source, Targets.GetUnit(I)) and (Targets.GetUnit(I).GetUnitType <> utMachine) then
    begin
      Value := Targets.GetUnit(I).GetUnitLevel + FAIValue;
      List.AddAB(Integer(Targets.GetUnit(I)), Value);
    end;
  if List.Count <> 0 then
  begin
    List.SortDescendingItemB;
    Target := TAbstractUnit(List[0].A);
    Priority := List[0].B;
    Result := True;
  end
  else Result := False;
  List.Free;
end;
procedure TUnitSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
var
  Action: TAICastSpellAction;
  Reason: string;
  Priority: Integer;
  Target: TAbstractUnit;
  Valid: Boolean;
begin
  if (FAIValue <> -1) and (A1.Owner is TArmy) then
  begin
    Valid := AIRequestCastSpellExpense(A1, FBaseManaCost, FManaUpkeep, 0);
    Valid := Valid and (A1.Owner is TArmy);
    Valid := Valid and THero(A1).CanCastSpell(FSpellID, Reason);
    if Valid and AIRetrieveOptimalTargetUnit(A1, TUnitList(A1.Owner), Target, Priority) then
    begin
      Action := CreateCastSpellAction;
      SetupCastSpellAction(A1, Action);
      Action.FPriority := Priority;
      Action.SetOwner(A2);
    end;
  end;
end;
function TUnitSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
var
  Reason: string;
  Priority: Integer;
  Target: TAbstractUnit;
  Targets: TUnitList;
  Event: TUnitSpellTE;
begin
  if THero(A1).CanCastSpell(FSpellID, Reason) then
  begin
    AICastSpellExpenseMade(A1, FBaseManaCost, FManaUpkeep, 0);
    if THero(A1).CanCastSpellInstantly(FSpellID, FBaseManaCost, Reason) then
    begin
      Targets := TUnitList(A1.Owner);
      if AIRetrieveOptimalTargetUnit(A1, Targets, Target, Priority) then
      begin
        Event := TUnitSpellTE.Create(nil);
        Event.Initialize(FSpellID, A1, nil, FBaseManaCost);
        Event.FTargetPlayer := Byte(A1.FPlayer);
        Event.FTargetUnitIDs.Add(Target.FUnitID);
        AoWHSMap.FTokenManager.GetTokenControl(A1.FPlayer).AddEvent(Event);
        Event.Release;
        Result := True;
      end
      else Result := False;
    end
    else if THero(A1).FCastingSpellID <> FSpellID then
    begin
      THero(A1).ExecuteStartCasting(FSpellID);
      Result := True;
    end
    else Result := True;
  end
  else Result := False;
end;
{ TResearchSpellAIPA: instance size 20; inherited $0C player control. }
class function TResearchSpellAIPA.Priority: Integer;
begin Result := 22; end;
function TResearchSpellAIPA.Process: Boolean;
var
  Choices: TDoubleItemList;
  Spells: TSpellList;
  Value, I, Index: Integer;
begin
  if (FControl.FPlayer.FPlayerIndex <> 0) and (FControl.FPlayer.FMagicControl.FResearchSpellID = 0) then
  begin
    Spells := TSpellList.Create;
    Choices := TDoubleItemList.Create;
    FControl.FPlayer.FMagicControl.ListResearchSpells(Spells, [stCombat, stUnit, stGlobal]);
    for I := 0 to Spells.GetCount - 1 do
    begin
      Value := Spells.GetSpell(I).FCastDuration * 100 + 100; Value := Value -
        FControl.FPlayer.FMagicControl.ResearchTurns(FControl.FPlayer.FMagicControl.GetNetPowerToResearch,
          Spells.GetSpell(I).FResearchCost);
      if Value <= 0 then Value := 1;
      Choices.AddAB(Spells.GetSpell(I).FSpellID, Value);
    end;
    if Choices.Count <> 0 then
    begin
      RandSeed := AoWHSMap.Random($FFFFFF);
      Index := Choices.RandomChanceItemB(0);
      FControl.FPlayer.FMagicControl.ExecuteResearchSpell(Choices[Index].A);
    end;
    Choices.Free;
    Spells.Free;
  end;
  Result := False;
end;
{ TAICastSpellActionList: instance size 12; inherited $08 children. }
function TAICastSpellActionList.GetCastSpellActions(A1: Integer): TAICastSpellAction;
begin Result := TAICastSpellAction(FChildren.List^[A1]); end;
function P4CompareCastSpellPriority(Item1, Item2: Pointer): Integer;
begin Result := TAICastSpellAction(Item2).FPriority - TAICastSpellAction(Item1).FPriority; end;
procedure TAICastSpellActionList.SortOnPriority;
begin FChildren.Sort(P4CompareCastSpellPriority); end;
{ TCastSpellAIPA: instance size 40; $14 state, $18 casting heroes,
  $1C idle heroes, $20 pending hero IDs, $24 candidate actions. }
constructor TCastSpellAIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCastingHeroes := TIntegerList.Create;
  FIdleHeroes := TIntegerList.Create;
  FPendingHeroes := TIntegerList.Create;
  FCastSpellActions := TAICastSpellActionList.Create(nil);
end;
destructor TCastSpellAIPA.Destroy;
begin
  FIdleHeroes.Free;
  FCastingHeroes.Free;
  FPendingHeroes.Free;
  FCastSpellActions.Free;
  inherited Destroy;
end;
class function TCastSpellAIPA.Priority: Integer;
begin Result := 23; end;
function TCastSpellAIPA.Activate: Boolean;
var
  Player: TPlayer;
  Hero: THero;
  I: Integer;
begin
  Result := inherited Activate;
  Player := FControl.FPlayer;
  if Player.FPlayerIndex <> 0 then
  begin
    FState := 0;
    for I := 0 to Player.FHeroes.GetCount - 1 do
    begin
      Hero := Player.FHeroes.GetHero(I);
      if Hero.GetAbilityEnabled(52) and (Hero.Owner <> nil) then
        if Hero.FCastingSpellID = 0 then FIdleHeroes.Add(Hero.FUnitID)
        else FCastingHeroes.Add(Hero.FUnitID);
    end;
  end;
end;
procedure TCastSpellAIPA.PrefetchCastSpellActions(Hero: THero);
var
  Spells: TSpellList;
  I: Integer;
begin
  Spells := TSpellList.Create;
  FControl.FPlayer.FMagicControl.ListSpells(Spells, [stUnit, stGlobal]);
  for I := 0 to Spells.GetCount - 1 do
    if Hero.CastingTurns(Spells.GetSpell(I)) < 8 then
      Spells.GetSpell(I).AIPrefetchCastSpellActions(Hero, FCastSpellActions);
  Spells.Free;
end;
function TCastSpellAIPA.CastingHeroesMax: Integer;
var
  Player: TPlayer;
begin
  Player := FControl.FPlayer;
  Result := Player.FMagicControl.FMana div 250 + 1;
end;
procedure TCastSpellAIPA.ProcessStates;
var
  Hero: THero;
  Done: Boolean;
  I, Index: Integer;
begin
  case FState of
    0:
      if FCastingHeroes.Count <> 0 then
      begin
        FPendingHeroes.Assign(FCastingHeroes);
        Inc(FState);
      end
      else FState := 2;
    1:
      if FPendingHeroes.Count <> 0 then
      begin
        Done := False;
        Hero := THero(AoWHSMap.FUnitControl.FindUnit(FPendingHeroes[0]));
        if (Hero <> nil) and (Hero.Owner <> nil) and (Byte(Hero.FUnitStatus) and $10 = 0) then
        begin
          if Hero.FCastingSpellID <> 0 then
            Done := AoWHSSet.FSpellControl.GetSpell(Hero.FCastingSpellID).AIExecuteCastSpellAction(Hero);
          if not Done then
          begin
            FIdleHeroes.Add(Hero.FUnitID);
            FCastingHeroes.Remove(Hero.FUnitID);
            Hero.ExecuteCancelCasting;
          end;
        end;
        FPendingHeroes.Delete(0);
      end
      else Inc(FState);
    2:
      if (FCastingHeroes.Count < CastingHeroesMax) and (FIdleHeroes.Count <> 0) then
      begin
        FPendingHeroes.Assign(FIdleHeroes);
        FCastSpellActions.Clear;
        Inc(FState);
      end
      else FState := -1;
    3:
      if FPendingHeroes.Count <> 0 then
      begin
        Hero := THero(AoWHSMap.FUnitControl.FindUnit(FPendingHeroes[0]));
        if (Hero <> nil) and (Byte(Hero.FUnitStatus) and $10 = 0) then
          PrefetchCastSpellActions(Hero);
        FPendingHeroes.Delete(0);
      end
      else Inc(FState);
    4:
      if FCastSpellActions.GetCount <> 0 then
      begin
        FCastSpellActions.SortOnPriority;
        Done := False;
        while not Done and (FCastSpellActions.GetCount <> 0) do
        begin
          I := 0;
          while (I < FCastSpellActions.GetCount) and
            (FCastSpellActions.GetCastSpellActions(I).FPriority >=
              FCastSpellActions.GetCastSpellActions(0).FPriority * 0.75) do Inc(I);
          Index := AoWHSMap.Random(I);
          Hero := THero(AoWHSMap.FUnitControl.FindUnit(FCastSpellActions.GetCastSpellActions(Index).FSourceUnitID));
          if (Hero <> nil) and (Byte(Hero.FUnitStatus) and $10 = 0) then
            if AoWHSSet.FSpellControl.GetSpell(FCastSpellActions.GetCastSpellActions(Index).FSpellID).AIExecuteCastSpellAction(Hero) then
            begin
              FCastingHeroes.Add(Hero.FUnitID);
              FIdleHeroes.Remove(Hero.FUnitID);
              Done := True;
            end;
          FCastSpellActions.GetCastSpellActions(Index).Free;
        end;
        if Done then FState := 2
        else FState := -1;
      end
      else FState := -1;
  end;
end;
function TCastSpellAIPA.Process: Boolean;
var
  Player: TPlayer;
begin
  Player := FControl.FPlayer;
  if Player.FPlayerIndex <> 0 then
  begin
    while (FState <> -1) and (AoWHSMap.FAIExecuter.GetProcessTimeLeft > 0) and not Player.GetBusy do
      ProcessStates;
    Result := FState <> -1;
  end
  else Result := False;
end;
{ TEnchantment: instance size 24; $08 ID, $0C source, $10 upkeep, $14 dispel resistance. }
constructor TEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDispelResistance := 10;
  FUpkeep := 1;
  FSource := -1;
  FEnchantmentID := 0;
end;
function TEnchantment.GetName: string;
begin Result := TranslateRStr(P4UndefinedRStr); end;
function TEnchantment.GetBinding: string;
begin Result := TranslateRStr(NoneRStr); end;
procedure TEnchantment.GetLocation(var A1, A2, A3: Shortint);
begin A1 := -1; A2 := -1; A3 := -1; end;
function TEnchantment.CenterToLocation: Boolean;
var
  X, Y, L: Shortint;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
  begin
    if AoWHSMap.Visible(X, Y, L, 0) then
    begin
      AoWHSMap.CenterViewTo(X, Y, L);
      AoWHSMap.PlayCenterAnimation(X, Y, L);
    end
    else
      AoWHSMap.ShowMessage(Format(TranslateRStr(XIsOutOfSightRStr), [GetBinding]));
    Result := True;
  end
  else Result := False;
end;
procedure TEnchantment.Select;
begin CenterToLocation; end;
procedure TEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FDispelResistance), 10);
  Stream.rwByte(Byte(FSource), 11);
  Stream.rwInteger(FUpkeep, 12);
  Stream.rwInteger(FEnchantmentID, 13);
end;
procedure TEnchantment.SetUpkeep(A1: Integer);
begin
  if A1 <> FUpkeep then
  begin
    FUpkeep := A1;
    if FSource > -1 then AoWHSMap.FPlayers.GetPlayers(FSource).FMagicControl.Update;
  end;
end;
procedure TEnchantment.SetSource(Player: Shortint);
begin
  if Player <> FSource then
  begin
    if FSource > -1 then AoWHSMap.FPlayers.GetPlayers(FSource).FMagicControl.UnregisterEnchantment(Self);
    FSource := Player;
    if FSource > -1 then AoWHSMap.FPlayers.GetPlayers(FSource).FMagicControl.RegisterEnchantment(Self);
  end;
end;
function TEnchantment.Dispel: Boolean;
begin Result := False; end;
function TEnchantment.DispelChance(A1: Integer): Integer;
begin
  Result := A1 - FDispelResistance * 10 + 50;
  if Result < 10 then Result := 10;
  if Result > 90 then Result := 90;
end;
function TEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 0; end;
{ TEnchantmentList: instance size 12; inherited $08 children. }
function TEnchantmentList.GetEnchantments(A1: Integer): TEnchantment;
begin Result := TEnchantment(FChildren.List^[A1]); end;
function TEnchantmentList.IndexOfID(A1: Integer): Integer;
begin
  Result := GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    if TEnchantment(FChildren.List^[Result]).FEnchantmentID = A1 then Exit;
  end;
  Result := -1;
end;
function TEnchantmentList.FindID(A1: Integer): TEnchantment;
var
  Index: Integer;
begin
  Index := IndexOfID(A1);
  if Index <> -1 then Result := TEnchantment(FChildren.List^[Index])
  else Result := nil;
end;
function TPowerSource.Name: string;
begin
  Result := '';
end;
function TPowerSource.Power: Integer;
asm
  XOR EAX, EAX
end;
procedure TPowerSource.GetLocation(var A1, A2, A3: Shortint);
begin
  A1 := -1;
  A2 := -1;
  A3 := -1;
end;
procedure TPowerSource.CenterToLocation;
var
  X, Y, L: Shortint;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
  begin
    AoWHSMap.CenterViewTo(X, Y, L);
    AoWHSMap.PlayCenterAnimation(X, Y, L);
  end;
end;



















procedure TPowerSource.Select;
begin end;
function TPowerSourceList.GetItems(A1: Integer): TPowerSource;
begin Result := TPowerSource(FChildren.List^[A1]); end;
procedure P4TranslateInto(const S: string; var Dest: string); assembler;
{ needs: P1 TranslateRStr has a string result at EDX; 5577C2D4. }
asm
  JMP TranslateRStr
end;
function TExternalPowerSource.Name: string;
begin
  P4TranslateInto(P4ExternalPowerRStr, Result);
end;
function TExternalPowerSource.Power: Integer;
{ The external control's unmarked P1 fields retain their existing declaration. }
asm
  MOV EAX, [EAX].TExternalPowerSource.FExternalPowerControl
  MOV EAX, [EAX + $1C]
end;
{ TPlayerMagicEventLog: instance size 44; $18 mode, $1C location,
  $20 spell ID, $24 value, $28 enchantment name. }
constructor TPlayerMagicEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FLocation.XYL := $FFFFFF;
end;
class function TPlayerMagicEventLog.ClassID: Integer;
begin Result := $202F0; end;
procedure TPlayerMagicEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FMode, 1, 20);
  Stream.rwInteger(FSpellID, 21);
  Stream.rwInteger(FValue, 22);
  Stream.rwString(FEnchantmentName, 23);
  Stream.rwInteger(FLocation.XYL, 24);
end;
procedure TPlayerMagicEventLog.ViewLocation;
var
  X: Shortint;
begin
  X := FLocation.X;
  if X <> -1 then
  begin
    AoWHSMap.CenterViewTo(X, FLocation.Y, FLocation.L);
    AoWHSMap.PlayCenterAnimation(FLocation.X, FLocation.Y, FLocation.L);
  end;
end;
function TPlayerMagicEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var
  Show: Boolean;
begin
  case FMode of
    pmemOutOfMana: Show := Trigger = etUser;
    pmemSpellResearched:
      if Trigger <> etUser then
        if AoWHSMap.FPlayMode = pmTurn then
          Show := wpSpellResearched in AoWEngine.FRegistry.GetClassicWindowPopupEvents
        else Show := wpSpellResearched in AoWEngine.FRegistry.GetSimultaneousWindowPopupEvents
      else Show := True;
    pmemStartResearch: Show := True;
  else Show := False;
  end;
  if Show then Result := inherited Execute(Mode, Trigger, Done)
  else Result := False;
end;
function TPlayerMagicEventLog.GetText: string;
begin
  case FMode of
    pmemSpellResearched:
      Result := Format(TranslateRStr(P4XResearchedRStr), [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]);
    pmemOutOfMana:
      if AoWHSMap.FSeatedPlayer = FPlayer then
        Result := Format(TranslateRStr(P4XRemovedOutOfManaRStr), [FEnchantmentName])
      else Result := Format(TranslateRStr(P4XRemovedRStr), [FEnchantmentName]);
  end;
end;
{ TPlayerMagicControl: instance size 76; $08 next enchantment ID, $0C cheat,
  $10 player, $14 update count, $18 external mana, $1C external power,
  $20 external source, $24 mana, $28 spheres, $2C research percentage,
  $30 spells, $34 research spell, $38 points, $3C enchantments,
  $40 power sources, $44/$45 active/enemy enchantments, $48 change events. }
constructor TPlayerMagicControl.Create(AOwner: Engine.TECustomNode); { Near miss: single-use source local is optimized away after three variants. }
var
  Source: TExternalPowerSource;
begin
  inherited Create(AOwner);
  FSpells := TIntegerList.Create;
  FChangedEvents := TEventList.Create;
  FEnchantments := TEnchantmentList.Create(nil);
  FPowerSources := TPowerSourceList.Create(nil);
  Source := TExternalPowerSource.Create(nil);
  FExternalPowerSource := Source;
  Source.FExternalPowerControl := Self;
  FPowerSources.AddChild(Source);
  FResearchPointsLeft := 0;
  FResearchSpellID := 0;
  FResearchPercentage := 50;
  FSpheres := [msCosmos..msSecret];
  FNextEnchantmentID := 1;
end;
destructor TPlayerMagicControl.Destroy;
begin
  try
    FSpells.Free;
    FEnchantments.Free;
    FChangedEvents.Free;
    FPowerSources.RemoveChild(FExternalPowerSource);
    if (FPowerSources.GetCount <> 0) and (msDestroying in AoWHSMap.Status) then
      try
        raise Exception.Create('oohps');
      except
        { Original bug: the diagnostic exception is swallowed. }
      end;
    FPowerSources.Free;
    FExternalPowerSource.Free;
    inherited Destroy;
  except
    { Original bug: cleanup errors are silently swallowed. }
  end;
end;
procedure TPlayerMagicControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FMana, 20);
  Stream.rwIntegerEx(FResearchPercentage, 50, 21);
  Stream.rwStreamProc(22, FSpells.LoadFromStream, FSpells.SaveToStream);
  Stream.rwInteger(FResearchSpellID, 23);
  Stream.rwInteger(FResearchPointsLeft, 24);
  Stream.rwEObject(FEnchantments, 25);
  Stream.rwData(FActiveEnchantments, 1, 26);
  Stream.rwInteger(FExternalMana, 27);
  Stream.rwInteger(FExternalPower, 28);
  Stream.rwBool(FCheatEnabled, 29);
  Stream.rwInteger(FNextEnchantmentID, 30);
end;
function TPlayerMagicControl.GetCheatEnabled: Boolean;
begin
  if FPlayer.FPlayerType = ptHuman then Result := FCheatEnabled
  else Result := False;
end;
procedure TPlayerMagicControl.SetActiveEnchantments(Value: TPlayerEnchantmentTypes);
var
  I: Integer;
begin
  FActiveEnchantments := Value;
  for I := AoWHSMap.FPlayers.GetCount - 1 downto 1 do
    if I <> FPlayer.FPlayerIndex then
      AoWHSMap.FPlayers.GetPlayers(I).FMagicControl.UpdateEnemyEnchantments;
end;
procedure TPlayerMagicControl.UpdateEnemyEnchantments;
var
  I: Integer;
  Magic: TPlayerMagicControl;
begin
  FEnemyEnchantments := [];
  for I := AoWHSMap.FPlayers.GetCount - 1 downto 1 do
    if I <> FPlayer.FPlayerIndex then
      if AoWHSMap.FPlayers.GetPlayers(I).FDiplomaticRelations.GetDiplomaticRelation(FPlayer.FPlayerIndex) = drWar then
      begin
        Magic := AoWHSMap.FPlayers.GetPlayers(I).FMagicControl;
        if petWaterMastery in Magic.FActiveEnchantments then FEnemyEnchantments := FEnemyEnchantments + [petWaterMastery];
        if petLifeMastery in Magic.FActiveEnchantments then FEnemyEnchantments := FEnemyEnchantments + [petLifeMastery];
        if petDeathMastery in Magic.FActiveEnchantments then FEnemyEnchantments := FEnemyEnchantments + [petDeathMastery];
        if petAirMastery in Magic.FActiveEnchantments then FEnemyEnchantments := FEnemyEnchantments + [petAirMastery];
      end;
end;
function TPlayerMagicControl.GetManaIncome: Integer;
begin Result := GetNetPowerToMana; end;
function TPlayerMagicControl.GetManaUpkeep: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FEnchantments.GetCount - 1 downto 0 do
    Inc(Result, FEnchantments.GetEnchantments(I).FUpkeep);
  Inc(Result, AoWHSMap.FGlobalMagicControl.GetEnchantmentUpkeep(FPlayer.FPlayerIndex));
end;
procedure TPlayerMagicControl.SetMana(A1: Integer);
begin
  if A1 < 0 then A1 := 0;
  if A1 <> FMana then
  begin
    FMana := A1;
    if (AoWHSMap.FVictoryCondition = vcAccumulateMana) and (AoWHSMap.FVictoryMana <= FMana) then
      AoWHSMap.GameOver(FPlayer.FPlayerIndex, goWon);
    Update;
  end;
end;
function TPlayerMagicControl.GetPower: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FPowerSources.GetCount - 1 downto 0 do
    Inc(Result, FPowerSources.GetItems(I).Power);
end;
procedure TPlayerMagicControl.OutOfMana(A1: Integer);
var
  I, Index: Integer;
  Log: TPlayerMagicEventLog;
begin
  while (A1 > 0) and (FEnchantments.GetCount <> 0) do
  begin
    I := FEnchantments.GetCount;
    Index := I - 1;
    while I <> 0 do
    begin
      Dec(I);
      if FEnchantments.GetEnchantments(I).FUpkeep < FEnchantments.GetEnchantments(Index).FUpkeep then Index := I;
    end;
    if Index <> -1 then
    begin
      Dec(A1, FEnchantments.GetEnchantments(Index).FUpkeep);
      Log := TPlayerMagicEventLog.Create(nil);
      Log.FPlayer := FPlayer.FPlayerIndex;
      Log.FMode := pmemOutOfMana;
      FEnchantments.GetEnchantments(Index).GetLocation(Log.FLocation.X, Log.FLocation.Y, Log.FLocation.L);
      Log.FEnchantmentName := FEnchantments.GetEnchantments(Index).GetName;
      AoWHSMap.FPlayers.GetPlayers(FPlayer.FPlayerIndex).FEventLogbook.AddEvent(Log);
      Log.Release;
      ExecuteDispelEnchantment(Index);
    end;
  end;
  if A1 > 0 then AoWHSMap.FGlobalMagicControl.OutOfMana(Byte(FPlayer.FPlayerIndex), A1);
end;
procedure TPlayerMagicControl.RemoveEnchantments;
begin
  while FEnchantments.GetCount <> 0 do ExecuteDispelEnchantment(FEnchantments.GetCount - 1);
end;
function TPlayerMagicControl.ValidateEnchantmentsUpkeep: Boolean;
var
  Balance: Integer;
begin
  Balance := FMana + GetManaIncome - GetManaUpkeep;
  if (Balance < 0) and (GetManaUpkeep <> 0) then Result := False
  else Result := True;
end;
function TPlayerMagicControl.ExecuteSpellResearched(A1: Integer): Boolean;
begin
  if FSpells.IndexOf(A1) = -1 then FSpells.Add(A1);
  if A1 = FResearchSpellID then
  begin
    FResearchPointsLeft := 0;
    FResearchSpellID := 0;
  end;
  Result := True;
end;
procedure TPlayerMagicControl.NewTurn;
var
  Kind: TSpellType;
  Candidates: TIntegerList;
  I, Index: Integer;
  Spell: TSpell;
  Log: TPlayerMagicEventLog;
begin
  if (AoWHSMap.FDay = 1) and (FPlayer.FPlayerIndex <> 0) and
    ((AoWHSMap.FGameType <> gtCampaign) or (FSpells.Count = 0)) then
  begin
    Candidates := TIntegerList.Create;
    for Kind := Low(TSpellType) to High(TSpellType) do
    begin
      Candidates.Clear;
      for I := 0 to AoWHSSet.FSpellControl.GetCount - 1 do
      begin
        Spell := AoWHSSet.FSpellControl.GetSpell(I);
        if (Spell <> nil) and (FSpells.IndexOf(I) = -1) and (Spell.FSpellType = Kind) and
          ((Spell.FMagicSphere = msCosmos) or (FPlayer.FLeader.GetSpherePicks(Spell.FMagicSphere) > 0)) and
          (Spell.FSpellLevel = 1) then Candidates.Add(I);
      end;
      if Candidates.Count > 0 then
      begin
        Index := AoWHSMap.Random(Candidates.Count);
        FSpells.Add(Candidates[Index]);
      end;
    end;
    Candidates.Free;
  end;
  if FResearchSpellID <> 0 then
  begin
    if FSpells.IndexOf(FResearchSpellID) = -1 then
    begin
      Dec(FResearchPointsLeft, GetNetPowerToResearch);
      if FResearchPointsLeft <= 0 then
      begin
        if FResearchPointsLeft < 0 then Inc(FMana, Abs(FResearchPointsLeft));
        Log := TPlayerMagicEventLog.Create(nil);
        Log.FPlayer := FPlayer.FPlayerIndex;
        Log.FMode := pmemSpellResearched;
        Log.FSpellID := FResearchSpellID;
        FPlayer.FEventLogbook.AddEvent(Log);
        ExecuteSpellResearched(FResearchSpellID);
        if (FPlayer.FPlayerIndex = AoWHSMap.FSeatedPlayer) and (FPlayer.FPlayerType = ptHuman) then
          Log.Execute(False, etEvent, nil);
        Log.Release;
      end;
    end
    else
    begin
      FResearchSpellID := 0;
      Inc(FMana, GetNetPowerToResearch);
    end;
  end
  else Inc(FMana, GetNetPowerToResearch);
  FMana := FMana + GetManaIncome - GetManaUpkeep;
  if FMana < 0 then
  begin
    OutOfMana(-FMana);
    FMana := 0;
  end;
  { Original bug: SetMana sees the value already stored and skips its victory check. }
  SetMana(FMana);
  Update;
end;
procedure TPlayerMagicControl.SetSpheres(Value: TMagicSpheres);
begin
  if (Value * [msEarth, msAir] <> [msEarth, msAir]) and
    (Value * [msFire, msWater] <> [msFire, msWater]) and
    (Value * [msLife, msDeath] <> [msLife, msDeath]) then FSpheres := Value;
end;
function TPlayerMagicControl.GetNetPower: Integer;
begin
  Result := GetPower;
  if getPowerLeak in AoWHSMap.FGlobalMagicControl.FActiveEnchantments then Result := (Result + 1) div 2;
end;
function TPlayerMagicControl.GetNetPowerToMana: Integer;
begin
  Result := GetNetPower - GetNetPowerToResearch;
  case FPlayer.FPlayerType of
    ptCPU2: Result := Round(Result * 1.25);
    ptCPU3: Result := Round(Result * 1.5);
    ptCPU4: Result := Round(Result * 1.75);
    ptCPU5: Result := Round(Result * 2.0);
  end;
end;
function TPlayerMagicControl.GetNetPowerToResearch: Integer;
begin Result := Round(GetNetPower * FResearchPercentage * 0.01); end;
function TPlayerMagicControl.ResearchTurns(Power, Points: Integer): Integer;
begin
  if Power > 0 then
  begin
    Result := Points div Power;
    if Points mod Power <> 0 then Inc(Result);
  end
  else Result := 999;
end;
function TPlayerMagicControl.GetResearchTurnsLeft: Integer;
begin
  Result := ResearchTurns(GetNetPowerToResearch, FResearchPointsLeft);
end;
function TPlayerMagicControl.ValidResearchSpell(Spell: TSpell): Boolean;
var
  Counts: array[1..4] of Integer;
  I, Level: Integer;
  Known: TSpell;
begin
  if (FPlayer.FLeader.GetSpherePicks(Spell.FMagicSphere) >= Spell.FSpellLevel) and
    (FSpells.IndexOf(Spell.FSpellID) = -1) then
  begin
    FillChar(Counts, SizeOf(Counts), 0);
    for I := FSpells.Count - 1 downto 0 do
    begin
      Known := AoWHSSet.FSpellControl.GetSpell(FSpells[I]);
      if (Known.FSpellLevel > 0) and Known.GetEnabled and
        (Spell.FMagicSphere = Known.FMagicSphere) then Inc(Counts[Known.FSpellLevel]);
    end;
    Level := 1;
    while (Counts[Level] >= 2) and (Level < 4) do Inc(Level);
    if AoWEngine.FDemo then Level := 2;
    Result := Level >= Spell.FSpellLevel;
  end
  else Result := False;
end;
procedure TPlayerMagicControl.ListResearchSpells(var List: TSpellList; SpellTypes: TSpellTypes);
var
  I: Integer;
  Spell: TSpell;
begin
  for I := 0 to AoWHSSet.FSpellControl.GetCount - 1 do
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(I);
    if (Spell <> nil) and (Spell.FSpellType in SpellTypes) and ValidResearchSpell(Spell) then
      List.Add(Spell);
  end;
end;
procedure TPlayerMagicControl.ListSpells(var List: TSpellList; SpellTypes: TSpellTypes);
var
  I: Integer;
  Spell: TSpell;
begin
  if FCheatEnabled and (FPlayer.FPlayerType = ptHuman) then
  begin
    for I := 0 to AoWHSSet.FSpellControl.GetCount - 1 do
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(I);
      if (Spell <> nil) and Spell.GetEnabled and (Spell.FSpellType in SpellTypes) then List.Add(Spell);
    end;
  end
  else
    for I := 0 to FSpells.Count - 1 do
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(FSpells[I]);
      if (Spell <> nil) and Spell.GetEnabled and (Spell.FSpellType in SpellTypes) then List.Add(Spell);
    end;
end;
procedure TPlayerMagicControl.BeginUpdate;
begin Inc(FUpdateCount); end;
procedure TPlayerMagicControl.EndUpdate;
begin Dec(FUpdateCount); if FUpdateCount = 0 then Update; end;
procedure TPlayerMagicControl.Update;
begin
  if FUpdateCount = 0 then
  begin
    UpdateEnemyEnchantments;
    FChangedEvents.TriggerNotifyEvents(Self);
  end;
end;
procedure TPlayerMagicControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayer.FPlayerIndex) then NewTurn;
  FEnchantments.MsgProc(Msg, Sender);
end;
procedure TPlayerMagicControl.ValidateEnchantmentID(Enchantment: TEnchantment);
var
  ID: Integer;
begin
  { Preserve a valid unused ID before allocating a new one. }
  if (Enchantment.FEnchantmentID <> 0) and (Enchantment.FEnchantmentID shr 24 = FPlayer.FPlayerIndex) then
  begin
    ID := Enchantment.FEnchantmentID;
    Enchantment.FEnchantmentID := 0;
    if FEnchantments.IndexOfID(ID) = -1 then Enchantment.FEnchantmentID := ID;
  end else Enchantment.FEnchantmentID := 0;
  if Enchantment.FEnchantmentID = 0 then
  begin
    if FNextEnchantmentID = 0 then FNextEnchantmentID := 1;
    ID := FPlayer.FPlayerIndex shl 24 + FNextEnchantmentID;
    Inc(FNextEnchantmentID);
    if FNextEnchantmentID > $FFFFF then FNextEnchantmentID := 1;
    while FEnchantments.IndexOfID(ID) <> -1 do
    begin
      ID := FPlayer.FPlayerIndex shl 24 + FNextEnchantmentID;
      Inc(FNextEnchantmentID);
      if FNextEnchantmentID > $FFFFF then FNextEnchantmentID := 1;
    end;
    Enchantment.FEnchantmentID := ID;
  end;
end;
function TPlayerMagicControl.RegisterEnchantment(Enchantment: TEnchantment): Boolean;
begin
  if FEnchantments.FChildren.IndexOf(Enchantment) = -1 then
  begin
    FEnchantments.AddChild(Enchantment);
    ValidateEnchantmentID(Enchantment);
    Update;
    Result := True;
  end
  else Result := False;
end;
function TPlayerMagicControl.UnregisterEnchantment(Enchantment: TEnchantment): Boolean;
begin
  Result := FEnchantments.FChildren.Remove(Enchantment) <> -1;
  if Result then Update;
end;
function TPlayerMagicControl.RegisterPowerSource(Source: TPowerSource): Boolean;
begin
  if FPowerSources.FindChildIndex(Source) = -1 then
  begin
    FPowerSources.AddChild(Source);
    Update;
    Result := True;
  end
  else Result := False;
end;
function TPlayerMagicControl.UnregisterPowerSource(Source: TPowerSource): Boolean;
begin
  Result := FPowerSources.RemoveChild(Source) <> -1;
  if Result then Update;
end;
function TPlayerMagicControl.CreateChangeMagicTE: TChangePlayerMagicTE;
begin
  Result := TChangePlayerMagicTE.Create(nil);
  Result.FPlayerIndex := FPlayer.FPlayerIndex;
end;
function TPlayerMagicControl.ExecuteDispelEnchantment(Index: Integer): Boolean;
begin
  if Index < FEnchantments.GetCount then Result := FEnchantments.GetEnchantments(Index).Dispel
  else Result := False;
end;
function TPlayerMagicControl.DispelEnchantment(Enchantment: TEnchantment): Boolean;
var
  Index: Integer;
  Event: TChangePlayerMagicTE;
begin
  Index := FEnchantments.FChildren.IndexOf(Enchantment);
  if not FPlayer.GetBusy and (Index <> -1) then
  begin
    Event := CreateChangeMagicTE;
    Event.FMode := cmmDispelEnchantment;
    Event.FValue := Index;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer.FPlayerIndex).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;
function TPlayerMagicControl.ExecuteChangePowerSettings(Percentage: Integer): Boolean;
begin
  FResearchPercentage := Percentage;
  Update;
  Result := True;
end;
function TPlayerMagicControl.ChangePowerSettings(Percentage: Integer): Boolean;
var
  Event: TChangePlayerMagicTE;
begin
  if not FPlayer.GetBusy then
  begin
    if Percentage <> FResearchPercentage then
    begin
      Event := CreateChangeMagicTE;
      Event.FMode := cmmChangePowerSettings;
      Event.FValue := Percentage;
      AoWHSMap.FTokenManager.GetTokenControl(FPlayer.FPlayerIndex).AddEvent(Event);
      Event.Release;
    end;
    Result := True;
  end
  else Result := False;
end;
function TPlayerMagicControl.ExecuteResearchSpell(SpellID: Integer): Boolean;
begin
  if (FSpells.IndexOf(SpellID) = -1) and (SpellID <> FResearchSpellID) then
  begin
    FResearchSpellID := SpellID;
    if SpellID <> 0 then FResearchPointsLeft := AoWHSSet.FSpellControl.GetSpell(SpellID).FResearchCost
    else FResearchPointsLeft := 0;
    Update;
    Result := True;
  end
  else Result := False;
end;
function TPlayerMagicControl.ResearchSpell(SpellID: Integer): Boolean;
var
  Event: TChangePlayerMagicTE;
begin
  if not FPlayer.GetBusy then
  begin
    Event := CreateChangeMagicTE;
    Event.FMode := cmmResearchSpell;
    Event.FValue := SpellID;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer.FPlayerIndex).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;
function TPlayerMagicControl.AIRequestOverrideUpkeep(Priority: Integer): Integer;
var
  I: Integer;
  Enchantment: TGlobalEnchantment; GlobalControl: TGlobalMagicControl;
begin
  Result := 0;
  for I := 0 to FEnchantments.GetCount - 1 do
    if Priority >= FEnchantments.GetEnchantments(I).GetAIUpkeepPriority then
      Inc(Result, FEnchantments.GetEnchantments(I).FUpkeep);
  { Original bug: this estimate also counts global enchantments owned by other players. }
  GlobalControl := AoWHSMap.FGlobalMagicControl; for I := GlobalControl.FEnchantments.GetCount - 1 downto 0 do
  begin
    Enchantment := AoWHSMap.FGlobalMagicControl.FEnchantments.GetEnchantments(I);
    if Priority >= Enchantment.GetAIUpkeepPriority then Inc(Result, Enchantment.GetUpkeep);
  end;
end;
function TPlayerMagicControl.AIOverrideUpkeep(Priority, Amount: Integer): Integer;
var
  List: TQuadItemList;
  I, UpkeepPriority, Total: Integer;
  Enchantment: TGlobalEnchantment; GlobalControl: TGlobalMagicControl;
begin
  Result := 0;
  List := TQuadItemList.Create;
  for I := 0 to FEnchantments.GetCount - 1 do
  begin
    UpkeepPriority := FEnchantments.GetEnchantments(I).GetAIUpkeepPriority;
    if UpkeepPriority <= Priority then
      List.AddABCD(UpkeepPriority, FEnchantments.GetEnchantments(I).FUpkeep,
        Integer(FEnchantments.GetEnchantments(I)), 0);
  end;
  GlobalControl := AoWHSMap.FGlobalMagicControl; for I := GlobalControl.FEnchantments.GetCount - 1 downto 0 do
  begin
    Enchantment := AoWHSMap.FGlobalMagicControl.FEnchantments.GetEnchantments(I);
    if Enchantment.FPlayerIndex = FPlayer.FPlayerIndex then
    begin
      UpkeepPriority := Enchantment.GetAIUpkeepPriority;
      if UpkeepPriority <= Priority then
        List.AddABCD(UpkeepPriority, Enchantment.GetUpkeep, 0, Integer(Enchantment));
    end;
  end;
  if List.Count <> 0 then
  begin
    Total := 0;
    List.SortAscendingItemA;
    while (Total < Amount) and (List.Count <> 0) and (FPlayer.FGameOverStatus <> goLost) do
    begin
      Inc(Total, List[0].B);
      if List[0].C <> 0 then
        ExecuteDispelEnchantment(FEnchantments.FChildren.IndexOf(Pointer(List[0].C)))
      else
      begin
        Enchantment := TGlobalEnchantment(List[0].D);
        Enchantment.AddRef;
        Enchantment.Remove(FPlayer.FPlayerIndex);
        Enchantment.Release;
      end;
      List.Delete(0);
    end;
  end;
  List.Free;
end;
class function TChangePlayerMagicTE.ClassID: Integer;
begin Result := $21115; end;
procedure TChangePlayerMagicTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FMode, 1, 20);
  Stream.rwByte(FPlayerIndex, 21);
  Stream.rwInteger(FValue, 22);
  Stream.rwInteger(FExtraValue, 23);
end;
function TChangePlayerMagicTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Success: Boolean;
  Magic: TPlayerMagicControl;
begin
  inherited Execute(TE);
  Success := False;
  Magic := AoWHSMap.FPlayers.GetPlayers(Shortint(FPlayerIndex)).FMagicControl;
  case FMode of
    cmmDispelEnchantment: Success := Magic.ExecuteDispelEnchantment(FValue);
    cmmChangePowerSettings: Success := Magic.ExecuteChangePowerSettings(FValue);
    cmmResearchSpell: Success := Magic.ExecuteResearchSpell(FValue);
  end;
  if Success then Result := erDone else Result := erDoneHalt;
end;
constructor TGlobalEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FEnchantmentMode := [gemTrueGlobal, gemOwned];
end;
function TGlobalEnchantment.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;
function TGlobalEnchantment.Release: Integer;
var Count: Integer; begin
  Dec(FRefCount);
  Count := FRefCount; Result := Count;
  if Count = 0 then Destroy;
end;
function TGlobalEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 0; end;
function TGlobalEnchantment.GetLocation: TXYL;
begin Result.XYL := $FFFFFF; end;
procedure TGlobalEnchantment.CenterToLocation;
var
  Location: TXYL;
begin
  Location := GetLocation;
  if Location.X <> -1 then
  begin
    AoWHSMap.CenterViewTo(Location.X, Location.Y, Location.L);
    AoWHSMap.PlayCenterAnimation(Location.X, Location.Y, Location.L);
  end;
end;
function TGlobalEnchantment.GetName: string;
begin Result := FName; end;
function TGlobalEnchantment.GetUpkeep: Integer;
begin Result := FEnchantmentManaUpkeep; end;
function TGlobalEnchantment.VisibleForPlayer(Player: Shortint): Boolean;
var
  Location: TXYL;
begin
  if not (gemTrueGlobal in FEnchantmentMode) and (Player <> FPlayerIndex) then
  begin
    Location := GetLocation;
    if Location.X <> -1 then
      Result := AoWHSMap.VisibleForPlayer(Location.X, Location.Y, Location.L, Player)
    else Result := False;
  end
  else Result := True;
end;
procedure TGlobalEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FEnchantmentID, 10);
  Stream.rwData(FEnchantmentType, 1, 11);
  Stream.rwByte(Byte(FPlayerIndex), 12);
  Stream.rwString(FName, 13);
  Stream.rwInteger(FEnchantmentManaUpkeep, 14);
  Stream.rwInteger(FDispelMana, 15);
end;
procedure TGlobalEnchantment.Setup(Kind: TGlobalEnchantmentType; Name: string; Upkeep: Integer);
begin
  FEnchantmentType := Kind;
  FName := Name;
  FEnchantmentManaUpkeep := Upkeep;
end;
function TGlobalEnchantment.CanActivate(Player: Shortint; var Reason: string): Boolean;
begin
  if (FEnchantmentType <> getNone) and
    (FEnchantmentType in AoWHSMap.FGlobalMagicControl.FActiveEnchantments) then
  begin
    Reason := Format(TranslateRStr(XIsAlreadyActiveRStr), [FName]);
    Result := False;
  end
  else
  begin
    Reason := '';
    Result := True;
  end;
end;
function TGlobalEnchantment.Activate(Player: Shortint): Boolean;
begin
  FPlayerIndex := Player;
  FEnchantmentStatus := FEnchantmentStatus + [getActivated];
  AoWHSMap.FGlobalMagicControl.ValidateEnchantmentID(Self);
  if gemOwned in FEnchantmentMode then
    Owner := AoWHSMap.FGlobalMagicControl.FEnchantments
  else AoWHSMap.FGlobalMagicControl.FEnchantments.AddChild(Self);
  AddRef;
  AoWHSMap.FGlobalMagicControl.Update;
  if FEnchantmentManaUpkeep <> 0 then AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.Update;
  Result := True;
end;
function TGlobalEnchantment.CanDeactivate(Player: Byte; var Reason: string): Boolean;
begin Result := True; end;
function TGlobalEnchantment.Deactivate(Player: Byte): Boolean;
begin
  FEnchantmentStatus := FEnchantmentStatus - [getActivated];
  if gemOwned in FEnchantmentMode then Owner := nil
  else AoWHSMap.FGlobalMagicControl.FEnchantments.RemoveChild(Self);
  AoWHSMap.FGlobalMagicControl.Update;
  if FEnchantmentManaUpkeep <> 0 then AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.Update;
  Release;
  Result := True;
end;
function TGlobalEnchantment.CanCast(Player: Shortint; var Reason: string): Boolean;
begin Result := CanActivate(Player, Reason); end;
function TGlobalEnchantment.Cast(Player: Shortint): Boolean;
var
  Reason: string;
  Log: TGlobalEnchantmentEventLog;
begin
  if CanCast(Player, Reason) then
  begin
    Result := Activate(Player);
    if Result then
    begin
      Log := TGlobalEnchantmentEventLog.Create(nil);
      Log.FEnchantmentPlayer := Player;
      Log.FPlayer := Player;
      Log.FText := Format(TranslateRStr(XCastRStr), [FName]);
      DistributeEventLog(Log, False);
      Log.Release;
    end;
  end
  else Result := False;
end;
function TGlobalEnchantment.CanDispel(Player: Shortint; var Reason: string): Boolean;
begin Result := CanDeactivate(Byte(Player), Reason); end;
function TGlobalEnchantment.Dispel(Player: Byte): Boolean;
var
  Reason: string;
  Location: TXYL;
  I: Integer;
  Log: TGlobalEnchantmentEventLog;
begin
  if CanDispel(Shortint(Player), Reason) then
  begin
    AddRef;
    Location := GetLocation;
    for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
      if VisibleForPlayer(I) then
      begin
        Log := TGlobalEnchantmentEventLog.Create(nil);
        Log.FPlayer := Shortint(Player);
        Log.FEnchantmentPlayer := FPlayerIndex;
        Log.SetLocation(Location.X, Location.Y, Location.L);
        Log.FText := Format(TranslateRStr(P4XDispelledRStr), [GetName]);
        AoWHSMap.FPlayers.GetPlayers(I).FEventLogbook.AddEvent(Log);
        Log.Release;
      end;
    Result := Deactivate(Player);
    Release;
  end
  else Result := False;
end;
function TGlobalEnchantment.CanRemove(Player: Shortint; var Reason: string): Boolean;
begin
  if Player = FPlayerIndex then Result := CanDeactivate(Byte(FPlayerIndex), Reason)
  else Result := False;
end;
function TGlobalEnchantment.Remove(Player: Byte): Boolean;
var
  Reason: string;
  Location: TXYL;
  I: Integer;
  Log: TGlobalEnchantmentEventLog;
begin
  if CanRemove(Player, Reason) then
  begin
    AddRef;
    Location := GetLocation;
    for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
      if VisibleForPlayer(I) then
      begin
        Log := TGlobalEnchantmentEventLog.Create(nil);
        Log.FPlayer := FPlayerIndex;
        Log.FEnchantmentPlayer := FPlayerIndex;
        Log.SetLocation(Location.X, Location.Y, Location.L);
        Log.FText := Format(TranslateRStr(P4XRemovedRStr), [GetName]);
        AoWHSMap.FPlayers.GetPlayers(I).FEventLogbook.AddEvent(Log);
        Log.Release;
      end;
    Result := Deactivate(Byte(FPlayerIndex));
    Release;
  end
  else Result := False;
end;
class function TGlobalEnchantmentEventLog.ClassID: Integer;
begin Result := $202EB; end;
procedure TGlobalEnchantmentEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FEnchantmentPlayer), 30);
end;
function TGlobalEnchantmentEventLog.GetLeftIcon: Integer;
var Player: Shortint; begin
  Player := FEnchantmentPlayer; if (Player > 0) and (AoWHSMap.FPlayers.GetCount > Player) then
    Result := AoWHSMap.FPlayers.GetPlayers(FEnchantmentPlayer).FPlayerRace
  else Result := 12;
end;
function TGlobalEnchantmentList.GetEnchantments(A1: Integer): TGlobalEnchantment;
begin Result := FChildren.List^[A1]; end;
constructor TGlobalMagicControl.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FEnchantments := TGlobalEnchantmentList.Create(nil); FChangedEvents := TEventList.Create; FNextEnchantmentID := 1; end;
destructor TGlobalMagicControl.Destroy;
begin inherited Destroy; FEnchantments.Free; FChangedEvents.Free; end;
procedure TGlobalMagicControl.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwEObject(FEnchantments, 10); Stream.rwInteger(FNextEnchantmentID, 11); Stream.rwData(FDoubleSphereManaCount, SizeOf(FDoubleSphereManaCount), 0); UpdateActiveEnchantments; end;
procedure TGlobalMagicControl.IncDoubleSphereManaCount(A1: TMagicSphere);
begin Inc(FDoubleSphereManaCount[A1]); end;
procedure TGlobalMagicControl.DecDoubleSphereManaCount(A1: TMagicSphere);
begin Dec(FDoubleSphereManaCount[A1]); end;
function TGlobalMagicControl.GetSphereManaDoubled(A1: TMagicSphere): Boolean;
begin Result := FDoubleSphereManaCount[A1] <> 0; end;
procedure TGlobalMagicControl.OutOfMana(Player: Shortint; Mana: Integer);
var Index, I: Integer; Enchantment: TGlobalEnchantment; Log: TPlayerMagicEventLog; begin Index := 0; while (Index <> -1) and (Mana > 0) and (FEnchantments.GetCount <> 0) do begin I := FEnchantments.GetCount; Index := I - 1; { Original may select the last enchantment of another player. } while I <> 0 do begin Dec(I); if (FEnchantments.GetEnchantments(I).FPlayerIndex = Player) and (FEnchantments.GetEnchantments(I).GetUpkeep < FEnchantments.GetEnchantments(Index).GetUpkeep) then Index := I; end; if Index <> -1 then begin Enchantment := FEnchantments.GetEnchantments(Index); Dec(Mana, Enchantment.GetUpkeep); Log := TPlayerMagicEventLog.Create(nil); Log.FPlayer := Player; Log.FMode := pmemOutOfMana; Log.FEnchantmentName :=
FEnchantments.GetEnchantments(Index).GetName; DistributeEventLog(Log, False); Log.Release; Enchantment.AddRef; Enchantment.Deactivate(Player); Enchantment.Release; end; end; end;
procedure TGlobalMagicControl.RemovePlayerEnchantments(Player: Shortint);
var I: Integer; begin for I := FEnchantments.GetCount - 1 downto 0 do if Player = FEnchantments.GetEnchantments(I).FPlayerIndex then FEnchantments.GetEnchantments(I).Remove(Player); end;
procedure TGlobalMagicControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin inherited MsgProc(Msg, Sender); FEnchantments.MsgProc(Msg, Sender); end;
procedure TGlobalMagicControl.BeginUpdate;
begin Inc(FUpdateCount); end;
procedure TGlobalMagicControl.EndUpdate;
begin Dec(FUpdateCount); if FUpdateCount = 0 then Update; end;
procedure TGlobalMagicControl.TriggerChangedEvent;
begin if FUpdateCount = 0 then FChangedEvents.TriggerNotifyEvents(Self); end;
procedure TGlobalMagicControl.Update;
begin UpdateActiveEnchantments; FChangedEvents.TriggerNotifyEvents(Self); end;
function TGlobalMagicControl.GetEnchantmentUpkeep(Player: Shortint): Integer;
var I: Integer; begin Result := 0; for I := FEnchantments.GetCount - 1 downto 0 do if Player = FEnchantments.GetEnchantments(I).FPlayerIndex then Inc(Result, FEnchantments.GetEnchantments(I).GetUpkeep); end;
procedure TGlobalMagicControl.UpdateActiveEnchantments;
var I: Integer; begin FActiveEnchantments := []; for I := FEnchantments.GetCount - 1 downto 0 do FActiveEnchantments := FActiveEnchantments + [FEnchantments.GetEnchantments(I).FEnchantmentType]; end;
function TGlobalMagicControl.IndexOfID(A1: Integer): Integer;
var I: Integer; begin I := FEnchantments.GetCount; while I <> 0 do begin Dec(I); if A1 = FEnchantments.GetEnchantments(I).FEnchantmentID then begin Result := I; Exit; end; end; Result := -1; end;
function TGlobalMagicControl.ValidateEnchantmentID(Enchantment: TGlobalEnchantment): Boolean;
var ID: Integer; begin ID := Enchantment.FEnchantmentID; if ID > 0 then begin Enchantment.FEnchantmentID := 0; if IndexOfID(ID) <> -1 then ID := 0; end; if ID <= 0 then begin ID := FNextEnchantmentID; Inc(FNextEnchantmentID); if FNextEnchantmentID > $FFFFFFF then FNextEnchantmentID := 1; while IndexOfID(ID) <> -1 do begin ID := FNextEnchantmentID; Inc(FNextEnchantmentID); if FNextEnchantmentID > $FFFFFFF then FNextEnchantmentID := 1; end; end; Enchantment.FEnchantmentID := ID; Result := True; end;
function TGlobalMagicControl.CreateChangeMagicTE: TChangeGlobalMagicTE;
begin Result := TChangeGlobalMagicTE.Create(nil); end;
function TGlobalMagicControl.ExecuteDispelEnchantment(Player: Shortint; EnchantmentID: Integer): Boolean;
var Index: Integer; begin Index := IndexOfID(EnchantmentID); if Index <> -1 then Result := FEnchantments.GetEnchantments(Index).Dispel(Player) else Result := False; end;
function TGlobalMagicControl.DispelEnchantment(Player: Shortint; Enchantment: TGlobalEnchantment): Boolean;
var Event: TChangeGlobalMagicTE; Reason: string; begin if not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy and (IndexOfID(Enchantment.FEnchantmentID) <> -1) then begin if Enchantment.CanDispel(Player, Reason) then begin Event := CreateChangeMagicTE; Event.FMode := cgmDispelEnchantment; Event.FEnchantmentID := Enchantment.FEnchantmentID; Event.FPlayerIndex := Player; AoWHSMap.FTokenManager.GetTokenControl(Player).AddEvent(Event); Event.Release; Result := True; end else begin if Player = AoWHSMap.FSeatedPlayer then AoWHSMap.ShowWarning(Reason); Result := False; end; end else Result := False; end;
function TGlobalMagicControl.ExecuteRemoveEnchantment(Player: Shortint; EnchantmentID: Integer): Boolean;
var Index: Integer; begin Index := IndexOfID(EnchantmentID); if Index <> -1 then Result := FEnchantments.GetEnchantments(Index).Remove(Player) else Result := False; end;
function TGlobalMagicControl.RemoveEnchantment(Player: Shortint; Enchantment: TGlobalEnchantment): Boolean;
var Event: TChangeGlobalMagicTE; Reason: string; begin if not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy and (IndexOfID(Enchantment.FEnchantmentID) <> -1) then begin if Enchantment.CanRemove(Player, Reason) then begin Event := CreateChangeMagicTE; Event.FMode := cgmRemoveEnchantment; Event.FEnchantmentID := Enchantment.FEnchantmentID; Event.FPlayerIndex := Player; AoWHSMap.FTokenManager.GetTokenControl(Player).AddEvent(Event); Event.Release; Result := True; end else begin if Player = AoWHSMap.FSeatedPlayer then AoWHSMap.ShowWarning(Reason); Result := False; end; end else Result := False; end;
class function TChangeGlobalMagicTE.ClassID: Integer;
begin Result := $21116; end;
procedure TChangeGlobalMagicTE.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwData(FMode, SizeOf(FMode), 20); Stream.rwByte(FPlayerIndex, 21); Stream.rwInteger(FEnchantmentID, 22); Stream.rwInteger(FValue, 23); end;
function TChangeGlobalMagicTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var Success: Boolean; begin inherited Execute(TE); Success := False; case FMode of cgmDispelEnchantment: Success := AoWHSMap.FGlobalMagicControl.ExecuteDispelEnchantment(FPlayerIndex, FEnchantmentID); cgmRemoveEnchantment: Success := AoWHSMap.FGlobalMagicControl.ExecuteRemoveEnchantment(FPlayerIndex, FEnchantmentID); end; if Success then Result := erDone else Result := erDoneHalt; end; { Original road-construction predicate, $55770FF0. }
