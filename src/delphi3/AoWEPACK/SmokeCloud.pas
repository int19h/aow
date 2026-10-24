unit SmokeCloud;

{ SmokeCloud of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

type
  TSmokeCloudEnchantment = class;
  TSmokeCloud = class;
  TSmokeCloudResource = class;


  { TSmokeCloudEnchantment (instance size 40, VMT 5579BF2C): +$24 FCloud. }
  TSmokeCloudEnchantment = class(TGlobalEnchantment)
  public
    FCloud: TSmokeCloud;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetName: string; override;
    function GetLocation: TXYL; override;
    function Deactivate(Player: Byte): Boolean; override;
    function VisibleForPlayer(Player: Shortint): Boolean; override;
  end;

  { TSmokeCloud (instance size 36, VMT 5579C044): +$14 FPlayer, +$18 FTurnsRemaining,
    +$1C FDrifting, +$1D FDirection, +$1E FUpdated, +$1F FVisibleForSeatedPlayer, +$20 FEnchantment. }
  TSmokeCloud = class(TMultiHexMO)
  public
    FPlayer: Shortint;
    FReserved: array[0..2] of Byte;
    FTurnsRemaining: Integer;
    FDrifting: Boolean;
    FDirection: Byte;
    FUpdated: Boolean;
    FVisibleForSeatedPlayer: Boolean;
    FEnchantment: TSmokeCloudEnchantment;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure UpdateConcealment(Xhx, Yhx, Lhx: Shortint);
    procedure UpdateVisibleForSeatedPlayer;
    function ValidMoveDir(Direction: Integer): Boolean;
    procedure UpdateCloud;
  end;

  { TSmokeCloudResource (instance size 68, VMT 5579C1E0) }
  TSmokeCloudResource = class(TMultiHexMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterSmokeCloud(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  PAoWHSSet = ^TAoWHSSet;
  TCloudSpellFields = packed record
    Reserved: array[0..7] of Byte;
    Name: string;
  end;
  TCloudMapFields = packed record
    Reserved: array[0..164] of Byte;
    SeatedPlayer: Byte;
  end;
  TCloudEnchantmentOptions = set of (ce0, ce1, ce2, ce3, ce4, ce5, ce6, ce7);
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  WorldSet: PAoWHSSet = @AoWE.AoWHSSet;



constructor TSmokeCloudEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TCloudEnchantmentOptions(FEnchantmentMode) :=
    TCloudEnchantmentOptions(FEnchantmentMode) - [ce0, ce1];
  FDispelMana := 25;
end;

class function TSmokeCloudEnchantment.ClassID: Integer;
begin Result := $21244; end;

function TSmokeCloudEnchantment.GetName: string;
begin
  { needs: the base GetName parameter is a hidden string result pointer. }
  Result := TCloudSpellFields(Pointer(TSpellControl(WorldSet^.FSpellControl).GetSpell($4A))^).Name;
end;

function TSmokeCloudEnchantment.GetLocation: TXYL;
{ needs: the base GetLocation returns TXYL in EAX, not two Integer parameters.
  Use its proven register ABI until the shared virtual declaration is recovered. }
asm
  PUSH EBX
  PUSH ECX
  MOV EBX,EAX
  MOV EAX,[EBX+$24]
  MOV EDX,[EAX]
  CALL DWORD PTR [EDX+$74]
  MOV [ESP],AL
  MOV EAX,[EBX+$24]
  MOV EDX,[EAX]
  CALL DWORD PTR [EDX+$78]
  MOV [ESP+1],AL
  MOV EAX,[EBX+$24]
  MOV EDX,[EAX]
  CALL DWORD PTR [EDX+$7C]
  MOV [ESP+2],AL
  MOV EAX,[ESP]
  POP EDX
  POP EBX
end;

function TSmokeCloudEnchantment.Deactivate(Player: Byte): Boolean;
{ needs: the base Deactivate returns Integer in EAX and takes no argument. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI,EAX
  TEST BYTE PTR [ESI+$10],1
  JZ @@inactive
  MOV EAX,ESI
  CALL TGlobalEnchantment.Deactivate
  MOV EBX,EAX
  MOV EAX,[ESI+$24]
  TEST BYTE PTR [EAX+$C],$20
  JZ @@done
  CALL TObject.Free
  JMP @@done
@@inactive:
  XOR EBX,EBX
@@done:
  MOV EAX,EBX
  POP ESI
  POP EBX
end;

function TSmokeCloudEnchantment.VisibleForPlayer(Player: Shortint): Boolean;
var
  Walk: THNWalkData;
begin
  Result := FPlayerIndex = Player;
  with Walk do
  begin
    InitHNWalk(Walk, FCloud.Xhx, FCloud.Yhx, 0);
    while not Result and (Radius <= 3) do
    begin
      Result := WorldMap^.VisibleForPlayer(X, Y, FCloud.Lhx, Player);
      WalkToNextHN(Walk);
    end;
  end;
end;

constructor TSmokeCloud.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FEnchantment := TSmokeCloudEnchantment.Create(nil);
  FEnchantment.FCloud := Self;
  FVisibleForSeatedPlayer := False;
  FDrifting := False;
end;

destructor TSmokeCloud.Destroy;
begin
  inherited Destroy;
  FEnchantment.Release;
end;

class function TSmokeCloud.ClassID: Integer;
begin Result := $21242; end;

function TSmokeCloud.GetShowPriority: Integer;
begin Result := inherited GetShowPriority + $0C000000; end;

function TSmokeCloud.CanSelect(Xhp, Yhp: Integer): Boolean;
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

procedure TSmokeCloud.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), 15);
  Stream.rwInteger(FTurnsRemaining, 16);
  Stream.rwBool(FDrifting, 17);
  Stream.rwByte(FDirection, 18);
  Stream.rwEObject(FEnchantment, 19);
end;

procedure TSmokeCloud.UpdateConcealment(Xhx, Yhx, Lhx: Shortint); { Original reloads TerrainList after Army.Update callbacks can replace the resource. } { Unmatched: tried absolute walk view to prevent retained walk base. }
var
  Walk: THNWalkData;
  Level: TMapLevel;
  MapField: TAoWMapField;
  ArmyHS: TArmyHS;
begin
  Level := WorldMap^.MapContainer.MapLevels[Lhx];
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while FResource.TerrainList.Count > Walk.HN do
  begin
    if (FResource.TerrainList.Terrain[Walk.HN] >= -1) and (Walk.X >= 0) and
      (Walk.Y >= 0) and (Walk.X < Level.Width) and (Level.Height > Walk.Y) then
    begin
      MapField := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
      ArmyHS := MapField.GetArmyHS;
      if ArmyHS <> nil then TArmy(ArmyHS.FArmy).Update;
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure TSmokeCloud.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if (Info.HN > 18) and (Info.HN < 37) then
    TAoWMapField(Info.MapField).FFieldFlags :=
      TAoWMapField(Info.MapField).FFieldFlags or $01000000;
end;

procedure TSmokeCloud.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if (Msg.MsgID <> $10) or (msEditting in WorldMap^.Status) then inherited MapFieldMsgProc(Msg);
  if FResource.TerrainList.Terrain[Msg.HN] >= -1 then
    if (Msg.MsgID = $1128) and (moActivated in FStatus) then Msg.Param[0] := 1
    else if Msg.MsgID = $110D then UpdateVisibleForSeatedPlayer;
end;

procedure TSmokeCloud.UpdateVisibleForSeatedPlayer;
var
  Visible: Boolean;
begin
  Visible := WorldMap^.Visible( GetXhx, GetYhx, GetLhx, 3) or
    (FEnchantment.FPlayerIndex = WorldMap^.FSeatedPlayer);
  if FVisibleForSeatedPlayer xor Visible then
  begin
    FVisibleForSeatedPlayer := Visible;
    WorldMap^.FGlobalMagicControl.TriggerChangedEvent;
  end;
end;

function TSmokeCloud.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then UpdateMapFields(TMapLevel(Owner.Owner), FXhx, FYhx);
end;

procedure TSmokeCloud.RemoveFromMap;
var
  Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  inherited RemoveFromMap;
  UpdateMapFields(Level, FXhx, FYhx);
end;

procedure TSmokeCloud.Activate;
begin
  inherited Activate;
  if FDirection = 0 then FDirection := WorldMap^.Random(6) + 1;
  with FEnchantment do
    if (FPlayerIndex > 0) and not (getActivated in FEnchantmentStatus) then
      Activate(FPlayerIndex);
  UpdateConcealment(Xhx, Yhx, Lhx);
  UpdateVisibleForSeatedPlayer;
end;

procedure TSmokeCloud.Deactivate;
begin
  inherited Deactivate;
  if Shortint(FEnchantment.FPlayerIndex) > 0 then
    FEnchantment.Deactivate(FEnchantment.FPlayerIndex);
  UpdateConcealment(GetXhx, GetYhx, GetLhx);
end;

procedure TSmokeCloud.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  if FVisibleForSeatedPlayer or (msEditting in WorldMap^.Status) then
    inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

function TSmokeCloud.ValidMoveDir(Direction: Integer): Boolean;
var
  Xhx, Yhx: Integer;
  Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  CenterHNtoHX(GetXhx, GetYhx, Direction, Xhx, Yhx);
  CenterHNtoHX(Xhx, Yhx, Direction, Xhx, Yhx);
  Result := (Xhx >= 10) and (Yhx >= 10) and (Level.Width >= Xhx + 10) and (Level.Height >= Yhx + 10);
end;

procedure TSmokeCloud.UpdateCloud;
var
  Xhx, Yhx: Integer;
  Directions: TByteList;
  Valid: Boolean;
  Direction, Tries: Integer;
  Lhx: Integer;
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
        Direction := Directions[WorldMap^.Random( Directions.Count)];
        Valid := ValidMoveDir(Direction);
        if not Valid then Directions.Remove(Direction);
      end;
      Directions.Free;
      if not Valid then
      begin
        Tries := 20;
        while not Valid and (Tries <> 0) do
        begin
          Direction := WorldMap^.Random( 6) + 1;
          Valid := ValidMoveDir(Direction);
          Dec(Tries);
        end;
      end;
      if Valid then
      begin
        FDirection := Direction;
        Lhx := GetLhx;
        CenterHNtoHX(GetXhx, GetYhx, Direction, Xhx, Yhx);
              CenterHNtoHX(Xhx, Yhx, Direction, Xhx, Yhx);
        Disconnect;
        UpdateConcealment(FXhx, FYhx, Lhx);
        FXhx := Xhx;
        FYhx := Yhx;
        Owner := WorldMap^.MapContainer.GetField(Xhx, Yhx, Lhx);
        Connect;
        UpdateConcealment(FXhx, FYhx, Lhx);
      end;
    end;
  end
  else Destroy;
end;

procedure TSmokeCloud.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayer) and not FUpdated then
  begin
    UpdateCloud;
    Exit;
  end;
  if (Msg.MsgID = $20020003) and (Msg.Value = FPlayer) then FUpdated := False
  else if Msg.MsgID = $20020009 then UpdateVisibleForSeatedPlayer;
end;

class function TSmokeCloudResource.ClassID: Integer;
begin Result := $21243; end;

class function TSmokeCloudResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@SmokeCloudRStr)); end;

function TSmokeCloudResource.ResourceUserClassID: Integer;
begin Result := $21242; end;

procedure RegisterSmokeCloud(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TSmokeCloud, TSmokeCloudResource, TSmokeCloudEnchantment]);
end;


initialization
finalization

end.
