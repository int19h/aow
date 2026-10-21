unit AoWItemsFoundDlg;

{ Draft declarations of AoWItemsFoundDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TItemsFoundDlg = class;


  { TItemsFoundDlg (instance size 176, VMT 0044C8D0) }
  TItemsFoundDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    PickupPnl: TAOWPanel; { +004C }
    PickupBtn: TAOWButton; { +0050 }
    CloseBtn: TAOWButton; { +0054 }
    BCeltL: TAoWFrame; { +0058 }
    TCeltL: TAoWFrame; { +005C }
    TCeltLineL: TAOWImage; { +0060 }
    AOWImage1: TAOWImage; { +0064 }
    AOWImage2: TAOWImage; { +0068 }
    CloseBtn2: TAOWButton; { +006C }
    OKPnl: TAOWPanel; { +0070 }
    MessageMemo: TAOWMemo; { +0074 }
    MessageMemoSB: TAOWVScrollBar; { +0078 }
    MemoPnl: TAOWPanel; { +007C }
    Translator: TIvTranslator; { +0080 }
    Gnd3: TAOWCheckBox; { +0084 }
    Gnd2: TAOWCheckBox; { +0088 }
    Gnd1: TAOWCheckBox; { +008C }
    Gnd4: TAOWCheckBox; { +0090 }
    Gnd5: TAOWCheckBox; { +0094 }
    LeftBtn: TAOWButton; { +0098 }
    RightBtn: TAOWButton; { +009C }
    public
    F_ItemsFoundDlg_A0: Integer;
    F_ItemsFoundDlg_A4: array[0..7] of Byte;
    F_ItemsFoundDlg_AC: Integer;
    procedure DlgHide;  { draft }
    procedure CloseBtn2Click;  { draft }
    procedure Gnd3Draw(A1: Integer; A2: Integer);  { draft }
    procedure PickupBtnClick;  { draft }
    procedure Gnd3MouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure LeftBtnClick;  { draft }
    procedure RightBtnClick;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TItemsFoundDlg.DlgHide;
begin end;

procedure TItemsFoundDlg.CloseBtn2Click;
begin end;

procedure TItemsFoundDlg.Gnd3Draw(A1: Integer; A2: Integer);
begin end;

procedure TItemsFoundDlg.PickupBtnClick;
begin end;

procedure TItemsFoundDlg.Gnd3MouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TItemsFoundDlg.LeftBtnClick;
begin end;

procedure TItemsFoundDlg.RightBtnClick;
begin end;

procedure TItemsFoundDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
