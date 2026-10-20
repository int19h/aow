unit Crops;

{ Draft declarations of Crops, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TPlayerCropStructure = class;
  TPlayerCropStructureResource = class;
  TCrop = class;
  TCropResource = class;


  { TPlayerCropStructure (instance size 68, VMT 557A5634) }
  TPlayerCropStructure = class(TPlayerStructure)
  public
    F_PlayerCropStructure_3C: Integer;
    F_PlayerCropStructure_40: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo); override;
    procedure Remove; override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    procedure NewTurn(A1: Integer); override;
    procedure SetPlayer(A1: Integer; A2: Integer); override;
    procedure GetIncome(A1: Integer; A2: Integer); override;
    procedure CanPlaceCrop(A1: Integer); virtual;  { +224 draft }
    procedure CropsEnabled; virtual;  { +228 draft }
    procedure RegrowCrops; virtual;  { +22C draft }
    procedure UpdateIncome(A1: Integer; A2: Integer); virtual;  { +230 draft }
    procedure UpdateCrops; virtual;  { +234 draft }
    procedure GetRace; virtual;  { +238 draft }
    procedure CropsChanged; virtual;  { +23C draft }
    procedure CropTrampled(A1: Integer); virtual;  { +240 draft }
    procedure SetIncome(A1: Byte);  { draft }
    procedure UpdateCropSettings;  { draft }
    procedure GetCropCount;  { draft }
    procedure SetCropCount(A1: Integer);  { draft }
    procedure LinkToCrops;  { draft }
  end;

  { TPlayerCropStructureResource (instance size 120, VMT 557A58FC) }
  TPlayerCropStructureResource = class(TPlayerStructureResource)
  public
    F_PlayerCropStructureResource_74: Integer;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function ResourceUserClassID: Integer; override;
  end;

  { TCrop (instance size 32, VMT 557A5A10) }
  TCrop = class(TILTerrainMO)
  public
    F_Crop_1C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure SetCropOwner(A1: Integer);  { draft }
    procedure UpdateSettings;  { draft }
    procedure EndTurn(A1: Integer);  { draft }
    procedure LinkToCropOwner;  { draft }
  end;

  { TCropResource (instance size 68, VMT 557A5BB0) }
  TCropResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure SetLevel(Value: Byte); override;
    procedure PlaceCrop(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

procedure RegisterCrops(A1: Integer);  { draft }

implementation

constructor TCrop.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCrop.Destroy;
begin end;

class function TCrop.ClassID: Integer;
begin Result := 0; end;

procedure TCrop.SetCropOwner(A1: Integer);
begin end;

procedure TCrop.UpdateSettings;
begin end;

procedure TCrop.EndTurn(A1: Integer);
begin end;

procedure TCrop.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TCrop.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TCrop.LinkToCropOwner;
begin end;

procedure TCrop.Activate;
begin end;

procedure TCrop.Deactivate;
begin end;

function TCrop.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TCrop.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

function TCrop.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

function TCrop.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

class function TCropResource.ClassID: Integer;
begin Result := 0; end;

procedure TCropResource.SetLevel(Value: Byte);
begin end;

function TCropResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TCropResource.ResourceEditName: string;
begin Result := ''; end;

procedure TCropResource.PlaceCrop(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TPlayerCropStructure.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerCropStructure.Destroy;
begin end;

class function TPlayerCropStructure.ClassID: Integer;
begin Result := 0; end;

procedure TPlayerCropStructure.GetIncome(A1: Integer; A2: Integer);
begin end;

procedure TPlayerCropStructure.CropTrampled(A1: Integer);
begin end;

procedure TPlayerCropStructure.SetIncome(A1: Byte);
begin end;

procedure TPlayerCropStructure.RegrowCrops;
begin end;

procedure TPlayerCropStructure.CropsEnabled;
begin end;

procedure TPlayerCropStructure.NewTurn(A1: Integer);
begin end;

procedure TPlayerCropStructure.UpdateIncome(A1: Integer; A2: Integer);
begin end;

procedure TPlayerCropStructure.CropsChanged;
begin end;

procedure TPlayerCropStructure.SetPlayer(A1: Integer; A2: Integer);
begin end;

procedure TPlayerCropStructure.Activate;
begin end;

procedure TPlayerCropStructure.Deactivate;
begin end;

procedure TPlayerCropStructure.UpdateCropSettings;
begin end;

procedure TPlayerCropStructure.UpdateCrops;
begin end;

procedure TPlayerCropStructure.GetRace;
begin end;

procedure TPlayerCropStructure.GetCropCount;
begin end;

procedure TPlayerCropStructure.CanPlaceCrop(A1: Integer);
begin end;

procedure TPlayerCropStructure.SetCropCount(A1: Integer);
begin end;

procedure TPlayerCropStructure.NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo);
begin end;

procedure TPlayerCropStructure.Remove;
begin end;

procedure TPlayerCropStructure.LinkToCrops;
begin end;

function TPlayerCropStructure.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

function TPlayerCropStructure.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

destructor TPlayerCropStructureResource.Destroy;
begin end;

class function TPlayerCropStructureResource.ClassID: Integer;
begin Result := 0; end;

function TPlayerCropStructureResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TPlayerCropStructureResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure RegisterCrops(A1: Integer);
begin end;


initialization
finalization

end.
