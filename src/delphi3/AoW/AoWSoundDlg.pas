unit AoWSoundDlg;

{ Draft declarations of AoWSoundDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWButton, AoWCheckBox, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TSoundDlg = class;


  { TSoundDlg (size $12C, VMT 00420E44): $110 sound quality, $114 sound settings ($118 rate, $11C music, $11D DirectSound, $120 window, $124 SFX, $128 voices). }
  TSoundDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    CloseBut: TAOWButton; { +0048 }
    TCeltLL: TAOWImage; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    Title: TAOWLabel; { +0054 }
    SongLB: TAOWListBox; { +0058 }
    SongLbl: TAOWLabel; { +005C }
    Close: TAOWButton; { +0060 }
    PlayListPnl: TAOWPanel; { +0064 }
    SoundTab: TAOWTabPanel; { +0068 }
    PlayLB: TAOWListBox; { +006C }
    AddBtn: TAOWButton; { +0070 }
    RemoveBtn: TAOWButton; { +0074 }
    PlayBtn: TAOWButton; { +0078 }
    PlayLbl: TAOWLabel; { +007C }
    CurrentSongLbl: TAOWLabel; { +0080 }
    TCeltLR: TAOWImage; { +0084 }
    MusicVolLbl: TAOWLabel; { +0088 }
    SFXVolLbl: TAOWLabel; { +008C }
    MainPnl: TAOWPanel; { +0090 }
    SoundLbl: TAOWLabel; { +0094 }
    SettingsPnl: TAOWPanel; { +0098 }
    SFXLbl: TAOWLabel; { +009C }
    SQPnl: TAOWPanel; { +00A0 }
    SQCB1: TAOWCheckBox; { +00A4 }
    SQLBL1: TAOWLabel; { +00A8 }
    SQCB2: TAOWCheckBox; { +00AC }
    SQLBL2: TAOWLabel; { +00B0 }
    SQCB3: TAOWCheckBox; { +00B4 }
    SQLBL3: TAOWLabel; { +00B8 }
    SQCB4: TAOWCheckBox; { +00BC }
    SQLBL4: TAOWLabel; { +00C0 }
    SFXPnl: TAOWPanel; { +00C4 }
    MusicEnabledChk: TAOWCheckBox; { +00C8 }
    SFXLBL2: TAOWLabel; { +00CC }
    SFXEnabledChk: TAOWCheckBox; { +00D0 }
    SFXLBL3: TAOWLabel; { +00D4 }
    TopLine: TAoWFrame; { +00D8 }
    AOWImage4: TAOWImage; { +00DC }
    HarpL: TAOWImage; { +00E0 }
    HarpR: TAOWImage; { +00E4 }
    MusicVolume: TAOWHScrollBar; { +00E8 }
    SFXVolume: TAOWHScrollBar; { +00EC }
    TitleIcon: TAOWImage; { +00F0 }
    SongSB: TAOWVScrollBar; { +00F4 }
    PlaySB: TAOWVScrollBar; { +00F8 }
    DirectSoundEnabledChk: TAOWCheckBox; { +00FC }
    UseDirectSoundLbl: TAOWLabel; { +0100 }
    FolderPnl: TAOWPanel; { +0104 }
    PlayPnl: TAOWPanel; { +0108 }
    Translator: TIvTranslator; { +010C }
    public
    FSoundQuality: Integer; { $110 }
    FSettings: TSoundSettings; { $114..$12B }
    procedure CloseClick;
    procedure MusicVolumeChange;
    procedure SFXVolumeChange;
    procedure RemoveBtnClick(Sender: TObject);
    procedure SoundSetup;
    procedure PlayBtnClick;
    procedure SongChange(Sender: TObject);
    procedure FindFiles;
    procedure SongLBChange;
    procedure AddBtnClick(Sender: TObject);
    procedure SoundDlgWindowCreate;
    procedure SoundDlgWindowDestroy;
    procedure PlayLBChange;
    procedure SQCB1Change(Sender: TObject);
    procedure SQCB2Change(Sender: TObject);
    procedure SQCB3Change(Sender: TObject);
    procedure SQCB4Change(Sender: TObject);
    procedure PlayLBDrawItem(Sender: TObject; const R: TRect; Index: Integer; var SurfDesc: TSurfaceDesc);
    procedure MusicEnabledChkChange(Sender: TObject);
    procedure SFXEnabledChkChange(Sender: TObject);
    procedure DirectSoundEnabledChkChange(Sender: TObject);
    procedure SoundTabChange;
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses AoWWinMan, aowIntGfxMod;

var
  SongFiles: TStringList;

procedure TSoundDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TSoundDlg.MusicVolumeChange;
begin
  SetMusicVolume(MusicVolume.Position);
end;

procedure TSoundDlg.SFXVolumeChange;
begin
  SetSFXVolume(SFXVolume.Position);
end;

procedure TSoundDlg.RemoveBtnClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  SongPlayer.Songs.Delete(PlayLB.Selected);
  if SongPlayer.CurrentIndex = -1 then
    if PlayLB.Selected < SongPlayer.Songs.Count then SongPlayer.Play(PlayLB.Selected)
    else if SongPlayer.Songs.Count <> 0 then SongPlayer.Play(SongPlayer.Songs.Count - 1);
  SoundSetup;
end;

procedure TSoundDlg.SoundSetup;
var
  I: Integer;
begin
  PlayLB.Items.Clear;
  for I := 0 to SongPlayer.SongNames.Count - 1 do PlayLB.Items.Add(SongPlayer.SongNames[I]);
  PlayLB.Selected := SongPlayer.CurrentIndex;
  PlayLB.FSized := False;
  if PlayLB.Selected = -1 then
  begin
    RemoveBtn.Visible := False;
    PlayBtn.Visible := False;
    CurrentSongLbl.Text := '';
  end
  else
  begin
    RemoveBtn.Visible := True;
    PlayBtn.Visible := True;
    CurrentSongLbl.Text := SongPlayer.SongNames[PlayLB.Selected];
  end;
  MainPnl.FDrawn := False;
  PlayListPnl.FDrawn := False;
  MusicEnabledChk.Checked := FSettings.MusicEnabled;
  SFXEnabledChk.Checked := FSettings.SFXEnabled;
  DirectSoundEnabledChk.Checked := FSettings.UseDirectSound;
  SQCB1.Checked := FSoundQuality = 0;
  SQCB2.Checked := FSoundQuality = 1;
  SQCB3.Checked := FSoundQuality = 2;
  SQCB4.Checked := FSoundQuality = 3;
end;

procedure TSoundDlg.PlayBtnClick;
begin
  General.PlayButtonSound(0);
  PlayLB.FDrawn := False;
  SongPlayer.Play(PlayLB.Selected);
end;

procedure TSoundDlg.SongChange(Sender: TObject);
begin
  CurrentSongLbl.Text := SongPlayer.SongNames[SongPlayer.CurrentIndex];
  MainPnl.FDrawn := False;
  PlayLB.FDrawn := False;
end;

procedure TSoundDlg.FindFiles;
var
  Directory: string;
  Search: TSearchRec;
begin
  SongLB.Items.Clear;
  SongFiles.Clear;
  SetCurrentDir(AoWEngine.StartupDirectory + '\Songs');
  Directory := GetCurrentDir;
  if Copy(Directory, Length(Directory), 1) = '\' then Directory := Copy(Directory, 1, Length(Directory) - 1);
  if FindFirst(Directory + '\*.*', faDirectory, Search) = 0 then
    repeat
      if (Search.Name <> '.') and (Search.Name <> '..') then
        if (UpperCase(Copy(Search.Name, Length(Search.Name) - 3, 4)) = '.S3M') or
          (UpperCase(Copy(Search.Name, Length(Search.Name) - 2, 3)) = '.IT') then
        begin
          SongFiles.Add('Songs\' + Search.Name);
          SongLB.Items.Add(GetSongName('Songs\' + Search.Name));
        end;
    until FindNext(Search) <> 0;
  FindClose(Search);
  SortStringsAscending(SongLB.Items, [SongFiles]);
  SongLB.Selected := -1;
  SongLB.ListOffset := 0;
  SongSB.Position := 0;
end;

procedure TSoundDlg.SongLBChange;
begin
  if SongLB.Selected > -1 then AddBtn.Visible := True;
end;

procedure TSoundDlg.AddBtnClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  SongPlayer.Songs.Add(SongFiles[SongLB.Selected]);
  SoundSetup;
end;

procedure TSoundDlg.SoundDlgWindowCreate;
begin
  SongFiles := TStringList.Create;
end;

procedure TSoundDlg.SoundDlgWindowDestroy;
begin
  SongFiles.Free;
end;

procedure TSoundDlg.PlayLBChange;
begin
  if PlayLB.Selected > -1 then
  begin
    RemoveBtn.Visible := True;
    PlayBtn.Visible := True;
  end;
end;

procedure TSoundDlg.SQCB1Change(Sender: TObject);
begin
  if SQCB1.Checked then
  begin
    ReleaseSoundSystem;
    FSoundQuality := 0;
    CurrentSongLbl.Text := '';
    PlayLB.FDrawn := False;
    MainPnl.FDrawn := False;
  end;
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1)
  else General.PlayButtonSound(2);
end;

procedure TSoundDlg.SQCB2Change(Sender: TObject);
begin
  if SQCB2.Checked then
  begin
    FSoundQuality := 1;
    if Sound.ssActivated in SoundSystemStatus then
    begin
      FSettings.OutputMode := [omMono, om8bit];
      FSettings.SampleRate := 22050;
      SetSoundSettings(FSettings);
    end
    else
    begin
      FSettings.OutputMode := [omMono, om8bit];
      FSettings.SampleRate := 22050;
      InitializeSoundSystem('Galaxy', FSettings);
    end;
  end;
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1)
  else General.PlayButtonSound(2);
end;

procedure TSoundDlg.SQCB3Change(Sender: TObject);
begin
  if SQCB3.Checked then
  begin
    FSoundQuality := 2;
    if Sound.ssActivated in SoundSystemStatus then
    begin
      FSettings.OutputMode := [omStereo, om16bit];
      FSettings.SampleRate := 44100;
      SetSoundSettings(FSettings);
    end
    else
    begin
      FSettings.OutputMode := [omStereo, om16bit];
      FSettings.SampleRate := 44100;
      InitializeSoundSystem('Galaxy', FSettings);
    end;
  end;
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1)
  else General.PlayButtonSound(2);
end;

procedure TSoundDlg.SQCB4Change(Sender: TObject);
begin
  if SQCB4.Checked then
  begin
    FSoundQuality := 3;
    if Sound.ssActivated in SoundSystemStatus then
    begin
      FSettings.OutputMode := [omStereo, om16bit, omHighQuality];
      FSettings.SampleRate := 44100;
      SetSoundSettings(FSettings);
    end
    else
    begin
      FSettings.OutputMode := [omStereo, om16bit, omHighQuality];
      FSettings.SampleRate := 44100;
      InitializeSoundSystem('Galaxy', FSettings);
    end;
  end;
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1)
  else General.PlayButtonSound(2);
end;

procedure TSoundDlg.PlayLBDrawItem(Sender: TObject; const R: TRect; Index: Integer; var SurfDesc: TSurfaceDesc);
begin
  if SongPlayer.CurrentIndex = Index then IntGfxMod.SoundWin[2].ShowClipped(R.Left, R.Top, SurfDesc);
end;

procedure TSoundDlg.MusicEnabledChkChange(Sender: TObject);
begin
  FSettings.MusicEnabled := MusicEnabledChk.Checked;
  SetMusicEnabled(FSettings.MusicEnabled);
  if FSettings.MusicEnabled and (FSoundQuality <> 0) then SongPlayer.Play(0);
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1)
  else General.PlayButtonSound(2);
end;

procedure TSoundDlg.SFXEnabledChkChange(Sender: TObject);
begin
  FSettings.SFXEnabled := SFXEnabledChk.Checked;
  SetSFXEnabled(FSettings.SFXEnabled);
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1)
  else General.PlayButtonSound(2);
end;

procedure TSoundDlg.DirectSoundEnabledChkChange(Sender: TObject);
begin
  FSettings.UseDirectSound := DirectSoundEnabledChk.Checked;
  if Sound.ssActivated in SoundSystemStatus then SetSoundSettings(FSettings);
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1)
  else General.PlayButtonSound(2);
end;

procedure TSoundDlg.SoundTabChange;
begin
  General.PlayButtonSound(0);
end;

procedure TSoundDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then Dlg.Visible := False;
end;


end.
