unit PageTurnCtrl;

{ Draft declarations of PageTurnCtrl, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TPageTurnControl = class;
  TPageTurnMode = (ptLeft, ptRight, ptOpen, ptClose);


  { TPageTurnControl (instance size 2228, VMT 55809D40) }
  TPageTurnControl = class(TObject)
  public
    FScale: Single; { +$04 }
    FShade: Single; { +$08 }
    FHalfWidth: Single; { +$0C }
    FSpeed: Integer; { +$10 }
    FMode: TPageTurnMode; { +$14 }
    FReserved15: array[0..2] of Byte;
    FWidth: Integer; { +$18 }
    FHeight: Integer; { +$1C }
    FSource1: TSurfaceDesc; { +$20 }
    FSourceX1, FSourceY1: Integer; { +$5C, +$60 }
    FSource2: TSurfaceDesc; { +$64 }
    FSourceX2, FSourceY2: Integer; { +$A0, +$A4 }
    FInvCos: array[0..511] of Single; { +$A8 }
    FRadius: Single; { +$8A8 }
    FShadow: Single; { +$8AC }
    FPosition: Integer; { +$8B0 }
    constructor Create;
    procedure SetPageDimensions(Width, Height: Integer);
    function GetInvCos(Value: Single): Single;
    procedure GenerateInvCosTable;
    procedure BltVerticalScanLine(SourceX, DestX, DestY: Integer; const Dest: TSurfaceDesc; Top, Bottom: Integer);
    procedure Start(Mode: TPageTurnMode);
    function UpdateScene: Boolean;
    procedure RenderLeftRightScene(X, Y: Integer; const Dest: TSurfaceDesc);
    procedure RenderOpenCloseScene(X, Y: Integer; const Dest: TSurfaceDesc);
    procedure RenderScene(X, Y: Integer; const Dest: TSurfaceDesc; X1, Y1: Integer; const Source1: TSurfaceDesc; X2, Y2: Integer; const Source2: TSurfaceDesc; var R: TRect);
  end;


implementation

constructor TPageTurnControl.Create;
begin
  inherited Create;
  FScale := 0.5;
  FSpeed := 2;
  FShade := 2.0;
  GenerateInvCosTable;
end;

procedure TPageTurnControl.SetPageDimensions(Width, Height: Integer);
begin
  FWidth := Width;
  FHeight := Height;
  FHalfWidth := FWidth shr 1;
end;

function TPageTurnControl.GetInvCos(Value: Single): Single;
begin
















  Assert((Value >= -1.0) and (Value <= 1.0));
  if Value >= 0 then Result := FInvCos[Round(Value * 511)]
  else Result := Pi - FInvCos[Round(-Value * 511)];
end;

procedure TPageTurnControl.GenerateInvCosTable;
var
  CosValue, Angle, Target: Single;
  I: Integer;
begin
  Angle := 0;
  I := 511;
  while Angle < Pi / 2 do
  begin
    CosValue := Cos(Angle);
    Target := I / 511;
    if CosValue - Target > 0 then FInvCos[I] := Angle
    else Dec(I);
    Angle := Angle + 0.00001;
  end;
end;

type PScanPixel = ^Word;
procedure BltColumn(Source: Pointer; SourcePitch: Integer; Dest: Pointer; DestPitch, Height: Integer); stdcall;
begin
  while Height > 0 do
  begin
    PScanPixel(Dest)^ := PScanPixel(Source)^;
    Inc(Integer(Source), SourcePitch);
    Inc(Integer(Dest), DestPitch);
    Dec(Height);
  end;
end;

procedure TPageTurnControl.BltVerticalScanLine(SourceX, DestX, DestY: Integer; const Dest: TSurfaceDesc; Top, Bottom: Integer);
var SourceY, Height, Y, ClipBottom: Integer; SourceP, DestP: Pointer; SourcePitch: Integer;
begin
  if (Dest.ClipRect.Left <= DestX) and (DestX < Dest.ClipRect.Right) then
  begin
    SourceY := Top;
    Y := DestY + Top;
    Height := Bottom - Top;
    if Y < Dest.ClipRect.Top then
    begin
      Dec(Height, Dest.ClipRect.Top - Y);
      Inc(SourceY, Dest.ClipRect.Top - Y);
      Y := Dest.ClipRect.Top;
    end;
    ClipBottom := Dest.ClipRect.Bottom;
    if ClipBottom < Height + Y then Dec(Height, Height + Y - Dest.ClipRect.Bottom);
    if Height > 0 then
    begin
      if SourceX < FWidth * 2 then
      begin
        SourceP := Pointer(Integer(FSource1.Data) + (FSourceX1 + SourceX) * 2 + (FSourceY1 + SourceY) * FSource1.Pitch);
        SourcePitch := FSource1.Pitch;
      end else
      begin
        SourceP := Pointer(Integer(FSource2.Data) + (SourceX - FWidth * 2 + FSourceX2) * 2 + (FSourceY2 + SourceY) * FSource2.Pitch);
        SourcePitch := FSource2.Pitch;
      end;
      DestP := Pointer(Integer(Dest.Data) + DestX * 2 + Dest.Pitch * Y);
      BltColumn(SourceP, SourcePitch, DestP, Dest.Pitch, Height);
    end;
  end;
end;

procedure TPageTurnControl.Start(Mode: TPageTurnMode);
begin
  FMode := Mode;
  case FMode of
    ptLeft:
      begin FRadius := FHalfWidth; FShadow := FRadius * 0.5; FPosition := FWidth; end;
    ptRight:
      begin FRadius := 1; FShadow := FRadius * 0.5; FPosition := 0; end;
    ptOpen: FPosition := 0;
    ptClose: FPosition := 180;
  end;
end;

function TPageTurnControl.UpdateScene: Boolean;
begin
  case FMode of
    ptLeft:
      begin
        FShade := 3.5;
        if FPosition > 0 then
        begin
          Dec(FPosition, FSpeed);
          if FPosition < 0 then FPosition := 0;
        end
        else if FRadius > 0 then
        begin
          FRadius := FRadius - FSpeed * 1.25 * 2 / Pi;
          if FRadius < 1 then FRadius := 0;
          FShadow := FRadius * 0.5;
        end;
        Result := FRadius >= 1;
      end;
    ptRight:
      begin
        FShade := 2.0;
        if FRadius < FHalfWidth then
        begin
          FRadius := FRadius + FSpeed * 1.5 * 2 / Pi;
          if FRadius > FHalfWidth then FRadius := FHalfWidth;
          FShadow := FRadius * 0.5;
        end
        else
        begin
          Inc(FPosition, FSpeed);
          if FPosition > FWidth then FPosition := FWidth;
        end;
        Result := FPosition < FWidth;
      end;
    ptOpen:
      begin
        Inc(FPosition, FSpeed);
        if FPosition > 180 then FPosition := 180;
        Result := FPosition < 180;
      end;
    ptClose:
      begin
        Dec(FPosition, FSpeed);
        if FPosition < 0 then FPosition := 0;
        Result := FPosition > 0;
      end;
  else Result := False;
  end;
end;

procedure TPageTurnControl.RenderLeftRightScene(X, Y: Integer; const Dest: TSurfaceDesc);
begin end;

procedure TPageTurnControl.RenderOpenCloseScene(X, Y: Integer; const Dest: TSurfaceDesc);
var BaseX, Height, Width: Integer; Step, SourceX: Single; Offset: Integer; R: TRect; I, PageWidth: Integer;
begin
  R.Left := FSourceX2 + FWidth;
  R.Top := FSourceY2;
  R.Right := FSourceX2 + FWidth * 2;
  R.Bottom := FSourceY2 + FHeight;
  BltSDRectClipped(FSource2, R, Dest, X + FWidth, Y);
  Height := Round(Sin(FPosition * Pi / 180) * FWidth);
  Width := Round(Cos(FPosition * Pi / 180) * FWidth);
  if Width > 0 then
  begin
    Step := FWidth / Width;
    BaseX := X + FWidth;
    PageWidth := FWidth;
    SourceX := PageWidth;
    for I := 0 to Width - 1 do
    begin
      Offset := Round(I / Width * Height * FScale);
      BltVerticalScanLine(Round(SourceX), BaseX + I, Y - Offset, Dest, 0, FHeight);
      SourceX := SourceX + Step;
    end;
  end else if Width < 0 then
  begin
    Width := -Width;
    Step := FWidth / Width;
    BaseX := X + FWidth;
    SourceX := FWidth * 3;
    for I := 0 to Width - 1 do
    begin
      Offset := Round(I / Width * Height * FScale);
      BltVerticalScanLine(Round(SourceX), BaseX - I, Y - Offset, Dest, 0, FHeight);
      SourceX := SourceX - Step;
    end;
  end;
end;

procedure TPageTurnControl.RenderScene(X, Y: Integer; const Dest: TSurfaceDesc; X1, Y1: Integer; const Source1: TSurfaceDesc; X2, Y2: Integer; const Source2: TSurfaceDesc; var R: TRect);
begin
  case FMode of
    ptLeft:
      begin
        FSource1 := Source1; FSourceX1 := X1; FSourceY1 := Y1;
        FSource2 := Source2; FSourceX2 := X2; FSourceY2 := Y2;
        RenderLeftRightScene(X, Y, Dest);
        R.Left := X; R.Right := X + FWidth * 2;
        R.Top := Y - (Round(FScale * FRadius) + 1);
        R.Bottom := Y + FHeight;
      end;
    ptRight:
      begin
        FSource1 := Source2; FSourceX1 := X2; FSourceY1 := Y2;
        FSource2 := Source1; FSourceX2 := X1; FSourceY2 := Y1;
        RenderLeftRightScene(X, Y, Dest);
        R.Left := X; R.Right := X + FWidth * 2;
        R.Top := Y - (Round(FScale * FRadius) + 1);
        R.Bottom := Y + FHeight;
      end;
    ptOpen:
      begin
        FSource1 := Source1; FSourceX1 := X1; FSourceY1 := Y1;
        FSource2 := Source2; FSourceX2 := X2; FSourceY2 := Y2;
        RenderOpenCloseScene(X, Y, Dest);
        R.Left := X; R.Right := X + FWidth * 2;
        R.Top := Y - Round(Sin(FPosition * Pi / 180) * FScale * FWidth + 1);
        R.Bottom := Y + FHeight;
      end;
    ptClose:
      begin
        FSource1 := Source2; FSourceX1 := X2; FSourceY1 := Y2;
        FSource2 := Source1; FSourceX2 := X1; FSourceY2 := Y1;
        RenderOpenCloseScene(X, Y, Dest);
        R.Left := X; R.Right := X + FWidth * 2;
        R.Top := Y - Round(Sin(FPosition * Pi / 180) * FScale * FWidth + 1);
        R.Bottom := Y + FHeight;
      end;
  end;
end;


initialization
finalization

end.
