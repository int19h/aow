unit AOWChatWin;

{ Chat input, scrolling, alignment and player colors recovered from AoW.exe.
  Layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AoWButton, AoWEdit, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TChatWindow = class;


  { TChatWindow: size $74; $70 pending scroll to the newest message. VMT 00412D5C. }
  TChatWindow = class(TDataModule)
  public
    published
    ChatWin: TAOWWindow; { +0044 }
    ChatMemo: TAOWMemo; { +0048 }
    ChatEdit: TAOWEdit; { +004C }
    PlayerList: TAOWListBox; { +0050 }
    SIcon: TAOWImage; { +0054 }
    IWTitle: TAOWLabel; { +0058 }
    Min: TAOWButton; { +005C }
    ChatPnl: TAOWPanel; { +0060 }
    NSBar: TAOWVScrollBar; { +0064 }
    ChatSB: TAOWVScrollBar; { +0068 }
    Translator: TIvTranslator; { +006C }
    public
    FScrollPending: Boolean; { $70 }
    F_ChatWindow_71: array[0..2] of Byte;
    published procedure MinClick; public
    published procedure ChatEditReturn; public
    published procedure ChatWinResize; public
    published procedure ChatWinShow; public
    published procedure ChatWinHide; public
    published procedure ChatMemoUpdate; public
    published procedure PlayerListPreDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; const SD: TSurfaceDesc); public
  end;


implementation

uses AoWWinMan, aowSetupEvents;

procedure TChatWindow.MinClick;
begin
  General.PlayButtonSound(0);
  ChatWin.Visible := False;
end;

procedure TChatWindow.ChatEditReturn; { Tried name list for initial guard only; with PlayerList after nonempty guard preserves list across concatenation; named cached list with identity after the nonempty guard; nested with scopes for retained list and network component; no exact match. }
var Text: string;
begin
  if (ChatEdit.Text <> '') and (PlayerList.Selected > -1) then
  begin
    Text := SetupEvents.DPlay.PlayerName + ': ' + ChatEdit.Text;
    SetupEvents.DPlay.SendChatMessage(Integer(PlayerList.Items.Objects[PlayerList.Selected]), Text);
    ChatMemo.Items.Add(Text);
    FScrollPending := True;
    ChatEdit.Text := '';
  end;
  ChatEdit.FRedraw := True;
end;

procedure TChatWindow.ChatWinResize;
begin
  with ChatWin do
    with Alignment do
    begin
      LeftOffset := WinLeft;
      BottomOffset := FWinManager.WinHeight - WinTop - WinHeight;
      AlignWidth := awLeft;
    end;
  FScrollPending := True;
end;

procedure TChatWindow.ChatWinShow;
begin
  General.RegisterDialog(ChatWin);
  FScrollPending := True;
end;

procedure TChatWindow.ChatWinHide;
begin General.UnregisterDialog(ChatWin); end;

procedure TChatWindow.ChatMemoUpdate;
begin
  if FScrollPending then
  begin
    with ChatSB do Position := Max + 1 - NumberVisible;
    FScrollPending := False;
  end;
end;

procedure TChatWindow.PlayerListPreDrawItem(Sender: TObject; const DrawRect: TRect; DrawItem: Integer; const SD: TSurfaceDesc);
var Player: Shortint;
begin
  if DrawItem <> 0 then
  begin
    Player := AoWHSMap.FPlayerCommunicator.PCC.IndexOfSystemID(Integer(PlayerList.Items.Objects[DrawItem]));
    if (Player > 0) and { Original leaves player zero without a race color. } (Player < AoWHSMap.FPlayers.Count) then
      PlayerList.TextColor := RaceColors[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace];
  end
  else PlayerList.TextColor := $8FA9A0;
end;

end.
