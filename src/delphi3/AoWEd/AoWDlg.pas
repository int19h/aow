unit AoWDlg;

{ Editor dialog positioning recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWDialog = class;


  { TAoWDialog (instance size 480, VMT 0040D824; $1DC FPositionInfo) }
  TAoWDialog = class(TForm)
  public
    FPositionInfo: PPoint; { $1DC }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure FormShow(Sender: TObject);
  end;


implementation

var SavedPosition: TPoint;

constructor TAoWDialog.Create(AOwner: Classes.TComponent);
begin
  FPositionInfo := @SavedPosition;
  inherited Create(AOwner);
end;

destructor TAoWDialog.Destroy;
begin
  if FPositionInfo <> nil then
  begin
    FPositionInfo.X := Left;
    FPositionInfo.Y := Top;
  end;
  inherited Destroy;
end;

procedure TAoWDialog.FormShow(Sender: TObject);
begin
  if (FPositionInfo <> nil) and (FPositionInfo.X <> 0) and (FPositionInfo.Y <> 0) then
  begin
    Left := FPositionInfo.X;
    Top := FPositionInfo.Y;
    Exit;
  end;
  Left := (Screen.Width - Width) shr 1;
  Top := (Screen.Height - Height) shr 1;
end;


end.
