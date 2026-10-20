program matchtest;

{ Host program for the byte-matching of aowInt.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B "-U..\Dcpack;..\Gfxepack;..\Ilpack"
      -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  Graphics,
  Controls,
  Forms,
  GFXE,
  AoWComp in 'AoWComp.pas',
  AOWInterfaceImgLib in 'AOWInterfaceImgLib.pas',
  AoWWinControl in 'AoWWinControl.pas',
  AoWDialogForm in 'AoWDialogForm.pas',
  AOWWinManager in 'AOWWinManager.pas',
  AoWBaseWin in 'AoWBaseWin.pas',
  AoWWinGeneric in 'AoWWinGeneric.pas',
  AoWWindow in 'AoWWindow.pas',
  AOWToolTip in 'AOWToolTip.pas',
  AoWControl in 'AoWControl.pas',
  AoWVScroll in 'AoWVScroll.pas',
  AOWMenuBar in 'AOWMenuBar.pas',
  AOWMenu in 'AOWMenu.pas',
  AoWButton in 'AoWButton.pas',
  AoWCheckBox in 'AoWCheckBox.pas',
  AoWComboBox in 'AoWComboBox.pas',
  AoWEdit in 'AoWEdit.pas',
  AoWImage in 'AoWImage.pas',
  AoWLabel in 'AoWLabel.pas',
  AoWListBox in 'AoWListBox.pas',
  AoWTabPanel in 'AoWTabPanel.pas',
  AoWMemo in 'AoWMemo.pas',
  AOWInterfaceEditor in 'AOWInterfaceEditor.pas',
  AOWGauge in 'AOWGauge.pas',
  AoWFrame in 'AoWFrame.pas',
  AoWPanel in 'AoWPanel.pas',
  AoWHScroll in 'AoWHScroll.pas',
  AoWHTMLMemo in 'AoWHTMLMemo.pas',
  aowUserDrawBox in 'aowUserDrawBox.pas';

{ The core units: AoWComp, AOWInterfaceImgLib, AoWWinControl, AOWWinManager, AoWBaseWin,
  AoWWinGeneric, AOWToolTip, AoWControl }
procedure HostCore;
var
  C: TAoWComponent;
  AL: TAOWAlignment;
  IL: TInterfaceIL;
  WC: TAOWWindowControl;
  WM: TAOWWinManager;
  BW: TAOWBaseWindow;
  GW: TAOWGenericWindow;
  TT: TAOWToolTip;
  CT: TAOWControl;
  R: TRect;
  SD: TSurfaceDesc;
  S: TSurface;
  SL: TStringList;
begin
  C := TAoWComponent.Create(nil);
  AL := TAOWAlignment.Create;
  C.SetAlign(AL);
  TaowRect.Create.Free;
  IL := TInterfaceIL.Create(nil);
  IL := IL.CheckIL(0, 1, C);
  IL.DrawILF(0, R, SD);
  IL.DrawILT(0, R, SD);
  IL.DrawILI(0, R, SD);
  IL.DrawILLh(0, R, SD);
  IL.DrawILLv(0, R, SD);
  AOWInterfaceImgLib.Register;
  WC := TAOWWindowControl.Create(nil);
  WC.SetOverlap(True);
  WC.RadioChange(C);
  S := nil;
  WC.VerifyBackSurface(S);
  WM := TAOWWinManager.Create(nil);
  WM.SetILBIndex(0);
  WM.SetILFIndex(0);
  WM.SetOverPri(0);
  WM.SetCursor(0);
  AOWWinManager.Register;
  BW := TAOWBaseWindow.Create(nil);
  BW.SetILFIndex(0);
  BW.SetILTIndex(0);
  BW.SetManager(WM);
  GW := TAOWGenericWindow.Create(nil);
  GW.SetCursor(0);
  GW.SetBuffer(True);
  TT := TAOWToolTip.Create(nil);
  SL := TStringList.Create;
  TT.SetFStrings(SL);
  AOWToolTip.Register;
  CT := TAOWControl.Create(nil);
  CT.SetAOWWindow(BW);
  CT.SetToolStrings(SL);
end;

{$I hostA.inc}
{$I hostB.inc}
{$I hostC.inc}
{$I hostD.inc}

begin
  HostCore;
  HostA;
  HostB;
  HostC;
  HostD;
end.
