unit aowTCMapEvents;

{ Partly recovered aowTCMapEvents handlers, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Any remaining stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC, CMapCtrl;

type
  TTCMapEvents = class;


  { TTCMapEvents (instance size 76, VMT 00458004) }
  TTCMapEvents = class(TDataModule)
  public
    published
    TCMap: TAoWCombatMapControl; { +0044 }
    public
    F_TCMapEvents_48: Integer;
    procedure TCMapActivateMap;  { draft }
    procedure TCMapDeActivateMap;  { draft }
    procedure TCMapDeselected(HS: THexagonSprite);
    procedure TCMapMapChanged(const R: TMapChangedInfo);
    procedure TCMapMouseOverTarget(HS: THexagonSprite);
    procedure TCMapSeatedPlayerChanged(Player: Shortint);
    procedure TCMapSelected(A1: Integer);  { draft }
    procedure TCMapShowMessage(const Info: TShowMessageInfo);
    procedure TCMapUnitChanged(A1: Integer);  { draft }
    procedure TCMapCastSpell(Caster: TCombatSpellCaster);
    procedure TCMapActivateAbility(A1: Integer);  { draft }
    procedure TCMapTurnChanged;  { draft }
  end;


implementation

uses AoWWinMan, AoWComp, E3Globals, aowMapEvents, E1Globals;


procedure TTCMapEvents.TCMapActivateMap;
begin end;

procedure TTCMapEvents.TCMapDeActivateMap;
begin end;

procedure TTCMapEvents.TCMapDeselected(HS: THexagonSprite);
begin
  if HS is TTacticalCombatUnitHS then
  begin
    General.FCombatUnit := nil;
    General.FSelectedUnit := nil;
    UnitWindow.UnitWin.Visible := False;
    TBWindow.TCUnitBtn.Visible := False;
    TCUnit.TCUnitWin.Visible := False;
  end;
end;

procedure TTCMapEvents.TCMapMapChanged(const R: TMapChangedInfo);
begin
  TCScanner.Scanner.DrawMap(R.Bounds.Left - 8, R.Bounds.Top - 6, R.Bounds.Right - R.Bounds.Left, R.Bounds.Bottom - R.Bounds.Top);
end;

procedure TTCMapEvents.TCMapMouseOverTarget(HS: THexagonSprite);
var
  U: TAbstractUnit;
begin
  if TCUnit.TCUnitWin.Visible then
  begin
    TCUnit.TargetSelPnl.Visible := HS <> nil;
    TCUnit.NoTargetPnl.Visible := HS = nil;
    if HS <> nil then
      if HS is TTacticalCombatUnitHS then
      begin
        U := TTacticalCombatUnitHS(HS).FUnit.FUnit;
        TCUnit.TargetULbl.Text := U.GetName;
        TCUnit.AHits.Text := IntToStr(U.GetHitPoints) + '/' + IntToStr(U.GetHits);
        TCUnit.AMoves.Text := IntToStr(U.GetMovePoints) + '/' + IntToStr(U.GetMoves);
        TCUnit.AAttack.Text := IntToStr(U.GetAttack);
        TCUnit.ADamage.Text := IntToStr(U.GetDamage);
        TCUnit.ADefense.Text := IntToStr(U.GetDefense);
        TCUnit.AResistance.Text := IntToStr(U.GetResistance);
        TCUnit.AMovesIcon.SetCurrent(General.MTtoInt(U.GetMoveTypes));
        U.ListAbilities(TCUnit.USelAbilLb.Items);
      end;
  end;
end;

procedure TTCMapEvents.TCMapSeatedPlayerChanged(Player: Shortint);
begin
  MWindow.MapWindow.Visible := AoWCombatMap.FPlaySounds;
  TCScanner.TCScannerWin.Visible := AoWCombatMap.FPlaySounds;
  if AoWCombatMap.FSeatedCombatPlayer = -1 then TBWindow.AutoBtn.Checked := False
  else TBWindow.AutoBtn.Checked := AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FSeatedCombatPlayer).FAuto;
  MapEvents.TheMapGemsChanged(Player);
  MapEvents.TheMapIncomeChanged(Player);
  MapEvents.TheMapPlayerMagicChanged(Player);
end;

procedure TTCMapEvents.TCMapSelected(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapShowMessage(const Info: TShowMessageInfo);
begin
  TBWindow.TCMsg.TextColor := Info.Color;
  TBWindow.TCMsg.Text := Info.Text;
end;

procedure TTCMapEvents.TCMapUnitChanged(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapCastSpell(Caster: TCombatSpellCaster);
begin
  TCUnit.UAbilLB.Selected := General.FCombatUnit.SelectSpell(Caster.FCombatCasterSpellID);
end;

procedure TTCMapEvents.TCMapActivateAbility(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapTurnChanged;
var
  Race: Integer;
begin
  Race := AoWHSMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentPlayer).FPlayerRace;
  with TBWindow.TCTurnButton do
  begin
    FCurPlayer := Race;
    if FCurPlayer = -1 then FCurPlayer := 12;
  end;
  TBWindow.TCTurnButton.FLastPlayer := -1;
  General.Manager.OverlayPriority := 49;
  TBWindow.TCPInd.FDrawn := False;
end;


end.
