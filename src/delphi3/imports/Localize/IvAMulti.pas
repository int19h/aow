unit IvAMulti;

{ Draft declarations of IvAMulti, from Localize.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, IvDictio;

type
  TIvCustomFileDictionary = class;


  { TIvCustomFileDictionary (instance size 136, VMT 00419CE0) }
  TIvCustomFileDictionary = class(TIvDictionary)
  public
    FFileName: string; { $7C; 5579767D } F_IvCustomFileDictionary_80: array[0..7] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
    function GetTranslationCount: Integer; override;
    procedure LanguageChanged(A1: Integer; A2: Integer); override;
    function TranslateContextString(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Integer; override;
    function CanBeOpened: Byte; override;
    function TranslateString(A1: Integer; A2: Integer): Integer; override;
    procedure LoadTranslation; virtual; abstract;  { +074 draft }
  end;


implementation

constructor TIvCustomFileDictionary.Create(AOwner: TComponent);
begin end;

destructor TIvCustomFileDictionary.Destroy;
begin end;

function TIvCustomFileDictionary.GetTranslationCount: Integer;
begin Result := 0; end;

function TIvCustomFileDictionary.CanBeOpened: Byte;
begin Result := 0; end;

procedure TIvCustomFileDictionary.LanguageChanged(A1: Integer; A2: Integer);
begin end;

function TIvCustomFileDictionary.TranslateString(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

function TIvCustomFileDictionary.TranslateContextString(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Integer;
begin Result := 0; end;


initialization
finalization

end.
