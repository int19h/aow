unit ResEForm;

{ Draft declarations of ResEForm, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  $1EC engine, $1F0 completion event, $1F8 resource. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TResourceEditForm = class;


  { TResourceEditForm (instance size 508, VMT 0040B99C) }
  TResourceEditForm = class(TForm)
  public
    published
    Panel1: TPanel; { +01DC }
    CancelBtn: TButton; { +01E0 }
    OKBtn: TButton; { +01E4 }
    Bevel2: TBevel; { +01E8 }
    public
    FEngine: TEngine; { $1EC }
    FOnEditDone: TEditDoneEvent; { $1F0 }
    FEditResource: TEResource; { $1F8; AoWEd 0040BB4E }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    constructor vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent); virtual;  { +080; AoWEd 0040BB30 }
    published procedure FormClose(Sender: TObject; var Action: TCloseAction); public
    { conflict: procedure FormClose(Sender: TObject; var Action: TCloseAction); (* AoWEd 004170EC *) }
  end;


implementation

constructor TResourceEditForm.Create(AOwner: Classes.TComponent);
begin
  raise Exception.Create('Use CreateForm instead of Create (TResourceEditForm)');
end;

constructor TResourceEditForm.vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent);
begin
  FEngine := AEngine;
  FEditResource := Resource;
  FOnEditDone := Done;
  inherited Create(Application.MainForm);
end;

destructor TResourceEditForm.Destroy;
begin
  inherited Destroy;
  if Assigned(FOnEditDone) then
    if ModalResult = mrOK then FOnEditDone(erOK, FEditResource)
    else FOnEditDone(erCancel, FEditResource);
end;

procedure TResourceEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;


end.
