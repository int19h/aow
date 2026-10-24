program misc;

{ Host program for byte-matching the small units of Enginep.dpl (zlib, EList, PlugInM, DebMDlg): it
  only has to reference every class and call every non-virtual method so that smart linking keeps
  them. It is linked, never run. Build with the original compiler (-O names the directory that
  holds obj\, the zlib object files):
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -U<src\delphi3> -O<src\delphi3> -E<out> -N<out> misc.dpr
  and compare with
    tools/match.py --alias src/delphi3/aliases/misc.json --units zlib,EList,PlugInM,DebMDlg
      <out>/misc.exe <out>/misc.map <game>/Enginep.dpl data/signatures/Enginep.dpl.json
      TCustomZlibStream TCompressionStream TDecompressionStream TListObject TObjectList
      TPlugInManager TDebugMessageDlg }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  Forms,
  Engine,
  zlib,
  EList,
  PlugInM,
  DebMDlg;

var
  M: TMemoryStream;
  CS: TCompressionStream;
  DS: TDecompressionStream;
  P: Pointer;
  N: Integer;
  LO: TListObject;
  OL: TObjectList;
  PM: TPlugInManager;
  DD: TDebugMessageDlg;
  EN: TEngine;
begin
  M := TMemoryStream.Create;
  CS := TCompressionStream.Create(clDefault, M);
  CS.Write(N, SizeOf(N));
  CS.Read(N, SizeOf(N));
  CS.Seek(0, soFromCurrent);
  Writeln(CS.CompressionRate);
  CS.Free;
  DS := TDecompressionStream.Create(M);
  DS.Read(N, SizeOf(N));
  DS.Write(N, SizeOf(N));
  DS.Seek(0, soFromBeginning);
  DS.Free;
  CompressBuf(M.Memory, M.Size, P, N);
  DecompressBuf(P, N, 0, P, N);
  LO := TListObject.Create;
  LO.SaveToStream(M);
  LO.LoadFromStream(M);
  OL := TObjectList.Create;
  OL[0] := LO;
  OL.ListObjects[1] := OL[0];
  OL.SaveToStream(M);
  OL.LoadFromStream(M, TListObject);
  OL.DestroyItems;
  OL.Free;
  PM := TPlugInManager.Create(nil);
  PM.LoadPlugIns('.');
  PM.ReleasePlugIns;
  PM.Free;
  Register;
  EN := TEngine.Create(nil);
  DD := TDebugMessageDlg.Create(nil);
  DD.Engine := EN;
  DD.SaveBtnClick(nil);
  DD.StayOnTopClick(nil);
  DD.ClearBtnClick(nil);
  DD.Free;
  EN.Free;
  M.Free;
end.
