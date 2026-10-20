program matchtest;

{ Host program for the byte-matching of VideoP.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -U..\Gfxepack -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  GFXE,
  VFW in 'VFW.pas',
  Video in 'Video.pas';

var
  VP: TVideoPlayer;
  SD: TSurfaceDesc;
begin
  Writeln(InitVFW, ReleaseVFW);
  VP := TVideoPlayer.Create(nil);
  VP.Initialize;
  VP.Release;
  VP.Clear;
  Writeln(VP.GetSoundLoaded, VP.GetVideoLoaded);
  VP.CloseDecompressor;
  Writeln(VP.SetupSound, VP.StreamSound);
  VP.ResetSoundStream;
  VP.StopSoundStream;
  Writeln(VP.SetupVideo, VP.RenderVideoFrame(0), VP.OptimizeOutputPFID(0), VP.Open('x'));
  VP.Close;
  Writeln(VP.ShowFrame(0, 0, 0, SD), VP.Show(0, 0, SD));
  Writeln(VP.GetPosition, VP.GetEndPosition);
  VP.SetPosition(0);
  Writeln(VP.Play, VP.Stop, VP.Pause, VP.Resume, VP.Update);
  VP.Free;
  Register;
end.
