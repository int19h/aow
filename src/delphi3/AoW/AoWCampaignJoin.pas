unit AoWCampaignJoin;

{ Draft declarations of AoWCampaignJoin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWMemo, AoWPanel, aowUserDrawBox, AoWE;

type
  TCampaignJoinDlg = class;


  { TCampaignJoinDlg (instance size $80, VMT 00418020): $68 stage, $6C faction, $70 leader, $74 scroll delay, $78 scroll position, $7C text. }
  TCampaignJoinDlg = class(TDataModule)
  public
    published
    CharGenPnl: TAOWPanel; { +0044 }
    LeaderTypePnl: TAOWPanel; { +0048 }
    CustomBtn: TAOWButton; { +004C }
    DefaultBtn: TAOWButton; { +0050 }
    LeaderTypeMsg: TAOWMemo; { +0054 }
    DefaultFacePnl: TAOWPanel; { +0058 }
    CustomFacePnl: TAOWPanel; { +005C }
    ScrollTextDB: TaowUserDrawBox; { +0060 }
    Translator: TIvTranslator; { +0064 }
    public
    FStage: Byte; { $68 }
    F_CampaignJoinDlg_69: array[0..2] of Byte; FFaction: Integer; { $6C }
    FLeader: TLeader; { $70 }
    FScrollDelay: Integer; { $74 }
    FScrollPosition: Integer; { $78 }
    FScrollText: TStringList; { $7C }
    procedure ShowLeaderChoices;
    procedure CampaignJoinDlgCreate;
    procedure CampaignJoinDlgDestroy;
    procedure CharGenPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DefaultFacePnlDraw(Sender: TObject; SD: TSurfaceDesc);
    procedure CustomBtnClick;  { draft }
    procedure DefaultBtnClick;  { draft }
    procedure ScrollTextDBUpdate;
    procedure ScrollTextDBDraw(Sender: TObject; SD: TSurfaceDesc);
    procedure DefaultFacePnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;


implementation

uses E3Globals;

procedure TCampaignJoinDlg.CampaignJoinDlgCreate;
begin
  FLeader := TLeader.Create(nil);
  FScrollText := TStringList.Create;
end;


procedure TCampaignJoinDlg.CampaignJoinDlgDestroy;
begin
  FLeader.Release;
  FScrollText.Free;
end;


procedure TCampaignJoinDlg.CharGenPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FStage = 0 then ShowLeaderChoices;
end;


procedure TCampaignJoinDlg.DefaultFacePnlDraw(Sender: TObject; SD: TSurfaceDesc);
var
  R: TRect;
begin
  R := Rect(DefaultFacePnl.WinLeft + 1, DefaultFacePnl.WinTop + 1,
    DefaultFacePnl.WinLeft + DefaultFacePnl.WinWidth - 2,
    DefaultFacePnl.WinTop + DefaultFacePnl.WinHeight - 2);
  FLeader.ShowFace(R, SD);
end;


procedure TCampaignJoinDlg.CustomBtnClick;
begin end;

procedure TCampaignJoinDlg.DefaultBtnClick;
begin end;

procedure TCampaignJoinDlg.ScrollTextDBUpdate;
begin
  if FStage = 0 then
    if FScrollPosition < FScrollText.Count * 20 + ScrollTextDB.WinHeight then
    begin
      Dec(FScrollDelay);
      if FScrollDelay <= 0 then
      begin
        Inc(FScrollPosition);
        ScrollTextDB.FDrawn := False;
        FScrollDelay := 3;
      end;
    end
    else ShowLeaderChoices;
end;


procedure TCampaignJoinDlg.ScrollTextDBDraw(Sender: TObject; SD: TSurfaceDesc);
var
  I, X, Y: Integer;
begin
  SD.ClipRect.Left := CharGenPnl.WinLeft + ScrollTextDB.WinLeft;
  SD.ClipRect.Right := SD.ClipRect.Left + ScrollTextDB.WinWidth;
  SD.ClipRect.Top := CharGenPnl.WinTop + ScrollTextDB.WinTop;
  SD.ClipRect.Bottom := SD.ClipRect.Top + ScrollTextDB.WinHeight;
  X := CharGenPnl.WinLeft + ScrollTextDB.WinLeft + ScrollTextDB.WinWidth div 2;
  Y := SD.ClipRect.Top + ScrollTextDB.WinHeight - FScrollPosition;
  for I := 0 to FScrollText.Count - 1 do
  begin
    FontModule.AoW15WhiteGrey.SetTextCentered(X, Y, FScrollText[I], SD);
    Inc(Y, 20);
  end;
end;


procedure TCampaignJoinDlg.DefaultFacePnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;



procedure TCampaignJoinDlg.ShowLeaderChoices;
begin
  FStage := 1;
  LeaderTypePnl.Visible := True;
  ScrollTextDB.Visible := False;
  CharGenPnl.Visible := True;
end;

end.
