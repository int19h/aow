unit AoWHex;

{ AoWHex of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TAoWHexagon = class;
  TAoWHexagonResource = class;
  TAoWBorderHexagon = class;
  TAoWWaterHexagon = class;
  TAoWWaterHexagonResource = class;


  { TAoWHexagon (instance size 20, VMT 5579A1D0): inherited +$10 transition
    images [0..2], +$13 side flags. }
  TAoWHexagon = class(THexagon)
  public
    procedure ChangeTerrain(const Msg: HSEngine.THSTerrainInfo); override;
    procedure TerrainChanged(const Msg: HSEngine.THSTerrainInfo); override;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo); override;
    procedure UpdateTransition(Side: Byte); override;
  end;

  { TAoWHexagonResource (instance size 56, VMT 5579A364) }
  TAoWHexagonResource = class(THexagonResource)
  public
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
  end;

  { TAoWBorderHexagon (instance size 16, VMT 5579A458) }
  TAoWBorderHexagon = class(TBorderHexagon)
  public
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
  end;

  { TAoWWaterHexagon (instance size 32, VMT 5579A5F8): +$18 FAnimationFrame,
    +$19 FAnimationIndex, +$1A..$1F FShoreTerrain[1..6]. }
  TAoWWaterHexagon = class(TLowerIsometricHexagon)
  public
    FAnimationFrame: Shortint;
    FAnimationIndex: Byte;
    FShoreTerrain: array[1..6] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure UpdateTransitions; override;
    procedure ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TAoWWaterHexagonResource (instance size 56, VMT 5579A7A0) }
  TAoWWaterHexagonResource = class(TLowerIsometricHexagonResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAoWHexagon(AEngine: TEngine);

implementation

type
  TAoWFieldFlags = packed record
    Reserved: array[0..23] of Byte;
    Flags: Integer;
  end;
  { needs: IsoHex private FDynamic +$10, FOpenSides +$14, FSides +$15,
    and resource FDynamicLevel +$34. Preserve the original storage locally. }
  TIsoFields = packed record
    Reserved: array[0..15] of Byte;
    Dynamic: TDynamicIsometricHexagon;
    OpenSides, Sides: Byte;
  end;
  TIsoResourceFields = packed record
    Reserved: array[0..51] of Byte;
    DynamicLevel: Byte;
  end;
  TWaterViewFlags = packed record
    Reserved: array[0..15] of Byte;
    Flags: Byte;
  end;
  PAoWHSMap = ^TAoWHSMap;
  PAoWHSSet = ^TAoWHSSet;
  { needs: Hexagon.THexagon transition fields (+$10..$13) and
    THexagonResource.FTransitionLibrary (+$34) are private in the recovered unit. }
  THexagonFields = packed record
    Reserved: array[0..15] of Byte;
    Transitions: array[0..2] of Byte;
    Sides: Byte;
  end;
  THexagonResourceFields = packed record
    Reserved: array[0..51] of Byte;
    TransitionLibrary: TCustomImageLibrary;
  end;

const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  WorldSet: PAoWHSSet = @AoWE.AoWHSSet;
  SideHN: array[0..2] of Byte = (6, 1, 2);
  SideClear: array[0..2] of Byte = ($F6, $ED, $DB);

procedure TAoWHexagon.NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo);
begin
  if HN = 0 then
    case Info.HN of
      6: UpdateTransition(0);
      1: UpdateTransition(1);
      2: UpdateTransition(2);
    end;
end;

procedure TAoWHexagon.ChangeTerrain(const Msg: HSEngine.THSTerrainInfo);
var
  R: TMapObjectResource;
begin
  if (Msg.HN = 0) and (GetTerrain(0) <> Msg.TerrainType) then
  begin
    R := WorldSet^.HexagonControl.GetRndResource(Msg.TerrainType, FResource.ClassID);
    if R <> nil then
    begin
      SetResource(R);
      UpdateTransitions;
      WorldMap^.InvalidateStaticScene(TMapField(Owner).Xhx,
        TMapField(Owner).Yhx, TMapField(Owner).Lhx);
    end
    else
      FResource.Engine.HSSet.HexagonControl.Place(WorldMap^.MapContainer,
        GetXhx, GetYhx, GetLhx, Msg.TerrainType);
  end;
end;

procedure TAoWHexagon.TerrainChanged(const Msg: HSEngine.THSTerrainInfo);
begin
  if Msg.TerrainType in [0, 6, 14] then
    if Smallint(Msg.TerrainType) <> 14 then
      FResource.Engine.HSSet.HexagonControl.Place(WorldMap^.MapContainer,
        GetXhx, GetYhx, GetLhx, Msg.TerrainType)
    else
      FResource.Engine.HSSet.HexagonControl.Place(WorldMap^.MapContainer,
        GetXhx, GetYhx, GetLhx, 0);
end;

procedure TAoWHexagon.UpdateTransition(Side: Byte);
var
  Shifted: Boolean;
  NXhx, NYhx: Integer;
  MapLevel: TMapLevel;
  NeighbourTerrain, OwnTerrain: Integer;
  IL: TCustomImageLibrary;
  Image: Integer;
begin
  Shifted := False;
  THexagonFields(Pointer(Self)^).Transitions[Side] := 255;
  THexagonFields(Pointer(Self)^).Sides := THexagonFields(Pointer(Self)^).Sides and SideClear[Side];
  MapLevel := TMapLevel(Owner.Owner);
  HNtoHX(SideHN[Side], NXhx, NYhx);
  TranslateHX(0, 0, TMapField(Owner).Xhx, TMapField(Owner).Yhx, NXhx, NYhx, NXhx, NYhx);
  if (NXhx >= 0) and (NYhx >= 0) and (MapLevel.Width > NXhx) and (MapLevel.Height > NYhx) then
  begin
    NeighbourTerrain := MapLevel.GetField(NXhx, NYhx).TerrainType;
    OwnTerrain := GetTerrain(0);
    if (OwnTerrain <> NeighbourTerrain) and (OwnTerrain >= 0) and
      (NeighbourTerrain >= 0) and (NeighbourTerrain <> 8) and (NeighbourTerrain <> 7) and
      (NeighbourTerrain <> 15) and (OwnTerrain <> 15) then
    begin
      if OwnTerrain = 9 then
      begin
        if (NeighbourTerrain = 10) or (NeighbourTerrain = 13) then
          THexagonFields(Pointer(Self)^).Transitions[Side] := Random(3) * 3 + (Side + $B6)
        else if (NeighbourTerrain <> 8) and (NeighbourTerrain <> 7) then
        begin
          THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $93;
          Shifted := True;
        end;
      end
      else if NeighbourTerrain = 9 then
      begin
        if (OwnTerrain = 10) or (OwnTerrain = 13) then
          THexagonFields(Pointer(Self)^).Transitions[Side] := Random(3) * 3 + (Side + $B6)
        else if (OwnTerrain <> 8) and (OwnTerrain <> 7) then
          THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $90;
      end
      else if OwnTerrain = 13 then
      begin
        if NeighbourTerrain = 10 then
          THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $D0
        else
        begin
          THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $D9;
          Shifted := True;
        end;
      end
      else if NeighbourTerrain = 13 then
      begin
        if OwnTerrain = 10 then
        begin
          THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $D3;
          Shifted := True;
        end
        else
          THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $D6;
      end
      else if OwnTerrain = 10 then
      begin
        THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $A3;
        Shifted := True;
      end
      else if NeighbourTerrain = 10 then
        THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $A0
      else if (NeighbourTerrain <> 0) and (NeighbourTerrain <> 6) then
      begin
        if OwnTerrain = 6 then
        begin
          { Original unreachable branch retained: the outer condition excludes terrain 0. }
          if NeighbourTerrain = 0 then
            THexagonFields(Pointer(Self)^).Transitions[Side] := Side + $60
          else
          begin
            THexagonFields(Pointer(Self)^).Transitions[Side] := Byte(NeighbourTerrain shl 4) + 3 + Side;
            Shifted := True;
          end;
        end
        else if OwnTerrain = 0 then
        begin
          THexagonFields(Pointer(Self)^).Transitions[Side] := Side + 3;
          Shifted := True;
        end
        else
          THexagonFields(Pointer(Self)^).Transitions[Side] :=
            Random(3) * 3 + (Byte(OwnTerrain shl 4) + Side + 6);
      end;
    end;
  end;
  if THexagonFields(Pointer(Self)^).Transitions[Side] <> 255 then
  begin
    IL := THexagonResourceFields(Pointer(FResource)^).TransitionLibrary;
    Image := THexagonFields(Pointer(Self)^).Transitions[Side];
    if Image < IL.Count then
      if IL[Image] <> nil then
      begin
        Inc(THexagonFields(Pointer(Self)^).Sides, 1 shl Side);
        if Shifted then Inc(THexagonFields(Pointer(Self)^).Sides, 1 shl (Side + 3));
      end;
  end;
end;

procedure TAoWHexagonResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  if Msg.MsgID = $10014 then
    if FTerrainList.Terrain[0] in [0, 6] then Exit;
  inherited MsgProc(Msg, Sender);
end;

procedure TAoWBorderHexagon.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if (Info.HN = 0) and (WorldMap^ <> nil) and (WorldMap^.FDay = 0) then
    TAoWFieldFlags(Pointer(Info.MapField)^).Flags :=
      TAoWFieldFlags(Pointer(Info.MapField)^).Flags and $FFFFF000;
end;

constructor TAoWWaterHexagon.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAnimationFrame := -1 - Random(20);
  TIsoFields(Pointer(Self)^).Sides := TIsoFields(Pointer(Self)^).Sides or (Random(4) shl 6);
end;

class function TAoWWaterHexagon.ClassID: Integer;
begin Result := $2073D; end;

procedure TAoWWaterHexagon.UpdateTransitions;
var
  Walk: THNWalkData;
  Level: TMapLevel;
  MapField: TMapField;
  HS: THexagonSprite;
begin
  TIsoFields(Pointer(Self)^).OpenSides := 0;
  TIsoFields(Pointer(Self)^).Sides := TIsoFields(Pointer(Self)^).Sides and $C0;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, TMapField(Owner).Xhx, TMapField(Owner).Yhx, 1);
  while Walk.HN <= 6 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      MapField := Level.GetField(Walk.X, Walk.Y);
      HS := MapField.FindOwnedHS(TLowerIsometricHexagon);
      if HS = nil then
      begin
        HS := MapField.FindOwnedHS(TBorderHexagon);
        if HS = nil then
        begin
          TIsoFields(Pointer(Self)^).OpenSides := TIsoFields(Pointer(Self)^).OpenSides or (1 shl (Walk.HN - 1));
          if MapField.TerrainType = 3 then FShoreTerrain[Walk.HN] := 40
          else if MapField.TerrainType = 5 then FShoreTerrain[Walk.HN] := 80
          else FShoreTerrain[Walk.HN] := 0;
        end;
      end
      else if GetTerrain(0) <> MapField.TerrainType then
        TIsoFields(Pointer(Self)^).Sides := TIsoFields(Pointer(Self)^).Sides or (1 shl (Walk.HN - 1));
    end;
    WalkToNextHN(Walk);
  end;
  if TIsoFields(Pointer(Self)^).Dynamic = nil then
    TIsoFields(Pointer(Self)^).Dynamic := DynamicIsometricHexagonClass.Create(TECustomNode(Self));
end;

procedure TAoWWaterHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp, Yhp: Integer;
  IL: TCustomImageLibrary;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  Xhp := Xhp - XhpSurf - 8;
  Yhp := Yhp - YhpSurf;
  IL := FResource.ImageSequenceList.ImageSequences[0].ImageLibrary;
  IL[((Integer(Owner) shr 3) + TMapField(Owner).Xhx + TMapField(Owner).Yhx * 2 +
    (TIsoFields(Pointer(Self)^).Sides shr 6)) and 15 + 140].Show(Xhp, Yhp, SurfaceDesc);
  Dec(Xhp, 6);
  Dec(Yhp, 9);
  if TIsoFields(Pointer(Self)^).Sides and 1 <> 0 then IL[36].Show(Xhp, Yhp, SurfaceDesc);
  if TIsoFields(Pointer(Self)^).Sides and 2 <> 0 then IL[37].Show(Xhp, Yhp, SurfaceDesc);
  if TIsoFields(Pointer(Self)^).Sides and $20 <> 0 then IL[35].Show(Xhp, Yhp, SurfaceDesc);
end;

procedure TAoWWaterHexagon.ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp, Yhp, X, Y: Integer;
  IL: TCustomImageLibrary;
  Variant: Integer;
  Sequence: TImageSequence;
  Image: Integer;
  Showing: Boolean;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  Xhp := Xhp - XhpSurf - 8;
  Yhp := Yhp - YhpSurf;
  { needs: AoWE.AoWEngine global; its resource engine provides the same settings. }
  if (TAoWEngine(FResource.Engine).FAnimationDetail <> 0) and
    ((TAoWMapField(Owner).FFieldFlags and $FF0000 <> 0) or
    (TAbstractAoWHSMap(TMapLevel(Owner.Owner).Map).FFogEnabled = 0)) then
  begin
    Inc(FAnimationFrame);
    if Smallint(FAnimationFrame) >= 0 then
    begin
      Showing := False;
      if Smallint(FAnimationFrame) = 0 then
        if TWaterViewFlags(Pointer(WorldMap^.FPlayerControl)^).Flags and $10 <> 0 then
        begin
          if (TIsoFields(Pointer(Self)^).OpenSides = 0) and (Random(300) = 0) and
            not (msEditting in WorldMap^.Status) then FAnimationIndex := Random(10) + 30
          else if Random(10) < 3 then FAnimationIndex := Random(9) + 50
          else FAnimationIndex := Random(10) + 20;
        end
        else
          if (TIsoFields(Pointer(Self)^).OpenSides = 0) and (Random(700) = 0) and
            not (msEditting in WorldMap^.Status) then FAnimationIndex := Random(10) + 30
          else FAnimationIndex := Random(10) + 20;
      if FAnimationIndex < FResource.ImageSequenceList.Count then
      begin
        Sequence := TImageSequence(FResource.ImageSequenceList.Items[FAnimationIndex]);
        while Sequence <> nil do
        begin
          Image := Sequence.GetUnloopedFrameIndex(FAnimationFrame);
          if Image <> -1 then
          begin
            Showing := True;
            if Sequence.ImageLibrary.ImageExist(Image) then
              Sequence.ImageLibrary[Image].Show(Sequence.dXshift + Xhp, Sequence.dYshift + Yhp, SurfaceDesc);
          end;
          Sequence := Sequence.Next;
        end;
      end;
      if not Showing then
        if TAoWEngine(FResource.Engine).FAnimationDetail = 1 then
          FAnimationFrame := -20 - Random(25)
        else FAnimationFrame := -10 - Random(25);
    end;
  end;
  inherited ShowDynamic(XhpSurf, YhpSurf, SurfaceDesc);
  IL := FResource.ImageSequenceList.ImageSequences[0].ImageLibrary;
  Variant := (Integer(Self) shr 8) and 3;
  if Variant = 3 then Variant := 0;
  if TIsoFields(Pointer(Self)^).OpenSides <> 0 then
  begin
    X := Xhp - 19;
    Y := Yhp - 32;
    if TIsoFields(Pointer(Self)^).OpenSides and 1 <> 0 then
    begin
      if TIsoFields(Pointer(Self)^).OpenSides and $23 = $23 then
        IL[FShoreTerrain[1] + 6].Show(X, Y, SurfaceDesc)
      else if TIsoFields(Pointer(Self)^).OpenSides and $23 = 1 then
        IL[FShoreTerrain[1] + 13].Show(X, Y, SurfaceDesc);
      if TIsoFields(Pointer(Self)^).OpenSides and 7 = 7 then
        IL[FShoreTerrain[2] + 25].Show(X, Y, SurfaceDesc)
      else if TIsoFields(Pointer(Self)^).OpenSides and 3 = 3 then
        IL[Variant + 3 + FShoreTerrain[2]].Show(X, Y, SurfaceDesc);
      if TIsoFields(Pointer(Self)^).OpenSides and $31 = $31 then
        IL[FShoreTerrain[6] + 24].Show(X, Y, SurfaceDesc)
      else if TIsoFields(Pointer(Self)^).OpenSides and $21 = $21 then
        IL[Variant + FShoreTerrain[6]].Show(X, Y, SurfaceDesc);
    end
    else
    begin
      if TIsoFields(Pointer(Self)^).OpenSides and 6 = 6 then
        IL[Variant + 10 + FShoreTerrain[3]].Show(X, Y, SurfaceDesc)
      else if TIsoFields(Pointer(Self)^).OpenSides and 2 = 2 then
        IL[FShoreTerrain[2] + 17].Show(X, Y, SurfaceDesc);
      if TIsoFields(Pointer(Self)^).OpenSides and $30 = $30 then
        IL[Variant + 7 + FShoreTerrain[5]].Show(X, Y, SurfaceDesc)
      else if TIsoFields(Pointer(Self)^).OpenSides and $20 = $20 then
        IL[FShoreTerrain[6] + 16].Show(X, Y, SurfaceDesc);
    end;
    if TIsoFields(Pointer(Self)^).OpenSides and 8 <> 0 then
    begin
      if TIsoFields(Pointer(Self)^).OpenSides and $E = $E then
        IL[FShoreTerrain[3] + 22].Show(X, Y + 1, SurfaceDesc)
      else if TIsoFields(Pointer(Self)^).OpenSides and $C = $C then
        if Variant = 2 then
          IL[FShoreTerrain[3] + 19].Show(X, Y + 1, SurfaceDesc)
        else
          IL[Variant + 30 + FShoreTerrain[3]].Show(X, Y + 1, SurfaceDesc);
      if TIsoFields(Pointer(Self)^).OpenSides and $38 = $38 then
        IL[FShoreTerrain[5] + 21].Show(X, Y, SurfaceDesc)
      else if TIsoFields(Pointer(Self)^).OpenSides and $18 = $18 then
        if Variant = 2 then
          IL[FShoreTerrain[5] + 18].Show(X, Y + 1, SurfaceDesc)
        else
          IL[Variant + 28 + FShoreTerrain[5]].Show(X, Y, SurfaceDesc);
      if TIsoFields(Pointer(Self)^).OpenSides and $1C = 8 then IL[FShoreTerrain[4] + 23].Show(X, Y, SurfaceDesc);
    end
    else if TIsoFields(Pointer(Self)^).OpenSides and $E = 4 then
      IL[FShoreTerrain[3] + 15].Show(X, Y, SurfaceDesc)
    else if TIsoFields(Pointer(Self)^).OpenSides and $38 = $10 then
      IL[FShoreTerrain[5] + 14].Show(X, Y, SurfaceDesc);
  end;
end;

constructor TAoWWaterHexagonResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TIsoResourceFields(Pointer(Self)^).DynamicLevel := 23;
end;

class function TAoWWaterHexagonResource.ClassID: Integer;
begin Result := $2073E; end;

class function TAoWWaterHexagonResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@WaterHexagonRStr)); end;

function TAoWWaterHexagonResource.ResourceUserClassID: Integer;
begin Result := $2073D; end;

procedure RegisterAoWHexagon(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAoWHexagon, TAoWHexagonResource]);
  AEngine.RegisterEClasses([TAoWBorderHexagon, TBorderHexagonResource]);
  AEngine.RegisterEClasses([TAoWWaterHexagon, TAoWWaterHexagonResource]);
  AEngine.RegisterEClasses([TLowerIsometricHexagon, TLowerIsometricHexagonResource]);
end;


initialization
finalization

end.
