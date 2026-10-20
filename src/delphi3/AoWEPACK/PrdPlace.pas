unit PrdPlace;

{ Draft declarations of PrdPlace, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TProductionPlaceControl = class;
  TProductionPlace = class;
  TProductionPlaceResource = class;
  TProductionPlaceEventLog = class;


  { TProductionPlaceControl (instance size 44, VMT 557BD4D0) }
  TProductionPlaceControl = class(TProductionControl)
  public
    F_ProductionPlaceControl_28: array[0..3] of Byte;
    procedure ExecuteProduction(A1: Integer); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetPlayer; override;
    procedure UnitProduced; override;
    procedure UnitResearched; override;
    procedure Update; override;
    procedure NewTurn(A1: Integer); override;
    procedure CanExecuteProduction(A1: Integer; A2: Integer); override;
    procedure GetProductionName(A1: Integer; A2: Integer); override;
    procedure GetProductionNameProgressive(A1: Integer; A2: Integer); override;
    procedure UnitProductionGold(A1: Integer); override;
    procedure UnitProductionMana(A1: Integer); override;
    procedure UnitProductionGoldUpkeep(A1: Integer); override;
    procedure UnitProductionManaUpkeep(A1: Integer); override;
    procedure UnitProductionTime(A1: Integer); override;
  end;

  { TProductionPlace (instance size 76, VMT 557BD68C) }
  TProductionPlace = class(TPlayerStructure)
  public
    F_ProductionPlace_3C: array[0..7] of Byte;
    F_ProductionPlace_44: Integer;
    F_ProductionPlace_48: Byte;
    F_ProductionPlace_49: Byte;
    F_ProductionPlace_4A: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure Select; override;
    procedure SetRazed(A1: Integer); override;
    procedure GetRazed; override;
    procedure NewDay; override;
    procedure NewTurn(A1: Integer); override;
    procedure BuildingDone; override;
    procedure GetCurrentActivityText(A1: Integer); override;
    procedure UpdateAITarget(A1: Integer; A2: Integer); override;
    procedure Update; override;
    procedure CanDblClick; override;
    procedure SetPlayer(A1: Integer; A2: Integer); override;
    procedure GetIncome(A1: Integer; A2: Integer); override;
    procedure GetPower; override;
    procedure StructureCaptured(A1: Integer; A2: Byte); override;
    procedure CreateProductionControl; virtual;  { +224 draft }
    procedure GenerateDefenders; virtual;  { +228 draft }
    procedure GetBaseIncome; virtual;  { +22C draft }
    procedure GetMagicSphere; virtual;  { +230 draft }
    procedure GetProductionName(A1: Integer; A2: Integer); virtual;  { +234 draft }
    procedure GetProductionNameProgressive(A1: Integer; A2: Integer); virtual;  { +238 draft }
    procedure ListIncomeInfo(A1: Integer; A2: Integer); virtual;  { +23C draft }
    procedure MasterySpellCast(A1: Integer; A2: Integer);  { draft }
    procedure CanProduce(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure Produce;  { draft }
    procedure ProductionGold;  { draft }
    procedure ProductionMana;  { draft }
    procedure ProductionTime;  { draft }
    procedure CanResearch(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure Research;  { draft }
    procedure ResearchGold;  { draft }
    procedure ResearchMana;  { draft }
    procedure ResearchTime;  { draft }
    procedure CanTrade(A1: Integer; A2: Integer);  { draft }
    procedure Trade(A1: Integer);  { draft }
    procedure ResetProductions;  { draft }
  end;

  { TProductionPlaceResource (instance size 120, VMT 557BD94C) }
  TProductionPlaceResource = class(TPlayerStructureResource)
  public
    F_ProductionPlaceResource_74: array[0..3] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Editor: TClass; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TProductionPlaceEventLog (instance size 32, VMT 557BDA5C) }
  TProductionPlaceEventLog = class(TProductionEventLog)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetProductionPlace;  { draft }
  end;

procedure RegisterProductionPlace;  { draft }

implementation

procedure TProductionPlaceControl.UnitProductionTime(A1: Integer);
begin end;

procedure TProductionPlaceControl.UnitProductionGold(A1: Integer);
begin end;

procedure TProductionPlaceControl.UnitProductionMana(A1: Integer);
begin end;

procedure TProductionPlaceControl.UnitProductionGoldUpkeep(A1: Integer);
begin end;

procedure TProductionPlaceControl.UnitProductionManaUpkeep(A1: Integer);
begin end;

procedure TProductionPlaceControl.GetPlayer;
begin end;

procedure TProductionPlaceControl.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TProductionPlaceControl.UnitProduced;
begin end;

procedure TProductionPlaceControl.UnitResearched;
begin end;

procedure TProductionPlaceControl.Update;
begin end;

procedure TProductionPlaceControl.CanExecuteProduction(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlaceControl.NewTurn(A1: Integer);
begin end;

procedure TProductionPlaceControl.ExecuteProduction(A1: Integer);
begin end;

procedure TProductionPlaceControl.GetProductionName(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlaceControl.GetProductionNameProgressive(A1: Integer; A2: Integer);
begin end;

constructor TProductionPlace.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TProductionPlace.Destroy;
begin end;

class function TProductionPlace.ClassID: Integer;
begin Result := 0; end;

procedure TProductionPlace.CanDblClick;
begin end;

procedure TProductionPlace.CreateProductionControl;
begin end;

procedure TProductionPlace.GetMagicSphere;
begin end;

procedure TProductionPlace.MasterySpellCast(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlace.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TProductionPlace.GetPower;
begin end;

procedure TProductionPlace.GetBaseIncome;
begin end;

procedure TProductionPlace.GetIncome(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlace.GetRazed;
begin end;

procedure TProductionPlace.SetRazed(A1: Integer);
begin end;

procedure TProductionPlace.ListIncomeInfo(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlace.GetCurrentActivityText(A1: Integer);
begin end;

procedure TProductionPlace.GetProductionName(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlace.GetProductionNameProgressive(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlace.CanProduce(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TProductionPlace.Produce;
begin end;

procedure TProductionPlace.ProductionGold;
begin end;

procedure TProductionPlace.ProductionMana;
begin end;

procedure TProductionPlace.ProductionTime;
begin end;

procedure TProductionPlace.CanResearch(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TProductionPlace.Research;
begin end;

procedure TProductionPlace.ResearchGold;
begin end;

procedure TProductionPlace.ResearchMana;
begin end;

procedure TProductionPlace.ResearchTime;
begin end;

procedure TProductionPlace.CanTrade(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlace.Trade(A1: Integer);
begin end;

procedure TProductionPlace.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TProductionPlace.Update;
begin end;

procedure TProductionPlace.StructureCaptured(A1: Integer; A2: Byte);
begin end;

procedure TProductionPlace.Activate;
begin end;

procedure TProductionPlace.Deactivate;
begin end;

procedure TProductionPlace.SetPlayer(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlace.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

procedure TProductionPlace.GenerateDefenders;
begin end;

procedure TProductionPlace.NewDay;
begin end;

procedure TProductionPlace.BuildingDone;
begin end;

procedure TProductionPlace.ResetProductions;
begin end;

procedure TProductionPlace.NewTurn(A1: Integer);
begin end;

procedure TProductionPlace.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TProductionPlace.Select;
begin end;

constructor TProductionPlaceResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TProductionPlaceResource.Destroy;
begin end;

class function TProductionPlaceResource.ResourceEditName: string;
begin Result := ''; end;

class function TProductionPlaceResource.ClassID: Integer;
begin Result := 0; end;

function TProductionPlaceResource.ResourceUserClassID: Integer;
begin Result := 0; end;

function TProductionPlaceResource.Editor: TClass;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TProductionPlaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function TProductionPlaceEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TProductionPlaceEventLog.GetProductionPlace;
begin end;

procedure TProductionPlaceEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure RegisterProductionPlace;
begin end;


initialization
finalization

end.
