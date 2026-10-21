unit AoWExeForms;

{ Shared executable form instances used by E2. These are the original global form
  references; no forms are constructed by the byte-match host. }

interface

uses Classes, Windows, AoWScenSetup, aowIntGfxMod, AoWMessageDlg, AoWInfoBanner,
  AoWSoundDlg, AoWVideoDlg, AOWMultiWin, AoWSWindow, AoWPInfoWin, AoWUnitWindow,
  AoWRealm, AoWMagic, AOWControlWin, AoWTBWindow, AoWInfoWin, AoWSpellBook,
  AOWChatWin, AOWMWindow, FontMod, AoWConstructDlg, AoWDisjunctionDlg, AoWTCUnit, AoWTCScanner;

var
  ScenSetup: TScenSetup;
  IntGfxMod: TIntGfxMod;
  MessageDlg: TMessageDlg;
  InfoBanner: TInfoBanner;
  SoundDlg: TSoundDlg;
  VideoDialog: TVideoDialog;
  MultiWindow: TMultiWindow;
  SWindow: TSWindow;
  PInfoW: TPInfoW;
  UnitWindow: TUnitWindow;
  RealmWin: TRealmWin;
  MagicWin: TMagicWin;
  ControlWin: TControlWin;
  TBWindow: TTBWindow;
  IWindow: TIWindow;
  SpellBook: TSpellBook;
  ChatWindow: TChatWindow;
  { MWindow is declared in AOWMWindow. }
  FontModule: TFontModule;
  TCUnit: TTCUnit;
  TCScanner: TTCScanner;
  ConstructDlg: TConstructDlg;
  DisjunctionDlg: TDisjunctionDlg;

procedure SetVideoMode(Dialog: TVideoDialog; FullScreen: TScreenMode);
procedure SetVideoSize(Dialog: TVideoDialog; Width, Height: Integer);


{ Shared unnamed routines called by the leader setup window. }
procedure ResetMessageDialog(Dialog: TMessageDlg);
procedure SetInfoBanner(Banner: TInfoBanner; Caption: string; Description: TStrings);

implementation

uses AoWE, AoWComp, AoWWindow;

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

procedure SetVideoMode(Dialog: TVideoDialog; FullScreen: TScreenMode);
begin
  if FullScreen <> Dialog.FFullScreen then
  begin
    Dialog.FFullScreen := FullScreen;
    Dialog.FModeChanged := True;
  end;
end;

procedure SetVideoSize(Dialog: TVideoDialog; Width, Height: Integer);
begin
  Dialog.FDisplayWidth := Width;
  Dialog.FDisplayHeight := Height;
  if Dialog.FFullScreen = scmGame then Dialog.FModeChanged := True;
end;

end.
