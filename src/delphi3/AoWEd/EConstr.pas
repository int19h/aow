unit EConstr;

{ Player construction property form recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, PlayerBox, checklst;

type
  TPlayerConstructionEditForm = class;
  TPlayerConstructionEditor = class;


  { TPlayerConstructionEditForm (instance size 560, VMT 00418498) }
  TPlayerConstructionEditForm = class(TAoWMapObjEditForm)
  public
    published
    Panel3: TPanel; { +0210 }
    BorderPanel: TDrawPanel; { +0214 }
    PlayerComboBox: TPlayerComboBox; { +0218 }
    Label1: TLabel; { +021C }
    RazedBox: TCheckBox; { +0220 }
    VictorySheet: TTabSheet; { +0224 }
    Memo1: TMemo; { +0228 }
    VictoryListBox: TCheckListBox; { +022C }
    public
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure BorderPanelDraw(Sender: TObject; const R: TRect);
    procedure RazedBoxClick(Sender: TObject);
  end;

  { TPlayerConstructionEditor (instance size 8, VMT 004186BC) }
  TPlayerConstructionEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TPlayerConstructionEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TPlayerConstructionEditForm.vmt90(Obj, Done);
end;

class procedure TPlayerConstructionEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TPlayerConstructionEditForm.FormCreate(Sender: TObject);
var I: Integer;
begin
  MainPageControl.ActivePage := GeneralSheet;
  PlayerComboBox.SetPlayerIndex(TPlayerStructure(FMapObject).FPlayer);
  if AoWHSMap.FVictoryCondition = vcCaptureLocations then
  begin
    VictoryListBox.Items.Clear;
    VictorySheet.TabVisible := True;
    for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
    begin
      VictoryListBox.Items.Add('Player ' + IntToStr(I) + ' (' + AoWHSSet.FRaceResources.GetRaceResource(AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace).FName + ')');
      VictoryListBox.Checked[I - 1] := TPlayerStructure(FMapObject).GetVictoryLocation(I);
    end;
  end
  else VictorySheet.TabVisible := False;
  RazedBox.Visible := TPlayerStructure(FMapObject).GetRazeable;
  RazedBox.Checked := TPlayerStructure(FMapObject).GetRazed;
  RazedBoxClick(Self);
  Caption := FMapObject.EditName + ' ' + TranslateRStr(PropertiesRStr);
end;

procedure TPlayerConstructionEditForm.OKBtnClick(Sender: TObject);
var I: Integer;
begin
  TPlayerStructure(FMapObject).SetPlayer(PlayerComboBox.FPlayerIndex);
  TPlayerStructure(FMapObject).SetRazed(RazedBox.Checked);
  if VictorySheet.TabVisible then
    for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
      TPlayerStructure(FMapObject).SetVictoryLocation(I, VictoryListBox.Checked[I - 1]);
  inherited OKBtnClick(Sender);
end;

procedure TPlayerConstructionEditForm.BorderPanelDraw(Sender: TObject; const R: TRect);
var Structure: TStructure;
begin
  Structure := TStructure(FMapObject);
  if Structure <> nil then Structure.ShowBorderImageDC(BorderPanel.Canvas.Handle, R);
end;

procedure TPlayerConstructionEditForm.RazedBoxClick(Sender: TObject);
begin
  if RazedBox.Checked then
  begin
    PlayerComboBox.Color := clBtnFace;
    PlayerComboBox.Enabled := False;
    Exit;
  end;
  PlayerComboBox.Color := clWindow;
  PlayerComboBox.Enabled := True;
end;


end.
