unit TextCtrlEd;

{ Draft declarations of TextCtrlEd, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  $20C text control, $210 selected text control item. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, SpinEdit, AoWE;

type
  TTextControlEditForm = class;


  { TTextControlEditForm (instance size 532, VMT 00421798) }
  TTextControlEditForm = class(TForm)
  public
    published
    Panel10: TPanel; { +01DC }
    Label7: TLabel; { +01E0 }
    TextIDEdit: TSpin; { +01E4 }
    TextMemo: TMemo; { +01E8 }
    NewText: TButton; { +01EC }
    DeleteText: TButton; { +01F0 }
    FindText: TButton; { +01F4 }
    TextScrollBar: TScrollBar; { +01F8 }
    CloseBtn: TButton; { +01FC }
    Label1: TLabel; { +0200 }
    Label2: TLabel; { +0204 }
    DescriptionEdit: TEdit; { +0208 }
    public
    FTextControl: TTextControl; { $20C }
    FText: TTextControlItem; { $210 }
    procedure UpdateScrollBar;
    procedure SetText(Item: TTextControlItem);
    procedure EditTextControl(TextControl: TTextControl);
    procedure TextIDEditChange;
    procedure NewTextClick;
    procedure DeleteTextClick;
    procedure FindTextClick;
    procedure TextMemoChange;
    procedure TextScrollBarChange;
    procedure DescriptionEditChange;
  end;


implementation

procedure TTextControlEditForm.UpdateScrollBar;
begin
  FTextControl.Sort;
  if FTextControl.Count <> 0 then TextScrollBar.Max := FTextControl.Count - 1
  else TextScrollBar.Max := 0;
  if FText <> nil then
  begin
    if FTextControl.IndexOf(FText) <> TextScrollBar.Position then
      TextScrollBar.Position := FTextControl.IndexOf(FText);
  end
  else TextScrollBar.Position := 0;
end;

procedure TTextControlEditForm.SetText(Item: TTextControlItem);
begin
  FText := Item;
  with FText do
    if Item <> nil then
    begin
      TextMemo.Lines.Text := FText.Text;
      DescriptionEdit.Text := Self.FText.FName;
      TextIDEdit.Value := Item.FID;
      TextMemo.Enabled := True;
      TextIDEdit.Enabled := True;
      DeleteText.Enabled := True;
    end
    else
    begin
      TextMemo.Enabled := False;
      TextIDEdit.Enabled := False;
      DeleteText.Enabled := False;
    end;
  UpdateScrollBar;
end;

procedure TTextControlEditForm.EditTextControl(TextControl: TTextControl);
begin
  FTextControl := TextControl;
  SetText(TextControl.GetItem(0));
  ShowModal;
end;

procedure TTextControlEditForm.TextIDEditChange;
begin
  if FText <> nil then
  begin
    FText.FID := TextIDEdit.Value;
    UpdateScrollBar;
  end;
end;

procedure TTextControlEditForm.NewTextClick;
begin
  SetText(FTextControl.New);
end;

procedure TTextControlEditForm.DeleteTextClick;
var Index: Integer;
begin
  Index := FTextControl.IndexOf(FText);
  if Index <> -1 then
  begin
    FTextControl.Delete(Index);
    if Index = FTextControl.Count then Index := FTextControl.Count - 1;
    SetText(FTextControl.GetItem(Index));
  end;
end;

procedure TTextControlEditForm.FindTextClick;
var S: string; Item: TTextControlItem; ID: Integer;
begin
  S := InputBox('ID search form', 'Type ID', '');
  try
    if S <> '' then
    begin
      ID := StrToInt(S);
      Item := FTextControl.FindID(ID);
      if Item <> nil then SetText(Item)
      else ShowMessage('ID not found');
    end;
  except
  end;
end;

procedure TTextControlEditForm.TextMemoChange;
var Item: TTextControlItem;
begin
  Item := FText;
  if Item <> nil then Item.FText.Text := TextMemo.Lines.Text;
end;

procedure TTextControlEditForm.TextScrollBarChange;
begin
  if FTextControl.GetItem(TextScrollBar.Position) <> FText then
    SetText(FTextControl.GetItem(TextScrollBar.Position));
end;

procedure TTextControlEditForm.DescriptionEditChange;
begin
  if FText <> nil then FText.FName := DescriptionEdit.Text;
end;

end.
