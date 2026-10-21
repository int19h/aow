unit AoWDisjunctionDlg;

{ Draft declarations of AoWDisjunctionDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow, aowUserDrawBox, AoWComp, AoWE, GlobalSpells;

type
  TDisjunctionDlg = class;


  { TDisjunctionDlg (instance size $B0, VMT 0043285C): $A4 caster, $A8 sort order, $AC..$AE map location. }
  TDisjunctionDlg = class(TDataModule)
  public
    published
    TitleIcon: TAOWImage; { +0044 }
    Title: TAOWLabel; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    CancelBtn: TAOWButton; { +0050 }
    CastBtn: TAOWButton; { +0054 }
    Dlg: TAOWWindow; { +0058 }
    DisjunctionChance: TAOWLabel; { +005C }
    DisjunctionChanceLbl: TAOWLabel; { +0060 }
    DisjunctionChancePnl: TAOWPanel; { +0064 }
    DisjunctionMana: TAOWLabel; { +0068 }
    DisjunctionManaLbl: TAOWLabel; { +006C }
    DisjunctionManaPnl: TAOWPanel; { +0070 }
    T4LBPnl: TAOWPanel; { +0074 }
    OwnerList: TAOWListBox; { +0078 }
    EnchantmentList: TAOWListBox; { +007C }
    Sort: TAOWButton; { +0080 }
    SortEnchantment: TAOWButton; { +0084 }
    EnchantmentsScrollBar: TAOWVScrollBar; { +0088 }
    Spell: TAOWLabel; { +008C }
    ChanceSlider: TAOWHScrollBar; { +0090 }
    Close: TAOWButton; { +0094 }
    Translator: TIvTranslator; { +0098 }
    MapViewPnl: TAOWPanel; { +009C }
    MapView: TaowUserDrawBox; { +00A0 }
    public
    FCaster: TDisjunctionSpellCaster; { $A4 }
    FSortOrder: Integer; { $A8 }
    FMapX: Shortint; { $AC }
    FMapY: Shortint; { $AD }
    FMapL: Shortint; { $AE }
    F_DisjunctionDlg_AF: array[0..0] of Byte;
    procedure ClearCaster;
    procedure UpdateEnchantments;
    procedure SortEnchantments;
    procedure UpdateChance;
    procedure SelectEnchantment(Index: Integer);
    procedure Execute(Caster: TDisjunctionSpellCaster);
    procedure CancelBtnClick;
    procedure CastBtnClick;
    procedure EnchantmentListChange;
    procedure OwnerListChange;
    procedure ChanceSliderChange;
    procedure EnchantmentsScrollBarChange;
    procedure SortEnchantmentClick;
    procedure SortClick;
    procedure DlgHide;
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MapViewDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
    procedure MapViewUpdate;
  end;


implementation

uses E3Globals, AoWWinMan;

procedure TDisjunctionDlg.CancelBtnClick;
begin
  Dlg.Visible := False;
end;


procedure TDisjunctionDlg.CastBtnClick;
var
  Reason: string;
begin
  if FCaster.CanCast(Reason) then
  begin
    if FCaster.Cast then Dlg.Visible := False;
  end
  else AoWHSMap.ShowMessage(Reason);
end;


procedure TDisjunctionDlg.EnchantmentListChange;
begin
  SelectEnchantment(EnchantmentList.Selected);
end;


procedure TDisjunctionDlg.OwnerListChange;
begin
  SelectEnchantment(OwnerList.Selected);
end;


procedure TDisjunctionDlg.ChanceSliderChange;
begin
  FCaster.SetDispelChance(ChanceSlider.Position);
  UpdateChance;
end;


procedure TDisjunctionDlg.EnchantmentsScrollBarChange;
begin
  EnchantmentList.ListOffset := EnchantmentsScrollBar.Position;
  OwnerList.ListOffset := EnchantmentsScrollBar.Position;
end;


procedure TDisjunctionDlg.SortEnchantmentClick;
begin
  General.PlayButtonSound(0);
  if FSortOrder = 0 then FSortOrder := 1 else FSortOrder := 0;
  SortEnchantments;
end;


procedure TDisjunctionDlg.SortClick;
begin
  General.PlayButtonSound(0);
  if FSortOrder = 2 then FSortOrder := 3 else FSortOrder := 2;
  SortEnchantments;
end;


procedure TDisjunctionDlg.DlgHide;
begin
  ClearCaster;
end;


procedure TDisjunctionDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Dlg.Visible := False;
end;


procedure TDisjunctionDlg.MapViewDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  R: TRect;
  MapSD: TSurfaceDesc;
  X, Y: Integer;
begin
  R := Rect(Dlg.WinLeft + Sender.WinLeft + 1, Dlg.WinTop + Sender.WinTop + 1,
    Dlg.WinLeft + Sender.WinLeft + Sender.WinWidth - 2, Dlg.WinTop + Sender.WinTop + Sender.WinHeight - 2);
  HXtoHP(FMapX, FMapY, X, Y);
  X := X + 16 - ((R.Right - R.Left) shr 1);
  Y := Y + 16 - ((R.Bottom - R.Top) shr 1);
  if X < 16 then X := 16;
  if Y < 16 then Y := 16;
  CreateSDfromSD(SD, R, MapSD);
  AoWHSMap.SetViewPort(X, Y, FMapL, R.Right - R.Left, R.Bottom - R.Top);
  AoWHSMap.UpdateStaticScene;
  AoWHSMap.UpdateDynamicScene;
  AoWHSMap.DrawStaticScene(MapSD);
  AoWHSMap.DrawDynamicScene(MapSD);
end;


procedure TDisjunctionDlg.MapViewUpdate;
begin
  General.Manager.OverlayPriority := $31;
  MapView.FDrawn := MapView.FDrawn and ((AoWHSMap.Frame and 1) <> 0);
end;




procedure TDisjunctionDlg.ClearCaster;
begin
  General.Manager.OverlayPriority := 0;
  if FCaster <> nil then
  begin
    FCaster.Release;
    FCaster := nil;
  end;
end;

procedure TDisjunctionDlg.UpdateEnchantments;
var
  Magic: TGlobalMagicControl;
  I: Integer;
  Reason: string;
begin
  Magic := AoWHSMap.FGlobalMagicControl;
  EnchantmentList.Items.Clear;
  OwnerList.Items.Clear;
  for I := 0 to Magic.FEnchantments.Count - 1 do
    if Magic.FEnchantments.GetEnchantments(I).FPlayerIndex <> AoWHSMap.FSeatedPlayer then
      if Magic.FEnchantments.GetEnchantments(I).VisibleForPlayer(AoWHSMap.FSeatedPlayer) then
        if Magic.FEnchantments.GetEnchantments(I).CanDispel(AoWHSMap.FSeatedPlayer, Reason) then
        begin
          Reason := Magic.FEnchantments.GetEnchantments(I).GetName;
          EnchantmentList.Items.AddObject(Magic.FEnchantments.GetEnchantments(I).GetName,
            TObject(Magic.FEnchantments.GetEnchantments(I).FEnchantmentID));
          OwnerList.Items.Add(AoWHSMap.FPlayers.GetPlayers(Magic.FEnchantments.GetEnchantments(I).FPlayerIndex).FLeader.FHeroName);
        end;
  SortEnchantments;
  UpdateChance;
end;

procedure TDisjunctionDlg.SortEnchantments;
begin
  case FSortOrder of
    0: SortStringsAscending(EnchantmentList.Items, [OwnerList.Items]);
    1: SortStringsDescending(EnchantmentList.Items, [OwnerList.Items]);
    2: SortStringsAscending(OwnerList.Items, [EnchantmentList.Items]);
    3: SortStringsDescending(OwnerList.Items, [EnchantmentList.Items]);
  end;
end;

procedure TDisjunctionDlg.UpdateChance;
begin
  if FCaster.GetEnoughMana then DisjunctionMana.TextColor := $C0C0C0
  else DisjunctionMana.TextColor := $FF;
  DisjunctionMana.Text := IntToStr(AoWHSSet.FSpellControl.GetSpell($33).FBaseManaCost) + '+' +
    IntToStr(FCaster.GetMana) + '=' + IntToStr(AoWHSSet.FSpellControl.GetSpell($33).FBaseManaCost + FCaster.GetMana);
  DisjunctionChance.Text := IntToStr(FCaster.FDispelChance) + '%';
  ChanceSlider.Max := FCaster.GetDispelChanceMax;
  ChanceSlider.Position := FCaster.FDispelChance;
end;

procedure TDisjunctionDlg.SelectEnchantment(Index: Integer);
var
  Enchantment: TGlobalEnchantment;
  Location: TXYL;
begin
  if (Index >= 0) and (Index < EnchantmentList.Items.Count) then
  begin
    EnchantmentList.Selected := Index;
    OwnerList.Selected := Index;
    FCaster.SetEnchantmentID(Integer(EnchantmentList.Items.Objects[Index]));
    Enchantment := FCaster.SelectedEnchantment;
    if Enchantment <> nil then
    begin
      Location := Enchantment.GetLocation;
      FMapX := Location.X;
      FMapY := Location.Y;
      FMapL := Location.L;
    end
    else FMapX := -1;
    if FMapX = -1 then FCaster.GetSource.GetLocation(FMapX, FMapY, FMapL);
    UpdateChance;
  end
  else
  begin
    EnchantmentList.Selected := -1;
    OwnerList.Selected := -1;
  end;
end;

procedure TDisjunctionDlg.Execute(Caster: TDisjunctionSpellCaster);
begin
  if FCaster <> nil then FCaster.Release;
  FCaster := Caster;
  FCaster.AddRef;
  UpdateEnchantments;
  SelectEnchantment(0);
  General.Manager.OverlayPriority := $31;
  Dlg.Visible := True;
end;

end.
