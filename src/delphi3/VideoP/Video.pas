unit Video;

{ The Video unit of VideoP.dpl: TVideoPlayer, the component that plays the game's AVI movies
  (intro, cut scenes) on a GFXE surface, written for the original compiler (Delphi 3.02) and
  compared function by function with the shipped module (tools/match.py). Declarations follow the
  original instance layout (notes/classes.json, notes/rtti/VideoP.dpl.txt).

  How it works: Open opens the video and the audio stream of an AVI file through the AVIFile API
  (VFW unit, loaded at run time). The video frames are decompressed with an installable
  compressor (ICLocate/ICDecompress) into a TDIBSurface whose pixel format follows the target
  surface; ShowFrame/Show copy (or remap) that DIB to a TSurfaceDesc. The sound is not played
  here: StreamSound reads the audio samples that belong to the current play position and hands
  them to OnStreamSound, which the game connects to its DirectSound stream. Timing is the
  millisecond clock of GFXE (GetElapsedMilliSeconds); Update advances the current frame.

  The package was compiled with optimization off ($O-): every local and parameter lives on the
  stack. }

{$O-}

interface

uses
  Windows, SysUtils, Classes, MMSystem, GFXE, VFW;

type
  TVideoPlayerStatus = set of (vpsInitialized, vpsLoaded, vpsPlaying, vpsPaused);
  TVideoPlayerOptions = set of (vpoUseDirectSound, vpoSoundEnabled, vpoVideoEnabled);
  TVideoPlayerLoopMode = (vplmNone, vplmLoopLongest, vplmLoopVideo, vplmLoopSound,
    vplmLoopIndependent);
  TSoundControlSettings = set of (scsResetSoundStream);
  TStreamSoundMode = (ssmStop, ssmPlay, ssmStream);
  { ssmPlay: Data holds the first block after a (re)start, ssmStream: the next block,
    ssmStop: stop the sound (Data nil) }
  TStreamSoundEvent = procedure(Mode: TStreamSoundMode; Data: Pointer; DataSize: Integer) of object;

  PRGBQuadArray = ^TRGBQuadArray;
  TRGBQuadArray = array[0..255] of TRGBQuad;

  { Video.TVideoPlayer (instance size 424). +$24 FFileName, +$28 FStatus, +$29 FSoundControl,
    +$2A FLoopmode, +$2B FOptions, +$2C FVideoStream, +$30 FVideoInfo (140 bytes), +$BC
    FFrameCount, +$C0 FFrameRate (frames per second), +$C4 FVideoFormat, +$C8 FCurrentFrame,
    +$CC FFrameBuffer, +$D0 FFrameBufferSize, +$D4 FOutputPFID, +$D8 FDIB, +$DC FLastFrame (the
    frame in FDIB), +$E0 FDecompressor, +$E4 FPosition (ms), +$E8 FStartTime (clock at FPosition),
    +$EC FStartPosition, +$F0 FSoundStream, +$F4 FSoundInfo (140 bytes), +$180 FSoundLength
    (samples), +$184 FSoundFormat, +$188 FSamplesPerSec, +$18C FOnStreamSound, +$194
    FSoundBuffer, +$198 FSoundBufferSize, +$19C FSoundBufferSamples (five seconds of sound),
    +$1A0 FSoundStreamSize (six seconds, in bytes; not used here), +$1A4 FSoundPosition (next
    sample to stream). }
  TVideoPlayer = class(TComponent)
  private
    FFileName: string;
    FStatus: TVideoPlayerStatus;
    FSoundControl: TSoundControlSettings;
    FLoopmode: TVideoPlayerLoopMode;
    FOptions: TVideoPlayerOptions;
    FVideoStream: IAVIStream;
    FVideoInfo: TAVIStreamInfo;
    FFrameCount: Integer;
    FFrameRate: Single;
    FVideoFormat: PBitmapInfoHeader; public property VideoFormat: PBitmapInfoHeader read FVideoFormat; private
    FCurrentFrame: Integer;
    FFrameBuffer: Pointer;
    FFrameBufferSize: Integer;
    FOutputPFID: Integer;
    FDIB: TDIBSurface;
    FLastFrame: Integer;
    FDecompressor: HIC;
    FPosition: Integer;
    FStartTime: Integer;
    FStartPosition: Integer;
    FSoundStream: IAVIStream;
    FSoundInfo: TAVIStreamInfo;
    FSoundLength: Integer;
    FSoundFormat: PWaveFormatEx; public property SoundFormat: PWaveFormatEx read FSoundFormat; private
    FSamplesPerSec: Single;
    FOnStreamSound: TStreamSoundEvent;
    FSoundBuffer: Pointer;
    FSoundBufferSize: Integer;
    FSoundBufferSamples: Integer;
    FSoundStreamSize: Integer;
    FSoundPosition: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize;
    procedure Release;
    procedure Clear;
    function GetSoundLoaded: Boolean;
    function GetVideoLoaded: Boolean;
    procedure CloseDecompressor;
    function SetupSound: Boolean;
    function StreamSound: Boolean;
    procedure ResetSoundStream;
    procedure StopSoundStream;
    function SetupVideo: Boolean;
    function RenderVideoFrame(Frame: Integer): Boolean;
    function OptimizeOutputPFID(PFID: Integer): Boolean;
    function Open(const FileName: string): Boolean;
    procedure Close;
    function ShowFrame(Frame, X, Y: Integer; const Dest: TSurfaceDesc): Boolean;
    function Show(X, Y: Integer; const Dest: TSurfaceDesc): Boolean;
    function GetPosition: Integer;
    procedure SetPosition(Value: Integer);
    function GetEndPosition: Integer;
    function Play: Boolean;
    function Stop: Boolean;
    function Pause: Boolean;
    function Resume: Boolean;
    function Update: Boolean;
    property Position: Integer read GetPosition write SetPosition;
    property EndPosition: Integer read GetEndPosition;
    property SoundLoaded: Boolean read GetSoundLoaded;
    property VideoLoaded: Boolean read GetVideoLoaded;
    property CurrentFrame: Integer read FCurrentFrame;
    property FrameCount: Integer read FFrameCount;
    property Status: TVideoPlayerStatus read FStatus;
  published
    property OnStreamSound: TStreamSoundEvent read FOnStreamSound write FOnStreamSound;
    property Loopmode: TVideoPlayerLoopMode read FLoopmode write FLoopmode;
    property Options: TVideoPlayerOptions read FOptions write FOptions;
  end;

procedure Register;

implementation

constructor TVideoPlayer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDIB := TDIBSurface.Create;
  FOutputPFID := 0;
  FCurrentFrame := -1;
  FOptions := [vpoUseDirectSound, vpoSoundEnabled, vpoVideoEnabled];
  FStatus := [];
  FLoopmode := vplmNone;
end;

destructor TVideoPlayer.Destroy;
begin
  if vpsLoaded in FStatus then
    Close;
  FDIB.Free;
  Clear;
  Release;
  inherited Destroy;
end;

{ Loads the VFW DLLs and initializes the AVIFile library (once per player). }
procedure TVideoPlayer.Initialize;
begin
  if not (vpsInitialized in FStatus) then
    if InitVFW then
    begin
      AVIFileInit;
      FStatus := FStatus + [vpsInitialized];
    end;
end;

procedure TVideoPlayer.Release;
begin
  if vpsInitialized in FStatus then
  begin
    AVIFileExit;
    ReleaseVFW;
    FStatus := FStatus - [vpsInitialized];
  end;
end;

{ Releases both streams, the decompressor and the buffers. The two stream formats are kept (they
  are reallocated on the next Open and never freed: a leak of the original). }
procedure TVideoPlayer.Clear;
begin
  CloseDecompressor;
  FFrameCount := 0;
  FFileName := '';
  ReallocMem(FFrameBuffer, 0);
  FFrameBufferSize := 0;
  ReallocMem(FSoundBuffer, 0);
  FSoundBufferSize := 0;
  FLastFrame := -1;
  FCurrentFrame := -1;
  FVideoStream := nil;
  FSoundStream := nil;
  FStartPosition := 0;
  FPosition := 0;
  FStartTime := 0;
end;

function TVideoPlayer.GetSoundLoaded: Boolean;
begin
  Result := (vpsLoaded in FStatus) and (FSoundStream <> nil);
end;

function TVideoPlayer.GetVideoLoaded: Boolean;
begin
  Result := (vpsLoaded in FStatus) and (FVideoStream <> nil);
end;

procedure TVideoPlayer.CloseDecompressor;
begin
  if FDecompressor <> 0 then
  begin
    ICSendMessage(FDecompressor, ICM_DECOMPRESS_END, 0, 0);
    if ICClose(FDecompressor) = ICERR_OK then
      FDecompressor := 0
    else
      raise Exception.Create('release decompress handle failure');
  end;
end;

{ Opens the audio stream of FFileName, reads its format and info and sizes the sound buffer: N is
  the number of samples per second rounded up, the buffer holds one second (N blocks) and
  FSoundBufferSamples is five seconds (5 * N samples). }
function TVideoPlayer.SetupSound: Boolean;
var
  FormatSize: Longint;
  N: Integer;
begin
  Result := AVIStreamOpenFromFile(FSoundStream, PChar(FFileName), streamtypeAUDIO, 0,
    OF_SHARE_DENY_WRITE, nil) = AVIERR_OK;
  if Result then
  begin
    Result := AVIStreamReadFormat(FSoundStream, 0, nil, FormatSize) = AVIERR_OK;
    if Result then
    begin
      ReallocMem(FSoundFormat, FormatSize);
      Result := AVIStreamReadFormat(FSoundStream, 0, FSoundFormat, FormatSize) = AVIERR_OK;
    end;
    if Result then
    begin
      FSoundLength := AVIStreamLength(FSoundStream);
      Result := AVIStreamInfo(FSoundStream, FSoundInfo, SizeOf(FSoundInfo)) = AVIERR_OK;
      if Result then
      begin
        FSamplesPerSec := FSoundInfo.dwRate / FSoundInfo.dwScale;
        N := Trunc(FSamplesPerSec);
        if N <> FSamplesPerSec then
          Inc(N);
        FSoundBufferSize := Round(FSoundFormat^.nBlockAlign * N);
        ReallocMem(FSoundBuffer, FSoundBufferSize);
        FSoundBufferSamples := N * 5;
        FSoundStreamSize := (N + FSoundBufferSamples) * FSoundFormat^.nBlockAlign;
      end;
    end;
  end;
end;

{ Reads the audio samples from the stream position up to five seconds (FSoundBufferSamples) ahead
  of the play position and passes them to OnStreamSound (ssmStream). After a seek, or when more
  than one second would have to be read, it restarts at the play position (ssmPlay) with five
  seconds of sound. }
function TVideoPlayer.StreamSound: Boolean;
var
  BytesNeeded: Longint;
  Samples: Longint;
  BytesRead: Longint;
  Pos: Integer;
  MaxLag: Integer;
  Mode: TStreamSoundMode;
  SamplePos: Integer;
  Start: Integer;
  Count: Integer;
begin
  if vpoSoundEnabled in FOptions then
  begin
    Pos := GetPosition;
    if Pos >= 0 then
    begin
      Result := True;
      MaxLag := FSoundBufferSamples div 5;
      SamplePos := Round(Pos * FSamplesPerSec * 0.001);
      Mode := ssmStream;
      Start := FSoundPosition;
      Count := SamplePos + FSoundBufferSamples - Start;
      if Count > MaxLag then
        ResetSoundStream;
      if scsResetSoundStream in FSoundControl then
      begin
        Mode := ssmPlay;
        Start := SamplePos;
        Count := FSoundBufferSamples;
        FSoundControl := FSoundControl - [scsResetSoundStream];
      end;
      if Count > 0 then
      begin
        Result := AVIStreamRead(FSoundStream, Start, Count, nil, 0, @BytesNeeded,
          @Samples) = AVIERR_OK;
        if Result and (FSoundBufferSize < BytesNeeded) then
        begin
          FSoundBufferSize := BytesNeeded;
          ReallocMem(FSoundBuffer, FSoundBufferSize);
        end;
        Result := Result and (AVIStreamRead(FSoundStream, Start, Count, FSoundBuffer,
          FSoundBufferSize, @BytesRead, @Samples) = AVIERR_OK);
        FSoundPosition := Start + Count;
        if Result and Assigned(FOnStreamSound) then
          FOnStreamSound(Mode, FSoundBuffer, BytesRead);
      end;
    end
    else
      Result := True;
  end
  else
    Result := False;
end;

procedure TVideoPlayer.ResetSoundStream;
begin
  FSoundControl := FSoundControl + [scsResetSoundStream];
end;

procedure TVideoPlayer.StopSoundStream;
begin
  if Assigned(FOnStreamSound) then
    FOnStreamSound(ssmStop, nil, 0);
end;

{ Opens the video stream of FFileName and reads its format (a BITMAPINFOHEADER with the palette
  for 8 bit video), length, frame rate and the buffer size of one compressed frame. }
function TVideoPlayer.SetupVideo: Boolean;
var
  FormatSize: Longint;
  Res: HResult;
begin
  Res := AVIStreamOpenFromFile(FVideoStream, PChar(FFileName), streamtypeVIDEO, 0,
    OF_SHARE_DENY_WRITE, nil);
  Result := Res = AVIERR_OK;
  if Result then
  begin
    Result := AVIStreamReadFormat(FVideoStream, 0, nil, FormatSize) = AVIERR_OK;
    if Result then
    begin
      ReallocMem(FVideoFormat, FormatSize);
      Result := AVIStreamReadFormat(FVideoStream, 0, FVideoFormat, FormatSize) = AVIERR_OK;
    end;
    if Result then
    begin
      FFrameCount := AVIStreamLength(FVideoStream);
      Result := AVIStreamInfo(FVideoStream, FVideoInfo, SizeOf(FVideoInfo)) = AVIERR_OK;
      if Result then
      begin
        FFrameRate := FVideoInfo.dwRate / FVideoInfo.dwScale;
        FFrameBufferSize := FVideoInfo.dwSuggestedBufferSize;
        ReallocMem(FFrameBuffer, FFrameBufferSize);
      end;
    end;
  end;
end;

{ Decompresses Frame into FDIB: reads and decompresses every frame from the previous key frame
  (or from the frame after FLastFrame when that is closer) up to Frame. }
function TVideoPlayer.RenderVideoFrame(Frame: Integer): Boolean;
var
  SaveESP: Integer;
  BytesNeeded: Longint;
  BytesRead: Longint;
  Samples: Longint;
  First: Integer;
  I: Integer;
  Res: DWORD;
begin
  if (Frame >= 0) and (Frame < FFrameCount) and (Frame <> FLastFrame) then
  begin
    Result := True;
    First := AVIStreamFindSample(FVideoStream, Frame, FIND_PREV or FIND_KEY);
    if (FLastFrame + 1 > First) and (FLastFrame <= Frame) then
      First := FLastFrame + 1;
    for I := First to Frame do
    begin
      Result := AVIStreamRead(FVideoStream, I, 1, nil, 0, @BytesNeeded, @Samples) = AVIERR_OK;
      if Result and (FFrameBufferSize < BytesNeeded) then
      begin
        FFrameBufferSize := BytesNeeded;
        ReallocMem(FFrameBuffer, FFrameBufferSize);
      end;
      Result := Result and (AVIStreamRead(FVideoStream, I, 1, FFrameBuffer, FFrameBufferSize,
        @BytesRead, @Samples) = AVIERR_OK);
      { ICDecompress is a cdecl function declared stdcall (VFW): the stack pointer is saved and
        restored around the call by hand }
      asm
        mov SaveESP, esp
      end;
      if Result then
      begin
        Res := ICDecompress(FDecompressor, 0, FVideoFormat, FFrameBuffer,
          FDIB.GetBITMAPINFOHEADER, FDIB.Bits);
        Result := Result and (Res = ICERR_OK);
      end;
      asm
        mov esp, SaveESP
      end;
    end;
    if Result then
      FLastFrame := Frame
    else
      FLastFrame := -1;
  end
  else
    Result := False;
end;

{ Sets FDIB up in the pixel format PFID and opens a decompressor for it; when the codec cannot
  produce that format it falls back to 8 bit (with the palette of the video) or to RGB 565. }
function TVideoPlayer.OptimizeOutputPFID(PFID: Integer): Boolean;
var
  Colors: PRGBQuadArray;
  I: Integer;
  Entry: PPaletteEntry;
begin
  CloseDecompressor;
  FOutputPFID := PFID;
  FLastFrame := -1;
  FDIB.Setup(FVideoFormat^.biWidth, FVideoFormat^.biHeight, FOutputPFID, nil);
  FDecompressor := ICLocate(ICTYPE_VIDEO, FVideoInfo.fccHandler, FVideoFormat,
    FDIB.GetBITMAPINFOHEADER, ICMODE_DECOMPRESS);
  if FDecompressor = 0 then
  begin
    if FVideoFormat^.biBitCount = 8 then
    begin
      FDIB.Setup(FVideoFormat^.biWidth, FVideoFormat^.biHeight, pfPAL8, nil);
      FDecompressor := ICLocate(ICTYPE_VIDEO, FVideoInfo.fccHandler, FVideoFormat,
        FDIB.GetBITMAPINFOHEADER, ICMODE_DECOMPRESS);
      if FDecompressor <> 0 then
      begin
        Colors := PRGBQuadArray(PChar(FVideoFormat) + SizeOf(TBitmapInfoHeader));
        for I := 0 to 255 do
        begin
          Entry := @FDIB.Palette.Entries[I];
          Entry^.R := Colors^[I].rgbRed;
          Entry^.G := Colors^[I].rgbGreen;
          Entry^.B := Colors^[I].rgbBlue;
          Entry^.Reserved := 0;
        end;
        FDIB.UpdatePalette;
      end;
    end
    else if FVideoFormat^.biBitCount = 16 then
    begin
      FDIB.Setup(FVideoFormat^.biWidth, FVideoFormat^.biHeight, pfRGB565, nil);
      FDecompressor := ICLocate(ICTYPE_VIDEO, FVideoInfo.fccHandler, FVideoFormat,
        FDIB.GetBITMAPINFOHEADER, ICMODE_DECOMPRESS);
    end;
    Result := FDecompressor <> 0;
  end
  else
    Result := True;
  Result := Result and (ICSendMessage(FDecompressor, ICM_DECOMPRESS_BEGIN, DWORD(FVideoFormat),
    DWORD(FDIB.GetBITMAPINFOHEADER)) = ICERR_OK);
end;

function TVideoPlayer.Open(const FileName: string): Boolean;
begin
  Close;
  Initialize;
  if not (vpsLoaded in FStatus) then
  begin
    FStatus := FStatus + [vpsLoaded];
    FFileName := FileName;
    Result := SetupVideo;
    if SetupSound then
      Result := True;
    if not Result then
    begin
      FStatus := FStatus - [vpsLoaded];
      Clear;
    end;
  end
  else
    Result := False;
end;

procedure TVideoPlayer.Close;
begin
  if vpsLoaded in FStatus then
  begin
    Stop;
    Clear;
    FStatus := FStatus - [vpsLoaded];
  end;
end;

{ Draws video frame Frame at X, Y on Dest (remapped when the pixel formats differ). }
function TVideoPlayer.ShowFrame(Frame, X, Y: Integer; const Dest: TSurfaceDesc): Boolean;
var
  SD: TSurfaceDesc;
begin
  if GetVideoLoaded then
  begin
    if (FDecompressor = 0) or (Dest.PixelFormatID <> FOutputPFID) then
      Result := OptimizeOutputPFID(Dest.PixelFormatID)
    else
      Result := True;
    if Result then
    begin
      RenderVideoFrame(Frame);
      FDIB.Lock(SD);
      if Dest.PixelFormatID <> SD.PixelFormatID then
        RemapSurfacePart(SD, 0, 0, SD.Width, SD.Height, Dest, X, Y)
      else
        BltSDRectClipped(SD, SD.ClipRect, Dest, X, Y);
      FDIB.Unlock;
    end;
  end
  else
    Result := False;
end;

{ Draws the current frame (see Update) at X, Y on Dest. }
function TVideoPlayer.Show(X, Y: Integer; const Dest: TSurfaceDesc): Boolean;
var
  SD: TSurfaceDesc;
begin
  if GetVideoLoaded then
  begin
    if (FDecompressor = 0) or (Dest.PixelFormatID <> FOutputPFID) then
      Result := OptimizeOutputPFID(Dest.PixelFormatID)
    else
      Result := True;
    if Result then
    begin
      RenderVideoFrame(FCurrentFrame);
      FDIB.Lock(SD);
      if Dest.PixelFormatID <> SD.PixelFormatID then
        RemapSurfacePart(SD, 0, 0, SD.Width, SD.Height, Dest, X, Y)
      else
        BltSDRectClipped(SD, SD.ClipRect, Dest, X, Y);
      FDIB.Unlock;
    end;
  end
  else
    Result := False;
end;

{ The play position in milliseconds, -1 when not playing. }
function TVideoPlayer.GetPosition: Integer;
begin
  if vpsPlaying in FStatus then
  begin
    Result := FPosition;
    if not (vpsPaused in FStatus) then
      Inc(Result, GetElapsedMilliSeconds - FStartTime);
  end
  else
    Result := -1;
end;

procedure TVideoPlayer.SetPosition(Value: Integer);
begin
  FPosition := Value;
  FStartTime := GetElapsedMilliSeconds;
  ResetSoundStream;
end;

{ The length in milliseconds: the longer of the video and the sound stream. }
function TVideoPlayer.GetEndPosition: Integer;
var
  T: Integer;
begin
  Result := 0;
  if GetVideoLoaded then
  begin
    T := Round(FFrameCount / FFrameRate * 1000);
    if T > Result then
      Result := T;
  end;
  if GetSoundLoaded then
  begin
    T := Round(FSoundLength / FSamplesPerSec * 1000);
    if T > Result then
      Result := T;
  end;
end;

{ Starts playing at FStartPosition, half a second from now. }
function TVideoPlayer.Play: Boolean;
begin
  if not (vpsPlaying in FStatus) then
  begin
    FStatus := FStatus + [vpsPlaying];
    ResetSoundStream;
    FPosition := FStartPosition;
    FStartTime := GetElapsedMilliSeconds + 500;
    FSoundPosition := -1;
    FCurrentFrame := -1;
    Result := True;
  end
  else
    Result := False;
end;

function TVideoPlayer.Stop: Boolean;
begin
  if vpsPlaying in FStatus then
  begin
    FStatus := FStatus - [vpsPlaying];
    Result := True;
  end
  else
    Result := False;
end;

function TVideoPlayer.Pause: Boolean;
begin
  if vpsPlaying in FStatus then
  begin
    Inc(FPosition, GetElapsedMilliSeconds - FStartTime);
    FStatus := FStatus + [vpsPaused];
    if GetSoundLoaded and (vpoSoundEnabled in FOptions) then
      StopSoundStream;
    Result := True;
  end
  else
    Result := False;
end;

function TVideoPlayer.Resume: Boolean;
begin
  if vpsPlaying in FStatus then
  begin
    ResetSoundStream;
    FStatus := FStatus - [vpsPaused];
    FStartTime := GetElapsedMilliSeconds;
    Result := True;
  end
  else
    Result := False;
end;

{ Called by the game every frame: loops or stops at the end, computes the current frame from the
  clock and streams the sound. }
function TVideoPlayer.Update: Boolean;
begin
  if vpsPlaying in FStatus then
  begin
    if GetPosition > GetEndPosition then
      if FLoopmode <> vplmNone then
        SetPosition(0)
      else
        Stop;
    if vpsPlaying in FStatus then
    begin
      FCurrentFrame := Round(GetPosition * FFrameRate * 0.001);
      if not (vpsPaused in FStatus) then
      begin
        StreamSound;
        if FCurrentFrame >= FFrameCount then
          if FLoopmode <> vplmNone then
            FCurrentFrame := FCurrentFrame mod FFrameCount
          else
            FCurrentFrame := -1;
      end;
    end;
    Result := True;
  end
  else
    Result := False;
end;

procedure Register;
begin
  RegisterComponents('GFX Engine', [TVideoPlayer]);
end;

end.
