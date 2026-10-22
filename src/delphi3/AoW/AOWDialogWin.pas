unit AOWDialogWin;

{ Draft declarations of AOWDialogWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TDWin = class;


  { TDWin (instance size 176, VMT 00450334) }
  TDWin = class(TDataModule)
  public
    published
    Dialog: TAOWWindow; { +0044 }
    DTitle: TAOWLabel; { +0048 }
    DMessage: TAOWLabel; { +004C }
    DButton: TAOWButton; { +0050 }
    DebugWin: TAOWWindow; { +0054 }
    DebugDTitle: TAOWLabel; { +0058 }
    DebugDOkBtn: TAOWButton; { +005C }
    FrameLbl: TAOWLabel; { +0060 }
    DebugDfrTitle: TAOWLabel; { +0064 }
    DebugMemo: TAOWMemo; { +0068 }
    DMemoScroll: TAOWVScrollBar; { +006C }
    okPnl: TAOWPanel; { +0070 }
    yesPnl: TAOWPanel; { +0074 }
    yesBtn: TAOWButton; { +0078 }
    noBtn: TAOWButton; { +007C }
    BCeltL: TAoWFrame; { +0080 }
    TCeltL: TAoWFrame; { +0084 }
    TCeltLineL: TAOWImage; { +0088 }
    AOWImage1: TAOWImage; { +008C }
    AOWImage2: TAOWImage; { +0090 }
    AoWFrame1: TAoWFrame; { +0094 }
    SignBLine: TAoWFrame; { +0098 }
    SIcon: TAOWImage; { +009C }
    Translator: TIvTranslator; { +00A0 }
    public
    FAction: Byte; { $A4; 004506E7 }
    F_DWin_A5: array[0..7] of Byte; FSkipCombatChoice: Boolean; { $AD; 00439AEC } F_DWin_AE: array[0..1] of Byte;
    procedure Confirm(Title, Text: string; Action: Byte);
    procedure AddDebugMessage(const Text: string);
    published procedure DButtonClick(Sender: TObject); public
    published procedure DebugDOkBtnClick; public  { draft }
    published procedure yesBtnClick(Sender: TObject); public
    published procedure DialogKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


implementation

uses AoWWinMan, E3Globals, AoWE, AoWTC, E1Globals;

procedure TDWin.DButtonClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  Dialog.Visible := False;
end;


procedure TDWin.DebugDOkBtnClick;
begin
  General.PlayButtonSound(0);
  DebugWin.Visible := False;
end;

procedure TDWin.yesBtnClick(Sender: TObject);
var Reason: string; Structure: TStructure;
begin
  General.PlayButtonSound(0);
  case FAction of
    0, 1: ;
    2: General.FCity.Loot;
    3:
      if General.FCity.CanRaze(AoWHSMap.FSeatedPlayer, Reason) then
      begin
        if General.FCity.Raze(AoWHSMap.FSeatedPlayer) then
        begin
          Structure := General.FStructure;
          MapEvents.TheMapStructureDeselected(General.FStructure);
          MapEvents.TheMapStructureSelected(Structure);
        end;
      end
      else AoWHSMap.ShowWarning(Reason);
    4: AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).Surrender;
    5: begin WorldMap.WorldPnl.Visible := False; General.ReturnToTitle; end;
    6: if AoWCombatMap <> nil then AoWCombatMap.Surrender(AoWCombatMap.FSeatedCombatPlayer);
    7: if General.FSelectedUnit <> nil then
      if General.FSelectedUnit.CanDisband(Reason) then
      begin
        if General.FSelectedUnit.Disband then UnitWindow.UnitWin.Visible := False;
      end
      else AoWHSMap.ShowWarning(Reason);
  end;
  Dialog.Visible := False;
end;

procedure TDWin.DialogKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: DButtonClick(Self);
    VK_RETURN: if yesPnl.Visible then yesBtnClick(Self) else DButtonClick(Self);
  end;
end;


procedure TDWin.AddDebugMessage(const Text: string);
begin
  DebugMemo.Items.Add(Text);
  if DebugMemo.Items.Count > 99 then DebugMemo.Items.Delete(0);
  DebugMemo.FSized := False;
  DMemoScroll.Position := DMemoScroll.Max;
end;

procedure TDWin.Confirm(Title, Text: string; Action: Byte);
begin
  FAction := Action;
  DTitle.Text := Title; DMessage.Text := Text;
  yesPnl.Visible := True; okPnl.Visible := False; Dialog.Visible := True;
end;

end.
