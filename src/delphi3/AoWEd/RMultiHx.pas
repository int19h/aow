unit RMultiHx;

{ Draft declarations of RMultiHx, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Multi-hex editor fields: $334 last selected hexagon; $338 tool (0 select, 1 drag, 2 main point). }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Buttons, RMapObj, HSEdMod;

type
  TMultiHexResourceEditForm = class;
  TMultiHexResourceEditor = class;


  { TMultiHexResourceEditForm (instance size 828, VMT 00405DD8) }
  TMultiHexResourceEditForm = class(TMapObjectResourceEditForm)
  public
    published
    BtnPanel: TPanel; { +0324 }
    SelectBtn: TSpeedButton; { +0328 }
    DragBtn: TSpeedButton; { +032C }
    MainPBtn: TSpeedButton; { +0330 }
    public
    FSelectedHexagon: Integer; { $334 }
    FTool: Byte; { $338 }
    F_MultiHexResourceEditForm_339: array[0..2] of Byte;
    procedure SetTool(Value: Byte);
    procedure ShowHexagonText(Hexagon, dX, dY: Integer; Text: string; Color: TColor; const SD: TSurfaceDesc);
    procedure vmt88(Index, X, Y: Integer; SD: TSurfaceDesc); override;
    procedure vmt98(const SD: TSurfaceDesc); virtual; { +098 }
    function vmt9C(Hexagon: Integer): Boolean; virtual; { +09C }
    procedure DisplayUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
    procedure DisplayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DisplayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DisplayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SelectBtnClick(Sender: TObject);
    procedure DragBtnClick(Sender: TObject);
    procedure MainPBtnClick(Sender: TObject);
    procedure TerrainComboBoxChange(Sender: TObject);
    procedure ComplexBoxClick(Sender: TObject);
  end;

  { TMultiHexResourceEditor (instance size 8, VMT 00406020) }
  TMultiHexResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

procedure TMultiHexResourceEditForm.SetTool(Value: Byte);
begin
  SelectBtn.Down := Value = 0;
  DragBtn.Down := Value = 1;
  FTool := Value;
end;

procedure TMultiHexResourceEditForm.ShowHexagonText(Hexagon, dX, dY: Integer; Text: string; Color: TColor; const SD: TSurfaceDesc);
var
  X, Y: Integer;
begin
  HNtoHP(Hexagon, X, Y);
  X := (Display.Width shr 1) + X + dX;
  Y := (Display.Height shr 1) + Y + dY;
  if Length(Text) > 6 then Text := Copy(Text, 1, 6) + '.';
  with HSEditModule do
    if HSEditFont <> nil then HSEditFont.SetTextCentered(X, Y, Text, SD);
end;

class function TMultiHexResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TMultiHexResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

function TMultiHexResourceEditForm.vmt9C(Hexagon: Integer): Boolean;
var
  R: TMultiHexMOR;
begin
  R := TMultiHexMOR(FResource);
  if (R.TerrainList.Terrain[Hexagon] = -2) or
     (R.TerrainList.Terrain[Hexagon] <> TerrainComboBox.TerrainType) or
     (R.TerrainList.Overlay[Hexagon] <> OverlayComboBox.TerrainType) then
  begin
    R.TerrainList.Terrain[Hexagon] := TerrainComboBox.TerrainType;
    R.TerrainList.Overlay[Hexagon] := OverlayComboBox.TerrainType;
  end
  else
  begin
    R.TerrainList.Terrain[Hexagon] := -2;
    R.TerrainList.Overlay[Hexagon] := -2;
  end;
  Result := True;
end;

procedure TMultiHexResourceEditForm.vmt98(const SD: TSurfaceDesc);
var
  I: Integer;
  TerrainType, OverlayType: Shortint;
  Name: string;
begin
  for I := FResource.TerrainList.Count - 1 downto 0 do
    if FResource.TerrainList.Terrain[I] >= -1 then
    begin
      TerrainType := FResource.TerrainList.Terrain[I];
      if TerrainType >= 0 then
      begin
        Name := FEngine.HSSet.TerrainTypes[TerrainType];
        ShowHexagonText(I, 0, -3, Name, 1, SD);
      end;
      OverlayType := FResource.TerrainList.Overlay[I];
      if OverlayType >= 0 then
      begin
        Name := FEngine.HSSet.OverlayTypes[OverlayType];
        ShowHexagonText(I, 0, 5, Name, 1, SD);
      end;
    end;
end;

procedure TMultiHexResourceEditForm.vmt88(Index, X, Y: Integer; SD: TSurfaceDesc);
begin
  if FResource.ImageLibrary.ImageExist(Index) then
    FResource.ImageLibrary[Index].Show(X + TMultiHexMOR(FResource).dXImage,
      Y + TMultiHexMOR(FResource).dYImage, SD);
end;

procedure TMultiHexResourceEditForm.DisplayUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
var
  X, Y, I, J: Integer;
  SD: TSurfaceDesc;
begin
  if MainPageControl.ActivePage = SettingsSheet then
  begin
    Inc(FFrame);
    if FFrame > $FFFFF then FFrame := 0;
    DC.GetSurface(1).Cls(0);
    DC.GetSurface(1).Lock(SD);
    for J := 0 to FPreviewFrames.Count - 1 do
      vmt90(FPreviewFrames[J], DC.GetSurface(1).Width div 2 - 16,
        DC.GetSurface(1).Height div 2 - 16, SD);
    for I := 160 downto 0 do
    begin
      HNtoHP(I, X, Y);
      X := ((Display.Width - 48) shr 1) + X + 8;
      Inc(Y, (Display.Height - 32) shr 1);
      if DragBtn.Down and (I = 0) then
        HSEditModule.HSEditIL[1].Show(X - 8, Y, SD)
      else
        HSEditModule.HSEditIL[0].ShowClipped(X - 8, Y, SD);
    end;
    for I := 160 downto 0 do
    begin
      HNtoHP(I, X, Y);
      X := ((Display.Width - 48) shr 1) + X + 8;
      Inc(Y, (Display.Height - 32) shr 1);
      if (FResource.TerrainList.Terrain[I] <> -2) or
         (FResource.TerrainList.Overlay[I] > -1) then
        HSEditModule.HSEditIL[2].ShowClipped(X - 8, Y, SD);
    end;
    if FTool <> 2 then vmt98(SD)
    else
    begin
      X := (Display.Width shr 1) - 40;
      Y := (Display.Height shr 1) - 32;
      HSEditModule.HSEditIL[4].ShowClipped(X + TMultiHexMOR(FResource).dXmainP,
        Y + TMultiHexMOR(FResource).dYmainP, SD);
    end;
    DC.GetSurface(1).Unlock;
  end;
end;

procedure TMultiHexResourceEditForm.DisplayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  dX, dY, Hexagon: Integer;
begin
  if Button = mbLeft then
  begin
    if DragBtn.Down then
    begin
      MouseCapture := True;
      SetCaptureControl(Display);
      FUpdating := True;
      FDragX := X;
      FDragY := Y;
      Display.Cursor := crDrag;
    end;
    if SelectBtn.Down then
    begin
      dX := (Display.Width - 48) shr 1;
      dY := (Display.Height - 32) shr 1;
      dX := X - dX;
      dY := Y - dY;
      Hexagon := HPtoHN(dX, dY);
      if Hexagon <= 120 then
        if vmt9C(Hexagon) then FSelectedHexagon := Hexagon;
    end;
    if MainPBtn.Down then
    begin
      dX := (Display.Width - 48) shr 1;
      dY := (Display.Height - 32) shr 1;
      TMultiHexMOR(FResource).dXmainP := X - dX - 8;
      TMultiHexMOR(FResource).dYmainP := Y - dY;
    end;
  end;
end;

procedure TMultiHexResourceEditForm.DisplayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  dX, dY: Integer;
begin
  if FUpdating then
  begin
    dX := X - FDragX;
    dY := Y - FDragY;
    TMultiHexMOR(FResource).dXImage := TMultiHexMOR(FResource).dXImage + dX;
    TMultiHexMOR(FResource).dYImage := TMultiHexMOR(FResource).dYImage + dY;
    FDragX := X;
    FDragY := Y;
  end;
  if MainPBtn.Down and (Display.GetMouseButton = 1) then
  begin
    dX := (Display.Width - 48) shr 1;
    dY := (Display.Height - 32) shr 1;
    TMultiHexMOR(FResource).dXmainP := X - dX - 8;
    TMultiHexMOR(FResource).dYmainP := Y - dY;
  end;
end;

procedure TMultiHexResourceEditForm.DisplayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FUpdating := False;
  ReleaseCapture;
  Display.Cursor := crDefault;
end;

procedure TMultiHexResourceEditForm.SelectBtnClick(Sender: TObject);
begin
  SetTool(0);
end;

procedure TMultiHexResourceEditForm.DragBtnClick(Sender: TObject);
begin
  SetTool(1);
end;

procedure TMultiHexResourceEditForm.MainPBtnClick(Sender: TObject);
begin
  SetTool(2);
end;

procedure TMultiHexResourceEditForm.TerrainComboBoxChange(Sender: TObject);
begin end;

procedure TMultiHexResourceEditForm.ComplexBoxClick(Sender: TObject);
begin
  inherited ComplexBoxClick(Sender);
  if ComplexBox.Checked then
  begin
    if DragBtn.Down then
    begin
      DragBtn.Down := False;
      SelectBtn.Down := True;
    end;
    DragBtn.Visible := False;
  end
  else DragBtn.Visible := True;
end;


end.
