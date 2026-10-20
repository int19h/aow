unit aowFX;

{ The aowFX unit of aowFXpck.dpl: point paths for the game's spell and world effects (TXYZList
  of TXYZ points: lines, arcs, swarms, lightning bolts) and the declarations of a particle
  system that has no code of its own, written for the original compiler (Delphi 3.02) and
  compared function by function with the shipped module (tools/match.py). Declarations follow
  the original instance layouts (notes/classes.json, notes/rtti/aowFXpck.dpl.txt).

  The path routines append new TXYZ points to List (passed by reference, the caller owns it):
  MakeLinePath Steps points from (X1, Y1) to (X2, Y2); MakeArcPathXY the same with Z following a
  half sine wave of the given height; MakeArcPath a ballistic arc (Z rises with VZ and falls with
  Gravity); MakeSwarmPath a closed loop around (X, Y); MakeLightningPath a zigzag of line pieces
  from (X1, Y1) to (X2, Y2), the last point marked with Z = 1; ScatterPath jitters the inner
  points of a path by one pixel. AoWEPACK's TWorldFXHS keeps such a list (+$20 FXYZList).

  The package requires Ilpack and Gfxepack, and its init table lists ImageLib right after the
  units of Classes (so the original uses clause probably named ImageLib), but nothing of either
  package is used here. The unit was compiled with the default switches. }

interface

uses
  Classes, Math;

type
  TSwarmDirection = (sdForward, sdBackward);

  { aowFX.TXYZ (instance size 16): one point, +4 X, +8 Y, +$C Z. }
  TXYZ = class(TObject)
  public
    X: Integer;
    Y: Integer;
    Z: Integer;
  end;

  { aowFX.TXYZList (instance size 8): +4 FList, the owned points. }
  TXYZList = class(TObject)
  private
    FList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(XYZ: TXYZ);
    procedure Delete(Index: Integer);
    function GetXYZ(Index: Integer): TXYZ;
    function GetCount: Integer;
    property Count: Integer read GetCount;
    property XYZ[Index: Integer]: TXYZ read GetXYZ; default;
  end;

  { aowFX.TfxParticleObject (instance size 44): no method of the package touches its fields, so
    only their size (+4..+$2B) is known. }
  TfxParticleObject = class(TObject)
  private
    FData: array[0..9] of Integer;
  end;

  { aowFX.TfxParticle (instance size 44), no fields of its own. }
  TfxParticle = class(TfxParticleObject)
  end;

  { aowFX.TfxParticleEffect (instance size 44), no fields of its own. }
  TfxParticleEffect = class(TfxParticleObject)
  end;

  { aowFX.TfxParticleSystem (instance size 52): +$2C FParticles, +$30 FEffects (never created by
    this unit). }
  TfxParticleSystem = class(TfxParticleObject)
  private
    FParticles: TList;
    FEffects: TList;
  public
    function GetParticle(Index: Integer): TfxParticle;
    function GetEffect(Index: Integer): TfxParticleEffect;
    property Particles[Index: Integer]: TfxParticle read GetParticle;
    property Effects[Index: Integer]: TfxParticleEffect read GetEffect;
  end;

procedure ScatterPath(var List: TXYZList);
procedure MakeLinePath(X1, Y1, X2, Y2, Steps: Integer; var List: TXYZList);
procedure MakeSwarmPath(Step, Radius, Phase, Angle, X, Y: Integer; Direction: TSwarmDirection;
  var List: TXYZList);
procedure MakeLightningPath(X1, Y1, X2, Y2: Integer; var List: TXYZList);
procedure MakeArcPath(X, Y, Angle: Integer; var Z, Speed, VZ, Gravity: Single;
  var List: TXYZList);
procedure MakeArcPathXY(X1, Y1, X2, Y2, StepSize, Height: SmallInt; var List: TXYZList);

implementation

{ TXYZList }

constructor TXYZList.Create;
begin
  FList := TList.Create;
end;

destructor TXYZList.Destroy;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    GetXYZ(I).Free;
  FList.Free;
  inherited Destroy;
end;

procedure TXYZList.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    GetXYZ(I).Free;
  FList.Clear;
end;

procedure TXYZList.Add(XYZ: TXYZ);
begin
  FList.Add(XYZ);
end;

procedure TXYZList.Delete(Index: Integer);
begin
  TXYZ(FList[Index]).Free;
  FList.Delete(Index);
end;

function TXYZList.GetXYZ(Index: Integer): TXYZ;
begin
  if (Index >= 0) and (Index < FList.Count) then
    Result := TXYZ(FList[Index])
  else
    Result := nil;
end;

function TXYZList.GetCount: Integer;
begin
  Result := FList.Count;
end;

{ TfxParticleSystem }

function TfxParticleSystem.GetParticle(Index: Integer): TfxParticle;
var
  P: Pointer;
begin
  P := FParticles[Index];
  Result := TfxParticle(P);
end;

function TfxParticleSystem.GetEffect(Index: Integer): TfxParticleEffect;
var
  P: Pointer;
begin
  P := FEffects[Index];
  Result := TfxParticleEffect(P);
end;

{ paths }

procedure ScatterPath(var List: TXYZList);
var
  I, RX, RY, DX, DY: Integer;
  XYZ: TXYZ;
begin
  DX := 0;
  DY := 0;
  for I := 1 to List.Count - 2 do
  begin
    XYZ := List[I];
    RX := Random(3);
    RY := Random(3);
    if RX - DX > 1 then
      RX := DX + 1;
    if DX - RX > 1 then
      RX := DX - 1;
    if RY - DY > 1 then
      RY := DY + 1;
    if DY - RY > 1 then
      RY := DY - 1;
    XYZ.X := XYZ.X + RX - 1;
    XYZ.Y := XYZ.Y + RY - 1;
    DX := RX;
    DY := RY;
  end;
end;

procedure MakeLinePath(X1, Y1, X2, Y2, Steps: Integer; var List: TXYZList);
var
  I: Integer;
  XYZ: TXYZ;
begin
  if Steps < 2 then
    Steps := 2;
  for I := 0 to Steps - 1 do
  begin
    XYZ := TXYZ.Create;
    List.Add(XYZ);
    XYZ.X := X1 + (X2 - X1) * I div (Steps - 1);
    XYZ.Y := Y1 + (Y2 - Y1) * I div (Steps - 1);
  end;
end;

procedure MakeSwarmPath(Step, Radius, Phase, Angle, X, Y: Integer; Direction: TSwarmDirection;
  var List: TXYZList);
var
  Total, B: Integer;
  Rad, R: Single;
  XYZ: TXYZ;
begin
  Total := 0;
  repeat
    Rad := Angle * Pi / 180;
    B := (Phase + Angle) mod 180;
    case B of
      0..89: R := Sqr(B / 90) * Radius + Radius;
    else
      R := Sqr((180 - B) / 90) * Radius + Radius;
    end;
    XYZ := TXYZ.Create;
    XYZ.X := Round(Sin(Rad) * R) + X;
    XYZ.Y := Round(Cos(Rad) * R) + Y;
    List.Add(XYZ);
    case Direction of
      sdForward:
        begin
          Angle := Angle + Step;
          if Angle >= 360 then
            Angle := Angle - 360;
        end;
      sdBackward:
        begin
          Angle := Angle - Step;
          { sic: tests 360 instead of 0, so the angle is never wrapped back }
          if Angle < 360 then
            Angle := Angle + 360;
        end;
    end;
    Total := Total + Step;
  until Total >= 360;
end;

{ The direction of the line from (X1, Y1) to (X2, Y2) in radians, pointing backwards (the
  lightning path subtracts it). }
function GetAngle(X1, Y1, X2, Y2: Integer): Single;
begin
  if X1 = X2 then
    Result := Pi / 2
  else
    Result := ArcTan((Y2 - Y1) / (X2 - X1));
  if X2 > X1 then
    Result := Result + Pi
  else if (Y1 < Y2) and (X2 = X1) then
    Result := Result + Pi;
end;

procedure MakeLightningPath(X1, Y1, X2, Y2: Integer; var List: TXYZList);
var
  NX, NY, CX, CY, Len: Integer;
  Angle, A2: Single;
  Dist, Seg: Integer;
begin
  CX := X1;
  CY := Y1;
  Angle := GetAngle(X1, Y1, X2, Y2);
  A2 := Angle;
  Len := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
  Dist := 0;
  Seg := Random(15) + 5;
  while Dist + Seg < Len do
  begin
    if A2 > Angle then
      A2 := Angle - DegToRad(Random(40) + 40)
    else
      A2 := Angle + DegToRad(Random(40) + 40);
    NX := X1 - Round(Cos(Angle) * Dist) - Round(Cos(A2) * Seg);
    NY := Y1 - Round(Sin(Angle) * Dist) - Round(Sin(A2) * Seg);
    MakeLinePath(CX, CY, NX, NY, Seg, List);
    CX := NX;
    CY := NY;
    Seg := Abs(Round(Cos(A2 - Angle) * Seg));
    Dist := Dist + Seg;
    Seg := Random(15) + 5;
  end;
  MakeLinePath(CX, CY, X2, Y2, Len - Dist, List);
  List[List.Count - 1].Z := 1;
end;

{ sic: Angle is used as radians (Cos(Angle)), but the game passes degrees (Random(360)). }
procedure MakeArcPath(X, Y, Angle: Integer; var Z, Speed, VZ, Gravity: Single;
  var List: TXYZList);
var
  FX, FY, DX, DY: Single;
  XYZ: TXYZ;
begin
  FX := X;
  FY := Y;
  DX := Cos(Angle) * Speed;
  DY := Sin(Angle) * Speed;
  if Gravity > 0 then
    while Z >= 0 do
    begin
      XYZ := TXYZ.Create;
      XYZ.X := Round(FX);
      XYZ.Y := Round(FY);
      XYZ.Z := Round(Z);
      List.Add(XYZ);
      FX := FX + DX;
      FY := FY + DY;
      VZ := VZ - Gravity;
      Z := Z + VZ;
    end;
end;

procedure MakeArcPathXY(X1, Y1, X2, Y2, StepSize, Height: SmallInt; var List: TXYZList);
var
  I, Steps, DX, DY: Integer;
  XYZ: TXYZ;
begin
  I := 0;
  DX := Abs(X2 - X1);
  DY := Abs(Y2 - Y1);
  Steps := (DX + DY) div StepSize;
  if Steps < 2 then
    Steps := 2;
  while I <= Steps do
  begin
    XYZ := TXYZ.Create;
    List.Add(XYZ);
    XYZ.X := X1 + (X2 - X1) * I div Steps;
    XYZ.Y := Y1 + (Y2 - Y1) * I div Steps;
    XYZ.Z := Round(Sin(I * Pi / Steps) * Height);
    Inc(I);
  end;
end;

end.
