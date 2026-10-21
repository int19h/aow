unit EChangeSong;

{ Draft declarations of EChangeSong, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Buttons, EMoveOnEvent;

type
  TChangeSongEditForm = class;
  TChangeSongEditor = class;


  { TChangeSongEditForm (instance size 572, VMT 0041E698) }
  TChangeSongEditForm = class(TMoveOnEventForm)
  public
    published
    Song: TTabSheet; { +0224 }
    GroupBox1: TGroupBox; { +0228 }
    SongCB: TComboBox; { +022C }
    SongNameLabel: TLabel; { +0230 }
    PlaySong: TSpeedButton; { +0234 }
    public
    F_ChangeSongEditForm_238: Integer;
    procedure FormCreate;  { draft }
    procedure FormDestroy;  { draft }
    procedure SongCBChange;  { draft }
    procedure PlaySongClick;  { draft }
  end;

  { TChangeSongEditor (instance size 8, VMT 0041E868) }
  TChangeSongEditor = class(TAoWMapObjectEditor)
  public
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TChangeSongEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin end;

procedure TChangeSongEditForm.FormCreate;
begin end;

procedure TChangeSongEditForm.FormDestroy;
begin end;

procedure TChangeSongEditForm.SongCBChange;
begin end;

procedure TChangeSongEditForm.PlaySongClick;
begin end;


end.
