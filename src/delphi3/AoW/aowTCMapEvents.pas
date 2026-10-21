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

uses AoWWinMan, AoWComp, E3Globals, aowMapEvents, E1Globals, E1GameFlow, E1TacticalSupport;


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
  MWindow.MapViewer.HSMap := AoWCombatMap;
  TCScanner.Scanner.SetMap(AoWCombatMap);
  with TCScanner do
  begin
    Scanner.FPreviousWidth := 0;
    Scanner.FIncremental := False;
    Scanner.FSized := False;
    Scanner.FUpdateStep := -1;
  end;
  MWindow.MapWindow.Visible := True;
  HideGameWindows(General);
  AoWCombatMap := TAoWCombatMap(AoWHSMap.FCombatMap);
  MWindow.MapWindow.Visible := AoWCombatMap.FPlaySounds;
  MWindow.FWorldAlignWidth := MWindow.MapWindow.Alignment.AlignWidth;
  MWindow.FWorldAlignHeight := MWindow.MapWindow.Alignment.AlignHeight;
  MWindow.FWorldRect.Left := MWindow.MapWindow.Alignment.LeftOffset;
  MWindow.FWorldRect.Top := MWindow.MapWindow.Alignment.TopOffset;
  if MWindow.FWorldAlignWidth = awBoth then
    MWindow.FWorldRect.Right := MWindow.MapWindow.Alignment.RightOffset
  else MWindow.FWorldRect.Right := MWindow.MapWindow.WinWidth;
  if MWindow.FWorldAlignHeight = ahBoth then
    MWindow.FWorldRect.Bottom := MWindow.MapWindow.Alignment.BottomOffset
  else MWindow.FWorldRect.Bottom := MWindow.MapWindow.WinHeight;
  MWindow.MapWindow.Alignment.LeftOffset := MWindow.FMapRect.Left;
  MWindow.MapWindow.Alignment.TopOffset := MWindow.FMapRect.Top;
  MWindow.MapWindow.Alignment.RightOffset := MWindow.FMapRect.Right;
  MWindow.MapWindow.Alignment.BottomOffset := MWindow.FMapRect.Bottom;
  MWindow.MapWindow.WinWidth := MWindow.FMapRect.Right;
  MWindow.MapWindow.WinHeight := MWindow.FMapRect.Bottom;
  MWindow.MapWindow.Alignment.AlignWidth := MWindow.FMapAlignWidth;
  MWindow.MapWindow.Alignment.AlignHeight := MWindow.FMapAlignHeight;
  MWindow.MapWindow.FAligned := False;
  TBWindow.TBWorld.Visible := False;
  TBWindow.TBCombat.Visible := True;
  TBWindow.TCCurPUpdate;
  TBWindow.AutoBtn.Checked := False;
  TBWindow.TCChatBtn.Visible := TBWindow.ChatBtn.Visible;
  TBWindow.TCUnitBtn.Visible := False;
  TBWindow.TaskWindow.FDrawn := False;
  TCScanner.TCScannerWin.Visible := AoWCombatMap.FPlaySounds;
  TBWindow.TCScannerBtn.Visible := AoWCombatMap.FPlaySounds;
  TCUnit.TCUnitWin.Visible := False;
  if not AoWCombatMap.FPlaySounds then
  begin
    FChatHeight := ChatWindow.ChatWin.WinHeight;
    ChatWindow.ChatWin.Alignment.AlignHeight := ahBoth;
  end
  else FChatHeight := 0;
  if General.FChatVisible or not AoWCombatMap.FPlaySounds then
    ChatWindow.ChatWin.Visible := True;
end;

procedure TTCMapEvents.TCMapDeActivateMap;
begin
  StopSong;
  SongPlayer.Resume;
  MWindow.MapViewer.HSMap := AoWHSMap;
  SWindow.Scanner.SetMap(AoWHSMap);
  with SWindow do
  begin
    Scanner.FPreviousWidth := 0;
    Scanner.FIncremental := False;
    Scanner.FSized := False;
    Scanner.FUpdateStep := -1;
  end;
  if FChatHeight > 0 then ChatWindow.ChatWin.WinHeight := FChatHeight;
  with ChatWindow do
  begin
    ChatWin.Alignment.AlignHeight := ahBottom;
    ChatWin.Visible := False;
  end;
  ChatWindow.FScrollPending := True;
  MWindow.FMapAlignWidth := MWindow.MapWindow.Alignment.AlignWidth;
  MWindow.FMapAlignHeight := MWindow.MapWindow.Alignment.AlignHeight;
  MWindow.FMapRect.Left := MWindow.MapWindow.Alignment.LeftOffset;
  MWindow.FMapRect.Top := MWindow.MapWindow.Alignment.TopOffset;
  if MWindow.FMapAlignWidth = awBoth then
    MWindow.FMapRect.Right := MWindow.MapWindow.Alignment.RightOffset
  else MWindow.FMapRect.Right := MWindow.MapWindow.WinWidth;
  if MWindow.FMapAlignHeight = ahBoth then
    MWindow.FMapRect.Bottom := MWindow.MapWindow.Alignment.BottomOffset
  else MWindow.FMapRect.Bottom := MWindow.MapWindow.WinHeight;
  MWindow.MapWindow.Alignment.LeftOffset := MWindow.FWorldRect.Left;
  MWindow.MapWindow.Alignment.TopOffset := MWindow.FWorldRect.Top;
  MWindow.MapWindow.Alignment.RightOffset := MWindow.FWorldRect.Right;
  MWindow.MapWindow.Alignment.BottomOffset := MWindow.FWorldRect.Bottom;
  MWindow.MapWindow.WinWidth := MWindow.FWorldRect.Right;
  MWindow.MapWindow.WinHeight := MWindow.FWorldRect.Bottom;
  MWindow.MapWindow.Alignment.AlignWidth := MWindow.FWorldAlignWidth;
  MWindow.MapWindow.Alignment.AlignHeight := MWindow.FWorldAlignHeight;
  RestoreGameWindows(General);
  General.Manager.FAligned := False;
  TBWindow.TBWorld.Visible := True;
  TBWindow.TBCombat.Visible := False;
  TBWindow.TurnButton.FButtonChecked := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSingleProcessCycle;
  TCScanner.TCScannerWin.Visible := False;
  TCUnit.TCUnitWin.Visible := False;
  TCScanner.Scanner.SetMap(nil);
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

procedure TTCMapEvents.TCMapSelected(HS: THexagonSprite);
begin
  if HS is TTacticalCombatUnitHS then
  begin
    General.FCombatUnit := TTacticalCombatUnitHS(HS);
    RefreshCombatUnit(TCUnit);
  end;
end;

procedure TTCMapEvents.TCMapShowMessage(const Info: TShowMessageInfo);
begin
  TBWindow.TCMsg.TextColor := Info.Color;
  TBWindow.TCMsg.Text := Info.Text;
end;

procedure TTCMapEvents.TCMapUnitChanged(HS: TTacticalCombatUnitHS);
begin
  if (HS = General.FCombatUnit) and (HS <> nil) then RefreshCombatUnit(TCUnit);
end;

procedure TTCMapEvents.TCMapCastSpell(Caster: TCombatSpellCaster);
begin
  TCUnit.UAbilLB.Selected := General.FCombatUnit.SelectSpell(Caster.FCombatCasterSpellID);
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
  TBWindow.TCPInd.FDrawn := False;
end;

end.
