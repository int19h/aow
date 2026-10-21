unit ILSeqEd;

{ Image-sequence editor from ILToolsP.dpl. No form resource is needed by the match host. }

{$R+}

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, Buttons, SpinEdit, GFXE, ImageLib, DisplayC, ILTools, Str2Clip;

type
  { TImageSequenceEditor: instance size $268; published component fields $1DC..$260
    follow the original form RTTI; $264 holds the saved sequence stream. }
  TImageSequenceEditor = class(TForm)
  published
    SequenceLayerSelector: TSequenceLayerSelector; { $01DC }
    PreviewILGrid: TImageLibraryGrid; { $01E0 }
    Panel6: TPanel; { $01E4 }
    AniSettingsBox: TGroupBox; { $01E8 }
    Label4: TLabel; { $01EC }
    Label5: TLabel; { $01F0 }
    SequenceSpeedBox: TComboBox; { $01F4 }
    SequenceModeBox: TComboBox; { $01F8 }
    GroupBox1: TGroupBox; { $01FC }
    FrameTableEdit: TEdit; { $0200 }
    GroupBox2: TGroupBox; { $0204 }
    GroupBox3: TGroupBox; { $0208 }
    LayerSpin: TSpin; { $020C }
    PlayModeBox: TGroupBox; { $0210 }
    PlayLooped: TCheckBox; { $0214 }
    PlayBtn: TButton; { $0218 }
    SequenceDisplayEditor: TSequenceDisplayEditor; { $021C }
    ImageSequencer: TImageSequencer; { $0220 }
    Windows16DC: TWindows16DC; { $0224 }
    Panel7: TPanel; { $0228 }
    Panel8: TPanel; { $022C }
    OpenLayerBtn: TSpeedButton; { $0230 }
    CloseLayerBtn: TSpeedButton; { $0234 }
    ImageIndexSelector: TDrawGrid; { $0238 }
    Panel1: TPanel; { $023C }
    OkBtn: TButton; { $0240 }
    CancelBtn: TButton; { $0244 }
    GridLibrary: TImageLibrary; { $0248 }
    Panel2: TPanel; { $024C }
    ILManagerComboBox: TILManagerComboBox; { $0250 }
    Label1: TLabel; { $0254 }
    Label2: TLabel; { $0258 }
    ColorDialog: TColorDialog; { $025C }
    ChangeColor: TButton; { $0260 }
  public
    FSavedSequences: TMemoryStream; { $264 }
    function GetImageSequenceList: TImageSequenceList;
    procedure SetImageSequenceList(Value: TImageSequenceList);
    procedure FrameTableEditChange(Sender: TObject);
    procedure ILManagerComboBoxChange(Sender: TObject);
    procedure LayerSpinUpdate(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure PlayLoopedClick(Sender: TObject);
    procedure SequenceDisplayEditorResizeBackSurface(DC: TAbstractDC; Width, Height: Integer);
    procedure SequenceDisplayEditorUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
    procedure SequenceModeBoxChange(Sender: TObject);
    procedure SequenceSpeedBoxChange(Sender: TObject);
    procedure ImageSequencerChange(Sender: TObject);
    procedure ImageSequencerCreateImageSequence(Sequencer: TImageSequencer; Sequence: TImageSequence);
    procedure ImageIndexSelectorDrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
    procedure ImageIndexSelectorSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure CloseLayerBtnClick(Sender: TObject);
    procedure ImageIndexSelectorDrawCell2(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
    procedure ImageIndexSelectorSelectCell2(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure OpenLayerBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    function ShowModal: Integer;
    procedure ImageIndexSelectorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ChangeColorClick(Sender: TObject);
    property ImageSequenceList: TImageSequenceList read GetImageSequenceList write SetImageSequenceList;
  end;

implementation

function TImageSequenceEditor.GetImageSequenceList: TImageSequenceList;
begin
  Result := ImageSequencer.ImageSequenceList;
end;

procedure TImageSequenceEditor.SetImageSequenceList(Value: TImageSequenceList);
begin
  ImageSequencer.ImageSequenceList := Value;
  if Value <> nil then
  begin
    ImageSequencer.ILManager := Value.ILManager;
    ILManagerComboBox.ILManager := Value.ILManager;
  end
  else
  begin
    ImageSequencer.ILManager := nil;
    ILManagerComboBox.ILManager := nil;
  end;
end;

procedure TImageSequenceEditor.FrameTableEditChange(Sender: TObject);
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

procedure TImageSequenceEditor.ILManagerComboBoxChange(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
  begin
    Sequence.ImageLibraryName := ILManagerComboBox.ImageLibraryName;
    ImageSequencer.CurrentImageSequenceUpdated;
  end;
end;

procedure TImageSequenceEditor.LayerSpinUpdate(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
    with Sequence do
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

procedure TImageSequenceEditor.PlayBtnClick(Sender: TObject);
begin
  SequenceDisplayEditor.FrameCount := 0;
end;

procedure TImageSequenceEditor.PlayLoopedClick(Sender: TObject);
begin
  SequenceDisplayEditor.ShowLooped := PlayLooped.Checked;
end;

procedure TImageSequenceEditor.SequenceDisplayEditorResizeBackSurface(DC: TAbstractDC; Width, Height: Integer);
var Display: TSequenceDisplayEditor;
begin
  Display := SequenceDisplayEditor;
  Display.ImageCenterX := Display.BackSurfaceWidth shr 1;
  Display.ImageCenterY := Display.BackSurfaceHeight shr 1;
end;

procedure TImageSequenceEditor.SequenceDisplayEditorUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
var Width, Height, X, Y: Integer; SD: TSurfaceDesc;
begin
  DC.GetSurface(1).Lock(SD);
  Width := DC.GetSurface(1).Width;
  Height := DC.GetSurface(1).Height;
  X := Width shr 1;
  Y := Height shr 1;
  GridLibrary[0].Show(X - 200, Y - 200, SD);
  DC.GetSurface(1).Unlock;
end;

procedure TImageSequenceEditor.SequenceModeBoxChange(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
  begin
    Sequence.SequenceMode := TSequenceMode(SequenceModeBox.ItemIndex);
    ImageSequencer.CurrentImageSequenceUpdated;
  end;
end;

procedure TImageSequenceEditor.SequenceSpeedBoxChange(Sender: TObject);
begin
  if ImageSequencer.CurrentImageSequence <> nil then
    ImageSequencer.CurrentImageSequence.SequenceSpeed := SequenceSpeedBox.ItemIndex;
end;

procedure TImageSequenceEditor.ImageSequencerChange(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
    with Sequence do
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

procedure TImageSequenceEditor.ImageSequencerCreateImageSequence(Sequencer: TImageSequencer; Sequence: TImageSequence);
begin
  Sequence.dXshift := 0;
  Sequence.dYshift := 0;
end;

procedure TImageSequenceEditor.ImageIndexSelectorDrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
var S: string;
begin
  if ARow <> 0 then S := IntToStr(ARow - 1) else S := 'Index';
  SetTextAlign(ImageIndexSelector.Canvas.Handle, TA_CENTER);
  ExtTextOut(ImageIndexSelector.Canvas.Handle, (R.Right + R.Left) div 2, R.Top + 2,
    ETO_CLIPPED, @R, PChar(S), Length(S), nil);
  SetTextAlign(ImageIndexSelector.Canvas.Handle, TA_LEFT);
  if (ARow > 0) and (ImageSequencer.ImageSequenceList.GetImageSequence(ARow - 1) <> nil) then
  begin
    S := 'u';
    ExtTextOut(ImageIndexSelector.Canvas.Handle, R.Right - 8, R.Top + 2,
      ETO_CLIPPED, @R, PChar(S), Length(S), nil);
  end;
end;

procedure TImageSequenceEditor.ImageIndexSelectorSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  ImageSequencer.CurrentSequenceIndex := ARow - 1;
end;

procedure TImageSequenceEditor.CloseLayerBtnClick(Sender: TObject);
begin
  ImageSequencer.DeleteSequenceLayer;
end;

procedure TImageSequenceEditor.ImageIndexSelectorDrawCell2(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
var S: string;
begin
  if ARow <> 0 then S := IntToStr(ARow - 1) else S := 'Index';
  SetTextAlign(ImageIndexSelector.Canvas.Handle, TA_CENTER);
  ExtTextOut(ImageIndexSelector.Canvas.Handle, (R.Right + R.Left) div 2, R.Top + 2,
    ETO_CLIPPED, @R, PChar(S), Length(S), nil);
  SetTextAlign(ImageIndexSelector.Canvas.Handle, TA_LEFT);
  if (ARow > 0) and (ImageSequencer.ImageSequenceList <> nil) and
    (ImageSequencer.ImageSequenceList.GetImageSequence(ARow - 1) <> nil) then
  begin
    S := 'u';
    ExtTextOut(ImageIndexSelector.Canvas.Handle, R.Right - 8, R.Top + 2,
      ETO_CLIPPED, @R, PChar(S), Length(S), nil);
  end;
end;

procedure TImageSequenceEditor.ImageIndexSelectorSelectCell2(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  ImageSequencer.CurrentSequenceIndex := ARow - 1;
end;

procedure TImageSequenceEditor.OpenLayerBtnClick(Sender: TObject);
begin
  ImageSequencer.AddSequenceLayer;
end;

procedure TImageSequenceEditor.FormCreate(Sender: TObject);
begin
  FSavedSequences := TMemoryStream.Create;
end;

procedure TImageSequenceEditor.FormDestroy(Sender: TObject);
begin
  FSavedSequences.Free;
end;

procedure TImageSequenceEditor.SpeedButton2Click(Sender: TObject);
begin
  ImageSequencer.DeleteSequenceLayer;
end;

function TImageSequenceEditor.ShowModal: Integer;
begin
  if GetImageSequenceList <> nil then
  begin
    FSavedSequences.Clear;
    GetImageSequenceList.SaveToStream(FSavedSequences);
  end;
  SequenceDisplayEditor.StartUpdateFrameLoop;
  Result := inherited ShowModal;
  SequenceDisplayEditor.StopUpdateFrameLoop;
  if Result = mrCancel then
    if GetImageSequenceList <> nil then
    begin
      FSavedSequences.Position := 0;
      GetImageSequenceList.LoadFromStream(FSavedSequences);
    end;
end;

procedure TImageSequenceEditor.ImageIndexSelectorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  I: Integer;
  List: TImageSequenceList;
  Index: Integer;
  Sequence: TImageSequence;
  Stream: TMemoryStream;
begin
  if ((Key = Ord('C')) or (Key = Ord('X'))) and (ssCtrl in Shift) then
  begin
    Stream := TMemoryStream.Create;
    List := TImageSequenceList.Create(nil, nil);
    with ImageIndexSelector do
      for I := Selection.Top to Selection.Bottom do
      begin
        Sequence := GetImageSequenceList.GetImageSequence(I - 1);
        if Sequence <> nil then List.Add(I - Selection.Top, Sequence.Copy(nil))
        else List.Add(I - Selection.Top, nil);
      end;
    List.SaveToStream(Stream);
    Str2Clip.CopyStreamToClipboard(Stream, 'IMAGESEQUENCELIST');
    Invalidate;
    List.Free;
    Stream.Free;
  end;
  if (Key = Ord('V')) and (ssCtrl in Shift) then
  begin
    Stream := TMemoryStream.Create;
    List := TImageSequenceList.Create(nil, nil);
    try
      if Str2Clip.PasteStreamFromClipboard(Stream, 'IMAGESEQUENCELIST') <> -1 then
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
                Sequence := List.GetImageSequence(Index).Copy(GetImageSequenceList);
                GetImageSequenceList.Add(I - 1, Sequence);
                while Sequence <> nil do
                begin
                  Sequence.LinkToIL;
                  Sequence := Sequence.Next;
                end;
              end;
              Inc(Index);
            end;
          ImageSequencer.CurrentSequenceIndex := Row - 1;
          Invalidate;
          GetImageSequenceList.ReduceCount;
        end;
      end;
    finally
      List.Free;
      Stream.Free;
    end;
  end;
  if (Key = Ord('X')) and (ssCtrl in Shift) then
    with ImageIndexSelector do
      for I := Selection.Top to Selection.Bottom do
        GetImageSequenceList.Delete(I - 1, nil);
end;

procedure TImageSequenceEditor.ChangeColorClick(Sender: TObject);
begin
  ColorDialog.Color := SequenceDisplayEditor.Color;
  if ColorDialog.Execute then SequenceDisplayEditor.Color := ColorDialog.Color;
end;

initialization
finalization

end.
