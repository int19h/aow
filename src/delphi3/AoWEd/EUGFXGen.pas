unit EUGFXGen;

{ Unit graphics sequence generator recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWDlg, SpinEdit;

type
  TUnitGFXGeneraterDlg = class;


  { TUnitGFXGeneraterDlg (instance size $23C, VMT 0040DA44; $238 FResource) }
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
    FResource: TUnitGFXResource; { $238 }
    procedure SetResource(Resource: TEResource);
    published procedure GenerateBtnClick(Sender: TObject); public
  end;


implementation

const
  DirectionOrder: array[1..6] of Integer = (4, 3, 2, 1, 6, 5);

function FirstFrameIndex(S: string): Integer;
var I: Integer; Digits: string;
begin
  I := 1;
  Digits := '';
  while (I <= Length(S)) and (S[I] in ['0'..'9']) do
  begin
    Digits := Digits + S[I];
    Inc(I);
  end;
  if Digits <> '' then Result := StrToInt(Digits) else Result := 0;
end;

function LastFrameIndex(S: string): Integer;
var I: Integer; Digits: string;
begin
  I := Length(S);
  Digits := '';
  while (I <> 0) and (S[I] in ['0'..'9']) do
  begin
    Digits := S[I] + Digits;
    Dec(I);
  end;
  if Digits <> '' then Result := StrToInt(Digits) else Result := 0;
end;

procedure TUnitGFXGeneraterDlg.SetResource(Resource: TEResource);
var List: TImageSequenceList; S: string; Sequence: TImageSequence; I, Index: Integer;
begin
  FResource := TUnitGFXResource(Resource);
  ILManagerComboBox.ILManager := FResource.FSequences.ILManager;
  ILManagerComboBox.ItemIndex := 0;
  SequenceSpeedBox.ItemIndex := 1;
  List := FResource.FSequences;
  Sequence := List.GetImageSequence(0);
  if Sequence <> nil then
  begin
    ILManagerComboBox.ImageLibraryName := Sequence.ImageLibraryName;
    SequenceSpeedBox.ItemIndex := Sequence.SequenceSpeed;
    XshiftEdit.Value := Sequence.dXshift;
    YshiftEdit.Value := Sequence.dYshift;
  end;
  for I := 0 to 3 do
  begin
    Index := I * 6 + 1; Sequence := List.GetImageSequence(Index);
    if (Sequence <> nil) and (Sequence.SequenceMode = smFrameTable) then
    begin
      if Sequence.FrameTable.Count = 1 then S := IntToStr(Sequence.FrameTable[0] mod 100)
      else if Sequence.FrameTable.Count > 1 then S := IntToStr(Sequence.FrameTable[0] mod 100) + '-' + IntToStr(Sequence.FrameTable.Last mod 100)
      else S := '';
      if S <> '' then
        case I of
          0: StandStillEdit.Text := S;
          1: MoveEdit.Text := S;
          2: AttackEdit.Text := S;
          3: HitEdit.Text := S;
        end;
    end;
  end;
end;


procedure TUnitGFXGeneraterDlg.GenerateBtnClick(Sender: TObject);
var
  Frame, FirstFrame, LastFrame, Action, Direction, Index: Integer;
  List: TImageSequenceList;
  Sequence: TImageSequence;
begin
  List := FResource.FSequences;
  for Action := 0 to 3 do
  begin
    case Action of
      0: begin FirstFrame := FirstFrameIndex(StandStillEdit.Text); LastFrame := LastFrameIndex(StandStillEdit.Text); end;
      1: begin FirstFrame := FirstFrameIndex(MoveEdit.Text); LastFrame := LastFrameIndex(MoveEdit.Text); end;
      2: begin FirstFrame := FirstFrameIndex(AttackEdit.Text); LastFrame := LastFrameIndex(AttackEdit.Text); end;
      3: begin FirstFrame := FirstFrameIndex(HitEdit.Text); LastFrame := LastFrameIndex(HitEdit.Text); end;
    else
      FirstFrame := 0;
      LastFrame := -1;
    end;
    for Direction := 1 to 6 do
    begin
      Index := Action * 6 + Direction - 1;
      Sequence := TImageSequence.Create(List);
      Sequence.SequenceMode := smFrameTable;
      Sequence.SequenceSpeed := SequenceSpeedBox.ItemIndex;
      Sequence.dXshift := XshiftEdit.Value;
      Sequence.dYshift := YshiftEdit.Value;
      Sequence.ImageLibraryName := ILManagerComboBox.ImageLibraryName;
      for Frame := DirectionOrder[Direction] * 100 + FirstFrame to DirectionOrder[Direction] * 100 + LastFrame do
        Sequence.FrameTable.Add(Frame);
      List.SetImageSequence(Index, Sequence);
    end;
  end;
end;


end.
