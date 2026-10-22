unit mssmtp;

{ Link-only SMTP layout ($27C bytes); the original VMT and implementation load at runtime. }
interface
uses Classes, msmb, msmsg;
type
  TmsSMTP = class(TmsMailBase)
  public
    FReserved250: array[0..31] of Byte;
    FMessage: TmsMessage;
    FReserved274: array[0..7] of Byte;
    procedure Send;
  end;
implementation
procedure TmsSMTP.Send; begin end;
initialization
finalization
end.
