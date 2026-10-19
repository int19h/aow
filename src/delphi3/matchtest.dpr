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
end.
