unit msmsgcls;

{ Link-only IMS declarations. The header is an opaque memory view used by the game. }
interface
uses Classes;
type
  TmsMessageHeader = class(TObject)
  public
    FReserved04: array[0..255] of Byte;
    FFrom: ShortString;
  end;
  TmsAddressList = class(TPersistent)
  private
    FItems: TList;
  public
    procedure Clear;
    procedure AddAddress(const Address, Name: string);
  end;
  TmsAttList = class(TPersistent)
  private
    FItems: TList;
  public
    procedure Clear;
    procedure AddFile(const FileName: string);
  end;
implementation
procedure TmsAddressList.Clear; begin end;
procedure TmsAddressList.AddAddress(const Address, Name: string); begin end;
procedure TmsAttList.Clear; begin end;
procedure TmsAttList.AddFile(const FileName: string); begin end;
initialization
finalization
end.
