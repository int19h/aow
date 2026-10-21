unit Gems;

{ Gold pickups of AoWEPACK.dpl, including generation and collection events. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  PAITargetInfo = ^TAITargetInfo;
  TGems = class;
  TGemsResource = class;

  TGemsGenerateMode = (gmUserDefined, gmLow, gmNormal, gmHigh, gmRandom);  { ot=1 }

  { TGems (instance size 36, VMT 557C4D54): $1C FAmount, $20 FGenerateMode. }
  TGems = class(TILTerrainMO)
  public
    FAmount: Integer;
    FGenerateMode: TGemsGenerateMode;
    F_Gems_21: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure GenerateGemsAmount;
    procedure UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer);
    procedure ArmyEntered(ArmyHS: TArmyHS);
  end;

  { TGemsResource (instance size 68, VMT 557C4EF0): no additional fields. }
  TGemsResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterGems(AEngine: TEngine);

implementation

constructor TGems.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FGenerateMode := gmNormal;
  FAmount := 0;
end;

class function TGems.ClassID: Integer;
begin Result := $203AE; end;

procedure TGems.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAmount, 5);
  Stream.rwData(FGenerateMode, 1, 6);
end;

procedure TGems.GenerateGemsAmount;
begin
  if FGenerateMode = gmRandom then
    FGenerateMode := TGemsGenerateMode(AoWHSMap.Random(3) + 1);
  case FGenerateMode of
    gmLow: FAmount := AoWHSMap.Random(25) + 25;
    gmNormal: FAmount := AoWHSMap.Random(25) + 50;
    gmHigh: FAmount := AoWHSMap.Random(50) + 100;
  end;
end;

procedure TGems.UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer);
var Value: Integer;
begin
  case Info.Mode of
    tmAttack..tmAttack:
      if Info.Player <> 0 then
      begin
        Value := FAmount div 5 + 15;
        if Value > Priority then Priority := Value;
      end;
  end;
end;

procedure TGems.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if Info.HN = 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $08000000;
end;

procedure TGems.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020001) and (AoWHSMap.FDay = 1) then GenerateGemsAmount;
end;

procedure TGems.ArmyEntered(ArmyHS: TArmyHS);
var Event: TLocationTextEventLog;
begin
  if ArmyHS.FArmy.FPlayer <> 0 then
  begin
    if (AoWHSMap.FSeatedPlayer = ArmyHS.FArmy.FPlayer) or
      AoWHSMap.Watching(GetXhx, GetYhx, GetLhx, 0) then
      PlaySample('SFX\EVENTS\GOLD.WAV');
    with AoWHSMap.FPlayers.GetPlayers(ArmyHS.FArmy.FPlayer) do
      SetGems(FGems + FAmount);
    Event := TLocationTextEventLog.Create(nil);
    Event.FPlayer := ArmyHS.FArmy.FPlayer;
    Event.FText := SysUtils.Format(TranslateRStr(LoadResString(@GoldFoundRStr)), [IntToStr(FAmount)]);
    Event.SetLocation(GetXhx, GetYhx, GetLhx);
    AoWHSMap.FPlayers.GetPlayers(ArmyHS.FArmy.FPlayer).FEventLogbook.AddEvent(Event);
    Event.Release;
    Destroy;
  end;
end;

procedure TGems.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); { Near miss: three variants retain a different AI-info argument load. }
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1102 then
  begin
    ArmyEntered(TArmyHS(Msg.Param[0]));
    Exit;
  end;
  if (Msg.MsgID = $1200) and (Msg.HN = 0) then
  begin
    UpdateAITarget(PAITargetInfo(Msg.Param[0])^, PInteger(Msg.Param[1])^);
    if PInteger(Msg.Param[1])^ < 0 then Msg.Result := 1;
  end;
end;

class function TGemsResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@GoldRStr)); end;

class function TGemsResource.ClassID: Integer;
begin Result := $203AF; end;

function TGemsResource.ResourceUserClassID: Integer;
begin Result := $203AE; end;

procedure RegisterGems(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TGems, TGemsResource]);
end;


initialization
finalization

end.
