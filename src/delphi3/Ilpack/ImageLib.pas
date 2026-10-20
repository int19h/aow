unit ImageLib;

{ The ImageLib unit of Ilpack.dpl (the image library of Age of Wonders: libraries of 8 and 16
  bit pictures, sprites and masks stored in .ILB files, the controls that show them, the
  library manager and the image sequences) written for the original compiler (Delphi 3.02), class
  by class: tools/match.py compares the code DCC32 generates for every method with the code in
  the game's module. Declarations follow the original instance layouts and VMT orders
  (notes/classes.json) and the declaration order of the type information; names of private
  fields and of implementation-only routines are invented. The editor units of the package
  (ILEdGrid, SubImgEd, ImgSetEd, SImgSEd, ILEdForm) are used by Register only. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls, Grids,
  IniFiles, GFXE, HashTabU;

type
  { ImageLib.TBltMode: how BltLibraryImage fits an image into a rectangle }
  TBltMode = (bmNone, bmStretch, bmStretchToFit, bmCenter);

  TLibraryImage = class;
  TLibraryImageClass = class of TLibraryImage;

  { ImageLib.TPaletteManager (instance size 8): +4 FPalettes, the TLibraryImagePalette objects of
    a library; images of 8 bits refer to them by index. }
  TLibraryImagePalette = class;

  TPaletteManager = class(TObject)
  private
    FPalettes: TList;
    function GetCount: Integer;
    function GetPalette(Index: Integer): TLibraryImagePalette;
    procedure UpdateIndices;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure Clear;
    function LinkToPalette(Index: Integer): TLibraryImagePalette;
    function RegisterPalette(Palette: TGFXEPalette): TLibraryImagePalette;
    procedure UnregisterPalette(Index: Integer);
    property Count: Integer read GetCount;
    property Palettes[Index: Integer]: TLibraryImagePalette read GetPalette;
  end;

  { ImageLib.TLibraryImagePalette (instance size 20): +4 FIndex, +8 FPalette, +$C FRemapPalette
    (the palette remapped to a pixel format, made on demand), +$10 FRefCount. }
  TLibraryImagePalette = class(TPersistent)
  private
    FIndex: Integer;
    FPalette: TGFXEPalette;
    FRemapPalette: TGFXEPalette;
    FRefCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    function RemapPalette(PixelFormatID: Integer): TGFXEPalette;
    procedure Assign(Source: TPersistent); override;
    property Index: Integer read FIndex;
    property Palette: TGFXEPalette read FPalette;
    property RefCount: Integer read FRefCount;
  end;

  { ImageLib.TImageLibraryStatus }
  TImageLibraryStatus = set of (isLoadingFromFile, isLoading, isModified, isSaving,
    isSavingToFile);

  { An entry of TCustomImageLibrary.FImages: the image, or nil and the index of the image it
    refers to (-1 for none). }
  PImageItem = ^TImageItem;
  TImageItem = record
    Image: TLibraryImage;
    Reference: Integer;
  end;
  PImageItemArray = ^TImageItemArray;
  TImageItemArray = array[0..MaxInt div SizeOf(TImageItem) - 1] of TImageItem;

  { ImageLib.TCustomImageLibrary (instance size 80): +$24 FStatus, +$28 FOnChange, +$30
    FChangeLock (OnChange is called when it is 0), +$31 FReloading (the images can reload their
    data from FLoadedFileName), +$32 FLoadOnDemand, +$34 FLoadedFileName, +$38 FFileName (relative
    to the project or to BaseImageLibraryPath), +$3C FDataOffset (where the discardable image
    data starts in the file), +$40 FCapacity, +$44 FCount, +$48 FImages, +$4C FPaletteManager. }
  TCustomImageLibrary = class(TComponent)
  private
    FStatus: TImageLibraryStatus;
    FOnChange: TNotifyEvent;
    FChangeLock: Byte;
    FReloading: Boolean;
    FLoadOnDemand: Boolean;
    FLoadedFileName: string;
    FFileName: string;
    FDataOffset: Integer;
    FCapacity: Integer;
    FCount: Integer;
    FImages: PImageItemArray;
    FPaletteManager: TPaletteManager;
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(Value: Integer);
    function GetFullFileName: string;
    procedure SetFileName(Value: string);
    procedure DeleteItem(Index: Integer);
    procedure InsertItem(Index: Integer);
    procedure SetLoadOnDemand(Value: Boolean);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetModified: Boolean; virtual;
    procedure SetModified(Value: Boolean); virtual;
    procedure Clear; virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromFile(const AFileName: string); virtual;
    procedure SaveToFile(const AFileName: string); virtual;
    procedure CallOnChangeEvent; virtual;
    function Copy: TCustomImageLibrary; virtual;
    function ReduceCount: Integer;
    procedure UpdateImageItemSettings(Index: Integer);
    procedure DisableOnChangeEvent;
    procedure EnableOnChangeEvent;
    procedure DisableReloading;
    procedure ReleaseDiscardableImageData;
    procedure LoadDiscardableImageData;
    function IsReference(Index: Integer): Boolean;
    function Get(Index: Integer): TLibraryImage;
    function GetSafe(Index: Integer): TLibraryImage;
    function ImageExist(Index: Integer): Boolean;
    function GetImageReference(Index: Integer): Integer;
    procedure SetImageReference(Index, Value: Integer);
    procedure LoadFromFileStream(const AFileName: string; Stream: TStream);
    procedure CopyToClipboard;
    procedure PasteFromClipboard;
    procedure Assign(Source: TPersistent); override;
    procedure Delete(Index: Integer);
    function Remove(Image: TLibraryImage): Integer;
    function IndexOf(Image: TLibraryImage): Integer;
    function GetImage(Index: Integer): TLibraryImage;
    procedure SetImage(Index: Integer; Image: TLibraryImage);
    procedure Insert(Index: Integer; Image: TLibraryImage);
    procedure Add(Image: TLibraryImage);
    function Empty: Boolean;
    procedure Pack;
    function GetSubCount(Index: Integer): Integer;
    function GetSub(Index, SubIndex: Integer): TLibraryImage;
    function GetSafeSub(Index, SubIndex: Integer): TLibraryImage;
    function GetSubImage(Index, SubIndex: Integer): TLibraryImage;
    procedure SetSubImage(Index, SubIndex: Integer; Image: TLibraryImage);
    procedure DeleteSub(Index, SubIndex: Integer);
    function RemoveSub(Index: Integer; Image: TLibraryImage): Integer;
    function IndexOfSub(Index: Integer; Image: TLibraryImage): Integer;
    procedure InsertSub(Index, SubIndex: Integer; Image: TLibraryImage);
    procedure AddSub(Index: Integer; Image: TLibraryImage);
    function SubImageExist(Index, SubIndex: Integer): Boolean;
    property Count: Integer read FCount write SetCount;
    property Images[Index: Integer]: TLibraryImage read Get; default;
    property Modified: Boolean read GetModified write SetModified;
    property Status: TImageLibraryStatus read FStatus;
    property PaletteManager: TPaletteManager read FPaletteManager;
    property FullFileName: string read GetFullFileName;
    property LoadedFileName: string read FLoadedFileName;
    property DataOffset: Integer read FDataOffset;
    property Reloading: Boolean read FReloading;
    property LoadOnDemand: Boolean read FLoadOnDemand write SetLoadOnDemand;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property FileName: string read FFileName write SetFileName;
  end;

  { ImageLib.TImageLibrary (instance size 80): the image library component }
  TImageLibrary = class(TCustomImageLibrary)
  published
    property LoadOnDemand;
    property OnChange;
    property FileName;
  end;

  { ImageLib.TLoadMode: when an image loads its discardable data (the pixels) }
  TLoadMode = (lmLoadAlways, lmLoadOnDemand, lmLoadFreeOnDemand);

  { ImageLib.TGrabInfo (instance size 24): how images are grabbed from a surface. +4
    FTransparentColor, +8 FFindRectangles (grab every rectangle GetSurfaceRectangles finds),
    +$C FTransparentPixel (the pixel value of the transparent color), +$10 FFileName (the file grabbed from), +$14 FFileIndex. VMT: LoadFromStream,
    SaveToStream, GrabInfoClass, Copy. }
  TGrabInfo = class;
  TGrabInfoClass = class of TGrabInfo;

  TGrabInfo = class(TObject)
  public
    TransparentColor: Integer;
    FindRectangles: Boolean;
    TransparentPixel: Integer;
    FileName: string;
    FileIndex: Integer;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    function GrabInfoClass: TGrabInfoClass; virtual;
    function Copy: TGrabInfo; virtual;
  end;

  TImagesGrabbedEvent = procedure(GrabbedImages: TCustomImageLibrary; UsedGrabInfo: TGrabInfo) of object;

  { The progress event of TLibraryImage.GrabImages }
  TGrabProgressEvent = procedure(Sender: TObject; Percent: Integer; const Msg: string) of object;

  { ImageLib.TShowMode, ImageLib.TBlendMode }
  TShowMode = (smOpaque, smTransparent, smBlended);
  TBlendMode = (bmUser, bmAlpha, bmBrighten, bmIntensity, bmShadow, bmLinearAlpha);

  { How an image is shown (8 bytes): the blend value is a percentage into the blend table
    collection of the blend mode, or the blend table itself for bmUser. }
  TShowInfo = record
    ShowMode: TShowMode;
    BlendMode: TBlendMode;
    case Integer of
      0: (BlendPercentage: Integer);
      1: (BlendTable: TBlendTable);
  end;

  { ImageLib.TLibraryImage (instance size 64): an image of an image library. +4 FOwner, +8
    FDataLoaded (the discardable data, the pixels, are in memory), +$C FDataPosition (of the
    discardable data in the library file, -1 for none), +$10 FDataSize, +$14 FReloadingEnabled,
    +$15 FVersion, +$16 FLoadMode, +$18 FDataWidth, +$1C FDataHeight (of the pixels), +$20
    FWidth, +$24 FHeight (the visual size), +$28 FXshift, +$2C FYshift (of the pixels in the
    visual rectangle), +$30 FFileName, +$34 FFileIndex (where the image was grabbed), +$38
    FShowInfo. }
  TLibraryImage = class(TPersistent)
  private
    FOwner: TCustomImageLibrary;
    FDataLoaded: Boolean;
    FDataPosition: Integer;
    FDataSize: Integer;
    FReloadingEnabled: Boolean;
    FVersion: Byte;
    FLoadMode: TLoadMode;
    FDataWidth: Integer;
    FDataHeight: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FXshift: Integer;
    FYshift: Integer;
    FFileName: string;
    FFileIndex: Integer;
    FShowInfo: TShowInfo;
  public
    procedure SetOwner(AOwner: TCustomImageLibrary); virtual;
    procedure SetLoadMode(Value: TLoadMode); virtual;
    function GetPalette: TGFXEPalette; virtual;
    function GetRemapPalette: TGFXEPalette; virtual;
    function GetTransparent: Boolean; virtual;
    procedure SetReloadingEnabled(Value: Boolean); virtual;
    procedure SetDefaultShowInfo(Value: TShowInfo); virtual;
    procedure SetXshift(Value: Integer); virtual;
    procedure SetYshift(Value: Integer); virtual;
    procedure SetWidth(Value: Integer); virtual;
    procedure SetHeight(Value: Integer); virtual;
    procedure GetVisualDimensions(var R: TRect); virtual;
    procedure ReadImageData(Stream: TStream); virtual;
    procedure WriteImageData(Stream: TStream); virtual;
    procedure ReadDiscardableImageData(Stream: TStream); virtual;
    procedure WriteDiscardableImageData(Stream: TStream); virtual;
    procedure ReleaseDiscardableImageData; virtual;
    procedure LoadDiscardableImageData; virtual;
    procedure SaveToStreamEx(Stream, DataStream: TStream); virtual;
    procedure LoadFromStreamEx(Stream, DataStream: TStream); virtual;
    function RemapToPixelFormat(PixelFormatID: Integer): HResult; virtual;
    procedure Clear; virtual;
    constructor Create(AOwner: TCustomImageLibrary); virtual;
    class function ClassID: Integer; virtual;
    class function Name: string; virtual;
    class function ClassVersion: Byte; virtual;
    function Info: string; virtual;
    function Copy: TLibraryImage; virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure Show(X, Y: Integer; const SD: TSurfaceDesc); virtual;
    procedure ShowStretched(const R: TRect; const SD: TSurfaceDesc); virtual;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); virtual;
    procedure ShowOpaqueStretched(const R: TRect; const SD: TSurfaceDesc); virtual;
    procedure ShowBlended(X, Y: Integer; const SD: TSurfaceDesc; Table: TBlendTable); virtual;
    procedure ShowBlendedStretched(const R: TRect; const SD: TSurfaceDesc; Table: TBlendTable); virtual;
    procedure ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc); virtual;
    procedure ShowEx(X, Y: Integer; const SD: TSurfaceDesc; const ShowInfo: TShowInfo); virtual;
    procedure ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor); virtual;
    function SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean; virtual;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; virtual;
    function CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
      OnImagesGrabbed: TImagesGrabbedEvent): TForm; virtual;
    function GrabImage(const SD: TSurfaceDesc; const R: TRect; GrabInfo: TGrabInfo): Boolean; virtual;
    class function GrabImages(const SD: TSurfaceDesc; GrabInfo: TGrabInfo;
      ImageLibrary: TCustomImageLibrary; OnProgress: TGrabProgressEvent): HResult; virtual;
    function CreateGrabInfo: TGrabInfo; virtual;
    destructor Destroy; override;
    procedure GetDimensions(var R: TRect);
    procedure ShowClipped(X, Y: Integer; const SD: TSurfaceDesc);
    property Owner: TCustomImageLibrary read FOwner write SetOwner;
    property DataLoaded: Boolean read FDataLoaded;
    property DataPosition: Integer read FDataPosition;
    property DataSize: Integer read FDataSize;
    property ReloadingEnabled: Boolean read FReloadingEnabled write SetReloadingEnabled;
    property Version: Byte read FVersion;
    property LoadMode: TLoadMode read FLoadMode write SetLoadMode;
    property DataWidth: Integer read FDataWidth;
    property DataHeight: Integer read FDataHeight;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Xshift: Integer read FXshift write SetXshift;
    property Yshift: Integer read FYshift write SetYshift;
    property FileName: string read FFileName write FFileName;
    property FileIndex: Integer read FFileIndex write FFileIndex;
    property ShowInfo: TShowInfo read FShowInfo write SetDefaultShowInfo;
    property Palette: TGFXEPalette read GetPalette;
    property RemapPalette: TGFXEPalette read GetRemapPalette;
    property Transparent: Boolean read GetTransparent;
  end;

  { ImageLib.TImageNode (instance size 76): an image made of several images (ClassID $100).
    +$40 FImages, +$44 FCapacity, +$48 FCount. Its Width and Height are the largest of the
    images. }
  PLibraryImageArray = ^TLibraryImageArray;
  TLibraryImageArray = array[0..MaxInt div 4 - 1] of TLibraryImage;

  TImageNode = class(TLibraryImage)
  private
    FImages: PLibraryImageArray;
    FCapacity: Integer;
    FCount: Integer;
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  public
    constructor Create(AOwner: TCustomImageLibrary); override;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    class function Name: string; override;
    function Info: string; override;
    function GetImage(Index: Integer): TLibraryImage;
    function GetSafeImage(Index: Integer): TLibraryImage;
    procedure UpdateDimensions;
    function Add(Image: TLibraryImage): Integer;
    procedure Insert(Index: Integer; Image: TLibraryImage);
    procedure Remove(Image: TLibraryImage);
    function IndexOf(Image: TLibraryImage): Integer;
    procedure Delete(Index: Integer);
    procedure SaveToStreamEx(Stream, DataStream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromStreamEx(Stream, DataStream: TStream); override;
    procedure Clear; override;
    procedure SetReloadingEnabled(Value: Boolean); override;
    procedure SetOwner(AOwner: TCustomImageLibrary); override;
    function RemapToPixelFormat(PixelFormatID: Integer): HResult; override;
    procedure Show(X, Y: Integer; const SD: TSurfaceDesc); override;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); override;
    procedure ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc); override;
    procedure ShowBlended(X, Y: Integer; const SD: TSurfaceDesc; Table: TBlendTable); override;
    procedure ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor); override;
    procedure ShowEx(X, Y: Integer; const SD: TSurfaceDesc; const ShowInfo: TShowInfo); override;
    function SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean; override;
    procedure SetLoadMode(Value: TLoadMode); override;
    procedure ReleaseDiscardableImageData; override;
    procedure LoadDiscardableImageData; override;
    property Count: Integer read FCount;
    property Images[Index: Integer]: TLibraryImage read GetImage; default;
  end;

  { ImageLib.TImage08 (instance size 76): the base of the 8 bit images. +$40 FOwnPalette (the
    image owns FImagePalette; otherwise it is shared through the palette manager of the
    library), +$44 FImagePalette, +$48 FRemapPalette (the palette the pixels are shown with:
    the image palette, or the copy remapped to the pixel format of the last surface). VMT: adds
    RegisterPalette (share the palette through the owner's palette manager) and
    UnregisterPalette (make a private copy again). }
  TImage08 = class(TLibraryImage)
  private
    FOwnPalette: Boolean;
    FImagePalette: TLibraryImagePalette;
    FRemapPalette: TGFXEPalette;
  public
    procedure Clear; override;
    procedure ReadImageData(Stream: TStream); override;
    procedure WriteImageData(Stream: TStream); override;
    procedure RegisterPalette; virtual;
    procedure UnregisterPalette; virtual;
    procedure CreateLibraryImagePalette(Palette: TGFXEPalette);
    procedure SetOwner(AOwner: TCustomImageLibrary); override;
    function RemapToPixelFormat(PixelFormatID: Integer): HResult; override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
    procedure ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor); override;
  end;

  { ImageLib.TPicture08 (instance size 88): an opaque 8 bit picture (ClassID 1). +$4C FPitch (of
    the rows: a multiple of 4 below 32 pixels, of 8 from 32 on), +$50 FBuffer (the allocated
    block), +$54 FBits (FBuffer aligned to 8 bytes). }
  TPicture08 = class(TImage08)
  private
    FPitch: Integer;
    FBuffer: Pointer;
    FBits: Pointer;
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure SetXshift(Value: Integer); override;
    procedure SetYshift(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure SetHeight(Value: Integer); override;
    function SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean; override;
    procedure AllocateDiscardableImageData(AWidth, AHeight: Integer);
    procedure ReleaseDiscardableImageData; override;
    procedure ReadDiscardableImageData(Stream: TStream); override;
    procedure WriteDiscardableImageData(Stream: TStream); override;
    function CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
      OnImagesGrabbed: TImagesGrabbedEvent): TForm; override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
    function GrabImage(const SD: TSurfaceDesc; const R: TRect; GrabInfo: TGrabInfo): Boolean; override;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); override;
  end;

  { ImageLib.TRLESprite08 (instance size 104): an 8 bit sprite, run length encoded (ClassID 2).
    +$4C FTransparentColor (the palette index of the transparent pixels), +$50 FReserved (only
    stored), +$54 FData (the encoded rows: per row a length dword, then the opaque pixels and,
    for a transparent run, the transparent index and the run length), +$58 FRLELeft, +$5C
    FRLETop, +$60 FRLEWidth, +$64 FRLEHeight (the rectangle of the encoded pixels in the data
    rectangle). }
  TRLESprite08 = class(TImage08)
  private
    FTransparentColor: Integer;
    FReserved: Integer;
    FData: Pointer;
    FRLELeft: Integer;
    FRLETop: Integer;
    FRLEWidth: Integer;
    FRLEHeight: Integer;
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure ReleaseDiscardableImageData; override;
    procedure SetXshift(Value: Integer); override;
    procedure SetYshift(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure SetHeight(Value: Integer); override;
    procedure GetVisualDimensions(var R: TRect); override;
    procedure ReadImageData(Stream: TStream); override;
    procedure WriteImageData(Stream: TStream); override;
    procedure ReadDiscardableImageData(Stream: TStream); override;
    procedure WriteDiscardableImageData(Stream: TStream); override;
    function SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean; override;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
    function CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
      OnImagesGrabbed: TImagesGrabbedEvent): TForm; override;
    function GrabImage(const SD: TSurfaceDesc; const R: TRect; GrabInfo: TGrabInfo): Boolean; override;
  end;

  { ImageLib.TImage16 (instance size 72): the base of the 16 bit images (pfRGB565 or pfRGB555).
    +$40 FPixelFormatID (of the pixels in memory), +$44 FStoredPixelFormatID (of the pixels in
    the library file: WriteImageData remaps the pixels back to it before they are written). }
  TImage16 = class(TLibraryImage)
  private
    FPixelFormatID: Integer;
    FStoredPixelFormatID: Integer;
  public
    constructor Create(AOwner: TCustomImageLibrary); override;
    procedure ReadImageData(Stream: TStream); override;
    procedure WriteImageData(Stream: TStream); override;
    procedure ReadDiscardableImageData(Stream: TStream); override;
    procedure WriteDiscardableImageData(Stream: TStream); override;
    procedure ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor); override;

  end;

  { ImageLib.TPicture16 (instance size 84, ClassID $10): an opaque 16 bit picture. +$48 FPitch
    (bytes per row, a multiple of 4, or of 8 from 32 pixels on), +$4C FBuffer (the allocated
    memory), +$50 FData (FBuffer aligned to 8 bytes). }
  TPicture16 = class(TImage16)
  private
    FPitch: Integer;
    FBuffer: Pointer;
    FData: Pointer;
    procedure AllocateDiscardableImageData(AWidth, AHeight: Integer);
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure SetXshift(Value: Integer); override;
    procedure SetYshift(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure SetHeight(Value: Integer); override;
    function SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean; override;
    procedure ReleaseDiscardableImageData; override;
    procedure ReadDiscardableImageData(Stream: TStream); override;
    procedure WriteDiscardableImageData(Stream: TStream); override;
    function CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
      OnImagesGrabbed: TImagesGrabbedEvent): TForm; override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
    function GrabImage(const SD: TSurfaceDesc; const R: TRect; GrabInfo: TGrabInfo): Boolean; override;
    function RemapToPixelFormat(PixelFormatID: Integer): HResult; override;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); override;
    procedure ShowBlended(X, Y: Integer; const SD: TSurfaceDesc; Table: TBlendTable); override;
    procedure ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc); override;
    procedure ShowOpaqueStretched(const R: TRect; const SD: TSurfaceDesc); override;
    procedure ShowBlendedStretched(const R: TRect; const SD: TSurfaceDesc; Table: TBlendTable); override;
  end;

  { ImageLib.TTransparentPicture16 (instance size 84, ClassID $15): a TPicture16 shown
    transparent by default; it cannot be grabbed. }
  TTransparentPicture16 = class(TPicture16)
  public
    constructor Create(AOwner: TCustomImageLibrary); override;
    class function ClassID: Integer; override;
    class function Name: string; override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
  end;

  { ImageLib.TSprite16 (instance size 108, ClassID $16): a 16 bit picture with a transparent
    color, cut to the smallest rectangle holding its opaque pixels. +$48 FPitch, +$4C FBuffer,
    +$50 FData (as TPicture16), +$54 FTransparentColor (in FStoredPixelFormatID), +$58 FColorKey
    (the transparent color in FPixelFormatID), +$5C FSpriteX, +$60 FSpriteY (of the pixels in the
    grabbed rectangle), +$64 FSpriteWidth, +$68 FSpriteHeight (of the pixels). }
  TSprite16 = class(TImage16)
  private
    FPitch: Integer;
    FBuffer: Pointer;
    FData: Pointer;
    FTransparentColor: Integer;
    FColorKey: Integer;
    FSpriteX: Integer;
    FSpriteY: Integer;
    FSpriteWidth: Integer;
    FSpriteHeight: Integer;
    procedure AllocateDiscardableImageData(AWidth, AHeight: Integer);
  public
    constructor Create(AOwner: TCustomImageLibrary); override;
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure SetXshift(Value: Integer); override;
    procedure SetYshift(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure SetHeight(Value: Integer); override;
    procedure GetVisualDimensions(var R: TRect); override;
    procedure ReleaseDiscardableImageData; override;
    procedure ReadImageData(Stream: TStream); override;
    procedure WriteImageData(Stream: TStream); override;
    procedure ReadDiscardableImageData(Stream: TStream); override;
    procedure WriteDiscardableImageData(Stream: TStream); override;
    function RemapToPixelFormat(PixelFormatID: Integer): HResult; override;
    function SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean; override;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); override;
    procedure ShowBlended(X, Y: Integer; const SD: TSurfaceDesc; Table: TBlendTable); override;
    procedure ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc); override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
    function CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
      OnImagesGrabbed: TImagesGrabbedEvent): TForm; override;
    function GrabImage(const SD: TSurfaceDesc; const R: TRect; GrabInfo: TGrabInfo): Boolean; override;
  end;

  { ImageLib.TRLESprite16 (instance size 96, ClassID $11): a run length encoded 16 bit sprite.
    +$48 FColorKey (the transparent color, in FPixelFormatID), +$4C FData (FDataSize bytes),
    +$50 FSpriteX, +$54 FSpriteY, +$58 FSpriteWidth, +$5C FSpriteHeight (as TSprite16). The data
    is FSpriteHeight rows; a row is a word with its size in bytes (the header included), a zero
    word, then pixels and skips (the color key and the size of the skip in bytes), padded with the
    color key to a dword. }
  TRLESprite16 = class(TImage16)
  private
    FColorKey: Integer;
    FData: Pointer;
    FSpriteX: Integer;
    FSpriteY: Integer;
    FSpriteWidth: Integer;
    FSpriteHeight: Integer;
  public
    constructor Create(AOwner: TCustomImageLibrary); override;
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure SetXshift(Value: Integer); override;
    procedure SetYshift(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure SetHeight(Value: Integer); override;
    procedure GetVisualDimensions(var R: TRect); override;
    procedure ReleaseDiscardableImageData; override;
    procedure ReadImageData(Stream: TStream); override;
    procedure WriteImageData(Stream: TStream); override;
    procedure ReadDiscardableImageData(Stream: TStream); override;
    procedure WriteDiscardableImageData(Stream: TStream); override;
    function RemapToPixelFormat(PixelFormatID: Integer): HResult; override;
    function SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean; override;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); override;
    procedure ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc); override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
    function CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
      OnImagesGrabbed: TImagesGrabbedEvent): TForm; override;
    function GrabImage(const SD: TSurfaceDesc; const R: TRect; GrabInfo: TGrabInfo): Boolean; override;
  end;

  { ImageLib.TTransparentRLESprite16 (instance size 96, ClassID $12): a TRLESprite16 shown
    transparent by default; it cannot be grabbed. }
  TTransparentRLESprite16 = class(TRLESprite16)
  public
    constructor Create(AOwner: TCustomImageLibrary); override;
    class function ClassID: Integer; override;
    class function Name: string; override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
  end;

  { ImageLib.TBitMaskGrabInfo (instance size 28): +$18 Inverse (grab the non-transparent
    rectangle with MinimizeInvTransparentRect). }
  TBitMaskGrabInfo = class(TGrabInfo)
  public
    Inverse: Boolean;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    function GrabInfoClass: TGrabInfoClass; override;
  end;

  { ImageLib.TBitMask (instance size 88): a mask of one bit per pixel (ClassID $13), shown as
    white pixels. +$40 FPitch (bytes per row, whole dwords), +$44 FMaskData (rows of dwords, the
    first pixel in the high bit), +$48 FMaskLeft, +$4C FMaskTop, +$50 FMaskWidth, +$54
    FMaskHeight (the rectangle of the mask in the data rectangle). }
  TBitMask = class(TLibraryImage)
  private
    FPitch: Integer;
    FMaskData: Pointer;
    FMaskLeft: Integer;
    FMaskTop: Integer;
    FMaskWidth: Integer;
    FMaskHeight: Integer;
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure SetXshift(Value: Integer); override;
    procedure SetYshift(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure SetHeight(Value: Integer); override;
    procedure ReadImageData(Stream: TStream); override;
    procedure WriteImageData(Stream: TStream); override;
    procedure AllocateMaskData(AWidth, AHeight: Integer);
    procedure ReleaseDiscardableImageData; override;
    procedure ReadDiscardableImageData(Stream: TStream); override;
    procedure WriteDiscardableImageData(Stream: TStream); override;
    function SupportGrabPixelFormat(PixelFormatID: Integer): Boolean; override;
    function CreateGrabInfo: TGrabInfo; override;
    function CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
      OnImagesGrabbed: TImagesGrabbedEvent): TForm; override;
    function GrabImage(const SD: TSurfaceDesc; const R: TRect; GrabInfo: TGrabInfo): Boolean; override;
    procedure ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor); override;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); override;
  end;

  { ImageLib.TShadow (instance size 88): a bit mask shown as a shadow, darkening the 16 bit
    surface under the set bits (ClassID $14). }
  TShadow = class(TBitMask)
  public
    constructor Create(AOwner: TCustomImageLibrary); override;
    function SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean; override;
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc); override;
  end;

  { ImageLib.TSetTextMode: how TImageLibraryFont.SetTextEx places the text (stmCenter: X is the
    centre of the text) }
  TSetTextMode = set of (stmCenter);

  { ImageLib.TImageLibraryFont (instance size 100): an image library whose image N is the
    character with code N. +$50 FCharacterDistance (pixels between two characters), +$54
    FHeight (the largest image height, set by LoadFromStream), +$58 FCharCase, +$5C FColor,
    +$60 FFontColorPaletteIndex (the entry of the first palette that SetColor sets to Color, -1
    for none). A character without an image is 5 pixels wide. }
  TImageLibraryFont = class(TCustomImageLibrary)
  private
    FCharacterDistance: Integer;
    FHeight: Integer;
    FCharCase: TEditCharCase;
    FColor: TColor;
    FFontColorPaletteIndex: Integer;
    procedure SetFontColorPaletteIndex(Value: Integer);
    procedure SetColor(Value: TColor);
    function TextWidth(const S: string): Integer;
    procedure ShowText(X, Y: Integer; const S: string; const SD: TSurfaceDesc);
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadFromStream(Stream: TStream); override;
    function GetTextWidth(const Text: string): Integer;
    function GetTextHeight(const Text: string): Integer;
    procedure SetText(X, Y: Integer; const Text: string; const SD: TSurfaceDesc);
    procedure SetTextCentered(X, Y: Integer; const Text: string; const SD: TSurfaceDesc);
    procedure SetTextEx(X, Y: Integer; const Text: string; const SD: TSurfaceDesc;
      Mode: TSetTextMode; const ShowInfo: TShowInfo);
    property Height: Integer read FHeight;
  published
    property CharacterDistance: Integer read FCharacterDistance write FCharacterDistance;
    property CharCase: TEditCharCase read FCharCase write FCharCase;
    property Color: TColor read FColor write SetColor;
    property FontColorPaletteIndex: Integer read FFontColorPaletteIndex write SetFontColorPaletteIndex;
    property LoadOnDemand;
    property OnChange;
    property FileName;
  end;

{ Splits Text into lines no wider than MaxWidth pixels in Font, at spaces and line breaks, and
  adds them to Strings. }
  { ImageLib.TCustomImageLibraryPanel (instance size 340): a panel that shows one image of an
    image library with BltLibraryImage. +$138 FScaleX, +$13C FScaleY (percent), +$140 FBltMode,
    +$144 FOnUpdated (called after every Paint), +$14C FImageLibrary, +$150 FImageIndex. }
  TCustomImageLibraryPanel = class(TCustomPanel)
  private
    FScaleX: Integer;
    FScaleY: Integer;
    FBltMode: TBltMode;
    FOnUpdated: TNotifyEvent;
    FImageLibrary: TCustomImageLibrary;
    FImageIndex: Integer;
    procedure SetBltMode(Value: TBltMode);
    procedure SetScaleX(Value: Integer);
    procedure SetScaleY(Value: Integer);
    procedure SetImageIndex(Value: Integer);
    procedure SetImageLibrary(Value: TCustomImageLibrary);
  protected
    procedure Paint; override;
    property ImageLibrary: TCustomImageLibrary read FImageLibrary write SetImageLibrary;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property BltMode: TBltMode read FBltMode write SetBltMode;
    property OnUpdated: TNotifyEvent read FOnUpdated write FOnUpdated;
    property ScaleX: Integer read FScaleX write SetScaleX;
    property ScaleY: Integer read FScaleY write SetScaleY;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { ImageLib.TImageLibraryPanel (instance size 340) }
  TImageLibraryPanel = class(TCustomImageLibraryPanel)
  published
    property BevelInner;
    property BevelOuter;
    property ImageLibrary;
    property ImageIndex;
    property BltMode;
    property OnUpdated;
    property ScaleX;
    property ScaleY;
    property Color;
  end;

  { ImageLib.TILGridEditMode: the edit operations a TCustomImageLibraryGrid allows }
  TILGridEditMode = set of (igCut, igCopy, igPaste, igDelete, igIns, igDel);

  { ImageLib.TILGrowDirection: which dimension UpdateDimensions grows to hold Count cells }
  TILGrowDirection = (ilNone, ilHorizontal, ilVertical);

  { ImageLib.TCustomImageDrawGrid (instance size 476): a grid of Count image cells. +$1A0
    FScaleX, +$1A4 FScaleY, +$1A8 FBltMode, +$1A9 FEditMode, +$1AC FOnCellUpdated (draws a cell
    at run time), +$1B4 FOnSelectCell, +$1BC FFocusColor, +$1C0 FGrowDirection, +$1C1
    FSelectionEnabled, +$1C4 FMinRowCount, +$1C8 FMinColCount, +$1CC FMaxRowCount, +$1D0
    FMaxColCount (0 for no limit), +$1D4 FShowGridIndex, +$1D8 FCount. Ctrl+X/C/V/Del call the
    edit methods, Ins and Del without a modifier InsCell and DelCell; they do nothing here. }
  TCustomImageDrawGrid = class(TCustomGrid)
  private
    FScaleX: Integer;
    FScaleY: Integer;
    FBltMode: TBltMode;
    FEditMode: TILGridEditMode;
    FOnCellUpdated: TDrawCellEvent;
    FOnSelectCell: TSelectCellEvent;
    FFocusColor: TColor;
    FGrowDirection: TILGrowDirection;
    FSelectionEnabled: Boolean;
    FMinRowCount: Integer;
    FMinColCount: Integer;
    FMaxRowCount: Integer;
    FMaxColCount: Integer;
    FShowGridIndex: Boolean;
    FCount: Integer;
    procedure SetBltMode(Value: TBltMode);
    procedure SetSelectionEnabled(Value: Boolean);
    procedure SetFocusColor(Value: TColor);
    procedure SetScaleX(Value: Integer);
    procedure SetScaleY(Value: Integer);
    procedure SetShowGridIndex(Value: Boolean);
    function GetColCount: Integer;
    procedure SetColCount(Value: Integer);
    procedure SetMinRowCount(Value: Integer);
    procedure SetMinColCount(Value: Integer);
    procedure SetMaxRowCount(Value: Integer);
    procedure SetMaxColCount(Value: Integer);
    function GetRowCount: Integer;
    procedure SetRowCount(Value: Integer);
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    property SelectionEnabled: Boolean read FSelectionEnabled write SetSelectionEnabled;
    property FocusColor: TColor read FFocusColor write SetFocusColor;
    property BltMode: TBltMode read FBltMode write SetBltMode;
    property OnCellUpdated: TDrawCellEvent read FOnCellUpdated write FOnCellUpdated;
    property OnSelectCell: TSelectCellEvent read FOnSelectCell write FOnSelectCell;
    property ScaleX: Integer read FScaleX write SetScaleX;
    property ScaleY: Integer read FScaleY write SetScaleY;
    property ColCount: Integer read GetColCount write SetColCount;
    property RowCount: Integer read GetRowCount write SetRowCount;
    property EditMode: TILGridEditMode read FEditMode write FEditMode;
    property GrowDirection: TILGrowDirection read FGrowDirection write FGrowDirection;
    property MinRowCount: Integer read FMinRowCount write SetMinRowCount;
    property MinColCount: Integer read FMinColCount write SetMinColCount;
    property MaxRowCount: Integer read FMaxRowCount write SetMaxRowCount;
    property MaxColCount: Integer read FMaxColCount write SetMaxColCount;
    property ShowGridIndex: Boolean read FShowGridIndex write SetShowGridIndex;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetCount(Value: Integer); virtual;
    procedure UpdateDimensions; virtual;
    procedure CutCell; virtual;
    procedure CopyCell; virtual;
    procedure DeleteCell; virtual;
    procedure PasteCell; virtual;
    procedure InsCell; virtual;
    procedure DelCell; virtual;
    function ImageIndex(ACol, ARow: Integer): Integer; virtual;
    procedure IndexToCell(Index: Integer; var ACol, ARow: Integer); virtual;
    procedure SelectIndex(Index: Integer);
    property Count: Integer read FCount write SetCount;
  end;

  { ImageLib.TImageDrawGrid (instance size 476) }
  TImageDrawGrid = class(TCustomImageDrawGrid)
  published
    property SelectionEnabled;
    property FocusColor;
    property Align;
    property BltMode;
    property OnCellUpdated;
    property ScaleX;
    property ScaleY;
    property Color;
    property ScrollBars;
    property DefaultRowHeight;
    property DefaultColWidth;
    property GridLineWidth;
    property ColCount;
    property RowCount;
    property PopupMenu;
    property EditMode;
    property Options;
    property GrowDirection;
    property MinRowCount;
    property MinColCount;
    property MaxRowCount;
    property MaxColCount;
    property ShowGridIndex;
    property Font;
  end;

  { ImageLib.TCustomImageLibraryGrid (instance size 480): a grid of the images of an image
    library, +$1DC FImageLibrary. The edit methods work on the selected cells, through the
    clipboard format of TCustomImageLibrary, when EditMode allows them. }
  TCustomImageLibraryGrid = class(TCustomImageDrawGrid)
  private
    FImageLibrary: TCustomImageLibrary;
    procedure SetImageLibrary(Value: TCustomImageLibrary);
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    property ImageLibrary: TCustomImageLibrary read FImageLibrary write SetImageLibrary;
  public
    function CreateSelectedIL: TCustomImageLibrary;
    procedure InsCell; override;
    procedure DelCell; override;
    procedure CutCell; override;
    procedure CopyCell; override;
    procedure DeleteCell; override;
    procedure PasteCell; override;
  end;

  { ImageLib.TImageLibraryGrid (instance size 480) }
  TImageLibraryGrid = class(TCustomImageLibraryGrid)
  published
    property SelectionEnabled;
    property FocusColor;
    property Align;
    property ImageLibrary;
    property BltMode;
    property OnCellUpdated;
    property ScaleX;
    property ScaleY;
    property Color;
    property ScrollBars;
    property DefaultRowHeight;
    property DefaultColWidth;
    property GridLineWidth;
    property ColCount;
    property RowCount;
    property PopupMenu;
    property EditMode;
    property Options;
    property GrowDirection;
    property MinRowCount;
    property MinColCount;
    property MaxRowCount;
    property MaxColCount;
    property ShowGridIndex;
    property Font;
  end;

  { ImageLib.TILManagerCategory: the lists of a TImageLibraryManager (icDisk: the .ILB files
    ExecutePathSearch found; icOwned: the libraries the manager owns and streams) }
  TILManagerCategory = set of (icDisk, icOwned);

  { ImageLib.TILManagerOptions }
  TILManagerOptions = set of (ioAutoSearchPath);

  TImageLibraryManager = class;

  { ImageLib.TILManagerObject (instance size 12): an entry of a TILManagerList. +4 FRefCount
    (the LinkToIL calls not yet released), +8 FImageLibrary (loaded by the first LinkToIL). }
  TILManagerObject = class(TObject)
  private
    FRefCount: Integer;
    FImageLibrary: TCustomImageLibrary;
  public
    property RefCount: Integer read FRefCount;
    property ImageLibrary: TCustomImageLibrary read FImageLibrary;
  end;

  { ImageLib.TILManagerList (instance size 52): library file names (upper case, relative to the
    search path) with their TILManagerObject. +$2C FHashTable (the objects by name), +$30
    FOwner. }
  TILManagerList = class(TStringList)
  private
    FHashTable: TStringHashTable256;
    FOwner: TImageLibraryManager;
  public
    constructor Create(AOwner: TImageLibraryManager);
    destructor Destroy; override;
    function GetIL(Index: Integer): TCustomImageLibrary;
    procedure UnloadIL;
    function AddILFile(FileName: string): TILManagerObject;
    function AddILManagerObject(const Name: string; ImageLibrary: TCustomImageLibrary): TILManagerObject;
    procedure Delete(Index: Integer); override;
    procedure Clear; override;
    function LinkToIL(FileName: string): TCustomImageLibrary;
    function ReleaseIL(FileName: string): Boolean;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  { ImageLib.TImageLibraryManager (instance size 48): the libraries a program shares, linked by
    file name. +$24 FSearchPath (upper case, ends with a backslash), +$28 FDiskList, +$2C
    FOwnedList. }
  TImageLibraryManager = class(TComponent)
  private
    FSearchPath: string;
    FDiskList: TILManagerList;
    FOwnedList: TILManagerList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure UnloadIL(Category: TILManagerCategory);
    procedure ExecutePathSearch(Path: string);
    function LinkToIL(Category: TILManagerCategory; FileName: string): TCustomImageLibrary;
    procedure ReleaseIL(Category: TILManagerCategory; FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    property DiskList: TILManagerList read FDiskList;
    property OwnedList: TILManagerList read FOwnedList;
  published
    property SearchPath: string read FSearchPath write FSearchPath;
  end;

  { ImageLib.TILManagerComboBox (instance size 388): a combo box with the library names of a
    manager. +$170 FILManager, +$174 FCategory, +$178 FSubDirectory (only the names in it are
    listed, without it), +$17C FSkipDirectories (separated by semicolons), +$180 FEmptyILName
    (the first item, for no library). }
  TILManagerComboBox = class(TComboBox)
  private
    FILManager: TImageLibraryManager;
    FCategory: TILManagerCategory;
    FSubDirectory: string;
    FSkipDirectories: string;
    FEmptyILName: string;
    procedure SetILManager(Value: TImageLibraryManager);
    procedure SetSubDirectory(Value: string);
    function GetImageLibraryName: string;
    procedure SetImageLibraryName(Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure GenerateItems;
    property ImageLibraryName: string read GetImageLibraryName write SetImageLibraryName;
  published
    property ILManager: TImageLibraryManager read FILManager write SetILManager;
    property Category: TILManagerCategory read FCategory write FCategory;
    property SubDirectory: string read FSubDirectory write SetSubDirectory;
    property SkipDirectories: string read FSkipDirectories write FSkipDirectories;
    property EmptyILName: string read FEmptyILName write FEmptyILName;
  end;

  { ImageLib.TILManagerListBox (instance size 360): the list box version of TILManagerComboBox.
    +$154 FILManager, +$158 FCategory, +$15C FSubDirectory, +$160 FSkipDirectories, +$164
    FEmptyILName. }
  TILManagerListBox = class(TListBox)
  private
    FILManager: TImageLibraryManager;
    FCategory: TILManagerCategory;
    FSubDirectory: string;
    FSkipDirectories: string;
    FEmptyILName: string;
    procedure SetILManager(Value: TImageLibraryManager);
    procedure SetSubDirectory(Value: string);
    function GetImageLibraryName: string;
    procedure SetImageLibraryName(Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure GenerateItems;
    property ImageLibraryName: string read GetImageLibraryName write SetImageLibraryName;
  published
    property ILManager: TImageLibraryManager read FILManager write SetILManager;
    property Category: TILManagerCategory read FCategory write FCategory;
    property SubDirectory: string read FSubDirectory write SetSubDirectory;
    property SkipDirectories: string read FSkipDirectories write FSkipDirectories;
    property EmptyILName: string read FEmptyILName write FEmptyILName;
  end;

  { ImageLib.TSequenceMode: how an image sequence steps through its images }
  TSequenceMode = (smNone, smUp, smUpDown, smRandom, smFrameTable, smRndFrameTable);

  TImageSequenceList = class;
  TFrameTableList = class;

  { ImageLib.TImageSequence (instance size 56): an animation of the images of a library, one
    layer of a chain sorted by layer. +4 FOwner, +8 FLayer, +$C FNext (the next layer), +$10
    FImageLibrary (linked by LinkToIL: FImageLibraryName from the manager of FOwner, or the
    library of FOwner), +$14 FImageLibraryName, +$18 FSequenceSpeed (frames per image - 1), +$19
    FSequenceMode, +$1C FFrameTable (the image indices of smFrameTable and smRndFrameTable),
    +$20 FImageIndex (the image of smNone, the random start of smRandom and smRndFrameTable),
    +$24 FdXshift, +$28 FdYshift, +$2C FLastFrame, +$30 FSpeedCount, +$34 FFrameCounter. }
  TImageSequence = class(TObject)
  private
    FOwner: TImageSequenceList;
    FLayer: Byte;
    FNext: TImageSequence;
    FImageLibrary: TCustomImageLibrary;
    FImageLibraryName: string;
    FSequenceSpeed: Byte;
    FSequenceMode: TSequenceMode;
    FFrameTable: TFrameTableList;
    FImageIndex: Integer;
    FdXshift: Integer;
    FdYshift: Integer;
    FLastFrame: Integer;
    FSpeedCount: Byte;
    FFrameCounter: Integer;
    procedure SetImageLibraryName(Value: string);
    procedure SetSequenceMode(Value: TSequenceMode);
  public
    constructor Create(AOwner: TImageSequenceList);
    destructor Destroy; override;
    function Copy(AOwner: TImageSequenceList): TImageSequence;
    function GetPreviewImage: TLibraryImage;
    procedure GetDimensions(var R: TRect);
    function GetTotalSequenceFrames: Integer;
    function GetFrameIndex(Frame, Offset: Integer): Integer;
    function GetUnloopedFrameIndex(Frame: Integer): Integer;
    procedure LinkToIL;
    procedure ReleaseIL;
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToIniFile(const Section: string; IniFile: TIniFile);
    procedure LoadFromIniFile(const Section: string; IniFile: TIniFile);
    property Owner: TImageSequenceList read FOwner;
    property Layer: Byte read FLayer write FLayer;
    property Next: TImageSequence read FNext write FNext;
    property ImageLibrary: TCustomImageLibrary read FImageLibrary;
    property ImageLibraryName: string read FImageLibraryName write SetImageLibraryName;
    property SequenceSpeed: Byte read FSequenceSpeed write FSequenceSpeed;
    property SequenceMode: TSequenceMode read FSequenceMode write SetSequenceMode;
    property FrameTable: TFrameTableList read FFrameTable;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property dXshift: Integer read FdXshift write FdXshift;
    property dYshift: Integer read FdYshift write FdYshift;
  end;

  { ImageLib.TImageSequenceList (instance size 28): the image sequences of the indices, each the
    first layer of a chain (nil for none). +$10 FLinked (the sequences are linked to their
    libraries), +$14 FILManager, +$18 FImageLibrary (the library of the sequences without a
    library name). }
  TImageSequenceList = class(TList)
  private
    FLinked: Boolean;
    FILManager: TImageLibraryManager;
    FImageLibrary: TCustomImageLibrary;
  public
    constructor Create(AILManager: TImageLibraryManager; AImageLibrary: TCustomImageLibrary);
    destructor Destroy; override;
    function UsedIndexString: string;
    procedure DestroyItems;
    function GetLayerImageSequence(Index, Layer: Integer): TImageSequence;
    function ReduceCount: Integer;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToIniFile(const Section: string; IniFile: TIniFile);
    procedure LoadFromIniFile(const Section: string; IniFile: TIniFile);
    function GetImageSequence(Index: Integer): TImageSequence;
    procedure SetImageSequence(Index: Integer; Value: TImageSequence);
    function GetSubCount(Index: Integer): Integer;
    function IndexOfSub(Index: Integer; Sequence: TImageSequence): Integer;
    function GetSubImageSequence(Index, SubIndex: Integer): TImageSequence;
    procedure Add(Index: Integer; Sequence: TImageSequence);
    procedure Delete(Index: Integer; Sequence: TImageSequence);
    procedure LinkToIL;
    procedure ReleaseIL;
    function Animating: Boolean;
    function GetPreviewImage: TLibraryImage;
    procedure GetDimensions(Index: Integer; var R: TRect);
    function Show(Index, X, Y, Frame: Integer; const SD: TSurfaceDesc): Boolean;
    function GetFramesCount(Index: Integer): Integer;
    procedure ShowLooped(Index, X, Y, Frame: Integer; const SD: TSurfaceDesc);
    procedure ShowLoopedEx(Index, X, Y, Frame, Offset: Integer; const SD: TSurfaceDesc);
    procedure CopyToClipboard;
    procedure PasteFromClipboard;
    property ImageSequences[Index: Integer]: TImageSequence read GetImageSequence write SetImageSequence;
    property Linked: Boolean read FLinked;
    property ILManager: TImageLibraryManager read FILManager;
    property ImageLibrary: TCustomImageLibrary read FImageLibrary;
  end;

  { ImageLib.TFrameTableList (instance size 20): a list of image indices, a copy of Classes.TList
    with Integer items and a fill value. +4 FList, +8 FCount, +$C FCapacity, +$10 FDefaultValue
    (SetCount fills new items with its low byte). Put grows the list instead of failing. VMT:
    Grow, Error. }
  PFrameTable = ^TFrameTable;
  TFrameTable = array[0..MaxListSize - 1] of Integer;
  TFrameTableSortCompare = function(Item1, Item2: Integer): Integer;

  TFrameTableList = class(TPersistent)
  private
    FList: PFrameTable;
    FCount: Integer;
    FCapacity: Integer;
    FDefaultValue: Integer;
  protected
    function Get(Index: Integer): Integer;
    procedure Grow; virtual;
    procedure Put(Index: Integer; Item: Integer);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add(Item: Integer): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    class procedure Error(const Msg: string; Data: Integer); virtual;
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TFrameTableList;
    function First: Integer;
    function IndexOf(Item: Integer): Integer;
    procedure Insert(Index: Integer; Item: Integer);
    function Last: Integer;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Integer): Integer;
    procedure Pack;
    procedure Sort(Compare: TFrameTableSortCompare);
    function Compare(List: TFrameTableList): Boolean;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    function GetItemString: string;
    procedure SetItemString(Value: string);
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: Integer read Get write Put; default;
    property List: PFrameTable read FList;
    property DefaultValue: Integer read FDefaultValue write FDefaultValue;
    property ItemString: string read GetItemString write SetItemString;
  end;

procedure BltLibraryImage(Canvas: TCanvas; Image: TLibraryImage; Rect: TRect; Mode: TBltMode;
  ScaleX, ScaleY: Integer; BkColor, Color: TColor; Selected: Boolean; var DrawRect: TRect);
procedure BltImageSequence(Sequence: TImageSequence; DC: HDC; X, Y: Integer; const R: TRect;
  Frame: Integer; BkColor: TColor);
procedure BltImageSequenceEx(Canvas: TCanvas; Sequence: TImageSequence; Frame: Integer;
  Rect: TRect; Mode: TBltMode; ScaleX, ScaleY: Integer; BkColor, Color: TColor;
  Selected: Boolean; var DrawRect: TRect);
function UpdateImage(ImageLibrary: TCustomImageLibrary; Image: TLibraryImage): Integer;
procedure DrawImageLine(Image: TLibraryImage; X1, Y1, X2, Y2, Spacing: Integer;
  const SD: TSurfaceDesc);
procedure ParseFontText(Text: string; Strings: TStrings; Font: TImageLibraryFont; MaxWidth: Integer);

function GetLibraryImageClass(Index: Integer): TLibraryImageClass;
function LibraryImageClassCount: Integer;
function FindLibraryImageClass(ClassID: Integer): TLibraryImageClass;
procedure RegisterLibraryImageClasses(AClasses: array of TLibraryImageClass);
function ReadImageFromStream(Stream: TStream; AOwner: TCustomImageLibrary): TLibraryImage;
procedure WriteImageToStream(Image: TLibraryImage; Stream: TStream);
function ReadImageFromStreamEx(Stream, DataStream: TStream; AOwner: TCustomImageLibrary): TLibraryImage;
procedure WriteImageToStreamEx(Image: TLibraryImage; Stream, DataStream: TStream);
procedure Register;

var
  { The directory library file names are relative to at run time (the program's directory) }
  BaseImageLibraryPath: string;

implementation

uses
  Consts, Clipbrd, Dialogs, DsgnIntf, ExptIntf, ToolIntf, ILEdGrid, SubImgEd, ImgSetEd, SImgSEd,
  ILEdForm;

type
  { TFastLoadFileStream (instance size 8, declared in the implementation): a read-only file
    stream opened with FILE_FLAG_SEQUENTIAL_SCAN. Destroy does not call the inherited destructor. }
  TFastLoadFileStream = class(THandleStream)
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
  end;

  { The header of an .ILB file (24 bytes). Up to version 3 the images follow it; from version 4
    on the image index (HeaderSize to IndexEnd) is followed by the discardable image data. }
  TILBHeader = record
    ID: string[4];
    Version: Single;
    HeaderSize: Integer;
    IndexEnd: Integer;
    Size: Integer;
  end;

  { TILFilenameProperty (instance size 16, declared in the implementation): the property editor
    of TCustomImageLibrary.FileName. }
  TILFilenameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;

  { Access to the lookup tables of a GFXE blend table collection: the original reads the
    array directly (GFXE.TLookupBlendTableCollection100 +8), which the GFXE source declares
    private. }
var
  LibraryImageClasses: TList;

{ TFastLoadFileStream }

constructor TFastLoadFileStream.Create(const FileName: string);
var
  H: THandle;
begin
  H := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);
  if H <> INVALID_HANDLE_VALUE then
    inherited Create(H)
  else
    raise EFOpenError.CreateFmt(SFOpenError, [FileName]);
end;

destructor TFastLoadFileStream.Destroy;
begin
  if Handle <> INVALID_HANDLE_VALUE then
    if not CloseHandle(Handle) then
      raise Exception.Create('Could not close file handle');
end;

{ The strings of the image sequences: a length and the characters }

procedure WriteStringToStream(const S: string; Stream: TStream);
var
  L: Integer;
begin
  L := Length(S);
  Stream.Write(L, 4);
  Stream.Write(PChar(S)^, L);
end;

procedure ReadStringFromStream(var S: string; Stream: TStream);
var
  L: Integer;
begin
  Stream.Read(L, 4);
  SetLength(S, L);
  Stream.Read(S[1], L);
end;

{ TImageNode }

constructor TImageNode.Create(AOwner: TCustomImageLibrary);
begin
  inherited Create(AOwner);
  FFileName := '(multi images)';
end;

destructor TImageNode.Destroy;
begin
  Clear;
  inherited Destroy;
end;

class function TImageNode.ClassID: Integer;
begin
  Result := $100;
end;

class function TImageNode.Name: string;
begin
  Result := '';
end;

function TImageNode.Info: string;
begin
  Result := 'Image Node';
end;

procedure TImageNode.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FImages, NewCapacity * SizeOf(TLibraryImage));
    FCapacity := NewCapacity;
  end;
end;

procedure TImageNode.SetCount(NewCount: Integer);
begin
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FImages^[FCount], (NewCount - FCount) * SizeOf(TLibraryImage), 0);
  FCount := NewCount;
end;

function TImageNode.GetImage(Index: Integer): TLibraryImage;
begin
  Result := FImages^[Index];
end;

function TImageNode.GetSafeImage(Index: Integer): TLibraryImage;
begin
  if (Index >= 0) and (Index < FCount) then
    Result := FImages^[Index]
  else
    Result := nil;
end;

procedure TImageNode.UpdateDimensions;
var
  I: Integer;
begin
  FWidth := 0;
  FHeight := 0;
  for I := 0 to FCount - 1 do
  begin
    if FImages^[I].FWidth > FWidth then FWidth := FImages^[I].FWidth;
    if FImages^[I].FHeight > FHeight then FHeight := FImages^[I].FHeight;
  end;
end;

function TImageNode.Add(Image: TLibraryImage): Integer;
begin
  SetCount(FCount + 1);
  FImages^[FCount - 1] := Image;
  if Image.FWidth > FWidth then FWidth := Image.FWidth;
  if Image.FHeight > FHeight then FHeight := Image.FHeight;
  Result := FCount;
end;

procedure TImageNode.Insert(Index: Integer; Image: TLibraryImage);
begin
  if FCapacity = FCount then SetCapacity(FCapacity + 1);
  if Index < FCount then
    Move(FImages^[Index], FImages^[Index + 1], (FCount - Index) * SizeOf(TLibraryImage));
  FImages^[Index] := Image;
  if Image.FWidth > FWidth then FWidth := Image.FWidth;
  if Image.FHeight > FHeight then FHeight := Image.FHeight;
  Inc(FCount);
end;

procedure TImageNode.Remove(Image: TLibraryImage);
var
  I: Integer;
begin
  I := FCount;
  while (I >= 0) and (Image <> FImages^[I]) do Dec(I);
  if I >= 0 then
  begin
    Dec(FCount);
    if I < FCount then
      Move(FImages^[I + 1], FImages^[I], (FCount - I) * SizeOf(TLibraryImage));
    UpdateDimensions;
  end;
end;

function TImageNode.IndexOf(Image: TLibraryImage): Integer;
begin
  Result := FCount - 1;
  while (Result >= 0) and (Image <> FImages^[Result]) do Dec(Result);
end;

procedure TImageNode.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < FCount) then
  begin
    Dec(FCount);
    if Index < FCount then
      Move(FImages^[Index + 1], FImages^[Index], (FCount - Index) * SizeOf(TLibraryImage));
    UpdateDimensions;
  end;
end;

procedure TImageNode.SaveToStreamEx(Stream, DataStream: TStream);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do WriteImageToStreamEx(FImages^[I], Stream, DataStream);
  WriteImageToStream(nil, Stream);
end;

procedure TImageNode.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do WriteImageToStream(FImages^[I], Stream);
  WriteImageToStream(nil, Stream);
end;

procedure TImageNode.LoadFromStream(Stream: TStream);
var
  Image: TLibraryImage;
begin
  Clear;
  Image := ReadImageFromStream(Stream, FOwner);
  while Image <> nil do
  begin
    Add(Image);
    Image := ReadImageFromStream(Stream, FOwner);
  end;
end;

procedure TImageNode.LoadFromStreamEx(Stream, DataStream: TStream);
var
  Image: TLibraryImage;
begin
  Image := ReadImageFromStreamEx(Stream, DataStream, FOwner);
  while Image <> nil do
  begin
    Add(Image);
    Image := ReadImageFromStreamEx(Stream, DataStream, FOwner);
  end;
end;

procedure TImageNode.Clear;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do FImages^[I].Destroy;
  FCount := 0;
  SetCapacity(0);
end;

procedure TImageNode.SetReloadingEnabled(Value: Boolean);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].SetReloadingEnabled(False);
end;

procedure TImageNode.SetOwner(AOwner: TCustomImageLibrary);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].SetOwner(AOwner);
  FOwner := AOwner;
end;

function TImageNode.RemapToPixelFormat(PixelFormatID: Integer): HResult;
var
  I: Integer;
begin
  Result := 0;
  I := FCount;
  while (I <> 0) and (Result = 0) do
  begin
    Dec(I);
    Result := FImages^[I].RemapToPixelFormat(PixelFormatID);
  end;
end;

procedure TImageNode.Show(X, Y: Integer; const SD: TSurfaceDesc);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].Show(X, Y, SD);
end;

procedure TImageNode.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].ShowOpaque(X, Y, SD);
end;

procedure TImageNode.ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].ShowTransparent(X, Y, SD);
end;

procedure TImageNode.ShowBlended(X, Y: Integer; const SD: TSurfaceDesc; Table: TBlendTable);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].ShowBlended(X, Y, SD, Table);
end;

procedure TImageNode.ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor);
var
  H: HWND;
  Surface: TDIB16Surface;
  SD: TSurfaceDesc;
  R: TRect;
  ClientRect: TRect;
  I: Integer;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := FWidth;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  Surface := TDIB16Surface.Create(SrcRect^.Right - SrcRect^.Left, SrcRect^.Bottom - SrcRect^.Top,
    pfRGB565);
  try
    if DestRect = nil then
    begin
      H := WindowFromDC(DC);
      GetClientRect(H, ClientRect);
      DestRect := @ClientRect;
    end;
    Surface.Cls(BkColor);
    Surface.Lock(SD);
    for I := 0 to FCount - 1 do FImages^[I].Show(-SrcRect^.Left, -SrcRect^.Top, SD);
    Surface.BltDC(DC, nil, DestRect);
    Surface.Unlock;
  finally
    Surface.Free;
  end;
end;

procedure TImageNode.ShowEx(X, Y: Integer; const SD: TSurfaceDesc; const ShowInfo: TShowInfo);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].ShowEx(X, Y, SD, ShowInfo);
end;

function TImageNode.SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean;
var
  I: Integer;
begin
  I := FCount;
  Result := True;
  while Result and (I <> 0) do
  begin
    Dec(I);
    Result := FImages^[I].SupportShowMode(ShowMode, PixelFormatID);
  end;
end;

procedure TImageNode.SetLoadMode(Value: TLoadMode);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].SetLoadMode(Value);
  FLoadMode := Value;
end;

procedure TImageNode.ReleaseDiscardableImageData;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].ReleaseDiscardableImageData;
  FDataLoaded := False;
end;

procedure TImageNode.LoadDiscardableImageData;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do FImages^[I].LoadDiscardableImageData;
  FDataLoaded := True;
end;

{ TLibraryImage }

constructor TLibraryImage.Create(AOwner: TCustomImageLibrary);
begin
  inherited Create;
  FDataPosition := -1;
  FReloadingEnabled := False;
  FLoadMode := lmLoadOnDemand;
  FShowInfo.ShowMode := smOpaque;
  FShowInfo.BlendMode := bmAlpha;
  SetOwner(AOwner);
end;

destructor TLibraryImage.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TLibraryImage.SetOwner(AOwner: TCustomImageLibrary);
begin
  if (AOwner <> FOwner) and (FOwner <> nil) and not FDataLoaded then
    SetReloadingEnabled(False);
  FOwner := AOwner;
end;

procedure TLibraryImage.SetXshift(Value: Integer);
begin
  FXshift := Value;
end;

procedure TLibraryImage.SetYshift(Value: Integer);
begin
  FYshift := Value;
end;

procedure TLibraryImage.SetWidth(Value: Integer);
begin
  FWidth := Value;
end;

procedure TLibraryImage.SetHeight(Value: Integer);
begin
  FHeight := Value;
end;

procedure TLibraryImage.GetVisualDimensions(var R: TRect);
begin
  R.Left := 0;
  R.Right := FWidth;
  R.Top := 0;
  R.Bottom := FHeight;
end;

procedure TLibraryImage.GetDimensions(var R: TRect);
begin
  R.Left := 0;
  R.Right := FWidth;
  R.Top := 0;
  R.Bottom := FHeight;
end;

procedure TLibraryImage.SetReloadingEnabled(Value: Boolean);
begin
  if not Value and not FDataLoaded then LoadDiscardableImageData;
  if Value and not FReloadingEnabled then
    raise Exception.Create('Cannot turn on Reloading when disabled')
  else
    FReloadingEnabled := Value;
end;

class function TLibraryImage.ClassVersion: Byte;
begin
  Result := 3;
end;

function TLibraryImage.Copy: TLibraryImage;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    WriteImageToStream(Self, Stream);
    Stream.Position := 0;
    Result := ReadImageFromStream(Stream, FOwner);
    Result.SetOwner(nil);
  finally
    Stream.Free;
  end;
end;

procedure TLibraryImage.Clear;
begin
  FVersion := ClassVersion;
  ReleaseDiscardableImageData;
  FDataSize := 0;
  FDataLoaded := False;
  FDataPosition := -1;
  FDataSize := 0;
  FReloadingEnabled := False;
  FXshift := 0;
  FDataWidth := 0;
  FWidth := 0;
  FYshift := 0;
  FDataHeight := 0;
  FHeight := 0;
end;

procedure TLibraryImage.ReadImageData(Stream: TStream);
begin
  Stream.Read(FVersion, 1);
  ReadStringFromStream(FFileName, Stream);
  Stream.Read(FDataWidth, 4);
  Stream.Read(FDataHeight, 4);
  Stream.Read(FXshift, 4);
  Stream.Read(FYshift, 4);
  Stream.Read(FFileIndex, 4);
  Stream.Read(FLoadMode, 1);
  Stream.Read(FDataSize, 4);
  if FVersion > 0 then
  begin
    if FVersion >= 2 then Stream.Read(FDataPosition, 4);
    Stream.Read(FWidth, 4);
    Stream.Read(FHeight, 4);
  end
  else
  begin
    FWidth := FDataWidth + FXshift;
    FHeight := FDataHeight + FYshift;
  end;
  if FVersion >= 3 then Stream.Read(FShowInfo, 8);
end;

procedure TLibraryImage.WriteImageData(Stream: TStream);
var
  V: Byte;
begin
  V := ClassVersion;
  Stream.Write(V, 1);
  WriteStringToStream(FFileName, Stream);
  Stream.Write(FDataWidth, 4);
  Stream.Write(FDataHeight, 4);
  Stream.Write(FXshift, 4);
  Stream.Write(FYshift, 4);
  Stream.Write(FFileIndex, 4);
  Stream.Write(FLoadMode, 1);
  Stream.Write(FDataSize, 4);
  Stream.Write(FDataPosition, 4);
  Stream.Write(FWidth, 4);
  Stream.Write(FHeight, 4);
  Stream.Write(FShowInfo, 8);
end;

procedure TLibraryImage.ReadDiscardableImageData(Stream: TStream);
begin
  FDataLoaded := True;
end;

procedure TLibraryImage.WriteDiscardableImageData(Stream: TStream);
begin
end;

procedure TLibraryImage.ReleaseDiscardableImageData;
begin
  FDataLoaded := False;
end;

procedure TLibraryImage.LoadDiscardableImageData;
var
  Stream: TStream;
begin
  if not FDataLoaded then
  begin
    Stream := TFastLoadFileStream.Create(FOwner.FLoadedFileName);
    try
      Stream.Seek(FDataPosition + FOwner.FDataOffset, 0);
      ReadDiscardableImageData(Stream);
      FDataLoaded := True;
    finally
      Stream.Free;
    end;
  end;
end;

procedure TLibraryImage.SaveToStream(Stream: TStream);
var
  P: Integer;
begin
  P := FDataPosition;
  FDataPosition := -1;
  WriteImageData(Stream);
  FDataPosition := P;
  if not FDataLoaded then
  begin
    LoadDiscardableImageData;
    WriteDiscardableImageData(Stream);
    if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
  end
  else
    WriteDiscardableImageData(Stream);
end;

procedure TLibraryImage.LoadFromStream(Stream: TStream);
var
  P: Integer;
begin
  Clear;
  ReadImageData(Stream);
  if FVersion < 2 then
  begin
    FDataPosition := Stream.Position;
    if (FLoadMode = lmLoadAlways) or (FOwner = nil) or not FOwner.FReloading or
      not (isLoadingFromFile in FOwner.FStatus) then
    begin
      ReadDiscardableImageData(Stream);
      FReloadingEnabled := False;
    end
    else
    begin
      Stream.Seek(FDataSize, 1);
      FReloadingEnabled := True;
    end;
  end
  else if (FLoadMode = lmLoadAlways) or (FOwner = nil) or not FOwner.FReloading or
    not (isLoadingFromFile in FOwner.FStatus) or (FDataPosition = -1) then
  begin
    if FDataPosition <> -1 then
    begin
      P := Stream.Position;
      Stream.Position := FOwner.FDataOffset + FDataPosition;
      ReadDiscardableImageData(Stream);
      Stream.Position := P;
    end
    else
      ReadDiscardableImageData(Stream);
    FReloadingEnabled := False;
  end
  else
    FReloadingEnabled := True;
end;

procedure TLibraryImage.LoadFromStreamEx(Stream, DataStream: TStream);
begin
  ReadImageData(Stream);
  if FVersion >= 2 then
  begin
    if (FLoadMode = lmLoadAlways) or (FOwner = nil) or not FOwner.FReloading or
      not (isLoadingFromFile in FOwner.FStatus) or (FDataPosition = -1) then
    begin
      if FDataPosition <> -1 then
      begin
        DataStream.Position := FOwner.FDataOffset + FDataPosition;
        ReadDiscardableImageData(DataStream);
      end
      else
        ReadDiscardableImageData(Stream);
      FReloadingEnabled := False;
    end
    else
      FReloadingEnabled := True;
  end
  else
    raise Exception.Create('Invalid image format');
end;

procedure TLibraryImage.SaveToStreamEx(Stream, DataStream: TStream);
var
  P: Integer;
begin
  P := FDataPosition;
  FDataPosition := DataStream.Position;
  WriteImageData(Stream);
  FDataPosition := P;
  if not FDataLoaded then
  begin
    LoadDiscardableImageData;
    WriteDiscardableImageData(DataStream);
    if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
  end
  else
    WriteDiscardableImageData(DataStream);
end;

procedure TLibraryImage.SetLoadMode(Value: TLoadMode);
begin
  FLoadMode := Value;
  if (FLoadMode = lmLoadAlways) and not FDataLoaded then LoadDiscardableImageData;
end;

function TLibraryImage.GetPalette: TGFXEPalette;
begin
  Result := nil;
end;

function TLibraryImage.GetRemapPalette: TGFXEPalette;
begin
  Result := nil;
end;

function TLibraryImage.GetTransparent: Boolean;
begin
  Result := False;
end;

class function TLibraryImage.ClassID: Integer;
begin
  Result := 0;
end;

function TLibraryImage.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := False;
end;

function TLibraryImage.CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
  OnImagesGrabbed: TImagesGrabbedEvent): TForm;
begin
  Result := nil;
end;

function TLibraryImage.GrabImage(const SD: TSurfaceDesc; const R: TRect;
  GrabInfo: TGrabInfo): Boolean;
begin
  Result := False;
end;

function TLibraryImage.CreateGrabInfo: TGrabInfo;
begin
  Result := TGrabInfo.Create;
end;

{ GrabImages: grabs the images of a surface into ImageLibrary, one per rectangle that
  GetSurfaceRectangles finds (or the whole surface). }
class function TLibraryImage.GrabImages(const SD: TSurfaceDesc; GrabInfo: TGrabInfo;
  ImageLibrary: TCustomImageLibrary; OnProgress: TGrabProgressEvent): HResult;

  procedure Progress(Percent: Integer; Msg: string);
  begin
    if Assigned(OnProgress) then OnProgress(nil, Percent, Msg);
  end;

var
  ImageClass: TLibraryImageClass;
  Image: TLibraryImage;
  Msg: string;
  Rects: TRectangleList;
  I: Integer;
begin
  Progress(10, 'Analyzing Image..');
  ImageClass := FindLibraryImageClass(ClassID);
  if GrabInfo.FindRectangles then
    Rects := GetSurfaceRectangles(SD, GrabInfo.TransparentColor, nil)
  else
  begin
    Rects := TRectangleList.Create;
    Rects.Add(TRectangle.Create(0, 0, SD.Width, SD.Height));
  end;
  if (Rects <> nil) and (ImageClass <> nil) then
  begin
    for I := 0 to Rects.Count - 1 do
    begin
      Msg := 'Grabbing Image';
      if Rects.Count > 1 then
        Progress(Round(I * 90 / (Rects.Count - 1)) + 10, 'Grabbing Image ' + IntToStr(I + 1))
      else
        Progress(100, 'Grabbing Image');
      Image := ImageClass.Create(nil);
      GrabInfo.FileIndex := I;
      if Image.GrabImage(SD, Rects.Rectangles[I].Rect, GrabInfo) then
        ImageLibrary.Add(Image)
      else
        Image.Free;
    end;
    Result := 0;
  end
  else
    Result := GFXE_ERROR;
  Rects.Free;
end;

class function TLibraryImage.Name: string;
begin
  Result := 'Abstract Library Image';
end;

function TLibraryImage.Info: string;
begin
  Result := Name + ' ' + IntToStr(FWidth) + 'x' + IntToStr(FHeight);
  if GetTransparent then Result := Result + ' Transparent';
end;

function TLibraryImage.RemapToPixelFormat(PixelFormatID: Integer): HResult;
begin
  raise Exception.Create('Surface format not supported');
  Result := GFXE_NOTSUPPORTED;
end;

procedure TLibraryImage.SetDefaultShowInfo(Value: TShowInfo);
begin
  if SupportShowMode(Value.ShowMode, 0) then FShowInfo := Value;
end;

procedure TLibraryImage.Show(X, Y: Integer; const SD: TSurfaceDesc);
begin
  case FShowInfo.ShowMode of
    smOpaque: ShowOpaque(X, Y, SD);
    smTransparent: ShowTransparent(X, Y, SD);
    smBlended:
      case FShowInfo.BlendMode of
        bmUser: if FShowInfo.BlendTable <> nil then ShowBlended(X, Y, SD, FShowInfo.BlendTable);
        bmAlpha: ShowBlended(X, Y, SD,
          AlphaBlendTable.Lookup[FShowInfo.BlendPercentage]);
        bmBrighten: ShowBlended(X, Y, SD,
          BrightenBlendTable.Lookup[FShowInfo.BlendPercentage]);
        bmIntensity: ShowBlended(X, Y, SD,
          IntensityBlendTable.Lookup[FShowInfo.BlendPercentage]);
        bmShadow: ShowBlended(X, Y, SD,
          ShadowBlendTable.Lookup[FShowInfo.BlendPercentage]);
        bmLinearAlpha: ShowBlended(X, Y, SD,
          LinearAlphaBlendTable.Lookup[FShowInfo.BlendPercentage]);
      end;
  end;
end;

{ ShowEx: the blend mode comes from the image's own show info (an original bug: ShowInfo only
  gives the show mode and the blend value), and bmLinearAlpha is not handled. }
procedure TLibraryImage.ShowEx(X, Y: Integer; const SD: TSurfaceDesc; const ShowInfo: TShowInfo);
begin
  case ShowInfo.ShowMode of
    smOpaque: ShowOpaque(X, Y, SD);
    smTransparent: ShowTransparent(X, Y, SD);
    smBlended:
      case FShowInfo.BlendMode of
        bmUser: if ShowInfo.BlendTable <> nil then ShowBlended(X, Y, SD, ShowInfo.BlendTable);
        bmAlpha: ShowBlended(X, Y, SD,
          AlphaBlendTable.Lookup[ShowInfo.BlendPercentage]);
        bmBrighten: ShowBlended(X, Y, SD,
          BrightenBlendTable.Lookup[ShowInfo.BlendPercentage]);
        bmIntensity: ShowBlended(X, Y, SD,
          IntensityBlendTable.Lookup[ShowInfo.BlendPercentage]);
        bmShadow: ShowBlended(X, Y, SD,
          ShadowBlendTable.Lookup[ShowInfo.BlendPercentage]);
      end;
  end;
end;

procedure TLibraryImage.ShowStretched(const R: TRect; const SD: TSurfaceDesc);
begin
  case FShowInfo.ShowMode of
    smOpaque: ShowOpaqueStretched(R, SD);
    smBlended:
      case FShowInfo.BlendMode of
        bmUser: if FShowInfo.BlendTable <> nil then ShowBlendedStretched(R, SD, FShowInfo.BlendTable);
        bmAlpha: ShowBlendedStretched(R, SD,
          AlphaBlendTable.Lookup[FShowInfo.BlendPercentage]);
        bmBrighten: ShowBlendedStretched(R, SD,
          BrightenBlendTable.Lookup[FShowInfo.BlendPercentage]);
        bmIntensity: ShowBlendedStretched(R, SD,
          IntensityBlendTable.Lookup[FShowInfo.BlendPercentage]);
        bmShadow: ShowBlendedStretched(R, SD,
          ShadowBlendTable.Lookup[FShowInfo.BlendPercentage]);
        bmLinearAlpha: ShowBlendedStretched(R, SD,
          LinearAlphaBlendTable.Lookup[FShowInfo.BlendPercentage]);
      end;
  end;
end;

procedure TLibraryImage.ShowClipped(X, Y: Integer; const SD: TSurfaceDesc);
begin
  Show(X, Y, SD);
end;

procedure TLibraryImage.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
begin
end;

procedure TLibraryImage.ShowOpaqueStretched(const R: TRect; const SD: TSurfaceDesc);
begin
end;

procedure TLibraryImage.ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc);
begin
end;

procedure TLibraryImage.ShowBlended(X, Y: Integer; const SD: TSurfaceDesc; Table: TBlendTable);
begin
end;

procedure TLibraryImage.ShowBlendedStretched(const R: TRect; const SD: TSurfaceDesc;
  Table: TBlendTable);
begin
end;

procedure TLibraryImage.ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor);
begin
end;

function TLibraryImage.SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean;
begin
  Result := False;
end;

{ TImage16 }

constructor TImage16.Create(AOwner: TCustomImageLibrary);
begin
  inherited Create(AOwner);
end;

procedure TImage16.ReadImageData(Stream: TStream);
begin
  inherited ReadImageData(Stream);
  Stream.Read(FStoredPixelFormatID, 4);
  FPixelFormatID := FStoredPixelFormatID;
end;

procedure TImage16.WriteImageData(Stream: TStream);
begin
  inherited WriteImageData(Stream);
  RemapToPixelFormat(FStoredPixelFormatID);
  Stream.Write(FStoredPixelFormatID, 4);
end;

procedure TImage16.ReadDiscardableImageData(Stream: TStream);
begin
  inherited ReadDiscardableImageData(Stream);
  FPixelFormatID := FStoredPixelFormatID;
end;

procedure TImage16.WriteDiscardableImageData(Stream: TStream);
begin
  inherited WriteDiscardableImageData(Stream);
end;

procedure TImage16.ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor);
var
  SD: TSurfaceDesc;
  R, ClientRect: TRect;
  Surface: TDIB16Surface;
  H: HWND;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := FWidth;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  Surface := TDIB16Surface.Create(SrcRect^.Right - SrcRect^.Left, SrcRect^.Bottom - SrcRect^.Top,
    FPixelFormatID);
  try
    if DestRect = nil then
    begin
      H := WindowFromDC(DC);
      GetClientRect(H, ClientRect);
      DestRect := @ClientRect;
    end;
    Surface.Cls(BkColor);
    Surface.Lock(SD);
    Show(-SrcRect^.Left, -SrcRect^.Top, SD);
    Surface.BltDC(DC, nil, DestRect);
    Surface.Unlock;
  finally
    Surface.Free;
  end;
end;

{ TPicture16 }

class function TPicture16.ClassID: Integer;
begin
  Result := $10;
end;

class function TPicture16.Name: string;
begin
  Result := 'Picture (16bpp)';
end;

procedure TPicture16.SetXshift(Value: Integer);
begin
  if Value < 0 then Value := 0;
  inherited SetXshift(Value);
  SetWidth(FWidth);
end;

procedure TPicture16.SetYshift(Value: Integer);
begin
  if Value < 0 then Value := 0;
  inherited SetYshift(Value);
  SetHeight(FHeight);
end;

procedure TPicture16.SetWidth(Value: Integer);
begin
  if Value < FXshift + FDataWidth then Value := FXshift + FDataWidth;
  inherited SetWidth(Value);
end;

procedure TPicture16.SetHeight(Value: Integer);
begin
  if Value < FYshift + FDataHeight then Value := FYshift + FDataHeight;
  inherited SetHeight(Value);
end;

function TPicture16.SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean;
begin
  Result := ((PixelFormatID = 0) or (PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555)) and
    (ShowMode in [smOpaque, smTransparent, smBlended]);
end;

procedure TPicture16.AllocateDiscardableImageData(AWidth, AHeight: Integer);
var
  Size: Integer;
begin
  if AWidth < 32 then
    FPitch := (AWidth shl 1 + 3) and not 3
  else
    FPitch := (AWidth shl 1 + 7) and not 7;
  Size := FPitch * AHeight + 7;
  ReallocMem(FBuffer, Size);
  FData := Pointer((Integer(FBuffer) + 7) and not 7);
end;

procedure TPicture16.ReleaseDiscardableImageData;
begin
  if FDataLoaded then
  begin
    ReallocMem(FBuffer, 0);
    FDataLoaded := False;
  end;
end;

procedure TPicture16.ReadDiscardableImageData(Stream: TStream);
var
  Y: Integer;
begin
  inherited ReadDiscardableImageData(Stream);
  AllocateDiscardableImageData(FDataWidth, FDataHeight);
  for Y := 0 to FDataHeight - 1 do
    Stream.Read(Pointer(Integer(FData) + Y * FPitch)^, FDataWidth * 2);
end;

procedure TPicture16.WriteDiscardableImageData(Stream: TStream);
var
  Y: Integer;
begin
  inherited WriteDiscardableImageData(Stream);
  for Y := 0 to FDataHeight - 1 do
    Stream.Write(Pointer(Integer(FData) + Y * FPitch)^, FDataWidth * 2);
end;

function TPicture16.CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
  OnImagesGrabbed: TImagesGrabbedEvent): TForm;
begin
  Result := nil;
end;

function TPicture16.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := (PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555) or
    (PixelFormatID = pfRGB24) or (PixelFormatID = pfPAL8);
end;

function TPicture16.GrabImage(const SD: TSurfaceDesc; const R: TRect;
  GrabInfo: TGrabInfo): Boolean;
var
  Y, I, X: Integer;
  S: PByte;
  D: PWord;
  P: PPaletteEntry;
  S24: PByteArray;
begin
  try
    Clear;
    Result := True;
    FDataLoaded := True;
    FDataWidth := R.Right - R.Left;
    FDataHeight := R.Bottom - R.Top;
    FWidth := FDataWidth;
    FHeight := FDataHeight;
    FFileName := ExtractFileName(GrabInfo.FileName);
    FFileIndex := GrabInfo.FileIndex;
    FDataSize := FDataWidth * FDataHeight * 2;
    AllocateDiscardableImageData(FWidth, FHeight);
    case SD.PixelFormatID of
      pfPAL8:
        begin
          for Y := 0 to FHeight - 1 do
          begin
            S := PByte(Integer(SD.Data) + (R.Top + Y) * SD.Pitch + R.Left);
            D := PWord(Integer(FData) + FPitch * Y);
            for X := 0 to FWidth - 1 do
            begin
              P := @SD.Palette.Entries[S^];
              D^ := (P^.R and $F8) shl 8 + (P^.G and $FC) shl 3 + P^.B shr 3;
              Inc(S);
              Inc(D);
            end;
          end;
          FStoredPixelFormatID := pfRGB565;
        end;
      pfRGB565, pfRGB555:
        begin
          for I := 0 to FHeight - 1 do
            Move(Pointer(Integer(SD.Data) + (R.Top + I) * SD.Pitch + R.Left * 2)^,
              Pointer(Integer(FData) + FPitch * I)^, FWidth * 2);
          FStoredPixelFormatID := SD.PixelFormatID;
        end;
      pfRGB24:
        begin
          for Y := 0 to FHeight - 1 do
          begin
            D := PWord(Integer(FData) + FPitch * Y);
            S24 := PByteArray(Integer(SD.Data) + (R.Top + Y) * SD.Pitch + R.Left * 3);
            for X := 0 to FWidth - 1 do
            begin
              D^ := (S24^[2] and $F8) shl 8 + (S24^[1] and $FC) shl 3 + S24^[0] shr 3;
              Inc(Integer(S24), 3);
              Inc(D);
            end;
          end;
          FStoredPixelFormatID := pfRGB565;
        end;
    else
      Result := False;
    end;
    FPixelFormatID := FStoredPixelFormatID;
  except
    ReleaseDiscardableImageData;
    Result := False;
  end;
end;

function TPicture16.RemapToPixelFormat(PixelFormatID: Integer): HResult;
begin
  Result := 0;
  if PixelFormatID <> FPixelFormatID then
    case PixelFormatID of
      pfRGB565:
        begin
          RemapSurface555to565(FData, FData, FPitch, FPitch, FDataWidth, FDataHeight);
          FPixelFormatID := pfRGB565;
        end;
      pfRGB555:
        begin
          RemapSurface565to555(FData, FData, FPitch, FPitch, FDataWidth, FDataHeight);
          FPixelFormatID := pfRGB555;
        end;
    else
      Result := GFXE_NOTSUPPORTED;
    end;
end;

procedure TPicture16.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
var
  DX, Right, W, H, SX, SY, DY, Bottom: Integer;
  Src, Dst: Pointer;
begin
  DX := X + FXshift;
  W := FDataWidth;
  Right := FDataWidth + DX;
  if DX < SD.ClipRect.Left then
  begin
    SX := SD.ClipRect.Left - X;
    DX := SD.ClipRect.Left;
    Dec(W, SX);
  end
  else
    SX := 0;
  if Right > SD.ClipRect.Right then Dec(W, Right - SD.ClipRect.Right);
  if W > 0 then
  begin
    DY := Y + FYshift;
    H := FDataHeight;
    Bottom := DY + FDataHeight;
    if DY < SD.ClipRect.Top then
    begin
      SY := SD.ClipRect.Top - Y;
      DY := SD.ClipRect.Top;
      Dec(H, SY);
    end
    else
      SY := 0;
    if Bottom > SD.ClipRect.Bottom then Dec(H, Bottom - SD.ClipRect.Bottom);
    if H > 0 then
      if not FDataLoaded then
      begin
        LoadDiscardableImageData;
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
          BltRect(Src, Dst, FPitch, SD.Pitch, W * 2, H)
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          BltRect(Src, Dst, FPitch, SD.Pitch, W * 2, H);
        end;
        if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
      end
      else
      begin
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
          BltRect(Src, Dst, FPitch, SD.Pitch, W * 2, H)
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          BltRect(Src, Dst, FPitch, SD.Pitch, W * 2, H);
        end;
      end;
  end;
end;

procedure TPicture16.ShowBlended(X, Y: Integer; const SD: TSurfaceDesc; Table: TBlendTable);
var
  DX, Right, W, H, SX, SY, DY, Bottom: Integer;
  Src, Dst: Pointer;
begin
  DX := X + FXshift;
  W := FDataWidth;
  Right := FDataWidth + DX;
  if DX < SD.ClipRect.Left then
  begin
    SX := SD.ClipRect.Left - X;
    DX := SD.ClipRect.Left;
    Dec(W, SX);
  end
  else
    SX := 0;
  if Right > SD.ClipRect.Right then Dec(W, Right - SD.ClipRect.Right);
  if W > 0 then
  begin
    DY := Y + FYshift;
    H := FDataHeight;
    Bottom := DY + FDataHeight;
    if DY < SD.ClipRect.Top then
    begin
      SY := SD.ClipRect.Top - Y;
      DY := SD.ClipRect.Top;
      Dec(H, SY);
    end
    else
      SY := 0;
    if Bottom > SD.ClipRect.Bottom then Dec(H, Bottom - SD.ClipRect.Bottom);
    if H > 0 then
      if not FDataLoaded then
      begin
        LoadDiscardableImageData;
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
        begin
          if Table.Bits = 5 then
            case FPixelFormatID of
              pfRGB565: BlendSurface565(Src, Dst, FPitch, SD.Pitch, W, H,
                @TBlendTable5Bit(Table).Table);
              pfRGB555: BlendSurface555(Src, Dst, FPitch, SD.Pitch, W, H,
                @TBlendTable5Bit(Table).Table);
            end
          else
            raise Exception.Create('Invalid BlendTable format');
        end
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          if Table.Bits = 5 then
            case FPixelFormatID of
              pfRGB565: BlendSurface565(Src, Dst, FPitch, SD.Pitch, W, H,
                @TBlendTable5Bit(Table).Table);
              pfRGB555: BlendSurface555(Src, Dst, FPitch, SD.Pitch, W, H,
                @TBlendTable5Bit(Table).Table);
            end
          else
            raise Exception.Create('Invalid BlendTable format');
        end;
        if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
      end
      else
      begin
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
        begin
          if Table.Bits = 5 then
            case FPixelFormatID of
              pfRGB565: BlendSurface565(Src, Dst, FPitch, SD.Pitch, W, H,
                @TBlendTable5Bit(Table).Table);
              pfRGB555: BlendSurface555(Src, Dst, FPitch, SD.Pitch, W, H,
                @TBlendTable5Bit(Table).Table);
            end
          else
            raise Exception.Create('Invalid BlendTable format');
        end
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          if Table.Bits = 5 then
            case FPixelFormatID of
              pfRGB565: BlendSurface565(Src, Dst, FPitch, SD.Pitch, W, H,
                @TBlendTable5Bit(Table).Table);
              pfRGB555: BlendSurface555(Src, Dst, FPitch, SD.Pitch, W, H,
                @TBlendTable5Bit(Table).Table);
            end
          else
            raise Exception.Create('Invalid BlendTable format');
        end;
      end;
  end;
end;

procedure TPicture16.ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc);
var
  DX, Right, W, H, SX, SY, DY, Bottom: Integer;
  Src, Dst: Pointer;
begin
  DX := X + FXshift;
  W := FDataWidth;
  Right := FDataWidth + DX;
  if DX < SD.ClipRect.Left then
  begin
    SX := SD.ClipRect.Left - X;
    DX := SD.ClipRect.Left;
    Dec(W, SX);
  end
  else
    SX := 0;
  if Right > SD.ClipRect.Right then Dec(W, Right - SD.ClipRect.Right);
  if W > 0 then
  begin
    DY := Y + FYshift;
    H := FDataHeight;
    Bottom := DY + FDataHeight;
    if DY < SD.ClipRect.Top then
    begin
      SY := SD.ClipRect.Top - Y;
      DY := SD.ClipRect.Top;
      Dec(H, SY);
    end
    else
      SY := 0;
    if Bottom > SD.ClipRect.Bottom then Dec(H, Bottom - SD.ClipRect.Bottom);
    if H > 0 then
      if not FDataLoaded then
      begin
        LoadDiscardableImageData;
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
        begin
          if FPixelFormatID = pfRGB565 then
            BltTransparent565(Src, Dst, FPitch, SD.Pitch, W, H)
          else
            BltTransparent555(Src, Dst, FPitch, SD.Pitch, W, H);
        end
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          if FPixelFormatID = pfRGB565 then
            BltTransparent565(Src, Dst, FPitch, SD.Pitch, W, H)
          else
            BltTransparent555(Src, Dst, FPitch, SD.Pitch, W, H);
        end;
        if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
      end
      else
      begin
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
        begin
          if FPixelFormatID = pfRGB565 then
            BltTransparent565(Src, Dst, FPitch, SD.Pitch, W, H)
          else
            BltTransparent555(Src, Dst, FPitch, SD.Pitch, W, H);
        end
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          if FPixelFormatID = pfRGB565 then
            BltTransparent565(Src, Dst, FPitch, SD.Pitch, W, H)
          else
            BltTransparent555(Src, Dst, FPitch, SD.Pitch, W, H);
        end;
      end;
  end;
end;

type
  PIntArray = ^TIntArray;
  TIntArray = array[0..MaxInt div 4 - 1] of Integer;

{ The stretched blits use a table of the source row addresses and a table of the source
  columns, in 16.16 fixed point steps. The vertical scale is taken from FHeight, the
  horizontal one from FDataWidth (an original inconsistency). }

procedure TPicture16.ShowOpaqueStretched(const R: TRect; const SD: TSurfaceDesc);
var
  RowTable: PIntArray;
  ColTable: PIntArray;
  W: Integer;
  Dst: Pointer;
  XPos, YPos, XStep, YStep: Integer;
  SX, SY: Integer;
  XScale, YScale: Single;
  H, L, T, Rt, B, I, C, D: Integer;
begin
  W := R.Right - R.Left;
  H := R.Bottom - R.Top;
  if (W > 0) and (H > 0) then
  begin
    XScale := W / FDataWidth;
    YScale := H / FHeight;
    L := R.Left;
    if L < SD.ClipRect.Left then
    begin
      SX := SD.ClipRect.Left - L;
      Inc(L, SX);
    end
    else
      SX := 0;
    T := R.Top;
    if T < SD.ClipRect.Top then
    begin
      SY := SD.ClipRect.Top - T;
      Inc(T, SY);
    end
    else
      SY := 0;
    Rt := R.Right;
    if Rt > SD.ClipRect.Right then
    begin
      D := Rt - SD.ClipRect.Right;
      Dec(Rt, D);
    end;
    B := R.Bottom;
    if B > SD.ClipRect.Bottom then
    begin
      D := B - SD.ClipRect.Bottom;
      Dec(B, D);
    end;
    W := Rt - L;
    H := B - T;
    if (W > 0) and (H > 0) then
    begin
      Dst := Pointer(Integer(SD.Data) + L * 2 + SD.Pitch * T);
      GetMem(RowTable, (W + H) * 4);
      ColTable := PIntArray(Integer(RowTable) + H * 4);
      XStep := Round(65535 / XScale);
      if SX <> 0 then
        XPos := Round(SX / XScale * 65535)
      else
        XPos := 0;
      for I := 0 to W - 1 do
      begin
        C := XPos shr 16;
        if C >= FDataWidth then C := FDataWidth - 1;
        ColTable^[I] := C;
        Inc(XPos, XStep);
      end;
      YStep := Round(65535 / YScale);
      if SY <> 0 then
        YPos := Round(SY / YScale * 65535)
      else
        YPos := 0;
      if not FDataLoaded then
      begin
        LoadDiscardableImageData;
        for I := 0 to H - 1 do
        begin
          C := YPos shr 16;
          if C >= FDataHeight then C := FDataHeight - 1;
          RowTable^[I] := C * FPitch + Integer(FData);
          Inc(YPos, YStep);
        end;
        if SD.PixelFormatID = FPixelFormatID then
          BltStretched16(RowTable, ColTable, Dst, SD.Pitch, W, H)
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          BltStretched16(RowTable, ColTable, Dst, SD.Pitch, W, H);
        end;
        if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
      end
      else
      begin
        for I := 0 to H - 1 do
        begin
          C := YPos shr 16;
          if C >= FDataHeight then C := FDataHeight - 1;
          RowTable^[I] := C * FPitch + Integer(FData);
          Inc(YPos, YStep);
        end;
        if SD.PixelFormatID = FPixelFormatID then
          BltStretched16(RowTable, ColTable, Dst, SD.Pitch, W, H)
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          BltStretched16(RowTable, ColTable, Dst, SD.Pitch, W, H);
        end;
      end;
      FreeMem(RowTable, (H + W) * 4);
    end;
  end;
end;

procedure TPicture16.ShowBlendedStretched(const R: TRect; const SD: TSurfaceDesc;
  Table: TBlendTable);
var
  RowTable: PIntArray;
  ColTable: PIntArray;
  W, H, Rt: Integer;
  Dst: Pointer;
  XPos, YPos, XStep, YStep: Integer;
  SX, SY: Integer;
  XScale, YScale: Single;
  L, T, B, I, C, D: Integer;
begin
  W := R.Right - R.Left;
  H := R.Bottom - R.Top;
  if (W > 0) and (H > 0) then
  begin
    XScale := W / FDataWidth;
    YScale := H / FHeight;
    L := R.Left;
    if L < SD.ClipRect.Left then
    begin
      SX := SD.ClipRect.Left - L;
      Inc(L, SX);
    end
    else
      SX := 0;
    T := R.Top;
    if T < SD.ClipRect.Top then
    begin
      SY := SD.ClipRect.Top - T;
      Inc(T, SY);
    end
    else
      SY := 0;
    Rt := R.Right;
    if Rt > SD.ClipRect.Right then
    begin
      D := Rt - SD.ClipRect.Right;
      Dec(Rt, D);
    end;
    B := R.Bottom;
    if B > SD.ClipRect.Bottom then
    begin
      D := B - SD.ClipRect.Bottom;
      Dec(B, D);
    end;
    W := Rt - L;
    H := B - T;
    if (W > 0) and (H > 0) then
    begin
      Dst := Pointer(Integer(SD.Data) + L * 2 + SD.Pitch * T);
      GetMem(RowTable, (W + H) * 4);
      ColTable := PIntArray(Integer(RowTable) + H * 4);
      XStep := Round(65535 / XScale);
      if SX <> 0 then
        XPos := Round(SX / XScale * 65535)
      else
        XPos := 0;
      for I := 0 to W - 1 do
      begin
        C := XPos shr 16;
        if C >= FDataWidth then C := FDataWidth - 1;
        ColTable^[I] := C;
        Inc(XPos, XStep);
      end;
      YStep := Round(65535 / YScale);
      if SY <> 0 then
        YPos := Round(SY / YScale * 65535)
      else
        YPos := 0;
      if not FDataLoaded then
      begin
        LoadDiscardableImageData;
        for I := 0 to H - 1 do
        begin
          C := YPos shr 16;
          if C >= FDataHeight then C := FDataHeight - 1;
          RowTable^[I] := C * FPitch + Integer(FData);
          Inc(YPos, YStep);
        end;
        if SD.PixelFormatID = FPixelFormatID then
          case SD.PixelFormatID of
            pfRGB555: BlendStretched555(RowTable, ColTable, Dst, SD.Pitch, W, H,
              @TBlendTable5Bit(Table).Table);
            pfRGB565: BlendStretched565(RowTable, ColTable, Dst, SD.Pitch, W, H,
              @TBlendTable5Bit(Table).Table);
          end
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          case SD.PixelFormatID of
            pfRGB555: BlendStretched555(RowTable, ColTable, Dst, SD.Pitch, W, H,
              @TBlendTable5Bit(Table).Table);
            pfRGB565: BlendStretched565(RowTable, ColTable, Dst, SD.Pitch, W, H,
              @TBlendTable5Bit(Table).Table);
          end;
        end;
        if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
      end
      else
      begin
        for I := 0 to H - 1 do
        begin
          C := YPos shr 16;
          if C >= FDataHeight then C := FDataHeight - 1;
          RowTable^[I] := C * FPitch + Integer(FData);
          Inc(YPos, YStep);
        end;
        if SD.PixelFormatID = FPixelFormatID then
          case SD.PixelFormatID of
            pfRGB555: BlendStretched555(RowTable, ColTable, Dst, SD.Pitch, W, H,
              @TBlendTable5Bit(Table).Table);
            pfRGB565: BlendStretched565(RowTable, ColTable, Dst, SD.Pitch, W, H,
              @TBlendTable5Bit(Table).Table);
          end
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          case SD.PixelFormatID of
            pfRGB555: BlendStretched555(RowTable, ColTable, Dst, SD.Pitch, W, H,
              @TBlendTable5Bit(Table).Table);
            pfRGB565: BlendStretched565(RowTable, ColTable, Dst, SD.Pitch, W, H,
              @TBlendTable5Bit(Table).Table);
          end;
        end;
      end;
      FreeMem(RowTable, (W + H) * 4);
    end;
  end;
end;

{ TTransparentPicture16 }

constructor TTransparentPicture16.Create(AOwner: TCustomImageLibrary);
begin
  inherited Create(AOwner);
  FShowInfo.ShowMode := smTransparent;
end;

class function TTransparentPicture16.ClassID: Integer;
begin
  Result := $15;
end;

class function TTransparentPicture16.Name: string;
begin
  Result := 'Transparent Picture (16bpp)';
end;

function TTransparentPicture16.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := False;
end;

{ The run length encoded sprites. The helpers are assembler with the pascal convention: the
  remappers convert the pixels of the rows in place (a pixel that becomes the color key is
  changed by one step, so that it stays a pixel), the blitters clip to SD.ClipRect. }

procedure RemapRLE565to555(Data: Pointer; Height, ColorKey: Integer); pascal; forward;
procedure RemapRLE555to565(Data: Pointer; Height, ColorKey: Integer); pascal; forward;
procedure BltRLE16(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer; Width, Height,
  ColorKey: Integer); pascal; forward;
procedure BlendRLE565(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer; Width, Height,
  ColorKey: Integer); pascal; forward;
procedure BlendRLE555(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer; Width, Height,
  ColorKey: Integer); pascal; forward;

{ TRLESprite16 }

constructor TRLESprite16.Create(AOwner: TCustomImageLibrary);
begin
  inherited Create(AOwner);
end;

class function TRLESprite16.ClassID: Integer;
begin
  Result := $11;
end;

class function TRLESprite16.Name: string;
begin
  Result := 'RLE Sprite (16bpp)';
end;

procedure TRLESprite16.SetXshift(Value: Integer);
begin
  if Value < -FSpriteX then Value := -FSpriteX;
  inherited SetXshift(Value);
  SetWidth(FWidth);
end;

procedure TRLESprite16.SetYshift(Value: Integer);
begin
  if Value < -FSpriteY then Value := -FSpriteY;
  inherited SetYshift(Value);
  SetHeight(FHeight);
end;

procedure TRLESprite16.SetWidth(Value: Integer);
var
  W: Integer;
begin
  W := FXshift + FSpriteX + FSpriteWidth;
  if Value < W then Value := W;
  inherited SetWidth(Value);
end;

procedure TRLESprite16.SetHeight(Value: Integer);
var
  W: Integer;
begin
  W := FYshift + FSpriteY + FSpriteHeight;
  if Value < W then Value := W;
  inherited SetHeight(Value);
end;

procedure TRLESprite16.GetVisualDimensions(var R: TRect);
begin
  R.Left := FXshift + FSpriteX;
  R.Right := R.Left + FSpriteWidth;
  R.Top := FYshift + FSpriteY;
  R.Bottom := R.Top + FSpriteHeight;
end;

procedure TRLESprite16.ReleaseDiscardableImageData;
begin
  if FDataLoaded then
  begin
    ReallocMem(FData, 0);
    FDataLoaded := False;
  end;
end;

{ The last dword of the image data is not used: ReadImageData skips it and WriteImageData
  writes an uninitialized local variable (an original bug). }
procedure TRLESprite16.ReadImageData(Stream: TStream);
var
  Reserved: Integer;
begin
  inherited ReadImageData(Stream);
  Stream.Read(FSpriteWidth, 4);
  Stream.Read(FSpriteHeight, 4);
  Stream.Read(FSpriteX, 4);
  Stream.Read(FSpriteY, 4);
  Stream.Read(FColorKey, 4);
  Stream.Read(Reserved, 4);
end;

procedure TRLESprite16.WriteImageData(Stream: TStream);
var
  Reserved: Integer;
begin
  inherited WriteImageData(Stream);
  Stream.Write(FSpriteWidth, 4);
  Stream.Write(FSpriteHeight, 4);
  Stream.Write(FSpriteX, 4);
  Stream.Write(FSpriteY, 4);
  Stream.Write(FColorKey, 4);
  Stream.Write(Reserved, 4);
end;

procedure TRLESprite16.ReadDiscardableImageData(Stream: TStream);
begin
  inherited ReadDiscardableImageData(Stream);
  ReallocMem(FData, FDataSize);
  Stream.Read(FData^, FDataSize);
end;

procedure TRLESprite16.WriteDiscardableImageData(Stream: TStream);
begin
  inherited WriteDiscardableImageData(Stream);
  Stream.Write(FData^, FDataSize);
end;

function TRLESprite16.RemapToPixelFormat(PixelFormatID: Integer): HResult;
begin
  Result := 0;
  if PixelFormatID <> FPixelFormatID then
    case PixelFormatID of
      pfRGB565:
        begin
          RemapRLE555to565(FData, FSpriteHeight, FColorKey);
          FPixelFormatID := pfRGB565;
        end;
      pfRGB555:
        begin
          RemapRLE565to555(FData, FSpriteHeight, FColorKey);
          FPixelFormatID := pfRGB555;
        end;
    else
      Result := GFXE_NOTSUPPORTED;
    end;
end;

function TRLESprite16.SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean;
begin
  Result := ((PixelFormatID = 0) or (PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555)) and
    (ShowMode in [smOpaque, smTransparent]);
end;

procedure TRLESprite16.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
begin
  if not FDataLoaded then
  begin
    LoadDiscardableImageData;
    if SD.PixelFormatID = FPixelFormatID then
      BltRLE16(X + FXshift + FSpriteX, Y + FYshift + FSpriteY, SD, FData, FSpriteWidth,
        FSpriteHeight, FColorKey)
    else
    begin
      if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
        raise Exception.Create('Surface pixel format not supported!');
      BltRLE16(X + FXshift + FSpriteX, Y + FYshift + FSpriteY, SD, FData, FSpriteWidth,
        FSpriteHeight, FColorKey);
    end;
    if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
  end
  else
  begin
    if SD.PixelFormatID = FPixelFormatID then
      BltRLE16(X + FXshift + FSpriteX, Y + FYshift + FSpriteY, SD, FData, FSpriteWidth,
        FSpriteHeight, FColorKey)
    else
    begin
      if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
        raise Exception.Create('Surface pixel format not supported!');
      BltRLE16(X + FXshift + FSpriteX, Y + FYshift + FSpriteY, SD, FData, FSpriteWidth,
        FSpriteHeight, FColorKey);
    end;
  end;
end;

{ ShowTransparent shows the sprite blended 50% }
procedure TRLESprite16.ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc);
begin
  if not FDataLoaded then
  begin
    LoadDiscardableImageData;
    if (SD.PixelFormatID <> FPixelFormatID) and (RemapToPixelFormat(SD.PixelFormatID) <> 0) then
      raise Exception.Create('Surface pixel format not supported!');
    case FPixelFormatID of
      pfRGB565: BlendRLE565(X + FXshift + FSpriteX, Y + FYshift + FSpriteY, SD, FData,
        FSpriteWidth, FSpriteHeight, FColorKey);
      pfRGB555: BlendRLE555(X + FXshift + FSpriteX, Y + FYshift + FSpriteY, SD, FData,
        FSpriteWidth, FSpriteHeight, FColorKey);
    end;
    if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
  end
  else
  begin
    if (SD.PixelFormatID <> FPixelFormatID) and (RemapToPixelFormat(SD.PixelFormatID) <> 0) then
      raise Exception.Create('Surface pixel format not supported!');
    case FPixelFormatID of
      pfRGB565: BlendRLE565(X + FXshift + FSpriteX, Y + FYshift + FSpriteY, SD, FData,
        FSpriteWidth, FSpriteHeight, FColorKey);
      pfRGB555: BlendRLE555(X + FXshift + FSpriteX, Y + FYshift + FSpriteY, SD, FData,
        FSpriteWidth, FSpriteHeight, FColorKey);
    end;
  end;
end;

function TRLESprite16.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := (PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555) or
    (PixelFormatID = pfRGB24) or (PixelFormatID = pfPAL8);
end;

function TRLESprite16.CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
  OnImagesGrabbed: TImagesGrabbedEvent): TForm;
begin
  Result := nil;
end;

{ The sprites take their transparent color from TGrabInfo +$C (declared Reserved in the core),
  not from TransparentColor (+4, the color GetSurfaceRectangles separates the images with).

  GrabImage encodes the rows into FData, which grows in 4 KB steps; FDataSize stays 0 until the
  end, so every word added past the first step reallocates (an original inefficiency). }
function TRLESprite16.GrabImage(const SD: TSurfaceDesc; const R: TRect;
  GrabInfo: TGrabInfo): Boolean;
var
  Pos, RowStart, Skip: Integer;
  Surface: TDataSurface;
  Row: Pointer;
  Y: Integer;
  LSD: TSurfaceDesc;
  GR, MR: TRect;
  X, C: Integer;

  procedure AddWord(W: Word);
  begin
    if FDataSize <= Pos then ReallocMem(FData, Pos + $1000);
    PWord(Integer(FData) + Pos)^ := W;
    Inc(Pos, 2);
  end;

  procedure StartRow;
  begin
    RowStart := Pos;
    AddWord(0);
    AddWord(0);
  end;

  procedure FlushSkip;
  begin
    if Skip <> 0 then
    begin
      AddWord(FColorKey);
      AddWord(Skip * 2);
      Skip := 0;
    end;
  end;

  procedure EndRow;
  begin
    FlushSkip;
    if FDataSize <= Pos then ReallocMem(FData, Pos + $1000);
    PWord(Integer(FData) + RowStart)^ := Pos - RowStart;
    if Pos and 3 <> 0 then AddWord(FColorKey);
  end;

begin
  Result := True;
  try
    Surface := nil;
    try
      if SD.BitCount <> 16 then
      begin
        Surface := TDataSurface.Create(R.Right - R.Left, R.Bottom - R.Top, pfRGB565, nil);
        GR.Left := 0;
        GR.Top := 0;
        GR.Right := Surface.GetWidth;
        GR.Bottom := Surface.GetHeight;
        Surface.Lock(LSD);
        if RemapSurfacePart(SD, R.Left, R.Top, Surface.GetWidth, Surface.GetHeight, LSD, 0, 0) <> 0 then
          raise Exception.Create('Invalid PixelFormat');
        FColorKey := RemapPixelInfo(GrabInfo.TransparentPixel, SD.PixelFormatID, SD.Palette,
          LSD.PixelFormatID, nil);
      end
      else
      begin
        LSD := SD;
        GR := R;
        FColorKey := GrabInfo.TransparentPixel;
      end;
      Clear;
      FDataLoaded := True;
      FDataWidth := GR.Right - GR.Left;
      FDataHeight := GR.Bottom - GR.Top;
      FWidth := FDataWidth;
      FHeight := FDataHeight;
      FFileName := ExtractFileName(GrabInfo.FileName);
      FFileIndex := GrabInfo.FileIndex;
      FStoredPixelFormatID := LSD.PixelFormatID;
      FPixelFormatID := FStoredPixelFormatID;
      Pos := 0;
      Skip := 0;
      MinimizeTransparentRect(LSD, GR, FColorKey, MR);
      FSpriteX := MR.Left - GR.Left;
      FSpriteY := MR.Top - GR.Top;
      FSpriteWidth := MR.Right - MR.Left;
      FSpriteHeight := MR.Bottom - MR.Top;
      for Y := MR.Top to MR.Bottom - 1 do
      begin
        Row := Pointer(LSD.Pitch * Y + Integer(LSD.Data));
        StartRow;
        for X := MR.Left to MR.Right - 1 do
        begin
          C := PWord(Integer(Row) + X + X)^;
          if C <> FColorKey then
          begin
            FlushSkip;
            AddWord(C);
          end
          else
            Inc(Skip);
        end;
        EndRow;
      end;
      ReallocMem(FData, Pos);
      FDataSize := Pos;
    finally
      if Surface <> nil then Surface.Destroy;
    end;
  except
    ReleaseDiscardableImageData;
    Result := False;
  end;
end;

procedure RemapRLE565to555(Data: Pointer; Height, ColorKey: Integer); pascal;
asm
        push    edi
        push    esi
        push    ebx
        mov     esi, Data
        mov     edi, Height
        mov     eax, ColorKey
        test    edi, edi
        je      @@5
        xor     ebx, ebx
        mov     ecx, dword ptr [esi]
        lea     esi, [esi+4]
        lea     ecx, [ecx-4]
@@1:
        test    ecx, ecx
        je      @@4
        mov     bx, word ptr [esi]
        lea     ecx, [ecx-2]
        cmp     ebx, eax
        je      @@3
        mov     edx, ebx
        shr     ebx, 1
        lea     esi, [esi+2]
        and     ebx, $0FFE0
        and     edx, $1F
        or      edx, ebx
        cmp     edx, eax
        je      @@2
        mov     word ptr [esi-2], dx
        jmp     @@1
@@2:
        add     edx, $400
        mov     word ptr [esi-2], dx
        jmp     @@1
@@3:
        mov     bx, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     ecx, [ecx-2]
        jmp     @@1
@@4:
        lea     esi, [esi+7]
        and     esi, -4
        dec     edi
        je      @@5
        mov     ecx, dword ptr [esi-4]
        lea     ecx, [ecx-4]
        jmp     @@1
@@5:
        pop     ebx
        pop     esi
        pop     edi
end;

procedure RemapRLE555to565(Data: Pointer; Height, ColorKey: Integer); pascal;
asm
        push    edi
        push    esi
        push    ebx
        mov     esi, Data
        mov     edi, Height
        mov     eax, ColorKey
        test    edi, edi
        je      @@5
        xor     ebx, ebx
        mov     ecx, dword ptr [esi]
        lea     esi, [esi+4]
        lea     ecx, [ecx-4]
@@1:
        test    ecx, ecx
        je      @@4
        mov     bx, word ptr [esi]
        lea     ecx, [ecx-2]
        cmp     ebx, eax
        je      @@3
        mov     edx, ebx
        shl     ebx, 1
        lea     esi, [esi+2]
        and     ebx, $0FFC0
        and     edx, $1F
        or      edx, ebx
        cmp     edx, eax
        je      @@2
        mov     word ptr [esi-2], dx
        jmp     @@1
@@2:
        inc     edx
        mov     word ptr [esi-2], dx
        jmp     @@1
@@3:
        mov     bx, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     ecx, [ecx-2]
        jmp     @@1
@@4:
        lea     esi, [esi+7]
        and     esi, -4
        dec     edi
        je      @@5
        mov     ecx, dword ptr [esi-4]
        lea     ecx, [ecx-4]
        jmp     @@1
@@5:
        pop     ebx
        pop     esi
        pop     edi
end;

procedure BltRLE16(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer; Width, Height,
  ColorKey: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9: Integer;
asm
        push    edi
        push    esi
        push    ebx
        mov     esi, Data
        mov     edi, SD
        mov     L1, esp
        mov     eax, X
        mov     ebx, Y
        mov     ecx, Width
        mov     edx, Height
        test    ecx, ecx
        je      @@24
        test    edx, edx
        je      @@24
        add     ecx, eax
        add     edx, ebx
        mov     L2, ecx
        mov     L3, edx
        cmp     ecx, dword ptr [edi+$10]
        js      @@24
        cmp     edx, dword ptr [edi+$14]
        js      @@24
        cmp     eax, dword ptr [edi+$18]
        jge     @@24
        cmp     ebx, dword ptr [edi+$1C]
        jge     @@24
        mov     ecx, Y
        mov     ebx, Height
        mov     eax, dword ptr [edi+$14]
        sub     edx, dword ptr [edi+$1C]
        jle     @@1
        sub     ebx, edx
@@1:
        sub     eax, ecx
        jle     @@3
        xor     edx, edx
        add     ecx, eax
        sub     ebx, eax
        je      @@24
@@2:
        mov     dx, word ptr [esi]
        lea     esi, [esi+edx+3]
        and     esi, $0FFFFFFC
        dec     eax
        jne     @@2
@@3:
        mov     Height, ebx
        mov     Y, ecx
        mov     esp, ColorKey
        mov     eax, X
        mov     ecx, L2
        cmp     eax, dword ptr [edi+$10]
        js      @@15
        cmp     ecx, dword ptr [edi+$18]
        jg      @@15
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mov     edi, dword ptr [edi+$20]
        mul     ecx
        lea     edi, [edi+ebx*2]
        mov     L4, ecx
        lea     edi, [edi+eax]
        xor     eax, eax
        mov     ecx, ColorKey
        shl     ecx, $10
        mov     L5, ecx
        mov     ecx, dword ptr [esi]
        mov     L6, edi
        lea     esi, [esi+4]
        lea     ecx, [ecx-4]
@@4:
        cmp     ecx, 8
        jb      @@12
        mov     eax, dword ptr [esi]
        lea     edi, [edi+8]
        mov     edx, eax
        and     eax, $0FFFF
        cmp     eax, esp
        je      @@6
        and     edx, $0FFFF0000
        lea     esi, [esi+8]
        cmp     edx, L5
        je      @@7
        mov     ebx, dword ptr [esi-4]
        or      eax, edx
        mov     edx, ebx
        mov     dword ptr [edi-8], eax
        and     ebx, $0FFFF
        mov     eax, edx
        cmp     ebx, esp
        je      @@8
        and     edx, $0FFFF0000
        lea     ecx, [ecx-8]
@@5:
        cmp     edx, L5
        je      @@9
        mov     dword ptr [edi-4], eax
        jmp     @@4
@@6:
        shr     edx, $10
        mov     ebx, dword ptr [esi+4]
        lea     esi, [esi+8]
        lea     ecx, [ecx-8]
        lea     edi, [edi+edx-4]
        mov     eax, ebx
        mov     edx, ebx
        and     ebx, $0FFFF
        and     edx, $0FFFF0000
        jmp     @@5
@@7:
        mov     ebx, dword ptr [esi-4]
        mov     byte ptr [edi-8], al
        mov     edx, ebx
        and     ebx, $0FFFF
        mov     byte ptr [edi-7], ah
        lea     edi, [edi+ebx-4]
        shr     edx, $10
        lea     ecx, [ecx-8]
        mov     word ptr [edi-2], dx
        jmp     @@4
@@8:
        shr     edx, $10
        sub     edi, 4
        lea     ecx, [ecx-8]
        add     edi, edx
        jmp     @@4
@@9:
        mov     word ptr [edi-4], bx
        mov     bx, word ptr [esi]
        lea     esi, [esi+2]
        lea     ecx, [ecx-2]
        lea     edi, [edi+ebx-2]
@@10:
        test    ecx, ecx
        je      @@14
        mov     bx, word ptr [esi]
        lea     ecx, [ecx-2]
        cmp     ebx, esp
        je      @@11
        mov     word ptr [edi], bx
        lea     esi, [esi+2]
        lea     edi, [edi+2]
        jmp     @@4
@@11:
        mov     bx, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     ecx, [ecx-2]
        add     edi, ebx
        jmp     @@10
@@12:
        test    ecx, ecx
        je      @@14
        mov     bx, word ptr [esi]
        lea     ecx, [ecx-2]
        cmp     ebx, esp
        je      @@13
        mov     word ptr [edi], bx
        lea     esi, [esi+2]
        lea     edi, [edi+2]
        jmp     @@12
@@13:
        mov     bx, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     ecx, [ecx-2]
        add     edi, ebx
        jmp     @@12
@@14:
        lea     esi, [esi+7]
        mov     edi, L6
        and     esi, -4
        add     edi, L4
        dec     Height
        je      @@24
        mov     ecx, dword ptr [esi-4]
        mov     L6, edi
        lea     ecx, [ecx-4]
        jmp     @@4
@@15:
        mov     edx, dword ptr [edi+$10]
        mov     eax, X
        sub     edx, eax
        lea     edx, [edx*2]
        jns     @@16
        xor     edx, edx
@@16:
        mov     L7, edx
        mov     ecx, L2
        mov     eax, dword ptr [edi+$18]
        sub     ecx, eax
        lea     ecx, [ecx*2]
        jns     @@17
        xor     ecx, ecx
@@17:
        mov     L8, ecx
        mov     eax, Width
        mov     ebx, ColorKey
        add     eax, eax
        shl     ebx, $10
        sub     eax, edx
        mov     L5, ebx
        sub     eax, ecx
        je      @@24
        mov     L9, eax
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mov     edi, dword ptr [edi+$20]
        mul     ecx
        lea     edi, [edi+ebx*2]
        mov     L4, ecx
        lea     edi, [edi+eax]
        xor     eax, eax
        mov     L6, edi
        mov     ecx, edi
        mov     ebx, dword ptr [esi]
        add     ecx, L7
        lea     ebx, [ebx+esi+3]
        lea     esi, [esi+4]
        and     ebx, -4
@@18:
        cmp     edi, ecx
        jae     @@20
        mov     ax, word ptr [esi]
        cmp     eax, esp
        je      @@19
        lea     edi, [edi+2]
        lea     esi, [esi+2]
        jmp     @@18
@@19:
        mov     ax, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     edi, [edi+eax]
        jmp     @@18
@@20:
        add     ecx, L9
        cmp     edi, ecx
        jae     @@23
@@21:
        mov     ax, word ptr [esi]
        cmp     eax, esp
        je      @@22
        mov     word ptr [edi], ax
        lea     edi, [edi+2]
        lea     esi, [esi+2]
        cmp     edi, ecx
        js      @@21
        jmp     @@23
@@22:
        mov     ax, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     edi, [edi+eax]
        cmp     edi, ecx
        js      @@21
@@23:
        mov     esi, ebx
        mov     edi, L6
        dec     Height
        je      @@24
        mov     ebx, dword ptr [esi]
        add     edi, L4
        lea     ebx, [ebx+esi+3]
        lea     esi, [esi+4]
        and     ebx, -4
        mov     ecx, edi
        mov     L6, edi
        add     ecx, L7
        jmp     @@18
@@24:
        mov     esp, L1
        pop     ebx
        pop     esi
        pop     edi
end;

{ TTransparentRLESprite16 }

constructor TTransparentRLESprite16.Create(AOwner: TCustomImageLibrary);
begin
  inherited Create(AOwner);
  FShowInfo.ShowMode := smTransparent;
end;

class function TTransparentRLESprite16.ClassID: Integer;
begin
  Result := $12;
end;

class function TTransparentRLESprite16.Name: string;
begin
  Result := 'Transparent RLE Sprite (16bpp)';
end;

function TTransparentRLESprite16.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := False;
end;

{ The 50% blends of a RLE sprite (TRLESprite16.ShowTransparent) }

procedure BlendRLE565(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer; Width, Height,
  ColorKey: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9: Integer;
asm
        push    edi
        push    esi
        push    ebx
        mov     esi, Data
        mov     edi, SD
        mov     L1, esp
        mov     eax, X
        mov     ebx, Y
        mov     ecx, Width
        mov     edx, Height
        add     ecx, eax
        add     edx, ebx
        mov     L2, ecx
        mov     L3, edx
        cmp     ecx, dword ptr [edi+$10]
        js      @@24
        cmp     edx, dword ptr [edi+$14]
        js      @@24
        cmp     eax, dword ptr [edi+$18]
        jge     @@24
        cmp     ebx, dword ptr [edi+$1C]
        jge     @@24
        mov     ecx, Y
        mov     ebx, Height
        mov     eax, dword ptr [edi+$14]
        sub     edx, dword ptr [edi+$1C]
        jle     @@1
        sub     ebx, edx
@@1:
        sub     eax, ecx
        jle     @@3
        xor     edx, edx
        add     ecx, eax
        sub     ebx, eax
        je      @@24
@@2:
        mov     dx, word ptr [esi]
        lea     esi, [esi+edx+3]
        and     esi, $0FFFFFFC
        dec     eax
        jne     @@2
@@3:
        mov     Height, ebx
        mov     Y, ecx
        mov     esp, ColorKey
        mov     eax, X
        mov     ecx, L2
        cmp     eax, dword ptr [edi+$10]
        js      @@15
        cmp     ecx, dword ptr [edi+$18]
        jg      @@15
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mov     edi, dword ptr [edi+$20]
        mul     ecx
        lea     edi, [edi+ebx*2]
        mov     L4, ecx
        lea     edi, [edi+eax]
        xor     eax, eax
        mov     ecx, ColorKey
        shl     ecx, $10
        mov     L5, ecx
        mov     ecx, dword ptr [esi]
        mov     L6, edi
        lea     esi, [esi+4]
        lea     ecx, [ecx-4]
@@4:
        cmp     ecx, 8
        jb      @@12
        mov     eax, dword ptr [esi]
        lea     edi, [edi+8]
        mov     edx, eax
        and     eax, $0FFFF
        cmp     eax, esp
        je      @@6
        and     edx, $0FFFF0000
        lea     esi, [esi+8]
        cmp     edx, L5
        je      @@7
        mov     ebx, dword ptr [esi-4]
        or      eax, edx
        mov     edx, dword ptr [edi-8]
        and     eax, $0F7DEF7DF
        and     edx, $0F7DEF7DF
        add     eax, edx
        mov     edx, ebx
        rcr     eax, 1
        and     ebx, $0FFFF
        mov     dword ptr [edi-8], eax
        mov     eax, edx
        cmp     ebx, esp
        je      @@8
        and     edx, $0FFFF0000
        lea     ecx, [ecx-8]
@@5:
        cmp     edx, L5
        je      @@9
        mov     edx, dword ptr [edi-4]
        and     eax, $0F7DEF7DF
        and     edx, $0F7DEF7DF
        add     eax, edx
        rcr     eax, 1
        mov     dword ptr [edi-4], eax
        jmp     @@4
@@6:
        shr     edx, $10
        mov     ebx, dword ptr [esi+4]
        lea     esi, [esi+8]
        lea     ecx, [ecx-8]
        lea     edi, [edi+edx-4]
        mov     eax, ebx
        mov     edx, ebx
        and     ebx, $0FFFF
        and     edx, $0FFFF0000
        jmp     @@5
@@7:
        mov     dx, word ptr [edi-8]
        mov     ebx, dword ptr [esi-4]
        and     eax, $0F7DF
        and     edx, $0F7DF
        add     eax, edx
        shr     eax, 1
        mov     edx, ebx
        and     ebx, $0FFFF
        mov     word ptr [edi-8], ax
        shr     edx, $10
        lea     ecx, [ecx-8]
        lea     edi, [edi+ebx-4]
        and     edx, $0F7DF
        mov     ebx, dword ptr [edi-2]
        and     ebx, $0F7DF
        add     edx, ebx
        shr     edx, 1
        mov     word ptr [edi-2], dx
        jmp     @@4
@@8:
        shr     edx, $10
        sub     edi, 4
        lea     ecx, [ecx-8]
        add     edi, edx
        jmp     @@4
@@9:
        mov     dx, word ptr [edi-4]
        and     ebx, $0F7DF
        and     edx, $0F7DF
        lea     ecx, [ecx-2]
        add     ebx, edx
        mov     dx, word ptr [esi]
        shr     ebx, 1
        lea     esi, [esi+2]
        mov     word ptr [edi-4], bx
        lea     edi, [edi+edx-2]
@@10:
        test    ecx, ecx
        je      @@14
        mov     bx, word ptr [esi]
        lea     ecx, [ecx-2]
        cmp     ebx, esp
        je      @@11
        mov     dx, word ptr [edi]
        and     edx, $0F7DF
        and     ebx, $0F7DF
        lea     esi, [esi+2]
        add     ebx, edx
        shr     ebx, 1
        mov     word ptr [edi], bx
        lea     edi, [edi+2]
        jmp     @@4
@@11:
        mov     bx, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     ecx, [ecx-2]
        add     edi, ebx
        jmp     @@10
@@12:
        test    ecx, ecx
        je      @@14
        mov     bx, word ptr [esi]
        lea     ecx, [ecx-2]
        cmp     ebx, esp
        je      @@13
        mov     dx, word ptr [edi]
        and     edx, $0F7DF
        and     ebx, $0F7DF
        lea     esi, [esi+2]
        add     ebx, edx
        shr     ebx, 1
        mov     word ptr [edi], bx
        lea     edi, [edi+2]
        jmp     @@12
@@13:
        mov     bx, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     ecx, [ecx-2]
        add     edi, ebx
        jmp     @@12
@@14:
        lea     esi, [esi+7]
        mov     edi, L6
        and     esi, -4
        add     edi, L4
        dec     Height
        je      @@24
        mov     ecx, dword ptr [esi-4]
        mov     L6, edi
        lea     ecx, [ecx-4]
        jmp     @@4
@@15:
        mov     edx, dword ptr [edi+$10]
        mov     eax, X
        sub     edx, eax
        lea     edx, [edx*2]
        jns     @@16
        xor     edx, edx
@@16:
        mov     L7, edx
        mov     ecx, L2
        mov     eax, dword ptr [edi+$18]
        sub     ecx, eax
        lea     ecx, [ecx*2]
        jns     @@17
        xor     ecx, ecx
@@17:
        mov     L8, ecx
        mov     eax, Width
        mov     ebx, ColorKey
        lea     eax, [eax*2]
        shl     ebx, $10
        sub     eax, edx
        mov     L5, ebx
        sub     eax, ecx
        je      @@24
        mov     L9, eax
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mov     edi, dword ptr [edi+$20]
        mul     ecx
        lea     edi, [edi+ebx*2]
        mov     L4, ecx
        lea     edi, [edi+eax]
        xor     eax, eax
        mov     L6, edi
        mov     ecx, edi
        mov     ebx, dword ptr [esi]
        add     ecx, L7
        lea     ebx, [ebx+esi+3]
        lea     esi, [esi+4]
        and     ebx, -4
@@18:
        cmp     edi, ecx
        jae     @@20
        mov     ax, word ptr [esi]
        cmp     eax, esp
        je      @@19
        lea     edi, [edi+2]
        lea     esi, [esi+2]
        jmp     @@18
@@19:
        mov     ax, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     edi, [edi+eax]
        jmp     @@18
@@20:
        add     ecx, L9
        cmp     edi, ecx
        jae     @@23
@@21:
        mov     ax, word ptr [esi]
        cmp     eax, esp
        je      @@22
        mov     dx, word ptr [edi]
        and     edx, $0F7DF
        and     eax, $0F7DF
        lea     edi, [edi+2]
        add     eax, edx
        shr     eax, 1
        lea     esi, [esi+2]
        mov     word ptr [edi-2], ax
        cmp     edi, ecx
        js      @@21
        jmp     @@23
@@22:
        mov     ax, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     edi, [edi+eax]
        cmp     edi, ecx
        js      @@21
@@23:
        mov     esi, ebx
        mov     edi, L6
        dec     Height
        je      @@24
        mov     ebx, dword ptr [esi]
        add     edi, L4
        lea     ebx, [ebx+esi+3]
        lea     esi, [esi+4]
        and     ebx, -4
        mov     ecx, edi
        mov     L6, edi
        add     ecx, L7
        jmp     @@18
@@24:
        mov     esp, L1
        pop     ebx
        pop     esi
        pop     edi
end;

procedure BlendRLE555(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer; Width, Height,
  ColorKey: Integer); pascal;
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9: Integer;
asm
        push    edi
        push    esi
        push    ebx
        mov     esi, Data
        mov     edi, SD
        mov     L1, esp
        mov     eax, X
        mov     ebx, Y
        mov     ecx, Width
        mov     edx, Height
        add     ecx, eax
        add     edx, ebx
        mov     L2, ecx
        mov     L3, edx
        cmp     ecx, dword ptr [edi+$10]
        js      @@24
        cmp     edx, dword ptr [edi+$14]
        js      @@24
        cmp     eax, dword ptr [edi+$18]
        jge     @@24
        cmp     ebx, dword ptr [edi+$1C]
        jge     @@24
        mov     ecx, Y
        mov     ebx, Height
        mov     eax, dword ptr [edi+$14]
        sub     edx, dword ptr [edi+$1C]
        jle     @@1
        sub     ebx, edx
@@1:
        sub     eax, ecx
        jle     @@3
        xor     edx, edx
        add     ecx, eax
        sub     ebx, eax
        je      @@24
@@2:
        mov     dx, word ptr [esi]
        lea     esi, [esi+edx+3]
        and     esi, $0FFFFFFC
        dec     eax
        jne     @@2
@@3:
        mov     Height, ebx
        mov     Y, ecx
        mov     esp, ColorKey
        mov     eax, X
        mov     ecx, L2
        cmp     eax, dword ptr [edi+$10]
        js      @@15
        cmp     ecx, dword ptr [edi+$18]
        jg      @@15
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mov     edi, dword ptr [edi+$20]
        mul     ecx
        lea     edi, [edi+ebx*2]
        mov     L4, ecx
        lea     edi, [edi+eax]
        xor     eax, eax
        mov     ecx, ColorKey
        shl     ecx, $10
        mov     L5, ecx
        mov     ecx, dword ptr [esi]
        mov     L6, edi
        lea     esi, [esi+4]
        lea     ecx, [ecx-4]
@@4:
        cmp     ecx, 8
        jb      @@12
        mov     eax, dword ptr [esi]
        lea     edi, [edi+8]
        mov     edx, eax
        and     eax, $0FFFF
        cmp     eax, esp
        je      @@6
        and     edx, $0FFFF0000
        lea     esi, [esi+8]
        cmp     edx, L5
        je      @@7
        mov     ebx, dword ptr [esi-4]
        or      eax, edx
        mov     edx, dword ptr [edi-8]
        and     eax, $7BDE7BDF
        and     edx, $7BDE7BDF
        add     eax, edx
        mov     edx, ebx
        rcr     eax, 1
        and     ebx, $0FFFF
        mov     dword ptr [edi-8], eax
        mov     eax, edx
        cmp     ebx, esp
        je      @@8
        and     edx, $0FFFF0000
        lea     ecx, [ecx-8]
@@5:
        cmp     edx, L5
        je      @@9
        mov     edx, dword ptr [edi-4]
        and     eax, $7BDE7BDF
        and     edx, $7BDE7BDF
        add     eax, edx
        rcr     eax, 1
        mov     dword ptr [edi-4], eax
        jmp     @@4
@@6:
        shr     edx, $10
        mov     ebx, dword ptr [esi+4]
        lea     esi, [esi+8]
        lea     ecx, [ecx-8]
        lea     edi, [edi+edx-4]
        mov     eax, ebx
        mov     edx, ebx
        and     ebx, $0FFFF
        and     edx, $0FFFF0000
        jmp     @@5
@@7:
        mov     dx, word ptr [edi-8]
        mov     ebx, dword ptr [esi-4]
        and     eax, $7BDF
        and     edx, $7BDF
        add     eax, edx
        shr     eax, 1
        mov     edx, ebx
        and     ebx, $0FFFF
        mov     word ptr [edi-8], ax
        shr     edx, $10
        lea     ecx, [ecx-8]
        lea     edi, [edi+ebx-4]
        and     edx, $7BDF
        mov     ebx, dword ptr [edi-2]
        and     ebx, $7BDF
        add     edx, ebx
        shr     edx, 1
        mov     word ptr [edi-2], dx
        jmp     @@4
@@8:
        shr     edx, $10
        sub     edi, 4
        lea     ecx, [ecx-8]
        add     edi, edx
        jmp     @@4
@@9:
        mov     dx, word ptr [edi-4]
        and     ebx, $7BDF
        and     edx, $7BDF
        lea     ecx, [ecx-2]
        add     ebx, edx
        mov     dx, word ptr [esi]
        shr     ebx, 1
        lea     esi, [esi+2]
        mov     word ptr [edi-4], bx
        lea     edi, [edi+edx-2]
@@10:
        test    ecx, ecx
        je      @@14
        mov     bx, word ptr [esi]
        lea     ecx, [ecx-2]
        cmp     ebx, esp
        je      @@11
        mov     dx, word ptr [edi]
        and     edx, $7BDF
        and     ebx, $7BDF
        lea     esi, [esi+2]
        add     ebx, edx
        shr     ebx, 1
        mov     word ptr [edi], bx
        lea     edi, [edi+2]
        jmp     @@4
@@11:
        mov     bx, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     ecx, [ecx-2]
        add     edi, ebx
        jmp     @@10
@@12:
        test    ecx, ecx
        je      @@14
        mov     bx, word ptr [esi]
        lea     ecx, [ecx-2]
        cmp     ebx, esp
        je      @@13
        mov     dx, word ptr [edi]
        and     edx, $7BDF
        and     ebx, $7BDF
        lea     esi, [esi+2]
        add     ebx, edx
        shr     ebx, 1
        mov     word ptr [edi], bx
        lea     edi, [edi+2]
        jmp     @@12
@@13:
        mov     bx, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     ecx, [ecx-2]
        add     edi, ebx
        jmp     @@12
@@14:
        lea     esi, [esi+7]
        mov     edi, L6
        and     esi, -4
        add     edi, L4
        dec     Height
        je      @@24
        mov     ecx, dword ptr [esi-4]
        mov     L6, edi
        lea     ecx, [ecx-4]
        jmp     @@4
@@15:
        mov     edx, dword ptr [edi+$10]
        mov     eax, X
        sub     edx, eax
        lea     edx, [edx*2]
        jns     @@16
        xor     edx, edx
@@16:
        mov     L7, edx
        mov     ecx, L2
        mov     eax, dword ptr [edi+$18]
        sub     ecx, eax
        lea     ecx, [ecx*2]
        jns     @@17
        xor     ecx, ecx
@@17:
        mov     L8, ecx
        mov     eax, Width
        mov     ebx, ColorKey
        lea     eax, [eax*2]
        shl     ebx, $10
        sub     eax, edx
        mov     L5, ebx
        sub     eax, ecx
        je      @@24
        mov     L9, eax
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mov     edi, dword ptr [edi+$20]
        mul     ecx
        lea     edi, [edi+ebx*2]
        mov     L4, ecx
        lea     edi, [edi+eax]
        xor     eax, eax
        mov     L6, edi
        mov     ecx, edi
        mov     ebx, dword ptr [esi]
        add     ecx, L7
        lea     ebx, [ebx+esi+3]
        lea     esi, [esi+4]
        and     ebx, -4
@@18:
        cmp     edi, ecx
        jae     @@20
        mov     ax, word ptr [esi]
        cmp     eax, esp
        je      @@19
        lea     edi, [edi+2]
        lea     esi, [esi+2]
        jmp     @@18
@@19:
        mov     ax, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     edi, [edi+eax]
        jmp     @@18
@@20:
        add     ecx, L9
        cmp     edi, ecx
        jae     @@23
@@21:
        mov     ax, word ptr [esi]
        cmp     eax, esp
        je      @@22
        mov     dx, word ptr [edi]
        and     edx, $7BDF
        and     eax, $7BDF
        lea     edi, [edi+2]
        add     eax, edx
        shr     eax, 1
        lea     esi, [esi+2]
        mov     word ptr [edi-2], ax
        cmp     edi, ecx
        js      @@21
        jmp     @@23
@@22:
        mov     ax, word ptr [esi+2]
        lea     esi, [esi+4]
        lea     edi, [edi+eax]
        cmp     edi, ecx
        js      @@21
@@23:
        mov     esi, ebx
        mov     edi, L6
        dec     Height
        je      @@24
        mov     ebx, dword ptr [esi]
        add     edi, L4
        lea     ebx, [ebx+esi+3]
        lea     esi, [esi+4]
        and     ebx, -4
        mov     ecx, edi
        mov     L6, edi
        add     ecx, L7
        jmp     @@18
@@24:
        mov     esp, L1
        pop     ebx
        pop     esi
        pop     edi
end;

{ TSprite16 }

constructor TSprite16.Create(AOwner: TCustomImageLibrary);
begin
  inherited Create(AOwner);
end;

class function TSprite16.ClassID: Integer;
begin
  Result := $16;
end;

class function TSprite16.Name: string;
begin
  Result := 'Sprite (16bpp)';
end;

procedure TSprite16.SetXshift(Value: Integer);
begin
  if Value < -FSpriteX then Value := -FSpriteX;
  inherited SetXshift(Value);
  SetWidth(FWidth);
end;

procedure TSprite16.SetYshift(Value: Integer);
begin
  if Value < -FSpriteY then Value := -FSpriteY;
  inherited SetYshift(Value);
  SetHeight(FHeight);
end;

procedure TSprite16.SetWidth(Value: Integer);
var
  W: Integer;
begin
  W := FXshift + FSpriteX + FSpriteWidth;
  if Value < W then Value := W;
  inherited SetWidth(Value);
end;

procedure TSprite16.SetHeight(Value: Integer);
var
  W: Integer;
begin
  W := FYshift + FSpriteY + FSpriteHeight;
  if Value < W then Value := W;
  inherited SetHeight(Value);
end;

procedure TSprite16.GetVisualDimensions(var R: TRect);
begin
  R.Left := FXshift + FSpriteX;
  R.Right := R.Left + FSpriteWidth;
  R.Top := FYshift + FSpriteY;
  R.Bottom := R.Top + FSpriteHeight;
end;

procedure TSprite16.AllocateDiscardableImageData(AWidth, AHeight: Integer);
var
  Size: Integer;
begin
  if AWidth < 32 then
    FPitch := (AWidth shl 1 + 3) and not 3
  else
    FPitch := (AWidth shl 1 + 7) and not 7;
  Size := FPitch * AHeight + 7;
  ReallocMem(FBuffer, Size);
  FData := Pointer((Integer(FBuffer) + 7) and not 7);
end;

procedure TSprite16.ReleaseDiscardableImageData;
begin
  if FDataLoaded then
  begin
    ReallocMem(FBuffer, 0);
    FDataLoaded := False;
  end;
end;

procedure TSprite16.ReadImageData(Stream: TStream);
begin
  inherited ReadImageData(Stream);
  Stream.Read(FSpriteWidth, 4);
  Stream.Read(FSpriteHeight, 4);
  Stream.Read(FSpriteX, 4);
  Stream.Read(FSpriteY, 4);
  Stream.Read(FTransparentColor, 4);
end;

procedure TSprite16.WriteImageData(Stream: TStream);
begin
  inherited WriteImageData(Stream);
  Stream.Write(FSpriteWidth, 4);
  Stream.Write(FSpriteHeight, 4);
  Stream.Write(FSpriteX, 4);
  Stream.Write(FSpriteY, 4);
  Stream.Write(FTransparentColor, 4);
end;

procedure TSprite16.ReadDiscardableImageData(Stream: TStream);
var
  Y: Integer;
begin
  inherited ReadDiscardableImageData(Stream);
  AllocateDiscardableImageData(FSpriteWidth, FSpriteHeight);
  for Y := 0 to FSpriteHeight - 1 do
    Stream.Read(Pointer(Integer(FData) + Y * FPitch)^, FSpriteWidth * 2);
  FColorKey := FTransparentColor;
end;

procedure TSprite16.WriteDiscardableImageData(Stream: TStream);
var
  Y: Integer;
begin
  inherited WriteDiscardableImageData(Stream);
  for Y := 0 to FSpriteHeight - 1 do
    Stream.Write(Pointer(Integer(FData) + Y * FPitch)^, FSpriteWidth * 2);
end;

function TSprite16.RemapToPixelFormat(PixelFormatID: Integer): HResult;
begin
  Result := 0;
  if PixelFormatID <> FPixelFormatID then
    case PixelFormatID of
      pfRGB565:
        begin
          RemapSurface555to565(FData, FData, FPitch, FPitch, FSpriteWidth, FSpriteHeight);
          FColorKey := RemapPixelInfo(FColorKey, pfRGB555, nil, pfRGB565, nil);
          FPixelFormatID := pfRGB565;
        end;
      pfRGB555:
        begin
          RemapSurface565to555(FData, FData, FPitch, FPitch, FSpriteWidth, FSpriteHeight);
          FColorKey := RemapPixelInfo(FColorKey, pfRGB565, nil, pfRGB555, nil);
          FPixelFormatID := pfRGB555;
        end;
    else
      Result := GFXE_NOTSUPPORTED;
    end;
end;

function TSprite16.SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean;
begin
  Result := ((PixelFormatID = 0) or (PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555)) and
    (ShowMode in [smOpaque, smTransparent, smBlended]);
end;

procedure TSprite16.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
var
  DX, Right, W, H, SX, SY, DY, Bottom: Integer;
  Src, Dst: Pointer;
begin
  Inc(X, FSpriteX);
  DX := FXshift + X;
  W := FSpriteWidth;
  Right := FSpriteWidth + DX;
  if DX < SD.ClipRect.Left then
  begin
    SX := SD.ClipRect.Left - X;
    DX := SD.ClipRect.Left;
    Dec(W, SX);
  end
  else
    SX := 0;
  if Right > SD.ClipRect.Right then Dec(W, Right - SD.ClipRect.Right);
  if W > 0 then
  begin
    Inc(Y, FSpriteY);
    DY := Y + FYshift;
    H := FSpriteHeight;
    Bottom := DY + FSpriteHeight;
    if DY < SD.ClipRect.Top then
    begin
      SY := SD.ClipRect.Top - Y;
      DY := SD.ClipRect.Top;
      Dec(H, SY);
    end
    else
      SY := 0;
    if Bottom > SD.ClipRect.Bottom then Dec(H, Bottom - SD.ClipRect.Bottom);
    if H > 0 then
      if not FDataLoaded then
      begin
        LoadDiscardableImageData;
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
          BltColorKey16(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey)
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          BltColorKey16(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey);
        end;
        if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
      end
      else
      begin
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
          BltColorKey16(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey)
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          BltColorKey16(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey);
        end;
      end;
  end;
end;

procedure TSprite16.ShowBlended(X, Y: Integer; const SD: TSurfaceDesc; Table: TBlendTable);
var
  DX, Right, W, H, SX, SY, DY, Bottom: Integer;
  Src, Dst: Pointer;
begin
  Inc(X, FSpriteX);
  DX := FXshift + X;
  W := FSpriteWidth;
  Right := FSpriteWidth + DX;
  if DX < SD.ClipRect.Left then
  begin
    SX := SD.ClipRect.Left - X;
    DX := SD.ClipRect.Left;
    Dec(W, SX);
  end
  else
    SX := 0;
  if Right > SD.ClipRect.Right then Dec(W, Right - SD.ClipRect.Right);
  if W > 0 then
  begin
    Inc(Y, FSpriteY);
    DY := Y + FYshift;
    H := FSpriteHeight;
    Bottom := DY + FSpriteHeight;
    if DY < SD.ClipRect.Top then
    begin
      SY := SD.ClipRect.Top - Y;
      DY := SD.ClipRect.Top;
      Dec(H, SY);
    end
    else
      SY := 0;
    if Bottom > SD.ClipRect.Bottom then Dec(H, Bottom - SD.ClipRect.Bottom);
    if H > 0 then
      if not FDataLoaded then
      begin
        LoadDiscardableImageData;
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
          case FPixelFormatID of
            pfRGB555: BlendColorKey555(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey,
              @TBlendTable5Bit(Table).Table);
            pfRGB565: BlendColorKey565(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey,
              @TBlendTable5Bit(Table).Table);
          end
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          case FPixelFormatID of
            pfRGB555: BlendColorKey555(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey,
              @TBlendTable5Bit(Table).Table);
            pfRGB565: BlendColorKey565(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey,
              @TBlendTable5Bit(Table).Table);
          end;
        end;
        if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
      end
      else
      begin
        Src := Pointer(Integer(FData) + SX * 2 + SY * FPitch);
        Dst := Pointer(Integer(SD.Data) + DX shl 1 + SD.Pitch * DY);
        if SD.PixelFormatID = FPixelFormatID then
          case FPixelFormatID of
            pfRGB555: BlendColorKey555(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey,
              @TBlendTable5Bit(Table).Table);
            pfRGB565: BlendColorKey565(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey,
              @TBlendTable5Bit(Table).Table);
          end
        else
        begin
          if RemapToPixelFormat(SD.PixelFormatID) <> 0 then
            raise Exception.Create('Surface pixel format not supported!');
          case FPixelFormatID of
            pfRGB555: BlendColorKey555(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey,
              @TBlendTable5Bit(Table).Table);
            pfRGB565: BlendColorKey565(Src, Dst, FPitch, SD.Pitch, W, H, FColorKey,
              @TBlendTable5Bit(Table).Table);
          end;
        end;
      end;
  end;
end;

{ ShowTransparent shows the sprite blended 50% }
procedure TSprite16.ShowTransparent(X, Y: Integer; const SD: TSurfaceDesc);
begin
  ShowBlended(X, Y, SD, AlphaBlendTable.LookupTables[50]);
end;

function TSprite16.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := (PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555) or
    (PixelFormatID = pfRGB24) or (PixelFormatID = pfPAL8);
end;

function TSprite16.CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
  OnImagesGrabbed: TImagesGrabbedEvent): TForm;
begin
  Result := nil;
end;

{ GrabImage locks the conversion surface and never unlocks it (an original bug) }
function TSprite16.GrabImage(const SD: TSurfaceDesc; const R: TRect;
  GrabInfo: TGrabInfo): Boolean;
var
  Surface: TDataSurface;
  LSD: TSurfaceDesc;
  GR, MR: TRect;
  Y: Integer;
begin
  Result := True;
  try
    Surface := nil;
    try
      if SD.BitCount <> 16 then
      begin
        Surface := TDataSurface.Create(R.Right - R.Left, R.Bottom - R.Top, pfRGB565, nil);
        GR.Left := 0;
        GR.Top := 0;
        GR.Right := Surface.GetWidth;
        GR.Bottom := Surface.GetHeight;
        Surface.Lock(LSD);
        if RemapSurfacePart(SD, R.Left, R.Top, Surface.GetWidth, Surface.GetHeight, LSD, 0, 0) <> 0 then
          raise Exception.Create('Invalid PixelFormat');
        FTransparentColor := RemapPixelInfo(GrabInfo.TransparentPixel, SD.PixelFormatID,
          SD.Palette, LSD.PixelFormatID, nil);
      end
      else
      begin
        LSD := SD;
        GR := R;
        FTransparentColor := GrabInfo.TransparentPixel;
      end;
      Clear;
      FDataLoaded := True;
      FDataWidth := GR.Right - GR.Left;
      FDataHeight := GR.Bottom - GR.Top;
      FWidth := FDataWidth;
      FHeight := FDataHeight;
      FFileName := ExtractFileName(GrabInfo.FileName);
      FFileIndex := GrabInfo.FileIndex;
      FStoredPixelFormatID := LSD.PixelFormatID;
      FPixelFormatID := FStoredPixelFormatID;
      FColorKey := FTransparentColor;
      MinimizeTransparentRect(LSD, GR, FTransparentColor, MR);
      FSpriteX := MR.Left - GR.Left;
      FSpriteY := MR.Top - GR.Top;
      FSpriteWidth := MR.Right - MR.Left;
      FSpriteHeight := MR.Bottom - MR.Top;
      FDataSize := FSpriteWidth * FSpriteHeight * 2;
      AllocateDiscardableImageData(FSpriteWidth, FSpriteHeight);
      for Y := MR.Top to MR.Bottom - 1 do
        Move(Pointer(LSD.Pitch * Y + Integer(LSD.Data) + MR.Left * 2)^,
          Pointer((Y - MR.Top) * FPitch + Integer(FData))^, FSpriteWidth * 2);
    finally
      if Surface <> nil then Surface.Destroy;
    end;
  except
    ReleaseDiscardableImageData;
    Result := False;
  end;
end;

{ The bit mask blitters (assembler, below): a mask of Width x Height bits, rows of whole dwords,
  the first pixel in the high bit, shown at X, Y on a 16 bit surface. }
procedure ShowBitMask16(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer;
  Width, Height: Integer); pascal; forward;
procedure ShowShadow565(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer;
  Width, Height: Integer); pascal; forward;
procedure ShowShadow555(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer;
  Width, Height: Integer); pascal; forward;

{ TBitMaskGrabInfo }

function TBitMaskGrabInfo.GrabInfoClass: TGrabInfoClass;
begin
  Result := TBitMaskGrabInfo;
end;

procedure TBitMaskGrabInfo.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  Stream.Read(Inverse, 1);
end;

procedure TBitMaskGrabInfo.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(Inverse, 1);
end;

{ TBitMask }

class function TBitMask.ClassID: Integer;
begin
  Result := $13;
end;

class function TBitMask.Name: string;
begin
  Result := 'Bit Mask';
end;

procedure TBitMask.SetXshift(Value: Integer);
begin
  if Value < -FMaskLeft then Value := -FMaskLeft;
  inherited SetXshift(Value);
  SetWidth(FWidth);
end;

procedure TBitMask.SetYshift(Value: Integer);
begin
  if Value < -FMaskTop then Value := -FMaskTop;
  inherited SetYshift(Value);
  SetHeight(FHeight);
end;

procedure TBitMask.SetWidth(Value: Integer);
var
  W: Integer;
begin
  W := FXshift + FMaskLeft + FMaskWidth;
  if Value < W then Value := W;
  inherited SetWidth(Value);
end;

procedure TBitMask.SetHeight(Value: Integer);
var
  H: Integer;
begin
  H := FYshift + FMaskTop + FMaskHeight;
  if Value < H then Value := H;
  inherited SetHeight(Value);
end;

procedure TBitMask.ReadImageData(Stream: TStream);
begin
  inherited ReadImageData(Stream);
  Stream.Read(FMaskWidth, 4);
  Stream.Read(FMaskHeight, 4);
  Stream.Read(FMaskLeft, 4);
  Stream.Read(FMaskTop, 4);
end;

procedure TBitMask.WriteImageData(Stream: TStream);
begin
  inherited WriteImageData(Stream);
  Stream.Write(FMaskWidth, 4);
  Stream.Write(FMaskHeight, 4);
  Stream.Write(FMaskLeft, 4);
  Stream.Write(FMaskTop, 4);
end;

procedure TBitMask.AllocateMaskData(AWidth, AHeight: Integer);
begin
  FMaskWidth := AWidth;
  FMaskHeight := AHeight;
  FPitch := (AWidth + 31) shr 5 shl 2;
  FDataSize := FPitch * FMaskHeight;
  ReallocMem(FMaskData, FDataSize);
end;

procedure TBitMask.ReleaseDiscardableImageData;
begin
  ReallocMem(FMaskData, 0);
  FDataLoaded := False;
end;

procedure TBitMask.ReadDiscardableImageData(Stream: TStream);
begin
  inherited ReadDiscardableImageData(Stream);
  AllocateMaskData(FMaskWidth, FMaskHeight);
  Stream.Read(FMaskData^, FDataSize);
end;

procedure TBitMask.WriteDiscardableImageData(Stream: TStream);
begin
  inherited WriteDiscardableImageData(Stream);
  Stream.Write(FMaskData^, FDataSize);
end;

function TBitMask.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := (PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555) or (PixelFormatID = pfRGB24) or
    (PixelFormatID = pfPAL8);
end;

function TBitMask.CreateGrabInfo: TGrabInfo;
begin
  Result := TBitMaskGrabInfo.Create;
end;

function TBitMask.CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
  OnImagesGrabbed: TImagesGrabbedEvent): TForm;
begin
  Result := nil;
end;

{ GrabImage sets a bit for every pixel that differs from the transparent pixel value. With an
  inverse grab info no bit is added at all (an original bug: the mask stays empty). }
function TBitMask.GrabImage(const SD: TSurfaceDesc; const R: TRect;
  GrabInfo: TGrabInfo): Boolean;
var
  Bits, BitCount, Offset: Integer;

  procedure AddBit(Bit: Boolean);
  begin
    Bits := Bits shl 1;
    if Bit then Inc(Bits);
    Inc(BitCount);
    if BitCount = 32 then
    begin
      PInteger(Integer(FMaskData) + Offset)^ := Bits;
      Inc(Offset, 4);
      BitCount := 0;
      Bits := 0;
    end;
  end;

  procedure FlushBits;
  begin
    Bits := Bits shl (32 - BitCount);
    PInteger(Integer(FMaskData) + Offset)^ := Bits;
    Inc(Offset, 4);
    BitCount := 0;
    Bits := 0;
  end;

var
  X, Y, TransparentColor, Left, Top, Bottom: Integer;
  MinRect: TRect;
begin
  Clear;
  Result := True;
  FDataLoaded := True;
  Bits := 0;
  Offset := 0;
  BitCount := 0;
  FDataWidth := R.Right - R.Left;
  FDataHeight := R.Bottom - R.Top;
  FWidth := FDataWidth;
  FHeight := FDataHeight;
  FFileName := ExtractFileName(GrabInfo.FileName);
  FFileIndex := GrabInfo.FileIndex;
  TransparentColor := GrabInfo.TransparentPixel;
  if not TBitMaskGrabInfo(GrabInfo).Inverse then
    MinimizeTransparentRect(SD, R, TransparentColor, MinRect)
  else
    MinimizeInvTransparentRect(SD, R, TransparentColor, MinRect);
  Left := MinRect.Left;
  FMaskLeft := Left - R.Left;
  Top := MinRect.Top;
  FMaskTop := Top - R.Top;
  FMaskWidth := MinRect.Right - Left;
  Bottom := MinRect.Bottom;
  FMaskHeight := Bottom - Top;
  AllocateMaskData(FMaskWidth, FMaskHeight);
  for Y := Top to Bottom - 1 do
  begin
    Offset := (Y - MinRect.Top) * FPitch;
    for X := MinRect.Left to MinRect.Right - 1 do
      if not TBitMaskGrabInfo(GrabInfo).Inverse then
        AddBit(GetPixelInfo(SD, X, Y) <> TransparentColor);
    FlushBits;
  end;
end;

{ ShowDC clears the surface to gray, not to BkColor. }
procedure TBitMask.ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor);
var
  H: HWND;
  Surface: TDIB16Surface;
  SD: TSurfaceDesc;
  R, ClientRect: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := FWidth;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  Surface := TDIB16Surface.Create(SrcRect^.Right - SrcRect^.Left, SrcRect^.Bottom - SrcRect^.Top,
    pfRGB565);
  try
    if DestRect = nil then
    begin
      H := WindowFromDC(DC);
      GetClientRect(H, ClientRect);
      DestRect := @ClientRect;
    end;
    Surface.Cls($808080);
    Surface.Lock(SD);
    Show(-SrcRect^.Left, -SrcRect^.Top, SD);
    Surface.BltDC(DC, nil, DestRect);
    Surface.Unlock;
  finally
    Surface.Free;
  end;
end;

procedure TBitMask.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
begin
  if not FDataLoaded then LoadDiscardableImageData;
  ShowBitMask16(X + FXshift + FMaskLeft, Y + FYshift + FMaskTop, SD, FMaskData, FMaskWidth,
    FMaskHeight);
end;

{ ShowBitMask16 sets the pixels of the set bits to $FFFF. When the mask is clipped away
  completely it restores esp from a local it has not set yet (an original bug). }
procedure ShowBitMask16(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer;
  Width, Height: Integer);
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9, L10: Integer;
asm
        push    edi
        push    esi
        push    ebx
        mov     eax, Width
        mov     esi, Data
        add     eax, $1F
        shr     eax, 5
        mov     edi, SD
        mov     L1, eax
        mov     eax, X
        mov     ecx, dword ptr [edi+$10]
        mov     ebx, Width
        mov     edx, dword ptr [edi+$18]
        add     ebx, eax
        cmp     ebx, ecx
        js      @@L19
        cmp     eax, edx
        jge     @@L19
        cmp     edx, ecx
        jle     @@L19
        mov     L2, ebx
        mov     eax, Y
        mov     ecx, dword ptr [edi+$14]
        mov     ebx, Height
        mov     edx, dword ptr [edi+$1C]
        add     ebx, eax
        cmp     ebx, ecx
        js      @@L19
        cmp     eax, edx
        jge     @@L19
        cmp     edx, ecx
        jle     @@L19
        mov     L3, ebx
        mov     edx, ebx
        mov     ecx, Y
        mov     ebx, Height
        mov     eax, dword ptr [edi+$14]
        sub     edx, dword ptr [edi+$1C]
        jle     @@L0
        sub     ebx, edx
@@L0:
        sub     eax, ecx
        jle     @@L1
        add     ecx, eax
        sub     ebx, eax
        mov     edx, L1
        shl     edx, 2
        mul     edx
        add     esi, eax
@@L1:
        mov     Height, ebx
        mov     Y, ecx
        mov     eax, X
        mov     ecx, L2
        cmp     eax, dword ptr [edi+$10]
        js      @@L7
        cmp     ecx, dword ptr [edi+$18]
        jg      @@L7
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mul     ecx
        mov     edi, dword ptr [edi+$20]
        mov     L4, ecx
        lea     edi, [edi+ebx*2]
        mov     L5, esp
        add     edi, eax
        mov     ebx, Height
@@L2:
        mov     edx, L1
        xor     ecx, ecx
        mov     L6, $40
@@L3:
        mov     eax, dword ptr [esi]
@@L4:
        add     eax, eax
        jae     @@L5
        mov     word ptr [edi+ecx], $0FFFF
        test    eax, eax
        je      @@L6
        lea     ecx, [ecx+2]
        jmp     @@L4
@@L5:
        je      @@L6
        lea     ecx, [ecx+2]
        jmp     @@L4
@@L6:
        lea     esi, [esi+4]
        mov     ecx, L6
        add     L6, $40
        dec     edx
        jne     @@L3
        dec     ebx
        je      @@L19
        add     edi, L4
        jmp     @@L2
@@L7:
        mov     ebx, L1
        shl     ebx, 2
        mov     L7, ebx
        mov     ebx, Width
        shl     ebx, 1
        mov     L8, ebx
        mov     edx, dword ptr [edi+$10]
        mov     eax, X
        sub     edx, eax
        jns     @@L8
        mov     L9, 0
        jmp     @@L9
@@L8:
        mov     ecx, edx
        and     edx, $1F
        shr     ecx, 5
        mov     L9, edx
        je      @@L9
        mov     eax, L1
        sub     eax, ecx
        mov     L1, eax
        mov     eax, ecx
        mov     edx, L8
        shl     eax, 6
        sub     edx, eax
        mov     L8, edx
        lea     esi, [esi+ecx*4]
        mov     edx, X
        shl     ecx, 5
        lea     edx, [edx+ecx]
        mov     X, edx
@@L9:
        mov     edx, L2
        mov     eax, dword ptr [edi+$18]
        sub     edx, eax
        js      @@L10
        mov     ecx, L8
        lea     eax, [edx*2]
        sub     ecx, eax
        mov     L8, ecx
        shr     edx, 5
        mov     eax, L1
        sub     eax, edx
        dec     eax
        mov     L1, eax
@@L10:
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mul     ecx
        mov     edi, dword ptr [edi+$20]
        mov     L4, ecx
        lea     edi, [edi+ebx*2]
        mov     ebx, Height
        add     edi, eax
        mov     L5, esp
@@L11:
        mov     esp, L1
        mov     L10, esi
        mov     L6, $40
        xor     ecx, ecx
        mov     ecx, L9
        test    ecx, ecx
        je      @@L12
        mov     eax, dword ptr [esi]
        add     esi, 4
        shl     eax, cl
        lea     ecx, [ecx*2]
        test    esp, esp
        jne     @@L13
        mov     ebx, L8
        je      @@L16
@@L12:
        mov     eax, dword ptr [esi]
        lea     esi, [esi+4]
@@L13:
        add     eax, eax
        jae     @@L14
        mov     word ptr [edi+ecx], $0FFFF
        lea     ecx, [ecx+2]
        test    eax, eax
        je      @@L15
        jmp     @@L13
@@L14:
        je      @@L15
        lea     ecx, [ecx+2]
        jmp     @@L13
@@L15:
        mov     ecx, L6
        add     L6, $40
        dec     esp
        jne     @@L12
        mov     ebx, L8
        cmp     ebx, ecx
        jle     @@L18
        mov     eax, dword ptr [esi]
        add     esi, 4
@@L16:
        add     eax, eax
        jae     @@L17
        mov     word ptr [edi+ecx], $0FFFF
        lea     ecx, [ecx+2]
        test    eax, eax
        je      @@L18
        cmp     ebx, ecx
        jle     @@L18
        jmp     @@L16
@@L17:
        lea     ecx, [ecx+2]
        je      @@L18
        cmp     ebx, ecx
        jg      @@L16
@@L18:
        dec     Height
        je      @@L19
        mov     esi, L10
        add     edi, L4
        add     esi, L7
        jmp     @@L11
@@L19:
        mov     esp, L5
        pop     ebx
        pop     esi
        pop     edi
end;

{ TShadow }

constructor TShadow.Create(AOwner: TCustomImageLibrary);
begin
  inherited Create(AOwner);
end;

{ SupportShowMode asks TLibraryImage, which supports nothing. }
function TShadow.SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean;
begin
  Result := ((PixelFormatID = pfRGB565) or (PixelFormatID = pfRGB555)) and
    inherited SupportShowMode(ShowMode, PixelFormatID);
end;

class function TShadow.ClassID: Integer;
begin
  Result := $14;
end;

class function TShadow.Name: string;
begin
  Result := 'Shadow';
end;

procedure TShadow.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
begin
  if not FDataLoaded then
  begin
    LoadDiscardableImageData;
    case SD.PixelFormatID of
      pfRGB565: ShowShadow565(X + FXshift + FMaskLeft, Y + FYshift + FMaskTop, SD, FMaskData,
        FMaskWidth, FMaskHeight);
      pfRGB555: ShowShadow555(X + FXshift + FMaskLeft, Y + FYshift + FMaskTop, SD, FMaskData,
        FMaskWidth, FMaskHeight);
    else
      raise Exception.Create('Surface format not supported');
    end;
    if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
  end
  else
    case SD.PixelFormatID of
      pfRGB565: ShowShadow565(X + FXshift + FMaskLeft, Y + FYshift + FMaskTop, SD, FMaskData,
        FMaskWidth, FMaskHeight);
      pfRGB555: ShowShadow555(X + FXshift + FMaskLeft, Y + FYshift + FMaskTop, SD, FMaskData,
        FMaskWidth, FMaskHeight);
    else
      raise Exception.Create('Surface format not supported');
    end;
end;

{ ShowShadow565, ShowShadow555 darken the pixels of the set bits to three quarters (the same
  esp bug as ShowBitMask16). }
procedure ShowShadow565(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer;
  Width, Height: Integer);
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9, L10: Integer;
asm
        push    edi
        push    esi
        push    ebx
        mov     eax, Width
        mov     esi, Data
        add     eax, $1F
        shr     eax, 5
        mov     edi, SD
        mov     L1, eax
        mov     eax, X
        mov     ecx, dword ptr [edi+$10]
        mov     ebx, Width
        mov     edx, dword ptr [edi+$18]
        add     ebx, eax
        cmp     ebx, ecx
        js      @@L25
        cmp     eax, edx
        jge     @@L25
        cmp     edx, ecx
        jle     @@L25
        mov     L2, ebx
        mov     eax, Y
        mov     ecx, dword ptr [edi+$14]
        mov     ebx, Height
        mov     edx, dword ptr [edi+$1C]
        add     ebx, eax
        cmp     ebx, ecx
        js      @@L25
        cmp     eax, edx
        jge     @@L25
        cmp     edx, ecx
        jle     @@L25
        mov     L3, ebx
        mov     edx, ebx
        mov     ecx, Y
        mov     ebx, Height
        mov     eax, dword ptr [edi+$14]
        sub     edx, dword ptr [edi+$1C]
        jle     @@L0
        sub     ebx, edx
@@L0:
        sub     eax, ecx
        jle     @@L1
        add     ecx, eax
        sub     ebx, eax
        mov     edx, L1
        shl     edx, 2
        mul     edx
        add     esi, eax
@@L1:
        mov     Height, ebx
        mov     Y, ecx
        mov     eax, X
        mov     ecx, L2
        cmp     eax, dword ptr [edi+$10]
        js      @@L10
        cmp     ecx, dword ptr [edi+$18]
        jg      @@L10
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mul     ecx
        mov     edi, dword ptr [edi+$20]
        mov     L4, ecx
        lea     edi, [edi+ebx*2]
        mov     L5, esp
        add     edi, eax
        xor     edx, edx
@@L2:
        mov     esp, L1
        xor     ecx, ecx
        mov     L6, $40
@@L3:
        mov     eax, dword ptr [esi]
@@L4:
        add     eax, eax
        jae     @@L5
        je      @@L8
        add     eax, eax
        jae     @@L6
        mov     ebx, dword ptr [edi+ecx]
        lea     ecx, [ecx+4]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $0E79CE79C
        shr     edx, 2
        and     ebx, $7BEF7BEF
        add     ebx, edx
        test    eax, eax
        mov     dword ptr [edi+ecx-4], ebx
        je      @@L7
        jmp     @@L4
@@L5:
        je      @@L7
        lea     ecx, [ecx+2]
        jmp     @@L4
@@L6:
        mov     bx, word ptr [edi+ecx]
        lea     ecx, [ecx+4]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $0E79C
        shr     edx, 2
        and     ebx, $7BEF
        add     ebx, edx
        test    eax, eax
        mov     word ptr [edi+ecx], bx
        jne     @@L4
@@L7:
        lea     esi, [esi+4]
        dec     esp
        je      @@L9
        mov     ecx, L6
        add     L6, $40
        jmp     @@L3
@@L8:
        mov     bx, word ptr [edi+ecx]
        mov     edx, ebx
        lea     esi, [esi+4]
        shr     ebx, 1
        and     edx, $0E79C
        shr     edx, 2
        and     ebx, $7BEF
        add     ebx, edx
        dec     esp
        mov     word ptr [edi+ecx], bx
        je      @@L9
        mov     ecx, L6
        add     L6, $40
        jmp     @@L3
@@L9:
        dec     Height
        je      @@L25
        add     edi, L4
        jmp     @@L2
@@L10:
        mov     ebx, L1
        shl     ebx, 2
        mov     L7, ebx
        mov     ebx, Width
        shl     ebx, 1
        mov     L8, ebx
        mov     edx, dword ptr [edi+$10]
        mov     eax, X
        sub     edx, eax
        jns     @@L11
        mov     L9, 0
        jmp     @@L12
@@L11:
        mov     ecx, edx
        and     edx, $1F
        shr     ecx, 5
        mov     L9, edx
        je      @@L12
        mov     eax, L1
        sub     eax, ecx
        mov     L1, eax
        mov     eax, ecx
        mov     edx, L8
        shl     eax, 6
        sub     edx, eax
        mov     L8, edx
        lea     esi, [esi+ecx*4]
        mov     edx, X
        shl     ecx, 5
        lea     edx, [edx+ecx]
        mov     X, edx
@@L12:
        mov     edx, L2
        mov     eax, dword ptr [edi+$18]
        sub     edx, eax
        js      @@L13
        mov     ecx, L8
        lea     eax, [edx*2]
        sub     ecx, eax
        mov     L8, ecx
        shr     edx, 5
        mov     eax, L1
        sub     eax, edx
        dec     eax
        mov     L1, eax
@@L13:
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mul     ecx
        mov     edi, dword ptr [edi+$20]
        mov     L4, ecx
        lea     edi, [edi+ebx*2]
        mov     ebx, Height
        add     edi, eax
        mov     L5, esp
@@L14:
        mov     esp, L1
        mov     L10, esi
        mov     L6, $40
        xor     ecx, ecx
        mov     ecx, L9
        test    ecx, ecx
        je      @@L15
        mov     eax, dword ptr [esi]
        add     esi, 4
        shl     eax, cl
        lea     ecx, [ecx*2]
        test    esp, esp
        jne     @@L16
        mov     ebx, L8
        je      @@L22
@@L15:
        mov     eax, dword ptr [esi]
@@L16:
        add     eax, eax
        jae     @@L17
        je      @@L20
        add     eax, eax
        jae     @@L18
        mov     ebx, dword ptr [edi+ecx]
        lea     ecx, [ecx+4]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $0E79CE79C
        shr     edx, 2
        and     ebx, $7BEF7BEF
        add     ebx, edx
        test    eax, eax
        mov     dword ptr [edi+ecx-4], ebx
        je      @@L19
        jmp     @@L16
@@L17:
        je      @@L19
        lea     ecx, [ecx+2]
        jmp     @@L16
@@L18:
        mov     bx, word ptr [edi+ecx]
        lea     ecx, [ecx+4]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $0E79C
        shr     edx, 2
        and     ebx, $7BEF
        add     ebx, edx
        test    eax, eax
        mov     word ptr [edi+ecx], bx
        jne     @@L16
@@L19:
        lea     esi, [esi+4]
        mov     ecx, L6
        dec     esp
        je      @@L21
        add     L6, $40
        jmp     @@L15
@@L20:
        mov     bx, word ptr [edi+ecx]
        mov     edx, ebx
        lea     esi, [esi+4]
        shr     ebx, 1
        and     edx, $0E79C
        shr     edx, 2
        and     ebx, $7BEF
        add     ebx, edx
        dec     esp
        mov     word ptr [edi+ecx], bx
        mov     ecx, L6
        je      @@L21
        add     L6, $40
        jmp     @@L15
@@L21:
        cmp     L8, ecx
        jle     @@L24
        mov     eax, dword ptr [esi]
        add     esi, 4
@@L22:
        add     eax, eax
        jae     @@L23
        mov     bx, word ptr [edi+ecx]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $0E79C
        shr     edx, 2
        and     ebx, $7BEF
        add     ebx, edx
        lea     ecx, [ecx+2]
        mov     word ptr [edi+ecx], bx
        test    eax, eax
        je      @@L24
        cmp     L8, ecx
        jle     @@L24
        jmp     @@L22
@@L23:
        lea     ecx, [ecx+2]
        je      @@L24
        cmp     L8, ecx
        jg      @@L22
@@L24:
        dec     Height
        je      @@L25
        mov     esi, L10
        add     edi, L4
        add     esi, L7
        jmp     @@L14
@@L25:
        mov     esp, L5
        pop     ebx
        pop     esi
        pop     edi
end;

procedure ShowShadow555(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer;
  Width, Height: Integer);
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9, L10: Integer;
asm
        push    edi
        push    esi
        push    ebx
        mov     eax, Width
        mov     esi, Data
        add     eax, $1F
        shr     eax, 5
        mov     edi, SD
        mov     L1, eax
        mov     eax, X
        mov     ecx, dword ptr [edi+$10]
        mov     ebx, Width
        mov     edx, dword ptr [edi+$18]
        add     ebx, eax
        cmp     ebx, ecx
        js      @@L25
        cmp     eax, edx
        jge     @@L25
        cmp     edx, ecx
        jle     @@L25
        mov     L2, ebx
        mov     eax, Y
        mov     ecx, dword ptr [edi+$14]
        mov     ebx, Height
        mov     edx, dword ptr [edi+$1C]
        add     ebx, eax
        cmp     ebx, ecx
        js      @@L25
        cmp     eax, edx
        jge     @@L25
        cmp     edx, ecx
        jle     @@L25
        mov     L3, ebx
        mov     edx, ebx
        mov     ecx, Y
        mov     ebx, Height
        mov     eax, dword ptr [edi+$14]
        sub     edx, dword ptr [edi+$1C]
        jle     @@L0
        sub     ebx, edx
@@L0:
        sub     eax, ecx
        jle     @@L1
        add     ecx, eax
        sub     ebx, eax
        mov     edx, L1
        shl     edx, 2
        mul     edx
        add     esi, eax
@@L1:
        mov     Height, ebx
        mov     Y, ecx
        mov     eax, X
        mov     ecx, L2
        cmp     eax, dword ptr [edi+$10]
        js      @@L10
        cmp     ecx, dword ptr [edi+$18]
        jg      @@L10
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mul     ecx
        mov     edi, dword ptr [edi+$20]
        mov     L4, ecx
        lea     edi, [edi+ebx*2]
        mov     L5, esp
        add     edi, eax
        xor     edx, edx
@@L2:
        mov     esp, L1
        xor     ecx, ecx
        mov     L6, $40
@@L3:
        mov     eax, dword ptr [esi]
@@L4:
        add     eax, eax
        jae     @@L5
        je      @@L8
        add     eax, eax
        jae     @@L6
        mov     ebx, dword ptr [edi+ecx]
        lea     ecx, [ecx+4]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $739C739C
        shr     edx, 2
        and     ebx, $3DEF3DEF
        add     ebx, edx
        test    eax, eax
        mov     dword ptr [edi+ecx-4], ebx
        je      @@L7
        jmp     @@L4
@@L5:
        je      @@L7
        lea     ecx, [ecx+2]
        jmp     @@L4
@@L6:
        mov     bx, word ptr [edi+ecx]
        lea     ecx, [ecx+4]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $739C
        shr     edx, 2
        and     ebx, $3DEF
        add     ebx, edx
        test    eax, eax
        mov     word ptr [edi+ecx], bx
        jne     @@L4
@@L7:
        lea     esi, [esi+4]
        dec     esp
        je      @@L9
        mov     ecx, L6
        add     L6, $40
        jmp     @@L3
@@L8:
        mov     bx, word ptr [edi+ecx]
        mov     edx, ebx
        lea     esi, [esi+4]
        shr     ebx, 1
        and     edx, $739C
        shr     edx, 2
        and     ebx, $3DEF
        add     ebx, edx
        dec     esp
        mov     word ptr [edi+ecx], bx
        je      @@L9
        mov     ecx, L6
        add     L6, $40
        jmp     @@L3
@@L9:
        dec     Height
        je      @@L25
        add     edi, L4
        jmp     @@L2
@@L10:
        mov     ebx, L1
        shl     ebx, 2
        mov     L7, ebx
        mov     ebx, Width
        shl     ebx, 1
        mov     L8, ebx
        mov     edx, dword ptr [edi+$10]
        mov     eax, X
        sub     edx, eax
        jns     @@L11
        mov     L9, 0
        jmp     @@L12
@@L11:
        mov     ecx, edx
        and     edx, $1F
        shr     ecx, 5
        mov     L9, edx
        je      @@L12
        mov     eax, L1
        sub     eax, ecx
        mov     L1, eax
        mov     eax, ecx
        mov     edx, L8
        shl     eax, 6
        sub     edx, eax
        mov     L8, edx
        lea     esi, [esi+ecx*4]
        mov     edx, X
        shl     ecx, 5
        lea     edx, [edx+ecx]
        mov     X, edx
@@L12:
        mov     edx, L2
        mov     eax, dword ptr [edi+$18]
        sub     edx, eax
        js      @@L13
        mov     ecx, L8
        lea     eax, [edx*2]
        sub     ecx, eax
        mov     L8, ecx
        shr     edx, 5
        mov     eax, L1
        sub     eax, edx
        dec     eax
        mov     L1, eax
@@L13:
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mul     ecx
        mov     edi, dword ptr [edi+$20]
        mov     L4, ecx
        lea     edi, [edi+ebx*2]
        mov     ebx, Height
        add     edi, eax
        mov     L5, esp
@@L14:
        mov     esp, L1
        mov     L10, esi
        mov     L6, $40
        xor     ecx, ecx
        mov     ecx, L9
        test    ecx, ecx
        je      @@L15
        mov     eax, dword ptr [esi]
        add     esi, 4
        shl     eax, cl
        lea     ecx, [ecx*2]
        test    esp, esp
        jne     @@L16
        mov     ebx, L8
        je      @@L22
@@L15:
        mov     eax, dword ptr [esi]
@@L16:
        add     eax, eax
        jae     @@L17
        je      @@L20
        add     eax, eax
        jae     @@L18
        mov     ebx, dword ptr [edi+ecx]
        lea     ecx, [ecx+4]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $739C739C
        shr     edx, 2
        and     ebx, $3DEF3DEF
        add     ebx, edx
        test    eax, eax
        mov     dword ptr [edi+ecx-4], ebx
        je      @@L19
        jmp     @@L16
@@L17:
        je      @@L19
        lea     ecx, [ecx+2]
        jmp     @@L16
@@L18:
        mov     bx, word ptr [edi+ecx]
        lea     ecx, [ecx+4]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $739C
        shr     edx, 2
        and     ebx, $3DEF
        add     ebx, edx
        test    eax, eax
        mov     word ptr [edi+ecx], bx
        jne     @@L16
@@L19:
        lea     esi, [esi+4]
        mov     ecx, L6
        dec     esp
        je      @@L21
        add     L6, $40
        jmp     @@L15
@@L20:
        mov     bx, word ptr [edi+ecx]
        mov     edx, ebx
        lea     esi, [esi+4]
        shr     ebx, 1
        and     edx, $739C
        shr     edx, 2
        and     ebx, $3DEF
        add     ebx, edx
        dec     esp
        mov     word ptr [edi+ecx], bx
        mov     ecx, L6
        je      @@L21
        add     L6, $40
        jmp     @@L15
@@L21:
        cmp     L8, ecx
        jle     @@L24
        mov     eax, dword ptr [esi]
        add     esi, 4
@@L22:
        add     eax, eax
        jae     @@L23
        mov     bx, word ptr [edi+ecx]
        mov     edx, ebx
        shr     ebx, 1
        and     edx, $739C
        shr     edx, 2
        and     ebx, $3DEF
        add     ebx, edx
        lea     ecx, [ecx+2]
        mov     word ptr [edi+ecx], bx
        test    eax, eax
        je      @@L24
        cmp     L8, ecx
        jle     @@L24
        jmp     @@L22
@@L23:
        lea     ecx, [ecx+2]
        je      @@L24
        cmp     L8, ecx
        jg      @@L22
@@L24:
        dec     Height
        je      @@L25
        mov     esi, L10
        add     edi, L4
        add     esi, L7
        jmp     @@L14
@@L25:
        mov     esp, L5
        pop     ebx
        pop     esi
        pop     edi
end;

{ Draws Image into Rect of Canvas: bmStretch stretches it over Rect, bmStretchToFit stretches it
  keeping the aspect ratio, bmCenter scales it by ScaleX and ScaleY percent and centers it,
  bmNone scales it and puts it at the top left. The rest of Rect is filled with BkColor, or
  with Color when Selected (bmStretchToFit and bmCenter); with Color when there is no image.
  DrawRect receives Rect, cut to the image for a selected centered image. }
procedure BltLibraryImage(Canvas: TCanvas; Image: TLibraryImage; Rect: TRect; Mode: TBltMode;
  ScaleX, ScaleY: Integer; BkColor, Color: TColor; Selected: Boolean; var DrawRect: TRect);
var
  W: Integer;
  H, RectWidth, RectHeight, ImageHeight: Integer;
  FitX, FitY: Real;
  OldColor: TColor;
  Rgn, Rgn2: HRGN;
  DestRect, ClipRect, SrcRect: TRect;
begin
  if (Image <> nil) and (Image.FWidth <> 0) and (Image.FHeight <> 0) then
  begin
    W := Image.FWidth;
    ImageHeight := Image.FHeight;
    SrcRect.Left := 0;
    SrcRect.Right := W;
    SrcRect.Top := 0;
    SrcRect.Bottom := ImageHeight;
    case Mode of
      bmStretch:
        begin
          SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
          Image.ShowDC(@SrcRect, @Rect, Canvas.Handle, BkColor);
        end;
      bmStretchToFit:
        begin
          OldColor := Canvas.Brush.Color;
          if Selected then
            Canvas.Brush.Color := Color
          else
            Canvas.Brush.Color := BkColor;
          RectWidth := Rect.Right - Rect.Left;
          RectHeight := Rect.Bottom - Rect.Top;
          H := ImageHeight;
          FitX := RectWidth / W;
          FitY := RectHeight / H;
          if FitX < FitY then
            FitY := FitX
          else
            FitX := FitY;
          W := Round(FitX * W);
          H := Round(FitY * H);
          DestRect.Left := (RectWidth - W) div 2 + Rect.Left;
          DestRect.Top := (RectHeight - H) div 2 + Rect.Top;
          DestRect.Right := W + DestRect.Left;
          DestRect.Bottom := DestRect.Top + H;
          Rgn := CreateRectRgnIndirect(DestRect);
          Rgn2 := CreateRectRgnIndirect(Rect);
          CombineRgn(Rgn2, Rgn2, Rgn, RGN_DIFF);
          FillRgn(Canvas.Handle, Rgn2, Canvas.Brush.Handle);
          DeleteObject(Rgn);
          DeleteObject(Rgn2);
          SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
          Image.ShowDC(@SrcRect, @DestRect, Canvas.Handle, BkColor);
          Canvas.Brush.Color := OldColor;
        end;
      bmCenter:
        begin
          ClipRect := Canvas.ClipRect;
          IntersectClipRect(Canvas.Handle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
          OldColor := Canvas.Brush.Color;
          if Selected then
            Canvas.Brush.Color := Color
          else
            Canvas.Brush.Color := BkColor;
          RectWidth := Rect.Right - Rect.Left;
          RectHeight := Rect.Bottom - Rect.Top;
          W := W * ScaleX div 100;
          H := ImageHeight * ScaleY div 100;
          DestRect.Left := (RectWidth - W) div 2 + Rect.Left;
          DestRect.Top := (RectHeight - H) div 2 + Rect.Top;
          DestRect.Right := W + DestRect.Left;
          DestRect.Bottom := DestRect.Top + H;
          Rgn := CreateRectRgnIndirect(DestRect);
          Rgn2 := CreateRectRgnIndirect(Rect);
          CombineRgn(Rgn2, Rgn2, Rgn, RGN_DIFF);
          FillRgn(Canvas.Handle, Rgn2, Canvas.Brush.Handle);
          DeleteObject(Rgn);
          DeleteObject(Rgn2);
          SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
          Image.ShowDC(@SrcRect, @DestRect, Canvas.Handle, BkColor);
          Canvas.Brush.Color := OldColor;
          Rgn2 := CreateRectRgnIndirect(ClipRect);
          SelectObject(Canvas.Handle, Rgn2);
          DeleteObject(Rgn2);
          if Selected then
          begin
            if DestRect.Left > Rect.Left then Rect.Left := DestRect.Left;
            if DestRect.Right < Rect.Right then Rect.Right := DestRect.Right;
            if DestRect.Top > Rect.Top then Rect.Top := DestRect.Top;
            if DestRect.Bottom < Rect.Bottom then Rect.Bottom := DestRect.Bottom;
          end;
        end;
      bmNone:
        begin
          ClipRect := Canvas.ClipRect;
          IntersectClipRect(Canvas.Handle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
          OldColor := Canvas.Brush.Color;
          Canvas.Brush.Color := BkColor;
          W := Image.FWidth * ScaleX div 100;
          H := Image.FHeight * ScaleY div 100;
          DestRect.Left := Rect.Left;
          DestRect.Top := Rect.Top;
          DestRect.Right := W + DestRect.Left;
          DestRect.Bottom := DestRect.Top + H;
          Rgn := CreateRectRgnIndirect(DestRect);
          Rgn2 := CreateRectRgnIndirect(Rect);
          CombineRgn(Rgn2, Rgn2, Rgn, RGN_DIFF);
          FillRgn(Canvas.Handle, Rgn2, Canvas.Brush.Handle);
          DeleteObject(Rgn);
          DeleteObject(Rgn2);
          SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
          Image.ShowDC(@SrcRect, @DestRect, Canvas.Handle, BkColor);
          Canvas.Brush.Color := OldColor;
          Rgn2 := CreateRectRgnIndirect(ClipRect);
          SelectObject(Canvas.Handle, Rgn2);
          DeleteObject(Rgn2);
        end;
    end;
  end
  else
  begin
    OldColor := Canvas.Brush.Color;
    Canvas.Brush.Color := Color;
    FillRect(Canvas.Handle, Rect, Canvas.Brush.Handle);
    Canvas.Brush.Color := OldColor;
  end;
  DrawRect := Rect;
end;

{ Draws the layers of a sequence for Frame on a 16 bit surface of the size of R, at X, Y, and
  blits it to R of DC }
procedure BltImageSequence(Sequence: TImageSequence; DC: HDC; X, Y: Integer; const R: TRect;
  Frame: Integer; BkColor: TColor);
var
  SD: TSurfaceDesc;
  Surface: TDIB16Surface;
  Index: Integer;
begin
  Surface := TDIB16Surface.Create(R.Right - R.Left, R.Bottom - R.Top, pfRGB565);
  Surface.Cls(BkColor);
  Surface.Lock(SD);
  while Sequence <> nil do
  begin
    Index := Sequence.GetUnloopedFrameIndex(Frame);
    if (Index <> -1) and (Sequence.FImageLibrary <> nil) and
      (Sequence.FImageLibrary.GetSafe(Index) <> nil) then
      Sequence.FImageLibrary[Index].Show(X + Sequence.FdXshift, Y + Sequence.FdYshift, SD);
    Sequence := Sequence.FNext;
  end;
  Surface.Unlock;
  Surface.BltDC(DC, nil, @R);
  Surface.Free;
end;

{ BltLibraryImage for the layers of a sequence: they are drawn for Frame on a 16 bit surface
  of the size of their union first }
procedure BltImageSequenceEx(Canvas: TCanvas; Sequence: TImageSequence; Frame: Integer;
  Rect: TRect; Mode: TBltMode; ScaleX, ScaleY: Integer; BkColor, Color: TColor;
  Selected: Boolean; var DrawRect: TRect);
var
  RectWidth, RectHeight: Integer;
  FitX, FitY: Real;
  Surface: TDIB16Surface;
  DestRect, ClipRect, SrcRect: TRect;
  SD: TSurfaceDesc;
  Bounds, SR: TRect;
  S: TImageSequence;
  Index, W, H: Integer;
  Rgn, Rgn2: HRGN;
  OldColor: TColor;
  ClipRgn: HRGN;
begin
  if Sequence <> nil then
  begin
    Bounds.Left := 0;
    Bounds.Right := 0;
    Bounds.Top := 0;
    Bounds.Bottom := 0;
    S := Sequence;
    while S <> nil do
    begin
      S.GetDimensions(SR);
      UnionRect(Bounds, Bounds, SR);
      S := S.FNext;
    end;
    Surface := TDIB16Surface.Create(Bounds.Right - Bounds.Left, Bounds.Bottom - Bounds.Top,
      pfRGB565);
    Surface.Cls(BkColor);
    Surface.Lock(SD);
    while Sequence <> nil do
    begin
      Index := Sequence.GetUnloopedFrameIndex(Frame);
      if (Index <> -1) and (Sequence.FImageLibrary <> nil) and
        (Sequence.FImageLibrary.GetSafe(Index) <> nil) then
        Sequence.FImageLibrary[Index].Show(Sequence.FdXshift - Bounds.Left,
          Sequence.FdYshift - Bounds.Top, SD);
      Sequence := Sequence.FNext;
    end;
    Surface.Unlock;
    W := Surface.GetWidth;
    H := Surface.GetHeight;
    SrcRect.Left := 0;
    SrcRect.Right := W;
    SrcRect.Top := 0;
    SrcRect.Bottom := H;
    case Mode of
      bmStretch:
        begin
          SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
          Surface.BltDC(Canvas.Handle, @SrcRect, @Rect);
        end;
      bmStretchToFit:
        begin
          OldColor := Canvas.Brush.Color;
          if Selected then
            Canvas.Brush.Color := Color
          else
            Canvas.Brush.Color := BkColor;
          RectWidth := Rect.Right - Rect.Left;
          RectHeight := Rect.Bottom - Rect.Top;
          FitX := RectWidth / W;
          FitY := RectHeight / H;
          if FitX < FitY then
            FitY := FitX
          else
            FitX := FitY;
          W := Round(FitX * W);
          H := Round(FitY * H);
          DestRect.Left := (RectWidth - W) div 2 + Rect.Left;
          DestRect.Top := (RectHeight - H) div 2 + Rect.Top;
          DestRect.Right := W + DestRect.Left;
          DestRect.Bottom := H + DestRect.Top;
          Rgn := CreateRectRgnIndirect(DestRect);
          Rgn2 := CreateRectRgnIndirect(Rect);
          CombineRgn(Rgn2, Rgn2, Rgn, RGN_DIFF);
          FillRgn(Canvas.Handle, Rgn2, Canvas.Brush.Handle);
          DeleteObject(Rgn);
          DeleteObject(Rgn2);
          SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
          Surface.BltDC(Canvas.Handle, @SrcRect, @DestRect);
          Canvas.Brush.Color := OldColor;
        end;
      bmCenter:
        begin
          ClipRect := Canvas.ClipRect;
          IntersectClipRect(Canvas.Handle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
          OldColor := Canvas.Brush.Color;
          if Selected then
            Canvas.Brush.Color := Color
          else
            Canvas.Brush.Color := BkColor;
          RectWidth := Rect.Right - Rect.Left;
          RectHeight := Rect.Bottom - Rect.Top;
          W := W * ScaleX div 100;
          H := H * ScaleY div 100;
          DestRect.Left := (RectWidth - W) div 2 + Rect.Left;
          DestRect.Top := (RectHeight - H) div 2 + Rect.Top;
          DestRect.Right := W + DestRect.Left;
          DestRect.Bottom := H + DestRect.Top;
          Rgn := CreateRectRgnIndirect(DestRect);
          Rgn2 := CreateRectRgnIndirect(Rect);
          CombineRgn(Rgn2, Rgn2, Rgn, RGN_DIFF);
          FillRgn(Canvas.Handle, Rgn2, Canvas.Brush.Handle);
          DeleteObject(Rgn);
          DeleteObject(Rgn2);
          SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
          Surface.BltDC(Canvas.Handle, @SrcRect, @DestRect);
          Canvas.Brush.Color := OldColor;
          ClipRgn := CreateRectRgnIndirect(ClipRect);
          SelectObject(Canvas.Handle, ClipRgn);
          DeleteObject(ClipRgn);
          if Selected then
          begin
            if DestRect.Left > Rect.Left then Rect.Left := DestRect.Left;
            if DestRect.Right < Rect.Right then Rect.Right := DestRect.Right;
            if DestRect.Top > Rect.Top then Rect.Top := DestRect.Top;
            if DestRect.Bottom < Rect.Bottom then Rect.Bottom := DestRect.Bottom;
          end;
        end;
      bmNone:
        begin
          ClipRect := Canvas.ClipRect;
          IntersectClipRect(Canvas.Handle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
          OldColor := Canvas.Brush.Color;
          Canvas.Brush.Color := BkColor;
          W := W * ScaleX div 100;
          H := H * ScaleY div 100;
          DestRect.Left := Rect.Left;
          DestRect.Top := Rect.Top;
          DestRect.Right := W + Rect.Left;
          DestRect.Bottom := H + Rect.Top;
          Rgn := CreateRectRgnIndirect(DestRect);
          Rgn2 := CreateRectRgnIndirect(Rect);
          CombineRgn(Rgn2, Rgn2, Rgn, RGN_DIFF);
          FillRgn(Canvas.Handle, Rgn2, Canvas.Brush.Handle);
          DeleteObject(Rgn);
          DeleteObject(Rgn2);
          SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
          Surface.BltDC(Canvas.Handle, @SrcRect, @DestRect);
          Canvas.Brush.Color := OldColor;
          ClipRgn := CreateRectRgnIndirect(ClipRect);
          SelectObject(Canvas.Handle, ClipRgn);
          DeleteObject(ClipRgn);
        end;
    end;
    Surface.Free;
  end
  else
  begin
    OldColor := Canvas.Brush.Color;
    Canvas.Brush.Color := Color;
    FillRect(Canvas.Handle, Rect, Canvas.Brush.Handle);
    Canvas.Brush.Color := OldColor;
  end;
  DrawRect := Rect;
end;

{ Replaces every sub image of the library that was grabbed from the same file and index as
  Image by a copy of Image with the shifts of the old one; returns the number replaced }
function UpdateImage(ImageLibrary: TCustomImageLibrary; Image: TLibraryImage): Integer;
var
  I, J: Integer;
  Sub, NewImage: TLibraryImage;
begin
  Result := 0;
  if Image <> nil then
    for I := 0 to ImageLibrary.Count - 1 do
      if not ImageLibrary.IsReference(I) then
        for J := 0 to ImageLibrary.GetSubCount(I) - 1 do
        begin
          Sub := ImageLibrary.GetSub(I, J);
          if (Sub <> nil) and (CompareText(Sub.FFileName, Image.FFileName) = 0) and
            (Sub.FFileIndex = Image.FFileIndex) then
          begin
            NewImage := Image.Copy;
            NewImage.Xshift := Sub.Xshift;
            NewImage.Yshift := Sub.Yshift;
            ImageLibrary.SetSubImage(I, J, NewImage);
            Inc(Result);
          end;
        end;
end;

{ Shows Image at every point of a line (Bresenham), skipping Spacing points after each one }
procedure DrawImageLine(Image: TLibraryImage; X1, Y1, X2, Y2, Spacing: Integer;
  const SD: TSurfaceDesc);
var
  X, Y, Inc2, DX2, DY2, DX, DY, D, Skip: Integer;
begin
  Skip := 0;
  if X1 > X2 then
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
  if Y1 <= Y2 then
  begin
    DX := X2 - X1;
    DY := Y2 - Y1;
    if DY >= DX then
    begin
      Inc2 := (DX - DY) * 2;
      DX2 := DX * 2;
      D := DX2 - DY;
      while Y <> Y2 do
      begin
        if Skip = 0 then
        begin
          Image.Show(X, Y, SD);
          Skip := Spacing;
        end
        else
          Dec(Skip);
        if D >= 0 then
        begin
          Inc(D, Inc2);
          Inc(X);
        end
        else
          Inc(D, DX2);
        Inc(Y);
      end;
      if Skip = 0 then Image.Show(X, Y, SD);
    end
    else
    begin
      Inc2 := (DY - DX) * 2;
      DY2 := DY * 2;
      D := DY2 - DX;
      while X <> X2 do
      begin
        if Skip = 0 then
        begin
          Image.Show(X, Y, SD);
          Skip := Spacing;
        end
        else
          Dec(Skip);
        if D >= 0 then
        begin
          Inc(D, Inc2);
          Inc(Y);
        end
        else
          Inc(D, DY2);
        Inc(X);
      end;
      if Skip = 0 then Image.Show(X, Y, SD);
    end;
  end
  else
  begin
    DX := X2 - X1;
    DY := Y1 - Y2;
    if DY >= DX then
    begin
      Inc2 := (DX - DY) * 2;
      DX2 := DX * 2;
      D := DX2 - DY;
      while Y <> Y2 do
      begin
        if Skip = 0 then
        begin
          Image.Show(X, Y, SD);
          Skip := Spacing;
        end
        else
          Dec(Skip);
        if D >= 0 then
        begin
          Inc(D, Inc2);
          Inc(X);
        end
        else
          Inc(D, DX2);
        Dec(Y);
      end;
      if Skip = 0 then Image.Show(X, Y, SD);
    end
    else
    begin
      Inc2 := (DY - DX) * 2;
      DY2 := DY * 2;
      D := DY2 - DX;
      while X <> X2 do
      begin
        if Skip = 0 then
        begin
          Image.Show(X, Y, SD);
          Skip := Spacing;
        end
        else
          Dec(Skip);
        if D >= 0 then
        begin
          Inc(D, Inc2);
          Dec(Y);
        end
        else
          Inc(D, DY2);
        Inc(X);
      end;
      if Skip = 0 then Image.Show(X, Y, SD);
    end;
  end;
end;

{ TImageLibraryFont }

constructor TImageLibraryFont.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCharacterDistance := 2;
  FFontColorPaletteIndex := -1;
  FCharCase := ecNormal;
end;

procedure TImageLibraryFont.SetFontColorPaletteIndex(Value: Integer);
begin
  if Value > 255 then Value := 255;
  if Value < 0 then Value := -1;
  FFontColorPaletteIndex := Value;
end;

procedure TImageLibraryFont.SetColor(Value: TColor);
var
  P: TLibraryImagePalette;
  R: TGFXEPalette;
begin
  if (FFontColorPaletteIndex >= 0) and (FPaletteManager.FPalettes.Count <> 0) then
  begin
    P := TLibraryImagePalette(FPaletteManager.FPalettes.List^[0]);
    PInteger(P.FPalette.GetEntry(FFontColorPaletteIndex))^ :=
      Color2PixelInfo(Value, P.FPalette.PixelFormatID, nil);
    R := P.FRemapPalette;
    if R <> nil then
      PInteger(P.FRemapPalette.GetEntry(FFontColorPaletteIndex))^ :=
        Color2PixelInfo(Value, R.PixelFormatID, nil);
  end;
  FColor := Value;
end;

procedure TImageLibraryFont.LoadFromStream(Stream: TStream);
var
  I: Integer;
begin
  inherited LoadFromStream(Stream);
  FHeight := 0;
  I := 0;
  while I < FCount do
  begin
    if Images[I] <> nil then
      if Images[I].Height > FHeight then FHeight := Images[I].Height;
    Inc(I);
  end;
end;

{ The image lookup repeats TCustomImageLibrary.Get, with the reference index passed through the
  image variable as there. }
function TImageLibraryFont.TextWidth(const S: string): Integer;
var
  I, C, L: Integer;
  Image: TLibraryImage;
begin
  L := Length(S);
  Result := 0;
  for I := 1 to L do
  begin
    C := Ord(S[I]);
    if C < FCount then
    begin
      Image := FImages^[C].Image;
      if Image = nil then
      begin
        Image := TLibraryImage(FImages^[C].Reference);
        if Integer(Image) <> -1 then
          Image := FImages^[Integer(Image)].Image
        else
          Image := nil;
      end;
    end
    else Image := nil;
    if Image <> nil then Inc(Result, Image.Width + FCharacterDistance)
    else Inc(Result, FCharacterDistance + 5);
  end;
end;

{ ShowText: the same image lookup as TextWidth. }
procedure TImageLibraryFont.ShowText(X, Y: Integer; const S: string; const SD: TSurfaceDesc);
var
  I, C: Integer;
  Image: TLibraryImage;
begin
  for I := 1 to Length(S) do
  begin
    C := Ord(S[I]);
    if C < FCount then
    begin
      Image := FImages^[C].Image;
      if Image = nil then
      begin
        Image := TLibraryImage(FImages^[C].Reference);
        if Integer(Image) <> -1 then
          Image := FImages^[Integer(Image)].Image
        else
          Image := nil;
      end;
    end
    else Image := nil;
    if Image <> nil then
    begin
      Image.Show(X, Y, SD);
      Inc(X, Image.Width + FCharacterDistance);
    end
    else Inc(X, FCharacterDistance + 5);
  end;
end;

function TImageLibraryFont.GetTextWidth(const Text: string): Integer;
begin
  case FCharCase of
    ecNormal: Result := TextWidth(Text);
    ecLowerCase: Result := TextWidth(LowerCase(Text));
    ecUpperCase: Result := TextWidth(UpperCase(Text));
  else
    Result := 0;
  end;
end;

function TImageLibraryFont.GetTextHeight(const Text: string): Integer;
var
  I, H, C: Integer;
  S: string;
begin
  case FCharCase of
    ecLowerCase: S := LowerCase(Text);
    ecUpperCase: S := UpperCase(Text);
  else
    S := Text;
  end;
  H := 0;
  for I := 1 to Length(S) do
  begin
    C := Ord(S[I]);
    if (C < FCount) and (Images[C] <> nil) and (Images[C].Height > H) then
      H := Images[C].Height;
  end;
  Result := H;
end;

procedure TImageLibraryFont.SetText(X, Y: Integer; const Text: string; const SD: TSurfaceDesc);
begin
  case FCharCase of
    ecNormal: ShowText(X, Y, Text, SD);
    ecLowerCase: ShowText(X, Y, LowerCase(Text), SD);
    ecUpperCase: ShowText(X, Y, UpperCase(Text), SD);
  end;
end;

procedure TImageLibraryFont.SetTextCentered(X, Y: Integer; const Text: string; const SD: TSurfaceDesc);
var
  S: string;
begin
  case FCharCase of
    ecNormal:
      begin
        X := X - TextWidth(Text) shr 1;
        ShowText(X, Y, Text, SD);
      end;
    ecLowerCase:
      begin
        S := LowerCase(Text);
        X := X - TextWidth(S) shr 1;
        ShowText(X, Y, S, SD);
      end;
    ecUpperCase:
      begin
        S := UpperCase(Text);
        X := X - TextWidth(S) shr 1;
        ShowText(X, Y, S, SD);
      end;
  end;
end;

procedure TImageLibraryFont.SetTextEx(X, Y: Integer; const Text: string; const SD: TSurfaceDesc;
  Mode: TSetTextMode; const ShowInfo: TShowInfo);
var
  I, C: Integer;
  S: string;
begin
  case FCharCase of
    ecLowerCase: S := LowerCase(Text);
    ecUpperCase: S := UpperCase(Text);
  else
    S := Text;
  end;
  if stmCenter in Mode then X := X - TextWidth(S) shr 1;
  for I := 1 to Length(S) do
  begin
    C := Ord(S[I]);
    if (C < FCount) and (Images[C] <> nil) then
    begin
      Images[C].ShowEx(X, Y, SD, ShowInfo);
      Inc(X, Images[C].Width + FCharacterDistance);
    end
    else Inc(X, FCharacterDistance + 5);
  end;
end;

procedure ParseFontText(Text: string; Strings: TStrings; Font: TImageLibraryFont; MaxWidth: Integer);
var
  I, J, W, Len, LineWidth: Integer;
  Word, Line: string;
begin
  I := 1;
  LineWidth := 0;
  Line := '';
  Len := Length(Text);
  while I <= Len do
  begin
    if Text[I] in [#13, ' '] then Inc(I);
    J := 0;
    while (I + J <= Len) and not (Text[I + J] in [#10, #13, ' ']) do Inc(J);
    Word := Copy(Text, I, J);
    W := Font.GetTextWidth(Word);
    if (LineWidth + W > MaxWidth) and (Line <> '') then
    begin
      Strings.Add(Line);
      Line := '';
      LineWidth := 0;
    end;
    if Line <> '' then
    begin
      Line := Line + ' ' + Word;
      LineWidth := LineWidth + W + Font.GetTextWidth(' ');
    end
    else
    begin
      Line := Line + Word;
      Inc(LineWidth, W);
    end;
    if (I + J <= Len) and (Text[I + J] = #10) then
    begin
      Strings.Add(Line);
      Line := '';
      LineWidth := 0;
      Inc(I);
    end;
    Inc(I, J);
  end;
  if Line <> '' then Strings.Add(Line);
end;

{ TCustomImageLibraryPanel }

constructor TCustomImageLibraryPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBltMode := bmStretchToFit;
  Color := clBlack;
  FScaleX := 100;
  FScaleY := 100;
end;

procedure TCustomImageLibraryPanel.SetBltMode(Value: TBltMode);
begin
  FBltMode := Value;
  Invalidate;
end;

procedure TCustomImageLibraryPanel.SetScaleX(Value: Integer);
begin
  FScaleX := Value;
  Invalidate;
end;

procedure TCustomImageLibraryPanel.SetScaleY(Value: Integer);
begin
  FScaleY := Value;
  Invalidate;
end;

procedure TCustomImageLibraryPanel.SetImageIndex(Value: Integer);
begin
  FImageIndex := Value;
  Invalidate;
end;

procedure TCustomImageLibraryPanel.SetImageLibrary(Value: TCustomImageLibrary);
begin
  FImageLibrary := Value;
  Invalidate;
end;

procedure TCustomImageLibraryPanel.Paint;
var
  R: TRect;
  L: TCustomImageLibrary;
  Image: TLibraryImage;
begin
  if not (csDestroying in ComponentState) then
  begin
    L := FImageLibrary;
    if L <> nil then
    begin
      Image := L.GetSafe(FImageIndex);
      if Image <> nil then
        BltLibraryImage(Canvas, Image, ClientRect, FBltMode, FScaleX, FScaleY, clBlack, Color,
          False, R)
      else inherited Paint;
    end
    else inherited Paint;
    if Assigned(FOnUpdated) then FOnUpdated(Self);
  end
  else inherited Paint;
end;

{ Draws the two-pixel frame in Color around R and, when Focused, the focus rectangles inside
  and outside it (TCustomImageDrawGrid.DrawCell). }
procedure DrawFocusFrame(DC: HDC; R: TRect; Focused: Boolean; Color: TColor);
var
  Brush: HBRUSH;
  OldBrush: HGDIOBJ;
  OldColor: TColorRef;
begin
  Brush := CreateSolidBrush(Color);
  OldColor := SetBkColor(DC, ColorToRGB(Color));
  OldBrush := SelectObject(DC, Brush);
  FrameRect(DC, R, Brush);
  if Focused then DrawFocusRect(DC, R);
  Inc(R.Left); Inc(R.Top); Dec(R.Right); Dec(R.Bottom);
  FrameRect(DC, R, Brush);
  Inc(R.Left); Inc(R.Top); Dec(R.Right); Dec(R.Bottom);
  if Focused then
  begin
    FrameRect(DC, R, Brush);
    DrawFocusRect(DC, R);
  end;
  SelectObject(DC, OldBrush);
  SetBkColor(DC, OldColor);
  DeleteObject(Brush);
end;

{ TCustomImageDrawGrid }

constructor TCustomImageDrawGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBltMode := bmStretchToFit;
  FFocusColor := clRed;
  DefaultColWidth := 64;
  DefaultRowHeight := 64;
  DefaultDrawing := False;
  FScaleX := 100;
  FScaleY := 100;
  FixedCols := 0;
  FixedRows := 0;
  FSelectionEnabled := True;
  FGrowDirection := ilHorizontal;
  Color := clBtnFace;
  GridLineWidth := 4;
  Options := Options - [goRangeSelect] + [goDrawFocusSelected];
end;

function TCustomImageDrawGrid.SelectCell(ACol, ARow: Longint): Boolean;
begin
  Result := True;
  if Assigned(FOnSelectCell) then FOnSelectCell(Self, ACol, ARow, Result);
  FSelectionEnabled := True;
end;

procedure TCustomImageDrawGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and FSelectionEnabled then
    case Key of
      Ord('X'): CutCell;
      Ord('C'): CopyCell;
      Ord('V'): PasteCell;
      VK_DELETE: DeleteCell;
    end;
  if Shift = [] then
    case Key of
      VK_INSERT: InsCell;
      VK_DELETE: DelCell;
    end;
  inherited KeyDown(Key, Shift);
end;

procedure TCustomImageDrawGrid.CutCell;
begin
end;

procedure TCustomImageDrawGrid.CopyCell;
begin
end;

procedure TCustomImageDrawGrid.DeleteCell;
begin
end;

procedure TCustomImageDrawGrid.PasteCell;
begin
end;

procedure TCustomImageDrawGrid.InsCell;
begin
end;

procedure TCustomImageDrawGrid.DelCell;
begin
end;

procedure TCustomImageDrawGrid.SetCount(Value: Integer);
begin
  { differs from the original in one register: it keeps Self in esi across the virtual call }
  FCount := Value;
  UpdateDimensions;
end;

procedure TCustomImageDrawGrid.UpdateDimensions;
begin
  case FGrowDirection of
    ilHorizontal: ColCount := (RowCount + FCount) div RowCount;
    ilVertical: RowCount := (ColCount + FCount) div ColCount;
  end;
end;

function TCustomImageDrawGrid.ImageIndex(ACol, ARow: Integer): Integer;
begin
  Result := ColCount * ARow + ACol;
end;

procedure TCustomImageDrawGrid.IndexToCell(Index: Integer; var ACol, ARow: Integer);
begin
  ACol := Index mod ColCount;
  ARow := Index div ColCount;
end;

procedure TCustomImageDrawGrid.SelectIndex(Index: Integer);
var
  ACol, ARow: Integer;
  R: TGridRect;
begin
  { differs from the original in one register: it moves Index to edi, the original leaves it in
    edx for the call }
  IndexToCell(Index, ACol, ARow);
  if SelectCell(ACol, ARow) then
  begin
    R.Left := ACol;
    R.Right := ACol;
    R.Top := ARow;
    R.Bottom := ARow;
    Selection := R;
  end;
end;

procedure TCustomImageDrawGrid.SetBltMode(Value: TBltMode);
begin
  FBltMode := Value;
  Invalidate;
end;

procedure TCustomImageDrawGrid.SetSelectionEnabled(Value: Boolean);
begin
  FSelectionEnabled := Value;
  Invalidate;
end;

procedure TCustomImageDrawGrid.SetFocusColor(Value: TColor);
begin
  FFocusColor := Value;
end;

procedure TCustomImageDrawGrid.SetScaleX(Value: Integer);
begin
  FScaleX := Value;
  Invalidate;
end;

procedure TCustomImageDrawGrid.SetScaleY(Value: Integer);
begin
  FScaleY := Value;
  Invalidate;
end;

procedure TCustomImageDrawGrid.SetShowGridIndex(Value: Boolean);
begin
  FShowGridIndex := Value;
  Invalidate;
end;

function TCustomImageDrawGrid.GetColCount: Integer;
begin
  Result := inherited ColCount;
end;

procedure TCustomImageDrawGrid.SetColCount(Value: Integer);
begin
  if (FMinColCount <> 0) and (Value < FMinColCount) then Value := FMinColCount;
  if (FMaxColCount <> 0) and (Value > FMaxColCount) then Value := FMaxColCount;
  inherited ColCount := Value;
end;

procedure TCustomImageDrawGrid.SetMinRowCount(Value: Integer);
begin
  FMinRowCount := Value;
  RowCount := RowCount;
end;

procedure TCustomImageDrawGrid.SetMinColCount(Value: Integer);
begin
  FMinColCount := Value;
  ColCount := ColCount;
end;

procedure TCustomImageDrawGrid.SetMaxRowCount(Value: Integer);
begin
  FMaxRowCount := Value;
  RowCount := RowCount;
end;

procedure TCustomImageDrawGrid.SetMaxColCount(Value: Integer);
begin
  FMaxColCount := Value;
  ColCount := ColCount;
end;

function TCustomImageDrawGrid.GetRowCount: Integer;
begin
  Result := inherited RowCount;
end;

procedure TCustomImageDrawGrid.SetRowCount(Value: Integer);
begin
  if (FMinRowCount <> 0) and (Value < FMinRowCount) then Value := FMinRowCount;
  if (FMaxRowCount <> 0) and (Value > FMaxRowCount) then Value := FMaxRowCount;
  inherited RowCount := Value;
end;

procedure TCustomImageDrawGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  S: string;
begin
  if not (csDesigning in ComponentState) then
  begin
    if Assigned(FOnCellUpdated) then FOnCellUpdated(Self, ACol, ARow, ARect, AState);
  end
  else
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ARect);
  end;
  if FShowGridIndex then
  begin
    S := IntToStr(ImageIndex(ACol, ARow));
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Color := Font.Color;
    Inc(ARect.Left, 3);
    Inc(ARect.Top, 2);
    DrawText(Canvas.Handle, PChar(S), Length(S), ARect, DT_WORDBREAK or DT_EXPANDTABS);
    Dec(ARect.Left, 3);
    Dec(ARect.Top, 2);
  end;
  if FSelectionEnabled and ((gdFocused in AState) or (gdSelected in AState)) then
    DrawFocusFrame(Canvas.Handle, ARect, gdFocused in AState, FFocusColor);
end;

{ TCustomImageLibraryGrid }

function TCustomImageLibraryGrid.CreateSelectedIL: TCustomImageLibrary;
var
  C, R: Integer;
  Image: TLibraryImage;
begin
  Result := TCustomImageLibrary.Create(nil);
  if FImageLibrary <> nil then
    for R := Selection.Top to Selection.Bottom do
      for C := Selection.Left to Selection.Right do
      begin
        Image := FImageLibrary.GetSafe(ImageIndex(C, R));
        if Image <> nil then Result.Add(Image.Copy)
        else Result.Add(nil);
      end;
end;

procedure TCustomImageLibraryGrid.InsCell;
begin
  if (igIns in FEditMode) and (FImageLibrary <> nil) then
  begin
    FImageLibrary.Insert(ImageIndex(Col, Row), nil);
    Invalidate;
  end;
end;

procedure TCustomImageLibraryGrid.DelCell;
begin
  if (igDel in FEditMode) and (FImageLibrary <> nil) then
  begin
    FImageLibrary.Delete(ImageIndex(Col, Row));
    Invalidate;
  end;
end;

procedure TCustomImageLibraryGrid.CutCell;
var
  L: TCustomImageLibrary;
  C, R: Integer;
begin
  if (igCut in FEditMode) and (FImageLibrary <> nil) then
  begin
    { differs from the original in the try frame register (xor eax,eax for xor edx,edx) }
    L := TCustomImageLibrary.Create(nil);
    try
      FImageLibrary.DisableOnChangeEvent;
      for R := Selection.Top to Selection.Bottom do
        for C := Selection.Left to Selection.Right do
          if FImageLibrary.GetSafe(ImageIndex(C, R)) <> nil then
            L.Add(FImageLibrary.GetImage(ImageIndex(C, R)))
          else L.Add(nil);
      Invalidate;
      FImageLibrary.EnableOnChangeEvent;
      if L.Count <> 0 then L.CopyToClipboard;
    finally
      L.Free;
    end;
  end;
end;

procedure TCustomImageLibraryGrid.CopyCell;
var
  L: TCustomImageLibrary;
begin
  if (igCopy in FEditMode) and (FImageLibrary <> nil) then
  begin
    L := CreateSelectedIL;
    try
      L.CopyToClipboard;
    finally
      L.Free;
    end;
  end;
end;

procedure TCustomImageLibraryGrid.DeleteCell;
var
  C, R: Integer;
begin
  if (igDelete in FEditMode) and (FImageLibrary <> nil) then
  begin
    FImageLibrary.DisableOnChangeEvent;
    for R := Selection.Top to Selection.Bottom do
      for C := Selection.Left to Selection.Right do
        FImageLibrary.SetImage(ImageIndex(C, R), nil);
    Invalidate;
    FImageLibrary.EnableOnChangeEvent;
  end;
end;

procedure TCustomImageLibraryGrid.PasteCell;
var
  L: TCustomImageLibrary;
  I, C, R: Integer;
begin
  { the pasted library is owned by the grid and never freed }
  if (igPaste in FEditMode) and (FImageLibrary <> nil) then
  begin
    L := TImageLibrary.Create(Self);
    L.PasteFromClipboard;
    if L.Count <> 0 then
    begin
      I := 0;
      FImageLibrary.DisableOnChangeEvent;
      for R := Selection.Top to Selection.Bottom do
        for C := Selection.Left to Selection.Right do
          if I < L.Count then
          begin
            FImageLibrary.SetImage(ImageIndex(C, R), L.GetImage(I));
            Inc(I);
          end;
      Invalidate;
      FImageLibrary.EnableOnChangeEvent;
    end;
  end;
end;

procedure TCustomImageLibraryGrid.SetImageLibrary(Value: TCustomImageLibrary);
begin
  FImageLibrary := Value;
  if FImageLibrary <> nil then Count := FImageLibrary.Count
  else Count := 0;
  Invalidate;
end;

procedure TCustomImageLibraryGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  R: TRect;
  L: TCustomImageLibrary;
  Image: TLibraryImage;
begin
  if not (csDestroying in ComponentState) then
  begin
    L := FImageLibrary;
    if L <> nil then
    begin
      Image := L.GetSafe(ImageIndex(ACol, ARow));
      if Image <> nil then
        BltLibraryImage(Canvas, Image, ARect, FBltMode, FScaleX, FScaleY, clBlack, Color, False, R);
    end
    else Image := nil;
    if Image = nil then
      with Canvas do
      begin
        Brush.Color := Color;
        FillRect(ARect);
      end;
  end;
  inherited DrawCell(ACol, ARow, ARect, AState);
end;


{ TPaletteManager }

constructor TPaletteManager.Create;
begin
  inherited Create;
  FPalettes := TList.Create;
end;

destructor TPaletteManager.Destroy;
begin
  Clear;
  FPalettes.Free;
  inherited Destroy;
end;

function TPaletteManager.GetCount: Integer;
begin
  Result := FPalettes.Count;
end;

function TPaletteManager.GetPalette(Index: Integer): TLibraryImagePalette;
begin
  Result := TLibraryImagePalette(FPalettes.Items[Index]);
end;

procedure TPaletteManager.UpdateIndices;
var
  I: Integer;
begin
  for I := 0 to FPalettes.Count - 1 do TLibraryImagePalette(FPalettes[I]).FIndex := I;
end;

procedure TPaletteManager.LoadFromStream(Stream: TStream);
var
  I, N: Integer;
  P: TLibraryImagePalette;
begin
  Clear;
  Stream.Read(N, 4);
  for I := 0 to N - 1 do
  begin
    P := TLibraryImagePalette.Create;
    P.LoadFromStream(Stream);
    FPalettes.Add(P);
    P.FIndex := I;
  end;
end;

procedure TPaletteManager.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  Stream.Write(FPalettes.Count, 4);
  for I := 0 to FPalettes.Count - 1 do TLibraryImagePalette(FPalettes.List^[I]).SaveToStream(Stream);
end;

procedure TPaletteManager.Clear;
var
  I: Integer;
begin
  for I := FPalettes.Count - 1 downto 0 do TLibraryImagePalette(FPalettes.List^[I]).Free;
  FPalettes.Clear;
end;

function TPaletteManager.LinkToPalette(Index: Integer): TLibraryImagePalette;
begin
  Result := TLibraryImagePalette(FPalettes.Items[Index]);
  Inc(Result.FRefCount);
end;

function TPaletteManager.RegisterPalette(Palette: TGFXEPalette): TLibraryImagePalette;
var
  I: Integer;
  Found: Boolean;
  P: TLibraryImagePalette;
begin
  I := FPalettes.Count;
  Found := False;
  while (I <> 0) and not Found do
  begin
    Dec(I);
    Found := Palette.Compare(TLibraryImagePalette(FPalettes.List^[I]).FPalette);
  end;
  if not Found then
  begin
    P := TLibraryImagePalette.Create;
    P.FPalette.Assign(Palette);
    P.FIndex := FPalettes.Count;
    P.FRefCount := 1;
    FPalettes.Add(P);
    Result := P;
  end
  else
  begin
    Inc(TLibraryImagePalette(FPalettes[I]).FRefCount);
    Result := FPalettes[I];
  end;
end;

procedure TPaletteManager.UnregisterPalette(Index: Integer);
var
  P: TLibraryImagePalette;
begin
  P := FPalettes[Index];
  Dec(P.FRefCount);
  if P.FRefCount <= 0 then
  begin
    FPalettes.Delete(Index);
    UpdateIndices;
    P.Free;
  end;
end;

{ TLibraryImagePalette }

constructor TLibraryImagePalette.Create;
begin
  inherited Create;
  FPalette := TGFXEPalette.Create;
end;

destructor TLibraryImagePalette.Destroy;
begin
  FPalette.Free;
  FRemapPalette.Free;
  inherited Destroy;
end;

procedure TLibraryImagePalette.SaveToStream(Stream: TStream);
begin
  FPalette.SaveToStream(Stream);
end;

procedure TLibraryImagePalette.LoadFromStream(Stream: TStream);
begin
  FPalette.LoadFromStream(Stream);
end;

function TLibraryImagePalette.RemapPalette(PixelFormatID: Integer): TGFXEPalette;
begin
  if PixelFormatID = FPalette.PixelFormatID then
    Result := FPalette
  else
  begin
    Color2PixelInfo(0, PixelFormatID, FPalette);
    if (FRemapPalette = nil) or (PixelFormatID <> FRemapPalette.PixelFormatID) then
    begin
      if FRemapPalette = nil then FRemapPalette := TGFXEPalette.Create;
      FRemapPalette.Assign(FPalette);
      FRemapPalette.Remap(PixelFormatID);
    end;
    Result := FRemapPalette;
  end;
end;

procedure TLibraryImagePalette.Assign(Source: TPersistent);
begin
  if Source is TLibraryImagePalette then
  begin
    FPalette.Assign(TLibraryImagePalette(Source).FPalette);
    if TLibraryImagePalette(Source).FRemapPalette <> nil then
    begin
      if FRemapPalette = nil then FRemapPalette := TGFXEPalette.Create;
      FRemapPalette.Assign(TLibraryImagePalette(Source).FRemapPalette);
    end
    else
      FRemapPalette.Free;
  end
  else
    raise EConvertError.Create('Can only assign to a TLibraryImagePalette descendant');
end;

{ The RLE sprite blitters (assembler, at the end of this part): Data holds Height rows of the
  encoding TRLESprite08.GrabImage makes; ShowRLE08 copies the opaque pixels to an 8 bit
  surface without clipping, ShowRLE08to16 maps them through the 16 bit Palette entries and
  clips to SD.ClipRect. }
procedure ShowRLE08(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer; Width, Height: Integer;
  ColorKey: Byte); pascal; forward;
procedure ShowRLE08to16(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer;
  Width, Height: Integer; ColorKey: Byte; Palette: Pointer); pascal; forward;

{ TImage08 }

procedure TImage08.Clear;
begin
  UnregisterPalette;
  FImagePalette.Free;
  FImagePalette := nil;
  inherited Clear;
end;

procedure TImage08.ReadImageData(Stream: TStream);
var
  Index: Integer;
begin
  inherited ReadImageData(Stream);
  Stream.Read(FOwnPalette, 1);
  if FOwnPalette then
  begin
    FImagePalette := TLibraryImagePalette.Create;
    FImagePalette.LoadFromStream(Stream);
  end
  else
  begin
    Stream.Read(Index, 4);
    FImagePalette := FOwner.FPaletteManager.LinkToPalette(Index);
  end;
  FRemapPalette := FImagePalette.FPalette;
end;

procedure TImage08.WriteImageData(Stream: TStream);
begin
  inherited WriteImageData(Stream);
  Stream.Write(FOwnPalette, 1);
  if FOwnPalette then
    FImagePalette.SaveToStream(Stream)
  else
    Stream.Write(FImagePalette.FIndex, 4);
end;

procedure TImage08.RegisterPalette;
var
  Old: TLibraryImagePalette;
begin
  if FOwnPalette and (FImagePalette <> nil) and (FOwner <> nil) then
  begin
    Old := FImagePalette;
    FImagePalette := FOwner.FPaletteManager.RegisterPalette(FImagePalette.FPalette);
    Old.Free;
    FRemapPalette := FImagePalette.FPalette;
    FOwnPalette := False;
  end;
end;

procedure TImage08.UnregisterPalette;
var
  P: TLibraryImagePalette;
begin
  if not FOwnPalette and (FImagePalette <> nil) then
  begin
    P := TLibraryImagePalette.Create;
    P.Assign(FImagePalette);
    FOwner.FPaletteManager.UnregisterPalette(FImagePalette.FIndex);
    FImagePalette := P;
    FRemapPalette := FImagePalette.FPalette;
    FOwnPalette := True;
  end;
end;

procedure TImage08.CreateLibraryImagePalette(Palette: TGFXEPalette);
begin
  UnregisterPalette;
  if FImagePalette = nil then FImagePalette := TLibraryImagePalette.Create;
  FImagePalette.FPalette.Assign(Palette);
  FRemapPalette := FImagePalette.FPalette;
  FOwnPalette := True;
end;

procedure TImage08.SetOwner(AOwner: TCustomImageLibrary);
begin
  if AOwner <> FOwner then
  begin
    UnregisterPalette;
    inherited SetOwner(AOwner);
    RegisterPalette;
  end;
end;

function TImage08.RemapToPixelFormat(PixelFormatID: Integer): HResult;
var
  P: TGFXEPalette;
begin
  P := FImagePalette.RemapPalette(PixelFormatID);
  if P <> nil then
  begin
    FRemapPalette := P;
    Result := GFXE_OK;
  end
  else
    Result := GFXE_NOTSUPPORTED;
end;

function TImage08.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := PixelFormatID = pfPAL8;
end;

{ ShowDC remaps the palette to pfPAL8 (an original slip: the surface is pfRGB565; ShowOpaque
  remaps the palette again when it differs). }
procedure TImage08.ShowDC(SrcRect, DestRect: PRect; DC: HDC; BkColor: TColor);
var
  H: HWND;
  Surface: TDIB16Surface;
  SD: TSurfaceDesc;
  R, ClientRect: TRect;
begin
  if SrcRect = nil then
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := FWidth;
    R.Bottom := FHeight;
    SrcRect := @R;
  end;
  RemapToPixelFormat(pfPAL8);
  Surface := TDIB16Surface.Create(SrcRect^.Right - SrcRect^.Left, SrcRect^.Bottom - SrcRect^.Top,
    pfRGB565);
  try
    if DestRect = nil then
    begin
      H := WindowFromDC(DC);
      GetClientRect(H, ClientRect);
      DestRect := @ClientRect;
    end;
    Surface.Cls(BkColor);
    Surface.Lock(SD);
    Show(-SrcRect^.Left, -SrcRect^.Top, SD);
    Surface.BltDC(DC, nil, DestRect);
    Surface.Unlock;
  finally
    Surface.Free;
  end;
end;

{ TPicture08 }

class function TPicture08.ClassID: Integer;
begin
  Result := 1;
end;

class function TPicture08.Name: string;
begin
  Result := 'Picture (08bpp)';
end;

procedure TPicture08.SetXshift(Value: Integer);
begin
  if Value < 0 then Value := 0;
  inherited SetXshift(Value);
  SetWidth(FWidth);
end;

procedure TPicture08.SetYshift(Value: Integer);
begin
  if Value < 0 then Value := 0;
  inherited SetYshift(Value);
  SetHeight(FHeight);
end;

procedure TPicture08.SetWidth(Value: Integer);
begin
  if Value < FDataWidth + FXshift then Value := FDataWidth + FXshift;
  inherited SetWidth(Value);
end;

procedure TPicture08.SetHeight(Value: Integer);
begin
  if Value < FDataHeight + FYshift then Value := FDataHeight + FYshift;
  inherited SetHeight(Value);
end;

function TPicture08.SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean;
begin
  Result := ((PixelFormatID = 0) or (PixelFormatID = pfPAL8) or (PixelFormatID = pfRGB555) or
    (PixelFormatID = pfRGB565)) and (ShowMode = smOpaque);
end;

procedure TPicture08.AllocateDiscardableImageData(AWidth, AHeight: Integer);
var
  Size: Integer;
begin
  if AWidth < 32 then
    FPitch := (AWidth + 3) and not 3
  else
    FPitch := (AWidth + 7) and not 7;
  Size := FPitch * AHeight + 7;
  ReallocMem(FBuffer, Size);
  FBits := Pointer((Integer(FBuffer) + 7) and not 7);
end;

procedure TPicture08.ReleaseDiscardableImageData;
begin
  if FDataLoaded then
  begin
    ReallocMem(FBuffer, 0);
    FDataLoaded := False;
  end;
end;

procedure TPicture08.ReadDiscardableImageData(Stream: TStream);
var
  Y: Integer;
begin
  inherited ReadDiscardableImageData(Stream);
  AllocateDiscardableImageData(FDataWidth, FDataHeight);
  for Y := 0 to FDataHeight - 1 do
    Stream.Read(Pointer(Y * FPitch + Integer(FBits))^, FDataWidth);
end;

procedure TPicture08.WriteDiscardableImageData(Stream: TStream);
var
  Y: Integer;
begin
  inherited WriteDiscardableImageData(Stream);
  for Y := 0 to FDataHeight - 1 do
    Stream.Write(Pointer(Y * FPitch + Integer(FBits))^, FDataWidth);
end;

function TPicture08.CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
  OnImagesGrabbed: TImagesGrabbedEvent): TForm;
begin
  Result := nil;
end;

function TPicture08.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := PixelFormatID = pfPAL8;
end;

function TPicture08.GrabImage(const SD: TSurfaceDesc; const R: TRect;
  GrabInfo: TGrabInfo): Boolean;
var
  Y: Integer;
begin
  try
    Clear;
    Result := True;
    FDataLoaded := True;
    FDataWidth := R.Right - R.Left;
    FDataHeight := R.Bottom - R.Top;
    FWidth := FDataWidth;
    FHeight := FDataHeight;
    FFileName := ExtractFileName(GrabInfo.FileName);
    FFileIndex := GrabInfo.FileIndex;
    FDataSize := FDataWidth * FDataHeight;
    AllocateDiscardableImageData(FWidth, FHeight);
    if SD.PixelFormatID = pfPAL8 then
    begin
      for Y := 0 to FHeight - 1 do
        Move(Pointer((R.Top + Y) * SD.Pitch + Integer(SD.Data) + R.Left)^,
          Pointer(Integer(FBits) + FPitch * Y)^, FDataWidth);
      CreateLibraryImagePalette(SD.Palette);
      if FOwner <> nil then RegisterPalette;
    end
    else
      Result := False;
  except
    ReleaseDiscardableImageData;
    Result := False;
  end;
end;

{ ShowOpaque: the clipped source offsets are counted from X and Y, not from X + Xshift and
  Y + Yshift (an original bug for shifted pictures). }
procedure TPicture08.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
var
  DestX, Right, Bottom: Integer;
  W, H, SrcX, SrcY, DestY: Integer;
  Src: Pointer;
begin
  DestX := X + FXshift;
  W := FDataWidth;
  Right := FDataWidth + DestX;
  if DestX < SD.ClipRect.Left then
  begin
    SrcX := SD.ClipRect.Left - X;
    DestX := SD.ClipRect.Left;
    Dec(W, SrcX);
  end
  else
    SrcX := 0;
  if Right > SD.ClipRect.Right then Dec(W, Right - SD.ClipRect.Right);
  if W > 0 then
  begin
    DestY := Y + FYshift;
    H := FDataHeight;
    Bottom := DestY + FDataHeight;
    if SD.ClipRect.Top > DestY then
    begin
      SrcY := SD.ClipRect.Top - Y;
      DestY := SD.ClipRect.Top;
      Dec(H, SrcY);
    end
    else
      SrcY := 0;
    if Bottom > SD.ClipRect.Bottom then Dec(H, Bottom - SD.ClipRect.Bottom);
    if H > 0 then
      if not FDataLoaded then
      begin
        LoadDiscardableImageData;
        Src := Pointer(Integer(FBits) + SrcX + SrcY * FPitch);
        DestX := DestX + Integer(SD.Data) + SD.Pitch * DestY;
        if SD.PixelFormatID = pfPAL8 then
          BltRect(Src, Pointer(DestX), FPitch, SD.Pitch, W, H)
        else
        begin
          if (SD.PixelFormatID <> FRemapPalette.PixelFormatID) and
            (RemapToPixelFormat(SD.PixelFormatID) <> GFXE_OK) then
            raise Exception.Create('Surface pixel format not supported!');
          case SD.PixelFormatID of
            pfRGB565:
              RemapSurface08to565(Src, Pointer(DestX), FPitch, SD.Pitch, W, H, FRemapPalette);
            pfRGB555:
              RemapSurface08to555(Src, Pointer(DestX), FPitch, SD.Pitch, W, H, FRemapPalette);
          end;
        end;
        if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
      end
      else
      begin
        Src := Pointer(Integer(FBits) + SrcX + SrcY * FPitch);
        DestX := DestX + Integer(SD.Data) + SD.Pitch * DestY;
        if SD.PixelFormatID = pfPAL8 then
          BltRect(Src, Pointer(DestX), FPitch, SD.Pitch, W, H)
        else
        begin
          if (SD.PixelFormatID <> FRemapPalette.PixelFormatID) and
            (RemapToPixelFormat(SD.PixelFormatID) <> GFXE_OK) then
            raise Exception.Create('Surface pixel format not supported!');
          case SD.PixelFormatID of
            pfRGB565:
              RemapSurface08to565(Src, Pointer(DestX), FPitch, SD.Pitch, W, H, FRemapPalette);
            pfRGB555:
              RemapSurface08to555(Src, Pointer(DestX), FPitch, SD.Pitch, W, H, FRemapPalette);
          end;
        end;
      end;
  end;
end;

{ TRLESprite08 }

class function TRLESprite08.ClassID: Integer;
begin
  Result := 2;
end;

class function TRLESprite08.Name: string;
begin
  Result := 'RLE Sprite (08bpp)';
end;

procedure TRLESprite08.ReleaseDiscardableImageData;
begin
  if FDataLoaded then
  begin
    ReallocMem(FData, 0);
    FDataLoaded := False;
  end;
end;

procedure TRLESprite08.SetXshift(Value: Integer);
begin
  if Value < -FRLELeft then Value := -FRLELeft;
  inherited SetXshift(Value);
  SetWidth(FWidth);
end;

procedure TRLESprite08.SetYshift(Value: Integer);
begin
  if Value < -FRLETop then Value := -FRLETop;
  inherited SetYshift(Value);
  SetHeight(FHeight);
end;

procedure TRLESprite08.SetWidth(Value: Integer);
var
  W: Integer;
begin
  W := FXshift + FRLELeft + FRLEWidth;
  if Value < W then Value := W;
  inherited SetWidth(Value);
end;

procedure TRLESprite08.SetHeight(Value: Integer);
var
  H: Integer;
begin
  H := FYshift + FRLETop + FRLEHeight;
  if Value < H then Value := H;
  inherited SetHeight(Value);
end;

procedure TRLESprite08.GetVisualDimensions(var R: TRect);
begin
  R.Left := FXshift + FRLELeft;
  R.Right := R.Left + FRLEWidth;
  R.Top := FYshift + FRLETop;
  R.Bottom := R.Top + FRLEHeight;
end;

procedure TRLESprite08.ReadImageData(Stream: TStream);
begin
  inherited ReadImageData(Stream);
  Stream.Read(FRLEWidth, 4);
  Stream.Read(FRLEHeight, 4);
  Stream.Read(FRLELeft, 4);
  Stream.Read(FRLETop, 4);
  Stream.Read(FTransparentColor, 4);
  Stream.Read(FReserved, 4);
end;

procedure TRLESprite08.WriteImageData(Stream: TStream);
begin
  inherited WriteImageData(Stream);
  Stream.Write(FRLEWidth, 4);
  Stream.Write(FRLEHeight, 4);
  Stream.Write(FRLELeft, 4);
  Stream.Write(FRLETop, 4);
  Stream.Write(FTransparentColor, 4);
  Stream.Write(FReserved, 4);
end;

procedure TRLESprite08.ReadDiscardableImageData(Stream: TStream);
begin
  inherited ReadDiscardableImageData(Stream);
  ReallocMem(FData, FDataSize);
  Stream.Read(FData^, FDataSize);
end;

procedure TRLESprite08.WriteDiscardableImageData(Stream: TStream);
begin
  inherited WriteDiscardableImageData(Stream);
  Stream.Write(FData^, FDataSize);
end;

function TRLESprite08.SupportShowMode(ShowMode: TShowMode; PixelFormatID: Integer): Boolean;
begin
  Result := ((PixelFormatID = 0) or (PixelFormatID = pfRGB555) or (PixelFormatID = pfRGB565)) and
    (ShowMode = smOpaque);
end;

procedure TRLESprite08.ShowOpaque(X, Y: Integer; const SD: TSurfaceDesc);
begin
  if not FDataLoaded then
  begin
    LoadDiscardableImageData;
    if SD.PixelFormatID = pfPAL8 then
      ShowRLE08(X + FXshift + FRLELeft, Y + FYshift + FRLETop, SD, FData, FRLEWidth, FRLEHeight,
        FTransparentColor)
    else
    begin
      if (SD.PixelFormatID <> FRemapPalette.PixelFormatID) and
        (RemapToPixelFormat(SD.PixelFormatID) <> GFXE_OK) then
        raise Exception.Create('Surface pixel format not supported!');
      case SD.PixelFormatID of
        pfRGB555, pfRGB565:
          ShowRLE08to16(X + FXshift + FRLELeft, Y + FYshift + FRLETop, SD, FData, FRLEWidth,
            FRLEHeight, FTransparentColor, @FRemapPalette.Entries);
      else
        raise Exception.Create('PixelFormat not supported');
      end;
    end;
    if FLoadMode = lmLoadFreeOnDemand then ReleaseDiscardableImageData;
  end
  else if SD.PixelFormatID = pfPAL8 then
    ShowRLE08(X + FXshift + FRLELeft, Y + FYshift + FRLETop, SD, FData, FRLEWidth, FRLEHeight,
      FTransparentColor)
  else
  begin
    if (SD.PixelFormatID <> FRemapPalette.PixelFormatID) and
      (RemapToPixelFormat(SD.PixelFormatID) <> GFXE_OK) then
      raise Exception.Create('Surface pixel format not supported!');
    case SD.PixelFormatID of
      pfRGB555, pfRGB565:
        ShowRLE08to16(X + FXshift + FRLELeft, Y + FYshift + FRLETop, SD, FData, FRLEWidth,
          FRLEHeight, FTransparentColor, @FRemapPalette.Entries);
    else
      raise Exception.Create('PixelFormat not supported');
    end;
  end;
end;

function TRLESprite08.SupportGrabPixelFormat(PixelFormatID: Integer): Boolean;
begin
  Result := PixelFormatID = pfPAL8;
end;

function TRLESprite08.CreateGrabForm(AOwner: TComponent; const SD: TSurfaceDesc;
  OnImagesGrabbed: TImagesGrabbedEvent): TForm;
begin
  Result := nil;
end;

{ GrabImage encodes the rows of the smallest rectangle holding the opaque pixels: per row a
  length dword (only its low word is written), the opaque pixels, and the runs of transparent
  pixels as the transparent index and the run length (up to 254). The buffer grows by 4 KB
  whenever the position reaches FDataSize, which stays 0 until the end (an original slip: every
  byte reallocates). Temp is never created. }
function TRLESprite08.GrabImage(const SD: TSurfaceDesc; const R: TRect;
  GrabInfo: TGrabInfo): Boolean;
var
  Pos, LineStart, Count: Integer;

  procedure AddByte(B: Byte);
  var
    P: PByte;
  begin
    if FDataSize <= Pos then ReallocMem(FData, Pos + $1000);
    P := PByte(Integer(FData) + Pos);
    P^ := B;
    Inc(Pos);
  end;

  procedure StartLine;
  begin
    LineStart := Pos;
    AddByte(0);
    AddByte(0);
    AddByte(0);
    AddByte(0);
  end;

  procedure FlushTransparent;
  begin
    while Count <> 0 do
    begin
      AddByte(FTransparentColor);
      if Count > 254 then
      begin
        Dec(Count, 254);
        AddByte(254);
      end
      else
      begin
        AddByte(Count);
        Count := 0;
      end;
    end;
  end;

  procedure EndLine;
  begin
    FlushTransparent;
    if FDataSize <= Pos then ReallocMem(FData, Pos + $1000);
    PWord(Integer(FData) + LineStart)^ := Pos - LineStart;
  end;

var
  Temp: TObject;
  Line: Integer;
  MinRect: TRect;
  X, Y, B, Left, Top, Bottom: Integer;
begin
  if SD.BitCount = 8 then
  begin
    Result := True;
    try
      Temp := nil;
      try
        FTransparentColor := GrabInfo.TransparentPixel;
        Clear;
        FDataLoaded := True;
        FDataWidth := R.Right - R.Left;
        FDataHeight := R.Bottom - R.Top;
        FWidth := FDataWidth;
        FHeight := FDataHeight;
        FFileName := ExtractFileName(GrabInfo.FileName);
        FFileIndex := GrabInfo.FileIndex;
        Pos := 0;
        Count := 0;
        MinimizeTransparentRect(SD, R, FTransparentColor, MinRect);
        Left := MinRect.Left;
        FRLELeft := Left - R.Left;
        Top := MinRect.Top;
        FRLETop := Top - R.Top;
        FRLEWidth := MinRect.Right - Left;
        Bottom := MinRect.Bottom;
        FRLEHeight := Bottom - Top;
        for Y := Top to Bottom - 1 do
        begin
          Line := Integer(SD.Data) + SD.Pitch * Y;
          StartLine;
          for X := MinRect.Left to MinRect.Right - 1 do
          begin
            B := PByte(Line + X)^;
            if B <> FTransparentColor then
            begin
              FlushTransparent;
              AddByte(B);
            end
            else
              Inc(Count);
          end;
          EndLine;
        end;
        ReallocMem(FData, Pos);
        FDataSize := Pos;
        CreateLibraryImagePalette(SD.Palette);
      finally
        if Temp <> nil then Temp.Destroy;
      end;
    except
      ReleaseDiscardableImageData;
      Result := False;
    end;
  end
  else
    Result := False;
end;

procedure ShowRLE08(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer; Width, Height: Integer;
  ColorKey: Byte);
var
  L1, L2, L3: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     edi, SD
        mov     eax, dword ptr [edi+$0C]
        mov     edx, Y
        mov     L1, eax
        mov     edi, dword ptr [edi+$20]
        mul     edx
        add     edi, eax
        add     edi, X
        mov     L2, edi
        mov     ebx, Width
        mov     edx, Height
        test    ebx, ebx
        je      @@L4
        test    edx, edx
        je      @@L4
        mov     L3, ebx
        mov     esi, Data
        xor     ebx, ebx
        mov     ah, byte ptr ColorKey
@@L0:
        mov     ecx, edi
        add     esi, 4
        mov     L2, edi
        add     ecx, L3
@@L1:
        cmp     edi, ecx
        je      @@L3
        mov     al, byte ptr [esi]
        cmp     al, ah
        je      @@L2
        mov     byte ptr [edi], al
        inc     edi
        inc     esi
        jmp     @@L1
@@L2:
        mov     bl, byte ptr [esi+1]
        add     esi, 2
        add     edi, ebx
        jmp     @@L1
@@L3:
        mov     edi, L2
        dec     edx
        je      @@L4
        add     edi, L1
        jmp     @@L0
@@L4:
        pop     esi
        pop     edi
        pop     ebx
end;

procedure ShowRLE08to16(X, Y: Integer; const SD: TSurfaceDesc; Data: Pointer;
  Width, Height: Integer; ColorKey: Byte; Palette: Pointer);
var
  L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11: Integer;
asm
        push    ebx
        push    edi
        push    esi
        mov     esi, Data
        mov     edi, SD
        mov     L1, esp
        mov     eax, X
        mov     ebx, Y
        mov     ecx, Width
        mov     edx, Height
        test    ecx, ecx
        je      @@L25
        test    edx, edx
        je      @@L25
        add     ecx, eax
        add     edx, ebx
        mov     L2, ecx
        mov     L3, edx
        cmp     ecx, dword ptr [edi+$10]
        js      @@L25
        cmp     edx, dword ptr [edi+$14]
        js      @@L25
        cmp     eax, dword ptr [edi+$18]
        jge     @@L25
        cmp     ebx, dword ptr [edi+$1C]
        jge     @@L25
        mov     ecx, Y
        mov     ebx, Height
        mov     eax, dword ptr [edi+$14]
        sub     edx, dword ptr [edi+$1C]
        jle     @@L0
        sub     ebx, edx
@@L0:
        sub     eax, ecx
        jle     @@L2
        xor     edx, edx
        add     ecx, eax
        sub     ebx, eax
        je      @@L25
@@L1:
        mov     dx, word ptr [esi]
        lea     esi, [esi+edx]
        dec     eax
        jne     @@L1
@@L2:
        mov     Height, ebx
        mov     Y, ecx
        mov     eax, X
        mov     ecx, L2
        cmp     eax, dword ptr [edi+$10]
        js      @@L16
        cmp     ecx, dword ptr [edi+$18]
        jg      @@L16
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mov     edi, dword ptr [edi+$20]
        mul     ecx
        lea     edi, [edi+ebx*2]
        mov     L4, ecx
        lea     edi, [edi+eax]
        mov     ebx, Width
        xor     edx, edx
        shl     ebx, 1
        xor     ecx, ecx
        mov     L5, ebx
        xor     ebx, ebx
        mov     esp, Palette
@@L3:
        mov     ecx, dword ptr [esi]
        add     esi, 4
        lea     ecx, [ecx-4]
        mov     L6, edi
@@L4:
        test    esi, 3
        jne     @@L12
@@L5:
        cmp     ecx, 4
        jb      @@L12
        mov     eax, dword ptr [esi]
        lea     ecx, [ecx-4]
        mov     dl, al
        mov     bl, ah
        cmp     al, byte ptr ColorKey
        je      @@L8
        shr     eax, $10
        mov     edx, dword ptr [esp+edx*4]
        cmp     bl, byte ptr ColorKey
        je      @@L9
        mov     word ptr [edi], dx
        mov     ebx, dword ptr [esp+ebx*4]
        xor     edx, edx
        mov     word ptr [edi+2], bx
@@L6:
        mov     dl, ah
        and     eax, $0FF
        xor     ebx, ebx
        lea     edi, [edi+8]
        cmp     al, byte ptr ColorKey
        je      @@L10
        mov     eax, dword ptr [esp+eax*4]
        lea     esi, [esi+4]
        mov     word ptr [edi-4], ax
@@L7:
        cmp     dl, byte ptr ColorKey
        je      @@L11
        mov     eax, dword ptr [esp+edx*4]
        xor     edx, edx
        mov     word ptr [edi-2], ax
        jmp     @@L5
@@L8:
        shr     eax, $10
        xor     edx, edx
        lea     edi, [edi+ebx*2-4]
        jmp     @@L6
@@L9:
        mov     bl, al
        mov     word ptr [edi], dx
        xor     edx, edx
        lea     esi, [esi+4]
        lea     edi, [edi+ebx*2+4]
        mov     dl, ah
        jmp     @@L7
@@L10:
        lea     esi, [esi+4]
        lea     edi, [edi+edx*2-4]
        xor     edx, edx
        jmp     @@L5
@@L11:
        mov     al, byte ptr [esi]
        and     eax, $0FF
        inc     esi
        dec     ecx
        xor     edx, edx
        lea     edi, [edi+eax*2-2]
@@L12:
        test    ecx, ecx
        je      @@L15
        mov     dl, byte ptr [esi]
@@L13:
        cmp     dl, byte ptr ColorKey
        je      @@L14
        mov     eax, dword ptr [esp+edx*4]
        inc     esi
        dec     ecx
        mov     word ptr [edi], ax
        add     edi, 2
        jmp     @@L4
@@L14:
        mov     dl, byte ptr [esi+1]
        add     esi, 2
        lea     ecx, [ecx-2]
        test    ecx, ecx
        lea     edi, [edi+edx*2]
        je      @@L15
        mov     dl, byte ptr [esi]
        jmp     @@L13
@@L15:
        mov     edi, L6
        dec     Height
        je      @@L25
        add     edi, L4
        jmp     @@L3
@@L16:
        mov     edx, dword ptr [edi+$10]
        mov     eax, X
        sub     edx, eax
        lea     edx, [edx*2]
        jns     @@L17
        xor     edx, edx
@@L17:
        mov     L7, edx
        mov     ecx, L2
        mov     eax, dword ptr [edi+$18]
        sub     ecx, eax
        lea     ecx, [ecx*2]
        jns     @@L18
        xor     ecx, ecx
@@L18:
        mov     L8, ecx
        mov     eax, Width
        lea     eax, [eax*2]
        sub     eax, edx
        sub     eax, ecx
        mov     L9, eax
        mov     eax, Y
        mov     ecx, dword ptr [edi+$0C]
        mov     ebx, X
        mov     edi, dword ptr [edi+$20]
        mul     ecx
        lea     edi, [edi+ebx*2]
        mov     L4, ecx
        lea     edi, [edi+eax]
        mov     esp, Palette
        xor     eax, eax
        mov     L10, edi
        mov     dl, byte ptr ColorKey
        mov     ecx, edi
        mov     ebx, dword ptr [esi]
        add     ecx, L7
        lea     ebx, [ebx+esi]
        lea     esi, [esi+4]
        mov     L11, ebx
@@L19:
        cmp     edi, ecx
        jae     @@L21
        mov     al, byte ptr [esi]
        cmp     al, dl
        je      @@L20
        lea     edi, [edi+2]
        inc     esi
        jmp     @@L19
@@L20:
        mov     al, byte ptr [esi+1]
        lea     esi, [esi+2]
        lea     edi, [edi+eax*2]
        jmp     @@L19
@@L21:
        add     ecx, L9
@@L22:
        cmp     edi, ecx
        jae     @@L24
        mov     al, byte ptr [esi]
        cmp     al, dl
        je      @@L23
        mov     ebx, dword ptr [esp+eax*4]
        inc     esi
        mov     word ptr [edi], bx
        add     edi, 2
        jmp     @@L22
@@L23:
        mov     al, byte ptr [esi+1]
        add     esi, 2
        lea     edi, [edi+eax*2]
        jmp     @@L22
@@L24:
        mov     esi, L11
        mov     edi, L10
        dec     Height
        je      @@L25
        mov     ebx, dword ptr [esi]
        add     edi, L4
        lea     ebx, [ebx+esi]
        lea     esi, [esi+4]
        mov     ecx, edi
        mov     L10, edi
        mov     L11, ebx
        add     ecx, L7
        jmp     @@L19
@@L25:
        mov     esp, L1
        pop     esi
        pop     edi
        pop     ebx
end;

{ TILManagerList }

constructor TILManagerList.Create(AOwner: TImageLibraryManager);
begin
  inherited Create;
  FOwner := AOwner;
  FHashTable := TStringHashTable256.Create;
end;

{ Original bug: the inherited destructor does not call Clear, so the TILManagerObjects and
  their libraries are never freed. }
destructor TILManagerList.Destroy;
begin
  inherited Destroy;
  FHashTable.Free;
end;

function TILManagerList.GetIL(Index: Integer): TCustomImageLibrary;
begin
  Result := TILManagerObject(Objects[Index]).FImageLibrary;
end;

procedure TILManagerList.UnloadIL;
var
  I: Integer;
  Obj: TILManagerObject;
begin
  for I := Count - 1 downto 0 do
  begin
    Obj := TILManagerObject(Objects[I]);
    if (Obj <> nil) and (Obj.FImageLibrary <> nil) then
      Obj.FImageLibrary.ReleaseDiscardableImageData;
  end;
end;

function TILManagerList.AddILFile(FileName: string): TILManagerObject;
var
  Obj: TILManagerObject;
begin
  Obj := TILManagerObject.Create;
  FileName := UpperCase(FileName);
  AddObject(FileName, Obj);
  FHashTable.Add(Obj, FileName);
  Result := Obj;
end;

{ Original bug: the object is deleted from the hash table instead of added, so LinkToIL never
  finds the owned libraries. }
function TILManagerList.AddILManagerObject(const Name: string;
  ImageLibrary: TCustomImageLibrary): TILManagerObject;
var
  S: string;
  Obj: TILManagerObject;
begin
  S := UpperCase(Name);
  Obj := TILManagerObject.Create;
  Obj.FImageLibrary := ImageLibrary;
  AddObject(S, Obj);
  FHashTable.Delete(S);
  Result := Obj;
end;

procedure TILManagerList.Delete(Index: Integer);
var
  Obj: TILManagerObject;
begin
  Obj := TILManagerObject(Objects[Index]);
  if Obj <> nil then
  begin
    Obj.FImageLibrary.Free;
    Obj.Free;
  end;
  FHashTable.Delete(Strings[Index]);
  inherited Delete(Index);
end;

procedure TILManagerList.Clear;
var
  I: Integer;
  Obj: TILManagerObject;
begin
  FHashTable.Clear;
  for I := Count - 1 downto 0 do
  begin
    Obj := TILManagerObject(Objects[I]);
    if Obj <> nil then
    begin
      Obj.FImageLibrary.Free;
      Obj.Free;
    end;
  end;
  inherited Clear;
end;

{ Links to the library of FileName (relative to the search path), loading it on the first link.
  The original clears FileName at the end (a second @LStrClr of the parameter). }
function TILManagerList.LinkToIL(FileName: string): TCustomImageLibrary;
var
  Obj: TILManagerObject;
begin
  FileName := UpperCase(FileName);
  Obj := FHashTable.Find(FileName);
  if Obj <> nil then
  begin
    Inc(Obj.FRefCount);
    if Obj.FImageLibrary = nil then
    begin
      Obj.FImageLibrary := TImageLibrary.Create(nil);
      Obj.FImageLibrary.LoadOnDemand := True;
      try
        Obj.FImageLibrary.LoadFromFile(FOwner.FSearchPath + FileName);
      except
        raise Exception.Create('Error loading: ' + FOwner.FSearchPath + FileName);
      end;
    end;
    Result := Obj.FImageLibrary;
  end
  else
    Result := nil;
  FileName := '';
end;

function TILManagerList.ReleaseIL(FileName: string): Boolean;
var
  Obj: TILManagerObject;
begin
  FileName := UpperCase(FileName);
  Obj := FHashTable.Find(FileName);
  if Obj <> nil then
  begin
    Dec(Obj.FRefCount);
    if Obj.FRefCount = 0 then Obj.FImageLibrary.ReleaseDiscardableImageData;
    Result := True;
  end
  else
    Result := False;
end;

procedure TILManagerList.LoadFromStream(Stream: TStream);
var
  I, N: Integer;
  Name: string;
  IL: TCustomImageLibrary;
begin
  Stream.Read(N, 4);
  for I := 0 to N - 1 do
  begin
    ReadStringFromStream(Name, Stream);
    IL := TImageLibrary.Create(nil);
    IL.LoadFromStream(Stream);
    AddILManagerObject(Name, IL);
  end;
end;

procedure TILManagerList.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  I := Count;
  Stream.Write(I, 4);
  for I := 0 to Count - 1 do
  begin
    WriteStringToStream(Strings[I], Stream);
    TILManagerObject(Objects[I]).FImageLibrary.SaveToStream(Stream);
  end;
end;

{ TImageLibraryManager }

constructor TImageLibraryManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDiskList := TILManagerList.Create(Self);
  FOwnedList := TILManagerList.Create(Self);
end;

destructor TImageLibraryManager.Destroy;
begin
  Clear;
  FDiskList.Free;
  FOwnedList.Free;
  inherited Destroy;
end;

procedure TImageLibraryManager.Clear;
begin
  FDiskList.Clear;
  FOwnedList.Clear;
end;

procedure TImageLibraryManager.UnloadIL(Category: TILManagerCategory);
begin
  if icDisk in Category then FDiskList.UnloadIL;
  if icOwned in Category then FOwnedList.UnloadIL;
end;

{ Lists the .ILB files of the search path and of its subdirectories in FDiskList }
procedure TImageLibraryManager.ExecutePathSearch(Path: string);

  procedure SearchDirectory(SubDirectory: string);
  var
    List: TStringList;
    SR: TSearchRec;
    Found: Boolean;
    I: Integer;
  begin
    Found := FindFirst(FSearchPath + SubDirectory + '*.ilb', faAnyFile - faDirectory, SR) = 0;
    while Found do
    begin
      FDiskList.AddILFile(SubDirectory + UpperCase(SR.Name));
      Found := FindNext(SR) = 0;
    end;
    FindClose(SR);
    List := TStringList.Create;
    Found := FindFirst(SubDirectory + '*.*', faDirectory, SR) = 0;
    while Found do
    begin
      if (SR.Attr and faDirectory <> 0) and (SR.Name <> '.') and (SR.Name <> '..') then
        List.Add(SubDirectory + UpperCase(SR.Name) + '\');
      Found := FindNext(SR) = 0;
    end;
    FindClose(SR);
    for I := 0 to List.Count - 1 do SearchDirectory(List[I]);
    List.Free;
  end;

var
  Dir: string;
begin
  FDiskList.Clear;
  FSearchPath := UpperCase(Path);
  if FSearchPath[Length(FSearchPath)] <> '\' then FSearchPath := FSearchPath + '\';
  Dir := GetCurrentDir;
  SetCurrentDir(Path);
  SearchDirectory('');
  SetCurrentDir(Dir);
end;

{ A missing owned library is created empty and added. The exception for a missing library is
  raised and swallowed at once (it only shows in the debugger), as in the original. }
function TImageLibraryManager.LinkToIL(Category: TILManagerCategory;
  FileName: string): TCustomImageLibrary;
begin
  Result := nil;
  if icDisk in Category then Result := FDiskList.LinkToIL(FileName);
  if (icOwned in Category) and (Result = nil) then
  begin
    Result := FOwnedList.LinkToIL(FileName);
    if Result = nil then
    begin
      Result := TImageLibrary.Create(nil);
      FOwnedList.AddILManagerObject(FileName, Result);
    end;
  end;
  if Result = nil then
    try
      raise Exception.Create('Missing IL Resource: ' + FileName);
    except
    end;
end;

procedure TImageLibraryManager.ReleaseIL(Category: TILManagerCategory; FileName: string);
var
  Released: Boolean;
begin
  Released := False;
  if icDisk in Category then Released := FDiskList.ReleaseIL(FileName);
  if (icOwned in Category) and not Released then FOwnedList.ReleaseIL(FileName);
end;

procedure TImageLibraryManager.SaveToStream(Stream: TStream);
begin
  FOwnedList.SaveToStream(Stream);
end;

procedure TImageLibraryManager.LoadFromStream(Stream: TStream);
begin
  FOwnedList.LoadFromStream(Stream);
end;

{ TILManagerComboBox }

procedure TILManagerComboBox.SetILManager(Value: TImageLibraryManager);
begin
  FILManager := Value;
  GenerateItems;
end;

procedure TILManagerComboBox.SetSubDirectory(Value: string);
begin
  FSubDirectory := UpperCase(Value);
  if (Value <> '') and (FSubDirectory[Length(FSubDirectory)] <> '\') then
    FSubDirectory := FSubDirectory + '\';
end;

constructor TILManagerComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := csDropDownList;
  FCategory := [icDisk];
end;

function TILManagerComboBox.GetImageLibraryName: string;
begin
  if (ItemIndex = 0) and (FEmptyILName <> '') and (Text = FEmptyILName) then
    Result := ''
  else
    Result := FSubDirectory + UpperCase(Text);
end;

procedure TILManagerComboBox.SetImageLibraryName(Value: string);
var
  L, I: Integer;
begin
  Value := UpperCase(Value);
  L := Length(FSubDirectory);
  if StrLComp(PChar(FSubDirectory), PChar(Value), L) = 0 then
    Value := System.Copy(Value, L + 1, Length(Value) - L);
  if Value = '' then Value := FEmptyILName;
  I := Items.IndexOf(Value);
  if I <> -1 then ItemIndex := I;
end;

procedure TILManagerComboBox.GenerateItems;
var
  List: TStringList;
  I: Integer;
  SubDirectory, Skip, Skips: string;
  SubLength, SkipLength: Integer;
begin
  List := TStringList.Create;
  if FEmptyILName <> '' then List.Add(FEmptyILName);
  if FILManager <> nil then
  begin
    if icDisk in FCategory then List.AddStrings(FILManager.FDiskList);
    if icOwned in FCategory then List.AddStrings(FILManager.FOwnedList);
  end;
  SubDirectory := UpperCase(FSubDirectory);
  if SubDirectory <> '' then
  begin
    SubLength := Length(SubDirectory);
    for I := List.Count - 1 downto 0 do
      if StrLComp(PChar(SubDirectory), PChar(List[I]), SubLength) = 0 then
        List[I] := System.Copy(List[I], SubLength + 1, Length(List[I]) - SubLength)
      else
        List.Delete(I);
  end;
  Skips := UpperCase(FSkipDirectories);
  while Skips <> '' do
  begin
    if Pos(';', Skips) > 0 then
    begin
      Skip := System.Copy(Skips, 1, Pos(';', Skips) - 1);
      Skips := System.Copy(Skips, Length(Skip) + 2, Length(Skips) - Length(Skip));
    end
    else
    begin
      Skip := Skips;
      Skips := '';
    end;
    Skip := UpperCase(Skip);
    if Skip[Length(Skip)] <> '\' then Skip := Skip + '\';
    SkipLength := Length(Skip);
    for I := List.Count - 1 downto 0 do
      if StrLComp(PChar(Skip), PChar(List[I]), SkipLength) = 0 then List.Delete(I);
  end;
  Items := List;
  List.Free;
end;

{ TILManagerListBox }

procedure TILManagerListBox.SetILManager(Value: TImageLibraryManager);
begin
  FILManager := Value;
  GenerateItems;
end;

procedure TILManagerListBox.SetSubDirectory(Value: string);
begin
  FSubDirectory := UpperCase(Value);
  if (Value <> '') and (FSubDirectory[Length(FSubDirectory)] <> '\') then
    FSubDirectory := FSubDirectory + '\';
end;

constructor TILManagerListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Sorted := True;
  FCategory := [icDisk];
end;

function TILManagerListBox.GetImageLibraryName: string;
begin
  if (ItemIndex = 0) and (FEmptyILName <> '') and (Items[ItemIndex] = FEmptyILName) then
    Result := ''
  else
    Result := FSubDirectory + Items[ItemIndex];
end;

procedure TILManagerListBox.SetImageLibraryName(Value: string);
var
  L, I: Integer;
begin
  Value := UpperCase(Value);
  L := Length(FSubDirectory);
  if StrLComp(PChar(FSubDirectory), PChar(Value), L) = 0 then
    Value := System.Copy(Value, L + 1, Length(Value) - L);
  if Value = '' then Value := FEmptyILName;
  I := Items.IndexOf(Value);
  if I <> -1 then ItemIndex := I;
end;

procedure TILManagerListBox.GenerateItems;
var
  List: TStringList;
  I: Integer;
  SubDirectory, Skip, Skips: string;
  SubLength, SkipLength: Integer;
begin
  List := TStringList.Create;
  if FEmptyILName <> '' then List.Add(FEmptyILName);
  if FILManager <> nil then
  begin
    if icDisk in FCategory then List.AddStrings(FILManager.FDiskList);
    if icOwned in FCategory then List.AddStrings(FILManager.FOwnedList);
  end;
  SubDirectory := UpperCase(FSubDirectory);
  if SubDirectory <> '' then
  begin
    SubLength := Length(SubDirectory);
    for I := List.Count - 1 downto 0 do
      if StrLComp(PChar(SubDirectory), PChar(List[I]), SubLength) = 0 then
        List[I] := System.Copy(List[I], SubLength + 1, Length(List[I]) - SubLength)
      else
        List.Delete(I);
  end;
  Skips := UpperCase(FSkipDirectories);
  while Skips <> '' do
  begin
    if Pos(';', Skips) > 0 then
    begin
      Skip := System.Copy(Skips, 1, Pos(';', Skips) - 1);
      Skips := System.Copy(Skips, Length(Skip) + 2, Length(Skips) - Length(Skip));
    end
    else
    begin
      Skip := Skips;
      Skips := '';
    end;
    Skip := UpperCase(Skip);
    if Skip[Length(Skip)] <> '\' then Skip := Skip + '\';
    SkipLength := Length(Skip);
    for I := List.Count - 1 downto 0 do
      if StrLComp(PChar(Skip), PChar(List[I]), SkipLength) = 0 then List.Delete(I);
  end;
  Items := List;
  List.Free;
end;

{ TImageSequence }

constructor TImageSequence.Create(AOwner: TImageSequenceList);
begin
  FOwner := AOwner;
  inherited Create;
end;

destructor TImageSequence.Destroy;
begin
  FFrameTable.Free;
  ReleaseIL;
  if FNext <> nil then FNext.Destroy;
  inherited Destroy;
end;

function TImageSequence.Copy(AOwner: TImageSequenceList): TImageSequence;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Result := TImageSequence.Create(AOwner);
    SaveToStream(Stream);
    Stream.Position := 0;
    Result.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

function TImageSequence.GetPreviewImage: TLibraryImage;
var
  I: Integer;
begin
  if Self <> nil then
  begin
    Result := nil;
    if (FFrameTable <> nil) and (FFrameTable.FCount <> 0) then
      Result := FImageLibrary.GetSafe(FFrameTable.FList^[0]);
    if FSequenceMode = smNone then Result := FImageLibrary.GetSafe(FImageIndex);
    if Result = nil then
    begin
      I := 0;
      while (I <> FImageLibrary.Count) and (Result = nil) do
      begin
        Result := FImageLibrary[I];
        Inc(I);
      end;
    end;
  end
  else
    Result := nil;
end;

procedure TImageSequence.SetImageLibraryName(Value: string);
begin
  ReleaseIL;
  FImageLibraryName := Value;
  if FOwner.FLinked then LinkToIL;
end;

procedure TImageSequence.SetSequenceMode(Value: TSequenceMode);
begin
  if (Value in [smFrameTable, smRndFrameTable]) and (FFrameTable = nil) then
    FFrameTable := TFrameTableList.Create;
  FSequenceMode := Value;
end;

procedure TImageSequence.GetDimensions(var R: TRect);
var
  I: Integer;
  Image: TLibraryImage;
  IR: TRect;
begin
  R.Left := 0;
  R.Right := 0;
  R.Top := 0;
  R.Bottom := 0;
  if FImageLibrary <> nil then
  begin
    case FSequenceMode of
      smFrameTable, smRndFrameTable:
        for I := 0 to FFrameTable.Count - 1 do
        begin
          Image := FImageLibrary.GetSafe(FFrameTable[I]);
          if Image <> nil then
          begin
            Image.GetVisualDimensions(IR);
            UnionRect(R, R, IR);
          end;
        end;
      smUp, smUpDown, smRandom:
        for I := 0 to FImageLibrary.Count - 1 do
        begin
          Image := FImageLibrary.GetSafe(I);
          if Image <> nil then
          begin
            Image.GetVisualDimensions(IR);
            UnionRect(R, R, IR);
          end;
        end;
      smNone:
        begin
          Image := FImageLibrary.GetSafe(FImageIndex);
          if Image <> nil then Image.GetVisualDimensions(R);
        end;
    end;
    Inc(R.Left, FdXshift);
    Inc(R.Right, FdXshift);
    Inc(R.Top, FdYshift);
    Inc(R.Bottom, FdYshift);
  end;
end;

function TImageSequence.GetTotalSequenceFrames: Integer;
begin
  case FSequenceMode of
    smFrameTable: Result := FFrameTable.Count * (FSequenceSpeed + 1);
    smUp: Result := FImageLibrary.Count * (FSequenceSpeed + 1);
    smUpDown: Result := FImageLibrary.Count * (FSequenceSpeed + 1) * 2;
  else
    Result := FSequenceSpeed + 1;
  end;
end;

function TImageSequence.GetFrameIndex(Frame, Offset: Integer): Integer;
begin
  if Frame >= 0 then
  begin
  if FSequenceMode <> smNone then
    case FSequenceMode of
      smFrameTable:
        begin
          if Frame <> FLastFrame then
          begin
            if FSpeedCount = 0 then
            begin
              FFrameCounter := (FFrameCounter + 1) and $FFFFFF;
              FSpeedCount := FSequenceSpeed;
            end
            else
              Dec(FSpeedCount);
            FLastFrame := Frame;
          end;
          Result := FFrameCounter + Offset;
          if FFrameTable.Count <> 0 then
          begin
            Result := Result mod FFrameTable.Count;
            Result := FFrameTable.FList^[Result];
          end
          else
            Result := -1;
        end;
      smUp:
        begin
          if Frame <> FLastFrame then
          begin
            if FSpeedCount = 0 then
            begin
              FFrameCounter := (FFrameCounter + 1) and $FFFFFF;
              FSpeedCount := FSequenceSpeed;
            end
            else
              Dec(FSpeedCount);
            FLastFrame := Frame;
          end;
          Result := FFrameCounter + Offset;
          Result := Result mod FImageLibrary.Count;
        end;
      smUpDown:
        begin
          if Frame <> FLastFrame then
          begin
            if FSpeedCount = 0 then
            begin
              FFrameCounter := (FFrameCounter + 1) and $FFFFFF;
              FSpeedCount := FSequenceSpeed;
            end
            else
              Dec(FSpeedCount);
            FLastFrame := Frame;
          end;
          Result := (FFrameCounter + Offset) mod ((FImageLibrary.Count - 1) * 2);
          Result := Abs(Result - (FImageLibrary.Count - 2));
        end;
      smRndFrameTable:
        begin
          if (Frame <> FLastFrame) and (Frame mod (FSequenceSpeed + 1) = 0) then
          begin
            FImageIndex := Random(FFrameTable.Count);
            FLastFrame := Frame;
          end;
          if FFrameTable.Count <> 0 then
            Result := FFrameTable.FList^[(FImageIndex + Offset) mod FFrameTable.Count]
          else
            Result := -1;
        end;
      smRandom:
        begin
          if (Frame <> FLastFrame) and (Frame mod (FSequenceSpeed + 1) = 0) then
          begin
            FImageIndex := Random(FImageLibrary.Count);
            FLastFrame := Frame;
          end;
          Result := (FImageIndex + Offset) mod FImageLibrary.Count;
        end;
    else
      Result := -1;
    end
  else
    Result := FImageIndex;
  end
  else
    Result := -1;
end;

function TImageSequence.GetUnloopedFrameIndex(Frame: Integer): Integer;
begin
  if Frame >= 0 then
  begin
    if FSequenceMode <> smNone then
      case FSequenceMode of
      smFrameTable:
        begin
          Result := Frame div (FSequenceSpeed + 1);
          if Result < FFrameTable.Count then
            Result := FFrameTable.FList^[Result]
          else
            Result := -1;
        end;
      smUp:
        begin
          Result := Frame div (FSequenceSpeed + 1);
          if Result >= FImageLibrary.Count then Result := -1;
        end;
      smUpDown: Result := -1;
      smRndFrameTable: Result := -1;
      smRandom: Result := -1;
      else
        Result := -1;
      end
    else
    begin
      Result := FImageIndex;
      Exit;
    end;
  end
  else
    Result := -1;
end;

procedure TImageSequence.LinkToIL;
begin
  if FImageLibrary <> nil then ReleaseIL;
  if FImageLibraryName <> '' then
    FImageLibrary := FOwner.FILManager.LinkToIL([icDisk], FImageLibraryName)
  else
    FImageLibrary := FOwner.FImageLibrary;
end;

procedure TImageSequence.ReleaseIL;
begin
  if FImageLibrary <> nil then
  begin
    if FImageLibraryName <> '' then
      FOwner.FILManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
end;

procedure TImageSequence.SaveToStream(Stream: TStream);
var
  HasNext: Boolean;
begin
  WriteStringToStream(FImageLibraryName, Stream);
  Stream.Write(FLayer, 1);
  Stream.Write(FSequenceSpeed, 1);
  Stream.Write(FSequenceMode, 1);
  Stream.Write(FImageIndex, 4);
  Stream.Write(FdXshift, 4);
  Stream.Write(FdYshift, 4);
  if FSequenceMode in [smFrameTable, smRndFrameTable] then FFrameTable.SaveToStream(Stream);
  HasNext := FNext <> nil;
  Stream.Write(HasNext, 1);
  if HasNext then FNext.SaveToStream(Stream);
end;

procedure TImageSequence.LoadFromStream(Stream: TStream);
var
  HasNext: Boolean;
begin
  ReleaseIL;
  ReadStringFromStream(FImageLibraryName, Stream);
  Stream.Read(FLayer, 1);
  Stream.Read(FSequenceSpeed, 1);
  Stream.Read(FSequenceMode, 1);
  Stream.Read(FImageIndex, 4);
  Stream.Read(FdXshift, 4);
  Stream.Read(FdYshift, 4);
  if FSequenceMode in [smFrameTable, smRndFrameTable] then
  begin
    if FFrameTable = nil then FFrameTable := TFrameTableList.Create;
    FFrameTable.LoadFromStream(Stream);
    FImageIndex := Random(FFrameTable.Count);
  end;
  Stream.Read(HasNext, 1);
  if HasNext then
  begin
    FNext := TImageSequence.Create(FOwner);
    FNext.LoadFromStream(Stream);
  end;
end;

procedure TImageSequence.SaveToIniFile(const Section: string; IniFile: TIniFile);
begin
  IniFile.WriteString(Section, 'ImageLibraryName', FImageLibraryName);
  IniFile.WriteInteger(Section, 'Layer', FLayer);
  IniFile.WriteInteger(Section, 'SequenceSpeed', FSequenceSpeed);
  IniFile.WriteInteger(Section, 'SequenceMode', Ord(FSequenceMode));
  IniFile.WriteInteger(Section, 'ImageIndex', FImageIndex);
  IniFile.WriteInteger(Section, 'dXshift', FdXshift);
  IniFile.WriteInteger(Section, 'dYshift', FdYshift);
  if FSequenceMode in [smFrameTable, smRndFrameTable] then
    IniFile.WriteString(Section, 'FrameTable', FFrameTable.ItemString);
  IniFile.WriteBool(Section, 'Last', FNext = nil);
  if FNext <> nil then FNext.SaveToIniFile(Section + 'X', IniFile);
end;

procedure TImageSequence.LoadFromIniFile(const Section: string; IniFile: TIniFile);
begin
  FImageLibraryName := IniFile.ReadString(Section, 'ImageLibraryName', '');
  FLayer := IniFile.ReadInteger(Section, 'Layer', 0);
  FSequenceSpeed := IniFile.ReadInteger(Section, 'SequenceSpeed', 0);
  FSequenceMode := TSequenceMode(IniFile.ReadInteger(Section, 'SequenceMode', 0));
  FImageIndex := IniFile.ReadInteger(Section, 'ImageIndex', 0);
  FdXshift := IniFile.ReadInteger(Section, 'dXshift', 0);
  FdYshift := IniFile.ReadInteger(Section, 'dYshift', 0);
  if FSequenceMode in [smFrameTable, smRndFrameTable] then
  begin
    if FFrameTable = nil then FFrameTable := TFrameTableList.Create;
    FFrameTable.ItemString := IniFile.ReadString(Section, 'FrameTable', '');
  end;
  if not IniFile.ReadBool(Section, 'Last', False) then
  begin
    FNext := TImageSequence.Create(FOwner);
    FNext.LoadFromIniFile(Section + 'X', IniFile);
  end;
end;

{ TImageSequenceList }

constructor TImageSequenceList.Create(AILManager: TImageLibraryManager;
  AImageLibrary: TCustomImageLibrary);
begin
  FILManager := AILManager;
  FImageLibrary := AImageLibrary;
  inherited Create;
end;

destructor TImageSequenceList.Destroy;
begin
  DestroyItems;
  inherited Destroy;
end;

{ The indices with a sequence, separated by commas }
function TImageSequenceList.UsedIndexString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
    if List^[I] <> nil then Result := Result + IntToStr(I) + ',';
  if Result <> '' then Result := System.Copy(Result, 1, Length(Result) - 1);
end;

procedure TImageSequenceList.DestroyItems;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    if List^[I] <> nil then TImageSequence(List^[I]).Destroy;
    inherited Delete(I);
  end;
end;

function TImageSequenceList.GetLayerImageSequence(Index, Layer: Integer): TImageSequence;
begin
  if Index < Count then
    Result := List^[Index]
  else
    Result := nil;
  while (Result <> nil) and (Layer <> Result.FLayer) do Result := Result.FNext;
end;

{ Deletes the empty indices at the end; returns the last index with a sequence }
function TImageSequenceList.ReduceCount: Integer;
begin
  Result := Count - 1;
  while (Result >= 0) and (List^[Result] = nil) do
  begin
    inherited Delete(Result);
    Dec(Result);
  end;
end;

procedure TImageSequenceList.LoadFromStream(Stream: TStream);
var
  I, N: Integer;
  IsNil: Boolean;
  Sequence: TImageSequence;
begin
  DestroyItems;
  Stream.Read(N, 4);
  for I := 0 to N - 1 do
  begin
    Stream.Read(IsNil, 1);
    if not IsNil then
    begin
      Sequence := TImageSequence.Create(Self);
      Sequence.LoadFromStream(Stream);
      inherited Add(Sequence);
    end
    else
      inherited Add(nil);
  end;
  if FLinked then
  begin
    FLinked := False;
    LinkToIL;
  end;
end;

procedure TImageSequenceList.SaveToStream(Stream: TStream);
var
  I: Integer;
  IsNil: Boolean;
begin
  ReduceCount;
  Stream.Write(Count, 4);
  for I := 0 to Count - 1 do
  begin
    IsNil := List^[I] = nil;
    Stream.Write(IsNil, 1);
    if not IsNil then TImageSequence(List^[I]).SaveToStream(Stream);
  end;
end;

procedure TImageSequenceList.SaveToIniFile(const Section: string; IniFile: TIniFile);
var
  I: Integer;
  S: string;
begin
  ReduceCount;
  IniFile.WriteString(Section, 'Used Indices', UsedIndexString);
  for I := 0 to Count - 1 do
    if List^[I] <> nil then
    begin
      S := Section + '\' + IntToStr(I);
      TImageSequence(List^[I]).SaveToIniFile(S + '\X', IniFile);
    end;
end;

procedure TImageSequenceList.LoadFromIniFile(const Section: string; IniFile: TIniFile);
var
  Used, Item: string;
  Sequence: TImageSequence;
  Index, P: Integer;
begin
  DestroyItems;
  Used := IniFile.ReadString(Section, 'Used Indices', '');
  while Used <> '' do
  begin
    P := Pos(',', Used);
    if P <> 0 then
    begin
      Item := System.Copy(Used, 1, P - 1);
      System.Delete(Used, 1, P);
    end
    else
    begin
      Item := Used;
      Used := '';
    end;
    Index := StrToInt(Item);
    Sequence := TImageSequence.Create(Self);
    Sequence.LoadFromIniFile(Section + '\' + IntToStr(Index) + '\X', IniFile);
    Add(Index, Sequence);
  end;
end;

function TImageSequenceList.GetImageSequence(Index: Integer): TImageSequence;
begin
  if (Index >= 0) and (Index < Count) then
    Result := List^[Index]
  else
    Result := nil;
end;

procedure TImageSequenceList.SetImageSequence(Index: Integer; Value: TImageSequence);
begin
  while Index >= Count do inherited Add(nil);
  if List^[Index] <> nil then TImageSequence(List^[Index]).Destroy;
  List^[Index] := Value;
end;

function TImageSequenceList.GetSubCount(Index: Integer): Integer;
var
  Sequence: TImageSequence;
begin
  Result := 0;
  if Index < Count then
    Sequence := List^[Index]
  else
    Sequence := nil;
  while Sequence <> nil do
  begin
    Sequence := Sequence.FNext;
    Inc(Result);
  end;
end;

{ Original bug: a Sequence that is not in the chain runs past its end (nil dereference). }
function TImageSequenceList.IndexOfSub(Index: Integer; Sequence: TImageSequence): Integer;
var
  S: TImageSequence;
begin
  Result := 0;
  if Index < Count then
    S := List^[Index]
  else
    S := nil;
  while S <> Sequence do
  begin
    S := S.FNext;
    Inc(Result);
  end;
  if S = nil then Result := -1;
end;

function TImageSequenceList.GetSubImageSequence(Index, SubIndex: Integer): TImageSequence;
var
  I: Integer;
begin
  I := 0;
  if Index < Count then
    Result := List^[Index]
  else
    Result := nil;
  while (Result <> nil) and (I <> SubIndex) do
  begin
    Result := Result.FNext;
    Inc(I);
  end;
end;

{ Inserts Sequence into the chain of Index by its layer. Original bug: an existing layer is
  only detected after the first link, not at the head of the chain. }
procedure TImageSequenceList.Add(Index: Integer; Sequence: TImageSequence);
var
  S, Prev: TImageSequence;
begin
  if Index < Count then
    S := List^[Index]
  else
    S := nil;
  if S <> nil then
  begin
    Prev := nil;
    while (S <> nil) and (S.FLayer < Sequence.FLayer) do
    begin
      Prev := S;
      S := S.FNext;
    end;
    if Prev <> nil then
    begin
      if (S <> nil) and (Sequence.FLayer = S.FLayer) then
        raise Exception.Create('Layer does already exist');
      Prev.FNext := Sequence;
      Sequence.FNext := S;
    end
    else
    begin
      List^[Index] := Sequence;
      Sequence.FNext := S;
    end;
  end
  else
    SetImageSequence(Index, Sequence);
end;

{ Takes Sequence out of the chain of Index (it is not freed) }
procedure TImageSequenceList.Delete(Index: Integer; Sequence: TImageSequence);
var
  S, Prev: TImageSequence;
begin
  if Index < Count then
  begin
    Prev := nil;
    S := List^[Index];
    while (S <> nil) and (S <> Sequence) do
    begin
      Prev := S;
      S := S.FNext;
    end;
    if (S <> nil) and (S = Sequence) then
    begin
      if Prev <> nil then
        Prev.FNext := S.FNext
      else
        List^[Index] := S.FNext;
      S.FNext := nil;
    end;
  end;
end;

procedure TImageSequenceList.LinkToIL;
var
  I: Integer;
  Sequence: TImageSequence;
begin
  if not FLinked then
  begin
    FLinked := True;
    for I := 0 to Count - 1 do
    begin
      Sequence := List^[I];
      while Sequence <> nil do
      begin
        Sequence.LinkToIL;
        Sequence := Sequence.FNext;
      end;
    end;
  end;
end;

procedure TImageSequenceList.ReleaseIL;
var
  I: Integer;
  Sequence: TImageSequence;
begin
  if FLinked then
  begin
    FLinked := False;
    for I := 0 to Count - 1 do
    begin
      Sequence := List^[I];
      while Sequence <> nil do
      begin
        Sequence.ReleaseIL;
        Sequence := Sequence.FNext;
      end;
    end;
  end;
end;

function TImageSequenceList.Animating: Boolean;
var
  I: Integer;
  Sequence: TImageSequence;
begin
  Result := False;
  I := 0;
  while (I <> Count) and not Result do
  begin
    Sequence := List^[I];
    while (Sequence <> nil) and not Result do
    begin
      Result := Sequence.FSequenceMode <> smNone;
      Sequence := Sequence.FNext;
    end;
    Inc(I);
  end;
end;

function TImageSequenceList.GetPreviewImage: TLibraryImage;
var
  I: Integer;
  Sequence: TImageSequence;
begin
  Result := nil;
  I := 0;
  while (I <> Count) and (Result = nil) do
  begin
    Sequence := List^[I];
    while (Sequence <> nil) and (Result = nil) do
    begin
      Result := Sequence.GetPreviewImage;
      Sequence := Sequence.FNext;
    end;
    Inc(I);
  end;
end;

procedure TImageSequenceList.GetDimensions(Index: Integer; var R: TRect);
var
  Sequence: TImageSequence;
  SR: TRect;
begin
  R.Left := 0;
  R.Right := 0;
  R.Top := 0;
  R.Bottom := 0;
  if (Index < Count) and (Index >= 0) then
  begin
    Sequence := List^[Index];
    while Sequence <> nil do
    begin
      Sequence.GetDimensions(SR);
      UnionRect(R, R, SR);
      Sequence := Sequence.FNext;
    end;
  end;
end;

{ Shows the layers of Index for Frame without looping; returns False when no layer has an
  image for Frame }
function TImageSequenceList.Show(Index, X, Y, Frame: Integer; const SD: TSurfaceDesc): Boolean;
var
  Sequence: TImageSequence;
  I: Integer;
begin
  Result := False;
  if Index < Count then
  begin
    Sequence := List^[Index];
    while Sequence <> nil do
    begin
      I := Sequence.GetUnloopedFrameIndex(Frame);
      if I <> -1 then
      begin
        Result := True;
        if Sequence.FImageLibrary.ImageExist(I) then
          Sequence.FImageLibrary[I].Show(X + Sequence.FdXshift, Y + Sequence.FdYshift, SD);
      end;
      Sequence := Sequence.FNext;
    end;
  end;
end;

function TImageSequenceList.GetFramesCount(Index: Integer): Integer;
var
  Sequence: TImageSequence;
  N: Integer;
begin
  Result := 0;
  if Index < Count then
  begin
    Sequence := List^[Index];
    while Sequence <> nil do
    begin
      N := Sequence.GetTotalSequenceFrames;
      if N > Result then Result := N;
      Sequence := Sequence.FNext;
    end;
  end;
end;

procedure TImageSequenceList.ShowLooped(Index, X, Y, Frame: Integer; const SD: TSurfaceDesc);
var
  Sequence: TImageSequence;
  I: Integer;
begin
  if Index < Count then
  begin
    Sequence := List^[Index];
    while Sequence <> nil do
    begin
      I := Sequence.GetFrameIndex(Frame, 0);
      if I <> -1 then
        if Sequence.FImageLibrary.ImageExist(I) then
          Sequence.FImageLibrary[I].Show(X + Sequence.FdXshift, Y + Sequence.FdYshift, SD);
      Sequence := Sequence.FNext;
    end;
  end;
end;

procedure TImageSequenceList.ShowLoopedEx(Index, X, Y, Frame, Offset: Integer;
  const SD: TSurfaceDesc);
var
  Sequence: TImageSequence;
  I: Integer;
begin
  if Index < Count then
  begin
    Sequence := List^[Index];
    while Sequence <> nil do
    begin
      I := Sequence.GetFrameIndex(Frame, Offset);
      if I <> -1 then
        if Sequence.FImageLibrary.ImageExist(I) then
          Sequence.FImageLibrary[I].Show(X + Sequence.FdXshift, Y + Sequence.FdYshift, SD);
      Sequence := Sequence.FNext;
    end;
  end;
end;

procedure TImageSequenceList.CopyToClipboard;
begin
end;

procedure TImageSequenceList.PasteFromClipboard;
begin
end;

{ TFrameTableList }

destructor TFrameTableList.Destroy;
begin
  Clear;
end;

procedure TFrameTableList.Assign(Source: TPersistent);
begin
  if Source is TFrameTableList then
    with TFrameTableList(Source) do
    begin
      Self.SetCapacity(FCount);
      Self.FCount := FCount;
      System.Move(FList^, Self.FList^, Self.FCount * SizeOf(Integer));
      Self.FDefaultValue := FDefaultValue;
    end
  else
    inherited Assign(Source);
end;

function TFrameTableList.Add(Item: Integer): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TFrameTableList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TFrameTableList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index], (FCount - Index) * SizeOf(Integer));
end;

class procedure TFrameTableList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

procedure TFrameTableList.Exchange(Index1, Index2: Integer);
var
  Item: Integer;
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(SListIndexError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TFrameTableList.Expand: TFrameTableList;
begin
  if FCount = FCapacity then Grow;
  Result := Self;
end;

function TFrameTableList.First: Integer;
begin
  Result := Get(0);
end;

function TFrameTableList.Get(Index: Integer): Integer;
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Result := FList^[Index];
end;

procedure TFrameTableList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TFrameTableList.IndexOf(Item: Integer): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do Inc(Result);
  if Result = FCount then Result := -1;
end;

procedure TFrameTableList.Insert(Index: Integer; Item: Integer);
begin
  if (Index < 0) or (Index > FCount) then Error(SListIndexError, Index);
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1], (FCount - Index) * SizeOf(Integer));
  FList^[Index] := Item;
  Inc(FCount);
end;

function TFrameTableList.Last: Integer;
begin
  Result := Get(FCount - 1);
end;

procedure TFrameTableList.Move(CurIndex, NewIndex: Integer);
var
  Item: Integer;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then Error(SListIndexError, NewIndex);
    Item := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Item);
  end;
end;

{ Unlike TList.Put, an index past the end grows the list }
procedure TFrameTableList.Put(Index: Integer; Item: Integer);
begin
  if Index < 0 then Error(SListIndexError, Index);
  if Index >= FCount then SetCount(Index + 1);
  FList^[Index] := Item;
end;

function TFrameTableList.Remove(Item: Integer): Integer;
begin
  Result := IndexOf(Item);
  if Result <> -1 then Delete(Result);
end;

procedure TFrameTableList.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do if Items[I] = 0 then Delete(I);
end;

procedure TFrameTableList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Integer));
    FCapacity := NewCapacity;
  end;
end;

procedure TFrameTableList.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SListCountError, NewCount);
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Integer), FDefaultValue);
  FCount := NewCount;
end;

procedure FrameTableQuickSort(SortList: PFrameTable; L, R: Integer;
  SCompare: TFrameTableSortCompare);
var
  I, J: Integer;
  P, T: Integer;
begin
  repeat
    I := L;
    J := R;
    P := SortList^[(L + R) shr 1];
    repeat
      while SCompare(SortList^[I], P) < 0 do Inc(I);
      while SCompare(SortList^[J], P) > 0 do Dec(J);
      if I <= J then
      begin
        T := SortList^[I];
        SortList^[I] := SortList^[J];
        SortList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then FrameTableQuickSort(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TFrameTableList.Sort(Compare: TFrameTableSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    FrameTableQuickSort(FList, 0, Count - 1, Compare);
end;

function TFrameTableList.Compare(List: TFrameTableList): Boolean;
begin
  Result := List.FCount = FCount;
  if Result then Result := CompareMem(FList, List.FList, FCount * SizeOf(Integer));
end;

procedure TFrameTableList.LoadFromStream(Stream: TStream);
var
  N: Integer;
begin
  Clear;
  Stream.Read(FDefaultValue, 4);
  Stream.Read(N, 4);
  SetCapacity(N);
  Stream.Read(FList^, N * SizeOf(Integer));
  FCount := N;
end;

procedure TFrameTableList.SaveToStream(Stream: TStream);
begin
  Stream.Write(FDefaultValue, 4);
  Stream.Write(FCount, 4);
  Stream.Write(FList^, FCount * SizeOf(Integer));
end;

{ The items separated by commas }
function TFrameTableList.GetItemString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FCount - 1 do Result := Result + IntToStr(FList^[I]) + ',';
  if Result <> '' then Result := System.Copy(Result, 1, Length(Result) - 1);
end;

{ Reads items separated by commas; other characters than digits are dropped, an empty item
  is 0 }
procedure TFrameTableList.SetItemString(Value: string);
var
  I, N: Integer;
  S: string;
begin
  for I := Length(Value) downto 1 do
    if not (Value[I] in [',', '0'..'9']) then System.Delete(Value, I, 1);
  Clear;
  I := Pos(',', Value);
  while Value <> '' do
  begin
    if I <> 0 then
    begin
      S := System.Copy(Value, 1, I - 1);
      System.Delete(Value, 1, I);
    end
    else
    begin
      S := Value;
      Value := '';
    end;
    if S <> '' then
      N := StrToInt(S)
    else
      N := 0;
    Add(N);
    I := Pos(',', Value);
  end;
end;

{ TGrabInfo }

function TGrabInfo.GrabInfoClass: TGrabInfoClass;
begin
  Result := TGrabInfo;
end;

procedure TGrabInfo.LoadFromStream(Stream: TStream);
begin
  Stream.Read(TransparentColor, 4);
  Stream.Read(FindRectangles, 1);
  Stream.Read(TransparentPixel, 4);
  ReadStringFromStream(FileName, Stream);
  Stream.Read(FileIndex, 4);
end;

procedure TGrabInfo.SaveToStream(Stream: TStream);
begin
  Stream.Write(TransparentColor, 4);
  Stream.Write(FindRectangles, 1);
  Stream.Write(TransparentPixel, 4);
  WriteStringToStream(FileName, Stream);
  Stream.Write(FileIndex, 4);
end;

function TGrabInfo.Copy: TGrabInfo;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    SaveToStream(Stream);
    Stream.Position := 0;
    Result := GrabInfoClass.Create;
    Result.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

{ TCustomImageLibrary }

constructor TCustomImageLibrary.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPaletteManager := TPaletteManager.Create;
  FLoadOnDemand := True;
  FFileName := '';
  FStatus := [];
  Clear;
end;

destructor TCustomImageLibrary.Destroy;
begin
  Clear;
  FPaletteManager.Free;
  inherited Destroy;
end;

function TCustomImageLibrary.GetModified: Boolean;
begin
  Result := isModified in FStatus;
end;

procedure TCustomImageLibrary.SetModified(Value: Boolean);
begin
  if Value then
    FStatus := FStatus + [isModified]
  else
    FStatus := FStatus - [isModified];
end;

procedure TCustomImageLibrary.SetCapacity(NewCapacity: Integer);
var
  I: Integer;
begin
  if NewCapacity <> 0 then NewCapacity := NewCapacity or 7;
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FImages, NewCapacity * SizeOf(TImageItem));
    if NewCapacity > FCapacity then
    begin
      FillChar(FImages^[FCapacity], (NewCapacity - FCapacity) * SizeOf(TImageItem), 0);
      for I := FCapacity to NewCapacity - 1 do FImages^[I].Reference := -1;
    end;
    FCapacity := NewCapacity;
    if FCapacity < FCount then FCount := FCapacity;
  end;
end;

procedure TCustomImageLibrary.SetCount(Value: Integer);
begin
  FCount := Value;
  if FCount > FCapacity then SetCapacity(FCount);
end;

function TCustomImageLibrary.GetFullFileName: string;
var
  Drive, Path: string;
begin
  if FFileName <> '' then
  begin
    if csDesigning in ComponentState then
      Path := ExtractFilePath(ToolServices.GetProjectName)
    else
      Path := BaseImageLibraryPath;
    Drive := ExtractFileDrive(FFileName);
    if (Drive = '') or (Drive = ExtractFileDrive(Path)) then
      Result := ExpandFileName(Path + FFileName)
    else
      Result := FFileName;
  end
  else
    Result := '';
end;

procedure TCustomImageLibrary.SetFileName(Value: string);
var
  Path: string;
begin
  if csDesigning in ComponentState then
    Path := ExtractFilePath(ToolServices.GetProjectName)
  else
    Path := BaseImageLibraryPath;
  Value := ExtractRelativePath(Path, Value);
  if ((csDesigning in ComponentState) or (csLoading in ComponentState)) and (Value <> FFileName) then
  begin
    FFileName := Value;
    if FFileName <> '' then
      try
        LoadFromFile(GetFullFileName);
      except
        ShowMessage('Error loading: ' + GetFullFileName);
        FFileName := '';
      end
    else
      DisableReloading;
  end
  else
    FFileName := Value;
end;

function TCustomImageLibrary.ReduceCount: Integer;
begin
  while (FCount > 0) and (Get(FCount - 1) = nil) do Dec(FCount);
  Result := FCount;
end;

procedure TCustomImageLibrary.DeleteItem(Index: Integer);
begin
  Move(FImages^[Index + 1], FImages^[Index], (FCount - Index - 1) * SizeOf(TImageItem));
  FillChar(FImages^[FCount - 1], SizeOf(TImageItem), 0);
  Dec(FCount);
  SetModified(True);
end;

procedure TCustomImageLibrary.InsertItem(Index: Integer);
begin
  SetCount(FCount + 1);
  Move(FImages^[Index], FImages^[Index + 1], (FCount - Index - 1) * SizeOf(TImageItem));
  FillChar(FImages^[Index], SizeOf(TImageItem), 0);
end;

procedure TCustomImageLibrary.UpdateImageItemSettings(Index: Integer);
var
  Image: TLibraryImage;
begin
  Image := FImages^[Index].Image;
  if (Image <> nil) and (Image.ClassID = $100) then TImageNode(Image).UpdateDimensions;
end;

procedure TCustomImageLibrary.CallOnChangeEvent;
begin
  if (FChangeLock = 0) and Assigned(FOnChange) and not (csDestroying in ComponentState) and
    not (csReading in ComponentState) then
  begin
    Inc(FChangeLock);
    FOnChange(Self);
    Dec(FChangeLock);
  end;
end;

procedure TCustomImageLibrary.DisableOnChangeEvent;
begin
  Inc(FChangeLock);
end;

procedure TCustomImageLibrary.EnableOnChangeEvent;
begin
  Dec(FChangeLock);
  if FChangeLock = 0 then CallOnChangeEvent;
end;

procedure TCustomImageLibrary.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', LoadFromStream, SaveToStream, FFileName = '');
end;

procedure TCustomImageLibrary.Clear;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if FImages^[I].Image <> nil then FImages^[I].Image.Free;
  if not (isLoadingFromFile in FStatus) then
  begin
    FFileName := '';
    FLoadedFileName := '';
  end;
  FReloading := False;
  SetCapacity(0);
  FPaletteManager.Clear;
  if FChangeLock = 0 then CallOnChangeEvent;
end;

procedure TCustomImageLibrary.DisableReloading;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    if FImages^[I].Image <> nil then FImages^[I].Image.SetReloadingEnabled(False);
  FReloading := False;
end;

procedure TCustomImageLibrary.ReleaseDiscardableImageData;
var
  I: Integer;
  Image: TLibraryImage;
begin
  if FReloading then
    for I := 0 to FCount - 1 do
      begin
      Image := FImages^[I].Image;
      if Image <> nil then Image.ReleaseDiscardableImageData;
    end;
end;

procedure TCustomImageLibrary.LoadDiscardableImageData;
var
  I: Integer;
  Image: TLibraryImage;
begin
  for I := 0 to FCount - 1 do
    begin
      Image := FImages^[I].Image;
      if Image <> nil then Image.LoadDiscardableImageData;
    end;
end;

procedure TCustomImageLibrary.SetLoadOnDemand(Value: Boolean);
begin
  if not Value and FLoadOnDemand then DisableReloading;
  FLoadOnDemand := Value;
  if not Value then FReloading := False;
end;

function TCustomImageLibrary.IsReference(Index: Integer): Boolean;
begin
  Result := (Index >= 0) and (Index < FCount) and (FImages^[Index].Image = nil) and
    (FImages^[Index].Reference <> -1);
end;

function TCustomImageLibrary.Get(Index: Integer): TLibraryImage;
begin
  Result := FImages^[Index].Image;
  if Result = nil then
  begin
    { the reference index passes through Result (the original's register use) }
    Result := TLibraryImage(FImages^[Index].Reference);
    if Integer(Result) <> -1 then
      Result := FImages^[Integer(Result)].Image
    else
      Result := nil;
  end;
end;

function TCustomImageLibrary.GetSafe(Index: Integer): TLibraryImage;
begin
  if (Index < FCount) and (Index >= 0) then
  begin
    Result := FImages^[Index].Image;
    if Result = nil then
    begin
      Result := TLibraryImage(FImages^[Index].Reference);
      if (Integer(Result) <> -1) and (Integer(Result) >= 0) and (Integer(Result) < FCount) then
        Result := FImages^[Integer(Result)].Image
      else
        Result := nil;
    end;
  end
  else
    Result := nil;
end;

function TCustomImageLibrary.ImageExist(Index: Integer): Boolean;
var
  R: Integer;
begin
  if (Index < FCount) and (Index >= 0) then
  begin
    Result := FImages^[Index].Image <> nil;
    if not Result then
    begin
      R := FImages^[Index].Reference;
      if (R >= 0) and (R < FCount) then
        Result := FImages^[R].Image <> nil
      else
        Result := False;
    end;
  end
  else
    Result := False;
end;

function TCustomImageLibrary.GetImageReference(Index: Integer): Integer;
begin
  Result := FImages^[Index].Reference;
end;

procedure TCustomImageLibrary.SetImageReference(Index, Value: Integer);
begin
  if Index >= FCount then SetCount(Index + 1);
  if Value <> -1 then
  begin
    if FImages^[Index].Image <> nil then FImages^[Index].Image.Destroy;
    FImages^[Index].Image := nil;
  end;
  FImages^[Index].Reference := Value;
  UpdateImageItemSettings(Index);
  SetModified(True);
end;

procedure TCustomImageLibrary.LoadFromStream(Stream: TStream);
var
  Index, Reference, StartPos: Integer;
  MS: TMemoryStream;
  Header: TILBHeader;
  SubIndex: Integer;
  Image: TLibraryImage;
begin
  FStatus := FStatus + [isLoading];
  Inc(FChangeLock);
  Clear;
  FReloading := (isLoadingFromFile in FStatus) and FLoadOnDemand;
  StartPos := Stream.Position;
  Stream.Read(Header, SizeOf(Header));
  Stream.Seek(Header.HeaderSize + StartPos, 0);
  if Header.Version < 4 then
  begin
    FDataOffset := 0;
    if Header.Version > 1.5 then
      FPaletteManager.LoadFromStream(Stream)
    else
      FPaletteManager.Clear;
    if Header.Version <= 2 then
    begin
      Stream.Read(Index, 4);
      while Index <> -1 do
      begin
        SubIndex := 0;
        Image := ReadImageFromStream(Stream, Self);
        while Image <> nil do
        begin
          SetSubImage(Index, SubIndex, Image);
          Inc(SubIndex);
          Image := ReadImageFromStream(Stream, Self);
        end;
        Stream.Read(Reference, 4);
        SetImageReference(Index, Reference);
        Stream.Read(Index, 4);
      end;
    end
    else if Header.Version = 3 then
    begin
      Stream.Read(Index, 4);
      while Index <> -1 do
      begin
        SetImage(Index, ReadImageFromStream(Stream, Self));
        Stream.Read(Reference, 4);
        SetImageReference(Index, Reference);
        Stream.Read(Index, 4);
      end;
    end;
  end
  else
  begin
    FDataOffset := Header.IndexEnd + StartPos;
    MS := TMemoryStream.Create;
    try
      MS.SetSize(Header.IndexEnd - Header.HeaderSize);
      Stream.ReadBuffer(MS.Memory^, MS.Size);
      FPaletteManager.LoadFromStream(MS);
      MS.Read(Index, 4);
      while Index <> -1 do
      begin
        SetImage(Index, ReadImageFromStreamEx(MS, Stream, Self));
        MS.Read(Reference, 4);
        SetImageReference(Index, Reference);
        MS.Read(Index, 4);
      end;
    finally
      MS.Free;
    end;
    if not (isLoadingFromFile in FStatus) then Stream.Seek(Header.Size + StartPos, 0);
  end;
  Dec(FChangeLock);
  if FChangeLock = 0 then CallOnChangeEvent;
  FStatus := FStatus - [isLoading];
end;

procedure TCustomImageLibrary.SaveToStream(Stream: TStream);
var
  Swap: TFileStream;
  StartPos: Integer;
  SwapName: string;
  I: Integer;
  Header: TILBHeader;
begin
  StartPos := Stream.Position;
  SwapName := ExtractFilePath(Application.ExeName) + '\SWAP.$$$';
  Swap := TFileStream.Create(SwapName, fmCreate);
  try
    FStatus := FStatus + [isSaving];
    Header.HeaderSize := SizeOf(Header);
    Header.ID := 'ILB'#0;
    Header.Version := 4;
    Stream.Write(Header, SizeOf(Header));
    FPaletteManager.SaveToStream(Stream);
    for I := 0 to FCount - 1 do
      if (FImages^[I].Image <> nil) or (FImages^[I].Reference <> -1) then
      begin
        Stream.Write(I, 4);
        WriteImageToStreamEx(FImages^[I].Image, Stream, Swap);
        Stream.Write(FImages^[I].Reference, 4);
      end;
    I := -1;
    Stream.Write(I, 4);
    Header.IndexEnd := Stream.Position - StartPos;
    Swap.Position := 0;
    Stream.CopyFrom(Swap, Swap.Size);
    Header.Size := Stream.Position - StartPos;
    Stream.Position := StartPos;
    Stream.Write(Header, SizeOf(Header));
    Stream.Position := StartPos + Header.Size;
  finally
    FStatus := FStatus - [isSaving];
    Swap.Free;
    DeleteFile(SwapName);
  end;
end;

procedure TCustomImageLibrary.LoadFromFile(const AFileName: string);
var
  Stream: TStream;
begin
  Stream := TFastLoadFileStream.Create(AFileName);
  try
    Inc(FChangeLock);
    FStatus := FStatus + [isLoadingFromFile];
    FileName := ExpandFileName(AFileName);
    FLoadedFileName := GetFullFileName;
    LoadFromStream(Stream);
  finally
    FStatus := FStatus - [isLoadingFromFile];
    Stream.Free;
    Dec(FChangeLock);
    if FChangeLock = 0 then CallOnChangeEvent;
  end;
end;

procedure TCustomImageLibrary.SaveToFile(const AFileName: string);
var
  Stream: TFileStream;
  Name: string;
begin
  Name := ExpandFileName(AFileName);
  if Name = FLoadedFileName then DisableReloading;
  FStatus := FStatus + [isSavingToFile];
  Stream := TFileStream.Create(Name, fmCreate);
  try
    SaveToStream(Stream);
  finally
    FStatus := FStatus - [isSavingToFile];
    Stream.Free;
  end;
end;

procedure TCustomImageLibrary.LoadFromFileStream(const AFileName: string; Stream: TStream);
begin
  FStatus := FStatus + [isLoadingFromFile];
  try
    FileName := ExpandFileName(AFileName);
    FLoadedFileName := GetFullFileName;
    LoadFromStream(Stream);
  finally
    FStatus := FStatus - [isLoadingFromFile];
  end;
end;

procedure TCustomImageLibrary.CopyToClipboard;
begin
  Clipboard.SetComponent(Self);
end;

procedure TCustomImageLibrary.PasteFromClipboard;
var
  L: TComponent;
  I: Integer;
begin
  Inc(FChangeLock);
  Clear;
  L := Clipboard.GetComponent(Self, nil);
  if (L <> nil) and (L is TCustomImageLibrary) then
  begin
    FFileName := TCustomImageLibrary(L).FFileName;
    FLoadedFileName := TCustomImageLibrary(L).FLoadedFileName;
    FReloading := TCustomImageLibrary(L).FReloading;
    for I := 0 to TCustomImageLibrary(L).FCount - 1 do
      SetImage(I, TCustomImageLibrary(L).GetImage(I));
  end;
  Dec(FChangeLock);
  if FChangeLock = 0 then CallOnChangeEvent;
end;

function TCustomImageLibrary.Copy: TCustomImageLibrary;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Result := TCustomImageLibrary(TComponentClass(ClassType).Create(nil));
    SaveToStream(Stream);
    Stream.Position := 0;
    Result.LoadFromStream(Stream);
    Result.FReloading := False;
  finally
    Stream.Destroy;
  end;
end;

procedure TCustomImageLibrary.Assign(Source: TPersistent);
var
  Stream: TMemoryStream;
begin
  if Source is TCustomImageLibrary then
  begin
    Stream := TMemoryStream.Create;
    try
      TCustomImageLibrary(Source).SaveToStream(Stream);
      Stream.Position := 0;
      LoadFromStream(Stream);
      FFileName := TCustomImageLibrary(Source).FFileName;
      FLoadedFileName := TCustomImageLibrary(Source).FLoadedFileName;
      if FChangeLock = 0 then CallOnChangeEvent;
    finally
      Stream.Free;
    end;
  end
  else
    raise EConvertError.Create('Can only assign to a TCustomImageLibrary descendant');
end;

procedure TCustomImageLibrary.Delete(Index: Integer);
begin
  if Index < FCount then
  begin
    if FImages^[Index].Image <> nil then FImages^[Index].Image.Free;
    DeleteItem(Index);
    if FChangeLock = 0 then CallOnChangeEvent;
  end;
end;

function TCustomImageLibrary.Remove(Image: TLibraryImage): Integer;
begin
  Result := IndexOf(Image);
  if Result <> -1 then
  begin
    if FImages^[Result].Image <> nil then FImages^[Result].Image.Free;
    DeleteItem(Result);
    if FChangeLock = 0 then CallOnChangeEvent;
  end;
end;

function TCustomImageLibrary.IndexOf(Image: TLibraryImage): Integer;
begin
  Result := 0;
  while (Result < FCount) and (Image <> FImages^[Result].Image) do Inc(Result);
  if Result = FCount then Result := -1;
end;

function TCustomImageLibrary.GetImage(Index: Integer): TLibraryImage;
begin
  if FImages^[Index].Image <> nil then
  begin
    Result := FImages^[Index].Image;
    Result.SetOwner(nil);
    FImages^[Index].Image := nil;
    SetModified(True);
    if FChangeLock = 0 then CallOnChangeEvent;
  end
  else
    Result := nil;
end;

procedure TCustomImageLibrary.SetImage(Index: Integer; Image: TLibraryImage);
begin
  if Index >= FCount then SetCount(Index + 1);
  if FImages^[Index].Image <> nil then FImages^[Index].Image.Destroy;
  FImages^[Index].Image := Image;
  FImages^[Index].Reference := -1;
  UpdateImageItemSettings(Index);
  if Image <> nil then Image.SetOwner(Self);
  SetModified(True);
  if FChangeLock = 0 then CallOnChangeEvent;
end;

procedure TCustomImageLibrary.Insert(Index: Integer; Image: TLibraryImage);
begin
  if Index < 0 then Index := 0;
  if Index < FCount then InsertItem(Index);
  SetImage(Index, Image);
end;

procedure TCustomImageLibrary.Add(Image: TLibraryImage);
begin
  SetImage(FCount, Image);
end;

function TCustomImageLibrary.Empty: Boolean;
var
  I: Integer;
begin
  I := 0;
  while (I <> FCount) and (FImages^[I].Image = nil) do Inc(I);
  Result := I = FCount;
end;

procedure TCustomImageLibrary.Pack;
var
  I: Integer;
begin
  DisableOnChangeEvent;
  for I := FCount - 1 downto 0 do
    if Get(I) = nil then Delete(I);
  EnableOnChangeEvent;
end;

function TCustomImageLibrary.GetSubCount(Index: Integer): Integer;
var
  Image: TLibraryImage;
begin
  Image := GetSafe(Index);
  if Image <> nil then
  begin
    if Image.ClassID <> $100 then
      Result := 1
    else
      Result := TImageNode(Image).FCount;
  end
  else
    Result := -1;
end;

function TCustomImageLibrary.GetSub(Index, SubIndex: Integer): TLibraryImage;
var
  Image: TLibraryImage;
begin
  Image := FImages^[Index].Image;
  if Image = nil then
  begin
    Index := FImages^[Index].Reference;
    if Index <> -1 then Image := FImages^[Index].Image;
  end;
  if Image <> nil then
  begin
    if Image.ClassID = $100 then
      Result := TImageNode(Image).FImages^[SubIndex]
    else if SubIndex = 0 then
      Result := Image
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TCustomImageLibrary.GetSafeSub(Index, SubIndex: Integer): TLibraryImage;
var
  Image: TLibraryImage;
begin
  Image := GetSafe(Index);
  if Image <> nil then
  begin
    if Image.ClassID = $100 then
      Result := TImageNode(Image).GetSafeImage(SubIndex)
    else if SubIndex = 0 then
      Result := Image
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TCustomImageLibrary.GetSubImage(Index, SubIndex: Integer): TLibraryImage;
var
  Node: TImageNode;
begin
  Result := FImages^[Index].Image;
  if Result <> nil then
    if Result.ClassID = $100 then
    begin
      Node := TImageNode(Result);
      if (SubIndex >= 0) and (SubIndex < Node.FCount) then
      begin
        Result := Node.FImages^[SubIndex];
        Result.SetOwner(nil);
        Node.Delete(SubIndex);
        if Node.FCount = 1 then
        begin
          FImages^[Index].Image := Node.GetImage(0);
          Node.Delete(0);
          Node.Free;
        end;
        SetModified(True);
      end
      else
        Result := nil;
    end
    else if SubIndex = 0 then
    begin
      Result.SetOwner(nil);
      FImages^[Index].Image := nil;
      SetModified(True);
    end
    else
      Result := nil;
end;

procedure TCustomImageLibrary.SetSubImage(Index, SubIndex: Integer; Image: TLibraryImage);
var
  Old: TLibraryImage;
  Node: TImageNode;
begin
  if Index < FCount then
    Old := FImages^[Index].Image
  else
    Old := nil;
  if Old <> nil then
  begin
    if Old.ClassID = $100 then
    begin
      Node := TImageNode(Old);
      if (SubIndex >= 0) and (SubIndex < Node.FCount) then
      begin
        Old := Node.FImages^[SubIndex];
        if Old <> nil then Old.Destroy;
        Node.FImages^[SubIndex] := Image;
        Image.SetOwner(Self);
        SetModified(True);
      end
      else
      begin
        Node.Add(Image);
        Image.SetOwner(Self);
        SetModified(True);
      end;
    end
    else if SubIndex <> 0 then
    begin
      Node := TImageNode.Create(Self);
      Node.Add(Old);
      Node.Add(Image);
      FImages^[Index].Image := Node;
      Image.SetOwner(Self);
      SetModified(True);
    end
    else
      SetImage(Index, Image);
  end
  else
    SetImage(Index, Image);
end;

{ DeleteSub: the test of the node class is inverted (an original bug): a single image is treated
  as a node, and a node is freed whole when SubIndex is 0. }
procedure TCustomImageLibrary.DeleteSub(Index, SubIndex: Integer);
var
  Node: TImageNode;
begin
  Node := TImageNode(FImages^[Index].Image);
  if Node <> nil then
    if Node.ClassID <> $100 then
    begin
      Node.GetImage(SubIndex).Destroy;
      Node.Delete(SubIndex);
      if Node.FCount = 1 then
      begin
        FImages^[Index].Image := Node.FImages^[0];
        Node.Delete(0);
        Node.Destroy;
      end;
      SetModified(True);
    end
    else if SubIndex = 0 then
    begin
      Node.Free;
      FImages^[Index].Image := nil;
    end;
end;

function TCustomImageLibrary.RemoveSub(Index: Integer; Image: TLibraryImage): Integer;
var
  Old: TLibraryImage;
begin
  Old := FImages^[Index].Image;
  if Old <> nil then
  begin
    if Old.ClassID = $100 then
    begin
      Result := TImageNode(Old).IndexOf(Image);
      if Result <> -1 then DeleteSub(Index, Result);
    end
    else if Old = Image then
    begin
      Old.Free;
      FImages^[Index].Image := nil;
      SetModified(True);
      Result := 0;
    end
    else
      Result := -1;
  end
  else
    Result := -1;
end;

function TCustomImageLibrary.IndexOfSub(Index: Integer; Image: TLibraryImage): Integer;
var
  Old: TLibraryImage;
begin
  Old := FImages^[Index].Image;
  if Old <> nil then
  begin
    if Old.ClassID = $100 then
      Result := TImageNode(Old).IndexOf(Image)
    else if Old = Image then
      Result := 0
    else
      Result := -1;
  end
  else
    Result := -1;
end;

procedure TCustomImageLibrary.InsertSub(Index, SubIndex: Integer; Image: TLibraryImage);
var
  Old: TLibraryImage;
  Node: TImageNode;
begin
  Old := FImages^[Index].Image;
  if Old <> nil then
  begin
    if Old.ClassID = $100 then
    begin
      TImageNode(Old).Insert(SubIndex, Image);
      Image.SetOwner(Self);
      SetModified(True);
    end
    else
    begin
      Node := TImageNode.Create(Self);
      Node.Add(Old);
      FImages^[Index].Image := Node;
      Node.Insert(SubIndex, Image);
      Image.SetOwner(Self);
      SetModified(True);
    end;
  end
  else
    AddSub(Index, Image);
end;

procedure TCustomImageLibrary.AddSub(Index: Integer; Image: TLibraryImage);
var
  Old: TLibraryImage;
  Node: TImageNode;
begin
  Old := FImages^[Index].Image;
  if Old <> nil then
  begin
    if Old.ClassID = $100 then
    begin
      TImageNode(Old).Add(Image);
      Image.SetOwner(Self);
      SetModified(True);
    end
    else
    begin
      Node := TImageNode.Create(Self);
      Node.Add(Old);
      FImages^[Index].Image := Node;
      Image.SetOwner(Self);
      SetModified(True);
    end;
  end
  else
    SetImage(Index, Image);
end;

function TCustomImageLibrary.SubImageExist(Index, SubIndex: Integer): Boolean;
var
  Image: TLibraryImage;
begin
  Image := FImages^[Index].Image;
  if (Image <> nil) and (SubIndex >= 0) then
  begin
    if Image.ClassID = $100 then
      Result := SubIndex < TImageNode(Image).FCount
    else
      Result := SubIndex = 0;
  end
  else
    Result := False;
end;

{ The library image classes }

function GetLibraryImageClass(Index: Integer): TLibraryImageClass;
begin
  Result := LibraryImageClasses[Index];
end;

function LibraryImageClassCount: Integer;
begin
  Result := LibraryImageClasses.Count;
end;

function FindLibraryImageClass(ClassID: Integer): TLibraryImageClass;
var
  I: Integer;
  Found: Boolean;
begin
  Found := False;
  I := 0;
  while (I < LibraryImageClasses.Count) and not Found do
  begin
    Found := ClassID = TLibraryImageClass(LibraryImageClasses[I]).ClassID;
    Inc(I);
  end;
  if Found then
    Result := LibraryImageClasses[I - 1]
  else
    Result := nil;
end;

procedure RegisterLibraryImageClasses(AClasses: array of TLibraryImageClass);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    if (AClasses[I].ClassID <> 0) and (FindLibraryImageClass(AClasses[I].ClassID) = nil) then
      LibraryImageClasses.Add(AClasses[I])
    else
      raise Exception.Create('Image ClassID is already used (' + AClasses[I].ClassName + ')');
end;

function ReadImageFromStream(Stream: TStream; AOwner: TCustomImageLibrary): TLibraryImage;
var
  ID: Integer;
  ImageClass: TLibraryImageClass;
begin
  Stream.Read(ID, 4);
  ImageClass := FindLibraryImageClass(ID);
  if ImageClass <> nil then
  begin
    Result := ImageClass.Create(AOwner);
    Result.LoadFromStream(Stream);
  end
  else
    Result := nil;
end;

procedure WriteImageToStream(Image: TLibraryImage; Stream: TStream);
var
  ID: Integer;
begin
  if Image <> nil then
  begin
    ID := Image.ClassID;
    Stream.Write(ID, 4);
    Image.SaveToStream(Stream);
  end
  else
  begin
    ID := 0;
    Stream.Write(ID, 4);
  end;
end;

function ReadImageFromStreamEx(Stream, DataStream: TStream; AOwner: TCustomImageLibrary): TLibraryImage;
var
  ID: Integer;
  ImageClass: TLibraryImageClass;
begin
  Stream.Read(ID, 4);
  ImageClass := FindLibraryImageClass(ID);
  if ImageClass <> nil then
  begin
    Result := ImageClass.Create(AOwner);
    Result.LoadFromStreamEx(Stream, DataStream);
  end
  else
    Result := nil;
end;

procedure WriteImageToStreamEx(Image: TLibraryImage; Stream, DataStream: TStream);
var
  ID: Integer;
begin
  if Image <> nil then
  begin
    ID := Image.ClassID;
    Stream.Write(ID, 4);
    Image.SaveToStreamEx(Stream, DataStream);
  end
  else
  begin
    ID := 0;
    Stream.Write(ID, 4);
  end;
end;

{ TILFilenameProperty }

function TILFilenameProperty.GetValue: string;
begin
  Result := inherited GetValue;
  if Result = '' then Result := '(using DFM)';
end;

procedure TILFilenameProperty.Edit;
var
  SaveDlg: TSaveDialog;
  OpenDlg: TOpenDialog;
  R: Integer;
  Dir: string;
  DoOpen: Boolean;
  L: TCustomImageLibrary;
begin
  Dir := GetCurrentDir;
  DoOpen := True;
  L := TCustomImageLibrary(GetComponent(0));
  if (L.FFileName = '') and (L.FCount <> 0) then
  begin
    R := MessageDlg('Save available images?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if R = mrYes then
    begin
      SaveDlg := TSaveDialog.Create(Application);
      SaveDlg.Filter := 'Image Libraries (*.ILB)|*.ILB';
      SaveDlg.DefaultExt := 'ILB';
      try
        if SaveDlg.Execute then
        begin
          L.SaveToFile(SaveDlg.FileName);
          L.FileName := SaveDlg.FileName;
          DoOpen := False;
        end
        else
          DoOpen := False;
      finally
        SaveDlg.Free;
      end;
    end;
    if R = mrCancel then DoOpen := False;
  end;
  if DoOpen then
  begin
    OpenDlg := TOpenDialog.Create(Application);
    if GetValue <> '' then
      OpenDlg.FileName := ExpandFileName(ExtractFilePath(ToolServices.GetProjectName) + GetValue);
    OpenDlg.Filter := 'Image Libraries|*.ILB';
    OpenDlg.Options := OpenDlg.Options + [ofPathMustExist, ofFileMustExist];
    try
      if OpenDlg.Execute then SetValue(OpenDlg.FileName);
    finally
      OpenDlg.Free;
      SetCurrentDir(Dir);
    end;
  end;
end;

function TILFilenameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paRevertable];
end;

procedure Register;
begin
  RegisterComponents('ImageLibrary', [TImageLibrary]);
  RegisterComponents('ImageLibrary', [TImageLibraryFont]);
  RegisterComponents('ImageLibrary', [TImageLibraryPanel]);
  RegisterComponents('ImageLibrary', [TImageLibraryGrid]);
  RegisterComponents('ImageLibrary', [TImageLibraryManager]);
  RegisterComponents('ImageLibrary', [TILManagerComboBox]);
  RegisterComponents('ImageLibrary', [TILManagerListBox]);
  RegisterComponents('ImageLibrary', [TImageDrawGrid]);
  RegisterComponents('ImageLibrary', [TImageLibraryEditGrid]);
  RegisterComponents('ImageLibrary', [TSubImageEditor]);
  RegisterComponents('ImageLibrary', [TImageSettingsEditor]);
  RegisterComponents('ImageLibrary', [TSubImageSettingsEditor]);
  RegisterComponentEditor(TCustomImageLibrary, TImageLibraryEditor);
  RegisterPropertyEditor(TypeInfo(string), TCustomImageLibrary, 'FileName', TILFilenameProperty);
end;

initialization
  BaseImageLibraryPath := ExtractFilePath(Application.ExeName);
  RegisterClasses([TImageLibrary]);
  LibraryImageClasses := TList.Create;
  RegisterLibraryImageClasses([TPicture08, TRLESprite08]);
  RegisterLibraryImageClasses([TPicture16, TTransparentPicture16, TRLESprite16,
    TTransparentRLESprite16, TShadow, TImageNode, TSprite16]);
finalization
  LibraryImageClasses.Free;
end.
