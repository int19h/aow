unit Sign;

{ Draft declarations of Sign, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TSign = class;
  TSignResource = class;
  TUpdateSignTE = class;


  { TSign (instance size 56, VMT 557A4098) }
  TSign = class(TStructure)
  public
    F_Sign_30: Integer;
    F_Sign_34: array[0..3] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure Select; override;
    procedure GetTextSeen(A1: Byte);  { draft }
    procedure SetText;  { draft }
    procedure CanChangeText;  { draft }
    procedure ChangeText(A1: Integer; A2: Integer);  { draft }
  end;

  { TSignResource (instance size 100, VMT 557A42EC) }
  TSignResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TUpdateSignTE (instance size 24, VMT 557A43DC) }
  TUpdateSignTE = class(TTokenEvent)
  public
    F_UpdateSignTE_10: Integer;
    F_UpdateSignTE_14: Byte;
    F_UpdateSignTE_15: Byte;
    F_UpdateSignTE_16: Byte;
    F_UpdateSignTE_17: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

procedure RegisterSign;  { draft }

implementation

constructor TSign.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSign.Destroy;
begin end;

class function TSign.ClassID: Integer;
begin Result := 0; end;

function TSign.GetOverlay(Index: Integer): Shortint;
begin Result := 0; end;

procedure TSign.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSign.GetTextSeen(A1: Byte);
begin end;

procedure TSign.SetText;
begin end;

procedure TSign.Select;
begin end;

procedure TSign.CanChangeText;
begin end;

procedure TSign.ChangeText(A1: Integer; A2: Integer);
begin end;

constructor TSignResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSignResource.ClassID: Integer;
begin Result := 0; end;

class function TSignResource.ResourceEditName: string;
begin Result := ''; end;

function TSignResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TSignResource.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TUpdateSignTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TUpdateSignTE.Destroy;
begin end;

class function TUpdateSignTE.ClassID: Integer;
begin Result := 0; end;

procedure TUpdateSignTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TUpdateSignTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure RegisterSign;
begin end;


initialization
finalization

end.
