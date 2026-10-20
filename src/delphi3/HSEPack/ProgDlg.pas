unit ProgDlg;

{ The ProgDlg unit of HSEPack.dpl: the progress dialog that THSMEdit shows while a map loads.
  Its ProgressEvent has the shape of Engine.TProgressEvent. The form's components are
  plain published fields (no DFM is linked here). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Engine;

type
  { ProgDlg.TProgressDlg (instance size 488): +$1DC the components. }
  TProgressDlg = class(TForm)
    ProgressPanel: TPanel;
    ProgressMessage: TLabel;
    ProgressBar: TProgressBar;
  public
    procedure ProgressEvent(Sender: TEObject; const Msg: string; Percent: Integer);
  end;

implementation

procedure TProgressDlg.ProgressEvent(Sender: TEObject; const Msg: string; Percent: Integer);
begin
  ProgressMessage.Caption := Msg;
  ProgressBar.Position := Percent;
  ProgressPanel.Repaint;
end;

end.
