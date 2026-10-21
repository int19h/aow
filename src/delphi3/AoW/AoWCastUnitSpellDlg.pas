unit AoWCastUnitSpellDlg;

{ Draft declarations of AoWCastUnitSpellDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TCastUnitSpellDlg = class;


  { TCastUnitSpellDlg (instance size 228, VMT 00431ACC) }
  TCastUnitSpellDlg = class(TDataModule)
  public
    published
    Unit1Gge: TAoWGauge; { +0044 }
    Unit2Gge: TAoWGauge; { +0048 }
    Unit3Gge: TAoWGauge; { +004C }
    Unit4Gge: TAoWGauge; { +0050 }
    Unit5Gg: TAoWGauge; { +0054 }
    Unit6Gg: TAoWGauge; { +0058 }
    Unit7Gg: TAoWGauge; { +005C }
    Unit8Gg: TAoWGauge; { +0060 }
    CastBut: TAOWButton; { +0064 }
    TitleIcon: TAOWImage; { +0068 }
    Close: TAOWButton; { +006C }
    Title: TAOWLabel; { +0070 }
    CancelBut: TAOWButton; { +0074 }
    Dlg: TAOWWindow; { +0078 }
    SelectLbl: TAOWLabel; { +007C }
    UnitPnl: TAOWPanel; { +0080 }
    TopPnl: TAOWPanel; { +0084 }
    SpellUpkeepLbl: TAOWLabel; { +0088 }
    SpellManaLbl: TAOWLabel; { +008C }
    CastingManaLbl: TAOWLabel; { +0090 }
    SpellNameLbl: TAOWLabel; { +0094 }
    CasterNameLbl: TAOWLabel; { +0098 }
    CastingPointsLbl: TAOWLabel; { +009C }
    U1: TAOWCheckBox; { +00A0 }
    U2: TAOWCheckBox; { +00A4 }
    U3: TAOWCheckBox; { +00A8 }
    U4: TAOWCheckBox; { +00AC }
    U5: TAOWCheckBox; { +00B0 }
    U6: TAOWCheckBox; { +00B4 }
    U7: TAOWCheckBox; { +00B8 }
    U8: TAOWCheckBox; { +00BC }
    DecoL: TAOWImage; { +00C0 }
    DecoR: TAOWImage; { +00C4 }
    SpellFr: TAOWImage; { +00C8 }
    FaceFrame: TAOWImage; { +00CC }
    AoWFrame1: TAoWFrame; { +00D0 }
    SelectionInfoPnl: TAOWPanel; { +00D4 }
    SelectionInfoLbl: TAOWLabel; { +00D8 }
    Translator: TIvTranslator; { +00DC }
    public
    F_CastUnitSpellDlg_E0: Integer;
    procedure CloseClick;  { draft }
    procedure CastButClick;  { draft }
    procedure U1Change(A1: Integer);  { draft }
    procedure FaceFramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure U1PreDraw(A1: Integer; A2: Integer);  { draft }
    procedure U1Draw;  { draft }
    procedure SpellFrPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgHide;  { draft }
    procedure DlgUpdate;  { draft }
  end;


implementation

procedure TCastUnitSpellDlg.CloseClick;
begin end;

procedure TCastUnitSpellDlg.CastButClick;
begin end;

procedure TCastUnitSpellDlg.U1Change(A1: Integer);
begin end;

procedure TCastUnitSpellDlg.FaceFramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure TCastUnitSpellDlg.U1PreDraw(A1: Integer; A2: Integer);
begin end;

procedure TCastUnitSpellDlg.U1Draw;
begin end;

procedure TCastUnitSpellDlg.SpellFrPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TCastUnitSpellDlg.DlgHide;
begin end;

procedure TCastUnitSpellDlg.DlgUpdate;
begin end;


end.
