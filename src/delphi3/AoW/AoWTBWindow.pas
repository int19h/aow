unit AoWTBWindow;

{ Draft declarations of AoWTBWindow, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenuBar, AoWButton, AoWCheckBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow, TurnButton;

type
  TTBWindow = class;


  { TTBWindow (instance size 324, VMT 00456CAC) }
  TTBWindow = class(TDataModule)
  public
    published
    TaskWindow: TAOWWindow; { +0044 }
    TBNextButton: TAOWButton; { +0048 }
    StartMenuBar: TAOWMenuBar; { +004C }
    TBMessEdit: TAOWEdit; { +0050 }
    WGILbl: TAOWLabel; { +0054 }
    WGTLbl: TAOWLabel; { +0058 }
    TurnButton: TAOWTurnButton; { +005C }
    WMButton: TAOWButton; { +0060 }
    OVButton: TAOWButton; { +0064 }
    ConButton: TAOWButton; { +0068 }
    StructButton: TAOWButton; { +006C }
    OV2Btn: TAOWButton; { +0070 }
    InfoBtn: TAOWButton; { +0074 }
    ChatBtn: TAOWButton; { +0078 }
    TaskPanel: TAOWPanel; { +007C }
    WGIPnl: TAOWPanel; { +0080 }
    TBbk: TAoWFrame; { +0084 }
    TimerImg: TAOWImage; { +0088 }
    TimeIcn: TAOWImage; { +008C }
    TimeLbl: TAOWLabel; { +0090 }
    PInd: TAoWFrame; { +0094 }
    CurP: TAOWImage; { +0098 }
    TBWorld: TAOWPanel; { +009C }
    TCNextBtn: TAOWButton; { +00A0 }
    TCStartBar: TAOWMenuBar; { +00A4 }
    TCMsg: TAOWEdit; { +00A8 }
    TCTurnButton: TAOWTurnButton; { +00AC }
    TCScannerBtn: TAOWButton; { +00B0 }
    TCUnitBtn: TAOWButton; { +00B4 }
    AoWFrame1: TAoWFrame; { +00B8 }
    TCTimerImg: TAOWImage; { +00BC }
    TCTimeImg: TAOWImage; { +00C0 }
    TCTimeLbl: TAOWLabel; { +00C4 }
    TCPInd: TAoWFrame; { +00C8 }
    TCCurP: TAOWImage; { +00CC }
    TBCombat: TAOWPanel; { +00D0 }
    TCPnl: TAOWPanel; { +00D4 }
    TCChatBtn: TAOWButton; { +00D8 }
    WGoldPnl: TAOWPanel; { +00DC }
    WGSign: TAOWLabel; { +00E0 }
    WMILbl: TAOWLabel; { +00E4 }
    WMTLbl: TAOWLabel; { +00E8 }
    WMIPnl: TAOWPanel; { +00EC }
    WManaPnl: TAOWPanel; { +00F0 }
    WMTSign: TAOWLabel; { +00F4 }
    TGILbl: TAOWLabel; { +00F8 }
    TGTLbl: TAOWLabel; { +00FC }
    TGIcn: TAOWImage; { +0100 }
    TGIPnl: TAOWPanel; { +0104 }
    TGoldPnl: TAOWPanel; { +0108 }
    TGSign: TAOWLabel; { +010C }
    TMILbl: TAOWLabel; { +0110 }
    TMTLbl: TAOWLabel; { +0114 }
    TWMIcn: TAOWImage; { +0118 }
    TMIPnl: TAOWPanel; { +011C }
    TManaPnl: TAOWPanel; { +0120 }
    TMTSign: TAOWLabel; { +0124 }
    RelationsBtn: TAOWButton; { +0128 }
    AutoBtn: TAOWCheckBox; { +012C }
    Translator: TIvTranslator; { +0130 }
    public
    F_TBWindow_134: Integer;
    F_TBWindow_138: Integer;
    F_TBWindow_13C: Word;
    F_TBWindow_13E: Word;
    F_TBWindow_140: Word;
    F_TBWindow_142: array[0..1] of Byte;
    procedure TurnButtonAnimDone;  { draft }
    procedure WMButtonClick;  { draft }
    procedure OVButtonClick(A1: Integer);  { draft }
    procedure ConButtonClick;  { draft }
    procedure StructButtonClick;  { draft }
    procedure TBNextButtonClick;  { draft }
    procedure UnitBtnClick;  { draft }
    procedure InfoBtnClick;  { draft }
    procedure ProdBtnClick;  { draft }
    procedure COBtnClick;  { draft }
    procedure ChatBtnClick;  { draft }
    procedure TurnButtonChange;  { draft }
    procedure PIndDraw(A1: Integer; A2: Integer);  { draft }
    procedure CurPUpdate;  { draft }
    procedure TCTurnButtonChange;  { draft }
    procedure TCTurnButtonAnimDone;  { draft }
    procedure TCPIndDraw(A1: Integer; A2: Integer);  { draft }
    procedure TCCurPUpdate;  { draft }
    procedure TCScannerBtnClick;  { draft }
    procedure TCNextBtnClick;  { draft }
    procedure TBWorldUpdate;  { draft }
    procedure TBCombatUpdate;  { draft }
    procedure OV2BtnClick;  { draft }
    procedure TCUnitBtnClick;  { draft }
    procedure StartMenuBarChange;  { draft }
    procedure RelationsBtnClick;  { draft }
    procedure ChatBtnUpdate(A1: Integer);  { draft }
    procedure AutoBtn2Click;  { draft }
  end;


implementation

procedure TTBWindow.TurnButtonAnimDone;
begin end;

procedure TTBWindow.WMButtonClick;
begin end;

procedure TTBWindow.OVButtonClick(A1: Integer);
begin end;

procedure TTBWindow.ConButtonClick;
begin end;

procedure TTBWindow.StructButtonClick;
begin end;

procedure TTBWindow.TBNextButtonClick;
begin end;

procedure TTBWindow.UnitBtnClick;
begin end;

procedure TTBWindow.InfoBtnClick;
begin end;

procedure TTBWindow.ProdBtnClick;
begin end;

procedure TTBWindow.COBtnClick;
begin end;

procedure TTBWindow.ChatBtnClick;
begin end;

procedure TTBWindow.TurnButtonChange;
begin end;

procedure TTBWindow.PIndDraw(A1: Integer; A2: Integer);
begin end;

procedure TTBWindow.CurPUpdate;
begin end;

procedure TTBWindow.TCTurnButtonChange;
begin end;

procedure TTBWindow.TCTurnButtonAnimDone;
begin end;

procedure TTBWindow.TCPIndDraw(A1: Integer; A2: Integer);
begin end;

procedure TTBWindow.TCCurPUpdate;
begin end;

procedure TTBWindow.TCScannerBtnClick;
begin end;

procedure TTBWindow.TCNextBtnClick;
begin end;

procedure TTBWindow.TBWorldUpdate;
begin end;

procedure TTBWindow.TBCombatUpdate;
begin end;

procedure TTBWindow.OV2BtnClick;
begin end;

procedure TTBWindow.TCUnitBtnClick;
begin end;

procedure TTBWindow.StartMenuBarChange;
begin end;

procedure TTBWindow.RelationsBtnClick;
begin end;

procedure TTBWindow.ChatBtnUpdate(A1: Integer);
begin end;

procedure TTBWindow.AutoBtn2Click;
begin end;


end.
