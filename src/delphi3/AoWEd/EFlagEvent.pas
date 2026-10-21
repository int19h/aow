unit EFlagEvent;

{ Flag event editor, size $220, inherited $20C map object. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EAoWMO, checklst, AoWE, FlagEvents;

type
  TFlagEventEditForm = class;


  { TFlagEventEditForm (instance size 544, VMT 0041F258) }
  TFlagEventEditForm = class(TAoWMapObjEditForm)
  public
    published
    PlayersGroupBox: TGroupBox; { +0210 }
    TriggerPlayersLB: TCheckListBox; { +0214 }
    Label1: TLabel; { +0218 }
    TriggerModeCB: TComboBox; { +021C }
    public
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  end;


implementation

procedure TFlagEventEditForm.FormCreate(Sender: TObject);
var I: Integer;
begin
  TriggerPlayersLB.Items.Clear;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
  begin
    TriggerPlayersLB.Items.Add('Player ' + IntToStr(I) + ' (' +
      AoWHSSet.FRaceResources.GetRaceResource(AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace).FName + ')');
    TriggerPlayersLB.Checked[I - 1] := TFlagEvent(FMapObject).GetTriggerPlayer(I);
  end;
  TriggerModeCB.ItemIndex := Ord(TFlagEvent(FMapObject).FTriggerMode);
end;

procedure TFlagEventEditForm.OKBtnClick(Sender: TObject);
var I: Integer;
begin
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    TFlagEvent(FMapObject).SetTriggerPlayer(I, TriggerPlayersLB.Checked[I - 1]);
  TFlagEvent(FMapObject).FTriggerMode := TFlagEventTriggerMode(TriggerModeCB.ItemIndex);
  inherited OKBtnClick(Sender);
end;

end.
