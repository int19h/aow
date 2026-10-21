unit GlobalSpells;

{ Draft declarations of GlobalSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  All class bodies and registration routines are recovered below. }

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

  { TConcealArea (instance size 52, VMT 557E9144): inherited $08 name, $10 spell ID, $14 mana, $20 sphere, $21 level, $22 type. }
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

  { TResurrectHero (instance size 52, VMT 557E96E0): inherited $08 name, $10 spell ID, $14 mana, $20 sphere, $21 level, $22 type, $28 sounds, $2C images. }
  TResurrectHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TAnimateHero (instance size 52, VMT 557E97FC): inherited $08 name, $10 spell ID, $14 mana, $20 sphere, $21 level, $22 type, $28 sounds, $2C images. }
  TAnimateHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TCallHero (instance size 52, VMT 557E9914): inherited $08 name, $10 spell ID, $14 mana, $20 sphere, $21 level, $22 type, $28 sounds, $2C images. }
  TCallHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    function FindCallHero(Source: TAbstractUnit): THero;
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

  { TDisjunction (instance size 52, VMT 557E9BE4): inherited $08 name, $10 spell ID, $14 mana, $20 sphere, $21 level, $22 type, $28 sounds, $2C images. }
  TDisjunction = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TCrusade (instance size 52, VMT 557E9CFC): inherited $08 name, $10 spell ID, $14 mana, $20 sphere, $21 level, $22 type, $28 sounds, $2C images. }
  TCrusade = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    function PlaceParty(Source: TAbstractUnit; Party: TArmyHS): Boolean;
  end;

procedure RegisterGlobalSpells(Engine: TAoWEngine);
procedure UnregisterGlobalSpells(Engine: TAoWEngine);

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

constructor TConcealArea.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(ConcealAreaRStr);
  FSpellID := 1;
  FSpellType := stGlobal;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msEarth;
end;

function TConcealArea.GetEnabled: Boolean;
begin
  Result := AoWHSMap.FExplorationEnabled;
end;

function TConcealArea.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  MapF: TAoWMapField;
  X,Y,Layer: Shortint;
  Player: Integer;
  Walk: THNWalkData;
  Level: TMapLevel;
  Log: TLocationTextEventLog; Conceal: TConcealAreaHS;
begin
  inherited ExecuteTE(A1, A2, A3);
  CastingDone(A2, A1.FEventMana);
  A2.GetLocation(X,Y,Layer);
  if A2.FPlayer = AoWHSMap.FSeatedPlayer then
  begin Conceal := TConcealAreaHS.Create(nil); Conceal.StartAnimation(X,Y,Layer,14); end;
  for Player := 1 to TPlayerList(AoWHSMap.FPlayers).Count-1 do
  begin
    Level := AoWHSMap.MapContainer.MapLevels[Layer];
    if (AoWHSMap.FPlayers.GetDiplomaticRelation(A2.FPlayer,Player) = drWar) and (Player <> Shortint(A2.FPlayer)) then
    begin
      Log := nil;
      InitHNWalk(Walk,X,Y,0);
      while Walk.Radius <= 14 do
      begin
        if (Walk.X >= 0) and (Walk.Y >= 0) and
          (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        begin
          MapF := TAoWMapField(Level.GetField(Walk.X,Walk.Y));
          if MapF.GetExplored(Player) and
            not AoWHSMap.VisibleForPlayer(Walk.X,Walk.Y,Layer,Player) then
          begin
            MapF.SetExplored(Player, False);
            if Log = nil then
            begin
              Log := TLocationTextEventLog.Create(nil);
              Log.FXhx := Walk.X;
              Log.FYhx := Walk.Y;
              Log.FLhx := Layer;
              Log.FPlayer := A2.FPlayer;
              Log.FText :=
                SysUtils.Format(AoWE.TranslateRStr(XCastRStr),
                  [AoWE.TranslateRStr(ConcealAreaRStr)]);
              TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FEventLogbook).AddEvent(Log);
              Log.Release;
            end;
          end;
        end;
        WalkToNextHN(Walk);
      end;
    end
    else if AoWHSMap.VisibleForPlayer(X,Y,Layer,Player) then
    begin
      Log := TLocationTextEventLog.Create(nil);
      Log.FXhx := X;
      Log.FYhx := Y;
      Log.FLhx := Layer;
      Log.FPlayer := A2.FPlayer;
      Log.FText :=
        SysUtils.Format(AoWE.TranslateRStr(XCastRStr),
          [AoWE.TranslateRStr(ConcealAreaRStr)]);
      TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FEventLogbook).AddEvent(Log);
      Log.Release;
    end;
  end;
  Result := False;
end;

function TConcealArea.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
var
  War: Boolean;
  Player: Integer;
begin
  Result := inherited CanActivate(A1, A2);
  if Result then
  begin
    War := False;
    for Player := 1 to AoWHSMap.FPlayers.Count - 1 do
      War := War or
        (AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Player) = drWar);
    if not War then
    begin
      A2 := SysUtils.Format(TranslateRStr(AWarRelationIsRequiredForXRStr), [TranslateRStr(ConcealAreaRStr)]);
      Result := False;
    end;
  end;
end;

function TConcealArea.Activate(A1: TAbstractUnit): Boolean;
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
  if ShowSource and (AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastImages.ImageSequences[0] <> nil) then
  begin
    Animation := TImageSequenceAnimation.Create(nil);
    Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastImages.ImageSequences[0]);
    AoWHSMap.PlaceHX(Animation, X, Y, Layer);
  end;
  if ShowTarget and (AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastImages.ImageSequences[0] <> nil) then
  begin
    Animation := TImageSequenceAnimation.Create(nil);
    Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastImages.ImageSequences[0]);
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

function TDisjunctionTE.Validate(A1: THero): Boolean; { Near miss: Boolean result register differs after three variants. }
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
  Twinkle.Setup(AoWHSSet.FSpellControl.GetSpell(51).FCastImages.ImageSequences[0],
    [tmExpand, tmExplode], FEventMana + 50, 192, 50, 30);
  AoWHSMap.PlaceHX(Twinkle, X, Y, Layer);
  AoWHSSet.FSpellControl.GetSpell(FEventSpellID).FCastSounds.Play(0);
  Mana := Round(Enchantment.FDispelMana * 0.02 * FDispelChance);
  AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).FMagicControl.SetMana(
    AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).FMagicControl.FMana - Mana);
  if AoWHSMap.Random(100) < FDispelChance then
  begin
    if AoWHSMap.FSeatedPlayer = A1.FPlayer then
      AoWHSMap.ShowMessage(SysUtils.Format(TranslateRStr(XSuccessfullyDispelledRStr), [Enchantment.GetName]));
    AoWHSMap.FGlobalMagicControl.ExecuteDispelEnchantment(A1.FPlayer, FEnchantmentID);
  end
  else if AoWHSMap.FSeatedPlayer = A1.FPlayer then
    { Original formats this message with an unused enchantment-name argument. }
    AoWHSMap.ShowMessage(SysUtils.Format(TranslateRStr(DispelMagicFailedRStr), [Enchantment.GetName]));
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
  Source: THero; Mana: Integer;
begin
  Result := False;
  Source := THero(AoWHSMap.FUnitControl.FindUnit(FCasterSourceID));
  if SelectedEnchantment <> nil then
    if not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).FMagicControl.GetCheatEnabled then
    begin
      Mana := AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).FMagicControl.FMana + Source.FCastingProgress; if Mana >=
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
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(DisjunctionRStr);
  FSpellID := 51;
  FSpellType := stGlobal;
  FBaseManaCost := 0;
  FSpellLevel := 2;
  FMagicSphere := msCosmos;
end;

function TDisjunction.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
var
  Count, I: Integer;
  Reason: string;
begin
  Count := 0;
  for I := 0 to AoWHSMap.FGlobalMagicControl.FEnchantments.Count - 1 do
    if (AoWHSMap.FGlobalMagicControl.FEnchantments.GetEnchantments(I).FPlayerIndex <> A1.FPlayer) and
      AoWHSMap.FGlobalMagicControl.FEnchantments.GetEnchantments(I).VisibleForPlayer(A1.FPlayer) and
      AoWHSMap.FGlobalMagicControl.FEnchantments.GetEnchantments(I).CanDispel(A1.FPlayer, Reason) then
      Inc(Count);
  if Count = 0 then
  begin
    A2 := TranslateRStr(NoGlobalOpponentEnchantmentsActiveRStr);
    Result := False;
  end
  else
    Result := True;
end;

function TDisjunction.Activate(A1: TAbstractUnit): Boolean;
var
  Reason: string;
  Caster: TDisjunctionSpellCaster;
begin
  if CanActivate(A1, Reason) then
  begin
    Caster := TDisjunctionSpellCaster.Create(nil);
    Caster.FCasterSpellID := FSpellID;
    Caster.FCasterSourceID := A1.FUnitID;
    AoWHSMap.FCosmeticSurgeryEvents.TriggerNotifyEvents(Caster);
    Caster.Release;
    Result := True;
  end
  else
    Result := False;
end;

constructor TResurrectHero.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(ResurrectHeroRStr);
  FSpellID := 66;
  FSpellType := stGlobal;
  FBaseManaCost := 0;
  FSpellLevel := 2;
  FMagicSphere := msCosmos;
end;

function TResurrectHero.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, Layer: Shortint;
  Animation: TTwinkleAnimation;
  Heroes: THeroList;
  I: Integer;
  Hero: THero;
  Army: TArmyHS;
  Log: TLocationTextEventLog;
  EmergeLog: THeroEmergeEventLog;
  InfoLog: TArmyInfoEventLog;
begin
  if A3 = 0 then
  begin
    A2.GetLocation(X, Y, Layer);
    AoWHSMap.ValidateObservation(A2.FPlayer, X, Y, Layer, 0);
    Animation := TTwinkleAnimation.Create(nil);
    Animation.Setup(FCastImages.GetImageSequence(0), [tmRotate], 50, 64, 50, 30);
    AoWHSMap.PlaceHX(Animation, X, Y, Layer);
    if (A2.FPlayer = AoWHSMap.FSeatedPlayer) or AoWHSMap.Watching(X, Y, Layer, 0) then
      FCastSounds.Play(0);
  end;
  if A3 = 20 then
  begin
    Heroes := THeroList.Create(nil);
    AoWHSMap.FHeroControl.ListDeadHeroes(Heroes);
    for I := Heroes.Count - 1 downto 0 do
      if (Heroes.GetHero(I) is TLeader) or
        (Heroes.GetHero(I).GetLevel > AoWHSMap.FPlayers.GetPlayers(A2.FPlayer).FBaseHeroJoinLevel + 2) then
        Heroes.RemoveChild(Heroes.GetHero(I));
    if Heroes.Count <> 0 then
    begin
      A2.GetLocation(X, Y, Layer);
      Hero := Heroes.GetHero(AoWHSMap.Random(Heroes.Count));
      Hero.Resurrect;
      Army := Hero.Place(X, Y, Layer, 0, [pmScanArea, pmCreateNewArmy]);
      Log := TLocationTextEventLog.Create(nil);
      Log.FPlayer := A2.FPlayer;
      Log.FText := SysUtils.Format(TranslateRStr(XResurrectedRStr), [Hero.FHeroName]);
      Log.SetLocation(Army.GetXhx, Army.GetYhx, Army.GetLhx);
      DistributeLocationEventLog(Log, A2.FPlayer, Army.GetXhx, Army.GetYhx, Army.GetLhx, False);
      Log.Release;
      if Hero.OfferToJoin(A2.FPlayer) then
      begin
        EmergeLog := THeroEmergeEventLog.Create(nil);
        EmergeLog.Setup(Hero, A2.FPlayer, hjmResurrected);
        EmergeLog.Execute(True, etEvent, nil);
        EmergeLog.Release;
      end
      else
      begin
        InfoLog := TArmyInfoEventLog.Create(nil);
        InfoLog.FArmyView.Setup(Army.FArmy, Byte(1) shl Army.FArmy.IndexOf(Hero));
        InfoLog.FSelection := $FF;
        InfoLog.FPlayer := A2.FPlayer;
        InfoLog.FMessages.Text := TranslateRStr(NoJoinResurrectionRStr);
        InfoLog.FTriggers := [etEvent];
        InfoLog.Execute(True, etEvent, nil);
        InfoLog.Release;
      end;
    end
    else
      AoWHSMap.ShowMessage(TranslateRStr(NoHeroAnswersYourCallRStr));
    CastingDone(A2, A1.FEventMana);
    Heroes.Free;
    Result := False;
  end
  else
    Result := True;
end;

function TResurrectHero.Activate(A1: TAbstractUnit): Boolean;
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

constructor TAnimateHero.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(AnimateHeroRStr);
  FSpellID := 67;
  FSpellType := stGlobal;
  FBaseManaCost := 0;
  FSpellLevel := 2;
  FMagicSphere := msCosmos;
end;

function TAnimateHero.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  X, Y, Layer: Shortint;
  Animation: TTwinkleAnimation;
  Heroes: THeroList;
  I: Integer;
  Hero: THero;
  Army: TArmyHS;
  Log: TLocationTextEventLog;
  EmergeLog: THeroEmergeEventLog;
  InfoLog: TArmyInfoEventLog;
begin
  if A3 = 0 then
  begin
    A2.GetLocation(X, Y, Layer);
    AoWHSMap.ValidateObservation(A2.FPlayer, X, Y, Layer, 0);
    Animation := TTwinkleAnimation.Create(nil);
    Animation.Setup(FCastImages.GetImageSequence(0), [tmRotate], 50, 64, 50, 30);
    AoWHSMap.PlaceHX(Animation, X, Y, Layer);
    if (A2.FPlayer = AoWHSMap.FSeatedPlayer) or AoWHSMap.Watching(X, Y, Layer, 0) then
      FCastSounds.Play(0);
  end;
  if A3 = 20 then
  begin
    Heroes := THeroList.Create(nil);
    AoWHSMap.FHeroControl.ListDeadHeroes(Heroes);
    for I := Heroes.Count - 1 downto 0 do
      if (Heroes.GetHero(I) is TLeader) or
        (Heroes.GetHero(I).GetLevel > AoWHSMap.FPlayers.GetPlayers(A2.FPlayer).FBaseHeroJoinLevel + 2) then
        Heroes.RemoveChild(Heroes.GetHero(I));
    if Heroes.Count <> 0 then
    begin
      A2.GetLocation(X, Y, Layer);
      Hero := Heroes.GetHero(AoWHSMap.Random(Heroes.Count));
      Hero.Animate;
      Army := Hero.Place(X, Y, Layer, 0, [pmScanArea, pmCreateNewArmy]);
      Log := TLocationTextEventLog.Create(nil);
      Log.FPlayer := A2.FPlayer;
      Log.FText := SysUtils.Format(TranslateRStr(XAnimatedRStr), [Hero.FHeroName]);
      Log.SetLocation(Army.GetXhx, Army.GetYhx, Army.GetLhx);
      DistributeLocationEventLog(Log, A2.FPlayer, Army.GetXhx, Army.GetYhx, Army.GetLhx, False);
      Log.Release;
      if Hero.OfferToJoin(A2.FPlayer) then
      begin
        EmergeLog := THeroEmergeEventLog.Create(nil);
        EmergeLog.Setup(Hero, A2.FPlayer, hjmResurrected);
        EmergeLog.Execute(True, etEvent, nil);
        EmergeLog.Release;
      end
      else
      begin
        InfoLog := TArmyInfoEventLog.Create(nil);
        InfoLog.FArmyView.Setup(Army.FArmy, Byte(1) shl Army.FArmy.IndexOf(Hero));
        InfoLog.FSelection := $FF;
        InfoLog.FPlayer := A2.FPlayer;
        InfoLog.FMessages.Text := TranslateRStr(NoJoinAnimateRStr);
        InfoLog.FTriggers := [etEvent];
        InfoLog.Execute(True, etEvent, nil);
        InfoLog.Release;
      end;
    end
    else
      if A2.FPlayer = AoWHSMap.FSeatedPlayer then
      begin
        AoWHSMap.ShowMessage(TranslateRStr(NoHeroAnswersYourCallRStr));
        AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
      end;
    CastingDone(A2, A1.FEventMana);
    Heroes.Free;
    Result := False;
  end
  else
    Result := True;
end;

function TAnimateHero.Activate(A1: TAbstractUnit): Boolean;
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

constructor TCallHero.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(CallHeroRStr);
  FSpellID := 69;
  FSpellType := stGlobal;
  FBaseManaCost := 0;
  FSpellLevel := 2;
  FMagicSphere := msCosmos;
end;

function TCallHero.Activate(A1: TAbstractUnit): Boolean;
var
  Reason: string;
  Event: TSpellTE;
begin
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

function TCallHero.FindCallHero(Source: TAbstractUnit): THero;
var
  Hero: THero;
  I: Integer;
  Heroes: TDoubleItemList;
  Index: Integer;
begin
  Heroes := TDoubleItemList.Create;
  for I := AoWHSMap.FHeroControl.GetCount - 1 downto 0 do
  begin
    Hero := AoWHSMap.FHeroControl.GetHero(I);
    if (Hero.FPlayer = 0) and (Hero.Owner is TArmy) and (TArmy(Hero.Owner).FX <> -1) then
      if Hero.OfferToJoin(Source.FPlayer) then
        Heroes.AddAB(Integer(Hero), 10)
      else
        Heroes.AddAB(Integer(Hero), 1);
  end;
  if Heroes.Count = 0 then
    for I := AoWHSMap.FHeroControl.GetCount - 1 downto 0 do
    begin
      Hero := AoWHSMap.FHeroControl.GetHero(I);
      if not (usKilled in Hero.FUnitStatus) and (Hero.FPlayer <= 0) and (Hero.Owner = nil) then
        if Hero.OfferToJoin(Source.FPlayer) then
          Heroes.AddAB(Integer(Hero), 10)
        else
          Heroes.AddAB(Integer(Hero), 1);
    end;
  if Heroes.Count <> 0 then
  begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    Index := Heroes.RandomChanceItemB(0);
    Result := THero(Heroes[Index].A);
  end
  else
    Result := nil;
  Heroes.Free;
end;

function TCallHero.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  ShowSource, ShowTarget: Boolean;
  X, Y, Layer: Shortint;
  Hero: THero;
  Army: TArmyHS;
  Animation: TImageSequenceAnimation;
begin
  inherited ExecuteTE(A1, A2, A3);
  A2.GetLocation(X, Y, Layer);
  Hero := FindCallHero(A2);
  if Hero <> nil then
  begin
    if Hero.Owner = nil then Hero.SetHitPoints(Hero.GetHits);
    Army := Hero.Place(X, Y, Layer, 0, [pmScanArea, pmCreateNewArmy]);
    ShowSource := (AoWHSMap.FSeatedPlayer = A2.FPlayer) or
      AoWHSMap.VisibleForPlayer(X, Y, Layer, AoWHSMap.FSeatedPlayer);
    ShowTarget := (AoWHSMap.FSeatedPlayer = A2.FPlayer) or
      AoWHSMap.VisibleForPlayer(Army.GetXhx, Army.GetYhx, Army.GetLhx, AoWHSMap.FSeatedPlayer);
    if ShowSource then
      if AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(0) <> nil then
      begin
        Animation := TImageSequenceAnimation.Create(nil);
        Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(0));
        AoWHSMap.PlaceHX(Animation, X, Y, Layer);
      end;
    if ShowTarget then
      if AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(0) <> nil then
      begin
        Animation := TImageSequenceAnimation.Create(nil);
        Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.GetImageSequence(0));
        AoWHSMap.PlaceHX(Animation, Army.GetXhx, Army.GetYhx, Army.GetLhx);
      end;
    if AoWHSMap.FSeatedPlayer = A2.FPlayer then
      AoWHSMap.CenterViewTo(Army.GetXhx, Army.GetYhx, Army.GetLhx)
    else
      AoWHSMap.ValidateObservation(A2.FPlayer, Army.GetXhx, Army.GetYhx, Army.GetLhx, 0);
    if (AoWHSMap.FSeatedPlayer = A2.FPlayer) or AoWHSMap.Watching(X, Y, Layer, 0) or
      AoWHSMap.Watching(Army.GetXhx, Army.GetYhx, Army.GetLhx, 0) then
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
  end
  else
    if AoWHSMap.FSeatedPlayer = A2.FPlayer then
    begin
      AoWHSMap.ShowMessage(TranslateRStr(NoHeroAnsweredYourCallRStr));
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
    end;
  AoWHSSet.FSpellControl.GetSpell(FSpellID).CastingDone(A2,
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FBaseManaCost);
  Result := False;
end;

constructor TCrusade.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(CrusadeRStr);
  FSpellID := 75;
  FSpellType := stGlobal;
  FBaseManaCost := 0;
  FSpellLevel := 4;
  FMagicSphere := msLife;
end;

function TCrusade.PlaceParty(Source: TAbstractUnit; Party: TArmyHS): Boolean;
var
  TargetX, TargetY: Integer;
  X, Y, Layer: Shortint;
  Animation: TImageSequenceAnimation;
begin
  Source.GetLocation(X, Y, Layer);
  CenterHNtoHX(X, Y, AoWHSMap.Random(RadToHN(5)), TargetX, TargetY);
  if Party.PlaceEx(TargetX, TargetY, Layer, [apSafe, apScanArea]) then
  begin
    Party.Activate;
    Party.FArmy.SetBehavior($FF, gbSuicidal);
    if AoWHSMap.Watching(Party.GetXhx, Party.GetYhx, Party.GetLhx, 0) then
      if AoWHSSet.FSpellControl.GetSpell(34).FCastImages.GetImageSequence(0) <> nil then
      begin
        { Original uses Warp Party's images for Crusade parties. }
        Animation := TImageSequenceAnimation.Create(nil);
        Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(34).FCastImages.GetImageSequence(0));
        Animation.FAnimationLevel := 28;
        AoWHSMap.PlaceHX(Animation, Party.GetXhx, Party.GetYhx, Party.GetLhx);
      end;
    Result := True;
  end
  else
    Result := False;
end;

function TCrusade.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
const
  LargeUnits: array[0..0] of Integer = (133);
  MountedUnits: array[0..2] of Integer = (132, 134, 128);
  FootUnits: array[0..1] of Integer = (129, 126);
var
  I, J, Count, UnitIndex, Xhp, Yhp: Integer;
  X, Y, Layer: Shortint;
  Party: TArmyHS;
  NewUnit: TUnit;
begin
  if A3 = 0 then
  begin
    A2.GetLocation(X, Y, Layer);
    AoWHSMap.ValidateObservation(A2.FPlayer, X, Y, Layer, 0);
    HXtoHP(X, Y, Xhp, Yhp);
    with AoWHSMap.AddEffect(fxCrusade) do
    begin
      FX := Xhp + 16;
      FY := Yhp + 16;
      FLayer := Layer;
    end;
    if AoWHSMap.Random(100) < 20 then
    begin
      Party := TArmyHS.Create(nil);
      Party.FArmy.SetPlayer(0);
      Count := 1;
      UnitIndex := AoWHSMap.Random(1);
      for J := 0 to Count - 1 do
      begin
        NewUnit := TUnit.Create(nil);
        NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(LargeUnits[UnitIndex]));
        NewUnit.ExpandAbility(101);
        Party.FArmy.AddUnit(NewUnit);
        NewUnit.Release;
      end;
      if not PlaceParty(A2, Party) then Party.Free;
    end
    else
    begin
      for I := 0 to 1 do
      begin
        Party := TArmyHS.Create(nil);
        Party.FArmy.SetPlayer(0);
        Count := AoWHSMap.Random(3) + 4;
        for J := 0 to Count - 1 do
        begin
          NewUnit := TUnit.Create(nil);
          UnitIndex := AoWHSMap.Random(2);
          NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(FootUnits[UnitIndex]));
          NewUnit.ExpandAbility(101);
          Party.FArmy.AddUnit(NewUnit);
          NewUnit.Release;
        end;
        if not PlaceParty(A2, Party) then Party.Free;
      end;
      Party := TArmyHS.Create(nil);
      Party.FArmy.SetPlayer(0);
      UnitIndex := AoWHSMap.Random(3);
      Count := 2;
      if UnitIndex = 2 then Inc(Count);
      for J := 0 to Count - 1 do
      begin
        NewUnit := TUnit.Create(nil);
        NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(MountedUnits[UnitIndex]));
        NewUnit.ExpandAbility(101);
        Party.FArmy.AddUnit(NewUnit);
        NewUnit.Release;
      end;
      if not PlaceParty(A2, Party) then Party.Free;
    end;
    AoWHSSet.FSpellControl.GetSpell(FSpellID).CastingDone(A2, FBaseManaCost);
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
  end;
  Result := False;
end;

function TCrusade.Activate(A1: TAbstractUnit): Boolean;
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

procedure RegisterGlobalSpells(Engine: TAoWEngine);
var
  Control: TSpellControl;
begin
  Control := Engine.FGameSet.FSpellControl;
  Engine.RegisterEClasses([TWarpPartyTE, TDisjunctionTE]);
  Control.RegisterSpell(TConcealArea.Create(nil));
  Control.RegisterSpell(TBirdsView.Create(nil));
  Control.RegisterSpell(TWarpParty.Create(nil));
  Control.RegisterSpell(TDisjunction.Create(nil));
  Control.RegisterSpell(TResurrectHero.Create(nil));
  Control.RegisterSpell(TAnimateHero.Create(nil));
  Control.RegisterSpell(TCallHero.Create(nil));
  Control.RegisterSpell(TCrusade.Create(nil));
end;

procedure UnregisterGlobalSpells(Engine: TAoWEngine);
var
  Control: TSpellControl;
begin
  Control := Engine.FGameSet.FSpellControl;
  Engine.UnregisterEClasses([TWarpPartyTE, TDisjunctionTE]);
  Control.UnregisterSpellID(1);
  Control.UnregisterSpellID(2);
  Control.UnregisterSpellID(34);
  Control.UnregisterSpellID(51);
  Control.UnregisterSpellID(66);
  Control.UnregisterSpellID(67);
  Control.UnregisterSpellID(69);
  Control.UnregisterSpellID(75);
end;


initialization
finalization

end.
