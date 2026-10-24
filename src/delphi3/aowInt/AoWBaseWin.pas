unit AoWBaseWin;

{ The AoWBaseWin unit of aowInt.dpl: TAOWBaseWindow, a window of the window manager. It draws
  itself and its controls into its back surface (DrawSurface) or straight into the display surface
  (DrawSurfDesc), redrawing only the dirty rectangles, and passes invalidated rectangles on to the
  windows above it and to its owner. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl;

type
  { AoWBaseWin.TAOWBaseWindow (instance size 492). Fields: +$1D0 FBuffer (freed by
    TAOWGenericWindow.Destroy), +$1D4 FFreeSurfaceOnHide, +$1D8 FWinManager, +$1DC FOnShow, +$1E4
    FOnHide.
    VMT (new): SetILFrame, SetILTexture }
  TAOWBaseWindow = class(TAOWWindowControl)
  public
    FBuffer: TObject;
    FFreeSurfaceOnHide: Boolean;
    FWinManager: TAOWWinManager;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    procedure InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent); override;
    procedure AddBltRect(var ARect: TRect; Sender: TAoWComponent); override;
    procedure SetVisible(Value: Boolean); override;
    procedure DrawSurface(Surface: TSurface); override;
    procedure DrawSurfDesc(SurfDesc: TSurfaceDesc); override;
    procedure SetILFrame(Value: TInterfaceIL); virtual;
    procedure SetILTexture(Value: TInterfaceIL); virtual;
    procedure SetILFIndex(Value: Integer);
    procedure SetILTIndex(Value: Integer);
    procedure SetManager(Value: TAOWWinManager);
    property ILFrame: TInterfaceIL read FILFrame write SetILFrame;
    property ILTexture: TInterfaceIL read FILTexture write SetILTexture;
    property ILIndexFrame: Integer read FILIndexFrame write SetILFIndex;
    property ILIndexTexture: Integer read FILIndexTexture write SetILTIndex;
  published
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property Alignment;
  end;

implementation

{ TAOWBaseWindow }

procedure TAOWBaseWindow.AddBltRect(var ARect: TRect; Sender: TAoWComponent);
begin
  if FDoubleBuffered and FSurfaceValid then
    inherited AddBltRect(ARect, Sender);
end;

procedure TAOWBaseWindow.InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent);
var
  I: Integer;
  C: TAoWComponent;
begin { Tried Self identity, receiver scope and local/field staging; register/stack allocation still differs. }
  if (Index > -1) and FValid and FVisible then
  begin
    for I := Index to FChildren.Count - 1 do
    begin
      C := FChildren[I];
      if C.FValid and C.FVisible and (ARect.Right >= C.FWinLeft) and
        (C.FWinLeft + C.FWinWidth >= ARect.Left) and (ARect.Bottom >= C.FWinTop) and
        (C.FWinTop + C.FWinHeight >= ARect.Top) and (C <> Sender) then
        if C is TAOWBaseWindow then
          C.InvalidateRect(0, ARect, Self)
        else
          C.FDrawn := False;
    end;
    if (FAOWOwner <> Sender) and (FAOWOwner is TAOWBaseWindow) then
      FAOWOwner.InvalidateRect(FAOWOwner.FChildren.IndexOf(Self) + 1, ARect, Self);
  end;
end;

procedure TAOWBaseWindow.SetILFIndex(Value: Integer);
begin
  if Value <> FILIndexFrame then
  begin
    FILIndexFrame := Value;
    FValid := False;
  end;
end;

procedure TAOWBaseWindow.SetILTIndex(Value: Integer);
begin
  if Value <> FILIndexTexture then
  begin
    FILIndexTexture := Value;
    FValid := False;
  end;
end;

{ DrawSurface draws the window and its controls. A double-buffered window draws into its back
  surface (at 0, 0: the position is restored afterwards), redrawing everything when it is not
  drawn or only the rectangles of its draw list, then lets the controls draw themselves and
  blits the dirty rectangles of its blit list to Surface, telling the window manager about each
  one. A window without a back surface draws itself and its controls straight into Surface. }
procedure TAOWBaseWindow.DrawSurface(Surface: TSurface);
var
  I, J: Integer;
  C: TAoWComponent;
  D: TaowRect;
  OldLeft, OldTop: Integer;
  Locked: Boolean;
  SD: TSurfaceDesc;
  R: TRect;
begin
  try
    if FValid and FVisible then
    begin
      OldLeft := FWinLeft;
      OldTop := FWinTop;
      try
        if FDoubleBuffered then
        begin
          FDrawn := not VerifyBackSurface(Surface) and FDrawn;
          FWinLeft := 0;
          FWinTop := 0;
          Locked := FBackSurface.Lock(SD) = 0;
        end
        else
          Locked := Surface.Lock(SD) = 0;
      except
        Locked := False;
        MessageBox(0, 'Verify Surface Error', Pointer('Error - ' + Name), 0);
      end;
      if Locked then
      begin
        try
          if not FDrawn then
          begin
            FSurfaceValid := False;
            ClearDrawList;
          end;
          if not FSurfaceValid then
            ClearBltList;
          if not FDrawn then
            Draw(SD)
          else if FPriority >= FWinManager.FOverlayPriority then
            for J := 0 to FDrawCount - 1 do
            begin
              D := FDrawList[J];
              R := SD.ClipRect;
              SD.ClipRect := Rect(D.R.Left, D.R.Top, D.R.Right + 1, D.R.Bottom + 1);
              Draw(SD);
              SD.ClipRect := R;
              InvalidateRect(0, D.R, nil);
            end;
          FDrawCount := 0;
        except
          MessageBox(0, 'Draw Error', Pointer('Error - ' + Name), 0);
        end;
        if FDoubleBuffered then
        begin
          if (FPriority >= FWinManager.FOverlayPriority) or not FDrawn then
          begin
            for I := 0 to FChildren.Count - 1 do
            begin
              C := FChildren[I];
              if C.FValid and C.FVisible and (not FDrawn or not C.FDrawn) then
              begin
                if not FDrawn and (C is TAOWBaseWindow) then
                  C.FSurfaceValid := False;
                C.FDrawn := False;
                C.Draw(SD);
                for J := 0 to FDrawCount - 1 do
                begin
                  D := FDrawList[J];
                  InvalidateRect(I + 1, D.R, nil);
                end;
                FDrawCount := 0;
                if not C.FDrawn or not FDrawn then
                begin
                  if FSurfaceValid then
                  begin
                    R := Rect(C.FWinLeft, C.FWinTop, C.FWinLeft + C.FWinWidth, C.FWinTop + C.FWinHeight);
                    AddBltRect(R, C);
                  end;
                  C.FFirstDraw := C.FDrawn;
                  R := Rect(FWinLeft + C.FWinLeft, FWinTop + C.FWinTop,
                    FWinLeft + C.FWinLeft + C.FWinWidth - 1, FWinTop + C.FWinTop + C.FWinHeight - 1);
                  InvalidateRect(I + 1, R, C);
                end;
                C.FDrawn := True;
              end;
            end;
            if Assigned(FOnDraw) then
              FOnDraw(Self, SD);
          end;
          if Locked then
            FBackSurface.Unlock;
          FWinLeft := OldLeft;
          FWinTop := OldTop;
          try
            if FSurfaceValid then
            begin
              if FBltCount > 0 then
              begin
                if Assigned(FOnPreDrawSurface) then
                  FOnPreDrawSurface(Self, FBackSurface, 0, 0);
                for J := 0 to FBltCount - 1 do
                begin
                  D := FBltList[J];
                  R := Rect(D.R.Left, D.R.Top, D.R.Right + 1, D.R.Bottom + 1);
                  if not FMasked then
                    FBackSurface.BltClipped(Surface, @R, D.R.Left + OldLeft, D.R.Top + OldTop)
                  else
                    FBackSurface.BltColorKeyClipped(Surface, @R, D.R.Left + OldLeft, D.R.Top + OldTop,
                      Color2PixelInfo(FMaskColor, FBackSurface.GetPixelFormatID, nil));
                  R := Rect(D.R.Left + OldLeft, D.R.Top + OldTop, D.R.Right + OldLeft,
                    D.R.Bottom + OldTop);
                  FWinManager.AddBltRect(R, Self);
                end;
                if Assigned(FOnDrawSurface) then
                  FOnDrawSurface(Self, Surface, 0, 0);
              end;
            end
            else
              Blt(Surface);
          except
            MessageBox(0, 'Blt Error', Pointer('Error - ' + Name), 0);
          end;
        end
        else
        begin
          for I := 0 to FChildren.Count - 1 do
          begin
            C := FChildren[I];
            if not FDrawn or not C.FDrawn or (C is TAOWBaseWindow) then
            begin
              C.Draw(SD);
              C.FDrawn := True;
            end;
          end;
          if Assigned(FOnDraw) then
            FOnDraw(Self, SD);
          if Locked then
            Surface.Unlock;
          try
            if Assigned(FOnPreDrawSurface) then
              FOnPreDrawSurface(Self, Surface, FWinLeft, FWinTop);
            if Assigned(FOnDrawSurface) then
              FOnDrawSurface(Self, Surface, FWinLeft, FWinTop);
          except
            MessageBox(0, 'SB Draw Events Error', Pointer('Error - ' + Name), 0);
          end;
        end;
        FDrawn := True;
      end;
    end;
  except
    MessageBox(0, 'Exception during DrawSurface', Pointer('Error - ' + Name), 0);
  end;
end;

{ DrawSurfDesc draws the window and its controls into SurfDesc. A double-buffered window draws
  into its back surface instead (created, or created again when the pixel format changed) and
  copies it into SurfDesc, masked with FMaskColor for a masked window. }
procedure TAOWBaseWindow.DrawSurfDesc(SurfDesc: TSurfaceDesc);
var
  I: Integer;
  C: TAoWComponent;
  OldLeft, OldTop: Integer;
  Ok: Boolean;
  DestSD: TSurfaceDesc;
  SrcRect, DestRect: TRect;
begin
  try
    OldLeft := FWinLeft;
    OldTop := FWinTop;
    Ok := True;
    if FDoubleBuffered then
    begin
      DestSD := SurfDesc;
      if FBackSurface = nil then
      begin
        FBackSurface := TDataSurface.Create(FWinWidth, FWinHeight, SurfDesc.PixelFormatID, nil);
        if FMasked then
          FBackSurface.Cls(FMaskColor);
        Ok := FBackSurface.Lock(SurfDesc) >= 0;
      end
      else
      begin
        Ok := FBackSurface.Lock(SurfDesc) >= 0;
        if Ok then
          if SurfDesc.PixelFormatID <> DestSD.PixelFormatID then
          begin
            FBackSurface.Unlock;
            FBackSurface.Free;
            FBackSurface := TDataSurface.Create(FWinWidth, FWinHeight, DestSD.PixelFormatID, nil);
            if FMasked then
              FBackSurface.Cls(FMaskColor);
            Ok := FBackSurface.Lock(SurfDesc) >= 0;
          end;
      end;
      if FBackSurface <> nil then
      begin
        FWinLeft := 0;
        FWinTop := 0;
      end;
    end;
    if Ok then
    begin
      Draw(SurfDesc);
      for I := 0 to FChildren.Count - 1 do
      begin
        C := FChildren[I];
        if C.FValid and C.FVisible and (not FDrawn or not C.FDrawn) then
        begin
          C.Draw(SurfDesc);
          C.FDrawn := True;
        end;
      end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
      if FDoubleBuffered then
      begin
        FWinLeft := OldLeft;
        FWinTop := OldTop;
        SrcRect := Rect(0, 0, FWinWidth, FWinHeight);
        DestRect := Rect(FWinLeft, FWinTop, FWinLeft + FWinWidth, FWinTop + FWinHeight);  { not used }
        try
          if FMasked = True then
            BltSpriteClipped16(SurfDesc, SrcRect, DestSD, FWinLeft, FWinTop, FMaskColor)
          else
            BltSDRectClipped(SurfDesc, SrcRect, DestSD, FWinLeft, FWinTop);
        except
        end;
        FBackSurface.Unlock;
      end;
    end;
  except
    MessageBox(0, 'Exception during DrawSurfaceDesc', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAOWBaseWindow.SetILFrame(Value: TInterfaceIL);
begin
  if Value <> FILFrame then
  begin
    FValid := False;
    FILFrame := Value;
  end;
end;

procedure TAOWBaseWindow.SetILTexture(Value: TInterfaceIL);
begin
  if Value <> FILTexture then
  begin
    FValid := False;
    FILTexture := Value;
  end;
end;

procedure TAOWBaseWindow.SetManager(Value: TAOWWinManager);
begin
  SetOwner(Value);
end;

{ SetVisible: a hidden window marks itself hidden (the window manager redraws the place it
  covered) and may free its back surface; a shown window is redrawn from scratch, remembers its
  place in FBackRect, and is put back at its place in the window order. }
procedure TAOWBaseWindow.SetVisible(Value: Boolean);
begin { Tried Self identity and typed/untyped receiver scopes; Self register still differs. }
  if Value <> FVisible then
  begin
    FVisible := Value;
    if not FVisible then
    begin
      FHidden := True;
      if Assigned(FOnHide) then
        FOnHide(Self);
      if FFreeSurfaceOnHide and (FBackSurface <> nil) then
      begin
        FBackSurface.Free;
        FBackSurface := nil;
      end;
    end
    else
    begin
      if FDoubleBuffered then
        FSurfaceValid := False
      else
        FDrawn := False;
      if not FHidden then
      begin
        FBackRect.Right := FWinWidth;
        FBackRect.Bottom := FWinHeight;
        FBackRect.Top := FWinTop;
        FBackRect.Left := FWinLeft;
      end;
      if not FValid or not FAligned or not FSized then
        Setup;
      ClearBltList;
      ClearDrawList;
      if Assigned(FOnShow) then
        FOnShow(Self);
    end;
  end;
  if FVisible then
    SetPriority(FPriority);
end;

end.
