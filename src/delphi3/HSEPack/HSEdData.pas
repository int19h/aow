unit HSEdData;

{ The HSEdData unit of HSEPack.dpl: one switch of the map editor. THSMEdit.UpdateFrame draws the
  map only while UpdateMap is set; the editor (AoWEd.exe) clears it while it changes the map. }

interface

var
  UpdateMap: Boolean;

implementation {$IFDEF RUNTIME_PACKAGES} uses Hexagon; {$ENDIF}

initialization
  UpdateMap := True;
end.
