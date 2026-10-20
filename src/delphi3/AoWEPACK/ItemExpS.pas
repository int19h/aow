unit ItemExpS;

{ Draft declarations of ItemExpS, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, ExploreS;

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

  { TItemExplorationSite (instance size 64, VMT 557C23BC) }
  TItemExplorationSite = class(TExplorationSite)
  public
    F_ItemExplorationSite_38: Byte;
    F_ItemExplorationSite_39: array[0..2] of Byte;
    F_ItemExplorationSite_3C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure NewDay; override;
    procedure GetExplored; override;
    procedure SetupCombat(A1: Integer; A2: Integer); override;
    procedure ExecuteSearchDone(A1: Integer; A2: Byte); override;
    procedure Generate; virtual;  { +204 draft }
  end;

  { TItemExplorationSiteEventLog (instance size 40, VMT 557C264C) }
  TItemExplorationSiteEventLog = class(TEventLog)
  public
    F_ItemExplorationSiteEventLog_18: array[0..3] of Byte;
    F_ItemExplorationSiteEventLog_1C: Integer;
    F_ItemExplorationSiteEventLog_20: Integer;
    F_ItemExplorationSiteEventLog_24: array[0..3] of Byte;
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

procedure RegisterItemExplorationSite(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

destructor TExplorationSiteItemList.Destroy;
begin end;

constructor TItemExplorationSite.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TItemExplorationSite.Destroy;
begin end;

class function TItemExplorationSite.ClassID: Integer;
begin Result := 0; end;

procedure TItemExplorationSite.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TItemExplorationSite.Activate;
begin end;

procedure TItemExplorationSite.Deactivate;
begin end;

procedure TItemExplorationSite.GetExplored;
begin end;

procedure TItemExplorationSite.Generate;
begin end;

procedure TItemExplorationSite.SetupCombat(A1: Integer; A2: Integer);
begin end;

procedure TItemExplorationSite.ExecuteSearchDone(A1: Integer; A2: Byte);
begin end;

procedure TItemExplorationSite.NewDay;
begin end;

constructor TItemExplorationSiteEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TItemExplorationSiteEventLog.Destroy;
begin end;

class function TItemExplorationSiteEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TItemExplorationSiteEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function TItemExplorationSiteResource.ClassID: Integer;
begin Result := 0; end;

procedure RegisterItemExplorationSite(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
