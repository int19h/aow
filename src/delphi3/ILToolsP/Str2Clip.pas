unit Str2Clip;

{ Stream clipboard format from ILToolsP.dpl. }

interface

uses Windows, SysUtils, Classes, Forms;

function CopyStreamToClipboard(Stream: TStream; const Format: string): Integer;
function PasteStreamFromClipboard(Stream: TStream; const Format: string): Integer;

implementation

var ClipboardFormat: UINT;

function CopyStreamToClipboard(Stream: TStream; const Format: string): Integer;
var
  SavedPosition: Integer;
  H: THandle;
  P: PChar;
begin
  SavedPosition := Stream.Position;
  Result := -1;
  if OpenClipboard(Application.Handle) and (Format <> '') then
  try
    Stream.Position := 0;
    H := GlobalAlloc(GMEM_MOVEABLE, Length(Format) + 4 + 4 + Stream.Size);
    try
      P := GlobalLock(H);
      try
        PInteger(P)^ := Length(Format);
        Move(Pointer(Format)^, P[4], Length(Format));
        PInteger(P + 4 + Length(Format))^ := Stream.Size;
        Inc(P, 4);
        Stream.ReadBuffer(P[Length(Format) + 4], Stream.Size);
        SetClipboardData(ClipboardFormat, H);
        Result := Stream.Size;
      finally
        GlobalUnlock(H);
      end;
    except
      GlobalFree(H);
      raise;
    end;
  finally
    Stream.Position := SavedPosition;
    CloseClipboard;
  end;
end;

function PasteStreamFromClipboard(Stream: TStream; const Format: string): Integer;
var
  H: THandle;
  P: PChar;
  L: Integer;
  S: string;
begin
  Result := -1;
  if OpenClipboard(Application.Handle) then
  try
    H := GetClipboardData(ClipboardFormat);
    if H <> 0 then
    begin
      P := GlobalLock(H);
      try
        if GlobalSize(THandle(P)) > 4 then { Original passes the locked pointer as the handle. }
        begin
          L := PInteger(P)^;
          SetLength(S, L);
          Move(P[4], S[1], L);
          if S = Format then
          begin
            Inc(P, 4);
            P := PChar(L + Integer(P));
            L := PInteger(P)^;
            Stream.Position := 0;
            Stream.Size := L;
            Stream.WriteBuffer(P[4], L);
            Result := L;
            Stream.Position := 0;
          end;
        end;
      finally
        GlobalUnlock(H);
      end;
    end;
  finally
    CloseClipboard;
  end;
end;

initialization
  ClipboardFormat := RegisterClipboardFormat('ECLIPBOARD FORMAT');
finalization

end.
