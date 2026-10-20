unit ExploreS;

{ ExploreS of AoWEPACK.dpl: original instance layouts; TDefendersArmy and
  TExplorationSiteResource recovered. TExplorationSite remains a draft. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

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

  { TExplorationSite (instance size 56, VMT 557C1440) }
  TExplorationSite = class(TStructure)
  public
    F_ExplorationSite_30: Byte;
    F_ExplorationSite_31: array[0..2] of Byte;
    F_ExplorationSite_34: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure ExecuteTE(A1: Integer; A2: Integer); override;
    procedure NewDay; override;
    procedure Update; override;
    procedure GetExplored; virtual;  { +1F0 draft }
    procedure SetupCombat(A1: Integer; A2: Integer); virtual;  { +1F4 draft }
    procedure ExecuteSearchDone(A1: Integer; A2: Byte); virtual;  { +1F8 draft }
    procedure ExecuteSearch(A1: Byte); virtual;  { +1FC draft }
    procedure Search; virtual;  { +200 draft }
    procedure CombatExecuted(A1: Integer);  { draft }
    procedure RequestCombatTypeCallBack(A1: Integer);  { draft }
    procedure CanSearch(A1: Integer);  { draft }
    procedure GenerateDefenders;  { draft }
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
begin end;

destructor TExplorationSite.Destroy;
begin end;

class function TExplorationSite.ClassID: Integer;
begin Result := 0; end;

procedure TExplorationSite.GetExplored;
begin end;

function TExplorationSite.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

procedure TExplorationSite.ExecuteSearchDone(A1: Integer; A2: Byte);
begin end;

procedure TExplorationSite.CombatExecuted(A1: Integer);
begin end;

procedure TExplorationSite.SetupCombat(A1: Integer; A2: Integer);
begin end;

procedure TExplorationSite.ExecuteSearch(A1: Byte);
begin end;

procedure TExplorationSite.ExecuteTE(A1: Integer; A2: Integer);
begin end;

function TExplorationSite.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TExplorationSite.RequestCombatTypeCallBack(A1: Integer);
begin end;

procedure TExplorationSite.CanSearch(A1: Integer);
begin end;

procedure TExplorationSite.Search;
begin end;

procedure TExplorationSite.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TExplorationSite.GenerateDefenders;
begin end;

procedure TExplorationSite.NewDay;
begin end;

procedure TExplorationSite.Update;
begin end;

procedure TExplorationSite.Activate;
begin end;

procedure TExplorationSite.Deactivate;
begin end;

procedure TExplorationSite.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

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
