program matchtest;

{ Host program for the byte-matching of Adcpack.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -U..\Gfxepack -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  ZoomControl in 'ZoomControl.pas',
  AdvancedDisplay in 'AdvancedDisplay.pas';

var
  ZC: TZoomControl;
  AD: TAdvancedDisplay;
begin
  ZC := TZoomControl.Create(nil);
  ZC.HideApplicationForms;
  ZC.ShowApplicationForms;
  ZC.MaximizeZoom;
  ZC.NormalizeZoom;
  ZC.Free;
  AD := TAdvancedDisplay.Create(nil);
  AD.HideApplicationForms;
  AD.ShowApplicationForms;
  AD.SetDisplayMode(dmFullScreen);
  AD.SwapDisplayMode;
  AD.Free;
  ZoomControl.Register;
  AdvancedDisplay.Register;
end.
