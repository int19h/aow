unit GameSDlg;

{ Draft declarations of GameSDlg, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, SpinEdit;

type
  TGameSettingsDlg = class;


  { TGameSettingsDlg (instance size 568, VMT 0042D8CC) }
  TGameSettingsDlg = class(TForm)
  public
    published
    BottomPnl: TPanel; { +01DC }
    ClientPnl: TPanel; { +01E0 }
    OKBtn: TButton; { +01E4 }
    CancelBtn: TButton; { +01E8 }
    MainPageControl: TPageControl; { +01EC }
    GeneralSheet: TTabSheet; { +01F0 }
    Bevel1: TBevel; { +01F4 }
    TransferSettingsLbl: TLabel; { +01F8 }
    TransferPointsLbl: TLabel; { +01FC }
    MaxHeroLevelMaxLbl: TLabel; { +0200 }
    TransferGoldLbl: TLabel; { +0204 }
    TransferManaLbl: TLabel; { +0208 }
    TransferPointsMaxEdit: TSpin; { +020C }
    TransferGoldMaxEdit: TSpin; { +0210 }
    TransferManaMaxEdit: TSpin; { +0214 }
    HeroLevelMaxEdit: TSpin; { +0218 }
    Bevel3: TBevel; { +021C }
    AlliedVictoryCB: TCheckBox; { +0220 }
    GameTypeLbl: TLabel; { +0224 }
    GameTypeCB: TComboBox; { +0228 }
    TurnLimitationLbl: TLabel; { +022C }
    TurnLimitationEdit: TSpin; { +0230 }
    DemoMapCB: TCheckBox; { +0234 }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
    procedure GameTypeCBChange;  { draft }
  end;


implementation

procedure TGameSettingsDlg.FormCreate;
begin end;

procedure TGameSettingsDlg.OKBtnClick;
begin end;

procedure TGameSettingsDlg.GameTypeCBChange;
begin end;


end.
