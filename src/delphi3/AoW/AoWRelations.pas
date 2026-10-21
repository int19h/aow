unit AoWRelations;

{ Partly recovered AoWRelations handlers, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Any remaining stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWComp, AoWButton, AoWCheckBox, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TRelWindow = class;


  { TRelWindow (size $2A8, VMT 00423988): $280 diplomatic actions, $288 player indices, $28C race indices, $290 controls. }
  TRelWindow = class(TDataModule)
  public
    published
    RelWin: TAOWWindow; { +0044 }
    RShield: TAOWImage; { +0048 }
    LShield: TAOWImage; { +004C }
    MExitBtn: TAOWButton; { +0050 }
    RelPnl: TAOWPanel; { +0054 }
    RIncomingPnl: TAOWPanel; { +0058 }
    MAcceptBtn: TAOWButton; { +005C }
    MRejectBtn: TAOWButton; { +0060 }
    MScroll: TAOWVScrollBar; { +0064 }
    P1I: TAOWImage; { +0068 }
    P2I: TAOWImage; { +006C }
    P3I: TAOWImage; { +0070 }
    P4I: TAOWImage; { +0074 }
    P5I: TAOWImage; { +0078 }
    P6I: TAOWImage; { +007C }
    P7I: TAOWImage; { +0080 }
    P8I: TAOWImage; { +0084 }
    P9I: TAOWImage; { +0088 }
    P10I: TAOWImage; { +008C }
    P11I: TAOWImage; { +0090 }
    P12I: TAOWImage; { +0094 }
    R1I: TAOWImage; { +0098 }
    R2I: TAOWImage; { +009C }
    R3I: TAOWImage; { +00A0 }
    R4I: TAOWImage; { +00A4 }
    R5I: TAOWImage; { +00A8 }
    R6I: TAOWImage; { +00AC }
    R7I: TAOWImage; { +00B0 }
    R8I: TAOWImage; { +00B4 }
    R9I: TAOWImage; { +00B8 }
    R10I: TAOWImage; { +00BC }
    R11I: TAOWImage; { +00C0 }
    R12I: TAOWImage; { +00C4 }
    FaceShadow: TAOWImage; { +00C8 }
    MMemo: TAOWMemo; { +00CC }
    MBGoldLbl: TAOWLabel; { +00D0 }
    MIcon: TAOWImage; { +00D4 }
    RMsgEditPnl: TAOWPanel; { +00D8 }
    RSBribePnl: TAOWPanel; { +00DC }
    SScroll: TAOWVScrollBar; { +00E0 }
    SMemo: TAOWMemo; { +00E4 }
    SBGoldSlid: TAOWHScrollBar; { +00E8 }
    ActionPnl: TAOWPanel; { +00EC }
    LInfoPlayerPnl: TAOWPanel; { +00F0 }
    RNewActionPnl: TAOWPanel; { +00F4 }
    AExit: TAOWButton; { +00F8 }
    APlayer: TAOWLabel; { +00FC }
    LInfoRacePnl: TAOWPanel; { +0100 }
    ARace2: TAOWLabel; { +0104 }
    AAlignment: TAOWImage; { +0108 }
    AAlignmentLbl: TAOWLabel; { +010C }
    P1CB: TAOWCheckBox; { +0110 }
    P2CB: TAOWCheckBox; { +0114 }
    P3CB: TAOWCheckBox; { +0118 }
    P4CB: TAOWCheckBox; { +011C }
    P5CB: TAOWCheckBox; { +0120 }
    P6CB: TAOWCheckBox; { +0124 }
    P7CB: TAOWCheckBox; { +0128 }
    P8CB: TAOWCheckBox; { +012C }
    P9CB: TAOWCheckBox; { +0130 }
    P10CB: TAOWCheckBox; { +0134 }
    P11CB: TAOWCheckBox; { +0138 }
    P12CB: TAOWCheckBox; { +013C }
    FaceFr: TAOWImage; { +0140 }
    R1CB: TAOWCheckBox; { +0144 }
    R2CB: TAOWCheckBox; { +0148 }
    R3CB: TAOWCheckBox; { +014C }
    R4CB: TAOWCheckBox; { +0150 }
    R5CB: TAOWCheckBox; { +0154 }
    R6CB: TAOWCheckBox; { +0158 }
    R7CB: TAOWCheckBox; { +015C }
    R8CB: TAOWCheckBox; { +0160 }
    R9CB: TAOWCheckBox; { +0164 }
    R10CB: TAOWCheckBox; { +0168 }
    R11CB: TAOWCheckBox; { +016C }
    R12CB: TAOWCheckBox; { +0170 }
    PlyrGlow: TAOWImage; { +0174 }
    NoContact: TAOWLabel; { +0178 }
    ASelect: TAOWButton; { +017C }
    ActionsLB: TAOWListBox; { +0180 }
    ActionSB: TAOWVScrollBar; { +0184 }
    LBActionsPnl: TAOWPanel; { +0188 }
    ActionLbl: TAOWLabel; { +018C }
    PIRelIcn: TAOWImage; { +0190 }
    PIRelLbl: TAOWLabel; { +0194 }
    PIRelPnl: TAOWPanel; { +0198 }
    PIRelV: TAOWLabel; { +019C }
    APlyrIcon: TAOWImage; { +01A0 }
    APlyrType: TAOWLabel; { +01A4 }
    PlStatIcn: TAOWImage; { +01A8 }
    PlStatLbl: TAOWLabel; { +01AC }
    PIStatPnl: TAOWPanel; { +01B0 }
    PlStatV: TAOWLabel; { +01B4 }
    PTypePnl: TAOWPanel; { +01B8 }
    PIFrame: TAOWPanel; { +01BC }
    RIFrame: TAOWPanel; { +01C0 }
    RIRelPnl: TAOWPanel; { +01C4 }
    RAlignPnl: TAOWPanel; { +01C8 }
    RlRelIcn: TAOWImage; { +01CC }
    RIRelLbl: TAOWLabel; { +01D0 }
    RlRelV: TAOWLabel; { +01D4 }
    MBGoldBribeV: TAOWLabel; { +01D8 }
    MBGoldIcn: TAOWImage; { +01DC }
    MBGoldPnl: TAOWPanel; { +01E0 }
    MBManaPnl: TAOWPanel; { +01E4 }
    MBManaLbl: TAOWLabel; { +01E8 }
    MBManaBribeV: TAOWLabel; { +01EC }
    MBManaIcn: TAOWImage; { +01F0 }
    MsgLbl: TAOWLabel; { +01F4 }
    MsgSendBtn: TAOWButton; { +01F8 }
    MsgCancelBtn: TAOWButton; { +01FC }
    RSBribe2: TAoWFrame; { +0200 }
    SBGoldV: TAOWLabel; { +0204 }
    SBGoldIcn: TAOWImage; { +0208 }
    SBGold: TAOWPanel; { +020C }
    SBMana: TAOWPanel; { +0210 }
    SBManaV: TAOWLabel; { +0214 }
    SBManaIcn: TAOWImage; { +0218 }
    RSBSep1: TAoWFrame; { +021C }
    SBribeBtn: TAOWLabel; { +0220 }
    SBManaSlid: TAOWHScrollBar; { +0224 }
    SBIcon: TAOWImage; { +0228 }
    RSBSendBtn: TAOWButton; { +022C }
    RBSCanlBtn: TAOWButton; { +0230 }
    StatusGlow: TAOWImage; { +0234 }
    BribeHeaderLbl: TAOWLabel; { +0238 }
    RMsgRecPnl: TAOWPanel; { +023C }
    RMMemo: TAOWMemo; { +0240 }
    RMHeaderLbl: TAOWLabel; { +0244 }
    RMReplyBtn: TAOWButton; { +0248 }
    RMCancelBtn: TAOWButton; { +024C }
    RMExitBtn: TAOWButton; { +0250 }
    IncommingInfoPnl: TAOWPanel; { +0254 }
    IIOkBtn: TAOWButton; { +0258 }
    IIExitBtn: TAOWButton; { +025C }
    IRScroll: TAOWVScrollBar; { +0260 }
    IIMemo: TAOWMemo; { +0264 }
    IIIcon: TAOWImage; { +0268 }
    Translator: TIvTranslator; { +026C }
    OfTheLbl: TAOWLabel; { +0270 }
    PRaceLbl: TAOWLabel; { +0274 }
    public
    FSelectedIndex: Integer; { $278 }
    FAction: TDiplomaticAction; { $27C }
    FActions: TDiplomaticActionList; { $280 }
    F_RelWindow_284: array[0..1] of Byte;
    FSelectedPlayer: Shortint; { $286 }
    FSelectedRace: Shortint; { $287 }
    FPlayers: TIntegerList; { $288 }
    FRaces: TIntegerList; { $28C }
    FControls: TList; { $290 }
    FDone: TExecuteDoneEvent; { $294 }
    FEvent: TDiplomaticActionEventLog; { $29C }
    FGlowIntensity: Integer; { $2A0 }
    FGlowIncreasing: Boolean; { $2A4 }
    F_RelWindow_2A5: array[0..2] of Byte;
    procedure SetAction(Action: TDiplomaticAction);
    procedure FinishEvent;
    procedure FinishDialog;
    procedure ClearActions;
    procedure RelWindowCreate;  { draft }
    procedure RelWindowDestroy;  { draft }
    procedure ExitClick;  { draft }
    procedure P1CBChange(A1: Integer);  { draft }
    procedure R1CBChange(A1: Integer);  { draft }
    procedure P1CBPreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
    procedure R1CBPreDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure P1IDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure R1IDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
    procedure MAcceptBtnClick;  { draft }
    procedure MRejectBtnClick;  { draft }
    procedure PlyrGlowUpdate;  { draft }
    procedure PlyrGlowDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure FaceFrPreDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure SBGoldSlidChange(Sender: TObject);  { draft }
    procedure SBManaSlidChange(Sender: TObject);  { draft }
    procedure RelWinHide;  { draft }
    procedure ASelectClick;  { draft }
    procedure ActionsLBChange(Sender: TObject);  { draft }
    procedure CancelSelectedAction;  { draft }
    procedure ChangeActionMessage(Sender: TAOWMemo);
    procedure MsgSendActionBtn;  { draft }
    procedure ReplyBtnClick;  { draft }
    procedure RMCancelBtnClick;  { draft }
    procedure IIOkBtnClick;  { draft }
    procedure RelWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses AoWWinMan, aowIntGfxMod, E3Globals;

procedure TRelWindow.SetAction(Action: TDiplomaticAction);
begin
  if Action <> FAction then
  begin
    if FAction <> nil then FAction.Release;
    FAction := Action;
    if FAction <> nil then FAction.AddRef;
  end;
end;

procedure TRelWindow.FinishEvent;
var
  Event: TDiplomaticActionEventLog;
  Done: TExecuteDoneEvent;
begin
  Event := FEvent;
  if Event <> nil then
  begin
    Done := FDone;
    FDone := nil;
    FEvent := nil;
    if Assigned(Done) then Done(Event);
    if Event <> nil then Event.Release;
  end;
end;

procedure TRelWindow.FinishDialog;
begin
  SetAction(nil);
  General.Manager.OverlayPriority := 0;
  FinishEvent;
  AoWHSMap.FTutorialControl.ShowMessage(71, True, True);
end;

procedure TRelWindow.ClearActions;
begin
  SetAction(nil);
  RNewActionPnl.Visible := True;
  RIncomingPnl.Visible := False;
  RMsgEditPnl.Visible := False;
  RSBribePnl.Visible := False;
  RMsgRecPnl.Visible := False;
  IncommingInfoPnl.Visible := False;
  FActions.Clear;
  ActionsLB.Items.Clear;
  SMemo.Items.Clear;
  MMemo.Items.Clear;
  ActionsLBChange(Self);
end;

procedure TRelWindow.RelWindowCreate;
begin
  FActions := TDiplomaticActionList.Create(nil);
  FRaces := TIntegerList.Create;
  FPlayers := TIntegerList.Create;
  FControls := TList.Create;
  FControls.Add(P1I);
  FControls.Add(P2I);
  FControls.Add(P3I);
  FControls.Add(P4I);
  FControls.Add(P5I);
  FControls.Add(P6I);
  FControls.Add(P7I);
  FControls.Add(P8I);
  FControls.Add(P9I);
  FControls.Add(P10I);
  FControls.Add(P11I);
  FControls.Add(P12I);
  FControls.Add(R1I);
  FControls.Add(R2I);
  FControls.Add(R3I);
  FControls.Add(R4I);
  FControls.Add(R5I);
  FControls.Add(R6I);
  FControls.Add(R7I);
  FControls.Add(R8I);
  FControls.Add(R9I);
  FControls.Add(R10I);
  FControls.Add(R11I);
  FControls.Add(R12I);
  FControls.Add(P1CB);
  FControls.Add(P2CB);
  FControls.Add(P3CB);
  FControls.Add(P4CB);
  FControls.Add(P5CB);
  FControls.Add(P6CB);
  FControls.Add(P7CB);
  FControls.Add(P8CB);
  FControls.Add(P9CB);
  FControls.Add(P10CB);
  FControls.Add(P11CB);
  FControls.Add(P12CB);
  FControls.Add(R1CB);
  FControls.Add(R2CB);
  FControls.Add(R3CB);
  FControls.Add(R4CB);
  FControls.Add(R5CB);
  FControls.Add(R6CB);
  FControls.Add(R7CB);
  FControls.Add(R8CB);
  FControls.Add(R9CB);
  FControls.Add(R10CB);
  FControls.Add(R11CB);
  FControls.Add(R12CB);
end;

procedure TRelWindow.RelWindowDestroy;
begin
  FActions.Free;
  FControls.Free;
  FPlayers.Free;
  FRaces.Free;
end;

procedure TRelWindow.ExitClick;
begin
  General.PlayButtonSound(0);
  RelWin.Visible := False;
end;

procedure TRelWindow.P1CBChange(A1: Integer);
begin end;

procedure TRelWindow.R1CBChange(A1: Integer);
begin end;

procedure TRelWindow.P1CBPreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
var
  Player: Shortint;
  R: TRect;
begin
  with Sender do
    if Tag < FPlayers.Count then
    begin
      Player := FPlayers[Tag];
      if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetFirstDaySeen(Player) <> -1 then
      begin
        R := Rect(WinLeft + 1, WinTop + 1, WinLeft + WinWidth - 1, WinTop + WinHeight - 1);
        if AoWHSMap.FPlayers.GetPlayers(Player).GetFace <> nil then
          AoWHSMap.FPlayers.GetPlayers(Player).GetFace.ShowStretched(R, Surface);
      end
      else IntGfxMod.RelWin[28].ShowClipped(WinLeft, WinTop, Surface);
      IntGfxMod.RelWin[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace + 16].ShowClipped(WinLeft, WinTop, Surface);
    end;
end;

procedure TRelWindow.R1CBPreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  Control: TAoWComponent;
  Race: Shortint;
  R: TRect;
  Action: TDiplomaticAction;
  Modifier: Integer;
begin
  Control := TAoWComponent(Sender);
  with Control do
    if Tag - 20 < FRaces.Count then
    begin
      Race := FRaces[Tag - 20];
      R := Rect(WinLeft + 1, WinTop + 1, WinLeft + WinWidth - 1, WinTop + WinHeight - 1);
      AoWHSSet.FRaceResources.GetRaceResource(Race).GetFace.ShowStretched(R, Surface);
      Action := FAction;
      if (Action = nil) and RNewActionPnl.Visible and (ActionsLB.Selected <> -1) then
        Action := TDiplomaticAction(ActionsLB.Items.Objects[ActionsLB.Selected]);
      if Action <> nil then
      begin
        Modifier := Action.GetRelationModifier(AoWHSMap.FSeatedPlayer, Race);
        if Modifier <> 0 then
        begin
          FontModule.Age10.Color := $FFFFFF;
          FontModule.Age10.SetTextCentered(R.Left + (R.Right - R.Left) div 2, R.Top + 50, IntToStr(Modifier), Surface);
        end;
      end;
    end;
end;

procedure TRelWindow.P1IDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  Player: Shortint;
  Relation: TDiplomaticRelation;
  Image: Integer;
begin
  with TAoWComponent(Sender) do
    if (Tag < FPlayers.Count) and (Tag <> FSelectedIndex) then
    begin
      Player := FPlayers[Tag];
      if FSelectedPlayer = -1 then
      begin
        if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetFirstDaySeen(Player) <> -1 then
          IntGfxMod.RelWin[Ord(AoWHSMap.FRaces.GetRace(FSelectedRace).GetPlayerRelation(Player)) + 11].ShowClipped(WinLeft, WinTop + 8, Surface);
      end
      else if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetFirstDaySeen(FSelectedPlayer) <> -1 then
        if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetFirstDaySeen(Player) <> -1 then
          if AoWHSMap.FPlayers.GetPlayers(FSelectedPlayer).GetFirstDaySeen(Player) <> -1 then
          begin
            Relation := AoWHSMap.FPlayers.GetDiplomaticRelation(FSelectedPlayer, Player);
            if Relation = drUnknown then Image := 50 else Image := Ord(Relation) + 8;
            IntGfxMod.RelWin[Image].Show(WinLeft, WinTop + 8, Surface);
          end;
    end;
end;

procedure TRelWindow.R1IDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
begin
  with Sender do
    if (FSelectedPlayer <> -1) and (Tag - 20 < FRaces.Count) then
      if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetFirstDaySeen(FSelectedPlayer) <> -1 then
        IntGfxMod.RelWin[Ord(AoWHSMap.FRaces.GetRace(FRaces[Tag - 20]).GetPlayerRelation(FSelectedPlayer)) + 11].ShowClipped(WinLeft, WinTop + 15, Surface);
end;

procedure TRelWindow.MAcceptBtnClick;
begin end;

procedure TRelWindow.MRejectBtnClick;
begin end;

procedure TRelWindow.PlyrGlowUpdate;
begin
  if FGlowIncreasing then Inc(FGlowIntensity) else Dec(FGlowIntensity);
  if FGlowIntensity = 20 then FGlowIncreasing := True
  else if FGlowIntensity = 50 then FGlowIncreasing := False;
  PlyrGlow.FDrawn := False;
end;

procedure TRelWindow.PlyrGlowDraw(Sender: TObject; Surface: TSurfaceDesc);
begin
  IntGfxMod.RelWin[44].ShowBlended(PlyrGlow.WinLeft, PlyrGlow.WinTop, Surface, IntensityBlendTable.LookupTables[FGlowIntensity]);
end;

procedure TRelWindow.FaceFrPreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  with FaceFr do R := Rect(WinLeft + 1, WinTop, WinLeft + WinWidth, WinTop + WinHeight);
  if FAction <> nil then
  begin
    if (FEvent <> nil) and (FEvent.FAction.FActionType = daSendMessageAsY) then
      AoWHSMap.FPlayers.GetPlayers(FEvent.FAction.FOtherPlayer).FLeader.ShowFace(R, Surface)
    else if FAction.FSource = AoWHSMap.FSeatedPlayer then
      AoWHSMap.FPlayers.GetPlayers(FAction.FTarget).FLeader.ShowFace(R, Surface)
    else if FAction.FReaction = darNone then
      AoWHSMap.FPlayers.GetPlayers(FAction.FSource).FLeader.ShowFace(R, Surface)
    else AoWHSMap.FPlayers.GetPlayers(FAction.FTarget).FLeader.ShowFace(R, Surface);
  end
  else if FSelectedPlayer = -1 then
    AoWHSSet.FRaceResources.GetRaceResource(FSelectedRace).GetFace.Show(FaceFr.WinLeft + 1, FaceFr.WinTop + 3, Surface)
  else if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetFirstDaySeen(FSelectedPlayer) <> -1 then
    AoWHSMap.FPlayers.GetPlayers(FSelectedPlayer).FLeader.ShowFace(R, Surface);
end;

procedure TRelWindow.SBGoldSlidChange(Sender: TObject);
begin
  if FAction <> nil then FAction.FGold := SBGoldSlid.Position;
  SBGoldV.Text := IntToStr(SBGoldSlid.Position);
end;

procedure TRelWindow.SBManaSlidChange(Sender: TObject);
begin
  if FAction <> nil then FAction.FMana := SBManaSlid.Position;
  SBManaV.Text := IntToStr(SBManaSlid.Position);
end;

procedure TRelWindow.RelWinHide;
begin
  FinishDialog;
end;

procedure TRelWindow.ASelectClick;
var
  Reason: string;
begin
  if ActionsLB.Selected <> -1 then
  begin
    SetAction(TDiplomaticAction(ActionsLB.Items.Objects[ActionsLB.Selected]));
    case FAction.FActionType of
      daDeclareWar, daThreatenToAttack, daBreakAlliance:
        if not FAction.Send(Reason) then AoWHSMap.ShowMessage(Reason);
      daOfferPeace, daProposeAlliance, daMakeTribute, daBreakAllianceWithY, daDeclareWarToY:
      begin
        RNewActionPnl.Visible := False;
        SBIcon.Visible := True;
        RSBribePnl.Visible := True;
        SBGoldSlid.Position := 0;
        SBManaSlid.Position := 0;
        SBGoldSlid.Max := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGems;
        SBManaSlid.Max := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FMagicControl.FMana;
        SBManaSlidChange(nil);
        SBGoldSlidChange(nil);
        BribeHeaderLbl.Text := FAction.GetName(AoWHSMap.FSeatedPlayer);
        case FAction.FActionType of
          daOfferPeace: SBIcon.CurrentImage := 8;
          daProposeAlliance: SBIcon.CurrentImage := 10;
          daMakeTribute: SBIcon.CurrentImage := 48;
          daDeclareWarToY: SBIcon.CurrentImage := 47;
          daBreakAllianceWithY: SBIcon.CurrentImage := 47;
        else SBIcon.Visible := False;
        end;
      end;
      daSendMessage, daSendMessageAsY:
      begin
        RNewActionPnl.Visible := False;
        RMsgEditPnl.Visible := True;
      end;
    end;
  end;
end;

procedure TRelWindow.ActionsLBChange(Sender: TObject);
begin
  RelPnl.FDrawn := False;
  if ActionsLB.Selected <> -1 then
  begin
    ASelect.ILIndexDown := 37;
    ASelect.ILIndexLit := 40;
    ASelect.ILIndexUp := 34;
  end
  else
  begin
    ASelect.ILIndexDown := 46;
    ASelect.ILIndexLit := 49;
    ASelect.ILIndexUp := 43;
  end;
end;

procedure TRelWindow.CancelSelectedAction;
begin end;

procedure TRelWindow.ChangeActionMessage(Sender: TAOWMemo);
begin
  if FAction <> nil then FAction.FMessage.Text := Sender.Items.Text;
end;

procedure TRelWindow.MsgSendActionBtn;
begin end;

procedure TRelWindow.ReplyBtnClick;
begin end;

procedure TRelWindow.RMCancelBtnClick;
begin end;

procedure TRelWindow.IIOkBtnClick;
begin end;

procedure TRelWindow.RelWinKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then RelWin.Visible := False;
end;


end.
