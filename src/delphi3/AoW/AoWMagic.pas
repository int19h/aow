unit AoWMagic;

{ AoWMagic handlers recovered from AoW.exe.
  Class layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TMagicWin = class;


  { TMagicWin: size $14C; $140 enchantment sort, $144 global sort, $148 power sort. VMT 0042C190. }
  TMagicWin = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    OWTitle: TAOWLabel; { +0048 }
    OWTitleIc: TAOWImage; { +004C }
    HeaderTab: TAOWTabPanel; { +0050 }
    OWRPillar: TAoWFrame; { +0054 }
    OWLPillar: TAoWFrame; { +0058 }
    T1Pnl: TAOWPanel; { +005C }
    ResearchPoints: TAOWLabel; { +0060 }
    ResLbl: TAOWLabel; { +0064 }
    T2Pnl: TAOWPanel; { +0068 }
    T2LBPnl: TAOWPanel; { +006C }
    EnchantmentList: TAOWListBox; { +0070 }
    EnchantmentSortBtn: TAOWButton; { +0074 }
    UpkeepList: TAOWListBox; { +0078 }
    UpkeepSortBtn: TAOWButton; { +007C }
    BindingList: TAOWListBox; { +0080 }
    BindingSortBtn: TAOWButton; { +0084 }
    ResPnl: TAOWPanel; { +0088 }
    NetMana: TAOWLabel; { +008C }
    NetMamaLbl: TAOWLabel; { +0090 }
    NetManaPnl: TAOWPanel; { +0094 }
    T3Pnl: TAOWPanel; { +0098 }
    T3LBPnl: TAOWPanel; { +009C }
    GlobalEnchantmentList: TAOWListBox; { +00A0 }
    GlobalEnchantmentSortBtn: TAOWButton; { +00A4 }
    GlobalUpkeepList: TAOWListBox; { +00A8 }
    GlobalUpkeepSortBtn: TAOWButton; { +00AC }
    GlobalNameList: TAOWListBox; { +00B0 }
    GlobalNameSortBtn: TAOWButton; { +00B4 }
    RightPnl: TAOWPanel; { +00B8 }
    SpellName: TAOWLabel; { +00BC }
    GlobalDispelBtn: TAOWButton; { +00C0 }
    DispelBtn: TAOWButton; { +00C4 }
    ResearchBtn: TAOWButton; { +00C8 }
    ResearchTurnsLeft: TAOWLabel; { +00CC }
    SpellClass: TAOWLabel; { +00D0 }
    SpellPnl: TAOWPanel; { +00D4 }
    SpellCost: TAOWLabel; { +00D8 }
    SpellIcn: TAOWImage; { +00DC }
    Minimize: TAOWButton; { +00E0 }
    ChangePowerBut: TAOWButton; { +00E4 }
    Power: TAOWLabel; { +00E8 }
    PowerLbl: TAOWLabel; { +00EC }
    PowePnl: TAOWPanel; { +00F0 }
    LeftPnl: TAOWPanel; { +00F4 }
    NonePnl: TAOWPanel; { +00F8 }
    NoneMsg: TAOWLabel; { +00FC }
    T4Pnl: TAOWPanel; { +0100 }
    T4LBPnl: TAOWPanel; { +0104 }
    PowerValueList: TAOWListBox; { +0108 }
    PowerValueSortBtn: TAOWButton; { +010C }
    PowerSourceList: TAOWListBox; { +0110 }
    PowerSourceSortBtn: TAOWButton; { +0114 }
    T2BottonPnl: TAOWPanel; { +0118 }
    EnchantmentSB: TAOWVScrollBar; { +011C }
    GlobalEnchantmentSB: TAOWVScrollBar; { +0120 }
    PowerSB: TAOWVScrollBar; { +0124 }
    T3BottomPnl: TAOWPanel; { +0128 }
    LeftFr: TAOWPanel; { +012C }
    T2ButtonPnl: TAOWPanel; { +0130 }
    T3ButtonPnl: TAOWPanel; { +0134 }
    Translator: TIvTranslator; { +0138 }
    Help: TAOWButton; { +013C }
    public
    FEnchantmentSort: Integer; { $140 }
    FGlobalEnchantmentSort: Integer; { $144 }
    FPowerSort: Integer; { $148 }
    procedure SelectEnchantment(Index: Integer);
    procedure SelectGlobalEnchantment(Index: Integer);
    procedure SelectPowerSource(Index: Integer);
    procedure SortEnchantments;
    procedure SortGlobalEnchantments;
    procedure SortPowerSources;
    procedure EnchantmentListDoubleClick;
    procedure EnchantmentListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DispelBtnClick;
    procedure EnchantmentListChange;
    procedure BindingListChange;
    procedure UpkeepListChange;
    procedure GlobalDispelBtnClick;
    procedure GlobalEnchantmentListChange;
    procedure GlobalNameListChange;
    procedure GlobalUpkeepListChange;
    procedure PowerSourceListChange;
    procedure PowerValueListChange;
    procedure ResearchBtnClick;
    procedure ChangePowerButClick;
    procedure SpellIcnDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure PowerSourceListDoubleClick;
    procedure PowerValueListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PowerSBChange;
    procedure GlobalEnchantmentSBChange;
    procedure EnchantmentSBChange;
    procedure EnchantmentSortBtnClick;
    procedure BindingSortBtnClick;
    procedure UpkeepSortBtnClick;
    procedure GlobalEnchantmentSortBtnClick;
    procedure GlobalNameSortBtnClick;
    procedure GlobalUpkeepSortBtnClick;
    procedure PowerSourceSortBtnClick;
    procedure PowerValueSortBtnClick;
    procedure HeaderTabChange;
    procedure DlgResize;
    procedure DlgShow;
    procedure DlgHide;
    procedure HelpClick;
    procedure GlobalEnchantmentMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;


implementation

uses AoWWinMan, AoWExeForms, AoWPowerDlg, aowHelpWin, E2GameFlow, E2Globals;

procedure TMagicWin.SelectEnchantment(Index: Integer);
begin
  if Index >= EnchantmentList.Items.Count then Index := EnchantmentList.Items.Count - 1;
  EnchantmentList.Selected := Index;
  BindingList.Selected := Index;
  UpkeepList.Selected := Index;
  DispelBtn.Visible := Index <> -1;
end;

procedure TMagicWin.SelectGlobalEnchantment(Index: Integer);
var
  Reason: string;
  Enchantment: TGlobalEnchantment;
begin
  if Index >= GlobalEnchantmentList.Items.Count then Index := GlobalEnchantmentList.Items.Count - 1;
  GlobalEnchantmentList.Selected := Index;
  GlobalNameList.Selected := Index;
  GlobalUpkeepList.Selected := Index;
  if Index <> -1 then
  begin
    Enchantment := TGlobalEnchantment(GlobalEnchantmentList.Items.Objects[Index]);
    GlobalDispelBtn.Visible := Enchantment.CanRemove(AoWHSMap.FSeatedPlayer, Reason);
  end
  else
    GlobalDispelBtn.Visible := False;
end;

procedure TMagicWin.SelectPowerSource(Index: Integer);
begin
  if Index >= PowerSourceList.Items.Count then Index := PowerSourceList.Items.Count - 1;
  PowerSourceList.Selected := Index;
  PowerValueList.Selected := Index;
end;

procedure TMagicWin.SortEnchantments;
begin
  case FEnchantmentSort of
    0: SortStringsAscending(EnchantmentList.Items, [BindingList.Items, UpkeepList.Items]);
    1: SortStringsDescending(EnchantmentList.Items, [BindingList.Items, UpkeepList.Items]);
    2: SortStringsAscending(BindingList.Items, [EnchantmentList.Items, UpkeepList.Items]);
    3: SortStringsDescending(BindingList.Items, [EnchantmentList.Items, UpkeepList.Items]);
    4: SortStringsNumericalAscending(UpkeepList.Items, [EnchantmentList.Items, BindingList.Items]);
    5: SortStringsNumericalDescending(UpkeepList.Items, [EnchantmentList.Items, BindingList.Items]);
  end;
end;

procedure TMagicWin.SortGlobalEnchantments;
begin
  case FGlobalEnchantmentSort of
    0: SortStringsAscending(GlobalEnchantmentList.Items, [GlobalNameList.Items, GlobalUpkeepList.Items]);
    1: SortStringsDescending(GlobalEnchantmentList.Items, [GlobalNameList.Items, GlobalUpkeepList.Items]);
    2: SortStringsAscending(GlobalNameList.Items, [GlobalEnchantmentList.Items, GlobalUpkeepList.Items]);
    3: SortStringsDescending(GlobalNameList.Items, [GlobalEnchantmentList.Items, GlobalUpkeepList.Items]);
    4: SortStringsNumericalAscending(GlobalUpkeepList.Items, [GlobalEnchantmentList.Items, GlobalNameList.Items]);
    5: SortStringsNumericalDescending(GlobalUpkeepList.Items, [GlobalEnchantmentList.Items, GlobalNameList.Items]);
  end;
end;

procedure TMagicWin.SortPowerSources;
begin
  case FPowerSort of
    0: SortStringsAscending(PowerSourceList.Items, [PowerValueList.Items]);
    1: SortStringsDescending(PowerSourceList.Items, [PowerValueList.Items]);
    2: SortStringsNumericalAscending(PowerValueList.Items, [PowerSourceList.Items]);
    3: SortStringsNumericalDescending(PowerValueList.Items, [PowerSourceList.Items]);
  end;
end;



procedure TMagicWin.EnchantmentListDoubleClick;
begin
  if (EnchantmentList.Selected >= 0) and (EnchantmentList.Selected < EnchantmentList.Items.Count) then
    TEnchantment(EnchantmentList.Items.Objects[EnchantmentList.Selected]).Select;
end;


procedure TMagicWin.EnchantmentListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    if (EnchantmentList.Selected >= 0) and (EnchantmentList.Selected < EnchantmentList.Items.Count) then
      TEnchantment(EnchantmentList.Items.Objects[EnchantmentList.Selected]).CenterToLocation;
end;


procedure TMagicWin.DispelBtnClick;
begin
  General.PlayButtonSound(0);
  if (EnchantmentList.Selected >= 0) and (EnchantmentList.Selected < EnchantmentList.Items.Count) then
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.DispelEnchantment(
      TEnchantment(EnchantmentList.Items.Objects[EnchantmentList.Selected]));
end;


procedure TMagicWin.EnchantmentListChange;
begin
  SelectEnchantment(EnchantmentList.Selected);
end;


procedure TMagicWin.BindingListChange;
begin
  SelectEnchantment(BindingList.Selected);
end;


procedure TMagicWin.UpkeepListChange;
begin
  SelectEnchantment(UpkeepList.Selected);
end;


procedure TMagicWin.GlobalDispelBtnClick;
begin
  General.PlayButtonSound(0);
  if (GlobalEnchantmentList.Selected >= 0) and (GlobalEnchantmentList.Selected < GlobalEnchantmentList.Items.Count) then
    AoWHSMap.FGlobalMagicControl.RemoveEnchantment(AoWHSMap.FSeatedPlayer,
      TGlobalEnchantment(GlobalEnchantmentList.Items.Objects[GlobalEnchantmentList.Selected]));
end;


procedure TMagicWin.GlobalEnchantmentListChange;
begin
  SelectGlobalEnchantment(GlobalEnchantmentList.Selected);
end;


procedure TMagicWin.GlobalNameListChange;
begin
  SelectGlobalEnchantment(GlobalNameList.Selected);
end;


procedure TMagicWin.GlobalUpkeepListChange;
begin
  SelectGlobalEnchantment(GlobalUpkeepList.Selected);
end;


procedure TMagicWin.PowerSourceListChange;
begin
  SelectPowerSource(PowerSourceList.Selected);
end;


procedure TMagicWin.PowerValueListChange;
begin
  SelectPowerSource(PowerValueList.Selected);
end;


procedure TMagicWin.ResearchBtnClick;
begin
  General.PlayButtonSound(0);
  SpellBook.ShowResearch;
end;

procedure TMagicWin.ChangePowerButClick;
begin
  General.PlayButtonSound(0);
  PowerDlg.Execute;
end;

procedure TMagicWin.SpellIcnDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  Magic: TPlayerMagicControl;
  Spell: TSpell;
begin
  Magic := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl;
  if Magic.FResearchSpellID <> 0 then
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(Magic.FResearchSpellID);
    if Spell <> nil then
      if Spell.FCastImages.GetImageSequence(10) <> nil then
        with TAOWImage(Sender) do
          Spell.FCastImages.Show(10, FAOWWindow.WinLeft + WinLeft,
            FAOWWindow.WinTop + WinTop, 0, Surface);
  end;
end;

procedure TMagicWin.PowerSourceListDoubleClick;
begin
  if (PowerSourceList.Selected >= 0) and (PowerSourceList.Selected < PowerSourceList.Items.Count) then
    TPowerSource(PowerSourceList.Items.Objects[PowerSourceList.Selected]).Select;
end;


procedure TMagicWin.PowerValueListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    if PowerSourceList.Selected >= 0 then
    if PowerSourceList.Selected < PowerSourceList.Items.Count then
      TPowerSource(PowerSourceList.Items.Objects[PowerSourceList.Selected]).CenterToLocation;
end;

procedure TMagicWin.PowerSBChange;
begin
  PowerSourceList.ListOffset := PowerSB.Position;
  PowerValueList.ListOffset := PowerSB.Position;
end;


procedure TMagicWin.GlobalEnchantmentSBChange;
begin
  GlobalEnchantmentList.ListOffset := GlobalEnchantmentSB.Position;
  GlobalNameList.ListOffset := GlobalEnchantmentSB.Position;
  GlobalUpkeepList.ListOffset := GlobalEnchantmentSB.Position;
end;


procedure TMagicWin.EnchantmentSBChange;
begin
  EnchantmentList.ListOffset := EnchantmentSB.Position;
  BindingList.ListOffset := EnchantmentSB.Position;
  UpkeepList.ListOffset := EnchantmentSB.Position;
end;


procedure TMagicWin.EnchantmentSortBtnClick;
begin
  General.PlayButtonSound(0);
  if FEnchantmentSort = 0 then FEnchantmentSort := 1
  else FEnchantmentSort := 0;
  SortEnchantments;
end;


procedure TMagicWin.BindingSortBtnClick;
begin
  General.PlayButtonSound(0);
  if FEnchantmentSort = 2 then FEnchantmentSort := 3
  else FEnchantmentSort := 2;
  SortEnchantments;
end;


procedure TMagicWin.UpkeepSortBtnClick;
begin
  General.PlayButtonSound(0);
  if FEnchantmentSort = 4 then FEnchantmentSort := 5
  else FEnchantmentSort := 4;
  SortEnchantments;
end;


procedure TMagicWin.GlobalEnchantmentSortBtnClick;
begin
  General.PlayButtonSound(0);
  if FGlobalEnchantmentSort = 0 then FGlobalEnchantmentSort := 1
  else FGlobalEnchantmentSort := 0;
  SortGlobalEnchantments;
end;


procedure TMagicWin.GlobalNameSortBtnClick;
begin
  General.PlayButtonSound(0);
  { Original name/upkeep buttons also toggle the enchantment-name order. }
  if FGlobalEnchantmentSort = 0 then FGlobalEnchantmentSort := 1
  else FGlobalEnchantmentSort := 0;
  SortGlobalEnchantments;
end;


procedure TMagicWin.GlobalUpkeepSortBtnClick;
begin
  General.PlayButtonSound(0);
  { Original name/upkeep buttons also toggle the enchantment-name order. }
  if FGlobalEnchantmentSort = 0 then FGlobalEnchantmentSort := 1
  else FGlobalEnchantmentSort := 0;
  SortGlobalEnchantments;
end;


procedure TMagicWin.PowerSourceSortBtnClick;
begin
  General.PlayButtonSound(0);
  if FPowerSort = 0 then FPowerSort := 1
  else FPowerSort := 0;
  SortPowerSources;
end;


procedure TMagicWin.PowerValueSortBtnClick;
begin
  General.PlayButtonSound(0);
  if FPowerSort = 2 then FPowerSort := 3
  else FPowerSort := 2;
  SortPowerSources;
end;


procedure TMagicWin.HeaderTabChange;
begin
  General.PlayButtonSound(0);
end;


procedure TMagicWin.DlgResize;
begin
  with Dlg do
    with Alignment do
    begin
      AlignWidth := awLeft;
      AlignHeight := ahTop;
      LeftOffset := WinLeft;
      TopOffset := WinTop;
    end;
end;


procedure TMagicWin.DlgShow;
begin
  General.RegisterDialog(Dlg);
end;


procedure TMagicWin.DlgHide;
begin
  General.UnregisterDialog(Dlg);
end;


procedure TMagicWin.HelpClick;
begin ShowHelp(506); end;

procedure TMagicWin.GlobalEnchantmentMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    if (GlobalEnchantmentList.Selected >= 0) and (GlobalEnchantmentList.Selected < GlobalEnchantmentList.Items.Count) then
      TGlobalEnchantment(GlobalEnchantmentList.Items.Objects[GlobalEnchantmentList.Selected]).CenterToLocation;
end;


end.
