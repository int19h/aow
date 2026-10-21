{ P5 unnamed helper declarations; these must follow the forward class block. }
procedure NegotiateArmy(Player: Shortint; ArmyHS: TArmyHS; Selection: Byte;
  X, Y, L: Shortint; MovePoints: Integer);
procedure BroadcastDiplomaticEvent(Log: TDiplomaticActionEventLog; Exclude: Shortint);

var
  MovePointTables: array[0..255] of TMovePointTable; { $558EA040 }
