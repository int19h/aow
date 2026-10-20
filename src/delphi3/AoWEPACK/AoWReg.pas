unit AoWReg;

{ AoWReg registry settings from AoWEPACK.dpl, recovered against Delphi 3.02.
  Remaining draft routines are marked below. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWRegistry = class;

  TDetailLevel = (dtlLow, dtlNormal, dtlHigh);  { ot=1 }
  TReadWriteMode = (rwRead, rwWrite);  { ot=1 }
  TWindowPopupEvent = (wpCombat, wpDiplomacy, wpSpellResearched, wpSpellReady, wpRebellion, wpPartyDamage, wpHeroUpgrade, wpHeroJoin);  { ot=1 }
  TWindowPopupEvents = set of TWindowPopupEvent; { ot=1 }
  TCombatResolveMode = (crmChoose, crmAlwaysFC, crmAlwaysTC);  { ot=1 }
  TMovementSpeed = (mmsNormal, mmsFast, mmsTurbo);  { ot=1 }
  TAoWLanguage = (alAuto, alEnglish, alGerman, alFrench, alSpanish, alItalian);  { ot=1 }

  { TAoWRegistry: instance size $18, inherited TRegistry fields $00..$17;
    no additional fields. VMT 55703984. }
  TAoWRegistry = class(TRegistry)
  public
    procedure AssociateAoWMap(const Executable: string);
    procedure rwInteger(Key, Name: string; var Value: Integer; Mode: TReadWriteMode);
    procedure rwBool(Key, Name: string; var Value: Boolean; Mode: TReadWriteMode);
    procedure rwString(Key, Name: string; var Value: string; Mode: TReadWriteMode);
    procedure rwBinaryData(Key, Name: string; var Value; Size: Integer; Mode: TReadWriteMode);
    procedure rwRect(Key, Name: string; var Value: TRect; Mode: TReadWriteMode);
    function GetRectangle(Index: Integer): TRect;
    procedure SetRectangle(Index: Integer; Value: TRect);
    function GetBoolean(Index: Integer): Boolean;
    procedure SetBoolean(Index: Integer; Value: Boolean);
    function GetString(Index: Integer): string;
    procedure SetString(Index: Integer; Value: string);
    function GetInteger(Index: Integer): Integer;
    procedure SetInteger(Index: Integer; Value: Integer);
    function GetDeveloper: Boolean;
    procedure SetDeveloper(Value: Boolean);
    function GetSkipIntro: Boolean;
    procedure SetSkipIntro(Value: Boolean);
    function GetDisplayMode: Integer;
    procedure SetDisplayMode(Value: Integer);
    function GetDisplayWidth: Integer;
    procedure SetDisplayWidth(Value: Integer);
    function GetDisplayHeight: Integer;
    procedure SetDisplayHeight(Value: Integer);
    function GetSurfaceInVMem: Boolean;
    procedure SetSurfaceInVMem(Value: Boolean);
    function GetAllowResolutionSwitches: Boolean;
    procedure SetAllowResolutionSwitches(Value: Boolean);
    function GetDebugMode: Boolean;
    procedure SetDebugMode(Value: Boolean);
    function GetRootDirectory: string;
    procedure SetRootDirectory(Value: string);
    function GetLanguage: TAoWLanguage;
    procedure SetLanguage(Value: TAoWLanguage);
    function GetSoundQuality: Integer;
    procedure SetSoundQuality(Value: Integer);
    function GetMusicVolume: Integer;
    procedure SetMusicVolume(Value: Integer);
    function GetSFXVolume: Integer;
    procedure SetSFXVolume(Value: Integer);
    function GetMainWindowPosition: TRect;
    procedure SetMainWindowPosition(Value: TRect);
    function GetMainWindowState: TWindowState;
    procedure SetMainWindowState(Value: TWindowState);
    function GetMapWindowPosition: TRect;
    procedure SetMapWindowPosition(Value: TRect);
    function GetShadowsEnabled: Boolean;
    procedure SetShadowsEnabled(Value: Boolean);
    function GetSFXEnabled: Boolean;
    procedure SetSFXEnabled(Value: Boolean);
    function GetMusicEnabled: Boolean;
    procedure SetMusicEnabled(Value: Boolean);
    function GetUseDirectSound: Boolean;
    procedure SetUseDirectSound(Value: Boolean);
    function GetDetailLevel: TDetailLevel;
    procedure SetDetailLevel(Value: TDetailLevel);
    function GetStartupDirectory: string;
    procedure SetStartupDirectory(Value: string);
    function GetLogTokenEvents: Boolean;
    procedure SetLogTokenEvents(Value: Boolean);
    function GetAutoSave: Boolean;
    procedure SetAutoSave(Value: Boolean);
    function GetAutoDebugSave: Boolean;
    procedure SetAutoDebugSave(Value: Boolean);
    function GetFastMovementEnabled: Boolean;
    procedure SetFastMovementEnabled(Value: Boolean);
    function GetClassicWindowPopupEvents: TWindowPopupEvents;
    procedure SetClassicWindowPopupEvents(Value: TWindowPopupEvents);
    function GetSimultaneousWindowPopupEvents: TWindowPopupEvents;
    procedure SetSimultaneousWindowPopupEvents(Value: TWindowPopupEvents);
    function GetCombatResolveMode: TCombatResolveMode;
    procedure SetCombatResolveMode(Value: TCombatResolveMode);
    function GetMovementSpeed: TMovementSpeed;
    procedure SetMovementSpeed(Value: TMovementSpeed);
    function GetLocalEmailAddress: string;
    procedure SetLocalEmailAddress(Value: string);
    function GetSMTPServer: string;
    procedure SetSMTPServer(Value: string);
    function GetPOP3Server: string;
    procedure SetPOP3Server(Value: string);
    function GetPOP3UserName: string;
    procedure SetPOP3UserName(Value: string);
    function GetPOP3Password: string;
    procedure SetPOP3Password(Value: string);
    function GetAttachmentDirectory: string;
    procedure SetAttachmentDirectory(Value: string);
    function GetCheckEmailFrequency: Integer;
    procedure SetCheckEmailFrequency(Value: Integer);
    function GetEmailGamesCRC: Integer;
    procedure SetEmailGamesCRC(Value: Integer);
    procedure RegisterDPlayLobbyServer;
  end;

function ValidAoWCD(Drive: Char): Boolean;
function AoWCDInserted: Boolean;
function GuaranteeAoWCD(const FirstMessage, RetryMessage: string): Boolean;

implementation

resourcestring
  AgeOfWondersMapStr = 'Age Of Wonders Map';

procedure TAoWRegistry.AssociateAoWMap(const Executable: string);
begin
  RootKey := HKEY_LOCAL_MACHINE;
  if OpenKey('\Software\Classes\.hsm', True) then
    WriteString('', 'AOWMAP');
  if OpenKey('\Software\Classes\AOWMAP', True) then
    WriteString('', AgeOfWondersMapStr);
  if OpenKey('\Software\Classes\AOWMAP\Shell\Open\Command', True) then
    WriteString('', Executable + ' "%1"');
  CloseKey;
  RootKey := HKEY_CURRENT_USER;
end;

procedure TAoWRegistry.rwInteger(Key, Name: string; var Value: Integer; Mode: TReadWriteMode);
begin
  if OpenKey('\Software\Triumph Studios\Age of Wonders\' + Key, True) then
  begin
    case Mode of
      rwRead: if ValueExists(Name) then Value := ReadInteger(Name);
      rwWrite: WriteInteger(Name, Value);
    end;
    CloseKey;
  end;
end;

procedure TAoWRegistry.rwBool(Key, Name: string; var Value: Boolean; Mode: TReadWriteMode);
begin
  if OpenKey('\Software\Triumph Studios\Age of Wonders\' + Key, True) then
  begin
    case Mode of
      rwRead: if ValueExists(Name) then Value := ReadBool(Name);
      rwWrite: WriteBool(Name, Value);
    end;
    CloseKey;
  end;
end;

procedure TAoWRegistry.rwString(Key, Name: string; var Value: string; Mode: TReadWriteMode);
begin
  if OpenKey('\Software\Triumph Studios\Age of Wonders\' + Key, True) then
  begin
    case Mode of
      rwRead: if ValueExists(Name) then Value := ReadString(Name);
      rwWrite: WriteString(Name, Value);
    end;
    CloseKey;
  end;
end;

procedure TAoWRegistry.rwBinaryData(Key, Name: string; var Value; Size: Integer; Mode: TReadWriteMode);
begin
  if OpenKey('\Software\Triumph Studios\Age of Wonders\' + Key, True) then
  begin
    case Mode of
      rwRead: if ValueExists(Name) then ReadBinaryData(Name, Value, Size);
      rwWrite: WriteBinaryData(Name, Value, Size);
    end;
    CloseKey;
  end;
end;

function StringToRect(S: string): TRect;
var
  P, I, Value: Integer;
  Part: string;
begin
  FillChar(Result, SizeOf(Result), 0);
  P := Pos(',', S);
  I := 0;
  while (S <> '') and (I <> 4) do
  begin
    if P <> 0 then
    begin
      Part := Copy(S, 1, P - 1);
      Delete(S, 1, P);
    end
    else
    begin
      Part := S;
      S := '';
    end;
    if Part <> '' then Value := StrToInt(Part) else Value := 0;
    case I of
      0: Result.Left := Value;
      1: Result.Top := Value;
      2: Result.Right := Value;
      3: Result.Bottom := Value;
    end;
    P := Pos(',', S);
    Inc(I);
  end;
end;

function RectToString(R: TRect): string;
begin
  Result := IntToStr(R.Left) + ',' + IntToStr(R.Top) + ',' +
    IntToStr(R.Right) + ',' + IntToStr(R.Bottom);
end;

procedure TAoWRegistry.rwRect(Key, Name: string; var Value: TRect; Mode: TReadWriteMode);
var
  S: string;
begin
  if OpenKey('\Software\Triumph Studios\Age of Wonders\' + Key, True) then
  begin
    case Mode of
      rwRead:
        if ValueExists(Name) then
        begin
          S := ReadString(Name);
          Value := StringToRect(S);
        end;
      rwWrite:
        begin
          S := RectToString(Value);
          WriteString(Name, S);
        end;
    end;
    CloseKey;
  end;
end;

function TAoWRegistry.GetRectangle(Index: Integer): TRect;
begin
  if Index >= 0 then
  begin
    FillChar(Result, SizeOf(Result), 0);
    rwRect('General\rectangles', IntToStr(Index), Result, rwRead);
  end
  else FillChar(Result, SizeOf(Result), 0);
end;

procedure TAoWRegistry.SetRectangle(Index: Integer; Value: TRect);
begin
  if Index >= 0 then
    rwRect('General\rectangles', IntToStr(Index), Value, rwWrite);
end;

function TAoWRegistry.GetBoolean(Index: Integer): Boolean;
begin
  { Original leaves Result uninitialized for a missing nonnegative index. }
  if Index >= 0 then
    rwBool('General\booleans', IntToStr(Index), Result, rwRead)
  else Result := False;
end;

procedure TAoWRegistry.SetBoolean(Index: Integer; Value: Boolean);
begin
  if Index >= 0 then
    rwBool('General\booleans', IntToStr(Index), Value, rwWrite);
end;

function TAoWRegistry.GetString(Index: Integer): string;
begin
  if Index >= 0 then
    rwString('General\strings', IntToStr(Index), Result, rwRead)
  else Result := '';
end;

procedure TAoWRegistry.SetString(Index: Integer; Value: string);
begin
  if Index >= 0 then
    rwString('General\strings', IntToStr(Index), Value, rwWrite);
end;

function TAoWRegistry.GetInteger(Index: Integer): Integer;
begin
  { Original leaves Result uninitialized for a missing nonnegative index. }
  if Index >= 0 then
    rwInteger('General\integers', IntToStr(Index), Result, rwRead)
  else Result := 0;
end;

procedure TAoWRegistry.SetInteger(Index: Integer; Value: Integer);
begin
  if Index >= 0 then
    rwInteger('General\integers', IntToStr(Index), Value, rwWrite);
end;

function TAoWRegistry.GetDeveloper: Boolean;
begin
  Result := False;
end;

procedure TAoWRegistry.SetDeveloper(Value: Boolean);
var
  Code: Integer;
begin
  if Value then
  begin
    Code := $D0D;
    rwInteger('General', 'D', Code, rwWrite);
    Exit;
  end;
  if OpenKey('\Software\Triumph Studios\Age of Wonders\General', True) then
  begin
    DeleteValue('D');
    CloseKey;
  end;
end;

function TAoWRegistry.GetSkipIntro: Boolean;
begin
  Result := False;
  rwBool('General', 'Skip Intro', Result, rwRead);
end;

procedure TAoWRegistry.SetSkipIntro(Value: Boolean);
begin
  rwBool('General', 'Skip Intro', Value, rwWrite);
end;

function TAoWRegistry.GetDisplayMode: Integer;
begin
  Result := 1;
  rwInteger('Video', 'Display Mode', Result, rwRead);
end;

procedure TAoWRegistry.SetDisplayMode(Value: Integer);
begin
  rwInteger('Video', 'Display Mode', Value, rwWrite);
end;

function TAoWRegistry.GetDisplayWidth: Integer;
begin
  Result := 640;
  rwInteger('Video', 'Display Width', Result, rwRead);
end;

procedure TAoWRegistry.SetDisplayWidth(Value: Integer);
begin
  rwInteger('Video', 'Display Width', Value, rwWrite);
end;

function TAoWRegistry.GetDisplayHeight: Integer;
begin
  Result := 480;
  rwInteger('Video', 'Display Height', Result, rwRead);
end;

procedure TAoWRegistry.SetDisplayHeight(Value: Integer);
begin
  rwInteger('Video', 'Display Height', Value, rwWrite);
end;

function TAoWRegistry.GetSurfaceInVMem: Boolean;
begin
  Result := False;
  rwBool('Video', 'Surface In VMem', Result, rwRead);
end;

procedure TAoWRegistry.SetSurfaceInVMem(Value: Boolean);
begin
  rwBool('Video', 'Surface In VMem', Value, rwWrite);
end;

function TAoWRegistry.GetAllowResolutionSwitches: Boolean;
begin
  Result := False;
  rwBool('Video', 'Allow Resolution Switches', Result, rwRead);
end;

procedure TAoWRegistry.SetAllowResolutionSwitches(Value: Boolean);
begin
  rwBool('Video', 'Allow Resolution Switches', Value, rwWrite);
end;

function TAoWRegistry.GetDebugMode: Boolean;
begin
  Result := False;
  rwBool('General', 'Debug Mode', Result, rwRead);
end;

procedure TAoWRegistry.SetDebugMode(Value: Boolean);
begin
  rwBool('General', 'Debug Mode', Value, rwWrite);
end;

function TAoWRegistry.GetRootDirectory: string;
begin
  Result := '';
  rwString('General', 'Root Directory', Result, rwRead);
end;

procedure TAoWRegistry.SetRootDirectory(Value: string);
begin
  rwString('General', 'Root Directory', Value, rwWrite);
end;

function TAoWRegistry.GetLanguage: TAoWLanguage;
var
  Value: Integer;
begin
  Value := 0;
  rwInteger('General', 'Language', Value, rwRead);
  { Original shipped code forces English after reading the setting. }
  Result := alEnglish;
  asm NOP end;
end;

procedure TAoWRegistry.SetLanguage(Value: TAoWLanguage);
var
  I: Integer;
begin
  I := Ord(Value);
  rwInteger('General', 'Language', I, rwWrite);
end;

function TAoWRegistry.GetSoundQuality: Integer;
begin
  Result := 3;
  rwInteger('Sound', 'Sound Quality', Result, rwRead);
end;

procedure TAoWRegistry.SetSoundQuality(Value: Integer);
begin
  rwInteger('Sound', 'Sound Quality', Value, rwWrite);
end;

function TAoWRegistry.GetMusicVolume: Integer;
begin
  Result := 50;
  rwInteger('Sound', 'Music Volume', Result, rwRead);
end;

procedure TAoWRegistry.SetMusicVolume(Value: Integer);
begin
  rwInteger('Sound', 'Music Volume', Value, rwWrite);
end;

function TAoWRegistry.GetSFXVolume: Integer;
begin
  Result := 50;
  rwInteger('Sound', 'SFX Volume', Result, rwRead);
end;

procedure TAoWRegistry.SetSFXVolume(Value: Integer);
begin
  rwInteger('Sound', 'SFX Volume', Value, rwWrite);
end;

function TAoWRegistry.GetMainWindowPosition: TRect;
begin
  FillChar(Result, SizeOf(Result), 0);
  rwRect('Workspace', 'Main Window Position', Result, rwRead);
end;

procedure TAoWRegistry.SetMainWindowPosition(Value: TRect);
begin
  rwRect('Workspace', 'Main Window Position', Value, rwWrite);
end;

function TAoWRegistry.GetMainWindowState: TWindowState;
var
  Value: Integer;
begin
  Value := 0;
  rwInteger('Workspace', 'Main Window State', Value, rwRead);
  Result := TWindowState(Value);
end;

procedure TAoWRegistry.SetMainWindowState(Value: TWindowState);
var
  I: Integer;
begin
  I := Ord(Value);
  rwInteger('Workspace', 'Main Window State', I, rwWrite);
end;

function TAoWRegistry.GetMapWindowPosition: TRect;
begin
  FillChar(Result, SizeOf(Result), 0);
  rwRect('Workspace', 'Map Window Position', Result, rwRead);
end;

procedure TAoWRegistry.SetMapWindowPosition(Value: TRect);
begin
  rwRect('Workspace', 'Map Window Position', Value, rwWrite);
end;

function TAoWRegistry.GetShadowsEnabled: Boolean;
begin
  Result := True;
  rwBool('Video', 'Shadows Enabled', Result, rwRead);
end;

procedure TAoWRegistry.SetShadowsEnabled(Value: Boolean);
begin
  rwBool('Video', 'Shadows Enabled', Value, rwWrite);
end;

function TAoWRegistry.GetSFXEnabled: Boolean;
begin
  Result := True;
  rwBool('Sound', 'Sound Effects Enabled', Result, rwRead);
end;

procedure TAoWRegistry.SetSFXEnabled(Value: Boolean);
begin
  rwBool('Sound', 'Sound Effects Enabled', Value, rwWrite);
end;

function TAoWRegistry.GetMusicEnabled: Boolean;
begin
  Result := True;
  rwBool('Sound', 'Music Enabled', Result, rwRead);
end;

procedure TAoWRegistry.SetMusicEnabled(Value: Boolean);
begin
  rwBool('Sound', 'Music Enabled', Value, rwWrite);
end;

function TAoWRegistry.GetUseDirectSound: Boolean;
begin
  Result := False;
  rwBool('Sound', 'Use DirectSound', Result, rwRead);
end;

procedure TAoWRegistry.SetUseDirectSound(Value: Boolean);
begin
  rwBool('Sound', 'Use DirectSound', Value, rwWrite);
end;

function TAoWRegistry.GetDetailLevel: TDetailLevel;
var
  Value: Integer;
begin
  Value := 2;
  rwInteger('Workspace', 'Detail Level', Value, rwRead);
  Result := TDetailLevel(Value);
end;

procedure TAoWRegistry.SetDetailLevel(Value: TDetailLevel);
var
  I: Integer;
begin
  I := Ord(Value);
  rwInteger('Workspace', 'Detail Level', I, rwWrite);
end;

function TAoWRegistry.GetStartupDirectory: string;
begin
  Result := '';
  rwString('General', 'Startup Directory', Result, rwRead);
end;

procedure TAoWRegistry.SetStartupDirectory(Value: string);
begin
  rwString('General', 'Startup Directory', Value, rwWrite);
end;

function TAoWRegistry.GetLogTokenEvents: Boolean;
begin
  Result := False;
  rwBool('General', 'Log Token Events', Result, rwRead);
end;

procedure TAoWRegistry.SetLogTokenEvents(Value: Boolean);
begin
  rwBool('General', 'Log Token Events', Value, rwWrite);
end;

function TAoWRegistry.GetAutoSave: Boolean;
begin
  Result := True;
  rwBool('General', 'Auto Save', Result, rwRead);
end;

procedure TAoWRegistry.SetAutoSave(Value: Boolean);
begin
  rwBool('General', 'Auto Save', Value, rwWrite);
end;

function TAoWRegistry.GetAutoDebugSave: Boolean;
begin
  Result := False;
  rwBool('General', 'Auto Debug Save', Result, rwRead);
end;

procedure TAoWRegistry.SetAutoDebugSave(Value: Boolean);
begin
  rwBool('General', 'Auto Debug Save', Value, rwWrite);
end;

function TAoWRegistry.GetFastMovementEnabled: Boolean;
begin
  Result := False;
  rwBool('General', 'Fast Movement Enabled', Result, rwRead);
end;

procedure TAoWRegistry.SetFastMovementEnabled(Value: Boolean);
begin
  rwBool('General', 'Fast Movement Enabled', Value, rwWrite);
end;

function TAoWRegistry.GetClassicWindowPopupEvents: TWindowPopupEvents;
begin
  Result := [wpCombat..wpHeroJoin];
  rwBinaryData('General', 'Classic Window Popup Events', Result, SizeOf(Result), rwRead);
end;

procedure TAoWRegistry.SetClassicWindowPopupEvents(Value: TWindowPopupEvents);
begin
  rwBinaryData('General', 'Classic Window Popup Events', Value, SizeOf(Value), rwWrite);
end;

function TAoWRegistry.GetSimultaneousWindowPopupEvents: TWindowPopupEvents;
begin
  Result := [wpCombat, wpDiplomacy, wpSpellResearched, wpSpellReady, wpPartyDamage, wpHeroUpgrade, wpHeroJoin];
  rwBinaryData('General', 'Simultaneous Window Popup Events', Result, SizeOf(Result), rwRead);
end;

procedure TAoWRegistry.SetSimultaneousWindowPopupEvents(Value: TWindowPopupEvents);
begin
  rwBinaryData('General', 'Simultaneous Window Popup Events', Value, SizeOf(Value), rwWrite);
end;

function TAoWRegistry.GetCombatResolveMode: TCombatResolveMode;
begin
  Result := crmChoose;
  rwBinaryData('General', 'Combat Resolve Mode', Result, SizeOf(Result), rwRead);
end;

procedure TAoWRegistry.SetCombatResolveMode(Value: TCombatResolveMode);
begin
  rwBinaryData('General', 'Combat Resolve Mode', Value, SizeOf(Value), rwWrite);
end;

function TAoWRegistry.GetMovementSpeed: TMovementSpeed;
begin
  Result := mmsNormal;
  rwBinaryData('General', 'Movement Speed', Result, SizeOf(Result), rwRead);
end;

procedure TAoWRegistry.SetMovementSpeed(Value: TMovementSpeed);
begin
  rwBinaryData('General', 'Movement Speed', Value, SizeOf(Value), rwWrite);
end;

function TAoWRegistry.GetLocalEmailAddress: string;
begin
  Result := '';
  rwString('Email', 'Local Email Address', Result, rwRead);
end;

procedure TAoWRegistry.SetLocalEmailAddress(Value: string);
begin
  rwString('Email', 'Local Email address', Value, rwWrite);
end;

function TAoWRegistry.GetSMTPServer: string;
begin
  Result := '';
  rwString('Email', 'SMTP Server', Result, rwRead);
end;

procedure TAoWRegistry.SetSMTPServer(Value: string);
begin
  rwString('Email', 'SMTP Server', Value, rwWrite);
end;

function TAoWRegistry.GetPOP3Server: string;
begin
  Result := '';
  rwString('Email', 'POP3 Server', Result, rwRead);
end;

procedure TAoWRegistry.SetPOP3Server(Value: string);
begin
  rwString('Email', 'POP3 Server', Value, rwWrite);
end;

function TransformPassword(S: string; Mode: Boolean): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    Result := Result + Char(((Length(S) + (I + 5)) and $FF) xor Ord(S[I]));
end;

function TAoWRegistry.GetPOP3UserName: string;
begin
  Result := '';
  rwString('Email', 'POP3 UserName', Result, rwRead);
end;

procedure TAoWRegistry.SetPOP3UserName(Value: string);
begin
  rwString('Email', 'POP3 UserName', Value, rwWrite);
end;

function TAoWRegistry.GetPOP3Password: string;
begin
  Result := '';
  rwString('Email', 'POP3 Password', Result, rwRead);
  Result := TransformPassword(Result, True);
end;

procedure TAoWRegistry.SetPOP3Password(Value: string);
begin
  Value := TransformPassword(Value, True);
  rwString('Email', 'POP3 Password', Value, rwWrite);
end;

function TAoWRegistry.GetAttachmentDirectory: string;
begin
  Result := '';
  rwString('Email', 'Attachment Directory', Result, rwRead);
end;

procedure TAoWRegistry.SetAttachmentDirectory(Value: string);
begin
  if (Length(Value) > 0) and (Value[Length(Value)] <> '\') then
    Value := Value + '\';
  rwString('Email', 'Attachment Directory', Value, rwWrite);
end;

function TAoWRegistry.GetCheckEmailFrequency: Integer;
begin
  Result := 1;
  rwInteger('Email', 'Check Email Frequency', Result, rwRead);
end;

procedure TAoWRegistry.SetCheckEmailFrequency(Value: Integer);
begin
  rwInteger('Email', 'Check Email Frequency', Value, rwWrite);
end;

function TAoWRegistry.GetEmailGamesCRC: Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  rwString('General', 'Serial number', S, rwRead);
  try
    P := Pos('-', S);
    { Original tests against -1 although Pos returns 0 when absent. }
    if P <> -1 then
    begin
      S := Copy(S, P + 1, Length(S) - P);
      P := Pos('-', S);
      if P <> -1 then
      begin
        S := Copy(S, 1, P - 1);
        if S <> '' then Result := HexToInt(S);
      end;
    end;
  except
    Result := 0;
  end;
end;

procedure TAoWRegistry.SetEmailGamesCRC(Value: Integer);
var
  S: string;
begin
  S := '4G5F6JHH-' + IntToHex(Value, 8) + '-6AG66554-98LK0FG3';
  rwString('General', 'Serial number', S, rwWrite);
end;

procedure TAoWRegistry.RegisterDPlayLobbyServer;
var
  Path: string;
begin
  RootKey := HKEY_LOCAL_MACHINE;
  if OpenKey('Software\Microsoft\DirectPlay\Applications\Age Of Wonders', True) then
  begin
    WriteString('Guid', '{3205D060-4FF5-11D3-811F-0050042E6D24}');
    WriteString('File', 'aow.exe');
    WriteString('CommandLine', 'dplobby');
    Path := ExtractFilePath(Application.ExeName);
    if (Length(Path) > 0) and (Path[Length(Path)] = '\') then
      Path := Copy(Path, 1, Length(Path) - 1);
    WriteString('Path', Path);
    WriteString('CurrentDirectory', Path);
    CloseKey;
  end;
  RootKey := HKEY_CURRENT_USER;
end;

function ValidAoWCD(Drive: Char): Boolean;
var
  Root: string;
begin
  Root := Drive + ':\';
  if GetDriveType(PChar(Root)) = DRIVE_CDROM then
  begin
    Result := FileExists(Drive + ':\AoWSetup.exe');
    Result := Result and FileExists(Drive + ':\setup.exe');
  end
  else Result := False;
end;

function AoWCDInserted: Boolean;
asm
  { The shipped GOG binary patches the drive scan to True followed by 54 NOPs. }
  PUSH EBX
  PUSH ESI
  PUSH EDI
  PUSH ECX
  XOR EBX, EBX
  MOV BL, 1
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  MOV EAX, EBX
  POP EDX
  POP EDI
  POP ESI
  POP EBX
end;

function GuaranteeAoWCD(const FirstMessage, RetryMessage: string): Boolean;
var
  Msg: string;
  Cancel: Boolean;
begin
  Msg := FirstMessage;
  Result := False;
  Cancel := False;
  while not Result and not Cancel do
  begin
    Result := AoWCDInserted;
    if not Result then
    begin
      Cancel := MessageDlg(Msg, mtInformation, [mbOK, mbCancel], 0) = mrCancel;
      Msg := RetryMessage;
    end;
  end;
end;


initialization
finalization

end.
