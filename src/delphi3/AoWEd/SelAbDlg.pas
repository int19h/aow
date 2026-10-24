unit SelAbDlg;

{ Draft declarations of SelAbDlg, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWDlg, AoWE;

type
  TAbilitySelectionDlg = class;


  { TAbilitySelectionDlg (instance size 536, VMT 00410004; $214 FAbilities) }
  TAbilitySelectionDlg = class(TAoWDialog)
  public
    published
    BottomPnl: TPanel; { +01E0 }
    OKBtn: TButton; { +01E4 }
    CancelBtn: TButton; { +01E8 }
    ClientPnl: TPanel; { +01EC }
    MainPageControl: TPageControl; { +01F0 }
    GeneralSheet: TTabSheet; { +01F4 }
    AddBtn: TButton; { +01F8 }
    DeleteBtn: TButton; { +01FC }
    SelectedAbBox: TListBox; { +0200 }
    AvailableAbBox: TListBox; { +0204 }
    Panel2: TPanel; { +0208 }
    Panel3: TPanel; { +020C }
    Translator: TIvTranslator; { +0210 }
    public
    FAbilityOwner: TAbilityOwner; { $214, owned working copy }
    { conflict: FAbilities: TAbilityOwner; }
    constructor CreateSelection(AbilityOwner: TAbilityOwner; AOwner: TComponent);
    { conflict: constructor CreateForAbilities(Abilities: TAbilityOwner; AOwner: Classes.TComponent); }
    procedure UpdateAddButton;
    procedure UpdateDeleteButton;
    destructor Destroy; override;
    procedure vmt80; virtual; { +080, available abilities }
    procedure vmt84; virtual; { +084, selected abilities }
    function vmt88(AbilityID: Integer): string; virtual; { +088 }
    function vmt8C(AbilityID: Integer): string; virtual; { +08C }
    function vmt90(AbilityID: Integer): Boolean; virtual; { +090 }
    function vmt94(AbilityID: Integer): Boolean; virtual; { +094 }
    published procedure AddBtnClick(Sender: TObject); public
    published procedure DeleteBtnClick(Sender: TObject); public
    published procedure FormShow(Sender: TObject); public
    published procedure AvailableAbBoxClick(Sender: TObject); public
    published procedure SelectedAbBoxClick(Sender: TObject); public
  end;


implementation

constructor TAbilitySelectionDlg.CreateSelection(AbilityOwner: TAbilityOwner; AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAbilityOwner := TAbilityOwner(AbilityOwner.Copy(AoWEngine));
end;

procedure TAbilitySelectionDlg.UpdateAddButton;
var
  Index: Integer;
begin
  with AvailableAbBox do
    if ItemIndex <> -1 then
    begin
      Index := Integer(Items.Objects[ItemIndex]);
      AddBtn.Enabled := vmt94(Index);
    end
    else AddBtn.Enabled := False;
end;

procedure TAbilitySelectionDlg.UpdateDeleteButton;
var
  Index: Integer;
begin
  with SelectedAbBox do
    if ItemIndex <> -1 then
    begin
      Index := Integer(Items.Objects[ItemIndex]);
      DeleteBtn.Enabled := vmt90(Index);
    end
    else DeleteBtn.Enabled := False;
end;

destructor TAbilitySelectionDlg.Destroy;
begin
  FAbilityOwner.Free;
  inherited Destroy;
end;

procedure TAbilitySelectionDlg.vmt80;
var
  I, ItemIndex, TopIndex: Integer;
  List: TStringList;
begin
  List := TStringList.Create;
  ItemIndex := AvailableAbBox.ItemIndex;
  TopIndex := AvailableAbBox.TopIndex;
  for I := 0 to AoWHSSet.FAbilityControl.GetCount - 1 do
    if AoWHSSet.FAbilityControl.GetAbility(I) <> nil then
      if AoWHSSet.FAbilityControl.GetAbility(I).CanExpand(FAbilityOwner) then
        List.AddObject(vmt8C(I), TObject(I));
  AvailableAbBox.Items.Assign(List);
  AvailableAbBox.TopIndex := TopIndex;
  AvailableAbBox.ItemIndex := ItemIndex;
  if AvailableAbBox.ItemIndex < 0 then AvailableAbBox.ItemIndex := 0;
  List.Free;
end;

procedure TAbilitySelectionDlg.vmt84;
var
  I, SavedIndex: Integer;
begin
  with SelectedAbBox do
  begin
    SavedIndex := ItemIndex;
    Items.Clear;
  end;
  for I := 0 to FAbilityOwner.GetAbCount - 1 do
    if FAbilityOwner.GetAbSet(I) then
      if FAbilityOwner.GetAbilitySelectionTypes * AoWHSSet.FAbilityControl.GetAbility(I).FSelectionTypes <> [] then
        SelectedAbBox.Items.AddObject(vmt88(I), TObject(I));
  SelectedAbBox.ItemIndex := SavedIndex;
  if SelectedAbBox.ItemIndex < 0 then
    SelectedAbBox.ItemIndex := SelectedAbBox.Items.Count - 1;
end;

function TAbilitySelectionDlg.vmt88(AbilityID: Integer): string;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetName(FAbilityOwner);
end;

function TAbilitySelectionDlg.vmt8C(AbilityID: Integer): string;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).ExpandName(FAbilityOwner);
end;

function TAbilitySelectionDlg.vmt90(AbilityID: Integer): Boolean;
begin
  Result := True;
end;

function TAbilitySelectionDlg.vmt94(AbilityID: Integer): Boolean;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).CanExpand(FAbilityOwner);
end;

procedure TAbilitySelectionDlg.AddBtnClick(Sender: TObject);
begin
  FAbilityOwner.ExpandAbility(Integer(AvailableAbBox.Items.Objects[AvailableAbBox.ItemIndex]));
  vmt84;
  vmt80;
  UpdateAddButton;
  UpdateDeleteButton;
end;

procedure TAbilitySelectionDlg.DeleteBtnClick(Sender: TObject);
begin
  FAbilityOwner.RemoveAbility(Integer(SelectedAbBox.Items.Objects[SelectedAbBox.ItemIndex]));
  vmt84;
  vmt80;
  UpdateAddButton;
  UpdateDeleteButton;
end;

procedure TAbilitySelectionDlg.FormShow(Sender: TObject);
begin
  inherited FormShow(Sender);
  vmt80;
  vmt84;
  UpdateAddButton;
  UpdateDeleteButton;
end;

procedure TAbilitySelectionDlg.AvailableAbBoxClick(Sender: TObject);
begin
  UpdateAddButton;
end;

procedure TAbilitySelectionDlg.SelectedAbBoxClick(Sender: TObject);
begin
  UpdateDeleteButton;
end;



end.
