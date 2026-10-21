unit AoWSelFactionWin;

{ AoWSelFactionWin handlers recovered from AoW.exe.
  Class layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWImage, AoWLabel, AoWMemo, AoWPanel;

type
  TSelFactionWin = class;


  { TSelFactionWin (instance size 144, VMT 00418940) }
  TSelFactionWin = class(TDataModule)
  public
    published
    FactionPnl: TAOWPanel; { +0044 }
    TopLbl: TAOWLabel; { +0048 }
    LightPnl: TAOWPanel; { +004C }
    LText: TAOWMemo; { +0050 }
    LStart: TAOWButton; { +0054 }
    LBack: TAOWButton; { +0058 }
    LSphere: TAOWImage; { +005C }
    DarkPnl: TAOWPanel; { +0060 }
    DStart: TAOWButton; { +0064 }
    DBack: TAOWButton; { +0068 }
    LName: TAOWLabel; { +006C }
    DText: TAOWMemo; { +0070 }
    DName: TAOWLabel; { +0074 }
    DSphere: TAOWImage; { +0078 }
    Translator: TIvTranslator; { +007C }
    public
    FFade: Integer; { $80 }
    FFadeImage: Integer; { $84 }
    FFadeDirection: Integer; { $88 }
    F_SelFactionWin_8C: array[0..3] of Byte;
    procedure CloseSelection;
    procedure LStartClick(Sender: TObject);
    procedure LightPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DarkPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LBackClick;
    procedure DBackClick;
    procedure FactionPnlMouseMove;
    procedure LightPnlMouseMove;
    procedure DarkPnlMouseMove;
    procedure AbortBtnClick;
    procedure FactionPnlUpdate;
    procedure FactionPnlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


var
  SelFactionWin: TSelFactionWin;

implementation

uses AoWE, AoWExeForms, AoWWinMan, E2Globals, E2GameFlow;

procedure TSelFactionWin.CloseSelection;
begin
  IntGfxMod.FactionWin.ReleaseDiscardableImageData;
  TitleWindow.TitleWin.Visible := False;
  ShowTitleScene(TitleScene, True);
  FactionPnl.Visible := False;
  FFade := 0;
end;

procedure TSelFactionWin.LStartClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  IntGfxMod.FactionWin.ReleaseDiscardableImageData;
  FactionPnl.Visible := False;
  FFade := 0;
  if Sender = LStart then StartCampaignJoin(CampaignJoinDlg, 0)
  else StartCampaignJoin(CampaignJoinDlg, 1);
end;

procedure TSelFactionWin.LightPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not DName.Visible and not LName.Visible then
  begin
    DName.Visible := True;
    DText.Visible := True;
    DBack.Visible := True;
    DStart.Visible := True;
    DBack.CaptureInput := True;
    DStart.CaptureInput := True;
    TopLbl.Visible := False;
    FFade := 100;
    FactionPnl.ILIndexTexture := 2;
    FFadeImage := 0;
    FFadeDirection := 1;
  end;
end;

procedure TSelFactionWin.DarkPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not LName.Visible and not DName.Visible then
  begin
    LName.Visible := True;
    LText.Visible := True;
    LBack.Visible := True;
    LStart.Visible := True;
    LBack.CaptureInput := True;
    LStart.CaptureInput := True;
    TopLbl.Visible := False;
    FFade := 100;
    FactionPnl.ILIndexTexture := 1;
    FFadeImage := 0;
    FFadeDirection := 1;
  end;
end;

procedure TSelFactionWin.LBackClick;
begin
  General.PlayButtonSound(0);
  LBack.CaptureInput := False;
  LStart.CaptureInput := False;
  FFade := 100;
  FFadeImage := 0;
  FFadeDirection := 0;
end;

procedure TSelFactionWin.DBackClick;
begin
  General.PlayButtonSound(0);
  DBack.CaptureInput := False;
  DStart.CaptureInput := False;
  FFade := 100;
  FFadeImage := 0;
  FFadeDirection := 0;
end;

procedure TSelFactionWin.FactionPnlMouseMove;
begin
  if not LightPnl.FHandled and not DName.Visible and not DarkPnl.FHandled and not LName.Visible then
  begin
    DSphere.Visible := False;
    LSphere.Visible := False;
    TopLbl.Text := TranslateRStr(ChooseFactionRStr);
  end;
end;

procedure TSelFactionWin.LightPnlMouseMove;
begin
  if not LName.Visible and not DSphere.Visible then
  begin
    DSphere.Visible := True;
    LSphere.Visible := False;
    TopLbl.Text := TranslateRStr(CultOfStormsRStr);
  end;
end;

procedure TSelFactionWin.DarkPnlMouseMove;
begin
  if not DName.Visible and not LSphere.Visible then
  begin
    DSphere.Visible := False;
    LSphere.Visible := True;
    TopLbl.Text := TranslateRStr(KeepersRStr);
  end;
end;

procedure TSelFactionWin.AbortBtnClick;
begin
  General.PlayButtonSound(0);
  CloseSelection;
end;

procedure TSelFactionWin.FactionPnlUpdate;
var
  R: TRect;
begin
  if SelFactionWin.FFade >= 0 then
  begin
    Dec(SelFactionWin.FFade, 6);
    if FFade < 6 then
      if LStart.Visible and not LStart.CaptureInput then
      begin
        LName.Visible := False;
        LText.Visible := False;
        LBack.Visible := False;
        LStart.Visible := False;
        LSphere.Visible := False;
        TopLbl.Visible := True;
        TopLbl.Text := TranslateRStr(ChooseFactionRStr);
        FactionPnl.ILIndexTexture := 0;
      end
      else
        if DStart.Visible and not DStart.CaptureInput then
        begin
          DName.Visible := False;
          DText.Visible := False;
          DBack.Visible := False;
          DStart.Visible := False;
          DSphere.Visible := False;
          TopLbl.Visible := True;
          TopLbl.Text := TranslateRStr(ChooseFactionRStr);
          FactionPnl.ILIndexTexture := 0;
        end;
    with FactionPnl do R := Rect(WinLeft, WinTop, WinLeft + WinWidth, FactionPnl.WinTop + WinHeight);
    TitleWindow.TitleWin.AddBltRect(R, nil);
  end;
end;

procedure TSelFactionWin.FactionPnlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of VK_ESCAPE: CloseSelection; end;
end;

end.
