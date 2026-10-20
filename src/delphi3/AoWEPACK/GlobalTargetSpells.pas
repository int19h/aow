unit GlobalTargetSpells;

{ Draft declarations of GlobalTargetSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TGlobalTargetSpellTE and TGlobalTargetSpell have recovered bodies below;
  the remaining classes are drafts. Local declaration workarounds are marked
  needs; their global pointer cells require binding before runtime use. }

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
    procedure ChangeTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure TerrainChanged(A1: Integer; A2: Integer; A3: Integer);  { draft }
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
    procedure RejuvenateTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
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

  { TWatcherEnchantment (instance size 40, VMT 5579D648) }
  TWatcherEnchantment = class(TGlobalEnchantment)
  public
    F_WatcherEnchantment_24: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer); override;
    procedure GetLocation(A1: Integer; A2: Integer); override;
    procedure Deactivate(A1: Byte); override;
  end;

  { TWatcherHS (instance size 32, VMT 5579D7A0) }
  TWatcherHS = class(TSingleHS)
  public
    F_WatcherHS_0C: Byte;
    F_WatcherHS_0D: Byte;
    F_WatcherHS_0E: array[0..1] of Byte;
    F_WatcherHS_10: Integer;
    F_WatcherHS_14: Integer;
    F_WatcherHS_18: Integer;
    F_WatcherHS_1C: Byte;
    F_WatcherHS_1D: array[0..2] of Byte;
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
    procedure StartAnimation(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure StopAnimation;  { draft }
    procedure UpdateExploration;  { draft }
    procedure UpdateUnfog;  { draft }
    procedure VisibilityRange;  { draft }
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
  TSpellLocation = packed record
    X, Y, Layer: Shortint;
    Reserved: Byte;
  end;

var
  { needs: AoWE.AoWHSSet and AoWE.AoWHSMap exported globals, loaded through
    package pointer cells at $558E92E8 and $558E9494 in PlayDefaultEffects.
    Temporary cells must be bound to those globals when P1 supplies them. }
  SpellHSSet: ^TAoWHSSet;
  SpellHSMap: ^TAoWHSMap;
  { needs: package indirection for GFXE.IntensityBlendTable ($558FC31C). }
  SpellIntensityTable: ^TLookupBlendTableCollection100;

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
    TSpellControl(SpellHSSet^.F_AoWHSSet_84), F_SpellTE_10).F_Spell_2C).
    ImageSequences[0] <> nil then
  begin
    Animation := TImageSequenceAnimation.Create(nil);
    { needs: TImageSequenceAnimation.SetImageSequence(Value: TImageSequence). }
    Animation.SetImageSequence(Integer(TImageSequenceList(
      LookupSpell(
      TSpellControl(SpellHSSet^.F_AoWHSSet_84), F_SpellTE_10).F_Spell_2C).
      ImageSequences[0]));
    SpellHSMap^.PlaceHX(Animation, X, Y, Layer);
  end;
  TSFXLibrary(LookupSpell(
    TSpellControl(SpellHSSet^.F_AoWHSSet_84), F_SpellTE_10).F_Spell_28).Play(0);
end;

constructor TGlobalTargetSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  F_Spell_22 := 2;
end;

procedure TGlobalTargetSpell.ShowTargetSelection(Target: TTargetSelectionControl; HN, Xs, Ys: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Level: TMapLevel;
  X, Y, Intensity, Radius: Integer;
begin
  Level := SpellHSMap^.MapContainer.MapLevels[Shortint(Target.F_TargetSelectionControl_3B)];
  CenterHNtoHX(Shortint(Target.F_TargetSelectionControl_39), Shortint(Target.F_TargetSelectionControl_3A), HN, X, Y);
  { Original accepts Width/Height themselves (strict > bounds test). }
  if (X >= 0) and (Y >= 0) and (X <= Level.Width) and (Y <= Level.Height) then
  begin
    if TGlobalTargetSpellCalls(Self).ValidSelectionMapF(Integer(Level.Field[X, Y])) then
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
  UnitLayer, UnitY, UnitX: Shortint;
begin
  with TTargetSelectionFields(Pointer(A2)^) do
  begin
    TTargetSelectionControl(A2).Initialize(A1);
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
      TSpellControl(SpellHSSet^.F_AoWHSSet_84), F_Spell_10).F_Spell_2C).
      ImageSequences[20].GetPreviewImage;
    ValidPreview := TImageSequenceList(LookupSpell(
      TSpellControl(SpellHSSet^.F_AoWHSSet_84), F_Spell_10).F_Spell_2C).
      ImageSequences[21].GetPreviewImage;
    InvalidPreview := TImageSequenceList(LookupSpell(
      TSpellControl(SpellHSSet^.F_AoWHSSet_84), F_Spell_10).F_Spell_2C).
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

class function TFreezeWaterTE.ClassID: Integer;
begin Result := 0; end;

procedure TFreezeWaterTE.ChangeTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TFreezeWaterTE.TerrainChanged(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TFreezeWaterTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TFreezeWater.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFreezeWater.ValidTargetMapF(A1: Integer);
begin end;

procedure TFreezeWater.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TFreezeWater.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TFreezeWater.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

class function TFireBarrierTE.ClassID: Integer;
begin Result := 0; end;

procedure TFireBarrierTE.CreateFireBarrier;
begin end;

procedure TFireBarrierTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TFireBarrier.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFireBarrier.ValidTargetMapF(A1: Integer);
begin end;

procedure TFireBarrier.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TFireBarrier.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TFireBarrier.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

class function TLevelTerrainTE.ClassID: Integer;
begin Result := 0; end;

procedure TLevelTerrainTE.LevelTerrain;
begin end;

procedure TLevelTerrainTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TLevelTerrain.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TLevelTerrain.ValidTargetMapF(A1: Integer);
begin end;

procedure TLevelTerrain.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TLevelTerrain.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TLevelTerrain.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

class function TRejuvenateTE.ClassID: Integer;
begin Result := 0; end;

procedure TRejuvenateTE.RejuvenateTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRejuvenateTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TRejuvenate.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRejuvenate.ValidTargetMapF(A1: Integer);
begin end;

procedure TRejuvenate.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TRejuvenate.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TRejuvenate.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TWatcherEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWatcherEnchantment.GetName(A1: Integer);
begin end;

procedure TWatcherEnchantment.GetLocation(A1: Integer; A2: Integer);
begin end;

procedure TWatcherEnchantment.Deactivate(A1: Byte);
begin end;

constructor TWatcherHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TWatcherHS.Destroy;
begin end;

class function TWatcherHS.ClassID: Integer;
begin Result := 0; end;

function TWatcherHS.GetLevel: Byte;
begin Result := 0; end;

procedure TWatcherHS.StartAnimation(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TWatcherHS.StopAnimation;
begin end;

procedure TWatcherHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TWatcherHS.UpdateExploration;
begin end;

procedure TWatcherHS.UpdateUnfog;
begin end;

procedure TWatcherHS.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TWatcherHS.Activate;
begin end;

procedure TWatcherHS.Deactivate;
begin end;

procedure TWatcherHS.VisibilityRange;
begin end;

function TWatcherHS.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TWatcherHS.RemoveFromMap;
begin end;

procedure TWatcherHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TWatcherHS.UpdateVisibleForSeatedPlayer;
begin end;

procedure TWatcherHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TWatcherHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

class function TWatcherTE.ClassID: Integer;
begin Result := 0; end;

procedure TWatcherTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TWatcher.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWatcher.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWatcher.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

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
