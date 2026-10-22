unit AoWLabel;

{ The AoWLabel unit of aowInt.dpl: TAOWLabel, a line of text in an image library font; it
  sizes itself to its text. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWToolTip, AoWControl, AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl,
  AoWBaseWin, AoWWinGeneric;

type
  { AoWLabel.TAOWLabel (instance size 276): no fields of its own }
  TAOWLabel = class(TAOWControl)
  public
    procedure Validate; override;
    procedure SetSize; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetGFont(Value: TImageLibraryFont);
    procedure SetGText(Value: string);
  published
    property AOWFont: TImageLibraryFont read FAOWFont write SetGFont;
    property Text: string read FText write SetGText;
    property TextColor;
  end;

procedure Register;

implementation

{ TAOWLabel }

procedure TAOWLabel.Validate;
begin
  if FAOWFont <> nil then
    FValid := True;
  FMasked := True;
  inherited Validate;
end;

procedure TAOWLabel.SetSize;
begin
  FWinWidth := FAOWFont.GetTextWidth(FText);
  FWinHeight := FAOWFont.GetTextHeight(FText);
  inherited SetSize;
end;

procedure TAOWLabel.SetGFont(Value: TImageLibraryFont);
begin
  if Value <> FAOWFont then
  begin
    FAOWFont := Value;
    FValid := False;
  end;
end;

procedure TAOWLabel.SetGText(Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    FSized := False;
    FAligned := False;
  end;
end;

procedure TAOWLabel.Draw(SurfDesc: TSurfaceDesc);
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      FAOWFont.Color := FColor;
      FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft, FAOWWindow.FWinTop + FWinTop, FText,
        SurfDesc);
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAOWLabel.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := FCaptureInput;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWLabel.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := FCaptureInput;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWLabel.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := FCaptureInput;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
end;

procedure TAOWLabel.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWLabel]);
end;

end.
