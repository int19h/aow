unit Tower;

{ Watchtowers and their construction control in AoWEPACK.dpl. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

type
  TTowerState = set of (tsRazed);
  TTower = class;
  TTowerResource = class;
  TTowerConstructionControl = class;


  { TTower (instance size 64, VMT 557C31A8): $3C FState, bit 0 razed. }
  TTower = class(TPlayerStructure)
  public
    FState: TTowerState;
    F_Tower_3D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    function VisibilityRange: Integer; override;
    function GetDefaultAITargetPriority: Integer; override;
  end;

  { TTowerResource (instance size 116, VMT 557C3434): no additional fields. }
  TTowerResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TTowerConstructionControl (instance size 8, VMT 557C352C) }
  TTowerConstructionControl = class(TStructureConstructionControl)
  public
    procedure GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer); override;
    function CanConstruct(A1: TAbstractUnit; var A2: string): Boolean; override;
    class function ID: Integer; override;
    function StructureResource(AUnit: TAbstractUnit): TStructureResource; override;
    { conflict: function StructureResource: TStructureResource; override; }
  end;

procedure RegisterTower(AEngine: TEngine);

implementation

class function TTower.ClassID: Integer;
begin Result := $2043E; end;

function TTower.VisibilityRange: Integer;
begin
  if not GetBuilding then
  begin
    Result := 12;
    if (GetLhx <> 0) or ((FPlayer > 0) and
      (Byte(AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FEnemyEnchantments) and 8 <> 0)) then
      Result := (Result + 1) shr 1;
  end
  else Result := 4;
end;

function TTower.GetDefaultAITargetPriority: Integer;
begin Result := 1; end;

procedure TTower.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
begin
  inherited UpdateAITarget(Info, Data);
  if not (tsRazed in FState) then
    case Info.Mode of
      tmFortify: if Info.Player = FPlayer then Data.Priority := 50;
    end;
end;

function TTower.GetRazed: Boolean;
begin Result := tsRazed in FState; end;

procedure TTower.SetRazed(Value: Boolean);
begin
  if Value then
  begin
    SetPlayer(-1);
    FState := FState + [tsRazed];
  end
  else FState := FState - [tsRazed];
  FImageIndex := GetTerrainTypeImage(FTerrainType);
end;

procedure TTower.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FState, 1, 20);
end;

procedure TTower.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if (FResource.TerrainList.Terrain[Msg.HN] >= 0) and (Msg.MsgID = $1123) and
    (TMapField(Msg.Param[0]).FindNoneTransparentHS(TTower) = Self) and
    not GetBuilding and not GetRazed then Msg.Result := 2;
end;

constructor TTowerResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := True;
  FClaimed := False;
  FRazeable := True;
  FRazeDefenderBudget := 50;
  FRebuildGold := 25;
  FRebuildDays := 2;
end;

class function TTowerResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@TowerRStr)); end;

class function TTowerResource.ClassID: Integer;
begin Result := $2043F; end;

function TTowerResource.ResourceUserClassID: Integer;
begin Result := $2043E; end;

class function TTowerConstructionControl.ID: Integer;
begin Result := 3; end;

function TTowerConstructionControl.StructureResource(AUnit: TAbstractUnit): TStructureResource;
{ conflict: function TTowerConstructionControl.StructureResource: TStructureResource; }
begin
  Result := TStructureResource(AoWHSSet.MapObjectResourceList.FindChild($2043F));
end;

procedure TTowerConstructionControl.GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer);
begin
  Text := SysUtils.Format(TranslateRStr(LoadResString(@BuildXRStr)), [TranslateRStr(LoadResString(@TowerRStr))]);
  Gold := 50;
  Days := 2;
end;

function TTowerConstructionControl.CanConstruct(A1: TAbstractUnit; var A2: string): Boolean;
var Xhx, Yhx, Lhx: Shortint;
begin
  A1.GetLocation(Xhx, Yhx, Lhx);
  if Lhx = 0 then Result := inherited CanConstruct(A1, A2)
  else
  begin
    Result := False;
    A2 := SysUtils.Format(TranslateRStr(LoadResString(@CannotBuildXInUndergroundRStr)),
      [TranslateRStr(LoadResString(@TowerRStr))]);
  end;
end;

procedure RegisterTower(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TTower, TTowerResource]);
  TConstructAbility(AoWHSSet.FAbilityControl.GetAbility($7D)).RegisterConstructionControl(
    TTowerConstructionControl.Create(nil));
end;

initialization
finalization

end.
