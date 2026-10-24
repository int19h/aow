unit PlugInM;

{ The PlugInM unit of Enginep.dpl written for the original compiler (Delphi 3.02): TPlugInManager,
  a component that finds the plug-in packages below a directory and loads and unloads them.
  Declarations follow the original instance layout (data/classes.json) and the published
  properties in data/rtti; tools/match.py compares every method with the game's module. }

interface

uses
  Windows, SysUtils, Classes, Dialogs;

type
  TLoadPlugInEvent = procedure(Sender: TObject; const FileName: string) of object;

  { PlugInM.TPlugInManager (instance size 60): +$24 FPlugIns (file names, Objects the package
    handles), +$28 FPlugInsLoaded, +$2C FPlugInDirectory, +$30 FPlugInExtension ('dpl'),
    +$34 FOnLoadPlugIn. }
  TPlugInManager = class(TComponent)
  private
    FPlugIns: TStringList;
    FPlugInsLoaded: Boolean;
    FPlugInDirectory: string;
    FPlugInExtension: string;
    FOnLoadPlugIn: TLoadPlugInEvent;
    procedure ExecutePlugInSearch(Directory: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadPlugIns(const Directory: string);
    procedure ReleasePlugIns;
    property PlugIns: TStringList read FPlugIns;
  published
    property PlugInsLoaded: Boolean read FPlugInsLoaded;
    property PlugInDirectory: string read FPlugInDirectory;
    property PlugInExtension: string read FPlugInExtension write FPlugInExtension;
    property OnLoadPlugIn: TLoadPlugInEvent read FOnLoadPlugIn write FOnLoadPlugIn;
  end;

procedure Register;

implementation

{ TPlugInManager }

constructor TPlugInManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPlugIns := TStringList.Create;
  FPlugInExtension := 'dpl';
end;

destructor TPlugInManager.Destroy;
begin
  ReleasePlugIns;
  FPlugIns.Free;
  inherited Destroy;
end;

procedure TPlugInManager.ExecutePlugInSearch(Directory: string);
var
  Dir: string;

  procedure SearchDir(Dir: string);
  var
    SR: TSearchRec;
    Dirs: TStringList;
    I: Integer;
    Found: Boolean;
  begin
    Found := FindFirst(Dir + '*.' + FPlugInExtension, faAnyFile - faDirectory, SR) = 0;
    while Found do
    begin
      FPlugIns.Add(Dir + SR.Name);
      Found := FindNext(SR) = 0;
    end;
    FindClose(SR);
    Dirs := TStringList.Create;
    Found := FindFirst(Dir + '*.*', faDirectory, SR) = 0;
    while Found do
    begin
      if (SR.Attr and faDirectory <> 0) and (SR.Name <> '.') and (SR.Name <> '..') then
        Dirs.Add(Dir + SR.Name + '\');
      Found := FindNext(SR) = 0;
    end;
    FindClose(SR);
    for I := 0 to Dirs.Count - 1 do SearchDir(Dirs[I]);
    Dirs.Free;
  end;

begin
  Dir := Directory;
  SearchDir(Dir);
end;

procedure TPlugInManager.LoadPlugIns(const Directory: string);
var
  I: Integer;
begin
  ReleasePlugIns;
  FPlugInDirectory := ExpandFileName(Directory);
  if (FPlugInDirectory <> '') and (FPlugInDirectory[Length(FPlugInDirectory)] <> '\') then
    FPlugInDirectory := FPlugInDirectory + '\';
  ExecutePlugInSearch(FPlugInDirectory);
  FPlugInsLoaded := False;
  with FPlugIns do
    for I := 0 to Count - 1 do
    begin
      try
        if Assigned(FOnLoadPlugIn) then FOnLoadPlugIn(Self, Strings[I]);
        Objects[I] := TObject(LoadPackage(Strings[I]));
        FPlugInsLoaded := True;
      except
        ShowMessage('Unable to load PlugIn: ' + Strings[I]);
        Objects[I] := nil;
      end;
    end;
end;

procedure TPlugInManager.ReleasePlugIns;
var
  I: Integer;
begin
  with FPlugIns do
    for I := Count - 1 downto 0 do
    begin
      try
        if Objects[I] <> nil then
        begin
          UnloadPackage(HMODULE(Objects[I]));
          Objects[I] := nil;
        end;
      except
        ShowMessage('Could not release PlugIn: ' + Strings[I]);
        Objects[I] := nil;
      end;
      Delete(I);
    end;
end;

procedure Register;
begin
  RegisterComponents('Engine', [TPlugInManager]);
end;

end.
