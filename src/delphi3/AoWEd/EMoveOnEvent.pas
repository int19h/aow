unit EMoveOnEvent;

{ Draft declarations of EMoveOnEvent, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EAoWMO, SpinEdit, checklst;

type
  TMoveOnEventForm = class;


  { TMoveOnEventForm (instance size 548, VMT 0041E280) }
  TMoveOnEventForm = class(TAoWMapObjEditForm)
  public
    published
    TriggerSheet: TTabSheet; { +0210 }
    PlayersGroupBox: TGroupBox; { +0214 }
    TriggerPlayersLB: TCheckListBox; { +0218 }
    RadiusEdit: TSpin; { +021C }
    Label1: TLabel; { +0220 }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
  end;


implementation

procedure TMoveOnEventForm.FormCreate;
begin end;

procedure TMoveOnEventForm.OKBtnClick(A1: Integer);
begin end;


end.
