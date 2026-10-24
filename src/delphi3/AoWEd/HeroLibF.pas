unit HeroLibF;

{ Hero library editor recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, HeroGrid, AoWE;

type
  THeroLibraryEditForm = class;


  { THeroLibraryEditForm: size $234; $230 selected library index. VMT 004245B4. }
  THeroLibraryEditForm = class(TForm)
  public
    published
    Panel1: TPanel; { +01DC }
    CloseBtn: TButton; { +01E0 }
    AddBtn: TButton; { +01E4 }
    CopyBtn: TButton; { +01E8 }
    LibraryHeroGrid: THeroGrid; { +01EC }
    ItemToolbar: TToolBar; { +01F0 }
    ToolButton3: TToolButton; { +01F4 }
    NewLibrary: TToolButton; { +01F8 }
    DeleteLibrary: TToolButton; { +01FC }
    ToolButton6: TToolButton; { +0200 }
    EditHeroBtn: TToolButton; { +0204 }
    NewHero: TToolButton; { +0208 }
    DeleteHero: TToolButton; { +020C }
    ToolButton8: TToolButton; { +0210 }
    SortOnNamesBtn: TToolButton; { +0214 }
    SortOnLevelBtn: TToolButton; { +0218 }
    HeroImageList: TImageList; { +021C }
    Panel2: TPanel; { +0220 }
    LibraryLbl: TLabel; { +0224 }
    LibraryCB: TComboBox; { +0228 }
    Translator: TIvTranslator; { +022C }
    public
    FLibraryIndex: Integer; { $230 }
    procedure EditHero(Hero: THero; ReadOnly: Boolean);
    procedure EditSelectedHero;
    procedure UpdateLibraries;
    procedure SetLibraryIndex(Index: Integer);
    published procedure FormShow(Sender: TObject); public
    published procedure AddBtnClick(Sender: TObject); public
    published procedure CopyBtnClick(Sender: TObject); public
    published procedure LibraryCBChange(Sender: TObject); public
    published procedure SortOnNameBtnClick(Sender: TObject); public
    published procedure SortOnLevelClick(Sender: TObject); public
    published procedure NewHeroClick(Sender: TObject); public
    published procedure NewLibraryClick(Sender: TObject); public
    published procedure DeleteLibraryClick(Sender: TObject); public
    published procedure CloseBtnClick(Sender: TObject); public
    published procedure EditHeroBtnClick(Sender: TObject); public
    published procedure DeleteHeroClick(Sender: TObject); public
  end;


implementation

uses EHero;

procedure THeroLibraryEditForm.EditHero(Hero: THero; ReadOnly: Boolean);
var Dlg: THeroEditForm;
begin
  Dlg := THeroEditForm.Create(Application);
  if ReadOnly then Dlg.EditLibraryHero(Hero) else Dlg.EditHero(Hero);
  Dlg.Free;
end;

procedure THeroLibraryEditForm.EditSelectedHero;
begin
  if LibraryHeroGrid.GetSelectedHero <> nil then
    EditHero(LibraryHeroGrid.GetSelectedHero, (AoWHSMap <> nil) and (FLibraryIndex = 0));
end;

procedure THeroLibraryEditForm.UpdateLibraries;
var Manager: THeroLibraryManager; I: Integer;
begin
  LibraryCB.Items.Clear;
  if AoWHSSet <> nil then
  begin
    Manager := AoWHSSet.FHeroLibraries;
    for I := 0 to Manager.GetCount - 1 do LibraryCB.Items.Add(Manager.GetLibrary(I).GetName);
  end
  else FLibraryIndex := -1;
  LibraryCB.ItemIndex := FLibraryIndex;
  CopyBtn.Enabled := AoWHSMap <> nil;
  AddBtn.Enabled := AoWHSMap <> nil;
end;

procedure THeroLibraryEditForm.SetLibraryIndex(Index: Integer);
begin
  if (Index >= 0) and (Index < LibraryCB.Items.Count) then FLibraryIndex := Index
  else FLibraryIndex := 0;
  LibraryCB.ItemIndex := FLibraryIndex;
  if (AoWHSSet <> nil) and (FLibraryIndex <> -1) then
  begin
    LibraryHeroGrid.SetHeroes(AoWHSSet.FHeroLibraries.GetLibrary(FLibraryIndex));
    LibraryHeroGrid.FEditable := (FLibraryIndex <> 0) or (AoWHSMap = nil);
  end
  else
  begin
    LibraryHeroGrid.SetHeroes(nil);
    LibraryHeroGrid.FEditable := False;
  end;
  if (FLibraryIndex = 0) and (AoWHSMap <> nil) then
  begin
    DeleteLibrary.Enabled := False;
    NewHero.Enabled := False;
    DeleteHero.Enabled := False;
  end
  else
  begin
    DeleteLibrary.Enabled := True;
    NewHero.Enabled := True;
    DeleteHero.Enabled := True;
  end;
end;

procedure THeroLibraryEditForm.FormShow(Sender: TObject);
begin
  UpdateLibraries;
  SetLibraryIndex(FLibraryIndex);
end;

procedure THeroLibraryEditForm.AddBtnClick(Sender: TObject);
var X, Y, Index: Integer; Hero: THero;
begin
  with LibraryHeroGrid do
    for Y := Selection.Top to Selection.Bottom do
      for X := Selection.Left to Selection.Right do
      begin
        Index := ImageIndex(X, Y);
        if (GetHero(Index) <> nil) and
          (AoWHSMap.FHeroControl.IndexOfLibraryEx(GetHero(Index).GetLibraryName, GetHero(Index).FLibraryID) = -1) then
        begin
          Hero := THero(GetHero(Index).Copy(AoWEngine));
          Hero.Activate;
          Hero.Release;
          AoWHSMap.SetModified;
        end
        else Beep;
      end;
end;

procedure THeroLibraryEditForm.CopyBtnClick(Sender: TObject);
var X, Y, Index: Integer; Hero: THero;
begin
  with LibraryHeroGrid do
    for Y := Selection.Top to Selection.Bottom do
      for X := Selection.Left to Selection.Right do
      begin
        Index := ImageIndex(X, Y);
        if GetHero(Index) <> nil then
        begin
          Hero := THero(GetHero(Index).Copy(AoWEngine));
          Hero.FLibraryID := -1;
          Hero.Activate;
          Hero.Release;
          AoWHSMap.SetModified;
        end;
      end;
end;

procedure THeroLibraryEditForm.LibraryCBChange(Sender: TObject);
begin
  SetLibraryIndex(LibraryCB.ItemIndex);
end;

procedure THeroLibraryEditForm.SortOnNameBtnClick(Sender: TObject);
begin
  LibraryHeroGrid.SortOnName;
end;

procedure THeroLibraryEditForm.SortOnLevelClick(Sender: TObject);
begin
  LibraryHeroGrid.SortOnLevel;
end;

procedure THeroLibraryEditForm.NewHeroClick(Sender: TObject);
var Dlg: THeroEditForm; Hero: THero;
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling; still differs. }
  if (FLibraryIndex <> 0) or (AoWHSMap = nil) then
  begin
    Hero := AoWHSSet.FHeroLibraries.GetLibrary(FLibraryIndex).CreateHero;
    Dlg := THeroEditForm.Create(Application);
    if Dlg.EditHero(Hero) then LibraryHeroGrid.UpdateHeroes else Hero.Free;
    Dlg.Free;
  end;
end;

procedure THeroLibraryEditForm.NewLibraryClick(Sender: TObject);
var Name: string; Lib: THeroLibrary;
begin
  Name := InputBox(TranslateRStr(CreateNewLibraryRStr), TranslateRStr(EnterLibraryNameRStr), '');
  if Name <> '' then
  begin
    Lib := AoWHSSet.FHeroLibraries.CreateLibrary(Name);
    if Lib <> nil then
    begin
      UpdateLibraries;
      SetLibraryIndex(AoWHSSet.FHeroLibraries.IndexOfLibrary(Lib));
    end
    else ShowMessage(AoWE.Format(TranslateRStr(XAlreadyExistsRStr), [Name]));
  end;
end;

procedure THeroLibraryEditForm.DeleteLibraryClick(Sender: TObject);
begin
  if (FLibraryIndex <> 0) or (AoWHSMap = nil) then
    if MessageDlg('Are you sure you want to delete libary X ?', mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
    begin
      { Original bug: deleting a hero library calls the item library manager. }
      AoWHSSet.FItemLibraries.DeleteLibrary(FLibraryIndex);
      UpdateLibraries;
      SetLibraryIndex(FLibraryIndex);
    end;
end;

procedure THeroLibraryEditForm.CloseBtnClick(Sender: TObject);
begin
  if AoWHSMap <> nil then
  begin
    AoWHSMap.FHeroControl.UpdateLibraryHeroes;
    AoWHSSet.FHeroLibraries.WriteUserLibraries;
  end;
end;

procedure THeroLibraryEditForm.EditHeroBtnClick(Sender: TObject);
begin
  EditSelectedHero;
end;

procedure THeroLibraryEditForm.DeleteHeroClick(Sender: TObject);
begin
  if (FLibraryIndex <> 0) or (AoWHSMap = nil) then LibraryHeroGrid.DeleteSelectedHero;
end;

end.
