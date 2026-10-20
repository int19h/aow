unit RndHex;

{ The RndHex unit of HSEPack.dpl: the random hexagon resource (TRndHexagonResource, ClassID
  $20154): placing it changes the terrain under the cursor to its terrain type through the map,
  which picks one of the hexagons of that terrain; its resource user is created the same way. }

interface

uses
  Windows, SysUtils, Classes, Engine, GFXE, ImageLib, HSEngine, Hexagon;

type
  { RndHex.TRndHexagonResource (instance size 56) }
  TRndHexagonResource = class(THexagonResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function CreateResourceUser: TEObject; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
  end;

procedure RegisterRandomHexagon(Engine: TEngine);

implementation

{ TRndHexagonResource }

class function TRndHexagonResource.ClassID: Integer;
begin
  Result := $20154;
end;

class function TRndHexagonResource.ResourceEditName: string;
begin
  Result := 'Random Hexagon';
end;

function TRndHexagonResource.CreateResourceUser: TEObject;
begin
  Result := FEngine.HSSet.HexagonControl.CreateMO(FTerrainList.GetTerrain(0));
end;

procedure TRndHexagonResource.MsgProc(var Msg: TEMsg; Sender: TEObject);
var
  Lhx, Radius: Integer;
  Xhx, Yhx: Integer;
begin
  if Msg.MsgID = $10005 then
  begin
    Lhx := Msg.Data[1];
    Radius := Msg.Param[1];
    HPtoHX(Msg.Value, Msg.Data[0], Xhx, Yhx);
    FEngine.HSMap.ChangeTerrain(nil, Xhx, Yhx, Lhx, Radius,
      FTerrainList.GetTerrain(0));
    Msg.MsgID := 0;
    Msg.Result := 0;
  end;
  if Msg.MsgID <> $10014 then inherited MsgProc(Msg, Sender);
end;

procedure RegisterRandomHexagon(Engine: TEngine);
begin
  Engine.RegisterEClasses([TRndHexagonResource]);
end;

end.
