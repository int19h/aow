unit CombatTE;

{ CombatTE, AoWTCPCK.dpl: partly recovered combat events.
  Original layouts and VMT order; remaining draft handlers retain their stubs.
  TCombatMoveTE: $1C unit, $20 delay, $24 struck units, $28 previous unit,
  $2C free-striking unit, $30 neighbour, $31 step, $34 strike.
  TCMeleeMoveTE: $38 melee round, $3C strike index.
  Touch event: $3C ability ID. Ranged event: $14 ability ID, $18 spell ID,
  $1C/$1E source coordinates, $20/$22 target coordinates. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC;

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
    F_CAbTouchMoveTE_38: Integer;
    FAbilityID: Integer; { $3C }
    F_CAbTouchMoveTE_40: Integer;
    F_CAbTouchMoveTE_44: Integer;
    F_CAbTouchMoveTE_48: Integer;
    F_CAbTouchMoveTE_4C: Integer;
    F_CAbTouchMoveTE_50: Integer;
    F_CAbTouchMoveTE_54: Integer;
    F_CAbTouchMoveTE_58: Integer;
    F_CAbTouchMoveTE_5C: Integer;
    F_CAbTouchMoveTE_60: Byte;
    F_CAbTouchMoveTE_61: Byte;
    F_CAbTouchMoveTE_62: array[0..1] of Byte;
    F_CAbTouchMoveTE_64: Integer;
    F_CAbTouchMoveTE_68: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function LastMove: AoWE.TMoveStatus; override;
  end;

  { TCAbRangedTE (instance size 60, VMT 0040799C) }
  TCAbRangedTE = class(TTokenEvent)
  public
    F_CAbRangedTE_10: Integer;
    FAbilityID: Integer; { $14 }
    FSpellID: Integer; { $18 }
    FSourceX: Word; { $1C }
    FSourceY: Word; { $1E }
    FTargetX: Word; { $20 }
    FTargetY: Word; { $22 }
    F_CAbRangedTE_24: Byte;
    F_CAbRangedTE_25: array[0..2] of Byte;
    F_CAbRangedTE_28: Integer;
    F_CAbRangedTE_2C: Integer;
    F_CAbRangedTE_30: Integer;
    F_CAbRangedTE_34: Integer;
    F_CAbRangedTE_38: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure NextStrike(A1: Integer; A2: Integer);  { draft }
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
    HN, NY, NX: Integer;
    HS: TTacticalCombatUnitHS;
  begin
    if FUnit.GetEnabled and (FFreeStrikeUnit = nil) then
    begin
      MapField := TAoWMapField(FUnit.FUnitHS.Owner);
      HN := FNeighbour + 1;
      while HN < 7 do
      begin
        CenterHNtoHX(FUnit.FUnitHS.Xhx, FUnit.FUnitHS.Yhx, HN, NX, NY);
        HS := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].GetField(NY, NX).FindOwnedChild($220104));
        if (HS <> nil) and (FPreviousUnit <> HS.FUnit) and HS.FUnit.GetEnabled and
          not HS.FUnit.GetLocked and (MeleeDamageTypes(HS.FUnit) <> []) and
          (HS.FUnit.GetSide <> FUnit.GetSide) and (HS.FAction = caMove) and
          (HS.FUnit.GetAbilityEnabled(1) = FUnit.GetAbilityEnabled(1)) then
        begin
          FNeighbour := HN;
          FFreeStrikeUnit := HS.FUnit;
          for NY := 0 to FObjects.Count - 1 do
            if FObjects[NY] = FFreeStrikeUnit then FFreeStrikeUnit := nil;
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
            if FUnit.FUnitHS.MoveFirst(Byte(Direction), False) = -1 then Result := msFailed
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
          if HS <> nil then FPreviousUnit := HS.FUnit else FPreviousUnit := nil;
          if FPreviousUnit <> nil then
          begin
            FMeleeRound := TMeleeRound.Create;
            FMeleeRound.Calculate(FUnit, FPreviousUnit);
            if FMeleeRound.FCount <> 0 then
            begin
              FUnit.FUnitHS.SetAction(caStepUp);
              FUnit.FUnitHS.SetDirection(GetMeleeDirIndex(FUnit.FUnitHS.Xhx,
                FUnit.FUnitHS.Xhx - FPreviousUnit.FUnitHS.Xhx,
                FUnit.FUnitHS.Yhx - FPreviousUnit.FUnitHS.Yhx));
              FPreviousUnit.FUnitHS.SetDirection(FUnit.FUnitHS.FDirection + 3);
              if FPreviousUnit.FUnitHS.FDirection > 6 then
                FPreviousUnit.FUnitHS.SetDirection(FPreviousUnit.FUnitHS.FDirection - 6);
            end
            else Result := msDone;
          end
          else Result := msDone;
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
                MakeDEHSList(X + FUnit.FUnitHS.F_TacticalCombatUnitHS_2C,
                  Y + FUnit.FUnitHS.F_TacticalCombatUnitHS_30, FStrike.FDamageTypes.Value - FStrike.FEffects.Value, False);
              if FStrike.FEffects.Value <> [] then
                MakeDEHSList(X + FUnit.FUnitHS.F_TacticalCombatUnitHS_2C,
                  Y + FUnit.FUnitHS.F_TacticalCombatUnitHS_30, FStrike.FEffects.Value, True);
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
              if not FUnit.GetEnabled then Result := msDone else NextStrike;
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
begin FillChar(Result, SizeOf(Result), 0); end;

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
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCAbRangedTE.NextStrike(A1: Integer; A2: Integer);
begin end;

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
  if UnitObject.FUnit.GetBloodType in [btNone] then Point.Z := Point.Z + 5;
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
  NewPath: TMovepath;
  Event: TCombatMoveTE;
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
      Result := Event <> nil;
      if Result then
      begin
        AoWHSMap.FTokenManager.GetTokenControl(UnitObject.GetPlayer).AddEvent(Event);
        Event.Release;
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
  Path: TMovepath;
  Multi: TMultiMoveTE;
  MoveEvent: TCombatMoveTE;
  Settings: TMoveSettings;
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
    begin
      Settings := Moves.GetMoveSettings(K);
      if Settings.FMovePos < Settings.FPath.Count - 1 then
      begin
        Path.Clear;
        for L := Settings.FMovePos to Settings.FPath.Count - 1 do Path.Add(Settings.FPath[L]);
        MoveEvent := TCombatMoveTE.Create(nil);
        if MoveEvent.Setup(TTacticalCombatUnitHS(Settings.FMoveObject).FUnit, Path) then Multi.FEvents.Add(MoveEvent);
        MoveEvent.Release;
      end;
    end;
    Result := Multi.FEvents.Count <> 0;
    if Result then AoWHSMap.FTokenManager.GetTokenControl(
      TTacticalCombatUnitHS(Moves.GetMoveSettings(0).FMoveObject).FUnit.GetPlayer).AddEvent(Multi);
    Multi.Release;
    Path.Free;
    for K := 0 to AoWCombatMap.FUnitSelection.FMoveSettingsList.Count - 1 do
      AoWCombatMap.FUnitSelection.FMoveSettingsList.GetMoveSettings(K).FPath.Clear;
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
