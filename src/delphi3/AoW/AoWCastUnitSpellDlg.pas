unit AoWCastUnitSpellDlg;

{ Draft declarations of AoWCastUnitSpellDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AOWGauge, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TCastUnitSpellDlg = class;


  { TCastUnitSpellDlg (size $E4, VMT 00431ACC): $E0 retained unit spell caster. }
  TCastUnitSpellDlg = class(TDataModule)
  public
    published
    Unit1Gge: TAoWGauge; { +0044 }
    Unit2Gge: TAoWGauge; { +0048 }
    Unit3Gge: TAoWGauge; { +004C }
    Unit4Gge: TAoWGauge; { +0050 }
    Unit5Gg: TAoWGauge; { +0054 }
    Unit6Gg: TAoWGauge; { +0058 }
    Unit7Gg: TAoWGauge; { +005C }
    Unit8Gg: TAoWGauge; { +0060 }
    CastBut: TAOWButton; { +0064 }
    TitleIcon: TAOWImage; { +0068 }
    Close: TAOWButton; { +006C }
    Title: TAOWLabel; { +0070 }
    CancelBut: TAOWButton; { +0074 }
    Dlg: TAOWWindow; { +0078 }
    SelectLbl: TAOWLabel; { +007C }
    UnitPnl: TAOWPanel; { +0080 }
    TopPnl: TAOWPanel; { +0084 }
    SpellUpkeepLbl: TAOWLabel; { +0088 }
    SpellManaLbl: TAOWLabel; { +008C }
    CastingManaLbl: TAOWLabel; { +0090 }
    SpellNameLbl: TAOWLabel; { +0094 }
    CasterNameLbl: TAOWLabel; { +0098 }
    CastingPointsLbl: TAOWLabel; { +009C }
    U1: TAOWCheckBox; { +00A0 }
    U2: TAOWCheckBox; { +00A4 }
    U3: TAOWCheckBox; { +00A8 }
    U4: TAOWCheckBox; { +00AC }
    U5: TAOWCheckBox; { +00B0 }
    U6: TAOWCheckBox; { +00B4 }
    U7: TAOWCheckBox; { +00B8 }
    U8: TAOWCheckBox; { +00BC }
    DecoL: TAOWImage; { +00C0 }
    DecoR: TAOWImage; { +00C4 }
    SpellFr: TAOWImage; { +00C8 }
    FaceFrame: TAOWImage; { +00CC }
    AoWFrame1: TAoWFrame; { +00D0 }
    SelectionInfoPnl: TAOWPanel; { +00D4 }
    SelectionInfoLbl: TAOWLabel; { +00D8 }
    Translator: TIvTranslator; { +00DC }
    public
    FCaster: TUnitSpellCaster; { $E0 }
    procedure ClearCaster; { 00432174 }
    procedure DrawUnit(Index, X, Y: Integer; var Surface: TSurfaceDesc); { 0043222C }
    published procedure CloseClick; public  { draft }
    published procedure CastButClick; public  { draft }
    published procedure U1Change(Sender: TAOWCheckBox); public
    published procedure FaceFramePreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc); public
    published procedure U1PreDraw(Sender: TObject; Surface: TSurfaceDesc); public
    published procedure U1Draw; public  { draft }
    published procedure SpellFrPreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc); public
    published procedure DlgHide; public  { draft }
    published procedure DlgUpdate; public  { draft }
  end;


implementation

uses AoWWinMan, aowIntGfxMod;

procedure TCastUnitSpellDlg.ClearCaster;
begin
  FCaster.Release;
  FCaster := nil;
end;

procedure TCastUnitSpellDlg.DrawUnit(Index, X, Y: Integer; var Surface: TSurfaceDesc);
var
  Alignment: AoWE.TAlignment;
  Info: TP2UnitShowInfo;
  OldClip: TRect;
begin
  if Index < FCaster.FTargetUnits.GetCount then
  begin
    OldClip := Surface.ClipRect;
    Surface.ClipRect := Rect(X + 5, Y + 4, X + 46, Y + 56);
    Alignment := FCaster.FTargetUnits.GetUnit(Index).GetAlignment;
    if Ord(Alignment) < IntGfxMod.UnitBGs.Count then
      with IntGfxMod.UnitBGs[Integer(Alignment)] do
        ShowClipped(X + 25 - Width div 2, Y + 30 - Height div 2, Surface);
    FillChar(Info, SizeOf(Info), 0);
    Info.Direction := 3;
    Info.Overlays := [uoHitPoints, uoRank];
    FCaster.FTargetUnits.GetUnit(Index).ShowEx(X - 8, Y - 4, Surface, Info);
    if (FCaster.FValidSelection shr Index) and 1 = 0 then
      with IntGfxMod.UnitBGs[7] do
        ShowClipped(X + 25 - Width div 2, Y + 30 - Height div 2, Surface);
    Surface.ClipRect := OldClip;
  end;
end;


procedure TCastUnitSpellDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TCastUnitSpellDlg.CastButClick;
var
  Reason: string;
begin
  General.PlayButtonSound(0);
  if FCaster.CanCast(Reason) then
  begin
    FCaster.Cast;
    Dlg.Visible := False;
  end
  else AoWHSMap.ShowMessage(Reason);
end;

procedure TCastUnitSpellDlg.U1Change(Sender: TAOWCheckBox);
var
  OldSelection: Byte;
  Reason: string;
begin
  with FCaster do
  begin
    OldSelection := FSelectionMask;
    if Sender.Checked then
      if not FAllowMultipleTargets then SetSelection(1 shl Sender.Tag)
      else SetSelection(FSelectionMask or (1 shl Sender.Tag))
    else SetSelection(FSelectionMask and not (1 shl Sender.Tag));
  end;
  U1.Checked := FCaster.FSelectionMask and 1 <> 0;
  U2.Checked := FCaster.FSelectionMask and 2 <> 0;
  U3.Checked := FCaster.FSelectionMask and 4 <> 0;
  U4.Checked := FCaster.FSelectionMask and 8 <> 0;
  U5.Checked := FCaster.FSelectionMask and 16 <> 0;
  U6.Checked := FCaster.FSelectionMask and 32 <> 0;
  U7.Checked := FCaster.FSelectionMask and 64 <> 0;
  U8.Checked := FCaster.FSelectionMask and 128 <> 0;
  if FCaster.FSelectionMask <> OldSelection then
    if Sender.Checked then General.PlayButtonSound(1)
    else General.PlayButtonSound(2);
  if FCaster.FSelectionMask <> 0 then
  begin
    if FCaster.CanCast(Reason) then SelectionInfoLbl.TextColor := 0
    else SelectionInfoLbl.TextColor := $95;
    SelectionInfoLbl.Text := TranslateRStr(RequiredManaRStr) + ' ' + IntToStr(FCaster.GetRequiredMana);
  end
  else SelectionInfoLbl.Text := '';
end;

procedure TCastUnitSpellDlg.FaceFramePreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
var
  U: TAbstractUnit;
  R: TRect;
begin
  U := AoWHSMap.FUnitControl.FindUnit(FCaster.FCasterSourceID);
  if U <> nil then
    if U.GetFace <> nil then
    begin
      with FaceFrame do
      begin
        R.Left := WinLeft + TopPnl.WinLeft;
        R.Right := R.Left + WinWidth;
        R.Top := WinTop + TopPnl.WinTop;
        R.Bottom := R.Top + WinHeight;
      end;
      U.GetFace.ShowStretched(R, Surface);
    end;
end;

procedure TCastUnitSpellDlg.U1PreDraw(Sender: TObject; Surface: TSurfaceDesc);
begin
  with TAOWImage(Sender) do DrawUnit(Tag, UnitPnl.WinLeft + WinLeft, UnitPnl.WinTop + WinTop, Surface);
end;

procedure TCastUnitSpellDlg.U1Draw;
begin end;

procedure TCastUnitSpellDlg.SpellFrPreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
var
  Spell: TSpell;
  R: TRect;
begin
  if FCaster <> nil then
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(FCaster.FCasterSpellID);
    if Spell <> nil then
    begin
      with SpellFr do
      begin
        R.Left := WinLeft + TopPnl.WinLeft;
        R.Right := R.Left + WinWidth;
        R.Top := WinTop + TopPnl.WinTop;
        R.Bottom := R.Top + WinHeight;
      end;
      if Spell.FCastImages.GetImageSequence(10) <> nil then
        Spell.FCastImages.Show(10, R.Left + 5, R.Top + 15, 0, Surface);
    end;
  end;
end;

procedure TCastUnitSpellDlg.DlgHide;
begin
  ClearCaster;
end;

procedure TCastUnitSpellDlg.DlgUpdate;
begin
  if Dlg.Visible and (FCaster <> nil) then
    if not FCaster.Valid then Dlg.Visible := False;
end;


end.
