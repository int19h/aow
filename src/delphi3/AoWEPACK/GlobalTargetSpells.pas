unit GlobalTargetSpells;

{ Draft declarations of GlobalTargetSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  All class bodies and registration routines are recovered below. Local declaration
  workarounds are marked needs; world pointer cells use the shared P1 globals. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Animation, AoWE;

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
    FLocation: TXYL; { $20; packed coordinates, 557C493C }
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
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure ShowTargetSelection(Target: TTargetSelectionControl; HN, Xs, Ys: Integer; const SurfaceDesc: TSurfaceDesc); virtual;  { +09C }
    procedure OnTargetSelectionChange(Sender: TObject); virtual;  { +0A0 }
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); virtual;  { +0A4 }
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; virtual;  { +0A8  }
    function ValidTargetSelection(A1: TTargetSelectionControl): Boolean; virtual;  { +0AC; 557A1808 }
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; virtual;  { +0B0  }
    function ValidTargetMapF(A1: TMapField): Boolean; virtual;  { +0B4  }
  end;

  { TFreezeWaterTE (instance size 36, VMT 5579CDE0) }
  TFreezeWaterTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure ChangeTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
    procedure TerrainChanged(MapF: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint);
  end;

  { TFreezeWater (instance size 60, VMT 5579CEC0) }
  TFreezeWater = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

  { TFireBarrierTE (instance size 36, VMT 5579CFFC) }
  TFireBarrierTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure CreateFireBarrier;  { draft }
  end;

  { TFireBarrier (instance size 60, VMT 5579D0DC) }
  TFireBarrier = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

  { TLevelTerrainTE (instance size 36, VMT 5579D218) }
  TLevelTerrainTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure LevelTerrain;  { draft }
  end;

  { TLevelTerrain (instance size 60, VMT 5579D2F8) }
  TLevelTerrain = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

  { TRejuvenateTE (instance size 36, VMT 5579D434) }
  TRejuvenateTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure RejuvenateTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
  end;

  { TRejuvenate (instance size 60, VMT 5579D514) }
  TRejuvenate = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

  { TWatcherEnchantment (instance size 40, VMT 5579D648): $24 FWatcher. }
  TWatcherEnchantment = class(TGlobalEnchantment)
  public
    FWatcher: TWatcherHS;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName: string; override;
    function GetLocation: TXYL; override;
    function Deactivate(Player: Byte): Boolean; override;
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
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
  end;

  { TWatcher (instance size 60, VMT 5579DA04) }
  TWatcher = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
  end;

  { TTornadoTE (instance size 48, VMT 5579DB38): $24 angle,
    $28 animation, $2C selected army identity. }
  TTornadoTE = class(TGlobalTargetSpellTE)
  public
    FAngle: Integer;
    FAnimation: TAnimation;
    FArmyID: TArmyID;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure ShowAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer;
      const SurfaceDesc: TSurfaceDesc);
  end;

  { TTornado (instance size 60, VMT 5579DC10) }
  TTornado = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidWarpLocation(Army: TArmyHS; X, Y, Layer: Shortint): Boolean;
    function CalculateWarpLocation(Army: TArmyHS; Selection: Byte): Integer;
  end;

  { TVortexTE (instance size 48, VMT 5579DD44): $24 angle,
    $28 animation, $2C selected army identity. }
  TVortexTE = class(TGlobalTargetSpellTE)
  public
    FAngle: Integer;
    FAnimation: TAnimation;
    FArmyID: TArmyID;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure ShowAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer;
      const SurfaceDesc: TSurfaceDesc);
  end;

  { TVortex (instance size 60, VMT 5579DE1C) }
  TVortex = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelection(A1: TTargetSelectionControl): Boolean; override;
    procedure ValidateTargetEvent(Target: TTargetSelectionControl; X,Y,Layer: Shortint; var Valid: Boolean);
  end;

  { THealingShowersTE (instance size 40, VMT 5579DF48): $24 animation. }
  THealingShowersTE = class(TGlobalTargetSpellTE)
  public
    FAnimation: TAnimation;
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure ShowAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer;
      const SurfaceDesc: TSurfaceDesc);
    procedure ChangeTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
  end;

  { THealingShowers (instance size 60, VMT 5579E030) }
  THealingShowers = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

  { TSmokeCloudSpell (instance size 60, VMT 5579E16C) }
  TSmokeCloudSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

procedure RegisterGlobalTargetSpells(A1: TAoWEngine);
procedure UnregisterGlobalTargetSpells(A1: Integer);  { draft }

implementation

uses EventLog, SmokeCloud, AoWReg;

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
  TSpellLocation = packed record
    X, Y, Layer: Shortint;
    Reserved: Byte;
  end;

type
  PSpellHSSet = ^TAoWHSSet;
  PSpellHSMap = ^TAoWHSMap;
  PSpellEngine = ^TAoWEngine;
  PSpellIntensityTable = ^TLookupBlendTableCollection100;
const
  { Import cells bind to the shared globals; distinct references preserve the original reloads. }
  SpellStructureClass: TClass = TStructure;
  SpellHSSet: PSpellHSSet = @AoWHSSet;
  SpellHSMap: PSpellHSMap = @AoWHSMap; SpellObservedMap: PSpellHSMap = @AoWHSMap; SpellPlayerMap: PSpellHSMap = @AoWHSMap;
  SpellEngine: PSpellEngine = @AoWEngine;
{$IFDEF RUNTIME_PACKAGES}
var
  { Imported data addresses cannot be used in Delphi 3 static initializers. }
  SpellIntensityTable: PSpellIntensityTable;
{$ELSE}
  SpellIntensityTable: PSpellIntensityTable = @GFXE.IntensityBlendTable;
{$ENDIF}

resourcestring
  { needs: AoWE.CancelRStr, referenced at $5579E664; absent from draft. }
  SpellCancelRStr = 'Cancel';

{ needs: TSpellControl.GetSpell must return TSpell. Preserve its register ABI
  with a tail call until the shared declaration is corrected. }
{ needs: TAoWMapField.GetExplored(Player: Integer): Boolean ($5579E4C8). }
{ needs: TUnitControl.FindUnit(ID: Integer): TAbstractUnit ($5579E4F7). }
{ needs: AoWE.TranslateRStr(const S: string): string ($5579E62D). }
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
  Stream.rwInteger(FLocation.XYL, $14);
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
  if TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FCastImages).
    ImageSequences[0] <> nil then
  begin
    Animation := TImageSequenceAnimation.Create(nil);
    { needs: TImageSequenceAnimation.SetImageSequence(Value: TImageSequence). }
    Animation.SetImageSequence(TImageSequenceList(
      TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FCastImages).
      ImageSequences[0]);
    SpellHSMap^.PlaceHX(Animation, X, Y, Layer);
  end;
  TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FCastSounds).Play(0);
end;

constructor TGlobalTargetSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellType := stGlobal;
end;

procedure TGlobalTargetSpell.ShowTargetSelection(Target: TTargetSelectionControl; HN, Xs, Ys: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Level: TMapLevel;
  MapF: TAoWMapField;
  X, Y, Intensity, Radius: Integer;
begin
  Level := SpellHSMap^.MapContainer.MapLevels[Shortint(Target.FTargetL)];
  CenterHNtoHX(Shortint(Target.FTargetX), Shortint(Target.FTargetY), HN, X, Y);
  { Original accepts Width/Height themselves (strict > bounds test). }
  if (X >= 0) and (Y >= 0) and (X <= Level.Width) and (Y <= Level.Height) then
  begin
    MapF := TAoWMapField(Level.Field[X,Y]);
    if TGlobalTargetSpellCalls(Self).ValidSelectionMapF(Integer(MapF)) then
    begin
      Radius := HNtoRad(HN);
      Intensity := Abs((SpellHSMap^.Frame + Radius) mod 9 - 4) * 20 + 20;
      TCustomImageLibrary(Target.FImageLibrary)[0].ShowBlended(Xs - 8, Ys, SurfaceDesc,
        SpellIntensityTable^.LookupTables[Intensity]);
    end
    else
      TCustomImageLibrary(Target.FImageLibrary)[1].Show(Xs - 8, Ys, SurfaceDesc);
  end;
end;

function TGlobalTargetSpell.ValidTargetMapF(A1: TMapField): Boolean;
asm
  { needs: Boolean result, retained in AL for the existing procedure ABI. }
  MOV AL, 1
end;

function TGlobalTargetSpell.ValidTargetSelectionMapF(A1: TMapField): Boolean;
begin
  if (SpellHSMap^.FExplorationEnabled) and
    not TAoWMapField(A1).GetExplored(FCasterPlayer) then
  begin
    { needs: Boolean function declaration; preserve result for callers. }
    Result := False;
    Exit;
  end;
  Result := True;
end;

function TGlobalTargetSpell.ValidTargetSelection(A1: TTargetSelectionControl): Boolean;
begin
  Result := True;
end;

procedure TGlobalTargetSpell.OnTargetSelectionChange(Sender: TObject);
var
  Target: TTargetSelectionView;
  Caster: TAbstractUnit;
begin
  Target := TTargetSelectionView(Sender);
  Caster := TUnitControl(SpellHSMap^.FUnitControl).FindUnit(FCasterID);
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

procedure TGlobalTargetSpell.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var UnitX, UnitY, UnitLayer: Shortint;
begin
  with A2 do
  begin
    Initialize(A1);
    FTargetMode := FTargetMode + [tmOwnerDraw, tmValidateDistance, tmExternalFloater];
    A1.GetLocation(UnitX, UnitY, UnitLayer);
    FSourceX := UnitX;
    FSourceY := UnitY;
    FSourceL := UnitLayer;
    FRange := 12;
    FOnChange.Add(OnTargetSelectionChange);
    FOnShow := ShowTargetSelection;
    FText.Text := SysUtils.Format(AoWE.TranslateRStr(SelectTargetLocationForXOnMapRStr), [FSpellName]);
    FTitle := FSpellName;
    FCancelText := AoWE.TranslateRStr(CancelRStr);
    FSourceImage := SpellHSSet^.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[20].GetPreviewImage;
    FValidTargetImage := SpellHSSet^.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[21].GetPreviewImage;
    FInvalidTargetImage := SpellHSSet^.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[22].GetPreviewImage;
  end;
end;

function TGlobalTargetSpell.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
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
      PSpellString(MessagePtr)^ := AoWE.TranslateRStr(CannotCastSpellInUndergoundRStr);
    end;
  end;
end;

function TGlobalTargetSpell.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
var
  X, Y, Layer: Shortint;
begin
  Result := inherited CanActivate(A1, A2);
  if Result and FAboveGroundOnly then
  begin
    A1.GetLocation(X, Y, Layer);
    if Layer <> 0 then
    begin
      Result := False;
      A2 := AoWE.TranslateRStr(CannotCastSpellInUndergoundRStr);
    end;
  end;
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
    Spell.FCasterPlayer := Shortint(TAbstractUnit(Caster).FPlayer);
    Spell.SetupTargetSelection(TAbstractUnit(Caster), TTargetSelectionControl(SpellHSMap^.FTargetSelection));
    TTargetSelectionControl(SpellHSMap^.FTargetSelection).Activate;
    Result := True;
  end
  else
    Result := False;
end;

function TGlobalTargetSpell.Activate(A1: TAbstractUnit): Boolean;
var
  MessageText: string;
begin
  inherited Activate(A1);
  if CanActivate(A1, MessageText) then
  begin
    FCasterID := A1.FUnitID;
    FCasterPlayer := Shortint(A1.FPlayer);
    SetupTargetSelection(A1, TTargetSelectionControl(SpellHSMap^.FTargetSelection));
    TTargetSelectionControl(SpellHSMap^.FTargetSelection).Activate;
    Result := True;
  end
  else Result := False;
end;

{ needs: the following AoWE drafts return values at the original call sites.
  The stack-argument shims discard their assembler EBP frame before tail calls. }
{ needs: Animation.TTwinkleAnimation.Setup has TImageSequence/TTwinkleMode
  arguments ($5579EA15-$5579EA1F); Animation is outside the interface exception. }
class function TFreezeWaterTE.ClassID: Integer;
begin Result := $21303; end;

procedure TFreezeWaterTE.ChangeTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
var
  Ice: TFrozenWaterHS;
begin
  if TAoWMapField(MapF).GetArmyHS() = nil then
    if Smallint(TerrainType) = Ord(ttWater) then
      TerrainType := Ord(ttIce)
    else if Smallint(TerrainType) = Ord(ttUndergroundWater) then
      TerrainType := Ord(ttUndergroundIce)
    else if TerrainType in [Ord(ttIce), Ord(ttUndergroundIce)] then
    begin
      Ice := TFrozenWaterHS(MapF.FindOwnedHS(TFrozenWaterHS));
      if Ice <> nil then
      begin
        Ice.FDaysRemaining := (SpellHSMap^.Random(11) - 5) div 5 + 3;
        Ice.FCasterPlayer := FEventPlayerIndex;
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
    Ice.FDaysRemaining := (SpellHSMap^.Random(11) - 5) div 5 + 3;
    Ice.FCasterPlayer := FEventPlayerIndex;
  end;
end;

function TFreezeWaterTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  Twinkle: TTwinkleAnimation;
begin
  inherited Process(A1, A2);
  SpellHSMap^.ValidateTerrainObservation(A1.FPlayer,
      Byte(TSpellLocation(FLocation).X), Byte(TSpellLocation(FLocation).Y),
      Byte(TSpellLocation(FLocation).Layer), 2);
  if SpellHSMap^.TerrainVisible( Byte(TSpellLocation(FLocation).X),
    Byte(TSpellLocation(FLocation).Y), Byte(TSpellLocation(FLocation).Layer), 2) then
  begin
    Twinkle := TTwinkleAnimation.Create(nil);
    Twinkle.Setup(TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(10).FCastImages).ImageSequences[0],[tmExpand],100,64,50,30);
    SpellHSMap^.PlaceHX(Twinkle, TSpellLocation(FLocation).X,
      TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer);
  end;
  { needs: TAbstractAoWHSMap.$A4 contains the seated player at byte $A5. }
  if (TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer = A1.FPlayer) or
    SpellHSMap^.WatchingTerrain( Byte(TSpellLocation(FLocation).X),
      Byte(TSpellLocation(FLocation).Y), Byte(TSpellLocation(FLocation).Layer), 2) then
    TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(10).FCastSounds).Play(0);
  SpellHSMap^.ChangeTerrainEx(nil, TSpellLocation(FLocation).X,
    TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer, 1,
    ChangeTerrain, TerrainChanged);
  TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
    CastingDone(TAbstractUnit(A1), FEventMana);
  { needs: TSpellTE.Process returns a result in EAX (zero for this event). }
  Result := False;
end;

{ needs: TArmyHS.VisibleForSeatedPlayer: Boolean; $5579EC2B tests AL. }
constructor TFreezeWater.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(FreezeWaterRStr);
  FSpellID := 10;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msWater;
end;

function TFreezeWater.ValidTargetMapF(A1: TMapField): Boolean;
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

function TFreezeWater.ValidTargetSelectionMapF(A1: TMapField): Boolean;
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

procedure TFreezeWater.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Target);
  TShortIntList(Target.FHNs).Clear;
  for I := 0 to RadToHN(2) - 1 do
    TShortIntList(Target.FHNs).Add(0);
end;

function TFreezeWater.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TFreezeWaterTE;
begin
  Event := TFreezeWaterTE.Create(nil);
  Event.Initialize(FSpellID, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.FTokenManager).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).AddEvent(Event);
  Event.Release;
  Result := True;
end;

{ needs: TFireControl.PlaceFire(X,Y,Layer:Integer; Create:Boolean): TFire,
  result consumed at $5579EDC3; GetSource returns TAbstractUnit at $5579EDE2. }
class function TFireBarrierTE.ClassID: Integer;
begin Result := $21304; end;

procedure TFireBarrierTE.CreateFireBarrier;
var
  Walk: THNWalkData;
  Level: TMapLevel;
  MapF: TAoWMapField;
  Fire: TFire;
begin
  RandSeed := SpellHSMap^.Random($FFFFFF);
  Level := SpellHSMap^.MapContainer.MapLevels[TSpellLocation(FLocation).Layer];
  InitHNWalk(Walk, TSpellLocation(FLocation).X, TSpellLocation(FLocation).Y, 0);
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      MapF := TAoWMapField(Level.Field[Walk.X, Walk.Y]);
      if TGlobalTargetSpellCalls(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(11)).
        ValidMapF(Integer(MapF)) and (MapF.GetArmyHS() = nil) then
      begin
        Fire := TFireControl(SpellHSSet^.FFireControl).PlaceFire(Walk.X,Walk.Y,TSpellLocation(FLocation).Layer,ftLarge);
        if Fire <> nil then
        begin
          Fire.SetupExplosion(Random(35));
          Fire.FTurnsLeft := 3;
          Fire.FPlayer := Self.GetSource().FPlayer;
        end;
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TFireBarrierTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin
  inherited Process(A1, A2);
  CreateFireBarrier;
  TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
    CastingDone(TAbstractUnit(A1), TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FBaseManaCost);
  Result := False;
end;

constructor TFireBarrier.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(FireBarrierRStr);
  FSpellID := 11;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msFire;
end;

function TFireBarrier.ValidTargetMapF(A1: TMapField): Boolean;
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

function TFireBarrier.ValidTargetSelectionMapF(A1: TMapField): Boolean;
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

procedure TFireBarrier.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Target);
  TShortIntList(Target.FHNs).Clear;
  for I := 0 to RadToHN(2) - 1 do
    TShortIntList(Target.FHNs).Add(0);
end;

function TFireBarrier.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TFireBarrierTE;
begin
  Event := TFireBarrierTE.Create(nil);
  Event.Initialize(FSpellID, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.FTokenManager).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).AddEvent(Event);
  Event.Release;
  Result := True;
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
      if TGlobalTargetSpellCalls(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(18)).
        ValidMapF(Integer(MapF)) and (MapF.GetArmyHS() = nil) then
      begin
        SpellHSMap^.ClearTerrain(Walk.X, Walk.Y, TSpellLocation(FLocation).Layer, 0, -1);
        if Smallint(MapF.TerrainType) = Ord(ttEarth) then
          SpellHSMap^.ChangeTerrain(nil, Walk.X, Walk.Y, TSpellLocation(FLocation).Layer, 0, Ord(ttDirt));
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TLevelTerrainTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin
  inherited Process(A1, A2);
  PlayDefaultEffects(TSpellLocation(FLocation).X, TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer);
  LevelTerrain;
  TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
    CastingDone(TAbstractUnit(A1), TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FBaseManaCost);
  Result := False;
end;

constructor TLevelTerrain.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(LevelTerrainRStr);
  FSpellID := 18;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msEarth;
end;

function TLevelTerrain.ValidTargetMapF(A1: TMapField): Boolean;
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

function TLevelTerrain.ValidTargetSelectionMapF(A1: TMapField): Boolean;
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

procedure TLevelTerrain.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Target);
  TShortIntList(Target.FHNs).Clear;
  for I := 0 to RadToHN(2) - 1 do
    TShortIntList(Target.FHNs).Add(0);
end;

function TLevelTerrain.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TLevelTerrainTE;
begin
  Event := TLevelTerrainTE.Create(nil);
  Event.Initialize(FSpellID, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.FTokenManager).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).AddEvent(Event);
  Event.Release;
  Result := True;
end;

class function TRejuvenateTE.ClassID: Integer;
begin Result := $21310; end;

procedure TRejuvenateTE.RejuvenateTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
begin
  if TerrainType in [Ord(ttDesert)..Ord(ttWasteland)] then TerrainType := Ord(ttGrass);
end;

function TRejuvenateTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  Twinkle: TTwinkleAnimation;
begin
  inherited Process(A1, A2);
  SpellHSMap^.ValidateTerrainObservation(A1.FPlayer,
      Byte(TSpellLocation(FLocation).X), Byte(TSpellLocation(FLocation).Y),
      Byte(TSpellLocation(FLocation).Layer), 2);
  if SpellHSMap^.TerrainVisible( Byte(TSpellLocation(FLocation).X),
    Byte(TSpellLocation(FLocation).Y), Byte(TSpellLocation(FLocation).Layer), 2) then
  begin
    Twinkle := TTwinkleAnimation.Create(nil);
    Twinkle.Setup(TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(41).FCastImages).ImageSequences[0],[tmRotate],100,64,50,30);
    SpellHSMap^.PlaceHX(Twinkle, TSpellLocation(FLocation).X,
      TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer);
  end;
  { needs: TAbstractAoWHSMap.$A4 contains the seated player at byte $A5. }
  if (TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer = A1.FPlayer) or
    SpellHSMap^.WatchingTerrain( Byte(TSpellLocation(FLocation).X),
      Byte(TSpellLocation(FLocation).Y), Byte(TSpellLocation(FLocation).Layer), 2) then
    TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(41).FCastSounds).Play(0);
  SpellHSMap^.ChangeTerrainEx(nil, TSpellLocation(FLocation).X,
    TSpellLocation(FLocation).Y, TSpellLocation(FLocation).Layer, 2,
    RejuvenateTerrain, nil);
  TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
    CastingDone(TAbstractUnit(A1), TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FBaseManaCost);
  { needs: TSpellTE.Process returns a result in EAX (zero for this event). }
  Result := False;
end;

constructor TRejuvenate.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(RejuvenateRStr);
  FSpellID := 41;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msLife;
  FAboveGroundOnly := True;
end;

function TRejuvenate.ValidTargetMapF(A1: TMapField): Boolean;
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

function TRejuvenate.ValidTargetSelectionMapF(A1: TMapField): Boolean;
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

procedure TRejuvenate.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Target);
  TShortIntList(Target.FHNs).Clear;
  for I := 0 to RadToHN(3) - 1 do
    TShortIntList(Target.FHNs).Add(0);
end;

function TRejuvenate.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TRejuvenateTE;
begin
  Event := TRejuvenateTE.Create(nil);
  Event.Initialize(FSpellID, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.FTokenManager).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).AddEvent(Event);
  Event.Release;
  Result := True;
end;

constructor TWatcherEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TGlobalEnchantmentMode(FEnchantmentMode) :=
    TGlobalEnchantmentMode(FEnchantmentMode) - [gemTrueGlobal, gemOwned];
  FDispelMana := 50;
end;

function TWatcherEnchantment.GetName: string;
begin
  Result := TSpellNameView(Pointer(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(57))^).Name;
end;

function TWatcherEnchantment.GetLocation: TXYL;
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

function TWatcherEnchantment.Deactivate(Player: Byte): Boolean;
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
function SpellRelation(Relations: TPlayerDiplomaticRelations; Player: Byte): Byte; assembler;
asm JMP TPlayerDiplomaticRelations.GetDiplomaticRelation end;

function SpellEnchantmentVisible(Enchantment: TGlobalEnchantment; Player: Byte): Boolean; assembler;
asm
  PUSH EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX+$84]
  POP EBX
end;

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
  TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(57).FCastSounds).Play(0);
  FUnexplored.Clear;
  if SpellHSMap^.FExplorationEnabled then
  begin
    InitHNWalk(Walk, X,Y,0);
    Level := SpellHSMap^.MapContainer.MapLevels[Layer];
    while Walk.Radius <= VisibilityRange do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        if not TAoWMapField(Level.Field[Walk.X,Walk.Y]).GetExplored(SpellHSMap^.FSeatedPlayer) then FUnexplored.Add(Walk.HN);
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
  if (SpellHSMap^.ViewL = Lhx) and SpellHSMap^.Visible( Xhx,Yhx,Lhx,0) then
  begin
    HXtoHP(Xhx,Yhx,X,Y);
    X := X-XhpSurf+16;
    Y := Y-YhpSurf+16;
    if TSpellControl(SpellHSSet^.FSpellControl).GetSpell(57).FCastImages <> nil then
      TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(57).FCastImages).
        ShowLooped(1,X,Y,SpellHSMap^.Frame,SurfaceDesc);
    if FAnimationFrame <> -1 then
    begin
      Inc(FAnimationFrame);
      { Original reads the shared AoWEngine animation detail at byte $6D.
        The map engine is not the global read by this routine. }
      if (SpellEngine^.FAnimationDetail = 2) and (SpellHSMap^.ViewL = Lhx) then
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
      RandSeed := SpellHSMap^.FInitialRandomSeed;
      for I := 0 to 300 do
      begin
        Radius := Random(VisibilityRange shl 5);
        Angle := Random(360);
        Delay := Random(80);
        if FAnimationFrame-Delay >= 0 then
        begin
          DegreesRadToCo(Angle,Radius,DX,DY);
          TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(57).FCastImages).
            Show(0,X+DX,Y+DY,FAnimationFrame-Delay,SurfaceDesc);
        end;
      end;
      if FAnimationFrame = 100 then StopAnimation;
    end;
  end;
end;

procedure TWatcherHS.UpdateExploration; { Near miss: loop bound and owner registers differ after three variants. }
var
  I, OwnerPlayer: Integer;
begin
  if Activated then
  begin
    for I := 1 to TPlayerList(SpellHSMap^.FPlayers).Count-1 do
    begin
      OwnerPlayer := Shortint(FEnchantment.FPlayerIndex);
      if (OwnerPlayer = I) or (SpellRelation(TPlayerDiplomaticRelations(
        TPlayerList(SpellHSMap^.FPlayers).GetPlayers(OwnerPlayer).FDiplomaticRelations), I) = 2) then
        SpellHSMap^.ExploreArea(Xhx,Yhx,Lhx,I,VisibilityRange);
    end;
  end;
end;

procedure TWatcherHS.UpdateUnfog; { Near miss: map pointer reuse and zero-radius branches differ after three variants. }
var
  Radius: Integer;
  OwnerPlayer: Shortint;
begin
  if Byte(SpellHSMap^.FSeatedPlayer) <> $FF then
  begin
    OwnerPlayer := Shortint(FEnchantment.FPlayerIndex);
    if     ((OwnerPlayer = SpellHSMap^.FSeatedPlayer) or
    (SpellRelation(TPlayerDiplomaticRelations(TPlayerList(SpellHSMap^.FPlayers).GetPlayers(OwnerPlayer).FDiplomaticRelations),
      Byte(SpellHSMap^.FSeatedPlayer)) = 2)) and Activated then
      Radius := VisibilityRange
    else Radius := 0;
  end
  else Radius := 0;
  if Radius <> FUnfogRadius then
  begin
    if FUnfogRadius <> 0 then SpellHSMap^.FogArea(Xhx,Yhx,Lhx,FUnfogRadius);
    FUnfogRadius := Radius;
    if FUnfogRadius <> 0 then SpellHSMap^.UnFogArea(Xhx,Yhx,Lhx,FUnfogRadius);
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
  FEnchantment.Activate(FEnchantment.FPlayerIndex);
  with TMapField(Owner) do
  SpellHSMap^.NotifyPlayerChanged(Xhx,Yhx,Lhx);
  MapF := TMapField(Owner);
  SpellHSMap^.UpdatePlayerSeen(Shortint(FEnchantment.FPlayerIndex),
    MapF.Xhx,MapF.Yhx,MapF.Lhx,VisibilityRange,VisibilityRange);
  UpdateExploration;
  UpdateUnfog;
end;

procedure TWatcherHS.Deactivate;
begin
  inherited Deactivate;
  TWatcherState(FWatcherState) := TWatcherState(FWatcherState) - [wsActive];
  if getActivated in FEnchantment.FEnchantmentStatus then
    FEnchantment.Deactivate(FEnchantment.FPlayerIndex);
  SpellHSMap^.NotifyPlayerChanged(TMapField(Owner).Xhx,TMapField(Owner).Yhx,TMapField(Owner).Lhx);
  UpdateUnfog;
end;

function TWatcherHS.VisibilityRange: Integer;
begin
  Result := 8;
  if (Lhx <> 0) or ((FEnchantment.FPlayerIndex > 0) and
    (petWaterMastery in SpellHSMap^.FPlayers.GetPlayers(FEnchantment.FPlayerIndex).
      FMagicControl.FEnemyEnchantments)) then
  begin
    Inc(Result);
    Result := Result shr 1;
  end;
end;

function TWatcherHS.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  TMapField(Owner).UpdateMapField;
end;

procedure TWatcherHS.RemoveFromMap; { Near miss: three variants retain ESI instead of EBX for the owner. }
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
  Visible := FEnchantment.VisibleForPlayer(SpellHSMap^.FSeatedPlayer);
  if FVisibleForSeatedPlayer xor Visible then
  begin
    FVisibleForSeatedPlayer := Visible;
    SpellHSMap^.FGlobalMagicControl.TriggerChangedEvent;
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

procedure TWatcherHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); { Near miss: Self/message registers and argument evaluation differ after three variants. }
var
  OwnerPlayer, Range: Integer;
begin
  with Msg do
  begin
  inherited MapFieldMsgProc(Msg);
  if MsgID = $110B then
    if Activated then
    begin
      OwnerPlayer := Shortint(FEnchantment.FPlayerIndex);
      if (OwnerPlayer = Param[1]) or (SpellRelation(TPlayerDiplomaticRelations(
        TPlayerList(SpellHSMap^.FPlayers).GetPlayers(OwnerPlayer).FDiplomaticRelations),
        Param[1]) = 2) then
        if Param[0] <= VisibilityRange then Result := 1;
    end;
  if MsgID = $110A then
    if Activated then
    begin
      OwnerPlayer := Shortint(FEnchantment.FPlayerIndex);
      if (OwnerPlayer = Param[1]) or (SpellRelation(TPlayerDiplomaticRelations(
        TPlayerList(SpellHSMap^.FPlayers).GetPlayers(OwnerPlayer).FDiplomaticRelations),
        Param[1]) = 2) then
        if Param[0] <= VisibilityRange then Result := 1;
    end;
  if MsgID = $110D then
  begin
    if VisibilityRange >= Param[0] then
    begin
      Range := Param[0];
      SpellHSMap^.UpdatePlayerSeen(Shortint(FEnchantment.FPlayerIndex),
        TMapField(Owner).Xhx,TMapField(Owner).Yhx,TMapField(Owner).Lhx,Range,Range);
    end;
    UpdateVisibleForSeatedPlayer;
  end;
  end;
end;

class function TWatcherTE.ClassID: Integer;
begin Result := $2131B; end;

function TWatcherTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  Watcher: TWatcherHS;
begin
  inherited Process(A1,A2);
  PlayDefaultEffects(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer);
  Watcher := TWatcherHS.Create(nil);
  Watcher.FEnchantment.FPlayerIndex := A1.FPlayer;
  Watcher.FEnchantment.FEnchantmentManaUpkeep :=
    TSpellControl(SpellHSSet^.FSpellControl).GetSpell(57).FManaUpkeep;
  SpellHSMap^.PlaceHX(Watcher,TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer);
  if Byte(SpellHSMap^.FSeatedPlayer) = FEventPlayerIndex then
    Watcher.StartAnimation(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer);
  TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
    CastingDone(A1,TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FBaseManaCost);
  Result := False;
end;

{ needs: TPlayer.GetBusy: Boolean, tested at $557A0266. }
constructor TWatcher.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(WatcherRStr);
  FSpellID := 57;
  FAboveGroundOnly := False;
end;

function TWatcher.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TWatcherTE;
begin
  if not SpellHSMap^.FPlayers.GetPlayers(A1.FPlayer).GetBusy then
  begin
    Event := TWatcherTE.Create(nil);
    Event.Initialize(FSpellID,A1.FPlayer,
      A1.FUnitID,FBaseManaCost);
    Event.SetLocation(A2,A3,A4);
    TTokenManager(SpellHSMap^.FTokenManager).
      GetTokenControl(Shortint(A1.FPlayer)).AddEvent(Event); { Original queues through AddEvent, VMT +$10. }
    Event.Release; Result := True;
  end
  else Result := False;
end;

procedure TWatcher.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
begin
  inherited SetupTargetSelection(A1,A2);
  TTargetSelectionMode(A2.FTargetMode) :=
    TTargetSelectionMode(A2.FTargetMode) - [tmFixedLevel,tmValidateDistance];
  TShortIntList(A2.FHNs).Clear;
end;

{ needs: the shared army and spell-event drafts do not declare results or
  var parameters. These typed entry shims preserve their original register ABI. }
type
  TSpellMoveTable = packed record
    Flags: Byte;
    Cost: array[0..15,0..15] of Shortint;
  end;
  TSpellAnimationFields = packed record
    Reserved: array[0..$23] of Byte;
    OnShow: TShowAnimationEvent;
  end;
  TSpellEngineFields = packed record
    Reserved: array[0..$6C] of Byte;
    Detail: Byte;
  end;

constructor TTornadoTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FArmyID := nil;
end;

destructor TTornadoTE.Destroy;
begin
  FArmyID.Free;
  inherited Destroy;
end;

class function TTornadoTE.ClassID: Integer;
begin Result := $21324; end;

function TTornadoTE.Validate(A1: THero): Boolean;
asm
  { needs: Boolean result on the shared TSpellTE.Validate virtual. }
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EDI, EDX
  MOV EBX, EAX
  MOV EDX, EDI
  MOV EAX, EBX
  CALL TSpellTE.Validate
  TEST AL, AL
  JZ @@Invalid
  MOV ESI, [EBX+$2C]
  TEST ESI, ESI
  JZ @@Valid
  MOV EAX, ESI
  CALL TArmyID.Valid
  TEST AL, AL
  JNZ @@Valid
@@Invalid:
  XOR EAX, EAX
  JMP @@Done
@@Valid:
  MOV AL, 1
@@Done:
  POP EDI
  POP ESI
  POP EBX
end;

procedure TTornadoTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwCreateEObject(TEObject(FArmyID), nil, $28);
end;

procedure TTornadoTE.ShowAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer;
  const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp, XShift, Height, X, Y: Integer;
  Angle: Single;
  I, Direction, Radius, Count, Last: Integer;
begin
  if SpellHSMap^.ViewL = TSpellLocation(FLocation).Layer then
  begin
    HXtoHP(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,Xhp,Yhp);
    Dec(Xhp,XhpSurf);
    Dec(Yhp,YhpSurf);
    FAngle := FAngle + 20 + FAnimation.FFrameCounter div 5;
    RandSeed := SpellHSMap^.FInitialRandomSeed;
    for I := 0 to 200 do
    begin
      Direction := Random(360);
      if (Animation.FFrameCounter >= I shr 2) and
         (Animation.FFrameCounter <= (I shr 4) + 68) then
      begin
        Radius := Round((2.997 - Ln(I * 19 * 0.005 + 1)) * 35) + 7;
        Height := 200 - I - 16;
        XShift := Round(Sin(FAnimation.FFrameCounter * 0.1 + I * 0.02) *
          (200-I) * 0.25) + 16;
        Angle := (Direction + FAngle) * Pi / 180;
        if Ord(SpellEngine^.FAnimationDetail) = 0 then
          Last := 1
        else if SpellEngine^.FAnimationDetail = 1 then
          Last := (200-I) shr 5
        else Last := (200-I) shr 4;
        for Count := Last downto 0 do
        begin
          X := Round(Cos(Angle)*Radius) + XShift;
          Y := Round(Sin(Angle)*Radius*0.5) + Height;
          TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(68).
            FCastImages).Show(0,Xhp+X,Yhp-Y,0,SurfaceDesc);
          Angle := 0.035 + Angle;
        end;
      end;
    end;
  end;
end;

resourcestring SpellXCastRStr = '%s cast';

function SpellUnitLevel(UnitObj: TAbstractUnit): Byte; assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$A0]; POP EBX end;

function SpellIndependentRelation(Units: TUnitList; Default: Byte): Byte; assembler;
asm JMP AoWE.UnitsToIndependentRelation end;

function SpellCreateGroup(Manager: TAIGroupManager; Player, Relation: Byte;
  Behavior: Integer): TAIGroup; assembler;
asm POP EBP; JMP TAIGroupManager.CreateGroup end;

type
  TSpellAIGroupFields = packed record
    Reserved: array[0..$4F] of Byte;
    Enemies: TIntegerList;
  end;

function TTornadoTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  MovedUnits: TUnitUserList;
  Owner: Byte;
  Selection: Byte;
  Location: TXYL;
  Chance: Integer;
  Exposed: Boolean;
  Army: TArmyHS;
  UnitObj: TAbstractUnit;
  MapF: TAoWMapField;
  I: Integer;
  Log: TArmyEventLog;
  Anim: TImageSequenceAnimation;
  Placed: TArmyHS;
  Group: TAIGroup;
begin
  if A2 = 0 then
  begin
    FAngle := 0;
    TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
      CastingDone(A1,TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FBaseManaCost);
    SpellHSMap^.ValidateObservation(A1.FPlayer,TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2);
    if (A1.FPlayer = SpellObservedMap^.FSeatedPlayer) or
      SpellHSMap^.Watching(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2) then
      TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FCastSounds).Play(0);
    Anim := TImageSequenceAnimation(TAnimation.Create(nil)); FAnimation := Anim;
    Anim.FAnimationLevel := $1B; Anim.FOnShow := ShowAnimation; Anim.FAnimationMap := SpellHSMap^;
    Anim.FTag := (SpellHSMap^.ViewWidth and $FFFF) or (SpellObservedMap^.ViewHeight shl 16); Anim.Activate;
  end;
  if A2 = 80 then begin
  MapF := TAoWMapField(SpellHSMap^.MapContainer.GetField(
    TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,
    TSpellLocation(FLocation).Layer));
  if (FArmyID <> nil) and not MapF.GetMagicShieldActive() then
  begin
    FArmyID.RetrieveArmy(Army,Selection);
    Exposed := not ((MapF.OverlayType in [1]) or (MapF.FindNoneTransparentHS(TStructure) <> nil));
    for I := 0 to TArmy(Army.FArmy).Count - 1 do
      if (Selection and (1 shl I)) <> 0 then
      begin
        UnitObj := TArmy(Army.FArmy).GetUnit(I);
        case UnitObj.GetUnitLevel of
          1: Chance := 90;
          2: Chance := 70;
          3: Chance := 50;
          4: Chance := 30;
        else Chance := 30;
        end;
        if not Exposed then Chance := Chance div 2;
        if Chance < SpellHSMap^.Random(100) then
          Selection := Selection and not (1 shl I);
      end;
    if TArmy(Army.FArmy).Transporter($FF) <> nil then
      if TArmy(Army.FArmy).Transporter(Selection) <> nil then Selection := $FF
      else Selection := 0;
    if Selection <> 0 then
    begin
      Log := TArmyEventLog.Create(nil);
      Log.FPlayer := A1.FPlayer;
      Log.FArmyText :=
        SysUtils.Format(AoWE.TranslateRStr(AoWE.XCastRStr),[AoWE.TranslateRStr(TornadoRStr)]);
      Log.FArmyMessages.Add(AoWE.TranslateRStr(TornadoRStr));
      Log.FArmyIcon := 2;
      Log.FArmyView.Setup(TArmy(Army.FArmy),Selection);
      DistributeLocationEventLog(Log,FEventPlayerIndex,Army.Xhx,Army.Yhx,Army.Lhx, True);
      Log.Release;
      Location.XYL := TTornado(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(68)).
        CalculateWarpLocation(Army,Selection);
      if Location.XYL <> $FFFFFF then
      begin
        if (A1.FPlayer = SpellObservedMap^.FSeatedPlayer) or
          SpellHSMap^.Watching(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2) then
          TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FCastSounds).Play(1);
        if (SpellObservedMap^.FSeatedPlayer = A1.FPlayer) or
          SpellHSMap^.VisibleForPlayer(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,SpellPlayerMap^.FSeatedPlayer) then
          if TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FCastImages).ImageSequences[1] <> nil then
          begin
            Anim := TImageSequenceAnimation.Create(nil);
            Anim.SetImageSequence(TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
              FCastImages).ImageSequences[1]);
            SpellHSMap^.PlaceHX(Anim,TSpellLocation(FLocation).X,
              TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer);
          end;
        if (SpellObservedMap^.FSeatedPlayer = A1.FPlayer) or
          SpellHSMap^.VisibleForPlayer(Location.X,Location.Y,Location.L,SpellPlayerMap^.FSeatedPlayer) then
          if TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FCastImages).ImageSequences[1] <> nil then
          begin
            Anim := TImageSequenceAnimation.Create(nil);
            Anim.SetImageSequence(TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
              FCastImages).ImageSequences[1]);
            SpellHSMap^.PlaceHX(Anim,Location.X,
              Location.Y,Location.L);
          end;
        MovedUnits := TUnitUserList.Create(nil);
        Owner := TArmy(Army.FArmy).FPlayer;
        MapF := TAoWMapField(SpellHSMap^.MapContainer.GetFieldXYL(Location.XYL));
        if TArmy(Army.FArmy).ValidateSelection($FF) <> Selection then begin
          for I := TArmy(Army.FArmy).Count - 1 downto 0 do
            if (Selection and (1 shl I)) <> 0 then
            begin
              UnitObj := TArmy(Army.FArmy).GetUnit(I);
              MovedUnits.AddUnit(UnitObj);
              Placed := UnitObj.Place(Location.X,Location.Y,Location.L,Byte(TArmy(Army.FArmy).FPlayer),[]);
              if Placed <> nil then TArmy(Placed.FArmy).UpdateExploration;
            end end
        else
        begin
          MovedUnits.AddUnits(Army.FArmy);
          Army.MoveTo(MapF, 0);
        end;
        if Owner = 0 then
        begin
          Group := TAIGroupManager(SpellHSMap^.FAIGroupManager).CreateGroup(0,
            UnitsToIndependentRelation(MovedUnits,5),gbHunt);
          Group.AddUnits(MovedUnits);
          THuntAG(Group).FTargetUnitIDs.Add(A1.FUnitID);
          Group.Release;
        end;
        MovedUnits.Free;
      end;
    end;
  end;
  FAnimation.Free;
  Result := False; end else Result := True;
end;












constructor TTornado.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(TornadoRStr);
  FSpellID := 68;
  FAboveGroundOnly := True;
end;

function TTornado.ValidWarpLocation(Army: TArmyHS; X, Y, Layer: Shortint): Boolean;
var
  MapF: TAoWMapField;
  Msg: TMapFieldMsg;
begin
  MapF := TAoWMapField(SpellHSMap^.MapContainer.GetField(X,Y,Layer));
  Result := (MapF.GetArmyHS() = nil) and (MapF.GetPlayer() = -1);
  if Result then
  begin
    Msg.MsgID := $1120;
    Msg.Param[0] := Integer(Army);
    Msg.Result := 0;
    MapF.SendMapFieldMsg(Msg);
    Result := (Msg.Result = 0) and TArmy(Army.FArmy).CanPlace(X,Y,Layer);
  end;
end;

function TTornado.CalculateWarpLocation(Army: TArmyHS; Selection: Byte): Integer; { Near miss: register or temporary allocation differs after three variants. }
var
  Table: TSpellMoveTable;
  Walk: THNWalkData;
  MapLevel: TMapLevel;
  MapF: TMapField;
  Locations: TList;
  Found: Boolean;
  Index, X: Integer;
begin
  Locations := TList.Create;
  TArmy(Army.FArmy).CreateMovePointTable(Selection,Table);
  InitHNWalk(Walk,Army.Xhx,Army.Yhx,10);
  MapLevel := SpellHSMap^.MapContainer.MapLevels[Army.Lhx];
  while Walk.Radius < 15 do
  begin
    X := Walk.X;
    if (X >= 0) and (Walk.Y >= 0) and
       (X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
    begin
      MapF := MapLevel.GetField(X,Walk.Y);
      if Table.Cost[MapF.TerrainType,MapF.OverlayType] <> -1 then
        Locations.Add(MapF);
    end;
    WalkToNextHN(Walk);
  end;
  Found := False;
  Result := $FFFFFF;
  while (Locations.Count <> 0) and not Found do
  begin
    Index := Random(Locations.Count);
    MapF := Locations[Index];
    if ValidWarpLocation(Army,MapF.Xhx,MapF.Yhx,MapF.Lhx) then
    begin
      Found := True;
      Result := MapF.XYL;
    end
    else Locations.Delete(Index);
  end;
  Locations.Free;
end;

function TTornado.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TTornadoTE;
  Army: TArmyHS;
begin
  if not SpellHSMap^.FPlayers.GetPlayers(A1.FPlayer).GetBusy then
  begin
    Event := TTornadoTE.Create(nil);
    Event.Initialize(FSpellID,A1.FPlayer,
      A1.FUnitID,FBaseManaCost);
    Event.SetLocation(A2,A3,A4);
    Army := TAoWMapField(SpellHSMap^.MapContainer.GetField(A2,A3,A4)).GetArmyHS();
    if Army <> nil then Event.FArmyID := TArmy(Army.FArmy).CreateID($FF);
    TTokenManager(SpellHSMap^.FTokenManager).
      GetTokenControl(Shortint(A1.FPlayer)).AddEvent(Event); { Original queues through AddEvent, VMT +$10. }
    Event.Release; Result := True;
  end
  else Result := False;
end;

procedure TTornado.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var Target: TTargetSelectionControl;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1,Target);
  TShortIntList(Target.FHNs).Clear;
end;

constructor TVortexTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FArmyID := nil;
end;

destructor TVortexTE.Destroy;
begin
  FArmyID.Free;
  inherited Destroy;
end;

class function TVortexTE.ClassID: Integer;
begin Result := $21325; end;

function TVortexTE.Validate(A1: THero): Boolean;
asm
  { needs: Boolean result on the shared TSpellTE.Validate virtual. }
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EDI, EDX
  MOV EBX, EAX
  MOV EDX, EDI
  MOV EAX, EBX
  CALL TSpellTE.Validate
  TEST AL, AL
  JZ @@Invalid
  MOV ESI, [EBX+$2C]
  TEST ESI, ESI
  JZ @@Valid
  MOV EAX, ESI
  CALL TArmyID.Valid
  TEST AL, AL
  JNZ @@Valid
@@Invalid:
  XOR EAX, EAX
  JMP @@Done
@@Valid:
  MOV AL, 1
@@Done:
  POP EDI
  POP ESI
  POP EBX
end;

procedure TVortexTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwCreateEObject(TEObject(FArmyID), nil, $28);
end;

procedure TVortexTE.ShowAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer;
  const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp, XShift, Height, X, Y: Integer;
  Angle: Single;
  I, Direction, Radius, Count, J: Integer;
begin
  if SpellHSMap^.ViewL = TSpellLocation(FLocation).Layer then
  begin
    HXtoHP(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,Xhp,Yhp);
    Dec(Xhp,XhpSurf);
    Dec(Yhp,YhpSurf);
    FAngle := FAngle + 20 + FAnimation.FFrameCounter div 5;
    RandSeed := SpellHSMap^.FInitialRandomSeed;
    for I := 0 to 200 do
    begin
      Direction := Random(360);
      if (Animation.FFrameCounter >= (200-I) shr 2) and
         (Animation.FFrameCounter <= (I shr 4) + 68) then
      begin
        Radius := Round((2.997 - Ln(I * 19 * 0.005 + 1)) * 35) + 18;
        Height := -16;
        XShift := 16;
        Angle := -(Direction + FAngle) * Pi / 180;
        if TMapSeatedPlayerView(Pointer(SpellEngine^)^).Reserved[$6D] = 0 then Count := 1
        else if TMapSeatedPlayerView(Pointer(SpellEngine^)^).Reserved[$6D] = 1 then Count := (200-I) shr 5
        else Count := (200-I) shr 4;
        for J := Count downto 0 do
        begin
          X := Round(Cos(Angle)*Radius) + XShift;
          Y := Round(Sin(Angle)*Radius / 1.75) + Height;
          TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(70).
            FCastImages).Show(0,Xhp+X,Yhp-Y,0,SurfaceDesc);
          Angle := 0.035 + Angle;
        end;
      end;
    end;
  end;
end;

function SpellMoveTypes(UnitObj: TAbstractUnit): Byte; assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$E8]; POP EBX end;

procedure SpellValidateTerrainObservation(Army: TArmy; Terrain,Overlay,Player: Byte); assembler;
asm POP EBP; JMP TArmy.ValidateTerrainEx end;

function TVortexTE.Process(A1: TAbstractUnit; A2: Integer): Boolean; { Near miss: Register and local allocation differ after three variants. }
var
  Anim: TAnimation; Log: TArmyEventLog;
  Selection: Byte;
  Damaged: Boolean;
  Damage: Integer;
  I: Integer;
  Army: TArmyHS;
  UnitObj: TAbstractUnit;
begin
  if A2 = 0 then
  begin
    FAngle := 0;
    TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
      CastingDone(A1,TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FBaseManaCost);
    SpellHSMap^.ValidateObservation(A1.FPlayer,TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2);
    if (A1.FPlayer = SpellObservedMap^.FSeatedPlayer) or
      SpellHSMap^.Watching(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2) then
      TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).FCastSounds).Play(0);
    Anim := TAnimation.Create(nil); FAnimation := Anim;
    Anim.FAnimationLevel := $1B; Anim.FOnShow := ShowAnimation; Anim.FAnimationMap := SpellHSMap^;
    Anim.FTag := (SpellHSMap^.ViewWidth and $FFFF) or (SpellObservedMap^.ViewHeight shl 16); Anim.Activate;
  end;
  if A2 = 80 then begin
  if (FArmyID <> nil) and FArmyID.RetrieveArmy(Army,Selection) then
  begin
    Log := TArmyEventLog.Create(nil);
    Log.FArmyText := AoWE.TranslateRStr(VortexDamageRStr);
    Log.FPlayer := A1.FPlayer;
    Log.FArmyMessages.Add(AoWE.TranslateRStr(VortexRStr));
    Log.FArmyIcon := 2;
    Log.FArmyView.Setup(TArmy(Army.FArmy),$FF);
    TArmy(Army.FArmy).BeginUpdate;
    Damaged := False;
    for I := 0 to TArmy(Army.FArmy).Count - 1 do
    begin
      UnitObj := TArmy(Army.FArmy).GetUnit(I);
      if not (mtFlying in UnitObj.GetMoveTypes) then
      begin
        if UnitObj.GetAbilityEnabled(2) then Damage := 7
        else if UnitObj.GetAbilityEnabled(23) then Damage := 10
        else Damage := 0;
        Damage := UnitObj.ExecuteDamageRole(8,Damage,[dtPhysical]);
        if Damage > UnitObj.GetHitPoints then Damage := UnitObj.GetHitPoints;
        if Damage > 0 then
        begin
          UnitObj.SetHitPoints(UnitObj.GetHitPoints-Damage);
          Damaged := True;
        end;
      end
      else Damage := 0;
      Log.FDamageValues.Add(Damage);
      Log.FDamageTypes.Add(7);
    end;
    if Damaged then
    begin
      Log.ValidateGameOver;
      DistributeLocationEventLog(Log,TArmy(Army.FArmy).FPlayer,
        Army.Xhx,Army.Yhx,Army.Lhx, True);
    end;
    Log.Release;
    TArmy(Army.FArmy).Validate;
    TArmy(Army.FArmy).ValidateTerrainEx(TMapField(Army.Owner).TerrainType,
      TMapField(Army.Owner).OverlayType,A1.FPlayer);
    TArmy(Army.FArmy).EndUpdate;
  end;
  FAnimation.Free;
  Result := False; end else Result := True;
end;









constructor TVortex.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(VortexRStr);
  FSpellID  := 70;
  FAboveGroundOnly := False;
end;

function TVortex.ValidTargetSelection(A1: TTargetSelectionControl): Boolean; { Near miss: register or temporary allocation differs after three variants. }
var MapF: TMapField;
begin
  if A1.FTargetX <> -1 then
  begin
    MapF := SpellHSMap^.MapContainer.MapLevels[A1.FTargetL].GetField(A1.FTargetX, A1.FTargetY);
    Result := MapF.TerrainType in [0, 10];
  end
  else Result := False;
end;

procedure TVortex.ValidateTargetEvent(Target: TTargetSelectionControl;
  X,Y,Layer: Shortint; var Valid: Boolean);
var MapLevel: TMapLevel;
begin
  if X <> -1 then
  begin
    MapLevel := SpellHSMap^.MapContainer.MapLevels[Layer];
    Valid := MapLevel.GetField(X,Y).TerrainType in [0,10];
  end
  else Valid := False;
end;

function TVortex.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TVortexTE;
  Army: TArmyHS;
begin
  if not SpellHSMap^.FPlayers.GetPlayers(A1.FPlayer).GetBusy then
  begin
    Event := TVortexTE.Create(nil);
    Event.Initialize(FSpellID,A1.FPlayer,
      A1.FUnitID,FBaseManaCost);
    Event.SetLocation(A2,A3,A4);
    Army := TAoWMapField(SpellHSMap^.MapContainer.GetField(A2,A3,A4)).GetArmyHS();
    if Army <> nil then Event.FArmyID := TArmy(Army.FArmy).CreateID($FF);
    TTokenManager(SpellHSMap^.FTokenManager).
      GetTokenControl(Shortint(A1.FPlayer)).AddEvent(Event); { Original queues through AddEvent, VMT +$10. }
    Event.Release; Result := True;
  end
  else Result := False;
end;

procedure TVortex.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var Target: TTargetSelectionControl;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1,Target);
  TShortIntList(Target.FHNs).Clear;
  TTargetSelectionView(Target).OnValidate := ValidateTargetEvent;
end;

type
  TSpellRegistryFields = packed record
    Reserved: array[0..$5B] of Byte;
    Registry: TAoWRegistry;
  end;

function SpellHitPointsMax(UnitObj: TAbstractUnit): Shortint; assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$D0]; POP EBX end;

class function THealingShowersTE.ClassID: Integer;
begin Result := $21327; end;

procedure THealingShowersTE.ShowAnimation(Animation: TAnimation;
  XhpSurf,YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  X,Y,XShift,YShift,Speed,Xhp,Yhp,Count: Integer;
  I,J,Frame: Integer;
begin
  if SpellHSMap^.ViewL = TSpellLocation(FLocation).Layer then
  begin
    HXtoHP(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,Xhp,Yhp);
    Dec(Xhp,XhpSurf);
    Dec(Yhp,YhpSurf);
    case TAoWRegistry(SpellEngine^.FRegistry).GetDetailLevel of
      dtlLow: Count := 50;
      dtlHigh: Count := 160;
    else Count := 100;
    end;
    RandSeed := SpellHSMap^.FInitialRandomSeed;
    for I := 0 to Count do
    begin
      X := Random(100)-50;
      Y := Random(100)-50;
      Speed := Random(5)+5;
      Frame := Animation.FFrameCounter-Random(30);
      if (Frame >= 0) and (Frame < 50) then
      begin
        Frame := Frame mod 30;
        Dec(X,Round(Frame*4*(Speed*0.2)));
        Inc(Y,Round(Frame*20*(Speed*0.2)));
        if Y < 500 then
          for J := 0 to 10 do
          begin
            XShift := X-Round(J*2*0.1);
            YShift := Y+Round(J*10*0.1);
            TImageSequenceList(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(73).FCastImages).Show(0,Xhp+XShift+120,Yhp+YShift-500+30,0,SurfaceDesc);
          end;
      end;
    end;
  end;
end;

procedure THealingShowersTE.ChangeTerrain(MapF: TMapField; var TerrainType,OverlayType: Shortint);
begin
  case TerrainType of
    5: TerrainType := 4;
    2: TerrainType := 4;
    4: TerrainType := 1;
  end;
end;

function THealingShowersTE.Process(A1: TAbstractUnit; A2: Integer): Boolean; { Near miss: Register allocation differs after three variants. }
var
  UnitObj: TAbstractUnit;
  Walk: THNWalkData;
  Army: TArmyHS;
  Level: TMapLevel;
  Anim: TImageSequenceAnimation;
  Healed,PlaySound: Boolean;
  I: Integer;
  Cloud: THexagonSprite;
begin
  inherited Process(A1,A2);
  if A2 = 0 then
  begin
    SpellHSMap^.ValidateTerrainObservation(A1.FPlayer,
      TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2);
    if (A1.FPlayer = SpellObservedMap^.FSeatedPlayer) or
      SpellHSMap^.WatchingTerrain(TSpellLocation(FLocation).X,
        TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2) then
      TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(73).FCastSounds).Play(0);
    Anim := TImageSequenceAnimation(TAnimation.Create(nil)); FAnimation := Anim;
    Anim.FAnimationLevel := $1B; Anim.FOnShow := ShowAnimation; Anim.FAnimationMap := SpellHSMap^;
    Anim.FTag := (SpellHSMap^.ViewWidth and $FFFF) or (SpellObservedMap^.ViewHeight shl 16); Anim.Activate;
    TSpellControl(SpellHSSet^.FSpellControl).GetSpell(FEventSpellID).
      CastingDone(A1,FEventMana);
  end;
  if A2 = 50 then
  begin
    PlaySound := False;
    SpellHSMap^.ChangeTerrainEx(nil,TSpellLocation(FLocation).X,
      TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,1,ChangeTerrain,nil);
    Level := SpellHSMap^.MapContainer.MapLevels[TSpellLocation(FLocation).Layer];
    InitHNWalk(Walk,TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,0);
    while Walk.Radius <= 1 do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and
        (Walk.X < Level.Width) and (Level.Height > Walk.Y) then
        if not TAoWMapField(Level.GetField(Walk.X,Walk.Y)).GetMagicShieldActive() then
        begin
          Healed := False;
          Army := TAoWMapField(Level.GetField(Walk.X,Walk.Y)).GetArmyHS();
          if Army <> nil then
          begin
            for I := 0 to TArmy(Army.FArmy).Count-1 do
            begin
              UnitObj := TArmy(Army.FArmy).GetUnit(I);
              if UnitObj.GetHitPoints < UnitObj.GetHits then
              begin
                UnitObj.SetHitPoints(UnitObj.GetHitPoints+5);
                Healed := True;
              end;
              if UnitObj.GetAbilityEnabled(96) then
              begin
                UnitObj.RemoveAbility(96);
                Healed := True;
              end;
            end;
            TArmy(Army.FArmy).Update;
            if Healed and SpellHSMap^.VisibleForPlayer(Army.Xhx,Army.Yhx,Army.Lhx,SpellHSMap^.FSeatedPlayer) then
            begin
              PlaySound := PlaySound or
                (Byte(TArmy(Army.FArmy).FPlayer) =
                  Byte(SpellObservedMap^.FSeatedPlayer)) or
                SpellHSMap^.Watching(Army.Xhx,Army.Yhx,Army.Lhx,1);
              Anim := TImageSequenceAnimation.Create(nil);
              Anim.SetImageSequence(TImageSequenceList(TAbilityControl(SpellHSSet^.FAbilityControl).GetAbility(47).FImageSequences).ImageSequences[0]);
              Anim.FAnimationLevel := 27;
              SpellHSMap^.PlaceHX(Anim,Army.Xhx,Army.Yhx,Army.Lhx);
            end;
          end;
          Cloud := THexagonSprite(Level.GetField(Walk.X,Walk.Y).FindOwnedChild($2077E));
          if Cloud <> nil then Cloud.Free;
        end;
      WalkToNextHN(Walk);
    end;
    if PlaySound then
      TSFXLibrary(TAbilityControl(SpellHSSet^.FAbilityControl).GetAbility(47).
        FSFXLibrary).Play(0);
  end;
  if A2 = 80 then begin FAnimation.Free; Result := False; end
  else Result := True;
end;





constructor THealingShowers.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(HealingShowersRStr);
  FSpellID := 73;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msWater;
end;

function THealingShowers.ValidTargetMapF(A1: TMapField): Boolean;
begin Result := inherited ValidTargetMapF(A1); end;


function THealingShowers.ValidTargetSelectionMapF(A1: TMapField): Boolean;
begin Result := inherited ValidTargetSelectionMapF(A1); end;


procedure THealingShowers.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Target);
  TShortIntList(Target.FHNs).Clear;
  for I := 0 to RadToHN(2) - 1 do
    TShortIntList(Target.FHNs).Add(0);
end;


function THealingShowers.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: THealingShowersTE;
begin
  Event := THealingShowersTE.Create(nil);
  Event.Initialize(FSpellID, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.FTokenManager).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).AddEvent(Event);
  Event.Release;
  Result := True;
end;

{ needs: TFireControl.PlaceFire(X,Y,Layer:Integer; Create:Boolean): TFire,
  result consumed at $5579EDC3; GetSource returns TAbstractUnit at $5579EDE2. }

constructor TSmokeCloudSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := AoWE.TranslateRStr(SmokeCloudRStr);
  FSpellID := 74;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msFire;
end;

function TSmokeCloudSpell.ValidTargetMapF(A1: TMapField): Boolean;
begin Result := inherited ValidTargetMapF(A1); end;


function TSmokeCloudSpell.ValidTargetSelectionMapF(A1: TMapField): Boolean;
begin Result := inherited ValidTargetSelectionMapF(A1); end;


procedure TSmokeCloudSpell.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Target);
  TShortIntList(Target.FHNs).Clear;
  for I := 0 to RadToHN(4) - 1 do
    TShortIntList(Target.FHNs).Add(0);
end;


function TSmokeCloudSpell.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TGlobalTargetSpellTE;
begin
  Event := TGlobalTargetSpellTE.Create(nil);
  Event.Initialize(FSpellID, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.FTokenManager).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).AddEvent(Event);
  Event.Release;
  Result := True;
end;

{ needs: TFireControl.PlaceFire(X,Y,Layer:Integer; Create:Boolean): TFire,
  result consumed at $5579EDC3; GetSource returns TAbstractUnit at $5579EDE2. }

function TSmokeCloudSpell.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  Resource: TEResource;
  Cloud: TSmokeCloud;
begin
  SpellHSMap^.ValidateObservation(TGlobalTargetSpellTE(A1).GetSource().FPlayer,TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).X,TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).Y,TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).Layer,2);
  if (TGlobalTargetSpellTE(A1).GetSource().FPlayer =
    SpellObservedMap^.FSeatedPlayer) or
    SpellHSMap^.Watching(TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).X,TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).Y,TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).Layer,2) then
    TSFXLibrary(TSpellControl(SpellHSSet^.FSpellControl).GetSpell(TGlobalTargetSpellTE(A1).FEventSpellID).FCastSounds).Play(0);
  Resource := TEResource(TMapObjectResourceList(TObject(SpellHSSet^.MapObjectResourceList)).FindChild($21243));
  if Resource <> nil then
  begin
    Cloud := TSmokeCloud(Resource.CreateResourceUser);
    Cloud.FPlayer := A2.FPlayer;
    Cloud.FTurnsRemaining := -1;
    TGlobalEnchantment(Cloud.FEnchantment).FPlayerIndex :=
      A2.FPlayer;
    TGlobalEnchantment(Cloud.FEnchantment).FEnchantmentManaUpkeep := Self.FManaUpkeep;
    Cloud.FDrifting := False;
    if not SpellHSMap^.PlaceHX(Cloud,TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).X,
      TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).Y,TSpellLocation(TGlobalTargetSpellTE(A1).FLocation).Layer) then
      Cloud.Free;
    TSpellControl(SpellHSSet^.FSpellControl).GetSpell(Self.FSpellID).
      CastingDone(A2,Self.FBaseManaCost);
  end;
  Result := False;
end;










type
  TSpellEngineSetFields = packed record
    Reserved: array[0..$63] of Byte;
    HSSet: TAoWHSSet;
  end;

procedure RegisterGlobalTargetSpells(A1: TAoWEngine);
var Control: TSpellControl;
begin
  Control := TSpellControl(TSpellEngineSetFields(Pointer(A1)^).HSSet.FSpellControl);
  TEngine(A1).RegisterEClasses([TFreezeWaterTE,TFrozenWaterHS,TFireBarrierTE,
    TLevelTerrainTE,TRejuvenateTE,TWatcherTE,TWatcherHS,TTornadoTE,TVortexTE,
    THealingShowersTE,TGlobalTargetSpellTE]);
  Control.RegisterSpell(TFreezeWater.Create(nil));
  Control.RegisterSpell(TFireBarrier.Create(nil));
  Control.RegisterSpell(TLevelTerrain.Create(nil));
  Control.RegisterSpell(TRejuvenate.Create(nil));
  Control.RegisterSpell(TWatcher.Create(nil));
  Control.RegisterSpell(TTornado.Create(nil));
  Control.RegisterSpell(TVortex.Create(nil));
  Control.RegisterSpell(THealingShowers.Create(nil));
  Control.RegisterSpell(TSmokeCloudSpell.Create(nil));
end;

procedure UnregisterGlobalTargetSpells(A1: Integer);
var Control: TSpellControl;
begin
  Control := TSpellControl(TSpellEngineSetFields(Pointer(A1)^).HSSet.FSpellControl);
  Control.UnregisterSpellID(10);
  Control.UnregisterSpellID(11);
  Control.UnregisterSpellID(18);
  Control.UnregisterSpellID(41);
  Control.UnregisterSpellID(57);
  Control.UnregisterSpellID(68);
  Control.UnregisterSpellID(70);
  Control.UnregisterSpellID(73);
  Control.UnregisterSpellID(74);
  TEngine(A1).UnregisterEClasses([TFreezeWaterTE,TFrozenWaterHS,TFireBarrierTE,
    TLevelTerrainTE,TRejuvenateTE,TWatcherTE,TWatcherHS,TTornadoTE,TVortexTE,
    THealingShowersTE,TGlobalTargetSpellTE]);
end;


initialization
{$IFDEF RUNTIME_PACKAGES}
  SpellIntensityTable := @GFXE.IntensityBlendTable;
{$ENDIF}
finalization

end.
