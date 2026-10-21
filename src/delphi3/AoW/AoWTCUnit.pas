unit AoWTCUnit;

{ Draft declarations of AoWTCUnit, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox, AoWE, AoWTC;

type
  TTCUnit = class;


  { TTCUnit (instance size $154, VMT 00433494); components $44..$150. }
  TTCUnit = class(TDataModule)
  public
    published
    TCUnitWin: TAOWWindow; { +0044 }
    SIcon: TAOWImage; { +0048 }
    Min: TAOWButton; { +004C }
    Close: TAOWButton; { +0050 }
    IWTitle: TAOWLabel; { +0054 }
    UAttackIcon: TAOWImage; { +0058 }
    UDefenseIcon: TAOWImage; { +005C }
    UMovesIcon: TAOWImage; { +0060 }
    UDamageIcon: TAOWImage; { +0064 }
    UResistanceIcon: TAOWImage; { +0068 }
    UHitsIcon: TAOWImage; { +006C }
    UAttack: TAOWLabel; { +0070 }
    UDefense: TAOWLabel; { +0074 }
    UMoves: TAOWLabel; { +0078 }
    UDamage: TAOWLabel; { +007C }
    UResistance: TAOWLabel; { +0080 }
    UHits: TAOWLabel; { +0084 }
    UnitName: TAOWMemo; { +0088 }
    UStatPnl: TAOWPanel; { +008C }
    UAbilLB: TAOWListBox; { +0090 }
    AbilNameLbl: TAOWLabel; { +0094 }
    TCUnitPnl: TAOWPanel; { +0098 }
    AOWImage1: TAOWImage; { +009C }
    AUnitName: TAOWMemo; { +00A0 }
    USelAbilLb: TAOWListBox; { +00A4 }
    TCAbilPnl: TAOWPanel; { +00A8 }
    AbilAtt: TAOWImage; { +00AC }
    AbilAttLbl: TAOWLabel; { +00B0 }
    AbilStatBox: TAOWPanel; { +00B4 }
    AbilStat: TAOWListBox; { +00B8 }
    AbilDam: TAOWImage; { +00BC }
    AbilDamLbl: TAOWLabel; { +00C0 }
    TargetLbl: TAOWLabel; { +00C4 }
    TargetULbl: TAOWLabel; { +00C8 }
    TargetSelPnl: TAOWPanel; { +00CC }
    NoTargetPnl: TAOWPanel; { +00D0 }
    TargetMessage: TAOWMemo; { +00D4 }
    UnitHits: TAoWGauge; { +00D8 }
    UnitMana: TAoWGauge; { +00DC }
    CelticCross: TAOWImage; { +00E0 }
    UStatP1: TAOWPanel; { +00E4 }
    UStatP2: TAOWPanel; { +00E8 }
    AAttackIcon: TAOWImage; { +00EC }
    ADefenseIcon: TAOWImage; { +00F0 }
    AMovesIcon: TAOWImage; { +00F4 }
    ADamageIcon: TAOWImage; { +00F8 }
    AResistanceIcon: TAOWImage; { +00FC }
    AHitsIcons: TAOWImage; { +0100 }
    AAttack: TAOWLabel; { +0104 }
    ADefense: TAOWLabel; { +0108 }
    AMoves: TAOWLabel; { +010C }
    ADamage: TAOWLabel; { +0110 }
    AResistance: TAOWLabel; { +0114 }
    AHits: TAOWLabel; { +0118 }
    AStatPnl: TAOWPanel; { +011C }
    AStatP1: TAOWPanel; { +0120 }
    AStatP2: TAOWPanel; { +0124 }
    Center: TAOWButton; { +0128 }
    AbilSB: TAOWVScrollBar; { +012C }
    UAbilSB: TAOWVScrollBar; { +0130 }
    AOWVScrollBar1: TAOWVScrollBar; { +0134 }
    AbilFr: TAOWPanel; { +0138 }
    ANameFr: TAOWPanel; { +013C }
    TargerFr: TAOWPanel; { +0140 }
    TNamePnl: TAOWPanel; { +0144 }
    UnitFr: TAOWPanel; { +0148 }
    UnitBox: TaowUserDrawBox; { +014C }
    Translator: TIvTranslator; { +0150 }
    public
    procedure TCUnitWinResize;
    procedure MinClick;
    procedure UAbilLBPreDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
    procedure TCUnitPnlDrawBack(Sender: TObject; SD: TSurfaceDesc);
    procedure UAbilLBUpdate;
    procedure UAbilLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure UAbilLBMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HeroSMapMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CenterClick;
    procedure CloseClick;
  end;


implementation

uses E3Globals, AoWWinMan, AoWInfoBanner;

procedure TTCUnit.TCUnitWinResize;
begin
  with TCUnitWin do
  begin
    Alignment.RightOffset := WinManager.WinWidth - WinLeft - WinWidth;
    Alignment.BottomOffset := WinManager.WinHeight - WinTop - WinHeight;
  end;
end;


procedure TTCUnit.MinClick;
begin
  General.PlayButtonSound(0);
  TCUnitWin.Visible := False;
end;


procedure TTCUnit.UAbilLBPreDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
begin
  if General.FCombatUnit <> nil then
    if (General.FCombatUnit.FUnit.GetPlayer = AoWCombatMap.FSeatedPlayer) and
       (General.FCombatUnit.FUnit.FMovePoints > 0) and
       (DrawItem < General.FCombatUnit.FCombatAbilityCount) and
       ((not (AoWHSSet.FAbilityControl.GetAbility(TTCAbility(General.FCombatUnit.FAbilities[DrawItem]).Ability).
          GetCombatMode(General.FCombatUnit.FUnit.FUnit) in [cmShortRange..cmLongRange]) and
          (TTCAbility(General.FCombatUnit.FAbilities[DrawItem]).Ability <> $34)) or
        (General.FCombatUnit.FUnit.FUnit.GetMoves = General.FCombatUnit.FUnit.FMovePoints)) then
      UAbilLB.TextColor := $FFFFFF
    else UAbilLB.TextColor := $C0C0C0;
end;


procedure TTCUnit.TCUnitPnlDrawBack(Sender: TObject; SD: TSurfaceDesc);
begin
  if General.FCombatUnit <> nil then
    General.FCombatUnit.FUnit.FUnit.ShowEx(TCUnitPnl.WinLeft - 10,
      TCUnitPnl.WinTop - 2, SD, General.FUnitShowInfo);
end;


procedure TTCUnit.UAbilLBUpdate;
begin
  if UAbilLB.F188 <> UAbilLB.Selected then UAbilLB.Selected := UAbilLB.F188;
end;


procedure TTCUnit.UAbilLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Ability: TAbility;
begin
  if UAbilLB.Selected > -1 then
    if Button = mbLeft then
      UAbilLB.Selected := General.FCombatUnit.SelectAbility(Integer(UAbilLB.Items.Objects[UAbilLB.Selected]))
    else if (Button = mbRight) and (General.FCombatUnit <> nil) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(Integer(UAbilLB.Items.Objects[UAbilLB.Selected]));
      if Ability <> nil then
        InfoBanner.ShowInfo(Ability.GetName(General.FCombatUnit.FUnit.FUnit), Ability.FDescription);
    end;
end;


procedure TTCUnit.UAbilLBMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if General.FCombatUnit <> nil then
  begin
    if (General.FCombatUnit.FUnit.GetPlayer = AoWCombatMap.FSeatedPlayer) and
       (General.FCombatUnit.FUnit.FMovePoints <> 0) and
       (UAbilLB.F188 < General.FCombatUnit.FCombatAbilityCount) then
    begin
      if not (AoWHSSet.FAbilityControl.GetAbility(TTCAbility(General.FCombatUnit.FAbilities[UAbilLB.F188]).Ability).
        GetCombatMode(General.FCombatUnit.FUnit.FUnit) in [cmShortRange..cmLongRange]) and
        (TTCAbility(General.FCombatUnit.FAbilities[UAbilLB.F188]).Ability <> $34) then Exit;
      with General.FCombatUnit.FUnit do
        if FUnit.GetMoves <= FMovePoints then Exit;
    end;
    UAbilLB.F188 := -1;
  end;
end;


procedure TTCUnit.HeroSMapMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  General.FSelectedUnit := General.FCombatUnit.FUnit.FUnit;
  UnitWindow.ShowUnit;
end;


procedure TTCUnit.CenterClick;
begin
  General.PlayButtonSound(0);
  AoWCombatMap.CenterViewTo(General.FCombatUnit.GetXhx, General.FCombatUnit.GetYhx, General.FCombatUnit.GetLhx);
  AoWCombatMap.PlayCenterAnimation(General.FCombatUnit.GetXhx, General.FCombatUnit.GetYhx, General.FCombatUnit.GetLhx);
end;


procedure TTCUnit.CloseClick;
begin
  General.PlayButtonSound(0);
  TCUnitWin.Visible := False;
end;



end.
