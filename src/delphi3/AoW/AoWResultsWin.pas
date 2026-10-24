unit AoWResultsWin;

{ Partly recovered AoWResultsWin handlers, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Any remaining stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AoWButton, AoWCheckBox, AoWImage, AoWLabel, AoWMemo, AoWPanel;

type
  TResultsWin = class;


  { TResultsWin (size $108, VMT 004279A8): $100 player indices, $104 checkbox controls. }
  TResultsWin = class(TDataModule)
  public
    published
    P1CB: TAOWCheckBox; { +0044 }
    P2CB: TAOWCheckBox; { +0048 }
    P3CB: TAOWCheckBox; { +004C }
    P4CB: TAOWCheckBox; { +0050 }
    P5CB: TAOWCheckBox; { +0054 }
    P6CB: TAOWCheckBox; { +0058 }
    P7CB: TAOWCheckBox; { +005C }
    P8CB: TAOWCheckBox; { +0060 }
    P9CB: TAOWCheckBox; { +0064 }
    P10CB: TAOWCheckBox; { +0068 }
    P11CB: TAOWCheckBox; { +006C }
    P12CB: TAOWCheckBox; { +0070 }
    StrLbl: TAOWLabel; { +0074 }
    TurnLbl: TAOWLabel; { +0078 }
    ResNames: TAOWMemo; { +007C }
    ResValues: TAOWMemo; { +0080 }
    SideLbl: TAOWLabel; { +0084 }
    Axis: TAOWImage; { +0088 }
    ExitBtn: TAOWButton; { +008C }
    FaceGrid: TAOWImage; { +0090 }
    LoadBtn: TAOWButton; { +0094 }
    ContinueBtn: TAOWButton; { +0098 }
    ResultsPnl: TAOWPanel; { +009C }
    StrengthCB: TAOWCheckBox; { +00A0 }
    AgendaPnl: TAOWPanel; { +00A4 }
    StrengthLbl: TAOWLabel; { +00A8 }
    GoldCB: TAOWCheckBox; { +00AC }
    GoldLbl: TAOWLabel; { +00B0 }
    ArmiesCB: TAOWCheckBox; { +00B4 }
    ArmiesLbl: TAOWLabel; { +00B8 }
    HeroesCB: TAOWCheckBox; { +00BC }
    HeroesLbl: TAOWLabel; { +00C0 }
    StructuresCB: TAOWCheckBox; { +00C4 }
    StructuresLbl: TAOWLabel; { +00C8 }
    KeyMax: TAOWLabel; { +00CC }
    KeyMin: TAOWLabel; { +00D0 }
    ManaCB: TAOWCheckBox; { +00D4 }
    ManaLbl: TAOWLabel; { +00D8 }
    Translator: TIvTranslator; { +00DC }
    public
    FMaxTurns, FMaxGold, FMaxMana, FMaxArmies, FReservedF0, FMaxHeroes, FMaxStructures, FMaxStrength: Integer; { $E0..$FC }
    FPlayers: TByteList; { $100 }
    FControls: TList; { $104 }
    procedure UpdateSelection;
    procedure DrawGraphs(const Surface: TSurfaceDesc);
    procedure DrawGraph(Image: TLibraryImage; Values: TIntegerList; Turns, Maximum: Integer; const R: TRect; const Surface: TSurfaceDesc);
    procedure DrawGold(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
    procedure DrawMana(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
    procedure DrawHeroes(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
    procedure DrawArmies(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
    procedure DrawStructures(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
    procedure DrawStrength(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
    published procedure ResultsWinCreate; public  { draft }
    published procedure ResultsWinDestroy; public  { draft }
    published procedure ContinueBtnClick; public  { draft }
    published procedure ExitBtnClick; public  { draft }
    published procedure ResultsPnlUpdate; public  { draft }
    published procedure AxisDraw(Sender: TObject; Surface: TSurfaceDesc); public
    published procedure AgendaChange; public  { draft }
    published procedure ResultsPnlShow; public  { draft }
    published procedure P1CBPreDraw(Sender: TObject; Surface: TSurfaceDesc); public
    published procedure P1CBChange(Sender: TObject); public
  end;


var
  ResultsWin: TResultsWin;
procedure ShowResults(Window: TResultsWin);
implementation

uses E1Resources, E1Globals, E1GameFlow, AoWWinMan, AoWExeForms, E3Globals, AOWPyreScrn, aowIntGfxMod, AoWVideoDlg;


procedure TResultsWin.UpdateSelection;
var
  I, J: Integer;
  Stats: TPlayerStatistics;
begin
  FMaxTurns := 1;
  FMaxGold := 1;
  FMaxMana := 1;
  FMaxArmies := 1;
  FReservedF0 := 1;
  FMaxHeroes := 1;
  FMaxStructures := 1;
  FMaxStrength := 1;
  for I := 0 to FPlayers.Count - 1 do
  begin
    Stats := AoWHSMap.FPlayers.GetPlayers(FPlayers[I]).FStatistics;
    if FMaxTurns < Stats.FTurnInfo.GetCount then FMaxTurns := Stats.FTurnInfo.GetCount;
    for J := 0 to Stats.FTurnInfo.GetCount - 1 do
    begin
      if FMaxArmies < Stats.FTurnInfo.GetTurnInfo(J).FArmyStrength then FMaxArmies := Stats.FTurnInfo.GetTurnInfo(J).FArmyStrength;
      if FMaxGold < Stats.FTurnInfo.GetTurnInfo(J).FGold then FMaxGold := Stats.FTurnInfo.GetTurnInfo(J).FGold;
      if FMaxMana < Stats.FTurnInfo.GetTurnInfo(J).FMana then FMaxMana := Stats.FTurnInfo.GetTurnInfo(J).FMana;
      if FMaxHeroes < Stats.FTurnInfo.GetTurnInfo(J).FHeroes then FMaxHeroes := Stats.FTurnInfo.GetTurnInfo(J).FHeroes;
      if FMaxStructures < Stats.FTurnInfo.GetTurnInfo(J).FStructures then FMaxStructures := Stats.FTurnInfo.GetTurnInfo(J).FStructures;
      if FMaxStrength < Stats.FTurnInfo.GetTurnInfo(J).GetSuperiority then FMaxStrength := Stats.FTurnInfo.GetTurnInfo(J).GetSuperiority;
    end;
  end;
  TurnLbl.Text := TranslateRStr(TurnRStr) + ' ' + IntToStr(FMaxTurns);
end;

procedure TResultsWin.DrawGraph(Image: TLibraryImage; Values: TIntegerList; Turns, Maximum: Integer; const R: TRect; const Surface: TSurfaceDesc);
var
  Width, LastY, Y1, X2, I: Integer;
  XStep, YStep: Single;
  NextY, X1, Y2, Height: Integer;
begin
  if Values.Count <> 0 then
  begin
    Width := R.Right - R.Left;
    Height := R.Bottom - R.Top;
    if Turns >= 2 then XStep := Width / (Turns - 1)
    else XStep := Width;
    YStep := Height / Maximum;
    LastY := Values[0];
    for I := 1 to Values.Count - 1 do
    begin
      NextY := Values[I];
      X1 := Round((I - 1) * XStep); X1 := X1;
      Y1 := Round(LastY * YStep);
      X2 := Round(X1 + XStep); { Original advances from the rounded previous x coordinate. }
      Y2 := Round(NextY * YStep);
      DrawImageLine(Image, X1 + R.Left, R.Bottom - Y1, R.Left + X2, R.Bottom - Y2, 1, Surface);
      LastY := NextY;
    end;
    if Values.Count = 1 then
    begin
      X1 := 0;
      NextY := Round(LastY * YStep);
      Y1 := NextY;
      X2 := Width - 1;
      Y2 := Round(LastY * YStep); { Original repeats the rounding and discards its result. }
      Y2 := NextY;
      DrawImageLine(Image, X1 + R.Left, R.Bottom - Y1, R.Left + X2, R.Bottom - Y2, 1, Surface);
    end;
  end;
end;

procedure TResultsWin.DrawGold(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
var
  Values: TIntegerList;
  Info: TTurnInfo;
  I: Integer;
begin
  Values := TIntegerList.Create;
  Info := AoWHSMap.FPlayers.GetPlayers(Player).FStatistics.FTurnInfo;
  for I := 0 to Info.GetCount - 1 do Values.Add(Info.GetTurnInfo(I).FGold);
  DrawGraph(IntGfxMod.EndScene[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace + 13],
    Values, FMaxTurns, FMaxGold, R, Surface);
  Values.Free;
  KeyMax.Text := IntToStr(FMaxGold);
end;

procedure TResultsWin.DrawMana(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
var
  Values: TIntegerList;
  Info: TTurnInfo;
  I: Integer;
begin
  Values := TIntegerList.Create;
  Info := AoWHSMap.FPlayers.GetPlayers(Player).FStatistics.FTurnInfo;
  for I := 0 to Info.GetCount - 1 do Values.Add(Info.GetTurnInfo(I).FMana);
  DrawGraph(IntGfxMod.EndScene[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace + 13],
    Values, FMaxTurns, FMaxMana, R, Surface);
  Values.Free;
  KeyMax.Text := IntToStr(FMaxMana);
end;

procedure TResultsWin.DrawHeroes(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
var
  Values: TIntegerList;
  Info: TTurnInfo;
  I: Integer;
begin
  Values := TIntegerList.Create;
  Info := AoWHSMap.FPlayers.GetPlayers(Player).FStatistics.FTurnInfo;
  for I := 0 to Info.GetCount - 1 do Values.Add(Info.GetTurnInfo(I).FHeroes);
  DrawGraph(IntGfxMod.EndScene[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace + 13],
    Values, FMaxTurns, FMaxHeroes, R, Surface);
  Values.Free;
  KeyMax.Text := IntToStr(FMaxHeroes);
end;

procedure TResultsWin.DrawArmies(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
var
  Values: TIntegerList;
  Info: TTurnInfo;
  I: Integer;
begin
  Values := TIntegerList.Create;
  Info := AoWHSMap.FPlayers.GetPlayers(Player).FStatistics.FTurnInfo;
  for I := 0 to Info.GetCount - 1 do Values.Add(Info.GetTurnInfo(I).FArmyStrength);
  DrawGraph(IntGfxMod.EndScene[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace + 13],
    Values, FMaxTurns, FMaxArmies, R, Surface);
  Values.Free;
  KeyMax.Text := IntToStr(FMaxArmies);
end;

procedure TResultsWin.DrawStructures(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
var
  Values: TIntegerList;
  Info: TTurnInfo;
  I: Integer;
begin
  Values := TIntegerList.Create;
  Info := AoWHSMap.FPlayers.GetPlayers(Player).FStatistics.FTurnInfo;
  for I := 0 to Info.GetCount - 1 do Values.Add(Info.GetTurnInfo(I).FStructures);
  DrawGraph(IntGfxMod.EndScene[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace + 13],
    Values, FMaxTurns, FMaxStructures, R, Surface);
  Values.Free;
  KeyMax.Text := IntToStr(FMaxStructures);
end;

procedure TResultsWin.DrawStrength(Player: Shortint; const R: TRect; const Surface: TSurfaceDesc);
var
  Values: TIntegerList;
  Info: TTurnInfo;
  I: Integer;
begin
  Values := TIntegerList.Create;
  Info := AoWHSMap.FPlayers.GetPlayers(Player).FStatistics.FTurnInfo;
  for I := 0 to Info.GetCount - 1 do Values.Add(Info.GetTurnInfo(I).GetSuperiority);
  DrawGraph(IntGfxMod.EndScene[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace + 13],
    Values, FMaxTurns, FMaxStrength, R, Surface);
  Values.Free;
  KeyMax.Text := IntToStr(FMaxStructures); { Original strength graph labels the structures maximum. }
end;

procedure TResultsWin.DrawGraphs(const Surface: TSurfaceDesc);
var
  Bounds: TRect;
  I: Integer;
begin
  Bounds.Left := ResultsPnl.WinLeft + Axis.WinLeft + 5;
  Bounds.Top := ResultsPnl.WinTop + Axis.WinTop + 4;
  Bounds.Right := ResultsPnl.WinLeft + Axis.WinLeft + 338;
  Bounds.Bottom := ResultsPnl.WinTop + Axis.WinTop + 117;
  for I := 0 to FPlayers.Count - 1 do
  begin
    if GoldCB.Checked then DrawGold(FPlayers[I], Bounds, Surface);
    if ManaCB.Checked then DrawMana(FPlayers[I], Bounds, Surface);
    if HeroesCB.Checked then DrawHeroes(FPlayers[I], Bounds, Surface);
    if StructuresCB.Checked then DrawStructures(FPlayers[I], Bounds, Surface);
    if ArmiesCB.Checked then DrawArmies(FPlayers[I], Bounds, Surface);
    if StrengthCB.Checked then DrawStrength(FPlayers[I], Bounds, Surface);
  end;
end;

procedure TResultsWin.ResultsWinCreate;
begin
  FPlayers := TByteList.Create;
  FControls := TList.Create;
  FControls.Add(P1CB);
  FControls.Add(P2CB);
  FControls.Add(P3CB);
  FControls.Add(P4CB);
  FControls.Add(P5CB);
  FControls.Add(P6CB);
  FControls.Add(P7CB);
  FControls.Add(P8CB);
  FControls.Add(P9CB);
  FControls.Add(P10CB);
  FControls.Add(P11CB);
  FControls.Add(P12CB);
end;

procedure TResultsWin.ResultsWinDestroy;
begin
  FPlayers.Free;
  FControls.Free;
end;

procedure TResultsWin.ContinueBtnClick;
begin
  FinishPyre(PyreScreen);
  General.PlayButtonSound(0);
  ResultsWin.ResultsPnl.Visible := False;
  FadeMusicVolume(SoundDlg.MusicVolume.Position, 2);
  if AoWHSMap.FGameStatus = gsTerminated then
  begin
    if AoWEngine.FCampaign = nil then General.ReturnToTitle
    else ShowCampaignMap(WorldMap);
  end
  else
  begin
    TitleWindow.TitleWin.Visible := False;
    SetVideoMode(VideoDialog, scmGame);
    VideoDialog.ApplyMode;
  end;
end;

procedure TResultsWin.ExitBtnClick;
begin
  ResultsPnl.Visible := False;
  General.ReturnToTitle;
end;

procedure TResultsWin.ResultsPnlUpdate;
begin
  PyreScreen.DeadPnlUpdate;
end;

procedure TResultsWin.AxisDraw(Sender: TObject; Surface: TSurfaceDesc);
begin
  DrawGraphs(Surface);
end;

procedure TResultsWin.AgendaChange;
begin
  ResultsPnl.FDrawn := False;
end;

procedure TResultsWin.ResultsPnlShow;
begin
  UpdateSelection;
end;

procedure TResultsWin.P1CBPreDraw(Sender: TObject; Surface: TSurfaceDesc); { Tried typed sender and panel-first rectangle arithmetic; no exact match. }
var
  R: TRect;
begin
  with TAoWComponent(Sender) do
    if Tag < FPlayers.Count then
    begin
      R := Rect(WinLeft + ResultsPnl.WinLeft + 1, WinTop + ResultsPnl.WinTop + 1,
        WinLeft + WinWidth + ResultsPnl.WinLeft - 1, WinTop + WinHeight + ResultsPnl.WinTop - 1);
      if AoWHSMap.FPlayers.GetPlayers(FPlayers[Tag]).GetFace <> nil then
        AoWHSMap.FPlayers.GetPlayers(FPlayers[Tag]).FLeader.ShowFace(R, Surface);
      IntGfxMod.RelWin[AoWHSMap.FPlayers.GetPlayers(FPlayers[Tag]).FPlayerRace + 16].ShowClipped(
        WinLeft + ResultsPnl.WinLeft, WinTop + ResultsPnl.WinTop, Surface);
    end;
end;

procedure TResultsWin.P1CBChange(Sender: TObject);
var Control: TAOWCheckBox;
begin Control := TAOWCheckBox(Sender);
  if Control.Checked then
  begin
    if FPlayers.Count > Control.Tag then SideLbl.Text := AoWHSMap.FPlayers.GetPlayers(FPlayers[Control.Tag]).GetNameEx;
    ResValues.Items.Clear;
    ResValues.Items.Add('0%');
    ResValues.Items.Add('0%');
    ResValues.Items.Add('0%');
    ResValues.Items.Add('0%');
  end;
end;
procedure ShowResults(Window: TResultsWin); var I: Integer; begin if AoWEngine.FDemo then PlaySongEx('Songs\Special\end2.s3m', 2, 2, True) else PlaySongEx('Songs\Special\Sunset.it', 2, 2, True); SetMusicVolume(0); FadeMusicVolume(AoWExeForms.SoundDlg.MusicVolume.Position, 1); Window.FPlayers.Clear; for I := 1 to AoWHSMap.FPlayers.Count - 1 do if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptIndependent then Window.FPlayers.Add(I); for I := 0 to 11 do begin TAOWCheckBox(Window.FControls[I]).Visible := I < Window.FPlayers.Count; TAOWCheckBox(Window.FControls[I]).Checked := (I < Window.FPlayers.Count) and (Window.FPlayers[I] = AoWHSMap.FSeatedPlayer); end; if (AoWEngine.FCampaign <> nil) and (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGameOverStatus = goLost) then begin Window.ContinueBtn.Text := TranslateRStr(ReplayRStr); Window.ExitBtn.Visible := True; end else begin Window.ContinueBtn.Text :=
TranslateRStr(ContinueRStr); Window.ExitBtn.Visible := False; end; ResultsWin.ResultsPnl.Visible := True; end;
end.
