unit aowSetupEvents;

{ Draft declarations of aowSetupEvents, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWSetup, aowDPlayComp;

type
  TSetupEvents = class;


  { TSetupEvents (instance size 80, VMT 0041375C) }
  TSetupEvents = class(TDataModule)
  public
    published
    DPlay: TGDPlay; { +0044 }
    SetupControl: TSetupControl; { +0048 }
    public
    F_SetupEvents_4C: array[0..3] of Byte;
    procedure SetupControlStart;  { draft }
    procedure SetupControlSendMap(A1: Integer; A2: Integer);  { draft }
    procedure DPlayFileStartMessage;  { draft }
    procedure DPlayFileDoneMessage(A1: Integer; A2: Integer);  { draft }
    procedure DPlayFileProgressMessage(A1: Integer; A2: Integer);  { draft }
    procedure DPlayChatMessage(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure DPlayMessageTimeout(A1: Integer);  { draft }
    procedure DPlayEjected;  { draft }
    procedure DPlayPingMessage;  { draft }
    procedure SetupControlCustomizeLeader(A1: Integer; A2: Integer);  { draft }
    procedure SetupControlLoadMap(A1: Integer; A2: Integer);  { draft }
    procedure SetupControlSendData(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetupControlSettingChanged;  { draft }
    procedure SetupControlEjectPlayer(A1: Integer; A2: Integer);  { draft }
    procedure DPlayMessage(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure SetupControlSynchronize(A1: Integer);  { draft }
    procedure SetupControlPlayerSetupDone;  { draft }
    procedure SetupControlIncompatibleVersion(A1: Integer; A2: Integer);  { draft }
    procedure DPlaySessionLost;  { draft }
    procedure SetupControlSendingMaps;  { draft }
    procedure DPlayMessageError;  { draft }
    procedure SetupEventsCreate;  { draft }
    procedure DPlayDestroyPlayer(A1: Integer);  { draft }
  end;


implementation

procedure TSetupEvents.SetupControlStart;
begin end;

procedure TSetupEvents.SetupControlSendMap(A1: Integer; A2: Integer);
begin end;

procedure TSetupEvents.DPlayFileStartMessage;
begin end;

procedure TSetupEvents.DPlayFileDoneMessage(A1: Integer; A2: Integer);
begin end;

procedure TSetupEvents.DPlayFileProgressMessage(A1: Integer; A2: Integer);
begin end;

procedure TSetupEvents.DPlayChatMessage(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSetupEvents.DPlayMessageTimeout(A1: Integer);
begin end;

procedure TSetupEvents.DPlayEjected;
begin end;

procedure TSetupEvents.DPlayPingMessage;
begin end;

procedure TSetupEvents.SetupControlCustomizeLeader(A1: Integer; A2: Integer);
begin end;

procedure TSetupEvents.SetupControlLoadMap(A1: Integer; A2: Integer);
begin end;

procedure TSetupEvents.SetupControlSendData(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSetupEvents.SetupControlSettingChanged;
begin end;

procedure TSetupEvents.SetupControlEjectPlayer(A1: Integer; A2: Integer);
begin end;

procedure TSetupEvents.DPlayMessage(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSetupEvents.SetupControlSynchronize(A1: Integer);
begin end;

procedure TSetupEvents.SetupControlPlayerSetupDone;
begin end;

procedure TSetupEvents.SetupControlIncompatibleVersion(A1: Integer; A2: Integer);
begin end;

procedure TSetupEvents.DPlaySessionLost;
begin end;

procedure TSetupEvents.SetupControlSendingMaps;
begin end;

procedure TSetupEvents.DPlayMessageError;
begin end;

procedure TSetupEvents.SetupEventsCreate;
begin end;

procedure TSetupEvents.DPlayDestroyPlayer(A1: Integer);
begin end;


end.
