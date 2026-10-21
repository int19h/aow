unit AoWArenaDlg;

{ Draft declarations of AoWArenaDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow, aowUserDrawBox;

type
  TArenaDlg = class;


  { TArenaDlg (instance size 180, VMT 0044BDA8) }
  TArenaDlg = class(TDataModule)
  public
    published
    SelectBtn: TAOWButton; { +0044 }
    TitleIcon: TAOWImage; { +0048 }
    Close: TAOWButton; { +004C }
    Title: TAOWLabel; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    Dlg: TAOWWindow; { +0058 }
    UnitPnl: TAOWPanel; { +005C }
    MapViewPnl: TAOWPanel; { +0060 }
    U1: TAOWCheckBox; { +0064 }
    U2: TAOWCheckBox; { +0068 }
    U3: TAOWCheckBox; { +006C }
    U4: TAOWCheckBox; { +0070 }
    U5: TAOWCheckBox; { +0074 }
    U6: TAOWCheckBox; { +0078 }
    U7: TAOWCheckBox; { +007C }
    U8: TAOWCheckBox; { +0080 }
    DecoL: TAOWImage; { +0084 }
    DecoR: TAOWImage; { +0088 }
    AoWFrame1: TAoWFrame; { +008C }
    SelectionInfoPnl: TAOWPanel; { +0090 }
    SelectionInfoLbl: TAOWLabel; { +0094 }
    SelectionLbl: TAOWLabel; { +0098 }
    MapView: TaowUserDrawBox; { +009C }
    InfoSep: TAOWImage; { +00A0 }
    Translator: TIvTranslator; { +00A4 }
    public
    F_ArenaDlg_A8: Integer;
    F_ArenaDlg_AC: array[0..7] of Byte;
    procedure CloseClick;  { draft }
    procedure SelectBtnClick;  { draft }
    procedure U1Change(A1: Integer);  { draft }
    procedure U1PreDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgHide;  { draft }
    procedure MapViewDraw(A1: Integer; A2: Integer);  { draft }
    procedure MapViewUpdate;  { draft }
    procedure DlgDrawBack;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TArenaDlg.CloseClick;
begin end;

procedure TArenaDlg.SelectBtnClick;
begin end;

procedure TArenaDlg.U1Change(A1: Integer);
begin end;

procedure TArenaDlg.U1PreDraw(A1: Integer; A2: Integer);
begin end;

procedure TArenaDlg.DlgHide;
begin end;

procedure TArenaDlg.MapViewDraw(A1: Integer; A2: Integer);
begin end;

procedure TArenaDlg.MapViewUpdate;
begin end;

procedure TArenaDlg.DlgDrawBack;
begin end;

procedure TArenaDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
