unit LicenseF;

{ Draft declarations of LicenseF, from AoWEPACK.dpl.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

type
  TLicenseForm = class;


  { TLicenseForm (instance size 516, VMT 558076CC) }
  TLicenseForm = class(TForm)
  published
    LicenseMemo: TMemo; { +$1DC }
    Panel1: TPanel; { +$1E0 }
    Image1: TImage; { +$1E4 }
    Label1: TLabel; { +$1E8 }
    Panel2: TPanel; { +$1EC }
    Bevel1: TBevel; { +$1F0 }
    Label2: TLabel; { +$1F4 }
    YesBtn: TButton; { +$1F8 }
    NoBtn: TButton; { +$1FC }
    Image2: TImage; { +$200 }
    procedure FormCreate(Sender: TObject);
  end;


implementation

procedure TLicenseForm.FormCreate(Sender: TObject);
begin
  LicenseMemo.Lines.LoadFromFile(AoWEngine.StartupDirectory + 'LICENSE.TXT');
end;

initialization
finalization

end.
