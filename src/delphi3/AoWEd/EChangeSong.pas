unit EChangeSong;

{ Draft declarations of EChangeSong, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  $238 song list; the song filename is in inherited $20C FMapObject. }

{$R+,Q+}

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
    FSongList: TSongList; { $238 }
    published procedure FormCreate(Sender: TObject); public
    published procedure FormDestroy(Sender: TObject); public
    published procedure SongCBChange(Sender: TObject); public
    published procedure PlaySongClick(Sender: TObject); public
  end;

  { TChangeSongEditor (instance size 8, VMT 0041E868) }
  TChangeSongEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

uses MoveOnEvents;

class procedure TChangeSongEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin Handled := Handled + [emEdit]; end;

procedure TChangeSongEditForm.FormCreate(Sender: TObject);
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling; still differs. }
  inherited FormCreate(Sender);
  FSongList := TSongList.Create(nil);
  FSongList.Search('SONGS\', 'S3M');
  FSongList.Search('SONGS\', 'IT');
  SongCB.Items.Assign(FSongList.SongNames);
  SongCB.ItemIndex := FSongList.Songs.IndexOf(TChangeSongMoveOnEvent(FMapObject).FSongFileName);
end;

procedure TChangeSongEditForm.FormDestroy(Sender: TObject);
begin
  FSongList.Free;
  StopSong;
end;

procedure TChangeSongEditForm.SongCBChange(Sender: TObject);
begin
  TChangeSongMoveOnEvent(FMapObject).FSongFileName := FSongList.Songs[SongCB.ItemIndex];
end;

procedure TChangeSongEditForm.PlaySongClick(Sender: TObject);
begin
  Sound.PlaySong(TChangeSongMoveOnEvent(FMapObject).FSongFileName);
end;

class function TChangeSongEditor.EditorClassID: Integer;
begin Result := $2054B; end;

end.
