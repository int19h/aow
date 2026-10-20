unit ImgSetEd;

{ The ImgSetEd unit of Ilpack.dpl: the panel of the image library editor that shows the
  settings of one image: the index of the image it refers to (an image reference, -1 for none)
  and its dimensions. The sub controls are created when the panel gets a parent. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, StdCtrls, ExtCtrls,
  ImageLib, ILSpin;

type
  { ImgSetEd.TImageSettingsEditor (instance size 340): +$138 FRefLabel, +$13C FRefEdit, +$140
    FDimLabel, +$144 FDimPanel, +$148 FImageLibrary, +$14C FUpdateLock, +$150 FImageIndex. }
  TImageSettingsEditor = class(TCustomPanel)
  private
    FRefLabel: TLabel;
    FRefEdit: TILSpinEdit;
    FDimLabel: TLabel;
    FDimPanel: TPanel;
    FImageLibrary: TCustomImageLibrary;
    FUpdateLock: Integer;
    FImageIndex: Integer;
    procedure CreateSubControls;
    procedure SetImageLibrary(Value: TCustomImageLibrary);
    procedure SetImageIndex(Value: Integer);
    procedure UpdateBoundingRect;
    procedure CallILChangedEvent;
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateSettings;
    procedure ReferenceValueUpdate(Sender: TObject);
  published
    property ImageLibrary: TCustomImageLibrary read FImageLibrary write SetImageLibrary;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property Align;
    property BevelInner;
    property BevelOuter;
    property Color;
  end;

implementation

{ TImageSettingsEditor }

constructor TImageSettingsEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := '';
end;

procedure TImageSettingsEditor.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and (FRefLabel = nil) then CreateSubControls;
end;

procedure TImageSettingsEditor.Loaded;
begin
  inherited Loaded;
  Caption := '';
end;

procedure TImageSettingsEditor.CreateSubControls;
begin
  Caption := '';
  FRefLabel := TLabel.Create(Self);
  FRefEdit := TILSpinEdit.Create(Self);
  with FRefLabel do
  begin
    Parent := Self;
    Left := 8;
    Top := 12;
    Caption := 'Reference Index:';
  end;
  with FRefEdit do
  begin
    Parent := Self;
    Left := 115;
    Top := 8;
    Width := 67;
    MinValue := -1;
    MaxValue := $FFFFFF;
    OnUpdate := ReferenceValueUpdate;
  end;
  FDimLabel := TLabel.Create(Self);
  FDimPanel := TPanel.Create(Self);
  with FDimLabel do
  begin
    Parent := Self;
    Left := 8;
    Top := 40;
    Caption := 'Dimensions:';
  end;
  with FDimPanel do
  begin
    Parent := Self;
    Left := 8;
    Top := 56;
    Caption := '';
    BevelOuter := bvLowered;
    Width := 157;
    Height := 20;
  end;
end;

procedure TImageSettingsEditor.SetImageLibrary(Value: TCustomImageLibrary);
begin
  FImageLibrary := Value;
  UpdateSettings;
end;

procedure TImageSettingsEditor.SetImageIndex(Value: Integer);
begin
  FImageIndex := Value;
  UpdateSettings;
end;

procedure TImageSettingsEditor.UpdateBoundingRect;
var
  Image: TLibraryImage;
begin
  Image := FImageLibrary.GetSafe(FImageIndex);
  if Image <> nil then
    FDimPanel.Caption := IntToStr(Image.Width) + ' x ' + IntToStr(Image.Height)
  else
    FDimPanel.Caption := '';
end;

procedure TImageSettingsEditor.CallILChangedEvent;
begin
  if FUpdateLock = 0 then
  begin
    Inc(FUpdateLock);
    FImageLibrary.CallOnChangeEvent;
    Dec(FUpdateLock);
  end;
end;

procedure TImageSettingsEditor.UpdateSettings;
begin
  if (FUpdateLock = 0) and (FImageLibrary <> nil) then
    with FImageLibrary do
    begin
      Inc(FUpdateLock);
      if (Count > FImageIndex) and (FImageIndex >= 0) then
        FRefEdit.Value := FImageLibrary.GetImageReference(FImageIndex);
      UpdateBoundingRect;
      Dec(FUpdateLock);
    end;
end;

procedure TImageSettingsEditor.ReferenceValueUpdate(Sender: TObject);
var
  Confirmed: Boolean;
begin
  if FImageLibrary <> nil then
  begin
    Confirmed := True;
    if (FRefEdit.Value <> -1) and (FImageLibrary.GetSafe(FImageIndex) <> nil) and
      not FImageLibrary.IsReference(FImageIndex) then
    begin
      Confirmed := MessageDlg('Creating a reference will destroy all sub-images, do you want to continue?',
        mtWarning, [mbYes, mbNo], 0) = mrYes;
      if Confirmed then
        FImageLibrary.SetImage(FImageIndex, nil);
    end;
    if not Confirmed then
      FRefEdit.Value := -1
    else
    begin
      FImageLibrary.SetImageReference(FImageIndex, FRefEdit.Value);
      UpdateSettings;
      CallILChangedEvent;
    end;
  end;
end;

end.
