unit E1Globals;

{ Executable globals referenced by E1 handlers; the original units access them indirectly. }
interface

uses aowMapEvents, AOWPyreScrn, AoWTitleScene, AoWIntroScene, AoWProgressDialog, AoWSelFactionWin, AoWWorldMap, AoWRelations, AoWResultsWin, AoWPWindows, E2Globals, AoWUnit;

var
  MapEvents: TMapEvents absolute aowMapEvents.MapEvents; { $45B280; 0044ED77 }
  PyreScreen: TPyreScreen absolute AOWPyreScrn.PyreScreen; { $45B154; 0042945C }
  TitleScene: TTitleScene absolute E2Globals.TitleScene; { $45B0E8 }
  IntroScene: TIntroScene;
  ProgressDialog: TProgressDialog absolute E2Globals.ProgressDialog; { $45B0B8 }
  SelFactionWin: TSelFactionWin absolute AoWSelFactionWin.SelFactionWin;
  WorldMap: TWorldMap absolute AoWWorldMap.WorldMap; { $45B0F8 }
  RelWindow: TRelWindow;
  PopupWindows: TPopupWindows;
  ExitState: Byte absolute AoWUnit.DeferredSetupAction; { $45B2B5; 0041FC14 }

implementation
end.
