unit RCILTer;

{ Draft declarations of RCILTer, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TCombatILTerrainResourceEditForm $360 bytes; inherited $308 resource. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatILTer, CityWall, RILTer, SpinEdit;

type
  TCombatILTerrainResourceEditForm = class;
  TCombatILTerrainResourceEditor = class;


  { TCombatILTerrainResourceEditForm (instance size 864, VMT 0040B534) }
  TCombatILTerrainResourceEditForm = class(TILTerrainResourceEditForm)
  public
    published
    CombatSettings: TTabSheet; { +033C }
    CPanel: TPanel; { +0340 }
    DefenseValue: TLabel; { +0344 }
    BurnValue: TLabel; { +0348 }
    DefenseValueEdit: TSpin; { +034C }
    BurnValueEdit: TSpin; { +0350 }
    CityWallPanel: TPanel; { +0354 }
    Label10: TLabel; { +0358 }
    CityWallDirectionEdit: TSpin; { +035C }
    public
    procedure FormCreate(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure CityWallDirectionEditUpdate(Sender: TObject);
  end;

  { TCombatILTerrainResourceEditor (instance size 8, VMT 0040B780) }
  TCombatILTerrainResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TCombatILTerrainResourceEditor.EditorClassID: Integer;
begin
  Result := $220137;
end;

class procedure TCombatILTerrainResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TCombatILTerrainResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

procedure TCombatILTerrainResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  DefenseValueEdit.Value := TCombatILTerrainResource(FResource).FDefense;
  BurnValueEdit.Value := TCombatILTerrainResource(FResource).FBurnValue;
  CityWallPanel.Visible := FResource is TCityWallResource;
  if CityWallPanel.Visible then
    CityWallDirectionEdit.Value := TCityWallResource(FResource).FDirection;
end;

procedure TCombatILTerrainResourceEditForm.CloseBtnClick(Sender: TObject);
begin
  TCombatILTerrainResource(FResource).FDefense := DefenseValueEdit.Value;
  TCombatILTerrainResource(FResource).FBurnValue := BurnValueEdit.Value;
  inherited CloseBtnClick(Sender);
end;

procedure TCombatILTerrainResourceEditForm.CityWallDirectionEditUpdate(Sender: TObject);
begin
  { Original truncates the direction to a byte before its redundant range check. }
  TCityWallResource(FResource).FDirection := Integer(Byte(CityWallDirectionEdit.Value));
end;


end.
