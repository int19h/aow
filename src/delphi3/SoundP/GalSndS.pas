unit GalSndS;

{ The GalSndS unit of SoundP.dpl: the sound system on top of the Galaxy Sound System (Galaxy
  unit), written for the original compiler (Delphi 3.02) and compared function by function with
  the shipped module (tools/match.py). Declarations follow the original instance layouts and VMT
  orders (data/classes.json); the enumeration names come from the type info.

  Volumes are 0..100 at the interface and 0..127 (music, sound effects) or 0..32767 (one
  sample) in Galaxy. Music is a module file (IT, S3M, ...) Galaxy loads and plays; PlaySongEx
  with FadeOut fades the playing song out first and starts the new one from Process once the
  music volume is down (pssWaitingForFadeIn). }

interface

uses
  Windows, SysUtils, Classes, Consts, MMSystem, Galaxy, Sound;

type
  { GalSndS.TGalaxySongStatus (instance size 16): +8 FOrder, +$C FSpeed, the module position }
  TGalaxySongStatus = class(TSongStatus)
  private
    FOrder: Integer;
    FSpeed: Integer;
  end;

  TGalaxySampleDataType = (gstDefault, gstExclusive);

  { GalSndS.TGalaxySampleData (instance size 20): +$C FDataType, +$10 FSample. gstDefault:
    loaded by Galaxy from a file; gstExclusive: a header built here for data in memory. }
  TGalaxySampleData = class(TSampleData)
  private
    FDataType: TGalaxySampleDataType;
    FSample: PglxSample;
  public
    constructor Create(Name: string); override;
    constructor CreateEx(Format: PWaveFormatEx; Data: Pointer; Size: Integer); override;
    destructor Destroy; override;
    property Sample: PglxSample read FSample;
  end;

  { GalSndS.TGalaxySample (instance size 40): +$18 FVoice, +$1C FPanning, +$20 FVolume (-1:
    the sample's own), +$24 FLooped. }
  TGalaxySample = class(TSample)
  private
    FVoice: PglxVoice;
    FPanning: TSamplePanning;
    FVolume: Integer;
    FLooped: Boolean;
  protected
    function GetPlaying: Boolean; override;
    function GetVolume: Integer; override;
    procedure SetVolume(Value: Integer); override;
    function GetLooped: Boolean; override;
    procedure SetLooped(Value: Boolean); override;
    function GetPanning: TSamplePanning; override;
    procedure SetPanning(Value: TSamplePanning); override;
  public
    constructor Create(ASampleData: TSampleData); override;
    procedure Play; override;
    procedure Stop; override;
    destructor Destroy; override;
  end;

  TPlayingSongStatus = (pssIdle, pssPlaying, pssWaitingForFadeIn);

  { GalSndS.TGalaxySoundSystem (instance size 60): +$C FSettings (24 bytes), +$24 FSong (24
    bytes: +$24 Status, +$28 Volume (0..127), +$2C FileName, +$30 Order (the order Process
    starts a waiting song at; never set here), +$34 FadeIn, +$38 Loop). }
  TGalaxySoundSystem = class(TSoundSystem)
  private
    FSettings: TSoundSettings;
    FSong: record
      Status: TPlayingSongStatus;
      Volume: Integer;
      FileName: string;
      Order: Integer;
      FadeIn: Integer;
      Loop: Boolean;
    end;
    procedure ResetPlayingSongData;
  protected
    class function GetName: string; override;
    function SampleClass: TSampleClass; override;
    function SampleDataClass: TSampleDataClass; override;
    function Activate(const Settings: TSoundSettings): Boolean; override;
    function Deactivate: Boolean; override;
    procedure Process; override;
    function GetMusicVolume: Integer; override;
    function GetSFXVolume: Integer; override;
    function GetPlayingSong: Boolean; override;
    function GetPlayingSongFileName: string; override;
    function GetSFXEnabled: Boolean; override;
    function GetMusicEnabled: Boolean; override;
  public
    function SetSFXEnabled(Value: Boolean): Boolean; override;
    function SetMusicEnabled(Value: Boolean): Boolean; override;
    function SetSoundSettings(const Settings: TSoundSettings): Boolean; override;
    function GetSoundSettings: TSoundSettings; override;
    function FadeMusicVolume(Volume, Speed: Integer): Boolean; override;
    function SetMusicVolume(Volume: Integer): Boolean; override;
    function FadeSFXVolume(Volume, Speed: Integer): Boolean; override;
    function SetSFXVolume(Volume: Integer): Boolean; override;
    function PlaySong(FileName: string): Boolean; override;
    function PlaySongEx(FileName: string; FadeOut, FadeIn: Integer; Loop: Boolean): Boolean;
      override;
    function StopSong: Boolean; override;
    function BackupSongStatus: TSongStatus; override;
    function RestoreSongStatus(Status: TSongStatus): Boolean; override;
  end;

implementation

{ TGalaxySampleData }

{ A sample header for wave data in memory. The length is computed as Size * nChannels div
  nBlockAlign (twice the sample count for stereo data); kept as in the original. }
constructor TGalaxySampleData.CreateEx(Format: PWaveFormatEx; Data: Pointer; Size: Integer);
begin
  inherited CreateEx(Format, Data, Size);
  FDataType := gstExclusive;
  FSample := AllocMem(SizeOf(TglxSample));
  FSample^.FourCC := $504D4153;
  FSample^.Size := $40;
  FSample^.Panning := $4000;
  FSample^.Volume := $7FFF;
  FSample^.C4Speed := Format^.nSamplesPerSec;
  FSample^.Data := Data;
  FSample^.Type_ := 3;
  if Format^.nChannels = 2 then
    FSample^.Type_ := FSample^.Type_ or GLX_SAMPLE_STEREO;
  if Format^.nBlockAlign div Format^.nChannels = 2 then
    FSample^.Type_ := FSample^.Type_ or GLX_SAMPLE_16BIT;
  FSample^.Length := Format^.nChannels * Size div Format^.nBlockAlign;
end;

constructor TGalaxySampleData.Create(Name: string);
var
  F: Pointer;
begin
  inherited Create(Name);
  F := glxfOpen(PChar(BaseSoundEnginePath + Name), 'rb');
  if F = nil then
    raise EFOpenError.CreateFmt(SFOpenError, [Name]);
  FSample := glxLoadSample(F, 1);
  FDataType := gstDefault;
  glxfClose(F);
end;

destructor TGalaxySampleData.Destroy;
begin
  if FDataType = gstDefault then
    glxUnloadSample(FSample)
  else if FDataType = gstExclusive then
    ReallocMem(FSample, 0);
  inherited Destroy;
end;

{ TGalaxySample }

constructor TGalaxySample.Create(ASampleData: TSampleData);
begin
  inherited Create(ASampleData);
  FVolume := -1;
  FPanning := spCenter;
end;

destructor TGalaxySample.Destroy;
begin
  if GetPlaying then
    glxStopSample(FVoice);
  inherited Destroy;
end;

function TGalaxySample.GetVolume: Integer;
begin
  Result := FVolume;
end;

procedure TGalaxySample.SetVolume(Value: Integer);
var
  P: Integer;
begin
  FVolume := Value;
  if FVoice <> nil then
  begin
    case FPanning of
      spLeft: P := 0;
      spCenter: P := $4000;
      spRight: P := $7FFF;
      spSurround: P := $8000;
    else
      P := $4000;
    end;
    glxControlSample(FVoice, -1, Round(FVolume * $7FFF / 100), P);
  end;
end;

function TGalaxySample.GetLooped: Boolean;
begin
  Result := FLooped;
end;

procedure TGalaxySample.SetLooped(Value: Boolean);
begin
  FLooped := Value;
  with TGalaxySampleData(SampleData).FSample^ do
    if FLooped then
    begin
      Type_ := Type_ or GLX_SAMPLE_LOOPED;
      LoopStart := 0;
      LoopEnd := Length - 1;
    end
    else
      Type_ := Type_ and not GLX_SAMPLE_LOOPED;
end;

function TGalaxySample.GetPanning: TSamplePanning;
begin
  Result := FPanning;
end;

procedure TGalaxySample.SetPanning(Value: TSamplePanning);
begin
  FPanning := Value;
end;

function TGalaxySample.GetPlaying: Boolean;
begin
  if FVoice <> nil then
    Result := inherited GetPlaying or ((FVoice^.Active <> 0) and
      (FVoice^.Sample = TGalaxySampleData(SampleData).FSample))
  else
    Result := False;
end;

procedure TGalaxySample.Play;
var
  P, V: Integer;
begin
  if not GetPlaying then
  begin
    case FPanning of
      spLeft: P := 0;
      spCenter: P := $4000;
      spRight: P := $7FFF;
      spSurround: P := $8000;
    else
      P := $4000;
    end;
    if GetLooped then
      with TGalaxySampleData(SampleData).FSample^ do
      begin
        Type_ := Type_ or GLX_SAMPLE_LOOPED;
        LoopStart := 0;
        LoopEnd := Length - 1;
      end;
    if FVolume <> -1 then
      V := Round(FVolume * $7FFF / 100)
    else
      V := -1;
    FVoice := glxStartSample(0, TGalaxySampleData(SampleData).FSample, -1, V, P, 0);
  end;
end;

procedure TGalaxySample.Stop;
begin
  if GetPlaying then
  begin
    glxStopSample(FVoice);
    FVoice := nil;
  end;
end;

{ TGalaxySoundSystem }

class function TGalaxySoundSystem.GetName: string;
begin
  Result := 'Galaxy';
end;

function TGalaxySoundSystem.GetSoundSettings: TSoundSettings;
begin
  Result := FSettings;
end;

{ Restarts the Galaxy output with the new settings (through DirectSound when asked for and
  available). }
function TGalaxySoundSystem.SetSoundSettings(const Settings: TSoundSettings): Boolean;
var
  Flags: Integer;
  Wnd: HWND;
begin
  if GalaxyActive then
  begin
    glxStopOutput;
    Flags := 0;
    if omMono in Settings.OutputMode then
      Flags := Flags or GLX_MONO
    else
      Flags := Flags or GLX_STEREO;
    if om8bit in Settings.OutputMode then
      Flags := Flags or GLX_8BIT
    else
      Flags := Flags or GLX_16BIT;
    if omHighQuality in Settings.OutputMode then
      Flags := Flags or GLX_HIGHQUALITY;
    Result := glxSetSampleVoices(Settings.SampleVoices) <> 0;
    if Result then
      if Settings.UseDirectSound and (glxDetectOutput(1, 0) = 0) then
      begin
        Wnd := Settings.Window;
        if Wnd = 0 then
          Wnd := GetActiveWindow;
        Result := glxStartOutput(Pointer(Wnd), Settings.SampleRate, Flags, 200) = 0;
      end
      else
        Result := glxStartOutput(nil, Settings.SampleRate, Flags, 20) = 0;
    if Result then
      FSettings := Settings;
  end
  else
    Result := False;
end;

function TGalaxySoundSystem.Activate(const Settings: TSoundSettings): Boolean;
begin
  ResetPlayingSongData;
  FSong.Volume := 127;
  Result := InitializeGalaxy;
  Result := Result and (glxInit = 0);
  Result := Result and (glxSetSampleVolume(127, 0) = 0);
  Result := Result and (glxSetMusicVolume(FSong.Volume, 0) = 0);
  if Result then
    SetSoundSettings(Settings);
  if not Result then
    Deactivate
  else
    FStatus := FStatus + [ssActivated];
end;

function TGalaxySoundSystem.Deactivate: Boolean;
begin
  if ssActivated in FStatus then
  begin
    FStatus := FStatus - [ssActivated, ssDirectSoundEnabled];
    glxStopOutput;
    glxUnloadMusic;
    glxDeInit;
    ReleaseGalaxy;
    Result := True;
  end
  else
    Result := False;
end;

function TGalaxySoundSystem.SampleClass: TSampleClass;
begin
  Result := TGalaxySample;
end;

function TGalaxySoundSystem.SampleDataClass: TSampleDataClass;
begin
  Result := TGalaxySampleData;
end;

function TGalaxySoundSystem.GetSFXEnabled: Boolean;
begin
  Result := FSettings.SFXEnabled;
end;

function TGalaxySoundSystem.SetSFXEnabled(Value: Boolean): Boolean;
begin
  FSettings.SFXEnabled := Value;
  Result := True;
end;

function TGalaxySoundSystem.GetMusicEnabled: Boolean;
begin
  Result := FSettings.MusicEnabled;
end;

function TGalaxySoundSystem.SetMusicEnabled(Value: Boolean): Boolean;
begin
  if Value <> FSettings.MusicEnabled then
  begin
    FSettings.MusicEnabled := Value;
    if not FSettings.MusicEnabled then
    begin
      glxStopMusic;
      glxUnloadMusic;
    end;
  end;
  Result := True;
end;

function TGalaxySoundSystem.SetMusicVolume(Volume: Integer): Boolean;
begin
  if Volume > 100 then
    Volume := 100;
  if Volume < 0 then
    Volume := 0;
  FSong.Volume := Round(Volume * 127 / 100);
  if FSong.Status <> pssWaitingForFadeIn then
    Result := glxSetMusicVolume(FSong.Volume, 0) = 0
  else
    Result := True;
end;

function TGalaxySoundSystem.FadeMusicVolume(Volume, Speed: Integer): Boolean;
begin
  if Volume > 100 then
    Volume := 100;
  if Volume < 0 then
    Volume := 0;
  if Speed < 0 then
    Speed := 0;
  if Speed > 100 then
    Speed := 100;
  FSong.Volume := Round(Volume * 127 / 100);
  if FSong.Status <> pssWaitingForFadeIn then
    Result := glxSetMusicVolume(FSong.Volume, Speed) = 0
  else
    Result := True;
end;

function TGalaxySoundSystem.GetMusicVolume: Integer;
begin
  if GalaxyActive then
    Result := Round(FSong.Volume * 100 / 127)
  else
    Result := -1;
end;

function TGalaxySoundSystem.SetSFXVolume(Volume: Integer): Boolean;
begin
  if Volume > 100 then
    Volume := 100;
  if Volume < 0 then
    Volume := 0;
  Volume := Round(Volume * 127 / 100);
  Result := glxSetSampleVolume(Volume, 0) = 0;
end;

function TGalaxySoundSystem.FadeSFXVolume(Volume, Speed: Integer): Boolean;
begin
  if Volume > 100 then
    Volume := 100;
  if Volume < 0 then
    Volume := 0;
  if Speed < 0 then
    Speed := 0;
  if Speed > 100 then
    Speed := 100;
  Volume := Round(Volume * 127 / 100);
  Result := glxSetSampleVolume(Volume, Speed) = 0;
end;

{ Scales Galaxy's sample volume (0..127) by 100/32767 instead of 100/127; kept as in the
  original. }
function TGalaxySoundSystem.GetSFXVolume: Integer;
begin
  if GalaxyActive then
    Result := Round(glxSampleVolume^ * 100 / 32767)
  else
    Result := -1;
end;

procedure TGalaxySoundSystem.ResetPlayingSongData;
begin
  FSong.Status := pssIdle;
  FSong.FileName := '';
  FSong.Loop := False;
  FSong.FadeIn := 2;
end;

{ Starts the waiting song once the old one has faded out. }
procedure TGalaxySoundSystem.Process;
begin
  if (FSong.Status = pssWaitingForFadeIn) and (glxMusicVolume^ = 0) then
  begin
    PlaySongEx(FSong.FileName, 0, FSong.FadeIn, FSong.Loop);
    if FSong.Order <> 0 then
      glxControlMusic(1, FSong.Order);
  end;
end;

function TGalaxySoundSystem.PlaySongEx(FileName: string; FadeOut, FadeIn: Integer;
  Loop: Boolean): Boolean;
var
  F: Pointer;
begin
  if GalaxyActive and FSettings.MusicEnabled then
    if (FadeOut = 0) or not GetPlayingSong then
    begin
      glxStopMusic;
      glxUnloadMusic;
      F := glxfOpen(PChar(BaseSoundEnginePath + FileName), 'rb');
      if F <> nil then
      begin
        try
          Result := glxLoadMusic(F, 1) = 0;
        finally
          glxfClose(F);
        end;
        if Loop then
          glxControlMusic(3, 1)
        else
          glxControlMusic(3, 0);
        if FadeIn <> 0 then
        begin
          glxSetMusicVolume(0, 0);
          glxSetMusicVolume(FSong.Volume, FadeIn);
        end
        else
          glxSetMusicVolume(FSong.Volume, 0);
        Result := Result and (glxStartMusic = 0);
        if Result then
        begin
          FSong.FileName := FileName;
          FSong.Status := pssPlaying;
          FSong.Loop := Loop;
          FSong.FadeIn := FadeIn;
        end;
      end
      else
        Result := False;
    end
    else
    begin
      ResetPlayingSongData;
      FSong.FileName := FileName;
      FSong.Status := pssWaitingForFadeIn;
      FSong.Loop := Loop;
      FSong.FadeIn := FadeIn;
      glxSetMusicVolume(0, FadeOut);
      Result := True;
    end
  else
    Result := False;
end;

function TGalaxySoundSystem.PlaySong(FileName: string): Boolean;
begin
  Result := PlaySongEx(FileName, 0, 0, False);
end;

function TGalaxySoundSystem.StopSong: Boolean;
begin
  if GalaxyActive then
    Result := glxStopMusic = 0
  else
    Result := False;
  ResetPlayingSongData;
end;

function TGalaxySoundSystem.GetPlayingSong: Boolean;
begin
  if GalaxyActive then
    Result := (glxMusicEnabled^ <> 0) or (FSong.Status = pssWaitingForFadeIn)
  else
    Result := False;
end;

function TGalaxySoundSystem.GetPlayingSongFileName: string;
begin
  if GetPlayingSong then
    Result := FSong.FileName
  else
    Result := '';
end;

function TGalaxySoundSystem.BackupSongStatus: TSongStatus;
var
  S: TGalaxySongStatus;
begin
  if GetPlayingSong then
  begin
    S := TGalaxySongStatus.Create;
    S.FFileName := FSong.FileName;
    S.FOrder := glxCurrentOrder^;
    S.FSpeed := glxCurrentSpeed^;
    Result := S;
  end
  else
    Result := nil;
end;

{ Restarts the saved song at its position, or (when a song is playing) fades that one out and
  lets Process start the saved song from the beginning. }
function TGalaxySoundSystem.RestoreSongStatus(Status: TSongStatus): Boolean;
begin
  if not GetPlayingSong then
  begin
    glxSetMusicVolume(0, 0);
    Result := PlaySong(Status.FileName);
    if Result then
      with TGalaxySongStatus(Status) do
      begin
        glxControlMusic(1, FOrder);
        glxCurrentSpeed^ := FSpeed;
      end;
    glxSetMusicVolume(FSong.Volume, 3);
  end
  else
  begin
    ResetPlayingSongData;
    FSong.FileName := Status.FileName;
    FSong.Status := pssWaitingForFadeIn;
    FSong.FadeIn := 3;
    glxSetMusicVolume(0, 2);
    Result := True;
  end;
end;

initialization
  RegisterSoundSystem(TGalaxySoundSystem);
end.
