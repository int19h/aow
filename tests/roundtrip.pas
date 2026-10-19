program roundtrip;

{ Load a save or map through the generated object model (AoWModel) and write it back; the written
  bytes must equal the original inflated data. Every difference points at a ReadWrite translation,
  a control style, or a storage stream detail that is still wrong.

  Usage: roundtrip <file.asg|hsm> [out.bin]
  Build: fpc -Mdelphi -Fu..\src\recovered -Fu..\src\model roundtrip.pas }

{$MODE DELPHI}{$H+}

uses
  SysUtils, Classes, Engine, EngineLists, AoWModel;

type
  TModelEngine = class(TEngine)
  public
    function CreateEObject(AClassID: Integer; AOwner: TEObject): TEObject; override;
  end;

function TModelEngine.CreateEObject(AClassID: Integer; AOwner: TEObject): TEObject;
var
  C: TEObjectClass;
begin
  C := ModelClassByID(AClassID);
  if C = nil then
    raise Exception.CreateFmt('no model class for class id %d', [AClassID]);
  Result := C.Create(AOwner);
end;

var
  Data: TCompressStream;
  Header: packed record
    Size: Integer;
    ID: array[0..3] of AnsiChar;
    Reserved: Integer;
    RootClassID: Integer;
  end;
  EngineObj: TModelEngine;
  Root: TEObject;
  Out: TMemoryStream;
  F: TFileStream;
  I, N, FirstDiff, Diffs: Integer;
  A, B: PByte;
begin
  if ParamCount < 1 then
  begin
    Writeln('usage: roundtrip <file.asg|hsm> [out.bin]');
    Halt(1);
  end;
  Data := TCompressStream.Create;
  Data.LoadFromFile(ParamStr(1));
  Data.Read(Header, SizeOf(Header));
  Data.Position := Header.Size;
  EngineObj := TModelEngine.Create(nil);
  Root := EngineObj.CreateEObject(Header.RootClassID, nil);
  Writeln('root: ', Root.ClassName, ' (class id ', Header.RootClassID, ')');
  EngineObj.ReadEObject(Data, Root);
  Writeln('read ', Data.Position, ' of ', Data.Size, ' bytes');

  Out := TMemoryStream.Create;
  Out.Write(Header, SizeOf(Header));
  EngineObj.WriteEObject(Out, Root);
  Writeln('wrote ', Out.Size, ' bytes (original ', Data.Size, ')');
  with StorageStats do
    Writeln('objects read ', ObjectsRead, ', written ', ObjectsWritten, '; children read ', ChildrenRead,
            ', written ', ChildrenWritten, ', skipped ', ChildrenSkipped);

  N := Data.Size;
  if Out.Size < N then N := Out.Size;
  A := Data.Memory; B := Out.Memory;
  FirstDiff := -1; Diffs := 0;
  for I := 0 to N - 1 do
    if A[I] <> B[I] then
    begin
      if FirstDiff < 0 then FirstDiff := I;
      Inc(Diffs);
    end;
  if (Diffs = 0) and (Out.Size = Data.Size) then
    Writeln('ROUND TRIP OK: byte-identical')
  else
  begin
    Writeln('differences: ', Diffs, ' bytes in the common ', N, ' bytes; first at offset ', FirstDiff);
    if FirstDiff >= 0 then
    begin
      Write('  original: ');
      for I := FirstDiff to FirstDiff + 15 do if I < Data.Size then Write(IntToHex(A[I], 2), ' ');
      Writeln;
      Write('  written : ');
      for I := FirstDiff to FirstDiff + 15 do if I < Out.Size then Write(IntToHex(B[I], 2), ' ');
      Writeln;
    end;
  end;
  if ParamCount >= 2 then
  begin
    F := TFileStream.Create(ParamStr(2), fmCreate);
    Out.Position := 0;
    F.CopyFrom(Out, Out.Size);
    F.Free;
  end;
  Out.Free;
  Root.Free;
  EngineObj.Free;
  Data.Free;
end.
