unit HSEdMod;

{ The HSEdMod unit of HSEPack.dpl: the data module of the map editor, with the editor's images
  (HSEditIL) and the brush sprites (HSBrushes: THSLibrary of the HSLib unit) that THSMEdit puts
  under the mouse. AoWEd.exe creates HSEditModule with Application.CreateForm and sets
  HSEditFont from its font module. The components are plain published fields (no DFM is linked
  here). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ImageLib, HSEngine,
  HSLib;

type
  { HSEdMod.THSEditModule (instance size 84): +$44 the components, +$4C HSEditFont (set and used
    as a font by AoWEd.exe), +$50 FHSEngine. }
  THSEditModule = class(TDataModule)
    HSEditIL: TImageLibrary;
    HSBrushes: THSLibrary;
  public
    HSEditFont: TImageLibraryFont;
  private
    FHSEngine: THexagonSpriteEngine;
  public
    procedure SetHSEngine(Value: THexagonSpriteEngine);
    property HSEngine: THexagonSpriteEngine read FHSEngine write SetHSEngine;
  end;

var
  HSEditModule: THSEditModule;

implementation

procedure THSEditModule.SetHSEngine(Value: THexagonSpriteEngine);
begin
  FHSEngine := Value;
  HSBrushes.Engine := Value;
end;

end.
