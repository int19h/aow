program matchtest;

{ Host program for the byte-matching of AOWTools.dpl: it references every class and every
  non-virtual method so that the linker keeps them; it is linked, never run. Build from this
  directory with the original compiler into a directory with a short path (DCC32 crashes on
  long paths):
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -Q "-U..\AoWEPACK;..\HSEPack;..;..\Gfxepack;..\Ilpack;..\Dcpack;..\SoundP;..\Network;..\aowFXpck;..\aowInt;..\Localize"
      -O.. -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  AOWTools in 'AOWTools.pas',
  AoWArnoLine in 'AoWArnoLine.pas',
  AoWBookWindow in 'AoWBookWindow.pas',
  AoWLenLine in 'AoWLenLine.pas',
  AowUserWindow in 'AowUserWindow.pas',
  Scanner in 'Scanner.pas',
  StartMenu in 'StartMenu.pas',
  TurnButton in 'TurnButton.pas';

var
  C: TClass;
  P: Pointer;

procedure Use(C: TClass; P: Pointer);
begin
  Writeln(Integer(C), Integer(P));
end;

begin
  Use(AoWArnoLine.TAoWArnoLine, nil);
  Use(AoWBookWindow.TAoWBookWindow, nil);
  Use(AoWLenLine.TAoWLenLine, nil);
  Use(AowUserWindow.TAoWUserWindow, nil);
  Use(Scanner.TScanner, nil);
  Use(StartMenu.TStartMenu, nil);
  Use(TurnButton.TAOWTurnButton, nil);
  Use(nil, @AOWTools.GetPackageInfoTable);
  Use(nil, @AOWTools.PackageLoad);
  Use(nil, @AOWTools.PackageUnload);
  Use(nil, @AoWArnoLine.TAoWArnoLine.SetITop);
  Use(nil, @AoWArnoLine.TAoWArnoLine.SetIMiddle);
  Use(nil, @AoWArnoLine.TAoWArnoLine.SetIBottom);
  Use(nil, @AoWArnoLine.Register);
  Use(nil, @AoWBookWindow.TAoWBookWindow.StartAnim);
  Use(nil, @AoWBookWindow.Register);
  Use(nil, @AoWLenLine.Register);
  Use(nil, @AowUserWindow.Register);
  Use(nil, @Scanner.TScanner.SetILFIndex);
  Use(nil, @Scanner.TScanner.SetObjIL);
  Use(nil, @Scanner.TScanner.SetArmies);
  Use(nil, @Scanner.TScanner.SetBuildings);
  Use(nil, @Scanner.TScanner.SetNaturals);
  Use(nil, @Scanner.TScanner.SetLevel);
  Use(nil, @Scanner.TScanner.SetMapWidth);
  Use(nil, @Scanner.TScanner.SetMapHeight);
  Use(nil, @Scanner.TScanner.GetTerrain);
  Use(nil, @Scanner.TScanner.SetTerrain);
  Use(nil, @Scanner.TScanner.GetOverlay);
  Use(nil, @Scanner.TScanner.SetOverlay);
  Use(nil, @Scanner.TScanner.GetExplored);
  Use(nil, @Scanner.TScanner.SetExplored);
  Use(nil, @Scanner.TScanner.GetObject);
  Use(nil, @Scanner.TScanner.GetObjectSize);
  Use(nil, @Scanner.TScanner.SetObjectSize);
  Use(nil, @Scanner.TScanner.SetImgLib);
  Use(nil, @Scanner.TScanner.SetHimgLib);
  Use(nil, @Scanner.TScanner.SetFogimgLib);
  Use(nil, @Scanner.TScanner.SetSteps);
  Use(nil, @Scanner.TScanner.SetObDrawn);
  Use(nil, @Scanner.TScanner.SetTLeft);
  Use(nil, @Scanner.TScanner.SetTTop);
  Use(nil, @Scanner.TScanner.SetTWidth);
  Use(nil, @Scanner.TScanner.SetTHeight);
  Use(nil, @Scanner.TScanner.SetMap);
  Use(nil, @Scanner.TScanner.DrawMap);
  Use(nil, @Scanner.TScanner.DrawObjects);
  Use(nil, @Scanner.Register);
  Use(nil, @StartMenu.Register);
  Use(nil, @TurnButton.Register);
  { per-package host additions: one include line per package (hosts\Pkg.inc), nothing else here }
end.
