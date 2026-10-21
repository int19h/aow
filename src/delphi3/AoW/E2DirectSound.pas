unit E2DirectSound;

{ DirectSound interfaces used by the executable intro. Slot offsets are the
  original DirectSound COM layout, through Unlock at $4C. }
interface
uses Windows, ActiveX, MMSystem;
type
  IDirectSoundBuffer = interface;
  TDSBufferDesc = record
    Size, Flags, BufferBytes, Reserved: DWORD;
    Format: PWaveFormatEx;
  end;
  IDirectSoundBuffer = interface(IUnknown)
    ['{279AFA85-4981-11CE-A521-0020AF0BE560}']
    function GetCaps(Caps: Pointer): HResult; stdcall;
    function GetCurrentPosition(Play, Write: Pointer): HResult; stdcall;
    function GetFormat(Format: Pointer; Size: DWORD; Written: Pointer): HResult; stdcall;
    function GetVolume(var Volume: Longint): HResult; stdcall;
    function GetPan(var Pan: Longint): HResult; stdcall;
    function GetFrequency(var Frequency: DWORD): HResult; stdcall;
    function GetStatus(var Status: DWORD): HResult; stdcall;
    function Initialize(Sound: IUnknown; const Desc: TDSBufferDesc): HResult; stdcall;
    function Lock(Offset, Size: Integer; var Data1: Pointer; var Size1: Integer;
      var Data2: Pointer; var Size2: Integer; Flags: DWORD): HResult; stdcall;
    function Play(Reserved1, Reserved2, Flags: DWORD): HResult; stdcall;
    function SetCurrentPosition(Position: DWORD): HResult; stdcall;
    function SetFormat(const Format: TWaveFormatEx): HResult; stdcall;
    function SetVolume(Volume: Longint): HResult; stdcall;
    function SetPan(Pan: Longint): HResult; stdcall;
    function SetFrequency(Frequency: DWORD): HResult; stdcall;
    function Stop: HResult; stdcall;
    function Unlock(Data1: Pointer; Size1: Integer; Data2: Pointer; Size2: Integer): HResult; stdcall;
    function Restore: HResult; stdcall;
  end;
  IDirectSound = interface(IUnknown)
    ['{279AFA83-4981-11CE-A521-0020AF0BE560}']
    function CreateSoundBuffer(const Desc: TDSBufferDesc; out Buffer: IDirectSoundBuffer;
      Outer: IUnknown): HResult; stdcall;
    function GetCaps(Caps: Pointer): HResult; stdcall;
    function DuplicateSoundBuffer(Source: IDirectSoundBuffer; out Dest: IDirectSoundBuffer): HResult; stdcall;
    function SetCooperativeLevel(Window: HWND; Level: DWORD): HResult; stdcall;
    function Compact: HResult; stdcall;
    function GetSpeakerConfig(var Config: DWORD): HResult; stdcall;
    function SetSpeakerConfig(Config: DWORD): HResult; stdcall;
    function Initialize(Device: PGUID): HResult; stdcall;
  end;
implementation
end.
