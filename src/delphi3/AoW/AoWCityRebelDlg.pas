unit AoWCityRebelDlg;

{ Draft declarations of AoWCityRebelDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWWindow;

type
  TCityRebelDlg = class;


  { TCityRebelDlg (instance size 132, VMT 00436E98) }
  TCityRebelDlg = class(TDataModule)
  public
    published
    RebelWin: TAOWWindow; { +0044 }
    Title: TAOWLabel; { +0048 }
    Close: TAOWButton; { +004C }
    TitleIcon: TAOWImage; { +0050 }
    BCeltL: TAoWFrame; { +0054 }
    CenterBut: TAOWButton; { +0058 }
    CloseBut: TAOWButton; { +005C }
    RebelBG: TAOWImage; { +0060 }
    CityNameLabel: TAOWLabel; { +0064 }
    AOWLabel2: TAOWLabel; { +0068 }
    AOWLabel3: TAOWLabel; { +006C }
    AoWFrame1: TAoWFrame; { +0070 }
    Translator: TIvTranslator; { +0074 }
    public
    F_CityRebelDlg_78: array[0..7] of Byte;
    F_CityRebelDlg_80: Integer;
    procedure CloseClick;  { draft }
    procedure CenterButClick;  { draft }
    procedure RebelWinHide;  { draft }
    procedure RebelWinKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TCityRebelDlg.CloseClick;
begin end;

procedure TCityRebelDlg.CenterButClick;
begin end;

procedure TCityRebelDlg.RebelWinHide;
begin end;

procedure TCityRebelDlg.RebelWinKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
