unit GameSDlg;

{ Draft declarations of GameSDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, SpinEdit, AoWE;

type
  TGameSettingsDlg = class;


  { TGameSettingsDlg (instance size 568, VMT 0042D8CC) }
  TGameSettingsDlg = class(TForm)
  public
    published
    BottomPnl: TPanel; { +01DC }
    ClientPnl: TPanel; { +01E0 }
    OKBtn: TButton; { +01E4 }
    CancelBtn: TButton; { +01E8 }
    MainPageControl: TPageControl; { +01EC }
    GeneralSheet: TTabSheet; { +01F0 }
    Bevel1: TBevel; { +01F4 }
    TransferSettingsLbl: TLabel; { +01F8 }
    TransferPointsLbl: TLabel; { +01FC }
    MaxHeroLevelMaxLbl: TLabel; { +0200 }
    TransferGoldLbl: TLabel; { +0204 }
    TransferManaLbl: TLabel; { +0208 }
    TransferPointsMaxEdit: TSpin; { +020C }
    TransferGoldMaxEdit: TSpin; { +0210 }
    TransferManaMaxEdit: TSpin; { +0214 }
    HeroLevelMaxEdit: TSpin; { +0218 }
    Bevel3: TBevel; { +021C }
    AlliedVictoryCB: TCheckBox; { +0220 }
    GameTypeLbl: TLabel; { +0224 }
    GameTypeCB: TComboBox; { +0228 }
    TurnLimitationLbl: TLabel; { +022C }
    TurnLimitationEdit: TSpin; { +0230 }
    DemoMapCB: TCheckBox; { +0234 }
    public
    procedure UpdateGameType;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure GameTypeCBChange(Sender: TObject);
  end;


implementation

uses MDIForm;

procedure TGameSettingsDlg.UpdateGameType;
begin
  if GameTypeCB.ItemIndex = 1 then
  begin
    TransferPointsMaxEdit.Color := clWindow;
    TransferPointsMaxEdit.Enabled := True;
    TransferGoldMaxEdit.Color := clWindow;
    TransferGoldMaxEdit.Enabled := True;
    TransferManaMaxEdit.Color := clWindow;
    TransferManaMaxEdit.Enabled := True;
    HeroLevelMaxEdit.Color := clWindow;
    HeroLevelMaxEdit.Enabled := True;
    AlliedVictoryCB.Enabled := True;
    TurnLimitationEdit.Color := clWindow;
    TurnLimitationEdit.Enabled := True;
  end
  else
  begin
    TransferPointsMaxEdit.Color := clBtnFace;
    TransferPointsMaxEdit.Enabled := False;
    TransferGoldMaxEdit.Color := clBtnFace;
    TransferGoldMaxEdit.Enabled := False;
    TransferManaMaxEdit.Color := clBtnFace;
    TransferManaMaxEdit.Enabled := False;
    HeroLevelMaxEdit.Color := clBtnFace;
    HeroLevelMaxEdit.Enabled := False;
    AlliedVictoryCB.Enabled := False;
    TurnLimitationEdit.Color := clBtnFace;
    TurnLimitationEdit.Enabled := False;
  end;
end;

procedure TGameSettingsDlg.FormCreate(Sender: TObject);
begin
  GameTypeCB.ItemIndex := Ord(AoWHSMap.FGameType);
  TransferPointsMaxEdit.Value := AoWHSMap.FCampaignSettings.FTransferPointsMax;
  TransferGoldMaxEdit.Value := AoWHSMap.FCampaignSettings.FTransferGoldMax;
  TransferManaMaxEdit.Value := AoWHSMap.FCampaignSettings.FTransferManaMax;
  HeroLevelMaxEdit.Value := AoWHSMap.FCampaignSettings.FHeroLevelMax;
  AlliedVictoryCB.Checked := AoWHSMap.FCampaignSettings.FAlliedVictory;
  TurnLimitationEdit.Value := AoWHSMap.FDayLimit;
  DemoMapCB.Checked := AoWHSMap.FShowAllPlayers;
  UpdateGameType;
end;

procedure TGameSettingsDlg.OKBtnClick(Sender: TObject);
var
  I: Integer;
begin
  AoWHSMap.FCampaignSettings.FAlliedVictory := AlliedVictoryCB.Checked;
  AoWHSMap.FCampaignSettings.FTransferPointsMax := TransferPointsMaxEdit.Value;
  AoWHSMap.FCampaignSettings.FTransferGoldMax := TransferGoldMaxEdit.Value;
  AoWHSMap.FCampaignSettings.FTransferManaMax := TransferManaMaxEdit.Value;
  AoWHSMap.FCampaignSettings.FHeroLevelMax := HeroLevelMaxEdit.Value;
  AoWHSMap.FDayLimit := TurnLimitationEdit.Value;
  AoWHSMap.FShowAllPlayers := DemoMapCB.Checked;
  if (CompareText(ExtractFileExt(MainForm.HSMEdit.HSMapFilename), '.csm') = 0) or
     (CompareText(ExtractFileExt(MainForm.HSMEdit.HSMapFilename), '.hsm') = 0) then
  begin
    I := Pos('.', MainForm.HSMEdit.HSMapFilename);
    if I <> 0 then AoWHSMap.FileName := Copy(MainForm.HSMEdit.HSMapFilename, 1, I - 1)
    else AoWHSMap.FileName := MainForm.HSMEdit.HSMapFilename;
    AoWHSMap.FGameType := TGameType(GameTypeCB.ItemIndex);
    if AoWHSMap.FGameType = gtCampaign then AoWHSMap.FileName := AoWHSMap.FileName + '.csm'
    else AoWHSMap.FileName := AoWHSMap.FileName + '.hsm';
    { Original truncates at the first dot, including dots in directory names. }
    MainForm.HSMEdit.HSMapFilename := AoWHSMap.FileName;
  end;
  AoWHSMap.SetModified;
end;

procedure TGameSettingsDlg.GameTypeCBChange(Sender: TObject);
begin
  UpdateGameType;
end;


end.
