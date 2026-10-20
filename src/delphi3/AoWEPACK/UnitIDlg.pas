unit UnitIDlg;

{ Draft declarations of UnitIDlg, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TUnitInfoDlg = class;


  { TUnitInfoDlg (instance size 564, VMT 557FF1B8) }
  TUnitInfoDlg = class(TForm)
  published
    OKBtn: TButton; { +$1DC }
    NamePnl: TPanel; { +$1E0 }
    Panel5: TPanel; { +$1E4 }
    Panel4: TPanel; { +$1E8 }
    AbilitiesMemo: TMemo; { +$1EC }
    Panel3: TPanel; { +$1F0 }
    Image10: TImage; { +$1F4 }
    Image9: TImage; { +$1F8 }
    Image8: TImage; { +$1FC }
    Image7: TImage; { +$200 }
    Image6: TImage; { +$204 }
    AttackLbl: TLabel; { +$208 }
    DefenseLbl: TLabel; { +$20C }
    DamageLbl: TLabel; { +$210 }
    ResistanceLbl: TLabel; { +$214 }
    HitPointLbl: TLabel; { +$218 }
    Panel1: TPanel; { +$21C }
    CloseBtn: TButton; { +$220 }
    AlignmentPnl: TPanel; { +$224 }
    Image1: TImage; { +$228 }
    MovesLbl: TLabel; { +$22C }
    Translator: TIvTranslator; { +$230 }
  public
    function ShowUnit(AUnit: TAbstractUnit): Integer;
    function ShowUnitResource(Resource: TUnitResource): Integer;
  end;


implementation

type
  { needs: typed TAbstractUnit virtual results. The slots are preserved in this
    local ABI view; it is never instantiated. }
  TUnitView = class(TAbilityOwner)
    procedure Slot9C; virtual; abstract;
    procedure SlotA0; virtual; abstract;
    procedure SlotA4; virtual; abstract;
    procedure SlotA8; virtual; abstract;
    procedure SlotAC; virtual; abstract;
    procedure SlotB0; virtual; abstract;
    procedure SlotB4; virtual; abstract;
    procedure SlotB8; virtual; abstract;
    procedure SlotBC; virtual; abstract;
    function GetAttack: Shortint; virtual; abstract; { +$C0 }
    function GetDefense: Shortint; virtual; abstract; { +$C4 }
    function GetDamage: Shortint; virtual; abstract; { +$C8 }
    function GetResistance: Shortint; virtual; abstract; { +$CC }
    function GetHits: Shortint; virtual; abstract; { +$D0 }
    function GetMoves: Shortint; virtual; abstract; { +$D4 }
    procedure SlotD8; virtual; abstract;
    procedure SlotDC; virtual; abstract;
    procedure SlotE0; virtual; abstract;
    procedure SlotE4; virtual; abstract;
    procedure SlotE8; virtual; abstract;
    procedure SlotEC; virtual; abstract;
    procedure SlotF0; virtual; abstract;
    procedure SlotF4; virtual; abstract;
    function GetName: string; virtual; abstract; { +$F8 }
    function GetAlignment: TAlignment; virtual; abstract; { +$FC }
  end;
  PUnitResourceView = ^TUnitResourceView;
  TUnitResourceView = record
    Reserved00: array[0..$27] of Byte;
    Alignment: Byte;
    Attack, Defense, Damage, Hits, Moves, Resistance: Shortint;
    Reserved2F: array[0..8] of Byte;
    AbilityOwner: TAbilityOwner; { +$38 }
  end;

const
  { needs: AoWE.TAlignmentRStr, an initialized string table absent from the draft. }
  AlignmentNames: array[TAlignment] of string =
    ('Pure Good', 'Good', 'Pure Neutral', 'Neutral', 'Evil', 'Pure Evil', 'None');

{ needs: typed callable results for the draft methods; preserve the existing ABI. }
function Stat(AUnit: TAbstractUnit; VMTOffset: Integer): Shortint; assembler;
asm mov ecx,[eax]; add ecx,edx; jmp dword ptr [ecx] end;
function UnitAlignment(AUnit: TAbstractUnit): TAlignment; assembler;
asm mov ecx,[eax]; jmp dword ptr [ecx+$FC] end;
function TranslateABI(const S: string): string; assembler;
asm jmp AoWE.TranslateRStr end;
function FormatABI(const S: string; const Args: array of const): string; assembler;
asm jmp AoWE.Format end;

function ResourceName(Resource: TUnitResource): string; assembler;
asm jmp TUnitResource.GetUnitName end;

function TUnitInfoDlg.ShowUnit(AUnit: TAbstractUnit): Integer;
begin
  DefenseLbl.Caption := IntToStr(TUnitView(AUnit).GetDefense);
  AttackLbl.Caption := IntToStr(TUnitView(AUnit).GetAttack);
  DamageLbl.Caption := IntToStr(TUnitView(AUnit).GetDamage);
  ResistanceLbl.Caption := IntToStr(TUnitView(AUnit).GetResistance);
  HitPointLbl.Caption := IntToStr(TUnitView(AUnit).GetHits);
  NamePnl.Caption := TUnitView(AUnit).GetName;
  AbilitiesMemo.Lines.Clear;
  AlignmentPnl.Caption := FormatABI(TranslateABI(AlignmentXRStr),
    [TranslateABI(AlignmentNames[TUnitView(AUnit).GetAlignment])]);
  AUnit.ListAbilities(AbilitiesMemo.Lines);
  MovesLbl.Caption := IntToStr(TUnitView(AUnit).GetMoves);
  Result := ShowModal;
end;

function TUnitInfoDlg.ShowUnitResource(Resource: TUnitResource): Integer;
begin
  DefenseLbl.Caption := IntToStr(PUnitResourceView(Resource)^.Defense);
  AttackLbl.Caption := IntToStr(PUnitResourceView(Resource)^.Attack);
  DamageLbl.Caption := IntToStr(PUnitResourceView(Resource)^.Damage);
  ResistanceLbl.Caption := IntToStr(PUnitResourceView(Resource)^.Resistance);
  HitPointLbl.Caption := IntToStr(PUnitResourceView(Resource)^.Hits);
  MovesLbl.Caption := IntToStr(PUnitResourceView(Resource)^.Moves);
  NamePnl.Caption := ResourceName(Resource);
  AbilitiesMemo.Lines.Clear;
  AlignmentPnl.Caption := FormatABI(TranslateABI(AlignmentXRStr),
    [TranslateABI(AlignmentNames[TAlignment(PUnitResourceView(Resource)^.Alignment)])]);
  PUnitResourceView(Resource)^.AbilityOwner.ListAbilities(AbilitiesMemo.Lines);
  Result := ShowModal;
end;

initialization
finalization

end.
