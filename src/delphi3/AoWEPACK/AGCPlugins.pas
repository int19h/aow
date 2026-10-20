unit AGCPlugins;

{ AI group razing, defensive target selection and wandering in AoWEPACK.dpl. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, City;

type
  TAIGroupRazeControl = class;
  TAIGroupDefendTargetSelector = class;
  TAIGroupWanderControl = class;

  TAIGroupRazeControlMode = set of (rcmCannotDefend, rcmOnMigrate, rcmAlways); { ot=1 }
  TAIGroupDefendTargetSelectorMode = set of (dtmCalculateMovepathBFS); { ot=1 }
  TAIGroupWanderMode = set of (wmTransportersAllowed); { ot=1 }

  { TAIGroupRazeControl: size $2C, VMT 557D70AC; fields $1C control, $20 mode,
    $21 damage types, $24 structure factor, $28 city factor. }
  TAIGroupRazeControl = class(TAIGroupControlPlugin)
  public
    FControl: TAIGroupControl; { $1C }
    FMode: TAIGroupRazeControlMode; { $20 }
    FDamageTypes: TDamageTypes; { $21 }
    FReserved23: Byte;
    FStructureStrengthFactor: Single; { $24 }
    FCityStrengthFactor: Single; { $28 }
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    procedure Reset;
    function Setup: Boolean;
    procedure ExecuteRaze(Structure: TStructure);
    function ValidateRazeCity(City: TCity; const Info: TBattleFieldInfo): Boolean;
    function ValidateRazeStructure(Structure: TStructure; const Info: TBattleFieldInfo): Boolean;
  end;

  { TAIGroupDefendTargetSelector: size $3C, VMT 557D71EC; $1C control,
    $20 selector, $24 targets, $28 mode, $2C path step, $30 radius, $34 damage, $38 factor. }
  TAIGroupDefendTargetSelector = class(TAIGroupControlPlugin)
  public
    FControl: TAIGroupControl; { $1C }
    FSelector: TAIMoveTargetSelector; { $20 }
    FTargets: TAIGroupControlTargetList; { $24 }
    FMode: TAIGroupDefendTargetSelectorMode; { $28 }
    FReserved29: array[0..2] of Byte;
    FPathStep: Integer; { $2C }
    FBattleFieldRadius: Integer; { $30 }
    FDamageTypes: TDamageTypes; { $34 }
    FReserved36: array[0..1] of Byte;
    FMovePointsFactor: Single; { $38 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    procedure Reset;
    function GetMovepathBattleFieldStrength(Path: TMovepath): Integer;
    procedure TargetFoundEvent(Target: TMoveTarget; var SearchDone: Boolean);
    function Setup(Control: TAIGroupControl): Boolean;
  end;

  { TAIGroupWanderControl: size $2C, VMT 557D7334; $1C mode, $20 move limit,
    $24 move settings, $28 control. }
  TAIGroupWanderControl = class(TAIGroupControlPlugin)
  public
    FMode: TAIGroupWanderMode; { $1C }
    FReserved1D: array[0..2] of Byte;
    FMovePointsMax: Integer; { $20 }
    FMoveSettings: TMoveControlSettings; { $24 }
    FControl: TAIGroupControl; { $28 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    procedure Reset;
    function Setup: Boolean;
  end;


implementation

type
  PAoWHSMap = ^TAoWHSMap;
  PDamageTypes = ^TDamageTypes;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  AllDamageTypes: TDamageTypes = [dtFire..dtNone];
  DamageTypes: PDamageTypes = @AllDamageTypes;

procedure TAIGroupRazeControl.Reset;
begin
  FDamageTypes := DamageTypes^ - [dtWall];
  FMode := [rcmCannotDefend];
  FCityStrengthFactor := 2;
  FStructureStrengthFactor := 2;
end;

function TAIGroupRazeControl.Setup: Boolean;
begin Reset; Result := True; end;

function TAIGroupRazeControl.Activate(Control: TAIGroupControl): Boolean;
begin
  FState := 0;
  FControl := Control;
  Result := True;
end;

procedure TAIGroupRazeControl.ExecuteRaze(Structure: TStructure);
begin Structure.Raze(FControl.FGroup.FPlayer); end;

function TAIGroupRazeControl.ValidateRazeCity(City: TCity; const Info: TBattleFieldInfo): Boolean;
begin
  case WorldMap^.FRaces.GetRace(City.FRace).GetPlayerRelation(FControl.FGroup.FPlayer) of
    sHostile, sWary:
      begin
        Result := rcmAlways in FMode;
        if rcmOnMigrate in FMode then Result := True;
        if rcmCannotDefend in FMode then
          Result := Result or (Round(Info.FriendlyStrength * FCityStrengthFactor) < Info.Strength);
      end;
  else Result := rcmAlways in FMode;
  end;
end;

function TAIGroupRazeControl.ValidateRazeStructure(Structure: TStructure; const Info: TBattleFieldInfo): Boolean;
begin
  Result := False;
  if rcmAlways in FMode then Result := True;
  if (rcmCannotDefend in FMode) and
    (Round(Info.FriendlyStrength * FStructureStrengthFactor) < Info.Strength) then Result := True;
end;

function TAIGroupRazeControl.Process: Boolean;
var
  Structure: TStructure;
  Info: TBattleFieldInfo;
begin
  if FState = 0 then
      begin
        Structure := TStructure(WorldMap^.MapContainer.GetFieldXYL(Integer(FControl.FLocation)).FindNoneTransparentHS(TStructure));
        if (Structure <> nil) and Structure.GetRazeable then
        begin
          SetupBattleFieldInfo(Info, FControl.FGroup.FPlayer, Shortint(FControl.FGroup.FIndependentRelation),
            [bfrIgnoreIndependents], FDamageTypes);
          WorldMap^.RetrieveBattleFieldInfo(FControl.FLocation.X, FControl.FLocation.Y,
            FControl.FLocation.L, 15, Info);
          if Structure is TCity then Result := ValidateRazeCity(TCity(Structure), Info)
          else Result := ValidateRazeStructure(Structure, Info);
          if Result then ExecuteRaze(Structure);
        end;
        Done;
      end
  else Done;
  Result := False;
end;

constructor TAIGroupDefendTargetSelector.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelector := TAIMoveTargetSelector.Create(nil);
  FTargets := TAIGroupControlTargetList.Create(nil);
end;

destructor TAIGroupDefendTargetSelector.Destroy;
begin
  FSelector.Free;
  FTargets.Free;
  inherited Destroy;
end;

procedure TAIGroupDefendTargetSelector.Reset;
begin
  FSelector.Reset;
  with FSelector do
  begin
    FOnTargetFound := TargetFoundEvent;
    FMovePointsMax := 150;
    FMovePointsMin := 0;
    FTargetInfo.Mode := tmDefend;
  end;
  FPathStep := 7;
  FDamageTypes := DamageTypes^ - [dtWall];
  FBattleFieldRadius := 10;
  FMovePointsFactor := -1;
  FMode := [];
end;

function TAIGroupDefendTargetSelector.GetMovepathBattleFieldStrength(Path: TMovepath): Integer;
var
  I: Integer;
  Info: TBattleFieldInfo;
begin
  if (Path <> nil) and (FPathStep < Path.Count) then
  begin
    Result := 0;
    I := FPathStep;
    SetupBattleFieldInfo(Info, FControl.FGroup.FPlayer, Shortint(FControl.FGroup.FIndependentRelation),
      [], FDamageTypes);
    Info.FriendlyRelations := [];
    Info.Requests := Info.Requests + [bfrIgnorePassiveIndependents];
    while I < Path.Count do
    begin
      Info.Strength := 0;
      WorldMap^.RetrieveBattleFieldInfo(Path[I].X, Path[I].Y, Path[I].L,
        FBattleFieldRadius, Info);
      if Result < Info.Strength then Result := Info.Strength;
      Inc(I, FPathStep);
    end;
  end
  else Result := 0;
end;

procedure TAIGroupDefendTargetSelector.TargetFoundEvent(Target: TMoveTarget; var SearchDone: Boolean);
var NewTarget: TAIGroupControlTarget;
begin
  NewTarget := TAIGroupControlTarget.Create(nil);
  with FSelector do NewTarget.FInfo := FTargetInfo;
  NewTarget.FData := Target.FData;
  NewTarget.FLocation := Target.FLocation;
  NewTarget.FMovePoints := Target.FMovePoints;
  Inc(NewTarget.FData.Priority, Round(Target.FMovePoints * FMovePointsFactor));
  if dtmCalculateMovepathBFS in FMode then
    NewTarget.FPathStrength := GetMovepathBattleFieldStrength(Target.FMovepath);
  if Target.FTransporterID <> -1 then NewTarget.FTransporterID := Target.FTransporterID;
  if NewTarget.FPathStrength < FControl.FStrengthMax then FTargets.Add(NewTarget);
  NewTarget.Release;
end;

function TAIGroupDefendTargetSelector.Setup(Control: TAIGroupControl): Boolean;
begin
  Reset;
  with FSelector do
  begin
    FSourceLocation := Control.FLocation;
    FMovePointTable := Control.FMovePointTable;
    FTargetInfo.Player := Control.FGroup.FPlayer;
    FTargetInfo.IndependentRelation := Shortint(Control.FGroup.FIndependentRelation);
  end;
  case WorldMap^.FPlayers.GetPlayers(Control.FGroup.FPlayer).FPlayerType of
    ptCPU2: FMode := FMode + [dtmCalculateMovepathBFS];
    ptCPU3: FMode := FMode + [dtmCalculateMovepathBFS];
    ptCPU4: FMode := FMode + [dtmCalculateMovepathBFS];
    ptCPU5: FMode := FMode + [dtmCalculateMovepathBFS];
  end;
  Result := True;
end;

function TAIGroupDefendTargetSelector.Activate(Control: TAIGroupControl): Boolean;
begin
  FControl := Control;
  FSelector.Search(Control);
  FState := 0;
  Result := True;
end;

function TAIGroupDefendTargetSelector.Process: Boolean;
begin
  case FState of
    0:
      begin
        if FSelector.FStatus = atsSearching then Result := FSelector.Process
        else Result := False;
        if not Result then
        begin
          FTargets.SortOnPriority;
          Inc(FState);
        end;
      end;
    1:
      begin
        if FTargets.Count <> 0 then
        begin
          FControl.FGroup.SetupTarget(nil, gtsIdle, 0);
          FControl.SetupME;
          if Integer(FTargets.GetTargets(0).FLocation) = Integer(FControl.FLocation) then
            FControl.FMoveExecuter.FMode := FControl.FMoveExecuter.FMode - [memAdjacent];
          FControl.ExecuteME(FTargets.GetTargets(0).FLocation.X,
            FTargets.GetTargets(0).FLocation.Y, FTargets.GetTargets(0).FLocation.L);
          FState := 2;
        end
        else
        begin
          FControl.SetupME;
          with FControl.FMoveExecuter do FMode := FMode - [memAdjacent];
          with FControl do ExecuteME(FLocation.X, FLocation.Y, FLocation.L);
          FControl.FGroup.SetupTarget(nil, gtsIdle, 0);
          Done;
        end;
        Result := False;
      end;
    2:
      begin
        Done;
        Result := False;
      end;
  else Result := False;
  end;
end;

constructor TAIGroupWanderControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMoveSettings := TMoveControlSettings.Create(nil);
end;

destructor TAIGroupWanderControl.Destroy;
begin
  FMoveSettings.Release;
  inherited Destroy;
end;

procedure TAIGroupWanderControl.Reset;
begin
  FMode := [];
  FMovePointsMax := 75;
  FMoveSettings.Reset;
end;

function TAIGroupWanderControl.Setup: Boolean;
begin Reset; Result := True; end;

function TAIGroupWanderControl.Activate(Control: TAIGroupControl): Boolean;
begin
  FControl := Control;
  FState := 0;
  Result := True;
end;

function CompareWanderFields(const Item1, Item2: TDoubleItem): Integer;
begin Result := Item2.B - Item1.B; end;

function TAIGroupWanderControl.Process: Boolean;
var
  Control: TAIGroupControl;
  Settings: TMoveControlSettings;
  Fields: TDoubleItemList;
  Field: TAoWMapField;
  I: Integer;
  Location: TXYL;
begin
  case FState of
    0:
      begin
        Control := FControl;
        FMoveSettings.Reset;
        with FMoveSettings do
        begin
          FPlayer := Control.FGroup.FPlayer;
          FMode := FMode + [mmAI];
          SetSourcePos(Control.FLocation.X, Control.FLocation.Y, Control.FLocation.L);
        end;
        with FMoveSettings do
        begin
          FMovePointsMax := Self.FMovePointsMax;
          FArmyHS := Control.FArmyHS;
          FSelection := Control.FSelection;
          FMovePointTable := Control.FMovePointTable;
          FMode := FMode + [mmLogProcessedMapFields];
          WorldMap^.FMoveControl.ProcessMove(FMoveSettings);
        end;
        with Control.FGroup do
          if (FTargetMode = 1) and (FTargetXYL.X > 0) and
            (FMoveSettings.GetMovePoints(FTargetXYL.X,
              FTargetXYL.Y,
              FTargetXYL.L) <> $FFFFFF) and
            (Integer(FControl.FGroup.FTargetXYL) <> Integer(Control.FLocation)) then FState := 2
          else FState := 1;
        Result := False;
      end;
    1:
      begin
        Settings := FMoveSettings;
        Fields := TDoubleItemList.Create;
        if Settings.FProcessedMapFields.Count > 40 then
        begin
          for I := Settings.FProcessedMapFields.Count - 1 downto 0 do
            if I and 3 = 3 then
            begin
              Field := Settings.FProcessedMapFields[I];
              if FMoveSettings.GetMovePoints(Field.Xhx, Field.Yhx, Field.Lhx) <> $FFFFFF then
                Fields.AddAB(Integer(Field), FMoveSettings.GetMovePoints(Field.Xhx, Field.Yhx, Field.Lhx));
            end;
        end
        else
          for I := Settings.FProcessedMapFields.Count - 1 downto 0 do
          begin
            Field := Settings.FProcessedMapFields[I];
            if FMoveSettings.GetMovePoints(Field.Xhx, Field.Yhx, Field.Lhx) <> $FFFFFF then
              Fields.AddAB(Integer(Field), FMoveSettings.GetMovePoints(Field.Xhx, Field.Yhx, Field.Lhx));
          end;
        if Fields.Count > 0 then
        begin
          Fields.Sort(CompareWanderFields);
          Field := nil;
          I := 0;
          while (Fields.Count <> 0) and (Field = nil) do
          begin
            I := WorldMap^.Random(Round(Fields.Count * 0.2) + 1);
            Field := TAoWMapField(Fields[I].A);
            if Field.GetPlayer <> -1 then
            begin
              Fields.Delete(I);
              Field := nil;
            end;
          end;
          if Field <> nil then
          begin
            Location.XYL := Field.GetXYL;
            FControl.FGroup.SetupTargetEx(Location, Fields[I].B, gtsExecute, 1, -1, 0, 0);
            Inc(FState);
          end
          else Done;
          Fields.Free;
        end
        else Done; { Original leaks Fields when no reachable field was collected. }
        Result := False;
      end;
    2:
      begin
        with FControl do
        begin
          SetupME;
          ExecuteME(FGroup.FTargetXYL.X,
            FGroup.FTargetXYL.Y,
            FGroup.FTargetXYL.L);
        end;
        Inc(FState);
        Result := False;
      end;
    3:
      begin
        Done;
        Result := False;
      end;
  else Result := False;
  end;
end;

initialization
finalization
end.
