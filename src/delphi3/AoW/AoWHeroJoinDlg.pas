unit AoWHeroJoinDlg;

{ Draft declarations of AoWHeroJoinDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  THeroJoinDlg = class;


  { THeroJoinDlg (instance size 172, VMT 004382E8) }
  THeroJoinDlg = class(TDataModule)
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
    MiddleBtn: TAOWButton; { +0068 }
    BCeltL: TAoWFrame; { +006C }
    RightBtn: TAOWButton; { +0070 }
    LeftBtn: TAOWButton; { +0074 }
    Dlg: TAOWWindow; { +0078 }
    HeroName: TAOWLabel; { +007C }
    HeroLevel: TAOWLabel; { +0080 }
    FaceFrame: TAOWImage; { +0084 }
    DetailsLbl: TAOWLabel; { +0088 }
    JoinMemo: TAOWMemo; { +008C }
    Translator: TIvTranslator; { +0090 }
    public
    F_HeroJoinDlg_94: array[0..7] of Byte;
    F_HeroJoinDlg_9C: Byte;
    F_HeroJoinDlg_9D: array[0..2] of Byte;
    F_HeroJoinDlg_A0: Byte;
    F_HeroJoinDlg_A1: array[0..2] of Byte;
    F_HeroJoinDlg_A4: Integer;
    F_HeroJoinDlg_A8: Byte;
    F_HeroJoinDlg_A9: array[0..2] of Byte;
    procedure HeroJoinDlgCreate;  { draft }
    procedure HeroJoinDlgDestroy;  { draft }
    procedure LeftBtnClick;  { draft }
    procedure MiddleBtnClick;  { draft }
    procedure RightBtnClick;  { draft }
    procedure FaceFramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure U1PreDraw(A1: Integer; A2: Integer);  { draft }
    procedure U1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DlgHide;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure THeroJoinDlg.HeroJoinDlgCreate;
begin end;

procedure THeroJoinDlg.HeroJoinDlgDestroy;
begin end;

procedure THeroJoinDlg.LeftBtnClick;
begin end;

procedure THeroJoinDlg.MiddleBtnClick;
begin end;

procedure THeroJoinDlg.RightBtnClick;
begin end;

procedure THeroJoinDlg.FaceFramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure THeroJoinDlg.U1PreDraw(A1: Integer; A2: Integer);
begin end;

procedure THeroJoinDlg.U1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure THeroJoinDlg.DlgHide;
begin end;

procedure THeroJoinDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
