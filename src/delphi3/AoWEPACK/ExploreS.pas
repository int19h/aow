unit ExploreS;

{ Exploration sites and their defender armies in AoWEPACK.dpl.
  Original layouts, virtual order and search/combat flow recovered from the executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  TDefendersArmy = class;
  TExplorationSite = class;
  TExplorationSiteResource = class;

  TDefendersMode = (dmUserDefined, dmLow, dmNormal, dmHigh, dmRandom);  { ot=1 }

  { TDefendersArmy (instance size 44, VMT 557C12B4): no additional fields. }
  TDefendersArmy = class(TArmy)
  public
    function CanAddUnit(AUnit: TAbstractUnit): Boolean; override;
  end;

  { TExplorationSite (instance size 56, VMT 557C1440):
    $30 FDefendersMode, $34 FDefenders. }
  TExplorationSite = class(TStructure)
  public
    FDefendersMode: TDefendersMode;
    F_ExplorationSite_31: array[0..2] of Byte;
    FDefenders: TDefendersArmy;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    function ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult; override;
    procedure NewDay; override;
    procedure Update; override;
    function GetExplored: Boolean; virtual;
    procedure SetupCombat(A1: TCombat; A2: TArmyHS); virtual;
    procedure ExecuteSearchDone(A1: TCombatType; A2: TCombatResult); virtual;
    function ExecuteSearch(A1: TCombatType): Boolean; virtual;
    function Search: Boolean; virtual;
    procedure CombatExecuted(A1: TCombat);
    procedure RequestCombatTypeCallBack(A1: TEventLog);
    function CanSearch(A1: Shortint): Boolean;
    procedure GenerateDefenders;
  end;

  { TExplorationSiteResource (instance size 104, VMT 557C16C4):
    $64 FDefenderCollections, the available defender army compositions. }
  TExplorationSiteResource = class(TStructureResource)
  public
    FDefenderCollections: TUnitIndexListCollection; { $64 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterExplorationSite(AEngine: TEngine);

implementation

function TDefendersArmy.CanAddUnit(AUnit: TAbstractUnit): Boolean;
begin
  Result := inherited CanAddUnit(AUnit);
  Result := Result and not AUnit.GetTransporter and AUnit.ValidTerrain(1, 4);
end;

constructor TExplorationSite.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDefendersMode := dmNormal;
  FDefenders := TDefendersArmy.Create(nil);
end;

destructor TExplorationSite.Destroy;
begin
  inherited Destroy;
  FDefenders.Free;
end;

class function TExplorationSite.ClassID: Integer;
begin Result := $203C1; end;

function TExplorationSite.GetExplored: Boolean;
begin Result := True; end;

function TExplorationSite.GetTerrainTypeImage(TerrainType: Integer): Integer; { Near miss: three variants retain a different receiver/index evaluation order. }
var Image: Integer;
begin
  if not GetExplored or (AoWHSMap.FDay = 0) then
    Result := TerrainType
  else
  begin
    Image := TerrainType + 100;
    if TExplorationSiteResource(FResource).ImageSequenceList.ImageSequences[Image] <> nil then
      Result := Image
    else Result := TerrainType;
  end;
end;

procedure TExplorationSite.ExecuteSearchDone(A1: TCombatType; A2: TCombatResult);
begin end;

procedure TExplorationSite.CombatExecuted(A1: TCombat); { Near miss: three variants retain different loop and object registers and a spilled index. }
var
  Data: TCombatData;
  Obj: TCombatObject;
  AUnit: TAbstractUnit;
  I: Integer;
begin
  Data := A1.FCombatData;
  for I := 0 to Data.GetCount - 1 do
  begin
    Obj := Data.GetObjects(I);
    if (Obj is TCombatUnit) and (Obj.GetPlayer = 0) then
    begin
      AUnit := TCombatUnit(Obj).FUnit;
      AUnit.AddRef;
      TCombatUnit(Obj).SetUnit(nil);
      FDefenders.AddUnit(AUnit);
      AUnit.Release;
    end;
  end;
  if A1 is TFastCombat then
    ExecuteSearchDone(ctFast, A1.FCombatResult)
  else ExecuteSearchDone(ctTactical, A1.FCombatResult);
end;

procedure TExplorationSite.SetupCombat(A1: TCombat; A2: TArmyHS);
begin
  A1.FOnExecuted := CombatExecuted;
  A1.Setup(A2.FArmy.FPlayer, A2.FArmy.FIndependentRelation, A2.GetXhx, A2.GetYhx, A2.GetLhx,
    FDefenders.FPlayer, FDefenders.FIndependentRelation, GetXhx, GetYhx, GetLhx, True);
  A1.AddArmy(A2.FArmy, csAttacker, GetXhx, GetYhx, GetLhx);
  A1.AddArmyEx(FDefenders, csDefender, -1, -1, -1, 1);
  A1.FExplorationSite := 1;
end;

function TExplorationSite.ExecuteSearch(A1: TCombatType): Boolean;
var
  ArmyHS: TArmyHS;
  Combat: TCombat;
  Player: Shortint;
  Event: TCombatEventLog;
begin
  ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
  if (ArmyHS <> nil) and CanSearch(ArmyHS.FArmy.FPlayer) then
  begin
    Player := ArmyHS.FArmy.FPlayer;
    if FDefenders.GetCount = 0 then ExecuteSearchDone(ctFast, crVictory)
    else if A1 = ctFast then
    begin
      AoWHSMap.LockGameOverEvent;
      Combat := AoWHSMap.CreateCombat($202B0);
      SetupCombat(Combat, ArmyHS);
      Combat.LockExecuted;
      Combat.Initialize;
      Combat.Activate;
      Combat.Execute;
      Combat.Deactivate;
      Combat.Finalize;
      Combat.FLogbook.FFinalData.FHeader := GetName + ' ' + Combat.FLogbook.FFinalData.FHeader;
      Event := TCombatEventLog.Create(nil);
      Event.SetCombatLogbook(Combat.FLogbook);
      AoWHSMap.FPlayers.GetPlayers(Player).FEventLogbook.AddEvent(Event);
      if (AoWHSMap.FSeatedPlayer = Player) and
        (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) then
        Event.Execute(False, etEvent, nil);
      Event.Release;
      Combat.UnlockExecuted;
      AoWHSMap.DestroyCombat;
      AoWHSMap.UnlockGameOverEvent;
    end
    else
    begin
      Combat := AoWHSMap.CreateCombat($220110);
      SetupCombat(Combat, ArmyHS);
      Combat.Initialize;
      Combat.Activate;
      if Combat.Execute <> crBusy then
      begin
        Combat.Deactivate;
        Combat.Finalize;
        Combat.FLogbook.FFinalData.FHeader := GetName + ' ' + Combat.FLogbook.FFinalData.FHeader;
        Event := TCombatEventLog.Create(nil);
        Event.SetCombatLogbook(Combat.FLogbook);
        AoWHSMap.FPlayers.GetPlayers(Player).FEventLogbook.AddEvent(Event);
        if (AoWHSMap.FSeatedPlayer = Player) and
          (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) then
          Event.Execute(False, etEvent, nil);
        Event.Release;
        AoWHSMap.DestroyCombat;
      end;
    end;
    Result := True;
  end
  else Result := False;
end;

function TExplorationSite.ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult;
begin
  Result := inherited ExecuteTE(A1, Executer);
  if A1.FAction = 0 then
    if ExecuteSearch(TCombatType(A1.FParam)) then Result := erDone
    else Result := erDoneHalt;
end;

function TExplorationSite.CanSelect(Xhp, Yhp: Integer): Boolean;
var Xhx, Yhx: Integer;
begin
  if not (msEditting in AoWHSMap.Status) then
  begin
    HPtoHX(Xhp, Yhp, Xhx, Yhx);
    if (TMapField(Owner).Xhx = Xhx) and (TMapField(Owner).Yhx = Yhx) then
      Result := inherited CanSelect(Xhp, Yhp)
    else Result := False;
  end
  else Result := inherited CanSelect(Xhp, Yhp);
end;

procedure TExplorationSite.RequestCombatTypeCallBack(A1: TEventLog);
var
  TE: TStructureTE;
begin
  with TCombatTypeRequestEventLog(A1) do
  if FCombatType <> ctNone then
  begin
    TE := CreateTE;
    SetupTE(TE);
    TE.FAction := 0;
    TE.FParam := Ord(FCombatType);
    AoWHSMap.FTokenManager.GetTokenControl(TE.FPlayer).AddEvent(TE);
    TE.Release;
  end;
end;

function TExplorationSite.CanSearch(A1: Shortint): Boolean;
var ArmyHS: TArmyHS;
begin
  if not GetExplored then
  begin
    ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
    if (ArmyHS = nil) or (ArmyHS.FArmy.FPlayer <> A1) then Result := False
    else begin Result := True; Exit; end;
  end
  else Result := False;
end;

function TExplorationSite.Search: Boolean; { Near miss: register or temporary allocation differs after three variants. }
var
  ArmyHS: TArmyHS;
  Request: TCombatTypeRequestEventLog;
  TE: TStructureTE;
begin
  ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
  if (ArmyHS <> nil) and CanSearch(ArmyHS.FArmy.FPlayer) then
  begin
    with AoWHSMap.FPlayers do
    if (FLocalPlayers.Count = 1) or AoWHSMap.FRequestCombatType then
    begin
      Request := TCombatTypeRequestEventLog.Create(nil);
      Request.SetCenterLocation(GetXhx, GetYhx, GetLhx);
      Request.FPlayer := ArmyHS.FArmy.FPlayer;
      Request.FDefenderPlayer := 0;
      AoWHSMap.TriggerExecuteEventLog(Request, True, RequestCombatTypeCallBack);
      Request.Release;
      Result := True;
    end
    else if not GetPlayers(ArmyHS.FArmy.FPlayer).GetBusy then
    begin
      TE := CreateTE;
      SetupTE(TE);
      TE.FAction := 0;
      TE.FParam := 1;
      AoWHSMap.FTokenManager.GetTokenControl(TE.FPlayer).AddEvent(TE);
      TE.Release;
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
end;

procedure TExplorationSite.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FDefenders, 5);
  Stream.rwData(FDefendersMode, 1, 6);
end;

procedure TExplorationSite.GenerateDefenders;
var
  Collection, I: Integer;
  List: TUnitIndexList;
  Collections: TUnitIndexListCollection;
begin
  RandSeed := AoWHSMap.FDefendersSeed;
  if FDefendersMode = dmRandom then
    FDefendersMode := TDefendersMode(System.Random(3) + 1);
  Collection := TExplorationSiteResource(FResource).FDefenderCollections.GetRndCollection;
  if Collection <> -1 then
  begin
    List := TUnitIndexList.Create;
    Collections := TExplorationSiteResource(FResource).FDefenderCollections;
    for I := Collections.GetCollectionCount(Collection) - 1 downto 0 do
      List.Add(Collections.GetU(Collection, I));
    try
      FillWithRandomUnits(List, FDefenders, 4, Ord(FDefendersMode) * 50,
        [utHumanoid, utCreature, utMachine]);
    except
      { Original silently ignores defender-generation failures. }
    end;
    List.Free;
  end;
end;

procedure TExplorationSite.NewDay;
begin
  inherited NewDay;
  if (AoWHSMap.FDay = 1) and (FDefendersMode <> dmUserDefined) then
    GenerateDefenders;
end;

procedure TExplorationSite.Update;
begin
  inherited Update;
  FImageIndex := GetTerrainTypeImage(FTerrainType);
end;

procedure TExplorationSite.Activate;
begin
  inherited Activate;
  FDefenders.Activate;
end;

procedure TExplorationSite.Deactivate;
begin
  FDefenders.Deactivate;
  inherited Deactivate;
end;

procedure TExplorationSite.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  FDefenders.MsgProc(Msg, Sender);
end;

constructor TExplorationSiteResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDefenderCollections := TUnitIndexListCollection.Create;
  FTerrainBound := False;
end;

destructor TExplorationSiteResource.Destroy;
begin
  FDefenderCollections.Free;
  inherited Destroy;
end;

class function TExplorationSiteResource.ResourceEditName: string;
begin Result := ''; end;

class function TExplorationSiteResource.ClassID: Integer;
begin Result := $203C2; end;

procedure TExplorationSiteResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(25, FDefenderCollections.LoadFromStream, FDefenderCollections.SaveToStream);
end;

function TExplorationSiteResource.ResourceUserClassID: Integer;
begin Result := $203C1; end;

procedure RegisterExplorationSite(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TExplorationSite, TExplorationSiteResource]);
end;


initialization
finalization

end.
