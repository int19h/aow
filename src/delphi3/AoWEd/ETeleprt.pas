unit ETeleprt;

{ ETeleprt editor routines recovered from AoWEd.exe. Remaining stubs are marked draft. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, SpinEdit, Teleport;

type
  TTeleportEditForm = class;
  TTeleportEditor = class;


  { TTeleportEditForm (instance size 568, VMT 0041944C) }
  TTeleportEditForm = class(TAoWMapObjEditForm)
  public
    published
    GroupBox1: TGroupBox; { +0210 }
    Label1: TLabel; { +0214 }
    Label2: TLabel; { +0218 }
    Label3: TLabel; { +021C }
    XtoEdit: TSpin; { +0220 }
    YtoEdit: TSpin; { +0224 }
    LtoEdit: TSpin; { +0228 }
    Panel3: TPanel; { +022C }
    BorderPanel: TDrawPanel; { +0230 }
    RazedCB: TCheckBox; { +0234 }
    public
    procedure FormCreate;
    procedure BorderPanelDraw(Sender: TObject; const R: TRect);
    procedure OKBtnClick(Sender: TObject);
  end;

  { TTeleportEditor (instance size 8, VMT 00419648) }
  TTeleportEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TTeleportEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TTeleportEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TTeleportEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin end;

procedure TTeleportEditForm.FormCreate;
begin
  with AoWHSMap.MapContainer do
  begin
    XtoEdit.MaxValue := Width - 1;
    YtoEdit.MaxValue := Height - 1;
    LtoEdit.MaxValue := LevelCount - 1;
    LtoEdit.Enabled := LevelCount > 1;
  end;
  XtoEdit.Value := TTeleport(FMapObject).FDestinationX;
  YtoEdit.Value := TTeleport(FMapObject).FDestinationY;
  LtoEdit.Value := TTeleport(FMapObject).FDestinationL;
  RazedCB.Checked := TTeleport(FMapObject).GetRazed;
end;


procedure TTeleportEditForm.BorderPanelDraw(Sender: TObject; const R: TRect);
var Structure: TStructure;
begin
  Structure := TStructure(FMapObject);
  if Structure <> nil then Structure.ShowBorderImageDC(BorderPanel.Canvas.Handle, R);
end;


procedure TTeleportEditForm.OKBtnClick(Sender: TObject);
begin
  TTeleport(FMapObject).FDestinationX := XtoEdit.Value;
  TTeleport(FMapObject).FDestinationY := YtoEdit.Value;
  TTeleport(FMapObject).FDestinationL := LtoEdit.Value;
  TTeleport(FMapObject).SetRazed(RazedCB.Checked);
  inherited OKBtnClick(Sender);
end;



end.
