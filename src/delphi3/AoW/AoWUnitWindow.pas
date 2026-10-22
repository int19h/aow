unit AoWUnitWindow;

{ Draft declarations of AoWUnitWindow, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC, AoWComp, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TUnitWindow = class;


  { TUnitWindow (instance size $248, VMT 0040710C).
    $21C highlight; $220 dragged item type; $224 highlight step; $228 blink state;
    $22C blink delay; $230 cursor image; $234/$238 ground offset/count; $23C show info. }
  TUnitWindow = class(TDataModule)
  public
    published
    UnitWin: TAOWWindow; { +0044 }
    UnitFrameLeft: TAOWImage; { +0048 }
    UnitTab: TAOWTabPanel; { +004C }
    Close: TAOWButton; { +0050 }
    Title: TAOWLabel; { +0054 }
    Help: TAOWButton; { +0058 }
    TitleIcon: TAOWImage; { +005C }
    BCloseBtn: TAOWButton; { +0060 }
    CeltLineR: TAOWImage; { +0064 }
    T2Memo: TAOWMemo; { +0068 }
    ManaIcon: TAOWImage; { +006C }
    Mana: TAOWLabel; { +0070 }
    T1AbilityLB: TAOWListBox; { +0074 }
    T1UseBut: TAOWButton; { +0078 }
    T1SortName: TAOWButton; { +007C }
    T1SortType: TAOWButton; { +0080 }
    T1SortSource: TAOWButton; { +0084 }
    T1UseMsg: TAOWLabel; { +0088 }
    T1Panel: TAOWPanel; { +008C }
    T2Panel: TAOWPanel; { +0090 }
    T1TypeLB: TAOWListBox; { +0094 }
    T1SrcLB: TAOWListBox; { +0098 }
    T1ListPnl: TAOWPanel; { +009C }
    T1SBar: TAOWVScrollBar; { +00A0 }
    T2SBar: TAOWVScrollBar; { +00A4 }
    T2Text: TAOWPanel; { +00A8 }
    T2Leader: TAOWPanel; { +00AC }
    Sel4: TAOWButton; { +00B0 }
    SelPnl: TAOWPanel; { +00B4 }
    Sel3: TAOWButton; { +00B8 }
    Sel2: TAOWButton; { +00BC }
    Sel1: TAOWButton; { +00C0 }
    Sel5: TAOWButton; { +00C4 }
    Sel6: TAOWButton; { +00C8 }
    Sel7: TAOWButton; { +00CC }
    AAlignment: TAOWImage; { +00D0 }
    AAlignmentLbl: TAOWLabel; { +00D4 }
    T2Alignnl: TAOWPanel; { +00D8 }
    AlFr: TAoWFrame; { +00DC }
    TypeIcn: TAOWImage; { +00E0 }
    TypeV: TAOWLabel; { +00E4 }
    T2TypePnl: TAOWPanel; { +00E8 }
    TypeFr: TAoWFrame; { +00EC }
    LdrFr: TAoWFrame; { +00F0 }
    SphereLbl: TAOWLabel; { +00F4 }
    T3Panel: TAOWPanel; { +00F8 }
    BP1: TAOWCheckBox; { +00FC }
    BPLbl1: TAOWLabel; { +0100 }
    BP2: TAOWCheckBox; { +0104 }
    BP3: TAOWCheckBox; { +0108 }
    BP4: TAOWCheckBox; { +010C }
    BP5: TAOWCheckBox; { +0110 }
    BP6: TAOWCheckBox; { +0114 }
    BP7: TAOWCheckBox; { +0118 }
    BP8: TAOWCheckBox; { +011C }
    BPLbl2: TAOWLabel; { +0120 }
    BodyLbl: TAOWLabel; { +0124 }
    Head: TAOWCheckBox; { +0128 }
    Torso: TAOWCheckBox; { +012C }
    Attack: TAOWCheckBox; { +0130 }
    Defend: TAOWCheckBox; { +0134 }
    RingL: TAOWCheckBox; { +0138 }
    RingR: TAOWCheckBox; { +013C }
    Gnd3: TAOWCheckBox; { +0140 }
    Gnd2: TAOWCheckBox; { +0144 }
    Gnd1: TAOWCheckBox; { +0148 }
    Gnd4: TAOWCheckBox; { +014C }
    Gnd5: TAOWCheckBox; { +0150 }
    GndLbl: TAOWLabel; { +0154 }
    SlotBack: TAOWImage; { +0158 }
    DisbandBtn: TAOWButton; { +015C }
    ItemUsePnl: TAOWPanel; { +0160 }
    ItemUseBtn: TAOWButton; { +0164 }
    ItemPic: TAOWImage; { +0168 }
    UnitMainPnl: TAOWPanel; { +016C }
    UnitName: TAOWLabel; { +0170 }
    UnitFrRight: TAOWImage; { +0174 }
    UAttackIcon: TAOWImage; { +0178 }
    UDefenseIcon: TAOWImage; { +017C }
    UMovesIcon: TAOWImage; { +0180 }
    UDamageIcon: TAOWImage; { +0184 }
    UResistanceIcon: TAOWImage; { +0188 }
    UHitsIcon: TAOWImage; { +018C }
    UAttack: TAOWLabel; { +0190 }
    UDefense: TAOWLabel; { +0194 }
    UMoves: TAOWLabel; { +0198 }
    UDamage: TAOWLabel; { +019C }
    UResistance: TAOWLabel; { +01A0 }
    UHits: TAOWLabel; { +01A4 }
    UStatPnl: TAOWPanel; { +01A8 }
    UStatP1: TAOWPanel; { +01AC }
    UStatP2: TAOWPanel; { +01B0 }
    UnitFr: TAOWPanel; { +01B4 }
    Level: TAOWLabel; { +01B8 }
    UnitLine1: TAOWImage; { +01BC }
    UnitLine2: TAOWImage; { +01C0 }
    FrLSh: TAOWImage; { +01C4 }
    FrRSh: TAOWImage; { +01C8 }
    RightFramePnl: TAOWPanel; { +01CC }
    MoraleLbl: TAOWLabel; { +01D0 }
    UpkeepIcon: TAOWImage; { +01D4 }
    UpKeep: TAOWLabel; { +01D8 }
    BCeltL: TAoWFrame; { +01DC }
    CeltLineL: TAOWImage; { +01E0 }
    GroundL: TAOWButton; { +01E4 }
    GroundR: TAOWButton; { +01E8 }
    RelationIcn: TAOWImage; { +01EC }
    RelationV: TAOWLabel; { +01F0 }
    T2RelPnl: TAOWPanel; { +01F4 }
    RelFr: TAoWFrame; { +01F8 }
    RelRing: TAOWImage; { +01FC }
    RelationLbl: TAOWLabel; { +0200 }
    AlignLbl: TAOWLabel; { +0204 }
    TypeLbl: TAOWLabel; { +0208 }
    XP: TAOWLabel; { +020C }
    PNext: TAOWButton; { +0210 }
    PPrev: TAOWButton; { +0214 }
    Translator: TIvTranslator; { +0218 }
    public
    FHighlight: Integer; { $21C }
    FItemType: TItemType; { $220 }
    F_UnitWindow_221: array[0..2] of Byte;
    FHighlightStep: Integer; { $224 }
    FItemVisible: Boolean; { $228 }
    F_UnitWindow_229: array[0..2] of Byte;
    FBlinkDelay: Integer; { $22C }
    FCursorImage: TLibraryImage; { $230 }
    FGroundOffset: Integer; { $234 }
    FGroundCount: Integer; { $238 }
    FShowInfo: TP2UnitShowInfo; { $23C }
    procedure ShowUnit; { draft; 00407DB8 }
    procedure UpdateGround(Offset: Integer);
    procedure PreDrawAbilityItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
    procedure HelpClick(Sender: TObject);
    procedure T1AbilityLBChange(Sender: TObject);
    procedure T1SbarChange(Sender: TObject);
    procedure ItemRHMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure UnitWinResize(Sender: TObject);
    procedure UnitWindowCreate(Sender: TObject);
    procedure UnitWinUpdate(Sender: TObject);
    procedure T1SortNameClick(Sender: TObject; Button: Integer);
    procedure T1SortTypeClick(Sender: TObject; Button: Integer);
    procedure T1SortSourceClick(Sender: TObject; Button: Integer);
    procedure UseAbility;
    procedure UseItemClick(Sender: TObject);
    procedure UnitTabChange(Sender: TObject);
    procedure UnitWinMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure UnitWinEnter(Sender: TObject);
    procedure UnitWinExit(Sender: TObject);
    procedure UnitWinShow(Sender: TObject);
    procedure GroundRClick(Sender: TObject);
    procedure GroundLClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure Gnd1Draw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure FrLShPreDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure FrRShPreDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure Gnd1Change(Sender: TObject);
    procedure Gnd3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HeadDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure TorsoDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure AttackDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure DefendDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure RingLDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure DisbandBtnClick;  { draft }
    procedure T1AbilityLBMouseDown(Sender: TObject; Button: TMouseButton);
    procedure UnitWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PPrevClick;
    procedure PNextClick;
  end;


var
  UnitWindow: TUnitWindow;

implementation

uses E2Globals, AoWExeForms, AoWWinMan, E3Globals, AoWInfoBanner;



var
  SelectedItem: TAOWCheckBox;

resourcestring
  AbilitiesRStr = 'Abilities';
  InfoRStr = 'Info';
  NoneRStr = 'None';
  CreatureRStr = 'Creature';
  MachineRStr = 'Machine';
  UnitRStr = 'Unit';
  LeaderRStr = 'Leader';
  HeroRStr = 'Hero';
  NoLeaderRStr = 'Hero has no Leader';
  LeaderSpheresRStr = 'Leaders magic spheres';
  ItemsRStr = 'Items';
  LevelRStr = 'Level';
  ExpRStr = 'Exp';
const ShowAbilitiesRStr: PResStringRec = @AbilitiesRStr; ShowExpRStr: PResStringRec = @ExpRStr;
function CompareUnitAbilities(const S1, S2: string; O1, O2: TObject): Integer;
var
  A1, A2: TAbility;
  V1, V2: Integer;
begin
  A1 := AoWHSSet.FAbilityControl.GetAbility(Integer(O1));
  A2 := AoWHSSet.FAbilityControl.GetAbility(Integer(O2));
  if A1.GetEnabled(General.FSelectedUnit) and
    (acAction in A1.GetControlType(General.FSelectedUnit)) then V1 := 10 else V1 := 0;
  if A2.GetEnabled(General.FSelectedUnit) and
    (acAction in A2.GetControlType(General.FSelectedUnit)) then V2 := 10 else V2 := 0;
  Result := V2 - V1;
  if Result = 0 then Result := CompareStr(S1, S2);
end;

procedure TUnitWindow.ShowUnit; { Near miss: Register allocation and jump-table offsets differ after three variants. }
var
  H: THero;
  U: TAbstractUnit;
begin
  if General.FSelectedUnit <> nil then
  begin
    General.BuildAbilities;
    U := General.FSelectedUnit;
    if (U <> nil) and (AoWHSMap.FSeatedPlayer = U.FPlayer) then
      AoWHSMap.FTutorialControl.ShowMessage(64, True, True);
    if U is THero then H := THero(U) else H := nil;
    if (AoWCombatMap = nil) and (General.FUnitList <> nil) and
      (General.IndexOfUnit(U) > -1) and (General.FSelectedUnits[1] > -1) then
    begin
      UnitWindow.PPrev.Visible := True; UnitWindow.PNext.Visible := True;
    end
    else
    begin
      UnitWindow.PPrev.Visible := False; UnitWindow.PNext.Visible := False;
    end;
    UnitWindow.Mana.Visible := False; UnitWindow.ManaIcon.Visible := False;
    UnitWindow.UnitTab.Items.Clear;
    UnitWindow.UnitTab.Items.Add(TranslateRStr(LoadResString(ShowAbilitiesRStr)));
    UnitWindow.UnitTab.Items.Add(TranslateRStr(AoWE.InfoRStr));
    if U.GetRace > -1 then
    begin
      UnitWindow.TypeV.Text := TranslateRStr(RaceNamesRStr[U.GetRace]);
      UnitWindow.RelationIcn.Visible := True;
      UnitWindow.RelationIcn.CurrentImage := Ord(AoWHSMap.FRaces.GetRace(U.GetRace).GetPlayerRelation(AoWHSMap.FSeatedPlayer)) + 11;
      UnitWindow.RelationV.Text := TranslateRStr(TStatusRStr[AoWHSMap.FRaces.GetRace(U.GetRace).GetPlayerRelation(AoWHSMap.FSeatedPlayer)]);
    end
    else
    begin
      UnitWindow.TypeV.Text := '';
      UnitWindow.RelationIcn.Visible := False;
      UnitWindow.RelationV.Text := TranslateRStr(AoWE.NoneRStr);
    end;
    if (AoWHSMap.FSeatedPlayer = U.FPlayer) and not (U is TLeader) and (AoWHSMap.FCombatMap = nil) then
    begin
      UnitWindow.DisbandBtn.Visible := True; UnitWindow.BCloseBtn.Alignment.AlignWidth := awLeft;
    end
    else
    begin
      UnitWindow.DisbandBtn.Visible := False; UnitWindow.BCloseBtn.Alignment.AlignWidth := awCenter;
    end;
    UnitWindow.BCloseBtn.FAligned := False;
    case U.GetUnitType of
      utCreature:
        begin
          UnitWindow.TypeV.Text := UnitWindow.TypeV.Text + ' ' + TranslateRStr(AoWE.CreatureRStr);
          UnitWindow.TypeIcn.CurrentImage := 21;
        end;
      utMachine:
        begin
          UnitWindow.TypeV.Text := UnitWindow.TypeV.Text + ' ' + TranslateRStr(AoWE.MachineRStr);
          UnitWindow.TypeIcn.CurrentImage := 22;
        end;
    else
      if H = nil then UnitWindow.TypeV.Text := UnitWindow.TypeV.Text + ' ' + TranslateRStr(AoWE.UnitRStr)
      else if H is TLeader then UnitWindow.TypeV.Text := UnitWindow.TypeV.Text + ' ' + TranslateRStr(AoWE.LeaderRStr)
      else UnitWindow.TypeV.Text := UnitWindow.TypeV.Text + ' ' + TranslateRStr(AoWE.HeroRStr);
      UnitWindow.TypeIcn.CurrentImage := 23;
    end;
    if H = nil then
    begin
      UnitWindow.Level.Text := TranslateRStr(AoWE.LevelRStr) + ' ' + IntToStr(U.GetUnitLevel);
      UnitWindow.T2Leader.Visible := False; UnitWindow.T2Text.Visible := True;
      UnitWindow.T2Memo.Items.Assign(U.GetDescription); UnitWindow.T2SBar.Position := 0;
      UnitWindow.UnitName.Text := U.GetName;
    end
    else
    begin
      if H.FPlayer = 0 then
      begin
        UnitWindow.SelPnl.Visible := False;
        UnitWindow.SphereLbl.Text := TranslateRStr(NoLeaderRStr);
      end
      else
      begin
        UnitWindow.SelPnl.Visible := True;
        if AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSphereCount < 1 then UnitWindow.Sel1.Visible := False
        else
        begin
          UnitWindow.Sel1.Visible := True;
          UnitWindow.Sel1.ILIndexUp := General.SphereToImage(AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSpheres(0));
        end;
        if AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSphereCount < 2 then UnitWindow.Sel2.Visible := False
        else
        begin
          UnitWindow.Sel2.Visible := True;
          UnitWindow.Sel2.ILIndexUp := General.SphereToImage(AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSpheres(1));
        end;
        if AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSphereCount < 3 then UnitWindow.Sel3.Visible := False
        else
        begin
          UnitWindow.Sel3.Visible := True;
          UnitWindow.Sel3.ILIndexUp := General.SphereToImage(AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSpheres(2));
        end;
        if AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSphereCount < 4 then UnitWindow.Sel4.Visible := False
        else
        begin
          UnitWindow.Sel4.Visible := True;
          UnitWindow.Sel4.ILIndexUp := General.SphereToImage(AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSpheres(3));
        end;
        if AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSphereCount < 5 then UnitWindow.Sel5.Visible := False
        else
        begin
          UnitWindow.Sel5.Visible := True;
          UnitWindow.Sel5.ILIndexUp := General.SphereToImage(AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSpheres(4));
        end;
        if AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSphereCount < 6 then UnitWindow.Sel6.Visible := False
        else
        begin
          UnitWindow.Sel6.Visible := True;
          UnitWindow.Sel6.ILIndexUp := General.SphereToImage(AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSpheres(5));
        end;
        if AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSphereCount < 7 then UnitWindow.Sel7.Visible := False
        else
        begin
          UnitWindow.Sel7.Visible := True;
          UnitWindow.Sel7.ILIndexUp := General.SphereToImage(AoWHSMap.FPlayers.GetPlayers(H.FPlayer).FLeader.GetSpheres(6));
        end;
        UnitWindow.SphereLbl.Text := TranslateRStr(LeaderSpheresRStr);
      end;
      if ((AoWHSMap.FCombat = nil) and (H.FPlayer = AoWHSMap.FSeatedPlayer)) or
        ((AoWHSMap.FCombat <> nil) and
        (AoWHSMap.FCombat.FCombatData.FPlayers.GetPlayers(AoWHSMap.FCombat.FCombatData.FCurrentPlayer).FPlayer = H.FPlayer)) then
        UnitWindow.UnitTab.Items.Add(TranslateRStr(AoWE.ItemsRStr));
      if H.GetCastingPointsMax > 0 then
      begin
        UnitWindow.Mana.Visible := True;
        UnitWindow.Mana.Text := IntToStr(H.GetCastingPoints) + '/' + IntToStr(H.GetCastingPointsMax);
        UnitWindow.ManaIcon.Visible := True;
      end;
      UnitWindow.ItemUseBtn.Visible := False; UnitWindow.FGroundOffset := 0;
      UnitWindow.Level.Text := TranslateRStr(AoWE.LevelRStr) + ' ' + IntToStr(H.GetLevel);
      UnitWindow.T2Leader.Visible := True; UnitWindow.T2Text.Visible := False;
      UnitWindow.UnitName.Text := H.FHeroName + ' ' + H.GetNickname;
    end;
    UnitWindow.XP.Text := TranslateRStr(LoadResString(ShowExpRStr)) + ' ' + IntToStr(U.GetExperience) + ' (' + IntToStr(U.GetNextLevelExperience) + ')';
    UnitWindow.UnitWin.Cursor := 0;
    if (UnitWindow.UnitTab.Items.Count <= UnitWindow.UnitTab.Selected) or (UnitWindow.UnitTab.Selected < 0) then
      UnitWindow.UnitTab.Selected := 0;
    UnitWindow.UnitWin.Visible := True;
    if (H <> nil) and (((AoWHSMap.FCombat = nil) and (H.FPlayer = AoWHSMap.FSeatedPlayer)) or
        ((AoWHSMap.FCombat <> nil) and
        (AoWHSMap.FCombat.FCombatData.FPlayers.GetPlayers(AoWHSMap.FCombat.FCombatData.FCurrentPlayer).FPlayer = H.FPlayer))) then
    begin
      if H.FInventory.GetItem(0) <> nil then UnitWindow.BP1.Tag := H.FInventory.GetItem(0).FItemID
      else UnitWindow.BP1.Tag := -1;
      if H.FInventory.GetItem(1) <> nil then UnitWindow.BP2.Tag := H.FInventory.GetItem(1).FItemID
      else UnitWindow.BP2.Tag := -1;
      if H.FInventory.GetItem(2) <> nil then UnitWindow.BP3.Tag := H.FInventory.GetItem(2).FItemID
      else UnitWindow.BP3.Tag := -1;
      if H.FInventory.GetItem(3) <> nil then UnitWindow.BP4.Tag := H.FInventory.GetItem(3).FItemID
      else UnitWindow.BP4.Tag := -1;
      if H.FInventory.GetItem(4) <> nil then UnitWindow.BP5.Tag := H.FInventory.GetItem(4).FItemID
      else UnitWindow.BP5.Tag := -1;
      if H.FInventory.GetItem(5) <> nil then UnitWindow.BP6.Tag := H.FInventory.GetItem(5).FItemID
      else UnitWindow.BP6.Tag := -1;
      if H.FInventory.GetItem(6) <> nil then UnitWindow.BP7.Tag := H.FInventory.GetItem(6).FItemID
      else UnitWindow.BP7.Tag := -1;
      if H.FInventory.GetItem(7) <> nil then UnitWindow.BP8.Tag := H.FInventory.GetItem(7).FItemID
      else UnitWindow.BP8.Tag := -1;
      if H.FHeroItems.GetPositionItem(ipAttackSlot) <> nil then UnitWindow.Attack.Tag := H.FHeroItems.GetPositionItem(ipAttackSlot).FItemID
      else UnitWindow.Attack.Tag := -1;
      if H.FHeroItems.GetPositionItem(ipDefenseSlot) <> nil then UnitWindow.Defend.Tag := H.FHeroItems.GetPositionItem(ipDefenseSlot).FItemID
      else UnitWindow.Defend.Tag := -1;
      if H.FHeroItems.GetPositionItem(ipHeadSlot) <> nil then UnitWindow.Head.Tag := H.FHeroItems.GetPositionItem(ipHeadSlot).FItemID
      else UnitWindow.Head.Tag := -1;
      if H.FHeroItems.GetPositionItem(ipTorsoSlot) <> nil then UnitWindow.Torso.Tag := H.FHeroItems.GetPositionItem(ipTorsoSlot).FItemID
      else UnitWindow.Torso.Tag := -1;
      if H.FHeroItems.GetPositionItem(ipLeftRingSlot) <> nil then UnitWindow.RingL.Tag := H.FHeroItems.GetPositionItem(ipLeftRingSlot).FItemID
      else UnitWindow.RingL.Tag := -1;
      if H.FHeroItems.GetPositionItem(ipRightRingSlot) <> nil then UnitWindow.RingR.Tag := H.FHeroItems.GetPositionItem(ipRightRingSlot).FItemID
      else UnitWindow.RingR.Tag := -1;
      UnitWindow.UpdateGround(0); SelectedItem := nil;
      UnitWindow.BP1.Checked := False;
      UnitWindow.BP2.Checked := False;
      UnitWindow.BP3.Checked := False;
      UnitWindow.BP4.Checked := False;
      UnitWindow.BP5.Checked := False;
      UnitWindow.BP6.Checked := False;
      UnitWindow.BP7.Checked := False;
      UnitWindow.BP8.Checked := False;
      UnitWindow.Attack.Checked := False;
      UnitWindow.Defend.Checked := False;
      UnitWindow.Head.Checked := False;
      UnitWindow.Torso.Checked := False;
      UnitWindow.RingL.Checked := False;
      UnitWindow.RingR.Checked := False;
      UnitWindow.ItemUseBtn.Visible := False;
    end;
    if U <> nil then
    begin
      UnitWindow.UHits.Text := IntToStr(U.GetHitPoints) + '/' + IntToStr(U.GetHits);
      if AoWHSMap.FCombatMap = nil then
        UnitWindow.UMoves.Text := IntToStr(U.GetMovePoints) + '/' + IntToStr(U.GetMoves)
      else if General.FCombatUnit <> nil then
        UnitWindow.UMoves.Text := IntToStr(General.FCombatUnit.FUnit.FMovePoints) + '/' + IntToStr(General.FCombatUnit.FUnit.GetMoves);
      UnitWindow.UAttack.Text := IntToStr(U.GetAttack); UnitWindow.UDamage.Text := IntToStr(U.GetDamage);
      UnitWindow.UDefense.Text := IntToStr(U.GetDefense); UnitWindow.UResistance.Text := IntToStr(U.GetResistance);
      UnitWindow.UMovesIcon.CurrentImage := General.MTtoInt(U.GetMoveTypes);
      if U.GetManaUpkeep > 0 then
      begin UnitWindow.UpKeep.Text := IntToStr(U.GetManaUpkeep); UpkeepIcon.CurrentImage := 52; end
      else
      begin UnitWindow.UpKeep.Text := IntToStr(U.GetUpkeep); UpkeepIcon.CurrentImage := 51; end;
      AAlignment.Visible := U.GetAlignment <> alNone;
      case U.GetAlignment of
        alPureGood: AAlignment.CurrentImage := 31;
        alGood: AAlignment.CurrentImage := 32;
        alPureNeutral, alNeutral: AAlignment.CurrentImage := 33;
        alEvil: AAlignment.CurrentImage := 34;
        alPureEvil: AAlignment.CurrentImage := 35;
      end;
      AAlignmentLbl.Text := TranslateRStr(TAlignmentRStr[U.GetAlignment]);
      UnitWindow.T1AbilityLB.Items.Clear; UnitWindow.T1TypeLB.Items.Clear; UnitWindow.T1SrcLB.Items.Clear;
      MoraleLbl.Text := AoWE.Format(TranslateRStr(MoraleXRStr), [TranslateRStr(TMoraleRStr[U.GetMorale])]);
      MoraleLbl.Visible := U.GetUnitType <> utMachine;
      if AoWHSMap.FCombatMap = nil then
      begin
        U.ListAbilityInfo(T1AbilityLB.Items, T1TypeLB.Items, T1SrcLB.Items);
        SortStringsEx(T1AbilityLB.Items, CompareUnitAbilities, [T1TypeLB.Items, T1SrcLB.Items]);
      end
      else if (General.FCombatUnit <> nil) and (General.FCombatUnit.FUnit <> nil) and (General.FCombatUnit.FUnit.FUnit <> nil) then
      begin
        General.FCombatUnit.FUnit.FUnit.ListAbilityInfo(T1AbilityLB.Items, T1TypeLB.Items, T1SrcLB.Items);
        SortStringsEx(T1AbilityLB.Items, CompareUnitAbilities, [T1TypeLB.Items, T1SrcLB.Items]);
      end;
      UnitWindow.T1AbilityLB.Selected := -1;
      UnitWindow.T1AbilityLBChange(T1AbilityLB);
      UnitWin.FDrawn := False;
    end;
  end;
end;

procedure TUnitWindow.PreDrawAbilityItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SurfDesc: TSurfaceDesc);
var
  Enabled: Boolean;
  A: TAbility;
begin
  A := AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[DrawItem]));
  if AoWHSMap.FCombatMap = nil then
    Enabled := (A <> nil) and (General.FSelectedUnit <> nil) and
      (General.FSelectedUnit.FPlayer = AoWHSMap.FSeatedPlayer) and
      (acAction in A.GetControlType(General.FSelectedUnit))
  else
  begin
    Enabled := (A <> nil) and (General.FCombatUnit <> nil) and
      (acCombatAction in AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[DrawItem])).GetControlType(General.FCombatUnit.FUnit.FUnit)) and
      (General.FCombatUnit.FUnit.GetPlayer = AoWCombatMap.FSeatedPlayer) and
      (General.FCombatUnit.FUnit.FMovePoints > 0) and
      (not ((AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[DrawItem])).GetCombatMode(General.FCombatUnit.FUnit.FUnit) in
        [cmShortRange, cmMediumRange, cmLongRange]) or
        (Integer(T1AbilityLB.Items.Objects[DrawItem]) = 52)) or
        (General.FCombatUnit.FUnit.FUnit.GetMoves = General.FCombatUnit.FUnit.FMovePoints));
  end;
  if Enabled then Sender.TextColor := $DFFEFF else Sender.TextColor := $8FA9A0;
end;







procedure TUnitWindow.HelpClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
end;

procedure TUnitWindow.T1AbilityLBChange(Sender: TObject);
var
  A: TAbility;
begin
  T1AbilityLB.Selected := TAOWListBox(Sender).Selected;
  T1TypeLB.Selected := TAOWListBox(Sender).Selected;
  T1SrcLB.Selected := TAOWListBox(Sender).Selected;
  if AoWHSMap.FCombatMap = nil then
  begin
    if (General.FSelectedUnit.FPlayer = AoWHSMap.FSeatedPlayer) and (T1AbilityLB.Selected > -1) then
    begin
      A := AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected]));
      if (A <> nil) and A.GetEnabled(General.FSelectedUnit) then
      begin
        if AoWHSMap.FCombatMap = nil then
          T1UseBut.Visible := acAction in A.GetControlType(General.FSelectedUnit)
        else
          T1UseBut.Visible :=
            (AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected])).GetCombatMode(General.FSelectedUnit) <> cmNone) and
            (AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected])).GetCombatMode(General.FSelectedUnit) <> cmMelee);
        if T1UseBut.Visible then
          T1UseBut.Text := AoWE.Format(TranslateRStr(UseXRStr), [A.GetName(General.FSelectedUnit)]);
      end
      else
        T1UseBut.Visible := False;
    end
    else
      T1UseBut.Visible := False;
  end
  else
  begin
    if (T1AbilityLB.Selected > -1) and (General.FCombatUnit <> nil) and
      (acCombatAction in AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected])).GetControlType(General.FCombatUnit.FUnit.FUnit)) and
      (General.FCombatUnit.FUnit.GetPlayer = AoWCombatMap.FSeatedPlayer) and
      (General.FCombatUnit.FUnit.FMovePoints > 0) and
      (not ((AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected])).GetCombatMode(General.FCombatUnit.FUnit.FUnit) in
        [cmShortRange, cmMediumRange, cmLongRange]) or
        (Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected]) = 52)) or
        (General.FCombatUnit.FUnit.FUnit.GetMoves = General.FCombatUnit.FUnit.FMovePoints)) then
    begin
        T1UseBut.Visible := True;
        T1UseBut.Text := AoWE.Format(TranslateRStr(UseXRStr),
          [AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected])).GetName(General.FCombatUnit.FUnit.FUnit)]);
    end
    else
      T1UseBut.Visible := False;
  end;
end;







procedure TUnitWindow.T1SbarChange(Sender: TObject);
begin
  T1AbilityLB.ListOffset := T1SBar.Position;
  T1TypeLB.ListOffset := T1SBar.Position;
end;

procedure TUnitWindow.ItemRHMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Check: TAOWCheckBox;
begin
  Check := TAOWCheckBox(Sender);
  ItemID := Check.Tag;
end;

procedure TUnitWindow.UnitWinResize(Sender: TObject);
begin
  with UnitWin do
    begin
      Alignment.LeftOffset := WinLeft;
      Alignment.TopOffset := WinTop;
      Alignment.AlignHeight := ahTop;
      Alignment.AlignWidth := awLeft;
    end;
end;

procedure TUnitWindow.UnitWindowCreate(Sender: TObject);
begin
  FItemType := TItemType(6);
end;

procedure TUnitWindow.UnitWinUpdate(Sender: TObject);
begin
  if UnitWin.Visible then
  begin
    Inc(FHighlight, FHighlightStep);
    if (FHighlight > 100) or (FHighlight < 50) then
    begin
      FHighlightStep := -FHighlightStep;
      Inc(FHighlight, FHighlightStep);
    end;
    case FItemType of
      itAttack: Attack.FDrawn := False;
      itDefense: Defend.FDrawn := False;
      itHead: Head.FDrawn := False;
      itTorso: Torso.FDrawn := False;
      itRing: begin RingL.FDrawn := False; RingR.FDrawn := False; end;
    end;
    if SelectedItem <> nil then
    begin
      Dec(FBlinkDelay);
      if FBlinkDelay < 0 then
      begin
        FBlinkDelay := 2;
        FItemVisible := not FItemVisible;
      end;
    end;
  end;
end;

procedure TUnitWindow.T1SortNameClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T1AbilityLB); Lists.Add(T1TypeLB); Lists.Add(T1SrcLB);
  General.SortLists(Lists, 0);
  T1UseBut.Visible := False;
end;

procedure TUnitWindow.T1SortTypeClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T1TypeLB); Lists.Add(T1AbilityLB); Lists.Add(T1SrcLB);
  General.SortLists(Lists, 0);
  T1UseBut.Visible := False;
end;

procedure TUnitWindow.T1SortSourceClick(Sender: TObject; Button: Integer);
var
  Lists: TList;
begin
  General.PlayButtonSound(0);
  Lists := TList.Create;
  Lists.Add(T1SrcLB); Lists.Add(T1AbilityLB); Lists.Add(T1TypeLB);
  General.SortLists(Lists, 0);
  T1UseBut.Visible := False;
end;

procedure TUnitWindow.UseAbility;
var
  A: TAbility;
  Reason: string;
begin
  General.PlayButtonSound(0);
  A := AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected]));
  if (A <> nil) and A.GetEnabled(General.FSelectedUnit) then
    if AoWHSMap.FCombatMap = nil then
    begin
      if General.FSelectedUnit.FPlayer = AoWHSMap.FSeatedPlayer then
        if A.Activate(General.FSelectedUnit, Reason) then
          UnitWin.Visible := False
        else
          if Reason <> '' then AoWHSMap.ShowWarning(Reason);
    end
    else
      if (General.FCombatUnit <> nil) and
        (General.FCombatUnit.FUnit.FCombatPlayer = AoWCombatMap.FSeatedCombatPlayer) then
        if General.FCombatUnit.SelectAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected])) > -1 then
          UnitWin.Visible := False;
end;

procedure TUnitWindow.UseItemClick(Sender: TObject);
var
  Reason: string;
begin
  General.PlayButtonSound(0);
  if (SelectedItem <> nil) and (General.FSelectedUnit is THero) then
    if THero(General.FSelectedUnit).CanUseItem(SelectedItem.Tag, Reason) then
      THero(General.FSelectedUnit).UseItem(SelectedItem.Tag)
    else
      AoWHSMap.ShowWarning(Reason);
end;

procedure TUnitWindow.UnitTabChange(Sender: TObject);
begin
  General.PlayButtonSound(0);
end;

procedure TUnitWindow.UnitWinMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbRight) and (SelectedItem <> nil) then Gnd1Change(SelectedItem);
end;

procedure TUnitWindow.UnitWinEnter(Sender: TObject);
begin
  MainForm.FCursorImage := FCursorImage;
end;

procedure TUnitWindow.UnitWinExit(Sender: TObject);
begin
  MainForm.FCursorImage := nil;
end;

procedure TUnitWindow.UnitWinShow(Sender: TObject);
begin
  FCursorImage := nil;
  MainForm.FCursorImage := FCursorImage;
end;

procedure TUnitWindow.GroundRClick(Sender: TObject);
begin
  UpdateGround(FGroundOffset + 1);
end;

procedure TUnitWindow.GroundLClick(Sender: TObject);
begin
  UpdateGround(FGroundOffset - 1);
end;

procedure TUnitWindow.CloseClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  UnitWin.Visible := False;
end;

procedure TUnitWindow.Gnd1Draw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  U: THero;
  Item: TItem;
begin
  if Sender.Tag <> -1 then
  begin
    U := THero(General.FSelectedUnit);
    Item := U.FInventory.FindItem(Sender.Tag);
    if Item = nil then Item := U.FHeroItems.FindItem(Sender.Tag);
    if Item = nil then
      if U.GetItemsOnGround <> nil then Item := U.GetItemsOnGround.FindItem(Sender.Tag);
    if Item <> nil then
      with T3Panel do
        with TAOWCheckBox(Sender) do
          if Item.GetImage <> nil then
            Item.GetImage.ShowClipped(T3Panel.WinLeft + WinLeft, T3Panel.WinTop + WinTop, SurfDesc);
  end;
end;

procedure TUnitWindow.FrLShPreDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  R: TRect;
begin
  if General.FSelectedUnit <> nil then
    if General.FSelectedUnit.GetFace <> nil then
    begin
      with TAOWImage(Sender) do R := Classes.Rect(WinLeft + 29, WinTop + 28,
        WinLeft + 132, WinTop + 156);
      General.FSelectedUnit.ShowFace(R, SurfDesc);
    end;
end;

procedure TUnitWindow.FrRShPreDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
begin
  if General.FSelectedUnit <> nil then
  begin
    FShowInfo.Direction := 3;
    if General.FSelectedUnit is THero then FShowInfo.Overlays := [] else FShowInfo.Overlays := [uoRank];
    with TAOWImage(Sender) do General.FSelectedUnit.ShowEx(WinLeft + 49, WinTop + 78, SurfDesc, FShowInfo);
  end;
end;

procedure TUnitWindow.Gnd1Change(Sender: TObject);
var Item: TItem; U: THero; Check: TAOWCheckBox;
begin
  Check := TAOWCheckBox(Sender); U := THero(General.FSelectedUnit);
  if U <> nil then
    if not AoWHSMap.FPlayers.GetPlayers(U.FPlayer).GetBusy and Check.Checked then
    begin
      FCursorImage := nil;
      if Check <> SelectedItem then
      begin
        if SelectedItem <> nil then
        begin
          PlaySample('SFX\Events\NewEvent.Wav');
          if Check.Tag <> -1 then U.SwapItem(SelectedItem.Tag, Check.Tag)
          else
          begin
            if Check = Head then U.PlaceItem(SelectedItem.Tag, ipHeadSlot)
else if Check = Torso then U.PlaceItem(SelectedItem.Tag, ipTorsoSlot)
else if Check = Attack then U.PlaceItem(SelectedItem.Tag, ipAttackSlot)
else if Check = Defend then U.PlaceItem(SelectedItem.Tag, ipDefenseSlot)
else if Check = RingR then U.PlaceItem(SelectedItem.Tag, ipRightRingSlot)
else if Check = RingL then U.PlaceItem(SelectedItem.Tag, ipLeftRingSlot)
else if Check = BP1 then U.PlaceItem(SelectedItem.Tag, ipInventorySlot1)
else if Check = BP2 then U.PlaceItem(SelectedItem.Tag, ipInventorySlot2)
else if Check = BP3 then U.PlaceItem(SelectedItem.Tag, ipInventorySlot3)
else if Check = BP4 then U.PlaceItem(SelectedItem.Tag, ipInventorySlot4)
else if Check = BP5 then U.PlaceItem(SelectedItem.Tag, ipInventorySlot5)
else if Check = BP6 then U.PlaceItem(SelectedItem.Tag, ipInventorySlot6)
else if Check = BP7 then U.PlaceItem(SelectedItem.Tag, ipInventorySlot7)
else if Check = BP8 then U.PlaceItem(SelectedItem.Tag, ipInventorySlot8)
else U.PlaceItem(SelectedItem.Tag, ipGround);
          end;
          Check.Checked := False;
          SelectedItem.Checked := False;
          SelectedItem := nil;
          UnitWin.Cursor := 0;
          FItemType := itUse;
          ItemUseBtn.Visible := False;
          FItemVisible := False;
        end
        else
        begin
          if Check.Tag <> -1 then
          begin
            SelectedItem := Check;
            FHighlight := 50;
            FHighlightStep := 10;
            Item := U.FInventory.FindItem(SelectedItem.Tag);
            if Item = nil then Item := U.FHeroItems.FindItem(SelectedItem.Tag);
            if Item = nil then
              if U.GetItemsOnGround <> nil then Item := U.GetItemsOnGround.FindItem(SelectedItem.Tag);
            if Item <> nil then
            begin
              FCursorImage := Item.GetImage;
              FItemType := Item.FItemType;
              if Item.FItemType = itScroll then ItemUseBtn.Visible := True
              else ItemUseBtn.Visible := False;
            end
            else
            begin FItemType := itUse; ItemUseBtn.Visible := False; end;
            FBlinkDelay := 2;
            FItemVisible := True;
          end
          else Check.Checked := False;
        end;
      end
      else
      begin
        SelectedItem.Checked := False;
        SelectedItem := nil;
        UnitWin.Cursor := 0;
        FItemType := itUse;
        ItemUseBtn.Visible := False;
        FItemVisible := False;
      end;
      MainForm.FCursorImage := FCursorImage;
    end;
end;




procedure TUnitWindow.Gnd3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if General.FSelectedUnit <> nil then
    if not AoWHSMap.FPlayers.GetPlayers(General.FSelectedUnit.FPlayer).GetBusy then
    begin
      if Button = mbRight then
      begin
        if TAOWCheckBox(Sender).Tag = -1 then TAOWCheckBox(Sender).PopupMenu := nil
        else TAOWCheckBox(Sender).PopupMenu := ItemBanner.IBannerPopup;
        ItemID := TAOWCheckBox(Sender).Tag;
      end
      else
        if Sender = SelectedItem then SelectedItem.Checked := False;
    end;
end;

procedure TUnitWindow.HeadDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
begin
  Gnd1Draw(Sender, SurfDesc);
  if (SelectedItem <> nil) and (Sender <> SelectedItem) and (FItemType = TItemType(0)) then
    with T3Panel do
      with TAOWCheckBox(Sender) do
        IntGfxMod.UnitWin[24].ShowBlended(T3Panel.WinLeft + WinLeft,
          T3Panel.WinTop + WinTop, SurfDesc, IntensityBlendTable.LookupTables[FHighlight]);
end;

procedure TUnitWindow.TorsoDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
begin
  Gnd1Draw(Sender, SurfDesc);
  if (SelectedItem <> nil) and (Sender <> SelectedItem) and (FItemType = TItemType(1)) then
    with T3Panel do
      with TAOWCheckBox(Sender) do
        IntGfxMod.UnitWin[24].ShowBlended(T3Panel.WinLeft + WinLeft,
          T3Panel.WinTop + WinTop, SurfDesc, IntensityBlendTable.LookupTables[FHighlight]);
end;

procedure TUnitWindow.AttackDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
begin
  Gnd1Draw(Sender, SurfDesc);
  if (SelectedItem <> nil) and (Sender <> SelectedItem) and (FItemType = TItemType(2)) then
    with T3Panel do
      with TAOWCheckBox(Sender) do
        IntGfxMod.UnitWin[24].ShowBlended(T3Panel.WinLeft + WinLeft,
          T3Panel.WinTop + WinTop, SurfDesc, IntensityBlendTable.LookupTables[FHighlight]);
end;

procedure TUnitWindow.DefendDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
begin
  Gnd1Draw(Sender, SurfDesc);
  if (SelectedItem <> nil) and (Sender <> SelectedItem) and (FItemType = TItemType(3)) then
    with T3Panel do
      with TAOWCheckBox(Sender) do
        IntGfxMod.UnitWin[24].ShowBlended(T3Panel.WinLeft + WinLeft,
          T3Panel.WinTop + WinTop, SurfDesc, IntensityBlendTable.LookupTables[FHighlight]);
end;

procedure TUnitWindow.RingLDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
begin
  Gnd1Draw(Sender, SurfDesc);
  if (SelectedItem <> nil) and (Sender <> SelectedItem) and (FItemType = TItemType(4)) then
    with T3Panel do
      with TAOWCheckBox(Sender) do
        IntGfxMod.UnitWin[24].ShowBlended(T3Panel.WinLeft + WinLeft,
          T3Panel.WinTop + WinTop, SurfDesc, IntensityBlendTable.LookupTables[FHighlight]);
end;

procedure TUnitWindow.DisbandBtnClick;
begin
  DialogWin.Confirm(TranslateRStr(E2Globals.ConfirmRStr), TranslateRStr(DisbandUnitRStr), 7);
end;

procedure TUnitWindow.T1AbilityLBMouseDown(Sender: TObject; Button: TMouseButton);
var
  A: TAbility;
begin
  if (Button = mbRight) and (General.FSelectedUnit <> nil) and (T1AbilityLB.Selected <> -1) then
  begin
    A := AoWHSSet.FAbilityControl.GetAbility(Integer(T1AbilityLB.Items.Objects[T1AbilityLB.Selected]));
    if A <> nil then AoWExeForms.SetInfoBanner(InfoBanner, A.GetName(nil), A.FDescription);
  end;
end;

procedure TUnitWindow.UnitWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: UnitWin.Visible := False;
  end;
end;

procedure TUnitWindow.PPrevClick;
var
  I: Integer;
begin
  General.PlayButtonSound(0);
  if General.FUnitList <> nil then
  begin
    I := General.IndexOfUnit(General.FSelectedUnit);
    if (I > -1) and (General.FSelectedUnits[0] > -1) then
    begin
      Dec(I);
      if I < 0 then
      begin
        I := 7;
        while General.FSelectedUnits[I] = -1 do Dec(I);
      end;
      General.FSelectedUnit := General.FUnitList.GetUnit(General.FSelectedUnits[I]);
      ShowUnit;
    end;
  end;
end;

procedure TUnitWindow.PNextClick;
var
  I: Integer;
begin
  General.PlayButtonSound(0);
  if General.FUnitList <> nil then
  begin
    I := General.IndexOfUnit(General.FSelectedUnit);
    if I > -1 then
    begin
      Inc(I); if I > 7 then I := 0;
      if General.FSelectedUnits[I] = -1 then I := 0;
      General.FSelectedUnit := General.FUnitList.GetUnit(General.FSelectedUnits[I]);
      ShowUnit;
    end;
  end;
end;


procedure TUnitWindow.UpdateGround(Offset: Integer);
var
  U: TAbstractUnit;
begin
  Gnd1.Tag := -1;
  Gnd2.Tag := -1;
  Gnd3.Tag := -1;
  Gnd4.Tag := -1;
  Gnd5.Tag := -1;
  Gnd1.Checked := False;
  Gnd2.Checked := False;
  Gnd3.Checked := False;
  Gnd4.Checked := False;
  Gnd5.Checked := False;
  U := General.FSelectedUnit;
  if U <> nil then
    if U is THero then
      if THero(U).GetItemsOnGround <> nil then
      begin
        FGroundCount := THero(U).GetItemsOnGround.Count;
        FGroundOffset := Offset;
        { Original last-page clamp leaves only four items visible. }
        if FGroundCount < Offset + 5 then FGroundOffset := FGroundCount - 4;
        if FGroundOffset < 0 then FGroundOffset := 0;
        GroundL.Visible := FGroundOffset > 0;
        GroundR.Visible := FGroundOffset + 5 <= FGroundCount;
        if FGroundOffset < THero(U).GetItemsOnGround.Count then
          Gnd1.Tag := THero(U).GetItemsOnGround.GetItem(FGroundOffset).FItemID;
        if FGroundOffset + 1 < THero(U).GetItemsOnGround.Count then
          Gnd2.Tag := THero(U).GetItemsOnGround.GetItem(FGroundOffset + 1).FItemID;
        if FGroundOffset + 2 < THero(U).GetItemsOnGround.Count then
          Gnd3.Tag := THero(U).GetItemsOnGround.GetItem(FGroundOffset + 2).FItemID;
        if FGroundOffset + 3 < THero(U).GetItemsOnGround.Count then
          Gnd4.Tag := THero(U).GetItemsOnGround.GetItem(FGroundOffset + 3).FItemID;
        if FGroundOffset + 4 < THero(U).GetItemsOnGround.Count then
          Gnd5.Tag := THero(U).GetItemsOnGround.GetItem(FGroundOffset + 4).FItemID;
      end;
end;

end.
