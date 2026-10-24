unit AoWSpellBook;

{ Draft declarations of AoWSpellBook, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC, EventLog, AoWComp, PageTurnCtrl, AoWBookWindow, AoWButton, AoWImage, AoWLabel, AoWMemo, AoWPanel;

type
  TSpellBook = class;


  { TSpellBook (instance size $248, VMT 0042DDA8): $220 mode, $221 page kind, $222 spell type, $224 spells, $228 page, $22C hero, $230 activation, $234 researched spell, $238 callback, $240 event, $244 saved player pages. }
  TSpellBook = class(TDataModule)
  public
    published
    LeftHeader: TAOWLabel; { +0044 }
    LeftSpellPage: TAOWPanel; { +0048 }
    S1Pnl: TAOWPanel; { +004C }
    S1Spell: TAOWLabel; { +0050 }
    S1Class: TAOWLabel; { +0054 }
    S1Memo: TAOWMemo; { +0058 }
    S1Cost: TAOWLabel; { +005C }
    S1Icn: TAOWImage; { +0060 }
    S2Pnl: TAOWPanel; { +0064 }
    S2Spell: TAOWLabel; { +0068 }
    S2Class: TAOWLabel; { +006C }
    S2Memo: TAOWMemo; { +0070 }
    S2Cost: TAOWLabel; { +0074 }
    S2Icn: TAOWImage; { +0078 }
    S3Pnl: TAOWPanel; { +007C }
    S3Spell: TAOWLabel; { +0080 }
    S3Class: TAOWLabel; { +0084 }
    S3Memo: TAOWMemo; { +0088 }
    S3Cost: TAOWLabel; { +008C }
    S3Icn: TAOWImage; { +0090 }
    S4Pnl: TAOWPanel; { +0094 }
    S4Spell: TAOWLabel; { +0098 }
    S4Class: TAOWLabel; { +009C }
    S4Memo: TAOWMemo; { +00A0 }
    S4Cost: TAOWLabel; { +00A4 }
    S4Icn: TAOWImage; { +00A8 }
    RightHeader: TAOWLabel; { +00AC }
    RightSpellPage: TAOWPanel; { +00B0 }
    S5Pnl: TAOWPanel; { +00B4 }
    S5Spell: TAOWLabel; { +00B8 }
    S5Class: TAOWLabel; { +00BC }
    S5Memo: TAOWMemo; { +00C0 }
    S5Cost: TAOWLabel; { +00C4 }
    S5Icn: TAOWImage; { +00C8 }
    S6Pnl: TAOWPanel; { +00CC }
    S6Spell: TAOWLabel; { +00D0 }
    S6Class: TAOWLabel; { +00D4 }
    S6Memo: TAOWMemo; { +00D8 }
    S6Cost: TAOWLabel; { +00DC }
    S6Icn: TAOWImage; { +00E0 }
    S7Pnl: TAOWPanel; { +00E4 }
    S7Spell: TAOWLabel; { +00E8 }
    S7Class: TAOWLabel; { +00EC }
    S7Memo: TAOWMemo; { +00F0 }
    S7Cost: TAOWLabel; { +00F4 }
    S7Icn: TAOWImage; { +00F8 }
    S8Pnl: TAOWPanel; { +00FC }
    S8Spell: TAOWLabel; { +0100 }
    S8Class: TAOWLabel; { +0104 }
    S8Memo: TAOWMemo; { +0108 }
    S8Cost: TAOWLabel; { +010C }
    S8Icn: TAOWImage; { +0110 }
    S1Btn: TAOWButton; { +0114 }
    CurrentPointsLbl: TAOWLabel; { +0118 }
    Line: TAOWLabel; { +011C }
    CastingPointsMaxLbl: TAOWLabel; { +0120 }
    GlobalBtn: TAOWButton; { +0124 }
    UnitBtn: TAOWButton; { +0128 }
    CombatBtn: TAOWButton; { +012C }
    InfoBtn: TAOWButton; { +0130 }
    PrevBtn: TAOWButton; { +0134 }
    NextBtn: TAOWButton; { +0138 }
    Cancel: TAOWButton; { +013C }
    S2Btn: TAOWButton; { +0140 }
    S3Btn: TAOWButton; { +0144 }
    S4Btn: TAOWButton; { +0148 }
    S5btn: TAOWButton; { +014C }
    S6Btn: TAOWButton; { +0150 }
    S7Btn: TAOWButton; { +0154 }
    S8Btn: TAOWButton; { +0158 }
    CastingPage: TAOWPanel; { +015C }
    CastingPnl: TAOWPanel; { +0160 }
    CastingSpell: TAOWLabel; { +0164 }
    CastingClass: TAOWLabel; { +0168 }
    CastingMemo: TAOWMemo; { +016C }
    CastingCost: TAOWLabel; { +0170 }
    CastingIcn: TAOWImage; { +0174 }
    LeftInfoPage: TAOWPanel; { +0178 }
    CastingStatus: TAOWLabel; { +017C }
    CastingPointsLbl: TAOWLabel; { +0180 }
    CastingBtn: TAOWButton; { +0184 }
    Sel4: TAOWButton; { +0188 }
    SelPnl: TAOWPanel; { +018C }
    Sel3: TAOWButton; { +0190 }
    Sel2: TAOWButton; { +0194 }
    Sel1: TAOWButton; { +0198 }
    Sel5: TAOWButton; { +019C }
    Sel6: TAOWButton; { +01A0 }
    Sel7: TAOWButton; { +01A4 }
    SelLbl: TAOWLabel; { +01A8 }
    SpellBookLbl: TAOWLabel; { +01AC }
    NameLbl: TAOWLabel; { +01B0 }
    ManaPoolLbl: TAOWLabel; { +01B4 }
    CastingLbl: TAOWLabel; { +01B8 }
    FaceFrame: TAOWImage; { +01BC }
    Face: TAOWImage; { +01C0 }
    Dlg: TAoWBookWindow; { +01C4 }
    NoneCastingLbl: TAOWLabel; { +01C8 }
    ResearchPage: TAOWPanel; { +01CC }
    ResearchName: TAOWLabel; { +01D0 }
    ResearchClass: TAOWLabel; { +01D4 }
    ResearchMemo: TAOWMemo; { +01D8 }
    ResearchCost: TAOWLabel; { +01DC }
    ResearchIcn: TAOWImage; { +01E0 }
    ResearchStatus: TAOWLabel; { +01E4 }
    ResearchNone: TAOWLabel; { +01E8 }
    ResearchPnl: TAOWPanel; { +01EC }
    ResearchLbl: TAOWLabel; { +01F0 }
    RightInfoPage: TAOWPanel; { +01F4 }
    ManaInfo: TAOWLabel; { +01F8 }
    Sep: TAOWImage; { +01FC }
    ResearchPointsLbl: TAOWLabel; { +0200 }
    ResearchManaPoolLbl: TAOWLabel; { +0204 }
    RManaInfo: TAOWLabel; { +0208 }
    AOWImage1: TAOWImage; { +020C }
    ResearchBookLbl: TAOWLabel; { +0210 }
    CancelResearchBtn: TAOWButton; { +0214 }
    CancelCastingBtn: TAOWButton; { +0218 }
    Translator: TIvTranslator; { +021C }
    public
    FMode: Byte; { $220: world casting, combat casting, research, researched }
    FPageKind: Byte; { $221: information or spell list }
    FSpellType: TSpellType; { $222 }
    FReserved223: Byte;
    FSpells: TSpellList; { $224 }
    FPage: Integer; { $228 }
    FHero: THero; { $22C }
    FActivation: TActivateAbilityInfo; { $230 }
    FResearchedSpell: Integer; { $234 }
    FDone: TExecuteDoneEvent; { $238 }
    FEvent: TPlayerMagicEventLog; { $240 }
    FPlayerPages: TDoubleItemList; { $244 }
    procedure ShowBook;
    procedure FinishDialog;
    function ValidateHero: Boolean;
    procedure Reset;
    procedure SetPageKind(Kind: Byte);
    procedure UpdateSpellPages;
    procedure UpdateInfoPages;
    procedure ShowSpellEntry(Spell: TSpell; Panel: TAOWPanel; Button: TAOWButton;
      Name, SpellClass, Cost: TAOWLabel; Memo: TAOWMemo; Icon: TAOWImage);
    procedure SelectSpell(Spell: TSpell);
    procedure PlayerChanged(Player: Shortint);
    procedure UnitChanged(U: TAbstractUnit);
    procedure ShowResearch;
    procedure ShowResearchEvent(Event: TPlayerMagicEventLog; Done: TExecuteDoneEvent);
    procedure ShowResearchedEvent(Event: TPlayerMagicEventLog; Done: TExecuteDoneEvent);
    procedure ShowCasting(Activation: TActivateAbilityInfo);
    procedure ShowCombatCasting(Activation: TActivateAbilityInfo);
    published procedure SpellBookCreate; public
    published procedure SpellBookDestroy; public
    published procedure CancelClick; public
    published procedure NextBtnClick; public
    published procedure PrevBtnClick; public
    published procedure SpellIconDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure SelectSpellBtnClick(Sender: TObject); public
    published procedure GlobalBtnClick(Sender: TObject); public
    published procedure UnitBtnClick; public
    published procedure CombatBtnClick; public
    published procedure InfoBtnClick(Sender: TObject); public
    published procedure CastingBtnClick; public
    published procedure CancelCastingBtnClick; public
    published procedure FaceDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure ResearchIcnDraw(Sender: TAOWImage; SD: TSurfaceDesc); public
    published procedure CastingIcnDraw(Sender: TAOWImage; SD: TSurfaceDesc); public
    published procedure CancelResearchBtnClick; public
    published procedure Sel1Click; public
    published procedure DlgHide; public
    published procedure DlgUpdate; public
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


implementation

uses AoWUnit, E3Globals, AoWWinMan;

procedure TSpellBook.SpellBookCreate;
var Defaults: TDoubleItem;
begin
  FSpells := TSpellList.Create;
  Defaults.A := 2; Defaults.B := 0;
  FPlayerPages := TDoubleItemList.Create;
  FPlayerPages.Default := Defaults;
end;

procedure TSpellBook.SpellBookDestroy;
begin
  if FActivation <> nil then
  begin FActivation.Release; FActivation := nil; end;
  FPlayerPages.Free;
  FSpells.Free;
end;

procedure TSpellBook.CancelClick;
begin
  if (AoWHSMap.FCombatMap <> nil) and (General.FCombatUnit <> nil) then
    General.FCombatUnit.SelectAbility(-1);
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TSpellBook.NextBtnClick;
begin
  Inc(FPage); UpdateSpellPages; Dlg.StartAnim(ptLeft);
  Dlg.FPageTurn.FSpeed := 25;
  PlaySample('Sfx\Int\Pagef1.wav');
end;

procedure TSpellBook.PrevBtnClick;
begin
  Dec(FPage); UpdateSpellPages; Dlg.StartAnim(ptRight);
  Dlg.FPageTurn.FSpeed := 25;
  PlaySample('Sfx\Int\Pagef1.wav');
end;

procedure TSpellBook.SpellIconDraw(Sender: TObject; SD: TSurfaceDesc);
var Index, X, Y: Integer;
begin
  Index := FPage * 8 + (TComponent(Sender).Tag and $F);
  if (Index >= 0) and (Index < FSpells.GetCount) then
    if FSpells.GetSpell(Index).FCastImages.GetImageSequence(10) <> nil then
    begin
      with TAOWImage(Sender) do begin X := FAOWWindow.WinLeft;
      Y := FAOWWindow.WinTop;
      FSpells.GetSpell(Index).FCastImages.Show(10, WinLeft + X, WinTop + Y, 0, SD); end;
    end;
end;

procedure TSpellBook.SelectSpellBtnClick(Sender: TObject);
begin
  SelectSpell(FSpells.GetSpell(FPage * 8 + TComponent(Sender).Tag));
end;

procedure TSpellBook.GlobalBtnClick(Sender: TObject);
begin
  if (FSpellType <> stGlobal) or (FPage <> 0) or (FPageKind <> 1) then
  begin
    if FPageKind = 0 then Dlg.StartAnim(ptLeft) else Dlg.StartAnim(ptRight);
    PlaySample('Sfx\Int\Pagef1.wav');
    FSpellType := stGlobal; FPage := 0; UpdateSpellPages; SetPageKind(1);
  end;
end;

procedure TSpellBook.UnitBtnClick;
begin
  if (FSpellType <> stUnit) or (FPage <> 0) or (FPageKind <> 1) then
  begin
    if (FPageKind = 0) or (FSpellType = stGlobal) then Dlg.StartAnim(ptLeft)
    else Dlg.StartAnim(ptRight);
    PlaySample('Sfx\Int\Pagef1.wav');
    FSpellType := stUnit; FPage := 0; UpdateSpellPages; SetPageKind(1);
  end;
end;

procedure TSpellBook.CombatBtnClick;
begin
  if (FSpellType <> stCombat) or (FPage <> 0) or (FPageKind <> 1) then
  begin
    Dlg.StartAnim(ptLeft);
    PlaySample('Sfx\Int\Pagef1.wav');
    FSpellType := stCombat; FPage := 0; UpdateSpellPages; SetPageKind(1);
  end;
end;

procedure TSpellBook.InfoBtnClick(Sender: TObject);
begin
  if FPageKind <> 0 then
  begin
    Dlg.StartAnim(ptRight);
    PlaySample('Sfx\Int\Pagef1.wav');
    SetPageKind(0);
  end;
end;

procedure TSpellBook.CastingBtnClick;
var Reason: string;
begin
  General.PlayButtonSound(0);
  if ValidateHero then
  begin
    case FMode of
      0: if FHero.CastSpell(FHero.FCastingSpellID, Reason) then Dlg.Visible := False
         else AoWHSMap.ShowWarning(Reason);
      1: SelectSpell(AoWHSSet.FSpellControl.GetSpell(FHero.FCastingSpellID));
    end;
  end;
end;

procedure TSpellBook.CancelCastingBtnClick;
begin
  General.PlayButtonSound(0);
  if ValidateHero then FHero.CancelCasting;
end;

procedure TSpellBook.FaceDraw(Sender: TObject; SD: TSurfaceDesc);
var R: TRect;
begin
  with TAOWImage(Sender) do
    R := Rect(LeftInfoPage.WinLeft + WinLeft, LeftInfoPage.WinTop + WinTop,
      LeftInfoPage.WinLeft + WinLeft + WinWidth,
      LeftInfoPage.WinTop + WinTop + WinHeight);
  FHero.GetFace.ShowStretched(R, SD);
end;

procedure TSpellBook.ResearchIcnDraw(Sender: TAOWImage; SD: TSurfaceDesc); { Tried cast sender with and coordinate order; cast sender and coordinate identity; opaque Sender and explicit image with cast; coordinate order; named parent window local for coordinate computation; no exact match. }
var Spell: TSpell; X: Integer;
begin
  Spell := AoWHSSet.FSpellControl.GetSpell(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.FResearchSpellID);
  if (Spell = nil) and (FMode = 3) then Spell := AoWHSSet.FSpellControl.GetSpell(FResearchedSpell);
  if Spell <> nil then with Sender do
  begin
    X := FAOWWindow.WinLeft;
    Spell.FCastImages.Show(10, WinLeft + X, FAOWWindow.WinTop + WinTop, 0, SD);
  end;
end;

procedure TSpellBook.CastingIcnDraw(Sender: TAOWImage; SD: TSurfaceDesc); { Tried cast sender with and coordinate order; cast sender and coordinate identity; opaque Sender and explicit image with cast; coordinate order; named parent window local for coordinate computation; no exact match. }
var Spell: TSpell; X: Integer;
begin
  if FHero <> nil then
    if FHero.Casting then
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(FHero.FCastingSpellID);
      if Spell <> nil then with Sender do
      begin
        X := FAOWWindow.WinLeft;
        Spell.FCastImages.Show(10, WinLeft + X, FAOWWindow.WinTop + WinTop, 0, SD);
      end;
    end;
end;

procedure TSpellBook.CancelResearchBtnClick;
var Control: TPlayerMagicControl;
begin
  General.PlayButtonSound(0);
  if ValidateHero then
  begin
    Control := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl;
    if Control.FResearchSpellID <> 0 then Control.ResearchSpell(0) else GlobalBtnClick(Self);
  end;
end;

procedure TSpellBook.Sel1Click;
begin General.PlayButtonSound(0); end;

procedure TSpellBook.DlgHide;
begin FinishDialog; end;

procedure TSpellBook.DlgUpdate;
begin
  if Dlg.Visible then
    if not ValidateHero then Dlg.Visible := False;
end;

procedure TSpellBook.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    if (AoWHSMap.FCombatMap <> nil) and (General.FCombatUnit <> nil) then
      General.FCombatUnit.SelectAbility(-1);
    Dlg.Visible := False;
  end;
end;

procedure TSpellBook.ShowBook;
begin
  General.Manager.OverlayPriority := 49;
  if (AoWUnit.MainForm.DXDC = AoWUnit.MainForm.Display.ActiveDC) and AoWUnit.MainForm.DXDC.UseVideoMemory then
    General.Manager.FDrawOverlay := False;
  Dlg.Visible := True;
end;

procedure TSpellBook.FinishDialog;
var Done: TExecuteDoneEvent; Event: TPlayerMagicEventLog;
begin
  PlaySample('SFX\INT\BOOKCLSE.WAV');
  Done := FDone; Event := FEvent; FDone := nil; FEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
  General.Manager.OverlayPriority := 0;
  General.Manager.FDrawOverlay := True;
  MagicWin.Dlg.FDrawn := False;
end;

function TSpellBook.ValidateHero: Boolean;
begin
  if FActivation <> nil then
  begin
    FHero := THero(AoWHSMap.FUnitControl.FindUnit(FActivation.FUnitID));
    Result := (FHero <> nil) and not (usKilled in FHero.FUnitStatus);
  end
  else Result := True;
end;

procedure TSpellBook.PlayerChanged(Player: Shortint);
begin
  if Dlg.Visible and (Player = AoWHSMap.FSeatedPlayer) then
  begin UpdateSpellPages; UpdateInfoPages; end;
end;

procedure TSpellBook.UnitChanged(U: TAbstractUnit);
begin
  if Dlg.Visible and ((U = nil) or ((FMode in [0, 1]) and (U = FHero))) then
  begin UpdateSpellPages; UpdateInfoPages; end;
end;

procedure TSpellBook.Reset;
begin
  if FActivation <> nil then
  begin FActivation.Release; FActivation := nil; end;
  FSpells.Clear; FPage := 0; FHero := nil;
  ResearchPage.Visible := True; CastingPage.Visible := True;
  GlobalBtn.Visible := True;
  GlobalBtn.ILIndexDown := 17; GlobalBtn.ILIndexLit := 18; GlobalBtn.ILIndexUp := 16;
  CombatBtn.Visible := True; UnitBtn.Visible := True; InfoBtn.Visible := True;
  CurrentPointsLbl.Visible := True; CastingPointsMaxLbl.Visible := True; Line.Visible := True;
end;

procedure TSpellBook.SetPageKind(Kind: Byte);
begin
  FPageKind := Kind;
  LeftSpellPage.Visible := Kind = 1;
  RightSpellPage.Visible := Kind = 1;
  LeftInfoPage.Visible := Kind = 0;
  RightInfoPage.Visible := Kind = 0;
  case Kind of
    1: begin
      NextBtn.Visible := FSpells.GetCount - (FPage + 1) * 8 > 0;
      PrevBtn.Visible := FPage <> 0;
    end;
    0: begin NextBtn.Visible := False; PrevBtn.Visible := False; end;
  end;
end;

procedure TSpellBook.SelectSpell(Spell: TSpell);
var Reason: string;
begin
  if ValidateHero then
  begin
    case FMode of
    2, 3:
      if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.ResearchSpell(Spell.FSpellID) then
        if (FEvent = nil) or (FEvent.FMode <> pmemStartResearch) then
        begin FMode := 2; InfoBtnClick(Self); end
        else Dlg.Visible := False;
    0:
    begin
      if (FHero.GetCastingPoints >= Spell.FBaseManaCost) or
        AoWHSMap.FPlayers.GetPlayers(FHero.FPlayer).FMagicControl.GetCheatEnabled then
      begin
        if FHero.CastSpell(Spell.FSpellID, Reason) then Dlg.Visible := False
        else AoWHSMap.ShowWarning(Reason);
      end
      else
        if FHero.CastSpell(Spell.FSpellID, Reason) then InfoBtnClick(Self)
        else AoWHSMap.ShowWarning(Reason);
    end;
    1:
    begin
      if FHero.CastCombatSpell(Spell.FSpellID, Reason) then Dlg.Visible := False
      else AoWCombatMap.ShowWarning(Reason);
    end;
    end;
  end
  else Dlg.Visible := False;
end;

procedure TSpellBook.ShowResearch;
begin
  Reset;
  CastingPointsMaxLbl.Visible := False; CurrentPointsLbl.Visible := False; Line.Visible := False;
  GlobalBtn.ILIndexDown := 14; GlobalBtn.ILIndexLit := 15; GlobalBtn.ILIndexUp := 13;
  CombatBtn.Visible := False; UnitBtn.Visible := False;
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.FResearchSpellID <> 0 then
    SetPageKind(0) else SetPageKind(1);
  FMode := 2; FSpellType := stGlobal; FPage := 0;
  FHero := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FLeader;
  UpdateSpellPages; UpdateInfoPages; ShowBook;
end;

procedure TSpellBook.ShowResearchEvent(Event: TPlayerMagicEventLog; Done: TExecuteDoneEvent);
begin
  FEvent := Event; FEvent.AddRef; FDone := Done;
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.FResearchSpellID = 0 then
  begin
    Reset;
    GlobalBtn.ILIndexDown := 14; GlobalBtn.ILIndexLit := 15; GlobalBtn.ILIndexUp := 13;
    CombatBtn.Visible := False; UnitBtn.Visible := False;
    FResearchedSpell := 0; SetPageKind(1);
    FMode := 2; FSpellType := stGlobal; FPage := 0;
    FHero := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FLeader;
    UpdateSpellPages; UpdateInfoPages; ShowBook;
    AoWHSMap.FTutorialControl.ShowMessage(51, True, True);
  end
  else ShowResearch;
end;

procedure TSpellBook.ShowResearchedEvent(Event: TPlayerMagicEventLog; Done: TExecuteDoneEvent);
begin
  FEvent := Event; FEvent.AddRef; FDone := Done;
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.FResearchSpellID = 0 then
  begin
    Reset; FResearchedSpell := Event.FSpellID; SetPageKind(0);
    FMode := 3; FSpellType := stGlobal; FPage := 0;
    FHero := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FLeader;
    UpdateSpellPages; UpdateInfoPages; ShowBook;
  end
  else ShowResearch;
end;

procedure TSpellBook.ShowCasting(Activation: TActivateAbilityInfo);
begin
  Reset; FActivation := Activation; FActivation.AddRef; FMode := 0;
  if ValidateHero then
  begin
  FSpellType := TSpellType(FPlayerPages[AoWHSMap.FSeatedPlayer].A);
  FPage := FPlayerPages[AoWHSMap.FSeatedPlayer].B;
  if FHero.Casting then SetPageKind(0)
  else
  begin
    FSpells.Clear;
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.ListSpells(FSpells, [FSpellType]);
    if (FSpells.GetCount = 0) or (FSpells.GetCount <= FPage * 8) then
    begin
      FSpells.Clear; FSpellType := TSpellType(3);
      while (FSpells.GetCount = 0) and (Ord(FSpellType) <> 0) do
      begin
        Dec(FSpellType);
        AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.ListSpells(FSpells, [FSpellType]);
      end;
    end;
    SetPageKind(1);
  end;
  UpdateSpellPages; UpdateInfoPages; ShowBook;
  end
  else Reset;
end;

procedure TSpellBook.ShowCombatCasting(Activation: TActivateAbilityInfo);
begin
  Reset; FActivation := Activation; FActivation.AddRef; FMode := 1;
  if ValidateHero then
  begin
    GlobalBtn.Visible := True;
    if FHero.Casting then SetPageKind(0)
    else
    begin
      FSpells.Clear; FSpellType := TSpellType(3);
      while (FSpells.GetCount = 0) and (Ord(FSpellType) <> 0) do
      begin
        Dec(FSpellType);
        AoWHSMap.FPlayers.GetPlayers(AoWCombatMap.FSeatedPlayer).FMagicControl.ListSpells(FSpells, [FSpellType]);
      end;
      SetPageKind(1);
    end;
    FSpellType := stCombat; FPage := 0;
    UpdateSpellPages; UpdateInfoPages; ShowBook;
  end
  else Reset;
end;

procedure TSpellBook.UpdateSpellPages;
var I: Integer; Spell: TSpell;
begin
  if ValidateHero then
  begin
    case FMode of
    2, 3:
    begin
      FSpells.Clear;
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.ListResearchSpells(FSpells, [stCombat, stUnit, stGlobal]);
      FSpells.SortOnLevel;
      LeftHeader.Text := AoWE.Format(TranslateRStr(ResearchXSpellRStr), [TranslateRStr(TSpellTypeRStr[FSpellType])]);
      RightHeader.Text := AoWE.Format(TranslateRStr(ResearchXSpellRStr), [TranslateRStr(TSpellTypeRStr[FSpellType])]);
      LeftHeader.Text := TranslateRStr(ResearchSpellRStr); { Original overwrites the type-specific headers. }
      RightHeader.Text := TranslateRStr(ResearchSpellRStr);
    end;
0:
    begin
      FSpells.Clear;
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.ListSpells(FSpells, [FSpellType]);
      FSpells.SortOnLevel;
      LeftHeader.Text := AoWE.Format(TranslateRStr(CastXSpellRStr), [TranslateRStr(TSpellTypeRStr[FSpellType])]);
      RightHeader.Text := AoWE.Format(TranslateRStr(CastXSpellRStr), [TranslateRStr(TSpellTypeRStr[FSpellType])]);
    end;
    1:
    begin
      FSpells.Clear;
      AoWHSMap.FPlayers.GetPlayers(AoWCombatMap.FSeatedPlayer).FMagicControl.ListSpells(FSpells, [FSpellType]);
      FSpells.SortOnLevel;
      LeftHeader.Text := AoWE.Format(TranslateRStr(CastXSpellRStr), [TranslateRStr(TSpellTypeRStr[FSpellType])]);
      RightHeader.Text := AoWE.Format(TranslateRStr(CastXSpellRStr), [TranslateRStr(TSpellTypeRStr[FSpellType])]);
    end;
    end; for I := FSpells.GetCount - 1 downto 0 do
      if (FSpells.GetSpell(I).FSpellID >= 100) and (SpellTypes[FSpells.GetSpell(I).FSpellID] = fxNone) then FSpells.Delete(I);
    Spell := FSpells.GetSpell(FPage * 8); ShowSpellEntry(Spell, S1Pnl, S1Btn, S1Spell, S1Class, S1Cost, S1Memo, S1Icn);
    Spell := FSpells.GetSpell(FPage * 8 + 1); ShowSpellEntry(Spell, S2Pnl, S2Btn, S2Spell, S2Class, S2Cost, S2Memo, S2Icn);
    Spell := FSpells.GetSpell(FPage * 8 + 2); ShowSpellEntry(Spell, S3Pnl, S3Btn, S3Spell, S3Class, S3Cost, S3Memo, S3Icn);
    Spell := FSpells.GetSpell(FPage * 8 + 3); ShowSpellEntry(Spell, S4Pnl, S4Btn, S4Spell, S4Class, S4Cost, S4Memo, S4Icn);
    Spell := FSpells.GetSpell(FPage * 8 + 4); ShowSpellEntry(Spell, S5Pnl, S5Btn, S5Spell, S5Class, S5Cost, S5Memo, S5Icn);
    Spell := FSpells.GetSpell(FPage * 8 + 5); ShowSpellEntry(Spell, S6Pnl, S6Btn, S6Spell, S6Class, S6Cost, S6Memo, S6Icn);
    Spell := FSpells.GetSpell(FPage * 8 + 6); ShowSpellEntry(Spell, S7Pnl, S7Btn, S7Spell, S7Class, S7Cost, S7Memo, S7Icn);
    Spell := FSpells.GetSpell(FPage * 8 + 7); ShowSpellEntry(Spell, S8Pnl, S8Btn, S8Spell, S8Class, S8Cost, S8Memo, S8Icn);
    if FMode = 0 then
    begin
      FPlayerPages.Count := AoWHSMap.FSeatedPlayer + 1;
      FPlayerPages.List^[AoWHSMap.FSeatedPlayer].A := Ord(FSpellType);
      FPlayerPages.List^[AoWHSMap.FSeatedPlayer].B := FPage;
    end;
    if FPageKind = 1 then
    begin
      NextBtn.Visible := FSpells.GetCount - (FPage + 1) * 8 > 0;
      PrevBtn.Visible := FPage <> 0;
    end;
  end else Dlg.Visible := False;
end;

procedure TSpellBook.ShowSpellEntry(Spell: TSpell; Panel: TAOWPanel; Button: TAOWButton;
  Name, SpellClass, Cost: TAOWLabel; Memo: TAOWMemo; Icon: TAOWImage);
var Reason: string; Turns: Integer; Control: TPlayerMagicControl;
begin
  if Spell <> nil then

  begin
    Panel.Visible := True;
    Name.Text := Spell.FSpellName;
    SpellClass.Text := TranslateRStr(TMagicSphereRStr[Spell.FMagicSphere]) + ', ' +
      TranslateRStr(LevelRStr) + ' ' + IntToStr(Spell.FSpellLevel);
    if FMode = 2 then
    begin
      if Spell.FSpellControlTypes = [sctGlobal] then SpellClass.Text := SpellClass.Text + ', ' + TranslateRStr(GlobalRStr)
      else if Spell.FSpellControlTypes = [sctCombat] then SpellClass.Text := SpellClass.Text + ', ' + TranslateRStr(CombatRStr)
      else if Spell.FSpellControlTypes = [sctGlobal, sctCombat] then
        SpellClass.Text := SpellClass.Text + ', ' + TranslateRStr(GlobalRStr) + '/' + TranslateRStr(CombatRStr);
    end;
    Memo.Items := Spell.FSpellText;
    if FHero = nil then Cost.Text := AoWE.Format(TranslateRStr(CostXRStr), [Spell.FBaseManaCost])
    else Cost.Text := AoWE.Format(TranslateRStr(CostXRStr), [FHero.CastingMana(Spell)]);
    if ((FMode = 0) and (not (sctGlobal in Spell.FSpellControlTypes) or FHero.Casting)) or
      ((FMode = 1) and (not (sctCombat in Spell.FSpellControlTypes) or FHero.Casting or
      not FHero.CanCastSpellInstantly(Spell.FSpellID, Spell.FBaseManaCost, Reason))) or
      ((FMode = 2) and (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.FResearchSpellID <> 0)) then
    begin
      Memo.TextColor := $4C4C4C; Name.TextColor := $4C4C4C; SpellClass.TextColor := $4C4C4C; Cost.TextColor := $4C4C4C;
      Button.Visible := False; Icon.Tag := Icon.Tag or $10;
    end
    else
    begin
      Memo.TextColor := $13243C; Name.TextColor := $13243C; SpellClass.TextColor := $5A2734; Cost.TextColor := $5A2734;
      Button.Visible := True; Icon.Tag := Icon.Tag and $F;
    end;
    if Spell.FManaUpkeep > 0 then
      Cost.Text := Cost.Text + ' ' + AoWE.Format(TranslateRStr(UpkeepXRStr), [Spell.FManaUpkeep]);
    if FMode in [0, 1] then
    begin
      Turns := FHero.CastingTurns(Spell);
      if Turns = 0 then Reason := TranslateRStr(InstantRStr)
      else Reason := AoWE.Format(TranslateRStr(TurnsXRStr), [IntToStr(Turns)]);
      Cost.Text := Cost.Text + ' ' + Reason;
    end
    else if (FMode = 2) or (FMode = 3) then
    begin
      Control := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl;
      Turns := Control.ResearchTurns(Control.GetNetPowerToResearch, Spell.FResearchCost);
      if Turns < 999 then Cost.Text := Cost.Text + ' ' + AoWE.Format(TranslateRStr(TurnsXRStr), [IntToStr(Turns)])
      else Cost.Text := Cost.Text + ' ' + AoWE.Format(TranslateRStr(XTurnsRStr), ['?']);
    end;
  end else Panel.Visible := False;
end;

procedure TSpellBook.UpdateInfoPages;
var Player: Shortint; Leader: TLeader; I: Integer; Button: TAOWButton;
  Control: TPlayerMagicControl; Spell: TSpell;
begin
  if ValidateHero then
  begin
    if FMode = 1 then Player := AoWCombatMap.FSeatedPlayer else Player := AoWHSMap.FSeatedPlayer;
    Leader := AoWHSMap.FPlayers.GetPlayers(Player).FLeader;
    for I := 0 to 6 do
    begin
      case I of
        0: Button := Sel1; 1: Button := Sel2; 2: Button := Sel3; 3: Button := Sel4;
        4: Button := Sel5; 5: Button := Sel6; 6: Button := Sel7;
      else Button := nil; end;
      if I < Leader.GetSphereCount then
      begin
        Button.Visible := True;
        case Integer(Leader.GetSpheres(I)) and $7F of
          1: begin Button.ILIndexDown := 28; Button.ILIndexLit := 29; Button.ILIndexUp := 27; end;
          5: begin Button.ILIndexDown := 43; Button.ILIndexLit := 44; Button.ILIndexUp := 42; end;
          3: begin Button.ILIndexDown := 34; Button.ILIndexLit := 35; Button.ILIndexUp := 33; end;
          4: begin Button.ILIndexDown := 37; Button.ILIndexLit := 38; Button.ILIndexUp := 36; end;
          6: begin Button.ILIndexDown := 40; Button.ILIndexLit := 41; Button.ILIndexUp := 39; end;
          2: begin Button.ILIndexDown := 31; Button.ILIndexLit := 32; Button.ILIndexUp := 30; end;
        end;
      end
      else Button.Visible := False;
    end;
    NameLbl.Text := FHero.FHeroName;
    ManaPoolLbl.Text := TranslateRStr(ManaPoolRStr) + ': ' + IntToStr(AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FMana);
    CastingPointsLbl.Text := TranslateRStr(CastingPointsRStr) + ': ' + IntToStr(FHero.GetCastingPoints) + '/' + IntToStr(FHero.GetCastingPointsMax);
    ResearchManaPoolLbl.Text := ManaPoolLbl.Text;
    ResearchPointsLbl.Text := TranslateRStr(ResearchPointsRStr) + ': ' +
      IntToStr(AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.GetNetPowerToResearch);
    if FMode in [2, 3] then
    begin
      CurrentPointsLbl.Text := ''; CastingPointsMaxLbl.Text := '';
      SpellBookLbl.Visible := False; ResearchBookLbl.Visible := True; CastingPage.Visible := False;
      Control := AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl;
      if Control.FResearchSpellID <> 0 then
      begin
        ResearchPnl.Visible := True; ResearchNone.Visible := False;
        Spell := AoWHSSet.FSpellControl.GetSpell(Control.FResearchSpellID);
        ResearchLbl.Text := TranslateRStr(CurrentlyResearchingRStr) + ':';
        ResearchMemo.Items := Spell.FSpellText; ResearchName.Text := Spell.FSpellName;
        ResearchClass.Text := TranslateRStr(TMagicSphereRStr[Spell.FMagicSphere]) + ', ' +
          TranslateRStr(LevelRStr) + ' ' + IntToStr(Spell.FSpellLevel);
        ResearchCost.Text := TranslateRStr(CastingCostRStr) + ': ' + IntToStr(FHero.CastingMana(Spell)) + ' ' + TranslateRStr(ManaRStr);
        if Control.GetResearchTurnsLeft < 999 then
          ResearchStatus.Text := FmtTurnsLeftStr(Control.GetResearchTurnsLeft)
        else ResearchStatus.Text := AoWE.Format(TranslateRStr(XTurnsRStr), ['?']);
        CancelResearchBtn.Text := TranslateRStr(CancelRStr);
        ResearchStatus.Visible := True;
      end
      else
      begin
        if FMode = 3 then
        begin
          ResearchPnl.Visible := True; ResearchNone.Visible := False;
          Spell := AoWHSSet.FSpellControl.GetSpell(FResearchedSpell);
          ResearchLbl.Text := TranslateRStr(ResearchedRStr) + ':';
          ResearchMemo.Items := Spell.FSpellText;
          ResearchName.Text := Spell.FSpellName;
          ResearchClass.Text := TranslateRStr(TMagicSphereRStr[Spell.FMagicSphere]) + ', ' +
            TranslateRStr(LevelRStr) + ' ' + IntToStr(Spell.FSpellLevel);
          ResearchCost.Text := TranslateRStr(CastingCostRStr) + ': ' + IntToStr(Spell.FBaseManaCost) + ' ' + TranslateRStr(ManaRStr);
          ResearchStatus.Visible := False;
          CancelResearchBtn.Text := TranslateRStr(ResearchRStr);
          CancelResearchBtn.ToolTipText.Text := TranslateRStr(ResearchNewSpellRStr);
        end
        else
        begin
          ResearchPnl.Visible := False; ResearchNone.Visible := True;
          CancelResearchBtn.Text := TranslateRStr(ResearchRStr);
          CancelResearchBtn.ToolTipText.Text := TranslateRStr(CancelSpellResearchRStr);
        end;
      end;
    end
    else if FMode in [0, 1] then
    begin
      CurrentPointsLbl.Text := IntToStr(FHero.GetCastingPoints);
      CastingPointsMaxLbl.Text := IntToStr(FHero.GetCastingPointsMax);
      SpellBookLbl.Visible := True; ResearchBookLbl.Visible := False; ResearchPage.Visible := False;
      if FHero.Casting then
      begin
        NoneCastingLbl.Visible := False;
        Spell := AoWHSSet.FSpellControl.GetSpell(FHero.FCastingSpellID);
        CastingSpell.Text := Spell.FSpellName;
        CastingClass.Text := TranslateRStr(TMagicSphereRStr[Spell.FMagicSphere]) + ', ' +
          TranslateRStr(LevelRStr) + ' ' + IntToStr(Spell.FSpellLevel);
        CastingCost.Text := TranslateRStr(CastingCostRStr) + ': ' + IntToStr(FHero.FCastingProgress) + ' ' + TranslateRStr(ManaRStr);
        CastingMemo.Items := Spell.FSpellText;
        CastingStatus.Text := '(' + FmtTurnsLeftStr(FHero.CastingTurnsLeft) + ')';
        CastingPnl.Visible := True;
        if FHero.CastingReady then
        begin CastingBtn.Visible := True; CastingStatus.Text := TranslateRStr(CastingReadyRStr); end
        else
        begin
          CastingBtn.Visible := False;
          CastingStatus.Text := '(' + FmtTurnsLeftStr(FHero.CastingTurnsLeft) + ')';
        end;
      end
      else
      begin CastingPnl.Visible := False; NoneCastingLbl.Visible := True; end;
    end else begin CastingPnl.Visible := False; NoneCastingLbl.Visible := True; end;
  end;
end;

end.
