unit E1Globals;

{ Executable globals referenced by E1 handlers; the original units access them indirectly. }
interface

uses aowMapEvents, AOWPyreScrn, AoWTitleScene, AoWIntroScene, AoWProgressDialog, AoWSelFactionWin, AoWWorldMap, AoWRelations, AoWResultsWin, AoWPWindows;

var
  MapEvents: TMapEvents;
  PyreScreen: TPyreScreen;
  TitleScene: TTitleScene;
  IntroScene: TIntroScene;
  ProgressDialog: TProgressDialog;
  SelFactionWin: TSelFactionWin;
  WorldMap: TWorldMap;
  RelWindow: TRelWindow;
  PopupWindows: TPopupWindows;
  ExitState: Byte; { $45B004 }

implementation
end.
