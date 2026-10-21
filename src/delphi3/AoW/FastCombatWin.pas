unit FastCombatWin;

{ Draft declarations of FastCombatWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EventLog, AoWComp, AoWE, AoWButton, AoWCheckBox, AoWHScroll, AoWImage, AoWLabel, AoWPanel, AoWWindow, aowUserDrawBox;

type
  TFastCombatWindow = class;


  { TFastCombatWindow (size $154, VMT 00434CD4): $124 phase, $128 phase frame, $12C animation frame, $134/$138 and $13C/$140 shield indices/opacities, $144 combat viewer, $148 completion event, $150 retained event. }
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
    FAnimationFrame: Integer; { $12C }
    FLogbook: TCombatLogbook; { $130; 0043534B }
    FLeftShield: Integer; { $134 }
    FLeftOpacity: Byte; { $138 }
    F_FastCombatWindow_139: array[0..2] of Byte;
    FRightShield: Integer; { $13C }
    FRightOpacity: Byte; { $140 }
    F_FastCombatWindow_141: array[0..2] of Byte;
    FViewer: TCombatViewer; { $144 }
    FDone: TExecuteDoneEvent; { $148 }
    FEvent: TEventLog; { $150 }
    procedure GetPartyPosition(Index: Integer; var X, Y: Integer);
    procedure DrawParties(X, Y: Integer; const Surface: TSurfaceDesc);
    procedure DrawWalls(X, Y: Integer; const Surface: TSurfaceDesc);
    procedure DrawCombat(X, Y: Integer; var Surface: TSurfaceDesc);
    procedure UpdateShields;
    procedure FinishDialog; { 00435268 }
    procedure SetPhase(Phase: Byte);
    procedure FastCombatWindowCreate;
    procedure FastCombatWindowDestroy;
    procedure CloseButClick;  { draft }
    procedure FCWinDrawSurface(Sender: TObject; Surface: TSurface);
    procedure FCWinUpdate(Sender: TObject);
    procedure InitialViewClick;  { draft }
    procedure FinalViewClick;  { draft }
    procedure PauseBtnClick;  { draft }
    procedure PlayBtnClick;  { draft }
    procedure SequencePositionSldChange;  { draft }
    procedure SequenceSpeedSldChange;  { draft }
    procedure LShieldUserDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
    procedure RShieldUserDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
    procedure FCWinHide;  { draft }
    procedure FCWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses AoWWinMan, aowIntGfxMod;


procedure TFastCombatWindow.GetPartyPosition(Index: Integer; var X, Y: Integer);
begin
  case Index of
    0: begin X := Party1Pnl.WinLeft; Y := Party1Pnl.WinTop; end;
    1, 7: begin X := Party2Pnl.WinLeft; Y := Party2Pnl.WinTop; end;
    2: begin X := Party3Pnl.WinLeft; Y := Party3Pnl.WinTop; end;
    3: begin X := Party4Pnl.WinLeft; Y := Party4Pnl.WinTop; end;
    4: begin X := Party5Pnl.WinLeft; Y := Party5Pnl.WinTop; end;
    5: begin X := Party6Pnl.WinLeft; Y := Party6Pnl.WinTop; end;
    6: begin X := Party7Pnl.WinLeft; Y := Party7Pnl.WinTop; end;
  end;
end;

procedure TFastCombatWindow.DrawParties(X, Y: Integer; const Surface: TSurfaceDesc);
var
  I, PX, PY, Position: Integer;
  Combat: TCombat;
  Obj: TCombatObject;
begin
  if vsInitialized in FViewer.FStatus then
  begin
    Combat := FViewer.FCombat;
    for I := 0 to Combat.FCombatData.GetCount - 1 do
    begin
      Obj := Combat.FCombatData.GetObjects(I);
      if Obj.FPosition <> $80 then
      begin
        GetPartyPosition(Obj.FPosition shr 4, PX, PY);
        PX := PX + X - 15;
        PY := PY + Y - 32;
        Position := Obj.FPosition and $F;
        Inc(PX, (Position mod 4) * 40);
        if Position >= 4 then Inc(PY, 38);
        FViewer.ShowFieldObject(Combat.FCombatData.GetObjects(I), FAnimationFrame, 3, PX, PY, Surface);
      end;
    end;
  end;
end;

procedure TFastCombatWindow.DrawWalls(X, Y: Integer; const Surface: TSurfaceDesc);
var
  Image: Integer;
  Wall: TCombatWall;
  function HasWall(A, B: Integer): Boolean;
  var
    PA, PB: TCombatParty;
    WA, WB: Boolean;
  begin
    PA := FViewer.FCombat.FCombatData.FParties.GetParty(A);
    PB := FViewer.FCombat.FCombatData.FParties.GetParty(B);
    WA := (PA <> nil) and (PA.FWall <> 0);
    WB := (PB <> nil) and (PB.FWall <> 0);
    Result := WA xor WB;
  end;
begin
  Dec(Y, 19);
  if FViewer.FCombat.FCombatData.FWallType = 2 then Image := 80
  else Image := 60;
  if FViewer.FCombat.FCombatData.FWallBreached then Inc(Image, 10);
  if HasWall(1, 6) then AoWHSSet.FCombatImages[Image].Show(X + 180, Y + 218 - 50, Surface);
  if HasWall(1, 2) then AoWHSSet.FCombatImages[Image].Show(X + 372, Y + 218 - 50, Surface);
  if HasWall(0, 1) then AoWHSSet.FCombatImages[Image + 4].Show(X + 180, Y + 218, Surface);
  if HasWall(0, 6) then AoWHSSet.FCombatImages[Image + 5].Show(X + 180, Y + 218, Surface);
  if HasWall(0, 2) then AoWHSSet.FCombatImages[Image + 5].Show(X + 372, Y + 218, Surface);
  if HasWall(5, 6) then AoWHSSet.FCombatImages[Image + 3].Show(X + 0, Y + 275, Surface);
  if HasWall(2, 3) then AoWHSSet.FCombatImages[Image + 2].Show(X + 374, Y + 275, Surface);
  if HasWall(0, 5) then AoWHSSet.FCombatImages[Image + 5].Show(X + 180, Y + 275, Surface);
  if HasWall(0, 3) then AoWHSSet.FCombatImages[Image + 5].Show(X + 372, Y + 275, Surface);
  if HasWall(0, 4) then AoWHSSet.FCombatImages[Image + 4].Show(X + 180, Y + 332, Surface);
  if HasWall(4, 5) then AoWHSSet.FCombatImages[Image + 1].Show(X + 180, Y + 342, Surface);
  if HasWall(4, 3) then AoWHSSet.FCombatImages[Image + 1].Show(X + 372, Y + 342, Surface);

  with FViewer.FCombat.FCombatData do
    if (FWallType <> 0) and (FWall <> nil) then
    begin
      Wall := FWall;
      if HasWall(0, 4) then
        ShowHitPcnt(X + 250, Y + 332 - 45, Surface, HitPointsToHitPcnt(Wall.GetHitPoints, Wall.GetHits))
      else ShowHitPcnt(X + 250, Y + 218 - 45, Surface, HitPointsToHitPcnt(Wall.GetHitPoints, Wall.GetHits));
    end;
end;

procedure TFastCombatWindow.DrawCombat(X, Y: Integer; var Surface: TSurfaceDesc);
var
  Combat: TCombat;
  I, PX, PY, Glow: Integer;
begin
  Combat := FViewer.FCombat;
  UpdateShields;
  if ModeLbl.Text <> Combat.FCombatData.FHeader then ModeLbl.Text := Combat.FCombatData.FHeader;
  DrawParties(X, Y + 20, Surface);
  if Combat.FCombatData.FWallType <> 0 then DrawWalls(X, Y + 20, Surface);
  FViewer.ShowFightingObjects(FAnimationFrame, X + 234, Y + 15, Surface);
  if (FPhase = 2) or (FPhase = 3) then
    for I := 0 to 7 do
      if Combat.FCombatData.FParties.GetParty(I) <> nil then
        if Combat.FCombatData.FParties.GetParty(I).FArmy.GetCount = 0 then
          if not (FViewer.FLogbook.FFinalData.F_CombatData_30 in [2, 7, 8]) then
          begin
            Glow := FPhaseFrame div 2;
            Glow := Abs((Glow + 7) mod 15 - 7);
            GetPartyPosition(I, PX, PY);
            AoWHSSet.FCombatImages[Glow + 100].ShowClipped(PX + X - 10, PY + Y - 9, Surface);
          end;
end;

procedure TFastCombatWindow.UpdateShields;
var
  Data: TCombatData;
  Left, Right: Integer;
  LeftOpacity, RightOpacity: Integer;
begin
  Data := FViewer.FCombat.FCombatData;
  if Data.FPlayers.GetPlayers(Data.FAttackerPlayer).FPlayer = 0 then Left := 12
  else Left := AoWHSMap.FPlayers.GetPlayers(Data.FPlayers.GetPlayers(Data.FAttackerPlayer).FPlayer).FPlayerRace;
  if (Data.FCurrentPlayer = $FF) or
    (Data.FPlayers.GetPlayers(Data.FCurrentPlayer).FSideIndex <> 0) then LeftOpacity := 60
  else LeftOpacity := 100;
  if FPhase = 3 then LeftOpacity := 100;
  if Data.FPlayers.GetPlayers(Data.FDefenderPlayer).FPlayer = 0 then Right := 12
  else Right := AoWHSMap.FPlayers.GetPlayers(Data.FPlayers.GetPlayers(Data.FDefenderPlayer).FPlayer).FPlayerRace;
  if (Data.FCurrentPlayer = $FF) or
    (Data.FPlayers.GetPlayers(Data.FCurrentPlayer).FSideIndex <> 1) then RightOpacity := 60
  else RightOpacity := 100;
  if FPhase = 3 then RightOpacity := 100;
  if (Left <> FLeftShield) or (LeftOpacity <> FLeftOpacity) then
  begin
    FLeftShield := Left;
    FLeftOpacity := LeftOpacity;
    LShieldUser.FDrawn := False;
  end;
  if (Right <> FRightShield) or (RightOpacity <> FRightOpacity) then
  begin
    FRightShield := Right;
    FRightOpacity := RightOpacity;
    RShieldUser.FDrawn := False;
  end;
end;

procedure TFastCombatWindow.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Log: TEventLog;
begin
  FViewer.Finalize;
  General.Manager.OverlayPriority := 0;
  Done := FDone;
  Log := FEvent;
  FDone := nil;
  FEvent := nil;
  if Assigned(Done) then Done(Log);
  if Log <> nil then Log.Release;
end;


procedure TFastCombatWindow.FastCombatWindowCreate;
begin
  FViewer := TCombatViewer.Create;
end;

procedure TFastCombatWindow.FastCombatWindowDestroy;
begin
  FViewer.Free;
end;

procedure TFastCombatWindow.CloseButClick;
begin
  General.PlayButtonSound(0);
  FCWin.Visible := False;
end;

procedure TFastCombatWindow.FCWinDrawSurface(Sender: TObject; Surface: TSurface);
var
  SD: TSurfaceDesc;
begin
  try
    if not (vsPaused in FViewer.FStatus) then Inc(FAnimationFrame);
    if FPhase = 1 then FViewer.Update;
    if Surface.Lock(SD) >= 0 then
    begin
      if SequencePositionSld.Position <> FViewer.FPosition then SequencePositionSld.Position := FViewer.FPosition;
      SD.ClipRect.Top := FCWin.WinTop + 24;
      DrawCombat(FCWin.WinLeft + 10, FCWin.WinTop + 10, SD);
      Surface.Unlock;
    end;
  except
    raise;
  end;
end;

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
var
  Viewer: TCombatViewer;
begin
  General.PlayButtonSound(0);
  Viewer := FViewer;
  if (Viewer <> nil) and (vsInitialized in Viewer.FStatus) then
  begin
    Viewer.SetPosition(0);
      SetPhase(1);
  end;
end;

procedure TFastCombatWindow.FinalViewClick;
var
  Viewer: TCombatViewer;
begin
  General.PlayButtonSound(0);
  Viewer := FViewer;
  if (Viewer <> nil) and (vsInitialized in Viewer.FStatus) then
  begin
    Viewer.SetPosition(Viewer.GetEndPosition + 1);
      SetPhase(3);
  end;
end;

procedure TFastCombatWindow.PauseBtnClick;
begin
  General.PlayButtonSound(0);
  if (FViewer <> nil) and (vsInitialized in FViewer.FStatus) then FViewer.Pause;
end;

procedure TFastCombatWindow.PlayBtnClick;
begin
  General.PlayButtonSound(0);
  if (FViewer <> nil) and (vsInitialized in FViewer.FStatus) then FViewer.Play;
end;

procedure TFastCombatWindow.SequencePositionSldChange;
var
  Viewer: TCombatViewer;
begin
  Viewer := FViewer;
  if (Viewer <> nil) and (vsInitialized in Viewer.FStatus) then
  begin
    Viewer.SetPosition(SequencePositionSld.Position);
      SetPhase(1);
  end;
end;

procedure TFastCombatWindow.SequenceSpeedSldChange;
begin
  if FViewer <> nil then FViewer.SetSpeed(20 - SequenceSpeedSld.Position);
end;

procedure TFastCombatWindow.LShieldUserDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
begin
  if FLeftOpacity = 100 then
    IntGfxMod.Shields[FLeftShield].ShowClipped(FCWin.WinLeft + Sender.WinLeft, FCWin.WinTop + Sender.WinTop, Surface)
  else
    IntGfxMod.Shields[FLeftShield].ShowBlended(FCWin.WinLeft + Sender.WinLeft, FCWin.WinTop + Sender.WinTop, Surface,
      AlphaBlendTable.Lookup[FLeftOpacity]);
end;

procedure TFastCombatWindow.RShieldUserDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
begin
  if FRightOpacity = 100 then
    IntGfxMod.Shields[FRightShield].ShowClipped(FCWin.WinLeft + Sender.WinLeft, FCWin.WinTop + Sender.WinTop, Surface)
  else
    IntGfxMod.Shields[FRightShield].ShowBlended(FCWin.WinLeft + Sender.WinLeft, FCWin.WinTop + Sender.WinTop, Surface,
      AlphaBlendTable.Lookup[FRightOpacity]);
end;

procedure TFastCombatWindow.FCWinHide;
begin
  FinishDialog;
end;

procedure TFastCombatWindow.FCWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = 27) or (Key = 32) then FCWin.Visible := False;
end;

procedure TFastCombatWindow.SetPhase(Phase: Byte);
begin
  FPhase := Phase;
  FPhaseFrame := 0;
end;

end.
