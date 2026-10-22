unit EGems;

{ Draft declarations of EGems, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TGemsEditForm $230 bytes, inherited $20C FMapObject. }

{$R-,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Gems, AoWE, EAoWMO, SpinEdit;

type
  TGemsEditForm = class;
  TGemsEditor = class;


  { TGemsEditForm (instance size 560, VMT 0041A658) }
  TGemsEditForm = class(TAoWMapObjEditForm)
  public
    published
    UserDefined: TRadioButton; { +0210 }
    AutoGenerate: TRadioButton; { +0214 }
    AutoGeneratePanel: TPanel; { +0218 }
    Label2: TLabel; { +021C }
    GenerateModeBox: TComboBox; { +0220 }
    UserDefinedPanel: TPanel; { +0224 }
    Label1: TLabel; { +0228 }
    GemsSpin: TSpin; { +022C }
    public
    published procedure GemsSpinChange(Sender: TObject); public
    published procedure FormCreate(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
    published procedure AutoGenerateClick(Sender: TObject); public
    published procedure UserDefinedClick(Sender: TObject); public
    published procedure GenerateModeBoxChange(Sender: TObject); public
  end;

  { TGemsEditor (instance size 8, VMT 0041A898) }
  TGemsEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TGemsEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TGemsEditForm.vmt90(Obj, Done);
end;

class procedure TGemsEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TGemsEditForm.GemsSpinChange(Sender: TObject);
begin
  TGems(FMapObject).FAmount := GemsSpin.Value;
end;

procedure TGemsEditForm.FormCreate(Sender: TObject);
begin
  GemsSpin.Value := TGems(FMapObject).FAmount;
  if TGems(FMapObject).FGenerateMode = gmUserDefined then
  begin
    UserDefined.Checked := True;
    UserDefinedClick(Self);
    GenerateModeBox.ItemIndex := 1;
  end
  else
  begin
    AutoGenerate.Checked := True;
    AutoGenerateClick(Self);
    GenerateModeBox.ItemIndex := Ord(TGems(FMapObject).FGenerateMode) - 1;
  end;
end;

procedure TGemsEditForm.OKBtnClick(Sender: TObject);
begin
  inherited OKBtnClick(Sender);
  if AutoGenerate.Checked then TGems(FMapObject).FAmount := 0
  else TGems(FMapObject).FGenerateMode := gmUserDefined;
end;

procedure TGemsEditForm.AutoGenerateClick(Sender: TObject);
begin
  AutoGeneratePanel.Enabled := True;
  UserDefinedPanel.Enabled := False;
  GenerateModeBox.Color := clWindow;
  GemsSpin.Color := clBtnFace;
end;

procedure TGemsEditForm.UserDefinedClick(Sender: TObject);
begin
  AutoGeneratePanel.Enabled := False;
  UserDefinedPanel.Enabled := True;
  GenerateModeBox.Color := clBtnFace;
  GemsSpin.Color := clWindow;
end;

procedure TGemsEditForm.GenerateModeBoxChange(Sender: TObject);
begin
  TGems(FMapObject).FGenerateMode := TGemsGenerateMode(GenerateModeBox.ItemIndex + 1);
end;


class function TGemsEditor.EditorClassID: Integer;
begin Result := $203AE; end;

end.
