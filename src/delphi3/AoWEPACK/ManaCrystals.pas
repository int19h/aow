unit ManaCrystals;

{ Draft declarations of ManaCrystals, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TManaCrystals = class;
  TManaCrystalsResource = class;


  { TManaCrystals (instance size 36, VMT 557B494C) }
  TManaCrystals = class(TILTerrainMO)
  public
    F_ManaCrystals_1C: Integer;
    F_ManaCrystals_20: Byte;
    F_ManaCrystals_21: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure GenerateManaCrystalsAmount;  { draft }
    procedure UpdateAITarget(A1: Integer; A2: Integer);  { draft }
    procedure ArmyEntered(A1: Integer);  { draft }
  end;

  { TManaCrystalsResource (instance size 68, VMT 557B4B00) }
  TManaCrystalsResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterManaCrystals;  { draft }

implementation

constructor TManaCrystals.Create(AOwner: Engine.TECustomNode);
begin end;

class function TManaCrystals.ClassID: Integer;
begin Result := 0; end;

procedure TManaCrystals.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TManaCrystals.GenerateManaCrystalsAmount;
begin end;

procedure TManaCrystals.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

procedure TManaCrystals.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TManaCrystals.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TManaCrystals.ArmyEntered(A1: Integer);
begin end;

procedure TManaCrystals.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

class function TManaCrystalsResource.ResourceEditName: string;
begin Result := ''; end;

class function TManaCrystalsResource.ClassID: Integer;
begin Result := 0; end;

function TManaCrystalsResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterManaCrystals;
begin end;


initialization
finalization

end.
