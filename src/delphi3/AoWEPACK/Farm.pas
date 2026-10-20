unit Farm;

{ Draft declarations of Farm, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Crops;

type
  TFarm = class;
  TFarmResource = class;

  TFarmMode = set of (fmRazed); { ot=1 }

  { TFarm (instance size 72, VMT 557B281C) }
  TFarm = class(TPlayerCropStructure)
  public
    F_Farm_44: Byte;
    F_Farm_45: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    function GetCurrentActivityText: string; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Priority: Integer); override;
    procedure CanPlaceCrop(A1: Integer); override;
    procedure CropsEnabled; override;
    procedure UpdateCrops; override;
  end;

  { TFarmResource (instance size 120, VMT 557B2AC4) }
  TFarmResource = class(TPlayerCropStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure FarmIncome(A1: Byte);  { draft }
procedure RegisterFarm;  { draft }

implementation

class function TFarm.ClassID: Integer;
begin Result := 0; end;

function TFarm.GetRazed: Boolean;
begin end;

procedure TFarm.SetRazed(Value: Boolean);
begin end;

function TFarm.GetCurrentActivityText: string;
begin end;

procedure TFarm.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFarm.CropsEnabled;
begin end;

procedure TFarm.CanPlaceCrop(A1: Integer);
begin end;

procedure TFarm.UpdateCrops;
begin end;

procedure TFarm.UpdateAITarget(const Info: TAITargetInfo; var Priority: Integer);
begin end;

procedure TFarm.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

constructor TFarmResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFarmResource.ResourceEditName: string;
begin Result := ''; end;

class function TFarmResource.ClassID: Integer;
begin Result := 0; end;

function TFarmResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure FarmIncome(A1: Byte);
begin end;

procedure RegisterFarm;
begin end;


initialization
finalization

end.
