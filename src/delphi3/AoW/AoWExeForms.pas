unit AoWExeForms;

{ Shared executable form instances used by E2. These are the original global form
  references; no forms are constructed by the byte-match host. }

interface

uses Classes, AoWScenSetup, aowIntGfxMod, AoWMessageDlg, AoWInfoBanner;

var
  ScenSetup: TScenSetup;
  IntGfxMod: TIntGfxMod;
  MessageDlg: TMessageDlg;
  InfoBanner: TInfoBanner;

{ Shared unnamed routines called by the leader setup window. }
procedure ResetMessageDialog(Dialog: TMessageDlg);
procedure SetInfoBanner(Banner: TInfoBanner; Caption: string; Description: TStrings);

implementation

uses AoWE;

procedure ResetMessageDialog(Dialog: TMessageDlg);
begin
  Dialog.YesNoPnl.Visible := False;
  Dialog.YesNoCancelPnl.Visible := False;
  Dialog.OKPnl.Visible := False;
  Dialog.OKCancelPnl.Visible := False;
  Dialog.MessageMemo.Items.Clear;
  Dialog.MemoPnl.Visible := True;
  Dialog.HeaderMemoPnl.Visible := False;
  Dialog.TitleLbl.Text := TranslateRStr(MessageRStr);
end;

procedure SetInfoBanner(Banner: TInfoBanner; Caption: string; Description: TStrings);
begin
  Banner.HeaderLbl.Text := Caption;
  Banner.InfoMemo.Items.Text := Description.Text;
end;

end.
