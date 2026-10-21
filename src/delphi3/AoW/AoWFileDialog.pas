unit AoWFileDialog;

{ Draft declarations of AoWFileDialog, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWComboBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TFileDlgWindow = class;


  { TFileDlgWindow (instance size 332, VMT 0041EB60) }
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
    F_FileDlgWindow_134: Integer;
    F_FileDlgWindow_138: Integer;
    F_FileDlgWindow_13C: Integer;
    F_FileDlgWindow_140: Integer;
    F_FileDlgWindow_144: Integer;
    F_FileDlgWindow_148: Integer;
    procedure CloseClick;  { draft }
    procedure FindDrives;  { draft }
    procedure FindFiles;  { draft }
    procedure FileDlgWindowCreate;  { draft }
    procedure FileDlgWindowDestroy;  { draft }
    procedure OpenbutClick;  { draft }
    procedure UpDirBtnClick;  { draft }
    procedure DriveCmbChange;  { draft }
    procedure FileLBChange(A1: Integer);  { draft }
    procedure FileDialogShow;  { draft }
    procedure mSBarChange(A1: Integer);  { draft }
    procedure SFileNameReturn;  { draft }
    procedure SFileNameChange(A1: Integer);  { draft }
    procedure SaveBtnClick;  { draft }
    procedure DateBtnClick;  { draft }
    procedure SSBarChange;  { draft }
    procedure FileDialogHide;  { draft }
    procedure FileDialogKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TFileDlgWindow.CloseClick;
begin end;

procedure TFileDlgWindow.FindDrives;
begin end;

procedure TFileDlgWindow.FindFiles;
begin end;

procedure TFileDlgWindow.FileDlgWindowCreate;
begin end;

procedure TFileDlgWindow.FileDlgWindowDestroy;
begin end;

procedure TFileDlgWindow.OpenbutClick;
begin end;

procedure TFileDlgWindow.UpDirBtnClick;
begin end;

procedure TFileDlgWindow.DriveCmbChange;
begin end;

procedure TFileDlgWindow.FileLBChange(A1: Integer);
begin end;

procedure TFileDlgWindow.FileDialogShow;
begin end;

procedure TFileDlgWindow.mSBarChange(A1: Integer);
begin end;

procedure TFileDlgWindow.SFileNameReturn;
begin end;

procedure TFileDlgWindow.SFileNameChange(A1: Integer);
begin end;

procedure TFileDlgWindow.SaveBtnClick;
begin end;

procedure TFileDlgWindow.DateBtnClick;
begin end;

procedure TFileDlgWindow.SSBarChange;
begin end;

procedure TFileDlgWindow.FileDialogHide;
begin end;

procedure TFileDlgWindow.FileDialogKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
