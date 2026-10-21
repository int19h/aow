unit UnitFlt;

{ Draft declarations of UnitFlt, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, HeroCtrl, MapCtrl, UnitIGrd, UnitTabC;

type
  TUnitFloater = class;


  { TUnitFloater (instance size 512, VMT 00408588; $1FC FShowHeroes, $1FD FShowUnits) }
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
    FShowHeroes: Boolean; { $1FC }
    FShowUnits: Boolean; F_UnitFloater_1FE: array[0..1] of Byte; { $1FD }
    constructor Create(AOwner: Classes.TComponent); override;
    procedure ResetSelection;
    procedure SetShowHeroes(Value: Boolean);
    procedure SetShowUnits(Value: Boolean);
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


procedure TUnitFloater.ResetSelection;
begin
  SetShowHeroes(False);
  SetShowUnits(True);
  HeroControlGrid.SelectionEnabled := False;
  UnitSelectionGrid.SelectionEnabled := False;
  UnitTabControl.FSelectionControl.Reset;
end;

procedure TUnitFloater.SetShowHeroes(Value: Boolean);
begin
  FShowHeroes := Value;
  HeroSelectionSheet.TabVisible := Value and FShowUnits;
  UnitSelectionSheet.TabVisible := Value and FShowUnits;
  if not Value then
    if FShowUnits then MainPageControl.ActivePage := UnitSelectionSheet
    else MainPageControl.ActivePage := nil
  else if not FShowUnits then MainPageControl.ActivePage := HeroSelectionSheet
  else MainPageControl.ActivePage := UnitSelectionSheet;
end;

procedure TUnitFloater.SetShowUnits(Value: Boolean);
begin
  FShowUnits := Value;
  UnitSelectionSheet.TabVisible := Value and FShowHeroes;
  HeroSelectionSheet.TabVisible := Value and FShowHeroes;
  if not Value then
    if FShowHeroes then MainPageControl.ActivePage := HeroSelectionSheet
    else MainPageControl.ActivePage := nil
  else MainPageControl.ActivePage := UnitSelectionSheet;
end;

end.
