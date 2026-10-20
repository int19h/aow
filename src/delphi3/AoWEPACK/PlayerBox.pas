unit PlayerBox;

{ Draft declarations of PlayerBox, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TPlayerComboBox = class;


  { TPlayerComboBox (instance size 372, VMT 55800248) }
  TPlayerComboBox = class(TComboBox)
  public
    F_PlayerComboBox_170: array[0..3] of Byte;
    procedure Loaded; override;
    procedure GenerateItems;  { draft }
    procedure SetPlayerIndex(A1: Integer);  { draft }
    procedure Change;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

procedure TPlayerComboBox.GenerateItems;
begin end;

procedure TPlayerComboBox.SetPlayerIndex(A1: Integer);
begin end;

procedure TPlayerComboBox.Change;
begin end;

procedure TPlayerComboBox.Loaded;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
