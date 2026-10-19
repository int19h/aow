unit ImageLib;

{ Stub of the game's ImageLib unit (Ilpack.dpl): only the entry point the Engine unit calls, with
  the parameter layout the call site in Engine.TEResource.Draw shows (Rect by value, Mode as a
  byte, a Boolean and a var record on the stack). The body is a stub until Ilpack is matched. }

interface

uses
  Windows;

procedure BltLibraryImage(Dest: TObject; Image: Pointer; Rect: TRect; Mode: Byte;
  A, B, C, D: Integer; Flag: Boolean; var R: TRect);

implementation

procedure BltLibraryImage(Dest: TObject; Image: Pointer; Rect: TRect; Mode: Byte;
  A, B, C, D: Integer; Flag: Boolean; var R: TRect);
begin
end;

end.
