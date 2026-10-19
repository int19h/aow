destructor TCustomAbilityList.Destroy;
begin
  SetAbCount(0);
  inherited Destroy;
end;

procedure TCustomAbilityList.SetAbCount(Value: Integer);
var
  OldBytes, NewBytes: Integer;
begin
  OldBytes := (FAbCount + 7) shr 3;
  NewBytes := (Value + 7) shr 3;
  ReallocMem(FAbSet, NewBytes);
  if NewBytes > OldBytes then
    FillChar((FAbSet + OldBytes)^, NewBytes - OldBytes, 0);
  FAbCount := Value;
end;

function TCustomAbilityList.GetAbSet(Index: Integer): Boolean;
begin
  Result := (Index >= 0) and (Index < FAbCount) and (((FAbSet + (Index shr 3))^ shr (Index and 7)) and 1 <> 0);
end;

procedure TCustomAbilityList.SetAbSet(Index: Integer; Value: Boolean);
var
  P: PByte;
begin
  if (Index < 0) or (Index >= FAbCount) then
    Exit;
  P := FAbSet + (Index shr 3);
  if Value then
    P^ := P^ or (1 shl (Index and 7))
  else
    P^ := P^ and not (1 shl (Index and 7));
end;

procedure TCustomAbilityList.ReadWrite(Stream: TEStorageStream);   { AoWE.TCustomAbilityList.ReadWrite }
var
  N: Integer;
begin
  if (Stream.StorageMode and (smCompare or smTranslate)) = 0 then
  begin
    if (Stream.StorageMode and smRead) = 0 then
    begin
      Stream.rwInteger(FAbCount, 2);
      Stream.rwData(FAbSet^, (FAbCount + 7) shr 3, 3);
    end
    else
    begin
      N := 0;
      Stream.rwInteger(N, 2);
      SetAbCount(N);
      Stream.rwData(FAbSet^, (FAbCount + 7) shr 3, 3);
    end;
  end;
  { the original then drops bits whose ability no longer exists in the game pack
    (AoWHSSet.AbilityControl.GetAbility); the model keeps the bits as read }
end;
