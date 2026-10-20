program matchtest;

{ Host program for the byte-matching of aowFXpck.dpl: it only has to reference every class and
  every non-virtual method so that the linker keeps them. Build with the original compiler:
    C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B -E<outdir> -N<outdir> matchtest.dpr
  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }

{$APPTYPE CONSOLE}

uses
  Classes,
  aowFX in 'aowFX.pas';

var
  L: TXYZList;
  PS: TfxParticleSystem;
  P: TfxParticle;
  E: TfxParticleEffect;
  Z, S, VZ, G: Single;
begin
  L := TXYZList.Create;
  L.Add(TXYZ.Create);
  Writeln(L.Count, Integer(L[0]));
  L.Delete(0);
  L.Clear;
  ScatterPath(L);
  MakeLinePath(0, 0, 1, 1, 2, L);
  MakeSwarmPath(1, 1, 0, 0, 0, 0, sdForward, L);
  MakeLightningPath(0, 0, 1, 1, L);
  MakeArcPath(0, 0, 0, Z, S, VZ, G, L);
  MakeArcPathXY(0, 0, 1, 1, 1, 1, L);
  L.Free;
  PS := TfxParticleSystem.Create;
  P := PS.Particles[0];
  E := PS.Effects[0];
  Writeln(Integer(P), Integer(E));
  PS.Free;
end.
