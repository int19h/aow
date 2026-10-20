unit Shipyard;

{ Draft declarations of Shipyard, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TShipyard = class;
  TShipyardResource = class;
  TShipyardConstructionControl = class;


  { TShipyard (instance size 76, VMT 557C715C) }
  TShipyard = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    procedure UpdateAITarget(A1: Integer; A2: Integer); override;
    procedure GetBaseIncome; override;
  end;

  { TShipyardResource (instance size 120, VMT 557C740C) }
  TShipyardResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TShipyardConstructionControl (instance size 8, VMT 557C750C) }
  TShipyardConstructionControl = class(TStructureConstructionControl)
  public
    procedure GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ID; override;
    procedure ValidateLocation(A1: Integer; A2: Integer); override;
    procedure StructureResource(A1: Integer; A2: Integer); override;
  end;

procedure RegisterShipyard;  { draft }

implementation

class function TShipyard.ClassID: Integer;
begin Result := 0; end;

procedure TShipyard.GetBaseIncome;
begin end;

procedure TShipyard.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

constructor TShipyardResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TShipyardResource.ResourceEditName: string;
begin Result := ''; end;

class function TShipyardResource.ClassID: Integer;
begin Result := 0; end;

function TShipyardResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TShipyardConstructionControl.ID;
begin end;

procedure TShipyardConstructionControl.StructureResource(A1: Integer; A2: Integer);
begin end;

procedure TShipyardConstructionControl.GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TShipyardConstructionControl.ValidateLocation(A1: Integer; A2: Integer);
begin end;

procedure RegisterShipyard;
begin end;


initialization
finalization

end.
