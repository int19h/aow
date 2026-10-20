unit Altar;

{ Draft declarations of Altar, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TAltar = class;
  TAltarResource = class;

  TAltarMode = (amIdle, amRazed, amRebuilding);  { ot=1 }

  { TAltar (instance size 68, VMT 557CE7C4) }
  TAltar = class(TPlayerStructure)
  public
    F_Altar_3C: Integer;
    F_Altar_40: Byte;
    F_Altar_41: Byte;
    F_Altar_42: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    function ExecuteTE(A1: TStructureTE): TExecuteResult; override;
    procedure NewDay; override;
    function GetCurrentActivityText: string; override;
    procedure ExecuteAI(A1: Integer; A2: Integer); override;
    procedure SetPlayer(Player: Shortint); override;
    function GetDefaultAITargetPriority: Integer; override;
    procedure CreateStorm; virtual;  { +224 draft }
    procedure StormTargetSelected(A1: Integer; A2: Byte); virtual;  { +228 draft }
    procedure GetRechargeDays; virtual;  { +22C draft }
    procedure CanTarget(A1: Integer); virtual;  { +230 draft }
    procedure Target; virtual;  { +234 draft }
    procedure CancelTargeting; virtual;  { +238 draft }
    procedure TargetMana; virtual;  { +23C draft }
    procedure OnTargetSelectionChange(A1: Integer);  { draft }
    procedure GetTargeting;  { draft }
  end;

  { TAltarResource (instance size 116, VMT 557CEA6C) }
  TAltarResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltar;  { draft }

implementation

class function TAltar.ClassID: Integer;
begin Result := 0; end;

procedure TAltar.CreateStorm;
begin end;

function TAltar.GetDefaultAITargetPriority: Integer;
begin Result := 0; end;

function TAltar.GetCurrentActivityText: string;
begin end;

function TAltar.ExecuteTE(A1: TStructureTE): TExecuteResult;
begin Result := erRetry; end;

procedure TAltar.StormTargetSelected(A1: Integer; A2: Byte);
begin end;

procedure TAltar.OnTargetSelectionChange(A1: Integer);
begin end;

procedure TAltar.CanTarget(A1: Integer);
begin end;

procedure TAltar.Target;
begin end;

procedure TAltar.GetTargeting;
begin end;

procedure TAltar.CancelTargeting;
begin end;

procedure TAltar.GetRechargeDays;
begin end;

procedure TAltar.TargetMana;
begin end;

procedure TAltar.NewDay;
begin end;

procedure TAltar.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAltar.SetPlayer(Player: Shortint);
begin end;

function TAltar.GetRazed: Boolean;
begin end;

procedure TAltar.SetRazed(Value: Boolean);
begin end;

procedure TAltar.ExecuteAI(A1: Integer; A2: Integer);
begin end;

constructor TAltarResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAltarResource.ResourceEditName: string;
begin Result := ''; end;

class function TAltarResource.ClassID: Integer;
begin Result := 0; end;

function TAltarResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAltar;
begin end;


initialization
finalization

end.
