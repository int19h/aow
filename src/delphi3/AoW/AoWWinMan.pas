unit AoWWinMan;

{ Draft declarations of AoWWinMan, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AoWWindow, AoWTC, City, PrdPlace, ExploreS, Sign, AOWToolTip, AOWWinManager;

type
  TGeneral = class;


  { TGeneral (instance size $CC, VMT 00453FC4).
    $68 preview settings; $78 abilities; $7C active ability count;
    $84 selected indices; $A4 unit list; $C0 selected unit; $C4 combat sprite. }
  TGeneral = class(TDataModule)
  public
    published
    Manager: TAOWWinManager; { +0044 }
    ToolTip: TAOWToolTip; { +0048 }
    public
    FWindowsHidden: Boolean; FReserved4D: array[0..10] of Byte; FInfoVisible, FRealmVisible, FMagicVisible, FReserved5B, FReserved5C, FUnitVisible, FScannerVisible, FControlVisible, FChatVisible, FMapVisible, FReserved62, FReserved63, FReserved64, FTargetVisible: Boolean; FReserved66: array[0..1] of Byte; { $4C..$67; 00455A34 }
    { conflict: FSavedWindowVisibility: array[0..15] of Boolean; }
    { conflict: FPInfoVisible, FControlVisible, FUnitVisible: Boolean; FReserved5B: array[0..1] of Byte; FRealmVisible, FScannerVisible, FInfoVisible, FChatVisible, FMapVisible: Boolean; FReserved62: array[0..2] of Byte; FMagicVisible: Boolean; }
    FUnitShowInfo: TP2UnitShowInfo; { $68; 0044A1E5 }
    { $69..$73 are part of FUnitShowInfo. }
    FReserved74: Integer; { $74 }
    FAbilities: TList; { $78 }
    FActiveAbilityCount: Integer; { $7C } F_General_80: Integer;
    FSelectedUnits: array[0..7] of Integer; { $84 }
    FUnitList: TArmy; { $A4 }
    FStructure: TStructure; { $A8; 00442354 } FPreviousStructure: TStructure; { $AC } FCity: TCity; { $B0 } FProductionPlace: TProductionPlace; { $B4 } FProductionControl: TProductionControl; { $B8; 004437FC } FSign: TSign; { $BC }
    FSelectedUnit: TAbstractUnit; { $C0; 00449DCD }
    { conflict: FUnit: TAbstractUnit; }
    FCombatUnit: TTacticalCombatUnitHS; { $C4 }
    F_General_C8: array[0..3] of Byte;
    procedure ReturnToTitle;
    procedure HideWindows;
    procedure ShowWindows;
    procedure HideTransientWindows;
    procedure SaveLayout;
    procedure PlayButtonSound(Kind: Byte); { draft; 00455DFC }
    { conflict: procedure ButtonSound(Index: Byte); }
    procedure SortLists(var Lists: TList; Order: Byte); { draft; 00455744 }
    procedure RegisterDialog(Window: TAOWWindow); { draft; 00456AAC }
    procedure UnregisterDialog(Window: TAOWWindow); { draft; 00456B34 }
    function IndexOfUnit(U: TAbstractUnit): Integer;
    procedure BuildAbilities; { 00455D10 }
    published function MTtoInt(MoveTypes: TMoveTypes): Integer; public
    function SphereToImage(Sphere: TMagicSphere): Integer;
    published procedure ManagerChangeCursor; public  { draft }
    published procedure GeneralCreate; public  { draft }
    published procedure GeneralDestroy; public  { draft }
    published procedure ResetLayout; public  { draft }
    published procedure ManagerDebugMessage(Text: string); public
    published procedure MapProgress(Sender: TEObject; const Message: string; Progression: Integer); public { 00454CA7 }
    { conflict: procedure MapProgress(Sender: TObject; const Text: string; Position: Integer); }
    published procedure ManagerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
    published procedure ManagerUpdate; public  { draft }
  end;


var
  General: TGeneral;

procedure LoadGame(Controller: TGeneral; Name: string);

procedure LoadCampaign(Controller: TGeneral; Name: string);

procedure StartGame(Controller: TGeneral);

implementation

uses AoWVideoDlg, E2Globals, AOWMWindow, AoWUnit, AoWRealm, aowSetupEvents, aowDPlayComp, E1Globals, E1Resources, E2CampaignSupport, E3Globals, AoWListBox, AoWUnitBanner, AoWInfoBanner, AOWDialogWin, AoWProgressDialog, AoWExeForms, E1GameFlow, E2GameFlow;

procedure TGeneral.PlayButtonSound(Kind: Byte);
begin
  case Kind of
    0: PlaySample('Sfx\Int\Btn1.wav');
    3: PlaySample('Sfx\Int\Btn3.wav');
    1: PlaySample('Sfx\Int\Btn5.wav');
    2: PlaySample('Sfx\Int\Btn6.wav');
  end;
end;

function TGeneral.IndexOfUnit(U: TAbstractUnit): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (FSelectedUnits[0] > -1) and (FUnitList <> nil) then
    for I := 0 to 7 do
      if (FSelectedUnits[I] > -1) and (I < FUnitList.Count) then
        if U = FUnitList.GetUnit(FSelectedUnits[I]) then Result := I;
end;

procedure TGeneral.BuildAbilities;
var
  I: Integer;
  A: TTCAbility;
begin
  FActiveAbilityCount := 0;
  for I := 0 to FAbilities.Count - 1 do TObject(FAbilities[I]).Free;
  FAbilities.Clear;
  for I := 0 to 169 do
    if FSelectedUnit.GetAbilityEnabled(I) then
    begin
      A := TTCAbility.Create;
      A.Ability := I;
      if (General.FSelectedUnit.FPlayer = AoWHSMap.FSeatedPlayer) and
        (AoWHSSet.FAbilityControl.GetAbility(I).GetControlType(General.FSelectedUnit) * [acAction] <> []) then
        begin
          FAbilities.Insert(FActiveAbilityCount, A);
          Inc(FActiveAbilityCount);
        end
      else FAbilities.Add(A);
    end;
end;

procedure TGeneral.SortLists(var Lists: TList; Order: Byte);
var
  L: TAOWListBox;
  I, J, InsertAt: Integer;
begin
  L := TAOWListBox(Lists[0]);
  for I := 1 to L.Items.Count - 1 do
  begin
    J := I - 1; InsertAt := -1;
    while J > -1 do
    begin
      case Order of
        0: if CompareStr(UpperCase(L.Items[I]), UpperCase(L.Items[J])) < 0 then InsertAt := J;
        1: if CompareStr(UpperCase(L.Items[I]), UpperCase(L.Items[J])) > 0 then InsertAt := J;
        2: try if StrToInt(L.Items[I]) > StrToInt(L.Items[J]) then InsertAt := J; except end;
        3: try if StrToInt(L.Items[I]) < StrToInt(L.Items[J]) then InsertAt := J; except end;
      end;
      Dec(J);
    end;
    if InsertAt > -1 then
      for J := 0 to Lists.Count - 1 do TAOWListBox(Lists[J]).Items.Move(I, InsertAt);
  end;
  for I := 0 to Lists.Count - 1 do
  begin
    L := TAOWListBox(Lists[I]); L.ListOffset := 0; L.Selected := -1; L.FSized := False;
  end;
  Lists.Free;
end;

procedure TGeneral.RegisterDialog(Window: TAOWWindow);
begin
  with MWindow.MapWindow do
    if (Alignment.AlignWidth = awBoth) and (Window.Alignment.AlignWidth = awBoth) then
    begin
      with MWindow.MapWindow do
      begin
        Alignment.BottomOffset := TBWindow.TaskWindow.WinHeight + Window.WinHeight;
        FAligned := False;
        if Visible then Window.Alignment.RightOffset := Alignment.RightOffset
        else Window.Alignment.RightOffset := 0;
      end;
      Window.FAligned := False;
    end;
end;

procedure TGeneral.UnregisterDialog(Window: TAOWWindow);
begin
  with MWindow.MapWindow do
  if (Alignment.AlignWidth = awBoth) and (Window.Alignment.AlignWidth = awBoth) and
    ((Window = ChatWindow.ChatWin) or not ChatWindow.ChatWin.Visible or (ChatWindow.ChatWin.Alignment.AlignWidth <> awBoth)) and
    ((Window = MagicWin.Dlg) or not MagicWin.Dlg.Visible or (MagicWin.Dlg.Alignment.AlignWidth <> awBoth)) and
    ((Window = AoWRealm.RealmWin.Dlg) or not AoWRealm.RealmWin.Dlg.Visible or (AoWRealm.RealmWin.Dlg.Alignment.AlignWidth <> awBoth)) then
  begin
    with MWindow.MapWindow do
    begin
      Alignment.BottomOffset := TBWindow.TaskWindow.WinHeight; FAligned := False;
      Window.Alignment.RightOffset := Alignment.RightOffset;
    end;
    Window.FAligned := False;
  end;
end;

function TGeneral.SphereToImage(Sphere: TMagicSphere): Integer;
begin
  case Sphere of
    msLife: Result := 27;
    msDeath: Result := 30;
    msEarth: Result := 33;
    msAir: Result := 36;
    msWater: Result := 39;
  else Result := 42;
  end;
end;

function TGeneral.MTtoInt(MoveTypes: TMoveTypes): Integer;
begin
  Result := 0;
  if MoveTypes * [mtForestry] = [mtForestry] then Result := 2;
  if MoveTypes * [mtMountaineering] = [mtMountaineering] then Result := 4;
  if MoveTypes * [mtSwimming] = [mtSwimming] then Result := 6;
  if MoveTypes * [mtWalking, mtSwimming] = [mtWalking, mtSwimming] then Result := 8;
  if MoveTypes * [mtSwimming, mtForestry] = [mtSwimming, mtForestry] then Result := 10;
  if MoveTypes * [mtSwimming, mtMountaineering] = [mtSwimming, mtMountaineering] then Result := 12;
  if MoveTypes * [mtForestry, mtMountaineering] = [mtForestry, mtMountaineering] then Result := 14;
  if MoveTypes * [mtSwimming, mtForestry, mtMountaineering] = [mtSwimming, mtForestry, mtMountaineering] then Result := 16;
  if MoveTypes * [mtFlying] = [mtFlying] then Result := 18;
end;

procedure TGeneral.ManagerChangeCursor;
begin
  SetMainCursor(MainForm, Manager.Cursor);
end;

procedure TGeneral.GeneralCreate;
begin
  FUnitShowInfo.Direction := 3;
  FUnitShowInfo.Overlays := [uoRank];
  FAbilities := TList.Create;
end;

procedure TGeneral.GeneralDestroy;
var
  I: Integer;
begin
  for I := 0 to FAbilities.Count - 1 do TObject(FAbilities[I]).Free;
  FAbilities.Free;
end;

procedure TGeneral.ResetLayout;
begin
  with SWindow.ScannerWindow do
  begin
    with Alignment do begin TopOffset := 0; RightOffset := 0; end;
    if General.Manager.WinHeight > 700 then
      WinHeight := (General.Manager.WinHeight - TBWindow.TaskWindow.WinHeight) div 3
    else
      WinHeight := (General.Manager.WinHeight - TBWindow.TaskWindow.WinHeight) div 2;
    WinWidth := (WinHeight * 200) div 216;
    if AoWHSMap <> nil then Visible := (AoWHSMap.FCombatMap = nil) and MWindow.MapWindow.Visible;
  end;
  with PInfoW.PInfoWin do
  begin
    with Alignment do begin BottomOffset := 0; RightOffset := 0; end;
    WinWidth := SWindow.ScannerWindow.WinWidth;
    WinHeight := SWindow.ScannerWindow.WinHeight;
    if AoWHSMap <> nil then Visible := (AoWHSMap.FCombatMap = nil) and MWindow.MapWindow.Visible;
  end;
  with ControlWin.ControlWindow do
  begin
    with Alignment do begin TopOffset := SWindow.ScannerWindow.WinHeight; RightOffset := 0; end;
    WinWidth := SWindow.ScannerWindow.WinWidth;
    WinHeight := SWindow.ScannerWindow.WinHeight;
    Visible := False;
  end;
  with IWindow.InfoWin do
  begin
    with Alignment do begin TopOffset := SWindow.ScannerWindow.WinHeight; RightOffset := 0; end;
    WinWidth := SWindow.ScannerWindow.WinWidth;
    WinHeight := SWindow.ScannerWindow.WinHeight;
    Visible := False;
  end;
  with TargetSelectionDlg.Dlg do
  begin
    with Alignment do begin TopOffset := SWindow.ScannerWindow.WinHeight; RightOffset := 0; end;
    WinWidth := SWindow.ScannerWindow.WinWidth;
    WinHeight := SWindow.ScannerWindow.WinHeight;
  end;
  with AoWRealm.RealmWin.Dlg do
  begin
    with Alignment do
    begin
      BottomOffset := TBWindow.TaskWindow.WinHeight;
      LeftOffset := 0; RightOffset := SWindow.ScannerWindow.WinWidth;
      AlignWidth := awBoth; AlignHeight := ahBottom;
    end;
    WinWidth := MinWidth; WinHeight := MinHeight; Visible := False;
  end;
  with MagicWin.Dlg do
  begin
    with Alignment do
    begin
      BottomOffset := TBWindow.TaskWindow.WinHeight;
      LeftOffset := 0; RightOffset := SWindow.ScannerWindow.WinWidth;
      AlignWidth := awBoth; AlignHeight := ahBottom;
    end;
    WinWidth := MinWidth; WinHeight := MinHeight; Visible := False;
  end;
  with UnitWindow.UnitWin do
  begin
    with Alignment do begin AlignWidth := awCenter; AlignHeight := ahCenter; end;
    WinWidth := MinWidth; WinHeight := MinHeight; Visible := False;
  end;
  with ChatWindow.ChatWin do
  begin
    with Alignment do
    begin
      BottomOffset := TBWindow.TaskWindow.WinHeight;
      LeftOffset := 0; RightOffset := SWindow.ScannerWindow.WinWidth;
      AlignWidth := awBoth; AlignHeight := ahBottom;
    end;
    WinWidth := MinWidth; WinHeight := MinHeight; Visible := False;
  end;
  with TCScanner.TCScannerWin do
  begin
    with Alignment do begin TopOffset := 0; RightOffset := 0; end;
    WinHeight := ((General.Manager.WinHeight - TBWindow.TaskWindow.WinHeight) * 170) div 432;
    WinWidth := (WinHeight * 150) div 170;
    if AoWHSMap <> nil then Visible := (AoWHSMap.FCombatMap <> nil) and MWindow.MapWindow.Visible;
  end;
  with TCUnit.TCUnitWin do
  begin
    with Alignment do begin BottomOffset := 0; RightOffset := 0; end;
    WinHeight := General.Manager.WinHeight - TBWindow.TaskWindow.WinHeight - TCScanner.TCScannerWin.WinHeight;
    WinWidth := TCScanner.TCScannerWin.WinWidth; Visible := False;
  end;
  with MWindow.MapWindow.Alignment do
  begin
    AlignHeight := ahBoth; AlignWidth := awBoth; TopOffset := 0; LeftOffset := 0;
  end;
  MWindow.FWorldAlignHeight := ahBoth; MWindow.FWorldAlignWidth := awBoth;
  MWindow.FWorldRect := Rect(0, 0, SWindow.ScannerWindow.WinWidth, TBWindow.TaskWindow.WinHeight);
  MWindow.FMapAlignHeight := ahBoth; MWindow.FMapAlignWidth := awBoth;
  MWindow.FMapRect := Rect(0, 0, TCScanner.TCScannerWin.WinWidth, TBWindow.TaskWindow.WinHeight);
  if AoWHSMap <> nil then
    if AoWHSMap.FCombatMap = nil then
      MWindow.MapWindow.Alignment.RightOffset := SWindow.ScannerWindow.WinWidth
    else
      MWindow.MapWindow.Alignment.RightOffset := TCScanner.TCScannerWin.WinWidth;
  MWindow.MapWindow.Alignment.BottomOffset := TBWindow.TaskWindow.WinHeight;
  if ChatWindow.ChatWin.Visible then RegisterDialog(ChatWindow.ChatWin);
  Manager.FAligned := False;
end;

procedure TGeneral.ManagerDebugMessage(Text: string);
begin
  DialogWin.AddDebugMessage(Text);
end;

procedure TGeneral.MapProgress(Sender: TEObject; const Message: string; Progression: Integer);
{ conflict: procedure TGeneral.MapProgress(Sender: TObject; const Text: string; Position: Integer); }
begin
  E2Globals.ProgressDialog.StatusLbl.Text := Message;
  E2Globals.ProgressDialog.Bar.Position := Progression;
  E2Globals.ProgressDialog.ProgDlg.FSurfaceValid := False;
  General.Manager.DrawSurface(AoWUnit.MainForm.Display.ActiveDC.GetSurface(1));
  AoWUnit.MainForm.Display.ActiveDC.BltSurface(AoWUnit.MainForm.Display.FSurfaceIndex);
end;

procedure TGeneral.ManagerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Player: TPlayer;
  S: string;
begin
  if AoWEngine.FDebug then
  begin
    if (AoWHSMap <> nil) and
      ((AoWHSMap.FPlayMode <> pmSimultaneous) or (AoWHSMap.FPlayers.FLocalPlayers.Count = 1)) and
      (Key in [Ord('1')..Ord('9')]) and (AoWCombatMap = nil) and
      (AoWHSMap.FPlayers.GetCount > Key - Ord('0')) and AoWEngine.FRegistry.GetDebugMode then
    begin
      Player := AoWHSMap.FPlayers.GetPlayers(Key - Ord('0'));
      if Player.FPlayerType = ptCPU5 then Player.FPlayerType := ptHuman
      else Inc(Player.FPlayerType);
      S := 'Player ' + IntToStr(Key - Ord('0')) + ' set to: ' + TranslateRStr(TPlayerTypeRStr[Ord(Player.FPlayerType)]);
      AoWHSMap.ShowMessage(S);
      AoWHSMap.FPlayers.Update;
      AoWHSMap.FRequestCombatType := AoWHSMap.FPlayers.FLocalHumanPlayers.Count > 1;
    end;
    case Key of
      VK_F11:
        begin
          S := ExtractFileDir(Application.ExeName);
          S := S + '\Scenario\Custom';
          SetCurrentDir(S);
          LoadGame(Self, 'Crap.hsm');
          StartGame(Self);
        end;
      VK_F12:
        begin
          S := ExtractFileDir(Application.ExeName);
          S := S + '\Scenario\Custom';
          SetCurrentDir(S);
          LoadGame(Self, 'demomap.hsm');
          StartGame(Self);
        end;
    end;
  end;
end;

procedure TGeneral.ManagerUpdate;
begin
  with UnitBanner do
    with BannerPopup do
      if FShowPending and not BannerPopup.Visible then
      begin
        BannerPopup.WinLeft := FMenuLeft;
        with BannerPopup do WinTop := FMenuTop;
        BannerPopup.Visible := True;
      end;
  with AoWInfoBanner.InfoBanner do
    with BannerPopup do
      if FShowPending and not BannerPopup.Visible then
      begin
        BannerPopup.WinLeft := FMenuLeft;
        with BannerPopup do WinTop := FMenuTop;
        BannerPopup.Visible := True;
      end;
  with MWindow do MapWindow.DoubleBuffered := Manager.FOverlayPriority > MapWindow.Priority;
  if AoWUnit.MainForm.FCursorChanged then Manager.AddDrawRect(AoWUnit.MainForm.FLastCursorRect, nil);
end;


procedure TGeneral.HideWindows;
var I: Integer;
begin
  if not FWindowsHidden then
  begin
    FWindowsHidden := True;
    FInfoVisible := PInfoW.PInfoWin.Visible;
    FRealmVisible := ControlWin.ControlWindow.Visible;
    FMagicVisible := UnitWindow.UnitWin.Visible;
    FUnitVisible := AoWRealm.RealmWin.Dlg.Visible;
    FTargetVisible := MagicWin.Dlg.Visible;
    FScannerVisible := SWindow.ScannerWindow.Visible;
    FControlVisible := IWindow.InfoWin.Visible;
    FChatVisible := ChatWindow.ChatWin.Visible;
    FMapVisible := MWindow.MapWindow.Visible;
    for I := 0 to General.Manager.FChildren.Count - 1 do
      if TAoWComponent(General.Manager.FChildren[I]) <> TBWindow.TaskWindow then
        TAoWComponent(General.Manager.FChildren[I]).Visible := False;
  end;
end;

procedure TGeneral.ShowWindows;
begin
  if FWindowsHidden then
  begin
    FWindowsHidden := False;
    PInfoW.PInfoWin.Visible := FInfoVisible;
    ControlWin.ControlWindow.Visible := FRealmVisible;
    UnitWindow.UnitWin.Visible := FMagicVisible;
    SWindow.ScannerWindow.Visible := FScannerVisible;
    IWindow.InfoWin.Visible := FControlVisible;
    MWindow.MapWindow.Visible := FMapVisible;
    AoWRealm.RealmWin.Dlg.Visible := FUnitVisible;
    MagicWin.Dlg.Visible := FTargetVisible;
    ChatWindow.ChatWin.Visible := FChatVisible;
  end;
end;

procedure TGeneral.HideTransientWindows;
var I: Integer; Window: TAOWWindow;
begin
  for I := 0 to Manager.FChildren.Count - 1 do
  begin
    Window := TAOWWindow(Manager.FChildren[I]);
    if (Window <> MWindow.MapWindow) and Window.Modal and Window.Visible then
      Window.Visible := False;
  end;
end;

procedure TGeneral.SaveLayout; { Read the saved rectangle through the window pointer cell. }
begin
      AoWEngine.FRegistry.SetRectangle(0, Rect(PInfoW.PInfoWin.Alignment.RightOffset, PInfoW.PInfoWin.Alignment.BottomOffset, PInfoW.PInfoWin.WinWidth, PInfoW.PInfoWin.WinHeight));
      AoWEngine.FRegistry.SetRectangle(1, Rect(ControlWin.ControlWindow.Alignment.RightOffset, ControlWin.ControlWindow.Alignment.TopOffset, ControlWin.ControlWindow.WinWidth, ControlWin.ControlWindow.WinHeight));
    if UnitWindow.UnitWin.Alignment.AlignWidth <> awCenter then AoWEngine.FRegistry.SetRectangle(2, Rect(UnitWindow.UnitWin.Alignment.LeftOffset, UnitWindow.UnitWin.Alignment.TopOffset, UnitWindow.UnitWin.WinWidth, UnitWindow.UnitWin.WinHeight))
    else AoWEngine.FRegistry.SetRectangle(2, Rect(0, 0, 0, 0));
    if AoWRealm.RealmWin.Dlg.Alignment.AlignWidth <> awBoth then AoWEngine.FRegistry.SetRectangle(5, Rect(AoWRealm.RealmWin.Dlg.Alignment.LeftOffset, AoWRealm.RealmWin.Dlg.Alignment.TopOffset, AoWRealm.RealmWin.Dlg.WinWidth, AoWRealm.RealmWin.Dlg.WinHeight))
    else AoWEngine.FRegistry.SetRectangle(5, Rect(0, 0, 0, 0));
    if MagicWin.Dlg.Alignment.AlignWidth <> awBoth then AoWEngine.FRegistry.SetRectangle(13, Rect(MagicWin.Dlg.Alignment.LeftOffset, MagicWin.Dlg.Alignment.TopOffset, MagicWin.Dlg.WinWidth, MagicWin.Dlg.WinHeight))
    else AoWEngine.FRegistry.SetRectangle(13, Rect(0, 0, 0, 0));
      AoWEngine.FRegistry.SetRectangle(6, Rect(SWindow.ScannerWindow.Alignment.RightOffset, SWindow.ScannerWindow.Alignment.TopOffset, SWindow.ScannerWindow.WinWidth, SWindow.ScannerWindow.WinHeight));
      AoWEngine.FRegistry.SetRectangle(7, Rect(IWindow.InfoWin.Alignment.RightOffset, IWindow.InfoWin.Alignment.TopOffset, IWindow.InfoWin.WinWidth, IWindow.InfoWin.WinHeight));
    if ChatWindow.ChatWin.Alignment.AlignWidth <> awBoth then AoWEngine.FRegistry.SetRectangle(8, Rect(ChatWindow.ChatWin.Alignment.LeftOffset, ChatWindow.ChatWin.Alignment.BottomOffset, ChatWindow.ChatWin.WinWidth, ChatWindow.ChatWin.WinHeight))
    else AoWEngine.FRegistry.SetRectangle(8, Rect(0, 0, 0, 0));
    if MWindow.MapWindow.Alignment.AlignWidth <> awBoth then AoWEngine.FRegistry.SetRectangle(9, Rect(MWindow.MapWindow.Alignment.LeftOffset, MWindow.MapWindow.Alignment.TopOffset, MWindow.MapWindow.WinWidth, MWindow.MapWindow.WinHeight))
    else AoWEngine.FRegistry.SetRectangle(9, Rect(0, 0, 0, 0));
      AoWEngine.FRegistry.SetRectangle(12, Rect(TCScanner.TCScannerWin.Alignment.RightOffset, TCScanner.TCScannerWin.Alignment.TopOffset, TCScanner.TCScannerWin.WinWidth, TCScanner.TCScannerWin.WinHeight));
      AoWEngine.FRegistry.SetRectangle(10, Rect(TCUnit.TCUnitWin.Alignment.RightOffset, TCUnit.TCUnitWin.Alignment.BottomOffset, TCUnit.TCUnitWin.WinWidth, TCUnit.TCUnitWin.WinHeight));
  if AOWMWindow.MWindow.FMapAlignWidth <> awBoth then AoWEngine.FRegistry.SetRectangle(11, Rect(TMWindow(Pointer(@MWindow)^).FMapRect.Left, TMWindow(Pointer(@MWindow)^).FMapRect.Top, TMWindow(Pointer(@MWindow)^).FMapRect.Right, TMWindow(Pointer(@MWindow)^).FMapRect.Bottom))
  else AoWEngine.FRegistry.SetRectangle(11, Rect(0, 0, 0, 0));

end;

















procedure TGeneral.ReturnToTitle;
begin
  AoWEngine.CloseHSM(nil); AoWEngine.CloseCampaign;
  SWindow.Scanner.SetMap(nil); TCScanner.Scanner.SetMap(nil);
  SongPlayer.Stop(False); SongPlayer.Songs.Clear;
  SetCurrentDir(AoWEngine.StartupDirectory);
  General.HideWindows;
  TBWindow.TaskWindow.Visible := False; TitleWindow.TitleWin.Visible := False;
  TitleScene.ResetScene; E2GameFlow.ShowTitleScene(TitleScene, True);
end;

procedure LoadGame(Controller: TGeneral; Name: string);
begin
  if AoWHSMap <> nil then AoWEngine.CloseHSM(nil);
  E2Globals.ProgressDialog.Title.Text := TranslateRStr(E1LoadingRStr) + ' ' + ExtractFileName(Name) + '...';
  E2Globals.ProgressDialog.StatusLbl.Text := '';
  E2Globals.ProgressDialog.Bar.Position := 0;
  E2Globals.ProgressDialog.Bar.Max := 100;
  E2Globals.ProgressDialog.ProgDlg.Visible := True;
  if not E2Globals.TitleScene.Window.Visible then General.Manager.OverlayPriority := 5000;
  SongPlayer.Stop(False);
  SongPlayer.Songs.Clear;
  FadeMusicVolume(0, 1);
  AoWEngine.LoadHSM(Name, False, Controller.MapProgress);
  if AoWEngine.FDemo and (AoWHSMap <> nil) and not AoWHSMap.FShowAllPlayers then Controller.ReturnToTitle;
  General.Manager.OverlayPriority := 0;
  E2Globals.ProgressDialog.ProgDlg.Visible := False;
end;

procedure LoadCampaign(Controller: TGeneral; Name: string);
begin
  if AoWHSMap <> nil then AoWEngine.CloseHSM(nil);
  AoWEngine.LoadCampaign(Name);
  if AoWEngine.FCampaign <> nil then
    if AoWEngine.FCampaign.FScenarioStarted then
    begin
      E2Globals.ProgressDialog.Title.Text := TranslateRStr(E1LoadingRStr) + ' ' + ExtractFileName(Name) + '...';
      E2Globals.ProgressDialog.StatusLbl.Text := '';
      E2Globals.ProgressDialog.Bar.Position := 0;
      E2Globals.ProgressDialog.Bar.Max := 100;
      E2Globals.ProgressDialog.ProgDlg.Visible := True;
      if not E2Globals.TitleScene.Window.Visible then General.Manager.OverlayPriority := 5000;
      SongPlayer.Stop(False);
      SongPlayer.Songs.Clear;
      FadeMusicVolume(0, 1);
      AoWEngine.LoadCampaignMap(Controller.MapProgress);
      General.Manager.OverlayPriority := 0;
      E2Globals.ProgressDialog.ProgDlg.Visible := False;
    end
    else
    begin
      E2Globals.TitleScene.HideScene;
      ShowCampaignMap(E1Globals.WorldMap);
    end;
end;

procedure StartGame(Controller: TGeneral);
var
  I: Integer;
begin
  Controller.FWindowsHidden := False;
  SongPlayer.Songs.Clear;
  if AoWHSMap.FGameSongs.Songs.Count <> 0 then
    SongPlayer.Songs.AddStrings(AoWHSMap.FGameSongs.Songs)
  else
  begin
    if AoWHSMap.FStartupSongs.Songs.Count <> 0 then
    begin
      for I := 0 to AoWHSMap.FStartupSongs.Songs.Count - 1 do
        if CompareText(AoWHSMap.FStartupSongs.SongNames[I], TranslateRStr(E1FileNotFoundRStr)) <> 0 then
          SongPlayer.Songs.Add(AoWHSMap.FStartupSongs.Songs[I]);
    end
    else SongPlayer.Songs.Add('Songs\Heartwoo.it');
  end;
  SongPlayer.Play(0);
  SetMusicVolume(AoWExeForms.SoundDlg.MusicVolume.Position);
  E1Globals.PopupWindows.OverViewsMenu.Items.Clear;
  E1Globals.PopupWindows.OverViewsMenu.Items.Add(TranslateRStr(E1BackgroundRStr));
  if AoWEngine.FCampaign <> nil then E1Globals.PopupWindows.OverViewsMenu.Items.Add(TranslateRStr(E1CampaignRStr));
  E2Globals.TitleScene.Window.Visible := False;
  E3Globals.TitleWindow.TitleWin.Visible := False;
  AoWExeForms.TBWindow.TaskWindow.Visible := True;
  E3Globals.MWindow.MapWindow.Visible := True;
  AoWExeForms.SWindow.ScannerWindow.Visible := True;
  E3Globals.MWindow.MapViewer.HSMap := AoWHSMap;
  AoWExeForms.SWindow.Scanner.SetMap(AoWHSMap);
  AoWExeForms.SWindow.Scanner.SetLevel(AoWHSMap.MapContainer.GetMapLevel(0));
  AoWExeForms.TBWindow.TurnButton.FButtonChecked := False;
  AoWExeForms.TBWindow.ChatBtn.Visible := SetupEvents.DPlay.Connected;
  General.Manager.FAligned := False;
  with AoWExeForms.SWindow.Scanner do
  begin
    FPreviousWidth := 0;
    FIncremental := False;
    FSized := False;
  end;
  AoWExeForms.SWindow.ScannerTab.Items.Clear;
  AoWExeForms.SWindow.ScannerTab.Items.Add(TranslateRStr(E1SurfaceRStr));
  if AoWHSMap.MapContainer.LevelCount > 1 then AoWExeForms.SWindow.ScannerTab.Items.Add(TranslateRStr(E1CavernsRStr));
  if AoWHSMap.MapContainer.LevelCount > 2 then AoWExeForms.SWindow.ScannerTab.Items.Add(TranslateRStr(E1DepthsRStr));
  AoWExeForms.SWindow.ScannerTab.Selected := 0;
  with AoWExeForms.SWindow.ScannerTab do FSized := False;
  AoWExeForms.SWindow.Scanner.SetTWidth(0);
  AoWExeForms.SWindow.Scanner.SetTHeight(0);
  AoWExeForms.SWindow.Scanner.SetTLeft(-1);
  AoWExeForms.SWindow.Scanner.SetTTop(-1);
  AoWExeForms.SWindow.Scanner.FUpdateStep := -1;
  AoWExeForms.SWindow.Scanner.SetMap(AoWHSMap);
  AoWExeForms.SWindow.Scanner.SetLevel(AoWHSMap.MapContainer.GetMapLevel(0));
  E3Globals.MWindow.MapViewer.HSMap := AoWHSMap;
  TMWindow(Pointer(@E3Globals.MWindow)^).MapViewer.SceneWidth := TMWindow(Pointer(@E3Globals.MWindow)^).MapWindow.WinWidth - 24;
  TMWindow(Pointer(@E3Globals.MWindow)^).MapViewer.SceneHeight := TMWindow(Pointer(@E3Globals.MWindow)^).MapWindow.WinHeight - 24;
  AoWHSMap.Activate;
  AoWExeForms.RealmWin.Dlg.Visible := False;
  E1Globals.MapEvents.TheMapArmyDeselected(nil);
  E1Globals.MapEvents.TheMapStructureDeselected(nil);
  AoWExeForms.TBWindow.CurPUpdate;
  AoWExeForms.PInfoW.UpdatePlayer;
  if msActivated in AoWHSMap.Status then
    with AoWExeForms.TBWindow.TurnButton do
      if AoWHSMap.FSeatedPlayer <> -1 then
      begin
        FLastPlayer := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FPlayerRace;
        if FLastPlayer = -1 then FLastPlayer := 12;
        FCurPlayer := FLastPlayer;
        FAnimationFrame := FCurPlayer * 7;
        AoWExeForms.TBWindow.CurP.Visible := AoWHSMap.FPlayMode = pmTurn;
      end
      else
      begin
        FCurPlayer := 12;
        FLastPlayer := FCurPlayer;
        FAnimationFrame := FCurPlayer * 7;
        AoWExeForms.TBWindow.CurP.Visible := False;
      end;
  AoWExeForms.TBWindow.FWorldClockDelay := 0;
  AoWExeForms.TBWindow.ChatBtn.ILIndexUp := 14;
  AoWExeForms.TBWindow.FChatFlash := 0;
  TVideoDialog(Pointer(@AoWExeForms.VideoDialog)^).SetSceneSize(TVideoDialog(Pointer(@AoWExeForms.VideoDialog)^).FDisplayWidth, TVideoDialog(Pointer(@AoWExeForms.VideoDialog)^).FDisplayHeight);
end;

end.
