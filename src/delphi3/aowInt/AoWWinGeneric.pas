unit AoWWinGeneric;

{ The AoWWinGeneric unit of aowInt.dpl: TAOWGenericWindow, the base window class that publishes
  the window manager's settings (the ancestor of TAOWWindow, TAOWToolTip and TAOWMenu). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl, AoWBaseWin;

type
  { AoWWinGeneric.TAOWGenericWindow (instance size 492): no fields of its own }
  TAOWGenericWindow = class(TAOWBaseWindow)
  public
    destructor Destroy; override;
    procedure SetOwner(Value: TAoWComponent); override;
    procedure SetCursor(Value: TCursor);
    procedure SetBuffer(Value: Boolean);
  published
    property WinManager: TAOWWinManager read FWinManager write SetManager;
    property UseVMem: Boolean read FUseVMem write FUseVMem;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property OverlapTopCorners: Boolean read FOverlapTopCorners write SetOverlap;
    property Cursor: TCursor read FCursor write SetCursor;
    property DoubleBuffered: Boolean read FDoubleBuffered write SetBuffer;
    property OnChangeCursor: TNotifyEvent read FOnChangeCursor write FOnChangeCursor;
    property MaskColor: TColor read FMaskColor write FMaskColor;
    property OnDrawSurface: TAoWOnDrawSurface read FOnDrawSurface write FOnDrawSurface;
    property OnPreDrawSurface: TAoWOnDrawSurface read FOnPreDrawSurface write FOnPreDrawSurface;
    property FreeSurfaceOnHide: Boolean read FFreeSurfaceOnHide write FFreeSurfaceOnHide;
  end;

implementation

{ TAOWGenericWindow }

destructor TAOWGenericWindow.Destroy;
begin
  FBuffer.Free;
  inherited Destroy;
end;

procedure TAOWGenericWindow.SetOwner(Value: TAoWComponent);
begin
  inherited SetOwner(Value);
  FWinManager := TAOWWinManager(FAOWOwner);
end;

procedure TAOWGenericWindow.SetCursor(Value: TCursor);
begin
  if Value <> FCursor then
  begin
    FCursor := Value;
    FWindowCursor := Value;
    if Assigned(FOnChangeCursor) then
      FOnChangeCursor(Self);
  end;
end;

procedure TAOWGenericWindow.SetBuffer(Value: Boolean);
begin
  if Value <> FDoubleBuffered then
  begin
    FDrawn := False;
    FDoubleBuffered := Value;
    if not FDoubleBuffered then
      if FBackSurface <> nil then
      begin
        FBackSurface.Free;
        FBackSurface := nil;
      end;
  end;
end;

end.
