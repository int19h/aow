unit EAoWMO;

{ Draft declarations of EAoWMO, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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
begin end;

procedure TAoWMapObjEditForm.vmt84;
begin end;

procedure TAoWMapObjEditForm.vmt8C;
begin end;


end.
