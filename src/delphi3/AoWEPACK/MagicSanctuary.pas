unit MagicSanctuary;

{ Draft declarations of MagicSanctuary, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TMagicSanctuaryOverlayHS = class;
  TMagicSanctuary = class;
  TMagicSanctuaryResource = class;


  { TMagicSanctuaryOverlayHS (instance size 20, VMT 557D404C) }
  TMagicSanctuaryOverlayHS = class(TSingleHS)
  public
    F_MagicSanctuaryOverlayHS_0C: array[0..7] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure FadeUp;  { draft }
  end;

  { TMagicSanctuary (instance size 52, VMT 557D41F4) }
  TMagicSanctuary = class(TStructure)
  public
    F_MagicSanctuary_30: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    procedure ArmyPlaced(A1: Integer); override;
  end;

  { TMagicSanctuaryResource (instance size 100, VMT 557D4464) }
  TMagicSanctuaryResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMagicSanctuary;  { draft }

implementation

constructor TMagicSanctuaryOverlayHS.Create(AOwner: Engine.TECustomNode);
begin end;

function TMagicSanctuaryOverlayHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TMagicSanctuaryOverlayHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TMagicSanctuaryOverlayHS.FadeUp;
begin end;

constructor TMagicSanctuary.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMagicSanctuary.Destroy;
begin end;

class function TMagicSanctuary.ClassID: Integer;
begin Result := 0; end;

procedure TMagicSanctuary.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

procedure TMagicSanctuary.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TMagicSanctuary.ArmyPlaced(A1: Integer);
begin end;

constructor TMagicSanctuaryResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TMagicSanctuaryResource.ResourceEditName: string;
begin Result := ''; end;

class function TMagicSanctuaryResource.ClassID: Integer;
begin Result := 0; end;

function TMagicSanctuaryResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterMagicSanctuary;
begin end;


initialization
finalization

end.
