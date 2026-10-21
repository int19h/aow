unit EUnitGFX;

{ Unit graphics editor recovered from AoWEd.exe; original range and overflow checks. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWREFrm, Buttons, ILTools, SpinEdit;

type
  { Declaration-only field type from Vcladdon.dpl (instance size 516). }
  TEditStringGrid = class(TStringGrid)
  private
    F_External: array[0..15] of Byte;
  end;

  TUnitGFXResourceEditForm = class;
  TUnitGFXResourceEditor = class;


  { TUnitGFXResourceEditForm (instance size $2FC, VMT 0040E2F8; $2F8 FResource) }
  TUnitGFXResourceEditForm = class(TAoWResourceEditForm)
  public
    published
    Panel2: TPanel; { +01FC }
    Windows16DC1: TWindows16DC; { +0200 }
    Panel3: TPanel; { +0204 }
    UnitGFXNameEdit: TEdit; { +0208 }
    PageControl1: TPageControl; { +020C }
    FramesSheet: TTabSheet; { +0210 }
    FaceSheet: TTabSheet; { +0214 }
    Panel4: TPanel; { +0218 }
    Panel5: TPanel; { +021C }
    Panel8: TPanel; { +0220 }
    OpenLayerBtn: TSpeedButton; { +0224 }
    CloseLayerBtn: TSpeedButton; { +0228 }
    ImageIndexSelector: TEditStringGrid; { +022C }
    GroupBox4: TGroupBox; { +0230 }
    FaceImagePanel: TImageLibraryPanel; { +0234 }
    FaceImageLibraryPreviewGrid: TImageLibraryGrid; { +0238 }
    FaceILManagerComboBox: TILManagerComboBox; { +023C }
    FaceIndexSpin: TSpin; { +0240 }
    Label1: TLabel; { +0244 }
    Label2: TLabel; { +0248 }
    ImageSequencer: TImageSequencer; { +024C }
    Windows16DC2: TWindows16DC; { +0250 }
    SequenceLayerSelector: TSequenceLayerSelector; { +0254 }
    PreviewILGrid: TImageLibraryGrid; { +0258 }
    Panel6: TPanel; { +025C }
    AniSettingsBox: TGroupBox; { +0260 }
    Label4: TLabel; { +0264 }
    Label5: TLabel; { +0268 }
    SequenceSpeedBox: TComboBox; { +026C }
    SequenceModeBox: TComboBox; { +0270 }
    GroupBox1: TGroupBox; { +0274 }
    FrameTableEdit: TEdit; { +0278 }
    GroupBox2: TGroupBox; { +027C }
    ILManagerComboBox: TILManagerComboBox; { +0280 }
    GroupBox3: TGroupBox; { +0284 }
    LayerSpin: TSpin; { +0288 }
    GenerateBtn: TButton; { +028C }
    SFXSheet: TTabSheet; { +0290 }
    GroupBox5: TGroupBox; { +0294 }
    PlayHitSample: TSpeedButton; { +0298 }
    Panel7: TPanel; { +029C }
    Panel9: TPanel; { +02A0 }
    Panel10: TPanel; { +02A4 }
    SequenceDisplayEditor: TSequenceDisplayEditor; { +02A8 }
    GroupBox6: TGroupBox; { +02AC }
    MoveSpeedBox: TComboBox; { +02B0 }
    GroupBox8: TGroupBox; { +02B4 }
    SpeedButton1: TSpeedButton; { +02B8 }
    GroupBox9: TGroupBox; { +02BC }
    SpeedButton2: TSpeedButton; { +02C0 }
    GroupBox10: TGroupBox; { +02C4 }
    SpeedButton3: TSpeedButton; { +02C8 }
    EditStandstillSFX: TButton; { +02CC }
    EditMoveSFX: TButton; { +02D0 }
    EditMeleeSFX: TButton; { +02D4 }
    EditDieSFX: TButton; { +02D8 }
    GroupBox7: TGroupBox; { +02DC }
    SpeedButton4: TSpeedButton; { +02E0 }
    Button1: TButton; { +02E4 }
    GroupBox11: TGroupBox; { +02E8 }
    Label3: TLabel; { +02EC }
    ChangeColor: TButton; { +02F0 }
    ColorDialog: TColorDialog; { +02F4 }
    public
    FResource: TUnitGFXResource; { $2F8 }
    procedure EditSFX(SFX: TSFXLibrary);
    destructor Destroy; override;
    procedure FormCreate(Sender: TObject);
    procedure ILManagerComboBoxChange(Sender: TObject);
    procedure LayerSpinUpdate(Sender: TObject);
    procedure SequenceModeBoxChange(Sender: TObject);
    procedure SequenceSpeedBoxChange(Sender: TObject);
    procedure FrameTableEditChange(Sender: TObject);
    procedure ImageSequencerChange(Sender: TObject);
    procedure OpenLayerBtnClick(Sender: TObject);
    procedure CloseLayerBtnClick(Sender: TObject);
    procedure ImageIndexSelectorSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure SequenceDisplayEditorStartUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
    procedure SequenceDisplayEditorResizeBackSurface(DC: TAbstractDC; Width, Height: Integer);
    procedure ImageSequencerCreateImageSequence(Sequencer: TImageSequencer; Sequence: TImageSequence);
    procedure UnitGFXNameEditChange(Sender: TObject);
    procedure FaceIndexSpinUpdate(Sender: TObject);
    procedure FaceILManagerComboBoxChange(Sender: TObject);
    procedure GenerateBtnClick(Sender: TObject);
    procedure MoveSpeedBoxChange(Sender: TObject);
    procedure SequenceDisplayEditorShowImageSequence(Sequence: TImageSequence; ImageIndex, X, Y: Integer; SD: TSurfaceDesc);
    procedure EditStandstillSFXClick(Sender: TObject);
    procedure EditMoveSFXClick(Sender: TObject);
    procedure EditMeleeSFXClick(Sender: TObject);
    procedure EditDieSFXClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ImageIndexSelectorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ChangeColorClick(Sender: TObject);
  end;

  { TUnitGFXResourceEditor (instance size 8, VMT 0040EBC0) }
  TUnitGFXResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses EUGFXGen, HSEdMod, SFXEdDlg;

const
  DirectionNames: array[1..6] of string = ('U', 'U/R', 'D/R', 'D', 'D/L', 'U/L');
  ActionNames: array[0..4] of string = ('Stand Still', 'Move', 'Attack', 'Hit', 'Shadow');

class function TUnitGFXResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TUnitGFXResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

destructor TUnitGFXResourceEditForm.Destroy;
begin
  inherited Destroy;
  Application.MainForm.SetFocus;
end;

procedure TUnitGFXResourceEditForm.FormCreate(Sender: TObject);
var I, Direction: Integer;
begin
  SequenceModeBox.ItemIndex := 0;
  SequenceSpeedBox.ItemIndex := 0;
  FResource := TUnitGFXResource(F_ResourceEditForm_1F8);
  FResource.AddRef;
  with ImageIndexSelector do
  begin
    RowCount := 32;
    for I := 0 to 4 do
      for Direction := 1 to 6 do
        Cells[0, I * 6 + Direction - 1] := ActionNames[I] + ' (' + DirectionNames[Direction] + ')';
    Cells[0, 30] := 'Dead';
    Cells[0, 31] := 'Dead (Burned)';
  end;
  ILManagerComboBox.ILManager := FResource.FSequences.ILManager;
  ImageSequencer.ILManager := FResource.FSequences.ILManager;
  ImageSequencer.ImageSequenceList := FResource.FSequences;
  FaceILManagerComboBox.ILManager := FResource.FSequences.ILManager;
  FaceILManagerComboBox.ImageLibraryName := FResource.FFaceImageLibraryName;
  FaceImagePanel.ImageLibrary := FResource.FFaceImageLibrary;
  FaceImagePanel.ImageIndex := FResource.FFaceIndex;
  FaceImageLibraryPreviewGrid.ImageLibrary := FResource.FFaceImageLibrary;
  FaceIndexSpin.Value := FResource.FFaceIndex;
  UnitGFXNameEdit.Text := FResource.FName;
  MoveSpeedBox.ItemIndex := FResource.F_UnitGFXResource_30;
end;

procedure TUnitGFXResourceEditForm.ILManagerComboBoxChange(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
  begin
    Sequence.ImageLibraryName := ILManagerComboBox.ImageLibraryName;
    ImageSequencer.CurrentImageSequenceUpdated;
  end;
end;

procedure TUnitGFXResourceEditForm.LayerSpinUpdate(Sender: TObject);
begin
  if ImageSequencer.CurrentImageSequence <> nil then
    with ImageSequencer.CurrentImageSequence do
    begin
      if LayerSpin.Value < Layer then
      begin
        ImageSequencer.DecreaseLayer;
        LayerSpin.Value := Layer;
      end;
      if LayerSpin.Value > Layer then
      begin
        ImageSequencer.IncreaseLayer;
        LayerSpin.Value := Layer;
      end;
    end;
end;

procedure TUnitGFXResourceEditForm.SequenceModeBoxChange(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
  begin
    Sequence.SequenceMode := TSequenceMode(SequenceModeBox.ItemIndex);
    ImageSequencer.CurrentImageSequenceUpdated;
  end;
end;

procedure TUnitGFXResourceEditForm.SequenceSpeedBoxChange(Sender: TObject);
var I: Integer; Sequence: TImageSequence;
begin
  with ImageIndexSelector do
    for I := Selection.Top to Selection.Bottom do
    begin
      Sequence := FResource.FSequences.GetImageSequence(I);
      if Sequence <> nil then Sequence.SequenceSpeed := SequenceSpeedBox.ItemIndex;
    end;
end;

procedure TUnitGFXResourceEditForm.FrameTableEditChange(Sender: TObject);
var S: string; I: Integer; Sequence: TImageSequence; Table: TFrameTableList;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
  begin
    Table := Sequence.FrameTable;
    if Table <> nil then
    begin
      Table.ItemString := FrameTableEdit.Text;
      S := FrameTableEdit.Text;
      for I := Length(S) downto 1 do
        if not (S[I] in ['0'..'9', ',']) then Delete(S, I, 1);
      if FrameTableEdit.Text <> S then FrameTableEdit.Text := S;
    end
    else if Sequence.SequenceMode = smNone then
    begin
      S := FrameTableEdit.Text;
      for I := Length(S) downto 1 do
        if not (S[I] in ['0'..'9']) then Delete(S, I, 1);
      if S <> '' then ImageSequencer.CurrentImageSequence.ImageIndex := StrToInt(S)
      else ImageSequencer.CurrentImageSequence.ImageIndex := 0;
      if S <> FrameTableEdit.Text then FrameTableEdit.Text := S;
    end;
  end;
end;

procedure TUnitGFXResourceEditForm.ImageSequencerChange(Sender: TObject);
begin
  if ImageSequencer.CurrentImageSequence <> nil then
    with ImageSequencer.CurrentImageSequence do
    begin
      if SequenceMode in [smFrameTable, smRndFrameTable] then
      begin
        FrameTableEdit.Enabled := True;
        FrameTableEdit.Text := FrameTable.ItemString;
        FrameTableEdit.Color := clWindow;
      end
      else if SequenceMode = smNone then
      begin
        FrameTableEdit.Enabled := True;
        FrameTableEdit.Text := IntToStr(ImageIndex);
        FrameTableEdit.Color := clWindow;
      end
      else if FrameTableEdit.Enabled then
      begin
        FrameTableEdit.Enabled := False;
        FrameTableEdit.Text := '';
        FrameTableEdit.Color := clBtnFace;
      end;
      LayerSpin.Enabled := True;
      LayerSpin.Value := Layer;
      ILManagerComboBox.Enabled := True;
      ILManagerComboBox.ImageLibraryName := ImageLibraryName;
      PreviewILGrid.ImageLibrary := ImageLibrary;
      SequenceModeBox.ItemIndex := Integer(SequenceMode);
      SequenceModeBox.Enabled := True;
      SequenceSpeedBox.ItemIndex := SequenceSpeed;
      SequenceSpeedBox.Enabled := True;
    end
  else
  begin
    FrameTableEdit.Enabled := False;
    FrameTableEdit.Text := '';
    FrameTableEdit.Color := clBtnFace;
    LayerSpin.Enabled := False;
    ILManagerComboBox.Enabled := False;
    PreviewILGrid.ImageLibrary := nil;
    SequenceModeBox.Enabled := False;
    SequenceSpeedBox.Enabled := False;
  end;
end;

procedure TUnitGFXResourceEditForm.OpenLayerBtnClick(Sender: TObject);
begin
  ImageSequencer.AddSequenceLayer;
end;

procedure TUnitGFXResourceEditForm.CloseLayerBtnClick(Sender: TObject);
begin
  ImageSequencer.DeleteSequenceLayer;
end;

procedure TUnitGFXResourceEditForm.ImageIndexSelectorSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  ImageSequencer.CurrentSequenceIndex := ARow;
  if (ARow > 23) and (ARow < 30) then
  begin
    SequenceDisplayEditor.PreviewFrames.Clear;
    SequenceDisplayEditor.PreviewFrames.Add(ARow);
    SequenceDisplayEditor.PreviewFrames.Add(ARow mod 6);
  end
  else
  begin
    SequenceDisplayEditor.PreviewFrames.Clear;
    SequenceDisplayEditor.PreviewFrames.Add(ARow);
  end;
end;

procedure TUnitGFXResourceEditForm.SequenceDisplayEditorStartUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
var X, Y: Integer; SD: TSurfaceDesc;
begin
  X := DC.GetSurface(1).Width shr 1;
  Y := DC.GetSurface(1).Height shr 1;
  DC.GetSurface(1).Lock(SD);
  HSEditModule.HSEditIL[0].ShowClipped(X - 24, Y - 16, SD);
  DC.GetSurface(1).Unlock;
end;

procedure TUnitGFXResourceEditForm.SequenceDisplayEditorResizeBackSurface(DC: TAbstractDC; Width, Height: Integer);
begin
  SequenceDisplayEditor.ImageCenterX := (Width shr 1) - 16;
  SequenceDisplayEditor.ImageCenterY := (Height shr 1) - 16;
end;

procedure TUnitGFXResourceEditForm.ImageSequencerCreateImageSequence(Sequencer: TImageSequencer; Sequence: TImageSequence);
begin
  Sequence.dXshift := -16;
  Sequence.dYshift := -32;
end;

procedure TUnitGFXResourceEditForm.UnitGFXNameEditChange(Sender: TObject);
begin
  FResource.FName := UnitGFXNameEdit.Text;
end;

procedure TUnitGFXResourceEditForm.FaceIndexSpinUpdate(Sender: TObject);
begin
  FResource.FFaceIndex := FaceIndexSpin.Value;
  FaceImagePanel.ImageIndex := FaceIndexSpin.Value;
end;

procedure TUnitGFXResourceEditForm.FaceILManagerComboBoxChange(Sender: TObject);
begin
  FResource.SetFaceImageLibraryName(FaceILManagerComboBox.ImageLibraryName);
  FaceImagePanel.ImageLibrary := FResource.FFaceImageLibrary;
  FaceImageLibraryPreviewGrid.ImageLibrary := FResource.FFaceImageLibrary;
end;

procedure TUnitGFXResourceEditForm.GenerateBtnClick(Sender: TObject);
var Dlg: TUnitGFXGeneraterDlg;
begin
  Dlg := TUnitGFXGeneraterDlg.Create(Self);
  Dlg.SetResource(FResource);
  Dlg.ShowModal;
  Dlg.Free;
end;

procedure TUnitGFXResourceEditForm.MoveSpeedBoxChange(Sender: TObject);
begin
  FResource.F_UnitGFXResource_30 := Byte(MoveSpeedBox.ItemIndex);
end;

procedure TUnitGFXResourceEditForm.SequenceDisplayEditorShowImageSequence(Sequence: TImageSequence; ImageIndex, X, Y: Integer; SD: TSurfaceDesc);
var SFX: TSFXLibrary;
begin
  SFX := nil;
  case ImageSequencer.CurrentSequenceIndex div 6 of
    0: SFX := FResource.FSFXLibraries[0];
    1: SFX := FResource.FSFXLibraries[1];
    2: SFX := FResource.FSFXLibraries[2];
    3: SFX := FResource.FSFXLibraries[3];
  end;
  if (SFX <> nil) and (Sequence.SpeedCount = Sequence.SequenceSpeed) then
    SFX.Play(ImageIndex mod 100);
end;

procedure TUnitGFXResourceEditForm.EditStandstillSFXClick(Sender: TObject);
begin
  EditSFX(FResource.FSFXLibraries[0]);
end;

procedure TUnitGFXResourceEditForm.EditMoveSFXClick(Sender: TObject);
begin
  EditSFX(FResource.FSFXLibraries[1]);
end;

procedure TUnitGFXResourceEditForm.EditMeleeSFXClick(Sender: TObject);
begin
  EditSFX(FResource.FSFXLibraries[2]);
end;

procedure TUnitGFXResourceEditForm.EditDieSFXClick(Sender: TObject);
begin
  EditSFX(FResource.FSFXLibraries[3]);
end;

procedure TUnitGFXResourceEditForm.Button1Click(Sender: TObject);
begin
  EditSFX(FResource.FSFXLibraries[4]);
end;

procedure TUnitGFXResourceEditForm.ImageIndexSelectorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  I: Integer;
  List: TImageSequenceList;
  Index: Integer;
  Stream: TMemoryStream;
  Sequence: TImageSequence;
begin
  if ((Key = Ord('C')) or (Key = Ord('X'))) and (ssCtrl in Shift) then
  begin
    Stream := TMemoryStream.Create;
    List := TImageSequenceList.Create(nil, nil);
    with ImageIndexSelector do
      for I := Selection.Top to Selection.Bottom do
      begin
        Sequence := FResource.FSequences.GetImageSequence(I);
        if Sequence <> nil then List.Add(I - Selection.Top, Sequence.Copy(nil))
        else List.Add(I - Selection.Top, nil);
      end;
    List.SaveToStream(Stream);
    CopyStreamToClipboard(Stream, 'IMAGESEQUENCELIST');
    Invalidate;
    List.Free;
    Stream.Free;
  end;
  if (Key = Ord('V')) and (ssCtrl in Shift) then
  begin
    Stream := TMemoryStream.Create;
    List := TImageSequenceList.Create(nil, nil);
    try
      if PasteStreamFromClipboard(Stream, 'IMAGESEQUENCELIST') <> -1 then
      begin
        List.LoadFromStream(Stream);
        Index := 0;
        with ImageIndexSelector do
        begin
          for I := Selection.Top to Selection.Bottom do
            if Index < List.Count then
            begin
              if List.GetImageSequence(Index) <> nil then
              begin
                Sequence := List.GetImageSequence(Index).Copy(FResource.FSequences);
                FResource.FSequences.Add(I, Sequence);
                while Sequence <> nil do
                begin
                  Sequence.LinkToIL;
                  Sequence := Sequence.Next;
                end;
              end;
              Inc(Index);
            end;
          ImageSequencer.CurrentSequenceIndex := Row;
          Invalidate;
          FResource.FSequences.LinkToIL;
        end;
      end;
    finally
      List.Free;
      Stream.Free;
    end;
  end;
  if (Key = Ord('X')) and (ssCtrl in Shift) then
    with ImageIndexSelector do
    begin
      for I := Selection.Top to Selection.Bottom do FResource.FSequences.SetImageSequence(I, nil);
      ImageSequencer.CurrentSequenceIndex := Row;
    end;
end;

procedure TUnitGFXResourceEditForm.ChangeColorClick(Sender: TObject);
begin
  ColorDialog.Color := SequenceDisplayEditor.Color;
  with ColorDialog do
    if Execute then SequenceDisplayEditor.Color := ColorDialog.Color;
end;


procedure TUnitGFXResourceEditForm.EditSFX(SFX: TSFXLibrary);
var Dlg: TSFXLibraryEditDlg;
begin
  Dlg := TSFXLibraryEditDlg.Create(Self);
  Dlg.Edit(AoWEngine, SFX, AoWHSSet.SFXManager);
  Dlg.Free;
end;

end.
