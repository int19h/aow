unit AOWChatWin;

{ Draft declarations of AOWChatWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TChatWindow = class;


  { TChatWindow (instance size 116, VMT 00412D5C) }
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
    F_ChatWindow_70: Byte;
    F_ChatWindow_71: array[0..2] of Byte;
    procedure MinClick;  { draft }
    procedure ChatEditReturn;  { draft }
    procedure ChatWinResize;  { draft }
    procedure ChatWinShow;  { draft }
    procedure ChatWinHide;  { draft }
    procedure ChatMemoUpdate;  { draft }
    procedure PlayerListPreDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;


implementation

procedure TChatWindow.MinClick;
begin end;

procedure TChatWindow.ChatEditReturn;
begin end;

procedure TChatWindow.ChatWinResize;
begin end;

procedure TChatWindow.ChatWinShow;
begin end;

procedure TChatWindow.ChatWinHide;
begin end;

procedure TChatWindow.ChatMemoUpdate;
begin end;

procedure TChatWindow.PlayerListPreDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;


end.
