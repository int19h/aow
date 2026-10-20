unit AoWWinControl;

{ The AoWWinControl unit of aowInt.dpl: TAOWWindowControl, the common ancestor of the window
  manager's windows (TAOWBaseWindow and its descendants). It holds the fields of every kind of
  window (dragging, resizing, the frame and texture libraries, the back surface the window is
  drawn into) and blits the back surface to the screen. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWComp, AOWInterfaceImgLib;

type
  TWindowType = (winNormal, winHollow, winBorderless, winBlank);

  TAOWWindowControl = class;

  TAoWOnDrawSurface = procedure(Sender: TAOWWindowControl; Surface: TSurface;
    Left, Top: Integer) of object;

  { AoWWinControl.TAOWWindowControl (instance size 464). Fields: +$104 FModal, +$108
    FOnDrawSurface, +$110 FOnPreDrawSurface, +$118 FDragging, +$11C FDragX, +$120 FDragY, +$124
    FDraggable, +$128 FResizable, +$12C FResizingX, +$12D FResizingY, +$130 FOnResize, +$138
    FOnInternalResize, +$140 FDragHeight, +$144 FOverlapTopCorners, +$146 FOldCursor, +$148
    FWindowCursor, +$14C FOnChangeCursor, +$154 FMinWidth, +$158 FMinHeight, +$15C FMaxWidth, +$160
    FMaxHeight, +$164 FInResizeArea, +$165 FWindowType, +$168 FILFrame, +$16C FILTexture, +$170
    FUseManagerBorders, +$174 FFrameLeft, +$178 FFrameTop, +$17C FFrameRight, +$180 FFrameBottom,
    +$184 FMaskColor, +$188 FUseVMem, +$18C FBackSurface, +$190 (unused), +$194 FBackRect, +$1A4
    (unused), +$1A8 FOnDrawBack, +$1B0 FOnEnter, +$1B8 FOnExit, +$1C0 FMouseInside, +$1C4
    FILIndexFrame, +$1C8 FILIndexTexture, +$1CC FDockable.
    VMT (new): DetachMenuBar, Blt }
  TAOWWindowControl = class(TAoWComponent)
  public
    FModal: Boolean;
    FOnDrawSurface: TAoWOnDrawSurface;
    FOnPreDrawSurface: TAoWOnDrawSurface;
    FDragging: Byte;
    FDragX: Integer;
    FDragY: Integer;
    FDraggable: LongBool;
    FResizable: LongBool;
    FResizingX: Byte;
    FResizingY: Byte;
    FOnResize: TNotifyEvent;
    FOnInternalResize: TNotifyEvent;
    FDragHeight: Integer;
    FOverlapTopCorners: Boolean;
    FOldCursor: TCursor;
    FWindowCursor: TCursor;
    FOnChangeCursor: TNotifyEvent;
    FMinWidth: Integer;
    FMinHeight: Integer;
    FMaxWidth: Integer;
    FMaxHeight: Integer;
    FInResizeArea: Boolean;
    FWindowType: TWindowType;
    FILFrame: TInterfaceIL;
    FILTexture: TInterfaceIL;
    FUseManagerBorders: Boolean;
    FFrameLeft: Integer;
    FFrameTop: Integer;
    FFrameRight: Integer;
    FFrameBottom: Integer;
    FMaskColor: TColor;
    FUseVMem: Boolean;
    FBackSurface: TSurface;
    F190: Integer;
    FBackRect: TRect;
    F1A4: Integer;
    FOnDrawBack: TAoWOnDrawBackEvent;
    FOnEnter: TNotifyEvent;
    FOnExit: TNotifyEvent;
    FMouseInside: Boolean;
    FILIndexFrame: Integer;
    FILIndexTexture: Integer;
    FDockable: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Validate; override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure CheckKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DetachMenuBar; virtual;
    procedure Blt(Surface: TSurface); virtual;
    procedure SetOverlap(Value: Boolean);
    procedure RadioChange(Sender: TAoWComponent);
    function VerifyBackSurface(Surface: TSurface): Boolean;
  published
    property Priority;
    property WinLeft;
    property WinTop;
    property WinWidth;
    property OnDrawBack: TAoWOnDrawBackEvent read FOnDrawBack write FOnDrawBack;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property Masked;
  end;

implementation

{ TAOWWindowControl }

constructor TAOWWindowControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOldCursor := -2;
  FWindowCursor := -2;
end;

destructor TAOWWindowControl.Destroy;
begin
  FBackSurface.Free;
  inherited Destroy;
end;

procedure TAOWWindowControl.DetachMenuBar;
begin
end;

procedure TAOWWindowControl.Validate;
begin
  if FAOWOwner <> nil then
  begin
    if FILFrame <> nil then
      FILFrame := FILFrame.CheckIL(FILIndexFrame, 8, Self);
    if FILTexture <> nil then
      FILTexture := FILTexture.CheckIL(FILIndexTexture, 1, Self);
    if FILFrame <> nil then
      if FILTexture <> nil then
        FWindowType := winNormal
      else
        FWindowType := winHollow
    else if FILTexture <> nil then
      FWindowType := winBorderless
    else
      FWindowType := winBlank;
    FValid := True;
  end;
  inherited Validate;
end;

procedure TAOWWindowControl.SetOverlap(Value: Boolean);
begin
  FOverlapTopCorners := Value;
  FDrawn := False;
end;

{ RadioChange unchecks the other children of the radio group of Sender }
procedure TAOWWindowControl.RadioChange(Sender: TAoWComponent);
var
  I: Integer;
  C: TAoWComponent;
begin
  for I := 0 to FChildren.Count - 1 do
  begin
    C := FChildren[I];
    if (Sender.FRadioIndex = C.FRadioIndex) and (C <> Sender) and (C.FChecked = True) then
    begin
      C.FChecked := False;
      C.FDrawn := False;
      if Assigned(C.FOnChange) then
        C.FOnChange(C);
    end;
  end;
end;

{ VerifyBackSurface makes the back surface match Surface (a DirectDraw surface in video memory
  when Surface is one and UseVMem is set, else a surface in system memory or a data surface);
  True when the back surface was created or restored and has to be drawn again }
function TAOWWindowControl.VerifyBackSurface(Surface: TSurface): Boolean;
var
  Flags: TDDSCreationFlags;
  DDS: TDDrawSurface;
begin
  Result := False;
  if FDoubleBuffered then
  begin
    if FBackSurface <> nil then
      if (FBackSurface.GetPixelFormatID <> Surface.GetPixelFormatID) or
        ((FBackSurface is TDDrawSurface) xor (Surface is TDDrawSurface)) then
      begin
        FBackSurface.Free;
        FBackSurface := nil;
      end;
    if FBackSurface = nil then
    begin
      if Surface is TDDrawSurface then
      begin
        if (ssVideoMemory in TDDrawSurface(Surface).Status) and FUseVMem then
          Flags := [cfVideoMemory, cfSystemMemory]
        else
          Flags := [cfSystemMemory];
        DDS := TDDrawSurface.Create;
        FBackSurface := DDS;
        DDS.CreateSurface(FWinWidth, FWinHeight, Surface.GetPixelFormatID, Flags);
      end
      else
        FBackSurface := TDataSurface.Create(FWinWidth, FWinHeight, Surface.GetPixelFormatID, nil);
      if FMasked then
        FBackSurface.Cls(FMaskColor);
      Result := True;
    end
    else if (FBackSurface is TDDrawSurface) and TDDrawSurface(FBackSurface).Lost then
      Result := TDDrawSurface(FBackSurface).Restore = DD_OK;
  end;
end;

procedure TAOWWindowControl.Blt(Surface: TSurface);
var
  R: TRect;
begin
  if Assigned(FOnPreDrawSurface) then
    FOnPreDrawSurface(Self, Surface, FWinLeft, FWinTop);
  R := Rect(0, 0, FWinWidth, FWinHeight);
  if not FMasked then
    FBackSurface.BltClipped(Surface, @R, FWinLeft, FWinTop)
  else
    FBackSurface.BltColorKeyClipped(Surface, @R, FWinLeft, FWinTop,
      Color2PixelInfo(FMaskColor, FBackSurface.GetPixelFormatID, nil));
  if Assigned(FOnDrawSurface) then
    FOnDrawSurface(Self, Surface, FWinLeft, FWinTop);
end;

procedure TAOWWindowControl.CheckKeyPress(var Key: Char);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  if FVisible then
  begin
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      C.CheckKeyPress(Key);
      if C.FHandled = True then
        FHandled := True;
    end;
    if (FHandled or FModal) and Assigned(FOnKeyPress) then
      FOnKeyPress(Self, Key);
    if FModal then
      FHandled := True;
  end;
end;

procedure TAOWWindowControl.CheckKeyDown(var Key: Word; Shift: TShiftState);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  if FVisible then
  begin
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      C.CheckKeyDown(Key, Shift);
      if C.FHandled = True then
        FHandled := True;
    end;
    if Assigned(FOnKeyDown) then
      FOnKeyDown(Self, Key, Shift);
    if FModal then
      FHandled := True;
  end;
end;

end.
