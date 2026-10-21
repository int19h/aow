unit AoWFileDialog;

{ Draft declarations of AoWFileDialog, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWButton, AoWComboBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TFileDlgWindow = class;


  { TFileDlgWindow (size $14C, VMT 0041EB60): $134 directory, $138 last filename, $13C save event, $140 done callback, $148 dialog mode. }
  TFileDlgWindow = class(TDataModule)
  public
    published
    FileDialog: TAOWWindow; { +0044 }
    CancelBut: TAOWButton; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    Openbut: TAOWButton; { +0050 }
    Title: TAOWLabel; { +0054 }
    FileLB: TAOWListBox; { +0058 }
    FileName: TAOWEdit; { +005C }
    ScenLbl: TAOWLabel; { +0060 }
    DriveCmb: TAOWComboBox; { +0064 }
    DriveL: TAOWLabel; { +0068 }
    Close: TAOWButton; { +006C }
    UpDirBtn: TAOWButton; { +0070 }
    PathL: TAOWLabel; { +0074 }
    TitleIcon: TAOWImage; { +0078 }
    DriveSB: TAOWVScrollBar; { +007C }
    CeltM: TAOWImage; { +0080 }
    LPlayersI: TAOWImage; { +0084 }
    LSavedInfo: TAOWPanel; { +0088 }
    LSizeI: TAOWImage; { +008C }
    LTownsI: TAOWImage; { +0090 }
    LTurnsI: TAOWImage; { +0094 }
    LPlayers: TAOWLabel; { +0098 }
    LSize: TAOWLabel; { +009C }
    LTowns: TAOWLabel; { +00A0 }
    LTurns: TAOWLabel; { +00A4 }
    CeltL: TAOWImage; { +00A8 }
    CeltR: TAOWImage; { +00AC }
    TCeltL: TAoWFrame; { +00B0 }
    TCelt: TAOWImage; { +00B4 }
    SPlayersI: TAOWImage; { +00B8 }
    NewInfo: TAOWPanel; { +00BC }
    SSizeI: TAOWImage; { +00C0 }
    STownsI: TAOWImage; { +00C4 }
    SPlayers: TAOWLabel; { +00C8 }
    SSize: TAOWLabel; { +00CC }
    STowns: TAOWLabel; { +00D0 }
    NewPnl: TAOWPanel; { +00D4 }
    SaveLB: TAOWListBox; { +00D8 }
    SFileName: TAOWEdit; { +00DC }
    SavedInfo: TAOWLabel; { +00E0 }
    SavePnl: TAOWPanel; { +00E4 }
    DateLB: TAOWListBox; { +00E8 }
    SaveBtn: TAOWButton; { +00EC }
    DateBtn: TAOWButton; { +00F0 }
    NSBar: TAOWVScrollBar; { +00F4 }
    DriveFr: TAOWPanel; { +00F8 }
    TopPnl: TAOWPanel; { +00FC }
    PathFr: TAOWPanel; { +0100 }
    PathEdit: TAOWEdit; { +0104 }
    NewLBFr: TAOWPanel; { +0108 }
    NewInfo1: TAOWPanel; { +010C }
    NewInfo2: TAOWPanel; { +0110 }
    NewInfo3: TAOWPanel; { +0114 }
    SaveLBFr: TAOWPanel; { +0118 }
    SSBar: TAOWVScrollBar; { +011C }
    SavedInfo1: TAOWPanel; { +0120 }
    SavedInfo2: TAOWPanel; { +0124 }
    SavedInfo3: TAOWPanel; { +0128 }
    SavedInfo4: TAOWPanel; { +012C }
    Translator: TIvTranslator; { +0130 }
    public
    FDirectory: string; { $134 }
    FLastFileName: string; { $138 }
    FSaveEvent: TSaveGameEventLog; { $13C }
    FDone: TExecuteDoneEvent; { $140 }
    { $144 is the data pointer of FDone. }
    FMode: Integer; { $148; 0 load, 1 save, 2 select map }
    procedure FinishDialog;
    procedure CloseClick;  { draft }
    procedure FindDrives;
    procedure FindFiles;
    procedure FileDlgWindowCreate;
    procedure FileDlgWindowDestroy;
    procedure OpenbutClick(Sender: TObject);  { draft }
    procedure UpDirBtnClick;
    procedure DriveCmbChange;
    procedure FileLBChange(Sender: TAOWListBox);
    procedure FileDialogShow;
    procedure mSBarChange(Sender: TAOWVScrollBar);
    procedure SFileNameReturn;
    procedure SFileNameChange(A1: Integer);
    procedure SaveBtnClick(Sender: TObject);
    procedure DateBtnClick(Sender: TObject);
    procedure SSBarChange;
    procedure FileDialogHide;
    procedure FileDialogKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


var
  FileDlgWindow: TFileDlgWindow;

implementation

uses AoWWorldMap, AoWWinMan;

var
  Drives, Directories, Files: TStringList;

function CompareFileDates(const S1, S2: string; O1, O2: TObject): Integer;
begin
  if (O1 = nil) and (O2 = nil) then Result := CompareText(S1, S2)
  else if O1 = nil then Result := -1
  else if O2 = nil then Result := 1
  else if AoWWorldMap.TFileTime(O2).FTime > AoWWorldMap.TFileTime(O1).FTime then Result := 1
  else if AoWWorldMap.TFileTime(O2).FTime < AoWWorldMap.TFileTime(O1).FTime then Result := -1
  else Result := 0;
end;


procedure TFileDlgWindow.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Event: TSaveGameEventLog;
begin
  Done := FDone;
  Event := FSaveEvent;
  FDone := nil;
  FSaveEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

procedure TFileDlgWindow.CloseClick;
begin
  General.PlayButtonSound(0);
  if FSaveEvent <> nil then
  begin
    if not (sgmDisableCancel in FSaveEvent.FMode) then FileDialog.Visible := False;
  end
  else FileDialog.Visible := False;
end;

procedure TFileDlgWindow.FindDrives;
type
  TVolumeName = string[26];
var
  Drive: string;
  Flags, Maximum: DWORD;
  Separator: Char;
  Selected, I: Integer;
  Volume: array[0..25] of Char;
  Mask: set of 0..31;
begin
  Drives.Clear;
  Integer(Mask) := GetLogicalDrives;
  Selected := 1;
  for I := 0 to 25 do
    if I in Mask then
    begin
      Volume := '';
      Drive := Chr(Ord('A') + I) + ':\';
      if I < 2 then Separator := #0
      else
      begin
        Separator := ' ';
        if GetDriveType(PChar(Drive)) = DRIVE_REMOTE then Separator := #0
        else GetVolumeInformation(PChar(Drive), Volume, 25, nil, Maximum, Flags, nil, 0);
      end;
      Drives.Add(TVolumeName(Volume) + Separator + '(' + Drive + ')');
      if Drive = ExtractFileDrive(GetCurrentDir) + '\' then Selected := Drives.Count - 1;
    end;
  DriveCmb.Items.Clear;
  DriveCmb.Items.AddStrings(Drives);
  DriveCmb.Selected := Selected;
  FindFiles;
end;

procedure TFileDlgWindow.FindFiles;
var
  IncludeFile: Boolean;
  Extension, Directory: string;
  I: Integer;
  Search: TSearchRec;
  Stamp: AoWWorldMap.TFileTime;
begin
  for I := 0 to DateLB.Items.Count - 1 do
    if DateLB.Items.Objects[I] <> nil then DateLB.Items.Objects[I].Free;
  Directories.Clear;
  Files.Clear;
  SPlayers.Text := '';
  SSize.Text := '';
  STowns.Text := '';
  LPlayers.Text := '';
  LSize.Text := '';
  LTowns.Text := '';
  LTurns.Text := '';
  Directory := GetCurrentDir;
  if Copy(Directory, Length(Directory), 1) = '\' then Directory := Copy(Directory, 1, Length(Directory) - 1);
  if FindFirst(Directory + '\**', faDirectory, Search) = 0 then
    repeat
      if (Search.Name <> '.') and (Search.Name <> '..') then
        if (Search.Attr and faDirectory) = faDirectory then Directories.Add(Search.Name)
        else
        begin
          IncludeFile := False;
          Extension := LowerCase(ExtractFileExt(Search.Name));
          IncludeFile := IncludeFile or ((FMode = 1) and (AoWEngine.FCampaign <> nil) and (Extension = '.acg'));
          IncludeFile := IncludeFile or ((FMode = 1) and (AoWEngine.FCampaign = nil) and (Extension = '.asg'));
          IncludeFile := IncludeFile or ((FMode = 0) and ((Extension = '.asg') or (Extension = '.acg')));
          { Original accepts .asg in every mode, including map selection. }
          IncludeFile := IncludeFile or ((FMode = 2) and (Extension = '.hsm')) or (Extension = '.asg');
          if IncludeFile then
          begin
            Stamp := AoWWorldMap.TFileTime.Create;
            Stamp.FTime := FileDateToDateTime(Search.Time);
            Files.AddObject(Search.Name, Stamp);
          end;
        end;
    until FindNext(Search) <> 0;
  FindClose(Search);
  FileLB.Selected := -1;
  SaveLB.Selected := -1;
  DateLB.Selected := -1;
  FileLB.ListOffset := 0;
  SaveLB.ListOffset := 0;
  DateLB.ListOffset := 0;
  FileLB.Items.Clear;
  SaveLB.Items.Clear;
  DateLB.Items.Clear;
  Directories.Sort;
  Files.Sort;
  FileLB.Items.AddStrings(Directories);
  FileLB.Items.AddStrings(Files);
  SaveLB.Items.AddStrings(FileLB.Items);
  PathEdit.Text := Directory + '\';
  for I := 0 to Directories.Count - 1 do DateLB.Items.Add('');
  for I := 0 to Files.Count - 1 do
    DateLB.Items.AddObject(DateTimeToStr(AoWWorldMap.TFileTime(Files.Objects[I]).FTime), Files.Objects[I]);
end;

procedure TFileDlgWindow.FileDlgWindowCreate;
begin
  Drives := TStringList.Create;
  Directories := TStringList.Create;
  Files := TStringList.Create;
  FDirectory := AoWEngine.StartupDirectory + 'Save\';
  FLastFileName := '';
end;

procedure TFileDlgWindow.FileDlgWindowDestroy;
var
  I: Integer;
begin
  for I := 0 to DateLB.Items.Count - 1 do
    if DateLB.Items.Objects[I] <> nil then DateLB.Items.Objects[I].Free;
  Drives.Free;
  Directories.Free;
  Files.Free;
end;

procedure TFileDlgWindow.OpenbutClick(Sender: TObject);
begin end;

procedure TFileDlgWindow.UpDirBtnClick;
begin
  General.PlayButtonSound(0);
  if SetCurrentDir('..') then FindFiles;
end;

procedure TFileDlgWindow.DriveCmbChange;
begin
  if SetCurrentDir(Copy(DriveCmb.Items[DriveCmb.Selected], Length(DriveCmb.Items[DriveCmb.Selected]) - 3, 3)) then FindFiles
  else FindDrives;
end;

procedure TFileDlgWindow.FileLBChange(Sender: TAOWListBox);
var
  Map: TAoWHSMap;
begin
  FileLB.Selected := Sender.Selected;
  SaveLB.Selected := Sender.Selected;
  DateLB.Selected := Sender.Selected;
  if Directories.Count - 1 < FileLB.Selected then
  begin
    SFileName.Text := FileLB.Items[FileLB.Selected];
    if LowerCase(ExtractFileExt(SFileName.Text)) = '.acg' then
    begin
      LPlayers.Text := '';
      LSize.Text := '';
      LTowns.Text := '';
      LTurns.Text := '';
    end
    else
    begin
      Map := TAoWHSMap(AoWEngine.CreatePreviewHSM(SFileName.Text));
      if Map = nil then
      begin
        LPlayers.Text := '';
        LSize.Text := '';
        LTowns.Text := '';
        LTurns.Text := '';
      end
      else
      begin
        LPlayers.Text := IntToStr(Map.FPlayers.GetCount - 1);
        case Map.MapContainer.Width of
          48: LSize.Text := TranslateRStr(SmallMapAbrRStr);
          64: LSize.Text := TranslateRStr(MediumMapAbrRStr);
          96: LSize.Text := TranslateRStr(LargeMapAbrRStr);
          127,128: LSize.Text := TranslateRStr(ExtraLargeMapAbrRStr);
        else LSize.Text := '?';
        end;
        LTowns.Text := IntToStr(Map.FStructureControl.FCityCount);
        LTurns.Text := IntToStr(Map.FDay);
        Map.Free;
      end;
    end;
  end
  else
  begin
    LPlayers.Text := '';
    LSize.Text := '';
    LTowns.Text := '';
    LTurns.Text := '';
  end;
  FileName.Text := SFileName.Text;
  SPlayers.Text := LPlayers.Text;
  SSize.Text := LSize.Text;
  STowns.Text := LTowns.Text;
end;

procedure TFileDlgWindow.FileDialogShow;
begin
  case FMode of
  0: begin
    SetCurrentDir(FDirectory);
    SFileName.Text := ExtractFileName(FLastFileName);
    FileName.Text := SFileName.Text;
    FileDlgWindow.Title.Text := TranslateRStr(SelectAFileToLoadRStr);
    FileDlgWindow.SFileName.Editable := False;
    FileDlgWindow.Openbut.Text := TranslateRStr(OpenRStr);
    SavePnl.Visible := True;
    NewPnl.Visible := False;
  end;
  1: begin
    SetCurrentDir(FDirectory);
    SFileName.Text := ExtractFileName(FLastFileName);
    if Pos('.', SFileName.Text) <> 0 then SFileName.Text := Copy(SFileName.Text, 1, Pos('.', SFileName.Text) - 1);
    if SFileName.Text <> '' then
      if AoWEngine.FCampaign <> nil then SFileName.Text := SFileName.Text + '.acg'
      else SFileName.Text := SFileName.Text + '.asg';
    FileName.Text := SFileName.Text;
    FileDlgWindow.Title.Text := TranslateRStr(SaveGameAsRStr);
    FileDlgWindow.SFileName.Editable := True;
    FileDlgWindow.Openbut.Text := TranslateRStr(SaveRStr);
    SavePnl.Visible := True;
    NewPnl.Visible := False;
  end;
  2: begin
    if ExtractFileExt(FLastFileName) = '.hsm' then FileName.Text := ExtractFileName(FLastFileName)
    else FileName.Text := '';
    SetCurrentDir(AoWEngine.StartupDirectory + 'Scenario\Custom\');
    FileDlgWindow.Title.Text := TranslateRStr(SelectAMapRStr);
    FileDlgWindow.Openbut.Text := TranslateRStr(SelectRStr);
    SavePnl.Visible := False;
    NewPnl.Visible := True;
  end;
  end;
  FileDlgWindow.FindDrives;
end;

procedure TFileDlgWindow.mSBarChange(Sender: TAOWVScrollBar);
begin
  FileLB.ListOffset := Sender.Position;
  SaveLB.ListOffset := Sender.Position;
  DateLB.ListOffset := Sender.Position;
end;

procedure TFileDlgWindow.SFileNameReturn;
begin
  OpenbutClick(Self);
end;

procedure TFileDlgWindow.SFileNameChange(A1: Integer);
begin
  FileLB.Selected := -1;
  FileLBChange(FileLB);
end;

procedure TFileDlgWindow.SaveBtnClick(Sender: TObject);
var
  Selected: string;
  I: Integer;
begin
  General.PlayButtonSound(0);
  if FileLB.Selected <> -1 then Selected := FileLB.Items[FileLB.Selected];
  for I := 0 to Directories.Count - 1 do
  begin
    SaveLB.Items.Delete(0);
    DateLB.Items.Delete(0);
  end;
  if (FMode = 1) or (FMode = 0) then
  begin
    SortStringsAscending(SaveLB.Items, [DateLB.Items, FileLB.Items]);
    FileLB.Items.Assign(SaveLB.Items);
  end
  else if FMode = 2 then SortStringsAscending(FileLB.Items, [DateLB.Items, SaveLB.Items]);
  for I := 0 to Directories.Count - 1 do
  begin
    SaveLB.Items.Insert(I, Directories[I]);
    DateLB.Items.Insert(I, '');
  end;
  if Selected <> '' then FileLB.Selected := FileLB.Items.IndexOf(Selected);
  FileLBChange(FileLB);
end;

procedure TFileDlgWindow.DateBtnClick(Sender: TObject);
var
  Selected: string;
  I: Integer;
begin
  General.PlayButtonSound(0);
  if FileLB.Selected <> -1 then Selected := FileLB.Items[FileLB.Selected];
  if (FMode = 1) or (FMode = 0) then
  begin
    for I := 0 to SaveLB.Items.Count - 1 do SaveLB.Items.Objects[I] := DateLB.Items.Objects[I];
    SortStringsEx(SaveLB.Items, CompareFileDates, [DateLB.Items, FileLB.Items]);
  end
  else if FMode = 2 then
  begin
    for I := 0 to FileLB.Items.Count - 1 do FileLB.Items.Objects[I] := DateLB.Items.Objects[I];
    SortStringsEx(FileLB.Items, CompareFileDates, [DateLB.Items, SaveLB.Items]);
  end;
  if Selected <> '' then FileLB.Selected := FileLB.Items.IndexOf(Selected);
  FileLBChange(FileLB);
end;

procedure TFileDlgWindow.SSBarChange;
begin
  SaveLB.ListOffset := SSBar.Position;
end;

procedure TFileDlgWindow.FileDialogHide;
begin
  FinishDialog;
end;

procedure TFileDlgWindow.FileDialogKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then FileDialog.Visible := False;
end;


end.
