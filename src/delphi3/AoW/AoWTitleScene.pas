unit AoWTitleScene;

{ Draft declarations of AoWTitleScene, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWLabel, AoWMemo, AowUserWindow;

type
  TTitleScene = class;


  { TTitleScene (instance size 180, VMT 004192F4) }
  TTitleScene = class(TDataModule)
  public
    published
    TitleSceneIL: TImageLibrary; { +0044 }
    Window: TAoWUserWindow; { +0048 }
    LegalNotice: TAOWMemo; { +004C }
    StrLbl: TAOWLabel; { +0050 }
    NameLbl: TAOWLabel; { +0054 }
    Copyright: TAOWLabel; { +0058 }
    Version: TAOWLabel; { +005C }
    public
    F_TitleScene_60: array[0..11] of Byte;
    F_TitleScene_6C: Byte;
    F_TitleScene_6D: array[0..2] of Byte;
    F_TitleScene_70: Integer;
    F_TitleScene_74: Integer;
    F_TitleScene_78: Integer;
    F_TitleScene_7C: Integer;
    F_TitleScene_80: Integer;
    F_TitleScene_84: array[0..15] of Byte;
    F_TitleScene_94: Byte;
    F_TitleScene_95: Byte;
    F_TitleScene_96: array[0..1] of Byte;
    F_TitleScene_98: Integer;
    F_TitleScene_9C: array[0..23] of Byte;
    procedure WindowDrawSurfaceEx(A1: Integer; A2: Integer);  { draft }
    procedure TitleSceneCreate;  { draft }
    procedure TitleSceneDestroy;  { draft }
    procedure WindowUpdate;  { draft }
    procedure WindowMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure WindowMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure WindowMouseUp(A1: Integer; A2: Byte);  { draft }
    procedure WindowHide;  { draft }
  end;


implementation

procedure TTitleScene.WindowDrawSurfaceEx(A1: Integer; A2: Integer);
begin end;

procedure TTitleScene.TitleSceneCreate;
begin end;

procedure TTitleScene.TitleSceneDestroy;
begin end;

procedure TTitleScene.WindowUpdate;
begin end;

procedure TTitleScene.WindowMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TTitleScene.WindowMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTitleScene.WindowMouseUp(A1: Integer; A2: Byte);
begin end;

procedure TTitleScene.WindowHide;
begin end;


end.
