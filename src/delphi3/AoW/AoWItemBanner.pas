unit AoWItemBanner;

{ Draft declarations of AoWItemBanner, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenu, AoWImage, AoWLabel, AoWListBox, AoWVScroll, aowUserDrawBox;

type
  TItemBanner = class;


  { TItemBanner (instance size 120, VMT 00406950) }
  TItemBanner = class(TDataModule)
  public
    published
    ItemNameLbl: TAOWLabel; { +0044 }
    IBannerPopup: TAOWMenu; { +0048 }
    AttackIcon: TAOWImage; { +004C }
    DefenseIcon: TAOWImage; { +0050 }
    DamageIcon: TAOWImage; { +0054 }
    ResistanceIcon: TAOWImage; { +0058 }
    Attack: TAOWLabel; { +005C }
    Defense: TAOWLabel; { +0060 }
    Damage: TAOWLabel; { +0064 }
    Resistance: TAOWLabel; { +0068 }
    DrawBox: TaowUserDrawBox; { +006C }
    AbLB: TAOWListBox; { +0070 }
    AbVSB: TAOWVScrollBar; { +0074 }
    public
    procedure IBannerPopupShow;  { draft }
    procedure IBannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DrawBoxPreDraw(A1: Integer; A2: Integer);  { draft }
  end;


implementation

procedure TItemBanner.IBannerPopupShow;
begin end;

procedure TItemBanner.IBannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TItemBanner.DrawBoxPreDraw(A1: Integer; A2: Integer);
begin end;


end.
