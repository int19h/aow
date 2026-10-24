unit MapCtrl;

{ Draft declarations of MapCtrl, from AoWEPACK.dpl.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Event dispatch and bindings recovered from the original; external layout accesses are local views. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, EventLog, AoWE;

type
  TAoWMapControl = class;
  TMapEvent = procedure of object;
  TMapPlayerEvent = procedure(Player: Shortint) of object;
  TMapDayEvent = procedure(Day: Integer) of object;
  TMapObjectEvent = procedure(Obj: TObject) of object;
  TMapEndTurnEvent = procedure(Player: Shortint; Automatic: Boolean) of object;
  TMapExecuteLogEvent = procedure(Log: TEventLog; Immediate: Boolean; Done: TExecuteDoneEvent) of object;
  TMapTargetEvent = procedure(Control: TTargetSelectionControl; Change: TTargetSelectionChange) of object;
  PExecuteLogInfo = ^TExecuteLogInfo;
  TExecuteLogInfo = record
    Log: TEventLog;
    Data2, Data1: Pointer;
    Trigger: Byte;
  end;


  { TAoWMapControl (instance size 404, VMT 55804D8C) }
  TAoWMapControl = class(TComponent)
  public
    FOnSelectArmy: TMapObjectEvent; { +$24 }
    FOnDeselectArmy: TMapObjectEvent; { +$2C }
    FOnDblClickArmy: TMapObjectEvent; { +$34 }
    FOnArmyChanged: TMapObjectEvent; { +$3C }
    FOnArmyDestroyed: TMapObjectEvent; { +$44 }
    FOnSelectStructure: TMapObjectEvent; { +$4C }
    FOnDeselectStructure: TMapObjectEvent; { +$54 }
    FOnDblClickStructure: TMapObjectEvent; { +$5C }
    FOnStructureChanged: TMapObjectEvent; { +$64 }
    FOnStructureDestroyed: TMapObjectEvent; { +$6C }
    FOnSelectItem: TMapObjectEvent; { +$74 }
    FOnDeselectItem: TMapObjectEvent; { +$7C }
    FOnUnitChanged: TMapObjectEvent; { +$84 }
    FOnUnitDestroyed: TMapObjectEvent; { +$8C }
    FOnActivateAbility: TNotifyEvent; { +$94 }
    FOnDiplomaticChange: TNotifyEvent; { +$9C }
    FOnActivateHSM: TNotifyEvent; { +$A4 }
    FOnDeactivateHSM: TNotifyEvent; { +$AC }
    FOnIncomeChanged: TMapPlayerEvent; { +$B4 }
    FOnUpkeepChanged: TMapPlayerEvent; { +$BC }
    FOnGemsChanged: TMapPlayerEvent; { +$C4 }
    FOnPlayerMagicChanged: TMapPlayerEvent; { +$CC }
    FOnGlobalMagicChanged: TNotifyEvent; { +$D4 }
    FOnShowMessage: TNotifyEvent; { +$DC }
    FOnChangeDay: TMapDayEvent; { +$E4 }
    FOnNewTurn: TNotifyEvent; { +$EC }
    FOnPlayerChanged: TMapPlayerEvent; { +$F4 }
    FOnSeatedPlayerChanged: TMapPlayerEvent; { +$FC }
    FOnCombatEvent: TNotifyEvent; { +$104 }
    FOnExecuteEventLog: TMapExecuteLogEvent; { +$10C }
    FOnMapChanged: TNotifyEvent; { +$114 }
    FOnScannerIconsChanged: TNotifyEvent; { +$11C }
    FOnMapSettingsChanged: TNotifyEvent; { +$124 }
    FOnLogbookChanged: TMapPlayerEvent; { +$12C }
    FOnGameOver: TNotifyEvent; { +$134 }
    FOnGameTerminated: TMapPlayerEvent; { +$13C }
    FOnPlayerTerminated: TNotifyEvent; { +$144 }
    FOnActivateCombatMap: TNotifyEvent; { +$14C }
    FOnDeactivateCombatMap: TNotifyEvent; { +$154 }
    FOnTargetSelectionChange: TMapTargetEvent; { +$15C }
    FOnViewPortChange: TNotifyEvent; { +$164 }
    FOnCastSpell: TNotifyEvent; { +$16C }
    FOnEndTurn: TMapEndTurnEvent; { +$174 }
    FOnRelationsChanged: TNotifyEvent; { +$17C }
    FOnExitGameEvent: TNotifyEvent; { +$184 }
    FOnHSChanged: TNotifyEvent; { +$18C }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure LinkToHSM;
    procedure ReleaseHSM;
    procedure ActivateHSM(Map: TObject);
    procedure DeactivateHSM(Map: TObject);
    procedure DblClick(Sender: TObject);
    procedure MapChanged(Sender: TObject);
    procedure ScannerIconsChanged(Sender: TObject);
    procedure MapSettingsChanged(Sender: TObject);
    procedure SelectHS(Sender: TObject);
    procedure DeselectHS(Sender: TObject);
    procedure PlayerChanged(Sender: TObject);
    procedure ExitGameEvent(Sender: TObject);
    procedure NewTurn(Sender: TObject);
    procedure EndTurn(Player: TObject);
    procedure SeatedPlayerChanged(Sender: TObject);
    procedure GemsChanged(Player: TObject);
    procedure IncomeChanged(Player: TObject);
    procedure UpkeepChanged(Player: TObject);
    procedure PlayerMagicChanged(Control: TObject);
    procedure GlobalMagicChanged(Sender: TObject);
    procedure ShowMessage(Sender: TObject);
    procedure ChangeDay(Sender: TObject);
    procedure CombatEvent(Sender: TObject);
    procedure LogbookChanged(Player: TObject);
    procedure StructureChanged(Obj: TObject);
    procedure StructureDestroyed(Obj: TObject);
    procedure ArmyChanged(Obj: TObject);
    procedure ArmyDestroyed(Obj: TObject);
    procedure HSChanged(Sender: TObject);
    procedure UnitChanged(Obj: TObject);
    procedure UnitDestroyed(Obj: TObject);
    procedure GameOver(Sender: TObject);
    procedure GameTerminated(Sender: TObject);
    procedure PlayerTerminated(Sender: TObject);
    procedure ExecuteEventLog(Info: TObject);
    procedure ActivateCombatMap(Sender: TObject);
    procedure DeactivateCombatMap(Sender: TObject);
    procedure TargetSelectionChange(Control: TObject);
    procedure CastSpell(Sender: TObject);
    procedure ViewPortChange(Sender: TObject);
    procedure ActivateAbility(Sender: TObject);
    procedure DiplomaticChange(Sender: TObject);
    procedure RelationsChanged(Sender: TObject);
  published property OnArmySelected: TMapObjectEvent read FOnSelectArmy write FOnSelectArmy; property OnArmyDeselected: TMapObjectEvent read FOnDeselectArmy write FOnDeselectArmy; property OnArmyDblClick: TMapObjectEvent read FOnDblClickArmy write FOnDblClickArmy; property OnArmyChanged: TMapObjectEvent read FOnArmyChanged write FOnArmyChanged; property OnArmyDestroyed: TMapObjectEvent read FOnArmyDestroyed write FOnArmyDestroyed; property OnStructureSelected: TMapObjectEvent read FOnSelectStructure write FOnSelectStructure; property OnStructureDeselected: TMapObjectEvent read FOnDeselectStructure write FOnDeselectStructure; property OnStructureDblClick: TMapObjectEvent read FOnDblClickStructure write FOnDblClickStructure; property OnStructureChanged: TMapObjectEvent read FOnStructureChanged write FOnStructureChanged;
    property OnStructureDestroyed: TMapObjectEvent read FOnStructureDestroyed write FOnStructureDestroyed; property OnUnitChanged: TMapObjectEvent read FOnUnitChanged write FOnUnitChanged; property OnUnitDestroyed: TMapObjectEvent read FOnUnitDestroyed write FOnUnitDestroyed; property OnActivateHSM: TNotifyEvent read FOnActivateHSM write FOnActivateHSM; property OnDeactivateHSM: TNotifyEvent read FOnDeactivateHSM write FOnDeactivateHSM; property OnGemsChanged: TMapPlayerEvent read FOnGemsChanged write FOnGemsChanged; property OnIncomeChanged: TMapPlayerEvent read FOnIncomeChanged write FOnIncomeChanged; property OnUpkeepChanged: TMapPlayerEvent read FOnUpkeepChanged write FOnUpkeepChanged; property OnShowMessage: TNotifyEvent read FOnShowMessage write FOnShowMessage;
    property OnDayChanged: TMapDayEvent read FOnChangeDay write FOnChangeDay; property OnPlayerChanged: TMapPlayerEvent read FOnPlayerChanged write FOnPlayerChanged; property OnNewTurn: TNotifyEvent read FOnNewTurn write FOnNewTurn; property OnEndTurn: TMapEndTurnEvent read FOnEndTurn write FOnEndTurn; property OnHSChanged: TNotifyEvent read FOnHSChanged write FOnHSChanged; property OnSeatedPlayerChanged: TMapPlayerEvent read FOnSeatedPlayerChanged write FOnSeatedPlayerChanged; property OnMapChanged: TNotifyEvent read FOnMapChanged write FOnMapChanged; property OnScannerIconsChanged: TNotifyEvent read FOnScannerIconsChanged write FOnScannerIconsChanged; property OnMapSettingsChanged: TNotifyEvent read FOnMapSettingsChanged write FOnMapSettingsChanged; property OnCombat: TNotifyEvent read FOnCombatEvent write FOnCombatEvent;
    property OnLogbookChanged: TMapPlayerEvent read FOnLogbookChanged write FOnLogbookChanged; property OnTargetSelectionChange: TMapTargetEvent read FOnTargetSelectionChange write FOnTargetSelectionChange; property OnCastSpell: TNotifyEvent read FOnCastSpell write FOnCastSpell; property OnActivateAbility: TNotifyEvent read FOnActivateAbility write FOnActivateAbility; property OnPlayerMagicChanged: TMapPlayerEvent read FOnPlayerMagicChanged write FOnPlayerMagicChanged; property OnGlobalMagicChanged: TNotifyEvent read FOnGlobalMagicChanged write FOnGlobalMagicChanged; property OnRelationsChanged: TNotifyEvent read FOnRelationsChanged write FOnRelationsChanged; property OnActivateCombatMap: TNotifyEvent read FOnActivateCombatMap write FOnActivateCombatMap;
    property OnDeactivateCombatMap: TNotifyEvent read FOnDeactivateCombatMap write FOnDeactivateCombatMap; property OnItemsSelected: TMapObjectEvent read FOnSelectItem write FOnSelectItem; property OnItemsDeselected: TMapObjectEvent read FOnDeselectItem write FOnDeselectItem; property OnGameOver: TNotifyEvent read FOnGameOver write FOnGameOver; property OnGameTerminated: TMapPlayerEvent read FOnGameTerminated write FOnGameTerminated; property OnPlayerTerminated: TNotifyEvent read FOnPlayerTerminated write FOnPlayerTerminated; property OnExecuteEventLog: TMapExecuteLogEvent read FOnExecuteEventLog write FOnExecuteEventLog; property OnViewPortChange: TNotifyEvent read FOnViewPortChange write FOnViewPortChange; property OnDiplomaticChange: TNotifyEvent read FOnDiplomaticChange write FOnDiplomaticChange;
    property OnExitGame: TNotifyEvent read FOnExitGameEvent write FOnExitGameEvent; end;

procedure Register;

implementation

type
  PRawObject = ^TRawObject;
  TRawObject = record
    Fields: array[0..511] of Pointer;
  end;
  PMapState = ^TMapState;
  TMapState = record
    Reserved00: array[0..$A3] of Byte;
    CurrentPlayer, SeatedPlayer: Shortint;
    ReservedA6: array[0..$72] of Byte;
    Result: Shortint; { +$119 }
    Reserved11A: array[0..$59] of Byte;
    Day: Integer; { +$174 }
  end;
  PPlayerState = ^TPlayerState;
  TPlayerState = record
    Reserved00: array[0..$2B] of Byte;
    Human: Boolean;
    Reserved2D: array[0..$78] of Byte;
    PlayerID: Shortint; { +$A6 }
  end;
  PTargetState = ^TTargetState;
  TTargetState = record
    Reserved00: array[0..$0C] of Byte;
    Status: Byte;
    Reserved0E: array[0..$29] of Byte;
    Mode: Byte; { +$38 }
  end;
  TGetPlayers = function(List: TPlayerList; Index: Integer): TObject;
  TGetArmyHS = function(Selection: TSelectedArmy): TArmyHS;
  TValidateEngine = function: Boolean;

{ needs: callable result declarations for the existing draft routines. }
function GetPlayersABI(List: TPlayerList; Index: Integer): TObject; assembler;
asm jmp TPlayerList.GetPlayers end;
function GetArmyHSABI(Selection: TSelectedArmy): TArmyHS; assembler;
asm jmp TSelectedArmy.GetArmyHS end;
function ValidateEngineABI: Boolean; assembler;
asm jmp ValidateAoWEngine end;

constructor TAoWMapControl.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  { needs: ValidateAoWEngine returns Boolean; its implementation declaration is still a procedure. }
  if ValidateEngineABI then
  begin
    TEventList(TRawObject(Pointer(AoWEngine)^).Fields[$48 div 4]).Add(ActivateHSM);
    TEventList(TRawObject(Pointer(AoWEngine)^).Fields[$4C div 4]).Add(DeactivateHSM);
    if AoWHSMap <> nil then LinkToHSM;
  end;
end;

destructor TAoWMapControl.Destroy;
begin
  if AoWEngine <> nil then
  begin
    TEventList(TRawObject(Pointer(AoWEngine)^).Fields[$48 div 4]).Remove(ActivateHSM);
    TEventList(TRawObject(Pointer(AoWEngine)^).Fields[$4C div 4]).Remove(DeactivateHSM);
    if AoWHSMap <> nil then ReleaseHSM;
  end;
  inherited Destroy;
end;

procedure TAoWMapControl.LinkToHSM;
var I: Integer;
begin
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$C div 4])^).Fields[$20 div 4]).Add(DblClick);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$19C div 4]).Add(ChangeDay);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1A8 div 4]).Add(PlayerChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1A0 div 4]).Add(NewTurn);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1A4 div 4]).Add(EndTurn);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1AC div 4]).Add(SeatedPlayerChanged);
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$18 div 4])^).Fields[$14 div 4]).Add(SelectHS);
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$18 div 4])^).Fields[$18 div 4]).Add(DeselectHS);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$A8 div 4]).Add(ShowMessage);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$BC div 4]).Add(MapChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$C0 div 4]).Add(ScannerIconsChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1EC div 4]).Add(MapSettingsChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1B0 div 4]).Add(CombatEvent);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$210 div 4]).Add(StructureChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$21C div 4]).Add(StructureDestroyed);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$20C div 4]).Add(ArmyChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$218 div 4]).Add(ArmyDestroyed);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$208 div 4]).Add(UnitChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$214 div 4]).Add(UnitDestroyed);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1BC div 4]).Add(GameOver);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1B8 div 4]).Add(GameTerminated);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$78 div 4]).Add(HSChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1B4 div 4]).Add(PlayerTerminated);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1D0 div 4]).Add(ExecuteEventLog);
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$E0 div 4])^).Fields[$34 div 4]).Add(TargetSelectionChange);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$70 div 4]).Add(ViewPortChange);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1E0 div 4]).Add(CastSpell);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1E4 div 4]).Add(ActivateAbility);
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$188 div 4])^).Fields[$3C div 4]).Add(GlobalMagicChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$198 div 4]).Add(RelationsChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1E8 div 4]).Add(DiplomaticChange);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1C4 div 4]).Add(ExitGameEvent);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$224 div 4]).Add(ActivateCombatMap);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$228 div 4]).Add(DeactivateCombatMap);
  for I := 0 to TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]).Count - 1 do
  begin
    TEventList(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$C div 4]).Add(GemsChanged);
    TEventList(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$10 div 4]).Add(IncomeChanged);
    TEventList(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$14 div 4]).Add(UpkeepChanged);
    TEventList(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$18 div 4]).Add(LogbookChanged);
    TEventList(TRawObject(Pointer(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$54 div 4])^).Fields[$48 div 4]).Add(PlayerMagicChanged);
  end;
end;

procedure TAoWMapControl.ReleaseHSM;
var I: Integer;
begin
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$C div 4])^).Fields[$20 div 4]).Remove(DblClick);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$19C div 4]).Remove(ChangeDay);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1A8 div 4]).Remove(PlayerChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1A0 div 4]).Remove(NewTurn);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1A4 div 4]).Remove(EndTurn);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1AC div 4]).Remove(SeatedPlayerChanged);
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$18 div 4])^).Fields[$14 div 4]).Remove(SelectHS);
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$18 div 4])^).Fields[$18 div 4]).Remove(DeselectHS);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$A8 div 4]).Remove(ShowMessage);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$BC div 4]).Remove(MapChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$C0 div 4]).Remove(ScannerIconsChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1EC div 4]).Remove(MapSettingsChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1B0 div 4]).Remove(CombatEvent);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$20C div 4]).Remove(ArmyChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$218 div 4]).Remove(ArmyDestroyed);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$208 div 4]).Remove(UnitChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$214 div 4]).Remove(UnitDestroyed);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$210 div 4]).Remove(StructureChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$21C div 4]).Remove(StructureDestroyed);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$78 div 4]).Remove(HSChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1BC div 4]).Remove(GameOver);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1B8 div 4]).Remove(GameTerminated);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1B4 div 4]).Remove(PlayerTerminated);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1D0 div 4]).Remove(ExecuteEventLog);
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$E0 div 4])^).Fields[$34 div 4]).Remove(TargetSelectionChange);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$70 div 4]).Remove(ViewPortChange);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1E0 div 4]).Remove(CastSpell);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1E4 div 4]).Remove(ActivateAbility);
  TEventList(TRawObject(Pointer(TRawObject(Pointer(AoWHSMap)^).Fields[$188 div 4])^).Fields[$3C div 4]).Remove(GlobalMagicChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$198 div 4]).Remove(RelationsChanged);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1E8 div 4]).Remove(DiplomaticChange);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$1C4 div 4]).Remove(ExitGameEvent);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$224 div 4]).Remove(ActivateCombatMap);
  TEventList(TRawObject(Pointer(AoWHSMap)^).Fields[$228 div 4]).Remove(DeactivateCombatMap);
  for I := 0 to TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]).Count - 1 do
  begin
    TEventList(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$C div 4]).Remove(GemsChanged);
    TEventList(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$10 div 4]).Remove(IncomeChanged);
    TEventList(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$14 div 4]).Remove(UpkeepChanged);
    TEventList(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$18 div 4]).Remove(LogbookChanged);
    TEventList(TRawObject(Pointer(TRawObject(Pointer(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), I))^).Fields[$54 div 4])^).Fields[$48 div 4]).Remove(PlayerMagicChanged);
  end;
end;

procedure TAoWMapControl.ActivateHSM(Map: TObject);
begin
  if TEObject(Map).ClassID = $20011 then
  begin
    LinkToHSM;
    if Assigned(FOnActivateHSM) then FOnActivateHSM(Self);
  end;
end;

procedure TAoWMapControl.DeactivateHSM(Map: TObject);
begin
  if TEObject(Map).ClassID = $20011 then
  begin
    if Assigned(FOnDeactivateHSM) then FOnDeactivateHSM(Self);
    ReleaseHSM;
  end;
end;

procedure TAoWMapControl.DblClick(Sender: TObject);
var HS: THexagonSprite;
begin
  if Assigned(FOnDblClickArmy) then
  begin
    HS := AoWHSMap.Selection.FindClass(TArmyHS);
    if HS <> nil then FOnDblClickArmy(TObject(TRawObject(Pointer(HS)^).Fields[$1C div 4]));
  end;
  if Assigned(FOnDblClickStructure) then
  begin
    HS := AoWHSMap.Selection.FindClass(TStructure);
    if HS <> nil then FOnDblClickStructure(HS);
  end;
end;

procedure TAoWMapControl.SelectHS(Sender: TObject);
var Selection: THexagonSpriteSelection;
begin
  try
  Selection := AoWHSMap.Selection;
  if Assigned(FOnSelectArmy) and (Selection.EventHS is TArmyHS) and (GetArmyHSABI(TSelectedArmy(TRawObject(Pointer(AoWHSMap)^).Fields[$D8 div 4])) <> nil) then FOnSelectArmy(TObject(TRawObject(Pointer(Selection.EventHS)^).Fields[$1C div 4]));
  if Assigned(FOnSelectStructure) and (Selection.EventHS is TStructure) then FOnSelectStructure(Selection.EventHS);
  if Assigned(FOnSelectItem) and (Selection.EventHS is TItemHS) then FOnSelectItem(Selection.EventHS);
  except
    Dialogs.ShowMessage('Exception occurred during SelectHS event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.DeselectHS(Sender: TObject);
var Selection: THexagonSpriteSelection;
begin
  try
  Selection := AoWHSMap.Selection;
  if Assigned(FOnDeselectArmy) and (Selection.EventHS is TArmyHS) then FOnDeselectArmy(TObject(TRawObject(Pointer(Selection.EventHS)^).Fields[$1C div 4]));
  if Assigned(FOnDeselectStructure) and (Selection.EventHS is TStructure) then FOnDeselectStructure(Selection.EventHS);
  if Assigned(FOnDeselectItem) and (Selection.EventHS is TItemHS) then FOnDeselectItem(Selection.EventHS);
  except
    Dialogs.ShowMessage('Exception occurred during DeselectHS event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.MapChanged(Sender: TObject);
begin
  try
    if Assigned(FOnMapChanged) then FOnMapChanged(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during MapChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ScannerIconsChanged(Sender: TObject);
begin
  try
    if Assigned(FOnScannerIconsChanged) then FOnScannerIconsChanged(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during ScannerIconsChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.MapSettingsChanged(Sender: TObject);
begin
  try
    if Assigned(FOnMapSettingsChanged) then FOnMapSettingsChanged(Self);
  except
    Dialogs.ShowMessage('Exception occurred during MapSettingsChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.PlayerChanged(Sender: TObject);
begin
  try
    if Assigned(FOnPlayerChanged) then FOnPlayerChanged(PMapState(AoWHSMap)^.CurrentPlayer);
  except
    Dialogs.ShowMessage('Exception occurred during PlayerChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ExitGameEvent(Sender: TObject);
begin
  try
    if Assigned(FOnExitGameEvent) then FOnExitGameEvent(Self);
  except
    Dialogs.ShowMessage('Exception occurred during ExitGame event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.NewTurn(Sender: TObject);
begin
  try
    if Assigned(FOnNewTurn) then FOnNewTurn(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during NewTurn event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.EndTurn(Player: TObject);
begin
  try
    if Assigned(FOnEndTurn) then FOnEndTurn(Shortint(Player), not PPlayerState(GetPlayersABI(TPlayerList(TRawObject(Pointer(AoWHSMap)^).Fields[$140 div 4]), Integer(Player)))^.Human);
  except
    Dialogs.ShowMessage('Exception occurred during EndTurn event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.SeatedPlayerChanged(Sender: TObject);
begin
  try
    if Assigned(FOnSeatedPlayerChanged) then FOnSeatedPlayerChanged(PMapState(AoWHSMap)^.SeatedPlayer);
  except
    Dialogs.ShowMessage('Exception occurred during PlayerChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.GemsChanged(Player: TObject);
begin
  try
    if Assigned(FOnGemsChanged) then FOnGemsChanged(PPlayerState(Player)^.PlayerID);
  except
    Dialogs.ShowMessage('Exception occurred during Gems Changed event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.IncomeChanged(Player: TObject);
begin
  try
    if Assigned(FOnIncomeChanged) then FOnIncomeChanged(PPlayerState(Player)^.PlayerID);
  except
    Dialogs.ShowMessage('Exception occurred during Income Changed event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.UpkeepChanged(Player: TObject);
begin
  try
    if Assigned(FOnUpkeepChanged) then FOnUpkeepChanged(PPlayerState(Player)^.PlayerID);
  except
    Dialogs.ShowMessage('Exception occurred during Upkeep Changed event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.PlayerMagicChanged(Control: TObject);
begin
  try
    if Assigned(FOnPlayerMagicChanged) then FOnPlayerMagicChanged(PPlayerState(TRawObject(Pointer(Control)^).Fields[$10 div 4])^.PlayerID);
  except
    Dialogs.ShowMessage('Exception occurred during Player Magic Changed event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.GlobalMagicChanged(Sender: TObject);
begin
  try
    if Assigned(FOnGlobalMagicChanged) then FOnGlobalMagicChanged(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during Magic Changed event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ShowMessage(Sender: TObject);
begin
  try
    if Assigned(FOnShowMessage) then FOnShowMessage(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during ShowMessage event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ChangeDay(Sender: TObject);
begin
  try
    if Assigned(FOnChangeDay) then FOnChangeDay(PMapState(AoWHSMap)^.Day);
  except
    Dialogs.ShowMessage('Exception occurred during ChangeDay event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.CombatEvent(Sender: TObject);
begin
  try
    if Assigned(FOnCombatEvent) then FOnCombatEvent(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during on combat event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.LogbookChanged(Player: TObject);
begin
  try
    if Assigned(FOnLogbookChanged) then FOnLogbookChanged(PPlayerState(Player)^.PlayerID);
  except
    Dialogs.ShowMessage('Exception occurred during LogbookChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.StructureChanged(Obj: TObject);
begin
  try
    if Assigned(FOnStructureChanged) then FOnStructureChanged(Obj);
  except
    Dialogs.ShowMessage('Exception occurred during OnStructureChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.StructureDestroyed(Obj: TObject);
begin
  try
    if Assigned(FOnStructureDestroyed) then FOnStructureDestroyed(Obj);
  except
    Dialogs.ShowMessage('Exception occurred during OnStructureDestroyed event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ArmyChanged(Obj: TObject);
begin
  try
    if Assigned(FOnArmyChanged) then FOnArmyChanged(Obj);
  except
    Dialogs.ShowMessage('Exception occurred during OnArmyChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ArmyDestroyed(Obj: TObject);
begin
  try
    if Assigned(FOnArmyDestroyed) then FOnArmyDestroyed(Obj);
  except
    Dialogs.ShowMessage('Exception occurred during OnArmyDestroyed event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.HSChanged(Sender: TObject);
begin
  try
    if Assigned(FOnHSChanged) then FOnHSChanged(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during OnHSChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.UnitChanged(Obj: TObject);
begin
  try
    if Assigned(FOnUnitChanged) then FOnUnitChanged(Obj);
  except
    Dialogs.ShowMessage('Exception occurred during OnUnitChanged event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.UnitDestroyed(Obj: TObject);
begin
  try
    if Assigned(FOnUnitDestroyed) then FOnUnitDestroyed(Obj);
  except
    Dialogs.ShowMessage('Exception occurred during OnUnitDestroyed event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.GameOver(Sender: TObject);
begin
  try
    if Assigned(FOnGameOver) then FOnGameOver(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during OnGameOver event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.GameTerminated(Sender: TObject);
begin
  try
    if Assigned(FOnGameTerminated) then FOnGameTerminated(PMapState(AoWHSMap)^.Result);
  except
    Dialogs.ShowMessage('Exception occurred during OnGameTerminated event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.PlayerTerminated(Sender: TObject);
begin
  try
    if Assigned(FOnPlayerTerminated) then FOnPlayerTerminated(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during OnPlayerTerminated event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ExecuteEventLog(Info: TObject);
begin
  try
    if Assigned(FOnExecuteEventLog) then
      FOnExecuteEventLog(PExecuteEventLogInfo(Info)^.Log, PExecuteEventLogInfo(Info)^.Immediate, PExecuteEventLogInfo(Info)^.Done);
  except
    Dialogs.ShowMessage('Exception occurred during OnExecuteEventLog event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ActivateCombatMap(Sender: TObject);
begin
  try
    if Assigned(FOnActivateCombatMap) then FOnActivateCombatMap(Self);
  except
    Dialogs.ShowMessage('Exception occurred during OnActivateCombatMap event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.DeactivateCombatMap(Sender: TObject);
begin
  try
    if Assigned(FOnDeactivateCombatMap) then FOnDeactivateCombatMap(Self);
  except
    Dialogs.ShowMessage('Exception occurred during OnDeactivateCombatMap event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.TargetSelectionChange(Control: TObject);
begin
  try
    if Assigned(FOnTargetSelectionChange) and ((PTargetState(TRawObject(Pointer(AoWHSMap)^).Fields[$E0 div 4])^.Status and 8) <> 0) then FOnTargetSelectionChange(TTargetSelectionControl(Control), TTargetSelectionControl(Control).FChange);
  except
    Dialogs.ShowMessage('Exception occurred during OnTargetSelectionChange event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.CastSpell(Sender: TObject);
begin
  try
    if Assigned(FOnCastSpell) then FOnCastSpell(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during OnCastSpell event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ViewPortChange(Sender: TObject);
begin
  try
    if Assigned(FOnViewPortChange) then FOnViewPortChange(Self);
  except
    Dialogs.ShowMessage('Exception occurred during OnViewPortChange event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.ActivateAbility(Sender: TObject);
begin
  try
    if Assigned(FOnActivateAbility) then FOnActivateAbility(Sender);
  except
    Dialogs.ShowMessage('Exception occurred during OnActivateAbility event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.DiplomaticChange(Sender: TObject);
begin
  try
    if Assigned(FOnDiplomaticChange) then FOnDiplomaticChange(Self);
  except
    Dialogs.ShowMessage('Exception occurred during OnDiplomaticChange event (TAoWMapControl)');
  end;
end;

procedure TAoWMapControl.RelationsChanged(Sender: TObject);
begin
  try
    if Assigned(FOnRelationsChanged) then FOnRelationsChanged(Self);
  except
    Dialogs.ShowMessage('Exception occurred during OnRelationsChanged event (TAoWMapControl)');
  end;
end;

procedure Register;
begin
  RegisterComponents('AoW', [TAoWMapControl]);
end;

initialization
finalization

end.
