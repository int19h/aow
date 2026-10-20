{ Group D: AoWDialogForm, AoWMemo, AOWInterfaceEditor, AoWHTMLMemo }
procedure HostD;
var
  DL: TDialog;
  ME: TAOWMemo;
  SL: TStringList;
  CE: TAOWComponentEditor;
  HM: TaowHTMLMemo;
begin
  DL := TDialog.Create(nil);
  DL.Draw(nil, nil);
  Dialog := DL;
  ME := TAOWMemo.Create(nil);
  SL := TStringList.Create;
  ME.SetFStrings(SL);
  ME.SetListOff(0);
  ME.SetVScroll(nil);
  ME.SetILFIndex(0);
  ME.SetILTIndex(0);
  ME.CurToReal;
  ME.RealToCur;
  ME.KeyStuff;
  AoWMemo.Register;
  TColorChange.Create.Free;
  CE := TAOWComponentEditor.Create(nil, nil);
  CE.Edit;
  AOWInterfaceEditor.Register;
  HM := TaowHTMLMemo.Create(nil);
  HM.SetAOWWindow(nil);
  HM.SetFStrings(nil);
  HM.SetVScroll(nil);
  HM.SetListOff(0);
  HM.SetFileName('');
  HM.LoadFont('');
  AoWHTMLMemo.Register;
  TChangeInfo.Create.Free;
end;
