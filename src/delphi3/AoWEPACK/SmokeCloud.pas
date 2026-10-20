unit SmokeCloud;

{ Draft declarations of SmokeCloud, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TSmokeCloudEnchantment = class;
  TSmokeCloud = class;
  TSmokeCloudResource = class;


  { TSmokeCloudEnchantment (instance size 40, VMT 5579BF2C) }
  TSmokeCloudEnchantment = class(TGlobalEnchantment)
  public
    F_SmokeCloudEnchantment_24: array[0..3] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); override;
    procedure GetLocation(A1: Integer; A2: Integer); override;
    procedure Deactivate(A1: Byte); override;
    procedure VisibleForPlayer(A1: Integer; A2: Integer); override;
  end;

  { TSmokeCloud (instance size 36, VMT 5579C044) }
  TSmokeCloud = class(TMultiHexMO)
  public
    F_SmokeCloud_14: Byte;
    F_SmokeCloud_15: array[0..2] of Byte;
    F_SmokeCloud_18: Integer;
    F_SmokeCloud_1C: Byte;
    F_SmokeCloud_1D: Byte;
    F_SmokeCloud_1E: array[0..1] of Byte;
    F_SmokeCloud_20: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure UpdateConcealment(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure UpdateVisibleForSeatedPlayer;  { draft }
    procedure ValidMoveDir(A1: Integer);  { draft }
    procedure UpdateCloud;  { draft }
  end;

  { TSmokeCloudResource (instance size 68, VMT 5579C1E0) }
  TSmokeCloudResource = class(TMultiHexMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterSmokeCloud;  { draft }

implementation

constructor TSmokeCloudEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSmokeCloudEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TSmokeCloudEnchantment.GetName(A1: Integer);
begin end;

procedure TSmokeCloudEnchantment.GetLocation(A1: Integer; A2: Integer);
begin end;

procedure TSmokeCloudEnchantment.Deactivate(A1: Byte);
begin end;

procedure TSmokeCloudEnchantment.VisibleForPlayer(A1: Integer; A2: Integer);
begin end;

constructor TSmokeCloud.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSmokeCloud.Destroy;
begin end;

class function TSmokeCloud.ClassID: Integer;
begin Result := 0; end;

function TSmokeCloud.GetShowPriority: Integer;
begin Result := 0; end;

function TSmokeCloud.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TSmokeCloud.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSmokeCloud.UpdateConcealment(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TSmokeCloud.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TSmokeCloud.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TSmokeCloud.UpdateVisibleForSeatedPlayer;
begin end;

function TSmokeCloud.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TSmokeCloud.RemoveFromMap;
begin end;

procedure TSmokeCloud.Activate;
begin end;

procedure TSmokeCloud.Deactivate;
begin end;

procedure TSmokeCloud.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TSmokeCloud.ValidMoveDir(A1: Integer);
begin end;

procedure TSmokeCloud.UpdateCloud;
begin end;

procedure TSmokeCloud.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

class function TSmokeCloudResource.ClassID: Integer;
begin Result := 0; end;

class function TSmokeCloudResource.ResourceEditName: string;
begin Result := ''; end;

function TSmokeCloudResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterSmokeCloud;
begin end;


initialization
finalization

end.
