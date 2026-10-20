program matchtest;

{ Host program for the byte-matching of Ilpack.dpl (the ImageLib and HashTabU units and the
  editor units ILSpin, PerfDlg, ILEdGrid, ImgSetEd, SImgSEd, SubImgEd, ILEdForm): it only has to
  reference every class and every non-virtual method so that the linker keeps them. Build with
  the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -U..\Gfxepack -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  GFXE,
  HashTabU in 'HashTabU.pas',
  ImageLib in 'ImageLib.pas',
  ILSpin in 'ILSpin.pas',
  PerfDlg in 'PerfDlg.pas',
  ILEdGrid in 'ILEdGrid.pas',
  ImgSetEd in 'ImgSetEd.pas',
  SImgSEd in 'SImgSEd.pas',
  SubImgEd in 'SubImgEd.pas',
  ILEdForm in 'ILEdForm.pas';

var
  IHT: TIntegerHashTable256;
  SHT: TStringHashTable256;
  PM: TPaletteManager;
  LP: TLibraryImagePalette;
  IL: TCustomImageLibrary;
  LI: TLibraryImage;
  N: TImageNode;
  GI: TGrabInfo;
  M: TMemoryStream;
  R: TRect;
  SD: TSurfaceDesc;
  Pal: TGFXEPalette;
  Canvas: TCanvas;
  S: string;
  B: Boolean;

{ The editor units }

procedure HostE1;
var
  SB: TSpinButton;
  SE: TILSpinEdit;
  TB: TTimerSpeedButton;
begin
  SB := TSpinButton.Create(nil);
  SB.Free;
  SE := TILSpinEdit.Create(nil);
  SE.Value := SE.Value;
  SE.Free;
  TB := TTimerSpeedButton.Create(nil);
  TB.Free;
end;

procedure HostE2;
var
  PD: TPerformanceDlg;
  PT: TPerformanceThread;
begin
  PD := TPerformanceDlg.CreateDialog(nil, nil);
  PD.Free;
  PT := TPerformanceThread.Create(nil, nil);
  PT.Free;
end;

procedure HostE3;
var
  EG: TImageLibraryEditGrid;
begin
  EG := TImageLibraryEditGrid.Create(nil);
  EG.ImageIndex := EG.ImageIndex;
  Writeln(Integer(EG.SelectedImage[0]));
  EG.SelectAll;
  EG.UpdateSettings;
  EG.Free;
end;

procedure HostE4;
var
  ISE: TImageSettingsEditor;
begin
  ISE := TImageSettingsEditor.Create(nil);
  ISE.ImageLibrary := nil;
  ISE.ImageIndex := 0;
  ISE.UpdateSettings;
  ISE.ReferenceValueUpdate(nil);
  ISE.Free;
end;

procedure HostE5;
var
  SS: TSubImageSettingsEditor;
begin
  SS := TSubImageSettingsEditor.Create(nil);
  SS.ImageLibrary := nil;
  SS.ImageIndex := 0;
  SS.SubImageIndex := 0;
  SS.SelectImage(0, 0);
  SS.Free;
end;

procedure HostE6;
var
  SL: TSubImageList;
  SE: TSubImageEditor;
begin
  SL := TSubImageList.Create(nil);
  SL.Free;
  SE := TSubImageEditor.Create(nil);
  SE.ImageLibrary := nil;
  SE.ImageIndex := 0;
  SE.SubImageIndex := 0;
  Writeln(Integer(SE.SelectedImage));
  SE.UpdateSettings;
  SE.Free;
end;

procedure HostE7;
var
  EF: TImageLibraryEditForm;
  ED: TImageLibraryEditor;
begin
  EF := TImageLibraryEditForm.Create(nil);
  EF.ImageLibrary := nil;
  EF.Free;
  ED := TImageLibraryEditor.Create(nil, nil);
  ED.Free;
end;

procedure HostG1;
var
  I: TLibraryImage;
begin
  I := TImage16.Create(nil);
  I.Free;
  I := TPicture16.Create(nil);
  I.Free;
  I := TTransparentPicture16.Create(nil);
  I.Free;
  I := TSprite16.Create(nil);
  I.Free;
  I := TRLESprite16.Create(nil);
  I.Free;
  I := TTransparentRLESprite16.Create(nil);
  I.Free;
end;

procedure HostG2;
var
  I08: TImage08;
  P08: TPicture08;
  R08: TRLESprite08;
  BG: TBitMaskGrabInfo;
  BM: TBitMask;
  Sh: TShadow;
begin
  I08 := TImage08.Create(nil);
  I08.CreateLibraryImagePalette(nil);
  I08.Free;
  P08 := TPicture08.Create(nil);
  P08.AllocateDiscardableImageData(0, 0);
  P08.Free;
  R08 := TRLESprite08.Create(nil);
  R08.Free;
  BG := TBitMaskGrabInfo.Create;
  BG.Free;
  BM := TBitMask.Create(nil);
  BM.AllocateMaskData(0, 0);
  BM.Free;
  Sh := TShadow.Create(nil);
  Sh.Free;
end;

procedure HostG3;
var
  F: TImageLibraryFont;
  P: TImageLibraryPanel;
  DG: TImageDrawGrid;
  LG: TImageLibraryGrid;
  SL: TStringList;
  SD3: TSurfaceDesc;
  SI: TShowInfo;
begin
  F := TImageLibraryFont.Create(nil);
  F.Color := clRed;
  F.FontColorPaletteIndex := 1;
  Writeln(F.GetTextWidth('x'), F.GetTextHeight('x'));
  F.SetText(0, 0, 'x', SD3);
  F.SetTextCentered(0, 0, 'x', SD3);
  F.SetTextEx(0, 0, 'x', SD3, [stmCenter], SI);
  SL := TStringList.Create;
  ParseFontText('x', SL, F, 100);
  SL.Free;
  F.Free;
  P := TImageLibraryPanel.Create(nil);
  P.BltMode := bmNone;
  P.ScaleX := 1;
  P.ScaleY := 1;
  P.ImageIndex := 0;
  P.ImageLibrary := nil;
  P.Free;
  DG := TImageDrawGrid.Create(nil);
  DG.BltMode := bmNone;
  DG.SelectionEnabled := True;
  DG.FocusColor := clRed;
  DG.ScaleX := 1;
  DG.ScaleY := 1;
  DG.ShowGridIndex := True;
  DG.ColCount := DG.ColCount;
  DG.RowCount := DG.RowCount;
  DG.MinRowCount := 1;
  DG.MinColCount := 1;
  DG.MaxRowCount := 1;
  DG.MaxColCount := 1;
  DG.SelectIndex(0);
  DG.Free;
  LG := TImageLibraryGrid.Create(nil);
  LG.ImageLibrary := nil;
  LG.CreateSelectedIL.Free;
  LG.Free;
end;

procedure HostG4;
var
  ML: TILManagerList;
  Man: TImageLibraryManager;
  CB: TILManagerComboBox;
  LB: TILManagerListBox;
  Seq: TImageSequence;
  SL: TImageSequenceList;
  FT: TFrameTableList;
  Str: TMemoryStream;
  R4: TRect;
  SD4: TSurfaceDesc;
  C4: TCanvas;
  S4: string;
begin
  Str := TMemoryStream.Create;
  Man := TImageLibraryManager.Create(nil);
  ML := TILManagerList.Create(Man);
  Writeln(Integer(ML.GetIL(0)), Integer(ML.AddILFile('x')), Integer(ML.AddILManagerObject('x', nil)));
  ML.UnloadIL;
  Writeln(Integer(ML.LinkToIL('x')), ML.ReleaseIL('x'));
  ML.Free;
  Man.Clear;
  Man.UnloadIL([icDisk]);
  Man.ExecutePathSearch('x');
  Writeln(Integer(Man.LinkToIL([icDisk], 'x')));
  Man.ReleaseIL([icDisk], 'x');
  Man.SaveToStream(Str);
  Man.LoadFromStream(Str);
  Man.Free;
  CB := TILManagerComboBox.Create(nil);
  CB.ILManager := nil;
  CB.SubDirectory := 'x';
  CB.ImageLibraryName := CB.ImageLibraryName;
  CB.GenerateItems;
  CB.Free;
  LB := TILManagerListBox.Create(nil);
  LB.ILManager := nil;
  LB.SubDirectory := 'x';
  LB.ImageLibraryName := LB.ImageLibraryName;
  LB.GenerateItems;
  LB.Free;
  SL := TImageSequenceList.Create(nil, nil);
  Seq := TImageSequence.Create(SL);
  Seq := Seq.Copy(SL);
  Writeln(Integer(Seq.GetPreviewImage), Seq.GetTotalSequenceFrames, Seq.GetFrameIndex(0, 0),
    Seq.GetUnloopedFrameIndex(0));
  Seq.ImageLibraryName := 'x';
  Seq.SequenceMode := smNone;
  Seq.GetDimensions(R4);
  Seq.LinkToIL;
  Seq.ReleaseIL;
  Seq.SaveToStream(Str);
  Seq.LoadFromStream(Str);
  Seq.SaveToIniFile('x', nil);
  Seq.LoadFromIniFile('x', nil);
  Seq.Free;
  Writeln(SL.UsedIndexString, Integer(SL.GetLayerImageSequence(0, 0)), SL.ReduceCount);
  SL.DestroyItems;
  SL.LoadFromStream(Str);
  SL.SaveToStream(Str);
  SL.SaveToIniFile('x', nil);
  SL.LoadFromIniFile('x', nil);
  Writeln(Integer(SL.GetImageSequence(0)), SL.GetSubCount(0), SL.IndexOfSub(0, nil),
    Integer(SL.GetSubImageSequence(0, 0)));
  SL.SetImageSequence(0, nil);
  SL.Add(0, nil);
  SL.Delete(0, nil);
  SL.LinkToIL;
  SL.ReleaseIL;
  Writeln(SL.Animating, Integer(SL.GetPreviewImage), SL.Show(0, 0, 0, 0, SD4), SL.GetFramesCount(0));
  SL.GetDimensions(0, R4);
  SL.ShowLooped(0, 0, 0, 0, SD4);
  SL.ShowLoopedEx(0, 0, 0, 0, 0, SD4);
  SL.CopyToClipboard;
  SL.PasteFromClipboard;
  SL.Free;
  FT := TFrameTableList.Create;
  FT.Count := 1;
  FT.Capacity := 2;
  FT[0] := FT[0];
  Writeln(FT.Add(0), Integer(FT.Expand), FT.First, FT.IndexOf(0), FT.Last, FT.Remove(0),
    FT.Compare(FT));
  FT.Delete(0);
  FT.Exchange(0, 0);
  FT.Insert(0, 0);
  FT.Move(0, 0);
  FT.Pack;
  FT.Sort(nil);
  FT.LoadFromStream(Str);
  FT.SaveToStream(Str);
  FT.ItemString := FT.ItemString;
  FT.Clear;
  FT.Free;
  BltImageSequence(nil, 0, 0, 0, R4, 0, 0);
  BltImageSequenceEx(C4, nil, 0, R4, bmNone, 0, 0, 0, 0, False, R4);
  Writeln(UpdateImage(nil, nil));
  DrawImageLine(nil, 0, 0, 0, 0, 0, SD4);
  S4 := '';
  Str.Free;
end;

begin
  IHT := TIntegerHashTable256.Create;
  IHT.Free;
  SHT := TStringHashTable256.Create;
  SHT.Free;
  M := TMemoryStream.Create;
  PM := TPaletteManager.Create;
  Writeln(PM.Count, Integer(PM.Palettes[0]));
  PM.LoadFromStream(M);
  PM.SaveToStream(M);
  PM.Clear;
  PM.LinkToPalette(0);
  Pal := TGFXEPalette.Create;
  LP := PM.RegisterPalette(Pal);
  PM.UnregisterPalette(0);
  PM.Free;
  LP := TLibraryImagePalette.Create;
  LP.SaveToStream(M);
  LP.LoadFromStream(M);
  Writeln(Integer(LP.RemapPalette(0)));
  LP.Free;
  GI := TGrabInfo.Create;
  GI.Free;
  IL := TImageLibrary.Create(nil);
  Writeln(IL.ReduceCount);
  IL.UpdateImageItemSettings(0);
  IL.DisableOnChangeEvent;
  IL.EnableOnChangeEvent;
  IL.DisableReloading;
  IL.ReleaseDiscardableImageData;
  IL.LoadDiscardableImageData;
  IL.LoadOnDemand := False;
  IL.FileName := 'x';
  Writeln(IL.IsReference(0), Integer(IL.Get(0)), Integer(IL.GetSafe(0)), IL.ImageExist(0), IL.GetImageReference(0), IL.FullFileName);
  IL.SetImageReference(0, 0);
  IL.LoadFromFileStream('x', M);
  IL.CopyToClipboard;
  IL.PasteFromClipboard;
  IL.Delete(0);
  Writeln(IL.Remove(nil), IL.IndexOf(nil), Integer(IL.GetImage(0)));
  IL.SetImage(0, nil);
  IL.Insert(0, nil);
  IL.Add(nil);
  Writeln(IL.Empty);
  IL.Pack;
  Writeln(IL.GetSubCount(0), Integer(IL.GetSub(0, 0)), Integer(IL.GetSafeSub(0, 0)), Integer(IL.GetSubImage(0, 0)));
  IL.SetSubImage(0, 0, nil);
  IL.DeleteSub(0, 0);
  Writeln(IL.RemoveSub(0, nil), IL.IndexOfSub(0, nil), IL.SubImageExist(0, 0));
  IL.InsertSub(0, 0, nil);
  IL.AddSub(0, nil);
  IL.Count := 1;
  IL.Free;
  N := TImageNode.Create(nil);
  Writeln(Integer(N.GetImage(0)), Integer(N.GetSafeImage(0)), N.Add(nil), N.IndexOf(nil));
  N.UpdateDimensions;
  N.Insert(0, nil);
  N.Remove(nil);
  N.Delete(0);
  LI := N;
  LI.GetDimensions(R);
  LI.ShowClipped(0, 0, SD);
  N.Free;
  Writeln(Integer(GetLibraryImageClass(0)), LibraryImageClassCount, Integer(FindLibraryImageClass(0)));
  RegisterLibraryImageClasses([TImageNode]);
  LI := ReadImageFromStream(M, nil);
  WriteImageToStream(LI, M);
  LI := ReadImageFromStreamEx(M, M, nil);
  WriteImageToStreamEx(LI, M, M);
  BltLibraryImage(Canvas, LI, R, bmNone, 0, 0, 0, 0, B, R);
  Register;
  HostG1;
  HostG2;
  HostG3;
  HostG4;
  HostE1;
  HostE2;
  HostE3;
  HostE4;
  HostE5;
  HostE6;
  HostE7;
  M.Free;
end.
