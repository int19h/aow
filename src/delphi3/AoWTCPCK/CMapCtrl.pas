unit CMapCtrl;

{ Combat-map component event bindings, recovered from AoWTCPCK.dpl. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  { AoWE names this map-event payload TMapChangedInfo in the recovered source. }
  TMapAreaInfo = AoWE.TMapChangedInfo;

  TAoWCombatMapControl = class;

  TOnMessageEvent = procedure(var EMsg: TEMsg) of object;
  TSelectHSEvent = procedure(HS: THexagonSprite) of object;
  TDeselectHSEvent = procedure(HS: THexagonSprite) of object;
  TPlayerChangedEvent = procedure(Player: Shortint) of object;
  TShowMessageEvent = procedure(const Info: TShowMessageInfo) of object;
  TTurnChangedEvent = procedure(Turn: Integer) of object;
  TMapChangedEvent = procedure(const ChangedArea: TMapAreaInfo) of object;
  TOnGameOverEvent = procedure(Player: Shortint) of object;
  TOnExecuteEventLogEvent = procedure(EventLog: TEventLog; ExecuteDoneEvent: TExecuteDoneEvent) of object;
  TCastCombatSpellEvent = procedure(SC: TCombatSpellCaster) of object;
  TActivateCombatAbilityEvent = procedure(AAI: TActivateAbilityInfo) of object;

  { TAoWCombatMapControl: size $C4; event methods occupy $24..$C3. VMT 00435F38. }
  TAoWCombatMapControl = class(TComponent)
  public
    FOnSelected: TSelectHSEvent; { $24 }
    FOnDeselected: TSelectHSEvent; { $2C }
    FOnActivateHSM: TNotifyEvent; { $34 }
    FOnDeactivateHSM: TNotifyEvent; { $3C }
    FOnIncomeChanged: TPlayerChangedEvent; { $44 }
    FOnUpkeepChanged: TPlayerChangedEvent; { $4C }
    FOnGemsChanged: TPlayerChangedEvent; { $54 }
    FOnShowMessage: TShowMessageEvent; { $5C }
    FOnTurnChanged: TTurnChangedEvent; { $64 }
    FOnPlayerChanged: TPlayerChangedEvent; { $6C }
    FOnSeatedPlayerChanged: TPlayerChangedEvent; { $74 }
    FOnExecuteEventLog: TOnExecuteEventLogEvent; { $7C }
    FOnMapChanged: TMapChangedEvent; { $84 }
    FOnLogbookChanged: TPlayerChangedEvent; { $8C }
    FOnActivateMap: TNotifyEvent; { $94 }
    FOnDeActivateMap: TNotifyEvent; { $9C }
    FOnMouseOverTarget: TSelectHSEvent; { $A4 }
    FOnUnitChanged: TSelectHSEvent; { $AC }
    FOnCastSpell: TCastCombatSpellEvent; { $B4 }
    FOnActivateAbility: TActivateCombatAbilityEvent; { $BC }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure LinkToHSM;
    procedure ReleaseHSM;
    procedure ActivateHSM(Sender: TObject);
    procedure DeactivateHSM(Sender: TObject);
    procedure MapChanged(Sender: TObject);
    procedure SelectHS(Sender: TObject);
    procedure DeselectHS(Sender: TObject);
    procedure MouseOverTarget(Sender: TObject);
    procedure UnitChanged(Sender: TObject);
    procedure PlayerChanged(Sender: TObject);
    procedure SeatedPlayerChanged(Sender: TObject);
    procedure GemsChanged(Sender: TObject);
    procedure IncomeChanged(Sender: TObject);
    procedure UpkeepChanged(Sender: TObject);
    procedure ShowMessage(Sender: TObject);
    procedure ChangeTurn(Sender: TObject);
    procedure LogbookChanged(Sender: TObject);
    procedure ExecuteEventLog(Sender: TObject);
    procedure ActivateMap(Sender: TObject);
    procedure DeactivateMap(Sender: TObject);
    procedure CastSpell(Sender: TObject);
    procedure ActivateAbility(Sender: TObject);
  published
    property OnSelected: TSelectHSEvent read FOnSelected write FOnSelected;
    property OnDeselected: TSelectHSEvent read FOnDeselected write FOnDeselected;
    property OnActivateHSM: TNotifyEvent read FOnActivateHSM write FOnActivateHSM;
    property OnDeactivateHSM: TNotifyEvent read FOnDeactivateHSM write FOnDeactivateHSM;
    property OnIncomeChanged: TPlayerChangedEvent read FOnIncomeChanged write FOnIncomeChanged;
    property OnUpkeepChanged: TPlayerChangedEvent read FOnUpkeepChanged write FOnUpkeepChanged;
    property OnGemsChanged: TPlayerChangedEvent read FOnGemsChanged write FOnGemsChanged;
    property OnShowMessage: TShowMessageEvent read FOnShowMessage write FOnShowMessage;
    property OnTurnChanged: TTurnChangedEvent read FOnTurnChanged write FOnTurnChanged;
    property OnPlayerChanged: TPlayerChangedEvent read FOnPlayerChanged write FOnPlayerChanged;
    property OnSeatedPlayerChanged: TPlayerChangedEvent read FOnSeatedPlayerChanged write FOnSeatedPlayerChanged;
    property OnExecuteEventLog: TOnExecuteEventLogEvent read FOnExecuteEventLog write FOnExecuteEventLog;
    property OnMapChanged: TMapChangedEvent read FOnMapChanged write FOnMapChanged;
    property OnLogbookChanged: TPlayerChangedEvent read FOnLogbookChanged write FOnLogbookChanged;
    property OnActivateMap: TNotifyEvent read FOnActivateMap write FOnActivateMap;
    property OnDeActivateMap: TNotifyEvent read FOnDeActivateMap write FOnDeActivateMap;
    property OnMouseOverTarget: TSelectHSEvent read FOnMouseOverTarget write FOnMouseOverTarget;
    property OnUnitChanged: TSelectHSEvent read FOnUnitChanged write FOnUnitChanged;
    property OnCastSpell: TCastCombatSpellEvent read FOnCastSpell write FOnCastSpell;
    property OnActivateAbility: TActivateCombatAbilityEvent read FOnActivateAbility write FOnActivateAbility;
  end;

procedure Register;

implementation

uses AoWTC;

constructor TAoWCombatMapControl.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  if ValidateAoWEngine then
  begin
    AoWEngine.OnHSMLoaded.Add(ActivateHSM);
    AoWEngine.OnHSMClose.Add(DeactivateHSM);
  end;
end;

destructor TAoWCombatMapControl.Destroy;
begin
  if AoWEngine <> nil then
  begin
    AoWEngine.OnHSMLoaded.Remove(ActivateHSM);
    AoWEngine.OnHSMClose.Remove(DeactivateHSM);
    if AoWCombatMap <> nil then ReleaseHSM;
  end;
  inherited Destroy;
end;

procedure TAoWCombatMapControl.LinkToHSM;
var I: Integer;
begin
  AoWCombatMap.FChangeTurnEvents.Add(ChangeTurn);
  AoWCombatMap.FPlayerChangedEvents.Add(PlayerChanged);
  AoWCombatMap.FSeatedPlayerChangedEvents.Add(SeatedPlayerChanged);
  AoWCombatMap.Selection.OnSelect.Add(SelectHS);
  AoWCombatMap.Selection.OnDeselect.Add(DeselectHS);
  AoWCombatMap.FShowMessageEvents.Add(ShowMessage);
  AoWCombatMap.FMapChangedEvents.Add(MapChanged);
  AoWCombatMap.FDeselectEvents.Add(ActivateMap);
  AoWCombatMap.FSelectEvents.Add(DeactivateMap);
  AoWCombatMap.FMouseOverTargetEvents.Add(MouseOverTarget);
  AoWCombatMap.FUnitChangedEvents.Add(UnitChanged);
  AoWCombatMap.FAbilityActivatedEvents.Add(ActivateAbility);
  AoWCombatMap.FCombatStartedEvents.Add(CastSpell);
  AoWHSMap.FExecuteEventLogEvents.Add(ExecuteEventLog);
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
  begin
    AoWHSMap.FPlayers.GetPlayers(I).FGemsChangedEvents.Add(GemsChanged);
    AoWHSMap.FPlayers.GetPlayers(I).FIncomeChangedEvents.Add(IncomeChanged);
    AoWHSMap.FPlayers.GetPlayers(I).FUpkeepChangedEvents.Add(UpkeepChanged);
    AoWHSMap.FPlayers.GetPlayers(I).FLogbookChangedEvents.Add(LogbookChanged);
  end;
end;

procedure TAoWCombatMapControl.ReleaseHSM;
var I: Integer;
begin
  AoWCombatMap.FChangeTurnEvents.Remove(ChangeTurn);
  AoWCombatMap.FPlayerChangedEvents.Remove(PlayerChanged);
  AoWCombatMap.FSeatedPlayerChangedEvents.Remove(SeatedPlayerChanged);
  AoWCombatMap.Selection.OnSelect.Remove(SelectHS);
  AoWCombatMap.Selection.OnDeselect.Remove(DeselectHS);
  AoWCombatMap.FShowMessageEvents.Remove(ShowMessage);
  AoWCombatMap.FMapChangedEvents.Remove(MapChanged);
  AoWHSMap.FExecuteEventLogEvents.Remove(ExecuteEventLog);
  AoWCombatMap.FDeselectEvents.Remove(ActivateMap);
  AoWCombatMap.FSelectEvents.Remove(DeactivateMap);
  AoWCombatMap.FMouseOverTargetEvents.Remove(MouseOverTarget);
  AoWCombatMap.FUnitChangedEvents.Remove(UnitChanged);
  AoWCombatMap.FAbilityActivatedEvents.Remove(ActivateAbility);
  AoWCombatMap.FCombatStartedEvents.Remove(CastSpell);
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
  begin
    AoWHSMap.FPlayers.GetPlayers(I).FGemsChangedEvents.Remove(GemsChanged);
    AoWHSMap.FPlayers.GetPlayers(I).FIncomeChangedEvents.Remove(IncomeChanged);
    AoWHSMap.FPlayers.GetPlayers(I).FUpkeepChangedEvents.Remove(UpkeepChanged);
    AoWHSMap.FPlayers.GetPlayers(I).FLogbookChangedEvents.Remove(LogbookChanged);
  end;
end;

procedure TAoWCombatMapControl.ActivateHSM(Sender: TObject);
begin
  if TEObject(Sender).ClassID = $220100 then
  begin
    LinkToHSM;
    if Assigned(FOnActivateHSM) then FOnActivateHSM(Self);
  end;
end;

procedure TAoWCombatMapControl.DeactivateHSM(Sender: TObject);
begin
  if TEObject(Sender).ClassID = $220100 then
  begin
    if Assigned(FOnDeactivateHSM) then FOnDeactivateHSM(Self);
    ReleaseHSM;
  end;
end;

procedure TAoWCombatMapControl.MapChanged(Sender: TObject);
begin
  try
    if Assigned(FOnMapChanged) then FOnMapChanged(TMapAreaInfo(Pointer(Sender)^));
  except
    Dialogs.ShowMessage('Exception occurred during MapChanged event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.SelectHS(Sender: TObject);
begin
  try
    if Assigned(FOnSelected) then FOnSelected(AoWCombatMap.Selection.EventHS);
  except
    Dialogs.ShowMessage('Exception occurred during OnSelect event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.DeselectHS(Sender: TObject);
begin
  try
    if Assigned(FOnDeselected) then FOnDeselected(AoWCombatMap.Selection.EventHS);
  except
    Dialogs.ShowMessage('Exception occurred during OnDeselect event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.MouseOverTarget(Sender: TObject);
begin
  try
    if Assigned(FOnMouseOverTarget) then FOnMouseOverTarget(AoWCombatMap.FUnitSelection.FMouseOverTarget);
  except
    Dialogs.ShowMessage('Exception occurred during OnMouseOverTarget event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.UnitChanged(Sender: TObject);
begin
  try
    if Assigned(FOnUnitChanged) then FOnUnitChanged(AoWCombatMap.FUnitSelection.GetTCUnitHS);
  except
    Dialogs.ShowMessage('Exception occurred during UnitChanged event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.PlayerChanged(Sender: TObject);
begin
  try
    if Assigned(FOnPlayerChanged) then FOnPlayerChanged(AoWCombatMap.FCurrentPlayer);
  except
    Dialogs.ShowMessage('Exception occurred during PlayerChanged event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.SeatedPlayerChanged(Sender: TObject);
begin
  try
    if Assigned(FOnSeatedPlayerChanged) then FOnSeatedPlayerChanged(AoWCombatMap.FSeatedPlayer);
  except
    Dialogs.ShowMessage('Exception occurred during PlayerChanged event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.GemsChanged(Sender: TObject);
begin
  try
    if Assigned(FOnGemsChanged) then FOnGemsChanged(TPlayer(Sender).FPlayerIndex);
  except
    Dialogs.ShowMessage('Exception occurred during Gems Changed event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.IncomeChanged(Sender: TObject);
begin
  try
    if Assigned(FOnIncomeChanged) then FOnIncomeChanged(TPlayer(Sender).FPlayerIndex);
  except
    Dialogs.ShowMessage('Exception occurred during Income Changed event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.UpkeepChanged(Sender: TObject);
begin
  try
    if Assigned(FOnUpkeepChanged) then FOnUpkeepChanged(TPlayer(Sender).FPlayerIndex);
  except
    Dialogs.ShowMessage('Exception occurred during Upkeep Changed event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.ShowMessage(Sender: TObject);
begin
  try
    if Assigned(FOnShowMessage) then FOnShowMessage(TShowMessageInfo(Pointer(Sender)^));
  except
    Dialogs.ShowMessage('Exception occurred during ShowMessage event(TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.ChangeTurn(Sender: TObject);
begin
  try
    { The original passes the seated player as the turn number. }
    if Assigned(FOnTurnChanged) then FOnTurnChanged(AoWCombatMap.FSeatedPlayer);
  except
    Dialogs.ShowMessage('Exception occurred during ChangeTurn event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.LogbookChanged(Sender: TObject);
begin
  try
    if Assigned(FOnLogbookChanged) then FOnLogbookChanged(TPlayer(Sender).FPlayerIndex);
  except
    Dialogs.ShowMessage('Exception occurred during LogbookChanged event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.ExecuteEventLog(Sender: TObject);
begin
  try
    if Assigned(FOnExecuteEventLog) then FOnExecuteEventLog(TExecuteEventLogInfo(Pointer(Sender)^).Log, TExecuteEventLogInfo(Pointer(Sender)^).Done);
  except
    Dialogs.ShowMessage('Exception occurred during OnExecuteEventLog event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.ActivateMap(Sender: TObject);
begin
  try
    if Assigned(FOnActivateMap) then FOnActivateMap(Self);
  except
    Dialogs.ShowMessage('Exception occurred during OnActivateMap event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.DeactivateMap(Sender: TObject);
begin
  try
    if Assigned(FOnDeActivateMap) then FOnDeActivateMap(Self);
  except
    Dialogs.ShowMessage('Exception occurred during OnDeactivateMap event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.CastSpell(Sender: TObject);
begin
  try
    if Assigned(FOnCastSpell) then FOnCastSpell(TCombatSpellCaster(Sender));
  except
    Dialogs.ShowMessage('Exception occurred during OnCastSpell event (TAoWCombatMapControl)');
  end;
end;

procedure TAoWCombatMapControl.ActivateAbility(Sender: TObject);
begin
  try
    if Assigned(FOnActivateAbility) then FOnActivateAbility(TActivateAbilityInfo(Sender));
  except
    Dialogs.ShowMessage('Exception occurred during OnActivateAbility event (TAoWCombatMapControl)');
  end;
end;

procedure Register;
begin
  RegisterComponents('AoWEngine', [TAoWCombatMapControl]);
end;

initialization
finalization

end.
