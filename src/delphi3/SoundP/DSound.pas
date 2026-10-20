unit DSound;

{ The DSound unit of SoundP.dpl: DirectSound declarations (a translation of the DirectX SDK's
  dsound.h, like the DDraw declarations in GFXE), written for the original compiler (Delphi 3.02)
  and compared function by function with the shipped module (tools/match.py).

  Only what the package shows is declared: the three speaker configuration macros (the only code
  of the unit) and the CLSID/IID typed constants (exported data, in this order). The original
  also declares the interfaces IDirectSound, IDirectSoundBuffer, IDirectSound3DListener,
  IDirectSound3DBuffer, IDirectSoundCapture, IDirectSoundCaptureBuffer, IDirectSoundNotify and
  IKsPropertySet (their type info is exported), but no code of SoundP calls them, so their
  method slots are not known and they are left out. }

interface

uses
  Windows;

const
  CLSID_DirectSound: TGUID = '{47D4D946-62E8-11CF-93BC-444553540000}';
  CLSID_DirectSoundCapture: TGUID = '{B0210780-89CD-11D0-AF08-00A0C925CD16}';
  IID_IDirectSound: TGUID = '{279AFA83-4981-11CE-A521-0020AF0BE560}';
  IID_IDirectSoundBuffer: TGUID = '{279AFA85-4981-11CE-A521-0020AF0BE560}';
  IID_IDirectSound3DListener: TGUID = '{279AFA84-4981-11CE-A521-0020AF0BE560}';
  IID_IDirectSound3DBuffer: TGUID = '{279AFA86-4981-11CE-A521-0020AF0BE560}';
  IID_IDirectSoundCapture: TGUID = '{B0210781-89CD-11D0-AF08-00A0C925CD16}';
  IID_IDirectSoundCaptureBuffer: TGUID = '{B0210782-89CD-11D0-AF08-00A0C925CD16}';
  IID_IDirectSoundNotify: TGUID = '{B0210783-89CD-11D0-AF08-00A0C925CD16}';
  IID_IKsPropertySet: TGUID = '{31EFAC30-515C-11D0-A9AA-00AA0061BE93}';

function DSSPEAKER_COMBINED(c, g: Byte): DWORD;
function DSSPEAKER_CONFIG(a: DWORD): Byte;
function DSSPEAKER_GEOMETRY(a: DWORD): Byte;

implementation

function DSSPEAKER_COMBINED(c, g: Byte): DWORD;
begin
  Result := c or (g shl 16);
end;

function DSSPEAKER_CONFIG(a: DWORD): Byte;
begin
  Result := Byte(a);
end;

function DSSPEAKER_GEOMETRY(a: DWORD): Byte;
begin
  Result := Byte(a shr 16);
end;

end.
