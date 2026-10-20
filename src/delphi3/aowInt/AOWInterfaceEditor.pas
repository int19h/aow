unit AOWInterfaceEditor;

{ The AOWInterfaceEditor unit of aowInt.dpl: TAOWComponentEditor, the component editor of the
  windows of the AoW interface. Its one verb opens a TDialog (AoWDialogForm) on the window; the
  dialog is kept in the window's FBuffer field, which TAOWGenericWindow.Destroy frees. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DsgnIntf,
  AoWComp, AoWWinControl, AoWDialogForm, AoWBaseWin;

type
  { AOWInterfaceEditor.TAOWComponentEditor (instance size 20). +$C FDialog, +$10 FWindow }
  TAOWComponentEditor = class(TComponentEditor)
  public
    FDialog: TDialog;
    FWindow: TAOWBaseWindow;
    procedure Edit; override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

procedure Register;

implementation

{ TAOWComponentEditor }

procedure TAOWComponentEditor.Edit;
var
  C: TComponent;
begin
  FDialog := nil;
  FWindow := nil;
  if (Designer <> nil) and (Component <> nil) and (Application <> nil) then
  begin
    C := Component;
    if C is TAOWBaseWindow then
    begin
      FWindow := TAOWBaseWindow(C);
      if FWindow.FBuffer <> nil then
      begin
        FWindow.FBuffer.Free;
        FWindow.FBuffer := nil;
      end;
      FDialog := TDialog.Create(nil);
      if FDialog <> nil then
      begin
        FDialog.Name := FWindow.Name + 'IntDlg';
        FWindow.FBuffer := FDialog;
        FDialog.FSelected := -1;
        FDialog.Draw(Component, Designer);
        FDialog.Show;
      end;
    end;
  end;
end;

procedure TAOWComponentEditor.ExecuteVerb(Index: Integer);
begin
  Edit;
end;

function TAOWComponentEditor.GetVerb(Index: Integer): string;
begin
  Result := '&AoW Interface Editor..';
end;

function TAOWComponentEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure Register;
begin
  RegisterComponentEditor(TAOWWindowControl, TAOWComponentEditor);
end;

end.
