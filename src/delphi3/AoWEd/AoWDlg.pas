unit AoWDlg;

{ Draft declarations of AoWDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWDialog = class;


  { TAoWDialog (instance size 480, VMT 0040D824) }
  TAoWDialog = class(TForm)
  public
    F_AoWDialog_1DC: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure FormShow;  { draft }
  end;


implementation

constructor TAoWDialog.Create(AOwner: Classes.TComponent);
begin end;

destructor TAoWDialog.Destroy;
begin end;

procedure TAoWDialog.FormShow;
begin end;


end.
