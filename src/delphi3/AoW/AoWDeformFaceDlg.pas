unit AoWDeformFaceDlg;

{ Cosmetic-surgery face selection and casting recovered from AoW.exe.
  Layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, UnitSpells, AoWComp, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWWindow;

type
  TDeformFaceDlg = class;


  { TDeformFaceDlg: size $90; $8C cosmetic-surgery caster. VMT 00445340. }
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
    FCaster: TCosmeticSurgerySpellCaster; { $8C }
    procedure Execute(Caster: TCosmeticSurgerySpellCaster);
    procedure Finish;
    procedure CancelBtnClick;
    procedure CastBtnClick;
    procedure DrawFace(Sender: TObject; SD: TSurfaceDesc);
    procedure PrevFaceBtnClick;
    procedure NextFaceBtnClick;
    procedure DlgHide;
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses AoWWinMan;

procedure TDeformFaceDlg.CancelBtnClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TDeformFaceDlg.CastBtnClick;
var Reason: string;
begin
  General.PlayButtonSound(0);
  if FCaster.CanCast(Reason) then
  begin
    FCaster.Cast;
    Dlg.Visible := False;
  end
  else AoWHSMap.ShowMessage(Reason);
end;

procedure TDeformFaceDlg.DrawFace(Sender: TObject; SD: TSurfaceDesc);
var
  R: TRect;
  Face, Offset: Integer;
  Resource: TFaceResource;
begin
  Offset := TComponent(Sender).Tag;
  Face := FCaster.FFaceIndex;
  while Offset < 0 do
  begin
    Inc(Offset);
    Face := AoWHSSet.FFaceResources.PrevFace(Face);
  end;
  while Offset > 0 do
  begin
    Dec(Offset);
    Face := AoWHSSet.FFaceResources.NextFace(Face);
  end;
  R := Rect(Dlg.WinLeft + TAoWComponent(Sender).WinLeft + 2,
    Dlg.WinTop + TAoWComponent(Sender).WinTop,
    Dlg.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth - 2,
    Dlg.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight - 2);
  if Face <> -1 then
  begin
    Resource := AoWHSSet.FFaceResources.GetFaceResource(Face);
    Resource.AddRef;
    Resource.GetFaceImage.ShowStretched(R, SD);
    Resource.Release;
  end;
end;

procedure TDeformFaceDlg.PrevFaceBtnClick;
begin
  General.PlayButtonSound(0);
  FCaster.FFaceIndex := AoWHSSet.FFaceResources.PrevFace(FCaster.FFaceIndex);
  Dlg.FDrawn := False;
end;

procedure TDeformFaceDlg.NextFaceBtnClick;
begin
  General.PlayButtonSound(0);
  FCaster.FFaceIndex := AoWHSSet.FFaceResources.NextFace(FCaster.FFaceIndex);
  Dlg.FDrawn := False;
end;

procedure TDeformFaceDlg.DlgHide;
begin Finish; end;

procedure TDeformFaceDlg.Finish;
begin
  FCaster.Release;
  FCaster := nil;
end;

procedure TDeformFaceDlg.Execute(Caster: TCosmeticSurgerySpellCaster);
var
  U: TAbstractUnit;
begin
  FCaster := Caster;
  FCaster.AddRef;
  U := AoWHSMap.FUnitControl.FindUnit(FCaster.FTargetUnitID);
  if U <> nil then
  begin
    UnitNameLbl.Text := U.GetName;
    Dlg.Visible := True;
  end
  else Finish;
end;

procedure TDeformFaceDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Dlg.Visible := False;
end;

end.
