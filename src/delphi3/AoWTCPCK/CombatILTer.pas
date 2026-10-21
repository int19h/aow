unit CombatILTer;

{ Combat image library terrain and its visible shadow, recovered from AoWTCPCK.dpl. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TCombatILTerrainShadow = class;
  TCombatILTerrain = class;
  TCombatILTerrainResource = class;
  TCombatFixedILTerrain = class;
  TCombatFixedILTerrainResource = class;


  { TCombatILTerrainShadow (instance size 12, VMT 004041E4) }
  TCombatILTerrainShadow = class(THexagonSprite)
  public
    FTerrain: TCombatILTerrain; { $08 }
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TCombatILTerrain (instance size 32, VMT 00404378) }
  TCombatILTerrain = class(TILTerrainMO)
  public
    FShadow: TCombatILTerrainShadow; { $1C }
    destructor Destroy; override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean; override;
    procedure ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); virtual; { +138 }
    function GetDefense: ShortInt;
    function GetBurnValue: ShortInt;
    procedure DestroyShadow;
    procedure CreateShadow;
  end;

  { TCombatILTerrainResource (instance size 72, VMT 00404538) }
  TCombatILTerrainResource = class(TILTerrainMOR)
  public
    FBurnValue: ShortInt; { $44 }
    FDefense: ShortInt; { $45 }
    F_CombatILTerrainResource_46: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TCombatFixedILTerrain (instance size 32, VMT 00404644) }
  TCombatFixedILTerrain = class(TCombatILTerrain)
  public
    class function ClassID: Integer; override;
    function CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean; override;
    procedure ChangeTerrain(const Info: HSEngine.THSTerrainInfo); override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    function ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt; override;
  end;

  { TCombatFixedILTerrainResource (instance size 72, VMT 0040480C) }
  TCombatFixedILTerrainResource = class(TCombatILTerrainResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCombatILTerrain(AEngine: TEngine);

implementation

function TCombatILTerrainShadow.GetShowPriority: Integer;
begin
  Result := (FTerrain.GetShowPriority and $03FFFFFF) - $64000000;
end;

function TCombatILTerrain.GetDefense: ShortInt;
begin Result := TCombatILTerrainResource(FResource).FDefense; end;

function TCombatILTerrain.GetBurnValue: ShortInt;
begin Result := TCombatILTerrainResource(FResource).FBurnValue; end;

function TCombatILTerrain.CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean;
begin Result := inherited CanPlaceOnHS(HS) or (HS is TAbstractRoad); end;

procedure TCombatILTerrainShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin FTerrain.ShowShadow(XhpSurf, YhpSurf, SurfaceDesc); end;

destructor TCombatILTerrain.Destroy;
begin
  DestroyShadow;
  inherited Destroy;
end;

class function TCombatILTerrain.ClassID: Integer;
begin Result := $220136; end;

procedure TCombatILTerrain.ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  FResource.ShowComplexImage(XhpSurf, YhpSurf, SurfaceDesc, 40,
    TMapField(Owner).Xhx + TMapField(Owner).Yhx shl 4);
end;

procedure TCombatILTerrain.DestroyShadow;
begin
  if FShadow <> nil then
  begin
    if GetVisible then FResource.Engine.HSMap.DynamicVisibleHS.RemoveChild(FShadow);
    FShadow.Free;
    FShadow := nil;
  end;
end;

procedure TCombatILTerrain.CreateShadow;
begin
  if FResource.ImageSequenceList.GetImageSequence(40) <> nil then
  begin
    if FShadow <> nil then DestroyShadow;
    if (AoWHSMap = nil) or AoWHSMap.FShowUnitShadows then
    begin
      FShadow := TCombatILTerrainShadow.Create(nil);
      FShadow.FTerrain := Self;
    end;
  end;
end;

procedure TCombatILTerrain.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  if not (moVisible in FStatus) then
  begin
    inherited MakeVisible(VisibilityList);
    if FShadow <> nil then
      VisibilityList.AddSortChild(FShadow, FShadow.GetShowPriority);
  end;
end;

procedure TCombatILTerrain.Activate;
begin
  inherited Activate;
  CreateShadow;
end;

procedure TCombatILTerrain.Deactivate;
begin
  DestroyShadow;
  inherited Deactivate;
end;

function TCombatILTerrain.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

procedure TCombatILTerrain.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $21001 then
    if FResource.TerrainList.GetTerrain(Msg.HN) >= 0 then
      if Msg.Param[0] < TCombatILTerrainResource(FResource).FDefense then
        Msg.Param[0] := TCombatILTerrainResource(FResource).FDefense;
end;

class function TCombatILTerrainResource.ClassID: Integer;
begin Result := $220137; end;

class function TCombatILTerrainResource.ResourceEditName: string;
begin Result := 'Combat ILTerrain'; end;

procedure TCombatILTerrainResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FDefense), 20);
  Stream.rwByte(Byte(FBurnValue), 21);
end;

function TCombatILTerrainResource.ResourceUserClassID: Integer;
begin Result := $220136; end;

class function TCombatFixedILTerrain.ClassID: Integer;
begin Result := $220138; end;

function TCombatFixedILTerrain.ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin Result := -1; end;

function TCombatFixedILTerrain.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    Result := ValidTerrainType(Info.MapField.TerrainType) and
      (GetMostFrequentMapFieldTerrainType(TMapLevel(Owner.Owner), FXhx, FYhx,
      FResource.TerrainList.GetTerrain(Info.HN)) = Info.MapField.TerrainType)
  else Result := True;
end;

procedure TCombatFixedILTerrain.ChangeTerrain(const Info: HSEngine.THSTerrainInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    if ValidTerrainType(Info.TerrainType) then
    begin
      FTerrainType := Info.TerrainType;
      FImageIndex := GetTerrainTypeImage(Info.TerrainType);
    end;
end;

procedure TCombatFixedILTerrain.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    if ValidTerrainType(Info.TerrainType) then
    begin
      FTerrainType := Info.TerrainType;
      FImageIndex := GetTerrainTypeImage(Info.TerrainType);
    end
    else raise Exception.Create('TILFixedTerrain Failure');
end;

class function TCombatFixedILTerrainResource.ClassID: Integer;
begin Result := $220139; end;

class function TCombatFixedILTerrainResource.ResourceEditName: string;
begin Result := 'Combat FixedILTerrain'; end;

function TCombatFixedILTerrainResource.ResourceUserClassID: Integer;
begin Result := $220138; end;

procedure RegisterCombatILTerrain(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCombatILTerrain, TCombatILTerrainResource,
    TCombatFixedILTerrain, TCombatFixedILTerrainResource]);
end;

initialization
finalization

end.
