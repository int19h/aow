unit AoWArmyInfoDlg;

{ Draft declarations of AoWArmyInfoDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  TArmyInfoDlg = class;


  { TArmyInfoDlg (instance size 172, VMT 004475A0) }
  TArmyInfoDlg = class(TDataModule)
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
    TitleIcon: TAOWImage; { +006C }
    Close: TAOWButton; { +0070 }
    Title: TAOWLabel; { +0074 }
    BCeltL: TAoWFrame; { +0078 }
    Dlg: TAOWWindow; { +007C }
    UnitLine1: TAoWFrame; { +0080 }
    UnitLine2: TAoWFrame; { +0084 }
    Message: TAOWMemo; { +0088 }
    FaceFrame: TAOWImage; { +008C }
    DetailsLbl: TAOWLabel; { +0090 }
    HeaderLbl: TAOWLabel; { +0094 }
    Translator: TIvTranslator; { +0098 }
    public
    F_ArmyInfoDlg_9C: Byte;
    F_ArmyInfoDlg_9D: array[0..10] of Byte;
    F_ArmyInfoDlg_A8: Integer;
    procedure CloseBtnClick;  { draft }
    procedure CloseClick;  { draft }
    procedure U1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure U1PreDraw(A1: Integer; A2: Integer);  { draft }
    procedure FaceFramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgHide;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TArmyInfoDlg.CloseBtnClick;
begin end;

procedure TArmyInfoDlg.CloseClick;
begin end;

procedure TArmyInfoDlg.U1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TArmyInfoDlg.U1PreDraw(A1: Integer; A2: Integer);
begin end;

procedure TArmyInfoDlg.FaceFramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure TArmyInfoDlg.DlgHide;
begin end;

procedure TArmyInfoDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
