unit SummonSpells;

{ Draft declarations of SummonSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

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


  { TSummonSpellTE (instance size 36, VMT 557E2F28) }
  TSummonSpellTE = class(TSpellTE)
  public
    F_SummonSpellTE_20: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TSummonSpell (instance size 60, VMT 557E3004) }
  TSummonSpell = class(TSpell)
  public
    F_SummonSpell_34: array[0..7] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AIPrefetchCastSpellActions(A1: Integer; A2: Integer); override;
    procedure AIExecuteCastSpellAction(A1: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure SetupSummonSpellTE(A1: Integer); virtual;  { +09C draft }
    procedure GetDispelResistance(A1: Integer);  { draft }
    procedure GetAIUpkeepPriority;  { draft }
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
    procedure SetupSummonSpellTE(A1: Integer); override;
  end;

  { TSummonMermaid (instance size 60, VMT 557E3ED4) }
  TSummonMermaid = class(TSummonSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

procedure RegisterSummonSpells(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure UnregisterSummonSpells(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TSummonSpellTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSummonSpellTE.Destroy;
begin end;

class function TSummonSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TSummonSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSummonSpellTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TSummonSpell.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSummonSpell.Destroy;
begin end;

procedure TSummonSpell.GetDispelResistance(A1: Integer);
begin end;

procedure TSummonSpell.SetupSummonSpellTE(A1: Integer);
begin end;

procedure TSummonSpell.Activate(A1: Integer; A2: Integer);
begin end;

procedure TSummonSpell.GetAIUpkeepPriority;
begin end;

procedure TSummonSpell.AIPrefetchCastSpellActions(A1: Integer; A2: Integer);
begin end;

procedure TSummonSpell.AIExecuteCastSpellAction(A1: Integer);
begin end;

constructor TSummonSyron.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonFrog.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonBoar.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonAirElemental.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonEarthElemental.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonFireElemental.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonWaterElemental.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonGoldDragon.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonBlackDragon.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonGreatEagle.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonFireSprite.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSummonBlackSpider.SetupSummonSpellTE(A1: Integer);
begin end;

constructor TSummonBlackSpider.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSummonMermaid.Create(AOwner: Engine.TECustomNode);
begin end;

procedure RegisterSummonSpells(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure UnregisterSummonSpells(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
