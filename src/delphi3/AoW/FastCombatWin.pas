unit FastCombatWin;

{ Draft declarations of FastCombatWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWButton, AoWCheckBox, AoWHScroll, AoWImage, AoWLabel, AoWPanel, AoWWindow, aowUserDrawBox;

type
  TFastCombatWindow = class;


  { TFastCombatWindow (size $154, VMT 00434CD4): $124 phase, $128 phase frame, $144 combat viewer. }
  TFastCombatWindow = class(TDataModule)
  public
    published
    FCWin: TAOWWindow; { +0044 }
    LNamePnl: TAOWPanel; { +0048 }
    LSideLbl: TAOWLabel; { +004C }
    RNamePnl: TAOWPanel; { +0050 }
    RSideLbl: TAOWLabel; { +0054 }
    LCtrlPnl: TAOWPanel; { +0058 }
    RCtrlPnl: TAOWPanel; { +005C }
    PlayBtn2: TAOWCheckBox; { +0060 }
    PauseBtn2: TAOWCheckBox; { +0064 }
    StartBtn: TAOWCheckBox; { +0068 }
    EndBtn: TAOWCheckBox; { +006C }
    CloseBut: TAOWButton; { +0070 }
    Party1Pnl: TAOWPanel; { +0074 }
    Party1Bg: TAOWImage; { +0078 }
    Part1Dead: TAOWImage; { +007C }
    Party2Pnl: TAOWPanel; { +0080 }
    Party2Bg: TAOWImage; { +0084 }
    Party2Dead: TAOWImage; { +0088 }
    Party3Pnl: TAOWPanel; { +008C }
    Party3Bg: TAOWImage; { +0090 }
    Party3Dead: TAOWImage; { +0094 }
    Party4Pnl: TAOWPanel; { +0098 }
    Party4Bg: TAOWImage; { +009C }
    Party4Dead: TAOWImage; { +00A0 }
    Party5Pnl: TAOWPanel; { +00A4 }
    Party5Bg: TAOWImage; { +00A8 }
    Party5Dead: TAOWImage; { +00AC }
    Party6Pnl: TAOWPanel; { +00B0 }
    Party6Bg: TAOWImage; { +00B4 }
    Party6Dead: TAOWImage; { +00B8 }
    Party7Pnl: TAOWPanel; { +00BC }
    Party7Bg: TAOWImage; { +00C0 }
    Party7Dead: TAOWImage; { +00C4 }
    LSidePnl: TAOWPanel; { +00C8 }
    RSidePnl: TAOWPanel; { +00CC }
    FightPnl: TAOWPanel; { +00D0 }
    LShield: TAOWImage; { +00D4 }
    RShield: TAOWImage; { +00D8 }
    InitialView: TAOWButton; { +00DC }
    FinalView: TAOWButton; { +00E0 }
    PlayBtn: TAOWButton; { +00E4 }
    PauseBtn: TAOWButton; { +00E8 }
    SequencePositionSld: TAOWHScrollBar; { +00EC }
    SequenceSpeedSld: TAOWHScrollBar; { +00F0 }
    GlowAnimation: TImageLibrary; { +00F4 }
    GlowImage: TAOWImage; { +00F8 }
    PrevSeqBtn: TAOWButton; { +00FC }
    NextSeqBtn: TAOWButton; { +0100 }
    StartLBl: TAOWLabel; { +0104 }
    FastLbl: TAOWLabel; { +0108 }
    SlowLbl: TAOWLabel; { +010C }
    EndLbl: TAOWLabel; { +0110 }
    ModeLbl: TAOWLabel; { +0114 }
    LShieldUser: TaowUserDrawBox; { +0118 }
    RShieldUser: TaowUserDrawBox; { +011C }
    Translator: TIvTranslator; { +0120 }
    public
    FPhase: Byte; { $124 }
    F_FastCombatWindow_125: array[0..2] of Byte;
    FPhaseFrame: Integer; { $128 }
    F_FastCombatWindow_12C: Integer;
    F_FastCombatWindow_130: array[0..3] of Byte;
    F_FastCombatWindow_134: Integer;
    F_FastCombatWindow_138: Byte;
    F_FastCombatWindow_139: array[0..2] of Byte;
    F_FastCombatWindow_13C: Integer;
    F_FastCombatWindow_140: Byte;
    F_FastCombatWindow_141: array[0..2] of Byte;
    FViewer: TCombatViewer; { $144 }
    F_FastCombatWindow_148: array[0..11] of Byte;
    procedure SetPhase(Phase: Byte);
    procedure FastCombatWindowCreate;
    procedure FastCombatWindowDestroy;
    procedure CloseButClick;  { draft }
    procedure FCWinDrawSurface(A1: Integer; A2: Integer);  { draft }
    procedure FCWinUpdate(Sender: TObject);
    procedure InitialViewClick;  { draft }
    procedure FinalViewClick;  { draft }
    procedure PauseBtnClick;  { draft }
    procedure PlayBtnClick;  { draft }
    procedure SequencePositionSldChange;  { draft }
    procedure SequenceSpeedSldChange;  { draft }
    procedure LShieldUserDraw(A1: Integer; A2: Integer);  { draft }
    procedure RShieldUserDraw(A1: Integer; A2: Integer);  { draft }
    procedure FCWinHide;  { draft }
    procedure FCWinKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

uses AoWWinMan;

procedure TFastCombatWindow.FastCombatWindowCreate;
begin
  FViewer := TCombatViewer.Create;
end;

procedure TFastCombatWindow.FastCombatWindowDestroy;
begin
  FViewer.Free;
end;

procedure TFastCombatWindow.CloseButClick;
begin end;

procedure TFastCombatWindow.FCWinDrawSurface(A1: Integer; A2: Integer);
begin end;

procedure TFastCombatWindow.FCWinUpdate(Sender: TObject);
var
  Image: Integer;
begin
  try
    case FPhase of
      0: begin
        Image := FPhaseFrame div 2;
        if Image > 9 then Image := 9;
        with GlowImage do if Image <> CurrentImage then CurrentImage := Image + 20;
        if not GlowImage.Visible then GlowImage.Visible := True;
        if FPhaseFrame > 20 then SetPhase(1);
      end;
      1: begin
        if GlowImage.CurrentImage <> 29 then GlowImage.CurrentImage := 29;
        if not GlowImage.Visible then GlowImage.Visible := True;
        with FViewer do if FPosition >= GetEndPosition then SetPhase(2);
      end;
      2: begin
        Image := 9 - FPhaseFrame div 2;
        if Image < 0 then Image := 0;
        with GlowImage do if Image <> CurrentImage then CurrentImage := Image + 20;
        if not GlowImage.Visible then GlowImage.Visible := True;
        if FPhaseFrame > 20 then
        begin
          SetPhase(3);
          FPhaseFrame := 21;
        end;
      end;
      3: if GlowImage.Visible then
        begin
          GlowImage.Visible := False;
          FCWin.FDrawn := False;
        end;
    end;
    FCWin.FSurfaceValid := False;
    Inc(FPhaseFrame);
  except
    raise Exception.Create('Exception during FastCombatWin.Update');
  end;
end;

procedure TFastCombatWindow.InitialViewClick;
begin end;

procedure TFastCombatWindow.FinalViewClick;
begin end;

procedure TFastCombatWindow.PauseBtnClick;
begin end;

procedure TFastCombatWindow.PlayBtnClick;
begin end;

procedure TFastCombatWindow.SequencePositionSldChange;
begin end;

procedure TFastCombatWindow.SequenceSpeedSldChange;
begin end;

procedure TFastCombatWindow.LShieldUserDraw(A1: Integer; A2: Integer);
begin end;

procedure TFastCombatWindow.RShieldUserDraw(A1: Integer; A2: Integer);
begin end;

procedure TFastCombatWindow.FCWinHide;
begin end;

procedure TFastCombatWindow.FCWinKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TFastCombatWindow.SetPhase(Phase: Byte);
begin
  FPhase := Phase;
  FPhaseFrame := 0;
end;

end.
