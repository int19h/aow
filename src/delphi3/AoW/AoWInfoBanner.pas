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
    procedure ShowInfo(const Header: string; Description: TStrings); { 0040701C }
    procedure BannerPopupMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;


var
  InfoBanner: TInfoBanner;

implementation

procedure TInfoBanner.ShowInfo(const Header: string; Description: TStrings);
begin
  HeaderLbl.Text := Header;
  InfoMemo.Items.Text := Description.Text;
end;

procedure TInfoBanner.BannerPopupMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then BannerPopup.Visible := False;
end;


end.
