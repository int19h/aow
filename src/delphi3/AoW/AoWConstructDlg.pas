unit AoWConstructDlg;

{ Construction selection, costs and activation recovered from AoW.exe.
  Layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TConstructDlg = class;


  { TConstructDlg: size $98; $94 activation request. VMT 00431368. }
  TConstructDlg = class(TDataModule)
  public
    published
    TitleIcon: TAOWImage; { +0044 }
    Close: TAOWButton; { +0048 }
    Title: TAOWLabel; { +004C }
    BCeltL: TAoWFrame; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    ConstructBtn: TAOWButton; { +0058 }
    Dlg: TAOWWindow; { +005C }
    ConstructPnl: TAOWPanel; { +0060 }
    ConstructionList: TAOWListBox; { +0064 }
    SortConstructionsBtn: TAOWButton; { +0068 }
    SortConstructionCostBtn: TAOWButton; { +006C }
    ConstructionCostList: TAOWListBox; { +0070 }
    ConstructionTurnsList: TAOWListBox; { +0074 }
    SortConstructionTurnsBtn: TAOWButton; { +0078 }
    AOWLabel1: TAOWLabel; { +007C }
    ConSB: TAOWVScrollBar; { +0080 }
    CeltM: TAOWImage; { +0084 }
    AOWButton2: TAOWButton; { +0088 }
    T4VSB: TAOWVScrollBar; { +008C }
    Translator: TIvTranslator; { +0090 }
    public
    FRequest: TActivateAbilityInfo; { $94 }
    procedure Execute(Request: TActivateAbilityInfo);
    procedure Finish;
    procedure UpdateConstructions;
    procedure SelectConstruction(Index: Integer);
    published procedure CancelBtnClick; public
    published procedure ConstructionListChange; public
    published procedure ConstructionCostListChange; public
    published procedure ConstructionTurnsListChange; public
    published procedure ConstructBtnClick(Sender: TObject); public
    published procedure SortConstructionsBtnClick; public
    published procedure SortConstructionCostBtnClick; public
    published procedure SortConstructionTurnsBtnClick; public
    published procedure DlgHide; public
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


implementation

uses AoWWinMan;

procedure TConstructDlg.CancelBtnClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TConstructDlg.ConstructionListChange;
begin SelectConstruction(ConstructionList.Selected); end;

procedure TConstructDlg.ConstructionCostListChange;
begin SelectConstruction(ConstructionCostList.Selected); end;

procedure TConstructDlg.ConstructionTurnsListChange;
begin SelectConstruction(ConstructionTurnsList.Selected); end;

procedure TConstructDlg.ConstructBtnClick(Sender: TObject);
var
  Reason: string;
  Control: TConstructionControl;
  U: TAbstractUnit;
begin
  General.PlayButtonSound(0);
  if (ConstructionList.Selected >= 0) and (ConstructionList.Selected < ConstructionList.Items.Count) then
  begin
    U := AoWHSMap.FUnitControl.FindUnit(FRequest.FUnitID);
    Control := TConstructionControl(ConstructionList.Items.Objects[ConstructionList.Selected]);
    if Control.CanConstruct(U, Reason) then
    begin
      if Control.Construct(U) then Dlg.Visible := False;
    end
    else AoWHSMap.ShowWarning(Reason);
  end;
end;

procedure TConstructDlg.SortConstructionsBtnClick;
begin General.PlayButtonSound(0); end;

procedure TConstructDlg.SortConstructionCostBtnClick;
begin General.PlayButtonSound(0); end;

procedure TConstructDlg.SortConstructionTurnsBtnClick;
begin General.PlayButtonSound(0); end;

procedure TConstructDlg.DlgHide;
begin Finish; end;

procedure TConstructDlg.Finish;
begin
  if FRequest <> nil then
  begin
    FRequest.Release;
    FRequest := nil;
  end;
end;

procedure TConstructDlg.Execute(Request: TActivateAbilityInfo);
begin
  if FRequest <> nil then FRequest.Release;
  FRequest := Request;
  FRequest.AddRef;
  UpdateConstructions;
  Dlg.Visible := True;
end;

procedure TConstructDlg.SelectConstruction(Index: Integer);
begin
  if (Index >= 0) and (Index < ConstructionList.Items.Count) then
  begin
    ConstructionList.Selected := Index;
    ConstructionCostList.Selected := Index;
    ConstructionTurnsList.Selected := Index;
  end
  else
  begin
    ConstructionList.Selected := -1;
    ConstructionCostList.Selected := -1;
    ConstructionTurnsList.Selected := -1;
  end;
end;

procedure TConstructDlg.UpdateConstructions;
var
  Days, Gold: Integer;
  U: TAbstractUnit;
  Name: string;
  I: Integer;
  Ability: TConstructAbility;
  Control: TConstructionControl;
begin
  Dlg.FDrawn := False;
  U := AoWHSMap.FUnitControl.FindUnit(FRequest.FUnitID);
  ConstructionList.Items.Clear;
  ConstructionCostList.Items.Clear;
  ConstructionTurnsList.Items.Clear;
  Ability := TConstructAbility(AoWHSSet.FAbilityControl.GetAbility(125));
  for I := 0 to Ability.FConstructionControls.Count - 1 do
  begin
    Control := Ability.FConstructionControls.GetConstructionControl(I);
    Control.GetInfo(U, Name, Gold, Days);
    ConstructionList.Items.AddObject(Name, Control);
    if Gold <> 0 then ConstructionCostList.Items.Add(IntToStr(Gold))
    else ConstructionCostList.Items.Add('-');
    if Days <> 0 then ConstructionTurnsList.Items.Add(IntToStr(Days))
    else ConstructionTurnsList.Items.Add('-');
  end;
end;

procedure TConstructDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin if Key = VK_ESCAPE then Dlg.Visible := False; end;

end.
