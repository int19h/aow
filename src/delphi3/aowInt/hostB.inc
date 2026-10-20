{ Group B: AoWVScroll, AoWComboBox, AoWListBox, AoWHScroll }
procedure HostB;
var
  SB: TAOWScrollBar;
  VS: TAOWVScrollBar;
  CB: TAOWComboBox;
  SL: TStringList;
  LB: TAOWListBox;
begin
  SB := TAOWScrollBar.Create(nil);
  SB.SetSmall(1);
  SB.SetLarge(1);
  SB.SetFMin(0);
  SB.SetFMax(1);
  SB.SetFNum(1);
  SB.SetFPos(0);
  VS := TAOWVScrollBar.Create(nil);
  VS.Free;
  AoWVScroll.Register;
  CB := TAOWComboBox.Create(nil);
  SL := TStringList.Create;
  CB.SetFStrings(SL);
  CB.SetVScroll(VS);
  AoWComboBox.Register;
  LB := TAOWListBox.Create(nil);
  LB.SetFStrings(SL);
  LB.SetIndex(0);
  LB.SetListOff(0);
  LB.SetVScroll(VS);
  LB.SetILFIndex(0);
  LB.SetILTnIndex(0);
  LB.SetILTsIndex(0);
  AoWListBox.Register;
  TAOWHScrollBar.Create(nil).Free;
  AoWHScroll.Register;
end;
