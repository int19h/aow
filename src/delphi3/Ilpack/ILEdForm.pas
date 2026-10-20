unit ILEdForm;

{ The ILEdForm unit of Ilpack.dpl: the image library editor of the Delphi IDE. The component
  editor TImageLibraryEditor (registered by ImageLib.Register) edits a copy of the library in
  TImageLibraryEditForm: the edit grid (ILEdGrid), the image settings (ImgSetEd), the sub
  images (SubImgEd) and their settings (SImgSEd), and a preview of the selected image. With OK
  the copy goes back into the component, or, when the library has a file, into that file. The
  form's components are plain published fields (no DFM is linked here). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, DsgnIntf, GFXE, ImageLib, ILEdGrid, ImgSetEd, SImgSEd, SubImgEd;

type
  { ILEdForm.TImageLibraryEditForm (instance size 584): +$1DC the components, +$244
    FImageLibrary (the copy edited, owned by the form). }
  TImageLibraryEditForm = class(TForm)
    Panel2: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    Panel1: TPanel;
    ToolBar1: TToolBar;
    OpenBtn: TToolButton;
    AddBtn: TToolButton;
    EnabledList: TImageList;
    ToolButton1: TToolButton;
    OpenILDialog: TOpenDialog;
    SaveBtn: TToolButton;
    ILEditGrid: TImageLibraryEditGrid;
    Panel3: TPanel;
    Bevel2: TBevel;
    Panel7: TPanel;
    Label4: TLabel;
    BltModeBox: TComboBox;
    ImageTrackerPanel: TDrawPanel;
    ImageSettingsEditor: TImageSettingsEditor;
    SaveILDialog: TSaveDialog;
    Panel4: TPanel;
    SubImageSettingsEditor: TSubImageSettingsEditor;
    SubImageEditor: TSubImageEditor;
    Splitter1: TSplitter;
    Panel5: TPanel;
    Panel16: TPanel;
    procedure ILEditGridSelectCell(Sender: TObject; Col, Row: Longint;
      var CanSelect: Boolean);
    procedure ImageTrackerPanelDraw(Sender: TObject; const R: TRect);
    procedure ToolButton1Click(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure BltModeBoxChange(Sender: TObject);
    procedure SubImageEditorSubImageSelected(Image: TLibraryImage; ImageIndex,
      SubImageIndex: Integer; Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FImageLibrary: TImageLibrary;
    procedure ImageLibraryChange(Sender: TObject);
    procedure SetImageLibrary(Value: TCustomImageLibrary);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ImageLibrary: TCustomImageLibrary write SetImageLibrary;
  end;

  { ILEdForm.TImageLibraryEditor (instance size 12): the component editor of the image
    libraries. }
  TImageLibraryEditor = class(TComponentEditor)
  public
    procedure Edit; override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

implementation

type
  { Access to the protected Canvas of GFXE.TDrawPanel (the original reads its FCanvas; the
    GFXE source may have declared Canvas public there) }
  TDrawPanelAccess = class(TDrawPanel);

{ TImageLibraryEditor }

procedure TImageLibraryEditor.Edit;
var
  Form: TImageLibraryEditForm;
begin
  Form := TImageLibraryEditForm.Create(Application);
  try
    Form.ImageLibrary := TCustomImageLibrary(Component);
    Form.FImageLibrary.Modified := False;
    if Form.ShowModal = mrOk then
      if TCustomImageLibrary(Component).FileName <> '' then
      begin
        if Form.FImageLibrary.Modified then
          if MessageDlg('Save changes to ' + TCustomImageLibrary(Component).FullFileName + '?',
            mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
          begin
            Form.FImageLibrary.SaveToFile(TCustomImageLibrary(Component).FullFileName);
            TCustomImageLibrary(Component).LoadFromFile(TCustomImageLibrary(Component).FullFileName);
          end;
      end
      else
      begin
        Designer.Modified;
        TCustomImageLibrary(Component).Assign(Form.FImageLibrary);
      end;
  finally
    Form.Free;
  end;
end;

procedure TImageLibraryEditor.ExecuteVerb(Index: Integer);
begin
  Edit;
end;

function TImageLibraryEditor.GetVerb(Index: Integer): string;
begin
  Result := '&ImageLibrary Editor..';
end;

function TImageLibraryEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TImageLibraryEditForm }

constructor TImageLibraryEditForm.Create(AOwner: TComponent);
begin
  FImageLibrary := TImageLibrary.Create(Self);
  inherited Create(AOwner);
  ILEditGrid.ImageLibrary := FImageLibrary;
  ImageSettingsEditor.ImageLibrary := FImageLibrary;
  SubImageEditor.ImageLibrary := FImageLibrary;
  SubImageSettingsEditor.ImageLibrary := FImageLibrary;
  FImageLibrary.OnChange := ImageLibraryChange;
  BltModeBox.ItemIndex := 1;
end;

destructor TImageLibraryEditForm.Destroy;
begin
  FImageLibrary.Free;
  inherited Destroy;
end;

procedure TImageLibraryEditForm.ImageLibraryChange(Sender: TObject);
begin
  ILEditGrid.UpdateSettings;
  ImageSettingsEditor.ImageIndex := ILEditGrid.ImageIndex;
  SubImageEditor.ImageIndex := ILEditGrid.ImageIndex;
  SubImageSettingsEditor.ImageIndex := ILEditGrid.ImageIndex;
  ImageTrackerPanel.Repaint;
end;

procedure TImageLibraryEditForm.SetImageLibrary(Value: TCustomImageLibrary);
var
  CanSelect: Boolean;
begin
  FImageLibrary.Assign(Value);
  ILEditGrid.UpdateSettings;
  ILEditGridSelectCell(Self, 0, ILEditGrid.Row, CanSelect);
end;

procedure TImageLibraryEditForm.ILEditGridSelectCell(Sender: TObject; Col, Row: Longint;
  var CanSelect: Boolean);
begin
  ImageSettingsEditor.ImageIndex := Row - 1;
  SubImageEditor.ImageIndex := Row - 1;
  ImageTrackerPanel.Repaint;
end;

procedure TImageLibraryEditForm.ImageTrackerPanelDraw(Sender: TObject; const R: TRect);
var
  Image: TLibraryImage;
  DrawRect: TRect;
begin
  Image := FImageLibrary.GetSafe(ImageSettingsEditor.ImageIndex);
  if Image <> nil then
    BltLibraryImage(TDrawPanelAccess(ImageTrackerPanel).Canvas, Image, R, TBltMode(BltModeBox.ItemIndex + 2),
      100, 100, clBlack, clBtnFace, True, DrawRect)
  else
    BltLibraryImage(TDrawPanelAccess(ImageTrackerPanel).Canvas, Image, R, TBltMode(BltModeBox.ItemIndex + 2),
      100, 100, ImageTrackerPanel.Color, ImageTrackerPanel.Color, False, DrawRect);
end;

procedure TImageLibraryEditForm.ToolButton1Click(Sender: TObject);
begin
  if FImageLibrary.Count <> 0 then
    if MessageDlg('Remove all images?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
    begin
      FImageLibrary.Clear;
      ILEditGrid.UpdateSettings;
    end;
end;

procedure TImageLibraryEditForm.OpenBtnClick(Sender: TObject);
begin
  if OpenILDialog.Execute then
    FImageLibrary.LoadFromFile(OpenILDialog.FileName);
end;

procedure TImageLibraryEditForm.SaveBtnClick(Sender: TObject);
begin
  if SaveILDialog.Execute then
    FImageLibrary.SaveToFile(SaveILDialog.FileName);
end;

procedure TImageLibraryEditForm.AddBtnClick(Sender: TObject);
var
  IL: TCustomImageLibrary;
  I: Integer;
begin
  if OpenILDialog.Execute then
  begin
    IL := TImageLibrary.Create(nil);
    try
      IL.LoadFromFile(OpenILDialog.FileName);
      FImageLibrary.DisableOnChangeEvent;
      for I := 0 to IL.Count - 1 do
        FImageLibrary.Add(IL.GetImage(I));
      FImageLibrary.EnableOnChangeEvent;
    finally
      IL.Free;
    end;
  end;
end;

procedure TImageLibraryEditForm.BltModeBoxChange(Sender: TObject);
begin
  ImageTrackerPanel.Repaint;
end;

procedure TImageLibraryEditForm.SubImageEditorSubImageSelected(Image: TLibraryImage;
  ImageIndex, SubImageIndex: Integer; Sender: TObject);
begin
  SubImageSettingsEditor.SelectImage(ImageIndex, SubImageIndex);
end;

{ Drops the mouse messages that are still queued from the double click that opened the
  editor. }
procedure TImageLibraryEditForm.FormActivate(Sender: TObject);
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, Handle, WM_MOUSEFIRST, WM_MOUSELAST, PM_REMOVE) do ;
end;

end.
