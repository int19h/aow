program matchtest;

{ Host program for the byte-matching of ILToolsP.dpl: it references every class and every
  non-virtual method so that the linker keeps them; it is linked, never run. Build from this
  directory with the original compiler into a directory with a short path (DCC32 crashes on
  long paths):
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -Q "-U..\AoWEPACK;..\HSEPack;..;..\Gfxepack;..\Ilpack;..\Dcpack;..\SoundP;..\Network;..\aowFXpck;..\aowInt;..\Localize"
      -O.. -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  ILSeqEd in 'ILSeqEd.pas',
  ILTools in 'ILTools.pas',
  ILToolsP in 'ILToolsP.pas',
  Str2Clip in 'Str2Clip.pas';

var
  C: TClass;
  P: Pointer;

procedure Use(C: TClass; P: Pointer);
begin
  Writeln(Integer(C), Integer(P));
end;

begin
  Use(ILSeqEd.TImageSequenceEditor, nil);
  Use(ILTools.TImageSequencer, nil);
  Use(ILTools.TSequenceLayerSelector, nil);
  Use(ILTools.TSequenceDisplayEditor, nil);
  Use(nil, @ILSeqEd.TImageSequenceEditor.GetImageSequenceList);
  Use(nil, @ILSeqEd.TImageSequenceEditor.SetImageSequenceList);
  Use(nil, @ILSeqEd.TImageSequenceEditor.FrameTableEditChange);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ILManagerComboBoxChange);
  Use(nil, @ILSeqEd.TImageSequenceEditor.LayerSpinUpdate);
  Use(nil, @ILSeqEd.TImageSequenceEditor.PlayBtnClick);
  Use(nil, @ILSeqEd.TImageSequenceEditor.PlayLoopedClick);
  Use(nil, @ILSeqEd.TImageSequenceEditor.SequenceDisplayEditorResizeBackSurface);
  Use(nil, @ILSeqEd.TImageSequenceEditor.SequenceDisplayEditorUpdateFrame);
  Use(nil, @ILSeqEd.TImageSequenceEditor.SequenceModeBoxChange);
  Use(nil, @ILSeqEd.TImageSequenceEditor.SequenceSpeedBoxChange);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ImageSequencerChange);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ImageSequencerCreateImageSequence);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ImageIndexSelectorDrawCell);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ImageIndexSelectorSelectCell);
  Use(nil, @ILSeqEd.TImageSequenceEditor.CloseLayerBtnClick);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ImageIndexSelectorDrawCell2);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ImageIndexSelectorSelectCell2);
  Use(nil, @ILSeqEd.TImageSequenceEditor.OpenLayerBtnClick);
  Use(nil, @ILSeqEd.TImageSequenceEditor.FormCreate);
  Use(nil, @ILSeqEd.TImageSequenceEditor.FormDestroy);
  Use(nil, @ILSeqEd.TImageSequenceEditor.SpeedButton2Click);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ShowModal);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ImageIndexSelectorKeyDown);
  Use(nil, @ILSeqEd.TImageSequenceEditor.ChangeColorClick);
  Use(nil, @ILTools.TImageSequencer.SetImageSequenceList);
  Use(nil, @ILTools.TImageSequencer.CurrentImageSequenceUpdated);
  Use(nil, @ILTools.TImageSequencer.SetCurrentImageSequence);
  Use(nil, @ILTools.TImageSequencer.SetCurrentSequenceIndex);
  Use(nil, @ILTools.TImageSequencer.AddSequenceLayer);
  Use(nil, @ILTools.TImageSequencer.DeleteSequenceLayer);
  Use(nil, @ILTools.TImageSequencer.IncreaseLayer);
  Use(nil, @ILTools.TImageSequencer.DecreaseLayer);
  Use(nil, @ILTools.TSequenceLayerSelector.SetImageSequencer);
  Use(nil, @ILTools.TSequenceLayerSelector.UpdateSettings);
  Use(nil, @ILTools.TSequenceLayerSelector.UpdateTabs);
  Use(nil, @ILTools.TSequenceDisplayEditor.SetImageSequencer);
  Use(nil, @ILTools.TSequenceDisplayEditor.UpdateSettings);
  Use(nil, @ILTools.Register);
  Use(nil, @ILToolsP.GetPackageInfoTable);
  Use(nil, @ILToolsP.PackageLoad);
  Use(nil, @ILToolsP.PackageUnload);
  Use(nil, @Str2Clip.CopyStreamToClipboard);
  Use(nil, @Str2Clip.PasteStreamFromClipboard);
  { per-package host additions: one include line per package (hosts\Pkg.inc), nothing else here }
end.
