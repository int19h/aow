unit ValidateMapDlg;

{ Draft declarations of ValidateMapDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TMapValidationDlg = class;


  { TMapValidationDlg (instance size 492, VMT 00424424) }
  TMapValidationDlg = class(TForm)
  public
    published
    Memo: TMemo; { +01DC }
    ButtonPnl: TPanel; { +01E0 }
    OKBtn: TButton; { +01E4 }
    Translator: TIvTranslator; { +01E8 }
    public
  end;


implementation


end.
