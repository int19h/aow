unit AOWDialogWin;

{ Draft declarations of AOWDialogWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TDWin = class;


  { TDWin (instance size 176, VMT 00450334) }
  TDWin = class(TDataModule)
  public
    published
    Dialog: TAOWWindow; { +0044 }
    DTitle: TAOWLabel; { +0048 }
    DMessage: TAOWLabel; { +004C }
    DButton: TAOWButton; { +0050 }
    DebugWin: TAOWWindow; { +0054 }
    DebugDTitle: TAOWLabel; { +0058 }
    DebugDOkBtn: TAOWButton; { +005C }
    FrameLbl: TAOWLabel; { +0060 }
    DebugDfrTitle: TAOWLabel; { +0064 }
    DebugMemo: TAOWMemo; { +0068 }
    DMemoScroll: TAOWVScrollBar; { +006C }
    okPnl: TAOWPanel; { +0070 }
    yesPnl: TAOWPanel; { +0074 }
    yesBtn: TAOWButton; { +0078 }
    noBtn: TAOWButton; { +007C }
    BCeltL: TAoWFrame; { +0080 }
    TCeltL: TAoWFrame; { +0084 }
    TCeltLineL: TAOWImage; { +0088 }
    AOWImage1: TAOWImage; { +008C }
    AOWImage2: TAOWImage; { +0090 }
    AoWFrame1: TAoWFrame; { +0094 }
    SignBLine: TAoWFrame; { +0098 }
    SIcon: TAOWImage; { +009C }
    Translator: TIvTranslator; { +00A0 }
    public
    F_DWin_A4: Byte;
    F_DWin_A5: array[0..10] of Byte;
    procedure DButtonClick;
    procedure DebugDOkBtnClick;  { draft }
    procedure yesBtnClick(A1: Integer; A2: Integer);  { draft }
    procedure DialogKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

uses AoWWinMan;

procedure TDWin.DButtonClick;
begin
  General.PlayButtonSound(0);
  Dialog.Visible := False;
end;


procedure TDWin.DebugDOkBtnClick;
begin end;

procedure TDWin.yesBtnClick(A1: Integer; A2: Integer);
begin end;

procedure TDWin.DialogKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
