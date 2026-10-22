unit AoWArnoLine;

{ AoWArnoLine from AOWTools.dpl: recovered from the original code and RTTI.
  Class layouts and VMT order follow the shipped module. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWControl, AOWInterfaceImgLib;

type
  TAoWArnoLine = class;


  { TAoWArnoLine: instance size $124; $114 top, $118 middle, $11C bottom,
    $120 copied line image library. }
  TAoWArnoLine = class(TAOWControl)
  public
    FImageTop: TLibraryImage; { $114 }
    FImageMiddle: TLibraryImage; { $118 }
    FImageBottom: TLibraryImage; { $11C }
    FLineLibrary: TInterfaceIL; { $120 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure SetITop(Value: TLibraryImage);
    procedure SetIMiddle(Value: TLibraryImage);
    procedure SetIBottom(Value: TLibraryImage);
  published property WinHeight;
    property ImageTop: TLibraryImage read FImageTop write SetITop;
    property ImageMiddle: TLibraryImage read FImageMiddle write SetIMiddle;
    property ImageBottom: TLibraryImage read FImageBottom write SetIBottom;
  end;

procedure Register;

implementation

constructor TAoWArnoLine.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FLineLibrary := TInterfaceIL.Create(Self);
end;

destructor TAoWArnoLine.Destroy;
begin
  FLineLibrary.Free;
  inherited Destroy;
end;

procedure TAoWArnoLine.Validate;
begin
  if (FImageTop <> nil) and (FImageMiddle <> nil) and (FImageBottom <> nil) then
  begin
    FLineLibrary.Clear;
    FLineLibrary.Add(FImageTop.Copy);
    FLineLibrary.Add(FImageMiddle.Copy);
    FLineLibrary.Add(FImageBottom.Copy);
    FValid := True;
  end;
  inherited Validate;
end;

procedure TAoWArnoLine.SetITop(Value: TLibraryImage);
begin
  if Value <> FImageTop then
  begin
    FImageTop := Value;
    FValid := False;
  end;
end;

procedure TAoWArnoLine.SetIMiddle(Value: TLibraryImage);
begin
  if Value <> FImageMiddle then
  begin
    FImageMiddle := Value;
    FValid := False;
  end;
end;

procedure TAoWArnoLine.SetIBottom(Value: TLibraryImage);
begin
  if Value <> FImageBottom then
  begin
    FImageBottom := Value;
    FValid := False;
  end;
end;

procedure TAoWArnoLine.SetSize;
begin
  FWinWidth := FImageTop.Width;
  inherited SetSize;
end;

procedure TAoWArnoLine.Draw(SurfDesc: GFXE.TSurfaceDesc);
var
  OldClip: TRect;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then FOnPreDraw(Self, SurfDesc);
      OldClip := SurfDesc.ClipRect;
      if FWinTop > SurfDesc.ClipRect.Top then SurfDesc.ClipRect.Top := FWinTop;
      FLineLibrary.DrawILLv(0, Rect(FAOWWindow.FWinLeft + FWinLeft,
        FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
      if Assigned(FOnDraw) then FOnDraw(Self, SurfDesc);
      SurfDesc.ClipRect := OldClip;
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure Register;
begin
  RegisterComponents('AOW Tools', [TAoWArnoLine]);
end;


initialization
finalization

end.
