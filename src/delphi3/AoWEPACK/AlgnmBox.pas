unit AlgnmBox;

{ Draft declarations of AlgnmBox, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Recovered alignment selection and original alignment-set constants. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TAlignmentBox = class;


  { TAlignmentBox (instance size 372, VMT 557FEB3C) }
  TAlignmentBox = class(TComboBox)
  public
    FAlignment: TAlignment; { +$170 }
    FAlignments: TAlignments; { +$171 }
    FSetMode: Boolean; { +$172 }
    F_AlignmentBox_173: array[0..0] of Byte;
    procedure Loaded; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure GenerateItems;
    procedure SetAlignments(Value: TAlignments);
    procedure SetAlignment(Value: TAlignment);
    procedure Change; override;
  end;

procedure Register;

implementation

const
  NoneRStr: string = 'None'; { needs: missing AoWE.NoneRStr }

{ needs: AlsToInt(TAlignments): Integer and IntToAls(Integer): TAlignments.
  Tail jumps preserve the proven original ABI without changing implementation headers. }
function AlignmentSetToInt(Value: TAlignments): Integer; assembler;
asm jmp AoWE.AlsToInt end;
function AlignmentIntToSet(Value: Integer): TAlignments; assembler;
asm jmp AoWE.IntToAls end;

const
  AlignAll: TAlignments = [alPureGood, alGood, alNeutral, alEvil, alPureEvil, alNone];
  AlignPureGood: TAlignments = [alPureGood, alGood, alNone];
  AlignGood: TAlignments = [alPureGood, alGood, alNeutral, alNone];
  AlignPureNeutral: TAlignments = [alNeutral, alNone];
  AlignNeutral: TAlignments = [alGood, alNeutral, alEvil, alNone];
  AlignEvil: TAlignments = [alNeutral, alEvil, alPureEvil, alNone];
  AlignPureEvil: TAlignments = [alEvil, alPureEvil, alNone];

constructor TAlignmentBox.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FSetMode := True;
end;

procedure TAlignmentBox.GenerateItems;
var Text: string;
begin
  Items.Clear;
  if FSetMode then
  begin
    Text := AoWE.TranslateRStr(NoneRStr);
    Items.AddObject(Text, TObject(AlignmentSetToInt(AlignAll)));
    Text := AoWE.TranslateRStr(PureGoodRStr);
    Items.AddObject(Text, TObject(AlignmentSetToInt(AlignPureGood)));
    Text := AoWE.TranslateRStr(GoodRStr);
    Items.AddObject(Text, TObject(AlignmentSetToInt(AlignGood)));
    Text := AoWE.TranslateRStr(PureNeutralRStr);
    Items.AddObject(Text, TObject(AlignmentSetToInt(AlignPureNeutral)));
    Text := AoWE.TranslateRStr(NeutralRStr);
    Items.AddObject(Text, TObject(AlignmentSetToInt(AlignNeutral)));
    Text := AoWE.TranslateRStr(EvilRStr);
    Items.AddObject(Text, TObject(AlignmentSetToInt(AlignEvil)));
    Text := AoWE.TranslateRStr(PureEvilRStr);
    Items.AddObject(Text, TObject(AlignmentSetToInt(AlignPureEvil)));
  end
  else
  begin
    Text := AoWE.TranslateRStr(NoneRStr);
    Items.AddObject(Text, TObject(6));
    Text := AoWE.TranslateRStr(PureGoodRStr);
    Items.AddObject(Text, TObject(0));
    Text := AoWE.TranslateRStr(GoodRStr);
    Items.AddObject(Text, TObject(1));
    Text := AoWE.TranslateRStr(PureNeutralRStr);
    Items.AddObject(Text, TObject(2));
    Text := AoWE.TranslateRStr(NeutralRStr);
    Items.AddObject(Text, TObject(3));
    Text := AoWE.TranslateRStr(EvilRStr);
    Items.AddObject(Text, TObject(4));
    Text := AoWE.TranslateRStr(PureEvilRStr);
    Items.AddObject(Text, TObject(5));
  end;
end;

procedure TAlignmentBox.SetAlignments(Value: TAlignments);
var I: Integer;
begin
  I := Items.IndexOfObject(TObject(AlignmentSetToInt(Value)));
  if I <> -1 then ItemIndex := I;
  if (ItemIndex = -1) and (Items.Count <> 0) then ItemIndex := 0;
  if ItemIndex <> -1 then FAlignments := AlignmentIntToSet(Integer(Items.Objects[ItemIndex]))
  else FAlignments := [];
end;

procedure TAlignmentBox.SetAlignment(Value: TAlignment);
var I: Integer;
begin
  I := Items.IndexOfObject(TObject(Value));
  if I <> -1 then ItemIndex := I;
  if (ItemIndex = -1) and (Items.Count <> 0) then ItemIndex := 0;
  if ItemIndex <> -1 then FAlignment := TAlignment(Items.Objects[ItemIndex])
  else FAlignment := alPureGood;
end;

procedure TAlignmentBox.Change;
begin
  if ItemIndex <> -1 then
    if FSetMode then FAlignments := AlignmentIntToSet(Integer(Items.Objects[ItemIndex]))
    else FAlignment := TAlignment(Items.Objects[ItemIndex])
  else
  begin
    FAlignments := [];
    FAlignment := alPureGood;
  end;
  inherited Change;
end;

procedure TAlignmentBox.Loaded;
begin
  inherited Loaded;
  GenerateItems;
end;

procedure Register;
begin RegisterComponents('AoW', [TAlignmentBox]); end;

initialization
finalization

end.
