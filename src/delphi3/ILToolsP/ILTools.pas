unit ILTools;

{ Image sequence authoring controls from ILToolsP.dpl, recovered from the original code
  and RTTI. Range checking is enabled in this unit. }

{$R+}

interface

uses Windows, SysUtils, Classes, Controls, Forms, Dialogs, ComCtrls, GFXE, ImageLib, DisplayC;

type
  TImageSequencer = class;
  TSequenceLayerSelector = class;
  TSequenceDisplayEditor = class;
  TOnCreateImageSequenceEvent = procedure(ImageSequencer: TImageSequencer; CreatedImageSequence: TImageSequence) of object;
  TOnShowImageSequenceEvent = procedure(ImageSequence: TImageSequence; ImageIndex, Xshow, Yshow: Integer; SurfaceDesc: TSurfaceDesc) of object;

  { TImageSequencer: instance size $4C; $24 manager, $28 change event,
    $30 create event, $38 sequences, $3C index, $40 current, $44 selector, $48 display. }
  TImageSequencer = class(TComponent)
  public
    FILManager: TImageLibraryManager;
    FOnChange: TNotifyEvent;
    FOnCreateImageSequence: TOnCreateImageSequenceEvent;
    FImageSequenceList: TImageSequenceList;
    FCurrentSequenceIndex: Integer;
    FCurrentImageSequence: TImageSequence;
    FLayerSelector: TSequenceLayerSelector;
    FDisplayEditor: TSequenceDisplayEditor;
    destructor Destroy; override;
    procedure SetImageSequenceList(Value: TImageSequenceList);
    procedure CurrentImageSequenceUpdated;
    procedure SetCurrentImageSequence(Value: TImageSequence);
    procedure SetCurrentSequenceIndex(Value: Integer);
    procedure AddSequenceLayer;
    procedure DeleteSequenceLayer;
    procedure IncreaseLayer;
    procedure DecreaseLayer;
    property ImageSequenceList: TImageSequenceList read FImageSequenceList write SetImageSequenceList;
    property CurrentImageSequence: TImageSequence read FCurrentImageSequence write SetCurrentImageSequence;
    property CurrentSequenceIndex: Integer read FCurrentSequenceIndex write SetCurrentSequenceIndex;
  published
    property ILManager: TImageLibraryManager read FILManager write FILManager;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCreateImageSequence: TOnCreateImageSequenceEvent read FOnCreateImageSequence write FOnCreateImageSequence;
  end;

  { TSequenceLayerSelector: instance size $144; $140 image sequencer. }
  TSequenceLayerSelector = class(TTabControl)
  public
    FImageSequencer: TImageSequencer;
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure SetImageSequencer(Value: TImageSequencer);
    procedure UpdateSettings;
    procedure Change; override;
    procedure UpdateTabs;
  published
    property ImageSequencer: TImageSequencer read FImageSequencer write SetImageSequencer;
  end;

  { TSequenceDisplayEditor: instance size $1E0; $1AC sequencer, $1B0 preview indices,
    $1B4 frame, $1B8/$1BC center, $1C0 dragging, $1C4 start event,
    $1CC/$1D0 last mouse position, $1D4 show event, $1DC looped. }
  TSequenceDisplayEditor = class(TDisplay)
  public
    FImageSequencer: TImageSequencer;
    FPreviewFrames: TFrameTableList;
    FFrameCount: Integer;
    FImageCenterX: Integer;
    FImageCenterY: Integer;
    FDraggingImage: Boolean;
    FOnStartUpdateFrame: TUpdateFrameEvent;
    FLastMouseX: Integer;
    FLastMouseY: Integer;
    FOnShowImageSequence: TOnShowImageSequenceEvent;
    FShowLooped: Boolean;
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
    procedure ResizeBackSurfaces(AWidth, AHeight: Integer); override;
    procedure UpdateFrame; override;
    procedure SetImageSequencer(Value: TImageSequencer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure UpdateSettings;
  published
    property ImageSequencer: TImageSequencer read FImageSequencer write SetImageSequencer;
    property FrameCount: Integer read FFrameCount write FFrameCount;
    property ImageCenterX: Integer read FImageCenterX write FImageCenterX;
    property ImageCenterY: Integer read FImageCenterY write FImageCenterY;
    property DraggingImage: Boolean read FDraggingImage;
    property PreviewFrames: TFrameTableList read FPreviewFrames;
    property OnStartUpdateFrame: TUpdateFrameEvent read FOnStartUpdateFrame write FOnStartUpdateFrame;
    property OnShowImageSequence: TOnShowImageSequenceEvent read FOnShowImageSequence write FOnShowImageSequence;
    property ShowLooped: Boolean read FShowLooped write FShowLooped;
  end;

procedure Register;

implementation

destructor TImageSequencer.Destroy;
var
  L: TSequenceLayerSelector;
  D: TSequenceDisplayEditor;
begin
  L := FLayerSelector;
  if L <> nil then L.SetImageSequencer(nil);
  D := FDisplayEditor;
  if D <> nil then D.SetImageSequencer(nil);
  inherited Destroy;
end;

procedure TImageSequencer.SetImageSequenceList(Value: TImageSequenceList);
begin
  FImageSequenceList := Value;
  FImageSequenceList.LinkToIL;
  SetCurrentSequenceIndex(0);
end;

procedure TImageSequencer.CurrentImageSequenceUpdated;
var
  L: TSequenceLayerSelector;
  D: TSequenceDisplayEditor;
begin
  L := FLayerSelector;
  if L <> nil then L.UpdateSettings;
  D := FDisplayEditor;
  if D <> nil then D.UpdateSettings;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TImageSequencer.SetCurrentImageSequence(Value: TImageSequence);
begin
  if FImageSequenceList <> nil then
  begin
    FCurrentImageSequence := Value;
    CurrentImageSequenceUpdated;
  end;
end;

procedure TImageSequencer.SetCurrentSequenceIndex(Value: Integer);
begin
  if FImageSequenceList <> nil then
  begin
    FCurrentSequenceIndex := Value;
    SetCurrentImageSequence(FImageSequenceList.GetImageSequence(Value));
  end;
end;

procedure TImageSequencer.AddSequenceLayer;
var
  S, LastSequence: TImageSequence;
begin
  S := TImageSequence.Create(FImageSequenceList);
  with FImageSequenceList do
  begin
    LastSequence := GetSubImageSequence(FCurrentSequenceIndex, GetSubCount(FCurrentSequenceIndex) - 1);
    if LastSequence <> nil then S.Layer := LastSequence.Layer + 1;
    Add(FCurrentSequenceIndex, S);
  end;
  if Assigned(FOnCreateImageSequence) then FOnCreateImageSequence(Self, S);
  S.LinkToIL;
  SetCurrentImageSequence(S);
end;

procedure TImageSequencer.DeleteSequenceLayer;
var
  LayerName: string;
  S: TImageSequence;
begin

  if FCurrentImageSequence <> nil then
    with FCurrentImageSequence do
    begin
      if Layer = 0 then LayerName := 'Ground Layer'
      else LayerName := 'Layer ' + IntToStr(Layer);
      if MessageDlg('Remove ' + LayerName + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        FImageSequenceList.Delete(FCurrentSequenceIndex, FCurrentImageSequence);
        FCurrentImageSequence.Free;
        SetCurrentSequenceIndex(FCurrentSequenceIndex);
      end;
    end;
end;

procedure TImageSequencer.IncreaseLayer;
var
  NewLayer: Integer;
  FreeLayer: Boolean;
begin
  with FCurrentImageSequence do
    if Self.FCurrentImageSequence <> nil then
    begin
      NewLayer := FCurrentImageSequence.Layer + 1;
      FreeLayer := FImageSequenceList.GetLayerImageSequence(FCurrentSequenceIndex, NewLayer) = nil;
      while not FreeLayer and (NewLayer <> 255) do
      begin
        Inc(NewLayer);
        FreeLayer := FImageSequenceList.GetLayerImageSequence(FCurrentSequenceIndex, NewLayer) = nil;
      end;
      if FreeLayer then
      begin
        FCurrentImageSequence.Layer := NewLayer;
        FImageSequenceList.Delete(FCurrentSequenceIndex, FCurrentImageSequence);
        FImageSequenceList.Add(FCurrentSequenceIndex, FCurrentImageSequence);
        CurrentImageSequenceUpdated;
      end;
    end;
end;

procedure TImageSequencer.DecreaseLayer;
var
  NewLayer: Integer;
  FreeLayer: Boolean;
begin
  with FCurrentImageSequence do
    if (Self.FCurrentImageSequence <> nil) and (FCurrentImageSequence.Layer <> 0) then
    begin
      NewLayer := FCurrentImageSequence.Layer - 1;
      FreeLayer := FImageSequenceList.GetLayerImageSequence(FCurrentSequenceIndex, NewLayer) = nil;
      while not FreeLayer and (NewLayer > 0) do
      begin
        Dec(NewLayer);
        FreeLayer := FImageSequenceList.GetLayerImageSequence(FCurrentSequenceIndex, NewLayer) = nil;
      end;
      if FreeLayer then
      begin
        FCurrentImageSequence.Layer := NewLayer;
        FImageSequenceList.Delete(FCurrentSequenceIndex, FCurrentImageSequence);
        FImageSequenceList.Add(FCurrentSequenceIndex, FCurrentImageSequence);
        CurrentImageSequenceUpdated;
      end;
    end;
end;

constructor TSequenceDisplayEditor.Create(AOwner: TComponent);
begin
  FPreviewFrames := TFrameTableList.Create;
  FShowLooped := True;
  inherited Create(AOwner);
end;

destructor TSequenceDisplayEditor.Destroy;
var
  S: TImageSequencer;
begin
  FPreviewFrames.Free;
  S := FImageSequencer;
  if S <> nil then S.FDisplayEditor := nil;
  inherited Destroy;
end;

procedure TSequenceDisplayEditor.SetImageSequencer(Value: TImageSequencer);
var
  S: TImageSequencer;
begin
  S := FImageSequencer;
  if S <> nil then S.FDisplayEditor := nil;
  FImageSequencer := Value;
  if FImageSequencer <> nil then FImageSequencer.FDisplayEditor := Self;
end;

procedure TSequenceDisplayEditor.ResizeBackSurfaces(AWidth, AHeight: Integer);
begin
  FImageCenterX := AWidth shr 1;
  FImageCenterY := AHeight shr 1;
  inherited ResizeBackSurfaces(AWidth, AHeight);
end;

procedure TSequenceDisplayEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    MouseCapture := True;
    SetCaptureControl(Self);
    FDraggingImage := True;
    FLastMouseX := X;
    FLastMouseY := Y;
    Cursor := -12;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TSequenceDisplayEditor.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FDraggingImage and (FImageSequencer <> nil) and (FImageSequencer.FCurrentImageSequence <> nil) then
  begin
    with FImageSequencer.FCurrentImageSequence do
    begin
      dXshift := dXshift + (X - FLastMouseX);
      dYshift := dYshift + (Y - FLastMouseY);
    end;
    FLastMouseX := X;
    FLastMouseY := Y;
  end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TSequenceDisplayEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FDraggingImage then
  begin
    FDraggingImage := False;
    ReleaseCapture;
    Cursor := crDefault;
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TSequenceDisplayEditor.UpdateFrame;
var
  S: TImageSequence;
  ImageIndex, I: Integer;
  SD: TSurfaceDesc;
  Lib: TCustomImageLibrary;
begin
  ActiveDC.GetSurface(1).Cls(Color);
  Inc(FFrameCount);
  if FFrameCount > $FFFFF then FFrameCount := 0;
  if Assigned(FOnStartUpdateFrame) then FOnStartUpdateFrame(Self, ActiveDC, FSurfaceIndex);
  ActiveDC.GetSurface(1).Lock(SD);
  with FImageSequencer do
    if FImageSequenceList <> nil then
      if FPreviewFrames.Count <> 0 then
        for I := 0 to FPreviewFrames.Count - 1 do
        begin
          S := FImageSequenceList.GetImageSequence(FPreviewFrames[I]);
          while S <> nil do
          begin
            Lib := S.ImageLibrary;
              if (Lib <> nil) and (Lib.Count <> 0) then
              begin
                ImageIndex := S.GetFrameIndex(FFrameCount, 0);
                if (ImageIndex <> -1) and S.ImageLibrary.ImageExist(ImageIndex) then
                  S.ImageLibrary.Get(ImageIndex).ShowClipped(FImageCenterX + S.dXshift, FImageCenterY + S.dYshift, SD);
              end
              else ImageIndex := -1;
            if Assigned(FOnShowImageSequence) then
              FOnShowImageSequence(S, ImageIndex, FImageCenterX + S.dXshift, FImageCenterY + S.dYshift, SD);
            S := S.Next;
          end;
        end
      else
      begin
        S := FImageSequenceList.GetImageSequence(FCurrentSequenceIndex);
        while S <> nil do
        begin
          Lib := S.ImageLibrary;
            if (Lib <> nil) and (Lib.Count <> 0) then
            begin
              if FShowLooped then ImageIndex := S.GetFrameIndex(FFrameCount, 0)
              else ImageIndex := S.GetUnloopedFrameIndex(FFrameCount);
              if (ImageIndex <> -1) and (S.ImageLibrary <> nil) and S.ImageLibrary.ImageExist(ImageIndex) then
                S.ImageLibrary.Get(ImageIndex).Show(FImageCenterX + S.dXshift, FImageCenterY + S.dYshift, SD);
              if Assigned(FOnShowImageSequence) then
                FOnShowImageSequence(S, ImageIndex, FImageCenterX + S.dXshift, FImageCenterY + S.dYshift, SD);
            end;
          S := S.Next;
        end;
      end;
  ActiveDC.GetSurface(1).Unlock;
  inherited UpdateFrame;
end;

procedure TSequenceDisplayEditor.UpdateSettings;
begin
end;

constructor TSequenceLayerSelector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TSequenceLayerSelector.Destroy;
var
  S: TImageSequencer;
begin
  S := FImageSequencer;
  if S <> nil then S.FLayerSelector := nil;
  inherited Destroy;
end;

procedure TSequenceLayerSelector.SetImageSequencer(Value: TImageSequencer);
var
  S: TImageSequencer;
begin
  S := FImageSequencer;
  if S <> nil then S.FLayerSelector := nil;
  FImageSequencer := Value;
  if FImageSequencer <> nil then FImageSequencer.FLayerSelector := Self;
end;

procedure TSequenceLayerSelector.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (Parent <> nil) and (Tabs.Count = 0) then Tabs.Add('Empty');
end;

procedure TSequenceLayerSelector.UpdateSettings;
begin
  if FImageSequencer.FImageSequenceList <> nil then UpdateTabs;
end;

procedure TSequenceLayerSelector.Change;
begin
  if (Tabs[TabIndex] <> 'Empty') and (FImageSequencer <> nil) then
    with FImageSequencer do
      SetCurrentImageSequence(FImageSequenceList.GetSubImageSequence(FCurrentSequenceIndex, TabIndex));
end;

procedure TSequenceLayerSelector.UpdateTabs;
var
  Strings: TStringList;
  S: TImageSequence;
begin
  with FImageSequencer do
  begin
    Strings := TStringList.Create;
    S := FImageSequenceList.GetImageSequence(FCurrentSequenceIndex);
    if S <> nil then
      while S <> nil do
      begin
        if S.Layer = 0 then Strings.Add('Base Layer')
        else Strings.Add('Layer ' + IntToStr(S.Layer));
        S := S.Next;
      end
    else Strings.Add('Empty');
    if not Tabs.Equals(Strings) then Tabs := Strings;
    TabIndex := FImageSequenceList.IndexOfSub(FCurrentSequenceIndex, FCurrentImageSequence);
    if TabIndex = -1 then TabIndex := 0;
    Strings.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('ImageLibrary', [TImageSequencer]);
  RegisterComponents('ImageLibrary', [TSequenceLayerSelector]);
  RegisterComponents('ImageLibrary', [TSequenceDisplayEditor]);
end;

initialization
finalization

end.
