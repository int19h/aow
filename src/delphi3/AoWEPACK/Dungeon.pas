unit Dungeon;

{ Draft declarations of Dungeon, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, ExploreS;

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

  { TDungeon (instance size 64, VMT 557C557C) }
  TDungeon = class(TExplorationSite)
  public
    F_Dungeon_38: Integer;
    F_Dungeon_3C: Byte;
    F_Dungeon_3D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure ExecuteTE(A1: Integer; A2: Integer); override;
    procedure NewDay; override;
    procedure GetExplored; override;
    procedure SetupCombat(A1: Integer; A2: Integer); override;
    procedure ExecuteSearchDone(A1: Integer; A2: Byte); override;
    procedure GeneratePrisoners(A1: Integer; A2: Integer);  { draft }
    procedure LiberatePrisoners(A1: Byte);  { draft }
  end;

  { TDungeonResource (instance size 108, VMT 557C57F0) }
  TDungeonResource = class(TExplorationSiteResource)
  public
    F_DungeonResource_68: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TPrisonersJoinEventLog (instance size 64, VMT 557C58EC) }
  TPrisonersJoinEventLog = class(TJoinEventLog)
  public
    F_PrisonersJoinEventLog_3C: Byte;
    F_PrisonersJoinEventLog_3D: Byte;
    F_PrisonersJoinEventLog_3E: Byte;
    F_PrisonersJoinEventLog_3F: array[0..0] of Byte;
    function Accept(var ErrorText: string): Boolean; override;
    function Cancel: Boolean; override;
  end;

procedure RegisterDungeon;  { draft }

implementation

function TPrisonersArmy.CanAddUnit(AUnit: TAbstractUnit): Boolean;
begin Result := False; end;

constructor TDungeon.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TDungeon.Destroy;
begin end;

class function TDungeon.ClassID: Integer;
begin Result := 0; end;

procedure TDungeon.GetExplored;
begin end;

procedure TDungeon.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TDungeon.SetupCombat(A1: Integer; A2: Integer);
begin end;

procedure TDungeon.ExecuteSearchDone(A1: Integer; A2: Byte);
begin end;

procedure TDungeon.GeneratePrisoners(A1: Integer; A2: Integer);
begin end;

procedure TDungeon.LiberatePrisoners(A1: Byte);
begin end;

procedure TDungeon.NewDay;
begin end;

procedure TDungeon.Activate;
begin end;

procedure TDungeon.Deactivate;
begin end;

procedure TDungeon.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TDungeon.ExecuteTE(A1: Integer; A2: Integer);
begin end;

constructor TDungeonResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TDungeonResource.Destroy;
begin end;

class function TDungeonResource.ResourceEditName: string;
begin Result := ''; end;

class function TDungeonResource.ClassID: Integer;
begin Result := 0; end;

function TDungeonResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TDungeonResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TPrisonersJoinEventLog.Accept(var ErrorText: string): Boolean;
begin Result := False; end;

function TPrisonersJoinEventLog.Cancel: Boolean;
begin Result := False; end;

procedure RegisterDungeon;
begin end;


initialization
finalization

end.
