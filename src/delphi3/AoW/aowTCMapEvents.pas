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
    FChatHeight: Integer; { $48; 004584BE }
    procedure TCMapActivateMap;  { draft }
    procedure TCMapDeActivateMap;  { draft }
    procedure TCMapDeselected(HS: THexagonSprite);
    procedure TCMapMapChanged(const R: TMapChangedInfo);
    procedure TCMapMouseOverTarget(HS: THexagonSprite);
    procedure TCMapSeatedPlayerChanged(Player: Shortint);
    procedure TCMapSelected(HS: THexagonSprite);
    procedure TCMapShowMessage(const Info: TShowMessageInfo);
    procedure TCMapUnitChanged(HS: TTacticalCombatUnitHS);
    procedure TCMapCastSpell(Caster: TCombatSpellCaster);
    procedure TCMapActivateAbility(Info: TActivateAbilityInfo);
    procedure TCMapTurnChanged;  { draft }
  end;


implementation

uses AoWExeForms, AOWMWindow, AoWTCUnit, AoWWinMan, AoWComp, E3Globals, aowMapEvents, E1Globals, E1GameFlow, E1TacticalSupport;


procedure TTCMapEvents.TCMapActivateMap;
begin
  SongPlayer.Pause(False);
  if AoWEngine.FDemo then PlaySongEx('Songs\Combat\Defend.IT', 2, 0, True)
  else
    case Random(3) of
      0: PlaySongEx('Songs\Combat\Defend.IT', 2, 0, True);
      1: PlaySongEx('Songs\Combat\Outnum.IT', 2, 0, True);
      2: PlaySongEx('Songs\Combat\Races.IT', 2, 0, True);
    end;
  AOWMWindow.MWindow.MapViewer.HSMap := AoWCombatMap;
  AoWExeForms.TCScanner.Scanner.SetMap(AoWCombatMap);
  with TCScanner do
  begin
    Scanner.FPreviousWidth := 0;
    Scanner.FIncremental := False;
    Scanner.FSized := False;
    Scanner.FUpdateStep := -1;
  end;
  AOWMWindow.MWindow.MapWindow.Visible := True;
  General.HideWindows;
  AoWCombatMap := TAoWCombatMap(AoWHSMap.FCombatMap);
  AOWMWindow.MWindow.MapWindow.Visible := AoWCombatMap.FPlaySounds;
  AOWMWindow.MWindow.FWorldAlignWidth := AOWMWindow.MWindow.MapWindow.Alignment.AlignWidth;
  AOWMWindow.MWindow.FWorldAlignHeight := AOWMWindow.MWindow.MapWindow.Alignment.AlignHeight;
  AOWMWindow.MWindow.FWorldRect.Left := AOWMWindow.MWindow.MapWindow.Alignment.LeftOffset;
  AOWMWindow.MWindow.FWorldRect.Top := AOWMWindow.MWindow.MapWindow.Alignment.TopOffset;
  if AOWMWindow.MWindow.FWorldAlignWidth = awBoth then
    AOWMWindow.MWindow.FWorldRect.Right := AOWMWindow.MWindow.MapWindow.Alignment.RightOffset
  else AOWMWindow.MWindow.FWorldRect.Right := AOWMWindow.MWindow.MapWindow.WinWidth;
  if AOWMWindow.MWindow.FWorldAlignHeight = ahBoth then
    AOWMWindow.MWindow.FWorldRect.Bottom := AOWMWindow.MWindow.MapWindow.Alignment.BottomOffset
  else AOWMWindow.MWindow.FWorldRect.Bottom := AOWMWindow.MWindow.MapWindow.WinHeight;
  AOWMWindow.MWindow.MapWindow.Alignment.LeftOffset := AOWMWindow.MWindow.FMapRect.Left;
  AOWMWindow.MWindow.MapWindow.Alignment.TopOffset := AOWMWindow.MWindow.FMapRect.Top;
  AOWMWindow.MWindow.MapWindow.Alignment.RightOffset := AOWMWindow.MWindow.FMapRect.Right;
  AOWMWindow.MWindow.MapWindow.Alignment.BottomOffset := AOWMWindow.MWindow.FMapRect.Bottom;
  AOWMWindow.MWindow.MapWindow.WinWidth := AOWMWindow.MWindow.FMapRect.Right;
  AOWMWindow.MWindow.MapWindow.WinHeight := AOWMWindow.MWindow.FMapRect.Bottom;
  AOWMWindow.MWindow.MapWindow.Alignment.AlignWidth := AOWMWindow.MWindow.FMapAlignWidth;
  AOWMWindow.MWindow.MapWindow.Alignment.AlignHeight := AOWMWindow.MWindow.FMapAlignHeight;
  AOWMWindow.MWindow.MapWindow.FAligned := False;
  AoWExeForms.TBWindow.TBWorld.Visible := False;
  AoWExeForms.TBWindow.TBCombat.Visible := True;
  AoWExeForms.TBWindow.TCCurPUpdate;
  AoWExeForms.TBWindow.AutoBtn.Checked := False;
  AoWExeForms.TBWindow.TCChatBtn.Visible := AoWExeForms.TBWindow.ChatBtn.Visible;
  AoWExeForms.TBWindow.TCUnitBtn.Visible := False;
  AoWExeForms.TBWindow.TaskWindow.FDrawn := False;
  AoWExeForms.TCScanner.TCScannerWin.Visible := AoWCombatMap.FPlaySounds;
  AoWExeForms.TBWindow.TCScannerBtn.Visible := AoWCombatMap.FPlaySounds;
  AoWTCUnit.TCUnit.TCUnitWin.Visible := False;
  if not AoWCombatMap.FPlaySounds then
  begin
    FChatHeight := AoWExeForms.ChatWindow.ChatWin.WinHeight;
    AoWExeForms.ChatWindow.ChatWin.Alignment.AlignHeight := ahBoth;
  end
  else FChatHeight := 0;
  if General.FChatVisible or not AoWCombatMap.FPlaySounds then
    AoWExeForms.ChatWindow.ChatWin.Visible := True;
end;

procedure TTCMapEvents.TCMapDeActivateMap;
begin
  StopSong;
  SongPlayer.Resume;
  AOWMWindow.MWindow.MapViewer.HSMap := AoWHSMap;
  SWindow.Scanner.SetMap(AoWHSMap);
  with SWindow do
  begin
    Scanner.FPreviousWidth := 0;
    Scanner.FIncremental := False;
    Scanner.FSized := False;
    Scanner.FUpdateStep := -1;
  end;
  if FChatHeight > 0 then AoWExeForms.ChatWindow.ChatWin.WinHeight := FChatHeight;
  with ChatWindow do
  begin
    ChatWin.Alignment.AlignHeight := ahBottom;
    ChatWin.Visible := False;
  end;
  AoWExeForms.ChatWindow.FScrollPending := True;
  AOWMWindow.MWindow.FMapAlignWidth := AOWMWindow.MWindow.MapWindow.Alignment.AlignWidth;
  AOWMWindow.MWindow.FMapAlignHeight := AOWMWindow.MWindow.MapWindow.Alignment.AlignHeight;
  AOWMWindow.MWindow.FMapRect.Left := AOWMWindow.MWindow.MapWindow.Alignment.LeftOffset;
  AOWMWindow.MWindow.FMapRect.Top := AOWMWindow.MWindow.MapWindow.Alignment.TopOffset;
  if AOWMWindow.MWindow.FMapAlignWidth = awBoth then
    AOWMWindow.MWindow.FMapRect.Right := AOWMWindow.MWindow.MapWindow.Alignment.RightOffset
  else AOWMWindow.MWindow.FMapRect.Right := AOWMWindow.MWindow.MapWindow.WinWidth;
  if AOWMWindow.MWindow.FMapAlignHeight = ahBoth then
    AOWMWindow.MWindow.FMapRect.Bottom := AOWMWindow.MWindow.MapWindow.Alignment.BottomOffset
  else AOWMWindow.MWindow.FMapRect.Bottom := AOWMWindow.MWindow.MapWindow.WinHeight;
  AOWMWindow.MWindow.MapWindow.Alignment.LeftOffset := AOWMWindow.MWindow.FWorldRect.Left;
  AOWMWindow.MWindow.MapWindow.Alignment.TopOffset := AOWMWindow.MWindow.FWorldRect.Top;
  AOWMWindow.MWindow.MapWindow.Alignment.RightOffset := AOWMWindow.MWindow.FWorldRect.Right;
  AOWMWindow.MWindow.MapWindow.Alignment.BottomOffset := AOWMWindow.MWindow.FWorldRect.Bottom;
  AOWMWindow.MWindow.MapWindow.WinWidth := AOWMWindow.MWindow.FWorldRect.Right;
  AOWMWindow.MWindow.MapWindow.WinHeight := AOWMWindow.MWindow.FWorldRect.Bottom;
  AOWMWindow.MWindow.MapWindow.Alignment.AlignWidth := AOWMWindow.MWindow.FWorldAlignWidth;
  AOWMWindow.MWindow.MapWindow.Alignment.AlignHeight := AOWMWindow.MWindow.FWorldAlignHeight;
  General.ShowWindows;
  General.Manager.FAligned := False;
  AoWExeForms.TBWindow.TBWorld.Visible := True;
  AoWExeForms.TBWindow.TBCombat.Visible := False;
  AoWExeForms.TBWindow.TurnButton.FButtonChecked := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSingleProcessCycle;
  AoWExeForms.TCScanner.TCScannerWin.Visible := False;
  AoWTCUnit.TCUnit.TCUnitWin.Visible := False;
  AoWExeForms.TCScanner.Scanner.SetMap(nil);
  General.Manager.OverlayPriority := 0;
  MapEvents.TheMapGemsChanged(AoWHSMap.FSeatedPlayer);
  MapEvents.TheMapIncomeChanged(AoWHSMap.FSeatedPlayer);
  MapEvents.TheMapPlayerMagicChanged(AoWHSMap.FSeatedPlayer);
end;

procedure TTCMapEvents.TCMapDeselected(HS: THexagonSprite);
begin
  if HS is TTacticalCombatUnitHS then
  begin
    General.FCombatUnit := nil;
    General.FSelectedUnit := nil;
    UnitWindow.UnitWin.Visible := False;
    AoWExeForms.TBWindow.TCUnitBtn.Visible := False;
    AoWTCUnit.TCUnit.TCUnitWin.Visible := False;
  end;
end;

procedure TTCMapEvents.TCMapMapChanged(const R: TMapChangedInfo);
begin
  AoWExeForms.TCScanner.Scanner.DrawMap(R.Bounds.Left - 8, R.Bounds.Top - 6, R.Bounds.Right - R.Bounds.Left, R.Bounds.Bottom - R.Bounds.Top);
end;

procedure TTCMapEvents.TCMapMouseOverTarget(HS: THexagonSprite);
var
  U: TAbstractUnit;
begin
  if AoWTCUnit.TCUnit.TCUnitWin.Visible then
  begin
    AoWTCUnit.TCUnit.TargetSelPnl.Visible := HS <> nil;
    AoWTCUnit.TCUnit.NoTargetPnl.Visible := HS = nil;
    if HS <> nil then
      if HS is TTacticalCombatUnitHS then
      begin
        U := TTacticalCombatUnitHS(HS).FUnit.FUnit;
        AoWTCUnit.TCUnit.TargetULbl.Text := U.GetName;
        AoWTCUnit.TCUnit.AHits.Text := IntToStr(U.GetHitPoints) + '/' + IntToStr(U.GetHits);
        AoWTCUnit.TCUnit.AMoves.Text := IntToStr(U.GetMovePoints) + '/' + IntToStr(U.GetMoves);
        AoWTCUnit.TCUnit.AAttack.Text := IntToStr(U.GetAttack);
        AoWTCUnit.TCUnit.ADamage.Text := IntToStr(U.GetDamage);
        AoWTCUnit.TCUnit.ADefense.Text := IntToStr(U.GetDefense);
        AoWTCUnit.TCUnit.AResistance.Text := IntToStr(U.GetResistance);
        AoWTCUnit.TCUnit.AMovesIcon.SetCurrent(General.MTtoInt(U.GetMoveTypes));
        U.ListAbilities(AoWTCUnit.TCUnit.USelAbilLb.Items);
      end;
  end;
end;

procedure TTCMapEvents.TCMapSeatedPlayerChanged(Player: Shortint);
begin
  AOWMWindow.MWindow.MapWindow.Visible := AoWCombatMap.FPlaySounds;
  AoWExeForms.TCScanner.TCScannerWin.Visible := AoWCombatMap.FPlaySounds;
  if AoWCombatMap.FSeatedCombatPlayer = -1 then AoWExeForms.TBWindow.AutoBtn.Checked := False
  else AoWExeForms.TBWindow.AutoBtn.Checked := AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FSeatedCombatPlayer).FAuto;
  MapEvents.TheMapGemsChanged(Player);
  MapEvents.TheMapIncomeChanged(Player);
  MapEvents.TheMapPlayerMagicChanged(Player);
end;

procedure TTCMapEvents.TCMapSelected(HS: THexagonSprite);
begin
  if HS is TTacticalCombatUnitHS then
  begin
    General.FCombatUnit := TTacticalCombatUnitHS(HS);
    AoWTCUnit.RefreshCombatUnit(TCUnit);
  end;
end;

procedure TTCMapEvents.TCMapShowMessage(const Info: TShowMessageInfo);
begin
  AoWExeForms.TBWindow.TCMsg.TextColor := Info.Color;
  AoWExeForms.TBWindow.TCMsg.Text := Info.Text;
end;

procedure TTCMapEvents.TCMapUnitChanged(HS: TTacticalCombatUnitHS);
begin
  if (HS = General.FCombatUnit) and (HS <> nil) then AoWTCUnit.RefreshCombatUnit(TCUnit);
end;

procedure TTCMapEvents.TCMapCastSpell(Caster: TCombatSpellCaster);
begin
  AoWTCUnit.TCUnit.UAbilLB.Selected := General.FCombatUnit.SelectSpell(Caster.FCombatCasterSpellID);
end;

procedure TTCMapEvents.TCMapActivateAbility(Info: TActivateAbilityInfo);
begin
  if Info.FAbilityID = $34 then SpellBook.ShowCombatCasting(Info);
end;

procedure TTCMapEvents.TCMapTurnChanged;
begin
  with TBWindow do
  begin
    TCTurnButton.FCurPlayer := AoWHSMap.FPlayers.GetPlayers(AoWCombatMap.FCurrentPlayer).FPlayerRace;
    if TCTurnButton.FCurPlayer = -1 then TCTurnButton.FCurPlayer := 12;
    TCTurnButton.FLastPlayer := -1;
  end;
  General.Manager.OverlayPriority := 49;
  AoWExeForms.TBWindow.TCPInd.FDrawn := False;
end;

end.
