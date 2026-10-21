unit AoWArnoLine;

{ Draft declarations of AoWArnoLine, from AOWTools.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWControl;

type
  TAoWArnoLine = class;


  { TAoWArnoLine (instance size 292, VMT 59705830) }
  TAoWArnoLine = class(TAOWControl)
  public
    F_AoWArnoLine_114: array[0..11] of Byte;
    F_AoWArnoLine_120: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure SetITop(A1: Integer);  { draft }
    procedure SetIMiddle(A1: Integer);  { draft }
    procedure SetIBottom(A1: Integer);  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TAoWArnoLine.Create(AOwner: Classes.TComponent);
begin end;

destructor TAoWArnoLine.Destroy;
begin end;

procedure TAoWArnoLine.Validate;
begin end;

procedure TAoWArnoLine.SetITop(A1: Integer);
begin end;

procedure TAoWArnoLine.SetIMiddle(A1: Integer);
begin end;

procedure TAoWArnoLine.SetIBottom(A1: Integer);
begin end;

procedure TAoWArnoLine.SetSize;
begin end;

procedure TAoWArnoLine.Draw(SurfDesc: GFXE.TSurfaceDesc);
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
