unit EAoWMO;

{ EAoWMO editor routines recovered from AoWEd.exe. Remaining stubs are marked draft. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWMapEF;

type
  TAoWMapObjEditForm = class;


  { TAoWMapObjEditForm (instance size 528, VMT 00417EC4; $20C FMapObject) }
  TAoWMapObjEditForm = class(TAoWMapEditForm)
  public
    published
    MainPageControl: TPageControl; { +0204 }
    GeneralSheet: TTabSheet; { +0208 }
    public
    FMapObject: TMapObject; { $20C; 0041C745 }
    { conflict: FMapObject: THexagonSprite; }
    procedure vmt84; override;
    procedure vmt8C; override;
    constructor vmt90(Obj: TEObject; Done: TEditDoneEvent); override;
  end;


implementation

constructor TAoWMapObjEditForm.vmt90(Obj: TEObject; Done: TEditDoneEvent);
begin
  if not (Obj is THexagonSprite) then raise Exception.Create('EditObject needs to be a THexagonSprite descendant');
  FMapObject := TMapObject(Obj);
  inherited vmt90(Obj, Done);
end;


procedure TAoWMapObjEditForm.vmt84;
begin
  FMapObject.Deactivate;
  inherited vmt84;
  FMapObject.Activate;
end;


procedure TAoWMapObjEditForm.vmt8C;
begin
  inherited vmt8C;
end;



end.
