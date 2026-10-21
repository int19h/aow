unit AoWGamePlayDlg;

{ Draft declarations of AoWGamePlayDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWComboBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TGamePlayDlg = class;


  { TGamePlayDlg (instance size 308, VMT 0042200C) }
  TGamePlayDlg = class(TDataModule)
  public
    published
    GamePlayDlg: TAOWWindow; { +0044 }
    CancelBtn: TAOWButton; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    Title: TAOWLabel; { +0050 }
    Close: TAOWButton; { +0054 }
    TCeltLR: TAOWImage; { +0058 }
    TCeltLL: TAOWImage; { +005C }
    TitleIcon: TAOWImage; { +0060 }
    AutoSaveCB: TAOWCheckBox; { +0064 }
    asLbl: TAOWLabel; { +0068 }
    SkipIntroCB: TAOWCheckBox; { +006C }
    siLbl: TAOWLabel; { +0070 }
    Tab1: TAOWTabPanel; { +0074 }
    Pnl1: TAOWPanel; { +0078 }
    Pnl2: TAOWPanel; { +007C }
    GamePasswordLbl: TAOWLabel; { +0080 }
    PasswordEdit: TAOWEdit; { +0084 }
    CombatResolveModeCB: TAOWComboBox; { +0088 }
    CombatResolveModeSB: TAOWVScrollBar; { +008C }
    Classic1CB: TAOWCheckBox; { +0090 }
    PopupLbl1: TAOWLabel; { +0094 }
    Classic2CB: TAOWCheckBox; { +0098 }
    PopupLbl2: TAOWLabel; { +009C }
    Classic3CB: TAOWCheckBox; { +00A0 }
    PopupLbl3: TAOWLabel; { +00A4 }
    Classic4CB: TAOWCheckBox; { +00A8 }
    Classic5CB: TAOWCheckBox; { +00AC }
    Classic6CB: TAOWCheckBox; { +00B0 }
    WindowPopupLbl: TAOWLabel; { +00B4 }
    ClassicLbl: TAOWLabel; { +00B8 }
    SimultaneousLbl: TAOWLabel; { +00BC }
    Sim1CB: TAOWCheckBox; { +00C0 }
    Sim2CB: TAOWCheckBox; { +00C4 }
    Sim3CB: TAOWCheckBox; { +00C8 }
    Sim4CB: TAOWCheckBox; { +00CC }
    Sim5CB: TAOWCheckBox; { +00D0 }
    Sim6CB: TAOWCheckBox; { +00D4 }
    PopupLbl4: TAOWLabel; { +00D8 }
    PopupLbl5: TAOWLabel; { +00DC }
    PopupLbl6: TAOWLabel; { +00E0 }
    Classic7CB: TAOWCheckBox; { +00E4 }
    Sim7CB: TAOWCheckBox; { +00E8 }
    PopupLbl7: TAOWLabel; { +00EC }
    ChangePasswordBtn: TAOWButton; { +00F0 }
    MovementSpeedCB: TAOWComboBox; { +00F4 }
    OKBtn: TAOWButton; { +00F8 }
    Classic8CB: TAOWCheckBox; { +00FC }
    Sim8CB: TAOWCheckBox; { +0100 }
    PopupLbl8: TAOWLabel; { +0104 }
    CombLbl: TAOWLabel; { +0108 }
    CombFr: TAOWPanel; { +010C }
    CombPnl: TAOWPanel; { +0110 }
    Movelbl: TAOWLabel; { +0114 }
    MovFr: TAOWPanel; { +0118 }
    BtmPnl: TAOWPanel; { +011C }
    MovPnl: TAOWPanel; { +0120 }
    AOWPanel1: TAOWPanel; { +0124 }
    CeltLineL: TAOWImage; { +0128 }
    Translator: TIvTranslator; { +012C }
    public
    F_GamePlayDlg_130: array[0..3] of Byte;
    procedure GamePlayDlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GamePlayDlgShow;  { draft }
    procedure ChangePasswordBtnClick;  { draft }
    procedure OKBtnClick;  { draft }
    procedure CancelClick;  { draft }
  end;


implementation

procedure TGamePlayDlg.GamePlayDlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TGamePlayDlg.GamePlayDlgShow;
begin end;

procedure TGamePlayDlg.ChangePasswordBtnClick;
begin end;

procedure TGamePlayDlg.OKBtnClick;
begin end;

procedure TGamePlayDlg.CancelClick;
begin end;


end.
