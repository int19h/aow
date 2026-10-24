unit ETCUnitPos;

{ Draft declarations of ETCUnitPos, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Direction uses inherited $1FC FEditObject and $20C FMapObject. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, AoWTC;

type
  TTCUnitPositionEditForm = class;
  TUnitPositionEditor = class;


  { TTCUnitPositionEditForm (instance size 556, VMT 0041DA70) }
  TTCUnitPositionEditForm = class(TAoWMapObjEditForm)
  public
    published
    GroupBox2: TGroupBox; { +0210 }
    Dir1: TRadioButton; { +0214 }
    Dir6: TRadioButton; { +0218 }
    Dir2: TRadioButton; { +021C }
    Dir5: TRadioButton; { +0220 }
    Dir3: TRadioButton; { +0224 }
    Dir4: TRadioButton; { +0228 }
    public
    published procedure FormCreate; public
    published procedure DirectionChanged; public
  end;

  { TUnitPositionEditor (instance size 8, VMT 0041DC1C) }
  TUnitPositionEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TUnitPositionEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TTCUnitPositionEditForm.vmt90(Obj, Done);
end;

class procedure TUnitPositionEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TTCUnitPositionEditForm.FormCreate;
begin
  case TUnitPositionHS(FEditObject).FDirection of
    1: Dir1.Checked := True;
    2: Dir2.Checked := True;
    3: Dir3.Checked := True;
    4: Dir4.Checked := True;
    5: Dir5.Checked := True;
    6: Dir6.Checked := True;
  end;
end;

procedure TTCUnitPositionEditForm.DirectionChanged;
var Direction: Integer;
begin
  if Dir1.Checked then Direction := 1
  else if Dir2.Checked then Direction := 2
  else if Dir3.Checked then Direction := 3
  else if Dir4.Checked then Direction := 4
  else if Dir5.Checked then Direction := 5
  else if Dir6.Checked then Direction := 6
  else Direction := 2;
  TUnitPositionHS(FMapObject).FDirection := Direction;
end;

class function TUnitPositionEditor.EditorClassID: Integer;
begin Result := $220103; end;

end.
