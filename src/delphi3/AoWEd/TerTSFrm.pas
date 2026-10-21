unit TerTSFrm;

{ Draft declarations of TerTSFrm, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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
    function vmt80(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer; virtual;  { +080 draft }
  end;


implementation

function TTerrainTypeSelectionForm.vmt80(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer;
begin Result := 0; end;


end.
