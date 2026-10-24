unit AoWItemsFoundDlg;

{ Found-item display, hero selection and completion recovered from AoW.exe.
  Layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, ItemExpS, EventLog, AoWComp, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TItemsFoundDlg = class;


  { TItemsFoundDlg: size $B0; $A0 item offset, $A4 completion event, $AC item event. VMT 0044C8D0. }
  TItemsFoundDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    PickupPnl: TAOWPanel; { +004C }
    PickupBtn: TAOWButton; { +0050 }
    CloseBtn: TAOWButton; { +0054 }
    BCeltL: TAoWFrame; { +0058 }
    TCeltL: TAoWFrame; { +005C }
    TCeltLineL: TAOWImage; { +0060 }
    AOWImage1: TAOWImage; { +0064 }
    AOWImage2: TAOWImage; { +0068 }
    CloseBtn2: TAOWButton; { +006C }
    OKPnl: TAOWPanel; { +0070 }
    MessageMemo: TAOWMemo; { +0074 }
    MessageMemoSB: TAOWVScrollBar; { +0078 }
    MemoPnl: TAOWPanel; { +007C }
    Translator: TIvTranslator; { +0080 }
    Gnd3: TAOWCheckBox; { +0084 }
    Gnd2: TAOWCheckBox; { +0088 }
    Gnd1: TAOWCheckBox; { +008C }
    Gnd4: TAOWCheckBox; { +0090 }
    Gnd5: TAOWCheckBox; { +0094 }
    LeftBtn: TAOWButton; { +0098 }
    RightBtn: TAOWButton; { +009C }
    public
    FItemOffset: Integer; { $A0 }
    FOnDone: TExecuteDoneEvent; { $A4 }
    FEvent: TItemExplorationSiteEventLog; { $AC }
    function GetHero: THero;
    procedure Finish; procedure Reset;
    published procedure DlgHide; public
    published procedure CloseBtn2Click; public
    published procedure Gnd3Draw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure PickupBtnClick; public
    published procedure Gnd3MouseDown(Sender: TAOWCheckBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure LeftBtnClick; public
    published procedure RightBtnClick; public
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


implementation

uses AoWWinMan, AoWExeForms, AoWItemBanner, E2CampaignSupport;
procedure TItemsFoundDlg.Reset; begin FItemOffset := 0; PickupPnl.Visible := False; OKPnl.Visible := False; end;
procedure TItemsFoundDlg.DlgHide;
begin Finish; end;

procedure TItemsFoundDlg.Finish;
var
  Done: TExecuteDoneEvent;
  Event: TItemExplorationSiteEventLog;
begin
  Dlg.Visible := False;
  Done := FOnDone;
  Event := FEvent;
  FOnDone := nil;
  FEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

function TItemsFoundDlg.GetHero: THero;
var Army: TArmyHS;
begin
  Result := nil;
  if FEvent <> nil then
  begin
    Army := TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(Integer(FEvent.FLocation))).GetArmyHS;
    if (Army <> nil) and (Army.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
      Result := Army.FArmy.Hero($FF, AllHeroTypes);
  end;
end;

procedure TItemsFoundDlg.CloseBtn2Click;
begin Dlg.Visible := False; end;

procedure TItemsFoundDlg.Gnd3Draw(Sender: TObject; SD: TSurfaceDesc); { Tried typed Sender distinct coordinate cast; no exact match. }
var
  Event: TItemExplorationSiteEventLog;
  Item: TItem;
begin
  Event := FEvent;
  if Event <> nil then
    if TComponent(Sender).Tag + FItemOffset < Event.FItemIDs.Count then
    begin
      Item := AoWHSMap.FItemControl.FindItem(FEvent.FItemIDs[TComponent(Sender).Tag + FItemOffset]);
      if Item <> nil then Item.Show(Dlg.WinLeft + TAoWComponent(Sender).WinLeft,
        Dlg.WinTop + TAoWComponent(Sender).WinTop, SD);
    end;
end;

procedure TItemsFoundDlg.PickupBtnClick;
var
  Hero: THero;
  Event: TTutorialMessageEventLog;
begin
  Hero := GetHero;
  if Hero <> nil then
  begin
    General.FSelectedUnit := Hero;
    UnitWindow.ShowUnit;
    UnitWindow.UnitTab.Selected := 2;
    if AoWHSMap.FGameType = gtTutorial then
    begin
      Event := TTutorialMessageEventLog.Create(nil);
      Event.FHelpFileName := TranslateRStr(TutorialRStr);
      if AoWHSMap.FTextControl.FindID(55) <> nil then
      begin
        Event.FMessage.Assign(AoWHSMap.FTextControl.FindID(55).FText);
        AoWHSMap.TriggerExecuteEventLog(Event, True, nil);
      end;
      Event.Release;
    end;
  end;
  Dlg.Visible := False;
end;

procedure TItemsFoundDlg.Gnd3MouseDown(Sender: TAOWCheckBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Item: TItem; Box: TAOWCheckBox;
begin
  Box := Sender;
  if Button = mbRight then
  begin
    Box.PopupMenu := nil;
    if FItemOffset + Box.Tag < FEvent.FItemIDs.Count then
    begin
      Item := AoWHSMap.FItemControl.FindItem(FEvent.FItemIDs[FItemOffset + Box.Tag]);
      if Item <> nil then
      begin
        Box.PopupMenu := ItemBanner.IBannerPopup;
        ItemID := Item.FItemID;
      end;
    end;
  end;
end;

procedure TItemsFoundDlg.LeftBtnClick;
begin
  if FItemOffset > 0 then
  begin
    Dec(FItemOffset);
    Dlg.FDrawn := False;
  end;
end;

procedure TItemsFoundDlg.RightBtnClick;
begin
  if FItemOffset + 5 < FEvent.FItemIDs.Count then
  begin
    Inc(FItemOffset);
    Dlg.FDrawn := False;
  end;
end;

procedure TItemsFoundDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin if Key = VK_ESCAPE then Dlg.Visible := False; end;

end.
