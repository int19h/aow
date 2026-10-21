unit AOWControlWin;

{ Draft declarations of AOWControlWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TControlWin = class;


  { TControlWin (instance size 380, VMT 00404910) }
  TControlWin = class(TDataModule)
  public
    published
    ControlWindow: TAOWWindow; { +0044 }
    CWTitle: TAOWLabel; { +0048 }
    CWMinIcon: TAOWButton; { +004C }
    Unit1Frame: TAoWFrame; { +0050 }
    Unit2Frame: TAoWFrame; { +0054 }
    Unit3Frame: TAoWFrame; { +0058 }
    Unit4Frame: TAoWFrame; { +005C }
    Unit5Frame: TAoWFrame; { +0060 }
    Unit6Frame: TAoWFrame; { +0064 }
    Unit7Frame: TAoWFrame; { +0068 }
    Unit8Frame: TAoWFrame; { +006C }
    CTitleIcon: TAOWImage; { +0070 }
    MovesLbl: TAOWLabel; { +0074 }
    PartyStatusLbl: TAOWLabel; { +0078 }
    Close: TAOWButton; { +007C }
    U1MIcon: TAOWImage; { +0080 }
    U2MIcon: TAOWImage; { +0084 }
    U3MIcon: TAOWImage; { +0088 }
    U4MIcon: TAOWImage; { +008C }
    U5MIcon: TAOWImage; { +0090 }
    U6MIcon: TAOWImage; { +0094 }
    U7MIcon: TAOWImage; { +0098 }
    U8MIcon: TAOWImage; { +009C }
    MoraleMask: TAOWImage; { +00A0 }
    MoveIcon: TAOWImage; { +00A4 }
    PartyT1Pnl: TAOWPanel; { +00A8 }
    PartyBPnl: TAOWPanel; { +00AC }
    PartyT2Pnl: TAOWPanel; { +00B0 }
    PartyT3Pnl: TAOWPanel; { +00B4 }
    PartyT4Pnl: TAOWPanel; { +00B8 }
    Unit1Gge: TAoWGauge; { +00BC }
    Unit2Gge: TAoWGauge; { +00C0 }
    Unit3Gge: TAoWGauge; { +00C4 }
    Unit4Gge: TAoWGauge; { +00C8 }
    Unit5Gge: TAoWGauge; { +00CC }
    Unit6Gge: TAoWGauge; { +00D0 }
    Unit7Gge: TAoWGauge; { +00D4 }
    Unit8Gge: TAoWGauge; { +00D8 }
    Unit1Chk: TAOWCheckBox; { +00DC }
    Unit2Chk: TAOWCheckBox; { +00E0 }
    Unit3Chk: TAOWCheckBox; { +00E4 }
    Unit5Chk: TAOWCheckBox; { +00E8 }
    Unit6Chk: TAOWCheckBox; { +00EC }
    Unit7Chk: TAOWCheckBox; { +00F0 }
    Unit4Chk: TAOWCheckBox; { +00F4 }
    Unit8Chk: TAOWCheckBox; { +00F8 }
    Emp1Fr: TAoWFrame; { +00FC }
    Emp2Fr: TAoWFrame; { +0100 }
    Emp3Fr: TAoWFrame; { +0104 }
    Emp4Fr: TAoWFrame; { +0108 }
    Emp5Fr: TAoWFrame; { +010C }
    Emp6Fr: TAoWFrame; { +0110 }
    Emp7Fr: TAoWFrame; { +0114 }
    Emp8Fr: TAoWFrame; { +0118 }
    Emp1Chk: TAoWFrame; { +011C }
    Emp2Chk: TAoWFrame; { +0120 }
    Emp3Chk: TAoWFrame; { +0124 }
    Emp4Chk: TAoWFrame; { +0128 }
    Emp5Chk: TAoWFrame; { +012C }
    Emp6Chk: TAoWFrame; { +0130 }
    Emp7Chk: TAoWFrame; { +0134 }
    Emp8Chk: TAoWFrame; { +0138 }
    PartyIPnl: TAOWPanel; { +013C }
    PartyILbl: TAOWLabel; { +0140 }
    Center: TAOWButton; { +0144 }
    Help: TAOWButton; { +0148 }
    PPrev: TAOWButton; { +014C }
    PMove: TAOWButton; { +0150 }
    PNext: TAOWButton; { +0154 }
    PControlPnl: TAOWPanel; { +0158 }
    PGuard: TAOWCheckBox; { +015C }
    AoWFrame2: TAoWFrame; { +0160 }
    PartyB2Pbl: TAOWPanel; { +0164 }
    AoWFrame1: TAoWFrame; { +0168 }
    Translator: TIvTranslator; { +016C }
    PartyActionLbl1: TAOWLabel; { +0170 }
    PartyActionLbl2: TAOWLabel; { +0174 }
    public
    F_ControlWin_178: Byte;
    F_ControlWin_179: array[0..2] of Byte;
    procedure CWMinIconClick;  { draft }
    procedure CloseClick(A1: Integer);  { draft }
    procedure ControlWindowResize;  { draft }
    procedure Unit1FrameMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure Unit1ChkChange(A1: Integer);  { draft }
    procedure CheckStart;  { draft }
    procedure CheckEnd;  { draft }
    procedure Unit1ChkMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure CenterClick;  { draft }
    procedure Unit1FramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure HelpClick;  { draft }
    procedure PPrevClick;  { draft }
    procedure PNextClick;  { draft }
    procedure PMoveClick;  { draft }
    procedure PGuardChange;  { draft }
  end;


implementation

procedure TControlWin.CWMinIconClick;
begin end;

procedure TControlWin.CloseClick(A1: Integer);
begin end;

procedure TControlWin.ControlWindowResize;
begin end;

procedure TControlWin.Unit1FrameMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TControlWin.Unit1ChkChange(A1: Integer);
begin end;

procedure TControlWin.CheckStart;
begin end;

procedure TControlWin.CheckEnd;
begin end;

procedure TControlWin.Unit1ChkMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TControlWin.CenterClick;
begin end;

procedure TControlWin.Unit1FramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure TControlWin.HelpClick;
begin end;

procedure TControlWin.PPrevClick;
begin end;

procedure TControlWin.PNextClick;
begin end;

procedure TControlWin.PMoveClick;
begin end;

procedure TControlWin.PGuardChange;
begin end;


end.
