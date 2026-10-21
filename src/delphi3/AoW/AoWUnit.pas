unit AoWUnit;

{ Draft declarations of AoWUnit, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TMainForm = class;


  { TMainForm (instance size 528, VMT 004526C0) }
  TMainForm = class(TForm)
  public
    published
    Display: TDisplay; { +01DC }
    WinDC: TWindows16DC; { +01E0 }
    DXDC: TDDrawFullScr16DC; { +01E4 }
    public
    F_MainForm_1E8: array[0..3] of Byte;
    F_MainForm_1EC: Integer;
    F_MainForm_1F0: array[0..7] of Byte; FCursorImage: TLibraryImage; { $1F8; 0040A0E4 }
    F_MainForm_1FC: Integer;
    F_MainForm_200: Integer;
    F_MainForm_204: Integer;
    F_MainForm_208: Integer;
    F_MainForm_20C: Byte;
    F_MainForm_20D: array[0..2] of Byte;
    procedure PlayInterfaceSound(Kind: Byte);
    procedure DisplayUpdateFrame(A1: Integer; A2: Integer);  { draft }
    procedure FormCreate;  { draft }
    procedure DisplayMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DisplayMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DisplayMouseUp(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DisplayKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure DisplayResizeBackSurface(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure DisplayDblClick;  { draft }
    procedure DisplaySurfaceDataLost;  { draft }
    procedure FormDestroy;  { draft }
    procedure DisplayActivateDC(A1: Integer; A2: Integer);  { draft }
    procedure FormShow;  { draft }
    procedure DisplayKeyPress(A1: Integer; A2: Integer);  { draft }
    procedure FormCloseQuery(A1: Integer; A2: Integer);  { draft }
    procedure DisplaySwapDC(A1: Integer);  { draft }
  end;


var
  MainForm: TMainForm;

implementation

procedure TMainForm.PlayInterfaceSound(Kind: Byte);
begin
  case Kind of
    0: PlaySample('Sfx\Int\Btn1.wav');
    1: PlaySample('Sfx\Int\Btn5.wav');
    2: PlaySample('Sfx\Int\Btn6.wav');
    3: PlaySample('Sfx\Int\Btn3.wav');
  end;
end;

procedure TMainForm.DisplayUpdateFrame(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.FormCreate;
begin end;

procedure TMainForm.DisplayMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMainForm.DisplayMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMainForm.DisplayMouseUp(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMainForm.DisplayKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMainForm.DisplayResizeBackSurface(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMainForm.DisplayDblClick;
begin end;

procedure TMainForm.DisplaySurfaceDataLost;
begin end;

procedure TMainForm.FormDestroy;
begin end;

procedure TMainForm.DisplayActivateDC(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.FormShow;
begin end;

procedure TMainForm.DisplayKeyPress(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.FormCloseQuery(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.DisplaySwapDC(A1: Integer);
begin end;


end.
