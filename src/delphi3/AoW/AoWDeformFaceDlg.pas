unit AoWDeformFaceDlg;

{ Draft declarations of AoWDeformFaceDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWWindow;

type
  TDeformFaceDlg = class;


  { TDeformFaceDlg (instance size 144, VMT 00445340) }
  TDeformFaceDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    FaceFrame: TAoWFrame; { +0048 }
    CancelBtn: TAOWButton; { +004C }
    TitleIcon: TAOWImage; { +0050 }
    Title: TAOWLabel; { +0054 }
    CastBtn: TAOWButton; { +0058 }
    SelectNewFaceLbl: TAOWLabel; { +005C }
    Close: TAOWButton; { +0060 }
    LeftFace: TAoWFrame; { +0064 }
    RightFace: TAoWFrame; { +0068 }
    AoWFrame1: TAoWFrame; { +006C }
    CeltM: TAOWImage; { +0070 }
    CeltL: TAOWImage; { +0074 }
    CeltR: TAOWImage; { +0078 }
    PrevFaceBtn: TAOWButton; { +007C }
    NextFaceBtn: TAOWButton; { +0080 }
    UnitNameLbl: TAOWLabel; { +0084 }
    Translator: TIvTranslator; { +0088 }
    public
    F_DeformFaceDlg_8C: Integer;
    procedure CancelBtnClick;  { draft }
    procedure CastBtnClick;  { draft }
    procedure DrawFace(A1: Integer; A2: Integer);  { draft }
    procedure PrevFaceBtnClick;  { draft }
    procedure NextFaceBtnClick;  { draft }
    procedure DlgHide;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TDeformFaceDlg.CancelBtnClick;
begin end;

procedure TDeformFaceDlg.CastBtnClick;
begin end;

procedure TDeformFaceDlg.DrawFace(A1: Integer; A2: Integer);
begin end;

procedure TDeformFaceDlg.PrevFaceBtnClick;
begin end;

procedure TDeformFaceDlg.NextFaceBtnClick;
begin end;

procedure TDeformFaceDlg.DlgHide;
begin end;

procedure TDeformFaceDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
