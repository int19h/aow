unit agsocket;

{ Link-only TagSocket layout ($250 bytes). }
interface
uses Classes, agwsock;
type
  TagSocket = class(TComponent)
  public
    FHost: string;
    FReserved28: array[0..551] of Byte;
    procedure SetWinsockLoaded(Value: Boolean);
    property WinsockLoaded: Boolean write SetWinsockLoaded;
  end;
implementation
procedure TagSocket.SetWinsockLoaded(Value: Boolean); begin end;
initialization
finalization
end.
