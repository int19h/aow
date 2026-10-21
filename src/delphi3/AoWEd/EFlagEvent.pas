unit EFlagEvent;

{ Draft declarations of EFlagEvent, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EAoWMO, checklst;

type
  TFlagEventEditForm = class;


  { TFlagEventEditForm (instance size 544, VMT 0041F258) }
  TFlagEventEditForm = class(TAoWMapObjEditForm)
  public
    published
    PlayersGroupBox: TGroupBox; { +0210 }
    TriggerPlayersLB: TCheckListBox; { +0214 }
    Label1: TLabel; { +0218 }
    TriggerModeCB: TComboBox; { +021C }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
  end;


implementation

procedure TFlagEventEditForm.FormCreate;
begin end;

procedure TFlagEventEditForm.OKBtnClick(A1: Integer);
begin end;


end.
