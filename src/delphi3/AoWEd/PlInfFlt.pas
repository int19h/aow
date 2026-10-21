unit PlInfFlt;

{ Draft declarations of PlInfFlt, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  No added instance fields; published controls occupy $1DC through $260. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, MapCtrl, PlayerBox;

type
  TPlayerInfoFloater = class;


  { TPlayerInfoFloater (instance size 612, VMT 004250FC) }
  TPlayerInfoFloater = class(TForm)
  public
    published
    PlayerInfoMapControl: TAoWMapControl; { +01DC }
    Panel2: TPanel; { +01E0 }
    PlayerComboBox: TPlayerComboBox; { +01E4 }
    Label1: TLabel; { +01E8 }
    PlayerPageControl: TPageControl; { +01EC }
    IncomeSheet: TTabSheet; { +01F0 }
    Label7: TLabel; { +01F4 }
    ExternalIncomeEdit: TPanel; { +01F8 }
    StructureSheet: TTabSheet; { +01FC }
    CityIncomeLab: TLabel; { +0200 }
    MinesLbl: TLabel; { +0204 }
    FarmLbl: TLabel; { +0208 }
    ExternalLbl: TLabel; { +020C }
    MineIncomeEdit: TPanel; { +0210 }
    FarmIncomeEdit: TPanel; { +0214 }
    UpkeepEdit: TPanel; { +0218 }
    NetIncomeEdit: TPanel; { +021C }
    Label6: TLabel; { +0220 }
    Bevel1: TBevel; { +0224 }
    StructureGrid: TStringGrid; { +0228 }
    PowerSheet: TTabSheet; { +022C }
    Label2: TLabel; { +0230 }
    PowerNodePowerEdit: TPanel; { +0234 }
    Label3: TLabel; { +0238 }
    HeroPowerEdit: TPanel; { +023C }
    Bevel2: TBevel; { +0240 }
    Label4: TLabel; { +0244 }
    TotalPowerEdit: TPanel; { +0248 }
    VictoryLocationsSheet: TTabSheet; { +024C }
    VictoryGrid: TStringGrid; { +0250 }
    ExternalPowerEdit: TPanel; { +0254 }
    ExternalPwrLbl: TLabel; { +0258 }
    Translator: TIvTranslator; { +025C }
    CityIncomeEdit: TPanel; { +0260 }
    public
    procedure UpdateStructureGrid(Grid: TStringGrid; Structures: TPlayerStructureList);
    procedure LoadPlayer(PlayerIndex: Shortint);
    procedure UpdatePlayer;
    procedure PlayerInfoMapControlActivateHSM(Sender: TObject);
    procedure PlayerInfoMapControlDeactivateHSM(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PlayerInfoMapControlGemsChanged(Player: Shortint);
    procedure PlayerInfoMapControlUpkeepChanged(Player: Shortint);
    procedure PlayerInfoMapControlIncomeChanged(Player: Shortint);
    procedure PlayerInfoMapControlStructureChanged(Sender: TObject);
    procedure PlayerComboBoxChange(Sender: TObject);
    procedure StructureGridDblClick(Sender: TObject);
    procedure PlayerInfoMapControlMapSettingsChanged(Sender: TObject);
    procedure FormClose(Sender: TObject);
  end;


var PlayerInfoFloater: TPlayerInfoFloater; { AoWEd 0042BB4E }

implementation

uses MDIForm, City, Mine, Farm;

function CompareStructures(A, B: Pointer): Integer;
begin
  Result := CompareText(TPlayerStructure(A).EditName, TPlayerStructure(B).EditName);
end;

procedure TPlayerInfoFloater.UpdateStructureGrid(Grid: TStringGrid; Structures: TPlayerStructureList);
var
  List: TList;
  I: Integer;
  Structure: TPlayerStructure;
  Name, Info: string;
begin
  Grid.Cols[0].Clear;
  Grid.Cols[1].Clear;
  Grid.Cells[0, 0] := TranslateRStr(StructureRStr);
  Grid.Cells[1, 0] := 'Info';
  List := TList.Create;
  for I := 0 to Structures.Count - 1 do List.Add(Structures.GetStructure(I));
  List.Sort(CompareStructures);
  for I := 0 to Structures.Count - 1 do
  begin
    Structure := TPlayerStructure(List[I]);
    Name := Structure.EditName;
    Info := '';
    if Structure is TCity then Info := TCity(Structure).GetName;
    Grid.Cells[0, I + 1] := Name;
    Grid.Cells[1, I + 1] := Info;
    Grid.Objects[0, I + 1] := Structure;
  end;
  Grid.RowCount := Structures.Count + 1;
  Grid.Invalidate;
  List.Free;
end;

procedure TPlayerInfoFloater.LoadPlayer(PlayerIndex: Shortint);
var
  Player: TPlayer;
  NodePower, HeroPower, I: Integer;
begin
  Player := AoWHSMap.FPlayers.GetPlayers(PlayerIndex);
  ExternalIncomeEdit.Caption := IntToStr(Player.FBaseIncome);
  CityIncomeEdit.Caption := IntToStr(CityIncome(PlayerIndex));
  MineIncomeEdit.Caption := IntToStr(MineIncome(PlayerIndex));
  FarmIncomeEdit.Caption := IntToStr(FarmIncome(PlayerIndex));
  UpkeepEdit.Caption := IntToStr(Player.GetUpkeep);
  NetIncomeEdit.Caption := IntToStr(Player.FIncome - Player.GetUpkeep);
  HeroPower := 0;
  NodePower := 0;
  with Player.FMagicControl do
    for I := 0 to FPowerSources.Count - 1 do
      if FPowerSources.GetItems(I) is TPlayerStructurePowerSource then
        Inc(NodePower, FPowerSources.GetItems(I).Power)
      else if FPowerSources.GetItems(I) is THeroPowerSource then
        Inc(HeroPower, FPowerSources.GetItems(I).Power);
  PowerNodePowerEdit.Caption := IntToStr(NodePower);
  HeroPowerEdit.Caption := IntToStr(HeroPower);
  ExternalPowerEdit.Caption := IntToStr(Player.FMagicControl.FExternalPower);
  TotalPowerEdit.Caption := IntToStr(Player.FMagicControl.GetNetPower);
  UpdateStructureGrid(StructureGrid, Player.FStructures);
  UpdateStructureGrid(VictoryGrid, Player.FVictoryLocations);
end;

procedure TPlayerInfoFloater.UpdatePlayer;
var Page: TTabSheet;
begin
  VictoryLocationsSheet.TabVisible := (AoWHSMap.FVictoryCondition = vcCaptureLocations) and (PlayerComboBox.FPlayerIndex <> 0);
  IncomeSheet.TabVisible := PlayerComboBox.FPlayerIndex <> 0;
  PowerSheet.TabVisible := PlayerComboBox.FPlayerIndex <> 0;
  with PlayerPageControl do
  begin
    Page := ActivePage;
    if (Page <> nil) and not Page.TabVisible then ActivePage := StructureSheet;
  end;
  LoadPlayer(PlayerComboBox.FPlayerIndex);
end;


procedure TPlayerInfoFloater.PlayerInfoMapControlActivateHSM(Sender: TObject);
begin
  PlayerComboBox.GenerateItems;
  PlayerComboBox.ItemIndex := 0;
  UpdatePlayer;
end;

procedure TPlayerInfoFloater.PlayerInfoMapControlDeactivateHSM(Sender: TObject);
begin
  Hide;
end;

procedure TPlayerInfoFloater.FormShow(Sender: TObject);
begin
  UpdatePlayer;
end;

procedure TPlayerInfoFloater.PlayerInfoMapControlGemsChanged(Player: Shortint);
begin
  if Visible and (Player = PlayerComboBox.FPlayerIndex) then UpdatePlayer;
end;

procedure TPlayerInfoFloater.PlayerInfoMapControlUpkeepChanged(Player: Shortint);
begin
  if Visible and (Player = PlayerComboBox.FPlayerIndex) then UpdatePlayer;
end;

procedure TPlayerInfoFloater.PlayerInfoMapControlIncomeChanged(Player: Shortint);
begin
  if Visible and (Player = PlayerComboBox.FPlayerIndex) then UpdatePlayer;
end;

procedure TPlayerInfoFloater.PlayerInfoMapControlStructureChanged(Sender: TObject);
begin
  if Visible then UpdatePlayer;
end;

procedure TPlayerInfoFloater.PlayerComboBoxChange(Sender: TObject);
begin
  UpdatePlayer;
end;

procedure TPlayerInfoFloater.StructureGridDblClick(Sender: TObject);
var Structure: TPlayerStructure;
begin
  with TStringGrid(Sender) do
    if Row <> 0 then
    begin
      Structure := TPlayerStructure(Objects[0, Row]);
      MainForm.SetMapLevel(Structure.GetLhx);
      AoWHSMap.Select(Structure, False);
      MainForm.HSMEdit.CenterView(Structure.GetXhx, Structure.GetYhx, Structure.GetLhx);
    end;
end;

procedure TPlayerInfoFloater.PlayerInfoMapControlMapSettingsChanged(Sender: TObject);
begin
  UpdatePlayer;
end;

procedure TPlayerInfoFloater.FormClose(Sender: TObject);
begin
  if AoWHSMap <> nil then MainForm.PlayerInfo.Checked := False;
end;

end.
