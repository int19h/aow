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
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    function GetCurrentActivityText: string; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Priority: Integer); override;
    procedure SetPlayer(Player: Shortint); override;
    function GetIncome: Integer; override;
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
  FIncomeSource.Setup(Self);
end;

destructor TMine.Destroy;
begin
  inherited Destroy;
  FIncomeSource.Free;
end;

class function TMine.ClassID: Integer;
begin Result := $2037A; end;

function TMine.GetIncome: Integer;
begin
  if not MineRazed(Self) and not MineBuilding(Self) then
    asm MOV EAX,10 end
  else
    asm XOR EAX,EAX end;
end;

function TMine.GetCurrentActivityText: string;
begin
  MineFormat(TranslateMineName(ProducingXIncomeRStr),
    [IntToStr(MineIncomeOf(Self))], Result);
end;

procedure TMine.UpdateAITarget(const Info: TAITargetInfo; var Priority: Integer);
var CandidatePriority: Integer;
begin
  if not MineRazed(Self) or MineBuilding(Self) then
  begin
    CandidatePriority := Priority;
    if TMineAIInfo(Info).Kind = 0 then
    begin
      if (Byte(TMineAIInfo(Info).Player) <> Byte(FPlayer)) and
        not MineRazed(Self) then
        if Byte(FPlayer) = 0 then CandidatePriority := 50
        else if MineAttackRelation(TMineAIInfo(Info).Player,
          TMineAIInfo(Info).OtherPlayer, Shortint(Byte(FPlayer)), 0) then
        begin
          CandidatePriority := 50 - TMinePlayerData(Pointer(MinePlayer(
            TPlayerList(WorldMap^.FPlayers), TMineAIInfo(Info).Player))^).Gold div 2;
          if CandidatePriority < 25 then CandidatePriority := 25;
          if CandidatePriority > 75 then CandidatePriority := 75;
        end;
    end
    else if (TMineAIInfo(Info).Kind = 6) and
      (Byte(TMineAIInfo(Info).Player) = Byte(FPlayer)) then Priority := 20;
    { Original can overwrite the special kind-6 priority with the previous higher value. }
    if Priority < CandidatePriority then Priority := CandidatePriority;
  end;
end;

procedure TMine.SetPlayer(Player: Shortint);
begin
  if Byte(Player) <> Byte(FPlayer) then
    if moActivated in FStatus then
    begin
      if Byte(FPlayer) <> $FF then
        MinePlayer(TPlayerList(WorldMap^.FPlayers), Shortint(Byte(FPlayer))).
          UnregisterIncomeSource(FIncomeSource);
      MineParentSetPlayer(Self, Byte(Player));
      if Byte(FPlayer) <> $FF then
        MinePlayer(TPlayerList(WorldMap^.FPlayers), Shortint(Byte(FPlayer))).
          RegisterIncomeSource(FIncomeSource);
    end
    else MineParentSetPlayer(Self, Byte(Player));
end;

procedure TMine.Activate;
begin
  inherited Activate;
  if Byte(FPlayer) <> $FF then
    MinePlayer(TPlayerList(WorldMap^.FPlayers), Shortint(Byte(FPlayer))).
      RegisterIncomeSource(FIncomeSource);
end;

procedure TMine.Deactivate;
begin
  if Byte(FPlayer) <> $FF then
    MinePlayer(TPlayerList(WorldMap^.FPlayers), Shortint(Byte(FPlayer))).
      UnregisterIncomeSource(FIncomeSource);
  inherited Deactivate;
end;

function TMine.GetRazed: Boolean;
asm TEST BYTE PTR [EAX+$3C],1; SETNE AL end;

procedure TMine.SetRazed(Value: Boolean);
begin
  if Value then
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
  FClaimed := False;
  FRazeable := True;
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
      if (S.ClassID = $2037A) and (Shortint(Byte(S.FPlayer)) = Player) then
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
