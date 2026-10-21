unit AoWTCUnit;

{ Draft declarations of AoWTCUnit, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox;

type
  TTCUnit = class;


  { TTCUnit (instance size 340, VMT 00433494) }
  TTCUnit = class(TDataModule)
  public
    published
    TCUnitWin: TAOWWindow; { +0044 }
    SIcon: TAOWImage; { +0048 }
    Min: TAOWButton; { +004C }
    Close: TAOWButton; { +0050 }
    IWTitle: TAOWLabel; { +0054 }
    UAttackIcon: TAOWImage; { +0058 }
    UDefenseIcon: TAOWImage; { +005C }
    UMovesIcon: TAOWImage; { +0060 }
    UDamageIcon: TAOWImage; { +0064 }
    UResistanceIcon: TAOWImage; { +0068 }
    UHitsIcon: TAOWImage; { +006C }
    UAttack: TAOWLabel; { +0070 }
    UDefense: TAOWLabel; { +0074 }
    UMoves: TAOWLabel; { +0078 }
    UDamage: TAOWLabel; { +007C }
    UResistance: TAOWLabel; { +0080 }
    UHits: TAOWLabel; { +0084 }
    UnitName: TAOWMemo; { +0088 }
    UStatPnl: TAOWPanel; { +008C }
    UAbilLB: TAOWListBox; { +0090 }
    AbilNameLbl: TAOWLabel; { +0094 }
    TCUnitPnl: TAOWPanel; { +0098 }
    AOWImage1: TAOWImage; { +009C }
    AUnitName: TAOWMemo; { +00A0 }
    USelAbilLb: TAOWListBox; { +00A4 }
    TCAbilPnl: TAOWPanel; { +00A8 }
    AbilAtt: TAOWImage; { +00AC }
    AbilAttLbl: TAOWLabel; { +00B0 }
    AbilStatBox: TAOWPanel; { +00B4 }
    AbilStat: TAOWListBox; { +00B8 }
    AbilDam: TAOWImage; { +00BC }
    AbilDamLbl: TAOWLabel; { +00C0 }
    TargetLbl: TAOWLabel; { +00C4 }
    TargetULbl: TAOWLabel; { +00C8 }
    TargetSelPnl: TAOWPanel; { +00CC }
    NoTargetPnl: TAOWPanel; { +00D0 }
    TargetMessage: TAOWMemo; { +00D4 }
    UnitHits: TAoWGauge; { +00D8 }
    UnitMana: TAoWGauge; { +00DC }
    CelticCross: TAOWImage; { +00E0 }
    UStatP1: TAOWPanel; { +00E4 }
    UStatP2: TAOWPanel; { +00E8 }
    AAttackIcon: TAOWImage; { +00EC }
    ADefenseIcon: TAOWImage; { +00F0 }
    AMovesIcon: TAOWImage; { +00F4 }
    ADamageIcon: TAOWImage; { +00F8 }
    AResistanceIcon: TAOWImage; { +00FC }
    AHitsIcons: TAOWImage; { +0100 }
    AAttack: TAOWLabel; { +0104 }
    ADefense: TAOWLabel; { +0108 }
    AMoves: TAOWLabel; { +010C }
    ADamage: TAOWLabel; { +0110 }
    AResistance: TAOWLabel; { +0114 }
    AHits: TAOWLabel; { +0118 }
    AStatPnl: TAOWPanel; { +011C }
    AStatP1: TAOWPanel; { +0120 }
    AStatP2: TAOWPanel; { +0124 }
    Center: TAOWButton; { +0128 }
    AbilSB: TAOWVScrollBar; { +012C }
    UAbilSB: TAOWVScrollBar; { +0130 }
    AOWVScrollBar1: TAOWVScrollBar; { +0134 }
    AbilFr: TAOWPanel; { +0138 }
    ANameFr: TAOWPanel; { +013C }
    TargerFr: TAOWPanel; { +0140 }
    TNamePnl: TAOWPanel; { +0144 }
    UnitFr: TAOWPanel; { +0148 }
    UnitBox: TaowUserDrawBox; { +014C }
    Translator: TIvTranslator; { +0150 }
    public
    procedure TCUnitWinResize;  { draft }
    procedure MinClick;  { draft }
    procedure UAbilLBPreDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure TCUnitPnlDrawBack(A1: Integer; A2: Integer);  { draft }
    procedure UAbilLBUpdate;  { draft }
    procedure UAbilLBMouseDown(A1: Integer; A2: Byte);  { draft }
    procedure UAbilLBMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure HeroSMapMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure CenterClick;  { draft }
    procedure CloseClick;  { draft }
  end;


implementation

procedure TTCUnit.TCUnitWinResize;
begin end;

procedure TTCUnit.MinClick;
begin end;

procedure TTCUnit.UAbilLBPreDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTCUnit.TCUnitPnlDrawBack(A1: Integer; A2: Integer);
begin end;

procedure TTCUnit.UAbilLBUpdate;
begin end;

procedure TTCUnit.UAbilLBMouseDown(A1: Integer; A2: Byte);
begin end;

procedure TTCUnit.UAbilLBMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTCUnit.HeroSMapMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TTCUnit.CenterClick;
begin end;

procedure TTCUnit.CloseClick;
begin end;


end.
