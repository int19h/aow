unit MDIForm;

{ Draft declarations of MDIForm, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Buttons, EResGrid, HSLib, HSMEdit, HSSEdit, HeroCtrl, ItemCtrl, LeadrGrd, SpinEdit, UnitIGrd, UnitTabC, checklst;

type
  TMainForm = class;


  { TMainForm (instance size 1708, VMT 00425CF0) }
  TMainForm = class(TForm)
  public
    published
    MainMenu1: TMainMenu; { +01DC }
    FileItem: TMenuItem; { +01E0 }
    NewItem: TMenuItem; { +01E4 }
    OpenMapItem: TMenuItem; { +01E8 }
    SaveItem: TMenuItem; { +01EC }
    SaveAsItem: TMenuItem; { +01F0 }
    CloseItem: TMenuItem; { +01F4 }
    N1: TMenuItem; { +01F8 }
    ExitItem: TMenuItem; { +01FC }
    HelpItem: TMenuItem; { +0200 }
    OptionsItem: TMenuItem; { +0204 }
    About1: TMenuItem; { +0208 }
    EditItem: TMenuItem; { +020C }
    CutItem: TMenuItem; { +0210 }
    CopyItem: TMenuItem; { +0214 }
    PasteItem: TMenuItem; { +0218 }
    DeleteItem: TMenuItem; { +021C }
    HSMEditDC: TWindows16DC; { +0220 }
    Panel1: TPanel; { +0224 }
    EditStatusBar: TStatusBar; { +0228 }
    HSMEdit: THSMEdit; { +022C }
    HSSEdit: THSSEdit; { +0230 }
    MORPanel: TPanel; { +0234 }
    MainPageControl: TPageControl; { +0238 }
    TileSheet: TTabSheet; { +023C }
    MORPageControl: TPageControl; { +0240 }
    SurfaceSheet: TTabSheet; { +0244 }
    SurfaceMORPage: TPageControl; { +0248 }
    GrassSheet: TTabSheet; { +024C }
    GrassMOR: TEResourceGrid; { +0250 }
    Steppe: TTabSheet; { +0254 }
    EResourceGrid2: TEResourceGrid; { +0258 }
    Desert: TTabSheet; { +025C }
    EResourceGrid3: TEResourceGrid; { +0260 }
    Snow: TTabSheet; { +0264 }
    EResourceGrid4: TEResourceGrid; { +0268 }
    Wasteland: TTabSheet; { +026C }
    EResourceGrid5: TEResourceGrid; { +0270 }
    StructuresSheet: TTabSheet; { +0274 }
    StructuresMOR: TEResourceGrid; { +0278 }
    HexagonSheet: TTabSheet; { +027C }
    HexagonsMOR: TEResourceGrid; { +0280 }
    UndergroundMORSHeet: TTabSheet; { +0284 }
    TabSheet1: TTabSheet; { +0288 }
    EResourceGrid6: TEResourceGrid; { +028C }
    UndergroundMORPage: TPageControl; { +0290 }
    DirtSheet: TTabSheet; { +0294 }
    DirtMOR: TEResourceGrid; { +0298 }
    uWastelandSheet: TTabSheet; { +029C }
    uWastelandMOR: TEResourceGrid; { +02A0 }
    TabSheet3: TTabSheet; { +02A4 }
    uStructuresMOR: TEResourceGrid; { +02A8 }
    uHexagonSheet: TTabSheet; { +02AC }
    uHexagonsMOR: TEResourceGrid; { +02B0 }
    TabSheet2: TTabSheet; { +02B4 }
    EResourceGrid7: TEResourceGrid; { +02B8 }
    DDrawFullScr16DC: TDDrawFullScr16DC; { +02BC }
    HeroesSheet: TTabSheet; { +02C0 }
    HeroPopupMenu: TPopupMenu; { +02C4 }
    AddFromHeroLib: TMenuItem; { +02C8 }
    DeleteHero: TMenuItem; { +02CC }
    EditHero: TMenuItem; { +02D0 }
    PreviewMode640x4801: TMenuItem; { +02D4 }
    N640x480: TMenuItem; { +02D8 }
    N800x600: TMenuItem; { +02DC }
    N1024x768: TMenuItem; { +02E0 }
    ObjectSheet: TTabSheet; { +02E4 }
    ObjectMOR: TEResourceGrid; { +02E8 }
    uObjectsSheet: TTabSheet; { +02EC }
    EResourceGrid1: TEResourceGrid; { +02F0 }
    UnitSelectionSheet: TTabSheet; { +02F4 }
    UnitTabControl: TUnitTabControl; { +02F8 }
    UnitSelectionGrid: TUnitIndexGrid; { +02FC }
    ItemSelectionSheet: TTabSheet; { +0300 }
    Panel5: TPanel; { +0304 }
    Panel6: TPanel; { +0308 }
    EditBrushes: THSLibrary; { +030C }
    RemoveFromMap: TMenuItem; { +0310 }
    N7: TMenuItem; { +0314 }
    N8: TMenuItem; { +0318 }
    N6: TMenuItem; { +031C }
    SortName: TMenuItem; { +0320 }
    SortLevels: TMenuItem; { +0324 }
    NewHeroItem: TMenuItem; { +0328 }
    ItemPopupMenu: TPopupMenu; { +032C }
    EditItemItem: TMenuItem; { +0330 }
    MenuItem2: TMenuItem; { +0334 }
    OpenItemLib: TMenuItem; { +0338 }
    MenuItem4: TMenuItem; { +033C }
    NewItemItem: TMenuItem; { +0340 }
    DeleteItemItem: TMenuItem; { +0344 }
    MenuItem8: TMenuItem; { +0348 }
    SortItemNames: TMenuItem; { +034C }
    SortItemTypes: TMenuItem; { +0350 }
    AgeOfWondersEngine: TAgeOfWondersEngine; { +0354 }
    DeveloperItems: TMenuItem; { +0358 }
    NewMapset: TMenuItem; { +035C }
    OpenMapset: TMenuItem; { +0360 }
    N9: TMenuItem; { +0364 }
    ExportText: TMenuItem; { +0368 }
    ImportText: TMenuItem; { +036C }
    DebugMode: TMenuItem; { +0370 }
    N11: TMenuItem; { +0374 }
    MapSetSettings: TMenuItem; { +0378 }
    MapSettings: TMenuItem; { +037C }
    N5: TMenuItem; { +0380 }
    LeaderSelectionSheet: TTabSheet; { +0384 }
    LeaderSelectionGrid: TLeaderGrid; { +0388 }
    N2: TMenuItem; { +038C }
    FogofWar: TMenuItem; { +0390 }
    PlayerInfo: TMenuItem; { +0394 }
    N4: TMenuItem; { +0398 }
    ItemControlGrid: TItemControlGrid; { +039C }
    RemoveItem: TMenuItem; { +03A0 }
    GotoItem: TMenuItem; { +03A4 }
    N10: TMenuItem; { +03A8 }
    HeroControlGrid: THeroControlGrid; { +03AC }
    GoToHero: TMenuItem; { +03B0 }
    N13: TMenuItem; { +03B4 }
    LeaderPopupMenu: TPopupMenu; { +03B8 }
    EditLeader: TMenuItem; { +03BC }
    GotoLeader: TMenuItem; { +03C0 }
    RemoveLeader: TMenuItem; { +03C4 }
    NewCombatMap: TMenuItem; { +03C8 }
    N14: TMenuItem; { +03CC }
    CombatSheet: TTabSheet; { +03D0 }
    Panel4: TPanel; { +03D4 }
    ScannerItem: TMenuItem; { +03D8 }
    CombatSurfacePageControl: TPageControl; { +03DC }
    CCitySheet: TTabSheet; { +03E0 }
    CCityMOR: TEResourceGrid; { +03E4 }
    CObjectSheet: TTabSheet; { +03E8 }
    CObjectsMOR: TEResourceGrid; { +03EC }
    CGrassSheet: TTabSheet; { +03F0 }
    CGrassMOR: TEResourceGrid; { +03F4 }
    CSteppeSheet: TTabSheet; { +03F8 }
    CSteppeMOR: TEResourceGrid; { +03FC }
    CDesertSheet: TTabSheet; { +0400 }
    CDesertMOR: TEResourceGrid; { +0404 }
    CSnowSheet: TTabSheet; { +0408 }
    CSnowMOR: TEResourceGrid; { +040C }
    CWastelandSheet: TTabSheet; { +0410 }
    CWastelandMOR: TEResourceGrid; { +0414 }
    CDirtSheet: TTabSheet; { +0418 }
    CTerrainu: TEResourceGrid; { +041C }
    CStructureSheet: TTabSheet; { +0420 }
    CStructureMOR: TEResourceGrid; { +0424 }
    ExplorationPlacesSheet: TTabSheet; { +0428 }
    PageControl1: TPageControl; { +042C }
    CDungeonSheet: TTabSheet; { +0430 }
    CDungeonMOR: TEResourceGrid; { +0434 }
    CMonsterlairSheet: TTabSheet; { +0438 }
    CMonsterlairMOR: TEResourceGrid; { +043C }
    CCryptSheet: TTabSheet; { +0440 }
    CCryptMOR: TEResourceGrid; { +0444 }
    CCastleRuinSheet: TTabSheet; { +0448 }
    CStructuresMOR: TEResourceGrid; { +044C }
    CZigguratSheet: TTabSheet; { +0450 }
    CZigguratMOR: TEResourceGrid; { +0454 }
    SettingsSheet: TTabSheet; { +0458 }
    PageControl3: TPageControl; { +045C }
    HiddenResourcesSheet: TTabSheet; { +0460 }
    HiddenResourceGrid: TEResourceGrid; { +0464 }
    RaceSheet: TTabSheet; { +0468 }
    RaceGrid: TEResourceGrid; { +046C }
    UnitGFX: TTabSheet; { +0470 }
    UnitGFXGrid: TEResourceGrid; { +0474 }
    UnitSheet: TTabSheet; { +0478 }
    UnitsGrid: TEResourceGrid; { +047C }
    HeroSheet: TTabSheet; { +0480 }
    HeroGrid: TEResourceGrid; { +0484 }
    ItemSheet: TTabSheet; { +0488 }
    ItemResourceGrid: TEResourceGrid; { +048C }
    FaceSheet: TTabSheet; { +0490 }
    FaceGrid: TEResourceGrid; { +0494 }
    AbilitySheet: TTabSheet; { +0498 }
    Panel3: TPanel; { +049C }
    AbilityListBox: TListBox; { +04A0 }
    GroupBox1: TGroupBox; { +04A4 }
    AbilityDescription: TMemo; { +04A8 }
    AbilityLevelPointBox: TGroupBox; { +04AC }
    Label1: TLabel; { +04B0 }
    AbilityLevelPoints: TSpin; { +04B4 }
    SFXBox: TGroupBox; { +04B8 }
    EditAbilitySFXBtn: TButton; { +04BC }
    AbGFXBox: TGroupBox; { +04C0 }
    AbGFXEdit: TButton; { +04C4 }
    GeneralSettingsSheet: TTabSheet; { +04C8 }
    AnimationsBox: TGroupBox; { +04CC }
    EditAnimations: TButton; { +04D0 }
    Spells: TTabSheet; { +04D4 }
    Panel9: TPanel; { +04D8 }
    SpellListBox: TListBox; { +04DC }
    GroupBox2: TGroupBox; { +04E0 }
    SpellDescription: TMemo; { +04E4 }
    GroupBox4: TGroupBox; { +04E8 }
    EditSpellSFX: TButton; { +04EC }
    GroupBox5: TGroupBox; { +04F0 }
    EditSpellGFX: TButton; { +04F4 }
    GroupBox3: TGroupBox; { +04F8 }
    Label2: TLabel; { +04FC }
    Label3: TLabel; { +0500 }
    Label4: TLabel; { +0504 }
    SpellMana: TSpin; { +0508 }
    SpellResearchPoints: TSpin; { +050C }
    SpellUpkeep: TSpin; { +0510 }
    Label5: TLabel; { +0514 }
    Label6: TLabel; { +0518 }
    SphereEdit: TComboBox; { +051C }
    SphereLevelEdit: TSpin; { +0520 }
    EditSpellText: TButton; { +0524 }
    EditAbilityText: TButton; { +0528 }
    GroupBox6: TGroupBox; { +052C }
    EditTextBtn: TButton; { +0530 }
    ItemLibrariesBox: TGroupBox; { +0534 }
    EditItemLibrariesBtn: TButton; { +0538 }
    HeroLibraryBox: TGroupBox; { +053C }
    EditHeroLibrariesBtn: TButton; { +0540 }
    GameSettingsMI: TMenuItem; { +0544 }
    N12: TMenuItem; { +0548 }
    RemoveMapLevel: TMenuItem; { +054C }
    AddMapLevel: TMenuItem; { +0550 }
    N15: TMenuItem; { +0554 }
    ExportAbilityInfo: TMenuItem; { +0558 }
    N1280x1024: TMenuItem; { +055C }
    RemoveLeadersItem: TMenuItem; { +0560 }
    DeveloperSheet: TTabSheet; { +0564 }
    DeveloperResourceGrid: TEResourceGrid; { +0568 }
    MapTextEditorMI: TMenuItem; { +056C }
    N16: TMenuItem; { +0570 }
    uDeveloperSheet: TTabSheet; { +0574 }
    uDeveloperResourceGrid: TEResourceGrid; { +0578 }
    DefaultPlayersMI: TMenuItem; { +057C }
    P0: TMenuItem; { +0580 }
    ExportForMultilizer: TMenuItem; { +0584 }
    AoWEdDictionary: TIvBinaryDictionary; { +0588 }
    Translator: TIvTranslator; { +058C }
    AbilityInfoGroup: TRadioGroup; { +0590 }
    AbilityInfoMemo: TMemo; { +0594 }
    AbilitySelectionGroup: TGroupBox; { +0598 }
    AbilitySelectionCLB: TCheckListBox; { +059C }
    ItemsPnl: TPanel; { +05A0 }
    OpenItemLibrary: TSpeedButton; { +05A4 }
    EditItemBtn: TSpeedButton; { +05A8 }
    NewItemBtn: TSpeedButton; { +05AC }
    DeleteItemBtn: TSpeedButton; { +05B0 }
    SortItemsName: TSpeedButton; { +05B4 }
    SortTypeBtn: TSpeedButton; { +05B8 }
    HeroPnl: TPanel; { +05BC }
    OpenHeroLibrary: TSpeedButton; { +05C0 }
    EditHeroBtn: TSpeedButton; { +05C4 }
    AddHeroBtn: TSpeedButton; { +05C8 }
    RemoveHeroBtn: TSpeedButton; { +05CC }
    SortNameBtn: TSpeedButton; { +05D0 }
    SortLevelBtn: TSpeedButton; { +05D4 }
    SpellInfoGroup: TGroupBox; { +05D8 }
    SpellInfoMemo: TMemo; { +05DC }
    Panel2: TPanel; { +05E0 }
    LoadBtn: TSpeedButton; { +05E4 }
    SaveBtn: TSpeedButton; { +05E8 }
    ValidateMapBtn: TSpeedButton; { +05EC }
    Brush1Btn: TSpeedButton; { +05F0 }
    Brush2Btn: TSpeedButton; { +05F4 }
    Brush3Btn: TSpeedButton; { +05F8 }
    LevelUpBtn: TSpeedButton; { +05FC }
    LevelDownBtn: TSpeedButton; { +0600 }
    EraseBtn: TSpeedButton; { +0604 }
    SelectBtn: TSpeedButton; { +0608 }
    OverrideBtn: TSpeedButton; { +060C }
    PreviewBtn: TSpeedButton; { +0610 }
    Bevel2: TBevel; { +0614 }
    ToolbarPnl: TPanel; { +0618 }
    ArmyBtn: TSpeedButton; { +061C }
    ItemBtn: TSpeedButton; { +0620 }
    RoadBtn: TSpeedButton; { +0624 }
    GrassBtn: TSpeedButton; { +0628 }
    WaterBtn: TSpeedButton; { +062C }
    IceBtn: TSpeedButton; { +0630 }
    SnowBtn: TSpeedButton; { +0634 }
    WastelandBtn: TSpeedButton; { +0638 }
    DesertBtn: TSpeedButton; { +063C }
    SteppeBtn: TSpeedButton; { +0640 }
    Panel10: TPanel; { +0644 }
    uArmyBtn: TSpeedButton; { +0648 }
    uItemBtn: TSpeedButton; { +064C }
    uBridgeBtn: TSpeedButton; { +0650 }
    uWaterBtn: TSpeedButton; { +0654 }
    DirtBtn: TSpeedButton; { +0658 }
    LavaBtn: TSpeedButton; { +065C }
    uIceBtn: TSpeedButton; { +0660 }
    EarthBtn: TSpeedButton; { +0664 }
    RockBtn: TSpeedButton; { +0668 }
    Panel7: TPanel; { +066C }
    SpeedButton1: TSpeedButton; { +0670 }
    BorderBtn: TSpeedButton; { +0674 }
    SpeedButton3: TSpeedButton; { +0678 }
    SpeedButton4: TSpeedButton; { +067C }
    SpeedButton5: TSpeedButton; { +0680 }
    SpeedButton6: TSpeedButton; { +0684 }
    SpeedButton7: TSpeedButton; { +0688 }
    SpeedButton8: TSpeedButton; { +068C }
    SpeedButton9: TSpeedButton; { +0690 }
    SpeedButton10: TSpeedButton; { +0694 }
    LeaderToolbar: TPanel; { +0698 }
    EditLeaderBtn: TSpeedButton; { +069C }
    public
    F_MainForm_6A0: array[0..11] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure FormCreate;  { draft }
    procedure CutItemClick;  { draft }
    procedure PasteItemClick;  { draft }
    procedure CopyItemClick;  { draft }
    procedure DeleteItemClick;  { draft }
    procedure HSMEditUpdateFrame;  { draft }
    procedure Brush1BtnClick;  { draft }
    procedure Brush2BtnClick;  { draft }
    procedure Brush3BtnClick;  { draft }
    procedure OpenBtnClick;  { draft }
    procedure SaveBtnClick;  { draft }
    procedure CloseItemClick;  { draft }
    procedure NewItemClick;  { draft }
    procedure SaveAsItemClick;  { draft }
    procedure ExitItemClick;  { draft }
    procedure FormCloseQuery(A1: Integer; A2: Integer);  { draft }
    procedure LevelDownBtnClick;  { draft }
    procedure LevelUpBtnClick;  { draft }
    procedure HSMEditDeactivate;  { draft }
    procedure HSMEditActivate;  { draft }
    procedure NewMapsetClick;  { draft }
    procedure HSSEditActivate;  { draft }
    procedure HSSEditDeactivate;  { draft }
    procedure HSMEditUpdateCaption;  { draft }
    procedure HSMEditShowMessage(A1: Integer; A2: Integer);  { draft }
    procedure HSMEditStaticSceneUpdated;  { draft }
    procedure DebugModeClick;  { draft }
    procedure About1Click;  { draft }
    procedure RaceGridLinkToResourceList(A1: Integer);  { draft }
    procedure MapSettingsClick;  { draft }
    procedure UnitGFXGridLinkToResourceList(A1: Integer);  { draft }
    procedure UnitsGridLinkToResourceList(A1: Integer);  { draft }
    procedure PreviewBtnClick;  { draft }
    procedure N640x480Click;  { draft }
    procedure N800x600Click;  { draft }
    procedure N1024x768Click;  { draft }
    procedure N1280x1024Click;  { draft }
    procedure HSMEditMouseMove;  { draft }
    procedure HeroGridLinkToResourceList(A1: Integer);  { draft }
    procedure ItemResourceGridLinkToResourceList(A1: Integer);  { draft }
    procedure FaceGridLinkToResourceList(A1: Integer);  { draft }
    procedure UnitTabControlSelectUnit(A1: Integer; A2: Integer);  { draft }
    procedure SortNameBtnClick;  { draft }
    procedure SortLevelBtnClick;  { draft }
    procedure OpenHeroLibraryClick;  { draft }
    procedure SortItemsNameClick;  { draft }
    procedure SortTypeBtnClick;  { draft }
    procedure HeroControlGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DeleteHeroBtnClick;  { draft }
    procedure RemoveFromMapClick;  { draft }
    procedure DeleteItemBtnClick;  { draft }
    procedure RemoveItemClick;  { draft }
    procedure RemoveLeaderFromMapClick;  { draft }
    procedure OpenItemLibraryClick;  { draft }
    procedure NewItemBtnClick;  { draft }
    procedure EditItemClick;  { draft }
    procedure NewHeroBtnClick;  { draft }
    procedure WaterBtnClick(A1: Integer);  { draft }
    procedure GrassBtnClick(A1: Integer);  { draft }
    procedure SteppeBtnClick(A1: Integer);  { draft }
    procedure DesertBtnClick(A1: Integer);  { draft }
    procedure WastelandBtnClick(A1: Integer);  { draft }
    procedure SnowBtnClick(A1: Integer);  { draft }
    procedure IceBtnClick(A1: Integer);  { draft }
    procedure RoadBtnClick(A1: Integer);  { draft }
    procedure EraseBtnClick;  { draft }
    procedure SelectHSBtnClick;  { draft }
    procedure HSMEditSelectPlaceHS;  { draft }
    procedure OverrideBtnClick;  { draft }
    procedure ChangeTerrainBtnClick;  { draft }
    procedure uWaterBtnClick;  { draft }
    procedure DirtBtnClick;  { draft }
    procedure LavaBtnClick;  { draft }
    procedure uIceBtnClick;  { draft }
    procedure EarthBtnClick;  { draft }
    procedure RockBtnClick;  { draft }
    procedure ArmyBtnClick(A1: Integer);  { draft }
    procedure ItemBtnClick(A1: Integer);  { draft }
    procedure EditHeroClick;  { draft }
    procedure ItemControlGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure HSMEditDeselectPlaceHS;  { draft }
    procedure OpenMapSetClick;  { draft }
    procedure ExportTextClick;  { draft }
    procedure ImportTextClick;  { draft }
    procedure MapSetSettingsClick(A1: Integer; A2: Integer);  { draft }
    procedure LeaderSelectionGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure FogofWarClick;  { draft }
    procedure PlayerInfoClick;  { draft }
    procedure RemoveMapLevelClick;  { draft }
    procedure AddMapLevelClick;  { draft }
    procedure FormShow;  { draft }
    procedure SpellListBoxClick;  { draft }
    procedure AbilityListBoxClick;  { draft }
    procedure AbilitySelectionCLBClickCheck(A1: Integer; A2: Integer);  { draft }
    procedure AbilityLevelPointsChange;  { draft }
    procedure AbilityDescriptionChange;  { draft }
    procedure EditAbilityTextClick;  { draft }
    procedure SpellDescriptionChange;  { draft }
    procedure EditSpellTextClick;  { draft }
    procedure SphereEditChange;  { draft }
    procedure SphereLevelEditChange;  { draft }
    procedure SpellManaChange;  { draft }
    procedure SpellResearchPointsChange;  { draft }
    procedure SpellUpkeepChange;  { draft }
    procedure EditAbilitySFXBtnClick;  { draft }
    procedure EditSpellSFXClick;  { draft }
    procedure GotoItemClick(A1: Integer; A2: Integer);  { draft }
    procedure ItemControlGridUnselect;  { draft }
    procedure HeroControlGridUnselect;  { draft }
    procedure GoToHeroClick(A1: Integer; A2: Integer);  { draft }
    procedure GoToLeaderClick(A1: Integer; A2: Integer);  { draft }
    procedure ValidateMapBtnClick;  { draft }
    procedure NewCombatMapClick;  { draft }
    procedure LinkToCombatResources(A1: Integer);  { draft }
    procedure UnitPositionBtnClick;  { draft }
    procedure BorderBtnClick;  { draft }
    procedure EditAnimationsClick;  { draft }
    procedure AbGFXEditClick;  { draft }
    procedure EditSpellGFXClick;  { draft }
    procedure ScannerItemClick;  { draft }
    procedure EditTextBtnClick;  { draft }
    procedure EditLeaderClick;  { draft }
    procedure HeroPopupMenuPopup;  { draft }
    procedure ItemPopupMenuPopup;  { draft }
    procedure GameSettingsClick;  { draft }
    procedure ExportAbilityInfoClick;  { draft }
    procedure HSMEditActivateDC;  { draft }
    procedure RemoveLeadersMIClick;  { draft }
    procedure MapTextEditorMIClick;  { draft }
    procedure ExportForMultilizerClick;  { draft }
    procedure HSMEditKeyDown;  { draft }
  end;


implementation

constructor TMainForm.Create(AOwner: Classes.TComponent);
begin end;

procedure TMainForm.FormCreate;
begin end;

destructor TMainForm.Destroy;
begin end;

procedure TMainForm.CutItemClick;
begin end;

procedure TMainForm.PasteItemClick;
begin end;

procedure TMainForm.CopyItemClick;
begin end;

procedure TMainForm.DeleteItemClick;
begin end;

procedure TMainForm.HSMEditUpdateFrame;
begin end;

procedure TMainForm.Brush1BtnClick;
begin end;

procedure TMainForm.Brush2BtnClick;
begin end;

procedure TMainForm.Brush3BtnClick;
begin end;

procedure TMainForm.OpenBtnClick;
begin end;

procedure TMainForm.SaveBtnClick;
begin end;

procedure TMainForm.CloseItemClick;
begin end;

procedure TMainForm.NewItemClick;
begin end;

procedure TMainForm.SaveAsItemClick;
begin end;

procedure TMainForm.ExitItemClick;
begin end;

procedure TMainForm.FormCloseQuery(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.LevelDownBtnClick;
begin end;

procedure TMainForm.LevelUpBtnClick;
begin end;

procedure TMainForm.HSMEditDeactivate;
begin end;

procedure TMainForm.HSMEditActivate;
begin end;

procedure TMainForm.NewMapsetClick;
begin end;

procedure TMainForm.HSSEditActivate;
begin end;

procedure TMainForm.HSSEditDeactivate;
begin end;

procedure TMainForm.HSMEditUpdateCaption;
begin end;

procedure TMainForm.HSMEditShowMessage(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.HSMEditStaticSceneUpdated;
begin end;

procedure TMainForm.DebugModeClick;
begin end;

procedure TMainForm.About1Click;
begin end;

procedure TMainForm.RaceGridLinkToResourceList(A1: Integer);
begin end;

procedure TMainForm.MapSettingsClick;
begin end;

procedure TMainForm.UnitGFXGridLinkToResourceList(A1: Integer);
begin end;

procedure TMainForm.UnitsGridLinkToResourceList(A1: Integer);
begin end;

procedure TMainForm.PreviewBtnClick;
begin end;

procedure TMainForm.N640x480Click;
begin end;

procedure TMainForm.N800x600Click;
begin end;

procedure TMainForm.N1024x768Click;
begin end;

procedure TMainForm.N1280x1024Click;
begin end;

procedure TMainForm.HSMEditMouseMove;
begin end;

procedure TMainForm.HeroGridLinkToResourceList(A1: Integer);
begin end;

procedure TMainForm.ItemResourceGridLinkToResourceList(A1: Integer);
begin end;

procedure TMainForm.FaceGridLinkToResourceList(A1: Integer);
begin end;

procedure TMainForm.UnitTabControlSelectUnit(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.SortNameBtnClick;
begin end;

procedure TMainForm.SortLevelBtnClick;
begin end;

procedure TMainForm.OpenHeroLibraryClick;
begin end;

procedure TMainForm.SortItemsNameClick;
begin end;

procedure TMainForm.SortTypeBtnClick;
begin end;

procedure TMainForm.HeroControlGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMainForm.DeleteHeroBtnClick;
begin end;

procedure TMainForm.RemoveFromMapClick;
begin end;

procedure TMainForm.DeleteItemBtnClick;
begin end;

procedure TMainForm.RemoveItemClick;
begin end;

procedure TMainForm.RemoveLeaderFromMapClick;
begin end;

procedure TMainForm.OpenItemLibraryClick;
begin end;

procedure TMainForm.NewItemBtnClick;
begin end;

procedure TMainForm.EditItemClick;
begin end;

procedure TMainForm.NewHeroBtnClick;
begin end;

procedure TMainForm.WaterBtnClick(A1: Integer);
begin end;

procedure TMainForm.GrassBtnClick(A1: Integer);
begin end;

procedure TMainForm.SteppeBtnClick(A1: Integer);
begin end;

procedure TMainForm.DesertBtnClick(A1: Integer);
begin end;

procedure TMainForm.WastelandBtnClick(A1: Integer);
begin end;

procedure TMainForm.SnowBtnClick(A1: Integer);
begin end;

procedure TMainForm.IceBtnClick(A1: Integer);
begin end;

procedure TMainForm.RoadBtnClick(A1: Integer);
begin end;

procedure TMainForm.EraseBtnClick;
begin end;

procedure TMainForm.SelectHSBtnClick;
begin end;

procedure TMainForm.HSMEditSelectPlaceHS;
begin end;

procedure TMainForm.OverrideBtnClick;
begin end;

procedure TMainForm.ChangeTerrainBtnClick;
begin end;

procedure TMainForm.uWaterBtnClick;
begin end;

procedure TMainForm.DirtBtnClick;
begin end;

procedure TMainForm.LavaBtnClick;
begin end;

procedure TMainForm.uIceBtnClick;
begin end;

procedure TMainForm.EarthBtnClick;
begin end;

procedure TMainForm.RockBtnClick;
begin end;

procedure TMainForm.ArmyBtnClick(A1: Integer);
begin end;

procedure TMainForm.ItemBtnClick(A1: Integer);
begin end;

procedure TMainForm.EditHeroClick;
begin end;

procedure TMainForm.ItemControlGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMainForm.HSMEditDeselectPlaceHS;
begin end;

procedure TMainForm.OpenMapSetClick;
begin end;

procedure TMainForm.ExportTextClick;
begin end;

procedure TMainForm.ImportTextClick;
begin end;

procedure TMainForm.MapSetSettingsClick(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.LeaderSelectionGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMainForm.FogofWarClick;
begin end;

procedure TMainForm.PlayerInfoClick;
begin end;

procedure TMainForm.RemoveMapLevelClick;
begin end;

procedure TMainForm.AddMapLevelClick;
begin end;

procedure TMainForm.FormShow;
begin end;

procedure TMainForm.SpellListBoxClick;
begin end;

procedure TMainForm.AbilityListBoxClick;
begin end;

procedure TMainForm.AbilitySelectionCLBClickCheck(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.AbilityLevelPointsChange;
begin end;

procedure TMainForm.AbilityDescriptionChange;
begin end;

procedure TMainForm.EditAbilityTextClick;
begin end;

procedure TMainForm.SpellDescriptionChange;
begin end;

procedure TMainForm.EditSpellTextClick;
begin end;

procedure TMainForm.SphereEditChange;
begin end;

procedure TMainForm.SphereLevelEditChange;
begin end;

procedure TMainForm.SpellManaChange;
begin end;

procedure TMainForm.SpellResearchPointsChange;
begin end;

procedure TMainForm.SpellUpkeepChange;
begin end;

procedure TMainForm.EditAbilitySFXBtnClick;
begin end;

procedure TMainForm.EditSpellSFXClick;
begin end;

procedure TMainForm.GotoItemClick(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.ItemControlGridUnselect;
begin end;

procedure TMainForm.HeroControlGridUnselect;
begin end;

procedure TMainForm.GoToHeroClick(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.GoToLeaderClick(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.ValidateMapBtnClick;
begin end;

procedure TMainForm.NewCombatMapClick;
begin end;

procedure TMainForm.LinkToCombatResources(A1: Integer);
begin end;

procedure TMainForm.UnitPositionBtnClick;
begin end;

procedure TMainForm.BorderBtnClick;
begin end;

procedure TMainForm.EditAnimationsClick;
begin end;

procedure TMainForm.AbGFXEditClick;
begin end;

procedure TMainForm.EditSpellGFXClick;
begin end;

procedure TMainForm.ScannerItemClick;
begin end;

procedure TMainForm.EditTextBtnClick;
begin end;

procedure TMainForm.EditLeaderClick;
begin end;

procedure TMainForm.HeroPopupMenuPopup;
begin end;

procedure TMainForm.ItemPopupMenuPopup;
begin end;

procedure TMainForm.GameSettingsClick;
begin end;

procedure TMainForm.ExportAbilityInfoClick;
begin end;

procedure TMainForm.HSMEditActivateDC;
begin end;

procedure TMainForm.RemoveLeadersMIClick;
begin end;

procedure TMainForm.MapTextEditorMIClick;
begin end;

procedure TMainForm.ExportForMultilizerClick;
begin end;

procedure TMainForm.HSMEditKeyDown;
begin end;


end.
