unit MainAG;

{ Main AI group types, passive control, movement completion and registration
  recovered from AoWEPACK.dpl, including fortification and transport controls.
  All groups inherit size $50; their controls inherit size $170. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, City, AGCPlugins, AoWE;

type
  TPassiveAG = class;
  TPassiveAGC = class;
  TFortifyAG = class;
  TFortifyAGC = class;
  TSuicidalAG = class;
  TSuicidalAGC = class;
  TTransportAG = class;
  TTransportAGC = class;


  { TPassiveAG (instance size 80, VMT 557D9ED8) }
  TPassiveAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetLoc: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
    function GetRecruitableUnits(Phase: Integer; Units, Recruitable: TUnitList): Boolean; override;
  end;

  { TPassiveAGC (instance size 368, VMT 557DA028) }
  TPassiveAGC = class(TAIGroupControl)
  public
    procedure ProcessStates; override;
    procedure CombinePassiveGroups;
  end;

  { TFortifyAG (instance size 80, VMT 557DA118) }
  TFortifyAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TFortifyAGC (instance size 384, VMT 557DA268): $170 city location,
    $174 enemy strength, $178 required strength, $17C target selector. }
  TFortifyAGC = class(TAIGroupControl)
  public
    FFortifyLocation: TXYL; { $170 }
    FEnemyStrength: Integer; { $174 }
    FRequiredStrength: Integer; { $178 }
    FTargetSelector: TAIGroupTargetSelector; { $17C }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); override;
    procedure ProcessStates; override;
    function Split: Boolean; override;
    function FortifyCity: TCity;
    function GetSurroundingEnemyStrength(Location: TXYL; Radius: Integer): Integer;
    procedure UpdateRequiredStrength;
    procedure MakeUselessUnitsPassive;
    function CanBreachWall: Boolean;
  end;

  { TSuicidalAG (instance size 80, VMT 557DA358) }
  TSuicidalAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TSuicidalAGC (instance size 368, VMT 557DA4A8) }
  TSuicidalAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone(Sender: TObject); override;
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); override;
    procedure ProcessStates; override;
  end;

  { TTransportAG (instance size 80, VMT 557DA5A0) }
  TTransportAG = class(TAIGroup)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
  end;

  { TTransportAGC (instance size 368, VMT 557DA6F8) }
  TTransportAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone(Sender: TObject); override;
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); override;
    procedure ProcessStates; override;
    procedure SetupME; override;
  end;


implementation

type
  { TRegistrator (instance size 4): no fields; map-load registration callback. }
  TRegistrator = class(TObject)
    class procedure MapLoaded(Sender: TObject);
  end;

class procedure TRegistrator.MapLoaded(Sender: TObject);
begin
  if Sender = AoWHSMap then
    AoWHSMap.FAIGroupManager.RegisterAIGroupClasses(
      [TPassiveAG, TSuicidalAG, TFortifyAG, TTransportAG]);
end;

constructor TPassiveAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 0;
  FRecruitmentPriority := 1;
end;

class function TPassiveAG.ClassID: Integer;
begin Result := $21458; end;

class function TPassiveAG.Behavior: TGroupBehavior;
begin Result := gbPassive; end;

class function TPassiveAG.GroupControlClass: TAIGroupControlClass;
begin Result := TPassiveAGC; end;

function TPassiveAG.GetLoc: Integer;
var
  Location: TXYL;
begin
  if FTargetMode = Byte(gdmCustom) then Location := FTargetXYL
  else Location.XYL := inherited GetLoc;
  Result := Location.XYL;
end;

function TPassiveAG.GetRecruitableUnits(Phase: Integer; Units, Recruitable: TUnitList): Boolean;
var
  Location: TXYL;
  Selector: TGroupDefenseSelector;
  I: Integer;
  AUnit: TAbstractUnit;
begin
  Location.XYL := GetLoc;
  Result := False;
  Selector := TGroupDefenseSelector.Create;
  Selector.Execute(Self, Location.X, Location.Y, Location.L, Units);
  if Selector.FDefenders.Count <> 0 then
    for I := Units.Count - 1 downto 0 do
    begin
      AUnit := Units.GetUnit(I);
      if Selector.FDefenders.IndexOf(AUnit) = -1 then
      begin
        Recruitable.AddUnit(AUnit);
        Result := True;
      end;
    end
  else
  begin
    Recruitable.AddUnits(Units);
    Result := True;
  end;
  Selector.Free;
end;

procedure TPassiveAGC.CombinePassiveGroups;
var
  Player: TPlayer;
  Location, OtherLocation: TXYL;
  I: Integer;
  Group: TAIGroup;
begin
  Player := AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer);
  Location.XYL := FGroup.GetLoc;
  for I := Player.FAIGroups.Count - 1 downto 0 do
  begin
    Group := Player.FAIGroups.GetGroups(I);
    if (FGroup.FGroupID <> Group.FGroupID) and
      (Group.ClassID = $21458) and (FGroup.FIndependentRelation = Group.FIndependentRelation) then
    begin
      OtherLocation.XYL := Group.GetLoc;
      if (Location.L = OtherLocation.L) and
        (dHXtoRad(Location.X, Location.Y, OtherLocation.X, OtherLocation.Y) <= 1) then
        FGroup.AddUnits(Group);
    end;
  end;
end;

procedure TPassiveAGC.ProcessStates;
var
  Location: TXYL;
  Selector: TGroupDefenseSelector;
  Group: TAIGroup;
  I: Integer;
  AUnit: TAbstractUnit;
begin
  case FState of
    0:
      begin
        CombinePassiveGroups;
        Location.XYL := FGroup.GetLoc;
        Selector := TGroupDefenseSelector.Create;
        Selector.Execute(FGroup, Location.X, Location.Y, Location.L, nil);
        if (Selector.FDefenders.Count <> FGroup.Count) and (FGroup.FPlayer <> 0) then
        begin
          Group := AoWHSMap.FAIGroupManager.CreateGroup(FGroup.FPlayer, Shortint(FGroup.FIndependentRelation),
            AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FAIControl.GetRandomGroupBehavior);
          for I := FGroup.Count - 1 downto 0 do
          begin
            AUnit := FGroup.GetUnit(I);
            if Selector.FDefenders.IndexOf(AUnit) = -1 then Group.AddUnit(AUnit);
          end;
          Group.Release;
        end;
        if Selector.FDefenseLocation.XYL <> $FFFFFF then
        begin
          FGroup.FTargetXYL := Selector.FDefenseLocation;
          FGroup.FTargetMode := Byte(gdmCustom);
          SetupME;
          FMoveExecuter.FMode := FMoveExecuter.FMode - [memAdjacent];
          ExecuteME(Selector.FDefenseLocation.X, Selector.FDefenseLocation.Y, Selector.FDefenseLocation.L);
          Done;
        end
        else Done;
        Selector.Free;
      end;
  end;
end;

constructor TFortifyAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 15;
  FRecruitmentPriority := 0;
end;

class function TFortifyAG.ClassID: Integer;
begin Result := $21459; end;

class function TFortifyAG.Behavior: TGroupBehavior;
begin Result := gbFortify; end;

class function TFortifyAG.GroupControlClass: TAIGroupControlClass;
begin Result := TFortifyAGC; end;

constructor TFortifyAGC.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargetSelector := TAIGroupTargetSelector.Create(nil);
end;

destructor TFortifyAGC.Destroy;
begin
  FTargetSelector.Release;
  inherited Destroy;
end;

function TFortifyAGC.FortifyCity: TCity;
begin
  if FFortifyLocation.XYL <> $FFFFFF then
    Result := TCity(AoWHSMap.MapContainer.GetFieldXYL(FFortifyLocation.XYL).FindNoneTransparentHS(TCity))
  else Result := nil;
end;

function TFortifyAGC.Split: Boolean;
begin Result := False; end;

procedure TFortifyAGC.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
begin
  case TAIGroupTargetFinder(Sender).FSelector.FTargetInfo.Mode of
    tmFortify: inherited TargetFoundEvent(Sender, Target, SearchDone);
    tmAttackArmies: inherited TargetFoundEvent(Sender, Target, SearchDone);
    tmAttack: inherited TargetFoundEvent(Sender, Target, SearchDone);
  end;
end;

function TFortifyAGC.GetSurroundingEnemyStrength(Location: TXYL; Radius: Integer): Integer;
var
  Settings: TMoveControlSettings;
  Msg: TMapFieldMsg;
  Info: TBattleFieldInfo;
  I: Integer;
begin
  Settings := TMoveControlSettings.Create(nil);
  Settings.FPlayer := FGroup.FPlayer;
  Settings.FMode := Settings.FMode + [mmLogProcessedMapFields, mmAI];
  Settings.SetSourcePos(Location.X, Location.Y, Location.L);
  Settings.FMovePointsMax := Radius;
  Settings.FArmyHS := nil;
  Settings.FSelection := 0;
  Settings.FMovePointTable := MovePointTables[MoveTypesToInt([mtFlying])];
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  SetupBattleFieldInfo(Info, FGroup.FPlayer, Shortint(FGroup.FIndependentRelation),
    [bfrIgnorePassiveIndependents], dtAll - [dtWall]);
  Info.FriendlyRelations := [];
  Msg.MsgID := $1108;
  Msg.Param[0] := Integer(@Info);
  for I := Settings.FProcessedMapFields.Count - 1 downto 0 do
    with TAoWMapField(Settings.FProcessedMapFields[I]) do
      if FFieldFlags and $04000000 <> 0 then SendMapFieldMsg(Msg);
  Result := Info.Strength;
  Settings.Release;
end;

procedure TFortifyAGC.UpdateRequiredStrength; { Near miss: register or temporary allocation differs after three variants. }
var
  Strength: Integer;
  Statistics: TPlayerStatistics;
begin
  FRequiredStrength := FEnemyStrength;
  if AoWHSMap.FDay > 5 then
  begin
    Strength := (AoWHSMap.FDay div 5) * 5000;
    if Strength > 50000 then Strength := 50000;
    if Strength > FEnemyStrength then FRequiredStrength := Strength;
  end;
  if (FRequiredStrength > 0) and (AoWHSMap.FDay < 10) then
    FRequiredStrength := Round(FRequiredStrength * AoWHSMap.FDay * 0.1);
  Statistics := AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FStatistics;
  if Statistics.FTurnInfo.Count > 0 then
  begin
    Strength := Statistics.FTurnInfo.GetTurnInfo(Statistics.FTurnInfo.Count - 1).FArmyStrength shr 1;
    if Strength < FRequiredStrength then FRequiredStrength := Strength;
    Strength := Round(Statistics.FTurnInfo.GetTurnInfo(Statistics.FTurnInfo.Count - 1).FArmyStrength * 0.1);
    if Strength > 50000 then Strength := 50000;
    if AoWHSMap.FDay < 10 then Strength := Round(Strength * AoWHSMap.FDay * 0.1);
    if Strength > FRequiredStrength then FRequiredStrength := Strength;
  end;
end;

function CompareFortifyUnits(Item1, Item2: Pointer): Integer;
var
  Strength1, Strength2: Integer;
begin
  Strength1 := TAbstractUnit(Item1).GetStrengthMax(dtAll - [dtWall]);
  Strength2 := TAbstractUnit(Item2).GetStrengthMax(dtAll - [dtWall]);
  if TObject(Item1) is TLeader then Strength1 := Strength2 + $FFFFFF; { Original uses Strength2. }
  if TObject(Item2) is TLeader then Inc(Strength2, $FFFFFF);
  Result := Strength2 - Strength1;
end;

procedure TFortifyAGC.MakeUselessUnitsPassive;
var
  Excess, I: Integer;
  Units, Passive: TUnitUserList;
  Group: TAIGroup;
begin
  Excess := FStrengthMax - FRequiredStrength;
  if Excess > 0 then
  begin
    Units := TUnitUserList.Create(nil);
    Passive := TUnitUserList.Create(nil);
    Units.AddUnits(FGroup);
    Units.FChildren.Sort(CompareFortifyUnits);
    I := Units.Count;
    while (I <> 0) and (Excess > 0) do
    begin
      Dec(I);
      if not (Units.GetUnit(I) is TLeader) then
      begin
        Dec(Excess, Units.GetUnit(I).GetStrengthMax(dtAll - [dtWall]));
        if Excess >= 0 then
        begin
          Passive.AddUnit(Units.GetUnit(I));
          Units.DeleteUnit(Units.GetUnit(I));
        end;
      end;
    end;
    if Passive.Count <> 0 then
    begin
      Group := AoWHSMap.FAIGroupManager.CreateGroup(FGroup.FPlayer,
        Shortint(FGroup.FIndependentRelation), gbPassive);
      Group.AddUnits(Passive);
      Group.Release;
    end;
    Passive.Free;
    Units.Free;
  end;
end;

function TFortifyAGC.CanBreachWall: Boolean;
var
  I: Integer;
  AUnit: TAbstractUnit;
begin
  I := FGroup.Count;
  Result := FGroup.GetStrength(dtWall) <> 0;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    AUnit := FGroup.GetUnit(I);
    Result := AUnit.GetAbilityEnabled(52) and
      TSpellCastingAbility(AoWHSSet.FAbilityControl.GetAbility(52)).CanCastBreachWallSpell(AUnit);
  end;
end;

procedure TFortifyAGC.ProcessStates; { Near miss: truncated case-table extent and branch offsets differ after three variants. }
var
  Finder: TAIGroupTargetFinder;
  Recruitment: TAIRecruitmentGroupFinder;
  ProductionFinder: TAIProductionLocationFinder;
  Recruit: TAIGroupRecruitControl;
  Produce: TAIGroupProductionControl;
  Defense: TAIGroupDefenseControl;
  CurrentTarget, NewTarget: TAIGroupControlTarget;
  I, Excess: Integer;
  Army: TArmyHS;
  ACity: TCity;
begin
  case FState of
    0:
      begin
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        Finder.FSelector.FTargetInfo.Mode := tmFortify;
        Finder.FMode := Finder.FMode + [tfmCalculateMovepathBFS];
        Finder.FRange := 12;
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    1:
      begin
        I := 0;
        while (I < FTargets.Count) and (gtsDone in FTargets.GetTargets(I).FStatus) do Inc(I);
        if I < FTargets.Count then
        begin
          FTargets.GetTargets(I).FDataA := GetSurroundingEnemyStrength(FTargets.GetTargets(I).FLocation, 70);
          FTargets.GetTargets(I).FStatus := FTargets.GetTargets(I).FStatus + [gtsDone];
        end
        else Inc(FState);
      end;
    2:
      begin
        FTargets.Validate;
        NewTarget := nil;
        I := FTargets.IndexOfXYL(FLocation.XYL);
        if I = -1 then CurrentTarget := nil
        else CurrentTarget := FTargets.GetTargets(I);
        for I := 0 to FTargets.Count - 1 do
        begin
          FTargets.GetTargets(I).FDataB := FTargets.GetTargets(I).FData.Priority * 10 +
            FTargets.GetTargets(I).FMovePoints * -2;
          Excess := FTargets.GetTargets(I).FDataA - FStrengthMax;
          if Excess > 0 then Dec(FTargets.GetTargets(I).FDataB, Excess shr 4);
          Excess := FTargets.GetTargets(I).FPathStrength;
          if Excess > 0 then Dec(FTargets.GetTargets(I).FDataB, Excess shr 3);
          if FTargets.GetTargets(I).FLocation.XYL <> FLocation.XYL then
          begin
            Army := TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(FTargets.GetTargets(I).FLocation.XYL)).GetArmyHS;
            if Army <> nil then Dec(FTargets.GetTargets(I).FDataB, Army.FArmy.Count shl 2);
          end;
        end;
        FTargets.SortOnPriority;
        if (FTargets.Count <> 0) and (FTargets.GetTargets(0) <> CurrentTarget) then
        begin
          FTargets.SortOnDataB;
          if (CurrentTarget = nil) or (CurrentTarget.FData.Priority < FTargets.GetTargets(0).FData.Priority) then
            NewTarget := FTargets.GetTargets(0)
          else NewTarget := CurrentTarget;
        end;
        if (NewTarget <> nil) and (NewTarget <> CurrentTarget) then
          FFortifyLocation := NewTarget.FLocation
        else if CurrentTarget <> nil then FFortifyLocation := CurrentTarget.FLocation
        else FFortifyLocation.XYL := $FFFFFF;
        Inc(FState);
      end;
    3:
      begin
        if FFortifyLocation.XYL = $FFFFFF then
          FEnemyStrength := GetSurroundingEnemyStrength(FLocation, 70)
        else FEnemyStrength := GetSurroundingEnemyStrength(FFortifyLocation, 70);
        UpdateRequiredStrength;
        Inc(FState);
      end;
    4:
      begin
        Recruitment := TAIRecruitmentGroupFinder.Create(nil);
        Recruitment.Setup(Self);
        ActivatePlugin(Recruitment);
        Recruitment.Release;
        Inc(FState);
      end;
    5:
      begin
        FProductionLocations.Clear;
        ProductionFinder := TAIProductionLocationFinder.Create(nil);
        ProductionFinder.Setup(Self);
        ProductionFinder.FSelector.FMovePointsMax := 24;
        ActivatePlugin(ProductionFinder);
        ProductionFinder.Release;
        Inc(FState);
      end;
    6:
      if (FRecruitmentGroups.Count <> 0) and (FRequiredStrength > FStrengthMax) then
      begin
        Recruit := TAIGroupRecruitControl.Create(nil);
        Recruit.Setup(Self);
        Recruit.FRecruitStrength := FRequiredStrength - (FGroup.FProductions.GetStrengthMax(dtAll - [dtWall]) + FStrengthMax);
        Recruit.FMode := rcmAutoRecruit;
        ActivatePlugin(Recruit);
        Recruit.Release;
        Inc(FState);
      end
      else FState := 10;
    7:
      begin
        FRecruitmentGroups.Validate(Self);
        if (FStrengthMax < FRequiredStrength) and (FRecruitmentGroups.Count <> 0) then
        begin
          Recruit := TAIGroupRecruitControl.Create(nil);
          Recruit.Setup(Self);
          Recruit.FRecruitStrength := FRequiredStrength - (FGroup.FProductions.GetStrengthMax(dtAll - [dtWall]) + FStrengthMax);
          Recruit.FMode := rcmForceRecruit;
          ActivatePlugin(Recruit);
          Recruit.Release;
        end;
        FState := 10;
      end;
    10:
      if (FStrengthMax >= FEnemyStrength) and FGroup.GetAdjacent then
      begin
        FTargets.Clear;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        Finder.FSelector.FTargetInfo.Mode := tmAttackArmies;
        Finder.FSelector.FMovePointsMax := 55;
        if FFortifyLocation.XYL = $FFFFFF then Finder.FSelector.FSourceLocation := FLocation
        else Finder.FSelector.FSourceLocation := FFortifyLocation;
        Finder.FMode := Finder.FMode + [tfmCalculateMovepathBFS];
        Finder.FRange := 12;
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end
      else if FStrengthMax < FEnemyStrength then FState := 18
      else FState := 17;
    11:
      if FTargets.Count >= 1 then
      begin
        if (FTargets.Count = 1) or (FortifyCity = nil) or CanBreachWall then
        begin
          FTargetSelector.Setup(Self);
          FTargetSelector.FPathStrengthFactor := 1.5;
          FTargetSelector.FCurrentPathStrengthFactor := 1.3;
          FTargetSelector.FSuperiority := 1.6;
          FTargetSelector.FNearSuperiority := 1.4;
          FTargetSelector.FMode := FTargetSelector.FMode - [tsmMultiTargets];
          ActivatePlugin(FTargetSelector);
          Inc(FState);
        end
        else FState := 18;
      end
      else FState := 13;
    12:
      if FTargetSelector.FTargetStatus = tssTargetConquered then FState := 10
      else
      begin
        if FFortifyLocation.XYL <> $FFFFFF then
        begin
          SetupME;
          ExecuteME(FFortifyLocation.X, FFortifyLocation.Y, FFortifyLocation.L);
        end;
        FState := 20;
      end;
    13:
      begin
        ACity := TCity(AoWHSMap.MapContainer.GetFieldXYL(FLocation.XYL).FindNoneTransparentHS(TCity));
        if (ACity <> nil) and (ACity.GetActiveAction = caMigrate) then
        begin
          Defense := TAIGroupDefenseControl.Create(nil);
          Defense.FDefendMode := gdmCustom;
          Defense.FCustomState := 19;
          ActivatePlugin(Defense);
          Defense.Release;
        end;
        Inc(FState);
      end;
    14:
      begin
        FTargets.Clear;
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        Finder.FSelector.FTargetInfo.Mode := tmAttack;
        Finder.FSelector.FMovePointsMax := 55;
        if FFortifyLocation.XYL = $FFFFFF then Finder.FSelector.FSourceLocation := FLocation
        else Finder.FSelector.FSourceLocation := FFortifyLocation;
        Finder.FMode := Finder.FMode + [tfmCalculateMovepathBFS];
        Finder.FRange := 12;
        ActivatePlugin(Finder);
        Finder.Release;
        Inc(FState);
      end;
    15:
      if FTargets.Count >= 1 then
      begin
        FTargetSelector.Setup(Self);
        FTargetSelector.FPathStrengthFactor := 1.5;
        FTargetSelector.FCurrentPathStrengthFactor := 1.3;
        FTargetSelector.FSuperiority := 1.6;
        FTargetSelector.FNearSuperiority := 1.4;
        FTargetSelector.FMode := FTargetSelector.FMode - [tsmMultiTargets];
        ActivatePlugin(FTargetSelector);
        Inc(FState);
      end
      else FState := 18;
    16:
      if FTargetSelector.FTargetStatus = tssTargetConquered then FState := 13
      else
      begin
        if (FFortifyLocation.XYL <> $FFFFFF) and
          not (FTargetSelector.FTargetStatus in [tssSettingupTarget, tssExecutingTarget]) then
        begin
          SetupME;
          ExecuteME(FFortifyLocation.X, FFortifyLocation.Y, FFortifyLocation.L);
        end;
        FState := 20;
      end;
    17:
      begin
        if FStrengthMax >= FEnemyStrength then
        begin
          ACity := TCity(AoWHSMap.MapContainer.GetFieldXYL(FLocation.XYL).FindNoneTransparentHS(TCity));
          if (ACity <> nil) and (ACity.GetActiveAction = caMigrate) then
          begin
            Defense := TAIGroupDefenseControl.Create(nil);
            Defense.FDefendMode := gdmCustom;
            Defense.FCustomState := 19;
            ActivatePlugin(Defense);
            Defense.Release;
          end;
        end;
        Inc(FState);
      end;
    18:
      begin
        if FFortifyLocation.XYL = $FFFFFF then
        begin
          SetupME;
          ExecuteME(FLocation.X, FLocation.Y, FLocation.L);
        end
        else
        begin
          SetupME;
          ExecuteME(FFortifyLocation.X, FFortifyLocation.Y, FFortifyLocation.L);
        end;
        FState := 20;
      end;
    19:
      begin
        SetupME;
        ExecuteME(FLocation.X, FLocation.Y, FLocation.L);
        FState := 20;
      end;
    20:
      if FortifyCity <> nil then FState := 21
      else Done;
    21:
      begin
        ACity := FortifyCity;
        if (ACity <> nil) and (ACity.FProduction.FStatus = pcsIdle) then
        begin
          if ACity.FWallType = 0 then
          begin
            if AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FAIBudget.RequestExpense(ACity.FortifyCost, 0) then
              if ACity.Fortify(False) then
                AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FAIBudget.ExpenseMade(ACity.FortifyCost, 0);
          end
          else if (ACity.FWallType = 1) and (AoWHSMap.FDay > 29) then
            if AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FAIBudget.RequestExpense(ACity.FortifyCost, 0) then
              if ACity.Fortify(False) then
                AoWHSMap.FPlayers.GetPlayers(FGroup.FPlayer).FAIBudget.ExpenseMade(ACity.FortifyCost, 0);
        end;
        Inc(FState);
      end;
    22:
      if FGroup.FProductions.GetStrengthMax(dtAll - [dtWall]) + FStrengthMax < FRequiredStrength then
      begin
        FProductionLocations.Clear;
        ProductionFinder := TAIProductionLocationFinder.Create(nil);
        ProductionFinder.Setup(Self);
        ProductionFinder.FSelector.FMovePointsMax := 24;
        ActivatePlugin(ProductionFinder);
        ProductionFinder.Release;
        Inc(FState);
      end
      else Inc(FState);
    23:
      begin
        if FProductionLocations.Count > 0 then
        begin
          Produce := TAIGroupProductionControl.Create(nil);
          Produce.Setup(Self);
          Produce.FProduceStrength := FRequiredStrength - (FGroup.FProductions.GetStrengthMax(dtAll - [dtWall]) + FStrengthMax);
          Produce.FMode := pcmAutoProduce;
          ActivatePlugin(Produce);
          Produce.Release;
        end;
        Inc(FState);
      end;
    24:
      begin
        case FGroup.FTargetType of
          gtsNone, gtsIdle: MakeUselessUnitsPassive;
        end;
        Inc(FState);
      end;
    25: Done;
  end;
end;

constructor TSuicidalAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 1;
  FRecruitmentPriority := 2;
end;

class function TSuicidalAG.ClassID: Integer;
begin Result := $21454; end;

class function TSuicidalAG.Behavior: TGroupBehavior;
begin Result := gbSuicidal; end;

class function TSuicidalAG.GroupControlClass: TAIGroupControlClass;
begin Result := TSuicidalAGC; end;

procedure TSuicidalAGC.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
begin
  SetupCP(Target);
  if FCombatPredictor.Execute in [crVictory, crDefeat, crNoDefenders] then
      if FCombatPredictor.GetEfficiency > 0 then
      begin
        Target.FData.Priority := FCombatPredictor.GetEfficiency +
          (Target.FData.Priority * 100 - Target.FMovePoints * 5);
        inherited TargetFoundEvent(Sender, Target, SearchDone);
      end;
end;

procedure TSuicidalAGC.MoveExecuterDone(Sender: TObject);
begin
  case FState of
    1:
      if FMoveExecuter.FStatus = mesOutOfMovePoints then Done
      else if FMoveExecuter.FStatus = mesInvalidated then Done;
  end;
end;

procedure TSuicidalAGC.ProcessStates;
var
  Finder: TAIGroupTargetFinder;
begin
  case FState of
    0:
      begin
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        Finder.FSelector.FMovePointsMax := 100;
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
          ExecuteME(FTargets.GetTargets(0).FLocation.X,
            FTargets.GetTargets(0).FLocation.Y, FTargets.GetTargets(0).FLocation.L);
          FTargets.Delete(0);
        end
        else Done;
      end;
  end;
end;

constructor TTransportAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProcessPriority := 2;
  FRecruitmentPriority := 20;
end;

destructor TTransportAG.Destroy;
begin
  inherited Destroy;
end;

class function TTransportAG.ClassID: Integer;
begin Result := $21467; end;

class function TTransportAG.Behavior: TGroupBehavior;
begin Result := gbTransport; end;

class function TTransportAG.GroupControlClass: TAIGroupControlClass;
begin Result := TTransportAGC; end;

procedure TTransportAGC.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
begin
  SetupCP(Target);
  if FCombatPredictor.Execute in [crVictory, crDefeat, crNoDefenders] then
      if FCombatPredictor.GetEfficiency > 75 then
      begin
        Target.FData.Priority := FCombatPredictor.GetEfficiency +
          (Target.FData.Priority * 100 - Target.FMovePoints * 5);
        inherited TargetFoundEvent(Sender, Target, SearchDone);
      end;
end;

procedure TTransportAGC.MoveExecuterDone(Sender: TObject);
begin
  case FState of
    1:
      if FMoveExecuter.FStatus = mesOutOfMovePoints then Done
      else if FMoveExecuter.FStatus = mesInvalidated then Done;
  end;
end;

procedure TTransportAGC.SetupME;
var
  Transporter: TAbstractUnit;
  Army: TArmy;
  I: Integer;
begin
  inherited SetupME;
  Transporter := FGroup.FLeader;
  if (Transporter <> nil) and (Transporter.Owner is TArmy) then
  begin
    Army := TArmy(Transporter.Owner);
    for I := 0 to Army.Count - 1 do
      if (Transporter <> Army.GetUnit(I)) and
        (FMoveExecuter.FUnits.IndexOfUnit(Army.GetUnit(I)) = -1) then
        FMoveExecuter.AddUnit(Army.GetUnit(I));
  end;
end;

procedure TTransportAGC.ProcessStates;
var
  Finder: TAIGroupTargetFinder;
  Wander: TAIGroupWanderControl;
begin
  case FState of
    0:
      begin
        Finder := TAIGroupTargetFinder.Create(nil);
        Finder.Setup(Self);
        Finder.FSelector.FMovePointsMax := 100;
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
          ExecuteME(FTargets.GetTargets(0).FLocation.X,
            FTargets.GetTargets(0).FLocation.Y, FTargets.GetTargets(0).FLocation.L);
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
  if ValidateAoWEngine then
  begin
    AoWEngine.RegisterEClasses([TSuicidalAG, TFortifyAG, TPassiveAG, TTransportAG]);
    AoWEngine.OnHSMLoaded.Add(TRegistrator.MapLoaded);
  end;
finalization
  if AoWEngine <> nil then
    AoWEngine.OnHSMLoaded.Remove(TRegistrator.MapLoaded);

end.
