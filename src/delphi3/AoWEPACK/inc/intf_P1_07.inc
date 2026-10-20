{ Interface declaration run owned by P1. }
  { TFaceResource (instance size 44, VMT 557102F0) }
  TFaceResource = class(TEResource)
  public
    FImageLibraryName: string;  { $18 }
    FImageIndex: Integer;  { $1C }
    FImageLibrary: TCustomImageLibrary;  { $20 }
    FReferences: Integer;  { $24 }
    FDeveloperOnly: Boolean;  { $28 }
    F_FaceResource_29: array[0..2] of Byte;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    function FaceResourceIndex: Integer;
    procedure LinkToIL;
    procedure ReleaseIL;
    procedure SetImageLibraryName(Value: string);
    function GetFaceImage: TLibraryImage;
  end;

  { TFaceResourceList (instance size 20, VMT 557103D8) }
  TFaceResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function IndexOfFaceImage(Image: TLibraryImage): Integer;
    function GetFaceResource(Index: Integer): TFaceResource;
    function PrevFace(Index: Integer): Integer;
    function NextFace(Index: Integer): Integer;
  end;

