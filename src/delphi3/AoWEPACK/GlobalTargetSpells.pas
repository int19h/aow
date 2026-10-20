unit GlobalTargetSpells;

{ Draft declarations of GlobalTargetSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Bodies through the watcher spell classes are recovered below;
  Tornado and later classes remain drafts. Local declaration workarounds are marked
  needs; world pointer cells are bound to the shared P1 globals. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TGlobalTargetSpellTE = class;
  TGlobalTargetSpell = class;
  TFreezeWaterTE = class;
  TFreezeWater = class;
  TFireBarrierTE = class;
  TFireBarrier = class;
  TLevelTerrainTE = class;
  TLevelTerrain = class;
  TRejuvenateTE = class;
  TRejuvenate = class;
  TWatcherEnchantment = class;
  TWatcherHS = class;
  TWatcherTE = class;
  TWatcher = class;
  TTornadoTE = class;
  TTornado = class;
  TVortexTE = class;
  TVortex = class;
  THealingShowersTE = class;
  THealingShowers = class;
  TSmokeCloudSpell = class;


  { TGlobalTargetSpellTE (instance size 36, VMT 5579CBAC).
    $20 FLocation: packed X/Y/layer coordinates; $23 reserved. }
  TGlobalTargetSpellTE = class(TSpellTE)
  public
    FLocation: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure SetLocation(X, Y, Layer: Shortint);
    procedure PlayDefaultEffects(X, Y, Layer: Shortint);
  end;

  { TGlobalTargetSpell (instance size 60, VMT 5579CC9C).
    $34 FCasterID, $38 FCasterPlayer, $39 FAboveGroundOnly, $3A padding.
    needs: CanActivate/Activate and the target predicates return Boolean.
    Procedure declarations retained for shared TSpell and P7 overrides.
    ShowTargetSelection variants: reordered locals, split/inline radius,
    target with-scope, and inline map-field lookup. SetupTargetSelection
    variants: explicit class local, repeated casts, class with-scope,
    record fields, record with-scope and reversed coordinate local order. }
  TGlobalTargetSpell = class(TSpell)
  public
    FCasterID: Integer;
    FCasterPlayer: Shortint;
    FAboveGroundOnly: Boolean;
    F_GlobalTargetSpell_3A: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure ShowTargetSelection(Target: TTargetSelectionControl; HN, Xs, Ys: Integer; const SurfaceDesc: TSurfaceDesc); virtual;  { +09C }
    procedure OnTargetSelectionChange(Sender: TObject); virtual;  { +0A0 }
    procedure SetupTargetSelection(A1: Integer; A2: Integer); virtual;  { +0A4 draft }
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0A8 draft }
    procedure ValidTargetSelection(A1: Integer); virtual;  { +0AC draft }
    procedure ValidTargetSelectionMapF(A1: Integer); virtual;  { +0B0 draft }
    procedure ValidTargetMapF(A1: Integer); virtual;  { +0B4 draft }
  end;

  { TFreezeWaterTE (instance size 36, VMT 5579CDE0) }
  TFreezeWaterTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ChangeTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
    procedure TerrainChanged(MapF: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint);
  end;

  { TFreezeWater (instance size 60, VMT 5579CEC0) }
  TFreezeWater = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TFireBarrierTE (instance size 36, VMT 5579CFFC) }
  TFireBarrierTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure CreateFireBarrier;  { draft }
  end;

  { TFireBarrier (instance size 60, VMT 5579D0DC) }
  TFireBarrier = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TLevelTerrainTE (instance size 36, VMT 5579D218) }
  TLevelTerrainTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure LevelTerrain;  { draft }
  end;

  { TLevelTerrain (instance size 60, VMT 5579D2F8) }
  TLevelTerrain = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TRejuvenateTE (instance size 36, VMT 5579D434) }
  TRejuvenateTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure RejuvenateTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
  end;

  { TRejuvenate (instance size 60, VMT 5579D514) }
  TRejuvenate = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TWatcherEnchantment (instance size 40, VMT 5579D648): $24 FWatcher. }
  TWatcherEnchantment = class(TGlobalEnchantment)
  public
    FWatcher: TWatcherHS;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer); override;
    procedure GetLocation(A1: Integer; A2: Integer); override;
    procedure Deactivate(A1: Byte); override;
  end;

  { TWatcherHS (instance size 32, VMT 5579D7A0): $0C state, $0D unfog
    radius, $10 enchantment, $14 animation frame, $18 unexplored HNs,
    $1C visibility flag; $0E/$1D padding. }
  TWatcherHS = class(TSingleHS)
  public
    FWatcherState: Byte;
    FUnfogRadius: Byte;
    FReserved0E: array[0..1] of Byte;
    FEnchantment: TWatcherEnchantment;
    FAnimationFrame: Integer;
    FUnexplored: TIntegerList;
    FVisibleForSeatedPlayer: Boolean;
    FReserved1D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure StartAnimation(X, Y, Layer: Shortint);
    procedure StopAnimation;  { draft }
    procedure UpdateExploration;  { draft }
    procedure UpdateUnfog;  { draft }
    function VisibilityRange: Integer;
    procedure UpdateVisibleForSeatedPlayer;  { draft }
  end;

  { TWatcherTE (instance size 36, VMT 5579D92C) }
  TWatcherTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TWatcher (instance size 60, VMT 5579DA04) }
  TWatcher = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TTornadoTE (instance size 48, VMT 5579DB38) }
  TTornadoTE = class(TGlobalTargetSpellTE)
  public
    F_TornadoTE_24: Integer;
    F_TornadoTE_28: Integer;
    F_TornadoTE_2C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TTornado (instance size 60, VMT 5579DC10) }
  TTornado = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidWarpLocation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CalculateWarpLocation(A1: Integer; A2: Integer);  { draft }
  end;

  { TVortexTE (instance size 48, VMT 5579DD44) }
  TVortexTE = class(TGlobalTargetSpellTE)
  public
    F_VortexTE_24: Integer;
    F_VortexTE_28: Integer;
    F_VortexTE_2C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TVortex (instance size 60, VMT 5579DE1C) }
  TVortex = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelection(A1: Integer); override;
    procedure ValidateTargetEvent(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { THealingShowersTE (instance size 40, VMT 5579DF48) }
  THealingShowersTE = class(TGlobalTargetSpellTE)
  public
    F_HealingShowersTE_24: Integer;
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ChangeTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { THealingShowers (instance size 60, VMT 5579E030) }
  THealingShowers = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TSmokeCloudSpell (instance size 60, VMT 5579E16C) }
  TSmokeCloudSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

procedure RegisterGlobalTargetSpells(A1: Integer);  { draft }
procedure UnregisterGlobalTargetSpells(A1: Integer);  { draft }

implementation

uses Animation;

type
  { needs: corrected result/callback signatures on TGlobalTargetSpell and
    its P7 descendants. This call-only view uses the original VMT slots. }
  TGlobalTargetSpellCalls = class(TSpell)
    procedure ShowSelection(Target: TTargetSelectionControl; HN, X, Y: Integer;
      const SD: TSurfaceDesc); virtual; abstract;
    procedure SelectionChanged(Sender: TObject); virtual; abstract;
    procedure SetupSelection(Caster, Target: Integer); virtual; abstract;
    function Selected(Caster, X, Y, Layer: Integer): Boolean; virtual; abstract;
    function ValidSelection(Target: Integer): Boolean; virtual; abstract;
    function ValidSelectionMapF(MapF: Integer): Boolean; virtual; abstract;
    function ValidMapF(MapF: Integer): Boolean; virtual; abstract;
  end;
  PSpellString = ^string;
  TSpellNameView = record
    Reserved: array[0..7] of Byte;
    Name: string;
  end;
  { needs: typed TTargetSelectionControl fields. This view preserves all offsets;
    $04 library, $0D mode, $10 show callback, $20 distance, $24/$28/$2C center,
    $34 change events, $38 change, $39/$3A/$3B location, $3C text,
    $40/$44 captions, $50/$54/$58 preview images. }
  TTargetSelectionView = class(TObject)
    ImageLibrary: TCustomImageLibrary;
    Reserved08: Integer;
    Status: Byte;
    Mode: TTargetSelectionMode;
    Padding0E: Word;
    OnShow: TShowTargetSelectionEvent;
    OnValidate: TValidateTargetEvent;
    Distance, CenterX, CenterY, CenterLayer, Reserved30: Integer;
    Changes: TEventList;
    Change: TTargetSelectionChange;
    X, Y, Layer: Shortint;
    Text: TStrings;
    Caption, CancelCaption: string;
    Reserved48, Reserved4C: Integer;
    Preview, ValidPreview, InvalidPreview: TLibraryImage;
  end;
  TTargetSelectionFields = record
    VMT: Pointer;
    ImageLibrary: TCustomImageLibrary;
    Reserved08: Integer;
    Status: Byte;
    Mode: TTargetSelectionMode;
    Padding0E: Word;
    OnShow: TShowTargetSelectionEvent;
    OnValidate: TValidateTargetEvent;
    Distance, CenterX, CenterY, CenterLayer, Reserved30: Integer;
    Changes: TEventList;
    Change: TTargetSelectionChange;
    X, Y, Layer: Shortint;
    Text: TStrings;
    Caption, CancelCaption: string;
    Reserved48, Reserved4C: Integer;
    Preview, ValidPreview, InvalidPreview: TLibraryImage;
  end;
  TMapSeatedPlayerView = record
    Reserved: array[0..$A4] of Byte;
    SeatedPlayer: Shortint;
  end;
  { Typed call-only methods retain original argument evaluation order without
    altering the foreign draft headers or their implementation signatures. }
  TSpellMapCalls = class(TObject)
    procedure ValidateTerrain(Player,X,Y,Layer: Byte; Radius: Integer);
    function TerrainVisible(X,Y,Layer: Byte; Radius: Integer): Boolean;
    function WatchingTerrain(X,Y,Layer: Byte; Radius: Integer): Boolean;
    function MapVisible(X,Y,Layer: Shortint; Radius: Integer): Boolean;
  end;
  TSpellLocation = packed record
    X, Y, Layer: Shortint;
    Reserved: Byte;
  end;

type
  PSpellHSSet = ^TAoWHSSet;
  PSpellHSMap = ^TAoWHSMap;
  PSpellIntensityTable = ^TLookupBlendTableCollection100;
const
  { Mirror package import cells while binding them to the shared globals. }
  SpellStructureClass: TClass = TStructure;
  SpellHSSet: PSpellHSSet = @AoWHSSet;
  SpellHSMap: PSpellHSMap = @AoWHSMap;
  SpellIntensityTable: PSpellIntensityTable = @GFXE.IntensityBlendTable;

resourcestring
  { needs: AoWE.CancelRStr, referenced at $5579E664; absent from draft. }
  SpellCancelRStr = 'Cancel';

{ needs: TSpellControl.GetSpell must return TSpell. Preserve its register ABI
  with a tail call until the shared declaration is corrected. }
function LookupSpell(Control: TSpellControl; ID: Integer): TSpell; assembler;
asm
  JMP TSpellControl.GetSpell
end;

{ needs: TAoWMapField.GetExplored(Player: Integer): Boolean ($5579E4C8). }
function MapExplored(MapF: TAoWMapField; Player: Integer): Boolean; assembler;
asm
  JMP TAoWMapField.GetExplored
end;

{ needs: TUnitControl.FindUnit(ID: Integer): TAbstractUnit ($5579E4F7). }
function FindSpellUnit(Control: TUnitControl; ID: Integer): TAbstractUnit; assembler;
asm
  JMP TUnitControl.FindUnit
end;

{ needs: AoWE.TranslateRStr(const S: string): string ($5579E62D). }
function SpellTranslate(const S: string): string; assembler;
asm
  JMP AoWE.TranslateRStr
end;

{ needs: TSpell.CanActivate(Caster: TAbstractUnit; var Msg: string): Boolean. }
function BaseCanActivate(Spell: TSpell; Caster: Integer; MessagePtr: Integer): Boolean; assembler;
asm
  JMP TSpell.CanActivate
end;

class function TGlobalTargetSpellTE.ClassID: Integer;
begin
  Result := $21328;
end;

procedure TGlobalTargetSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FLocation, $14);
end;

procedure TGlobalTargetSpellTE.SetLocation(X, Y, Layer: Shortint);
begin
  TSpellLocation(FLocation).X := X;
  TSpellLocation(FLocation).Y := Y;
  TSpellLocation(FLocation).Layer := Layer;
end;

procedure TGlobalTargetSpellTE.PlayDefaultEffects(X, Y, Layer: Shortint);
var
  Animation: TImageSequenceAnimation;
begin
  { needs: TSpellControl.GetSpell(ID: Integer): TSpell; original calls at
    $5579E2CE, $5579E301, $5579E344 consume EAX as the returned spell.
    TSpell.$28 is TSFXLibrary; TSpell.$2C is TImageSequenceList. }
  if TImageSequenceList(LookupSpell(
    TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).F_Spell_2C).
    ImageSequences[0] <> nil then
  begin
    Animation := TImageSequenceAnimation.Create(nil);
    { needs: TImageSequenceAnimation.SetImageSequence(Value: TImageSequence). }
    Animation.SetImageSequence(Integer(TImageSequenceList(
      LookupSpell(
      TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).F_Spell_2C).
      ImageSequences[0]));
    SpellHSMap^.PlaceHX(Animation, X, Y, Layer);
  end;
  TSFXLibrary(LookupSpell(
    TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).F_Spell_28).Play(0);
end;

constructor TGlobalTargetSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  F_Spell_22 := 2;
end;

procedure TGlobalTargetSpell.ShowTargetSelection(Target: TTargetSelectionControl; HN, Xs, Ys: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Level: TMapLevel;
  MapF: TAoWMapField;
  X, Y, Intensity, Radius: Integer;
begin
  Level := SpellHSMap^.MapContainer.MapLevels[Shortint(Target.F_TargetSelectionControl_3B)];
  CenterHNtoHX(Shortint(Target.F_TargetSelectionControl_39), Shortint(Target.F_TargetSelectionControl_3A), HN, X, Y);
  { Original accepts Width/Height themselves (strict > bounds test). }
  if (X >= 0) and (Y >= 0) and (X <= Level.Width) and (Y <= Level.Height) then
  begin
    MapF := TAoWMapField(Level.Field[X,Y]);
    if TGlobalTargetSpellCalls(Self).ValidSelectionMapF(Integer(MapF)) then
    begin
      Radius := HNtoRad(HN);
      Intensity := Abs((SpellHSMap^.Frame + Radius) mod 9 - 4) * 20 + 20;
      TCustomImageLibrary(Target.F_TargetSelectionControl_04)[0].ShowBlended(Xs - 8, Ys, SurfaceDesc,
        SpellIntensityTable^.LookupTables[Intensity]);
    end
    else
      TCustomImageLibrary(Target.F_TargetSelectionControl_04)[1].Show(Xs - 8, Ys, SurfaceDesc);
  end;
end;

procedure TGlobalTargetSpell.ValidTargetMapF(A1: Integer);
asm
  { needs: Boolean result, retained in AL for the existing procedure ABI. }
  MOV AL, 1
end;

procedure TGlobalTargetSpell.ValidTargetSelectionMapF(A1: Integer);
begin
  if (SpellHSMap^.F_AbstractAoWHSMap_C9 <> 0) and
    not MapExplored(TAoWMapField(A1), FCasterPlayer) then
  begin
    { needs: Boolean function declaration; preserve result for callers. }
    asm XOR EAX, EAX end;
    Exit;
  end;
  asm MOV AL, 1 end;
end;

procedure TGlobalTargetSpell.ValidTargetSelection(A1: Integer);
asm
  { needs: Boolean result. }
  MOV AL, 1
end;

procedure TGlobalTargetSpell.OnTargetSelectionChange(Sender: TObject);
var
  Target: TTargetSelectionView;
  Caster: TAbstractUnit;
begin
  Target := TTargetSelectionView(Sender);
  Caster := FindSpellUnit(TUnitControl(SpellHSMap^.F_AoWHSMap_FC), FCasterID);
  if Caster <> nil then
    case Target.Change of
      tscDeactivated:
        begin
          Target.Changes.Remove(OnTargetSelectionChange);
          TTargetSelectionControl(Target).Deactivate;
        end;
      tscSelected:
        if TGlobalTargetSpellCalls(Self).ValidSelection(Integer(Target)) then
          if TGlobalTargetSpellCalls(Self).Selected(Integer(Caster), Target.X, Target.Y, Target.Layer) then
          begin
            Target.Changes.Remove(OnTargetSelectionChange);
            TTargetSelectionControl(Target).Deactivate;
          end;
    end
  else
  begin
    Target.Changes.Remove(OnTargetSelectionChange);
    TTargetSelectionControl(Target).Deactivate;
  end;
end;

procedure TGlobalTargetSpell.SetupTargetSelection(A1: Integer; A2: Integer);
var
  Target: TTargetSelectionView;
  UnitLayer, UnitY, UnitX: Shortint;
begin
  Target := TTargetSelectionView(A2);
  with Target do
  begin
    TTargetSelectionControl(Target).Initialize(A1);
    Mode := [tmOwnerDraw, tmValidateDistance, tmExternalFloater] + Mode;
    { needs: TAbstractUnit.GetLocation(var X, Y, Layer: Shortint); $5579E5D5. }
    TAbstractUnit(A1).GetLocation(UnitX, UnitY, UnitLayer);
    CenterX := UnitX;
    CenterY := UnitY;
    CenterLayer := UnitLayer;
    Distance := 12;
    Changes.Add(OnTargetSelectionChange);
    OnShow := ShowTargetSelection;
    { needs: TSpell.$08 is a string; draft declares Integer. }
    Text.Text := SysUtils.Format(SpellTranslate(SelectTargetLocationForXOnMapRStr),
      [TSpellNameView(Pointer(Self)^).Name]);
    Caption := TSpellNameView(Pointer(Self)^).Name;
    CancelCaption := SpellTranslate(SpellCancelRStr);
    Preview := TImageSequenceList(LookupSpell(
      TSpellControl(SpellHSSet^.FSpellControl), F_Spell_10).F_Spell_2C).
      ImageSequences[20].GetPreviewImage;
    ValidPreview := TImageSequenceList(LookupSpell(
      TSpellControl(SpellHSSet^.FSpellControl), F_Spell_10).F_Spell_2C).
      ImageSequences[21].GetPreviewImage;
    InvalidPreview := TImageSequenceList(LookupSpell(
      TSpellControl(SpellHSSet^.FSpellControl), F_Spell_10).F_Spell_2C).
      ImageSequences[22].GetPreviewImage;
  end;
end;

procedure TGlobalTargetSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
asm
  { needs: Boolean result; stack arguments require the normal EBP frame. }
  XOR EAX, EAX
end;

{ needs: Boolean results on the shared TSpell virtuals. Helpers keep managed
  string finalization before returning AL; the public methods tail-call them. }
function GlobalTargetCanActivate(Spell: TGlobalTargetSpell; Caster: Integer;
  MessagePtr: Integer): Boolean;
var
  X, Y, Layer: Shortint;
begin
  Result := BaseCanActivate(Spell, Caster, MessagePtr);
  if Result and Spell.FAboveGroundOnly then
  begin
    TAbstractUnit(Caster).GetLocation(X, Y, Layer);
    if Layer <> 0 then
    begin
      Result := False;
      PSpellString(MessagePtr)^ := SpellTranslate(CannotCastSpellInUndergoundRStr);
    end;
  end;
end;

procedure TGlobalTargetSpell.CanActivate(A1: Integer; A2: Integer);
asm
  JMP GlobalTargetCanActivate
end;

function VirtualCanActivate(Spell: TSpell; Caster, MessagePtr: Integer): Boolean; assembler;
asm
  MOV EAX, Spell
  MOV EDX, Caster
  MOV ECX, MessagePtr
  PUSH EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX+$68]
  POP EBX
end;

procedure BaseActivate(Spell: TSpell; Caster, A2: Integer); assembler;
asm
  JMP TSpell.Activate
end;

function GlobalTargetActivate(Spell: TGlobalTargetSpell; Caster, A2: Integer): Boolean;
var
  MessageText: string;
begin
  BaseActivate(Spell, Caster, A2);
  if VirtualCanActivate(Spell, Caster, Integer(@MessageText)) then
  begin
    Spell.FCasterID := TAbstractUnit(Caster).FUnitID;
    Spell.FCasterPlayer := Shortint(TAbstractUnit(Caster).F_AbstractUnit_24);
    Spell.SetupTargetSelection(Caster, SpellHSMap^.F_AoWHSMap_E0);
    TTargetSelectionControl(SpellHSMap^.F_AoWHSMap_E0).Activate;
    Result := True;
  end
  else
    Result := False;
end;

procedure TGlobalTargetSpell.Activate(A1: Integer; A2: Integer);
asm
  JMP GlobalTargetActivate
end;

{ needs: the following AoWE drafts return values at the original call sites.
  The stack-argument shims discard their assembler EBP frame before tail calls. }
function SpellMapRandom(Map: TAoWHSMap; Range: Integer): Integer; assembler;
asm JMP TAoWHSMap.Random end;

function SpellFieldArmy(MapF: TAoWMapField): TArmyHS; assembler;
asm JMP TAoWMapField.GetArmyHS end;

function TSpellMapCalls.TerrainVisible(X, Y, Layer: Byte; Radius: Integer): Boolean; assembler;
asm POP EBP; JMP TAoWHSMap.TerrainVisible end;

function TSpellMapCalls.WatchingTerrain(X, Y, Layer: Byte; Radius: Integer): Boolean; assembler;
asm POP EBP; JMP TAoWHSMap.WatchingTerrain end;

procedure TSpellMapCalls.ValidateTerrain(Player, X, Y, Layer: Byte; Radius: Integer); assembler;
asm POP EBP; JMP TAoWHSMap.ValidateTerrainObservation end;

{ needs: Animation.TTwinkleAnimation.Setup has TImageSequence/TTwinkleMode
  arguments ($5579EA15-$5579EA1F); Animation is outside the interface exception. }
procedure SpellTwinkleSetup(A: TTwinkleAnimation; Sequence: TImageSequence;
  Mode: TTwinkleMode; Count, StartRadius, EndRadius, Duration: Integer); assembler;
asm POP EBP; JMP TTwinkleAnimation.Setup end;

class function TFreezeWaterTE.ClassID: Integer;
begin Result := $21303; end;

procedure TFreezeWaterTE.ChangeTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
var
  Ice: TFrozenWaterHS;
begin
  if SpellFieldArmy(TAoWMapField(MapF)) = nil then
    if Smallint(TerrainType) = Ord(ttWater) then
      TerrainType := Ord(ttIce)
    else if Smallint(TerrainType) = Ord(ttUndergroundWater) then
      TerrainType := Ord(ttUndergroundIce)
    else if TerrainType in [Ord(ttIce), Ord(ttUndergroundIce)] then
    begin
      Ice := TFrozenWaterHS(MapF.FindOwnedHS(TFrozenWaterHS));
      if Ice <> nil then
      begin
        Ice.F_FrozenWaterHS_0C := (SpellMapRandom(SpellHSMap^, 11) - 5) div 5 + 3;
        Ice.F_FrozenWaterHS_0D := F_SpellTE_18;
      end;
    end;
end;

procedure TFreezeWaterTE.TerrainChanged(MapF: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint);
var
  Ice: TFrozenWaterHS;
begin
  if (MapF.TerrainType in [Ord(ttIce), Ord(ttUndergroundIce)]) and
    not (OriginalTerrainType in [Ord(ttIce), Ord(ttUndergroundIce)]) then
  begin
    Ice := TFrozenWaterHS(MapF.FindOwnedHS(TFrozenWaterHS));
    if Ice = nil then
    begin
      Ice := TFrozenWaterHS.Create(nil);
      SpellHSMap^.PlaceHX(Ice, MapF.Xhx, MapF.Yhx, MapF.Lhx);
    end;
    Ice.F_FrozenWaterHS_0C := (SpellMapRandom(SpellHSMap^, 11) - 5) div 5 + 3;
    Ice.F_FrozenWaterHS_0D := F_SpellTE_18;
  end;
end;

procedure TFreezeWaterTE.Process(A1: Integer; A2: Integer);
var
  Caster: TAbstractUnit;
  Twinkle: TTwinkleAnimation;
begin
  Caster := TAbstractUnit(A1);
  inherited Process(A1, A2);
  with TSpellMapCalls(SpellHSMap^) do
    ValidateTerrain(Caster.F_AbstractUnit_24,
      Byte(TSpellLocation(FLocation).X), Byte(TSpellLocation(FLocation).Y),
      Byte(TSpellLocation(FLocation).Layer), 2);
  if TSpellMapCalls(SpellHSMap^).TerrainVisible( Byte(TSpellLocation(FLocation).X),
    Byte(TSpellLocation(FLocation).Y), Byte(TSpellLocation(FLocation).Layer), 2) then
  begin
    Twinkle := TTwinkleAnimation.Create(nil);
    SpellTwinkleSetup(Twinkle, TImageSequenceList(LookupSpell(
      TSpellControl(SpellHSSet^.FSpellControl), 10).F_Spell_2C).ImageSequences[0],
      [tmExpand], 100, 64, 50, 30);
    SpellHSMap^.PlaceHX(Twinkle, TSpellLocation(FLocation).X,
      TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer);
  end;
  { needs: TAbstractAoWHSMap.$A4 contains the seated player at byte $A5. }
  if (Byte(TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) = Caster.F_AbstractUnit_24) or
    TSpellMapCalls(SpellHSMap^).WatchingTerrain( Byte(TSpellLocation(FLocation).X),
      Byte(TSpellLocation(FLocation).Y), Byte(TSpellLocation(FLocation).Layer), 2) then
    TSFXLibrary(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), 10).F_Spell_28).Play(0);
  SpellHSMap^.ChangeTerrainEx(nil, TSpellLocation(FLocation).X,
    TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer, 1,
    ChangeTerrain, TerrainChanged);
  LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).
    CastingDone(A1, F_SpellTE_1C);
  { needs: TSpellTE.Process returns a result in EAX (zero for this event). }
  asm XOR EAX, EAX end;
end;

{ needs: TArmyHS.VisibleForSeatedPlayer: Boolean; $5579EC2B tests AL. }
function SpellArmyVisible(Army: TArmyHS): Boolean; assembler;
asm JMP TArmyHS.VisibleForSeatedPlayer end;

constructor TFreezeWater.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(FreezeWaterRStr);
  F_Spell_10 := 10;
  F_Spell_14 := 5;
  F_Spell_21 := 3;
  F_Spell_20 := 6;
end;

procedure TFreezeWater.ValidTargetMapF(A1: Integer);
asm
  { Original Boolean-return ABI; foreign P7 overrides remain procedures. }
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EBX, EDX
  MOV ESI, EAX
  MOV EDX, EBX
  MOV EAX, ESI
  CALL TGlobalTargetSpell.ValidTargetMapF
  TEST AL, AL
  JZ @@False
  MOVSX EDI, BYTE PTR [EBX+$14]
  TEST DI, DI
  JZ @@TerrainOK
  CMP DI, 10
  JNZ @@False
@@TerrainOK:
  MOV EDX, [SpellStructureClass]
  MOV EAX, EBX
  CALL TMapField.FindNoneTransparentHS
  TEST EAX, EAX
  JZ @@True
@@False:
  XOR EAX, EAX
  JMP @@CheckArmy
@@True:
  MOV AL, 1
@@CheckArmy:
  TEST AL, AL
  JZ @@Done
  MOV EAX, EBX
  CALL TAoWMapField.GetArmyHS
  TEST EAX, EAX
  SETZ AL
@@Done:
  POP EDI
  POP ESI
  POP EBX
end;

procedure TFreezeWater.ValidTargetSelectionMapF(A1: Integer);
asm
  { Original Boolean-return ABI; foreign P7 overrides remain procedures. }
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EDX, ESI
  MOV EAX, EBX
  CALL TGlobalTargetSpell.ValidTargetSelectionMapF
  TEST AL, AL
  JZ @@False
  MOVSX EDI, BYTE PTR [ESI+$14]
  TEST DI, DI
  JZ @@TerrainOK
  CMP DI, 10
  JNZ @@False
@@TerrainOK:
  MOV EDX, [SpellStructureClass]
  MOV EAX, ESI
  CALL TMapField.FindNoneTransparentHS
  TEST EAX, EAX
  JZ @@True
@@False:
  XOR EAX, EAX
  JMP @@CheckArmy
@@True:
  MOV AL, 1
@@CheckArmy:
  MOV EBX, EAX
  TEST BL, BL
  JZ @@Done
  MOV EAX, ESI
  CALL TAoWMapField.GetArmyHS
  MOV ESI, EAX
  TEST ESI, ESI
  JZ @@Done
  MOV EAX, ESI
  CALL TArmyHS.VisibleForSeatedPlayer
  MOV EBX, EAX
  XOR BL, 1
@@Done:
  MOV EAX, EBX
  POP EDI
  POP ESI
  POP EBX
end;

procedure TFreezeWater.SetupTargetSelection(A1: Integer; A2: Integer);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Integer(Target));
  TShortIntList(Target.F_TargetSelectionControl_08).Clear;
  for I := 0 to RadToHN(2) - 1 do
    TShortIntList(Target.F_TargetSelectionControl_08).Add(0);
end;

procedure TFreezeWater.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Event: TFreezeWaterTE;
begin
  Event := TFreezeWaterTE.Create(nil);
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).F_AbstractUnit_24,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).F_AbstractUnit_24)).Add(Event);
  Event.Release;
  asm MOV AL, 1 end;
end;

{ needs: TFireControl.PlaceFire(X,Y,Layer:Integer; Create:Boolean): TFire,
  result consumed at $5579EDC3; GetSource returns TAbstractUnit at $5579EDE2. }
function SpellPlaceFire(Control: TFireControl; X, Y, Layer: Integer; CreateFire: Boolean): TFire; assembler;
asm POP EBP; JMP TFireControl.PlaceFire end;

function SpellSource(Event: TSpellTE): TAbstractUnit; assembler;
asm JMP TSpellTE.GetSource end;

class function TFireBarrierTE.ClassID: Integer;
begin Result := $21304; end;

procedure TFireBarrierTE.CreateFireBarrier;
var
  Walk: THNWalkData;
  Level: TMapLevel;
  MapF: TAoWMapField;
  Fire: TFire;
begin
  RandSeed := SpellMapRandom(SpellHSMap^, $FFFFFF);
  Level := SpellHSMap^.MapContainer.MapLevels[TSpellLocation(FLocation).Layer];
  InitHNWalk(Walk, TSpellLocation(FLocation).X, TSpellLocation(FLocation).Y, 0);
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      MapF := TAoWMapField(Level.Field[Walk.X, Walk.Y]);
      if TGlobalTargetSpellCalls(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), 11)).
        ValidMapF(Integer(MapF)) and (SpellFieldArmy(MapF) = nil) then
      begin
        Fire := SpellPlaceFire(TFireControl(SpellHSSet^.FFireControl),
          Walk.X, Walk.Y, TSpellLocation(FLocation).Layer, True);
        if Fire <> nil then
        begin
          Fire.SetupExplosion(Random(35));
          Fire.F_Fire_1D := 3;
          Fire.F_Fire_24 := SpellSource(Self).F_AbstractUnit_24;
        end;
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure TFireBarrierTE.Process(A1: Integer; A2: Integer);
begin
  inherited Process(A1, A2);
  CreateFireBarrier;
  LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).
    CastingDone(A1, LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).F_Spell_14);
  asm XOR EAX, EAX end;
end;

constructor TFireBarrier.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(FireBarrierRStr);
  F_Spell_10 := 11;
  F_Spell_14 := 5;
  F_Spell_21 := 3;
  F_Spell_20 := 5;
end;

procedure TFireBarrier.ValidTargetMapF(A1: Integer);
asm
  { Original Boolean-return ABI; foreign P7 overrides remain procedures. }
  PUSH EBX
  PUSH ESI
  MOV EBX, EDX
  MOV ESI, EAX
  MOV EDX, EBX
  MOV EAX, ESI
  CALL TGlobalTargetSpell.ValidTargetMapF
  TEST AL, AL
  JZ @@False
  MOV AL, BYTE PTR [EBX+$14]
  TEST AL, AL
  JZ @@False
  SUB AL, 6
  JZ @@False
  SUB AL, 4
  JZ @@False
  SUB AL, 3
  JZ @@False
  MOV EDX, [SpellStructureClass]
  MOV EAX, EBX
  CALL TMapField.FindNoneTransparentHS
  TEST EAX, EAX
  JZ @@True
@@False:
  XOR EAX, EAX
  JMP @@CheckArmy
@@True:
  MOV AL, 1
@@CheckArmy:
  TEST AL, AL
  JZ @@Done
  MOV EAX, EBX
  CALL TAoWMapField.GetArmyHS
  TEST EAX, EAX
  SETZ AL
@@Done:
  POP ESI
  POP EBX
end;

procedure TFireBarrier.ValidTargetSelectionMapF(A1: Integer);
asm
  { Original Boolean-return ABI; foreign P7 overrides remain procedures. }
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EDX, ESI
  MOV EAX, EBX
  CALL TGlobalTargetSpell.ValidTargetSelectionMapF
  TEST AL, AL
  JZ @@False
  MOV AL, BYTE PTR [ESI+$14]
  TEST AL, AL
  JZ @@False
  SUB AL, 6
  JZ @@False
  SUB AL, 4
  JZ @@False
  SUB AL, 3
  JZ @@False
  MOV EDX, [SpellStructureClass]
  MOV EAX, ESI
  CALL TMapField.FindNoneTransparentHS
  TEST EAX, EAX
  JZ @@True
@@False:
  XOR EAX, EAX
  JMP @@CheckArmy
@@True:
  MOV AL, 1
@@CheckArmy:
  MOV EBX, EAX
  TEST BL, BL
  JZ @@Done
  MOV EAX, ESI
  CALL TAoWMapField.GetArmyHS
  MOV ESI, EAX
  TEST ESI, ESI
  JZ @@Done
  MOV EAX, ESI
  CALL TArmyHS.VisibleForSeatedPlayer
  MOV EBX, EAX
  XOR BL, 1
@@Done:
  MOV EAX, EBX
  POP ESI
  POP EBX
end;

procedure TFireBarrier.SetupTargetSelection(A1: Integer; A2: Integer);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Integer(Target));
  TShortIntList(Target.F_TargetSelectionControl_08).Clear;
  for I := 0 to RadToHN(2) - 1 do
    TShortIntList(Target.F_TargetSelectionControl_08).Add(0);
end;

procedure TFireBarrier.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Event: TFireBarrierTE;
begin
  Event := TFireBarrierTE.Create(nil);
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).F_AbstractUnit_24,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).F_AbstractUnit_24)).Add(Event);
  Event.Release;
  asm MOV AL, 1 end;
end;

class function TLevelTerrainTE.ClassID: Integer;
begin Result := $21309; end;

procedure TLevelTerrainTE.LevelTerrain;
var
  Walk: THNWalkData;
  Level: TMapLevel;
  MapF: TAoWMapField;
begin
  Level := SpellHSMap^.MapContainer.MapLevels[TSpellLocation(FLocation).Layer];
  InitHNWalk(Walk, TSpellLocation(FLocation).X, TSpellLocation(FLocation).Y, 0);
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      MapF := TAoWMapField(Level.Field[Walk.X, Walk.Y]);
      if TGlobalTargetSpellCalls(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), 18)).
        ValidMapF(Integer(MapF)) and (SpellFieldArmy(MapF) = nil) then
      begin
        SpellHSMap^.ClearTerrain(Walk.X, Walk.Y, TSpellLocation(FLocation).Layer, 0, -1);
        if Smallint(MapF.TerrainType) = Ord(ttEarth) then
          SpellHSMap^.ChangeTerrain(nil, Walk.X, Walk.Y, TSpellLocation(FLocation).Layer, 0, Ord(ttDirt));
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure TLevelTerrainTE.Process(A1: Integer; A2: Integer);
begin
  inherited Process(A1, A2);
  PlayDefaultEffects(TSpellLocation(FLocation).X, TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer);
  LevelTerrain;
  LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).
    CastingDone(A1, LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).F_Spell_14);
  asm XOR EAX, EAX end;
end;

constructor TLevelTerrain.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(LevelTerrainRStr);
  F_Spell_10 := 18;
  F_Spell_14 := 5;
  F_Spell_21 := 3;
  F_Spell_20 := 3;
end;

procedure TLevelTerrain.ValidTargetMapF(A1: Integer);
asm
  { Original Boolean-return ABI; foreign P7 overrides remain procedures. }
  PUSH EBX
  PUSH ESI
  MOV EBX, EDX
  MOV ESI, EAX
  MOV EDX, EBX
  MOV EAX, ESI
  CALL TGlobalTargetSpell.ValidTargetMapF
  TEST AL, AL
  JZ @@False
  MOV AL, BYTE PTR [EBX+$14]
  TEST AL, AL
  JZ @@False
  SUB AL, 6
  JZ @@False
  SUB AL, 2
  JZ @@False
  SUB AL, 2
  JZ @@False
  SUB AL, 3
  JZ @@False
  MOV EDX, [SpellStructureClass]
  MOV EAX, EBX
  CALL TMapField.FindNoneTransparentHS
  TEST EAX, EAX
  JZ @@True
@@False:
  XOR EAX, EAX
  JMP @@CheckArmy
@@True:
  MOV AL, 1
@@CheckArmy:
  TEST AL, AL
  JZ @@Done
  MOV EAX, EBX
  CALL TAoWMapField.GetArmyHS
  TEST EAX, EAX
  SETZ AL
@@Done:
  POP ESI
  POP EBX
end;

procedure TLevelTerrain.ValidTargetSelectionMapF(A1: Integer);
asm
  { Original Boolean-return ABI; foreign P7 overrides remain procedures. }
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EDX, ESI
  MOV EAX, EBX
  CALL TGlobalTargetSpell.ValidTargetSelectionMapF
  TEST AL, AL
  JZ @@False
  MOV AL, BYTE PTR [ESI+$14]
  TEST AL, AL
  JZ @@False
  SUB AL, 6
  JZ @@False
  SUB AL, 2
  JZ @@False
  SUB AL, 2
  JZ @@False
  SUB AL, 3
  JZ @@False
  MOV EDX, [SpellStructureClass]
  MOV EAX, ESI
  CALL TMapField.FindNoneTransparentHS
  TEST EAX, EAX
  JZ @@True
@@False:
  XOR EAX, EAX
  JMP @@CheckArmy
@@True:
  MOV AL, 1
@@CheckArmy:
  MOV EBX, EAX
  TEST BL, BL
  JZ @@Done
  MOV EAX, ESI
  CALL TAoWMapField.GetArmyHS
  MOV ESI, EAX
  TEST ESI, ESI
  JZ @@Done
  MOV EAX, ESI
  CALL TArmyHS.VisibleForSeatedPlayer
  MOV EBX, EAX
  XOR BL, 1
@@Done:
  MOV EAX, EBX
  POP ESI
  POP EBX
end;

procedure TLevelTerrain.SetupTargetSelection(A1: Integer; A2: Integer);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Integer(Target));
  TShortIntList(Target.F_TargetSelectionControl_08).Clear;
  for I := 0 to RadToHN(2) - 1 do
    TShortIntList(Target.F_TargetSelectionControl_08).Add(0);
end;

procedure TLevelTerrain.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Event: TLevelTerrainTE;
begin
  Event := TLevelTerrainTE.Create(nil);
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).F_AbstractUnit_24,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).F_AbstractUnit_24)).Add(Event);
  Event.Release;
  asm MOV AL, 1 end;
end;

class function TRejuvenateTE.ClassID: Integer;
begin Result := $21310; end;

procedure TRejuvenateTE.RejuvenateTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
begin
  if TerrainType in [Ord(ttDesert)..Ord(ttWasteland)] then TerrainType := Ord(ttGrass);
end;

procedure TRejuvenateTE.Process(A1: Integer; A2: Integer);
var
  Caster: TAbstractUnit;
  Twinkle: TTwinkleAnimation;
begin
  Caster := TAbstractUnit(A1);
  inherited Process(A1, A2);
  with TSpellMapCalls(SpellHSMap^) do
    ValidateTerrain(Caster.F_AbstractUnit_24,
      Byte(TSpellLocation(FLocation).X), Byte(TSpellLocation(FLocation).Y),
      Byte(TSpellLocation(FLocation).Layer), 2);
  if TSpellMapCalls(SpellHSMap^).TerrainVisible( Byte(TSpellLocation(FLocation).X),
    Byte(TSpellLocation(FLocation).Y), Byte(TSpellLocation(FLocation).Layer), 2) then
  begin
    Twinkle := TTwinkleAnimation.Create(nil);
    SpellTwinkleSetup(Twinkle, TImageSequenceList(LookupSpell(
      TSpellControl(SpellHSSet^.FSpellControl), 41).F_Spell_2C).ImageSequences[0],
      [tmRotate], 100, 64, 50, 30);
    SpellHSMap^.PlaceHX(Twinkle, TSpellLocation(FLocation).X,
      TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer);
  end;
  { needs: TAbstractAoWHSMap.$A4 contains the seated player at byte $A5. }
  if (Byte(TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) = Caster.F_AbstractUnit_24) or
    TSpellMapCalls(SpellHSMap^).WatchingTerrain( Byte(TSpellLocation(FLocation).X),
      Byte(TSpellLocation(FLocation).Y), Byte(TSpellLocation(FLocation).Layer), 2) then
    TSFXLibrary(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), 41).F_Spell_28).Play(0);
  SpellHSMap^.ChangeTerrainEx(nil, TSpellLocation(FLocation).X,
    TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer, 2,
    RejuvenateTerrain, nil);
  LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).
    CastingDone(A1, LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), F_SpellTE_10).F_Spell_14);
  { needs: TSpellTE.Process returns a result in EAX (zero for this event). }
  asm XOR EAX, EAX end;
end;

constructor TRejuvenate.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(RejuvenateRStr);
  F_Spell_10 := 41;
  F_Spell_14 := 5;
  F_Spell_21 := 1;
  F_Spell_20 := 1;
  FAboveGroundOnly := True;
end;

procedure TRejuvenate.ValidTargetMapF(A1: Integer);
asm
  { Original result in AL, with two early returns. }
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EDX, ESI
  MOV EAX, EBX
  CALL TGlobalTargetSpell.ValidTargetMapF
  TEST AL, AL
  JZ @@False
  MOV AL, BYTE PTR [ESI+$14]
  ADD AL, $FE
  SUB AL, 4
  JB @@True
@@False:
  XOR EAX, EAX
  POP ESI
  POP EBX
  RET
@@True:
  MOV AL, 1
  POP ESI
  POP EBX
end;

procedure TRejuvenate.ValidTargetSelectionMapF(A1: Integer);
asm
  { Original result in AL, with two early returns. }
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EDX, ESI
  MOV EAX, EBX
  CALL TGlobalTargetSpell.ValidTargetSelectionMapF
  TEST AL, AL
  JZ @@False
  MOV AL, BYTE PTR [ESI+$14]
  ADD AL, $FE
  SUB AL, 4
  JB @@True
@@False:
  XOR EAX, EAX
  POP ESI
  POP EBX
  RET
@@True:
  MOV AL, 1
  POP ESI
  POP EBX
end;

procedure TRejuvenate.SetupTargetSelection(A1: Integer; A2: Integer);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Integer(Target));
  TShortIntList(Target.F_TargetSelectionControl_08).Clear;
  for I := 0 to RadToHN(3) - 1 do
    TShortIntList(Target.F_TargetSelectionControl_08).Add(0);
end;

procedure TRejuvenate.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Event: TRejuvenateTE;
begin
  Event := TRejuvenateTE.Create(nil);
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).F_AbstractUnit_24,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).F_AbstractUnit_24)).Add(Event);
  Event.Release;
  asm MOV AL, 1 end;
end;

constructor TWatcherEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TGlobalEnchantmentMode(F_GlobalEnchantment_11) :=
    TGlobalEnchantmentMode(F_GlobalEnchantment_11) - [gemTrueGlobal, gemOwned];
  F_GlobalEnchantment_14 := 50;
end;

procedure TWatcherEnchantment.GetName(A1: Integer);
begin
  PSpellString(A1)^ := TSpellNameView(Pointer(LookupSpell(
    TSpellControl(SpellHSSet^.FSpellControl), 57))^).Name;
end;

procedure TWatcherEnchantment.GetLocation(A1: Integer; A2: Integer);
asm
  { needs: TGlobalEnchantment.GetLocation returns a packed TXYL in EAX.
    Preserve its original register ABI while the shared procedure draft remains. }
  PUSH EBX
  PUSH ECX
  MOV EBX, EAX
  MOV EAX, [EBX+$24]
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX+$74]
  MOV BYTE PTR [ESP], AL
  MOV EAX, [EBX+$24]
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX+$78]
  MOV BYTE PTR [ESP+1], AL
  MOV EAX, [EBX+$24]
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX+$7C]
  MOV BYTE PTR [ESP+2], AL
  MOV EAX, [ESP]
  POP EDX
  POP EBX
end;

procedure TWatcherEnchantment.Deactivate(A1: Byte);
asm
  { needs: TGlobalEnchantment.Deactivate returns a value; P7 overrides retain
    the procedure draft, so preserve the original ABI and conditional Free. }
  PUSH EBX
  PUSH ESI
  MOV ESI, EAX
  TEST BYTE PTR [ESI+$10], 1
  JZ @@Inactive
  MOV EAX, ESI
  CALL TGlobalEnchantment.Deactivate
  MOV EBX, EAX
  MOV EAX, [ESI+$24]
  TEST BYTE PTR [EAX+$0C], 1
  JZ @@Done
  CALL TObject.Free
  JMP @@Done
@@Inactive:
  XOR EBX, EBX
@@Done:
  MOV EAX, EBX
  POP ESI
  POP EBX
end;

{ needs: typed result declarations in the AoWE interface and matching
  implementation headers. Register ABI shims keep those owners untouched. }
function SpellPlayer(List: TPlayerList; Index: Integer): TPlayer; assembler;
asm JMP TPlayerList.GetPlayers end;

function SpellRelation(Relations: TPlayerDiplomaticRelations; Player: Byte): Byte; assembler;
asm JMP TPlayerDiplomaticRelations.GetDiplomaticRelation end;

function SpellEnchantmentVisible(Enchantment: TGlobalEnchantment; Player: Byte): Boolean; assembler;
asm
  PUSH EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX+$84]
  POP EBX
end;

procedure SpellFogArea(Map: TAbstractAoWHSMap; X,Y,Layer,Radius: Integer); assembler;
asm POP EBP; JMP TAbstractAoWHSMap.FogArea end;

procedure SpellUnfogArea(Map: TAbstractAoWHSMap; X,Y,Layer,Radius: Integer); assembler;
asm POP EBP; JMP TAbstractAoWHSMap.UnFogArea end;

procedure SpellExploreArea(Map: TAbstractAoWHSMap; X,Y,Layer,Player,Radius: Integer); assembler;
asm POP EBP; JMP TAbstractAoWHSMap.ExploreArea end;

function TSpellMapCalls.MapVisible(X,Y,Layer: Shortint; Radius: Integer): Boolean; assembler;
asm POP EBP; JMP TAoWHSMap.Visible end;

type
  TWatcherState = set of (wsActive);
  TMapFieldFlagView = record
    Reserved: array[0..$17] of Byte;
    Flags: Integer;
  end;

constructor TWatcherHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FEnchantment := TWatcherEnchantment.Create(nil);
  FEnchantment.FWatcher := Self;
  FUnexplored := TIntegerList.Create;
  FVisibleForSeatedPlayer := False;
  FAnimationFrame := -1;
end;

destructor TWatcherHS.Destroy;
begin
  inherited Destroy;
  FUnexplored.Free;
  FEnchantment.Release;
end;

class function TWatcherHS.ClassID: Integer;
begin Result := $2077D; end;

function TWatcherHS.GetLevel: Byte;
begin Result := 27; end;

procedure TWatcherHS.StartAnimation(X, Y, Layer: Shortint);
var
  Walk: THNWalkData;
  Level: TMapLevel;
begin
  FAnimationFrame := 0;
  SpellHSMap^.DynamicFixedVisibleHS.AddChild(Self);
  TSFXLibrary(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl), 57).F_Spell_28).Play(0);
  FUnexplored.Clear;
  if SpellHSMap^.F_AbstractAoWHSMap_C9 <> 0 then
  begin
    InitHNWalk(Walk, X,Y,0);
    Level := SpellHSMap^.MapContainer.MapLevels[Layer];
    while Walk.Radius <= VisibilityRange do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        if not MapExplored(TAoWMapField(Level.Field[Walk.X,Walk.Y]),
          TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) then FUnexplored.Add(Walk.HN);
      WalkToNextHN(Walk);
    end;
  end;
end;

procedure TWatcherHS.StopAnimation;
begin
  SpellHSMap^.DynamicFixedVisibleHS.RemoveChild(Self);
  FAnimationFrame := -1;
  FUnexplored.Clear;
end;

procedure TWatcherHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X,Y, DX,DY, Radius,Angle, PX,PY,Intensity,I,Delay: Integer;
begin
  if (Lhx = SpellHSMap^.ViewL) and TSpellMapCalls(SpellHSMap^).MapVisible( Xhx,Yhx,Lhx,0) then
  begin
    HXtoHP(Xhx,Yhx,X,Y);
    X := X-XhpSurf+16;
    Y := Y-YhpSurf+16;
    if LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),57).F_Spell_2C <> 0 then
      TImageSequenceList(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),57).F_Spell_2C).
        ShowLooped(1,X,Y,SpellHSMap^.Frame,SurfaceDesc);
    if FAnimationFrame <> -1 then
    begin
      Inc(FAnimationFrame);
      { needs: AoWE.AoWEngine global at $558E945C. The map's engine supplies
        the same engine instance; byte $6D is the original display mode. }
      if (PByte(Integer(SpellHSMap^.Engine)+$6D)^ = 2) and (Lhx = SpellHSMap^.ViewL) then
      begin
        Intensity := 100-FAnimationFrame;
        HXtoHP(Xhx,Yhx,X,Y);
        X := X-XhpSurf-8;
        Y := Y-YhpSurf;
        for I := FUnexplored.Count-1 downto 0 do
        begin
          HNtoHP(FUnexplored[I],PX,PY);
          Inc(PX,X); Inc(PY,Y);
          TCustomImageLibrary(SpellHSSet^.FGeneralImages)[5].ShowBlended(PX,PY,
            SurfaceDesc, AlphaBlendTable.LookupTables[Intensity]);
        end;
      end;
      { Original resets the shared random generator for deterministic particles. }
      RandSeed := SpellHSMap^.F_AoWHSMap_22C;
      for I := 0 to 300 do
      begin
        Radius := Random(VisibilityRange shl 5);
        Angle := Random(360);
        Delay := Random(80);
        if FAnimationFrame-Delay >= 0 then
        begin
          DegreesRadToCo(Angle,Radius,Integer(@DX),Integer(@DY));
          TImageSequenceList(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),57).F_Spell_2C).
            Show(0,X+DX,Y+DY,FAnimationFrame-Delay,SurfaceDesc);
        end;
      end;
      if FAnimationFrame = 100 then StopAnimation;
    end;
  end;
end;

procedure TWatcherHS.UpdateExploration;
var
  I, OwnerPlayer: Integer;
begin
  if Activated then
  begin
    for I := 1 to TPlayerList(SpellHSMap^.FPlayers).Count-1 do
    begin
      OwnerPlayer := Shortint(FEnchantment.F_GlobalEnchantment_19);
      if (OwnerPlayer = I) or (SpellRelation(TPlayerDiplomaticRelations(
        SpellPlayer(TPlayerList(SpellHSMap^.FPlayers),OwnerPlayer).F_Player_40), I) = 2) then
        SpellExploreArea(SpellHSMap^, Xhx,Yhx,Lhx,I,VisibilityRange);
    end;
  end;
end;

procedure TWatcherHS.UpdateUnfog;
var
  Radius: Integer;
  OwnerPlayer: Shortint;
begin
  if Byte(TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) <> $FF then
  begin
    OwnerPlayer := Shortint(FEnchantment.F_GlobalEnchantment_19);
    if     ((OwnerPlayer = TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) or
    (SpellRelation(TPlayerDiplomaticRelations(SpellPlayer(
      TPlayerList(SpellHSMap^.FPlayers),OwnerPlayer).F_Player_40),
      Byte(TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer)) = 2)) and Activated then
      Radius := VisibilityRange
    else Radius := 0;
  end
  else Radius := 0;
  if Radius <> FUnfogRadius then
  begin
    if FUnfogRadius <> 0 then SpellFogArea(SpellHSMap^,Xhx,Yhx,Lhx,FUnfogRadius);
    FUnfogRadius := Radius;
    if FUnfogRadius <> 0 then SpellUnfogArea(SpellHSMap^,Xhx,Yhx,Lhx,FUnfogRadius);
  end;
end;

procedure TWatcherHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FEnchantment,$28);
end;

procedure TWatcherHS.Activate;
var
  MapF: TMapField;
begin
  inherited Activate;
  TWatcherState(FWatcherState) := TWatcherState(FWatcherState) + [wsActive];
  FEnchantment.Activate(FEnchantment.F_GlobalEnchantment_19,0);
  MapF := TMapField(Owner);
  SpellHSMap^.NotifyPlayerChanged(MapF.Xhx,MapF.Yhx,MapF.Lhx);
  MapF := TMapField(Owner);
  SpellHSMap^.UpdatePlayerSeen(Shortint(FEnchantment.F_GlobalEnchantment_19),
    MapF.Xhx,MapF.Yhx,MapF.Lhx,VisibilityRange,VisibilityRange);
  UpdateExploration;
  UpdateUnfog;
end;

procedure TWatcherHS.Deactivate;
begin
  inherited Deactivate;
  TWatcherState(FWatcherState) := TWatcherState(FWatcherState) - [wsActive];
  if FEnchantment.F_GlobalEnchantment_10 and 1 <> 0 then
    FEnchantment.Deactivate(FEnchantment.F_GlobalEnchantment_19);
  SpellHSMap^.NotifyPlayerChanged(TMapField(Owner).Xhx,TMapField(Owner).Yhx,TMapField(Owner).Lhx);
  UpdateUnfog;
end;

function TWatcherHS.VisibilityRange: Integer;
var
  Player: Shortint;
begin
  Result := 8;
  if Lhx <> 0 then
  begin
    Inc(Result);
    Result := Result shr 1;
  end
  else
  begin
    Player := Shortint(FEnchantment.F_GlobalEnchantment_19);
    if (Player > 0) and (PByte(SpellPlayer(TPlayerList(SpellHSMap^.FPlayers),Player).
      F_Player_54+$45)^ and 8 <> 0) then
  begin
    Inc(Result);
    Result := Result shr 1;
  end;
  end;
end;

function TWatcherHS.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  TMapField(Owner).UpdateMapField;
end;

procedure TWatcherHS.RemoveFromMap;
var
  MapF: TMapField;
begin
  MapF := TMapField(Owner);
  inherited RemoveFromMap;
  MapF.UpdateMapField;
end;

procedure TWatcherHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if Info.HN = 0 then
    TMapFieldFlagView(Pointer(Info.MapField)^).Flags :=
      TMapFieldFlagView(Pointer(Info.MapField)^).Flags or $1000 or $1000000;
end;

procedure TWatcherHS.UpdateVisibleForSeatedPlayer;
var
  Visible: Boolean;
begin
  Visible := SpellEnchantmentVisible(FEnchantment,Byte(TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer));
  if FVisibleForSeatedPlayer <> Visible then
  begin
    FVisibleForSeatedPlayer := Visible;
    TGlobalMagicControl(SpellHSMap^.FPlayerControl).TriggerChangedEvent;
  end;
end;

procedure TWatcherHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
var
  ID: Integer;
begin
  inherited MsgProc(Msg,Sender);
  ID := Msg.MsgID;
  if ID = $20020008 then
  begin
    UpdateExploration; UpdateUnfog; Exit;
  end;
  if ID = $20020006 then
  begin
    UpdateUnfog; UpdateVisibleForSeatedPlayer;
  end;
end;

procedure TWatcherHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
var
  OwnerPlayer, Range: Integer;
begin
  with Msg do
  begin
  inherited MapFieldMsgProc(Msg);
  if MsgID = $110B then
    if Activated then
    begin
      OwnerPlayer := Shortint(FEnchantment.F_GlobalEnchantment_19);
      if (OwnerPlayer = Param[1]) or (SpellRelation(TPlayerDiplomaticRelations(
        SpellPlayer(TPlayerList(SpellHSMap^.FPlayers),OwnerPlayer).F_Player_40),
        Param[1]) = 2) then
        if Param[0] <= VisibilityRange then Result := 1;
    end;
  if MsgID = $110A then
    if Activated then
    begin
      OwnerPlayer := Shortint(FEnchantment.F_GlobalEnchantment_19);
      if (OwnerPlayer = Param[1]) or (SpellRelation(TPlayerDiplomaticRelations(
        SpellPlayer(TPlayerList(SpellHSMap^.FPlayers),OwnerPlayer).F_Player_40),
        Param[1]) = 2) then
        if Param[0] <= VisibilityRange then Result := 1;
    end;
  if MsgID = $110D then
  begin
    if VisibilityRange >= Param[0] then
    begin
      Range := Param[0];
      SpellHSMap^.UpdatePlayerSeen(Shortint(FEnchantment.F_GlobalEnchantment_19),
        TMapField(Owner).Xhx,TMapField(Owner).Yhx,TMapField(Owner).Lhx,Range,Range);
    end;
    UpdateVisibleForSeatedPlayer;
  end;
  end;
end;

class function TWatcherTE.ClassID: Integer;
begin Result := $2131B; end;

procedure TWatcherTE.Process(A1: Integer; A2: Integer);
var
  Watcher: TWatcherHS;
begin
  inherited Process(A1,A2);
  PlayDefaultEffects(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer);
  Watcher := TWatcherHS.Create(nil);
  Watcher.FEnchantment.F_GlobalEnchantment_19 := TAbstractUnit(A1).F_AbstractUnit_24;
  Watcher.FEnchantment.F_GlobalEnchantment_20 :=
    LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),57).F_Spell_1C;
  SpellHSMap^.PlaceHX(Watcher,TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer);
  if Byte(TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) = F_SpellTE_18 then
    Watcher.StartAnimation(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer);
  LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),F_SpellTE_10).
    CastingDone(A1,LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),F_SpellTE_10).F_Spell_14);
  asm XOR EAX, EAX end;
end;

{ needs: TPlayer.GetBusy: Boolean, tested at $557A0266. }
function SpellPlayerBusy(Player: TPlayer): Boolean; assembler;
asm JMP TPlayer.GetBusy end;

constructor TWatcher.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(WatcherRStr);
  F_Spell_10 := 57;
  FAboveGroundOnly := False;
end;

procedure TWatcher.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Busy: Boolean;
  Event: TWatcherTE;
begin
  Busy := SpellPlayerBusy(SpellPlayer(TPlayerList(SpellHSMap^.FPlayers),
    Shortint(TAbstractUnit(A1).F_AbstractUnit_24)));
  if not Busy then
  begin
    Event := TWatcherTE.Create(nil);
    Event.Initialize(F_Spell_10,TAbstractUnit(A1).F_AbstractUnit_24,
      TAbstractUnit(A1).FUnitID,F_Spell_14);
    Event.SetLocation(A2,A3,A4);
    TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
      GetTokenControl(Shortint(TAbstractUnit(A1).F_AbstractUnit_24)).Add(Event);
    Event.Release;
  end;
  { needs: Boolean function result, preserved while P7 procedure overrides remain. }
  asm MOV AL, Busy; XOR AL, 1 end;
end;

procedure TWatcher.SetupTargetSelection(A1: Integer; A2: Integer);
begin
  inherited SetupTargetSelection(A1,A2);
  TTargetSelectionMode(TTargetSelectionControl(A2).F_TargetSelectionControl_0D) :=
    TTargetSelectionMode(TTargetSelectionControl(A2).F_TargetSelectionControl_0D) - [tmFixedLevel,tmValidateDistance];
  TShortIntList(TTargetSelectionControl(A2).F_TargetSelectionControl_08).Clear;
end;

constructor TTornadoTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TTornadoTE.Destroy;
begin end;

class function TTornadoTE.ClassID: Integer;
begin Result := 0; end;

procedure TTornadoTE.Validate(A1: Integer);
begin end;

procedure TTornadoTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTornadoTE.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTornadoTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TTornado.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTornado.ValidWarpLocation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTornado.CalculateWarpLocation(A1: Integer; A2: Integer);
begin end;

procedure TTornado.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTornado.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

constructor TVortexTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TVortexTE.Destroy;
begin end;

class function TVortexTE.ClassID: Integer;
begin Result := 0; end;

procedure TVortexTE.Validate(A1: Integer);
begin end;

procedure TVortexTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TVortexTE.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TVortexTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TVortex.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TVortex.ValidTargetSelection(A1: Integer);
begin end;

procedure TVortex.ValidateTargetEvent(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TVortex.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TVortex.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

class function THealingShowersTE.ClassID: Integer;
begin Result := 0; end;

procedure THealingShowersTE.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THealingShowersTE.ChangeTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure THealingShowersTE.Process(A1: Integer; A2: Integer);
begin end;

constructor THealingShowers.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THealingShowers.ValidTargetMapF(A1: Integer);
begin end;

procedure THealingShowers.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure THealingShowers.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure THealingShowers.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TSmokeCloudSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSmokeCloudSpell.ValidTargetMapF(A1: Integer);
begin end;

procedure TSmokeCloudSpell.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TSmokeCloudSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TSmokeCloudSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSmokeCloudSpell.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure RegisterGlobalTargetSpells(A1: Integer);
begin end;

procedure UnregisterGlobalTargetSpells(A1: Integer);
begin end;


initialization
finalization

end.
