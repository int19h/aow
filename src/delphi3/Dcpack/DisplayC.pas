unit DisplayC;

{ The DisplayC unit of Dcpack.dpl (the display layer of Age of Wonders: the display control
  TDisplay and the display controllers ("DCs") that put the surfaces of GFXE on the screen, in a
  window through GDI or full screen through DirectDraw, plus the frame update loop) written for
  the original compiler (Delphi 3.02), class by class: tools/match.py compares the code DCC32
  generates for every method with the code in the game's module. Declarations follow the original
  instance layouts and VMT orders (notes/classes.json). The original was
  D:\GEngine\GFXE\DisplayC\DisplayC.pas with inc\TDisplay.PAS included (the Assert in
  TCustomDisplay.CreateWnd names it); TMatrix came from a unit DCTypes (its error message says so)
  but is compiled into this unit: its VMT is the first of the unit and its methods the last.
  TWindows08DIBSurface is declared in the implementation section (its VMT sits between the
  methods of TWindowsDC and TWindows08DC and it is not exported). Two declarations of GFXE.pas
  must be as in the original: the fields of TDDrawSurface protected (TDDrawDCSurface and
  TDDrawFullScr16DC write them) and the surface parameter of IDirectDrawSurface.GetAttachedSurface
  var, not out (the calls do not clear it). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE;

const
  { HResult codes of the display controllers }
  DCERR_NOTSUPPORTED = HResult($80011001);
  DCERR_ACTIVATEFAILED = HResult($80011002);
  DCERR_FAILED = HResult($80011004);
  DCERR_ACTIVATED = HResult($80011005);
  DCERR_NOTACTIVATED = HResult($80011006);
  DCERR_NOFLIP = HResult($80011009);

  { Posted to the display: WParam 1 shows the active DC, 2 activates the primary DC }
  WM_DISPLAYC = $69FF;

  { DirectDraw constants used here (not in GFXE) }
  DDSD_BACKBUFFERCOUNT = $00000020;
  DDSCAPS_BACKBUFFER = $00000004;
  DDSCAPS_COMPLEX = $00000008;
  DDSCAPS_FLIP = $00000010;
  DDSCAPS_3DDEVICE = $00002000;
  DDSCL_FULLSCREEN = $00000001;
  DDSCL_ALLOWREBOOT = $00000002;
  DDSCL_NOWINDOWCHANGES = $00000004;
  DDSCL_EXCLUSIVE = $00000010;
  DDSCL_ALLOWMODEX = $00000040;
  DDWAITVB_BLOCKBEGIN = $00000001;
  DDGFS_CANFLIP = $00000001;

type
  { DisplayC.TMatrix (instance size 12): a byte matrix (the invalidated blocks of a surface).
    +4 FData, +8 FWidth, +9 FHeight. }
  TMatrix = class(TObject)
  private
    FData: PChar;
    FWidth: Byte;
    FHeight: Byte;
  public
    constructor Create(AWidth, AHeight: Byte);
    destructor Destroy; override;
    function GetVal(X, Y: Byte): Integer;
    procedure SetVal(X, Y: Byte; Value: Byte);
    property Width: Byte read FWidth;
    property Height: Byte read FHeight;
  end;

  TDisplayCtrlStatus = set of (dsVisible, dsActivated, dsWindowed);

  TCustomDisplay = class;

  { DisplayC.TAbstractDC (instance size 36): the interface of a display controller; 35 new
    virtual methods, all abstract but GetSurface and BltInvalidatedSurface. }
  TAbstractDC = class(TComponent)
  public
    function GetInvMatrix: TMatrix; virtual; abstract;
    procedure SetPrimarySurfaceRgn(const R: TRect); virtual; abstract;
    function GetPrimarySurfaceRgn: PRect; virtual; abstract;
    function GetStatus: TDisplayCtrlStatus; virtual; abstract;
    function GetDisplay: TCustomDisplay; virtual; abstract;
    function GetPalette: TGFXEPalette; virtual; abstract;
    function GetSurface(Index: Integer): TSurface; virtual;
    function GetSurfaceCount: Integer; virtual; abstract;
    function WndProc(var Message: TMessage): Boolean; virtual; abstract;
    function SupportDisplayMode(ADisplay: TCustomDisplay): HResult; virtual; abstract;
    procedure WindowRecreated; virtual; abstract;
    procedure ShowError(Msg: string); virtual; abstract;
    function GetHPalette: HPALETTE; virtual; abstract;
    function Hide: HResult; virtual; abstract;
    function Show: HResult; virtual; abstract;
    procedure GetPixPosofBlock(BX, BY: Integer; R: TRect; var PX, PY, BW, BH: Integer); virtual; abstract;
    procedure GetBlockPosofPix(PX, PY: Integer; R: TRect; var BX, BY: Integer); virtual; abstract;
    function GetInvBlockSize(X, Y: Integer; Matrix: TMatrix; var BW, BH: Integer): Integer; virtual; abstract;
    procedure NewFrame; virtual; abstract;
    procedure ShowFrameRate; virtual; abstract;
    function Activate(ADisplay: TCustomDisplay): HResult; virtual; abstract;
    function Deactivate: HResult; virtual; abstract;
    function FlipSurface(Index: Integer): HResult; virtual; abstract;
    function BltSurface(Index: Integer): HResult; virtual; abstract;
    function BltInvalidatedSurface(Index: Integer): HResult; virtual;
    function Handle: HWND; virtual; abstract;
    function OutputWnd: TWinControl; virtual; abstract;
    function ResizeBackSurfaces(AWidth, AHeight: Integer): HResult; virtual; abstract;
    procedure GetMousePos(var X, Y: Integer); virtual; abstract;
    function RealizePaletNow: HResult; virtual; abstract;
    function SetPalet(Palette: TGFXEPalette): HResult; virtual; abstract;
    function WaitForVerticalBlank: HResult; virtual; abstract;
    procedure InitInvMatrix(AWidth, AHeight: Byte); virtual; abstract;
    procedure Invalidate(X, Y, W, H: Integer); virtual; abstract;
    procedure InvalidateAll; virtual; abstract;
  end;

  { DisplayC.TDisplayCtrl (instance size 76): the common part of the display controllers. +$24
    FLastFrameTime, +$28 FFrameCount (Word), +$2A FStatus, +$2C FDisplay, +$30
    FPrimarySurfaceRgn (the output rectangle), +$40 FInvMatrix, +$44 FRealizePalet, +$48
    FLastVBTime. }
  TDisplayCtrl = class(TAbstractDC)
  private
    FLastFrameTime: Integer;
    FFrameCount: Word;
    FStatus: TDisplayCtrlStatus;
    FDisplay: TCustomDisplay;
    FPrimarySurfaceRgn: TRect;
    FInvMatrix: TMatrix;
    FRealizePalet: Boolean;
    FLastVBTime: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetInvMatrix: TMatrix; override;
    function GetSurfaceCount: Integer; override;
    function BltSurface(Index: Integer): HResult; override;
    function FlipSurface(Index: Integer): HResult; override;
    function ResizeBackSurfaces(AWidth, AHeight: Integer): HResult; override;
    procedure SetPrimarySurfaceRgn(const R: TRect); override;
    function GetPrimarySurfaceRgn: PRect; override;
    function GetStatus: TDisplayCtrlStatus; override;
    function GetHPalette: HPALETTE; override;
    function WndProc(var Message: TMessage): Boolean; override;
    function GetDisplay: TCustomDisplay; override;
    function OutputWnd: TWinControl; override;
    procedure WindowRecreated; override;
    function Handle: HWND; override;
    procedure ShowError(Msg: string); override;
    function Activate(ADisplay: TCustomDisplay): HResult; override;
    function Deactivate: HResult; override;
    function SupportDisplayMode(ADisplay: TCustomDisplay): HResult; override;
    function SetPalet(Palette: TGFXEPalette): HResult; override;
    procedure RealizePalet;
    function RealizePaletNow: HResult; override;
    procedure GetMousePos(var X, Y: Integer); override;
    function Hide: HResult; override;
    function Show: HResult; override;
    function GetPalette: TGFXEPalette; override;
    function WaitForVerticalBlank: HResult; override;
    procedure InitInvMatrix(AWidth, AHeight: Byte); override;
    procedure InvalidateAll; override;
    function GetInvBlockSize(X, Y: Integer; Matrix: TMatrix; var BW, BH: Integer): Integer; override;
    procedure GetPixPosofBlock(BX, BY: Integer; R: TRect; var PX, PY, BW, BH: Integer); override;
    procedure GetBlockPosofPix(PX, PY: Integer; R: TRect; var BX, BY: Integer); override;
    procedure InvWndwithValue(X, Y, W, H: Integer; Value: Byte);
    procedure Invalidate(X, Y, W, H: Integer); override;
    function GetCurrentFrameRate: Integer;
    procedure NewFrame; override;
    procedure ShowFrameRate; override;
  end;

  { DisplayC.TDDrawFSWinControl (instance size 284): the full screen window of the DirectDraw
    controllers; passes the mouse and key events on to its display. +$118 FDisplay. }
  TDDrawFSWinControl = class(TWinControl)
  private
    FDisplay: TCustomDisplay;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure Click; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TActivatedDCType = (dtPrimaryDC, dtSecondaryDC, dtUserDC);
  TBackSurfaceControlMode = (bmBltSurface, bmBltInvalidatedSurface, bmPageFlipping, bmNone);
  TUpdateFrameEvent = procedure(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer) of object;
  TDCNotifyEvent = procedure(Sender: TObject; DC: TAbstractDC) of object;
  TDisplayStatus = set of (dsFrameLoopActive, dsDDrawEnabled, dsDirectInputEnabled, dsAsynchrone,
    dsExclusiveAccess, dsFrameLoopPaused);
  TDisplayOptions = set of (doAutoResizeBackSurface, doAutoSwapDC, doAutoStartUpdateFrameLoop,
    doAutoActivatePrimaryDC, doShowFrameRate, doShowErrors, doFocusAble, doRestoreSurfacesOnSwap,
    doBltOnWMPAINT, doAutoEnableDDraw);
  TBufferingScheme = (bsSingle, bsDouble, bsTripple);
  TErrorEvent = procedure(ErrorStr: string; Error: Integer) of object;
  TSurfaceDataLostEvent = procedure(DC: TAbstractDC; SurfaceType: Integer) of object;
  TUpdateFrameMode = (umAsynchrone, umSynchrone);
  TResizeBackSurfaceEvent = procedure(DC: TAbstractDC; Width, Height: Integer) of object;
  TSwapDCEvent = procedure(DC: TAbstractDC) of object;

  TUpdateFrameThread = class;

  { DisplayC.TCustomDisplay (instance size 428): the display control. +$118 FFSWinControl, the
    events (+$11C OnBltSurface, +$124 OnUpdateFrame, +$12C OnSurfaceDataLost, +$134 OnResize,
    +$13C OnError, +$144 OnActivateDC, +$14C OnDeactivateDC, +$154 OnHide, +$15C OnShow, +$164
    OnResizeBackSurface, +$16C OnSwapDC), +$174 FFrameRate, +$178 FFrameTime (ms per frame),
    +$17C FCurrentFrameRate, +$180 FUpdateFrameThread, +$184 FStatus, +$185 FOptions (2 bytes),
    +$187 FUpdateFrameMode, +$188 FBackSurfaceControlMode, +$189 FBufferingScheme, +$18C
    FBackSurfaceWidth, +$190 FBackSurfaceHeight, +$194 FSurfaceIndex (the back surface to
    show), +$198 FPauseCount, +$19C FMouseAboveSurface, +$1A0 FPrimaryDC, +$1A4 FSecondaryDC,
    +$1A8 FActiveDC. }
  TCustomDisplay = class(TWinControl)
  private
    FFSWinControl: TDDrawFSWinControl;
    FOnBltSurface: TNotifyEvent;
    FOnUpdateFrame: TUpdateFrameEvent;
    FOnSurfaceDataLost: TSurfaceDataLostEvent;
    FOnResize: TNotifyEvent;
    FOnError: TErrorEvent;
    FOnActivateDC: TDCNotifyEvent;
    FOnDeactivateDC: TDCNotifyEvent;
    FOnHide: TNotifyEvent;
    FOnShow: TNotifyEvent;
    FOnResizeBackSurface: TResizeBackSurfaceEvent;
    FOnSwapDC: TSwapDCEvent;
    FFrameRate: Integer;
    FFrameTime: Integer;
  protected FCurrentFrameRate: Integer; private { HSMEdit uses it; one line keeps the Assert below on 1350 }
    FUpdateFrameThread: TUpdateFrameThread;
    FStatus: TDisplayStatus;
    FOptions: TDisplayOptions;
    FUpdateFrameMode: TUpdateFrameMode;
    FBackSurfaceControlMode: TBackSurfaceControlMode;
    FBufferingScheme: TBufferingScheme;
    FBackSurfaceWidth: Integer;
    FBackSurfaceHeight: Integer;
  protected FSurfaceIndex: Integer; private { HSMEdit uses it }
    FPauseCount: Integer;
    FMouseAboveSurface: Boolean;
    FPrimaryDC: TAbstractDC;
    FSecondaryDC: TAbstractDC;
    FActiveDC: TAbstractDC;
    procedure SetCursor(Value: TCursor);
    function GetCursor: TCursor;
    procedure SetBufferingScheme(Value: TBufferingScheme);
    procedure SetUpdateFrameMode(Value: TUpdateFrameMode);
    procedure SetBackSurfaceWidth(Value: Integer);
    procedure SetBackSurfaceHeight(Value: Integer);
    procedure CMWantSpecialKey(var Message: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
    procedure CMKeyUP(var Message: TWMKeyUp); message CN_KEYUP;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function GetPalette: HPALETTE; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDC(Index: Integer): TAbstractDC; virtual;
    procedure Resize; virtual;
    procedure SetFrameRate(Value: Integer); virtual;
    procedure ShowError(Msg: string); virtual;
    procedure StopUpdateFrameLoop; virtual;
    procedure PauseFrameUpdateLoop; virtual;
    procedure ResumeFrameUpdateLoop; virtual;
    procedure StartUpdateFrameLoop; virtual;
    procedure ResizeBackSurfaces(AWidth, AHeight: Integer); virtual;
    procedure SurfaceDataLost(SurfaceType: Integer); virtual;
    function GetMouseButton: Integer; virtual;
    procedure GetMousePos(var X, Y: Integer); virtual;
    procedure UpdateFrame; virtual;
    function SwapDC: HResult; virtual;
    function ExecuteBltSurfaceEvent: HResult; virtual;
    function GetMouseAboveSurface: Boolean;
    procedure Hide;
    procedure Show;
    function SupportDC(DC: TAbstractDC): HResult;
    function ActivateDC(DC: TAbstractDC): HResult;
    function DeactivateDC: HResult;
    property Cursor: TCursor read GetCursor write SetCursor;
    property ActiveDC: TAbstractDC read FActiveDC;
    property FSWinControl: TDDrawFSWinControl read FFSWinControl;
  protected
    property Options: TDisplayOptions read FOptions write FOptions;
    property BufferingScheme: TBufferingScheme read FBufferingScheme write SetBufferingScheme;
    property BackSurfaceControlMode: TBackSurfaceControlMode read FBackSurfaceControlMode write FBackSurfaceControlMode;
    property BackSurfaceWidth: Integer read FBackSurfaceWidth write SetBackSurfaceWidth;
    property BackSurfaceHeight: Integer read FBackSurfaceHeight write SetBackSurfaceHeight;
    property FrameRate: Integer read FFrameRate write SetFrameRate;
    property PrimaryDC: TAbstractDC read FPrimaryDC write FPrimaryDC;
    property SecondaryDC: TAbstractDC read FSecondaryDC write FSecondaryDC;
    property UpdateFrameMode: TUpdateFrameMode read FUpdateFrameMode write SetUpdateFrameMode;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
    property OnBltSurface: TNotifyEvent read FOnBltSurface write FOnBltSurface;
    property OnDeactivateDC: TDCNotifyEvent read FOnDeactivateDC write FOnDeactivateDC;
    property OnActivateDC: TDCNotifyEvent read FOnActivateDC write FOnActivateDC;
    property OnUpdateFrame: TUpdateFrameEvent read FOnUpdateFrame write FOnUpdateFrame;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnError: TErrorEvent read FOnError write FOnError;
    property OnSurfaceDataLost: TSurfaceDataLostEvent read FOnSurfaceDataLost write FOnSurfaceDataLost;
    property OnResizeBackSurface: TResizeBackSurfaceEvent read FOnResizeBackSurface write FOnResizeBackSurface;
    property OnSwapDC: TSwapDCEvent read FOnSwapDC write FOnSwapDC;
  end;

  { DisplayC.TDisplay (instance size 428): TCustomDisplay with its properties published. }
  TDisplay = class(TCustomDisplay)
  published
    property Align;
    property Color;
    property Enabled;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnDblClick;
    property Options;
    property BufferingScheme;
    property BackSurfaceControlMode;
    property BackSurfaceWidth;
    property BackSurfaceHeight;
    property FrameRate;
    property PrimaryDC;
    property SecondaryDC;
    property UpdateFrameMode;
    property OnResize;
    property OnBltSurface;
    property OnDeactivateDC;
    property OnActivateDC;
    property OnUpdateFrame;
    property OnHide;
    property OnShow;
    property OnError;
    property OnSurfaceDataLost;
    property OnResizeBackSurface;
    property OnSwapDC;
  end;

  { DisplayC.TUpdateFrameThread (instance size 52): the asynchronous frame loop; calls
    TCustomDisplay.UpdateFrame through Synchronize at the frame rate. +$28 FDisplay, +$2C FBusy,
    +$30 FLastTime. }
  TUpdateFrameThread = class(TThread)
  private
    FDisplay: TCustomDisplay;
    FBusy: Boolean;
    FLastTime: Integer;
    procedure TriggerUpdateFrame;
  protected
    procedure Execute; override;
  public
    constructor Create(ADisplay: TCustomDisplay);
  end;

  { DisplayC.TDisplayGDISurface (instance size 12): a TGDISurface on the window of a control,
    taking the handle from the control. +8 FControl. }
  TDisplayGDISurface = class(TGDISurface)
  private
    FControl: TWinControl;
  public
    constructor Create(AControl: TWinControl);
    function GetHandle: HWND; override;
  end;

  { DisplayC.TWindowsDC (instance size 88): the windowed controllers (GDI). +$4C FDC, +$50 FWnd,
    +$54 FGDISurface (the window, surface 0). }
  TWindowsDC = class(TDisplayCtrl)
  private
    FDC: HDC;
    FWnd: HWND;
    FGDISurface: TDisplayGDISurface;
  public
    constructor Create(AOwner: TComponent); override;
    function Activate(ADisplay: TCustomDisplay): HResult; override;
    function Deactivate: HResult; override;
    procedure WindowRecreated; override;
    function SupportDisplayMode(ADisplay: TCustomDisplay): HResult; override;
    function BltSurface(Index: Integer): HResult; override;
    function FlipSurface(Index: Integer): HResult; override;
    function GetInvBlockSize(X, Y: Integer; Matrix: TMatrix; var BW, BH: Integer): Integer; override;
    procedure ShowFrameRate; override;
  end;

  { DisplayC.TWindows08DC (instance size 1172): 8 bit back surfaces drawn with StretchDIBits
    through a palette. +$58 FBack1, +$5C FBack2 (TWindows08DIBSurface, declared in the
    implementation), +$60 FPalette, +$64 FBitmapInfo (header and
    256 colors), +$48C FHPalette, +$490 FOldPalette. }
  TWindows08DC = class(TWindowsDC)
  private
    FBack1: TSurface;
    FBack2: TSurface;
    FPalette: TGFXEPalette;
    FBitmapInfo: TBitmapInfoHeader;
    FColors: array[0..255] of TRGBQuad;
    FHPalette: HPALETTE;
    FOldPalette: HPALETTE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetPalette: TGFXEPalette; override;
    function GetHPalette: HPALETTE; override;
    function GetSurface(Index: Integer): TSurface; override;
    function Deactivate: HResult; override;
    function Activate(ADisplay: TCustomDisplay): HResult; override;
    procedure CreateHPalette;
    procedure ReleaseHPalette;
    procedure WindowRecreated; override;
    procedure UpdatePalette;
  end;

  TWin16DCPixelFormat = (pfAuto, pf555, pf565);

  { DisplayC.TWindows16DC (instance size 100): 16 bit DIB back surfaces. +$58 FPixelFormat,
    +$5C FBack1, +$60 FBack2. }
  TWindows16DC = class(TWindowsDC)
  private
    FPixelFormat: TWin16DCPixelFormat;
    FBack1: TDIB16Surface;
    FBack2: TDIB16Surface;
    procedure SetPixelFormat(Value: TWin16DCPixelFormat);
  public
    constructor Create(AOwner: TComponent); override;
    function GetSurface(Index: Integer): TSurface; override;
    function Deactivate: HResult; override;
    function Activate(ADisplay: TCustomDisplay): HResult; override;
  published
    property PixelFormat: TWin16DCPixelFormat read FPixelFormat write SetPixelFormat;
  end;

  { DisplayC.TWindows24DC (instance size 96): 24 bit DIB back surfaces. +$58 FBack1, +$5C
    FBack2. }
  TWindows24DC = class(TWindowsDC)
  private
    FBack1: TDIB24Surface;
    FBack2: TDIB24Surface;
  public
    function GetSurface(Index: Integer): TSurface; override;
    function Deactivate: HResult; override;
    function Activate(ADisplay: TCustomDisplay): HResult; override;
  end;

  { DisplayC.TWindows32DC (instance size 96): 32 bit back surfaces. +$58 FBack1, +$5C FBack2. }
  TWindows32DC = class(TWindowsDC)
  private
    FBack1: TDIB32Surface;
    FBack2: TDIB32Surface;
  public
    function GetSurface(Index: Integer): TSurface; override;
    function Deactivate: HResult; override;
    function Activate(ADisplay: TCustomDisplay): HResult; override;
  end;

  { DisplayC.TDDrawDCSurface (instance size 100): a TDDrawSurface around a surface that
    DirectDraw created elsewhere (the primary surface and its attached back buffers). }
  TDDrawDCSurface = class(TDDrawSurface)
  public
    function SetDDSurface(ASurface: IDirectDrawSurface; AStatus: TDDrawSurfaceStatus): HResult;
  end;

  { DisplayC.TDDrawDC (instance size 92): the DirectDraw controllers. +$4C FPrimary, +$50
    FBack1, +$54 FBack2, +$58 FUseVideoMemory, +$59 FUseVerticalBlank, +$5A FDebugMode. }
  TDDrawDC = class(TDisplayCtrl)
  private
    FPrimary: TDDrawDCSurface;
    FBack1: TDDrawDCSurface;
    FBack2: TDDrawDCSurface;
    FUseVideoMemory: Boolean;
    FUseVerticalBlank: Boolean;
    FDebugMode: Boolean;
  public
    procedure SurfaceLost(Sender: TObject);
    function VerifyLostSurfaces: HResult;
    function FlipSurface(Index: Integer): HResult; override;
    function BltSurface(Index: Integer): HResult; override;
    function GetSurface(Index: Integer): TSurface; override;
    function WaitForVerticalBlank: HResult; override;
    procedure ShowFrameRate; override;
    function Deactivate: HResult; override;
  published
    property UseVideoMemory: Boolean read FUseVideoMemory write FUseVideoMemory;
    property UseVerticalBlank: Boolean read FUseVerticalBlank write FUseVerticalBlank;
    property DebugMode: Boolean read FDebugMode write FDebugMode;
  end;

  { DisplayC.TDDrawFullScrDC (instance size 112): full screen through DirectDraw, in the window
    of the display's TDDrawFSWinControl. +$5C FHooked (the main window hook), +$60
    FDisplayWidth, +$64 FDisplayHeight, +$68 FBitDepth, +$6C FEnable3D, +$6D FSwitching. One
    more virtual: CreateSurfaces. }
  TDDrawFullScrDC = class(TDDrawDC)
  private
    FHooked: Boolean;
    FDisplayWidth: Integer;
    FDisplayHeight: Integer;
    FBitDepth: Integer;
    FEnable3D: Boolean;
    FSwitching: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function MainWindowHook(var Message: TMessage): Boolean;
    procedure HookMainWindow;
    procedure UnHookMainWindow;
    function SwitchResolution(AWidth, AHeight: Integer): HResult;
    procedure HideApplicationForms;
    procedure ShowApplicationForms;
    function OutputWnd: TWinControl; override;
    function Handle: HWND; override;
    procedure GetMousePos(var X, Y: Integer); override;
    function SetDisplayMode(AWidth, AHeight, ABitDepth: Integer): HResult;
    function FlipSurface(Index: Integer): HResult; override;
    function CreateSurfaces: HResult; virtual;
    function ResizeBackSurfaces(AWidth, AHeight: Integer): HResult; override;
    function Hide: HResult; override;
    function Show: HResult; override;
    function Activate(ADisplay: TCustomDisplay): HResult; override;
    function Deactivate: HResult; override;
  published
    property DisplayWidth: Integer read FDisplayWidth write FDisplayWidth;
    property DisplayHeight: Integer read FDisplayHeight write FDisplayHeight;
    property Enable3D: Boolean read FEnable3D write FEnable3D;
  end;

  { DisplayC.TDDrawFullScr16DC (instance size 112): 16 bit full screen. }
  TDDrawFullScr16DC = class(TDDrawFullScrDC)
  public
    constructor Create(AOwner: TComponent); override;
    function CreateSurfaces: HResult; override;
  end;

  { DisplayC.TDDrawFullScr24DC (instance size 112): 24 bit full screen. }
  TDDrawFullScr24DC = class(TDDrawFullScrDC)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { DisplayC.TDDrawFullScr32DC (instance size 112): 32 bit full screen. }
  TDDrawFullScr32DC = class(TDDrawFullScrDC)
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure Register;

implementation

{ TAbstractDC }

function TAbstractDC.GetSurface(Index: Integer): TSurface;
begin
  Result := nil;
end;

{ Blits the invalidated blocks of back surface Index to the primary surface: every block the
  matrix marks is merged with its marked neighbours (GetInvBlockSize) into one rectangle, and
  the marks count down, so a block is blitted once per back surface. }
function TAbstractDC.BltInvalidatedSurface(Index: Integer): HResult;
var
  M: TMatrix;
  BW, BH: Integer;
  X: Integer;
  PX2, PY2, BlkW, BlkH: Integer;
  I, J, Y: Integer;
  V: Integer;
  ClipR, SrcR, DstR: TRect;
begin
  if GetInvMatrix <> nil then
  begin
    Result := 0;
    M := TMatrix.Create(GetInvMatrix.Width, GetInvMatrix.Height);
    for I := 0 to GetInvMatrix.Width - 1 do
      for J := 0 to GetInvMatrix.Height - 1 do
        if GetInvMatrix.GetVal(I, J) <> 0 then
          M.SetVal(I, J, 1);
    ClipR.Left := 0;
    ClipR.Right := GetSurface(1).Width;
    ClipR.Top := 0;
    ClipR.Bottom := GetSurface(1).Height;
    for J := 0 to M.Height - 1 do
      for I := 0 to M.Width - 1 do
        if Result >= 0 then
        begin
          V := GetInvMatrix.GetVal(I, J);
          if V <> 0 then
            GetInvMatrix.SetVal(I, J, V - 1);
          if M.GetVal(I, J) <> 0 then
          begin
            GetInvBlockSize(I, J, M, BW, BH);
            GetPixPosofBlock(I, J, ClipR, SrcR.Left, SrcR.Top, BlkW, BlkH);
            if (BW > 1) or (BH > 1) then
            begin
              GetPixPosofBlock(I + BW - 1, J + BH - 1, ClipR, PX2, PY2, BlkW, BlkH);
              SrcR.Right := PX2 + BlkW;
              SrcR.Bottom := PY2 + BlkH;
            end
            else
            begin
              SrcR.Right := SrcR.Left + BlkW;
              SrcR.Bottom := SrcR.Top + BlkH;
            end;
            GetPixPosofBlock(I, J, GetPrimarySurfaceRgn^, DstR.Left, DstR.Top, BlkW, BlkH);
            Inc(DstR.Left, GetPrimarySurfaceRgn^.Left);
            Inc(DstR.Top, GetPrimarySurfaceRgn^.Top);
            if (BW > 1) or (BH > 1) then
            begin
              GetPixPosofBlock(I + BW - 1, J + BH - 1, GetPrimarySurfaceRgn^, PX2, PY2, BlkW, BlkH);
              DstR.Right := PX2 + BlkW + GetPrimarySurfaceRgn^.Left;
              DstR.Bottom := PY2 + BlkH + GetPrimarySurfaceRgn^.Top;
            end
            else
            begin
              DstR.Right := DstR.Left + BlkW;
              DstR.Bottom := DstR.Top + BlkH;
            end;
            Result := GetSurface(Index).BltStretch(GetSurface(0), @SrcR, @DstR);
            for X := 0 to BW - 1 do
              for Y := 0 to BH - 1 do
                M.SetVal(I + X, J + Y, 0);
          end;
        end;
    M.Destroy;
  end
  else
    Result := DCERR_FAILED;
end;

{ TDisplayCtrl }

function TDisplayCtrl.GetInvMatrix: TMatrix;
begin
  Result := FInvMatrix;
end;

function TDisplayCtrl.GetSurfaceCount: Integer;
begin
  if GetDisplay = nil then
    Result := 0
  else
    Result := Ord(GetDisplay.FBufferingScheme);
end;

function TDisplayCtrl.BltSurface(Index: Integer): HResult;
begin
  Result := GetSurface(Index).BltStretch(GetSurface(0), nil, GetPrimarySurfaceRgn);
end;

function TDisplayCtrl.FlipSurface(Index: Integer): HResult;
begin
  Result := GetSurface(Index).BltStretch(GetSurface(0), nil, GetPrimarySurfaceRgn);
  if Succeeded(Result) then
    Result := DCERR_NOFLIP;
end;

{ Bug kept from the original: the result of Resize is ignored, so Result stays 0. }
function TDisplayCtrl.ResizeBackSurfaces(AWidth, AHeight: Integer): HResult;
var
  I: Integer;
begin
  Result := 0;
  InvalidateAll;
  for I := 1 to Ord(GetDisplay.FBufferingScheme) do
    if Result >= 0 then
      if (GetSurface(I).Width <> AWidth) or (GetSurface(I).Height <> AHeight) then
      begin
        GetSurface(I).Resize(AWidth, AHeight);
        GetSurface(I).Cls(GetDisplay.Color);
      end;
end;

procedure TDisplayCtrl.SetPrimarySurfaceRgn(const R: TRect);
begin
  FPrimarySurfaceRgn := R;
end;

function TDisplayCtrl.GetPrimarySurfaceRgn: PRect;
begin
  Result := @FPrimarySurfaceRgn;
end;

function TDisplayCtrl.GetStatus: TDisplayCtrlStatus;
begin
  Result := FStatus;
end;

function TDisplayCtrl.GetHPalette: HPALETTE;
begin
  Result := 0;
end;

function TDisplayCtrl.WndProc(var Message: TMessage): Boolean;
begin
  Result := True;
  if Message.Msg = WM_NCPAINT then
  begin
    Result := False;
    Message.Result := 0;
  end;
  if Message.Msg = WM_ERASEBKGND then
  begin
    Result := False;
    Message.Result := 1;
  end;
end;

function TDisplayCtrl.GetDisplay: TCustomDisplay;
begin
  Result := FDisplay;
end;

function TDisplayCtrl.OutputWnd: TWinControl;
begin
  Result := GetDisplay;
end;

procedure TDisplayCtrl.WindowRecreated;
begin
end;

function TDisplayCtrl.Handle: HWND;
begin
  Result := FDisplay.Handle;
end;

procedure TDisplayCtrl.ShowError(Msg: string);
begin
  FDisplay.ShowError(Msg);
end;

function TDisplayCtrl.Activate(ADisplay: TCustomDisplay): HResult;
begin
  if not (dsActivated in FStatus) then
  begin
    FDisplay := ADisplay;
    FStatus := FStatus + [dsActivated];
    FDisplay.FCurrentFrameRate := FDisplay.FFrameRate;
    InvalidateAll;
    Result := 0;
  end
  else
    Result := DCERR_ACTIVATED;
end;

function TDisplayCtrl.Deactivate: HResult;
begin
  if dsActivated in FStatus then
  begin
    FStatus := FStatus - [dsActivated];
    if FDisplay <> nil then
      FDisplay.DeactivateDC;
    Result := 0;
    FDisplay := nil;
  end
  else
    Result := DCERR_NOTACTIVATED;
end;

function TDisplayCtrl.SupportDisplayMode(ADisplay: TCustomDisplay): HResult;
begin
  Result := DCERR_NOTSUPPORTED;
end;

function TDisplayCtrl.SetPalet(Palette: TGFXEPalette): HResult;
begin
  Result := DCERR_NOTSUPPORTED;
end;

procedure TDisplayCtrl.RealizePalet;
begin
  if dsFrameLoopActive in FDisplay.FStatus then
    FRealizePalet := True
  else
    RealizePaletNow;
end;

function TDisplayCtrl.RealizePaletNow: HResult;
begin
  Result := DCERR_NOTSUPPORTED;
end;

{ The mouse position in the display, or -1, -1 when the mouse is outside or another window has
  captured it. }
procedure TDisplayCtrl.GetMousePos(var X, Y: Integer);
var
  H: HWND;
  Parent: TWinControl;
  MaxX, MaxY: Integer;
  P: TPoint;
  OX, OY: Integer;
  Inside: Boolean;
begin
  H := GetCapture;
  if (H = 0) or (H = FDisplay.Handle) then
  begin
    Parent := FDisplay.Parent;
    GetCursorPos(P);
    MaxX := FDisplay.ClientRect.Right + FDisplay.Left;
    MaxY := FDisplay.ClientRect.Bottom + FDisplay.Top;
    if Parent.ClientRect.Right < MaxX then
      MaxX := Parent.ClientRect.Right;
    if Parent.ClientRect.Bottom < MaxY then
      MaxY := Parent.ClientRect.Bottom;
    OX := FDisplay.ClientOrigin.X - FDisplay.Left;
    OY := FDisplay.ClientOrigin.Y - FDisplay.Top;
    X := P.X - OX;
    Y := P.Y - OY;
    Inside := (X >= 0) and (X <= MaxX) and (Y >= 0) and (Y <= MaxY);
    if not Inside then
    begin
      X := -1;
      Y := -1;
    end
    else
    begin
      Dec(X, FDisplay.Left);
      Dec(Y, FDisplay.Top);
    end;
  end
  else
  begin
    X := -1;
    Y := -1;
  end;
end;

function TDisplayCtrl.Hide: HResult;
begin
  FStatus := FStatus - [dsVisible];
  Result := 0;
end;

function TDisplayCtrl.Show: HResult;
begin
  FStatus := FStatus + [dsVisible];
  Result := 0;
end;

function TDisplayCtrl.GetPalette: TGFXEPalette;
begin
  Result := nil;
end;

{ Waits until the frame time (FDisplay.FFrameTime ms) has passed since the last call. }
function TDisplayCtrl.WaitForVerticalBlank: HResult;
var
  Wait, Target, T, D: Integer;
begin
  Wait := FDisplay.FFrameTime;
  if Wait <> 0 then
  begin
    Target := FLastVBTime + Wait;
    T := GetElapsedMilliSeconds;
    if T >= Target - Wait then
    begin
      D := Target - T;
      while D > 0 do
      begin
        if D > 5 then
          Sleep(0);
        T := GetElapsedMilliSeconds;
        D := Target - T;
      end;
    end;
    FLastVBTime := T;
  end;
  Result := 0;
end;

procedure TDisplayCtrl.InitInvMatrix(AWidth, AHeight: Byte);
begin
  if FInvMatrix <> nil then
    FInvMatrix.Destroy;
  FInvMatrix := TMatrix.Create(AWidth, AHeight);
end;

procedure TDisplayCtrl.InvalidateAll;
var
  I, J: Integer;
begin
  if FInvMatrix <> nil then
    with FInvMatrix do
      for I := 0 to Width - 1 do
        for J := 0 to Height - 1 do
          SetVal(I, J, 1);
end;

{ The size of the largest rectangle of marked blocks with its top left corner at X, Y, grown
  first downwards (rows of shrinking width) and then to the right (columns of shrinking
  height); BW and BH get its size in blocks, the result is its area. }
function TDisplayCtrl.GetInvBlockSize(X, Y: Integer; Matrix: TMatrix; var BW, BH: Integer): Integer;
var
  Size1, Size2, W1, H2, W2, H1: Integer;
  P: PChar;
  Q: PChar;
  N, L, Off: Integer;
  Ok: Boolean;
begin
  P := Matrix.FData + X + Matrix.FWidth * Y;
  if P^ <> #0 then
  begin
    H1 := 0;
    Q := P;
    W1 := Matrix.FWidth - X;
    Size1 := 0;
    repeat
      N := W1;
      L := 0;
      while (N <> 0) and ((Q + L)^ <> #0) do
      begin
        Inc(L);
        Dec(N);
      end;
      Ok := L * H1 >= Size1;
      if Ok then
      begin
        Inc(H1);
        Q := Q + Matrix.FWidth;
        W1 := L;
        Size1 := H1 * L;
      end;
    until not Ok or (H1 + Y = Matrix.FHeight);
    BH := H1;
    BW := W1;
    W2 := 0;
    Q := P;
    H2 := Matrix.FHeight - Y;
    Size2 := 0;
    repeat
      N := H2;
      L := 0;
      Off := 0;
      while (N <> 0) and ((Q + Off)^ <> #0) do
      begin
        Inc(L);
        Dec(N);
        Inc(Off, Matrix.FWidth);
      end;
      Ok := L * W2 >= Size2;
      if Ok then
      begin
        Inc(Q);
        Inc(W2);
        H2 := L;
        Size2 := W2 * H2;
      end;
    until not Ok or (W2 + X = Matrix.FWidth);
    if Size2 > Size1 then
    begin
      BW := W2;
      BH := H2;
      Result := Size2;
    end
    else
      Result := Size1;
  end
  else
    Result := 0;
end;

procedure TDisplayCtrl.GetPixPosofBlock(BX, BY: Integer; R: TRect; var PX, PY, BW, BH: Integer);
var
  W, H: Integer;
begin
  W := (R.Right - R.Left + FInvMatrix.FWidth - 1) div FInvMatrix.FWidth;
  H := (R.Bottom - R.Top + FInvMatrix.FHeight - 1) div FInvMatrix.FHeight;
  PX := W * BX;
  PY := H * BY;
  BW := W;
  BH := H;
end;

procedure TDisplayCtrl.GetBlockPosofPix(PX, PY: Integer; R: TRect; var BX, BY: Integer);
var
  W, H: Integer;
begin
  W := (R.Right - R.Left + 1 + FInvMatrix.FWidth - 1) div FInvMatrix.FWidth;
  H := (R.Bottom - R.Top + 1 + FInvMatrix.FHeight - 1) div FInvMatrix.FHeight;
  BX := (PX - R.Left) div W;
  BY := (PY - R.Top) div H;
end;

{ Marks the blocks of the pixel rectangle X, Y, W, H with Value. Bug kept from the original:
  the range test checks BY2 >= 0 where BX2 >= 0 was meant (and BY1 twice). }
procedure TDisplayCtrl.InvWndwithValue(X, Y, W, H: Integer; Value: Byte);
var
  BX1, BX2, BY1, BY2: Integer;
  M: TMatrix;
  R: TRect;
begin
  if FInvMatrix <> nil then
  begin
    M := FInvMatrix;
    R.Left := 0;
    R.Right := GetSurface(1).Width;
    R.Top := 0;
    R.Bottom := GetSurface(1).Height;
    GetBlockPosofPix(X, Y, R, BX1, BY1);
    GetBlockPosofPix(X + W, Y + H, R, BX2, BY2);
    if (M.FWidth > BX1) and (M.FHeight > BY1) and (BY2 >= 0) and (BY1 >= 0) then
    begin
      if BX1 < 0 then
        BX1 := 0;
      if BY1 < 0 then
        BY1 := 0;
      if M.FWidth <= BX2 then
        BX2 := M.FWidth - 1;
      if M.FHeight <= BY2 then
        BY2 := M.FHeight - 1;
      for X := BX1 to BX2 do
        for Y := BY1 to BY2 do
          M.SetVal(X, Y, Value);
    end;
  end;
end;

procedure TDisplayCtrl.Invalidate(X, Y, W, H: Integer);
begin
  InvWndwithValue(X, Y, W, H, 1);
end;

constructor TDisplayCtrl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInvMatrix := TMatrix.Create(4, 4);
end;

destructor TDisplayCtrl.Destroy;
begin
  if dsActivated in FStatus then
    Deactivate;
  if FInvMatrix <> nil then
  begin
    FInvMatrix.Destroy;
    FInvMatrix := nil;
  end;
  inherited Destroy;
end;

function TDisplayCtrl.GetCurrentFrameRate: Integer;
begin
  Result := FDisplay.FCurrentFrameRate;
end;

{ Counts frames; every 5 frames the frame rate is measured. }
procedure TDisplayCtrl.NewFrame;
var
  T: Integer;
begin
  if FFrameCount >= 5 then
  begin
    T := GetElapsedMilliSeconds;
    FDisplay.FCurrentFrameRate := Round(5000 / (T - FLastFrameTime + 1));
    FFrameCount := 0;
    FLastFrameTime := T;
  end;
  Inc(FFrameCount);
end;

procedure TDisplayCtrl.ShowFrameRate;
begin
end;

{ TUpdateFrameThread }

procedure TUpdateFrameThread.TriggerUpdateFrame;
begin
  if not Terminated then
    with FDisplay do
      if not (dsFrameLoopPaused in FStatus) and not (csDestroying in ComponentState) and
        (FActiveDC <> nil) then
        UpdateFrame;
end;

procedure TUpdateFrameThread.Execute;
var
  D: TCustomDisplay;
  T, Wait, Rest: Integer;
begin
  D := FDisplay;
  while not Terminated and (dsFrameLoopActive in D.FStatus) do
  begin
    FBusy := True;
    T := GetElapsedMilliSeconds;
    if D.FFrameTime > 2 then
      Wait := D.FFrameTime - 2
    else
      Wait := 0;
    while (T < FLastTime) or (T < FLastTime + Wait) do
    begin
      Rest := FLastTime + Wait - T;
      if Rest > 5 then
        Sleep(0);
      T := GetElapsedMilliSeconds;
    end;
    FLastTime := T;
    Synchronize(TriggerUpdateFrame);
    FBusy := False;
  end;
end;

constructor TUpdateFrameThread.Create(ADisplay: TCustomDisplay);
begin
  FDisplay := ADisplay;
  inherited Create(False);
  FreeOnTerminate := True;
end;

{ TDDrawFSWinControl }

constructor TDDrawFSWinControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ShowWindow(Handle, CmdShow);
  Brush.Color := clBlack;
end;

destructor TDDrawFSWinControl.Destroy;
begin
  if (FDisplay <> nil) and (FDisplay.FActiveDC <> nil) and (FDisplay.FActiveDC.Handle = Handle) then
    FDisplay.FActiveDC.Deactivate;
  inherited Destroy;
  FDisplay := nil;
end;

procedure TDDrawFSWinControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDisplay.MouseDown(Button, Shift, X, Y);
end;

procedure TDDrawFSWinControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FDisplay.MouseMove(Shift, X, Y);
end;

procedure TDDrawFSWinControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDisplay.MouseUp(Button, Shift, X, Y);
end;

procedure TDDrawFSWinControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FDisplay.KeyDown(Key, Shift);
end;

procedure TDDrawFSWinControl.KeyUp(var Key: Word; Shift: TShiftState);
begin
  FDisplay.KeyUp(Key, Shift);
end;

procedure TDDrawFSWinControl.KeyPress(var Key: Char);
begin
  FDisplay.KeyPress(Key);
end;

procedure TDDrawFSWinControl.DblClick;
begin
  FDisplay.DblClick;
end;

procedure TDDrawFSWinControl.Click;
begin
  FDisplay.Click;
end;

procedure TDDrawFSWinControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Caption := '';
  Params.Style := Integer(WS_POPUP);
  Params.ExStyle := WS_EX_TOPMOST;
  Params.WndParent := Application.Handle;
  Params.WindowClass.hbrBackground := GetStockObject(NULL_BRUSH);
  Params.WindowClass.style := CS_VREDRAW or CS_HREDRAW or CS_DBLCLKS;
end;

procedure TDDrawFSWinControl.WndProc(var Message: TMessage);
begin
  if not (csDestroying in ComponentState) then
  begin
    if (Message.Msg = WM_KILLFOCUS) and (FDisplay <> nil) and (FDisplay.FActiveDC <> nil) and
      not (dsWindowed in FDisplay.FActiveDC.GetStatus) and (dsVisible in FDisplay.FActiveDC.GetStatus) and
      Application.Active then
      Windows.SetFocus(Handle);
    if (Message.Msg = WM_PAINT) and (FDisplay <> nil) and (FDisplay.FActiveDC <> nil) and
      not (dsWindowed in FDisplay.FActiveDC.GetStatus) then
    begin
      FDisplay.FActiveDC.InvalidateAll;
      if doBltOnWMPAINT in FDisplay.FOptions then
        FDisplay.ExecuteBltSurfaceEvent;
    end;
    inherited WndProc(Message);
  end;
end;

{ TCustomDisplay (inc\TDisplay.PAS in the original)

  How the display works, as far as the code of this unit tells:

  The display control has no surfaces of its own. It shows the surfaces of its active display
  controller (FActiveDC), which is one of PrimaryDC and SecondaryDC; SwapDC (also Alt+Enter in
  KeyDown) switches between the two. A controller owns surface 0, the output (the window
  through GDI, or the DirectDraw primary surface), and with double or triple buffering
  (BufferingScheme) back surfaces 1 and 2 that the game draws on. FSurfaceIndex is the back
  surface to show next; with triple buffering UpdateFrame alternates it between 1 and 2.

  Life cycle:
  - Create sets the size to 100 x 100, the color to black, the default options
    [doAutoSwapDC, doAutoStartUpdateFrameLoop, doAutoActivatePrimaryDC, doBltOnWMPAINT],
    double buffering and back surfaces of 640 x 480, and (outside the designer) makes the
    owner the parent and creates the TDDrawFSWinControl that the full screen controllers draw
    in.
  - Loaded creates the window handle; CreateWnd lets the active controller know that the
    window was recreated (WindowRecreated) and, with doAutoActivatePrimaryDC, posts
    WM_DISPLAYC with WParam 2 to activate the primary controller once the window exists.
  - ActivateDC deactivates the active controller and activates the new one. With
    doRestoreSurfacesOnSwap the contents of the old surfaces are captured in TDataSurfaces
    first and remapped into the surfaces of the new controller. When the new controller
    cannot be activated, the old one is activated again and the result is
    DCERR_ACTIVATEFAILED. The frame loop is paused meanwhile; a change of the output size
    calls Resize, a change of the back surface size OnResizeBackSurface, then OnActivateDC
    follows and, with doAutoStartUpdateFrameLoop, the frame loop starts.
  - DeactivateDC calls OnDeactivateDC and deactivates the active controller.
  - Destroy stops the frame loop, deactivates the controller and frees the full screen window
    unless it is already being destroyed.

  The frame loop:
  - StartUpdateFrameLoop runs UpdateFrame at FrameRate frames per second. In umAsynchrone mode
    a TUpdateFrameThread waits for the frame time (FFrameTime, 1000 / FrameRate ms, 2 ms less
    for the thread) and calls UpdateFrame in the main thread through Synchronize; in
    umSynchrone mode StartUpdateFrameLoop itself loops, calling UpdateFrame and
    Application.ProcessMessages, until the loop is stopped or the application terminates.
  - PauseFrameUpdateLoop and ResumeFrameUpdateLoop nest (FPauseCount) and suspend and resume
    the thread; StopUpdateFrameLoop resumes the thread as often as needed and terminates it.
  - UpdateFrame switches the triple buffer, sends a MouseMove(-1, -1) when the mouse left the
    output with no button down, calls OnUpdateFrame (the game draws the frame on the back
    surface it gets; an exception there only shows a message), counts the frame for the frame
    rate (NewFrame), waits for the frame time or the vertical blank (WaitForVerticalBlank) and
    shows the back surface (ExecuteBltSurfaceEvent).
  - ExecuteBltSurfaceEvent calls OnBltSurface and then, depending on BackSurfaceControlMode:
    bmBltSurface blits the whole back surface to the output (BltSurface),
    bmBltInvalidatedSurface blits only the blocks marked in the controller's invalidation
    matrix (BltInvalidatedSurface; Invalidate and InvalidateAll mark them), bmPageFlipping
    flips (FlipSurface; controllers that cannot flip blit and return DCERR_NOFLIP) and bmNone
    shows nothing. With doShowFrameRate the controller writes the frame rate on the output.

  The options (Options):
  - doAutoResizeBackSurface: the back surfaces follow the size of the output (Resize and the
    controllers' Activate).
  - doAutoSwapDC: not tested in this unit.
  - doAutoStartUpdateFrameLoop: ActivateDC and SetUpdateFrameMode start the frame loop.
  - doAutoActivatePrimaryDC: CreateWnd activates the primary controller.
  - doShowFrameRate: ExecuteBltSurfaceEvent shows the frame rate.
  - doShowErrors: ShowError shows a message box.
  - doFocusAble: a mouse click focuses the output window.
  - doRestoreSurfacesOnSwap: ActivateDC copies the surface contents to the new controller.
  - doBltOnWMPAINT: WM_PAINT invalidates everything and shows the back surface again.
  - doAutoEnableDDraw: TWindows16DC activates DirectDraw to find the best 16 bit format.

  The status (FStatus): dsFrameLoopActive and dsFrameLoopPaused belong to the frame loop;
  dsDDrawEnabled, dsDirectInputEnabled, dsAsynchrone and dsExclusiveAccess are not used here.

  The events:
  - OnBltSurface(Sender): before the back surface is shown.
  - OnUpdateFrame(Sender, DC, SurfaceType): draw the frame on back surface SurfaceType of DC.
  - OnSurfaceDataLost(DC, SurfaceType): the contents of a surface were lost (a DirectDraw
    surface was restored, or the back surfaces were resized) and must be drawn again.
  - OnResize(Sender): the output changed its size.
  - OnError(ErrorStr, Error): declared and published, not called in this unit.
  - OnActivateDC, OnDeactivateDC(Sender, DC): a controller was activated or is deactivated.
  - OnHide, OnShow(Sender): the output is hidden or shown (Hide and Show; the full screen
    controllers hide when the application is deactivated and show again through WM_DISPLAYC
    with WParam 1).
  - OnResizeBackSurface(DC, Width, Height): the back surfaces got a new size.
  - OnSwapDC(DC): SwapDC is about to activate DC.

  The messages: WM_SIZE calls Resize; WM_PAINT is handled as described for doBltOnWMPAINT;
  the windowed controllers see the window messages first (TAbstractDC.WndProc) and swallow
  WM_NCPAINT and WM_ERASEBKGND; CM_WANTSPECIALKEY and CN_KEYUP keep the arrow keys for the
  display; WM_DISPLAYC carries the posted requests.

  The controllers (Register puts them on the GFX Engine page of the component palette;
  TDDrawFullScr08DC and the TDDrawWnd DCs have bitmaps in the package but no code):
  - TWindowsDC and its descendants draw in the display's window through GDI: TWindows08DC
    with 8 bit DIBs and a logical palette, TWindows16DC with 16 bit DIB sections (555 or 565,
    PixelFormat), TWindows24DC and TWindows32DC with 24 and 32 bit ones. Every block of the
    invalidation matrix is blitted on its own (GetInvBlockSize).
  - TDDrawFullScrDC and its descendants switch the screen to DisplayWidth x DisplayHeight at
    16, 24 or 32 bits and draw in the full screen window through DirectDraw: a flipping chain
    in video memory when the back surfaces have the size of the screen (UseVideoMemory), else
    separate back surfaces that are blitted. They hide the application's forms while they
    are active, hook the main window for WM_ACTIVATEAPP and WM_DISPLAYCHANGE, and restore
    lost surfaces (VerifyLostSurfaces). UseVerticalBlank waits for the vertical blank;
    DebugMode leaves the window where it is; Enable3D asks for 3D capable surfaces.

  The error codes: DCERR_NOTSUPPORTED (not supported by the controller), DCERR_ACTIVATEFAILED,
  DCERR_FAILED (no invalidation matrix, or an exception during activation), DCERR_ACTIVATED
  (already activated), DCERR_NOTACTIVATED and DCERR_NOFLIP (blitted instead of flipped).

  The controller interface (TAbstractDC), in the order of its VMT:
  - GetInvMatrix, InitInvMatrix, Invalidate, InvalidateAll: the invalidation matrix (blocks
    of the back surface that changed; TMatrix values count down once per shown frame).
  - SetPrimarySurfaceRgn, GetPrimarySurfaceRgn: the rectangle of the output that shows the
    back surface.
  - GetStatus (dsVisible, dsActivated, dsWindowed); GetDisplay, OutputWnd and Handle: the
    display, the control and the window drawn in.
  - GetPalette, GetHPalette, SetPalet, RealizePaletNow: the palette of 8 bit controllers.
  - GetSurface, GetSurfaceCount: surface 0 (the output) and the back surfaces.
  - WndProc: the window messages of the windowed controllers (False swallows a message).
  - SupportDisplayMode: whether the controller can work with the display (SupportDC).
  - WindowRecreated: the window handle changed.
  - ShowError passes an error message to the display; Hide and Show hide and show the output.
  - GetPixPosofBlock, GetBlockPosofPix, GetInvBlockSize: block and pixel coordinates of the
    invalidation matrix.
  - NewFrame, ShowFrameRate: the frame rate; Activate, Deactivate: start and stop working.
  - FlipSurface, BltSurface, BltInvalidatedSurface: show a back surface.
  - ResizeBackSurfaces: gives the back surfaces a new size.
  - GetMousePos: the mouse position in output coordinates (-1, -1 outside).
  - WaitForVerticalBlank: waits for the frame time or the vertical blank.

  This comment also keeps the Assert in CreateWnd on the line that the original reports
  (1350, counted through the include file). }

function TCustomDisplay.GetPalette: HPALETTE;
begin
  if not (csDesigning in ComponentState) then
  begin
    Result := 0;
    if FActiveDC <> nil then
      Result := FActiveDC.GetHPalette;
    if Result = 0 then
      Result := inherited GetPalette;
  end
  else
    Result := inherited GetPalette;
end;

procedure TCustomDisplay.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not (csDesigning in ComponentState) then
    Params.WindowClass.style := Params.WindowClass.style or CS_OWNDC;
end;

procedure TCustomDisplay.CreateWnd;
begin
  Assert(not (csDestroying in ComponentState));
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
  begin
    if FActiveDC <> nil then
      FActiveDC.WindowRecreated;
    if (FPrimaryDC <> nil) and (FActiveDC = nil) and (doAutoActivatePrimaryDC in FOptions) then
      PostMessage(Handle, WM_DISPLAYC, 2, 0);
  end;
end;

procedure TCustomDisplay.SetFrameRate(Value: Integer);
begin
  FFrameRate := Value;
  if FFrameRate <> 0 then
    FFrameTime := Round(1000 / FFrameRate)
  else
    FFrameTime := 0;
end;

procedure TCustomDisplay.SetCursor(Value: TCursor);
begin
  TControl(Self).Cursor := Value;
  if FFSWinControl <> nil then
    FFSWinControl.Cursor := Value;
end;

function TCustomDisplay.GetCursor: TCursor;
begin
  Result := TControl(Self).Cursor;
end;

procedure TCustomDisplay.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (doFocusAble in FOptions) and (FActiveDC <> nil) then
    Windows.SetFocus(FActiveDC.Handle);
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCustomDisplay.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_RETURN) and (Shift = [ssAlt]) then
    SwapDC;
end;

procedure TCustomDisplay.SetBufferingScheme(Value: TBufferingScheme);
begin
  if FActiveDC = nil then
    FBufferingScheme := Value
  else
    ShowError('Cannot change buffering scheme when DC is activated');
  case FBufferingScheme of
    bsSingle: FSurfaceIndex := 0;
    bsDouble: FSurfaceIndex := 1;
    bsTripple: FSurfaceIndex := 2;
  end;
end;

procedure TCustomDisplay.SetUpdateFrameMode(Value: TUpdateFrameMode);
begin
  if not (dsFrameLoopActive in FStatus) then
  begin
    FUpdateFrameMode := Value;
    if not (csDesigning in ComponentState) and (doAutoStartUpdateFrameLoop in FOptions) and
      not (csLoading in ComponentState) then
      StartUpdateFrameLoop;
  end
  else
    ShowError('Cannot change update frame loop mode when UpdateFrame loop is activated');
end;

constructor TCustomDisplay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 100;
  Color := clBlack;
  FOptions := [doAutoSwapDC, doAutoStartUpdateFrameLoop, doAutoActivatePrimaryDC, doBltOnWMPAINT];
  FBackSurfaceControlMode := bmBltSurface;
  FBackSurfaceWidth := 640;
  FBackSurfaceHeight := 480;
  FBufferingScheme := bsDouble;
  FUpdateFrameMode := umAsynchrone;
  if not (csDesigning in ComponentState) then
  begin
    Parent := TWinControl(AOwner);
    FFSWinControl := TDDrawFSWinControl.Create(Application);
    FFSWinControl.FDisplay := Self;
  end;
end;

destructor TCustomDisplay.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    StopUpdateFrameLoop;
    if FActiveDC <> nil then
    begin
      FActiveDC.Deactivate;
      FActiveDC := nil;
    end;
    if (FFSWinControl <> nil) and not (csDestroying in FFSWinControl.ComponentState) then
    begin
      FFSWinControl.Destroy;
      FFSWinControl := nil;
    end;
  end;
  inherited Destroy;
end;

procedure TCustomDisplay.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
    HandleNeeded;
end;

procedure TCustomDisplay.GetMousePos(var X, Y: Integer);
begin
  if FActiveDC <> nil then
    FActiveDC.GetMousePos(X, Y);
end;

function TCustomDisplay.GetMouseButton: Integer;
begin
  Result := 0;
  if GetAsyncKeyState(VK_LBUTTON) and $8000 <> 0 then
    Result := Result or 1;
  if GetAsyncKeyState(VK_RBUTTON) and $8000 <> 0 then
    Result := Result or 2;
  if GetAsyncKeyState(VK_MBUTTON) and $8000 <> 0 then
    Result := Result or 4;
end;

procedure TCustomDisplay.SurfaceDataLost(SurfaceType: Integer);
begin
  if Assigned(FOnSurfaceDataLost) then
    FOnSurfaceDataLost(FActiveDC, SurfaceType);
end;

procedure TCustomDisplay.ResizeBackSurfaces(AWidth, AHeight: Integer);
var
  I: Integer;
begin
  FBackSurfaceWidth := AWidth;
  FBackSurfaceHeight := AHeight;
  if not (csDesigning in ComponentState) and (FActiveDC <> nil) and (FBufferingScheme <> bsSingle) then
    if (FActiveDC.GetSurface(1).Width <> AWidth) or (FActiveDC.GetSurface(1).Height <> AHeight) then
    begin
      FActiveDC.ResizeBackSurfaces(FBackSurfaceWidth, FBackSurfaceHeight);
      for I := 1 to Ord(FBufferingScheme) do
        SurfaceDataLost(I);
    end;
  if Assigned(FOnResizeBackSurface) then
    FOnResizeBackSurface(FActiveDC, AWidth, AHeight);
end;

procedure TCustomDisplay.SetBackSurfaceWidth(Value: Integer);
begin
  if Value >= 0 then
    ResizeBackSurfaces(Value, FBackSurfaceHeight);
end;

procedure TCustomDisplay.SetBackSurfaceHeight(Value: Integer);
begin
  if Value >= 0 then
    ResizeBackSurfaces(FBackSurfaceWidth, Value);
end;

procedure TCustomDisplay.Resize;
begin
  if FActiveDC <> nil then
  begin
    with FActiveDC do
    begin
      GetPrimarySurfaceRgn^.Left := 0;
      GetPrimarySurfaceRgn^.Right := GetSurface(0).Width;
      GetPrimarySurfaceRgn^.Top := 0;
      GetPrimarySurfaceRgn^.Bottom := GetSurface(0).Height;
    end;
    if doAutoResizeBackSurface in FOptions then
      ResizeBackSurfaces(FActiveDC.GetSurface(0).Width, FActiveDC.GetSurface(0).Height);
  end
  else if doAutoResizeBackSurface in FOptions then
    ResizeBackSurfaces(Width, Height);
  if Assigned(FOnResize) then
    FOnResize(Self);
end;

function TCustomDisplay.GetDC(Index: Integer): TAbstractDC;
begin
  case Index of
    -1: Result := FActiveDC;
    0: Result := FPrimaryDC;
    1: Result := FSecondaryDC;
  else
    Result := nil;
  end;
end;

procedure TCustomDisplay.CMWantSpecialKey(var Message: TCMWantSpecialKey);
begin
  inherited;
  if (Message.CharCode = VK_LEFT) or (Message.CharCode = VK_RIGHT) or (Message.CharCode = VK_UP) or
    (Message.CharCode = VK_DOWN) then
    Message.Result := 1;
end;

procedure TCustomDisplay.CMKeyUP(var Message: TWMKeyUp);
begin
  inherited;
  if (Message.CharCode = VK_LEFT) or (Message.CharCode = VK_RIGHT) or (Message.CharCode = VK_UP) or
    (Message.CharCode = VK_DOWN) then
    Message.Result := 0;
end;

function TCustomDisplay.GetMouseAboveSurface: Boolean;
var
  P: TPoint;
  R: TRect;
begin
  if FActiveDC <> nil then
  begin
    if dsWindowed in FActiveDC.GetStatus then
    begin
      GetWindowRect(Handle, R);
      GetCursorPos(P);
      Result := (P.X >= R.Left) and (P.X < R.Right) and (P.Y >= R.Top) and (P.Y < R.Bottom);
    end
    else
      Result := True;
  end
  else
    Result := False;
end;

procedure TCustomDisplay.WndProc(var Message: TMessage);
begin
  if not (csDesigning in ComponentState) then
  begin
    if (FActiveDC <> nil) and (dsWindowed in FActiveDC.GetStatus) then
    begin
      if FActiveDC.WndProc(Message) then
        inherited WndProc(Message);
      if Message.Msg = WM_PAINT then
      begin
        FActiveDC.InvalidateAll;
        if doBltOnWMPAINT in FOptions then
          ExecuteBltSurfaceEvent;
      end;
    end
    else
      inherited WndProc(Message);
    if Message.Msg = WM_SIZE then
      Resize;
    if (Message.Msg = WM_DISPLAYC) and not (csDestroying in ComponentState) then
    begin
      case Message.WParam of
        1: Show;
        2:
          try
            ActivateDC(FPrimaryDC);
          except
          end;
      end;
      Message.Result := 0;
    end;
  end
  else
    inherited WndProc(Message);
end;

procedure TCustomDisplay.ShowError(Msg: string);
begin
  if doShowErrors in FOptions then
    MessageDlg(Msg, mtError, [mbOK], 0);
end;

function TCustomDisplay.ExecuteBltSurfaceEvent: HResult;
begin
  try
    Result := 0;
    if (FActiveDC <> nil) and (dsVisible in FActiveDC.GetStatus) then
    begin
      if Assigned(FOnBltSurface) then
        FOnBltSurface(Self);
      if FBufferingScheme <> bsSingle then
        case FBackSurfaceControlMode of
          bmPageFlipping: Result := FActiveDC.FlipSurface(FSurfaceIndex);
          bmBltSurface: Result := FActiveDC.BltSurface(FSurfaceIndex);
          bmBltInvalidatedSurface: Result := FActiveDC.BltInvalidatedSurface(FSurfaceIndex);
        end;
      if doShowFrameRate in FOptions then
        FActiveDC.ShowFrameRate;
    end;
  except
    ShowMessage('Exception occured during ExecuteBltSurface event');
    raise;
  end;
end;

procedure TCustomDisplay.Hide;
begin
  if Assigned(FOnHide) then
    FOnHide(Self);
  if (FActiveDC <> nil) and not (csDesigning in ComponentState) then
    FActiveDC.Hide;
end;

procedure TCustomDisplay.Show;
begin
  if (FActiveDC <> nil) and not (csDesigning in ComponentState) then
    FActiveDC.Show;
  if Assigned(FOnShow) then
    FOnShow(Self);
end;

function TCustomDisplay.SupportDC(DC: TAbstractDC): HResult;
begin
  if DC <> nil then
    Result := DC.SupportDisplayMode(Self)
  else
    Result := DCERR_NOTSUPPORTED;
end;

{ Deactivates the active DC and activates DC; falls back to the old DC when that fails. With
  doRestoreSurfacesOnSwap the contents of the surfaces are copied over to the new DC. }
function TCustomDisplay.ActivateDC(DC: TAbstractDC): HResult;
var
  OldBackW, OldBackH, OldW, OldH: Integer;
  OldDC: TAbstractDC;
  I: Integer;
  Surfaces: array[0..2] of TDataSurface;
begin
  if (FActiveDC <> DC) and not (dsActivated in DC.GetStatus) then
  begin
    OldW := 0;
    OldH := 0;
    OldBackW := FBackSurfaceWidth;
    OldBackH := FBackSurfaceHeight;
    PauseFrameUpdateLoop;
    FSurfaceIndex := 1;
    OldDC := nil;
    FillChar(Surfaces, SizeOf(Surfaces), 0);
    if FActiveDC <> nil then
    begin
      OldW := FActiveDC.GetSurface(0).Width;
      OldH := FActiveDC.GetSurface(0).Height;
      OldDC := FActiveDC;
      if doRestoreSurfacesOnSwap in FOptions then
        for I := 0 to Ord(FBufferingScheme) do
        begin
          Surfaces[I] := TDataSurface.Create(0, 0, 0, nil);
          if Surfaces[I].CaptureSurface(FActiveDC.GetSurface(I), nil) < 0 then
          begin
            Surfaces[I].Free;
            Surfaces[I] := nil;
          end;
        end;
      DeactivateDC;
      FActiveDC := nil;
    end;
    Result := DC.Activate(Self);
    if Result >= 0 then
      FActiveDC := DC
    else
    begin
      ShowError('Could not activate Display Control ' + DC.ClassName + ' (Error:' + IntToStr(Result) + ')');
      if (OldDC <> nil) and (OldDC.Activate(Self) >= 0) then
        FActiveDC := OldDC;
      Result := DCERR_ACTIVATEFAILED;
    end;
    ResumeFrameUpdateLoop;
    if FActiveDC <> nil then
    begin
      if doRestoreSurfacesOnSwap in FOptions then
        for I := 0 to Ord(FBufferingScheme) do
          if Surfaces[I] <> nil then
            RemapSurface(Surfaces[I], FActiveDC.GetSurface(I));
      Windows.SetFocus(FActiveDC.Handle);
    end;
    for I := 0 to Ord(FBufferingScheme) do
      if Surfaces[I] <> nil then
        Surfaces[I].Free;
    if (OldDC <> nil) and (FActiveDC <> nil) and
      ((FActiveDC.GetSurface(0).Width <> OldW) or (FActiveDC.GetSurface(0).Height <> OldH)) then
      Resize;
    if (FActiveDC <> nil) and Assigned(FOnResizeBackSurface) and (FBufferingScheme <> bsSingle) and
      ((OldBackW <> FBackSurfaceWidth) or (OldBackH <> FBackSurfaceHeight)) then
      FOnResizeBackSurface(FActiveDC, FBackSurfaceWidth, FBackSurfaceHeight);
    if FActiveDC <> nil then
    begin
      if Assigned(FOnActivateDC) then
        FOnActivateDC(Self, FActiveDC);
      if (Result >= 0) and (doAutoStartUpdateFrameLoop in FOptions) and (FActiveDC <> nil) and
        not (dsFrameLoopActive in FStatus) then
        StartUpdateFrameLoop;
    end;
  end
  else
    Result := DCERR_ACTIVATED;
end;

function TCustomDisplay.DeactivateDC: HResult;
begin
  if (FActiveDC <> nil) and (dsActivated in FActiveDC.GetStatus) then
  begin
    if Assigned(FOnDeactivateDC) then
      FOnDeactivateDC(Self, FActiveDC);
    FActiveDC.Deactivate;
    FActiveDC := nil;
  end;
  Result := 0;
end;

function TCustomDisplay.SwapDC: HResult;
var
  NewDC: TAbstractDC;
begin
  if FPrimaryDC = FActiveDC then
    NewDC := FSecondaryDC
  else
    NewDC := FPrimaryDC;
  if Assigned(FOnSwapDC) then
    FOnSwapDC(NewDC);
  if NewDC <> nil then
    Result := ActivateDC(NewDC)
  else
    Result := DCERR_NOTSUPPORTED;
end;

procedure TCustomDisplay.UpdateFrame;
begin
  if FBufferingScheme = bsTripple then
    if FSurfaceIndex = 1 then
      FSurfaceIndex := 2
    else
      FSurfaceIndex := 1;
  if GetMouseAboveSurface <> FMouseAboveSurface then
  begin
    FMouseAboveSurface := not FMouseAboveSurface;
    if not FMouseAboveSurface and (GetMouseButton = 0) then
      MouseMove([], -1, -1);
  end;
  if Assigned(FOnUpdateFrame) then
    try
      FOnUpdateFrame(Self, FActiveDC, FSurfaceIndex);
    except
      ShowMessage('Exception occurred during UpdateFrame event');
    end;
  if FActiveDC <> nil then
  begin
    FActiveDC.NewFrame;
    FActiveDC.WaitForVerticalBlank;
    ExecuteBltSurfaceEvent;
  end;
end;

procedure TCustomDisplay.StopUpdateFrameLoop;
begin
  if dsFrameLoopActive in FStatus then
  begin
    if FUpdateFrameThread <> nil then
    begin
      while FUpdateFrameThread.Suspended do
        FUpdateFrameThread.Resume;
      FUpdateFrameThread.Terminate;
      FUpdateFrameThread := nil;
    end;
    FStatus := FStatus - [dsFrameLoopActive];
  end;
  FPauseCount := 0;
  FStatus := FStatus - [dsFrameLoopPaused];
end;

procedure TCustomDisplay.PauseFrameUpdateLoop;
begin
  Inc(FPauseCount);
  if not (dsFrameLoopPaused in FStatus) then
  begin
    FStatus := FStatus + [dsFrameLoopPaused];
    if FUpdateFrameThread <> nil then
      FUpdateFrameThread.Suspend;
  end;
end;

procedure TCustomDisplay.ResumeFrameUpdateLoop;
begin
  if dsFrameLoopPaused in FStatus then
  begin
    Dec(FPauseCount);
    if FPauseCount = 0 then
    begin
      FStatus := FStatus - [dsFrameLoopPaused];
      if FUpdateFrameThread <> nil then
        FUpdateFrameThread.Resume;
    end;
  end;
end;

{ Starts the frame loop: a TUpdateFrameThread (umAsynchrone), or a loop that runs here until
  the loop is stopped (umSynchrone). }
procedure TCustomDisplay.StartUpdateFrameLoop;
begin
  if not (dsFrameLoopActive in FStatus) then
  begin
    FStatus := FStatus + [dsFrameLoopActive];
    if FUpdateFrameMode = umAsynchrone then
      FUpdateFrameThread := TUpdateFrameThread.Create(Self)
    else
      while dsFrameLoopActive in FStatus do
        if (FActiveDC <> nil) and not Application.Terminated then
        begin
          if not (dsFrameLoopPaused in FStatus) and (FActiveDC <> nil) then
            UpdateFrame;
          Application.ProcessMessages;
        end
        else
          StopUpdateFrameLoop;
  end;
  FPauseCount := 0;
  FStatus := FStatus - [dsFrameLoopPaused];
end;

{ TDisplayGDISurface }

constructor TDisplayGDISurface.Create(AControl: TWinControl);
begin
  if AControl <> nil then
    inherited Create(AControl.Handle)
  else
    inherited Create(0);
  FControl := AControl;
end;

function TDisplayGDISurface.GetHandle: HWND;
begin
  Result := FControl.Handle;
end;

{ TWindowsDC }

constructor TWindowsDC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InitInvMatrix(4, 4);
  FStatus := FStatus + [dsWindowed];
end;

function TWindowsDC.Activate(ADisplay: TCustomDisplay): HResult;
begin
  Result := inherited Activate(ADisplay);
  if Result >= 0 then
  begin
    FGDISurface := TDisplayGDISurface.Create(ADisplay);
    GetPrimarySurfaceRgn^.Left := 0;
    GetPrimarySurfaceRgn^.Right := FGDISurface.Width;
    GetPrimarySurfaceRgn^.Top := 0;
    GetPrimarySurfaceRgn^.Bottom := FGDISurface.Height;
    if doAutoResizeBackSurface in ADisplay.FOptions then
      ADisplay.ResizeBackSurfaces(FGDISurface.Width, FGDISurface.Height);
    FWnd := Handle;
    FDC := Windows.GetDC(Handle);
    SetStretchBltMode(FDC, COLORONCOLOR);
    Show;
  end;
end;

function TWindowsDC.Deactivate: HResult;
begin
  if (FDC <> 0) and (FDisplay <> nil) then
  begin
    ReleaseDC(FWnd, FDC);
    FDC := 0;
  end;
  FGDISurface.Free;
  FGDISurface := nil;
  Result := inherited Deactivate;
end;

procedure TWindowsDC.WindowRecreated;
begin
  FWnd := Handle;
  FDC := Windows.GetDC(FWnd);
  SetStretchBltMode(FDC, COLORONCOLOR);
end;

function TWindowsDC.SupportDisplayMode(ADisplay: TCustomDisplay): HResult;
begin
  Result := 0;
end;

function TWindowsDC.BltSurface(Index: Integer): HResult;
begin
  Result := GetSurface(Index).BltDC(FDC, nil, @FPrimarySurfaceRgn);
end;

function TWindowsDC.FlipSurface(Index: Integer): HResult;
begin
  Result := GetSurface(Index).BltDC(FDC, nil, @FPrimarySurfaceRgn);
  if Result >= 0 then
    Result := DCERR_NOFLIP;
end;

{ In a window every block is a block of its own. }
function TWindowsDC.GetInvBlockSize(X, Y: Integer; Matrix: TMatrix; var BW, BH: Integer): Integer;
begin
  if GetInvMatrix.GetVal(X, Y) <> 0 then
  begin
    BW := 1;
    BH := 1;
  end
  else
  begin
    BW := 0;
    BH := 0;
  end;
  Result := BW * BH;
end;

procedure TWindowsDC.ShowFrameRate;
var
  S: string;
begin
  if FDC <> 0 then
  begin
    S := ' Framerate: ' + IntToStr(GetCurrentFrameRate) + '  ' + #0;
    TextOut(FDC, 0, 0, @S[1], Length(S) - 1);
  end;
end;

type
  { DisplayC.TWindows08DIBSurface (instance size 28): an 8 bit bottom-up DIB of a
    TWindows08DC, drawn with the bitmap info and palette of its owner. +4 FWidth, +8 FHeight,
    +$C FMem, +$10 FBits (FMem aligned to 8), +$14 FPitch (negative), +$18 FOwner. }
  TWindows08DIBSurface = class(TSurface)
  private
    FWidth: Integer;
    FHeight: Integer;
    FMem: Pointer;
    FBits: Pointer;
    FPitch: Integer;
    FOwner: TWindows08DC;
  public
    constructor Create(AWidth, AHeight: Integer; AOwner: TWindows08DC);
    destructor Destroy; override;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function BltStretch(Dest: TSurface; SrcRect, DestRect: PRect): HResult; override;
    function BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult; override;
    function Lock(var SD: TSurfaceDesc): HResult; override;
    function Unlock: HResult; override;
    function UpdatePalette: HResult; override;
    function Cls(Color: TColor): HResult; override;
    function Resize(AWidth, AHeight: Integer): HResult; override;
  end;

{ TWindows08DIBSurface }

constructor TWindows08DIBSurface.Create(AWidth, AHeight: Integer; AOwner: TWindows08DC);
begin
  inherited Create;
  FOwner := AOwner;
  Resize(AWidth, AHeight);
end;

destructor TWindows08DIBSurface.Destroy;
begin
  ReallocMem(FMem, 0);
  inherited Destroy;
end;

function TWindows08DIBSurface.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TWindows08DIBSurface.GetHeight: Integer;
begin
  Result := FHeight;
end;

{ Copies SrcRect to the top left of DestRect (no stretching); a GDI surface that cannot be
  locked is drawn on with BltDC. }
function TWindows08DIBSurface.BltStretch(Dest: TSurface; SrcRect, DestRect: PRect): HResult;
var
  P, Dst: Integer;
  DC: HDC;
  SD: TSurfaceDesc;
  SR, DR: TRect;
begin
  if Dest.Lock(SD) >= 0 then
  begin
    if SrcRect = nil then
    begin
      SR.Left := 0;
      SR.Right := FWidth;
      SR.Top := 0;
      SR.Bottom := FHeight;
      SrcRect := @SR;
    end;
    if DestRect = nil then
    begin
      DR.Left := 0;
      DR.Right := Dest.Width;
      DR.Top := 0;
      DR.Bottom := Dest.Height;
      DestRect := @DR;
    end;
    P := Abs(FHeight * FPitch) + Integer(FBits) + FPitch + SrcRect^.Left + SrcRect^.Top * FPitch;
    Dst := Integer(SD.Data) + DestRect^.Left + DestRect^.Top * SD.Pitch;
    BltRect(Pointer(P), Pointer(Dst), FPitch, SD.Pitch, SrcRect^.Right - SrcRect^.Left,
      SrcRect^.Bottom - SrcRect^.Top);
    Dest.Unlock;
    Result := 0;
  end
  else if Dest is TGDISurface then
  begin
    DC := Windows.GetDC(TGDISurface(Dest).Handle);
    Result := BltDC(DC, SrcRect, DestRect);
    ReleaseDC(TGDISurface(Dest).Handle, DC);
  end
  else
    Result := GFXE_CANNOTLOCK;
end;

function TWindows08DIBSurface.BltDC(DC: HDC; SrcRect, DestRect: PRect): HResult;
var
  SR, DR: TRect;
begin
  if SrcRect = nil then
  begin
    SR.Left := 0;
    SR.Top := 0;
    SR.Right := FWidth;
    SR.Bottom := FHeight;
    SrcRect := @SR;
  end;
  if DestRect = nil then
  begin
    GetClientRect(WindowFromDC(DC), DR);
    DestRect := @DR;
  end;
  if StretchDIBits(DC, DestRect^.Left, DestRect^.Top, DestRect^.Right - DestRect^.Left,
    DestRect^.Bottom - DestRect^.Top, SrcRect^.Left, FHeight - SrcRect^.Bottom,
    SrcRect^.Right - SrcRect^.Left, SrcRect^.Bottom - SrcRect^.Top, FBits,
    PBitmapInfo(@FOwner.FBitmapInfo)^, DIB_RGB_COLORS, SRCCOPY) = DestRect^.Bottom - DestRect^.Top then
    Result := 0
  else
    Result := GFXE_ERROR;
end;

function TWindows08DIBSurface.Lock(var SD: TSurfaceDesc): HResult;
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
  SD.Palette := FOwner.FPalette;
  SD.Data := Pointer(Abs(FHeight * FPitch) + Integer(FBits) + FPitch);
  Result := 0;
end;

function TWindows08DIBSurface.Unlock: HResult;
begin
  Result := 0;
end;

function TWindows08DIBSurface.UpdatePalette: HResult;
begin
  FOwner.UpdatePalette;
  Result := 0;
end;

{ Bug kept from the original: fills from the field FBits instead of the bits (with a negative
  count, so nothing happens). }
function TWindows08DIBSurface.Cls(Color: TColor): HResult;
var
  C: Integer;
begin
  C := FOwner.FPalette.GetNearestColor(Color);
  FillChar(FBits, FPitch * FHeight, C);
  Result := 0;
end;

function TWindows08DIBSurface.Resize(AWidth, AHeight: Integer): HResult;
begin
  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin
    FWidth := AWidth;
    FHeight := AHeight;
    FPitch := -((FWidth + 7) and not 7);
    with FOwner.FBitmapInfo do
    begin
      biWidth := Abs(FPitch);
      biHeight := FHeight;
    end;
    ReallocMem(FMem, Abs(FPitch * FHeight) + 7);
    FBits := Pointer((Integer(FMem) + 7) and not 7);
    Result := 0;
  end
  else
    Result := 0;
end;

{ TWindows08DC }

constructor TWindows08DC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPalette := TGFXEPalette.Create;
  FPalette.PixelFormatID := pfRGB24;
end;

destructor TWindows08DC.Destroy;
begin
  FPalette.Free;
  inherited Destroy;
end;

function TWindows08DC.GetPalette: TGFXEPalette;
begin
  Result := FPalette;
end;

function TWindows08DC.GetHPalette: HPALETTE;
begin
  Result := FHPalette;
end;

function TWindows08DC.GetSurface(Index: Integer): TSurface;
begin
  case Index of
    0: Result := FGDISurface;
    1: Result := FBack1;
    2: Result := FBack2;
  else
    Result := nil;
  end;
end;

function TWindows08DC.Deactivate: HResult;
begin
  if dsActivated in FStatus then
  begin
    FBack1.Free;
    FBack1 := nil;
    FBack2.Free;
    FBack2 := nil;
  end;
  ReleaseHPalette;
  Result := inherited Deactivate;
end;

function TWindows08DC.Activate(ADisplay: TCustomDisplay): HResult;
var
  I: Integer;
begin
  Result := inherited Activate(ADisplay);
  if Result >= 0 then
  begin
    with FBitmapInfo do
    begin
      biSize := SizeOf(TBitmapInfoHeader);
      biPlanes := 1;
      biBitCount := 8;
      biCompression := BI_RGB;
      biSizeImage := 0;
      biClrUsed := 256;
      biClrImportant := 0;
    end;
    if ADisplay.FBufferingScheme in [bsDouble, bsTripple] then
    begin
      FBack1 := TWindows08DIBSurface.Create(ADisplay.FBackSurfaceWidth, ADisplay.FBackSurfaceHeight, Self);
      FBack1.Cls(ADisplay.Color);
    end;
    if ADisplay.FBufferingScheme = bsTripple then
    begin
      FBack2 := TWindows08DIBSurface.Create(ADisplay.FBackSurfaceWidth, ADisplay.FBackSurfaceHeight, Self);
      FBack2.Cls(ADisplay.Color);
    end;
    GetSystemPaletteEntries(FDC, 0, 256, FPalette.GetEntry(0)^);
    for I := 0 to 255 do
      with FPalette.Entries[I] do
      begin
        FColors[I].rgbRed := R;
        FColors[I].rgbGreen := G;
        FColors[I].rgbBlue := B;
        FColors[I].rgbReserved := PC_NOCOLLAPSE;
      end;
    CreateHPalette;
  end;
  if Result < 0 then
    Deactivate;
end;

procedure TWindows08DC.CreateHPalette;
var
  LogPal: record
    palVersion: Word;
    palNumEntries: Word;
    palPalEntry: array[0..255] of Windows.TPaletteEntry;
  end;
begin
  LogPal.palVersion := $300;
  LogPal.palNumEntries := 236;
  Move(FPalette.GetEntry(0)^, LogPal.palPalEntry, SizeOf(LogPal.palPalEntry));
  FHPalette := CreatePalette(PLogPalette(@LogPal)^);
  FOldPalette := SelectPalette(FDC, FHPalette, False);
  RealizePalette(FDC);
end;

procedure TWindows08DC.ReleaseHPalette;
begin
  if FOldPalette <> 0 then
  begin
    SelectPalette(FDC, FOldPalette, False);
    FOldPalette := 0;
  end;
  DeleteObject(FHPalette);
  FHPalette := 0;
end;

procedure TWindows08DC.WindowRecreated;
begin
  inherited WindowRecreated;
  if FOldPalette <> 0 then
    DeleteObject(FOldPalette);
  CreateHPalette;
  UpdatePalette;
end;

procedure TWindows08DC.UpdatePalette;
var
  I: Integer;
  D: TCustomDisplay;
begin
  for I := 0 to 255 do
    with FPalette.Entries[I] do
    begin
      FColors[I].rgbRed := R;
      FColors[I].rgbGreen := G;
      FColors[I].rgbBlue := B;
      FColors[I].rgbReserved := PC_NOCOLLAPSE;
    end;
  SetPaletteEntries(FHPalette, 0, 256, FPalette.GetEntry(0)^);
  if RealizePalette(FDC) = GDI_ERROR then
  begin
    D := GetDisplay;
    D.ShowError('Could not realize palette (TWindows08DC)');
  end;
  InvalidateAll;
end;

{ TWindows16DC }

constructor TWindows16DC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPixelFormat := pfAuto;
end;

function TWindows16DC.GetSurface(Index: Integer): TSurface;
begin
  case Index of
    0: Result := FGDISurface;
    1: Result := FBack1;
    2: Result := FBack2;
  else
    Result := nil;
  end;
end;

function TWindows16DC.Deactivate: HResult;
begin
  if dsActivated in FStatus then
  begin
    FBack1.Free;
    FBack1 := nil;
    FBack2.Free;
    FBack2 := nil;
  end;
  Result := inherited Deactivate;
end;

procedure TWindows16DC.SetPixelFormat(Value: TWin16DCPixelFormat);
begin
  if not (dsActivated in FStatus) then
    FPixelFormat := Value
  else
    ShowMessage('Cannot change PixelFormat when activated');
end;

function TWindows16DC.Activate(ADisplay: TCustomDisplay): HResult;
var
  PFID: Integer;
begin
  Result := inherited Activate(ADisplay);
  if Result >= 0 then
  begin
    if FPixelFormat = pfAuto then
    begin
      if doAutoEnableDDraw in ADisplay.FOptions then
        DD;
      if DirectDrawActivated then
        PFID := GetOptimalPixelFormatID(16)
      else
        PFID := pfRGB555;
    end
    else if FPixelFormat = pf555 then
      PFID := pfRGB555
    else
      PFID := pfRGB565;
    if (PFID <> pfRGB565) and (PFID <> pfRGB555) then
      PFID := pfRGB555;
    if ADisplay.FBufferingScheme in [bsDouble, bsTripple] then
    begin
      FBack1 := TDIB16Surface.Create(ADisplay.FBackSurfaceWidth, ADisplay.FBackSurfaceHeight, PFID);
      FBack1.Cls(ADisplay.Color);
    end;
    if ADisplay.FBufferingScheme = bsTripple then
    begin
      FBack2 := TDIB16Surface.Create(ADisplay.FBackSurfaceWidth, ADisplay.FBackSurfaceHeight, PFID);
      FBack2.Cls(ADisplay.Color);
    end;
  end;
  if Result < 0 then
    Deactivate;
end;

{ TWindows24DC }

function TWindows24DC.GetSurface(Index: Integer): TSurface;
begin
  case Index of
    0: Result := FGDISurface;
    1: Result := FBack1;
    2: Result := FBack2;
  else
    Result := nil;
  end;
end;

function TWindows24DC.Deactivate: HResult;
begin
  if dsActivated in FStatus then
  begin
    FBack1.Free;
    FBack1 := nil;
    FBack2.Free;
    FBack2 := nil;
  end;
  Result := inherited Deactivate;
end;

function TWindows24DC.Activate(ADisplay: TCustomDisplay): HResult;
begin
  Result := inherited Activate(ADisplay);
  if Result >= 0 then
  begin
    if ADisplay.FBufferingScheme in [bsDouble, bsTripple] then
    begin
      FBack1 := TDIB24Surface.Create(ADisplay.FBackSurfaceWidth, ADisplay.FBackSurfaceHeight);
      FBack1.Cls(ADisplay.Color);
    end;
    if ADisplay.FBufferingScheme = bsTripple then
    begin
      FBack2 := TDIB24Surface.Create(ADisplay.FBackSurfaceWidth, ADisplay.FBackSurfaceHeight);
      FBack2.Cls(ADisplay.Color);
    end;
  end;
  if Result < 0 then
    Deactivate;
end;

{ TWindows32DC }

function TWindows32DC.GetSurface(Index: Integer): TSurface;
begin
  case Index of
    0: Result := FGDISurface;
    1: Result := FBack1;
    2: Result := FBack2;
  else
    Result := nil;
  end;
end;

function TWindows32DC.Deactivate: HResult;
begin
  if dsActivated in FStatus then
  begin
    FBack1.Free;
    FBack1 := nil;
    FBack2.Free;
    FBack2 := nil;
  end;
  Result := inherited Deactivate;
end;

function TWindows32DC.Activate(ADisplay: TCustomDisplay): HResult;
begin
  Result := inherited Activate(ADisplay);
  if Result >= 0 then
  begin
    if ADisplay.FBufferingScheme in [bsDouble, bsTripple] then
    begin
      FBack1 := TDIB32Surface.Create(ADisplay.FBackSurfaceWidth, ADisplay.FBackSurfaceHeight);
      FBack1.Cls(ADisplay.Color);
    end;
    if ADisplay.FBufferingScheme = bsTripple then
    begin
      FBack2 := TDIB32Surface.Create(ADisplay.FBackSurfaceWidth, ADisplay.FBackSurfaceHeight);
      FBack2.Cls(ADisplay.Color);
    end;
  end;
  if Result < 0 then
    Deactivate;
end;

{ TDDrawDCSurface }

function TDDrawDCSurface.SetDDSurface(ASurface: IDirectDrawSurface; AStatus: TDDrawSurfaceStatus): HResult;
var
  DDSD: TDDSurfaceDesc;
begin
  if FSurface <> nil then
    FSurface := nil;
  FStatus := [];
  FSurface := IDirectDrawSurface2(ASurface);
  if FSurface <> nil then
  begin
    FillChar(DDSD, SizeOf(DDSD), 0);
    DDSD.dwSize := SizeOf(DDSD);
    Result := FSurface.Lock(nil, DDSD, DDLOCK_WAIT, 0);
    if Succeeded(Result) then
    begin
      FWidth := DDSD.dwWidth;
      FHeight := DDSD.dwHeight;
      with DDSD.ddpfPixelFormat do
        FPixelFormatID := MASKtoPFID(dwRGBBitCount, dwRBitMask, dwGBitMask, dwBBitMask, dwRGBAlphaBitMask);
      FSurface.Unlock(nil);
      FStatus := AStatus;
    end;
  end
  else
  begin
    FWidth := 0;
    FHeight := 0;
    FPixelFormatID := 0;
    Result := 0;
  end;
end;

{ TDDrawDC }

procedure TDDrawDC.SurfaceLost(Sender: TObject);
begin
  VerifyLostSurfaces;
end;

{ Restores the lost surfaces and tells the display which surfaces lost their contents. }
function TDDrawDC.VerifyLostSurfaces: HResult;
begin
  Result := 0;
  if (FPrimary <> nil) and FPrimary.Lost then
  begin
    Result := FPrimary.Restore;
    if Succeeded(Result) then
    begin
      FDisplay.SurfaceDataLost(0);
      if (FBack1 <> nil) and (ssComplex in FBack1.Status) then
        FDisplay.SurfaceDataLost(1);
      if (FBack2 <> nil) and (ssComplex in FBack2.Status) then
        FDisplay.SurfaceDataLost(2);
    end;
  end;
  if Succeeded(Result) and (FBack1 <> nil) and FBack1.Lost then
  begin
    Result := FBack1.Restore;
    if Succeeded(Result) then
      FDisplay.SurfaceDataLost(1);
  end;
  if Succeeded(Result) and (FBack2 <> nil) and FBack2.Lost then
  begin
    Result := FBack2.Restore;
    if Succeeded(Result) then
      FDisplay.SurfaceDataLost(2);
  end;
end;

function TDDrawDC.FlipSurface(Index: Integer): HResult;
begin
  Result := GetSurface(Index).BltStretch(FPrimary, nil, @FPrimarySurfaceRgn);
  if Succeeded(Result) then
    Result := DCERR_NOFLIP;
end;

function TDDrawDC.BltSurface(Index: Integer): HResult;
begin
  Result := GetSurface(Index).BltStretch(FPrimary, nil, @FPrimarySurfaceRgn);
end;

function TDDrawDC.GetSurface(Index: Integer): TSurface;
begin
  case Index of
    0: Result := FPrimary;
    1: Result := FBack1;
    2: Result := FBack2;
  else
    Result := nil;
  end;
end;

function TDDrawDC.WaitForVerticalBlank: HResult;
var
  Wait, Target, T, D: Integer;
begin
  if FUseVerticalBlank then
  begin
    if DD <> nil then
    begin
      Wait := FDisplay.FFrameTime;
      if Wait <> 0 then
      begin
        Target := FLastVBTime + Wait;
        T := GetElapsedMilliSeconds;
        if T >= Target - Wait then
        begin
          D := Target - T;
          while D > 0 do
          begin
            if D > 5 then
              Sleep(0);
            T := GetElapsedMilliSeconds;
            D := Target - T;
          end;
        end;
        FLastVBTime := T;
      end;
      Result := DD.WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN, 0);
      FLastVBTime := GetElapsedMilliSeconds;
    end
    else
      Result := DCERR_NOTSUPPORTED;
  end
  else
  begin
    Wait := FDisplay.FFrameTime;
    if Wait <> 0 then
    begin
      Target := FLastVBTime + Wait;
      T := GetElapsedMilliSeconds;
      if T >= Target - Wait then
      begin
        D := Target - T;
        while D > 0 do
        begin
          if D > 5 then
            Sleep(2);
          T := GetElapsedMilliSeconds;
          D := Target - T;
        end;
      end;
      FLastVBTime := T;
    end;
    Result := 0;
  end;
end;

procedure TDDrawDC.ShowFrameRate;
var
  S: string;
  DC: HDC;
  X, Y: Integer;
begin
  if FPrimary <> nil then
  begin
    S := ' Framerate: ' + IntToStr(GetCurrentFrameRate) + ' ' + #0;
    if OutputWnd.Parent <> nil then
    begin
      X := OutputWnd.Parent.ClientOrigin.X;
      Y := OutputWnd.Parent.ClientOrigin.Y;
    end
    else
    begin
      X := OutputWnd.ClientOrigin.X;
      Y := OutputWnd.ClientOrigin.Y;
    end;
    if Succeeded(FPrimary.Surface.GetDC(DC)) then
    begin
      TextOut(DC, X, Y, @S[1], Length(S) - 1);
      FPrimary.Surface.ReleaseDC(DC);
    end;
  end;
end;

function TDDrawDC.Deactivate: HResult;
begin
  if dsActivated in GetStatus then
  begin
    DD.FlipToGDISurface;
    DD.WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN, 0);
    FBack2.Free;
    FBack2 := nil;
    FBack1.Free;
    FBack1 := nil;
    FPrimary.Free;
    FPrimary := nil;
  end;
  Result := inherited Deactivate;
end;

{ TDDrawFullScrDC }

constructor TDDrawFullScrDC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHooked := False;
  FDisplayWidth := 640;
  FDisplayHeight := 480;
  FBitDepth := 16;
  FSwitching := False;
end;

destructor TDDrawFullScrDC.Destroy;
begin
  UnHookMainWindow;
  inherited Destroy;
end;

{ Hides the display when the application is deactivated and shows it again (through a posted
  message) when it is activated. }
function TDDrawFullScrDC.MainWindowHook(var Message: TMessage): Boolean;
begin
  if (Message.Msg = WM_ACTIVATEAPP) and (dsActivated in GetStatus) and (GetDisplay <> nil) then
    if Message.WParam = 0 then
      GetDisplay.Hide
    else
      PostMessage(GetDisplay.Handle, WM_DISPLAYC, 1, 0);
  if (Message.Msg = WM_DISPLAYCHANGE) and (dsVisible in FStatus) and not FSwitching then
    GetDisplay.Hide;
  Result := False;
end;

procedure TDDrawFullScrDC.HookMainWindow;
begin
  if not FHooked then
  begin
    FHooked := True;
    Application.HookMainWindow(MainWindowHook);
  end;
end;

procedure TDDrawFullScrDC.UnHookMainWindow;
begin
  if FHooked then
  begin
    FHooked := False;
    Application.UnhookMainWindow(MainWindowHook);
  end;
end;

{ Bug kept from the original: the resolution only changes when both the width and the height
  differ from the current ones. }
function TDDrawFullScrDC.SwitchResolution(AWidth, AHeight: Integer): HResult;
begin
  if (AWidth <> FDisplayWidth) and (AHeight <> FDisplayHeight) then
  begin
    FSwitching := True;
    Result := DD.SetCooperativeLevel(GetDisplay.FFSWinControl.Handle, DDSCL_ALLOWMODEX or DDSCL_EXCLUSIVE or
      DDSCL_NOWINDOWCHANGES or DDSCL_ALLOWREBOOT or DDSCL_FULLSCREEN);
    if Succeeded(Result) then
    begin
      Result := SetDisplayMode(AWidth, AHeight, FBitDepth);
      if Succeeded(Result) then
      begin
        FDisplayWidth := AWidth;
        FDisplayHeight := AHeight;
        SetWindowPos(GetDisplay.FFSWinControl.Handle, HWND_TOPMOST, 0, 0, FDisplayWidth, FDisplayHeight,
          SWP_SHOWWINDOW);
        UpdateWindow(GetDisplay.FFSWinControl.Handle);
        if not (doAutoResizeBackSurface in GetDisplay.FOptions) then
          Result := CreateSurfaces
        else
          GetDisplay.ResizeBackSurfaces(AWidth, AHeight);
        GetDisplay.Resize;
      end;
    end;
    FSwitching := False;
  end
  else
    Result := 0;
end;

procedure TDDrawFullScrDC.HideApplicationForms;
var
  I: Integer;
begin
  for I := Screen.FormCount - 1 downto 0 do
    if Screen.Forms[I].Visible then
      SetWindowPos(Screen.Forms[I].Handle, 0, 0, 0, 0, 0, SWP_NOSENDCHANGING or SWP_NOOWNERZORDER or
        SWP_HIDEWINDOW or SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TDDrawFullScrDC.ShowApplicationForms;
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
    if Screen.Forms[I].Visible and not (csDestroying in Screen.Forms[I].ComponentState) then
      SetWindowPos(Screen.Forms[I].Handle, 0, 0, 0, 0, 0, SWP_NOSENDCHANGING or SWP_NOOWNERZORDER or
        SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

function TDDrawFullScrDC.OutputWnd: TWinControl;
begin
  Result := GetDisplay.FFSWinControl;
end;

function TDDrawFullScrDC.Handle: HWND;
begin
  Result := GetDisplay.FFSWinControl.Handle;
end;

procedure TDDrawFullScrDC.GetMousePos(var X, Y: Integer);
var
  P: TPoint;
begin
  if dsVisible in FStatus then
  begin
    GetCursorPos(P);
    X := P.X;
    Y := P.Y;
  end
  else
  begin
    X := -1;
    Y := -1;
  end;
end;

function TDDrawFullScrDC.SetDisplayMode(AWidth, AHeight, ABitDepth: Integer): HResult;
begin
  Result := DD.SetDisplayMode(AWidth, AHeight, ABitDepth, 0, 0);
end;

{ Flips to surface Index when it is attached to the primary surface (ssComplex), else blits
  it; once more after restoring lost surfaces. }
function TDDrawFullScrDC.FlipSurface(Index: Integer): HResult;
begin
  if ssComplex in TDDrawSurface(GetSurface(Index)).Status then
  begin
    repeat
    until FPrimary.Surface.GetFlipStatus(DDGFS_ISFLIPDONE) <> DDERR_WASSTILLDRAWING;
    Result := FPrimary.Surface.GetFlipStatus(DDGFS_CANFLIP);
    if Succeeded(Result) then
      Result := FPrimary.Surface.Flip(TDDrawSurface(GetSurface(Index)).Surface, 0);
  end
  else
  begin
    Result := GetSurface(Index).BltStretch(GetSurface(0), nil, GetPrimarySurfaceRgn);
    if Succeeded(Result) then
      Result := DCERR_NOFLIP;
  end;
  if Result = DDERR_SURFACELOST then
    if Succeeded(VerifyLostSurfaces) then
      if ssComplex in TDDrawSurface(GetSurface(Index)).Status then
      begin
        repeat
        until FPrimary.Surface.GetFlipStatus(DDGFS_ISFLIPDONE) <> DDERR_WASSTILLDRAWING;
        Result := FPrimary.Surface.GetFlipStatus(DDGFS_CANFLIP);
        if Succeeded(Result) then
          Result := FPrimary.Surface.Flip(TDDrawSurface(GetSurface(Index)).Surface, 0);
      end
      else
      begin
        Result := GetSurface(Index).BltStretch(GetSurface(0), nil, GetPrimarySurfaceRgn);
        if Succeeded(Result) then
          Result := DCERR_NOFLIP;
      end;
end;

{ Creates the primary surface and the back surfaces: a flipping chain in video memory when the
  back surfaces have the size of the screen (with one back buffer less when the chain cannot be
  made), else a primary surface and separate back surfaces. }
function TDDrawFullScrDC.CreateSurfaces: HResult;
var
  Primary, Back1, Back2: IDirectDrawSurface;
  Caps: TDDSCaps;
  DDSD: TDDSurfaceDesc;
begin
  Result := 0;
  FillChar(DDSD, SizeOf(DDSD), 0);
  DDSD.dwSize := SizeOf(DDSD);
  Primary := nil;
  Back1 := nil;
  Back2 := nil;
  FBack2.Free;
  FBack2 := nil;
  FBack1.Free;
  FBack1 := nil;
  FPrimary.Free;
  FPrimary := nil;
  if FUseVideoMemory then
  begin
    if (GetDisplay.FBackSurfaceWidth = FDisplayWidth) and (GetDisplay.FBackSurfaceHeight = FDisplayHeight) then
    begin
      DDSD.dwFlags := DDSD_CAPS;
      if GetDisplay.FBufferingScheme <> bsSingle then
        DDSD.dwFlags := DDSD.dwFlags or DDSD_BACKBUFFERCOUNT;
      DDSD.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE or DDSCAPS_FLIP or DDSCAPS_COMPLEX or DDSCAPS_VIDEOMEMORY;
      if FEnable3D then
        DDSD.ddsCaps.dwCaps := DDSD.ddsCaps.dwCaps or DDSCAPS_3DDEVICE;
      DDSD.dwBackBufferCount := Ord(GetDisplay.FBufferingScheme);
      Result := DD.CreateSurface(DDSD, Primary, nil);
      if Succeeded(Result) then
      begin
        FPrimary := TDDrawDCSurface.Create;
        FPrimary.SetDDSurface(Primary, [ssVideoMemory, ssPrimary, ssCreated, ssComplex]);
        Caps.dwCaps := DDSCAPS_BACKBUFFER;
        Result := Primary.GetAttachedSurface(Caps, Back1);
        if Succeeded(Result) then
        begin
          FBack1 := TDDrawDCSurface.Create;
          FBack1.SetDDSurface(Back1, [ssVideoMemory, ssCreated, ssComplex]);
        end;
        if Succeeded(Result) and (GetDisplay.FBufferingScheme = bsTripple) then
        begin
          Caps.dwCaps := DDSCAPS_FLIP;
          Result := Back1.GetAttachedSurface(Caps, Back2);
          if Result >= 0 then
          begin
            FBack2 := TDDrawDCSurface.Create;
            FBack2.SetDDSurface(Back2, [ssVideoMemory, ssCreated, ssComplex]);
          end;
        end;
      end
      else
        Result := 0;
      if Succeeded(Result) and (Primary = nil) and (GetDisplay.FBufferingScheme = bsTripple) then
      begin
        DDSD.dwBackBufferCount := 1;
        Result := DD.CreateSurface(DDSD, Primary, nil);
        if Succeeded(Result) then
        begin
          FPrimary := TDDrawDCSurface.Create;
          FPrimary.SetDDSurface(Primary, [ssVideoMemory, ssPrimary, ssCreated, ssComplex]);
          Caps.dwCaps := DDSCAPS_BACKBUFFER;
          Result := Primary.GetAttachedSurface(Caps, Back1);
          if Succeeded(Result) then
          begin
            FBack1 := TDDrawDCSurface.Create;
            FBack1.SetDDSurface(Back1, [ssVideoMemory, ssCreated, ssComplex]);
          end;
          if Succeeded(Result) then
          begin
            FBack2 := TDDrawDCSurface.Create;
            Result := FBack2.CreateSurface(GetDisplay.FBackSurfaceWidth, GetDisplay.FBackSurfaceHeight,
              FPrimary.PixelFormatID, [cfVideoMemory, cfSystemMemory]);
          end;
        end
        else
          Result := 0;
      end;
    end;
    if Succeeded(Result) and (Primary = nil) then
    begin
      DDSD.dwFlags := DDSD_CAPS;
      DDSD.dwBackBufferCount := 0;
      DDSD.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;
      if FEnable3D then
        DDSD.ddsCaps.dwCaps := DDSD.ddsCaps.dwCaps or DDSCAPS_3DDEVICE;
      Result := DD.CreateSurface(DDSD, Primary, nil);
      if Succeeded(Result) then
      begin
        FPrimary := TDDrawDCSurface.Create;
        FPrimary.SetDDSurface(Primary, [ssVideoMemory, ssPrimary, ssCreated]);
        FBack1 := TDDrawDCSurface.Create;
        Result := FBack1.CreateSurface(GetDisplay.FBackSurfaceWidth, GetDisplay.FBackSurfaceHeight,
          FPrimary.PixelFormatID, [cfVideoMemory, cfSystemMemory]);
        if Succeeded(Result) and (GetDisplay.FBufferingScheme = bsTripple) then
        begin
          FBack2 := TDDrawDCSurface.Create;
          Result := FBack2.CreateSurface(GetDisplay.FBackSurfaceWidth, GetDisplay.FBackSurfaceHeight,
            FPrimary.PixelFormatID, [cfVideoMemory, cfSystemMemory]);
        end;
      end;
    end;
  end
  else
  begin
    DDSD.dwFlags := DDSD_CAPS;
    DDSD.dwBackBufferCount := 0;
    DDSD.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;
    if FEnable3D then
      DDSD.ddsCaps.dwCaps := DDSD.ddsCaps.dwCaps or DDSCAPS_3DDEVICE;
    Result := DD.CreateSurface(DDSD, Primary, nil);
    if Succeeded(Result) then
    begin
      FPrimary := TDDrawDCSurface.Create;
      FPrimary.SetDDSurface(Primary, [ssVideoMemory, ssPrimary, ssCreated]);
      FBack1 := TDDrawDCSurface.Create;
      Result := FBack1.CreateSurface(GetDisplay.FBackSurfaceWidth, GetDisplay.FBackSurfaceHeight,
        FPrimary.PixelFormatID, [cfSystemMemory]);
      if Succeeded(Result) and (GetDisplay.FBufferingScheme = bsTripple) then
      begin
        FBack2 := TDDrawDCSurface.Create;
        Result := FBack2.CreateSurface(GetDisplay.FBackSurfaceWidth, GetDisplay.FBackSurfaceHeight,
          FPrimary.PixelFormatID, [cfSystemMemory]);
      end;
    end;
  end;
  if Failed(Result) then
  begin
    FBack2.Free;
    FBack2 := nil;
    FBack1.Free;
    FBack1 := nil;
    FPrimary.Free;
    FPrimary := nil;
  end
  else
  begin
    if FPrimary <> nil then
      FPrimary.OnSurfaceLost := SurfaceLost;
    if FBack1 <> nil then
    begin
      FBack1.OnSurfaceLost := SurfaceLost;
      FBack1.Cls(GetDisplay.Color);
    end;
    if FBack2 <> nil then
    begin
      FBack2.OnSurfaceLost := SurfaceLost;
      FBack2.Cls(GetDisplay.Color);
    end;
    DD.WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN, 0);
  end;
  Primary := nil;
  Back1 := nil;
  Back2 := nil;
end;

{ Bug kept from the original: the result of CreateSurfaces is ignored, the result is 0. }
function TDDrawFullScrDC.ResizeBackSurfaces(AWidth, AHeight: Integer): HResult;
var
  I: Integer;
begin
  Result := 0;
  InvalidateAll;
  if GetDisplay.FBufferingScheme <> bsSingle then
    if (AWidth <> FBack1.Width) or (AHeight <> FBack1.Height) then
    begin
      CreateSurfaces;
      if Assigned(GetDisplay.FOnSurfaceDataLost) then
        for I := 1 to Ord(GetDisplay.FBufferingScheme) do
          GetDisplay.FOnSurfaceDataLost(Self, I);
    end;
end;

function TDDrawFullScrDC.Hide: HResult;
begin
  if dsVisible in FStatus then
  begin
    FStatus := FStatus - [dsVisible];
    DD.FlipToGDISurface;
    ShowWindow(GetDisplay.FFSWinControl.Handle, SW_HIDE);
    Result := DD.RestoreDisplayMode;
  end
  else
    Result := 0;
end;

function TDDrawFullScrDC.Show: HResult;
begin
  if not (dsVisible in FStatus) then
  begin
    Result := DD.SetCooperativeLevel(GetDisplay.FFSWinControl.Handle, DDSCL_ALLOWMODEX or DDSCL_EXCLUSIVE or
      DDSCL_NOWINDOWCHANGES or DDSCL_ALLOWREBOOT or DDSCL_FULLSCREEN);
    if Succeeded(Result) then
    begin
      Result := SetDisplayMode(FDisplayWidth, FDisplayHeight, FBitDepth);
      if Succeeded(Result) then
      begin
        if not FDebugMode then
        begin
          SetWindowPos(GetDisplay.FFSWinControl.Handle, HWND_TOPMOST, 0, 0, FDisplayWidth, FDisplayHeight,
            SWP_SHOWWINDOW);
          UpdateWindow(GetDisplay.FFSWinControl.Handle);
        end;
        Windows.SetFocus(GetDisplay.FFSWinControl.Handle);
        VerifyLostSurfaces;
        DD.WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN, 0);
      end;
    end;
    if Succeeded(Result) then
      FStatus := FStatus + [dsVisible];
  end
  else
    Result := 0;
end;

function TDDrawFullScrDC.Activate(ADisplay: TCustomDisplay): HResult;
begin
  try
    Result := inherited Activate(ADisplay);
    if Result >= 0 then
    begin
      HideApplicationForms;
      GetDisplay.FFSWinControl.Cursor := GetDisplay.Cursor;
      FPrimarySurfaceRgn.Left := 0;
      FPrimarySurfaceRgn.Right := FDisplayWidth;
      FPrimarySurfaceRgn.Top := 0;
      FPrimarySurfaceRgn.Bottom := FDisplayHeight;
      if Succeeded(Result) then
        Result := Show;
      if Succeeded(Result) then
      begin
        if doAutoResizeBackSurface in ADisplay.FOptions then
        begin
          ADisplay.BackSurfaceWidth := FDisplayWidth;
          ADisplay.BackSurfaceHeight := FDisplayHeight;
        end;
        Result := CreateSurfaces;
      end;
      HookMainWindow;
    end;
    if Failed(Result) then
      Deactivate;
  except
    Deactivate;
    Result := DCERR_FAILED;
  end;
end;

function TDDrawFullScrDC.Deactivate: HResult;
begin
  if dsActivated in FStatus then
  begin
    Hide;
    ShowApplicationForms;
    UnHookMainWindow;
  end;
  Result := inherited Deactivate;
end;

{ TDDrawFullScr16DC }

constructor TDDrawFullScr16DC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitDepth := 16;
end;

{ A 1555 surface is drawn on as 555. }
function TDDrawFullScr16DC.CreateSurfaces: HResult;
begin
  Result := inherited CreateSurfaces;
  if Result >= 0 then
  begin
    if FPrimary.PixelFormatID = pfARGB1555 then
      FPrimary.FPixelFormatID := pfRGB555;
    if (FBack1 <> nil) and (FBack1.PixelFormatID = pfARGB1555) then
      FBack1.FPixelFormatID := pfRGB555;
    if (FBack2 <> nil) and (FBack2.PixelFormatID = pfARGB1555) then
      FBack2.FPixelFormatID := pfRGB555;
  end;
end;

{ TDDrawFullScr24DC }

constructor TDDrawFullScr24DC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitDepth := 24;
end;

{ TDDrawFullScr32DC }

constructor TDDrawFullScr32DC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitDepth := 32;
end;

{ TMatrix (DCTypes in the original) }

constructor TMatrix.Create(AWidth, AHeight: Byte);
begin
  inherited Create;
  FWidth := AWidth;
  FHeight := AHeight;
  GetMem(FData, FWidth * FHeight);
  if FData <> nil then
    FillChar(FData^, FWidth * FHeight, 0);
end;

destructor TMatrix.Destroy;
begin
  if FData <> nil then
  begin
    FreeMem(FData, FWidth * FHeight);
    FData := nil;
  end;
  inherited Destroy;
end;

{ The value at X, Y, clipped to 2. }
function TMatrix.GetVal(X, Y: Byte): Integer;
begin
  if (X < FWidth) and (Y < FHeight) then
  begin
    Result := Ord((FData + X + Y * FWidth)^);
    if Result > 2 then
      Result := 2;
  end
  else
    raise Exception.Create('TMatrix out of bounds (DCTypes)');
end;

procedure TMatrix.SetVal(X, Y: Byte; Value: Byte);
begin
  if (X < FWidth) and (Y < FHeight) then
    (FData + X + Y * FWidth)^ := Char(Value);
end;

procedure Register;
begin
  RegisterComponents('GFX Engine', [TDisplay]);
  RegisterComponents('GFX Engine', [TWindows08DC, TWindows16DC, TWindows24DC, TWindows32DC]);
  RegisterComponents('GFX Engine', [TDDrawFullScr16DC, TDDrawFullScr24DC, TDDrawFullScr32DC]);
end;

end.
