unit IndependentAG;

{ IndependentAG, from AoWEPACK.dpl. Guard and patrol groups recovered at the
  original instance layouts, including raid and scout controllers. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TGuardAG = class;
  TGuardAGC = class;
  TGuardAreaAG = class;
  TGuardAreaAGC = class;
  TPatrolAG = class;
  TPatrolAGC = class;
  TRefugeAG = class;
  TRefugeAGC = class;
  TRaidAG = class;
  TRaidAGC = class;
  TScoutAG = class;
  TScoutAGC = class;


  { TGuardAG (instance size 80, VMT 557D7E5C) }
  TGuardAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TGuardAGC (instance size 368, VMT 557D7FB0) }
  TGuardAGC = class(TAIGroupControl)
  public
  end;

  { TGuardAreaAG (instance size 84, VMT 557D80A8): $50 guard location. }
  TGuardAreaAG = class(TAIGroup)
  public
    FGuardLocation: TXYL; { $50 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TGuardAreaAGC (instance size 368, VMT 557D8204) }
  TGuardAreaAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone(Sender: TObject); override;
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); override;
    procedure ProcessStates; override;
    procedure ProcessStatesLooped; override;
  end;

  { TPatrolAG (instance size 96, VMT 557D8304): $50 from, $54 to, $58 previous heading, $5C strength. }
  TPatrolAG = class(TAIGroup)
  public
    FPatrolFrom: TXYL; { $50 }
    FPatrolTo: TXYL; { $54 }
    FPreviousHeading: Shortint; { $58 }
    F_PatrolAG_59: array[0..2] of Byte;
    FPatrolStrength: Integer; { $5C }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TPatrolAGC (instance size 368, VMT 557D845C) }
  TPatrolAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone(Sender: TObject); override;
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); override;
    procedure ProcessStates; override;
    function ResetPatrolToLocation: Boolean;
  end;

  { TRefugeAG (instance size 80, VMT 557D8554) }
  TRefugeAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TRefugeAGC (instance size 368, VMT 557D86AC) }
  TRefugeAGC = class(TAIGroupControl)
  public
  end;

  { TRaidAG (instance size 80, VMT 557D87A4) }
  TRaidAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TRaidAGC (instance size 368, VMT 557D88F4) }
  TRaidAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone(Sender: TObject); override;
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); override;
    procedure ProcessStates; override;
  end;

  { TScoutAG (instance size 80, VMT 557D89E8) }
  TScoutAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TScoutAGC (instance size 368, VMT 557D8B3C) }
  TScoutAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone(Sender: TObject); override;
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); override;
    procedure ProcessStates; override;
  end;


implementation

uses AGCPlugins;

constructor TGuardAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 1;
  FRecruitmentPriority := 2;
end;

class function TGuardAG.ClassID: Integer;
begin Result := $21453; end;

class function TGuardAG.Behavior: TGroupBehavior;
begin Result := gbGuard; end;

class function TGuardAG.GroupControlClass: TAIGroupControlClass;
begin Result := TGuardAGC; end;

constructor TGuardAreaAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FGuardLocation.XYL := $FFFFFF;
  FProcessPriority := 1;
  FRecruitmentPriority := 2;
end;

class function TGuardAreaAG.ClassID: Integer;
begin Result := $21451; end;

class function TGuardAreaAG.Behavior: TGroupBehavior;
begin Result := gbGuardArea; end;

class function TGuardAreaAG.GroupControlClass: TAIGroupControlClass;
begin Result := TGuardAreaAGC; end;

procedure TGuardAreaAG.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FGuardLocation.XYL, 50);
end;

procedure TGuardAreaAGC.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
begin
  SetupCP(Target);
  { Original also accepts crDefeat when the subsequent efficiency tests pass. }
  if FCombatPredictor.Execute in [crVictory, crDefeat, crNoDefenders] then
    if FCombatPredictor.GetEfficiency > 0 then
    begin
      Target.FData.Priority := FCombatPredictor.GetEfficiency +
        (Target.FData.Priority * 100 - Target.FMovePoints * 5);
      inherited TargetFoundEvent(Sender, Target, SearchDone);
    end;
end;

procedure TGuardAreaAGC.MoveExecuterDone(Sender: TObject);
begin
  case FState of
    1:
      if FMoveExecuter.FStatus = mesOutOfMovePoints then Done
      else if FMoveExecuter.FStatus = mesInvalidated then Done;
    2:
      if FMoveExecuter.FStatus = mesFailed then
      begin
        TGuardAreaAG(FGroup).FGuardLocation.XYL := $FFFFFF;
        Done;
      end
      else Done;
  end;
end;

procedure TGuardAreaAGC.ProcessStates;
var
  I: Integer;
  MapF: TAoWMapField;
  Finder: TAIGroupTargetFinder;
  Settings: TMoveControlSettings;
begin
  case FState of
    0:
      begin
        if TGuardAreaAG(FGroup).FGuardLocation.X = -1 then
          TGuardAreaAG(FGroup).FGuardLocation := FLocation;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        with Finder.FSelector do
        begin
          FSourceLocation := TGuardAreaAG(FGroup).FGuardLocation;
          FTargetInfo.Mode := tmGuardArea;
        end;
        Finder.FSelector.FMovePointsMax := FArmy.Moves(FSelection);
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    1:
      begin
        FTargets.Validate;
        if FTargets.Count <> 0 then
        begin
          if (FArmy.Moves(FSelection) <> FArmy.MovePoints(FSelection)) or
            (TGuardAreaAG(FGroup).FGuardLocation.XYL <> FLocation.XYL) then
          begin
            Settings := TMoveControlSettings.Create(nil);
            Settings.FPlayer := FArmy.FPlayer;
            Settings.FMode := Settings.FMode + [mmAI];
            Settings.SetSourcePos(FArmy.FX, FArmy.FY, FArmy.FL);
            Settings.FMovePointsMax := FArmy.MovePoints(FSelection);
            Settings.FArmyHS := FArmyHS;
            Settings.FSelection := FSelection;
            Settings.FMovePointTable := FMovePointTable;
            AoWHSMap.FMoveControl.ProcessMove(Settings);
            for I := FTargets.Count - 1 downto 0 do
              if Settings.GetMovePointsXYL(FTargets.GetTargets(I).FLocation.XYL) = $FFFFFF then
                FTargets.Delete(I);
            Settings.Release;
          end;
          if FTargets.Count <> 0 then
          begin
            FTargets.SortOnPriority;
            SetupME;
            ExecuteME(FTargets.GetTargets(0).FLocation.X, FTargets.GetTargets(0).FLocation.Y,
              FTargets.GetTargets(0).FLocation.L);
            FTargets.Delete(0);
          end
          else FState := 2;
        end
        else FState := 2;
      end;
    2:
      begin
        if TGuardAreaAG(FGroup).FGuardLocation.XYL <> FLocation.XYL then
        begin
          MapF := TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(TGuardAreaAG(FGroup).FGuardLocation.XYL));
          if (MapF.GetPlayer = -1) or (MapF.GetPlayer = FGroup.FPlayer) then
          begin
            SetupME;
            with TGuardAreaAG(FGroup).FGuardLocation do ExecuteME(X, Y, L);
          end
          else Done;
        end
        else Done;
      end;
  end;
end;

procedure TGuardAreaAGC.ProcessStatesLooped;
begin
  ProcessStates;
end;

constructor TPatrolAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 1;
  FRecruitmentPriority := 2;
  FPatrolFrom.XYL := $FFFFFF;
  FPatrolTo.XYL := $FFFFFF;
  FPreviousHeading := 0;
end;

class function TPatrolAG.ClassID: Integer;
begin Result := $21452; end;

class function TPatrolAG.Behavior: TGroupBehavior;
begin Result := gbPatrol; end;

class function TPatrolAG.GroupControlClass: TAIGroupControlClass;
begin Result := TPatrolAGC; end;

procedure TPatrolAG.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FPatrolFrom.XYL, 40);
  Stream.rwInteger(FPatrolTo.XYL, 41);
  Stream.rwByte(Byte(FPreviousHeading), 42);
  Stream.rwInteger(FPatrolStrength, 43);
end;

function ComparePatrolFields(const A, B: TDoubleItem): Integer;
begin
  Result := B.B - A.B;
end;

function PatrolHeadingDistance(A, B: Integer): Integer;
begin
  Result := Abs(B - A);
  if Result > 3 then Result := 6 - Result;
end;

function TPatrolAGC.ResetPatrolToLocation: Boolean;
var
  PreviousHeading, X, Y: Integer;
  NewList: TDoubleItemList;
  Group: TPatrolAG;
  Settings: TMoveControlSettings;
  Fields: TList;
  Lists: array[0..6] of TDoubleItemList;
  Msg: TMapFieldMsg;
  Item: TDoubleItem;
  I, J, Heading, LastHeading: Integer;
  MapF: TAoWMapField;
  Choices: TByteList;
  SelectedList: TDoubleItemList;
begin
  Group := TPatrolAG(FGroup);
  if Group.FPatrolFrom.X = -1 then Group.FPatrolFrom := FLocation;
  Settings := TMoveControlSettings.Create(nil);
  Settings.FPlayer := Group.FPlayer;
  Settings.FMode := Settings.FMode + [mmAI, mmIgnoreArmies];
  Settings.SetSourcePos(Group.FPatrolFrom.X, Group.FPatrolFrom.Y, Group.FPatrolFrom.L);
  Settings.FMovePointsMax := 48;
  Settings.FMode := Settings.FMode + [mmLogProcessedMapFields];
  Settings.FArmyHS := FArmyHS;
  Settings.FSelection := FSelection;
  Settings.FMovePointTable := FMovePointTable;
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  Fields := Settings.FProcessedMapFields;
  for I := 0 to 6 do Lists[I] := TDoubleItemList.Create;
  X := Group.FPatrolFrom.X;
  Y := Group.FPatrolFrom.Y;
  for I := Fields.Count - 1 downto 0 do
    { Original samples every fourth processed field. }
    if I and 3 = 3 then
    begin
      MapF := TAoWMapField(Fields.List^[I]);
      Heading := dHXtoHT(X, Y, MapF.Xhx, MapF.Yhx);
      Lists[Heading].AddAB(Integer(MapF), Settings.GetMovePoints(MapF.Xhx, MapF.Yhx, MapF.Lhx));
    end;
  for I := 0 to 6 do Lists[I].Sort(ComparePatrolFields);
  Msg.MsgID := $1120;
  Msg.Param[0] := Integer(FArmyHS);
  for I := 1 to 6 do
  begin
    NewList := TDoubleItemList.Create;
    J := 0;
    while (NewList.Count <> 30) and (J <> Lists[I].Count) do
    begin
      MapF := TAoWMapField(Lists[I].List^[J].A);
      if MapF.GetPlayer = -1 then
      begin
        Msg.Result := 0;
        MapF.SendMapFieldMsg(Msg);
        if Msg.Result = 0 then
          NewList.Add(Lists[I].Items[J]);
      end;
      Inc(J);
    end;
    Lists[I].Free;
    Lists[I] := NewList;
  end;
  MapF := TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(Group.FPatrolFrom.XYL));
  if MapF.GetPlayer = -1 then Lists[0].AddAB(Integer(MapF), 0);
  if Group.FPatrolTo.X <> -1 then
    LastHeading := dHXtoHT(Group.FPatrolFrom.X, Group.FPatrolFrom.Y, Group.FPatrolTo.X, Group.FPatrolTo.Y)
  else LastHeading := 0;
  PreviousHeading := Group.FPreviousHeading;
  Choices := TByteList.Create;
  for I := 0 to 6 do
    if (Lists[I].Count <> 0) and (LastHeading <> I) and (I <> PreviousHeading) then
      if (PreviousHeading = 0) or (PatrolHeadingDistance(I, LastHeading) > 1) or
        (PatrolHeadingDistance(I, PreviousHeading) > 1) then
        Choices.Add(I);
  if Choices.Count = 0 then
    for I := 0 to 6 do
      if (Lists[I].Count <> 0) and (LastHeading <> I) then Choices.Add(I);
  if Choices.Count <> 0 then
  begin
    Group.FPreviousHeading := LastHeading;
    Heading := Choices.Items[AoWHSMap.Random(Choices.Count)];
    SelectedList := Lists[Heading];
    MapF := TAoWMapField(SelectedList.List^[AoWHSMap.Random(SelectedList.Count)].A);
    Group.FPatrolTo.XYL := MapF.GetXYL;
    Result := True;
  end
  else Result := False;
  for I := 0 to 6 do Lists[I].Free;
  Choices.Free;
  Settings.Release;
end;

procedure TPatrolAGC.MoveExecuterDone(Sender: TObject);
begin
  case FMoveExecuter.FStatus of
    mesDone: Done;
    mesFailed:
      if FState = 7 then
        TPatrolAG(FGroup).FPatrolTo.XYL := $FFFFFF
      else Done;
  end;
end;

procedure TPatrolAGC.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
var
  MapF: TAoWMapField;
begin
  MapF := TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(Target.FLocation.XYL));
  if MapF.GetPlayer <> FGroup.FPlayer then
  begin
    SetupCP(Target);
    if FCombatPredictor.Execute in [crVictory, crDefeat, crNoDefenders] then
      if FCombatPredictor.GetSuperiority > 80 then
        if FCombatPredictor.GetEfficiency > 50 then
        begin
          Target.FData.Priority := FCombatPredictor.GetEfficiency + Target.FData.Priority * 100;
          inherited TargetFoundEvent(Sender, Target, SearchDone);
        end;
  end;
end;

procedure TPatrolAGC.ProcessStates;
var
  Defense: TAIGroupDefenseControl;
  Recruitment: TAIRecruitmentGroupFinder;
  Recruit: TAIGroupRecruitControl;
  Finder: TAIGroupTargetFinder;
  Settings: TMoveControlSettings;
begin
  case FState of
    0:
      begin
        if TPatrolAG(FGroup).FPatrolStrength = 0 then
          TPatrolAG(FGroup).FPatrolStrength := FStrengthMax;
        Defense := TAIGroupDefenseControl.Create(nil);
        Defense.FDefendMode := gdmWait;
        ActivatePlugin(Defense);
        Defense.Release;
        FState := 1;
      end;
    1:
      begin
        if (TPatrolAG(FGroup).FPatrolTo.X = -1) or
          ((TPatrolAG(FGroup).FPatrolTo.L = FLocation.L) and
          (dHXtoRad(TPatrolAG(FGroup).FPatrolTo.X, TPatrolAG(FGroup).FPatrolTo.Y,
            FLocation.X, FLocation.Y) < 3)) then
          ResetPatrolToLocation;
        Inc(FState);
      end;
    2:
      if FStrengthMax < TPatrolAG(FGroup).FPatrolStrength then
      begin
        Inc(FState);
        Recruitment := TAIRecruitmentGroupFinder.Create(nil);
        Recruitment.Setup(Self);
        ActivatePlugin(Recruitment);
        Recruitment.Release;
      end
      else FState := 4;
    3:
      begin
        if (FRecruitmentGroups.Count <> 0) and
          (FStrengthMax < TPatrolAG(FGroup).FPatrolStrength) then
        begin
          Recruit := TAIGroupRecruitControl.Create(nil);
          Recruit.Reset;
          Recruit.FRecruitStrength := TPatrolAG(FGroup).FPatrolStrength - FStrengthMax;
          Recruit.FMode := rcmAutoRecruit;
          ActivatePlugin(Recruit);
          Recruit.Release;
        end;
        Inc(FState);
      end;
    4:
      begin
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        Finder.FSelector.FMovePointsMax := FArmy.Moves(FSelection);
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    5:
      begin
        FTargets.Validate;
        if FTargets.Count <> 0 then
        begin
          SetupME;
          ExecuteME(FTargets.GetTargets(0).FLocation.X, FTargets.GetTargets(0).FLocation.Y,
            FTargets.GetTargets(0).FLocation.L);
          FTargets.Delete(0);
        end
        else Inc(FState);
      end;
    6:
      if (AoWHSMap.Random(3) = 0) or (TPatrolAG(FGroup).FPatrolTo.X = -1) then Done
      else
      begin
        Inc(FState);
        SetupME;
        with TPatrolAG(FGroup).FPatrolTo do ExecuteME(X, Y, L);
      end;
    7:
      begin
        Settings := TMoveControlSettings.Create(nil);
        Settings.FPlayer := FGroup.FPlayer;
        Settings.FMode := Settings.FMode + [mmAI];
        Settings.SetSourcePos(FLocation.X, FLocation.Y, FLocation.L);
        with TPatrolAG(FGroup).FPatrolFrom do Settings.SetDestinationPos(X, Y, L);
        Settings.FMovePointsMax := 48;
        Settings.FMode := Settings.FMode + [mmIgnoreArmies];
        Settings.FArmyHS := FArmyHS;
        Settings.FSelection := FSelection;
        Settings.FMovePointTable := FMovePointTable;
        AoWHSMap.FMoveControl.ProcessMove(Settings);
        if Settings.FPath.Count = 0 then TPatrolAG(FGroup).FPatrolFrom.XYL := $FFFFFF;
        Settings.Release;
        Done;
      end;
  end;
end;

constructor TRefugeAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 1;
  FRecruitmentPriority := 2;
end;

class function TRefugeAG.ClassID: Integer;
begin Result := $21461; end;

class function TRefugeAG.Behavior: TGroupBehavior;
begin Result := gbRefuge; end;

class function TRefugeAG.GroupControlClass: TAIGroupControlClass;
begin Result := TRefugeAGC; end;

constructor TRaidAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 1;
  FRecruitmentPriority := 2;
end;

class function TRaidAG.ClassID: Integer;
begin Result := $21465; end;

class function TRaidAG.Behavior: TGroupBehavior;
begin Result := gbRaid; end;

class function TRaidAG.GroupControlClass: TAIGroupControlClass;
begin Result := TRaidAGC; end;

procedure TRaidAGC.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
begin
  SetupCP(Target);
  { Original also accepts crDefeat when the efficiency test passes. }
  if FCombatPredictor.Execute in [crVictory, crDefeat, crNoDefenders] then
    if FCombatPredictor.GetEfficiency > 0 then
    begin
      Target.FData.Priority := FCombatPredictor.GetEfficiency div 10 +
        (Target.FData.Priority * 100 - Target.FMovePoints * 5);
      inherited TargetFoundEvent(Sender, Target, SearchDone);
    end;
end;

procedure TRaidAGC.MoveExecuterDone(Sender: TObject);
begin
  case FState of
    1:
      if FMoveExecuter.FStatus = mesOutOfMovePoints then Done
      else if FMoveExecuter.FStatus = mesInvalidated then Done;
  end;
end;

procedure TRaidAGC.ProcessStates;
var
  Finder: TAIGroupTargetFinder;
  Raze: TAIGroupRazeControl;
begin
  case FState of
    0:
      begin
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        with Finder.FSelector do
        begin
          FMovePointsMax := 100;
          FTargetInfo.Mode := tmRaid;
        end;
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    1:
      begin
        FTargets.Validate;
        if FTargets.Count <> 0 then
        begin
          FTargets.SortOnPriority;
          SetupME;
          ExecuteME(FTargets.GetTargets(0).FLocation.X, FTargets.GetTargets(0).FLocation.Y,
            FTargets.GetTargets(0).FLocation.L);
          FTargets.Delete(0);
          Inc(FState);
        end
        else Done;
      end;
    2:
      begin
        Raze := TAIGroupRazeControl.Create(nil);
        Raze.Setup(Self);
        Raze.FMode := [];
        ActivatePlugin(Raze);
        Raze.Release;
        FState := 1;
      end;
  end;
end;

constructor TScoutAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 10;
  FRecruitmentPriority := 10;
end;

class function TScoutAG.ClassID: Integer;
begin Result := $21455; end;

class function TScoutAG.Behavior: TGroupBehavior;
begin Result := gbScout; end;

class function TScoutAG.GroupControlClass: TAIGroupControlClass;
begin Result := TScoutAGC; end;

procedure TScoutAGC.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
begin
  SetupCP(Target);
  if FCombatPredictor.Execute in [crVictory, crNoDefenders] then
    if FCombatPredictor.GetEfficiency > 50 then
    begin
      Target.FData.Priority := FCombatPredictor.GetEfficiency +
        (Target.FData.Priority * 100 - Target.FMovePoints * 5);
      inherited TargetFoundEvent(Sender, Target, SearchDone);
    end;
end;

procedure TScoutAGC.MoveExecuterDone(Sender: TObject);
begin
  case FState of
    1:
      if FMoveExecuter.FStatus = mesOutOfMovePoints then Done
      else if FMoveExecuter.FStatus = mesInvalidated then Done;
  end;
end;

procedure TScoutAGC.ProcessStates;
var
  Finder: TAIGroupTargetFinder;
  Wander: TAIGroupWanderControl;
begin
  case FState of
    0:
      if (FGroup.FPlayer <> 0) or
        (AoWHSMap.Random(3) < Ord(AoWHSMap.GetIndependentAIMode)) then
      begin
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        Finder.FSelector.FMovePointsMax := FGroup.GetMovePointsMin;
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end
      else Done;
    1:
      begin
        FTargets.Validate;
        if FTargets.Count <> 0 then
        begin
          FTargets.SortOnPriority;
          SetupME;
          ExecuteME(FTargets.GetTargets(0).FLocation.X, FTargets.GetTargets(0).FLocation.Y,
            FTargets.GetTargets(0).FLocation.L);
          FTargets.Delete(0);
        end
        else Inc(FState);
      end;
    2:
      begin
        Wander := TAIGroupWanderControl.Create(nil);
        Wander.Setup(Self);
        Wander.FMovePointsMax := 125;
        ActivatePlugin(Wander);
        Wander.Release;
        Inc(FState);
      end;
    3: Done;
  end;
end;


initialization
finalization

end.
