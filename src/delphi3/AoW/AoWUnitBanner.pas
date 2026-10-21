unit AoWUnitBanner;

{ Draft declarations of AoWUnitBanner, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenu, AoWImage, AoWLabel, AoWListBox, AoWVScroll;

type
  TUnitBanner = class;


  { TUnitBanner (instance size 132, VMT 00403D84) }
  TUnitBanner = class(TDataModule)
  public
    published
    UnitNameLbl: TAOWLabel; { +0044 }
    AttackIcon: TAOWImage; { +0048 }
    DefenseIcon: TAOWImage; { +004C }
    MovesIcon: TAOWImage; { +0050 }
    DamageIcon: TAOWImage; { +0054 }
    ResistanceIcon: TAOWImage; { +0058 }
    HitsIcon: TAOWImage; { +005C }
    Attack: TAOWLabel; { +0060 }
    Defense: TAOWLabel; { +0064 }
    Moves: TAOWLabel; { +0068 }
    Damage: TAOWLabel; { +006C }
    Resistance: TAOWLabel; { +0070 }
    Hits: TAOWLabel; { +0074 }
    BannerPopup: TAOWMenu; { +0078 }
    AbLB: TAOWListBox; { +007C }
    AbVSB: TAOWVScrollBar; { +0080 }
    public
    procedure BannerPopupShow;  { draft }
    procedure AbLBUpdate;  { draft }
    procedure AbLBMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure BannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure AbLBMouseDown;  { draft }
  end;


var
  UnitBanner: TUnitBanner;

implementation

procedure TUnitBanner.BannerPopupShow;
begin end;

procedure TUnitBanner.AbLBUpdate;
begin end;

procedure TUnitBanner.AbLBMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitBanner.BannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TUnitBanner.AbLBMouseDown;
begin end;


end.
