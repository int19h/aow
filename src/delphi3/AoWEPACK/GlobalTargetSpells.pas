unit GlobalTargetSpells;

{ Draft declarations of GlobalTargetSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  All class bodies and registration routines are recovered below. Local declaration
  workarounds are marked needs; world pointer cells use the shared P1 globals. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Animation;

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
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer;
      const SurfaceDesc: TSurfaceDesc);
  end;

  { TTornado (instance size 60, VMT 5579DC10) }
  TTornado = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
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
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer;
      const SurfaceDesc: TSurfaceDesc);
  end;

  { TVortex (instance size 60, VMT 5579DE1C) }
  TVortex = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelection(A1: Integer); override;
    procedure ValidateTargetEvent(Target: TTargetSelectionControl; X,Y,Layer: Shortint; var Valid: Boolean);
  end;

  { THealingShowersTE (instance size 40, VMT 5579DF48): $24 animation. }
  THealingShowersTE = class(TGlobalTargetSpellTE)
  public
    FAnimation: TAnimation;
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer;
      const SurfaceDesc: TSurfaceDesc);
    procedure ChangeTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
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

uses EventLog, AoWReg, SmokeCloud;

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
    Spell.FCasterPlayer := Shortint(TAbstractUnit(Caster).FPlayer);
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
    ValidateTerrain(Caster.FPlayer,
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
  if (Byte(TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) = Caster.FPlayer) or
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
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
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
          Fire.F_Fire_24 := SpellSource(Self).FPlayer;
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
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
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
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
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
    ValidateTerrain(Caster.FPlayer,
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
  if (Byte(TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) = Caster.FPlayer) or
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
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
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
  Watcher.FEnchantment.F_GlobalEnchantment_19 := TAbstractUnit(A1).FPlayer;
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
    Shortint(TAbstractUnit(A1).FPlayer)));
  if not Busy then
  begin
    Event := TWatcherTE.Create(nil);
    Event.Initialize(F_Spell_10,TAbstractUnit(A1).FPlayer,
      TAbstractUnit(A1).FUnitID,F_Spell_14);
    Event.SetLocation(A2,A3,A4);
    TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
      GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
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

function SpellArmyID(Army: TArmy; Selection: Byte): TArmyID; assembler;
asm JMP TArmy.CreateID end;

function SpellCanPlace(Army: TArmy; X, Y, Layer: Shortint): Boolean; assembler;
asm POP EBP; JMP TArmy.CanPlace end;

procedure SpellMoveTable(Army: TArmy; Selection: Byte; var Table: TSpellMoveTable); assembler;
asm JMP TArmy.CreateMovePointTable end;

function SpellFieldPlayer(MapF: TAoWMapField): Shortint; assembler;
asm JMP TAoWMapField.GetPlayer end;

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

procedure TTornadoTE.Validate(A1: Integer);
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
  I, Direction, Radius, Count: Integer;
begin
  if SpellHSMap^.ViewL = TSpellLocation(FLocation).Layer then
  begin
    HXtoHP(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,Xhp,Yhp);
    Dec(Xhp,XhpSurf);
    Dec(Yhp,YhpSurf);
    FAngle := FAngle + 20 + FAnimation.F_Animation_10 div 5;
    RandSeed := SpellHSMap^.F_AoWHSMap_22C;
    for I := 0 to 200 do
    begin
      Direction := Random(360);
      if (Animation.F_Animation_10 >= I shr 2) and
         (Animation.F_Animation_10 <= (I shr 4) + 68) then
      begin
        Radius := Round((2.997 - Ln(I * 19 * 0.005 + 1)) * 35) + 7;
        Height := 200 - I - 16;
        XShift := Round(Sin(FAnimation.F_Animation_10 * 0.1 + I * 0.02) *
          (200-I) * 0.25) + 16;
        Angle := (Direction + FAngle) * Pi / 180;
        if TSpellEngineFields(Pointer(SpellHSMap^.Engine)^).Detail = 0 then
          Count := 1
        else if TSpellEngineFields(Pointer(SpellHSMap^.Engine)^).Detail = 1 then
          Count := (200-I) shr 5
        else Count := (200-I) shr 4;
        for Count := Count downto 0 do
        begin
          X := Round(Cos(Angle)*Radius) + XShift;
          Y := Round(Sin(Angle)*Radius*0.5) + Height;
          TImageSequenceList(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),68).
            F_Spell_2C).Show(0,Xhp+X,Yhp-Y,0,SurfaceDesc);
          Angle := 0.035 + Angle;
        end;
      end;
    end;
  end;
end;

resourcestring SpellXCastRStr = '%s cast';

function SpellUnitLevel(UnitObj: TAbstractUnit): Byte; assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$A0]; POP EBX end;

function SpellShield(MapF: TAoWMapField): Boolean; assembler;
asm JMP TAoWMapField.GetMagicShieldActive end;

procedure SpellRetrieveArmy(ID: TArmyID; var Army: TArmyHS; var Selection: Byte); assembler;
asm JMP TArmyID.RetrieveArmy end;

function SpellUnit(Army: TUnitList; Index: Integer): TAbstractUnit; assembler;
asm JMP TUnitList.GetUnit end;

function SpellTransporter(Army: TArmy; Selection: Byte): TAbstractUnit; assembler;
asm JMP TArmy.Transporter end;

function SpellSelection(Army: TArmy; Selection: Byte): Byte; assembler;
asm JMP TArmy.ValidateSelection end;

procedure SpellLogArmy(LogUnits: TUnitList; Army: TArmy; Selection: Byte); assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$C0]; POP EBX end;

function SpellVisibleForPlayer(Map: TAoWHSMap; X,Y,Layer: Integer; Player: Shortint): Boolean; assembler;
asm POP EBP; JMP TAoWHSMap.VisibleForPlayer end;

procedure SpellMoveArmy(Army: TArmyHS; MapF: TMapField; Mode: Integer); assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$10C]; POP EBX end;

function SpellPlaceUnit(UnitObj: TAbstractUnit; X,Y,Layer: Integer;
  Player, Mode: Byte): TArmyHS; assembler;
asm POP EBP; JMP TAbstractUnit.Place end;

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

procedure SpellObservation(Map: TAoWHSMap; Player,X,Y,Layer: Byte; Radius: Integer); assembler;
asm POP EBP; JMP TAoWHSMap.ValidateObservation end;

function SpellWatching(Map: TAoWHSMap; X,Y,Layer: Byte; Radius: Integer): Boolean; assembler;
asm POP EBP; JMP TAoWHSMap.Watching end;

function ProcessTornado(Event: TTornadoTE; Caster: TAbstractUnit; Step: Integer): Boolean;
var
  MovedUnits: TUnitUserList;
  Owner: Byte;
  Selection: Byte;
  Location: Integer;
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
  if Step = 0 then
  begin
    Event.FAngle := 0;
    LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),Event.F_SpellTE_10).
      CastingDone(Integer(Caster),LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
        Event.F_SpellTE_10).F_Spell_14);
    SpellObservation(SpellHSMap^,Caster.FPlayer,
      TSpellLocation(Event.FLocation).X,TSpellLocation(Event.FLocation).Y,
      TSpellLocation(Event.FLocation).Layer,2);
    if (Caster.FPlayer = TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) or
      SpellWatching(SpellHSMap^,TSpellLocation(Event.FLocation).X,
        TSpellLocation(Event.FLocation).Y,TSpellLocation(Event.FLocation).Layer,2) then
      TSFXLibrary(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
        Event.F_SpellTE_10).F_Spell_28).Play(0);
    Event.FAnimation := TAnimation.Create(nil);
    Event.FAnimation.F_Animation_0B[0] := $1B;
    TSpellAnimationFields(Pointer(Event.FAnimation)^).OnShow := Event.ShowAnimation;
    Event.FAnimation.F_Animation_38 := Integer(SpellHSMap^);
    Event.FAnimation.F_Animation_34 := (SpellHSMap^.ViewWidth and $FFFF) or
      (SpellHSMap^.ViewHeight shl 16);
    Event.FAnimation.Activate;
  end;
  Result := True;
  if Step <> 80 then Exit;
  MapF := TAoWMapField(SpellHSMap^.MapContainer.GetField(
    TSpellLocation(Event.FLocation).X,TSpellLocation(Event.FLocation).Y,
    TSpellLocation(Event.FLocation).Layer));
  if (Event.FArmyID <> nil) and not SpellShield(MapF) then
  begin
    SpellRetrieveArmy(Event.FArmyID,Army,Selection);
    Exposed := (MapF.OverlayType <> 1) and (MapF.FindNoneTransparentHS(TStructure) = nil);
    for I := 0 to TArmy(Army.F_ArmyHS_1C).Count - 1 do
      if (Selection and (1 shl I)) <> 0 then
      begin
        UnitObj := SpellUnit(TArmy(Army.F_ArmyHS_1C),I);
        case SpellUnitLevel(UnitObj) of
          1: Chance := 90;
          2: Chance := 70;
          3: Chance := 50;
          4: Chance := 30;
        else Chance := 30;
        end;
        if not Exposed then Chance := Chance shr 1;
        if Chance < SpellMapRandom(SpellHSMap^,100) then
          Selection := Selection and not (1 shl I);
      end;
    if SpellTransporter(TArmy(Army.F_ArmyHS_1C),$FF) <> nil then
      if SpellTransporter(TArmy(Army.F_ArmyHS_1C),Selection) <> nil then Selection := $FF
      else Selection := 0;
    if Selection <> 0 then
    begin
      Log := TArmyEventLog.Create(nil);
      Log.F_EventLog_10 := Caster.FPlayer;
      PSpellString(@Log.F_ArmyEventLog_1C)^ :=
        SysUtils.Format(SpellTranslate(SpellXCastRStr),[SpellTranslate(TornadoRStr)]);
      TStrings(Log.F_ArmyEventLog_20).Add(SpellTranslate(TornadoRStr));
      Log.F_ArmyEventLog_24 := 2;
      SpellLogArmy(TUnitList(Log.F_ArmyEventLog_18),TArmy(Army.F_ArmyHS_1C),Selection);
      DistributeLocationEventLog(Integer(Log),Event.F_SpellTE_18,Army.Xhx,Army.Yhx,Army.Lhx,1);
      Log.Release;
      Location := TTornado(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),68)).
        CalculateWarpLocation(Army,Selection);
      if Location <> $FFFFFF then
      begin
        if (Caster.FPlayer = TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) or
          SpellWatching(SpellHSMap^,TSpellLocation(Event.FLocation).X,
            TSpellLocation(Event.FLocation).Y,TSpellLocation(Event.FLocation).Layer,2) then
          TSFXLibrary(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
            Event.F_SpellTE_10).F_Spell_28).Play(1);
        if (TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer = Caster.FPlayer) or
          SpellVisibleForPlayer(SpellHSMap^,TSpellLocation(Event.FLocation).X,
            TSpellLocation(Event.FLocation).Y,TSpellLocation(Event.FLocation).Layer,
            TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) then
          if TImageSequenceList(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
            Event.F_SpellTE_10).F_Spell_2C).ImageSequences[1] <> nil then
          begin
            Anim := TImageSequenceAnimation.Create(nil);
            Anim.SetImageSequence(Integer(TImageSequenceList(LookupSpell(
              TSpellControl(SpellHSSet^.FSpellControl),Event.F_SpellTE_10).
              F_Spell_2C).ImageSequences[1]));
            SpellHSMap^.PlaceHX(Anim,TSpellLocation(Event.FLocation).X,
              TSpellLocation(Event.FLocation).Y,TSpellLocation(Event.FLocation).Layer);
          end;
        if (TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer = Caster.FPlayer) or
          SpellVisibleForPlayer(SpellHSMap^,TSpellLocation(Location).X,
            TSpellLocation(Location).Y,TSpellLocation(Location).Layer,
            TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) then
          if TImageSequenceList(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
            Event.F_SpellTE_10).F_Spell_2C).ImageSequences[1] <> nil then
          begin
            Anim := TImageSequenceAnimation.Create(nil);
            Anim.SetImageSequence(Integer(TImageSequenceList(LookupSpell(
              TSpellControl(SpellHSSet^.FSpellControl),Event.F_SpellTE_10).
              F_Spell_2C).ImageSequences[1]));
            SpellHSMap^.PlaceHX(Anim,TSpellLocation(Location).X,
              TSpellLocation(Location).Y,TSpellLocation(Location).Layer);
          end;
        MovedUnits := TUnitUserList.Create(nil);
        Owner := TArmy(Army.F_ArmyHS_1C).F_Army_12;
        MapF := TAoWMapField(SpellHSMap^.MapContainer.GetFieldXYL(Location));
        if SpellSelection(TArmy(Army.F_ArmyHS_1C),$FF) = Selection then
        begin
          MovedUnits.AddUnits(Integer(Army.F_ArmyHS_1C));  { AddUnits is still a draft }
          SpellMoveArmy(Army,MapF,0);
        end
        else
          for I := TArmy(Army.F_ArmyHS_1C).Count - 1 downto 0 do
            if (Selection and (1 shl I)) <> 0 then
            begin
              UnitObj := SpellUnit(TArmy(Army.F_ArmyHS_1C),I);
              MovedUnits.AddUnit(Integer(UnitObj));
              Placed := SpellPlaceUnit(UnitObj,TSpellLocation(Location).X,
                TSpellLocation(Location).Y,TSpellLocation(Location).Layer,
                TArmy(Army.F_ArmyHS_1C).F_Army_12,0);
              if Placed <> nil then TArmy(Placed.F_ArmyHS_1C).UpdateExploration;
            end;
        if Owner = 0 then
        begin
          Group := SpellCreateGroup(TAIGroupManager(SpellHSMap^.F_AoWHSMap_130),0,
            SpellIndependentRelation(MovedUnits,5),13);
          Group.AddUnits(Integer(MovedUnits));
          TSpellAIGroupFields(Pointer(Group)^).Enemies.Add(Caster.FUnitID);
          Group.Release;
        end;
        MovedUnits.Free;
      end;
    end;
  end;
  Event.FAnimation.Free;
  Result := False;
end;

procedure TTornadoTE.Process(A1: Integer; A2: Integer);
asm
  { needs: Boolean result on TSpellTE.Process; managed locals finalize in the helper. }
  JMP ProcessTornado
end;

constructor TTornado.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(TornadoRStr);
  F_Spell_10 := 68;
  FAboveGroundOnly := True;
end;

function TTornado.ValidWarpLocation(Army: TArmyHS; X, Y, Layer: Shortint): Boolean;
var
  MapF: TAoWMapField;
  Msg: TMapFieldMsg;
begin
  MapF := TAoWMapField(SpellHSMap^.MapContainer.GetField(X,Y,Layer));
  Result := (SpellFieldArmy(MapF) = nil) and (SpellFieldPlayer(MapF) = -1);
  if Result then
  begin
    Msg.MsgID := $1120;
    Msg.Param[0] := Integer(Army);
    Msg.Result := 0;
    MapF.SendMapFieldMsg(Msg);
    Result := (Msg.Result = 0) and SpellCanPlace(TArmy(Army.F_ArmyHS_1C),X,Y,Layer);
  end;
end;

function TTornado.CalculateWarpLocation(Army: TArmyHS; Selection: Byte): Integer;
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
  SpellMoveTable(TArmy(Army.F_ArmyHS_1C),Selection,Table);
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

procedure TTornado.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Event: TTornadoTE;
  Army: TArmyHS;
  Busy: Boolean;
begin
  Busy := SpellPlayerBusy(SpellPlayer(TPlayerList(SpellHSMap^.FPlayers),
    Shortint(TAbstractUnit(A1).FPlayer)));
  if not Busy then
  begin
    Event := TTornadoTE.Create(nil);
    Event.Initialize(F_Spell_10,TAbstractUnit(A1).FPlayer,
      TAbstractUnit(A1).FUnitID,F_Spell_14);
    Event.SetLocation(A2,A3,A4);
    Army := SpellFieldArmy(TAoWMapField(SpellHSMap^.MapContainer.GetField(A2,A3,A4)));
    if Army <> nil then Event.FArmyID := SpellArmyID(TArmy(Army.F_ArmyHS_1C),$FF);
    TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
      GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
    Event.Release;
  end;
  asm MOV AL, Busy; XOR AL, 1 end;
end;

procedure TTornado.SetupTargetSelection(A1: Integer; A2: Integer);
var Target: TTargetSelectionControl;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1,Integer(Target));
  TShortIntList(Target.F_TargetSelectionControl_08).Clear;
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

procedure TVortexTE.Validate(A1: Integer);
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
  I, Direction, Radius, Count: Integer;
begin
  if SpellHSMap^.ViewL = TSpellLocation(FLocation).Layer then
  begin
    HXtoHP(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,Xhp,Yhp);
    Dec(Xhp,XhpSurf);
    Dec(Yhp,YhpSurf);
    FAngle := FAngle + 20 + FAnimation.F_Animation_10 div 5;
    RandSeed := SpellHSMap^.F_AoWHSMap_22C;
    for I := 0 to 200 do
    begin
      Direction := Random(360);
      if (Animation.F_Animation_10 >= (200-I) shr 2) and
         (Animation.F_Animation_10 <= (I shr 4) + 68) then
      begin
        Radius := Round((2.997 - Ln(I * 19 * 0.005 + 1)) * 35) + 18;
        Height := -16;
        XShift := 16;
        Angle := -(Direction + FAngle) * Pi / 180;
        if TSpellEngineFields(Pointer(SpellHSMap^.Engine)^).Detail = 0 then
          Count := 1
        else if TSpellEngineFields(Pointer(SpellHSMap^.Engine)^).Detail = 1 then
          Count := (200-I) shr 5
        else Count := (200-I) shr 4;
        for Count := Count downto 0 do
        begin
          X := Round(Cos(Angle)*Radius) + XShift;
          Y := Round(Sin(Angle)*Radius / 1.75) + Height;
          TImageSequenceList(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),70).
            F_Spell_2C).Show(0,Xhp+X,Yhp-Y,0,SurfaceDesc);
          Angle := 0.035 + Angle;
        end;
      end;
    end;
  end;
end;

function SpellRetrieveArmyOK(ID: TArmyID; var Army: TArmyHS; var Selection: Byte): Boolean; assembler;
asm JMP TArmyID.RetrieveArmy end;

function SpellMoveTypes(UnitObj: TAbstractUnit): Byte; assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$E8]; POP EBX end;

function SpellDamage(UnitObj: TAbstractUnit; Attack, Resistance: Integer;
  Types: Byte): Integer; assembler;
asm POP EBP; JMP TAbstractUnit.ExecuteDamageRole end;

procedure SpellValidateTerrain(Army: TArmy; Terrain,Overlay,Player: Byte); assembler;
asm POP EBP; JMP TArmy.ValidateTerrainEx end;

function ProcessVortex(Event: TVortexTE; Caster: TAbstractUnit; Step: Integer): Boolean;
var
  Log: TArmyEventLog;
  Selection: Byte;
  Damaged: Boolean;
  Damage, Resistance: Integer;
  Army: TArmyHS;
  UnitObj: TAbstractUnit;
  I: Integer;
begin
  if Step = 0 then
  begin
    Event.FAngle := 0;
    LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),Event.F_SpellTE_10).
      CastingDone(Integer(Caster),LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
        Event.F_SpellTE_10).F_Spell_14);
    SpellObservation(SpellHSMap^,Caster.FPlayer,
      TSpellLocation(Event.FLocation).X,TSpellLocation(Event.FLocation).Y,
      TSpellLocation(Event.FLocation).Layer,2);
    if (Caster.FPlayer = TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) or
      SpellWatching(SpellHSMap^,TSpellLocation(Event.FLocation).X,
        TSpellLocation(Event.FLocation).Y,TSpellLocation(Event.FLocation).Layer,2) then
      TSFXLibrary(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
        Event.F_SpellTE_10).F_Spell_28).Play(0);
    Event.FAnimation := TAnimation.Create(nil);
    Event.FAnimation.F_Animation_0B[0] := $1B;
    TSpellAnimationFields(Pointer(Event.FAnimation)^).OnShow := Event.ShowAnimation;
    Event.FAnimation.F_Animation_38 := Integer(SpellHSMap^);
    Event.FAnimation.F_Animation_34 := (SpellHSMap^.ViewWidth and $FFFF) or
      (SpellHSMap^.ViewHeight shl 16);
    Event.FAnimation.Activate;
  end;
  Result := True;
  if Step <> 80 then Exit;
  if (Event.FArmyID <> nil) and SpellRetrieveArmyOK(Event.FArmyID,Army,Selection) then
  begin
    Log := TArmyEventLog.Create(nil);
    PSpellString(@Log.F_ArmyEventLog_1C)^ := SpellTranslate(VortexDamageRStr);
    Log.F_EventLog_10 := Caster.FPlayer;
    TStrings(Log.F_ArmyEventLog_20).Add(SpellTranslate(VortexRStr));
    Log.F_ArmyEventLog_24 := 2;
    SpellLogArmy(TUnitList(Log.F_ArmyEventLog_18),TArmy(Army.F_ArmyHS_1C),$FF);
    TArmy(Army.F_ArmyHS_1C).BeginUpdate;
    Damaged := False;
    for I := 0 to TArmy(Army.F_ArmyHS_1C).Count - 1 do
    begin
      UnitObj := SpellUnit(TArmy(Army.F_ArmyHS_1C),I);
      if (SpellMoveTypes(UnitObj) and 2) = 0 then
      begin
        if UnitObj.GetAbilityEnabled(2) then Resistance := 7
        else if UnitObj.GetAbilityEnabled(23) then Resistance := 10
        else Resistance := 0;
        Damage := SpellDamage(UnitObj,8,Resistance,$80);
        if Damage > UnitObj.GetHitPoints then Damage := UnitObj.GetHitPoints;
        if Damage > 0 then
        begin
          UnitObj.SetHitPoints(UnitObj.GetHitPoints-Damage);
          Damaged := True;
        end;
      end
      else Damage := 0;
      TByteList(Log.F_ArmyEventLog_28).Add(Damage);
      TByteList(Log.F_ArmyEventLog_2C).Add(7);
    end;
    if Damaged then
    begin
      Log.ValidateGameOver;
      DistributeLocationEventLog(Integer(Log),TArmy(Army.F_ArmyHS_1C).F_Army_12,
        Army.Xhx,Army.Yhx,Army.Lhx,1);
    end;
    Log.Release;
    TArmy(Army.F_ArmyHS_1C).Validate;
    SpellValidateTerrain(TArmy(Army.F_ArmyHS_1C),TMapField(Army.Owner).TerrainType,
      TMapField(Army.Owner).OverlayType,Caster.FPlayer);
    TArmy(Army.F_ArmyHS_1C).EndUpdate;
  end;
  Event.FAnimation.Free;
  Result := False;
end;

procedure TVortexTE.Process(A1: Integer; A2: Integer);
asm JMP ProcessVortex end;

constructor TVortex.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(VortexRStr);
  F_Spell_10  := 70;
  FAboveGroundOnly := False;
end;

procedure TVortex.ValidTargetSelection(A1: Integer);
var
  MapF: TMapField;
  Valid: Boolean;
begin
  Valid := False;
  if TTargetSelectionView(A1).X <> -1 then
  begin
    MapF := SpellHSMap^.MapContainer.MapLevels[TTargetSelectionView(A1).Layer].
      GetField(TTargetSelectionView(A1).X,TTargetSelectionView(A1).Y);
    Valid := (MapF.TerrainType = 0) or (MapF.TerrainType = 10);
  end;
  asm MOV AL,Valid end;
end;

procedure TVortex.ValidateTargetEvent(Target: TTargetSelectionControl;
  X,Y,Layer: Shortint; var Valid: Boolean);
var MapF: TMapField;
begin
  if X = -1 then Valid := False
  else
  begin
    MapF := SpellHSMap^.MapContainer.MapLevels[Layer].GetField(X,Y);
    Valid := (MapF.TerrainType = 0) or (MapF.TerrainType = 10);
  end;
end;

procedure TVortex.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Event: TVortexTE;
  Army: TArmyHS;
  Busy: Boolean;
begin
  Busy := SpellPlayerBusy(SpellPlayer(TPlayerList(SpellHSMap^.FPlayers),
    Shortint(TAbstractUnit(A1).FPlayer)));
  if not Busy then
  begin
    Event := TVortexTE.Create(nil);
    Event.Initialize(F_Spell_10,TAbstractUnit(A1).FPlayer,
      TAbstractUnit(A1).FUnitID,F_Spell_14);
    Event.SetLocation(A2,A3,A4);
    Army := SpellFieldArmy(TAoWMapField(SpellHSMap^.MapContainer.GetField(A2,A3,A4)));
    if Army <> nil then Event.FArmyID := SpellArmyID(TArmy(Army.F_ArmyHS_1C),$FF);
    TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
      GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
    Event.Release;
  end;
  asm MOV AL, Busy; XOR AL, 1 end;
end;

procedure TVortex.SetupTargetSelection(A1: Integer; A2: Integer);
var Target: TTargetSelectionControl;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1,Integer(Target));
  TShortIntList(Target.F_TargetSelectionControl_08).Clear;
  TTargetSelectionView(Target).OnValidate := ValidateTargetEvent;
end;

type
  TSpellRegistryFields = packed record
    Reserved: array[0..$5B] of Byte;
    Registry: TAoWRegistry;
  end;

function SpellAbility(Control: TAbilityControl; ID: Integer): TAbility; assembler;
asm JMP TAbilityControl.GetAbility end;

function SpellHitPointsMax(UnitObj: TAbstractUnit): Shortint; assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$D0]; POP EBX end;

class function THealingShowersTE.ClassID: Integer;
begin Result := $21327; end;

procedure THealingShowersTE.ShowAnimation(Animation: TAnimation;
  XhpSurf,YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  X,Y,Speed,Xhp,Yhp,Count: Integer;
  I,J,Frame,XShift,YShift: Integer;
begin
  if SpellHSMap^.ViewL = TSpellLocation(FLocation).Layer then
  begin
    HXtoHP(TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,Xhp,Yhp);
    Dec(Xhp,XhpSurf);
    Dec(Yhp,YhpSurf);
    case TSpellRegistryFields(Pointer(SpellHSMap^.Engine)^).Registry.GetDetailLevel of
      dtlLow: Count := 50;
      dtlHigh: Count := 160;
    else Count := 100;
    end;
    RandSeed := SpellHSMap^.F_AoWHSMap_22C;
    for I := 0 to Count do
    begin
      X := Random(100)-50;
      Y := Random(100)-50;
      Speed := Random(5)+5;
      Frame := Animation.F_Animation_10-Random(30);
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
            TImageSequenceList(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
              73).F_Spell_2C).Show(0,Xhp+XShift+120,Yhp+YShift-500+30,0,SurfaceDesc);
          end;
      end;
    end;
  end;
end;

procedure THealingShowersTE.ChangeTerrain(MapF: TMapField; var TerrainType,OverlayType: Shortint);
begin
  case TerrainType of
    2: TerrainType := 4;
    4: TerrainType := 1;
    5: TerrainType := 4;
  end;
end;

procedure THealingShowersTE.Process(A1: Integer; A2: Integer);
var
  Level: TMapLevel;
  Walk: THNWalkData;
  Army: TArmyHS;
  UnitObj: TAbstractUnit;
  Anim: TImageSequenceAnimation;
  I: Integer;
  Healed,PlaySound: Boolean;
  Cloud: THexagonSprite;
begin
  inherited Process(A1,A2);
  if A2 = 0 then
  begin
    TSpellMapCalls(SpellHSMap^).ValidateTerrain(TAbstractUnit(A1).FPlayer,
      TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2);
    if (TAbstractUnit(A1).FPlayer = TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) or
      TSpellMapCalls(SpellHSMap^).WatchingTerrain(TSpellLocation(FLocation).X,
        TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,2) then
      TSFXLibrary(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),73).F_Spell_28).Play(0);
    FAnimation := TAnimation.Create(nil);
    FAnimation.F_Animation_0B[0] := $1B;
    TSpellAnimationFields(Pointer(FAnimation)^).OnShow := ShowAnimation;
    FAnimation.F_Animation_38 := Integer(SpellHSMap^);
    FAnimation.F_Animation_34 := (SpellHSMap^.ViewWidth and $FFFF) or
      (SpellHSMap^.ViewHeight shl 16);
    FAnimation.Activate;
    LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),F_SpellTE_10).
      CastingDone(A1,F_SpellTE_1C);
  end;
  if A2 = 50 then
  begin
    PlaySound := False;
    SpellHSMap^.ChangeTerrainEx(nil,TSpellLocation(FLocation).X,
      TSpellLocation(FLocation).Y,TSpellLocation(FLocation).Layer,1,ChangeTerrain,nil);
    Level := SpellHSMap^.MapContainer.MapLevels[TSpellLocation(FLocation).Layer];
    InitHNWalk(Walk,TSpellLocation(FLocation).X,TSpellLocation(FLocation).Y,0);
    while Walk.Radius < 2 do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and
        (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        if not SpellShield(TAoWMapField(Level.GetField(Walk.X,Walk.Y))) then
        begin
          Healed := False;
          Army := SpellFieldArmy(TAoWMapField(Level.GetField(Walk.X,Walk.Y)));
          if Army <> nil then
          begin
            for I := 0 to TArmy(Army.F_ArmyHS_1C).Count-1 do
            begin
              UnitObj := SpellUnit(TArmy(Army.F_ArmyHS_1C),I);
              if UnitObj.GetHitPoints < SpellHitPointsMax(UnitObj) then
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
            TArmy(Army.F_ArmyHS_1C).Update;
            if Healed and SpellVisibleForPlayer(SpellHSMap^,Army.Xhx,Army.Yhx,Army.Lhx,
              TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) then
            begin
              PlaySound := PlaySound or
                (TArmy(Army.F_ArmyHS_1C).F_Army_12 =
                  TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) or
                SpellWatching(SpellHSMap^,Army.Xhx,Army.Yhx,Army.Lhx,1);
              Anim := TImageSequenceAnimation.Create(nil);
              Anim.SetImageSequence(Integer(TImageSequenceList(SpellAbility(
                TAbilityControl(SpellHSSet^.FAbilityControl),47).F_Ability_1C).ImageSequences[0]));
              Anim.F_Animation_0B[0] := 27;
              SpellHSMap^.PlaceHX(Anim,Army.Xhx,Army.Yhx,Army.Lhx);
            end;
          end;
          Cloud := Level.GetField(Walk.X,Walk.Y).FindNoneTransparentHSCID($2077E);
          if Cloud <> nil then Cloud.Free;
        end;
      WalkToNextHN(Walk);
    end;
    if PlaySound then
      TSFXLibrary(SpellAbility(TAbilityControl(SpellHSSet^.FAbilityControl),47).
        F_Ability_18).Play(0);
  end;
  if A2 = 80 then FAnimation.Free;
  asm CMP A2,80; SETNE AL end;
end;

constructor THealingShowers.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(HealingShowersRStr);
  F_Spell_10 := 73;
  F_Spell_14 := 5;
  F_Spell_21 := 3;
  F_Spell_20 := 6;
end;

procedure THealingShowers.ValidTargetMapF(A1: Integer);
begin inherited ValidTargetMapF(A1); end;


procedure THealingShowers.ValidTargetSelectionMapF(A1: Integer);
begin inherited ValidTargetSelectionMapF(A1); end;


procedure THealingShowers.SetupTargetSelection(A1: Integer; A2: Integer);
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


procedure THealingShowers.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Event: THealingShowersTE;
begin
  Event := THealingShowersTE.Create(nil);
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
  Event.Release;
  asm MOV AL, 1 end;
end;

{ needs: TFireControl.PlaceFire(X,Y,Layer:Integer; Create:Boolean): TFire,
  result consumed at $5579EDC3; GetSource returns TAbstractUnit at $5579EDE2. }

constructor TSmokeCloudSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  TSpellNameView(Pointer(Self)^).Name := SpellTranslate(SmokeCloudRStr);
  F_Spell_10 := 74;
  F_Spell_14 := 5;
  F_Spell_21 := 3;
  F_Spell_20 := 5;
end;

procedure TSmokeCloudSpell.ValidTargetMapF(A1: Integer);
begin inherited ValidTargetMapF(A1); end;


procedure TSmokeCloudSpell.ValidTargetSelectionMapF(A1: Integer);
begin inherited ValidTargetSelectionMapF(A1); end;


procedure TSmokeCloudSpell.SetupTargetSelection(A1: Integer; A2: Integer);
var
  Target: TTargetSelectionControl;
  I: Integer;
begin
  Target := TTargetSelectionControl(A2);
  inherited SetupTargetSelection(A1, Integer(Target));
  TShortIntList(Target.F_TargetSelectionControl_08).Clear;
  for I := 0 to RadToHN(4) - 1 do
    TShortIntList(Target.F_TargetSelectionControl_08).Add(0);
end;


procedure TSmokeCloudSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Event: TGlobalTargetSpellTE;
begin
  Event := TGlobalTargetSpellTE.Create(nil);
  Event.Initialize(F_Spell_10, TAbstractUnit(A1).FPlayer,
    TAbstractUnit(A1).FUnitID, F_Spell_14);
  Event.SetLocation(A2, A3, A4);
  TTokenManager(SpellHSMap^.F_AoWHSMap_23C).
    GetTokenControl(Shortint(TAbstractUnit(A1).FPlayer)).Add(Event);
  Event.Release;
  asm MOV AL, 1 end;
end;

{ needs: TFireControl.PlaceFire(X,Y,Layer:Integer; Create:Boolean): TFire,
  result consumed at $5579EDC3; GetSource returns TAbstractUnit at $5579EDE2. }

function SpellResource(Collection: TObject; ID: Integer): TEResource; assembler;
asm PUSH EBX; MOV EBX,[EAX]; CALL DWORD PTR [EBX+$7C]; POP EBX end;

function ExecuteSmokeCloud(Spell: TSmokeCloudSpell; Event: TGlobalTargetSpellTE;
  Caster: TAbstractUnit): Boolean;
var
  Resource: TEResource;
  Cloud: TSmokeCloud;
begin
  SpellObservation(SpellHSMap^,SpellSource(Event).FPlayer,
    TSpellLocation(Event.FLocation).X,TSpellLocation(Event.FLocation).Y,
    TSpellLocation(Event.FLocation).Layer,2);
  if (SpellSource(Event).FPlayer =
    TMapSeatedPlayerView(Pointer(SpellHSMap^)^).SeatedPlayer) or
    SpellWatching(SpellHSMap^,TSpellLocation(Event.FLocation).X,
      TSpellLocation(Event.FLocation).Y,TSpellLocation(Event.FLocation).Layer,2) then
    TSFXLibrary(LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),
      Event.F_SpellTE_10).F_Spell_28).Play(0);
  Resource := SpellResource(TObject(SpellHSSet^.MapObjectResourceList),$21243);
  if Resource <> nil then
  begin
    Cloud := TSmokeCloud(Resource.CreateResourceUser);
    Cloud.F_SmokeCloud_14 := Caster.FPlayer;
    Cloud.F_SmokeCloud_18 := -1;
    TGlobalEnchantment(Cloud.F_SmokeCloud_20).F_GlobalEnchantment_19 :=
      Caster.FPlayer;
    TGlobalEnchantment(Cloud.F_SmokeCloud_20).F_GlobalEnchantment_20 := Spell.F_Spell_18;
    Cloud.F_SmokeCloud_1C := 0;
    if not SpellHSMap^.PlaceHX(Cloud,TSpellLocation(Event.FLocation).X,
      TSpellLocation(Event.FLocation).Y,TSpellLocation(Event.FLocation).Layer) then
      Cloud.Free;
    LookupSpell(TSpellControl(SpellHSSet^.FSpellControl),Spell.F_Spell_10).
      CastingDone(Integer(Caster),Spell.F_Spell_14);
  end;
  Result := False;
end;

procedure TSmokeCloudSpell.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
asm
  { needs: TSpell.ExecuteTE has only Event and Caster register arguments.
    Its shared draft adds a stack argument; remove that frame before dispatch. }
  POP EBP
  JMP ExecuteSmokeCloud
end;

type
  TSpellEngineSetFields = packed record
    Reserved: array[0..$63] of Byte;
    HSSet: TAoWHSSet;
  end;

procedure RegisterGlobalTargetSpells(A1: Integer);
var Control: TSpellControl;
begin
  Control := TSpellControl(TSpellEngineSetFields(Pointer(A1)^).HSSet.FSpellControl);
  TEngine(A1).RegisterEClasses([TFreezeWaterTE,TFrozenWaterHS,TFireBarrierTE,
    TLevelTerrainTE,TRejuvenateTE,TWatcherTE,TWatcherHS,TTornadoTE,TVortexTE,
    THealingShowersTE,TGlobalTargetSpellTE]);
  Control.RegisterSpell(Integer(TFreezeWater.Create(nil)));
  Control.RegisterSpell(Integer(TFireBarrier.Create(nil)));
  Control.RegisterSpell(Integer(TLevelTerrain.Create(nil)));
  Control.RegisterSpell(Integer(TRejuvenate.Create(nil)));
  Control.RegisterSpell(Integer(TWatcher.Create(nil)));
  Control.RegisterSpell(Integer(TTornado.Create(nil)));
  Control.RegisterSpell(Integer(TVortex.Create(nil)));
  Control.RegisterSpell(Integer(THealingShowers.Create(nil)));
  Control.RegisterSpell(Integer(TSmokeCloudSpell.Create(nil)));
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
finalization

end.
