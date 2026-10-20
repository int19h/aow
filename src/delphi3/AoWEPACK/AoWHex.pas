unit AoWHex;

{ Draft declarations of AoWHex, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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

  { TAoWWaterHexagon (instance size 32, VMT 5579A5F8) }
  TAoWWaterHexagon = class(TLowerIsometricHexagon)
  public
    F_AoWWaterHexagon_18: Byte;
    F_AoWWaterHexagon_19: Byte;
    F_AoWWaterHexagon_1A: Byte;
    F_AoWWaterHexagon_1B: Byte;
    F_AoWWaterHexagon_1C: Byte;
    F_AoWWaterHexagon_1D: Byte;
    F_AoWWaterHexagon_1E: Byte;
    F_AoWWaterHexagon_1F: Byte;
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

procedure RegisterAoWHexagon(A1: Integer);  { draft }

implementation

type
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
    { needs: AoWE.AoWHSSet ($558E92E8) and AoWHSMap ($558E9494).
      Use the resource engine's set and map until P1 provides those globals. }
    R := FResource.Engine.HSSet.HexagonControl.GetRndResource(Msg.TerrainType, FResource.ClassID);
    if R <> nil then
    begin
      SetResource(R);
      UpdateTransitions;
      FResource.Engine.HSMap.InvalidateStaticScene(TMapField(Owner).Xhx,
        TMapField(Owner).Yhx, TMapField(Owner).Lhx);
    end
    else
      FResource.Engine.HSSet.HexagonControl.Place(FResource.Engine.HSMap.MapContainer,
        GetXhx, GetYhx, GetLhx, Msg.TerrainType);
  end;
end;

procedure TAoWHexagon.TerrainChanged(const Msg: HSEngine.THSTerrainInfo);
begin
  if Msg.TerrainType in [0, 6, 14] then
    { needs: AoWE.AoWHSMap ($558E9494); use the resource engine's map. }
    if Smallint(Msg.TerrainType) <> 14 then
      FResource.Engine.HSSet.HexagonControl.Place(FResource.Engine.HSMap.MapContainer,
        GetXhx, GetYhx, GetLhx, Msg.TerrainType)
    else
      FResource.Engine.HSSet.HexagonControl.Place(FResource.Engine.HSMap.MapContainer,
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
begin end;

procedure TAoWBorderHexagon.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

constructor TAoWWaterHexagon.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAoWWaterHexagon.ClassID: Integer;
begin Result := 0; end;

procedure TAoWWaterHexagon.UpdateTransitions;
begin end;

procedure TAoWWaterHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TAoWWaterHexagon.ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TAoWWaterHexagonResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAoWWaterHexagonResource.ClassID: Integer;
begin Result := 0; end;

class function TAoWWaterHexagonResource.ResourceEditName: string;
begin Result := ''; end;

function TAoWWaterHexagonResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAoWHexagon(A1: Integer);
begin end;


initialization
finalization

end.
