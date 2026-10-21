unit PrdPlace;

{ Production places, income structures and their production controls from AoWEPACK.dpl.
  Instance layouts and VMT order follow the original. Unresolved recovery is noted inline. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EventLog, AoWE;

type
  TProductionPlaceControl = class;
  TProductionPlace = class;
  TProductionPlaceResource = class;
  TProductionPlaceEventLog = class;


  { TProductionPlaceControl: size $2C; $28 production place. VMT 557BD4D0. }
  TProductionPlaceControl = class(TProductionControl)
  public
    FProductionPlace: TProductionPlace;  { $28 }
    function ExecuteProduction(Item: TProductionItem): Boolean; override;
    procedure GetLocation(var X, Y, L: Shortint); override;
    function GetPlayer: Shortint; override;
    function UnitProduced: Boolean; override;
    procedure UnitResearched; override;
    procedure Update; override;
    procedure NewTurn(Player: Shortint); override;
    function CanExecuteProduction(Item: TProductionItem; var Reason: string): Boolean; override;
    function GetProductionName(Item: TProductionItem): string; override;
    function GetProductionNameProgressive(Item: TProductionItem): string; override;
    function UnitProductionGold(Index: Integer): Integer; override;
    function UnitProductionMana(Index: Integer): Integer; override;
    function UnitProductionGoldUpkeep(Index: Integer): Integer; override;
    function UnitProductionManaUpkeep(Index: Integer): Integer; override;
    function UnitProductionTime(Index: Integer): Integer; override;
  end;

  { TProductionPlace: size $4C; $3C power source, $40 income source, $44 production
    control, $48 razed state, $49 defender level, $4A padding. VMT 557BD68C. }
  TProductionPlace = class(TPlayerStructure)
  public
    FPowerSource: TPlayerStructurePowerSource;  { $3C }
    FIncomeSource: TPlayerStructureIncomeSource;  { $40 }
    FProductionControl: TProductionPlaceControl;  { $44 }
    FRazedState: Byte;  { $48 }
    FDefenderLevel: Byte;  { $49 }
    F_ProductionPlace_4A: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure Select; override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    procedure NewDay; override;
    procedure NewTurn(Player: Shortint); override;
    procedure BuildingDone; override;
    function GetCurrentActivityText: string; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    procedure Update; override;
    function CanDblClick: Boolean; override;
    procedure SetPlayer(Player: Shortint); override;
    function GetIncome: Integer; override;
    function GetPower: Integer; override;
    procedure StructureCaptured(OldPlayer, NewPlayer: Shortint); override;
    function CreateProductionControl: TProductionPlaceControl; virtual;
    procedure GenerateDefenders; virtual;
    function GetBaseIncome: Integer; virtual;
    function GetMagicSphere: TMagicSphere; virtual;
    function GetProductionName(Item: TProductionItem): string; virtual;
    function GetProductionNameProgressive(Item: TProductionItem): string; virtual;
    procedure ListIncomeInfo(Names, Values: TStrings); virtual;
    procedure MasterySpellCast(Player: Shortint; Sphere: TMagicSphere);
    function CanProduce(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
    function Produce(Index: Integer; Queue: Boolean): Boolean;
    function ProductionGold(Index: Integer): Integer;
    function ProductionMana(Index: Integer): Integer;
    function ProductionTime(Index: Integer): Integer;
    function CanResearch(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
    function Research(Index: Integer; Queue: Boolean): Boolean;
    function ResearchGold(Index: Integer): Integer;
    function ResearchMana(Index: Integer): Integer;
    function ResearchTime(Index: Integer): Integer;
    function CanTrade(Queue: Boolean; var Reason: string): Boolean;
    function Trade(Queue: Boolean): Boolean;
    procedure ResetProductions;
  end;

  { TProductionPlaceResource: size $78; $74 available unit indexes. VMT 557BD94C. }
  TProductionPlaceResource = class(TPlayerStructureResource)
  public
    FUnits: TUnitIndexList;  { $74 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Editor: TClass; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TProductionPlaceEventLog: size $20; no added fields. VMT 557BDA5C. }
  TProductionPlaceEventLog = class(TProductionEventLog)
  public
    class function ClassID: Integer; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    function GetProductionPlace: TProductionPlace;
  end;

procedure RegisterProductionPlace(AEngine: TEngine);

implementation

uses Animation, PassiveAb;

function TProductionPlaceControl.UnitProductionTime(Index: Integer): Integer;
var
  Player: Shortint;
  Picks: Integer;
begin
  Index := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(Index).FLevel * 2;
  if FProductionPlace.GetMagicSphere <> msNone then
  begin
    Player := FProductionPlace.FPlayer;
    if Player > 0 then
      Picks := AoWHSMap.FPlayers.GetPlayers(Player).FLeader.GetSpherePicks(FProductionPlace.GetMagicSphere)
    else Picks := 0;
    Dec(Result, Picks div 2);
    if Result < 1 then Result := 1;
  end;
end;

function TProductionPlaceControl.UnitProductionGold(Index: Integer): Integer;
begin
  if FProductionPlace.GetMagicSphere <> msNone then Result := 0
  else Result := inherited UnitProductionGold(Index);
end;

function TProductionPlaceControl.UnitProductionMana(Index: Integer): Integer;
begin
  { The original uses the gold production cost as the node's mana cost. }
  if FProductionPlace.GetMagicSphere <> msNone then Result := inherited UnitProductionGold(Index)
  else Result := 0;
end;

function TProductionPlaceControl.UnitProductionGoldUpkeep(Index: Integer): Integer;
begin
  { The original uses the inherited mana production cost for gold upkeep. }
  if FProductionPlace.GetMagicSphere <> msNone then Result := 0
  else Result := inherited UnitProductionMana(Index);
end;

function TProductionPlaceControl.UnitProductionManaUpkeep(Index: Integer): Integer;
begin
  if FProductionPlace.GetMagicSphere <> msNone then
    Result := AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(Index).FUnitIndex).FLevel * 5
  else Result := 0;
end;

function TProductionPlaceControl.GetPlayer: Shortint;
begin Result := FProductionPlace.FPlayer; end;

procedure TProductionPlaceControl.GetLocation(var X, Y, L: Shortint);
begin
  with FProductionPlace do
  begin
    X := Xhx;
    Y := Yhx;
    L := Lhx;
  end;
end;

function TProductionPlaceControl.UnitProduced: Boolean;
var
  Enchantment: TUnitEnchantment;
  Log: TProductionPlaceEventLog;
begin
  with FProductionPlace do
  begin
    Result := FSettings.FUnit.Place(Xhx, Yhx, Lhx, FPlayer, [pmScanArea]) <> nil;
    if Result and (FProductionPlace.GetMagicSphere <> msNone) and FSettings.FUnit.ExpandAbility(155) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(FSettings.FUnit.GetAbilityData(155)).FEnchantment;
      Enchantment.SetUpkeep((FSettings.FUnit.GetUnitLevel + 1) * 2);
      Enchantment.SetSource(FProductionPlace.FPlayer);
      Enchantment.FDispelResistance := FSettings.FUnit.GetUnitLevel + 3;
    end;
    Log := TProductionPlaceEventLog.Create(nil);
    Log.FPlayer := FPlayer;
    Log.FText := SysUtils.Format(TranslateRStr(XProducedAtYRStr), [FSettings.FUnit.GetName, FProductionPlace.GetName]);
    Log.SetLocation(Xhx, Yhx, Lhx);
    AoWHSMap.FPlayers.GetPlayers(Log.FPlayer).FEventLogbook.AddEvent(Log);
    Log.Release;
  end;
end;

procedure TProductionPlaceControl.UnitResearched;
var
  Log: TProductionPlaceEventLog;
begin
  inherited UnitResearched;
  with FProductionPlace do
  begin
    Log := TProductionPlaceEventLog.Create(nil);
    Log.FPlayer := FPlayer;
    Log.FText := SysUtils.Format(TranslateRStr(XInstalledAtYRStr), [AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(FSettings.FUnitProductionIndex).FUnitIndex).GetUnitName, FProductionPlace.GetName]);
    Log.SetLocation(Xhx, Yhx, Lhx);
    AoWHSMap.FPlayers.GetPlayers(Log.FPlayer).FEventLogbook.AddEvent(Log);
    Log.Release;
  end;
end;

procedure TProductionPlaceControl.Update;
begin
  inherited Update;
  if FUpdateCount = 0 then FProductionPlace.Update;
end;

function TProductionPlaceControl.CanExecuteProduction(Item: TProductionItem; var Reason: string): Boolean;
begin
  if Item.FProductionID = 10 then Result := True
  else Result := inherited CanExecuteProduction(Item, Reason);
end;

procedure TProductionPlaceControl.NewTurn(Player: Shortint);
begin
  inherited NewTurn(Player);
  if (FStatus = pcsProducing) and (Player = FSettings.FPlayer) and (FSettings.FTurnsLeft = 0) then
    if FQueue.GetItem(0).FProductionID = 10 then ProductionDone;
end;

function TProductionPlaceControl.ExecuteProduction(Item: TProductionItem): Boolean;
begin
  Result := inherited ExecuteProduction(Item);
  if Result then
    case Item.FProductionID of
      10: begin
        FSettings.FTurnsTotal := Item.FParameter;
        FSettings.FTurnsLeft := 1;
        FSettings.FPlayer := GetPlayer;
        FStatus := pcsProducing;
      end;
    end;
end;

function TProductionPlaceControl.GetProductionName(Item: TProductionItem): string;
begin
  if (Item.FProductionID = 1) or (Item.FProductionID = 2) then Result := inherited GetProductionName(Item)
  else Result := FProductionPlace.GetProductionName(Item);
end;

function TProductionPlaceControl.GetProductionNameProgressive(Item: TProductionItem): string;
begin
  if (Item.FProductionID = 1) or (Item.FProductionID = 2) then Result := inherited GetProductionNameProgressive(Item)
  else Result := FProductionPlace.GetProductionNameProgressive(Item);
end;

constructor TProductionPlace.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProductionControl := CreateProductionControl;
  FProductionControl.FProductionPlace := Self;
  if GetMagicSphere = msNone then
  begin
    FIncomeSource := TPlayerStructureIncomeSource.Create(nil);
    FIncomeSource.Setup(Self);
    FDefenderLevel := 2;
  end
  else
  begin
    FPowerSource := TPlayerStructurePowerSource.Create(nil);
    FPowerSource.Setup(Self);
    FDefenderLevel := 3;
  end;
end;

destructor TProductionPlace.Destroy;
begin
  inherited Destroy;
  FPowerSource.Free;
  FIncomeSource.Free;
  FProductionControl.Free;
end;

class function TProductionPlace.ClassID: Integer;
begin Result := $203BA; end;

function TProductionPlace.CanDblClick: Boolean;
begin
  if (AoWHSMap.FSeatedPlayer <> FPlayer) or (GetMagicSphere <> msNone) then Result := False
  else Result := True;
end;

function TProductionPlace.CreateProductionControl: TProductionPlaceControl;
begin Result := TProductionPlaceControl.Create(nil); end;

function TProductionPlace.GetMagicSphere: TMagicSphere;
begin Result := msNone; end;

procedure TProductionPlace.MasterySpellCast(Player: Shortint; Sphere: TMagicSphere);
var
  UnitIndex: Integer;
  AUnit: TUnit;
  ArmyHS: TArmyHS;
  Enchantment: TUnitEnchantment;
  Animation: TImageSequenceAnimation;
begin
  if (Sphere = GetMagicSphere) and (FPlayer > 0) then
  begin
    case Sphere of
      msLife: UnitIndex := 216;
      msDeath: UnitIndex := 217;
      msWater: UnitIndex := 227;
      msFire: UnitIndex := 226;
      msEarth: UnitIndex := 225;
      msAir: UnitIndex := 224;
    else UnitIndex := -1;
    end;
    if UnitIndex <> -1 then
    begin
      AUnit := TUnit.Create(nil);
      AUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(UnitIndex));
      AUnit.SetPlayer(FPlayer);
      ArmyHS := AUnit.Place(Xhx, Yhx, Lhx, FPlayer, [pmScanArea]);
      if ArmyHS <> nil then
      begin
        if AUnit.ExpandAbility(155) then
        begin
          Enchantment := TUnitEnchantmentAbilityData(AUnit.GetAbilityData(155)).FEnchantment;
          Enchantment.SetUpkeep(TSummonedAbility(AoWHSSet.FSpellControl.GetSpell(155)).GetDefaultManaUpkeep(AUnit));
          Enchantment.SetSource(FPlayer);
          Enchantment.FDispelResistance := TSummonedAbility(AoWHSSet.FSpellControl.GetSpell(155)).GetDefaultDispelResistance(AUnit);
        end;
        if AoWHSMap.Visible(ArmyHS.Xhx, ArmyHS.Yhx, ArmyHS.Lhx, 0) then
        begin
          Animation := TImageSequenceAnimation.Create(nil);
          Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(29).FCastImages.GetImageSequence(0));
                  AoWHSMap.PlaceHX(Animation, Xhx, Yhx, Lhx);
        end;
      end;
      AUnit.Release;
    end;
  end;
end;

procedure TProductionPlace.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020102 then MasterySpellCast(Msg.Param[0], TMagicSphere(Msg.Param[1]));
end;

function TProductionPlace.GetPower: Integer;
begin
  { The original tests msCosmos, rather than msNone, here. }
  if (FPlayer > 0) and (GetMagicSphere <> msCosmos) and not GetRazed and not GetBuilding then
  begin
    Result := AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader.GetSpherePicks(GetMagicSphere);
    if Result <> 0 then Result := Result * 5 + 10 else Result := 0;
  end
  else Result := 0;
end;

function TProductionPlace.GetBaseIncome: Integer;
begin
  if (FRazedState <> 1) and not GetBuilding then Result := 10
  else Result := 0;
end;

function TProductionPlace.GetIncome: Integer;
var
  Income: Integer;
  Control: TProductionPlaceControl;
begin
  Income := GetBaseIncome;
  if GetMagicSphere = msNone then
  begin
    Control := FProductionControl;
    if (Control.FStatus <> pcsProducing) or (Control.FQueue.GetItem(0).FProductionID = 10) then
      Inc(Income, Round(Income * 0.25));
  end;
  Result := Income;
end;

function TProductionPlace.GetRazed: Boolean;
begin Result := FRazedState = 1; end;

procedure TProductionPlace.SetRazed(Value: Boolean);
begin
  if Value then
  begin
    FProductionControl.ExecuteDeleteProductions;
    SetPlayer(-1);
    FRazedState := 1;
  end
  else FRazedState := 0;
  { 557BE592: image refresh requires private, non-draft TILTerrainMO.FImageIndex. }
end;

procedure TProductionPlace.ListIncomeInfo(Names, Values: TStrings);
var
  Picks: Integer;
begin
  if GetMagicSphere = msNone then
  begin
    if GetBaseIncome > 0 then
    begin
      Names.Add(TranslateRStr(BaseIncomeRStr));
      Values.Add(IntToStr(GetBaseIncome));
      if (FProductionControl.FStatus <> pcsProducing) or
        ((FProductionControl.FQueue.GetItem(0).FProductionID = 10) and (GetBaseIncome > 0)) then
      begin
        Names.Add(TranslateRStr(ProducingMerchandiseRStr));
        Values.Add(IntToStr(Round(GetBaseIncome * 0.25)));
      end;
    end;
  end
  else if FPlayer > 0 then
  begin
    Picks := AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader.GetSpherePicks(GetMagicSphere);
    Names.Add(SysUtils.Format(TranslateRStr(XtimeYSphereRStr), [IntToStr(Picks), LowerCase(TranslateRStr(TMagicSphereRStr[GetMagicSphere]))]));
    Values.Add(IntToStr(Picks * 5));
    if (FProductionControl.FStatus <> pcsProducing) or (FProductionControl.FQueue.GetItem(0).FProductionID = 10) then
    begin
      Names.Add(TranslateRStr(ExtraPowerRStr));
      Values.Add(IntToStr(Round(Picks * 5 * 0.25)));
    end;
  end;
end;

function TProductionPlace.GetCurrentActivityText: string;
begin
  if FProductionControl.FQueue.Count = 0 then
  begin
    if FPlayer > 0 then
    begin
      if GetMagicSphere <> msNone then
      begin
        if GetPower <> 0 then Result := TranslateRStr(GeneratingExtraPowerRStr)
        else Result := '-';
      end
      else if GetBaseIncome <> 0 then Result := TranslateRStr(ProducingMerchandiseRStr)
      else Result := TranslateRStr(NoneRStr);
    end
    else Result := LowerCase(TranslateRStr(NoneRStr));
  end
  else Result := FProductionControl.GetProductionNameProgressive(FProductionControl.FQueue.GetItem(0));
end;

function TProductionPlace.GetProductionName(Item: TProductionItem): string;
begin
  if Item.FProductionID = 10 then
    if GetMagicSphere <> msNone then Result := TranslateRStr(GenerateExtraPowerRStr)
    else Result := TranslateRStr(ProduceMerchandiseRStr)
  else Result := TranslateRStr(UnknownRStr);
end;

function TProductionPlace.GetProductionNameProgressive(Item: TProductionItem): string;
begin
  if Item.FProductionID = 10 then
    if GetMagicSphere <> msNone then Result := TranslateRStr(GeneratingExtraPowerRStr)
    else Result := TranslateRStr(ProducingMerchandiseRStr)
  else Result := TranslateRStr(UnknownRStr);
end;

function TProductionPlace.CanProduce(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin Result := FProductionControl.CanProduceUnit(Index, Queue, Reason); end;

function TProductionPlace.Produce(Index: Integer; Queue: Boolean): Boolean;
begin Result := FProductionControl.ProduceUnit(Index, Queue); end;

function TProductionPlace.ProductionGold(Index: Integer): Integer;
begin Result := FProductionControl.UnitProductionGold(Index); end;

function TProductionPlace.ProductionMana(Index: Integer): Integer;
begin Result := FProductionControl.UnitProductionMana(Index); end;

function TProductionPlace.ProductionTime(Index: Integer): Integer;
begin Result := FProductionControl.UnitProductionTime(Index); end;

function TProductionPlace.CanResearch(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin Result := FProductionControl.CanResearchUnit(Index, Queue, Reason); end;

function TProductionPlace.Research(Index: Integer; Queue: Boolean): Boolean;
begin Result := FProductionControl.ResearchUnit(Index, Queue); end;

function TProductionPlace.ResearchGold(Index: Integer): Integer;
begin Result := FProductionControl.UnitResearchGold(Index); end;

function TProductionPlace.ResearchMana(Index: Integer): Integer;
begin Result := FProductionControl.UnitResearchMana(Index); end;

function TProductionPlace.ResearchTime(Index: Integer): Integer;
begin Result := FProductionControl.UnitResearchTime(Index); end;

function TProductionPlace.CanTrade(Queue: Boolean; var Reason: string): Boolean;
begin
  if GetMagicSphere <> msNone then
    if AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader.GetSpherePicks(GetMagicSphere) > 0 then Result := True
    else
    begin
      Result := False;
      Reason := TranslateRStr(YouCannotChannelPowerFromThisNodeRStr);
    end
  else Result := GetBaseIncome <> 0;
end;

function TProductionPlace.Trade(Queue: Boolean): Boolean;
var
  Item: TProductionItem;
  Reason: string;
begin
  if CanTrade(Queue, Reason) and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    Item := TProductionItem.Create(nil);
    Item.FProductionID := 10;
    if Queue then Item.FParameter := 1 else Item.FParameter := -1;
    FProductionControl.Produce(Item, Queue);
    Item.Free;
    Result := True;
  end
  else Result := False;
end;

procedure TProductionPlace.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FProductionControl, 8);
  Stream.rwData(FDefenderLevel, 1, 9);
  Stream.rwData(FRazedState, 1, 10);
end;

procedure TProductionPlace.Update;
begin
  inherited Update;
  if (FIncomeSource <> nil) and (FPlayer >= 0) then AoWHSMap.FPlayers.GetPlayers(FPlayer).UpdateIncome;
  if (FPowerSource <> nil) and (FPlayer >= 0) then AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.Update;
end;

procedure TProductionPlace.StructureCaptured(OldPlayer, NewPlayer: Shortint);
var
  Log: TProductionPlaceEventLog;
begin
  if not GetRazed and not GetBuilding and (OldPlayer = 0) and
    not (msEditting in AoWHSMap.Status) and (moActivated in Status) and
    not TPlayerStructureResource(Resource).FClaimed then
  begin
    Log := TProductionPlaceEventLog.Create(nil);
    Log.FPlayer := NewPlayer;
    Log.FText := SysUtils.Format(TranslateRStr(StructureCapturedRStr), [EditName]);
    Log.FXhx := Xhx;
    Log.FYhx := Yhx;
    Log.FLhx := Lhx;
    DistributeLocationEventLog(Log, FPlayer, Xhx, Yhx, Lhx, False);
    Log.Release;
  end;
end;

procedure TProductionPlace.Activate;
begin
  inherited Activate;
  FProductionControl.Activate;
  if FPlayer <> -1 then
  begin
    if GetMagicSphere = msNone then AoWHSMap.FPlayers.GetPlayers(FPlayer).FProductionControls.Add(FProductionControl);
    if FPowerSource <> nil then AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.RegisterPowerSource(FPowerSource);
    if FIncomeSource <> nil then AoWHSMap.FPlayers.GetPlayers(FPlayer).RegisterIncomeSource(FIncomeSource);
  end;
end;

procedure TProductionPlace.Deactivate;
begin
  if FPlayer <> -1 then
  begin
    if GetMagicSphere = msNone then AoWHSMap.FPlayers.GetPlayers(FPlayer).FProductionControls.Remove(FProductionControl);
    if FPowerSource <> nil then AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.UnregisterPowerSource(FPowerSource);
    if FIncomeSource <> nil then AoWHSMap.FPlayers.GetPlayers(FPlayer).UnregisterIncomeSource(FIncomeSource);
  end;
  FProductionControl.Deactivate;
  inherited Deactivate;
end;

procedure TProductionPlace.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
  begin
    FProductionControl.PlayerChanged;
    if FPlayer <> -1 then
    begin
      if FPowerSource <> nil then AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.UnregisterPowerSource(FPowerSource);
      if FIncomeSource <> nil then AoWHSMap.FPlayers.GetPlayers(FPlayer).UnregisterIncomeSource(FIncomeSource);
      if GetMagicSphere = msNone then AoWHSMap.FPlayers.GetPlayers(FPlayer).FProductionControls.Remove(FProductionControl);
    end;
    inherited SetPlayer(Player);
    if FPlayer <> -1 then
    begin
      if FPowerSource <> nil then AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.RegisterPowerSource(FPowerSource);
      if FIncomeSource <> nil then AoWHSMap.FPlayers.GetPlayers(FPlayer).RegisterIncomeSource(FIncomeSource);
      if GetMagicSphere = msNone then AoWHSMap.FPlayers.GetPlayers(FPlayer).FProductionControls.Add(FProductionControl);
    end;
  end;
end;

procedure TProductionPlace.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
begin
  if not GetRazed then
    case Info.Mode of
      tmAttack, tmRaid:
        if Info.Player <> FPlayer then
          if FPlayer = 0 then Data.Priority := 50
          else if ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, 0) then
          begin
            Data.Priority := 50 + AoWHSMap.FPlayers.GetPlayers(Info.Player).FIncome div 2;
            if Data.Priority < 25 then Data.Priority := 25;
            if Data.Priority > 75 then Data.Priority := 75;
          end;
      tmProduce: if Info.Player = FPlayer then Data.Priority := Data.Priority or 2;
      tmDefend: if Info.Player = FPlayer then Data.Priority := 30;
    end;
end;

procedure TProductionPlace.GenerateDefenders;
var
  ArmyHS: TArmyHS;
  Budget, Collection, I: Integer;
  Units: TUnitIndexList;
begin
  if FDefenderLevel <> 0 then
  begin
    if FDefenderLevel = 4 then FDefenderLevel := AoWHSMap.Random(3) + 1;
    Budget := (FDefenderLevel - 2) * 25 + 25;
    ArmyHS := TArmyHS(FOwner.FindOwnedChild($20217));
    if ArmyHS <> nil then Dec(Budget, ArmyHS.FArmy.ObtainValue($FF));
    if Budget > 0 then
    begin
      RandSeed := AoWHSMap.Random($FFFFF);
      Collection := TStructureResource(Resource).FDefenders.GetRndCollection;
      if Collection <> -1 then
      begin
        Units := TUnitIndexList.Create;
        with TStructureResource(Resource).FDefenders do
          for I := GetCollectionCount(Collection) - 1 downto 0 do Units.Add(GetU(Collection, I));
        PlaceRandomUnits(Xhx, Yhx, Lhx, 0, Units, 4, Budget, [utHumanoid, utCreature]);
        ArmyHS := TAoWMapField(FOwner).GetArmyHS;
        if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = 0) then ArmyHS.FArmy.SetBehavior($FF, gbGuard);
        Units.Free;
      end;
    end;
  end;
end;

procedure TProductionPlace.NewDay;
begin
  inherited NewDay;
  if AoWHSMap.FDay = 1 then
  begin
    if FPlayer = 0 then GenerateDefenders;
    ResetProductions;
  end;
end;

procedure TProductionPlace.BuildingDone;
begin
  inherited BuildingDone;
  ResetProductions;
end;

procedure TProductionPlace.ResetProductions;
var
  I: Integer;
  R: TProductionPlaceResource;
begin
  FProductionControl.FUnitProductions.Clear;
  if GetMagicSphere = msNone then
  begin
    R := TProductionPlaceResource(Resource);
    for I := 0 to R.FUnits.Count - 1 do FProductionControl.FUnitProductions.Add(R.FUnits[I], False);
    FProductionControl.FUnitProductions.SortOnLevel;
    FProductionControl.FUnitProductions.GetItem(0).FResearched := True;
  end;
end;

procedure TProductionPlace.NewTurn(Player: Shortint);
begin
  inherited NewTurn(Player);
  FProductionControl.NewTurn(Player);
end;

procedure TProductionPlace.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if (Msg.MsgID = $1201) and (Msg.HN = 0) then Msg.Result := Integer(FProductionControl);
end;

procedure TProductionPlace.Select;
begin inherited Select; end;

constructor TProductionPlaceResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FClaimed := False;
  FUnits := TUnitIndexList.Create;
  FRazeable := True;
end;

destructor TProductionPlaceResource.Destroy;
begin
  FUnits.Free;
  inherited Destroy;
end;

class function TProductionPlaceResource.ResourceEditName: string;
begin Result := ''; end;

class function TProductionPlaceResource.ClassID: Integer;
begin Result := $203BB; end;

function TProductionPlaceResource.ResourceUserClassID: Integer;
begin Result := $203BA; end;

function TProductionPlaceResource.Editor: TClass;
begin
  Result := Engine.Editors.FindEditor($203BB);
  if Result = nil then Result := inherited Editor;
end;

procedure TProductionPlaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(18, FUnits.LoadFromStream, FUnits.SaveToStream);
end;

class function TProductionPlaceEventLog.ClassID: Integer;
begin Result := $202FB; end;

function TProductionPlaceEventLog.GetProductionPlace: TProductionPlace;
begin
  Result := TProductionPlace(AoWHSMap.MapContainer.GetField(FXhx, FYhx, FLhx).FindNoneTransparentHS(TProductionPlace));
end;

function TProductionPlaceEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var
  Place: TProductionPlace;
begin
  if Trigger = etUser then
  begin
    Place := GetProductionPlace;
    if (Place <> nil) and (AoWHSMap.FSeatedPlayer = Place.FPlayer) then
    begin
      AoWHSMap.CenterViewTo(FXhx, FYhx, FLhx);
      AoWHSMap.TriggerExecuteEventLog(Self, True, Done);
    end;
  end;
  Result := False;
end;

procedure RegisterProductionPlace(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TProductionPlace, TProductionPlaceResource, TProductionPlaceEventLog]);
end;


initialization
finalization

end.
