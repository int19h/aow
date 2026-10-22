unit AboutDialog;

{ Draft declarations of AboutDialog, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAboutDlg = class;


  { TAboutDlg (instance size 508, VMT 0042E08C) }
  TAboutDlg = class(TForm)
  public
    published
    Panel1: TPanel; { +01DC }
    OKButton: TButton; { +01E0 }
    Label1: TLabel; { +01E4 }
    Image2: TImage; { +01E8 }
    VersionLbl: TLabel; { +01EC }
    Label2: TLabel; { +01F0 }
    Bevel1: TBevel; { +01F4 }
    Translator: TIvTranslator; { +01F8 }
    public
    published procedure FormCreate(Sender: TObject); public
  end;


implementation

uses MDIForm;

procedure TAboutDlg.FormCreate(Sender: TObject);
begin
  VersionLbl.Caption := GetEditorVersion;
end;


end.
