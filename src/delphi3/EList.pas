unit EList;

{ The EList unit of Enginep.dpl written for the original compiler (Delphi 3.02): TListObject, an
  object a TObjectList owns and streams, and TObjectList itself. Declarations follow the original
  instance layouts and VMT orders (data/classes.json); tools/match.py compares every method with
  the game's module. }

interface

uses
  Classes;

type
  TListObject = class;
  TListObjectClass = class of TListObject;

  { EList.TListObject (instance size 4): no fields. Create is virtual so that
    TObjectList.LoadFromStream can construct items from a class reference; the stream methods are
    empty here and overridden by the items. }
  TListObject = class(TObject)
  public
    constructor Create; virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
  end;

  { EList.TObjectList (instance size 16): a TList that owns its TListObjects. A slot may be nil;
    the stream format is the count followed by a nil flag per slot and the item's own data. }
  TObjectList = class(TList)
  private
    function GetListObject(Index: Integer): TListObject;
    procedure SetListObject(Index: Integer; Value: TListObject);
  public
    destructor Destroy; override;
    procedure DestroyItems;
    procedure LoadFromStream(Stream: TStream; AClass: TListObjectClass);
    procedure SaveToStream(Stream: TStream);
    property ListObjects[Index: Integer]: TListObject read GetListObject write SetListObject; default;
  end;

implementation

{ TListObject }

constructor TListObject.Create;
begin
  inherited Create;
end;

procedure TListObject.SaveToStream(Stream: TStream);
begin
end;

procedure TListObject.LoadFromStream(Stream: TStream);
begin
end;

{ TObjectList }

destructor TObjectList.Destroy;
begin
  DestroyItems;
  inherited Destroy;
end;

function TObjectList.GetListObject(Index: Integer): TListObject;
begin
  Result := TListObject(List^[Index]);
end;

procedure TObjectList.SetListObject(Index: Integer; Value: TListObject);
begin
  while Index >= Count do Add(nil);
  if List^[Index] <> nil then TListObject(List^[Index]).Destroy;
  List^[Index] := Value;
end;

procedure TObjectList.DestroyItems;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    if List^[I] <> nil then TListObject(List^[I]).Destroy;
    Delete(I);
  end;
end;

procedure TObjectList.LoadFromStream(Stream: TStream; AClass: TListObjectClass);
var
  N: Integer;
  IsNil: Boolean;
  I: Integer;
  Obj: TListObject;
begin
  DestroyItems;
  Stream.Read(N, SizeOf(N));
  for I := 0 to N - 1 do
  begin
    Stream.Read(IsNil, SizeOf(IsNil));
    if not IsNil then
    begin
      Obj := AClass.Create;
      Obj.LoadFromStream(Stream);
      Add(Obj);
    end
    else
      Add(nil);
  end;
end;

procedure TObjectList.SaveToStream(Stream: TStream);
var
  IsNil: Boolean;
  I: Integer;
begin
  Stream.Write(Count, SizeOf(Integer));
  for I := 0 to Count - 1 do
  begin
    IsNil := List^[I] = nil;
    Stream.Write(IsNil, SizeOf(IsNil));
    if not IsNil then TListObject(List^[I]).SaveToStream(Stream);
  end;
end;

end.
