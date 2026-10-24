unit E2WindowLayout;

{ The original window placement loader, 00455F58. }

interface

procedure RestoreWindowLayout(Controller: TObject);

implementation

uses AOWMWindow, Windows, Classes, AoWE, AoWComp, AoWExeForms;

procedure RestoreWindowLayout(Controller: TObject); { Tried addressable rectangle to force width reloads; no exact match. }
var
  R: TRect;
begin
  R := AoWEngine.FRegistry.GetRectangle(6);
  with SWindow.ScannerWindow do
    if R.Right <> 0 then
    begin
      Alignment.TopOffset := R.Top;
      Alignment.RightOffset := R.Left;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      Alignment.TopOffset := 0;
      Alignment.RightOffset := 0;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(0);
  with PInfoW.PInfoWin do
    if R.Right <> 0 then
    begin
      Alignment.BottomOffset := R.Top;
      Alignment.RightOffset := R.Left;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      Alignment.BottomOffset := 0;
      Alignment.RightOffset := 0;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(2);
  with UnitWindow.UnitWin do
    if R.Right <> 0 then
    begin
      with Alignment do
      begin
        AlignWidth := awLeft;
        AlignHeight := ahTop;
        TopOffset := R.Top;
        LeftOffset := R.Left;
      end;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      with Alignment do
      begin
        AlignWidth := awCenter;
        AlignHeight := ahCenter;
      end;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(3);
  R := AoWEngine.FRegistry.GetRectangle(4);
  R := AoWEngine.FRegistry.GetRectangle(5);
  with RealmWin.Dlg do
    if R.Right <> 0 then
    begin
      with Alignment do
      begin
        AlignWidth := awLeft;
        AlignHeight := ahTop;
        TopOffset := R.Top;
        LeftOffset := R.Left;
      end;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      with Alignment do BottomOffset := TBWindow.TaskWindow.WinHeight;
      with Alignment do
      begin
        LeftOffset := 0;
        RightOffset := SWindow.ScannerWindow.WinWidth;
        AlignWidth := awBoth;
        AlignHeight := ahBottom;
      end;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(13);
  with MagicWin.Dlg do
    if R.Right <> 0 then
    begin
      with Alignment do
      begin
        AlignWidth := awLeft;
        AlignHeight := ahTop;
        TopOffset := R.Top;
        LeftOffset := R.Left;
      end;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      with Alignment do BottomOffset := TBWindow.TaskWindow.WinHeight;
      with Alignment do
      begin
        LeftOffset := 0;
        RightOffset := SWindow.ScannerWindow.WinWidth;
        AlignWidth := awBoth;
        AlignHeight := ahBottom;
      end;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(1);
  with ControlWin.ControlWindow do
    if R.Right <> 0 then
    begin
      Alignment.TopOffset := R.Top;
      Alignment.RightOffset := R.Left;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      Alignment.TopOffset := SWindow.ScannerWindow.WinHeight;
      Alignment.RightOffset := 0;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(7);
  with IWindow.InfoWin do
    if R.Right <> 0 then
    begin
      Alignment.TopOffset := R.Top;
      Alignment.RightOffset := R.Left;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      Alignment.TopOffset := SWindow.ScannerWindow.WinHeight;
      Alignment.RightOffset := 0;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(8);
  with ChatWindow.ChatWin do
    if R.Right <> 0 then
    begin
      with Alignment do
      begin
        AlignWidth := awLeft;
        BottomOffset := R.Top;
        LeftOffset := R.Left;
      end;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      with Alignment do
      begin
        AlignWidth := awBoth;
        LeftOffset := 0;
        RightOffset := SWindow.ScannerWindow.MinWidth;
        BottomOffset := TBWindow.TaskWindow.WinHeight;
      end;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(12);
  with TCScanner.TCScannerWin do
    if R.Right <> 0 then
    begin
      Alignment.TopOffset := R.Top;
      Alignment.RightOffset := R.Left;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      Alignment.TopOffset := 0;
      Alignment.RightOffset := 0;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(10);
  with TCUnit.TCUnitWin do
    if R.Right <> 0 then
    begin
      Alignment.BottomOffset := R.Top;
      Alignment.RightOffset := R.Left;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      Alignment.BottomOffset := 0;
      Alignment.RightOffset := 0;
      WinWidth := MinWidth;
      WinHeight := MinHeight;
    end;
  R := AoWEngine.FRegistry.GetRectangle(11);
  if R.Right <> 0 then
    begin
    MWindow.FMapRect := R;
    MWindow.FMapAlignHeight := ahTop;
    MWindow.FMapAlignWidth := awLeft;
  end
    else
    begin
    MWindow.FMapAlignHeight := ahBoth;
    MWindow.FMapAlignWidth := awBoth;
    MWindow.FMapRect := Rect(0, 0, TCScanner.TCScannerWin.MinWidth, TBWindow.TaskWindow.WinHeight);
  end;
  R := AoWEngine.FRegistry.GetRectangle(9);
  with MWindow.MapWindow do
    if R.Right <> 0 then
    begin
      with Alignment do
      begin
        AlignHeight := ahTop;
        AlignWidth := awLeft;
        TopOffset := R.Top;
        LeftOffset := R.Left;
      end;
      WinWidth := R.Right;
      WinHeight := R.Bottom;
    end
    else
    begin
      with Alignment do
      begin
        AlignHeight := ahBoth;
        AlignWidth := awBoth;
        TopOffset := 0;
        LeftOffset := 0;
        RightOffset := SWindow.ScannerWindow.MinWidth;
        BottomOffset := TBWindow.TaskWindow.WinHeight;
      end;
    end;
end;


end.
