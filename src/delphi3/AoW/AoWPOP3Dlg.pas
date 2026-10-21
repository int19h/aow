unit AoWPOP3Dlg;

{ Draft declarations of AoWPOP3Dlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TPOP3Dlg = class;


  { TPOP3Dlg (instance size 168, VMT 00429ECC) }
  TPOP3Dlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    TCeltL: TAoWFrame; { +0050 }
    TCeltLineL: TAOWImage; { +0054 }
    AOWImage1: TAOWImage; { +0058 }
    AOWImage2: TAOWImage; { +005C }
    SearchingEmailGameLbl: TAOWLabel; { +0060 }
    EmailGameFoundLbl: TAOWLabel; { +0064 }
    FoundEmailGames: TAOWListBox; { +0068 }
    ExitPnl: TAOWPanel; { +006C }
    Exit2Btn: TAOWButton; { +0070 }
    StartExitPnl: TAOWPanel; { +0074 }
    StartBtn: TAOWButton; { +0078 }
    ExitBtn: TAOWButton; { +007C }
    LocalEmailAddressEdit: TAOWEdit; { +0080 }
    AttachmentDirectoryLbl: TAOWLabel; { +0084 }
    TitleIcon: TAOWImage; { +0088 }
    EditPnl: TAOWPanel; { +008C }
    ModePnl: TAOWPanel; { +0090 }
    EmailGamesSB: TAOWVScrollBar; { +0094 }
    Close: TAOWButton; { +0098 }
    Translator: TIvTranslator; { +009C }
    public
    FSearching: Boolean; FReservedA1: array[0..2] of Byte; { $A0 }
    FCheckDelay: Integer; { $A4 }
    procedure ResetSearch;
    procedure UpdateSelection;
    function CheckAttachments: Integer;
    procedure ShowDialog;
    procedure CancelBtnClick;  { draft }
    procedure DlgUpdate;  { draft }
    procedure ExitBtnClick;  { draft }
    procedure FoundEmailGamesChange;  { draft }
    procedure StartBtnClick;  { draft }
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

uses AoWE, AoWWinMan, E1GameFlow;


procedure TPOP3Dlg.ResetSearch;
begin
  FCheckDelay := 30;
  FSearching := False;
  FoundEmailGames.Items.Clear;
  ExitPnl.Visible := True;
  StartExitPnl.Visible := False;
end;

procedure TPOP3Dlg.UpdateSelection;
begin
  if (FoundEmailGames.Items.Count <> 0) and (FoundEmailGames.Selected <> -1) then
  begin
    StartExitPnl.Visible := True;
    ExitPnl.Visible := False;
  end
  else
  begin
    StartExitPnl.Visible := False;
    ExitPnl.Visible := True;
  end;
end;

function TPOP3Dlg.CheckAttachments: Integer;
var
  Name, Destination: string;
  Search: TSearchRec;
  Handle: THandle;
  Found: Boolean;
begin
  Result := 0;
  if AoWEngine.FRegistry.GetAttachmentDirectory <> '' then
  begin
    Found := FindFirst(AoWEngine.FRegistry.GetAttachmentDirectory + '\*.asg', faDirectory, Search) = 0;
    while Found do
    begin
      Name := AoWEngine.FRegistry.GetAttachmentDirectory + '\' + Search.Name;
      Handle := CreateFile(PChar(Name), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      if Handle <> INVALID_HANDLE_VALUE then
      begin
        CloseHandle(Handle);
        AoWEngine.FEmailGames.ValidateIncommingGame(Name, Destination);
        if Destination <> '' then
          if CopyFile(PChar(Name), PChar(Destination), False) then
          begin
            if FoundEmailGames.Items.IndexOf(ExtractFileName(Destination)) = -1 then
              FoundEmailGames.Items.Add(ExtractFileName(Destination));
            SysUtils.DeleteFile(Name);
            Inc(Result);
          end;
      end;
      Found := FindNext(Search) = 0;
    end;
    FindClose(Search);
  end;
end;

procedure TPOP3Dlg.ShowDialog;
begin
  ResetSearch;
  LocalEmailAddressEdit.Text := AoWEngine.FRegistry.GetLocalEmailAddress;
  AttachmentDirectoryLbl.Text := '(' + AoWE.Format(TranslateRStr(AttachmentDirectoryXRStr),
    [AoWEngine.FRegistry.GetAttachmentDirectory]) + ')';
  Dlg.Visible := True;
end;

procedure TPOP3Dlg.CancelBtnClick;
begin
  Dlg.Visible := False;
end;

procedure TPOP3Dlg.DlgUpdate;
begin
  Dec(FCheckDelay);
  if FCheckDelay < 0 then
  begin
    FCheckDelay := AoWEngine.FRegistry.GetCheckEmailFrequency * 30 * 60;
    if FCheckDelay < 30 then FCheckDelay := 30;
    FCheckDelay := 150; { Original overrides the configured interval. }
  end;
  case FCheckDelay of 25: CheckAttachments; end;
end;

procedure TPOP3Dlg.ExitBtnClick;
begin
  Dlg.Visible := False;
end;

procedure TPOP3Dlg.FoundEmailGamesChange;
begin
  UpdateSelection;
end;

procedure TPOP3Dlg.StartBtnClick;
begin
  if FoundEmailGames.Selected <> -1 then
  begin
    LoadGame(General, AoWEngine.StartupDirectory + 'EmailIn\' + FoundEmailGames.Items[FoundEmailGames.Selected]);
    StartGame(General);
  end;
end;

procedure TPOP3Dlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then Dlg.Visible := False;
end;

end.
