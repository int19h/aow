unit AoWArmyEventDlg;

{ Draft declarations of AoWArmyEventDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TArmyEventDlg = class;


  { TArmyEventDlg (instance size 140, VMT 004365E4) }
  TArmyEventDlg = class(TDataModule)
  public
    published
    ArmyEventWin: TAOWWindow; { +0044 }
    BGoldSq: TAoWFrame; { +0048 }
    UnitPnl: TAOWPanel; { +004C }
    EventText: TAOWLabel; { +0050 }
    DamagePic: TAOWImage; { +0054 }
    CloseBut: TAOWButton; { +0058 }
    TitleIcon: TAOWImage; { +005C }
    Close: TAOWButton; { +0060 }
    Title: TAOWLabel; { +0064 }
    BCeltL: TAoWFrame; { +0068 }
    DecoL: TAOWImage; { +006C }
    DecoR: TAOWImage; { +0070 }
    Translator: TIvTranslator; { +0074 }
    public
    F_ArmyEventDlg_78: array[0..11] of Byte;
    F_ArmyEventDlg_84: Integer;
    F_ArmyEventDlg_88: Integer;
    procedure ArmyEventDlgCreate;  { draft }
    procedure ArmyEventDlgDestroy;  { draft }
    procedure CloseClick;  { draft }
    procedure UnitPnlDrawBack(A1: Integer; A2: Integer);  { draft }
    procedure UnitPnlUpdate;  { draft }
    procedure ArmyEventWinHide;  { draft }
    procedure ArmyEventWinKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TArmyEventDlg.ArmyEventDlgCreate;
begin end;

procedure TArmyEventDlg.ArmyEventDlgDestroy;
begin end;

procedure TArmyEventDlg.CloseClick;
begin end;

procedure TArmyEventDlg.UnitPnlDrawBack(A1: Integer; A2: Integer);
begin end;

procedure TArmyEventDlg.UnitPnlUpdate;
begin end;

procedure TArmyEventDlg.ArmyEventWinHide;
begin end;

procedure TArmyEventDlg.ArmyEventWinKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
