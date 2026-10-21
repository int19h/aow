unit NewMapDialog;

{ Draft declarations of NewMapDialog, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TNewMapDlg = class;


  { TNewMapDlg (instance size 552, VMT 004031C0) }
  TNewMapDlg = class(TForm)
  public
    published
    Panel1: TPanel; { +01DC }
    CancelBtn: TButton; { +01E0 }
    OKBtn: TButton; { +01E4 }
    ClientPnl: TPanel; { +01E8 }
    MainPageControl: TPageControl; { +01EC }
    GeneralSheet: TTabSheet; { +01F0 }
    Bevel1: TBevel; { +01F4 }
    MapSizePnl: TPanel; { +01F8 }
    ExtraLargeRB: TRadioButton; { +01FC }
    LargeRB: TRadioButton; { +0200 }
    MediumRB: TRadioButton; { +0204 }
    SmallRB: TRadioButton; { +0208 }
    Label1: TLabel; { +020C }
    MapLevelPnl: TPanel; { +0210 }
    Label2: TLabel; { +0214 }
    OneLevel: TRadioButton; { +0218 }
    TwoLevels: TRadioButton; { +021C }
    ThreeLevels: TRadioButton; { +0220 }
    Translator: TIvTranslator; { +0224 }
    public
    procedure OKBtnClick;  { draft }
  end;


implementation

procedure TNewMapDlg.OKBtnClick;
begin end;


end.
