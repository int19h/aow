unit Galaxy;

{ The Galaxy unit of SoundP.dpl: the binding to the Galaxy Sound System (Carlo Vogelsang's
  third-party sound library: software mixer for samples, MOD/S3M/IT music, CD audio), written for
  the original compiler (Delphi 3.02) and compared function by function with the shipped module
  (tools/match.py). GALAXY.DLL is loaded at run time and every entry point and data export is
  linked by ordinal (GetGalaxyProc); the glx* variables are exported by the package in this
  declaration order. The routines are cdecl (the caller pops the arguments). The variables are
  declared with anonymous procedural and pointer types, as in the original: the signature hash
  in each export name (glxInit@F93F9B8A) is then the same as the original's for every routine
  whose parameters are plain integers and pointers. The routines that take a Galaxy record
  (voice, sample, instrument) hash differently since their record types are not known, and the
  data exports that point to Galaxy records or arrays are plain Pointers here.
  The data exports (glxMusicVolume, glxCurrentOrder, ...) are pointers into the DLL.

  InitializeGalaxy skips ordinals $D5 (glxEffectChannels is never linked) and $E3, and links
  glxKNIFound last ($F2); kept as in the original. }

interface

uses
  Windows, SysUtils;

const
  { glxStartOutput mixer flags (SetSoundSettings) }
  GLX_MONO = 0;
  GLX_STEREO = 1;
  GLX_8BIT = 0;
  GLX_16BIT = 2;
  GLX_HIGHQUALITY = 4;

  { glxSample.Type_ flags }
  GLX_SAMPLE_LOOPED = 8;
  GLX_SAMPLE_16BIT = 4;
  GLX_SAMPLE_STEREO = $40;

type
  { glxSample (72 bytes): the sample header Galaxy loads (glxLoadSample) or GalSndS builds for
    sound data in memory (TGalaxySampleData.CreateEx): +0 FourCC 'SAMP', +4 Size (bytes after
    the first eight), +$28 Panning, +$2A Volume, +$2C Type_ (GLX_SAMPLE_*), +$30 Length,
    +$34 LoopStart, +$38 LoopEnd, +$3C C4Speed (the sample rate), +$44 Data. }
  PglxSample = ^TglxSample;
  TglxSample = record
    FourCC: Longint;
    Size: Longint;
    Message: array[0..31] of Char;
    Panning: Word;
    Volume: Word;
    Type_: Word;
    Reserved: Word;
    Length: Longint;
    LoopStart: Longint;
    LoopEnd: Longint;
    C4Speed: Longint;
    Articulation: Pointer;
    Data: Pointer;
  end;

  { glxVoice (packed): GalSndS reads only +$F Active and +$42 Sample, the sample the voice
    plays (TGalaxySample.GetPlaying). }
  PglxVoice = ^TglxVoice;
  TglxVoice = packed record
    Reserved1: array[0..14] of Byte;
    Active: Byte;
    Reserved2: array[0..49] of Byte;
    Sample: PglxSample;
  end;

var
  glxfOpen: function(FileName, Mode: PChar): Pointer; cdecl;
  glxfClose: function(Stream: Pointer): Integer; cdecl;
  glxAllocateStreamingBuffer: Pointer;
  glxControlChannel: function(Channel, Command, Param1, Param2: Integer): Integer; cdecl;
  glxControlVoice: function(Voice: PglxVoice; Frequency, Volume, Panning: Integer): Integer; cdecl;
  glxControlMusic: function(A, B: Integer): Integer; cdecl;
  glxControlSample: function(Voice: PglxVoice; Frequency, Volume, Panning: Integer): Integer; cdecl;
  glxControlSample3D: Pointer;
  glxControlInstrument: Pointer;
  glxDeInit: function: Integer; cdecl;
  glxDetectOutput: function(A, B: Integer): Integer; cdecl;
  glxFlushOutput: function: Integer; cdecl;
  glxInfo: Pointer;
  glxInit: function: Integer; cdecl;
  glxLock: function: Integer; cdecl;
  glxLoadEffects: function(Stream: Pointer; Flags: Integer): Integer; cdecl;
  glxLoadMusic: function(Stream: Pointer; Flags: Integer): Integer; cdecl;
  glxLoadSample: function(Stream: Pointer; Flags: Integer): PglxSample; cdecl;
  glxLoadInstument: function(Instrument: Integer; Stream: Pointer; Flags: Integer): Integer; cdecl;
  glxLoadInstrumentSample: Pointer;
  glxResetMusic: function: Integer; cdecl;
  glxSaveEffects: function(Stream: Pointer; Flags: Integer): Integer; cdecl;
  glxSaveMusic: function(Stream: Pointer; Flags: Integer): Integer; cdecl;
  glxSaveSample: Pointer;
  glxSaveInstruments: function(Instrument: Integer; Stream: Pointer; Flags: Integer): Integer;
    cdecl;
  glxSaveInstrumentSample: function(Instrument, Sample: Integer; Stream: Pointer;
    Flags: Integer): Integer; cdecl;
  glxSetCallBack: Pointer;
  glxSetCDAudoVolume: function(A, B: Integer): Integer; cdecl;
  glxSetMusicVolume: function(A, B: Integer): Integer; cdecl;
  glxSetSampleVoices: function(A: Integer): Integer; cdecl;
  glxSetSampleVolume: function(A, B: Integer): Integer; cdecl;
  glxSetIOInterface: function(OpenProc, ReadProc, SeekProc, CloseProc: Pointer): Integer; cdecl;
  glxSetMemInterface: function(AllocProc, ReallocProc, FreeProc: Pointer): Integer; cdecl;
  glxSetMusicChorus: function(P: Pointer): Integer; cdecl;
  glxSetMusicReverb: function(P: Pointer): Integer; cdecl;
  glxSetSampleChorus: function(P: Pointer): Integer; cdecl;
  glxSetSampleReverb: function(P: Pointer): Integer; cdecl;
  glxSetSampleReverb2: function(P: Pointer): Integer; cdecl;
  glxStartCDAudio: function(A, B: Integer): Integer; cdecl;
  glxStartMusic: function: Integer; cdecl;
  glxStartOutput: function(Owner: Pointer; Rate, Flags, BufferMs: Integer): Integer; cdecl;
  glxStartSample: function(VoiceNo: Integer; Sample: PglxSample; Frequency, Volume, Panning,
    Flags: Integer): PglxVoice; cdecl;
  glxStartSample3D: Pointer;
  glxStartInstrument: Pointer;
  glxStopCDAudio: function: Integer; cdecl;
  glxStopMusic: function: Integer; cdecl;
  glxStopOutput: function: Integer; cdecl;
  glxStopSample: function(Voice: PglxVoice): Integer; cdecl;
  glxStopSample3D: function(Voice: PglxVoice): Integer; cdecl;
  glxStopInstrument: function(Voice: PglxVoice): Integer; cdecl;
  glxUnlock: function: Integer; cdecl;
  glxUnloadMusic: function: Integer; cdecl;
  glxUnloadSample: function(Sample: PglxSample): Integer; cdecl;
  glxUnloadInstrument: function(A: Integer): Integer; cdecl;
  glxUnloadInstrumentSample: function(A, B: Integer): Integer; cdecl;
  glxAudioOutput: Pointer;
  glxAudioBuffer: Pointer;
  glxVoices: Pointer;
  glxChannels: Pointer;
  glxSongName: PChar;
  glxAuthorName: PChar;
  glxPlayerMode: ^Byte;
  glxMusicVoices: ^Byte;
  glxInitialSpeed: ^Word;
  glxInitialTempo: ^Word;
  glxMinPeriod: ^Word;
  glxMaxPeriod: ^Word;
  glxInitialPanning: Pointer;
  glxEffectChannels: ^Byte;
  glxSongLength: ^Byte;
  glxOrders: Pointer;
  glxPatterns: Pointer;
  glxInstruments: Pointer;
  glxCurrentPtr: Pointer;
  glxCurrentTime: ^Word;
  glxPatternRow: ^Byte;
  glxPatternBreak: ^Byte;
  glxCurrentTempo: ^Word;
  glxCurrentSpeed: ^Word;
  glxCurrentOrder: ^Byte;
  glxCurrentTick: ^Longint;
  glxCurrentSample: ^Longint;
  glxMusicVolume: ^Shortint;
  glxSampleVolume: ^Shortint;
  glxCDVolume: ^Shortint;
  glxMusicEnabled: ^Byte;
  glxOutputActive: ^Byte;
  glxMusicLooping: ^Byte;
  glxSamplingrate: ^Longint;
  glxCallbackFunction: Pointer;
  glxMMXFound: ^Byte;
  glxK3DFound: ^Byte;
  glxKNIFound: ^Byte;
  glxMusicReverb: Pointer;
  glxSampleReverb: Pointer;
  glxMusicChorus: Pointer;
  glxSampleChorus: Pointer;

function GalaxyActive: Boolean;
function InitializeGalaxy: Boolean;
function ReleaseGalaxy: Boolean;

implementation

const
  GalaxyDLLName: string = 'galaxy.dll';
  GalaxyHandle: THandle = 0;
  GalaxyRefCount: Integer = 0;

function GalaxyActive: Boolean;
begin
  Result := GalaxyRefCount <> 0;
end;

function GetGalaxyProc(Ordinal: Integer): FARPROC;
begin
  Result := GetProcAddress(GalaxyHandle, PChar(Ordinal));
  if Result = nil then
    raise Exception.Create('Cannot link to DLL (ProcParam:' + IntToStr(Ordinal) + ')');
end;

{ Loads GALAXY.DLL on the first call and links every entry point; the later calls only count. }
function InitializeGalaxy: Boolean;
begin
  Result := True;
  if GalaxyRefCount = 0 then
  begin
    GalaxyHandle := LoadLibrary(@GalaxyDLLName[1]);
    if GalaxyHandle <> 0 then
    try
      @glxfOpen := GetGalaxyProc($32);
      @glxfClose := GetGalaxyProc($33);
      glxAllocateStreamingBuffer := GetGalaxyProc($64);
      @glxControlVoice := GetGalaxyProc($65);
      @glxControlMusic := GetGalaxyProc($66);
      @glxControlSample := GetGalaxyProc($67);
      glxControlSample3D := GetGalaxyProc($68);
      glxControlInstrument := GetGalaxyProc($69);
      @glxControlChannel := GetGalaxyProc($6A);
      @glxDeInit := GetGalaxyProc($6B);
      @glxDetectOutput := GetGalaxyProc($6C);
      @glxFlushOutput := GetGalaxyProc($6D);
      glxInfo := GetGalaxyProc($6E);
      @glxInit := GetGalaxyProc($6F);
      @glxLock := GetGalaxyProc($70);
      @glxLoadEffects := GetGalaxyProc($71);
      @glxLoadMusic := GetGalaxyProc($72);
      @glxLoadSample := GetGalaxyProc($73);
      @glxLoadInstument := GetGalaxyProc($74);
      glxLoadInstrumentSample := GetGalaxyProc($75);
      @glxResetMusic := GetGalaxyProc($76);
      @glxSaveEffects := GetGalaxyProc($77);
      @glxSaveMusic := GetGalaxyProc($78);
      glxSaveSample := GetGalaxyProc($79);
      @glxSaveInstruments := GetGalaxyProc($7A);
      @glxSaveInstrumentSample := GetGalaxyProc($7B);
      glxSetCallBack := GetGalaxyProc($7C);
      @glxSetCDAudoVolume := GetGalaxyProc($7D);
      @glxSetMusicVolume := GetGalaxyProc($7E);
      @glxSetSampleVoices := GetGalaxyProc($7F);
      @glxSetSampleVolume := GetGalaxyProc($80);
      @glxSetIOInterface := GetGalaxyProc($81);
      @glxSetMemInterface := GetGalaxyProc($82);
      @glxSetMusicChorus := GetGalaxyProc($83);
      @glxSetMusicReverb := GetGalaxyProc($84);
      @glxSetSampleChorus := GetGalaxyProc($85);
      @glxSetSampleReverb := GetGalaxyProc($86);
      @glxSetSampleReverb2 := GetGalaxyProc($87);
      @glxStartCDAudio := GetGalaxyProc($88);
      @glxStartMusic := GetGalaxyProc($89);
      @glxStartOutput := GetGalaxyProc($8A);
      @glxStartSample := GetGalaxyProc($8B);
      glxStartSample3D := GetGalaxyProc($8C);
      glxStartInstrument := GetGalaxyProc($8D);
      @glxStopCDAudio := GetGalaxyProc($8E);
      @glxStopMusic := GetGalaxyProc($8F);
      @glxStopOutput := GetGalaxyProc($90);
      @glxStopSample := GetGalaxyProc($91);
      @glxStopSample3D := GetGalaxyProc($92);
      @glxStopInstrument := GetGalaxyProc($93);
      @glxUnlock := GetGalaxyProc($94);
      @glxUnloadMusic := GetGalaxyProc($95);
      @glxUnloadSample := GetGalaxyProc($96);
      @glxUnloadInstrument := GetGalaxyProc($97);
      @glxUnloadInstrumentSample := GetGalaxyProc($98);
      glxAudioOutput := GetGalaxyProc($C8);
      glxAudioBuffer := GetGalaxyProc($C9);
      glxVoices := GetGalaxyProc($CA);
      glxChannels := GetGalaxyProc($CB);
      glxSongName := GetGalaxyProc($CC);
      glxAuthorName := GetGalaxyProc($CD);
      glxPlayerMode := GetGalaxyProc($CE);
      glxMusicVoices := GetGalaxyProc($CF);
      glxInitialSpeed := GetGalaxyProc($D0);
      glxInitialTempo := GetGalaxyProc($D1);
      glxMinPeriod := GetGalaxyProc($D2);
      glxMaxPeriod := GetGalaxyProc($D3);
      glxInitialPanning := GetGalaxyProc($D4);
      glxSongLength := GetGalaxyProc($D6);
      glxOrders := GetGalaxyProc($D7);
      glxPatterns := GetGalaxyProc($D8);
      glxInstruments := GetGalaxyProc($D9);
      glxCurrentPtr := GetGalaxyProc($DA);
      glxCurrentTime := GetGalaxyProc($DB);
      glxPatternRow := GetGalaxyProc($DC);
      glxPatternBreak := GetGalaxyProc($DD);
      glxCurrentTempo := GetGalaxyProc($DE);
      glxCurrentSpeed := GetGalaxyProc($DF);
      glxCurrentOrder := GetGalaxyProc($E0);
      glxCurrentTick := GetGalaxyProc($E1);
      glxCurrentSample := GetGalaxyProc($E2);
      glxMusicVolume := GetGalaxyProc($E4);
      glxSampleVolume := GetGalaxyProc($E5);
      glxCDVolume := GetGalaxyProc($E6);
      glxMusicEnabled := GetGalaxyProc($E7);
      glxOutputActive := GetGalaxyProc($E8);
      glxMusicLooping := GetGalaxyProc($E9);
      glxSamplingrate := GetGalaxyProc($EA);
      glxCallbackFunction := GetGalaxyProc($EB);
      glxMMXFound := GetGalaxyProc($EC);
      glxK3DFound := GetGalaxyProc($ED);
      glxMusicReverb := GetGalaxyProc($EE);
      glxSampleReverb := GetGalaxyProc($EF);
      glxMusicChorus := GetGalaxyProc($F0);
      glxSampleChorus := GetGalaxyProc($F1);
      glxKNIFound := GetGalaxyProc($F2);
    except
      Result := False;
    end
    else
      Result := False;
  end;
  if Result then
    Inc(GalaxyRefCount);
end;

function ReleaseGalaxy: Boolean;
begin
  Dec(GalaxyRefCount);
  if GalaxyRefCount = 0 then
  begin
    FreeLibrary(GalaxyHandle);
    GalaxyHandle := 0;
  end;
  Result := True;
end;

end.
