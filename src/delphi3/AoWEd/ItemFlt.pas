unit ItemFlt;

{ Draft declarations of ItemFlt, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemCtrl;

type
  TItemFloater = class;


  { TItemFloater (instance size 484, VMT 00413C54) }
  TItemFloater = class(TForm)
  public
    published
    ItemControlGrid: TItemControlGrid; { +01DC }
    Translator: TIvTranslator; { +01E0 }
    public
    procedure FormShow;  { draft }
    procedure FormHide;  { draft }
    procedure ItemControlGridDblClick;  { draft }
  end;


var ItemFloater: TItemFloater; { AoWEd 00415D8C }
implementation

procedure TItemFloater.FormShow;
begin end;

procedure TItemFloater.FormHide;
begin end;

procedure TItemFloater.ItemControlGridDblClick;
begin end;


end.
