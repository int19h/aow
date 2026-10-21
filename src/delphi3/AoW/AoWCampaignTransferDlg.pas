unit AoWCampaignTransferDlg;

{ Draft declarations of AoWCampaignTransferDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWBookWindow, AoWButton, AoWCheckBox, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWPanel;

type
  TCampaignTransferDlg = class;


  { TCampaignTransferDlg (instance size 464, VMT 0040C058) }
  TCampaignTransferDlg = class(TDataModule)
  public
    published
    LHero1: TAOWCheckBox; { +0044 }
    LHero2: TAOWCheckBox; { +0048 }
    LHero3: TAOWCheckBox; { +004C }
    LHero4: TAOWCheckBox; { +0050 }
    LItem1: TAOWCheckBox; { +0054 }
    LItemPnl: TAOWPanel; { +0058 }
    LItem2: TAOWCheckBox; { +005C }
    LItem3: TAOWCheckBox; { +0060 }
    LItem4: TAOWCheckBox; { +0064 }
    LUnit1: TAOWCheckBox; { +0068 }
    LUnitPnl: TAOWPanel; { +006C }
    LUnit2: TAOWCheckBox; { +0070 }
    LUnit3: TAOWCheckBox; { +0074 }
    LUnit4: TAOWCheckBox; { +0078 }
    Available: TAOWLabel; { +007C }
    TransBookWin: TAoWBookWindow; { +0080 }
    BookStart: TAOWButton; { +0084 }
    Cancel: TAOWButton; { +0088 }
    PnlL: TAOWPanel; { +008C }
    Title: TAOWLabel; { +0090 }
    PnlR: TAOWPanel; { +0094 }
    TransferPointsLbl: TAOWLabel; { +0098 }
    AddBtn: TAOWButton; { +009C }
    LGoldLbl: TAOWLabel; { +00A0 }
    GoldLeftLbl: TAOWLabel; { +00A4 }
    LManaLbl: TAOWLabel; { +00A8 }
    ManaLeftLbl: TAOWLabel; { +00AC }
    Next: TAOWLabel; { +00B0 }
    LSep1: TAoWFrame; { +00B4 }
    LHeroImgL: TAOWImage; { +00B8 }
    LHeroPnl: TAOWPanel; { +00BC }
    LItemImgL: TAOWImage; { +00C0 }
    LUnitImgL: TAOWImage; { +00C4 }
    LHeroImgR: TAOWImage; { +00C8 }
    LItemImgR: TAOWImage; { +00CC }
    LUnitImgR: TAOWImage; { +00D0 }
    RHero1: TAOWCheckBox; { +00D4 }
    RHero2: TAOWCheckBox; { +00D8 }
    RHero3: TAOWCheckBox; { +00DC }
    RHero4: TAOWCheckBox; { +00E0 }
    RItem1: TAOWCheckBox; { +00E4 }
    RItemPnl: TAOWPanel; { +00E8 }
    RItem2: TAOWCheckBox; { +00EC }
    RItem3: TAOWCheckBox; { +00F0 }
    RItem4: TAOWCheckBox; { +00F4 }
    RUnit1: TAOWCheckBox; { +00F8 }
    RUnitPnl: TAOWPanel; { +00FC }
    RUnit2: TAOWCheckBox; { +0100 }
    RUnit3: TAOWCheckBox; { +0104 }
    RUnit4: TAOWCheckBox; { +0108 }
    RHeroImgL: TAOWImage; { +010C }
    RHeroPnl: TAOWPanel; { +0110 }
    RItemImgL: TAOWImage; { +0114 }
    RUnitImgL: TAOWImage; { +0118 }
    RHeroImgR: TAOWImage; { +011C }
    RItemImgR: TAOWImage; { +0120 }
    RUnitImgR: TAOWImage; { +0124 }
    RSep1: TAoWFrame; { +0128 }
    RemoveBtn: TAOWButton; { +012C }
    LSep2: TAoWFrame; { +0130 }
    RSep2: TAoWFrame; { +0134 }
    GoldSlider: TAOWHScrollBar; { +0138 }
    ManaSlider: TAOWHScrollBar; { +013C }
    LHeroLB: TAOWButton; { +0140 }
    AutoBtn: TAOWButton; { +0144 }
    LItemLB: TAOWButton; { +0148 }
    LUnitLB: TAOWButton; { +014C }
    LHeroRB: TAOWButton; { +0150 }
    LItemRB: TAOWButton; { +0154 }
    LUnitRB: TAOWButton; { +0158 }
    RHeroLB: TAOWButton; { +015C }
    RItemLB: TAOWButton; { +0160 }
    RUnitLB: TAOWButton; { +0164 }
    RHeroRB: TAOWButton; { +0168 }
    RItemRB: TAOWButton; { +016C }
    RUnitRB: TAOWButton; { +0170 }
    CostImg: TAOWImage; { +0174 }
    CostPnl: TAOWPanel; { +0178 }
    CostLbl: TAOWLabel; { +017C }
    LGoldImg: TAOWImage; { +0180 }
    LManaImg: TAOWImage; { +0184 }
    TGoldLbl: TAOWLabel; { +0188 }
    TransferGoldLbl: TAOWLabel; { +018C }
    TManaLbl: TAOWLabel; { +0190 }
    TransferManaLbl: TAOWLabel; { +0194 }
    RGoldImg: TAOWImage; { +0198 }
    RManaImg: TAOWImage; { +019C }
    ResBackG: TAOWImage; { +01A0 }
    Translator: TIvTranslator; { +01A4 }
    public
    F_CampaignTransferDlg_1A8: Integer;
    F_CampaignTransferDlg_1AC: Integer;
    F_CampaignTransferDlg_1B0: Integer;
    F_CampaignTransferDlg_1B4: Integer;
    F_CampaignTransferDlg_1B8: Integer;
    F_CampaignTransferDlg_1BC: Integer;
    F_CampaignTransferDlg_1C0: Byte;
    F_CampaignTransferDlg_1C1: array[0..2] of Byte;
    F_CampaignTransferDlg_1C4: Integer;
    F_CampaignTransferDlg_1C8: Byte;
    F_CampaignTransferDlg_1C9: array[0..2] of Byte;
    F_CampaignTransferDlg_1CC: Integer;
    procedure BookStartClick;  { draft }
    procedure CancelClick;  { draft }
    procedure GoldSliderChange;  { draft }
    procedure ManaSliderChange;  { draft }
    procedure LHeroLBClick;  { draft }
    procedure LHeroRBClick;  { draft }
    procedure LItemLBClick;  { draft }
    procedure LItemRBClick;  { draft }
    procedure LUnitLBClick;  { draft }
    procedure LUnitRBClick;  { draft }
    procedure RHeroLBClick;  { draft }
    procedure RHeroRBClick;  { draft }
    procedure RItemLBClick;  { draft }
    procedure RItemRBClick;  { draft }
    procedure RUnitLBClick;  { draft }
    procedure RUnitRBClick;  { draft }
    procedure LHeroesDraw(A1: Integer; A2: Integer);  { draft }
    procedure RHeroesDraw(A1: Integer; A2: Integer);  { draft }
    procedure LUnitsDraw(A1: Integer; A2: Integer);  { draft }
    procedure RUnitsDraw(A1: Integer; A2: Integer);  { draft }
    procedure LItemsDraw(A1: Integer; A2: Integer);  { draft }
    procedure RItemsDraw(A1: Integer; A2: Integer);  { draft }
    procedure LHeroesSelect(A1: Integer);  { draft }
    procedure LItemsSelect(A1: Integer);  { draft }
    procedure LUnitSelect(A1: Integer);  { draft }
    procedure RHeroesSelect(A1: Integer);  { draft }
    procedure RItemsSelect(A1: Integer);  { draft }
    procedure RUnitsSelect(A1: Integer);  { draft }
    procedure AddBtnClick;  { draft }
    procedure RemoveBtnClick;  { draft }
    procedure LHeroesUpdate(A1: Integer);  { draft }
    procedure LItemsUpdate(A1: Integer);  { draft }
    procedure LUnitsUpdate(A1: Integer);  { draft }
    procedure RHeroesUpdate(A1: Integer);  { draft }
    procedure RItemsUpdate(A1: Integer);  { draft }
    procedure RUnitsUpdate(A1: Integer);  { draft }
    procedure AutoBtnClick;  { draft }
  end;


implementation

procedure TCampaignTransferDlg.BookStartClick;
begin end;

procedure TCampaignTransferDlg.CancelClick;
begin end;

procedure TCampaignTransferDlg.GoldSliderChange;
begin end;

procedure TCampaignTransferDlg.ManaSliderChange;
begin end;

procedure TCampaignTransferDlg.LHeroLBClick;
begin end;

procedure TCampaignTransferDlg.LHeroRBClick;
begin end;

procedure TCampaignTransferDlg.LItemLBClick;
begin end;

procedure TCampaignTransferDlg.LItemRBClick;
begin end;

procedure TCampaignTransferDlg.LUnitLBClick;
begin end;

procedure TCampaignTransferDlg.LUnitRBClick;
begin end;

procedure TCampaignTransferDlg.RHeroLBClick;
begin end;

procedure TCampaignTransferDlg.RHeroRBClick;
begin end;

procedure TCampaignTransferDlg.RItemLBClick;
begin end;

procedure TCampaignTransferDlg.RItemRBClick;
begin end;

procedure TCampaignTransferDlg.RUnitLBClick;
begin end;

procedure TCampaignTransferDlg.RUnitRBClick;
begin end;

procedure TCampaignTransferDlg.LHeroesDraw(A1: Integer; A2: Integer);
begin end;

procedure TCampaignTransferDlg.RHeroesDraw(A1: Integer; A2: Integer);
begin end;

procedure TCampaignTransferDlg.LUnitsDraw(A1: Integer; A2: Integer);
begin end;

procedure TCampaignTransferDlg.RUnitsDraw(A1: Integer; A2: Integer);
begin end;

procedure TCampaignTransferDlg.LItemsDraw(A1: Integer; A2: Integer);
begin end;

procedure TCampaignTransferDlg.RItemsDraw(A1: Integer; A2: Integer);
begin end;

procedure TCampaignTransferDlg.LHeroesSelect(A1: Integer);
begin end;

procedure TCampaignTransferDlg.LItemsSelect(A1: Integer);
begin end;

procedure TCampaignTransferDlg.LUnitSelect(A1: Integer);
begin end;

procedure TCampaignTransferDlg.RHeroesSelect(A1: Integer);
begin end;

procedure TCampaignTransferDlg.RItemsSelect(A1: Integer);
begin end;

procedure TCampaignTransferDlg.RUnitsSelect(A1: Integer);
begin end;

procedure TCampaignTransferDlg.AddBtnClick;
begin end;

procedure TCampaignTransferDlg.RemoveBtnClick;
begin end;

procedure TCampaignTransferDlg.LHeroesUpdate(A1: Integer);
begin end;

procedure TCampaignTransferDlg.LItemsUpdate(A1: Integer);
begin end;

procedure TCampaignTransferDlg.LUnitsUpdate(A1: Integer);
begin end;

procedure TCampaignTransferDlg.RHeroesUpdate(A1: Integer);
begin end;

procedure TCampaignTransferDlg.RItemsUpdate(A1: Integer);
begin end;

procedure TCampaignTransferDlg.RUnitsUpdate(A1: Integer);
begin end;

procedure TCampaignTransferDlg.AutoBtnClick;
begin end;


end.
