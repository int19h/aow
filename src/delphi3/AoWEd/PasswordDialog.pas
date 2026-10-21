unit PasswordDialog;

{ Draft declarations of PasswordDialog, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TPasswordDlg = class;


  { TPasswordDlg (instance size 496, VMT 00421F34) }
  TPasswordDlg = class(TForm)
  public
    published
    EnterPasswordLbl: TLabel; { +01DC }
    PasswordEdit: TEdit; { +01E0 }
    OKBtn: TButton; { +01E4 }
    CancelBtn: TButton; { +01E8 }
    Translator: TIvTranslator; { +01EC }
    public
  end;


resourcestring
  UniqueRacesRStr = 'Please make sure that all players have an unique race!';

implementation


end.
