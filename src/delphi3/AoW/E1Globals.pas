unit E1Globals;

{ Executable globals referenced by E1 handlers; the original units access them indirectly. }
interface

uses aowMapEvents, AOWPyreScrn, AoWTitleScene, AoWIntroScene, AoWProgressDialog, AoWSelFactionWin, AoWWorldMap, AoWRelations, AoWResultsWin, AoWPWindows;

var
  MapEvents: TMapEvents absolute aowMapEvents.MapEvents; { $45B280; 0044ED77 }
  PyreScreen: TPyreScreen absolute AOWPyreScrn.PyreScreen; { $45B154; 0042945C }
  TitleScene: TTitleScene;
  IntroScene: TIntroScene;
  ProgressDialog: TProgressDialog;
  SelFactionWin: TSelFactionWin absolute AoWSelFactionWin.SelFactionWin;
  WorldMap: TWorldMap;
  RelWindow: TRelWindow;
  PopupWindows: TPopupWindows;
  ExitState: Byte; { $45B004 }

implementation
end.
