{ Group A: AoWWindow, AOWMenuBar, AOWMenu, AoWTabPanel, AoWPanel }
procedure HostA;
var
  MB: TAOWMenuBar;
  MN: TAOWMenu;
  TP: TAOWTabPanel;
  PN: TAOWPanel;
  WN: TAOWWindow;
  SL: TStringList;
begin
  WN := TAOWWindow.Create(nil);
  WN.Free;
  AoWWindow.Register;
  PN := TAOWPanel.Create(nil);
  PN.SetAOWWindow(nil);
  AoWPanel.Register;
  SL := TStringList.Create;
  TP := TAOWTabPanel.Create(nil);
  TP.SetFStrings(SL);
  TP.SetIndex(0);
  AoWTabPanel.Register;
  MN := TAOWMenu.Create(nil);
  MN.DetachMenu;
  MN.SetILTsIndex(0);
  MN.SetFStrings(SL);
  MN.SetITStrings(SL);
  MN.SetPopupOwner(MN);
  AOWMenu.Register;
  MB := TAOWMenuBar.Create(nil);
  SL := TStringList.Create;
  MB.SetFStrings(SL);
  AOWMenuBar.Register;
end;
