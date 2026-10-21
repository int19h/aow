unit AoWUnitSelDlg;

{ Draft declarations of AoWUnitSelDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TUnitSelectionDlg = class;


  { TUnitSelectionDlg (instance size 176, VMT 004449D4) }
  TUnitSelectionDlg = class(TDataModule)
  public
    published
    SelectBtn: TAOWButton; { +0044 }
    TitleIcon: TAOWImage; { +0048 }
    Close: TAOWButton; { +004C }
    Title: TAOWLabel; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    Dlg: TAOWWindow; { +0058 }
    UnitPnl: TAOWPanel; { +005C }
    SourcePnl: TAOWPanel; { +0060 }
    SourceNameLbl: TAOWLabel; { +0064 }
    U1: TAOWCheckBox; { +0068 }
    U2: TAOWCheckBox; { +006C }
    U3: TAOWCheckBox; { +0070 }
    U4: TAOWCheckBox; { +0074 }
    U5: TAOWCheckBox; { +0078 }
    U6: TAOWCheckBox; { +007C }
    U7: TAOWCheckBox; { +0080 }
    U8: TAOWCheckBox; { +0084 }
    DecoL: TAOWImage; { +0088 }
    DecoR: TAOWImage; { +008C }
    SourceFace: TAOWImage; { +0090 }
    AoWFrame1: TAoWFrame; { +0094 }
    SelectionInfoPnl: TAOWPanel; { +0098 }
    SelectionInfoLbl: TAOWLabel; { +009C }
    SelectionLbl: TAOWLabel; { +00A0 }
    Translator: TIvTranslator; { +00A4 }
    public
    F_UnitSelectionDlg_A8: Integer;
    F_UnitSelectionDlg_AC: array[0..3] of Byte;
    procedure CloseClick;  { draft }
    procedure SelectBtnClick;  { draft }
    procedure U1Change(A1: Integer);  { draft }
    procedure U1PreDraw(A1: Integer; A2: Integer);  { draft }
    procedure SourceFacePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgHide;  { draft }
  end;


implementation

procedure TUnitSelectionDlg.CloseClick;
begin end;

procedure TUnitSelectionDlg.SelectBtnClick;
begin end;

procedure TUnitSelectionDlg.U1Change(A1: Integer);
begin end;

procedure TUnitSelectionDlg.U1PreDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitSelectionDlg.SourceFacePreDraw(A1: Integer; A2: Integer);
begin end;

procedure TUnitSelectionDlg.DlgHide;
begin end;


end.
