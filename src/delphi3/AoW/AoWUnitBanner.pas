unit AoWUnitBanner;

{ Draft declarations of AoWUnitBanner, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC, AoWComp, AOWMenu, AoWImage, AoWLabel, AoWListBox, AoWVScroll;

type
  TUnitBanner = class;


  { TUnitBanner (instance size $84, VMT 00403D84).
    $44..80 published labels, popup and ability-list controls. }
  TUnitBanner = class(TDataModule)
  public
    published
    UnitNameLbl: TAOWLabel; { +0044 }
    AttackIcon: TAOWImage; { +0048 }
    DefenseIcon: TAOWImage; { +004C }
    MovesIcon: TAOWImage; { +0050 }
    DamageIcon: TAOWImage; { +0054 }
    ResistanceIcon: TAOWImage; { +0058 }
    HitsIcon: TAOWImage; { +005C }
    Attack: TAOWLabel; { +0060 }
    Defense: TAOWLabel; { +0064 }
    Moves: TAOWLabel; { +0068 }
    Damage: TAOWLabel; { +006C }
    Resistance: TAOWLabel; { +0070 }
    Hits: TAOWLabel; { +0074 }
    BannerPopup: TAOWMenu; { +0078 }
    AbLB: TAOWListBox; { +007C }
    AbVSB: TAOWVScrollBar; { +0080 }
    public
    published procedure BannerPopupShow(Sender: TObject); public  { draft }
    published procedure AbLBUpdate; public  { draft }
    published procedure AbLBMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); public
    published procedure BannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer); public  { draft }
    published procedure AbLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
  end;


var
  UnitBanner: TUnitBanner;

implementation

uses AoWWinMan;

procedure TUnitBanner.BannerPopupShow(Sender: TObject);
var
  I: Integer;
  A: TTCAbility;
begin
  if General.FSelectedUnit <> nil then
  begin
    UnitNameLbl.Text := General.FSelectedUnit.GetName;
    BannerPopup.FAligned := False;
    Hits.Text := IntToStr(General.FSelectedUnit.GetHitPoints) + '/' + IntToStr(General.FSelectedUnit.GetHits);
    Moves.Text := IntToStr(General.FSelectedUnit.GetMovePoints) + '/' + IntToStr(General.FSelectedUnit.GetMoves);
    Attack.Text := IntToStr(General.FSelectedUnit.GetAttack);
    Damage.Text := IntToStr(General.FSelectedUnit.GetDamage);
    Defense.Text := IntToStr(General.FSelectedUnit.GetDefense);
    Resistance.Text := IntToStr(General.FSelectedUnit.GetResistance);
    MovesIcon.CurrentImage := General.MTtoInt(General.FSelectedUnit.GetMoveTypes);
    AbLB.Items.Clear; General.BuildAbilities;
    for I := 0 to General.FAbilities.Count - 1 do
    begin
      A := General.FAbilities[I];
      AbLB.Items.Add(AoWHSSet.FAbilityControl.GetAbility(A.Ability).GetName(General.FSelectedUnit));
    end;
    AbLB.Selected := -1;
    with AbLB do begin F188 := -1; ListOffset := 0; end;
  end;
end;

procedure TUnitBanner.AbLBUpdate;
begin
  if AbLB.F188 <> AbLB.Selected then AbLB.Selected := AbLB.F188;
end;

procedure TUnitBanner.AbLBMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); { Tried with/local receiver; no exact match. }
begin
  if (General.FSelectedUnit <> nil) and (AbLB.F188 >= General.FActiveAbilityCount) then AbLB.F188 := -1;
end;

procedure TUnitBanner.BannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin
  if A2 = 1 then UnitBanner.BannerPopup.Visible := False;
end;

procedure TUnitBanner.AbLBMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Reason: string;
begin
  if General.FSelectedUnit <> nil then
    if (AbLB.Selected > -1) and (AbLB.Selected < General.FActiveAbilityCount) then
    begin
      AoWHSSet.FAbilityControl.GetAbility(TTCAbility(General.FAbilities[AbLB.Selected]).Ability).Activate(General.FSelectedUnit, Reason);
      BannerPopup.Visible := False;
    end
    else AbLB.Selected := -1;
end;


end.
