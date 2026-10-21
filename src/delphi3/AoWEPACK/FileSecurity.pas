unit FileSecurity;

{ FileSecurity, from AoWEPACK.dpl. Security trailers use a $6A-byte data record
  and a $0C-byte footer containing CRC32, size and the SDID signature.
  The four unnamed helpers follow PageTurnCtrl's finalization in code order. }

interface

uses
  Windows, SysUtils, Classes, Engine;

function GetFileSecurityID(const FileName: string; var ID: string): Boolean;
function SetFileSecurityID(const FileName, ID: string): Boolean;
function RemoveFileSecurityID(const FileName: string): Boolean;

implementation

type
  TSecurityData = packed record
    Reserved00: Integer;
    Key: Byte;
    ID: string[50];
    Reserved38: array[0..49] of Byte;
  end;
  TSecurityFooter = packed record
    CRC: Integer;
    Size: DWORD;
    Signature: array[0..3] of Char;
  end;

function EncodeSecurityID(Value: string; Key: Byte): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Value) do
    Result := Result + Char(Byte((Length(Value) + (I + 5) + Key) and $FF) xor Byte(Value[I]));
end;

function ReadSecurityData(const FileName: string; var Data: TSecurityData): Boolean;
var
  BytesRead: DWORD;
  Footer: TSecurityFooter;
  Handle: THandle;
begin
  Result := False;
  FillChar(Data, SizeOf(Data), 0);
  Handle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  SetFilePointer(Handle, -SizeOf(Footer), nil, FILE_END);
  if ReadFile(Handle, Footer, SizeOf(Footer), BytesRead, nil) and
    (BytesRead = SizeOf(Footer)) and (string(Footer.Signature) = 'SDID') then
  begin
    SetFilePointer(Handle, -Integer(Footer.Size + SizeOf(Footer)), nil, FILE_END);
    { Original trusts the footer size when reading this fixed-size buffer. }
    if ReadFile(Handle, Data, Footer.Size, BytesRead, nil) and
      (BytesRead = Footer.Size) and (GetCRC32(@Data, Footer.Size) = Footer.CRC) then
      Result := True;
  end;
  CloseHandle(Handle);
end;

function WriteSecurityData(const FileName: string; const Data: TSecurityData): Boolean;
var
  CreationTime, AccessTime, WriteTime: TFileTime;
  BytesRead, BytesWritten: DWORD;
  Footer: TSecurityFooter;
  OldData: TSecurityData;
  Handle: THandle;
  OldSize: Integer;
begin
  Result := False;
  Handle := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  GetFileTime(Handle, @CreationTime, @AccessTime, @WriteTime);
  OldSize := 0;
  SetFilePointer(Handle, -SizeOf(Footer), nil, FILE_END);
  if ReadFile(Handle, Footer, SizeOf(Footer), BytesRead, nil) and
    (BytesRead = SizeOf(Footer)) and (string(Footer.Signature) = 'SDID') then
  begin
    SetFilePointer(Handle, -Integer(Footer.Size + SizeOf(Footer)), nil, FILE_END);
    { Original trusts the footer size when reading this fixed-size buffer. }
    if ReadFile(Handle, OldData, Footer.Size, BytesRead, nil) and
      (BytesRead = Footer.Size) and (GetCRC32(@OldData, Footer.Size) = Footer.CRC) then
      OldSize := Footer.Size + SizeOf(Footer);
  end;
  SetFilePointer(Handle, -OldSize, nil, FILE_END);
  if WriteFile(Handle, Data, SizeOf(Data), BytesWritten, nil) then
  begin
    Footer.Size := SizeOf(Data);
    Footer.CRC := GetCRC32(@Data, SizeOf(Data));
    Footer.Signature := 'SDID';
    Result := WriteFile(Handle, Footer, SizeOf(Footer), BytesWritten, nil);
  end;
  SetFileTime(Handle, @CreationTime, @AccessTime, @WriteTime);
  CloseHandle(Handle);
end;

function RemoveSecurityData(const FileName: string): Boolean;
var
  CreationTime, AccessTime, WriteTime: TFileTime;
  BytesRead: DWORD;
  Footer: TSecurityFooter;
  OldData: TSecurityData;
  Handle: THandle;
  OldSize: Integer;
begin
  Result := False;
  Handle := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  GetFileTime(Handle, @CreationTime, @AccessTime, @WriteTime);
  OldSize := 0;
  SetFilePointer(Handle, -SizeOf(Footer), nil, FILE_END);
  if ReadFile(Handle, Footer, SizeOf(Footer), BytesRead, nil) and
    (BytesRead = SizeOf(Footer)) and (string(Footer.Signature) = 'SDID') then
  begin
    SetFilePointer(Handle, -Integer(Footer.Size + SizeOf(Footer)), nil, FILE_END);
    { Original trusts the footer size when reading this fixed-size buffer. }
    if ReadFile(Handle, OldData, Footer.Size, BytesRead, nil) and
      (BytesRead = Footer.Size) and (GetCRC32(@OldData, Footer.Size) = Footer.CRC) then
    begin
      OldSize := Footer.Size + SizeOf(Footer);
      Result := True;
    end;
  end;
  SetFilePointer(Handle, -OldSize, nil, FILE_END);
  SetEndOfFile(Handle);
  SetFileTime(Handle, @CreationTime, @AccessTime, @WriteTime);
  CloseHandle(Handle);
end;

function GetFileSecurityID(const FileName: string; var ID: string): Boolean;
var
  Data: TSecurityData;
begin
  if ReadSecurityData(FileName, Data) then
  begin
    ID := EncodeSecurityID(Data.ID, Data.Key);
    Result := True;
  end
  else
  begin
    ID := '';
    Result := False;
  end;
end;

function SetFileSecurityID(const FileName, ID: string): Boolean;
var
  Data: TSecurityData;
  Key: Byte;
begin
  FillChar(Data, SizeOf(Data), 0);
  Key := Random(256);
  Data.Key := Key;
  Data.ID := ShortString(EncodeSecurityID(ID, Key));
  Result := WriteSecurityData(FileName, Data);
end;

function RemoveFileSecurityID(const FileName: string): Boolean;
begin
  Result := RemoveSecurityData(FileName);
end;

initialization
finalization

end.
