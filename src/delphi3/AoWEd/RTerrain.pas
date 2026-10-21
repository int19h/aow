unit RTerrain;

{ Draft declarations of RTerrain, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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
    procedure TerrainComboBoxChange;  { draft }
    procedure FormCreate;  { draft }
    procedure DecorationComboBoxChange;  { draft }
  end;


implementation

procedure TTerrainResourceEditForm.TerrainComboBoxChange;
begin end;

procedure TTerrainResourceEditForm.FormCreate;
begin end;

procedure TTerrainResourceEditForm.DecorationComboBoxChange;
begin end;


end.
