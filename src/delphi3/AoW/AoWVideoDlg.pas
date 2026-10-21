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


  { TVideoDialog: size $A4; $90 full screen, $91 change flag, $9C/$A0 display size. VMT 0040ADD4. }
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
    FFullScreen: Boolean; { $90; 0040B034 }
    FModeChanged: Boolean; { $91; 0040B034 } F_VideoDialog_92: array[0..9] of Byte;
    FDisplayWidth: Integer; { $9C; 0040B04C }
    FDisplayHeight: Integer; { $A0; 0040B04C }
    procedure VideoDlgWindowCreate;  { draft }
    procedure VideoDlgWindowDestroy;  { draft }
    procedure CloseButClick;  { draft }
    procedure ApplyBtnClick;  { draft }
    procedure ResCBChange(A1: Integer);  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure DlgShow;  { draft }
  end;

  { TWMCampaignScenarioPage: size $18; $08 image library, $0C image index, $10 heading, $14 text. VMT 0040B804. }
  TWMCampaignScenarioPage = class(TEObject)
  public
    FImageLibrary: string; { $08 }
    { Managed string at $08. }
    FImageIndex: Integer; { $0C }
    { Integer at $0C. }
    FHeading: string; { $10 }
    { Managed string at $10. }
    FText: TStringList; { $14 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TWMCampaignScenarioPageList (instance size 12, VMT 0040B8C4) }
  TWMCampaignScenarioPageList = class(TENode)
  public
  end;

  { TWMCampaignScenario: size $3C; $14 image library, $18 path text, $1C description, $20 flag, $24/$28 position, $2C paths, $30/$34 pages, $38 map kind. VMT 0040B9A8. }
  TWMCampaignScenario = class(TAoWCampaignScenario)
  public
    FImageLibrary: string; { $14 }
    { Managed string at $14. }
    FPathDescription: string; { $18 }
    { Managed string at $18. }
    FDescription: string; { $1C }
    { Managed string at $1C. }
    F_WMCampaignScenario_20: Boolean; { $20; 0040BCE7 rwBool }
    F_WMCampaignScenario_21: array[0..2] of Byte;
    FMapX: Integer; { $24 }
    { Integer at $24. }
    FMapY: Integer; { $28 }
    { Integer at $28. }
    FPaths: TIntegerList; { $2C }
    FIntroPages: TWMCampaignScenarioPageList; { $30 }
    FOutroPages: TWMCampaignScenarioPageList; { $34 }
    FMapKind: Byte; { $38 }
    F_WMCampaignScenario_39: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TWMCampaign: size $40; $34 faction, $38 state, $3C page. VMT 0040BA6C. }
  TWMCampaign = class(TAoWCampaign)
  public
    FFaction: Integer; { $34; 0041D90E }
    FState: Integer; { $38; 0041D968 } FPage: Integer; { $3C; 0041E43C }
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
begin
  inherited Create(AOwner);
  FText := TStringList.Create;
end;


destructor TWMCampaignScenarioPage.Destroy;
begin
  FText.Free;
  inherited Destroy;
end;


class function TWMCampaignScenarioPage.ClassID: Integer;
begin Result := $225002; end;


procedure TWMCampaignScenarioPage.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FText, 10);
  Stream.rwString(FHeading, 11);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FImageLibrary, 12);
  Stream.rwInteger(FImageIndex, 13);
end;


constructor TWMCampaignScenario.Create(AOwner: Engine.TECustomNode);
var
  I: Integer;
begin
  inherited Create(AOwner);
  FIntroPages := TWMCampaignScenarioPageList.Create(nil);
  FOutroPages := TWMCampaignScenarioPageList.Create(nil);
  for I := 0 to 9 do
  begin
    TWMCampaignScenarioPage.Create(FIntroPages);
    TWMCampaignScenarioPage.Create(FOutroPages);
  end;
  FPaths := TIntegerList.Create;
  FPaths.Default := -1;
end;


destructor TWMCampaignScenario.Destroy;
begin
  FIntroPages.Free;
  FOutroPages.Free;
  FPaths.Free;
  inherited Destroy;
end;


class function TWMCampaignScenario.ClassID: Integer;
begin Result := $225001; end;


procedure TWMCampaignScenario.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FImageLibrary, 12);
  Stream.rwString(FPathDescription, 13);
  Stream.rwString(FDescription, 14);
  Stream.rwBool(F_WMCampaignScenario_20, 15);
  Stream.rwInteger(FMapX, 16);
  Stream.rwInteger(FMapY, 17);
  Stream.rwEObject(FIntroPages, 19);
  Stream.rwEObject(FOutroPages, 20);
  Stream.rwStreamProc(21, FPaths.LoadFromStream, FPaths.SaveToStream);
  Stream.rwData(FMapKind, 1, 22);
end;


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
