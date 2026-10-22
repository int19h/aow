unit AoWLeaderSetup;

{ The leader customization window of AoW.exe. Layouts follow the original RTTI;
  named handlers and the unnamed leader setup routines are recovered from the executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWButton, AoWComboBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll;

type
  TLeaderSetupWin = class;


  { TLeaderSetupWin: size $2F0; $2D8 setup control, $2DC phase, $2E0 fixed spheres,
    $2E4 working leader, $2E8 selected sort, $2EC available sort. VMT 00414BE0. }
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
    FSetup: TLeaderSetupControl; { $2D8 }
    FPhase: Integer; { $2DC }
    FFixedSpheres: Integer; { $2E0 }
    FLeader: TLeader; { $2E4 }
    FSelectedSort: Integer; { $2E8 }
    FAvailableSort: Integer; { $2EC }
    procedure Execute(Control: TLeaderSetupControl);
    procedure Finish;
    procedure Cancel;
    procedure LoadLeader;
    procedure SaveLeader;
    procedure UpdateSkillPoints;
    procedure UpdateStatistics;
    procedure UpdateLeader;
    procedure SortSelectedAbilities;
    procedure SortAvailableAbilities;
    procedure UpdateAbilities;
    procedure SelectAvailableAbility(Index: Integer);
    procedure SelectSelectedAbility(Index: Integer);
    function CanAddAbility(AbilityID: Integer): Boolean;
    procedure SetPhase(Value: Integer);
    procedure SetFixedSpheres(Value: Integer);
    procedure Reset;
    procedure UpdateSpheres;
    published procedure LeaderSetupWinCreate; public
    published procedure LeaderSetupWinDestroy; public
    published procedure AddAbilityClick; public
    published procedure RemoveAbilityClick; public
    published procedure DrawSelectionFace(Sender: TObject; SD: TSurfaceDesc); public
    published procedure FacePrevBtnClick; public
    published procedure FaceNextBtnClick; public
    published procedure PrevBtnClick; public
    published procedure NextBtnClick; public
    published procedure MainFaceFrPreDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure NameEditChange; public
    published procedure SelectedAbilitiesCostChange; public
    published procedure SelectedAbilitiesChange; public
    published procedure AvailableAbilitiesCostChange; public
    published procedure AvailableAbilitiesChange; public
    published procedure SelectedAbilitiesLBChange; public
    published procedure AvailableAbilitiesLBChange; public
    published procedure AttUpClick; public
    published procedure AttDnClick; public
    published procedure DefUpClick; public
    published procedure DefDnClick; public
    published procedure DamUpClick; public
    published procedure DamDnClick; public
    published procedure ResUpClick; public
    published procedure ResDnClick; public
    published procedure HitUpClick; public
    published procedure HitDnClick; public
    published procedure MovUpClick; public
    published procedure MovDnClick; public
    published procedure ClearBtnClick; public
    published procedure DefaultBtnClick; public
    published procedure SelLifeClick; public
    published procedure SelFireClick; public
    published procedure SelDeathClick; public
    published procedure SelWaterClick; public
    published procedure SelAirClick; public
    published procedure SelEarthClick; public
    published procedure DeleteSphereClick(Sender: TObject); public
    published procedure RaceCBChange; public
    published procedure SelectedAbilitiesSortClick; public
    published procedure SelectedAbilitiesCostSortClick; public
    published procedure AvailableAbilitiesSortClick; public
    published procedure AvailableAbilitiesCostSortClick; public
    published procedure SBaseClick; public
    published procedure SExtraClick; public
    published procedure SFinalClick; public
    published procedure SelectedAbilitiesCostMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure AvailableAbilitiesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
  end;


var
  LeaderSetupWin: TLeaderSetupWin;

implementation

uses AoWUnit, AoWExeForms, aowSetupEvents, AoWWinMan, E2Globals;


procedure TLeaderSetupWin.LeaderSetupWinCreate;
begin
  FLeader := TLeader.Create(nil);
end;

procedure TLeaderSetupWin.LeaderSetupWinDestroy;
begin
  FLeader.Free;
end;

procedure TLeaderSetupWin.AddAbilityClick;
var
  AbilityID: Integer;
begin
  General.PlayButtonSound(0);
  if AvailableAbilities.Selected <> -1 then
  begin
    AbilityID := Integer(AvailableAbilities.Items.Objects[AvailableAbilities.Selected]);
    if CanAddAbility(AbilityID) then
    begin
      FLeader.ExpandAbility(AbilityID);
      UpdateAbilities;
      UpdateLeader;
    end;
  end;
end;

procedure TLeaderSetupWin.RemoveAbilityClick;
var
  AbilityID: Integer;
begin
  General.PlayButtonSound(0);
  if SelectedAbilities.Selected <> -1 then
  begin
    AbilityID := Integer(SelectedAbilities.Items.Objects[SelectedAbilities.Selected]);
    if FLeader.FHeroResource.FAbilities.GetAbSet(AbilityID) and
      (FLeader.FHeroResource.FAbilities.GetAbLevel(AbilityID) = FLeader.GetAbilityLevel(AbilityID)) then Exit;
    FLeader.RemoveAbility(AbilityID);
    UpdateAbilities;
    UpdateLeader;
  end;
end;

procedure TLeaderSetupWin.DrawSelectionFace(Sender: TObject; SD: TSurfaceDesc);
var
  Setup: TLeaderSetupControl;
  Index, Offset: Integer;
  R: TRect;
  Face: TFaceResource;
begin
  Setup := FSetup;
  Offset := TComponent(Sender).Tag;
  Index := FLeader.FFaceIndex;
  while Offset < 0 do
  begin
    Inc(Offset);
    Index := AoWHSSet.FFaceResources.PrevFace(Index);
  end;
  while Offset > 0 do
  begin
    Dec(Offset);
    Index := AoWHSSet.FFaceResources.NextFace(Index);
  end;
  with TAOWImage(Sender) do
    R := Rect(Phase1Pnl.WinLeft + WinLeft + 2, Phase1Pnl.WinTop + WinTop,
      Phase1Pnl.WinLeft + WinLeft + WinWidth - 2,
      Phase1Pnl.WinTop + WinTop + WinHeight - 2);
  if Setup.FOriginalLeader.GetFace <> nil then
  begin
    Face := AoWHSSet.FFaceResources.GetFaceResource(Index);
    Face.AddRef;
    Face.GetFaceImage.ShowStretched(R, SD);
    Face.Release;
  end;
end;

procedure TLeaderSetupWin.FacePrevBtnClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetFaceIndex(AoWHSSet.FFaceResources.PrevFace(FLeader.FFaceIndex));
  TitleWindow.TitleWin.FDrawn := False;
end;

procedure TLeaderSetupWin.FaceNextBtnClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetFaceIndex(AoWHSSet.FFaceResources.NextFace(FLeader.FFaceIndex));
  TitleWindow.TitleWin.FDrawn := False;
end;

procedure TLeaderSetupWin.PrevBtnClick;
begin
  General.PlayButtonSound(0);
  case FPhase of
    1: if lsmCampaign in FSetup.FMode then Cancel;
    2: begin
         SaveLeader;
         if lsmLook in FSetup.FMode then SetPhase(1);
       end;
    3: begin
         SaveLeader;
         if lsmSettings in FSetup.FMode then SetPhase(2)
         else if lsmLook in FSetup.FMode then SetPhase(1);
       end;
  end;
end;

procedure TLeaderSetupWin.NextBtnClick;
begin
  General.PlayButtonSound(0);
  case FPhase of
    1: begin
         SaveLeader;
         if lsmSettings in FSetup.FMode then SetPhase(2)
         else if lsmSpheres in FSetup.FMode then SetPhase(3)
         else Finish;
         TitleWindow.TitleWin.FDrawn := False;
       end;
    2: begin
         SaveLeader;
         if lsmSpheres in FSetup.FMode then SetPhase(3)
         else Finish;
         TitleWindow.TitleWin.FDrawn := False;
       end;
    3: if FLeader.GetSphereCount = FLeader.FSpherePicksMax then Finish
       else
       begin
         ResetMessageDialog(MessageDlg);
         MessageDlg.MessageMemo.Items.Add('');
         MessageDlg.MessageMemo.Items.Add(TranslateRStr(PleaseAssignAllSpheresRStr));
         MessageDlg.OKPnl.Visible := True;
         MessageDlg.Dlg.Visible := True;
       end;
  end;
end;

procedure TLeaderSetupWin.MainFaceFrPreDraw(Sender: TObject; SD: TSurfaceDesc);
var
  Setup: TLeaderSetupControl;
  R: TRect;
begin
  Setup := FSetup;
  if FPhase > 1 then
  begin
    with TAoWFrame(Sender) do
      R := Rect(LMainPnl.WinLeft + WinLeft + 2, LMainPnl.WinTop + WinTop,
        LMainPnl.WinLeft + WinLeft + WinWidth - 2,
        LMainPnl.WinTop + WinTop + WinHeight - 2);
    if Setup.FOriginalLeader.GetFace <> nil then
      Setup.FOriginalLeader.GetFace.ShowStretched(R, SD);
  end;
end;

procedure TLeaderSetupWin.NameEditChange;
begin
  FLeader.FHeroName := NameEdit.Text;
end;

procedure TLeaderSetupWin.SelectedAbilitiesCostChange;
begin
  SelectSelectedAbility(SelectedAbilitiesCost.Selected);
end;

procedure TLeaderSetupWin.SelectedAbilitiesChange;
begin
  SelectSelectedAbility(SelectedAbilities.Selected);
end;

procedure TLeaderSetupWin.AvailableAbilitiesCostChange;
begin
  SelectAvailableAbility(AvailableAbilitiesCost.Selected);
end;

procedure TLeaderSetupWin.AvailableAbilitiesChange;
begin
  SelectAvailableAbility(AvailableAbilities.Selected);
end;

procedure TLeaderSetupWin.SelectedAbilitiesLBChange;
begin
  SelectedAbilities.ListOffset := SelectedAbilitiesLB.Position;
  SelectedAbilitiesCost.ListOffset := SelectedAbilitiesLB.Position;
end;

procedure TLeaderSetupWin.AvailableAbilitiesLBChange;
begin
  AvailableAbilities.ListOffset := AvailableAbilitiesLB.Position;
  AvailableAbilitiesCost.ListOffset := AvailableAbilitiesLB.Position;
end;

procedure TLeaderSetupWin.AttUpClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitAttack(FLeader.FUnitAttack + 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.AttDnClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitAttack(FLeader.FUnitAttack - 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.DefUpClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitDefense(FLeader.FUnitDefense + 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.DefDnClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitDefense(FLeader.FUnitDefense - 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.DamUpClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitDamage(FLeader.FUnitDamage + 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.DamDnClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitDamage(FLeader.FUnitDamage - 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.ResUpClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitResistance(FLeader.FUnitResistance + 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.ResDnClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitResistance(FLeader.FUnitResistance - 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.HitUpClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitHits(FLeader.FUnitHits + 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.HitDnClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitHits(FLeader.FUnitHits - 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.MovUpClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitMoves(FLeader.FUnitMoves + 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.MovDnClick;
begin
  General.PlayButtonSound(0);
  FLeader.SetUnitMoves(FLeader.FUnitMoves - 1);
  UpdateStatistics;
end;

procedure TLeaderSetupWin.ClearBtnClick;
begin
  General.PlayButtonSound(0);
  case FPhase of
    1: with FLeader do
       begin
         SetNickname('');
         FHeroName := '';
         UpdateLeader;
       end;
    2: with FLeader do
       begin
         AssignAb(FHeroResource.FAbilities);
         SetUnitAttack(0);
         SetUnitDefense(0);
         SetUnitDamage(0);
         SetUnitHits(0);
         SetUnitMoves(0);
         SetUnitResistance(0);
         UpdateLeader;
       end;
    3: begin FLeader.ClearSpheres; UpdateSpheres; end;
  end;
end;

procedure TLeaderSetupWin.DefaultBtnClick;
var
  I: Integer;
begin
  General.PlayButtonSound(0);
  TitleWindow.TitleWin.FDrawn := False;
  case FPhase of
    1: with FLeader do
       begin
         SetNickname(FSetup.FLeader.GetNickname);
         FHeroName := FSetup.FLeader.FHeroName;
         SetFaceIndex(FSetup.FLeader.FFaceIndex);
         UpdateLeader;
       end;
    2: with FLeader do
       begin
         AssignAb(FSetup.FLeader);
         SetUnitAttack(FSetup.FLeader.FUnitAttack);
         SetUnitDefense(FSetup.FLeader.FUnitDefense);
         SetUnitDamage(FSetup.FLeader.FUnitDamage);
         SetUnitHits(FSetup.FLeader.FUnitHits);
         SetUnitMoves(FSetup.FLeader.FUnitMoves);
         SetUnitResistance(FSetup.FLeader.FUnitResistance);
         UpdateLeader;
       end;
    3: with FLeader do
       begin
         ClearSpheres;
         for I := 0 to FSetup.FLeader.GetSphereCount - 1 do
           AddSphere(FSetup.FLeader.GetSpheres(I));
         UpdateLeader;
         UpdateSpheres;
       end;
  end;
end;

procedure TLeaderSetupWin.SelLifeClick;
begin
  General.PlayButtonSound(0);
  if FLeader.CanAddSphere(msLife) then
  begin
    FLeader.AddSphere(msLife);
    UpdateSpheres;
  end;
end;

procedure TLeaderSetupWin.SelFireClick;
begin
  General.PlayButtonSound(0);
  if FLeader.CanAddSphere(msFire) then
  begin
    FLeader.AddSphere(msFire);
    UpdateSpheres;
  end;
end;

procedure TLeaderSetupWin.SelDeathClick;
begin
  General.PlayButtonSound(0);
  if FLeader.CanAddSphere(msDeath) then
  begin
    FLeader.AddSphere(msDeath);
    UpdateSpheres;
  end;
end;

procedure TLeaderSetupWin.SelWaterClick;
begin
  General.PlayButtonSound(0);
  if FLeader.CanAddSphere(msWater) then
  begin
    FLeader.AddSphere(msWater);
    UpdateSpheres;
  end;
end;

procedure TLeaderSetupWin.SelAirClick;
begin
  General.PlayButtonSound(0);
  if FLeader.CanAddSphere(msAir) then
  begin
    FLeader.AddSphere(msAir);
    UpdateSpheres;
  end;
end;

procedure TLeaderSetupWin.SelEarthClick;
begin
  General.PlayButtonSound(0);
  if FLeader.CanAddSphere(msEarth) then
  begin
    FLeader.AddSphere(msEarth);
    UpdateSpheres;
  end;
end;

procedure TLeaderSetupWin.DeleteSphereClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  if TComponent(Sender).Tag < FLeader.GetSphereCount then
    FLeader.DeleteSphereIndex(TComponent(Sender).Tag);
  UpdateSpheres;
end;

procedure TLeaderSetupWin.RaceCBChange;
begin
  General.PlayButtonSound(0);
  FLeader.SetRace(Integer(RaceCB.Items.Objects[RaceCB.Selected]));
end;

procedure TLeaderSetupWin.SelectedAbilitiesSortClick;
begin
  General.PlayButtonSound(0);
  if FSelectedSort = 0 then FSelectedSort := 1
  else FSelectedSort := 0;
  SortSelectedAbilities;
end;

procedure TLeaderSetupWin.SelectedAbilitiesCostSortClick;
begin
  General.PlayButtonSound(0);
  if FSelectedSort = 2 then FSelectedSort := 3
  else FSelectedSort := 2;
  SortSelectedAbilities;
end;

procedure TLeaderSetupWin.AvailableAbilitiesSortClick;
begin
  General.PlayButtonSound(0);
  if FAvailableSort = 0 then FAvailableSort := 1
  else FAvailableSort := 0;
  SortAvailableAbilities;
end;

procedure TLeaderSetupWin.AvailableAbilitiesCostSortClick;
begin
  General.PlayButtonSound(0);
  if FAvailableSort = 2 then FAvailableSort := 3
  else FAvailableSort := 2;
  SortAvailableAbilities;
end;

procedure TLeaderSetupWin.SBaseClick;
begin
  General.PlayButtonSound(0);
end;

procedure TLeaderSetupWin.SExtraClick;
begin
  General.PlayButtonSound(0);
end;

procedure TLeaderSetupWin.SFinalClick;
begin
  General.PlayButtonSound(0);
end;

procedure TLeaderSetupWin.SelectedAbilitiesCostMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Ability: TAbility;
begin
  if (Button = mbRight) and (SelectedAbilities.Selected <> -1) then
  begin
    Ability := AoWHSSet.FAbilityControl.GetAbility(Integer(SelectedAbilities.Items.Objects[SelectedAbilities.Selected]));
    if Ability <> nil then
      SetInfoBanner(InfoBanner, Ability.GetName(nil), Ability.FDescription);
  end;
end;

procedure TLeaderSetupWin.AvailableAbilitiesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Ability: TAbility;
begin
  if (Button = mbRight) and (AvailableAbilities.Selected <> -1) then
  begin
    Ability := AoWHSSet.FAbilityControl.GetAbility(Integer(AvailableAbilities.Items.Objects[AvailableAbilities.Selected]));
    if Ability <> nil then
      SetInfoBanner(InfoBanner, Ability.GetName(nil), Ability.FDescription);
  end;
end;


procedure TLeaderSetupWin.LoadLeader;
begin
  FLeader.Assign(FSetup.FOriginalLeader, AoWEngine);
end;

procedure TLeaderSetupWin.SaveLeader;
var
  Leader: TLeader;
begin
  FSetup.FOriginalLeader.Assign(FLeader, AoWEngine);
  Leader := FSetup.FOriginalLeader;
  LeaderName.Text := Leader.FHeroName;
  UAttack.Text := IntToStr(Leader.GetInherentAttack);
  UDefense.Text := IntToStr(Leader.GetInherentDefense);
  UDamage.Text := IntToStr(Leader.GetInherentDamage);
  UResistance.Text := IntToStr(Leader.GetInherentResistance);
  UHits.Text := IntToStr(Leader.GetHits);
  UMoves.Text := IntToStr(Leader.GetMoves);
  UAbilities.Items.Clear;
  Leader.ListAbilities(UAbilities.Items);
  SideNameLbl.Text := TranslateRStr(RaceNamesPluralRStr[Leader.FRace]);
  ShieldL.CurrentImage := Leader.FRace + 13;
  ShieldR.CurrentImage := Leader.FRace + 13;
end;

procedure TLeaderSetupWin.UpdateSkillPoints;
begin
  SkillPointsLbl.Text := TranslateRStr(SkillPointsRStr) + ' ' +
    IntToStr(FLeader.GetSkillPoints) + '/' + IntToStr(FLeader.GetSkillPointsMax);
end;

procedure TLeaderSetupWin.UpdateStatistics;
var
  Res: THeroResource;
begin
  Res := FLeader.FHeroResource;
  AttB.Text := IntToStr(Res.FAttack);
  DefB.Text := IntToStr(Res.FDefense);
  DamB.Text := IntToStr(Res.FDamage);
  ResB.Text := IntToStr(Res.FResistance);
  HitB.Text := IntToStr(Res.FHits);
  MovB.Text := IntToStr(Res.FMoves);
  AttA.Text := IntToStr(FLeader.FUnitAttack);
  DefA.Text := IntToStr(FLeader.FUnitDefense);
  DamA.Text := IntToStr(FLeader.FUnitDamage);
  ResA.Text := IntToStr(FLeader.FUnitResistance);
  HitA.Text := IntToStr(FLeader.FUnitHits);
  MovA.Text := IntToStr(FLeader.FUnitMoves);
  AttValue.Text := IntToStr(FLeader.GetInherentAttack);
  DefValue.Text := IntToStr(FLeader.GetInherentDefense);
  DamValue.Text := IntToStr(FLeader.GetInherentDamage);
  ResValue.Text := IntToStr(FLeader.GetInherentResistance);
  HitValue.Text := IntToStr(FLeader.GetHits);
  MovValue.Text := IntToStr(FLeader.GetMoves);
  UpdateSkillPoints;
end;

procedure TLeaderSetupWin.UpdateLeader;
begin
  NameEdit.Text := FLeader.FHeroName;
  UpdateAbilities;
  UpdateStatistics;
end;

procedure TLeaderSetupWin.SortSelectedAbilities;
begin
  case FSelectedSort of
    0: SortStringsAscending(SelectedAbilities.Items, [SelectedAbilitiesCost.Items]);
    1: SortStringsDescending(SelectedAbilities.Items, [SelectedAbilitiesCost.Items]);
    2: SortStringsNumericalAscending(SelectedAbilitiesCost.Items, [SelectedAbilities.Items]);
    3: SortStringsNumericalDescending(SelectedAbilitiesCost.Items, [SelectedAbilities.Items]);
  end;
end;

procedure TLeaderSetupWin.SelectSelectedAbility(Index: Integer);
begin
  SelectedAbilities.Selected := Index;
  SelectedAbilitiesCost.Selected := Index;
end;

procedure TLeaderSetupWin.SortAvailableAbilities;
begin
  case FAvailableSort of
    0: SortStringsAscending(AvailableAbilities.Items, [AvailableAbilitiesCost.Items]);
    1: SortStringsDescending(AvailableAbilities.Items, [AvailableAbilitiesCost.Items]);
    2: SortStringsNumericalAscending(AvailableAbilitiesCost.Items, [AvailableAbilities.Items]);
    3: SortStringsNumericalDescending(AvailableAbilitiesCost.Items, [AvailableAbilities.Items]);
  end;
end;

procedure TLeaderSetupWin.SelectAvailableAbility(Index: Integer);
begin
  AvailableAbilities.Selected := Index;
  AvailableAbilitiesCost.Selected := Index;
end;

function TLeaderSetupWin.CanAddAbility(AbilityID: Integer): Boolean;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).CanExpand(FLeader) and
    (AoWHSSet.FAbilityControl.GetAbility(AbilityID).ExpandCost(FLeader) <= FLeader.GetSkillPoints);
end;

procedure TLeaderSetupWin.UpdateAbilities;
var
  I: Integer;
  Name, Cost: string;
  Ability: TAbility;
begin
  AvailableAbilities.Items.Clear;
  AvailableAbilitiesCost.Items.Clear;
  for I := 0 to AoWHSSet.FAbilityControl.GetCount - 1 do
    if (AoWHSSet.FAbilityControl.GetAbility(I) <> nil) and
      (AoWHSSet.FAbilityControl.GetAbility(I).FSelectionTypes * [astCustomizeLeader, astHeroUpgrade] <> []) then
      if AoWHSSet.FAbilityControl.GetAbility(I).CanExpand(FLeader) then
      begin
        AvailableAbilities.Items.AddObject(AoWHSSet.FAbilityControl.GetAbility(I).ExpandName(FLeader), TObject(I));
        AvailableAbilitiesCost.Items.Add(IntToStr(AoWHSSet.FAbilityControl.GetAbility(I).ExpandCost(FLeader)));
      end;
  SelectedAbilities.Items.Clear;
  SelectedAbilitiesCost.Items.Clear;
  for I := 0 to FLeader.GetAbCount - 1 do
  begin
    Ability := AoWHSSet.FAbilityControl.GetAbility(I);
    if FLeader.GetAbSet(I) and (FLeader.FHeroResource.FAbilities.GetAbSet(I) or
      (Ability.FSelectionTypes * [astCustomizeLeader, astHeroUpgrade] <> [])) then
    begin
      Name := AoWHSSet.FAbilityControl.GetAbility(I).GetName(FLeader);
      if FLeader.FHeroResource.FAbilities.GetAbSet(I) and
        (FLeader.FHeroResource.FAbilities.GetAbLevel(I) = FLeader.GetAbilityLevel(I)) then
      begin
        Name := Name + ' (' + TranslateRStr(FixedRStr) + ')';
        Cost := '-';
      end
      else
        Cost := IntToStr(Ability.GetSkillPoints(FLeader) - Ability.GetSkillPoints(FLeader.FHeroResource.FAbilities));
      SelectedAbilitiesCost.Items.Add(Cost);
      SelectedAbilities.Items.AddObject(Name, TObject(I));
    end;
  end;
  AvailableAbilitiesLB.Max := AvailableAbilities.Items.Count - 1;
  SelectedAbilitiesLB.Max := SelectedAbilities.Items.Count - 1;
  SortAvailableAbilities;
  SortSelectedAbilities;
end;

procedure TLeaderSetupWin.SetFixedSpheres(Value: Integer);
begin
  FFixedSpheres := Value;
  UpdateSpheres;
end;

procedure TLeaderSetupWin.Reset;
begin
  ClearBtn.Visible := True;
  DefaultBtn.Visible := True;
  PrevBtn.Visible := True;
  NextBtn.Visible := True;
  Phase1Header.Text := TranslateRStr(Step1CustomizeLeaderRStr);
  Phase2Header.Text := TranslateRStr(Step2AssignSkillPointsRStr);
  Phase3Header.Text := TranslateRStr(Step3AssignSpheresRStr);
  SetFixedSpheres(0);
end;

procedure TLeaderSetupWin.SetPhase(Value: Integer);
begin
  FPhase := Value;
  Phase1Pnl.Visible := Value = 1;
  Phase2Pnl.Visible := Value = 2;
  Phase3Pnl.Visible := Value = 3;
  Phase1Header.Visible := Value = 1;
  Phase2Header.Visible := Value = 2;
  Phase3Header.Visible := Value = 3;
  StatPnl.Visible := Value > 2;
  AbilityPnl.Visible := Value > 2;
  LeaderName.Visible := Value > 1;
  LeaderLbl.Visible := not (lsmCampaign in FSetup.FMode);
  SideNameLbl.Visible := not (lsmCampaign in FSetup.FMode);
  ShieldL.Visible := not (lsmCampaign in FSetup.FMode) or (Value > 1);
  ShieldR.Visible := not (lsmCampaign in FSetup.FMode) or (Value > 1);
  MainFaceFr.Visible := not (lsmCampaign in FSetup.FMode) or (Value > 1);
  MainFace.Visible := MainFaceFr.Visible;
  if (Value = 3) or ((Value = 2) and (FSetup.FMode * [lsmSpheres] = [])) or
    ((Value = 1) and (FSetup.FMode * [lsmSettings, lsmSpheres] = [])) then
    NextBtn.Text := TranslateRStr(FinishRStr)
  else
    NextBtn.Text := TranslateRStr(NextRStr);
  case Value of
    1: UpdateLeader;
    2: UpdateLeader;
    3: UpdateSpheres;
  end;
end;

procedure TLeaderSetupWin.UpdateSpheres;
var
  I: Integer;
  Btn: TAOWButton;
begin
  for I := 0 to 6 do
  begin
    case I of
      0: Btn := Sel1;
      1: Btn := Sel2;
      2: Btn := Sel3;
      3: Btn := Sel4;
      4: Btn := Sel5;
      5: Btn := Sel6;
      6: Btn := Sel7;
    else Btn := nil;
    end;
    if I < FLeader.GetSphereCount then
    begin
      Btn.Visible := True;
      case Integer(FLeader.GetSpheres(I)) and $7F of
        1: begin Btn.ILIndexDown := 28; Btn.ILIndexLit := 29; Btn.ILIndexUp := 27; end;
        5: begin Btn.ILIndexDown := 43; Btn.ILIndexLit := 44; Btn.ILIndexUp := 42; end;
        3: begin Btn.ILIndexDown := 34; Btn.ILIndexLit := 35; Btn.ILIndexUp := 33; end;
        4: begin Btn.ILIndexDown := 37; Btn.ILIndexLit := 38; Btn.ILIndexUp := 36; end;
        6: begin Btn.ILIndexDown := 40; Btn.ILIndexLit := 41; Btn.ILIndexUp := 39; end;
        2: begin Btn.ILIndexDown := 31; Btn.ILIndexLit := 32; Btn.ILIndexUp := 30; end;
      end;
    end
    else Btn.Visible := False;
    if I < FFixedSpheres then
    begin
      Btn.FCaptureInput := False;
      Btn.ILIndexUp := Btn.ILIndexUp + 1;
    end
    else Btn.FCaptureInput := True;
  end;
  SelectedSpheresLbl.Text := TranslateRStr(SelectedSpheresRStr) + ' (' +
    IntToStr(FLeader.GetSphereCount) + '/' + IntToStr(FLeader.FSpherePicksMax) + ')';
  if FLeader.CanAddSphere(msLife) then
  begin
    SelLife.ILIndexUp := 27;
    SelLife.FCaptureInput := True;
  end
  else
  begin
    SelLife.ILIndexUp := 28;
    SelLife.FCaptureInput := False;
  end;
  if FLeader.CanAddSphere(msDeath) then
  begin
    SelDeath.ILIndexUp := 30;
    SelDeath.FCaptureInput := True;
  end
  else
  begin
    SelDeath.ILIndexUp := 31;
    SelDeath.FCaptureInput := False;
  end;
  if FLeader.CanAddSphere(msFire) then
  begin
    SelFire.ILIndexUp := 42;
    SelFire.FCaptureInput := True;
  end
  else
  begin
    SelFire.ILIndexUp := 43;
    SelFire.FCaptureInput := False;
  end;
  if FLeader.CanAddSphere(msWater) then
  begin
    SelWater.ILIndexUp := 39;
    SelWater.FCaptureInput := True;
  end
  else
  begin
    SelWater.ILIndexUp := 40;
    SelWater.FCaptureInput := False;
  end;
  if FLeader.CanAddSphere(msEarth) then
  begin
    SelEarth.ILIndexUp := 33;
    SelEarth.FCaptureInput := True;
  end
  else
  begin
    SelEarth.ILIndexUp := 34;
    SelEarth.FCaptureInput := False;
  end;
  if FLeader.CanAddSphere(msAir) then
  begin
    SelAir.ILIndexUp := 36;
    SelAir.FCaptureInput := True;
  end
  else
  begin
    SelAir.ILIndexUp := 37;
    SelAir.FCaptureInput := False;
  end;
  SelLife.FDrawn := False;
  SelDeath.FDrawn := False;
  SelFire.FDrawn := False;
  SelWater.FDrawn := False;
  SelEarth.FDrawn := False;
  SelAir.FDrawn := False;
end;

procedure TLeaderSetupWin.Execute(Control: TLeaderSetupControl);
var
  I: Integer;
begin
  Reset;
  if FSetup <> nil then FSetup.Release;
  FSetup := Control;
  FSetup.AddRef;
  FSelectedSort := 0;
  FAvailableSort := 0;
  LeaderPnl.ILTexture := IntGfxMod.TitleScreen;
  LeaderPnl.ILIndexTexture := 4;
  RaceCB.Visible := (FSetup.FItems.Count <> 0) and (lsmCampaign in FSetup.FMode);
  RaceLbl.Visible := RaceCB.Visible;
  if RaceCB.Visible then
  begin
    RaceCB.Items.Clear;
    for I := 0 to FSetup.FItems.Count - 1 do
      RaceCB.Items.AddObject(TranslateRStr(RaceNamesRStr[FSetup.FItems[I]]), TObject(FSetup.FItems[I]));
    RaceCB.Selected := FSetup.FItems.IndexOf(FSetup.FOriginalLeader.FRace);
  end;
  SideNameLbl.Text := TranslateRStr(RaceNamesPluralRStr[FSetup.FOriginalLeader.FRace]);
  ShieldL.CurrentImage := FSetup.FOriginalLeader.FRace + 13;
  ShieldR.CurrentImage := FSetup.FOriginalLeader.FRace + 13;
  ShieldR.Visible := not (lsmCampaign in FSetup.FMode);
  LoadLeader;
  SaveLeader;
  if lsmLook in FSetup.FMode then SetPhase(1)
  else if lsmSettings in FSetup.FMode then SetPhase(2)
  else if lsmSpheres in FSetup.FMode then SetPhase(3);
  LeaderPnl.Visible := True;
end;

procedure TLeaderSetupWin.Finish;
var
  Control: TLeaderSetupControl;
begin
  SaveLeader;
  Control := FSetup;
  Control.FStatus := lssDone;
  FSetup := nil;
  LeaderPnl.Visible := False;
  SetupEvents.UpdatePlayerName(Control.FOriginalLeader.FHeroName);
  Control.Done;
  Control.Release;
end;

procedure TLeaderSetupWin.Cancel;
var
  Control: TLeaderSetupControl;
begin
  SaveLeader;
  Control := FSetup;
  Control.FStatus := lssCanceled;
  FSetup := nil;
  LeaderPnl.Visible := False;
  Control.Done;
  Control.Release;
end;

end.
