unit AoWHeroInfoDlg;

{ Draft declarations of AoWHeroInfoDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  THeroInfoDlg = class;


  { THeroInfoDlg (instance size 156, VMT 00447CEC) }
  THeroInfoDlg = class(TDataModule)
  public
    published
    UnitPnl: TAOWPanel; { +0044 }
    U1: TAoWFrame; { +0048 }
    U2: TAoWFrame; { +004C }
    U4: TAoWFrame; { +0050 }
    U5: TAoWFrame; { +0054 }
    U3: TAoWFrame; { +0058 }
    U6: TAoWFrame; { +005C }
    U7: TAoWFrame; { +0060 }
    U8: TAoWFrame; { +0064 }
    CloseBtn: TAOWButton; { +0068 }
    BCeltL: TAoWFrame; { +006C }
    Dlg: TAOWWindow; { +0070 }
    HeroName: TAOWLabel; { +0074 }
    HeroLevel: TAOWLabel; { +0078 }
    FaceFrame: TAOWImage; { +007C }
    DetailsLbl: TAOWLabel; { +0080 }
    Message: TAOWMemo; { +0084 }
    Translator: TIvTranslator; { +0088 }
    public
    F_HeroInfoDlg_8C: array[0..7] of Byte;
    F_HeroInfoDlg_94: Integer;
    F_HeroInfoDlg_98: Byte;
    F_HeroInfoDlg_99: array[0..2] of Byte;
    procedure CloseBtnClick;  { draft }
    procedure FaceFramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure U1PreDraw(A1: Integer; A2: Integer);  { draft }
    procedure U1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DlgHide;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure THeroInfoDlg.CloseBtnClick;
begin end;

procedure THeroInfoDlg.FaceFramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure THeroInfoDlg.U1PreDraw(A1: Integer; A2: Integer);
begin end;

procedure THeroInfoDlg.U1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure THeroInfoDlg.DlgHide;
begin end;

procedure THeroInfoDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
