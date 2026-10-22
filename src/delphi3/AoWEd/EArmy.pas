unit EArmy;

{ Army editor handlers and placement control recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, PlayerBox, UnitGrid;

type
  TArmyEditForm = class;
  TArmyHSEditor = class;
  TArmyPlaceControl = class;


  { TArmyEditForm (instance size $254, VMT 004198F8; $250 FArmy) }
  TArmyEditForm = class(TAoWMapObjEditForm)
  public
    published
    GroupBox1: TGroupBox; { +0210 }
    UnitGrid: TUnitGrid; { +0214 }
    AddBtn: TButton; { +0218 }
    DeleteBtn: TButton; { +021C }
    EditBtn: TButton; { +0220 }
    GroupBox2: TGroupBox; { +0224 }
    Dir1: TRadioButton; { +0228 }
    Dir6: TRadioButton; { +022C }
    Dir2: TRadioButton; { +0230 }
    Dir5: TRadioButton; { +0234 }
    Dir3: TRadioButton; { +0238 }
    Dir4: TRadioButton; { +023C }
    Label1: TLabel; { +0240 }
    PlayerComboBox: TPlayerComboBox; { +0244 }
    BehaviourPanel: TPanel; { +0248 }
    BehaviourComboBox: TComboBox; { +024C }
    public
    FArmy: TArmy; { $250 }
    procedure EditHero(Hero: THero);
    procedure FormCreate(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure PlayerComboBoxChange(Sender: TObject);
    procedure BehaviourComboBoxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure UnitGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure EditBtnClick(Sender: TObject);
    procedure UnitGridDblClick(Sender: TObject);
    procedure DirectionChanged(Sender: TObject);
  end;

  { TArmyHSEditor (instance size 8, VMT 00419C18) }
  TArmyHSEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;

  { TArmyPlaceControl (instance size 8, VMT 00419CC4) }
  TArmyPlaceControl = class(TEObject)
  public
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
  end;


var ArmyPlaceControl: TArmyPlaceControl; { AoWEd 0042B645 }

implementation

uses UnitFlt, MDIForm, EHero;

var SavedPosition: TPoint;

class function TArmyHSEditor.EditorClassID: Integer;
begin
  Result := $20217;
end;

class procedure TArmyHSEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TArmyEditForm.vmt90(Obj, Done);
end;

class procedure TArmyHSEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TArmyEditForm.FormCreate(Sender: TObject);
var CanSelect: Boolean;
begin
  SetPositionInfo(@SavedPosition);
  FArmy := TArmyHS(FEditObject).FArmy;
  FArmy.BeginUpdate;
  PlayerComboBox.SetPlayerIndex(FArmy.FPlayer);
  PlayerComboBoxChange(Self);
  UnitGrid.FSelectionControl := UnitFloater.UnitTabControl.FSelectionControl;
  UnitGrid.SetUnits(FArmy);
  UnitGridSelectCell(Self, 0, 0, CanSelect);
  case TArmyHS(FEditObject).FDirection of
    1: Dir1.Checked := True;
    2: Dir2.Checked := True;
    3: Dir3.Checked := True;
    4: Dir4.Checked := True;
    5: Dir5.Checked := True;
    6: Dir6.Checked := True;
  end;
end;

procedure TArmyEditForm.CloseBtnClick(Sender: TObject);
begin
  MainForm.HSMEdit.SelectEditResource(nil);
end;

procedure TArmyEditForm.PlayerComboBoxChange(Sender: TObject);
begin
  FArmy.SetPlayer(PlayerComboBox.FPlayerIndex);
  if True then
  begin
    with BehaviourComboBox do
    begin
      Color := clWindow;
      BehaviourComboBox.Enabled := True;
      if PlayerComboBox.FPlayerIndex = 0 then
      begin
        Items.Clear;
        Items.AddObject(TranslateRStr(AutoRStr), TObject(0));
        Items.AddObject(TranslateRStr(PatrolRStr), TObject(1));
        Items.AddObject(TranslateRStr(GuardRStr), TObject(2));
        Items.AddObject(TranslateRStr(GuardAreaRStr), TObject(3));
        Items.AddObject(TranslateRStr(ScoutRStr), TObject(4));
        Items.AddObject(TranslateRStr(RefugeRStr), TObject(5));
        Items.AddObject(TranslateRStr(RaidRStr), TObject(6));
        Items.AddObject(TranslateRStr(SuicidalRStr), TObject(10));
        ItemIndex := Items.IndexOfObject(TObject(FArmy.FOldAIBehavior));
        { Original tests zero rather than the missing-item value -1. }
        if ItemIndex = 0 then
        begin
          ItemIndex := 0;
          BehaviourComboBoxChange(Self);
        end;
      end
      else
      begin
        Items.Clear;
        Items.AddObject(TranslateRStr(AutoRStr), TObject(0));
        Items.AddObject(TranslateRStr(PatrolRStr), TObject(1));
        Items.AddObject(TranslateRStr(GuardRStr), TObject(2));
        Items.AddObject(TranslateRStr(GuardAreaRStr), TObject(3));
        Items.AddObject(TranslateRStr(ScoutRStr), TObject(4));
        Items.AddObject(TranslateRStr(RaidRStr), TObject(6));
        Items.AddObject(TranslateRStr(SuicidalRStr), TObject(10));
        ItemIndex := Items.IndexOfObject(TObject(FArmy.FOldAIBehavior));
        { Original tests zero rather than the missing-item value -1. }
        if ItemIndex = 0 then
        begin
          ItemIndex := 0;
          BehaviourComboBoxChange(Self);
        end;
      end;
    end;
  end
  else
  begin
    BehaviourComboBox.Color := clBtnFace;
    BehaviourComboBox.Enabled := False;
  end;
  UnitGrid.Invalidate;
end;

procedure TArmyEditForm.BehaviourComboBoxChange(Sender: TObject);
begin
  if BehaviourComboBox.ItemIndex = 0 then
  begin
    FArmy.FOldAIBehavior := TGroupBehavior(0);
    Exit;
  end;
  with BehaviourComboBox do
    FArmy.FOldAIBehavior := TGroupBehavior(Items.Objects[ItemIndex]);
end;

procedure TArmyEditForm.FormShow(Sender: TObject);
begin
  with UnitFloater.UnitTabControl.FSelectionControl do
  begin
    FShowAllCategory := True;
    FShowRaceCategories := True;
    FShowTypeCategories := True;
  end;
  UnitFloater.ResetSelection;
  UnitFloater.SetShowHeroes(True);
  UnitFloater.UnitTabControl.UpdateSelection;
  UnitFloater.Show;
end;

procedure TArmyEditForm.FormDestroy(Sender: TObject);
begin
  UnitFloater.Hide;
  FArmy.EndUpdate;
end;

procedure TArmyEditForm.AddBtnClick(Sender: TObject);
begin
  UnitGrid.AddUnit;
end;

procedure TArmyEditForm.DeleteBtnClick(Sender: TObject);
begin
  UnitGrid.DeleteUnit;
end;

procedure TArmyEditForm.UnitGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var AUnit: TAbstractUnit;
begin
  AUnit := UnitGrid.GetUnit(ACol, ARow);
  EditBtn.Enabled := AUnit is THero;
end;

procedure TArmyEditForm.EditBtnClick(Sender: TObject);
begin
  if UnitGrid.GetSelectedUnit is THero then EditHero(THero(UnitGrid.GetSelectedUnit));
end;

procedure TArmyEditForm.UnitGridDblClick(Sender: TObject);
begin
  if UnitGrid.GetSelectedUnit is THero then EditHero(THero(UnitGrid.GetSelectedUnit));
end;

procedure TArmyEditForm.DirectionChanged(Sender: TObject);
var Direction: Integer;
begin
  if Dir1.Checked then Direction := 1
  else if Dir2.Checked then Direction := 2
  else if Dir3.Checked then Direction := 3
  else if Dir4.Checked then Direction := 4
  else if Dir5.Checked then Direction := 5
  else if Dir6.Checked then Direction := 6
  else Direction := 2;
  TUnitHS(FMapObject).SetDirection(Direction);
end;

procedure TArmyPlaceControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
var X, Y, L: Integer; Army: TArmyHS;
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10005 then
  begin
    L := Msg.Data[1];
    HPtoHX(Msg.Value, Msg.Data[0], X, Y);
    if AoWHSMap.MapContainer.GetField(X, Y, L).TerrainType <> 15 then
    begin
      Army := TArmyHS(AoWHSMap.MapContainer.GetField(X, Y, L).FindOwnedChild($20217));
      if Army = nil then
      begin
        Army := TArmyHS.Create(nil);
        if not AoWHSMap.PlaceHX(Army, X, Y, L) then
        begin
          Army.Free;
          Army := nil;
        end;
      end;
      if Army <> nil then
      begin
        TEObjectEditorClass(Army.Editor).Edit(Army, AoWEngine, nil);
        Msg.MsgID := 0;
        Msg.Result := 0;
      end;
    end;
  end;
end;


procedure TArmyEditForm.EditHero(Hero: THero);
var Form: THeroEditForm;
begin
  Form := THeroEditForm.Create(Application);
  if Hero.GetLibraryHero then Form.EditLibraryHero(Hero)
  else Form.EditHero(Hero);
  Form.Free;
end;

end.
