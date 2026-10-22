unit aowHelpWin;

{ Partly recovered aowHelpWin handlers, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Any remaining stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWComp, AoWButton, AoWImage, AoWLabel, AoWMemo, AoWVScroll, AoWWindow;

type
  THelpWindow = class;


  { THelpWindow: done callback $7C, help event $84.
    (instance size 136, VMT 004043F0) }
  THelpWindow = class(TDataModule)
  public
    published
    HelpWin: TAOWWindow; { +0044 }
    Title: TAOWLabel; { +0048 }
    CloseBtn: TAOWButton; { +004C }
    TitleIcon: TAOWImage; { +0050 }
    BBarEnd: TAOWImage; { +0054 }
    BBarBegin: TAOWImage; { +0058 }
    BCloseBut: TAOWButton; { +005C }
    CeltLineR: TAOWImage; { +0060 }
    BBar: TAOWImage; { +0064 }
    CeltLineL: TAOWImage; { +0068 }
    HelpSB: TAOWVScrollBar; { +006C }
    HeaderMemo: TAOWMemo; { +0070 }
    HelpMemo: TAOWMemo; { +0074 }
    Translator: TIvTranslator; { +0078 }
    public
    FDone: TExecuteDoneEvent; { $7C }
    FHelpEvent: THelpMessageEventLog; { $84 }
    procedure FinishDialog;
    procedure ShowHelpEvent(Event: THelpMessageEventLog; Unused: Boolean; Done: TExecuteDoneEvent);
    published procedure CloseBtnClick; public  { draft }
    published procedure HelpWinHide; public  { draft }
    published procedure HelpWinResize; public  { draft }
  end;


var HelpWindow: THelpWindow; procedure ShowHelp(HelpID: Integer); { 0040471C }

implementation




procedure THelpWindow.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Event: THelpMessageEventLog;
begin
  Done := FDone;
  Event := FHelpEvent;
  FDone := nil;
  FHelpEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

procedure THelpWindow.ShowHelpEvent(Event: THelpMessageEventLog; Unused: Boolean; Done: TExecuteDoneEvent);
begin
  FinishDialog;
  FHelpEvent := Event;
  FHelpEvent.AddRef;
  HeaderMemo.Items.Clear;
  if Event.FMessage.Count > 0 then HeaderMemo.Items.Add(Event.FMessage[0]);
  HelpMemo.Items.Clear;
  HelpMemo.Items.AddStrings(Event.FMessage);
  if HelpMemo.Items.Count > 0 then HelpMemo.Items.Delete(0);
  if (HelpMemo.Items.Count > 0) and (HelpMemo.Items[0] = '') then HelpMemo.Items.Delete(0);
  if Event.FMode <> 0 then FDone := Done
  else if Assigned(Done) then Done(FHelpEvent);
  HelpWin.Visible := True;
end;

procedure ShowHelp(HelpID: Integer);
var
  Lines: TStringList;
begin
  if HelpWindow.HelpWin.Visible then HelpWindow.FinishDialog;
  Lines := TStringList.Create;
  AoWHSSet.FTextControl.RetrieveText(HelpID, Lines);
  HelpWindow.HelpSB.Position := 0;
  HelpWindow.HeaderMemo.Items.Clear;
  if Lines.Count > 0 then HelpWindow.HeaderMemo.Items.Add(Lines[0]);
  HelpWindow.HelpMemo.Items.Clear;
  HelpWindow.HelpMemo.Items.AddStrings(Lines);
  if HelpWindow.HelpMemo.Items.Count > 0 then HelpWindow.HelpMemo.Items.Delete(0);
  if (HelpWindow.HelpMemo.Items.Count > 0) and (HelpWindow.HelpMemo.Items[0] = '') then HelpWindow.HelpMemo.Items.Delete(0);
  HelpWindow.HelpWin.Visible := True;
  Lines.Free;
end;

procedure THelpWindow.CloseBtnClick;
begin
  HelpWin.Visible := False;
end;

procedure THelpWindow.HelpWinHide;
begin
  FinishDialog;
end;

procedure THelpWindow.HelpWinResize;
begin
  with HelpWin do
  begin
    Alignment.LeftOffset := WinLeft;
    Alignment.TopOffset := WinTop;
    Alignment.AlignHeight := ahTop;
    Alignment.AlignWidth := awLeft;
  end;
end;


end.
