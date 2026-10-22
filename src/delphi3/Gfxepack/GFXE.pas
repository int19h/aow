unit GFXE;

{ The GFXE unit of Gfxepack.dpl (the graphics engine of Age of Wonders: surfaces, blitters, blend
  tables, DirectDraw access) written for the original compiler (Delphi 3.02), class by class:
  tools/match.py compares the code DCC32 generates for every method with the code in the game's
  module. Declarations follow the original instance layouts and VMT orders (notes/classes.json).
  The original was D:\GEngine\GFXE\GFXMAIN\GFXE.pas with inc\DIBSURF.PAS and inc\DDSurf.PAS
  included (the Assert line numbers tell); the DirectDraw interfaces and GUIDs are declared in
  this unit itself (their type info and typed constants sit in Gfxepack.dpl), without GUIDs on
  the interface types. The assembler blitters are transcribed from the disassembly: `asm` blocks
  compile verbatim; the MMX instructions are DB-encoded (Delphi 3 has no MMX mnemonics). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ActiveX,
  MMSystem;

const
  { HResult codes returned by the surfaces (GetErrorMsg) }
  GFXE_OK = 0;
  GFXE_ERROR = HResult($80000001);
  GFXE_NOTSUPPORTED = HResult($80000002);
  GFXE_PIXELFORMATNOTSUPPORTED = HResult($80000003);
  GFXE_BITMAPFORMATNOTSUPPORTED = HResult($80000004);
  GFXE_CANNOTLOCK = HResult($80000005);

  { Pixel format IDs (MASKtoPFID): bits 0-7 the bit count, bits 8-15 the channel order, the
    high nibbles the bits per channel (A, B, G, R) }
  pfPAL8 = $00000008;
  pfRGB555 = $55509310;
  pfARGB1555 = $55519310;
  pfRGB565 = $56509310;
  pfRGB24 = $88809318;
  pfBGR24 = $88801B18;
  pfRGB32 = $88889320;
  pfXRGB32 = $88809320;

  { DirectDraw constants used here }
  DD_OK = 0;
  DDERR_UNSUPPORTED = HResult($887601AE);
  DDERR_SURFACELOST = HResult($887601C2);
  DDERR_WASSTILLDRAWING = HResult($8876021C);
  DDENUMRET_OK = 1;
  DDSD_CAPS = $00000001;
  DDSD_HEIGHT = $00000002;
  DDSD_WIDTH = $00000004;
  DDSD_PITCH = $00000008;
  DDSD_PIXELFORMAT = $00001000;
  DDSCAPS_OFFSCREENPLAIN = $00000040;
  DDSCAPS_PRIMARYSURFACE = $00000200;
  DDSCAPS_SYSTEMMEMORY = $00000800;
  DDSCAPS_VIDEOMEMORY = $00004000;
  DDPF_RGB = $00000040;
  DDLOCK_WAIT = $00000001;
  DDBLT_ASYNC = $00000200;
  DDBLT_COLORFILL = $00000400;
  DDBLT_KEYSRC = $00008000;
  DDBLT_WAIT = $01000000;
  DDBLTFAST_NOCOLORKEY = $00000000;
  DDBLTFAST_SRCCOLORKEY = $00000001;
  DDBLTFAST_WAIT = $00000010;
  DDCKEY_SRCBLT = $00000008;
  DDGBS_CANBLT = $00000001;
  DDGFS_ISFLIPDONE = $00000002;
  DDSCL_NORMAL = $00000008;

type
  PWord = ^Word;

  { DirectDraw structures (ddraw.h layout) }
  PDDColorKey = ^TDDColorKey;
  TDDColorKey = record
    dwColorSpaceLowValue: DWORD;
    dwColorSpaceHighValue: DWORD;
  end;

  PDDPixelFormat = ^TDDPixelFormat;
  TDDPixelFormat = record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwFourCC: DWORD;
    dwRGBBitCount: DWORD;
    dwRBitMask: DWORD;
    dwGBitMask: DWORD;
    dwBBitMask: DWORD;
    dwRGBAlphaBitMask: DWORD;
  end;

  PDDSCaps = ^TDDSCaps;
  TDDSCaps = record
    dwCaps: DWORD;
  end;

  PDDSurfaceDesc = ^TDDSurfaceDesc;
  TDDSurfaceDesc = record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwHeight: DWORD;
    dwWidth: DWORD;
    lPitch: Longint;
    dwBackBufferCount: DWORD;
    dwMipMapCount: DWORD;
    dwAlphaBitDepth: DWORD;
    dwReserved: DWORD;
    lpSurface: Pointer;
    ddckCKDestOverlay: TDDColorKey;
    ddckCKDestBlt: TDDColorKey;
    ddckCKSrcOverlay: TDDColorKey;
    ddckCKSrcBlt: TDDColorKey;
    ddpfPixelFormat: TDDPixelFormat;
    ddsCaps: TDDSCaps;
  end;

  PDDBltFX = ^TDDBltFX;
  TDDBltFX = record
    dwSize: DWORD;
    dwDDFX: DWORD;
    dwROP: DWORD;
    dwDDROP: DWORD;
    dwRotationAngle: DWORD;
    dwZBufferOpCode: DWORD;
    dwZBufferLow: DWORD;
    dwZBufferHigh: DWORD;
    dwZBufferBaseDest: DWORD;
    dwZDestConstBitDepth: DWORD;
    dwZDestConst: DWORD;
    dwZSrcConstBitDepth: DWORD;
    dwZSrcConst: DWORD;
    dwAlphaEdgeBlendBitDepth: DWORD;
    dwAlphaEdgeBlend: DWORD;
    dwReserved: DWORD;
    dwAlphaDestConstBitDepth: DWORD;
    dwAlphaDestConst: DWORD;
    dwAlphaSrcConstBitDepth: DWORD;
    dwAlphaSrcConst: DWORD;
    dwFillColor: DWORD;
    ddckDestColorkey: TDDColorKey;
    ddckSrcColorkey: TDDColorKey;
  end;

  TDDEnumModesCallback = function(lpDDSurfaceDesc: PDDSurfaceDesc; lpContext: Pointer): HResult; stdcall;

  IDirectDrawSurface = interface;
  IDirectDrawPalette = interface;
  IDirectDrawClipper = interface;

  IDirectDraw = interface(IUnknown)
    function Compact: HResult; stdcall;
    function CreateClipper(dwFlags: DWORD; out lplpDDClipper: IDirectDrawClipper; pUnkOuter: IUnknown): HResult; stdcall;
    function CreatePalette(dwFlags: DWORD; lpColorTable: Pointer; out lplpDDPalette: IDirectDrawPalette; pUnkOuter: IUnknown): HResult; stdcall;
    function CreateSurface(const lpDDSurfaceDesc: TDDSurfaceDesc; var lplpDDSurface: IDirectDrawSurface; pUnkOuter: IUnknown): HResult; stdcall;
    function DuplicateSurface(lpDDSurface: IDirectDrawSurface; out lplpDupDDSurface: IDirectDrawSurface): HResult; stdcall;
    function EnumDisplayModes(dwFlags: DWORD; lpDDSurfaceDesc: PDDSurfaceDesc; lpContext: Pointer; lpEnumModesCallback: TDDEnumModesCallback): HResult; stdcall;
    function EnumSurfaces(dwFlags: DWORD; lpDDSD: PDDSurfaceDesc; lpContext: Pointer; lpEnumCallback: Pointer): HResult; stdcall;
    function FlipToGDISurface: HResult; stdcall;
    function GetCaps(lpDDDriverCaps: Pointer; lpDDHELCaps: Pointer): HResult; stdcall;
    function GetDisplayMode(var lpDDSurfaceDesc: TDDSurfaceDesc): HResult; stdcall;
    function GetFourCCCodes(var lpNumCodes: DWORD; lpCodes: PDWORD): HResult; stdcall;
    function GetGDISurface(out lplpGDIDDSSurface: IDirectDrawSurface): HResult; stdcall;
    function GetMonitorFrequency(var lpdwFrequency: DWORD): HResult; stdcall;
    function GetScanLine(var lpdwScanLine: DWORD): HResult; stdcall;
    function GetVerticalBlankStatus(var lpbIsInVB: BOOL): HResult; stdcall;
    function Initialize(lpGUID: PGUID): HResult; stdcall;
    function RestoreDisplayMode: HResult; stdcall;
    function SetCooperativeLevel(hWnd: HWND; dwFlags: DWORD): HResult; stdcall;
    function SetDisplayMode(dwWidth, dwHeight, dwBpp: DWORD): HResult; stdcall;
    function WaitForVerticalBlank(dwFlags: DWORD; hEvent: THandle): HResult; stdcall;
  end;

  IDirectDraw2 = interface(IUnknown)
    function Compact: HResult; stdcall;
    function CreateClipper(dwFlags: DWORD; out lplpDDClipper: IDirectDrawClipper; pUnkOuter: IUnknown): HResult; stdcall;
    function CreatePalette(dwFlags: DWORD; lpColorTable: Pointer; out lplpDDPalette: IDirectDrawPalette; pUnkOuter: IUnknown): HResult; stdcall;
    function CreateSurface(const lpDDSurfaceDesc: TDDSurfaceDesc; var lplpDDSurface: IDirectDrawSurface; pUnkOuter: IUnknown): HResult; stdcall;
    function DuplicateSurface(lpDDSurface: IDirectDrawSurface; out lplpDupDDSurface: IDirectDrawSurface): HResult; stdcall;
    function EnumDisplayModes(dwFlags: DWORD; lpDDSurfaceDesc: PDDSurfaceDesc; lpContext: Pointer; lpEnumModesCallback: TDDEnumModesCallback): HResult; stdcall;
    function EnumSurfaces(dwFlags: DWORD; lpDDSD: PDDSurfaceDesc; lpContext: Pointer; lpEnumCallback: Pointer): HResult; stdcall;
    function FlipToGDISurface: HResult; stdcall;
    function GetCaps(lpDDDriverCaps: Pointer; lpDDHELCaps: Pointer): HResult; stdcall;
    function GetDisplayMode(var lpDDSurfaceDesc: TDDSurfaceDesc): HResult; stdcall;
    function GetFourCCCodes(var lpNumCodes: DWORD; lpCodes: PDWORD): HResult; stdcall;
    function GetGDISurface(out lplpGDIDDSSurface: IDirectDrawSurface): HResult; stdcall;
    function GetMonitorFrequency(var lpdwFrequency: DWORD): HResult; stdcall;
    function GetScanLine(var lpdwScanLine: DWORD): HResult; stdcall;
    function GetVerticalBlankStatus(var lpbIsInVB: BOOL): HResult; stdcall;
    function Initialize(lpGUID: PGUID): HResult; stdcall;
    function RestoreDisplayMode: HResult; stdcall;
    function SetCooperativeLevel(hWnd: HWND; dwFlags: DWORD): HResult; stdcall;
    function SetDisplayMode(dwWidth, dwHeight, dwBpp, dwRefreshRate, dwFlags: DWORD): HResult; stdcall;
    function WaitForVerticalBlank(dwFlags: DWORD; hEvent: THandle): HResult; stdcall;
    function GetAvailableVidMem(lpDDSCaps: PDDSCaps; var lpdwTotal, lpdwFree: DWORD): HResult; stdcall;
  end;

  IDirectDrawPalette = interface(IUnknown)
    function GetCaps(var lpdwCaps: DWORD): HResult; stdcall;
    function GetEntries(dwFlags, dwBase, dwNumEntries: DWORD; lpEntries: Pointer): HResult; stdcall;
    function Initialize(lpDD: IDirectDraw; dwFlags: DWORD; lpDDColorTable: Pointer): HResult; stdcall;
    function SetEntries(dwFlags, dwStartingEntry, dwCount: DWORD; lpEntries: Pointer): HResult; stdcall;
  end;

  IDirectDrawClipper = interface(IUnknown)
    function GetClipList(lpRect: PRect; lpClipList: Pointer; var lpdwSize: DWORD): HResult; stdcall;
    function GetHWnd(var lphWnd: HWND): HResult; stdcall;
    function Initialize(lpDD: IDirectDraw; dwFlags: DWORD): HResult; stdcall;
    function IsClipListChanged(var lpbChanged: BOOL): HResult; stdcall;
    function SetClipList(lpClipList: Pointer; dwFlags: DWORD): HResult; stdcall;
    function SetHWnd(dwFlags: DWORD; hWnd: HWND): HResult; stdcall;
  end;

  IDirectDrawSurface = interface(IUnknown)
    function AddAttachedSurface(lpDDSAttachedSurface: IDirectDrawSurface): HResult; stdcall;
    function AddOverlayDirtyRect(const lpRect: TRect): HResult; stdcall;
    function Blt(lpDestRect: PRect; lpDDSrcSurface: IDirectDrawSurface; lpSrcRect: PRect; dwFlags: DWORD; lpDDBltFx: PDDBltFX): HResult; stdcall;
    function BltBatch(lpDDBltBatch: Pointer; dwCount: DWORD; dwFlags: DWORD): HResult; stdcall;
    function BltFast(dwX, dwY: DWORD; lpDDSrcSurface: IDirectDrawSurface; lpSrcRect: PRect; dwTrans: DWORD): HResult; stdcall;
    function DeleteAttachedSurface(dwFlags: DWORD; lpDDSAttachedSurface: IDirectDrawSurface): HResult; stdcall;
    function EnumAttachedSurfaces(lpContext: Pointer; lpEnumSurfacesCallback: Pointer): HResult; stdcall;
    function EnumOverlayZOrders(dwFlags: DWORD; lpContext: Pointer; lpfnCallback: Pointer): HResult; stdcall;
    function Flip(lpDDSurfaceTargetOverride: IDirectDrawSurface; dwFlags: DWORD): HResult; stdcall;
    function GetAttachedSurface(var lpDDSCaps: TDDSCaps; var lplpDDAttachedSurface: IDirectDrawSurface): HResult; stdcall;
    function GetBltStatus(dwFlags: DWORD): HResult; stdcall;
    function GetCaps(var lpDDSCaps: TDDSCaps): HResult; stdcall;
    function GetClipper(out lplpDDClipper: IDirectDrawClipper): HResult; stdcall;
    function GetColorKey(dwFlags: DWORD; var lpDDColorKey: TDDColorKey): HResult; stdcall;
    function GetDC(var lphDC: HDC): HResult; stdcall;
    function GetFlipStatus(dwFlags: DWORD): HResult; stdcall;
    function GetOverlayPosition(var lplX, lplY: Longint): HResult; stdcall;
    function GetPalette(out lplpDDPalette: IDirectDrawPalette): HResult; stdcall;
    function GetPixelFormat(var lpDDPixelFormat: TDDPixelFormat): HResult; stdcall;
    function GetSurfaceDesc(var lpDDSurfaceDesc: TDDSurfaceDesc): HResult; stdcall;
    function Initialize(lpDD: IDirectDraw; var lpDDSurfaceDesc: TDDSurfaceDesc): HResult; stdcall;
    function IsLost: HResult; stdcall;
    function Lock(lpDestRect: PRect; var lpDDSurfaceDesc: TDDSurfaceDesc; dwFlags: DWORD; hEvent: THandle): HResult; stdcall;
    function ReleaseDC(hDC: HDC): HResult; stdcall;
    function Restore: HResult; stdcall;
    function SetClipper(lpDDClipper: IDirectDrawClipper): HResult; stdcall;
    function SetColorKey(dwFlags: DWORD; lpDDColorKey: PDDColorKey): HResult; stdcall;
    function SetOverlayPosition(lX, lY: Longint): HResult; stdcall;
    function SetPalette(lpDDPalette: IDirectDrawPalette): HResult; stdcall;
    function Unlock(lpSurfaceData: Pointer): HResult; stdcall;
    function UpdateOverlay(lpSrcRect: PRect; lpDDDestSurface: IDirectDrawSurface; lpDestRect: PRect; dwFlags: DWORD; lpDDOverlayFx: Pointer): HResult; stdcall;
    function UpdateOverlayDisplay(dwFlags: DWORD): HResult; stdcall;
    function UpdateOverlayZOrder(dwFlags: DWORD; lpDDSReference: IDirectDrawSurface): HResult; stdcall;
  end;

  IDirectDrawSurface2 = interface(IUnknown)
    function AddAttachedSurface(lpDDSAttachedSurface: IDirectDrawSurface2): HResult; stdcall;
    function AddOverlayDirtyRect(const lpRect: TRect): HResult; stdcall;
    function Blt(lpDestRect: PRect; lpDDSrcSurface: IDirectDrawSurface2; lpSrcRect: PRect; dwFlags: DWORD; lpDDBltFx: PDDBltFX): HResult; stdcall;
    function BltBatch(lpDDBltBatch: Pointer; dwCount: DWORD; dwFlags: DWORD): HResult; stdcall;
    function BltFast(dwX, dwY: DWORD; lpDDSrcSurface: IDirectDrawSurface2; lpSrcRect: PRect; dwTrans: DWORD): HResult; stdcall;
    function DeleteAttachedSurface(dwFlags: DWORD; lpDDSAttachedSurface: IDirectDrawSurface2): HResult; stdcall;
    function EnumAttachedSurfaces(lpContext: Pointer; lpEnumSurfacesCallback: Pointer): HResult; stdcall;
    function EnumOverlayZOrders(dwFlags: DWORD; lpContext: Pointer; lpfnCallback: Pointer): HResult; stdcall;
    function Flip(lpDDSurfaceTargetOverride: IDirectDrawSurface2; dwFlags: DWORD): HResult; stdcall;
    function GetAttachedSurface(var lpDDSCaps: TDDSCaps; var lplpDDAttachedSurface: IDirectDrawSurface2): HResult; stdcall;
    function GetBltStatus(dwFlags: DWORD): HResult; stdcall;
    function GetCaps(var lpDDSCaps: TDDSCaps): HResult; stdcall;
    function GetClipper(out lplpDDClipper: IDirectDrawClipper): HResult; stdcall;
    function GetColorKey(dwFlags: DWORD; var lpDDColorKey: TDDColorKey): HResult; stdcall;
    function GetDC(var lphDC: HDC): HResult; stdcall;
    function GetFlipStatus(dwFlags: DWORD): HResult; stdcall;
    function GetOverlayPosition(var lplX, lplY: Longint): HResult; stdcall;
    function GetPalette(out lplpDDPalette: IDirectDrawPalette): HResult; stdcall;
    function GetPixelFormat(var lpDDPixelFormat: TDDPixelFormat): HResult; stdcall;
    function GetSurfaceDesc(var lpDDSurfaceDesc: TDDSurfaceDesc): HResult; stdcall;
    function Initialize(lpDD: IDirectDraw; var lpDDSurfaceDesc: TDDSurfaceDesc): HResult; stdcall;
    function IsLost: HResult; stdcall;
    function Lock(lpDestRect: PRect; var lpDDSurfaceDesc: TDDSurfaceDesc; dwFlags: DWORD; hEvent: THandle): HResult; stdcall;
    function ReleaseDC(hDC: HDC): HResult; stdcall;
    function Restore: HResult; stdcall;
    function SetClipper(lpDDClipper: IDirectDrawClipper): HResult; stdcall;
    function SetColorKey(dwFlags: DWORD; lpDDColorKey: PDDColorKey): HResult; stdcall;
    function SetOverlayPosition(lX, lY: Longint): HResult; stdcall;
    function SetPalette(lpDDPalette: IDirectDrawPalette): HResult; stdcall;
    function Unlock(lpSurfaceData: Pointer): HResult; stdcall;
    function UpdateOverlay(lpSrcRect: PRect; lpDDDestSurface: IDirectDrawSurface2; lpDestRect: PRect; dwFlags: DWORD; lpDDOverlayFx: Pointer): HResult; stdcall;
    function UpdateOverlayDisplay(dwFlags: DWORD): HResult; stdcall;
    function UpdateOverlayZOrder(dwFlags: DWORD; lpDDSReference: IDirectDrawSurface2): HResult; stdcall;
    function GetDDInterface(out lplpDD: IUnknown): HResult; stdcall;
    function PageLock(dwFlags: DWORD): HResult; stdcall;
    function PageUnlock(dwFlags: DWORD): HResult; stdcall;
  end;

  IDirectDrawSurface3 = interface(IUnknown)
    function AddAttachedSurface(lpDDSAttachedSurface: IDirectDrawSurface3): HResult; stdcall;
    function AddOverlayDirtyRect(const lpRect: TRect): HResult; stdcall;
    function Blt(lpDestRect: PRect; lpDDSrcSurface: IDirectDrawSurface3; lpSrcRect: PRect; dwFlags: DWORD; lpDDBltFx: PDDBltFX): HResult; stdcall;
    function BltBatch(lpDDBltBatch: Pointer; dwCount: DWORD; dwFlags: DWORD): HResult; stdcall;
    function BltFast(dwX, dwY: DWORD; lpDDSrcSurface: IDirectDrawSurface3; lpSrcRect: PRect; dwTrans: DWORD): HResult; stdcall;
    function DeleteAttachedSurface(dwFlags: DWORD; lpDDSAttachedSurface: IDirectDrawSurface3): HResult; stdcall;
    function EnumAttachedSurfaces(lpContext: Pointer; lpEnumSurfacesCallback: Pointer): HResult; stdcall;
    function EnumOverlayZOrders(dwFlags: DWORD; lpContext: Pointer; lpfnCallback: Pointer): HResult; stdcall;
    function Flip(lpDDSurfaceTargetOverride: IDirectDrawSurface3; dwFlags: DWORD): HResult; stdcall;
    function GetAttachedSurface(var lpDDSCaps: TDDSCaps; var lplpDDAttachedSurface: IDirectDrawSurface3): HResult; stdcall;
    function GetBltStatus(dwFlags: DWORD): HResult; stdcall;
    function GetCaps(var lpDDSCaps: TDDSCaps): HResult; stdcall;
    function GetClipper(out lplpDDClipper: IDirectDrawClipper): HResult; stdcall;
    function GetColorKey(dwFlags: DWORD; var lpDDColorKey: TDDColorKey): HResult; stdcall;
    function GetDC(var lphDC: HDC): HResult; stdcall;
    function GetFlipStatus(dwFlags: DWORD): HResult; stdcall;
    function GetOverlayPosition(var lplX, lplY: Longint): HResult; stdcall;
    function GetPalette(out lplpDDPalette: IDirectDrawPalette): HResult; stdcall;
    function GetPixelFormat(var lpDDPixelFormat: TDDPixelFormat): HResult; stdcall;
    function GetSurfaceDesc(var lpDDSurfaceDesc: TDDSurfaceDesc): HResult; stdcall;
    function Initialize(lpDD: IDirectDraw; var lpDDSurfaceDesc: TDDSurfaceDesc): HResult; stdcall;
    function IsLost: HResult; stdcall;
    function Lock(lpDestRect: PRect; var lpDDSurfaceDesc: TDDSurfaceDesc; dwFlags: DWORD; hEvent: THandle): HResult; stdcall;
    function ReleaseDC(hDC: HDC): HResult; stdcall;
    function Restore: HResult; stdcall;
    function SetClipper(lpDDClipper: IDirectDrawClipper): HResult; stdcall;
    function SetColorKey(dwFlags: DWORD; lpDDColorKey: PDDColorKey): HResult; stdcall;
    function SetOverlayPosition(lX, lY: Longint): HResult; stdcall;
    function SetPalette(lpDDPalette: IDirectDrawPalette): HResult; stdcall;
    function Unlock(lpSurfaceData: Pointer): HResult; stdcall;
    function UpdateOverlay(lpSrcRect: PRect; lpDDDestSurface: IDirectDrawSurface3; lpDestRect: PRect; dwFlags: DWORD; lpDDOverlayFx: Pointer): HResult; stdcall;
    function UpdateOverlayDisplay(dwFlags: DWORD): HResult; stdcall;
    function UpdateOverlayZOrder(dwFlags: DWORD; lpDDSReference: IDirectDrawSurface3): HResult; stdcall;
    function GetDDInterface(out lplpDD: IUnknown): HResult; stdcall;
    function PageLock(dwFlags: DWORD): HResult; stdcall;
    function PageUnlock(dwFlags: DWORD): HResult; stdcall;
    function SetSurfaceDesc(const lpDDSD: TDDSurfaceDesc; dwFlags: DWORD): HResult; stdcall;
  end;

  IDirectDrawColorControl = interface(IUnknown)
    function GetColorControls(lpColorControl: Pointer): HResult; stdcall;
    function SetColorControls(lpColorControl: Pointer): HResult; stdcall;
  end;

const
  CLSID_DirectDraw: TGUID = (D1: $D7B70EE0; D2: $4340; D3: $11CF; D4: ($B0, $63, $00, $20, $AF, $C2, $CD, $35));
  CLSID_DirectDrawClipper: TGUID = (D1: $593817A0; D2: $7DB3; D3: $11CF; D4: ($A2, $DE, $00, $AA, $00, $B9, $33, $56));
  IID_IDirectDraw: TGUID = (D1: $6C14DB80; D2: $A733; D3: $11CE; D4: ($A5, $21, $00, $20, $AF, $0B, $E5, $60));
  IID_IDirectDraw2: TGUID = (D1: $B3A6F3E0; D2: $2B43; D3: $11CF; D4: ($A2, $DE, $00, $AA, $00, $B9, $33, $56));
  IID_IDirectDrawSurface: TGUID = (D1: $6C14DB81; D2: $A733; D3: $11CE; D4: ($A5, $21, $00, $20, $AF, $0B, $E5, $60));
  IID_IDirectDrawSurface2: TGUID = (D1: $57805885; D2: $6EEC; D3: $11CF; D4: ($94, $41, $A8, $23, $03, $C1, $0E, $27));
  IID_IDirectDrawSurface3: TGUID = (D1: $DA044E00; D2: $69B2; D3: $11D0; D4: ($A1, $D5, $00, $AA, $00, $B8, $DF, $BB));
  IID_IDirectDrawPalette: TGUID = (D1: $6C14DB84; D2: $A733; D3: $11CE; D4: ($A5, $21, $00, $20, $AF, $0B, $E5, $60));
  IID_IDirectDrawClipper: TGUID = (D1: $6C14DB85; D2: $A733; D3: $11CE; D4: ($A5, $21, $00, $20, $AF, $0B, $E5, $60));
  IID_IDirectDrawColorControl: TGUID = (D1: $4B9F0EE0; D2: $0D7E; D3: $11D0; D4: ($9B, $06, $00, $A0, $C9, $03, $A3, $B8));

var
  DirectDrawCreate: function(lpGUID: PGUID; out lplpDD: IDirectDraw; pUnkOuter: IUnknown): HResult; stdcall;
  DirectDrawEnumerate: function(lpCallback: Pointer; lpContext: Pointer): HResult; stdcall;
  DirectDrawCreateClipper: function(dwFlags: DWORD; out lplpDDClipper: IDirectDrawClipper; pUnkOuter: IUnknown): HResult; stdcall;

type
  { GFXE.TGFXEPalette (instance size 1032): +4 FPixelFormatID, +8 FEntries (256 x 4 bytes). }
  PPaletteEntry = ^TPaletteEntry;
  TPaletteEntry = packed record
    case Integer of
      0: (R, G, B, Reserved: Byte);
      1: (W: Word);
      2: (Value: Integer);
  end;
  TPaletteEntries = array[0..255] of TPaletteEntry;

  TGFXEPalette = class(TObject)
  public
    PixelFormatID: Integer;
    Entries: TPaletteEntries;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure Assign(Source: TGFXEPalette);
    function GetEntry(Index: Integer): PPaletteEntry;
    function Remap(NewPixelFormatID: Integer): HResult;
    function GetNearestColor(Color: TColor): Integer;
    function Compare(Palette: TGFXEPalette): Boolean;
  end;

  { The description of a locked surface (60 bytes): Width, Height, BitCount, Pitch, ClipRect,
    Data, Palette, PixelFormatID, RMask, GMask, BMask, AMask }
  PSurfaceDesc = ^TSurfaceDesc;
  TSurfaceDesc = record
    Width: Integer;
    Height: Integer;
    BitCount: Integer;
    Pitch: Integer;
    ClipRect: TRect;
    Data: Pointer;
    Palette: TGFXEPalette;
    PixelFormatID: Integer;
    RMask: Integer;
    GMask: Integer;
    BMask: Integer;
    AMask: Integer;
  end;

  { GFXE.TSurface (instance size 4): the abstract surface; GetWidth and GetHeight are abstract.
    VMT: GetColor, GetPixelInfo, GetWidth, GetHeight, GetPixelFormatID, Blt, BltClipped,
    BltColorKey, BltColorKeyClipped, BltDC, BltStretch, Lock, Unlock, LockEx, UnlockEx,
    UpdatePalette, Resize, Cls }
  TSurface = class(TObject)
  public
    function GetColor(X, Y: Integer): TColor; virtual;
    function GetPixelInfo(X, Y: Integer): Integer; virtual;
    function GetWidth: Integer; virtual; abstract;
    function GetHeight: Integer; virtual; abstract;
    function GetPixelFormatID: Integer; virtual;
    function Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; virtual;
    function BltClipped(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; virtual;
    function BltColorKey(Dest: TSurface; SrcRect: PRect; X, Y: Integer; ColorKey: TColor): HResult; virtual;
    function BltColorKeyClipped(Dest: TSurface; SrcRect: PRect; X, Y: Integer; ColorKey: TColor): HResult; virtual;
    function BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult; virtual;
    function BltStretch(Dest: TSurface; SrcRect, DestRect: PRect): HResult; virtual;
    function Lock(var SD: TSurfaceDesc): HResult; virtual;
    function Unlock: HResult; virtual;
    function LockEx(var SD: TSurfaceDesc; const R: TRect): HResult; virtual;
    function UnlockEx(const SD: TSurfaceDesc): HResult; virtual;
    function UpdatePalette: HResult; virtual;
    function Resize(AWidth, AHeight: Integer): HResult; virtual;
    function Cls(Color: TColor): HResult; virtual;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property PixelFormatID: Integer read GetPixelFormatID;
  end;

  { GFXE.TDataSurface (instance size 44): a surface in memory. +4 FWidth, +8 FHeight, +$C FMem,
    +$10 FData (FMem aligned to 8), +$14 FBitCount (Byte), +$18 FPitch, +$1C FPixelFormatID,
    +$20 FX, +$24 FY (origin of the captured rectangle), +$28 FPalette. }
  TDataSurface = class(TSurface)
  private
    FWidth: Integer;
    FHeight: Integer;
    FMem: Pointer;
    FData: Pointer;
    FBitCount: Byte;
    FPitch: Integer;
    FPixelFormatID: Integer;
    FX: Integer;
    FY: Integer;
    FPalette: TGFXEPalette;
  public
    constructor Create(AWidth, AHeight, APixelFormatID: Integer; APalette: TGFXEPalette);
    constructor CreateFromSurface(Surface: TSurface; R: PRect);
    destructor Destroy; override;
    function GetPixelFormatID: Integer; override;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function Lock(var SD: TSurfaceDesc): HResult; override;
    function Unlock: HResult; override;
    function CaptureSurface(Surface: TSurface; R: PRect): HResult;
    procedure SetPalette(Palette: TGFXEPalette);
    function Resize(AWidth, AHeight: Integer): HResult; override;
    property Data: Pointer read FData;
    property Pitch: Integer read FPitch;
    property Palette: TGFXEPalette read FPalette write SetPalette;
  end;

  { GFXE.TDIBSurface (instance size 1100): a DIB section of any format (8, 16 or 24 bit). +4
    FHandle, +8 FWidth, +$C FHeight, +$10 FMem, +$14 FBits, +$18 FPitch, +$1C FPixelFormatID,
    +$20 FInfo (BITMAPINFOHEADER and 256 colors), +$448 FPalette. }
  TDIBSurface = class(TSurface)
  private
    FHandle: HBITMAP;
    FWidth: Integer;
    FHeight: Integer;
    FMem: Pointer;
    FBits: Pointer;
    FPitch: Integer;
    FPixelFormatID: Integer;
    FInfo: TBitmapInfoHeader;
    FColors: array[0..255] of TRGBQuad;
    FPalette: TGFXEPalette;
  public
    destructor Destroy; override;
    function GetBITMAPINFO: PBitmapInfo;
    function GetBITMAPINFOHEADER: PBitmapInfoHeader;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    procedure Clear;
    function UpdatePalette: HResult; override;
    function Setup(AWidth, AHeight, APixelFormatID: Integer; APalette: TGFXEPalette): HResult;
    function Resize(AWidth, AHeight: Integer): HResult; override;
    function Lock(var SD: TSurfaceDesc): HResult; override;
    function Unlock: HResult; override;
    function Cls(Color: TColor): HResult; override;
    function Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; override;
    procedure SaveToBMP24(const FileName: string);
    property Handle: HBITMAP read FHandle;
    property Bits: Pointer read FBits;
    property Pitch: Integer read FPitch;
    property Palette: TGFXEPalette read FPalette;
  end;

  { GFXE.TDIB08Surface (instance size 1092): an 8 bit bitmap in memory (bottom-up: the pitch is
    negative). +4 FWidth, +8 FHeight, +$C FMem, +$10 FBits, +$14 FPitch, +$18 FInfo (header and
    256 colors), +$440 FPalette. }
  TDIB08Surface = class(TSurface)
  private
    FWidth: Integer;
    FHeight: Integer;
    FMem: Pointer;
    FBits: Pointer;
    FPitch: Integer;
    FInfo: TBitmapInfoHeader;
    FColors: array[0..255] of TRGBQuad;
    FPalette: TGFXEPalette;
  public
    constructor Create(AWidth, AHeight: Integer; APalette: TGFXEPalette);
    destructor Destroy; override;
    function GetPixelFormatID: Integer; override;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function UpdatePalette: HResult; override;
    function Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; override;
    function BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult; override;
    function Lock(var SD: TSurfaceDesc): HResult; override;
    function Unlock: HResult; override;
    function Resize(AWidth, AHeight: Integer): HResult; override;
    function Cls(Color: TColor): HResult; override;
    procedure SetPalette(Palette: TGFXEPalette);
    property Palette: TGFXEPalette read FPalette write SetPalette;
  end;

  { GFXE.TDIB16Surface (instance size 80): a 16 bit DIB section (555 or 565). +4 FHandle, +8
    FWidth, +$C FHeight, +$10 FBits, +$14 FPitch, +$18 FPixelFormatID, +$1C FInfo, +$44 FMasks. }
  TDIB16Surface = class(TSurface)
  private
    FHandle: HBITMAP;
    FWidth: Integer;
    FHeight: Integer;
    FBits: Pointer;
    FPitch: Integer;
    FPixelFormatID: Integer;
    FInfo: TBitmapInfoHeader;
    FMasks: array[0..2] of Integer;
    procedure SetPixelFormatID(Value: Integer);
  public
    constructor Create(AWidth, AHeight, APixelFormatID: Integer);
    destructor Destroy; override;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function GetPixelFormatID: Integer; override;
    function Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; override;
    function BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult; override;
    function Lock(var SD: TSurfaceDesc): HResult; override;
    function Unlock: HResult; override;
    function Cls(Color: TColor): HResult; override;
    function Resize(AWidth, AHeight: Integer): HResult; override;
    property Handle: HBITMAP read FHandle;
    property PixelFormatID: Integer read FPixelFormatID write SetPixelFormatID;
  end;

  { GFXE.TDIB24Surface (instance size 64): a 24 bit DIB section. +4 FHandle, +8 FWidth, +$C
    FHeight, +$10 FBits, +$14 FPitch, +$18 FInfo. }
  TDIB24Surface = class(TSurface)
  private
    FHandle: HBITMAP;
    FWidth: Integer;
    FHeight: Integer;
    FBits: Pointer;
    FPitch: Integer;
    FInfo: TBitmapInfoHeader;
  public
    constructor Create(AWidth, AHeight: Integer);
    destructor Destroy; override;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function GetBMPInfo: PBitmapInfoHeader;
    function Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; override;
    function BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult; override;
    function Cls(Color: TColor): HResult; override;
    function Lock(var SD: TSurfaceDesc): HResult; override;
    function Unlock: HResult; override;
    function Resize(AWidth, AHeight: Integer): HResult; override;
    property Handle: HBITMAP read FHandle;
  end;

  { GFXE.TDIB32Surface (instance size 64): a 32 bit bitmap in memory (bottom-up). +4 FWidth, +8
    FHeight, +$C FMem, +$10 FBits, +$14 FPitch, +$18 FInfo. }
  TDIB32Surface = class(TSurface)
  private
    FWidth: Integer;
    FHeight: Integer;
    FMem: Pointer;
    FBits: Pointer;
    FPitch: Integer;
    FInfo: TBitmapInfoHeader;
  public
    constructor Create(AWidth, AHeight: Integer);
    destructor Destroy; override;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; override;
    function BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult; override;
    function Lock(var SD: TSurfaceDesc): HResult; override;
    function Unlock: HResult; override;
    function Cls(Color: TColor): HResult; override;
    function Resize(AWidth, AHeight: Integer): HResult; override;
  end;

  { GFXE.TGDISurface (instance size 8): a window drawn through GDI. +4 FHandle. Two more
    virtuals: GetHandle, SetHandle. }
  TGDISurface = class(TSurface)
  private
    FHandle: HWND;
  public
    constructor Create(AHandle: HWND);
    function GetHandle: HWND; virtual;
    procedure SetHandle(Value: HWND); virtual;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; override;
    function BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult; override;
    function Resize(AWidth, AHeight: Integer): HResult; override;
    function Cls(Color: TColor): HResult; override;
    property Handle: HWND read GetHandle write SetHandle;
  end;

  TDDrawSurfaceStatus = set of (ssVideoMemory, ssLocked, ssPrimary, ssCreated, ssComplex);
  TDDSCreationFlags = set of (cfVideoMemory, cfSystemMemory);

  { GFXE.TDDrawSurface (instance size 100): a DirectDraw surface. +4 FOnSurfaceLost, +$C
    FPixelFormatID, +$10 FWidth, +$14 FHeight, +$18 FSurface, +$1C FCreationFlags, +$1D FStatus,
    +$20 FLockCount, +$24 FLockExCount, +$28 FSurfaceDesc (the description of the lock). }
  TDDrawSurface = class(TSurface)
  protected
    FOnSurfaceLost: TNotifyEvent;
    FPixelFormatID: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FSurface: IDirectDrawSurface2;
    FCreationFlags: TDDSCreationFlags;
    FStatus: TDDrawSurfaceStatus;
    FLockCount: Integer;
    FLockExCount: Integer;
    FSurfaceDesc: TSurfaceDesc;
  public
    function CreateSurface(AWidth, AHeight, APixelFormatID: Integer; AFlags: TDDSCreationFlags): HResult;
    destructor Destroy; override;
    function Lost: Boolean;
    function Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult; override;
    function BltColorKey(Dest: TSurface; SrcRect: PRect; X, Y: Integer; ColorKey: TColor): HResult; override;
    function GetPixelFormatID: Integer; override;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function Lock(var SD: TSurfaceDesc): HResult; override;
    function Unlock: HResult; override;
    function LockEx(var SD: TSurfaceDesc; const R: TRect): HResult; override;
    function UnlockEx(const SD: TSurfaceDesc): HResult; override;
    function Resize(AWidth, AHeight: Integer): HResult; override;
    function Restore: HResult;
    function AsyncCls(Color: TColor): HResult;
    function Cls(Color: TColor): HResult; override;
    property Surface: IDirectDrawSurface2 read FSurface;
    property Status: TDDrawSurfaceStatus read FStatus;
    property CreationFlags: TDDSCreationFlags read FCreationFlags;
    property OnSurfaceLost: TNotifyEvent read FOnSurfaceLost write FOnSurfaceLost;
  end;

  { GFXE.TRectangle (instance size 20): +4 Rect. }
  TRectangle = class(TObject)
  public
    Rect: TRect;
    constructor Create(ALeft, ATop, ARight, ABottom: Integer);
    constructor CreateRect(const R: TRect);
  end;

  { GFXE.TRectangleList (instance size 16): a TList of TRectangle, owning them. }
  TRectangleList = class(TList)
  private
    function GetRectangle(Index: Integer): TRectangle;
  public
    destructor Destroy; override;
    property Rectangles[Index: Integer]: TRectangle read GetRectangle;
  end;

  TOnDrawRectEvent = procedure(Sender: TObject; const R: TRect) of object;

  { GFXE.TDrawPanel (instance size 324): a panel that paints through OnDraw. +$138
    FEraseBkgndEnabled, +$13C FOnDraw. }
  TDrawPanel = class(TCustomPanel)
  private
    FEraseBkgndEnabled: Boolean;
    FOnDraw: TOnDrawRectEvent;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override; property Canvas; { AoWEd 0041CBCB }
  published
    property Color;
    property Align;
    property OnDraw: TOnDrawRectEvent read FOnDraw write FOnDraw;
    property EraseBkgndEnabled: Boolean read FEraseBkgndEnabled write FEraseBkgndEnabled;
  end;

  { GFXE.TImageFile (instance size 4): an image file format, all class functions. }
  TImageFile = class(TObject)
  public
    class function GetName: string; virtual; abstract;
    class function GetExtension: string; virtual; abstract;
    class function GetDescription: string; virtual; abstract;
    class function GetPixelFormatID(const FileName: string): Integer; virtual; abstract;
    class function CreateSurface(const FileName: string): TSurface; virtual; abstract;
    class function LoadToSurfaceDesc(const FileName: string; var SD: TSurfaceDesc; X, Y: Integer): HResult; virtual; abstract;
  end;
  TImageFileClass = class of TImageFile;

  { GFXE.TOpenImageFileDialog (instance size 144): a TOpenDialog whose filter lists the
    registered image file classes. }
  TOpenImageFileDialog = class(TOpenDialog)
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { GFXE.TDisplayModeItem (instance size 16): +4 PixelFormatID, +8 Width, +$C Height. }
  TDisplayModeItem = class(TObject)
  public
    PixelFormatID: Integer;
    Width: Integer;
    Height: Integer;
  end;

  { GFXE.TDisplayModeList (instance size 8): +4 FList. }
  TDisplayModeList = class(TObject)
  private
    FList: TList;
    function GetItems(Index: Integer): TDisplayModeItem;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(AWidth, AHeight, APixelFormatID: Integer);
    procedure Delete(Index: Integer);
    property Items[Index: Integer]: TDisplayModeItem read GetItems;
    property Count: Integer read GetCount;
  end;

  { GFXE.TBlendTable (instance size 12): +4 FBits, +8 FTable. VMT: Copy, Assign. }
  TBlendTable = class(TObject)
  private
    FBits: Integer;
    FTable: Pointer;
  public
    function Copy: TBlendTable; virtual; abstract;
    procedure Assign(Source: TBlendTable); virtual; abstract;
    procedure Initialize(ABits: Integer; ATable: Pointer);
    property Bits: Integer read FBits;
    property Table: Pointer read FTable;
  end;

  { GFXE.TBlendTable5Bit (instance size 1036): +$C Table (32 x 32 bytes). }
  TBlendTable5Bit = class(TBlendTable)
  public
    Table: array[0..31, 0..31] of Byte;
    constructor Create;
    procedure Assign(Source: TBlendTable); override;
    function Copy: TBlendTable; override;
  end;

  { GFXE.TBlendTableList (instance size 8): +4 FList. }
  TBlendTableList = class(TObject)
  private
    FList: TList;
    function GetCount: Integer;
    function GetTables(Index: Integer): TBlendTable;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(Table: TBlendTable);
    procedure Delete(Index: Integer);
    property Count: Integer read GetCount;
    property Tables[Index: Integer]: TBlendTable read GetTables;
  end;

  TGenerateBlendTableProc = procedure(Table: TBlendTable; Value: Single);

  { GFXE.TLookupBlendTableCollection100 (instance size 412): +4 FTables, +8 Lookup (101
    tables, indexed by percentage). }
  TLookupBlendTableCollection100 = class(TObject)
  private
    FTables: TBlendTableList;
  public { ImageLib's blitters read Lookup directly; adding lines here moves the Asserts below }
    Lookup: array[0..100] of TBlendTable;
    function GetLookupTables(Index: Integer): TBlendTable;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function GenerateLookupTables(Bits: Integer; Proc: TGenerateBlendTableProc; Count: Integer): Boolean;
    property Tables: TBlendTableList read FTables;
    property LookupTables[Index: Integer]: TBlendTable read GetLookupTables;
  end;

  TBltRectProc = procedure(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
  TProgressEvent = procedure(Sender: TObject; Percent: Integer; Param: Integer) of object;

var
  AlphaBlendTable: TLookupBlendTableCollection100;
  IntensityBlendTable: TLookupBlendTableCollection100;
  BrightenBlendTable: TLookupBlendTableCollection100;
  ShadowBlendTable: TLookupBlendTableCollection100;
  LinearAlphaBlendTable: TLookupBlendTableCollection100;

function GetImageFilesFilter: string;
function ValidImageFile(const FileName: string): Boolean;
function LoadImageFile(const FileName: string; var SD: TSurfaceDesc; X, Y: Integer): HResult;
function CreateSurfaceFromImageFile(const FileName: string): TSurface;
function GetImageFilePixelFormat(const FileName: string): Integer;
procedure RegisterImageFileClasses(AClasses: array of TImageFileClass);

procedure FPBltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RegisterBltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RepMovsdBltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure BltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure GetOptimalGFXESettings(ShowDialog: Boolean);
procedure RegisterBltProc(Proc: TBltRectProc; Name: string);
function BltSDRectClipped(const Src: TSurfaceDesc; SrcRect: TRect; const Dest: TSurfaceDesc; X, Y: Integer): HResult;
procedure BltTransparent565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure BltTransparent555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure BltColorKey16(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; ColorKey: Integer); pascal;
function BltSprite16(const Src: TSurfaceDesc; SrcRect: TRect; const Dest: TSurfaceDesc; X, Y: Integer; ColorKey: TColor): HResult;
function BltSpriteClipped16(const Src: TSurfaceDesc; SrcRect: TRect; const Dest: TSurfaceDesc; X, Y: Integer; ColorKey: TColor): HResult;
procedure BltStretched16(RowTable, ColTable: Pointer; Dst: Pointer; DstPitch, Width, Height: Integer); pascal;
function ColorFillSD(R: TRect; Color: TColor; const SD: TSurfaceDesc): HResult;
function RDTSC: Integer;
procedure FillInt(var Dest; Count, Value: Integer);
procedure FillTrippleByte(var Dest; Count, Value: Integer);
procedure FillWord(var Dest; Count, Value: Integer);
function GetPixelInfo(const SD: TSurfaceDesc; X, Y: Integer): Integer;
function MASKtoPFID(BitCount: Integer; RMask, GMask, BMask, AMask: Integer): Integer;
function PFIDtoMASK(PixelFormatID: Integer; var RMask, GMask, BMask, AMask: Integer): Integer;
procedure CreateSDfromSD(const Src: TSurfaceDesc; const R: TRect; var Dest: TSurfaceDesc);
function GetSurfaceRectangles(SD: TSurfaceDesc; TransparentColor: Integer; OnProgress: TProgressEvent): TRectangleList;
procedure MinimizeTransparentRect(const SD: TSurfaceDesc; const R: TRect; TransparentColor: Integer; var Result: TRect);
procedure MinimizeInvTransparentRect(const SD: TSurfaceDesc; const R: TRect; TransparentColor: Integer; var Result: TRect);
procedure DrawLine16(X1, Y1, X2, Y2, Skip: Integer; Color: Word; const SD: TSurfaceDesc);
procedure DrawLine(X1, Y1, X2, Y2, Skip: Integer; Color: TColor; const SD: TSurfaceDesc);

procedure RemapSurface16to16(Src, Dst: Pointer; Table: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface16to08(Src, Dst: Pointer; Table: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface16to32(Src, Dst: Pointer; Table: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface555to32(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface565to32(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface555to565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface565to555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface24to565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface24to555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface555to24(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface565to24(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface32to565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface32to555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
procedure RemapSurface08to565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Palette: TGFXEPalette); pascal;
procedure RemapSurface08to555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Palette: TGFXEPalette); pascal;
procedure RemapSurface08to24(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Palette: TGFXEPalette); pascal;
function RemapSurfacePart(const Src: TSurfaceDesc; SrcX, SrcY, Width, Height: Integer; const Dest: TSurfaceDesc; DestX, DestY: Integer): HResult;
function RemapSurface(Src, Dest: TSurface): HResult;
function Color2PixelInfo(Color: TColor; PixelFormatID: Integer; Palette: TGFXEPalette): Integer;
function PixelInfo2Color(PixelInfo: Integer; PixelFormatID: Integer; Palette: TGFXEPalette): TColor;
function RemapPixelInfo(PixelInfo: Integer; SrcPixelFormatID: Integer; SrcPalette: TGFXEPalette; DestPixelFormatID: Integer; DestPalette: TGFXEPalette): Integer;
function SaveSurfaceDescToBMP24(const SD: TSurfaceDesc; R: TRect; const FileName: string): HResult;
function DDSDtoSurfaceDesc(const DDSD: TDDSurfaceDesc; var SD: TSurfaceDesc): HResult;

procedure GenerateAlphaBlendTable(Table: TBlendTable; Alpha: Single);
procedure GenerateIntensityBlendTable(Table: TBlendTable; Intensity: Single);
procedure GenerateShadowBlendTable(Table: TBlendTable; Shadow: Single);
procedure GenerateBrightenBlendTable(Table: TBlendTable; Brighten: Single);
procedure BlendSurface555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Table: Pointer); pascal;
procedure BlendSurface565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Table: Pointer); pascal;
procedure BlendColorKey555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; ColorKey: Integer; Table: Pointer); pascal;
procedure BlendColorKey565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; ColorKey: Integer; Table: Pointer); pascal;
procedure BlendStretched555(RowTable, ColTable: Pointer; Dst: Pointer; DstPitch, Width, Height: Integer; Table: Pointer); pascal;
procedure BlendStretched565(RowTable, ColTable: Pointer; Dst: Pointer; DstPitch, Width, Height: Integer; Table: Pointer); pascal;

function GetErrorMsg(ErrorCode: HResult): string;
procedure SaveGFXESettingsToStream(Stream: TStream);
procedure LoadGFXESettingsFromStream(Stream: TStream);
procedure WriteGFXESettingsToRegistry(const Key: string);
procedure ReadGFXESettingsFromRegistry(const Key: string);
function GetPrimarySurfacePFID: Integer;
function DisplayModeSupported(Width, Height, PixelFormatID: Integer): Boolean;
procedure ListDisplayModes(List: TDisplayModeList; Width, Height, PixelFormatID: Integer);
procedure ForceOptimal16BitPixelFormatID(PixelFormatID: Integer);
function GetOptimalPixelFormatID(BitCount: Integer): Integer;
function DDStoPFID(Surface: IDirectDrawSurface): Integer;
function DirectDrawActivated: Boolean;
function DD: IDirectDraw2;
function MMXsupport: Boolean;
function GetElapsedMilliSeconds: Integer;
function GetElapsedMicroSeconds: Integer;
procedure Register;

implementation

uses
  GFXDiag, Grids;

const
  MaxBltProcs = 20;

type
  { The implementation list of image file classes (TList of TImageFileClass). }
  TImageFileClassList = class(TList)
  private
    function GetClasses(Index: Integer): TImageFileClass;
  public
    function FindClass(Ext: string): TImageFileClass;
    property Classes[Index: Integer]: TImageFileClass read GetClasses;
  end;

  { The blit timing test of GetOptimalGFXESettings }
  TBltTest = record
    Src: Pointer;
    Dst: Pointer;
    SrcPitch: Integer;
    DstPitch: Integer;
    Width: Integer;
    Height: Integer;
  end;

  TBltTestResult = record
    Index: Integer;
    Bandwidth: Integer;
  end;

var
  ForcedPixelFormatID: Integer;
  ImageFileClassList: TImageFileClassList;
  BltProcs: array[0..MaxBltProcs] of TBltRectProc;
  BltProcNames: array[0..MaxBltProcs] of string;
  { the blit routine indices chosen by GetOptimalGFXESettings: large and small blits, for
    qword, dword, word and misaligned source/destination pairs }
  OptimalBltProc: array[0..7] of Byte;
  BltProcCount: Integer;
  ModeCount: Integer;
  EnumDDSD: TDDSurfaceDesc;
  ListPixelFormatID: Integer;
  FDirectDrawActivated: Boolean;
  FDirectDraw: IDirectDraw2;
  PerformanceCounterAvailable: Boolean;
  PerformanceFrequency: Comp;

{ TImageFileClassList }

function TImageFileClassList.GetClasses(Index: Integer): TImageFileClass;
var
  P: Pointer;
begin
  P := Items[Index];
  Result := TImageFileClass(P);
end;

function TImageFileClassList.FindClass(Ext: string): TImageFileClass;
var
  I: Integer;
begin
  I := 0;
  if (Ext <> '') and (Ext[1] = '.') then
    Ext := Copy(Ext, 2, Length(Ext) - 1);
  while (I <> Count) and (CompareText(TImageFileClass(List^[I]).GetExtension, Ext) <> 0) do
    Inc(I);
  if I <> Count then
    Result := TImageFileClass(List^[I])
  else
    Result := nil;
end;

{ TOpenImageFileDialog }

constructor TOpenImageFileDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Filter := GetImageFilesFilter;
end;

procedure TOpenImageFileDialog.Loaded;
begin
  inherited Loaded;
  Filter := GetImageFilesFilter;
end;

function GetImageFilesFilter: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to ImageFileClassList.Count - 1 do
  begin
    if Result <> '' then Result := Result + '|';
    Result := Result + ImageFileClassList.Classes[I].GetDescription + '|*.' +
      ImageFileClassList.Classes[I].GetExtension;
  end;
end;

function ValidImageFile(const FileName: string): Boolean;
begin
  Result := ImageFileClassList.FindClass(ExtractFileExt(FileName)) <> nil;
end;

function LoadImageFile(const FileName: string; var SD: TSurfaceDesc; X, Y: Integer): HResult;
var
  C: TImageFileClass;
begin
  C := ImageFileClassList.FindClass(ExtractFileExt(FileName));
  if C <> nil then
    Result := C.LoadToSurfaceDesc(FileName, SD, X, Y)
  else
    Result := GFXE_NOTSUPPORTED;
end;

function CreateSurfaceFromImageFile(const FileName: string): TSurface;
var
  C: TImageFileClass;
begin
  C := ImageFileClassList.FindClass(ExtractFileExt(FileName));
  if C <> nil then
    Result := C.CreateSurface(FileName)
  else
    Result := nil;
end;

function GetImageFilePixelFormat(const FileName: string): Integer;
var
  C: TImageFileClass;
begin
  C := ImageFileClassList.FindClass(ExtractFileExt(FileName));
  if C <> nil then
    Result := C.GetPixelFormatID(FileName)
  else
    Result := 0;
end;

procedure RegisterImageFileClasses(AClasses: array of TImageFileClass);
var
  I: Integer;
begin
  for I := 0 to High(AClasses) do
    if ImageFileClassList.FindClass(AClasses[I].GetExtension) = nil then
      ImageFileClassList.Add(AClasses[I])
    else
      raise Exception.Create('ImageFile class with ' + AClasses[I].GetExtension +
        ' extension is already registered');
end;

{ The blitters: TBltRectProc (pascal calling convention, so that the first parameter has the
  highest stack address). MMXBltRect copies 32 bytes per step through mm0-mm3 (DB-encoded),
  FPBltRect through the FPU, RegisterBltRect through the integer registers, RepMovsdBltRect
  with rep movsd. BltRect picks the one measured fastest for the alignment. }

procedure MMXBltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4: Integer;
asm
        cld
        push    ebx
        push    esi
        push    edi
        mov     esi, Src
        mov     edi, Dst
        mov     edx, Width
        lea     ebx, [@@row]
        cmp     edx, 31
        js      @@small
        mov     ecx, esi
        add     ecx, 7
        and     ecx, $FFFFFFF8
        sub     ecx, esi
        mov     L1, ecx
        sub     edx, ecx
        mov     eax, edx
        shr     edx, 5
        and     eax, $1F
        mov     L2, edx
        mov     ecx, eax
        and     eax, 3
        shr     ecx, 2
        mov     L3, eax
        mov     L4, ecx
        mov     eax, esi
        mov     ebx, Height
        mov     edx, edi
        test    ebx, ebx
        je      @@exit
@@row:
        mov     ecx, L1
        rep     movsb
        mov     ecx, L2
        test    ecx, ecx
        je      @@rest
@@mmx:
        DB      $0F, $6F, $06           // movq  mm0, [esi]
        DB      $0F, $6F, $4E, $08      // movq  mm1, [esi+8]
        DB      $0F, $6F, $56, $10      // movq  mm2, [esi+16]
        DB      $0F, $6F, $5E, $18      // movq  mm3, [esi+24]
        lea     esi, [esi+32]
        DB      $0F, $7F, $07           // movq  [edi], mm0
        DB      $0F, $7F, $4F, $08      // movq  [edi+8], mm1
        DB      $0F, $7F, $57, $10      // movq  [edi+16], mm2
        DB      $0F, $7F, $5F, $18      // movq  [edi+24], mm3
        lea     edi, [edi+32]
        dec     ecx
        jne     @@mmx
@@rest:
        mov     ecx, L4
        rep     movsd
        mov     ecx, L3
        rep     movsb
        dec     ebx
        je      @@emms
        add     eax, SrcPitch
        add     edx, DstPitch
        mov     esi, eax
        mov     edi, edx
        jmp     @@row
@@small:
        test    edx, edx
        je      @@exit
        mov     eax, edx
        mov     ebx, Height
        shr     edx, 2
        and     eax, 3
        mov     L4, edx
        mov     L3, eax
        mov     eax, esi
        mov     edx, edi
@@srow:
        mov     ecx, L4
        rep     movsd
        mov     ecx, L3
        rep     movsb
        dec     ebx
        je      @@exit
        add     eax, SrcPitch
        add     edx, DstPitch
        mov     esi, eax
        mov     edi, edx
        jmp     @@srow
@@emms:
        DB      $0F, $77                // emms
        wait
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

procedure FPBltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4: Integer;
asm
        cld
        push    ebx
        push    esi
        push    edi
        mov     esi, Src
        mov     edi, Dst
        mov     edx, Width
        lea     ebx, [@@row]
        cmp     edx, 31
        js      @@small
        mov     ecx, esi
        add     ecx, 7
        and     ecx, $FFFFFFF8
        sub     ecx, esi
        mov     L1, ecx
        sub     edx, ecx
        mov     eax, edx
        shr     edx, 5
        and     eax, $1F
        mov     L2, edx
        mov     ecx, eax
        and     eax, 3
        shr     ecx, 2
        mov     L3, eax
        mov     L4, ecx
        mov     eax, esi
        mov     ebx, Height
        mov     edx, edi
        test    ebx, ebx
        je      @@exit
@@row:
        mov     ecx, L1
        rep     movsb
        mov     ecx, L2
        test    ecx, ecx
        je      @@rest
@@fp:
        fild    qword ptr [esi]
        fild    qword ptr [esi+8]
        fild    qword ptr [esi+16]
        fild    qword ptr [esi+24]
        lea     esi, [esi+32]
        fistp   qword ptr [edi+24]
        fistp   qword ptr [edi+16]
        fistp   qword ptr [edi+8]
        fistp   qword ptr [edi]
        lea     edi, [edi+32]
        dec     ecx
        jne     @@fp
@@rest:
        mov     ecx, L4
        rep     movsd
        mov     ecx, L3
        rep     movsb
        dec     ebx
        je      @@wait
        add     eax, SrcPitch
        add     edx, DstPitch
        mov     esi, eax
        mov     edi, edx
        jmp     @@row
@@small:
        test    edx, edx
        je      @@exit
        mov     eax, edx
        mov     ebx, Height
        shr     edx, 2
        and     eax, 3
        mov     L4, edx
        mov     L3, eax
        mov     eax, esi
        mov     edx, edi
@@srow:
        mov     ecx, L4
        rep     movsd
        mov     ecx, L3
        rep     movsb
        dec     ebx
        je      @@exit
        add     eax, SrcPitch
        add     edx, DstPitch
        mov     esi, eax
        mov     edi, edx
        jmp     @@srow
@@wait:
        wait
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

procedure RegisterBltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9: Integer;
asm
        push    ebx
        push    esi
        push    edi
        mov     esi, Src
        mov     edi, Dst
        mov     eax, esi
        mov     ebx, 4
        mov     ecx, Width
        sub     ebx, eax
        test    ecx, ecx
        je      @@exit
        add     eax, ecx
        and     eax, 3
        je      @@l1
        mov     L1, eax
        sub     ecx, eax
        lea     eax, [@@tail]
        jmp     @@l2
@@l1:
        lea     eax, [@@nextrow]
@@l2:
        and     ebx, 3
        sub     ecx, ebx
        shr     ecx, 2
        test    ecx, 1
        je      @@l3
        mov     L2, eax
        lea     eax, [@@dword]
@@l3:
        and     ecx, $FFFFFFFE
        je      @@l4
        shr     ecx, 1
        mov     L3, ecx
        mov     L4, eax
        lea     eax, [@@qwords]
@@l4:
        test    ebx, 3
        je      @@l5
        mov     L5, ebx
        mov     L6, eax
        lea     eax, [@@head]
@@l5:
        mov     L7, eax
        mov     ebx, Height
        mov     L8, esi
        test    ebx, ebx
        je      @@exit
        mov     L9, edi
        jmp     dword ptr L7
@@head:
        mov     ecx, L5
@@h1:
        mov     al, [esi]
        lea     esi, [esi+1]
        dec     ecx
        mov     [edi], al
        lea     edi, [edi+1]
        jne     @@h1
        jmp     dword ptr L6
@@qwords:
        mov     ecx, L3
@@q1:
        mov     eax, [esi]
        mov     edx, [esi+4]
        lea     esi, [esi+8]
        mov     [edi], eax
        mov     [edi+4], edx
        lea     edi, [edi+8]
        dec     ecx
        jne     @@q1
        jmp     dword ptr L4
@@dword:
        mov     eax, [esi]
        lea     esi, [esi+4]
        mov     [edi], eax
        lea     edi, [edi+4]
        jmp     dword ptr L2
@@tail:
        mov     ecx, L1
@@t1:
        mov     al, [esi]
        inc     esi
        dec     ecx
        mov     [edi], al
        lea     edi, [edi+1]
        jne     @@t1
@@nextrow:
        dec     ebx
        je      @@exit
        mov     esi, L8
        mov     edi, L9
        add     esi, SrcPitch
        add     edi, DstPitch
        mov     L8, esi
        mov     L9, edi
        jmp     dword ptr L7
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

procedure RepMovsdBltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3: Integer;
asm
        cld
        push    ebx
        push    esi
        push    edi
        mov     esi, Src
        mov     edi, Dst
        mov     edx, Width
        mov     eax, esi
        cmp     edx, 4
        js      @@small
        add     eax, edx
        and     eax, 3
        mov     L1, eax
        sub     edx, eax
        mov     ecx, edx
        shr     edx, 2
        and     ecx, 3
        mov     L2, edx
        mov     L3, ecx
        mov     eax, esi
        mov     ebx, Height
        mov     edx, edi
        test    ebx, ebx
        je      @@exit
@@row:
        mov     ecx, L3
        rep     movsb
        mov     ecx, L2
        rep     movsd
        mov     ecx, L1
        rep     movsb
        dec     ebx
        je      @@exit
        add     eax, SrcPitch
        add     edx, DstPitch
        mov     esi, eax
        mov     edi, edx
        jmp     @@row
@@small:
        test    edx, edx
        je      @@exit
        mov     L1, edx
        mov     ebx, Height
        mov     edx, edi
        test    ebx, ebx
        je      @@exit
@@srow:
        mov     ecx, L1
        rep     movsb
        dec     ebx
        je      @@exit
        add     eax, SrcPitch
        add     edx, DstPitch
        mov     esi, eax
        mov     edi, edx
        jmp     @@srow
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

procedure BltRect(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
asm
        push    ebx
        push    esi
        push    edi
        mov     esi, Width
        mov     edx, Dst
        mov     eax, Src
        cmp     esi, 64
        jle     @@small
        mov     ecx, eax
        mov     ebx, ecx
        and     ebx, 7
        mov     edi, edx
        and     edi, 7
        cmp     ebx, edi
        jne     @@l1
        xor     ecx, ecx
        mov     cl, byte ptr [OptimalBltProc+0]
        jmp     @@call
@@l1:
        mov     ebx, ecx
        and     ebx, 3
        mov     edi, edx
        and     edi, 3
        cmp     ebx, edi
        jne     @@l2
        xor     ecx, ecx
        mov     cl, byte ptr [OptimalBltProc+1]
        jmp     @@call
@@l2:
        and     ecx, 1
        mov     ebx, edx
        and     ebx, 1
        cmp     ecx, ebx
        jne     @@l3
        xor     ecx, ecx
        mov     cl, byte ptr [OptimalBltProc+2]
        jmp     @@call
@@l3:
        xor     ecx, ecx
        mov     cl, byte ptr [OptimalBltProc+3]
        jmp     @@call
@@small:
        mov     ecx, eax
        mov     ebx, ecx
        and     ebx, 7
        mov     edi, edx
        and     edi, 7
        cmp     ebx, edi
        jne     @@s1
        xor     ecx, ecx
        mov     cl, byte ptr [OptimalBltProc+4]
        jmp     @@call
@@s1:
        mov     ebx, ecx
        and     ebx, 3
        mov     edi, edx
        and     edi, 3
        cmp     ebx, edi
        jne     @@s2
        xor     ecx, ecx
        mov     cl, byte ptr [OptimalBltProc+5]
        jmp     @@call
@@s2:
        and     ecx, 1
        mov     ebx, edx
        and     ebx, 1
        cmp     ecx, ebx
        jne     @@s3
        xor     ecx, ecx
        mov     cl, byte ptr [OptimalBltProc+6]
        jmp     @@call
@@s3:
        xor     ecx, ecx
        mov     cl, byte ptr [OptimalBltProc+3]   // sic: the small misaligned entry (+7) is never used
@@call:
        push    eax
        push    edx
        mov     eax, SrcPitch
        push    eax
        mov     eax, DstPitch
        push    eax
        push    esi
        mov     eax, Height
        push    eax
        mov     eax, dword ptr [BltProcs+ecx*4]
        call    eax
        pop     edi
        pop     esi
        pop     ebx
end;

{ The four timing tests of GetOptimalGFXESettings: the source and destination of T are aligned
  to 8 bytes and the destination offset by 0, 4, 2 or 1 bytes; every registered blit routine
  is run Count times and the fastest one returned with its bandwidth. }

function TestQWordAligned(T: TBltTest; Count: Integer): TBltTestResult;
var
  I: Integer;
  Res: TBltTestResult;
  Start, Stop, BestTime, Best, J, Time: Integer;
begin
  Best := -1;
  BestTime := $FFFFFF;
  T.Src := Pointer((Integer(T.Src) + 7) and not 7);
  T.Dst := Pointer((Integer(T.Dst) + 7) and not 7);
  T.Width := T.Width - 8;
  if T.Width > 0 then
  begin
    BltProcs[0](T.Src, T.Dst, T.SrcPitch, T.DstPitch, T.Width, T.Height);
    for I := 0 to BltProcCount - 1 do
    begin
      Start := GetElapsedMilliSeconds;
      for J := 0 to Count - 1 do
        BltProcs[I](T.Src, T.Dst, T.SrcPitch, T.DstPitch, T.Width, T.Height);
      Stop := GetElapsedMilliSeconds;
      Time := Stop - Start;
      if Time < BestTime then
      begin
        BestTime := Time;
        Best := I;
      end;
    end;
    Res.Index := Best;
    try
      Res.Bandwidth := Round(T.Width * T.Height / (1000 / Count * BestTime));
    except
      Res.Bandwidth := 0;
    end;
  end;
  Result := Res;
end;

function TestDWordAligned(T: TBltTest; Count: Integer): TBltTestResult;
var
  I: Integer;
  Res: TBltTestResult;
  Start, Stop, BestTime, Best, J, Time: Integer;
begin
  Best := -1;
  BestTime := $FFFFFF;
  T.Src := Pointer((Integer(T.Src) + 7) and not 7);
  T.Dst := Pointer(((Integer(T.Dst) + 7) and not 7) + 4);
  T.Width := T.Width - 16;
  if T.Width > 0 then
  begin
    BltProcs[0](T.Src, T.Dst, T.SrcPitch, T.DstPitch, T.Width, T.Height);
    for I := 0 to BltProcCount - 1 do
    begin
      Start := GetElapsedMilliSeconds;
      for J := 0 to Count - 1 do
        BltProcs[I](T.Src, T.Dst, T.SrcPitch, T.DstPitch, T.Width, T.Height);
      Stop := GetElapsedMilliSeconds;
      Time := Stop - Start;
      if Time < BestTime then
      begin
        BestTime := Time;
        Best := I;
      end;
    end;
    Res.Index := Best;
    try
      Res.Bandwidth := Round(T.Width * T.Height / (1000 / Count * BestTime));
    except
      Res.Bandwidth := 0;
    end;
  end;
  Result := Res;
end;

function TestWordAligned(T: TBltTest; Count: Integer): TBltTestResult;
var
  I: Integer;
  Res: TBltTestResult;
  Start, Stop, BestTime, Best, J, Time: Integer;
begin
  Best := -1;
  BestTime := $FFFFFF;
  T.Src := Pointer((Integer(T.Src) + 7) and not 7);
  T.Dst := Pointer(((Integer(T.Dst) + 7) and not 7) + 2);
  T.Width := T.Width - 16;
  if T.Width > 0 then
  begin
    BltProcs[0](T.Src, T.Dst, T.SrcPitch, T.DstPitch, T.Width, T.Height);
    for I := 0 to BltProcCount - 1 do
    begin
      Start := GetElapsedMilliSeconds;
      for J := 0 to Count - 1 do
        BltProcs[I](T.Src, T.Dst, T.SrcPitch, T.DstPitch, T.Width, T.Height);
      Stop := GetElapsedMilliSeconds;
      Time := Stop - Start;
      if Time < BestTime then
      begin
        BestTime := Time;
        Best := I;
      end;
    end;
    Res.Index := Best;
    try
      Res.Bandwidth := Round(T.Width * T.Height / (1000 / Count * BestTime));
    except
      Res.Bandwidth := 0;
    end;
  end;
  Result := Res;
end;

function TestMissAligned(T: TBltTest; Count: Integer): TBltTestResult;
var
  I: Integer;
  Res: TBltTestResult;
  Start, Stop, BestTime, Best, J, Time: Integer;
begin
  Best := -1;
  BestTime := $FFFFFF;
  T.Src := Pointer((Integer(T.Src) + 7) and not 7);
  T.Dst := Pointer(((Integer(T.Dst) + 7) and not 7) + 1);
  T.Width := T.Width - 16;
  if T.Width > 0 then
  begin
    BltProcs[0](T.Src, T.Dst, T.SrcPitch, T.DstPitch, T.Width, T.Height);
    for I := 0 to BltProcCount - 1 do
    begin
      Start := GetElapsedMilliSeconds;
      for J := 0 to Count - 1 do
        BltProcs[I](T.Src, T.Dst, T.SrcPitch, T.DstPitch, T.Width, T.Height);
      Stop := GetElapsedMilliSeconds;
      Time := Stop - Start;
      if Time < BestTime then
      begin
        BestTime := Time;
        Best := I;
      end;
    end;
    Res.Index := Best;
    try
      Res.Bandwidth := Round(T.Width * T.Height / (1000 / Count * BestTime));
    except
      Res.Bandwidth := 0;
    end;
  end;
  Result := Res;
end;

procedure GetOptimalGFXESettings(ShowDialog: Boolean);
var
  Form: TGFXEDiagnoseDlg;
  R: TBltTestResult;
  T: TBltTest;

  procedure ShowResult(Row: Integer);
  begin
    if Form <> nil then
    begin
      Form.BltGrid.Cells[1, Row + 1] := BltProcNames[R.Index];
      Form.BltGrid.Cells[2, Row + 1] := IntToStr(R.Bandwidth) + ' MB/S';
      Form.BltGrid.Refresh;
    end;
  end;

begin
  if ShowDialog then
  begin
    Form := TGFXEDiagnoseDlg.Create(nil);
    Form.Show;
    Form.Update;
  end
  else
    Form := nil;
  FillChar(T, SizeOf(T), 0);
  ReallocMem(T.Src, 1280 * 480 + 31);
  ReallocMem(T.Dst, 1280 * 480 + 31);
  T.SrcPitch := 1280;
  T.DstPitch := 1280;
  repeat
    if Form <> nil then Form.Caption := 'Running Optimal Settings Diagnose...';
    T.Width := 1280;
    T.Height := 480;
    Sleep(500);
    R := TestQWordAligned(T, 10);
    OptimalBltProc[0] := R.Index;
    ShowResult(0);
    Sleep(500);
    R := TestDWordAligned(T, 10);
    OptimalBltProc[1] := R.Index;
    ShowResult(1);
    Sleep(500);
    R := TestWordAligned(T, 10);
    OptimalBltProc[2] := R.Index;
    ShowResult(2);
    Sleep(500);
    R := TestMissAligned(T, 10);
    OptimalBltProc[3] := R.Index;
    ShowResult(3);
    T.Width := 60;
    T.Height := 480;
    Sleep(500);
    R := TestQWordAligned(T, 100);
    OptimalBltProc[4] := R.Index;
    ShowResult(4);
    Sleep(500);
    R := TestDWordAligned(T, 100);
    OptimalBltProc[5] := R.Index;
    ShowResult(5);
    Sleep(500);
    R := TestWordAligned(T, 100);
    OptimalBltProc[6] := R.Index;
    ShowResult(6);
    Sleep(500);
    R := TestMissAligned(T, 100);
    OptimalBltProc[7] := R.Index;
    ShowResult(7);
    if Form <> nil then
    begin
      Form.Caption := 'Optimal Settings Diagnose Done';
      Application.ProcessMessages;
      while Form.ModalResult = mrNone do Application.ProcessMessages;
    end;
  until (Form = nil) or (Form.ModalResult <> mrRetry);
  ReallocMem(T.Src, 0);
  ReallocMem(T.Dst, 0);
  Form.Free;
end;

procedure RegisterBltProc(Proc: TBltRectProc; Name: string);
begin
  if BltProcCount <> MaxBltProcs then
  begin
    Inc(BltProcCount);
    BltProcs[BltProcCount - 1] := Proc;
    BltProcNames[BltProcCount - 1] := Name;
  end
  else
    raise Exception.Create('Maximum number of BltProc reached');
end;

function BltSDRectClipped(const Src: TSurfaceDesc; SrcRect: TRect; const Dest: TSurfaceDesc; X, Y: Integer): HResult;
var
  W, H: Integer;
  S, D: Pointer;
  Bytes: Integer;
begin
  if SrcRect.Right > Src.ClipRect.Right then SrcRect.Right := Src.ClipRect.Right;
  if SrcRect.Left < Src.ClipRect.Left then
  begin
    X := X + (Src.ClipRect.Left - SrcRect.Left);
    SrcRect.Left := Src.ClipRect.Left;
  end;
  if X < Dest.ClipRect.Left then
  begin
    SrcRect.Left := SrcRect.Left + (Dest.ClipRect.Left - X);
    X := Dest.ClipRect.Left;
  end;
  W := SrcRect.Right - SrcRect.Left;
  if W + X > Dest.ClipRect.Right then W := W - (W + X - Dest.ClipRect.Right);
  if SrcRect.Bottom > Src.ClipRect.Bottom then SrcRect.Bottom := Src.ClipRect.Bottom;
  if SrcRect.Top < Src.ClipRect.Top then
  begin
    Y := Y + (Src.ClipRect.Top - SrcRect.Top);
    SrcRect.Top := Src.ClipRect.Top;
  end;
  if Y < Dest.ClipRect.Top then
  begin
    SrcRect.Top := SrcRect.Top + (Dest.ClipRect.Top - Y);
    Y := Dest.ClipRect.Top;
  end;
  H := SrcRect.Bottom - SrcRect.Top;
  if Y + H > Dest.ClipRect.Bottom then H := H - (Y + H - Dest.ClipRect.Bottom);
  if Src.PixelFormatID = Dest.PixelFormatID then
  begin
    if (W > 0) and (H > 0) then
    begin
      Bytes := (Src.BitCount * W) shr 3;
      S := Pointer(Integer(Src.Data) + Src.Pitch * SrcRect.Top + (Src.BitCount * SrcRect.Left) shr 3);
      D := Pointer(Integer(Dest.Data) + Dest.Pitch * Y + (Dest.BitCount * X) shr 3);
      BltRect(S, D, Src.Pitch, Dest.Pitch, Bytes, H);
    end;
    Result := GFXE_OK;
  end
  else
    Result := GFXE_PIXELFORMATNOTSUPPORTED;
end;

{ Transparent (50%) blits of two 16 bit surfaces: the pixels are averaged with the low bit of
  every channel masked off. }

procedure BltTransparent565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     ebx, Height
        mov     esi, Src
        mov     edi, Dst
        test    eax, eax
        je      @@exit
        test    ebx, ebx
        je      @@exit
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L1, ecx
        mov     L2, eax
        shr     ebx, 2
        je      @@l3
        mov     L3, ebx
        lea     ecx, [@@dwords]
        mov     L4, ecx
        jmp     @@start
@@l3:
        lea     ecx, [@@tail]
        mov     L4, ecx
        jmp     @@start
@@unaligned:
        mov     L3, 0
        mov     L2, eax
        lea     ecx, [@@tail]
        mov     L4, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L5, eax
        mov     ebx, Width
        mov     eax, DstPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L6, eax
        mov     L7, esp
        jmp     dword ptr L4
@@dwords:
        mov     esp, L3
@@d1:
        mov     eax, [esi]
        mov     ebx, [edi]
        mov     ecx, [esi+4]
        mov     edx, [edi+4]
        and     eax, $F7DEF7DF
        and     ebx, $F7DEF7DF
        and     ecx, $F7DEF7DF
        and     edx, $F7DEF7DF
        add     eax, ebx
        lea     esi, [esi+8]
        rcr     eax, 1
        add     ecx, edx
        mov     [edi], eax
        rcr     ecx, 1
        mov     [edi+4], ecx
        lea     edi, [edi+8]
        dec     esp
        jne     @@d1
        jmp     dword ptr L1
@@tail:
        mov     ecx, L2
@@t1:
        mov     ax, [esi]
        mov     bx, [edi]
        and     eax, $F7DF
        and     ebx, $F7DF
        add     eax, ebx
        lea     edi, [edi+2]
        shr     eax, 1
        lea     esi, [esi+2]
        dec     ecx
        mov     [edi-2], ax
        jne     @@t1
@@nextrow:
        add     esi, L5
        add     edi, L6
        dec     Height
        je      @@done
        jmp     dword ptr L4
@@done:
        mov     esp, L7
@@exit:
        pop     esi
        pop     edi
        pop     ebx
end;

procedure BltTransparent555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     ebx, Height
        mov     esi, Src
        mov     edi, Dst
        test    eax, eax
        je      @@exit
        test    ebx, ebx
        je      @@exit
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L1, ecx
        mov     L2, eax
        shr     ebx, 2
        je      @@l3
        mov     L3, ebx
        lea     ecx, [@@dwords]
        mov     L4, ecx
        jmp     @@start
@@l3:
        lea     ecx, [@@tail]
        mov     L4, ecx
        jmp     @@start
@@unaligned:
        mov     L3, 0
        mov     L2, eax
        lea     ecx, [@@tail]
        mov     L4, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L5, eax
        mov     ebx, Width
        mov     eax, DstPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L6, eax
        mov     L7, esp
        jmp     dword ptr L4
@@dwords:
        mov     esp, L3
@@d1:
        mov     eax, [esi]
        mov     ebx, [edi]
        mov     ecx, [esi+4]
        mov     edx, [edi+4]
        and     eax, $7BDE7BDF
        and     ebx, $7BDE7BDF
        and     ecx, $7BDE7BDF
        and     edx, $7BDE7BDF
        add     eax, ebx
        lea     esi, [esi+8]
        rcr     eax, 1
        add     ecx, edx
        mov     [edi], eax
        rcr     ecx, 1
        mov     [edi+4], ecx
        lea     edi, [edi+8]
        dec     esp
        jne     @@d1
        jmp     dword ptr L1
@@tail:
        mov     ecx, L2
@@t1:
        mov     ax, [esi]
        mov     bx, [edi]
        and     eax, $7BDF
        and     ebx, $7BDF
        add     eax, ebx
        lea     edi, [edi+2]
        shr     eax, 1
        lea     esi, [esi+2]
        dec     ecx
        mov     [edi-2], ax
        jne     @@t1
@@nextrow:
        add     esi, L5
        add     edi, L6
        dec     Height
        je      @@done
        jmp     dword ptr L4
@@done:
        mov     esp, L7
@@exit:
        pop     esi
        pop     edi
        pop     ebx
end;

{ Color keyed 16 bit blit: two pixels at a time, the pairs equal to the doubled key skipped. }
procedure BltColorKey16(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; ColorKey: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    esi
        mov     eax, Height
        push    edi
        test    eax, eax
        je      @@exit
        mov     eax, Dst
        mov     edx, Width
        and     eax, 3
        jne     @@odd
        mov     ebx, edx
        mov     L1, eax
        shr     ebx, 1
        mov     ecx, edx
        and     ecx, 1
        mov     L2, ebx
        mov     L3, ecx
        jmp     @@setup
@@odd:
        mov     eax, 1
        lea     ecx, [edx-1]
        mov     L1, eax
        shr     ecx, 1
        lea     ebx, [edx-1]
        mov     L2, ecx
        and     ebx, 1
        mov     L3, ebx
@@setup:
        mov     eax, Width
        mov     edx, SrcPitch
        shl     eax, 1
        mov     ecx, DstPitch
        sub     edx, eax
        sub     ecx, eax
        mov     L4, edx
        mov     L5, ecx
        mov     ebx, ColorKey
        mov     eax, ebx
        mov     esi, Src
        mov     edi, Dst
        shl     eax, 16
        mov     L6, esp
        mov     esp, ebx
        mov     L7, eax
        or      esp, eax
@@row:
        mov     ecx, L1
        xor     eax, eax
        test    ecx, ecx
        je      @@pairs
        mov     ax, [esi]
        add     edi, 2
        add     esi, 2
        cmp     eax, ebx
        je      @@pairs
        mov     [edi-2], ax
@@pairs:
        mov     ecx, L2
        test    ecx, ecx
        je      @@last
@@p1:
        mov     eax, [esi]
        add     edi, 4
@@p2:
        mov     edx, eax
        add     esi, 4
        and     eax, $FFFF
        and     edx, $FFFF0000
        cmp     eax, ebx
        je      @@lowkey
        cmp     edx, L7
        je      @@highkey
        or      eax, edx
        dec     ecx
        mov     [edi-4], eax
        jne     @@p1
        jmp     @@last
@@lowkey:
        cmp     edx, L7
        jne     @@lk2
        dec     ecx
        jne     @@both
        jmp     @@last
@@lk2:
        shr     edx, 16
        dec     ecx
        mov     [edi-2], dx
        jne     @@p1
        jmp     @@last
@@highkey:
        mov     [edi-4], ax
        dec     ecx
        je      @@last
@@both:
        mov     eax, [esi]
        add     edi, 4
        cmp     eax, esp
        jne     @@p2
        add     esi, 4
        dec     ecx
        jne     @@both
@@last:
        mov     ecx, L3
        xor     eax, eax
        test    ecx, ecx
        je      @@next
        mov     ax, [esi]
        add     edi, 2
        add     esi, 2
        cmp     eax, ebx
        je      @@next
        mov     [edi-2], ax
@@next:
        add     esi, L4
        add     edi, L5
        dec     Height
        jne     @@row
        mov     esp, L6
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

function BltSprite16(const Src: TSurfaceDesc; SrcRect: TRect; const Dest: TSurfaceDesc; X, Y: Integer; ColorKey: TColor): HResult;
var
  Key: Integer;
  S, D: Pointer;
begin
  if (Src.BitCount = 16) and (Dest.PixelFormatID = Src.PixelFormatID) then
  begin
    Key := Color2PixelInfo(ColorKey, Src.PixelFormatID, nil);
    S := Pointer(Integer(Src.Data) + Src.Pitch * SrcRect.Top + SrcRect.Left * 2);
    D := Pointer(Integer(Dest.Data) + Dest.Pitch * Y + X * 2);
    BltColorKey16(S, D, Src.Pitch, Dest.Pitch, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, Key);
    Result := GFXE_OK;
  end
  else
    Result := GFXE_PIXELFORMATNOTSUPPORTED;
end;

function BltSpriteClipped16(const Src: TSurfaceDesc; SrcRect: TRect; const Dest: TSurfaceDesc; X, Y: Integer; ColorKey: TColor): HResult;
var
  W, H: Integer;
  S, D: Pointer;
  Key: Integer;
begin
  if (Src.BitCount = 16) and (Dest.BitCount = 16) then
  begin
    if SrcRect.Right > Src.ClipRect.Right then SrcRect.Right := Src.ClipRect.Right;
    if SrcRect.Left < Src.ClipRect.Left then
    begin
      X := X + (Src.ClipRect.Left - SrcRect.Left);
      SrcRect.Left := Src.ClipRect.Left;
    end;
    if X < Dest.ClipRect.Left then
    begin
      SrcRect.Left := SrcRect.Left + (Dest.ClipRect.Left - X);
      X := Dest.ClipRect.Left;
    end;
    W := SrcRect.Right - SrcRect.Left;
    if W + X > Dest.ClipRect.Right then W := W - ((W + X) - Dest.ClipRect.Right);
    if SrcRect.Bottom > Src.ClipRect.Bottom then SrcRect.Bottom := Src.ClipRect.Bottom;
    if SrcRect.Top < Src.ClipRect.Top then
    begin
      Y := Y + (Src.ClipRect.Top - SrcRect.Top);
      SrcRect.Top := Src.ClipRect.Top;
    end;
    if Y < Dest.ClipRect.Top then
    begin
      SrcRect.Top := SrcRect.Top + (Dest.ClipRect.Top - Y);
      Y := Dest.ClipRect.Top;
    end;
    H := SrcRect.Bottom - SrcRect.Top;
    if Y + H > Dest.ClipRect.Bottom then H := H - ((Y + H) - Dest.ClipRect.Bottom);
    if (W > 0) and (H > 0) then
    begin
      Key := Color2PixelInfo(ColorKey, Src.PixelFormatID, nil);
      S := Pointer(Integer(Src.Data) + Src.Pitch * SrcRect.Top + SrcRect.Left * 2);
      D := Pointer(Integer(Dest.Data) + Dest.Pitch * Y + X * 2);
      BltColorKey16(S, D, Src.Pitch, Dest.Pitch, W, H, Key);
    end;
    Result := GFXE_OK;
  end
  else
    Result := GFXE_PIXELFORMATNOTSUPPORTED;
end;

{ Stretched 16 bit blit: RowTable holds the source row pointers, ColTable the source column
  indices of every destination pixel. }
procedure BltStretched16(RowTable, ColTable: Pointer; Dst: Pointer; DstPitch, Width, Height: Integer); pascal;
var
  L1, L2: Integer;
asm
        push    ebx
        push    esi
        push    edi
        mov     ebx, Width
        mov     eax, DstPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L1, eax
        mov     edi, Dst
        mov     L2, esp
        xor     ebx, ebx
@@row:
        mov     esp, RowTable
        mov     esi, [esp+ebx*4]
        mov     esp, ColTable
        xor     ecx, ecx
@@col:
        mov     edx, [esp+ecx*4]
        add     edi, 2
        inc     ecx
        mov     ax, [esi+edx*2]
        cmp     ecx, Width
        mov     [edi-2], ax
        jne     @@col
        inc     ebx
        cmp     ebx, Height
        je      @@done
        add     edi, L1
        jmp     @@row
@@done:
        mov     esp, L2
        pop     edi
        pop     esi
        pop     ebx
end;

function ColorFillSD(R: TRect; Color: TColor; const SD: TSurfaceDesc): HResult;
var
  W: Integer;
  Y: Integer;
  P: PChar;
  Pixel: Integer;
begin
  if R.Left < SD.ClipRect.Left then R.Left := SD.ClipRect.Left;
  if R.Right > SD.ClipRect.Right then R.Right := SD.ClipRect.Right;
  if R.Top < SD.ClipRect.Top then R.Top := SD.ClipRect.Top;
  if R.Bottom > SD.ClipRect.Bottom then R.Bottom := SD.ClipRect.Bottom;
  W := R.Right - R.Left;
  case SD.PixelFormatID of
    pfRGB555, pfARGB1555, pfRGB565:
      begin
        P := PChar(Integer(SD.Data) + SD.Pitch * R.Top + R.Left * 2);
        Pixel := Color2PixelInfo(Color, SD.PixelFormatID, nil);
        for Y := R.Top to R.Bottom - 1 do
        begin
          FillWord(P^, W, Pixel);
          Inc(P, SD.Pitch);
        end;
        Result := GFXE_OK;
      end;
  else
    Result := GFXE_NOTSUPPORTED;
  end;
end;

function RDTSC: Integer;
asm
        DB      $0F, $31                // rdtsc
end;

procedure FillInt(var Dest; Count, Value: Integer);
asm
        push    edi
        mov     edi, eax
        mov     eax, ecx
        mov     ecx, edx
        rep     stosd
        pop     edi
end;

procedure FillTrippleByte(var Dest; Count, Value: Integer);
asm
        push    edi
        push    ebx
        mov     ebx, ecx
        mov     edi, eax
        shr     ebx, 16
        mov     eax, ecx
@@1:
        mov     [edi], cx
        mov     [edi+2], bl
        add     edi, 3
        dec     edx
        jne     @@1
        pop     ebx
        pop     edi
end;

procedure FillWord(var Dest; Count, Value: Integer);
asm
        push    edi
        mov     edi, eax
        mov     eax, ecx
        shl     eax, 16
        add     eax, ecx
        mov     ecx, edx
        shr     ecx, 1
        rep     stosd
        and     edx, 1
        je      @@1
        stosw
@@1:
        pop     edi
end;

function GetPixelInfo(const SD: TSurfaceDesc; X, Y: Integer): Integer;
begin
  case SD.BitCount of
    8: Result := PByte(X + Integer(SD.Data) + SD.Pitch * Y)^;
    16: Result := PWord(Integer(SD.Data) + X + X + SD.Pitch * Y)^;
    24: Result := PInteger(Integer(SD.Data) + X * 3 + SD.Pitch * Y)^ and $FFFFFF;
    32: Result := PInteger(Integer(SD.Data) + X * 4 + SD.Pitch * Y)^;
  else
    raise Exception.Create('PixelFormat is not supported');
  end;
end;

{ The pixel format ID: bits 0-7 the bit count, bits 8-15 the position (0-3) of each channel
  (A, B, G, R) counted from the low end, bits 16-31 the bits per channel (A, B, G, R). }
function MASKtoPFID(BitCount: Integer; RMask, GMask, BMask, AMask: Integer): Integer;
var
  Order: array[0..3] of Byte;
  Swapped: Boolean;
  Masks: array[0..3] of Integer;
  I, Bits, T: Integer;
begin
  Result := BitCount;
  Masks[0] := AMask;
  Order[3] := 3;
  Masks[1] := BMask;
  Order[0] := 0;
  Masks[2] := GMask;
  Order[1] := 1;
  Masks[3] := RMask;
  Order[2] := 2;
  repeat
    Swapped := False;
    for I := 0 to 2 do
      if (((Masks[Order[I]] < 0) or (Masks[Order[I + 1]] < Masks[Order[I]])) and (Masks[Order[I + 1]] > 0)) or
        ((Masks[Order[I]] = 0) and (Masks[Order[I + 1]] <> 0)) then
      begin
        T := Order[I];
        Order[I] := Order[I + 1];
        Order[I + 1] := T;
        Swapped := True;
      end;
  until not Swapped;
  for I := 0 to 3 do
    Result := Result + (I shl (Order[I] * 2 + 8));
  for I := 0 to 3 do
  begin
    Bits := 0;
    while Masks[I] <> 0 do
    begin
      if Masks[I] and 1 <> 0 then Inc(Bits);
      Masks[I] := Masks[I] shr 1;
    end;
    Result := Result + (Bits shl (I * 4 + 16));
  end;
end;

function PFIDtoMASK(PixelFormatID: Integer; var RMask, GMask, BMask, AMask: Integer): Integer;
var
  BitCount: Integer;
  Order: array[0..3] of Byte;
  Pos: Integer;
  Masks: array[0..3] of Integer;
  I, J, Bits, M: Integer;
begin
  FillChar(Order, SizeOf(Order), 0);
  FillChar(Masks, SizeOf(Masks), 0);
  BitCount := PixelFormatID and $FF;
  Pos := 0;
  Order[(PixelFormatID shr 8) and 3] := 0;
  Order[(PixelFormatID shr 10) and 3] := 1;
  Order[(PixelFormatID shr 12) and 3] := 2;
  Order[(PixelFormatID shr 14) and 3] := 3;
  for I := 0 to 3 do
  begin
    Bits := (PixelFormatID shr (Order[I] * 4 + 16)) and $F;
    J := Bits;
    M := 0;
    while J <> 0 do
    begin
      M := M * 2 + 1;
      Dec(J);
    end;
    M := M shl Pos;
    Pos := Pos + Bits;
    Masks[Order[I]] := M;
  end;
  AMask := Masks[0];
  BMask := Masks[1];
  GMask := Masks[2];
  RMask := Masks[3];
  Result := BitCount;
end;

procedure CreateSDfromSD(const Src: TSurfaceDesc; const R: TRect; var Dest: TSurfaceDesc);
begin
  Dest := Src;
  IntersectRect(Dest.ClipRect, Src.ClipRect, R);
  Dest.Data := Pointer(Integer(Src.Data) + R.Top * Src.Pitch + (Src.BitCount shr 3) * R.Left);
  Dec(Dest.ClipRect.Left, R.Left);
  Dec(Dest.ClipRect.Right, R.Left);
  Dec(Dest.ClipRect.Top, R.Top);
  Dec(Dest.ClipRect.Bottom, R.Top);
end;

{ TRectangle }

constructor TRectangle.Create(ALeft, ATop, ARight, ABottom: Integer);
begin
  Rect.Left := ALeft;
  Rect.Top := ATop;
  Rect.Right := ARight;
  Rect.Bottom := ABottom;
end;

constructor TRectangle.CreateRect(const R: TRect);
begin
  Rect := R;
end;

{ TRectangleList }

destructor TRectangleList.Destroy;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    TRectangle(Items[I]).Destroy;
    Delete(I);
  end;
end;

function TRectangleList.GetRectangle(Index: Integer): TRectangle;
begin
  Result := TRectangle(List^[Index]);
end;

{ The rectangles of a surface: the maximal rectangles of TransparentColor bordered by other
  colors, found from their top left corners. }
function GetSurfaceRectangles(SD: TSurfaceDesc; TransparentColor: Integer; OnProgress: TProgressEvent): TRectangleList;
var
  List: TRectangleList;
  X, Y: Word;

  function GetPixel(X, Y: Integer): Integer;
  var
    P: Pointer;
  begin
    case SD.BitCount of
      8: Result := PByte(X + Integer(SD.Data) + SD.Pitch * Y)^;
      16: Result := PWord(Integer(SD.Data) + X + X + SD.Pitch * Y)^;
      24: if X + 1 < SD.Width then
            Result := PInteger(Integer(SD.Data) + (X + X + X) + SD.Pitch * Y)^ and $FFFFFF
          else
          begin
            P := Pointer(Integer(SD.Data) + (X + X + X) + SD.Pitch * Y);
            Result := PWord(P)^ + PByte(Integer(P) + 2)^ shl 16;
          end;
      32: Result := PInteger(Integer(SD.Data) + X shl 2 + SD.Pitch * Y)^;
    else
      raise Exception.Create('PixelFormat is not supported');
    end;
  end;

  function FindRectangle(X, Y: Integer): TRectangle;
  var
    W, H, I: Integer;
    Ok: Boolean;
    R: TRectangle;
  begin
    R := nil;
    W := 1;
    H := 1;
    while (GetPixel(X + W, Y) = TransparentColor) and (GetPixel(X + W, Y + 1) <> TransparentColor) and
      (X + W < SD.Width - 1) do
      Inc(W);
    if (GetPixel(X + W, Y) = TransparentColor) and (GetPixel(X + W, Y + 1) = TransparentColor) and
      (X + W < SD.Width - 1) and (W > 1) then
    begin
      while (GetPixel(X, Y + H) = TransparentColor) and (GetPixel(X + W, Y + H) = TransparentColor) and
        (GetPixel(X + 1, Y + H) <> TransparentColor) and (GetPixel(X + W - 1, Y + H) <> TransparentColor) and
        (Y + H < SD.Height) do
        Inc(H);
      if (GetPixel(X, Y + H) = TransparentColor) and (GetPixel(X + 1, Y + H) = TransparentColor) and
        (GetPixel(X + W, Y + H) = TransparentColor) and (GetPixel(X + W - 1, Y + H) = TransparentColor) and
        (Y + H < SD.Height) and (H > 1) then
      begin
        Ok := True;
        I := 1;
        while Ok and (I <> W) do
        begin
          Ok := GetPixel(X + I, Y + H) = TransparentColor;
          Inc(I);
        end;
        if Ok then R := TRectangle.Create(X + 1, Y + 1, X + W, Y + H);
      end;
    end;
    Result := R;
  end;

begin
  List := TRectangleList.Create;
  for Y := 0 to SD.Height - 1 do
  begin
    for X := 0 to SD.Width - 1 do
      if GetPixel(X, Y) = TransparentColor then
        if FindRectangle(X, Y) <> nil then List.Add(FindRectangle(X, Y));
    if Assigned(OnProgress) and ((Y mod 20 = 0) or (Y = SD.Height - 1)) then
      OnProgress(nil, Round(Y * 100 / (SD.Height - 1)), 0);
  end;
  if List.Count = 0 then
  begin
    List.Free;
    Result := nil;
  end
  else
    Result := List;
end;

{ Shrinks R to the part of the surface that is not TransparentColor (MinimizeTransparentRect)
  or that is TransparentColor (MinimizeInvTransparentRect). }
procedure MinimizeTransparentRect(const SD: TSurfaceDesc; const R: TRect; TransparentColor: Integer; var Result: TRect);
var
  Found: Boolean;
  X, Y: Integer;
  Rect: TRect;

  function GetPixel(X, Y: Integer): Integer;
  begin
    case SD.BitCount of
      8: Result := PByte(X + Integer(SD.Data) + SD.Pitch * Y)^;
      16: Result := PWord(Integer(SD.Data) + X + X + SD.Pitch * Y)^;
      24: Result := PInteger(Integer(SD.Data) + X * 3 + SD.Pitch * Y)^ and $FFFFFF;
      32: Result := PInteger(Integer(SD.Data) + X * 4 + SD.Pitch * Y)^;
    else
      raise Exception.Create('PixelFormat is not supported');
    end;
  end;

begin
  Rect := R;
  Found := False;
  while not Found and (Rect.Top < Rect.Bottom) do
  begin
    X := Rect.Left;
    while not Found and (X <> Rect.Right) do
    begin
      Found := GetPixel(X, Rect.Top) <> TransparentColor;
      Inc(X);
    end;
    if not Found then Inc(Rect.Top);
  end;
  Found := False;
  while not Found and (Rect.Bottom > Rect.Top) do
  begin
    X := Rect.Left;
    while not Found and (X <> Rect.Right) do
    begin
      Found := GetPixel(X, Rect.Bottom - 1) <> TransparentColor;
      Inc(X);
    end;
    if not Found then Dec(Rect.Bottom);
  end;
  Found := False;
  while not Found and (Rect.Left < Rect.Right) do
  begin
    Y := Rect.Top;
    while not Found and (Y <> Rect.Bottom) do
    begin
      Found := GetPixel(Rect.Left, Y) <> TransparentColor;
      Inc(Y);
    end;
    if not Found then Inc(Rect.Left);
  end;
  Found := False;
  while not Found and (Rect.Right > Rect.Left) do
  begin
    Y := Rect.Top;
    while not Found and (Y <> Rect.Bottom) do
    begin
      Found := GetPixel(Rect.Right - 1, Y) <> TransparentColor;
      Inc(Y);
    end;
    if not Found then Dec(Rect.Right);
  end;
  Result := Rect;
end;

procedure MinimizeInvTransparentRect(const SD: TSurfaceDesc; const R: TRect; TransparentColor: Integer; var Result: TRect);
var
  Found: Boolean;
  X, Y: Integer;
  Rect: TRect;

  function GetPixel(X, Y: Integer): Integer;
  begin
    case SD.BitCount of
      8: Result := PByte(X + Integer(SD.Data) + SD.Pitch * Y)^;
      16: Result := PWord(Integer(SD.Data) + X + X + SD.Pitch * Y)^;
      24: Result := PInteger(Integer(SD.Data) + X * 3 + SD.Pitch * Y)^ and $FFFFFF;
      32: Result := PInteger(Integer(SD.Data) + X * 4 + SD.Pitch * Y)^;
    else
      raise Exception.Create('PixelFormat is not supported');
    end;
  end;

begin
  Rect := R;
  Found := False;
  while not Found and (Rect.Top < Rect.Bottom) do
  begin
    X := Rect.Left;
    while not Found and (X <> Rect.Right) do
    begin
      Found := GetPixel(X, Rect.Top) = TransparentColor;
      Inc(X);
    end;
    if not Found then Inc(Rect.Top);
  end;
  Found := False;
  while not Found and (Rect.Bottom > Rect.Top) do
  begin
    X := Rect.Left;
    while not Found and (X <> Rect.Right) do
    begin
      Found := GetPixel(X, Rect.Bottom - 1) = TransparentColor;
      Inc(X);
    end;
    if not Found then Dec(Rect.Bottom);
  end;
  Found := False;
  while not Found and (Rect.Left < Rect.Right) do
  begin
    Y := Rect.Top;
    while not Found and (Y <> Rect.Bottom) do
    begin
      Found := GetPixel(Rect.Left, Y) = TransparentColor;
      Inc(Y);
    end;
    if not Found then Inc(Rect.Left);
  end;
  Found := False;
  while not Found and (Rect.Right > Rect.Left) do
  begin
    Y := Rect.Top;
    while not Found and (Y <> Rect.Bottom) do
    begin
      Found := GetPixel(Rect.Right - 1, Y) = TransparentColor;
      Inc(Y);
    end;
    if not Found then Dec(Rect.Right);
  end;
  Result := Rect;
end;

{ Bresenham line on a 16 bit surface, every Skip-th pixel left out; the clip test is only made
  when an end point lies outside the clip rectangle. }
procedure DrawLine16(X1, Y1, X2, Y2, Skip: Integer; Color: Word; const SD: TSurfaceDesc);
var
  X, Y: Integer;
  DX, DY, D2, DX2, DY2, E: Integer;
  P: PWord;
  Count: Integer;
begin
  Count := 0;
  if X2 < X1 then
  begin
    X := X2;
    X2 := X1;
    X1 := X;
    Y := Y2;
    Y2 := Y1;
    Y1 := Y;
  end
  else
  begin
    X := X1;
    Y := Y1;
  end;
  if (X1 >= SD.ClipRect.Left) and (X1 < SD.ClipRect.Right) and (Y1 >= SD.ClipRect.Top) and
    (Y1 < SD.ClipRect.Bottom) and (X2 >= SD.ClipRect.Left) and (X2 < SD.ClipRect.Right) and
    (Y2 >= SD.ClipRect.Top) and (Y2 < SD.ClipRect.Bottom) then
  begin
    // the whole line is inside the clip rectangle
    if Y2 >= Y1 then
    begin
      DX := X2 - X1;
      DY := Y2 - Y1;
      if DY >= DX then
      begin
        D2 := 2 * (DX - DY);
        DX2 := 2 * DX;
        E := DX2 - DY;
        P := PWord(Integer(SD.Data) + X * 2 + SD.Pitch * Y);
        while Y <> Y2 do
        begin
          if Count = 0 then
          begin
            P^ := Color;
            Count := Skip;
          end
          else
            Dec(Count);
          if E >= 0 then
          begin
            E := E + D2;
            Inc(P);
          end
          else
            E := E + DX2;
          Inc(Integer(P), SD.Pitch);
          Inc(Y);
        end;
        if Count = 0 then P^ := Color;
      end
      else
      begin
        D2 := 2 * (DY - DX);
        DY2 := 2 * DY;
        E := DY2 - DX;
        P := PWord(Integer(SD.Data) + X * 2 + SD.Pitch * Y);
        while X <> X2 do
        begin
          if Count = 0 then
          begin
            P^ := Color;
            Count := Skip;
          end
          else
            Dec(Count);
          if E >= 0 then
          begin
            E := E + D2;
            Inc(Integer(P), SD.Pitch);
          end
          else
            E := E + DY2;
          Inc(P);
          Inc(X);
        end;
        if Count = 0 then P^ := Color;
      end;
    end
    else
    begin
      DX := X2 - X1;
      DY := Y1 - Y2;
      P := PWord(Integer(SD.Data) + X * 2 + SD.Pitch * Y);
      if DY >= DX then
      begin
        D2 := 2 * (DX - DY);
        DX2 := 2 * DX;
        E := DX2 - DY;
        while Y <> Y2 do
        begin
          if Count = 0 then
          begin
            P^ := Color;
            Count := Skip;
          end
          else
            Dec(Count);
          if E >= 0 then
          begin
            E := E + D2;
            Inc(P);
          end
          else
            E := E + DX2;
          Dec(Y);
          Dec(Integer(P), SD.Pitch);
        end;
        if Count = 0 then P^ := Color;
      end
      else
      begin
        D2 := 2 * (DY - DX);
        DY2 := 2 * DY;
        E := DY2 - DX;
        P := PWord(Integer(SD.Data) + X * 2 + SD.Pitch * Y);
        while X <> X2 do
        begin
          if Count = 0 then
          begin
            P^ := Color;
            Count := Skip;
          end
          else
            Dec(Count);
          if E >= 0 then
          begin
            E := E + D2;
            Dec(Integer(P), SD.Pitch);
          end
          else
            E := E + DY2;
          Inc(X);
          Inc(P);
        end;
        if Count = 0 then P^ := Color;
      end;
    end;
  end
  else
  begin
    // clipped: every pixel is tested
    if Y2 >= Y1 then
    begin
      DX := X2 - X1;
      DY := Y2 - Y1;
      if DY >= DX then
      begin
        D2 := 2 * (DX - DY);
        DX2 := 2 * DX;
        E := DX2 - DY;
        P := PWord(Integer(SD.Data) + X * 2 + SD.Pitch * Y);
        while Y <> Y2 do
        begin
          if Count = 0 then
          begin
            if (X >= SD.ClipRect.Left) and (X < SD.ClipRect.Right) and (Y >= SD.ClipRect.Top) and (Y < SD.ClipRect.Bottom) then P^ := Color;
            Count := Skip;
          end
          else
            Dec(Count);
          if E >= 0 then
          begin
            E := E + D2;
            Inc(P);
            Inc(X);
          end
          else
            E := E + DX2;
          Inc(Integer(P), SD.Pitch);
          Inc(Y);
        end;
        if (Count = 0) and (X >= SD.ClipRect.Left) and (X < SD.ClipRect.Right) and (Y >= SD.ClipRect.Top) and (Y < SD.ClipRect.Bottom) then P^ := Color;
      end
      else
      begin
        D2 := 2 * (DY - DX);
        DY2 := 2 * DY;
        E := DY2 - DX;
        P := PWord(Integer(SD.Data) + X * 2 + SD.Pitch * Y);
        while X <> X2 do
        begin
          if Count = 0 then
          begin
            if (X >= SD.ClipRect.Left) and (X < SD.ClipRect.Right) and (Y >= SD.ClipRect.Top) and (Y < SD.ClipRect.Bottom) then P^ := Color;
            Count := Skip;
          end
          else
            Dec(Count);
          if E >= 0 then
          begin
            E := E + D2;
            Inc(Y);
            Inc(Integer(P), SD.Pitch);
          end
          else
            E := E + DY2;
          Inc(P);
          Inc(X);
        end;
        if (Count = 0) and (X >= SD.ClipRect.Left) and (X < SD.ClipRect.Right) and (Y >= SD.ClipRect.Top) and (Y < SD.ClipRect.Bottom) then P^ := Color;
      end;
    end
    else
    begin
      DX := X2 - X1;
      DY := Y1 - Y2;
      P := PWord(Integer(SD.Data) + X * 2 + SD.Pitch * Y);
      if DY >= DX then
      begin
        D2 := 2 * (DX - DY);
        DX2 := 2 * DX;
        E := DX2 - DY;
        while Y <> Y2 do
        begin
          if Count = 0 then
          begin
            if (X >= SD.ClipRect.Left) and (X < SD.ClipRect.Right) and (Y >= SD.ClipRect.Top) and (Y < SD.ClipRect.Bottom) then P^ := Color;
            Count := Skip;
          end
          else
            Dec(Count);
          if E >= 0 then
          begin
            E := E + D2;
            Inc(X);
            Inc(P);
          end
          else
            E := E + DX2;
          Dec(Y);
          Dec(Integer(P), SD.Pitch);
        end;
        if (Count = 0) and (X >= SD.ClipRect.Left) and (X < SD.ClipRect.Right) and (Y >= SD.ClipRect.Top) and (Y < SD.ClipRect.Bottom) then P^ := Color;
      end
      else
      begin
        D2 := 2 * (DY - DX);
        DY2 := 2 * DY;
        E := DY2 - DX;
        P := PWord(Integer(SD.Data) + X * 2 + SD.Pitch * Y);
        while X <> X2 do
        begin
          if Count = 0 then
          begin
            if (X >= SD.ClipRect.Left) and (X < SD.ClipRect.Right) and (Y >= SD.ClipRect.Top) and (Y < SD.ClipRect.Bottom) then P^ := Color;
            Count := Skip;
          end
          else
            Dec(Count);
          if E >= 0 then
          begin
            E := E + D2;
            Dec(Y);
            Dec(Integer(P), SD.Pitch);
          end
          else
            E := E + DY2;
          Inc(X);
          Inc(P);
        end;
        if (Count = 0) and (X >= SD.ClipRect.Left) and (X < SD.ClipRect.Right) and (Y >= SD.ClipRect.Top) and (Y < SD.ClipRect.Bottom) then P^ := Color;
      end;
    end;
  end;
end;

{ Skip is not passed on: DrawLine16 always draws every pixel (original). }
procedure DrawLine(X1, Y1, X2, Y2, Skip: Integer; Color: TColor; const SD: TSurfaceDesc);
var
  Pixel: Integer;
begin
  case SD.PixelFormatID of
    pfRGB555, pfARGB1555, pfRGB565:
      begin
        Pixel := Color2PixelInfo(Color, SD.PixelFormatID, nil);
        DrawLine16(X1, Y1, X2, Y2, 0, Pixel, SD);
      end;
  end;
end;

{ The original unit was longer: the line numbers compiled into the Assert calls (7162 for the next Assert below) prove that 3417 more lines preceded this point. Their content is unknown; the blank lines below keep the Assert line numbers identical. }

























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































{ TDIBSurface }

destructor TDIBSurface.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TDIBSurface.GetBITMAPINFO: PBitmapInfo;
begin
  Result := @FInfo;
end;

function TDIBSurface.GetBITMAPINFOHEADER: PBitmapInfoHeader;
begin
  Result := @FInfo;
end;

function TDIBSurface.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TDIBSurface.GetHeight: Integer;
begin
  Result := FHeight;
end;

procedure TDIBSurface.Clear;
begin
  ReallocMem(FMem, 0);
  if FPalette <> nil then
  begin
    FPalette.Free;
    FPalette := nil;
  end;
  FWidth := 0;
  FHeight := 0;
  FPitch := 0;
  if FHandle <> 0 then
  begin
    DeleteObject(FHandle);
    FHandle := 0;
  end;
end;

function TDIBSurface.UpdatePalette: HResult;
var
  I: Integer;
begin
  if (FPalette <> nil) and (FPixelFormatID = pfPAL8) then
  begin
    for I := 0 to 255 do
      with FPalette.Entries[I] do
      begin
        FColors[I].rgbRed := R;
        FColors[I].rgbGreen := G;
        FColors[I].rgbBlue := B;
      end;
    Result := GFXE_OK;
  end
  else
    Result := GFXE_NOTSUPPORTED;
end;

function TDIBSurface.Setup(AWidth, AHeight, APixelFormatID: Integer; APalette: TGFXEPalette): HResult;
var
  DC: HDC;
  DS: TDIBSection;
begin
  Clear;
  case APixelFormatID of
    pfPAL8:
      begin
        FWidth := AWidth;
        FHeight := AHeight;
        FPixelFormatID := APixelFormatID;
        FPalette := TGFXEPalette.Create;
        FPalette.PixelFormatID := pfRGB24;
        with FInfo do
        begin
          biSize := SizeOf(TBitmapInfoHeader);
          biPlanes := 1;
          biBitCount := 8;
          biCompression := BI_RGB;
          biSizeImage := 0;
          biClrUsed := 256;
          biClrImportant := 0;
          biWidth := FWidth;
          biHeight := FHeight;
        end;
        FPitch := -(FWidth + 3) and not 3;   // sic: negated before masking
        ReallocMem(FMem, Abs(FPitch * FHeight) + 7);
        FBits := Pointer((Integer(FMem) + 7) and not 7);
        Result := GFXE_OK;
      end;
    pfRGB555, pfRGB565:
      begin
        FWidth := AWidth;
        FHeight := AHeight;
        FPixelFormatID := APixelFormatID;
        with FInfo do
        begin
          biSize := SizeOf(TBitmapInfoHeader);
          biPlanes := 1;
          biBitCount := 16;
          biCompression := BI_BITFIELDS;
          biSizeImage := 0;
          biClrUsed := 0;
          biClrImportant := 0;
          biXPelsPerMeter := 0;
          biYPelsPerMeter := 0;
          biWidth := FWidth;
          biHeight := FHeight;
        end;
        case FPixelFormatID of
          pfRGB565:
            begin
              Integer(FColors[0]) := $F800;
              Integer(FColors[1]) := $07E0;
              Integer(FColors[2]) := $001F;
            end;
          pfRGB555:
            begin
              Integer(FColors[0]) := $7C00;
              Integer(FColors[1]) := $03E0;
              Integer(FColors[2]) := $001F;
            end;
        end;
        DC := GetDC(0);
        FHandle := CreateDIBSection(DC, GetBITMAPINFO^, DIB_RGB_COLORS, FBits, 0, 0);
        if FHandle <> 0 then
        begin
          Result := GetObject(FHandle, SizeOf(DS), @DS);
          if Result <> 0 then
          begin
            FWidth := DS.dsBm.bmWidth;
            FHeight := DS.dsBm.bmHeight;
            FPitch := -((DS.dsBm.bmWidthBytes + 3) and not 3);
            Result := GFXE_OK;
          end
          else
            Result := GFXE_ERROR;
        end
        else
          Result := GFXE_ERROR;
        if Result = GFXE_ERROR then Clear;
        ReleaseDC(0, DC);
      end;
    pfRGB24:
      begin
        FWidth := AWidth;
        FHeight := AHeight;
        FPixelFormatID := APixelFormatID;
        with FInfo do
        begin
          biSize := SizeOf(TBitmapInfoHeader);
          biPlanes := 1;
          biBitCount := 24;
          biCompression := BI_RGB;
          biSizeImage := 0;
          biClrUsed := 0;
          biClrImportant := 0;
          biWidth := AWidth;
          biHeight := AHeight;
        end;
        DC := GetDC(0);
        FHandle := CreateDIBSection(DC, GetBITMAPINFO^, DIB_RGB_COLORS, FBits, 0, 0);
        if FHandle <> 0 then
        begin
          Result := GetObject(FHandle, SizeOf(DS), @DS);
          if Result <> 0 then
          begin
            FWidth := DS.dsBm.bmWidth;
            FHeight := DS.dsBm.bmHeight;
            FPitch := -((DS.dsBm.bmWidthBytes + 3) and not 3);
            Result := GFXE_OK;
          end
          else
            Result := GFXE_ERROR;
        end
        else
          Result := GFXE_ERROR;
        if Result = GFXE_ERROR then Clear;
        ReleaseDC(0, DC);
      end;
  else
    Result := GFXE_NOTSUPPORTED;
  end;
end;

function TDIBSurface.Resize(AWidth, AHeight: Integer): HResult;
begin
  if (AWidth <> FWidth) or (AHeight <> FHeight) then
    Result := Setup(AWidth, AHeight, FPixelFormatID, FPalette)
  else
    Result := GFXE_OK;
end;

function TDIBSurface.Lock(var SD: TSurfaceDesc): HResult;
begin
  FillChar(SD, SizeOf(SD), 0);
  case FPixelFormatID of
    pfPAL8:
      begin
        SD.Width := FWidth;
        SD.Height := FHeight;
        SD.BitCount := 8;
        SD.PixelFormatID := pfPAL8;
        SD.ClipRect.Left := 0;
        SD.ClipRect.Right := FWidth;
        SD.ClipRect.Top := 0;
        SD.ClipRect.Bottom := FHeight;
        SD.Pitch := FPitch;
        SD.Palette := FPalette;
        SD.Data := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch);
        Result := GFXE_OK;
      end;
    pfRGB555, pfRGB565:
      begin
        SD.Width := FWidth;
        SD.Height := FHeight;
        SD.PixelFormatID := FPixelFormatID;
        SD.BitCount := 16;
        SD.ClipRect.Left := 0;
        SD.ClipRect.Right := FWidth;
        SD.ClipRect.Top := 0;
        SD.ClipRect.Bottom := FHeight;
        SD.Pitch := FPitch;
        if FPixelFormatID = pfRGB565 then
        begin
          SD.RMask := $F800;
          SD.GMask := $07E0;
          SD.BMask := $001F;
        end
        else if FPixelFormatID = pfRGB555 then
        begin
          SD.RMask := $7C00;
          SD.GMask := $03E0;
          SD.BMask := $001F;
        end;
        SD.Data := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch);
        Result := GFXE_OK;
      end;
    pfRGB24:
      begin
        SD.Width := FWidth;
        SD.Height := FHeight;
        SD.BitCount := 24;
        SD.PixelFormatID := pfRGB24;
        SD.ClipRect.Left := 0;
        SD.ClipRect.Right := FWidth;
        SD.ClipRect.Top := 0;
        SD.ClipRect.Bottom := FHeight;
        SD.Pitch := FPitch;
        SD.RMask := $FF0000;
        SD.GMask := $00FF00;
        SD.BMask := $0000FF;
        SD.Data := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch);
        Result := GFXE_OK;
      end;
  else
    Result := GFXE_NOTSUPPORTED;
  end;
end;

function TDIBSurface.Unlock: HResult;
begin
  Result := GFXE_OK;
end;

function TDIBSurface.Cls(Color: TColor): HResult;
var
  Pixel, V, Y: Integer;
  R, G, B: Byte;
begin
  case FPixelFormatID of
    pfPAL8:
      begin
        FillChar(FBits^, Abs(FPitch * FHeight), FPalette.GetNearestColor(Color));
        Result := GFXE_OK;
      end;
    pfRGB555, pfRGB565:
      begin
        Color := ColorToRGB(Color);
        R := Color and $FF;
        G := Color shr 8 and $FF;
        B := Color shr 16 and $FF;
        case FPixelFormatID of
          pfRGB565: Pixel := (R and $F8) shl 8 + (G and $FC) shl 3 + B shr 3;
          pfRGB555: Pixel := (R and $F8) shl 7 + (G and $F8) shl 2 + B shr 3;
        else
          Pixel := 0;
        end;
        V := Pixel shl 16 + Pixel;
        FillInt(FBits^, Abs(FPitch * FHeight) shr 2, V);
        Result := GFXE_OK;
      end;
    pfRGB24:
      begin
        Color := ColorToRGB(Color);
        if Color <> 0 then
        begin
          V := (Color and $FF) shl 16 + (Color and $FF00) + (Color shr 16);
          for Y := 0 to FHeight - 1 do
            FillTrippleByte(Pointer(Abs(FPitch) * Y + Integer(FBits))^, FWidth, V);
        end
        else
        begin
          V := 0;
          FillInt(FBits^, Abs(FPitch * FHeight) shr 2, V);
        end;
        Result := GFXE_OK;
      end;
  else
    Result := GFXE_NOTSUPPORTED;
  end;
end;

function TDIBSurface.Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
var
  S, D: Pointer;
  DC: HDC;
  SD: TSurfaceDesc;
  R: TRect;
  DR: TRect;
begin
  if Succeeded(Dest.Lock(SD)) then
  begin
    if SrcRect = nil then
    begin
      R.Left := 0;
      R.Right := FWidth;
      R.Top := 0;
      R.Bottom := FHeight;
      SrcRect := @R;
    end;
    case FPixelFormatID of
      pfPAL8:
        begin
          S := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch + SrcRect.Left + SrcRect.Top * FPitch);
          D := Pointer(Integer(SD.Data) + X + Y * SD.Pitch);
          BltRect(S, D, FPitch, SD.Pitch, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top);
          Result := GFXE_OK;
        end;
      pfRGB555, pfRGB565:
        begin
          S := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch + SrcRect.Left * 2 + SrcRect.Top * FPitch);
          D := Pointer(X * 2 + Integer(SD.Data) + Y * SD.Pitch);
          BltRect(S, D, FPitch, SD.Pitch, (SrcRect.Right - SrcRect.Left) * 2, SrcRect.Bottom - SrcRect.Top);
          Result := GFXE_OK;
        end;
      pfRGB24:
        begin
          S := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch + SrcRect.Left * 3 + SrcRect.Top * FPitch);
          D := Pointer(X * 3 + Integer(SD.Data) + Y * SD.Pitch);
          BltRect(S, D, FPitch, SD.Pitch, (SrcRect.Right - SrcRect.Left) * 3, SrcRect.Bottom - SrcRect.Top);
          Result := GFXE_OK;
        end;
    else
      Result := GFXE_NOTSUPPORTED;
    end;
    Dest.Unlock;
  end
  else if Dest is TGDISurface then
  begin
    DC := GetDC(TGDISurface(Dest).Handle);
    DR.Left := X;
    DR.Top := Y;
    DR.Right := SrcRect.Right - SrcRect.Left + X;
    DR.Bottom := SrcRect.Bottom - SrcRect.Top + Y;
    Result := BltDC(DC, SrcRect, @DR);
    ReleaseDC(TGDISurface(Dest).Handle, DC);
  end
  else
    Result := GFXE_CANNOTLOCK;
end;

procedure TDIBSurface.SaveToBMP24(const FileName: string);
var
  SD: TSurfaceDesc;
begin
  Lock(SD);
  SaveSurfaceDescToBMP24(SD, SD.ClipRect, FileName);
  Unlock;
end;

{ TDIB08Surface }

constructor TDIB08Surface.Create(AWidth, AHeight: Integer; APalette: TGFXEPalette);
begin
  inherited Create;
  FPalette := TGFXEPalette.Create;
  FPalette.PixelFormatID := pfRGB24;
  with FInfo do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biPlanes := 1;
    biBitCount := 8;
    biCompression := BI_RGB;
    biSizeImage := 0;
    biClrUsed := 256;
    biClrImportant := 0;
  end;
  Resize(AWidth, AHeight);
  SetPalette(APalette);
end;

destructor TDIB08Surface.Destroy;
begin
  ReallocMem(FMem, 0);
  FPalette.Free;
  FPalette := nil;
  inherited Destroy;
end;

function TDIB08Surface.GetPixelFormatID: Integer;
begin
  Result := pfPAL8;
end;

function TDIB08Surface.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TDIB08Surface.GetHeight: Integer;
begin
  Result := FHeight;
end;

{ Passes the address of the palette field, not the palette (original). }
function TDIB08Surface.UpdatePalette: HResult;
begin
  SetPalette(TGFXEPalette(@FPalette));
  Result := GFXE_OK;
end;

function TDIB08Surface.Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
var
  S, D: Pointer;
  DC: HDC;
  SD: TSurfaceDesc;
  R: TRect;
  DR: TRect;
begin
  if Succeeded(Dest.Lock(SD)) then
  begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Right := FWidth;
    R.Top := 0;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  S := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch + SrcRect.Left + SrcRect.Top * FPitch);
  D := Pointer(Integer(SD.Data) + X + Y * SD.Pitch);
  BltRect(S, D, FPitch, SD.Pitch, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top);
    Dest.Unlock;
    Result := GFXE_OK;
  end
  else if Dest is TGDISurface then
  begin
    DC := GetDC(TGDISurface(Dest).Handle);
    DR.Left := X;
    DR.Top := Y;
    DR.Right := X + (SrcRect.Right - SrcRect.Left);
    DR.Bottom := SrcRect.Bottom - SrcRect.Top + Y;
    Result := BltDC(DC, SrcRect, @DR);
    ReleaseDC(TGDISurface(Dest).Handle, DC);
  end
  else
    Result := GFXE_CANNOTLOCK;
end;

function TDIB08Surface.BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult;
var
  R: TRect;
  DR: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := FWidth;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  if DestRect = nil then
  begin
    GetClientRect(WindowFromDC(DC), DR);
    DestRect := @DR;
  end;
  Result := StretchDIBits(DC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left,
    DestRect.Bottom - DestRect.Top, SrcRect.Left, FHeight - SrcRect.Bottom,
    SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, FBits, PBitmapInfo(@FInfo)^,
    DIB_RGB_COLORS, SRCCOPY);
  if Result = DestRect.Bottom - DestRect.Top then
    Result := GFXE_OK
  else
    Result := GFXE_ERROR;
end;

function TDIB08Surface.Lock(var SD: TSurfaceDesc): HResult;
begin
  FillChar(SD, SizeOf(SD), 0);
  SD.Width := FWidth;
  SD.Height := FHeight;
  SD.BitCount := 8;
  SD.PixelFormatID := pfPAL8;
  SD.ClipRect.Left := 0;
  SD.ClipRect.Right := FWidth;
  SD.ClipRect.Top := 0;
  SD.ClipRect.Bottom := FHeight;
  SD.Pitch := FPitch;
  SD.Palette := FPalette;
  SD.Data := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch);
  Result := GFXE_OK;
end;

function TDIB08Surface.Unlock: HResult;
begin
  Result := GFXE_OK;
end;

function TDIB08Surface.Resize(AWidth, AHeight: Integer): HResult;
begin
  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin
    FWidth := AWidth;
    FHeight := AHeight;
    FPitch := -((FWidth + 7) and not 7);
    with FInfo do
    begin
      biWidth := Abs(FPitch);
      biHeight := FHeight;
    end;
    ReallocMem(FMem, Abs(FPitch * FHeight) + 7);
    FBits := Pointer((Integer(FMem) + 7) and not 7);
    Result := GFXE_OK;
  end
  else
    Result := GFXE_OK;
end;

function TDIB08Surface.Cls(Color: TColor): HResult;
var
  Index: Integer;
begin
  Index := FPalette.GetNearestColor(Color);
  FillChar(FBits^, Abs(FPitch * FHeight), Index);
  Result := GFXE_OK;
end;

procedure TDIB08Surface.SetPalette(Palette: TGFXEPalette);
var
  I: Integer;
begin
  if Palette <> nil then
  begin
    for I := 0 to 255 do
      with Palette.Entries[I] do
      begin
        FColors[I].rgbRed := R;
        FColors[I].rgbGreen := G;
        FColors[I].rgbBlue := B;
      end;
    if Palette <> TGFXEPalette(@FPalette) then FPalette.Assign(Palette);
  end;
end;

{ TDIB16Surface }

constructor TDIB16Surface.Create(AWidth, AHeight, APixelFormatID: Integer);
begin
  inherited Create;
  FWidth := 0;
  FHeight := 0;
  FPixelFormatID := APixelFormatID;
  with FInfo do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biPlanes := 1;
    biBitCount := 16;
    biCompression := BI_BITFIELDS;
    biSizeImage := 0;
    biClrUsed := 0;
    biClrImportant := 0;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
  end;
  SetPixelFormatID(FPixelFormatID);
  Resize(AWidth, AHeight);
end;

destructor TDIB16Surface.Destroy;
begin
  Resize(0, 0);
  inherited Destroy;
end;

function TDIB16Surface.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TDIB16Surface.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TDIB16Surface.GetPixelFormatID: Integer;
begin
  Result := FPixelFormatID;
end;

procedure TDIB16Surface.SetPixelFormatID(Value: Integer);
begin
  if (Value = pfRGB565) or (Value = pfRGB555) then
  begin
    FPixelFormatID := Value;
    case FPixelFormatID of
      pfRGB565:
        begin
          FMasks[0] := $F800;
          FMasks[1] := $07E0;
          FMasks[2] := $001F;
        end;
      pfRGB555:
        begin
          FMasks[0] := $7C00;
          FMasks[1] := $03E0;
          FMasks[2] := $001F;
        end;
    end;
  end
  else
    raise Exception.Create('PixelFormatID not supported');
end;

function TDIB16Surface.Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
var
  S, D: Pointer;
  DC: HDC;
  SD: TSurfaceDesc;
  R: TRect;
  DR: TRect;
begin
  if Succeeded(Dest.Lock(SD)) then
  begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Right := FWidth;
    R.Top := 0;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  S := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch + SrcRect.Left * 2 + SrcRect.Top * FPitch);
  D := Pointer(Integer(SD.Data) + X * 2 + Y * SD.Pitch);
  BltRect(S, D, FPitch, SD.Pitch, (SrcRect.Right - SrcRect.Left) * 2, SrcRect.Bottom - SrcRect.Top);
    Dest.Unlock;
    Result := GFXE_OK;
  end
  else if Dest is TGDISurface then
  begin
    DC := GetDC(TGDISurface(Dest).Handle);
    DR.Left := X;
    DR.Top := Y;
    DR.Right := X + (SrcRect.Right - SrcRect.Left);
    DR.Bottom := SrcRect.Bottom - SrcRect.Top + Y;
    Result := BltDC(DC, SrcRect, @DR);
    ReleaseDC(TGDISurface(Dest).Handle, DC);
  end
  else
    Result := GFXE_CANNOTLOCK;
end;

function TDIB16Surface.BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult;
var
  R: TRect;
  DR: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := FWidth;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  if DestRect = nil then
  begin
    GetClientRect(WindowFromDC(DC), DR);
    DestRect := @DR;
  end;
  SetStretchBltMode(DC, COLORONCOLOR);
  Result := StretchDIBits(DC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left,
    DestRect.Bottom - DestRect.Top, SrcRect.Left, FInfo.biHeight - SrcRect.Bottom,
    SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, FBits, PBitmapInfo(@FInfo)^,
    DIB_RGB_COLORS, SRCCOPY);
  if Result = DestRect.Bottom - DestRect.Top then
    Result := GFXE_OK
  else
    Result := GFXE_ERROR;
end;

function TDIB16Surface.Lock(var SD: TSurfaceDesc): HResult;
begin
  FillChar(SD, SizeOf(SD), 0);
  SD.Width := FWidth;
  SD.Height := FHeight;
  SD.PixelFormatID := FPixelFormatID;
  SD.BitCount := 16;
  SD.ClipRect.Left := 0;
  SD.ClipRect.Right := FWidth;
  SD.ClipRect.Top := 0;
  SD.ClipRect.Bottom := FHeight;
  SD.Pitch := FPitch;
  if FPixelFormatID = pfRGB565 then
  begin
    SD.RMask := $F800;
    SD.GMask := $07E0;
    SD.BMask := $001F;
  end;
  if FPixelFormatID = pfRGB555 then
  begin
    SD.RMask := $7C00;
    SD.GMask := $03E0;
    SD.BMask := $001F;
  end;
  SD.Data := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch);
  Result := GFXE_OK;
end;

function TDIB16Surface.Unlock: HResult;
begin
  Result := GFXE_OK;
end;

function TDIB16Surface.Cls(Color: TColor): HResult;
var
  Pixel, V: Integer;
  R, G, B: Byte;
begin
  Color := ColorToRGB(Color);
  R := Color and $FF;
  G := Color shr 8 and $FF;
  B := Color shr 16 and $FF;
  case FPixelFormatID of
    pfRGB565: Pixel := (R and $F8) shl 8 + (G and $FC) shl 3 + B shr 3;
    pfRGB555: Pixel := (R and $F8) shl 7 + (G and $F8) shl 2 + B shr 3;
  else
    Pixel := 0;
  end;
  V := Pixel shl 16 + Pixel;
  FillInt(FBits^, Abs(FPitch * FHeight) shr 2, V);
  Result := GFXE_OK;
end;

function TDIB16Surface.Resize(AWidth, AHeight: Integer): HResult;
var
  B: Boolean;
  DC: HDC;
  BI: PBitmapInfo;
  DS: TDIBSection;
begin
  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin
    if FHandle <> 0 then
    begin
      B := DeleteObject(FHandle);
      Assert(B, 'Cannot delete GDI object');
      FHandle := 0;
    end;
    if (AWidth <> 0) and (AHeight <> 0) then
    begin
      DC := GetDC(0);
      BI := @FInfo;
      with FInfo do
      begin
        biWidth := AWidth;
        biHeight := AHeight;
      end;
      FHandle := CreateDIBSection(DC, BI^, DIB_RGB_COLORS, FBits, 0, 0);
      if FHandle <> 0 then
      begin
        Result := GetObject(FHandle, SizeOf(DS), @DS);
        if Result <> 0 then
        begin
          FWidth := DS.dsBm.bmWidth;
          FHeight := DS.dsBm.bmHeight;
          FPitch := -((DS.dsBm.bmWidthBytes + 3) and not 3);
          Result := GFXE_OK;
        end
        else Result := GFXE_ERROR;
      end
      else
        Result := GFXE_ERROR;
      if Result = GFXE_ERROR then
      begin
        if FHandle <> 0 then
        begin
          B := DeleteObject(FHandle);
          Assert(B, 'Cannot delete GDI object');
          FHandle := 0;
        end;
        FWidth := 0;
        FHeight := 0;
      end;
      ReleaseDC(0, DC);
    end
    else
    begin
      FWidth := 0;
      FHeight := 0;
      FPitch := 0;
      Result := GFXE_OK;
    end;
  end
  else
    Result := GFXE_OK;
end;

{ TDIB24Surface }

constructor TDIB24Surface.Create(AWidth, AHeight: Integer);
begin
  inherited Create;
  with FInfo do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biPlanes := 1;
    biBitCount := 24;
    biCompression := BI_RGB;
    biSizeImage := 0;
    biClrUsed := 0;
    biClrImportant := 0;
  end;
  Resize(AWidth, AHeight);
end;

destructor TDIB24Surface.Destroy;
begin
  Resize(0, 0);
  inherited Destroy;
end;

function TDIB24Surface.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TDIB24Surface.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TDIB24Surface.GetBMPInfo: PBitmapInfoHeader;
begin
  Result := @FInfo;
end;

function TDIB24Surface.Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
var
  S, D: Pointer;
  DC: HDC;
  SD: TSurfaceDesc;
  R: TRect;
  DR: TRect;
begin
  if Succeeded(Dest.Lock(SD)) then
  begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Right := FWidth;
    R.Top := 0;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  S := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch + SrcRect.Left * 3 + SrcRect.Top * FPitch);
  D := Pointer(Integer(SD.Data) + X * 3 + Y * SD.Pitch);
  BltRect(S, D, FPitch, SD.Pitch, (SrcRect.Right - SrcRect.Left) * 3, SrcRect.Bottom - SrcRect.Top);
    Dest.Unlock;
    Result := GFXE_OK;
  end
  else if Dest is TGDISurface then
  begin
    DC := GetDC(TGDISurface(Dest).Handle);
    DR.Left := X;
    DR.Top := Y;
    DR.Right := X + (SrcRect.Right - SrcRect.Left);
    DR.Bottom := SrcRect.Bottom - SrcRect.Top + Y;
    Result := BltDC(DC, SrcRect, @DR);
    ReleaseDC(TGDISurface(Dest).Handle, DC);
  end
  else
    Result := GFXE_CANNOTLOCK;
end;

function TDIB24Surface.BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult;
var
  R: TRect;
  DR: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := FWidth;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  if DestRect = nil then
  begin
    GetClientRect(WindowFromDC(DC), DR);
    DestRect := @DR;
  end;
  Result := StretchDIBits(DC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left,
    DestRect.Bottom - DestRect.Top, SrcRect.Left, FInfo.biHeight - SrcRect.Bottom,
    SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, FBits, PBitmapInfo(@FInfo)^,
    DIB_RGB_COLORS, SRCCOPY);
  if Result = DestRect.Bottom - DestRect.Top then
    Result := GFXE_OK
  else
    Result := GFXE_ERROR;
end;

function TDIB24Surface.Cls(Color: TColor): HResult;
var
  V, Y: Integer;
begin
  Color := ColorToRGB(Color);
  if Color <> 0 then
  begin
    V := (Color and $FF) shl 16 + (Color and $FF00) + (Color shr 16);
    for Y := 0 to FHeight - 1 do
      FillTrippleByte(Pointer(Abs(FPitch) * Y + Integer(FBits))^, FWidth, V);
  end
  else
  begin
    V := 0;
    FillInt(FBits^, Abs(FPitch * FHeight) shr 2, V);
  end;
  Result := GFXE_OK;
end;

function TDIB24Surface.Lock(var SD: TSurfaceDesc): HResult;
begin
  FillChar(SD, SizeOf(SD), 0);
  SD.Width := FWidth;
  SD.Height := FHeight;
  SD.BitCount := 24;
  SD.PixelFormatID := pfRGB24;
  SD.ClipRect.Left := 0;
  SD.ClipRect.Right := FWidth;
  SD.ClipRect.Top := 0;
  SD.ClipRect.Bottom := FHeight;
  SD.Pitch := FPitch;
  SD.RMask := $FF0000;
  SD.GMask := $00FF00;
  SD.BMask := $0000FF;
  SD.Data := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch);
  Result := GFXE_OK;
end;

function TDIB24Surface.Unlock: HResult;
begin
  Result := GFXE_OK;
end;

function TDIB24Surface.Resize(AWidth, AHeight: Integer): HResult;
var
  DC: HDC;
  BI: PBitmapInfo;
  DS: TDIBSection;
  Res: Integer;
begin
  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin
    if FHandle <> 0 then
    begin
      DeleteObject(FHandle);
      FHandle := 0;
    end;
    if (AWidth <> 0) and (AHeight <> 0) then
    begin
      DC := GetDC(0);
      BI := @FInfo;
      with FInfo do
      begin
        biWidth := AWidth;
        biHeight := AHeight;
      end;
      FHandle := CreateDIBSection(DC, BI^, DIB_RGB_COLORS, FBits, 0, 0);
      if FHandle <> 0 then
        if GetObject(FHandle, SizeOf(DS), @DS) <> 0 then
        begin
          FWidth := DS.dsBm.bmWidth;
          FHeight := DS.dsBm.bmHeight;
          FPitch := -((DS.dsBm.bmWidthBytes + 3) and not 3);
          Res := GFXE_OK;
        end
        else
          Res := GFXE_ERROR
      else
        Res := GFXE_ERROR;
      if Res = GFXE_ERROR then
      begin
        if FHandle <> 0 then
        begin
          DeleteObject(FHandle);
          FHandle := 0;
        end;
        FWidth := 0;
        FHeight := 0;
      end;
      ReleaseDC(0, DC);
    end
    else
    begin
      FWidth := 0;
      FHeight := 0;
      FPitch := 0;
    end;
    Result := GFXE_OK;
  end
  else
    Result := GFXE_OK;
end;

{ TDIB32Surface }

constructor TDIB32Surface.Create(AWidth, AHeight: Integer);
begin
  inherited Create;
  with FInfo do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
    biSizeImage := 0;
    biClrUsed := 0;
    biClrImportant := 0;
  end;
  Resize(AWidth, AHeight);
end;

destructor TDIB32Surface.Destroy;
begin
  ReallocMem(FMem, 0);
  inherited Destroy;
end;

function TDIB32Surface.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TDIB32Surface.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TDIB32Surface.Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
var
  S, D: Pointer;
  DC: HDC;
  SD: TSurfaceDesc;
  R: TRect;
  DR: TRect;
begin
  if Succeeded(Dest.Lock(SD)) then
  begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Right := FWidth;
    R.Top := 0;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  S := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch + SrcRect.Left * 4 + SrcRect.Top * FPitch);
  D := Pointer(Integer(SD.Data) + X * 4 + Y * SD.Pitch);
  BltRect(S, D, FPitch, SD.Pitch, (SrcRect.Right - SrcRect.Left) * 4, SrcRect.Bottom - SrcRect.Top);
    Dest.Unlock;
    Result := GFXE_OK;
  end
  else if Dest is TGDISurface then
  begin
    DC := GetDC(TGDISurface(Dest).Handle);
    DR.Left := X;
    DR.Top := Y;
    DR.Right := X + (SrcRect.Right - SrcRect.Left);
    DR.Bottom := SrcRect.Bottom - SrcRect.Top + Y;
    Result := BltDC(DC, SrcRect, @DR);
    ReleaseDC(TGDISurface(Dest).Handle, DC);
  end
  else
    Result := GFXE_CANNOTLOCK;
end;

function TDIB32Surface.BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult;
var
  R: TRect;
  DR: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := FWidth;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  if DestRect = nil then
  begin
    GetClientRect(WindowFromDC(DC), DR);
    DestRect := @DR;
  end;
  Result := StretchDIBits(DC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left,
    DestRect.Bottom - DestRect.Top, SrcRect.Left, FInfo.biHeight - SrcRect.Bottom,
    SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, FBits, PBitmapInfo(@FInfo)^,
    DIB_RGB_COLORS, SRCCOPY);
  if Result = DestRect.Bottom - DestRect.Top then
    Result := GFXE_OK
  else
    Result := GFXE_ERROR;
end;

function TDIB32Surface.Lock(var SD: TSurfaceDesc): HResult;
begin
  FillChar(SD, SizeOf(SD), 0);
  SD.Width := FWidth;
  SD.Height := FHeight;
  SD.BitCount := 32;
  SD.PixelFormatID := pfRGB32;
  SD.ClipRect.Left := 0;
  SD.ClipRect.Right := FWidth;
  SD.ClipRect.Top := 0;
  SD.ClipRect.Bottom := FHeight;
  SD.Pitch := FPitch;
  SD.RMask := $00FF0000;
  SD.GMask := $0000FF00;
  SD.BMask := $000000FF;
  SD.AMask := Integer($FF000000);
  SD.Data := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch);
  Result := GFXE_OK;
end;

function TDIB32Surface.Unlock: HResult;
begin
  Result := GFXE_OK;
end;

function TDIB32Surface.Cls(Color: TColor): HResult;
var
  V: Integer;
begin
  Color := ColorToRGB(Color);
  V := (Color and $FF) shl 16 + (Color and $FF00) + (Color shr 16 and $FF);
  FillInt(FBits^, Abs(FPitch * FHeight) shr 2, V);
  Result := GFXE_OK;
end;

function TDIB32Surface.Resize(AWidth, AHeight: Integer): HResult;
begin
  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin
    FWidth := AWidth;
    FHeight := AHeight;
    FPitch := -((FWidth * 4 + 7) and not 7);
    with FInfo do
    begin
      biWidth := Abs(FPitch) shr 2;
      biHeight := FHeight;
    end;
    ReallocMem(FMem, Abs(FPitch * FHeight) + 7);
    FBits := Pointer((Integer(FMem) + 7) and not 7);
    Result := GFXE_OK;
  end
  else
    Result := GFXE_OK;
end;

{ The pixel format converters. The 16 bit source ones are assembler (two pixels per step when
  source and destination are dword aligned); the 8, 24 and 32 bit source ones are Pascal. }

procedure RemapSurface16to16(Src, Dst: Pointer; Table: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     ebx, Height
        mov     L1, esp
        mov     edx, Table
        mov     esi, Src
        mov     edi, Dst
        test    ebx, ebx
        je      @@done
        test    eax, eax
        je      @@done
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L2, ecx
        mov     L3, eax
        shr     ebx, 2
        mov     L4, ebx
        lea     ecx, [@@dwords]
        mov     L5, ecx
        jmp     @@start
@@unaligned:
        mov     L4, 0
        mov     L3, eax
        lea     ecx, [@@tail]
        mov     L5, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        shl     ebx, 1
        sub     eax, ebx
        mov     L6, eax
        mov     ebx, Width
        mov     eax, DstPitch
        shl     ebx, 1
        sub     eax, ebx
        mov     L7, eax
        jmp     dword ptr L5
@@dwords:
        mov     esp, L4
@@d1:
        mov     eax, [esi]
        lea     edi, [edi+8]
        mov     ebx, eax
        mov     ecx, [esi+4]
        shr     ebx, 16
        and     eax, $FFFF
        mov     bx, [edx+ebx*2]
        mov     ax, [edx+eax*2]
        shl     ebx, 16
        lea     esi, [esi+8]
        or      eax, ebx
        mov     ebx, ecx
        shr     ecx, 16
        and     ebx, $FFFF
        mov     cx, [edx+ecx*2]
        mov     [edi-8], eax
        mov     bx, [edx+ebx*2]
        shl     ecx, 16
        or      ecx, ebx
        dec     esp
        mov     [edi-4], ecx
        jne     @@d1
        jmp     dword ptr L2
@@tail:
        xor     eax, eax
        mov     ebx, L3
@@t1:
        mov     ax, [esi]
        lea     edi, [edi+2]
        mov     cx, [edx+eax*2]
        lea     esi, [esi+2]
        mov     [edi-2], cx
        dec     ebx
        jne     @@t1
@@nextrow:
        add     esi, L6
        add     edi, L7
        dec     Height
        je      @@done
        jmp     dword ptr L5
@@done:
        mov     esp, L1
@@exit:
        pop     esi
        pop     edi
        pop     ebx
end;

procedure RemapSurface16to08(Src, Dst: Pointer; Table: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     edx, Table
        mov     esi, Src
        mov     edi, Dst
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L1, ecx
        mov     L2, eax
        shr     ebx, 2
        mov     L3, ebx
        lea     ecx, [@@dwords]
        mov     L4, ecx
        jmp     @@start
@@unaligned:
        mov     L3, 0
        mov     L2, eax
        lea     ecx, [@@tail]
        mov     L4, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        shl     ebx, 1
        sub     eax, ebx
        mov     L5, eax
        mov     ebx, Width
        mov     eax, DstPitch
        sub     eax, ebx
        mov     L6, eax
        mov     L7, esp
        jmp     dword ptr L4
@@dwords:
        mov     esp, L3
@@d1:
        mov     eax, [esi+4]
        lea     edi, [edi+4]
        mov     ebx, eax
        and     eax, $FFFF
        shr     ebx, 16
        mov     cl, [edx+eax]
        mov     ch, [edx+ebx]
        mov     eax, [esi]
        shl     ecx, 16
        mov     ebx, eax
        and     eax, $FFFF
        shr     ebx, 16
        mov     cl, [edx+eax]
        mov     ch, [edx+ebx]
        lea     esi, [esi+8]
        mov     [edi-4], ecx
        dec     esp
        jne     @@d1
        jmp     dword ptr L1
@@tail:
        xor     eax, eax
        mov     ebx, L2
        test    ebx, ebx
        je      @@nextrow
@@t1:
        mov     ax, [esi]
        inc     edi
        mov     cl, [edx+eax]
        add     esi, 2
        mov     [edi-1], cl
        dec     ebx
        jne     @@t1
@@nextrow:
        add     esi, L5
        add     edi, L6
        dec     Height
        je      @@done
        jmp     dword ptr L4
@@done:
        mov     esp, L7
        pop     esi
        pop     edi
        pop     ebx
end;

procedure RemapSurface16to32(Src, Dst: Pointer; Table: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     edx, Table
        mov     esi, Src
        mov     edi, Dst
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L1, ecx
        mov     L2, eax
        shr     ebx, 2
        mov     L3, ebx
        lea     ecx, [@@dwords]
        mov     L4, ecx
        jmp     @@start
@@unaligned:
        mov     L3, 0
        mov     L2, eax
        lea     ecx, [@@tail]
        mov     L4, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        shl     ebx, 1
        sub     eax, ebx
        mov     L5, eax
        mov     ebx, Width
        mov     eax, DstPitch
        shl     ebx, 2
        sub     eax, ebx
        mov     L6, eax
        jmp     dword ptr L4
@@dwords:
        mov     ecx, L3
@@d1:
        mov     eax, [esi]
        lea     edi, [edi+16]
        mov     ebx, eax
        and     eax, $FFFF
        shr     ebx, 16
        mov     eax, [edx+eax*4]
        mov     ebx, [edx+ebx*4]
        mov     [edi-16], eax
        mov     [edi-12], ebx
        mov     eax, [esi+4]
        lea     esi, [esi+8]
        mov     ebx, eax
        and     eax, $FFFF
        shr     ebx, 16
        mov     eax, [edx+eax*4]
        mov     ebx, [edx+ebx*4]
        mov     [edi-8], eax
        mov     [edi-4], ebx
        dec     ecx
        jne     @@d1
        jmp     dword ptr L1
@@tail:
        xor     eax, eax
        mov     ebx, L2
@@t1:
        mov     ax, [esi]
        lea     edi, [edi+4]
        mov     ecx, [edx+eax*4]
        lea     esi, [esi+2]
        mov     [edi-4], ecx
        dec     ebx
        jne     @@t1
@@nextrow:
        add     esi, L5
        add     edi, L6
        dec     Height
        je      @@done
        jmp     dword ptr L4
@@done:
        pop     esi
        pop     edi
        pop     ebx
end;

procedure RemapSurface555to32(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     esi, Src
        mov     edi, Dst
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L1, ecx
        mov     L2, eax
        shr     ebx, 2
        mov     L3, ebx
        lea     ecx, [@@dwords]
        mov     L4, ecx
        jmp     @@start
@@unaligned:
        mov     L3, 0
        mov     L2, eax
        lea     ecx, [@@tail]
        mov     L4, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        shl     ebx, 1
        sub     eax, ebx
        mov     L5, eax
        mov     ebx, Width
        mov     eax, DstPitch
        shl     ebx, 2
        sub     eax, ebx
        mov     L6, eax
        mov     L7, esp
        jmp     dword ptr L4
@@dwords:
        mov     esp, L3
@@d1:
        mov     ecx, [esi]
        lea     edi, [edi+16]
        lea     eax, [ecx*8]
        mov     ebx, [esi]
        shl     ah, 3
        mov     edx, eax
        shl     ebx, 9
        and     eax, $F8F8
        ror     edx, 16
        and     ebx, $F80000
        shl     dh, 3
        or      eax, ebx
        shr     ecx, 7
        and     edx, $F8F8
        and     ecx, $F80000
        mov     [edi-16], eax
        or      edx, ecx
        mov     ecx, [esi+4]
        mov     [edi-12], edx
        mov     ebx, ecx
        lea     eax, [ecx*8]
        lea     esi, [esi+8]
        shl     ah, 3
        mov     edx, eax
        shl     ebx, 9
        and     eax, $F8F8
        ror     edx, 16
        and     ebx, $F80000
        shl     dh, 3
        or      eax, ebx
        shr     ecx, 7
        and     edx, $F8F8
        and     ecx, $F80000
        mov     [edi-8], eax
        or      ecx, edx
        dec     esp
        mov     [edi-4], ecx
        jne     @@d1
        jmp     dword ptr L1
@@tail:
        mov     esp, L7
        mov     ecx, L2
@@t1:
        mov     ax, [esi]
        lea     edi, [edi+4]
        shl     eax, 3
        mov     ebx, eax
        shl     ah, 3
        lea     esi, [esi+2]
        shr     ebx, 12
        and     eax, $F8F8
        and     ebx, $F80000
        or      eax, ebx
        dec     ecx
        mov     [edi-4], eax
        jne     @@t1
@@nextrow:
        add     esi, L5
        add     edi, L6
        dec     Height
        je      @@done
        jmp     dword ptr L4
@@done:
        mov     esp, L7
        pop     esi
        pop     edi
        pop     ebx
end;

procedure RemapSurface565to32(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     esi, Src
        mov     edi, Dst
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L1, ecx
        mov     L2, eax
        shr     ebx, 2
        mov     L3, ebx
        lea     ecx, [@@dwords]
        mov     L4, ecx
        jmp     @@start
@@unaligned:
        mov     L3, 0
        mov     L2, eax
        lea     ecx, [@@tail]
        mov     L4, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        shl     ebx, 1
        sub     eax, ebx
        mov     L5, eax
        mov     ebx, Width
        mov     eax, DstPitch
        shl     ebx, 2
        sub     eax, ebx
        mov     L6, eax
        mov     L7, esp
        jmp     dword ptr L4
@@dwords:
        mov     esp, L3
@@d1:
        mov     ecx, [esi]
        lea     edi, [edi+16]
        lea     eax, [ecx*8]
        mov     ebx, [esi]
        shl     ah, 2
        mov     edx, eax
        shl     ebx, 8
        and     eax, $FCF8
        ror     edx, 16
        and     ebx, $F80000
        shl     dh, 2
        or      eax, ebx
        shr     ecx, 8
        and     edx, $FCF8
        and     ecx, $F80000
        mov     [edi-16], eax
        or      edx, ecx
        mov     ecx, [esi+4]
        mov     [edi-12], edx
        mov     ebx, ecx
        lea     eax, [ecx*8]
        lea     esi, [esi+8]
        shl     ah, 2
        mov     edx, eax
        shl     ebx, 8
        and     eax, $FCF8
        ror     edx, 16
        and     ebx, $F80000
        shl     dh, 2
        or      eax, ebx
        shr     ecx, 8
        and     edx, $F8F8          // sic: the second pixel pair masks the green like 555
        and     ecx, $F80000
        mov     [edi-8], eax
        or      ecx, edx
        dec     esp
        mov     [edi-4], ecx
        jne     @@d1
        jmp     dword ptr L1
@@tail:
        mov     esp, L7
        mov     ecx, L2
@@t1:
        mov     ax, [esi]
        lea     edi, [edi+4]
        shl     eax, 3
        mov     ebx, eax
        shl     ah, 2
        lea     esi, [esi+2]
        shl     ebx, 5
        and     eax, $FCF8
        and     ebx, $F80000
        or      eax, ebx
        dec     ecx
        mov     [edi-4], eax
        jne     @@t1
@@nextrow:
        add     esi, L5
        add     edi, L6
        dec     Height
        je      @@done
        jmp     dword ptr L4
@@done:
        mov     esp, L7
        pop     esi
        pop     edi
        pop     ebx
end;

procedure RemapSurface555to565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     ebx, Height
        mov     esi, Src
        mov     edi, Dst
        test    eax, eax
        je      @@exit
        test    ebx, ebx
        je      @@exit
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L1, ecx
        mov     L2, eax
        shr     ebx, 2
        je      @@l3
        mov     L3, ebx
        lea     ecx, [@@dwords]
        mov     L4, ecx
        jmp     @@start
@@l3:
        lea     ecx, [@@tail]
        mov     L4, ecx
        jmp     @@start
@@unaligned:
        mov     L3, 0
        mov     L2, eax
        lea     ecx, [@@tail]
        mov     L4, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L5, eax
        mov     ebx, Width
        mov     eax, DstPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L6, eax
        mov     L7, esp
        jmp     dword ptr L4
@@dwords:
        mov     esp, L3
@@d1:
        mov     ecx, [esi]
        mov     edx, [esi+4]
        mov     eax, ecx
        mov     ebx, edx
        add     ecx, ecx
        and     eax, $1F001F
        add     edx, edx
        and     ebx, $1F001F
        and     ecx, $FFC0FFC0
        and     edx, $FFC0FFC0
        or      eax, ecx
        or      ebx, edx
        mov     [edi], eax
        mov     [edi+4], ebx
        lea     esi, [esi+8]
        lea     edi, [edi+8]
        dec     esp
        jne     @@d1
        jmp     dword ptr L1
@@tail:
        mov     ecx, L2
@@t1:
        mov     ax, [esi]
        lea     edi, [edi+2]
        mov     ebx, eax
        add     eax, eax
        and     ebx, $1F
        and     eax, $FFC0
        lea     esi, [esi+2]
        or      eax, ebx
        mov     [edi-2], ax
        dec     ecx
        jne     @@t1
@@nextrow:
        add     esi, L5
        add     edi, L6
        dec     Height
        je      @@done
        jmp     dword ptr L4
@@done:
        mov     esp, L7
@@exit:
        pop     esi
        pop     edi
        pop     ebx
end;

procedure RemapSurface565to555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     eax, Width
        mov     ebx, Height
        mov     esi, Src
        mov     edi, Dst
        test    eax, eax
        je      @@exit
        test    ebx, ebx
        je      @@exit
        test    esi, 3
        jne     @@unaligned
        test    edi, 3
        jne     @@unaligned
        mov     ebx, eax
        and     eax, 3
        je      @@l1
        lea     ecx, [@@tail]
        jmp     @@l2
@@l1:
        lea     ecx, [@@nextrow]
@@l2:
        mov     L1, ecx
        mov     L2, eax
        shr     ebx, 2
        je      @@l3
        mov     L3, ebx
        lea     ecx, [@@dwords]
        mov     L4, ecx
        jmp     @@start
@@l3:
        lea     ecx, [@@tail]
        mov     L4, ecx
        jmp     @@start
@@unaligned:
        mov     L3, 0
        mov     L2, eax
        lea     ecx, [@@tail]
        mov     L4, ecx
@@start:
        mov     ebx, Width
        mov     eax, SrcPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L5, eax
        mov     ebx, Width
        mov     eax, DstPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L6, eax
        mov     L7, esp
        jmp     dword ptr L4
@@dwords:
        mov     esp, L3
@@d1:
        mov     ecx, [esi]
        mov     edx, [esi+4]
        mov     eax, ecx
        mov     ebx, edx
        shr     ecx, 1
        and     eax, $1F001F
        shr     edx, 1
        and     ebx, $1F001F
        and     ecx, $7FE07FE0
        and     edx, $7FE07FE0
        or      eax, ecx
        or      ebx, edx
        mov     [edi], eax
        mov     [edi+4], ebx
        lea     esi, [esi+8]
        lea     edi, [edi+8]
        dec     esp
        jne     @@d1
        jmp     dword ptr L1
@@tail:
        mov     ecx, L2
@@t1:
        mov     ax, [esi]
        lea     edi, [edi+2]
        mov     ebx, eax
        shr     eax, 1
        and     ebx, $1F
        and     eax, $7FE0
        lea     esi, [esi+2]
        or      eax, ebx
        mov     [edi-2], ax
        dec     ecx
        jne     @@t1
@@nextrow:
        add     esi, L5
        add     edi, L6
        dec     Height
        je      @@done
        jmp     dword ptr L4
@@done:
        mov     esp, L7
@@exit:
        pop     esi
        pop     edi
        pop     ebx
end;

procedure RemapSurface24to565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  Y: Integer;
  S: PByteArray;
  D: PWord;
  X: Integer;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      D^ := (S[2] and $F8) shl 8 + (S[1] and $FC) shl 3 + S[0] shr 3;
      S := Pointer(Integer(S) + 3);
      D := Pointer(Integer(D) + 2);
    end;
  end;
end;

procedure RemapSurface24to555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  Y: Integer;
  S: PByteArray;
  D: PWord;
  X: Integer;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      D^ := (S[2] and $F8) shl 7 + (S[1] and $F8) shl 2 + S[0] shr 3;
      S := Pointer(Integer(S) + 3);
      D := Pointer(Integer(D) + 2);
    end;
  end;
end;

procedure RemapSurface555to24(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  X, Y: Integer;
  D: PByteArray;
  S: PWord;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      D[2] := (S^ and $7C00) shr 7;
      D[1] := (S^ and $03E0) shr 2;
      D[0] := (S^ and $1F) shl 3;
      D := Pointer(Integer(D) + 3);
      S := Pointer(Integer(S) + 2);
    end;
  end;
end;

procedure RemapSurface565to24(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  X, Y: Integer;
  D: PByteArray;
  S: PWord;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      D[2] := (S^ and $F800) shr 8;
      D[1] := (S^ and $07E0) shr 3;
      D[0] := (S^ and $1F) shl 3;
      D := Pointer(Integer(D) + 3);
      S := Pointer(Integer(S) + 2);
    end;
  end;
end;

{ Both 32 bit converters produce 555 pixels from bytes 1-3 of the source (original). }
procedure RemapSurface32to565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  Y: Integer;
  S: PByteArray;
  D: PWord;
  X: Integer;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      D^ := (S[1] and $F8) shl 7 + (S[2] and $F8) shl 2 + S[3] shr 3;
      S := Pointer(Integer(S) + 4);
      D := Pointer(Integer(D) + 2);
    end;
  end;
end;

procedure RemapSurface32to555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer); pascal;
var
  Y: Integer;
  S: PByteArray;
  D: PWord;
  X: Integer;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      D^ := (S[1] and $F8) shl 7 + (S[2] and $F8) shl 2 + S[3] shr 3;
      S := Pointer(Integer(S) + 4);
      D := Pointer(Integer(D) + 2);
    end;
  end;
end;

procedure RemapSurface08to565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Palette: TGFXEPalette); pascal;
var
  X, Y: Integer;
  S: PByte;
  D: PWord;
  E: PPaletteEntry;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      E := @Palette.Entries[S^];
      D^ := (E.R and $F8) shl 8 + (E.G and $FC) shl 3 + E.B shr 3;
      S := Pointer(Integer(S) + 1);
      D := Pointer(Integer(D) + 2);
    end;
  end;
end;

procedure RemapSurface08to555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Palette: TGFXEPalette); pascal;
var
  X, Y: Integer;
  S: PByte;
  D: PWord;
  E: PPaletteEntry;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      E := @Palette.Entries[S^];
      D^ := (E.R and $F8) shl 7 + (E.G and $F8) shl 2 + E.B shr 3;
      S := Pointer(Integer(S) + 1);
      D := Pointer(Integer(D) + 2);
    end;
  end;
end;

procedure RemapSurface08to24(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Palette: TGFXEPalette); pascal;
var
  X, Y: Integer;
  S: PByte;
  D: PByteArray;
  E: PPaletteEntry;
begin
  for Y := 0 to Height - 1 do
  begin
    S := Pointer(Integer(Src) + SrcPitch * Y);
    D := Pointer(Integer(Dst) + DstPitch * Y);
    for X := 0 to Width - 1 do
    begin
      E := @Palette.Entries[S^];
      D[2] := E.R;
      D[1] := E.G;
      D[0] := E.B;
      S := Pointer(Integer(S) + 1);
      D := Pointer(Integer(D) + 3);
    end;
  end;
end;

function RemapSurfacePart(const Src: TSurfaceDesc; SrcX, SrcY, Width, Height: Integer; const Dest: TSurfaceDesc; DestX, DestY: Integer): HResult;
var
  S, D: Pointer;
begin
  Result := GFXE_OK;
  if SrcX + Width > Src.Width then Width := Src.Width - SrcX;
  if SrcY + Height > Src.Height then Height := Src.Height - SrcY;
  if SrcX < 0 then
  begin
    DestX := DestX - SrcX;
    Width := Width + SrcX;
    SrcX := 0;
  end;
  if SrcY < 0 then
  begin
    DestY := DestY - SrcY;
    Height := Height + SrcY;
    SrcY := 0;
  end;
  if DestX + Width > Dest.Width then Width := Dest.Width - DestX;
  if DestY + Height > Dest.Height then Height := Dest.Height - DestY;
  if DestX < 0 then
  begin
    SrcX := SrcX - DestX;
    Width := Width + DestX;
    DestX := 0;
  end;
  if DestY < 0 then
  begin
    SrcY := SrcY - DestY;
    Height := Height + DestY;
    DestY := 0;
  end;
  if (Width > 0) and (Height > 0) then
  begin
    S := Pointer(Integer(Src.Data) + Src.Pitch * SrcY + ((Src.BitCount + 7) shr 3) * SrcX);
    D := Pointer(Integer(Dest.Data) + Dest.Pitch * DestY + ((Dest.BitCount + 7) shr 3) * DestX);
    case Src.PixelFormatID of
      pfPAL8:
        case Dest.PixelFormatID of
          pfRGB565: RemapSurface08to565(S, D, Src.Pitch, Dest.Pitch, Width, Height, Src.Palette);
          pfRGB555: RemapSurface08to555(S, D, Src.Pitch, Dest.Pitch, Width, Height, Src.Palette);
          pfRGB24: RemapSurface08to24(S, D, Src.Pitch, Dest.Pitch, Width, Height, Src.Palette);
          pfPAL8: BltRect(S, D, Src.Pitch, Dest.Pitch, Width, Height);
        else
          Result := GFXE_NOTSUPPORTED;
        end;
      pfRGB555, pfARGB1555:
        case Dest.PixelFormatID of
          pfRGB24: RemapSurface555to24(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB32: RemapSurface555to32(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB565: RemapSurface555to565(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB555: BltRect(S, D, Src.Pitch, Dest.Pitch, Width * 2, Height);
        else
          Result := GFXE_NOTSUPPORTED;
        end;
      pfRGB565:
        case Dest.PixelFormatID of
          pfRGB24: RemapSurface565to24(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB32: RemapSurface565to32(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB555: RemapSurface565to555(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB565: BltRect(S, D, Src.Pitch, Dest.Pitch, Width * 2, Height);
        else
          Result := GFXE_NOTSUPPORTED;
        end;
      pfRGB24:
        case Dest.PixelFormatID of
          pfRGB565: RemapSurface24to565(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB555: RemapSurface24to555(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB24: BltRect(S, D, Src.Pitch, Dest.Pitch, Width * 3, Height);
        else
          Result := GFXE_NOTSUPPORTED;
        end;
      pfRGB32:
        case Dest.PixelFormatID of
          pfRGB565: RemapSurface32to565(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB555: RemapSurface32to555(S, D, Src.Pitch, Dest.Pitch, Width, Height);
          pfRGB32: BltRect(S, D, Src.Pitch, Dest.Pitch, Width * 4, Height);
        else
          Result := GFXE_NOTSUPPORTED;
        end;
    else
      Result := GFXE_NOTSUPPORTED;
    end;
  end;
end;

function RemapSurface(Src, Dest: TSurface): HResult;
var
  SSD, DSD: TSurfaceDesc;
begin
  Src.Lock(SSD);
  Dest.Lock(DSD);
  Result := RemapSurfacePart(SSD, 0, 0, SSD.Width, SSD.Height, DSD, 0, 0);
  Src.Unlock;
  Dest.Unlock;
end;

function Color2PixelInfo(Color: TColor; PixelFormatID: Integer; Palette: TGFXEPalette): Integer;
var
  R, G, B: Byte;
begin
  Color := ColorToRGB(Color);
  R := Color and $FF;
  G := Color shr 8 and $FF;
  B := Color shr 16 and $FF;
  case PixelFormatID of
    pfRGB565: Result := (R and $F8) shl 8 + (G and $FC) shl 3 + (B and $F8) shr 3;
    pfRGB555: Result := (R and $F8) shl 7 + (G and $F8) shl 2 + (B and $F8) shr 3;
    pfARGB1555: Result := (R and $F8) shl 7 + (G and $F8) shl 2 + (B and $F8) shr 3;
    pfRGB24: Result := R shl 16 + G shl 8 + B;
    pfBGR24: Result := Color;
    pfRGB32: Result := R shl 16 + G shl 8 + B;
    pfXRGB32: Result := R shl 16 + G shl 8 + B;
    pfPAL8:
      if Palette <> nil then
        Result := Palette.GetNearestColor(R + G shl 8 + B shl 16)
      else
        raise Exception.Create('Destination Palette Needed!');
  else
    raise Exception.Create('PixelFormat not supported (' + IntToStr(PixelFormatID) + ')');
  end;
end;

function PixelInfo2Color(PixelInfo: Integer; PixelFormatID: Integer; Palette: TGFXEPalette): TColor;
begin
  Result := RemapPixelInfo(PixelInfo, PixelFormatID, Palette, pfBGR24, nil);
end;

function RemapPixelInfo(PixelInfo: Integer; SrcPixelFormatID: Integer; SrcPalette: TGFXEPalette; DestPixelFormatID: Integer; DestPalette: TGFXEPalette): Integer;
var
  R, G, B, A: Byte;
begin
  case SrcPixelFormatID of
    pfPAL8:
      if SrcPalette <> nil then
      begin
        R := SrcPalette.Entries[PixelInfo].R;
        G := SrcPalette.Entries[PixelInfo].G;
        B := SrcPalette.Entries[PixelInfo].B;
        A := 0;
      end
      else
        raise Exception.Create('Source Palette needed (GFXE)');
    pfRGB565:
      begin
        R := PixelInfo shr 8 and $F8;
        G := PixelInfo shr 3 and $FC;
        B := PixelInfo shl 3 and $F8;
        A := 0;
      end;
    pfRGB555:
      begin
        R := PixelInfo shr 7 and $F8;
        G := PixelInfo shr 2 and $F8;
        B := PixelInfo shl 3 and $F8;
        A := 0;
      end;
    pfARGB1555:
      begin
        R := PixelInfo shr 7 and $F8;
        G := PixelInfo shr 2 and $F8;
        B := PixelInfo shl 3 and $F8;
        A := PixelInfo shr 8 and 1;
      end;
    pfRGB24:
      begin
        R := PixelInfo shr 16 and $FF;
        G := PixelInfo shr 8 and $FF;
        B := PixelInfo and $FF;
        A := 0;
      end;
    pfBGR24:
      begin
        R := PixelInfo and $FF;
        G := PixelInfo shr 8 and $FF;
        B := PixelInfo shr 16 and $FF;
        A := 0;
      end;
    pfRGB32:
      begin
        A := PixelInfo shr 24 and $FF;
        R := PixelInfo shr 16 and $FF;
        G := PixelInfo shr 8 and $FF;
        B := PixelInfo and $FF;
      end;
  else
    raise Exception.Create('Source PixelFormat not supported');
  end;
  case DestPixelFormatID of
    pfPAL8:
      if DestPalette <> nil then
        Result := DestPalette.GetNearestColor(R + G shl 8 + B shl 16)
      else
        raise Exception.Create('Destination Palette needed');
    pfRGB565: Result := (R and $F8) shl 8 + (G and $FC) shl 3 + (B and $F8) shr 3;
    pfRGB555: Result := (R and $F8) shl 7 + (G and $F8) shl 2 + (B and $F8) shr 3;
    pfARGB1555: Result := (A and $80) shl 8 + (R and $F8) shl 7 + (G and $F8) shl 2 + (B and $F8) shr 3;
    pfRGB24: Result := R shl 16 + G shl 8 + B;
    pfBGR24: Result := R + G shl 8 + B shl 16;
    pfRGB32: Result := A shl 24 + R shl 16 + G shl 8 + B;
  else
    raise Exception.Create('Destination PixelFormat not supported');
  end;
end;

{ TDrawPanel }

constructor TDrawPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := '';
  Color := clBlack;
  BevelOuter := bvNone;
  FEraseBkgndEnabled := True;
end;

procedure TDrawPanel.WndProc(var Message: TMessage);
begin
  if (Message.Msg = WM_ERASEBKGND) and not FEraseBkgndEnabled then
  begin
    Message.Result := 1;
    Invalidate;
  end
  else
    inherited WndProc(Message);
end;

procedure TDrawPanel.Paint;
begin
  if Assigned(FOnDraw) then
    FOnDraw(Self, ClientRect)
  else
    inherited Paint;
end;

{ The BMP file format: TBMPImageFile and its helpers. }

{$I-}
function LoadBMP(const FileName: string; var SD: TSurfaceDesc; X, Y: Integer): HResult;
var
  SX, SY, DX, DY: Integer;
  W, H: Integer;
  Size: Integer;
  I, J: Integer;
  Data: Pointer;
  Pitch: Integer;
  D: Pointer;
  S: PByteArray;
  P: Pointer;
  X2, Y2: Integer;
  FH: TBitmapFileHeader;
  IH: TBitmapInfoHeader;
  Pal: array[0..255] of TRGBQuad;
  F: file;
begin
  try
    Result := GFXE_OK;
    Data := nil;
    AssignFile(F, FileName);
    Reset(F, 1);
    BlockRead(F, FH, SizeOf(FH));
    BlockRead(F, IH, SizeOf(IH));
    if IH.biBitCount = 8 then BlockRead(F, Pal, SizeOf(Pal));
    Seek(F, FH.bfOffBits);
    Size := FH.bfSize - FH.bfOffBits;
    Pitch := (((IH.biBitCount * IH.biWidth + 7) shr 3) + 3) and not 3;
    W := IH.biWidth;
    X2 := W + X;
    if X < SD.ClipRect.Left then
    begin
      SX := SD.ClipRect.Left - X;
      DX := SD.ClipRect.Left;
      W := W - SX;
    end
    else
    begin
      SX := 0;
      DX := X;
    end;
    if X2 > SD.ClipRect.Right then W := W - (X2 - SD.ClipRect.Right);
    H := IH.biHeight;
    Y2 := H + Y;
    if Y < SD.ClipRect.Top then
    begin
      SY := SD.ClipRect.Top - Y;
      DY := SD.ClipRect.Top;
      H := H - SY;
    end
    else
    begin
      SY := 0;
      DY := Y;
    end;
    if Y2 > SD.ClipRect.Bottom then H := H - (Y2 - SD.ClipRect.Bottom);
    if (IH.biCompression = BI_RGB) and (W > 0) and (H > 0) then
    begin
      ReallocMem(Data, Size);
      BlockRead(F, Data^, Size);
      case IH.biBitCount of
        8:
          case SD.PixelFormatID of
            pfPAL8:
              begin
                for I := H - 1 downto 0 do
                begin
                  S := Pointer((IH.biHeight - 1 - (I + SY)) * Pitch + (Integer(Data) + SX));
                  D := Pointer((I + DY) * SD.Pitch + (Integer(SD.Data) + DX));
                  Move(S^, D^, W);
                end;
                if SD.Palette <> nil then
                begin
                  for J := 0 to 255 do
                  begin
                    SD.Palette.Entries[J].R := Pal[J].rgbRed;
                    SD.Palette.Entries[J].G := Pal[J].rgbGreen;
                    SD.Palette.Entries[J].B := Pal[J].rgbBlue;
                  end;
                  SD.Palette.PixelFormatID := pfBGR24;
                end;
              end;
            pfRGB565:
              for I := H - 1 downto 0 do
              begin
                S := Pointer((IH.biHeight - 1 - (I + SY)) * Pitch + (SX * 2 + Integer(Data)));
                P := Pointer(Integer(SD.Data) + DX * 2 + (I + DY) * SD.Pitch);
                for J := 0 to W - 1 do
                begin
                  with Pal[S[0]] do
                    PWord(P)^ := (rgbRed and $F8) shl 8 + (rgbGreen and $FC) shl 3 + rgbBlue shr 3;
                  S := Pointer(Integer(S) + 1);
                  P := Pointer(Integer(P) + 2);
                end;
              end;
            pfRGB555:
              for I := H - 1 downto 0 do
              begin
                S := Pointer((IH.biHeight - 1 - (I + SY)) * Pitch + (SX * 2 + Integer(Data)));
                P := Pointer(Integer(SD.Data) + DX * 2 + (I + DY) * SD.Pitch);
                for J := 0 to W - 1 do
                begin
                  with Pal[S[0]] do
                    PWord(P)^ := (rgbRed and $F8) shl 7 + (rgbGreen and $F8) shl 2 + rgbBlue shr 3;
                  S := Pointer(Integer(S) + 1);
                  P := Pointer(Integer(P) + 2);
                end;
              end;
          end;
        24:
          case SD.PixelFormatID of
            pfRGB565:
              for I := H - 1 downto 0 do
              begin
                S := Pointer((IH.biHeight - 1 - (I + SY)) * Pitch + (SX * 3 + Integer(Data)));
                P := Pointer(Integer(SD.Data) + DX * 2 + (I + DY) * SD.Pitch);
                for J := 0 to W - 1 do
                begin
                  PWord(P)^ := (S[2] and $F8) shl 8 + (S[1] and $FC) shl 3 + S[0] shr 3;
                  S := Pointer(Integer(S) + 3);
                  P := Pointer(Integer(P) + 2);
                end;
              end;
            pfRGB555:
              for I := H - 1 downto 0 do
              begin
                S := Pointer((IH.biHeight - 1 - (I + SY)) * Pitch + (SX * 3 + Integer(Data)));
                P := Pointer(Integer(SD.Data) + DX * 2 + (I + DY) * SD.Pitch);
                for J := 0 to W - 1 do
                begin
                  PWord(P)^ := (S[2] and $F8) shl 7 + (S[1] and $F8) shl 2 + S[0] shr 3;
                  S := Pointer(Integer(S) + 3);
                  P := Pointer(Integer(P) + 2);
                end;
              end;
            pfRGB24:
              for I := H - 1 downto 0 do
              begin
                S := Pointer((IH.biHeight - 1 - (I + SY)) * Pitch + (SX * 3 + Integer(Data)));
                D := Pointer(Integer(SD.Data) + DX * 3 + (I + DY) * SD.Pitch);
                Move(S^, D^, W * 3);
              end;
            pfRGB32:
              for I := H - 1 downto 0 do
              begin
                S := Pointer((IH.biHeight - 1 - (I + SY)) * Pitch + (SX * 3 + Integer(Data)));
                P := Pointer(Integer(SD.Data) + DX * 4 + (I + DY) * SD.Pitch);
                for J := 0 to W - 1 do
                begin
                  PInteger(P)^ := (S[2] and $F8) shl 16 + (S[1] and $F8) shl 8 + S[0];
                  S := Pointer(Integer(S) + 3);
                  P := Pointer(Integer(P) + 4);
                end;
              end;
          else
            Result := GFXE_PIXELFORMATNOTSUPPORTED;
          end;
      else
        Result := GFXE_BITMAPFORMATNOTSUPPORTED;
      end;
    end
    else
      Result := GFXE_BITMAPFORMATNOTSUPPORTED;
  finally
    ReallocMem(Data, 0);
    CloseFile(F);
  end;
end;
{$I+}

{$I-}
function SaveSurfaceDescToBMP24(const SD: TSurfaceDesc; R: TRect; const FileName: string): HResult;
var
  DIB: TDIB24Surface;
  FH: TBitmapFileHeader;
  IH: TBitmapInfoHeader;
  DSD: TSurfaceDesc;
  F: file;
  Y, Bytes: Integer;
begin
  DIB := TDIB24Surface.Create(R.Right - R.Left, R.Bottom - R.Top);
  DIB.Lock(DSD);
  Result := RemapSurfacePart(SD, R.Left, R.Top, DIB.Width, DIB.Height, DSD, 0, 0);
  if Succeeded(Result) then
  begin
    FillChar(FH, SizeOf(FH), 0);
    FH.bfType := $4D42;
    FH.bfSize := SizeOf(FH) + SizeOf(IH) + Abs(DSD.Pitch) * DSD.Height;
    FH.bfOffBits := SizeOf(FH) + SizeOf(IH);
    FillChar(IH, SizeOf(IH), 0);
    IH.biSize := SizeOf(IH);
    IH.biWidth := DSD.Width;
    IH.biHeight := DSD.Height;
    IH.biPlanes := 1;
    IH.biBitCount := 24;
    IH.biCompression := BI_RGB;
    IH.biSizeImage := 0;
    IH.biXPelsPerMeter := 0;
    IH.biYPelsPerMeter := 0;
    IH.biClrUsed := 0;
    IH.biClrImportant := 0;
    AssignFile(F, FileName);
    Rewrite(F, 1);
    BlockWrite(F, FH, SizeOf(FH));
    BlockWrite(F, IH, SizeOf(IH));
    Bytes := (((IH.biBitCount * IH.biWidth + 7) shr 3) + 3) and not 3;
    for Y := IH.biHeight - 1 downto 0 do
      BlockWrite(F, Pointer(Integer(DSD.Data) + DSD.Pitch * Y)^, Bytes);
    CloseFile(F);
  end;
  DIB.Unlock;
  DIB.Free;
end;
{$I+}

{$I-}
function CreateSurfaceFromBMP(const FileName: string): TSurface;
var
  S: TSurface;
  FH: TBitmapFileHeader;
  IH: TBitmapInfoHeader;
  Pal: array[0..255] of TRGBQuad;
  SD: TSurfaceDesc;
  F: file;
begin
  S := nil;
  try
    AssignFile(F, FileName);
    Reset(F, 1);
    BlockRead(F, FH, SizeOf(FH));
    BlockRead(F, IH, SizeOf(IH));
    if IH.biBitCount = 8 then BlockRead(F, Pal, SizeOf(Pal));
  finally
    CloseFile(F);
  end;
  case IH.biBitCount of
    8: S := TDIB08Surface.Create(IH.biWidth, IH.biHeight, nil);
    24: S := TDIB24Surface.Create(IH.biWidth, IH.biHeight);
    32: S := TDIB32Surface.Create(IH.biWidth, IH.biHeight);
  end;
  if S <> nil then
  begin
    S.Lock(SD);
    if Failed(LoadBMP(FileName, SD, 0, 0)) then
    begin
      S.Unlock;
      S.Free;
      S := nil;
    end
    else
      S.Unlock;
  end;
  Result := S;
end;
{$I+}

{$I-}
function GetBMPPixelFormat(const FileName: string): Integer;
var
  FH: TBitmapFileHeader;
  IH: TBitmapInfoHeader;
  F: file;
begin
  Result := 0;
  try
    AssignFile(F, FileName);
    Reset(F, 1);
    BlockRead(F, FH, SizeOf(FH));
    BlockRead(F, IH, SizeOf(IH));
    case IH.biBitCount of
      8: Result := pfPAL8;
      24: Result := pfRGB24;
      32: Result := pfRGB32;
    end;
  finally
    CloseFile(F);
  end;
end;
{$I+}

type
  { GFXE.TBMPImageFile (instance size 4): the Windows bitmap file format. }
  TBMPImageFile = class(TImageFile)
  public
    class function GetExtension: string; override;
    class function GetDescription: string; override;
    class function GetPixelFormatID(const FileName: string): Integer; override;
    class function CreateSurface(const FileName: string): TSurface; override;
    class function LoadToSurfaceDesc(const FileName: string; var SD: TSurfaceDesc; X, Y: Integer): HResult; override;
  end;

class function TBMPImageFile.GetExtension: string;
begin
  Result := 'BMP';
end;

class function TBMPImageFile.GetDescription: string;
begin
  Result := 'Bitmap files (*.bmp)';
end;

class function TBMPImageFile.GetPixelFormatID(const FileName: string): Integer;
begin
  Result := GetBMPPixelFormat(FileName);
end;

class function TBMPImageFile.CreateSurface(const FileName: string): TSurface;
begin
  Result := CreateSurfaceFromBMP(FileName);
end;

class function TBMPImageFile.LoadToSurfaceDesc(const FileName: string; var SD: TSurfaceDesc; X, Y: Integer): HResult;
begin
  Result := LoadBMP(FileName, SD, X, Y);
end;

{ The original unit was longer: the line numbers compiled into the Assert calls (9342 for the next Assert below) prove that 37 more lines preceded this point. Their content is unknown; the blank lines below keep the Assert line numbers identical. }





































{ TDDrawSurface (inc\DDSurf.PAS in the original) }

function TDDrawSurface.CreateSurface(AWidth, AHeight, APixelFormatID: Integer; AFlags: TDDSCreationFlags): HResult;
var
  DDSD: TDDSurfaceDesc;
  S: IDirectDrawSurface;
begin
  Result := DD_OK;
  if FSurface <> nil then FSurface := nil;
  FWidth := AWidth;
  FHeight := AHeight;
  FPixelFormatID := APixelFormatID;
  if not (cfVideoMemory in AFlags) then AFlags := AFlags + [cfSystemMemory];
  FCreationFlags := AFlags;
  FillChar(DDSD, SizeOf(DDSD), 0);
  DDSD.dwSize := SizeOf(DDSD);
  DDSD.dwWidth := AWidth;
  DDSD.dwHeight := AHeight;
  DDSD.dwFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT;
  DDSD.ddpfPixelFormat.dwSize := SizeOf(TDDPixelFormat);
  DDSD.ddpfPixelFormat.dwFlags := DDPF_RGB;
  DDSD.ddpfPixelFormat.dwRGBBitCount := PFIDtoMASK(APixelFormatID,
    Integer(DDSD.ddpfPixelFormat.dwRBitMask), Integer(DDSD.ddpfPixelFormat.dwGBitMask),
    Integer(DDSD.ddpfPixelFormat.dwBBitMask), Integer(DDSD.ddpfPixelFormat.dwRGBAlphaBitMask));
  if cfVideoMemory in AFlags then
  begin
    DDSD.ddsCaps.dwCaps := DDSCAPS_VIDEOMEMORY or DDSCAPS_OFFSCREENPLAIN;
    Result := DD.CreateSurface(DDSD, S, nil);
    if Succeeded(Result) then FStatus := FStatus + [ssVideoMemory];
  end;
  if (S = nil) and (cfSystemMemory in AFlags) then
  begin
    DDSD.ddsCaps.dwCaps := DDSCAPS_SYSTEMMEMORY or DDSCAPS_OFFSCREENPLAIN;
    Result := DD.CreateSurface(DDSD, S, nil);
  end;
  if Succeeded(Result) then
    Result := S.QueryInterface(IID_IDirectDrawSurface2, FSurface);
  S := nil;
  if Succeeded(Result) then FStatus := FStatus + [ssCreated];
end;

destructor TDDrawSurface.Destroy;
begin
  if FSurface <> nil then
  begin
    while FSurface.GetFlipStatus(DDGFS_ISFLIPDONE) = DDERR_WASSTILLDRAWING do;
    while FSurface.GetBltStatus(DDGBS_CANBLT) = DDERR_WASSTILLDRAWING do;
    FSurface := nil;
  end;
  inherited Destroy;
end;

function TDDrawSurface.Lost: Boolean;
begin
  Result := (FSurface <> nil) and (FSurface.IsLost = DDERR_SURFACELOST);
end;

function TDDrawSurface.Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
var
  R: TRect;
begin
  if ssLocked in FStatus then raise Exception.Create('SURFACE IS LOCKED');
  if Dest is TDDrawSurface then
  begin
    if ssLocked in TDDrawSurface(Dest).FStatus then raise Exception.Create('DESTSURFACE IS LOCKED');
    if SrcRect = nil then
    begin
      R.Left := 0;
      R.Right := FWidth;
      R.Top := 0;
      R.Bottom := FHeight;
      SrcRect := @R;
    end;
    if (ssVideoMemory in FStatus) and (ssVideoMemory in TDDrawSurface(Dest).FStatus) then
      Result := TDDrawSurface(Dest).FSurface.BltFast(X, Y, FSurface, SrcRect, DDBLTFAST_WAIT)
    else
      Result := inherited Blt(Dest, SrcRect, X, Y);
  end
  else
    Result := inherited Blt(Dest, SrcRect, X, Y);
  if Result = DDERR_SURFACELOST then
  begin
    if FSurface.IsLost = DDERR_SURFACELOST then
    begin
      if Assigned(FOnSurfaceLost) then
      begin
        FOnSurfaceLost(Self);
        if FSurface.IsLost <> DDERR_SURFACELOST then Result := Blt(Dest, SrcRect, X, Y);
      end;
    end
    else if Dest is TDDrawSurface then
      if (TDDrawSurface(Dest).FSurface.IsLost = DDERR_SURFACELOST) and Assigned(TDDrawSurface(Dest).FOnSurfaceLost) then
      begin
        TDDrawSurface(Dest).FOnSurfaceLost(Self);
        if TDDrawSurface(Dest).FSurface.IsLost <> DDERR_SURFACELOST then Result := Blt(Dest, SrcRect, X, Y);
      end;
  end;
end;

function TDDrawSurface.BltColorKey(Dest: TSurface; SrcRect: PRect; X, Y: Integer; ColorKey: TColor): HResult;
var
  Key: TDDColorKey;
  R: TRect;
  DR: TRect;
begin
  if Dest is TDDrawSurface then
  begin
    if SrcRect = nil then
    begin
      R.Left := 0;
      R.Right := FWidth;
      R.Top := 0;
      R.Bottom := FHeight;
      SrcRect := @R;
    end;
    Key.dwColorSpaceLowValue := ColorKey;
    Key.dwColorSpaceHighValue := ColorKey;
    Result := FSurface.SetColorKey(DDCKEY_SRCBLT, @Key);
    if Succeeded(Result) then
      if (ssVideoMemory in FStatus) and (ssVideoMemory in TDDrawSurface(Dest).FStatus) then
        Result := TDDrawSurface(Dest).FSurface.BltFast(X, Y, FSurface, SrcRect, DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT)
      else
      begin
        DR.Left := X;
        DR.Top := Y;
        DR.Right := SrcRect.Right - SrcRect.Left + X;
        DR.Bottom := SrcRect.Bottom - SrcRect.Top + Y;
        Result := TDDrawSurface(Dest).FSurface.Blt(@DR, FSurface, SrcRect, DDBLT_WAIT or DDBLT_KEYSRC, nil);
      end;
    if Failed(Result) then Result := inherited BltColorKey(Dest, SrcRect, X, Y, ColorKey);
  end
  else
    Result := inherited BltColorKey(Dest, SrcRect, X, Y, ColorKey);
  if Result = DDERR_SURFACELOST then
  begin
    if FSurface.IsLost = DDERR_SURFACELOST then
    begin
      if Assigned(FOnSurfaceLost) then
      begin
        FOnSurfaceLost(Self);
        if FSurface.IsLost <> DDERR_SURFACELOST then Result := BltColorKey(Dest, SrcRect, X, Y, ColorKey);
      end;
    end
    else if Dest is TDDrawSurface then
      if (TDDrawSurface(Dest).FSurface.IsLost = DDERR_SURFACELOST) and Assigned(TDDrawSurface(Dest).FOnSurfaceLost) then
      begin
        TDDrawSurface(Dest).FOnSurfaceLost(Self);
        if TDDrawSurface(Dest).FSurface.IsLost <> DDERR_SURFACELOST then Result := BltColorKey(Dest, SrcRect, X, Y, ColorKey);
      end;
  end;
end;

function DDSDtoSurfaceDesc(const DDSD: TDDSurfaceDesc; var SD: TSurfaceDesc): HResult;
begin
  Result := DD_OK;
  FillChar(SD, SizeOf(SD), 0);
  SD.Width := DDSD.dwWidth;
  SD.Height := DDSD.dwHeight;
  SD.Pitch := DDSD.lPitch;
  SD.BitCount := DDSD.ddpfPixelFormat.dwRGBBitCount;
  SD.ClipRect.Left := 0;
  SD.ClipRect.Right := DDSD.dwWidth;
  SD.ClipRect.Top := 0;
  SD.ClipRect.Bottom := DDSD.dwHeight;
  SD.Data := DDSD.lpSurface;
  SD.PixelFormatID := MASKtoPFID(DDSD.ddpfPixelFormat.dwRGBBitCount, DDSD.ddpfPixelFormat.dwRBitMask,
    DDSD.ddpfPixelFormat.dwGBitMask, DDSD.ddpfPixelFormat.dwBBitMask, DDSD.ddpfPixelFormat.dwRGBAlphaBitMask);
  SD.RMask := DDSD.ddpfPixelFormat.dwRBitMask;
  SD.GMask := DDSD.ddpfPixelFormat.dwGBitMask;
  SD.BMask := DDSD.ddpfPixelFormat.dwBBitMask;
  SD.AMask := DDSD.ddpfPixelFormat.dwRGBAlphaBitMask;
end;

function TDDrawSurface.GetPixelFormatID: Integer;
begin
  Result := FPixelFormatID;
end;

function TDDrawSurface.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TDDrawSurface.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TDDrawSurface.Lock(var SD: TSurfaceDesc): HResult;
var
  DDSD: TDDSurfaceDesc;
begin
  if FLockCount = 0 then
  begin
    FillChar(DDSD, SizeOf(DDSD), 0);
    DDSD.dwSize := SizeOf(DDSD);
    repeat
      Result := FSurface.Lock(nil, DDSD, DDLOCK_WAIT, 0);
    until Result <> DDERR_WASSTILLDRAWING;
    if Succeeded(Result) then
    begin
      Inc(FLockCount);
      FStatus := FStatus + [ssLocked];
      FillChar(SD, SizeOf(SD), 0);
      SD.Width := DDSD.dwWidth;
      SD.Height := DDSD.dwHeight;
      SD.Pitch := DDSD.lPitch;
      SD.ClipRect.Left := 0;
      SD.ClipRect.Right := DDSD.dwWidth;
      SD.ClipRect.Top := 0;
      SD.ClipRect.Bottom := DDSD.dwHeight;
      SD.Data := DDSD.lpSurface;
      SD.PixelFormatID := FPixelFormatID;
      SD.BitCount := DDSD.ddpfPixelFormat.dwRGBBitCount;
      SD.RMask := DDSD.ddpfPixelFormat.dwRBitMask;
      SD.GMask := DDSD.ddpfPixelFormat.dwGBitMask;
      SD.BMask := DDSD.ddpfPixelFormat.dwBBitMask;
      SD.AMask := DDSD.ddpfPixelFormat.dwRGBAlphaBitMask;
    end
    else if (Result = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
    begin
      FOnSurfaceLost(Self);
      if FSurface.IsLost <> DDERR_SURFACELOST then Result := Lock(SD);
    end;
    if Succeeded(Result) then Move(SD, FSurfaceDesc, SizeOf(SD));
  end
  else
  begin
    Inc(FLockCount);
    Move(FSurfaceDesc, SD, SizeOf(SD));
    Result := DD_OK;
  end;
end;

function TDDrawSurface.Unlock: HResult;
begin
  Assert(FLockCount <> 0, 'Invalid Unlock');
  if FLockCount = 1 then
  begin
    Result := FSurface.Unlock(nil);
    if Succeeded(Result) then
    begin
      Dec(FLockCount);
      if FLockExCount = 0 then FStatus := FStatus - [ssLocked];
    end;
  end
  else
  begin
    Dec(FLockCount);
    Result := DD_OK;
  end;
end;

function TDDrawSurface.LockEx(var SD: TSurfaceDesc; const R: TRect): HResult;
var
  DDSD: TDDSurfaceDesc;
begin
  FillChar(DDSD, SizeOf(DDSD), 0);
  DDSD.dwSize := SizeOf(DDSD);
  repeat
    Result := FSurface.Lock(@R, DDSD, DDLOCK_WAIT, 0);
  until Result <> DDERR_WASSTILLDRAWING;
  if Succeeded(Result) then
  begin
    Inc(FLockExCount);
    FStatus := [ssLocked] + FStatus;
    FillChar(SD, SizeOf(SD), 0);
    SD.Width := R.Right - R.Left;
    SD.Height := R.Bottom - R.Top;
    SD.Pitch := DDSD.lPitch;
    SD.ClipRect.Left := 0;
    SD.ClipRect.Right := SD.Width;
    SD.ClipRect.Top := 0;
    SD.ClipRect.Bottom := SD.Height;
    SD.Data := DDSD.lpSurface;
    SD.PixelFormatID := FPixelFormatID;
    SD.BitCount := DDSD.ddpfPixelFormat.dwRGBBitCount;
    SD.RMask := DDSD.ddpfPixelFormat.dwRBitMask;
    SD.GMask := DDSD.ddpfPixelFormat.dwGBitMask;
    SD.BMask := DDSD.ddpfPixelFormat.dwBBitMask;
    SD.AMask := DDSD.ddpfPixelFormat.dwRGBAlphaBitMask;
  end
  else if (Result = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
  begin
    FOnSurfaceLost(Self);
    if FSurface.IsLost <> DDERR_SURFACELOST then Result := LockEx(SD, R);
  end;
end;

function TDDrawSurface.UnlockEx(const SD: TSurfaceDesc): HResult;
begin
  Result := FSurface.Unlock(SD.Data);
  if Succeeded(Result) then
  begin
    Dec(FLockExCount);
    if (FLockExCount = 0) and (FLockExCount = 0) then FStatus := FStatus - [ssLocked];   // sic
  end;
end;

function TDDrawSurface.Resize(AWidth, AHeight: Integer): HResult;
begin
  if (AWidth <> FWidth) or (AHeight <> FHeight) or
    ((FSurface <> nil) and (FSurface.IsLost = DDERR_SURFACELOST)) then
    Result := CreateSurface(AWidth, AHeight, FPixelFormatID, FCreationFlags)
  else
    Result := DD_OK;
end;

function TDDrawSurface.Restore: HResult;
begin
  if (FSurface <> nil) and (FSurface.IsLost = DDERR_SURFACELOST) then
    Result := FSurface.Restore
  else
    Result := DD_OK;
end;

function TDDrawSurface.AsyncCls(Color: TColor): HResult;
var
  R: TRect;
  Fx: TDDBltFX;
  Count, Value, I: Integer;
begin
  R.Top := 0;
  R.Bottom := FHeight;
  R.Left := 0;
  R.Right := FWidth;
  Fx.dwSize := SizeOf(Fx);
  Fx.dwFillColor := Color2PixelInfo(Color, FPixelFormatID, nil);
  while FSurface.GetBltStatus(DDGBS_CANBLT) = DDERR_WASSTILLDRAWING do;
  Result := FSurface.Blt(@R, nil, nil, DDBLT_COLORFILL or DDBLT_ASYNC, @Fx);
  if Result = DDERR_UNSUPPORTED then
  begin
    if FLockCount <> 0 then
      with FSurfaceDesc do
      begin
        Count := (Width * BitCount) shr 3;
        case BitCount of
          8: Value := Fx.dwFillColor shl 24 + Fx.dwFillColor shl 16 + Fx.dwFillColor shl 8 + Fx.dwFillColor;
          16: Value := Fx.dwFillColor shl 16 + Fx.dwFillColor;
          32: Value := Fx.dwFillColor;
        else
          Value := 0;
        end;
        for I := 0 to Height - 1 do
          FillInt(Pointer(Integer(Data) + Pitch * I)^, Count, Value);
      end;
    Result := DD_OK;
  end;
  if (Result = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
  begin
    FOnSurfaceLost(Self);
    if FSurface.IsLost <> DDERR_SURFACELOST then Result := Cls(Color);
  end;
end;

function TDDrawSurface.Cls(Color: TColor): HResult;
var
  Pixel: Integer;
  SD: TSurfaceDesc;
  I: Integer;
begin
  Pixel := Color2PixelInfo(Color, TDDrawSurface(Self).FPixelFormatID, nil);
  if FLockCount <> 0 then
  begin
    with FSurfaceDesc do
    begin
      Result := DD_OK;
      case BitCount of
        8: for I := 0 to Height - 1 do
             FillChar(Pointer(Integer(Data) + Pitch * I)^, Width, Pixel);
        16: for I := 0 to Height - 1 do
              FillWord(Pointer(Integer(Data) + Pitch * I)^, Width, Pixel);
        24: for I := 0 to Height - 1 do
              FillTrippleByte(Pointer(Integer(Data) + Pitch * I)^, Width, Pixel);
        32: for I := 0 to Height - 1 do
              FillInt(Pointer(Integer(Data) + Pitch * I)^, Width, Pixel);
      else
        Result := GFXE_NOTSUPPORTED;
      end;
    end;
  end
  else
  begin
    Result := Lock(SD);
    if Succeeded(Result) then
    begin
      case SD.BitCount of
        8: for I := 0 to SD.Height - 1 do
             FillChar(Pointer(Integer(SD.Data) + SD.Pitch * I)^, SD.Width, Pixel);
        16: for I := 0 to SD.Height - 1 do
              FillWord(Pointer(Integer(SD.Data) + SD.Pitch * I)^, SD.Width, Pixel);
        24: for I := 0 to SD.Height - 1 do
              FillTrippleByte(Pointer(Integer(SD.Data) + SD.Pitch * I)^, SD.Width, Pixel);
        32: for I := 0 to SD.Height - 1 do
              FillInt(Pointer(Integer(SD.Data) + SD.Pitch * I)^, SD.Width, Pixel);
      else
        Result := GFXE_NOTSUPPORTED;
      end;
      Unlock;
    end;
  end;
  if (Result = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
  begin
    FOnSurfaceLost(Self);
    if FSurface.IsLost <> DDERR_SURFACELOST then Result := Cls(Color);
  end;
end;

{ The 5 bit blend tables: Table[I, J] is the blend of source intensity I over destination
  intensity J (0..31). }

procedure GenerateAlphaBlendTable(Table: TBlendTable; Alpha: Single);
var
  I, J: Integer;
begin
  if Table is TBlendTable5Bit then
    for I := 0 to 31 do
      for J := 0 to 31 do
        TBlendTable5Bit(Table).Table[I, J] := Round(I * Alpha + (1 - Alpha) * J)
  else
    raise Exception.Create('BlendTable format not supported');
end;

procedure GenerateLinearAlphaBlendTable(Table: TBlendTable; Alpha: Single);
var
  I, J: Integer;
  F: Single;
begin
  if Table is TBlendTable5Bit then
    for I := 0 to 31 do
    begin
      if Alpha > 0 then
        F := I / (31 * Alpha)
      else
        F := 1;
      if F > 1 then F := 1;
      for J := 0 to 31 do
        TBlendTable5Bit(Table).Table[I, J] := Round(I * F + (1 - F) * J);
    end
  else
    raise Exception.Create('BlendTable format not supported');
end;

procedure GenerateIntensityBlendTable(Table: TBlendTable; Intensity: Single);
var
  I, J, V: Integer;
  F: Single;
begin
  if Table is TBlendTable5Bit then
    for I := 0 to 31 do
      for J := 0 to 31 do
      begin
        if I = 0 then
          F := 0
        else
          F := I * Intensity * 1.75 / (I + J);
        V := Round(I * F) + J;
        if V > 31 then V := 31;
        TBlendTable5Bit(Table).Table[I, J] := V;
      end;
end;

procedure GenerateShadowBlendTable(Table: TBlendTable; Shadow: Single);
var
  I, J, V: Integer;
  F: Single;
begin
  if Table is TBlendTable5Bit then
    for I := 0 to 31 do
      for J := 0 to 31 do
      begin
        F := (31 - I) * (1 / 31) * Shadow;
        V := Round((1 - F) * J);
        if V < 0 then V := 0;
        if V > J then V := J;
        TBlendTable5Bit(Table).Table[I, J] := V;
      end;
end;

procedure GenerateBrightenBlendTable(Table: TBlendTable; Brighten: Single);
var
  I, J, V: Integer;
begin
  if Table is TBlendTable5Bit then
    for I := 0 to 31 do
      for J := 0 to 31 do
      begin
        V := Round(I * Brighten + (1 - Brighten) * J);
        if V < J then V := J;
        TBlendTable5Bit(Table).Table[I, J] := V;
      end;
end;

{ TBlendTable }

procedure TBlendTable.Initialize(ABits: Integer; ATable: Pointer);
begin
  FTable := ATable;
  FBits := ABits;
end;

{ TBlendTable5Bit }

constructor TBlendTable5Bit.Create;
begin
  inherited Create;
  Initialize(5, @Table);
end;

procedure TBlendTable5Bit.Assign(Source: TBlendTable);
begin
  if Source is TBlendTable5Bit then
    Move(TBlendTable5Bit(Source).Table, Table, SizeOf(Table));
end;

function TBlendTable5Bit.Copy: TBlendTable;
begin
  Result := TBlendTable5Bit.Create;
  Result.Assign(Self);
end;

{ TBlendTableList }

constructor TBlendTableList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TBlendTableList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

function TBlendTableList.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TBlendTableList.Clear;
begin
  while FList.Count <> 0 do
  begin
    TBlendTable(FList.List^[FList.Count - 1]).Free;
    FList.Delete(FList.Count - 1);
  end;
end;

function TBlendTableList.GetTables(Index: Integer): TBlendTable;
begin
  Result := TBlendTable(FList.List^[Index]);
end;

procedure TBlendTableList.Add(Table: TBlendTable);
begin
  FList.Add(Table);
end;

procedure TBlendTableList.Delete(Index: Integer);
begin
  TBlendTable(FList.List^[Index]).Free;
  FList.Delete(Index);
end;

{ TLookupBlendTableCollection100 }

constructor TLookupBlendTableCollection100.Create;
begin
  inherited Create;
  FTables := TBlendTableList.Create;
end;

destructor TLookupBlendTableCollection100.Destroy;
begin
  Clear;
  FTables.Free;
  inherited Destroy;
end;

function TLookupBlendTableCollection100.GetLookupTables(Index: Integer): TBlendTable;
begin
  Result := Lookup[Index];
end;

procedure TLookupBlendTableCollection100.Clear;
begin
  FTables.Clear;
  FillChar(Lookup, SizeOf(Lookup), 0);
end;

function TLookupBlendTableCollection100.GenerateLookupTables(Bits: Integer; Proc: TGenerateBlendTableProc; Count: Integer): Boolean;
var
  T: TBlendTable;
  V: Single;
  I, J: Integer;
begin
  Clear;
  if (Bits = 5) and (Count > 0) then
  begin
    for I := 0 to Count - 1 do
    begin
      case Bits of
        5: T := TBlendTable5Bit.Create;
      else
        T := nil;
      end;
      if Count <> 1 then
        V := I / (Count - 1)
      else
        V := 0.5;
      Proc(T, V);
      FTables.Add(T);
    end;
    for I := 0 to 100 do
    begin
      J := (I * Count) div 100;
      if J = Count then J := Count - 1;
      Lookup[I] := FTables.Tables[J];
    end;
    Result := True;
  end
  else
    Result := False;
end;

{ The 16 bit blenders: each channel of source and destination pixel (5 bits; the 6 bit green of
  565 loses its low bit) indexes the 32 x 32 table. Two pixels per step when the destination
  is dword aligned. }

procedure BlendSurface555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Table: Pointer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12: Integer;
asm
        push    ebx
        push    esi
        mov     eax, Height
        push    edi
        test    eax, eax
        je      @@exit
        mov     eax, Dst
        mov     edx, Width
        and     eax, 3
        jne     @@odd
        mov     ebx, edx
        mov     L1, eax
        shr     ebx, 1
        mov     ecx, edx
        and     ecx, 1
        mov     L2, ebx
        mov     L3, ecx
        jmp     @@setup
@@odd:
        mov     eax, 1
        lea     ecx, [edx-1]
        mov     L1, eax
        shr     ecx, 1
        lea     ebx, [edx-1]
        mov     L2, ecx
        and     ebx, 1
        mov     L3, ebx
@@setup:
        mov     eax, Width
        mov     edx, SrcPitch
        shl     eax, 1
        mov     ecx, DstPitch
        sub     edx, eax
        sub     ecx, eax
        mov     L4, edx
        mov     L5, ecx
        mov     esi, Src
        mov     edi, Dst
        mov     L6, esp
@@row:
        mov     ecx, L1
        xor     eax, eax
        test    ecx, ecx
        je      @@pairs
        xor     edx, edx
        mov     ax, [esi]
        mov     dx, [edi]
        mov     esp, eax
        mov     L7, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        mov     edx, L7
        and     eax, $3E0
        shr     edx, 5
        add     eax, Table
        shr     esp, 5
        and     edx, $1F
        add     eax, edx
        and     esp, $3E0
        mov     edx, L7
        add     esp, Table
        shr     edx, 10
        mov     cl, [eax]
        shl     ecx, 5
        and     edx, $1F
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 10
        add     edi, 2
        add     ecx, ebx
        add     esi, 2
        mov     [edi-2], cx
@@pairs:
        mov     ecx, L2
        test    ecx, ecx
        je      @@next
        mov     L8, ecx
@@p1:
        mov     L9, esi
        mov     L10, edi
        mov     esi, [esi]
        mov     edi, [edi]
        mov     esp, esi
        mov     L7, edi
        and     esi, $1F
        and     edi, $1F
        shl     esi, 5
        add     edi, Table
        mov     L8, ecx
        xor     ebx, ebx
        mov     eax, esp
        mov     bl, [edi+esi]
        mov     edx, L7
        mov     esi, esp
        shr     edx, 5
        xor     ecx, ecx
        and     eax, $3E0
        and     edx, $1F
        add     eax, Table
        shr     esi, 5
        mov     edi, L7
        shr     edi, 10
        mov     cl, [eax+edx]
        and     esi, $3E0
        mov     eax, esp
        shl     ecx, 2
        add     esi, Table
        and     edi, $1F
        mov     edx, L7
        shr     esp, 16
        lea     ecx, [ebx+ecx*8]
        shr     edx, 16
        mov     bl, [edi+esi]
        mov     eax, esp
        mov     L11, edx
        shl     ebx, 10
        and     eax, $1F
        add     ebx, ecx
        and     edx, $1F
        shl     eax, 5
        mov     L12, ebx
        add     edx, Table
        xor     ebx, ebx
        mov     esi, esp
        mov     edi, L11
        mov     bl, [edx+eax]
        xor     ecx, ecx
        shr     edi, 5
        and     esi, $3E0
        add     esi, Table
        mov     eax, esp
        and     edi, $1F
        shr     eax, 5
        mov     edx, L11
        and     eax, $3E0
        mov     cl, [esi+edi]
        shr     edx, 10
        add     eax, Table
        shl     ecx, 5
        and     edx, $1F
        mov     edi, L10
        mov     esi, L9
        add     ecx, ebx
        mov     bl, [edx+eax]
        shl     ebx, 10
        add     edi, 4
        add     ebx, ecx
        mov     eax, L12
        shl     ebx, 16
        add     esi, 4
        add     eax, ebx
        mov     ecx, L8
        mov     [edi-4], eax
        dec     ecx
        jne     @@p1
        mov     ecx, L3
        xor     eax, eax
        test    ecx, ecx
        je      @@next
        xor     edx, edx
        mov     ax, [esi]
        mov     dx, [edi]
        mov     esp, eax
        mov     L7, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        mov     edx, L7
        and     eax, $3E0
        shr     edx, 5
        add     eax, Table
        shr     esp, 5
        and     edx, $1F
        add     eax, edx
        and     esp, $3E0
        mov     edx, L7
        add     esp, Table
        shr     edx, 10
        mov     cl, [eax]
        shl     ecx, 5
        and     edx, $1F
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 10
        add     edi, 2
        add     ecx, ebx
        add     esi, 2
        mov     [edi-2], cx
@@next:
        add     esi, L4
        add     edi, L5
        dec     Height
        jne     @@row
        mov     esp, L6
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

procedure BlendSurface565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; Table: Pointer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12: Integer;
asm
        push    ebx
        push    esi
        mov     eax, Height
        push    edi
        test    eax, eax
        je      @@exit
        mov     eax, Dst
        mov     edx, Width
        and     eax, 3
        jne     @@odd
        mov     ebx, edx
        mov     L1, eax
        shr     ebx, 1
        mov     ecx, edx
        and     ecx, 1
        mov     L2, ebx
        mov     L3, ecx
        jmp     @@setup
@@odd:
        mov     eax, 1
        lea     ecx, [edx-1]
        mov     L1, eax
        shr     ecx, 1
        lea     ebx, [edx-1]
        mov     L2, ecx
        and     ebx, 1
        mov     L3, ebx
@@setup:
        mov     eax, Width
        mov     edx, SrcPitch
        shl     eax, 1
        mov     ecx, DstPitch
        sub     edx, eax
        sub     ecx, eax
        mov     L4, edx
        mov     L5, ecx
        mov     esi, Src
        mov     edi, Dst
        mov     L6, esp
@@row:
        mov     ecx, L1
        xor     eax, eax
        test    ecx, ecx
        je      @@pairs
        xor     edx, edx
        mov     ax, [esi]
        mov     dx, [edi]
        mov     esp, eax
        mov     L7, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        shr     eax, 1
        mov     edx, L7
        shr     edx, 6
        and     eax, $3E0
        shr     esp, 6
        add     eax, Table
        and     edx, $1F
        and     esp, $3E0
        add     eax, edx
        mov     edx, L7
        shr     edx, 11
        add     esp, Table
        mov     cl, [eax]
        and     edx, $1F
        shl     ecx, 6
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 11
        add     edi, 2
        add     ecx, ebx
        add     esi, 2
        mov     [edi-2], cx
@@pairs:
        mov     ecx, L2
        test    ecx, ecx
        je      @@last
        mov     L8, ecx
@@p1:
        mov     L9, esi
        mov     L10, edi
        mov     esi, [esi]
        mov     edi, [edi]
        mov     esp, esi
        mov     L7, edi
        and     esi, $1F
        and     edi, $1F
        shl     esi, 5
        add     edi, Table
        mov     L8, ecx
        xor     ebx, ebx
        mov     eax, esp
        mov     bl, [edi+esi]
        shr     eax, 1
        mov     esi, esp
        mov     edx, L7
        xor     ecx, ecx
        shr     edx, 6
        and     eax, $3E0
        and     edx, $1F
        add     eax, Table
        shr     esi, 6
        mov     edi, L7
        shr     edi, 11
        mov     cl, [eax+edx]
        and     esi, $3E0
        and     edi, $1F
        shl     ecx, 3
        add     esi, Table
        shr     esp, 16
        mov     edx, L7
        lea     ecx, [ebx+ecx*8]
        mov     bl, [edi+esi]
        shr     edx, 16
        mov     eax, esp
        shl     ebx, 11
        mov     L11, edx
        add     ebx, ecx
        and     eax, $1F
        mov     L12, ebx
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        mov     esi, esp
        mov     bl, [edx+eax]
        mov     edi, L11
        shr     esi, 1
        xor     ecx, ecx
        shr     edi, 6
        and     esi, $3E0
        mov     eax, esp
        add     esi, Table
        shr     eax, 6
        and     edi, $1F
        mov     edx, L11
        and     eax, $3E0
        shr     edx, 11
        add     eax, Table
        mov     cl, [esi+edi]
        mov     edi, L10
        shl     ecx, 6
        mov     esi, L9
        add     ecx, ebx
        add     edi, 4
        mov     bl, [eax+edx]
        mov     eax, L12
        shl     ebx, 11
        add     esi, 4
        add     ebx, ecx
        mov     ecx, L8
        shl     ebx, 16
        add     eax, ebx
        mov     [edi-4], eax
        dec     ecx
        jne     @@p1
@@last:
        mov     ecx, L3
        xor     eax, eax
        test    ecx, ecx
        je      @@next
        xor     edx, edx
        mov     ax, [esi]
        mov     dx, [edi]
        mov     esp, eax
        mov     L7, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        shr     eax, 1
        mov     edx, L7
        shr     edx, 6
        and     eax, $3E0
        shr     esp, 6
        add     eax, Table
        and     edx, $1F
        and     esp, $3E0
        add     eax, edx
        mov     edx, L7
        shr     edx, 11
        add     esp, Table
        mov     cl, [eax]
        and     edx, $1F
        shl     ecx, 6
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 11
        add     edi, 2
        add     ecx, ebx
        add     esi, 2
        mov     [edi-2], cx
@@next:
        add     esi, L4
        add     edi, L5
        dec     Height
        jne     @@row
        mov     esp, L6
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

procedure BlendColorKey555(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; ColorKey: Integer; Table: Pointer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12, L13, L14, L15: Integer;
asm
        push    ebx
        push    esi
        mov     eax, Height
        push    edi
        test    eax, eax
        je      @@exit
        mov     eax, Dst
        mov     edx, Width
        and     eax, 3
        jne     @@odd
        mov     ebx, edx
        mov     L1, eax
        shr     ebx, 1
        mov     ecx, edx
        and     ecx, 1
        mov     L2, ebx
        mov     L3, ecx
        jmp     @@setup
@@odd:
        mov     eax, 1
        lea     ecx, [edx-1]
        mov     L1, eax
        shr     ecx, 1
        lea     ebx, [edx-1]
        mov     L2, ecx
        and     ebx, 1
        mov     L3, ebx
@@setup:
        mov     eax, Width
        mov     edx, SrcPitch
        shl     eax, 1
        mov     ecx, DstPitch
        sub     edx, eax
        sub     ecx, eax
        mov     L4, edx
        mov     L5, ecx
        mov     eax, ColorKey
        mov     ebx, eax
        mov     esi, Src
        mov     edi, Dst
        shl     ebx, 16
        mov     L6, eax
        mov     L7, esp
        or      eax, ebx
        mov     L8, ebx
        mov     L9, eax
@@row:
        mov     ecx, L1
        xor     eax, eax
        test    ecx, ecx
        je      @@pairs
        mov     ax, [esi]
        xor     edx, edx
        cmp     eax, L6
        jne     @@s1
        add     esi, 2
        add     edi, 2
        jmp     @@pairs
@@s1:
        mov     dx, [edi]
        mov     esp, eax
        mov     L10, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        mov     edx, L10
        and     eax, $3E0
        shr     edx, 5
        add     eax, Table
        shr     esp, 5
        and     edx, $1F
        add     eax, edx
        and     esp, $3E0
        mov     edx, L10
        add     esp, Table
        shr     edx, 10
        mov     cl, [eax]
        shl     ecx, 5
        and     edx, $1F
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 10
        add     edi, 2
        add     ecx, ebx
        add     esi, 2
        mov     [edi-2], cx
@@pairs:
        mov     edx, L2
        test    edx, edx
        je      @@last
        mov     L11, edx
        mov     eax, [esi]
        jmp     @@check
@@skip:
        add     esi, 4
        add     edi, 4
        dec     edx
        je      @@last
        mov     L11, edx
        mov     eax, [esi]
@@check:
        cmp     eax, L9
        je      @@skip
        mov     ebx, eax
        mov     ecx, eax
        and     ebx, $FFFF0000
        and     ecx, $FFFF
        cmp     ebx, L8
        je      @@hikey
        cmp     ecx, L6
        je      @@lokey
        mov     L12, esi
        mov     esi, eax
@@both: mov     L13, edi
        mov     edi, [edi]
        { Every full pair reloads its destination pixels. }
        mov     esp, esi
        mov     L10, edi
        and     esi, $1F
        and     edi, $1F
        shl     esi, 5
        add     edi, Table
        xor     ebx, ebx
        mov     eax, esp
        mov     bl, [edi+esi]
        mov     edx, L10
        mov     esi, esp
        shr     edx, 5
        xor     ecx, ecx
        and     eax, $3E0
        and     edx, $1F
        add     eax, Table
        shr     esi, 5
        mov     edi, L10
        shr     edi, 10
        mov     cl, [eax+edx]
        and     esi, $3E0
        mov     eax, esp
        shl     ecx, 2
        add     esi, Table
        and     edi, $1F
        mov     edx, L10
        shr     esp, 16
        lea     ecx, [ebx+ecx*8]
        shr     edx, 16
        mov     bl, [edi+esi]
        mov     eax, esp
        mov     L14, edx
        shl     ebx, 10
        and     eax, $1F
        add     ebx, ecx
        and     edx, $1F
        shl     eax, 5
        mov     L15, ebx
        add     edx, Table
        xor     ebx, ebx
        mov     esi, esp
        mov     edi, L14
        mov     bl, [edx+eax]
        xor     ecx, ecx
        shr     edi, 5
        and     esi, $3E0
        add     esi, Table
        mov     eax, esp
        and     edi, $1F
        shr     eax, 5
        mov     edx, L14
        and     eax, $3E0
        mov     cl, [esi+edi]
        shr     edx, 10
        add     eax, Table
        shl     ecx, 5
        and     edx, $1F
        mov     edi, L13
        mov     esi, L12
        add     ecx, ebx
        mov     bl, [edx+eax]
        shl     ebx, 10
        add     edi, 4
        add     ebx, ecx
        mov     eax, L15
        shl     ebx, 16
        add     esi, 4
        add     eax, ebx
        mov     edx, L11
        mov     [edi-4], eax
        dec     edx
        je      @@last
        mov     eax, [esi]
        mov     L11, edx
        mov     ebx, eax
        mov     ecx, eax
        and     ebx, $FFFF0000
        and     ecx, $FFFF
        cmp     ebx, L8
        je      @@b2
        cmp     ecx, L6
        je      @@b1
        mov     L12, esi
        mov     esi, eax
        jmp     @@both
@@b1:
        cmp     eax, L9
        je      @@skip
        jmp     @@lokey
@@b2:
        cmp     eax, L9
        je      @@skip
@@hikey:
        xor     edx, edx
        mov     esp, eax
        mov     dx, [edi]
        and     eax, $1F
        shl     eax, 5
        mov     L10, edx
        and     edx, $1F
        xor     ebx, ebx
        add     edx, Table
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        mov     edx, L10
        and     eax, $3E0
        shr     edx, 5
        add     eax, Table
        shr     esp, 5
        and     edx, $1F
        add     eax, edx
        and     esp, $3E0
        mov     edx, L10
        add     esp, Table
        shr     edx, 10
        mov     cl, [eax]
        shl     ecx, 5
        and     edx, $1F
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 10
        add     edi, 4
        add     ecx, ebx
        add     esi, 4
        mov     edx, L11
        mov     [edi-4], cx
        dec     edx
        je      @@last
        mov     eax, [esi]
        mov     L11, edx
        jmp     @@check
@@lokey:
        shr     eax, 16
        xor     edx, edx
        mov     dx, [edi+2]
        mov     esp, eax
        mov     L10, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        mov     edx, L10
        and     eax, $3E0
        shr     edx, 5
        add     eax, Table
        shr     esp, 5
        and     edx, $1F
        add     eax, edx
        and     esp, $3E0
        mov     edx, L10
        add     esp, Table
        shr     edx, 10
        mov     cl, [eax]
        shl     ecx, 5
        and     edx, $1F
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 10
        add     edi, 4
        add     ecx, ebx
        add     esi, 4
        mov     edx, L11
        mov     [edi-2], cx
        dec     edx
        je      @@last
        mov     eax, [esi]
        mov     L11, edx
        jmp     @@check
@@last:
        mov     ecx, L3
        xor     eax, eax
        test    ecx, ecx
        je      @@next
        xor     edx, edx
        mov     ax, [esi]
        cmp     eax, L6
        jne     @@s2
        add     esi, 2
        add     edi, 2
        jmp     @@next
@@s2:
        mov     dx, [edi]
        mov     esp, eax
        mov     L10, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        mov     edx, L10
        and     eax, $3E0
        shr     edx, 5
        add     eax, Table
        shr     esp, 5
        and     edx, $1F
        add     eax, edx
        and     esp, $3E0
        mov     edx, L10
        add     esp, Table
        shr     edx, 10
        mov     cl, [eax]
        shl     ecx, 5
        and     edx, $1F
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 10
        add     edi, 2
        add     ecx, ebx
        add     esi, 2
        mov     [edi-2], cx
@@next:
        add     esi, L4
        add     edi, L5
        dec     Height
        jne     @@row
        mov     esp, L7
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

procedure BlendColorKey565(Src, Dst: Pointer; SrcPitch, DstPitch, Width, Height: Integer; ColorKey: Integer; Table: Pointer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12, L13, L14, L15: Integer;
asm
        push    ebx
        push    esi
        mov     eax, Height
        push    edi
        test    eax, eax
        je      @@exit
        mov     eax, Dst
        mov     edx, Width
        and     eax, 3
        jne     @@odd
        mov     ebx, edx
        mov     L1, eax
        shr     ebx, 1
        mov     ecx, edx
        and     ecx, 1
        mov     L2, ebx
        mov     L3, ecx
        jmp     @@setup
@@odd:
        mov     eax, 1
        lea     ecx, [edx-1]
        mov     L1, eax
        shr     ecx, 1
        lea     ebx, [edx-1]
        mov     L2, ecx
        and     ebx, 1
        mov     L3, ebx
@@setup:
        mov     eax, Width
        mov     edx, SrcPitch
        shl     eax, 1
        mov     ecx, DstPitch
        sub     edx, eax
        sub     ecx, eax
        mov     L4, edx
        mov     L5, ecx
        mov     eax, ColorKey
        mov     ebx, eax
        mov     esi, Src
        mov     edi, Dst
        shl     ebx, 16
        mov     L6, eax
        mov     L7, esp
        or      eax, ebx
        mov     L8, ebx
        mov     L9, eax
@@row:
        mov     ecx, L1
        xor     eax, eax
        test    ecx, ecx
        je      @@pairs
        mov     ax, [esi]
        xor     edx, edx
        cmp     eax, L6
        jne     @@s1
        add     esi, 2
        add     edi, 2
        jmp     @@pairs
@@s1:
        mov     dx, [edi]
        mov     esp, eax
        mov     L10, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        shr     eax, 1
        mov     edx, L10
        shr     edx, 6
        and     eax, $3E0
        shr     esp, 6
        add     eax, Table
        and     edx, $1F
        and     esp, $3E0
        add     eax, edx
        mov     edx, L10
        shr     edx, 11
        add     esp, Table
        mov     cl, [eax]
        and     edx, $1F
        shl     ecx, 6
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 11
        add     edi, 2
        add     ecx, ebx
        add     esi, 2
        mov     [edi-2], cx
@@pairs:
        mov     edx, L2
        test    edx, edx
        je      @@last
        mov     L11, edx
        mov     eax, [esi]
        jmp     @@check
@@skip:
        add     esi, 4
        add     edi, 4
        dec     edx
        je      @@last
        mov     L11, edx
        mov     eax, [esi]
@@check:
        cmp     eax, L9
        je      @@skip
        mov     ebx, eax
        mov     ecx, eax
        and     ebx, $FFFF0000
        and     ecx, $FFFF
        cmp     ebx, L8
        je      @@hikey
        cmp     ecx, L6
        je      @@lokey
        mov     L12, esi
        mov     esi, eax
@@both: mov     L13, edi
        mov     edi, [edi]
        { Every full pair reloads its destination pixels. }
        mov     esp, esi
        mov     L10, edi
        and     esi, $1F
        and     edi, $1F
        shl     esi, 5
        add     edi, Table
        xor     ebx, ebx
        mov     eax, esp
        mov     bl, [edi+esi]
        shr     eax, 1
        mov     esi, esp
        mov     edx, L10
        xor     ecx, ecx
        shr     edx, 6
        and     eax, $3E0
        and     edx, $1F
        add     eax, Table
        shr     esi, 6
        mov     edi, L10
        shr     edi, 11
        mov     cl, [eax+edx]
        and     esi, $3E0
        and     edi, $1F
        shl     ecx, 3
        add     esi, Table
        shr     esp, 16
        mov     edx, L10
        lea     ecx, [ebx+ecx*8]
        mov     bl, [edi+esi]
        shr     edx, 16
        mov     eax, esp
        shl     ebx, 11
        mov     L14, edx
        add     ebx, ecx
        and     eax, $1F
        mov     L15, ebx
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        mov     esi, esp
        mov     bl, [edx+eax]
        mov     edi, L14
        shr     esi, 1
        xor     ecx, ecx
        shr     edi, 6
        and     esi, $3E0
        mov     eax, esp
        add     esi, Table
        shr     eax, 6
        and     edi, $1F
        mov     edx, L14
        and     eax, $3E0
        shr     edx, 11
        add     eax, Table
        mov     cl, [esi+edi]
        mov     edi, L13
        shl     ecx, 6
        mov     esi, L12
        add     ecx, ebx
        add     edi, 4
        mov     bl, [eax+edx]
        mov     eax, L15
        shl     ebx, 11
        add     esi, 4
        add     ebx, ecx
        mov     edx, L11
        shl     ebx, 16
        add     eax, ebx
        mov     [edi-4], eax
        dec     edx
        je      @@last
        mov     eax, [esi]
        mov     L11, edx
        mov     ebx, eax
        mov     ecx, eax
        and     ebx, $FFFF0000
        and     ecx, $FFFF
        cmp     ebx, L8
        je      @@b2
        cmp     ecx, L6
        je      @@b1
        mov     L12, esi
        mov     esi, eax
        jmp     @@both
@@b1:
        cmp     eax, L9
        je      @@skip
        jmp     @@lokey
@@b2:
        cmp     eax, L9
        je      @@skip
@@hikey:
        xor     edx, edx
        mov     esp, eax
        mov     dx, [edi]
        mov     L10, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        shr     eax, 1
        mov     edx, L10
        shr     edx, 6
        and     eax, $3E0
        shr     esp, 6
        add     eax, Table
        and     edx, $1F
        and     esp, $3E0
        add     eax, edx
        mov     edx, L10
        shr     edx, 11
        add     esp, Table
        mov     cl, [eax]
        and     edx, $1F
        shl     ecx, 6
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 11
        add     edi, 4
        add     ecx, ebx
        add     esi, 4
        mov     edx, L11
        mov     [edi-4], cx
        dec     edx
        je      @@last
        mov     eax, [esi]
        mov     L11, edx
        jmp     @@check
@@lokey:
        shr     eax, 16
        xor     edx, edx
        mov     dx, [edi+2]
        mov     esp, eax
        mov     L10, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        shr     eax, 1
        mov     edx, L10
        shr     edx, 6
        and     eax, $3E0
        shr     esp, 6
        add     eax, Table
        and     edx, $1F
        and     esp, $3E0
        add     eax, edx
        mov     edx, L10
        shr     edx, 11
        add     esp, Table
        mov     cl, [eax]
        and     edx, $1F
        shl     ecx, 6
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 11
        add     edi, 4
        add     ecx, ebx
        add     esi, 4
        mov     edx, L11
        mov     [edi-2], cx
        dec     edx
        je      @@last
        mov     eax, [esi]
        mov     L11, edx
        jmp     @@check
@@last:
        mov     ecx, L3
        xor     eax, eax
        test    ecx, ecx
        je      @@next
        xor     edx, edx
        mov     ax, [esi]
        cmp     eax, L6
        jne     @@s2
        add     esi, 2
        add     edi, 2
        jmp     @@next
@@s2:
        mov     dx, [edi]
        mov     esp, eax
        mov     L10, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        shr     eax, 1
        mov     edx, L10
        shr     edx, 6
        and     eax, $3E0
        shr     esp, 6
        add     eax, Table
        and     edx, $1F
        and     esp, $3E0
        add     eax, edx
        mov     edx, L10
        shr     edx, 11
        add     esp, Table
        mov     cl, [eax]
        and     edx, $1F
        shl     ecx, 6
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 11
        add     edi, 2
        add     ecx, ebx
        add     esi, 2
        mov     [edi-2], cx
@@next:
        add     esi, L4
        add     edi, L5
        dec     Height
        jne     @@row
        mov     esp, L7
@@exit:
        pop     edi
        pop     esi
        pop     ebx
end;

procedure BlendStretched555(RowTable, ColTable: Pointer; Dst: Pointer; DstPitch, Width, Height: Integer; Table: Pointer); pascal;
var
  L1, L2, L3, L4, L5: Integer;
asm
        push    ebx
        push    esi
        push    edi
        mov     ebx, Width
        mov     eax, DstPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L1, eax
        mov     edi, Dst
        xor     ecx, ecx
        mov     L2, esp
        mov     L3, ecx
@@row:
        mov     esp, RowTable
        mov     esi, [esp+ecx*4]
        xor     ebx, ebx
        mov     esp, ColTable
@@col:
        mov     edx, [esp+ebx*4]
        xor     eax, eax
        mov     ax, [esi+edx*2]
        mov     L4, ebx
        xor     edx, edx
        mov     dx, [edi]
        mov     esp, eax
        mov     L5, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        mov     edx, L5
        and     eax, $3E0
        shr     edx, 5
        add     eax, Table
        shr     esp, 5
        and     edx, $1F
        add     eax, edx
        and     esp, $3E0
        mov     edx, L5
        add     esp, Table
        shr     edx, 10
        mov     cl, [eax]
        shl     ecx, 5
        and     edx, $1F
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 10
        add     edi, 2
        add     ecx, ebx
        mov     ebx, L4
        mov     [edi-2], cx
        inc     ebx
        mov     esp, ColTable
        mov     ecx, L3
        cmp     ebx, Width
        jne     @@col
        inc     ecx
        cmp     ecx, Height
        je      @@done
        mov     L3, ecx
        add     edi, L1
        jmp     @@row
@@done:
        mov     esp, L2
        pop     edi
        pop     esi
        pop     ebx
end;

procedure BlendStretched565(RowTable, ColTable: Pointer; Dst: Pointer; DstPitch, Width, Height: Integer; Table: Pointer); pascal;
var
  L1, L2, L3, L4, L5: Integer;
asm
        push    ebx
        push    esi
        push    edi
        mov     ebx, Width
        mov     eax, DstPitch
        add     ebx, ebx
        sub     eax, ebx
        mov     L1, eax
        mov     edi, Dst
        xor     ecx, ecx
        mov     L2, esp
        mov     L3, ecx
@@row:
        mov     esp, RowTable
        mov     esi, [esp+ecx*4]
        xor     ebx, ebx
        mov     esp, ColTable
@@col:
        mov     edx, [esp+ebx*4]
        xor     eax, eax
        mov     ax, [esi+edx*2]
        mov     L4, ebx
        xor     edx, edx
        mov     dx, [edi]
        mov     esp, eax
        mov     L5, edx
        and     eax, $1F
        and     edx, $1F
        shl     eax, 5
        add     edx, Table
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, [edx+eax]
        mov     eax, esp
        shr     eax, 1
        mov     edx, L5
        shr     edx, 6
        and     eax, $3E0
        shr     esp, 6
        add     eax, Table
        and     edx, $1F
        and     esp, $3E0
        add     eax, edx
        mov     edx, L5
        shr     edx, 11
        add     esp, Table
        mov     cl, [eax]
        and     edx, $1F
        shl     ecx, 6
        add     ecx, ebx
        mov     bl, [esp+edx]
        shl     ebx, 11
        add     edi, 2
        add     ecx, ebx
        mov     ebx, L4
        mov     [edi-2], cx
        inc     ebx
        mov     esp, ColTable
        mov     ecx, L3
        cmp     ebx, Width
        jne     @@col
        inc     ecx
        cmp     ecx, Height
        je      @@done
        mov     L3, ecx
        add     edi, L1
        jmp     @@row
@@done:
        mov     esp, L2
        pop     edi
        pop     esi
        pop     ebx
end;

procedure InitBlendTables(Bits, Count: Integer);
begin
  AlphaBlendTable.GenerateLookupTables(Bits, GenerateAlphaBlendTable, Count);
  IntensityBlendTable.GenerateLookupTables(Bits, GenerateIntensityBlendTable, Count);
  BrightenBlendTable.GenerateLookupTables(Bits, GenerateBrightenBlendTable, Count);
  ShadowBlendTable.GenerateLookupTables(Bits, GenerateShadowBlendTable, Count);
  LinearAlphaBlendTable.GenerateLookupTables(Bits, GenerateLinearAlphaBlendTable, Count);
end;

{ TGFXEPalette }

procedure TGFXEPalette.LoadFromStream(Stream: TStream);
begin
  Stream.Read(PixelFormatID, SizeOf(PixelFormatID));
  Stream.Read(Entries, SizeOf(Entries));
end;

procedure TGFXEPalette.SaveToStream(Stream: TStream);
begin
  Stream.Write(PixelFormatID, SizeOf(PixelFormatID));
  Stream.Write(Entries, SizeOf(Entries));
end;

procedure TGFXEPalette.Assign(Source: TGFXEPalette);
begin
  Entries := Source.Entries;
  PixelFormatID := Source.PixelFormatID;
end;

function TGFXEPalette.GetEntry(Index: Integer): PPaletteEntry;
begin
  Result := @Entries[Index];
end;

function TGFXEPalette.Remap(NewPixelFormatID: Integer): HResult;
var
  I: Integer;
begin
  Result := GFXE_OK;
  if NewPixelFormatID <> PixelFormatID then
  begin
    case PixelFormatID of
      pfBGR24:
        case NewPixelFormatID of
          pfRGB565:
            for I := 0 to 255 do
              with Entries[I] do W := (R and $F8) shl 8 + (G and $FC) shl 3 + B shr 3;
          pfRGB555:
            for I := 0 to 255 do
              with Entries[I] do W := (R and $F8) shl 7 + (G and $F8) shl 2 + B shr 3;
          pfXRGB32: Result := GFXE_OK;
        else
          Result := GFXE_NOTSUPPORTED;
        end;
      pfRGB24:
        case NewPixelFormatID of
          pfRGB565:
            for I := 0 to 255 do
              with Entries[I] do W := (B and $F8) shl 8 + (G and $FC) shl 3 + R shr 3;
          pfRGB555:
            for I := 0 to 255 do
              with Entries[I] do W := (B and $F8) shl 7 + (G and $F8) shl 2 + R shr 3;
          pfXRGB32: Result := GFXE_OK;
        else
          Result := GFXE_NOTSUPPORTED;
        end;
    else
      Result := GFXE_NOTSUPPORTED;
    end;
    if Succeeded(Result) then PixelFormatID := NewPixelFormatID;
  end
  else
    Result := GFXE_OK;
end;

function TGFXEPalette.GetNearestColor(Color: TColor): Integer;
var
  Best: Integer;
  R, G, B: Integer;
  I, D, BestDist: Integer;
  E: PPaletteEntry;
begin
  Color := ColorToRGB(Color);
  R := Color and $FF;
  G := Color shr 8 and $FF;
  B := Color shr 16 and $FF;
  Best := 0;
  BestDist := $FFFFFF;
  for I := 0 to 255 do
  begin
    E := @Entries[I];
    D := Abs(E.R - R) + Abs(E.G - G) + Abs(E.B - B);
    if D < BestDist then
    begin
      BestDist := D;
      Best := I;
    end;
  end;
  Result := Best;
end;

function TGFXEPalette.Compare(Palette: TGFXEPalette): Boolean;
var
  I: Integer;
begin
  if Palette.PixelFormatID = PixelFormatID then
    case PixelFormatID and $1F of
      8:
        begin
          Result := True;
          I := 255;
          while (I >= 0) and Result do
          begin
            Result := Palette.Entries[I].W = Entries[I].W;
            Dec(I);
          end;
        end;
      16:
        begin
          Result := True;
          I := 255;
          while (I >= 0) and Result do
          begin
            Result := Palette.Entries[I].W = Entries[I].W;
            Dec(I);
          end;
        end;
      24:
        begin
          Result := True;
          I := 255;
          while (I >= 0) and Result do
          begin
            Result := (Palette.Entries[I].W = Entries[I].W) and (Palette.Entries[I].B = Entries[I].B);
            Dec(I);
          end;
        end;
      32: Result := CompareMem(@Entries, @Palette.Entries, SizeOf(Entries));
    else
      Result := False;
    end
  else
    Result := False;
end;

{ The original unit was longer: the line numbers compiled into the Assert calls (11932 for the next Assert below) prove that 737 more lines preceded this point. Their content is unknown; the blank lines below keep the Assert line numbers identical. }

































































































































































































































































































































































































































































































































































































































































































































































{ TSurface }

function TSurface.GetPixelInfo(X, Y: Integer): Integer;
var
  SD: TSurfaceDesc;
  P: Pointer;
begin
  if Succeeded(Lock(SD)) then
  begin
    try
      Assert((X >= 0) and (X < SD.Width) and (Y >= 0) and (Y < SD.Height), 'Coordinates out of bounds!');
      case SD.BitCount of
        8: Result := PByte(X + Integer(SD.Data) + Y * SD.Pitch)^;
        16: Result := PWord(X + X + Integer(SD.Data) + Y * SD.Pitch)^;
        24:
          if X + 1 < SD.Width then
            Result := PInteger(X + X + X + Integer(SD.Data) + Y * SD.Pitch)^ and $FFFFFF
          else
          begin
            P := Pointer(X + X + X + Integer(SD.Data) + Y * SD.Pitch);
            Result := PWord(P)^ + PByte(Integer(P) + 2)^ shl 16;
          end;
        32: Result := PInteger(X shl 2 + Integer(SD.Data) + Y * SD.Pitch)^;
      else
        Assert(False, 'Pixel format not supported (GetColor)'); Result := 0;
      end;
    finally
      Unlock;
    end;
  end else begin Assert(False, 'Cannot Lock Surface'); Result := -1; end;
end;

function TSurface.GetPixelFormatID: Integer;
var
  SD: TSurfaceDesc;
begin
  if Succeeded(Lock(SD)) then
  begin
    Result := SD.PixelFormatID; Unlock;
  end else Result := 0;
end;

function TSurface.GetColor(X, Y: Integer): TColor;
var
  SD: TSurfaceDesc;
  P: PByteArray;
  V: Integer;
  W: Word; Index: Byte;
begin
  if Succeeded(Lock(SD)) then
  begin
    try
      Assert((X >= 0) and (X < SD.Width) and (Y >= 0) and (Y < SD.Height), 'Coordinates out of bounds!');
      { 8 bit pixels need the palette; 1555 and the TColor ordered 24 bit layout are not handled }
      case SD.PixelFormatID of
        pfRGB555: begin
          W := PWord(X + X + Integer(SD.Data) + Y * SD.Pitch)^;
          Result := (W and $7C00) shr 7 + (W and $03E0) shl 6 + (W and $1F) shl 19;
        end;
        pfRGB565: begin
          W := PWord(X + X + Integer(SD.Data) + Y * SD.Pitch)^;
          Result := (W and $F800) shr 8 + (W and $07E0) shl 5 + (W and $1F) shl 19;
        end;
        pfPAL8: begin
          Assert(SD.Palette <> nil, 'Palette not found, cannot retrieve color (GetColor)');
          Index := PByte(X + Integer(SD.Data) + Y * SD.Pitch)^; P := @SD.Palette.Entries[Index];
          Result := P[0] + P[1] shl 8 + P[2] shl 16;
        end;
        pfRGB24: begin
          P := Pointer(X + X + X + Integer(SD.Data) + Y * SD.Pitch);
          Result := P[2] + P[1] shl 8 + P[0] shl 16;
        end;
        pfRGB32: begin
          V := PInteger(X shl 2 + Integer(SD.Data) + Y * SD.Pitch)^;
          Result := (V and $FF0000) shr 16 + (V and $FF00) + (V and $FF) shl 16;
        end;
      else
        Assert(False, 'Pixel format not supported (GetColor)'); Result := 0;
      end;
    finally
      Unlock;
    end;
  end else begin Assert(False, 'Cannot Lock Surface'); Result := -1; end;
end;

function TSurface.Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
var
  DSD: TSurfaceDesc;
  SSD: TSurfaceDesc;
  R: TRect;
  S, D: Pointer;
begin
  if Dest.PixelFormatID = PixelFormatID then
  begin
    if Succeeded(Dest.Lock(DSD)) then
    begin
      if Succeeded(Lock(SSD)) then
      begin
        if SrcRect = nil then
        begin
          R.Left := 0;
          R.Right := SSD.Width;
          R.Top := 0;
          R.Bottom := SSD.Height;
          SrcRect := @R;
        end;
        S := Pointer(SrcRect.Left * SSD.BitCount div 8 + Integer(SSD.Data) + SrcRect.Top * SSD.Pitch);
        D := Pointer(X * DSD.BitCount div 8 + Integer(DSD.Data) + Y * DSD.Pitch);
        BltRect(S, D, SSD.Pitch, DSD.Pitch, (SrcRect.Right - SrcRect.Left) * DSD.BitCount div 8, SrcRect.Bottom - SrcRect.Top);
        Unlock;
        Result := GFXE_OK;
      end
      else
        Result := GFXE_CANNOTLOCK;
      Dest.Unlock;
    end
    else
      Result := GFXE_CANNOTLOCK;
  end
  else
    Result := GFXE_PIXELFORMATNOTSUPPORTED;
end;

function TSurface.BltClipped(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
var
  W, H: Integer;
  R: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Right := GetWidth;
    R.Top := 0;
    R.Bottom := GetHeight;
  end
  else
  begin
    R := SrcRect^;
    if R.Right > GetWidth then R.Right := GetWidth;
    if R.Left < 0 then
    begin
      X := X - R.Left;
      R.Left := 0;
    end;
  end;
  if X < 0 then
  begin
    R.Left := R.Left - X;
    X := 0;
  end;
  W := R.Right - R.Left;
  if Dest.GetWidth < X + W then W := W - (X + W - Dest.GetWidth);
  if R.Bottom > GetHeight then R.Bottom := GetHeight;
  if R.Top < 0 then
  begin
    Y := Y - R.Top;
    R.Top := 0;
  end;
  if Y < 0 then
  begin
    R.Top := R.Top - Y;
    Y := 0;
  end;
  H := R.Bottom - R.Top;
  if Dest.GetHeight < H + Y then H := H - (H + Y - Dest.GetHeight);
  if (W > 0) and (H > 0) then
  begin
    R.Right := W + R.Left;
    R.Bottom := R.Top + H;
    Result := Blt(Dest, @R, X, Y);
  end
  else
    Result := GFXE_OK;
end;

function TSurface.BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult;
begin
  Result := GFXE_NOTSUPPORTED;
end;

function TSurface.BltStretch(Dest: TSurface; SrcRect, DestRect: PRect): HResult;
var
  R: TRect;
  DR: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Right := GetWidth;
    R.Top := 0;
    R.Bottom := GetHeight;
    SrcRect := @R;
  end;
  if DestRect = nil then
  begin
    DR.Left := 0;
    DR.Right := Dest.GetWidth;
    DR.Top := 0;
    DR.Bottom := Dest.GetHeight;
    DestRect := @DR;
  end;
  if (SrcRect.Right - SrcRect.Left = DestRect.Right - DestRect.Left) and
    (SrcRect.Bottom - SrcRect.Top = DestRect.Bottom - DestRect.Top) then
    Result := Blt(Dest, SrcRect, DestRect.Left, DestRect.Top)
  else
    Result := GFXE_NOTSUPPORTED;
end;

function TSurface.BltColorKey(Dest: TSurface; SrcRect: PRect; X, Y: Integer; ColorKey: TColor): HResult;
var
  DSD: TSurfaceDesc;
  SSD: TSurfaceDesc;
  R: TRect;
  S, D: Pointer;
begin
  if (Dest.PixelFormatID = PixelFormatID) and (PixelFormatID and $FF = 16) then
  begin
    if Succeeded(Dest.Lock(DSD)) then
    begin
      if Succeeded(Lock(SSD)) then
      begin
        if SrcRect = nil then
        begin
          R.Left := 0;
          R.Right := SSD.Width;
          R.Top := 0;
          R.Bottom := SSD.Height;
          SrcRect := @R;
        end;
        S := Pointer(SrcRect.Left * SSD.BitCount div 8 + Integer(SSD.Data) + SrcRect.Top * SSD.Pitch);
        D := Pointer(X * DSD.BitCount div 8 + Integer(DSD.Data) + Y * DSD.Pitch);
        BltColorKey16(S, D, SSD.Pitch, DSD.Pitch, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, ColorKey);
        Result := GFXE_OK;
        Unlock;
      end
      else
        Result := GFXE_CANNOTLOCK;
      Dest.Unlock;
    end
    else
      Result := GFXE_CANNOTLOCK;
  end
  else
    Result := GFXE_PIXELFORMATNOTSUPPORTED;
end;

function TSurface.BltColorKeyClipped(Dest: TSurface; SrcRect: PRect; X, Y: Integer; ColorKey: TColor): HResult;
var
  W, H: Integer;
  R: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Right := GetWidth;
    R.Top := 0;
    R.Bottom := GetHeight;
  end
  else
  begin
    R := SrcRect^;
    if R.Right > GetWidth then R.Right := GetWidth;
    if R.Left < 0 then
    begin
      X := X - R.Left;
      R.Left := 0;
    end;
  end;
  if X < 0 then
  begin
    R.Left := R.Left - X;
    X := 0;
  end;
  W := R.Right - R.Left;
  if Dest.GetWidth < X + W then W := W - (X + W - Dest.GetWidth);
  if R.Bottom > GetHeight then R.Bottom := GetHeight;
  if R.Top < 0 then
  begin
    Y := Y - R.Top;
    R.Top := 0;
  end;
  if Y < 0 then
  begin
    R.Top := R.Top - Y;
    Y := 0;
  end;
  H := R.Bottom - R.Top;
  if Dest.GetHeight < H + Y then H := H - (H + Y - Dest.GetHeight);
  if (W > 0) and (H > 0) then
  begin
    R.Right := W + R.Left;
    R.Bottom := R.Top + H;
    Result := BltColorKey(Dest, @R, X, Y, ColorKey);
  end
  else
    Result := GFXE_OK;
end;

function TSurface.UpdatePalette: HResult;
begin
  Result := GFXE_NOTSUPPORTED;
end;

function TSurface.Lock(var SD: TSurfaceDesc): HResult;
begin
  Result := GFXE_NOTSUPPORTED;
end;

function TSurface.LockEx(var SD: TSurfaceDesc; const R: TRect): HResult;
begin
  if (R.Left >= 0) and (R.Top >= 0) and (R.Bottom <= GetHeight) and (R.Right <= GetWidth) then
  begin
    Result := Lock(SD);
    if Succeeded(Result) then
    begin
      SD.Data := Pointer(Integer(SD.Data) + (R.Left * SD.BitCount) shr 3 + R.Top * SD.Pitch);
      SD.Width := R.Right - R.Left;
      SD.Height := R.Bottom - R.Top;
      SD.ClipRect.Right := SD.Width;
      SD.ClipRect.Bottom := SD.Height;
    end;
  end
  else
    Result := GFXE_ERROR;
end;

function TSurface.Unlock: HResult;
begin
  Result := GFXE_NOTSUPPORTED;
end;

function TSurface.UnlockEx(const SD: TSurfaceDesc): HResult;
begin
  Result := Unlock;
end;

function TSurface.Resize(AWidth, AHeight: Integer): HResult;
begin
  Result := GFXE_NOTSUPPORTED;
end;

function TSurface.Cls(Color: TColor): HResult;
var
  SD: TSurfaceDesc;
  Pixel: Integer;
  I: Integer;
begin
  if Succeeded(Lock(SD)) then
  begin
    Pixel := Color2PixelInfo(Color, SD.PixelFormatID, nil);
    Result := GFXE_OK;
    case SD.BitCount of
      8: for I := 0 to SD.Height - 1 do
           FillChar(Pointer(Integer(SD.Data) + SD.Pitch * I)^, SD.Width, Pixel);
      16: for I := 0 to SD.Height - 1 do
            FillWord(Pointer(Integer(SD.Data) + SD.Pitch * I)^, SD.Width, Pixel);
      24: for I := 0 to SD.Height - 1 do
            FillTrippleByte(Pointer(Integer(SD.Data) + SD.Pitch * I)^, SD.Width, Pixel);
      32: for I := 0 to SD.Height - 1 do
            FillInt(Pointer(Integer(SD.Data) + SD.Pitch * I)^, SD.Width, Pixel);
    else
      Result := GFXE_NOTSUPPORTED;
    end;
    Unlock;
  end
  else
    Result := GFXE_NOTSUPPORTED;
end;

{ TGDISurface }

constructor TGDISurface.Create(AHandle: HWND);
begin
  inherited Create;
  FHandle := AHandle;
end;

function TGDISurface.GetHandle: HWND;
begin
  Result := FHandle;
end;

procedure TGDISurface.SetHandle(Value: HWND);
begin
  FHandle := Value;
end;

function TGDISurface.GetWidth: Integer;
var
  R: TRect;
begin
  if GetClientRect(Handle, R) then
    Result := R.Right - R.Left
  else
    Result := -1;
end;

function TGDISurface.GetHeight: Integer;
var
  R: TRect;
begin
  if GetClientRect(Handle, R) then
    Result := R.Bottom - R.Top
  else
    Result := -1;
end;

function TGDISurface.Blt(Dest: TSurface; SrcRect: PRect; X, Y: Integer): HResult;
begin
  Result := GFXE_NOTSUPPORTED;
end;

function TGDISurface.BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult;
var
  SrcDC: HDC;
  R: TRect;
  DR: TRect;
begin
  SrcDC := GetDC(Handle);
  if SrcRect = nil then
  begin
    GetClientRect(Handle, R);
    SrcRect := @R;
  end;
  if DestRect = nil then
  begin
    GetClientRect(WindowFromDC(DC), DR);
    DestRect := @DR;
  end;
  if StretchBlt(DC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left,
    DestRect.Bottom - DestRect.Top, SrcDC, SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left,
    SrcRect.Bottom - SrcRect.Top, SRCCOPY) then
    Result := GFXE_OK
  else
    Result := GFXE_ERROR;
  ReleaseDC(Handle, SrcDC);
end;

function TGDISurface.Resize(AWidth, AHeight: Integer): HResult;
begin
  if SetWindowPos(Handle, 0, 0, 0, AWidth, AHeight, SWP_NOMOVE or SWP_NOZORDER) then
    Result := GFXE_OK
  else
    Result := GFXE_ERROR;
end;

function TGDISurface.Cls(Color: TColor): HResult;
var
  H: HWND;
  B: HBRUSH;
  DC: HDC;
  R: TRect;
begin
  H := Handle;
  DC := GetDC(H);
  GetClientRect(H, R);
  B := CreateSolidBrush(ColorToRGB(Color));
  FillRect(DC, R, B);
  DeleteObject(B);
  ReleaseDC(H, DC);
  Result := GFXE_OK;
end;

{ TDataSurface }

constructor TDataSurface.Create(AWidth, AHeight, APixelFormatID: Integer; APalette: TGFXEPalette);
begin
  inherited Create;
  FBitCount := APixelFormatID and $FF;
  FPixelFormatID := APixelFormatID;
  SetPalette(APalette);
  Resize(AWidth, AHeight);
end;

constructor TDataSurface.CreateFromSurface(Surface: TSurface; R: PRect);
begin
  inherited Create;
  CaptureSurface(Surface, R);
end;

destructor TDataSurface.Destroy;
begin
  FPalette.Free;
  FPalette := nil;
  ReallocMem(FMem, 0);
  inherited Destroy;
end;

function TDataSurface.GetPixelFormatID: Integer;
begin
  Result := FPixelFormatID;
end;

function TDataSurface.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TDataSurface.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TDataSurface.Lock(var SD: TSurfaceDesc): HResult;
begin
  FillChar(SD, SizeOf(SD), 0);
  SD.Width := FWidth;
  SD.Height := FHeight;
  SD.BitCount := FBitCount;
  SD.PixelFormatID := FPixelFormatID;
  SD.ClipRect.Left := 0;
  SD.ClipRect.Right := FWidth;
  SD.ClipRect.Top := 0;
  SD.ClipRect.Bottom := FHeight;
  SD.Pitch := FPitch;
  SD.Data := FData;
  Result := GFXE_OK;
end;

function TDataSurface.Unlock: HResult;
begin
  Result := GFXE_OK;
end;

function TDataSurface.CaptureSurface(Surface: TSurface; R: PRect): HResult;
var
  SD: TSurfaceDesc;
  RR: TRect;
  W, H: Integer;
begin
  Result := Surface.Lock(SD);
  if Succeeded(Result) then
  begin
    try
      FBitCount := SD.BitCount;
      FPixelFormatID := SD.PixelFormatID;
      if R = nil then
      begin
        RR.Left := 0;
        RR.Right := SD.Width;
        RR.Top := 0;
        RR.Bottom := SD.Height;
        R := @RR;
      end;
      W := R.Right - R.Left;
      H := R.Bottom - R.Top;
      if (W > 0) and (H > 0) then
      begin
        Resize(W, H);
        SetPalette(SD.Palette);
        FX := R.Left;
        FY := R.Top;
        BltRect(Pointer((FX * FBitCount) shr 3 + (FY * SD.Pitch + Integer(SD.Data))), FData,
          SD.Pitch, FPitch, (FWidth * FBitCount) shr 3, FHeight);
      end;
    except
      FX := 30;
    end;
    Surface.Unlock;
    Result := GFXE_OK;
  end;
end;

procedure TDataSurface.SetPalette(Palette: TGFXEPalette);
begin
  if Palette <> nil then
  begin
    if FPalette = nil then FPalette := TGFXEPalette.Create;
    FPalette.Assign(Palette);
  end
  else
  begin
    FPalette.Free;
    FPalette := nil;
  end;
end;

function TDataSurface.Resize(AWidth, AHeight: Integer): HResult;
var
  Size: Integer;
begin
  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin
    FWidth := AWidth;
    FHeight := AHeight;
    FPitch := (((FBitCount + 7) shr 3) * FWidth + 7) and not 7;
    Size := FPitch * FHeight + 7;
    ReallocMem(FMem, Size);
    FData := Pointer((Integer(FMem) + 7) and not 7);
    Result := GFXE_OK;
  end
  else
    Result := GFXE_OK;
end;

function GetErrorMsg(ErrorCode: HResult): string;
begin
  case ErrorCode of
    GFXE_OK: Result := 'No ERROR occurred!';
    GFXE_ERROR: Result := 'Undefine ERROR occurred';
    GFXE_NOTSUPPORTED: Result := 'Function is not supported';
    GFXE_PIXELFORMATNOTSUPPORTED: Result := 'PixelFormat is not supported';
    GFXE_BITMAPFORMATNOTSUPPORTED: Result := 'Bitmap format is not supported';
  else
    Result := 'Undocumented Error (Error Code:' + IntToStr(ErrorCode) + ')';
  end;
end;

procedure SaveGFXESettingsToStream(Stream: TStream);
begin
end;

procedure LoadGFXESettingsFromStream(Stream: TStream);
begin
end;

procedure WriteGFXESettingsToRegistry(const Key: string);
begin
  try
  finally
  end;
end;

procedure ReadGFXESettingsFromRegistry(const Key: string);
begin
  try
  finally
  end;
end;

{ DirectDraw: display modes and the DirectDraw object }

function DisplayModeSupportedCallback(DDSD: PDDSurfaceDesc; Context: Pointer): HResult; stdcall;
begin
  if (EnumDDSD.ddpfPixelFormat.dwRBitMask = DDSD.ddpfPixelFormat.dwRBitMask) and
    (EnumDDSD.ddpfPixelFormat.dwGBitMask = DDSD.ddpfPixelFormat.dwGBitMask) and
    (EnumDDSD.ddpfPixelFormat.dwBBitMask = DDSD.ddpfPixelFormat.dwBBitMask) then
    Inc(ModeCount);
  Result := DDENUMRET_OK;
end;

function GetPrimarySurfacePFID: Integer;
var
  DDSD: TDDSurfaceDesc;
  S: IDirectDrawSurface;
begin
  if DD <> nil then
  begin
    FillChar(DDSD, SizeOf(DDSD), 0);
    DDSD.dwSize := SizeOf(DDSD);
    DDSD.dwFlags := DDSD_CAPS;
    DDSD.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;
    DD.SetCooperativeLevel(0, DDSCL_NORMAL);
    if Succeeded(DD.CreateSurface(DDSD, S, nil)) then
    begin
      Result := DDStoPFID(S);
      S := nil;
    end
    else
      Result := 0;
  end
  else
    Result := 0;
end;

function DisplayModeSupported(Width, Height, PixelFormatID: Integer): Boolean;
begin
  if DD <> nil then
  begin
    FillChar(EnumDDSD, SizeOf(EnumDDSD), 0);
    EnumDDSD.dwSize := SizeOf(EnumDDSD);
    EnumDDSD.dwFlags := DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT;
    EnumDDSD.dwWidth := Width;
    EnumDDSD.dwHeight := Height;
    EnumDDSD.ddpfPixelFormat.dwSize := SizeOf(TDDPixelFormat);
    EnumDDSD.ddpfPixelFormat.dwFlags := DDPF_RGB;
    EnumDDSD.ddpfPixelFormat.dwRGBBitCount := PFIDtoMASK(PixelFormatID,
      Integer(EnumDDSD.ddpfPixelFormat.dwRBitMask), Integer(EnumDDSD.ddpfPixelFormat.dwGBitMask),
      Integer(EnumDDSD.ddpfPixelFormat.dwBBitMask), Integer(EnumDDSD.ddpfPixelFormat.dwRGBAlphaBitMask));
    ModeCount := 0;
    DD.EnumDisplayModes(0, @EnumDDSD, nil, @DisplayModeSupportedCallback);
    Result := ModeCount <> 0;
  end
  else
    Result := False;
end;

{ TDisplayModeList }

constructor TDisplayModeList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TDisplayModeList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TDisplayModeList.Clear;
begin
  while FList.Count <> 0 do Delete(FList.Count - 1);
end;

function TDisplayModeList.GetItems(Index: Integer): TDisplayModeItem;
begin
  Result := TDisplayModeItem(FList.List^[Index]);
end;

function TDisplayModeList.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TDisplayModeList.Add(AWidth, AHeight, APixelFormatID: Integer);
var
  Item: TDisplayModeItem;
begin
  Item := TDisplayModeItem.Create;
  Item.Width := AWidth;
  Item.Height := AHeight;
  Item.PixelFormatID := APixelFormatID;
  FList.Add(Item);
end;

procedure TDisplayModeList.Delete(Index: Integer);
begin
  TDisplayModeItem(FList.Items[Index]).Free;
  FList.Delete(Index);
end;

{ ListPixelFormatID is never set (original): every mode is listed. }
function ListDisplayModesCallback(DDSD: PDDSurfaceDesc; Context: Pointer): HResult; stdcall;
var
  PFID: Integer;
begin
  PFID := MASKtoPFID(DDSD.ddpfPixelFormat.dwRGBBitCount, DDSD.ddpfPixelFormat.dwRBitMask,
    DDSD.ddpfPixelFormat.dwGBitMask, DDSD.ddpfPixelFormat.dwBBitMask, DDSD.ddpfPixelFormat.dwRGBAlphaBitMask);
  if (ListPixelFormatID = 0) or (PFID = ListPixelFormatID) then
    TDisplayModeList(Context).Add(DDSD.dwWidth, DDSD.dwHeight, PFID);
  Result := DDENUMRET_OK;
end;

procedure ListDisplayModes(List: TDisplayModeList; Width, Height, PixelFormatID: Integer);
begin
  if DD <> nil then
  begin
    FillChar(EnumDDSD, SizeOf(EnumDDSD), 0);
    EnumDDSD.dwSize := SizeOf(EnumDDSD);
    if Width <> 0 then
    begin
      EnumDDSD.dwFlags := EnumDDSD.dwFlags or DDSD_WIDTH;
      EnumDDSD.dwWidth := Width;
    end;
    if Height <> 0 then
    begin
      EnumDDSD.dwFlags := EnumDDSD.dwFlags or DDSD_HEIGHT;
      EnumDDSD.dwHeight := Height;
    end;
    if PixelFormatID <> 0 then
    begin
      EnumDDSD.dwFlags := EnumDDSD.dwFlags or DDSD_PIXELFORMAT;
      EnumDDSD.ddpfPixelFormat.dwSize := SizeOf(TDDPixelFormat);
      EnumDDSD.ddpfPixelFormat.dwFlags := DDPF_RGB;
      EnumDDSD.ddpfPixelFormat.dwRGBBitCount := PFIDtoMASK(PixelFormatID,
        Integer(EnumDDSD.ddpfPixelFormat.dwRBitMask), Integer(EnumDDSD.ddpfPixelFormat.dwGBitMask),
        Integer(EnumDDSD.ddpfPixelFormat.dwBBitMask), Integer(EnumDDSD.ddpfPixelFormat.dwRGBAlphaBitMask));
    end;
    DD.EnumDisplayModes(0, @EnumDDSD, List, @ListDisplayModesCallback);
  end;
end;

procedure ForceOptimal16BitPixelFormatID(PixelFormatID: Integer);
begin
  if (PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555) then
    ForcedPixelFormatID := PixelFormatID
  else
    ForcedPixelFormatID := 0;
end;

function GetOptimalPixelFormatID(BitCount: Integer): Integer;
begin
  case BitCount of
    8: Result := pfPAL8;
    16:
      if ForcedPixelFormatID = 0 then
      begin
        Result := GetPrimarySurfacePFID;
        if (Result <> pfRGB565) and (Result <> pfRGB555) and (Result <> pfARGB1555) then
          if DisplayModeSupported(Screen.Width, Screen.Height, pfRGB565) then
            Result := pfRGB565
          else if DisplayModeSupported(Screen.Width, Screen.Height, pfRGB555) then
            Result := pfRGB555
          else if DisplayModeSupported(640, 480, pfRGB565) then
            Result := pfRGB565
          else if DisplayModeSupported(640, 480, pfRGB555) then
            Result := pfRGB555
          else
            Result := pfRGB555;
      end
      else
        Result := ForcedPixelFormatID;
    24: Result := pfRGB24;
    32: Result := pfXRGB32;
  else
    Result := 0;
  end;
end;

function DDStoPFID(Surface: IDirectDrawSurface): Integer;
var
  DDSD: TDDSurfaceDesc;
begin
  if Surface <> nil then
  begin
    FillChar(DDSD, SizeOf(DDSD), 0);
    DDSD.dwSize := SizeOf(DDSD);
    Result := Surface.Lock(nil, DDSD, DDLOCK_WAIT, 0);
    if Result >= 0 then
    begin
      Result := MASKtoPFID(DDSD.ddpfPixelFormat.dwRGBBitCount, DDSD.ddpfPixelFormat.dwRBitMask,
        DDSD.ddpfPixelFormat.dwGBitMask, DDSD.ddpfPixelFormat.dwBBitMask, DDSD.ddpfPixelFormat.dwRGBAlphaBitMask);
      Surface.Unlock(nil);
    end
    else
      Result := 0;
  end
  else
    Result := 0;
end;

function DirectDrawActivated: Boolean;
begin
  Result := FDirectDrawActivated;
end;

function ActivateDirectDraw: Boolean;
begin
  if not FDirectDrawActivated then
  begin
    if Succeeded(CoInitialize(nil)) then
    begin
      if Succeeded(CoCreateInstance(CLSID_DirectDraw, nil, CLSCTX_ALL, IID_IDirectDraw2, FDirectDraw)) then
        if Succeeded(FDirectDraw.Initialize(nil)) then
          FDirectDrawActivated := True
        else
          FDirectDraw := nil;
      if not FDirectDrawActivated then CoUninitialize;
    end;
  end;
  Result := FDirectDrawActivated;
end;

procedure DeactivateDirectDraw;
begin
  if FDirectDrawActivated then
  begin
    FDirectDraw := nil;
    CoUninitialize;
  end;
end;

function DD: IDirectDraw2;
begin
  if not FDirectDrawActivated then
    if ActivateDirectDraw then
      Result := FDirectDraw
    else
      Result := nil
  else
    Result := FDirectDraw;
end;

function CPUIDSupported: Boolean;
var
  Supported: Boolean;
asm
        lea     edx, Supported
        push    ebx
        mov     Supported, True
        pushfd
        pop     eax
        mov     ecx, eax
        xor     eax, $200000
        push    eax
        popfd
        pushfd
        pop     eax
        xor     eax, ecx
        jne     @@1
        mov     Supported, False
@@1:
        pop     ebx
        mov     al, [edx]
end;

function MMXsupport: Boolean;
begin
  if CPUIDSupported then
    asm
        push    ebx
        xor     eax, eax
        DB      $0F, $A2                // cpuid
        cmp     eax, 1
        jl      @@no
        xor     eax, eax
        inc     eax
        DB      $0F, $A2                // cpuid
        test    edx, $800000
        je      @@no
        mov     Result, True
        jmp     @@done
@@no:
        mov     Result, False
@@done:
        pop     ebx
    end
  else
    Result := False;
end;

function GetElapsedMilliSeconds: Integer;
var
  C: Comp;
begin
  if PerformanceCounterAvailable then
  begin
    QueryPerformanceCounter(PLargeInteger(@C)^);
    C := C * 1000 / PerformanceFrequency;
    Result := PInteger(@C)^;
  end
  else
    Result := timeGetTime;
end;

function GetElapsedMicroSeconds: Integer;
var
  C: Comp;
begin
  if PerformanceCounterAvailable then
  begin
    QueryPerformanceCounter(PLargeInteger(@C)^);
    C := C * 1000000 / PerformanceFrequency;
    Result := PInteger(@C)^;
  end
  else
    Result := timeGetTime * 1000;
end;

procedure Register;
begin
  RegisterComponents('GFX Engine', [TDrawPanel, TOpenImageFileDialog]);
end;

initialization
  PerformanceCounterAvailable := QueryPerformanceFrequency(TLargeInteger(PerformanceFrequency));
  AlphaBlendTable := TLookupBlendTableCollection100.Create;
  IntensityBlendTable := TLookupBlendTableCollection100.Create;
  BrightenBlendTable := TLookupBlendTableCollection100.Create;
  ShadowBlendTable := TLookupBlendTableCollection100.Create;
  LinearAlphaBlendTable := TLookupBlendTableCollection100.Create;
  InitBlendTables(5, 31);
  FDirectDrawActivated := False;
  BltProcCount := 0;
  ForcedPixelFormatID := 0;
  ImageFileClassList := TImageFileClassList.Create;
  RegisterImageFileClasses([TBMPImageFile]);
  RegisterBltProc(RegisterBltRect, 'Register Blt');
  if MMXsupport then RegisterBltProc(MMXBltRect, 'MMX Blt');
  RegisterBltProc(RepMovsdBltRect, 'MOVSD Blt');
finalization
  AlphaBlendTable.Free;
  IntensityBlendTable.Free;
  BrightenBlendTable.Free;
  ShadowBlendTable.Free;
  LinearAlphaBlendTable.Free;
  DeactivateDirectDraw;
  ImageFileClassList.Free;
end.
