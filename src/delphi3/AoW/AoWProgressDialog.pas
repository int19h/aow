unit AoWProgressDialog;

{ Draft declarations of AoWProgressDialog, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWFrame, AoWImage, AoWLabel, AoWWindow;

type
  TProgressDialog = class;


  { TProgressDialog (instance size 108, VMT 004131A0) }
  TProgressDialog = class(TDataModule)
  public
    published
    Title: TAOWLabel; { +0044 }
    TCeltLineL: TAOWImage; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    StatusLbl: TAOWLabel; { +0050 }
    ProgDlg: TAOWWindow; { +0054 }
    Bar: TAoWGauge; { +0058 }
    TCeltL: TAoWFrame; { +005C }
    AOWImage1: TAOWImage; { +0060 }
    AOWImage2: TAOWImage; { +0064 }
    Translator: TIvTranslator; { +0068 }
    public
  end;


implementation


end.
