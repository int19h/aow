unit CombatTE;

{ Draft declarations of CombatTE, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TCEndTurnTE = class;
  TCEndCombatTE = class;
  TCombatMoveTE = class;
  TCMeleeMoveTE = class;
  TCAbTouchMoveTE = class;
  TCAbRangedTE = class;
  TTerminateCombatTE = class;

  TTokenStep = (tokStart, tokEnd, tokFirstStrike, tokInitStrike, tokExeStrike, tokEndStrike, tokExeEndStrike, tokStepUp, tokDelayStrike);  { ot=1 }

  { TCEndTurnTE (instance size 16, VMT 00407548) }
  TCEndTurnTE = class(TTokenEvent)
  public
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TCEndCombatTE (instance size 16, VMT 0040760C) }
  TCEndCombatTE = class(TTokenEvent)
  public
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TCombatMoveTE (instance size 56, VMT 004076D4) }
  TCombatMoveTE = class(TMoveTE)
  public
    F_CombatMoveTE_1C: Integer;
    F_CombatMoveTE_20: Integer;
    F_CombatMoveTE_24: Integer;
    F_CombatMoveTE_28: Integer;
    F_CombatMoveTE_2C: Integer;
    F_CombatMoveTE_30: array[0..0] of Byte;
    F_CombatMoveTE_31: Byte;
    F_CombatMoveTE_32: array[0..1] of Byte;
    F_CombatMoveTE_34: Integer;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function GetMapF(Location: HSEngine.TXYL): AoWE.TAoWMapField; override;
    function Validate: Boolean; override;
    function DefaultMove: AoWE.TMoveStatus; override;
    function Setup(A1: Integer; A2: Integer): Byte; virtual;  { +070 draft }
    function ExecuteDefaultMove: Byte;  { draft }
  end;

  { TCMeleeMoveTE (instance size 64, VMT 004077C0) }
  TCMeleeMoveTE = class(TCombatMoveTE)
  public
    F_CMeleeMoveTE_38: Integer;
    F_CMeleeMoveTE_3C: Integer;
    class function ClassID: Integer; override;
    function LastMove: AoWE.TMoveStatus; override;
    procedure NextStrike;  { draft }
    procedure ExecuteStrike;  { draft }
  end;

  { TCAbTouchMoveTE (instance size 108, VMT 004078AC) }
  TCAbTouchMoveTE = class(TCombatMoveTE)
  public
    F_CAbTouchMoveTE_38: Integer;
    F_CAbTouchMoveTE_3C: Integer;
    F_CAbTouchMoveTE_40: Integer;
    F_CAbTouchMoveTE_44: Integer;
    F_CAbTouchMoveTE_48: Integer;
    F_CAbTouchMoveTE_4C: Integer;
    F_CAbTouchMoveTE_50: Integer;
    F_CAbTouchMoveTE_54: Integer;
    F_CAbTouchMoveTE_58: Integer;
    F_CAbTouchMoveTE_5C: Integer;
    F_CAbTouchMoveTE_60: Byte;
    F_CAbTouchMoveTE_61: Byte;
    F_CAbTouchMoveTE_62: array[0..1] of Byte;
    F_CAbTouchMoveTE_64: Integer;
    F_CAbTouchMoveTE_68: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function LastMove: AoWE.TMoveStatus; override;
  end;

  { TCAbRangedTE (instance size 60, VMT 0040799C) }
  TCAbRangedTE = class(TTokenEvent)
  public
    F_CAbRangedTE_10: Integer;
    F_CAbRangedTE_14: Integer;
    F_CAbRangedTE_18: Integer;
    F_CAbRangedTE_1C: Word;
    F_CAbRangedTE_1E: Word;
    F_CAbRangedTE_20: Word;
    F_CAbRangedTE_22: Word;
    F_CAbRangedTE_24: Byte;
    F_CAbRangedTE_25: array[0..2] of Byte;
    F_CAbRangedTE_28: Integer;
    F_CAbRangedTE_2C: Integer;
    F_CAbRangedTE_30: Integer;
    F_CAbRangedTE_34: Integer;
    F_CAbRangedTE_38: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure NextStrike(A1: Integer; A2: Integer);  { draft }
  end;

  { TTerminateCombatTE (instance size 16, VMT 00407A64) }
  TTerminateCombatTE = class(TTokenEvent)
  public
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

procedure MakeDEHSList(A1: Integer; A2: Integer; A3: Word; A4: Integer);  { draft }
function CreateTCEndCombatTE(A1: Integer; A2: Integer; A3: Integer): Integer;  { draft }
function CreateTCEndTurnTE(A1: Byte): Integer;  { draft }
function CreateTCCancelEndTurnTE(A1: Byte): Integer;  { draft }
procedure MakeHitBlood(A1: Integer; A2: Integer);  { draft }
function CreateTCMeleeMoveTE(A1: Integer; A2: Integer): Integer;  { draft }
function CreateTCAbTouchMoveTE(A1: Integer; A2: Integer; A3: Integer): Integer;  { draft }
function CreateTCAbRangedTE(A1: Integer; A2: Word; A3: Word; A4: Integer; A5: Integer): Integer;  { draft }
function CreateCombatMoveTE(A1: Integer; A2: Integer): Integer;  { draft }
function MoveCombatUnit(A1: Integer; A2: Integer): Byte;  { draft }
function SetupMultiTCUnitMove(A1: Integer): Byte;  { draft }
procedure RegisterCombatTE(A1: Integer);  { draft }

implementation

class function TTerminateCombatTE.ClassID: Integer;
begin Result := 0; end;

function TTerminateCombatTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TCEndCombatTE.ClassID: Integer;
begin Result := 0; end;

function TCEndCombatTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TCEndTurnTE.ClassID: Integer;
begin Result := 0; end;

function TCEndTurnTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TCombatMoveTE.ClassID: Integer;
begin Result := 0; end;

function TCombatMoveTE.GetMapF(Location: HSEngine.TXYL): AoWE.TAoWMapField;
begin FillChar(Result, SizeOf(Result), 0); end;

destructor TCombatMoveTE.Destroy;
begin end;

function TCombatMoveTE.Setup(A1: Integer; A2: Integer): Byte;
begin Result := 0; end;

function TCombatMoveTE.Validate: Boolean;
begin Result := False; end;

function TCombatMoveTE.ExecuteDefaultMove: Byte;
begin Result := 0; end;

function TCombatMoveTE.DefaultMove: AoWE.TMoveStatus;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TCMeleeMoveTE.ClassID: Integer;
begin Result := 0; end;

function TCMeleeMoveTE.LastMove: AoWE.TMoveStatus;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCMeleeMoveTE.NextStrike;
begin end;

procedure TCMeleeMoveTE.ExecuteStrike;
begin end;

class function TCAbTouchMoveTE.ClassID: Integer;
begin Result := 0; end;

procedure TCAbTouchMoveTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCAbTouchMoveTE.LastMove: AoWE.TMoveStatus;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TCAbRangedTE.ClassID: Integer;
begin Result := 0; end;

procedure TCAbRangedTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCAbRangedTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCAbRangedTE.NextStrike(A1: Integer; A2: Integer);
begin end;

procedure MakeDEHSList(A1: Integer; A2: Integer; A3: Word; A4: Integer);
begin end;

function CreateTCEndCombatTE(A1: Integer; A2: Integer; A3: Integer): Integer;
begin Result := 0; end;

function CreateTCEndTurnTE(A1: Byte): Integer;
begin Result := 0; end;

function CreateTCCancelEndTurnTE(A1: Byte): Integer;
begin Result := 0; end;

procedure MakeHitBlood(A1: Integer; A2: Integer);
begin end;

function CreateTCMeleeMoveTE(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

function CreateTCAbTouchMoveTE(A1: Integer; A2: Integer; A3: Integer): Integer;
begin Result := 0; end;

function CreateTCAbRangedTE(A1: Integer; A2: Word; A3: Word; A4: Integer; A5: Integer): Integer;
begin Result := 0; end;

function CreateCombatMoveTE(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

function MoveCombatUnit(A1: Integer; A2: Integer): Byte;
begin Result := 0; end;

function SetupMultiTCUnitMove(A1: Integer): Byte;
begin Result := 0; end;

procedure RegisterCombatTE(A1: Integer);
begin end;


initialization
finalization

end.
