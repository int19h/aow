{ Interface declaration run owned by P2. }
  { TExportTextStream (instance size 44, VMT 55724894) }
  TExportTextStream = class(TEWriteTextStorageStream)
  public
    procedure rwString(var S: string; ID: Integer); override;
    procedure rwStrings(Strings: Classes.TStrings; ID: Integer); override;
  end;

  { TTranslateTextStream (instance size 40, VMT 55724960) }
  TTranslateTextStream = class(TTranslateStorageStream)
  public
    FDictionary: TIvDictionary; { $24; 557973C9 }
    procedure TranslateStrings(var Strings: Classes.TStrings); override;
    procedure TranslateString(var S: string); override;
  end;

