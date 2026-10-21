unit AoWTitleScene;

{ AoWTitleScene recovered from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWLabel, AoWMemo, AowUserWindow;

type
  TTitleScene = class;


  { TTitleScene (size $B4, VMT 004192F4): $64/$68 frame counters, $6C mouse button, $70/$74 mouse position, $78/$7C/$80 selected/pressed/hover button, $84 scene rectangle, $94/$95 redraw/credits, $98 credits, $9C/$A0 credit page/frame, $A4/$A8 intro flag/frame, $AC font. }
  TTitleScene = class(TDataModule)
  public
    published
    TitleSceneIL: TImageLibrary; { +0044 }
    Window: TAoWUserWindow; { +0048 }
    LegalNotice: TAOWMemo; { +004C }
    StrLbl: TAOWLabel; { +0050 }
    NameLbl: TAOWLabel; { +0054 }
    Copyright: TAOWLabel; { +0058 }
    Version: TAOWLabel; { +005C }
    public
    FReserved60: Integer; FFrame: Integer; FTotalFrame: Integer; { $60, $64, $68 }
    FMouseButton: TMouseButton; { $6C }
    F_TitleScene_6D: array[0..2] of Byte;
    FMouseX: Integer; { $70 }
    FMouseY: Integer; { $74 }
    FSelectedButton: Integer; { $78 }
    FPressedButton: Integer; { $7C }
    FHoverButton: Integer; { $80 }
    FSceneRect: TRect; { $84 }
    FRedrawBackground: Boolean; { $94 }
    FShowCredits: Boolean; { $95 }
    F_TitleScene_96: array[0..1] of Byte;
    FCredits: TList; { $98 }
    FCreditPage: Integer; FCreditFrame: Integer; FShowIntro: Boolean; FPadA5: array[0..2] of Byte; FIntroFrame: Integer; FFont: TImageLibraryFont; FCreditsFont: TImageLibraryFont; { $9C, $A0, $A4, $A8, $AC, $B0 }
    { conflict: FShadowFont: TImageLibraryFont; }
    procedure DrawCredits(var Surface: TSurfaceDesc);
    procedure DrawIntro(var Surface: TSurfaceDesc);
    procedure DrawScene(var Surface: TSurfaceDesc);
    procedure ShowScene(PlayMusic: Boolean);
    procedure HideScene;
    procedure ResetScene;
    procedure AdvanceFrame;
    function HitTest: Integer;
    procedure WindowDrawSurfaceEx(Surface: TSurface; var Drawn: Boolean);
    procedure TitleSceneCreate;
    procedure TitleSceneDestroy;
    procedure WindowUpdate;  { draft }
    procedure WindowMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WindowMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure WindowMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WindowHide;
  end;


implementation

uses AoWUnit, E1Globals, E1GameFlow, AoWWinMan, AoWExeForms, E3Globals, AoWFileDialog, AoWVideoDlg;


resourcestring
  TitleNewGameRStr = 'New Game';
  TitleCampaignRStr = 'Campaign';
  TitleTutorialRStr = 'Tutorial';
  TitleLoadGameRStr = 'Load Game';
  TitleExitRStr = 'Exit';

var
  TitleButtons: array[0..4] of string;

procedure TTitleScene.ShowScene(PlayMusic: Boolean);
begin
  if PlayMusic then
    if not ((SongPlayer.CurrentIndex <> -1) and (SongPlayer.CurrentIndex < SongPlayer.Songs.Count) and
      (SongPlayer.Songs[SongPlayer.CurrentIndex] = 'SONGS\TITLE.IT')) then
    begin
      SongPlayer.Songs.Clear;
      SongPlayer.Songs.Add('SONGS\TITLE.IT');
      SongPlayer.Play(0);
    end;
  General.Manager.OverlayPriority := 0;
  TitleSceneIL.LoadDiscardableImageData;
  SetVideoSize(VideoDialog, 640, 480);
  SetVideoMode(VideoDialog, scmTitle);
  VideoDialog.ApplyBtnClick;
  MainForm.Display.FrameRate := 30;
  MainForm.DXDC.UseVerticalBlank := True;
  FRedrawBackground := True;
  FPressedButton := -1;
  FHoverButton := -1;
  FFont := FontModule.AoW15WhiteGrey;
  FCreditsFont := FontModule.AoW15WhiteGrey;
  Window.WinManager.ILIndexTBack := 4;
  Window.Visible := True;
end;

procedure TTitleScene.DrawCredits(var Surface: TSurfaceDesc);
var
  X, Y, I, Duration: Integer;
  Info: TShowInfo;
  Lines: TStrings;
begin
  Inc(FCreditFrame);
  Info.ShowMode := smBlended;
  Info.BlendMode := bmAlpha;
  Lines := TStrings(FCredits[FCreditPage]);
  X := Surface.Width div 2;
  Y := Surface.Height div 2 - ((Lines.Count * 25 + FCreditsFont.Height) div 2 + 35);
  Duration := Lines.Count * 30 + 70;
  if Lines.Count > 0 then
  begin
    Info.BlendPercentage := FCreditFrame;
    if Info.BlendPercentage > Duration then
      Info.BlendPercentage := 100 - (Info.BlendPercentage - Duration) * 5
    else Info.BlendPercentage := Info.BlendPercentage * 10;
    if Info.BlendPercentage > 0 then
      if Info.BlendPercentage < 100 then
        FCreditsFont.SetTextEx(X, Y, Lines[0], Surface, [stmCenter], Info)
      else FCreditsFont.SetTextCentered(X, Y, Lines[0], Surface);
    for I := 1 to Lines.Count - 1 do
    begin
      if FCreditFrame > Duration then Info.BlendPercentage := 100 - (FCreditFrame - Duration) * 5
      else Info.BlendPercentage := (FCreditFrame - (I * 30 + 20)) * 10;
      if Info.BlendPercentage > 0 then
        if Info.BlendPercentage < 100 then
          FCreditsFont.SetTextEx(X, Y + I * 25 + 5, Lines[I], Surface, [stmCenter], Info)
        else FCreditsFont.SetTextCentered(X, Y + I * 25 + 5, Lines[I], Surface);
    end;
  end;
  if FCreditFrame > Duration + 20 then
  begin
    Inc(FCreditPage);
    if FCreditPage >= FCredits.Count then
    begin
      FTotalFrame := 0;
      FShowCredits := False;
    end
    else FCreditFrame := 0;
  end;
end;

procedure TTitleScene.DrawIntro(var Surface: TSurfaceDesc);
var
  X, Y, Page, Frame, Opacity: Integer;
  Info: TShowInfo;
  Text: string;
begin
  Inc(FIntroFrame);
  X := Surface.Width div 2;
  Y := Surface.Height div 2;
  Page := FIntroFrame div 130;
  Frame := FIntroFrame mod 130;
  case Frame of
    0..10: Opacity := Frame * 10;
    11..30: Opacity := 100;
    31..40: Opacity := 100 - (Frame - 30) * 10;
  else Opacity := 0;
  end;
  if Opacity <> 0 then
  begin
    case Page of
      0: Text := TranslateRStr(CoDevelopedByRStr);
      1: Text := TranslateRStr(CoPublishedByRStr);
      2: Text := '';
    end;
    if Opacity < 100 then
    begin
      Info.ShowMode := smBlended;
      Info.BlendMode := bmAlpha;
      Info.BlendPercentage := Opacity;
      FCreditsFont.SetTextEx(X, Y - FCreditsFont.Height div 2, Text, Surface, [stmCenter], Info);
    end
    else FCreditsFont.SetTextCentered(X, Y - FCreditsFont.Height div 2, Text, Surface);
  end;
  if (Frame > 45) and (Frame < 130) then
    case Page of
      0: begin
        if TitleSceneIL[4] <> nil then TitleSceneIL[4].ShowClipped(X - 75 - TitleSceneIL[4].Width div 2, Y - TitleSceneIL[4].Height div 2, Surface);
        if TitleSceneIL[5] <> nil then TitleSceneIL[5].ShowClipped(X + 75 - TitleSceneIL[5].Width div 2, Y - TitleSceneIL[5].Height div 2, Surface);
      end;
      1: begin
        FCreditsFont.SetTextCentered(X - 75, Y - TitleSceneIL[6].Height div 2 - 20, TranslateRStr(NorthAmericaRStr), Surface);
        FCreditsFont.SetTextCentered(X + 90, Y - TitleSceneIL[6].Height div 2 - 20, TranslateRStr(EuropeRStr), Surface);
        if TitleSceneIL[6] <> nil then TitleSceneIL[6].ShowClipped(X - 75 - TitleSceneIL[6].Width div 2, Y - TitleSceneIL[6].Height div 2 + 20, Surface);
        if TitleSceneIL[2] <> nil then TitleSceneIL[2].ShowClipped(X + 90 - TitleSceneIL[2].Width div 2, Y - TitleSceneIL[2].Height div 2 + 20, Surface);
      end;
      2: begin
        case Frame of
          45..55: Opacity := (Frame - 45) * 10;
          121..130: Opacity := 100 - (Frame - 120) * 10;
        else Opacity := 101;
        end;
        if Opacity < 101 then
        begin
          Info.ShowMode := smBlended;
          Info.BlendMode := bmAlpha;
          Info.BlendPercentage := Opacity;
          FCreditsFont.SetTextEx(X, Y - FCreditsFont.Height div 2, 'Copyright (C) 1999,2000 Triumph Studios', Surface, [stmCenter], Info);
        end
        else FCreditsFont.SetTextCentered(X, Y - FCreditsFont.Height div 2, 'Copyright (C) 1999,2000 Triumph Studios', Surface);
      end;
    end;
  if Page = 3 then FShowIntro := False;
end;

procedure TTitleScene.DrawScene(var Surface: TSurfaceDesc);
var
  X, Y, Frame, Spacing, I, Image: Integer;
  R: TRect;
begin
  FSceneRect.Left := 0;
  FSceneRect.Right := Surface.Width;
  FSceneRect.Top := Surface.Height div 2 - 240;
  FSceneRect.Bottom := Surface.Height div 2 + 240;
  if FRedrawBackground then
  begin
    R := FSceneRect;
    Inc(R.Top, TitleSceneIL[0].Height);
    ColorFillSD(R, 0, Surface);
  end;
  Y := FSceneRect.Top;
  Frame := FFrame - 25;
  if Frame < 0 then Frame := 0;
  X := -((Frame + 490) mod TitleSceneIL[0].Width);
  TitleSceneIL[0].ShowClipped(X, Y, Surface);
  X := X + TitleSceneIL[0].Width;
  TitleSceneIL[0].ShowClipped(X, Y, Surface);
  if not FShowCredits and (FFrame > 25) then
  begin
    if FFrame < 75 then Image := (FFrame - 25) * 2
    else if FTotalFrame < 731 then Image := 100
    else Image := (750 - FTotalFrame) * 5;
    X := (FSceneRect.Right - FSceneRect.Left - TitleSceneIL[1].Width) div 2;
    if Image < 100 then TitleSceneIL[1].ShowBlended(X, Y + 10, Surface, AlphaBlendTable.Lookup[Image])
    else TitleSceneIL[3].ShowClipped(X, Y + 10, Surface);
  end;
  Spacing := 120;
  X := (TitleSceneIL[10].Width + FSceneRect.Left + FSceneRect.Right) div 2 - 320;
  for I := 0 to 4 do
  begin
    if (I = FPressedButton) and (I = HitTest) then Image := 2
    else if (FPressedButton = -1) and (I = FHoverButton) then Image := 1
    else Image := 0;
    TitleSceneIL[I * 3 + 10 + Image].ShowClipped(X + Spacing * I, Y + 355, Surface);
    if I = HitTest then
    begin
      FFont.Color := $FFFFFF;
      FFont.SetTextCentered(X + Spacing * I + TitleSceneIL[10].Width div 2, Y + 445, TranslateRStr(TitleButtons[I]), Surface);
    end;
    if AoWEngine.FAnimationDetail = 2 then TitleSceneIL[25].ShowClipped(X + Spacing * I, Y + 355, Surface);
  end;
  if FShowCredits then DrawCredits(Surface);
  if FShowIntro then DrawIntro(Surface);
end;

procedure TTitleScene.HideScene;
begin
  Window.Visible := False;
end;

procedure TTitleScene.ResetScene;
begin
  FHoverButton := -1;
  FFrame := 0;
  FTotalFrame := 0;
  FShowCredits := False;
  FTotalFrame := 0; { Original repeats the total-frame reset. }
  FShowIntro := False;
end;

procedure TTitleScene.AdvanceFrame;
begin
  Inc(FFrame);
  Inc(FTotalFrame);
  if not FShowCredits and (FTotalFrame = 750) then
  begin
    FCreditPage := 0;
    FCreditFrame := 0;
    FShowCredits := True;
  end;
  if not FShowIntro and (FTotalFrame = 300) then
  begin
    FIntroFrame := 0;
    FShowIntro := True;
  end;
end;

function TTitleScene.HitTest: Integer;
var
  Found: Boolean;
  X, Spacing: Integer;
begin
  if (FSceneRect.Bottom - 125 < FMouseY) and (FMouseY < FSceneRect.Bottom) then
  begin
    Spacing := 120;
    X := (TitleSceneIL[10].Width + (FSceneRect.Left + FSceneRect.Right)) div 2 - 320;
    Result := 5;
    Found := False;
    while (Result <> 0) and not Found do
    begin
      Dec(Result);
      Found := (Spacing * Result + X < FMouseX) and
        (TitleSceneIL[10].Width + X + Spacing * Result > FMouseX);
    end;
    if not Found then Result := -1;
  end
  else Result := -1;
end;

procedure TTitleScene.WindowDrawSurfaceEx(Surface: TSurface; var Drawn: Boolean);
var
  SD: TSurfaceDesc;
begin
  try
    if Windows.Succeeded(Surface.Lock(SD)) then
    begin
      DrawScene(SD);
      if AoWEngine.RegisteredVersion and not FShowCredits then
      begin
        LegalNotice.Draw(SD);
        StrLbl.Draw(SD);
        NameLbl.Draw(SD);
      end;
      Version.Draw(SD);
      Surface.Unlock;
    end;
    Drawn := True;
  except
    raise Exception.Create('Failure during TitleScene DrawSurface');
  end;
end;

procedure TTitleScene.TitleSceneCreate;
var
  Lines: TStringList;
begin
  ResetScene;
  NameLbl.Text := AoWEngine.RegisteredTo;
  Version.Text := AoWE.Format(TranslateRStr(VersionXRStr), [AoWEngine.GetVersionStr]);
  FCredits := TList.Create;
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(DesignerAndDirectorRStr));
  Lines.Add('Lennart Sas');
  Lines.Add('');
  Lines.Add(TranslateRStr(AdditionalDesignRStr));
  Lines.Add('Arno van Wingerden');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(LeadProgrammerRStr));
  Lines.Add('Arno van Wingerden');
  Lines.Add('');
  Lines.Add(TranslateRStr(ProgrammerRStr));
  Lines.Add('Josh Farley');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(ArtistsRStr));
  Lines.Add('Lennart Sas');
  Lines.Add('Thomas Cardin');
  Lines.Add('Roy Postma');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(LeadScenarioDesignerRStr));
  Lines.Add('Menno Sas');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(ScenarioDesignersRStr));
  Lines.Add('Doug Gibson');
  Lines.Add('Arnout Sas');
  Lines.Add('Hugo van Wingerden');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(WriterRStr));
  Lines.Add('Raymond Bingham');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(MusicRStr));
  Lines.Add('Michiel van den Bos');
  Lines.Add('');
  Lines.Add(TranslateRStr(SoundFXRStr));
  Lines.Add('Nando Eweg');
  FCredits.Add(Lines);
  Lines.Add('');
  Lines.Add(TranslateRStr(IntroVoiceRStr));
  Lines.Add('John McGinn (English)');
  Lines.Add('Norbert Gastell (German)');
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(GalaxySoundSystemRStr));
  Lines.Add('Carlo Vogelsang');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(InternetMailSuiteRStr));
  Lines.Add('Argo Software Design');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(QACoreRStr));
  Lines.Add('Cliff Benjamin');
  Lines.Add('Ian Calderon');
  Lines.Add('Ted Stephenson');
  Lines.Add('Hugo van Wingerden');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr('Take 2 Europe'));
  Lines.Add('');
  Lines.Add('Producer');
  Lines.Add('Ken Jordan');
  Lines.Add('');
  Lines.Add('Manuals + Translations');
  Lines.Add('Frazer Nash');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add('Tarantula Studios testing suite');
  Lines.Add('');
  Lines.Add('Test Manager');
  Lines.Add('Mark Lloyd');
  Lines.Add('');
  Lines.Add('Lead Tester');
  Lines.Add('Paul Byers');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add('Testers');
  Lines.Add('');
  Lines.Add('Jim Thompson');
  Lines.Add('Kit Brown');
  Lines.Add('Julian Turner');
  Lines.Add('Jim Cree');
  Lines.Add('Lee Johnson');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(BizzRStr));
  Lines.Add('Jay Wilbur');
  Lines.Add('Mark Rein');
  FCredits.Add(Lines);
  Lines := TStringList.Create;
  Lines.Add(TranslateRStr(SpecialThanksRStr));
  Lines.Add('Eelco van der Snoek');
  Lines.Add('Doug Gibson');
  Lines.Add('Dietmer Tan');
  Lines.Add('Arjan Brussee');
  Lines.Add('Daniel Cook');
  FCredits.Add(Lines);
end;

procedure TTitleScene.TitleSceneDestroy;
var
  I: Integer;
begin
  for I := FCredits.Count - 1 downto 0 do TObject(FCredits.List^[I]).Free;
  FCredits.Free;
end;

procedure TTitleScene.WindowUpdate;
begin
  Window.FSurfaceValid := False;
  if not FileDlgWindow.FileDialog.Visible and not ProgressDialog.ProgDlg.Visible then AdvanceFrame;
end;

procedure TTitleScene.WindowMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseX := X;
  FMouseY := Y;
  FMouseButton := Button;
  FPressedButton := HitTest;
end;

procedure TTitleScene.WindowMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FMouseX := X;
  FMouseY := Y;
  if FHoverButton <> -1 then FRedrawBackground := True;
  FHoverButton := HitTest;
end;

procedure TTitleScene.WindowMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseX := X;
  FMouseY := Y;
  FMouseButton := Button;
  if HitTest = FPressedButton then
  begin
    FSelectedButton := FPressedButton;
    case FSelectedButton of
      0: begin
        Window.Visible := False;
        General.PlayButtonSound(0);
        ShowMultiplayer(MultiWindow, '');
      end;
      1: if not AoWEngine.FDemo then
        begin
          Window.Visible := False;
          General.PlayButtonSound(0);
          ShowFactionSelection(SelFactionWin);
        end
        else ShowDemoMessage;
      2: begin
        LoadGame(General, AoWEngine.StartupDirectory + 'Scenario\Custom\' + 'TUTORIAL.HSM');
        if AoWHSMap <> nil then
        begin
          AoWHSMap.FFixedLeaders := True;
          StartGame(General);
          Window.Visible := False;
        end;
      end;
      3: begin
        General.PlayButtonSound(0);
        FileDlgWindow.FMode := 0;
        FileDlgWindow.FileDialog.Visible := True;
      end;
      4: begin
        Window.Visible := False;
        General.PlayButtonSound(0);
        if AoWEngine.FDemo then ShowExitSplash(TitleWindow)
        else MainForm.Close;
      end;
    end;
  end;
  FPressedButton := -1;
end;

procedure TTitleScene.WindowHide;
begin
  Window.WinManager.ILIndexTBack := 0;
  MainForm.Display.FrameRate := 30;
  MainForm.DXDC.UseVerticalBlank := False;
  Window.Visible := False;
  TitleSceneIL.ReleaseDiscardableImageData;
end;


initialization
  TitleButtons[0] := TitleNewGameRStr;
  TitleButtons[1] := TitleCampaignRStr;
  TitleButtons[2] := TitleTutorialRStr;
  TitleButtons[3] := TitleLoadGameRStr;
  TitleButtons[4] := TitleExitRStr;

end.
