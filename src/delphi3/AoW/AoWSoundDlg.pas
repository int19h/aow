unit AoWSoundDlg;

{ Draft declarations of AoWSoundDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TSoundDlg = class;


  { TSoundDlg (instance size 300, VMT 00420E44) }
  TSoundDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    CloseBut: TAOWButton; { +0048 }
    TCeltLL: TAOWImage; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    Title: TAOWLabel; { +0054 }
    SongLB: TAOWListBox; { +0058 }
    SongLbl: TAOWLabel; { +005C }
    Close: TAOWButton; { +0060 }
    PlayListPnl: TAOWPanel; { +0064 }
    SoundTab: TAOWTabPanel; { +0068 }
    PlayLB: TAOWListBox; { +006C }
    AddBtn: TAOWButton; { +0070 }
    RemoveBtn: TAOWButton; { +0074 }
    PlayBtn: TAOWButton; { +0078 }
    PlayLbl: TAOWLabel; { +007C }
    CurrentSongLbl: TAOWLabel; { +0080 }
    TCeltLR: TAOWImage; { +0084 }
    MusicVolLbl: TAOWLabel; { +0088 }
    SFXVolLbl: TAOWLabel; { +008C }
    MainPnl: TAOWPanel; { +0090 }
    SoundLbl: TAOWLabel; { +0094 }
    SettingsPnl: TAOWPanel; { +0098 }
    SFXLbl: TAOWLabel; { +009C }
    SQPnl: TAOWPanel; { +00A0 }
    SQCB1: TAOWCheckBox; { +00A4 }
    SQLBL1: TAOWLabel; { +00A8 }
    SQCB2: TAOWCheckBox; { +00AC }
    SQLBL2: TAOWLabel; { +00B0 }
    SQCB3: TAOWCheckBox; { +00B4 }
    SQLBL3: TAOWLabel; { +00B8 }
    SQCB4: TAOWCheckBox; { +00BC }
    SQLBL4: TAOWLabel; { +00C0 }
    SFXPnl: TAOWPanel; { +00C4 }
    MusicEnabledChk: TAOWCheckBox; { +00C8 }
    SFXLBL2: TAOWLabel; { +00CC }
    SFXEnabledChk: TAOWCheckBox; { +00D0 }
    SFXLBL3: TAOWLabel; { +00D4 }
    TopLine: TAoWFrame; { +00D8 }
    AOWImage4: TAOWImage; { +00DC }
    HarpL: TAOWImage; { +00E0 }
    HarpR: TAOWImage; { +00E4 }
    MusicVolume: TAOWHScrollBar; { +00E8 }
    SFXVolume: TAOWHScrollBar; { +00EC }
    TitleIcon: TAOWImage; { +00F0 }
    SongSB: TAOWVScrollBar; { +00F4 }
    PlaySB: TAOWVScrollBar; { +00F8 }
    DirectSoundEnabledChk: TAOWCheckBox; { +00FC }
    UseDirectSoundLbl: TAOWLabel; { +0100 }
    FolderPnl: TAOWPanel; { +0104 }
    PlayPnl: TAOWPanel; { +0108 }
    Translator: TIvTranslator; { +010C }
    public
    F_SoundDlg_110: Integer;
    F_SoundDlg_114: Byte;
    F_SoundDlg_115: array[0..2] of Byte;
    F_SoundDlg_118: Integer;
    F_SoundDlg_11C: Byte;
    F_SoundDlg_11D: Byte;
    F_SoundDlg_11E: array[0..5] of Byte;
    F_SoundDlg_124: Byte;
    F_SoundDlg_125: array[0..6] of Byte;
    procedure CloseClick;  { draft }
    procedure MusicVolumeChange;  { draft }
    procedure SFXVolumeChange;  { draft }
    procedure RemoveBtnClick;  { draft }
    procedure SoundSetup;  { draft }
    procedure PlayBtnClick;  { draft }
    procedure SongChange;  { draft }
    procedure FindFiles;  { draft }
    procedure SongLBChange;  { draft }
    procedure AddBtnClick;  { draft }
    procedure SoundDlgWindowCreate;  { draft }
    procedure SoundDlgWindowDestroy;  { draft }
    procedure PlayLBChange;  { draft }
    procedure SQCB1Change(A1: Integer);  { draft }
    procedure SQCB2Change(A1: Integer);  { draft }
    procedure SQCB3Change(A1: Integer);  { draft }
    procedure SQCB4Change(A1: Integer);  { draft }
    procedure PlayLBDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure MusicEnabledChkChange(A1: Integer);  { draft }
    procedure SFXEnabledChkChange(A1: Integer);  { draft }
    procedure DirectSoundEnabledChkChange(A1: Integer);  { draft }
    procedure SoundTabChange;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TSoundDlg.CloseClick;
begin end;

procedure TSoundDlg.MusicVolumeChange;
begin end;

procedure TSoundDlg.SFXVolumeChange;
begin end;

procedure TSoundDlg.RemoveBtnClick;
begin end;

procedure TSoundDlg.SoundSetup;
begin end;

procedure TSoundDlg.PlayBtnClick;
begin end;

procedure TSoundDlg.SongChange;
begin end;

procedure TSoundDlg.FindFiles;
begin end;

procedure TSoundDlg.SongLBChange;
begin end;

procedure TSoundDlg.AddBtnClick;
begin end;

procedure TSoundDlg.SoundDlgWindowCreate;
begin end;

procedure TSoundDlg.SoundDlgWindowDestroy;
begin end;

procedure TSoundDlg.PlayLBChange;
begin end;

procedure TSoundDlg.SQCB1Change(A1: Integer);
begin end;

procedure TSoundDlg.SQCB2Change(A1: Integer);
begin end;

procedure TSoundDlg.SQCB3Change(A1: Integer);
begin end;

procedure TSoundDlg.SQCB4Change(A1: Integer);
begin end;

procedure TSoundDlg.PlayLBDrawItem(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSoundDlg.MusicEnabledChkChange(A1: Integer);
begin end;

procedure TSoundDlg.SFXEnabledChkChange(A1: Integer);
begin end;

procedure TSoundDlg.DirectSoundEnabledChkChange(A1: Integer);
begin end;

procedure TSoundDlg.SoundTabChange;
begin end;

procedure TSoundDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
