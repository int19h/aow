unit Arena;

{ Arenas of AoWEPACK.dpl: unit training, token events and the selection log. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  TArenaTE = class;
  TArena = class;
  TArenaResource = class;
  TEnterArenaEventLog = class;


  { TArenaTE: size $2C; $28 FUnitIDs. }
  TArenaTE = class(TStructureTE)
  public
    FUnitIDs: TIntegerList;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TArena (instance size 48, VMT 557D6240) }
  TArena = class(TStructure)
  public
    class function ClassID: Integer; override;
    function CreateTE: TStructureTE; override;
    function ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult; override;
    function CanDblClick: Boolean; override;
    function UnitTrainCost(AUnit: TAbstractUnit): Integer;
    procedure ExecuteTrainUnit(AUnit: TAbstractUnit);
    function CanTrainUnits(Player: Shortint; Units: TIntegerList; var ErrorText: string): Boolean;
    function TrainUnits(Player: Shortint; Units: TIntegerList; var ErrorText: string): Boolean;
    function CanEnter(Player: Shortint): Boolean;
    function Enter: Boolean;
  end;

  { TArenaResource (instance size 100, VMT 557D6498) }
  TArenaResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TEnterArenaEventLog: size $24; $18 FArena, $1C FSelection,
    $1D FTrainable, $20 FUnitIDs. }
  TEnterArenaEventLog = class(TEventLog)
  public
    FArena: TArena;
    FSelection: Byte;
    FTrainable: Byte;
    FReserved1E: array[0..1] of Byte;
    FUnitIDs: TIntegerList;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCount: Integer;
    function GetUnit(Index: Integer): TAbstractUnit;
    procedure SetSelection(Value: Byte);
    function Train(var ErrorText: string): Boolean;
    function CanTrain(var ErrorText: string): Boolean;
    function GetSelectionInfo: string;
  end;

procedure RegisterArena(AEngine: TEngine);

implementation

constructor TArenaTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIDs := TIntegerList.Create;
end;

destructor TArenaTE.Destroy;
begin
  FUnitIDs.Free;
  inherited Destroy;
end;

class function TArenaTE.ClassID: Integer;
begin Result := $208AE; end;

procedure TArenaTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(40, FUnitIDs.LoadFromStream, FUnitIDs.SaveToStream);
end;

class function TArena.ClassID: Integer;
begin Result := $2089C; end;

function TArena.CanDblClick: Boolean;
begin Result := CanEnter(AoWHSMap.FSeatedPlayer); end;

function TArena.UnitTrainCost(AUnit: TAbstractUnit): Integer;
begin
  if AUnit is THero then
  begin
    { The original rejects heroes, although ExecuteTrainUnit supports them. }
    Result := -1;
    Exit;
  end;
  if AUnit is TUnit then
    with TUnit(AUnit) do
      if GetRank <> urGold then Result := (GetNextLevelExperience - AUnit.GetExperience) * 5
      else Result := -1
  else Result := -1;
end;

procedure TArena.ExecuteTrainUnit(AUnit: TAbstractUnit);
begin
  if AUnit is THero then
  begin
    with THero(AUnit) do
    begin
      SetExperience(GetNextLevelExperience);
      Changed;
    end;
    Exit;
  end;
  if AUnit is TUnit then
    with TUnit(AUnit) do
    begin
      SetExperience(GetNextLevelExperience);
      Changed;
    end;
end;

function TArena.ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult;
var I: Integer; AUnit: TAbstractUnit; ErrorText: string;
begin
  Result := inherited ExecuteTE(A1, Executer);
  if A1.FAction = 1 then
    if CanTrainUnits(A1.FParam, TArenaTE(A1).FUnitIDs, ErrorText) then
    begin
      for I := 0 to TArenaTE(A1).FUnitIDs.Count - 1 do
      begin
        AUnit := AoWHSMap.FUnitControl.FindUnit(TArenaTE(A1).FUnitIDs[I]);
        if AUnit <> nil then
        begin
          AoWHSMap.FPlayers.GetPlayers(A1.FParam).SetGems(
            AoWHSMap.FPlayers.GetPlayers(A1.FParam).FGems - UnitTrainCost(AUnit));
          ExecuteTrainUnit(AUnit);
        end;
      end;
      if AoWHSMap.FSeatedPlayer = A1.FParam then
        with TArenaTE(A1) do
          if FUnitIDs.Count = 1 then AoWHSMap.ShowMessage(TranslateRStr(OneUnitTrainedRStr))
          else AoWHSMap.ShowMessage(Format(TranslateRStr(XUnitsTrainedRStr), [IntToStr(FUnitIDs.Count)]));
    end;
end;

function TArena.CanTrainUnits(Player: Shortint; Units: TIntegerList; var ErrorText: string): Boolean;
var Total, I, Cost: Integer; AUnit: TAbstractUnit;
begin
  if Units.Count <> 0 then
  begin
    Total := 0;
    I := Units.Count;
    Result := True;
    while Result and (I <> 0) do
    begin
      Dec(I);
      AUnit := AoWHSMap.FUnitControl.FindUnit(Units[I]);
      if AUnit <> nil then
      begin
        Cost := UnitTrainCost(AUnit);
        if Cost <> -1 then Inc(Total, Cost)
        else Result := False;
      end
      else Result := False;
    end;
    if Result then
      if AoWHSMap.FPlayers.GetPlayers(Player).FGems >= Total then Result := True
      else
      begin
        Result := False;
        ErrorText := TranslateRStr(NotEnoughGoldRStr);
      end;
  end
  else
  begin
    Result := False;
    ErrorText := TranslateRStr(NoUnitSelectedRStr);
  end;
end;

function TArena.TrainUnits(Player: Shortint; Units: TIntegerList; var ErrorText: string): Boolean;
var TE: TArenaTE;
begin
  ErrorText := '';
  if CanTrainUnits(Player, Units, ErrorText) and not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy then
  begin
    TE := TArenaTE(CreateTE);
    SetupTE(TE);
    TE.FUnitIDs.Assign(Units);
    TE.FParam := Player;
    TE.FAction := 1;
    AoWHSMap.FTokenManager.GetTokenControl(Player).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function TArena.CreateTE: TStructureTE;
begin Result := TArenaTE.Create(nil); end;

function TArena.CanEnter(Player: Shortint): Boolean;
var Army: TArmyHS;
begin
  Army := TArmyHS(FOwner.FindOwnedChild($20217));
  if (Army <> nil) and (Army.FArmy.FPlayer = Player) then Result := True
  else Result := False;
end;

function TArena.Enter: Boolean;
var Log: TEnterArenaEventLog; Army: TArmyHS; I: Integer;
begin
  if CanEnter(AoWHSMap.FSeatedPlayer) then
  begin
    Log := TEnterArenaEventLog.Create(nil);
    Log.FArena := Self;
    Army := TArmyHS(FOwner.FindOwnedChild($20217));
    for I := 0 to Army.FArmy.Count - 1 do
    begin
      Log.FUnitIDs.Add(Army.FArmy.GetUnit(I).FUnitID);
      if UnitTrainCost(Army.FArmy.GetUnit(I)) <> -1 then
        Log.FTrainable := Log.FTrainable or (1 shl I);
    end;
    Log.Execute(True, etUser, nil);
    Log.Release;
    Result := True;
  end
  else Result := False;
end;

constructor TArenaResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCastsShadow := True;
end;

class function TArenaResource.ResourceEditName: string;
begin Result := TranslateRStr(ArenaRStr); end;

class function TArenaResource.ClassID: Integer;
begin Result := $2089D; end;

function TArenaResource.ResourceUserClassID: Integer;
begin Result := $2089C; end;

constructor TEnterArenaEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIDs := TIntegerList.Create;
end;

destructor TEnterArenaEventLog.Destroy;
begin
  FUnitIDs.Free;
  inherited Destroy;
end;

function TEnterArenaEventLog.GetCount: Integer;
begin Result := FUnitIDs.Count; end;

function TEnterArenaEventLog.GetUnit(Index: Integer): TAbstractUnit;
begin
  if (Index >= 0) and (Index < FUnitIDs.Count) then
    Result := AoWHSMap.FUnitControl.FindUnit(FUnitIDs[Index])
  else Result := nil;
end;

procedure TEnterArenaEventLog.SetSelection(Value: Byte);
begin FSelection := Value and FTrainable; end;

function TEnterArenaEventLog.Train(var ErrorText: string): Boolean;
var Units: TIntegerList; I: Integer;
begin
  Units := TIntegerList.Create;
  for I := 0 to FUnitIDs.Count - 1 do
    if (1 shl I) and FSelection <> 0 then Units.Add(FUnitIDs[I]);
  Result := FArena.TrainUnits(AoWHSMap.FSeatedPlayer, Units, ErrorText);
  Units.Free;
end;

function TEnterArenaEventLog.CanTrain(var ErrorText: string): Boolean;
var Units: TIntegerList; I: Integer;
begin
  Units := TIntegerList.Create;
  for I := 0 to FUnitIDs.Count - 1 do
    if (1 shl I) and FSelection <> 0 then Units.Add(FUnitIDs[I]);
  Result := FArena.CanTrainUnits(AoWHSMap.FSeatedPlayer, Units, ErrorText);
  Units.Free;
end;

function TEnterArenaEventLog.GetSelectionInfo: string;
var Total, I: Integer; AUnit: TAbstractUnit;
begin
  Total := 0;
  for I := 0 to FUnitIDs.Count - 1 do
    if (1 shl I) and FSelection <> 0 then
    begin
      AUnit := AoWHSMap.FUnitControl.FindUnit(FUnitIDs[I]);
      if AUnit <> nil then Inc(Total, FArena.UnitTrainCost(AUnit));
    end;
  if Total <> 0 then Result := Format(TranslateRStr(TotalCostXRStr), [IntToStr(Total)])
  else Result := '';
end;

procedure RegisterArena(AEngine: TEngine);
begin AEngine.RegisterEClasses([TArena, TArenaTE, TArenaResource]); end;

initialization
finalization
end.
