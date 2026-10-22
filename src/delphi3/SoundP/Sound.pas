unit Sound;

{ The Sound unit of SoundP.dpl: the sound system of Age of Wonders, written for the original
  compiler (Delphi 3.02) and compared function by function with the shipped module
  (tools/match.py). Declarations follow the original instance layouts and VMT orders
  (notes/classes.json, notes/rtti/SoundP.dpl.txt); the enumeration names come from the type info.

  How it works: a sound system (TSoundSystem, the only one is TGalaxySoundSystem in GalSndS)
  registers its class (RegisterSoundSystem); InitializeSoundSystem creates one and activates it
  with TSoundSettings. Sound effects are TSample objects that play a TSampleData (the loaded wave
  file, shared and reference counted through SampleDataList); PlaySample/PlaySampleEx find or
  load the data and start a sample, ProcessSound updates every sample each tick (a sample that
  has finished and does not loop destroys itself). Music is one song at a time (PlaySong,
  PlaySongEx with fades); TSongPlayer plays a song list in turn. The engine objects TSFX (a wave
  file), TSFXSequence (an ID and a set of TSFX, one picked at random) and TSFXLibrary (the
  sequences) store the game's sound effects; TSFXManager and its combo and list boxes browse the
  wave files under a directory. File names are relative to BaseSoundEnginePath (the directory of
  the program, or of the project in the IDE).

  The package was compiled with the default switches. The signature hashes in the package's
  export names (Name@XXXXXXXX) confirm the unit routines' parameter and result types where they
  do not involve classes: GetSoundSettings is a function, TSongStatus has a protected field and
  a read-only property (the hash ignores names and member order, but not visibility). }

interface

uses
  Windows, SysUtils, Classes, Controls, StdCtrls, Forms, Dialogs, MMSystem, ExptIntf, ToolIntf,
  Engine, EList;

type
  TSampleCallBackMode = (scRestartLoop, scDone);
  TSample = class;
  TSongStatus = class;
  TSampleCallBack = procedure(Sample: TSample; Mode: TSampleCallBackMode) of object;
  TSampleStatus = set of (ssRunning);
  TSamplePanning = (spLeft, spCenter, spRight, spSurround);
  TSoundOutputMode = set of (omMono, omStereo, om8bit, om16bit, omHighQuality);

  { The settings a sound system is activated with (24 bytes): +0 OutputMode, +4 SampleRate, +8
    MusicEnabled, +9 UseDirectSound, +$C Window (the DirectSound window; the active window when
    0), +$10 SFXEnabled, +$14 SampleVoices. }
  TSoundSettings = record
    OutputMode: TSoundOutputMode;
    SampleRate: Integer;
    MusicEnabled: Boolean;
    UseDirectSound: Boolean;
    Window: HWND;
    SFXEnabled: Boolean;
    SampleVoices: Integer;
  end;

  { Sound.TSampleData (instance size 12): +4 FName, +8 FRefCount. The sound data of one wave
    file, in SampleDataList while it is loaded; Create counts the first reference. }
  TSampleData = class(TObject)
  private
    FName: string;
    FRefCount: Integer;
  public
    constructor Create(Name: string); virtual;
    constructor CreateEx(Format: PWaveFormatEx; Data: Pointer; Size: Integer); virtual;
    procedure Release; virtual;
    procedure AddRef; virtual;
    destructor Destroy; override;
    property Name: string read FName;
    property RefCount: Integer read FRefCount;
  end;

  TSampleDataClass = class of TSampleData;

  { Sound.TSample (instance size 24): +4 FDelay (Update ticks before it plays), +8 FSampleData,
    +$C FCallBack, +$14 FStatus. One playing sound effect, in SampleList. }
  TSample = class(TObject)
  private
    FDelay: Integer;
    FSampleData: TSampleData;
    FCallBack: TSampleCallBack;
    FStatus: TSampleStatus;
  protected
    function GetPlaying: Boolean; virtual;
    function GetVolume: Integer; virtual; abstract;
    procedure SetVolume(Value: Integer); virtual; abstract;
    function GetLooped: Boolean; virtual; abstract;
    procedure SetLooped(Value: Boolean); virtual; abstract;
    function GetPanning: TSamplePanning; virtual; abstract;
    procedure SetPanning(Value: TSamplePanning); virtual; abstract;
  public
    procedure Update; virtual;
    constructor Create(ASampleData: TSampleData); virtual;
    procedure Play; virtual;
    procedure Stop; virtual;
    destructor Destroy; override;
    procedure Execute;
    property SampleData: TSampleData read FSampleData;
    property Delay: Integer read FDelay write FDelay;
    property CallBack: TSampleCallBack read FCallBack write FCallBack;
    property Status: TSampleStatus read FStatus;
    property Playing: Boolean read GetPlaying;
    property Volume: Integer read GetVolume write SetVolume;
    property Looped: Boolean read GetLooped write SetLooped;
    property Panning: TSamplePanning read GetPanning write SetPanning;
  end;

  TSampleClass = class of TSample;

  TSoundSystemStatus = set of (ssActivated, ssDirectSoundEnabled);

  { Sound.TSoundSystem (instance size 12): +4 FRefCount, +8 FStatus. The abstract sound system;
    GetName is a class function (RegisterSoundSystem calls it on the class). }
  TSoundSystem = class(TObject)
  protected
    FRefCount: Integer;
    FStatus: TSoundSystemStatus;
    class function GetName: string; virtual; abstract;
    function SampleClass: TSampleClass; virtual; abstract;
    function SampleDataClass: TSampleDataClass; virtual; abstract;
    function Activate(const Settings: TSoundSettings): Boolean; virtual; abstract;
    function Deactivate: Boolean; virtual; abstract;
    procedure Process; virtual; abstract;
    function GetMusicVolume: Integer; virtual; abstract;
    function GetSFXVolume: Integer; virtual; abstract;
    function GetPlayingSong: Boolean; virtual; abstract;
    function GetPlayingSongFileName: string; virtual; abstract;
    function GetSFXEnabled: Boolean; virtual; abstract;
    function GetMusicEnabled: Boolean; virtual; abstract;
  public
    constructor Create; virtual;
    function Release: Integer; virtual;
    function AddRef: Integer; virtual;
    function SetSFXEnabled(Value: Boolean): Boolean; virtual; abstract;
    function SetMusicEnabled(Value: Boolean): Boolean; virtual; abstract;
    function SetSoundSettings(const Settings: TSoundSettings): Boolean; virtual; abstract;
    function GetSoundSettings: TSoundSettings; virtual; abstract;
    function FadeMusicVolume(Volume, Speed: Integer): Boolean; virtual; abstract;
    function SetMusicVolume(Volume: Integer): Boolean; virtual; abstract;
    function FadeSFXVolume(Volume, Speed: Integer): Boolean; virtual; abstract;
    function SetSFXVolume(Volume: Integer): Boolean; virtual; abstract;
    function PlaySong(FileName: string): Boolean; virtual; abstract;
    function PlaySongEx(FileName: string; FadeOut, FadeIn: Integer; Loop: Boolean): Boolean;
      virtual; abstract;
    function StopSong: Boolean; virtual; abstract;
    function BackupSongStatus: TSongStatus; virtual; abstract;
    function RestoreSongStatus(Status: TSongStatus): Boolean; virtual; abstract;
    destructor Destroy; override;
    property Status: TSoundSystemStatus read FStatus;
    property MusicVolume: Integer read GetMusicVolume;
    property SFXVolume: Integer read GetSFXVolume;
    property PlayingSong: Boolean read GetPlayingSong;
    property PlayingSongFileName: string read GetPlayingSongFileName;
    property SFXEnabled: Boolean read GetSFXEnabled;
    property MusicEnabled: Boolean read GetMusicEnabled;
  end;

  TSoundSystemClass = class of TSoundSystem;

  { Sound.TSFXList (instance size 44): the wave files TSFXManager found }
  TSFXList = class(TStringList)
  end;

  { Sound.TSFXManager (instance size 44): +$24 FSearchPath, +$28 FSFX. ExecutePathSearch lists
    every wave file under a directory (with its subdirectories) relative to the search path. }
  TSFXManager = class(TComponent)
  private
    FSearchPath: string;
    FSFX: TSFXList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure ExecutePathSearch(Path: string);
  published
    property SearchPath: string read FSearchPath write FSearchPath;
    property SFX: TSFXList read FSFX;
  end;

  { Sound.TSFXManagerComboBox (instance size 384): +$170 FSFXManager, +$174 FSubDirectory, +$178
    FSkipDirectories (';'-separated), +$17C FEmptySFXName. }
  TSFXManagerComboBox = class(TComboBox)
  private
    FSFXManager: TSFXManager;
    FSubDirectory: string;
    FSkipDirectories: string;
    FEmptySFXName: string;
    procedure SetSFXManager(Value: TSFXManager);
    procedure SetSubDirectory(Value: string);
    function GetSFXName: string;
    procedure SetSFXName(Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure GenerateItems;
    property SFXName: string read GetSFXName write SetSFXName;
  published
    property SFXManager: TSFXManager read FSFXManager write SetSFXManager;
    property SubDirectory: string read FSubDirectory write SetSubDirectory;
    property SkipDirectories: string read FSkipDirectories write FSkipDirectories;
    property EmptySFXName: string read FEmptySFXName write FEmptySFXName;
  end;

  { Sound.TSFXManagerListBox (instance size 356): +$154 FSFXManager, +$158 FSubDirectory, +$15C
    FSkipDirectories, +$160 FEmptySFXName. The same as the combo box. }
  TSFXManagerListBox = class(TListBox)
  private
    FSFXManager: TSFXManager;
    FSubDirectory: string;
    FSkipDirectories: string;
    FEmptySFXName: string;
    procedure SetSFXManager(Value: TSFXManager);
    procedure SetSubDirectory(Value: string);
    function GetSFXName: string;
    procedure SetSFXName(Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure GenerateItems;
    property SFXName: string read GetSFXName write SetSFXName;
  published
    property SFXManager: TSFXManager read FSFXManager write SetSFXManager;
    property SubDirectory: string read FSubDirectory write SetSubDirectory;
    property SkipDirectories: string read FSkipDirectories write FSkipDirectories;
    property EmptySFXName: string read FEmptySFXName write FEmptySFXName;
  end;

  { Sound.TSongStatus (instance size 8): +4 FFileName. What BackupSongStatus saves; the sound
    system adds its own position. }
  TSongStatus = class(TObject)
  protected
    FFileName: string;
  public
    property FileName: string read FFileName;
  end;

  TSongPlayerStatus = set of (spPlaying, spPaused);

  { Sound.TSonglist (instance size 16): +8 FSongs, +$C FSongNames (the titles, from the
    files). An engine object with a list of music files. }
  TSonglist = class(TEObject)
  private
    FSongs: TStringList;
    FSongNames: TStringList;
    procedure SetSongs(Value: TStringList);
    procedure SongsChanged(Sender: TObject);
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    destructor Destroy; override;
    procedure Search(Path, Ext: string);
    property Songs: TStringList read FSongs write SetSongs;
    property SongNames: TStringList read FSongNames;
  end;

  { Sound.TSongPlayer (instance size 40): +4 FCurrentSong, +8 FStatus, +$C FSongs, +$10
    FSongNames, +$14 FCurrentIndex, +$18 FOnSongChange, +$20 FBackup (Pause), +$24
    FPauseCount. Plays the songs in turn (Update starts the next one). }
  TSongPlayer = class(TObject)
  private
    FCurrentSong: string;
    FStatus: TSongPlayerStatus;
    FSongs: TStringList;
    FSongNames: TStringList;
    FCurrentIndex: Integer;
    FOnSongChange: TNotifyEvent;
    FBackup: TSongStatus;
    FPauseCount: Integer;
    procedure SetSongs(Value: TStringList);
    procedure SongsChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Update;
    function PlayEx(Index, FadeOut, FadeIn: Integer): Boolean;
    function Play(Index: Integer): Boolean;
    function Stop(StopMusic: Boolean): Boolean;
    function Pause(StopMusic: Boolean): Boolean;
    function Resume: Boolean;
    property CurrentSong: string read FCurrentSong;
    property Status: TSongPlayerStatus read FStatus;
    property Songs: TStringList read FSongs write SetSongs;
    property SongNames: TStringList read FSongNames;
    property CurrentIndex: Integer read FCurrentIndex;
    property OnSongChange: TNotifyEvent read FOnSongChange write FOnSongChange;
  end;

  { Sound.TSFX (instance size 12): +8 FFileName. One wave file of a sequence. }
  TSFX = class(TEObject)
  private
    FFileName: string;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    class function ClassID: Integer; override;
    function Play: TSample;
    function PlayEx(Volume: Integer; Looped: Boolean; Delay: Integer; Panning: TSamplePanning;
      CallBack: TSampleCallBack): TSample;
    property FileName: string read FFileName write FFileName;
  end;

  { Sound.TSFXSequence (instance size 16): +$C FID. A sound effect: its children are TSFX, one
    of them plays (at random). }
  TSFXSequence = class(TENode)
  private
    FID: Integer;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetSFX(Index: Integer): TSFX;
    function Play: TSample;
    function PlayEx(Volume: Integer; Looped: Boolean; Delay: Integer; Panning: TSamplePanning;
      CallBack: TSampleCallBack): TSample;
    property ID: Integer read FID write FID;
    property SFX[Index: Integer]: TSFX read GetSFX;
  end;

  { Sound.TSFXLibrary (instance size 12): the sound effects (TSFXSequence children) by ID. }
  TSFXLibrary = class(TENode)
  public
    class function ClassID: Integer; override;
    function GetSFXSequence(Index: Integer): TSFXSequence;
    function Play(ID: Integer): TSample;
    function PlayEx(ID, Volume: Integer; Looped: Boolean; Delay: Integer;
      Panning: TSamplePanning; CallBack: TSampleCallBack): TSample;
    function Find(ID: Integer): TSFXSequence;
    function DoubleID: Integer;
    property SFXSequences[Index: Integer]: TSFXSequence read GetSFXSequence;
  end;

var
  BaseSoundEnginePath: string;
  SongPlayer: TSongPlayer;

procedure LockSampleData(Name: string);
procedure UnlockSampleData(Name: string);
function CreateSampleData(const Name: string): TSampleData;
function CreateSampleDataEx(Format: PWaveFormatEx; Data: Pointer; Size: Integer): TSampleData;
function CreateSample(SampleData: TSampleData): TSample;
function PlaySample(Name: string): TSample;
function PlaySampleEx(Name: string; Volume: Integer; Looped: Boolean; Delay: Integer;
  Panning: TSamplePanning; CallBack: TSampleCallBack): TSample;
function SamplesActive: Integer;
function SamplesLoaded: Integer;
procedure RegisterSoundSystem(AClass: TSoundSystemClass);
function InitializeSoundSystem(Name: string; const Settings: TSoundSettings): Boolean;
procedure ReleaseSoundSystem;
function SoundSystemStatus: TSoundSystemStatus;
procedure SetMusicVolume(Volume: Integer);
procedure FadeMusicVolume(Volume, Speed: Integer);
function GetMusicVolume: Integer;
procedure SetSFXVolume(Volume: Integer);
function GetSFXVolume: Integer;
function GetMusicEnabled: Boolean;
function SetMusicEnabled(Value: Boolean): Boolean;
function GetSFXEnabled: Boolean;
function SetSFXEnabled(Value: Boolean): Boolean;
function GetSoundSettings: TSoundSettings;
function SetSoundSettings(const Settings: TSoundSettings): Boolean;
function BackupSongStatus: TSongStatus;
function RestoreSongStatus(Status: TSongStatus): Boolean;
function GetSongName(FileName: string): string;
function PlayingSongFileName: string;
function PlaySong(FileName: string): Boolean;
function PlaySongEx(FileName: string; FadeOut, FadeIn: Integer; Loop: Boolean): Boolean;
function StopSong: Boolean;
procedure ProcessSound;
procedure RegisterSoundEngineClasses(AEngine: TEngine);
procedure UnregisterSoundEngineClasses(AEngine: TEngine);
procedure Register;

implementation uses GalSndS;

const
  SFXExtension = 'WAV';

type
  { Sound.TSampleList (instance size 16): every TSample (ProcessSound updates them) }
  TSampleList = class(TList)
  public
    destructor Destroy; override;
    procedure Clear;
  end;

  { Sound.TSampleDataList (instance size 16): the loaded TSampleData }
  TSampleDataList = class(TList)
  public
    function Find(Name: string): TSampleData;
  end;

  { TENode keeps its child list private in Engine.pas: the sequences and the library reach it
    through this copy of TENode's layout (+8 FChildren). The code is the same as with a
    protected FChildren, which is probably what the original Engine unit had. }
  TENodeAccess = class(TECustomNode)
  private
    FChildren: TEObjectList;
  end;

  { Sound.TSoundSystemList (instance size 16): the registered sound system classes }
  TSoundSystemList = class(TList)
  public
    function Find(Name: string): TSoundSystemClass;
  end;

const
  SoundSystem: TSoundSystem = nil;
  SoundSystems: TSoundSystemList = nil;
  SampleDataList: TSampleDataList = nil;
  SampleList: TSampleList = nil;

{ TSFXManager }

constructor TSFXManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSFX := TSFXList.Create;
end;

destructor TSFXManager.Destroy;
begin
  Clear;
  FSFX.Free;
  inherited Destroy;
end;

procedure TSFXManager.Clear;
begin
  FSFX.Clear;
end;

procedure TSFXManager.ExecutePathSearch(Path: string);
var
  OldDir: string;

  procedure Search(Dir: string);
  var
    SR: TSearchRec;
    Dirs: TStringList;
    Found: Boolean;
    I: Integer;
  begin
    Found := FindFirst(FSearchPath + Dir + '*.' + SFXExtension, faAnyFile and not faDirectory,
      SR) = 0;
    while Found do
    begin
      FSFX.Add(UpperCase(Dir + SR.Name));
      Found := FindNext(SR) = 0;
    end;
    FindClose(SR);
    Dirs := TStringList.Create;
    Found := FindFirst(Dir + '*.*', faDirectory, SR) = 0;
    while Found do
    begin
      if (SR.Attr and faDirectory <> 0) and (SR.Name <> '.') and (SR.Name <> '..') then
        Dirs.Add(Dir + UpperCase(SR.Name) + '\');
      Found := FindNext(SR) = 0;
    end;
    FindClose(SR);
    for I := 0 to Dirs.Count - 1 do
      Search(Dirs[I]);
    Dirs.Free;
  end;

begin
  FSFX.Clear;
  FSearchPath := UpperCase(Path);
  if FSearchPath[Length(FSearchPath)] <> '\' then
    FSearchPath := FSearchPath + '\';
  OldDir := GetCurrentDir;
  SetCurrentDir(Path);
  Search('');
  SetCurrentDir(OldDir);
  FSearchPath := UpperCase(ExtractRelativePath(BaseSoundEnginePath, FSearchPath));
end;

{ TSFXManagerComboBox }

procedure TSFXManagerComboBox.SetSFXManager(Value: TSFXManager);
begin
  FSFXManager := Value;
  GenerateItems;
end;

procedure TSFXManagerComboBox.SetSubDirectory(Value: string);
begin
  FSubDirectory := UpperCase(Value);
  if (Value <> '') and (FSubDirectory[Length(FSubDirectory)] <> '\') then
    FSubDirectory := FSubDirectory + '\';
end;

constructor TSFXManagerComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := csDropDownList;
end;

function TSFXManagerComboBox.GetSFXName: string;
begin
  if (ItemIndex = 0) and (FEmptySFXName <> '') and (Text = FEmptySFXName) then
    Result := ''
  else
    Result := FSFXManager.FSearchPath + FSubDirectory + Text;
end;

procedure TSFXManagerComboBox.SetSFXName(Value: string);
var
  L, I: Integer;
begin
  if not (csLoading in ComponentState) then
  begin
    L := Length(FSFXManager.FSearchPath + FSubDirectory);
    if StrLComp(PChar(FSFXManager.FSearchPath + FSubDirectory), PChar(Value), L) = 0 then
      Value := Copy(Value, L + 1, Length(Value) - L);
    if Value = '' then
      Value := FEmptySFXName;
    I := Items.IndexOf(Value);
    if I <> -1 then
      ItemIndex := I;
  end;
end;

{ Fills the items with the manager's files under SubDirectory (without the subdirectory), less
  those in SkipDirectories, after EmptySFXName. }
procedure TSFXManagerComboBox.GenerateItems;
var
  List: TStringList;
  Sub, Dir, Skip: string;
  L, DirLen, I: Integer;
begin
  List := TStringList.Create;
  if FEmptySFXName <> '' then
    List.Add(FEmptySFXName);
  if FSFXManager <> nil then
    List.AddStrings(FSFXManager.FSFX);
  Sub := UpperCase(FSubDirectory);
  if Sub <> '' then
  begin
    L := Length(Sub);
    for I := List.Count - 1 downto 0 do
      if StrLComp(PChar(Sub), PChar(List[I]), L) = 0 then
        List[I] := Copy(List[I], L + 1, Length(List[I]) - L)
      else
        List.Delete(I);
  end;
  Skip := UpperCase(FSkipDirectories);
  while Skip <> '' do
  begin
    if Pos(';', Skip) > 0 then
    begin
      Dir := Copy(Skip, 1, Pos(';', Skip) - 1);
      Skip := Copy(Skip, Length(Dir) + 2, Length(Skip) - Length(Dir));
    end
    else
    begin
      Dir := Skip;
      Skip := '';
    end;
    Dir := UpperCase(Dir);
    if Dir[Length(Dir)] <> '\' then
      Dir := Dir + '\';
    DirLen := Length(Dir);
    for I := List.Count - 1 downto 0 do
      if StrLComp(PChar(Dir), PChar(List[I]), DirLen) = 0 then
        List.Delete(I);
  end;
  Items := List;
  List.Free;
end;

{ TSFXManagerListBox }

procedure TSFXManagerListBox.SetSFXManager(Value: TSFXManager);
begin
  FSFXManager := Value;
  GenerateItems;
end;

procedure TSFXManagerListBox.SetSubDirectory(Value: string);
begin
  FSubDirectory := UpperCase(Value);
  if (Value <> '') and (FSubDirectory[Length(FSubDirectory)] <> '\') then
    FSubDirectory := FSubDirectory + '\';
end;

constructor TSFXManagerListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := lbStandard;
  Sorted := True;
end;

function TSFXManagerListBox.GetSFXName: string;
begin
  if (ItemIndex = 0) and (FEmptySFXName <> '') and (Items[ItemIndex] = FEmptySFXName) then
    Result := ''
  else
    Result := FSFXManager.FSearchPath + FSubDirectory + Items[ItemIndex];
end;

procedure TSFXManagerListBox.SetSFXName(Value: string);
var
  L, I: Integer;
begin
  if not (csLoading in ComponentState) then
  begin
    L := Length(FSFXManager.FSearchPath + FSubDirectory);
    if StrLComp(PChar(FSFXManager.FSearchPath + FSubDirectory), PChar(Value), L) = 0 then
      Value := Copy(Value, L + 1, Length(Value) - L);
    if Value = '' then
      Value := FEmptySFXName;
    I := Items.IndexOf(Value);
    if I <> -1 then
      ItemIndex := I;
  end;
end;

procedure TSFXManagerListBox.GenerateItems;
var
  List: TStringList;
  Sub, Dir, Skip: string;
  L, DirLen, I: Integer;
begin
  List := TStringList.Create;
  if FEmptySFXName <> '' then
    List.Add(FEmptySFXName);
  if FSFXManager <> nil then
    List.AddStrings(FSFXManager.FSFX);
  Sub := UpperCase(FSubDirectory);
  if Sub <> '' then
  begin
    L := Length(Sub);
    for I := List.Count - 1 downto 0 do
      if StrLComp(PChar(Sub), PChar(List[I]), L) = 0 then
        List[I] := Copy(List[I], L + 1, Length(List[I]) - L)
      else
        List.Delete(I);
  end;
  Skip := UpperCase(FSkipDirectories);
  while Skip <> '' do
  begin
    if Pos(';', Skip) > 0 then
    begin
      Dir := Copy(Skip, 1, Pos(';', Skip) - 1);
      Skip := Copy(Skip, Length(Dir) + 2, Length(Skip) - Length(Dir));
    end
    else
    begin
      Dir := Skip;
      Skip := '';
    end;
    Dir := UpperCase(Dir);
    if Dir[Length(Dir)] <> '\' then
      Dir := Dir + '\';
    DirLen := Length(Dir);
    for I := List.Count - 1 downto 0 do
      if StrLComp(PChar(Dir), PChar(List[I]), DirLen) = 0 then
        List.Delete(I);
  end;
  Items := List;
  List.Free;
end;

{ TSampleDataList }

function TSampleDataList.Find(Name: string): TSampleData;
var
  I: Integer;
begin
  I := 0;
  while (I <> Count) and (CompareText(Name, TSampleData(List^[I]).FName) <> 0) do
    Inc(I);
  if I <> Count then
    Result := List^[I]
  else
    Result := nil;
end;

{ TSampleData }

constructor TSampleData.Create(Name: string);
begin
  inherited Create;
  FName := Name;
  SampleDataList.Add(Self);
  AddRef;
end;

{ Sound data from memory; it is not put in SampleDataList. }
constructor TSampleData.CreateEx(Format: PWaveFormatEx; Data: Pointer; Size: Integer);
begin
  inherited Create;
  FName := '';
  AddRef;
end;

destructor TSampleData.Destroy;
begin
  SampleDataList.Remove(Self);
  inherited Destroy;
end;

procedure TSampleData.Release;
begin
  Dec(FRefCount);
  if FRefCount = 0 then
    Destroy;
end;

procedure TSampleData.AddRef;
begin
  Inc(FRefCount);
end;

{ TSampleList }

destructor TSampleList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TSampleList.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    TSample(List^[I]).Destroy;
  inherited Clear;
end;

{ TSample }

constructor TSample.Create(ASampleData: TSampleData);
begin
  inherited Create;
  SampleList.Add(Self);
  FSampleData := ASampleData;
  FSampleData.AddRef;
end;

destructor TSample.Destroy;
begin
  if Assigned(FCallBack) then
    FCallBack(Self, scDone);
  if FSampleData <> nil then
    FSampleData.Release;
  FSampleData := nil;
  SampleList.Remove(Self);
  inherited Destroy;
end;

function TSample.GetPlaying: Boolean;
begin
  Result := FDelay <> 0;
end;

procedure TSample.Play;
begin
end;

procedure TSample.Stop;
begin
end;

{ Called every tick (ProcessSound): a delayed sample counts down and plays, a finished one that
  does not loop destroys itself. }
procedure TSample.Update;
begin
  if (ssRunning in FStatus) and not GetPlaying then
    if FDelay <> 0 then
    begin
      Dec(FDelay);
      if FDelay = 0 then
        Play;
    end
    else if not GetLooped then
      Destroy;
end;

procedure TSample.Execute;
begin
  if not (ssRunning in FStatus) then
  begin
    if FDelay = 0 then
      Play;
    FStatus := FStatus + [ssRunning];
  end;
end;

{ TSonglist }

constructor TSonglist.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FSongs := TStringList.Create;
  FSongs.OnChange := SongsChanged;
  FSongNames := TStringList.Create;
end;

destructor TSonglist.Destroy;
begin
  FSongs.Free;
  FSongNames.Free;
  inherited Destroy;
end;

class function TSonglist.ClassID: Integer;
begin
  Result := $210004;
end;

procedure TSonglist.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smText in Stream.StorageMode) then
    Stream.rwStrings(FSongs, 10);
end;

procedure TSonglist.SetSongs(Value: TStringList);
begin
  FSongs.Assign(Value);
end;

{ Reads the song titles; a file that cannot be read is dropped from the list. }
procedure TSonglist.SongsChanged(Sender: TObject);
var
  I: Integer;
begin
  FSongNames.Clear;
  for I := FSongs.Count - 1 downto 0 do
    try
      FSongNames.Insert(0, GetSongName(FSongs[I]));
    except
      FSongs.Delete(I);
    end;
end;

procedure TSonglist.Search(Path, Ext: string);
var
  SR: TSearchRec;
  FullPath: string;
  Found: Boolean;
begin
  if Path[Length(Path)] <> '\' then
    Path := Path + '\';
  FullPath := BaseSoundEnginePath + Path;
  FSongs.BeginUpdate;
  Found := FindFirst(FullPath + '*.' + Ext, faAnyFile and not faDirectory, SR) = 0;
  while Found do
  begin
    FSongs.Add(UpperCase(Path + SR.Name));
    Found := FindNext(SR) = 0;
  end;
  FindClose(SR);
  FSongs.EndUpdate;
end;

{ TSongPlayer }

constructor TSongPlayer.Create;
begin
  inherited Create;
  FSongs := TStringList.Create;
  FSongs.OnChange := SongsChanged;
  FSongNames := TStringList.Create;
  FCurrentIndex := -1;
end;

destructor TSongPlayer.Destroy;
begin
  FSongs.Free;
  FSongNames.Free;
  inherited Destroy;
end;

procedure TSongPlayer.SetSongs(Value: TStringList);
begin
  FSongs.Assign(Value);
end;

procedure TSongPlayer.SongsChanged(Sender: TObject);
var
  I: Integer;
begin
  FSongNames.Clear;
  for I := FSongs.Count - 1 downto 0 do
    try
      FSongNames.Insert(0, GetSongName(FSongs[I]));
    except
      FSongs.Delete(I);
    end;
  if spPlaying in FStatus then
    if FSongs.Count <> 0 then
    begin
      if FCurrentIndex <> -1 then
        if (FCurrentIndex >= FSongs.Count) or (FSongs[FCurrentIndex] <> FCurrentSong) then
        begin
          FCurrentIndex := FSongs.IndexOf(FCurrentSong);
          if FCurrentIndex = -1 then
            FCurrentSong := '';
        end;
      if (FCurrentIndex = -1) and not (spPaused in FStatus) then
        Play(0);
    end
    else
    begin
      if SoundSystem <> nil then
        SoundSystem.StopSong;
      FCurrentIndex := -1;
      FCurrentSong := '';
    end;
end;

{ Called every tick (ProcessSound): starts the next song when the last one has ended. }
procedure TSongPlayer.Update;
begin
  if (SoundSystem <> nil) and (spPlaying in FStatus) and not (spPaused in FStatus) and
    not SoundSystem.PlayingSong and SoundSystem.MusicEnabled then
  begin
    Inc(FCurrentIndex);
    if FSongs.Count <= FCurrentIndex then
      FCurrentIndex := 0;
    if FCurrentIndex < FSongs.Count then
      Play(FCurrentIndex)
    else
      FCurrentIndex := -1;
  end;
end;

function TSongPlayer.PlayEx(Index, FadeOut, FadeIn: Integer): Boolean;
begin
  if (SoundSystem <> nil) and (Index >= 0) and (Index < FSongs.Count) then
  begin
    FStatus := FStatus + [spPlaying];
    Result := SoundSystem.PlaySongEx(FSongs[Index], FadeOut, FadeIn, False);
    if Result then
    begin
      FCurrentIndex := Index;
      FCurrentSong := FSongs[Index];
      if Assigned(FOnSongChange) then
        FOnSongChange(Self);
    end
    else
    begin
      FCurrentSong := '';
      FCurrentIndex := -1;
    end;
  end
  else
    Result := False;
end;

function TSongPlayer.Play(Index: Integer): Boolean;
begin
  if (SoundSystem <> nil) and (Index >= 0) and (Index < FSongs.Count) then
  begin
    FStatus := FStatus + [spPlaying];
    Result := SoundSystem.PlaySongEx(FSongs[Index], 2, 0, False);
    if Result then
    begin
      FCurrentIndex := Index;
      FCurrentSong := FSongs[Index];
      if Assigned(FOnSongChange) then
        FOnSongChange(Self);
    end
    else
    begin
      FCurrentSong := '';
      FCurrentIndex := -1;
    end;
  end
  else
    Result := False;
end;

function TSongPlayer.Stop(StopMusic: Boolean): Boolean;
begin
  if SoundSystem <> nil then
  begin
    if StopMusic then
      Result := SoundSystem.StopSong
    else
      Result := False;
    FStatus := FStatus - [spPlaying];
  end
  else
    Result := False;
end;

{ Pauses count; the first one saves the song position. }
function TSongPlayer.Pause(StopMusic: Boolean): Boolean;
begin
  if FPauseCount = 0 then
  begin
    if FBackup <> nil then
      FBackup.Free;
    FBackup := BackupSongStatus;
    FStatus := FStatus + [spPaused];
    if StopMusic then
      SoundSystem.StopSong;
  end;
  Inc(FPauseCount);
  Result := True;
end;

function TSongPlayer.Resume: Boolean;
begin
  Dec(FPauseCount);
  if FPauseCount = 0 then
  begin
    if FBackup <> nil then
    begin
      FCurrentIndex := FSongs.IndexOf(FBackup.FFileName);
      if FCurrentIndex = -1 then
        Play(0)
      else
        RestoreSongStatus(FBackup);
      FBackup.Free;
      FBackup := nil;
    end;
    FStatus := FStatus - [spPaused];
  end;
  Result := True;
end;

{ TSFX }

class function TSFX.ClassID: Integer;
begin
  Result := $210001;
end;

procedure TSFX.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smText in Stream.StorageMode) then
    Stream.rwString(FFileName, 5);
end;

function TSFX.Play: TSample;
begin
  Result := PlaySample(FFileName);
end;

function TSFX.PlayEx(Volume: Integer; Looped: Boolean; Delay: Integer;
  Panning: TSamplePanning; CallBack: TSampleCallBack): TSample;
begin
  Result := PlaySampleEx(FFileName, Volume, Looped, Delay, Panning, CallBack);
end;

{ TSFXSequence }

class function TSFXSequence.ClassID: Integer;
begin
  Result := $210002;
end;

function TSFXSequence.GetSFX(Index: Integer): TSFX;
begin
  Result := TENodeAccess(Self).FChildren.List^[Index];
end;

procedure TSFXSequence.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FID, 5);
end;

function TSFXSequence.Play: TSample;
begin
  if TENodeAccess(Self).FChildren.Count <> 0 then
    Result := TSFX(TENodeAccess(Self).FChildren.List^[Random(TENodeAccess(Self).FChildren.Count)]).Play
    else
      Result := nil;
end;

function TSFXSequence.PlayEx(Volume: Integer; Looped: Boolean; Delay: Integer;
  Panning: TSamplePanning; CallBack: TSampleCallBack): TSample;
begin
  if TENodeAccess(Self).FChildren.Count <> 0 then
    Result := TSFX(TENodeAccess(Self).FChildren.List^[Random(TENodeAccess(Self).FChildren.Count)]).
      PlayEx(Volume, Looped, Delay, Panning, CallBack)
    else
      Result := nil;
end;

{ TSFXLibrary }

class function TSFXLibrary.ClassID: Integer;
begin
  Result := $210003;
end;

function TSFXLibrary.GetSFXSequence(Index: Integer): TSFXSequence;
begin
  if (Index >= 0) and (Index < TENodeAccess(Self).FChildren.Count) then
    Result := TENodeAccess(Self).FChildren.List^[Index]
  else
    Result := nil;
end;

function TSFXLibrary.Play(ID: Integer): TSample;
var
  S: TSFXSequence;
begin
  S := Find(ID);
  if S <> nil then
    Result := S.Play
  else
    Result := nil;
end;

function TSFXLibrary.PlayEx(ID, Volume: Integer; Looped: Boolean; Delay: Integer;
  Panning: TSamplePanning; CallBack: TSampleCallBack): TSample;
var
  S: TSFXSequence;
begin
  S := Find(ID);
  if S <> nil then
    Result := S.PlayEx(Volume, Looped, Delay, Panning, CallBack)
  else
    Result := nil;
end;

function TSFXLibrary.Find(ID: Integer): TSFXSequence;
var
  I: Integer;
begin
  I := 0;
  Result := nil;
  while (I <> TENodeAccess(Self).FChildren.Count) and (Result = nil) do
  begin
    if TSFXSequence(TENodeAccess(Self).FChildren.List^[I]).FID = ID then
      Result := TSFXSequence(TENodeAccess(Self).FChildren.List^[I]);
    Inc(I);
  end;
end;

{ The first ID that two sequences share, -1 when the IDs are unique. }
function TSFXLibrary.DoubleID: Integer;
var
  I, J, ID: Integer;
begin
  I := 0;
  Result := -1;
  while (Result = -1) and (I <> Count) do
  begin
    ID := TSFXSequence(TENodeAccess(Self).FChildren.List^[I]).FID;
    for J := I + 1 to Count - 1 do
      if ID = TSFXSequence(TENodeAccess(Self).FChildren.List^[J]).FID then
        Result := ID;
    Inc(I);
  end;
end;

{ TSoundSystem }

constructor TSoundSystem.Create;
begin
  inherited Create;
  FRefCount := 1;
end;

destructor TSoundSystem.Destroy;
begin
  if ssActivated in FStatus then
    Deactivate;
  inherited Destroy;
end;

function TSoundSystem.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then
    Destroy;
end;

function TSoundSystem.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

{ Unit routines }

{ Loads the sound data (or adds a reference) so that it stays loaded between samples. }
procedure LockSampleData(Name: string);
var
  D: TSampleData;
begin
  if SoundSystem <> nil then
  begin
    D := SampleDataList.Find(Name);
    if D = nil then
      SoundSystem.SampleDataClass.Create(Name)
    else
      D.AddRef;
  end;
end;

procedure UnlockSampleData(Name: string);
var
  D: TSampleData;
begin
  D := SampleDataList.Find(Name);
  if D <> nil then
    D.Release;
end;

function CreateSampleData(const Name: string): TSampleData;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.SampleDataClass.Create(Name)
  else
    Result := nil;
end;

function CreateSampleDataEx(Format: PWaveFormatEx; Data: Pointer; Size: Integer): TSampleData;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.SampleDataClass.CreateEx(Format, Data, Size)
  else
    Result := nil;
end;

function CreateSample(SampleData: TSampleData): TSample;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.SampleClass.Create(SampleData)
  else
    Result := nil;
end;

function PlaySample(Name: string): TSample;
var
  D: TSampleData;
begin
  if (SoundSystem <> nil) and SoundSystem.SFXEnabled then
    try
      D := SampleDataList.Find(Name);
      if D = nil then
      begin
        D := SoundSystem.SampleDataClass.Create(Name);
        Result := SoundSystem.SampleClass.Create(D);
        D.Release;
      end
      else
        Result := SoundSystem.SampleClass.Create(D);
      Result.Execute;
    except
      Result := nil;
    end
  else
    Result := nil;
end;

function PlaySampleEx(Name: string; Volume: Integer; Looped: Boolean; Delay: Integer;
  Panning: TSamplePanning; CallBack: TSampleCallBack): TSample;
var
  D: TSampleData;
begin
  if (SoundSystem <> nil) and SoundSystem.SFXEnabled then
    try
      D := SampleDataList.Find(Name);
      if D = nil then
      begin
        D := SoundSystem.SampleDataClass.Create(Name);
        Result := SoundSystem.SampleClass.Create(D);
        D.Release;
      end
      else
        Result := SoundSystem.SampleClass.Create(D);
      Result.Looped := Looped;
      Result.FDelay := Delay;
      Result.Panning := Panning;
      Result.FCallBack := CallBack;
      Result.Volume := Volume;
      Result.Execute;
    except
      Result := nil;
    end
  else
    Result := nil;
end;

function SamplesActive: Integer;
begin
  Result := SampleList.Count;
end;

function SamplesLoaded: Integer;
begin
  Result := SampleDataList.Count;
end;

{ TSoundSystemList }

function TSoundSystemList.Find(Name: string): TSoundSystemClass;
var
  I: Integer;
begin
  I := 0;
  while (I <> Count) and (CompareText(Name, TSoundSystemClass(List^[I]).GetName) <> 0) do
    Inc(I);
  if I <> Count then
    Result := List^[I]
  else
    Result := nil;
end;

procedure RegisterSoundSystem(AClass: TSoundSystemClass);
begin
  if SoundSystems = nil then
    SoundSystems := TSoundSystemList.Create;
  if SoundSystems.Find(AClass.GetName) = nil then
    SoundSystems.Add(AClass)
  else
    raise Exception.Create('Sound System with name: ' + AClass.GetName + ' already registered');
end;

{ Creates and activates the named sound system (the first registered one when Name is empty). }
function InitializeSoundSystem(Name: string; const Settings: TSoundSettings): Boolean;
var
  C: TSoundSystemClass;
begin
  Result := True;
  if Name = '' then
  begin
    if SoundSystems.Count <> 0 then
      C := SoundSystems[0]
    else
      C := nil;
  end
  else
    C := SoundSystems.Find(Name);
  if C <> nil then
  begin
    if SoundSystem <> nil then
      ReleaseSoundSystem;
    SoundSystem := C.Create;
    if not SoundSystem.Activate(Settings) then
    begin
      SoundSystem.Free;
      SoundSystem := nil;
      Result := False;
    end;
  end
  else
    Result := False;
end;

procedure ReleaseSoundSystem;
begin
  if SoundSystem <> nil then
  begin
    if SongPlayer <> nil then
      SongPlayer.Stop(True);
    if SampleList <> nil then
      SampleList.Clear;
    SoundSystem.Release;
    SoundSystem := nil;
  end;
end;

function SoundSystemStatus: TSoundSystemStatus;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.FStatus
  else
    Result := [];
end;

procedure SetMusicVolume(Volume: Integer);
begin
  if SoundSystem <> nil then
    SoundSystem.SetMusicVolume(Volume);
end;

procedure FadeMusicVolume(Volume, Speed: Integer);
begin
  if SoundSystem <> nil then
    SoundSystem.FadeMusicVolume(Volume, Speed);
end;

function GetMusicVolume: Integer;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.GetMusicVolume
  else
    Result := -1;
end;

procedure SetSFXVolume(Volume: Integer);
begin
  if SoundSystem <> nil then
    SoundSystem.SetSFXVolume(Volume);
end;

function GetSFXVolume: Integer;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.GetSFXVolume
  else
    Result := -1;
end;

function GetMusicEnabled: Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.GetMusicEnabled
  else
    Result := False;
end;

function SetMusicEnabled(Value: Boolean): Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.SetMusicEnabled(Value)
  else
    Result := False;
end;

function GetSFXEnabled: Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.GetSFXEnabled
  else
    Result := False;
end;

function SetSFXEnabled(Value: Boolean): Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.SetSFXEnabled(Value)
  else
    Result := False;
end;

function GetSoundSettings: TSoundSettings;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.GetSoundSettings
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function SetSoundSettings(const Settings: TSoundSettings): Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.SetSoundSettings(Settings)
  else
    Result := False;
end;

function BackupSongStatus: TSongStatus;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.BackupSongStatus
  else
    Result := nil;
end;

function RestoreSongStatus(Status: TSongStatus): Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.RestoreSongStatus(Status)
  else
    Result := False;
end;

{ The title stored in an Impulse Tracker or Scream Tracker 3 module, else the file name without
  the extension. }
function GetSongName(FileName: string): string;
var
  Stream: TFileStream;
  Ext: string;
  Title: array[0..27] of Char;
  P: Integer;
begin
  Stream := TFileStream.Create(BaseSoundEnginePath + FileName, fmOpenRead or fmShareDenyWrite);
  try
    Ext := UpperCase(ExtractFileExt(FileName));
    FillChar(Title, SizeOf(Title), 0);
    if Ext = '.IT' then
    begin
      Stream.Seek(4, 0);
      Stream.Read(Title, SizeOf(Title));
      Result := StrPas(Title);
    end
    else if Ext = '.S3M' then
    begin
      Stream.Read(Title, SizeOf(Title));
      Result := StrPas(Title);
    end
    else
    begin
      Result := ExtractFileName(FileName);
      P := Pos('.', Result);
      if P <> 0 then
        Result := Copy(Result, 1, P - 1);
    end;
  finally
    Stream.Free;
  end;
end;

function PlayingSongFileName: string;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.GetPlayingSongFileName
  else
    Result := '';
end;

function PlaySong(FileName: string): Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.PlaySong(FileName)
  else
    Result := False;
end;

function PlaySongEx(FileName: string; FadeOut, FadeIn: Integer; Loop: Boolean): Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.PlaySongEx(FileName, FadeOut, FadeIn, Loop)
  else
    Result := False;
end;

function StopSong: Boolean;
begin
  if SoundSystem <> nil then
    Result := SoundSystem.StopSong
  else
    Result := False;
end;

procedure ProcessSound;
var
  I: Integer;
begin
  if SampleList <> nil then
    for I := SampleList.Count - 1 downto 0 do
      TSample(SampleList.List^[I]).Update;
  if SongPlayer <> nil then
    SongPlayer.Update;
  if SoundSystem <> nil then
    SoundSystem.Process;
end;

procedure RegisterSoundEngineClasses(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TSFXSequence, TSFXLibrary, TSFX]);
end;

procedure UnregisterSoundEngineClasses(AEngine: TEngine);
begin
  AEngine.UnregisterEClasses([TSFXSequence, TSFXLibrary, TSFX]);
end;

procedure Register;
begin
  RegisterComponents('Sound', [TSFXManager, TSFXManagerComboBox, TSFXManagerListBox]);
end;

initialization
  if ToolServices <> nil then
    BaseSoundEnginePath := ExtractFilePath(ToolServices.GetProjectName)
  else
    BaseSoundEnginePath := ExtractFilePath(Application.ExeName);
  SampleList := TSampleList.Create;
  SampleDataList := TSampleDataList.Create;
  if SoundSystems = nil then
    SoundSystems := TSoundSystemList.Create;
  SongPlayer := TSongPlayer.Create;

finalization
  SongPlayer.Free;
  SongPlayer := nil;
  SampleList.Free;
  SampleList := nil;
  if SampleDataList.Count <> 0 then
    ShowMessage('Inproper use of Sound Engine (SoundData still loaded)!');
  SampleDataList.Free;
  SampleDataList := nil;
  if SoundSystem <> nil then
    SoundSystem.Release;
  SoundSystems.Free;
end.
