unit ETCUnitPos;

{ Draft declarations of ETCUnitPos, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO;

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
    procedure FormCreate;  { draft }
    procedure DirectionChanged;  { draft }
  end;

  { TUnitPositionEditor (instance size 8, VMT 0041DC1C) }
  TUnitPositionEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TUnitPositionEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TUnitPositionEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TTCUnitPositionEditForm.FormCreate;
begin end;

procedure TTCUnitPositionEditForm.DirectionChanged;
begin end;


end.
