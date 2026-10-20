unit UnHolyG;

{ Draft declarations of UnHolyG, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, GlobalTargetSpells;

type
  TUnHolyGround = class;
  TUnHolyGroundResource = class;
  TUnholyGroundSpellTE = class;
  TUnholyGroundSpell = class;


  { TUnHolyGround (instance size 32, VMT 557C8B10) }
  TUnHolyGround = class(TILTerrainMO)
  public
    F_UnHolyGround_1C: array[0..0] of Byte;
    F_UnHolyGround_1D: Byte;
    F_UnHolyGround_1E: Byte;
    F_UnHolyGround_1F: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure TriggerArmyDamage(A1: Integer);  { draft }
    procedure ArmyPlaced;  { draft }
    procedure RestoreTerrain;  { draft }
    procedure NewTurn(A1: Integer);  { draft }
    procedure CanDoDamage(A1: Integer);  { draft }
    procedure ShowSummonAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure NewFrameSummonAnimation(A1: Integer; A2: Integer);  { draft }
  end;

  { TUnHolyGroundResource (instance size 68, VMT 557C8CC0) }
  TUnHolyGroundResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TUnholyGroundSpellTE (instance size 36, VMT 557C8DC0) }
  TUnholyGroundSpellTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: Integer; A2: Integer): Boolean; override;
    procedure CreateUnholyGround(A1: Integer);  { draft }
  end;

  { TUnholyGroundSpell (instance size 60, VMT 557C8EA4) }
  TUnholyGroundSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    function TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: Integer): Boolean; override;
    function ValidTargetMapF(A1: Integer): Boolean; override;
  end;

procedure RegisterUnHolyGround(A1: Integer);  { draft }
procedure UnRegisterUnholyGround(A1: Integer);  { draft }

implementation

class function TUnHolyGround.ClassID: Integer;
begin Result := 0; end;

procedure TUnHolyGround.TriggerArmyDamage(A1: Integer);
begin end;

procedure TUnHolyGround.ArmyPlaced;
begin end;

procedure TUnHolyGround.RestoreTerrain;
begin end;

procedure TUnHolyGround.NewTurn(A1: Integer);
begin end;

procedure TUnHolyGround.CanDoDamage(A1: Integer);
begin end;

procedure TUnHolyGround.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

function TUnHolyGround.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TUnHolyGround.RemoveFromMap;
begin end;

procedure TUnHolyGround.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TUnHolyGround.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TUnHolyGround.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TUnHolyGround.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TUnHolyGround.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TUnHolyGround.ShowSummonAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnHolyGround.NewFrameSummonAnimation(A1: Integer; A2: Integer);
begin end;

class function TUnHolyGroundResource.ResourceEditName: string;
begin Result := ''; end;

class function TUnHolyGroundResource.ClassID: Integer;
begin Result := 0; end;

function TUnHolyGroundResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TUnholyGroundSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TUnholyGroundSpellTE.CreateUnholyGround(A1: Integer);
begin end;

function TUnholyGroundSpellTE.Process(A1: Integer; A2: Integer): Boolean;
begin Result := False; end;

constructor TUnholyGroundSpell.Create(AOwner: Engine.TECustomNode);
begin end;

function TUnholyGroundSpell.ValidTargetMapF(A1: Integer): Boolean;
begin Result := False; end;

function TUnholyGroundSpell.ValidTargetSelectionMapF(A1: Integer): Boolean;
begin Result := False; end;

procedure TUnholyGroundSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

function TUnholyGroundSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Boolean;
begin Result := False; end;

procedure RegisterUnHolyGround(A1: Integer);
begin end;

procedure UnRegisterUnholyGround(A1: Integer);
begin end;


initialization
finalization

end.
