unit HolyG;

{ Draft declarations of HolyG, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, GlobalTargetSpells;

type
  THolyGround = class;
  THolyGroundResource = class;
  THolyGroundSpellTE = class;
  THolyGroundSpell = class;


  { THolyGround (instance size 32, VMT 557C79A0) }
  THolyGround = class(TILTerrainMO)
  public
    F_HolyGround_1C: array[0..0] of Byte;
    F_HolyGround_1D: Byte;
    F_HolyGround_1E: Byte;
    F_HolyGround_1F: Byte;
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

  { THolyGroundResource (instance size 68, VMT 557C7B48) }
  THolyGroundResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { THolyGroundSpellTE (instance size 36, VMT 557C7C40) }
  THolyGroundSpellTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure CreateHolyGround(A1: Integer);  { draft }
  end;

  { THolyGroundSpell (instance size 60, VMT 557C7D1C) }
  THolyGroundSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    function TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: Integer): Boolean; override;
    function ValidTargetMapF(A1: Integer): Boolean; override;
  end;

procedure RegisterHolyGround(A1: Integer);  { draft }
procedure UnRegisterHolyGround(A1: Integer);  { draft }

implementation

class function THolyGround.ClassID: Integer;
begin Result := 0; end;

procedure THolyGround.TriggerArmyDamage(A1: Integer);
begin end;

procedure THolyGround.ArmyPlaced;
begin end;

procedure THolyGround.RestoreTerrain;
begin end;

procedure THolyGround.NewTurn(A1: Integer);
begin end;

procedure THolyGround.CanDoDamage(A1: Integer);
begin end;

procedure THolyGround.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

function THolyGround.PlaceOnMap: Boolean;
begin Result := False; end;

procedure THolyGround.RemoveFromMap;
begin end;

procedure THolyGround.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function THolyGround.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure THolyGround.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure THolyGround.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure THolyGround.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure THolyGround.ShowSummonAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THolyGround.NewFrameSummonAnimation(A1: Integer; A2: Integer);
begin end;

class function THolyGroundResource.ResourceEditName: string;
begin Result := ''; end;

class function THolyGroundResource.ClassID: Integer;
begin Result := 0; end;

function THolyGroundResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function THolyGroundSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure THolyGroundSpellTE.CreateHolyGround(A1: Integer);
begin end;

function THolyGroundSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin Result := False; end;

constructor THolyGroundSpell.Create(AOwner: Engine.TECustomNode);
begin end;

function THolyGroundSpell.ValidTargetMapF(A1: Integer): Boolean;
begin Result := False; end;

function THolyGroundSpell.ValidTargetSelectionMapF(A1: Integer): Boolean;
begin Result := False; end;

procedure THolyGroundSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

function THolyGroundSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Boolean;
begin Result := False; end;

procedure RegisterHolyGround(A1: Integer);
begin end;

procedure UnRegisterHolyGround(A1: Integer);
begin end;


initialization
finalization

end.
