unit AoWSpellBook;

{ Draft declarations of AoWSpellBook, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWBookWindow, AoWButton, AoWImage, AoWLabel, AoWMemo, AoWPanel;

type
  TSpellBook = class;


  { TSpellBook (instance size 584, VMT 0042DDA8) }
  TSpellBook = class(TDataModule)
  public
    published
    LeftHeader: TAOWLabel; { +0044 }
    LeftSpellPage: TAOWPanel; { +0048 }
    S1Pnl: TAOWPanel; { +004C }
    S1Spell: TAOWLabel; { +0050 }
    S1Class: TAOWLabel; { +0054 }
    S1Memo: TAOWMemo; { +0058 }
    S1Cost: TAOWLabel; { +005C }
    S1Icn: TAOWImage; { +0060 }
    S2Pnl: TAOWPanel; { +0064 }
    S2Spell: TAOWLabel; { +0068 }
    S2Class: TAOWLabel; { +006C }
    S2Memo: TAOWMemo; { +0070 }
    S2Cost: TAOWLabel; { +0074 }
    S2Icn: TAOWImage; { +0078 }
    S3Pnl: TAOWPanel; { +007C }
    S3Spell: TAOWLabel; { +0080 }
    S3Class: TAOWLabel; { +0084 }
    S3Memo: TAOWMemo; { +0088 }
    S3Cost: TAOWLabel; { +008C }
    S3Icn: TAOWImage; { +0090 }
    S4Pnl: TAOWPanel; { +0094 }
    S4Spell: TAOWLabel; { +0098 }
    S4Class: TAOWLabel; { +009C }
    S4Memo: TAOWMemo; { +00A0 }
    S4Cost: TAOWLabel; { +00A4 }
    S4Icn: TAOWImage; { +00A8 }
    RightHeader: TAOWLabel; { +00AC }
    RightSpellPage: TAOWPanel; { +00B0 }
    S5Pnl: TAOWPanel; { +00B4 }
    S5Spell: TAOWLabel; { +00B8 }
    S5Class: TAOWLabel; { +00BC }
    S5Memo: TAOWMemo; { +00C0 }
    S5Cost: TAOWLabel; { +00C4 }
    S5Icn: TAOWImage; { +00C8 }
    S6Pnl: TAOWPanel; { +00CC }
    S6Spell: TAOWLabel; { +00D0 }
    S6Class: TAOWLabel; { +00D4 }
    S6Memo: TAOWMemo; { +00D8 }
    S6Cost: TAOWLabel; { +00DC }
    S6Icn: TAOWImage; { +00E0 }
    S7Pnl: TAOWPanel; { +00E4 }
    S7Spell: TAOWLabel; { +00E8 }
    S7Class: TAOWLabel; { +00EC }
    S7Memo: TAOWMemo; { +00F0 }
    S7Cost: TAOWLabel; { +00F4 }
    S7Icn: TAOWImage; { +00F8 }
    S8Pnl: TAOWPanel; { +00FC }
    S8Spell: TAOWLabel; { +0100 }
    S8Class: TAOWLabel; { +0104 }
    S8Memo: TAOWMemo; { +0108 }
    S8Cost: TAOWLabel; { +010C }
    S8Icn: TAOWImage; { +0110 }
    S1Btn: TAOWButton; { +0114 }
    CurrentPointsLbl: TAOWLabel; { +0118 }
    Line: TAOWLabel; { +011C }
    CastingPointsMaxLbl: TAOWLabel; { +0120 }
    GlobalBtn: TAOWButton; { +0124 }
    UnitBtn: TAOWButton; { +0128 }
    CombatBtn: TAOWButton; { +012C }
    InfoBtn: TAOWButton; { +0130 }
    PrevBtn: TAOWButton; { +0134 }
    NextBtn: TAOWButton; { +0138 }
    Cancel: TAOWButton; { +013C }
    S2Btn: TAOWButton; { +0140 }
    S3Btn: TAOWButton; { +0144 }
    S4Btn: TAOWButton; { +0148 }
    S5btn: TAOWButton; { +014C }
    S6Btn: TAOWButton; { +0150 }
    S7Btn: TAOWButton; { +0154 }
    S8Btn: TAOWButton; { +0158 }
    CastingPage: TAOWPanel; { +015C }
    CastingPnl: TAOWPanel; { +0160 }
    CastingSpell: TAOWLabel; { +0164 }
    CastingClass: TAOWLabel; { +0168 }
    CastingMemo: TAOWMemo; { +016C }
    CastingCost: TAOWLabel; { +0170 }
    CastingIcn: TAOWImage; { +0174 }
    LeftInfoPage: TAOWPanel; { +0178 }
    CastingStatus: TAOWLabel; { +017C }
    CastingPointsLbl: TAOWLabel; { +0180 }
    CastingBtn: TAOWButton; { +0184 }
    Sel4: TAOWButton; { +0188 }
    SelPnl: TAOWPanel; { +018C }
    Sel3: TAOWButton; { +0190 }
    Sel2: TAOWButton; { +0194 }
    Sel1: TAOWButton; { +0198 }
    Sel5: TAOWButton; { +019C }
    Sel6: TAOWButton; { +01A0 }
    Sel7: TAOWButton; { +01A4 }
    SelLbl: TAOWLabel; { +01A8 }
    SpellBookLbl: TAOWLabel; { +01AC }
    NameLbl: TAOWLabel; { +01B0 }
    ManaPoolLbl: TAOWLabel; { +01B4 }
    CastingLbl: TAOWLabel; { +01B8 }
    FaceFrame: TAOWImage; { +01BC }
    Face: TAOWImage; { +01C0 }
    Dlg: TAoWBookWindow; { +01C4 }
    NoneCastingLbl: TAOWLabel; { +01C8 }
    ResearchPage: TAOWPanel; { +01CC }
    ResearchName: TAOWLabel; { +01D0 }
    ResearchClass: TAOWLabel; { +01D4 }
    ResearchMemo: TAOWMemo; { +01D8 }
    ResearchCost: TAOWLabel; { +01DC }
    ResearchIcn: TAOWImage; { +01E0 }
    ResearchStatus: TAOWLabel; { +01E4 }
    ResearchNone: TAOWLabel; { +01E8 }
    ResearchPnl: TAOWPanel; { +01EC }
    ResearchLbl: TAOWLabel; { +01F0 }
    RightInfoPage: TAOWPanel; { +01F4 }
    ManaInfo: TAOWLabel; { +01F8 }
    Sep: TAOWImage; { +01FC }
    ResearchPointsLbl: TAOWLabel; { +0200 }
    ResearchManaPoolLbl: TAOWLabel; { +0204 }
    RManaInfo: TAOWLabel; { +0208 }
    AOWImage1: TAOWImage; { +020C }
    ResearchBookLbl: TAOWLabel; { +0210 }
    CancelResearchBtn: TAOWButton; { +0214 }
    CancelCastingBtn: TAOWButton; { +0218 }
    Translator: TIvTranslator; { +021C }
    public
    F_SpellBook_220: Byte;
    F_SpellBook_221: Byte;
    F_SpellBook_222: Byte;
    F_SpellBook_223: array[0..0] of Byte;
    F_SpellBook_224: Integer;
    F_SpellBook_228: Integer;
    F_SpellBook_22C: Integer;
    F_SpellBook_230: Integer;
    F_SpellBook_234: Integer;
    F_SpellBook_238: array[0..7] of Byte;
    F_SpellBook_240: Integer;
    F_SpellBook_244: Integer;
    procedure SpellBookCreate;  { draft }
    procedure SpellBookDestroy;  { draft }
    procedure CancelClick(A1: Integer);  { draft }
    procedure NextBtnClick;  { draft }
    procedure PrevBtnClick;  { draft }
    procedure SpellIconDraw(A1: Integer; A2: Integer);  { draft }
    procedure SelectSpellBtnClick(A1: Integer);  { draft }
    procedure GlobalBtnClick;  { draft }
    procedure UnitBtnClick;  { draft }
    procedure CombatBtnClick;  { draft }
    procedure InfoBtnClick;  { draft }
    procedure CastingBtnClick;  { draft }
    procedure CancelCastingBtnClick;  { draft }
    procedure FaceDraw(A1: Integer; A2: Integer);  { draft }
    procedure ResearchIcnDraw(A1: Integer; A2: Integer);  { draft }
    procedure CastingIcnDraw(A1: Integer; A2: Integer);  { draft }
    procedure CancelResearchBtnClick;  { draft }
    procedure Sel1Click;  { draft }
    procedure DlgHide;  { draft }
    procedure DlgUpdate;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TSpellBook.SpellBookCreate;
begin end;

procedure TSpellBook.SpellBookDestroy;
begin end;

procedure TSpellBook.CancelClick(A1: Integer);
begin end;

procedure TSpellBook.NextBtnClick;
begin end;

procedure TSpellBook.PrevBtnClick;
begin end;

procedure TSpellBook.SpellIconDraw(A1: Integer; A2: Integer);
begin end;

procedure TSpellBook.SelectSpellBtnClick(A1: Integer);
begin end;

procedure TSpellBook.GlobalBtnClick;
begin end;

procedure TSpellBook.UnitBtnClick;
begin end;

procedure TSpellBook.CombatBtnClick;
begin end;

procedure TSpellBook.InfoBtnClick;
begin end;

procedure TSpellBook.CastingBtnClick;
begin end;

procedure TSpellBook.CancelCastingBtnClick;
begin end;

procedure TSpellBook.FaceDraw(A1: Integer; A2: Integer);
begin end;

procedure TSpellBook.ResearchIcnDraw(A1: Integer; A2: Integer);
begin end;

procedure TSpellBook.CastingIcnDraw(A1: Integer; A2: Integer);
begin end;

procedure TSpellBook.CancelResearchBtnClick;
begin end;

procedure TSpellBook.Sel1Click;
begin end;

procedure TSpellBook.DlgHide;
begin end;

procedure TSpellBook.DlgUpdate;
begin end;

procedure TSpellBook.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
