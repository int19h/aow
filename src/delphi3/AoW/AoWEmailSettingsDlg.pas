unit AoWEmailSettingsDlg;

{ Draft declarations of AoWEmailSettingsDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TEmailSettingsDlg = class;


  { TEmailSettingsDlg (instance size 144, VMT 0040EBE8) }
  TEmailSettingsDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    TCeltL: TAoWFrame; { +0050 }
    TCeltLineL: TAOWImage; { +0054 }
    AOWImage1: TAOWImage; { +0058 }
    AOWImage2: TAOWImage; { +005C }
    OKCancelPnl: TAOWPanel; { +0060 }
    OKBtn: TAOWButton; { +0064 }
    CancelBtn: TAOWButton; { +0068 }
    LocalEmailAddressLbl: TAOWLabel; { +006C }
    LocalEmailAddressEdit: TAOWEdit; { +0070 }
    SMTPServerLbl: TAOWLabel; { +0074 }
    SMTPServerEdit: TAOWEdit; { +0078 }
    AttachmentDirectoryLbl: TAOWLabel; { +007C }
    AttachmentDirectoryEdit: TAOWEdit; { +0080 }
    Close: TAOWButton; { +0084 }
    TitleIcon: TAOWImage; { +0088 }
    Translator: TIvTranslator; { +008C }
    public
    procedure OKBtnClick;  { draft }
    procedure CancelBtnClick;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TEmailSettingsDlg.OKBtnClick;
begin end;

procedure TEmailSettingsDlg.CancelBtnClick;
begin end;

procedure TEmailSettingsDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
