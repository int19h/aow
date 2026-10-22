unit Altar;

{ Altar targeting, recharge and AI recovered from AoWEPACK.dpl.
  TAltar adds $3C storm, $40 mode and $41 recharge days to TPlayerStructure. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Storms, AoWE;

type
  TAltar = class;
  TAltarResource = class;

  TAltarMode = (amIdle, amRazed, amRebuilding);  { ot=1 }

  { TAltar (instance size 68): $3C FStorm, $40 FMode, $41 FRechargeDays;
    $42..$43 alignment padding. VMT 557CE7C4. }
  TAltar = class(TPlayerStructure)
  public
    FStorm: TStorm; { $3C }
    FMode: TAltarMode; { $40 }
    FRechargeDays: Byte; { $41 }
    { $42..$43 alignment padding }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    function ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult; override;
    procedure NewDay; override;
    function GetCurrentActivityText: string; override;
    function ExecuteAI(Player: Shortint; Phase: Integer): Boolean; override;
    procedure SetPlayer(Player: Shortint); override;
    function GetDefaultAITargetPriority: Integer; override;
    function CreateStorm: TStorm; virtual;
    function StormTargetSelected(X, Y, L: Shortint): Boolean; virtual;
    function GetRechargeDays: Byte; virtual;
    function CanTarget(var Reason: string): Boolean; virtual;
    function Target: Boolean; virtual;
    function CancelTargeting: Boolean; virtual;
    function TargetMana: Integer; virtual;
    procedure OnTargetSelectionChange(Sender: TObject);
    function GetTargeting: Boolean;
  end;

  { TAltarResource (instance size 116, no added fields, VMT 557CEA6C) }
  TAltarResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltar(AEngine: TEngine);

implementation

class function TAltar.ClassID: Integer;
begin Result := $203F1; end;

function TAltar.CreateStorm: TStorm;
begin Result := nil; end;

function TAltar.GetDefaultAITargetPriority: Integer;
begin
  Result := FRechargeDays * 10 + 10;
end;

function TAltar.GetCurrentActivityText: string;
begin
  if GetRechargeDays <> FRechargeDays then
    Result := AoWE.TranslateRStr(ChargingRStr) + ' (' +
      FmtDaysLeftStr(GetRechargeDays - FRechargeDays) + ')'
  else Result := AoWE.TranslateRStr(ReadyRStr);
end;

function TAltar.ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult;
var
  Reason: string;
begin
  Result := inherited ExecuteTE(A1, Executer);
  if A1.FAction = 0 then
  begin
    if (Executer.ExecuteCount = 0) and CanTarget(Reason) then
    begin
      FStorm := CreateStorm;
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.SetMana(
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana - TargetMana);
      FRechargeDays := 0;
      FStorm.InitializeStorm(FPlayer, Shortint(A1.FParam and $FF),
        Shortint((A1.FParam shr 8) and $FF), Shortint((A1.FParam shr 16) and $FF));
    end;
    if FStorm <> nil then
    begin
      if not FStorm.UpdateStorm then
      begin
        FStorm.FinalizeStorm;
        FStorm.Free;
        FStorm := nil;
        Result := erDone;
        Update;
      end
      else Result := erRetry;
    end
    else Result := erDoneHalt;
  end;
end;

function TAltar.StormTargetSelected(X, Y, L: Shortint): Boolean;
var
  Reason: string;
  Event: TStructureTE;
begin
  if CanTarget(Reason) and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    Event := CreateTE;
    SetupTE(Event);
    Event.FParam := X + (Y shl 8) + (L shl 16);
    Event.FAction := 0;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TAltar.OnTargetSelectionChange(Sender: TObject);
var
  Selection: TTargetSelectionControl;
begin
  Selection := TTargetSelectionControl(Sender);
  case Selection.FChange of
    tscDeactivated:
      begin
        FStorm.Free;
        FStorm := nil;
        Selection.FOnChange.Remove(OnTargetSelectionChange);
        Update;
      end;
    tscSelected:
      begin
        Selection.FOnChange.Remove(OnTargetSelectionChange);
        if StormTargetSelected(Selection.FTargetX, Selection.FTargetY, Selection.FTargetL) then
          Selection.Deactivate;
        FStorm.Free;
        FStorm := nil;
        Update;
      end;
  end;
end;

function TAltar.CanTarget(var Reason: string): Boolean;
begin
  if TargetMana <= AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana then
    Result := True
  else
  begin
    Result := False;
    Reason := AoWE.TranslateRStr(NotEnoughManaRStr);
  end;
end;

function TAltar.Target: Boolean;
var
  Selection: TTargetSelectionControl;
  Reason: string;
begin
  Selection := AoWHSMap.FTargetSelection;
  if not GetRazed and (FPlayer >= 0) and
    (TargetMana <= AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana) and
    CanTarget(Reason) and (FStorm = nil) then
  begin
    Selection.Initialize(Self);
    Selection.FTargetMode := Selection.FTargetMode + [tmValidateDistance, tmExternalFloater];
    Selection.FSourceX := GetXhx;
    Selection.FSourceY := GetYhx;
    Selection.FSourceL := GetLhx;
    Selection.FRange := 12;
    Selection.FOnChange.Add(OnTargetSelectionChange);
    FStorm := CreateStorm;
    FStorm.UpdateTargetSelection(AoWHSMap.FTargetSelection);
    Selection.FText.Text := SysUtils.Format(AoWE.TranslateRStr(SelectTargetLocationForXOnMapRStr), [FStorm.Name]);
    Selection.FTitle := EditName;
    Selection.FCancelText := AoWE.TranslateRStr(CancelRStr);
    Selection.FSourceImage := GetTopBorderImage;
    Selection.FValidTargetImage := GetMiddleBorderImage;
    Selection.FInvalidTargetImage := GetBottomBorderImage;
    Selection.Activate;
    Result := True;
    Update;
  end
  else Result := True; { Original reports success even when targeting cannot start. }
end;

function TAltar.GetTargeting: Boolean;
begin
  Result := (tsActivated in AoWHSMap.FTargetSelection.FStatus) and
    (Self = AoWHSMap.FTargetSelection.FSource);
end;

function TAltar.CancelTargeting: Boolean;
begin
  if GetTargeting then
  begin
    AoWHSMap.FTargetSelection.Deactivate;
    Result := True;
  end
  else Result := False;
end;

function TAltar.GetRechargeDays: Byte;
begin Result := 10; end;

function TAltar.TargetMana: Integer;
begin
  Result := (GetRechargeDays - FRechargeDays) * 50;
end;

procedure TAltar.NewDay;
begin
  inherited NewDay;
  if GetRechargeDays <> FRechargeDays then Inc(FRechargeDays);
end;

procedure TAltar.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FRechargeDays, $F);
  Stream.rwData(FMode, SizeOf(FMode), $10);
end;

procedure TAltar.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
  begin
    inherited SetPlayer(Player);
    if (Player = FPlayer) and (Self = AoWHSMap.FTargetSelection.FSource) then
      AoWHSMap.FTargetSelection.Deactivate;
  end;
end;

function TAltar.GetRazed: Boolean;
begin
  Result := FMode = amRazed;
end;

procedure TAltar.SetRazed(Value: Boolean);
begin
  if Value then
  begin
    SetPlayer(-1);
    FMode := amRazed;
  end
  else FMode := amIdle;
  FImageIndex := GetTerrainTypeImage(FTerrainType);
end;

function TAltar.ExecuteAI(Player: Shortint; Phase: Integer): Boolean;
var
  Storm: TStorm;
  Target: TXYL;
  Friendly, Enemy: TBattleFieldInfo;
  Damage: TStormDamageInfo;
  Value: Integer;
begin
  if (Player = FPlayer) and ((Phase = 1) or (Phase = 2)) then
  begin
    Storm := CreateStorm;
    if Storm.GetBestTarget(Player, GetXhx, GetYhx, GetLhx, 12, Target, Damage) then
    begin
      Value := Damage.EnemyDamage - Damage.FriendlyDamage;
      if Value > TargetMana * 0.75 then
        if AoWHSMap.FPlayers.GetPlayers(Player).FAIBudget.RequestBudgetExpense(
          0, TargetMana, AoWHSMap.FPlayers.GetPlayers(Player).FAIBudget.FDefaultBudget, True) then
        begin
          SetupBattleFieldInfo(Friendly, Player, 0, [], dtAll - [dtWall]);
          Friendly.EnemyRelations := [];
          AoWHSMap.RetrieveBattleFieldInfo(GetXhx, GetYhx, GetLhx, 1, Friendly);
          SetupBattleFieldInfo(Enemy, Player, 0, [], dtAll - [dtWall]);
          AoWHSMap.RetrieveBattleFieldInfo(GetXhx, GetYhx, GetLhx, 8, Enemy);
          if (Friendly.FriendlyStrength < Enemy.Strength) or (Value > 100) then
            if StormTargetSelected(Target.X, Target.Y, Target.L) then
              AoWHSMap.FPlayers.GetPlayers(Player).FAIBudget.BudgetExpenseMade(
                0, TargetMana, AoWHSMap.FPlayers.GetPlayers(Player).FAIBudget.FDefaultBudget,
                bemPoolThenBudget);
        end;
    end;
    Storm.Free;
  end;
  Result := False;
end;

constructor TAltarResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FClaimed := False;
  FRazeable := True;
  FRazeDefenderBudget := 150;
  FRebuildGold := 50;
  FRebuildDays := 2;
end;

class function TAltarResource.ResourceEditName: string;
begin Result := ''; end;

class function TAltarResource.ClassID: Integer;
begin Result := $203F2; end;

function TAltarResource.ResourceUserClassID: Integer;
begin Result := $203F1; end;

procedure RegisterAltar(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAltar, TAltarResource]);
end;

initialization
finalization

end.
