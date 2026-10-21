unit TCFCDlg;

{ Draft declarations of TCFCDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow, aowUserDrawBox;

type
  TTCFCDialog = class;


  { TTCFCDialog (instance size 152, VMT 00439834) }
  TTCFCDialog = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    DTitle: TAOWLabel; { +0048 }
    DMessage: TAOWLabel; { +004C }
    FightBtn: TAOWButton; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    BCeltL: TAoWFrame; { +0058 }
    TCeltL: TAoWFrame; { +005C }
    TCeltLineL: TAOWImage; { +0060 }
    AOWImage1: TAOWImage; { +0064 }
    AOWImage2: TAOWImage; { +0068 }
    Tactical: TAOWLabel; { +006C }
    Automatic: TAOWLabel; { +0070 }
    TCchk: TAOWCheckBox; { +0074 }
    FCchk: TAOWCheckBox; { +0078 }
    MapViewPnl: TAOWPanel; { +007C }
    MapView: TaowUserDrawBox; { +0080 }
    InfoSep: TAOWImage; { +0084 }
    Translator: TIvTranslator; { +0088 }
    public
    F_TCFCDialog_8C: Integer;
    F_TCFCDialog_90: array[0..7] of Byte;
    procedure CancelBtnClick;  { draft }
    procedure FightBtnClick;  { draft }
    procedure FCchkChange(A1: Integer);  { draft }
    procedure TCchkChange(A1: Integer);  { draft }
    procedure MapViewDraw(A1: Integer; A2: Integer);  { draft }
    procedure MapViewUpdate;  { draft }
    procedure DlgHide;  { draft }
    procedure TCchkDoubleClick(A1: Integer);  { draft }
    procedure FCchkDoubleClick(A1: Integer);  { draft }
  end;


implementation

procedure TTCFCDialog.CancelBtnClick;
begin end;

procedure TTCFCDialog.FightBtnClick;
begin end;

procedure TTCFCDialog.FCchkChange(A1: Integer);
begin end;

procedure TTCFCDialog.TCchkChange(A1: Integer);
begin end;

procedure TTCFCDialog.MapViewDraw(A1: Integer; A2: Integer);
begin end;

procedure TTCFCDialog.MapViewUpdate;
begin end;

procedure TTCFCDialog.DlgHide;
begin end;

procedure TTCFCDialog.TCchkDoubleClick(A1: Integer);
begin end;

procedure TTCFCDialog.FCchkDoubleClick(A1: Integer);
begin end;


end.
