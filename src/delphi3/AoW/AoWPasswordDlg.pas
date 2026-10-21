unit AoWPasswordDlg;

{ Draft declarations of AoWPasswordDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TPasswordDlg = class;


  { TPasswordDlg (instance size 124, VMT 0044DEA4) }
  TPasswordDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    TCeltL: TAoWFrame; { +0050 }
    TCeltLineL: TAOWImage; { +0054 }
    OKCancelPnl: TAOWPanel; { +0058 }
    OKBtn: TAOWButton; { +005C }
    CancelBtn: TAOWButton; { +0060 }
    PasswordLbl: TAOWLabel; { +0064 }
    PasswordEdit: TAOWEdit; { +0068 }
    Translator: TIvTranslator; { +006C }
    public
    F_PasswordDlg_70: array[0..7] of Byte;
    F_PasswordDlg_78: Integer;
    procedure DlgHide;  { draft }
    procedure OKBtnClick;  { draft }
    procedure CancelBtnClick;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TPasswordDlg.DlgHide;
begin end;

procedure TPasswordDlg.OKBtnClick;
begin end;

procedure TPasswordDlg.CancelBtnClick;
begin end;

procedure TPasswordDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
