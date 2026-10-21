unit SingleCombatHex;

{ SingleCombatHex, AoWTCPCK.dpl. Original layouts and VMT order.
  TSingleCombatHexagon: size $10, no added fields. Resource: size $34, no added fields. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TSingleCombatHexagon = class;
  TSingleCombatHexagonResource = class;


  { TSingleCombatHexagon (instance size 16, VMT 00434E38) }
  TSingleCombatHexagon = class(TAbstractHexagon)
  public
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
  end;

  { TSingleCombatHexagonResource (instance size 52, VMT 00434FE8) }
  TSingleCombatHexagonResource = class(TAbstractHexagonResource)
  public
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure SetLevel(Value: Byte); override;
    function GetHexagonControl: HSEngine.THexagonControl; override;
  end;

procedure RegisterSingleCombatHexagon(AEngine: TEngine);

implementation

class function TSingleCombatHexagon.ClassID: Integer;
begin Result := $22051E; end;

function TSingleCombatHexagon.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

procedure TSingleCombatHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X, Y: Integer;
  Sequence: TImageSequence;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
  X := X - XhpSurf - 8;
  Y := Y - YhpSurf;
  Sequence := FResource.ImageSequenceList.GetImageSequence(0);
  Sequence.ImageLibrary.Get(Sequence.ImageIndex).Show(X, Y, SurfaceDesc);
end;

class function TSingleCombatHexagonResource.ClassID: Integer;
begin Result := $22051F; end;

class function TSingleCombatHexagonResource.ResourceEditName: string;
begin Result := 'Combat Single Hexagon'; end;

procedure TSingleCombatHexagonResource.SetLevel(Value: Byte);
begin
  inherited SetLevel(0);
end;

function TSingleCombatHexagonResource.GetHexagonControl: HSEngine.THexagonControl;
begin Result := nil; end;

procedure TSingleCombatHexagonResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10055 then Msg.Result := 5;
end;

function TSingleCombatHexagonResource.ResourceUserClassID: Integer;
begin Result := $22051E; end;

procedure RegisterSingleCombatHexagon(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TSingleCombatHexagonResource, TSingleCombatHexagon]);
end;


initialization
finalization

end.
