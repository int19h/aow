unit SImgSEd;

{ The SImgSEd unit of Ilpack.dpl: the panel of the image library editor that edits the settings
  of a sub image (or of every image selected in the edit grid): its offset and size, its load
  mode, the file it was grabbed from, and its show mode (opaque, transparent, or blended with a
  blend mode and percentage). The sub controls are created when the panel gets a parent. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, ExtCtrls, ComCtrls,
  ImageLib, ILSpin, ILEdGrid;

type
  { SImgSEd.TSubImageSettingsEditor (instance size 444): +$138 the sub controls (a page control
    with the pages General and Show Mode), +$1A4 FImageLibrary, +$1A8 FUpdateLock, +$1AC
    FImageIndex, +$1B0 FSubImageIndex, +$1B4 FImage (the image shown, or nil), +$1B8
    FImageLibraryEditGrid (the grid whose selection the changes apply to). }
  TSubImageSettingsEditor = class(TCustomPanel)
  private
    FPageControl: TPageControl;
    FGeneralSheet: TTabSheet;
    FShowModeSheet: TTabSheet;
    FLoadModeLabel: TLabel;
    FLoadModeBox: TComboBox;
    FPositionGroup: TGroupBox;
    FXLabel: TLabel;
    FYLabel: TLabel;
    FXEdit: TILSpinEdit;
    FYEdit: TILSpinEdit;
    FWLabel: TLabel;
    FHLabel: TLabel;
    FWEdit: TILSpinEdit;
    FHEdit: TILSpinEdit;
    FSourceGroup: TGroupBox;
    FFileNameLabel: TLabel;
    FFileIndexLabel: TLabel;
    FFileNameEdit: TEdit;
    FFileIndexEdit: TILSpinEdit;
    FOpaqueButton: TRadioButton;
    FTransparentButton: TRadioButton;
    FBlendedButton: TRadioButton;
    FBlendPanel: TPanel;
    FBlendModeLabel: TLabel;
    FPercentageLabel: TLabel;
    FBlendModeBox: TComboBox;
    FPercentageEdit: TILSpinEdit;
    FImageLibrary: TCustomImageLibrary;
    FUpdateLock: Integer;
    FImageIndex: Integer;
    FSubImageIndex: Integer;
    FImage: TLibraryImage;
    FImageLibraryEditGrid: TImageLibraryEditGrid;
    procedure CreateSubControls;
    procedure CallILChangedEvent;
    function GetSelectedImage(Index: Integer): TLibraryImage;
    procedure SetImageLibrary(Value: TCustomImageLibrary);
    procedure SetImageIndex(Value: Integer);
    procedure SetSubImageIndex(Value: Integer);
    procedure FileIndexChanged(Sender: TObject);
    procedure XPositionChanged(Sender: TObject);
    procedure YPositionChanged(Sender: TObject);
    procedure WidthChanged(Sender: TObject);
    procedure HeightChanged(Sender: TObject);
    procedure FileNameChanged(Sender: TObject);
    procedure LoadModeChanged(Sender: TObject);
    procedure BlendPercentageChanged(Sender: TObject);
    procedure BlendModeChanged(Sender: TObject);
    procedure ShowModeChanged(Sender: TObject);
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateSettings;
    procedure SelectImage(AImageIndex, ASubImageIndex: Integer);
  published
    property ImageLibrary: TCustomImageLibrary read FImageLibrary write SetImageLibrary;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property SubImageIndex: Integer read FSubImageIndex write SetSubImageIndex;
    property ImageLibraryEditGrid: TImageLibraryEditGrid read FImageLibraryEditGrid
      write FImageLibraryEditGrid;
    property Align;
    property BevelInner;
    property BevelOuter;
    property Color;
    property Font;
  end;

implementation
uses ImgSetEd;

{ TSubImageSettingsEditor }

constructor TSubImageSettingsEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := '';
end;

procedure TSubImageSettingsEditor.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and (FPositionGroup = nil) then CreateSubControls;
end;

procedure TSubImageSettingsEditor.Loaded;
begin
  inherited Loaded;
  Caption := '';
end;

procedure TSubImageSettingsEditor.CreateSubControls;
begin
  Caption := '';
  FPageControl := TPageControl.Create(Self);
  FPageControl.Parent := Self;
  FPageControl.Align := alClient;
  FGeneralSheet := TTabSheet.Create(FPageControl);
  FGeneralSheet.PageControl := FPageControl;
  FGeneralSheet.Caption := 'General';
  FShowModeSheet := TTabSheet.Create(FPageControl);
  FShowModeSheet.PageControl := FPageControl;
  FShowModeSheet.Caption := 'Show Mode';

  { General: the position and size }
  FPositionGroup := TGroupBox.Create(Self);
  FPositionGroup.Parent := FGeneralSheet;
  FXLabel := TLabel.Create(FGeneralSheet);
  FYLabel := TLabel.Create(FGeneralSheet);
  FWLabel := TLabel.Create(FGeneralSheet);
  FHLabel := TLabel.Create(FGeneralSheet);
  FXEdit := TILSpinEdit.Create(FGeneralSheet);
  FYEdit := TILSpinEdit.Create(FGeneralSheet);
  FWEdit := TILSpinEdit.Create(FGeneralSheet);
  FHEdit := TILSpinEdit.Create(FGeneralSheet);
  with FPositionGroup do
  begin
    Left := 4;
    Top := 8;
    Width := 190;
    Height := 87;
    Caption := 'Relative Position/Size:';
  end;
  with FXLabel do
  begin
    Parent := FPositionGroup;
    Left := 8;
    Top := 24;
    Caption := 'X:';
  end;
  with FYLabel do
  begin
    Parent := FPositionGroup;
    Left := 99;
    Top := 24;
    Caption := 'Y:';
  end;
  with FXEdit do
  begin
    Parent := FPositionGroup;
    Left := 28;
    Top := 19;
    Width := 55;
    Height := 22;
    OnUpdate := XPositionChanged;
    Enabled := False;
    MinValue := -1000000;
    MaxValue := 1000000;
  end;
  with FYEdit do
  begin
    Parent := FPositionGroup;
    Left := 115;
    Top := 19;
    Width := 55;
    Height := 22;
    OnUpdate := YPositionChanged;
    Enabled := False;
    MinValue := -1000000;
    MaxValue := 1000000;
  end;
  with FWLabel do
  begin
    Parent := FPositionGroup;
    Left := 8;
    Top := 54;
    Caption := 'W:';
  end;
  with FHLabel do
  begin
    Parent := FPositionGroup;
    Left := 99;
    Top := 54;
    Caption := 'H:';
  end;
  with FWEdit do
  begin
    Parent := FPositionGroup;
    Left := 28;
    Top := 49;
    Width := 55;
    Height := 22;
    OnUpdate := WidthChanged;
    Enabled := False;
    MinValue := -1000000;
    MaxValue := 1000000;
  end;
  with FHEdit do
  begin
    Parent := FPositionGroup;
    Left := 115;
    Top := 49;
    Width := 55;
    Height := 22;
    OnUpdate := HeightChanged;
    Enabled := False;
    MinValue := -1000000;
    MaxValue := 1000000;
  end;

  { General: the load mode }
  FLoadModeLabel := TLabel.Create(FGeneralSheet);
  FLoadModeBox := TComboBox.Create(FGeneralSheet);
  with FLoadModeLabel do
  begin
    Parent := FGeneralSheet;
    Caption := 'Load Mode:';
    Left := 4;
    Top := 106;
    Width := 153;
    Height := 13;
  end;
  with FLoadModeBox do
  begin
    Parent := FGeneralSheet;
    Left := 77;
    Width := 117;
    Height := 21;
    Top := 102;
    { Put on the empty list: the combo box ignores the missing item }
    Items[0] := 'LoadAlways';
    Items[1] := 'LoadOnDemand';
    Items[2] := 'LoadFreeOnDemand';
    OnChange := LoadModeChanged;
    Enabled := False;
  end;

  { General: the source file }
  FSourceGroup := TGroupBox.Create(FGeneralSheet);
  FSourceGroup.Parent := FGeneralSheet;
  FFileNameLabel := TLabel.Create(FGeneralSheet);
  FFileIndexLabel := TLabel.Create(FGeneralSheet);
  FFileNameEdit := TEdit.Create(FGeneralSheet);
  FFileIndexEdit := TILSpinEdit.Create(FGeneralSheet);
  with FSourceGroup do
  begin
    Left := 4;
    Top := 130;
    Width := 190;
    Height := 79;
    Caption := 'Source:';
  end;
  with FFileNameLabel do
  begin
    Parent := FSourceGroup;
    Left := 8;
    Top := 20;
    Caption := 'File Name:';
  end;
  with FFileIndexLabel do
  begin
    Parent := FSourceGroup;
    Left := 8;
    Top := 46;
    Caption := 'File Index:';
  end;
  with FFileNameEdit do
  begin
    Parent := FSourceGroup;
    Left := 74;
    Top := 16;
    Width := 102;
    Height := 21;
    OnChange := FileNameChanged;
    Enabled := False;
  end;
  with FFileIndexEdit do
  begin
    Parent := FSourceGroup;
    Left := 74;
    Top := 44;
    Width := 68;
    Height := 22;
    OnChange := FileIndexChanged;
    Enabled := False;
    MinValue := -1;
    MaxValue := 100000;
  end;

  { Show Mode }
  FOpaqueButton := TRadioButton.Create(FShowModeSheet);
  FTransparentButton := TRadioButton.Create(FShowModeSheet);
  FBlendedButton := TRadioButton.Create(FShowModeSheet);
  FBlendPanel := TPanel.Create(FShowModeSheet);
  FBlendModeLabel := TLabel.Create(FBlendPanel);
  FPercentageLabel := TLabel.Create(FBlendPanel);
  FBlendModeBox := TComboBox.Create(FBlendPanel);
  FPercentageEdit := TILSpinEdit.Create(FBlendPanel);
  with FOpaqueButton do
  begin
    Parent := FShowModeSheet;
    Left := 16;
    Top := 16;
    Caption := 'Opaque';
    Checked := True;
    OnClick := ShowModeChanged;
  end;
  with FTransparentButton do
  begin
    Parent := FShowModeSheet;
    Left := 16;
    Top := 40;
    Caption := 'Transparent';
    OnClick := ShowModeChanged;
  end;
  with FBlendedButton do
  begin
    Parent := FShowModeSheet;
    Left := 16;
    Top := 64;
    Caption := 'Blended';
    OnClick := ShowModeChanged;
  end;
  with FBlendPanel do
  begin
    Parent := FShowModeSheet;
    BevelInner := bvNone;
    BevelOuter := bvLowered;
    Caption := '';
    Height := 73;
    Left := 32;
    Top := 88;
    Width := 153;
  end;
  with FBlendModeLabel do
  begin
    Parent := FBlendPanel;
    Left := 8;
    Top := 10;
    Height := 16;
    Width := 38;
    Caption := 'Mode:';
  end;
  with FPercentageLabel do
  begin
    Parent := FBlendPanel;
    Left := 8;
    Top := 40;
    Height := 16;
    Width := 73;
    Caption := 'Percentage:';
  end;
  with FBlendModeBox do
  begin
    Parent := FBlendPanel;
    Left := 48;
    Top := 8;
    Height := 24;
    Width := 97;
    Style := csDropDownList;
    Items.Add('Alpha');
    Items.Add('Brighten');
    Items.Add('Intensity');
    Items.Add('Shadow');
    OnChange := BlendModeChanged;
  end;
  with FPercentageEdit do
  begin
    Parent := FBlendPanel;
    Left := 88;
    Top := 36;
    Height := 26;
    Width := 57;
    OnChange := BlendPercentageChanged;
    MinValue := 0;
    MaxValue := 100;
  end;
end;

procedure TSubImageSettingsEditor.CallILChangedEvent;
begin
  if FUpdateLock = 0 then
  begin
    Inc(FUpdateLock);
    FImageLibrary.CallOnChangeEvent;
    Dec(FUpdateLock);
  end;
end;

{ The Index-th image the changes apply to: the images selected in the edit grid, or FImage }
function TSubImageSettingsEditor.GetSelectedImage(Index: Integer): TLibraryImage;
begin
  Result := nil;
  if FImageLibraryEditGrid <> nil then
  begin
    if FImageLibraryEditGrid.Selection.Top <> FImageLibraryEditGrid.Selection.Bottom then
      Result := FImageLibraryEditGrid.SelectedImage[Index]
    else if Index = 0 then
      Result := FImage
    else
      Result := nil;
  end
  else if Index = 0 then
    Result := FImage;
end;

procedure TSubImageSettingsEditor.UpdateSettings;
var
  Enable, MultiSelect, IsRef: Boolean;
begin
  if (FUpdateLock = 0) and (FImageLibrary <> nil) then
    with FImageLibrary do
    begin
      Inc(FUpdateLock);
      if (Count > FImageIndex) and (FImageIndex >= 0) then
      begin
        FImage := GetSafeSub(FImageIndex, FSubImageIndex);
        IsRef := FImageLibrary.IsReference(FImageIndex);
      end
      else
      begin
        FImage := nil;
        IsRef := False;
      end;
      Enable := (FImage <> nil) and not IsRef;
      MultiSelect := (FImageLibraryEditGrid <> nil) and
        (FImageLibraryEditGrid.Selection.Top <> FImageLibraryEditGrid.Selection.Bottom);
      FLoadModeBox.Enabled := MultiSelect or Enable;
      FFileNameEdit.Enabled := MultiSelect or Enable;
      FXEdit.Enabled := Enable;
      FYEdit.Enabled := Enable;
      FWEdit.Enabled := Enable;
      FHEdit.Enabled := Enable;
      FFileIndexEdit.Enabled := Enable;
      FOpaqueButton.Enabled := MultiSelect or Enable;
      FTransparentButton.Enabled := MultiSelect or Enable;
      FBlendedButton.Enabled := MultiSelect or Enable;
      if FImage <> nil then
        with FImage do
        begin
          FFileNameEdit.Text := FileName;
          FFileIndexEdit.Value := FileIndex;
          FLoadModeBox.ItemIndex := Ord(LoadMode);
          FXEdit.Value := Xshift;
          FYEdit.Value := Yshift;
          FWEdit.Value := Width;
          FHEdit.Value := Height;
          FOpaqueButton.Enabled := SupportShowMode(smOpaque, 0);
          FOpaqueButton.Checked := ShowInfo.ShowMode = smOpaque;
          FTransparentButton.Enabled := SupportShowMode(smTransparent, 0);
          FTransparentButton.Checked := ShowInfo.ShowMode = smTransparent;
          FBlendedButton.Enabled := SupportShowMode(smBlended, 0);
          FBlendedButton.Checked := ShowInfo.ShowMode = smBlended;
          FPercentageEdit.Value := ShowInfo.BlendPercentage;
          FBlendModeBox.ItemIndex := Ord(ShowInfo.BlendMode) - 1;
          FBlendPanel.Visible := ShowInfo.ShowMode = smBlended;
        end
      else
      begin
        FFileNameEdit.Text := '';
        FFileIndexEdit.Value := -1;
        FBlendPanel.Visible := MultiSelect;
      end;
      Dec(FUpdateLock);
    end;
end;

procedure TSubImageSettingsEditor.SetImageLibrary(Value: TCustomImageLibrary);
begin
  FImageLibrary := Value;
  UpdateSettings;
end;

procedure TSubImageSettingsEditor.SetImageIndex(Value: Integer);
begin
  FImageIndex := Value;
  UpdateSettings;
end;

procedure TSubImageSettingsEditor.SetSubImageIndex(Value: Integer);
begin
  FSubImageIndex := Value;
  UpdateSettings;
end;

procedure TSubImageSettingsEditor.SelectImage(AImageIndex, ASubImageIndex: Integer);
begin
  FImageIndex := AImageIndex;
  FSubImageIndex := ASubImageIndex;
  UpdateSettings;
end;

procedure TSubImageSettingsEditor.FileIndexChanged(Sender: TObject);
begin
  if FImage <> nil then
  begin
    FImage.FileIndex := FFileIndexEdit.Value;
    CallILChangedEvent;
  end;
end;

procedure TSubImageSettingsEditor.XPositionChanged(Sender: TObject);
var
  OldValue: Integer;
begin
  if (FImage <> nil) and (FXEdit.Value <> FImage.Xshift) then
  begin
    OldValue := FImage.Xshift;
    FImage.Xshift := FXEdit.Value;
    FXEdit.Value := FImage.Xshift;
    FWEdit.Value := FImage.Width;
    if OldValue <> FImage.Xshift then
    begin
      FImageLibrary.UpdateImageItemSettings(FImageIndex);
      FImageLibrary.Modified := True;
      CallILChangedEvent;
    end;
  end;
end;

procedure TSubImageSettingsEditor.YPositionChanged(Sender: TObject);
var
  OldValue: Integer;
begin
  if (FImage <> nil) and (FYEdit.Value <> FImage.Yshift) then
  begin
    OldValue := FImage.Yshift;
    FImage.Yshift := FYEdit.Value;
    FYEdit.Value := FImage.Yshift;
    FHEdit.Value := FImage.Height;
    if OldValue <> FImage.Yshift then
    begin
      FImageLibrary.UpdateImageItemSettings(FImageIndex);
      FImageLibrary.Modified := True;
      CallILChangedEvent;
    end;
  end;
end;

procedure TSubImageSettingsEditor.WidthChanged(Sender: TObject);
var
  OldValue: Integer;
begin
  if (FImage <> nil) and (FWEdit.Value <> FImage.Width) then
  begin
    OldValue := FImage.Width;
    FImage.Width := FWEdit.Value;
    FWEdit.Value := FImage.Width;
    if OldValue <> FImage.Width then
    begin
      FImageLibrary.UpdateImageItemSettings(FImageIndex);
      FImageLibrary.Modified := True;
      CallILChangedEvent;
    end;
  end;
end;

procedure TSubImageSettingsEditor.HeightChanged(Sender: TObject);
var
  OldValue: Integer;
begin
  if (FImage <> nil) and (FHEdit.Value <> FImage.Height) then
  begin
    OldValue := FImage.Height;
    FImage.Height := FHEdit.Value;
    FHEdit.Value := FImage.Height;
    if OldValue <> FImage.Height then
    begin
      FImageLibrary.UpdateImageItemSettings(FImageIndex);
      FImageLibrary.Modified := True;
      CallILChangedEvent;
    end;
  end;
end;

procedure TSubImageSettingsEditor.FileNameChanged(Sender: TObject);
var
  I: Integer;
  Image: TLibraryImage;
begin
  if FUpdateLock = 0 then
  begin
    I := 0;
    Image := GetSelectedImage(I);
    while Image <> nil do
    begin
      Image.FileName := FFileNameEdit.Text;
      Inc(I);
      Image := GetSelectedImage(I);
    end;
    CallILChangedEvent;
  end;
end;

procedure TSubImageSettingsEditor.LoadModeChanged(Sender: TObject);
var
  I: Integer;
  Image: TLibraryImage;
begin
  if FUpdateLock = 0 then
  begin
    I := 0;
    Image := GetSelectedImage(I);
    while Image <> nil do
    begin
      FImageLibrary.Modified := True;
      Image.LoadMode := TLoadMode(FLoadModeBox.ItemIndex);
      Inc(I);
      Image := GetSelectedImage(I);
    end;
  end;
end;

procedure TSubImageSettingsEditor.BlendPercentageChanged(Sender: TObject);
var
  I: Integer;
  Image: TLibraryImage;
  Info: TShowInfo;
begin
  if FUpdateLock = 0 then
  begin
    I := 0;
    Image := GetSelectedImage(I);
    while Image <> nil do
    begin
      Info := Image.ShowInfo;
      Info.BlendPercentage := FPercentageEdit.Value;
      if Info.BlendPercentage < 0 then Info.BlendPercentage := 0;
      if Info.BlendPercentage > 100 then Info.BlendPercentage := 100;
      Image.ShowInfo := Info;
      Inc(I);
      Image := GetSelectedImage(I);
    end;
    CallILChangedEvent;
  end;
end;

procedure TSubImageSettingsEditor.BlendModeChanged(Sender: TObject);
var
  I: Integer;
  Image: TLibraryImage;
  Info: TShowInfo;
begin
  if FUpdateLock = 0 then
  begin
    I := 0;
    Image := GetSelectedImage(I);
    while Image <> nil do
    begin
      Info := Image.ShowInfo;
      Info.BlendMode := TBlendMode(FBlendModeBox.ItemIndex + 1);
      Image.ShowInfo := Info;
      Inc(I);
      Image := GetSelectedImage(I);
    end;
    CallILChangedEvent;
  end;
end;

procedure TSubImageSettingsEditor.ShowModeChanged(Sender: TObject);
var
  I: Integer;
  Image: TLibraryImage;
  Info: TShowInfo;
begin
  if FUpdateLock = 0 then
  begin
    I := 0;
    Image := GetSelectedImage(I);
    while Image <> nil do
    begin
      Info := Image.ShowInfo;
      if FOpaqueButton.Checked then
        Info.ShowMode := smOpaque
      else if FTransparentButton.Checked then
        Info.ShowMode := smTransparent;
      if FBlendedButton.Checked then
      begin
        Info.ShowMode := smBlended;
        if Info.BlendPercentage = 0 then
        begin
          Info.BlendPercentage := 50;
          FPercentageEdit.Value := Info.BlendPercentage;
        end;
        FBlendPanel.Visible := True;
      end
      else
        FBlendPanel.Visible := False;
      Image.ShowInfo := Info;
      Inc(I);
      Image := GetSelectedImage(I);
    end;
  end;
  CallILChangedEvent;
end;

end.
