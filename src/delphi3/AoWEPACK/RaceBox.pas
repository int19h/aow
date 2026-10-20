unit RaceBox;

{ Draft declarations of RaceBox, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TRaceBox = class;


  { TRaceBox (instance size 384, VMT 558006C8) }
  TRaceBox = class(TComboBox)
  public
    F_RaceBox_170: array[0..11] of Byte;
    F_RaceBox_17C: Integer;
    procedure Loaded; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure GenerateItems(A1: Integer; A2: Integer);  { draft }
    procedure SetRace(A1: Integer);  { draft }
    procedure Change;  { draft }
    procedure SetRaces(A1: Integer);  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TRaceBox.Create(AOwner: Classes.TComponent);
begin end;

procedure TRaceBox.GenerateItems(A1: Integer; A2: Integer);
begin end;

procedure TRaceBox.SetRace(A1: Integer);
begin end;

procedure TRaceBox.Change;
begin end;

procedure TRaceBox.SetRaces(A1: Integer);
begin end;

procedure TRaceBox.Loaded;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
