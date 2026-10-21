unit AoWResultsWin;

{ Partly recovered AoWResultsWin handlers, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
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
    F_ResultsWin_E0: array[0..31] of Byte;
    FPlayers: TByteList; { $100 }
    FControls: TList; { $104 }
    procedure ResultsWinCreate;  { draft }
    procedure ResultsWinDestroy;  { draft }
    procedure ContinueBtnClick;  { draft }
    procedure ExitBtnClick;  { draft }
    procedure ResultsPnlUpdate;  { draft }
    procedure AxisDraw(A1: Integer; A2: Integer);  { draft }
    procedure AgendaChange;  { draft }
    procedure ResultsPnlShow;  { draft }
    procedure P1CBPreDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure P1CBChange(Sender: TObject);
  end;


implementation

uses AoWWinMan, E3Globals, AOWPyreScrn, aowIntGfxMod, E1Globals;


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
begin end;

procedure TResultsWin.ExitBtnClick;
begin end;

procedure TResultsWin.ResultsPnlUpdate;
begin
  PyreScreen.DeadPnlUpdate;
end;

procedure TResultsWin.AxisDraw(A1: Integer; A2: Integer);
begin end;

procedure TResultsWin.AgendaChange;
begin
  ResultsPnl.FDrawn := False;
end;

procedure TResultsWin.ResultsPnlShow;
begin end;

procedure TResultsWin.P1CBPreDraw(Sender: TObject; Surface: TSurfaceDesc);
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
begin
  with TAOWCheckBox(Sender) do
  if Checked then
  begin
    if Tag < FPlayers.Count then SideLbl.Text := AoWHSMap.FPlayers.GetPlayers(FPlayers[Tag]).GetNameEx;
    ResValues.Items.Clear;
    ResValues.Items.Add('00');
    ResValues.Items.Add('00');
    ResValues.Items.Add('00');
    ResValues.Items.Add('00');
  end;
end;


end.
