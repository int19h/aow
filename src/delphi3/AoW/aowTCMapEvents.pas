unit aowTCMapEvents;

{ Draft declarations of aowTCMapEvents, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CMapCtrl;

type
  TTCMapEvents = class;


  { TTCMapEvents (instance size 76, VMT 00458004) }
  TTCMapEvents = class(TDataModule)
  public
    published
    TCMap: TAoWCombatMapControl; { +0044 }
    public
    F_TCMapEvents_48: Integer;
    procedure TCMapActivateMap;  { draft }
    procedure TCMapDeActivateMap;  { draft }
    procedure TCMapDeselected(A1: Integer);  { draft }
    procedure TCMapMapChanged(A1: Integer);  { draft }
    procedure TCMapMouseOverTarget(A1: Integer);  { draft }
    procedure TCMapSeatedPlayerChanged(A1: Integer);  { draft }
    procedure TCMapSelected(A1: Integer);  { draft }
    procedure TCMapShowMessage(A1: Integer);  { draft }
    procedure TCMapUnitChanged(A1: Integer);  { draft }
    procedure TCMapCastSpell(A1: Integer);  { draft }
    procedure TCMapActivateAbility(A1: Integer);  { draft }
    procedure TCMapTurnChanged;  { draft }
  end;


implementation

procedure TTCMapEvents.TCMapActivateMap;
begin end;

procedure TTCMapEvents.TCMapDeActivateMap;
begin end;

procedure TTCMapEvents.TCMapDeselected(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapMapChanged(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapMouseOverTarget(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapSeatedPlayerChanged(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapSelected(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapShowMessage(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapUnitChanged(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapCastSpell(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapActivateAbility(A1: Integer);
begin end;

procedure TTCMapEvents.TCMapTurnChanged;
begin end;


end.
