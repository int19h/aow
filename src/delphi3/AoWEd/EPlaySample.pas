unit EPlaySample;

{ Draft declarations of EPlaySample, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Buttons, EMoveOnEvent;

type
  TPlaySampleEditForm = class;
  TPlaySampleEditor = class;


  { TPlaySampleEditForm (instance size 568, VMT 0041EE50) }
  TPlaySampleEditForm = class(TMoveOnEventForm)
  public
    published
    SampleSheet: TTabSheet; { +0224 }
    SampleGroupBox: TGroupBox; { +0228 }
    SongNameLabel: TLabel; { +022C }
    PlaySong: TSpeedButton; { +0230 }
    SFXManagerBox: TSFXManagerComboBox; { +0234 }
    public
    procedure FormCreate;  { draft }
    procedure PlaySongClick;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
  end;

  { TPlaySampleEditor (instance size 8, VMT 0041F020) }
  TPlaySampleEditor = class(TAoWMapObjectEditor)
  public
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TPlaySampleEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TPlaySampleEditForm.FormCreate;
begin end;

procedure TPlaySampleEditForm.PlaySongClick;
begin end;

procedure TPlaySampleEditForm.OKBtnClick(A1: Integer);
begin end;


end.
