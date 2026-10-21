unit AoWCityJoinDlg;

{ Draft declarations of AoWCityJoinDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWArnoLine, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWWindow;

type
  TCityJoinDlg = class;


  { TCityJoinDlg (instance size 144, VMT 004371B4) }
  TCityJoinDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    ApproachLbl: TAOWLabel; { +0048 }
    TCeltLineL: TAOWImage; { +004C }
    CeltFrame: TAoWFrame; { +0050 }
    BCeltL: TAoWFrame; { +0054 }
    Memo: TAOWMemo; { +0058 }
    CancelBtn: TAOWButton; { +005C }
    AttackBtn: TAOWButton; { +0060 }
    TitleIcon: TAOWImage; { +0064 }
    Title: TAOWLabel; { +0068 }
    AcceptBtn: TAOWButton; { +006C }
    WhatLbl: TAOWLabel; { +0070 }
    CityPicLine: TAoWArnoLine; { +0074 }
    CloseBtn: TAOWButton; { +0078 }
    Translator: TIvTranslator; { +007C }
    public
    F_CityJoinDlg_80: Byte;
    F_CityJoinDlg_81: array[0..10] of Byte;
    F_CityJoinDlg_8C: Byte;
    F_CityJoinDlg_8D: array[0..2] of Byte;
    procedure AcceptBtnClick;  { draft }
    procedure AttackBtnClick;  { draft }
    procedure CancelBtnClick;  { draft }
    procedure DlgDrawBack(A1: Integer; A2: Integer);  { draft }
    procedure DlgHide;  { draft }
    procedure CloseBtnClick;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TCityJoinDlg.AcceptBtnClick;
begin end;

procedure TCityJoinDlg.AttackBtnClick;
begin end;

procedure TCityJoinDlg.CancelBtnClick;
begin end;

procedure TCityJoinDlg.DlgDrawBack(A1: Integer; A2: Integer);
begin end;

procedure TCityJoinDlg.DlgHide;
begin end;

procedure TCityJoinDlg.CloseBtnClick;
begin end;

procedure TCityJoinDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
