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
    FCreditPage: Integer; FCreditFrame: Integer; FShowIntro: Boolean; FPadA5: array[0..2] of Byte; FIntroFrame: Integer; FFont: TImageLibraryFont; FReservedB0: Integer; { $9C, $A0, $A4, $A8, $AC }
    procedure ResetScene;
    procedure AdvanceFrame;
    function HitTest: Integer;
    procedure WindowDrawSurfaceEx(A1: Integer; A2: Integer);  { draft }
    procedure TitleSceneCreate;
    procedure TitleSceneDestroy;
    procedure WindowUpdate;  { draft }
    procedure WindowMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WindowMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure WindowMouseUp(A1: Integer; A2: Byte);  { draft }
    procedure WindowHide;
  end;


implementation

uses AoWUnit;

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

procedure TTitleScene.WindowDrawSurfaceEx(A1: Integer; A2: Integer);
begin end;

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
begin end;

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

procedure TTitleScene.WindowMouseUp(A1: Integer; A2: Byte);
begin end;

procedure TTitleScene.WindowHide;
begin
  Window.WinManager.ILIndexTBack := 0;
  MainForm.Display.FrameRate := 30;
  MainForm.DXDC.UseVerticalBlank := False;
  Window.Visible := False;
  TitleSceneIL.ReleaseDiscardableImageData;
end;


end.
