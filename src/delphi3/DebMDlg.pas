unit DebMDlg;

{ The DebMDlg unit of Enginep.dpl written for the original compiler (Delphi 3.02): TDebugMessageDlg,
  the form that shows an engine's debug messages (TEngine.OutputDebugStr / OutputDebugMessage) in
  a memo and lets the user pick the debug IDs to see. The component fields and event handlers are
  the published ones of the original (notes/rtti/Enginep.dpl.txt); no DFM is needed to compare the
  code, so the form resource is not linked. tools/match.py compares every method with the game's
  module. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, CheckLst, EngineLists, Engine;

type
  { DebMDlg.TDebugMessageDlg (instance size 540): +$1DC..+$210 the components, +$214 FEngine,
    +$218 FDebugIDs (the ID of every name in VisibleDebugNames). }
  TDebugMessageDlg = class(TForm)
    Panel2: TPanel;
    SaveBtn: TButton;
    SaveDialog: TSaveDialog;
    StayOnTop: TCheckBox;
    ClearBtn: TButton;
    UpdateBox: TCheckBox;
    PageControl1: TPageControl;
    InfoSheet: TTabSheet;
    SettingsSheet: TTabSheet;
    DebugStrings: TMemo;
    GroupBox1: TGroupBox;
    VisibleDebugNames: TCheckListBox;
    ShowSelectedIDs: TRadioButton;
    ShowAllIDs: TRadioButton;
    procedure SaveBtnClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FEngine: TEngine;
    FDebugIDs: TIntegerList;
    function ShowID(ID: Integer): Boolean;
    procedure OutputDebugInfoEvent(Sender: TObject);
    procedure SetEngine(Value: TEngine);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Engine: TEngine read FEngine write SetEngine;
  end;

var
  DebugMessageDlg: TDebugMessageDlg;

implementation

{ TDebugMessageDlg }

constructor TDebugMessageDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDebugIDs := TIntegerList.Create;
end;

destructor TDebugMessageDlg.Destroy;
begin
  Engine := nil;
  FDebugIDs.Free;
  inherited Destroy;
end;

function TDebugMessageDlg.ShowID(ID: Integer): Boolean;
var
  I: Integer;
begin
  if not ShowAllIDs.Checked then
  begin
    I := FDebugIDs.IndexOf(ID);
    Result := (I <> -1) and VisibleDebugNames.Checked[I];
  end
  else
    Result := True;
end;

{ Sender is the address of the TEngineDebugInfo record TEngine.OutputDebugMessage hands to its
  debug events; the record cast through Pointer(Sender)^ is what gives the original's code (a
  pointer local or a with statement evaluates the Lines object first) }
procedure TDebugMessageDlg.OutputDebugInfoEvent(Sender: TObject);
begin
  if UpdateBox.Checked and ShowID(TEngineDebugInfo(Pointer(Sender)^).ID) then
  begin
    if DebugStrings.Lines.Count > 5000 then DebugStrings.Lines.Delete(0);
    DebugStrings.Lines.AddObject(TEngineDebugInfo(Pointer(Sender)^).Text,
      TObject(TEngineDebugInfo(Pointer(Sender)^).ID));
  end;
end;

procedure TDebugMessageDlg.SetEngine(Value: TEngine);
var
  I: Integer;
begin
  if FEngine <> nil then FEngine.DebugEvents.Remove(OutputDebugInfoEvent);
  FEngine := Value;
  if FEngine <> nil then
  begin
    FEngine.DebugEvents.Add(OutputDebugInfoEvent);
    VisibleDebugNames.Items.Clear;
    FDebugIDs.Clear;
    for I := 0 to FEngine.DebugIDs.Count - 1 do
    begin
      VisibleDebugNames.Items.Add(FEngine.DebugIDs[I]);
      FDebugIDs.Add(Integer(FEngine.DebugIDs.Objects[I]));
    end;
  end;
end;

procedure TDebugMessageDlg.SaveBtnClick(Sender: TObject);
begin
  SaveDialog.DefaultExt := 'log';
  SaveDialog.FileName := Application.Title;
  if SaveDialog.Execute then DebugStrings.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TDebugMessageDlg.StayOnTopClick(Sender: TObject);
begin
  if StayOnTop.Checked then FormStyle := fsStayOnTop else FormStyle := fsNormal;
end;

procedure TDebugMessageDlg.ClearBtnClick(Sender: TObject);
begin
  DebugStrings.Lines.Clear;
end;

procedure TDebugMessageDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  { the original closes with caMinimize (3), not caFree }
  Action := caMinimize;
end;

end.
