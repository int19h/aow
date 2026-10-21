unit aowMapEvents;

{ Draft declarations of aowMapEvents, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, MapCtrl, AoWE;

type
  TMapEvents = class;


  { TMapEvents (instance size $48, VMT 0044E554); $44 map control. }
  TMapEvents = class(TDataModule)
  public
    published
    TheMap: TAoWMapControl; { +0044 }
    public
    procedure TheMapActivateAbility(A1: Integer);  { draft }
    procedure TheMapArmyChanged(A1: Integer);  { draft }
    procedure TheMapArmyDeselected;
    procedure TheMapArmyDestroyed(Army: TArmy);
    procedure TheMapArmySelected(A1: Integer; A2: Integer);  { draft }
    procedure TheMapDayChanged(A1: Integer);  { draft }
    procedure TheMapDeactivateHSM;  { draft }
    procedure TheMapEndTurn(A1: Byte; A2: Integer);  { draft }
    procedure TheMapExecuteEventLog(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure TheMapGameOver;  { draft }
    procedure TheMapGemsChanged(Player: Shortint);
    procedure TheMapGlobalMagicChanged;  { draft }
    procedure TheMapIncomeChanged(Player: Shortint);
    procedure TheMapMapChanged(var Info: TMapChangedInfo);
    procedure TheMapScannerIconsChanged(var Info: TMapChangedInfo);
    procedure TheMapPlayerMagicChanged(A1: Integer);  { draft }
    procedure TheMapSeatedPlayerChanged(A1: Integer);  { draft }
    procedure TheMapShowMessage(var Info: TShowMessageInfo);
    procedure TheMapStructureChanged(A1: Integer);  { draft }
    procedure TheMapStructureDeselected;  { draft }
    procedure TheMapStructureDestroyed(A1: Integer);  { draft }
    procedure TheMapStructureSelected(A1: Integer);  { draft }
    procedure TheMapItemsDeselected;  { draft }
    procedure TheMapItemsSelected;  { draft }
    procedure TheMapTargetSelectionChange;  { draft }
    procedure TheMapUnitChanged(A1: Integer);  { draft }
    procedure TheMapCastSpell(A1: Integer);  { draft }
    procedure TheMapHSChanged(A1: Integer);  { draft }
    procedure TheMapRelationsChanged;  { draft }
    procedure TheMapDiplomaticChange;  { draft }
    procedure TheMapStructureDblClick(A1: Integer);  { draft }
  end;


implementation

uses E3Globals, AoWWinMan, AoWUnitBanner;

procedure TMapEvents.TheMapActivateAbility(A1: Integer);
begin end;

procedure TMapEvents.TheMapArmyChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapArmyDeselected;
begin
  General.FAbilities.Clear;
  General.FUnitList := nil;
  ControlWin.MovesLbl.Text := '';
  ControlWin.MoveIcon.Visible := False;
  ControlWin.Emp1Fr.Visible := True;
  ControlWin.Emp1Chk.Visible := True;
  ControlWin.Emp2Fr.Visible := True;
  ControlWin.Emp2Chk.Visible := True;
  ControlWin.Emp3Fr.Visible := True;
  ControlWin.Emp3Chk.Visible := True;
  ControlWin.Emp4Fr.Visible := True;
  ControlWin.Emp4Chk.Visible := True;
  ControlWin.Emp5Fr.Visible := True;
  ControlWin.Emp5Chk.Visible := True;
  ControlWin.Emp6Fr.Visible := True;
  ControlWin.Emp6Chk.Visible := True;
  ControlWin.Emp7Fr.Visible := True;
  ControlWin.Emp7Chk.Visible := True;
  ControlWin.Emp8Fr.Visible := True;
  ControlWin.Emp8Chk.Visible := True;
  ControlWin.ControlWindow.Visible := False;
  TBWindow.ConButton.Visible := False;
  if UnitWindow.UnitWin.Visible then UnitWindow.UnitWin.Visible := False;
end;

procedure TMapEvents.TheMapArmyDestroyed(Army: TArmy);
begin
  if (Army <> nil) and (Army = General.FUnitList) then TheMapArmyDeselected;
  if RealmWin.Dlg.Visible and (RealmWin.HeaderTab.Selected = 3) then RealmWin.UpdateOverview;
end;

procedure TMapEvents.TheMapArmySelected(A1: Integer; A2: Integer);
begin end;

procedure TMapEvents.TheMapDayChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapDeactivateHSM;
begin end;

procedure TMapEvents.TheMapEndTurn(A1: Byte; A2: Integer);
begin end;

procedure TMapEvents.TheMapExecuteEventLog(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMapEvents.TheMapGameOver;
begin end;

procedure TMapEvents.TheMapGemsChanged(Player: Shortint);
var
  Update: Boolean;
begin
  Update := False;
  if AoWHSMap.FSeatedPlayer = Player then Update := True
  else if AoWHSMap.FCombatMap <> nil then
    if AoWHSMap.FCombatMap.FSeatedPlayer = Player then Update := True;
  if Update then
  begin
    if Player = -1 then Update := False
    else if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then Update := False;
    if not Update then
    begin
      { The original clears both income signs when the gold display is cleared. }
      TBWindow.WGTLbl.Text := '';
      TBWindow.WGSign.Text := '';
      TBWindow.WMTSign.Text := '';
    end
    else
    begin
      TBWindow.WGTLbl.Text := IntToStr(AoWHSMap.FPlayers.GetPlayers(Player).FGems);
      if RealmWin.Dlg.Visible and (RealmWin.HeaderTab.Selected = 0) then RealmWin.UpdateOverview;
    end;
    TBWindow.TGTLbl.Text := TBWindow.WGTLbl.Text;
    TBWindow.TGSign.Text := TBWindow.WGSign.Text;
    TBWindow.TMTSign.Text := TBWindow.WMTSign.Text;
  end;
end;

procedure TMapEvents.TheMapGlobalMagicChanged;
begin end;

procedure TMapEvents.TheMapIncomeChanged(Player: Shortint);
var
  Update: Boolean;
  NetIncome: Integer;
begin
  Update := False;
  if AoWHSMap.FSeatedPlayer = Player then Update := True
  else if AoWHSMap.FCombatMap <> nil then
    if AoWHSMap.FCombatMap.FSeatedPlayer = Player then Update := True;
  if Update then
  begin
    if Player = -1 then Update := False
    else if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then Update := False;
    if not Update then TBWindow.WGILbl.Text := ''
    else
    begin
      NetIncome := AoWHSMap.FPlayers.GetPlayers(Player).FIncome - AoWHSMap.FPlayers.GetPlayers(Player).GetUpkeep;
      if NetIncome >= 0 then
      begin
        TBWindow.WGSign.Text := '+';
        TBWindow.WGSign.TextColor := $77FF77;
        TBWindow.WGILbl.TextColor := $77FF77;
      end
      else
      begin
        TBWindow.WGSign.Text := '-';
        TBWindow.WGSign.TextColor := $77;
        TBWindow.WGILbl.TextColor := $77;
      end;
      TBWindow.WGILbl.Text := IntToStr(Abs(NetIncome));
      if RealmWin.Dlg.Visible and (RealmWin.HeaderTab.Selected = 0) then RealmWin.UpdateOverview;
    end;
    TBWindow.TGILbl.Text := TBWindow.WGILbl.Text;
    TBWindow.TGSign.Text := TBWindow.WGSign.Text;
    TBWindow.TGSign.TextColor := TBWindow.WGSign.TextColor;
    TBWindow.TGILbl.TextColor := TBWindow.WGILbl.TextColor;
  end;
end;

procedure TMapEvents.TheMapMapChanged(var Info: TMapChangedInfo);
begin
  if Info.MapLevel = SWindow.Scanner.FLevel then
    SWindow.Scanner.DrawMap(Info.Bounds.Left - 6, Info.Bounds.Top - 6,
      Info.Bounds.Right - Info.Bounds.Left,
      Info.Bounds.Bottom - Info.Bounds.Top);
end;

procedure TMapEvents.TheMapScannerIconsChanged(var Info: TMapChangedInfo);
begin
  if Info.MapLevel = SWindow.Scanner.FLevel then SWindow.Scanner.SetObDrawn(False);
end;

procedure TMapEvents.TheMapPlayerMagicChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapSeatedPlayerChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapShowMessage(var Info: TShowMessageInfo);
begin
  TBWindow.TBMessEdit.TextColor := Info.Color;
  TBWindow.TBMessEdit.Text := Info.Text;
end;

procedure TMapEvents.TheMapStructureChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapStructureDeselected;
begin end;

procedure TMapEvents.TheMapStructureDestroyed(A1: Integer);
begin end;

procedure TMapEvents.TheMapStructureSelected(A1: Integer);
begin end;

procedure TMapEvents.TheMapItemsDeselected;
begin end;

procedure TMapEvents.TheMapItemsSelected;
begin end;

procedure TMapEvents.TheMapTargetSelectionChange;
begin end;

procedure TMapEvents.TheMapUnitChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapCastSpell(A1: Integer);
begin end;

procedure TMapEvents.TheMapHSChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapRelationsChanged;
begin end;

procedure TMapEvents.TheMapDiplomaticChange;
begin end;

procedure TMapEvents.TheMapStructureDblClick(A1: Integer);
begin end;


end.
