unit AoWWinMan;

{ Draft declarations of AoWWinMan, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AoWWindow, AoWTC, AOWToolTip, AOWWinManager;

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
    F_General_4C: array[0..27] of Byte;
    FUnitShowInfo: TP2UnitShowInfo; { $68; 0044A1E5 }
    { $69..$73 are part of FUnitShowInfo. }
    FReserved74: Integer; { $74 }
    FAbilities: TList; { $78 }
    FActiveAbilityCount: Integer; { $7C } F_General_80: Integer;
    FSelectedUnits: array[0..7] of Integer; { $84 }
    FUnitList: TUnitList; { $A4 }
    F_General_A8: array[0..23] of Byte;
    FSelectedUnit: TAbstractUnit; { $C0; 00449DCD }
    { conflict: FUnit: TAbstractUnit; }
    FCombatUnit: TTacticalCombatUnitHS; { $C4 }
    F_General_C8: array[0..3] of Byte;
    procedure PlayButtonSound(Kind: Byte); { draft; 00455DFC }
    { conflict: procedure ButtonSound(Index: Byte); }
    procedure SortLists(var Lists: TList; Order: Byte); { draft; 00455744 }
    procedure RegisterDialog(Window: TAOWWindow); { draft; 00456AAC }
    procedure UnregisterDialog(Window: TAOWWindow); { draft; 00456B34 }
    function IndexOfUnit(U: TAbstractUnit): Integer;
    procedure BuildAbilities; { 00455D10 }
    function MTtoInt(MoveTypes: TMoveTypes): Integer;
    function SphereToImage(Sphere: TMagicSphere): Integer;
    procedure ManagerChangeCursor;  { draft }
    procedure GeneralCreate;  { draft }
    procedure GeneralDestroy;  { draft }
    procedure ResetLayout;  { draft }
    procedure ManagerDebugMessage(A1: Integer; A2: Integer);  { draft }
    procedure MapProgress(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ManagerKeyDown(A1: Integer; A2: Integer);  { draft }
    procedure ManagerUpdate;  { draft }
  end;


var
  General: TGeneral;

implementation

uses E3Globals, AoWListBox;

procedure TGeneral.PlayButtonSound(Kind: Byte);
begin
  case Kind of
    0: PlaySample('Sfx\Int\Btn1.wav');
    1: PlaySample('Sfx\Int\Btn5.wav');
    2: PlaySample('Sfx\Int\Btn6.wav');
    3: PlaySample('Sfx\Int\Btn3.wav');
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
      if General.FSelectedUnit.FPlayer = AoWHSMap.FSeatedPlayer then
        if AoWHSSet.FAbilityControl.GetAbility(I).GetControlType(General.FSelectedUnit) * [acAction] = [acAction] then
        begin
          FAbilities.Insert(FActiveAbilityCount, A);
          Inc(FActiveAbilityCount);
        end
        else FAbilities.Add(A)
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
  with MWindow.MapWindow.Alignment do
    if (AlignWidth = awBoth) and (Window.Alignment.AlignWidth = awBoth) then
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
  if (MWindow.MapWindow.Alignment.AlignWidth = awBoth) and (Window.Alignment.AlignWidth = awBoth) and
    ((Window = ChatWindow.ChatWin) or not ChatWindow.ChatWin.Visible or (ChatWindow.ChatWin.Alignment.AlignWidth <> awBoth)) and
    ((Window = MagicWin.Dlg) or not MagicWin.Dlg.Visible or (MagicWin.Dlg.Alignment.AlignWidth <> awBoth)) and
    ((Window = RealmWin.Dlg) or not RealmWin.Dlg.Visible or (RealmWin.Dlg.Alignment.AlignWidth <> awBoth)) then
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
begin end;

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
  with RealmWin.Dlg do
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

procedure TGeneral.ManagerDebugMessage(A1: Integer; A2: Integer);
begin end;

procedure TGeneral.MapProgress(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TGeneral.ManagerKeyDown(A1: Integer; A2: Integer);
begin end;

procedure TGeneral.ManagerUpdate;
begin end;


end.
