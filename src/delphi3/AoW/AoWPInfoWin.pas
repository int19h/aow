unit AoWPInfoWin;

{ Draft declarations of AoWPInfoWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TPInfoW = class;


  { TPInfoW (instance size 160, VMT 00422EC8) }
  TPInfoW = class(TDataModule)
  public
    published
    PInfoWin: TAOWWindow; { +0044 }
    Min: TAOWButton; { +0048 }
    IWTitle: TAOWLabel; { +004C }
    SIcon: TAOWImage; { +0050 }
    EventList: TAOWListBox; { +0054 }
    LeadL: TAOWLabel; { +0058 }
    Turn: TAOWLabel; { +005C }
    RShield: TAOWImage; { +0060 }
    EventFr: TAOWPanel; { +0064 }
    EventSB: TAOWVScrollBar; { +0068 }
    PInfoPnl: TAOWPanel; { +006C }
    LeaderCB: TAOWCheckBox; { +0070 }
    FaceFr: TAOWPanel; { +0074 }
    EventLbl: TAOWLabel; { +0078 }
    ShieldFr: TAOWPanel; { +007C }
    TurnFr: TAOWPanel; { +0080 }
    InfoFr: TAOWPanel; { +0084 }
    Player: TAOWLabel; { +0088 }
    Race: TAOWLabel; { +008C }
    RaceCB: TAOWCheckBox; { +0090 }
    Center: TAOWButton; { +0094 }
    Help: TAOWButton; { +0098 }
    Translator: TIvTranslator; { +009C }
    public
    procedure MinClick;  { draft }
    procedure EventListDoubleClick;  { draft }
    procedure EventListPreDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure EventListDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure PInfoWinResize;  { draft }
    procedure EventListMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure LeaderBtnClick(A1: Integer; A2: Integer);  { draft }
    procedure RaceBtnClick;  { draft }
    procedure FaceFrDraw(A1: Integer; A2: Integer);  { draft }
    procedure FaceFrMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure HelpClick;  { draft }
  end;


implementation

procedure TPInfoW.MinClick;
begin end;

procedure TPInfoW.EventListDoubleClick;
begin end;

procedure TPInfoW.EventListPreDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TPInfoW.EventListDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TPInfoW.PInfoWinResize;
begin end;

procedure TPInfoW.EventListMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TPInfoW.LeaderBtnClick(A1: Integer; A2: Integer);
begin end;

procedure TPInfoW.RaceBtnClick;
begin end;

procedure TPInfoW.FaceFrDraw(A1: Integer; A2: Integer);
begin end;

procedure TPInfoW.FaceFrMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TPInfoW.HelpClick;
begin end;


end.
