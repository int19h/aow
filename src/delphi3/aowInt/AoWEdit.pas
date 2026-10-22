unit AoWEdit;

{ The AoWEdit unit of aowInt.dpl: TAOWEdit, a one-line edit box drawn from an edit library (a
  horizontal line of three images) with its text in AOWFont. It scrolls the text so that the
  part after FFirstChar fits, shows a blinking cursor character while it has the input focus
  (FRedraw), takes the focus on a click and loses it on a click outside, and handles the
  cursor keys, Delete, Backspace, Return and Ctrl+V (paste the clipboard text). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  Clipbrd, AOWToolTip, AoWControl, AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl,
  AoWBaseWin, AoWWinGeneric;

type
  { AoWEdit.TAOWEdit (instance size 336). Fields: +$114 FMaxChars (0: no limit), +$118
    FCursorChar, +$119 FPassWordChar (#0: show the text), +$11C FCursorShown (the blink state of
    the cursor), +$120 FBlinkDelay (updates between two blinks), +$124 FBlinkCount, +$128
    FShownChars (the characters from FFirstChar to the end), +$12C FFirstChar (the first
    character shown), +$130 FEditable, +$134 FILEdit, +$138 FOnExit, +$140 FOnReturn, +$148
    FILIndex, +$14C FCursorPos (the cursor position counted from FFirstChar). FRedraw (+$94)
    is the input focus.
    VMT (new): SetILEdit }
  TAOWEdit = class(TAOWControl)
  public
    FMaxChars: Integer;
    FCursorChar: Char;
    FPassWordChar: Char;
    FCursorShown: LongBool;
    FBlinkDelay: Integer;
    FBlinkCount: Integer;
    FShownChars: Integer;
    FFirstChar: Integer;
    FEditable: Boolean;
    FILEdit: TInterfaceIL;
    FOnExit: TNotifyEvent;
    FOnReturn: TNotifyEvent;
    FILIndex: Integer;
    FCursorPos: Integer;
    constructor Create(AOwner: TComponent); override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure CheckKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure SetILEdit(Value: TInterfaceIL); virtual;
    procedure SetGText(Value: string);
    procedure SetILIndex(Value: Integer);
  published
    property WinWidth;
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property Text: string read FText write SetGText;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property OnChange;
    property MaxChars: Integer read FMaxChars write FMaxChars;
    property CursorChar: Char read FCursorChar write FCursorChar;
    property BlinkDelay: Integer read FBlinkDelay write FBlinkDelay;
    property TextColor;
    property Editable: Boolean read FEditable write FEditable;
    property ILEdit: TInterfaceIL read FILEdit write SetILEdit;
    property ILIndex: Integer read FILIndex write SetILIndex;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnReturn: TNotifyEvent read FOnReturn write FOnReturn;
    property PassWordChar: Char read FPassWordChar write FPassWordChar;
  end;

procedure Register;

implementation

{ TAOWEdit }

constructor TAOWEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCursorChar := '|';
  FCursorShown := True;
  FEditable := True;
end;

procedure TAOWEdit.Validate;
begin
  if FILEdit <> nil then
    FILEdit := FILEdit.CheckIL(FILIndex, 3, Self);
  if (FILEdit <> nil) and (FAOWFont <> nil) then
    FValid := True;
  inherited Validate;
end;

procedure TAOWEdit.SetSize;
begin
  if FILEdit[FILIndex].Width + FILEdit[FILIndex + 2].Width > FWinWidth then
    FWinWidth := FILEdit[FILIndex].Width + FILEdit[FILIndex + 2].Width;
  FWinHeight := FILEdit[FILIndex].Height;
  FFirstChar := 1;
  if Length(FText) < FCursorPos then
    FCursorPos := Length(FText);
  if FAOWFont.GetTextWidth(Copy(FText, FFirstChar, Length(FText) - FFirstChar)) >
    FWinWidth - 2 * FBorderWidth - 1 then
    while FAOWFont.GetTextWidth(Copy(FText, FFirstChar, Length(FText))) >
      FWinWidth - 2 * FBorderWidth - 1 do
      Inc(FFirstChar);
  FShownChars := Length(FText) - FFirstChar + 1;
  inherited SetSize;
end;

procedure TAOWEdit.SetGText(Value: string);
begin
  FText := Value;
  FSized := False;
end;

procedure TAOWEdit.SetILEdit(Value: TInterfaceIL);
begin
  if Value <> FILEdit then
  begin
    FValid := False;
    FILEdit := Value;
  end;
end;

procedure TAOWEdit.SetILIndex(Value: Integer);
begin
  if Value <> FILIndex then
  begin
    FILIndex := Value;
    FValid := False;
  end;
end;

procedure TAOWEdit.Update;
begin
  inherited Update;
  if FVisible and FEditable and (FBlinkDelay > 0) and (FRedraw = True) then
  begin
    Inc(FBlinkCount);
    if FBlinkCount > FBlinkDelay then
    begin
      FDrawn := False;
      FBlinkCount := 0;
      if FCursorShown = True then
        FCursorShown := False
      else
        FCursorShown := True;
    end;
  end;
end;

procedure TAOWEdit.Draw(SurfDesc: TSurfaceDesc);
var
  S: string;
  OldClip: TRect;
  I: Integer;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      FILEdit.DrawILLh(FILIndex, Rect(FAOWWindow.FWinLeft + FWinLeft, FAOWWindow.FWinTop + FWinTop,
        FWinWidth, FWinHeight), SurfDesc);
      OldClip := SurfDesc.ClipRect;
      if FAOWWindow.FWinLeft + FWinLeft + FWinWidth - FILEdit[FILIndex + 2].Width < OldClip.Right then
        SurfDesc.ClipRect.Right := FAOWWindow.FWinLeft + FWinLeft + FWinWidth -
          FILEdit[FILIndex + 2].Width;
      FAOWFont.Color := FColor;
      if FPassWordChar = #0 then
        FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FBorderWidth, FAOWWindow.FWinTop +
          FWinTop + FBorderHeight, Copy(FText, FFirstChar, FShownChars), SurfDesc)
      else
      begin
        S := '';
        for I := 0 to FShownChars - 1 do
          S := S + FPassWordChar;
        FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FBorderWidth, FAOWWindow.FWinTop +
          FWinTop + FBorderHeight, S, SurfDesc);
      end;
      SurfDesc.ClipRect := OldClip;
      if FEditable and (FRedraw = True) and (FCursorShown = True) then
        FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FBorderWidth +
          FAOWFont.GetTextWidth(Copy(FText, FFirstChar, FCursorPos)), FAOWWindow.FWinTop +
          FWinTop + FBorderHeight, FCursorChar, SurfDesc);
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAOWEdit.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  W, I: Integer;
  OldRedraw: Boolean;
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  FMouseDown := False;
  OldRedraw := FRedraw;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if (FValid = True) and (FVisible = True) then
    begin
      if Button = mbLeft then
      begin
        if FEditable = True then
          FRedraw := True;
        if X > FAOWWindow.FWinLeft + FWinLeft + FBorderWidth +
          FAOWFont.GetTextWidth(Copy(FText, FFirstChar, Length(FText))) then
        begin
          FFirstChar := 1;
          if FAOWFont.GetTextWidth(Copy(FText, FFirstChar, Length(FText) - FFirstChar)) >
            FWinWidth - 2 * FBorderWidth - 1 then
            while FAOWFont.GetTextWidth(Copy(FText, FFirstChar, Length(FText))) >
              FWinWidth - 2 * FBorderWidth - 1 do
              Inc(FFirstChar);
          FCursorPos := Length(FText) - FFirstChar + 1;
        end
        else
        begin
          I := 0;
          W := FAOWFont.GetTextWidth(Copy(FText, FFirstChar, I + 1));
          while (X > FAOWWindow.FWinLeft + FWinLeft + FBorderWidth + W) and
            (Length(FText) > I + FFirstChar - 1) do
          begin
            Inc(I);
            W := FAOWFont.GetTextWidth(Copy(FText, FFirstChar, I + 1));
          end;
          FCursorPos := I;
        end;
        FCursorShown := FEditable;
        FBlinkCount := 0;
        FDrawn := False;
      end;
      if Assigned(FOnMouseDown) then
        FOnMouseDown(Self, Button, Shift, X, Y);
    end;
  end
  else
  begin
    if FCursorShown then
    begin
      FCursorShown := False;
      if Assigned(FOnExit) then
        FOnExit(Self);
    end;
    FRedraw := False;
  end;
  if FRedraw <> OldRedraw then
    FDrawn := False;
end;

procedure TAOWEdit.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWEdit.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if FVisible and (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if FEditable = True then
      FAOWWindow.FCursor := crIBeam;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
end;

procedure TAOWEdit.CheckKeyPress(var Key: Char);
var
  C: Char;
  Scroll: Boolean;
begin
  FHandled := FRedraw;
  Scroll := True;
  if FEditable and (FRedraw = True) and (FValid = True) and (FVisible = True) then
  begin
    FCursorShown := True;
    case Key of
      #8:
        begin
          if FCursorPos > 0 then
          begin
            FText := Copy(FText, 1, FCursorPos + FFirstChar - 2) + Copy(FText, FCursorPos +
              FFirstChar, Length(FText) - FCursorPos - FFirstChar + 1);
            FCursorPos := FCursorPos + FFirstChar - 2;
          end;
          FFirstChar := 1;
        end;
      #13:
        begin
          FCursorShown := False;
          FRedraw := False;
          if Assigned(FOnReturn) then
            FOnReturn(Self);
        end;
      #0..#7, #9..#12, #14..#31: ;
    else
      C := Key;
      if (Length(FText) < FMaxChars) or (FMaxChars = 0) then
      begin
        FText := Copy(FText, 1, FFirstChar + FCursorPos - 1) + C + Copy(FText, FFirstChar +
          FCursorPos, Length(FText) - FCursorPos - FFirstChar + 1);
        Inc(FCursorPos);
        FCursorPos := FCursorPos + FFirstChar - 1;
        FFirstChar := 1;
      end;
    end;
    if Scroll = True then
    begin
      while FAOWFont.GetTextWidth(Copy(FText, FFirstChar, Length(FText))) >
        FWinWidth - 2 * FBorderWidth - 1 do
      begin
        Inc(FFirstChar);
        Dec(FCursorPos);
      end;
      FShownChars := Length(FText) - FFirstChar + 1;
      if FCursorPos < 0 then
        FCursorPos := 0;
    end;
    FBlinkCount := 0;
    FDrawn := False;
    if Assigned(FOnKeyPress) then
      FOnKeyPress(Self, Key);
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TAOWEdit.CheckKeyDown(var Key: Word; Shift: TShiftState);
begin
  FHandled := FRedraw;
  if FEditable and (FRedraw = True) and (FValid = True) and (FVisible = True) then
  begin
    case Key of
      VK_LEFT:
        if FCursorPos > 0 then
          Dec(FCursorPos)
        else if FFirstChar > 1 then
          Dec(FFirstChar);
      VK_RIGHT:
        if FShownChars > FCursorPos then
          Inc(FCursorPos)
        else if FFirstChar + FShownChars < Length(FText) then
          Inc(FFirstChar);
      VK_DELETE:
        if FCursorPos < Length(FText) then
        begin
          FText := Copy(FText, 1, FCursorPos + FFirstChar - 1) + Copy(FText, FCursorPos +
            FFirstChar + 1, Length(FText) - FCursorPos - FFirstChar);
          FCursorPos := FCursorPos + FFirstChar - 1;
          FFirstChar := 1;
        end;
    else
      if ssCtrl in Shift then
        case Char(Key) of
          'V', 'v':
            if Clipboard.HasFormat(CF_TEXT) then
            begin
              FText := Copy(FText, 1, FFirstChar + FCursorPos - 1) + Clipboard.AsText +
                Copy(FText, FFirstChar + FCursorPos, Length(FText) - FCursorPos - FFirstChar + 1);
              Inc(FCursorPos, Length(Clipboard.AsText));
            end;
        end;
    end;
    FShownChars := Length(FText) - FFirstChar + 1;
    if FCursorPos < 0 then
      FCursorPos := 0;
    FCursorShown := True;
    FBlinkCount := 0;
    FDrawn := False;
    if Assigned(FOnKeyDown) then
      FOnKeyDown(Self, Key, Shift);
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWEdit]);
end;

end.
