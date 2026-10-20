unit WizardsTower;

{ Draft declarations of WizardsTower, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  TWizardsTower = class;
  TWizardsTowerResource = class;
  TEnterWizardsTowerEventLog = class;


  { TWizardsTower (instance size 56, VMT 557D5508) }
  TWizardsTower = class(TStructure)
  public
    F_WizardsTower_30: Byte;
    F_WizardsTower_31: Byte;
    F_WizardsTower_32: array[0..0] of Byte;
    F_WizardsTower_33: Byte;
    F_WizardsTower_34: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function ExecuteTE(A1: TStructureTE): TExecuteResult; override;
    procedure NewDay; override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    function CanDblClick: Boolean; override;
    procedure ValidAITarget(A1: Integer);  { draft }
    procedure GenerateSettings;  { draft }
    procedure CanEnter(A1: Integer);  { draft }
    procedure Enter;  { draft }
    procedure BuyCost;  { draft }
    procedure CanBuy(A1: Integer; A2: Integer);  { draft }
    procedure Buy(A1: Integer; A2: Integer);  { draft }
  end;

  { TWizardsTowerResource (instance size 100, VMT 557D5774) }
  TWizardsTowerResource = class(TStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TEnterWizardsTowerEventLog (instance size 28, VMT 557D587C) }
  TEnterWizardsTowerEventLog = class(TEventLog)
  public
    F_EnterWizardsTowerEventLog_18: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

procedure RegisterWizardsTower;  { draft }

implementation

constructor TEnterWizardsTowerEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TEnterWizardsTowerEventLog.Destroy;
begin end;

constructor TWizardsTower.Create(AOwner: Engine.TECustomNode);
begin end;

class function TWizardsTower.ClassID: Integer;
begin Result := 0; end;

procedure TWizardsTower.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TWizardsTower.CanDblClick: Boolean;
begin end;

procedure TWizardsTower.ValidAITarget(A1: Integer);
begin end;

procedure TWizardsTower.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
begin end;

procedure TWizardsTower.ArmyPlaced(A1: Integer);
begin end;

procedure TWizardsTower.GenerateSettings;
begin end;

procedure TWizardsTower.NewDay;
begin end;

procedure TWizardsTower.CanEnter(A1: Integer);
begin end;

procedure TWizardsTower.Enter;
begin end;

function TWizardsTower.ExecuteTE(A1: TStructureTE): TExecuteResult;
begin Result := erRetry; end;

procedure TWizardsTower.BuyCost;
begin end;

procedure TWizardsTower.CanBuy(A1: Integer; A2: Integer);
begin end;

procedure TWizardsTower.Buy(A1: Integer; A2: Integer);
begin end;

class function TWizardsTowerResource.ResourceEditName: string;
begin Result := ''; end;

class function TWizardsTowerResource.ClassID: Integer;
begin Result := 0; end;

function TWizardsTowerResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterWizardsTower;
begin end;


initialization
finalization

end.
