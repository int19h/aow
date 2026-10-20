unit RaceBox;

{ Draft declarations of RaceBox, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Recovered item generation and selection; original field offsets are listed below. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TRaceBox = class;


  { TRaceBox (instance size 384, VMT 558006C8) }
  TRaceBox = class(TComboBox)
  public
    FOnGenerateItems: TNotifyEvent; { +$170 }
    FRace: Shortint; { +$178 }
    FAllowRandom: Boolean; { +$179 }
    FAllowNone: Boolean; { +$17A }
    FSelectableOnly: Boolean; { +$17B }
    FRaces: TRaceList; { +$17C }
    procedure Loaded; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure GenerateItems;
    procedure SetRace(Value: Shortint);
    procedure Change; override;
    procedure SetRaces(Value: TRaceList);
  end;

procedure Register;

implementation

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
constructor TRaceBox.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FSelectableOnly := True;
end;

procedure TRaceBox.GenerateItems;
var
  ResourceList: TRaceResourceList;
  I: Integer;
begin
  if Assigned(FOnGenerateItems) then FOnGenerateItems(Self);
  Items.Clear;
  if (AoWEngine <> nil) and (FRaces <> nil) then
  begin
    ResourceList := TRaceResourceList(TObjectFields(Pointer(AoWHSSet)^).Fields[$54 div 4]);
    if FAllowNone then Items.AddObject('None', TObject(-1));
    if FAllowRandom then Items.AddObject('Random', TObject(-2));
    for I := 0 to FRaces.Count - 1 do
      if GetRace(FRaces, I) <> nil then
        if not FSelectableOnly or PRaceView(GetRace(FRaces, I))^.Selectable then
          Items.AddObject(PNameView(GetRaceResource(ResourceList, I))^.Name, TObject(I));
  end;
end;

procedure TRaceBox.SetRace(Value: Shortint);
begin
  ItemIndex := Items.IndexOfObject(TObject(Integer(Value)));
  if (ItemIndex = -1) and (Items.Count <> 0) then ItemIndex := 0;
  if ItemIndex <> -1 then FRace := Shortint(Items.Objects[ItemIndex])
  else FRace := -1;
end;

procedure TRaceBox.Change;
begin
  if ItemIndex <> -1 then FRace := Shortint(Items.Objects[ItemIndex])
  else FRace := -1;
  inherited Change;
end;

procedure TRaceBox.SetRaces(Value: TRaceList);
begin
  FRaces := Value;
  if not (csDesigning in ComponentState) and not (csLoading in ComponentState) then GenerateItems;
end;

procedure TRaceBox.Loaded;
begin
  inherited Loaded;
  GenerateItems;
end;

procedure Register;
begin
  RegisterComponents('AoW', [TRaceBox]);
end;

initialization
finalization

end.
