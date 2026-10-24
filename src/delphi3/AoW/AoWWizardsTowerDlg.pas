unit AoWWizardsTowerDlg;

{ Draft declarations of AoWWizardsTowerDlg, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
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
    FOnClose: TExecuteDoneEvent; { $88 }
    FEvent: TEnterWizardsTowerEventLog; { $90 }
    procedure ClearEvent;
    published procedure CancelBtnClick; public  { draft }
    published procedure BuyBtnClick; public  { draft }
    published procedure DlgHide; public  { draft }
    published procedure SpellIcnDraw(Sender: TAoWComponent; SD: TSurfaceDesc); public
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


implementation

uses AoWWinMan, E3Globals;

procedure TWizardsTowerDlg.ClearEvent;
var
  Event: TEnterWizardsTowerEventLog;
  Notify: TExecuteDoneEvent;
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
  if not FEvent.FTower.Buy(AoWHSMap.FSeatedPlayer, Reason) then AoWHSMap.ShowWarning(Reason)
  else Dlg.Visible := False;
end;

procedure TWizardsTowerDlg.DlgHide;
begin
  ClearEvent;
end;

procedure TWizardsTowerDlg.SpellIcnDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  S: TSpell; X, Y: Integer;
begin
  with FEvent.FTower do if FSpellID <> 0 then
  begin
    S := AoWHSSet.FSpellControl.GetSpell(FSpellID);
    if S <> nil then
      if S.FCastImages.GetImageSequence(10) <> nil then
        with TAOWImage(Sender) do begin X := AOWWindow.WinLeft; Y := AOWWindow.WinTop; S.FCastImages.Show(10, WinLeft + X,
          WinTop + Y, 0, SD); end;
  end;
end;

procedure TWizardsTowerDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Dlg.Visible := False;
end;


end.
