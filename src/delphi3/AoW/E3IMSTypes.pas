unit E3IMSTypes;
{ Imported IMS objects used by E3. TmsMessageHeader.From is at $104;
  list instances are opaque and their methods are imported from ims.dpl. }
interface
type
  TmsMessageHeader = class(TObject)
  public
    FReserved04: array[0..255] of Byte;
    FFrom: ShortString; { $104 }
  end;
  TmsAddressList = class(TObject)
  public
    procedure Clear;
    procedure AddAddress(const Address, Name: string);
  end;
  TmsAttList = class(TObject)
  public
    procedure Clear;
    procedure AddFile(const FileName: string);
  end;
implementation
procedure TmsAddressList.Clear; external 'ims.dpl' name 'msmsgcls.TmsAddressList.Clear@23EDC2EF';
procedure TmsAddressList.AddAddress(const Address, Name: string); external 'ims.dpl' name 'msmsgcls.TmsAddressList.AddAddress@23EDC2EF';
procedure TmsAttList.Clear; external 'ims.dpl' name 'msmsgcls.TmsAttList.Clear@23EDC2EF';
procedure TmsAttList.AddFile(const FileName: string); external 'ims.dpl' name 'msmsgcls.TmsAttList.AddFile@23EDC2EF';
end.
