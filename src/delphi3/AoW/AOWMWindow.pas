unit AOWMWindow;

{ The map window of AoW.exe, including input forwarding, view synchronization and shortcuts.
  Layouts follow the original RTTI; named handlers and supporting routines are recovered
  from the executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWWindow, AoWComp;

type
  TMWindow = class;


  { TMWindow: size $70; $5C saved map rectangle, $6D/$6F saved alignment. VMT 00450C38. }
  TMWindow = class(TDataModule)
  public
    published
    MapWindow: TAOWWindow; { +0044 }
    MapViewer: THSMapViewer; { +0048 }
    public
    FWorldRect: TRect; { $4C }
    FMapRect: TRect; { $5C }
    { conflict: FCombatRect: TRect; }
    FWorldAlignWidth: TAOWAlignWidth; { $6C }
    FMapAlignWidth: AoWComp.TAOWAlignWidth; { $6D }
    { conflict: FCombatAlignWidth: TAOWAlignWidth; }
    FWorldAlignHeight: TAOWAlignHeight; { $6E }
    FMapAlignHeight: AoWComp.TAOWAlignHeight; { $6F }
    { conflict: FCombatAlignHeight: TAOWAlignHeight; }
    function InsideMap(X, Y: Integer): Boolean; { 00450DE8 }
    published procedure MWindowCreate; public
    published procedure MapWindowMouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure MapWindowMouseUp(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure MapWindowMouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer); public
    published procedure MapViewerSceneChanged; public
    published procedure MapWindowResize; public
    published procedure MapWindowExit(Sender: TObject); public
    published procedure MapWindowUpdate; public
    published procedure MapWindowPreDrawSurface(Sender: TObject; Surface: TSurface; X, Y: Integer); public
    published procedure MapWindowKeyDown(Sender: TAoWComponent; var Key: Word; Shift: TShiftState); public
  end;


var
  MWindow: TMWindow;

implementation

uses AoWE, AoWTC, AoWExeForms, AoWWinMan, AoWUnit, AoWFileDialog;

procedure TMWindow.MWindowCreate;
begin
  MapWindow.ILFrame := IntGfxMod.GenericF;
  MapWindow.WinManager := General.Manager;
  FMapAlignWidth := awBoth;
  FMapAlignHeight := ahBoth;
end;

function TMWindow.InsideMap(X, Y: Integer): Boolean;
begin
  with MapWindow do
    Result := (X > WinLeft + 12) and (X < WinLeft + WinWidth - 12) and
      (Y > WinTop + 12) and (Y < WinTop + WinHeight - 12);
end;

procedure TMWindow.MapWindowMouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if InsideMap(X, Y) then
    AoWHSMap.Mouse.Down(Button, Shift, X - 12 - MapWindow.WinLeft, Y - 12 - MapWindow.WinTop);
end;

procedure TMWindow.MapWindowMouseUp(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if InsideMap(X, Y) then
    begin X := X - 12 - MapWindow.WinLeft; with MapWindow do AoWHSMap.Mouse.Up(Button, Shift, X, Y - 12 - WinTop); end
  else
    AoWHSMap.Mouse.Up(Button, Shift, -1, -1);
end;

procedure TMWindow.MapWindowMouseMove(Sender: TAoWComponent; Shift: TShiftState; X, Y: Integer); { Tried coordinate identity assignments; no exact match. }
begin
  with MapWindow do
    if (X > WinLeft + 11) and (X < MapWindow.WinLeft + WinWidth - 11) and
      (Y > WinTop + 11) and (Y < WinTop + WinHeight - 11) then
    begin
      AoWHSMap.Mouse.Move(Shift, X - 12 - MapWindow.WinLeft, Y - 12 - WinTop);
      MapWindow.Cursor := 9999;
    end;
end;

procedure TMWindow.MapViewerSceneChanged; { Tried scanner-first comparison; no exact match. }
begin
  if AoWHSMap.FSeatedPlayer <> -1 then
  begin
    SWindow.Scanner.SetTWidth(MWindow.MapViewer.SceneWidth div 32);
    SWindow.Scanner.SetTHeight(MWindow.MapViewer.SceneHeight div 32);
    SWindow.Scanner.SetTLeft(MapViewer.SceneX div 32 - 6);
    SWindow.Scanner.SetTTop(MapViewer.SceneY div 32 - 6);
    TCScanner.Scanner.SetTWidth(MWindow.MapViewer.SceneWidth div 32);
    TCScanner.Scanner.SetTHeight(MWindow.MapViewer.SceneHeight div 32);
    TCScanner.Scanner.SetTLeft(MWindow.MapViewer.SceneX div 32 - 6);
    TCScanner.Scanner.SetTTop(MWindow.MapViewer.SceneY div 32 - 6);
  end;
  if AoWHSMap.FCombatMap = nil then
    if AoWHSMap.MapContainer.GetMapLevel(MapViewer.SceneL) <> SWindow.Scanner.FLevel then
    begin
      with SWindow.Scanner do
      begin
        FUpdateStep := -1;
        SetLevel(AoWHSMap.MapContainer.GetMapLevel(MapViewer.SceneL));
      end;
      SWindow.ScannerTab.SetIndex(MapViewer.SceneL);
    end;
  if AoWHSMap.FCombatMap <> nil then
    with AoWHSMap.FCombatMap.Mouse do Move([], X, Y)
  else
    with AoWHSMap.Mouse do Move([], X, Y);
end;

procedure TMWindow.MapWindowResize;
begin
  with MapWindow do

    begin
      Alignment.LeftOffset := WinLeft;
      Alignment.TopOffset := WinTop;
      Alignment.AlignWidth := awLeft;
      Alignment.AlignHeight := ahTop;
    end;
  MapViewer.SceneWidth := MapWindow.WinWidth - 24;
  MapViewer.SceneHeight := MapWindow.WinHeight - 24;
end;

procedure TMWindow.MapWindowExit(Sender: TObject);
begin
  if AoWHSMap <> nil then AoWHSMap.Mouse.Move([], -1, -1);
end;

procedure TMWindow.MapWindowUpdate;
begin
  if AoWHSMap <> nil then
  begin
    AoWHSMap.UpdateFPS(MainForm.Display.CurrentFrameRate);
    with MapWindow do FDrawn := FDrawn and FDoubleBuffered;
  end;
end;

procedure TMWindow.MapWindowPreDrawSurface(Sender: TObject; Surface: TSurface; X, Y: Integer);
begin
  if AoWHSMap <> nil then
  begin
    MapViewer.SceneWidth := MapWindow.WinWidth - 24;
    MapViewer.SceneHeight := MapWindow.WinHeight - 24;
    if MapWindow.DoubleBuffered then
      MapViewer.ShowScene(12, 12, MapWindow.FBackSurface)
    else
      MapViewer.ShowScene(X + 12, Y + 12, Surface);
  end;
end;

procedure TMWindow.MapWindowKeyDown(Sender: TAoWComponent; var Key: Word; Shift: TShiftState);
var
  K: Word;
begin
  if (AoWHSMap <> nil) and (AoWCombatMap = nil) then
    AoWHSMap.FKeyboard.KeyDown(Key, Shift);
  K := Key;
  case AoWEngine.FLanguage of
    4: case Key of
      65: if ssCtrl in Shift then K := 79;
      71: if ssCtrl in Shift then K := 83;
    end;
  end;
  if (MapViewer <> nil) and (AoWHSMap <> nil) then
    case K of
      VK_LEFT: begin
        MWindow.MapViewer.SceneX := MWindow.MapViewer.SceneX - 32;
        Sender.FHandled := True;
      end;
      VK_RIGHT: begin
        MWindow.MapViewer.SceneX := MWindow.MapViewer.SceneX + 32;
        Sender.FHandled := True;
      end;
      VK_UP: begin
        MWindow.MapViewer.SceneY := MWindow.MapViewer.SceneY - 32;
        Sender.FHandled := True;
      end;
      VK_DOWN: begin
        MWindow.MapViewer.SceneY := MWindow.MapViewer.SceneY + 32;
        Sender.FHandled := True;
      end;
      VK_PRIOR: MWindow.MapViewer.SceneL := MWindow.MapViewer.SceneL - 1;
      VK_NEXT: MWindow.MapViewer.SceneL := MWindow.MapViewer.SceneL + 1;
      77: begin
        if AoWCombatMap <> nil then AoWCombatMap.FUnitSelection.MoveUnits;
        Sender.FHandled := True;
      end;
      78: begin
        if AoWCombatMap <> nil then AoWCombatMap.SelectNextUnit(True);
        Sender.FHandled := True;
      end;
      80: begin
        if AoWCombatMap <> nil then AoWCombatMap.SelectNextUnit(False);
        Sender.FHandled := True;
      end;
      69, VK_RETURN:
        if (ssCtrl in Shift) and (AoWCombatMap <> nil) then
        begin
          AoWCombatMap.EndTurn(False);
          Sender.FHandled := True;
        end;
      79, VK_F3:
        if (AoWCombatMap = nil) and ((K = VK_F3) or (ssCtrl in Shift)) then
        begin
          FileDlgWindow.FMode := 0;
          FileDlgWindow.FileDialog.Visible := True;
        end;
      83, VK_F4:
        if (AoWCombatMap = nil) and ((K = VK_F4) or (ssCtrl in Shift)) then
        begin
          FileDlgWindow.FMode := 1;
          FileDlgWindow.FileDialog.Visible := True;
        end;
      VK_F5:
        if AoWCombatMap <> nil then AoWCombatMap.FShowGrid := not AoWCombatMap.FShowGrid
        else AoWHSMap.FShowGrid := not AoWHSMap.FShowGrid;
      VK_F6:
        if AoWEngine.FDebug and (AoWHSMap.FConnectionType <> pcNetwork) then
          if AoWCombatMap <> nil then
          begin
            AoWCombatMap.SetFogEnabled(not AoWCombatMap.FFogEnabled);
            if AoWCombatMap.FFogEnabled then AoWCombatMap.ShowMessage('Fog Enabled')
            else AoWCombatMap.ShowMessage('Fog Disabled');
          end
          else if AoWHSMap <> nil then
          begin
            AoWHSMap.SetFogEnabled(not AoWHSMap.FFogEnabled);
            if AoWHSMap.FFogEnabled then AoWHSMap.ShowMessage('Fog Enabled')
            else AoWHSMap.ShowMessage('Fog Disabled');
          end;
      VK_F7:
        if AoWEngine.FDebug and (AoWHSMap.FConnectionType <> pcNetwork) then
          if AoWCombatMap <> nil then
          begin
            AoWCombatMap.SetExplorationEnabled(not AoWCombatMap.FExplorationEnabled);
            if AoWCombatMap.FExplorationEnabled then AoWCombatMap.ShowMessage('Exploration Enabled')
            else AoWCombatMap.ShowMessage('ExplorationEnabled'); { Original text omits the space. }
          end
          else if AoWHSMap <> nil then
          begin
            AoWHSMap.SetExplorationEnabled(not AoWHSMap.FExplorationEnabled);
            if AoWHSMap.FExplorationEnabled then AoWHSMap.ShowMessage('Exploration Enabled')
            else AoWHSMap.ShowMessage('Exploration Disabled');
          end;
      VK_F8:
        if not AoWEngine.FDemo and AoWEngine.FRegistry.GetDeveloper then
          if AoWHSMap.FCombatMap <> nil then AoWCombatMap.EndCombat(Self);
    end;
end;

end.
