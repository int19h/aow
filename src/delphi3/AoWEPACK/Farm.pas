unit Farm;

{ Farm, from AoWEPACK.dpl. Recovered farm and resource bodies at their original layouts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Crops, AoWE;

type
  TFarm = class;
  TFarmResource = class;

  TFarmMode = set of (fmRazed); { ot=1 }

  { TFarm (instance size 72, VMT 557B281C): $44 FMode. }
  TFarm = class(TPlayerCropStructure)
  public
    FMode: TFarmMode; { $44 }
    F_Farm_45: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    function GetCurrentActivityText: string; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    function CanPlaceCrop(Field: TMapField): Boolean; override;
    function CropsEnabled: Boolean; override;
    procedure UpdateCrops; override;
  end;

  { TFarmResource (instance size 120, VMT 557B2AC4) }
  TFarmResource = class(TPlayerCropStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

function FarmIncome(Player: Shortint): Integer;
procedure RegisterFarm(Engine: TEngine);

implementation

type
  PAoWMap = ^TAoWHSMap;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
  FarmText: PResStringRec = @AoWE.FarmRStr;
  IncomeText: PResStringRec = @AoWE.ProducingXIncomeRStr;

class function TFarm.ClassID: Integer;
begin
  Result := $2036E;
end;

function TFarm.GetRazed: Boolean;
begin
  Result := fmRazed in FMode;
end;

procedure TFarm.SetRazed(Value: Boolean);
begin
  if Value then
  begin
    SetPlayer(-1);
    FMode := FMode + [fmRazed];
  end
  else FMode := FMode - [fmRazed];
  UpdateCrops;
  FImageIndex := GetTerrainTypeImage(FTerrainType);
end;

function TFarm.GetCurrentActivityText: string;
begin
  Result := SysUtils.Format(TranslateRStr(LoadResString(IncomeText)), [IntToStr(GetIncome)]);
end;

procedure TFarm.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FMode, SizeOf(FMode), $14);
end;

function TFarm.CropsEnabled: Boolean;
begin
  Result := inherited CropsEnabled and (SmallInt(FTerrainType) <> 5);
end;

function TFarm.CanPlaceCrop(Field: TMapField): Boolean;
begin
  Result := (SmallInt(Field.TerrainType) <> 5) and inherited CanPlaceCrop(Field);
end;

procedure TFarm.UpdateCrops;
var Count: Integer;
begin
  if not GetEditMode and (moActivated in FStatus) then
  begin
    if GetRazed or (SmallInt(FTerrainType) = 5) then Count := 0
    else if msEditting in WorldMap^.Status then Count := TFarmResource(FResource).FCropLocations.Count
    else Count := -1;
    if Count <> -1 then SetCropCount(Count);
    UpdateCropSettings;
    UpdateIncome;
  end;
end;

procedure TFarm.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
var Priority: Integer;
begin
  if not GetRazed or GetBuilding then
    case Info.Mode of tmAttack:
      if (Info.Player <> FPlayer) and not GetRazed then
      begin
        Priority := Data.Priority;
        if FPlayer = 0 then Priority := 50
        else if ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, 0) then
        begin
          Priority := 50 - WorldMap^.FPlayers.GetPlayers(Info.Player).FIncome div 2;
          if Priority < 25 then Priority := 25;
          if Priority > 75 then Priority := 75;
        end;
        if Priority > Data.Priority then Data.Priority := Priority;
      end; end;
end;

procedure TFarm.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  inherited TerrainChanged(Info);
  if Info.HN = 0 then UpdateCrops;
end;

constructor TFarmResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FClaimed := False;
  FRazeable := True;
  FRazeDefenderBudget := 50;
  FRebuildGold := 25;
  FRebuildDays := 2;
end;

class function TFarmResource.ResourceEditName: string;
begin
  Result := TranslateRStr(LoadResString(FarmText));
end;

class function TFarmResource.ClassID: Integer;
begin
  Result := $2036F;
end;

function TFarmResource.ResourceUserClassID: Integer;
begin
  Result := $2036E;
end;

function FarmIncome(Player: Shortint): Integer;
var P: TPlayer; I: Integer; Structure: TPlayerStructure;
begin
  if TAoWHSMap(Pointer(WorldMap)^) <> nil then
  begin
    P := WorldMap^.FPlayers.GetPlayers(Player);
    Result := 0;
    for I := 0 to P.FStructures.Count - 1 do
    begin
      Structure := P.FStructures.GetStructure(I);
      if (Structure.ClassID = $2036E) and (Structure.FPlayer = Player) then Inc(Result, TFarm(Structure).FIncome);
    end;
  end
  else Result := -1;
end;

procedure RegisterFarm(Engine: TEngine);
begin
  Engine.RegisterEClasses([TFarm, TFarmResource]);
end;


initialization
finalization

end.
