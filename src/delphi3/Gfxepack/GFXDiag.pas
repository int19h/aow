unit GFXDiag;

{ The GFXDiag unit of Gfxepack.dpl: the dialog GetOptimalGFXESettings shows while it times the
  blit routines. The form's components are plain published fields (no DFM is linked here);
  FormCreate fills the grid captions. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Grids;

type
  { GFXDiag.TGFXEDiagnoseDlg (instance size 512): +$1DC Panel1, Label1, Label2, Bevel1,
    GroupBox1, BltGrid, Button1, Button2, Image1. }
  TGFXEDiagnoseDlg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    GroupBox1: TGroupBox;
    BltGrid: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
  end;

var
  GFXEDiagnoseDlg: TGFXEDiagnoseDlg;

implementation

procedure TGFXEDiagnoseDlg.FormCreate(Sender: TObject);
begin
  with BltGrid do
  begin
    Row := 10;
    Cells[0, 0] := 'Blt Mode';
    Cells[0, 1] := 'QWord Aligned';
    Cells[0, 2] := 'DWord Aligned';
    Cells[0, 3] := 'Word Aligned';
    Cells[0, 4] := 'Miss Aligned';
    Cells[0, 5] := 'QWord Aligned (small)';
    Cells[0, 6] := 'DWord Aligned (small)';
    Cells[0, 7] := 'Word Aligned (small)';
    Cells[0, 8] := 'Miss Aligned (small)';
    Cells[1, 0] := 'Blt Routine';
    Cells[2, 0] := 'Bandwidth';
  end;
end;

end.
