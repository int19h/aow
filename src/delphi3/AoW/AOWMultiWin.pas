unit AOWMultiWin;

{ Draft declarations of AOWMultiWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll;

type
  TMultiWindow = class;


  { TMultiWindow (instance size 244, VMT 0042A6C4) }
  TMultiWindow = class(TDataModule)
  public
    published
    JoinPnl: TAOWPanel; { +0044 }
    GamesLB: TAOWListBox; { +0048 }
    GLBvsc: TAOWVScrollBar; { +004C }
    JoinBtn: TAOWButton; { +0050 }
    MultiPnl: TAOWPanel; { +0054 }
    BackBtn: TAOWButton; { +0058 }
    GamePanel: TAOWPanel; { +005C }
    TCPBtn: TAOWButton; { +0060 }
    IPXBtn: TAOWButton; { +0064 }
    SingleBtn: TAOWButton; { +0068 }
    EmailBtn: TAOWButton; { +006C }
    TCPPnl: TAOWPanel; { +0070 }
    TCPNameLbl: TAOWLabel; { +0074 }
    Single: TAOWLabel; { +0078 }
    Address: TAOWLabel; { +007C }
    CancelTCP: TAOWButton; { +0080 }
    Host: TAOWButton; { +0084 }
    Find: TAOWButton; { +0088 }
    GameLbl: TAOWLabel; { +008C }
    TCPName: TAOWEdit; { +0090 }
    IPEdit: TAOWEdit; { +0094 }
    LanPnl: TAOWPanel; { +0098 }
    LANFind: TAOWButton; { +009C }
    JoinLbl: TAOWLabel; { +00A0 }
    BottomPnl: TAOWPanel; { +00A4 }
    BackButn: TAOWButton; { +00A8 }
    MsgPnl: TAOWPanel; { +00AC }
    CancelOKBut: TAOWButton; { +00B0 }
    MessageMemo: TAOWMemo; { +00B4 }
    LANCancel: TAOWButton; { +00B8 }
    AOWLabel1: TAOWLabel; { +00BC }
    LANLbl: TAOWLabel; { +00C0 }
    IPXName: TAOWEdit; { +00C4 }
    LANHost: TAOWButton; { +00C8 }
    PBEMPnl: TAOWPanel; { +00CC }
    CancelPBEMBtn: TAOWButton; { +00D0 }
    CheckEmailBtn: TAOWButton; { +00D4 }
    NewPBEMGameBtn: TAOWButton; { +00D8 }
    LoadPBEMGameBtn: TAOWButton; { +00DC }
    EmailSettingsBtn: TAOWButton; { +00E0 }
    HeatNetBtn: TAOWButton; { +00E4 }
    Translator: TIvTranslator; { +00E8 }
    public
    F_MultiWindow_EC: Integer;
    F_MultiWindow_F0: Integer;
    procedure CloseBtnClick;  { draft }
    procedure MultiWinUpdate;  { draft }
    procedure JoinBtnClick;  { draft }
    procedure GamesLBChange;  { draft }
    procedure BackBtnClick;  { draft }
    procedure TCPBtnClick;  { draft }
    procedure IPXBtnClick;  { draft }
    procedure CancelTCPClick;  { draft }
    procedure FindClick;  { draft }
    procedure HostClick;  { draft }
    procedure IPXNameChange;  { draft }
    procedure TCPNameChange;  { draft }
    procedure LANFindClick;  { draft }
    procedure LANHostClick;  { draft }
    procedure SingleBtnClick;  { draft }
    procedure ModemBtnClick;  { draft }
    procedure DirectBtnClick;  { draft }
    procedure EmailBtnClick;  { draft }
    procedure CancelOKButClick;  { draft }
    procedure CancelPBEMBtnClick;  { draft }
    procedure CheckEmailBtnClick;  { draft }
    procedure NewPBEMGameBtnClick;  { draft }
    procedure LoadPBEMGameBtnClick;  { draft }
    procedure EmailSettingsBtnClick;  { draft }
    procedure HeatNetBtnClick;  { draft }
  end;


implementation

procedure TMultiWindow.CloseBtnClick;
begin end;

procedure TMultiWindow.MultiWinUpdate;
begin end;

procedure TMultiWindow.JoinBtnClick;
begin end;

procedure TMultiWindow.GamesLBChange;
begin end;

procedure TMultiWindow.BackBtnClick;
begin end;

procedure TMultiWindow.TCPBtnClick;
begin end;

procedure TMultiWindow.IPXBtnClick;
begin end;

procedure TMultiWindow.CancelTCPClick;
begin end;

procedure TMultiWindow.FindClick;
begin end;

procedure TMultiWindow.HostClick;
begin end;

procedure TMultiWindow.IPXNameChange;
begin end;

procedure TMultiWindow.TCPNameChange;
begin end;

procedure TMultiWindow.LANFindClick;
begin end;

procedure TMultiWindow.LANHostClick;
begin end;

procedure TMultiWindow.SingleBtnClick;
begin end;

procedure TMultiWindow.ModemBtnClick;
begin end;

procedure TMultiWindow.DirectBtnClick;
begin end;

procedure TMultiWindow.EmailBtnClick;
begin end;

procedure TMultiWindow.CancelOKButClick;
begin end;

procedure TMultiWindow.CancelPBEMBtnClick;
begin end;

procedure TMultiWindow.CheckEmailBtnClick;
begin end;

procedure TMultiWindow.NewPBEMGameBtnClick;
begin end;

procedure TMultiWindow.LoadPBEMGameBtnClick;
begin end;

procedure TMultiWindow.EmailSettingsBtnClick;
begin end;

procedure TMultiWindow.HeatNetBtnClick;
begin end;


end.
