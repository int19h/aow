unit RMapObj;

{ Map object resource editor from AoWEd.exe. Original range and overflow checks. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Buttons, ILTools, SpinEdit, TerCBox, HSEdMod, ILSeqEd;

type
  TMapObjectResourceClass = class of TMapObjectResource;
  TMapObjectResourceEditForm = class;
  TMapObjectResourceEditor = class;


  { TMapObjectResourceEditForm (instance size $324): $2F0 saved task state,
    $2F4 disabled windows, $2F8 engine, $2FC close result, $300 edit callback,
    $308 resource, $30C reserved, $310 preview indices, $314 frame,
    $318 reserved flag, $31C/$320 reserved. VMT 004037F0. }
  TMapObjectResourceEditForm = class(TForm)
  public
    published
    BottomPanel: TPanel; { +01DC }
    CloseBtn: TButton; { +01E0 }
    CancelBtn: TButton; { +01E4 }
    BottomBevel: TBevel; { +01E8 }
    MainPageControl: TPageControl; { +01EC }
    SettingsSheet: TTabSheet; { +01F0 }
    SettingsPanel: TPanel; { +01F4 }
    SettingsWindowsDC: TWindows16DC; { +01F8 }
    Panel5: TPanel; { +01FC }
    Panel3: TPanel; { +0200 }
    Label3: TLabel; { +0204 }
    LevelBox: TComboBox; { +0208 }
    AnimationPanel: TPanel; { +020C }
    ComplexBox: TCheckBox; { +0210 }
    AniSheet: TTabSheet; { +0214 }
    OpenILDlg: TOpenDialog; { +0218 }
    TerrainPanel: TPanel; { +021C }
    Label1: TLabel; { +0220 }
    TerrainComboBox: TTerrainComboBox; { +0224 }
    OverlayTerrainPanel: TPanel; { +0228 }
    Label2: TLabel; { +022C }
    OverlayComboBox: TTerrainComboBox; { +0230 }
    LoadPanel: TPanel; { +0234 }
    LoadImageSetBtn: TButton; { +0238 }
    Panel2: TPanel; { +023C }
    Label6: TLabel; { +0240 }
    Label7: TLabel; { +0244 }
    MORComboBox: TComboBox; { +0248 }
    NameEdit: TEdit; { +024C }
    Panel1: TPanel; { +0250 }
    Display: TDisplay; { +0254 }
    ImageLibraryGrid: TImageLibraryGrid; { +0258 }
    Panel4: TPanel; { +025C }
    Panel7: TPanel; { +0260 }
    Panel8: TPanel; { +0264 }
    ImageIndexSelector: TDrawGrid; { +0268 }
    OpenLayerBtn: TSpeedButton; { +026C }
    CloseLayerBtn: TSpeedButton; { +0270 }
    PreviewImagePanel: TPanel; { +0274 }
    Label8: TLabel; { +0278 }
    PreviewFramesEdit: TEdit; { +027C }
    Panel9: TPanel; { +0280 }
    Label9: TLabel; { +0284 }
    ResourceIDEdit: TEdit; { +0288 }
    Windows16DC1: TWindows16DC; { +028C }
    ImageSequencer: TImageSequencer; { +0290 }
    Windows16DC2: TWindows16DC; { +0294 }
    SequenceLayerSelector: TSequenceLayerSelector; { +0298 }
    PreviewILGrid: TImageLibraryGrid; { +029C }
    Panel6: TPanel; { +02A0 }
    AniSettingsBox: TGroupBox; { +02A4 }
    Label4: TLabel; { +02A8 }
    Label5: TLabel; { +02AC }
    SequenceSpeedBox: TComboBox; { +02B0 }
    SequenceModeBox: TComboBox; { +02B4 }
    GroupBox1: TGroupBox; { +02B8 }
    FrameTableEdit: TEdit; { +02BC }
    GroupBox3: TGroupBox; { +02C0 }
    LayerSpin: TSpin; { +02C4 }
    SequenceDisplayEditor: TSequenceDisplayEditor; { +02C8 }
    PlayModeBox: TGroupBox; { +02CC }
    PlayLooped: TCheckBox; { +02D0 }
    PlayBtn: TButton; { +02D4 }
    ILPanelLarge: TPanel; { +02D8 }
    ILManagerComboBox: TILManagerComboBox; { +02DC }
    ImageLibraryLabel: TLabel; { +02E0 }
    BKColorLabel: TLabel; { +02E4 }
    ChangeBKColor: TButton; { +02E8 }
    ColorDialog: TColorDialog; { +02EC }
    public
    FSavedTaskState: Integer; { $2F0 }
    FTaskWindows: Pointer; { $2F4 }
    FEngine: THSEngine; { $2F8 }
    FEditResult: Integer; { $2FC }
    FOnEditDone: TEditDoneEvent; { $300 }
    FResource: TMapObjectResource; { $308 }
    F_MapObjectResourceEditForm_30C: array[0..3] of Byte;
    FPreviewFrames: TByteList; { $310 }
    FFrame: Integer; { $314 }
    FUpdating: Boolean; { $318 }
    F_MapObjectResourceEditForm_319: array[0..2] of Byte;
    FDragX: Integer; { $31C, 004067A0 }
    FDragY: Integer; { $320, 004067A9 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure WndProc(var Message: TMessage); override;
    procedure vmt80; virtual;  { +080 }
    procedure vmt84; virtual;  { +084 }
    procedure vmt88(Index, X, Y: Integer; SD: TSurfaceDesc); virtual;  { +088 }
    procedure vmt8C(Index, X, Y: Integer; SD: TSurfaceDesc); virtual;  { +08C }
    procedure vmt90(Index, X, Y: Integer; SD: TSurfaceDesc); virtual;  { +090 }
    constructor CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent); virtual; { +094 }
    procedure DisableWindows;
    procedure EnableWindows;
    procedure DisableComplex;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CloseBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure MORComboBoxChange(Sender: TObject);
    procedure ComplexBoxClick(Sender: TObject);
    procedure TerrainComboBoxChange(Sender: TObject);
    procedure OverlayComboBoxChange(Sender: TObject);
    procedure LevelBoxChange(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure LoadImageSetBtnClick(Sender: TObject);
    procedure ImageIndexSelectorDrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
    procedure PreviewFramesEditChange(Sender: TObject);
    procedure MainPageControlChange(Sender: TObject);
    procedure DisplayKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DisplayUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
    procedure FrameTableEditChange(Sender: TObject);
    procedure ILManagerComboBoxChange(Sender: TObject);
    procedure ImageSequencerChange(Sender: TObject);
    procedure ImageSequencerCreateImageSequence(Sequencer: TImageSequencer; Sequence: TImageSequence);
    procedure LayerSpinUpdate(Sender: TObject);
    procedure SequenceDisplayEditorResizeBackSurface(DC: TAbstractDC; Width, Height: Integer);
    procedure SequenceDisplayEditorUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
    procedure SequenceModeBoxChange(Sender: TObject);
    procedure SequenceSpeedBoxChange(Sender: TObject);
    procedure SequenceDisplayEditorActivateDC(Sender: TObject);
    procedure OpenLayerBtnClick(Sender: TObject);
    procedure CloseLayerBtnClick(Sender: TObject);
    procedure ImageIndexSelectorSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure PlayBtnClick(Sender: TObject);
    procedure PlayLoopedClick(Sender: TObject);
    procedure ChangeBKColorClick(Sender: TObject);
    procedure ExEditClick(Sender: TObject);
    procedure ImageIndexSelectorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ResourceIDEditChange(Sender: TObject);
  end;

  { TMapObjectResourceEditor (instance size 8, VMT 00404200) }
  TMapObjectResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

var
  SavedLeft: Integer = -1000;
  SavedTop: Integer = 0;
  SavedColor: TColor = 0;

class function TMapObjectResourceEditor.EditorClassID: Integer;
begin
  Result := $10154;
end;

class procedure TMapObjectResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TMapObjectResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

constructor TMapObjectResourceEditForm.Create(AOwner: Classes.TComponent);
begin
  raise Exception.Create('Use CreateForm instead of Create (TMapResourceEditForm)');
end;

constructor TMapObjectResourceEditForm.CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent);
var
  I: Integer;
  Found: Boolean;
begin
  FEditResult := mrCancel;
  FEngine := AEngine;
  FResource := Resource;
  FPreviewFrames := TByteList.Create;
  inherited Create(Application.MainForm);
  Caption := FResource.ResourceEditName;
  NameEdit.Text := FResource.Name;
  SequenceModeBox.ItemIndex := 0;
  SequenceSpeedBox.ItemIndex := 0;
  PlayLooped.Checked := SequenceDisplayEditor.ShowLooped;
  if FResource.ImageSequenceList <> nil then
  begin
    I := 0;
    Found := False;
    while not Found and (I <> FResource.ImageSequenceList.Count) do
    begin
      Found := FResource.ImageSequenceList.GetImageSequence(I) <> nil;
      if not Found then Inc(I);
    end;
  end
  else
  begin
    I := 0;
    Found := False;
    while not Found and (I <> FResource.ImageLibrary.Count) do
    begin
      Found := FResource.ImageLibrary[I] <> nil;
      if not Found then Inc(I);
    end;
  end;
  if not Found then I := 1;
  FPreviewFrames.Add(I);
  PreviewFramesEdit.Text := IntToStr(I);
  ResourceIDEdit.Text := IntToStr(FResource.ResourceID);
  FUpdating := False;
  SequenceDisplayEditor.Color := SavedColor;
  ImageLibraryGrid.ImageLibrary := FResource.ImageLibrary;
  MainPageControl.ActivePage := SettingsSheet;
  TerrainComboBox.HexagonSpriteEngine := THexagonSpriteEngine(AEngine.FComponent);
  OverlayComboBox.HexagonSpriteEngine := THexagonSpriteEngine(AEngine.FComponent);
  TerrainComboBox.TerrainType := Resource.TerrainList.Terrain[0];
  OverlayComboBox.TerrainType := Resource.TerrainList.Overlay[0];
  case Resource.Level of
    10: LevelBox.ItemIndex := 0;
    26: LevelBox.ItemIndex := 1;
  end;
  FOnEditDone := Done;
  ComplexBox.Checked := FResource.ImageSequenceList <> nil;
  if ComplexBox.Checked then vmt84 else DisableComplex;
  DisableWindows;
  vmt80;
  MORComboBox.Text := Resource.ResourceEditName;
end;

destructor TMapObjectResourceEditForm.Destroy;
begin
  FPreviewFrames.Free;
  EnableWindows;
  inherited Destroy;
end;

procedure TMapObjectResourceEditForm.DisableWindows;
begin
  EnableWindows;
  FTaskWindows := DisableTaskWindows(Handle);
  EnableWindow(Handle, True);
end;

procedure TMapObjectResourceEditForm.EnableWindows;
begin
  if FTaskWindows <> nil then
  begin
    EnableTaskWindows(FTaskWindows);
    FTaskWindows := nil;
  end;
end;

procedure TMapObjectResourceEditForm.DisableComplex;
begin
  MainPageControl.Pages[1].TabVisible := False;
  ComplexBox.Checked := False;
end;

procedure TMapObjectResourceEditForm.vmt80;
var
  List: TEObjectClassList;
  I: Integer;
  S: string;
begin
  List := FEngine.GetDescendantClasses(TMapObjectResource);
  for I := 0 to List.Count - 1 do
  begin
    S := TMapObjectResourceClass(List[I]).ResourceEditName;
    if S <> '' then MORComboBox.Items.AddObject(S, TObject(List[I]));
  end;
  List.Free;
end;

procedure TMapObjectResourceEditForm.FormCreate(Sender: TObject);
begin
  if SavedLeft <> -1000 then
  begin
    SetBounds(SavedLeft, SavedTop, Width, Height);
    Position := poDesigned;
  end;
  MainPageControl.ActivePage := SettingsSheet;
end;

procedure TMapObjectResourceEditForm.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if (Message.Msg = WM_WINDOWPOSCHANGED) and Visible then
  begin
    SavedLeft := Left;
    SavedTop := Top;
  end;
end;

procedure TMapObjectResourceEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SequenceDisplayEditor.StopUpdateFrameLoop;
  Display.StopUpdateFrameLoop;
  Action := caFree;
  if not ComplexBox.Checked then
  begin
    FResource.ImageSequenceList.Free;
    FResource.ImageSequenceList := nil;
  end;
  if Assigned(FOnEditDone) then
    if FEditResult = mrOK then FOnEditDone(erOK, FResource)
    else FOnEditDone(erCancel, FResource);
end;

procedure TMapObjectResourceEditForm.CloseBtnClick(Sender: TObject);
begin
  FEditResult := mrOK;
  FEngine.HSSet.SetModified;
  Close;
end;

procedure TMapObjectResourceEditForm.CancelBtnClick(Sender: TObject);
begin
  FEditResult := mrCancel;
  Close;
end;

procedure TMapObjectResourceEditForm.MORComboBoxChange(Sender: TObject);
var
  C: TEObjectClass;
  R: TMapObjectResource;
begin
  with MORComboBox do C := TEObjectClass(Items.Objects[ItemIndex]);
  if C.ClassID <> FResource.ClassID then
  begin
    EnableWindows;
    R := TMapObjectResource(C.Create(nil));
    if FResource.CellImage <> nil then
    begin
      R.CellImage := FResource.CellImage.Copy;
      R.Name := FResource.Name;
    end;
    FEngine.ActivateEObject(R);
    TEObjectEditorClass(R.Editor).Edit(R, FEngine, FOnEditDone);
    FOnEditDone := nil;
    Close;
  end;
end;

procedure TMapObjectResourceEditForm.vmt84;
begin
  MainPageControl.Pages[1].TabVisible := True;
  if FResource.ImageSequenceList = nil then
    FResource.ImageSequenceList := TImageSequenceList.Create(FResource.Engine.HSSet.ImageLibraryManager, FResource.ImageLibrary);
  ImageSequencer.ImageSequenceList := FResource.ImageSequenceList;
  ILManagerComboBox.ILManager := FResource.ImageSequenceList.ILManager;
end;

procedure TMapObjectResourceEditForm.vmt88(Index, X, Y: Integer; SD: TSurfaceDesc);
begin
  if FResource.ImageLibrary.ImageExist(Index) then
    FResource.ImageLibrary[Index].Show(X, Y, SD);
end;

procedure TMapObjectResourceEditForm.vmt8C(Index, X, Y: Integer; SD: TSurfaceDesc);
var
  Sequence: TImageSequence;
  ImageIndex: Integer;
begin
  if FResource.ImageSequenceList <> nil then
  begin
    Sequence := FResource.ImageSequenceList.GetImageSequence(Index);
    while Sequence <> nil do
    begin
      if (Sequence.ImageLibrary <> nil) and (Sequence.ImageLibrary.Count <> 0) then
      begin
        if PlayLooped.Checked then ImageIndex := Sequence.GetFrameIndex(FFrame, 0)
        else ImageIndex := Sequence.GetUnloopedFrameIndex(FFrame);
        if (ImageIndex <> -1) and Sequence.ImageLibrary.ImageExist(ImageIndex) then
          Sequence.ImageLibrary[ImageIndex].Show(X + Sequence.dXshift, Y + Sequence.dYshift, SD);
      end;
      Sequence := Sequence.Next;
    end;
  end;
end;

procedure TMapObjectResourceEditForm.vmt90(Index, X, Y: Integer; SD: TSurfaceDesc);
begin
  if ComplexBox.Checked then vmt8C(Index, X, Y, SD)
  else vmt88(Index, X, Y, SD);
end;

procedure TMapObjectResourceEditForm.ComplexBoxClick(Sender: TObject);
begin
  if ComplexBox.Checked then vmt84 else DisableComplex;
end;

procedure TMapObjectResourceEditForm.TerrainComboBoxChange(Sender: TObject);
begin
  FResource.TerrainList.Terrain[0] := TerrainComboBox.TerrainType;
end;

procedure TMapObjectResourceEditForm.OverlayComboBoxChange(Sender: TObject);
begin
  if not (FResource is TMultiHexMOR) then
    FResource.TerrainList.Overlay[0] := OverlayComboBox.TerrainType;
end;

procedure TMapObjectResourceEditForm.LevelBoxChange(Sender: TObject);
begin
  case LevelBox.ItemIndex of
    0: FResource.Level := 10;
    1: FResource.Level := 26;
  end;
end;

procedure TMapObjectResourceEditForm.NameEditChange(Sender: TObject);
begin
  FResource.Name := NameEdit.Text;
end;

procedure TMapObjectResourceEditForm.LoadImageSetBtnClick(Sender: TObject);
begin
  if OpenILDlg.Execute then
  begin
    FResource.ImageLibrary.LoadFromFile(OpenILDlg.FileName);
    ImageLibraryGrid.Count := FResource.ImageLibrary.Count;
    ImageLibraryGrid.Repaint;
  end;
end;

procedure TMapObjectResourceEditForm.PreviewFramesEditChange(Sender: TObject);
begin
  FPreviewFrames.ItemString := PreviewFramesEdit.Text;
end;

procedure TMapObjectResourceEditForm.MainPageControlChange(Sender: TObject);
begin
  if MainPageControl.ActivePage = SettingsSheet then
  begin
    if not (dsFrameLoopPaused in SequenceDisplayEditor.FStatus) then SequenceDisplayEditor.PauseFrameUpdateLoop;
    if dsFrameLoopPaused in Display.FStatus then Display.ResumeFrameUpdateLoop;
  end;
  if MainPageControl.ActivePage = AniSheet then
  begin
    if not (dsFrameLoopPaused in Display.FStatus) then Display.PauseFrameUpdateLoop;
    if dsFrameLoopPaused in SequenceDisplayEditor.FStatus then SequenceDisplayEditor.ResumeFrameUpdateLoop;
  end;
end;

procedure TMapObjectResourceEditForm.SequenceDisplayEditorActivateDC(Sender: TObject);
begin
  MainPageControlChange(Self);
end;

procedure TMapObjectResourceEditForm.PlayBtnClick(Sender: TObject);
begin
  SequenceDisplayEditor.FrameCount := 0;
end;

procedure TMapObjectResourceEditForm.PlayLoopedClick(Sender: TObject);
begin
  SequenceDisplayEditor.ShowLooped := PlayLooped.Checked;
end;

procedure TMapObjectResourceEditForm.ChangeBKColorClick(Sender: TObject);
begin
  with ColorDialog do
  begin
    Color := 0;
    if Execute then
    begin
      SequenceDisplayEditor.Color := ColorDialog.Color;
      SavedColor := ColorDialog.Color;
    end;
  end;
end;

procedure TMapObjectResourceEditForm.ResourceIDEditChange(Sender: TObject);
begin
  FResource.ResourceID := StrToInt(ResourceIDEdit.Text);
end;

procedure TMapObjectResourceEditForm.FrameTableEditChange(Sender: TObject);
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

procedure TMapObjectResourceEditForm.ILManagerComboBoxChange(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
  begin
    Sequence.ImageLibraryName := ILManagerComboBox.ImageLibraryName;
    ImageSequencer.CurrentImageSequenceUpdated;
  end;
end;

procedure TMapObjectResourceEditForm.ImageSequencerChange(Sender: TObject);
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

procedure TMapObjectResourceEditForm.LayerSpinUpdate(Sender: TObject);
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

procedure TMapObjectResourceEditForm.SequenceModeBoxChange(Sender: TObject);
var Sequence: TImageSequence;
begin
  Sequence := ImageSequencer.CurrentImageSequence;
  if Sequence <> nil then
  begin
    Sequence.SequenceMode := TSequenceMode(SequenceModeBox.ItemIndex);
    ImageSequencer.CurrentImageSequenceUpdated;
  end;
end;

procedure TMapObjectResourceEditForm.SequenceSpeedBoxChange(Sender: TObject);
begin
  if ImageSequencer.CurrentImageSequence <> nil then
    ImageSequencer.CurrentImageSequence.SequenceSpeed := SequenceSpeedBox.ItemIndex;
end;

procedure TMapObjectResourceEditForm.OpenLayerBtnClick(Sender: TObject);
begin
  ImageSequencer.AddSequenceLayer;
end;

procedure TMapObjectResourceEditForm.CloseLayerBtnClick(Sender: TObject);
begin
  ImageSequencer.DeleteSequenceLayer;
end;

procedure TMapObjectResourceEditForm.ImageIndexSelectorDrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
var S: string;
begin
  if ARow <> 0 then S := IntToStr(ARow - 1) else S := 'Index';
  SetTextAlign(ImageIndexSelector.Canvas.Handle, TA_CENTER);
  ExtTextOut(ImageIndexSelector.Canvas.Handle, (R.Right + R.Left) div 2, R.Top + 2,
    ETO_CLIPPED, @R, PChar(S), Length(S), nil);
  SetTextAlign(ImageIndexSelector.Canvas.Handle, TA_LEFT);
  if (ARow > 0) and (FResource.ImageSequenceList.GetImageSequence(ARow - 1) <> nil) then
  begin
    S := 'u';
    ExtTextOut(ImageIndexSelector.Canvas.Handle, R.Right - 8, R.Top + 2,
      ETO_CLIPPED, @R, PChar(S), Length(S), nil);
  end;
end;

procedure TMapObjectResourceEditForm.ImageIndexSelectorSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  ImageSequencer.CurrentSequenceIndex := ARow - 1;
end;

procedure TMapObjectResourceEditForm.ImageSequencerCreateImageSequence(Sequencer: TImageSequencer; Sequence: TImageSequence);
begin
  Sequence.dXshift := -16;
  Sequence.dYshift := -16;
end;

procedure TMapObjectResourceEditForm.SequenceDisplayEditorResizeBackSurface(DC: TAbstractDC; Width, Height: Integer);
begin
  with SequenceDisplayEditor do
  begin
    ImageCenterX := (BackSurfaceWidth shr 1) - 16;
    ImageCenterY := (BackSurfaceHeight shr 1) - 16;
  end;
end;

procedure TMapObjectResourceEditForm.DisplayUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
var
  I: Integer;
  SD: TSurfaceDesc;
begin
  if MainPageControl.ActivePage = SettingsSheet then
  begin
    Inc(FFrame);
    if FFrame > $FFFFF then FFrame := 0;
    DC.GetSurface(1).Cls(0);
    DC.GetSurface(1).Lock(SD);
    for I := 0 to FPreviewFrames.Count - 1 do
      vmt90(FPreviewFrames[I], DC.GetSurface(1).Width div 2 - 16, DC.GetSurface(1).Height div 2 - 16, SD);
    DC.GetSurface(1).Unlock;
  end;
end;

procedure TMapObjectResourceEditForm.SequenceDisplayEditorUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
var
  Width, Height, I, X, Y: Integer;
  SD: TSurfaceDesc;
begin
  DC.GetSurface(1).Lock(SD);
  Width := DC.GetSurface(1).Width;
  Height := DC.GetSurface(1).Height;
  for I := 90 downto 1 do
  begin
    HNtoHP(I, X, Y);
    X := ((Width - 48) shr 1) + X + 8;
    Y := Y + ((Height - 32) shr 1);
    HSEditModule.HSEditIL[0].Show(X - 8, Y, SD);
  end;
  X := Width shr 1;
  Y := Height shr 1;
  HSEditModule.HSEditIL[2].Show(X - 24, Y - 16, SD);
  DC.GetSurface(1).Unlock;
end;

procedure TMapObjectResourceEditForm.ExEditClick(Sender: TObject);
var
  F: TImageSequenceEditor;
begin
  F := TImageSequenceEditor.Create(Self);
  F.ImageSequenceList := FResource.ImageSequenceList;
  F.ShowModal;
  F.Free;
end;

procedure TMapObjectResourceEditForm.DisplayKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  IL: TImageLibrary;
begin
  if ssCtrl in Shift then
    case Key of
      Ord('X'):
        begin
          IL := TImageLibrary.Create(Self);
          IL.Add(FResource.CellImage.Copy);
          IL.CopyToClipboard;
          IL.Destroy;
          FResource.CellImage := nil;
          Beep;
        end;
      Ord('C'):
        begin
          IL := TImageLibrary.Create(Self);
          if FResource.CellImage <> nil then IL.Add(FResource.CellImage.Copy)
          else IL.Add(nil);
          IL.CopyToClipboard;
          IL.Destroy;
          Beep;
        end;
      Ord('V'):
        begin
          IL := TImageLibrary.Create(Self);
          IL.PasteFromClipboard;
          if IL.Count <> 0 then
          begin
            FResource.CellImage := IL.GetImage(0);
            Beep;
          end;
          { Original assumes the multihex layout without checking the resource class. }
          with TMultiHexMOR(FResource) do
            if CellImage <> nil then
            begin
              dXImage := -(CellImage.Width div 2) + 16;
              dYImage := -(CellImage.Height div 2) + 16;
            end;
          { Original leaves the paste library allocated. }
        end;
      VK_DELETE:
        begin
          FResource.CellImage := nil;
          Beep;
        end;
    end;
end;

procedure TMapObjectResourceEditForm.ImageIndexSelectorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  I: Integer;
  List: TImageSequenceList;
  Index: Integer;
  Sequence: TImageSequence;
  Stream: TMemoryStream;
  Sequencer: TImageSequencer;
begin
  Sequencer := ImageSequencer;
  if ((Key = Ord('C')) or (Key = Ord('X'))) and (ssCtrl in Shift) then
  begin
    Stream := TMemoryStream.Create;
    List := TImageSequenceList.Create(nil, nil);
    with ImageIndexSelector do
      for I := Selection.Top to Selection.Bottom do
      begin
        Sequence := Sequencer.ImageSequenceList.GetImageSequence(I - 1);
        if Sequence <> nil then List.Add(I - Selection.Top, Sequence.Copy(nil))
        else List.Add(I - Selection.Top, nil);
      end;
    List.SaveToStream(Stream);
    Engine.CopyStreamToClipboard(Stream, 'IMAGESEQUENCELIST');
    Invalidate;
    List.Free;
    Stream.Free;
  end;
  if (Key = Ord('V')) and (ssCtrl in Shift) then
  begin
    Stream := TMemoryStream.Create;
    List := TImageSequenceList.Create(nil, nil);
    try
      if Engine.PasteStreamFromClipboard(Stream, 'IMAGESEQUENCELIST') <> -1 then
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
                Sequence := List.GetImageSequence(Index).Copy(Sequencer.ImageSequenceList);
                Sequencer.ImageSequenceList.Add(I - 1, Sequence);
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
          Sequencer.ImageSequenceList.LinkToIL;
        end;
      end;
    finally
      List.Free;
      Stream.Free;
    end;
  end;
  if ((Key = Ord('X')) or (Key = VK_DELETE)) and (ssCtrl in Shift) then
    with ImageIndexSelector do
    begin
      for I := Selection.Top to Selection.Bottom do
      begin
        Sequence := Sequencer.ImageSequenceList.GetImageSequence(I - 1);
        if Sequence <> nil then
        begin
          Sequencer.ImageSequenceList.Delete(I - 1, Sequence);
          Sequence.Free;
        end;
      end;
      Invalidate;
    end;
end;

end.
