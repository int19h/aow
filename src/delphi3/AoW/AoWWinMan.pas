unit AoWWinMan;

{ Draft declarations of AoWWinMan, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWWindow, AoWTC, AOWToolTip, AOWWinManager;

type
  TGeneral = class;


  { TGeneral (instance size $CC, VMT 00453FC4).
    $84 selected unit indices; $A4 unit list; $C0 current unit; $C4 combat unit sprite. }
  TGeneral = class(TDataModule)
  public
    published
    Manager: TAOWWinManager; { +0044 }
    ToolTip: TAOWToolTip; { +0048 }
    public
    F_General_4C: array[0..27] of Byte;
    F_General_68: Byte;
    F_General_69: Byte;
    F_General_6A: array[0..13] of Byte;
    F_General_78: Integer;
    F_General_7C: array[0..7] of Byte;
    FSelectedUnits: array[0..7] of Integer; { $84 }
    FUnitList: TUnitList; { $A4 }
    F_General_A8: array[0..23] of Byte;
    FSelectedUnit: TAbstractUnit; { $C0; 00449DCD }
    { conflict: FUnit: TAbstractUnit; }
    FCombatUnit: TTacticalCombatUnitHS; { $C4 }
    F_General_C8: array[0..3] of Byte;
    procedure PlayButtonSound(Kind: Byte); { draft; 00455DFC }
    { conflict: procedure ButtonSound(Index: Byte); }
    procedure SortLists(var Lists: TList; Order: Byte); { draft; 00455744 }
    procedure RegisterDialog(Window: TAOWWindow); { draft; 00456AAC }
    procedure UnregisterDialog(Window: TAOWWindow); { draft; 00456B34 }
    function IndexOfUnit(U: TAbstractUnit): Integer;
    procedure MTtoInt(A1: Byte; A2: Integer);  { draft }
    procedure ManagerChangeCursor;  { draft }
    procedure GeneralCreate;  { draft }
    procedure GeneralDestroy;  { draft }
    procedure ResetLayout;  { draft }
    procedure ManagerDebugMessage(A1: Integer; A2: Integer);  { draft }
    procedure MapProgress(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ManagerKeyDown(A1: Integer; A2: Integer);  { draft }
    procedure ManagerUpdate;  { draft }
  end;


var
  General: TGeneral;

implementation

procedure TGeneral.PlayButtonSound(Kind: Byte);
begin
  case Kind of
    0: PlaySample('Sfx\Int\Btn1.wav');
    1: PlaySample('Sfx\Int\Btn5.wav');
    2: PlaySample('Sfx\Int\Btn6.wav');
    3: PlaySample('Sfx\Int\Btn3.wav');
  end;
end;

function TGeneral.IndexOfUnit(U: TAbstractUnit): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (FSelectedUnits[0] > -1) and (FUnitList <> nil) then
    for I := 0 to 7 do
      if (FSelectedUnits[I] > -1) and (I < FUnitList.Count) then
        if U = FUnitList.GetUnit(FSelectedUnits[I]) then Result := I;
end;

procedure TGeneral.SortLists(var Lists: TList; Order: Byte);
begin end;

procedure TGeneral.RegisterDialog(Window: TAOWWindow);
begin end;

procedure TGeneral.UnregisterDialog(Window: TAOWWindow);
begin end;

procedure TGeneral.MTtoInt(A1: Byte; A2: Integer);
begin end;

procedure TGeneral.ManagerChangeCursor;
begin end;

procedure TGeneral.GeneralCreate;
begin end;

procedure TGeneral.GeneralDestroy;
begin end;

procedure TGeneral.ResetLayout;
begin end;

procedure TGeneral.ManagerDebugMessage(A1: Integer; A2: Integer);
begin end;

procedure TGeneral.MapProgress(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TGeneral.ManagerKeyDown(A1: Integer; A2: Integer);
begin end;

procedure TGeneral.ManagerUpdate;
begin end;


end.
