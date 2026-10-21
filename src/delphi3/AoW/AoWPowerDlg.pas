unit AoWPowerDlg;

{ Power allocation, research estimates and drawing recovered from AoW.exe.
  Layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AoWButton, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TPowerDlg = class;


  { TPowerDlg: size $AC; all fields are form components, $9C power allocation slider. VMT 0042B9B0. }
  TPowerDlg = class(TDataModule)
  public
    published
    TitleIcon: TAOWImage; { +0044 }
    Close: TAOWButton; { +0048 }
    Title: TAOWLabel; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    SetBtn: TAOWButton; { +0058 }
    Dlg: TAOWWindow; { +005C }
    NetMana: TAOWLabel; { +0060 }
    NetMamaLbl: TAOWLabel; { +0064 }
    UpkeePnl: TAOWPanel; { +0068 }
    ResearchLeft: TAOWLabel; { +006C }
    SpellName: TAOWLabel; { +0070 }
    ResearchPnl: TAOWPanel; { +0074 }
    SliderPnl: TAOWPanel; { +0078 }
    PowerLbl: TAOWLabel; { +007C }
    Power: TAOWLabel; { +0080 }
    Mana: TAOWLabel; { +0084 }
    Research: TAOWLabel; { +0088 }
    ManaPnl: TAOWPanel; { +008C }
    ResPnl: TAOWPanel; { +0090 }
    ManaLbl: TAOWLabel; { +0094 }
    ResearchLbl: TAOWLabel; { +0098 }
    PowerSlider: TAOWHScrollBar; { +009C }
    PAMana: TAOWImage; { +00A0 }
    PARes: TAOWImage; { +00A4 }
    Translator: TIvTranslator; { +00A8 }
    public
    procedure Execute;
    procedure UpdatePower;
    procedure CancelBtnClick;
    procedure PowerSliderChange;
    procedure SetBtnClick;
    procedure PAManaDraw(Sender: TObject; SD: TSurfaceDesc);
    procedure PAResDraw(Sender: TObject; SD: TSurfaceDesc);
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses AoWWinMan, AoWExeForms;

procedure TPowerDlg.CancelBtnClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TPowerDlg.PowerSliderChange;
begin UpdatePower; end;

procedure TPowerDlg.Execute;
var Control: TPlayerMagicControl;
begin
  Dlg.Visible := True;
  Control := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl;
  PowerSlider.Position := Control.FResearchPercentage;
  Power.Text := IntToStr(Control.GetNetPower);
  UpdatePower;
end;

procedure TPowerDlg.UpdatePower;
var
  Upkeep, Turns, SpellID, PointsLeft: Integer;
  ManaPower, ResearchPower: Integer;
begin
  ManaPower := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.GetNetPower;
  PointsLeft := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.FResearchPointsLeft;
  Upkeep := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.GetManaUpkeep;
  SpellID := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.FResearchSpellID;
  ResearchPower := Round(PowerSlider.Position * ManaPower / 100);
  Dec(ManaPower, ResearchPower);
  if SpellID <> 0 then
  begin
    Turns := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.ResearchTurns(ResearchPower, PointsLeft);
    SpellName.Text := AoWHSSet.FSpellControl.GetSpell(SpellID).FSpellName;
    ResearchLeft.Text := FmtTurnsStr(Turns);
  end
  else
  begin
    SpellName.Text := TranslateRStr(NoneRStr);
    ResearchLeft.Text := '-';
  end;
  NetMana.Text := IntToStr(ManaPower) + '-' + IntToStr(Upkeep) + '=' + IntToStr(ManaPower - Upkeep);
  Mana.Text := IntToStr(ManaPower);
  Research.Text := IntToStr(ResearchPower);
  Dlg.FDrawn := False;
end;

procedure TPowerDlg.SetBtnClick;
begin
  General.PlayButtonSound(0);
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.ChangePowerSettings(PowerSlider.Position) then
    Dlg.Visible := False;
end;

procedure TPowerDlg.PAManaDraw(Sender: TObject; SD: TSurfaceDesc);
var
  X, Y, Intensity: Integer;
begin
  with TAOWImage(Sender) do
  begin
    X := AOWWindow.WinLeft;
    Y := AOWWindow.WinTop;
    Intensity := Round((100 - PowerSlider.Position) * 50 / 100);
    IntGfxMod.MiscArt[7].ShowBlended(WinLeft + X, WinTop + Y, SD, IntensityBlendTable.LookupTables[Intensity]);
  end;
end;

procedure TPowerDlg.PAResDraw(Sender: TObject; SD: TSurfaceDesc);
var
  X, Y, Intensity: Integer;
begin
  with TAOWImage(Sender) do
  begin
    X := AOWWindow.WinLeft;
    Y := AOWWindow.WinTop;
    Intensity := Round(PowerSlider.Position * 50 / 100);
    IntGfxMod.MiscArt[8].ShowBlended(WinLeft + X, WinTop + Y, SD, IntensityBlendTable.LookupTables[Intensity]);
  end;
end;

procedure TPowerDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin if Key = VK_ESCAPE then Dlg.Visible := False; end;

end.
