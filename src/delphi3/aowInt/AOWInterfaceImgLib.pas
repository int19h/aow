unit AOWInterfaceImgLib;

{ The AOWInterfaceImgLib unit of aowInt.dpl: TInterfaceIL, the image library that holds the
  pieces the controls are drawn from (frames, textures, lines, icons). Its Draw* methods draw a
  frame, a texture tile, a single image or a horizontal or vertical line of images into a
  rectangle given as (Left, Top, Width, Height) in a TRect, clipped to the surface's clip rectangle,
  which they narrow while drawing and restore. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib;

type
  { AOWInterfaceImgLib.TInterfaceIL (instance size 80): no fields or virtual methods of its own }
  TInterfaceIL = class(TImageLibrary)
  public
    function CheckIL(Index, Count: Integer; Sender: TComponent): TInterfaceIL;
    procedure DrawILF(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
    procedure DrawILT(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
    procedure DrawILI(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
    procedure DrawILLh(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
    procedure DrawILLv(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
  end;

procedure Register;

implementation

{ TInterfaceIL }

{ CheckIL returns Self when the library holds the Count images from Index on, else nil after a
  message box that names the library and the component (Sender) that needs them }
function TInterfaceIL.CheckIL(Index, Count: Integer; Sender: TComponent): TInterfaceIL;
var
  I: Integer;
begin
  Result := Self;
  if Index + Count > Self.Count then
  begin
    Result := nil;
    MessageBox(0, Pointer(Name + ' must have ' + IntToStr(Index + Count) + ' Images'),
      Pointer('Error - ' + Sender.Name), 0);
  end
  else
    for I := Index to Index + Count - 1 do
      if not ImageExist(I) then
      begin
        MessageBox(0, Pointer(Name + ' Image # ' + IntToStr(I) + ' is invalid'),
          Pointer('Error - ' + Sender.Name), 0);
        Result := nil;
      end;
end;

{ DrawILF draws a frame of 8 images: Index the top left corner, +1 the top edge, +2 the top right
  corner, +3 the left edge, +4 the right edge, +5 the bottom left corner, +6 the bottom edge, +7
  the bottom right corner }
procedure TInterfaceIL.DrawILF(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
var
  I: Integer;
  ClipRight, ClipBottom: Integer;
  OldClip: TRect;
begin
  OldClip := SurfDesc.ClipRect;
  if R.Left + R.Right > SurfDesc.ClipRect.Right then
    ClipRight := SurfDesc.ClipRect.Right
  else
    ClipRight := R.Left + R.Right;
  if R.Top + R.Bottom > SurfDesc.ClipRect.Bottom then
    ClipBottom := SurfDesc.ClipRect.Bottom
  else
    ClipBottom := R.Top + R.Bottom;
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  Images[Index].ShowClipped(R.Left, R.Top, SurfDesc);
  Images[Index + 5].ShowClipped(R.Left, R.Top + R.Bottom - Images[Index + 5].Height, SurfDesc);
  if R.Left + R.Right - Images[Index + 4].Width < OldClip.Right then
    SurfDesc.ClipRect.Right := R.Left + R.Right - Images[Index + 4].Width;
  for I := 0 to (R.Right - Images[Index].Width - Images[Index + 2].Width) div
    Images[Index + 1].Width do
  begin
    Images[Index + 1].ShowClipped(R.Left + Images[Index].Width + Images[Index + 1].Width * I,
      R.Top, SurfDesc);
    Images[Index + 6].ShowClipped(R.Left + Images[Index + 5].Width + Images[Index + 6].Width * I,
      R.Top + R.Bottom - Images[Index + 6].Height, SurfDesc);
  end;
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  if R.Top + R.Bottom - Images[Index + 6].Height < OldClip.Bottom then
    SurfDesc.ClipRect.Bottom := R.Top + R.Bottom - Images[Index + 6].Height;
  for I := 0 to (R.Bottom - Images[Index].Height - Images[Index + 5].Height) div
    Images[Index + 3].Height do
  begin
    Images[Index + 3].ShowClipped(R.Left, R.Top + Images[Index].Height +
      Images[Index + 3].Height * I, SurfDesc);
    Images[Index + 4].ShowClipped(R.Left + R.Right - Images[Index + 4].Width,
      R.Top + Images[Index + 2].Height + Images[Index + 4].Height * I, SurfDesc);
  end;
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  Images[Index + 2].ShowClipped(R.Left + R.Right - Images[Index + 2].Width, R.Top, SurfDesc);
  Images[Index + 7].ShowClipped(R.Left + R.Right - Images[Index + 7].Width,
    R.Top + R.Bottom - Images[Index + 7].Height, SurfDesc);
  SurfDesc.ClipRect := OldClip;
end;

{ DrawILT tiles image Index over R }
procedure TInterfaceIL.DrawILT(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
var
  I, J: Integer;
  ClipRight, ClipBottom: Integer;
  OldClip: TRect;
begin
  OldClip := SurfDesc.ClipRect;
  if R.Left + R.Right > SurfDesc.ClipRect.Right then
    ClipRight := SurfDesc.ClipRect.Right
  else
    ClipRight := R.Left + R.Right;
  if R.Top + R.Bottom > SurfDesc.ClipRect.Bottom then
    ClipBottom := SurfDesc.ClipRect.Bottom
  else
    ClipBottom := R.Top + R.Bottom;
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  if R.Left + R.Right < OldClip.Right then
    SurfDesc.ClipRect.Right := R.Left + R.Right;
  if R.Top + R.Bottom < OldClip.Bottom then
    SurfDesc.ClipRect.Bottom := R.Top + R.Bottom;
  for J := 0 to R.Bottom div Images[Index].Height do
    for I := 0 to R.Right div Images[Index].Width do
      Images[Index].ShowClipped(R.Left + Images[Index].Width * I,
        R.Top + Images[Index].Height * J, SurfDesc);
  SurfDesc.ClipRect := OldClip;
end;

{ DrawILI draws image Index at the top left corner of R, clipped to R }
procedure TInterfaceIL.DrawILI(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
var
  ClipRight, ClipBottom: Integer;
  OldClip: TRect;
begin
  OldClip := SurfDesc.ClipRect;
  if R.Left + R.Right > SurfDesc.ClipRect.Right then
    ClipRight := SurfDesc.ClipRect.Right
  else
    ClipRight := R.Left + R.Right;
  if R.Top + R.Bottom > SurfDesc.ClipRect.Bottom then
    ClipBottom := SurfDesc.ClipRect.Bottom
  else
    ClipBottom := R.Top + R.Bottom;
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  Images[Index].ShowClipped(R.Left, R.Top, SurfDesc);
  SurfDesc.ClipRect := OldClip;
end;

{ DrawILLh draws a horizontal line of 3 images: Index the left end, +1 the middle (repeated),
  +2 the right end }
procedure TInterfaceIL.DrawILLh(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
var
  I: Integer;
  ClipRight, ClipBottom: Integer;
  OldClip: TRect;
begin
  OldClip := SurfDesc.ClipRect;
  if R.Left + R.Right > SurfDesc.ClipRect.Right then
    ClipRight := SurfDesc.ClipRect.Right
  else
    ClipRight := R.Left + R.Right;
  if R.Top + R.Bottom > SurfDesc.ClipRect.Bottom then
    ClipBottom := SurfDesc.ClipRect.Bottom
  else
    ClipBottom := R.Top + R.Bottom;
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  Images[Index].ShowClipped(R.Left, R.Top, SurfDesc);
  if R.Left + R.Right - Images[Index + 2].Width < OldClip.Right then
    SurfDesc.ClipRect.Right := R.Left + R.Right - Images[Index + 2].Width;
  for I := 0 to (R.Right - Images[Index].Width - Images[Index + 2].Width) div
    Images[Index + 1].Width do
    Images[Index + 1].ShowClipped(R.Left + Images[Index].Width + Images[Index + 1].Width * I,
      R.Top, SurfDesc);
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  Images[Index + 2].ShowClipped(R.Left + R.Right - Images[Index + 2].Width, R.Top, SurfDesc);
  SurfDesc.ClipRect := OldClip;
end;

{ DrawILLv draws a vertical line of 3 images: Index the top end, +1 the middle (repeated), +2
  the bottom end }
procedure TInterfaceIL.DrawILLv(Index: Integer; const R: TRect; var SurfDesc: TSurfaceDesc);
var
  I: Integer;
  ClipRight, ClipBottom: Integer;
  OldClip: TRect;
begin
  OldClip := SurfDesc.ClipRect;
  if R.Left + R.Right > SurfDesc.ClipRect.Right then
    ClipRight := SurfDesc.ClipRect.Right
  else
    ClipRight := R.Left + R.Right;
  if R.Top + R.Bottom > SurfDesc.ClipRect.Bottom then
    ClipBottom := SurfDesc.ClipRect.Bottom
  else
    ClipBottom := R.Top + R.Bottom;
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  Images[Index].ShowClipped(R.Left, R.Top, SurfDesc);
  if R.Top + R.Bottom - Images[Index + 2].Height < OldClip.Bottom then
    SurfDesc.ClipRect.Bottom := R.Top + R.Bottom - Images[Index + 2].Height;
  for I := 0 to (R.Bottom - Images[Index].Height - Images[Index + 2].Height) div
    Images[Index + 1].Height do
    Images[Index + 1].ShowClipped(R.Left, R.Top + Images[Index].Height +
      Images[Index + 1].Height * I, SurfDesc);
  SurfDesc.ClipRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, ClipRight, ClipBottom);
  Images[Index + 2].ShowClipped(R.Left, R.Top + R.Bottom - Images[Index + 2].Height, SurfDesc);
  SurfDesc.ClipRect := OldClip;
end;

procedure Register;
begin
  RegisterComponents('ImageLibrary', [TInterfaceIL]);
end;

end.
