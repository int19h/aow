unit PoisonC;

{ Poison clouds in AoWEPACK.dpl: map effects, damage and drifting movement. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TPoisonCloud = class;
  TPoisonCloudResource = class;


  { TPoisonCloud (instance size 32, VMT 557CA640): $14 FPlayer,
    $18 FTurnsRemaining, $1C FDrifting, $1D FDirection, $1E FUpdated. }
  TPoisonCloud = class(TMultiHexMO)
  public
    FPlayer: Shortint;
    F_PoisonCloud_15: array[0..2] of Byte;
    FTurnsRemaining: Integer;
    FDrifting: Boolean;
    FDirection: Byte;
    FUpdated: Boolean;
    FReserved1F: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetShowPriority: Integer; override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure UpdateMapFields(Level: TMapLevel; Xhx, Yhx: Integer);
    function CanDoDamage(Units: TUnitList): Boolean;
    procedure ArmyPlaced(ArmyHS: TArmyHS);
    procedure TriggerDamage;
    function ValidMoveDir(Direction: Integer): Boolean;
    procedure UpdateCloud;
  end;

  { TPoisonCloudResource (instance size 68, VMT 557CA7E0) }
  TPoisonCloudResource = class(TMultiHexMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterPoisonCloud(AEngine: TEngine);

implementation

constructor TPoisonCloud.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDrifting := False;
end;

class function TPoisonCloud.ClassID: Integer;
begin Result := $2123F; end;

function TPoisonCloud.GetShowPriority: Integer;
begin Result := inherited GetShowPriority + $0C000000; end;

function TPoisonCloud.CanSelect(Xhp, Yhp: Integer): Boolean;
var
  Xhx, Yhx, HN: Integer;
begin
  if msEditting in FResource.Engine.HSMap.Status then
  begin
    HPtoHX(Xhp, Yhp, Xhx, Yhx);
    HN := dHXtoHN(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhx, Yhx);
    Result := (HN < FResource.TerrainList.Count) and (FResource.TerrainList.Terrain[HN] >= -1);
  end
  else Result := False;
end;

procedure TPoisonCloud.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= -1 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $2000;
end;

function TPoisonCloud.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then UpdateMapFields(TMapLevel(Owner.Owner), GetXhx, GetYhx);
end;

procedure TPoisonCloud.UpdateMapFields(Level: TMapLevel; Xhx, Yhx: Integer);
var
  Walk: THNWalkData;
  Count: Integer;
begin
  Count := FResource.TerrainList.Count;
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Walk.HN <> Count do
  begin
    if (GetTerrain(Walk.HN) >= -1) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      Level.GetField(Walk.X, Walk.Y).UpdateMapField;
    WalkToNextHN(Walk);
  end;
end;

procedure TPoisonCloud.RemoveFromMap;
var Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  inherited RemoveFromMap;
  UpdateMapFields(Level, FXhx, FYhx);
end;

function TPoisonCloud.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if FResource.TerrainList.Terrain[Info.HN] >= -1 then
  begin
    if not CanDoDamage(TMoveControl(Info.Sender).FSettings.FUnits) then Result := 1
    else begin Result := 0; Exit; end;
  end
  else Result := 1;
end;

function TPoisonCloud.CanDoDamage(Units: TUnitList): Boolean;
var I: Integer; AUnit: TAbstractUnit;
begin
  Result := False;
  I := Units.GetCount;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    AUnit := Units.GetUnit(I);
    Result := not (dtPoison in AUnit.GetImmunityTypes) and not AUnit.GetAbilityEnabled(1);
  end;
end;

procedure TPoisonCloud.ArmyPlaced(ArmyHS: TArmyHS);
begin
  if not (msEditting in AoWHSMap.Status) and
    not TAoWMapField(ArmyHS.Owner).GetMagicShieldActive then
    ArmyHS.FArmy.IncommingStorm(stPestilence, 0, ArmyHS.FArmy.FPlayer);
end;

procedure TPoisonCloud.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), 15);
  Stream.rwInteger(FTurnsRemaining, 16);
  Stream.rwBool(FDrifting, 17);
  Stream.rwByte(FDirection, 18);
end;

procedure TPoisonCloud.TriggerDamage;
var
  Msg: TMapFieldMsg;
  Walk: THNWalkData;
  Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, GetXhx, GetYhx, 0);
  Msg.MsgID := $1150;
  Msg.Param[0] := Ord(stPestilence);
  Msg.Param[2] := FPlayer;
  with Walk do
  while FResource.TerrainList.Count > HN do
  begin
    if (FResource.TerrainList.GetTerrain(HN) >= -1) and (X >= 0) and (Y >= 0) and
      (X < Level.Width) and (Level.Height > Y) then
    begin
      Msg.Param[1] := Radius;
      Level.GetField(X, Y).SendMapFieldMsg(Msg);
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure TPoisonCloud.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if (Msg.MsgID <> $10) or (msEditting in AoWHSMap.Status) then
    inherited MapFieldMsgProc(Msg);
  if FResource.TerrainList.Terrain[Msg.HN] >= -1 then
  begin
    if Msg.MsgID = $1142 then ArmyPlaced(TArmyHS(Msg.Param[0]))
    else if Msg.MsgID = $1120 then
    begin
      if not (dtPoison in TArmyHS(Msg.Param[0]).FArmy.ImmunityTypes($FF)) then Msg.Result := 1;
    end
    else if Msg.MsgID = $1150 then
      if (Byte(Msg.Param[0]) = 1) and (Msg.Param[1] = 0) and (Msg.HN = 0) then Destroy;
  end;
end;

procedure TPoisonCloud.Activate;
begin
  inherited Activate;
  if FDirection = 0 then FDirection := AoWHSMap.Random(6) + 1;
end;

function TPoisonCloud.ValidMoveDir(Direction: Integer): Boolean;
var
  Xhx, Yhx: Integer;
  Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  CenterHNtoHX(GetXhx, GetYhx, Direction, Xhx, Yhx);
  CenterHNtoHX(Xhx, Yhx, Direction, Xhx, Yhx);
  Result := (Xhx >= 10) and (Yhx >= 10) and
    (Xhx + 10 <= Level.Width) and (Yhx + 10 <= Level.Height);
end;

procedure TPoisonCloud.UpdateCloud;
var
  Xhx, Yhx: Integer;
  Directions: TByteList;
  Valid: Boolean;
  Direction, Tries: Integer;
  Lhx, OldXhx, OldYhx: Integer;
begin
  if FTurnsRemaining <> 1 then
  begin
    FUpdated := True;
    if FTurnsRemaining <> 0 then Dec(FTurnsRemaining);
    if FDrifting then
    begin
      Direction := 0;
      Directions := TByteList.Create;
      Valid := False;
      Directions.Add(FDirection);
      if FDirection <> 1 then Directions.Add(FDirection - 1) else Directions.Add(6);
      if FDirection <> 6 then Directions.Add(FDirection + 1) else Directions.Add(1);
      while (Directions.Count <> 0) and not Valid do
      begin
        Direction := Directions[AoWHSMap.Random(Directions.Count)];
        Valid := ValidMoveDir(Direction);
        if not Valid then Directions.Remove(Direction);
      end;
      Directions.Free;
      if not Valid then
      begin
        Tries := 20;
        while not Valid and (Tries <> 0) do
        begin
          Direction := AoWHSMap.Random(6) + 1;
          Valid := ValidMoveDir(Direction);
          Dec(Tries);
        end;
      end;
      if Valid then
      begin
        OldXhx := GetXhx;
        OldYhx := GetYhx;
        FDirection := Direction;
        Lhx := GetLhx;
        CenterHNtoHX(GetXhx, GetYhx, Direction, Xhx, Yhx);
        CenterHNtoHX(Xhx, Yhx, Direction, Xhx, Yhx);
        Disconnect;
        UpdateMapFields(AoWHSMap.MapContainer.GetMapLevel(Lhx), OldXhx, OldYhx);
        FXhx := Xhx;
        FYhx := Yhx;
        Owner := AoWHSMap.MapContainer.GetField(Xhx, Yhx, Lhx);
        Connect;
        UpdateMapFields(AoWHSMap.MapContainer.GetMapLevel(Lhx), Xhx, Yhx);
      end;
    end;
    TriggerDamage;
  end
  else Destroy;
end;

procedure TPoisonCloud.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayer) and not FUpdated then
  begin
    UpdateCloud;
    Exit;
  end;
  if (Msg.MsgID = $20020003) and (Msg.Value = FPlayer) then FUpdated := False;
end;

class function TPoisonCloudResource.ClassID: Integer;
begin Result := $21240; end;

class function TPoisonCloudResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@PoisonCloudRStr)); end;

function TPoisonCloudResource.ResourceUserClassID: Integer;
begin Result := $2123F; end;

procedure RegisterPoisonCloud(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TPoisonCloud, TPoisonCloudResource]);
end;

initialization
finalization

end.
