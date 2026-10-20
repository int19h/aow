unit UnitIDlg;

{ Draft declarations of UnitIDlg, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TUnitInfoDlg = class;


  { TUnitInfoDlg (instance size 564, VMT 557FF1B8) }
  TUnitInfoDlg = class(TForm)
  public
    F_UnitInfoDlg_1DC: Integer;
    F_UnitInfoDlg_1E0: Integer;
    F_UnitInfoDlg_1E4: Integer;
    F_UnitInfoDlg_1E8: Integer;
    F_UnitInfoDlg_1EC: Integer;
    F_UnitInfoDlg_1F0: Integer;
    F_UnitInfoDlg_1F4: Integer;
    F_UnitInfoDlg_1F8: Integer;
    F_UnitInfoDlg_1FC: Integer;
    F_UnitInfoDlg_200: Integer;
    F_UnitInfoDlg_204: Integer;
    F_UnitInfoDlg_208: Integer;
    F_UnitInfoDlg_20C: Integer;
    F_UnitInfoDlg_210: Integer;
    F_UnitInfoDlg_214: Integer;
    F_UnitInfoDlg_218: Integer;
    F_UnitInfoDlg_21C: Integer;
    F_UnitInfoDlg_220: Integer;
    F_UnitInfoDlg_224: Integer;
    F_UnitInfoDlg_228: Integer;
    F_UnitInfoDlg_22C: Integer;
    F_UnitInfoDlg_230: Integer;
    procedure ShowUnit(A1: Integer);  { draft }
    procedure ShowUnitResource(A1: Integer);  { draft }
  end;


implementation

procedure TUnitInfoDlg.ShowUnit(A1: Integer);
begin end;

procedure TUnitInfoDlg.ShowUnitResource(A1: Integer);
begin end;


initialization
finalization

end.
