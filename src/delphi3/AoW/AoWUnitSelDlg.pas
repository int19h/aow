unit AoWUnitSelDlg;

{ Draft declarations of AoWUnitSelDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, Arena, EventLog, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TUnitSelectionDlg = class;


  { TUnitSelectionDlg (instance size $B0, VMT 004449D4).
    $A8 unit selector; $AC retained event log. }
  TUnitSelectionDlg = class(TDataModule)
  public
    published
    SelectBtn: TAOWButton; { +0044 }
    TitleIcon: TAOWImage; { +0048 }
    Close: TAOWButton; { +004C }
    Title: TAOWLabel; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    Dlg: TAOWWindow; { +0058 }
    UnitPnl: TAOWPanel; { +005C }
    SourcePnl: TAOWPanel; { +0060 }
    SourceNameLbl: TAOWLabel; { +0064 }
    U1: TAOWCheckBox; { +0068 }
    U2: TAOWCheckBox; { +006C }
    U3: TAOWCheckBox; { +0070 }
    U4: TAOWCheckBox; { +0074 }
    U5: TAOWCheckBox; { +0078 }
    U6: TAOWCheckBox; { +007C }
    U7: TAOWCheckBox; { +0080 }
    U8: TAOWCheckBox; { +0084 }
    DecoL: TAOWImage; { +0088 }
    DecoR: TAOWImage; { +008C }
    SourceFace: TAOWImage; { +0090 }
    AoWFrame1: TAoWFrame; { +0094 }
    SelectionInfoPnl: TAOWPanel; { +0098 }
    SelectionInfoLbl: TAOWLabel; { +009C }
    SelectionLbl: TAOWLabel; { +00A0 }
    Translator: TIvTranslator; { +00A4 }
    public
    FEvent: TUnitSelector; { $A8 }
    FEventLog: TUnitSelectorAAI; { $AC }
    procedure DrawUnit(Index, X, Y: Integer; var SD: TSurfaceDesc);
    procedure ResetSelection;
    procedure Execute(Request: TUnitSelectorAAI);
    procedure ClearEvent;
    procedure CloseClick;  { draft }
    procedure SelectBtnClick;  { draft }
    procedure U1Change(Sender: TObject);
    procedure U1PreDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
    procedure SourceFacePreDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
    procedure DlgHide;  { draft }
  end;


implementation

uses AoWWinMan, E3Globals;

procedure TUnitSelectionDlg.DrawUnit(Index, X, Y: Integer; var SD: TSurfaceDesc);
var
  SaveRect: TRect;
  Info: TP2UnitShowInfo;
  Img: TLibraryImage;
begin
  if Index < FEvent.FUnits.GetCount then
  begin
    SaveRect := SD.ClipRect;
    SD.ClipRect := Rect(X + 5, Y + 4, X + 46, Y + 56);
    if Byte(FEvent.FUnits.GetUnit(Index).GetAlignment) < IntGfxMod.UnitBGs.Count then
    begin
      Img := IntGfxMod.UnitBGs[Ord(FEvent.FUnits.GetUnit(Index).GetAlignment)];
      Img.ShowClipped(X + 25 - Img.Width div 2, Y + 30 - Img.Height div 2, SD);
    end;
    FillChar(Info, SizeOf(Info), 0);
    Info.Direction := 3; Info.Overlays := [uoHitPoints, uoRank];
    FEvent.FUnits.GetUnit(Index).ShowEx(X - 8, Y - 5, SD, Info);
    if ((FEvent.FSelectable shr Index) and 1) = 0 then
    begin
      Img := IntGfxMod.UnitBGs[7];
      Img.ShowClipped(X + 25 - Img.Width div 2, Y + 30 - Img.Height div 2, SD);
    end;
    SD.ClipRect := SaveRect;
  end;
end;

procedure TUnitSelectionDlg.ClearEvent;
begin
  if FEvent <> nil then begin FEvent.Release; FEvent := nil; end;
  if FEventLog <> nil then begin FEventLog.Release; FEventLog := nil; end;
end;

procedure TUnitSelectionDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TUnitSelectionDlg.SelectBtnClick;
var
  Reason: string;
begin
  General.PlayButtonSound(0);
  if FEvent.CanSelect(Reason) then
  begin
    FEvent.Select;
    Dlg.Visible := False;
  end
  else AoWHSMap.ShowWarning(Reason);
end;

procedure TUnitSelectionDlg.U1Change(Sender: TObject);
var
  Reason: string;
begin
  if TAOWCheckBox(Sender).Checked then
    if not FEvent.FCanceled then FEvent.SetSelection(1 shl TComponent(Sender).Tag)
    else FEvent.SetSelection(FEvent.FSelection or (1 shl TComponent(Sender).Tag))
  else FEvent.SetSelection(FEvent.FSelection and not (1 shl TComponent(Sender).Tag));
  U1.Checked := (FEvent.FSelection and 1) <> 0;
  U2.Checked := (FEvent.FSelection and 2) <> 0;
  U3.Checked := (FEvent.FSelection and 4) <> 0;
  U4.Checked := (FEvent.FSelection and 8) <> 0;
  U5.Checked := (FEvent.FSelection and 16) <> 0;
  U6.Checked := (FEvent.FSelection and 32) <> 0;
  U7.Checked := (FEvent.FSelection and 64) <> 0;
  U8.Checked := (FEvent.FSelection and 128) <> 0;
  if (FEvent.FSelectable and (1 shl TComponent(Sender).Tag)) <> 0 then
    if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
  if FEvent.FSelection <> 0 then
  begin
    if FEvent.CanSelect(Reason) then SelectionInfoLbl.TextColor := 0
    else SelectionInfoLbl.TextColor := $95;
  end
  else SelectionInfoLbl.Text := '';
end;

procedure TUnitSelectionDlg.U1PreDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
begin
  DrawUnit(Sender.Tag, UnitPnl.WinLeft + Sender.WinLeft, UnitPnl.WinTop + Sender.WinTop, SD);
end;

procedure TUnitSelectionDlg.SourceFacePreDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  R: TRect;
  U: TAbstractUnit;
begin
  if FEvent <> nil then
  begin
    U := AoWHSMap.FUnitControl.FindUnit(FEvent.FSourceUnitID);
    if U <> nil then
    begin
      with SourceFace do
      begin
        R.Left := WinLeft + SourcePnl.WinLeft; R.Right := WinWidth + R.Left;
        R.Top := WinTop + SourcePnl.WinTop; R.Bottom := WinHeight + R.Top;
      end;
      if U.GetFace <> nil then U.GetFace.ShowStretched(R, SD);
    end;
  end;
end;

procedure TUnitSelectionDlg.DlgHide;
begin
  ClearEvent;
end;


procedure TUnitSelectionDlg.ResetSelection;
begin
  if FEvent <> nil then begin FEvent.Release; FEvent := nil; end;
  if FEventLog <> nil then begin FEventLog.Release; FEventLog := nil; end;
  U1.Checked := False; U2.Checked := False; U3.Checked := False; U4.Checked := False;
  U5.Checked := False; U6.Checked := False; U7.Checked := False; U8.Checked := False;
  SelectionInfoLbl.Text := '';
end;

procedure TUnitSelectionDlg.Execute(Request: TUnitSelectorAAI);
var U: TAbstractUnit;
begin
  ResetSelection;
  FEventLog := Request; FEventLog.AddRef;
  FEvent := Request.FUnitSelector; FEvent.AddRef;
  U := AoWHSMap.FUnitControl.FindUnit(FEvent.FSourceUnitID);
  if U <> nil then
  begin SourcePnl.Visible := True; SourceNameLbl.Text := U.GetName; end
  else SourcePnl.Visible := False;
  SelectionLbl.Text := FEvent.FCaption;
  Dlg.Visible := True;
end;

end.
