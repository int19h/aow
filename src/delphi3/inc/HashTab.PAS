{ The hash list and hash table classes of the Engine unit. The original keeps them in an include
  file, D:\GEngine\Engine\inc\HashTab.PAS: the Assert calls carry that file name, and line numbers
  counted from the start of Engine.pas (THashList.SetCapacity's Assert is at line 7127 there). The
  declarations are in the Engine.pas interface. }

destructor THashList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure THashList.Clear;
begin
  FCount := 0;
  SetCapacity(0);
end;

procedure THashList.SetCapacity(NewCapacity: Integer);
begin
  Assert(NewCapacity >= FCount, 'Capacity Error (THashList)');
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FItems, NewCapacity * SizeOf(THashItem));
    FCapacity := NewCapacity;
  end;
end;

procedure THashList.Delete(Index: Integer);
begin
  Assert((Index >= 0) and (Index < FCount), 'Delete Error (THashList)');
  Dec(FCount);
  if Index < FCount then
    Move(FItems^[Index + 1], FItems^[Index], (FCount - Index) * SizeOf(THashItem));
end;

procedure THashList.Add(Item: THashItem);
begin
  if FCapacity = FCount then SetCapacity(FCapacity + 16);
  FItems^[FCount] := Item;
  Inc(FCount);
end;

procedure TIntegerHashList.Add(Item: Pointer; Key: Integer);
var
  H: THashItem;
begin
  if Find(Key) <> nil then raise Exception.Create('ID already in HashTable');
  Assert(Item <> nil, 'Cannot add nil item to hash table');
  H.Key := Key;
  H.Item := Item;
  inherited Add(H);
end;

procedure TIntegerHashList.Delete(Key: Integer);
var
  I: Integer;
begin
  I := FCount;
  if I <> 0 then
    repeat
      Dec(I);
      if Key = FItems^[I].Key then
      begin
        inherited Delete(I);
        Exit;
      end;
    until I = 0;
end;

function TIntegerHashList.Find(Key: Integer): Pointer;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if Key = FItems^[I].Key then
    begin
      Result := FItems^[I].Item;
      Exit;
    end;
  Result := nil;
end;

constructor TIntegerHashTable256.Create;
var
  I: Integer;
begin
  inherited Create;
  for I := 0 to 255 do FLists[I] := TIntegerHashList.Create;
end;

destructor TIntegerHashTable256.Destroy;
var
  I: Integer;
begin
  for I := 0 to 255 do FLists[I].Free;
  inherited Destroy;
end;

procedure TIntegerHashTable256.Clear;
var
  I: Integer;
begin
  for I := 0 to 255 do FLists[I].Clear;
end;

procedure TIntegerHashTable256.Add(Item: Pointer; Key: Integer);
begin
  FLists[Key and $FF].Add(Item, Key);
end;

procedure TIntegerHashTable256.Delete(Key: Integer);
begin
  FLists[Key and $FF].Delete(Key);
end;

function TIntegerHashTable256.Find(Key: Integer): Pointer;
begin
  Result := FLists[Key and $FF].Find(Key);
end;

procedure TIntegerHashTable256.DeleteSafe(Item: Pointer; Key: Integer);
begin
  if FLists[Key and $FF].Find(Key) = Item then FLists[Key and $FF].Delete(Key);
end;

function TIntegerHashTable256.GetFreeID: Integer;
var
  Min, MinIndex, I: Integer;
begin
  Min := $FFFFFF;
  MinIndex := 0;
  for I := 0 to 255 do
    if Min > FLists[I].Count then
    begin
      Min := FLists[I].Count;
      MinIndex := I;
    end;
  I := FLists[MinIndex].Count;
  while FLists[MinIndex].Find(I shl 8 + MinIndex) <> nil do Inc(I);
  Result := I shl 8 + MinIndex;
end;
