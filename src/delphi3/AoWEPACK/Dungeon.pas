unit Dungeon;

{ Dungeon, from AoWEPACK.dpl. Recovered prisoners, liberation and resource
  bodies at the original instance layouts and VMT order. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, ExploreS, EventLog;

type
  TPrisonersArmy = class;
  TDungeon = class;
  TDungeonResource = class;
  TPrisonersJoinEventLog = class;

  TPrisonersMode = (pmUserDefined, pmLow, pmNormal, pmHigh, pmRandom);  { ot=1 }

  { TPrisonersArmy (instance size 44, VMT 557C53F4) }
  TPrisonersArmy = class(TArmy)
  public
    function CanAddUnit(AUnit: TAbstractUnit): Boolean; override;
  end;

  { TDungeon (instance size 64, VMT 557C557C): $38 FPrisoners, $3C FPrisonersMode. }
  TDungeon = class(TExplorationSite)
  public
    FPrisoners: TPrisonersArmy; { $38 }
    FPrisonersMode: TPrisonersMode; { $3C }
    F_Dungeon_3D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult; override;
    procedure NewDay; override;
    function GetExplored: Boolean; override;
    procedure SetupCombat(A1: TCombat; A2: TArmyHS); override;
    procedure ExecuteSearchDone(A1: TCombatType; A2: TCombatResult); override;
    procedure GeneratePrisoners;
    procedure LiberatePrisoners(Player: Shortint);
  end;

  { TDungeonResource (instance size 108, VMT 557C57F0): $68 FPrisonerCollections. }
  TDungeonResource = class(TExplorationSiteResource)
  public
    FPrisonerCollections: TUnitIndexListCollection; { $68 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TPrisonersJoinEventLog (instance size 64, VMT 557C58EC): $3C FX, $3D FY, $3E FL. }
  TPrisonersJoinEventLog = class(TJoinEventLog)
  public
    FX: Shortint; { $3C }
    FY: Shortint; { $3D }
    FL: Shortint; { $3E }
    F_PrisonersJoinEventLog_3F: array[0..0] of Byte;
    function Accept(var ErrorText: string): Boolean; override;
    function Cancel: Boolean; override;
  end;

procedure RegisterDungeon(Engine: TEngine);

implementation

type
  PAoWMap = ^TAoWHSMap;
  PAoWSet = ^TAoWHSSet;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
  WorldSet: PAoWSet = @AoWE.AoWHSSet;
  RandomSeed: ^Integer = @System.RandSeed;

function TPrisonersArmy.CanAddUnit(AUnit: TAbstractUnit): Boolean;
begin
  Result := inherited CanAddUnit(AUnit);
  Result := Result and not AUnit.GetTransporter and AUnit.ValidTerrain(1, 4);
end;

constructor TDungeon.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPrisonersMode := pmNormal;
  FPrisoners := TPrisonersArmy.Create(nil);
end;

destructor TDungeon.Destroy;
begin
  inherited Destroy;
  FPrisoners.Free;
end;

class function TDungeon.ClassID: Integer;
begin Result := $2032A; end;

function TDungeon.GetExplored: Boolean;
begin Result := FPrisoners.Count = 0; end;

procedure TDungeon.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FPrisoners, 8);
  Stream.rwData(FPrisonersMode, 1, 9);
end;

procedure TDungeon.SetupCombat(A1: TCombat; A2: TArmyHS);
begin
  inherited SetupCombat(A1, A2);
  A1.FItems := FPrisoners;
end;

procedure TDungeon.ExecuteSearchDone(A1: TCombatType; A2: TCombatResult);
var
  Army: TArmyHS;
  Log: TPrisonersJoinEventLog;
  I: Integer;
begin
  if A2 in [crVictory, crNoDefenders] then
  begin
    Army := TArmyHS(Owner.FindOwnedChild($20217));
    Log := TPrisonersJoinEventLog.Create(nil);
    Log.FX := GetXhx;
    Log.FY := GetYhx;
    Log.FL := GetLhx;
    Log.FPlayer := Army.FArmy.FPlayer;
    Log.FSelection := $FF;
    Log.FGold := 0;
    Log.FJoinMode := jmDefault;
    Log.FFirstUnitID := FPrisoners.GetUnit(0).FUnitID;
    for I := 0 to FPrisoners.Count - 1 do
      Log.FUnitIDs.Add(FPrisoners.GetUnit(I).FUnitID);
    if FPrisoners.Count = 1 then
      Log.FJoinMessage.Text := TranslateRStr(LiberatePrisonerMessageRStr)
    else
      Log.FJoinMessage.Text := TranslateRStr(LiberatePrisonersMessageRStr);
    Log.Execute(False, etEvent, nil);
    Log.Release;
  end;
end;

procedure TDungeon.GeneratePrisoners;
var
  Collection, I: Integer;
  List: TUnitIndexList;
  Collections: TUnitIndexListCollection;
begin
  RandomSeed^ := WorldMap^.FDefendersSeed;
  if FPrisonersMode = pmRandom then
    FPrisonersMode := TPrisonersMode(System.Random(3) + 1);
  Collection := TDungeonResource(FResource).FPrisonerCollections.GetRndCollection;
  if Collection <> -1 then
  begin
    List := TUnitIndexList.Create;
    Collections := TDungeonResource(FResource).FPrisonerCollections;
    for I := Collections.GetCollectionCount(Collection) - 1 downto 0 do
      List.Add(Collections.GetU(Collection, I));
    FillWithRandomUnits(List, FPrisoners, 4, Ord(FPrisonersMode) * 50,
      [utHumanoid, utCreature, utMachine]);
    List.Free;
  end;
end;

procedure TDungeon.LiberatePrisoners(Player: Shortint);
var
  LocationLog: TLocationTextEventLog;
  ArmyLog: TArmyInfoEventLog;
  Hero: THero;
  Army: TArmyHS;
begin
  LocationLog := TLocationTextEventLog.Create(nil);
  LocationLog.FPlayer := GetPlayer;
  LocationLog.FText := SysUtils.Format(TranslateRStr(XExploredRStr), [GetName]);
  LocationLog.SetLocation(GetXhx, GetYhx, GetLhx);
  DistributeLocationEventLog(LocationLog, Player, GetXhx, GetYhx, GetLhx, False);
  LocationLog.Release;
  ArmyLog := TArmyInfoEventLog.Create(nil);
  ArmyLog.FArmyView.Setup(FPrisoners, $FF);
  ArmyLog.FArmyView.FX := GetXhx;
  ArmyLog.FArmyView.FY := GetYhx;
  ArmyLog.FArmyView.FL := GetLhx;
  ArmyLog.FSelection := $FF;
  ArmyLog.FPlayer := GetPlayer;
  ArmyLog.FTitle := TranslateRStr(PrisonerLiberationRStr);
  ArmyLog.FDescription := '';
  Hero := FPrisoners.Hero($FF, [htHero]);
  if Hero = nil then
    if FPrisoners.Count = 1 then
    begin
      ArmyLog.FText := TranslateRStr(OnePrisonerLiberatedRStr);
      ArmyLog.FMessages.Text := SysUtils.Format(TranslateRStr(AfterLiberationOneUnitJoinedTheForcesOfXRStr),
        [WorldMap^.FPlayers.GetPlayers(Player).GetName]);
    end
    else
    begin
      ArmyLog.FText := SysUtils.Format(TranslateRStr(XPrisonersLiberatedRStr), [IntToStr(FPrisoners.Count)]);
      ArmyLog.FMessages.Text := SysUtils.Format(TranslateRStr(AfterLiberationXunitsJoinedTheForcesOfYRStr),
        [FPrisoners.Count, WorldMap^.FPlayers.GetPlayers(Player).GetName]);
    end
  else
  begin
    ArmyLog.FText := SysUtils.Format(TranslateRStr(XLiberatedRStr), [Hero.FHeroName]);
    ArmyLog.FMessages.Text := SysUtils.Format(TranslateRStr(AfterLiberationXJoinedTheForcesOfYRStr),
      [Hero.FHeroName, WorldMap^.FPlayers.GetPlayers(Player).GetName]);
  end;
  DistributeLocationEventLog(ArmyLog, -1, GetXhx, GetYhx, GetLhx, False);
  ArmyLog.Release;
  Army := TArmyHS.Create(nil);
  Army.FArmy.BeginUpdate;
  Army.FArmy.SetPlayer(Player);
  Army.FArmy.AddUnits(FPrisoners);
  Army.PlaceEx(GetXhx, GetYhx, GetLhx, [apSafe, apScanArea]);
  Army.Activate;
  Army.FArmy.EndUpdate;
end;

procedure TDungeon.NewDay;
begin
  inherited NewDay;
  if WorldMap^.FDay = 1 then GeneratePrisoners;
end;

procedure TDungeon.Activate;
begin
  inherited Activate;
  FPrisoners.Activate;
end;

procedure TDungeon.Deactivate;
begin
  FPrisoners.Deactivate;
  inherited Deactivate;
end;

procedure TDungeon.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  FPrisoners.MsgProc(Msg, Sender);
end;

function TDungeon.ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult;
begin
  Result := inherited ExecuteTE(A1, Executer);
  if A1.FAction = 1 then
  begin
    LiberatePrisoners(A1.FParam);
    Result := erDone;
  end;
end;

constructor TDungeonResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPrisonerCollections := TUnitIndexListCollection.Create;
end;

destructor TDungeonResource.Destroy;
begin
  FPrisonerCollections.Free;
  inherited Destroy;
end;

class function TDungeonResource.ResourceEditName: string;
begin Result := TranslateRStr(DungeonRStr); end;

class function TDungeonResource.ClassID: Integer;
begin Result := $2032B; end;

function TDungeonResource.ResourceUserClassID: Integer;
begin Result := $2032A; end;

procedure TDungeonResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(30, FPrisonerCollections.LoadFromStream, FPrisonerCollections.SaveToStream);
end;

function TPrisonersJoinEventLog.Accept(var ErrorText: string): Boolean;
var
  Dungeon: TDungeon;
  TE: TStructureTE;
begin
  Dungeon := TDungeon(WorldMap^.MapContainer.GetField(FX, FY, FL).FindOwnedChild($2032A));
  if (Dungeon <> nil) and not WorldMap^.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    TE := Dungeon.CreateTE;
    Dungeon.SetupTE(TE);
    TE.FParam := FPlayer;
    TE.FAction := 1;
    WorldMap^.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function TPrisonersJoinEventLog.Cancel: Boolean;
var
  Dungeon: TDungeon;
  I, Index: Integer;
begin
  Dungeon := TDungeon(WorldMap^.MapContainer.GetField(FX, FY, FL).FindOwnedChild($2032A));
  if Dungeon <> nil then
    for I := 0 to Dungeon.FPrisoners.Count - 1 do
      if Dungeon.FPrisoners.GetUnit(I).GetUnitType in [utHumanoid, utCreature] then
      begin
        Index := Dungeon.FPrisoners.GetUnit(I).GetUnitGFXResourceIndex;
        if WorldSet^.FUnitGFXResources.GetUnitGFXResource(Index) <> nil then
          WorldSet^.FUnitGFXResources.GetUnitGFXResource(Index).FSFXLibraries[3].PlayEx(
            0, 100, False, System.Random(15), spCenter, nil);
      end;
  Result := True;
end;

procedure RegisterDungeon(Engine: TEngine);
begin
  Engine.RegisterEClasses([TDungeon, TDungeonResource]);
end;

initialization
finalization

end.
