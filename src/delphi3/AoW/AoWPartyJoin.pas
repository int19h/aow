unit AoWPartyJoin;

{ Draft declarations of AoWPartyJoin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  TPartyJoinDlg = class;


  { TPartyJoinDlg (instance size 188, VMT 00437734) }
  TPartyJoinDlg = class(TDataModule)
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
    TitleIcon: TAOWImage; { +006C }
    Title: TAOWLabel; { +0070 }
    BCeltL: TAoWFrame; { +0074 }
    RightBtn: TAOWButton; { +0078 }
    LeftBtn: TAOWButton; { +007C }
    Dlg: TAOWWindow; { +0080 }
    UnitLine1: TAoWFrame; { +0084 }
    UnitLine2: TAoWFrame; { +0088 }
    JoinMemo: TAOWMemo; { +008C }
    Header: TAOWLabel; { +0090 }
    FaceFrame: TAOWImage; { +0094 }
    DetailsLbl: TAOWLabel; { +0098 }
    Close: TAOWButton; { +009C }
    Translator: TIvTranslator; { +00A0 }
    public
    F_PartyJoinDlg_A4: array[0..7] of Byte;
    F_PartyJoinDlg_AC: Byte;
    F_PartyJoinDlg_AD: array[0..2] of Byte;
    F_PartyJoinDlg_B0: Byte;
    F_PartyJoinDlg_B1: array[0..2] of Byte;
    F_PartyJoinDlg_B4: Integer;
    F_PartyJoinDlg_B8: Byte;
    F_PartyJoinDlg_B9: array[0..2] of Byte;
    procedure PartyJoinDlgCreate;  { draft }
    procedure PartyJoinDlgDestroy;  { draft }
    procedure LeftBtnClick;  { draft }
    procedure MiddleBtnClick;  { draft }
    procedure RightBtnClick;  { draft }
    procedure CloseClick;  { draft }
    procedure FaceFramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure U1PreDraw(A1: Integer; A2: Integer);  { draft }
    procedure U1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DlgHide;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TPartyJoinDlg.PartyJoinDlgCreate;
begin end;

procedure TPartyJoinDlg.PartyJoinDlgDestroy;
begin end;

procedure TPartyJoinDlg.LeftBtnClick;
begin end;

procedure TPartyJoinDlg.MiddleBtnClick;
begin end;

procedure TPartyJoinDlg.RightBtnClick;
begin end;

procedure TPartyJoinDlg.CloseClick;
begin end;

procedure TPartyJoinDlg.FaceFramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure TPartyJoinDlg.U1PreDraw(A1: Integer; A2: Integer);
begin end;

procedure TPartyJoinDlg.U1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TPartyJoinDlg.DlgHide;
begin end;

procedure TPartyJoinDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
