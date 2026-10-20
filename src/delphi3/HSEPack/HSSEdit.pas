unit HSSEdit;

{ The HSSEdit unit of HSEPack.dpl: the hexagon sprite set editor component of the map editor
  (AoWEd.exe). THSSEdit loads, saves and activates the sprite set (THSSet) of a THSEngine; its
  control THSSEditControl, connected to the engine, marks the set modified when the engine
  reports a change (message $24). The original file was d:\gengine\hsengine\edit\Hssedit.pas
  (the name follows that of Hsmedit.pas, which an Assert names). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Engine, HSEngine;

type
  TShowMessageEvent = procedure(S: String) of object;

  THSSEdit = class;

  { HSSEdit.THSSEditControl (instance size 16): +$C FHSSEdit. }
  THSSEditControl = class(TEUser)
  private
    FHSSEdit: THSSEdit;
  public
    destructor Destroy; override;
    function GetControlStyle: TEControlStyles; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
  end;

  { HSSEdit.THSSEdit (instance size 80): +$24 FHSEngine, +$28 FEdit (activated for editing),
    +$29 FActivated, the events (+$2C OnActivate, +$34 OnDeactivate, +$3C OnShowMessage, +$44
    OnUpdateCaption), +$4C FControl. }
  THSSEdit = class(TComponent)
  private
    FHSEngine: THSEngine;
    FEdit: Boolean;
    FActivated: Boolean;
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnShowMessage: TShowMessageEvent;
    FOnUpdateCaption: TNotifyEvent;
    FControl: THSSEditControl;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetHSEngine(Value: THSEngine);
    procedure UpdateCaption; virtual;
    function CanCloseSet: Boolean;
    function SaveAs: Boolean;
    function Save: Boolean;
    function LoadHSSFile(FileName: string; Edit: Boolean): Boolean;
    function Load(Edit: Boolean): Boolean;
    function Close: Boolean;
    function NewSet: Boolean;
    procedure Activate(Edit: Boolean);
    procedure DeActivate;
    property HSEngine: THSEngine read FHSEngine write SetHSEngine;
    property Activated: Boolean read FActivated;
    property Edit: Boolean read FEdit;
  published
    property OnShowMessage: TShowMessageEvent read FOnShowMessage write FOnShowMessage;
    property OnUpdateCaption: TNotifyEvent read FOnUpdateCaption write FOnUpdateCaption;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
  end;

procedure Register;

implementation

{ THSSEditControl }

destructor THSSEditControl.Destroy;
begin
  FHSSEdit.FControl := nil;
  inherited Destroy;
end;

function THSSEditControl.GetControlStyle: TEControlStyles;
begin
  Result := [];
end;

procedure THSSEditControl.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $24) and FHSSEdit.FActivated then
    FHSSEdit.FHSEngine.HSSet.SetModified;
end;

{ THSSEdit }

constructor THSSEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FControl := THSSEditControl.Create(nil);
  FControl.FHSSEdit := Self;
end;

destructor THSSEdit.Destroy;
begin
  FControl.Free;
  inherited Destroy;
end;

procedure THSSEdit.SetHSEngine(Value: THSEngine);
begin
  FHSEngine := Value;
  if FHSEngine <> nil then
    FControl.Connect(FHSEngine);
end;

procedure THSSEdit.UpdateCaption;
begin
  if Assigned(FOnUpdateCaption) then
    FOnUpdateCaption(Self);
end;

function THSSEdit.CanCloseSet: Boolean;
var
  R: Integer;
begin
  if (FHSEngine <> nil) and FActivated then
  begin
    with FHSEngine do
    begin
      if not (ssModified in HSSet.Status) then
        R := mrNo
      else
        R := MessageDlg('Save changes to ' + HSSFileName, mtConfirmation, [mbYes, mbNo, mbCancel], 0);
      if R = mrYes then
        if HSSFileName <> 'noname.hss' then
        begin
          THSEngine(GetEngine).SaveHSS(HSSFileName, nil);
          HSSet.ResetModified;
        end
        else
          if not SaveAs then
            R := mrCancel;
    end;
    Result := R <> mrCancel;
  end
  else
    Result := True;
end;

function THSSEdit.SaveAs: Boolean;
var
  D: TSaveDialog;
begin
  Result := False;
  if (FHSEngine <> nil) and FActivated and FEdit then
  begin
    D := TSaveDialog.Create(nil);
    D.Filter := 'Hexagon Sprite Set|*.HSS';
    D.InitialDir := GetCurrentDir;
    D.DefaultExt := 'hss';
    D.FileName := FHSEngine.HSSFileName;
    if D.Execute then
    begin
      FHSEngine.SaveHSS(D.FileName, nil);
      FHSEngine.HSSet.ResetModified;
      UpdateCaption;
      Result := True;
    end;
    D.Free;
  end;
end;

function THSSEdit.Save: Boolean;
begin
  if (FHSEngine <> nil) and FActivated and FEdit then
    with FHSEngine do
      if HSSFileName <> 'noname.hss' then
      begin
        SaveHSS(HSSFileName, nil);
        HSSet.ResetModified;
        Result := True;
      end
      else
        Result := SaveAs
  else
    Result := False;
end;

function THSSEdit.LoadHSSFile(FileName: string; Edit: Boolean): Boolean;
begin
  try
    FHSEngine.LoadHSS(FileName, True, nil);
    FHSEngine.HSSet.ResetModified;
    UpdateCaption;
    Activate(Edit);
    Result := True;
  except
    ShowMessage('Error loading ' + FileName);
    DeActivate;
    Result := False;
  end;
end;

function THSSEdit.Load(Edit: Boolean): Boolean;
var
  D: TOpenDialog;
begin
  Result := False;
  if FHSEngine <> nil then
  begin
    D := TOpenDialog.Create(nil);
    D.Filter := 'Hexagon Sprite Set|*.HSS';
    if D.Execute and Close then
    begin
      UpdateWindow(GetDesktopWindow);
      UpdateWindow(Application.MainForm.Handle);
      Result := LoadHSSFile(D.FileName, Edit);
    end;
    D.Free;
  end;
end;

function THSSEdit.Close: Boolean;
begin
  Result := CanCloseSet;
  if Result and (FHSEngine <> nil) then
    DeActivate;
end;

function THSSEdit.NewSet: Boolean;
begin
  Result := Close;
  if Result and (FHSEngine <> nil) then
  begin
    FHSEngine.CloseHSS;
    Activate(True);
  end;
end;

procedure THSSEdit.Activate(Edit: Boolean);
var
  Msg: TEMsg;
begin
  DeActivate;
  if not FActivated then
  begin
    if FHSEngine = nil then
      raise Exception.Create('No HexagonSpriteEngine defined!');
    FActivated := True;
    FEdit := Edit;
    if FEdit then
      FHSEngine.HSSet.SetEditting;
    InitMsg(Msg, $10400, FControl);
    FHSEngine.ControlNode.MsgProc(Msg, FControl);
    if FEdit then
      InitMsg(Msg, $19, FControl)
    else
      InitMsg(Msg, $21, FControl);
    FHSEngine.ControlNode.MsgProc(Msg, FControl);
    if Assigned(FOnActivate) then
      FOnActivate(Self);
    UpdateCaption;
  end;
end;

procedure THSSEdit.DeActivate;
var
  Msg: TEMsg;
begin
  Sleep(100);
  if FActivated then
  begin
    FActivated := False;
    InitMsg(Msg, $10401, FControl);
    FHSEngine.MsgProc(Msg, FControl);
    if FEdit then
      InitMsg(Msg, $20, FControl)
    else
      InitMsg(Msg, $22, FControl);
    FHSEngine.ControlNode.MsgProc(Msg, FControl);
    FHSEngine.HSSet.ResetEditting;
    FEdit := False;
    if Assigned(FOnDeactivate) then
      FOnDeactivate(Self);
    UpdateCaption;
  end;
end;

procedure Register;
begin
  RegisterComponents('HS-Engine', [THSSEdit]);
end;

end.
