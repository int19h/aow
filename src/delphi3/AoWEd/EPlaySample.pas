unit EPlaySample;

{ Draft declarations of EPlaySample, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  TPlaySampleEditForm $238 bytes; inherited $20C is the sample event. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, MoveOnEvents, AoWE, Buttons, EMoveOnEvent;

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
    published procedure FormCreate(Sender: TObject); public
    published procedure PlaySongClick(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
  end;

  { TPlaySampleEditor (instance size 8, VMT 0041F020) }
  TPlaySampleEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TPlaySampleEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TPlaySampleEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  SFXManagerBox.SFXManager := AoWEngine.HSSet.SFXManager;
  SFXManagerBox.SFXName := TPlaySampleMoveOnEvent(FMapObject).FSampleFileName;
end;

procedure TPlaySampleEditForm.PlaySongClick(Sender: TObject);
begin
  if SFXManagerBox.SFXName <> '' then PlaySample(SFXManagerBox.SFXName);
end;

procedure TPlaySampleEditForm.OKBtnClick(Sender: TObject);
begin
  TPlaySampleMoveOnEvent(FMapObject).FSampleFileName := SFXManagerBox.SFXName;
  inherited OKBtnClick(Sender);
end;


class function TPlaySampleEditor.EditorClassID: Integer;
begin Result := $2055D; end;

end.
