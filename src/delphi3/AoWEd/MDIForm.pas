unit MDIForm;

{ MDIForm from AoWEd.exe. TMainForm is $6AC bytes; published controls occupy
  $1DC..$69C, $6A0 message lifetime, $6A4 static timing dirty, $6A5 initial display,
  $6A8 reserved. Unrecovered methods retain draft declarations. }

{$R+,Q+}

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
    FMessageLifetime: Integer; { $6A0 }
    FStaticTimingDirty: Boolean; { $6A4 }
    FInitialDisplay: Boolean; { $6A5 }
    F_MainForm_6A6: array[0..5] of Byte;
    function LoadMap(const FileName: string): Boolean;
    procedure SetMapLevel(Level: Integer);
    procedure ClearSelectionButtons;
    procedure ResetToolButtons;
    procedure ClearMouseMessages;
    procedure EditMapSettings(AllowCancel: Boolean);
    procedure UpdateDefaultPlayers;
    procedure DefaultPlayerClick(Sender: TObject);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ApplicationException(Sender: TObject; E: Exception);
    procedure ApplicationHint(Sender: TObject; var Done: Boolean);
    procedure ApplicationShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure FormCreate(Sender: TObject);
    procedure CutItemClick(Sender: TObject);
    procedure PasteItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure DeleteItemClick(Sender: TObject);
    procedure HSMEditUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
    procedure Brush1BtnClick(Sender: TObject);
    procedure Brush2BtnClick(Sender: TObject);
    procedure Brush3BtnClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure CloseItemClick(Sender: TObject);
    procedure NewItemClick(Sender: TObject);
    procedure SaveAsItemClick(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure LevelDownBtnClick(Sender: TObject);
    procedure LevelUpBtnClick(Sender: TObject);
    procedure HSMEditDeactivate(Sender: TObject);
    procedure HSMEditActivate(Sender: TObject);
    procedure NewMapsetClick(Sender: TObject);
    procedure HSSEditActivate(Sender: TObject);
    procedure HSSEditDeactivate(Sender: TObject);
    procedure HSMEditUpdateCaption(Sender: TObject);
    procedure HSMEditShowMessage(S: string);
    procedure HSMEditStaticSceneUpdated(Sender: TObject);
    procedure DebugModeClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure RaceGridLinkToResourceList(Sender: TObject);
    procedure MapSettingsClick(Sender: TObject);
    procedure UnitGFXGridLinkToResourceList(Sender: TObject);
    procedure UnitsGridLinkToResourceList(Sender: TObject);
    procedure PreviewBtnClick(Sender: TObject);
    procedure N640x480Click(Sender: TObject);
    procedure N800x600Click(Sender: TObject);
    procedure N1024x768Click(Sender: TObject);
    procedure N1280x1024Click(Sender: TObject);
    procedure HSMEditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HeroGridLinkToResourceList(Sender: TObject);
    procedure ItemResourceGridLinkToResourceList(Sender: TObject);
    procedure FaceGridLinkToResourceList(Sender: TObject);
    procedure UnitTabControlSelectUnit(Sender: TObject; Index: Integer);
    procedure SortNameBtnClick(Sender: TObject);
    procedure SortLevelBtnClick(Sender: TObject);
    procedure OpenHeroLibraryClick(Sender: TObject);
    procedure SortItemsNameClick(Sender: TObject);
    procedure SortTypeBtnClick(Sender: TObject);
    procedure HeroControlGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DeleteHeroBtnClick(Sender: TObject);  { draft }
    procedure RemoveFromMapClick(Sender: TObject);  { draft }
    procedure DeleteItemBtnClick(Sender: TObject);
    procedure RemoveItemClick(Sender: TObject);  { draft }
    procedure RemoveLeaderFromMapClick(Sender: TObject);  { draft }
    procedure OpenItemLibraryClick(Sender: TObject);
    procedure NewItemBtnClick(Sender: TObject);
    procedure EditItemClick(Sender: TObject);
    procedure NewHeroBtnClick(Sender: TObject);
    procedure WaterBtnClick(Sender: TObject);
    procedure GrassBtnClick(Sender: TObject);
    procedure SteppeBtnClick(Sender: TObject);
    procedure DesertBtnClick(Sender: TObject);
    procedure WastelandBtnClick(Sender: TObject);
    procedure SnowBtnClick(Sender: TObject);
    procedure IceBtnClick(Sender: TObject);
    procedure RoadBtnClick(Sender: TObject);
    procedure EraseBtnClick(Sender: TObject);
    procedure SelectHSBtnClick(Sender: TObject);
    procedure HSMEditSelectPlaceHS(Sender: TObject);
    procedure OverrideBtnClick(Sender: TObject);
    procedure ChangeTerrainBtnClick(Sender: TObject);
    procedure uWaterBtnClick(Sender: TObject);
    procedure DirtBtnClick(Sender: TObject);
    procedure LavaBtnClick(Sender: TObject);
    procedure uIceBtnClick(Sender: TObject);
    procedure EarthBtnClick(Sender: TObject);
    procedure RockBtnClick(Sender: TObject);
    procedure ArmyBtnClick(Sender: TObject);
    procedure ItemBtnClick(Sender: TObject);
    procedure EditHeroClick(Sender: TObject);
    procedure ItemControlGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure HSMEditDeselectPlaceHS(Sender: TObject);
    procedure OpenMapSetClick(Sender: TObject);
    procedure ExportTextClick(Sender: TObject);
    procedure ImportTextClick(Sender: TObject);
    procedure MapSetSettingsClick(Sender: TObject);
    procedure LeaderSelectionGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure FogofWarClick(Sender: TObject);
    procedure PlayerInfoClick(Sender: TObject);
    procedure RemoveMapLevelClick(Sender: TObject);
    procedure AddMapLevelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpellListBoxClick(Sender: TObject);
    procedure AbilityListBoxClick(Sender: TObject);
    procedure AbilitySelectionCLBClickCheck(Sender: TObject);
    procedure AbilityLevelPointsChange(Sender: TObject);
    procedure AbilityDescriptionChange(Sender: TObject);
    procedure EditAbilityTextClick(Sender: TObject);
    procedure SpellDescriptionChange(Sender: TObject);
    procedure EditSpellTextClick(Sender: TObject);
    procedure SphereEditChange(Sender: TObject);
    procedure SphereLevelEditChange(Sender: TObject);
    procedure SpellManaChange(Sender: TObject);
    procedure SpellResearchPointsChange(Sender: TObject);
    procedure SpellUpkeepChange(Sender: TObject);
    procedure EditAbilitySFXBtnClick(Sender: TObject);  { draft }
    procedure EditSpellSFXClick(Sender: TObject);  { draft }
    procedure GotoItemClick(Sender: TObject);
    procedure ItemControlGridUnselect(Sender: TObject);
    procedure HeroControlGridUnselect(Sender: TObject);
    procedure GoToHeroClick(Sender: TObject);
    procedure GoToLeaderClick(Sender: TObject);
    procedure ValidateMapBtnClick(Sender: TObject);
    procedure NewCombatMapClick(Sender: TObject);
    procedure LinkToCombatResources(Sender: TObject);
    procedure UnitPositionBtnClick(Sender: TObject);
    procedure BorderBtnClick(Sender: TObject);
    procedure EditAnimationsClick(Sender: TObject);
    procedure AbGFXEditClick(Sender: TObject);
    procedure EditSpellGFXClick(Sender: TObject);
    procedure ScannerItemClick(Sender: TObject);
    procedure EditTextBtnClick(Sender: TObject);
    procedure EditLeaderClick(Sender: TObject);
    procedure HeroPopupMenuPopup(Sender: TObject);  { draft }
    procedure ItemPopupMenuPopup(Sender: TObject);  { draft }
    procedure GameSettingsClick(Sender: TObject);
    procedure ExportAbilityInfoClick(Sender: TObject);
    procedure HSMEditActivateDC(Sender: TObject);
    procedure RemoveLeadersMIClick(Sender: TObject);  { draft }
    procedure MapTextEditorMIClick(Sender: TObject);
    procedure ExportForMultilizerClick(Sender: TObject);
    procedure HSMEditKeyDown(Sender: TObject);
  end;

function GetEditorVersion: string;

var MainForm: TMainForm; { AoWEd 00415A7A }
implementation

uses FontMod, AoWReg, ScannerFlt, UnitFlt, AoWTC, UnitGrid, TextEdDlg, PasswordDialog, MapSDlg, NewMapDialog, SFXEdDlg, ILSeqEd, AboutDialog, GameSDlg, HeroLibF, ItemLibF, EItem, EHero, TextCtrlEd, PlInfFlt, EArmy, EItemHS, HSSetDlg, ValidateMapDlg;


resourcestring
  DeleteSelectedHeroesRStr = 'Do you want to delete the selected heroes?';
  RemoveSelectedHeroesRStr = 'Do you want to remove the selected heroes from the map?';
  RemoveSelectedItemsRStr = 'Do you want to remove the selected items from the map?';
  RemoveLeaderRStr = 'Do you want to remove this Leader from the map?';
  DeleteSelectedItemsRStr = 'Do you want to delete the selected items?';
  CannotRemoveSurfaceRStr = 'Cannot Remove Surface Level';
  RemoveCurrentLevelRStr = 'Are you sure you want to remove the current map level?';

function GetEditorVersion: string;
begin
  Result := AoWE.Format(TranslateRStr(VersionXRStr),
    [IntToStr(1) + '.' + IntToStr(36) + '.' + IntToStr(AoWEngine.GetBuildNumber)]);
end;

procedure TMainForm.ClearSelectionButtons;
begin
  if EraseBtn.Down then EraseBtn.Down := False;
  if SelectBtn.Down then SelectBtn.Down := False;
end;

procedure TMainForm.ResetToolButtons;
begin
  ArmyBtn.AllowAllUp := True;
  ArmyBtn.Down := False;
  ItemBtn.Down := False;
  RoadBtn.Down := False;
  WaterBtn.Down := False;
  GrassBtn.Down := False;
  SteppeBtn.Down := False;
  DesertBtn.Down := False;
  WastelandBtn.Down := False;
  SnowBtn.Down := False;
  IceBtn.Down := False;
  uArmyBtn.AllowAllUp := False;
  uArmyBtn.Down := False;
  uItemBtn.Down := False;
  uBridgeBtn.Down := False;
  uWaterBtn.Down := False;
  DirtBtn.Down := False;
  LavaBtn.Down := False;
  uIceBtn.Down := False;
  EarthBtn.Down := False;
  RockBtn.Down := False;
end;

procedure TMainForm.SetMapLevel(Level: Integer);
begin
  if Level <> HSMEdit.SceneLevel then
  begin
    HSMEdit.SetSceneLevel(Level);
    HSMEdit.SelectEditResource(nil);
    EditStatusBar.Panels[1].Text := AoWE.Format(TranslateRStr(LevelXRStr), [IntToStr(Level)]);
    if Level > 0 then MORPageControl.ActivePage := UndergroundMORSheet
    else MORPageControl.ActivePage := SurfaceSheet;
    ScannerFloater.UpdateLevel;
  end;
end;

procedure TMainForm.ClearMouseMessages;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, Handle, WM_MOUSEFIRST, WM_MOUSELAST, PM_REMOVE) do;
end;

function TMainForm.LoadMap(const FileName: string): Boolean;
var
  Cancel: Boolean;
  Dlg: TPasswordDlg;
begin
  Cancel := False;
  Result := HSMEdit.LoadHSM(FileName);
  if (AoWHSMap = nil) or (AoWHSMap.FDay <> 0) or
     (AoWHSMap.FGameType = gtCampaign) or AoWHSMap.FShowAllPlayers then Cancel := True;
  if Result and not Cancel then
    if (AoWHSMap <> nil) and (AoWHSMap.FAuthor <> '') then
    begin
      Dlg := TPasswordDlg.Create(Self);
      if Dlg.ShowModal = mrOK then
      begin
        Cancel := Encode(Dlg.PasswordEdit.Text, 0) <> AoWHSMap.FAuthor;
        if Cancel then
        begin
          ShowMessage(TranslateRStr(InvalidPasswordRStr));
          Result := False;
        end;
      end
      else Cancel := True;
      Dlg.Free;
    end;
  if Cancel then
  begin
    HSMEdit.Close;
    Result := False;
  end;
  if Result then
  begin
    HSMEdit.Activate;
    HSSEdit.Activate(False);
  end;
end;

procedure TMainForm.EditMapSettings(AllowCancel: Boolean);
var
  Dlg: TMapSettingsDlg;
begin
  if HSMEdit.Activated and (AoWHSMap <> nil) then
  begin
    HSMEdit.PauseFrameUpdateLoop;
    Dlg := TMapSettingsDlg.Create(Self);
    try
      Dlg.CancelBtn.Enabled := AllowCancel;
      Dlg.ShowModal;
    finally
      Dlg.Destroy;
    end;
    UpdateDefaultPlayers;
    HSMEdit.ResumeFrameUpdateLoop;
  end;
end;

procedure TMainForm.ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
var Key: Word;
begin
  if (Msg.Message >= WM_KEYFIRST) and (Msg.Message <= WM_KEYLAST) then
    if Msg.Message = WM_KEYDOWN then
    begin
      Key := Word(Msg.wParam);
      if (Key = VK_LEFT) or (Key = VK_RIGHT) or (Key = VK_UP) or (Key = VK_DOWN) then
        if Screen.ActiveForm = Self then
        begin
          HSMEdit.KeyDown(Key, KeyDataToShiftState(Msg.lParam));
          Handled := True;
        end;
    end;
end;

procedure TMainForm.ApplicationException(Sender: TObject; E: Exception);
begin
  if E is EAccessViolation then
  begin
    ShowMessage('Oh dear, it''s the end....');
    if not Application.Terminated then Application.Terminate;
  end
  else Application.ShowException(E);
end;

procedure TMainForm.ApplicationHint(Sender: TObject; var Done: Boolean);
begin
end;

procedure TMainForm.ApplicationShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
var
  AUnit: TAbstractUnit;
  Grid: TDrawGrid;
  Cell: TGridCoord;
  Index: Integer;
  Resource: TEResource;
begin
  Grid := TDrawGrid(HintInfo.HintControl);
  if Grid is TCustomGrid then
  begin
    Cell := Grid.MouseCoord(HintInfo.CursorPos.X, HintInfo.CursorPos.Y);
    HintInfo.CursorRect := Grid.CellRect(Cell.X, Cell.Y);
    if (HintInfo.CursorPos.X > HintInfo.CursorRect.Left) and
       (HintInfo.CursorPos.X < HintInfo.CursorRect.Right) and
       (HintInfo.CursorPos.Y > HintInfo.CursorRect.Top) and
       (HintInfo.CursorPos.Y < HintInfo.CursorRect.Bottom) then
    begin
      if HintInfo.HintControl is TUnitIndexGrid then
      begin
        Index := TUnitIndexGrid(Grid).GetUnit(Cell.X, Cell.Y);
        if (Index <> -1) and (AoWHSSet <> nil) and
           (AoWHSSet.FUnitResources.GetUnitResource(Index) <> nil) then
          HintStr := AoWHSSet.FUnitResources.GetUnitResource(Index).GetUnitName
        else CanShow := False;
      end;
      if HintInfo.HintControl is TEResourceGrid then
      begin
        Resource := TEResourceGrid(Grid).GetResourceColRow(Cell.X, Cell.Y);
        if Resource <> nil then HintStr := Resource.ResourceEditName
        else CanShow := False;
      end;
      if HintInfo.HintControl is TUnitGrid then
      begin
        AUnit := TUnitGrid(Grid).GetUnit(Cell.X, Cell.Y);
        if AUnit <> nil then HintStr := AUnit.GetName
        else CanShow := False;
      end;
    end
    else CanShow := False;
  end;
end;

procedure TMainForm.DefaultPlayerClick(Sender: TObject);
begin
  TMenuItem(Sender).Checked := True;
  AoWHSMap.FEditorPlayer := TMenuItem(Sender).Tag;
end;

procedure TMainForm.UpdateDefaultPlayers;
var I: Integer; Item: TMenuItem;
begin
  while DefaultPlayersMI.Count <> 0 do DefaultPlayersMI.Items[DefaultPlayersMI.Count - 1].Free;
  if AoWHSMap <> nil then
  begin
    for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    begin
      Item := TMenuItem.Create(DefaultPlayersMI);
      if I > 0 then
        Item.Caption := TranslateRStr(PlayerRStr) + ' ' + IntToStr(I) + ' (' +
          TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace]) + ')'
      else Item.Caption := AoWHSMap.FPlayers.GetPlayers(I).GetName;
      Item.RadioItem := True;
      Item.GroupIndex := 99;
      Item.Tag := I;
      Item.OnClick := DefaultPlayerClick;
      DefaultPlayersMI.Add(Item);
    end;
    if AoWHSMap.FEditorPlayer < DefaultPlayersMI.Count then
      DefaultPlayersMI.Items[AoWHSMap.FEditorPlayer].Checked := True
    else DefaultPlayersMI.Items[0].Checked := True;
  end;
end;

constructor TMainForm.Create(AOwner: Classes.TComponent);
begin
  SetCurrentDir(ExtractFilePath(Application.ExeName));
  inherited Create(AOwner);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  I, Language: Integer;
  Settings: TSoundSettings;
begin
  try
    DeveloperItems.Visible := False;
    DeveloperSheet.TabVisible := False;
    uDeveloperSheet.TabVisible := False;
    HSMEdit.LoadMapFileFilter := TranslateRStr(CustomMapRStr) + '|*.hsm';
    AoWEdDictionary.FFileName := AoWEngine.StartupDirectory + 'Dict\' + 'AoWEd' + '.mld';
    AoWEdDictionary.Open;
    case AoWEngine.FRegistry.GetLanguage of
      alAuto: AoWEdDictionary.SetLanguage(Language + 1); { Original uses an uninitialized language index. }
      alEnglish: AoWEdDictionary.SetLanguage(1);
      alGerman: AoWEdDictionary.SetLanguage(1);
      alFrench: AoWEdDictionary.SetLanguage(1);
      alItalian: AoWEdDictionary.SetLanguage(1);
      alSpanish: AoWEdDictionary.SetLanguage(1);
    end;
    Translator.Translate;
    AoWEngine.InitializeHSSet(AoWEngine.StartupDirectory + 'RELEASE\RELEASE.HSS', nil);
    UnitSelectionGrid.ShowHint := True;
    WindowState := wsMaximized;
    Settings.OutputMode := [omMono, om16bit];
    Settings.SampleRate := 22050;
    Settings.SampleVoices := 8;
    Settings.MusicEnabled := False;
    Settings.SFXEnabled := True;
    Settings.UseDirectSound := False;
    AoWEngine.FRegistry.AssociateAoWMap(Application.ExeName);
    Application.OnMessage := ApplicationMessage;
    HSMEdit.HSEngine := AoWEngine;
    HSSEdit.HSEngine := AoWEngine;
    Caption := TranslateRStr(AoWEdRStr);
    FInitialDisplay := True;
    Application.OnException := ApplicationException;
    with EditStatusBar do
      for I := 0 to Panels.Count - 1 do Panels[I].Text := '';
    MORPanel.Color := clAppWorkSpace;
    MainPageControl.ActivePage := TileSheet;
    MainPageControl.Visible := False;
    SurfaceMORPage.ActivePage := StructuresSheet;
    HexagonSheet.TabVisible := False;
    uHexagonSheet.TabVisible := False;
    HeroesSheet.TabVisible := False;
    UnitSelectionSheet.TabVisible := False;
    ItemSelectionSheet.TabVisible := False;
    LeaderSelectionSheet.TabVisible := False;
    Application.ShowHint := True;
    Application.HintPause := 500;
    Application.OnShowHint := ApplicationShowHint;
    Application.OnIdle := ApplicationHint; { Original installs the status handler on idle. }
    DDrawFullScr16DC.DisplayWidth := 800;
    DDrawFullScr16DC.DisplayHeight := 600;
    SetCurrentDir(ExtractFilePath(Application.ExeName) + 'scenario\custom');
  except
    Application.Terminate;
  end;
end;

destructor TMainForm.Destroy;
begin
  inherited Destroy;
end;

procedure TMainForm.CutItemClick(Sender: TObject);
var
  OldState, NewState: TKeyboardState;
begin
  if Screen.ActiveControl <> nil then
  begin
    GetKeyboardState(OldState);
    NewState := OldState;
    NewState[VK_CONTROL] := NewState[VK_CONTROL] or $80;
    SetKeyboardState(NewState);
    Screen.ActiveControl.Perform(WM_KEYDOWN, Ord('X'), 0);
    SetKeyboardState(OldState);
  end;
end;

procedure TMainForm.PasteItemClick(Sender: TObject);
var
  OldState, NewState: TKeyboardState;
begin
  if Screen.ActiveControl <> nil then
  begin
    GetKeyboardState(OldState);
    NewState := OldState;
    NewState[VK_CONTROL] := NewState[VK_CONTROL] or $80;
    SetKeyboardState(NewState);
    Screen.ActiveControl.Perform(WM_KEYDOWN, Ord('V'), 0);
    SetKeyboardState(OldState);
  end;
end;

procedure TMainForm.CopyItemClick(Sender: TObject);
var
  OldState, NewState: TKeyboardState;
begin
  if Screen.ActiveControl <> nil then
  begin
    GetKeyboardState(OldState);
    NewState := OldState;
    NewState[VK_CONTROL] := NewState[VK_CONTROL] or $80;
    SetKeyboardState(NewState);
    Screen.ActiveControl.Perform(WM_KEYDOWN, Ord('C'), 0);
    SetKeyboardState(OldState);
  end;
end;

procedure TMainForm.DeleteItemClick(Sender: TObject);
begin
  if Screen.ActiveControl <> nil then Screen.ActiveControl.Perform(WM_KEYDOWN, VK_DELETE, 0);
end;

procedure TMainForm.HSMEditUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
var
  X, Y: Integer;
  TerrainType, OverlayType: Shortint;
  S: string;
  HSSet: THSSet;
  SD: TSurfaceDesc;
  HS: THexagonSprite;
begin
  Sleep(1);
  if (AoWHSMap = nil) and (HSMEdit.HSEngine.HSMap <> nil) then
    MainPageControl.ActivePage := CombatSheet;
  with HSMEdit do
  begin
    ProcessSound;
    if (msModified in HSEngine.HSMap.Status) and not SaveBtn.Enabled then
      SaveBtn.Enabled := True;
    if not (msModified in HSEngine.HSMap.Status) and SaveBtn.Enabled then
      SaveBtn.Enabled := False;
    if FMessageLifetime > 0 then
    begin
      Dec(FMessageLifetime);
      if FMessageLifetime = 0 then EditStatusBar.Panels[4].Text := '';
    end;
    X := HSEngine.HSMap.Mouse.Xhx;
    Y := HSEngine.HSMap.Mouse.Yhx;
    if X <> -1 then
    begin
      EditStatusBar.Panels[0].Text := IntToStr(X) + ':' + IntToStr(Y);
      TerrainType := HSEngine.HSMap.MapContainer.GetField(HSEngine.HSMap.Mouse.Xhx,
        HSEngine.HSMap.Mouse.Yhx, HSEngine.HSMap.ViewL).TerrainType;
      HSSet := HSEngine.HSSet;
      if (TerrainType >= 0) and (TerrainType < HSSet.TerrainTypes.Count) then
        S := HSSet.TerrainTypes[TerrainType]
      else if TerrainType = -1 then S := TranslateRStr(TransparentRStr)
      else S := TranslateRStr(UnknownRStr);
      with THSEngine(HSSet.ActivatedEngine).HSMap do
        OverlayType := MapContainer.GetField(X, Y, ViewL).OverlayType;
      if OverlayType >= 0 then S := S + '/' + HSSet.OverlayTypes[OverlayType]
      else S := S + '/' + TranslateRStr(TransparentRStr);
      EditStatusBar.Panels[2].Text := S;
    end
    else
    begin
      EditStatusBar.Panels[0].Text := '';
      EditStatusBar.Panels[2].Text := '';
    end;
    if HSEngine.HSMap.Selection.Count = 1 then
    begin
      HS := HSEngine.HSMap.Selection.HS[0];
      S := AoWE.Format(TranslateRStr(XSelectedRStr), [HS.EditName]);
      if AoWEngine.FRegistry.GetDeveloper then
        S := S + ' (Level:' + IntToStr(HS.Level) + ')';
      EditStatusBar.Panels[3].Text := S;
    end
    else if HSMEdit.HSPlaceControl is TMapObjectResource then
      EditStatusBar.Panels[3].Text := AoWE.Format(TranslateRStr(XSelectedRStr),
        [TMapObjectResource(HSMEdit.HSPlaceControl).ResourceEditName])
    else EditStatusBar.Panels[3].Text := '';
    if DebugMode.Checked then
      if ActiveDC.GetSurface(1).Lock(SD) = 0 then
      begin
        FontModule.Age10.SetText(5, 5, 'Framerate: ' + IntToStr(CurrentFrameRate), SD);
        FontModule.Age10.SetText(5, 20, 'Static Blt time: ' + IntToStr(HSMEdit.StaticBltTime) + ' ms', SD);
        FontModule.Age10.SetText(5, 35, 'Dynamic Blt time: ' + IntToStr(HSMEdit.BltTime) + ' ms', SD);
        FontModule.Age10.SetText(5, 50, 'Dynamic Update time: ' + IntToStr(HSMEdit.DynamicUpdateTime) + ' ms', SD);
        FontModule.Age10.SetText(5, 65, 'Dynamic Draw time: ' + IntToStr(HSMEdit.DynamicDrawTime) + ' ms', SD);
        FontModule.Age10.SetText(5, 80, 'Overhead: ' + IntToStr(HSMEdit.IdleTime) + ' ms', SD);
        FontModule.Age10.SetText(5, 95, 'Ideal FPS: ' + IntToStr(HSMEdit.MaxFrameRate), SD);
        FontModule.Age10.SetText(5, 110, 'HS on screen: ' +
          IntToStr(HSEngine.HSMap.StaticVisibleHS.Count + HSEngine.HSMap.DynamicVisibleHS.Count), SD);
        if FStaticTimingDirty then
        begin
          FontModule.Age10.SetText(5, 135, 'Static Update time: ' + IntToStr(HSMEdit.StaticUpdateTime) + ' ms', SD);
          FontModule.Age10.SetText(5, 150, 'Static Draw time: ' + IntToStr(HSMEdit.StaticDrawTime) + ' ms', SD);
          FStaticTimingDirty := False;
        end;
        ActiveDC.GetSurface(1).Unlock;
      end;
  end;
end;

procedure TMainForm.Brush1BtnClick(Sender: TObject);
begin
  HSMEdit.BrushSize := 1;
end;

procedure TMainForm.Brush2BtnClick(Sender: TObject);
begin
  HSMEdit.BrushSize := 2;
end;

procedure TMainForm.Brush3BtnClick(Sender: TObject);
begin
  HSMEdit.BrushSize := 3;
end;

procedure TMainForm.OpenBtnClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  Dlg.Filter := HSMEdit.LoadMapFileFilter;
  if Dlg.Execute and HSMEdit.Close then
  begin
    UpdateWindow(Handle);
    UpdateWindow(GetDesktopWindow);
    Repaint;
    LoadMap(Dlg.FileName);
  end;
  ClearMouseMessages;
  { Original leaves the open dialog owned by the main form. }
end;

procedure TMainForm.SaveBtnClick(Sender: TObject);
begin
  if AoWHSMap <> nil then
  begin
    if AoWHSMap.FGameType = gtCustom then
      HSMEdit.SaveMapFileFilter := TranslateRStr(CustomMapRStr) + '|*.hsm'
    else HSMEdit.SaveMapFileFilter := TranslateRStr(CampaignMapRStr) + '|*.csm';
  end
  else if AoWCombatMap <> nil then
    HSMEdit.SaveMapFileFilter := TranslateRStr(CustomMapRStr) + '|*.hsm';
  HSMEdit.Save;
  HSSEdit.Save;
end;

procedure TMainForm.CloseItemClick(Sender: TObject);
begin
  if HSMEdit.Activated then HSMEdit.Close;
  if HSSEdit.Activated and HSSEdit.Edit then HSSEdit.Close;
end;

procedure TMainForm.NewItemClick(Sender: TObject);
var
  Dlg: TNewMapDlg;
begin
  if HSMEdit.Close then
    if HSSEdit.Close then
    begin
      Dlg := TNewMapDlg.Create(Self);
      if Dlg.ShowModal = mrOK then
      begin
        HSSEdit.Activate(False);
        UpdateWindow(Handle);
        FInitialDisplay := True;
        HSMEdit.HSMapFileName := 'noname.hsm';
        HSMEdit.Activate;
        HSSEditActivate(Self);
        HSMEdit.UpdateFrame;
        HSMEdit.ExecuteBltSurfaceEvent;
        EditMapSettings(False);
      end;
      Dlg.Free;
    end;
end;

procedure TMainForm.SaveAsItemClick(Sender: TObject);
begin
  if AoWHSMap <> nil then
  begin
    if AoWHSMap.FGameType = gtCustom then
      HSMEdit.SaveMapFileFilter := TranslateRStr(CustomMapRStr) + '|*.hsm'
    else HSMEdit.SaveMapFileFilter := TranslateRStr(CampaignMapRStr) + '|*.csm';
  end
  else if AoWCombatMap <> nil then
    HSMEdit.SaveMapFileFilter := TranslateRStr(CustomMapRStr) + '|*.hsm';
  HSMEdit.SaveAs;
  HSSEdit.SaveAs;
end;

procedure TMainForm.ExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := HSMEdit.Close and HSSEdit.Close;
end;

procedure TMainForm.LevelDownBtnClick(Sender: TObject);
begin
  if HSMEdit.Activated then
    if HSMEdit.SceneLevel + 1 <> AoWHSMap.MapContainer.LevelCount then
    begin
      with HSMEdit do SetSceneLevel(Integer(SceneLevel) + 1);
      if Smallint(HSMEdit.SceneLevel) = 1 then HSMEdit.SelectEditResource(nil);
      EditStatusBar.Panels[1].Text := AoWE.Format(TranslateRStr(LevelXRStr), [IntToStr(HSMEdit.SceneLevel)]);
      if HSMEdit.SceneLevel > 0 then MORPageControl.ActivePage := UndergroundMORSHeet;
      ScannerFloater.UpdateLevel;
    end;
end;

procedure TMainForm.LevelUpBtnClick(Sender: TObject);
begin
  if HSMEdit.Activated then
    if HSMEdit.SceneLevel <> 0 then
    begin
      with HSMEdit do SetSceneLevel(Integer(SceneLevel) - 1);
      if Smallint(HSMEdit.SceneLevel) = 0 then HSMEdit.SelectEditResource(nil);
      EditStatusBar.Panels[1].Text := AoWE.Format(TranslateRStr(LevelXRStr), [IntToStr(HSMEdit.SceneLevel)]);
      if Smallint(HSMEdit.SceneLevel) = 0 then MORPageControl.ActivePage := SurfaceSheet;
      ScannerFloater.UpdateLevel;
    end;
end;

procedure TMainForm.HSMEditDeactivate(Sender: TObject);
begin
  ScannerFloater.SetMap(nil);
  UnitSelectionSheet.TabVisible := False;
  HeroControlGrid.SetAoWHSMap(nil);
  HeroesSheet.TabVisible := False;
  LeaderSelectionSheet.TabVisible := False;
  LeaderSelectionGrid.SetAoWHSMap(nil);
  ItemSelectionSheet.TabVisible := False;
  ItemControlGrid.SetAoWHSMap(nil);
  OverrideBtn.Down := False;
  OverrideBtn.Enabled := False;
  CombatSheet.Visible := False;
  EditStatusBar.Panels[1].Text := '';
  EditStatusBar.Panels[0].Text := '';
  EditStatusBar.Panels[2].Text := '';
  EditStatusBar.Panels[3].Text := '';
  LevelDownBtn.Enabled := False;
  LevelUpBtn.Enabled := False;
  Brush1Btn.Enabled := False;
  Brush1Btn.Down := False;
  Brush2Btn.Enabled := False;
  Brush2Btn.Down := False;
  Brush3Btn.Enabled := False;
  Brush3Btn.Down := False;
  SaveBtn.Enabled := False;
  EraseBtn.Enabled := False;
  PreviewBtn.Enabled := False;
  SelectBtn.Enabled := False;
  ValidateMapBtn.Enabled := False;
  UnitSelectionSheet.Visible := False;
  HSSEditDeactivate(Self);
end;

procedure TMainForm.HSMEditActivate(Sender: TObject);
begin
  if AoWHSMap <> nil then
  begin
    AoWHSMap.SetFogEnabled(False);
    MainPageControl.ActivePage := TileSheet;
    MORPageControl.ActivePage := SurfaceSheet;
    LevelDownBtn.Enabled := AoWHSMap.MapContainer.LevelCount > 1;
    LevelUpBtn.Enabled := LevelDownBtn.Enabled;
    EditStatusBar.Panels[1].Text := AoWE.Format(TranslateRStr(LevelXRStr), [IntToStr(HSMEdit.SceneLevel)]);
    UnitTabControl.UpdateSelection;
    UnitSelectionSheet.TabVisible := True;
    LeaderSelectionSheet.TabVisible := True;
    LeaderSelectionGrid.SetAoWHSMap(AoWHSMap);
    HeroControlGrid.SetAoWHSMap(AoWHSMap);
    HeroesSheet.TabVisible := True;
    ItemSelectionSheet.TabVisible := True;
    ItemControlGrid.SetAoWHSMap(AoWHSMap);
    CombatSheet.TabVisible := False;
    TileSheet.TabVisible := True;
    SettingsSheet.TabVisible := False;
    HSMEdit.RoadControl := AoWHSSet.RoadControl;
    ScannerFloater.SetMap(AoWHSMap);
    if ScannerItem.Checked then ScannerFloater.ShowScanner;
    if PlayerInfo.Checked then PlayerInfoFloater.Show;
  end
  else
  begin
    SettingsSheet.TabVisible := False;
    TileSheet.TabVisible := False;
    CombatSheet.TabVisible := True;
    MainPageControl.ActivePage := CombatSheet;
    HSMEdit.RoadControl := AoWHSSet.FCombatRoads;
  end;
  UpdateDefaultPlayers;
  OverrideBtn.Down := False;
  OverrideBtn.Enabled := True;
  HSMEdit.Overwrite := False;
  SelectBtn.Enabled := True;
  SelectBtn.Down := True;
  HSMEdit.DeselectPlaceHS;
  HSMEdit.BrushSize := 2;
  Brush1Btn.Enabled := True;
  Brush2Btn.Enabled := True;
  Brush2Btn.Down := True;
  Brush3Btn.Enabled := True;
  EraseBtn.Enabled := True;
  PreviewBtn.Enabled := True;
  ValidateMapBtn.Enabled := True;
  HSMEdit.SetFocus;
end;

procedure TMainForm.NewMapsetClick(Sender: TObject);
begin
  if HSMEdit.Close then HSSEdit.NewSet($20010);
end;

procedure TMainForm.HSSEditActivate(Sender: TObject);
var I: Integer;
begin
  if FInitialDisplay then
  begin
    SaveBtn.Enabled := True;
    for I := 0 to MORPageControl.PageCount - 1 do MORPageControl.Pages[I].TabVisible := HSSEdit.Edit;
    if HSSEdit.Edit then
    begin
      SettingsSheet.TabVisible := True;
      HexagonSheet.TabVisible := True;
      uHexagonSheet.TabVisible := True;
      TileSheet.TabVisible := True;
    end;
    MORPanel.Color := clBtnFace;
    MainPageControl.ActivePage := TileSheet;
    MainPageControl.Visible := True;
    AoWHSSet.FAbilityControl.ListAbilities(AbilityListBox.Items, astAll);
    AbilityListBox.ItemIndex := 0;
    AbilityListBoxClick(Self);
    AoWHSSet.FSpellControl.ListSpells(SpellListBox.Items, msAll);
    SpellListBox.ItemIndex := 0;
    SpellListBoxClick(Self);
  end;
end;

procedure TMainForm.HSSEditDeactivate(Sender: TObject);
var I: Integer;
begin
  SaveBtn.Enabled := False;
  MORPanel.Color := clAppWorkSpace;
  MainPageControl.Visible := False;
  HexagonSheet.TabVisible := False;
  uHexagonSheet.TabVisible := False;
  for I := 0 to MORPageControl.PageCount - 1 do MORPageControl.Pages[I].TabVisible := False;
end;

procedure TMainForm.HSMEditUpdateCaption(Sender: TObject);
begin
  if HSMEdit.Activated then
    Caption := TranslateRStr(AoWEdRStr) + ' [' + HSMEdit.HSMapFileName + ']'
  else if HSSEdit.Activated and HSSEdit.Edit then
    Caption := TranslateRStr(AoWEdRStr) + ' [' + AoWEngine.HSSFileName + ']'
  else Caption := TranslateRStr(AoWEdRStr);
end;

procedure TMainForm.HSMEditShowMessage(S: string);
begin
  EditStatusBar.Panels[4].Text := S;
  FMessageLifetime := HSMEdit.CurrentFrameRate * 2 + 4;
end;

procedure TMainForm.HSMEditStaticSceneUpdated(Sender: TObject);
begin
  FStaticTimingDirty := True;
end;

procedure TMainForm.DebugModeClick(Sender: TObject);
begin
  DebugMode.Checked := not DebugMode.Checked;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  with HSMEdit do if Activated then PauseFrameUpdateLoop;
  with TAboutDlg.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
  with HSMEdit do if Activated then ResumeFrameUpdateLoop;
end;

procedure TMainForm.RaceGridLinkToResourceList(Sender: TObject);
begin
  TEResourceGrid(Sender).ResourceList := AoWHSSet.FRaceResources;
end;

procedure TMainForm.MapSettingsClick(Sender: TObject);
begin
  EditMapSettings(True);
end;

procedure TMainForm.UnitGFXGridLinkToResourceList(Sender: TObject);
begin
  TEResourceGrid(Sender).ResourceList := AoWHSSet.FUnitGFXResources;
end;

procedure TMainForm.UnitsGridLinkToResourceList(Sender: TObject);
begin
  TEResourceGrid(Sender).ResourceList := AoWHSSet.FUnitResources;
end;

procedure TMainForm.PreviewBtnClick(Sender: TObject);
begin
  HSMEdit.ShowPreview;
end;

procedure TMainForm.N640x480Click(Sender: TObject);
begin
  with DDrawFullScr16DC do
  begin
    DisplayWidth := 640;
    DisplayHeight := 480;
  end;
  N640x480.Checked := True;
end;

procedure TMainForm.N800x600Click(Sender: TObject);
begin
  with DDrawFullScr16DC do
  begin
    DisplayWidth := 800;
    DisplayHeight := 600;
  end;
  N800x600.Checked := True;
end;

procedure TMainForm.N1024x768Click(Sender: TObject);
begin
  with DDrawFullScr16DC do
  begin
    DisplayWidth := 1024;
    DisplayHeight := 768;
  end;
  N1024x768.Checked := True;
end;

procedure TMainForm.N1280x1024Click(Sender: TObject);
begin
  with DDrawFullScr16DC do
  begin
    DisplayWidth := 1280;
    DisplayHeight := 1024;
  end;
  N1280x1024.Checked := True;
end;

procedure TMainForm.HSMEditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if AoWEngine.FRegistry.GetDeveloper then
    EditStatusBar.Panels[5].Text := 'Allocated Memory: ' + IntToStr(GetHeapStatus.TotalAllocated);
end;

procedure TMainForm.HeroGridLinkToResourceList(Sender: TObject);
begin
  TEResourceGrid(Sender).ResourceList := AoWHSSet.FHeroResources;
end;

procedure TMainForm.ItemResourceGridLinkToResourceList(Sender: TObject);
begin
  TEResourceGrid(Sender).ResourceList := AoWHSSet.FItemGFXResources;
end;

procedure TMainForm.FaceGridLinkToResourceList(Sender: TObject);
begin
  TEResourceGrid(Sender).ResourceList := AoWHSSet.FFaceResources;
end;

procedure TMainForm.UnitTabControlSelectUnit(Sender: TObject; Index: Integer);
begin
  if Index <> -1 then HSMEdit.SelectEditResource(AoWHSSet.FUnitResources.GetUnitResource(Index));
end;

procedure TMainForm.SortNameBtnClick(Sender: TObject);
begin
  HeroControlGrid.SortOnName;
end;

procedure TMainForm.SortLevelBtnClick(Sender: TObject);
begin
  HeroControlGrid.SortOnLevel;
end;

procedure TMainForm.OpenHeroLibraryClick(Sender: TObject);
var Dlg: THeroLibraryEditForm;
begin
  with HSMEdit do if HSMEdit.Activated then PauseFrameUpdateLoop;
  Dlg := THeroLibraryEditForm.Create(Self);
  Dlg.ShowModal;
  Dlg.Free;
  with HSMEdit do if HSMEdit.Activated then ResumeFrameUpdateLoop;
end;

procedure TMainForm.SortItemsNameClick(Sender: TObject);
begin
  ItemControlGrid.SortOnName;
end;

procedure TMainForm.SortTypeBtnClick(Sender: TObject);
begin
  ItemControlGrid.SortOnType;
end;

procedure TMainForm.HeroControlGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  Hero: THero;
  HS: TUnitHS;
begin
  Hero := HeroControlGrid.GetHero(HeroControlGrid.ImageIndex(ACol, ARow));
  if (Hero <> nil) and (Hero.Owner = nil) then
  begin
    HS := TUnitHS.Create(nil);
    HS.SetUnitGFXResourceIndex(Hero.GetUnitGFXResourceIndex);
    HSMEdit.SelectPlaceHS(Hero, HS, 24, 0, 0);
  end
  else HSMEdit.DeselectPlaceHS;
end;


procedure TMainForm.DeleteHeroBtnClick(Sender: TObject);
var S: string;
begin
  if HSMEdit.Activated then HSMEdit.PauseFrameUpdateLoop;
  S := DeleteSelectedHeroesRStr;
  if MessageDlg(S, mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
    HeroControlGrid.DeleteHero;
  if HSMEdit.Activated then HSMEdit.ResumeFrameUpdateLoop;
end;


procedure TMainForm.RemoveFromMapClick(Sender: TObject);
var S: string;
begin
  if HSMEdit.Activated then HSMEdit.PauseFrameUpdateLoop;
  S := RemoveSelectedHeroesRStr;
  if MessageDlg(S, mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
    HeroControlGrid.RemoveFromMap;
  if HSMEdit.Activated then HSMEdit.ResumeFrameUpdateLoop;
end;


procedure TMainForm.DeleteItemBtnClick(Sender: TObject);
begin
  if HSMEdit.Activated then HSMEdit.PauseFrameUpdateLoop;
  if MessageDlg(DeleteSelectedItemsRStr, mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
  begin
    HSMEdit.DeselectPlaceHS;
    ItemControlGrid.DeleteItem;
  end;
  if HSMEdit.Activated then HSMEdit.ResumeFrameUpdateLoop;
end;

procedure TMainForm.RemoveItemClick(Sender: TObject);
var S: string;
begin
  if HSMEdit.Activated then HSMEdit.PauseFrameUpdateLoop;
  S := RemoveSelectedItemsRStr;
  if MessageDlg(S, mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
    ItemControlGrid.RemoveItemFromMap;
  if HSMEdit.Activated then HSMEdit.ResumeFrameUpdateLoop;
end;


procedure TMainForm.RemoveLeaderFromMapClick(Sender: TObject);
begin
  if (LeaderSelectionGrid.GetSelectedLeader <> nil) and (LeaderSelectionGrid.GetSelectedLeader.Owner <> nil) then
      if MessageDlg(RemoveLeaderRStr, mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
        LeaderSelectionGrid.RemoveFromMap;
end;


procedure TMainForm.OpenItemLibraryClick(Sender: TObject);
var Dlg: TItemLibraryEditForm;
begin
  with HSMEdit do if HSMEdit.Activated then PauseFrameUpdateLoop;
  Dlg := TItemLibraryEditForm.Create(Self);
  Dlg.ShowModal;
  Dlg.Free;
  with HSMEdit do if HSMEdit.Activated then ResumeFrameUpdateLoop;
end;

procedure TMainForm.NewItemBtnClick(Sender: TObject);
var Item: TItem; Dlg: TItemEditForm;
begin
  Item := TItem.Create(nil);
  Item.Activate;
  Dlg := TItemEditForm.Create(Application);
  if Dlg.EditItem(Item) then AoWHSMap.FItemControl.RegisterItem(Item)
  else Item.Free;
  Dlg.Free;
end;

procedure TMainForm.EditItemClick(Sender: TObject);
var Item: TItem; Dlg: TItemEditForm;
begin
  Item := ItemControlGrid.GetSelectedItem;
  if Item <> nil then
  begin
    Dlg := TItemEditForm.Create(Application);
    if Item.GetLibraryItem then Dlg.EditLibraryItem(Item)
    else Dlg.EditItem(Item);
    Dlg.Free;
  end;
end;

procedure TMainForm.NewHeroBtnClick(Sender: TObject);
var Hero: THero; Dlg: THeroEditForm;
begin
  Hero := THero.Create(nil);
  Hero.Activate;
  Dlg := THeroEditForm.Create(Application);
  if not Dlg.EditHero(Hero) then Hero.Free;
  Dlg.Free;
end;

procedure TMainForm.WaterBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(0)
  else HSMEdit.SelectClearTerrain(0);
end;

procedure TMainForm.GrassBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(1)
  else HSMEdit.SelectClearTerrain(1);
end;

procedure TMainForm.SteppeBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(4)
  else HSMEdit.SelectClearTerrain(4);
end;

procedure TMainForm.DesertBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(2)
  else HSMEdit.SelectClearTerrain(2);
end;

procedure TMainForm.WastelandBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(5)
  else HSMEdit.SelectClearTerrain(5);
end;

procedure TMainForm.SnowBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(3)
  else HSMEdit.SelectClearTerrain(3);
end;

procedure TMainForm.IceBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(6)
  else HSMEdit.SelectClearTerrain(6);
end;

procedure TMainForm.RoadBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  HSMEdit.SelectRoad;
  if AoWCombatMap <> nil then HSMEdit.PlaceOptions := 5;
end;

procedure TMainForm.EraseBtnClick(Sender: TObject);
begin
  if EraseBtn.Down then
  begin
    HSMEdit.SelectEraser;
    SelectBtn.Down := False;
    EraseBtn.Down := True;
  end;
end;

procedure TMainForm.SelectHSBtnClick(Sender: TObject);
begin
  HSMEdit.SelectEditResource(nil);
  ResetToolButtons;
end;

procedure TMainForm.HSMEditSelectPlaceHS(Sender: TObject);
var Control: TEObject;
begin
  Control := HSMEdit.HSPlaceControl;
  if (Control is TMapObjectResource) or (Control = nil) then ResetToolButtons;
  ClearSelectionButtons;
  if HSMEdit.HSPlaceControl = nil then SelectBtn.Down := True;
end;

procedure TMainForm.OverrideBtnClick(Sender: TObject);
begin
  HSMEdit.Overwrite := OverrideBtn.Down;
end;

procedure TMainForm.ChangeTerrainBtnClick(Sender: TObject);
begin
  HSMEdit.SetOverwrite(False);
end;

procedure TMainForm.uWaterBtnClick(Sender: TObject);
begin
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(10)
  else HSMEdit.SelectClearTerrain(10);
end;

procedure TMainForm.DirtBtnClick(Sender: TObject);
begin
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(12)
  else HSMEdit.SelectClearTerrain(12);
end;

procedure TMainForm.LavaBtnClick(Sender: TObject);
begin
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(9)
  else HSMEdit.SelectClearTerrain(9);
end;

procedure TMainForm.uIceBtnClick(Sender: TObject);
begin
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(13)
  else HSMEdit.SelectClearTerrain(13);
end;

procedure TMainForm.EarthBtnClick(Sender: TObject);
begin
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(7)
  else HSMEdit.SelectClearTerrain(7);
end;

procedure TMainForm.RockBtnClick(Sender: TObject);
begin
  if not OverrideBtn.Down then HSMEdit.SelectChangeTerrain(8)
  else HSMEdit.SelectClearTerrain(8);
end;

procedure TMainForm.ArmyBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  HSMEdit.SelectPlaceHS(ArmyPlaceControl, EditBrushes.CreateHS(0), $28, 0, 0);
  ToolbarPnl.Repaint;
end;

procedure TMainForm.ItemBtnClick(Sender: TObject);
begin
  TSpeedButton(Sender).AllowAllUp := False;
  HSMEdit.SelectPlaceHS(ItemPlaceControl, EditBrushes.CreateHS(1), $28, 0, 0);
  ToolbarPnl.Repaint;
end;

procedure TMainForm.EditHeroClick(Sender: TObject);
var Hero: THero; Dlg: THeroEditForm;
begin
  Hero := HeroControlGrid.GetSelectedHero;
  if Hero <> nil then
  begin
    Dlg := THeroEditForm.Create(Application);
    if Hero.GetLibraryHero then Dlg.EditLibraryHero(Hero)
    else Dlg.EditHero(Hero);
    Dlg.Free;
  end;
  HSMEdit.DeselectPlaceHS;
end;

procedure TMainForm.ItemControlGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  Item: TItem;
  HS: TLibraryImageHS;
begin
  Item := ItemControlGrid.GetItem(ItemControlGrid.ImageIndex(ACol, ARow));
  if (Item <> nil) and (Item.Owner = nil) then
  begin
    HS := TLibraryImageHS.Create(nil);
    if Item.FItemGFXIndex <> -1 then
      HS.SetImage(AoWHSSet.FItemGFXResources.GetItemGFX(Item.FItemGFXIndex).GetCellImage);
    HSMEdit.SelectPlaceHS(Item, HS, 56, -5, -5);
  end
  else HSMEdit.DeselectPlaceHS;
end;


procedure TMainForm.HSMEditDeselectPlaceHS(Sender: TObject);
begin
  HeroControlGrid.SelectionEnabled := False;
  ItemControlGrid.SelectionEnabled := False;
  UnitSelectionGrid.SelectionEnabled := False;
  LeaderSelectionGrid.SelectionEnabled := False;
end;

procedure TMainForm.OpenMapSetClick(Sender: TObject);
begin
  if HSMEdit.Close then HSSEdit.Load(True);
end;

procedure TMainForm.ExportTextClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  Dlg := TSaveDialog.Create(Self);
  Dlg.Filter := 'Text file (*.txt)|*.txt';
  Dlg.DefaultExt := 'txt';
  if Dlg.Execute then
    if HSMEdit.Activated then AoWEngine.WriteTextToFile(Dlg.FileName, AoWHSMap)
    else if HSSEdit.Activated then AoWEngine.WriteTextToFile(Dlg.FileName, AoWHSSet);
  Dlg.Free;
end;

procedure TMainForm.ImportTextClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  Dlg.Filter := 'Text file (*.txt)|*.txt';
  if Dlg.Execute then
    if HSMEdit.Activated then AoWEngine.ReadTextFromFile(Dlg.FileName, AoWHSMap)
    else if HSSEdit.Activated then AoWEngine.ReadTextFromFile(Dlg.FileName, AoWHSSet);
  Dlg.Free;
end;

procedure TMainForm.MapSetSettingsClick(Sender: TObject);
var Dlg: THSSetDialog;
begin
  Dlg := THSSetDialog.Create(Application);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.LeaderSelectionGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  Hero: TLeader;
  HS: TUnitHS;
begin
  Hero := LeaderSelectionGrid.GetLeader(LeaderSelectionGrid.ImageIndex(ACol, ARow) + 1);
  if (Hero <> nil) and (Hero.Owner = nil) then
  begin
    HS := TUnitHS.Create(nil);
    HS.SetUnitGFXResourceIndex(Hero.GetUnitGFXResourceIndex);
    HSMEdit.SelectPlaceHS(Hero, HS, 24, 0, 0);
  end
  else HSMEdit.DeselectPlaceHS;
end;


procedure TMainForm.FogofWarClick(Sender: TObject);
begin
  FogofWar.Checked := not FogofWar.Checked;
  if AoWHSMap <> nil then AoWHSMap.SetFogEnabled(FogofWar.Checked);
end;

procedure TMainForm.PlayerInfoClick(Sender: TObject);
begin
  if AoWHSMap <> nil then
  begin
    PlayerInfo.Checked := not PlayerInfo.Checked;
    if PlayerInfo.Checked then PlayerInfoFloater.Show
    else PlayerInfoFloater.Hide;
  end;
end;

procedure TMainForm.RemoveMapLevelClick(Sender: TObject);
var
  Level: Shortint;
begin
  if AoWHSMap <> nil then
    if HSMEdit.SceneLevel = 0 then ShowMessage(CannotRemoveSurfaceRStr)
    else if MessageDlg(RemoveCurrentLevelRStr, mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
    begin
      Level := HSMEdit.SceneLevel;
      HSMEdit.SceneLevel := 0;
      AoWHSMap.RemoveMapLevel(Level);
      LevelDownBtn.Enabled := AoWHSMap.MapContainer.LevelCount > 1;
      LevelUpBtn.Enabled := LevelDownBtn.Enabled;
      MORPageControl.ActivePage := SurfaceSheet;
      AoWHSMap.SetModified;
    end;
end;

procedure TMainForm.AddMapLevelClick(Sender: TObject);
begin
  if AoWHSMap <> nil then
    if AoWHSMap.AddMapLevel then
    begin
      HSMEdit.SceneLevel := AoWHSMap.MapContainer.LevelCount - 1;
      LevelDownBtn.Enabled := AoWHSMap.MapContainer.LevelCount > 1;
      LevelUpBtn.Enabled := LevelDownBtn.Enabled;
      if HSMEdit.SceneLevel > 0 then MORPageControl.ActivePage := UndergroundMORSheet
      else MORPageControl.ActivePage := SurfaceSheet;
      AoWHSMap.SetModified;
    end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if ParamStr(1) <> '' then
    if FileExists(ParamStr(1)) then
      if CompareText(ExtractFileExt(ParamStr(1)), '.hsm') = 0 then
      begin
        Application.ProcessMessages;
        LoadMap(ParamStr(1));
      end;
end;

procedure TMainForm.SpellListBoxClick(Sender: TObject);
var
  Change: TNotifyEvent;
  Info: TSpellCombatInfo;
  D: TDamageType;
  DamageText: string;
  ID: Integer;
begin
  { Original checks the ability list before reading the spell list. }
  if (AoWHSSet <> nil) and (AbilityListBox.ItemIndex <> -1) then
  begin
    ID := Integer(SpellListBox.Items.Objects[SpellListBox.ItemIndex]);
    with SpellDescription do
    begin
      Change := OnChange;
      OnChange := nil;
      Text := AoWHSSet.FSpellControl.GetSpell(ID).FSpellText.Text;
      SpellMana.Value := AoWHSSet.FSpellControl.GetSpell(ID).FBaseManaCost;
      SpellUpkeep.Value := AoWHSSet.FSpellControl.GetSpell(ID).FManaUpkeep;
      SpellResearchPoints.Value := AoWHSSet.FSpellControl.GetSpell(ID).FResearchCost;
      SphereEdit.ItemIndex := Ord(AoWHSSet.FSpellControl.GetSpell(ID).FMagicSphere);
      SphereLevelEdit.Value := AoWHSSet.FSpellControl.GetSpell(ID).FSpellLevel;
    end;
    SpellDescription.OnChange := Change;
    SpellInfoMemo.Lines.Clear;
    FillChar(Info, SizeOf(Info), 0);
    AoWHSSet.FSpellControl.GetSpell(ID).GetCombatInfo(nil, Info);
    SpellInfoMemo.Lines.Add('Attack: ' + IntToStr(Info.Attack));
    SpellInfoMemo.Lines.Add('Damage: ' + IntToStr(Info.Damage));
    SpellInfoMemo.Lines.Add('Repeat: ' + IntToStr(Info.RepeatCount));
    SpellInfoMemo.Lines.Add('Range: ' + IntToStr(Info.Range));
    if Info.DamageTypes <> [] then
    begin
      for D := Low(TDamageType) to High(TDamageType) do
        if D in Info.DamageTypes then
        begin
          if DamageText <> '' then DamageText := DamageText + ', ';
          DamageText := DamageText + TranslateRStr(TDamageTypeRStr[D]);
        end;
      SpellInfoMemo.Lines.Add('Damage Types: ' + DamageText);
    end;
    SpellInfoMemo.Lines.Add('Avg. Targets(FC): ' + IntToStr(Info.Radius));
  end;
end;

procedure TMainForm.AbilityListBoxClick(Sender: TObject);
var
  Change: TNotifyEvent;
  ID: Integer;
  T: TAbilitySelectionType;
begin
  if (AoWHSSet <> nil) and (AbilityListBox.ItemIndex <> -1) then
  begin
    ID := Integer(AbilityListBox.Items.Objects[AbilityListBox.ItemIndex]);
    with AbilityDescription do
    begin
      Change := OnChange;
      OnChange := nil;
      Text := AoWHSSet.FAbilityControl.GetAbility(ID).FDescription.Text;
    end;
    AbilityDescription.OnChange := Change;
    AbilityLevelPointBox.Visible := True;
    AbilityLevelPoints.Value := AoWHSSet.FAbilityControl.GetAbility(ID).FSkillPointCost;
    AbilityInfoMemo.Lines.Clear;
    AoWHSSet.FAbilityControl.GetAbility(ID).ListInfo(AbilityInfoMemo.Lines, [aimStatistics]);
    AbilitySelectionCLB.Items.Clear;
    for T := Low(TAbilitySelectionType) to High(TAbilitySelectionType) do
    begin
      AbilitySelectionCLB.Items.AddObject(TranslateRStr(TAbilitySelectionTypeRStr[T]), TObject(T));
      AbilitySelectionCLB.Checked[Ord(T)] := T in AoWHSSet.FAbilityControl.GetAbility(ID).FSelectionTypes;
    end;
  end;
end;

procedure TMainForm.AbilitySelectionCLBClickCheck(Sender: TObject);
var
  Index: Integer;
begin
  if (AoWHSSet <> nil) and (AbilityListBox.ItemIndex <> -1) then
  begin
    with AbilityListBox do Index := Integer(Items.Objects[ItemIndex]);
    with AbilitySelectionCLB do
    begin
      AoWHSSet.FAbilityControl.GetAbility(Index).FSelectionTypes :=
        AoWHSSet.FAbilityControl.GetAbility(Index).FSelectionTypes -
        [TAbilitySelectionType(Items.Objects[ItemIndex])];
      if Checked[ItemIndex] then
        AoWHSSet.FAbilityControl.GetAbility(Index).FSelectionTypes :=
          AoWHSSet.FAbilityControl.GetAbility(Index).FSelectionTypes +
          [TAbilitySelectionType(Items.Objects[ItemIndex])];
    end;
  end;
end;

procedure TMainForm.AbilityLevelPointsChange(Sender: TObject);
var
  ID: Integer;
begin
  if AoWHSSet <> nil then
    if AbilityListBox.ItemIndex <> -1 then
    begin
      with AbilityListBox do ID := Integer(Items.Objects[ItemIndex]);
      AoWHSSet.FAbilityControl.GetAbility(ID).FSkillPointCost := AbilityLevelPoints.Value;
    end;
end;

procedure TMainForm.AbilityDescriptionChange(Sender: TObject);
var
  Index: Integer;
begin
  if (AoWHSSet <> nil) and (AbilityListBox.ItemIndex <> -1) then
  begin
    with AbilityListBox do Index := Integer(Items.Objects[ItemIndex]);
    AoWHSSet.FAbilityControl.GetAbility(Index).FDescription.Text := AbilityDescription.Text;
  end;
end;

procedure TMainForm.EditAbilityTextClick(Sender: TObject);
var
  Index: Integer;
  Dlg: TTextEditDlg;
begin
  if (AoWHSSet <> nil) and (AbilityListBox.ItemIndex <> -1) then
  begin
    with AbilityListBox do Index := Integer(Items.Objects[ItemIndex]);
    Dlg := TTextEditDlg.Create(Self);
    Dlg.Memo.Text := AoWHSSet.FAbilityControl.GetAbility(Index).FDescription.Text;
    if Dlg.ShowModal = mrOK then
    begin
      AoWHSSet.FAbilityControl.GetAbility(Index).FDescription.Text := Dlg.Memo.Text;
      AbilityDescription.Text := Dlg.Memo.Text;
    end;
    Dlg.Free;
  end;
end;

procedure TMainForm.SpellDescriptionChange(Sender: TObject);
var
  Index: Integer;
begin
  if (AoWHSSet <> nil) and (SpellListBox.ItemIndex <> -1) then
  begin
    with SpellListBox do Index := Integer(Items.Objects[ItemIndex]);
    AoWHSSet.FSpellControl.GetSpell(Index).FSpellText.Text := SpellDescription.Text;
  end;
end;

procedure TMainForm.EditSpellTextClick(Sender: TObject);
var
  Index: Integer;
  Dlg: TTextEditDlg;
begin
  if (AoWHSSet <> nil) and (SpellListBox.ItemIndex <> -1) then
  begin
    with SpellListBox do Index := Integer(Items.Objects[ItemIndex]);
    Dlg := TTextEditDlg.Create(Self);
    Dlg.Memo.Text := AoWHSSet.FSpellControl.GetSpell(Index).FSpellText.Text;
    if Dlg.ShowModal = mrOK then
    begin
      AoWHSSet.FSpellControl.GetSpell(Index).FSpellText.Text := Dlg.Memo.Text;
      SpellDescription.Text := Dlg.Memo.Text;
    end;
    Dlg.Free;
  end;
end;

procedure TMainForm.SphereEditChange(Sender: TObject);
var
  ID: Integer;
begin
  if AoWHSSet <> nil then
    if SpellListBox.ItemIndex <> -1 then
    begin
      with SpellListBox do ID := Integer(Items.Objects[ItemIndex]);
      AoWHSSet.FSpellControl.GetSpell(ID).FMagicSphere := TMagicSphere(SphereEdit.ItemIndex);
    end;
end;

procedure TMainForm.SphereLevelEditChange(Sender: TObject);
var
  ID: Integer;
begin
  if AoWHSSet <> nil then
    if SpellListBox.ItemIndex <> -1 then
    begin
      with SpellListBox do ID := Integer(Items.Objects[ItemIndex]);
      AoWHSSet.FSpellControl.GetSpell(ID).FSpellLevel := SphereLevelEdit.Value;
    end;
end;

procedure TMainForm.SpellManaChange(Sender: TObject);
var
  ID: Integer;
begin
  if AoWHSSet <> nil then
    if SpellListBox.ItemIndex <> -1 then
    begin
      with SpellListBox do ID := Integer(Items.Objects[ItemIndex]);
      AoWHSSet.FSpellControl.GetSpell(ID).FBaseManaCost := SpellMana.Value;
    end;
end;

procedure TMainForm.SpellResearchPointsChange(Sender: TObject);
var
  ID: Integer;
begin
  if AoWHSSet <> nil then
    if SpellListBox.ItemIndex <> -1 then
    begin
      with SpellListBox do ID := Integer(Items.Objects[ItemIndex]);
      AoWHSSet.FSpellControl.GetSpell(ID).FResearchCost := SpellResearchPoints.Value;
    end;
end;

procedure TMainForm.SpellUpkeepChange(Sender: TObject);
var
  ID: Integer;
begin
  if AoWHSSet <> nil then
    if SpellListBox.ItemIndex <> -1 then
    begin
      with SpellListBox do ID := Integer(Items.Objects[ItemIndex]);
      AoWHSSet.FSpellControl.GetSpell(ID).FManaUpkeep := SpellUpkeep.Value;
    end;
end;

procedure TMainForm.EditAbilitySFXBtnClick(Sender: TObject);
var Dlg: TSFXLibraryEditDlg; ID: Integer;
begin
  if (AoWHSSet <> nil) and (AbilityListBox.ItemIndex <> -1) then
  begin
    Dlg := TSFXLibraryEditDlg.Create(Self);
    ID := Integer(AbilityListBox.Items.Objects[AbilityListBox.ItemIndex]);
    Dlg.Edit(AoWEngine, AoWHSSet.FAbilityControl.GetAbility(ID).FSFXLibrary, AoWHSSet.SFXManager);
    Dlg.Free;
  end;
end;


procedure TMainForm.EditSpellSFXClick(Sender: TObject);
var Dlg: TSFXLibraryEditDlg; ID: Integer;
begin
  if (AoWHSSet <> nil) and (SpellListBox.ItemIndex <> -1) then
  begin
    Dlg := TSFXLibraryEditDlg.Create(Self);
    ID := Integer(SpellListBox.Items.Objects[SpellListBox.ItemIndex]);
    Dlg.Edit(AoWEngine, AoWHSSet.FSpellControl.GetSpell(ID).FCastSounds, AoWHSSet.SFXManager);
    Dlg.Free;
  end;
end;


procedure TMainForm.GotoItemClick(Sender: TObject);
var
  X, Y, L: Shortint;
begin
  with ItemControlGrid do
    if (GetSelectedItem <> nil) and (GetSelectedItem.Owner <> nil) then
    begin
      GetSelectedItem.GetLocation(X, Y, L);
      if X <> -1 then
      begin
        SetMapLevel(L);
        HSMEdit.CenterView(X, Y, L);
        FMap.PlayCenterAnimation(X, Y, L);
      end;
    end;
end;

procedure TMainForm.ItemControlGridUnselect(Sender: TObject);
begin
  HSMEdit.DeselectPlaceHS;
end;

procedure TMainForm.HeroControlGridUnselect(Sender: TObject);
begin
  HSMEdit.DeselectPlaceHS;
end;

procedure TMainForm.GoToHeroClick(Sender: TObject);
var
  X, Y, L: Shortint;
begin
  with HeroControlGrid do
    if (GetSelectedHero <> nil) and (GetSelectedHero.Owner <> nil) then
    begin
      GetSelectedHero.GetLocation(X, Y, L);
      if X <> -1 then
      begin
        SetMapLevel(L);
        HSMEdit.CenterView(X, Y, L);
        FMap.PlayCenterAnimation(X, Y, L);
      end;
    end;
end;

procedure TMainForm.GoToLeaderClick(Sender: TObject);
var
  X, Y, L: Shortint;
begin
  with LeaderSelectionGrid do
    if (GetSelectedLeader <> nil) and (GetSelectedLeader.Owner <> nil) then
    begin
      GetSelectedLeader.GetLocation(X, Y, L);
      if X <> -1 then
      begin
        SetMapLevel(L);
        HSMEdit.CenterView(X, Y, L);
        FMap.PlayCenterAnimation(X, Y, L);
      end;
    end;
end;

procedure TMainForm.ValidateMapBtnClick(Sender: TObject);
var Dlg: TMapValidationDlg;
begin
  if AoWHSMap <> nil then
  begin
    Dlg := TMapValidationDlg.Create(Self);
    AoWHSMap.ValidateMap(Dlg.Memo.Lines);
    Dlg.ShowModal;
    Dlg.Free;
  end;
end;

procedure TMainForm.NewCombatMapClick(Sender: TObject);
var
  Map: THSMap;
begin
  if HSMEdit.Close and HSSEdit.Close then
  begin
    FInitialDisplay := False;
    AoWEngine.InitializeHSSet(AoWEngine.StartupDirectory + 'RELEASE\RELEASE.HSS', nil);
    Map := AoWEngine.NewHSM($220100);
    Map.CreateNewMap(TAoWNewCombatMapSettings.Create);
    HSSEdit.Activate(False);
    FInitialDisplay := True;
    HSMEdit.HSMapFileName := 'noname.hsm';
    HSMEdit.Activate;
    HSSEditActivate(Self);
  end;
end;

procedure TMainForm.LinkToCombatResources(Sender: TObject);
begin
  TEResourceGrid(Sender).ResourceList := AoWEngine.FGameSet.FCombatResources;
end;

procedure TMainForm.UnitPositionBtnClick(Sender: TObject);
begin
  HSMEdit.SelectPlaceHS(AoWCombatMap.FUnitPositions, EditBrushes.CreateHS(1), $28, 0, 0);
end;

procedure TMainForm.BorderBtnClick(Sender: TObject);
begin
  HSMEdit.SelectForceTerrain(15);
end;

procedure TMainForm.EditAnimationsClick(Sender: TObject);
var Editor: TImageSequenceEditor;
begin
  Editor := TImageSequenceEditor.Create(Self);
  Editor.SetImageSequenceList(AoWHSSet.FImageSequences);
  Editor.ShowModal;
  Editor.Free;
end;

procedure TMainForm.AbGFXEditClick(Sender: TObject);
var
  ID: Integer;
  Editor: TImageSequenceEditor;
begin
  if AoWHSSet <> nil then
    if AbilityListBox.ItemIndex <> -1 then
    begin
      with AbilityListBox do ID := Integer(Items.Objects[ItemIndex]);
      Editor := TImageSequenceEditor.Create(Self);
      Editor.SetImageSequenceList(AoWHSSet.FAbilityControl.GetAbility(ID).FImageSequences);
      Editor.ShowModal;
      Editor.Free;
    end;
end;

procedure TMainForm.EditSpellGFXClick(Sender: TObject);
var
  ID: Integer;
  Editor: TImageSequenceEditor;
begin
  if AoWHSSet <> nil then
    if SpellListBox.ItemIndex <> -1 then
    begin
      with SpellListBox do ID := Integer(Items.Objects[ItemIndex]);
      Editor := TImageSequenceEditor.Create(Self);
      Editor.SetImageSequenceList(AoWHSSet.FSpellControl.GetSpell(ID).FCastImages);
      Editor.ShowModal;
      Editor.Free;
    end;
end;

procedure TMainForm.ScannerItemClick(Sender: TObject);
begin
  if AoWHSMap <> nil then
  begin
    ScannerItem.Checked := not ScannerItem.Checked;
    if ScannerItem.Checked then ScannerFloater.ShowScanner
    else ScannerFloater.Hide;
    ScannerItem.Checked := ScannerFloater.Visible;
  end;
end;

procedure TMainForm.EditTextBtnClick(Sender: TObject);
var Dlg: TTextControlEditForm;
begin
  Dlg := TTextControlEditForm.Create(Self);
  Dlg.EditTextControl(AoWHSSet.FTextControl);
  Dlg.Free;
end;

procedure TMainForm.EditLeaderClick(Sender: TObject);
var Hero: THero; Dlg: THeroEditForm;
begin
  Hero := LeaderSelectionGrid.GetSelectedLeader;
  if (Hero <> nil) and LeaderSelectionGrid.SelectionEnabled then
  begin
    Dlg := THeroEditForm.Create(Application);
    Dlg.EditHero(Hero);
    Dlg.Free;
  end;
  HSMEdit.DeselectPlaceHS;
end;

procedure TMainForm.HeroPopupMenuPopup(Sender: TObject);
begin
  with HeroControlGrid.Selection do
    if (Left = Right) and (Top = Bottom) then
  begin
    N13.Visible := True;
    N8.Visible := True;
    EditHero.Visible := True;
    GoToHero.Visible := True;
  end
  else
  begin
    N13.Visible := False;
    N8.Visible := False;
    EditHero.Visible := False;
    GoToHero.Visible := False;
  end;
end;


procedure TMainForm.ItemPopupMenuPopup(Sender: TObject);
begin
  with ItemControlGrid.Selection do
    if (Left = Right) and (Top = Bottom) then
  begin
    MenuItem2.Visible := True;
    MenuItem4.Visible := True;
    EditItemItem.Visible := True;
    GotoItem.Visible := True;
  end
  else
  begin
    MenuItem2.Visible := False;
    MenuItem4.Visible := False;
    EditItemItem.Visible := False;
    GotoItem.Visible := False;
  end;
end;


procedure TMainForm.GameSettingsClick(Sender: TObject);
begin
  if AoWHSMap <> nil then
  begin
    with HSMEdit do if Activated then PauseFrameUpdateLoop;
    with TGameSettingsDlg.Create(Self) do
    begin
      ShowModal;
      Free;
    end;
    with HSMEdit do if Activated then ResumeFrameUpdateLoop;
  end;
end;

procedure TMainForm.ExportAbilityInfoClick(Sender: TObject);
var
  Dlg: TSaveDialog;
  List: TStringList;
begin
  Dlg := TSaveDialog.Create(Self);
  Dlg.Filter := 'Text files|*.txt';
  if Dlg.Execute then
  begin
    List := TStringList.Create;
    AoWHSSet.FAbilityControl.ListAbilityInfo(List, True, [aimDescription, aimStatistics]);
    if Pos('.', Dlg.FileName) = 0 then List.SaveToFile(Dlg.FileName + '.txt')
    else List.SaveToFile(Dlg.FileName);
    List.Free;
  end;
  Dlg.Free;
end;

procedure TMainForm.HSMEditActivateDC(Sender: TObject);
begin
  if HSMEdit.Activated then HSMEdit.RebuildScene;
  SetWindowPos(ScannerFloater.Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  SetWindowPos(PlayerInfoFloater.Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TMainForm.RemoveLeadersMIClick(Sender: TObject);
var I: Integer;
begin
  if AoWHSMap <> nil then
    for I := AoWHSMap.FHeroControl.GetCount - 1 downto 0 do
      if AoWHSMap.FHeroControl.GetHero(I) is TLeader then
        with AoWHSMap.FHeroControl.GetHero(I) do
        begin
          SetOwner(nil);
          Deactivate;
          Release;
        end;
end;


procedure TMainForm.MapTextEditorMIClick(Sender: TObject);
var
  Dlg: TTextControlEditForm;
begin
  if AoWHSMap <> nil then
  begin
    with HSMEdit do if HSMEdit.Activated then PauseFrameUpdateLoop;
    Dlg := TTextControlEditForm.Create(Self);
    Dlg.EditTextControl(AoWHSMap.FTextControl);
    Dlg.Free;
    AoWHSMap.SetModified;
    with HSMEdit do if HSMEdit.Activated then ResumeFrameUpdateLoop;
  end;
end;

procedure TMainForm.ExportForMultilizerClick(Sender: TObject);
var
  FileName: string;
begin
  if HSMEdit.Activated then
  begin
    FileName := AoWHSMap.FileName;
    if Pos('.', FileName) <> 0 then FileName := Copy(FileName, 1, Pos('.', FileName) - 1);
    FileName := FileName + '.txt';
    AoWEngine.ExportTextToFile(FileName, AoWHSMap);
    ShowMessage('text successfully exported to: ' + FileName);
  end
  else
  begin
    FileName := AoWEngine.StartupDirectory + 'Release\' + 'release.txt';
    AoWEngine.ExportTextToFile(FileName, AoWHSSet);
    ShowMessage('text successfully exported to: ' + FileName);
  end;
end;

procedure TMainForm.HSMEditKeyDown(Sender: TObject);
var
  I, J, Count: Integer;
begin
  if AoWHSMap <> nil then
    for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
    begin
      Count := 0;
      for J := AoWHSMap.FHeroControl.GetCount - 1 downto 0 do
        if AoWHSMap.FHeroControl.GetHero(J) is TLeader then
          if AoWHSMap.FHeroControl.GetHero(J).FPlayer = I then
          begin
            Inc(Count);
            if Count > 1 then ShowMessage('Double leaders defined (Player:' + IntToStr(I) + ')');
          end;
    end;
end;


end.
