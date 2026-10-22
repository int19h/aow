unit BehaviorAG;

{ BehaviorAG, from AoWEPACK.dpl. Recovered behavior groups and controllers
  at their original instance layouts and VMT order. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

type
  TAbstractBehaviorAG = class;
  TAbstractBehaviorAGC = class;
  TSkirmishAG = class;
  TSkirmishAGC = class;
  TNormalAG = class;
  TNormalAGC = class;
  TDefenderAG = class;
  TDefenderAGC = class;
  TAggressorAG = class;
  TAggressorAGC = class;
  TExpanderAG = class;
  TExpanderAGC = class;
  TScorcherAG = class;
  TScorcherAGC = class;


  { TAbstractBehaviorAG (instance size 80, VMT 557DC2CC) }
  TAbstractBehaviorAG = class(TAIGroup)
  public
    function CooperateWithGroup(Group: TAIGroup; Target: TAIGroupControlTarget): Boolean; override;
  end;

  { TAbstractBehaviorAGC (instance size 372, VMT 557DC430): $170 FTargetSelector. }
  TAbstractBehaviorAGC = class(TAIGroupControl)
  public
    FTargetSelector: TAIGroupTargetSelector; { $170 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSkirmishAG (instance size 80, VMT 557DC53C) }
  TSkirmishAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TSkirmishAGC (instance size 372, VMT 557DC690) }
  TSkirmishAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TNormalAG (instance size 80, VMT 557DC78C) }
  TNormalAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TNormalAGC (instance size 372, VMT 557DC8E0) }
  TNormalAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TDefenderAG (instance size 80, VMT 557DC9D4) }
  TDefenderAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TDefenderAGC (instance size 372, VMT 557DCB28) }
  TDefenderAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TAggressorAG (instance size 80, VMT 557DCC24) }
  TAggressorAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TAggressorAGC (instance size 372, VMT 557DCD80) }
  TAggressorAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TExpanderAG (instance size 80, VMT 557DCE7C) }
  TExpanderAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TExpanderAGC (instance size 372, VMT 557DCFD0) }
  TExpanderAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;

  { TScorcherAG (instance size 80, VMT 557DD0CC) }
  TScorcherAG = class(TAbstractBehaviorAG)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TScorcherAGC (instance size 372, VMT 557DD220) }
  TScorcherAGC = class(TAbstractBehaviorAGC)
  public
    procedure ProcessStates; override;
  end;


implementation

uses IndependentAG, MainAG, AGCPlugins;

function TAbstractBehaviorAG.CooperateWithGroup(Group: TAIGroup; Target: TAIGroupControlTarget): Boolean;
{ conflict: function TAbstractBehaviorAG.CooperateWithGroup(Group: TAIGroup): Boolean; }
begin
  Result := inherited CooperateWithGroup(Group, Target);
  Result := Result or (Group.Behavior = gbFortify);
end;

constructor TAbstractBehaviorAGC.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargetSelector := TAIGroupTargetSelector.Create(nil);
end;

destructor TAbstractBehaviorAGC.Destroy;
begin
  FTargetSelector.Release;
  inherited Destroy;
end;

constructor TNormalAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 10;
  FRecruitmentPriority := 10;
end;

class function TNormalAG.ClassID: Integer;
begin Result := $21464; end;

class function TNormalAG.Behavior: TGroupBehavior;
begin Result := gbNormal; end;

class function TNormalAG.GroupControlClass: TAIGroupControlClass;
begin Result := TNormalAGC; end;

procedure TNormalAGC.ProcessStates;
var
  Defense: TAIGroupDefenseControl;
  Finder: TAIGroupTargetFinder;
  Recruitment: TAIRecruitmentGroupFinder;
  Production: TAIProductionLocationFinder;
  Raze: TAIGroupRazeControl;
  Defend: TAIGroupDefendTargetSelector;
begin
  case FState of
    0:
      begin
        Defense := TAIGroupDefenseControl.Create(nil);
        Defense.FDefendMode := gdmSplit;
        ActivatePlugin(Defense);
        Defense.Release;
        Inc(FState);
      end;
    1:
      if FGroup.Count > 0 then
      begin
        FTargets.Clear;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        if FGroup.FTransporter = nil then
          Finder.FSelector.SetTransporter(FindAvailableTransporter)
        else Finder.FSelector.SetTransporter(FGroup.FTransporter);
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end
      else Done;
    2:
      if FTargets.Count <> 0 then
      begin
        Recruitment := TAIRecruitmentGroupFinder.Create(nil);
        Recruitment.Setup(Self);
        ActivatePlugin(Recruitment);
        Recruitment.Release;
        Inc(FState);
      end
      else FState := 10;
    3:
      if FTargets.Count <> 0 then
      begin
        FProductionLocations.Clear;
        Production := TAIProductionLocationFinder.Create(nil);
        Production.Setup(Self);
        ActivatePlugin(Production);
        Production.Release;
        Inc(FState);
      end
      else FState := 10;
    4:
      if FTargets.Count <> 0 then
      begin
        FTargetSelector.Setup(Self);
        FTargetSelector.FSuperiority := 1.5;
        FTargetSelector.FPathStrengthFactor := 0.9;
        FTargetSelector.FCurrentPathStrengthFactor := 0.7;
        FTargetSelector.FNearSuperiority := 1.3;
        FTargetSelector.FMultiTargetFactor := 2;
        ActivatePlugin(FTargetSelector);
        Inc(FState);
      end
      else Inc(FState);
    5:
      if FTargetSelector.FTargetStatus = tssTargetConquered then
      begin
        Raze := TAIGroupRazeControl.Create(nil);
        Raze.Setup(Self);
        ActivatePlugin(Raze);
        Raze.Release;
        FState := 6;
      end
      else if FTargetSelector.FTargetStatus = tssNoTargetsFound then FState := 10
      else Done;
    6:
      if AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FPlayerType in [ptCPU3, ptCPU4, ptCPU5] then
        FState := 0
      else Done;
    10:
      begin
        Defend := TAIGroupDefendTargetSelector.Create(nil);
        Defend.Setup(Self);
        ActivatePlugin(Defend);
        Defend.Release;
        FState := 11;
      end;
    11:
      begin
        if FGroup.FTransporter <> nil then FGroup.DeleteUnit(FGroup.FTransporter);
        CombineIdleGroups;
        Done;
      end;
  end;
end;

constructor TDefenderAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 10;
  FRecruitmentPriority := 10;
end;

class function TDefenderAG.ClassID: Integer;
begin Result := $21456; end;

class function TDefenderAG.Behavior: TGroupBehavior;
begin Result := gbDefensive; end;

class function TDefenderAG.GroupControlClass: TAIGroupControlClass;
begin Result := TDefenderAGC; end;

procedure TDefenderAGC.ProcessStates;
var
  Defense: TAIGroupDefenseControl;
  Finder: TAIGroupTargetFinder;
  Recruitment: TAIRecruitmentGroupFinder;
  Production: TAIProductionLocationFinder;
  Raze: TAIGroupRazeControl;
  Defend: TAIGroupDefendTargetSelector;
begin
  case FState of
    0:
      begin
        Defense := TAIGroupDefenseControl.Create(nil);
        Defense.FDefendMode := gdmSplit;
        ActivatePlugin(Defense);
        Defense.Release;
        Inc(FState);
      end;
    1:
      begin
        FTargets.Clear;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        if FGroup.FTransporter = nil then
          Finder.FSelector.SetTransporter(FindAvailableTransporter)
        else Finder.FSelector.SetTransporter(FGroup.FTransporter);
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    2:
      if FTargets.Count <> 0 then
      begin
        Recruitment := TAIRecruitmentGroupFinder.Create(nil);
        Recruitment.Setup(Self);
        ActivatePlugin(Recruitment);
        Recruitment.Release;
        Inc(FState);
      end
      else FState := 10;
    3:
      if FTargets.Count <> 0 then
      begin
        FProductionLocations.Clear;
        Production := TAIProductionLocationFinder.Create(nil);
        Production.Setup(Self);
        ActivatePlugin(Production);
        Production.Release;
        Inc(FState);
      end
      else FState := 10;
    4:
      if FTargets.Count <> 0 then
      begin
        FTargetSelector.Setup(Self);
        FTargetSelector.FBattleFieldFactor := 1.7;
        FTargetSelector.FCurrentBattleFieldFactor := 1.2;
        FTargetSelector.FSuperiority := 2;
        FTargetSelector.FNearSuperiority := 1.5;
        FTargetSelector.FMinimumStrength := 10000;
        FTargetSelector.FMultiTargetFactor := 2;
        ActivatePlugin(FTargetSelector);
        Inc(FState);
      end
      else Inc(FState);
    5:
      if FTargetSelector.FTargetStatus = tssTargetConquered then
      begin
        Raze := TAIGroupRazeControl.Create(nil);
        Raze.Setup(Self);
        ActivatePlugin(Raze);
        Raze.Release;
        FState := 6;
      end
      else if FTargetSelector.FTargetStatus = tssNoTargetsFound then FState := 10
      else Done;
    6:
      if AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FPlayerType in [ptCPU3, ptCPU4, ptCPU5] then
        FState := 0
      else Done;
    10:
      begin
        Defend := TAIGroupDefendTargetSelector.Create(nil);
        Defend.Setup(Self);
        ActivatePlugin(Defend);
        Defend.Release;
        FState := 11;
      end;
    11:
      begin
        if FGroup.FTransporter <> nil then FGroup.DeleteUnit(FGroup.FTransporter);
        CombineIdleGroups;
        Done;
      end;
  end;
end;

constructor TAggressorAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 10;
  FRecruitmentPriority := 10;
end;

class function TAggressorAG.ClassID: Integer;
begin Result := $21457; end;

class function TAggressorAG.Behavior: TGroupBehavior;
begin Result := gbAggressive; end;

class function TAggressorAG.GroupControlClass: TAIGroupControlClass;
begin Result := TAggressorAGC; end;

procedure TAggressorAGC.ProcessStates;
var
  Defense: TAIGroupDefenseControl;
  Finder: TAIGroupTargetFinder;
  Recruitment: TAIRecruitmentGroupFinder;
  Production: TAIProductionLocationFinder;
  Raze: TAIGroupRazeControl;
  Wander: TAIGroupWanderControl;
begin
  case FState of
    0:
      begin
        Defense := TAIGroupDefenseControl.Create(nil);
        Defense.FDefendMode := gdmSplit;
        ActivatePlugin(Defense);
        Defense.Release;
        Inc(FState);
      end;
    1:
      begin
        FTargets.Clear;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        if FGroup.FTransporter = nil then
          Finder.FSelector.SetTransporter(FindAvailableTransporter)
        else Finder.FSelector.SetTransporter(FGroup.FTransporter);
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    2:
      if FTargets.Count <> 0 then
      begin
        Recruitment := TAIRecruitmentGroupFinder.Create(nil);
        Recruitment.Setup(Self);
        ActivatePlugin(Recruitment);
        Recruitment.Release;
        Inc(FState);
      end
      else FState := 10;
    3:
      if FTargets.Count <> 0 then
      begin
        FProductionLocations.Clear;
        Production := TAIProductionLocationFinder.Create(nil);
        Production.Setup(Self);
        ActivatePlugin(Production);
        Production.Release;
        Inc(FState);
      end
      else FState := 10;
    4:
      if FTargets.Count <> 0 then
      begin
        FTargetSelector.Setup(Self);
        FTargetSelector.FPathStrengthFactor := 0.75;
        FTargetSelector.FCurrentPathStrengthFactor := 0.55;
        FTargetSelector.FSuperiority := 1.4;
        FTargetSelector.FNearSuperiority := 1.2;
        ActivatePlugin(FTargetSelector);
        Inc(FState);
      end
      else Inc(FState);
    5:
      if FTargetSelector.FTargetStatus = tssTargetConquered then
      begin
        Raze := TAIGroupRazeControl.Create(nil);
        Raze.Setup(Self);
        ActivatePlugin(Raze);
        Raze.Release;
        FState := 6;
      end
      else if FTargetSelector.FTargetStatus = tssNoTargetsFound then FState := 10
      else Done;
    6:
      if AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FPlayerType in [ptCPU3, ptCPU4, ptCPU5] then
        FState := 0
      else Done;
    10:
      begin
        Wander := TAIGroupWanderControl.Create(nil);
        Wander.Setup(Self);
        Wander.FMovePointsMax := 100;
        ActivatePlugin(Wander);
        Wander.Release;
        Inc(FState);
      end;
    11:
      begin
        if FGroup.FTransporter <> nil then FGroup.DeleteUnit(FGroup.FTransporter);
        CombineIdleGroups;
        Done;
      end;
  end;
end;

constructor TExpanderAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 10;
  FRecruitmentPriority := 10;
end;

class function TExpanderAG.ClassID: Integer;
begin Result := $21462; end;

class function TExpanderAG.Behavior: TGroupBehavior;
begin Result := gbExpand; end;

class function TExpanderAG.GroupControlClass: TAIGroupControlClass;
begin Result := TExpanderAGC; end;

procedure TExpanderAGC.ProcessStates;
var
  Defense: TAIGroupDefenseControl;
  Finder: TAIGroupTargetFinder;
  Recruitment: TAIRecruitmentGroupFinder;
  Production: TAIProductionLocationFinder;
  Raze: TAIGroupRazeControl;
  Wander: TAIGroupWanderControl;
begin
  case FState of
    0:
      begin
        Defense := TAIGroupDefenseControl.Create(nil);
        Defense.FDefendMode := gdmSplit;
        ActivatePlugin(Defense);
        Defense.Release;
        Inc(FState);
      end;
    1:
      begin
        FTargets.Clear;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        if FGroup.FTransporter = nil then
          Finder.FSelector.SetTransporter(FindAvailableTransporter)
        else Finder.FSelector.SetTransporter(FGroup.FTransporter);
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    2:
      if FTargets.Count <> 0 then
      begin
        Recruitment := TAIRecruitmentGroupFinder.Create(nil);
        Recruitment.Setup(Self);
        ActivatePlugin(Recruitment);
        Recruitment.Release;
        Inc(FState);
      end
      else FState := 10;
    3:
      if FTargets.Count <> 0 then
      begin
        FProductionLocations.Clear;
        Production := TAIProductionLocationFinder.Create(nil);
        Production.Setup(Self);
        ActivatePlugin(Production);
        Production.Release;
        Inc(FState);
      end
      else FState := 10;
    4:
      if FTargets.Count <> 0 then
      begin
        FTargetSelector.Setup(Self);
        FTargetSelector.FMoveDayFactor := 0.05;
        FTargetSelector.FPrioritySettings.FSetupBonus := 25;
        FTargetSelector.FPrioritySettings.FExecuteBonus := 25;
        FTargetSelector.FPrioritySettings.FMoveDayPenalty := -10;
        FTargetSelector.FPrioritySettings.FImmediateBonus := 10;
        FTargetSelector.FPrioritySettings.FTransportPenalty := -25;
        ActivatePlugin(FTargetSelector);
        Inc(FState);
      end
      else Inc(FState);
    5:
      if FTargetSelector.FTargetStatus = tssTargetConquered then
      begin
        Raze := TAIGroupRazeControl.Create(nil);
        Raze.Setup(Self);
        ActivatePlugin(Raze);
        Raze.Release;
        FState := 6;
      end
      else if FTargetSelector.FTargetStatus = tssNoTargetsFound then FState := 10
      else Done;
    6:
      if AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FPlayerType in [ptCPU3, ptCPU4, ptCPU5] then
        FState := 0
      else Done;
    10:
      begin
        Wander := TAIGroupWanderControl.Create(nil);
        Wander.Setup(Self);
        Wander.FMovePointsMax := 100;
        ActivatePlugin(Wander);
        Wander.Release;
        Inc(FState);
      end;
    11:
      begin
        if FGroup.FTransporter <> nil then FGroup.DeleteUnit(FGroup.FTransporter);
        CombineIdleGroups;
        Done;
      end;
  end;
end;

constructor TScorcherAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 10;
  FRecruitmentPriority := 10;
end;

class function TScorcherAG.ClassID: Integer;
begin Result := $21463; end;

class function TScorcherAG.Behavior: TGroupBehavior;
begin Result := gbScorch; end;

class function TScorcherAG.GroupControlClass: TAIGroupControlClass;
begin Result := TScorcherAGC; end;

procedure TScorcherAGC.ProcessStates;
var
  Defense: TAIGroupDefenseControl;
  Finder: TAIGroupTargetFinder;
  Recruitment: TAIRecruitmentGroupFinder;
  Production: TAIProductionLocationFinder;
  Raze: TAIGroupRazeControl;
  Wander: TAIGroupWanderControl;
begin
  case FState of
    0:
      begin
        Defense := TAIGroupDefenseControl.Create(nil);
        Defense.FDefendMode := gdmSplit;
        ActivatePlugin(Defense);
        Defense.Release;
        Inc(FState);
      end;
    1:
      begin
        FTargets.Clear;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        if FGroup.FTransporter = nil then
          Finder.FSelector.SetTransporter(FindAvailableTransporter)
        else Finder.FSelector.SetTransporter(FGroup.FTransporter);
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    2:
      if FTargets.Count <> 0 then
      begin
        Recruitment := TAIRecruitmentGroupFinder.Create(nil);
        Recruitment.Setup(Self);
        ActivatePlugin(Recruitment);
        Recruitment.Release;
        Inc(FState);
      end
      else FState := 10;
    3:
      if FTargets.Count <> 0 then
      begin
        FProductionLocations.Clear;
        Production := TAIProductionLocationFinder.Create(nil);
        Production.Setup(Self);
        ActivatePlugin(Production);
        Production.Release;
        Inc(FState);
      end
      else FState := 10;
    4:
      if FTargets.Count <> 0 then
      begin
        FTargetSelector.Setup(Self);
        FTargetSelector.FSuperiority := 1.75;
        FTargetSelector.FNearSuperiority := 1.3;
        FTargetSelector.FMultiTargetFactor := 200;
        ActivatePlugin(FTargetSelector);
        Inc(FState);
      end
      else Inc(FState);
    5:
      if FTargetSelector.FTargetStatus = tssTargetConquered then
      begin
        Raze := TAIGroupRazeControl.Create(nil);
        Raze.Setup(Self);
        Raze.FMode := Raze.FMode + [rcmOnMigrate];
        Raze.FCityStrengthFactor := 1.5;
        ActivatePlugin(Raze);
        Raze.Release;
        FState := 6;
      end
      else if FTargetSelector.FTargetStatus = tssNoTargetsFound then FState := 10
      else Done;
    6:
      if AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FPlayerType in [ptCPU3, ptCPU4, ptCPU5] then
        FState := 0
      else Done;
    10:
      begin
        Wander := TAIGroupWanderControl.Create(nil);
        Wander.Setup(Self);
        Wander.FMovePointsMax := 100;
        ActivatePlugin(Wander);
        Wander.Release;
        Inc(FState);
      end;
    11:
      begin
        if FGroup.FTransporter <> nil then FGroup.DeleteUnit(FGroup.FTransporter);
        CombineIdleGroups;
        Done;
      end;
  end;
end;

constructor TSkirmishAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 12;
  FRecruitmentPriority := 12;
end;

class function TSkirmishAG.ClassID: Integer;
begin Result := $21466; end;

class function TSkirmishAG.Behavior: TGroupBehavior;
begin Result := gbSkirmish; end;

class function TSkirmishAG.GroupControlClass: TAIGroupControlClass;
begin Result := TSkirmishAGC; end;

procedure TSkirmishAGC.ProcessStates;
var
  Finder: TAIGroupTargetFinder;
  Group: TAIGroup;
begin
  case FState of
    0:
      begin
        FTargets.Clear;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        if FGroup.FTransporter = nil then
          Finder.FSelector.SetTransporter(FindAvailableTransporter)
        else Finder.FSelector.SetTransporter(FGroup.FTransporter);
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    1:
      if FTargets.Count <> 0 then
      begin
        FTargetSelector.Setup(Self);
        FTargetSelector.FSuperiority := 3;
        FTargetSelector.FNearSuperiority := 2;
        FTargetSelector.FMode := FTargetSelector.FMode - [tsmCooperate, tsmRecruit, tsmProduce];
        ActivatePlugin(FTargetSelector);
        Inc(FState);
      end
      else FState := 10;
    2:
      if FTargetSelector.FTargetStatus = tssTargetConquered then FState := 5
      else if FTargetSelector.FTargetStatus = tssNoTargetsFound then FState := 10
      else Done;
    5:
      if AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FPlayerType in [ptCPU3, ptCPU4, ptCPU5] then
        FState := 0
      else Done;
    10:
      begin
        if FGroup.FTransporter <> nil then FGroup.DeleteUnit(FGroup.FTransporter);
        Group := AoWHSMap.FAIGroupManager.CreateGroup(FGroup.FPlayer, 0,
          AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FAIControl.GetRandomGroupBehavior);
        Group.AddUnits(FGroup);
        Group.Release;
        Done;
      end;
  end;
end;


initialization
finalization

end.
