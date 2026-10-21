unit ResEForm;

{ Draft declarations of ResEForm, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TResourceEditForm = class;


  { TResourceEditForm (instance size 508, VMT 0040B99C) }
  TResourceEditForm = class(TForm)
  public
    published
    Panel1: TPanel; { +01DC }
    CancelBtn: TButton; { +01E0 }
    OKBtn: TButton; { +01E4 }
    Bevel2: TBevel; { +01E8 }
    public
    F_ResourceEditForm_1EC: Integer;
    F_ResourceEditForm_1F0: Integer;
    F_ResourceEditForm_1F4: Integer;
    F_ResourceEditForm_1F8: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    function vmt80(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer; virtual;  { +080 draft }
    procedure FormClose(A1: Integer; A2: Integer);  { draft }
  end;


implementation

constructor TResourceEditForm.Create(AOwner: Classes.TComponent);
begin end;

function TResourceEditForm.vmt80(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer;
begin Result := 0; end;

destructor TResourceEditForm.Destroy;
begin end;

procedure TResourceEditForm.FormClose(A1: Integer; A2: Integer);
begin end;


end.
