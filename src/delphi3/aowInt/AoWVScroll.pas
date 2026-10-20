unit AoWVScroll;

{ The AoWVScroll unit of aowInt.dpl: TAOWScrollBar, the common ancestor of the scroll bars (the
  range, the position, the image libraries and the auto-repeat of a held button), and
  TAOWVScrollBar, the vertical scroll bar. A scroll bar is one of three kinds, chosen by Validate
  from the image libraries it has: a scroll bar with two buttons, a background and a tab
  (stScroll), a slider without buttons (stSlider) or just the two buttons (stIncDec). The tab is
  an icon (ttIcon) or a line of three images stretched to its size (ttBar). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWComp, AOWInterfaceImgLib, AoWWinControl, AOWWinManager, AoWBaseWin, AOWToolTip, AoWControl;

type
  TaowScrollType = (stScroll, stSlider, stIncDec);
  TaowTabType = (ttIcon, ttBar);

  { AoWVScroll.TAOWScrollBar (instance size 380). Fields: +$114 FVanishWhenFull, +$118 FILIInc
    (the increment button: down or right), +$11C FILIDec (the decrement button), +$120 FILTBack
    (the background of a scroll bar), +$124 FILLBack (the background line of a slider), +$128
    FILITab (an icon tab), +$12C FILLTab (a line tab), +$130 F130 (the length of the track the tab
    moves in), +$134 F134 (the length of the tab), +$138 FMin, +$13C FMax, +$140 FSmallChange,
    +$144 FLargeChange, +$148 FPosition, +$14C F14C (the number of positions, FMax - FMin + 1),
    +$150 F150 (the updates the mouse button has been held; 0 when it is up), +$151 F151 (the part
    that was clicked: 1 the decrement button, 2 the track before the tab, 3 the track after it,
    4 the increment button, 5 the tab), +$152 FDelay (the updates before a held button repeats),
    +$154 F154 (the position a click in the track pages to; the mouse offset into the tab while
    the tab is dragged), +$158 FNumberVisible, +$15C F15C (unused), +$160 FScrollType, +$161
    FTabType, +$164 FILIndexIncUp, +$168 FILIndexIncDown, +$16C FILIndexDecUp, +$170
    FILIndexDecDown, +$174 FILIndexBack, +$178 FILIndexTab.
    VMT (new): SetILIUIndex, SetILIDIndex, SetILDUIndex, SetILDDIndex, SetILBIndex, SetILTIndex,
    SetILInc, SetILDec, SetILBack, SetILLBack, SetILITab, SetILLTab }
  TAOWScrollBar = class(TAOWControl)
  public
    FVanishWhenFull: Boolean;
    FILIInc: TInterfaceIL;
    FILIDec: TInterfaceIL;
    FILTBack: TInterfaceIL;
    FILLBack: TInterfaceIL;
    FILITab: TInterfaceIL;
    FILLTab: TInterfaceIL;
    F130: Integer;
    F134: Integer;
    FMin: Integer;
    FMax: Integer;
    FSmallChange: Integer;
    FLargeChange: Integer;
    FPosition: Integer;
    F14C: Integer;
    F150: Byte;
    F151: Byte;
    FDelay: Byte;
    F154: Integer;
    FNumberVisible: Integer;
    F15C: Integer;
    FScrollType: TaowScrollType;
    FTabType: TaowTabType;
    FILIndexIncUp: Integer;
    FILIndexIncDown: Integer;
    FILIndexDecUp: Integer;
    FILIndexDecDown: Integer;
    FILIndexBack: Integer;
    FILIndexTab: Integer;
    constructor Create(AOwner: TComponent); override;
    procedure Validate; override;
    procedure Update; override;
    procedure SetILIUIndex(Value: Integer); virtual;
    procedure SetILIDIndex(Value: Integer); virtual;
    procedure SetILDUIndex(Value: Integer); virtual;
    procedure SetILDDIndex(Value: Integer); virtual;
    procedure SetILBIndex(Value: Integer); virtual;
    procedure SetILTIndex(Value: Integer); virtual;
    procedure SetILInc(Value: TInterfaceIL); virtual;
    procedure SetILDec(Value: TInterfaceIL); virtual;
    procedure SetILBack(Value: TInterfaceIL); virtual;
    procedure SetILLBack(Value: TInterfaceIL); virtual;
    procedure SetILITab(Value: TInterfaceIL); virtual;
    procedure SetILLTab(Value: TInterfaceIL); virtual;
    procedure SetSmall(Value: Integer);
    procedure SetLarge(Value: Integer);
    procedure SetFMin(Value: Integer);
    procedure SetFMax(Value: Integer);
    procedure SetFNum(Value: Integer);
    procedure SetFPos(Value: Integer);
  published
    property Delay: Byte read FDelay write FDelay default 20;
    property Min: Integer read FMin write SetFMin;
    property Max: Integer read FMax write SetFMax;
    property SmallChange: Integer read FSmallChange write SetSmall;
    property LargeChange: Integer read FLargeChange write SetLarge;
    property Position: Integer read FPosition write SetFPos;
    property WinHeight;
    property WinWidth;
    property NumberVisible: Integer read FNumberVisible write SetFNum;
    property OnChange;
    property VanishWhenFull: Boolean read FVanishWhenFull write FVanishWhenFull;
    property ILIInc: TInterfaceIL read FILIInc write SetILInc;
    property ILIDec: TInterfaceIL read FILIDec write SetILDec;
    property ILTBack: TInterfaceIL read FILTBack write SetILBack;
    property ILLBack: TInterfaceIL read FILLBack write SetILLBack;
    property ILITab: TInterfaceIL read FILITab write SetILITab;
    property ILLTab: TInterfaceIL read FILLTab write SetILLTab;
    property ILIndexIncUp: Integer read FILIndexIncUp write SetILIUIndex;
    property ILIndexIncDown: Integer read FILIndexIncDown write SetILIDIndex;
    property ILIndexDecUp: Integer read FILIndexDecUp write SetILDUIndex;
    property ILIndexDecDown: Integer read FILIndexDecDown write SetILDDIndex;
    property ILIndexBack: Integer read FILIndexBack write SetILBIndex;
    property ILIndexTab: Integer read FILIndexTab write SetILTIndex;
  end;

  { AoWVScroll.TAOWVScrollBar (instance size 380): the vertical scroll bar, the decrement button
    at the top and the increment button at the bottom }
  TAOWVScrollBar = class(TAOWScrollBar)
  public
    procedure SetSize; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

procedure Register;

implementation

{ TAOWScrollBar }

constructor TAOWScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSmallChange := 1;
  FLargeChange := 1;
  FMax := 1;
  FNumberVisible := 1;
  FDelay := 20;
end;

procedure TAOWScrollBar.SetILInc(Value: TInterfaceIL);
begin
  if Value <> FILIInc then
  begin
    FValid := False;
    FILIInc := Value;
  end;
end;

procedure TAOWScrollBar.SetILDec(Value: TInterfaceIL);
begin
  if Value <> FILIDec then
  begin
    FValid := False;
    FILIDec := Value;
  end;
end;

procedure TAOWScrollBar.SetILBack(Value: TInterfaceIL);
begin
  if Value <> FILTBack then
  begin
    FValid := False;
    FILTBack := Value;
  end;
end;

procedure TAOWScrollBar.SetILLBack(Value: TInterfaceIL);
begin
  if Value <> FILLBack then
  begin
    FValid := False;
    FILLBack := Value;
  end;
end;

procedure TAOWScrollBar.SetILITab(Value: TInterfaceIL);
begin
  if Value <> FILITab then
  begin
    FValid := False;
    FILITab := Value;
  end;
end;

procedure TAOWScrollBar.SetILLTab(Value: TInterfaceIL);
begin
  if Value <> FILLTab then
  begin
    FValid := False;
    FILLTab := Value;
  end;
end;

procedure TAOWScrollBar.SetILIUIndex(Value: Integer);
begin
  if Value <> FILIndexIncUp then
  begin
    FILIndexIncUp := Value;
    FValid := False;
  end;
end;

procedure TAOWScrollBar.SetILIDIndex(Value: Integer);
begin
  if Value <> FILIndexIncDown then
  begin
    FILIndexIncDown := Value;
    FValid := False;
  end;
end;

procedure TAOWScrollBar.SetILDUIndex(Value: Integer);
begin
  if Value <> FILIndexDecUp then
  begin
    FILIndexDecUp := Value;
    FValid := False;
  end;
end;

procedure TAOWScrollBar.SetILDDIndex(Value: Integer);
begin
  if Value <> FILIndexDecDown then
  begin
    FILIndexDecDown := Value;
    FValid := False;
  end;
end;

procedure TAOWScrollBar.SetILBIndex(Value: Integer);
begin
  if Value <> FILIndexBack then
  begin
    FILIndexBack := Value;
    FValid := False;
  end;
end;

procedure TAOWScrollBar.SetILTIndex(Value: Integer);
begin
  if Value <> FILIndexTab then
  begin
    FILIndexTab := Value;
    FValid := False;
  end;
end;

{ Validate checks the image libraries and picks the kind of scroll bar: both buttons with a
  background and a tab make a scroll bar, both buttons alone make an increment/decrement pair,
  a background line with a tab makes a slider; anything else leaves the scroll bar invalid }
procedure TAOWScrollBar.Validate;
begin
  if FILIInc <> nil then
    FILIInc := FILIInc.CheckIL(FILIndexIncUp, 1, Self);
  if FILIInc <> nil then
    FILIInc := FILIInc.CheckIL(FILIndexIncDown, 1, Self);
  if FILIDec <> nil then
    FILIDec := FILIDec.CheckIL(FILIndexDecUp, 1, Self);
  if FILIDec <> nil then
    FILIDec := FILIDec.CheckIL(FILIndexDecDown, 1, Self);
  if FILTBack <> nil then
    FILTBack := FILTBack.CheckIL(FILIndexBack, 1, Self);
  if FILLBack <> nil then
    FILLBack := FILLBack.CheckIL(FILIndexBack, 3, Self);
  if FILITab <> nil then
    FILITab := FILITab.CheckIL(FILIndexTab, 3, Self);
  if FILLTab <> nil then
    FILLTab := FILLTab.CheckIL(FILIndexTab, 3, Self);
  if FILITab <> nil then
    FTabType := ttIcon
  else
    FTabType := ttBar;
  if (FILIInc <> nil) and (FILIDec <> nil) then
  begin
    FValid := True;
    if (FILTBack <> nil) and ((FILITab <> nil) or (FILLTab <> nil)) then
      FScrollType := stScroll
    else
      FScrollType := stIncDec;
  end
  else if (FILLBack <> nil) and ((FILITab <> nil) or (FILLTab <> nil)) then
  begin
    FValid := True;
    FScrollType := stSlider;
  end;
  inherited Validate;
end;

procedure TAOWScrollBar.SetSmall(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  FSmallChange := Value;
end;

procedure TAOWScrollBar.SetLarge(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  FLargeChange := Value;
end;

procedure TAOWScrollBar.SetFMin(Value: Integer);
begin
  if Value > FMax then
    Value := FMax;
  if Value <> FMin then
  begin
    FMin := Value;
    FSized := False;
  end;
end;

procedure TAOWScrollBar.SetFMax(Value: Integer);
begin
  if Value < FMin then
    Value := FMin;
  if Value <> FMax then
  begin
    FMax := Value;
    FSized := False;
  end;
end;

procedure TAOWScrollBar.SetFNum(Value: Integer);
begin
  if Value > FMax - FMin + 1 then
    Value := FMax - FMin + 1;
  if Value < 1 then
    Value := 1;
  if Value <> FNumberVisible then
  begin
    FNumberVisible := Value;
    FSized := False;
  end;
end;

procedure TAOWScrollBar.SetFPos(Value: Integer);
begin
  FPosition := Value;
  if FPosition + FNumberVisible > FMax - FMin + 1 then
    FPosition := FMax - FMin - FNumberVisible + 1;
  if FPosition < 0 then
    FPosition := 0;
  FDrawn := False;
end;

{ Update repeats the action of a held mouse button once the button has been held for Delay
  updates: a button steps by SmallChange, the track pages by LargeChange up to the position that
  was clicked }
procedure TAOWScrollBar.Update;
begin
  if FVisible and (F150 > 0) then
    if F150 < FDelay then
      Inc(F150)
    else
      case F151 of
        1:
          begin
            FPosition := FPosition - FSmallChange;
            if FMin > FPosition then
              FPosition := FMin;
            FDrawn := False;
            if Assigned(FOnChange) then
              FOnChange(Self);
          end;
        4:
          begin
            FPosition := FPosition + FSmallChange;
            if FMax + 1 - FNumberVisible < FPosition then
              FPosition := FMax + 1 - FNumberVisible;
            FDrawn := False;
            if Assigned(FOnChange) then
              FOnChange(Self);
          end;
        2:
          begin
            FPosition := FPosition - FLargeChange;
            if F154 > FPosition then
            begin
              FPosition := F154;
              F150 := 0;
            end;
            FDrawn := False;
            if Assigned(FOnChange) then
              FOnChange(Self);
          end;
        3:
          begin
            FPosition := FPosition + FLargeChange;
            if F154 + 1 < FPosition then
            begin
              FPosition := F154 + 1;
              F150 := 0;
            end;
            FDrawn := False;
            if Assigned(FOnChange) then
              FOnChange(Self);
          end;
      end;
  inherited Update;
end;

{ TAOWVScrollBar }

{ SetSize takes the width from the images and sizes the track and the tab: the tab of a line is
  proportional to the visible part of the range, but no shorter than its two end images }
procedure TAOWVScrollBar.SetSize;
begin
  F14C := FMax - FMin + 1;
  if F14C < FNumberVisible then
    FNumberVisible := F14C;
  case FScrollType of
    stScroll:
      begin
        FWinWidth := FILTBack[FILIndexBack].Width;
        if FILIDec[FILIndexDecUp].Height + FILIInc[FILIndexIncUp].Height > FWinHeight then
          FWinHeight := FILIDec[FILIndexDecUp].Height + FILIInc[FILIndexIncUp].Height;
        F130 := FWinHeight - FILIDec[FILIndexDecUp].Height - FILIInc[FILIndexIncUp].Height;
        if F130 < 1 then
          F130 := 1;
        F134 := F130 * FNumberVisible div F14C;
        case FTabType of
          ttIcon:
            F134 := FILITab[FILIndexTab].Height;
          ttBar:
            if F134 < FILLTab[FILIndexTab].Height + FILLTab[FILIndexTab + 2].Height then
              F134 := FILLTab[FILIndexTab].Height + FILLTab[FILIndexTab + 2].Height;
        end;
      end;
    stSlider:
      begin
        FWinWidth := FILLBack[FILIndexBack].Width;
        F130 := FWinHeight;
        F134 := F130 * FNumberVisible div F14C;
        case FTabType of
          ttIcon:
            F134 := FILITab[FILIndexTab].Height;
          ttBar:
            if F134 < FILLTab[FILIndexTab].Height + FILLTab[FILIndexTab + 2].Height then
              F134 := FILLTab[FILIndexTab].Height + FILLTab[FILIndexTab + 2].Height;
        end;
      end;
    stIncDec:
      begin
        FWinWidth := FILIDec[FILIndexDecUp].Width;
        FWinHeight := FILIDec[FILIndexDecUp].Height + FILIInc[FILIndexIncUp].Height;
      end;
  end;
  if FPosition + FNumberVisible > F14C then
    FPosition := F14C - FNumberVisible;
  inherited SetSize;
end;

{ Draw draws the buttons (pressed while held), the background and the tab. The top of the
  increment button is computed from the height of its pressed image in both states (original) }
procedure TAOWVScrollBar.Draw(SurfDesc: TSurfaceDesc);
var
  TabPos: Integer;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      case FScrollType of
        stScroll:
          begin
            if (F151 = 4) and (F150 > 0) then
              FILIInc.DrawILT(FILIndexIncDown, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop + FWinHeight - FILIInc[FILIndexIncDown].Height,
                FWinWidth, FILIInc[FILIndexIncDown].Height), SurfDesc)
            else
              FILIInc.DrawILT(FILIndexIncUp, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop + FWinHeight - FILIInc[FILIndexIncDown].Height,
                FWinWidth, FILIInc[FILIndexIncUp].Height), SurfDesc);
            if (F151 = 1) and (F150 > 0) then
              FILIDec.DrawILT(FILIndexDecDown, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop, FWinWidth, FILIDec[FILIndexDecDown].Height),
                SurfDesc)
            else
              FILIDec.DrawILT(FILIndexDecUp, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop, FWinWidth, FILIDec[FILIndexDecUp].Height),
                SurfDesc);
            FILTBack.DrawILT(FILIndexBack, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop + FILIDec[FILIndexDecUp].Height,
              FILTBack[FILIndexBack].Width, F130), SurfDesc);
            TabPos := F130 * FPosition div F14C;
            if F134 + TabPos > F130 then
              TabPos := F130 - F134;
            case FTabType of
              ttIcon:
                FILITab.DrawILT(FILIndexTab, Rect(FAOWWindow.FWinLeft + FWinLeft,
                  FAOWWindow.FWinTop + FWinTop + FILIDec[FILIndexDecUp].Height + TabPos,
                  FWinWidth, F134), SurfDesc);
              ttBar:
                FILLTab.DrawILLv(FILIndexTab, Rect(FAOWWindow.FWinLeft + FWinLeft,
                  FAOWWindow.FWinTop + FWinTop + FILIDec[FILIndexDecUp].Height + TabPos,
                  FWinWidth, F134), SurfDesc);
            end;
          end;
        stSlider:
          begin
            FILLBack.DrawILLv(FILIndexBack, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
            TabPos := F130 * FPosition div F14C;
            if F134 + TabPos > F130 then
              TabPos := F130 - F134;
            case FTabType of
              ttIcon:
                FILITab.DrawILT(FILIndexTab, Rect(FAOWWindow.FWinLeft + FWinLeft,
                  FAOWWindow.FWinTop + FWinTop + TabPos, FWinWidth, F134), SurfDesc);
              ttBar:
                FILLTab.DrawILLv(FILIndexTab, Rect(FAOWWindow.FWinLeft + FWinLeft,
                  FAOWWindow.FWinTop + FWinTop + TabPos, FWinWidth, F134), SurfDesc);
            end;
          end;
        stIncDec:
          begin
            if (F151 = 4) and (F150 > 0) then
              FILIInc.DrawILT(FILIndexIncDown, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop + FWinHeight - FILIInc[FILIndexIncDown].Height,
                FWinWidth, FILIInc[FILIndexIncDown].Height), SurfDesc)
            else
              FILIInc.DrawILT(FILIndexIncUp, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop + FWinHeight - FILIInc[FILIndexIncDown].Height,
                FWinWidth, FILIInc[FILIndexIncUp].Height), SurfDesc);
            if (F151 = 1) and (F150 > 0) then
              FILIDec.DrawILT(FILIndexDecDown, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop, FWinWidth, FILIDec[FILIndexDecDown].Height),
                SurfDesc)
            else
              FILIDec.DrawILT(FILIndexDecUp, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop, FWinWidth, FILIDec[FILIndexDecUp].Height),
                SurfDesc);
          end;
      end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ CheckMouseDown: a click on a button steps the position, a click in the track pages towards
  the click, a click on the tab starts dragging it (F151 stays 5). The track before the tab ends
  at the height of the increment button (original) }
procedure TAOWVScrollBar.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TabPos: Integer;
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (FVisible = True) and (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Button = mbLeft then
    begin
      F150 := 1;
      F151 := 5;
      TabPos := F130 * FPosition div F14C;
      if TabPos + F134 > F130 then
        TabPos := F130 - F134;
      if FScrollType <> stSlider then
      begin
        if Y < FAOWWindow.FWinTop + FWinTop + FILIDec[FILIndexDecUp].Height - 1 then
        begin
          F151 := 1;
          FPosition := FPosition - FSmallChange;
          if FMin > FPosition then
            FPosition := FMin;
          FDrawn := False;
          if Assigned(FOnChange) then
            FOnChange(Self);
        end;
        if Y > FAOWWindow.FWinTop + FWinTop + FWinHeight - FILIInc[FILIndexIncUp].Height then
        begin
          F151 := 4;
          FPosition := FPosition + FSmallChange;
          if FMax + 1 - FNumberVisible < FPosition then
            FPosition := FMax + 1 - FNumberVisible;
          FDrawn := False;
          if Assigned(FOnChange) then
            FOnChange(Self);
        end;
      end;
      if F151 = 5 then
        case FScrollType of
          stScroll:
            begin
              if (Y > FAOWWindow.FWinTop + FWinTop + FILIDec[FILIndexDecUp].Height) and
                (Y < FAOWWindow.FWinTop + FWinTop + TabPos + FILIInc[FILIndexIncUp].Height) then
              begin
                F154 := (Y - FAOWWindow.FWinTop - FWinTop - FILIDec[FILIndexDecUp].Height) *
                  F14C div F130 + FMin;
                F151 := 2;
                FPosition := FPosition - FLargeChange;
                if FMin > FPosition then
                  FPosition := FMin;
                FDrawn := False;
                if Assigned(FOnChange) then
                  FOnChange(Self);
              end;
              if (Y > FAOWWindow.FWinTop + FWinTop + FILIDec[FILIndexDecUp].Height + TabPos +
                F134) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight -
                FILIInc[FILIndexIncUp].Height) then
              begin
                F154 := (Y - FAOWWindow.FWinTop - FWinTop - FILIDec[FILIndexDecUp].Height) *
                  F14C div F130 + FMin;
                F151 := 3;
                FPosition := FPosition + FLargeChange;
                if FMax + 1 - FNumberVisible < FPosition then
                  FPosition := FMax + 1 - FNumberVisible;
                FDrawn := False;
                if Assigned(FOnChange) then
                  FOnChange(Self);
              end;
              if F151 = 5 then
                F154 := Y - TabPos;
            end;
          stSlider:
            begin
              if (Y > FAOWWindow.FWinTop + FWinTop) and
                (Y < FAOWWindow.FWinTop + FWinTop + TabPos) then
              begin
                F154 := (Y - FAOWWindow.FWinTop - FWinTop) * F14C div F130 + FMin;
                F151 := 2;
                FPosition := FPosition - FLargeChange;
                if FMin > FPosition then
                  FPosition := FMin;
                FDrawn := False;
                if Assigned(FOnChange) then
                  FOnChange(Self);
              end;
              if (Y > FAOWWindow.FWinTop + FWinTop + TabPos + F134) and
                (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
              begin
                F154 := (Y - FAOWWindow.FWinTop - FWinTop) * F14C div F130 + FMin;
                F151 := 3;
                FPosition := FPosition + FLargeChange;
                if FMax + 1 - FNumberVisible < FPosition then
                  FPosition := FMax + 1 - FNumberVisible;
                FDrawn := False;
                if Assigned(FOnChange) then
                  FOnChange(Self);
              end;
              if F151 = 5 then
                F154 := Y - TabPos;
            end;
        end;
    end;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWVScrollBar.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if F151 <> 0 then
    FDrawn := False;
  F150 := 0;
  F151 := 0;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

{ CheckMouseMove drags the tab }
procedure TAOWVScrollBar.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if (F151 = 5) and (F150 > 0) then
  begin
    FPosition := (Y - F154) * F14C div F130 + FMin;
    if FPosition < FMin then
      FPosition := FMin;
    if FMax + 1 - FNumberVisible < FPosition then
      FPosition := FMax + 1 - FNumberVisible;
    FDrawn := False;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWVScrollBar]);
end;

end.
