unit Hill;

{ Hill of AoWEPACK.dpl: recovered bodies and original instance layouts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  THillMO = class;
  THillMOR = class;


  { THillMO (instance size 20, VMT 55800AFC) }
  THillMO = class(TTerrainMO)
  public
    class function ClassID: Integer; override;
  end;

  { THillMOR (instance size 72, VMT 55800C98) }
  THillMOR = class(TTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function CreateResourceUser: Engine.TEObject; override;
  end;

procedure RegisterHill(AEngine: TEngine);

implementation

resourcestring
  HillNameRStr = 'Hill'; { original AoWE.HillRStr, RT_STRING $FFB8 }

const
  HillNameResource: PResStringRec = @HillNameRStr;

class function THillMO.ClassID: Integer;
begin Result := $20168; end;

class function THillMOR.ClassID: Integer;
begin Result := $20169; end;

class function THillMOR.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(HillNameResource)); end;

function THillMOR.CreateResourceUser: Engine.TEObject;
var
  MO: THillMO;
begin
  MO := THillMO.Create(nil);
  MO.SetResource(Self);
  MO.SetResourceLinked(True);
  Result := MO;
end;

procedure RegisterHill(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([THillMO]);
end;


initialization
finalization

end.
