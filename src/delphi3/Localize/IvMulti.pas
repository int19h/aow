unit IvMulti;

{ Draft declarations of IvMulti, from Localize.dpl.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, IvDictio;

type
  TIvTranslator = class;


  { TIvTranslator (instance size 160, VMT 0040C4E8) }
  TIvTranslator = class(TIvCustomTranslator)
  public
    F_IvTranslator_54: array[0..75] of Byte;
    procedure Reserved_040; virtual; abstract; { unused slot }
    procedure Reserved_044; virtual; abstract; { unused slot }
    procedure Reserved_048; virtual; abstract; { unused slot }
    procedure Reserved_04C; virtual; abstract; { unused slot }
    procedure Reserved_050; virtual; abstract; { unused slot }
    procedure Reserved_054; virtual; abstract; { unused slot }
    procedure Reserved_058; virtual; abstract; { unused slot }
    procedure Reserved_05C; virtual; abstract; { unused slot }
    procedure Reserved_060; virtual; abstract; { unused slot }
    procedure Reserved_064; virtual; abstract; { unused slot }
    procedure Reserved_068; virtual; abstract; { unused slot }
    procedure Reserved_06C; virtual; abstract; { unused slot }
  end;


implementation


initialization
finalization

end.
