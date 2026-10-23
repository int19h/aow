unit FaceSel;

{ FaceSel editor routines recovered from AoWEd.exe. Remaining stubs are marked draft. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWDlg, AoWE;

type
  TFaceSelectionDlg = class;


  { TFaceSelectionDlg: size $20C; $204 filtered face indices, $208 selected face. VMT 00411AA4. }
  TFaceSelectionDlg = class(TAoWDialog)
  public
    published
    Panel1: TPanel; { +01E0 }
    CancelBtn: TButton; { +01E4 }
    OKBtn: TButton; { +01E8 }
    ClientPnl: TPanel; { +01EC }
    MainPageControl: TPageControl; { +01F0 }
    GeneralSheet: TTabSheet; { +01F4 }
    FacesGrid: TImageDrawGrid; { +01F8 }
    Label1: TLabel; { +01FC }
    Translator: TIvTranslator; { +0200 }
    public
    FFaceIndexes: TIntegerList; { $204 }
    FSelectedIndex: Integer; { $208 }
    procedure SetFaceIndex(Index: Integer);
    published procedure FacesGridCellUpdated(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState); public
    published procedure FormCreate; public
    published procedure FormDeactivate; public
    published procedure OKBtnClick; public
  end;


implementation

procedure TFaceSelectionDlg.SetFaceIndex(Index: Integer);
var InputIndex, Found: Integer; begin InputIndex := Index;
  FSelectedIndex := InputIndex;
  Found := FFaceIndexes.IndexOf(InputIndex);
  if Found <> -1 then
    with FacesGrid do
    begin
      Col := Found mod ColCount;
      Row := Found div ColCount;
    end;
end;


procedure TFaceSelectionDlg.FacesGridCellUpdated(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
var Index: Integer; DrawRect: TRect;
begin
  Index := FacesGrid.ImageIndex(ACol, ARow);
  with FacesGrid do
    if Index < FFaceIndexes.Count then
      BltLibraryImage(Canvas, AoWHSSet.FFaceResources.GetFaceResource(FFaceIndexes[Index]).GetCellImage,
        R, bmStretch, 50, 50, 0, Color, False, DrawRect)
    else begin Canvas.Brush.Color := clBtnFace; Canvas.FillRect(R); end;
end;


procedure TFaceSelectionDlg.FormCreate;
var I: Integer;
begin
  FFaceIndexes := TIntegerList.Create;
  FFaceIndexes.Default := -1;
  with AoWHSSet.FFaceResources do
    for I := 0 to GetCount - 1 do
      if (GetFaceResource(I) <> nil) and
        (not GetFaceResource(I).FDeveloperOnly or AoWEngine.FRegistry.GetDeveloper) then
        FFaceIndexes.Add(I);
  FacesGrid.Count := FFaceIndexes.Count;
end;


procedure TFaceSelectionDlg.FormDeactivate;
begin
  FFaceIndexes.Free;
end;


procedure TFaceSelectionDlg.OKBtnClick;
begin
  with FacesGrid do FSelectedIndex := FFaceIndexes[ImageIndex(Col, Row)];
end;



end.
