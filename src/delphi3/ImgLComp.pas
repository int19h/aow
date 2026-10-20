unit ImgLComp;

{ The ImgLComp unit of Enginep.dpl written for the original compiler (Delphi 3.02): grids and
  panels that draw ImageLib images, with cut/copy/paste/delete through events and the clipboard.
  Declarations follow the original instance layouts and VMT orders (notes/classes.json), the
  published properties the RTTI (notes/rtti/Enginep.dpl.txt), the enumeration and event parameter
  names the type info in the module. tools/match.py compares every method with the module. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Grids, ExtCtrls, ImageLib;

type
  { what the user may do with the cells: emReadOnly allows copy, emWriteOnly paste and delete,
    emReadWrite everything (cut needs emReadWrite) }
  TEditMode = (emNone, emReadOnly, emWriteOnly, emReadWrite);

  { which dimension RecalcRowsColumns grows to hold CellCount cells }
  TGrowDirection = (gdNone, gdHorizontal, gdVertical);

  { the edit events return False to veto the operation }
  TGridEditEvent = function(Sender: TObject): Boolean of object;
  TDrawImageEvent = procedure(ARect: TRect) of object;

  { ImgLComp.TDrawImageGrid (instance size 560): +$1E0 FScaleX, +$1E4 FScaleY, +$1E8 FBltMode,
    +$1EC FSelectColor, +$1F0 FBkColor, +$1F4 FCellCount, +$1F8 FMinRowCount, +$1FC FMinColCount,
    +$200 FMaxRowCount, +$204 FMaxColCount, +$208 FEditBeep, +$209 FEditMode, +$20C FOnCutCell,
    +$214 FOnCopyCell, +$21C FOnPasteCell, +$224 FOnDeleteCell, +$22C FGrowDirection,
    +$22D FShowGridIndex, +$22E FSelectionEnabled. A TDrawGrid whose cells are images; Ctrl+X/C/V
    and Del call the edit methods, which are dynamic. }
  TDrawImageGrid = class(TDrawGrid)
  private
    FScaleX: Integer;
    FScaleY: Integer;
    FBltMode: TBltMode;
    FSelectColor: TColor;
    FBkColor: TColor;
    FCellCount: Integer;
    FMinRowCount: Integer;
    FMinColCount: Integer;
    FMaxRowCount: Integer;
    FMaxColCount: Integer;
    FEditBeep: Boolean;
    FEditMode: TEditMode;
    FOnCutCell: TGridEditEvent;
    FOnCopyCell: TGridEditEvent;
    FOnPasteCell: TGridEditEvent;
    FOnDeleteCell: TGridEditEvent;
    FGrowDirection: TGrowDirection;
    FShowGridIndex: Boolean;
  protected
    FSelectionEnabled: Boolean;
    procedure SetShowGridIndex(Value: Boolean);
    procedure DrawGridIndex(ACol, ARow: Integer; Rect: TRect); virtual;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function GetRowCount: Integer;
    procedure SetRowCount(Value: Integer);
    function GetColCount: Integer;
    procedure SetColCount(Value: Integer);
    procedure SetMinRowCount(Value: Integer);
    procedure SetMinColCount(Value: Integer);
    procedure SetMaxRowCount(Value: Integer);
    procedure SetMaxColCount(Value: Integer);
    procedure SetSelectColor(Value: TColor);
    procedure SetSelectionEnabled(Value: Boolean);
    procedure SetCellCount(Value: Integer);
    procedure RecalcRowsColumns; virtual;
    procedure DrawCellImage(Image: TLibraryImage; Rect: TRect; State: TGridDrawState);
    procedure DrawCellFocus(Rect: TRect; State: TGridDrawState);
    function GetCellIndex(ACol, ARow: Integer): Integer; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetSelectEnabledSilent(Value: Boolean);
    procedure WndProc(var Message: TMessage); override;
    function CutCell: Boolean; dynamic;
    function CopyCell: Boolean; dynamic;
    function PasteCell: Boolean; dynamic;
    function DeleteCell: Boolean; dynamic;
    function SingleCellSelected: Boolean;
    property CellCount: Integer read FCellCount write SetCellCount;
  published
    property ScaleX: Integer read FScaleX write FScaleX;
    property ScaleY: Integer read FScaleY write FScaleY;
    property SelectColor: TColor read FSelectColor write SetSelectColor;
    property SelectionEnabled: Boolean read FSelectionEnabled write SetSelectionEnabled;
    property BltMode: TBltMode read FBltMode write FBltMode;
    property MinRowCount: Integer read FMinRowCount write SetMinRowCount;
    property MinColCount: Integer read FMinColCount write SetMinColCount;
    property MaxRowCount: Integer read FMaxRowCount write SetMaxRowCount;
    property MaxColCount: Integer read FMaxColCount write SetMaxColCount;
    property RowCount: Integer read GetRowCount write SetRowCount;
    property ColCount: Integer read GetColCount write SetColCount;
    property OnCutCell: TGridEditEvent read FOnCutCell write FOnCutCell;
    property OnCopyCell: TGridEditEvent read FOnCopyCell write FOnCopyCell;
    property OnPasteCell: TGridEditEvent read FOnPasteCell write FOnPasteCell;
    property OnDeleteCell: TGridEditEvent read FOnDeleteCell write FOnDeleteCell;
    property EditBeep: Boolean read FEditBeep write FEditBeep;
    property EditMode: TEditMode read FEditMode write FEditMode;
    property GrowDirection: TGrowDirection read FGrowDirection write FGrowDirection;
    property ShowGridIndex: Boolean read FShowGridIndex write SetShowGridIndex;
    property BkColor: TColor read FBkColor write FBkColor;
  end;

  { ImgLComp.TImageListGrid (instance size 576): +$230 FCellImageList, +$234 FCellImageListSize,
    +$238 FSkipEmptyImages, +$23C FGridList. The cells show the entries of a TList; with
    SkipEmptyImages the nil entries are left out and FCellImageList maps cell to list index. }
  TImageListGrid = class(TDrawImageGrid)
  private
    FCellImageList: PInteger;
    FCellImageListSize: Integer;
    FSkipEmptyImages: Boolean;
    FGridList: TList;
    procedure SetGridList(Value: TList);
    procedure DestroyCellImageList;
  protected
    function ImageEmpty(Index: Integer): Boolean; virtual;
    function GetGridListIndex(Index: Integer): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GenerateCellImageList;
    function GetSelectedGridListIndex: Integer;
    property GridList: TList read FGridList write SetGridList;
  published
    property SkipEmptyImages: Boolean read FSkipEmptyImages write FSkipEmptyImages;
  end;

  { ImgLComp.TImageLibGrid (instance size 580): +$240 FImageLibrary. The cells show the images
    of an image library; cut/copy/paste go through a temporary TImageLibrary and its clipboard
    format. }
  TImageLibGrid = class(TImageListGrid)
  private
    FImageLibrary: TImageLibrary;
    procedure SetImageLibrary(Value: TImageLibrary);
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
  public
    function GetSelectedImageLib: TImageLibrary;
    procedure DeleteSelectedImages;
    function CutCell: Boolean; override;
    function CopyCell: Boolean; override;
    function PasteCell: Boolean; override;
    function DeleteCell: Boolean; override;
  published
    property ImageLibrary: TImageLibrary read FImageLibrary write SetImageLibrary;
  end;

  { ImgLComp.TDrawImagePanel (instance size 372): +$138 FOnDrawImage, +$140 FEditBeep,
    +$141 FEditMode, +$142 FBltMode, +$144 FFocusColor, +$148 FShowFocus, +$149 FMinimizeImage,
    +$14C FScaleX, +$150 FScaleY, +$154 FOnCutImage, +$15C FOnCopyImage, +$164 FOnPasteImage,
    +$16C FOnDeleteImage. A panel that paints one image through OnDrawImage; Paint repeats
    TCustomPanel.Paint's bevels (with its nested AdjustColors) and then calls DrawImage. }
  TDrawImagePanel = class(TCustomPanel)
  private
    FOnDrawImage: TDrawImageEvent;
    FEditBeep: Boolean;
    FEditMode: TEditMode;
    FBltMode: TBltMode;
    FFocusColor: TColor;
    FShowFocus: Boolean;
    FMinimizeImage: Boolean;
    FScaleX: Integer;
    FScaleY: Integer;
    FOnCutImage: TGridEditEvent;
    FOnCopyImage: TGridEditEvent;
    FOnPasteImage: TGridEditEvent;
    FOnDeleteImage: TGridEditEvent;
    procedure SetFocusColor(Value: TColor);
    procedure SetShowFocus(Value: Boolean);
  protected
    procedure Paint; override;
    procedure DrawImage(Rect: TRect); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DrawFocus(Rect: TRect);
    procedure DrawLibraryImage(Image: TLibraryImage; Rect: TRect; Selected: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    procedure WndProc(var Message: TMessage); override;
    function CutImage: Boolean; dynamic;
    function CopyImage: Boolean; dynamic;
    function PasteImage: Boolean; dynamic;
    function DeleteImage: Boolean; dynamic;
  published
    property Align;
    property Color;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
    property BorderWidth;
    property BltMode: TBltMode read FBltMode write FBltMode;
    property ScaleX: Integer read FScaleX write FScaleX;
    property ScaleY: Integer read FScaleY write FScaleY;
    property FocusColor: TColor read FFocusColor write SetFocusColor;
    property ShowFocus: Boolean read FShowFocus write SetShowFocus;
    property MinimizeImage: Boolean read FMinimizeImage write FMinimizeImage;
    property EditBeep: Boolean read FEditBeep write FEditBeep;
    property EditMode: TEditMode read FEditMode write FEditMode;
    property OnDrawImage: TDrawImageEvent read FOnDrawImage write FOnDrawImage;
    property OnCutImage: TGridEditEvent read FOnCutImage write FOnCutImage;
    property OnCopyImage: TGridEditEvent read FOnCopyImage write FOnCopyImage;
    property OnPasteImage: TGridEditEvent read FOnPasteImage write FOnPasteImage;
    property OnDeleteImage: TGridEditEvent read FOnDeleteImage write FOnDeleteImage;
  end;

  { ImgLComp.TLibraryImagePanel (instance size 376): +$174 FLibraryImage, an image the panel
    owns and shows; cut/copy/paste through a temporary TImageLibrary. }
  TLibraryImagePanel = class(TDrawImagePanel)
  private
    FLibraryImage: TLibraryImage;
    procedure SetLibraryImage(Value: TLibraryImage);
  protected
    procedure DrawImage(Rect: TRect); override;
  public
    function CutImage: Boolean; override;
    function CopyImage: Boolean; override;
    function PasteImage: Boolean; override;
    function DeleteImage: Boolean; override;
    property LibraryImage: TLibraryImage read FLibraryImage write SetLibraryImage;
  end;

implementation

{ Draws the two-pixel frame in Color around R and, when Focused, the focus rectangles inside
  and outside it (DrawCellFocus, TDrawImagePanel.DrawFocus). }
procedure DrawFocusFrame(DC: HDC; R: TRect; Focused, Selected: Boolean; Color: TColor);
var
  Brush: HBRUSH;
  OldColor: TColorRef;
  OldBrush: HGDIOBJ;
begin
  if Selected or Focused then
  begin
    Brush := CreateSolidBrush(Color);
    OldColor := SetBkColor(DC, ColorToRGB(Color));
    OldBrush := SelectObject(DC, Brush);
    FrameRect(DC, R, Brush);
    if Focused then DrawFocusRect(DC, R);
    Inc(R.Left); Inc(R.Top); Dec(R.Right); Dec(R.Bottom);
    FrameRect(DC, R, Brush);
    Inc(R.Left); Inc(R.Top); Dec(R.Right); Dec(R.Bottom);
    if Focused then
    begin
      FrameRect(DC, R, Brush);
      DrawFocusRect(DC, R);
    end;
    SelectObject(DC, OldBrush);
    SetBkColor(DC, OldColor);
    DeleteObject(Brush);
  end;
end;

{ TDrawImageGrid }

constructor TDrawImageGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScaleX := 100;
  FScaleY := 100;
  FSelectColor := clRed;
  FBkColor := clBlack;
  FBltMode := bmCenter;
  FSelectionEnabled := True;
  FEditMode := emNone;
  FGrowDirection := gdVertical;
  DefaultDrawing := False;
  FixedCols := 0;
  FixedRows := 0;
  Color := clBtnFace;
  GridLineWidth := 4;
  Options := Options - [goRangeSelect] + [goDrawFocusSelected];
end;

destructor TDrawImageGrid.Destroy;
begin
  inherited Destroy;
end;

procedure TDrawImageGrid.SetSelectEnabledSilent(Value: Boolean);
begin
  FSelectionEnabled := Value;
end;

procedure TDrawImageGrid.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_ERASEBKGND then
  begin
    Message.Result := 1;
    Invalidate;
  end
  else inherited WndProc(Message);
end;

procedure TDrawImageGrid.SetShowGridIndex(Value: Boolean);
begin
  FShowGridIndex := Value;
  Refresh;
end;

procedure TDrawImageGrid.DrawGridIndex(ACol, ARow: Integer; Rect: TRect);
var
  S: string;
begin
  S := IntToStr(GetCellIndex(ACol, ARow));
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color := Font.Color;
  Inc(Rect.Left, 3);
  Inc(Rect.Top, 2);
  DrawText(Canvas.Handle, PChar(S), Length(S), Rect, DT_WORDBREAK or DT_EXPANDTABS);
end;

procedure TDrawImageGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
begin
  inherited DrawCell(ACol, ARow, ARect, AState);
  if FShowGridIndex then DrawGridIndex(ACol, ARow, ARect);
end;

function TDrawImageGrid.CutCell: Boolean;
begin
  if FSelectionEnabled and Assigned(FOnCutCell) then Result := FOnCutCell(Self)
  else Result := True;
end;

function TDrawImageGrid.CopyCell: Boolean;
begin
  if FSelectionEnabled and Assigned(FOnCopyCell) then Result := FOnCopyCell(Self)
  else Result := True;
end;

function TDrawImageGrid.PasteCell: Boolean;
begin
  if FSelectionEnabled and Assigned(FOnPasteCell) then Result := FOnPasteCell(Self)
  else Result := True;
end;

function TDrawImageGrid.DeleteCell: Boolean;
begin
  if FSelectionEnabled and Assigned(FOnDeleteCell) then Result := FOnDeleteCell(Self)
  else Result := True;
end;

procedure TDrawImageGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if ssCtrl in Shift then
    case Key of
      Ord('X'): if FEditMode = emReadWrite then CutCell;
      Ord('C'): if FEditMode in [emReadOnly, emReadWrite] then CopyCell;
      Ord('V'): if FEditMode in [emWriteOnly, emReadWrite] then PasteCell;
      VK_DELETE: if FEditMode in [emWriteOnly, emReadWrite] then DeleteCell;
    end;
  inherited KeyDown(Key, Shift);
end;

function TDrawImageGrid.SingleCellSelected: Boolean;
begin
  Result := (Selection.Top = Selection.Bottom) and (Selection.Left = Selection.Right);
end;

function TDrawImageGrid.GetRowCount: Integer;
begin
  Result := inherited RowCount;
end;

procedure TDrawImageGrid.SetRowCount(Value: Integer);
begin
  if (FMinRowCount <> 0) and (Value < FMinRowCount) then Value := FMinRowCount;
  if (FMaxRowCount <> 0) and (Value > FMaxRowCount) then Value := FMaxRowCount;
  inherited RowCount := Value;
end;

function TDrawImageGrid.GetColCount: Integer;
begin
  Result := inherited ColCount;
end;

procedure TDrawImageGrid.SetColCount(Value: Integer);
begin
  if (FMinColCount <> 0) and (Value < FMinColCount) then Value := FMinColCount;
  if (FMaxColCount <> 0) and (Value > FMaxColCount) then Value := FMaxColCount;
  inherited ColCount := Value;
end;

procedure TDrawImageGrid.SetMinRowCount(Value: Integer);
begin
  FMinRowCount := Value;
  RowCount := RowCount;
end;

procedure TDrawImageGrid.SetMinColCount(Value: Integer);
begin
  FMinColCount := Value;
  ColCount := ColCount;
end;

procedure TDrawImageGrid.SetMaxRowCount(Value: Integer);
begin
  FMaxRowCount := Value;
  RowCount := RowCount;
end;

procedure TDrawImageGrid.SetMaxColCount(Value: Integer);
begin
  FMaxColCount := Value;
  ColCount := ColCount;
end;

procedure TDrawImageGrid.SetSelectColor(Value: TColor);
begin
  FSelectColor := Value;
  if (csDesigning in ComponentState) and HandleAllocated and
    not (csUpdating in ComponentState) then Refresh;
end;

procedure TDrawImageGrid.SetSelectionEnabled(Value: Boolean);
begin
  if Value <> FSelectionEnabled then
  begin
    FSelectionEnabled := Value;
    if HandleAllocated and not (csUpdating in ComponentState) then Refresh;
  end;
end;

procedure TDrawImageGrid.SetCellCount(Value: Integer);
begin
  { differs from the original in one register: it keeps Self in esi across the virtual call }
  FCellCount := Value;
  RecalcRowsColumns;
end;

procedure TDrawImageGrid.RecalcRowsColumns;
begin
  case FGrowDirection of
    gdHorizontal:
      if FEditMode in [emWriteOnly, emReadWrite] then
        ColCount := (RowCount + FCellCount) div RowCount
      else
        ColCount := (RowCount + FCellCount - 1) div RowCount;
    gdVertical:
      if FEditMode in [emWriteOnly, emReadWrite] then
        RowCount := (ColCount + FCellCount) div ColCount
      else
        RowCount := (ColCount + FCellCount - 1) div ColCount;
  end;
end;

procedure TDrawImageGrid.DrawCellImage(Image: TLibraryImage; Rect: TRect; State: TGridDrawState);
var
  R: TRect;
begin
  BltLibraryImage(Canvas, Image, Rect, FBltMode, FScaleX, FScaleY, FBkColor, Color, False, R);
  DrawCellFocus(Rect, State);
end;

procedure TDrawImageGrid.DrawCellFocus(Rect: TRect; State: TGridDrawState);
begin
  if FSelectionEnabled then
    DrawFocusFrame(Canvas.Handle, Rect, gdFocused in State, gdSelected in State, FSelectColor);
end;

function TDrawImageGrid.GetCellIndex(ACol, ARow: Integer): Integer;
begin
  Result := ColCount * ARow + ACol;
end;

{ TImageListGrid }

constructor TImageListGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSkipEmptyImages := True;
end;

destructor TImageListGrid.Destroy;
begin
  DestroyCellImageList;
  inherited Destroy;
end;

function TImageListGrid.ImageEmpty(Index: Integer): Boolean;
begin
  Result := FGridList[Index] = nil;
end;

procedure TImageListGrid.SetGridList(Value: TList);
begin
  FGridList := Value;
  GenerateCellImageList;
end;

procedure TImageListGrid.GenerateCellImageList;
var
  I, N: Integer;
begin
  DestroyCellImageList;
  if (FGridList <> nil) and (FGridList.Count <> 0) then
  begin
    if FSkipEmptyImages and not (FEditMode in [emWriteOnly, emReadWrite]) then
    begin
      N := 0;
      for I := 0 to FGridList.Count - 1 do
        if not ImageEmpty(I) then Inc(N);
    end
    else N := FGridList.Count;
    CellCount := N;
    N := 0;
    FCellImageListSize := (FCellCount + 1) * SizeOf(Integer);
    GetMem(FCellImageList, FCellImageListSize);
    for I := 0 to FGridList.Count - 1 do
    begin
      PInteger(Longint(FCellImageList) + N * SizeOf(Integer))^ := I;
      if not ImageEmpty(I) or not FSkipEmptyImages or (FEditMode in [emWriteOnly, emReadWrite]) then
        Inc(N);
    end;
  end
  else CellCount := 0;
end;

procedure TImageListGrid.DestroyCellImageList;
begin
  if FCellImageList <> nil then
  begin
    FreeMem(FCellImageList, FCellImageListSize);
    FCellImageList := nil;
  end;
end;

function TImageListGrid.GetGridListIndex(Index: Integer): Integer;
begin
  if not FSkipEmptyImages or (FEditMode in [emWriteOnly, emReadWrite]) then Result := Index
  else if (Index >= 0) and (Index < FCellCount) then
    Result := PInteger(Longint(FCellImageList) + Index * SizeOf(Integer))^
  else Result := -1;
end;

function TImageListGrid.GetSelectedGridListIndex: Integer;
begin
  Result := GetGridListIndex(GetCellIndex(Col, Row));
end;

{ TImageLibGrid }

function TImageLibGrid.GetSelectedImageLib: TImageLibrary;
var
  C, R, I: Integer;
begin
  Result := TImageLibrary.Create(Self);
  if FImageLibrary <> nil then
    for R := Selection.Top to Selection.Bottom do
      for C := Selection.Left to Selection.Right do
      begin
        I := GetGridListIndex(GetCellIndex(C, R));
        if I <> -1 then Result.Add(FImageLibrary[I].Copy)
        else Result.Add(nil);
      end;
end;

procedure TImageLibGrid.DeleteSelectedImages;
var
  C, R, I: Integer;
begin
  if FImageLibrary <> nil then
    for R := Selection.Top to Selection.Bottom do
      for C := Selection.Left to Selection.Right do
      begin
        I := GetGridListIndex(GetCellIndex(C, R));
        if I <> -1 then FImageLibrary.SetImage(I, nil);
      end;
end;

function TImageLibGrid.CutCell: Boolean;
var
  L: TImageLibrary;
begin
  Result := inherited CutCell;
  if Result and (FImageLibrary <> nil) then
  begin
    L := GetSelectedImageLib;
    if L.Count <> 0 then L.CopyToClipboard;
    L.Destroy;
    DeleteSelectedImages;
    if FEditBeep then Beep;
    Refresh;
  end;
end;

function TImageLibGrid.CopyCell: Boolean;
var
  L: TImageLibrary;
begin
  Result := inherited CopyCell;
  if Result and (FImageLibrary <> nil) then
  begin
    L := GetSelectedImageLib;
    if L.Count <> 0 then L.CopyToClipboard;
    L.Destroy;
    if FEditBeep then Beep;
  end;
end;

function TImageLibGrid.PasteCell: Boolean;
var
  L: TImageLibrary;
  I, J, C, R: Integer;
  Image: TLibraryImage;
begin
  Result := inherited PasteCell;
  if Result and (FImageLibrary <> nil) then
  begin
    L := TImageLibrary.Create(Self);
    L.PasteFromClipboard;
    if L.Count <> 0 then
    begin
      I := 0;
      for R := Selection.Top to Selection.Bottom do
        for C := Selection.Left to Selection.Right do
          if I < L.Count then
          begin
            Image := L.GetImage(I);
            FImageLibrary.SetImage(GetCellIndex(C, R), Image);
            Inc(I);
          end;
      if (Selection.Bottom = RowCount - 1) and (Selection.Right = ColCount - 1) and
        (FGrowDirection <> gdNone) then
      begin
        J := GetCellIndex(Selection.Right, Selection.Bottom);
        while I < L.Count do
        begin
          Inc(J);
          Image := L.GetImage(I);
          FImageLibrary.SetImage(J, Image);
          Inc(I);
        end;
      end;
    end;
    L.Destroy;
    GenerateCellImageList;
    if FEditBeep then Beep;
    Refresh;
  end;
end;

function TImageLibGrid.DeleteCell: Boolean;
begin
  Result := inherited DeleteCell;
  if Result and (FImageLibrary <> nil) then
  begin
    DeleteSelectedImages;
    if FEditBeep then Beep;
    Refresh;
  end;
end;

procedure TImageLibGrid.SetImageLibrary(Value: TImageLibrary);
begin
  FImageLibrary := Value;
  GenerateCellImageList;
  RecalcRowsColumns;
  Refresh;
end;

procedure TImageLibGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  I: Integer;
begin
  I := GetGridListIndex(GetCellIndex(ACol, ARow));
  if (I <> -1) and (FImageLibrary <> nil) and (I < FImageLibrary.Count) and
    (FImageLibrary[I] <> nil) then
    DrawCellImage(FImageLibrary[I], ARect, AState)
  else
    DrawCellImage(nil, ARect, AState);
  inherited DrawCell(ACol, ARow, ARect, AState);
end;

{ TDrawImagePanel }

constructor TDrawImagePanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScaleX := 100;
  FScaleY := 100;
  FBltMode := bmStretchToFit;
  FShowFocus := True;
  FFocusColor := clRed;
  FEditBeep := True;
  TabStop := True;
end;

procedure TDrawImagePanel.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_ERASEBKGND then Message.Result := 1
  else inherited WndProc(Message);
  if (Message.Msg = WM_KILLFOCUS) or (Message.Msg = WM_SETFOCUS) then Paint;
end;

procedure TDrawImagePanel.SetFocusColor(Value: TColor);
begin
  FFocusColor := Value;
  Refresh;
end;

procedure TDrawImagePanel.SetShowFocus(Value: Boolean);
begin
  FShowFocus := Value;
  Refresh;
end;

procedure TDrawImagePanel.DrawImage(Rect: TRect);
begin
  if Assigned(FOnDrawImage) then FOnDrawImage(Rect);
end;

function TDrawImagePanel.CutImage: Boolean;
begin
  if Assigned(FOnCutImage) and FShowFocus then Result := FOnCutImage(Self)
  else Result := True;
end;

function TDrawImagePanel.CopyImage: Boolean;
begin
  if Assigned(FOnCopyImage) and FShowFocus then Result := FOnCopyImage(Self)
  else Result := True;
end;

function TDrawImagePanel.PasteImage: Boolean;
begin
  if Assigned(FOnPasteImage) and FShowFocus then Result := FOnPasteImage(Self)
  else Result := True;
end;

function TDrawImagePanel.DeleteImage: Boolean;
begin
  if Assigned(FOnDeleteImage) and FShowFocus then Result := FOnDeleteImage(Self)
  else Result := True;
end;

procedure TDrawImagePanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if FShowFocus and not Focused then
  begin
    SetFocus;
    Refresh;
  end;
end;

procedure TDrawImagePanel.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if ssCtrl in Shift then
    case Key of
      Ord('X'): if FEditMode = emReadWrite then CutImage;
      Ord('C'): if FEditMode in [emReadOnly, emReadWrite] then CopyImage;
      Ord('V'): if FEditMode in [emWriteOnly, emReadWrite] then PasteImage;
      VK_DELETE: if FEditMode in [emWriteOnly, emReadWrite] then DeleteImage;
    end;
  inherited KeyDown(Key, Shift);
end;

procedure TDrawImagePanel.DrawFocus(Rect: TRect);
begin
  DrawFocusFrame(Canvas.Handle, Rect, True, True, FFocusColor);
end;

procedure TDrawImagePanel.DrawLibraryImage(Image: TLibraryImage; Rect: TRect; Selected: Boolean);
var
  R: TRect;
begin
  { the third parameter is not used (the callers pass False); differs from the original in one
    register: it keeps Image in esi (as if Image were used after the call) }
  BltLibraryImage(Canvas, Image, Rect, FBltMode, FScaleX, FScaleY, 0, Color, False, R);
  Rect := R;
  if Focused and FShowFocus then DrawFocus(Rect);
end;

procedure TDrawImagePanel.Paint;
var
  Rect: TRect;
  TopColor, BottomColor: TColor;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  Frame3D(Canvas, Rect, Color, Color, BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  DrawImage(Rect);
end;

{ TLibraryImagePanel }

procedure TLibraryImagePanel.DrawImage(Rect: TRect);
begin
  if Assigned(FOnDrawImage) then inherited DrawImage(Rect);
  DrawLibraryImage(FLibraryImage, Rect, False);
end;

function TLibraryImagePanel.CutImage: Boolean;
var
  L: TImageLibrary;
begin
  Result := inherited CutImage;
  if Result then
  begin
    L := TImageLibrary.Create(Self);
    L.Add(FLibraryImage);
    L.CopyToClipboard;
    L.Destroy;
    FLibraryImage := nil;
    if FEditBeep then Beep;
    Refresh;
  end;
end;

function TLibraryImagePanel.CopyImage: Boolean;
var
  L: TImageLibrary;
begin
  Result := inherited CopyImage;
  if Result then
  begin
    L := TImageLibrary.Create(Self);
    if FLibraryImage <> nil then L.Add(FLibraryImage.Copy)
    else L.Add(nil);
    if FEditBeep then Beep;
    L.CopyToClipboard;
    L.Destroy;
  end;
end;

function TLibraryImagePanel.PasteImage: Boolean;
var
  L: TImageLibrary;
begin
  Result := inherited PasteImage;
  if Result then
  begin
    L := TImageLibrary.Create(Self);
    L.PasteFromClipboard;
    if L.Count <> 0 then
    begin
      LibraryImage := L.GetImage(0);
      if FEditBeep then Beep;
    end;
    L.Destroy;
  end;
end;

function TLibraryImagePanel.DeleteImage: Boolean;
begin
  Result := inherited DeleteImage;
  if Result then
  begin
    LibraryImage := nil;
    if FEditBeep then Beep;
  end;
end;

procedure TLibraryImagePanel.SetLibraryImage(Value: TLibraryImage);
begin
  { differs from the original in one register: it keeps the old image in esi and Value in edi }
  if FLibraryImage <> nil then FLibraryImage.Destroy;
  FLibraryImage := Value;
  Refresh;
end;

initialization
finalization
end.
