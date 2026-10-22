unit SplashFrm;

{ Draft declarations of SplashFrm, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  No added instance fields; image and labels occupy $1DC through $1EC. }

{$R+,Q+}

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
    published procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
    published procedure Image1Click(Sender: TObject); public
    published procedure FormCreate(Sender: TObject); public
  end;


implementation

uses AoWE, MDIForm;

procedure TSplashForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  ModalResult := mrOK;
end;

procedure TSplashForm.Image1Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TSplashForm.FormCreate(Sender: TObject);
begin
  VersionLbl.Caption := GetEditorVersion;
  Image1.Picture.LoadFromFile(AoWEngine.StartupDirectory + 'EDIMAGES\SPLASH.BMP');
end;

end.
