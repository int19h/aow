unit House;

{ Combat houses, recovered from AoWTCPCK.dpl. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatStructure;

type
  THouse = class;
  THouseResource = class;


  { THouse (instance size 48, VMT 00434584) }
  THouse = class(TCombatStructure)
  public
    FRace: Integer; { $28 }
    FFlagID: Integer; { $2C }
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
  end;

  { THouseResource (instance size 72, VMT 00434728) }
  THouseResource = class(TCombatStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterHouse(AEngine: TEngine);

implementation

uses AoWE, City, AoWTC;

class function THouse.ClassID: Integer;
begin Result := $220512; end;

procedure THouse.Activate;
var
  Structure: TPlayerStructure;
begin
  inherited Activate;
  if not (msEditting in AoWCombatMap.Status) then
  begin
    Structure := TPlayerStructure(AoWHSMap.MapContainer.GetMapLevel(CombatLLoc).
      GetField(CombatXLoc, CombatYLoc).FindNoneTransparentHS(TPlayerStructure));
    if Structure <> nil then
    begin
      if Structure is TCity then FRace := TCity(Structure).FRace
      else FRace := 0;
      if Structure.FPlayer = -1 then FFlagID := -1
      else FFlagID := AoWHSMap.FPlayers.GetPlayers(Structure.FPlayer).FPlayerRace;
      if FFlagID = -1 then FFlagID := 32;
    end;
  end;
end;

procedure THouse.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  ImageIndex, Xhp, Yhp, TerrainOffset: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  if FHitPoints = 0 then
  begin
    Sequence := AoWHSSet.FImageSequences.GetImageSequence(50);
    case AoWCombatMap.MapContainer.GetMapLevel(0).GetField(GetXhx, GetYhx).TerrainType of
      3: TerrainOffset := 1;
      5, 7, 12: TerrainOffset := 2;
    else TerrainOffset := 0;
    end;
    if Sequence <> nil then
      repeat
        ImageIndex := Sequence.GetUnloopedFrameIndex(Integer(Self) mod 3 + TerrainOffset * 3);
        if ImageIndex <> -1 then
          Sequence.ImageLibrary[ImageIndex].Show(
            XhpSurf + Sequence.dXshift + 16, YhpSurf + Sequence.dYshift + 16, SurfaceDesc);
        Sequence := Sequence.Next;
      until Sequence = nil;
  end
  else
  begin
    case AoWCombatMap.MapContainer.GetMapLevel(0).GetField(GetXhx, GetYhx).TerrainType of
      3: TerrainOffset := 20;
      5, 7, 12: TerrainOffset := 40;
    else TerrainOffset := 0;
    end;
    Sequence := FResource.ImageSequenceList.GetImageSequence(TerrainOffset + FRace);
    if Sequence <> nil then
      repeat
        case Sequence.Layer of
          7:
            begin
              ImageIndex := Sequence.GetFrameIndex(AoWCombatMap.Frame, (Integer(Self) shr 2) and $FFFF);
              if ImageIndex <> -1 then
                if not (msEditting in AoWCombatMap.Status) then
                  AoWHSSet.FFlagControl.ShowStructureFlagEx(
                    XhpSurf + 21 + Sequence.dXshift, YhpSurf + Sequence.dYshift + 16,
                    GetXhx + AoWHSMap.Frame + GetYhx * 100, FFlagID, SurfaceDesc, False);
            end;
        else
          begin
            ImageIndex := Sequence.GetFrameIndex(AoWCombatMap.Frame, (Integer(Self) shr 2) and $FFFF);
            if ImageIndex <> -1 then
              Sequence.ImageLibrary[ImageIndex].Show(
                XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift, SurfaceDesc);
          end;
        end;
        Sequence := Sequence.Next;
      until Sequence = nil;
  end;
end;

procedure THouse.ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Sequence: TImageSequence;
  ImageIndex, Xhp, Yhp: Integer;
begin
  if FHitPoints > 0 then
  begin
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    XhpSurf := Xhp - XhpSurf;
    YhpSurf := Yhp - YhpSurf;
    Sequence := FResource.ImageSequenceList.GetImageSequence(FRace + 60);
    if Sequence <> nil then
      repeat
        ImageIndex := Sequence.GetFrameIndex(AoWCombatMap.Frame, (Integer(Self) shr 2) and $FFFF);
        if ImageIndex <> -1 then
          Sequence.ImageLibrary[ImageIndex].Show(
            XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift, SurfaceDesc);
        Sequence := Sequence.Next;
      until Sequence = nil;
  end;
end;

class function THouseResource.ClassID: Integer;
begin Result := $220513; end;

class function THouseResource.ResourceEditName: string;
begin Result := 'Combat House'; end;

function THouseResource.ResourceUserClassID: Integer;
begin Result := $220512; end;

procedure RegisterHouse(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([THouseResource, THouse]);
end;

initialization
finalization

end.
