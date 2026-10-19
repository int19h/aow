program asgread;

{ Reads a save or map file with the recovered Engine unit and prints the same facts that
  tools/asg_dump.py prints, so that the Pascal and the Python readers can be compared.

  Usage: asgread <file.asg|hsm>
  Build: fpc -Mdelphi -Fu..\src\recovered asgread.pas }

{$MODE DELPHI}{$H+}

uses
  SysUtils, Classes, Engine;

const
  ClassID_TAoWHSMap = 131089;
  ClassID_TPlayer = 131104;

type
  { A generic object that records which property ids its table holds. }
  TProbeObject = class(TEObject)
  public
    Name: string;
    IDs: string;
    procedure ReadWrite(Stream: TEStorageStream); override;
  end;

  { A node: after its own properties the children follow under id 1 (TECustomNode.MainReadWrite).
    TENode supplies the child list; rwCreateEObject attaches children through SetOwner. }
  TProbeNode = class(TENode)
  public
    Name: string;
    IDs: string;
    procedure ReadWrite(Stream: TEStorageStream); override;
    { embedded lists are shared children of their owner: Clear empties them instead of freeing them }
    function GetControlStyle: Byte; override;
  end;

  TPlayerProbe = class(TProbeObject)
  public
    Race: Byte;
    Gold, Gems: Integer;
    Name2: string;
    procedure ReadWrite(Stream: TEStorageStream); override;
  end;

  TMapProbe = class(TProbeNode)
  public
    ScenarioSet, MapName: string;
    Width, Height: Integer;
    PlayerList: TProbeNode;
    constructor Create(AOwner: TEObject); override;
    procedure ReadWrite(Stream: TEStorageStream); override;
  end;

  TProbeEngine = class(TEngine)
  public
    function CreateEObject(AClassID: Integer; AOwner: TEObject): TEObject; override;
  end;

  { TPlayer and TMapProbe are nodes in the original (TPlayer descends from TENode through TEObject?
    no: TPlayer is a TEObject with lists inside; the player list is the node). }

function TableIDs(Stream: TEStorageStream): string;
var
  T: TPropertyTable;
  I: Integer;
begin
  Result := '';
  if not (Stream is TEReadStorageStream) then
    Exit;
  T := TEReadStorageStream(Stream).PropertyTable;
  for I := T.First to T.Count - 1 do
    Result := Result + IntToStr(T.Items^[I].ID) + ' ';
end;

procedure TProbeObject.ReadWrite(Stream: TEStorageStream);
begin
  IDs := TableIDs(Stream);
end;

procedure TProbeNode.ReadWrite(Stream: TEStorageStream);
begin
  IDs := TableIDs(Stream);
end;

function TProbeNode.GetControlStyle: Byte;
begin
  Result := csStored or csShared;
end;

procedure TPlayerProbe.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Race, 2);        { TPlayer +$A5, id 2 }
  Stream.rwInteger(Gold, 5);     { TPlayer +$AC, id 5 }
  Stream.rwInteger(Gems, $10);   { TPlayer +$C4, id $10 (named FGems by its getter) }
  Stream.rwString(Name2, $18);   { TPlayer +$30, id $18 }
end;

constructor TMapProbe.Create(AOwner: TEObject);
begin
  inherited Create(AOwner);
  PlayerList := TProbeNode.Create(Self);
end;

procedure TMapProbe.ReadWrite(Stream: TEStorageStream);
var
  Flag: Byte;
begin
  inherited ReadWrite(Stream);
  Stream.rwData(Flag, 1, $1F);          { TAoWHSMap +$13A: first call in ReadWrite }
  Stream.rwString(ScenarioSet, 2);      { THSMap +$38 }
  Stream.rwInteger(Width, 4);           { THSMap +$80 }
  Stream.rwInteger(Height, 5);          { THSMap +$84 }
  Stream.rwString(MapName, $19);        { TAoWHSMap +$E4 }
  Stream.rwEObject(PlayerList, $15);    { TAoWHSMap +$140 FPlayerList }
end;

function TProbeEngine.CreateEObject(AClassID: Integer; AOwner: TEObject): TEObject;
begin
  case AClassID of
    ClassID_TAoWHSMap: Result := TMapProbe.Create(AOwner);
    ClassID_TPlayer: Result := TPlayerProbe.Create(AOwner);
  else
    Result := TProbeObject.Create(AOwner);
  end;
  if Result is TProbeObject then
    TProbeObject(Result).Name := 'class ' + IntToStr(AClassID)
  else if Result is TProbeNode then
    TProbeNode(Result).Name := 'class ' + IntToStr(AClassID);
end;

var
  Data: TCompressStream;
  Header: packed record
    Size: Integer;
    ID: array[0..3] of AnsiChar;
    Reserved: Integer;
    RootClassID: Integer;
  end;
  Reader: TEReadStorageStream;
  EngineObj: TProbeEngine;
  Root: TEObject;
  Map: TMapProbe;
  I: Integer;
  P: TPlayerProbe;
begin
  if ParamCount < 1 then
  begin
    Writeln('usage: asgread <file.asg|hsm>');
    Halt(1);
  end;
  Data := TCompressStream.Create;
  Data.LoadFromFile(ParamStr(1));
  Writeln('inflated ', Data.Size, ' bytes');
  Data.Read(Header, SizeOf(Header));
  Writeln('header: size=', Header.Size, ' id=', Header.ID, ' classid=', Header.RootClassID);
  Data.Position := Header.Size;
  EngineObj := TProbeEngine.Create(nil);
  Reader := TEReadStorageStream.Create(Data, False, EngineObj);
  Root := EngineObj.CreateEObject(Header.RootClassID, nil);
  Reader.rwEObject(Root, 0);
  if Root is TMapProbe then
  begin
    Map := TMapProbe(Root);
    Writeln('map ids: ', Map.IDs);
    Writeln('scenario set: ', Map.ScenarioSet);
    Writeln('size: ', Map.Width, ' x ', Map.Height);
    Writeln('name: ', Map.MapName);
    Writeln('players: ', Map.PlayerList.Count);
    for I := 0 to Map.PlayerList.Count - 1 do
    begin
      P := TPlayerProbe(Map.PlayerList.Children[I]);
      Writeln('  player ', I, ': race=', P.Race, ' gold=', P.Gold, ' gems=', P.Gems, ' name=', P.Name2, '  ids: ', P.IDs);
    end;
  end;
  Reader.Free;
  Root.Free;
  EngineObj.Free;
  Data.Free;
end.
