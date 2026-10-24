unit SFXEdDlg;

{ The SFXEdDlg unit of SoundP.dpl: the sound effect library editor (TSFXLibraryEditDlg), written
  for the original compiler (Delphi 3.02) and compared function by function with the shipped
  module (tools/match.py). The form's components are plain published fields (offsets from
  data/rtti/SoundP.dpl.txt); there is no DFM.

  Edit works on a copy of the library and assigns it back on OK (the copy is not freed). The
  sequence grid shows one sequence per row from row 1; PlaySeqClick plays the sequence with the
  row's number instead of the row's sequence (Row, not Row - 1); kept as in the original.
  Ctrl+C/Ctrl+X/Ctrl+V/Ctrl+Del in the grid copy, cut, paste and delete the selected sequences
  through the clipboard (format 'SFXLIBRARY'). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Grids, Buttons, SpinEdit, Engine, Sound;

type
  { SFXEdDlg.TSFXLibraryEditDlg (instance size 568): the components at +$1DC..+$22C, +$230
    FLibrary (the copy being edited), +$234 FSequence (the selected sequence). }
  TSFXLibraryEditDlg = class(TForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    SequenceList: TStringGrid;
    Panel2: TPanel;
    SFXList: TListBox;
    AddSeq: TButton;
    DeleteSeq: TButton;
    IDLabel: TLabel;
    SFXIDEdit: TSpin;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    SFXManagerList: TSFXManagerListBox;
    PlaySFXFile: TSpeedButton;
    AddSFX: TButton;
    DeleteSFX: TButton;
    OKBtn: TButton;
    Button1: TButton;
    PlaySFX: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure PlaySFXClick(Sender: TObject);
    procedure PlaySFXFileClick(Sender: TObject);
    procedure PlaySeqClick(Sender: TObject);
    procedure AddSeqClick(Sender: TObject);
    procedure DeleteSeqClick(Sender: TObject);
    procedure AddSFXClick(Sender: TObject);
    procedure DeleteSFXClick(Sender: TObject);
    procedure SequenceListSelectCell(Sender: TObject; Col, Row: Longint;
      var CanSelect: Boolean);
    procedure SFXIDEditUpdate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure SequenceListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FLibrary: TSFXLibrary;
    FSequence: TSFXSequence;
    procedure SelectSequence(Index: Integer);
    procedure UpdateSequenceList;
  public
    procedure Edit(AEngine: TEngine; ALibrary: TSFXLibrary; AManager: TSFXManager);
  end;

var
  SFXLibraryEditDlg: TSFXLibraryEditDlg;

implementation

procedure TSFXLibraryEditDlg.SelectSequence(Index: Integer);
var
  I: Integer;
begin
  if (Index >= 0) and (Index < FLibrary.Count) then
  begin
    SFXList.Items.Clear;
    FSequence := FLibrary.GetSFXSequence(Index);
    with FSequence do
    begin
      for I := 0 to Count - 1 do
        SFXList.Items.Add(GetSFX(I).FileName);
      SFXIDEdit.Value := ID;
    end;
    SFXIDEdit.Enabled := True;
    AddSFX.Enabled := True;
    DeleteSFX.Enabled := True;
  end
  else
  begin
    FSequence := nil;
    SFXIDEdit.Enabled := False;
    SFXIDEdit.Value := -1;
    SFXList.Items.Clear;
    AddSFX.Enabled := False;
    DeleteSFX.Enabled := False;
  end;
end;

procedure TSFXLibraryEditDlg.UpdateSequenceList;
var
  I: Integer;
begin
  if SequenceList.RowCount <= FLibrary.Count then
    SequenceList.RowCount := FLibrary.Count + 1;
  for I := 0 to SequenceList.RowCount - 2 do
    if I < FLibrary.Count then
      SequenceList.Cells[0, I + 1] := IntToStr(FLibrary.GetSFXSequence(I).ID)
    else
      SequenceList.Cells[0, I + 1] := '';
  SelectSequence(SequenceList.Row - 1);
end;

procedure TSFXLibraryEditDlg.Edit(AEngine: TEngine; ALibrary: TSFXLibrary;
  AManager: TSFXManager);
begin
  FLibrary := TSFXLibrary(ALibrary.Copy(AEngine));
  SFXManagerList.SFXManager := AManager;
  SFXManagerList.GenerateItems;
  SequenceList.Row := 1;
  UpdateSequenceList;
  if ShowModal = mrOk then
    ALibrary.Assign(FLibrary, AEngine);
end;

procedure TSFXLibraryEditDlg.FormCreate(Sender: TObject);
begin
  SequenceList.Cells[0, 0] := 'ID';
end;

procedure TSFXLibraryEditDlg.PlaySFXClick(Sender: TObject);
begin
  if (SFXList.ItemIndex >= 0) and (SFXList.Items.Count > SFXList.ItemIndex) then
    PlaySample(SFXList.Items[SFXList.ItemIndex]);
end;

procedure TSFXLibraryEditDlg.PlaySFXFileClick(Sender: TObject);
begin
  PlaySample(SFXManagerList.SFXName);
end;

procedure TSFXLibraryEditDlg.PlaySeqClick(Sender: TObject);
begin
  if (SequenceList.Row > 0) and (SequenceList.Row < FLibrary.Count) then
    FLibrary.GetSFXSequence(SequenceList.Row).Play;
end;

procedure TSFXLibraryEditDlg.AddSeqClick(Sender: TObject);
begin
  TSFXSequence.Create(FLibrary);
  SequenceList.Row := FLibrary.Count;
  UpdateSequenceList;
end;

procedure TSFXLibraryEditDlg.DeleteSeqClick(Sender: TObject);
begin
  if FSequence <> nil then
  begin
    FSequence.Free;
    UpdateSequenceList;
  end;
end;

procedure TSFXLibraryEditDlg.AddSFXClick(Sender: TObject);
var
  S: TSFX;
begin
  if (FSequence <> nil) and (SFXManagerList.SFXName <> '') then
  begin
    S := TSFX.Create(FSequence);
    S.FileName := SFXManagerList.SFXName;
    SelectSequence(SequenceList.Row - 1);
  end;
end;

procedure TSFXLibraryEditDlg.DeleteSFXClick(Sender: TObject);
begin
  if FSequence <> nil then
    with FSequence do
      if (SFXList.ItemIndex >= 0) and (Count > SFXList.ItemIndex) then
      begin
        GetSFX(SFXList.ItemIndex).Free;
        SelectSequence(SequenceList.Row - 1);
      end;
end;

procedure TSFXLibraryEditDlg.SequenceListSelectCell(Sender: TObject; Col, Row: Longint;
  var CanSelect: Boolean);
begin
  SelectSequence(Row - 1);
end;

procedure TSFXLibraryEditDlg.SFXIDEditUpdate(Sender: TObject);
begin
  if FSequence <> nil then
  begin
    FSequence.ID := SFXIDEdit.Value;
    UpdateSequenceList;
  end;
end;

procedure TSFXLibraryEditDlg.OKBtnClick(Sender: TObject);
var
  ID: Integer;
begin
  ID := FLibrary.DoubleID;
  if ID <> -1 then
    ShowMessage('Double ID defined (' + IntToStr(ID) + ')')
  else
    ModalResult := mrOk;
end;

procedure TSFXLibraryEditDlg.SequenceListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Lib: TSFXLibrary;
  Stream: TMemoryStream;
  I: Integer;
begin
  if ((Key = Ord('C')) or (Key = Ord('X'))) and (ssCtrl in Shift) then
  begin
    Stream := TMemoryStream.Create;
    Lib := TSFXLibrary.Create(nil);
    for I := SequenceList.Selection.Top to SequenceList.Selection.Bottom do
      if FLibrary.GetSFXSequence(I - 1) <> nil then
        FLibrary.GetSFXSequence(I - 1).Copy(GetEngine(0)).Owner := Lib;
    GetEngine(0).StoreEObject(Stream, Lib, nil);
    CopyStreamToClipboard(Stream, 'SFXLIBRARY');
    Lib.Free;
    Stream.Free;
  end;
  if ((Key = Ord('X')) or (Key = VK_DELETE)) and (ssCtrl in Shift) then
  begin
    for I := SequenceList.Selection.Bottom downto SequenceList.Selection.Top do
      if FLibrary.GetSFXSequence(I - 1) <> nil then
        FLibrary.GetSFXSequence(I - 1).Free;
    UpdateSequenceList;
  end;
  if (Key = Ord('V')) and (ssCtrl in Shift) then
  begin
    Stream := TMemoryStream.Create;
    if PasteStreamFromClipboard(Stream, 'SFXLIBRARY') <> -1 then
    begin
      Lib := TSFXLibrary(GetEngine(0).RetrieveEObject(Stream, nil));
      if Lib <> nil then
      begin
        for I := Lib.Count - 1 downto 0 do
          Lib.GetSFXSequence(I).Owner := FLibrary;
        UpdateSequenceList;
        Lib.Free;
      end;
    end;
    Stream.Free;
  end;
end;

end.
