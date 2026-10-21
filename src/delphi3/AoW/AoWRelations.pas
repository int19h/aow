unit AoWRelations;

{ Draft declarations of AoWRelations, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TRelWindow = class;


  { TRelWindow (instance size 680, VMT 00423988) }
  TRelWindow = class(TDataModule)
  public
    published
    RelWin: TAOWWindow; { +0044 }
    RShield: TAOWImage; { +0048 }
    LShield: TAOWImage; { +004C }
    MExitBtn: TAOWButton; { +0050 }
    RelPnl: TAOWPanel; { +0054 }
    RIncomingPnl: TAOWPanel; { +0058 }
    MAcceptBtn: TAOWButton; { +005C }
    MRejectBtn: TAOWButton; { +0060 }
    MScroll: TAOWVScrollBar; { +0064 }
    P1I: TAOWImage; { +0068 }
    P2I: TAOWImage; { +006C }
    P3I: TAOWImage; { +0070 }
    P4I: TAOWImage; { +0074 }
    P5I: TAOWImage; { +0078 }
    P6I: TAOWImage; { +007C }
    P7I: TAOWImage; { +0080 }
    P8I: TAOWImage; { +0084 }
    P9I: TAOWImage; { +0088 }
    P10I: TAOWImage; { +008C }
    P11I: TAOWImage; { +0090 }
    P12I: TAOWImage; { +0094 }
    R1I: TAOWImage; { +0098 }
    R2I: TAOWImage; { +009C }
    R3I: TAOWImage; { +00A0 }
    R4I: TAOWImage; { +00A4 }
    R5I: TAOWImage; { +00A8 }
    R6I: TAOWImage; { +00AC }
    R7I: TAOWImage; { +00B0 }
    R8I: TAOWImage; { +00B4 }
    R9I: TAOWImage; { +00B8 }
    R10I: TAOWImage; { +00BC }
    R11I: TAOWImage; { +00C0 }
    R12I: TAOWImage; { +00C4 }
    FaceShadow: TAOWImage; { +00C8 }
    MMemo: TAOWMemo; { +00CC }
    MBGoldLbl: TAOWLabel; { +00D0 }
    MIcon: TAOWImage; { +00D4 }
    RMsgEditPnl: TAOWPanel; { +00D8 }
    RSBribePnl: TAOWPanel; { +00DC }
    SScroll: TAOWVScrollBar; { +00E0 }
    SMemo: TAOWMemo; { +00E4 }
    SBGoldSlid: TAOWHScrollBar; { +00E8 }
    ActionPnl: TAOWPanel; { +00EC }
    LInfoPlayerPnl: TAOWPanel; { +00F0 }
    RNewActionPnl: TAOWPanel; { +00F4 }
    AExit: TAOWButton; { +00F8 }
    APlayer: TAOWLabel; { +00FC }
    LInfoRacePnl: TAOWPanel; { +0100 }
    ARace2: TAOWLabel; { +0104 }
    AAlignment: TAOWImage; { +0108 }
    AAlignmentLbl: TAOWLabel; { +010C }
    P1CB: TAOWCheckBox; { +0110 }
    P2CB: TAOWCheckBox; { +0114 }
    P3CB: TAOWCheckBox; { +0118 }
    P4CB: TAOWCheckBox; { +011C }
    P5CB: TAOWCheckBox; { +0120 }
    P6CB: TAOWCheckBox; { +0124 }
    P7CB: TAOWCheckBox; { +0128 }
    P8CB: TAOWCheckBox; { +012C }
    P9CB: TAOWCheckBox; { +0130 }
    P10CB: TAOWCheckBox; { +0134 }
    P11CB: TAOWCheckBox; { +0138 }
    P12CB: TAOWCheckBox; { +013C }
    FaceFr: TAOWImage; { +0140 }
    R1CB: TAOWCheckBox; { +0144 }
    R2CB: TAOWCheckBox; { +0148 }
    R3CB: TAOWCheckBox; { +014C }
    R4CB: TAOWCheckBox; { +0150 }
    R5CB: TAOWCheckBox; { +0154 }
    R6CB: TAOWCheckBox; { +0158 }
    R7CB: TAOWCheckBox; { +015C }
    R8CB: TAOWCheckBox; { +0160 }
    R9CB: TAOWCheckBox; { +0164 }
    R10CB: TAOWCheckBox; { +0168 }
    R11CB: TAOWCheckBox; { +016C }
    R12CB: TAOWCheckBox; { +0170 }
    PlyrGlow: TAOWImage; { +0174 }
    NoContact: TAOWLabel; { +0178 }
    ASelect: TAOWButton; { +017C }
    ActionsLB: TAOWListBox; { +0180 }
    ActionSB: TAOWVScrollBar; { +0184 }
    LBActionsPnl: TAOWPanel; { +0188 }
    ActionLbl: TAOWLabel; { +018C }
    PIRelIcn: TAOWImage; { +0190 }
    PIRelLbl: TAOWLabel; { +0194 }
    PIRelPnl: TAOWPanel; { +0198 }
    PIRelV: TAOWLabel; { +019C }
    APlyrIcon: TAOWImage; { +01A0 }
    APlyrType: TAOWLabel; { +01A4 }
    PlStatIcn: TAOWImage; { +01A8 }
    PlStatLbl: TAOWLabel; { +01AC }
    PIStatPnl: TAOWPanel; { +01B0 }
    PlStatV: TAOWLabel; { +01B4 }
    PTypePnl: TAOWPanel; { +01B8 }
    PIFrame: TAOWPanel; { +01BC }
    RIFrame: TAOWPanel; { +01C0 }
    RIRelPnl: TAOWPanel; { +01C4 }
    RAlignPnl: TAOWPanel; { +01C8 }
    RlRelIcn: TAOWImage; { +01CC }
    RIRelLbl: TAOWLabel; { +01D0 }
    RlRelV: TAOWLabel; { +01D4 }
    MBGoldBribeV: TAOWLabel; { +01D8 }
    MBGoldIcn: TAOWImage; { +01DC }
    MBGoldPnl: TAOWPanel; { +01E0 }
    MBManaPnl: TAOWPanel; { +01E4 }
    MBManaLbl: TAOWLabel; { +01E8 }
    MBManaBribeV: TAOWLabel; { +01EC }
    MBManaIcn: TAOWImage; { +01F0 }
    MsgLbl: TAOWLabel; { +01F4 }
    MsgSendBtn: TAOWButton; { +01F8 }
    MsgCancelBtn: TAOWButton; { +01FC }
    RSBribe2: TAoWFrame; { +0200 }
    SBGoldV: TAOWLabel; { +0204 }
    SBGoldIcn: TAOWImage; { +0208 }
    SBGold: TAOWPanel; { +020C }
    SBMana: TAOWPanel; { +0210 }
    SBManaV: TAOWLabel; { +0214 }
    SBManaIcn: TAOWImage; { +0218 }
    RSBSep1: TAoWFrame; { +021C }
    SBribeBtn: TAOWLabel; { +0220 }
    SBManaSlid: TAOWHScrollBar; { +0224 }
    SBIcon: TAOWImage; { +0228 }
    RSBSendBtn: TAOWButton; { +022C }
    RBSCanlBtn: TAOWButton; { +0230 }
    StatusGlow: TAOWImage; { +0234 }
    BribeHeaderLbl: TAOWLabel; { +0238 }
    RMsgRecPnl: TAOWPanel; { +023C }
    RMMemo: TAOWMemo; { +0240 }
    RMHeaderLbl: TAOWLabel; { +0244 }
    RMReplyBtn: TAOWButton; { +0248 }
    RMCancelBtn: TAOWButton; { +024C }
    RMExitBtn: TAOWButton; { +0250 }
    IncommingInfoPnl: TAOWPanel; { +0254 }
    IIOkBtn: TAOWButton; { +0258 }
    IIExitBtn: TAOWButton; { +025C }
    IRScroll: TAOWVScrollBar; { +0260 }
    IIMemo: TAOWMemo; { +0264 }
    IIIcon: TAOWImage; { +0268 }
    Translator: TIvTranslator; { +026C }
    OfTheLbl: TAOWLabel; { +0270 }
    PRaceLbl: TAOWLabel; { +0274 }
    public
    F_RelWindow_278: Integer;
    F_RelWindow_27C: Integer;
    F_RelWindow_280: Integer;
    F_RelWindow_284: array[0..1] of Byte;
    F_RelWindow_286: Byte;
    F_RelWindow_287: Byte;
    F_RelWindow_288: Integer;
    F_RelWindow_28C: Integer;
    F_RelWindow_290: Integer;
    F_RelWindow_294: array[0..7] of Byte;
    F_RelWindow_29C: Integer;
    F_RelWindow_2A0: Integer;
    F_RelWindow_2A4: Byte;
    F_RelWindow_2A5: array[0..2] of Byte;
    procedure RelWindowCreate;  { draft }
    procedure RelWindowDestroy;  { draft }
    procedure ExitClick;  { draft }
    procedure P1CBChange(A1: Integer);  { draft }
    procedure R1CBChange(A1: Integer);  { draft }
    procedure P1CBPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure R1CBPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure P1IDraw(A1: Integer; A2: Integer);  { draft }
    procedure R1IDraw(A1: Integer; A2: Integer);  { draft }
    procedure MAcceptBtnClick;  { draft }
    procedure MRejectBtnClick;  { draft }
    procedure PlyrGlowUpdate;  { draft }
    procedure PlyrGlowDraw(A1: Integer; A2: Integer);  { draft }
    procedure FaceFrPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure SBGoldSlidChange;  { draft }
    procedure SBManaSlidChange;  { draft }
    procedure RelWinHide;  { draft }
    procedure ASelectClick;  { draft }
    procedure ActionsLBChange;  { draft }
    procedure CancelSelectedAction;  { draft }
    procedure ChangeActionMessage(A1: Integer);  { draft }
    procedure MsgSendActionBtn;  { draft }
    procedure ReplyBtnClick;  { draft }
    procedure RMCancelBtnClick;  { draft }
    procedure IIOkBtnClick;  { draft }
    procedure RelWinKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TRelWindow.RelWindowCreate;
begin end;

procedure TRelWindow.RelWindowDestroy;
begin end;

procedure TRelWindow.ExitClick;
begin end;

procedure TRelWindow.P1CBChange(A1: Integer);
begin end;

procedure TRelWindow.R1CBChange(A1: Integer);
begin end;

procedure TRelWindow.P1CBPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TRelWindow.R1CBPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TRelWindow.P1IDraw(A1: Integer; A2: Integer);
begin end;

procedure TRelWindow.R1IDraw(A1: Integer; A2: Integer);
begin end;

procedure TRelWindow.MAcceptBtnClick;
begin end;

procedure TRelWindow.MRejectBtnClick;
begin end;

procedure TRelWindow.PlyrGlowUpdate;
begin end;

procedure TRelWindow.PlyrGlowDraw(A1: Integer; A2: Integer);
begin end;

procedure TRelWindow.FaceFrPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TRelWindow.SBGoldSlidChange;
begin end;

procedure TRelWindow.SBManaSlidChange;
begin end;

procedure TRelWindow.RelWinHide;
begin end;

procedure TRelWindow.ASelectClick;
begin end;

procedure TRelWindow.ActionsLBChange;
begin end;

procedure TRelWindow.CancelSelectedAction;
begin end;

procedure TRelWindow.ChangeActionMessage(A1: Integer);
begin end;

procedure TRelWindow.MsgSendActionBtn;
begin end;

procedure TRelWindow.ReplyBtnClick;
begin end;

procedure TRelWindow.RMCancelBtnClick;
begin end;

procedure TRelWindow.IIOkBtnClick;
begin end;

procedure TRelWindow.RelWinKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
