program matchtest;

{ Host program for the byte-matching experiment: it only has to reference every class so that the
  linker keeps them (every method of a class with a VMT is kept once the class is used). Build with
  the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Classes,
  PropTable in 'PropTable.pas',
  EngineLists in 'EngineLists.pas';

var
  T: TPropertyTable;
  L: TIntegerList;
  LB: TByteList;
  LS: TShortIntList;
  LW: TWordList;
  LT: TBitList;
  M: TMemoryStream;
begin
  T := TPropertyTable.Create;
  M := TMemoryStream.Create;
  T.Add(1, 0);
  T.Add(200, 300);
  T.BackupSettings;
  T.Add(2, 4);
  T.RestoreSettings;
  T.SaveToStream(M);
  M.Position := 0;
  T.Clear;
  T.LoadFromStream(M);
  Writeln(T.FindOffset(200), ' ', T.PropertyExist(1));
  M.Free;
  T.Free;
  L := TIntegerList.Create;
  L.ItemString := '1,2,3';
  L.Insert(0, 5);
  L.Move(0, 1);
  L.Exchange(0, 1);
  L.Pack;
  L.Remove(2);
  L[5] := 7;
  L.Sort(nil);
  M := TMemoryStream.Create;
  L.SaveToStream(M);
  M.Position := 0;
  L.LoadFromStream(M);
  M.Free;
  Writeln(L.ItemString, L.First, L.Last, L.Expand.Count, L.RandomChanceItem(1), L.Compare(L));
  L.Free;
  LB := TByteList.Create;
  LB.ItemString := '1,2,3';
  LB.Insert(0, 5);
  LB.Move(0, 1);
  LB.Exchange(0, 1);
  LB.Pack;
  LB.Remove(2);
  LB[5] := 7;
  LB.Sort(nil);
  M := TMemoryStream.Create;
  LB.SaveToStream(M);
  M.Position := 0;
  LB.LoadFromStream(M);
  M.Free;
  Writeln(LB.ItemString, LB.First, LB.Last, LB.Expand.Count, LB.RandomChanceItem(1), LB.Compare(LB));
  LB.Free;
  LS := TShortIntList.Create;
  LS.Add(1);
  LS.Insert(0, 5);
  LS.Move(0, 1);
  LS.Exchange(0, 1);
  LS.Pack;
  LS.Remove(2);
  LS[5] := 7;
  LS.Sort(nil);
  M := TMemoryStream.Create;
  LS.SaveToStream(M);
  M.Position := 0;
  LS.LoadFromStream(M);
  M.Free;
  Writeln(LS.First, LS.Last, LS.Expand.Count, LS.RandomChanceItem(1), LS.Compare(LS));
  LS.Free;
  LW := TWordList.Create;
  LW.Add(1);
  LW.Insert(0, 5);
  LW.Move(0, 1);
  LW.Exchange(0, 1);
  LW.Pack;
  LW.Remove(2);
  LW[5] := 7;
  LW.Sort(nil);
  M := TMemoryStream.Create;
  LW.SaveToStream(M);
  M.Position := 0;
  LW.LoadFromStream(M);
  M.Free;
  Writeln(LW.First, LW.Last, LW.Expand.Count, LW.RandomChanceItem(1), LW.Compare(LW));
  LW.Free;
  LT := TBitList.Create;
  LT.ItemString := '1,2,3';
  LT.Insert(0, True);
  LT.Move(0, 1);
  LT.Exchange(0, 1);
  LT.Pack;
  LT.Remove(True);
  LT[5] := True;
  M := TMemoryStream.Create;
  LT.SaveToStream(M);
  M.Position := 0;
  LT.LoadFromStream(M);
  M.Free;
  Writeln(LT.ItemString, LT.First, LT.Last, LT.Expand.Count, LT.BitsSet, LT.BitsCleared, LT.Compare(LT));
  LT.Free;
end.
