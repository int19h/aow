unit ExploreS;

{ Draft declarations of ExploreS, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TDefendersArmy = class;
  TExplorationSite = class;
  TExplorationSiteResource = class;

  TDefendersMode = (dmUserDefined, dmLow, dmNormal, dmHigh, dmRandom);  { ot=1 }

  { TDefendersArmy (instance size 44, VMT 557C12B4) }
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

  { TExplorationSiteResource (instance size 104, VMT 557C16C4) }
  TExplorationSiteResource = class(TStructureResource)
  public
    F_ExplorationSiteResource_64: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterExplorationSite;  { draft }

implementation

function TDefendersArmy.CanAddUnit(AUnit: TAbstractUnit): Boolean;
begin Result := False; end;

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
begin end;

destructor TExplorationSiteResource.Destroy;
begin end;

class function TExplorationSiteResource.ResourceEditName: string;
begin Result := ''; end;

class function TExplorationSiteResource.ClassID: Integer;
begin Result := 0; end;

procedure TExplorationSiteResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TExplorationSiteResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterExplorationSite;
begin end;


initialization
finalization

end.
