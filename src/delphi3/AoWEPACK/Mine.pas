unit Mine;

{ Draft declarations of Mine, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TMine = class;
  TMineResource = class;


  { TMine (instance size 68, VMT 557B4020) }
  TMine = class(TPlayerStructure)
  public
    F_Mine_3C: Byte;
    F_Mine_3D: array[0..6] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure SetRazed(A1: Integer); override;
    procedure GetRazed; override;
    procedure GetCurrentActivityText(A1: Integer); override;
    procedure UpdateAITarget(A1: Integer; A2: Integer); override;
    procedure SetPlayer(A1: Integer; A2: Integer); override;
    procedure GetIncome(A1: Integer; A2: Integer); override;
    procedure GetCombatEventText(A1: Integer; A2: Integer); override;
  end;

  { TMineResource (instance size 116, VMT 557B42A8) }
  TMineResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure MineIncome(A1: Byte);  { draft }
procedure RegisterMine;  { draft }

implementation

constructor TMine.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMine.Destroy;
begin end;

class function TMine.ClassID: Integer;
begin Result := 0; end;

procedure TMine.GetIncome(A1: Integer; A2: Integer);
begin end;

procedure TMine.GetCurrentActivityText(A1: Integer);
begin end;

procedure TMine.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

procedure TMine.SetPlayer(A1: Integer; A2: Integer);
begin end;

procedure TMine.Activate;
begin end;

procedure TMine.Deactivate;
begin end;

procedure TMine.GetRazed;
begin end;

procedure TMine.SetRazed(A1: Integer);
begin end;

procedure TMine.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TMine.GetCombatEventText(A1: Integer; A2: Integer);
begin end;

constructor TMineResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TMineResource.ResourceEditName: string;
begin Result := ''; end;

class function TMineResource.ClassID: Integer;
begin Result := 0; end;

function TMineResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure MineIncome(A1: Byte);
begin end;

procedure RegisterMine;
begin end;


initialization
finalization

end.
