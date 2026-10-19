unit ImageLib;

{ Stub of the game's ImageLib unit (Ilpack.dpl): only the declarations the Engine, ImgLComp and
  EResGrid units need, with the register/stack parameter layout their call sites show. Every body
  is a stub until Ilpack is matched. BltLibraryImage: Rect by value, Mode as a byte, a Boolean and
  a var record on the stack (Engine.TEResource.Draw, ImgLComp.TDrawImageGrid.DrawCellImage). }

interface

uses
  Windows, Classes;

type
  { ImageLib.TBltMode: how an image is fitted into a rectangle (names from the type info) }
  TBltMode = (bmNone, bmStretch, bmStretchToFit, bmCenter);

  { ImageLib.TLibraryImage (instance size 64): an image of an image library. Only the VMT order
    matters here: Copy is slot 30 (+120), the method ImgLComp calls; the other virtual methods
    are named after the original VMT (notes/classes.json) and are stubs. }
  TLibraryImage = class(TPersistent)
  private
    FReserved: array[0..14] of Integer;
  public
    procedure SetOwner; virtual; abstract;
    procedure SetLoadMode; virtual; abstract;
    procedure GetPalette; virtual; abstract;
    procedure GetRemapPalette; virtual; abstract;
    procedure GetTransparent; virtual; abstract;
    procedure SetReloadingEnabled; virtual; abstract;
    procedure SetDefaultShowInfo; virtual; abstract;
    procedure SetXshift; virtual; abstract;
    procedure SetYshift; virtual; abstract;
    procedure SetWidth; virtual; abstract;
    procedure SetHeight; virtual; abstract;
    procedure GetVisualDimensions; virtual; abstract;
    procedure ReadImageData; virtual; abstract;
    procedure WriteImageData; virtual; abstract;
    procedure ReadDiscardableImageData; virtual; abstract;
    procedure WriteDiscardableImageData; virtual; abstract;
    procedure ReleaseDiscardableImageData; virtual; abstract;
    procedure LoadDiscardableImageData; virtual; abstract;
    procedure SaveToStreamEx; virtual; abstract;
    procedure LoadFromStreamEx; virtual; abstract;
    procedure RemapToPixelFormat; virtual; abstract;
    procedure Clear; virtual; abstract;
    constructor Create; virtual;
    class function ClassID: Integer; virtual; abstract;
    class function Name: string; virtual; abstract;
    class function ClassVersion: Integer; virtual; abstract;
    procedure Info; virtual; abstract;
    function Copy: TLibraryImage; virtual;
  end;

  { ImageLib.TCustomImageLibrary (instance size 80): +$44 FCount, +$48 FImages (8-byte entries:
    image, reference), +$4C FPaletteManager. Get returns an image, GetImage takes it out of the
    library, SetImage destroys the image that was at Index, Add is SetImage(Count, Image). stub }
  TCustomImageLibrary = class(TComponent)
  private
    FReserved: array[0..7] of Integer;
    FCount: Integer;
    FImages: Pointer;
    FPaletteManager: TObject;
  public
    constructor Create(AOwner: TComponent); override;
    function Get(Index: Integer): TLibraryImage;
    procedure Add(Image: TLibraryImage);
    procedure SetImage(Index: Integer; Image: TLibraryImage);
    function GetImage(Index: Integer): TLibraryImage;
    procedure CopyToClipboard;
    procedure PasteFromClipboard;
    property Count: Integer read FCount;
    property Images[Index: Integer]: TLibraryImage read Get; default;
  end;

  { ImageLib.TImageLibrary (instance size 80): the published image library component. stub }
  TImageLibrary = class(TCustomImageLibrary)
  end;

procedure BltLibraryImage(Dest: TObject; Image: Pointer; Rect: TRect; Mode: Byte;
  A, B, C, D: Integer; Flag: Boolean; var R: TRect);

implementation

{ TLibraryImage }

constructor TLibraryImage.Create;
begin
  inherited Create;
end;

function TLibraryImage.Copy: TLibraryImage;
begin
  Result := nil;
end;

{ TCustomImageLibrary }

constructor TCustomImageLibrary.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TCustomImageLibrary.Get(Index: Integer): TLibraryImage;
begin
  Result := nil;
end;

procedure TCustomImageLibrary.Add(Image: TLibraryImage);
begin
end;

procedure TCustomImageLibrary.SetImage(Index: Integer; Image: TLibraryImage);
begin
end;

function TCustomImageLibrary.GetImage(Index: Integer): TLibraryImage;
begin
  Result := nil;
end;

procedure TCustomImageLibrary.CopyToClipboard;
begin
end;

procedure TCustomImageLibrary.PasteFromClipboard;
begin
end;

procedure BltLibraryImage(Dest: TObject; Image: Pointer; Rect: TRect; Mode: Byte;
  A, B, C, D: Integer; Flag: Boolean; var R: TRect);
begin
end;

end.
