{ Interface declaration run owned by P1. }
  { TFaceResource (instance size 44, VMT 557102F0) }
  TFaceResource = class(TEResource)
  public
    F_FaceResource_18: Integer;
    F_FaceResource_1C: Integer;
    F_FaceResource_20: Integer;
    F_FaceResource_24: Integer;
    F_FaceResource_28: Byte;
    F_FaceResource_29: array[0..2] of Byte;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    procedure FaceResourceIndex;  { draft }
    procedure LinkToIL;  { draft }
    procedure ReleaseIL;  { draft }
    procedure SetImageLibraryName(A1: Integer; A2: Integer);  { draft }
    procedure GetFaceImage;  { draft }
  end;

  { TFaceResourceList (instance size 20, VMT 557103D8) }
  TFaceResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure IndexOfFaceImage(A1: Integer);  { draft }
    procedure GetFaceResource(A1: Integer);  { draft }
    procedure PrevFace(A1: Integer);  { draft }
    procedure NextFace(A1: Integer);  { draft }
  end;

