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
  P: PChar; DataSize: Integer;
begin
  SavedPosition := Stream.Position;
  Result := -1;
  if OpenClipboard(Application.Handle) and (Format <> '') then
  try
    Stream.Position := 0;
    DataSize := Length(Format) + 4 + 4 + Stream.Size; H := GlobalAlloc(GMEM_MOVEABLE, DataSize);
    try
      P := GlobalLock(H);
      try
        PInteger(P)^ := Length(Format);
        {$R+} Move(Format[1], P[4], Length(Format)); {$R-} { R+ retains the original first-character address calculation. }
        PInteger(P + 4 + Length(Format))^ := Stream.Size;
        { Buffer address contains both length words. }
        Stream.ReadBuffer(PChar(Length(Format) + (Integer(P) + 4) + 4)^, Stream.Size);
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
  S: string; Size: Integer;
begin
  Result := -1;
  if OpenClipboard(Application.Handle) then
  try
    H := GetClipboardData(ClipboardFormat);
    if H <> 0 then
    begin
      P := GlobalLock(H);
      try
        Size := GlobalSize(THandle(P)); if Size > 4 then { Original passes the locked pointer as the handle. }
        begin
          L := PInteger(P)^;
          SetLength(S, L);
          {$R+} Move(P[4], S[1], L); {$R-} { R+ retains the original first-character address calculation. }
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
