unit AoWInfoBanner;

{ Draft declarations of AoWInfoBanner, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenu, AoWLabel, AoWMemo, AoWVScroll;

type
  TInfoBanner = class;


  { TInfoBanner (instance size 84, VMT 00406F44) }
  TInfoBanner = class(TDataModule)
  public
    published
    HeaderLbl: TAOWLabel; { +0044 }
    InfoMemo: TAOWMemo; { +0048 }
    BannerPopup: TAOWMenu; { +004C }
    InfoMemoSB: TAOWVScrollBar; { +0050 }
    public
    procedure BannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;


implementation

procedure TInfoBanner.BannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;


end.
