unit AoWItemBanner;

{ Draft declarations of AoWItemBanner, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AOWMenu, AoWImage, AoWLabel, AoWListBox, AoWVScroll, aowUserDrawBox;

type
  TItemBanner = class;


  { TItemBanner (instance size 120, VMT 00406950) }
  TItemBanner = class(TDataModule)
  public
    published
    ItemNameLbl: TAOWLabel; { +0044 }
    IBannerPopup: TAOWMenu; { +0048 }
    AttackIcon: TAOWImage; { +004C }
    DefenseIcon: TAOWImage; { +0050 }
    DamageIcon: TAOWImage; { +0054 }
    ResistanceIcon: TAOWImage; { +0058 }
    Attack: TAOWLabel; { +005C }
    Defense: TAOWLabel; { +0060 }
    Damage: TAOWLabel; { +0064 }
    Resistance: TAOWLabel; { +0068 }
    DrawBox: TaowUserDrawBox; { +006C }
    AbLB: TAOWListBox; { +0070 }
    AbVSB: TAOWVScrollBar; { +0074 }
    public
    published procedure IBannerPopupShow(Sender: TObject); public
    published procedure IBannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer); public
    published procedure DrawBoxPreDraw(Sender: TObject; SurfDesc: TSurfaceDesc); public
  end;


var
  ItemBanner: TItemBanner;
  ItemID: Integer;

implementation

procedure TItemBanner.IBannerPopupShow(Sender: TObject);
var
  Item: TItem;
  X, Y: Integer;
begin
  Item := AoWHSMap.FItemControl.FindItem(ItemID);
  if Item <> nil then
  begin
    ItemNameLbl.Text := Item.FOwnerName;
    AttackIcon.Visible := False;
    DamageIcon.Visible := False;
    DefenseIcon.Visible := False;
    ResistanceIcon.Visible := False;
    Attack.Visible := False;
    Damage.Visible := False;
    Defense.Visible := False;
    Resistance.Visible := False;
    X := 30;
    Y := 100;
    if Item.FAttack <> 0 then
    begin
      Attack.Text := IntToStr(Item.FAttack);
      Attack.Visible := True;
      AttackIcon.Visible := True;
      AttackIcon.WinLeft := X + 10;
      Attack.WinLeft := X + 30;
      AttackIcon.WinTop := Y;
      Attack.WinTop := Y + 5;
      Inc(X, 50);
      if X = 130 then
      begin
        X := 30;
        Inc(Y, 20);
      end;
    end;
    if Item.FDamage <> 0 then
    begin
      Damage.Text := IntToStr(Item.FDamage);
      Damage.Visible := True;
      DamageIcon.Visible := True;
      DamageIcon.WinLeft := X + 10;
      Damage.WinLeft := X + 30;
      DamageIcon.WinTop := Y;
      Damage.WinTop := Y + 5;
      Inc(X, 50);
      if X = 130 then
      begin
        X := 30;
        Inc(Y, 20);
      end;
    end;
    if Item.FDefense <> 0 then
    begin
      Defense.Text := IntToStr(Item.FDefense);
      Defense.Visible := True;
      DefenseIcon.Visible := True;
      DefenseIcon.WinLeft := X + 10;
      Defense.WinLeft := X + 30;
      DefenseIcon.WinTop := Y;
      Defense.WinTop := Y + 5;
      Inc(X, 50);
      if X = 130 then
      begin
        X := 30;
        Inc(Y, 20);
      end;
    end;
    if Item.FResistance <> 0 then
    begin
      Resistance.Text := IntToStr(Item.FResistance);
      Resistance.Visible := True;
      ResistanceIcon.Visible := True;
      ResistanceIcon.WinLeft := X + 10;
      Resistance.WinLeft := X + 30;
      ResistanceIcon.WinTop := Y;
      Resistance.WinTop := Y + 5;
      Inc(X, 50);
      if X = 130 then
      begin
        X := 30;
        Inc(Y, 20);
      end;
    end;
    if X <> 30 then Inc(Y, 20);
    AbLB.Items.Clear;
    AbLB.Alignment.TopOffset := Y + 10;
    for X := 1 to 169 do
      if Item.GetAbEnabled(X) then
        AbLB.Items.AddObject(AoWHSSet.FAbilityControl.GetAbility(X).GetName(Item), TObject(X));
    IBannerPopup.WinHeight := AbLB.Items.Count * AbLB.ItemHeight + (Y + 50);
    if IBannerPopup.WinHeight > 200 then IBannerPopup.WinHeight := 200;
  end;
end;

procedure TItemBanner.IBannerPopupMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin
  if A2 = 1 then ItemBanner.IBannerPopup.Visible := False;
end;

procedure TItemBanner.DrawBoxPreDraw(Sender: TObject; SurfDesc: TSurfaceDesc);
var
  Item: TItem;
begin
  Item := AoWHSMap.FItemControl.FindItem(ItemID);
  if Item <> nil then Item.Show(DrawBox.WinLeft, DrawBox.WinTop, SurfDesc);
end;


end.
