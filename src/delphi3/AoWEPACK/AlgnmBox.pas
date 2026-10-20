unit AlgnmBox;

{ Draft declarations of AlgnmBox, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAlignmentBox = class;


  { TAlignmentBox (instance size 372, VMT 557FEB3C) }
  TAlignmentBox = class(TComboBox)
  public
    F_AlignmentBox_170: Byte;
    F_AlignmentBox_171: Byte;
    F_AlignmentBox_172: Byte;
    F_AlignmentBox_173: array[0..0] of Byte;
    procedure Loaded; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure GenerateItems;  { draft }
    procedure SetAlignments(A1: Byte; A2: Integer);  { draft }
    procedure SetAlignment(A1: Byte);  { draft }
    procedure Change;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TAlignmentBox.Create(AOwner: Classes.TComponent);
begin end;

procedure TAlignmentBox.GenerateItems;
begin end;

procedure TAlignmentBox.SetAlignments(A1: Byte; A2: Integer);
begin end;

procedure TAlignmentBox.SetAlignment(A1: Byte);
begin end;

procedure TAlignmentBox.Change;
begin end;

procedure TAlignmentBox.Loaded;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
