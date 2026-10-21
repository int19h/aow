unit Spin;

{ Draft declarations of Spin, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Buttons;

type
  TSpinButton = class;
  TSpinEdit = class;
  TTimerSpeedButton = class;


  { TSpinButton (instance size 312, VMT 0040BE70) }
  TSpinButton = class(TWinControl)
  public
    F_SpinButton_118: array[0..31] of Byte;
    procedure Loaded; override;
    procedure Notification(AComponent: Classes.TComponent; Operation: Classes.TOperation); override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  end;

  { TSpinEdit (instance size $144, VMT 0040C300): $140 FEditorEnabled. }
  TSpinEdit = class(TCustomEdit)
  public
    F_SpinEdit_130: array[0..11] of Byte;
    F_SpinEdit_13C: Integer;
    FEditorEnabled: Boolean; { $140 }
    F_SpinEdit_141: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure CreateParams(var Params: Controls.TCreateParams); override;
    procedure CreateWnd; override;
    function IsValidChar(Key: Char): Boolean; virtual; { +09C }
    procedure vmtA0; virtual;  { +0A0 draft }
    procedure vmtA4; virtual;  { +0A4 draft }
  end;

  { TTimerSpeedButton (instance size 216, VMT 0040C9B4) }
  TTimerSpeedButton = class(TSpeedButton)
  public
    F_TimerSpeedButton_D0: array[0..7] of Byte;
    destructor Destroy; override;
    procedure Paint; override;
  end;


implementation

constructor TSpinButton.Create(AOwner: Classes.TComponent);
begin end;

procedure TSpinButton.Notification(AComponent: Classes.TComponent; Operation: Classes.TOperation);
begin end;

procedure TSpinButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin end;

procedure TSpinButton.Loaded;
begin end;

constructor TSpinEdit.Create(AOwner: Classes.TComponent);
begin end;

destructor TSpinEdit.Destroy;
begin end;

function TSpinEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := (Key in [DecimalSeparator, '+', '-', '0'..'9']) or
    ((Key < #32) and (Key <> Chr(VK_RETURN)));
  if not FEditorEnabled and Result and ((Key >= #32) or
      (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE))) then
    Result := False;
end;

procedure TSpinEdit.CreateParams(var Params: Controls.TCreateParams);
begin end;

procedure TSpinEdit.CreateWnd;
begin end;

procedure TSpinEdit.vmtA0;
begin end;

procedure TSpinEdit.vmtA4;
begin end;

destructor TTimerSpeedButton.Destroy;
begin end;

procedure TTimerSpeedButton.Paint;
begin end;


end.
