unit SplashFrm;

{ Draft declarations of SplashFrm, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TSplashForm = class;


  { TSplashForm (instance size 496, VMT 00420B18) }
  TSplashForm = class(TForm)
  public
    published
    Image1: TImage; { +01DC }
    VersionLbl: TLabel; { +01E0 }
    StatusLabel: TLabel; { +01E4 }
    Label1: TLabel; { +01E8 }
    Translator: TIvTranslator; { +01EC }
    public
    procedure FormKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure Image1Click;  { draft }
    procedure FormCreate;  { draft }
  end;


implementation

procedure TSplashForm.FormKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSplashForm.Image1Click;
begin end;

procedure TSplashForm.FormCreate;
begin end;


end.
