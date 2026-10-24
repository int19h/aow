unit AoWArenaDlg;

{ Draft declarations of AoWArenaDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, Arena, EventLog, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow, aowUserDrawBox;

type
  TArenaDlg = class;


  { TArenaDlg (instance size $B4, VMT 0044BDA8).
    $A8 arena event; $AC completion callback. }
  TArenaDlg = class(TDataModule)
  public
    published
    SelectBtn: TAOWButton; { +0044 }
    TitleIcon: TAOWImage; { +0048 }
    Close: TAOWButton; { +004C }
    Title: TAOWLabel; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    Dlg: TAOWWindow; { +0058 }
    UnitPnl: TAOWPanel; { +005C }
    MapViewPnl: TAOWPanel; { +0060 }
    U1: TAOWCheckBox; { +0064 }
    U2: TAOWCheckBox; { +0068 }
    U3: TAOWCheckBox; { +006C }
    U4: TAOWCheckBox; { +0070 }
    U5: TAOWCheckBox; { +0074 }
    U6: TAOWCheckBox; { +0078 }
    U7: TAOWCheckBox; { +007C }
    U8: TAOWCheckBox; { +0080 }
    DecoL: TAOWImage; { +0084 }
    DecoR: TAOWImage; { +0088 }
    AoWFrame1: TAoWFrame; { +008C }
    SelectionInfoPnl: TAOWPanel; { +0090 }
    SelectionInfoLbl: TAOWLabel; { +0094 }
    SelectionLbl: TAOWLabel; { +0098 }
    MapView: TaowUserDrawBox; { +009C }
    InfoSep: TAOWImage; { +00A0 }
    Translator: TIvTranslator; { +00A4 }
    public
    FEvent: TEnterArenaEventLog; { $A8 }
    FOnClose: TExecuteDoneEvent; { $AC }
    procedure DrawUnit(Index, X, Y: Integer; var SD: TSurfaceDesc);
    procedure ClearEvent;
    published procedure CloseClick; public  { draft }
    published procedure SelectBtnClick; public  { draft }
    published procedure U1Change(Sender: TObject); public
    published procedure U1PreDraw(Sender: TAoWComponent; SD: TSurfaceDesc); public
    published procedure DlgHide; public  { draft }
    published procedure MapViewDraw(Sender: TAoWComponent; SD: TSurfaceDesc); public
    published procedure MapViewUpdate; public  { draft }
    published procedure DlgDrawBack; public  { draft }
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


procedure ShowArena(Dialog: TArenaDlg; Event: TEnterArenaEventLog; Done: TExecuteDoneEvent);
procedure ResetArena(Dialog: TArenaDlg);

implementation

uses AoWWinMan, E3Globals;





















procedure ShowArena(Dialog: TArenaDlg; Event: TEnterArenaEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    Assert(FEvent = nil);
    ResetArena(Dialog);
    FOnClose := Done;
    FEvent := Event;
    FEvent.AddRef;
    General.Manager.OverlayPriority := 49;
    Dlg.Visible := True;
  end;
end;

procedure TArenaDlg.DrawUnit(Index, X, Y: Integer; var SD: TSurfaceDesc);
var
  SaveRect: TRect;
  Info: TP2UnitShowInfo;
  Img: TLibraryImage;
  U: TAbstractUnit;
  Alignment: AoWE.TAlignment;
begin
  if Index < FEvent.GetCount then
  begin
    U := FEvent.GetUnit(Index);
    SaveRect := SD.ClipRect;
    SD.ClipRect := Rect(X + 5, Y + 4, X + 46, Y + 56);
    Alignment := U.GetAlignment;
    if Byte(Alignment) < IntGfxMod.UnitBGs.Count then
    begin
      Img := IntGfxMod.UnitBGs[Integer(Alignment)];
      Img.ShowClipped(X + 25 - Img.Width div 2, Y + 30 - Img.Height div 2, SD);
    end;
    FillChar(Info, SizeOf(Info), 0);
    Info.Direction := 3; Info.Overlays := [uoHitPoints, uoRank];
    U.ShowEx(X - 8, Y - 5, SD, Info);
    if ((FEvent.FTrainable shr Index) and 1) = 0 then
    begin
      Img := IntGfxMod.UnitBGs[7];
      Img.ShowClipped(X + 25 - Img.Width div 2, Y + 30 - Img.Height div 2, SD);
    end;
    SD.ClipRect := SaveRect;
    if ((FEvent.FTrainable shr Index) and 1) <> 0 then
    begin
      FontModule.Age8.Color := 0;
      FontModule.Age8.SetTextCentered(X + 25, Y + 62, IntToStr(FEvent.FArena.UnitTrainCost(U)), SD);
    end;
  end;
end;

procedure TArenaDlg.ClearEvent;
var
  Event: TEnterArenaEventLog;
  Notify: TExecuteDoneEvent;
begin
  General.Manager.OverlayPriority := 0;
  Notify := FOnClose; Event := FEvent;
  FOnClose := nil; FEvent := nil;
  if Assigned(Notify) then Notify(Event);
  if Event <> nil then Event.Release;
end;

procedure TArenaDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TArenaDlg.SelectBtnClick;
var
  Reason: string;
begin
  General.PlayButtonSound(0);
  if FEvent.Train(Reason) then
  begin
    Dlg.Visible := False;
  end
  else AoWHSMap.ShowWarning(Reason);
end;

procedure TArenaDlg.U1Change(Sender: TObject);
var
  Reason: string;
begin
  if TAOWCheckBox(Sender).Checked then
    FEvent.SetSelection(FEvent.FSelection or (1 shl TComponent(Sender).Tag))
  else FEvent.SetSelection(FEvent.FSelection and not (1 shl TComponent(Sender).Tag));
  U1.Checked := (FEvent.FSelection and 1) <> 0;
  U2.Checked := (FEvent.FSelection and 2) <> 0;
  U3.Checked := (FEvent.FSelection and 4) <> 0;
  U4.Checked := (FEvent.FSelection and 8) <> 0;
  U5.Checked := (FEvent.FSelection and 16) <> 0;
  U6.Checked := (FEvent.FSelection and 32) <> 0;
  U7.Checked := (FEvent.FSelection and 64) <> 0;
  U8.Checked := (FEvent.FSelection and 128) <> 0;
  if (FEvent.FTrainable and (1 shl TComponent(Sender).Tag)) <> 0 then
    if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
  if FEvent.FSelection <> 0 then
  begin
    if FEvent.CanTrain(Reason) then SelectionInfoLbl.TextColor := 0
    else SelectionInfoLbl.TextColor := $95;
    SelectionInfoLbl.Text := FEvent.GetSelectionInfo;
  end
  else SelectionInfoLbl.Text := '';
end;

procedure TArenaDlg.U1PreDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
begin
  with TAOWImage(Sender) do DrawUnit(Sender.Tag, UnitPnl.WinLeft + WinLeft, UnitPnl.WinTop + WinTop, SD);
end;

procedure TArenaDlg.DlgHide;
begin
  ClearEvent;
end;

procedure TArenaDlg.MapViewDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  X, Y: Integer;
  MapSD: TSurfaceDesc;
  R: TRect; W, H: Integer;
begin
  R := Rect(Dlg.WinLeft + TAOWImage(Sender).WinLeft, Dlg.WinTop + TAOWImage(Sender).WinTop,
    Dlg.WinLeft + TAOWImage(Sender).WinLeft + TAOWImage(Sender).WinWidth, Dlg.WinTop + TAOWImage(Sender).WinTop + TAOWImage(Sender).WinHeight);
  W := R.Right - R.Left; H := R.Bottom - R.Top; HXtoHP(FEvent.FArena.GetXhx, FEvent.FArena.GetYhx, X, Y);
  X := X + 16 - (W shr 1);
  Y := Y + 16 - (H shr 1);
  if X < 16 then X := 16; if Y < 16 then Y := 16;
  CreateSDfromSD(SD, R, MapSD);
  AoWHSMap.SetViewPort(X, Y, FEvent.FArena.GetLhx, R.Right - R.Left, R.Bottom - R.Top);
  AoWHSMap.UpdateStaticScene; AoWHSMap.UpdateDynamicScene;
  AoWHSMap.DrawStaticScene(MapSD); AoWHSMap.DrawDynamicScene(MapSD);
end;

procedure TArenaDlg.MapViewUpdate;
begin
  MapView.FDrawn := MapView.FDrawn and ((AoWHSMap.Frame and 1) <> 0);
end;

procedure TArenaDlg.DlgDrawBack;
begin end;

procedure TArenaDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Dlg.Visible := False;
end;


procedure ResetArena(Dialog: TArenaDlg);
begin
  with Dialog do
  begin
    U1.Checked := False; U2.Checked := False; U3.Checked := False; U4.Checked := False;
    U5.Checked := False; U6.Checked := False; U7.Checked := False; U8.Checked := False;
    SelectionInfoLbl.Text := '';
  end;
end;

end.
