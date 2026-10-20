unit GlobalSpells;

{ Draft declarations of GlobalSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TConcealAreaHS through TDisjunctionSpellCaster are recovered;
  TDisjunction and the hero spells remain drafts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TConcealAreaHS = class;
  TConcealArea = class;
  TBirdsViewHS = class;
  TBirdsView = class;
  TWarpPartyTE = class;
  TWarpParty = class;
  TResurrectHero = class;
  TAnimateHero = class;
  TCallHero = class;
  TDisjunctionTE = class;
  TDisjunctionSpellCaster = class;
  TDisjunction = class;
  TCrusade = class;


  { TConcealAreaHS (instance size 24, VMT 557E8FBC): $0C/$0D/$0E
    X/Y/layer, $0F padding, $10 explored hexagons, $14 animation frame. }
  TConcealAreaHS = class(TFixedVisibleHS)
  public
    FX: Shortint;
    FY: Shortint;
    FLayer: Shortint;
    F_ConcealAreaHS_0F: array[0..0] of Byte;
    FHexagons: TIntegerList;
    FFrame: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure StartAnimation(X,Y,Layer,Radius: Shortint);
    procedure StopAnimation;  { draft }
  end;

  { TConcealArea (instance size 52, VMT 557E9144) }
  TConcealArea = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function GetEnabled: Boolean; override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TBirdsViewHS (instance size 24, VMT 557E925C): $0C/$0D/$0E
    X/Y/layer, $0F padding, $10 unexplored hexagons, $14 animation frame. }
  TBirdsViewHS = class(TFixedVisibleHS)
  public
    FX: Shortint;
    FY: Shortint;
    FLayer: Shortint;
    F_BirdsViewHS_0F: array[0..0] of Byte;
    FHexagons: TIntegerList;
    FFrame: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure StartAnimation(X,Y,Layer,Radius: Shortint);
    procedure StopAnimation;  { draft }
  end;

  { TBirdsView (instance size 52, VMT 557E93E0): inherited $08 name, $10 spell ID,
    $14 mana, $20 sphere, $21 level, $22 spell type. }
  TBirdsView = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function GetEnabled: Boolean; override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TWarpPartyTE (instance size 40, VMT 557E94F4): $20 army ID, $24 packed destination. }
  TWarpPartyTE = class(TSpellTE)
  public
    FArmyID: TArmyID; { $20 }
    FWarpLocation: TXYL; { $24 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
  end;

  { TWarpParty (instance size 52, VMT 557E95CC): inherited $08 name, $10 ID,
    $14 mana, $20 sphere, $21 level, $22 spell type. }
  TWarpParty = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    function ValidTarget(Army: TArmyHS; X, Y, Layer: Shortint): Boolean;
    function CalculateWarpLocation(Army: TArmyHS): Integer;
  end;

  { TResurrectHero (instance size 52, VMT 557E96E0) }
  TResurrectHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TAnimateHero (instance size 52, VMT 557E97FC) }
  TAnimateHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TCallHero (instance size 52, VMT 557E9914) }
  TCallHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure FindCallHero(A1: Integer);  { draft }
  end;

  { TDisjunctionTE (instance size 40, VMT 557E9A24): $20 dispel chance, $24 enchantment ID. }
  TDisjunctionTE = class(TSpellTE)
  public
    FDispelChance: Integer; { $20 }
    FEnchantmentID: Integer; { $24 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
  end;

  { TDisjunctionSpellCaster (instance size 28, VMT 557E9B00): $14 enchantment ID,
    $18 dispel chance; inherited $08 spell ID, $0C source unit ID, $10 references. }
  TDisjunctionSpellCaster = class(TSpellCaster)
  public
    FEnchantmentID: Integer; { $14 }
    FDispelChance: Integer; { $18 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CanCast(var Reason: string): Boolean; override;
    function Cast: Boolean; override;
    procedure SetEnchantmentID(A1: Integer);
    function SelectedEnchantment: TGlobalEnchantment;
    function GetMana: Integer;
    procedure SetDispelChance(A1: Integer);
    function GetDispelChanceMax: Integer;
    function GetEnoughMana: Boolean;
  end;

  { TDisjunction (instance size 52, VMT 557E9BE4) }
  TDisjunction = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TCrusade (instance size 52, VMT 557E9CFC) }
  TCrusade = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure PlaceParty(A1: Integer; A2: Integer);  { draft }
  end;

procedure RegisterGlobalSpells(A1: Integer);  { draft }
procedure UnregisterGlobalSpells(A1: Integer);  { draft }

implementation

uses EventLog, Animation;

type
  PGlobalSpellMap = ^TAoWHSMap;
  PGlobalSpellSet = ^TAoWHSSet;
  PGlobalSpellEngine = ^TAoWEngine;
  TGlobalSpellEngineFields = packed record
    Reserved: array[0..$6C] of Byte;
    Detail: Byte;
  end;
const
  GlobalSpellMap: PGlobalSpellMap = @AoWHSMap;
  GlobalSpellSet: PGlobalSpellSet = @AoWHSSet;
  GlobalSpellEngine: PGlobalSpellEngine = @AoWEngine;

{ needs: pointer and Boolean results on the shared procedure drafts. }
constructor TConcealAreaHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FHexagons := TIntegerList.Create;
end;

destructor TConcealAreaHS.Destroy;
begin
  FHexagons.Free;
  inherited Destroy;
end;

function TConcealAreaHS.GetShowPriority: Integer;
begin Result := $78000000; end;

procedure TConcealAreaHS.StartAnimation(X,Y,Layer,Radius: Shortint);
var
  Walk: THNWalkData;
  Level: TMapLevel;
begin
  FX := X;
  FY := Y;
  FLayer := Layer;
  FFrame := 0;
  TSFXLibrary(TSpellControl(GlobalSpellSet^.FSpellControl).GetSpell(1).
    FCastSounds).Play(0);
  GlobalSpellMap^.DynamicFixedVisibleHS.AddChild(Self);
  InitHNWalk(Walk,FX,FY,0);
  Level := GlobalSpellMap^.MapContainer.MapLevels[FLayer];
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      if TAoWMapField(Level.GetField(Walk.X,Walk.Y)).GetExplored(GlobalSpellMap^.FSeatedPlayer) then FHexagons.Add(Walk.HN);
    WalkToNextHN(Walk);
  end;
end;

procedure TConcealAreaHS.StopAnimation;
begin
  GlobalSpellMap^.DynamicFixedVisibleHS.RemoveChild(Self);
  GlobalSpellMap^.DynamicVisibleHS.RemoveChild(Self);
  Destroy;
end;

procedure TConcealAreaHS.Show(XhpSurf: Integer; YhpSurf: Integer;
  const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp,Yhp,HX,HY,Intensity,Radius,Direction,X,Y: Integer;
  I,Delay: Integer;
begin
  if GlobalSpellMap^.ViewL = FLayer then
  begin
    Inc(FFrame);
    if (GlobalSpellEngine^.FAnimationDetail = 2) and
      (GlobalSpellMap^.ViewL = FLayer) then
    begin
      Intensity := 60-Abs(FFrame*3-60);
      HXtoHP(FX,FY,Xhp,Yhp);
      Xhp := Xhp-XhpSurf-8;
      Dec(Yhp,YhpSurf);
      for I := FHexagons.Count-1 downto 0 do
      begin
        HNtoHP(FHexagons[I],HX,HY);
        Inc(HX,Xhp);
        Inc(HY,Yhp);
        TCustomImageLibrary(GlobalSpellSet^.FGeneralImages)[5].
          ShowBlended(HX,HY,SurfaceDesc,AlphaBlendTable.LookupTables[Intensity]);
      end;
    end;
    { Original bug: Xhp/Yhp are uninitialized outside high detail. }
    RandSeed := GlobalSpellMap^.FInitialRandomSeed;
    for I := 0 to 200 do
    begin
      Radius := Random(448);
      Direction := Random(360);
      Delay := Random(20);
      if FFrame-Delay >= 0 then
      begin
        AoWE.DegreesRadToCo(Direction,Radius,X,Y);
        TImageSequenceList(TSpellControl(GlobalSpellSet^.FSpellControl).GetSpell(57).FCastImages).Show(0,Xhp+X,Yhp+Y,FFrame-Delay,SurfaceDesc);
      end;
    end;
    if FFrame = 40 then StopAnimation;
  end;
end;

type
  TGlobalSpellNameFields = packed record
    Reserved: array[0..7] of Byte;
    Name: string;
  end;

constructor TConcealArea.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TGlobalSpellNameFields(Pointer(Self)^).Name := AoWE.TranslateRStr(ConcealAreaRStr);
  FSpellID := 1;
  FSpellType := stGlobal;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msEarth;
end;

function TConcealArea.GetEnabled: Boolean;
asm
  { needs: Boolean result on TSpell.GetEnabled. }
  MOV EAX,[GlobalSpellMap]
  MOV EAX,[EAX]
  MOV AL,[EAX+$C9]
end;

type
  PGlobalSpellString = ^string;
resourcestring
  GlobalSpellXCastRStr = '%s cast';

procedure GlobalBaseExecute(Spell: TSpell; Event: TSpellTE; Caster: TAbstractUnit); assembler;
asm JMP TSpell.ExecuteTE end;

function GlobalPlayerRelation(List: TPlayerList; Player,Other: Byte): Byte; assembler;
asm JMP TPlayerList.GetDiplomaticRelation end;

procedure GlobalSetExplored(MapF: TAoWMapField; Player: Byte; Explored: Boolean); assembler;
asm JMP TAoWMapField.SetExplored end;

function ExecuteConcealArea(Spell: TConcealArea; Event: TSpellTE;
  Caster: TAbstractUnit): Boolean;
var
  MapF: TAoWMapField;
  X,Y,Layer: Shortint;
  Player: Integer;
  Walk: THNWalkData;
  Level: TMapLevel;
  Log: TLocationTextEventLog;
begin
  GlobalBaseExecute(Spell,Event,Caster);
  Spell.CastingDone(Caster,Spell.FBaseManaCost);
  Caster.GetLocation(X,Y,Layer);
  if Caster.FPlayer = GlobalSpellMap^.FSeatedPlayer then
    TConcealAreaHS.Create(nil).StartAnimation(X,Y,Layer,14);
  for Player := 1 to TPlayerList(GlobalSpellMap^.FPlayers).Count-1 do
  begin
    Level := GlobalSpellMap^.MapContainer.MapLevels[Layer];
    if (GlobalPlayerRelation(TPlayerList(GlobalSpellMap^.FPlayers),
      Caster.FPlayer,Player) = 1) and (Player <> Shortint(Caster.FPlayer)) then
    begin
      Log := nil;
      InitHNWalk(Walk,X,Y,0);
      while Walk.Radius < 15 do
      begin
        if (Walk.X >= 0) and (Walk.Y >= 0) and
          (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        begin
          MapF := TAoWMapField(Level.GetField(Walk.X,Walk.Y));
          if MapF.GetExplored(Player) and
            not GlobalSpellMap^.VisibleForPlayer(Walk.X,Walk.Y,Layer,Player) then
          begin
            GlobalSetExplored(MapF,Player,False);
            if Log = nil then
            begin
              Log := TLocationTextEventLog.Create(nil);
              Log.FXhx := Walk.X;
              Log.FYhx := Walk.Y;
              Log.FLhx := Layer;
              Log.FPlayer := Caster.FPlayer;
              PGlobalSpellString(@Log.FText)^ :=
                SysUtils.Format(AoWE.TranslateRStr(GlobalSpellXCastRStr),
                  [AoWE.TranslateRStr(ConcealAreaRStr)]);
              TEventLogbook(TPlayerList(GlobalSpellMap^.FPlayers).GetPlayers(Player).FEventLogbook).AddEvent(Log);
              Log.Release;
            end;
          end;
        end;
        WalkToNextHN(Walk);
      end;
    end
    else if GlobalSpellMap^.VisibleForPlayer(X,Y,Layer,Player) then
    begin
      Log := TLocationTextEventLog.Create(nil);
      Log.FXhx := X;
      Log.FYhx := Y;
      Log.FLhx := Layer;
      Log.FPlayer := Caster.FPlayer;
      PGlobalSpellString(@Log.FText)^ :=
        SysUtils.Format(AoWE.TranslateRStr(GlobalSpellXCastRStr),
          [AoWE.TranslateRStr(ConcealAreaRStr)]);
      TEventLogbook(TPlayerList(GlobalSpellMap^.FPlayers).GetPlayers(Player).FEventLogbook).AddEvent(Log);
      Log.Release;
    end;
  end;
  Result := False;
end;

function TConcealArea.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
asm
  { needs: ExecuteTE(Event, Caster): Boolean; the shared draft adds a stack arg. }
  POP EBP
  JMP ExecuteConcealArea
end;

function GlobalBaseCanActivate(Spell: TSpell; Caster: TAbstractUnit;
  var Message: string): Boolean; assembler;
asm JMP TSpell.CanActivate end;

function GlobalDiplomaticRelation(Relations: TPlayerDiplomaticRelations;
  Player: Shortint): Byte; assembler;
asm JMP TPlayerDiplomaticRelations.GetDiplomaticRelation end;

function CanConcealArea(Spell: TConcealArea; Caster: TAbstractUnit;
  var Message: string): Boolean;
var
  War: Boolean;
  Player: Shortint;
begin
  Result := GlobalBaseCanActivate(Spell,Caster,Message);
  if Result then
  begin
    War := False;
    for Player := 1 to TPlayerList(GlobalSpellMap^.FPlayers).Count-1 do
      War := War or (GlobalDiplomaticRelation(TPlayerDiplomaticRelations(
        TPlayerList(GlobalSpellMap^.FPlayers).GetPlayers(Shortint(Caster.FPlayer)).FDiplomaticRelations),Player) = 1);
    if not War then
    begin
      Message := SysUtils.Format(AoWE.TranslateRStr(AWarRelationIsRequiredForXRStr),
        [AoWE.TranslateRStr(ConcealAreaRStr)]);
      Result := False;
    end;
  end;
end;

function TConcealArea.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
asm
  { needs: Boolean result and var string on the shared TSpell.CanActivate. }
  JMP CanConcealArea
end;

procedure GlobalBaseActivate(Spell: TSpell; Caster: TAbstractUnit;
  Activation: Integer); assembler;
asm JMP TSpell.Activate end;

function GlobalVirtualCanActivate(Spell: TSpell; Caster: TAbstractUnit;
  var Message: string): Boolean; assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$68]; POP EBX end;

function ActivateConcealArea(Spell: TConcealArea; Caster: TAbstractUnit;
  Activation: Integer): Boolean;
var
  Message: string;
  Event: TSpellTE;
begin
  GlobalBaseActivate(Spell,Caster,Activation);
  Result := False;
  if GlobalVirtualCanActivate(Spell,Caster,Message) and
    not TPlayerList(GlobalSpellMap^.FPlayers).GetPlayers(Shortint(Caster.FPlayer)).GetBusy() then
  begin
    Event := TSpellTE.Create(nil);
    Event.Initialize(Spell.FSpellID,Caster.FPlayer,
      Caster.FUnitID,Spell.FBaseManaCost);
    TTokenManager(GlobalSpellMap^.FTokenManager).
      GetTokenControl(Shortint(Caster.FPlayer)).Add(Event);
    Event.Release;
    Result := True;
  end;
end;

function TConcealArea.Activate(A1: TAbstractUnit): Boolean;
asm
  { needs: Boolean result on the shared TSpell.Activate. }
  JMP ActivateConcealArea
end;

constructor TBirdsViewHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FHexagons := TIntegerList.Create;
end;

destructor TBirdsViewHS.Destroy;
begin
  FHexagons.Free;
  inherited Destroy;
end;

function TBirdsViewHS.GetShowPriority: Integer;
begin Result := $78000000; end;

procedure TBirdsViewHS.StartAnimation(X,Y,Layer,Radius: Shortint);
var
  Walk: THNWalkData;
  Level: TMapLevel;
begin
  FX := X;
  FY := Y;
  FLayer := Layer;
  FFrame := 0;
  TSFXLibrary(TSpellControl(GlobalSpellSet^.FSpellControl).GetSpell(2).
    FCastSounds).Play(0);
  InitHNWalk(Walk,X,Y,0);
  Level := GlobalSpellMap^.MapContainer.MapLevels[Layer];
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      if not TAoWMapField(Level.GetField(Walk.X,Walk.Y)).GetExplored(GlobalSpellMap^.FSeatedPlayer) then FHexagons.Add(Walk.HN);
    WalkToNextHN(Walk);
  end;
  GlobalSpellMap^.DynamicFixedVisibleHS.AddChild(Self);
end;

procedure TBirdsViewHS.StopAnimation;
begin
  GlobalSpellMap^.DynamicFixedVisibleHS.RemoveChild(Self);
  GlobalSpellMap^.DynamicVisibleHS.RemoveChild(Self);
  Destroy;
end;

procedure TBirdsViewHS.Show(XhpSurf: Integer; YhpSurf: Integer;
  const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp,Yhp,HX,HY,Intensity,Radius,Direction,X,Y: Integer;
  I,Delay: Integer;
begin
  if GlobalSpellMap^.ViewL = FLayer then
  begin
    Inc(FFrame);
    Intensity := 100-FFrame*2;
    HXtoHP(FX,FY,Xhp,Yhp);
    Xhp := Xhp-XhpSurf-8;
    Dec(Yhp,YhpSurf);
    for I := 0 to FHexagons.Count-1 do
    begin
      HNtoHP(FHexagons[I],HX,HY);
      Inc(HX,Xhp);
      Inc(HY,Yhp);
      TCustomImageLibrary(GlobalSpellSet^.FGeneralImages)[5].
        ShowBlended(HX,HY,SurfaceDesc,AlphaBlendTable.LookupTables[Intensity]);
    end;
    RandSeed := GlobalSpellMap^.FInitialRandomSeed;
    for I := 0 to 200 do
    begin
      Radius := Random(448);
      Direction := Random(360);
      Delay := Random(30);
      if FFrame-Delay >= 0 then
      begin
        AoWE.DegreesRadToCo(Direction,Radius,X,Y);
        TImageSequenceList(TSpellControl(GlobalSpellSet^.FSpellControl).
          GetSpell(57).FCastImages).Show(0,Xhp+X,Yhp+Y,FFrame-Delay,SurfaceDesc);
      end;
    end;
    if FFrame = 50 then StopAnimation;
  end;
end;

constructor TBirdsView.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(BirdsViewRStr);
  FSpellID := 2;
  FSpellType := stGlobal;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msAir;
end;

function TBirdsView.GetEnabled: Boolean;
begin
  Result := AoWHSMap.FExplorationEnabled;
end;

function TBirdsView.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, Layer: Shortint;
begin
  inherited ExecuteTE(A1, A2, A3);
  CastingDone(A2, A1.FEventMana);
  A2.GetLocation(X, Y, Layer);
  if AoWHSMap.FSeatedPlayer = A2.FPlayer then
    with TBirdsViewHS.Create(nil) do StartAnimation(X, Y, Layer, 14);
  AoWHSMap.ExploreArea(X, Y, Layer, A2.FPlayer, 14);
  Result := False;
end;

function TBirdsView.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
var
  X, Y, Layer: Shortint;
begin
  Result := inherited CanActivate(A1, A2);
  if Result then
  begin
    A1.GetLocation(X, Y, Layer);
    if Layer <> 0 then
    begin
      A2 := TranslateRStr(CannotCastSpellInUndergoundRStr);
      Result := False;
    end;
  end;
end;

function TBirdsView.Activate(A1: TAbstractUnit): Boolean;
var
  Reason: string;
  Event: TSpellTE;
begin
  inherited Activate(A1);
  if CanActivate(A1, Reason) and not AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).GetBusy then
  begin
    Event := TSpellTE.Create(nil);
    Event.Initialize(FSpellID, A1.FPlayer, A1.FUnitID, FBaseManaCost);
    AoWHSMap.FTokenManager.GetTokenControl(A1.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else
    Result := False;
end;

constructor TWarpPartyTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FArmyID := nil;
end;

destructor TWarpPartyTE.Destroy;
begin
  FArmyID.Free;
  inherited Destroy;
end;

class function TWarpPartyTE.ClassID: Integer;
begin
  Result := $2130C;
end;

procedure TWarpPartyTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FWarpLocation.XYL, 30);
  Stream.rwCreateEObject(TEObject(FArmyID), nil, 31);
end;

function TWarpPartyTE.Validate(A1: THero): Boolean;
var
  Selection: Byte;
  Army: TArmyHS;
begin
  Result := inherited Validate(A1) and FArmyID.Valid;
  if Result then
  begin
    FArmyID.RetrieveArmy(Army, Selection);
    Result := TWarpParty(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).ValidTarget(
      Army, FWarpLocation.X, FWarpLocation.Y, FWarpLocation.L);
  end;
end;

function TWarpPartyTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  ShowSource, ShowTarget: Boolean;
  Selection: Byte;
  X, Y, Layer: Shortint;
  Army: TArmyHS;
  Field: TMapField;
  Animation: TImageSequenceAnimation;
begin
  inherited Process(A1, A2);
  A1.GetLocation(X, Y, Layer);
  FArmyID.RetrieveArmy(Army, Selection);
  Field := AoWHSMap.MapContainer.GetFieldXYL(FWarpLocation.XYL);
  Army.MoveTo(Field, 0);
  ShowSource := (AoWHSMap.FSeatedPlayer = A1.FPlayer) or
    AoWHSMap.VisibleForPlayer(X, Y, Layer, AoWHSMap.FSeatedPlayer);
  ShowTarget := (AoWHSMap.FSeatedPlayer = A1.FPlayer) or
    AoWHSMap.VisibleForPlayer(Field.Xhx, Field.Yhx, Field.Lhx, AoWHSMap.FSeatedPlayer);
  if ShowSource and (AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastImages[0] <> nil) then
  begin
    Animation := TImageSequenceAnimation.Create(nil);
    Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastImages[0]);
    AoWHSMap.PlaceHX(Animation, X, Y, Layer);
  end;
  if ShowTarget and (AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastImages[0] <> nil) then
  begin
    Animation := TImageSequenceAnimation.Create(nil);
    Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastImages[0]);
    AoWHSMap.PlaceHX(Animation, Field.Xhx, Field.Yhx, Field.Lhx);
  end;
  if A1.FPlayer = AoWHSMap.FSeatedPlayer then
    AoWHSMap.CenterViewTo(Field.Xhx, Field.Yhx, Field.Lhx)
  else
    AoWHSMap.ValidateObservation(A1.FPlayer, Field.Xhx, Field.Yhx, Field.Lhx, 0);
  if (A1.FPlayer = AoWHSMap.FSeatedPlayer) or AoWHSMap.Watching(X, Y, Layer, 0) or
    AoWHSMap.Watching(Field.Xhx, Field.Yhx, Field.Lhx, 0) then
    AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastSounds.Play(0);
  AoWHSSet.FSpellControl.GetSpell(FEventSpellID).CastingDone(A1,
    AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FBaseManaCost);
  Result := False;
end;

constructor TWarpParty.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(WarpPartyRStr);
  FSpellID := 34;
  FSpellType := stGlobal;
  FBaseManaCost := 1;
  FSpellLevel := 2;
  FMagicSphere := msFire;
end;

function TWarpParty.ValidTarget(Army: TArmyHS; X, Y, Layer: Shortint): Boolean;
var
  Field: TAoWMapField;
  Msg: TMapFieldMsg;
begin
  Field := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, Layer));
  Result := (Field.GetArmyHS = nil) and (Field.GetPlayer = -1);
  if Result then
  begin
    Msg.MsgID := $1120;
    Msg.Param[0] := Integer(Army);
    Msg.Result := 0;
    Field.SendMapFieldMsg(Msg);
    Result := (Msg.Result = 0) and Army.FArmy.CanPlace(X, Y, Layer);
  end;
end;

function TWarpParty.CalculateWarpLocation(Army: TArmyHS): Integer;
var
  Candidates: TList;
  Table: TP2MovePointTable;
  Msg: TMapFieldMsg;
  Walk: THNWalkData;
  Level: TMapLevel;
  Field: TAoWMapField;
  L, I: Integer;
  Found: Boolean;
begin
  Candidates := TList.Create;
  Army.FArmy.CreateMovePointTable($FF, Table);
  InitHNWalk(Walk, Army.Xhx, Army.Yhx, 10);
  Level := AoWHSMap.MapContainer.MapLevels[Army.Lhx];
  while Walk.Radius < 20 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Field := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
      if Table[Field.TerrainType, Field.OverlayType] <> -1 then Candidates.Add(Field);
    end;
    WalkToNextHN(Walk);
  end;
  for L := 0 to AoWHSMap.MapContainer.LevelCount - 1 do
    if Abs(L - Army.Lhx) = 1 then
    begin
      Level := AoWHSMap.MapContainer.MapLevels[L];
      InitHNWalk(Walk, Army.Xhx, Army.Yhx, 0);
      while Walk.Radius < 10 do
      begin
        if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        begin
          Field := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
          if Table[Field.TerrainType, Field.OverlayType] <> -1 then Candidates.Add(Field);
        end;
        WalkToNextHN(Walk);
      end;
    end;
  Found := False;
  Result := $FFFFFF;
  while (Candidates.Count <> 0) and not Found do
  begin
    I := Random(Candidates.Count);
    Field := Candidates[I];
    if (Field.GetArmyHS = nil) and (Field.GetPlayer = -1) then
    begin
      Msg.MsgID := $1120;
      Msg.Param[0] := Integer(Army);
      Msg.Result := 0;
      Field.SendMapFieldMsg(Msg);
      Found := (Msg.Result = 0) and Army.FArmy.CanPlace(Field.Xhx, Field.Yhx, Field.Lhx);
    end;
    if Found then Result := Field.GetXYL
    else Candidates.Delete(I);
  end;
  Candidates.Free;
end;

function TWarpParty.Activate(A1: TAbstractUnit): Boolean;
var
  Reason: string;
  Event: TWarpPartyTE;
begin
  inherited Activate(A1);
  if CanActivate(A1, Reason) and not AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).GetBusy then
  begin
    Event := TWarpPartyTE.Create(nil);
    Event.Initialize(FSpellID, A1.FPlayer, A1.FUnitID, FBaseManaCost);
    Event.FArmyID := TArmy(A1.Owner).CreateID($FF);
    Event.FWarpLocation.XYL := CalculateWarpLocation(TArmy(A1.Owner).GetArmyHS);
    AoWHSMap.FSelectedArmy.Unselect;
    if Event.FWarpLocation.XYL <> $FFFFFF then
    begin
      AoWHSMap.FTokenManager.GetTokenControl(A1.FPlayer).AddEvent(Event);
      Result := True;
    end
    else
      Result := False;
    Event.Release;
  end
  else
    Result := False;
end;

class function TDisjunctionTE.ClassID: Integer;
begin
  Result := $21319;
end;

procedure TDisjunctionTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FEnchantmentID, 20);
  Stream.rwInteger(FDispelChance, 21);
end;

function TDisjunctionTE.Validate(A1: THero): Boolean;
var
  Index: Integer;
begin
  Result := inherited Validate(A1);
  Index := AoWHSMap.FGlobalMagicControl.IndexOfID(FEnchantmentID);
  Result := Result and (Index <> -1);
  if Result then
  begin
    with AoWHSMap.FGlobalMagicControl.FEnchantments.GetEnchantments(Index) do
      Result := AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).FMagicControl.FMana + A1.FCastingProgress >=
        Round(FDispelMana * 0.02 * FDispelChance) + FEventMana;
  end;
end;

function TDisjunctionTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  Enchantment: TGlobalEnchantment;
  Index: Integer;
  X, Y, Layer: Shortint;
  Twinkle: TTwinkleAnimation;
  Mana: Integer;
begin
  inherited Process(A1, A2);
  Index := AoWHSMap.FGlobalMagicControl.IndexOfID(FEnchantmentID);
  Enchantment := AoWHSMap.FGlobalMagicControl.FEnchantments.GetEnchantments(Index);
  A1.GetLocation(X, Y, Layer);
  AoWHSMap.ValidateObservation(A1.FPlayer, X, Y, Layer, 0);
  Twinkle := TTwinkleAnimation.Create(nil);
  Twinkle.Setup(AoWHSSet.FSpellControl.GetSpell(51).FCastImages[0],
    [tmExpand, tmExplode], FEventMana + 50, 192, 50, 30);
  AoWHSMap.PlaceHX(Twinkle, X, Y, Layer);
  AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastSounds.Play(0);
  Mana := Round(Enchantment.FDispelMana * 0.02 * FDispelChance);
  AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).FMagicControl.SetMana(
    AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).FMagicControl.FMana - Mana);
  if AoWHSMap.Random(100) < FDispelChance then
  begin
    if AoWHSMap.FSeatedPlayer = A1.FPlayer then
      AoWHSMap.ShowMessage(Format(TranslateRStr(XSuccessfullyDispelledRStr), [Enchantment.GetName]));
    AoWHSMap.FGlobalMagicControl.ExecuteDispelEnchantment(A1.FPlayer, FEnchantmentID);
  end
  else if AoWHSMap.FSeatedPlayer = A1.FPlayer then
    { Original formats this message with an unused enchantment-name argument. }
    AoWHSMap.ShowMessage(Format(TranslateRStr('Dispel Magic failed'), [Enchantment.GetName]));
  AoWHSSet.FSpellControl.GetSpell(FEventSpellID).CastingDone(A1, FEventMana);
  Result := False;
end;

constructor TDisjunctionSpellCaster.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDispelChance := 50;
end;

procedure TDisjunctionSpellCaster.SetEnchantmentID(A1: Integer);
begin
  FEnchantmentID := A1;
end;

function TDisjunctionSpellCaster.SelectedEnchantment: TGlobalEnchantment;
var
  Index: Integer;
begin
  Index := AoWHSMap.FGlobalMagicControl.IndexOfID(FEnchantmentID);
  if Index <> -1 then
    Result := AoWHSMap.FGlobalMagicControl.FEnchantments.GetEnchantments(Index)
  else
    Result := nil;
end;

function TDisjunctionSpellCaster.GetMana: Integer;
var
  Enchantment: TGlobalEnchantment;
begin
  Enchantment := SelectedEnchantment;
  if Enchantment <> nil then
    Result := Round(Enchantment.FDispelMana * 0.02 * FDispelChance)
  else
    Result := -1;
end;

procedure TDisjunctionSpellCaster.SetDispelChance(A1: Integer);
begin
  FDispelChance := A1;
  if FDispelChance < 1 then FDispelChance := 1;
  if FDispelChance > 75 then FDispelChance := 75;
end;

function TDisjunctionSpellCaster.GetDispelChanceMax: Integer;
begin
  Result := 75;
end;

function TDisjunctionSpellCaster.GetEnoughMana: Boolean;
var
  Source: THero;
begin
  Result := False;
  Source := THero(AoWHSMap.FUnitControl.FindUnit(FCasterSourceID));
  if SelectedEnchantment <> nil then
    if not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).FMagicControl.GetCheatEnabled then
    begin
      if AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).FMagicControl.FMana + Source.FCastingProgress >=
        AoWHSSet.FSpellControl.GetSpell(51).FBaseManaCost + GetMana then
        Result := True;
    end
    else
      Result := True;
end;

function TDisjunctionSpellCaster.CanCast(var Reason: string): Boolean;
var
  Source: THero;
begin
  Result := inherited CanCast(Reason);
  Source := THero(AoWHSMap.FUnitControl.FindUnit(FCasterSourceID));
  if Result and (SelectedEnchantment <> nil) then
    if not (getSpellWard in AoWHSMap.FGlobalMagicControl.FActiveEnchantments) or
      (SelectedEnchantment.FEnchantmentType = getSpellWard) then
    begin
      if not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).FMagicControl.GetCheatEnabled then
      begin
        if AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).FMagicControl.FMana + Source.FCastingProgress >=
          AoWHSSet.FSpellControl.GetSpell(51).FBaseManaCost + GetMana then
          Result := True
        else
        begin
          Result := False;
          Reason := TranslateRStr(NotEnoughManaRStr);
        end;
      end
      else
        Result := True;
    end
    else
    begin
      Result := False;
      Reason := TranslateRStr(CannotDispelWhenSpellWardIsActiveRStr);
    end
  else
    Result := False;
end;

function TDisjunctionSpellCaster.Cast: Boolean;
var
  Reason: string;
  Source: TAbstractUnit;
  Event: TDisjunctionTE;
begin
  if CanCast(Reason) then
  begin
    Source := AoWHSMap.FUnitControl.FindUnit(FCasterSourceID);
    if not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).GetBusy then
    begin
      Event := TDisjunctionTE.Create(nil);
      Event.Initialize(FCasterSpellID, Source.FPlayer, Source.FUnitID,
        AoWHSSet.FSpellControl.GetSpell(51).FBaseManaCost);
      Event.FEnchantmentID := FEnchantmentID;
      Event.FDispelChance := FDispelChance;
      AoWHSMap.FTokenManager.GetTokenControl(Source.FPlayer).AddEvent(Event);
      Event.Release;
      Result := True;
    end
    else
      Result := False;
  end
  else
  begin
    Result := False;
    AoWHSMap.ShowMessage(Reason);
  end;
end;

constructor TDisjunction.Create(AOwner: Engine.TECustomNode);
begin end;

function TDisjunction.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
begin Result := False; end;

function TDisjunction.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

constructor TResurrectHero.Create(AOwner: Engine.TECustomNode);
begin end;

function TResurrectHero.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
begin Result := False; end;

function TResurrectHero.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

constructor TAnimateHero.Create(AOwner: Engine.TECustomNode);
begin end;

function TAnimateHero.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
begin Result := False; end;

function TAnimateHero.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

constructor TCallHero.Create(AOwner: Engine.TECustomNode);
begin end;

function TCallHero.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

procedure TCallHero.FindCallHero(A1: Integer);
begin end;

function TCallHero.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
begin Result := False; end;

constructor TCrusade.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCrusade.PlaceParty(A1: Integer; A2: Integer);
begin end;

function TCrusade.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
begin Result := False; end;

function TCrusade.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

procedure RegisterGlobalSpells(A1: Integer);
begin end;

procedure UnregisterGlobalSpells(A1: Integer);
begin end;


initialization
finalization

end.
