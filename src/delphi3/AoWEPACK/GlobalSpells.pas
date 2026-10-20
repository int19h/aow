unit GlobalSpells;

{ Draft declarations of GlobalSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TConcealAreaHS, TConcealArea and TBirdsViewHS are recovered; later classes remain drafts. }

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
    procedure GetEnabled; override;
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

  { TBirdsView (instance size 52, VMT 557E93E0) }
  TBirdsView = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    procedure GetEnabled; override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
  end;

  { TWarpPartyTE (instance size 40, VMT 557E94F4) }
  TWarpPartyTE = class(TSpellTE)
  public
    F_WarpPartyTE_20: Integer;
    F_WarpPartyTE_24: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: Integer; A2: Integer): Boolean; override;
  end;

  { TWarpParty (instance size 52, VMT 557E95CC) }
  TWarpParty = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure ValidTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CalculateWarpLocation(A1: Integer);  { draft }
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

  { TDisjunctionTE (instance size 40, VMT 557E9A24) }
  TDisjunctionTE = class(TSpellTE)
  public
    F_DisjunctionTE_20: Integer;
    F_DisjunctionTE_24: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: Integer; A2: Integer): Boolean; override;
  end;

  { TDisjunctionSpellCaster (instance size 28, VMT 557E9B00) }
  TDisjunctionSpellCaster = class(TSpellCaster)
  public
    F_DisjunctionSpellCaster_14: Integer;
    F_DisjunctionSpellCaster_18: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CanCast(var Reason: string): Boolean; override;
    function Cast: Boolean; override;
    procedure SetEnchantmentID(A1: Integer);  { draft }
    procedure SelectedEnchantment;  { draft }
    procedure GetMana;  { draft }
    procedure SetDispelChance(A1: Integer);  { draft }
    procedure GetDispelChanceMax;  { draft }
    procedure GetEnoughMana;  { draft }
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

uses EventLog;

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
    RandSeed := GlobalSpellMap^.F_AoWHSMap_22C;
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

procedure TConcealArea.GetEnabled;
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
    RandSeed := GlobalSpellMap^.F_AoWHSMap_22C;
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
begin end;

procedure TBirdsView.GetEnabled;
begin end;

function TBirdsView.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
begin Result := False; end;

function TBirdsView.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
begin Result := False; end;

function TBirdsView.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

constructor TWarpPartyTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TWarpPartyTE.Destroy;
begin end;

class function TWarpPartyTE.ClassID: Integer;
begin Result := 0; end;

procedure TWarpPartyTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TWarpPartyTE.Validate(A1: THero): Boolean;
begin Result := False; end;

function TWarpPartyTE.Process(A1: Integer; A2: Integer): Boolean;
begin Result := False; end;

constructor TWarpParty.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWarpParty.ValidTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWarpParty.CalculateWarpLocation(A1: Integer);
begin end;

function TWarpParty.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

class function TDisjunctionTE.ClassID: Integer;
begin Result := 0; end;

procedure TDisjunctionTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TDisjunctionTE.Validate(A1: THero): Boolean;
begin Result := False; end;

function TDisjunctionTE.Process(A1: Integer; A2: Integer): Boolean;
begin Result := False; end;

constructor TDisjunctionSpellCaster.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDisjunctionSpellCaster.SetEnchantmentID(A1: Integer);
begin end;

procedure TDisjunctionSpellCaster.SelectedEnchantment;
begin end;

procedure TDisjunctionSpellCaster.GetMana;
begin end;

procedure TDisjunctionSpellCaster.SetDispelChance(A1: Integer);
begin end;

procedure TDisjunctionSpellCaster.GetDispelChanceMax;
begin end;

procedure TDisjunctionSpellCaster.GetEnoughMana;
begin end;

function TDisjunctionSpellCaster.CanCast(var Reason: string): Boolean;
begin Result := False; end;

function TDisjunctionSpellCaster.Cast: Boolean;
begin Result := False; end;

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
