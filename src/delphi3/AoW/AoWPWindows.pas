unit AoWPWindows;

{ Draft declarations of AoWPWindows, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenu, StartMenu;

type
  TPopupWindows = class;


  { TPopupWindows (instance size 120, VMT 00427450) }
  TPopupWindows = class(TDataModule)
  public
    published
    StartMenu: TStartMenu; { +0044 }
    OverViewsMenu: TAOWMenu; { +0048 }
    SettingsMenu: TAOWMenu; { +004C }
    EndMenu: TAOWMenu; { +0050 }
    DiskMenu: TAOWMenu; { +0054 }
    TCStartMenu: TStartMenu; { +0058 }
    Translator: TIvTranslator; { +005C }
    HelpMenu: TAOWMenu; { +0060 }
    TCOVMenu: TAOWMenu; { +0064 }
    TCDiskMenu: TAOWMenu; { +0068 }
    TCHelpMenu: TAOWMenu; { +006C }
    TCSettingsMenu: TAOWMenu; { +0070 }
    TCEndMenu: TAOWMenu; { +0074 }
    public
    procedure SettingsMenuSelect(A1: Integer; A2: Byte);  { draft }
    procedure EndMenuSelect(A1: Integer);  { draft }
    procedure DiskMenuSelect(A1: Integer);  { draft }
    procedure OverViewsMenuSelect(A1: Integer);  { draft }
    procedure TCEndMenuSelect(A1: Integer);  { draft }
    procedure HelpMenuSelect(A1: Integer);  { draft }
  end;


implementation

procedure TPopupWindows.SettingsMenuSelect(A1: Integer; A2: Byte);
begin end;

procedure TPopupWindows.EndMenuSelect(A1: Integer);
begin end;

procedure TPopupWindows.DiskMenuSelect(A1: Integer);
begin end;

procedure TPopupWindows.OverViewsMenuSelect(A1: Integer);
begin end;

procedure TPopupWindows.TCEndMenuSelect(A1: Integer);
begin end;

procedure TPopupWindows.HelpMenuSelect(A1: Integer);
begin end;


end.
