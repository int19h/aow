program matchtest;

{ Host program for the byte-matching of Network.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler from
  this directory (Engine.pas and its units are in the parent directory, zlib's object files too):
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B "-U..;..\Ilpack;..\Ilpack\stubs;..\Gfxepack" -O.. -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  Engine,
  NetworkE in 'NetworkE.pas';

var
  E: TEngine;
  PCSL: TPlayerCommunicationSettingsList;
  PCC: TPlayerCommunicationControl;
  PC: TPlayerCommunicator;
  LP: TLocalPCC;
  RP: TRemotePCC;
  PDL: TPackageDataList;
  M: TMemoryStream;
  TE: TTokenEvent;
  TEL: TTokenEventList;
  TP: TTokenPackage;
  TPD: TTokenPackageDistributer;
  TC: TTokenControl;
  TX: TTokenExecuter;
  TM: TTokenManager;
  DP: TDataPackage;
  PCS: TPlayerCommunicationSettings;
  P: Pointer;
begin
  E := TEngine.Create(nil);
  RegisterNetworkEngine(E);
  M := TMemoryStream.Create;
  P := nil;
  PCS := TPlayerCommunicationSettings.Create(nil);
  PCS.Free;
  DP := TDataPackage.Create(nil);
  DP.Free;
  PCSL := TPlayerCommunicationSettingsList.Create(nil);
  Writeln(Integer(PCSL.GetPlayers(0)));
  PCC := TPlayerCommunicationControl.Create;
  PCC.AddRef;
  PCC.Release;
  Writeln(Integer(PCC.GetPlayers(0)), PCC.GetCount, PCC.Setup(1), PCC.IndexOfSystemID(1));
  PC := TPlayerCommunicator.Create(nil);
  Writeln(PC.ReceiveDataPackage, PC.SendDataPackage(nil, 0, 0));
  LP := TLocalPCC.Create;
  LP.Clear;
  LP.Setup(1);
  LP.SetConnectionMode(0, cmLocal);
  RP := TRemotePCC.Create;
  RP.Clear;
  RP.SetConnectionMode(0, cmRemote);
  RP.SetSystemID(0, 1);
  RP.Setup(1, 1);
  RP.DataReceived(P, 0, 0);
  Writeln(RP.SendData(P, 0, 0));
  PDL := TPackageDataList.Create;
  Writeln(PDL.GetCount, Integer(PDL.GetPackageData(0)));
  PDL.Clear;
  PDL.Add(M);
  PDL.AddData(P, 0);
  PDL.Insert(0, M);
  PDL.Delete(0);
  PDL.Free;
  TE := TTokenEvent.Create(nil);
  TEL := TTokenEventList.Create(nil);
  Writeln(TEL.IndexOfTokenCounter(0), TEL.FindTE(0), Integer(TEL.GetEvent(0)), TEL.GetCount);
  TEL.SortOnTokenCounter;
  TEL.AddEvents(TEL);
  TEL.Add(TE);
  TEL.Delete(0);
  TEL.Insert(0, TE);
  TP := TTokenPackage.Create(nil);
  TP.Free;
  TPD := TTokenPackageDistributer.Create(nil);
  TPD.SetPC(PC);
  TPD.DataPackageReceived(PC);
  TC := TTokenControl.Create(nil, 0);
  TC.ClearEvents;
  Writeln(Integer(TC.GetEvent(0)), TC.GetCount, TC.Local, TC.Global, TC.Remote,
    TC.GetPrefetchableTokenEvents(nil));
  TX := TTokenExecuter.Create(nil);
  Writeln(TX.GetSyncValue, Integer(TX.GetTC(0)));
  TX.AddTC(TC);
  TX.DeleteTC(0);
  TX.RemoveTC(TC);
  TX.InsertTC(0, TC);
  TX.Reset;
  TX.PrefetchTokenEvent(TE);
  Writeln(Integer(TX.GetExecutingTokenEvent), TX.InsertExecuteEvent(TE));
  TX.Initialize(0);
  TX.ActivateTC(0);
  TX.ActivateNextTC;
  TX.Lock;
  TX.Unlock;
  Writeln(TX.GetLocked, TX.ProcessSystemTokenEvents);
  TX.AddSystemEvent(TE);
  TX.Process;
  TM := TTokenManager.Create(nil);
  Writeln(TM.GetCount, Integer(TM.GetTokenControl(0)));
  TM.TriggerMessage('');
  TM.Free;
  TPassTokenTE.Create(nil).Free;
  TSyncTE.Create(nil).Free;
end.
