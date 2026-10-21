unit E3Globals;

{ Executable module references used by E3. }
interface
uses aowIntGfxMod, FontMod, AoWUnit, AoWItemBanner;
var
  IntGfxMod: TIntGfxMod;
  FontModule: TFontModule;
  MainForm: TMainForm;
  ItemBanner: TItemBanner absolute AoWItemBanner.ItemBanner; { $45B05C }
  ItemID: Integer absolute AoWItemBanner.ItemID; { $45B060 }
implementation
end.
