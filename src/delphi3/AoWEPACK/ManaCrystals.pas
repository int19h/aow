unit ManaCrystals;

{ ManaCrystals of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, EventLog, AoWE;

type
  TCrystalAIInfo = packed record
    Player, OtherPlayer: Shortint;
    Kind: Byte;
  end;
  PCrystalAIInfo = ^TCrystalAIInfo;
  TManaCrystals = class;
  TManaCrystalsResource = class;


  { TManaCrystals (instance size 36, VMT 557B494C): +$1C FAmount, +$20 FSize. }
  TManaCrystals = class(TILTerrainMO)
  public
    FAmount: Integer;
    FSize: Byte;
    F_ManaCrystals_21: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure GenerateManaCrystalsAmount;
    procedure UpdateAITarget(var Info: TCrystalAIInfo; var Priority: Integer);
    procedure ArmyEntered(ArmyHS: TArmyHS);
  end;

  { TManaCrystalsResource (instance size 68, VMT 557B4B00) }
  TManaCrystalsResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterManaCrystals(AEngine: TEngine);

implementation

type
  TCrystalLog = class(TLocationTextEventLog)
    procedure Location(X, Y, L: Shortint);
  end;
  TCrystalMagic = class(TPlayerMagicControl)
    property Mana: Integer read FMana write SetMana;
  end;
  PCrystalMap = ^TAoWHSMap;
  TCrystalMapFields = packed record
    Reserved: array[0..164] of Byte;
    SeatedPlayer: Shortint;
  end;
  TCrystalFieldFlags = packed record
    Reserved: array[0..23] of Byte;
    Flags: Integer;
  end;
const WorldMap: PCrystalMap = @AoWE.AoWHSMap;
{ needs: the draft methods return integers and objects, and Watching returns Boolean. }
procedure TCrystalLog.Location(X, Y, L: Shortint); assembler;
asm JMP TLocationTextEventLog.SetLocation end;
function CrystalRandom(Map: TAoWHSMap; Range: Integer): Integer; assembler;
asm JMP TAoWHSMap.Random end;
function CrystalPlayer(List: TPlayerList; Player: Integer): TPlayer; assembler;
asm JMP TPlayerList.GetPlayers end;
function CrystalWatching(Map: TAoWHSMap; X, Y, L: Shortint; Radius: Integer): Boolean; assembler;
asm JMP TAoWHSMap.Watching end;
function TranslateCrystalName(const S: string): string; assembler;
asm JMP AoWE.TranslateRStr end;


constructor TManaCrystals.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSize := 2;
  FAmount := 0;
end;

class function TManaCrystals.ClassID: Integer;
begin Result := $203BE; end;

procedure TManaCrystals.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAmount, 5);
  Stream.rwData(FSize, 1, 6);
end;

procedure TManaCrystals.GenerateManaCrystalsAmount;
begin
  if FSize = 4 then FSize := CrystalRandom(WorldMap^, 3) + 1;
  case FSize of
    1: FAmount := CrystalRandom(WorldMap^, 25) + 25;
    2: FAmount := CrystalRandom(WorldMap^, 25) + 50;
    3: FAmount := CrystalRandom(WorldMap^, 50) + 100;
  end;
end;

procedure TManaCrystals.UpdateAITarget(var Info: TCrystalAIInfo; var Priority: Integer);
var P: Integer;
begin
  case Info.Kind of
    0: if Info.Player <> 0 then
    begin
      P := FAmount div 5 + 15;
      if Priority < P then Priority := P;
    end;
  end;
end;
procedure TManaCrystals.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if Info.HN = 0 then
    TCrystalFieldFlags(Pointer(Info.MapField)^).Flags :=
      TCrystalFieldFlags(Pointer(Info.MapField)^).Flags or $08000000;
end;

procedure TManaCrystals.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020001) and (WorldMap^.FDay = 1) then
    GenerateManaCrystalsAmount;
end;

procedure TManaCrystals.ArmyEntered(ArmyHS: TArmyHS);
var
  Log: TLocationTextEventLog;
begin
  if Byte(TArmy(ArmyHS.FArmy).FPlayer) = 0 then Exit;
  if (Byte(TCrystalMapFields(Pointer(WorldMap^)^).SeatedPlayer) =
    Byte(TArmy(ArmyHS.FArmy).FPlayer)) or
    WorldMap^.Watching(GetXhx, GetYhx, GetLhx, 0) then
    PlaySample('SFX\EVENTS\MANA.WAV');
  with CrystalPlayer(TPlayerList(WorldMap^.FPlayers),
    Shortint(TArmy(ArmyHS.FArmy).FPlayer)) do
    TCrystalMagic(FMagicControl).Mana := TCrystalMagic(FMagicControl).Mana + FAmount;
  Log := TLocationTextEventLog.Create(nil);
  Log.FPlayer := Byte(TArmy(ArmyHS.FArmy).FPlayer);
  PString(@Log.FText)^ := SysUtils.Format(TranslateCrystalName(ManaCrystalsFoundRStr),
    [IntToStr(FAmount)]);
  Log.SetLocation(GetXhx, GetYhx, GetLhx);
  TEventLogbook(CrystalPlayer(TPlayerList(WorldMap^.FPlayers),
    Shortint(TArmy(ArmyHS.FArmy).FPlayer)).FEventLogbook).AddEvent(Log);
  Log.Release;
  Destroy;
end;

procedure TManaCrystals.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); { Near miss: three variants retain a different AI-info argument load. }
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1102 then
  begin
    ArmyEntered(TArmyHS(Msg.Param[0]));
    Exit;
  end;
  if Msg.MsgID = $1200 then
    if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
    begin
      UpdateAITarget(PCrystalAIInfo(Msg.Param[0])^, PInteger(Msg.Param[1])^);
      { Original marks the message only when the resulting priority is negative. }
      if PInteger(Msg.Param[1])^ < 0 then Msg.Result := 1;
    end;
end;

class function TManaCrystalsResource.ResourceEditName: string;
begin Result := TranslateCrystalName(ManaCrystalsRStr); end;

class function TManaCrystalsResource.ClassID: Integer;
begin Result := $203BF; end;

function TManaCrystalsResource.ResourceUserClassID: Integer;
begin Result := $203BE; end;

procedure RegisterManaCrystals(AEngine: TEngine);
begin AEngine.RegisterEClasses([TManaCrystals, TManaCrystalsResource]); end;


initialization
finalization

end.
