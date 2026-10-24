program matchtest;

{ Host program for the byte-matching of Dcpack.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -Q -U..\Gfxepack -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; compare from the repository root:
    python tools/match.py --quiet --units DisplayC --alias src/delphi3/Dcpack/match-aliases.json
      <outdir>/matchtest.exe <outdir>/matchtest.map "D:/Games/GOG/Age of Wonders/Dcpack.dpl"
      data/signatures/Dcpack.dpl.json TMatrix TAbstractDC TDisplayCtrl TDDrawFSWinControl
      TCustomDisplay TDisplay TUpdateFrameThread TDisplayGDISurface TWindowsDC TWindows08DC
      TWindows16DC TWindows24DC TWindows32DC TDDrawDCSurface TDDrawDC TDDrawFullScrDC
      TDDrawFullScr16DC TDDrawFullScr24DC TDDrawFullScr32DC
  (TWindows08DIBSurface, declared in the implementation, is compared through the aliases.) }

{$APPTYPE CONSOLE}

uses
  Windows,
  Messages,
  Classes,
  Controls,
  GFXE,
  DisplayC in 'DisplayC.pas';

var
  M: TMatrix;
  CD: TCustomDisplay;
  D: TDisplay;
  W08: TWindows08DC;
  W16: TWindows16DC;
  W24: TWindows24DC;
  W32: TWindows32DC;
  F16: TDDrawFullScr16DC;
  F24: TDDrawFullScr24DC;
  F32: TDDrawFullScr32DC;
  FS: TDDrawFullScrDC;
  DDC: TDDrawDC;
  DC: TDisplayCtrl;
  GS: TDisplayGDISurface;
  DS: TDDrawDCSurface;
  T: TUpdateFrameThread;
  FW: TDDrawFSWinControl;
  Msg: TMessage;
  I, J: Integer;
begin
  M := TMatrix.Create(1, 1);
  Writeln(M.GetVal(0, 0));
  M.SetVal(0, 0, 0);
  M.Free;
  D := TDisplay.Create(nil);
  CD := D;
  CD.Cursor := CD.Cursor;
  D.BufferingScheme := bsDouble;
  D.UpdateFrameMode := umSynchrone;
  D.BackSurfaceWidth := 1;
  D.BackSurfaceHeight := 1;
  Writeln(Integer(CD.GetMouseAboveSurface), CD.SupportDC(nil), CD.ActivateDC(nil), CD.DeactivateDC);
  CD.Hide;
  CD.Show;
  D.Free;
  W08 := TWindows08DC.Create(nil);
  W08.CreateHPalette;
  W08.ReleaseHPalette;
  W08.UpdatePalette;
  W08.Free;
  W16 := TWindows16DC.Create(nil);
  W16.PixelFormat := pf555;
  W16.Free;
  W24 := TWindows24DC.Create(nil);
  W24.Free;
  W32 := TWindows32DC.Create(nil);
  W32.Free;
  F16 := TDDrawFullScr16DC.Create(nil);
  F16.Free;
  F24 := TDDrawFullScr24DC.Create(nil);
  F24.Free;
  F32 := TDDrawFullScr32DC.Create(nil);
  FS := F32;
  Writeln(Integer(FS.MainWindowHook(Msg)), FS.SwitchResolution(1, 1), FS.SetDisplayMode(1, 1, 1));
  FS.HookMainWindow;
  FS.UnHookMainWindow;
  FS.HideApplicationForms;
  FS.ShowApplicationForms;
  DDC := FS;
  DDC.SurfaceLost(nil);
  Writeln(DDC.VerifyLostSurfaces);
  DC := DDC;
  DC.RealizePalet;
  DC.InvWndwithValue(0, 0, 1, 1, 1);
  Writeln(DC.GetCurrentFrameRate);
  F32.Free;
  GS := TDisplayGDISurface.Create(nil);
  GS.Free;
  DS := TDDrawDCSurface.Create;
  Writeln(DS.SetDDSurface(nil, []));
  DS.Free;
  T := TUpdateFrameThread.Create(nil);
  T.Free;
  FW := TDDrawFSWinControl.Create(nil);
  FW.Free;
  I := 0;
  J := I;
  Writeln(I, J);
  Register;
end.
