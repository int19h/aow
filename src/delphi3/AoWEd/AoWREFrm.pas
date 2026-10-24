unit AoWREFrm;

{ AoW resource modal editor, instance size $1FC, inherited fields only. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ResEForm;

type
  TAoWResourceEditForm = class;


  { TAoWResourceEditForm (instance size 508, VMT 0040BC6C) }
  TAoWResourceEditForm = class(TResourceEditForm)
  public
    destructor Destroy; override;
    constructor vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent); override;
  end;


implementation

uses MDIForm;

constructor TAoWResourceEditForm.vmt80(AEngine: TEngine; Resource: TEResource; Done: TEditDoneEvent);
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling; still differs. }
  inherited vmt80(AEngine, Resource, Done);
  with MainForm do
    if HSMEdit.Activated then HSMEdit.PauseFrameUpdateLoop;
  ShowModal;
end;

destructor TAoWResourceEditForm.Destroy;
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling; still differs. }
  with MainForm do
    if HSMEdit.Activated then HSMEdit.ResumeFrameUpdateLoop;
  inherited Destroy;
end;


end.
