unit AoWVideoDlg;

{ Draft declarations of AoWVideoDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWE, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TVideoDialog = class;
  TWMCampaignScenarioPage = class;
  TWMCampaignScenarioPageList = class;
  TWMCampaignScenario = class;
  TWMCampaign = class;


  { TVideoDialog (instance size 164, VMT 0040ADD4) }
  TVideoDialog = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    CloseBut: TAOWButton; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    Title: TAOWLabel; { +0050 }
    Close: TAOWButton; { +0054 }
    TCeltLR: TAOWImage; { +0058 }
    TopLine: TAoWFrame; { +005C }
    VideoLbl: TAOWLabel; { +0060 }
    TCeltPattern: TAOWImage; { +0064 }
    TitleIcon: TAOWImage; { +0068 }
    TCeltLL: TAOWImage; { +006C }
    DisplayModesLB: TAOWListBox; { +0070 }
    ResCB: TAOWCheckBox; { +0074 }
    ResSwLbl: TAOWLabel; { +0078 }
    ApplyBtn: TAOWButton; { +007C }
    T3LBPnl: TAOWPanel; { +0080 }
    VideoSB: TAOWVScrollBar; { +0084 }
    Translator: TIvTranslator; { +0088 }
    public
    F_VideoDialog_8C: Integer;
    F_VideoDialog_90: Byte;
    F_VideoDialog_91: array[0..10] of Byte;
    F_VideoDialog_9C: Integer;
    F_VideoDialog_A0: Integer;
    procedure VideoDlgWindowCreate;  { draft }
    procedure VideoDlgWindowDestroy;  { draft }
    procedure CloseButClick;  { draft }
    procedure ApplyBtnClick;  { draft }
    procedure ResCBChange(A1: Integer);  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure DlgShow;  { draft }
  end;

  { TWMCampaignScenarioPage (instance size 24, VMT 0040B804) }
  TWMCampaignScenarioPage = class(TEObject)
  public
    F_WMCampaignScenarioPage_08: Byte;
    F_WMCampaignScenarioPage_09: array[0..2] of Byte;
    F_WMCampaignScenarioPage_0C: Byte;
    F_WMCampaignScenarioPage_0D: array[0..2] of Byte;
    F_WMCampaignScenarioPage_10: Byte;
    F_WMCampaignScenarioPage_11: array[0..2] of Byte;
    F_WMCampaignScenarioPage_14: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TWMCampaignScenarioPageList (instance size 12, VMT 0040B8C4) }
  TWMCampaignScenarioPageList = class(TENode)
  public
  end;

  { TWMCampaignScenario (instance size 60, VMT 0040B9A8) }
  TWMCampaignScenario = class(TAoWCampaignScenario)
  public
    F_WMCampaignScenario_14: Byte;
    F_WMCampaignScenario_15: array[0..2] of Byte;
    F_WMCampaignScenario_18: Byte;
    F_WMCampaignScenario_19: array[0..2] of Byte;
    F_WMCampaignScenario_1C: Byte;
    F_WMCampaignScenario_1D: array[0..2] of Byte;
    F_WMCampaignScenario_20: Byte;
    F_WMCampaignScenario_21: array[0..2] of Byte;
    F_WMCampaignScenario_24: Byte;
    F_WMCampaignScenario_25: array[0..2] of Byte;
    F_WMCampaignScenario_28: Byte;
    F_WMCampaignScenario_29: array[0..2] of Byte;
    F_WMCampaignScenario_2C: Integer;
    F_WMCampaignScenario_30: Integer;
    F_WMCampaignScenario_34: Integer;
    F_WMCampaignScenario_38: Byte;
    F_WMCampaignScenario_39: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TWMCampaign (instance size 64, VMT 0040BA6C) }
  TWMCampaign = class(TAoWCampaign)
  public
    F_WMCampaign_34: Integer;
    F_WMCampaign_38: array[0..7] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    function CreateScenario: AoWE.TAoWCampaignScenario; override;
    function GetAutoSaveFileName(Auto: AoWE.TCampaignAutoSaveType): string; override;
  end;


implementation

procedure TVideoDialog.VideoDlgWindowCreate;
begin end;

procedure TVideoDialog.VideoDlgWindowDestroy;
begin end;

procedure TVideoDialog.CloseButClick;
begin end;

procedure TVideoDialog.ApplyBtnClick;
begin end;

procedure TVideoDialog.ResCBChange(A1: Integer);
begin end;

procedure TVideoDialog.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TVideoDialog.DlgShow;
begin end;

constructor TWMCampaignScenarioPage.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TWMCampaignScenarioPage.Destroy;
begin end;

class function TWMCampaignScenarioPage.ClassID: Integer;
begin Result := 0; end;

procedure TWMCampaignScenarioPage.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TWMCampaignScenario.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TWMCampaignScenario.Destroy;
begin end;

class function TWMCampaignScenario.ClassID: Integer;
begin Result := 0; end;

procedure TWMCampaignScenario.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TWMCampaign.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TWMCampaign.Destroy;
begin end;

class function TWMCampaign.ClassID: Integer;
begin Result := 0; end;

procedure TWMCampaign.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TWMCampaign.CreateScenario: AoWE.TAoWCampaignScenario;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TWMCampaign.Clear;
begin end;

function TWMCampaign.GetAutoSaveFileName(Auto: AoWE.TCampaignAutoSaveType): string;
begin Result := ''; end;


end.
