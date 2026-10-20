unit IndependentAG;

{ Draft declarations of IndependentAG, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TGuardAG = class;
  TGuardAGC = class;
  TGuardAreaAG = class;
  TGuardAreaAGC = class;
  TPatrolAG = class;
  TPatrolAGC = class;
  TRefugeAG = class;
  TRefugeAGC = class;
  TRaidAG = class;
  TRaidAGC = class;
  TScoutAG = class;
  TScoutAGC = class;


  { TGuardAG (instance size 80, VMT 557D7E5C) }
  TGuardAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TGuardAGC (instance size 368, VMT 557D7FB0) }
  TGuardAGC = class(TAIGroupControl)
  public
  end;

  { TGuardAreaAG (instance size 84, VMT 557D80A8) }
  TGuardAreaAG = class(TAIGroup)
  public
    F_GuardAreaAG_50: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TGuardAreaAGC (instance size 368, VMT 557D8204) }
  TGuardAreaAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone; override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
    procedure ProcessStatesLooped; override;
  end;

  { TPatrolAG (instance size 96, VMT 557D8304) }
  TPatrolAG = class(TAIGroup)
  public
    F_PatrolAG_50: Integer;
    F_PatrolAG_54: Integer;
    F_PatrolAG_58: Byte;
    F_PatrolAG_59: array[0..2] of Byte;
    F_PatrolAG_5C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TPatrolAGC (instance size 368, VMT 557D845C) }
  TPatrolAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone; override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
    procedure ResetPatrolToLocation;  { draft }
  end;

  { TRefugeAG (instance size 80, VMT 557D8554) }
  TRefugeAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TRefugeAGC (instance size 368, VMT 557D86AC) }
  TRefugeAGC = class(TAIGroupControl)
  public
  end;

  { TRaidAG (instance size 80, VMT 557D87A4) }
  TRaidAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TRaidAGC (instance size 368, VMT 557D88F4) }
  TRaidAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone; override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
  end;

  { TScoutAG (instance size 80, VMT 557D89E8) }
  TScoutAG = class(TAIGroup)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    procedure Behavior; override;
  end;

  { TScoutAGC (instance size 368, VMT 557D8B3C) }
  TScoutAGC = class(TAIGroupControl)
  public
    procedure MoveExecuterDone; override;
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
  end;


implementation

constructor TGuardAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TGuardAG.ClassID: Integer;
begin Result := 0; end;

procedure TGuardAG.Behavior;
begin end;

procedure TGuardAG.GroupControlClass;
begin end;

constructor TGuardAreaAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TGuardAreaAG.ClassID: Integer;
begin Result := 0; end;

procedure TGuardAreaAG.Behavior;
begin end;

procedure TGuardAreaAG.GroupControlClass;
begin end;

procedure TGuardAreaAG.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TGuardAreaAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TGuardAreaAGC.MoveExecuterDone;
begin end;

procedure TGuardAreaAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

procedure TGuardAreaAGC.ProcessStatesLooped;
begin end;

constructor TPatrolAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPatrolAG.ClassID: Integer;
begin Result := 0; end;

procedure TPatrolAG.Behavior;
begin end;

procedure TPatrolAG.GroupControlClass;
begin end;

procedure TPatrolAG.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPatrolAGC.ResetPatrolToLocation;
begin end;

procedure TPatrolAGC.MoveExecuterDone;
begin end;

procedure TPatrolAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPatrolAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

constructor TRefugeAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TRefugeAG.ClassID: Integer;
begin Result := 0; end;

procedure TRefugeAG.Behavior;
begin end;

procedure TRefugeAG.GroupControlClass;
begin end;

constructor TRaidAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TRaidAG.ClassID: Integer;
begin Result := 0; end;

procedure TRaidAG.Behavior;
begin end;

procedure TRaidAG.GroupControlClass;
begin end;

procedure TRaidAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRaidAGC.MoveExecuterDone;
begin end;

procedure TRaidAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

constructor TScoutAG.Create(AOwner: Engine.TECustomNode);
begin end;

class function TScoutAG.ClassID: Integer;
begin Result := 0; end;

procedure TScoutAG.Behavior;
begin end;

procedure TScoutAG.GroupControlClass;
begin end;

procedure TScoutAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TScoutAGC.MoveExecuterDone;
begin end;

procedure TScoutAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;


initialization
finalization

end.
