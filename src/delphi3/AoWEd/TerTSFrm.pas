unit TerTSFrm;

{ Draft declarations of TerTSFrm, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  TTerrainTypeSelectionForm $1F4 bytes; $1F0 is the terrain selector. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, TerCBox;

type
  TTerrainTypeSelectionForm = class;


  { TTerrainTypeSelectionForm (instance size 500, VMT 004076D8) }
  TTerrainTypeSelectionForm = class(TForm)
  public
    published
    OKBtn: TButton; { +01DC }
    CancelBtn: TButton; { +01E0 }
    Panel1: TPanel; { +01E4 }
    Label1: TLabel; { +01E8 }
    Label2: TLabel; { +01EC }
    TerrainComboBox: TTerrainComboBox; { +01F0 }
    public
    function GetTerrainType: Shortint;
    constructor CreateSelection(AOwner: TComponent; AEngine: THSEngine; TerrainType: Shortint; Mode: TTerrainComboBoxMode); virtual; { +080 }
  end;


implementation

constructor TTerrainTypeSelectionForm.CreateSelection(AOwner: TComponent; AEngine: THSEngine; TerrainType: Shortint; Mode: TTerrainComboBoxMode);
begin
  inherited Create(AOwner);
  TerrainComboBox.HexagonSpriteEngine := THexagonSpriteEngine(AEngine.FComponent);
  TerrainComboBox.TerrainType := TerrainType;
  TerrainComboBox.Mode := Mode;
end;


function TTerrainTypeSelectionForm.GetTerrainType: Shortint;
begin
  Result := TerrainComboBox.TerrainType;
end;

end.
