unit VFW;

{ The VFW unit of VideoP.dpl: the Video for Windows declarations the video player needs (AVIFile
  streams from avifil32.dll and the installable compressors from msvfw32.dll), written for the
  original compiler (Delphi 3.02). The functions are not imported statically: InitVFW loads both
  DLLs and fills the procedure variables below with GetProcAddress (ANSI entry points such as
  AVIFileOpenA), ReleaseVFW unloads them again; both are reference counted. The interfaces are
  declared without GUIDs (their type info in VideoP.dpl has none); their methods follow vfw.h.
  The package was compiled with optimization off ($O-): every local and parameter lives on the
  stack. }

{$O-}

interface

uses
  Windows, ActiveX, SysUtils;

const
  { stream types (mmioFOURCC) }
  streamtypeVIDEO = $73646976;  { 'vids' }
  streamtypeAUDIO = $73647561;  { 'auds' }

  { AVIStreamFindSample flags }
  FIND_NEXT = $00000001;
  FIND_PREV = $00000004;
  FIND_KEY = $00000010;
  FIND_ANY = $00000020;
  FIND_FORMAT = $00000040;

  { compressor modes and messages }
  ICMODE_COMPRESS = 1;
  ICMODE_DECOMPRESS = 2;
  ICMODE_FASTDECOMPRESS = 3;
  ICMODE_QUERY = 4;
  ICERR_OK = 0;
  ICM_USER = $4000;
  ICM_DECOMPRESS_BEGIN = ICM_USER + 12;
  ICM_DECOMPRESS_END = ICM_USER + 14;

  AVIERR_OK = 0;

  { typed constants: their addresses are exported by the package }
  ICTYPE_VIDEO: DWORD = $63646976;  { 'vidc' }
  ICTYPE_AUDIO: DWORD = $63647561;  { 'audc' }
  ICM_FRAMERATE: DWORD = $526D7246; { 'FrmR' }

  IID_IAVIFile: TGUID = '{00020020-0000-0000-C000-000000000046}';
  IID_IAVIStream: TGUID = '{00020021-0000-0000-C000-000000000046}';
  IID_IAVIStreaming: TGUID = '{00020022-0000-0000-C000-000000000046}';
  IID_IGetFrame: TGUID = '{00020023-0000-0000-C000-000000000046}';
  IID_IAVIEditStream: TGUID = '{00020024-0000-0000-C000-000000000046}';
  CLSID_AVISimpleUnMarshal: TGUID = '{00020009-0000-0000-C000-000000000046}';
  CLSID_AVIFile: TGUID = '{00020000-0000-0000-C000-000000000046}';

type
  HIC = THandle;

  { AVISTREAMINFOA (140 bytes) }
  PAVIStreamInfo = ^TAVIStreamInfo;
  TAVIStreamInfo = record
    fccType: DWORD;
    fccHandler: DWORD;
    dwFlags: DWORD;
    dwCaps: DWORD;
    wPriority: Word;
    wLanguage: Word;
    dwScale: DWORD;
    dwRate: DWORD;
    dwStart: DWORD;
    dwLength: DWORD;
    dwInitialFrames: DWORD;
    dwSuggestedBufferSize: DWORD;
    dwQuality: DWORD;
    dwSampleSize: DWORD;
    rcFrame: TRect;
    dwEditCount: DWORD;
    dwFormatChangeCount: DWORD;
    szName: array[0..63] of Char;
  end;

  { AVIFILEINFOA (108 bytes) }
  PAVIFileInfo = ^TAVIFileInfo;
  TAVIFileInfo = record
    dwMaxBytesPerSec: DWORD;
    dwFlags: DWORD;
    dwCaps: DWORD;
    dwStreams: DWORD;
    dwSuggestedBufferSize: DWORD;
    dwWidth: DWORD;
    dwHeight: DWORD;
    dwScale: DWORD;
    dwRate: DWORD;
    dwLength: DWORD;
    dwEditCount: DWORD;
    szFileType: array[0..63] of Char;
  end;

  { AVICOMPRESSOPTIONS }
  PAVICompressOptions = ^TAVICompressOptions;
  TAVICompressOptions = record
    fccType: DWORD;
    fccHandler: DWORD;
    dwKeyFrameEvery: DWORD;
    dwQuality: DWORD;
    dwBytesPerSecond: DWORD;
    dwFlags: DWORD;
    lpFormat: Pointer;
    cbFormat: DWORD;
    lpParms: Pointer;
    cbParms: DWORD;
    dwInterleaveEvery: DWORD;
  end;

  IAVIStream = interface(IUnknown)
    function Create(lParam1, lParam2: Longint): HResult; stdcall;
    function Info(var psi: TAVIStreamInfo; lSize: Longint): HResult; stdcall;
    function FindSample(lPos, lFlags: Longint): Longint; stdcall;
    function ReadFormat(lPos: Longint; lpFormat: Pointer; var lpcbFormat: Longint): HResult; stdcall;
    function SetFormat(lPos: Longint; lpFormat: Pointer; cbFormat: Longint): HResult; stdcall;
    function Read(lStart, lSamples: Longint; lpBuffer: Pointer; cbBuffer: Longint;
      plBytes, plSamples: PLongint): HResult; stdcall;
    function Write(lStart, lSamples: Longint; lpBuffer: Pointer; cbBuffer: Longint; dwFlags: DWORD;
      plSampWritten, plBytesWritten: PLongint): HResult; stdcall;
    function Delete(lStart, lSamples: Longint): HResult; stdcall;
    function ReadData(fcc: DWORD; lp: Pointer; var lpcb: Longint): HResult; stdcall;
    function WriteData(fcc: DWORD; lp: Pointer; cb: Longint): HResult; stdcall;
    function SetInfo(var lpInfo: TAVIStreamInfo; cbInfo: Longint): HResult; stdcall;
  end;

  IAVIEditStream = interface(IUnknown)
    function Cut(var plStart, plLength: Longint; var ppResult: IAVIStream): HResult; stdcall;
    function Copy(var plStart, plLength: Longint; var ppResult: IAVIStream): HResult; stdcall;
    function Paste(var plPos, plLength: Longint; pstream: IAVIStream; lStart, lEnd: Longint): HResult; stdcall;
    function Clone(var ppResult: IAVIStream): HResult; stdcall;
    function SetInfo(var lpInfo: TAVIStreamInfo; cbInfo: Longint): HResult; stdcall;
  end;

  IAVIFile = interface(IUnknown)
    function Info(var pfi: TAVIFileInfo; lSize: Longint): HResult; stdcall;
    function GetStream(var ppStream: IAVIStream; fccType: DWORD; lParam: Longint): HResult; stdcall;
    function CreateStream(var ppStream: IAVIStream; var psi: TAVIStreamInfo): HResult; stdcall;
    function WriteData(ckid: DWORD; lpData: Pointer; cbData: Longint): HResult; stdcall;
    function ReadData(ckid: DWORD; lpData: Pointer; var lpcbData: Longint): HResult; stdcall;
    function EndRecord: HResult; stdcall;
    function DeleteStream(fccType: DWORD; lParam: Longint): HResult; stdcall;
  end;

  IGetFrame = interface(IUnknown)
    function GetFrame(lPos: Longint): Pointer; stdcall;
    function BeginExtraction(lStart, lEnd, lRate: Longint): HResult; stdcall;
    function EndExtraction: HResult; stdcall;
    function SetFormat(lpbi: PBitmapInfoHeader; lpBits: Pointer; x, y, dx, dy: Integer): HResult; stdcall;
  end;

var
  { msvfw32.dll }
  ICClose: function(hic: HIC): DWORD; stdcall;
  ICLocate: function(fccType, fccHandler: DWORD; lpbiIn, lpbiOut: PBitmapInfoHeader;
    wFlags: Word): HIC; stdcall;
  ICSendMessage: function(hic: HIC; msg: UINT; dw1, dw2: DWORD): DWORD; stdcall;
  ICDecompress: function(hic: HIC; dwFlags: DWORD; lpbiFormat: PBitmapInfoHeader; lpData: Pointer;
    lpbi: PBitmapInfoHeader; lpBits: Pointer): DWORD; stdcall;
  { avifil32.dll }
  AVIFileInit: procedure; stdcall;
  AVIFileExit: procedure; stdcall;
  AVIFileAddRef: function(pfile: IAVIFile): ULONG; stdcall;
  AVIFileRelease: function(pfile: IAVIFile): ULONG; stdcall;
  AVIFileOpen: function(var ppfile: IAVIFile; szFile: PChar; uMode: UINT;
    lpHandler: PCLSID): HResult; stdcall;
  AVIFileInfo: function(pfile: IAVIFile; var pfi: TAVIFileInfo; lSize: Longint): HResult; stdcall;
  AVIFileGetStream: function(pfile: IAVIFile; var ppavi: IAVIStream; fccType: DWORD;
    lParam: Longint): HResult; stdcall;
  AVIFileCreateStream: function(pfile: IAVIFile; var ppavi: IAVIStream;
    var psi: TAVIStreamInfo): HResult; stdcall;
  AVIFileWriteData: function(pfile: IAVIFile; ckid: DWORD; lpData: Pointer;
    cbData: Longint): HResult; stdcall;
  AVIFileReadData: function(pfile: IAVIFile; ckid: DWORD; lpData: Pointer;
    var lpcbData: Longint): HResult; stdcall;
  AVIFileEndRecord: function(pfile: IAVIFile): HResult; stdcall;
  AVIStreamAddRef: function(pavi: IAVIStream): ULONG; stdcall;
  AVIStreamRelease: function(pavi: IAVIStream): ULONG; stdcall;
  AVIStreamInfo: function(pavi: IAVIStream; var psi: TAVIStreamInfo; lSize: Longint): HResult; stdcall;
  AVIStreamFindSample: function(pavi: IAVIStream; lPos, lFlags: Longint): Longint; stdcall;
  AVIStreamReadFormat: function(pavi: IAVIStream; lPos: Longint; lpFormat: Pointer;
    var lpcbFormat: Longint): HResult; stdcall;
  AVIStreamSetFormat: function(pavi: IAVIStream; lPos: Longint; lpFormat: Pointer;
    cbFormat: Longint): HResult; stdcall;
  AVIStreamReadData: function(pavi: IAVIStream; fcc: DWORD; lp: Pointer;
    var lpcb: Longint): HResult; stdcall;
  AVIStreamWriteData: function(pavi: IAVIStream; fcc: DWORD; lp: Pointer;
    cb: Longint): HResult; stdcall;
  AVIStreamRead: function(pavi: IAVIStream; lStart, lSamples: Longint; lpBuffer: Pointer;
    cbBuffer: Longint; plBytes, plSamples: PLongint): HResult; stdcall;
  AVIStreamWrite: function(pavi: IAVIStream; lStart, lSamples: Longint; lpBuffer: Pointer;
    cbBuffer: Longint; dwFlags: DWORD; plSampWritten, plBytesWritten: PLongint): HResult; stdcall;
  AVIStreamStart: function(pavi: IAVIStream): Longint; stdcall;
  AVIStreamLength: function(pavi: IAVIStream): Longint; stdcall;
  AVIStreamTimeToSample: function(pavi: IAVIStream; lTime: Longint): Longint; stdcall;
  AVIStreamSampleToTime: function(pavi: IAVIStream; lSample: Longint): Longint; stdcall;
  AVIStreamBeginStreaming: function(pavi: IAVIStream; lStart, lEnd, lRate: Longint): HResult; stdcall;
  AVIStreamEndStreaming: function(pavi: IAVIStream): HResult; stdcall;
  AVIStreamGetFrameOpen: function(pavi: IAVIStream; lpbiWanted: PBitmapInfoHeader): Pointer; stdcall;
  AVIStreamGetFrame: function(pg: Pointer; lPos: Longint): Pointer; stdcall;
  AVIStreamGetFrameClose: function(pg: Pointer): HResult; stdcall;
  AVIStreamOpenFromFile: function(var ppavi: IAVIStream; szFile: PChar; fccType: DWORD;
    lParam: Longint; mode: UINT; pclsidHandler: PCLSID): HResult; stdcall;
  AVIStreamCreate: function(var ppavi: IAVIStream; lParam1, lParam2: Longint;
    pclsidHandler: PCLSID): HResult; stdcall;
  AVISave: function(szFile: PChar; pclsidHandler: PCLSID; lpfnCallback: Pointer; nStreams: Integer;
    pfile: IAVIStream; lpOptions: PAVICompressOptions): HResult; cdecl;
  AVISaveV: function(szFile: PChar; pclsidHandler: PCLSID; lpfnCallback: Pointer; nStreams: Integer;
    ppavi: Pointer; plpOptions: Pointer): HResult; stdcall;
  AVISaveOptions: function(Wnd: HWND; uiFlags: UINT; nStreams: Integer; ppavi: Pointer;
    plpOptions: Pointer): BOOL; stdcall;
  AVISaveOptionsFree: function(nStreams: Integer; plpOptions: Pointer): HResult; stdcall;
  AVIMakeFileFromStreams: function(var ppfile: IAVIFile; nStreams: Integer;
    papStreams: Pointer): HResult; stdcall;
  AVIMakeCompressedStream: function(var ppsCompressed: IAVIStream; ppsSource: IAVIStream;
    lpOptions: PAVICompressOptions; pclsidHandler: PCLSID): HResult; stdcall;
  CreateEditableStream: function(var ppsEditable: IAVIStream; psSource: IAVIStream): HResult; stdcall;

{ Loads msvfw32.dll and avifil32.dll and links every procedure variable above. Counted: only the
  first call loads; later calls return True. Returns False (and undoes the load) when a DLL or an
  entry point is missing. }
function InitVFW: Boolean;
{ Undoes one InitVFW; the last one frees both DLLs. False when VFW was not initialized. }
function ReleaseVFW: Boolean;

implementation

const
  MSVFW32DLL: string = 'msvfw32.dll';
  AVIFIL32DLL: string = 'avifil32.dll';
  hMSVFW32: THandle = 0;
  hAVIFIL32: THandle = 0;

var
  VFWRefCount: Integer;

{ GetProcAddress that raises an exception for a missing entry point (InitVFW catches it). }
function GetProc(Module: HModule; const ProcName: string): Pointer;
begin
  Result := GetProcAddress(Module, PChar(ProcName));
  if Result = nil then
    raise Exception.Create('Cannot link to DLL (ProcName:' + ProcName + ')');
end;

function InitVFW: Boolean;
begin
  Inc(VFWRefCount);
  if VFWRefCount = 1 then
  begin
    hMSVFW32 := LoadLibrary(@MSVFW32DLL[1]);
    hAVIFIL32 := LoadLibrary(@AVIFIL32DLL[1]);
    if (hMSVFW32 <> 0) and (hAVIFIL32 <> 0) then
    begin
      try
        @ICClose := GetProc(hMSVFW32, 'ICClose');
        @ICLocate := GetProc(hMSVFW32, 'ICLocate');
        @ICSendMessage := GetProc(hMSVFW32, 'ICSendMessage');
        @ICDecompress := GetProc(hMSVFW32, 'ICDecompress');
        @AVIFileInit := GetProc(hAVIFIL32, 'AVIFileInit');
        @AVIFileExit := GetProc(hAVIFIL32, 'AVIFileExit');
        @AVIFileAddRef := GetProc(hAVIFIL32, 'AVIFileAddRef');
        @AVIFileRelease := GetProc(hAVIFIL32, 'AVIFileRelease');
        @AVIFileOpen := GetProc(hAVIFIL32, 'AVIFileOpenA');
        @AVIFileInfo := GetProc(hAVIFIL32, 'AVIFileInfo');
        @AVIMakeFileFromStreams := GetProc(hAVIFIL32, 'AVIMakeFileFromStreams');
        @AVIFileGetStream := GetProc(hAVIFIL32, 'AVIFileGetStream');
        @AVIFileCreateStream := GetProc(hAVIFIL32, 'AVIFileCreateStreamA');
        @AVIFileWriteData := GetProc(hAVIFIL32, 'AVIFileWriteData');
        @AVIFileReadData := GetProc(hAVIFIL32, 'AVIFileReadData');
        @AVIFileEndRecord := GetProc(hAVIFIL32, 'AVIFileEndRecord');
        @AVIStreamAddRef := GetProc(hAVIFIL32, 'AVIStreamAddRef');
        @AVIStreamRelease := GetProc(hAVIFIL32, 'AVIStreamRelease');
        @AVIStreamInfo := GetProc(hAVIFIL32, 'AVIStreamInfo');
        @AVIStreamFindSample := GetProc(hAVIFIL32, 'AVIStreamFindSample');
        @AVIStreamReadFormat := GetProc(hAVIFIL32, 'AVIStreamReadFormat');
        @AVIStreamSetFormat := GetProc(hAVIFIL32, 'AVIStreamSetFormat');
        @AVIStreamReadData := GetProc(hAVIFIL32, 'AVIStreamReadData');
        @AVIStreamWriteData := GetProc(hAVIFIL32, 'AVIStreamWriteData');
        @AVIStreamRead := GetProc(hAVIFIL32, 'AVIStreamRead');
        @AVIStreamWrite := GetProc(hAVIFIL32, 'AVIStreamWrite');
        @AVIStreamStart := GetProc(hAVIFIL32, 'AVIStreamStart');
        @AVIStreamLength := GetProc(hAVIFIL32, 'AVIStreamLength');
        @AVIStreamTimeToSample := GetProc(hAVIFIL32, 'AVIStreamTimeToSample');
        @AVIStreamSampleToTime := GetProc(hAVIFIL32, 'AVIStreamSampleToTime');
        @AVIStreamBeginStreaming := GetProc(hAVIFIL32, 'AVIStreamBeginStreaming');
        @AVIStreamEndStreaming := GetProc(hAVIFIL32, 'AVIStreamEndStreaming');
        @AVIStreamGetFrameOpen := GetProc(hAVIFIL32, 'AVIStreamGetFrameOpen');
        @AVIStreamGetFrame := GetProc(hAVIFIL32, 'AVIStreamGetFrame');
        @AVIStreamGetFrameClose := GetProc(hAVIFIL32, 'AVIStreamGetFrameClose');
        @AVIStreamOpenFromFile := GetProc(hAVIFIL32, 'AVIStreamOpenFromFile');
        @AVIStreamCreate := GetProc(hAVIFIL32, 'AVIStreamCreate');
        @AVISaveV := GetProc(hAVIFIL32, 'AVISaveVA');
        @AVISave := GetProc(hAVIFIL32, 'AVISave');
        @AVISaveOptions := GetProc(hAVIFIL32, 'AVISaveOptions');
        @AVISaveOptionsFree := GetProc(hAVIFIL32, 'AVISaveOptionsFree');
        @AVIMakeCompressedStream := GetProc(hAVIFIL32, 'AVIMakeCompressedStream');
        @CreateEditableStream := GetProc(hAVIFIL32, 'CreateEditableStream');
        Result := True;
      except
        ReleaseVFW;
        Result := False;
      end;
    end
    else
    begin
      ReleaseVFW;
      Result := False;
    end;
  end
  else
    Result := True;
end;

function ReleaseVFW: Boolean;
begin
  if VFWRefCount <> 0 then
  begin
    Dec(VFWRefCount);
    if VFWRefCount = 0 then
    begin
      if hMSVFW32 <> 0 then
      begin
        FreeLibrary(hMSVFW32);
        hMSVFW32 := 0;
      end;
      if hAVIFIL32 <> 0 then
      begin
        FreeLibrary(hAVIFIL32);
        hAVIFIL32 := 0;
      end;
    end;
    Result := True;
  end
  else
    Result := False;
end;

end.
