program matchtest;

{ Host program for the byte-matching experiment: it only has to reference every method so that the
  linker keeps them. Build with the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -$O+ matchtest.dpr
  -GD writes matchtest.map with the address of every method. }

{$APPTYPE CONSOLE}

uses
  Classes,
  PropTable in 'PropTable.pas';

var
  T: TPropertyTable;
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
end.
