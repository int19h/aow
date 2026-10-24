unit AlgnmBox;

{ Draft declarations of AlgnmBox, from AoWEPACK.dpl.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Recovered alignment selection and original alignment-set constants. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

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
  published property UseSets: Boolean read FSetMode write FSetMode; end;

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
  AlignAll: ^TAlignments = @AoWE.alsAll;
  AlignPureGood: ^TAlignments = @AoWE.alsPureGood;
  AlignGood: ^TAlignments = @AoWE.alsGood;
  AlignPureNeutral: ^TAlignments = @AoWE.alsPureNeutral;
  AlignNeutral: ^TAlignments = @AoWE.alsNeutral;
  AlignEvil: ^TAlignments = @AoWE.alsEvil;
  AlignPureEvil: ^TAlignments = @AoWE.alsPureEvil;

constructor TAlignmentBox.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FSetMode := True;
end;

procedure TAlignmentBox.GenerateItems;
begin
  Items.Clear;
  if FSetMode then
  begin
    Items.AddObject(AoWE.TranslateRStr(AoWE.NoneRStr), TObject(AoWE.AlsToInt(AlignAll^)));
    Items.AddObject(AoWE.TranslateRStr(PureGoodRStr), TObject(AoWE.AlsToInt(AlignPureGood^)));
    Items.AddObject(AoWE.TranslateRStr(GoodRStr), TObject(AoWE.AlsToInt(AlignGood^)));
    Items.AddObject(AoWE.TranslateRStr(PureNeutralRStr), TObject(AoWE.AlsToInt(AlignPureNeutral^)));
    Items.AddObject(AoWE.TranslateRStr(NeutralRStr), TObject(AoWE.AlsToInt(AlignNeutral^)));
    Items.AddObject(AoWE.TranslateRStr(EvilRStr), TObject(AoWE.AlsToInt(AlignEvil^)));
    Items.AddObject(AoWE.TranslateRStr(PureEvilRStr), TObject(AoWE.AlsToInt(AlignPureEvil^)));
  end
  else
  begin
    Items.AddObject(AoWE.TranslateRStr(AoWE.NoneRStr), TObject(6));
    Items.AddObject(AoWE.TranslateRStr(PureGoodRStr), TObject(0));
    Items.AddObject(AoWE.TranslateRStr(GoodRStr), TObject(1));
    Items.AddObject(AoWE.TranslateRStr(PureNeutralRStr), TObject(2));
    Items.AddObject(AoWE.TranslateRStr(NeutralRStr), TObject(3));
    Items.AddObject(AoWE.TranslateRStr(EvilRStr), TObject(4));
    Items.AddObject(AoWE.TranslateRStr(PureEvilRStr), TObject(5));
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
