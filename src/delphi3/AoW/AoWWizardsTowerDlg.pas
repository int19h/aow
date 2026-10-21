unit AoWWizardsTowerDlg;

{ Draft declarations of AoWWizardsTowerDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, City, WizardsTower, EventLog, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  TWizardsTowerDlg = class;


  { TWizardsTowerDlg (instance size $94, VMT 0044B6EC).
    $88 completion callback; $90 tower-entry event. }
  TWizardsTowerDlg = class(TDataModule)
  public
    published
    TitleIcon: TAOWImage; { +0044 }
    Close: TAOWButton; { +0048 }
    Title: TAOWLabel; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    BuyBtn: TAOWButton; { +0058 }
    Dlg: TAOWWindow; { +005C }
    ResearchPnl: TAOWPanel; { +0060 }
    SpellName: TAOWLabel; { +0064 }
    SpellIcn: TAOWImage; { +0068 }
    SpellClass: TAOWLabel; { +006C }
    SpellCost: TAOWLabel; { +0070 }
    ResearchMemo: TAOWMemo; { +0074 }
    PriceLbl: TAOWLabel; { +0078 }
    OfferText: TAOWLabel; { +007C }
    PicPnl: TAOWPanel; { +0080 }
    Translator: TIvTranslator; { +0084 }
    public
    FOnClose: TNotifyEvent; { $88 }
    FEvent: TEnterWizardsTowerEventLog; { $90 }
    procedure ClearEvent;
    procedure CancelBtnClick;  { draft }
    procedure BuyBtnClick;  { draft }
    procedure DlgHide;  { draft }
    procedure SpellIcnDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses AoWWinMan, E3Globals;

procedure TWizardsTowerDlg.ClearEvent;
var
  Event: TEnterWizardsTowerEventLog;
  Notify: TNotifyEvent;
begin
  Dlg.Visible := False;
  Notify := FOnClose; Event := FEvent;
  FOnClose := nil; FEvent := nil;
  if Assigned(Notify) then Notify(Event);
  if Event <> nil then Event.Release;
  AoWHSMap.FTutorialControl.ShowMessage(69, True, True);
end;

procedure TWizardsTowerDlg.CancelBtnClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TWizardsTowerDlg.BuyBtnClick;
var
  Reason: string;
begin
  General.PlayButtonSound(0);
  if FEvent.FTower.Buy(AoWHSMap.FSeatedPlayer, Reason) then Dlg.Visible := False
  else AoWHSMap.ShowWarning(Reason);
end;

procedure TWizardsTowerDlg.DlgHide;
begin
  ClearEvent;
end;

procedure TWizardsTowerDlg.SpellIcnDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  S: TSpell;
begin
  if FEvent.FTower.FSpellID <> 0 then
  begin
    S := AoWHSSet.FSpellControl.GetSpell(FEvent.FTower.FSpellID);
    if S <> nil then
      if S.FCastImages.GetImageSequence(10) <> nil then
        S.FCastImages.Show(10, Sender.WinLeft + TAOWImage(Sender).AOWWindow.WinLeft,
          TAOWImage(Sender).AOWWindow.WinTop + Sender.WinTop, 0, SD);
  end;
end;

procedure TWizardsTowerDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Dlg.Visible := False;
end;


end.
