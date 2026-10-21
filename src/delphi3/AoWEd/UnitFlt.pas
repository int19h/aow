unit UnitFlt;

{ Draft declarations of UnitFlt, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, HeroCtrl, MapCtrl, UnitIGrd, UnitTabC;

type
  TUnitFloater = class;


  { TUnitFloater (instance size 512, VMT 00408588) }
  TUnitFloater = class(TForm)
  public
    published
    MainPageControl: TPageControl; { +01DC }
    UnitSelectionSheet: TTabSheet; { +01E0 }
    UnitTabControl: TUnitTabControl; { +01E4 }
    UnitSelectionGrid: TUnitIndexGrid; { +01E8 }
    HeroSelectionSheet: TTabSheet; { +01EC }
    HeroControlGrid: THeroControlGrid; { +01F0 }
    MapControl: TAoWMapControl; { +01F4 }
    Translator: TIvTranslator; { +01F8 }
    public
    F_UnitFloater_1FC: Byte;
    F_UnitFloater_1FD: array[0..2] of Byte;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure HeroControlGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure HeroSelectionSheetEnter;  { draft }
    procedure FormShow;  { draft }
    procedure MapControlActivateHSM;  { draft }
    procedure MapControlDeactivateHSM;  { draft }
  end;


var
  UnitFloater: TUnitFloater;

implementation

constructor TUnitFloater.Create(AOwner: Classes.TComponent);
begin end;

procedure TUnitFloater.HeroControlGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitFloater.HeroSelectionSheetEnter;
begin end;

procedure TUnitFloater.FormShow;
begin end;

procedure TUnitFloater.MapControlActivateHSM;
begin end;

procedure TUnitFloater.MapControlDeactivateHSM;
begin end;


end.
