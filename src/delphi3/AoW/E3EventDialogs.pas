unit E3EventDialogs;

{ Event-log dialog routines called by TMapEvents in AoW.exe. }
interface
uses Classes, SysUtils, AoWE, EventLog, FastCombatWin, AoWRelations,
  E2Globals, AoWWorldMap, AoWSMTPDlg, TCFCDlg, AoWNewTurnDialog, aowHelpWin, AoWSendEmailGameDlg, AoWPasswordDlg, AoWArmyEventDlg, AoWCityRebelDlg, AoWCityJoinDlg, AoWPartyJoin, AoWHeroJoinDlg, AoWMsgReceiveDlg, AoWTutorialWin, AoWHeroUpgradeDlg, AoWHeroInfoDlg, AoWWizardsTowerDlg, AoWArenaDlg, AoWItemsFoundDlg;

procedure ShowCombatEvent(Dialog: TFastCombatWindow; Event: TCombatEventLog; Done: TExecuteDoneEvent);
procedure ShowDiplomaticEvent(Dialog: TRelWindow; Event: TDiplomaticActionEventLog; Done: TExecuteDoneEvent);
procedure ShowInformationBook(Dialog: TWorldMap; Event: TShowBookEventLog; Done: TExecuteDoneEvent);
procedure ShowCombatType(Dialog: TTCFCDialog; Event: TCombatTypeRequestEventLog; Done: TExecuteDoneEvent);
procedure ShowSMTPEvent(Dialog: TSMTPDlg; Event: TSMTPEventLog; Done: TExecuteDoneEvent);
var
  HelpWindow: THelpWindow absolute aowHelpWin.HelpWindow; { $45B04C } SendEmailGameDlg: TSendEmailGameDlg; PasswordDlg: TPasswordDlg;
  ArmyEventDlg: TArmyEventDlg;
  CityRebelDlg: TCityRebelDlg;
  CityJoinDlg: TCityJoinDlg;
  PartyJoinDlg: TPartyJoinDlg;
  HeroJoinDlg: THeroJoinDlg;
  MsgReceiveDlg: TMsgReceiveDlg;
  TutorialWindow: TTutorialWindow absolute E2Globals.TutorialWindow; { $45B278 }
  HeroUpgradeDlg: THeroUpgradeDlg;
  HeroInfoDlg: THeroInfoDlg;
  WizardsTowerDlg: TWizardsTowerDlg;
  ArenaDlg: TArenaDlg;
  ItemsFoundDlg: TItemsFoundDlg;
  FastCombatWindow: TFastCombatWindow; { $45B1B0 }
  NewTurnDlg: TNewTurnDlg; { $45B1E8 }
  TCFCDialog: TTCFCDialog; { $45B1F0 }

implementation
uses AoWWinMan, E3Globals, AoWComp, AoWButton, AoWImage;
procedure InitializeCombatDialog(Dialog: TFastCombatWindow; Logbook: TCombatLogbook);
var
  RaceIndex, PartyRace: Integer;
  PlayerIndex: Shortint;
  Combat: TCombat;
  Party: TCombatParty;
  Image: TAOWImage;
  I: Integer;
begin
  with Dialog do
  begin
    FViewer.Initialize(Logbook);
    Combat := FViewer.FCombat;
    FAnimationFrame := 0;
    for I := 0 to 7 do
    begin
      case I of
        0: Image := Party1Bg;
        1: Image := Party2Bg;
        2: Image := Party3Bg;
        3: Image := Party4Bg;
        4: Image := Party5Bg;
        5: Image := Party6Bg;
        6: Image := Party7Bg;
        7: Image := Party2Bg; { Original reuses the second background for the eighth party. }
      else Image := nil;
      end;
      Party := Combat.FCombatData.FParties.GetParty(I);
      if Party <> nil then
      begin
        PlayerIndex := Combat.FCombatData.FPlayers.GetPlayers(Party.FPlayerIndex).FPlayer;
        if PlayerIndex <> 0 then PartyRace := AoWHSMap.FPlayers.GetPlayers(PlayerIndex).FPlayerRace
        else PartyRace := 12;
        Image.CurrentImage := PartyRace + 21;
        Image.Visible := True;
      end
      else if I <> 7 then Image.Visible := False;
      { Original refreshes both side labels inside the party loop. }
      if Combat.FCombatData.FPlayers.GetPlayers(Combat.FCombatData.FAttackerPlayer).FPlayer = 0 then
        LSideLbl.Text := TranslateRStr(IndependentsRStr)
      else
      begin
        RaceIndex := AoWHSMap.FPlayers.GetPlayers(Combat.FCombatData.FPlayers.GetPlayers(Combat.FCombatData.FAttackerPlayer).FPlayer).FPlayerRace;
        LSideLbl.Text := AoWHSSet.FRaceResources.GetRaceResource(RaceIndex).FRaceName;
      end;
      if Combat.FCombatData.FPlayers.GetPlayers(Combat.FCombatData.FDefenderPlayer).FPlayer = 0 then
        RSideLbl.Text := TranslateRStr(IndependentsRStr)
      else
      begin
        RaceIndex := AoWHSMap.FPlayers.GetPlayers(Combat.FCombatData.FPlayers.GetPlayers(Combat.FCombatData.FDefenderPlayer).FPlayer).FPlayerRace;
        RSideLbl.Text := AoWHSSet.FRaceResources.GetRaceResource(RaceIndex).FRaceName;
      end;
    end;
    FViewer.Play;
    FCWin.FDrawn := False;
    SequencePositionSld.Max := FViewer.GetEndPosition;
    SequenceSpeedSld.Position := 20 - FViewer.FDelay;
    if FViewer.GetEndPosition <> -1 then SetPhase(0) else SetPhase(3);
  end;
end;

procedure ShowCombatEvent(Dialog: TFastCombatWindow; Event: TCombatEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin





























































    Assert(FEvent = nil);
    General.Manager.OverlayPriority := 49;
    FEvent := Event; FEvent.AddRef;
    FDone := Done;
    FLogbook := Event.FLogbook;
    InitializeCombatDialog(Dialog, FLogbook);
    FCWin.Visible := True;
  end;
end;

procedure ShowCombatType(Dialog: TTCFCDialog; Event: TCombatTypeRequestEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
    if E3Globals.DialogWin.FSkipCombatChoice then
    begin
      if TCchk.Checked then Event.Select(TCombatType(2)) else Event.Select(TCombatType(1));
      Done(Event);
    end
    else
    begin
      FRequest := Event; FRequest.AddRef;
      FOnDone := TNotifyEvent(Done);
      General.Manager.OverlayPriority := 49;
      if TCchk.Checked then Event.Select(TCombatType(2)) else Event.Select(TCombatType(1));
      if AoWHSMap.FPlayers.GetPlayers(FRequest.FPlayer).FPlayerType = ptHuman then
      begin CancelBtn.Visible := True; FightBtn.Alignment.AlignWidth := awLeft; end
      else
      begin CancelBtn.Visible := False; FightBtn.Alignment.AlignWidth := awCenter; end;
      Dlg.ReAlign;
      Dlg.Visible := True;
      AoWHSMap.FTutorialControl.ShowMessage(61, True, True);
    end;
end;

procedure ShowDiplomaticEvent(Dialog: TRelWindow; Event: TDiplomaticActionEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    ClearActions;
    ResetChecks;
















































































































































































































































































































































































































































































    Assert(FEvent = nil);
    FDone := Done;
    with Event do begin FEvent := Event; AddRef; end;
    if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FStatus = psPlaying then
    begin
      ShowRelations(Event.FAction.FTarget);
      SetAction(Event.FAction);
      case FAction.FActionType of
        daSendMessage:
          begin
            HighlightPlayer(FAction.FSource); ShowPlayerInformation(FAction.FSource);
            RNewActionPnl.Visible := False; RMsgRecPnl.Visible := True;
            RMMemo.Items.Text := FAction.FMessage.Text;
            RMHeaderLbl.Text := AoWE.Format(TranslateRStr(MessageFromXRStr),
              [AoWHSMap.FPlayers.GetPlayers(FAction.FSource).GetName]);
          end;
        daSendMessageAsY:
          begin
            HighlightPlayer(FAction.FOtherPlayer); ShowPlayerInformation(FAction.FOtherPlayer);
            RNewActionPnl.Visible := False; RMsgRecPnl.Visible := True;
            RMMemo.Items.Text := FAction.FMessage.Text;
            RMHeaderLbl.Text := AoWE.Format(TranslateRStr(MessageFromXRStr),
              [AoWHSMap.FPlayers.GetPlayers(FAction.FOtherPlayer).GetName]);
          end;
        daOfferPeace, daProposeAlliance, daMakeTribute, daBreakAllianceWithY, daDeclareWarToY:
          begin
            RNewActionPnl.Visible := False;
            if FAction.FReaction = darNone then
            begin
              HighlightPlayer(FAction.FSource); ShowPlayerInformation(FAction.FSource);
              RIncomingPnl.Visible := True;
              MBGoldBribeV.Text := IntToStr(FAction.FGold); MBManaBribeV.Text := IntToStr(FAction.FMana);
              MMemo.Items.Text := FAction.FMessage.Text;
              case FAction.FActionType of
                daOfferPeace: MIcon.CurrentImage := 8;
                daProposeAlliance: MIcon.CurrentImage := 10;
                daDeclareWarToY: MIcon.CurrentImage := 47;
                daBreakAllianceWithY: MIcon.CurrentImage := 47;
                daMakeTribute: MIcon.CurrentImage := 48;
              end;
            end
            else if (AoWHSMap.FSeatedPlayer = FAction.FSource) and (FAction.FReaction <> TDiplomaticActionReaction(3)) then
            begin
              HighlightPlayer(FAction.FTarget); ShowPlayerInformation(FAction.FTarget);
              RNewActionPnl.Visible := False; IncommingInfoPnl.Visible := True;
              IIMemo.Items.Text := FAction.FMessage.Text;
              case FAction.FActionType of
                daOfferPeace: IIIcon.CurrentImage := 8;
                daProposeAlliance: IIIcon.CurrentImage := 10;
                daDeclareWarToY: IIIcon.CurrentImage := 47;
                daBreakAllianceWithY: IIIcon.CurrentImage := 47;
                daMakeTribute: IIIcon.CurrentImage := 48;
              end;
            end
            else
            begin
              FinishEvent;
              if FAction.FReaction = TDiplomaticActionReaction(3) then ShowPlayerActions(FAction.FTarget)
              else ShowPlayerActions(FAction.FSource);
            end;
          end;
        daDeclareWar, daBreakAlliance:
          if AoWHSMap.FSeatedPlayer = FAction.FSource then
          begin FinishEvent; ShowPlayerActions(FAction.FTarget); end
          else if AoWHSMap.FSeatedPlayer = FAction.FTarget then
          begin
            HighlightPlayer(FAction.FSource); ShowPlayerInformation(FAction.FSource);
            RNewActionPnl.Visible := False; IncommingInfoPnl.Visible := True;
            IIMemo.Items.Text := FAction.FMessage.Text;
            if FAction.FActionType = daDeclareWar then IIIcon.CurrentImage := 9
            else if FAction.FActionType = daBreakAlliance then IIIcon.CurrentImage := 8;
          end
          else begin FinishEvent; ShowPlayerActions(FAction.FSource); end;
        daThreatenToAttack:
          begin
            HighlightPlayer(FAction.FSource); ShowPlayerInformation(FAction.FSource);
            RNewActionPnl.Visible := False; IncommingInfoPnl.Visible := True;
            IIMemo.Items.Text := FAction.FMessage.Text;
            IIIcon.CurrentImage := 46;
          end;
      end;
    end
    else FinishDialog;
  end;
end;

procedure ShowInformationBook(Dialog: TWorldMap; Event: TShowBookEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    FOnBookClosed := TNotifyEvent(Done);
    FBookContext := Event;
    if FBookContext <> nil then FBookContext.AddRef;
    LabelL.Text := AoWHSMap.FMapName;
    MemoL.Items.Clear;
    MemoL.Items.AddStrings(AoWHSMap.FDescription);
    LabelR.Text := TranslateRStr(MapSettingsRStr);
    MemoR.Items.Clear;
    if AoWHSMap.FVictoryCondition = TVictoryCondition(0) then
      MemoR.Items.Add(AoWE.Format(TranslateRStr(ObjectiveXRStr), [TranslateRStr(ConquerTheMapRStr)]))
    else MemoR.Items.Add(AoWE.Format(TranslateRStr(ObjectiveXRStr), [TranslateRStr(AoWE.TVictoryConditionRStr[AoWHSMap.FVictoryCondition])]));
    if AoWHSMap.FDayLimit > 0 then MemoR.Items.Add(AoWE.Format(TranslateRStr(DayLimitXRStr), [IntToStr(AoWHSMap.FDayLimit)]));
    if AoWHSMap.FAlliedVictory then
      MemoR.Items.Add(AoWE.Format(TranslateRStr(AlliedVictoryXRStr), [TranslateRStr(EnabledRStr)]))
    else MemoR.Items.Add(AoWE.Format(TranslateRStr(AlliedVictoryXRStr), [TranslateRStr(DisabledRStr)]));
    MemoR.Items.Add(AoWE.Format(TranslateRStr(PlayersOnMapXRStr), [IntToStr(AoWHSMap.FPlayers.GetCount - 1)]));
    MemoR.Items.Add(AoWE.Format(TranslateRStr(MaximumSphereLevelXRStr), [IntToStr(AoWHSMap.FSphereCount)]));
    MemoR.Items.Add(AoWE.Format(TranslateRStr(MaximumPlayerHeroesXRStr), [IntToStr(AoWHSMap.FHeroCountMax)]));
    if (AoWHSMap.FConnectionType = TPlayerConnectionType(0)) and AoWHSMap.FRequestCombatType then
      MemoR.Items.Add(AoWE.Format(TranslateRStr(GametypeXRStr),
        [TranslateRStr(AoWE.TPlayerConnectionTypeRStr[AoWHSMap.FConnectionType]) + '/' + TranslateRStr(HotSeatRStr)]))
    else MemoR.Items.Add(AoWE.Format(TranslateRStr(GametypeXRStr), [TranslateRStr(AoWE.TPlayerConnectionTypeRStr[AoWHSMap.FConnectionType])]));
    MemoR.Items.Add(AoWE.Format(TranslateRStr(TurnModeXRStr), [TranslateRStr(TPlayModeRStr[AoWHSMap.FPlayMode])]));
    PicL.Visible := False; PicR.Visible := False; MemoL.Visible := True;
    MemoR.Visible := True; Back.Visible := False; Cancel.Visible := False;
    Next.Visible := False; BookWin.Visible := True;
    if BookWin.FBackSurface <> nil then BookWin.FBackSurface.Cls(BookWin.FMaskColor);
    General.Manager.OverlayPriority := 49;
  end;
end;

procedure ShowSMTPEvent(Dialog: TSMTPDlg; Event: TSMTPEventLog; Done: TExecuteDoneEvent);
begin
  with Dialog do
  begin
    ResetProgress;
    FDone := Done; FEvent := Event; with FEvent do AddRef;
    RecipientLbl.Text := AoWE.Format(TranslateRStr(RecipientXRStr), [Event.FToAddress]);
    try
      IMSSMTP.FMessage := IMSMessage;
      IMSSMTP.FHost := AoWEngine.FRegistry.GetSMTPServer;
      IMSSMTP.WinsockLoaded := True;
      with IMSMessage do
      begin
        FEncode := False; FIncludeHeader := False;
        FHeader.FFrom := Event.FFromAddress;
        FRecipients.Clear;
        Dialog.IMSMessage.FRecipients.AddAddress(Event.FToAddress, '');
      end;
      IMSMessage.FSubject := Event.FSubject;
      IMSMessage.SetBody(Event.FMessage);
      IMSMessage.FAttachments.Clear;
      IMSMessage.FAttachments.AddFile(Event.FFileName);
      StartSending;
      Dlg.Visible := True;
    except
      FEvent.FSuccess := False;
      FFinished := True;
      Dlg.Visible := True;
    end;
  end;
end;

end.
