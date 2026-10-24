unit AoWMapEF;

{ Draft declarations of AoWMapEF, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Position $1F0, completion event $1F4, object $1FC, rollback stream $200. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWMapEditForm = class;


  { TAoWMapEditForm (instance size 516, VMT 00417174; $1F0 FPositionInfo, $1FC FEditObject) }
  TAoWMapEditForm = class(TForm)
  public
    published
    ClientPnl: TPanel; { +01DC }
    ButtonPnl: TPanel; { +01E0 }
    OKBtn: TButton; { +01E4 }
    CancelBtn: TButton; { +01E8 }
    Translator: TIvTranslator; { +01EC }
    public
    FPositionInfo: PPoint; { $1F0 }
    FOnEditDone: TEditDoneEvent; { $1F4 }
    FEditObject: TEObject; { $1FC }
    FEditStream: TMemoryStream; { $200 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure SetPositionInfo(Info: PPoint);
    procedure vmt80; virtual;  { +080 }
    procedure vmt84; virtual;  { +084 }
    procedure vmt88; virtual;  { +088 }
    procedure vmt8C; virtual;  { +08C }
    constructor vmt90(Obj: TEObject; Done: TEditDoneEvent); virtual; { +090 }
    published procedure FormClose(Sender: TObject; var Action: TCloseAction); public
    published procedure FormShow; public
    published procedure OKBtnClick(Sender: TObject); public
  end;


implementation

uses AoWE, MDIForm;

var EditFormPosition: TPoint;

constructor TAoWMapEditForm.Create(AOwner: Classes.TComponent);
begin
  raise Exception.Create('Use CreateForm instead of Create (TAoWMapObjEditForm)');
end;

procedure TAoWMapEditForm.vmt80;
begin
  AoWEngine.WriteEObject(FEditStream, FEditObject, nil);
end;


procedure TAoWMapEditForm.vmt84;
begin
  FEditStream.Position := 0;
  AoWEngine.ReadEObject(FEditStream, FEditObject, nil);
end;


constructor TAoWMapEditForm.vmt90(Obj: TEObject; Done: TEditDoneEvent);
begin { Match trials (3): addressable/absolute locals, named temporaries, with scopes, Pointer casts, zero-shift scheduling, identity assignments; still differs. }
  FEditStream := TMemoryStream.Create;
  FPositionInfo := @EditFormPosition;
  FOnEditDone := Done;
  FEditObject := Obj;
  vmt80;
  vmt88;
  inherited Create(MainForm);
  MainForm.HSMEdit.PauseFrameUpdateLoop;
  ShowModal;
end;


destructor TAoWMapEditForm.Destroy;
var Position: PPoint;
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling, identity assignments; still differs. }
  Position := FPositionInfo;
  if Position <> nil then
  begin
    Position^.X := Left;
    Position^.Y := Top;
  end;
  MainForm.HSMEdit.ResumeFrameUpdateLoop;
  if ModalResult = mrCancel then vmt84;
  FEditStream.Free;
  vmt8C;
  inherited Destroy;
end;


procedure TAoWMapEditForm.vmt88;
begin end;

procedure TAoWMapEditForm.vmt8C;
begin
  if Assigned(FOnEditDone) then
    if ModalResult = mrCancel then FOnEditDone(erCancel, FEditObject)
    else FOnEditDone(erOK, FEditObject);
end;


procedure TAoWMapEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;


procedure TAoWMapEditForm.FormShow;
begin
  if (FPositionInfo <> nil) and (FPositionInfo^.X <> 0) and (FPositionInfo^.Y <> 0) then
  begin
    Left := FPositionInfo^.X;
    Top := FPositionInfo^.Y;
  end
  else
  begin
    Left := (Screen.Width - Width) shr 1;
    Top := (Screen.Height - Height) shr 1;
  end;
end;


procedure TAoWMapEditForm.OKBtnClick(Sender: TObject);
begin
  if AoWHSMap <> nil then AoWHSMap.SetModified;
end;



procedure TAoWMapEditForm.SetPositionInfo(Info: PPoint);
begin
  FPositionInfo := Info;
end;

end.
