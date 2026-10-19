program ui;

{ Host program for byte-matching the ImgLComp and EResGrid units: it references every class and
  every non-virtual method so that the linker keeps them (the program is never run). Build with
  the original compiler from this directory:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -U.. -E<outdir> -N<outdir> ui.dpr
  -GD writes ui.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  Controls,
  Grids,
  Forms,
  ImageLib,
  Engine,
  ImgLComp,
  EResGrid;

var
  G: TDrawImageGrid;
  LG: TImageListGrid;
  IG: TImageLibGrid;
  P: TDrawImagePanel;
  LP: TLibraryImagePanel;
  RG: TECustomResourceGrid;
  EG: TEResourceGrid;
  L: TList;
  I: Integer;
  B: Boolean;
  R: TRect;
  O: TObject;

begin
  G := TDrawImageGrid.Create(nil);
  G.SetSelectEnabledSilent(True);
  B := G.CutCell;
  B := G.CopyCell;
  B := G.PasteCell;
  B := G.DeleteCell;
  B := G.SingleCellSelected;
  G.CellCount := 3;
  G.RowCount := G.RowCount;
  G.ColCount := G.ColCount;
  G.MinRowCount := 1;
  G.MinColCount := 1;
  G.MaxRowCount := 1;
  G.MaxColCount := 1;
  G.SelectColor := 0;
  G.SelectionEnabled := True;
  G.ShowGridIndex := True;
  G.Free;

  LG := TImageListGrid.Create(nil);
  L := TList.Create;
  LG.GridList := L;
  LG.GenerateCellImageList;
  I := LG.GetSelectedGridListIndex;
  LG.Free;

  IG := TImageLibGrid.Create(nil);
  O := IG.GetSelectedImageLib;
  IG.DeleteSelectedImages;
  IG.ImageLibrary := nil;
  B := IG.CutCell;
  B := IG.CopyCell;
  B := IG.PasteCell;
  B := IG.DeleteCell;
  IG.Free;

  P := TDrawImagePanel.Create(nil);
  P.FocusColor := 0;
  P.ShowFocus := True;
  B := P.CutImage;
  B := P.CopyImage;
  B := P.PasteImage;
  B := P.DeleteImage;
  P.Free;

  LP := TLibraryImagePanel.Create(nil);
  LP.LibraryImage := nil;
  B := LP.CutImage;
  B := LP.CopyImage;
  B := LP.PasteImage;
  B := LP.DeleteImage;
  LP.Free;

  RG := TECustomResourceGrid.Create(nil);
  RG.Free;
  EG := TEResourceGrid.Create(nil);
  EG.Free;
  Register;
end.
