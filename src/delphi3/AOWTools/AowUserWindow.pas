unit AowUserWindow;

{ AowUserWindow from AOWTools.dpl: recovered from the original code and RTTI.
  Class layouts and VMT order follow the shipped module. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWWindow;

type
  TAoWUserWindow = class;

  TDrawSurfaceExEvent = procedure(Surface: TSurface; var Handled: Boolean) of object;

  { TAoWUserWindow: instance size $1F4; $1EC extended drawing event. }
  TAoWUserWindow = class(TAOWWindow)
  public
    FOnDrawSurfaceEx: TDrawSurfaceExEvent; { $1EC }
    procedure DrawSurface(Surface: GFXE.TSurface); override;
  published
    property OnDrawSurfaceEx: TDrawSurfaceExEvent read FOnDrawSurfaceEx write FOnDrawSurfaceEx;
  end;

procedure Register;

implementation

procedure TAoWUserWindow.DrawSurface(Surface: GFXE.TSurface);
var
  Handled: Boolean;
begin
  Handled := False;
  if Assigned(FOnDrawSurfaceEx) then FOnDrawSurfaceEx(Surface, Handled);
  if not Handled then inherited DrawSurface(Surface);
end;

procedure Register;
begin
  RegisterComponents('AOW Tools', [TAoWUserWindow]);
end;


initialization
finalization

end.
