unit AoWCampaignJoin;

{ Draft declarations of AoWCampaignJoin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWMemo, AoWPanel, aowUserDrawBox;

type
  TCampaignJoinDlg = class;


  { TCampaignJoinDlg (instance size 128, VMT 00418020) }
  TCampaignJoinDlg = class(TDataModule)
  public
    published
    CharGenPnl: TAOWPanel; { +0044 }
    LeaderTypePnl: TAOWPanel; { +0048 }
    CustomBtn: TAOWButton; { +004C }
    DefaultBtn: TAOWButton; { +0050 }
    LeaderTypeMsg: TAOWMemo; { +0054 }
    DefaultFacePnl: TAOWPanel; { +0058 }
    CustomFacePnl: TAOWPanel; { +005C }
    ScrollTextDB: TaowUserDrawBox; { +0060 }
    Translator: TIvTranslator; { +0064 }
    public
    F_CampaignJoinDlg_68: Byte;
    F_CampaignJoinDlg_69: array[0..6] of Byte;
    F_CampaignJoinDlg_70: Integer;
    F_CampaignJoinDlg_74: Integer;
    F_CampaignJoinDlg_78: Integer;
    F_CampaignJoinDlg_7C: Integer;
    procedure CampaignJoinDlgCreate;  { draft }
    procedure CampaignJoinDlgDestroy;  { draft }
    procedure CharGenPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DefaultFacePnlDraw(A1: Integer; A2: Integer);  { draft }
    procedure CustomBtnClick;  { draft }
    procedure DefaultBtnClick;  { draft }
    procedure ScrollTextDBUpdate;  { draft }
    procedure ScrollTextDBDraw(A1: Integer; A2: Integer);  { draft }
    procedure DefaultFacePnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;


implementation

procedure TCampaignJoinDlg.CampaignJoinDlgCreate;
begin end;

procedure TCampaignJoinDlg.CampaignJoinDlgDestroy;
begin end;

procedure TCampaignJoinDlg.CharGenPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCampaignJoinDlg.DefaultFacePnlDraw(A1: Integer; A2: Integer);
begin end;

procedure TCampaignJoinDlg.CustomBtnClick;
begin end;

procedure TCampaignJoinDlg.DefaultBtnClick;
begin end;

procedure TCampaignJoinDlg.ScrollTextDBUpdate;
begin end;

procedure TCampaignJoinDlg.ScrollTextDBDraw(A1: Integer; A2: Integer);
begin end;

procedure TCampaignJoinDlg.DefaultFacePnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;


end.
