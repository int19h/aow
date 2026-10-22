unit AoWCityRebelDlg;

{ Draft declarations of AoWCityRebelDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, City, WizardsTower, EventLog, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWWindow;

type
  TCityRebelDlg = class;


  { TCityRebelDlg (instance size $84, VMT 00436E98).
    $78 completion callback; $80 city-rebellion event. }
  TCityRebelDlg = class(TDataModule)
  public
    published
    RebelWin: TAOWWindow; { +0044 }
    Title: TAOWLabel; { +0048 }
    Close: TAOWButton; { +004C }
    TitleIcon: TAOWImage; { +0050 }
    BCeltL: TAoWFrame; { +0054 }
    CenterBut: TAOWButton; { +0058 }
    CloseBut: TAOWButton; { +005C }
    RebelBG: TAOWImage; { +0060 }
    CityNameLabel: TAOWLabel; { +0064 }
    AOWLabel2: TAOWLabel; { +0068 }
    AOWLabel3: TAOWLabel; { +006C }
    AoWFrame1: TAoWFrame; { +0070 }
    Translator: TIvTranslator; { +0074 }
    public
    FOnClose: TExecuteDoneEvent; { $78 }
    FEvent: TCityRebellionEventLog; { $80 }
    procedure ClearEvent;
    published procedure CloseClick; public  { draft }
    published procedure CenterButClick; public  { draft }
    published procedure RebelWinHide; public  { draft }
    published procedure RebelWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


implementation

uses AoWWinMan, E3Globals;

procedure TCityRebelDlg.ClearEvent;
var
  Event: TCityRebellionEventLog;
  Notify: TExecuteDoneEvent;
begin
  Notify := FOnClose; Event := FEvent;
  FOnClose := nil; FEvent := nil;
  if Assigned(Notify) then Notify(Event);
  if Event <> nil then Event.Release;
end;

procedure TCityRebelDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  RebelWin.Visible := False;
end;

procedure TCityRebelDlg.CenterButClick;
begin
  General.PlayButtonSound(0);
  with FEvent do AoWHSMap.CenterViewTo(FXhx, FYhx, FLhx);
end;

procedure TCityRebelDlg.RebelWinHide;
begin
  ClearEvent;
end;

procedure TCityRebelDlg.RebelWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_SPACE) then RebelWin.Visible := False;
end;


end.
