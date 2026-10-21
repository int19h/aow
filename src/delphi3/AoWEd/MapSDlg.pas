unit MapSDlg;

{ Draft declarations of MapSDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RaceBox, SpinEdit, checklst;

type
  TMapSettingsDlg = class;


  { TMapSettingsDlg (instance size 768, VMT 004220D8) }
  TMapSettingsDlg = class(TForm)
  public
    published
    ClientPnl: TPanel; { +01DC }
    MainPageControl: TPageControl; { +01E0 }
    GeneralSheet: TTabSheet; { +01E4 }
    MapNameLbl: TLabel; { +01E8 }
    Label5: TLabel; { +01EC }
    MapnameEdit: TEdit; { +01F0 }
    PasswordEdit: TEdit; { +01F4 }
    SettingsSheet: TTabSheet; { +01F8 }
    GroupBox3: TGroupBox; { +01FC }
    RaceListCheckBox: TCheckListBox; { +0200 }
    PlayersSheet: TTabSheet; { +0204 }
    BottomPnl: TPanel; { +0208 }
    Button1: TButton; { +020C }
    CancelBtn: TButton; { +0210 }
    MapIntroductionMemo: TMemo; { +0214 }
    MapDescriptionLbl: TLabel; { +0218 }
    Bevel1: TBevel; { +021C }
    Label7: TLabel; { +0220 }
    PlayListBox: TListBox; { +0224 }
    AvailableSongsBox: TListBox; { +0228 }
    Label4: TLabel; { +022C }
    AddSong: TButton; { +0230 }
    DeleteSong: TButton; { +0234 }
    MapSongsLbl: TLabel; { +0238 }
    IndependantAIGroup: TRadioGroup; { +023C }
    RestrictionsBox: TGroupBox; { +0240 }
    Label6: TLabel; { +0244 }
    NumberOfHeroesEdit: TSpin; { +0248 }
    MaxSpherePicksEdit: TSpin; { +024C }
    MaxSpellLevelLabel: TLabel; { +0250 }
    Label2: TLabel; { +0254 }
    NumberOfPlayersEdit: TSpin; { +0258 }
    Label1: TLabel; { +025C }
    PlayerCB: TComboBox; { +0260 }
    Bevel3: TBevel; { +0264 }
    PlayerPnl: TPanel; { +0268 }
    Label15: TLabel; { +026C }
    PlayerRaceBox: TRaceBox; { +0270 }
    PlayerTypeBox: TComboBox; { +0274 }
    Label16: TLabel; { +0278 }
    PlayerFixed: TCheckBox; { +027C }
    Label18: TLabel; { +0280 }
    StartGoldEdit: TSpin; { +0284 }
    ExternalGoldIncomeEdit: TSpin; { +0288 }
    Label17: TLabel; { +028C }
    StartManaLbl: TLabel; { +0290 }
    ExternalManaIncome: TLabel; { +0294 }
    Bevel2: TBevel; { +0298 }
    ObjectiveDescriptionLbl: TLabel; { +029C }
    ObjectiveMemo: TMemo; { +02A0 }
    StartManaEdit: TSpin; { +02A4 }
    ExternalPowerIncomeEdit: TSpin; { +02A8 }
    BehaviorLbl: TLabel; { +02AC }
    BehaviorCB: TComboBox; { +02B0 }
    Bevel4: TBevel; { +02B4 }
    DiplomacySheet: TTabSheet; { +02B8 }
    RelationGrid: TDrawGrid; { +02BC }
    DiplomaticIcons: TImageList; { +02C0 }
    ChangePasswordBtn: TButton; { +02C4 }
    ObjectiveBox: TGroupBox; { +02C8 }
    ObjectivePnl: TPanel; { +02CC }
    AccumulateGoldRB: TRadioButton; { +02D0 }
    CaptureLocationsRB: TRadioButton; { +02D4 }
    NoneRB: TRadioButton; { +02D8 }
    AmountLbl: TLabel; { +02DC }
    AccumulateManaRB: TRadioButton; { +02E0 }
    Label3: TLabel; { +02E4 }
    AccumulateManaEdit: TSpin; { +02E8 }
    AccumulateGoldEdit: TSpin; { +02EC }
    Translator: TIvTranslator; { +02F0 }
    public
    F_MapSettingsDlg_2F4: Integer;
    F_MapSettingsDlg_2F8: Integer;
    F_MapSettingsDlg_2FC: Integer;
    procedure FormCreate;  { draft }
    procedure FormDestroy;  { draft }
    procedure RaceListCheckBoxClickCheck;  { draft }
    procedure PlayerCBChange;  { draft }
    procedure ObjectiveMemoChange;  { draft }
    procedure ExternalGoldIncomeEditChange;  { draft }
    procedure StartGoldEditChange;  { draft }
    procedure PlayerFixedClick;  { draft }
    procedure PlayerRaceBoxChange;  { draft }
    procedure PlayerTypeBoxChange;  { draft }
    procedure BehaviorCBChange;  { draft }
    procedure StartManaEditChange;  { draft }
    procedure ExternalPowerIncomeEditChange;  { draft }
    procedure OKBtnClick;  { draft }
    procedure AddSongClick;  { draft }
    procedure DeleteSongClick;  { draft }
    procedure ObjectiveBoxooClick;  { draft }
    procedure NumberOfPlayersEditChange;  { draft }
    procedure RelationGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure RelationGridDrawCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure RelationGridMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ChangePasswordBtnClick;  { draft }
    procedure VictoryConditionClick;  { draft }
    procedure FormCloseQuery(A1: Integer; A2: Integer);  { draft }
  end;


implementation

procedure TMapSettingsDlg.FormCreate;
begin end;

procedure TMapSettingsDlg.FormDestroy;
begin end;

procedure TMapSettingsDlg.RaceListCheckBoxClickCheck;
begin end;

procedure TMapSettingsDlg.PlayerCBChange;
begin end;

procedure TMapSettingsDlg.ObjectiveMemoChange;
begin end;

procedure TMapSettingsDlg.ExternalGoldIncomeEditChange;
begin end;

procedure TMapSettingsDlg.StartGoldEditChange;
begin end;

procedure TMapSettingsDlg.PlayerFixedClick;
begin end;

procedure TMapSettingsDlg.PlayerRaceBoxChange;
begin end;

procedure TMapSettingsDlg.PlayerTypeBoxChange;
begin end;

procedure TMapSettingsDlg.BehaviorCBChange;
begin end;

procedure TMapSettingsDlg.StartManaEditChange;
begin end;

procedure TMapSettingsDlg.ExternalPowerIncomeEditChange;
begin end;

procedure TMapSettingsDlg.OKBtnClick;
begin end;

procedure TMapSettingsDlg.AddSongClick;
begin end;

procedure TMapSettingsDlg.DeleteSongClick;
begin end;

procedure TMapSettingsDlg.ObjectiveBoxooClick;
begin end;

procedure TMapSettingsDlg.NumberOfPlayersEditChange;
begin end;

procedure TMapSettingsDlg.RelationGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMapSettingsDlg.RelationGridDrawCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMapSettingsDlg.RelationGridMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMapSettingsDlg.ChangePasswordBtnClick;
begin end;

procedure TMapSettingsDlg.VictoryConditionClick;
begin end;

procedure TMapSettingsDlg.FormCloseQuery(A1: Integer; A2: Integer);
begin end;


end.
