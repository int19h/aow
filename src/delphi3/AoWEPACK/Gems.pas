unit Gems;

{ Gems of AoWEPACK.dpl: original instance layouts; TGemsResource recovered.
  TGems remains a draft. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TGems = class;
  TGemsResource = class;

  TGemsGenerateMode = (gmUserDefined, gmLow, gmNormal, gmHigh, gmRandom);  { ot=1 }

  { TGems (instance size 36, VMT 557C4D54) }
  TGems = class(TILTerrainMO)
  public
    F_Gems_1C: Integer;
    F_Gems_20: Byte;
    F_Gems_21: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure GenerateGemsAmount;  { draft }
    procedure UpdateAITarget(A1: Integer; A2: Integer);  { draft }
    procedure ArmyEntered(A1: Integer);  { draft }
  end;

  { TGemsResource (instance size 68, VMT 557C4EF0): no additional fields. }
  TGemsResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterGems;  { draft }

implementation

constructor TGems.Create(AOwner: Engine.TECustomNode);
begin end;

class function TGems.ClassID: Integer;
begin Result := 0; end;

procedure TGems.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TGems.GenerateGemsAmount;
begin end;

procedure TGems.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

procedure TGems.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TGems.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TGems.ArmyEntered(A1: Integer);
begin end;

procedure TGems.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

class function TGemsResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@GoldRStr)); end;

class function TGemsResource.ClassID: Integer;
begin Result := $203AF; end;

function TGemsResource.ResourceUserClassID: Integer;
begin Result := $203AE; end;

procedure RegisterGems;
begin end;


initialization
finalization

end.
