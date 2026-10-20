unit PowerNode;

{ Draft declarations of PowerNode, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TPowerNode = class;
  TPowerNodeResource = class;


  { TPowerNode (instance size 68, VMT 557CFFE4) }
  TPowerNode = class(TPlayerStructure)
  public
    F_PowerNode_3C: Byte;
    F_PowerNode_3D: array[0..6] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    function GetCurrentActivityText: string; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    procedure SetPlayer(Player: Shortint); override;
    function GetPower: Integer; override;
    procedure GetCombatEventText(Combat: TCombat; var Text: string); override;
  end;

  { TPowerNodeResource (instance size 116, VMT 557D027C) }
  TPowerNodeResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterPowerNode;  { draft }

implementation

constructor TPowerNode.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPowerNode.Destroy;
begin end;

class function TPowerNode.ClassID: Integer;
begin Result := 0; end;

function TPowerNode.GetPower: Integer;
begin end;

function TPowerNode.GetRazed: Boolean;
begin end;

procedure TPowerNode.SetRazed(Value: Boolean);
begin end;

procedure TPowerNode.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TPowerNode.GetCurrentActivityText: string;
begin end;

procedure TPowerNode.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
begin end;

procedure TPowerNode.SetPlayer(Player: Shortint);
begin end;

procedure TPowerNode.Activate;
begin end;

procedure TPowerNode.Deactivate;
begin end;

procedure TPowerNode.GetCombatEventText(Combat: TCombat; var Text: string);
begin end;

constructor TPowerNodeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPowerNodeResource.ResourceEditName: string;
begin Result := ''; end;

class function TPowerNodeResource.ClassID: Integer;
begin Result := 0; end;

function TPowerNodeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterPowerNode;
begin end;


initialization
finalization

end.
