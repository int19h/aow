unit EResGrid;

{ The EResGrid unit of Enginep.dpl written for the original compiler (Delphi 3.02): the resource
  grid of the editors, a TImageListGrid whose cells are the TEResource objects of a TEResourceList
  of an engine. Declarations follow the original instance layouts and VMT orders
  (notes/classes.json) and the published properties of the RTTI (notes/rtti/Enginep.dpl.txt);
  tools/match.py compares every method with the module. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Menus,
  Grids, ImageLib, Engine, ImgLComp;

type
  TECustomResourceGrid = class;

  TLinkResourceEvent = procedure(Sender: TECustomResourceGrid) of object;

  { EResGrid.TEResourceGridControl (instance size 16): +$C FGrid. The TEUser the grid connects
    to the engine's control node; messages $19..$23 activate and deactivate the grid. }
  TEResourceGridControl = class(TEUser)
  private
    FGrid: TECustomResourceGrid;
  public
    destructor Destroy; override;
    function GetControlStyle: TEControlStyles; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
  end;

  { EResGrid.TECustomResourceGrid (instance size 628): +$240 FEditID, +$244 FEngine,
    +$248 FEditEnabled, +$249 FActive, +$24C FUserData, +$250 FPopupMenu, +$254 FEComponent,
    +$258 FGridControl, +$25C FEditSettings, +$260 FDefaultResourceCID, +$264 FResourceList,
    +$268 FResources, +$26C FSelectedResources, +$270 FUseEditID. }
  TECustomResourceGrid = class(TImageListGrid)
  private
    FEditID: Integer;
    FEngine: TEngine;
    FEditEnabled: Boolean;
    FActive: Boolean;
    FUserData: Integer;
    FPopupMenu: TPopupMenu;
    FEComponent: TEComponent;
    FGridControl: TEResourceGridControl;
    FEditSettings: TEResourceEditSettings;
    FDefaultResourceCID: Integer;
    FResourceList: TEResourceList;
    FResources: TList;
    FSelectedResources: TEObjectList;
    FUseEditID: Boolean;
    procedure SetEComponent(Value: TEComponent);
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    function GetEditIndex(ACol, ARow: Integer): Integer;
    procedure SetResource(Index: Integer; R: TEResource);
    function GetResource(Index: Integer): TEResource;
    function CreateDefaultResource: TEResource;
    procedure EditResourceDone(EditResult: TEditResult; R: TEObject);
    procedure EditResource(Index: Integer);
    procedure DblClick; override;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    procedure GenerateResourceEditList;
    procedure DeleteSelectedResources;
    function GetSelectedResources: TECopyComponent;
    procedure GenerateSelectedResourcesList;
    procedure PasteImage(Index: Integer; Image: TLibraryImage);
    procedure PasteImageLibrary;
    procedure ClearPopupMenu;
    procedure PopupAddRows(Sender: TObject);
    procedure PopupCut(Sender: TObject);
    procedure PopupCopy(Sender: TObject);
    procedure PopupPaste(Sender: TObject);
    procedure PopupDelete(Sender: TObject);
    procedure PopupEdit(Sender: TObject);
    procedure ShowEditPopupMenu(R: TEResource; X, Y: Integer);
    procedure ShowEditMultiPopupMenu(L: TEObjectList; X, Y: Integer);
    procedure ShowPopupMenu(R: TEResource; X, Y: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure InitializeResourceEditor; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateResourceView;
    function GetResourceColRow(ACol, ARow: Integer): TEResource;
    function CutCell: Boolean; override;
    function CopyCell: Boolean; override;
    function PasteCell: Boolean; override;
    function DeleteCell: Boolean; override;
    procedure Activate(Edit: Boolean);
    procedure DeActivate;
    property Engine: TEComponent read FEComponent write SetEComponent;
    property DefaultResourceCID: Integer read FDefaultResourceCID write FDefaultResourceCID;
    property UseEditID: Boolean read FUseEditID write FUseEditID;
    property UserData: Integer read FUserData write FUserData;
    property ResourceList: TEResourceList read FResourceList write FResourceList;
    property EditSettings: TEResourceEditSettings read FEditSettings;
    property EditID: Integer read FEditID;
    property Active: Boolean read FActive;
    property EditEnabled: Boolean read FEditEnabled;
  end;

  { EResGrid.TEResourceGrid (instance size 640): +$274 FResourceListCID,
    +$278 FOnLinkToResourceList. The published grid: InitializeResourceEditor finds the edit
    settings object ($402) and the resource list by class id. }
  TEResourceGrid = class(TECustomResourceGrid)
  private
    FResourceListCID: Integer;
    FOnLinkToResourceList: TLinkResourceEvent;
  protected
    procedure InitializeResourceEditor; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnLinkToResourceList: TLinkResourceEvent read FOnLinkToResourceList write FOnLinkToResourceList;
    property ResourceListCID: Integer read FResourceListCID write FResourceListCID;
    property DefaultResourceCID;
    property Engine;
    property ShowGridIndex;
    property UseEditID;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Engine', [TEResourceGrid]);
end;

{ TEResourceGridControl }

destructor TEResourceGridControl.Destroy;
begin
  FGrid.FGridControl := nil;
  inherited Destroy;
end;

function TEResourceGridControl.GetControlStyle: TEControlStyles;
begin
  Result := [];
end;

procedure TEResourceGridControl.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  { identical to the original apart from the absolute addresses in the case jump table, which
    tools/match.py compares as code }
  inherited MsgProc(Msg, Sender);
  case Msg.MsgID of
    $19: FGrid.Activate(True);
    $20: FGrid.DeActivate;
    $21: FGrid.Activate(False);
    $22: FGrid.DeActivate;
    $23: if (Self <> Msg.Sender) and (Msg.Data[0] = FGrid.FUserData) and (Msg.Data[0] >= 0) then
      FGrid.SelectionEnabled := False;
  end;
end;

{ TECustomResourceGrid }

constructor TECustomResourceGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  EditBeep := True;
  SelectionEnabled := False;
  DefaultRowHeight := 40;
  ScrollBars := ssVertical;
  FResources := TList.Create;
  GridList := FResources;
  FPopupMenu := TPopupMenu.Create(Self);
  FSelectedResources := TEObjectList.Create;
  FUseEditID := True;
  RowCount := 10;
  ColCount := 5;
  FGridControl := TEResourceGridControl.Create(nil);
  FGridControl.FGrid := Self;
end;

destructor TECustomResourceGrid.Destroy;
begin
  ClearPopupMenu;
  FResources.Free;
  FGridControl.Free;
  FGridControl := nil;
  FSelectedResources.Free;
  FPopupMenu.Free;
  inherited Destroy;
end;

procedure TECustomResourceGrid.SetEComponent(Value: TEComponent);
begin
  { differs from the original in one register: it copies Value to ecx and loads the engine into
    edx; no source variant tried reproduces it }
  FEComponent := Value;
  if Value <> nil then
  begin
    FEngine := Value.Engine;
    if FEngine <> nil then FGridControl.Connect(FEngine.ControlNode)
    else FGridControl.Disconnect;
  end
  else FEngine := nil;
end;

procedure TECustomResourceGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  I: Integer;
  C: TColor;
begin
  I := GetEditIndex(ACol, ARow);
  if FActive then
  begin
    if (FEngine <> nil) and (I <> -1) and (I < FResources.Count) and (FResources[I] <> nil) then
    begin
      if TEResource(FResources[I]).CellImage = nil then
      begin
        C := Canvas.Brush.Color;
        Canvas.Brush.Color := clBlack;
        FillRect(Canvas.Handle, ARect, Canvas.Brush.Handle);
        Canvas.Brush.Color := C;
        DrawCellFocus(ARect, AState);
      end
      else
      begin
        TEResource(FResources[I]).Draw(Canvas, ARect, BltMode, ScaleX, ScaleY, BkColor, Color);
        DrawCellFocus(ARect, AState);
      end;
    end
    else DrawCellImage(nil, ARect, AState);
  end;
  inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TECustomResourceGrid.UpdateResourceView;
begin
  GenerateCellImageList;
  Refresh;
end;

function TECustomResourceGrid.GetEditIndex(ACol, ARow: Integer): Integer;
begin
  if FEditEnabled then Result := GetCellIndex(ACol, ARow)
  else Result := GetGridListIndex(GetCellIndex(ACol, ARow));
end;

procedure TECustomResourceGrid.SetResource(Index: Integer; R: TEResource);
var
  Changed: Boolean;
  Msg: TEMsg;
begin
  Changed := False;
  while Index >= FResources.Count do FResources.Add(nil);
  if FResources[Index] <> nil then
  begin
    TEResource(FResources[Index]).Destroy;
    Changed := True;
  end;
  FResources[Index] := R;
  if R <> nil then
  begin
    if R.Owner <> FResourceList then
    begin
      if csKeepIndex in FResourceList.GetControlStyle then R.SetArrayOwner(FResourceList, Index)
      else R.SetOwner(FResourceList);
      Changed := True;
    end;
    R.EditIndex := Index;
    { the original reloads R from the stack for this second store (value tracking lost) }
    R.EditID := FEditID;
    FResourceList.ValidateResourceID(FResourceList.Count - 1);
    FEngine.ActivateEObject(R);
  end;
  if Changed then
  begin
    FResourceList.ResourceChanged;
    InitMsg(Msg, $24, FGridControl);
    Msg.Value := FUserData;
    FEngine.ControlNode.MsgProc(Msg, FGridControl);
  end;
end;

function TECustomResourceGrid.GetResource(Index: Integer): TEResource;
begin
  if (Index < FResources.Count) and (Index >= 0) then Result := FResources[Index]
  else Result := nil;
end;

function TECustomResourceGrid.GetResourceColRow(ACol, ARow: Integer): TEResource;
begin
  Result := GetResource(GetEditIndex(ACol, ARow));
end;

function TECustomResourceGrid.CreateDefaultResource: TEResource;
begin
  if FDefaultResourceCID <> 0 then
    Result := TEResource(FEngine.CreateEObject(FDefaultResourceCID, nil))
  else Result := nil;
end;

procedure TECustomResourceGrid.EditResourceDone(EditResult: TEditResult; R: TEObject);
var
  I: Integer;
  Old: TEResource;
begin
  if EditResult = erOK then
  begin
    I := GetEditIndex(Col, Row);
    if I < FResources.Count then Old := FResources[I] else Old := nil;
    if (Old <> nil) and (Old.ClassID = R.ClassID) then
    begin
      Old.Assign(R, FEngine);
      FEngine.ActivateEObject(Old);
      R.Free;
    end
    else SetResource(I, TEResource(R));
    UpdateResourceView;
  end
  else R.Free;
end;

procedure TECustomResourceGrid.EditResource(Index: Integer);
var
  Old, R: TEResource;
begin
  if Index < FResources.Count then Old := FResources[Index] else Old := nil;
  if Old = nil then R := CreateDefaultResource
  else R := TEResource(Old.Copy(FEngine));
  if R <> nil then FEngine.ActivateEObject(R);
  { original bug: the resource list is set before the nil test }
  R.ResourceList := FResourceList;
  if R <> nil then
    TEObjectEditorClass(R.Editor).Edit(R, FEngine, EditResourceDone);
end;

procedure TECustomResourceGrid.DblClick;
begin
  inherited DblClick;
  if (EditMode in [emWriteOnly, emReadWrite]) and (FEngine <> nil) then
    EditResource(GetEditIndex(Col, Row));
end;

function TECustomResourceGrid.SelectCell(ACol, ARow: Longint): Boolean;
var
  R: TEResource;
  Msg: TEMsg;
begin
  inherited SelectCell(ACol, ARow);
  if FActive then
  begin
    R := GetResource(GetEditIndex(ACol, ARow));
    InitMsg(Msg, $23, FGridControl);
    Msg.Obj := R;
    Msg.Data[0] := FUserData;
    FEngine.ControlNode.MsgProc(Msg, FGridControl);
    FSelectionEnabled := True;
    Result := True;
  end
  else Result := False;
end;

procedure TECustomResourceGrid.GenerateResourceEditList;
var
  I: Integer;
begin
  if FResourceList <> nil then
    with FResourceList do
    begin
      FResources.Clear;
      if FUseEditID then
      begin
        for I := 0 to Count - 1 do
          if (Children[I] <> nil) and (TEResource(Children[I]).EditID = FEditID) then
            SetResource(TEResource(Children[I]).EditIndex, TEResource(Children[I]));
      end
      else
        for I := 0 to Count - 1 do
          if Children[I] <> nil then SetResource(I, TEResource(Children[I]));
    end
  else
    raise Exception.Create('No Resource list defined! (' + Name + ')');
end;

procedure TECustomResourceGrid.DeleteSelectedResources;
var
  R, C: Integer;
begin
  for R := Selection.Top to Selection.Bottom do
    for C := Selection.Left to Selection.Right do
      SetResource(GetEditIndex(C, R), nil);
end;

function TECustomResourceGrid.GetSelectedResources: TECopyComponent;
var
  R, C: Integer;
  Res: TEResource;
begin
  Result := TECopyComponent.Create(Self);
  for R := Selection.Top to Selection.Bottom do
    for C := Selection.Left to Selection.Right do
    begin
      Res := GetResource(GetEditIndex(C, R));
      if Res <> nil then Res := TEResource(Res.Copy(FEngine));
      TECopyComponent(Result).EObjectList.Add(Res);
    end;
end;

procedure TECustomResourceGrid.GenerateSelectedResourcesList;
var
  R, C: Integer;
begin
  FSelectedResources.Clear;
  for R := Selection.Top to Selection.Bottom do
    for C := Selection.Left to Selection.Right do
      FSelectedResources.Add(GetResource(GetEditIndex(C, R)));
end;

function TECustomResourceGrid.CutCell: Boolean;
var
  CC: TECopyComponent;
begin
  Result := inherited CutCell;
  if Result then
  begin
    CC := GetSelectedResources;
    if CC.Count <> 0 then CC.CopyToClipboard(FEngine, 'EResources');
    CC.Destroy;
    DeleteSelectedResources;
    UpdateResourceView;
    if EditBeep then Beep;
    Refresh;
  end;
end;

function TECustomResourceGrid.CopyCell: Boolean;
var
  CC: TECopyComponent;
begin
  Result := inherited CopyCell;
  if Result then
  begin
    CC := GetSelectedResources;
    if CC.Count <> 0 then CC.CopyToClipboard(FEngine, 'EResources');
    CC.Destroy;
    if EditBeep then Beep;
  end;
end;

procedure TECustomResourceGrid.PasteImage(Index: Integer; Image: TLibraryImage);
var
  R: TEResource;
begin
  R := GetResource(Index);
  if R = nil then
  begin
    R := CreateDefaultResource;
    if R <> nil then
    begin
      R.CellImage := Image;
      SetResource(Index, R);
    end;
  end
  else R.CellImage := Image;
end;

procedure TECustomResourceGrid.PasteImageLibrary;
var
  L: TImageLibrary;
  I, J, C, R: Integer;
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
          PasteImage(GetCellIndex(C, R), L.GetImage(I));
          Inc(I);
        end;
    if (Selection.Bottom = RowCount - 1) and (Selection.Right = ColCount - 1) and
      (GrowDirection <> gdNone) then
    begin
      J := GetCellIndex(Selection.Right, Selection.Bottom);
      while I < L.Count do
      begin
        Inc(J);
        PasteImage(J, L.GetImage(I));
        Inc(I);
      end;
    end;
    UpdateResourceView;
  end;
  L.Destroy;
end;

function TECustomResourceGrid.PasteCell: Boolean;
var
  CC: TECopyComponent;
  I, J, C, R: Integer;
  Res: TEResource;
begin
  Result := inherited PasteCell;
  if Result then
  begin
    CC := TECopyComponent.Create(Self);
    CC.PasteFromClipboard(FEngine, 'EResources');
    if CC.Count <> 0 then
    begin
      I := 0;
      for R := Selection.Top to Selection.Bottom do
        for C := Selection.Left to Selection.Right do
          if I < CC.Count then
          begin
            Res := TEResource(CC.EObjects[I]);
            if Res <> nil then Res := TEResource(Res.Copy(FEngine));
            SetResource(GetEditIndex(C, R), Res);
            Inc(I);
          end;
      if (Selection.Bottom = RowCount - 1) and (Selection.Right = ColCount - 1) and
        (GrowDirection <> gdNone) then
      begin
        J := GetEditIndex(Selection.Right, Selection.Bottom);
        while I < CC.Count do
        begin
          Inc(J);
          Res := TEResource(CC.EObjects[I]);
          if Res <> nil then Res := TEResource(Res.Copy(FEngine));
          SetResource(J, Res);
          Inc(I);
        end;
      end;
    end
    else PasteImageLibrary;
    CC.Destroy;
    UpdateResourceView;
    if EditBeep then Beep;
    Refresh;
  end;
end;

function TECustomResourceGrid.DeleteCell: Boolean;
begin
  Result := inherited DeleteCell;
  if Result then
  begin
    DeleteSelectedResources;
    if EditBeep then Beep;
    Refresh;
  end;
end;

procedure TECustomResourceGrid.ClearPopupMenu;
var
  I: Integer;
begin
  with FPopupMenu do
    for I := Items.Count - 1 downto 0 do Items[I].Free;
end;

procedure TECustomResourceGrid.PopupAddRows(Sender: TObject);
var
  S: string;
  N: Integer;
begin
  if InputQuery('Add Rows:', 'Enter number of rows', S) then
  try
    N := StrToInt(S);
    if N > 100 then N := 100;
    RowCount := RowCount + N;
  except
  end;
end;

procedure TECustomResourceGrid.PopupCut(Sender: TObject);
begin
  CutCell;
end;

procedure TECustomResourceGrid.PopupCopy(Sender: TObject);
begin
  CopyCell;
end;

procedure TECustomResourceGrid.PopupPaste(Sender: TObject);
begin
  PasteCell;
end;

procedure TECustomResourceGrid.PopupDelete(Sender: TObject);
begin
  DeleteCell;
end;

procedure TECustomResourceGrid.PopupEdit(Sender: TObject);
begin
end;

procedure TECustomResourceGrid.ShowEditPopupMenu(R: TEResource; X, Y: Integer);
var
  M: TMenuItem;
  Handled: Boolean;
begin
  ClearPopupMenu;
  if (RowCount < MaxRowCount) or (MaxRowCount = 0) then
  begin
    M := TMenuItem.Create(FPopupMenu);
    M.Caption := 'Add &Rows';
    M.OnClick := PopupAddRows;
    FPopupMenu.Items.Add(M);
    FPopupMenu.Items.Add(NewLine);
  end;
  M := TMenuItem.Create(FPopupMenu);
  M.OnClick := PopupCut;
  M.Caption := 'Cu&t';
  FPopupMenu.Items.Add(M);
  M := TMenuItem.Create(FPopupMenu);
  M.OnClick := PopupCopy;
  M.Caption := '&Copy';
  FPopupMenu.Items.Add(M);
  M := TMenuItem.Create(FPopupMenu);
  M.OnClick := PopupPaste;
  M.Caption := '&Paste';
  FPopupMenu.Items.Add(M);
  M := TMenuItem.Create(FPopupMenu);
  M.OnClick := PopupDelete;
  M.Caption := '&Delete';
  FPopupMenu.Items.Add(M);
  if R <> nil then
  begin
    M := TMenuItem.Create(FPopupMenu);
    M.OnClick := PopupEdit;
    M.Caption := '&Edit';
    FPopupMenu.Items.Add(NewLine);
    FPopupMenu.Items.Add(M);
    TEObjectEditorClass(R.Editor).UpdatePopupMenu(R, FEngine, Handled, FPopupMenu);
  end;
  FPopupMenu.Popup(X, Y);
end;

procedure TECustomResourceGrid.ShowEditMultiPopupMenu(L: TEObjectList; X, Y: Integer);
var
  M: TMenuItem;
  Handled: Boolean;
begin
  ClearPopupMenu;
  if (RowCount < MaxRowCount) or (MaxRowCount = 0) then
  begin
    M := TMenuItem.Create(FPopupMenu);
    M.Caption := 'Add &Rows';
    M.OnClick := PopupAddRows;
    FPopupMenu.Items.Add(M);
    FPopupMenu.Items.Add(NewLine);
  end;
  M := TMenuItem.Create(FPopupMenu);
  M.OnClick := PopupCut;
  M.Caption := 'Cu&t';
  FPopupMenu.Items.Add(M);
  M := TMenuItem.Create(FPopupMenu);
  M.OnClick := PopupCopy;
  M.Caption := '&Copy';
  FPopupMenu.Items.Add(M);
  M := TMenuItem.Create(FPopupMenu);
  M.OnClick := PopupPaste;
  M.Caption := '&Paste';
  FPopupMenu.Items.Add(M);
  M := TMenuItem.Create(FPopupMenu);
  M.OnClick := PopupDelete;
  M.Caption := '&Delete';
  FPopupMenu.Items.Add(M);
  if L.EObjects[0] <> nil then
    TEObjectEditorClass(L.EObjects[0].Editor).UpdateMultiPopupMenu(L.EObjects[0], FEngine,
      Handled, FPopupMenu, L);
  FPopupMenu.Popup(X, Y);
end;

procedure TECustomResourceGrid.ShowPopupMenu(R: TEResource; X, Y: Integer);
begin
end;

procedure TECustomResourceGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbRight then
  begin
    if SingleCellSelected then
    begin
      if FEditEnabled then
        ShowEditPopupMenu(GetResource(GetEditIndex(Col, Row)), ClientOrigin.X + X, ClientOrigin.Y + Y)
      else
        ShowPopupMenu(GetResource(GetEditIndex(Col, Row)), ClientOrigin.X + X, ClientOrigin.Y + Y);
    end
    else
    begin
      GenerateSelectedResourcesList;
      ShowEditMultiPopupMenu(FSelectedResources, ClientOrigin.X + X, ClientOrigin.Y + Y);
    end;
  end;
end;

procedure TECustomResourceGrid.Activate(Edit: Boolean);
var
  E: TEngine;
begin
  { the original loads the engine before the nil test (a local or a with statement) }
  E := FEngine;
  if E <> nil then
  begin
    Enabled := True;
    SelectionEnabled := False;
    InitializeResourceEditor;
    FEditID := FEditSettings.GetEditID(Name);
    FEditEnabled := Edit;
    if FEditEnabled then
    begin
      EditMode := emReadWrite;
      Options := Options + [goRangeSelect];
    end
    else
    begin
      EditMode := emNone;
      Options := Options - [goRangeSelect];
    end;
    GenerateResourceEditList;
    FActive := True;
    UpdateResourceView;
  end;
end;

procedure TECustomResourceGrid.DeActivate;
begin
  FActive := False;
  FEditEnabled := False;
  SelectionEnabled := False;
  Enabled := False;
  Refresh;
end;

{ TEResourceGrid }

constructor TEResourceGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResourceListCID := 0;
end;

procedure TEResourceGrid.InitializeResourceEditor;
begin
  FEditSettings := TEResourceEditSettings(FEngine.FindChildInTree($402));
  if Assigned(FOnLinkToResourceList) then FOnLinkToResourceList(Self);
  if (FResourceList = nil) and (FResourceListCID <> 0) then
    FResourceList := TEResourceList(FEngine.FindChildInTree(FResourceListCID));
end;

initialization
finalization
end.
