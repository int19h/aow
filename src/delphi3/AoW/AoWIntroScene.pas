unit AoWIntroScene;

{ Intro movie playback and its DirectSound streaming ring buffer, recovered from AoW.exe. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AowUserWindow, Video, E2DirectSound;

type
  TIntroScene = class;


  { TIntroScene: size $5C; $4C sound buffer, $50 buffer size, $54 DirectSound, $58 stream position. VMT 00451F68. }
  TIntroScene = class(TDataModule)
  public
    published
    Window: TAoWUserWindow; { +0044 }
    VideoPlayer: TVideoPlayer; { +0048 }
    public
    FSoundBuffer: IDirectSoundBuffer; { $4C }
    FBufferSize: Integer; { $50 }
    FDirectSound: IDirectSound; { $54 }
    FStreamPosition: Integer; { $58 }
    procedure InitializeSound;
    procedure ReleaseSound;
    procedure Finish;
    procedure Execute;
    procedure VideoPlayerStreamSound(Mode: TStreamSoundMode; Data: Pointer; DataSize: Integer);
    procedure WindowDrawSurfaceEx(Surface: TSurface; var Handled: Boolean);
    procedure WindowHide;
    procedure WindowUpdate;
    procedure WindowMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WindowKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses ActiveX, DSound, AoWE, AoWUnit, AoWExeForms, E2Globals, E2GameFlow, AoWVideoDlg, AoWComp;

procedure TIntroScene.InitializeSound;
var
  Desc: TDSBufferDesc;
  Size1, Size2: Integer;
  Data1, Data2: Pointer;
  HR: HResult;
begin
  ReleaseSoundSystem;
  CoInitialize(nil);
  HR := CoCreateInstance(CLSID_DirectSound, nil, 1, IID_IDirectSound, FDirectSound);
  if Succeeded(HR) then HR := FDirectSound.Initialize(nil);
  if Succeeded(HR) then HR := FDirectSound.SetCooperativeLevel(MainForm.Display.Handle, 1);
  if Succeeded(HR) then
  begin
    { Original sizes the byte buffer using samples per second. }
    FBufferSize := VideoPlayer.SoundFormat^.nSamplesPerSec * 60;
    Desc.Size := SizeOf(Desc);
    Desc.Flags := $8000;
    Desc.BufferBytes := FBufferSize;
    Desc.Reserved := 0;
    Desc.Format := VideoPlayer.SoundFormat;
    HR := FDirectSound.CreateSoundBuffer(Desc, FSoundBuffer, nil);
    if Succeeded(HR) then
    begin
      HR := FSoundBuffer.Lock(0, Desc.BufferBytes, Data1, Size1, Data2, Size2, 0);
      if Succeeded(HR) then
      begin
        FSoundBuffer.Unlock(Data1, Size1, Data2, Size2);
        if Succeeded(HR) then HR := FSoundBuffer.Play(0, 0, 1);
      end;
    end;
  end;
  Succeeded(HR);
end;

procedure TIntroScene.ReleaseSound;
begin
  if FSoundBuffer <> nil then
  begin
    FSoundBuffer.Stop;
    FSoundBuffer := nil;
  end;
  if FDirectSound <> nil then FDirectSound := nil;
  if AoWEngine.FRegistry.GetSoundQuality <> 0 then
  begin
    InitializeSoundSystem('Galaxy', SoundDlg.FSettings);
    SetMusicVolume(AoWEngine.FRegistry.GetMusicVolume);
    SetSFXVolume(AoWEngine.FRegistry.GetSFXVolume);
  end;
end;

procedure TIntroScene.VideoPlayerStreamSound(Mode: TStreamSoundMode; Data: Pointer; DataSize: Integer);
var
  Size1, Size2: Integer;
  Data1, Data2: Pointer;
  HR: HResult;
  Count: Integer;
begin
  if FSoundBuffer <> nil then
    if Mode = ssmPlay then
    begin
      HR := FSoundBuffer.Lock(0, DataSize, Data1, Size1, Data2, Size2, 0);
      if Succeeded(HR) then
      begin
        Move(Data^, Data1^, DataSize);
        HR := FSoundBuffer.Unlock(Data1, Size1, Data2, Size2);
        if Succeeded(HR) then HR := FSoundBuffer.SetCurrentPosition(0);
        if Succeeded(HR) then HR := FSoundBuffer.Play(0, 0, 1);
        FStreamPosition := DataSize;
        { The original unlocks the same block a second time. }
        if Succeeded(HR) then FSoundBuffer.Unlock(Data1, Size1, Data2, Size2);
      end;
    end
    else if Mode = ssmStream then
    begin
      HR := FSoundBuffer.Lock(FStreamPosition mod FBufferSize, DataSize, Data1, Size1, Data2, Size2, 0);
      if Succeeded(HR) then
      begin
        Inc(FStreamPosition, DataSize);
        Count := DataSize;
        if DataSize > Size1 then Count := Size1;
        Move(Data^, Data1^, Count);
        Dec(DataSize, Count);
        if DataSize > 0 then
        begin
          { The wrapped block reuses Count instead of the remaining DataSize. }
          if Count > Size2 then Count := Size2;
          Move(Pointer(Integer(Data) + Size1)^, Data2^, Count);
        end;
        if Succeeded(HR) then FSoundBuffer.Unlock(Data1, Size1, Data2, Size2);
      end;
    end
    else if Mode = ssmStop then FSoundBuffer.Stop;
end;

procedure TIntroScene.Execute;
begin
  SetSceneSize(VideoDialog, 640, 480);
  SetVideoMode(VideoDialog, scmTitle);
  MainForm.DXDC.DisplayWidth := 640;
  MainForm.DXDC.DisplayHeight := 480;
  if VideoPlayer.Open(AoWEngine.StartupDirectory + 'IMAGES\SCENES\INTRO.AVI') then
  begin
    if AoWEngine.FRegistry.GetSoundQuality <> 0 then InitializeSound;
    Window.WinManager.ILIndexTBack := 4;
    VideoPlayer.Play;
    VideoPlayer.Position := -500;
    Window.Visible := True;
  end
  else ShowTitleScene(TitleScene, True);
end;

procedure TIntroScene.WindowDrawSurfaceEx(Surface: TSurface; var Handled: Boolean);
var
  SD: TSurfaceDesc;
  X, Y: Integer;
begin
  if Succeeded(Surface.Lock(SD)) then
  begin
    if VideoPlayer.VideoLoaded then
    begin
      X := (SD.Width - VideoPlayer.VideoFormat^.biWidth) div 2;
      Y := (SD.Height - VideoPlayer.VideoFormat^.biHeight) div 2;
      VideoPlayer.Update;
      VideoPlayer.Show(X, Y, SD);
    end;
    Surface.Unlock;
  end;
  Handled := True;
end;

procedure TIntroScene.Finish;
begin
  ReleaseSound;
  Window.Visible := False;
  ShowTitleScene(TitleScene, True);
end;

procedure TIntroScene.WindowHide;
begin
  Window.WinManager.ILIndexTBack := 0;
  VideoPlayer.Close;
end;

procedure TIntroScene.WindowUpdate;
begin
  Window.FSurfaceValid := False;
  if not (vpsPlaying in VideoPlayer.Status) then Finish;
end;

procedure TIntroScene.WindowMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Finish;
end;

procedure TIntroScene.WindowKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = 27) or (Key = 32) then Finish;
end;

end.
