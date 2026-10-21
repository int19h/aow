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
    FDisplayModes: TDisplayModeList; { $8C }
    FFullScreen: Boolean; { $90; 0040B034 }
    FModeChanged: Boolean; { $91; 0040B034 } F_VideoDialog_92: array[0..9] of Byte;
    FDisplayWidth: Integer; { $9C; 0040B04C }
    { conflict: FWidth: Integer; }
    FDisplayHeight: Integer; { $A0; 0040B04C }
    { conflict: FHeight: Integer; }
    function CurrentMode: Integer;
    procedure ChangeResolution(W, H: Integer);
    procedure UpdateModes;
    procedure VideoDlgWindowCreate;  { draft }
    procedure VideoDlgWindowDestroy;  { draft }
    procedure CloseButClick;  { draft }
    procedure ApplyBtnClick;  { draft }
    procedure ResCBChange(Sender: TObject);
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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


var
  VideoDialog: TVideoDialog;

implementation

uses AoWWinMan, E3Globals;

function TVideoDialog.CurrentMode: Integer;
var
  W, H, I: Integer;
begin
  if MainForm.DXDC = MainForm.Display.ActiveDC then
  begin
    W := MainForm.DXDC.DisplayWidth; H := MainForm.DXDC.DisplayHeight;
    I := FDisplayModes.Count - 1;
    while (I >= 0) and ((W <> FDisplayModes.Items[I].Width) or (H <> FDisplayModes.Items[I].Height)) do Dec(I);
    Result := DisplayModesLB.Items.IndexOfObject(TObject(I));
  end
  else Result := 0;
end;

procedure TVideoDialog.ChangeResolution(W, H: Integer);
begin
  if W = 0 then
  begin
    if MainForm.Display.ActiveDC = MainForm.DXDC then MainForm.Display.SwapDC;
  end
  else
    if MainForm.DXDC = MainForm.Display.ActiveDC then
    begin
      if (W <> MainForm.DXDC.DisplayWidth) or (H <> MainForm.DXDC.DisplayHeight) then
      begin
        MainForm.DXDC.SwitchResolution(W, H); MWindow.MapViewer.ResetStaticSurface;
        if Dlg.Visible then begin Dlg.FBackSurface.Free; Dlg.FBackSurface := nil; end;
      end;
    end
    else
    begin
      MainForm.DXDC.DisplayWidth := W; MainForm.DXDC.DisplayHeight := H;
      MainForm.Display.SwapDC;
    end;
  UpdateModes; General.ResetLayout;
end;

procedure TVideoDialog.UpdateModes;
var
  I: Integer;
  Mode: TDisplayModeItem;
  S: string;
begin
  DisplayModesLB.Items.Clear;
  DisplayModesLB.Items.AddObject(TranslateRStr(DesktopWindowRStr), TObject(-1));
  for I := 0 to FDisplayModes.Count - 1 do
  begin
    Mode := FDisplayModes.Items[I];
    if (Mode.Width >= 640) and (Mode.Height >= 480) then
      DisplayModesLB.Items.AddObject(TranslateRStr(FullScreenRStr) + ':' + IntToStr(Mode.Width) + 'x' + IntToStr(Mode.Height), TObject(I));
  end;
  DisplayModesLB.Selected := CurrentMode;
  if DisplayModesLB.Selected <> -1 then
  begin
    S := DisplayModesLB.Items[DisplayModesLB.Selected];
    S := S + ' (' + LowerCase(TranslateRStr(CurrentRStr)) + ')';
    DisplayModesLB.Items[DisplayModesLB.Selected] := S;
  end;
end;

procedure TVideoDialog.VideoDlgWindowCreate;
begin
  FDisplayModes := TDisplayModeList.Create;
  ListDisplayModes(FDisplayModes, 0, 0, 16);
end;

procedure TVideoDialog.VideoDlgWindowDestroy;
begin
  FDisplayModes.Free;
end;

procedure TVideoDialog.CloseButClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TVideoDialog.ApplyBtnClick;
var
  I: Integer;
begin
  General.PlayButtonSound(0);
  if DisplayModesLB.Selected <> -1 then
  begin
    I := Integer(DisplayModesLB.Items.Objects[DisplayModesLB.Selected]);
    if I <> -1 then
    begin
      FDisplayWidth := FDisplayModes.Items[I].Width;
      FDisplayHeight := FDisplayModes.Items[I].Height;
      ChangeResolution(FDisplayWidth, FDisplayHeight); FFullScreen := True;
    end
    else
    begin
      FFullScreen := False; ChangeResolution(0, 0);
    end;
  end;
end;

procedure TVideoDialog.ResCBChange(Sender: TObject);
begin
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
  AoWEngine.FRegistry.SetAllowResolutionSwitches(ResCB.Checked);
end;

procedure TVideoDialog.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  General.Manager.FAligned := False;
  if Key = VK_ESCAPE then Dlg.Visible := False;
end;

procedure TVideoDialog.DlgShow;
begin
  VideoDialog.ResCB.Checked := AoWEngine.FRegistry.GetAllowResolutionSwitches;
end;

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
begin
  inherited Create(AOwner);
end;

destructor TWMCampaign.Destroy;
begin
  inherited Destroy;
end;

class function TWMCampaign.ClassID: Integer;
begin Result := $225000; end;

procedure TWMCampaign.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FFaction, 30);
end;

function TWMCampaign.CreateScenario: AoWE.TAoWCampaignScenario;
begin
  Result := TWMCampaignScenario.Create(nil);
end;

procedure TWMCampaign.Clear;
begin
  inherited Clear;
end;

function TWMCampaign.GetAutoSaveFileName(Auto: AoWE.TCampaignAutoSaveType): string;
begin
  if Auto = casScenarioFinished then
  begin
    Result := AoWHSMap.FMapName;
    if FFaction = 0 then Result := Result + '_' + TranslateRStr(WonRStr)
    else Result := Result + '-' + TranslateRStr(WonRStr); { Original uses Won for both factions. }
    Result := Result + '.acg';
  end
  else Result := inherited GetAutoSaveFileName(Auto);
end;


end.
