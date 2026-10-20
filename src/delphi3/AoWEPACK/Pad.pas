unit Pad;

{ Pad of AoWEPACK.dpl: recovered bodies and original instance layouts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TPad = class;
  TPadResource = class;


  { TPad (instance size 32, VMT 557FE6C8): $1C FPadActive. }
  TPad = class(TFixedILTerrainMO)
  public
    FPadActive: Boolean; { $1C }
    FReserved1D: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt; override;
  end;

  { TPadResource (instance size 72, VMT 557FE864): $44 FPadSize. }
  TPadResource = class(TFixedILTerrainMOR)
  public
    FPadSize: Byte; { $44 }
    FReserved45: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Editor: TClass; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure ActivateMsg;
  end;

procedure RegisterPad(AEngine: TEngine);

implementation

constructor TPad.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPadActive := True;
end;

class function TPad.ClassID: Integer;
begin Result := $20106; end;

function TPad.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

function TPad.ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin
  if MapLevel.Lhx <> 0 then Result := 12 else Result := -1;
end;

constructor TPadResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetLevel(10);
end;

destructor TPadResource.Destroy;
begin
  if (Engine <> nil) and not (ssDestroying in THSEngine(Engine).HSSet.Status) then
    TAoWHSSet(THSEngine(Engine).HSSet).FPadControl.UnregisterPadResource(Self, FPadSize);
  inherited Destroy;
end;

class function TPadResource.ClassID: Integer;
begin Result := $20107; end;

class function TPadResource.ResourceEditName: string;
begin Result := 'Pad'; end;

function TPadResource.ResourceUserClassID: Integer;
begin Result := $20106; end;

procedure TPadResource.ActivateMsg;
var
  I: Integer;
begin
  FPadSize := 0;
  for I := 0 to TerrainList.Count - 1 do
    if TerrainList.GetTerrain(I) >= -1 then Inc(FPadSize);
  TAoWHSSet(THSEngine(Engine).HSSet).FPadControl.RegisterPadResource(Self, FPadSize);
end;

procedure TPadResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then ActivateMsg;
end;

function TPadResource.Editor: TClass;
begin
  Result := Engine.Editors.FindEditor($20107);
  if Result = nil then Result := inherited Editor;
end;

procedure RegisterPad(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TPad, TPadResource]);
end;


initialization
finalization

end.
