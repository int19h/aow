unit SummonSpells;

{ SummonSpells, recovered from AoWEPACK.dpl at the original instance layouts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PassiveAb, Animation;

type
  TSummonSpellTE = class;
  TSummonSpell = class;
  TSummonSyron = class;
  TSummonFrog = class;
  TSummonBoar = class;
  TSummonAirElemental = class;
  TSummonEarthElemental = class;
  TSummonFireElemental = class;
  TSummonWaterElemental = class;
  TSummonGoldDragon = class;
  TSummonBlackDragon = class;
  TSummonGreatEagle = class;
  TSummonFireSprite = class;
  TSummonBlackSpider = class;
  TSummonMermaid = class;


  { TSummonSpellTE (instance size 36, VMT 557E2F28): $20 FUnitIndices. }
  TSummonSpellTE = class(TSpellTE)
  public
    FUnitIndices: TUnitIndexList; { $20 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
  end;

  { TSummonSpell (instance size 60, VMT 557E3004): $34 FAIBasePriority, $38 FUnitIndices. }
  TSummonSpell = class(TSpell)
  public
    FAIBasePriority: Integer; { $34 }
    FUnitIndices: TUnitIndexList; { $38 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); override;
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure SetupSummonSpellTE(Event: TSummonSpellTE); virtual; { +09C }
    function GetDispelResistance(AUnit: TAbstractUnit): Integer;
    function GetAIUpkeepPriority: Integer;
  end;

  { TSummonSyron (instance size 60, VMT 557E3120) }
  TSummonSyron = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonFrog (instance size 60, VMT 557E323C) }
  TSummonFrog = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonBoar (instance size 60, VMT 557E3354) }
  TSummonBoar = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonAirElemental (instance size 60, VMT 557E346C) }
  TSummonAirElemental = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonEarthElemental (instance size 60, VMT 557E3594) }
  TSummonEarthElemental = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonFireElemental (instance size 60, VMT 557E36C0) }
  TSummonFireElemental = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonWaterElemental (instance size 60, VMT 557E37EC) }
  TSummonWaterElemental = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonGoldDragon (instance size 60, VMT 557E3918) }
  TSummonGoldDragon = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonBlackDragon (instance size 60, VMT 557E3A3C) }
  TSummonBlackDragon = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonGreatEagle (instance size 60, VMT 557E3B64) }
  TSummonGreatEagle = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonFireSprite (instance size 60, VMT 557E3C88) }
  TSummonFireSprite = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSummonBlackSpider (instance size 60, VMT 557E3DAC) }
  TSummonBlackSpider = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupSummonSpellTE(Event: TSummonSpellTE); override;
  end;

  { TSummonMermaid (instance size 60, VMT 557E3ED4) }
  TSummonMermaid = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

procedure RegisterSummonSpells(AEngine: TAoWEngine);
procedure UnregisterSummonSpells(AEngine: TAoWEngine);

implementation

type
  PAoWMap = ^TAoWHSMap;
  PAoWSet = ^TAoWHSSet;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
  WorldSet: PAoWSet = @AoWE.AoWHSSet;
  NoLocationText: PResStringRec = @AoWE.NoSummonLocationFoundRStr;
  TSummonSyronText: PResStringRec = @AoWE.SummonSyronRStr;
  TSummonFrogText: PResStringRec = @AoWE.SummonFrogRStr;
  TSummonBoarText: PResStringRec = @AoWE.SummonBoarRStr;
  TSummonAirElementalText: PResStringRec = @AoWE.SummonAirElementalRStr;
  TSummonEarthElementalText: PResStringRec = @AoWE.SummonEarthElementalRStr;
  TSummonFireElementalText: PResStringRec = @AoWE.SummonFireElementalRStr;
  TSummonWaterElementalText: PResStringRec = @AoWE.SummonWaterElementalRStr;
  TSummonGoldDragonText: PResStringRec = @AoWE.SummonGoldDragonRStr;
  TSummonBlackDragonText: PResStringRec = @AoWE.SummonBlackDragonRStr;
  TSummonGreatEagleText: PResStringRec = @AoWE.SummonGreatEagleRStr;
  TSummonFireSpriteText: PResStringRec = @AoWE.SummonFireSpriteRStr;
  TSummonBlackSpiderText: PResStringRec = @AoWE.SummonBlackSpiderRStr;
  TSummonMermaidText: PResStringRec = @AoWE.SummonMermaidRStr;

constructor TSummonSpellTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIndices := TUnitIndexList.Create;
end;

destructor TSummonSpellTE.Destroy;
begin
  FUnitIndices.Free;
  inherited Destroy;
end;

class function TSummonSpellTE.ClassID: Integer;
begin
  Result := $2130B;
end;

procedure TSummonSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc($1E, FUnitIndices.LoadFromStream, FUnitIndices.SaveToStream);
end;

function TSummonSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  Done: Boolean;
  X, Y, L: Shortint;
  I: Integer;
  U: TUnit;
  Army: TArmyHS;
  Enchantment: TUnitEnchantment;
  Group: TAIGroup;
  Anim: TImageSequenceAnimation;
begin
  inherited Process(A1, A2);
  Done := False;
  A1.GetLocation(X, Y, L);
  for I := 0 to FUnitIndices.Count - 1 do
  begin
    U := TUnit.Create(nil);
    U.SetUnitResource(WorldSet^.FUnitResources.GetUnitResource(FUnitIndices[I]));
    Army := U.Place(X, Y, L, A1.FPlayer, [pmScanArea]);
    if Army <> nil then
      if dHXtoRad(X, Y, Army.GetXhx, Army.GetYhx) <= 2 then
      begin
        if U.ExpandAbility(155) then
        begin
          Enchantment := TUnitEnchantmentAbilityData(U.GetAbilityData(155)).FEnchantment;
          Enchantment.SetUpkeep(WorldSet^.FSpellControl.GetSpell(FEventSpellID).FManaUpkeep);
          Enchantment.SetSource(A1.FPlayer);
          Enchantment.FDispelResistance := TSummonSpell(WorldSet^.FSpellControl.GetSpell(FEventSpellID)).GetDispelResistance(U);
          Group := A1.FGroup;
          if Group <> nil then Group.AddUnit(U);
        end;
        Done := True;
      end
      else U.SetOwner(nil);
    U.Release;
  end;
  if Done then
  begin
    if A1.FPlayer = AoWHSMap.FSeatedPlayer then AoWHSMap.MakeVisible(X, Y, L, 3);
    AoWHSMap.ValidateObservation(A1.FPlayer, X, Y, L, 0);
    if AoWHSMap.Visible(X, Y, L, 0) then
    begin
      if WorldSet^.FSpellControl.GetSpell(FEventSpellID).FCastImages.ImageSequences[0] <> nil then
      begin
        Anim := TImageSequenceAnimation.Create(nil);
        Anim.SetImageSequence(WorldSet^.FSpellControl.GetSpell(FEventSpellID).FCastImages.ImageSequences[0]);
        AoWHSMap.PlaceHX(Anim, X, Y, L);
      end;
      if (A1.FPlayer = AoWHSMap.FSeatedPlayer) or AoWHSMap.Watching(X, Y, L, 0) then
        WorldSet^.FSpellControl.GetSpell(FEventSpellID).FCastSounds.Play(0);
    end;
    WorldSet^.FSpellControl.GetSpell(FEventSpellID).CastingDone(A1,
      WorldSet^.FSpellControl.GetSpell(FEventSpellID).FBaseManaCost);
  end
  else if A1.FPlayer = AoWHSMap.FSeatedPlayer then
    AoWHSMap.ShowMessage(TranslateRStr(LoadResString(NoLocationText)));
  Result := False;
end;

constructor TSummonSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIndices := TUnitIndexList.Create;
  FSpellType := stGlobal;
  FAIBasePriority := -1;
end;

destructor TSummonSpell.Destroy;
begin
  FUnitIndices.Free;
  inherited Destroy;
end;

function TSummonSpell.GetDispelResistance(AUnit: TAbstractUnit): Integer;
begin
  { Original looks up the summoned ability in the spell control. }
  Result := TSummonedAbility(WorldSet^.FSpellControl.GetSpell(155)).GetDefaultDispelResistance(AUnit);
end;

procedure TSummonSpell.SetupSummonSpellTE(Event: TSummonSpellTE);
begin
  Event.FUnitIndices.Add(FUnitIndices[Random(FUnitIndices.Count)]);
end;

function TSummonSpell.Activate(A1: TAbstractUnit): Boolean;
var
  Event: TSummonSpellTE;
  Reason: string;
begin
  if CanActivate(A1, Reason) then
  begin
    Event := TSummonSpellTE.Create(nil);
    Event.Initialize(FSpellID, A1.FPlayer, A1.FUnitID, FBaseManaCost);
    SetupSummonSpellTE(Event);
    WorldMap^.FTokenManager.GetTokenControl(A1.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TSummonSpell.GetAIUpkeepPriority: Integer;
begin
  Result := TSummonedAbility(WorldSet^.FAbilityControl.GetAbility(155)).UnitIndexToAIUpkeepPriority(FUnitIndices[0]);
end;

procedure TSummonSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
var
  CanCast: Boolean;
  Action: TAICastSpellAction;
  Reason: string;
begin
  if FAIBasePriority <> -1 then
  begin
    CanCast := AIRequestCastSpellExpense(A1, FBaseManaCost, FManaUpkeep, GetAIUpkeepPriority);
    CanCast := CanCast and THero(A1).CanCastSpell(FSpellID, Reason);
    if CanCast then
    begin
      Action := CreateCastSpellAction;
      SetupCastSpellAction(A1, Action);
      Action.FPriority := FAIBasePriority;
      Action.SetOwner(A2);
    end;
  end;
end;

function TSummonSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
var
  Reason: string;
begin
  with THero(A1) do
    if CanCastSpell(FSpellID, Reason) then
    begin
      AICastSpellExpenseMade(A1, FBaseManaCost, FManaUpkeep, GetAIUpkeepPriority);
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

constructor TSummonSyron.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonSyronText));
  FSpellID := 24;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msCosmos;
  FUnitIndices.Add(221);
  FCastDuration := 40;
  FAIBasePriority := 500;
end;

constructor TSummonFrog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonFrogText));
  FSpellID := 22;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msWater;
  FUnitIndices.Add(236);
  FCastDuration := 5;
  FAIBasePriority := 200;
end;

constructor TSummonBoar.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonBoarText));
  FSpellID := 31;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msEarth;
  FUnitIndices.Add(235);
  FCastDuration := 5;
end;

constructor TSummonAirElemental.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonAirElementalText));
  FSpellID := 27;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msAir;
  FUnitIndices.Add(224);
  FCastDuration := 40;
  FAIBasePriority := 750;
end;

constructor TSummonEarthElemental.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonEarthElementalText));
  FSpellID := 28;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msEarth;
  FUnitIndices.Add(225);
  FCastDuration := 40;
  FAIBasePriority := 750;
end;

constructor TSummonFireElemental.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonFireElementalText));
  FSpellID := 29;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msFire;
  FUnitIndices.Add(226);
  FCastDuration := 40;
  FAIBasePriority := 500;
end;

constructor TSummonWaterElemental.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonWaterElementalText));
  FSpellID := 30;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msWater;
  FUnitIndices.Add(227);
  FCastDuration := 40;
  FAIBasePriority := 500;
end;

constructor TSummonGoldDragon.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonGoldDragonText));
  FSpellID := 25;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msLife;
  FUnitIndices.Add(216);
  FCastDuration := 40;
  FAIBasePriority := 750;
end;

constructor TSummonBlackDragon.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonBlackDragonText));
  FSpellID := 26;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msDeath;
  FUnitIndices.Add(217);
  FCastDuration := 40;
  FAIBasePriority := 750;
end;

constructor TSummonGreatEagle.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonGreatEagleText));
  FSpellID := 23;
  FBaseManaCost := 5;
  FSpellLevel := 2;
  FMagicSphere := msAir;
  FUnitIndices.Add(234);
  FCastDuration := 10;
  FAIBasePriority := 250;
end;

constructor TSummonFireSprite.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonFireSpriteText));
  FSpellID := 21;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msFire;
  FUnitIndices.Add(228);
  FCastDuration := 10;
  FAIBasePriority := 200;
end;

procedure TSummonBlackSpider.SetupSummonSpellTE(Event: TSummonSpellTE);
begin
  inherited SetupSummonSpellTE(Event);
end;

constructor TSummonBlackSpider.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonBlackSpiderText));
  FSpellID := 20;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msDeath;
  FUnitIndices.Add(222);
  FCastDuration := 5;
  FAIBasePriority := 200;
end;

constructor TSummonMermaid.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LoadResString(TSummonMermaidText));
  FSpellID := 78;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msDeath;
  FUnitIndices.Add(218);
  FCastDuration := 5;
  FAIBasePriority := -1;
end;

procedure RegisterSummonSpells(AEngine: TAoWEngine);
var
  Control: TSpellControl;
begin
  Control := AEngine.FGameSet.FSpellControl;
  AEngine.RegisterEClasses([TSummonSpellTE]);
  Control.RegisterSpell(TSummonSyron.Create(nil));
  Control.RegisterSpell(TSummonFrog.Create(nil));
  Control.RegisterSpell(TSummonBoar.Create(nil));
  Control.RegisterSpell(TSummonAirElemental.Create(nil));
  Control.RegisterSpell(TSummonEarthElemental.Create(nil));
  Control.RegisterSpell(TSummonFireElemental.Create(nil));
  Control.RegisterSpell(TSummonWaterElemental.Create(nil));
  Control.RegisterSpell(TSummonGoldDragon.Create(nil));
  Control.RegisterSpell(TSummonBlackDragon.Create(nil));
  Control.RegisterSpell(TSummonGreatEagle.Create(nil));
  Control.RegisterSpell(TSummonFireSprite.Create(nil));
  Control.RegisterSpell(TSummonBlackSpider.Create(nil));
  Control.RegisterSpell(TSummonMermaid.Create(nil));
end;

procedure UnregisterSummonSpells(AEngine: TAoWEngine);
var
  Control: TSpellControl;
begin
  Control := AEngine.FGameSet.FSpellControl;
  AEngine.UnregisterEClasses([TSummonSpellTE]);
  Control.UnregisterSpellID(24);
  Control.UnregisterSpellID(22);
  Control.UnregisterSpellID(31);
  Control.UnregisterSpellID(27);
  Control.UnregisterSpellID(28);
  Control.UnregisterSpellID(29);
  Control.UnregisterSpellID(30);
  Control.UnregisterSpellID(25);
  Control.UnregisterSpellID(26);
  Control.UnregisterSpellID(23);
  Control.UnregisterSpellID(21);
  Control.UnregisterSpellID(20);
  Control.UnregisterSpellID(78);
end;

initialization
finalization

end.
