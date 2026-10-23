unit CombatTE;

{ CombatTE, AoWTCPCK.dpl: tactical combat token events.
  Original layouts and VMT order. All handlers are recovered.
  TCombatMoveTE: $1C unit, $20 delay, $24 struck units, $28 previous unit,
  $2C free-striking unit, $30 neighbour, $31 step, $34 strike.
  TCMeleeMoveTE: $38 melee round, $3C strike index.
  Touch event: $3C ability ID. Ranged event: $14 ability ID, $18 spell ID,
  $1C/$1E source coordinates, $20/$22 target coordinates, $24 effect type,
  $28 strike count, $2C sound, $30 delay, $34 strike index, $38 state.
  Touch event: $38 effect, $40..$5C ability actions, $60 effect type,
  $61 success, $64 damage, $68 wall. }

{$O-,Q+,R+}

interface

uses AoWTC,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, CityWall;

type
  TCEndTurnTE = class;
  TCEndCombatTE = class;
  TCombatMoveTE = class;
  TCMeleeMoveTE = class;
  TCAbTouchMoveTE = class;
  TCAbRangedTE = class;
  TTerminateCombatTE = class;

  TTokenStep = (tokStart, tokEnd, tokFirstStrike, tokInitStrike, tokExeStrike, tokEndStrike, tokExeEndStrike, tokStepUp, tokDelayStrike);  { ot=1 }

  { TCEndTurnTE (instance size 16, VMT 00407548) }
  TCEndTurnTE = class(TTokenEvent)
  public
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TCEndCombatTE (instance size 16, VMT 0040760C) }
  TCEndCombatTE = class(TTokenEvent)
  public
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TCombatMoveTE (instance size 56, VMT 004076D4) }
  TCombatMoveTE = class(TMoveTE)
  public
    FUnit: TTacticalCombatUnit; { $1C }
    FDelay: Integer; { $20 }
    FObjects: TList; { $24 }
    FPreviousUnit: TTacticalCombatUnit; { $28 }
    FFreeStrikeUnit: TTacticalCombatUnit; { $2C }
    FNeighbour: Shortint; { $30 }
    FStep: TTokenStep; { $31 }
    F_CombatMoveTE_32: array[0..1] of Byte;
    FStrike: TStrikeCA; { $34 }
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function GetMapF(Location: HSEngine.TXYL): AoWE.TAoWMapField; override;
    function Validate: Boolean; override;
    function DefaultMove: AoWE.TMoveStatus; override;
    function Setup(UnitObject: TTacticalCombatUnit; Path: TMovepath): Boolean; virtual; { $70 }
    function ExecuteDefaultMove: TMoveStatus;
  end;

  { TCMeleeMoveTE (instance size 64, VMT 004077C0) }
  TCMeleeMoveTE = class(TCombatMoveTE)
  public
    FMeleeRound: TMeleeRound; { $38 }
    FStrikeIndex: Integer; { $3C }
    class function ClassID: Integer; override;
    function LastMove: AoWE.TMoveStatus; override;
    procedure NextStrike;
    procedure ExecuteStrike;
  end;

  { TCAbTouchMoveTE (instance size 108, VMT 004078AC) }
  TCAbTouchMoveTE = class(TCombatMoveTE)
  public
    FEffect: TfxHS; { $38 }
    FAbilityID: Integer; { $3C }
    FPossessAction: TPossessCA; { $40 }
    FEntangleAction: TEntangleCA; { $44 }
    FWebAction: TWebCA; { $48 }
    FTurnUndeadAction: TTurnUndeadCA; { $4C }
    FHealingAction: THealingCA; { $50 }
    FCommandAction: TCommandCA; { $54 }
    FDeathAction: TInvokeDeathCA; { $58 }
    FDispelAction: TDispelMagicAbilityCA; { $5C }
    FEffectType: TfxType; { $60 }
    FSuccessful: Boolean; { $61 }
    F_CAbTouchMoveTE_62: array[0..1] of Byte;
    FDamage: Integer; { $64 }
    FWall: TCityWall; { $68 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function LastMove: AoWE.TMoveStatus; override;
  end;

  { TCAbRangedTE (instance size 60, VMT 0040799C) }
  TCAbRangedTE = class(TTokenEvent)
  public
    FUnit: TTacticalCombatUnit; { $10 }
    FAbilityID: Integer; { $14 }
    FSpellID: Integer; { $18 }
    FSourceX: Word; { $1C }
    FSourceY: Word; { $1E }
    FTargetX: Word; { $20 }
    FTargetY: Word; { $22 }
    FEffectType: TfxType; { $24 }
    F_CAbRangedTE_25: array[0..2] of Byte;
    FStrikeCount: Integer; { $28 }
    FSound: TObject; { $2C }
    FDelay: Integer; { $30 }
    FStrikeIndex: Integer; { $34 }
    FState: Integer; { $38 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure NextStrike;
  end;

  { TTerminateCombatTE (instance size 16, VMT 00407A64) }
  TTerminateCombatTE = class(TTokenEvent)
  public
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

procedure MakeDEHSList(X, Y: Integer; DamageTypes: TDamageTypes; Resisted: Boolean);
function CreateTCEndCombatTE: TCEndCombatTE;
function CreateTCEndTurnTE(Player: Shortint): TCEndTurnTE;
function CreateTCCancelEndTurnTE(Player: Shortint): TCEndTurnTE;
procedure MakeHitBlood(UnitObject: TTacticalCombatUnit; Damage: Integer);
function CreateTCMeleeMoveTE(UnitObject: TTacticalCombatUnit; Path: TMovepath): TCMeleeMoveTE;
function CreateTCAbTouchMoveTE(UnitObject: TTacticalCombatUnit; Path: TMovepath; AbilityID: Integer): TCAbTouchMoveTE;
function CreateTCAbRangedTE(UnitObject: TTacticalCombatUnit; X, Y: Word; AbilityID, SpellID: Integer): TCAbRangedTE;
function CreateCombatMoveTE(UnitObject: TTacticalCombatUnit; Path: TMovepath): TCombatMoveTE;
function MoveCombatUnit(UnitObject: TTacticalCombatUnit; Path: TMovepath): Boolean;
function SetupMultiTCUnitMove(Moves: TMoveSettingsList): Boolean;
procedure RegisterCombatTE(AEngine: TEngine);

implementation

uses Math, CombatFire, CombatSpells;


class function TTerminateCombatTE.ClassID: Integer;
begin Result := $222006; end;

function TTerminateCombatTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin
  AoWHSMap.DestroyCombat;
  Result := erDone;
end;

class function TCEndCombatTE.ClassID: Integer;
begin Result := $222005; end;

function TCEndCombatTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  I: Integer;
begin
  inherited Execute(TE);
  for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
    if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) <> nil) and
      (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
      AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled and
      (AoWCombatMap.FCombat.FCombatData.GetObjects(I).FCombatPlayer = AoWCombatMap.FCurrentCombatPlayer) then
      AoWCombatMap.FCombat.FCombatData.GetObjects(I).Surrender;
  Result := erDone;
end;

class function TCEndTurnTE.ClassID: Integer;
begin Result := $222004; end;

function TCEndTurnTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  TurnIndex, I: Integer;
  Found: Boolean;
begin
  inherited Execute(TE);
  RandSeed := AoWHSMap.Random($FFFFFF);
  TurnIndex := AoWCombatMap.FCombat.FCombatData.FTurnOrder.IndexOf(AoWCombatMap.FCurrentCombatPlayer);
  Found := False;
  while not Found do
  begin
    TurnIndex := TurnIndex + 1;
    if AoWCombatMap.FCombat.FCombatData.FTurnOrder.Count <= TurnIndex then
    begin
      TurnIndex := 0;
      AoWCombatMap.FCombat.NewRound;
    end;
    for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
      if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) <> nil) and
        (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
        (AoWCombatMap.FCombat.FCombatData.GetObjects(I).FCombatPlayer =
          AoWCombatMap.FCombat.FCombatData.FTurnOrder[TurnIndex]) and
        AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled then Found := True;
  end;
  AoWCombatMap.NewTurn(AoWCombatMap.FCombat.FCombatData.FTurnOrder[TurnIndex]);
  Result := erDone;
end;

class function TCombatMoveTE.ClassID: Integer;
begin Result := $222000; end;

function TCombatMoveTE.GetMapF(Location: HSEngine.TXYL): AoWE.TAoWMapField;
begin
  Result := TAoWMapField(AoWCombatMap.MapContainer.GetField(Location.X, Location.Y, 0));
end;

destructor TCombatMoveTE.Destroy;
begin
  if FObjects <> nil then FObjects.Free;
  inherited Destroy;
end;

function TCombatMoveTE.Setup(UnitObject: TTacticalCombatUnit; Path: TMovepath): Boolean;
var
  StartIndex, I: Integer;
begin
  FPath.Clear;
  StartIndex := Path.MovePointsToPos(UnitObject.FMovePoints);
  if StartIndex <> Path.Count - 1 then
  begin
    for I := StartIndex to Path.Count - 1 do FPath.Add(Path[I]);
    Result := True;
  end
  else Result := False;
end;

function TCombatMoveTE.Validate: Boolean;
var
  MapField: TAoWMapField;
  Index: Integer;
  HS: TTacticalCombatUnitHS;
begin
  inherited Validate;
  Index := FPath.Count - 1;
  MapField := GetMapF(FPath[Index]);
  HS := TTacticalCombatUnitHS(MapField.FindOwnedChild($220104));
  if HS <> nil then
  begin
    FObjects := TList.Create;
    FUnit := HS.FUnit;
    Result := True;
  end
  else Result := False;
end;

function TCombatMoveTE.ExecuteDefaultMove: TMoveStatus;
var
  NewField, OldField: TAoWMapField;
  R: TRect;
begin
  Move;
  OldField := TAoWMapField(FUnit.FUnitHS.Owner);
  NewField := GetMapF(FPath[FMoveIndex]);
  FUnit.FUnitHS.MoveTo(NewField, 0);
  if NewField.FindChildIndex(FUnit.FUnitHS) <> -1 then
  begin
    Result := ProcessMove;
    FUnit.MovedTo(OldField, NewField, FPath[FMoveIndex].Flag);
    AoWCombatMap.TriggerMapChangedEvent(Rect(OldField.Xhx, OldField.Yhx, OldField.Xhx + 1, OldField.Yhx + 1), 0);
    if (FMoveIndex = 0) and (NewField.FindChild($220528) <> nil) and
      (FUnit.FCombatPlayer <> AoWCombatMap.FCombat.FCombatData.FDefenderPlayer) then
    begin
      FUnit.SetStatus([csFled]);
      R := Rect(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, FUnit.FUnitHS.Xhx + 1, FUnit.FUnitHS.Yhx + 1);
      FUnit.FUnitHS.Free;
      AoWCombatMap.TriggerMapChangedEvent(R, 0);
      FUnit.FUnitHS := nil;
      Result := msDone;
    end
    else
    begin
      if AoWCombatMap.FExplorationEnabled then
      begin
        AoWCombatMap.ExploreArea(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx,
          0, FUnit.GetPlayer, FUnit.GetVisibilityRange);
        AoWCombatMap.MapChangedRad(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0, FUnit.GetVisibilityRange + 1);
      end
      else
        AoWCombatMap.TriggerMapChangedEvent(Rect(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx,
          FUnit.FUnitHS.Xhx + 1, FUnit.FUnitHS.Yhx + 1), 0);
      if (AoWHSMap.FPlayers.GetPlayers(FUnit.GetPlayer).FPlayerType <> ptHuman) or
        AoWCombatMap.FPlayers.GetPlayers(FUnit.FCombatPlayer).FAuto then FUnit.FMovePoints := 0;
    end;
  end
  else
  begin
    FUnit.FUnitHS := nil;
    Result := msDone;
  end;
end;

function TCombatMoveTE.DefaultMove: AoWE.TMoveStatus;
var
  MapField: TAoWMapField;
  Direction, X, Y: Integer;
  procedure CheckFreeStrike;
  var
    HN, NX, NY: Integer;
    HS: TTacticalCombatUnitHS;
  begin
    if FUnit.GetEnabled and (FFreeStrikeUnit = nil) then
    begin
      MapField := TAoWMapField(FUnit.FUnitHS.Owner);
      HN := FNeighbour + 1;
      while HN <= 6 do
      begin
        CenterHNtoHX(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, HN, NX, NY);
        HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(NX, NY).FindOwnedChild($220104));
        if (HS <> nil) and (FPreviousUnit <> HS.FUnit) and HS.FUnit.GetEnabled and
          not HS.FUnit.GetLocked and (MeleeDamageTypes(HS.FUnit) <> []) and
          (HS.FUnit.GetSide <> FUnit.GetSide) and (HS.FAction = caMove) and
          (HS.FUnit.GetAbilityEnabled(1) = FUnit.GetAbilityEnabled(1)) then
        begin
          FNeighbour := HN;
          FFreeStrikeUnit := HS.FUnit;
          for NX := 0 to FObjects.Count - 1 do
            if FObjects[NX] = FFreeStrikeUnit then FFreeStrikeUnit := nil;
          if FFreeStrikeUnit <> nil then
          begin
            HN := 6;
            FStep := tokStart;
          end;
        end;
        HN := HN + 1;
      end;
      if FFreeStrikeUnit = nil then FNeighbour := 0
      else FObjects.Add(FFreeStrikeUnit);
    end;
  end;
begin
  Result := msMoving;
  try
    if FFreeStrikeUnit <> nil then
    begin
      Result := msMoving;
      case FStep of
        tokStart:
          try
            FUnit.FUnitHS.SetAction(caBusy);
            FFreeStrikeUnit.FUnitHS.SetAction(caStepUp);
            FFreeStrikeUnit.FUnitHS.SetDirection(GetMeleeDirIndex(FFreeStrikeUnit.FUnitHS.Xhx,
              FFreeStrikeUnit.FUnitHS.Xhx - FUnit.FUnitHS.Xhx, FFreeStrikeUnit.FUnitHS.Yhx - FUnit.FUnitHS.Yhx));
            FStep := tokInitStrike;
          except MessageBox(0, 'Error during Token Start', 'Error - TCMoveToken', 0); end;
        tokInitStrike:
          try
            if FFreeStrikeUnit.FUnitHS.FActionDone then
            begin
              RandSeed := AoWHSMap.Random($FFFFFF);
              FStrike := CreateStrikeCA(FFreeStrikeUnit, FUnit, True);
              if FStrike.FDamage = 0 then FFreeStrikeUnit.FUnitHS.SetAction(caMeleeMiss)
              else FFreeStrikeUnit.FUnitHS.SetAction(caMeleeHit);
              FUnit.FUnitHS.SetAction(caBusy);
              FStep := tokExeStrike;
            end;
          except MessageBox(0, 'Error during Token InitStrike', 'Error - TCMoveToken', 0); end;
        tokExeStrike:
          try
            if FFreeStrikeUnit.FUnitHS.FActionDone then
            begin
              if FStrike.FDamage > 0 then
              begin
                FUnit.FUnitHS.SetAction(caHit);
                MakeHitBlood(FUnit, FStrike.FDamage);
              end;
              HXtoHP(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, X, Y);
              if FStrike.FDamageTypes.Value - FStrike.FEffects.Value <> [] then
                MakeDEHSList(X, Y, FStrike.FDamageTypes.Value - FStrike.FEffects.Value, False);
              if FStrike.FEffects.Value <> [] then MakeDEHSList(X, Y, FStrike.FEffects.Value, True);
              FStep := tokEndStrike;
            end;
          except MessageBox(0, 'Error during Token ExeStrike', 'Error - TCMoveToken', 0); end;
        tokEndStrike:
          try
            if FUnit.FUnitHS.FActionDone or (FStrike.FDamage = 0) then
            begin
              if FStrike.FDamage > 0 then AoWCombatMap.FCombat.ExecuteCombatAction(FStrike);
              FStep := tokEnd;
              FFreeStrikeUnit.FUnitHS.SetAction(caStepBack);
            end;
          except MessageBox(0, 'Error during Token EndStrike', 'Error - TCMoveToken', 0); end;
        tokEnd:
          try
            if FFreeStrikeUnit.FUnitHS.FActionDone then
            begin
              if not FUnit.GetEnabled then Result := msDone
              else if FUnit.GetLocked then
              begin
                FUnit.FUnitHS.CancelMove;
                Result := msDone;
              end
              else FUnit.FUnitHS.SetAction(caMove);
              if FStrike <> nil then
              begin FStrike.Release; FStrike := nil; end;
              FFreeStrikeUnit.FUnitHS.SetAction(caMove);
              FStep := tokStart;
              FFreeStrikeUnit := nil;
              CheckFreeStrike;
            end;
          except MessageBox(0, 'Error during Token End', 'Error - TCMoveToken', 0); end;
      end;
    end
    else if FUnit.GetEnabled then
    begin
      if FUnit.FUnitHS.Moving then
      begin
        if (FUnit.FUnitHS.MoveNext = 100) or not FUnit.FUnitHS.GetVisible then
        begin
          Result := ExecuteDefaultMove;
          if Result = msMoving then CheckFreeStrike;
        end
        else Result := msMoving;
      end
      else if FMoveIndex <> 0 then
      begin
        if not AoWCombatMap.FExplorationEnabled or
          TAoWMapField(AoWCombatMap.MapContainer.GetField(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0)).GetExplored(AoWCombatMap.FSeatedPlayer) then
          AoWCombatMap.MakeVisible(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0, 3);
        Direction := GetDirection(FMoveIndex);
        MapField := GetMapF(FPath[FMoveIndex - 1]);
        if MapField.GetPlayer = -1 then
        begin
          if Direction <> 0 then
          begin
            if FUnit.FUnitHS.MoveFirst(Direction, False) = -1 then Result := msFailed
            else Result := msMoving;
            if Result = msMoving then CheckFreeStrike;
          end
          else Result := ExecuteDefaultMove;
        end
        else Result := msDone;
      end
      else Result := msDone;
    end;
    if Result = msDone then
      if FUnit.GetEnabled and (FUnit.FCombatPlayer = AoWCombatMap.FCurrentCombatPlayer) then
      begin
        AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FLastX := FUnit.FUnitHS.Xhx;
        AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FLastY := FUnit.FUnitHS.Yhx;
      end;
  except MessageBox(0, 'Error during Token', 'Error - TCMoveToken', 0); end;
end;

class function TCMeleeMoveTE.ClassID: Integer;
begin Result := $222001; end;

function TCMeleeMoveTE.LastMove: AoWE.TMoveStatus;
var
  HS: TTacticalCombatUnitHS;
  X, Y: Integer;
  Strike: TMeleeStrike;
begin
  Result := msMoving;
  try
    case FStep of
      tokStart:
        try
          Result := msMoving;
          FUnit.FUnitHS.CancelMove;
          if not AoWCombatMap.FExplorationEnabled or
            TAoWMapField(AoWCombatMap.MapContainer.GetField(FUnit.FUnitHS.Xhx,
              FUnit.FUnitHS.Yhx, 0)).GetExplored(AoWCombatMap.FSeatedPlayer) then
            AoWCombatMap.MakeVisible(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0, 5);
          HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(FPath[0].X, FPath[0].Y).FindOwnedChild($220104));
          if HS = nil then FPreviousUnit := nil else FPreviousUnit := HS.FUnit;
          if FPreviousUnit = nil then Result := msDone
          else
          begin
            FMeleeRound := TMeleeRound.Create;
            FMeleeRound.Calculate(FUnit, FPreviousUnit);
            if FMeleeRound.FCount = 0 then Result := msDone
            else
            begin
              FUnit.FUnitHS.SetAction(caStepUp);
              FUnit.FUnitHS.SetDirection(GetMeleeDirIndex(FUnit.FUnitHS.Xhx,
                FUnit.FUnitHS.Xhx - FPreviousUnit.FUnitHS.Xhx,
                FUnit.FUnitHS.Yhx - FPreviousUnit.FUnitHS.Yhx));
              FPreviousUnit.FUnitHS.SetDirection(FUnit.FUnitHS.FDirection + 3);
              if FPreviousUnit.FUnitHS.FDirection > 6 then
                FPreviousUnit.FUnitHS.SetDirection(FPreviousUnit.FUnitHS.FDirection - 6);
            end;
          end;
          FStep := tokFirstStrike;
        except MessageBox(0, 'Error during Token Start', 'Error - TCMelMoveToken', 0); end;
      tokFirstStrike:
        if FUnit.FUnitHS.FActionDone then ExecuteStrike;
      tokDelayStrike:
        if FDelay > 0 then FDelay := FDelay - 1 else ExecuteStrike;
      tokInitStrike:
        try
          FMeleeRound.GetMeleeStrike(FStrikeIndex - 1, Strike);
          if (Strike.Side = csDefender) and FPreviousUnit.FUnitHS.FActionDone then
          begin
            if FStrike.FDamage > 0 then
            begin
              FUnit.FUnitHS.SetAction(caHit);
              MakeHitBlood(FUnit, FStrike.FDamage);
              HXtoHP(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, X, Y);
              if FStrike.FDamageTypes.Value - FStrike.FEffects.Value <> [] then
                MakeDEHSList(X + FUnit.FUnitHS.FOffsetX,
                  Y + FUnit.FUnitHS.FOffsetY, FStrike.FDamageTypes.Value - FStrike.FEffects.Value, False);
              if FStrike.FEffects.Value <> [] then
                MakeDEHSList(X + FUnit.FUnitHS.FOffsetX,
                  Y + FUnit.FUnitHS.FOffsetY, FStrike.FEffects.Value, True);
            end;
            FStep := tokExeStrike;
          end
          else
          begin
          FMeleeRound.GetMeleeStrike(FStrikeIndex - 1, Strike);
          if (Strike.Side = csAttacker) and FUnit.FUnitHS.FActionDone then
          begin
            if FStrike.FDamage > 0 then
            begin
              FPreviousUnit.FUnitHS.SetAction(caHit);
              MakeHitBlood(FPreviousUnit, FStrike.FDamage);
              HXtoHP(FPreviousUnit.FUnitHS.Xhx, FPreviousUnit.FUnitHS.Yhx, X, Y);
              if FStrike.FDamageTypes.Value - FStrike.FEffects.Value <> [] then
                MakeDEHSList(X, Y, FStrike.FDamageTypes.Value - FStrike.FEffects.Value, False);
              if FStrike.FEffects.Value <> [] then MakeDEHSList(X, Y, FStrike.FEffects.Value, True);
            end;
            FStep := tokExeStrike;
          end;
          end;
        except MessageBox(0, 'Error during Token InitStrike', 'Error - TCMelMoveToken', 0); end;
      tokExeStrike:
        try
          if FStrike.FDamage = 0 then NextStrike
          else
          begin
            FMeleeRound.GetMeleeStrike(FStrikeIndex - 1, Strike);
            if (Strike.Side = csAttacker) and FPreviousUnit.FUnitHS.FActionDone then
            begin
              AoWCombatMap.FCombat.ExecuteCombatAction(FStrike);
              if not FPreviousUnit.GetEnabled then
              begin
                FStep := tokEnd;
                FUnit.FUnitHS.SetAction(caStepBack);
              end
              else NextStrike;
            end
            else if FUnit.FUnitHS.FActionDone then
            begin
              AoWCombatMap.FCombat.ExecuteCombatAction(FStrike);
              if FUnit.GetEnabled then NextStrike else Result := msDone;
            end;
          end;
        except MessageBox(0, 'Error during Token ExeStrike', 'Error - TCMelMoveToken', 0); end;
      tokEnd:
        if FUnit.FUnitHS.FActionDone then Result := msDone else Result := msMoving;
    end;
    if Result = msDone then
    begin
      if FMeleeRound <> nil then FMeleeRound.Free;
      if FStrike <> nil then FStrike.Release;
      if FUnit.GetEnabled then
      begin
        FUnit.FMovePoints := 0;
        FUnit.FUnitHS.Unselect;
        if FUnit.FCombatPlayer = AoWCombatMap.FCurrentCombatPlayer then
        begin
          AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FLastX := FUnit.FUnitHS.Xhx;
          AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FLastY := FUnit.FUnitHS.Yhx;
        end;
      end;
    end;
  except MessageBox(0, 'Error during Token', 'Error - TCMelMoveToken', 0); end;
end;

procedure TCMeleeMoveTE.NextStrike;
var
  Locked: Boolean;
  Strike: TMeleeStrike;
begin
  Locked := True;
  while Locked and (FStrikeIndex < FMeleeRound.FCount) do
  begin
    FMeleeRound.GetMeleeStrike(FStrikeIndex, Strike);
    if Strike.Side = csAttacker then Locked := FUnit.GetLocked
    else Locked := FPreviousUnit.GetLocked;
    if Locked then FStrikeIndex := FStrikeIndex + 1;
  end;
  if FStrikeIndex < FMeleeRound.FCount then
  begin
    FStep := tokDelayStrike;
    FDelay := 3;
  end
  else
  begin
    FStep := tokEnd;
    FUnit.FUnitHS.SetAction(caStepBack);
  end;
end;

procedure TCMeleeMoveTE.ExecuteStrike;
var
  Strike: TMeleeStrike;
begin
  if FStrike <> nil then FStrike.Release;
  RandSeed := AoWHSMap.Random($FFFFFF);
  FStrike := FMeleeRound.CreateStrikeCA(FStrikeIndex);
  FMeleeRound.GetMeleeStrike(FStrikeIndex, Strike);
  if Strike.Side = csAttacker then
  begin
    if FStrike.FDamage = 0 then FUnit.FUnitHS.SetAction(caMeleeMiss)
    else FUnit.FUnitHS.SetAction(caMeleeHit);
  end
  else
  begin
    if FStrike.FDamage = 0 then FPreviousUnit.FUnitHS.SetAction(caMeleeMiss)
    else FPreviousUnit.FUnitHS.SetAction(caMeleeHit);
  end;
  FStrikeIndex := FStrikeIndex + 1;
  FStep := tokInitStrike;
end;

class function TCAbTouchMoveTE.ClassID: Integer;
begin Result := $222002; end;

procedure TCAbTouchMoveTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAbilityID, 30);
end;

function TCAbTouchMoveTE.LastMove: AoWE.TMoveStatus;
var
  Point: TXYZ;
  I, X, Y: Integer;
  HS: TTacticalCombatUnitHS;
  Msg: TMapFieldMsg;
begin
  Result := msMoving;
  try
    case FStep of
      tokStart:
        try
          FEffectType := AbilTypes[FAbilityID];
          FUnit.FUnitHS.CancelMove;
          FUnit.FUnitHS.Unselect;
          FUnit.FUnitHS.FSelectedAbility := FAbilityID;
          if not AoWCombatMap.FExplorationEnabled or
            TAoWMapField(AoWCombatMap.MapContainer.GetField(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0)).GetExplored(AoWCombatMap.FSeatedPlayer) then
            AoWCombatMap.MakeVisible(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0, 5);
          FUnit.FUnitHS.SetDirection(GetMeleeDirIndex(FUnit.FUnitHS.Xhx,
            FUnit.FUnitHS.Xhx - FPath[0].X, FUnit.FUnitHS.Yhx - FPath[0].Y));
          if FAbilityID = 65 then FStep := tokInitStrike
          else if FAbilityID = 114 then
          begin FStep := tokExeStrike; FUnit.FUnitHS.SetAction(caRoundAttack); end
          else
          begin
            FUnit.FUnitHS.SetAction(caStepUp);
            HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(FPath[0].X, FPath[0].Y).FindOwnedChild($220104));
            if HS = nil then FPreviousUnit := nil else FPreviousUnit := HS.FUnit;
            if (FPreviousUnit <> nil) and (FAbilityID <> 117) then
            begin
              FPreviousUnit.FUnitHS.SetDirection(FUnit.FUnitHS.FDirection + 3);
              if FPreviousUnit.FUnitHS.FDirection > 6 then FPreviousUnit.FUnitHS.SetDirection(FPreviousUnit.FUnitHS.FDirection - 6);
            end
            else
            begin
              if FAbilityID = 117 then
              begin
                FWall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].GetField(FPath[0].X, FPath[0].Y).FindOwnedChild($220504));
                if FWall = nil then FWall := TCityWall(AoWCombatMap.MapContainer.MapLevels[0].GetField(FPath[0].X, FPath[0].Y).FindOwnedChild($220506));
                if (FWall = nil) and (FAbilityID = 117) then Result := msDone;
              end
              else Result := msDone;
            end;
            FStep := tokStepUp;
          end;
        except MessageBox(0, 'Error during Token Start', Pointer('Error - TCTouchToken ' + IntToStr(FAbilityID)), 0); end;
      tokStepUp:
        try
          if FUnit.FUnitHS.FActionDone then
          begin FUnit.FUnitHS.SetAction(caAbility); FStep := tokInitStrike; end;
        except MessageBox(0, 'Error during Token StepUp', Pointer('Error - TCTouchToken ' + IntToStr(FAbilityID)), 0); end;
      tokInitStrike:
        try
          if FPreviousUnit <> nil then
          begin
            if FUnit.FUnitHS.FActionDone then
            begin
              FEffect := AoWCombatMap.AddEffect(FEffectType);
              FEffect.FAbilityIndex := FAbilityID;
              Point := TXYZ.Create;
              HXtoHP(FPreviousUnit.FUnitHS.Xhx, FPreviousUnit.FUnitHS.Yhx, Point.X, Point.Y);
              Inc(Point.X, 16);
              FEffect.FPath.Add(Point);
              FStep := tokExeStrike;
            end;
          end
          else if (FWall <> nil) or (FAbilityID = 65) then
          begin
            case FAbilityID of
              117:
            begin
              FStep := tokEnd;
              FDamage := 0;
              RandSeed := AoWHSMap.Random($FFFFFF);
              FWall.SetHitPoints(FWall.FHitPoints - ExecuteDamageRole(TCDamage[0], TCAttack[0] - FWall.GetDefense));
              FUnit.FUnitHS.SetAction(caStepBack);
            end;
              65:
            begin
              FEffect := AoWCombatMap.AddEffect(FEffectType);
              FEffect.FAbilityIndex := FAbilityID;
              Point := TXYZ.Create;
              HXtoHP(FPath[1].X, FPath[1].Y, Point.X, Point.Y);
              Inc(Point.X, 16);
              FEffect.FPath.Add(Point);
              FStep := tokExeStrike;
            end;
            end;
          end;
        except MessageBox(0, 'Error during Token InitStrike', Pointer('Error - TCTouchToken ' + IntToStr(FAbilityID)), 0); end;
      tokExeStrike:
        try
          if FEffect = nil then
          begin
            if not FUnit.GetEnabled then Result := msDone
            else
              case FAbilityID of
                114:
                  if FUnit.FUnitHS.FActionDone or (FUnit.FUnitHS.FActionFrame >= 17) then Result := msDone
                  else if raDir[FUnit.FUnitHS.FActionFrame] > 0 then
                  begin
                    I := (raDir[FUnit.FUnitHS.FActionFrame] + FUnit.FUnitHS.FDirection) mod 6 + 1;
                    CenterHNtoHX(FPath[1].X, FPath[1].Y, I, X, Y);
                    HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).FindOwnedChild($220104));
                    if (HS = nil) or (HS = FUnit.FUnitHS) then FPreviousUnit := nil else
                    begin
                      if HS.FUnit.GetAbilityEnabled(1) then FPreviousUnit := nil else
                      begin
                      RandSeed := AoWHSMap.Random($FFFFFF);
                      FStrike := CreateStrikeCA(FUnit, HS.FUnit, True);
                      if FStrike.FDamage > 0 then
                      begin
                        HS.SetAction(caHit);
                        FUnit.FUnitHS.SetAction(caRoundAttackHit);
                        MakeHitBlood(HS.FUnit, FStrike.FDamage);
                        AoWCombatMap.FCombat.ExecuteCombatAction(FStrike);
                      end
                      else FUnit.FUnitHS.SetAction(caRoundAttack);
                      FStrike.Release;
                      FStrike := nil;
                      end;

                    end;

                  end;
              end;
          end
          else if FEffect.FDone then
          begin
            if not FUnit.GetEnabled then Result := msDone
            else
              case FAbilityID of
                40:
                  begin
                    RandSeed := AoWHSMap.Random($FFFFFF);
                    FEntangleAction := TEntangleAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateEntangleCA(FUnit, FPreviousUnit);
                    FSuccessful := FEntangleAction.FSuccessful;
                    AoWCombatMap.FCombat.ExecuteCombatAction(FEntangleAction);
                    FEntangleAction.Release;
                  end;
                27:
                  begin
                    RandSeed := AoWHSMap.Random($FFFFFF);
                    FWebAction := TWebAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateWebCA(FUnit, FPreviousUnit);
                    FSuccessful := FWebAction.FSuccessful;
                    AoWCombatMap.FCombat.ExecuteCombatAction(FWebAction);
                    FWebAction.Release;
                  end;
                28, 29, 148:
                  begin
                    RandSeed := AoWHSMap.Random($FFFFFF);
                    FCommandAction := TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateCommandCA(FUnit, FPreviousUnit);
                    FSuccessful := FCommandAction.FSuccessful;
                    AoWCombatMap.FCombat.ExecuteCombatAction(FCommandAction);
                    FCommandAction.Release;
                  end;
                38:
                  begin
                    RandSeed := AoWHSMap.Random($FFFFFF);
                    FTurnUndeadAction := TTurnUndeadAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateTurnUndeadCA(FUnit, FPreviousUnit);
                    FSuccessful := FTurnUndeadAction.GetSuccessfull;
                    AoWCombatMap.FCombat.ExecuteCombatAction(FTurnUndeadAction);
                    FTurnUndeadAction.Release;
                  end;
                35:
                  begin
                    RandSeed := AoWHSMap.Random($FFFFFF);
                    FDeathAction := TInvokeDeathAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateCA(FUnit, FPreviousUnit);
                    FSuccessful := FDeathAction.FSuccessful;
                    AoWCombatMap.FCombat.ExecuteCombatAction(FDeathAction);
                    FDeathAction.Release;
                  end;
                47:
                  begin
                    RandSeed := AoWHSMap.Random($FFFFFF);
                    FHealingAction := THealingAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateHealingCA(FUnit, FPreviousUnit);
                    FSuccessful := True;
                    AoWCombatMap.FCombat.ExecuteCombatAction(FHealingAction);
                    FHealingAction.Release;
                  end;
                60:
                  begin
                    RandSeed := AoWHSMap.Random($FFFFFF);
                    FDispelAction := TDispelMagicAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateCA(FUnit, FPreviousUnit);
                    FSuccessful := FDispelAction.FEnchantmentIDs.Count > 0;
                    AoWCombatMap.FCombat.ExecuteCombatAction(FDispelAction);
                    FDispelAction.Release;
                  end;
                106, 107:
                  begin
                    RandSeed := AoWHSMap.Random($FFFFFF);
                    FPossessAction := TPossessAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreatePossessCA(FUnit, FPreviousUnit);
                    FSuccessful := FPossessAction.FSuccessful;
                    AoWCombatMap.FCombat.ExecuteCombatAction(FPossessAction);
                    FPossessAction.Release;
                    FUnit.FUnitHS.SetUnitGFXResourceIndex(FUnit.FUnit.GetUnitGFXResourceIndex);
                    if not FPreviousUnit.GetEnabled then
                    begin
                      FUnit.FUnitHS.MoveTo(TMapField(FPreviousUnit.FUnitHS.Owner), 0);
                      FUnit.FUnitHS.SetDirection(FPreviousUnit.FUnitHS.FDirection);
                      FUnit.FUnitHS.FOffsetX := 0;
                      FUnit.FUnitHS.FOffsetY := 0;
                      FPreviousUnit.FUnitHS.Free;
                      FPreviousUnit.FUnitHS := nil;
                      Result := msDone;
                    end;
                  end;
              end;
            if not FUnit.GetEnabled or (((FAbilityID = 106) or (FAbilityID = 107)) and FSuccessful) then Result := msDone
            else if not FSuccessful and (FPreviousUnit <> nil) and FPreviousUnit.GetEnabled and
              not FPreviousUnit.GetLocked and (MeleeDamageTypes(FPreviousUnit) <> []) and (FPreviousUnit.GetSide <> FUnit.GetSide) then
            begin
              RandSeed := AoWHSMap.Random($FFFFFF);
              FStrike := CreateStrikeCA(FPreviousUnit, FUnit, True);
              if FStrike.FDamage = 0 then FPreviousUnit.FUnitHS.SetAction(caMeleeMiss)
              else FPreviousUnit.FUnitHS.SetAction(caMeleeHit);
              FUnit.FUnitHS.SetAction(caBusy);
              FStep := tokEndStrike;
            end
            else
            begin FStep := tokEnd; FUnit.FUnitHS.SetAction(caStepBack); end;
          end
          else if FUnit.GetEnabled then
            case FAbilityID of
              65:
                if FEffect.FFrame = 5 then
                begin
                  Msg.MsgID := $31000; Msg.Param[0] := Integer(FUnit); Msg.Result := -1;
                  for I := 0 to 6 do
                  begin
                    CenterHNtoHX(FPath[1].X, FPath[1].Y, I, X, Y);
                    AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                    CreateFire(False, 50, X, Y);
                  end;
                  FUnit.FDeathMethod := dmExplode;
                end;
            end;
        except MessageBox(0, 'Error during Token ExeStrike', Pointer('Error - TCTouchToken ' + IntToStr(FAbilityID)), 0); end;
      tokEndStrike:
        try
          if FPreviousUnit.FUnitHS.FActionDone then
          begin
            if FStrike.FDamage > 0 then
            begin
              FUnit.FUnitHS.SetAction(caHit);
              MakeHitBlood(FUnit, FStrike.FDamage);
            end;
            HXtoHP(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, I, X);
            if FStrike.FDamageTypes.Value - FStrike.FEffects.Value <> [] then
              MakeDEHSList(I + FUnit.FUnitHS.FOffsetX, X + FUnit.FUnitHS.FOffsetY, FStrike.FDamageTypes.Value - FStrike.FEffects.Value, False);
            if FStrike.FEffects.Value <> [] then
              MakeDEHSList(I + FUnit.FUnitHS.FOffsetX, X + FUnit.FUnitHS.FOffsetY, FStrike.FEffects.Value, True);
            FStep := tokExeEndStrike;
          end;
        except MessageBox(0, 'Error during Token StrikeBack', Pointer('Error - TCTouchToken ' + IntToStr(FAbilityID)), 0); end;
      tokExeEndStrike:
        try
          if FUnit.FUnitHS.FActionDone or (FStrike.FDamage = 0) then
          begin
            if FStrike.FDamage > 0 then AoWCombatMap.FCombat.ExecuteCombatAction(FStrike);
            if FUnit.GetEnabled then begin FStep := tokEnd; FUnit.FUnitHS.SetAction(caStepBack); end
            else Result := msDone;
          end;
        except MessageBox(0, 'Error during Token ExeStrikeBack', Pointer('Error - TCTouchToken ' + IntToStr(FAbilityID)), 0); end;
      tokEnd:
        if FUnit.FUnitHS.FActionDone then Result := msDone;
    end;
    if Result = msDone then
      if FUnit.GetEnabled then
      begin
        FUnit.FUnitHS.SetAction(caMove);
        FUnit.FUnitHS.FSelectedAbility := -1;
        FUnit.FMovePoints := 0;
        FUnit.FUnitHS.Unselect;
        if FUnit.FCombatPlayer = AoWCombatMap.FCurrentCombatPlayer then
        begin
          AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FLastX := FUnit.FUnitHS.Xhx;
          AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FLastY := FUnit.FUnitHS.Yhx;
        end;
      end;
  except MessageBox(0, 'Error during Token', Pointer('Error - TCTouchToken ' + IntToStr(FAbilityID)), 0); end;
end;

class function TCAbRangedTE.ClassID: Integer;
begin Result := $222003; end;

procedure TCAbRangedTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAbilityID, 30);
  Stream.rwInteger(FSpellID, 31);
  Stream.rwWord(FTargetX, 32);
  Stream.rwWord(FTargetY, 33);
  Stream.rwWord(FSourceX, 34);
  Stream.rwWord(FSourceY, 35);
end;

function TCAbRangedTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  I, X, Y, EffectIndex: Integer;
  Effect, ExtraEffect: TfxHS;
  EndX, EndY: Integer;
  Info: TSpellCombatInfo;
  HS: TTacticalCombatUnitHS;
  Ooze: TCOozeHS;
  Action: TCombatAction;
  Msg: TMapFieldMsg;
begin
  inherited Execute(TE);
  Result := erRetry;
  try
    case FState of
      0:
        try
          HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(FSourceX, FSourceY).FindOwnedChild($220104));
          if HS = nil then Result := erDone
          else
          begin
            FUnit := HS.FUnit;
            FUnit.FUnitHS.Unselect;
            FUnit.FUnitHS.FSelectedAbility := FAbilityID;
            FUnit.FUnitHS.FSelectedSpell := FSpellID;
            if FAbilityID = 52 then FEffectType := SpellTypes[FSpellID]
            else FEffectType := AbilTypes[FAbilityID];
            if FAbilityID = 52 then AoWHSSet.FSpellControl.GetSpell(FSpellID).CombatSpellCast(FUnit);
            if not AoWCombatMap.FExplorationEnabled or
              TAoWMapField(AoWCombatMap.MapContainer.GetField(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0)).GetExplored(AoWCombatMap.FSeatedPlayer) then
              AoWCombatMap.MakeVisible(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0, 2);
            case FEffectType of
              fxBreath: FStrikeCount := 20;
              fxScreenNESW: FStrikeCount := 10;
              fxScreenNS:
                case FSpellID of
                  116: FStrikeCount := 21;
                  124: FStrikeCount := 19;
                else FStrikeCount := 35; end;
              fxShockWave:
                begin FTargetX := FSourceX; FTargetY := FSourceY; FStrikeCount := 1; end;
              fxTouch: FStrikeCount := 1;
              fxSwarm, fxScreenSwarm: FStrikeCount := 30;
            else
              if FAbilityID = 52 then
              begin
                AoWHSSet.FSpellControl.GetSpell(FSpellID).GetCombatInfo(FUnit.FUnit, Info);
                FStrikeCount := Info.RepeatCount;
              end
              else FStrikeCount := TRangedAttackAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).GetAttackRepeatRA(FUnit.FUnit);
            end;
            case FEffectType of
              fxTremors:
                begin
                  FSound := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.PlayEx(0, 64, True, 0, spCenter, nil);
                  NextStrike;
                end;
              fxScreenSwarm:
                begin
                  FSound := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.PlayEx(2, 64, True, 0, spCenter, nil);
                  for I := 0 to FStrikeCount - 1 do NextStrike;
                end;
            else NextStrike;
            end;
            FUnit.FMovePoints := 0;
            Inc(FState);
          end;
        except
          MessageBox(0, 'Error during Token Start', Pointer('Error - TCRangedToken ' + IntToStr(FAbilityID) + '/' + IntToStr(FSpellID)), 0);
        end;
      1:
        try
          EffectIndex := 0;
          while EffectIndex < AoWCombatMap.FEffects.Count do
          begin
            EndX := -1;
            EndY := -1;
            Effect := TfxHS(AoWCombatMap.FEffects[EffectIndex]);
            if (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 117) then
            begin
              if Effect.FEffectType = fxRock then
              begin
                if Effect.FDone then
                begin
                  Effect.FEffectType := fxFBExplosion;
                  Effect.FDone := False;
                  while Effect.FPath.Count > 1 do Effect.FPath.Delete(0);
                end;
              end
              else case Effect.FFrame of
                5: begin
                Msg.MsgID := $31003;
                Msg.Param[0] := Integer(FUnit);
                Msg.Result := -1;
                HPtoHX(Effect.FPath[0].X, Effect.FPath[0].Y, EndX, EndY);
                for I := 0 to 6 do
                begin
                  CenterHNtoHX(EndX, EndY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                  CreateFire(False, 50, X, Y);
                end;
              end;
              end;
            end
            else if (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 107) then
            begin
              if (Effect.FFrame <> -1) and (Effect.FPath[Effect.FFrame].Z = 15) then
              begin
                HPtoHX(Effect.FPath[Effect.FFrame].X, Effect.FPath[Effect.FFrame].Y, X, Y);
                HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).FindOwnedChild($220104));
                if HS <> nil then
                begin
                  RandSeed := AoWHSMap.Random($FFFFFF);
                  Effect.FCombatAction := AoWHSSet.FSpellControl.GetSpell(Effect.FSpellIndex).CreateCA(FUnit, HS.FUnit, False);
                  HXtoHP(HS.Xhx, HS.Yhx, I, X);
                  if TDamageCA(Effect.FCombatAction).FDamageTypes.Value - TDamageCA(Effect.FCombatAction).FEffects.Value <> [] then
                    MakeDEHSList(I, X, TDamageCA(Effect.FCombatAction).FDamageTypes.Value - TDamageCA(Effect.FCombatAction).FEffects.Value, False);
                  if TDamageCA(Effect.FCombatAction).FEffects.Value <> [] then
                    MakeDEHSList(I, X, TDamageCA(Effect.FCombatAction).FEffects.Value, True);
                  AoWCombatMap.FCombat.ExecuteCombatAction(Effect.FCombatAction);
                  Effect.FCombatAction.Release;
                  Effect.FCombatAction := nil;
                end;
              end;
            end
            else if (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 112) then
            begin
              case Effect.FFrame of
                89: begin
                Msg.MsgID := $31004;
                Msg.Param[0] := Integer(FUnit);
                Msg.Param[1] := 0;
                Msg.Result := -1;
                for I := 6 to 59 do
                  for X := 6 to 52 do AoWCombatMap.MapContainer.MapLevels[0].GetField(I, X).SendMapFieldMsg(Msg);
              end;
              end;
            end
            else if (Effect.FAbilityIndex = 52) and (Effect.FEffectType = fxResurrect) and
              ((Effect.FSpellIndex = 130) or (Effect.FSpellIndex = 129)) then
            begin
              case Effect.FFrame of
                0: begin
                Msg.MsgID := $31008;
                Msg.Param[0] := Integer(FUnit);
                Msg.Param[1] := FSpellID;
                Msg.Result := -1;
                for I := 0 to 6 do
                begin
                  CenterHNtoHX(FTargetX, FTargetY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                end;
              end;
                99: begin
                Msg.MsgID := $31009;
                Msg.Param[0] := Integer(FUnit);
                Msg.Param[1] := FSpellID;
                Msg.Result := -1;
                for I := 0 to 6 do
                begin
                  CenterHNtoHX(FTargetX, FTargetY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                end;
              end;
              end;
            end
            else if (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 104) then
            begin
              case Effect.FFrame of
                199: begin
                Msg.MsgID := $31005;
                Msg.Param[0] := Integer(FUnit);
                Msg.Result := -1;
                for I := 0 to 6 do
                begin
                  CenterHNtoHX(FTargetX, FTargetY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                end;
              end;
              end;
            end
            else if (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 127) then
            begin
              case Effect.FFrame of
                175: begin
                Msg.MsgID := $3100D;
                Msg.Param[0] := Integer(FUnit);
                Msg.Result := -1;
                for I := 1 to 6 do
                begin
                  CenterHNtoHX(FTargetX, FTargetY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                end;
              end;
                200: begin
                Msg.MsgID := $3100D;
                Msg.Param[0] := Integer(FUnit);
                Msg.Result := -1;
                for I := 7 to 18 do
                begin
                  CenterHNtoHX(FTargetX, FTargetY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                end;
              end;
                225: begin
                Msg.MsgID := $3100D;
                Msg.Param[0] := Integer(FUnit);
                Msg.Result := -1;
                for I := 19 to 36 do
                begin
                  CenterHNtoHX(FTargetX, FTargetY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                end;
              end;
              end;
            end
            else if (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 128) then
            begin
              case Effect.FFrame of
                100: begin
                CreateFire(False, 50, FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx);
                Msg.MsgID := $3100E;
                Msg.Param[0] := Integer(FUnit);
                Msg.Result := -1;
                AoWCombatMap.MapContainer.MapLevels[0].GetField(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx).SendMapFieldMsg(Msg);
              end;
                175: begin
                Msg.MsgID := $3100E;
                Msg.Param[0] := Integer(FUnit);
                Msg.Result := -1;
                for I := 0 to 18 do
                begin
                  CenterHNtoHX(FTargetX, FTargetY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                  CreateFire(False, 50, X, Y);
                end;
              end;
              end;
            end
            else if (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 105) and (Effect.FTarget <> nil) then
            begin
              for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
                if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) <> nil) and
                  (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
                  (AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetSide <> FUnit.GetSide) and
                  AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled and
                  (TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS <> nil) then
                begin
                  RandSeed := AoWHSMap.Random($FFFFFF);
                  Action := AoWHSSet.FSpellControl.GetSpell(FSpellID).CreateCA(FUnit, AoWCombatMap.FCombat.FCombatData.GetObjects(I), False);
                  if TExclusiveCombatSpellCA(Action).FSucceeded then
                    TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.SetAction(caHit);
                  AoWCombatMap.FCombat.ExecuteCombatAction(Action);
                  Action.Release;
                end;
              Effect.FTarget := nil;
            end
            else if (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 120) then
            begin
              case Effect.FFrame of
                2999: begin
                Msg.MsgID := $3100C;
                Msg.Param[0] := Integer(FUnit);
                Msg.Result := -1;
                for I := 0 to 6 do
                begin
                  CenterHNtoHX(FTargetX, FTargetY, I, X, Y);
                  AoWCombatMap.MapContainer.MapLevels[0].GetField(X, Y).SendMapFieldMsg(Msg);
                end;
              end;
              end;
            end
            else if (Effect.FEffectType = fxSacredWrath) and (Effect.FAbilityIndex = 52) and (Effect.FSpellIndex = 125) then
            begin
              case Effect.FFrame of
                5: for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
                  if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
                    AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled then
                  begin
                    HS := TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS;
                    if HS <> nil then
                    begin
                      ExtraEffect := AoWCombatMap.AddEffect(fxSWComet);
                      ExtraEffect.FAbilityIndex := FAbilityID;
                      ExtraEffect.FSpellIndex := FSpellID;
                      ExtraEffect.FTarget := HS.FUnit;
                    end;
                  end;
              end;
            end
            else
            begin
              if Effect.FDone and (Effect.FTarget <> nil) and Effect.FTarget.GetEnabled then
              begin
                I := 0;
                RandSeed := AoWHSMap.Random($FFFFFF);
                if FAbilityID = 52 then Effect.FCombatAction := AoWHSSet.FSpellControl.GetSpell(FSpellID).CreateCA(FUnit, Effect.FTarget, False)
                else if FAbilityID = 47 then Effect.FCombatAction := THealingAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateHealingCA(FUnit, Effect.FTarget)
                else if FAbilityID = 60 then Effect.FCombatAction := TDispelMagicAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateCA(FUnit, Effect.FTarget)
                else Effect.FCombatAction := TRangedAttackAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).CreateRangedAttackCA(FUnit, Effect.FTarget, 0);
                if Effect.FCombatAction is TDamageCA then
                begin
                  I := TDamageCA(Effect.FCombatAction).FDamage;
                  HXtoHP(TTacticalCombatUnit(Effect.FTarget).FUnitHS.Xhx, TTacticalCombatUnit(Effect.FTarget).FUnitHS.Yhx, X, Y);
                  if TDamageCA(Effect.FCombatAction).FDamageTypes.Value - TDamageCA(Effect.FCombatAction).FEffects.Value <> [] then
                    MakeDEHSList(X, Y, TDamageCA(Effect.FCombatAction).FDamageTypes.Value - TDamageCA(Effect.FCombatAction).FEffects.Value, False);
                  if TDamageCA(Effect.FCombatAction).FEffects.Value <> [] then MakeDEHSList(X, Y, TDamageCA(Effect.FCombatAction).FEffects.Value, True);
                end
                else if Effect.FCombatAction is TEntangleSpellCA then
                begin
                  if TEntangleSpellCA(Effect.FCombatAction).FSucceeded then TTacticalCombatUnit(Effect.FTarget).FUnitHS.SetAction(caHit);
                end
                else if (Effect.FCombatAction is TMindDecayCA) and TMindDecayCA(Effect.FCombatAction).FSucceeded then TTacticalCombatUnit(Effect.FTarget).FUnitHS.SetAction(caHit);
                if I > 0 then
                begin
                  TTacticalCombatUnit(Effect.FTarget).FUnitHS.SetAction(caHit);
                  MakeHitBlood(TTacticalCombatUnit(Effect.FTarget), I);
                  Effect.FCancelled := True;
                end;
              end;
              if Effect.FDone then
              begin
                HPtoHX(Effect.FPath[Effect.FPath.Count - 1].X, Effect.FPath[Effect.FPath.Count - 1].Y, EndX, EndY);
                if (Effect.FCombatAction <> nil) and (Effect.FTarget <> nil) then
                begin
                  AoWCombatMap.FCombat.ExecuteCombatAction(Effect.FCombatAction);
                  Effect.FCombatAction.Release;
                  Effect.FCombatAction := nil;
                  if not Effect.FTarget.GetEnabled then
                    for I := 0 to AoWCombatMap.FEffects.Count - 1 do
                      if I <> EffectIndex then
                        if TfxHS(AoWCombatMap.FEffects[I]).FTarget = Effect.FTarget then
                          TfxHS(AoWCombatMap.FEffects[I]).FTarget := nil;
                end
                else if EndX > -1 then
                  case Effect.FAbilityIndex of
                    30, 86..90:
                      if Effect.FTargetX > 0 then
                      begin
                        Msg.MsgID := $31012;
                        Msg.Param[0] := Integer(FUnit);
                        Msg.Param[1] := Effect.FAbilityIndex;
                        Msg.Result := -1;
                        AoWCombatMap.MapContainer.MapLevels[0].GetField(Effect.FTargetX, Effect.FTargetY).SendMapFieldMsg(Msg);
                      end;
                    24:
                      begin
                        Msg.MsgID := $31001; Msg.Param[0] := Integer(FUnit); Msg.Result := -1;
                        AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).SendMapFieldMsg(Msg);
                      end;
                    44:
                      begin
                        Msg.MsgID := $31002; Msg.Param[0] := Integer(FUnit); Msg.Result := -1;
                        AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).SendMapFieldMsg(Msg);
                      end;
                    31:
                      begin
                        Msg.MsgID := $3100A; Msg.Param[0] := Integer(FUnit); Msg.Result := -1;
                        AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).SendMapFieldMsg(Msg);
                        CreateFire(False, 100, EndX, EndY);
                      end;
                    52:
                      case Effect.FEffectType of
                        fxBreath:
                          if Effect.FTargetX > 0 then
                          begin
                            Msg.MsgID := $31013; Msg.Param[0] := Integer(FUnit); Msg.Param[1] := Effect.FSpellIndex; Msg.Result := -1;
                            AoWCombatMap.MapContainer.MapLevels[0].GetField(Effect.FTargetX, Effect.FTargetY).SendMapFieldMsg(Msg);
                          end;
                        fxScreenNS:
                          case Effect.FSpellIndex of
                            116:
                              begin
                                Msg.MsgID := $31006; Msg.Param[0] := Integer(FUnit); Msg.Result := -1;
                                AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).SendMapFieldMsg(Msg);
                              end;
                            124:
                              if (AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).TerrainType <> 0) and
                                (AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).TerrainType <> 10) and
                                (AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).OverlayType <> 2) and
                                (AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).OverlayType <> 11) and
                                (AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).OverlayType <> 8) and
                                (AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).TerrainType <> 9) and
                                (AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).TerrainType <> 15) and
                                (AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).TerrainType <> 7) then
                              begin
                                Ooze := TCOozeHS.Create(nil);
                                AoWCombatMap.PlaceHX(Ooze, EndX, EndY, 0);
                              end;
                          end;
                        fxEffect:
                          case Effect.FSpellIndex of
                            113:
                              begin
                                Msg.MsgID := $3100B; Msg.Param[0] := Integer(FUnit); Msg.Result := -1;
                                AoWCombatMap.MapContainer.MapLevels[0].GetField(EndX, EndY).SendMapFieldMsg(Msg);
                                CreateFire(False, 100, EndX, EndY);
                              end;
                          end;
                      end;
                  end;
              end;
            end;
            Inc(EffectIndex);
          end;
          if (AoWCombatMap.FEffects.Count = 0) and ((FStrikeIndex >= FStrikeCount) or not FUnit.GetEnabled) then
          begin
            if FUnit.GetEnabled then FUnit.FUnitHS.SetAction(caMove);
            Result := erDone;
          end;
          if FUnit.GetEnabled then
            if FEffectType = fxBreath then NextStrike
            else
            begin
              if FUnit.FUnitHS.FActionDone or ((FAbilityID = 52) and (FDelay <= 0)) then FDelay := AoWHSMap.Random(3) + 4;
              Dec(FDelay);
              if FDelay = 0 then NextStrike;
            end;
        except
          MessageBox(0, 'Error during Token Execute', Pointer('Error - TCRangedToken ' + IntToStr(FAbilityID) + '/' + IntToStr(FSpellID)), 0);
        end;
    end;
    if Result = erDone then
    begin
      if FSound <> nil then FSound.Free;
      if (FUnit <> nil) and FUnit.GetEnabled then
      begin
        FUnit.FUnitHS.FSelectedAbility := -1;
        FUnit.FUnitHS.FSelectedSpell := -1;
        FUnit.FUnitHS.Unselect;
        if FUnit.FCombatPlayer = AoWCombatMap.FCurrentCombatPlayer then
        begin
          AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FLastX := FUnit.FUnitHS.Xhx;
          AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentCombatPlayer).FLastY := FUnit.FUnitHS.Yhx;
        end;
      end;
    end;
  except
    MessageBox(0, 'Error during Token', Pointer('Error - TCRangedToken ' + IntToStr(FAbilityID) + '/' + IntToStr(FSpellID)), 0);
  end;
end;

procedure TCAbRangedTE.NextStrike;
var
  Used: TList;
  Target: TTacticalCombatUnit;
  Effect, ExtraEffect: TfxHS;
  HS: TTacticalCombatUnitHS;
  A, Sweep, Angle, Radius: Single;
  X1, Y1, X2, Y2, DX, DY, I, J, K: Integer;
  Point: TXYZ;
  HitObject: THexagonSprite;
  Path: TXYZList;
  Obstacles: TList;
  Obstacle: TROb;
  Found: Boolean;
  function FindTarget(X, Y: Integer): TTacticalCombatUnit;
  var
    I, Distance, BestDistance, J: Integer;
    Available: Boolean;
  begin
    Result := nil;
    BestDistance := 6;
    for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
      if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
        AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled and
        (AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetSide <> FUnit.GetSide) then
      begin
        Available := True;
        for J := 0 to Used.Count - 1 do
          if AoWCombatMap.FCombat.FCombatData.GetObjects(I) = Used[J] then Available := False;
        if Available then
        begin
          Distance := dHXtoRad(X, Y,
            TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.Xhx,
            TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.Yhx);
          if Distance < BestDistance then
          begin
            Result := TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I));
            BestDistance := Distance;
          end;
        end;
      end;
  end;
  procedure ChooseTarget;
  var
    I, Index, Total, Distance: Integer;
    Weights: TList;
  begin
    Used := TList.Create;
    Weights := TList.Create;
    Total := 0;
    for I := 0 to AoWCombatMap.FCombat.FCombatData.GetCount - 1 do
      if (AoWCombatMap.FCombat.FCombatData.GetObjects(I) is TCombatUnit) and
        AoWCombatMap.FCombat.FCombatData.GetObjects(I).GetEnabled and
        (AoWCombatMap.FCombat.FCombatData.GetObjects(I) <> Target) then
      begin
        Distance := dHXtoRad(FTargetX, FTargetY,
          TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.Xhx,
          TTacticalCombatUnit(AoWCombatMap.FCombat.FCombatData.GetObjects(I)).FUnitHS.Yhx);
        if Distance < 13 then
        begin
          Total := Total + (13 - Distance);
          Used.Add(AoWCombatMap.FCombat.FCombatData.GetObjects(I));
          Weights.Add(Pointer(13 - Distance));
        end;
      end;
    if Target <> nil then
    begin
      Used.Add(Target);
      Weights.Add(Pointer(Total));
      Total := Total + Total;
    end;
    if Used.Count > 0 then
    begin
      I := AoWHSMap.Random(Total) - Integer(Weights[0]);
      Index := 0;
      while (Index < Used.Count - 1) and (I > 0) do
      begin
        Index := Index + 1;
        I := I - Integer(Weights[Index]);
      end;
      Target := TTacticalCombatUnit(Used[Index]);
    end;
    Used.Free;
    Weights.Free;
  end;
begin
  if FStrikeIndex >= FStrikeCount then Exit;
  Effect := AoWCombatMap.AddEffect(fxNone);
  Obstacles := TList.Create;
  case FEffectType of
    fxBreath:
      begin
        CenterHNtoHX(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx,
          BreathHN[BreathDirection[dHXtoHN(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx,
            FTargetX, FTargetY)] * 12 - 3], J, K);
        HXtoHP(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, X1, Y1);
        HXtoHP(J, K, X2, Y2);
        Sweep := FStrikeIndex;
        if Sweep > 9 then Sweep := 19 - Sweep;
        if Y2 = Y1 then A := 0
        else if X2 = X1 then A := Pi / 2
        else A := ArcTan(Abs(X2 - X1) / Abs(Y2 - Y1));
        if (Y2 = Y1) or (X2 = X1) then Angle := Pi / 2 - A + (Sweep * 6 - 30) * Pi / 180
        else Angle := A + (Sweep * 6 - 30) * Pi / 180;
        Radius := Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1));
        if X2 >= X1 then DX := Round(Sin(Angle) * Radius) - X2 + X1
        else DX := X1 - X2 - Round(Sin(Angle) * Radius);
        if Y2 >= Y1 then DY := Round(Cos(Angle) * Radius) - Y2 + Y1
        else DY := Y1 - Y2 - Round(Cos(Angle) * Radius);
        MakeRangedPath(FUnit.GetSide, 50, 20, 50, FUnit.FUnitHS.Xhx,
          FUnit.FUnitHS.Yhx, J, K, DX, DY, False, Effect.FPath, Obstacles);
        if FStrikeIndex < 12 then
          CenterHNtoHX(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx,
            BreathHN[BreathDirection[dHXtoHN(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx,
              FTargetX, FTargetY)] * 12 + BreathHit[FStrikeIndex] - 12],
            Effect.FTargetX, Effect.FTargetY);
      end;
    fxTouch, fxEffect, fxSacredWrath, fxGeyser, fxCloud, fxMindDecay, fxShockWave, fxSacFlame:
      begin
        if FEffectType = fxSacredWrath then begin FTargetX := 32; FTargetY := 29; end;
        HXtoHP(FTargetX, FTargetY, X2, Y2);
        case FEffectType of
          fxGeyser: AoWCombatMap.CenterViewTo(FTargetX, FTargetY - 5, 0);
          fxMindDecay:
            begin
              Effect.FTargetX := FTargetX;
              Effect.FTargetY := FTargetY;
              AoWCombatMap.CenterViewTo(FTargetX + 1, FTargetY - 4, 0);
            end;
          fxShockWave: AoWCombatMap.CenterViewTo(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, 0);
          fxSacFlame: AoWCombatMap.CenterViewTo(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx - 3, 0);
        else AoWCombatMap.CenterViewTo(FTargetX, FTargetY, 0);
        end;
        Point := TXYZ.Create;
        Point.X := X2 + 16;
        Point.Y := Y2 + 16;
        Effect.FPath.Add(Point);
        HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(FTargetX, FTargetY).FindOwnedChild($220104));
        if HS <> nil then Effect.FTarget := HS.FUnit;
      end;
    fxWinds:
      begin
        HXtoHP(FTargetX, FTargetY, X2, Y2);
        Point := TXYZ.Create;
        Point.X := X2 + 16;
        Point.Y := Y2 + 16;
        Effect.FPath.Add(Point);
        HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(FTargetX, FTargetY).FindOwnedChild($220104));
        if HS <> nil then Effect.FTarget := HS.FUnit;
        I := AoWHSMap.Random(37) + 1;
        Found := False;
        while not Found do
        begin
          CenterHNtoHX(FTargetX, FTargetY, I, J, K);
          if (J > 5) and (J < 60) and (K > 5) and (K < 53) and
            (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).FindOwnedChild($220104) = nil) and
            ((AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).OverlayType <> 8) or
              (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).OverlayType =
               AoWCombatMap.MapContainer.MapLevels[0].GetField(FTargetX, FTargetY).OverlayType)) and
            (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).TerrainType <> 15) and
            (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).TerrainType <> 7) and
            (((AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).TerrainType <> 0) and
              (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).TerrainType <> 10) and
              (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).TerrainType <> 9)) or
              (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).TerrainType =
               AoWCombatMap.MapContainer.MapLevels[0].GetField(FTargetX, FTargetY).TerrainType)) then Found := True
          else Inc(I);
        end;
        HXtoHP(J, K, DX, DY);
        AoWCombatMap.CenterViewTo(FTargetX, FTargetY, 0);
        for I := 0 to 29 do
        begin
          Effect.FPath.Add(TXYZ.Create);
          Effect.FPath[Effect.FPath.Count - 1].X := Effect.FPath[0].X + Random(30) - 15;
          Effect.FPath[Effect.FPath.Count - 1].Y := Effect.FPath[0].Y + Random(30) - 15;
        end;
        J := Random(300); K := Random(300);
        MakeArcPathXY(Effect.FPath[Effect.FPath.Count - 1].X,
          Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z,
          Effect.FPath[Effect.FPath.Count - 1].X + J - 150,
          Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z + K - 150,
          (Abs(J - 150) + Abs(K - 150)) div 50 + 2, 100, Effect.FPath);
        Effect.FTargetX := Effect.FPath.Count;
        J := Random(200); K := Random(200);
        MakeArcPathXY(Effect.FPath[Effect.FPath.Count - 1].X,
          Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z,
          Effect.FPath[Effect.FPath.Count - 1].X + J - 100,
          Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z + K - 100,
          (Abs(J - 100) + Abs(K - 100)) div 50 + 3, 100, Effect.FPath);
        Effect.FTargetY := Effect.FPath.Count;
        MakeArcPathXY(Effect.FPath[Effect.FPath.Count - 1].X,
          Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z,
          DX + 16, DY + 16,
          (Abs(Effect.FPath[Effect.FPath.Count - 1].Y - Effect.FPath[Effect.FPath.Count - 1].Z - DY) +
           Abs(Effect.FPath[Effect.FPath.Count - 1].X - DX)) div 50 + 4, 100, Effect.FPath);
      end;
    fxScreenNESW:
      begin
        Point := TXYZ.Create;
        if Random(100) < 50 then Point.X := 0 else Point.X := 1;
        Effect.FPath.Add(Point);
        if FStrikeIndex = 9 then Effect.FTarget := FUnit;
      end;
    fxScreenNS:
      begin
        case FSpellID of 124: I := 19; else I := 7; end;
        CenterHNtoHX(FTargetX, FTargetY, rndHex[FStrikeIndex mod I], DX, DY);
        HXtoHP(DX, DY, X2, Y2);
        AoWCombatMap.MakeVisible(DX, DY, 0, 5);
        X1 := Random(20) + 6;
        Y1 := Random(20) + 6;
        MakeLinePath(X2 + X1 - 100, Y2 + Y1 - 300, X2 + X1, Y2 + Y1, 30, Effect.FPath);
        case FSpellID of
          124: Effect.FTarget := nil;
        else
        begin
          HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(DX, DY).FindOwnedChild($220104));
          if HS <> nil then Effect.FTarget := HS.FUnit;
        end;
        end;
      end;
    fxChain:
      begin
        HXtoHP(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, X1, Y1);
        HXtoHP(FTargetX, FTargetY, X2, Y2);
        MakeLightningPath(X1 + 16, Y1, X2 + 16, Y2, Effect.FPath);
        Effect.FPath[Effect.FPath.Count - 1].Z := 16;
        I := 3;
        Used := TList.Create;
        Used.Add(FUnit);
        HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(FTargetX, FTargetY).FindOwnedChild($220104));
        if HS <> nil then Used.Add(HS.FUnit);
        Target := FindTarget(FTargetX, FTargetY);
        while (Target <> nil) and (I > 0) do
        begin
          Used.Add(Target);
          X1 := X2 + 16;
          Y1 := Y2 + 16;
          HXtoHP(Target.FUnitHS.Xhx, Target.FUnitHS.Yhx, X2, Y2);
          MakeLightningPath(X1, Y1, X2 + 16, Y2, Effect.FPath);
          Dec(I);
          Target := FindTarget(Target.FUnitHS.Xhx, Target.FUnitHS.Yhx);
        end;
        Used.Free;
      end;
    fxSwarm:
      begin
        HXtoHP(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, X1, Y1);
        MakeSwarmPath(Random(10) + 10, Random(5) + 20, Random(90), Random(360),
          Random(20) + X1 + 6, Random(20) + Y1 - 10, TSwarmDirection(Random(2)), Effect.FPath);
        K := Effect.FPath.Count - 1;
        for I := 0 to 2 do
          for J := 0 to K do
          begin
            Point := TXYZ.Create;
            Point.X := Effect.FPath[J].X;
            Point.Y := Effect.FPath[J].Y;
            Effect.FPath.Add(Point);
          end;
        HXtoHP(FTargetX, FTargetY, X2, Y2);
        MakeLinePath(Effect.FPath[Effect.FPath.Count - 1].X,
          Effect.FPath[Effect.FPath.Count - 1].Y, X2 + 16, Y2, 15, Effect.FPath);
        Path := TXYZList.Create;
        MakeSwarmPath(Random(10) + 10, Random(5) + 20, Random(90), Random(360),
          Effect.FPath[Effect.FPath.Count - 1].X, Effect.FPath[Effect.FPath.Count - 1].Y,
          TSwarmDirection(Random(2)), Path);
        MakeLinePath(Effect.FPath[Effect.FPath.Count - 1].X,
          Effect.FPath[Effect.FPath.Count - 1].Y, Path[0].X, Path[0].Y, 5, Effect.FPath);
        for I := 0 to Path.Count - 1 do Effect.FPath.Add(Path[I]); { Original shares the points, then frees Path. }
        K := Path.Count - 1;
        for I := 0 to 2 do
          for J := 0 to K do
          begin
            Point := TXYZ.Create;
            Point.X := Path[J].X;
            Point.Y := Path[J].Y;
            Effect.FPath.Add(Point);
          end;
        Path.Free;
      end;
    fxScreenSwarm:
      begin
        HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(FTargetX, FTargetY).FindOwnedChild($220104));
        if HS = nil then Target := nil else Target := HS.FUnit;
        DX := FTargetX; DY := FTargetY;
        ChooseTarget;
        if Target <> nil then begin DX := Target.FUnitHS.Xhx; DY := Target.FUnitHS.Yhx; end;
        Effect.FTarget := Target;
        HXtoHP(DX, DY, X2, Y2);
        if FStrikeIndex = 0 then AoWCombatMap.CenterViewTo(FTargetX, FTargetY, 0);
        Point := TXYZ.Create;
        Point.X := X2; Point.Y := Y2;
        Effect.FPath.Add(Point);
        MakeSwarmPath(Random(10) + 10, Random(10) + 25, Random(90), Random(360),
          Random(20), Random(20) - 10, TSwarmDirection(Random(2)), Effect.FPath);
        K := Effect.FPath.Count - 1;
        for I := 0 to 4 do
          for J := 1 to K do
          begin
            Point := TXYZ.Create;
            Point.X := Effect.FPath[J].X; Point.Y := Effect.FPath[J].Y;
            Effect.FPath.Add(Point);
          end;
        for I := 0 to 49 do Effect.FPath[I + 1].Z := 100 - I * 2;
      end;
    fxFrostBeam:
      begin
        HXtoHP(FTargetX, FTargetY, X2, Y2);
        Effect.FTargetX := FTargetX; Effect.FTargetY := FTargetY;
        AoWCombatMap.CenterViewTo(FTargetX - 3, FTargetY - 3, 0);
        MakeArcPathXY(X2 - 200, Y2 - 200, X2 + 16, Y2 + 16, 5, 100, Effect.FPath);
      end;
    fxRay:
      begin
        AoWCombatMap.MakeVisible(FTargetX - 3, FTargetY - 3, 0, 3);
        MakeRangedPath(FUnit.GetSide, 10, 0, 50, FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx,
          FTargetX, FTargetY, 0, 0, True, Effect.FPath, Obstacles);
      end;
  else
    MakeAbilPath(FUnit.GetSide, FAbilityID, FSpellID, FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx,
      FTargetX, FTargetY, Effect.FPath, Obstacles);
  end;
  Effect.FAbilityIndex := FAbilityID;
  Effect.FSpellIndex := FSpellID;
  Effect.FEffectType := FEffectType;
  case FEffectType of
    fxArrow, fxRock, fxComet, fxBreath, fxCometBall, fxRay, fxSwarm, fxAltArrow:
      begin
        HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(FTargetX, FTargetY).FindOwnedChild($220104));
        if HS <> nil then Effect.FTarget := HS.FUnit;
        I := 0;
        while I < Obstacles.Count do
        begin
          Obstacle := TROb(Obstacles[I]);
          if AoWHSMap.Random(100) < Obstacle.Chance then
          begin
            HPtoHX(Effect.FPath[Obstacle.PathIndex].X, Effect.FPath[Obstacle.PathIndex].Y, J, K);
            if Effect.FEffectType = fxBreath then HitObject := nil
            else HitObject := THexagonSprite(AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).FindOwnedChild($220104));
            if HitObject = nil then HitObject := THexagonSprite(AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).FindOwnedChild($220166));
            if HitObject = nil then HitObject := THexagonSprite(AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).FindOwnedChild($220504));
            if HitObject = nil then HitObject := THexagonSprite(AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).FindOwnedChild($220506));
            if (HitObject <> nil) or (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).TerrainType = 15) or
              (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).TerrainType = 7) or
              (AoWCombatMap.MapContainer.MapLevels[0].GetField(J, K).OverlayType = 8) then
            begin
              for J := Obstacle.PathIndex + 1 to Effect.FPath.Count - 1 do Effect.FPath.Delete(Effect.FPath.Count - 1);
              if not (HitObject is TTacticalCombatUnitHS) then
              begin
                Effect.FTarget := nil;
                if Effect.FEffectType = fxBreath then Effect.FTargetX := 0;
              end
              else Effect.FTarget := TTacticalCombatUnitHS(HitObject).FUnit;
              I := Obstacles.Count;
            end;
          end;
          Inc(I);
        end;
      end;
  end;
  if FEffectType = fxBreath then Effect.FTarget := nil
  else case FAbilityID of
    31: Effect.FTarget := nil;
    52: case FSpellID of
      104, 107, 113, 116, 117, 127, 129, 130: Effect.FTarget := nil;
      102, 106, 120, 128: Effect.FTarget := FUnit;
      115: if AoWHSMap.Random(100) < 75 then Effect.FTarget := nil;
      100:
        begin
          ExtraEffect := AoWCombatMap.AddEffect(fxSFOverlay);
          HXtoHP(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, X1, Y1);
          while ExtraEffect.FPath.Count < Effect.FPath.Count do
          begin
            Point := TXYZ.Create;
            Point.X := X1 + 16; Point.Y := Y1;
            ExtraEffect.FPath.Add(Point);
          end;
          ExtraEffect.FAbilityIndex := FAbilityID; ExtraEffect.FSpellIndex := FSpellID;
        end;
    end;
  end;
  Effect.FVariant := GetRangedDirIndex(FTargetX - FUnit.FUnitHS.Xhx, FTargetY - FUnit.FUnitHS.Yhx);
  if FStrikeIndex = 0 then
    case FEffectType of
      fxArrow, fxRock, fxComet, fxBreath, fxCometBall, fxEffect, fxRay, fxChain, fxSwarm,
      fxScreenSwarm, fxSFOverlay, fxDispel, fxAltArrow, fxGeyser, fxFrostBeam:
        case Effect.FVariant of
          0, 1, 23: FUnit.FUnitHS.SetDirection(1);
          2..6: FUnit.FUnitHS.SetDirection(2);
          7..10: FUnit.FUnitHS.SetDirection(3);
          11..13: FUnit.FUnitHS.SetDirection(4);
          14..17: FUnit.FUnitHS.SetDirection(5);
          18..22: FUnit.FUnitHS.SetDirection(6);
        end;
    end;
  if FEffectType in [fxRock, fxComet, fxBreath, fxCometBall, fxScreenNS] then Effect.FVariant := 0;
  if (FEffectType = fxBreath) and (FStrikeIndex = 0) then FUnit.FUnitHS.SetAction(caBreathAttack)
  else if ((FAbilityID <> 52) and (AbilTypes[FAbilityID] <> fxBreath)) or (FStrikeIndex = 0) then
    FUnit.FUnitHS.SetAction(caAbility);
  for I := 0 to Obstacles.Count - 1 do TObject(Obstacles[I]).Free;
  Obstacles.Free;
  Inc(FStrikeIndex);
end;

procedure MakeDEHSList(X, Y: Integer; DamageTypes: TDamageTypes; Resisted: Boolean);
  procedure MakeEffect(EffectType: TfxType);
  var
    Effect: TfxHS;
    I, Count: Integer;
    Z, Speed, VZ, Gravity: Single;
  begin
    Count := Random(5) + 8;
    for I := 1 to Count - 1 do
    begin
      Effect := AoWCombatMap.AddEffect(EffectType);
      Speed := (Random(10) + 10) * 0.1;
      Gravity := 0.5;
      if Resisted or (EffectType = fxDamMagic) then
        VZ := (Random(50) + 50) * 0.1
      else
        VZ := (Random(25) + 25) * 0.1;
      Z := 0;
      MakeArcPath(X, Y, I * 360 div Count, Z, Speed, VZ, Gravity, Effect.FPath);
    end;
  end;
begin
  X := X + 16;
  if dtLightning in DamageTypes then MakeEffect(fxDamLightning);
  if dtFire in DamageTypes then MakeEffect(fxDamFire);
  if dtPoison in DamageTypes then MakeEffect(fxDamPoison);
  if dtMagic in DamageTypes then MakeEffect(fxDamMagic);
  if dtHoly in DamageTypes then MakeEffect(fxDamHoly);
  if dtDeath in DamageTypes then MakeEffect(fxDamDeath);
  if dtCold in DamageTypes then MakeEffect(fxDamCold);
end;

function CreateTCEndCombatTE: TCEndCombatTE;
begin Result := TCEndCombatTE.Create(nil); end;

function CreateTCEndTurnTE(Player: Shortint): TCEndTurnTE;
begin
  if (Player <> -1) and AoWHSMap.FTokenManager.PlayerReady(Player) then
    Result := TCEndTurnTE.Create(nil)
  else Result := nil;
end;

function CreateTCCancelEndTurnTE(Player: Shortint): TCEndTurnTE;
begin
  if not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy then
    Result := TCEndTurnTE.Create(nil)
  else Result := nil;
end;

procedure MakeHitBlood(UnitObject: TTacticalCombatUnit; Damage: Integer);
var
  Effect: TfxHS;
  Point: TXYZ;
begin
  Effect := AoWCombatMap.AddEffect(fxBlood);
  Point := TXYZ.Create;
  Effect.FPath.Add(Point);
  case Damage of
    1..3: Point.Z := 1;
    4..7: Point.Z := 2;
    8..100: Point.Z := 3;
  end;
  case UnitObject.FUnit.GetBloodType of btNone: Point.Z := Point.Z + 5; end;
  HXtoHP(UnitObject.FUnitHS.Xhx, UnitObject.FUnitHS.Yhx, Point.X, Point.Y);
  Point.X := Random(10) + Point.X + 11;
  Point.Y := Random(10) + Point.Y + 9 - Ord(UnitObject.FUnit.GetUnitSize) * 10;
end;

function CreateTCMeleeMoveTE(UnitObject: TTacticalCombatUnit; Path: TMovepath): TCMeleeMoveTE;
begin
  Result := TCMeleeMoveTE.Create(nil);
  if Result <> nil then Result.Setup(UnitObject, Path);
end;

function CreateTCAbTouchMoveTE(UnitObject: TTacticalCombatUnit; Path: TMovepath; AbilityID: Integer): TCAbTouchMoveTE;
begin
  Result := TCAbTouchMoveTE.Create(nil);
  if Result <> nil then
  begin
    Result.Setup(UnitObject, Path);
    Result.FAbilityID := AbilityID;
  end;
end;

function CreateTCAbRangedTE(UnitObject: TTacticalCombatUnit; X, Y: Word; AbilityID, SpellID: Integer): TCAbRangedTE;
begin
  Result := TCAbRangedTE.Create(nil);
  if Result <> nil then
  begin
    Result.FSourceX := UnitObject.FUnitHS.Xhx;
    Result.FSourceY := UnitObject.FUnitHS.Yhx;
    Result.FTargetX := X;
    Result.FTargetY := Y;
    Result.FAbilityID := AbilityID;
    Result.FSpellID := SpellID;
  end;
end;

function CreateCombatMoveTE(UnitObject: TTacticalCombatUnit; Path: TMovepath): TCombatMoveTE;
begin
  Result := TCombatMoveTE.Create(nil);
  if Result <> nil then Result.Setup(UnitObject, Path);
end;

function MoveCombatUnit(UnitObject: TTacticalCombatUnit; Path: TMovepath): Boolean;
var
  MovePoints, Cost, Index: Integer;
  Event: TCombatMoveTE;
  NewPath: TMovepath;
  I: Integer;
begin
  Result := False;
  if AoWHSMap.FTokenManager.PlayerReady(UnitObject.GetPlayer) and (Path.Count > 1) then
  begin
    MovePoints := UnitObject.FMovePoints;
    Cost := 0;
    Index := Path.Count;
    while (Index <> 0) and (Cost <= MovePoints) do
    begin
      Index := Index - 1;
      Cost := Cost + Path[Index].Flag;
    end;
    if Cost > MovePoints then Index := Index + 1;
    if Index < Path.Count - 1 then
    begin
      NewPath := TMovepath.Create;
      for I := Index to Path.Count - 1 do NewPath.Add(Path[I]);
      Event := CreateCombatMoveTE(UnitObject, NewPath);
      if Event <> nil then
      begin
        AoWHSMap.FTokenManager.GetTokenControl(UnitObject.GetPlayer).AddEvent(Event);
        Event.Release;
        Result := True;
      end;
      NewPath.Free;
    end;
  end;
end;

function ValidateTCMovePosition(Moves: TMoveSettingsList; Index: Integer): Boolean;
var
  I: Integer;
  Settings: TMoveSettings;
begin
  Result := True;
  if Result then
    for I := Moves.Count - 1 downto 0 do
      if I <> Index then
      begin
        Settings := Moves.GetMoveSettings(I);
        if Settings.FValid and
          (Moves.GetMoveSettings(Index).GetMovePrio >= Settings.GetMovePrio) and
          (Settings.GetMoveLoc.XYL = Moves.GetMoveSettings(Index).GetMoveLoc.XYL) then Result := False;
      end;
end;

function SetupMultiTCUnitMove(Moves: TMoveSettingsList): Boolean;
var
  Multi: TMultiMoveTE;
  MoveEvent: TCombatMoveTE;
  Path: TMovepath;
  I, J, K, L: Integer;
begin
  if (Moves.Count <> 0) and AoWHSMap.FTokenManager.PlayerReady(
    TTacticalCombatUnitHS(Moves.GetMoveSettings(0).FMoveObject).FUnit.GetPlayer) then
  begin
    Path := TMovepath.Create;
    Multi := TMultiMoveTE.Create(nil);
    Multi.FSimultaneous := False;
    Moves.CalculateMovePositions(ValidateTCMovePosition);
    for I := 1 to Moves.Count - 1 do
      for J := 0 to I - 1 do
        if Moves.GetMoveSettings(J).FPath.Count > Moves.GetMoveSettings(I).FPath.Count then
          Moves.FChildren.Exchange(I, J);
    for K := 0 to Moves.Count - 1 do
    with Moves.GetMoveSettings(K) do
    begin
      if FMovePos < FPath.Count - 1 then
      begin
        Path.Clear;
        for L := FMovePos to FPath.Count - 1 do Path.Add(FPath[L]);
        MoveEvent := TCombatMoveTE.Create(nil);
        if MoveEvent.Setup(TTacticalCombatUnitHS(FMoveObject).FUnit, Path) then Multi.FEvents.Add(MoveEvent);
        MoveEvent.Release;
      end;
    end;
    if Multi.FEvents.Count <> 0 then
    begin
      AoWHSMap.FTokenManager.GetTokenControl(
        TTacticalCombatUnitHS(Moves.GetMoveSettings(0).FMoveObject).FUnit.GetPlayer).AddEvent(Multi);
      Result := True;
    end
    else Result := False;
    Multi.Release;
    Path.Free;
    for K := 0 to AoWCombatMap.FUnitSelection.FMoveSettingsList.Count - 1 do
      with AoWCombatMap.FUnitSelection.FMoveSettingsList.GetMoveSettings(K) do FPath.Clear;
  end
  else Result := False;
end;

procedure RegisterCombatTE(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCombatMoveTE, TCMeleeMoveTE, TCAbTouchMoveTE,
    TCAbRangedTE, TCEndTurnTE, TCEndCombatTE, TTerminateCombatTE]);
end;


initialization
finalization

end.
