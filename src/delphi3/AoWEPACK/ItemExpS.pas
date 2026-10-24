unit ItemExpS;

{ ItemExpS, from AoWEPACK.dpl. Recovered exploration, event-log and resource
  bodies at the original instance layouts and VMT order. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, ExploreS, EventLog, AoWE;

type
  TExplorationSiteItemList = class;
  TItemExplorationSite = class;
  TItemExplorationSiteEventLog = class;
  TItemExplorationSiteResource = class;


  { TExplorationSiteItemList (instance size 24, VMT 557C2298) }
  TExplorationSiteItemList = class(TItemList)
  public
    destructor Destroy; override;
  end;

  { TItemExplorationSite (instance size 64, VMT 557C23BC): $38 FItemCount, $3C FItems. }
  TItemExplorationSite = class(TExplorationSite)
  public
    FItemCount: Byte; { $38; 0 user-defined, 4 random }
    F_ItemExplorationSite_39: array[0..2] of Byte;
    FItems: TExplorationSiteItemList; { $3C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewDay; override;
    function GetExplored: Boolean; override;
    procedure SetupCombat(A1: TCombat; A2: TArmyHS); override;
    procedure ExecuteSearchDone(A1: TCombatType; A2: TCombatResult); override;
    procedure Generate; virtual; { +204 }
  end;

  { TItemExplorationSiteEventLog (instance size 40, VMT 557C264C):
    $18 FItemIDs, $1C FMessages, $20 FTitle, $24 FLocation. }
  TItemExplorationSiteEventLog = class(TEventLog)
  public
    FItemIDs: TIntegerList; { $18 }
    FMessages: TStringList; { $1C }
    FTitle: string; { $20 }
    FLocation: TXYL; { $24 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TItemExplorationSiteResource (instance size 104, VMT 557C276C) }
  TItemExplorationSiteResource = class(TExplorationSiteResource)
  public
    class function ClassID: Integer; override;
  end;

procedure RegisterItemExplorationSite(Engine: TEngine);

implementation

{$IFDEF RUNTIME_PACKAGES}
var
  RandomSeed: ^Integer;
{$ENDIF}

type
  PAoWMap = ^TAoWHSMap;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
{$IFNDEF RUNTIME_PACKAGES}
  RandomSeed: ^Integer = @System.RandSeed;
{$ENDIF}
  ItemsFoundText: PResStringRec = @AoWE.ItemsFoundRStr;
  ItemsExploredText: PResStringRec = @AoWE.ItemsExploredRStr;
  AllItemTypes: ^TItemTypes = @AoWE.itAll;

destructor TExplorationSiteItemList.Destroy;
begin
  inherited Destroy;
end;

constructor TItemExplorationSite.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FItems := TExplorationSiteItemList.Create(nil);
  FItemCount := 2;
end;

destructor TItemExplorationSite.Destroy;
begin
  inherited Destroy;
  FItems.Free;
  FItems := nil;
end;

class function TItemExplorationSite.ClassID: Integer;
begin
  Result := $203F3;
end;

procedure TItemExplorationSite.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FItems, 8);
  Stream.rwData(FItemCount, SizeOf(FItemCount), 9);
end;

procedure TItemExplorationSite.Activate;
begin
  inherited Activate;
  FItems.RegisterItems;
end;

procedure TItemExplorationSite.Deactivate;
begin
  inherited Deactivate;
end;

function TItemExplorationSite.GetExplored: Boolean;
begin
  Result := FItems.Count = 0;
end;

procedure TItemExplorationSite.Generate; { Unmatched: tried Pointer cast map receiver; untyped pointer-cell view for item-type set. }
var I: Byte; Item: TItem;
begin
  if FItemCount <> 0 then
  begin
    RandomSeed^ := WorldMap^.Random($FFFFFF);
    if FItemCount = 4 then FItemCount := WorldMap^.Random(3) + 1;
    FItems.Clear;
    for I := 1 to FItemCount do
    begin
      Item := WorldMap^.FItemControl.GenerateItem(AllItemTypes^, 0, $FFFF);
      if Item <> nil then Item.Owner := FItems;
    end;
  end;
end;

procedure TItemExplorationSite.SetupCombat(A1: TCombat; A2: TArmyHS);
begin
  inherited SetupCombat(A1, A2);
  A1.FItems := FItems;
end;

procedure TItemExplorationSite.ExecuteSearchDone(A1: TCombatType; A2: TCombatResult); { Unmatched: tried Pointer cast map receiver; untyped pointer-cell view for map argument. }
var
  Army: TArmyHS;
  Log: TItemExplorationSiteEventLog;
  I: Integer;
  Item: TItem;
begin
  if A2 in [crVictory, crNoDefenders] then
  begin
    Army := TArmyHS(Owner.FindOwnedChild($20217));
    Log := TItemExplorationSiteEventLog.Create(nil);
    Log.FPlayer := Army.FArmy.FPlayer;
    Log.FTitle := TranslateRStr(LoadResString(ItemsFoundText));
    Log.FLocation.X := GetXhx;
    Log.FLocation.Y := GetYhx;
    Log.FLocation.L := GetLhx;
    for I := FItems.Count - 1 downto 0 do
    begin
      Item := FItems.GetItem(I);
      Log.FItemIDs.Add(Item.FItemID);
      Item.PlaceOnMap(WorldMap^, GetXhx, GetYhx, GetLhx);
    end;
    Log.FMessages.CommaText := { Original parses the formatted text as CSV. } SysUtils.Format(TranslateRStr(LoadResString(ItemsExploredText)), [FResource.ResourceEditName]);
    Log.Execute(False, etEvent, nil);
    Log.Release;
    Update;
  end;
end;

procedure TItemExplorationSite.NewDay;
begin
  inherited NewDay;
  if WorldMap^.FDay = 1 then Generate;
end;

constructor TItemExplorationSiteEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FItemIDs := TIntegerList.Create;
  FMessages := TStringList.Create;
end;

destructor TItemExplorationSiteEventLog.Destroy;
begin
  FItemIDs.Free;
  FMessages.Free;
  inherited Destroy;
end;

class function TItemExplorationSiteEventLog.ClassID: Integer;
begin Result := $203F5; end;

procedure TItemExplorationSiteEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(20, FItemIDs.LoadFromStream, FItemIDs.SaveToStream);
  Stream.rwStrings(FMessages, 21);
  Stream.rwString(FTitle, 22);
end;

class function TItemExplorationSiteResource.ClassID: Integer;
begin Result := $203F4; end;

procedure RegisterItemExplorationSite(Engine: TEngine);
begin
  Engine.RegisterEClasses([TItemExplorationSiteEventLog]);
end;

initialization
{$IFDEF RUNTIME_PACKAGES}
  RandomSeed := @System.RandSeed;
{$ENDIF}
finalization

end.
