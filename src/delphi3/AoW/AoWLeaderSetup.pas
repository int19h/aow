unit AoWLeaderSetup;

{ Draft declarations of AoWLeaderSetup, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWComboBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll;

type
  TLeaderSetupWin = class;


  { TLeaderSetupWin (instance size 752, VMT 00414BE0) }
  TLeaderSetupWin = class(TDataModule)
  public
    published
    SelectedAbilities: TAOWListBox; { +0044 }
    Phase2Pnl: TAOWPanel; { +0048 }
    LMainPnl: TAOWPanel; { +004C }
    NextBtn: TAOWButton; { +0050 }
    DefaultBtn: TAOWButton; { +0054 }
    ClearBtn: TAOWButton; { +0058 }
    PrevBtn: TAOWButton; { +005C }
    EditStatisticsPnl: TAOWPanel; { +0060 }
    AvailableAbilities: TAOWListBox; { +0064 }
    AttValue: TAOWLabel; { +0068 }
    AttLbl: TAOWLabel; { +006C }
    AttPnl: TAOWPanel; { +0070 }
    DamValue: TAOWLabel; { +0074 }
    DamLbl: TAOWLabel; { +0078 }
    DamPnl: TAOWPanel; { +007C }
    DefValue: TAOWLabel; { +0080 }
    DefLbl: TAOWLabel; { +0084 }
    DefPnl: TAOWPanel; { +0088 }
    ResValue: TAOWLabel; { +008C }
    ResLbl: TAOWLabel; { +0090 }
    ResPnl: TAOWPanel; { +0094 }
    HitValue: TAOWLabel; { +0098 }
    HitLbl: TAOWLabel; { +009C }
    HitPnl: TAOWPanel; { +00A0 }
    MovValue: TAOWLabel; { +00A4 }
    MovLbl: TAOWLabel; { +00A8 }
    MovPnl: TAOWPanel; { +00AC }
    AttI: TAOWLabel; { +00B0 }
    DamI: TAOWLabel; { +00B4 }
    DefI: TAOWLabel; { +00B8 }
    ResI: TAOWLabel; { +00BC }
    HitI: TAOWLabel; { +00C0 }
    MovI: TAOWLabel; { +00C4 }
    AttA: TAOWLabel; { +00C8 }
    DamA: TAOWLabel; { +00CC }
    DefA: TAOWLabel; { +00D0 }
    ResA: TAOWLabel; { +00D4 }
    HitA: TAOWLabel; { +00D8 }
    MovA: TAOWLabel; { +00DC }
    AttP: TAOWLabel; { +00E0 }
    DamP: TAOWLabel; { +00E4 }
    DefP: TAOWLabel; { +00E8 }
    ResP: TAOWLabel; { +00EC }
    HitP: TAOWLabel; { +00F0 }
    MovP: TAOWLabel; { +00F4 }
    AttB: TAOWLabel; { +00F8 }
    DamB: TAOWLabel; { +00FC }
    DefB: TAOWLabel; { +0100 }
    ResB: TAOWLabel; { +0104 }
    HitB: TAOWLabel; { +0108 }
    MovB: TAOWLabel; { +010C }
    SkillPointsLbl: TAOWLabel; { +0110 }
    UAttIcn: TAOWImage; { +0114 }
    UDefIcn: TAOWImage; { +0118 }
    UMovIcn: TAOWImage; { +011C }
    UDamIcn: TAOWImage; { +0120 }
    UResIcn: TAOWImage; { +0124 }
    UHitIcn: TAOWImage; { +0128 }
    UAttack: TAOWLabel; { +012C }
    UDefense: TAOWLabel; { +0130 }
    UMoves: TAOWLabel; { +0134 }
    UDamage: TAOWLabel; { +0138 }
    UResistance: TAOWLabel; { +013C }
    UHits: TAOWLabel; { +0140 }
    StatPnl: TAOWPanel; { +0144 }
    UAbilities: TAOWListBox; { +0148 }
    AbilityPnl: TAOWPanel; { +014C }
    UStatP1: TAOWPanel; { +0150 }
    UStatP2: TAOWPanel; { +0154 }
    LeaderName: TAOWLabel; { +0158 }
    ShieldL: TAOWImage; { +015C }
    ShieldR: TAOWImage; { +0160 }
    ButtonPnl: TAOWPanel; { +0164 }
    LeftPnl: TAOWPanel; { +0168 }
    RightPnl: TAOWPanel; { +016C }
    LeaderStatsLbl: TAOWLabel; { +0170 }
    LeaderAbilLbl: TAOWLabel; { +0174 }
    FullAbilLbl: TAOWLabel; { +0178 }
    RemoveAbility: TAOWButton; { +017C }
    AddAbility: TAOWButton; { +0180 }
    MainFace: TAOWImage; { +0184 }
    Phase1Pnl: TAOWPanel; { +0188 }
    Face4: TAOWImage; { +018C }
    Face5: TAOWImage; { +0190 }
    Face6: TAOWImage; { +0194 }
    Face7: TAOWImage; { +0198 }
    Face3: TAOWImage; { +019C }
    Face2: TAOWImage; { +01A0 }
    Face1: TAOWImage; { +01A4 }
    NameEdit: TAOWEdit; { +01A8 }
    NameLbl: TAOWLabel; { +01AC }
    FaceLbl: TAOWLabel; { +01B0 }
    RaceLbl: TAOWLabel; { +01B4 }
    Phase1Header: TAOWLabel; { +01B8 }
    UAbilSB: TAOWVScrollBar; { +01BC }
    AvailableAbilitiesLB: TAOWVScrollBar; { +01C0 }
    SelectedAbilitiesLB: TAOWVScrollBar; { +01C4 }
    Phase3Pnl: TAOWPanel; { +01C8 }
    SpheresLbl: TAOWLabel; { +01CC }
    SelDeath: TAOWButton; { +01D0 }
    SpherePnl: TAOWPanel; { +01D4 }
    SelLife: TAOWButton; { +01D8 }
    SelFire: TAOWButton; { +01DC }
    SelEarth: TAOWButton; { +01E0 }
    SelAir: TAOWButton; { +01E4 }
    SelWater: TAOWButton; { +01E8 }
    LifeLbl: TAOWLabel; { +01EC }
    Sel4: TAOWButton; { +01F0 }
    SphereSelectionPnl: TAOWPanel; { +01F4 }
    Sel3: TAOWButton; { +01F8 }
    Sel2: TAOWButton; { +01FC }
    Sel1: TAOWButton; { +0200 }
    Sel5: TAOWButton; { +0204 }
    Sel6: TAOWButton; { +0208 }
    Sel7: TAOWButton; { +020C }
    DeathLbl: TAOWLabel; { +0210 }
    EarthLbl: TAOWLabel; { +0214 }
    WaterLbl: TAOWLabel; { +0218 }
    FireLbl: TAOWLabel; { +021C }
    AirLbl: TAOWLabel; { +0220 }
    SelectedSpheresLbl: TAOWLabel; { +0224 }
    FaceNextBtn: TAOWButton; { +0228 }
    FacePrevBtn: TAOWButton; { +022C }
    LeaderLbl: TAOWLabel; { +0230 }
    SideNameLbl: TAOWLabel; { +0234 }
    SelectedAbilitiesCost: TAOWListBox; { +0238 }
    AvailableAbilitiesCost: TAOWListBox; { +023C }
    AttUp: TAOWButton; { +0240 }
    AttDn: TAOWButton; { +0244 }
    DamUp: TAOWButton; { +0248 }
    DamDn: TAOWButton; { +024C }
    DefUp: TAOWButton; { +0250 }
    DefDn: TAOWButton; { +0254 }
    ResUp: TAOWButton; { +0258 }
    ResDn: TAOWButton; { +025C }
    HitUp: TAOWButton; { +0260 }
    HitDn: TAOWButton; { +0264 }
    MovUp: TAOWButton; { +0268 }
    MovDn: TAOWButton; { +026C }
    AttIc: TAOWImage; { +0270 }
    DamIcn: TAOWImage; { +0274 }
    DefIc: TAOWImage; { +0278 }
    ResIc: TAOWImage; { +027C }
    HitIc: TAOWImage; { +0280 }
    MovIc: TAOWImage; { +0284 }
    SBase: TAOWButton; { +0288 }
    SExtra: TAOWButton; { +028C }
    SFinal: TAOWButton; { +0290 }
    SelectedAbilitiesSort: TAOWButton; { +0294 }
    SelectedAbilitiesCostSort: TAOWButton; { +0298 }
    AvailableAbilitiesSort: TAOWButton; { +029C }
    AvailableAbilitiesCostSort: TAOWButton; { +02A0 }
    MainFaceFr: TAoWFrame; { +02A4 }
    FFr1: TAoWFrame; { +02A8 }
    FFr7: TAoWFrame; { +02AC }
    FFr2: TAoWFrame; { +02B0 }
    FFr6: TAoWFrame; { +02B4 }
    FFr3: TAoWFrame; { +02B8 }
    FFr5: TAoWFrame; { +02BC }
    FFr4: TAoWFrame; { +02C0 }
    Phase2Header: TAOWLabel; { +02C4 }
    Phase3Header: TAOWLabel; { +02C8 }
    LeaderPnl: TAOWPanel; { +02CC }
    RaceCB: TAOWComboBox; { +02D0 }
    Translator: TIvTranslator; { +02D4 }
    public
    F_LeaderSetupWin_2D8: Integer;
    F_LeaderSetupWin_2DC: Integer;
    F_LeaderSetupWin_2E0: array[0..3] of Byte;
    F_LeaderSetupWin_2E4: Integer;
    F_LeaderSetupWin_2E8: Integer;
    F_LeaderSetupWin_2EC: Integer;
    procedure LeaderSetupWinCreate;  { draft }
    procedure LeaderSetupWinDestroy;  { draft }
    procedure AddAbilityClick;  { draft }
    procedure RemoveAbilityClick;  { draft }
    procedure DrawSelectionFace(A1: Integer; A2: Integer);  { draft }
    procedure FacePrevBtnClick;  { draft }
    procedure FaceNextBtnClick;  { draft }
    procedure PrevBtnClick;  { draft }
    procedure NextBtnClick;  { draft }
    procedure MainFaceFrPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure NameEditChange;  { draft }
    procedure SelectedAbilitiesCostChange;  { draft }
    procedure SelectedAbilitiesChange;  { draft }
    procedure AvailableAbilitiesCostChange;  { draft }
    procedure AvailableAbilitiesChange;  { draft }
    procedure SelectedAbilitiesLBChange;  { draft }
    procedure AvailableAbilitiesLBChange;  { draft }
    procedure AttUpClick;  { draft }
    procedure AttDnClick;  { draft }
    procedure DefUpClick;  { draft }
    procedure DefDnClick;  { draft }
    procedure DamUpClick;  { draft }
    procedure DamDnClick;  { draft }
    procedure ResUpClick;  { draft }
    procedure ResDnClick;  { draft }
    procedure HitUpClick;  { draft }
    procedure HitDnClick;  { draft }
    procedure MovUpClick;  { draft }
    procedure MovDnClick;  { draft }
    procedure ClearBtnClick;  { draft }
    procedure DefaultBtnClick;  { draft }
    procedure SelLifeClick;  { draft }
    procedure SelFireClick;  { draft }
    procedure SelDeathClick;  { draft }
    procedure SelWaterClick;  { draft }
    procedure SelAirClick;  { draft }
    procedure SelEarthClick;  { draft }
    procedure DeleteSphereClick(A1: Integer);  { draft }
    procedure RaceCBChange;  { draft }
    procedure SelectedAbilitiesSortClick;  { draft }
    procedure SelectedAbilitiesCostSortClick;  { draft }
    procedure AvailableAbilitiesSortClick;  { draft }
    procedure AvailableAbilitiesCostSortClick;  { draft }
    procedure SBaseClick;  { draft }
    procedure SExtraClick;  { draft }
    procedure SFinalClick;  { draft }
    procedure SelectedAbilitiesCostMouseDown(A1: Integer; A2: Byte);  { draft }
    procedure AvailableAbilitiesMouseDown(A1: Integer; A2: Byte);  { draft }
  end;


implementation

procedure TLeaderSetupWin.LeaderSetupWinCreate;
begin end;

procedure TLeaderSetupWin.LeaderSetupWinDestroy;
begin end;

procedure TLeaderSetupWin.AddAbilityClick;
begin end;

procedure TLeaderSetupWin.RemoveAbilityClick;
begin end;

procedure TLeaderSetupWin.DrawSelectionFace(A1: Integer; A2: Integer);
begin end;

procedure TLeaderSetupWin.FacePrevBtnClick;
begin end;

procedure TLeaderSetupWin.FaceNextBtnClick;
begin end;

procedure TLeaderSetupWin.PrevBtnClick;
begin end;

procedure TLeaderSetupWin.NextBtnClick;
begin end;

procedure TLeaderSetupWin.MainFaceFrPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TLeaderSetupWin.NameEditChange;
begin end;

procedure TLeaderSetupWin.SelectedAbilitiesCostChange;
begin end;

procedure TLeaderSetupWin.SelectedAbilitiesChange;
begin end;

procedure TLeaderSetupWin.AvailableAbilitiesCostChange;
begin end;

procedure TLeaderSetupWin.AvailableAbilitiesChange;
begin end;

procedure TLeaderSetupWin.SelectedAbilitiesLBChange;
begin end;

procedure TLeaderSetupWin.AvailableAbilitiesLBChange;
begin end;

procedure TLeaderSetupWin.AttUpClick;
begin end;

procedure TLeaderSetupWin.AttDnClick;
begin end;

procedure TLeaderSetupWin.DefUpClick;
begin end;

procedure TLeaderSetupWin.DefDnClick;
begin end;

procedure TLeaderSetupWin.DamUpClick;
begin end;

procedure TLeaderSetupWin.DamDnClick;
begin end;

procedure TLeaderSetupWin.ResUpClick;
begin end;

procedure TLeaderSetupWin.ResDnClick;
begin end;

procedure TLeaderSetupWin.HitUpClick;
begin end;

procedure TLeaderSetupWin.HitDnClick;
begin end;

procedure TLeaderSetupWin.MovUpClick;
begin end;

procedure TLeaderSetupWin.MovDnClick;
begin end;

procedure TLeaderSetupWin.ClearBtnClick;
begin end;

procedure TLeaderSetupWin.DefaultBtnClick;
begin end;

procedure TLeaderSetupWin.SelLifeClick;
begin end;

procedure TLeaderSetupWin.SelFireClick;
begin end;

procedure TLeaderSetupWin.SelDeathClick;
begin end;

procedure TLeaderSetupWin.SelWaterClick;
begin end;

procedure TLeaderSetupWin.SelAirClick;
begin end;

procedure TLeaderSetupWin.SelEarthClick;
begin end;

procedure TLeaderSetupWin.DeleteSphereClick(A1: Integer);
begin end;

procedure TLeaderSetupWin.RaceCBChange;
begin end;

procedure TLeaderSetupWin.SelectedAbilitiesSortClick;
begin end;

procedure TLeaderSetupWin.SelectedAbilitiesCostSortClick;
begin end;

procedure TLeaderSetupWin.AvailableAbilitiesSortClick;
begin end;

procedure TLeaderSetupWin.AvailableAbilitiesCostSortClick;
begin end;

procedure TLeaderSetupWin.SBaseClick;
begin end;

procedure TLeaderSetupWin.SExtraClick;
begin end;

procedure TLeaderSetupWin.SFinalClick;
begin end;

procedure TLeaderSetupWin.SelectedAbilitiesCostMouseDown(A1: Integer; A2: Byte);
begin end;

procedure TLeaderSetupWin.AvailableAbilitiesMouseDown(A1: Integer; A2: Byte);
begin end;


end.
