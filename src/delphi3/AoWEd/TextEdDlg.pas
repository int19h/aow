unit TextEdDlg;

{ Draft declarations of TextEdDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TTextEditDlg = class;


  { TTextEditDlg (instance size 488, VMT 00421634) }
  TTextEditDlg = class(TForm)
  public
    published
    OKBtn: TButton; { +01DC }
    CancelBtn: TButton; { +01E0 }
    Memo: TMemo; { +01E4 }
    public
  end;


implementation


end.
