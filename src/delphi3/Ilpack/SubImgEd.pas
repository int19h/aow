unit SubImgEd;

{ The SubImgEd unit of Ilpack.dpl: the panel of the image library editor that lists the sub
  images of one image (an image node), with buttons that move the selected sub image up and
  down and a popup menu for cut, copy, paste and delete through the clipboard. The selection
  is passed on to a TSubImageSettingsEditor and to the SubImageSelected event. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, ExtCtrls, Buttons, Menus,
  ImageLib, SImgSEd;

type
  { SubImgEd.TEditMode }
  TEditMode = (emNone, emReadOnly, emWriteOnly, emReadWrite);

  { SubImgEd.TEditEvent: OnCut, OnCopy, OnPaste and OnDelete; False cancels the operation }
  TEditEvent = function(Sender: TObject): Boolean of object;

  { SubImgEd.TSubImageSelectedEvent }
  TSubImageSelectedEvent = procedure(Image: TLibraryImage; ImageIndex, SubImageIndex: Integer;
    Sender: TObject) of object;

  { SubImgEd.TSubImageList (instance size 344): the list box of a TSubImageEditor (its Owner).
    +$154 FPopupMenu. }
  TSubImageList = class(TListBox)
  private
    FPopupMenu: TPopupMenu;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure PopupCut(Sender: TObject);
    procedure PopupCopy(Sender: TObject);
    procedure PopupPaste(Sender: TObject);
    procedure PopupDelete(Sender: TObject);
  end;

  { SubImgEd.TSubImageEditor (instance size 400): +$138 FSubImageIndex, +$13C FButtonPanel,
    +$140 FShiftUpButton, +$144 FShiftDownButton, +$148 FList, +$14C FEditMode (not used),
    +$150 FOnCut, +$158 FOnCopy, +$160 FOnPaste, +$168 FOnDelete, +$170 FImageIndex, +$174
    FImageLibrary, +$178 FTest (not used), +$17C FSubImageSelected, +$184 FLastIndex (the sub
    image last reported, -1 or -2 to report again), +$188 FUpdateLock, +$18C
    FSubImageSettingsEditor. }
  TSubImageEditor = class(TCustomPanel)
  private
    FSubImageIndex: Integer;
    FButtonPanel: TPanel;
    FShiftUpButton: TSpeedButton;
    FShiftDownButton: TSpeedButton;
    FList: TSubImageList;
    FEditMode: TEditMode;
    FOnCut: TEditEvent;
    FOnCopy: TEditEvent;
    FOnPaste: TEditEvent;
    FOnDelete: TEditEvent;
    FImageIndex: Integer;
    FImageLibrary: TCustomImageLibrary;
    FTest: TCustomImageLibrary;
    FSubImageSelected: TSubImageSelectedEvent;
    FLastIndex: Integer;
    FUpdateLock: Integer;
    FSubImageSettingsEditor: TSubImageSettingsEditor;
    procedure ShiftBtnUpPressed(Sender: TObject);
    procedure ShiftBtnDnPressed(Sender: TObject);
    procedure CallSubImageSelectedEvent;
    procedure CallILChangedEvent;
    procedure SetImageLibrary(Value: TCustomImageLibrary);
    function GetSelectedImage: TLibraryImage;
    procedure SetImageIndex(Value: Integer);
    procedure SetSubImageIndex(Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateSettings;
    procedure ShiftUp;
    procedure ShiftDn;
    function CutCell: Boolean; virtual;
    function CopyCell: Boolean; virtual;
    function PasteCell: Boolean; virtual;
    function DeleteCell: Boolean; virtual;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property SubImageIndex: Integer read FSubImageIndex write SetSubImageIndex;
    property SelectedImage: TLibraryImage read GetSelectedImage;
    property OnCut: TEditEvent read FOnCut write FOnCut;
    property OnCopy: TEditEvent read FOnCopy write FOnCopy;
    property OnPaste: TEditEvent read FOnPaste write FOnPaste;
    property OnDelete: TEditEvent read FOnDelete write FOnDelete;
  published
    property SubImageSettingsEditor: TSubImageSettingsEditor read FSubImageSettingsEditor
      write FSubImageSettingsEditor;
    property ImageLibrary: TCustomImageLibrary read FImageLibrary write SetImageLibrary;
    property Align;
    property EditMode: TEditMode read FEditMode write FEditMode;
    property Test: TCustomImageLibrary read FTest write FTest;
    property SubImageSelected: TSubImageSelectedEvent read FSubImageSelected
      write FSubImageSelected;
    property BevelInner;
    property BevelOuter;
  end;

implementation

{ TSubImageList }

constructor TSubImageList.Create(AOwner: TComponent);
var
  Item: TMenuItem;
begin
  inherited Create(AOwner);
  Color := clBtnFace;
  FPopupMenu := TPopupMenu.Create(Self);
  Item := TMenuItem.Create(FPopupMenu);
  Item.OnClick := PopupCut;
  Item.Caption := 'Cu&t';
  Item.ShortCut := TextToShortCut('Ctrl+X');
  FPopupMenu.Items.Add(Item);
  Item := TMenuItem.Create(FPopupMenu);
  Item.OnClick := PopupCopy;
  Item.Caption := '&Copy';
  Item.ShortCut := TextToShortCut('Ctrl+C');
  FPopupMenu.Items.Add(Item);
  Item := TMenuItem.Create(FPopupMenu);
  Item.OnClick := PopupPaste;
  Item.Caption := '&Paste';
  Item.ShortCut := TextToShortCut('Ctrl+V');
  FPopupMenu.Items.Add(Item);
  Item := TMenuItem.Create(FPopupMenu);
  Item.OnClick := PopupDelete;
  Item.Caption := 'De&lete';
  Item.ShortCut := TextToShortCut('Ctrl+Del');
  FPopupMenu.Items.Add(Item);
  if not (csDesigning in ComponentState) and (PopupMenu = nil) then
    PopupMenu := FPopupMenu;
end;

procedure TSubImageList.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  Windows.SetFocus(Handle);
  TSubImageEditor(Owner).CallSubImageSelectedEvent;
end;

procedure TSubImageList.PopupCut(Sender: TObject);
begin
  TSubImageEditor(Owner).CutCell;
end;

procedure TSubImageList.PopupCopy(Sender: TObject);
begin
  TSubImageEditor(Owner).CopyCell;
end;

procedure TSubImageList.PopupPaste(Sender: TObject);
begin
  TSubImageEditor(Owner).PasteCell;
end;

procedure TSubImageList.PopupDelete(Sender: TObject);
begin
  TSubImageEditor(Owner).DeleteCell;
end;

{ TSubImageEditor }

constructor TSubImageEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImageLibrary := nil;
  FButtonPanel := TPanel.Create(Self);
  with FButtonPanel do
  begin
    Parent := Self;
    Caption := '';
    Width := 32;
    BevelOuter := bvNone;
    Align := alRight;
  end;
  FList := TSubImageList.Create(Self);
  with FList do
  begin
    Parent := Self;
    Align := alClient;
  end;
  FShiftUpButton := TSpeedButton.Create(Self);
  with FShiftUpButton do
  begin
    Parent := FButtonPanel;
    Left := 4;
    Top := 3;
    Flat := True;
    Glyph.Handle := LoadBitmap(HInstance, 'BUTTONUP');
    NumGlyphs := 2;
    Caption := '';
    OnClick := ShiftBtnUpPressed;
  end;
  FShiftDownButton := TSpeedButton.Create(Self);
  with FShiftDownButton do
  begin
    Parent := FButtonPanel;
    Left := 4;
    Top := 31;
    Flat := True;
    Glyph.Handle := LoadBitmap(HInstance, 'BUTTONDN');
    NumGlyphs := 2;
    Caption := '';
    OnClick := ShiftBtnDnPressed;
  end;
  FLastIndex := -1;
end;

procedure TSubImageEditor.ShiftBtnUpPressed(Sender: TObject);
begin
  ShiftUp;
end;

procedure TSubImageEditor.ShiftBtnDnPressed(Sender: TObject);
begin
  ShiftDn;
end;

procedure TSubImageEditor.CallSubImageSelectedEvent;
begin
  FSubImageIndex := FList.ItemIndex;
  if FSubImageIndex <> FLastIndex then
  begin
    FLastIndex := FSubImageIndex;
    if Assigned(FSubImageSelected) then
      FSubImageSelected(GetSelectedImage, FImageIndex, FSubImageIndex, Self);
  end;
end;

procedure TSubImageEditor.UpdateSettings;
var
  Index, I: Integer;
  Image: TLibraryImage;
begin
  if FUpdateLock = 0 then
  begin
    Inc(FUpdateLock);
    Index := FList.ItemIndex;
    if Index < 0 then Index := 0;
    FList.Items.Clear;
    if (FImageLibrary <> nil) and not FImageLibrary.IsReference(FImageIndex) then
    begin
      for I := 0 to FImageLibrary.GetSubCount(FImageIndex) - 1 do
      begin
        Image := FImageLibrary.GetSub(FImageIndex, I);
        FList.Items.AddObject(Image.Name + ' (' + Image.FileName + ')', Image);
      end;
      if FImageIndex >= 0 then
        FList.Items.Add('(empty)');
    end;
    FList.ItemIndex := Index;
    if (FList.ItemIndex = -1) and (FList.Items.Count <> 0) then
      FList.ItemIndex := 0;
    FSubImageIndex := FList.ItemIndex;
    FLastIndex := -2;
    if FSubImageSettingsEditor <> nil then
      FSubImageSettingsEditor.SelectImage(FImageIndex, FSubImageIndex);
    CallSubImageSelectedEvent;
    Dec(FUpdateLock);
  end;
end;

procedure TSubImageEditor.CallILChangedEvent;
begin
  if FImageLibrary <> nil then
  begin
    Inc(FUpdateLock);
    FImageLibrary.CallOnChangeEvent;
    Dec(FUpdateLock);
  end;
end;

procedure TSubImageEditor.ShiftUp;
begin
  with FList do
    if (Items.Count > 2) and (ItemIndex > 0) then
    begin
      with FImageLibrary do
        InsertSub(FImageIndex, ItemIndex - 1, GetSubImage(FImageIndex, ItemIndex));
      ItemIndex := ItemIndex - 1;
      CallILChangedEvent;
      FLastIndex := -1;
      UpdateSettings;
    end
    else
      ItemIndex := 0;
end;

procedure TSubImageEditor.ShiftDn;
begin
  with FList do
    if (Items.Count > ItemIndex + 1) and (Items.Count > 2) then
    begin
      with FImageLibrary do
        InsertSub(FImageIndex, ItemIndex + 1, GetSubImage(FImageIndex, ItemIndex));
      ItemIndex := ItemIndex + 1;
      CallILChangedEvent;
      FLastIndex := -1;
      UpdateSettings;
    end;
end;

procedure TSubImageEditor.SetImageLibrary(Value: TCustomImageLibrary);
begin
  FImageLibrary := Value;
  FLastIndex := -1;
  if not (csDesigning in ComponentState) then UpdateSettings;
end;

function TSubImageEditor.GetSelectedImage: TLibraryImage;
begin
  if FImageLibrary <> nil then
    Result := FImageLibrary.GetSafeSub(FImageIndex, FSubImageIndex)
  else
    Result := nil;
end;

procedure TSubImageEditor.SetImageIndex(Value: Integer);
begin
  FImageIndex := Value;
  FLastIndex := -1;
  UpdateSettings;
end;

procedure TSubImageEditor.SetSubImageIndex(Value: Integer);
begin
  FList.ItemIndex := Value;
  FSubImageIndex := FList.ItemIndex;
  if FSubImageSettingsEditor <> nil then
    FSubImageSettingsEditor.SelectImage(FImageIndex, FSubImageIndex);
end;

function TSubImageEditor.DeleteCell: Boolean;
begin
  if Assigned(FOnDelete) then
    Result := FOnDelete(Self)
  else
    Result := True;
  if Result and (FImageLibrary <> nil) and (FSubImageIndex <> -1) then
  begin
    FImageLibrary.DeleteSub(FImageIndex, FSubImageIndex);
    FLastIndex := -1;
    UpdateSettings;
    CallILChangedEvent;
  end;
end;

function TSubImageEditor.CutCell: Boolean;
var
  IL: TCustomImageLibrary;
begin
  if Assigned(FOnCut) then
    Result := FOnCut(Self)
  else
    Result := True;
  if Result and (FSubImageIndex <> -1) then
  begin
    IL := TImageLibrary.Create(nil);
    if FImageLibrary.GetSafeSub(FImageIndex, FSubImageIndex) <> nil then
      IL.Add(FImageLibrary.GetSubImage(FImageIndex, FSubImageIndex))
    else
      IL.Add(nil);
    IL.CopyToClipboard;
    IL.Free;
    FLastIndex := -1;
    UpdateSettings;
    CallILChangedEvent;
  end;
end;

function TSubImageEditor.CopyCell: Boolean;
var
  IL: TCustomImageLibrary;
begin
  if Assigned(FOnCopy) then
    Result := FOnCopy(Self)
  else
    Result := True;
  if Result and (FSubImageIndex <> -1) then
  begin
    IL := TImageLibrary.Create(nil);
    if FImageLibrary.GetSafeSub(FImageIndex, FSubImageIndex) <> nil then
      IL.Add(FImageLibrary.GetSub(FImageIndex, FSubImageIndex).Copy)
    else
      IL.Add(nil);
    IL.CopyToClipboard;
    IL.Free;
  end;
end;

{ Inserts the images of the clipboard library (image nodes excepted) before the selected sub
  image, the last one first. }
function TSubImageEditor.PasteCell: Boolean;
var
  IL: TCustomImageLibrary;
  I: Integer;
begin
  if Assigned(FOnPaste) then
    Result := FOnPaste(Self)
  else
    Result := True;
  if Result and (FSubImageIndex <> -1) then
  begin
    IL := TImageLibrary.Create(nil);
    IL.PasteFromClipboard;
    for I := IL.Count - 1 downto 0 do
      if IL[I].ClassID <> $100 then
        FImageLibrary.InsertSub(FImageIndex, FSubImageIndex, IL.GetImage(I));
    IL.Free;
    FLastIndex := -1;
    UpdateSettings;
    CallILChangedEvent;
  end;
end;

end.
