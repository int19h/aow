unit AoWWorldMap;

{ Draft declarations of AoWWorldMap, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWVideoDlg, AoWComp, AoWBookWindow, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWVScroll;

type
  TWorldMap = class;
  TFileTime = class;


  { TWorldMap: size $16C; $13C star image, $140/$144 brightness, $148/$14C path animation, $150/$154 pawn timing, $158 hover, $15C context, $160 completion event, $168 book action. VMT 0041B5B8. }
  TWorldMap = class(TDataModule)
  public
    published
    MemoL: TAOWMemo; { +0044 }
    PicR: TAOWImage; { +0048 }
    WorldPnl: TAOWPanel; { +004C }
    Path1: TAOWImage; { +0050 }
    Path2: TAOWImage; { +0054 }
    Path3: TAOWImage; { +0058 }
    PPawn: TAOWImage; { +005C }
    EPawn: TAOWImage; { +0060 }
    DescLbl: TAOWLabel; { +0064 }
    Back: TAOWButton; { +0068 }
    Next: TAOWButton; { +006C }
    Cancel: TAOWButton; { +0070 }
    BookStart: TAOWButton; { +0074 }
    LabelL: TAOWLabel; { +0078 }
    MemoR: TAOWMemo; { +007C }
    LabelR: TAOWLabel; { +0080 }
    PicL: TAOWImage; { +0084 }
    BookWin: TAoWBookWindow; { +0088 }
    InfoPnl: TAOWPanel; { +008C }
    Elves: TAOWLabel; { +0090 }
    Halflings: TAOWLabel; { +0094 }
    Goblins: TAOWLabel; { +0098 }
    Orcs: TAOWLabel; { +009C }
    Dwarves: TAOWLabel; { +00A0 }
    Undead: TAOWLabel; { +00A4 }
    Highmen: TAOWLabel; { +00A8 }
    Lizardmen: TAOWLabel; { +00AC }
    DarkElves: TAOWLabel; { +00B0 }
    VoW: TAOWLabel; { +00B4 }
    ElvenC: TAOWLabel; { +00B8 }
    IoLG: TAOWLabel; { +00BC }
    Deepmir: TAOWLabel; { +00C0 }
    Aldor: TAOWLabel; { +00C4 }
    Serpent: TAOWLabel; { +00C8 }
    Blackwater: TAOWLabel; { +00CC }
    Skull: TAOWLabel; { +00D0 }
    Sylvanus: TAOWLabel; { +00D4 }
    Pass: TAOWLabel; { +00D8 }
    Arcalot: TAOWLabel; { +00DC }
    Flowershire: TAOWLabel; { +00E0 }
    Sobek: TAOWLabel; { +00E4 }
    Steppe: TAOWLabel; { +00E8 }
    Bronnam: TAOWLabel; { +00EC }
    UC: TAOWLabel; { +00F0 }
    Woods: TAOWLabel; { +00F4 }
    Burbatak: TAOWLabel; { +00F8 }
    QuitBtn: TAOWButton; { +00FC }
    ShowBtn: TAOWButton; { +0100 }
    SelectLbl: TAOWLabel; { +0104 }
    AlliesLnl: TAOWLabel; { +0108 }
    Frame: TAOWPanel; { +010C }
    Azrac: TAOWLabel; { +0110 }
    StarImg: TAOWImage; { +0114 }
    Terstar: TAOWLabel; { +0118 }
    HeroPnl: TAoWFrame; { +011C }
    Ally1Pnl: TAoWFrame; { +0120 }
    Ally2Pnl: TAoWFrame; { +0124 }
    Ally3Pnl: TAoWFrame; { +0128 }
    SetBtn: TAOWButton; { +012C }
    Translator: TIvTranslator; { +0130 }
    leftSB: TAOWVScrollBar; { +0134 }
    rightSB: TAOWVScrollBar; { +0138 }
    public
    FStarImage: Integer; { $13C }
    FStarStep: Integer; { $140 }
    FStarIntensity: Integer; { $144 }
    FPathFrame: Integer; { $148 }
    FPathDelay: Integer; { $14C }
    FPawnTicks: Integer; { $150 }
    FEnemyDelay: Integer; { $154 }
    FDescriptionHandled: Boolean; { $158 }
    F_WorldMap_159: array[0..2] of Byte; FBookContext: TEObject; { $15C } FOnBookClosed: TNotifyEvent; { $160 }
    FBookAction: Byte; { $168 }
    F_WorldMap_169: array[0..2] of Byte;
    function GetCampaign: TWMCampaign;
    procedure UpdateCampaignState; { unrecovered; 0041CA5C }
    procedure BookClosed;
    procedure BackClick;
    procedure NextStartClick;
    procedure WorldPnlUpdate;
    procedure Path1MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Path2MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Path3MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CancelClick;
    procedure PPawnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PPawnMouseMove(A1: Integer);  { draft }
    procedure Path1MouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer);
    procedure Path2MouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer);
    procedure Path3MouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer);
    procedure WorldPnlMouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer);
    procedure BookStartClick;
    procedure BookWinAnimDone;
    procedure BookWinShow;
    procedure BookWinUpdate;
    procedure ShowBtnClick;  { draft }
    procedure QuitBtnClick;  { draft }
    procedure StarImgUpdate;
    procedure StarImgDraw(A1: Integer; A2: Integer);  { draft }
    procedure Ally1PnlPreDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure Ally2PnlPreDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure Ally3PnlPreDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure HeroPnlPreDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure SetBtnClick;  { draft }
    procedure BookWinHide;
  end;

  { TFileTime (instance size 12, VMT 0041EB14) }
  TFileTime = class(TObject)
  public
    FTime: TDateTime; { $04; 0041F71B }
  end;


function GetCampaignPage(Pages: TWMCampaignScenarioPageList; Index: Integer): TWMCampaignScenarioPage;

implementation

uses AoWExeForms, AoWWinMan, E2CampaignSupport, PageTurnCtrl;

var
  BookStartVisible: Boolean;

function GetCampaignPage(Pages: TWMCampaignScenarioPageList; Index: Integer): TWMCampaignScenarioPage;
begin
  Result := TWMCampaignScenarioPage(Pages.FChildren.List^[Index]);
end;

function TWorldMap.GetCampaign: TWMCampaign;
begin
  Result := TWMCampaign(AoWEngine.FCampaign);
end;

procedure TWorldMap.UpdateCampaignState;
begin
  { Original 0041CA5C; the campaign state view is still unrecovered. }
end;

procedure TWorldMap.BookClosed;
var
  Done: TNotifyEvent;
  Context: TEObject;
begin
  Done := FOnBookClosed;
  Context := FBookContext;
  FOnBookClosed := nil;
  FBookContext := nil;
  if Assigned(Done) then Done(Context);
  if Context <> nil then Context.Release;
  General.Manager.OverlayPriority := 0;
end;

procedure TWorldMap.BackClick;
begin
  Back.CaptureInput := False;
  Next.CaptureInput := False;
  with BookStart do
  begin
    CaptureInput := False;
    Visible := False;
  end;
  with BookWin do
  begin
    FDrawn := False;
    if FBackSurface <> nil then FBackSurface.Cls(FMaskColor);
  end;
  PlaySample('Sfx\Int\Pagef1.wav');
  FBookAction := 1;
end;


procedure TWorldMap.NextStartClick;
begin
  Back.CaptureInput := False;
  Next.CaptureInput := False;
  BookStart.CaptureInput := False;
  PlaySample('Sfx\Int\Pagef1.wav');
  FBookAction := 2;
end;


procedure TWorldMap.WorldPnlUpdate;
var
  Frame, StartIndex, EndIndex: Integer;
begin
  if WorldPnl.Visible and not BookWin.Visible then
  begin
    Path1.FDrawn := False;
    Path2.FDrawn := False;
    Path3.FDrawn := False;
    PPawn.FDrawn := False;
    EPawn.FDrawn := False;
    Dec(FPathDelay);
    if FPathDelay < 1 then
    begin
      FPathDelay := 5;
      Frame := 1 - FPathFrame;
      FPathFrame := Frame;
      Path1.CurrentImage := GetCampaign.FFaction * 3 + (Frame + 2);
      Path2.CurrentImage := GetCampaign.FFaction * 3 + (FPathFrame + 2);
      Path3.CurrentImage := GetCampaign.FFaction * 3 + (FPathFrame + 2);
    end;
    if GetCampaign.FState = 5 then
    begin
      if FPawnTicks > 0 then
      begin
        PPawn.WinLeft := (GetCampaignScenario(GetCampaign, GetCampaign.FNextScenarioID).FMapX -
          GetCampaignScenario(GetCampaign, GetCampaign.FCurrentScenarioID).FMapX) * (20 - FPawnTicks) div 19 +
          GetCampaignScenario(GetCampaign, GetCampaign.FCurrentScenarioID).FMapX - 25;
        PPawn.WinTop := (GetCampaignScenario(GetCampaign, GetCampaign.FNextScenarioID).FMapY -
          GetCampaignScenario(GetCampaign, GetCampaign.FCurrentScenarioID).FMapY) * (20 - FPawnTicks) div 19 +
          GetCampaignScenario(GetCampaign, GetCampaign.FCurrentScenarioID).FMapY - 65;
        if EPawn.WinTop < PPawn.WinTop then
        begin PPawn.Priority := 10; EPawn.Priority := 5; end
        else
        begin PPawn.Priority := 5; EPawn.Priority := 10; end;
      end
      else
      begin
        FPawnTicks := 20;
        FEnemyDelay := 30;
        Inc(GetCampaign.FState);
        if DescLbl.Text <> GetCampaignScenario(GetCampaign, GetCampaign.FNextScenarioID).FDescription then
        begin
          DescLbl.Text := GetCampaignScenario(GetCampaign, GetCampaign.FNextScenarioID).FDescription;
          with DescLbl do WinTop := 460 - WinHeight;
          FDescriptionHandled := True;
        end;
      end;
      Dec(FPawnTicks);
    end;
    if GetCampaign.FState = 6 then
    begin
      if FPawnTicks > 0 then
      begin
        FDescriptionHandled := True;
        StartIndex := GetCampaign.FScenarios.IndexOfID(
          GetCampaignScenario(GetCampaign, GetCampaign.FCurrentScenarioID).FPaths[3]);
        EndIndex := GetCampaign.FScenarios.IndexOfID(
          GetCampaignScenario(GetCampaign, GetCampaign.FNextScenarioID).FPaths[3]);
        if (StartIndex <> -1) and (EndIndex <> -1) then
        begin
          EPawn.WinLeft := (GetCampaignScenario(GetCampaign, EndIndex).FMapX -
            GetCampaignScenario(GetCampaign, StartIndex).FMapX) * (20 - FPawnTicks) div 19 +
            GetCampaignScenario(GetCampaign, StartIndex).FMapX - 25;
          EPawn.WinTop := (GetCampaignScenario(GetCampaign, EndIndex).FMapY -
            GetCampaignScenario(GetCampaign, StartIndex).FMapY) * (20 - FPawnTicks) div 19 +
            GetCampaignScenario(GetCampaign, StartIndex).FMapY - 65;
          if EPawn.WinTop < PPawn.WinTop then
          begin PPawn.Priority := 10; EPawn.Priority := 5; end
          else
          begin PPawn.Priority := 5; EPawn.Priority := 10; end;
        end;
      end
      else
      begin
        if FEnemyDelay > 0 then
      Dec(FEnemyDelay)
      else
      begin
          Inc(GetCampaign.FState);
          UpdateCampaignState;
        end;
      end;
      Dec(FPawnTicks);
    end;
  end;
end;


procedure TWorldMap.Path1MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not BookWin.Visible then
    if GetCampaign.FState = 1 then
    begin
      DescLbl.Text := '';
      SelectCampaignPath(GetCampaign, 0);
      UpdateCampaignState;
    end;
end;


procedure TWorldMap.Path2MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not BookWin.Visible then
    if GetCampaign.FState = 1 then
    begin
      DescLbl.Text := '';
      SelectCampaignPath(GetCampaign, 1);
      UpdateCampaignState;
    end;
end;


procedure TWorldMap.Path3MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not BookWin.Visible then
    if GetCampaign.FState = 1 then
    begin
      DescLbl.Text := '';
      SelectCampaignPath(GetCampaign, 2);
      UpdateCampaignState;
    end;
end;


procedure TWorldMap.CancelClick;
begin
  GetCampaign.ResetNextScenario;
  GetCampaign.FState := 1;
  PlaySample('Sfx\Int\BookClse.wav');
  UpdateCampaignState;
end;


procedure TWorldMap.PPawnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (X > 20) and (Sender = PPawn) then
    if GetCampaign.FState = 1 then
    begin
      GetCampaign.FState := 0;
      GetCampaign.FPage := 0;
      UpdateCampaignState;
    end;
  TAoWComponent(Sender).FHandled := False; { Original hit test uses X. }
end;


procedure TWorldMap.PPawnMouseMove(A1: Integer);
begin end;

procedure TWorldMap.Path1MouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  if GetCampaign.FState = 1 then
  begin
    Index := GetCampaign.FScenarios.IndexOfID(
      GetCampaignScenario(GetCampaign, GetCampaign.FCurrentScenarioID).FPaths[0]);
    if DescLbl.Text <> GetCampaignScenario(GetCampaign, Index).FPathDescription then
    begin
      DescLbl.Text := GetCampaignScenario(GetCampaign, Index).FPathDescription;
      with DescLbl do WinTop := 460 - WinHeight;
    end;
  end;
  FDescriptionHandled := True;
end;


procedure TWorldMap.Path2MouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  if GetCampaign.FState = 1 then
  begin
    Index := GetCampaign.FScenarios.IndexOfID(
      GetCampaignScenario(GetCampaign, GetCampaign.FCurrentScenarioID).FPaths[1]);
    if DescLbl.Text <> GetCampaignScenario(GetCampaign, Index).FPathDescription then
    begin
      DescLbl.Text := GetCampaignScenario(GetCampaign, Index).FPathDescription;
      with DescLbl do WinTop := 460 - WinHeight;
    end;
  end;
  FDescriptionHandled := True;
end;


procedure TWorldMap.Path3MouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  if GetCampaign.FState = 1 then
  begin
    Index := GetCampaign.FScenarios.IndexOfID(
      GetCampaignScenario(GetCampaign, GetCampaign.FCurrentScenarioID).FPaths[2]);
    if DescLbl.Text <> GetCampaignScenario(GetCampaign, Index).FPathDescription then
    begin
      DescLbl.Text := GetCampaignScenario(GetCampaign, Index).FPathDescription;
      with DescLbl do WinTop := 460 - WinHeight;
    end;
  end;
  FDescriptionHandled := True;
end;


procedure TWorldMap.WorldPnlMouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer);
begin
  if not FDescriptionHandled then
    if (GetCampaign.FState = 1) and (DescLbl.Text <> '') then DescLbl.Text := '';
  FDescriptionHandled := False;
end;


procedure TWorldMap.BookStartClick;
begin
  BookWin.Visible := False;
  PlaySample('Sfx\Int\BookClse.wav');
  if not WorldPnl.Visible then General.Manager.OverlayPriority := 0;
  if WorldPnl.Visible then
  begin
    FPawnTicks := 20;
    Inc(GetCampaign.FState);
    UpdateCampaignState;
  end;
end;


procedure TWorldMap.BookWinAnimDone;
begin
  Back.CaptureInput := True;
  Next.CaptureInput := True;
  BookStart.CaptureInput := True;
  BookWin.FHidden := True;
end;


procedure TWorldMap.BookWinShow;
begin FBookAction := 0; end;


procedure TWorldMap.BookWinUpdate;
var
  R: TRect;
begin
  case FBookAction of
    1: FBookAction := 3;
    2: FBookAction := 4;
    3: begin
      BookWin.StartAnim(TPageTurnMode(1));
      Dec(GetCampaign.FPage, 2);
      UpdateCampaignState;
      FBookAction := 0;
    end;
    4: begin
      BookWin.StartAnim(TPageTurnMode(0));
      Inc(GetCampaign.FPage, 2);
      UpdateCampaignState;
      FBookAction := 0;
    end;
  end;
  if BookStart.Visible <> BookStartVisible then
  begin
    with BookStart do
      R := Rect(BookWin.WinLeft + WinLeft, BookWin.WinTop + WinTop,
        BookWin.WinLeft + WinLeft + WinWidth,
        BookWin.WinTop + WinTop + WinHeight);
    General.Manager.AddBltRect(R, BookWin);
    BookStartVisible := BookStart.Visible;
  end;
end;


procedure TWorldMap.ShowBtnClick;
begin end;

procedure TWorldMap.QuitBtnClick;
begin end;

procedure TWorldMap.StarImgUpdate;
begin
  Inc(FStarIntensity, FStarStep);
  if FStarIntensity + FStarStep > 100 then FStarStep := -1;
  if FStarIntensity + FStarStep < 50 then FStarStep := 1;
  StarImg.FDrawn := False;
end;


procedure TWorldMap.StarImgDraw(A1: Integer; A2: Integer);
begin end;

procedure TWorldMap.Ally1PnlPreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  with Ally1Pnl do
    R := Rect(InfoPnl.WinLeft + WinLeft, InfoPnl.WinTop + WinTop,
      InfoPnl.WinLeft + WinLeft + WinWidth,
      InfoPnl.WinTop + WinTop + WinHeight);
  if GetCampaign.FRaceHistory.Count > 0 then
    AoWHSSet.FRaceResources.GetRaceResource(GetCampaign.FRaceHistory[0]).GetFace.ShowStretched(R, Surface);
end;


procedure TWorldMap.Ally2PnlPreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  with Ally2Pnl do
    R := Rect(InfoPnl.WinLeft + WinLeft, InfoPnl.WinTop + WinTop,
      InfoPnl.WinLeft + WinLeft + WinWidth,
      InfoPnl.WinTop + WinTop + WinHeight);
  if GetCampaign.FRaceHistory.Count > 1 then
    AoWHSSet.FRaceResources.GetRaceResource(GetCampaign.FRaceHistory[1]).GetFace.ShowStretched(R, Surface);
end;


procedure TWorldMap.Ally3PnlPreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  with Ally3Pnl do
    R := Rect(InfoPnl.WinLeft + WinLeft, InfoPnl.WinTop + WinTop,
      InfoPnl.WinLeft + WinLeft + WinWidth,
      InfoPnl.WinTop + WinTop + WinHeight);
  if GetCampaign.FRaceHistory.Count > 2 then
    AoWHSSet.FRaceResources.GetRaceResource(GetCampaign.FRaceHistory[2]).GetFace.ShowStretched(R, Surface);
end;


procedure TWorldMap.HeroPnlPreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  with HeroPnl do
    R := Rect(InfoPnl.WinLeft + WinLeft, InfoPnl.WinTop + WinTop,
      InfoPnl.WinLeft + WinLeft + WinWidth,
      InfoPnl.WinTop + WinTop + WinHeight);
  if GetCampaign.FTransferSettings.FLeader <> nil then
    GetCampaign.FTransferSettings.FLeader.ShowFace(R, Surface);
end;


procedure TWorldMap.SetBtnClick;
begin end;

procedure TWorldMap.BookWinHide;
begin BookClosed; end;


end.
