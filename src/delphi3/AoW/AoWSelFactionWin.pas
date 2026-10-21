unit AoWSelFactionWin;

{ Draft declarations of AoWSelFactionWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWImage, AoWLabel, AoWMemo, AoWPanel;

type
  TSelFactionWin = class;


  { TSelFactionWin (instance size 144, VMT 00418940) }
  TSelFactionWin = class(TDataModule)
  public
    published
    FactionPnl: TAOWPanel; { +0044 }
    TopLbl: TAOWLabel; { +0048 }
    LightPnl: TAOWPanel; { +004C }
    LText: TAOWMemo; { +0050 }
    LStart: TAOWButton; { +0054 }
    LBack: TAOWButton; { +0058 }
    LSphere: TAOWImage; { +005C }
    DarkPnl: TAOWPanel; { +0060 }
    DStart: TAOWButton; { +0064 }
    DBack: TAOWButton; { +0068 }
    LName: TAOWLabel; { +006C }
    DText: TAOWMemo; { +0070 }
    DName: TAOWLabel; { +0074 }
    DSphere: TAOWImage; { +0078 }
    Translator: TIvTranslator; { +007C }
    public
    F_SelFactionWin_80: Integer;
    F_SelFactionWin_84: Integer;
    F_SelFactionWin_88: Integer;
    F_SelFactionWin_8C: array[0..3] of Byte;
    procedure LStartClick(A1: Integer);  { draft }
    procedure LightPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DarkPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure LBackClick;  { draft }
    procedure DBackClick;  { draft }
    procedure FactionPnlMouseMove;  { draft }
    procedure LightPnlMouseMove;  { draft }
    procedure DarkPnlMouseMove;  { draft }
    procedure AbortBtnClick;  { draft }
    procedure FactionPnlUpdate;  { draft }
    procedure FactionPnlKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TSelFactionWin.LStartClick(A1: Integer);
begin end;

procedure TSelFactionWin.LightPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TSelFactionWin.DarkPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TSelFactionWin.LBackClick;
begin end;

procedure TSelFactionWin.DBackClick;
begin end;

procedure TSelFactionWin.FactionPnlMouseMove;
begin end;

procedure TSelFactionWin.LightPnlMouseMove;
begin end;

procedure TSelFactionWin.DarkPnlMouseMove;
begin end;

procedure TSelFactionWin.AbortBtnClick;
begin end;

procedure TSelFactionWin.FactionPnlUpdate;
begin end;

procedure TSelFactionWin.FactionPnlKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
