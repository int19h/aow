unit GlobalSpells;

{ Draft declarations of GlobalSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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


  { TConcealAreaHS (instance size 24, VMT 557E8FBC) }
  TConcealAreaHS = class(TFixedVisibleHS)
  public
    F_ConcealAreaHS_0C: Byte;
    F_ConcealAreaHS_0D: Byte;
    F_ConcealAreaHS_0E: Byte;
    F_ConcealAreaHS_0F: array[0..0] of Byte;
    F_ConcealAreaHS_10: Integer;
    F_ConcealAreaHS_14: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure StartAnimation(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure StopAnimation;  { draft }
  end;

  { TConcealArea (instance size 52, VMT 557E9144) }
  TConcealArea = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetEnabled; override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
  end;

  { TBirdsViewHS (instance size 24, VMT 557E925C) }
  TBirdsViewHS = class(TFixedVisibleHS)
  public
    F_BirdsViewHS_0C: Byte;
    F_BirdsViewHS_0D: Byte;
    F_BirdsViewHS_0E: Byte;
    F_BirdsViewHS_0F: array[0..0] of Byte;
    F_BirdsViewHS_10: Integer;
    F_BirdsViewHS_14: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure StartAnimation(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure StopAnimation;  { draft }
  end;

  { TBirdsView (instance size 52, VMT 557E93E0) }
  TBirdsView = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetEnabled; override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
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
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TWarpParty (instance size 52, VMT 557E95CC) }
  TWarpParty = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure ValidTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CalculateWarpLocation(A1: Integer);  { draft }
  end;

  { TResurrectHero (instance size 52, VMT 557E96E0) }
  TResurrectHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
  end;

  { TAnimateHero (instance size 52, VMT 557E97FC) }
  TAnimateHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
  end;

  { TCallHero (instance size 52, VMT 557E9914) }
  TCallHero = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure FindCallHero(A1: Integer);  { draft }
  end;

  { TDisjunctionTE (instance size 40, VMT 557E9A24) }
  TDisjunctionTE = class(TSpellTE)
  public
    F_DisjunctionTE_20: Integer;
    F_DisjunctionTE_24: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TDisjunctionSpellCaster (instance size 28, VMT 557E9B00) }
  TDisjunctionSpellCaster = class(TSpellCaster)
  public
    F_DisjunctionSpellCaster_14: Integer;
    F_DisjunctionSpellCaster_18: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanCast(A1: Integer); override;
    procedure Cast; override;
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
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
  end;

  { TCrusade (instance size 52, VMT 557E9CFC) }
  TCrusade = class(TSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure PlaceParty(A1: Integer; A2: Integer);  { draft }
  end;

procedure RegisterGlobalSpells(A1: Integer);  { draft }
procedure UnregisterGlobalSpells(A1: Integer);  { draft }

implementation

constructor TConcealAreaHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TConcealAreaHS.Destroy;
begin end;

function TConcealAreaHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TConcealAreaHS.StartAnimation(A1: Byte; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TConcealAreaHS.StopAnimation;
begin end;

procedure TConcealAreaHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TConcealArea.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TConcealArea.GetEnabled;
begin end;

procedure TConcealArea.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TConcealArea.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TConcealArea.Activate(A1: Integer; A2: Integer);
begin end;

constructor TBirdsViewHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TBirdsViewHS.Destroy;
begin end;

function TBirdsViewHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TBirdsViewHS.StartAnimation(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TBirdsViewHS.StopAnimation;
begin end;

procedure TBirdsViewHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TBirdsView.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TBirdsView.GetEnabled;
begin end;

procedure TBirdsView.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TBirdsView.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TBirdsView.Activate(A1: Integer; A2: Integer);
begin end;

constructor TWarpPartyTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TWarpPartyTE.Destroy;
begin end;

class function TWarpPartyTE.ClassID: Integer;
begin Result := 0; end;

procedure TWarpPartyTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TWarpPartyTE.Validate(A1: Integer);
begin end;

procedure TWarpPartyTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TWarpParty.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWarpParty.ValidTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWarpParty.CalculateWarpLocation(A1: Integer);
begin end;

procedure TWarpParty.Activate(A1: Integer; A2: Integer);
begin end;

class function TDisjunctionTE.ClassID: Integer;
begin Result := 0; end;

procedure TDisjunctionTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TDisjunctionTE.Validate(A1: Integer);
begin end;

procedure TDisjunctionTE.Process(A1: Integer; A2: Integer);
begin end;

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

procedure TDisjunctionSpellCaster.CanCast(A1: Integer);
begin end;

procedure TDisjunctionSpellCaster.Cast;
begin end;

constructor TDisjunction.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDisjunction.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TDisjunction.Activate(A1: Integer; A2: Integer);
begin end;

constructor TResurrectHero.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TResurrectHero.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TResurrectHero.Activate(A1: Integer; A2: Integer);
begin end;

constructor TAnimateHero.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAnimateHero.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAnimateHero.Activate(A1: Integer; A2: Integer);
begin end;

constructor TCallHero.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCallHero.Activate(A1: Integer; A2: Integer);
begin end;

procedure TCallHero.FindCallHero(A1: Integer);
begin end;

procedure TCallHero.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TCrusade.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCrusade.PlaceParty(A1: Integer; A2: Integer);
begin end;

procedure TCrusade.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCrusade.Activate(A1: Integer; A2: Integer);
begin end;

procedure RegisterGlobalSpells(A1: Integer);
begin end;

procedure UnregisterGlobalSpells(A1: Integer);
begin end;


initialization
finalization

end.
