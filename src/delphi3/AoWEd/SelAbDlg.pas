unit SelAbDlg;

{ Draft declarations of SelAbDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWDlg;

type
  TAbilitySelectionDlg = class;


  { TAbilitySelectionDlg (instance size 536, VMT 00410004) }
  TAbilitySelectionDlg = class(TAoWDialog)
  public
    published
    BottomPnl: TPanel; { +01E0 }
    OKBtn: TButton; { +01E4 }
    CancelBtn: TButton; { +01E8 }
    ClientPnl: TPanel; { +01EC }
    MainPageControl: TPageControl; { +01F0 }
    GeneralSheet: TTabSheet; { +01F4 }
    AddBtn: TButton; { +01F8 }
    DeleteBtn: TButton; { +01FC }
    SelectedAbBox: TListBox; { +0200 }
    AvailableAbBox: TListBox; { +0204 }
    Panel2: TPanel; { +0208 }
    Panel3: TPanel; { +020C }
    Translator: TIvTranslator; { +0210 }
    public
    F_AbilitySelectionDlg_214: Integer;
    destructor Destroy; override;
    procedure vmt80; virtual;  { +080 draft }
    procedure vmt84; virtual;  { +084 draft }
    procedure vmt88(A1: Integer; A2: Integer); virtual;  { +088 draft }
    procedure vmt8C(A1: Integer; A2: Integer); virtual;  { +08C draft }
    function vmt90: Byte; virtual;  { +090 draft }
    procedure vmt94(A1: Integer); virtual;  { +094 draft }
    procedure AddBtnClick;  { draft }
    procedure DeleteBtnClick;  { draft }
    procedure FormShow;  { draft }
    procedure AvailableAbBoxClick;  { draft }
    procedure SelectedAbBoxClick;  { draft }
  end;


implementation

destructor TAbilitySelectionDlg.Destroy;
begin end;

procedure TAbilitySelectionDlg.vmt80;
begin end;

procedure TAbilitySelectionDlg.vmt84;
begin end;

procedure TAbilitySelectionDlg.vmt88(A1: Integer; A2: Integer);
begin end;

procedure TAbilitySelectionDlg.vmt8C(A1: Integer; A2: Integer);
begin end;

function TAbilitySelectionDlg.vmt90: Byte;
begin Result := 0; end;

procedure TAbilitySelectionDlg.vmt94(A1: Integer);
begin end;

procedure TAbilitySelectionDlg.AddBtnClick;
begin end;

procedure TAbilitySelectionDlg.DeleteBtnClick;
begin end;

procedure TAbilitySelectionDlg.FormShow;
begin end;

procedure TAbilitySelectionDlg.AvailableAbBoxClick;
begin end;

procedure TAbilitySelectionDlg.SelectedAbBoxClick;
begin end;


end.
