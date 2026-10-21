unit aowMapEvents;

{ Draft declarations of aowMapEvents, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, MapCtrl;

type
  TMapEvents = class;


  { TMapEvents (instance size 72, VMT 0044E554) }
  TMapEvents = class(TDataModule)
  public
    published
    TheMap: TAoWMapControl; { +0044 }
    public
    procedure TheMapActivateAbility(A1: Integer);  { draft }
    procedure TheMapArmyChanged(A1: Integer);  { draft }
    procedure TheMapArmyDeselected;  { draft }
    procedure TheMapArmyDestroyed(A1: Integer);  { draft }
    procedure TheMapArmySelected(A1: Integer; A2: Integer);  { draft }
    procedure TheMapDayChanged(A1: Integer);  { draft }
    procedure TheMapDeactivateHSM;  { draft }
    procedure TheMapEndTurn(A1: Byte; A2: Integer);  { draft }
    procedure TheMapExecuteEventLog(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure TheMapGameOver;  { draft }
    procedure TheMapGemsChanged(A1: Byte);  { draft }
    procedure TheMapGlobalMagicChanged;  { draft }
    procedure TheMapIncomeChanged(A1: Byte);  { draft }
    procedure TheMapMapChanged(A1: Integer);  { draft }
    procedure TheMapScannerIconsChanged(A1: Integer);  { draft }
    procedure TheMapPlayerMagicChanged(A1: Integer);  { draft }
    procedure TheMapSeatedPlayerChanged(A1: Integer);  { draft }
    procedure TheMapShowMessage(A1: Integer);  { draft }
    procedure TheMapStructureChanged(A1: Integer);  { draft }
    procedure TheMapStructureDeselected;  { draft }
    procedure TheMapStructureDestroyed(A1: Integer);  { draft }
    procedure TheMapStructureSelected(A1: Integer);  { draft }
    procedure TheMapItemsDeselected;  { draft }
    procedure TheMapItemsSelected;  { draft }
    procedure TheMapTargetSelectionChange;  { draft }
    procedure TheMapUnitChanged(A1: Integer);  { draft }
    procedure TheMapCastSpell(A1: Integer);  { draft }
    procedure TheMapHSChanged(A1: Integer);  { draft }
    procedure TheMapRelationsChanged;  { draft }
    procedure TheMapDiplomaticChange;  { draft }
    procedure TheMapStructureDblClick(A1: Integer);  { draft }
  end;


implementation

procedure TMapEvents.TheMapActivateAbility(A1: Integer);
begin end;

procedure TMapEvents.TheMapArmyChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapArmyDeselected;
begin end;

procedure TMapEvents.TheMapArmyDestroyed(A1: Integer);
begin end;

procedure TMapEvents.TheMapArmySelected(A1: Integer; A2: Integer);
begin end;

procedure TMapEvents.TheMapDayChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapDeactivateHSM;
begin end;

procedure TMapEvents.TheMapEndTurn(A1: Byte; A2: Integer);
begin end;

procedure TMapEvents.TheMapExecuteEventLog(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMapEvents.TheMapGameOver;
begin end;

procedure TMapEvents.TheMapGemsChanged(A1: Byte);
begin end;

procedure TMapEvents.TheMapGlobalMagicChanged;
begin end;

procedure TMapEvents.TheMapIncomeChanged(A1: Byte);
begin end;

procedure TMapEvents.TheMapMapChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapScannerIconsChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapPlayerMagicChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapSeatedPlayerChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapShowMessage(A1: Integer);
begin end;

procedure TMapEvents.TheMapStructureChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapStructureDeselected;
begin end;

procedure TMapEvents.TheMapStructureDestroyed(A1: Integer);
begin end;

procedure TMapEvents.TheMapStructureSelected(A1: Integer);
begin end;

procedure TMapEvents.TheMapItemsDeselected;
begin end;

procedure TMapEvents.TheMapItemsSelected;
begin end;

procedure TMapEvents.TheMapTargetSelectionChange;
begin end;

procedure TMapEvents.TheMapUnitChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapCastSpell(A1: Integer);
begin end;

procedure TMapEvents.TheMapHSChanged(A1: Integer);
begin end;

procedure TMapEvents.TheMapRelationsChanged;
begin end;

procedure TMapEvents.TheMapDiplomaticChange;
begin end;

procedure TMapEvents.TheMapStructureDblClick(A1: Integer);
begin end;


end.
