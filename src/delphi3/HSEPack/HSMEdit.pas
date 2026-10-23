unit HSMEdit;

{ The HSMEdit unit of HSEPack.dpl: THSMEdit, the map display of the editor AoWEd.exe (scrolling,
  preview, placing terrain, roads and map objects, cut/copy/paste of the selected sprites). The
  original was d:\gengine\hsengine\edit\Hsmedit.pas (the Assert in SelectPlaceHS, line 668). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Menus,
  Engine, GFXE, DisplayC, HSEngine, HSLib, ProgDlg;

type
  THSMEditViewMode = (hvmDefault, hvmPreview);
  THSMPlaceControlMode = (pmChangeTerrain, pmClearTerrain, pmRoad, pmEraser, pmForceTerrain);
  TShowMessageEvent = procedure(S: String) of object;

  THSMEdit = class;

  { HSMEdit.THSMEditControl (instance size 16): +$C FHSMEdit. }
  THSMEditControl = class(TEUser)
  private
    FHSMEdit: THSMEdit;
  public
    destructor Destroy; override;
    function GetControlStyle: TEControlStyles; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
  end;

  { HSMEdit.THSMPlaceControl (instance size 24): places terrain, roads and the eraser. +8 FMode,
    +9 FTerrainType, +$C FHSEngine, +$10 FRoadControl (nil: the sprite set's), +$14 FHSMEdit. }
  THSMPlaceControl = class(TEObject)
  private
    FMode: THSMPlaceControlMode;
    FTerrainType: Shortint;
    FHSEngine: THSEngine;
    FRoadControl: TMORTerrainControl;
    FHSMEdit: THSMEdit;
  public
    procedure PlaceTerrain(Xhx, Yhx, Lhx, Radius, TerrainType: Shortint);
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
  end;

  { HSMEdit.THSMEdit (instance size 624): the fields from +$1AC in order; +$1B0 FBrushes (the brush
    sprites, by size), +$1EC never used, +$1F0 FPlaceHS (the sprite under the mouse, at +$1F4 FPlaceDX,
    FPlaceDY), +$1FC FHSPlaceControl (gets the drop message), +$248.. the frame times in ms. }
  THSMEdit = class(TDisplay)
  private
    FBrushSize: Byte;
    FBrushes: array[1..3] of TLibraryHS;
    FActivated: Boolean;
    FHSEngine: THSEngine;
    FHorzScrollBar, FVertScrollBar: TScrollBar;
    FControl: THSMEditControl;
    FPopupMenu: TPopupMenu;
    FIgnoreMouseDown: Boolean;
    FPlaceControl: THSMPlaceControl;
    FLoadMapFileFilter, FSaveMapFileFilter, FHSMapFileName: string;
    FViewMode: THSMEditViewMode;
    FReserved: Integer;
    FPlaceHS: THexagonSprite;
    FPlaceDX, FPlaceDY: Integer;
    FHSPlaceControl: TEObject; public property HSPlaceControl: TEObject read FHSPlaceControl; private
    FPlaceOptions: Integer; public property PlaceOptions: Integer read FPlaceOptions write FPlaceOptions; private { AoWEd 0042B2EF }
    FOnShowMessage: TShowMessageEvent;
    FOnStaticSceneUpdated, FOnUpdateCaption: TNotifyEvent;
    FSceneValid: Boolean;
    FSceneLevel: Shortint;
    FOnActivate, FOnDeactivate, FOnSelectPlaceHS, FOnDeselectPlaceHS: TNotifyEvent;
    FPreviewX, FPreviewY: Integer;
    FStaticDrawTime, FDynamicDrawTime, FStaticUpdateTime, FDynamicUpdateTime: Integer; public property StaticDrawTime: Integer read FStaticDrawTime; property DynamicDrawTime: Integer read FDynamicDrawTime; property StaticUpdateTime: Integer read FStaticUpdateTime; property DynamicUpdateTime: Integer read FDynamicUpdateTime; private
    FStaticBltTime, FBltTime, FIdleTime, FMaxFrameRate: Integer; public property StaticBltTime: Integer read FStaticBltTime; property BltTime: Integer read FBltTime; property IdleTime: Integer read FIdleTime; property MaxFrameRate: Integer read FMaxFrameRate; private
    FOverwrite: Boolean;
    FProgressDlg: TProgressDlg;
    procedure CMWantSpecialKey(var Message: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  protected
    public procedure KeyDown(var Key: Word; Shift: TShiftState); override; protected { AoWEd 0042813C }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetOverwrite(Value: Boolean);
    procedure UpdateScrollBars;
    procedure UpdateCaption;
    procedure SetHSMapFilename(Value: string);
    procedure SetBrushSize(Value: Byte);
    function GetCopyPasteHSIDstring: string;
    function CutHS: Boolean; virtual;
    function CopyHS: Boolean; virtual;
    function PasteHS: Boolean; virtual;
    function DeleteHS: Boolean; virtual;
    procedure ClearKeyboardQueue;
    procedure PopupCut(Sender: TObject);
    procedure PopupCopy(Sender: TObject);
    procedure PopupPaste(Sender: TObject);
    procedure PopupDelete(Sender: TObject);
    procedure EditSelectedHS;
    procedure PopupEdit(Sender: TObject);
    procedure ClearPopupMenu;
    procedure ShowPopupMenu(X, Y: Integer);
    function GetRoadControl: TMORTerrainControl;
    procedure SetRoadControl(Value: TMORTerrainControl);
    procedure SelectPlaceHS(AHSPlaceControl: TEObject; APlaceHS: THexagonSprite;
      AOptions, ADX, ADY: Integer);
    procedure DeselectPlaceHS;
    procedure SelectChangeTerrain(TerrainType: Shortint);
    procedure SelectClearTerrain(TerrainType: Shortint);
    procedure SelectForceTerrain(TerrainType: Shortint);
    procedure SelectEraser;
    procedure SelectRoad;
    procedure SelectEditResource(Resource: TEResource);
    procedure SetHSEngine(Value: THSEngine);
    procedure ShowMsg(S: string);
    procedure Resize; override;
    procedure BuildStaticScene;
    procedure BltStaticScene(Dest: TSurface);
    procedure CenterView(Xhx, Yhx, Lhx: Shortint);
    procedure RebuildScene;
    procedure SetSceneLevel(Value: Shortint);
    procedure BuildDynamicScene;
    procedure ShowSelection;
    function DropSelectedPlaceHS(Xhp, Yhp, Lhx: Integer): Integer;
    procedure UpdateMouseCoordinates;
    procedure SelectAndEditHS(Xhx, Yhx, Lhx: Integer);
    procedure VerifyMouseScrolling;
    procedure UpdateFrame; override;
    function ExecuteBltSurfaceEvent: HResult; override;
    procedure SurfaceDataLost(SurfaceType: Integer); override;
    function SaveAs: Boolean;
    function Save: Boolean;
    function CanCloseMap: Boolean;
    procedure ProgressEvent(Sender: TEObject; const Msg: string; Percent: Integer);
    function LoadHSM(const FileName: string): Boolean;
    function Load: Boolean;
    function Close: Boolean;
    function NewMap(Settings: TNewHSMapSettings): Boolean; virtual;
    procedure HorzScrollBarChange(Sender: TObject);
    procedure VertScrollBarChange(Sender: TObject);
    procedure Activate;
    procedure DeActivate;
    procedure ValidatePreviewView;
    procedure ShowPreview;
    procedure HidePreview;
    property Activated: Boolean read FActivated;
    property HSEngine: THSEngine read FHSEngine write SetHSEngine;
    property BrushSize: Byte read FBrushSize write SetBrushSize;
    property Overwrite: Boolean read FOverwrite write SetOverwrite;
    property RoadControl: TMORTerrainControl read GetRoadControl write SetRoadControl;
    property HSMapFileName: string read FHSMapFileName write SetHSMapFilename;
    property SceneLevel: Shortint read FSceneLevel write SetSceneLevel;
    property ViewMode: THSMEditViewMode read FViewMode;
  published
    property OnShowMessage: TShowMessageEvent read FOnShowMessage write FOnShowMessage;
    property OnUpdateCaption: TNotifyEvent read FOnUpdateCaption write FOnUpdateCaption;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnStaticSceneUpdated: TNotifyEvent read FOnStaticSceneUpdated write FOnStaticSceneUpdated;
    property OnDeselectPlaceHS: TNotifyEvent read FOnDeselectPlaceHS write FOnDeselectPlaceHS;
    property OnSelectPlaceHS: TNotifyEvent read FOnSelectPlaceHS write FOnSelectPlaceHS;
    property LoadMapFileFilter: string read FLoadMapFileFilter write FLoadMapFileFilter;
    property SaveMapFileFilter: string read FSaveMapFileFilter write FSaveMapFileFilter;
  end;

const
  { the place options of SelectPlaceHS (a resource returns them in the Result of message $10055):
    the brush under the mouse (drop with its radius), the cursor brush, drop while the button is
    down, show the place sprite, deselect after a drop, snap the place sprite to the hexagon }
  poBrush = $01; poCursor = $02; poDropWhileDown = $04; poShowPlaceHS = $08;
  poDeselectAfterDrop = $10; poSnapToHexagon = $20;

procedure Register;

implementation

uses
  MMSystem, HSEdData, HSEdMod;

type
  { the menu items that TEObjectEditor.UpdatePopupMenu leaves in its byte-sized var parameter
    (Engine.pas declares it Boolean) }
  TPopupItems = set of (piEdit, piCut, piCopy, piPaste, piDelete);

  { (the location records come from HSEngine: TXYL, filled by THexagonSprite.GetBaseHX
    through its XYL variant, and THNWalkData of InitHNWalk; the brush sprites are TLibraryHS
    of HSLib) }


{ THSMEditControl }

destructor THSMEditControl.Destroy;
begin
  FHSMEdit.FControl := nil;
  inherited Destroy;
end;

function THSMEditControl.GetControlStyle: TEControlStyles;
begin
  Result := [];
end;

procedure THSMEditControl.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $23) and (Msg.Sender <> Self) and FHSMEdit.FActivated then
    FHSMEdit.SelectEditResource(TEResource(Msg.Obj));
end;

{ THSMPlaceControl }

procedure THSMPlaceControl.PlaceTerrain(Xhx, Yhx, Lhx, Radius, TerrainType: Shortint);
var
  Walk: THNWalkData;
begin
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Walk.Radius <= Radius do
  begin
    FHSEngine.HSSet.HexagonControl.Place(FHSEngine.HSMap.MapContainer, Walk.X, Walk.Y,
      Lhx, TerrainType);
    WalkToNextHN(Walk);
  end;
end;

procedure THSMPlaceControl.MsgProc(var Msg: TEMsg; Sender: TEObject);
var
  Xhx, Yhx, Radius: Integer;
  Walk: THNWalkData;
  Lhx: Integer;
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10005 then
  begin
    Lhx := Msg.Data[1];
    if FHSMEdit.FPlaceOptions and poBrush <> 0 then
      Radius := Msg.Param[1]
    else
      Radius := 0;
    HPtoHX(Msg.Value, Msg.Data[0], Xhx, Yhx);
    case FMode of
      pmChangeTerrain:
        FHSEngine.HSMap.ChangeTerrain(nil, Xhx, Yhx, Lhx, Radius, FTerrainType);
      pmClearTerrain:
        FHSEngine.HSMap.ClearTerrain(Xhx, Yhx, Lhx, Radius, FTerrainType);
      pmRoad:
        begin
          if FHSMEdit.FOverwrite then
            FHSEngine.HSMap.ClearTerrain(Xhx, Yhx, Lhx, Radius, -1);
          InitHNWalk(Walk, Xhx, Yhx, 0);
          while Walk.Radius <= Radius do
          begin
            { the sprite set's road control places at the centre with the terrain of the walked
              hexagon, the selected one at the walked hexagon (original quirk) }
            if FRoadControl = nil then
              FHSEngine.HSSet.RoadControl.Place(FHSEngine.HSMap.MapContainer, Xhx, Yhx, Lhx,
                FHSEngine.HSMap.MapContainer.GetField(Walk.X, Walk.Y, Lhx).TerrainType)
            else
              FRoadControl.Place(FHSEngine.HSMap.MapContainer, Walk.X, Walk.Y, Lhx,
                FHSEngine.HSMap.MapContainer.GetField(Xhx, Yhx, Lhx).TerrainType);
            WalkToNextHN(Walk);
          end;
        end;
      pmEraser:
        FHSEngine.HSMap.ClearTerrain(Xhx, Yhx, Lhx, Radius, -1);
      pmForceTerrain:
        PlaceTerrain(Xhx, Yhx, Lhx, Radius, FTerrainType);
    end;
    Msg.MsgID := 0;
    Msg.Result := 0;
  end;
end;

{ THSMEdit }

constructor THSMEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPlaceControl := THSMPlaceControl.Create(nil);
  FPlaceControl.FHSMEdit := Self;
  FControl := THSMEditControl.Create(nil);
  FControl.FHSMEdit := Self;
  FSceneLevel := 0;
  FBrushSize := 1;
  FPopupMenu := TPopupMenu.Create(Self);
  Color := clAppWorkSpace;
  FSceneValid := False;
  Options := Options + [doAutoResizeBackSurface];
  if not (csDesigning in ComponentState) then
  begin
    FHorzScrollBar := TScrollBar.Create(Self);
    FVertScrollBar := TScrollBar.Create(Self);
    with FHorzScrollBar do
    begin Align := alBottom; Height := 15; OnChange := HorzScrollBarChange; Visible := False; end;
    with FVertScrollBar do
    begin
      Align := alRight; OnChange := VertScrollBarChange; Visible := False; Kind := sbVertical;
      Width := 15;
    end;
  end;
end;

destructor THSMEdit.Destroy;
begin
  FPlaceControl.Free;
  FControl.Free;
  inherited Destroy;
end;

procedure THSMEdit.SetOverwrite(Value: Boolean);
begin
  FOverwrite := Value;
  if FOverwrite then
  begin
    if FPlaceControl.FMode = pmChangeTerrain then
      FPlaceControl.FMode := pmClearTerrain;
  end
  else
    if FPlaceControl.FMode = pmClearTerrain then
      FPlaceControl.FMode := pmChangeTerrain;
end;

procedure THSMEdit.CMWantSpecialKey(var Message: TCMWantSpecialKey);
begin
  inherited;
  { the map test only covers VK_LEFT (original precedence) }
  if (FHSEngine.HSMap <> nil) and (Message.CharCode = VK_LEFT) or
    (Message.CharCode = VK_RIGHT) or (Message.CharCode = VK_UP) or (Message.CharCode = VK_DOWN) then
    Message.Result := 1;
end;

procedure THSMEdit.UpdateScrollBars;
var
  HSMap: THSMap;
begin
  if not (csDesigning in ComponentState) and (FHSEngine <> nil) and
    (FHSEngine.HSMap <> nil) and FActivated then
  begin
    HSMap := FHSEngine.HSMap;
    FHorzScrollBar.Align := alBottom;
    FHorzScrollBar.Min := 2;
    FHorzScrollBar.LargeChange := Round(BackSurfaceWidth * 0.75) div 8;
    if HSMap.GetMaxXhp - 16 > Width then
    begin FHorzScrollBar.Max := (HSMap.GetMaxXhp - Width) div 8 - 2; FHorzScrollBar.Visible := True; end
    else begin FHorzScrollBar.Max := 2; FHorzScrollBar.Visible := False; end;
    FVertScrollBar.Min := 2;
    FVertScrollBar.Align := alRight;
    FVertScrollBar.LargeChange := Round(BackSurfaceHeight * 0.75) div 8;
    if HSMap.GetMaxYhp - 32 > Height then
    begin FVertScrollBar.Max := (HSMap.GetMaxYhp - Height) div 8 - 3; FVertScrollBar.Visible := True; end
    else begin FVertScrollBar.Max := 2; FVertScrollBar.Visible := False; end;
  end;
end;

procedure THSMEdit.UpdateCaption;
begin
  if Assigned(FOnUpdateCaption) then
    FOnUpdateCaption(Self);
end;

procedure THSMEdit.SetHSMapFilename(Value: string);
begin
  FHSMapFileName := Value;
  UpdateCaption;
end;

procedure THSMEdit.SetBrushSize(Value: Byte);
begin
  if FBrushes[FBrushSize] <> nil then
    FHSEngine.HSMap.Remove(FBrushes[FBrushSize]);
  FBrushSize := Value;
end;

function THSMEdit.GetCopyPasteHSIDstring: string;
begin
  if FSceneLevel = 0 then
    Result := 'Surface Hexagonsprites'
  else
    Result := 'Underground Hexagonsprites';
end;

function THSMEdit.CutHS: Boolean;
var
  Selection: THexagonSpriteSelection;
  CopyComponent: TECopyComponent;
  I: Integer;
  HS: THexagonSprite;
begin
  Result := False;
  Selection := FHSEngine.HSMap.Selection;
  if Selection.LocationHS.Count <> 0 then
  begin
    CopyComponent := TECopyComponent.Create(Self);
    for I := Selection.LocationHS.Count - 1 downto 0 do
    begin
      HS := Selection.LocationHS[I];
      CopyComponent.EObjectList.Add(HS);
    end;
    if CopyComponent.Count <> 0 then
    begin
      CopyComponent.CopyToClipboard(FHSEngine, GetCopyPasteHSIDstring);
      Result := True;
    end;
    for I := Selection.LocationHS.Count - 1 downto 0 do
    begin
      HS := Selection.LocationHS[I];
      if HS.GetLevel <> 0 then
        Selection.GetHS(I).Destroy;
    end;
    CopyComponent.Destroy;
    FHSEngine.HSMap.SetModified;
  end;
end;

function THSMEdit.CopyHS: Boolean;
var
  Selection: THexagonSpriteSelection;
  I: Integer;
begin
  Result := False;
  Selection := FHSEngine.HSMap.Selection;
  if Selection.GetCount <> 0 then
  begin
    with TECopyComponent.Create(Self) do
    begin
      for I := Selection.GetCount - 1 downto 0 do
        EObjectList.Add(Selection.GetHS(I));
      if Count <> 0 then
      begin
        CopyToClipboard(FHSEngine, GetCopyPasteHSIDstring);
        Result := True;
      end;
      Destroy;
    end;
  end;
end;

function THSMEdit.PasteHS: Boolean;
var
  Xhp, Yhp, Lhx: Integer;
  Xhx, Yhx, Lhx0: Integer;
  Selection: THexagonSpriteSelection;
  CopyComponent: TECopyComponent;
  I: Integer;
begin
  Result := False;
  Selection := FHSEngine.HSMap.Selection;
  if Selection.LocationHS.Count <> 0 then
  begin
    Xhx := THexagonSprite(Selection.LocationHS[0]).GetXhx;
    Yhx := THexagonSprite(Selection.LocationHS[0]).GetYhx;
    Lhx0 := THexagonSprite(Selection.LocationHS[0]).GetLhx;
    CopyComponent := TECopyComponent.Create(Self);
    CopyComponent.PasteFromClipboard(FHSEngine, GetCopyPasteHSIDstring);
    if CopyComponent.Count <> 0 then
    begin
      Selection.UnselectLocation;
      HXtoHP(Xhx, Yhx, Xhp, Yhp);
      Inc(Xhp, 16);
      Inc(Yhp, 16);
      Lhx := Lhx0;
      Selection.QuickClear;
      for I := CopyComponent.Count - 1 downto 0 do
      begin
        if FHSEngine.HSMap.Place(THexagonSprite(CopyComponent.EObjects[I]), Xhp, Yhp, Lhx) then
          Selection.SelectLocationHS(THexagonSprite(CopyComponent.EObjects[I]))
        else
        begin
          CopyComponent.EObjects[I].Destroy;
          MessageBeep(0);
        end;
        CopyComponent.EObjectList.Delete(I);
      end;
    end;
    CopyComponent.Free;
    FHSEngine.HSMap.SetModified;
    Result := True;
  end;
end;

function THSMEdit.DeleteHS: Boolean;
var
  Selection: THexagonSpriteSelection;
  I: Integer;
begin
  Result := False;
  Selection := FHSEngine.HSMap.Selection;
  if Selection.GetCount <> 0 then
  begin
    for I := Selection.GetCount - 1 downto 0 do
      if Selection.GetHS(I).GetLevel <> 0 then
      begin
        Selection.GetHS(I).Destroy;
        Result := True;
      end;
    FHSEngine.HSMap.SetModified;
  end;
end;

procedure THSMEdit.ClearKeyboardQueue;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, Application.MainForm.Handle, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE) do ;
end;

procedure THSMEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if FActivated then
  begin
    if ssCtrl in Shift then
      case Key of
        Ord('X'): CutHS;
        Ord('C'): CopyHS;
        Ord('V'): PasteHS;
        VK_DELETE: DeleteHS;
      end;
    if Shift = [] then
      case Key of
        VK_SPACE:
          begin
            SelectEditResource(nil);
            FHSEngine.HSMap.Selection.UnselectAll;
          end;
        VK_UP:
          begin
            if FViewMode = hvmPreview then
            begin Dec(FPreviewY, 24); ValidatePreviewView; RebuildScene; end
            else FVertScrollBar.Position := FVertScrollBar.Position - 4;
            ClearKeyboardQueue;
          end;
        VK_DOWN:
          begin
            if FViewMode = hvmPreview then
            begin Inc(FPreviewY, 24); ValidatePreviewView; RebuildScene; end
            else FVertScrollBar.Position := FVertScrollBar.Position + 4;
            ClearKeyboardQueue;
          end;
        VK_LEFT:
          begin
            if FViewMode = hvmPreview then
            begin Dec(FPreviewX, 24); ValidatePreviewView; RebuildScene; end
            else FHorzScrollBar.Position := FHorzScrollBar.Position - 4;
            ClearKeyboardQueue;
          end;
        VK_RIGHT:
          begin
            if FViewMode = hvmPreview then
            begin Inc(FPreviewX, 24); ValidatePreviewView; RebuildScene; end
            else FHorzScrollBar.Position := FHorzScrollBar.Position + 4;
            ClearKeyboardQueue;
          end;
        VK_DELETE:
          DeleteHS;
        VK_ESCAPE:
          if FViewMode = hvmPreview then
            HidePreview;
      end;
  end;
  if (Key = VK_RETURN) and (Shift = [ssAlt]) then
  begin
    if FViewMode = hvmDefault then
      ShowPreview
    else
      HidePreview;
  end
  else
    inherited KeyDown(Key, Shift);
end;

procedure THSMEdit.PopupCut(Sender: TObject);
begin CutHS; end;

procedure THSMEdit.PopupCopy(Sender: TObject);
begin CopyHS; end;

procedure THSMEdit.PopupPaste(Sender: TObject);
begin PasteHS; end;

procedure THSMEdit.PopupDelete(Sender: TObject);
begin DeleteHS; end;

procedure THSMEdit.EditSelectedHS;
var
  Selection: THexagonSpriteSelection;
begin
  Selection := FHSEngine.HSMap.Selection;
  if (Selection.GetCount <> 0) and (Selection.GetHS(0) <> nil) then
    TEObjectEditorClass(Selection.GetHS(0).Editor).Edit(Selection.GetHS(0), FHSEngine, nil);
end;

procedure THSMEdit.PopupEdit(Sender: TObject);
begin EditSelectedHS; end;

procedure THSMEdit.ClearPopupMenu;
var
  I: Integer;
begin
  with FPopupMenu do
    for I := Items.Count - 1 downto 0 do
      Items[I].Free;
end;

procedure THSMEdit.ShowPopupMenu(X, Y: Integer);
var
  Items: TPopupItems;
  Item: TMenuItem;
begin
  ClearPopupMenu;
  if FHSEngine.HSMap.Selection.GetCount <> 0 then
  begin
    if FHSEngine.HSMap.Selection.GetCount = 1 then
    begin
      Items := [piCut, piCopy, piPaste, piDelete];
      TEObjectEditorClass(FHSEngine.HSMap.Selection.GetHS(0).Editor).UpdatePopupMenu(
        FHSEngine.HSMap.Selection.GetHS(0), FHSEngine, Engine.TEditMode(Items), FPopupMenu);
      if (Items <> []) and (FPopupMenu.Items.Count <> 0) then
        FPopupMenu.Items.Add(NewLine);
    end
    else
      Items := [piCut, piCopy, piPaste, piDelete];
    if piEdit in Items then
    begin
      Item := TMenuItem.Create(FPopupMenu); Item.OnClick := PopupEdit;
      Item.Caption := FHSEngine.TranslateText(EditStr); Item.Default := True;
      FPopupMenu.Items.Insert(0, Item);
      FPopupMenu.Items.Insert(1, NewLine);
    end;
    if piCut in Items then
    begin
      Item := TMenuItem.Create(FPopupMenu); Item.OnClick := PopupCut;
      Item.Caption := FHSEngine.TranslateText(CutStr); FPopupMenu.Items.Add(Item);
    end;
    if piCopy in Items then
    begin
      Item := TMenuItem.Create(FPopupMenu); Item.OnClick := PopupCopy;
      Item.Caption := FHSEngine.TranslateText(CopyStr); FPopupMenu.Items.Add(Item);
    end;
    if piPaste in Items then
    begin
      Item := TMenuItem.Create(FPopupMenu); Item.OnClick := PopupPaste;
      Item.Caption := FHSEngine.TranslateText(PasteStr); FPopupMenu.Items.Add(Item);
    end;
    if piDelete in Items then
    begin
      Item := TMenuItem.Create(FPopupMenu); Item.OnClick := PopupDelete;
      Item.Caption := FHSEngine.TranslateText(DeleteStr); FPopupMenu.Items.Add(Item);
    end;
    FPopupMenu.Popup(X, Y);
  end;
end;

function THSMEdit.GetRoadControl: TMORTerrainControl;
begin Result := FPlaceControl.FRoadControl; end;

procedure THSMEdit.SetRoadControl(Value: TMORTerrainControl);
begin FPlaceControl.FRoadControl := Value; end;

procedure THSMEdit.SelectPlaceHS(AHSPlaceControl: TEObject; APlaceHS: THexagonSprite;
  AOptions, ADX, ADY: Integer);
var
  Msg: TEMsg;
begin
  if FActivated then
  begin
    DeselectPlaceHS;
    Assert(AHSPlaceControl <> nil, 'No HSPlaceControl defined');
    FPlaceDX := ADX;
    FPlaceDY := ADY;
    FPlaceOptions := AOptions;
    FPlaceHS := APlaceHS;
    if FPlaceHS <> nil then
      FPlaceHS.SetEditMode(True);
    FHSPlaceControl := AHSPlaceControl;
    FHSEngine.HSMap.Selection.UnselectAll;
    FHSEngine.HSMap.Mouse.SetCapture(Self);
    InitMsg(Msg, $23, FControl);
    Msg.Data[0] := 0;
    FHSEngine.ControlNode.SendMsg(Msg, FControl);
    if Assigned(FOnSelectPlaceHS) then
      FOnSelectPlaceHS(Self);
  end;
end;

procedure THSMEdit.DeselectPlaceHS;
begin
  if FHSPlaceControl <> nil then
  begin
    if Assigned(FOnDeselectPlaceHS) then
      FOnDeselectPlaceHS(Self);
    FHSPlaceControl := nil;
  end;
  if FPlaceHS <> nil then
  begin
    FPlaceHS.Free;
    FPlaceHS := nil;
  end;
  FPlaceOptions := 0;
  with FHSEngine.HSMap.Mouse do
    if Capture = Self then
      SetCapture(nil);
end;

procedure THSMEdit.SelectChangeTerrain(TerrainType: Shortint);
var
  PlaceControl: THSMPlaceControl;
begin
  PlaceControl := FPlaceControl;
  PlaceControl.FMode := pmChangeTerrain;
  PlaceControl.FTerrainType := TerrainType;
  SelectPlaceHS(PlaceControl, nil, poBrush or poDropWhileDown, 0, 0);
end;

procedure THSMEdit.SelectClearTerrain(TerrainType: Shortint);
var
  PlaceControl: THSMPlaceControl;
begin
  PlaceControl := FPlaceControl;
  PlaceControl.FMode := pmClearTerrain;
  PlaceControl.FTerrainType := TerrainType;
  SelectPlaceHS(PlaceControl, nil, poBrush or poDropWhileDown, 0, 0);
end;

procedure THSMEdit.SelectForceTerrain(TerrainType: Shortint);
var
  PlaceControl: THSMPlaceControl;
begin
  PlaceControl := FPlaceControl;
  PlaceControl.FMode := pmForceTerrain;
  PlaceControl.FTerrainType := TerrainType;
  SelectPlaceHS(PlaceControl, nil, poBrush or poDropWhileDown, 0, 0);
end;

procedure THSMEdit.SelectEraser;
begin
  FPlaceControl.FMode := pmClearTerrain;
  FPlaceControl.FTerrainType := -1;
  SelectPlaceHS(FPlaceControl, nil, poBrush or poDropWhileDown, 0, 0);
end;

procedure THSMEdit.SelectRoad;
begin
  FPlaceControl.FMode := pmRoad;
  SelectPlaceHS(FPlaceControl, nil, poCursor or poDropWhileDown, 0, 0);
end;

procedure THSMEdit.SelectEditResource(Resource: TEResource);
var
  HS: THexagonSprite;
  Msg: TEMsg;
  Options: Integer;
begin
  if Resource <> nil then
  begin
    HS := nil;
    InitMsg(Msg, $10055, nil);
    Resource.MsgProc(Msg, FControl);
    Options := Msg.Result;
    if Options and poShowPlaceHS <> 0 then
      HS := THexagonSprite(Resource.CreateResourceUser);
    SelectPlaceHS(Resource, HS, Options, 0, 0);
  end
  else
  begin
    DeselectPlaceHS;
    InitMsg(Msg, $23, FControl);
    Msg.Data[0] := 0;
    FHSEngine.ControlNode.SendMsg(Msg, FControl);
  end;
end;

procedure THSMEdit.SetHSEngine(Value: THSEngine);
begin
  if Value <> nil then
  begin
    FHSEngine := Value;
    FPlaceControl.FHSEngine := FHSEngine;
  end
  else
    FHSEngine := nil;
  if FHSEngine <> nil then
    FControl.Connect(FHSEngine.ControlNode)
  else
    FControl.Disconnect;
end;

procedure THSMEdit.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if not (csDestroying in ComponentState) then
  begin
    if FHorzScrollBar <> nil then
      FHorzScrollBar.Parent := AParent;
    if FVertScrollBar <> nil then
      FVertScrollBar.Parent := AParent;
  end;
end;

procedure THSMEdit.ShowMsg(S: string);
begin
  if Assigned(FOnShowMessage) then
    FOnShowMessage(S);
end;

procedure THSMEdit.Resize;
begin
  inherited Resize;
  if FActivated and FSceneValid then
  begin
    UpdateScrollBars;
    FHSEngine.HSMap.StaticSceneInvalid := True;
  end;
end;

procedure THSMEdit.BuildStaticScene;
var
  SurfaceDesc: TSurfaceDesc;
  T: Integer;
  HSMap: THSMap;
begin
  if FActivated then
  begin
    if ActiveDC.GetSurface(2).Lock(SurfaceDesc) = 0 then
    begin
      HSMap := FHSEngine.HSMap;
      T := timeGetTime;
      HSMap.UpdateStaticScene;
      FStaticUpdateTime := timeGetTime - T;
      T := timeGetTime;
      HSMap.DrawStaticScene(SurfaceDesc);
      FStaticDrawTime := timeGetTime - T;
      ActiveDC.GetSurface(2).Unlock;
    end;
    if Assigned(FOnStaticSceneUpdated) then
      FOnStaticSceneUpdated(Self);
  end;
end;

procedure THSMEdit.BltStaticScene(Dest: TSurface);
var
  T: Integer;
begin
  T := timeGetTime;
  ActiveDC.GetSurface(2).Blt(Dest, nil, 0, 0);
  FStaticBltTime := timeGetTime - T;
end;

procedure THSMEdit.CenterView(Xhx, Yhx, Lhx: Shortint);
var
  W, H, Xhp, Yhp: Integer;
  HSMap: THSMap;
begin
  FSceneLevel := Lhx;
  W := ActiveDC.GetSurface(0).Width;
  H := ActiveDC.GetSurface(0).Height;
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  HSMap := FHSEngine.HSMap;
  Dec(Xhp, W div 2);
  Dec(Yhp, H div 2);
  if Xhp < 16 then
    Xhp := 16;
  if HSMap.GetMaxXhp - W - 16 < Xhp then
    Xhp := HSMap.GetMaxXhp - W - 16;
  if Yhp < 16 then
    Yhp := 16;
  { 26 in the test and 24 in the limit (original) }
  if HSMap.GetMaxYhp - H - 26 < Yhp then
    Yhp := HSMap.GetMaxYhp - H - 24;
  HSMap.SetViewPort(Xhp, Yhp, FSceneLevel, W, H);
  FHorzScrollBar.Position := Xhp shr 3;
  FVertScrollBar.Position := Yhp shr 3;
end;

procedure THSMEdit.RebuildScene;
var
  HSMap: THSMap;
begin
  if FActivated then
  begin
    HSMap := FHSEngine.HSMap;
    if ActiveDC <> nil then
    begin
      if FViewMode = hvmDefault then
        HSMap.SetViewPort(FHorzScrollBar.Position shl 3, FVertScrollBar.Position shl 3, FSceneLevel,
          ActiveDC.GetSurface(0).Width, ActiveDC.GetSurface(0).Height)
      else
        HSMap.SetViewPort(FPreviewX, FPreviewY, FSceneLevel, ActiveDC.GetSurface(0).Width,
          ActiveDC.GetSurface(0).Height);
      FHSEngine.HSMap.StaticSceneInvalid := True;
    end;
  end;
end;

procedure THSMEdit.SetSceneLevel(Value: Shortint);
begin
  if (Value <> FSceneLevel) and (Value >= 0) and
    (Value <= FHSEngine.HSMap.MapContainer.LevelCount - 1) then
  begin
    FSceneLevel := Value;
    RebuildScene;
  end;
end;

procedure THSMEdit.BuildDynamicScene;
var
  SurfaceDesc: TSurfaceDesc;
  HSMap: THSMap;
  T: Integer;
begin
  if FActivated then
  begin
    HSMap := FHSEngine.HSMap;
    HSMap.NewFrame;
    if HSMap.StaticSceneInvalid then
      BuildStaticScene;
    T := timeGetTime;
    HSMap.UpdateDynamicScene;
    FDynamicUpdateTime := timeGetTime - T;
    BltStaticScene(ActiveDC.GetSurface(FSurfaceIndex));
    if ActiveDC.GetSurface(FSurfaceIndex).Lock(SurfaceDesc) = 0 then
    begin
      T := timeGetTime;
      HSMap.DrawDynamicScene(SurfaceDesc);
      FDynamicDrawTime := timeGetTime - T;
      ActiveDC.GetSurface(FSurfaceIndex).Unlock;
    end;
  end;
end;

procedure THSMEdit.ShowSelection;
var
  I, J, N: Integer;
  Xhx, Yhx: Integer;
  XYL: TXYL;
  Selection: THexagonSpriteSelection;
  HS: THexagonSprite;
  AllTransparent: Boolean;
  Brush: TLibraryHS;
begin
  if FHSEngine.HSMap.Selection.GetCount <> 0 then
  begin
    Selection := FHSEngine.HSMap.Selection;
    for I := 0 to Selection.GetCount - 1 do
      if not (cmShowSelectionSelf in THexagonSprite(Selection.GetChild(I)).ControlMode) then
      begin
        THexagonSprite(Selection.GetChild(I)).GetBaseHX(XYL.XYL);
        HS := THexagonSprite(Selection.GetChild(I));
        N := HS.GetTerrainCount - 1;
        if N < 0 then
          N := 0;
        AllTransparent := (HS.GetTerrain(0) = -1) and (HS.GetOverlay(0) = -1);
        for J := 0 to N do
          if AllTransparent and (HS.GetTerrain(J) >= -1) or (HS.GetTerrain(J) >= 0) or
            (HS.GetOverlay(J) >= 0) or (J = 0) then
          begin
            CenterHNtoHX(XYL.X, XYL.Y, J, Xhx, Yhx);
            if FHSEngine.HSMap.Viewing(Xhx, Yhx, XYL.L) then
            begin
              if J <> 0 then
                Brush := HSEditModule.HSBrushes.CreateHS(0)
              else
              begin
                Brush := HSEditModule.HSBrushes.CreateHS(3);
                Brush.Level := Brush.Level + 1;
              end;
              Brush.DestroyOnShow := True;
              Brush.PlaceHXEx(FHSEngine.HSMap.MapContainer, Xhx, Yhx, XYL.L, -1, True);
            end;
          end;
      end;
  end;
end;

function THSMEdit.DropSelectedPlaceHS(Xhp, Yhp, Lhx: Integer): Integer;
var
  Msg: TEMsg;
begin
  if FHSPlaceControl <> nil then
  begin
    InitMsg(Msg, $10005, nil);
    Msg.Param[0] := Integer(FHSEngine.HSMap.MapContainer);
    if FPlaceOptions and poBrush <> 0 then
      Msg.Param[1] := FBrushSize - 1
    else
      Msg.Param[1] := 0;
    if FOverwrite then
      Msg.Param[2] := 1
    else
      Msg.Param[2] := 0;
    Msg.Value := Xhp;
    Msg.Data[0] := Yhp;
    Msg.Data[1] := Lhx;
    FHSPlaceControl.MsgProc(Msg, nil);
    if Msg.Result = 0 then
      FHSEngine.HSMap.SetModified;
    Result := Msg.Result;
    if (Result = 0) and (FPlaceOptions and poDeselectAfterDrop <> 0) then
      DeselectPlaceHS;
  end
  else
    Result := 0;
end;

procedure THSMEdit.UpdateMouseCoordinates;
var
  X, Y: Integer;
  Shift: TShiftState;
begin
  if ActiveDC <> nil then
  begin
    ActiveDC.GetMousePos(X, Y);
    { Shift is never set (original) }
    if FViewMode = hvmDefault then
      FHSEngine.HSMap.Mouse.Move(TShiftState(Pointer(@Shift)^), X, Y); { Keep the original uninitialized stack byte. }
  end;
end;

procedure THSMEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HSMap: THSMap; MapPtr: Pointer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not FIgnoreMouseDown and (FViewMode = hvmDefault) and FActivated then
  begin
    MapPtr := @HSMap; HSMap := FHSEngine.HSMap; { Keep the original stack slot. }
    HSMap.Mouse.Down(Button, Shift, X, Y);
    if (HSMap.Mouse.GetXhx <> -1) and (Button = mbLeft) and (FHSPlaceControl <> nil) and
      (HSMap.Engine.HSMap.Mouse.Capture = Self) then
      if DropSelectedPlaceHS(HSMap.Mouse.GetXhp, HSMap.Mouse.GetYhp,
        HSMap.Engine.HSMap.ViewL) <> 0 then
      begin
        ShowMsg(HSMap.Engine.TranslateText(InvalidPlaceMentStr));
        Beep;
      end;
    if Button = mbRight then
      if FHSPlaceControl = nil then
        ShowPopupMenu(ClientOrigin.X + X, ClientOrigin.Y + Y)
      else
      begin
        SelectEditResource(nil);
        if Assigned(FOnSelectPlaceHS) then
          FOnSelectPlaceHS(Self);
      end;
  end;
  FIgnoreMouseDown := False;
end;

procedure THSMEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (FViewMode = hvmDefault) and FActivated then
    FHSEngine.HSMap.Mouse.Up(Button, Shift, X, Y);
end;

procedure THSMEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
end;

procedure THSMEdit.SelectAndEditHS(Xhx, Yhx, Lhx: Integer);
var
  PopupMenu: TPopupMenu;
  Items: TPopupItems;
  Xhp, Yhp: Integer;
  MapField: TMapField;
  I: Integer;
  HS: THexagonSprite;
  Found: Boolean;
begin
  HS := nil;
  MapField := FHSEngine.HSMap.MapContainer.GetField(Xhx, Yhx, Lhx);
  { never used: the editors fill FPopupMenu (original) }
  PopupMenu := TPopupMenu.Create(nil);
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  I := MapField.GetCount - 1;
  Found := False;
  while not Found and (I >= 0) do
  begin
    HS := MapField.HSList^[I];
    if HS.CanSelect(Xhp, Yhp) then
    begin
      Items := [];
      TEObjectEditorClass(HS.Editor).UpdatePopupMenu(HS, MapField.GetEngine, Engine.TEditMode(Items), FPopupMenu);
      Found := piEdit in Items;
    end;
    Dec(I);
  end;
  if Found then
  begin
    FHSEngine.HSMap.Selection.UnselectLocation;
    FHSEngine.HSMap.Selection.SelectLocationHS(HS);
    EditSelectedHS;
  end;
  PopupMenu.Free;
end;

procedure THSMEdit.DblClick;
begin
  inherited DblClick;
end;

procedure THSMEdit.VerifyMouseScrolling;
var
  MouseX, MouseY, W, H: Integer;
  Xhp, Yhp: Integer;
  HSMap: THSMap;
begin
  W := ActiveDC.GetSurface(0).Width;
  H := ActiveDC.GetSurface(0).Height;
  ActiveDC.GetMousePos(MouseX, MouseY);
  HSMap := FHSEngine.HSMap;
  Xhp := HSMap.ViewXhp;
  Yhp := HSMap.ViewYhp;
  if W - 20 < MouseX then
    Inc(Xhp, 16);
  if MouseX < 20 then
    Dec(Xhp, 16);
  if H - 20 < MouseY then
    Inc(Yhp, 16);
  if MouseY < 20 then
    Dec(Yhp, 16);
  if Xhp < 16 then
    Xhp := 16;
  if Xhp > HSMap.GetMaxXhp - W - 16 then
    Xhp := HSMap.GetMaxXhp - W - 16;
  if Yhp < 16 then
    Yhp := 16;
  if Yhp > HSMap.GetMaxYhp - H - 26 then
    Yhp := HSMap.GetMaxYhp - H - 24;
  HSMap.SetViewPort(Xhp, Yhp, FSceneLevel, W, H);
  if FViewMode = hvmDefault then
  begin
    FHorzScrollBar.Position := Xhp shr 3;
    FVertScrollBar.Position := Yhp shr 3;
  end
  else
  begin
    FPreviewX := Xhp;
    FPreviewY := Yhp;
    ValidatePreviewView;
  end;
end;

procedure THSMEdit.UpdateFrame;
var
  Xhp, Yhp: Integer;
  HSMap: THSMap;
  StaticChanged: Boolean;
begin
  Sleep(1);
  if FActivated and UpdateMap then
  begin
    if ActiveDC <> SecondaryDC then
    begin
      UpdateMouseCoordinates;
      if Application.Active and IsWindowEnabled(Application.MainForm.Handle) and
        (FHSEngine.HSMap.Mouse.GetXhx <> -1) then
      begin
        HSMap := FHSEngine.HSMap;
        if (GetMouseButton = 1) and (Screen.ActiveForm = Application.MainForm) then
        begin
          if (FHSPlaceControl <> nil) and (FPlaceOptions and poDropWhileDown <> 0) then
            DropSelectedPlaceHS(HSMap.Mouse.GetXhp, HSMap.Mouse.GetYhp,
              HSMap.Engine.HSMap.ViewL);
        end
        else
          FIgnoreMouseDown := False;
        if Screen.ActiveForm = Application.MainForm then
        begin
          if FPlaceOptions and poBrush <> 0 then
            FBrushes[FBrushSize].PlaceHXEx(HSMap.MapContainer, HSMap.Mouse.GetXhx,
              HSMap.Mouse.GetYhx, HSMap.ViewL, -1, True);
          if FPlaceOptions and poCursor <> 0 then
            FBrushes[1].PlaceHXEx(HSMap.MapContainer, HSMap.Mouse.GetXhx,
              HSMap.Mouse.GetYhx, HSMap.ViewL, -1, True);
          if (FPlaceOptions and poShowPlaceHS <> 0) and (FPlaceHS <> nil) then
          begin
            if FPlaceOptions and poSnapToHexagon <> 0 then
              HXtoHP(HSMap.Mouse.GetXhx, HSMap.Mouse.GetYhx, Xhp, Yhp)
            else
            begin
              Xhp := HSMap.Mouse.GetXhp;
              Yhp := HSMap.Mouse.GetYhp;
            end;
            HSMap.Engine.HSMap.Place(FPlaceHS, Xhp + FPlaceDX, Yhp + FPlaceDY,
              HSMap.ViewL);
          end;
        end;
      end;
    end
    else
      VerifyMouseScrolling;
    ShowSelection;
    StaticChanged := FHSEngine.HSMap.StaticSceneInvalid;
    BuildDynamicScene;
    if FPlaceHS <> nil then
      FHSEngine.HSMap.Remove(FPlaceHS);
    if FPlaceOptions and poCursor <> 0 then
      FHSEngine.HSMap.Remove(FBrushes[1]);
    if FPlaceOptions and poBrush <> 0 then
      FHSEngine.HSMap.Remove(FBrushes[FBrushSize]);
    if FCurrentFrameRate <> 0 then
    begin
      if StaticChanged then
      begin
        FMaxFrameRate := FStaticDrawTime + FDynamicDrawTime + FStaticUpdateTime +
          FDynamicUpdateTime + FStaticBltTime + FBltTime;
        FIdleTime := 1000 div FCurrentFrameRate - FMaxFrameRate;
      end
      else
      begin
        FMaxFrameRate := FDynamicDrawTime + FDynamicUpdateTime + FStaticBltTime + FBltTime;
        FIdleTime := 1000 div FCurrentFrameRate - FMaxFrameRate;
      end;
    end
    else
      FIdleTime := 0;
    if FMaxFrameRate <> 0 then
      FMaxFrameRate := 1000 div FMaxFrameRate;
  end;
  inherited UpdateFrame;
end;

function THSMEdit.ExecuteBltSurfaceEvent: HResult;
var
  T: Integer;
  DC: HDC;
  OldBrush: HBRUSH;
begin
  if FActivated and FSceneValid then
  begin
    T := timeGetTime;
    FSurfaceIndex := 1;
    Result := inherited ExecuteBltSurfaceEvent;
    FBltTime := timeGetTime - T;
  end
  else
  begin
    DC := Windows.GetDC(Handle);
    OldBrush := SelectObject(DC, CreateSolidBrush(GetSysColor(COLOR_APPWORKSPACE)));
    Rectangle(DC, -1, -1, Width + 2, Height + 2);
    DeleteObject(SelectObject(DC, OldBrush));
    ReleaseDC(Handle, DC);
    Result := 0;
  end;
end;

procedure THSMEdit.SurfaceDataLost(SurfaceType: Integer);
begin
  inherited SurfaceDataLost(SurfaceType);
  if FActivated and FSceneValid and (SurfaceType = 1) then
  begin
    ActiveDC.GetSurface(1).Cls(0);
    RebuildScene;
  end;
end;

function THSMEdit.SaveAs: Boolean;
var
  D: TSaveDialog;
  Saved: Boolean;
begin
  Saved := False;
  if FActivated then
  begin
    { never freed (its owner is Self; original) }
    D := TSaveDialog.Create(Self);
    D.Options := D.Options + [ofOverwritePrompt, ofCreatePrompt];
    D.Filter := FSaveMapFileFilter;
    D.InitialDir := GetCurrentDir;
    D.DefaultExt := LowerCase(Copy(D.Filter, Length(D.Filter) - 2, 3));
    D.FileName := FHSMapFileName;
    if Pos('.', D.FileName) <> 0 then
      D.FileName := Copy(D.FileName, 1, Pos('.', D.FileName) - 1);
    if D.Execute then
    begin
      UpdateWindow(Handle);
      UpdateWindow(GetDesktopWindow);
      Repaint;
      FHSEngine.SaveHSM(D.FileName, ProgressEvent);
      FHSMapFileName := D.FileName;
      FHSEngine.HSMap.ResetModified;
      UpdateCaption;
      Saved := True;
    end;
  end;
  Result := Saved;
end;

function THSMEdit.Save: Boolean;
var
  HSEngine: THSEngine;
begin
  if FActivated then
  begin
    HSEngine := FHSEngine;
    if CompareText(FHSMapFileName, 'noname.hsm') <> 0 then
    begin
      UpdateWindow(Handle);
      HSEngine.SaveHSM(FHSMapFileName, ProgressEvent);
      HSEngine.HSMap.ResetModified;
      Result := True;
    end
    else
      Result := SaveAs;
  end
  else
    Result := False;
end;

function THSMEdit.CanCloseMap: Boolean;
var
  R: Integer;
begin
  with FHSEngine do
    if HSMap <> nil then
    begin
      PauseFrameUpdateLoop;
      if not (msModified in HSMap.Status) then
        R := mrNo
      else
        R := MessageDlg(Format(FHSEngine.TranslateText(SaveChangesToXStr), [FHSMapFileName]),
          mtConfirmation, [mbYes, mbNo, mbCancel], 0);
      if R = mrYes then
        if FHSMapFileName <> 'noname.hsm' then
        begin
          FHSEngine.SaveHSM(FHSMapFileName, ProgressEvent);
          HSMap.ResetModified;
        end
        else
          if not SaveAs then
            R := mrCancel;
      Result := R <> mrCancel;
      ResumeFrameUpdateLoop;
    end
    else
      Result := True;
end;

procedure THSMEdit.ProgressEvent(Sender: TEObject; const Msg: string; Percent: Integer);
begin
  if FProgressDlg <> nil then
  begin
    FProgressDlg.ProgressMessage.Caption := Msg;
    FProgressDlg.ProgressBar.Position := Percent;
    FProgressDlg.ProgressPanel.Repaint;
  end;
end;

function THSMEdit.LoadHSM(const FileName: string): Boolean;
begin
  FHSMapFileName := FileName;
  FProgressDlg := TProgressDlg.Create(Self);
  FProgressDlg.Caption := FHSEngine.TranslateText(LoadingStr) + ' ' + ExtractFileName(FileName);
  FProgressDlg.ProgressMessage.Caption := FHSEngine.TranslateText(OneMomentPleaseStr);
  FProgressDlg.Show;
  FProgressDlg.Repaint;
  FHSEngine.LoadHSM(FileName, True, ProgressEvent);
  { freed but not cleared (original) }
  FProgressDlg.Free;
  if FHSEngine.HSMap <> nil then
  begin
    FHSEngine.HSMap.Activate;
    FHSEngine.HSMap.ResetModified;
    Result := True;
  end
  else
    Result := False;
end;

function THSMEdit.Load: Boolean;
var
  D: TOpenDialog;
begin
  Result := False;
  { never freed (its owner is Self; original) }
  D := TOpenDialog.Create(Self);
  D.Filter := FLoadMapFileFilter;
  if D.Execute and CanCloseMap then
  begin
    Close;
    UpdateWindow(Handle);
    UpdateWindow(GetDesktopWindow);
    Repaint;
    Result := LoadHSM(D.FileName);
    if Result then
      Activate;
  end;
end;

function THSMEdit.Close: Boolean;
begin
  Result := CanCloseMap;
  if Result and (FHSEngine.HSMap <> nil) then
  begin
    if msActivated in FHSEngine.HSMap.Status then
      FHSEngine.HSMap.Deactivate;
    DeActivate;
    FHSEngine.CloseHSM(nil);
    FHSMapFileName := 'noname.hsm';
  end;
end;

function THSMEdit.NewMap(Settings: TNewHSMapSettings): Boolean;
begin
  Result := Close;
  if Result then
    try
      FHSEngine.NewHSM(Settings.HSMapClassID);
      if FHSEngine.HSMap.CreateNewMap(Settings) then
      begin
        FHSMapFileName := 'noname.hsm';
        Activate;
        Result := True;
      end
      else
        Result := False;
    except
      FHSEngine.CloseHSM(nil);
      raise;
    end;
end;

procedure THSMEdit.HorzScrollBarChange(Sender: TObject);
begin
  if FHorzScrollBar.Visible then
    RebuildScene;
end;

procedure THSMEdit.VertScrollBarChange(Sender: TObject);
begin
  if FVertScrollBar.Visible then
    RebuildScene;
end;

procedure THSMEdit.Activate;
var
  HSMap: THSMap;
  I: Integer;
begin
  if not FActivated then
  begin
    if FHSEngine = nil then
      raise Exception.Create('No HexagonSpriteEngine defined (HSMapEdit)');
    FSceneLevel := 0;
    HSMap := FHSEngine.HSMap;
    HSMap.Status := HSMap.Status + [msEditting];
    for I := 1 to 3 do
      if FBrushes[I] = nil then
        FBrushes[I] := HSEditModule.HSBrushes.CreateHS(I - 1);
    FActivated := True;
    StartUpdateFrameLoop;
    Sleep(100);
    UpdateScrollBars;
    FSceneValid := True;
    RebuildScene;
    if Assigned(FOnActivate) then
      FOnActivate(Self);
    UpdateCaption;
  end;
end;

procedure THSMEdit.DeActivate;
var
  HSMap: THSMap;
  I: Integer;
begin
  if FActivated then
  begin
    DeselectPlaceHS;
    FActivated := False;
    FSceneValid := False;
    HSMap := FHSEngine.HSMap;
    HSMap.Status := HSMap.Status - [msEditting];
    HSMap.Remove(FBrushes[FBrushSize]);
    for I := 1 to 3 do
      if FBrushes[I] <> nil then
      begin
        FBrushes[I].Free;
        FBrushes[I] := nil;
      end;
    FHorzScrollBar.Visible := False;
    FVertScrollBar.Visible := False;
    StopUpdateFrameLoop;
    if Assigned(FOnDeactivate) then
      FOnDeactivate(Self);
    UpdateCaption;
    UpdateWindow(Handle);
  end;
end;

procedure THSMEdit.ValidatePreviewView;
var
  MaxX, MaxY: Integer;
begin
  MaxX := FHSEngine.HSMap.GetMaxXhp - ActiveDC.GetSurface(0).Width - 16;
  MaxY := FHSEngine.HSMap.GetMaxYhp - ActiveDC.GetSurface(0).Height - 16;
  if MaxX < FPreviewX then
    FPreviewX := MaxX;
  if FPreviewX < 16 then
    FPreviewX := 16;
  if MaxY < FPreviewY then
    FPreviewY := MaxY;
  if FPreviewY < 16 then
    FPreviewY := 16;
end;

procedure THSMEdit.ShowPreview;
begin
  if FActivated and (FViewMode = hvmDefault) then
  begin
    FViewMode := hvmPreview;
    SwapDC;
    FPreviewX := FHorzScrollBar.Position shl 3;
    FPreviewY := FVertScrollBar.Position shl 3;
    RebuildScene;
  end;
end;

procedure THSMEdit.HidePreview;
begin
  if FActivated and (FViewMode = hvmPreview) then
  begin
    FViewMode := hvmDefault;
    SwapDC;
    RebuildScene;
  end;
end;

procedure Register;
begin
  RegisterComponents('HS-Engine', [THSMEdit]);
end;

end.
