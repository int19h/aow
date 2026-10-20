unit Spring;

{ Draft declarations of Spring, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Animation, AoWE;

type
  TSpringOfLifeAnimation = class;
  TSpringOfLife = class;
  TSpringOfLifeResource = class;


  { TSpringOfLifeAnimation (instance size 60, VMT 557A3858) }
  TSpringOfLifeAnimation = class(TAnimation)
  public
    procedure AnimationControlMode; override;
    procedure NewFrame; override;
  end;

  { TSpringOfLife (instance size 48, VMT 557A3A04) }
  TSpringOfLife = class(TStructure)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure ShowBlessingAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ExecuteNaturesBlessing(A1: Integer);  { draft }
  end;

  { TSpringOfLifeResource (instance size 100, VMT 557A3C6C) }
  TSpringOfLifeResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterSpringOfLife;  { draft }

implementation

procedure TSpringOfLifeAnimation.AnimationControlMode;
begin end;

procedure TSpringOfLifeAnimation.NewFrame;
begin end;

constructor TSpringOfLife.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSpringOfLife.ClassID: Integer;
begin Result := 0; end;

procedure TSpringOfLife.ShowBlessingAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSpringOfLife.ExecuteNaturesBlessing(A1: Integer);
begin end;

procedure TSpringOfLife.ArmyPlaced(A1: Integer);
begin end;

constructor TSpringOfLifeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSpringOfLifeResource.ClassID: Integer;
begin Result := 0; end;

class function TSpringOfLifeResource.ResourceEditName: string;
begin Result := ''; end;

function TSpringOfLifeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterSpringOfLife;
begin end;


initialization
finalization

end.
