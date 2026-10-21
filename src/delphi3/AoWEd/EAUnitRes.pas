unit EAUnitRes;

{ Draft declarations of EAUnitRes, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWREFrm;

type
  TAbstractUnitResourceEditForm = class;


  { TAbstractUnitResourceEditForm (instance size 536, VMT 0040FCC4; $214 FUnitResource) }
  TAbstractUnitResourceEditForm = class(TAoWResourceEditForm)
  public
    published
    MainPageControl: TPageControl; { +01FC }
    GFXSFXSheet: TTabSheet; { +0200 }
    GFXGroupBox: TGroupBox; { +0204 }
    Label1: TLabel; { +0208 }
    UnitGFXBox: TComboBox; { +020C }
    PreviewImagePanel: TDrawPanel; { +0210 }
    public
    FUnitResource: TAbstractUnitResource; { $214 }
    procedure FormCreate;  { draft }
    procedure UnitGFXBoxChange;  { draft }
    procedure PreviewImagePanelDraw(A1: Integer; A2: Integer);  { draft }
  end;


implementation

procedure TAbstractUnitResourceEditForm.FormCreate;
begin end;

procedure TAbstractUnitResourceEditForm.UnitGFXBoxChange;
begin end;

procedure TAbstractUnitResourceEditForm.PreviewImagePanelDraw(A1: Integer; A2: Integer);
begin end;


end.
