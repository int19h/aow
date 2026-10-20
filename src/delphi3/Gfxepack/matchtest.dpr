program matchtest;

{ Host program for the byte-matching of Gfxepack.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  GFXDiag in 'GFXDiag.pas',
  GFXE in 'GFXE.pas';

var
  Pal: TGFXEPalette;
  DS: TDataSurface;
  DIB: TDIBSurface;
  D08: TDIB08Surface;
  D16: TDIB16Surface;
  D24: TDIB24Surface;
  D32: TDIB32Surface;
  GDI: TGDISurface;
  DDS: TDDrawSurface;
  RL: TRectangleList;
  RC: TRectangle;
  DP: TDrawPanel;
  OD: TOpenImageFileDialog;
  DML: TDisplayModeList;
  BT: TBlendTable;
  BT5: TBlendTable5Bit;
  BTL: TBlendTableList;
  LBT: TLookupBlendTableCollection100;
  SD, SD2: TSurfaceDesc;
  R: TRect;
  M: TMemoryStream;
  S: TSurface;
  Dlg: TGFXEDiagnoseDlg;
  P: Pointer;
  I, J, K, L: Integer;
  DDSD: TDDSurfaceDesc;
  Surf: IDirectDrawSurface;
  Flag: Boolean;
  Str: string;
begin
  M := TMemoryStream.Create;
  Pal := TGFXEPalette.Create;
  Pal.LoadFromStream(M);
  Pal.SaveToStream(M);
  Pal.Assign(Pal);
  Writeln(Pal.GetEntry(0).R, Pal.Remap(pfRGB555), Pal.GetNearestColor(0), Pal.Compare(Pal));
  DS := TDataSurface.Create(1, 1, pfRGB565, Pal);
  DS := TDataSurface.CreateFromSurface(DS, nil);
  DS.CaptureSurface(DS, @R);
  DS.SetPalette(Pal);
  DS.Free;
  DIB := TDIBSurface.Create;
  Writeln(Integer(DIB.GetBITMAPINFO), Integer(DIB.GetBITMAPINFOHEADER), DIB.Setup(1, 1, pfRGB24, nil));
  DIB.Clear;
  DIB.SaveToBMP24('x');
  DIB.Free;
  D08 := TDIB08Surface.Create(1, 1, Pal);
  D08.SetPalette(Pal);
  D08.Free;
  D16 := TDIB16Surface.Create(1, 1, pfRGB565);
  D16.PixelFormatID := pfRGB555;
  D16.Free;
  D24 := TDIB24Surface.Create(1, 1);
  Writeln(Integer(D24.GetBMPInfo));
  D24.Free;
  D32 := TDIB32Surface.Create(1, 1);
  D32.Free;
  GDI := TGDISurface.Create(0);
  GDI.Free;
  DDS := TDDrawSurface.Create;
  Writeln(DDS.CreateSurface(1, 1, pfRGB565, [cfVideoMemory]), DDS.Lost, DDS.Restore, DDS.AsyncCls(0));
  DDS.Free;
  RC := TRectangle.Create(0, 0, 1, 1);
  RC.Free;
  RC := TRectangle.CreateRect(R);
  RL := TRectangleList.Create;
  RL.Add(RC);
  Writeln(Integer(RL.Rectangles[0]));
  RL.Free;
  DP := TDrawPanel.Create(nil);
  DP.Free;
  OD := TOpenImageFileDialog.Create(nil);
  OD.Free;
  DML := TDisplayModeList.Create;
  DML.Add(1, 1, 1);
  Writeln(DML.Count, Integer(DML.Items[0]));
  DML.Delete(0);
  DML.Clear;
  DML.Free;
  BT5 := TBlendTable5Bit.Create;
  BT5.Initialize(5, nil);
  BT := BT5.Copy;
  BT.Assign(BT5);
  BTL := TBlendTableList.Create;
  BTL.Add(BT);
  Writeln(BTL.Count, Integer(BTL.Tables[0]));
  BTL.Delete(0);
  BTL.Clear;
  BTL.Free;
  LBT := TLookupBlendTableCollection100.Create;
  Writeln(LBT.GenerateLookupTables(5, GenerateAlphaBlendTable, 3), Integer(LBT.LookupTables[0]));
  LBT.Clear;
  LBT.Free;
  Dlg := TGFXEDiagnoseDlg.Create(nil);
  Dlg.FormCreate(nil);
  Dlg.Free;
  Str := GetImageFilesFilter;
  Writeln(ValidImageFile(Str), LoadImageFile(Str, SD, 0, 0), Integer(CreateSurfaceFromImageFile(Str)), GetImageFilePixelFormat(Str));
  RegisterImageFileClasses([TImageFile]);
  P := nil;
  FPBltRect(P, P, 0, 0, 0, 0);
  RegisterBltRect(P, P, 0, 0, 0, 0);
  RepMovsdBltRect(P, P, 0, 0, 0, 0);
  BltRect(P, P, 0, 0, 0, 0);
  GetOptimalGFXESettings(False);
  RegisterBltProc(FPBltRect, 'x');
  Writeln(BltSDRectClipped(SD, R, SD2, 0, 0));
  BltTransparent565(P, P, 0, 0, 0, 0);
  BltTransparent555(P, P, 0, 0, 0, 0);
  BltColorKey16(P, P, 0, 0, 0, 0, 0);
  Writeln(BltSprite16(SD, R, SD2, 0, 0, 0), BltSpriteClipped16(SD, R, SD2, 0, 0, 0));
  BltStretched16(P, P, P, 0, 0, 0);
  Writeln(ColorFillSD(R, 0, SD), RDTSC);
  FillInt(P^, 0, 0);
  FillTrippleByte(P^, 0, 0);
  FillWord(P^, 0, 0);
  Writeln(GetPixelInfo(SD, 0, 0), MASKtoPFID(16, 1, 2, 3, 4), PFIDtoMASK(1, I, J, K, L));
  CreateSDfromSD(SD, R, SD2);
  RL := GetSurfaceRectangles(SD, 0, nil, nil);
  MinimizeTransparentRect(SD, R, 0, R);
  MinimizeInvTransparentRect(SD, R, 0, R);
  DrawLine16(0, 0, 1, 1, 0, 0, SD);
  DrawLine(0, 0, 1, 1, 0, 0, SD);
  RemapSurface16to16(P, P, P, 0, 0, 0, 0);
  RemapSurface16to08(P, P, P, 0, 0, 0, 0);
  RemapSurface16to32(P, P, P, 0, 0, 0, 0);
  RemapSurface555to32(P, P, 0, 0, 0, 0);
  RemapSurface565to32(P, P, 0, 0, 0, 0);
  RemapSurface555to565(P, P, 0, 0, 0, 0);
  RemapSurface565to555(P, P, 0, 0, 0, 0);
  RemapSurface24to565(P, P, 0, 0, 0, 0);
  RemapSurface24to555(P, P, 0, 0, 0, 0);
  RemapSurface555to24(P, P, 0, 0, 0, 0);
  RemapSurface565to24(P, P, 0, 0, 0, 0);
  RemapSurface32to565(P, P, 0, 0, 0, 0);
  RemapSurface32to555(P, P, 0, 0, 0, 0);
  RemapSurface08to565(P, P, 0, 0, 0, 0, Pal);
  RemapSurface08to555(P, P, 0, 0, 0, 0, Pal);
  RemapSurface08to24(P, P, 0, 0, 0, 0, Pal);
  S := nil;
  Writeln(RemapSurfacePart(SD, 0, 0, 1, 1, SD2, 0, 0), RemapSurface(S, S), Color2PixelInfo(0, 0, Pal), PixelInfo2Color(0, 0, Pal), RemapPixelInfo(0, 0, Pal, 0, Pal));
  Writeln(SaveSurfaceDescToBMP24(SD, R, 'x'), DDSDtoSurfaceDesc(DDSD, SD));
  GenerateAlphaBlendTable(BT, 0.5);
  GenerateIntensityBlendTable(BT, 0.5);
  GenerateShadowBlendTable(BT, 0.5);
  GenerateBrightenBlendTable(BT, 0.5);
  BlendSurface555(P, P, 0, 0, 0, 0, P);
  BlendSurface565(P, P, 0, 0, 0, 0, P);
  BlendColorKey555(P, P, 0, 0, 0, 0, 0, P);
  BlendColorKey565(P, P, 0, 0, 0, 0, 0, P);
  BlendStretched555(P, P, P, 0, 0, 0, P);
  BlendStretched565(P, P, P, 0, 0, 0, P);
  Writeln(GetErrorMsg(0));
  SaveGFXESettingsToStream(M);
  LoadGFXESettingsFromStream(M);
  WriteGFXESettingsToRegistry('x');
  ReadGFXESettingsFromRegistry('x');
  Flag := DisplayModeSupported(1, 1, 1);
  ListDisplayModes(DML, 0, 0, 0);
  ForceOptimal16BitPixelFormatID(0);
  Surf := nil;
  Writeln(GetPrimarySurfacePFID, Flag, GetOptimalPixelFormatID(16), DDStoPFID(Surf), DirectDrawActivated, Integer(DD), MMXsupport, GetElapsedMilliSeconds, GetElapsedMicroSeconds);
  Register;
  Pal.Free;
  M.Free;
end.
