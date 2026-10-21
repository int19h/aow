unit PlayerBox;

{ Draft declarations of PlayerBox, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Recovered item generation and selection; original field offsets are listed below. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TPlayerComboBox = class;


  { TPlayerComboBox (instance size 372, VMT 55800248) }
  TPlayerComboBox = class(TComboBox)
  public
    FPlayerIndex: Shortint; { +$170 }
    FAllowNone: Boolean; { +$171 }
    FAllowIndependent: Boolean; { +$172 }
    FAllowRandom: Boolean; { +$173 }
    procedure Loaded; override;
    procedure GenerateItems;
    procedure SetPlayerIndex(Value: Shortint);
    procedure Change; override;
  end;

procedure Register;

implementation

const
  PlayerRStr: string = 'Player'; { needs: missing AoWE.PlayerRStr }

type
  TObjectFields = record Fields: array[0..511] of Pointer; end;
  PNameView = ^TNameView;
  TNameView = record Reserved: array[0..$23] of Byte; Name: string; end;
  PRaceView = ^TRaceView;
  TRaceView = record Reserved: array[0..$13] of Byte; Selectable: Boolean; end;
{ needs: the draft lookup procedures return objects; preserve their original register ABI. }
function GetRace(List: TRaceList; Index: Integer): TRace; assembler;
asm jmp TRaceList.GetRace end;
function GetRaceResource(List: TRaceResourceList; Index: Integer): TRaceResource; assembler;
asm jmp TRaceResourceList.GetRaceResource end;
function GetPlayers(List: TPlayerList; Index: Integer): TPlayer; assembler;
asm jmp TPlayerList.GetPlayers end;
function GetNumberOfPlayers(List: TPlayerList): Byte; assembler;
asm jmp TPlayerList.GetNumberOfPlayers end;
procedure TPlayerComboBox.GenerateItems;
var
  ResourceList: TRaceResourceList;
  I: Integer;
begin
  Items.Clear;
  if AoWHSMap <> nil then
  begin
    ResourceList := TRaceResourceList(TObjectFields(Pointer(AoWHSSet)^).Fields[$54 div 4]);
    if FAllowNone then Items.AddObject('None', TObject(-1));
    if FAllowRandom then Items.AddObject('Random', TObject(-2));
    if FAllowIndependent then Items.AddObject('Independents', nil);
    for I := 1 to GetNumberOfPlayers(TPlayerList(TObjectFields(Pointer(AoWHSMap)^).Fields[$140 div 4])) do
    begin
      Items.AddObject(AoWE.TranslateRStr(AoWE.PlayerRStr) + ' ' + IntToStr(I) + ' (' +
        PNameView(GetRaceResource(ResourceList, Shortint(GetPlayers(TPlayerList(TObjectFields(Pointer(AoWHSMap)^).Fields[$140 div 4]), I).FPlayerRace)))^.Name + ')', TObject(I));
    end;
  end;
end;

procedure TPlayerComboBox.SetPlayerIndex(Value: Shortint);
begin
  ItemIndex := Items.IndexOfObject(TObject(Integer(Value)));
  if (ItemIndex = -1) and (Items.Count <> 0) then ItemIndex := 0;
  if ItemIndex <> -1 then FPlayerIndex := Shortint(Items.Objects[ItemIndex])
  else FPlayerIndex := -1;
end;

procedure TPlayerComboBox.Change;
begin
  if ItemIndex <> -1 then FPlayerIndex := Shortint(Items.Objects[ItemIndex])
  else FPlayerIndex := -1;
  inherited Change;
end;

procedure TPlayerComboBox.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then GenerateItems;
end;

procedure Register;
begin
  RegisterComponents('AoW', [TPlayerComboBox]);
end;

initialization
finalization

end.
