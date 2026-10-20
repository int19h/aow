unit AoWHScroll;

{ The AoWHScroll unit of aowInt.dpl: TAOWHScrollBar, the horizontal scroll bar (TAOWScrollBar of
  AoWVScroll with the decrement button at the left and the increment button at the right). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWComp, AOWInterfaceImgLib, AoWWinControl, AOWWinManager, AoWBaseWin, AOWToolTip, AoWControl,
  AoWVScroll;

type
  { AoWHScroll.TAOWHScrollBar (instance size 380): no fields of its own }
  TAOWHScrollBar = class(TAOWScrollBar)
  public
    procedure SetSize; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

procedure Register;

implementation

{ TAOWHScrollBar }

{ SetSize: as TAOWVScrollBar.SetSize across; the track length is not kept above zero here }
procedure TAOWHScrollBar.SetSize;
begin
  F14C := FMax - FMin + 1;
  if F14C < FNumberVisible then
    FNumberVisible := F14C;
  case FScrollType of
    stScroll:
      begin
        FWinHeight := FILTBack[FILIndexBack].Height;
        if FILIDec[FILIndexDecUp].Width + FILIInc[FILIndexIncUp].Width > FWinWidth then
          FWinWidth := FILIDec[FILIndexDecUp].Width + FILIInc[FILIndexIncUp].Width;
        F130 := FWinWidth - FILIDec[FILIndexDecUp].Width - FILIInc[FILIndexIncUp].Width;
        F134 := F130 * FNumberVisible div F14C;
        case FTabType of
          ttIcon:
            F134 := FILITab[FILIndexTab].Width;
          ttBar:
            if F134 < FILLTab[FILIndexTab].Width + FILLTab[FILIndexTab + 2].Width then
              F134 := FILLTab[FILIndexTab].Width + FILLTab[FILIndexTab + 2].Width;
        end;
      end;
    stSlider:
      begin
        FWinHeight := FILLBack[FILIndexBack].Height;
        F130 := FWinWidth;
        F134 := F130 * FNumberVisible div F14C;
        case FTabType of
          ttIcon:
            F134 := FILITab[FILIndexTab].Width;
          ttBar:
            if F134 < FILLTab[FILIndexTab].Width + FILLTab[FILIndexTab + 2].Width then
              F134 := FILLTab[FILIndexTab].Width + FILLTab[FILIndexTab + 2].Width;
        end;
      end;
    stIncDec:
      begin
        FWinHeight := FILIDec[FILIndexDecUp].Height;
        FWinWidth := FILIDec[FILIndexDecUp].Width + FILIInc[FILIndexIncUp].Width;
      end;
  end;
  if FPosition + FNumberVisible > F14C then
    FPosition := F14C - FNumberVisible;
  inherited SetSize;
end;

{ Draw: as TAOWVScrollBar.Draw across. The buttons of an increment/decrement pair keep parts of
  the vertical code: the increment button is drawn left of the control and below it, and the
  decrement button is FWinWidth wide and as high as its image (original) }
procedure TAOWHScrollBar.Draw(SurfDesc: TSurfaceDesc);
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
              FILIInc.DrawILT(FILIndexIncDown, Rect(FAOWWindow.FWinLeft + FWinLeft + FWinWidth -
                FILIInc[FILIndexIncDown].Width, FAOWWindow.FWinTop + FWinTop,
                FILIInc[FILIndexIncDown].Width, FWinHeight), SurfDesc)
            else
              FILIInc.DrawILT(FILIndexIncUp, Rect(FAOWWindow.FWinLeft + FWinLeft + FWinWidth -
                FILIInc[FILIndexIncDown].Width, FAOWWindow.FWinTop + FWinTop,
                FILIInc[FILIndexIncUp].Width, FWinHeight), SurfDesc);
            if (F151 = 1) and (F150 > 0) then
              FILIDec.DrawILT(FILIndexDecDown, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop, FILIDec[FILIndexDecDown].Width, FWinHeight),
                SurfDesc)
            else
              FILIDec.DrawILT(FILIndexDecUp, Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop, FILIDec[FILIndexDecUp].Width, FWinHeight),
                SurfDesc);
            FILTBack.DrawILT(FILIndexBack, Rect(FAOWWindow.FWinLeft + FWinLeft +
              FILIDec[FILIndexDecUp].Width, FAOWWindow.FWinTop + FWinTop, F130,
              FILTBack[FILIndexBack].Height), SurfDesc);
            TabPos := F130 * FPosition div F14C;
            if F134 + TabPos > F130 then
              TabPos := F130 - F134;
            case FTabType of
              ttIcon:
                FILITab.DrawILT(FILIndexTab, Rect(FAOWWindow.FWinLeft + FWinLeft +
                  FILIDec[FILIndexDecUp].Width + TabPos, FAOWWindow.FWinTop + FWinTop, F134,
                  FWinHeight), SurfDesc);
              ttBar:
                FILLTab.DrawILLh(FILIndexTab, Rect(FAOWWindow.FWinLeft + FWinLeft +
                  FILIDec[FILIndexDecUp].Width + TabPos, FAOWWindow.FWinTop + FWinTop, F134,
                  FWinHeight), SurfDesc);
            end;
          end;
        stSlider:
          begin
            FILLBack.DrawILLh(FILIndexBack, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
            TabPos := F130 * FPosition div F14C;
            if F134 + TabPos > F130 then
              TabPos := F130 - F134;
            case FTabType of
              ttIcon:
                FILITab.DrawILT(FILIndexTab, Rect(FAOWWindow.FWinLeft + FWinLeft + TabPos,
                  FAOWWindow.FWinTop + FWinTop, F134, FWinHeight), SurfDesc);
              ttBar:
                FILLTab.DrawILLh(FILIndexTab, Rect(FAOWWindow.FWinLeft + FWinLeft + TabPos,
                  FAOWWindow.FWinTop + FWinTop, F134, FWinHeight), SurfDesc);
            end;
          end;
        stIncDec:
          begin
            if (F151 = 4) and (F150 > 0) then
              FILIInc.DrawILT(FILIndexIncDown, Rect(FAOWWindow.FWinLeft + FWinLeft -
                FILIInc[FILIndexIncDown].Width, FAOWWindow.FWinTop + FWinTop + FWinHeight,
                FILIInc[FILIndexIncDown].Width, FWinHeight), SurfDesc)
            else
              FILIInc.DrawILT(FILIndexIncUp, Rect(FAOWWindow.FWinLeft + FWinLeft -
                FILIInc[FILIndexIncUp].Width, FAOWWindow.FWinTop + FWinTop + FWinHeight,
                FILIInc[FILIndexIncUp].Width, FWinHeight), SurfDesc);
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

{ CheckMouseDown: as TAOWVScrollBar.CheckMouseDown across, but OnChange is called once at the end
  when the position changed. The track after the tab ends at the width of the decrement button
  (original) }
procedure TAOWHScrollBar.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TabPos: Integer;
  OldPos: Integer;
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (FVisible = True) and (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    OldPos := FPosition;
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
        if X < FAOWWindow.FWinLeft + FWinLeft + FILIDec[FILIndexDecUp].Width - 1 then
        begin
          F151 := 1;
          FPosition := FPosition - FSmallChange;
          if FMin > FPosition then
            FPosition := FMin;
        end;
        if X > FAOWWindow.FWinLeft + FWinLeft + FWinWidth - FILIInc[FILIndexIncUp].Width then
        begin
          F151 := 4;
          FPosition := FPosition + FSmallChange;
          if FMax + 1 - FNumberVisible < FPosition then
            FPosition := FMax + 1 - FNumberVisible;
        end;
      end;
      if F151 = 5 then
        case FScrollType of
          stScroll:
            begin
              if (X > FAOWWindow.FWinLeft + FWinLeft + FILIDec[FILIndexDecUp].Width) and
                (X < FAOWWindow.FWinLeft + FWinLeft + TabPos + FILIInc[FILIndexIncUp].Width) then
              begin
                F154 := (X - FAOWWindow.FWinLeft - FWinLeft - FILIDec[FILIndexDecUp].Width) *
                  F14C div F130 + FMin;
                F151 := 2;
                FPosition := FPosition - FLargeChange;
                if FMin > FPosition then
                  FPosition := FMin;
              end;
              if (X > FAOWWindow.FWinLeft + FWinLeft + FILIDec[FILIndexDecUp].Width + TabPos +
                F134) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth -
                FILIDec[FILIndexDecUp].Width) then
              begin
                F154 := (X - FAOWWindow.FWinLeft - FWinLeft - FILIDec[FILIndexDecUp].Width) *
                  F14C div F130 + FMin;
                F151 := 3;
                FPosition := FPosition + FLargeChange;
                if FMax + 1 - FNumberVisible < FPosition then
                  FPosition := FMax + 1 - FNumberVisible;
              end;
              if F151 = 5 then
                F154 := X - TabPos;
            end;
          stSlider:
            begin
              if (X > FAOWWindow.FWinLeft + FWinLeft) and
                (X < FAOWWindow.FWinLeft + FWinLeft + TabPos) then
              begin
                F154 := (X - FAOWWindow.FWinLeft - FWinLeft) * F14C div F130 + FMin;
                F151 := 2;
                FPosition := FPosition - FLargeChange;
                if FMin > FPosition then
                  FPosition := FMin;
              end;
              if (X > FAOWWindow.FWinLeft + FWinLeft + TabPos + F134) and
                (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) then
              begin
                F154 := (X - FAOWWindow.FWinLeft - FWinLeft) * F14C div F130 + FMin;
                F151 := 3;
                FPosition := FPosition + FLargeChange;
                if FMax + 1 - FNumberVisible < FPosition then
                  FPosition := FMax + 1 - FNumberVisible;
              end;
              if F151 = 5 then
                F154 := X - TabPos;
            end;
        end;
    end;
    if OldPos <> FPosition then
    begin
      FDrawn := False;
      if Assigned(FOnChange) then
        FOnChange(Self);
    end;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWHScrollBar.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (F151 = 1) or (F151 = 4) then
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

procedure TAOWHScrollBar.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if (F151 = 5) and (F150 > 0) then
  begin
    FPosition := (X - F154) * F14C div F130 + FMin;
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
  RegisterComponents('AOW Interface', [TAOWHScrollBar]);
end;

end.
