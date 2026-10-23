unit GlobalEnchantmentSpells;

{ GlobalEnchantmentSpells, partially recovered from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Global enchantments and their spell effects recovered from the original code. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Animation, AoWE;

type
  TGlobalEnchantmentSpellTE = class;
  TGlobalEnchantmentSpell = class;
  TEnchantedRoadsEnchantment = class;
  TEnchantedRoads = class;
  TAirMasteryEnchantment = class;
  TAirMastery = class;
  TWaterMasteryEnchantment = class;
  TWaterMastery = class;
  THatredEnchantment = class;
  THatred = class;
  THarmonyEnchantment = class;
  THarmony = class;
  TPowerLeakEnchantment = class;
  TPowerLeak = class;
  TFloodControl = class;
  TFloodEnchantment = class;
  TFlood = class;
  TLifeMasteryEnchantment = class;
  TLifeMastery = class;
  TDeathMasteryEnchantment = class;
  TDeathMastery = class;
  TFireMasteryEnchantment = class;
  TFireMastery = class;
  TEarthMasteryEnchantment = class;
  TEarthMastery = class;
  TSpellWardEnchantment = class;
  TSpellWard = class;


  { TGlobalEnchantmentSpellTE (instance size 36, VMT 557ED91C): $20 FEnchantment. }
  TGlobalEnchantmentSpellTE = class(TSpellTE)
  public
    FEnchantment: TGlobalEnchantment; { $20 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
  end;

  { TGlobalEnchantmentSpell (instance size 56, VMT 557EDA18): $34 FAIBasePriority. }
  TGlobalEnchantmentSpell = class(TSpell)
  public
    FAIBasePriority: Integer; { $34 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); override;
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    function AICanCastSpell(Source: TAbstractUnit): Boolean; virtual; { +09C }
    function CreateEnchantment: TGlobalEnchantment; virtual; { +0A0 }
    procedure SetupEnchantment(Source: TAbstractUnit; Enchantment: TGlobalEnchantment); virtual; { +0A4 }
    function AIUpkeepPriority: Integer;
  end;

  { TEnchantedRoadsEnchantment (instance size 36, VMT 557EDB5C) }
  TEnchantedRoadsEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function CanActivate(Player: Shortint; var Reason: string): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
  end;

  { TEnchantedRoads (instance size 56, VMT 557EDC88) }
  TEnchantedRoads = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
    procedure ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
  end;

  { TAirMasteryEnchantment (instance size 36, VMT 557EDDBC) }
  TAirMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function CanActivate(Player: Shortint; var Reason: string): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
  end;

  { TAirMastery (instance size 56, VMT 557EDEE0) }
  TAirMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
    procedure ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
  end;

  { TWaterMasteryEnchantment (instance size 36, VMT 557EE00C) }
  TWaterMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function CanActivate(Player: Shortint; var Reason: string): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
  end;

  { TWaterMastery (instance size 56, VMT 557EE138) }
  TWaterMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
  end;

  { THatredEnchantment (instance size 40, VMT 557EE268): $24 FDaysActive. }
  THatredEnchantment = class(TGlobalEnchantment)
  public
    FDaysActive: Integer; { $24 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
    procedure NewDay;
  end;

  { THatred (instance size 56, VMT 557EE384) }
  THatred = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
  end;

  { THarmonyEnchantment (instance size 40, VMT 557EE4A8): $24 FDaysActive. }
  THarmonyEnchantment = class(TGlobalEnchantment)
  public
    FDaysActive: Integer; { $24 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
    procedure NewDay;
  end;

  { THarmony (instance size 56, VMT 557EE5C8) }
  THarmony = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
  end;

  { TPowerLeakEnchantment (instance size 36, VMT 557EE6F0) }
  TPowerLeakEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
  end;

  { TPowerLeak (instance size 56, VMT 557EE814) }
  TPowerLeak = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
  end;

  PFloodTerrainArray = ^TFloodTerrainArray;
  TFloodTerrainArray = array[0..MaxInt - 1] of Shortint;

  { TFloodControl (instance size 20, VMT 557EE93C): $08 FWidth, $0C FHeight, $10 FOriginalTerrain. }
  TFloodControl = class(TEObject)
  public
    FWidth: Integer; { $08 }
    FHeight: Integer; { $0C }
    FOriginalTerrain: PFloodTerrainArray; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Setup;
    procedure Flood;
    procedure Restore;
  end;

  { TFloodEnchantment (instance size 48, VMT 557EEA10): $24 FRemoved, $25 FRestoreDays, $26 FDispelPlayer, $28 FTurnsActive, $2C FFloodControl. }
  TFloodEnchantment = class(TGlobalEnchantment)
  public
    FRemoved: Boolean; { $24 }
    FRestoreDays: Shortint; { $25 }
    FDispelPlayer: Shortint; { $26 }
    FReserved: Byte; { $27 alignment }
    FTurnsActive: Integer; { $28 }
    FFloodControl: TFloodControl; { $2C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetName: string; override;
    function GetUpkeep: Integer; override;
    function GetAIUpkeepPriority: Integer; override;
    function CanDeactivate(Player: Byte; var Reason: string): Boolean; override;
    function Deactivate(Player: Byte): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
    function DaysBeforeActive: Integer;
    procedure NewTurn;
  end;

  { TFlood (instance size 56, VMT 557EEB2C) }
  TFlood = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TLifeMasteryEnchantment (instance size 36, VMT 557EEC4C) }
  TLifeMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function CanActivate(Player: Shortint; var Reason: string): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
  end;

  { TLifeMastery (instance size 56, VMT 557EED74) }
  TLifeMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
  end;

  { TDeathMasteryEnchantment (instance size 36, VMT 557EEEA4) }
  TDeathMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function CanActivate(Player: Shortint; var Reason: string): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
    procedure NewTurn(Player: Shortint);
  end;

  { TDeathMastery (instance size 56, VMT 557EEFD0) }
  TDeathMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
    procedure ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
  end;

  { TFireMasteryEnchantment (instance size 36, VMT 557EF100) }
  TFireMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function CanActivate(Player: Shortint; var Reason: string): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
    procedure UpdateFire(Factor: Integer; Explosions: Boolean);
  end;

  { TFireMastery (instance size 56, VMT 557EF228) }
  TFireMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
    procedure ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
  end;

  { TEarthMasteryEnchantment (instance size 36, VMT 557EF358) }
  TEarthMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function CanActivate(Player: Shortint; var Reason: string): Boolean; override;
    function Activate(Player: Shortint): Boolean; override;
  end;

  { TEarthMastery (instance size 56, VMT 557EF484) }
  TEarthMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
    procedure ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
  end;

  { TSpellWardEnchantment (instance size 36, VMT 557EF5B4) }
  TSpellWardEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAIUpkeepPriority: Integer; override;
  end;

  { TSpellWard (instance size 56, VMT 557EF6D8) }
  TSpellWard = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CreateEnchantment: TGlobalEnchantment; override;
  end;

procedure RegisterGlobalEnchantmentSpells(AEngine: TAoWEngine);
procedure UnregisterGlobalEnchantmentSpells(AEngine: TAoWEngine);

implementation

type
  PAoWMap = ^TAoWHSMap;
  PAoWSet = ^TAoWHSSet;
  PAoWEngine = ^TAoWEngine;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
  WorldSet: PAoWSet = @AoWE.AoWHSSet;
  WorldEngine: PAoWEngine = @AoWE.AoWEngine;
  WaterText: PResStringRec = @AoWE.WaterMasteryRStr;
  HarmonyText: PResStringRec = @AoWE.HarmonyRStr;
  FloodText: PResStringRec = @AoWE.FloodRStr;
  ActiveInDaysText: PResStringRec = @AoWE.XinYdaysRStr;
  AlreadyRemovedText: PResStringRec = @AoWE.XAlreadyRemovedRStr;
  PowerLeakText: PResStringRec = @AoWE.PowerLeakRStr;
  HatredText: PResStringRec = @AoWE.HatredRStr;
  AirText: PResStringRec = @AoWE.AirMasteryRStr;
  LifeText: PResStringRec = @AoWE.LifeMasteryRStr;
  DeathText: PResStringRec = @AoWE.DeathMasteryRStr;
  FireText: PResStringRec = @AoWE.FireMasteryRStr;
  EarthText: PResStringRec = @AoWE.EarthMasteryRStr;
  WardNameText: PResStringRec = @AoWE.SpellWardRStr;
  SpellWardText: PResStringRec = @AoWE.CannotCastGlobalEnchantmentWhenSpellWardIsActiveRStr;
  RoadsText: PResStringRec = @AoWE.EnchantedRoadsRStr;
  AlreadyActiveText: PResStringRec = @AoWE.XIsAlreadyActiveRStr;

procedure NotifySpellSphere(Player: Shortint; Sphere: TMagicSphere);
var
  Msg: TEMsg;
begin
  InitMsg(Msg, $20020102, nil);
  Msg.Param[0] := Player;
  Msg.Param[1] := Ord(Sphere);
  WorldMap^.SendMsg(Msg, nil);
end;

destructor TGlobalEnchantmentSpellTE.Destroy;
begin
  if FEnchantment <> nil then
  begin
    FEnchantment.Release;
    FEnchantment := nil;
  end;
  inherited Destroy;
end;

class function TGlobalEnchantmentSpellTE.ClassID: Integer;
begin
  Result := $21312;
end;

procedure TGlobalEnchantmentSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwCreateEObject(TEObject(FEnchantment), nil, $19);
end;

function TGlobalEnchantmentSpellTE.Validate(A1: THero): Boolean;
var
  Reason: string;
begin
  Result := inherited Validate(A1);
  Result := Result and FEnchantment.CanCast(A1.FPlayer, Reason);
end;

function TGlobalEnchantmentSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin
  Result := inherited Process(A1, A2);
end;

constructor TGlobalEnchantmentSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAIBasePriority := -1;
end;

function TGlobalEnchantmentSpell.CreateEnchantment: TGlobalEnchantment;
begin
  Result := nil;
end;

procedure TGlobalEnchantmentSpell.SetupEnchantment(Source: TAbstractUnit; Enchantment: TGlobalEnchantment);
begin
  Enchantment.FEnchantmentManaUpkeep := FManaUpkeep;
end;

function TGlobalEnchantmentSpell.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
begin
  if A3 = 0 then TGlobalEnchantmentSpellTE(A1).FEnchantment.Cast(A2.FPlayer);
  Result := False;
end;

function TGlobalEnchantmentSpell.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
var
  Enchantment: TGlobalEnchantment;
begin
  Result := inherited CanActivate(A1, A2);
  if Result then
    if not (getSpellWard in WorldMap^.FGlobalMagicControl.FActiveEnchantments) then
    begin
      Enchantment := CreateEnchantment;
      if Enchantment <> nil then
      begin
        SetupEnchantment(A1, Enchantment);
        Result := Enchantment.CanCast(A1.FPlayer, A2);
        Enchantment.Release;
      end;
    end
    else
    begin
      Result := False;
      A2 := TranslateRStr(LoadResString(SpellWardText));
    end;
end;

function TGlobalEnchantmentSpell.Activate(A1: TAbstractUnit): Boolean;
var
  Event: TGlobalEnchantmentSpellTE;
  Reason: string;
begin
  if CanActivate(A1, Reason) and not WorldMap^.FPlayers.GetPlayers(A1.FPlayer).GetBusy then
  begin
    Event := TGlobalEnchantmentSpellTE.Create(nil);
    Event.Initialize(FSpellID, A1.FPlayer, A1.FUnitID, FBaseManaCost);
    Event.FEnchantment := CreateEnchantment;
    SetupEnchantment(A1, Event.FEnchantment);
    WorldMap^.FTokenManager.GetTokenControl(A1.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TGlobalEnchantmentSpell.AICanCastSpell(Source: TAbstractUnit): Boolean;
var
  Reason: string;
begin
  Result := (FAIBasePriority <> -1) and THero(Source).CanCastSpell(FSpellID, Reason);
  Result := Result and CanActivate(Source, Reason);
end;

function TGlobalEnchantmentSpell.AIUpkeepPriority: Integer;
var
  Enchantment: TGlobalEnchantment;
begin
  { Original creates the base enchantment here. }
  Enchantment := TGlobalEnchantment.Create(nil);
  Result := Enchantment.GetAIUpkeepPriority;
  Enchantment.Release;
end;

procedure TGlobalEnchantmentSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
var
  Action: TAICastSpellAction;
begin
  if AICanCastSpell(A1) and AIRequestCastSpellExpense(A1, FBaseManaCost, FManaUpkeep, AIUpkeepPriority) then
  begin
    Action := CreateCastSpellAction;
    SetupCastSpellAction(A1, Action);
    Action.FPriority := FAIBasePriority;
    Action.SetOwner(A2);
  end;
end;

function TGlobalEnchantmentSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
var
  Reason: string;
begin
  if AICanCastSpell(A1) then
  begin
    AICastSpellExpenseMade(A1, FBaseManaCost, FManaUpkeep, AIUpkeepPriority);
    with THero(A1) do
      if CanCastSpellInstantly(FSpellID, FBaseManaCost, Reason) then
        Result := Self.Activate(A1)
      else if FCastingSpellID <> FSpellID then
      begin
        ExecuteStartCasting(FSpellID);
        Result := True;
      end
      else Result := True;
  end
  else Result := False;
end;

constructor TEnchantedRoadsEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(RoadsText));
  FEnchantmentType := getNone;
  FDispelMana := 50;
end;

class function TEnchantedRoadsEnchantment.ClassID: Integer;
begin
  Result := $21313;
end;

function TEnchantedRoadsEnchantment.GetAIUpkeepPriority: Integer;
begin
  Result := 900;
end;

function TEnchantedRoadsEnchantment.CanActivate(Player: Shortint; var Reason: string): Boolean;
begin
  Result := inherited CanActivate(Player, Reason);
  if Result and (petEnchantedRoads in AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FActiveEnchantments) then
  begin
    Reason := SysUtils.Format(TranslateRStr(LoadResString(AlreadyActiveText)), [GetName]);
    Result := False;
  end;
end;

function TEnchantedRoadsEnchantment.Activate(Player: Shortint): Boolean;
begin
  inherited Activate(Player);
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments + [petEnchantedRoads]);
  Result := True;
end;

function TEnchantedRoadsEnchantment.Deactivate(Player: Byte): Boolean;
begin
  inherited Deactivate(Player);
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments - [petEnchantedRoads]);
  Result := True;
end;

constructor TEnchantedRoads.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(RoadsText));
  FSpellID := 44;
  FSpellType := stGlobal;
  FBaseManaCost := 1;
  FSpellLevel := 3;
  FMagicSphere := msEarth;
  FCastDuration := 20;
  FAIBasePriority := 750;
end;

procedure TEnchantedRoads.ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  X, MaxX, Y, MaxY, Xhp, Yhp, FieldStep: Integer;
  MapLevel: TMapLevel;
  MapF: TAoWMapField;
begin
  MapLevel := AoWE.AoWHSMap.MapContainer.GetMapLevel(AoWE.AoWHSMap.ViewL);
  FieldStep := MapLevel.FHNOffsets[0, 4];
  MaxX := AoWE.AoWHSMap.ViewXhx + AoWE.AoWHSMap.ViewWidthHX - 1;
  MaxY := AoWE.AoWHSMap.ViewYhx + AoWE.AoWHSMap.ViewHeightHX - 1;
  for X := AoWE.AoWHSMap.ViewXhx to MaxX do
  begin
    HXtoHP(X, AoWE.AoWHSMap.ViewYhx, Xhp, Yhp);
    Xhp := Xhp - XhpSurf + 16;
    Yhp := Yhp - YhpSurf + 16;
    MapF := TAoWMapField(MapLevel.GetField(X, AoWE.AoWHSMap.ViewYhx));
    for Y := AoWE.AoWHSMap.ViewYhx to MaxY do
    begin
      if (MapF.OverlayType = 4) and (AoWE.AoWHSMap.FSeatedPlayer <> -1) and
        MapF.GetExplored(AoWE.AoWHSMap.FSeatedPlayer) then
        FCastImages.Show(0, Xhp, Yhp,
          Anim.FFrameCounter - ((MapF.Xhx + MapF.Yhx * 8 + WordRec(LongRec(MapF.FFieldFlags).Hi).Lo) and 15), SurfaceDesc);
      MapF := TAoWMapField(Integer(MapF) + FieldStep);
      Inc(Yhp, 32);
    end;
  end;
  if Anim.FFrameCounter = 50 then Anim.Destroy;
end;

function TEnchantedRoads.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; { Near miss: three variants retain different animation and Source registers. }
var
  X, Y, L: Shortint;
  Anim: TAnimation;
  Twinkle: TTwinkleAnimation;
begin
  inherited ExecuteTE(A1, A2, A3);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  Anim := TAnimation.Create(nil);
  Anim.FAnimationLevel := 27;
  Anim.FOnShow := ShowAnimation;
  Anim.FAnimationMap := WorldMap^;
  Anim.Activate;
  Twinkle := TTwinkleAnimation.Create(nil);
  Twinkle.Setup(WorldSet^.FSpellControl.GetSpell(44).FCastImages.ImageSequences[0],
    [tmRotate], 50, 64, 50, 30);
  WorldMap^.PlaceHX(Twinkle, X, Y, L);
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

function TEnchantedRoads.CreateEnchantment: TGlobalEnchantment;
begin
  Result := TEnchantedRoadsEnchantment.Create(nil);
end;

constructor TAirMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(AirText));
  FEnchantmentType := getNone;
  FDispelMana := 175;
end;

class function TAirMasteryEnchantment.ClassID: Integer;
begin
  Result := $2131E;
end;

function TAirMasteryEnchantment.GetAIUpkeepPriority: Integer;
begin
  Result := 1250;
end;

function TAirMasteryEnchantment.CanActivate(Player: Shortint; var Reason: string): Boolean;
begin
  Result := inherited CanActivate(Player, Reason);
  if Result then
    if petAirMastery in WorldMap^.FPlayers.GetPlayers(Player).FMagicControl.FActiveEnchantments then
    begin
      Reason := SysUtils.Format(TranslateRStr(LoadResString(AlreadyActiveText)), [GetName]);
      Result := False;
    end;
end;

function TAirMasteryEnchantment.Activate(Player: Shortint): Boolean;
begin
  inherited Activate(Player);
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments + [petAirMastery]);
  WorldMap^.FGlobalMagicControl.IncDoubleSphereManaCount(msEarth); { Original uses Earth. }
  Result := True;
end;

function TAirMasteryEnchantment.Deactivate(Player: Byte): Boolean;
begin
  inherited Deactivate(Player);
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments - [petAirMastery]);
  WorldMap^.FGlobalMagicControl.DecDoubleSphereManaCount(msEarth); { Original uses Earth. }
  Result := True;
end;

constructor TAirMastery.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(AirText));
  FSpellID := 60;
  FSpellType := stGlobal;
  FBaseManaCost := 1;
  FSpellLevel := 3;
  FMagicSphere := msEarth; { Original also assigns Earth to Air Mastery. }
  FCastDuration := 40;
  FAIBasePriority := 750;
end;

procedure TAirMastery.ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  I, Count, X, Y, Speed, Image: Integer;
begin
  if AoWHSMap.ViewL = 0 then
  begin
    RandSeed := AoWHSMap.Frame - Anim.FFrameCounter;
    case Ord(WorldEngine^.FAnimationDetail) of
      0: Count := 5;
      2: Count := 20;
    else Count := 10;
    end;
    for I := 0 to Count - 1 do
    begin
      X := Random(Anim.FTag and $FFFF);
      Y := Random(Cardinal(Anim.FTag) shr 16);
      Speed := Random(15) + 5;
      Image := Random(3);
      Inc(X, ((Anim.FFrameCounter - 45) * Speed) * 2);
      Dec(Y, (Anim.FFrameCounter - 45) * Speed);
      FCastImages.Show(Image, SurfaceDesc.ClipRect.Left + X, SurfaceDesc.ClipRect.Top + Y, 0, SurfaceDesc);
    end;
  end;
  if Anim.FFrameCounter = 90 then Anim.Destroy;
end;

function TAirMastery.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; { Near miss: register or temporary allocation differs after three variants. }
var
  X, Y, L: Shortint;
  Anim: TAnimation;
begin
  inherited ExecuteTE(A1, A2, A3);
  NotifySpellSphere(A2.FPlayer, msAir);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  Anim := TAnimation.Create(nil);
  Anim.FAnimationLevel := 28;
  Anim.FOnShow := ShowAnimation;
  Anim.FAnimationMap := WorldMap^;
  Anim.FTag := (WorldMap^.ViewWidth and $FFFF) or (WorldMap^.ViewHeight shl 16);
  Anim.Activate;
  WorldSet^.FSpellControl.GetSpell(60).FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

function TAirMastery.CreateEnchantment: TGlobalEnchantment;
begin
  Result := TAirMasteryEnchantment.Create(nil);
end;

constructor TWaterMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(WaterText));
  FEnchantmentType := getNone;
  FDispelMana := 175;
end;

class function TWaterMasteryEnchantment.ClassID: Integer;
begin
  Result := $21314;
end;

function TWaterMasteryEnchantment.GetAIUpkeepPriority: Integer;
begin
  Result := 1250;
end;

function TWaterMasteryEnchantment.CanActivate(Player: Shortint; var Reason: string): Boolean;
begin
  Result := inherited CanActivate(Player, Reason);
  if Result then
    if petWaterMastery in WorldMap^.FPlayers.GetPlayers(Player).FMagicControl.FActiveEnchantments then
    begin
      Reason := SysUtils.Format(TranslateRStr(LoadResString(AlreadyActiveText)), [GetName]);
      Result := False;
    end;
end;

function TWaterMasteryEnchantment.Activate(Player: Shortint): Boolean;
begin
  inherited Activate(Player);
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments + [petWaterMastery]);
  WorldMap^.UpdateVisibility;
  WorldMap^.FGlobalMagicControl.IncDoubleSphereManaCount(msFire); { Original uses Fire for Water Mastery. }
  Result := True;
end;

function TWaterMasteryEnchantment.Deactivate(Player: Byte): Boolean;
begin
  inherited Deactivate(Player);
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments - [petWaterMastery]);
  WorldMap^.UpdateVisibility;
  WorldMap^.FGlobalMagicControl.DecDoubleSphereManaCount(msFire); { Original uses Fire for Water Mastery. }
  Result := True;
end;

function TWaterMastery.CreateEnchantment: TGlobalEnchantment;
begin
  Result := TWaterMasteryEnchantment.Create(nil);
end;

constructor TWaterMastery.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(WaterText));
  FSpellID := 45;
  FSpellType := stGlobal;
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msWater;
  FCastDuration := 40;
  FAIBasePriority := 1000;
end;

function TWaterMastery.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, L: Shortint;
begin
  inherited ExecuteTE(A1, A2, 0); { Original ignores the event step. }
  A2.GetLocation(X, Y, L);
  NotifySpellSphere(A2.FPlayer, msWater);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  FCastSounds.Play(0);
  WorldMap^.AddEffect(fxWaterMastery);
  CastingDone(A2, FBaseManaCost);
  Result := False;
end;

constructor THatredEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(HatredText));
  FEnchantmentType := getHatred;
  FDispelMana := 50;
end;

class function THatredEnchantment.ClassID: Integer;
begin
  Result := $21315;
end;

function THatredEnchantment.GetAIUpkeepPriority: Integer;
begin
  Result := 500;
end;

procedure THatredEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FDaysActive, $14);
end;

procedure THatredEnchantment.NewDay;
begin
  Inc(FDaysActive);
  if FDaysActive <= 10 then Dec(WorldMap^.FRaces.FRelationOffset, 4);
end;

procedure THatredEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayerIndex) then NewDay;
end;

function THatredEnchantment.Activate(Player: Shortint): Boolean;
begin
  inherited Activate(Player);
  NewDay;
  Result := True;
end;

function THatredEnchantment.Deactivate(Player: Byte): Boolean;
begin
  inherited Deactivate(Player);
  if FDaysActive > 10 then Inc(WorldMap^.FRaces.FRelationOffset, 40)
  else Inc(WorldMap^.FRaces.FRelationOffset, FDaysActive * 4);
  Result := True;
end;

function THatred.CreateEnchantment: TGlobalEnchantment;
begin
  Result := THatredEnchantment.Create(nil);
end;

constructor THatred.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(HatredText));
  FSpellID := 46;
  FSpellType := stGlobal;
  FBaseManaCost := 20;
  FSpellLevel := 4;
  FMagicSphere := msDeath;
end;

function THatred.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, L: Shortint;
begin
  inherited ExecuteTE(A1, A2, A3);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  WorldMap^.AddEffect(fxHatred);
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

constructor THarmonyEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(HarmonyText));
  FEnchantmentType := getHarmony;
  FDispelMana := 50;
end;

class function THarmonyEnchantment.ClassID: Integer;
begin
  Result := $21316;
end;

function THarmonyEnchantment.GetAIUpkeepPriority: Integer;
begin
  Result := 500;
end;

procedure THarmonyEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FDaysActive, $14);
end;

procedure THarmonyEnchantment.NewDay;
begin
  Inc(FDaysActive);
  if FDaysActive <= 10 then Inc(WorldMap^.FRaces.FRelationOffset, 4);
end;

procedure THarmonyEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayerIndex) then NewDay;
end;

function THarmonyEnchantment.Activate(Player: Shortint): Boolean;
begin
  inherited Activate(Player);
  NewDay;
  Result := True;
end;

function THarmonyEnchantment.Deactivate(Player: Byte): Boolean;
begin
  inherited Deactivate(Player);
  if FDaysActive > 10 then Dec(WorldMap^.FRaces.FRelationOffset, 40)
  else Dec(WorldMap^.FRaces.FRelationOffset, FDaysActive * 4);
  Result := True;
end;

function THarmony.CreateEnchantment: TGlobalEnchantment;
begin
  Result := THarmonyEnchantment.Create(nil);
end;

constructor THarmony.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(HarmonyText));
  FSpellID := 47;
  FSpellType := stGlobal;
  FBaseManaCost := 15;
  FSpellLevel := 4;
  FMagicSphere := msLife;
end;

function THarmony.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, L: Shortint;
begin
  inherited ExecuteTE(A1, A2, A3);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  WorldMap^.AddEffect(fxTranquility);
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

constructor TPowerLeakEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(PowerLeakText));
  FEnchantmentType := getPowerLeak;
  FDispelMana := 25;
end;

class function TPowerLeakEnchantment.ClassID: Integer;
begin
  Result := $21317;
end;

function TPowerLeakEnchantment.GetAIUpkeepPriority: Integer;
begin
  Result := 750;
end;

function TPowerLeakEnchantment.Activate(Player: Shortint): Boolean;
var
  I: Integer;
begin
  inherited Activate(Player);
  for I := WorldMap^.FPlayers.Count - 1 downto 0 do
    WorldMap^.FPlayers.GetPlayers(I).FMagicControl.Update;
  Result := True;
end;

function TPowerLeakEnchantment.Deactivate(Player: Byte): Boolean;
var
  I: Integer;
begin
  inherited Deactivate(Player);
  for I := WorldMap^.FPlayers.Count - 1 downto 0 do
    WorldMap^.FPlayers.GetPlayers(I).FMagicControl.Update;
  Result := True;
end;

function TPowerLeak.CreateEnchantment: TGlobalEnchantment;
begin
  Result := TPowerLeakEnchantment.Create(nil);
end;

constructor TPowerLeak.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellType := stGlobal;
  FSpellName := TranslateRStr(LoadResString(PowerLeakText));
  FSpellID := 48;
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msCosmos;
  FCastDuration := 20;
  FAIBasePriority := 750;
end;

function TPowerLeak.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, L: Shortint;
  Anim: TTwinkleAnimation;
begin
  inherited ExecuteTE(A1, A2, A3);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  Anim := TTwinkleAnimation.Create(nil);
  Anim.Setup(WorldSet^.FSpellControl.GetSpell(48).FCastImages.ImageSequences[0],
    [tmImplode], 100, 64, 50, 30);
  WorldMap^.PlaceHX(Anim, X, Y, L);
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

constructor TFloodControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FOriginalTerrain := nil;
end;

destructor TFloodControl.Destroy;
begin
  if FOriginalTerrain <> nil then ReallocMem(FOriginalTerrain, 0);
  inherited Destroy;
end;

procedure TFloodControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FWidth, $14);
  Stream.rwInteger(FHeight, $15);
  if FWidth <> 0 then
  begin
    if smRead in Stream.StorageMode then ReallocMem(FOriginalTerrain, FWidth * FHeight * 2);
    Stream.rwData(FOriginalTerrain^, FWidth * FHeight * 2, $16);
  end;
end;

procedure TFloodControl.Setup;
begin
  FWidth := WorldMap^.MapContainer.Width;
  FHeight := WorldMap^.MapContainer.Height;
  ReallocMem(FOriginalTerrain, FWidth * FHeight * 2);
  FillChar(FOriginalTerrain^, FWidth * FHeight * 2, 0);
end;

procedure TFloodControl.Flood;
var
  X, Y: Integer;
  MapLevel: TMapLevel;
  Walk: THNWalkData;
  MapF: TMapField;
  Index: Integer;
  RoadHS: THexagonSprite;
  TerrainType: Shortint;
begin
  WorldMap^.LockMapChangedEvent;
  MapLevel := WorldMap^.MapContainer.GetMapLevel(0);
  { Original includes the last row when walking neighbouring hexagons. }
  for Y := 1 to MapLevel.Height - 1 do
    for X := 1 to MapLevel.Width - 2 do
      if MapLevel.GetField(X, Y).TerrainType = 0 then
      begin
        InitHNWalk(Walk, X, Y, 1);
        while Walk.Radius = 1 do
        begin
          MapF := MapLevel.GetField(Walk.X, Walk.Y);
          if (not (MapF.TerrainType in [0, 6, 15]) and not (MapF.OverlayType in [0, 2, 7])) or
            ((MapF.TerrainType = 0) and (MapF.OverlayType = 5)) then
          begin
            Index := (FWidth * Walk.Y + Walk.X) * 2;
            if (FOriginalTerrain^[Index] = 0) and (FOriginalTerrain^[Index + 1] = 0) and
              (MapF.FindNoneTransparentHS(TStructure) = nil) then
            begin
              FOriginalTerrain^[Index] := MapF.TerrainType;
              FOriginalTerrain^[Index + 1] := MapF.OverlayType;
            end;
            if MapF.OverlayType in [4, 5] then
            begin
              RoadHS := MapF.FindOwnedHS(TAbstractRoad);
              if RoadHS <> nil then RoadHS.Destroy;
            end;
          end;
          WalkToNextHN(Walk);
        end;
      end;
  for Y := 1 to MapLevel.Height - 1 do
  begin
    Index := (FWidth * Y + 1) * 2;
    for X := 1 to MapLevel.Width - 2 do
    begin
      if FOriginalTerrain^[Index] <> 0 then
      begin
        MapF := MapLevel.GetField(X, Y);
        TerrainType := MapF.TerrainType;
        if TerrainType <> 0 then
        begin
          MapF.TerrainType := 0;
          MapF.TerrainChanged;
        end;
      end;
      Inc(Index, 2);
    end;
  end;
  WorldMap^.UnlockMapChangedEvent;
  WorldMap^.InvalidateMap;
end;

procedure TFloodControl.Restore;
var
  Resources: TEObjectList;
  Candidates: TList;
  X, Y, I, Index: Integer;
  MapF: TMapField;
  MapLevel: TMapLevel;
  Overlay: Shortint;
  Resource: TMapObjectResource;
begin
  WorldMap^.LockMapChangedEvent;
  MapLevel := WorldMap^.MapContainer.GetMapLevel(0);
  for Y := 1 to MapLevel.Height - 1 do
  begin
    Index := (FWidth * Y + 1) * 2;
    for X := 1 to MapLevel.Width - 2 do
    begin
      if FOriginalTerrain^[Index] <> 0 then
      begin
        MapF := MapLevel.GetField(X, Y);
        if MapF.TerrainType in [0, 6] then
        begin
          MapF.TerrainType := FOriginalTerrain^[Index];
          MapF.TerrainChanged;
        end;
      end;
      Inc(Index, 2);
    end;
  end;
  Resources := WorldSet^.MapObjectResourceList.FChildren;
  Candidates := TList.Create;
  for Y := 1 to MapLevel.Height - 1 do
  begin
    Index := (FWidth * Y + 1) * 2;
    for X := 1 to MapLevel.Width - 2 do
    begin
      Overlay := FOriginalTerrain^[Index + 1];
      if Overlay > 0 then
      begin
        MapF := MapLevel.GetField(X, Y);
        if Overlay in [4, 5] then
          WorldSet^.RoadControl.Place(WorldMap^.MapContainer, X, Y, 0, MapF.TerrainType)
        else
        begin
          Candidates.Clear;
          for I := 0 to Resources.Count - 1 do
          begin
            Resource := TMapObjectResource(Resources.List^[I]);
            if (Resource.ClassID = $20167) and (Resource.TerrainList.UsedTerrain = 1) and
              (Resource.TerrainList.Terrain[0] = MapF.TerrainType) and
              (Overlay = Resource.TerrainList.Overlay[0]) then Candidates.Add(Resource);
          end;
          if Candidates.Count <> 0 then
            TMapObjectResource(Candidates[WorldMap^.Random(Candidates.Count)]).PlaceResourceUser(WorldMap^, X, Y, 0);
        end;
      end;
      Inc(Index, 2);
    end;
  end;
  Candidates.Free;
  WorldMap^.UnlockMapChangedEvent;
  WorldMap^.InvalidateMap;
end;

constructor TFloodEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(FloodText));
  FEnchantmentType := getFlood;
  FFloodControl := TFloodControl.Create(nil);
  FDispelMana := 100;
  FRestoreDays := -1;
end;

destructor TFloodEnchantment.Destroy;
begin
  FFloodControl.Free;
  inherited Destroy;
end;

class function TFloodEnchantment.ClassID: Integer;
begin
  Result := $21318;
end;

function TFloodEnchantment.GetAIUpkeepPriority: Integer;
begin
  Result := 500;
end;

procedure TFloodEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FTurnsActive, $14);
  Stream.rwEObject(FFloodControl, $15);
  Stream.rwBool(FRemoved, $16);
  Stream.rwByte(Byte(FDispelPlayer), $17);
  Stream.rwShortintEx(FRestoreDays, -1, $18);
end;

function TFloodEnchantment.DaysBeforeActive: Integer;
begin
  if (WorldMap^.FPlayMode = pmSimultaneous) and (FTurnsActive < 2) then
    Result := 2 - FTurnsActive
  else if (WorldMap^.FPlayMode = pmTurn) and (FTurnsActive = 0) then Result := 1
  else Result := 0;
end;

function TFloodEnchantment.GetName: string;
begin
  Result := inherited GetName;
  if FRemoved then Result := Result + ' (' + LowerCase(FmtDaysLeftStr(FRestoreDays)) + ')'
  else if DaysBeforeActive <> 0 then
    Result := SysUtils.Format(LoadResString(ActiveInDaysText), [Result, DaysBeforeActive]);
end;

function TFloodEnchantment.GetUpkeep: Integer;
begin
  if not FRemoved then Result := inherited GetUpkeep
  else Result := 0;
end;

procedure TFloodEnchantment.NewTurn; { Near miss: three variants retain different turn-counter load reuse. }
begin
  if not FRemoved then
  begin
    Inc(FTurnsActive);
    if WorldMap^.FPlayMode = pmSimultaneous then
    begin
      if (FTurnsActive > 1) and (FTurnsActive < 4) then FFloodControl.Flood
      else if FTurnsActive = 4 then
        if WorldMap^.Random(2) = 1 then FFloodControl.Flood;
    end
    else if WorldMap^.FPlayMode = pmTurn then
    begin
      if FTurnsActive < 3 then FFloodControl.Flood
      else if FTurnsActive = 3 then
        if WorldMap^.Random(2) = 1 then FFloodControl.Flood;
    end;
  end;
end;

procedure TFloodEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020003 then
  begin
    if (Msg.Value = FPlayerIndex) and not FRemoved then NewTurn;
    if (Msg.Value = FDispelPlayer) and FRemoved then
    begin
      Dec(FRestoreDays);
      if FRestoreDays <= 0 then
      begin
        FFloodControl.Restore;
        inherited Deactivate(FDispelPlayer);
      end;
    end;
  end;
end;

function TFloodEnchantment.Activate(Player: Shortint): Boolean;
begin
  inherited Activate(Player);
  FRemoved := False;
  FFloodControl.Setup;
  Result := True;
end;

function TFloodEnchantment.CanDeactivate(Player: Byte; var Reason: string): Boolean;
begin
  if not FRemoved then Result := inherited CanDeactivate(Player, Reason)
  else
  begin
    Reason := SysUtils.Format(TranslateRStr(LoadResString(AlreadyRemovedText)), [FName]);
    Result := False;
  end;
end;

function TFloodEnchantment.Deactivate(Player: Byte): Boolean;
begin
  if not FRemoved then
  begin
    FDispelPlayer := Player;
    FRemoved := True;
    if WorldMap^.FPlayMode = pmSimultaneous then FRestoreDays := 2
    else FRestoreDays := 1;
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.Update;
    WorldMap^.FGlobalMagicControl.Update;
    Result := True;
  end
  else Result := False;
end;

function TFlood.CreateEnchantment: TGlobalEnchantment;
begin Result := TFloodEnchantment.Create(nil); end;

constructor TFlood.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(FloodText));
  FSpellID := 50;
  FSpellType := stGlobal;
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msWater;
end;

procedure TFlood.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

function TFlood.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, L: Shortint;
  Twinkle: TTwinkleAnimation;
begin
  inherited ExecuteTE(A1, A2, A3);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  Twinkle := TTwinkleAnimation.Create(nil);
  Twinkle.Setup(WorldSet^.FSpellControl.GetSpell(50).FCastImages.ImageSequences[0],
    [tmRotate], 50, 64, 50, 30);
  WorldMap^.PlaceHX(Twinkle, X, Y, L);
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

constructor TLifeMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(LifeText));
  FEnchantmentType := getNone;
  FDispelMana := 175;
end;

class function TLifeMasteryEnchantment.ClassID: Integer;
begin Result := $2131F; end;

function TLifeMasteryEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 1250; end;

function TLifeMasteryEnchantment.CanActivate(Player: Shortint; var Reason: string): Boolean;
begin
  Result := inherited CanActivate(Player, Reason);
  if Result then
    if petLifeMastery in WorldMap^.FPlayers.GetPlayers(Player).FMagicControl.FActiveEnchantments then
    begin
      Reason := SysUtils.Format(TranslateRStr(LoadResString(AlreadyActiveText)), [GetName]);
      Result := False;
    end;
end;

function TLifeMasteryEnchantment.Activate(Player: Shortint): Boolean;
var
  APlayer: TPlayer;
  I, J: Integer;
begin
  inherited Activate(Player);
  WorldMap^.FGlobalMagicControl.IncDoubleSphereManaCount(msDeath); { Original doubles Death. }
  APlayer := WorldMap^.FPlayers.GetPlayers(FPlayerIndex);
  with APlayer.FMagicControl do
    SetActiveEnchantments(FActiveEnchantments + [petLifeMastery]);
  for I := APlayer.FArmies.Count - 1 downto 0 do
    for J := APlayer.FArmies.GetArmy(I).Count - 1 downto 0 do
      APlayer.FArmies.GetArmy(I).GetUnit(J).SetLifeMasteryBlessing;
  Result := True;
end;

function TLifeMasteryEnchantment.Deactivate(Player: Byte): Boolean;
var
  Msg: TEMsg;
begin
  inherited Deactivate(Player);
  WorldMap^.FGlobalMagicControl.DecDoubleSphereManaCount(msDeath); { Original doubles Death. }
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments - [petLifeMastery]);
  InitMsg(Msg, $20020100, Self);
  WorldMap^.SendMsg(Msg, Self);
  Result := True;
end;

constructor TLifeMastery.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellType := stGlobal;
  FSpellName := TranslateRStr(LoadResString(LifeText));
  FSpellID := 61;
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msCosmos; { Original assigns Cosmos to Life Mastery. }
  FCastDuration := 40;
  FAIBasePriority := 1000;
end;

function TLifeMastery.CreateEnchantment: TGlobalEnchantment;
begin Result := TLifeMasteryEnchantment.Create(nil); end;

function TLifeMastery.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, L: Shortint;
  Twinkle: TTwinkleAnimation;
begin
  inherited ExecuteTE(A1, A2, A3);
  NotifySpellSphere(A2.FPlayer, msLife);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  Twinkle := TTwinkleAnimation.Create(nil);
  Twinkle.Setup(WorldSet^.FSpellControl.GetSpell(61).FCastImages.ImageSequences[0],
    [tmRotate], 100, 64, 50, 30);
  WorldMap^.PlaceHX(Twinkle, X, Y, L);
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

constructor TDeathMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(DeathText));
  FEnchantmentType := getNone;
  FDispelMana := 175;
end;

class function TDeathMasteryEnchantment.ClassID: Integer;
begin Result := $21320; end;

function TDeathMasteryEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 1250; end;

function TDeathMasteryEnchantment.CanActivate(Player: Shortint; var Reason: string): Boolean;
begin
  Result := inherited CanActivate(Player, Reason);
  if Result then
    if petDeathMastery in WorldMap^.FPlayers.GetPlayers(Player).FMagicControl.FActiveEnchantments then
    begin
      Reason := SysUtils.Format(TranslateRStr(LoadResString(AlreadyActiveText)), [GetName]);
      Result := False;
    end;
end;

function TDeathMasteryEnchantment.Activate(Player: Shortint): Boolean;
begin
  inherited Activate(Player);
  WorldMap^.FGlobalMagicControl.IncDoubleSphereManaCount(msLife); { Original doubles Life. }
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments + [petDeathMastery]);
  Result := True;
end;

function TDeathMasteryEnchantment.Deactivate(Player: Byte): Boolean;
var
  Msg: TEMsg;
begin
  inherited Deactivate(Player);
  WorldMap^.FGlobalMagicControl.DecDoubleSphereManaCount(msLife); { Original doubles Life. }
  WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.SetActiveEnchantments(
    WorldMap^.FPlayers.GetPlayers(FPlayerIndex).FMagicControl.FActiveEnchantments - [petDeathMastery]);
  InitMsg(Msg, $20020101, Self);
  WorldMap^.SendMsg(Msg, Self);
  Result := True;
end;

procedure TDeathMasteryEnchantment.NewTurn(Player: Shortint);
var
  X, Y, L, Index: Integer;
  Flags: PByteArray; Mask: Integer;
  MapLevel: TMapLevel;
  Walk: THNWalkData;
  Border: Boolean;
begin
  Flags := nil;
  Mask := 1 shl (Player - 1);
  for L := 0 to WorldMap^.MapContainer.LevelCount - 1 do
  begin
    MapLevel := WorldMap^.MapContainer.GetMapLevel(L);
    Index := 0;
    ReallocMem(Flags, MapLevel.Width * MapLevel.Height);
    FillChar(Flags^, MapLevel.Width * MapLevel.Height, 0);
    for Y := 1 to MapLevel.Height - 1 do
      for X := 1 to MapLevel.Width - 2 do
      begin
        if TAoWMapField(MapLevel.GetField(X, Y)).FFieldFlags and Mask <> 0 then
        begin
          Border := False;
          InitHNWalk(Walk, X, Y, 1);
          while (Walk.Radius = 1) and not Border do
          begin
            if (Walk.X >= 0) and (Walk.X < MapLevel.Width) and
              (Walk.Y >= 0) and (Walk.Y < MapLevel.Height) then
              Border := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y)).FFieldFlags and Mask = 0;
            WalkToNextHN(Walk);
          end;
          if Border then Flags[Index] := 1;
        end;
        Inc(Index);
      end;
    Index := 0;
    for Y := 1 to MapLevel.Height - 1 do
      for X := 1 to MapLevel.Width - 2 do
      begin
        if Flags[Index] <> 0 then TAoWMapField(MapLevel.GetField(X, Y)).SetExplored(Player, False);
        Inc(Index);
      end;
  end;
  WorldMap^.UpdateVisibility;
  ReallocMem(Flags, 0);
end;

procedure TDeathMasteryEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then
    if LongBool(Msg.Value) then
      if petDeathMastery in WorldMap^.FPlayers.GetPlayers(Msg.Value).FMagicControl.FEnemyEnchantments then
        NewTurn(Msg.Value);
end;

constructor TDeathMastery.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellType := stGlobal;
  FSpellName := TranslateRStr(LoadResString(DeathText));
  FSpellID := 62;
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msCosmos; { Original assigns Cosmos to Death Mastery. }
  FCastDuration := 40;
  FAIBasePriority := 1000;
end;

function TDeathMastery.CreateEnchantment: TGlobalEnchantment;
begin Result := TDeathMasteryEnchantment.Create(nil); end;

procedure TDeathMastery.ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  I, Count, X, Y, Speed, D, Image: Integer;
begin
  RandSeed := WorldMap^.Frame - Anim.FFrameCounter;
  case WorldEngine^.FAnimationDetail of
    0: Count := 5;
    2: Count := 20;
  else Count := 10;
  end;
  for I := 0 to Count - 1 do
  begin
    X := Random(Anim.FTag and $FFFF);
    Y := Random(Cardinal(Anim.FTag) shr 16);
    Speed := Random(15) + 5;
    Image := Random(3);
    D := (Anim.FFrameCounter - 45) * Speed;
    Dec(X, D * 2);
    Inc(Y, D);
    FCastImages.Show(Image, SurfaceDesc.ClipRect.Left + X, SurfaceDesc.ClipRect.Top + Y, 0, SurfaceDesc);
  end;
  if Anim.FFrameCounter = 90 then Anim.Destroy;
end;

function TDeathMastery.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; { Near miss: register or temporary allocation differs after three variants. }
var
  X, Y, L: Shortint;
begin
  inherited ExecuteTE(A1, A2, A3);
  NotifySpellSphere(A2.FPlayer, msDeath);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  with TAnimation.Create(nil) do
  begin
    FAnimationLevel := 28;
    FOnShow := ShowAnimation;
    FAnimationMap := WorldMap^;
    FTag := (WorldMap^.ViewWidth and $FFFF) or (WorldMap^.ViewHeight shl 16);
    Activate;
  end;
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

constructor TFireMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(FireText));
  FEnchantmentType := getFireMastery;
  FDispelMana := 175;
end;

class function TFireMasteryEnchantment.ClassID: Integer;
begin Result := $21321; end;

function TFireMasteryEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 1250; end;

function TFireMasteryEnchantment.CanActivate(Player: Shortint; var Reason: string): Boolean;
begin
  if petFireMastery in WorldMap^.FPlayers.GetPlayers(Player).FMagicControl.FActiveEnchantments then
  begin
    Reason := SysUtils.Format(TranslateRStr(LoadResString(AlreadyActiveText)), [GetName]);
    Result := False;
  end
  else Result := True;
end;

function TFireMasteryEnchantment.Activate(Player: Shortint): Boolean;
var
  APlayer: TPlayer;
  I, J: Integer;
begin
  inherited Activate(Player);
  WorldMap^.FGlobalMagicControl.IncDoubleSphereManaCount(msWater); { Original doubles Water. }
  APlayer := WorldMap^.FPlayers.GetPlayers(FPlayerIndex);
  with APlayer.FMagicControl do
    SetActiveEnchantments(FActiveEnchantments + [petFireMastery]);
  for I := APlayer.FArmies.Count - 1 downto 0 do
    for J := APlayer.FArmies.GetArmy(I).Count - 1 downto 0 do
      APlayer.FArmies.GetArmy(I).GetUnit(J).SetFireMasteryProtection;
  UpdateFire(15, True);
  Result := True;
end;

function TFireMasteryEnchantment.Deactivate(Player: Byte): Boolean;
var
  APlayer: TPlayer;
  I, J: Integer;
begin
  inherited Deactivate(Player);
  APlayer := WorldMap^.FPlayers.GetPlayers(FPlayerIndex);
  with APlayer.FMagicControl do
    SetActiveEnchantments(FActiveEnchantments - [petFireMastery]);
  for I := APlayer.FArmies.Count - 1 downto 0 do
    for J := APlayer.FArmies.GetArmy(I).Count - 1 downto 0 do
      APlayer.FArmies.GetArmy(I).GetUnit(J).ResetFireMasteryProtection;
  WorldMap^.FGlobalMagicControl.DecDoubleSphereManaCount(msWater); { Original doubles Water. }
  Result := True;
end;

procedure TFireMasteryEnchantment.UpdateFire(Factor: Integer; Explosions: Boolean);
var
  X, Y, L, Chance: Integer;
  MapLevel: TMapLevel;
  Fire: TFire;
begin
  RandSeed := WorldMap^.Random($FFFFFF);
  for L := 0 to WorldMap^.MapContainer.LevelCount - 1 do
  begin
    MapLevel := WorldMap^.MapContainer.GetMapLevel(L);
    for Y := 1 to MapLevel.Height - 1 do
      for X := 1 to MapLevel.Width - 2 do
      begin
        Chance := IgnitionChance(TAoWMapField(MapLevel.GetField(X, Y)));
        if Chance > 0 then
          if WorldMap^.Random(10000) < Chance * Factor then
          begin
            Fire := WorldSet^.FFireControl.PlaceFire(X, Y, L, ftLarge);
            if Fire <> nil then
            begin
              if Explosions then Fire.SetupExplosion(Random(30));
              Fire.FTurnsLeft := 3;
            end;
          end;
      end;
  end;
end;

procedure TFireMasteryEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020003 then
    if LongBool(Msg.Value) then
      if petFireMastery in WorldMap^.FPlayers.GetPlayers(Msg.Value).FMagicControl.FActiveEnchantments then
        UpdateFire(2, not WorldMap^.FRequestCombatType);
end;

constructor TFireMastery.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellType := stGlobal;
  FSpellName := TranslateRStr(LoadResString(FireText));
  FSpellID := 63;
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msFire;
  FCastDuration := 40;
  FAIBasePriority := 1000;
end;

function TFireMastery.CreateEnchantment: TGlobalEnchantment;
begin Result := TFireMasteryEnchantment.Create(nil); end;

procedure TFireMastery.ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  FieldStep, Chance, Delay, X, Y, MaxY, Xhp, Yhp: Integer;
  MapLevel: TMapLevel;
  MaxX: Integer;
  MapF: TAoWMapField;
begin
  case WorldEngine^.FAnimationDetail of
    0: Chance := 2;
    2: Chance := 5;
  else Chance := 3;
  end;
  MapLevel := AoWE.AoWHSMap.MapContainer.GetMapLevel(AoWE.AoWHSMap.ViewL);
  FieldStep := MapLevel.FHNOffsets[0, 4];
  MaxX := AoWE.AoWHSMap.ViewXhx + AoWE.AoWHSMap.ViewWidthHX - 1;
  MaxY := AoWE.AoWHSMap.ViewYhx + AoWE.AoWHSMap.ViewHeightHX - 1;
  for X := AoWE.AoWHSMap.ViewXhx to MaxX do
  begin
    HXtoHP(X, AoWE.AoWHSMap.ViewYhx, Xhp, Yhp);
    Xhp := Xhp - XhpSurf + 16;
    Yhp := Yhp - YhpSurf + 16;
    MapF := TAoWMapField(MapLevel.GetField(X, AoWE.AoWHSMap.ViewYhx));
    for Y := AoWE.AoWHSMap.ViewYhx to MaxY do
    begin
      if not (MapF.TerrainType in [7, 8, 15] { Original excludes border terrain. }) and (AoWE.AoWHSMap.FSeatedPlayer <> -1) and
        (not AoWE.AoWHSMap.FExplorationEnabled or MapF.GetExplored(AoWE.AoWHSMap.FSeatedPlayer)) then
      begin
        RandSeed := MapF.Xhx + MapF.Yhx * 8 + (PByteArray(MapF)^[$1A] shl 16);
        if Random(100) < Chance then
        begin
          Delay := Random(40);
          FCastImages.Show(0, Xhp, Yhp, Anim.FFrameCounter - Delay, SurfaceDesc);
          if (Anim.FFrameCounter = Delay) and (WorldEngine^.FAnimationDetail <> 0) then
            Sound.PlaySample(ExplosionSFX[X mod 2]);
        end;
      end;
      MapF := TAoWMapField(Integer(MapF) + FieldStep);
      Inc(Yhp, 32);
    end;
  end;
  if Anim.FFrameCounter = 90 then Anim.Destroy;
end;

function TFireMastery.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; { Near miss: register or temporary allocation differs after three variants. }
var
  X, Y, L: Shortint;
begin
  if A3 = 0 then
  begin
    A2.GetLocation(X, Y, L);
    NotifySpellSphere(A2.FPlayer, msFire);
    WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
    with TAnimation.Create(nil) do
    begin
      FAnimationLevel := 27;
      FOnShow := ShowAnimation;
      FAnimationMap := WorldMap^;
      FTag := (WorldMap^.ViewWidth and $FFFF) or (WorldMap^.ViewHeight shl 16);
      Activate;
    end;
    FCastSounds.Play(0);
    CastingDone(A2, A1.FEventMana);
  end;
  if A3 = 20 then
  begin
    inherited ExecuteTE(A1, A2, 0);
    Result := False;
  end
  else Result := True;
end;

constructor TEarthMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(EarthText));
  FEnchantmentType := getNone;
  FDispelMana := 175;
end;

class function TEarthMasteryEnchantment.ClassID: Integer;
begin Result := $21322; end;

function TEarthMasteryEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 1250; end;

function TEarthMasteryEnchantment.CanActivate(Player: Shortint; var Reason: string): Boolean;
begin
  Result := inherited CanActivate(Player, Reason);
  if Result then
    if petEarthMastery in WorldMap^.FPlayers.GetPlayers(Player).FMagicControl.FActiveEnchantments then
    begin
      Reason := SysUtils.Format(TranslateRStr(LoadResString(AlreadyActiveText)), [FName]);
      Result := False;
    end;
end;

function TEarthMasteryEnchantment.Activate(Player: Shortint): Boolean;
var
  APlayer: TPlayer;
  I, J: Integer;
begin
  inherited Activate(Player);
  WorldMap^.FGlobalMagicControl.IncDoubleSphereManaCount(msAir); { Original doubles Air. }
  APlayer := WorldMap^.FPlayers.GetPlayers(FPlayerIndex);
  with APlayer.FMagicControl do
    SetActiveEnchantments(FActiveEnchantments + [petEarthMastery]);
  for I := APlayer.FArmies.Count - 1 downto 0 do
    for J := APlayer.FArmies.GetArmy(I).Count - 1 downto 0 do
      APlayer.FArmies.GetArmy(I).GetUnit(J).SetEarthMasteryStoneSkin;
  Result := True;
end;

function TEarthMasteryEnchantment.Deactivate(Player: Byte): Boolean;
var
  APlayer: TPlayer;
  I, J: Integer;
begin
  inherited Deactivate(Player);
  APlayer := WorldMap^.FPlayers.GetPlayers(FPlayerIndex);
  with APlayer.FMagicControl do
    SetActiveEnchantments(FActiveEnchantments - [petEarthMastery]);
  for I := APlayer.FArmies.Count - 1 downto 0 do
    for J := APlayer.FArmies.GetArmy(I).Count - 1 downto 0 do
      APlayer.FArmies.GetArmy(I).GetUnit(J).ResetEarthMasteryStoneSkin;
  WorldMap^.FGlobalMagicControl.DecDoubleSphereManaCount(msAir); { Original doubles Air. }
  Result := True;
end;

constructor TEarthMastery.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(EarthText));
  FSpellID := 64;
  FSpellType := stGlobal;
  FBaseManaCost := 1;
  FSpellLevel := 3;
  FMagicSphere := msEarth;
  FCastDuration := 40;
  FAIBasePriority := 1000;
end;

procedure TEarthMastery.ShowAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  X, MaxX, Y, MaxY, Xhp, Yhp, FieldStep: Integer;
  MapLevel: TMapLevel;
  MapF: TAoWMapField;
begin
  MapLevel := AoWE.AoWHSMap.MapContainer.GetMapLevel(AoWE.AoWHSMap.ViewL);
  FieldStep := MapLevel.FHNOffsets[0, 4];
  MaxX := AoWE.AoWHSMap.ViewXhx + AoWE.AoWHSMap.ViewWidthHX - 1;
  MaxY := AoWE.AoWHSMap.ViewYhx + AoWE.AoWHSMap.ViewHeightHX - 1;
  for X := AoWE.AoWHSMap.ViewXhx to MaxX do
  begin
    HXtoHP(X, AoWE.AoWHSMap.ViewYhx, Xhp, Yhp);
    Xhp := Xhp - XhpSurf + 16;
    Yhp := Yhp - YhpSurf + 16;
    MapF := TAoWMapField(MapLevel.GetField(X, AoWE.AoWHSMap.ViewYhx));
    for Y := AoWE.AoWHSMap.ViewYhx to MaxY do
    begin
      if Smallint(MapF.OverlayType) = 4 then
        FCastImages.Show(0, Xhp, Yhp,
          Anim.FFrameCounter - ((Cardinal(MapF) shr 8) and 15), SurfaceDesc); { Original uses the field address. }
      Inc(Integer(MapF), FieldStep);
      Inc(Yhp, 32);
    end;
  end;
  if Anim.FFrameCounter = 50 then Anim.Destroy;
end;

function TEarthMastery.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, L: Shortint;
begin
  inherited ExecuteTE(A1, A2, A3);
  NotifySpellSphere(A2.FPlayer, msEarth);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  WorldMap^.AddEffect(fxEarthMastery);
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

function TEarthMastery.CreateEnchantment: TGlobalEnchantment;
begin Result := TEarthMasteryEnchantment.Create(nil); end;

constructor TSpellWardEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FName := TranslateRStr(LoadResString(WardNameText));
  FEnchantmentType := getSpellWard;
  FDispelMana := 50;
end;

class function TSpellWardEnchantment.ClassID: Integer;
begin Result := $21323; end;

function TSpellWardEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 500; end;

constructor TSpellWard.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(WardNameText));
  FSpellID := 65;
  FSpellType := stGlobal;
  FBaseManaCost := 1;
  FSpellLevel := 3;
  FMagicSphere := msEarth;
end;

function TSpellWard.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, L: Shortint;
begin
  inherited ExecuteTE(A1, A2, A3);
  A2.GetLocation(X, Y, L);
  WorldMap^.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  WorldMap^.AddEffect(fxSpellWard);
  FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

function TSpellWard.CreateEnchantment: TGlobalEnchantment;
begin Result := TSpellWardEnchantment.Create(nil); end;

procedure RegisterGlobalEnchantmentSpells(AEngine: TAoWEngine);
var
  Control: TSpellControl;
begin
  Control := AEngine.FGameSet.FSpellControl;
  AEngine.RegisterEClasses([TEnchantedRoadsEnchantment, TGlobalEnchantmentSpellTE, TGlobalEnchantmentEventLog]);
  AEngine.RegisterEClasses([TWaterMasteryEnchantment, THatredEnchantment, THarmonyEnchantment, TPowerLeakEnchantment, TFloodEnchantment, TAirMasteryEnchantment]);
  AEngine.RegisterEClasses([TLifeMasteryEnchantment, TDeathMasteryEnchantment, TFireMasteryEnchantment, TEarthMasteryEnchantment, TSpellWardEnchantment]);
  Control.RegisterSpell(TEnchantedRoads.Create(nil));
  Control.RegisterSpell(THatred.Create(nil));
  Control.RegisterSpell(THarmony.Create(nil));
  Control.RegisterSpell(TPowerLeak.Create(nil));
  Control.RegisterSpell(TFlood.Create(nil));
  Control.RegisterSpell(TAirMastery.Create(nil));
  Control.RegisterSpell(TLifeMastery.Create(nil));
  Control.RegisterSpell(TDeathMastery.Create(nil));
  Control.RegisterSpell(TFireMastery.Create(nil));
  Control.RegisterSpell(TEarthMastery.Create(nil));
  Control.RegisterSpell(TWaterMastery.Create(nil));
  Control.RegisterSpell(TSpellWard.Create(nil));
end;

procedure UnregisterGlobalEnchantmentSpells(AEngine: TAoWEngine);
var
  Control: TSpellControl;
begin
  Control := AEngine.FGameSet.FSpellControl;
  Control.UnregisterSpellID(44);
  Control.UnregisterSpellID(46);
  Control.UnregisterSpellID(47);
  Control.UnregisterSpellID(48);
  Control.UnregisterSpellID(50);
  Control.UnregisterSpellID(60);
  Control.UnregisterSpellID(61);
  Control.UnregisterSpellID(62);
  Control.UnregisterSpellID(63);
  Control.UnregisterSpellID(64);
  Control.UnregisterSpellID(45);
  Control.UnregisterSpellID(65);
  AEngine.UnregisterEClasses([TEnchantedRoadsEnchantment, TGlobalEnchantmentSpellTE, TGlobalEnchantmentEventLog]);
  AEngine.UnregisterEClasses([TWaterMasteryEnchantment, THatredEnchantment, THarmonyEnchantment, TPowerLeakEnchantment, TFloodEnchantment, TAirMasteryEnchantment]);
  AEngine.UnregisterEClasses([TLifeMasteryEnchantment, TDeathMasteryEnchantment, TFireMasteryEnchantment, TEarthMasteryEnchantment, TSpellWardEnchantment]);
end;


initialization
finalization

end.
