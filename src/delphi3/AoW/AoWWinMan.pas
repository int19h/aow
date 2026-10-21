unit AoWWinMan;

{ Draft declarations of AoWWinMan, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWWindow, AOWToolTip, AOWWinManager;

type
  TGeneral = class;


  { TGeneral (instance size 204, VMT 00453FC4) }
  TGeneral = class(TDataModule)
  public
    published
    Manager: TAOWWinManager; { +0044 }
    ToolTip: TAOWToolTip; { +0048 }
    public
    F_General_4C: array[0..27] of Byte;
    F_General_68: Byte;
    F_General_69: Byte;
    F_General_6A: array[0..13] of Byte;
    F_General_78: Integer;
    F_General_7C: array[0..67] of Byte; FSelectedUnit: TAbstractUnit; { $C0; 00449DCD } F_General_C4: array[0..7] of Byte;
    procedure PlayButtonSound(Kind: Byte); { draft; 00455DFC }
    procedure SortLists(var Lists: TList; Order: Byte); { draft; 00455744 }
    procedure RegisterDialog(Window: TAOWWindow); { draft; 00456AAC }
    procedure UnregisterDialog(Window: TAOWWindow); { draft; 00456B34 }
    procedure MTtoInt(A1: Byte; A2: Integer);  { draft }
    procedure ManagerChangeCursor;  { draft }
    procedure GeneralCreate;  { draft }
    procedure GeneralDestroy;  { draft }
    procedure ResetLayout;  { draft }
    procedure ManagerDebugMessage(A1: Integer; A2: Integer);  { draft }
    procedure MapProgress(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ManagerKeyDown(A1: Integer; A2: Integer);  { draft }
    procedure ManagerUpdate;  { draft }
  end;


var
  General: TGeneral;

implementation

procedure TGeneral.PlayButtonSound(Kind: Byte);
begin end;

procedure TGeneral.SortLists(var Lists: TList; Order: Byte);
begin end;

procedure TGeneral.RegisterDialog(Window: TAOWWindow);
begin end;

procedure TGeneral.UnregisterDialog(Window: TAOWWindow);
begin end;

procedure TGeneral.MTtoInt(A1: Byte; A2: Integer);
begin end;

procedure TGeneral.ManagerChangeCursor;
begin end;

procedure TGeneral.GeneralCreate;
begin end;

procedure TGeneral.GeneralDestroy;
begin end;

procedure TGeneral.ResetLayout;
begin end;

procedure TGeneral.ManagerDebugMessage(A1: Integer; A2: Integer);
begin end;

procedure TGeneral.MapProgress(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TGeneral.ManagerKeyDown(A1: Integer; A2: Integer);
begin end;

procedure TGeneral.ManagerUpdate;
begin end;


end.
