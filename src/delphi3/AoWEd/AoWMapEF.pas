unit AoWMapEF;

{ Draft declarations of AoWMapEF, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWMapEditForm = class;


  { TAoWMapEditForm (instance size 516, VMT 00417174; $1F0 FPositionInfo, $1FC FEditObject) }
  TAoWMapEditForm = class(TForm)
  public
    published
    ClientPnl: TPanel; { +01DC }
    ButtonPnl: TPanel; { +01E0 }
    OKBtn: TButton; { +01E4 }
    CancelBtn: TButton; { +01E8 }
    Translator: TIvTranslator; { +01EC }
    public
    FPositionInfo: PPoint; { $1F0 }
    F_AoWMapEditForm_1F4: Integer;
    F_AoWMapEditForm_1F8: Integer;
    FEditObject: TEObject; { $1FC }
    F_AoWMapEditForm_200: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure SetPositionInfo(Info: PPoint);
    procedure vmt80; virtual;  { +080 draft }
    procedure vmt84; virtual;  { +084 draft }
    procedure vmt88; virtual;  { +088 draft }
    procedure vmt8C; virtual;  { +08C draft }
    function vmt90(A1: Byte; A2: Integer; A3: Integer; A4: Integer): Integer; virtual;  { +090 draft }
    procedure FormClose(A1: Integer; A2: Integer);  { draft }
    procedure FormShow;  { draft }
    procedure OKBtnClick(Sender: TObject);
  end;


implementation

constructor TAoWMapEditForm.Create(AOwner: Classes.TComponent);
begin end;

procedure TAoWMapEditForm.vmt80;
begin end;

procedure TAoWMapEditForm.vmt84;
begin end;

function TAoWMapEditForm.vmt90(A1: Byte; A2: Integer; A3: Integer; A4: Integer): Integer;
begin Result := 0; end;

destructor TAoWMapEditForm.Destroy;
begin end;

procedure TAoWMapEditForm.vmt88;
begin end;

procedure TAoWMapEditForm.vmt8C;
begin end;

procedure TAoWMapEditForm.FormClose(A1: Integer; A2: Integer);
begin end;

procedure TAoWMapEditForm.FormShow;
begin end;

procedure TAoWMapEditForm.OKBtnClick(Sender: TObject);
begin end;


procedure TAoWMapEditForm.SetPositionInfo(Info: PPoint);
begin
  FPositionInfo := Info;
end;

end.
