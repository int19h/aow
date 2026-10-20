unit MainAG;

{ Main AI group types, passive control, movement completion and registration
  recovered from AoWEPACK.dpl. Other control methods remain drafts.
  All groups inherit size $50; their controls inherit size $170. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

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
    procedure ProcessStates(A1: Integer; A2: Integer); override;
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

  { TFortifyAGC (instance size 384, VMT 557DA268) }
  TFortifyAGC = class(TAIGroupControl)
  public
    F_FortifyAGC_170: array[0..15] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
    procedure Split; override;
    procedure FortifyCity;  { draft }
    procedure GetSurroundingEnemyStrength(A1: Integer; A2: Integer);  { draft }
    procedure UpdateRequiredStrength(A1: Integer; A2: Integer);  { draft }
    procedure MakeUselessUnitsPassive(A1: Integer; A2: Integer);  { draft }
    procedure CanBreachWall;  { draft }
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
    procedure MoveExecuterDone; override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
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
    procedure MoveExecuterDone; override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
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
      (Group.ClassID = $21458) and (FGroup.FTargetStatus = Group.FTargetStatus) then
    begin
      OtherLocation.XYL := Group.GetLoc;
      if (Location.L = OtherLocation.L) and
        (dHXtoRad(Location.X, Location.Y, OtherLocation.X, OtherLocation.Y) <= 1) then
        FGroup.AddUnits(Group);
    end;
  end;
end;

procedure TPassiveAGC.ProcessStates(A1: Integer; A2: Integer);
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
          Group := AoWHSMap.FAIGroupManager.CreateGroup(FGroup.FPlayer, Shortint(FGroup.FTargetStatus),
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
begin end;

destructor TFortifyAGC.Destroy;
begin end;

procedure TFortifyAGC.FortifyCity;
begin end;

procedure TFortifyAGC.Split;
begin end;

procedure TFortifyAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TFortifyAGC.GetSurroundingEnemyStrength(A1: Integer; A2: Integer);
begin end;

procedure TFortifyAGC.UpdateRequiredStrength(A1: Integer; A2: Integer);
begin end;

procedure TFortifyAGC.MakeUselessUnitsPassive(A1: Integer; A2: Integer);
begin end;

procedure TFortifyAGC.CanBreachWall;
begin end;

procedure TFortifyAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

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

procedure TSuicidalAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSuicidalAGC.MoveExecuterDone;
begin
  case FState of
    1:
      if FMoveExecuter.FStatus = mesOutOfMovePoints then Done
      else if FMoveExecuter.FStatus = mesInvalidated then Done;
  end;
end;

procedure TSuicidalAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

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

procedure TTransportAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTransportAGC.MoveExecuterDone;
begin
  case FState of
    1:
      if FMoveExecuter.FStatus = mesOutOfMovePoints then Done
      else if FMoveExecuter.FStatus = mesInvalidated then Done;
  end;
end;

procedure TTransportAGC.SetupME;
begin end;

procedure TTransportAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;


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
