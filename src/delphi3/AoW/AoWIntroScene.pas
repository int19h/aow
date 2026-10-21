unit AoWIntroScene;

{ Draft declarations of AoWIntroScene, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AowUserWindow, Video;

type
  TIntroScene = class;


  { TIntroScene (instance size 92, VMT 00451F68) }
  TIntroScene = class(TDataModule)
  public
    published
    Window: TAoWUserWindow; { +0044 }
    VideoPlayer: TVideoPlayer; { +0048 }
    public
    F_IntroScene_4C: Integer;
    F_IntroScene_50: Integer;
    F_IntroScene_54: array[0..3] of Byte;
    F_IntroScene_58: Integer;
    procedure VideoPlayerStreamSound(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure WindowDrawSurfaceEx(A1: Integer; A2: Integer);  { draft }
    procedure WindowHide;  { draft }
    procedure WindowUpdate;  { draft }
    procedure WindowMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure WindowKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TIntroScene.VideoPlayerStreamSound(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TIntroScene.WindowDrawSurfaceEx(A1: Integer; A2: Integer);
begin end;

procedure TIntroScene.WindowHide;
begin end;

procedure TIntroScene.WindowUpdate;
begin end;

procedure TIntroScene.WindowMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TIntroScene.WindowKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
