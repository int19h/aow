unit ILEdGrid;

{ The ILEdGrid unit of Ilpack.dpl: the grid of the image library editor (ILEdForm). One row per
  image of the library (row 0 is the header): the index and the file name of the image, or
  "(empty)", or the index an image reference points to. A popup menu offers the performance
  dialog (PerfDlg), cut, copy and paste through the clipboard, delete, insert and remove rows,
  and saving the selected images as 24-bit bitmaps. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, Grids, Menus, GFXE, ImageLib;

type
  { ILEdGrid.TEditEvent: OnEditCell; the result is not used }
  TEditEvent = function(Sender: TObject): Boolean of object;

  { ILEdGrid.TImageLibraryEditGrid (instance size 520): +$1E0 FMultiSelected (more than one row
    selected), +$1E4 FPopupMenu, +$1E8 FEditMode, +$1EC FOnMultiSelect, +$1F4 FOnEditCell, +$1FC
    FImageLibrary, +$200 FSelectionEnabled, +$204 FImageIndex. }
  TImageLibraryEditGrid = class(TDrawGrid)
  private
    FMultiSelected: Boolean;
    FPopupMenu: TPopupMenu;
    FEditMode: TILGridEditMode;
    FOnMultiSelect: TNotifyEvent;
    FOnEditCell: TEditEvent;
    FImageLibrary: TCustomImageLibrary;
    FSelectionEnabled: Boolean;
    FImageIndex: Integer;
    procedure SetImageIndex(Value: Integer);
    function GetSelectedImage(Index: Integer): TLibraryImage;
    procedure SetImageLibrary(Value: TCustomImageLibrary);
    procedure PerformanceClick(Sender: TObject);
    procedure PopupCut(Sender: TObject);
    procedure PopupCopy(Sender: TObject);
    procedure PopupPaste(Sender: TObject);
    procedure PopupDelete(Sender: TObject);
    procedure PopupIns(Sender: TObject);
    procedure PopupDel(Sender: TObject);
    procedure SaveAsBmpClick(Sender: TObject);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WndProc(var Message: TMessage); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SelectAll;
    procedure UpdateSettings;
    procedure CutCell; virtual;
    procedure CopyCell; virtual;
    procedure PasteCell; virtual;
    procedure DeleteCell; virtual;
    procedure InsCell; virtual;
    procedure DelCell; virtual;
    procedure EditCell; virtual;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property SelectedImage[Index: Integer]: TLibraryImage read GetSelectedImage;
    property MultiSelected: Boolean read FMultiSelected;
    property EditMode: TILGridEditMode read FEditMode write FEditMode;
  published
    property ImageLibrary: TCustomImageLibrary read FImageLibrary write SetImageLibrary;
    property OnMultiSelect: TNotifyEvent read FOnMultiSelect write FOnMultiSelect;
    property OnEditCell: TEditEvent read FOnEditCell write FOnEditCell;
    property SelectionEnabled: Boolean read FSelectionEnabled write FSelectionEnabled;
  end;

implementation

uses
  PerfDlg;

{ TImageLibraryEditGrid }

constructor TImageLibraryEditGrid.Create(AOwner: TComponent);
var
  Item: TMenuItem;
begin
  inherited Create(AOwner);
  ScrollBars := ssVertical;
  FixedCols := 0;
  FixedRows := 1;
  RowCount := 2;
  ColCount := 2;
  ColWidths[0] := 38;
  ColWidths[1] := 76;
  DefaultRowHeight := 18;
  Color := clBtnFace;
  FEditMode := [igCut, igCopy, igPaste, igDelete, igIns, igDel];
  Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect,
    goDrawFocusSelected, goRowSelect];
  FPopupMenu := TPopupMenu.Create(Self);
  Item := TMenuItem.Create(FPopupMenu);
  Item.OnClick := PerformanceClick;
  Item.Caption := 'Performance';
  FPopupMenu.Items.Add(Item);
  FPopupMenu.Items.Add(NewLine);
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
  FPopupMenu.Items.Add(NewLine);
  Item := TMenuItem.Create(FPopupMenu);
  Item.OnClick := PopupIns;
  Item.Caption := '&Insert';
  Item.ShortCut := TextToShortCut('Ins');
  FPopupMenu.Items.Add(Item);
  Item := TMenuItem.Create(FPopupMenu);
  Item.OnClick := PopupDel;
  Item.Caption := '&Delete';
  Item.ShortCut := TextToShortCut('Del');
  FPopupMenu.Items.Add(Item);
  FPopupMenu.Items.Add(NewLine);
  Item := TMenuItem.Create(FPopupMenu);
  Item.OnClick := SaveAsBmpClick;
  Item.Caption := 'Save as 24-bit bmp';
  Item.ShortCut := 0;
  FPopupMenu.Items.Add(Item);
  if not (csDesigning in ComponentState) and (PopupMenu = nil) then
    PopupMenu := FPopupMenu;
end;

procedure TImageLibraryEditGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  Windows.SetFocus(Handle);
end;

procedure TImageLibraryEditGrid.SetImageIndex(Value: Integer);
begin
  Row := Value + 1;
  FImageIndex := Row - 1;
end;

{ The Index-th image of the selection, counting the sub images of each selected image }
function TImageLibraryEditGrid.GetSelectedImage(Index: Integer): TLibraryImage;
var
  I, SubIndex: Integer;
begin
  SubIndex := 0;
  I := Selection.Top - 1;
  Result := nil;
  while (Index <> -1) and (I < Selection.Bottom) do
  begin
    Result := FImageLibrary.GetSafeSub(I, SubIndex);
    if Result = nil then
    begin
      Inc(I);
      SubIndex := 0;
    end
    else
    begin
      Dec(Index);
      Inc(SubIndex);
    end;
  end;
  if Index <> -1 then Result := nil;
end;

function TImageLibraryEditGrid.SelectCell(ACol, ARow: Longint): Boolean;
begin
  { the row, not the image index (ImageIndex is Row - 1 elsewhere) }
  FImageIndex := ARow;
  Result := inherited SelectCell(ACol, ARow);
end;

procedure TImageLibraryEditGrid.SetImageLibrary(Value: TCustomImageLibrary);
begin
  FImageLibrary := Value;
  Update;
end;

procedure TImageLibraryEditGrid.PerformanceClick(Sender: TObject);
var
  Dlg: TPerformanceDlg;
begin
  if FImageLibrary.GetSafe(Row - 1) <> nil then
  begin
    Dlg := TPerformanceDlg.CreateDialog(Self, FImageLibrary.GetSafe(Row - 1));
    Dlg.ShowModal;
    Dlg.Destroy;
  end;
end;

procedure TImageLibraryEditGrid.PopupCut(Sender: TObject);
begin
  CutCell;
end;

procedure TImageLibraryEditGrid.PopupCopy(Sender: TObject);
begin
  CopyCell;
end;

procedure TImageLibraryEditGrid.PopupPaste(Sender: TObject);
begin
  PasteCell;
end;

procedure TImageLibraryEditGrid.PopupDelete(Sender: TObject);
begin
  DeleteCell;
end;

procedure TImageLibraryEditGrid.PopupIns(Sender: TObject);
begin
  InsCell;
end;

procedure TImageLibraryEditGrid.PopupDel(Sender: TObject);
begin
  DelCell;
end;

{ Saves every selected image as <library file name without extension><index>.bmp. The loop
  runs over the selected rows, not the image indices (Row - 1): the original saves the image
  below each selected row. }
procedure TImageLibraryEditGrid.SaveAsBmpClick(Sender: TObject);
var
  Surface: TDIBSurface;
  FileName: string;
  I: Integer;
  Image: TLibraryImage;
  PixelFormatID: Integer;
  SD: TSurfaceDesc;
begin
  FileName := ExpandFileName(FImageLibrary.FileName);
  if Pos('.', FileName) <> 0 then
    FileName := Copy(FileName, 1, Pos('.', FileName) - 1);
  Surface := TDIBSurface.Create;
  for I := Selection.Top to Selection.Bottom do
  begin
    Image := FImageLibrary.GetSafe(I);
    if Image <> nil then
    begin
      if Image.SupportShowMode(Image.ShowInfo.ShowMode, pfRGB24) then
        PixelFormatID := pfRGB24
      else if Image.SupportShowMode(Image.ShowInfo.ShowMode, pfRGB565) then
        PixelFormatID := pfRGB565
      else
        PixelFormatID := 0;
      if PixelFormatID <> 0 then
        if Succeeded(Surface.Setup(Image.Width, Image.Height, PixelFormatID, nil)) then
        begin
          Surface.Lock(SD);
          Image.Show(0, 0, SD);
          Surface.Unlock;
          Surface.SaveToBMP24(FileName + IntToStr(I) + '.bmp');
        end;
    end;
  end;
  Surface.Free;
end;

procedure TImageLibraryEditGrid.SelectAll;
var
  R: TGridRect;
begin
  R.Left := 0;
  R.Top := 1;
  R.Right := ColCount - 1;
  R.Bottom := RowCount - 1;
  Selection := R;
end;

procedure TImageLibraryEditGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if ssCtrl in Shift then
    case Key of
      Ord('X'): CutCell;
      Ord('C'): CopyCell;
      Ord('V'): PasteCell;
      Ord('A'): SelectAll;
      VK_DELETE: DeleteCell;
    end;
  if Shift = [] then
    case Key of
      VK_INSERT: InsCell;
      VK_DELETE: DelCell;
    end;
  inherited KeyDown(Key, Shift);
end;

procedure TImageLibraryEditGrid.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_KEYDOWN then Message.Result := 0;
  inherited WndProc(Message);
end;

procedure TImageLibraryEditGrid.WMSize(var Message: TWMSize);
begin
  inherited;
  if not (csLoading in ComponentState) then
    ColWidths[1] := Width - (Width - ClientRect.Right) - ColWidths[0] - 2;
end;

procedure TImageLibraryEditGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  Centered: Boolean;
  Image: TLibraryImage;
  S: string;
begin
  Centered := False;
  if not FMultiSelected and (Selection.Top <> Selection.Bottom) then
  begin
    { Notify only when the selection first becomes multiple rows. }

    if Assigned(FOnMultiSelect) then FOnMultiSelect(Self);
    FMultiSelected := True;

  end
  else
    FMultiSelected := Selection.Top <> Selection.Bottom;
  Inc(ARect.Left, 2);
  Inc(ARect.Top, 2);
  Dec(ARect.Right, 2);
  if ARow <> 0 then
  begin
    if ACol <> 0 then
    begin
      if FImageLibrary <> nil then
      begin
        Image := FImageLibrary.GetSafe(ARow - 1);
        if Image <> nil then
          S := Image.FileName
        else
          S := '(empty)';
        if FImageLibrary.IsReference(ARow - 1) then
          S := 'Reference->' + IntToStr(FImageLibrary.GetImageReference(ARow - 1));
      end;
    end
    else
    begin
      Centered := True;
      S := IntToStr(ARow - 1);
    end;
  end
  else if ACol = 0 then
    S := 'Index'
  else
    S := 'Image(s)';
  if Centered then
  begin
    SetTextAlign(Canvas.Handle, TA_CENTER);
    ExtTextOut(Canvas.Handle, (ARect.Right + ARect.Left) div 2, ARect.Top,
      ETO_CLIPPED or ETO_OPAQUE, @ARect, PChar(S), Length(S), nil);
  end
  else
  begin
    SetTextAlign(Canvas.Handle, TA_LEFT);
    ExtTextOut(Canvas.Handle, ARect.Left, ARect.Top, ETO_CLIPPED or ETO_OPAQUE, @ARect,
      PChar(S), Length(S), nil);
  end;
end;

procedure TImageLibraryEditGrid.UpdateSettings;
var
  IL: TCustomImageLibrary;
  N, Rows: Integer;
begin
  IL := FImageLibrary;
  if IL <> nil then
  begin
    N := IL.Count;
    Rows := N; Rows := Integer(Longint(Rows));
    Inc(Rows);
    if Rows < 2 then Rows := 2;
    if IL.GetSafe(N - 1) <> nil then Inc(Rows);
    if Rows <> RowCount then RowCount := Rows;
    FImageIndex := Row - 1;
    Refresh;
  end;
end;

procedure TImageLibraryEditGrid.EditCell;
begin
  if FSelectionEnabled and Assigned(FOnEditCell) then FOnEditCell(Self);
end;

procedure TImageLibraryEditGrid.DelCell;
begin
  if (igDel in FEditMode) and (FImageLibrary <> nil) then
  begin
    FImageLibrary.DisableOnChangeEvent;
    if FImageLibrary.Count <> 1 then
      FImageLibrary.Delete(Row - 1)
    else
      FImageLibrary.SetImage(Row - 1, nil);
    UpdateSettings;
    FImageLibrary.EnableOnChangeEvent;
  end;
end;

procedure TImageLibraryEditGrid.InsCell;
begin
  if (igIns in FEditMode) and (FImageLibrary <> nil) then
  begin
    FImageLibrary.DisableOnChangeEvent;
    if FImageLibrary.Count = 0 then
      FImageLibrary.Insert(Row - 1, nil);
    FImageLibrary.Insert(Row - 1, nil);
    UpdateSettings;
    FImageLibrary.EnableOnChangeEvent;
  end;
end;

procedure TImageLibraryEditGrid.DeleteCell;
var
  I: Integer;
begin
  if (igDelete in FEditMode) and (FImageLibrary <> nil) then
  begin
    FImageLibrary.DisableOnChangeEvent;
    for I := Selection.Top to Selection.Bottom do
      FImageLibrary.SetImage(I - 1, nil);
    UpdateSettings;
    FImageLibrary.EnableOnChangeEvent;
  end;
end;

procedure TImageLibraryEditGrid.CutCell;
var
  IL: TCustomImageLibrary;
  I: Integer;
begin
  if (igCut in FEditMode) and (FImageLibrary <> nil) then
  begin
    IL := TImageLibrary.Create(nil);
    FImageLibrary.DisableOnChangeEvent;
    for I := Selection.Top to Selection.Bottom do
      if FImageLibrary.GetSafe(I - 1) <> nil then
        IL.Add(FImageLibrary.GetImage(I - 1))
      else
        IL.Add(nil);
    UpdateSettings;
    FImageLibrary.EnableOnChangeEvent;
    IL.CopyToClipboard;
    IL.Free;
  end;
end;

procedure TImageLibraryEditGrid.CopyCell;
var
  IL: TCustomImageLibrary;
  I: Integer;
begin
  if (igCopy in FEditMode) and (FImageLibrary <> nil) then
  begin
    IL := TImageLibrary.Create(nil);
    for I := Selection.Top to Selection.Bottom do
      if FImageLibrary.GetSafe(I - 1) <> nil then
        IL.Add(FImageLibrary[I - 1].Copy)
      else
        IL.Add(nil);
    IL.CopyToClipboard;
    IL.Free;
  end;
end;

procedure TImageLibraryEditGrid.PasteCell;
var
  IL: TCustomImageLibrary;
  I: Integer;
begin
  if (igPaste in FEditMode) and (FImageLibrary <> nil) then
  begin
    IL := TImageLibrary.Create(nil);
    IL.PasteFromClipboard;
    FImageLibrary.DisableOnChangeEvent;
    for I := 0 to IL.Count - 1 do
      if I <= Selection.Bottom - Selection.Top then
        FImageLibrary.SetImage(Selection.Top - 1 + I, IL.GetImage(I));
    UpdateSettings;
    FImageLibrary.EnableOnChangeEvent;
    IL.Free;
  end;
end;

end.
