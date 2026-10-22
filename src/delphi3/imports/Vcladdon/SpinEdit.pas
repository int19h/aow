unit SpinEdit;

{ STUB of the third-party unit SpinEdit of Vcladdon.dpl (not recovered), with only what SoundP
  uses: the TSpin edit control of the sound effect editor (SFXEdDlg) and its static
  GetValue/SetValue. The instance layout follows notes/classes.json (instance size 336; +$130
  FMinValue, +$134 FMaxValue, +$138 FIncrement, +$13C the spin button, +$140 FEditorEnabled,
  +$144 FOnUpdate, +$14C not known); the method bodies are placeholders and are not compared. }

interface

uses
  Windows, SysUtils, Classes, Controls, StdCtrls;

type
  { SpinEdit.TSpin (instance size 336) }
  TSpin = class(TCustomEdit)
  private
    FMinValue: Longint;
    FMaxValue: Longint;
    FIncrement: Longint;
    FButton: TControl;
    FEditorEnabled: Boolean;
    FOnUpdate: TNotifyEvent;
    FReserved: Longint;
    function GetValue: Longint;
    procedure SetValue(NewValue: Longint);
  public
    property Value: Longint read GetValue write SetValue; property Color; property MaxValue: Longint read FMaxValue write FMaxValue; { AoWEd 0041581A, 00419059 }
  end;

implementation

function TSpin.GetValue: Longint;
begin
  Result := StrToIntDef(Text, FMinValue);
end;

procedure TSpin.SetValue(NewValue: Longint);
begin
  Text := IntToStr(NewValue);
end;

end.
