unit IvDictio;

{ Draft declarations of IvDictio, from Localize.dpl.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms;

type
  TIvDictionary = class;
  TIvCustomTranslator = class;


  { TIvDictionary (instance size 124, VMT 0040508C) }
  TIvDictionary = class(TComponent)
  public
    F_IvDictionary_24: array[0..31] of Byte; FLanguage: Integer; { $44; 55797B4F } F_IvDictionary_48: array[0..51] of Byte;
    destructor Destroy; override;
    procedure DefineProperties(Filer: TFiler); override;
    constructor Create(AOwner: TComponent); override;
    function GetLanguageCount: Integer; virtual; abstract;  { +028 draft }
    procedure GetLanguageData(A1: Integer; A2: Integer); virtual; abstract;  { +02C draft }
    function GetLocaleCount: Integer; virtual; abstract;  { +030 draft }
    procedure GetLocaleData(A1: Integer; A2: Integer); virtual; abstract;  { +034 draft }
    function GetTranslationCount: Integer; virtual;  { +038 draft }
    procedure LanguageChanged(A1: Integer; A2: Integer); virtual;  { +03C draft }
    function TranslateContextString(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Integer; virtual; abstract;  { +040 draft }
    procedure Open; virtual; { +044; 55797684 }
    procedure Close; virtual; { +048; 55797724 }
    function CanBeOpened: Byte; virtual;  { +04C draft }
    procedure GetLanguageDatas(A1: Integer; A2: Integer); virtual;  { +050 draft }
    procedure GetLocaleDatas(A1: Integer); virtual;  { +054 draft }
    function TranslateString(A1: Integer; A2: Integer): Integer; virtual;  { +058 draft }
    procedure TranslateStrings(A1: Integer); virtual;  { +05C draft }
    function GetTranslationMode: Integer; virtual;  { +060 draft }
    procedure SynchronizeLocale; virtual;  { +064 draft }
    procedure SynchronizeLanguage; virtual;  { +068 draft }
    procedure GetPrimaryLanguages(A1: Integer; A2: Byte); virtual;  { +06C draft }
    function IsLocaleSupported(A1: Integer; A2: Integer): Byte; virtual;  { +070 draft }
    procedure SetDictionaryName(const Name: string);
    procedure SetLanguage(A1: Integer);
    function Translate(const S: string): string;
  end;

  { TIvCustomTranslator (instance size 84, VMT 00405464) }
  TIvCustomTranslator = class(TComponent)
  public
    F_IvCustomTranslator_24: array[0..47] of Byte;
    procedure Reserved_028; virtual; abstract; { unused slot }
    procedure Reserved_02C; virtual; abstract; { unused slot }
    procedure Reserved_030; virtual; abstract; { unused slot }
    procedure Translate; virtual; abstract; { $34; AoWEd 0042856F }
    procedure Reserved_038; virtual; abstract; { unused slot }
    procedure Reserved_03C; virtual; abstract; { unused slot }
  end;


implementation uses IvParser, IvDemoD, IvStamp, IvCommon;

constructor TIvDictionary.Create(AOwner: TComponent);
begin end;

destructor TIvDictionary.Destroy;
begin end;

procedure TIvDictionary.SetDictionaryName(const Name: string);
begin end;

procedure TIvDictionary.DefineProperties(Filer: TFiler);
begin end;

procedure TIvDictionary.SynchronizeLocale;
begin end;

procedure TIvDictionary.SynchronizeLanguage;
begin end;

procedure TIvDictionary.SetLanguage(A1: Integer);
begin end;

function TIvDictionary.GetTranslationCount: Integer;
begin Result := 0; end;

function TIvDictionary.GetTranslationMode: Integer;
begin Result := 0; end;

function TIvDictionary.TranslateString(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TIvDictionary.TranslateStrings(A1: Integer);
begin end;

procedure TIvDictionary.LanguageChanged(A1: Integer; A2: Integer);
begin end;

function TIvDictionary.IsLocaleSupported(A1: Integer; A2: Integer): Byte;
begin Result := 0; end;

function TIvDictionary.CanBeOpened: Byte;
begin Result := 0; end;

procedure TIvDictionary.Open;
begin end;

procedure TIvDictionary.Close;
begin end;

function TIvDictionary.Translate(const S: string): string;
begin Result := ''; end;

procedure TIvDictionary.GetLanguageDatas(A1: Integer; A2: Integer);
begin end;

procedure TIvDictionary.GetLocaleDatas(A1: Integer);
begin end;

procedure TIvDictionary.GetPrimaryLanguages(A1: Integer; A2: Byte);
begin end;


initialization
finalization

end.
