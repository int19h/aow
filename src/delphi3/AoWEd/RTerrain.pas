unit RTerrain;

{ Draft declarations of RTerrain, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RMultiHx;

type
  TTerrainResourceEditForm = class;


  { TTerrainResourceEditForm (instance size 840, VMT 00406AAC) }
  TTerrainResourceEditForm = class(TMultiHexResourceEditForm)
  public
    published
    Panel10: TPanel; { +033C }
    Label10: TLabel; { +0340 }
    DecorationComboBox: TComboBox; { +0344 }
    public
    procedure TerrainComboBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DecorationComboBoxChange(Sender: TObject);
  end;


implementation

procedure TTerrainResourceEditForm.TerrainComboBoxChange(Sender: TObject);
var
  List: TTerrainList;
  I: Integer;
begin
  inherited TerrainComboBoxChange(Sender);
  if TerrainComboBox.TerrainType >= 0 then
  begin
    List := FResource.TerrainList;
    for I := 0 to List.Count - 1 do
      if List.Terrain[I] >= 0 then List.Terrain[I] := TerrainComboBox.TerrainType;
    TTerrainMOR(FResource).TerrainType := Byte(TerrainComboBox.TerrainType);
  end;
end;

procedure TTerrainResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  DecorationComboBox.Items := FEngine.HSSet.DecorationTypes;
  DecorationComboBox.ItemIndex := TTerrainMOR(FResource).DecorationType;
end;

procedure TTerrainResourceEditForm.DecorationComboBoxChange(Sender: TObject);
begin
  TTerrainMOR(FResource).DecorationType := DecorationComboBox.ItemIndex;
end;


end.
