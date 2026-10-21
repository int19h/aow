unit AoWEmailGameSettingsDlg;

{ Draft declarations of AoWEmailGameSettingsDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWVScroll, AoWWindow;

type
  TEmailGameSettingsDlg = class;


  { TEmailGameSettingsDlg (instance size 232, VMT 0040EFAC) }
  TEmailGameSettingsDlg = class(TDataModule)
  public
    published
    OKBtn: TAOWButton; { +0044 }
    TitleIcon: TAOWImage; { +0048 }
    Title: TAOWLabel; { +004C }
    CancelBut: TAOWButton; { +0050 }
    Dlg: TAOWWindow; { +0054 }
    LocalEmailAdressLbl: TAOWLabel; { +0058 }
    DecoL: TAOWImage; { +005C }
    DecoR: TAOWImage; { +0060 }
    AoWFrame1: TAoWFrame; { +0064 }
    LocalEmailAddressEdit: TAOWEdit; { +0068 }
    PlayerEMailAddressesLbl: TAOWLabel; { +006C }
    EmailAddressEdit1: TAOWEdit; { +0070 }
    PlayerPnl: TAOWPanel; { +0074 }
    PlayerLbl1: TAOWLabel; { +0078 }
    PlayerSB: TAOWVScrollBar; { +007C }
    PlayerLbl2: TAOWLabel; { +0080 }
    PlayerLbl3: TAOWLabel; { +0084 }
    EmailAddressEdit2: TAOWEdit; { +0088 }
    EmailAddressEdit3: TAOWEdit; { +008C }
    PlayerLbl4: TAOWLabel; { +0090 }
    EmailAddressEdit4: TAOWEdit; { +0094 }
    EmailGameNameLbl: TAOWLabel; { +0098 }
    EmailGameNameEdit: TAOWEdit; { +009C }
    SettingsBtn: TAOWButton; { +00A0 }
    Player1Pnl: TAOWPanel; { +00A4 }
    PowePnl: TAOWPanel; { +00A8 }
    Player2Pnl: TAOWPanel; { +00AC }
    Player3Pnl: TAOWPanel; { +00B0 }
    Player4Pnl: TAOWPanel; { +00B4 }
    PlayerLbl5: TAOWLabel; { +00B8 }
    EmailAddressEdit5: TAOWEdit; { +00BC }
    PlayerLbl6: TAOWLabel; { +00C0 }
    EmailAddressEdit6: TAOWEdit; { +00C4 }
    Player5Pnl: TAOWPanel; { +00C8 }
    Player6Pnl: TAOWPanel; { +00CC }
    NamePnl: TAOWPanel; { +00D0 }
    LocalPnl: TAOWPanel; { +00D4 }
    CloseBtn: TAOWButton; { +00D8 }
    Translator: TIvTranslator; { +00DC }
    public
    F_EmailGameSettingsDlg_E0: Integer;
    F_EmailGameSettingsDlg_E4: Integer;
    procedure EmailGameSettingsDlgCreate;  { draft }
    procedure EmailGameSettingsDlgDestroy;  { draft }
    procedure PlayerSBChange;  { draft }
    procedure EmailAddressEdit1Change(A1: Integer);  { draft }
    procedure OKBtnClick;  { draft }
    procedure CancelButClick;  { draft }
    procedure SettingsBtnClick;  { draft }
    procedure LocalEmailAddressEditUpdate;  { draft }
    procedure Player6PnlDrawBack(A1: Integer; A2: Integer);  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TEmailGameSettingsDlg.EmailGameSettingsDlgCreate;
begin end;

procedure TEmailGameSettingsDlg.EmailGameSettingsDlgDestroy;
begin end;

procedure TEmailGameSettingsDlg.PlayerSBChange;
begin end;

procedure TEmailGameSettingsDlg.EmailAddressEdit1Change(A1: Integer);
begin end;

procedure TEmailGameSettingsDlg.OKBtnClick;
begin end;

procedure TEmailGameSettingsDlg.CancelButClick;
begin end;

procedure TEmailGameSettingsDlg.SettingsBtnClick;
begin end;

procedure TEmailGameSettingsDlg.LocalEmailAddressEditUpdate;
begin end;

procedure TEmailGameSettingsDlg.Player6PnlDrawBack(A1: Integer; A2: Integer);
begin end;

procedure TEmailGameSettingsDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
