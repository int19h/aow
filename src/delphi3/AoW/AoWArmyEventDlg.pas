unit AoWArmyEventDlg;

{ Draft declarations of AoWArmyEventDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWComp, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TArmyEventDlg = class;


  { TArmyEventDlg (instance size $8C, VMT 004365E4).
    $78 completion callback; $80 army event; $84 frame; $88 visible unit indices. }
  TArmyEventDlg = class(TDataModule)
  public
    published
    ArmyEventWin: TAOWWindow; { +0044 }
    BGoldSq: TAoWFrame; { +0048 }
    UnitPnl: TAOWPanel; { +004C }
    EventText: TAOWLabel; { +0050 }
    DamagePic: TAOWImage; { +0054 }
    CloseBut: TAOWButton; { +0058 }
    TitleIcon: TAOWImage; { +005C }
    Close: TAOWButton; { +0060 }
    Title: TAOWLabel; { +0064 }
    BCeltL: TAoWFrame; { +0068 }
    DecoL: TAOWImage; { +006C }
    DecoR: TAOWImage; { +0070 }
    Translator: TIvTranslator; { +0074 }
    public
    FOnClose: TExecuteDoneEvent; { $78 } FEvent: TArmyEventLog; { $80 }
    FFrame: Integer; { $84 }
    FUnits: TByteList; { $88 }
    procedure DrawUnits(X, Y: Integer; const SD: TSurfaceDesc);
    procedure DrawUnit(Index, X, Y: Integer; SD: TSurfaceDesc);
    procedure ClearEvent;
    procedure ArmyEventDlgCreate;  { draft }
    procedure ArmyEventDlgDestroy;  { draft }
    procedure CloseClick;  { draft }
    procedure UnitPnlDrawBack(Sender: TAoWComponent; SD: TSurfaceDesc);
    procedure UnitPnlUpdate;  { draft }
    procedure ArmyEventWinHide;  { draft }
    procedure ArmyEventWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


procedure ShowArmyEvent(Dialog: TArmyEventDlg; Event: TArmyEventLog; Unused: Integer; Done: TExecuteDoneEvent);

implementation

uses AoWWinMan;




























procedure ShowArmyEvent(Dialog: TArmyEventDlg; Event: TArmyEventLog; Unused: Integer; Done: TExecuteDoneEvent);
var
  Log: TArmyEventLog;
  Army: TArmyView;
  I, Image: Integer;
begin
  with Dialog do
  begin
    Assert(FEvent = nil);
    FOnClose := Done;
    FEvent := Event;
    FEvent.AddRef;
    Log := FEvent;
    DamagePic.CurrentImage := Log.FArmyIcon;
    EventText.Text := Log.FArmyMessages.Text;
    Army := Log.FArmyView;
    FUnits.Clear;
    for I := 0 to Army.GetCount - 1 do
      if not Army.GetUnitConcealedForPlayer(I, AoWHSMap.FSeatedPlayer) or (Log.FDamageValues[I] <> 0) then
      begin
        FUnits.Add(I);
        Image := Log.FArmyView.GetUnit(I).GetUnitGFXResourceIndex;
        if Image <> -1 then AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Image).AddRef;
      end;
    ArmyEventWin.Visible := True;
    FFrame := 0;
  end;
end;

procedure TArmyEventDlg.DrawUnits(X, Y: Integer; const SD: TSurfaceDesc);
var
  Offset, I: Integer;
begin
  Offset := FUnits.Count * -16;
  for I := 0 to FUnits.Count - 1 do DrawUnit(I, I * 32 + X + Offset, Y, SD);
end;

procedure TArmyEventDlg.DrawUnit(Index, X, Y: Integer; SD: TSurfaceDesc);
var
  Event: TArmyEventLog;
  Frame: Integer;
  Info: TP2UnitShowInfo;
begin
  Event := FEvent;
  if Event.FDamageValues[FUnits[Index]] <> 0 then
  begin
    { The original staggers animation by bits of the unit object's address. }
    Frame := FFrame - ((Integer(Event.FArmyView.GetUnit(FUnits[Index])) shr 3) and 7);
    FillChar(Info, SizeOf(Info), 0);
    Info.Frame := (Frame shr 1) - 1; Info.Direction := 3; Info.Animation := uaHit;
    Event.FArmyView.GetUnit(FUnits[Index]).ShowEx(X, Y, SD, Info);
    if Frame = 5 then
      if Event.FArmyView.GetUnit(FUnits[Index]).GetHitPoints <> 0 then
        AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Event.FArmyView.GetUnit(FUnits[Index]).GetUnitGFXResourceIndex).FSFXLibraries[3].Play(0)
      else
        AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Event.FArmyView.GetUnit(FUnits[Index]).GetUnitGFXResourceIndex).FSFXLibraries[4].Play(0);
    if Frame < 6 then
      ShowHitPcnt(X, Y, SD, HitPointsToHitPcnt(Event.FArmyView.GetUnit(FUnits[Index]).GetHitPoints,
        Event.FArmyView.GetUnit(FUnits[Index]).GetHits))
    else
    begin
      ShowDamageIcon(X, Y + 8, SD, Event.FDamageValues[FUnits[Index]], TDamageType(Event.FDamageTypes[FUnits[Index]]));
      ShowHitPcnt(X, Y, SD, HitPointsToHitPcnt(Byte(Event.FArmyView.GetUnit(FUnits[Index]).GetHitPoints - Event.FDamageValues[FUnits[Index]]),
        Event.FArmyView.GetUnit(FUnits[Index]).GetHits));
    end;
  end
  else Event.FArmyView.GetUnit(FUnits[Index]).Show(X, Y, SD);
end;

procedure TArmyEventDlg.ClearEvent;
var
  Event: TArmyEventLog;
  Notify: TExecuteDoneEvent;
  I, Resource: Integer;
begin
  General.Manager.OverlayPriority := 0;
  for I := 0 to FUnits.Count - 1 do
  begin
    Resource := FEvent.FArmyView.GetUnit(FUnits[I]).GetUnitGFXResourceIndex;
    if Resource <> -1 then AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Resource).Release;
  end;
  Notify := FOnClose; Event := FEvent;
  FOnClose := nil; FEvent := nil;
  if Assigned(Notify) then Notify(Event);
  if Event <> nil then Event.Release;
end;

procedure TArmyEventDlg.ArmyEventDlgCreate;
begin
  FUnits := TByteList.Create;
end;

procedure TArmyEventDlg.ArmyEventDlgDestroy;
begin
  FUnits.Free;
end;

procedure TArmyEventDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  ArmyEventWin.Visible := False;
end;

procedure TArmyEventDlg.UnitPnlDrawBack(Sender: TAoWComponent; SD: TSurfaceDesc);
begin
  if FFrame < 1000 then Inc(FFrame);
  DrawUnits(ArmyEventWin.WinLeft + 203, ArmyEventWin.WinTop + 100, SD);
end;

procedure TArmyEventDlg.UnitPnlUpdate;
begin
  UnitPnl.FDrawn := False; ArmyEventWin.FDrawn := False;
end;

procedure TArmyEventDlg.ArmyEventWinHide;
begin
  ClearEvent;
end;

procedure TArmyEventDlg.ArmyEventWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_SPACE) then ArmyEventWin.Visible := False;
end;


end.
