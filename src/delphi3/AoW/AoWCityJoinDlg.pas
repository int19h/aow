unit AoWCityJoinDlg;

{ Draft declarations of AoWCityJoinDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWComp, AoWArnoLine, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWWindow;

type
  TCityJoinDlg = class;


  { TCityJoinDlg (size $90, VMT 004371B4): $80 race, $84 completion event, $8C retained negotiation event. }
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
    FRace: Shortint; { $80 }
    FReserved81: array[0..2] of Byte;
    FDone: TExecuteDoneEvent; { $84 }
    FEvent: TNegotiateRequestEventLog; { $8C }
    procedure FinishDialog; { 004373A8 }
    procedure AcceptBtnClick;  { draft }
    procedure AttackBtnClick;  { draft }
    procedure CancelBtnClick;  { draft }
    procedure DlgDrawBack(Sender: TObject; Surface: TSurfaceDesc);
    procedure DlgHide;  { draft }
    procedure CloseBtnClick;  { draft }
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses AoWWinMan;

procedure TCityJoinDlg.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Log: TNegotiateRequestEventLog;
begin
  Done := FDone;
  Log := FEvent;
  FDone := nil;
  FEvent := nil;
  if Assigned(Done) then Done(Log);
  if Log <> nil then Log.Release;
end;


procedure TCityJoinDlg.AcceptBtnClick;
var
  Reason: string;
begin
  General.PlayButtonSound(0);
  if not FEvent.Accept(Reason) then AoWHSMap.ShowWarning(Reason)
  else Dlg.Visible := False;
end;

procedure TCityJoinDlg.AttackBtnClick;
var
  Reason: string;
begin
  General.PlayButtonSound(0);
  if not FEvent.Reject(Reason) then AoWHSMap.ShowWarning(Reason)
  else Dlg.Visible := False;
end;

procedure TCityJoinDlg.CancelBtnClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TCityJoinDlg.DlgDrawBack(Sender: TObject; Surface: TSurfaceDesc);
var
  Face: TLibraryImage;
begin
  Face := AoWHSSet.FRaceResources.GetRaceResource(FRace).GetFace;
  with Face do
    if Face <> nil then ShowClipped(CeltFrame.WinLeft + 10, CeltFrame.WinTop + 28, Surface);
end;

procedure TCityJoinDlg.DlgHide;
begin
  FinishDialog;
end;

procedure TCityJoinDlg.CloseBtnClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TCityJoinDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then Dlg.Visible := False;
end;


end.
