unit Pad;

{ Draft declarations of Pad, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TPad = class;
  TPadResource = class;


  { TPad (instance size 32, VMT 557FE6C8) }
  TPad = class(TFixedILTerrainMO)
  public
    F_Pad_1C: array[0..3] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt; override;
  end;

  { TPadResource (instance size 72, VMT 557FE864) }
  TPadResource = class(TFixedILTerrainMOR)
  public
    F_PadResource_44: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Editor: TClass; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure ActivateMsg;  { draft }
  end;

procedure RegisterPad;  { draft }

implementation

constructor TPad.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPad.ClassID: Integer;
begin Result := 0; end;

function TPad.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

function TPad.ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin Result := 0; end;

constructor TPadResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPadResource.Destroy;
begin end;

class function TPadResource.ClassID: Integer;
begin Result := 0; end;

class function TPadResource.ResourceEditName: string;
begin Result := ''; end;

function TPadResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TPadResource.ActivateMsg;
begin end;

procedure TPadResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

function TPadResource.Editor: TClass;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure RegisterPad;
begin end;


initialization
finalization

end.
