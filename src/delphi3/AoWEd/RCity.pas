unit RCity;

{ Draft declarations of RCity, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  No added fields; resource and preview state are inherited. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RPlayerStructure;

type
  TCityResourceEditForm = class;
  TCityResourceEditor = class;


  { TCityResourceEditForm (instance size 888, VMT 00409A9C) }
  TCityResourceEditForm = class(TPlayerStructureResourceEditForm)
  public
    procedure vmt90(Index, X, Y: Integer; SD: TSurfaceDesc); override;
    constructor CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent); override;
    published procedure ComplexBoxClick(Sender: TObject); public
  end;

  { TCityResourceEditor (instance size 8, VMT 00409BDC) }
  TCityResourceEditor = class(TEObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TCityResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin TCityResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done); end;

constructor TCityResourceEditForm.CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent);
begin
  inherited CreateForm(AEngine, Resource, Done);
  ComplexBox.Checked := True;
  vmt84;
end;

procedure TCityResourceEditForm.vmt90(Index, X, Y: Integer; SD: TSurfaceDesc);
begin
  if MainPageControl.ActivePage = SettingsSheet then vmt88(Index, X, Y, SD)
  else inherited vmt90(Index, X, Y, SD);
end;

procedure TCityResourceEditForm.ComplexBoxClick(Sender: TObject);
begin end;


class function TCityResourceEditor.EditorClassID: Integer;
begin Result := $20109; end;

end.
