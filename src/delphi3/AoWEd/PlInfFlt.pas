unit PlInfFlt;

{ Draft declarations of PlInfFlt, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, MapCtrl, PlayerBox;

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
    procedure PlayerInfoMapControlActivateHSM;  { draft }
    procedure PlayerInfoMapControlDeactivateHSM;  { draft }
    procedure FormShow;  { draft }
    procedure PlayerInfoMapControlGemsChanged(A1: Byte);  { draft }
    procedure PlayerInfoMapControlUpkeepChanged(A1: Byte);  { draft }
    procedure PlayerInfoMapControlIncomeChanged(A1: Byte);  { draft }
    procedure PlayerInfoMapControlStructureChanged;  { draft }
    procedure PlayerComboBoxChange;  { draft }
    procedure StructureGridDblClick(A1: Integer);  { draft }
    procedure PlayerInfoMapControlMapSettingsChanged;  { draft }
    procedure FormClose;  { draft }
  end;


var PlayerInfoFloater: TPlayerInfoFloater; { AoWEd 0042BB4E }

implementation

procedure TPlayerInfoFloater.PlayerInfoMapControlActivateHSM;
begin end;

procedure TPlayerInfoFloater.PlayerInfoMapControlDeactivateHSM;
begin end;

procedure TPlayerInfoFloater.FormShow;
begin end;

procedure TPlayerInfoFloater.PlayerInfoMapControlGemsChanged(A1: Byte);
begin end;

procedure TPlayerInfoFloater.PlayerInfoMapControlUpkeepChanged(A1: Byte);
begin end;

procedure TPlayerInfoFloater.PlayerInfoMapControlIncomeChanged(A1: Byte);
begin end;

procedure TPlayerInfoFloater.PlayerInfoMapControlStructureChanged;
begin end;

procedure TPlayerInfoFloater.PlayerComboBoxChange;
begin end;

procedure TPlayerInfoFloater.StructureGridDblClick(A1: Integer);
begin end;

procedure TPlayerInfoFloater.PlayerInfoMapControlMapSettingsChanged;
begin end;

procedure TPlayerInfoFloater.FormClose;
begin end;


end.
