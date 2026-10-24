unit UnitFlt;

{ Draft declarations of UnitFlt, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, HeroCtrl, MapCtrl, UnitIGrd, UnitTabC;

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
    published procedure HeroControlGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean); public
    published procedure HeroSelectionSheetEnter; public
    published procedure FormShow; public
    published procedure MapControlActivateHSM; public
    published procedure MapControlDeactivateHSM; public
  end;


var
  UnitFloater: TUnitFloater;

implementation

constructor TUnitFloater.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  ResetSelection;
end;

procedure TUnitFloater.HeroControlGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  UnitTabControl.FSelectionControl.SetSelectedHero(HeroControlGrid.GetHero(HeroControlGrid.ImageIndex(ACol, ARow)));
  HeroControlGrid.SelectionEnabled := True;
end;

procedure TUnitFloater.HeroSelectionSheetEnter;
begin
  HeroControlGrid.SelectionEnabled := UnitTabControl.FSelectionControl.FSelectedHero <> nil;
end;

procedure TUnitFloater.FormShow;
begin
  if FShowHeroes then HeroControlGrid.SetAoWHSMap(AoWHSMap);
end;

procedure TUnitFloater.MapControlActivateHSM;
begin
  HeroControlGrid.SetAoWHSMap(AoWHSMap);
end;

procedure TUnitFloater.MapControlDeactivateHSM;
begin
  HeroControlGrid.SetAoWHSMap(nil);
end;


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
  else if FShowUnits then MainPageControl.ActivePage := UnitSelectionSheet
  else MainPageControl.ActivePage := HeroSelectionSheet;
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
