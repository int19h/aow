unit PageTurnCtrl;

{ Draft declarations of PageTurnCtrl, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TPageTurnControl = class;


  { TPageTurnControl (instance size 2228, VMT 55809D40) }
  TPageTurnControl = class(TObject)
  public
    F_PageTurnControl_04: array[0..19] of Byte;
    F_PageTurnControl_18: Integer;
    F_PageTurnControl_1C: array[0..2199] of Byte;
    constructor Create;  { draft }
    procedure SetPageDimensions(A1: Integer; A2: Integer);  { draft }
    procedure GetInvCos(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GenerateInvCosTable;  { draft }
    procedure BltVerticalScanLine(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure Start(A1: Integer);  { draft }
    procedure UpdateScene;  { draft }
    procedure RenderLeftRightScene(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure RenderOpenCloseScene(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure RenderScene(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer);  { draft }
  end;


implementation

constructor TPageTurnControl.Create;
begin end;

procedure TPageTurnControl.SetPageDimensions(A1: Integer; A2: Integer);
begin end;

procedure TPageTurnControl.GetInvCos(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPageTurnControl.GenerateInvCosTable;
begin end;

procedure TPageTurnControl.BltVerticalScanLine(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TPageTurnControl.Start(A1: Integer);
begin end;

procedure TPageTurnControl.UpdateScene;
begin end;

procedure TPageTurnControl.RenderLeftRightScene(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPageTurnControl.RenderOpenCloseScene(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPageTurnControl.RenderScene(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer);
begin end;


initialization
finalization

end.
