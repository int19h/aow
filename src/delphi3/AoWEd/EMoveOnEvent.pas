unit EMoveOnEvent;

{ Draft declarations of EMoveOnEvent, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EAoWMO, SpinEdit, checklst, AoWE, MoveOnEvents;

type
  TMoveOnEventForm = class;


  { TMoveOnEventForm (instance size 548, VMT 0041E280) }
  TMoveOnEventForm = class(TAoWMapObjEditForm)
  public
    published
    TriggerSheet: TTabSheet; { +0210 }
    PlayersGroupBox: TGroupBox; { +0214 }
    TriggerPlayersLB: TCheckListBox; { +0218 }
    RadiusEdit: TSpin; { +021C }
    Label1: TLabel; { +0220 }
    public
    published procedure FormCreate(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
  end;


implementation

procedure TMoveOnEventForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  MainPageControl.ActivePage := TriggerSheet;
  TriggerPlayersLB.Items.Clear;
  for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
  begin
    TriggerPlayersLB.Items.Add('Player ' + IntToStr(I) + ' (' +
      AoWHSSet.FRaceResources.GetRaceResource(AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace).FName + ')');
    TriggerPlayersLB.Checked[I - 1] := TMoveOnEvent(FMapObject).GetTriggerPlayer(I);
  end;
  RadiusEdit.Value := TMoveOnEvent(FMapObject).FRadius;
  Caption := FMapObject.EditName;
end;

procedure TMoveOnEventForm.OKBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
    TMoveOnEvent(FMapObject).SetTriggerPlayer(I, TriggerPlayersLB.Checked[I - 1]);
  TMoveOnEvent(FMapObject).SetRadius(RadiusEdit.Value);
  inherited OKBtnClick(Sender);
end;


end.
