unit AoWCampaignSettings;

{ Draft declarations of AoWCampaignSettings, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWButton, AoWComboBox, AoWFrame, AoWImage, AoWLabel, AoWVScroll, AoWWindow;

type
  TCampaignSettingsDlg = class;


  { TCampaignSettingsDlg (instance size 132, VMT 0041B1B0) }
  TCampaignSettingsDlg = class(TDataModule)
  public
    published
    Translator: TIvTranslator; { +0044 }
    Dlg: TAOWWindow; { +0048 }
    OKBtn: TAOWButton; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    Title: TAOWLabel; { +0054 }
    Close: TAOWButton; { +0058 }
    TitleIcon: TAOWImage; { +005C }
    DifficultyLevelLbl: TAOWLabel; { +0060 }
    DifficultyLevelCB: TAOWComboBox; { +0064 }
    CombatResolveModeSB: TAOWVScrollBar; { +0068 }
    TurnModeLbl: TAOWLabel; { +006C }
    TurnModeCB: TAOWComboBox; { +0070 }
    AOWVScrollBar1: TAOWVScrollBar; { +0074 }
    AoWFrame1: TAoWFrame; { +0078 }
    CancelBtn: TAOWButton; { +007C }
    TCeltLineL: TAOWImage; { +0080 }
    public
    published procedure DlgShow(Sender: TObject); public
    published procedure OKBtnClick; public
    published procedure CancelBtnClick; public
  end;


implementation

procedure TCampaignSettingsDlg.DlgShow(Sender: TObject);
var
  Level: TCampaignDifficultyLevel;
begin
  DifficultyLevelCB.Items.Clear;
  for Level := Low(TCampaignDifficultyLevel) to High(TCampaignDifficultyLevel) do
    DifficultyLevelCB.Items.AddObject(TranslateRStr(TCampaignDifficultyLevelRStr[Level]), TObject(Level));
  DifficultyLevelCB.Selected := DifficultyLevelCB.Items.IndexOfObject(TObject(AoWEngine.FCampaign.FDifficultyLevel));
  TurnModeCB.Items.Clear;
  TurnModeCB.Items.AddObject(TranslateRStr(TPlayModeRStr[pmTurn]), TObject(pmTurn));
  TurnModeCB.Items.AddObject(TranslateRStr(TPlayModeRStr[pmSimultaneous]), TObject(pmSimultaneous));
  TurnModeCB.Selected := TurnModeCB.Items.IndexOfObject(TObject(AoWEngine.FCampaign.FPlayMode));
end;

procedure TCampaignSettingsDlg.OKBtnClick;
begin
  AoWEngine.FCampaign.FDifficultyLevel := TCampaignDifficultyLevel(DifficultyLevelCB.Items.Objects[DifficultyLevelCB.Selected]);
  AoWEngine.FCampaign.FPlayMode := TPlayMode(TurnModeCB.Items.Objects[TurnModeCB.Selected]);
  Dlg.Visible := False;
end;

procedure TCampaignSettingsDlg.CancelBtnClick;
begin
  Dlg.Visible := False;
end;


end.
