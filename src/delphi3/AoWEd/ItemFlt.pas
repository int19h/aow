unit ItemFlt;

{ ItemFlt editor routines recovered from AoWEd.exe. Remaining stubs are marked draft. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemCtrl, AoWE;

type
  TItemFloater = class;


  { TItemFloater (instance size 484, VMT 00413C54) }
  TItemFloater = class(TForm)
  public
    published
    ItemControlGrid: TItemControlGrid; { +01DC }
    Translator: TIvTranslator; { +01E0 }
    public
    published procedure FormShow; public
    published procedure FormHide; public
    published procedure ItemControlGridDblClick; public
  end;


var ItemFloater: TItemFloater; { AoWEd 00415D8C }
implementation

uses EItem;

procedure TItemFloater.FormShow;
begin
  ItemControlGrid.SetAoWHSMap(AoWHSMap);
end;


procedure TItemFloater.FormHide;
begin
  ItemControlGrid.SetAoWHSMap(nil);
end;


procedure TItemFloater.ItemControlGridDblClick;
var Item: TItem; Dlg: TItemEditForm;
begin
  Item := ItemControlGrid.GetSelectedItem;
  if Item <> nil then
  begin
    Dlg := TItemEditForm.Create(Application);
    if Item.GetLibraryItem then Dlg.EditLibraryItem(Item) else Dlg.EditItem(Item);
    Dlg.Free;
  end;
end;



end.
