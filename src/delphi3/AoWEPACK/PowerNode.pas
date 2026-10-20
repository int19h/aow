unit PowerNode;

{ Power nodes of AoWEPACK.dpl: power generation and player magic registration. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TPowerNode = class;
  TPowerNodeResource = class;


  TPowerNodeState = set of (pnsRazed);

  { TPowerNode: size $44; $3C FState, $40 FPowerSource. }
  TPowerNode = class(TPlayerStructure)
  public
    FState: TPowerNodeState;
    FReserved3D: array[0..2] of Byte;
    FPowerSource: TPlayerStructurePowerSource;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    function GetCurrentActivityText: string; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    procedure SetPlayer(Player: Shortint); override;
    function GetPower: Integer; override;
    function GetCombatEventText(Combat: TCombat): string; override;
  end;

  { TPowerNodeResource (instance size 116, VMT 557D027C) }
  TPowerNodeResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterPowerNode(AEngine: TEngine);

implementation

constructor TPowerNode.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPowerSource := TPlayerStructurePowerSource.Create(nil);
  FPowerSource.Setup(Self);
end;

destructor TPowerNode.Destroy;
begin
  inherited Destroy;
  FPowerSource.Free;
end;

class function TPowerNode.ClassID: Integer;
begin Result := $2019A; end;

function TPowerNode.GetPower: Integer;
begin
  if not GetRazed and not GetBuilding then Result := 10
  else Result := 0;
end;

function TPowerNode.GetRazed: Boolean;
begin Result := pnsRazed in FState; end;

procedure TPowerNode.SetRazed(Value: Boolean);
begin
  if Value then
  begin
    SetPlayer(-1);
    FState := FState + [pnsRazed];
  end
  else FState := FState - [pnsRazed];
  FImageIndex := GetTerrainTypeImage(FTerrainType);
end;

procedure TPowerNode.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FState, 1, 20);
end;

function TPowerNode.GetCurrentActivityText: string;
begin Result := Format(TranslateRStr(GeneratingXPowerRStr), [IntToStr(GetPower)]); end;

procedure TPowerNode.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
{ conflict: procedure TPowerNode.UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer); }
var P: Integer;
begin
  case Info.Mode of
    tmAttack:
      if (Info.Player <> FPlayer) and not GetRazed then
      begin
        P := Data.Priority;
        if FPlayer = 0 then P := 50
        else if ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, 0) then
        begin
          P := 50 - AoWHSMap.FPlayers.GetPlayers(Info.Player).FIncome div 2;
          if P < 25 then P := 25;
          if P > 75 then P := 75;
        end;
        if Data.Priority < P then Data.Priority := P;
      end;
  end;
end;

procedure TPowerNode.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
    if moActivated in FStatus then
    begin
      if FPlayer <> -1 then
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.UnregisterPowerSource(FPowerSource);
      inherited SetPlayer(Player);
      if FPlayer <> -1 then
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.RegisterPowerSource(FPowerSource);
    end
    else inherited SetPlayer(Player);
end;

procedure TPowerNode.Activate;
begin
  inherited Activate;
  if FPlayer <> -1 then
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.RegisterPowerSource(FPowerSource);
end;

procedure TPowerNode.Deactivate;
begin
  if FPlayer <> -1 then
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.UnregisterPowerSource(FPowerSource);
  inherited Deactivate;
end;

function TPowerNode.GetCombatEventText(Combat: TCombat): string;
begin
  if (Combat.FCombatResult = crVictory) or (Combat.FCombatResult = crNoDefenders) then
    Result := TranslateRStr(PowerNodeBattleWonRStr)
  else Result := '';
end;

constructor TPowerNodeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := False;
  FClaimed := False;
  FRazeDefenderBudget := 200;
  FRazeable := True;
  FRebuildGold := 50;
  FRebuildDays := 2;
end;

class function TPowerNodeResource.ResourceEditName: string;
begin Result := TranslateRStr(PowerNodeRStr); end;

class function TPowerNodeResource.ClassID: Integer;
begin Result := $2019B; end;

function TPowerNodeResource.ResourceUserClassID: Integer;
begin Result := $2019A; end;

procedure RegisterPowerNode(AEngine: TEngine);
begin AEngine.RegisterEClasses([TPowerNode, TPowerNodeResource]); end;

initialization
finalization
end.
