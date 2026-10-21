unit AoWRoad;

{ AoWRoad of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TAoWRoad = class;


  { TAoWRoad (instance size 20, VMT 5579B6FC) }
  TAoWRoad = class(TRoad)
  public
    procedure UpdateTransitions; override;
  end;

procedure RegisterAoWRoad(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  { needs: Road.TRoad.FTransitions at +$10 is private. }
  TRoadFields = packed record
    Reserved: array[0..15] of Byte;
    Transitions: Byte;
  end;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;

procedure TAoWRoad.UpdateTransitions;
var
  OldTransitions: Byte;
  Xhx, Yhx: Integer;
  Msg: TMapFieldMsg;
  HN: Integer;
  Level: TMapLevel;
  MapField: TMapField;
  HasRoad: Boolean;
begin
  OldTransitions := FTransitions;
  Level := TMapLevel(Owner.Owner);
  FTransitions := 0;
  Msg.MsgID := $1131;
  Msg.Param[0] := Integer(Owner);
  for HN := 1 to 6 do
  begin
    HNtoHX(HN, Xhx, Yhx);
    TranslateHX(0, 0, TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhx, Yhx, Xhx, Yhx);
    if (Xhx >= 0) and (Yhx >= 0) and (Level.Width > Xhx) and (Level.Height > Yhx) then
    begin
      MapField := Level.GetField(Xhx, Yhx);
      if MapField.FindOwnedHS(TAbstractRoad) = nil then
      begin
        { Original message stores its response in Param[1], rather than Result. }
        Msg.Param[1] := 0;
        MapField.SendMapFieldMsg(Msg);
        HasRoad := Msg.Param[1] <> 0;
      end
      else HasRoad := True;
      if HasRoad then Inc(FTransitions, 1 shl (HN - 1));
    end;
  end;
  if FTransitions and $22 = $22 then
    FTransitions := FTransitions and $DD + $80;
  if FTransitions and $14 = $14 then
    FTransitions := FTransitions and $EB + $40;
  if OldTransitions <> FTransitions then
    WorldMap^.InvalidateStaticScene(TMapField(Owner).Xhx, TMapField(Owner).Yhx, TMapField(Owner).Lhx);
end;

procedure RegisterAoWRoad(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAoWRoad, TRoadResource]);
end;


initialization
finalization

end.
