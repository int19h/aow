unit IvBinDic;

{ Draft declarations of IvBinDic, from Localize.dpl.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, IvAMulti;

type
  TIvBinaryDictionary = class;


  { TIvBinaryDictionary (instance size 152, VMT 004208A4) }
  TIvBinaryDictionary = class(TIvCustomFileDictionary)
  public
    F_IvBinaryDictionary_88: array[0..15] of Byte;
    procedure DefineProperties(Filer: TFiler); override;
    function GetLanguageCount: Integer; override;
    procedure GetLanguageData(A1: Integer; A2: Integer); override;
    function GetLocaleCount: Integer; override;
    procedure GetLocaleData(A1: Integer; A2: Integer); override;
    function GetTranslationCount: Integer; override;
    procedure GetLanguageDatas(A1: Integer; A2: Integer); override;
    procedure GetLocaleDatas(A1: Integer); override;
    procedure LoadTranslation; override;
    procedure ReadLanguages(A1: Integer); virtual;  { +078 draft }
    procedure ReadTranslations(A1: Integer); virtual;  { +07C draft }
    procedure ReadLocales(A1: Integer); virtual;  { +080 draft }
  end;


implementation uses IvReader, IvMlRead, IvMLDFil;

procedure TIvBinaryDictionary.ReadLanguages(A1: Integer);
begin end;

procedure TIvBinaryDictionary.ReadTranslations(A1: Integer);
begin end;

procedure TIvBinaryDictionary.ReadLocales(A1: Integer);
begin end;

procedure TIvBinaryDictionary.DefineProperties(Filer: TFiler);
begin end;

function TIvBinaryDictionary.GetLanguageCount: Integer;
begin Result := 0; end;

function TIvBinaryDictionary.GetTranslationCount: Integer;
begin Result := 0; end;

procedure TIvBinaryDictionary.GetLanguageData(A1: Integer; A2: Integer);
begin end;

procedure TIvBinaryDictionary.GetLanguageDatas(A1: Integer; A2: Integer);
begin end;

function TIvBinaryDictionary.GetLocaleCount: Integer;
begin Result := 0; end;

procedure TIvBinaryDictionary.GetLocaleData(A1: Integer; A2: Integer);
begin end;

procedure TIvBinaryDictionary.GetLocaleDatas(A1: Integer);
begin end;

procedure TIvBinaryDictionary.LoadTranslation;
begin end;


initialization
finalization

end.
