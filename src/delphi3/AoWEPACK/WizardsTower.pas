unit WizardsTower;

{ Wizards towers of AoWEPACK.dpl: spell generation, purchases and AI targets. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  TWizardsTower = class;
  TWizardsTowerResource = class;
  TEnterWizardsTowerEventLog = class;


  { TWizardsTower: size $38, VMT 557D5508; $30 generate, $31 spheres, $33 level, $34 spell ID. }
  TWizardsTower = class(TStructure)
  public
    FGenerateSpell: Boolean; { $30 }
    FMagicSpheres: TMagicSpheres; { $31 }
    FSpellLevel: Byte; { $33 }
    FSpellID: Integer; { $34 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult; override;
    procedure NewDay; override;
    procedure ArmyPlaced(A1: TArmyHS); override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    function CanDblClick: Boolean; override;
    function ValidAITarget(Player: Shortint): Boolean;
    procedure GenerateSettings;
    function CanEnter(Player: Shortint): Boolean;
    function Enter: Boolean;
    function BuyCost: Integer;
    function CanBuy(Player: Shortint; var Reason: string): Boolean;
    function Buy(Player: Shortint; var Reason: string): Boolean;
  end;

  { TWizardsTowerResource: size $64, VMT 557D5774; no additional fields. }
  TWizardsTowerResource = class(TStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TEnterWizardsTowerEventLog: size $1C, VMT 557D587C; $18 tower. }
  TEnterWizardsTowerEventLog = class(TEventLog)
  public
    FTower: TWizardsTower; { $18 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

procedure RegisterWizardsTower(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  PAoWHSSet = ^TAoWHSSet;
  PMagicSpheres = ^TMagicSpheres;
const
  AllMagicSpheres: TMagicSpheres = [msCosmos..msSecret];
  MagicSpheres: PMagicSpheres = @AllMagicSpheres;
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  WorldSet: PAoWHSSet = @AoWE.AoWHSSet;

constructor TEnterWizardsTowerEventLog.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

destructor TEnterWizardsTowerEventLog.Destroy;
begin inherited Destroy; end;

constructor TWizardsTower.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FGenerateSpell := True;
  FMagicSpheres := MagicSpheres^;
  FSpellLevel := 2;
end;

class function TWizardsTower.ClassID: Integer;
begin Result := $2089E; end;

procedure TWizardsTower.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(FGenerateSpell, 30);
  Stream.rwData(FMagicSpheres, 2, 31);
  Stream.rwByte(FSpellLevel, 32);
  Stream.rwData(FSpellID, 4, 33);
end;

function TWizardsTower.CanDblClick: Boolean;
begin Result := CanEnter(WorldMap^.FSeatedPlayer); end;

function TWizardsTower.ValidAITarget(Player: Shortint): Boolean;
begin
  if (Player > 0) and not GetRazed and (FSpellID <> 0) and
    (WorldMap^.FPlayers.GetPlayers(Player).FMagicControl.FSpells.IndexOf(FSpellID) = -1) then
    Result := WorldSet^.FSpellControl.GetSpell(FSpellID).FCastDuration > 0
  else Result := False;
end;

procedure TWizardsTower.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
var Player: Shortint;
begin
  if not GetRazed or GetBuilding then
    case Info.Mode of
      tmAttack:
        begin
          Player := TAoWMapField(Owner).GetPlayer;
          if (Player <> Info.Player) and
            ((Player <= 0) or ValidAttackRelation(Info.Player, 0, Player, 0)) and
            ValidAITarget(Info.Player) then
          begin
            if Data.Priority < 10 then Data.Priority := 10;
            Data.Cost := BuyCost;
          end;
        end;
    end;
end;

procedure TWizardsTower.ArmyPlaced(A1: TArmyHS);
var
  Army: TArmy;
  Group: TAIGroup;
  I: Integer;
  Reason: string;
  Cost: Integer;
  Found: Boolean;
  Location: Integer;
begin
  inherited ArmyPlaced(A1);
  if (WorldMap^.FPlayers.GetPlayers(A1.FArmy.FPlayer).FPlayerType in
    [ptCPU1, ptCPU2, ptCPU3, ptCPU4, ptCPU5]) and
    ValidAITarget(A1.FArmy.FPlayer) then
  begin
    Army := A1.FArmy;
    Group := nil;
    I := 0;
    Cost := BuyCost;
    Found := False;
    Location := Integer(PackXYL(GetXhx, GetYhx, GetLhx));
    while not Found and (I <> Army.Count) do
    begin
      Group := Army.GetUnit(I).FGroup;
      Found := (Group <> nil) and (Integer(Group.FTargetXYL) = Location) and (Group.FGoldBudget = Cost);
      Inc(I);
    end;
    if Found and CanBuy(Army.FPlayer, Reason) then
    begin
      Group.ReturnTargetExpense;
      WorldMap^.FPlayers.GetPlayers(Army.FPlayer).SetGems(
        WorldMap^.FPlayers.GetPlayers(Army.FPlayer).FGems - Cost);
      WorldMap^.FPlayers.GetPlayers(Army.FPlayer).FMagicControl.FSpells.Add(FSpellID);
    end;
  end;
end;

procedure TWizardsTower.GenerateSettings;
begin
  FSpellID := WorldSet^.FSpellControl.GetRandomSpell(FSpellLevel, FSpellLevel, FMagicSpheres);
end;

procedure TWizardsTower.NewDay;
begin
  inherited NewDay;
  if (WorldMap^.FDay = 1) and (FGenerateSpell or (FSpellID = 0)) then GenerateSettings;
end;

function TWizardsTower.CanEnter(Player: Shortint): Boolean;
var ArmyHS: TArmyHS;
begin
  ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
  if (ArmyHS = nil) or (ArmyHS.FArmy.FPlayer <> Player) then Result := False
  else Result := True;
end;

function TWizardsTower.Enter: Boolean;
var Log: TEnterWizardsTowerEventLog;
begin
  if CanEnter(WorldMap^.FSeatedPlayer) then
  begin
    Log := TEnterWizardsTowerEventLog.Create(nil);
    Log.FTower := Self;
    Log.Execute(True, etUser, nil);
    Log.Release;
    Result := True;
  end
  else Result := False;
end;

function TWizardsTower.ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult;
var
  Player: TPlayer;
  Reason, Text: string;
begin
  Result := inherited ExecuteTE(A1, Executer);
  if (A1.FAction = 1) and CanBuy(A1.FParam, Reason) then
  begin
    Player := WorldMap^.FPlayers.GetPlayers(A1.FParam);
    Player.SetGems(Player.FGems - BuyCost);
    Player.FMagicControl.FSpells.Add(FSpellID);
    if WorldMap^.FSeatedPlayer = A1.FParam then
    begin
      Text := SysUtils.Format(TranslateRStr(LoadResString(@TheyTaughtYouTheSpellXRStr)),
        [WorldSet^.FSpellControl.GetSpell(FSpellID).FSpellName]);
      WorldMap^.ShowMessage(Text);
    end;
  end;
end;

function TWizardsTower.BuyCost: Integer;
begin
  if FSpellID <> 0 then Result := WorldSet^.FSpellControl.GetSpell(FSpellID).FResearchCost
  else Result := -1;
end;

function TWizardsTower.CanBuy(Player: Shortint; var Reason: string): Boolean;
begin
  if FSpellID <> 0 then
  begin
    if WorldMap^.FPlayers.GetPlayers(Player).FMagicControl.FSpells.IndexOf(FSpellID) = -1 then
    begin
      if WorldMap^.FPlayers.GetPlayers(Player).FGems >= BuyCost then Result := True
      else
      begin
        Result := False;
        Reason := TranslateRStr(LoadResString(@NotEnoughGoldRStr));
      end;
    end
    else
    begin
      Result := False;
      Reason := TranslateRStr(LoadResString(@SpellIsAlreadyResearchedRStr));
    end;
  end
  else Result := False;
end;

function TWizardsTower.Buy(Player: Shortint; var Reason: string): Boolean;
var TE: TStructureTE;
begin
  Reason := '';
  if CanBuy(Player, Reason) and not WorldMap^.FPlayers.GetPlayers(Player).GetBusy then
  begin
    TE := CreateTE;
    SetupTE(TE);
    TE.FAction := 1;
    TE.FParam := Player;
    WorldMap^.FTokenManager.GetTokenControl(Player).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

class function TWizardsTowerResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@WizardsTowerRStr)); end;

class function TWizardsTowerResource.ClassID: Integer;
begin Result := $2089F; end;

function TWizardsTowerResource.ResourceUserClassID: Integer;
begin Result := $2089E; end;

procedure RegisterWizardsTower(AEngine: TEngine);
begin AEngine.RegisterEClasses([TWizardsTower, TWizardsTowerResource]); end;

initialization
finalization
end.
