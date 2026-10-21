unit AoWWorldMap;

{ Draft declarations of AoWWorldMap, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWBookWindow, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWVScroll;

type
  TWorldMap = class;
  TFileTime = class;


  { TWorldMap (instance size 364, VMT 0041B5B8) }
  TWorldMap = class(TDataModule)
  public
    published
    MemoL: TAOWMemo; { +0044 }
    PicR: TAOWImage; { +0048 }
    WorldPnl: TAOWPanel; { +004C }
    Path1: TAOWImage; { +0050 }
    Path2: TAOWImage; { +0054 }
    Path3: TAOWImage; { +0058 }
    PPawn: TAOWImage; { +005C }
    EPawn: TAOWImage; { +0060 }
    DescLbl: TAOWLabel; { +0064 }
    Back: TAOWButton; { +0068 }
    Next: TAOWButton; { +006C }
    Cancel: TAOWButton; { +0070 }
    BookStart: TAOWButton; { +0074 }
    LabelL: TAOWLabel; { +0078 }
    MemoR: TAOWMemo; { +007C }
    LabelR: TAOWLabel; { +0080 }
    PicL: TAOWImage; { +0084 }
    BookWin: TAoWBookWindow; { +0088 }
    InfoPnl: TAOWPanel; { +008C }
    Elves: TAOWLabel; { +0090 }
    Halflings: TAOWLabel; { +0094 }
    Goblins: TAOWLabel; { +0098 }
    Orcs: TAOWLabel; { +009C }
    Dwarves: TAOWLabel; { +00A0 }
    Undead: TAOWLabel; { +00A4 }
    Highmen: TAOWLabel; { +00A8 }
    Lizardmen: TAOWLabel; { +00AC }
    DarkElves: TAOWLabel; { +00B0 }
    VoW: TAOWLabel; { +00B4 }
    ElvenC: TAOWLabel; { +00B8 }
    IoLG: TAOWLabel; { +00BC }
    Deepmir: TAOWLabel; { +00C0 }
    Aldor: TAOWLabel; { +00C4 }
    Serpent: TAOWLabel; { +00C8 }
    Blackwater: TAOWLabel; { +00CC }
    Skull: TAOWLabel; { +00D0 }
    Sylvanus: TAOWLabel; { +00D4 }
    Pass: TAOWLabel; { +00D8 }
    Arcalot: TAOWLabel; { +00DC }
    Flowershire: TAOWLabel; { +00E0 }
    Sobek: TAOWLabel; { +00E4 }
    Steppe: TAOWLabel; { +00E8 }
    Bronnam: TAOWLabel; { +00EC }
    UC: TAOWLabel; { +00F0 }
    Woods: TAOWLabel; { +00F4 }
    Burbatak: TAOWLabel; { +00F8 }
    QuitBtn: TAOWButton; { +00FC }
    ShowBtn: TAOWButton; { +0100 }
    SelectLbl: TAOWLabel; { +0104 }
    AlliesLnl: TAOWLabel; { +0108 }
    Frame: TAOWPanel; { +010C }
    Azrac: TAOWLabel; { +0110 }
    StarImg: TAOWImage; { +0114 }
    Terstar: TAOWLabel; { +0118 }
    HeroPnl: TAoWFrame; { +011C }
    Ally1Pnl: TAoWFrame; { +0120 }
    Ally2Pnl: TAoWFrame; { +0124 }
    Ally3Pnl: TAoWFrame; { +0128 }
    SetBtn: TAOWButton; { +012C }
    Translator: TIvTranslator; { +0130 }
    leftSB: TAOWVScrollBar; { +0134 }
    rightSB: TAOWVScrollBar; { +0138 }
    public
    F_WorldMap_13C: Integer;
    F_WorldMap_140: Integer;
    F_WorldMap_144: Integer;
    F_WorldMap_148: Integer;
    F_WorldMap_14C: Integer;
    F_WorldMap_150: Integer;
    F_WorldMap_154: Integer;
    F_WorldMap_158: Byte;
    F_WorldMap_159: array[0..14] of Byte;
    F_WorldMap_168: Byte;
    F_WorldMap_169: array[0..2] of Byte;
    procedure BackClick;  { draft }
    procedure NextStartClick;  { draft }
    procedure WorldPnlUpdate;  { draft }
    procedure Path1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure Path2MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure Path3MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure CancelClick;  { draft }
    procedure PPawnMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure PPawnMouseMove(A1: Integer);  { draft }
    procedure Path1MouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure Path2MouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure Path3MouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure WorldPnlMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure BookStartClick;  { draft }
    procedure BookWinAnimDone;  { draft }
    procedure BookWinShow;  { draft }
    procedure BookWinUpdate;  { draft }
    procedure ShowBtnClick;  { draft }
    procedure QuitBtnClick;  { draft }
    procedure StarImgUpdate;  { draft }
    procedure StarImgDraw(A1: Integer; A2: Integer);  { draft }
    procedure Ally1PnlPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure Ally2PnlPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure Ally3PnlPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure HeroPnlPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure SetBtnClick;  { draft }
    procedure BookWinHide;  { draft }
  end;

  { TFileTime (instance size 12, VMT 0041EB14) }
  TFileTime = class(TObject)
  public
    FTime: TDateTime; { $04; 0041F71B }
  end;


implementation

procedure TWorldMap.BackClick;
begin end;

procedure TWorldMap.NextStartClick;
begin end;

procedure TWorldMap.WorldPnlUpdate;
begin end;

procedure TWorldMap.Path1MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TWorldMap.Path2MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TWorldMap.Path3MouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TWorldMap.CancelClick;
begin end;

procedure TWorldMap.PPawnMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TWorldMap.PPawnMouseMove(A1: Integer);
begin end;

procedure TWorldMap.Path1MouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWorldMap.Path2MouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWorldMap.Path3MouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWorldMap.WorldPnlMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWorldMap.BookStartClick;
begin end;

procedure TWorldMap.BookWinAnimDone;
begin end;

procedure TWorldMap.BookWinShow;
begin end;

procedure TWorldMap.BookWinUpdate;
begin end;

procedure TWorldMap.ShowBtnClick;
begin end;

procedure TWorldMap.QuitBtnClick;
begin end;

procedure TWorldMap.StarImgUpdate;
begin end;

procedure TWorldMap.StarImgDraw(A1: Integer; A2: Integer);
begin end;

procedure TWorldMap.Ally1PnlPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TWorldMap.Ally2PnlPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TWorldMap.Ally3PnlPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TWorldMap.HeroPnlPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TWorldMap.SetBtnClick;
begin end;

procedure TWorldMap.BookWinHide;
begin end;


end.
