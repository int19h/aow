unit BloodShrine;

{ Draft declarations of BloodShrine, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Animation, AoWE;

type
  TBloodShrineAnimation = class;
  TBloodShrine = class;
  TBloodShrineResource = class;


  { TBloodShrineAnimation (instance size 60, VMT 557E26D0) }
  TBloodShrineAnimation = class(TAnimation)
  public
    procedure AnimationControlMode; override;
    procedure NewFrame; override;
  end;

  { TBloodShrine (instance size 48, VMT 557E2880) }
  TBloodShrine = class(TStructure)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure ShowBlessingAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ExecuteBloodlust(A1: Integer);  { draft }
  end;

  { TBloodShrineResource (instance size 100, VMT 557E2AEC) }
  TBloodShrineResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterBloodShrine;  { draft }

implementation

procedure TBloodShrineAnimation.AnimationControlMode;
begin end;

procedure TBloodShrineAnimation.NewFrame;
begin end;

constructor TBloodShrine.Create(AOwner: Engine.TECustomNode);
begin end;

class function TBloodShrine.ClassID: Integer;
begin Result := 0; end;

procedure TBloodShrine.ShowBlessingAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TBloodShrine.ExecuteBloodlust(A1: Integer);
begin end;

procedure TBloodShrine.ArmyPlaced(A1: Integer);
begin end;

constructor TBloodShrineResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TBloodShrineResource.ClassID: Integer;
begin Result := 0; end;

class function TBloodShrineResource.ResourceEditName: string;
begin Result := ''; end;

function TBloodShrineResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterBloodShrine;
begin end;


initialization
finalization

end.
