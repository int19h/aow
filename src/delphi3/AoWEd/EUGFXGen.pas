unit EUGFXGen;

{ Draft declarations of EUGFXGen, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWDlg, SpinEdit;

type
  TUnitGFXGeneraterDlg = class;


  { TUnitGFXGeneraterDlg (instance size 572, VMT 0040DA44) }
  TUnitGFXGeneraterDlg = class(TAoWDialog)
  public
    published
    Panel2: TPanel; { +01E0 }
    Panel3: TPanel; { +01E4 }
    GenerateBtn: TButton; { +01E8 }
    CancelBtn: TButton; { +01EC }
    Label1: TLabel; { +01F0 }
    StandStillEdit: TEdit; { +01F4 }
    Label2: TLabel; { +01F8 }
    MoveEdit: TEdit; { +01FC }
    Label3: TLabel; { +0200 }
    Label4: TLabel; { +0204 }
    AttackEdit: TEdit; { +0208 }
    HitEdit: TEdit; { +020C }
    Panel4: TPanel; { +0210 }
    Label5: TLabel; { +0214 }
    ILManagerComboBox: TILManagerComboBox; { +0218 }
    Panel1: TPanel; { +021C }
    Label6: TLabel; { +0220 }
    Label7: TLabel; { +0224 }
    XshiftEdit: TSpin; { +0228 }
    YshiftEdit: TSpin; { +022C }
    Label8: TLabel; { +0230 }
    SequenceSpeedBox: TComboBox; { +0234 }
    public
    F_UnitGFXGeneraterDlg_238: Integer;
    procedure GenerateBtnClick;  { draft }
  end;


implementation

procedure TUnitGFXGeneraterDlg.GenerateBtnClick;
begin end;


end.
