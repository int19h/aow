unit msmsg;

{ Link-only layouts: TmsCustomMessage $23C, TmsMessage $24C. }
interface
uses Classes, msmsgcls;
type
  TmsCustomMessage = class(TComponent)
  public
    FHeader: TmsMessageHeader;
    FSubject: ShortString;
    FIncludeHeader, FEncode: Boolean;
    FReserved12A: array[0..9] of Byte;
    FAttachments: TmsAttList;
    FReserved138: array[0..259] of Byte;
    procedure SetBody(Value: TStrings);
  end;
  TmsMessage = class(TmsCustomMessage)
  public
    FRecipients: TmsAddressList;
    FReserved240: array[0..11] of Byte;
  end;
implementation
procedure TmsCustomMessage.SetBody(Value: TStrings); begin end;
initialization
finalization
end.
