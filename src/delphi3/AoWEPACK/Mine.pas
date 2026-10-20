unit Mine;

{ Mine of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TMine = class;
  TMineResource = class;


  { TMine (instance size 68, VMT 557B4020): +$3C FState (bit 0 razed),
    +$40 FIncomeSource. }
  TMine = class(TPlayerStructure)
  public
    FState: Byte;
    FReserved3D: array[0..2] of Byte;
    FIncomeSource: TPlayerStructureIncomeSource;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure SetRazed(A1: Integer); override;
    procedure GetRazed; override;
    procedure GetCurrentActivityText(A1: Integer); override;
    procedure UpdateAITarget(A1: Integer; A2: Integer); override;
    procedure SetPlayer(A1: Integer; A2: Integer); override;
    procedure GetIncome(A1: Integer; A2: Integer); override;
    procedure GetCombatEventText(A1: Integer; A2: Integer); override;
  end;

  { TMineResource (instance size 116, VMT 557B42A8) }
  TMineResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

function MineIncome(Player: Shortint): Integer;  { draft }
procedure RegisterMine(AEngine: TEngine);

implementation

type
  PMineMap = ^TAoWHSMap;
  TMineAIInfo = packed record
    Player, OtherPlayer: Shortint;
    Kind: Byte;
  end;
  TMinePlayerData = packed record
    Reserved: array[0..207] of Byte;
    Gold: Integer;
  end;
  TMineCombatData = packed record
    Reserved: array[0..19] of Byte;
    Outcome: Byte;
  end;
  TMineImageData = packed record
    Reserved: array[0..19] of Byte;
    ImageIndex: Integer;
  end;
const WorldMap: PMineMap = @AoWE.AoWHSMap;

{ needs: draft AoWE methods have object, integer and Boolean results. }
function MinePlayer(List: TPlayerList; Player: Integer): TPlayer; assembler;
asm JMP TPlayerList.GetPlayers end;
function MineRazed(Structure: TStructure): Boolean; assembler;
asm MOV EDX,[EAX]; JMP DWORD PTR [EDX+$150] end;
function MineBuilding(Structure: TStructure): Boolean; assembler;
asm JMP TStructure.GetBuilding end;
procedure MineSetPlayer(Structure: TPlayerStructure; Player: Byte); assembler;
asm MOV ECX,[EAX]; JMP DWORD PTR [ECX+$1F0] end;
function MineIncomeOf(Structure: TPlayerStructure): Integer; assembler;
asm MOV EDX,[EAX]; JMP DWORD PTR [EDX+$1F4] end;
procedure MineParentSetPlayer(Structure: TPlayerStructure; Player: Byte); assembler;
asm JMP TPlayerStructure.SetPlayer end;
function MineAttackRelation(Player, OtherPlayer, Owner: Shortint; Mode: Byte): Boolean; assembler;
asm JMP AoWE.ValidAttackRelation end;
function MineStructure(List: TPlayerStructureList; Index: Integer): TPlayerStructure; assembler;
asm JMP TPlayerStructureList.GetStructure end;
procedure TranslateMineText(const S: string; var Text: string); assembler;
asm JMP AoWE.TranslateRStr end;
procedure MineFormat(const Fmt: string; const Args: array of const; var Text: string); assembler;
asm JMP SysUtils.Format end;
function TranslateMineName(const S: string): string; assembler;
asm JMP AoWE.TranslateRStr end;


constructor TMine.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FIncomeSource := TPlayerStructureIncomeSource.Create(nil);
  FIncomeSource.Setup(Integer(Self));
end;

destructor TMine.Destroy;
begin
  inherited Destroy;
  FIncomeSource.Free;
end;

class function TMine.ClassID: Integer;
begin Result := $2037A; end;

procedure TMine.GetIncome(A1: Integer; A2: Integer);
begin
  if not MineRazed(Self) and not MineBuilding(Self) then
    asm MOV EAX,10 end
  else
    asm XOR EAX,EAX end;
end;

procedure TMine.GetCurrentActivityText(A1: Integer);
begin
  MineFormat(TranslateMineName(ProducingXIncomeRStr),
    [IntToStr(MineIncomeOf(Self))], PString(A1)^);
end;

procedure TMine.UpdateAITarget(A1: Integer; A2: Integer);
var Priority: Integer;
begin
  if not MineRazed(Self) or MineBuilding(Self) then
  begin
    Priority := PInteger(A2)^;
    if TMineAIInfo(Pointer(A1)^).Kind = 0 then
    begin
      if (Byte(TMineAIInfo(Pointer(A1)^).Player) <> F_PlayerStructure_30) and
        not MineRazed(Self) then
        if F_PlayerStructure_30 = 0 then Priority := 50
        else if MineAttackRelation(TMineAIInfo(Pointer(A1)^).Player,
          TMineAIInfo(Pointer(A1)^).OtherPlayer, Shortint(F_PlayerStructure_30), 0) then
        begin
          Priority := 50 - TMinePlayerData(Pointer(MinePlayer(
            TPlayerList(WorldMap^.FPlayers), TMineAIInfo(Pointer(A1)^).Player))^).Gold div 2;
          if Priority < 25 then Priority := 25;
          if Priority > 75 then Priority := 75;
        end;
    end
    else if (TMineAIInfo(Pointer(A1)^).Kind = 6) and
      (Byte(TMineAIInfo(Pointer(A1)^).Player) = F_PlayerStructure_30) then PInteger(A2)^ := 20;
    { Original can overwrite the special kind-6 priority with the previous higher value. }
    if PInteger(A2)^ < Priority then PInteger(A2)^ := Priority;
  end;
end;

procedure TMine.SetPlayer(A1: Integer; A2: Integer);
begin
  if Byte(A1) <> F_PlayerStructure_30 then
    if moActivated in FStatus then
    begin
      if F_PlayerStructure_30 <> $FF then
        MinePlayer(TPlayerList(WorldMap^.FPlayers), Shortint(F_PlayerStructure_30)).
          UnregisterIncomeSource(Integer(FIncomeSource));
      MineParentSetPlayer(Self, Byte(A1));
      if F_PlayerStructure_30 <> $FF then
        MinePlayer(TPlayerList(WorldMap^.FPlayers), Shortint(F_PlayerStructure_30)).
          RegisterIncomeSource(Integer(FIncomeSource));
    end
    else MineParentSetPlayer(Self, Byte(A1));
end;

procedure TMine.Activate;
begin
  inherited Activate;
  if F_PlayerStructure_30 <> $FF then
    MinePlayer(TPlayerList(WorldMap^.FPlayers), Shortint(F_PlayerStructure_30)).
      RegisterIncomeSource(Integer(FIncomeSource));
end;

procedure TMine.Deactivate;
begin
  if F_PlayerStructure_30 <> $FF then
    MinePlayer(TPlayerList(WorldMap^.FPlayers), Shortint(F_PlayerStructure_30)).
      UnregisterIncomeSource(Integer(FIncomeSource));
  inherited Deactivate;
end;

procedure TMine.GetRazed;
asm TEST BYTE PTR [EAX+$3C],1; SETNE AL end;

procedure TMine.SetRazed(A1: Integer);
begin
  if Byte(A1) <> 0 then
  begin
    MineSetPlayer(Self, $FF);
    FState := FState or 1;
  end
  else FState := FState and $FE;
  TMineImageData(Pointer(Self)^).ImageIndex := GetTerrainTypeImage(TerrainType);
end;

procedure TMine.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FState, 1, 20);
end;

procedure TMine.GetCombatEventText(A1: Integer; A2: Integer);
begin
  if (TMineCombatData(Pointer(A1)^).Outcome = 3) or
    (TMineCombatData(Pointer(A1)^).Outcome = 6) then
    TranslateMineText(MineBattleWonRStr, PString(A2)^)
  else PString(A2)^ := '';
end;

constructor TMineResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  F_StructureResource_44 := 0;
  F_PlayerStructureResource_64 := 0;
  F_StructureResource_58 := 1;
  F_StructureResource_60 := 75;
  F_StructureResource_5A := 25;
  F_StructureResource_5B := 2;
end;

class function TMineResource.ResourceEditName: string;
begin Result := TranslateMineName(MineRStr); end;

class function TMineResource.ClassID: Integer;
begin Result := $2037B; end;

function TMineResource.ResourceUserClassID: Integer;
begin Result := $2037A; end;

function MineIncome(Player: Shortint): Integer;
var
  P: TPlayer;
  S: TPlayerStructure;
  I: Integer;
begin
  if WorldMap^ <> nil then
  begin
    P := MinePlayer(TPlayerList(WorldMap^.FPlayers), Player);
    Result := 0;
    for I := 0 to TEObjectList(P.F_Player_1C).Count - 1 do
    begin
      S := MineStructure(TPlayerStructureList(P.F_Player_1C), I);
      if (S.ClassID = $2037A) and (Shortint(S.F_PlayerStructure_30) = Player) then
        Inc(Result, MineIncomeOf(S));
    end;
  end
  else Result := -1;
end;

procedure RegisterMine(AEngine: TEngine);
begin AEngine.RegisterEClasses([TMine, TMineResource]); end;


initialization
finalization

end.
