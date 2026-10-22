unit EManaC;

{ Mana-crystal map-object editor from AoWEd.exe.
  The original checks arithmetic overflow but truncates the generation-mode byte. }

{$R-,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, ManaCrystals, SpinEdit;

type
  TManaCrystalsEditForm = class;
  TManaCrystalsEditor = class;


  { TManaCrystalsEditForm (size $230, VMT 0041BEF8): inherited $20C FMapObject;
    controls at $210..$22C; TManaCrystals.$1C amount and $20 generation mode. }
  TManaCrystalsEditForm = class(TAoWMapObjEditForm)
  public
    published
    AutoGenerate: TRadioButton; { +0210 }
    AutoGeneratePanel: TPanel; { +0214 }
    Label2: TLabel; { +0218 }
    GenerateModeBox: TComboBox; { +021C }
    UserDefinedPanel: TPanel; { +0220 }
    Label1: TLabel; { +0224 }
    ManaSpin: TSpin; { +0228 }
    UserDefined: TRadioButton; { +022C }
    public
    published procedure FormCreate(Sender: TObject); public
    published procedure ManaSpinChange(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
    published procedure AutoGenerateClick(Sender: TObject); public
    published procedure UserDefinedClick(Sender: TObject); public
    published procedure GenerateModeBoxChange(Sender: TObject); public
  end;

  { TManaCrystalsEditor (instance size 8, VMT 0041C148) }
  TManaCrystalsEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TManaCrystalsEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TManaCrystalsEditForm.vmt90(Obj, Done);
end;

class procedure TManaCrystalsEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TManaCrystalsEditForm.FormCreate(Sender: TObject);
begin
  ManaSpin.Value := TManaCrystals(FMapObject).FAmount;
  if TManaCrystals(FMapObject).FSize = 0 then
  begin
    UserDefined.Checked := True;
    UserDefinedClick(Self);
    GenerateModeBox.ItemIndex := 1;
  end
  else
  begin
    AutoGenerate.Checked := True;
    AutoGenerateClick(Self);
    GenerateModeBox.ItemIndex := TManaCrystals(FMapObject).FSize - 1;
  end;
end;

procedure TManaCrystalsEditForm.ManaSpinChange(Sender: TObject);
begin
  TManaCrystals(FMapObject).FAmount := ManaSpin.Value;
end;

procedure TManaCrystalsEditForm.OKBtnClick(Sender: TObject);
begin
  inherited OKBtnClick(Sender);
  if AutoGenerate.Checked then TManaCrystals(FMapObject).FAmount := 0
  else TManaCrystals(FMapObject).FSize := 0;
end;

procedure TManaCrystalsEditForm.AutoGenerateClick(Sender: TObject);
begin
  AutoGeneratePanel.Enabled := True;
  UserDefinedPanel.Enabled := False;
  GenerateModeBox.Color := clWindow;
  ManaSpin.Color := clBtnFace;
end;

procedure TManaCrystalsEditForm.UserDefinedClick(Sender: TObject);
begin
  AutoGeneratePanel.Enabled := False;
  UserDefinedPanel.Enabled := True;
  GenerateModeBox.Color := clBtnFace;
  ManaSpin.Color := clWindow;
end;

procedure TManaCrystalsEditForm.GenerateModeBoxChange(Sender: TObject);
begin
  TManaCrystals(FMapObject).FSize := Byte(GenerateModeBox.ItemIndex + 1);
end;


class function TManaCrystalsEditor.EditorClassID: Integer;
begin Result := $203BE; end;

end.
