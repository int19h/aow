program matchtest;

{ Host program for the byte-matching of SoundP.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler from
  this directory (Engine from src\delphi3, ImageLib from Ilpack, GFXE from Gfxepack):
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -Q "-U..;..\Ilpack;..\Gfxepack" -O..
      -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  Forms,
  Engine,
  SpinEdit in 'SpinEdit.pas',
  Galaxy in 'Galaxy.pas',
  Sound in 'Sound.pas',
  GalSndS in 'GalSndS.pas',
  SFXEdDlg in 'SFXEdDlg.pas',
  DSound in 'DSound.pas';

var
  Settings: TSoundSettings;
  M: TSFXManager;
  CB: TSFXManagerComboBox;
  LB: TSFXManagerListBox;
  SL: TSonglist;
  SP: TSongPlayer;
  X: TSFX;
  Q: TSFXSequence;
  L: TSFXLibrary;
  Dlg: TSFXLibraryEditDlg;
  CallBack: TSampleCallBack;
  K: Word;
  B: Boolean;
begin
  Writeln(GalaxyActive, InitializeGalaxy, ReleaseGalaxy);
  Writeln(DSSPEAKER_COMBINED(1, 2), DSSPEAKER_CONFIG(3), DSSPEAKER_GEOMETRY(4));
  TObject(TGalaxySampleData.Create('x')).Free;
  TObject(TGalaxySample.Create(nil)).Free;
  TGalaxySoundSystem.Create.Free;
  M := TSFXManager.Create(nil);
  M.Clear;
  M.ExecutePathSearch('x');
  CB := TSFXManagerComboBox.Create(nil);
  CB.SFXManager := M;
  CB.SubDirectory := 'x';
  CB.SFXName := CB.SFXName;
  CB.GenerateItems;
  LB := TSFXManagerListBox.Create(nil);
  LB.SFXManager := M;
  LB.SubDirectory := 'x';
  LB.SFXName := LB.SFXName;
  LB.GenerateItems;
  SL := TSonglist.Create(nil);
  SL.Search('x', 'y');
  SL.Songs := nil;
  SP := TSongPlayer.Create;
  SP.Update;
  SP.Songs := nil;
  Writeln(SP.PlayEx(0, 0, 0), SP.Play(0), SP.Stop(True), SP.Pause(True), SP.Resume);
  X := TSFX.Create(nil);
  X.Play;
  X.PlayEx(0, False, 0, spCenter, CallBack);
  Q := TSFXSequence.Create(nil);
  Q.GetSFX(0);
  Q.Play;
  Q.PlayEx(0, False, 0, spCenter, CallBack);
  L := TSFXLibrary.Create(nil);
  L.GetSFXSequence(0);
  L.Play(0);
  L.PlayEx(0, 0, False, 0, spCenter, CallBack);
  L.Find(0);
  Writeln(L.DoubleID);
  LockSampleData('x');
  UnlockSampleData('x');
  CreateSampleData('x');
  CreateSampleDataEx(nil, nil, 0);
  CreateSample(nil);
  PlaySample('x');
  PlaySampleEx('x', 0, False, 0, spCenter, CallBack);
  Writeln(SamplesActive, SamplesLoaded);
  RegisterSoundSystem(TGalaxySoundSystem);
  Writeln(InitializeSoundSystem('x', Settings));
  ReleaseSoundSystem;
  Writeln(Byte(SoundSystemStatus));
  SetMusicVolume(0);
  FadeMusicVolume(0, 0);
  Writeln(GetMusicVolume);
  SetSFXVolume(0);
  Writeln(GetSFXVolume, GetMusicEnabled, SetMusicEnabled(True), GetSFXEnabled,
    SetSFXEnabled(True));
  Settings := GetSoundSettings;
  Writeln(SetSoundSettings(Settings));
  RestoreSongStatus(BackupSongStatus);
  Writeln(GetSongName('x'), PlayingSongFileName, PlaySong('x'), PlaySongEx('x', 0, 0, False),
    StopSong);
  ProcessSound;
  RegisterSoundEngineClasses(nil);
  UnregisterSoundEngineClasses(nil);
  Register;
  Dlg := TSFXLibraryEditDlg.Create(nil);
  Dlg.Edit(nil, L, M);
  Dlg.FormCreate(nil);
  Dlg.PlaySFXClick(nil);
  Dlg.PlaySFXFileClick(nil);
  Dlg.PlaySeqClick(nil);
  Dlg.AddSeqClick(nil);
  Dlg.DeleteSeqClick(nil);
  Dlg.AddSFXClick(nil);
  Dlg.DeleteSFXClick(nil);
  Dlg.SequenceListSelectCell(nil, 0, 0, B);
  Dlg.SFXIDEditUpdate(nil);
  Dlg.OKBtnClick(nil);
  Dlg.SequenceListKeyDown(nil, K, []);
end.
