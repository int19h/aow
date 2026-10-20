program matchtest;

{ Host program for the byte-matching of aowDPlay.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  DPlay in 'DPlay.pas',
  DPLobby in 'DPLobby.pas',
  aowDPlayComp in 'aowDPlayComp.pas';

var
  GP: TGDPlay;
  S: string;
  G: TGUID;
  DPN: TDPName;
  SD: TDPSessionDesc2;
begin
  TGuidItem.Create.Free;
  TGDConnection.Create.Free;
  TGDSession.Create.Free;
  TGDPlayer.Create.Free;
  TCapsItem.Create.Free;
  TGDFile.Create.Free;
  TGDMessage.Create.Free;
  TgdSentMsg.Create.Free;
  GP := TGDPlay.Create(nil);
  GP.GauranteeMsgs := True;
  GP.UseCodes := True;
  GP.PlayerName := 'x';
  Writeln(GP.CheckLobby, GP.GetConnections, GP.CreateSession);
  GP.CloseSession;
  Writeln(GP.GetSessions(True), GP.Connect(0));
  GP.DisConnect;
  Writeln(GP.JoinSession(0), GP.LockSession, GP.CreatePlayer('x'), GP.GetPlayers(0), GP.GetPlayerIndex(0));
  GP.CreateMsg(0, nil, 0, 0).Free;
  Writeln(GP.SendMessage(0, nil, 0), GP.SendChatMessage(0, 'x'), GP.SendPingMessage(0));
  Writeln(GP.SendFileMessage(0, S, fsmBurst), GP.SendFileDataMessage(0, nil, 0, 'x', fsmBurst));
  Writeln(GP.CheckMessages, GP.EjectPlayer(0), GP.UpdateSessionInfo, GP.UpdatePlayerInfo(0));
  Writeln(GotConnection(G, nil, 0, @DPN, 0, nil), GotSession(SD, nil, 0, nil), GotPlayer(0, 0, @DPN, 0, nil));
  GP.Free;
  Register;
end.
