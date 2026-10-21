unit AoWPInfoWin;

{ Draft declarations of AoWPInfoWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, EventLog, AoWButton, AoWCheckBox, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TPInfoW = class;


  { TPInfoW (instance size 160, VMT 00422EC8) }
  TPInfoW = class(TDataModule)
  public
    published
    PInfoWin: TAOWWindow; { +0044 }
    Min: TAOWButton; { +0048 }
    IWTitle: TAOWLabel; { +004C }
    SIcon: TAOWImage; { +0050 }
    EventList: TAOWListBox; { +0054 }
    LeadL: TAOWLabel; { +0058 }
    Turn: TAOWLabel; { +005C }
    RShield: TAOWImage; { +0060 }
    EventFr: TAOWPanel; { +0064 }
    EventSB: TAOWVScrollBar; { +0068 }
    PInfoPnl: TAOWPanel; { +006C }
    LeaderCB: TAOWCheckBox; { +0070 }
    FaceFr: TAOWPanel; { +0074 }
    EventLbl: TAOWLabel; { +0078 }
    ShieldFr: TAOWPanel; { +007C }
    TurnFr: TAOWPanel; { +0080 }
    InfoFr: TAOWPanel; { +0084 }
    Player: TAOWLabel; { +0088 }
    Race: TAOWLabel; { +008C }
    RaceCB: TAOWCheckBox; { +0090 }
    Center: TAOWButton; { +0094 }
    Help: TAOWButton; { +0098 }
    Translator: TIvTranslator; { +009C }
    public
    procedure UpdatePlayer;
    procedure UpdateEvents;
    procedure MinClick;
    procedure EventListDoubleClick;
    procedure EventListPreDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
    procedure EventListDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
    procedure PInfoWinResize;
    procedure EventListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LeaderBtnClick(Sender: TObject);
    procedure RaceBtnClick;
    procedure FaceFrDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
    procedure FaceFrMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HelpClick;
  end;


var
  PInfoW: TPInfoW;

implementation

uses E3Globals, AoWWinMan, aowHelpWin;

procedure TPInfoW.MinClick;
begin
  General.PlayButtonSound(0); PInfoWin.Visible := False;
end;

procedure TPInfoW.EventListDoubleClick;
begin
  AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FEventLogbook.GetLogs(
    Integer(EventList.Items.Objects[EventList.Selected])).Execute(True, etUser, nil);
end;

procedure TPInfoW.EventListPreDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
begin
  if DrawItem <> EventList.Selected then
    EventList.TextColor := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FEventLogbook.GetLogs(
      Integer(EventList.Items.Objects[DrawItem])).GetTextColor;
end;

procedure TPInfoW.EventListDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
var
  LeftIcon, MiddleIcon, RightIcon: Integer;
begin
  LeftIcon := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FEventLogbook.GetLogs(Integer(EventList.Items.Objects[DrawItem])).GetLeftIcon;
  MiddleIcon := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FEventLogbook.GetLogs(Integer(EventList.Items.Objects[DrawItem])).GetMiddleIcon;
  RightIcon := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FEventLogbook.GetLogs(Integer(EventList.Items.Objects[DrawItem])).GetRightIcon;
  if LeftIcon > -1 then
    if MiddleIcon = -1 then
      IntGfxMod.EventIcons[LeftIcon].ShowClipped(DrawRect.Left + (36 - IntGfxMod.EventIcons[LeftIcon].Width) div 2, DrawRect.Top + 1, SD)
    else IntGfxMod.EventIcons[LeftIcon].ShowClipped(DrawRect.Left, DrawRect.Top + 1, SD);
  if MiddleIcon > -1 then IntGfxMod.EventIcons[MiddleIcon].ShowClipped(DrawRect.Left + 12, DrawRect.Top + 1, SD);
  if RightIcon > -1 then IntGfxMod.EventIcons[RightIcon].ShowClipped(DrawRect.Left + 24, DrawRect.Top + 1, SD);
end;

procedure TPInfoW.PInfoWinResize;
begin
  with PInfoWin do
    begin
      Alignment.RightOffset := WinManager.WinWidth - WinLeft - WinWidth;
      Alignment.BottomOffset := General.Manager.WinHeight - WinTop - WinHeight;
    end;
end;

procedure TPInfoW.EventListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (EventList.Selected > -1) and (Button = mbRight) then
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FEventLogbook.GetLogs(
      Integer(EventList.Items.Objects[EventList.Selected])).ViewLocation;
end;

procedure TPInfoW.LeaderBtnClick(Sender: TObject);
var
  X, Y, L: Shortint;
begin
  General.PlayButtonSound(0);
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FLeader <> nil then
  begin
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetLeaderLocation(X, Y, L);
    if X > -1 then
    begin
      AoWHSMap.CenterViewTo(X, Y, L);
      AoWHSMap.PlayCenterAnimation(X, Y, L);
    end;
  end;
end;

procedure TPInfoW.RaceBtnClick;
begin
  General.PlayButtonSound(0);
end;

procedure TPInfoW.FaceFrDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  R: TRect;
begin
  if AoWHSMap.FSeatedPlayer > -1 then
  begin
    with FaceFr do R := Rect(WinLeft + 3, WinTop + 3, WinLeft + WinWidth - 3, WinTop + WinHeight - 3);
    if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetFace <> nil then
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetFace.ShowStretched(R, SD);
  end;
end;

procedure TPInfoW.FaceFrMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Xhx, Yhx, Lhx: Shortint;
begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FLeader <> nil then
  begin
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetLeaderLocation(Xhx, Yhx, Lhx);
    if Xhx > -1 then
    begin
      General.FSelectedUnit := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FLeader;
      case Button of
        mbLeft: UnitWindow.ShowUnit;
        mbRight: LeaderBtnClick(Self);
      end;
    end;
  end;
end;

procedure TPInfoW.HelpClick;
begin
  ShowHelp(502);
end;


procedure TPInfoW.UpdatePlayer;
var
  RaceIndex: Integer;
begin
  if AoWHSMap.FSeatedPlayer > -1 then
  begin
    AoWPInfoWin.PInfoW.Player.Text := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetName;
    if AoWHSMap.FSeatedPlayer <> 0 then
      AoWPInfoWin.PInfoW.Race.Text := TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FPlayerRace]);
    AoWPInfoWin.PInfoW.Turn.Text := TranslateRStr(DayRStr) + ' ' + IntToStr(AoWHSMap.FDay);
    RaceIndex := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FPlayerRace;
    if RaceIndex = -1 then RaceIndex := 12;
    AoWPInfoWin.PInfoW.RShield.CurrentImage := RaceIndex + 13;
    AoWPInfoWin.PInfoW.PInfoWin.Visible := True;
  end;
end;

procedure TPInfoW.UpdateEvents;
begin
  EventList.Items.Clear;
  if AoWHSMap.FSeatedPlayer > -1 then
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FEventLogbook.ListEvents(EventList.Items);
  EventList.ListOffset := EventList.Items.Count - 1;
end;

end.
