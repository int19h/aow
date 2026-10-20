unit Mountain;

{ Draft declarations of Mountain, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Mountain terrain and raised terrain bodies recovered from the original code. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTer, GlobalTargetSpells, Animation;

type
  TMountainMO = class;
  TMountainMOR = class;
  TRaisedMountain = class;
  TRaisedMountainResource = class;
  TRaiseTerrainTE = class;
  TRaiseTerrain = class;


  { TMountainMO (instance size 20, VMT 557A266C) }
  TMountainMO = class(TAoWTerrain)
  public
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    function CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function ValidMountainOverlap(MapField: TMapField; Overlay: Shortint): Boolean;
  end;

  { TMountainMOR (instance size 76, VMT 557A2814) }
  TMountainMOR = class(TAoWTerrainResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TRaisedMountain (instance size 32, VMT 557A2940): $1C FMode,
    $1D FPlayer, $1E FDuration, $1F FOriginalOverlay. }
  TRaisedMountain = class(TILTerrainMO)
  public
    FMode: set of (rmRaising); { $1C }
    FPlayer: Shortint; { $1D }
    FDuration: Shortint; { $1E }
    FOriginalOverlay: Shortint; { $1F }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure RestoreTerrain;
    procedure NewTurn(Player: Shortint);
    procedure ShowRaiseTerrainAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
    procedure NewFrameRaiseTerrainAnimation(Anim: TAnimation; FrameCounter: Integer);
  end;

  { TRaisedMountainResource (instance size 68, VMT 557A2AF4) }
  TRaisedMountainResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TRaiseTerrainTE (instance size 36, VMT 557A2BF8) }
  TRaiseTerrainTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: Integer; A2: Integer): Boolean; override;
    procedure RaiseTerrain(Caster: TAbstractUnit);
  end;

  { TRaiseTerrain (instance size 60, VMT 557A2CD0) }
  TRaiseTerrain = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    function TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: Integer): Boolean; override;
    function ValidTargetMapF(A1: Integer): Boolean; override;
  end;

procedure RegisterMountain(AEngine: TEngine);
procedure UnRegisterMountain(AEngine: TEngine);

implementation

type
  PAoWMap = ^TAoWHSMap;
  PAoWSet = ^TAoWHSSet;
  TLocation = packed record X, Y, Layer, Reserved: Shortint end;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
  WorldSet: PAoWSet = @AoWE.AoWHSSet;
resourcestring
  MountainNameRStr = 'Mountain';
const
  MountainName: PResStringRec = @MountainNameRStr;

class function TMountainMO.ClassID: Integer;
begin Result := $20168; end;

function TMountainMO.GetOverlay(Index: Integer): Shortint;
begin
  Result := FResource.TerrainList.Overlay[Index];
  if Result >= 0 then Result := 0;
end;

function TMountainMO.CanChangeTerrain(const Info: THSSenderInfo): Boolean;
begin Result := True; end;

function TMountainMO.ValidMountainOverlap(MapField: TMapField; Overlay: Shortint): Boolean;
var
  Valid: Boolean;
  I: Integer;
  HS: TMapObject;
  OtherOverlay: Shortint;
begin
  Valid := True;
  I := 0;
  while (I <> MapField.Count) and Valid do
  begin
    HS := TMapObject(MapField.HSList^[I]);
    if HS.ClassID = $20168 then
    begin
      OtherOverlay := HS.Resource.TerrainList.Overlay[MapField.GetHNofHS(HS)];
      Valid := not (((OtherOverlay = 0) and (Overlay = 0)) or
        ((Smallint(OtherOverlay) = 1) and (Smallint(Overlay) = 1)));
    end;
    Inc(I);
  end;
  Result := Valid;
end;

function TMountainMO.CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  I: Integer;
  Valid: Boolean;
  List: TTerrainList;
  MapField: TMapField;
  X, Y: Integer;
  HS: THexagonSprite;
begin
  I := 0;
  Valid := True;
  List := FResource.TerrainList;
  while Valid and (I < List.Count) do
  begin
    if (List.Terrain[I] >= 0) or (List.Overlay[I] >= 0) then
    begin
      CenterHNtoHX(Xhx, Yhx, I, X, Y);
      if (X >= 0) and (Y >= 0) and (X < MapContainer.Width) and (Y < MapContainer.Height) then
      begin
        MapField := MapContainer.GetField(X, Y, Lhx);
        HS := MapField.GetMaxLevelNoneTransparentHS;
        if (HS <> nil) and (HS.ClassID = $20168) then
          Valid := ValidMountainOverlap(MapField, List.Overlay[I])
        else
          Valid := (HS = nil) or (HS.GetLevel < 10);
      end;
    end;
    Inc(I);
  end;
  Valid := Valid and MapContainer.Map.CanChangeTerrain(Self, Xhx, Yhx, Lhx, FResource.TerrainList);
  Result := Valid;
end;

class function TMountainMOR.ClassID: Integer;
begin Result := $20169; end;

class function TMountainMOR.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(MountainName)); end;

function TMountainMOR.ResourceUserClassID: Integer;
begin Result := $20168; end;

class function TRaisedMountain.ClassID: Integer;
begin Result := $2016A; end;

procedure TRaisedMountain.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwShortintEx(FPlayer, -1, 40);
  Stream.rwShortintEx(FDuration, -1, 41);
  Stream.rwShortintEx(FOriginalOverlay, -1, 42);
end;

procedure TRaisedMountain.RestoreTerrain;
var
  Field: TMapField;
  Overlay: Shortint;
begin
  Field := TMapField(Owner);
  Overlay := FOriginalOverlay;
  Self.Destroy;
  if Overlay > 0 then
    WorldMap^.PlaceTerrain(Field.Xhx, Field.Yhx, Field.Lhx, Field.TerrainType, Overlay);
end;

procedure TRaisedMountain.NewTurn(Player: Shortint);
begin
  if (Player = FPlayer) and (FDuration > 0) then
  begin
    Dec(FDuration);
    if FDuration = 0 then RestoreTerrain;
  end;
end;

procedure TRaisedMountain.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then NewTurn(Msg.Value);
end;

procedure TRaisedMountain.MapFieldMsgProc(var Msg: TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1132 then
    if FResource.TerrainList.Terrain[Msg.HN] >= 0 then RestoreTerrain;
end;

procedure TRaisedMountain.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin
  if not (rmRaising in FMode) then inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

procedure TRaisedMountain.ShowRaiseTerrainAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Field: TMapField;
begin
  Field := WorldMap^.MapContainer.GetField(Anim.GetXhx, Anim.GetYhx, Anim.GetLhx);
  { Original tests the base mountain ID, although this object is raised terrain. }
  if (Self = Field.FindOwnedChild($20168)) and (Anim.FFrameCounter = 0) then
    if (WorldMap^.FSeatedPlayer = Anim.FTag) or
      AoWE.AoWHSMap.WatchingTerrain(GetXhx, GetYhx, GetLhx, 0) then
      WorldSet^.FSpellControl.GetSpell(19).FCastSounds.Play(0);
end;

procedure TRaisedMountain.NewFrameRaiseTerrainAnimation(Anim: TAnimation; FrameCounter: Integer);
var
  Field: TMapField;
begin
  Field := WorldMap^.MapContainer.GetField(Anim.GetXhx, Anim.GetYhx, Anim.GetLhx);
  if (Field.FindOwnedChild($2016A) = Self) and (FrameCounter = 9) then
    FMode := FMode - [rmRaising];
end;

class function TRaisedMountainResource.ClassID: Integer;
begin Result := $2016B; end;

class function TRaisedMountainResource.ResourceEditName: string;
begin Result := TranslateRStr(RaisedMountainRStr); end;

function TRaisedMountainResource.ResourceUserClassID: Integer;
begin Result := $2016A; end;

class function TRaiseTerrainTE.ClassID: Integer;
begin Result := $2130A; end;

procedure TRaiseTerrainTE.RaiseTerrain(Caster: TAbstractUnit);
var
  Resources: TMapObjectResourceList;
  Level: TMapLevel;
  Walk: THNWalkData;
  Field: TAoWMapField;
  Mountain: TRaisedMountain;
  Resource: TMapObjectResource;
  I: Integer;
  Found: Boolean;
  Anim: TImageSequenceAnimation;
begin
  Resources := WorldSet^.MapObjectResourceList;
  Level := WorldMap^.MapContainer.MapLevels[TLocation(FLocation).Layer];
  InitHNWalk(Walk, TLocation(FLocation).X, TLocation(FLocation).Y, 0);
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Field := TAoWMapField(Level.Field[Walk.X, Walk.Y]);
      Mountain := nil;
      if TRaiseTerrain(WorldSet^.FSpellControl.GetSpell(19)).ValidTargetMapF(Integer(Field)) then
      begin
        Found := False;
        I := Resources.Count;
        while not Found and (I <> 0) do
        begin
          Dec(I);
          Resource := TMapObjectResource(Resources.Resources[I]);
          Found := (Resource.ClassID = $2016B) and (Resource.TerrainList.UsedTerrain = 1);
        end;
        if Found then
        begin
          Field.RestoreTerrain;
          Mountain := TRaisedMountain(Resource.CreateResourceUser);
          Mountain.FDuration := (WorldMap^.Random(11) - 5) div 5 + 3;
          Mountain.FPlayer := Caster.FPlayer;
          Mountain.FOriginalOverlay := Field.OverlayType;
          WorldMap^.ClearTerrain(Walk.X, Walk.Y, TLocation(FLocation).Layer, 0, -1);
          if WorldMap^.PlaceHX(Mountain, Walk.X, Walk.Y, TLocation(FLocation).Layer) then
          begin
            Mountain.FMode := Mountain.FMode + [rmRaising];
            Anim := TImageSequenceAnimation.Create(nil);
            Anim.SetImageSequence(WorldSet^.FSpellControl.GetSpell(19).FCastImages.ImageSequences[0]);
            Anim.FOnShow := Mountain.ShowRaiseTerrainAnimation;
            Anim.FOnNewFrame := Mountain.NewFrameRaiseTerrainAnimation;
            Anim.FFrameCounter := -WorldMap^.Random(15);
            WorldMap^.PlaceHX(Anim, Walk.X, Walk.Y, TLocation(FLocation).Layer);
          end;
        end;
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TRaiseTerrainTE.Process(A1: Integer; A2: Integer): Boolean;
begin
  inherited Process(A1, A2);
  RaiseTerrain(TAbstractUnit(A1));
  WorldMap^.ValidateTerrainObservation(TAbstractUnit(A1).FPlayer,
    TLocation(FLocation).X, TLocation(FLocation).Y, TLocation(FLocation).Layer, 1);
  WorldSet^.FSpellControl.GetSpell(FEventSpellID).CastingDone(TAbstractUnit(A1), FEventMana);
  Result := False;
end;

constructor TRaiseTerrain.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(RaiseTerrainRStr);
  FSpellID := 19;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msEarth;
  FAboveGroundOnly := True;
end;

function TRaiseTerrain.ValidTargetMapF(A1: Integer): Boolean;
begin
  Result := inherited ValidTargetMapF(A1) and
    not (TAoWMapField(A1).TerrainType in [0, 6, 10, 13]) and
    not (TAoWMapField(A1).OverlayType in [0]) and
    (TAoWMapField(A1).FindNoneTransparentHS(TStructure) = nil);
  if Result then Result := TAoWMapField(A1).GetArmyHS = nil;
end;

function TRaiseTerrain.ValidTargetSelectionMapF(A1: Integer): Boolean;
var
  Valid: Boolean;
  Army: TArmyHS;
begin
  Valid := inherited ValidTargetSelectionMapF(A1) and
    not (TAoWMapField(A1).TerrainType in [0, 6, 10, 13]) and
    not (TAoWMapField(A1).OverlayType in [0]) and
    (TAoWMapField(A1).FindNoneTransparentHS(TStructure) = nil);
  if Valid then
  begin
    Army := TAoWMapField(A1).GetArmyHS;
    if Army <> nil then Valid := not Army.VisibleForSeatedPlayer;
  end;
  Result := Valid;
end;

procedure TRaiseTerrain.SetupTargetSelection(A1: Integer; A2: Integer);
var I: Integer;
begin
  inherited SetupTargetSelection(A1, A2);
  TTargetSelectionControl(A2).FHNs.Clear;
  for I := 0 to RadToHN(2) - 1 do
    TTargetSelectionControl(A2).FHNs.Add(0);
end;

function TRaiseTerrain.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Boolean;
var Event: TRaiseTerrainTE;
begin
  Event := TRaiseTerrainTE.Create(nil);
  Event.Initialize(FSpellID, TAbstractUnit(A1).FPlayer, TAbstractUnit(A1).FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  WorldMap^.FTokenManager.GetTokenControl(TAbstractUnit(A1).FPlayer).AddEvent(Event);
  Event.Release;
  Result := True;
end;

procedure RegisterMountain(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TMountainMO, TMountainMOR, TRaiseTerrainTE, TRaisedMountain, TRaisedMountainResource]);
  TAoWEngine(AEngine).FGameSet.FSpellControl.RegisterSpell(TRaiseTerrain.Create(nil));
end;

procedure UnRegisterMountain(AEngine: TEngine);
begin
  AEngine.UnregisterEClasses([TMountainMO, TMountainMOR, TRaiseTerrainTE, TRaisedMountain, TRaisedMountainResource]);
  { Original unregisters spell 12, although Raise Terrain registers as spell 19. }
  TAoWEngine(AEngine).FGameSet.FSpellControl.UnregisterSpellID(12);
end;


initialization
finalization

end.
