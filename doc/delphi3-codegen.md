# Delphi 3.02 source forms and generated code

| To get this output | Write or try this source form |
|---|---|
| `setl al; test al,al` instead of a direct conditional jump | Store the comparison in a Boolean local before testing it. |
| Reversed `cmp` operands and the opposite signed jump | Change `A < B` to `B > A`; the compiler does not canonicalize them. |
| Different saved registers without changing the computation | Reorder local declarations, or split an expression through a local. |
| A spill after four values surviving a call | Keep five Integer locals live; `ebp` is the fourth register when no frame is needed. Live Self consumes one of these registers. |
| A different object-address register | Try `with P do` versus repeated `P.Field`; a redundant cast of Self also changes allocation under `O+`. |
| Sorted case dispatch but differently ordered branch bodies | Reorder the case arms. Bodies stay in source order, including jump-table cases. |
| An indirect case jump | Five separate dense Integer labels suffice in the tested family; four do not. Sparse labels can add a byte index table or select a comparison tree. |
| Unsigned comparison with a literal | Type both operands: `Cardinal(A) < Cardinal(90)` gives `jae` on the false path; `Cardinal(A) < 90` gives `jge`. |
| Calls to argument expressions in a particular order | Write explicit assignments in that order. Inline `Join(Step(1),...,Step(4))` calls Step with 4,3,2,1. |
| An otherwise unexplained exception frame | Check for a string local, even an unused one, or a by-value string parameter. |
| EDX, rather than EAX, zeroed for FS registration | Keep a call result in a local used inside try; storing it to Result first can free EAX (K21). Two Integer assignments inside try before their comparison also select EDX in K77's O+ probe. |
| A hidden record-result destination | Check exact size: 1,2,4-byte records return in registers here; packed size 3 uses a buffer (K06). |
| One array string clear versus several scalar clears | Keep allocated strings of the same type together; a distinct `type string` splits cleanup, an unused Integer gap does not (K09). |
| ECX rather than EDX initializing a managed-string slot under O- | Declare an unused `Sender:TObject` parameter on the method (K09, r6_unused_live). |
| An immediate OR rather than loading a set literal | Try `Include(S,bit)` instead of `S:=S+[bit]` (K26). |
| Word set operations instead of generic 32-byte helpers | Type Mask and Empty constants as the same set type as the operand (K26). |
| A full pointer load without string conversion or uniqueness | Use `Pointer(S)`; PChar and @S[1] can call LStrToPChar or UniqueString depending on storage/constness (K12). |
| MOV 1 plus LEA for a string's first-character Move operand | Try statement-scoped `{$R+}` around Move; the const-source probe also removes LStrToPChar, without a bounds-check call (K12, r6_move). |
| LoadResString, a literal pointer, or a pointer-cell load | Distinguish resourcestring, untyped string const, and typed string const (K13). |
| `cmp al,1` instead of a nonzero test | Write `B=True`; it differs from `if B` for noncanonical Boolean bytes (K27). |
| A method-pointer high-word test | `Assigned(E)` tests Code high word; `TMethod(E).Code<>nil` tests the whole pointer (K14). |
| A different dynamic-call BX selector | Restore dynamic method declaration order; swapping A/B changes $FFFF to $FFFE (K15). |
| No extra save in a forwarding override | Return the inherited function value explicitly: `Result:=inherited Work(...)` (K16). |
| REP MOVSD instead of a runtime Move call | Use typed record assignment for these 16/32-byte copies (K08). |
| An extra class check before a field/getter | `as` emits AsClass; a hard class cast does not (K33). |
| No duplicate AL reload after pure asm | Use a private Byte local if the asm already loads AL, rather than naming Result (K23). |
| Different integer complement instructions | `xor $FFFFFFFF` emits XOR; `not` emits NOT (K24). |
| No intermediate copy before shifting a retained priority value | Try `(Yhp+33) shl 13` instead of `(Yhp+33)*$2000`; the copy removal is O+ in this probe (K24, r6_shift_live). |
| Correct enum sizes in the probe | Use CLI `-$Z-` or source `{$Z1}`; the numeric CLI `-$Z1` is not equivalent (K31). |
| Direct raw-list loads rather than TList.Get | Use the backing List pointer only when the original did; it also removes checked getter behavior (K32). |
| Different floating constant loads | Declare Scale as Single, Double or Extended to select dword, qword or xword loads; changing only the number can leave the instructions identical (K25). |
| Sender copied after a nil guard or after FS registration | Assign it to a local at that source position; the parameter can be preserved in the prologue (K39). |
| Another narrow-field read after a comparison | Use `ShortInt(PChar(Object)[offset])` for a signed byte or `Boolean(PChar(Self)[offset])` for a Boolean; typed fields can reuse the first read (K40). |
| Different reuse inside a short-circuit condition | Try nested `if` statements; b03's same-code result does not cover every shared-field expression (K41). |
| A const-record field reloaded instead of retained | Rebase through its first field, e.g. `PSurfaceDesc(@SD.Width)^` (K42). |
| An index loaded earlier, without a shift instruction | Write `Index shl 0` (K43). |
| Changed argument/receiver load order without conversion | Try a class cast through `Pointer` at the argument's member expression (K44). |
| Different reuse of a global pointer cell | Try `TWindow(Pointer(@Window)^)`; qualification alone did not do this (K45, NR02). |
| A receiver retained across a getter in an equality | Put its field expression on the left; check receiver stability across the call (K46). |
| A byte load instead of SHR plus AND | Use `WordRec(LongRec(Flags).Hi).Lo` for bits 16..23 of a memory field (K47). |
| Packed locals occupying eight-byte slots | Overlay each with `array[0..1] of Integer` in an untagged variant record (K49). |
| No Self copy before FS setup, with EDX zeroed | Assign a pointer-returning call to a Pointer local before casting (K50). |
| A parameter or local spilled although its address is never consumed | Take its address into a local; this also works for Boolean flags and loop indexes (K51, K61). |
| LEA for a list index plus a constant | Name the search index and remove an unnecessary lookup-result cast (K52). |
| A callback destination retained in EBX | Try explicit callback field assignments instead of a destination `with` (K55). |
| Different saved registers, or byte rather than word set tests, without an extra copy | Retain `X:=X`; the assignment can disappear after affecting allocation (K57). |
| Self/Sender exchanged between EBX and ESI | Try `Sender:=TObject(Pointer(Sender))` before the existing body (K58). |
| A different lifetime for a consumed parameter or replaced object | Reuse the consumed parameter, or split old/new object generations into separate locals (K59/K60). |
| A frame and forced stack slots without a consuming address call | Add local `absolute` views; their declaration order can select slot order (K67/K68). |
| `mov al,[Level]; mov ecx,eax` before a constructor | Assign the enum cast to an enum local before construction (K27 refinement). |
| Stop retained in EAX and the elapsed time in EDX | Repeat `Stop-Start` rather than assigning it to Time (K64). |
| No store/reload of an addressable source before Move | Put the computed address in a separate short-lived Pointer local (K66). |
| ECX rather than EAX scratch loads while pushing stdcall arguments | Assign the call to Result before comparing it (K70). |
| One string-array clear instead of two scalar clears | Inline the plugin-name and exception-message expressions; check their resulting slot adjacency (K71). |
| A separate byte load before ADD instead of a memory ADD | Try `Byte(Key+0)` in the byte sum; `Byte(Key)` alone is unchanged in the control (K72). |
| A quotient kept in EAX rather than copied to a saved register | Name `Q:=I div 5` and reuse Q in the guard and index (K73). |
| `sete al; mov ebx,eax` instead of `sete bl` | Name the first byte-returning call before comparing it with the second (K74). |
| No incoming DL spill/reload around an enum-returning call | Assign the enum result to an enum local before testing set membership (K75, O+). |
| Recomputed coordinate sums instead of shared sums | Try a hard class cast at each Sender field read in the multi-argument expression (K76, O+). |

## Setup and how to reproduce

Experiments run on 2026-10-23 with `C:\Tools\Delphi3\BIN\DCC32.EXE`, SHA256
`2EEFE2C33C88E0BD466000C57F6B198088343D8E37DBA5042F0C3F2F824E8CEF`.
The compiler identifies itself as Delphi for Win32 Version 10.0. Nothing was executed.

The baseline from the switch sweep in [match.md](match.md) is
`O+ W- B- G+ A+ R- Q- Z1` (Z1 denotes the intended source enum size).
The probe now uses command-line `-$Z-` for that size: numeric CLI `-$Z1`
miscompiles enums in this compiler; see K31. The first-round measurements
predate that correction; all second-round probes use it except the explicit
failing-flag control. Every pair was also compiled with `O-`.
The increment, Byte-assignment and Word-for tests additionally used `O- Q+`
(Adcpack) and `O- Q+ R+` (aowDPlayComp). `L+` keeps map symbols available;
`-B -GD` rebuilds with a detailed map. A package requiring `vcl30` retains all
interface routines without calling them. This is the game-package compilation setting.

There are 135 source pairs and 278 pair/switch configurations. Inputs, copied
units, compiler logs, packages, maps and `results.json` remain under
`D:\Build\tmp\cx_cg1`. Input names are `inputs\<id>_a.pas` and `_b.pas`;
output directories are `<id>_<mode>_a` and `_b`, where mode is `opt`, `noopt`,
`overflow` or `checked`. The IDs below identify these files. This study's
scratch generator was deleted; test inputs and results were retained. No game
files were copied and the game was not run.

`tools/dcc_probe.py` accepts a file containing `interface ... implementation ... end.`
or a complete unit. It copies the unit into the named output directory and builds
`ProbeHost.dpl`, `ProbeHost.map` and a compiler log there. Compiler TMP/TEMP
also point there. Keep the input outside
that generated directory. Include directives resolve relative to the input directory.

```powershell
python -B tools/dcc_probe.py D:\Build\tmp\cx_cg1\inputs\b06_bool_local_b.pas `
  --out D:\Build\tmp\cx_cg1\reprobe -- TProbe.Run
python -B tools/dcc_probe.py D:\Build\tmp\cx_cg1\inputs\k09_nested_b.pas `
  --out D:\Build\tmp\cx_cg1\reprobe_noopt --switch O- -- Run 'Inner<Run'
```

The probe reuses `match.Image`, map resolution and `match.decode_stream`, plus
the shared flow traversal to omit unreachable padding and literal bytes. It
keeps local branch offsets, call identities, finally continuations and `.table`
entries. `.table` entries are hexadecimal offsets from the routine start.
It does not print literal-pool or byte-index contents; those were read from the
package bytes for the examples below. Reusing an output directory replaces its
generated files. Compiler errors and missing routine names produce a failing exit code.

Evidence below uses Intel syntax, hexadecimal offsets, and elides unchanged lines.
`+xx` means an offset within the routine, not an arbitrary masked address.
**Same code** means the instruction stream and local transfers agree after
relocation, excluding alignment. Calls were compared by identity, not merely
masked as TARGET. **Different** applies to both `O+` and `O-` unless stated;
excerpts are `O+` unless marked. These are observed settings, not universal
register-allocation promises. Label, width, live-count and side-effect-order
probes intentionally change more than observable spelling: they establish code
shapes, not permission to change a recovered method's behavior.

These common declarations make the abbreviated bodies below complete:

```pascal
var Global: Integer;
function Step(X: Integer): Integer;
function Join(A,B,C,D: Integer): Integer;
procedure Touch(X: Integer);
{ implementation }
function Step(X: Integer): Integer;
begin Global:=Global+X; Result:=Global end;
function Join(A,B,C,D: Integer): Integer;
begin Result:=A+B+C+D end;
procedure Touch(X: Integer);
begin Global:=Global xor X end;
```

Plain functions are `function Run(A,B: Integer): Integer` unless specified.
Method bodies use the same helpers and this class, with the indicated Run parameters:

```pascal
type TProbe = class
  F,G: Integer;
  P: TProbe;
  function Run(A,B: Integer): Integer;
end;
```

Thus Self arrives in eax, A in edx and B in ecx; F, G and P are at offsets 4, 8
and `$C`. Plain Run receives A in eax and B in edx. Touch changes only Global,
but the caller must assume a call can invalidate a field read.

The earlier worker-report audit is in section 10, with inputs and output under
`D:\Build\tmp\cx_cg2`. Section 11 audits nine fourth-round rewrite reports
under `D:\Build\tmp\cx_cg3`; section 12 audits the latest five, rx1..rx5,
under `D:\Build\tmp\cx_cg4`. Earlier round counts above and below remain
historical counts for their respective directories.

The four forms in `D:\Build\tmp\cx_cg5\forms.txt` were audited on
2026-10-24. The receiver zero shift is already covered by K43. Three new
refinements are recorded under K09, K12 and K24 below, with motivating
functions and paired snippets. Their inputs are
`D:\Build\tmp\cx_cg5\inputs\r6_<name>.pas`; output directories are
`cx_cg5\r6_<name>_opt` and `_noopt`, with full disassembly in sibling
`.txt` files. Each input contains both forms, compiled together with
`python -B tools/dcc_probe.py <input> --out <directory> -- <routines>`;
`_noopt` additionally uses `--switch O-` before `--`. Other switches are
the setup defaults. Nothing was executed. Simpler controls and their
disassemblies are retained in the same directory; the earlier round counts
remain historical.

## 1. Branches

**b01_invert: different.** Method bodies:

```pascal
{ A } if A<F then Result:=A+G else Result:=B+G;
{ B } if not (A<F) then Result:=B+G else Result:=A+G;
```

The then arm falls through in both; inverting the source swaps physical bodies.
`O-` also reverses the jump and body order, using stack-backed parameters.

```text
A: cmp edx,[eax+4]; jge +0b    B: cmp edx,[eax+4]; jl +0b
   add edx,[eax+8]               add ecx,[eax+8]
   mov eax,edx; ret              mov eax,ecx; ret
```

**b02_exit: same code, both modes.** Method bodies:

```pascal
{ A } if A<F then begin Result:=Step(A); Exit end; Result:=Step(B)+G;
{ B } if A<F then Result:=Step(A) else Result:=Step(B)+G;
```

Both have `cmp edx,[ebx+4]; jge +15; mov eax,edx; call Step;
pop esi; pop ebx; ret`, followed at `+15` by the B call and G addition.
Exit does not force a jump to one shared epilogue here.

**b03_nested_and: same code, both modes with B-.**

```pascal
{ A } Result:=0; if A<F then if B<G then Result:=Step(A);
{ B } Result:=0; if (A<F) and (B<G) then Result:=Step(A);
```

Both: `xor esi,esi; cmp edx,[eax+4]; jge +16; cmp ecx,[eax+8];
jge +16; mov eax,edx; call Step; mov esi,eax`.
**b08_full_boolean** repeats this exact pair under `{$B+}`: **different**.
The nested form remains short circuit; the and form becomes
`cmp edx,[esi+4]; setl al; cmp ecx,[esi+8]; setl cl; and al,cl; je +1f`.

**b04_and_order: different.**

```pascal
{ A } if (A<F) and (Step(B)>G) then Result:=1 else Result:=2;
{ B } if (Step(B)>G) and (A<F) then Result:=1 else Result:=2;
```

A: `cmp esi,[ebx+4]; jge +21; mov eax,edi; call Step; cmp eax,[ebx+8]`.
B: `mov eax,edi; call Step; cmp eax,[ebx+8]; jle +21; cmp esi,[ebx+4]`.
Self/A/B are ebx/esi/edi in both. B always calls Step; A can skip it.

**b05_or_order: different.** With the same `then Result:=1 else Result:=2`,
`(A<F) or (B<G)` starts `cmp edx,[eax+4]; jl +0a; cmp ecx,[eax+8]; jge +10`;
`(B<G) or (A<F)` starts `cmp ecx,[eax+8]; jl +0a; cmp edx,[eax+4]; jge +10`.
Operand order remains visible even without calls.

**b06_bool_local: different.**

```pascal
{ A } if A<F then Result:=Step(A) else Result:=Step(B);
{ B, var C: Boolean; } C:=A<F; if C then Result:=Step(A) else Result:=Step(B);
```

A: `cmp edx,[eax+4]; jge +0d`. B: `cmp edx,[eax+4]; setl al;
test al,al; je +12`. Under `O-`, B writes C with `setl byte ptr [ebp-$11]`
and tests it with `cmp byte ptr [ebp-$11],0`. The condition is materialized.

**b07_compare_swap: different.**
`if A<B then Result:=Step(A) else Result:=Step(B)` gives
`cmp edx,eax; jle +0a`; replacing only `A<B` with `B>A` gives
`cmp eax,edx; jge +0a`. The bodies and calls remain in the same order.

## 2. Case

For this section, `Run(A: Integer)` returns Integer. Label i's body returns
`11+i` (decimal); else returns 99. Each label is a separate arm unless grouped
explicitly. A range is one arm, not several independent bodies.

**c01_arm_order: different.** `case A of 1:Result:=11; 2:Result:=12;
3:Result:=13; else Result:=99 end` versus arm order 3,1,2.
Both dispatch in ascending numeric order with three `dec eax` operations.
A has `je +0b; ... je +11; ... je +17` and bodies 11,12,13;
B has `je +0f; ... je +15; ... jne +1b` and bodies 13,11,12.
The final test can fall through into the first source arm.

**c02_dense_order: different.** Eight arms 0,1,2,3,4,5,6,7 versus
7,0,6,1,5,2,4,3, with the same label-to-result association:

```text
both: cmp eax,7; ja +5c; jmp dword ptr [eax*4 + table]
A table at +0c: 2c 32 38 3e 44 4a 50 56
B table at +0c: 32 3e 4a 56 50 44 38 2c
A first body +2c: mov eax,0b; ret
B first body +2c: mov eax,12; ret
```

**cs02_count..cs16_count: different for every pair.** Compare n independent
arms labeled `0..n-1` against the same bodies labeled `10..n+9`.

| n tested | Dispatch in both source forms, both modes | Representative differing lines |
|---|---|---|
| 2,3,4 | Comparison chain | A starts `sub eax,1; jb arm0; je arm1`; B starts `sub eax,0a; je arm0`, then decrements. |
| 5,6,7,8,9,12,16 | Jump table | A starts `cmp eax,n-1`; B prefixes `add eax,-0a`, then `cmp eax,n-1`. |

At n=5, A has `cmp eax,4; ja +3e; jmp [eax*4 + +0c]`, table
`20 26 2c 32 38`. B has `add eax,-0a; cmp eax,4; ja +41;
jmp [eax*4 + +0f]`, table `23 29 2f 35 3b`. The selector is rebased to
zero before indexing; the table base denotes index zero, not the original low label.

**c03_dense_sparse, ct02_density..ct32_density, cu05_density..cu07_density:
different for every pair.** Compare eight arms 0..7 with arms `0,s,2*s,...,7*s`.
Their bodies remain 11..18.

| s | Sparse dispatch, both modes | Evidence |
|---|---|---|
| 2,3,4,5 | Byte index followed by address table | s=3: `cmp eax,15; ja +7c; mov al,[eax + +12]; jmp [eax*4 + +28]`. |
| 6,7,8,16,32 | Comparison tree/chain, no table | The dense partner retains `cmp eax,7; ja else; jmp [eax*4+table]`. |

For s=3, bytes at +12 are `01 00 00 02 00 00 03 00 00 04 00 00 05 00 00
06 00 00 07 00 00 08`. Missing labels map to byte index 0; labels 0,3,...,21
map to indices 1..8. Dwords at +28 point to offsets
`7c 4c 52 58 5e 64 6a 70 76`: else first, then the eight source bodies.
Only al is replaced because the bounds check leaves the selector below 256 here.

**cv030_span..cv256_span: different for every pair.** Compare dense 0..7 against
the eight labels `0,1,2,3,4,5,6,E`. E was 30,31,32,33,34,35,36,37,38,39,40,48,
64,255,256. Both modes use a compressed table through E=38, a comparison tree
from E=39. At E=38: `cmp eax,26; ja +91; mov al,[eax + +16];
jmp [eax*4 + +3d]`. At E=39: `cmp eax,4; jg +16; je +3d;
sub eax,1; jb +25; je +2b`. This threshold is measured for eight distinct
bodies and this layout; it is not a general density formula.

**c04_ranges: same code, both modes.** Arms `1..3:Result:=11; 4..6:Result:=12`
versus `1,2,3:Result:=11; 4,5,6:Result:=12`, same else.
Both: `dec eax; sub eax,3; jb +0d; sub eax,3; jb +13; jmp +19`.
Adjacent labels sharing one body coalesce into ranges.

**c05_else: different.** `Result:=99; case A of 1:Result:=11;
2:Result:=12 end` versus the same case with `else Result:=99` and no initial
assignment. A starts `mov edx,63; dec eax; je +0d`, keeps Result in edx and
ends by moving it to eax. B starts `dec eax; je +08`, with each arm writing
eax and returning; its else is `mov eax,63; ret`.

**c06_word and c08_dense_word: different.** Change only the selector parameter
from Integer to Word. Three arms 1,2,3 replace `dec eax` with `dec ax`.
Eight arms 0..7 still get a jump table: the Word version prefixes
`movzx eax,ax; cmp eax,7; ja +5f; jmp [eax*4 + +0f]`, with table
`2f 35 3b 41 47 4d 53 59`. A Word selector does not force a decrement chain.

**c07_single_range: different.** `case A of 0..89:Result:=11 else Result:=99 end`
starts `sub eax,5a; jae +0b`. `if Cardinal(A)<90 then Result:=11 else Result:=99`
starts `cmp eax,5a; jge +0b`. These are not equivalent for negative A in this
compiler; the typed-literal control in section 5 isolates the signedness issue.

## 3. Locals and copies

**l01_field: different.** Method bodies:

```pascal
{ A } Result:=F; Touch(A); Result:=Result+F;
{ B, var T: Integer; } T:=F; Result:=T; Touch(A); Result:=Result+T;
```

A keeps Self in ebx and Result in esi: `mov esi,[ebx+4]; call Touch;
add esi,[ebx+4]`. B keeps T in ebx and Result in esi:
`mov ebx,[eax+4]; mov esi,ebx; call Touch; add esi,ebx`.
`O-` similarly replaces the second field load with the T slot.
Caching a field across a call also changes semantics if that call changes the field.

**l02_parameter: different.** `Touch(A); Result:=A+B` versus
`T:=A; Touch(A); Result:=T+B`, with local T:Integer only in B.
Both save B in esi and A/T in ebx, but A emits `mov ebx,eax; mov eax,ebx;
call Touch`, while B emits `mov ebx,eax; call Touch`. Even a removed copy
can remove a seemingly redundant argument reload. `O-` adds a real T slot/copy.

**l03_copy: same code O+, different O-.** Both declare `X,T: Integer`.
`X:=Step(A); Touch(B); Result:=X+1` versus
`T:=Step(A); X:=T; Touch(B); Result:=X+1`.
Both optimized forms have `call Step; mov ebx,eax; ... call Touch;
lea eax,[ebx+1]`. Unoptimized A stores Step's result to `[ebp-$10]`;
B stores to `[ebp-$14]`, then `mov eax,[ebp-$14]; mov [ebp-$10],eax`.

**l04_decl_order: different.** Same body, declarations `X,Y,Z: Integer`
versus `Z,Y,X: Integer`:

```pascal
X:=Step(A); Y:=Step(B); Z:=Step(X); Touch(Y); Result:=X+Y+Z;
```

O+ A maps X/Y/Z to ebx/esi/edi, B to esi/ebx/edi:
`call Step; mov ebx,eax` versus `call Step; mov esi,eax` for X;
`mov eax,esi; call Touch` versus `mov eax,ebx; call Touch` for Y.
O- A maps X/Y/Z to `[ebp-$10/-$14/-$18]`, B to `[-$18/-$14/-$10]`.
Declaration order influences allocation; it is not a fixed register numbering rule.

**l05_unused: same code O+, different O-.** Add unused `Unused: Integer` to
`Result:=Step(A)+B`. O+ retains identical code. O- changes only allocation
`add esp,-0c` to `add esp,-10`; parameter and Result slots do not move.
See section 8 for the quite different unused-string result.

**l06_width: different.** `X:=Byte(A); Touch(B); Result:=X+1`, changing only
X's declaration from Byte to Integer. Byte keeps the low byte in bl, then
`xor eax,eax; mov al,bl; inc eax` after Touch. Integer normalizes before Touch
with `xor ebx,ebx; mov bl,al`, then finishes with `lea eax,[ebx+1]`.
Under O-, X is byte `[ebp-$0d]` versus dword `[ebp-$10]`.

**ls1_live..ls6_live: different for every pair.** Declare n versus n+1 Integer
locals; body `L1:=A+1; ...; Ln:=A+n; Touch(B); Result:=L1+...+Ln`.
All locals remain live through Touch; A and B do not.

| Live locals | O+ locations | Added instruction evidence relative to the previous count |
|---|---|---|
| 1 | L1=ebx | `lea ebx,[eax+1]` |
| 2 | plus L2=esi | `push esi; ... lea esi,[eax+2]` |
| 3 | plus L3=edi | `push edi; ... lea edi,[eax+3]` |
| 4 | plus L4=ebp | `push ebp; ... lea ebp,[eax+4]` (no EBP frame) |
| 5 | plus L5=[esp] | `push ecx; ... add eax,5; mov [esp],eax` |
| 6 | plus L6=[esp+4] | `add esp,-8; ... mov [esp+4],eax` |
| 7 | plus L7=[esp+8] | `add esp,-0c; ... mov [esp+8],eax` |

Under O-, A/B/Result are `[ebp-4/-8/-$0c]`, and L1..Ln occupy
`[ebp-$10], [ebp-$14], ...`; each extra local grows the frame by four.
**l08_live_self** repeats the pressure test in a method: `L1:=F; L2:=A+2;
L3:=A+3; Touch(B); Result:=L1+L2+L3+G`, versus adding L4:=A+4 and including
L4 in the sum. Self=ebx, L1=esi, L2=edi, L3=ebp; L4 spills:
`push ecx; ... add edx,4; mov [esp],edx; ... add eax,[esp]`.

**l07_mixed_order: different.** Same body:
`B1:=Byte(A); W1:=Word(B); I:=Step(A); Touch(I); Result:=B1+W1+I`.
Declare `B1:Byte; W1:Word; I:Integer` versus `I:Integer; W1:Word; B1:Byte`.
O+ maps B1/W1/I to bl/di/esi versus bl/si/edi, e.g. `movzx edx,di`
versus `movzx edx,si`. O- uses byte `[ebp-$0d]`, word `[ebp-$10]`, dword
`[ebp-$14]` versus byte `[-$13]`, word `[-$12]`, dword `[-$10]`.
Small locals do not universally consume separate four-byte slots; padding and
alignment still affect where the next one lands.

## 4. Expressions

**e01_with: different.** Method `Result:=P.F+P.G; Touch(Result)` versus
`with P do Result:=F+G; Touch(Result)`.
Repeated expressions use `mov edx,[eax+0c]; mov ebx,[edx+4]; add ebx,[edx+8]`.
With uses `mov eax,[eax+0c]; mov ebx,[eax+4]; add ebx,[eax+8]`.
Both evaluate P only once here; with changes the address register, not the load count.
O- gives the with object a hidden saved address rather than repeating the access.

**e02_self_param: different.** `Run(O:TProbe)` uses `Result:=Self.F+Self.G`
versus `Result:=O.F+O.G`, assuming O=Self at the caller.
Self: `mov edx,[eax+4]; add edx,[eax+8]; mov eax,edx; ret`.
O: `mov eax,[edx+4]; add eax,[edx+8]; ret`. The compiler cannot infer the
caller's alias. O- loads the corresponding Self/O stack pointer instead.

**e03_split: different.** Both declare T:Integer.
`Result:=Step(A)+Step(B)` versus `T:=Step(A); Result:=T+Step(B)`.
Both call Step(A) before Step(B). A saves A in ebx, reloads it for the first call,
and ends `add ebx,eax; mov eax,ebx`. B calls Step immediately with incoming eax
and ends `add eax,ebx`. O- materializes T in its declared slot rather than an
expression temporary. A split statement is visible even when call order is unchanged.

**e04_arg_calls: different, including side-effect order.**

```pascal
{ A } Result:=Join(Step(1),Step(2),Step(3),Step(4));
{ B, var X,Y,Z,W: Integer; }
X:=Step(1); Y:=Step(2); Z:=Step(3); W:=Step(4); Result:=Join(X,Y,Z,W);
```

A emits `mov eax,4; call Step; push eax; mov eax,3; call Step; push eax;
mov eax,2; call Step; push eax; mov eax,1; call Step; pop edx; pop ecx;
call Join`. B calls 1,2,3,4 in statement order, keeping X/Y/Z in ebx/esi/edi,
pushing W, then loading ecx/edx/eax from Z/Y/X. O- preserves these respective
call orders but puts B's named locals on the stack. The fourth Join argument
is a stack argument; this example alone does not establish order among several
stack arguments.

**e05_arg_simple: different.** Method `Result:=Join(A,B,F,G)` versus
`X:=A; Y:=B; Z:=F; W:=G; Result:=Join(X,Y,Z,W)` with four Integer locals.
A: `mov ebx,[eax+8]; push ebx; mov eax,[eax+4]; xchg edx,eax;
xchg edx,ecx; call Join`. B: `mov esi,[eax+4]; mov eax,[eax+8]; push eax;
mov eax,edx; mov edx,ecx; mov ecx,esi; call Join`.
The explicit field loads move ahead of argument setup; the copy statements
also influence register choices. O- has four actual local stores.

**e06_inc and e08_inc_field: same code in all four settings.**
`Inc(A); Touch(A); Result:=A+B` versus `A:=A+1; Touch(A); Result:=A+B`;
method `Inc(F); Result:=F` versus `F:=F+1; Result:=F`.
O+ parameter: `inc ebx`; field: `inc dword ptr [eax+4]; mov eax,[eax+4]`.
O- parameter: `inc dword ptr [ebp-4]`.
With O- Q+ (with or without R+), both parameter spellings use
`add dword ptr [ebp-4],1; jno ...; call System.@IntOver`; both field spellings
use `add dword ptr [eax+4],1; jno ...; call System.@IntOver`.
Changing Inc's spelling alone is not a useful variation in these integer cases.

**e07_result_name: same code, both modes.**
`Result:=Step(A); Result:=Result+B` versus `Run:=Step(A); Run:=Result+B`.
Both: `call Step; add eax,esi` in the same saved-register prologue.
The function name is an assignment target here. Reading bare `Run` on the
right in this parameterized function instead fails with "Not enough actual
parameters"; it is not a replacement spelling for every use of Result.

**e10_self_cast: different O+, same code O-.** Method
`Result:=Self.F+Self.G` versus `Result:=TProbe(Self).F+TProbe(Self).G`.
A uses `mov edx,[eax+4]; add edx,[eax+8]; mov eax,edx`.
B prefixes `mov edx,eax`, then `mov ecx,[edx+4]; add ecx,[edx+8]; mov eax,ecx`.
Even a cast to the same class creates a distinct address expression under O+.

**e09_nil_local and e11_nil_noreuse: different.**

```pascal
{ e11 A } if P<>nil then Result:=1 else Result:=0;
{ e11 B, var T:TProbe; } T:=P; if T<>nil then Result:=1 else Result:=0;
{ e09 A } if P<>nil then Result:=P.F else Result:=0;
{ e09 B, var T:TProbe; } T:=P; if T<>nil then Result:=T.F else Result:=0;
```

e11: A uses `cmp dword ptr [eax+0c],0; je ...`; B uses
`mov eax,[eax+0c]; test eax,eax; je ...`.
e09: even A uses `mov edx,[eax+0c]; test edx,edx; je ...; mov eax,[edx+4]`;
B instead uses eax for P and `[eax+4]` for its F.
The following field reuse permits a direct field condition to get mov/test
without either a local or with. O- keeps the local version's pointer in a slot.

## 5. Types

**t01_Boolean/ByteBool/WordBool/LongBool: same code for each pair, both modes.**
For `Run(X:T):Integer`, compare `if X then Result:=1 else Result:=2` with
`if Ord(X)<>0 then Result:=1 else Result:=2`.

| T | O+ test in either spelling | O- memory test in either spelling |
|---|---|---|
| Boolean | `test al,al` | byte parameter slot against zero |
| ByteBool | `test al,al` | byte parameter slot against zero |
| WordBool | `test ax,ax` | word parameter slot against zero |
| LongBool | `test eax,eax` | dword parameter slot against zero |

All tests branch directly to the false arm. Boolean versus ByteBool changes
neither test in this example, but constructing their true values differs.

**t02_*_result: different for each of the same four types.** For
`Run(A:Integer):T`, compare `Result:=A<>0` with `Result:=T(A)`.
Boolean comparison: `test eax,eax; setne al; ret`.
ByteBool, WordBool and LongBool comparison: `test eax,eax; setne al;
neg al; sbb eax,eax; ret` (true becomes all ones in the returned width).
Every cast version is just `ret` under O+; it preserves the incoming bits.
O- stores the computed/cast value at Result's byte, word or dword slot;
the comparison still normalizes and the cast does not.

**t10_bool_local_width and t14_*_local: different.** Same body
`L:=A<>0; Touch(B); if L then Result:=1 else Result:=2`, changing only L
from Boolean to ByteBool, WordBool or LongBool.
Boolean: `setne bl; ... call Touch; test bl,bl`.
Others: `setne al; neg al; sbb ebx,ebx; ... call Touch`, followed respectively
by `test bl,bl`, `test bx,bx`, `test ebx,ebx`.
Under O-, both construction and the sized test target the corresponding local slot.

The following three independent families cover Integer types without changing
the parameter, local and result types together:

* **t09_*_param:** `function Run(X:T):Integer; begin Result:=X end` versus
  the same function with only X's type changed to Integer.
* **t04_*_result:** `function Run(X:T):T; begin Result:=X end` versus
  the same function with only the result type changed to Integer.
* **t03_*:** `Run(X:Integer):Integer`, `L:=T(X); Touch(1); Result:=L`,
  with local L:T versus L:Integer. The cast and parameter stay unchanged.

| T | t09 parameter: A versus Integer B, O+ | t04 result: narrow A versus Integer B, O+ | t03 local: conversion placement, O+ | Result in both modes |
|---|---|---|---|---|
| Byte | `and eax,ff; ret` / `ret` | `ret` / `and eax,ff; ret` | A: after call `xor eax,eax; mov al,bl`; B: before call `xor ebx,ebx; mov bl,al` | Different in all three families |
| ShortInt | `movsx eax,al; ret` / `ret` | `ret` / `movsx eax,al; ret` | A: after call `movsx eax,bl`; B: before call `movsx ebx,al` | Different in all three families |
| Word | `movzx eax,ax; ret` / `ret` | `ret` / `movzx eax,ax; ret` | A: after call `movzx eax,bx`; B: before call `movzx ebx,ax` | Different in all three families |
| SmallInt | `movsx eax,ax; ret` / `ret` | `ret` / `movsx eax,ax; ret` | A: after call `movsx eax,bx`; B: before call `movsx ebx,ax` | Different in all three families |
| Integer | `ret` / `ret` | `ret` / `ret` | Same ebx value survives the call | Same code in all three families |
| Cardinal | `ret` / `ret` | `ret` / `ret` | Same ebx value survives the call | Same code in all three families |

In t03 under O-, the typed Byte local is `[ebp-9]`, Word `[ebp-$0a]`,
Integer `[ebp-$0c]`. For Byte A: `mov al,[ebp-4]; mov [ebp-9],al;
call Touch; xor eax,eax; mov al,[ebp-9]`. B instead zero-extends before
`mov [ebp-$0c],eax`, then reloads the full dword after Touch. Signed variants
use `movsx`; Word uses `movzx`. Narrow results do not promise normalized
upper bits; changing just the return type can therefore add a conversion.

**t05_cast: different.** `Run(A:Integer):Integer`, `Result:=ShortInt(A)`
versus `Result:=Byte(A)`: `movsx eax,al; ret` versus `and eax,ff; ret`.
O- performs the corresponding extension after reading A's low byte.

**t06_signed_compare: different.** `Run(A,B:Integer):Integer` versus the
same parameters typed Cardinal, body `if A<B then Result:=1 else Result:=2`.
Both: `cmp edx,eax`; Integer false path is `jle +0a`, Cardinal is `jbe +0a`.
Moving data between Integer and Cardinal needs no code here; ordering does.

**t13_cardinal_const: different.** `if Cardinal(A)<90 then Result:=1 else
Result:=2` versus `if Cardinal(A)<Cardinal(90) then Result:=1 else Result:=2`.
Both: `cmp eax,5a`; the first uses signed `jge +0b`, the second unsigned
`jae +0b`. O- has the same signed/unsigned distinction after loading A.
Do not infer comparison signedness from a cast on only one operand.

**t12_byte_assign: same code O+, O-, and O- Q+; different O- Q+ R+.**
`Run(X:Integer):Integer`, local L:Byte, `L:=X; Result:=L` versus
`L:=Byte(X); Result:=L`. O+ both: `and eax,ff; ret`.
Checked A inserts `bound eax,qword ptr [+24]` before
`mov byte ptr [ebp-9],al`; the explicit cast B omits bound. The bounds
literal is 0..255. This difference comes from R+, not Q+.

**t07_smallset: different.** `Run(X:Byte):Integer`, test
`X in [0,10,13]` versus `(X=0) or (X=10) or (X=13)` with the same 1/2 arms.
Set: `test al,al; je +0c; sub al,0a; je +0c; sub al,3; jne +12`.
Or: `test al,al; je +0c; cmp al,0a; je +0c; cmp al,0d; jne +12`.
O- likewise distinguishes the subtract chain from independent comparisons.

**t08_set_result and t11_large_set: different.** No-argument Run returns
TBits; body `Result:=[0,2,5]`. Change only the type declaration:

| Set type pair | Return code A | Return code B |
|---|---|---|
| `set of 0..7` / `set of 0..31` | `mov al,byte ptr [+08]; ret` | `mov eax,dword ptr [+08]; ret` |
| `set of 0..31` / `set of 0..63` | Same dword return | `mov edx,[+14]; mov [eax],edx; mov edx,[+18]; mov [eax+4],edx; ret` |

The eight-byte result is written through a hidden destination pointer in eax.
The small constants are stored after the code: the first byte/dword is `$25`.
O- uses sized Result slots for small sets and the destination pointer for the
large set. Literal bytes are data, not the spurious `add [eax],al` a linear
disassembler can print between ret and the constant.

## 6. Loops

Locals I are Integer unless stated. The post-loop value test is an observation
of compiler output, not a language guarantee; DCC warns that I may be undefined.

**o01_for_direction: different.** `Result:=0; for I:=0 to A-1 do
Result:=Result+B` versus `for I:=A-1 downto 0` with the same initialization/body.
I is unused in the body. Up: `dec eax; test eax,eax; jl end; inc eax;
add ecx,edx; dec eax; jne body`. Down: `dec eax; cmp eax,0; jl end;
add ecx,edx; dec eax; cmp eax,-1; jne body`. A variable-bound downto need
not become an increment-to-zero counter. O- maintains the control variable
and bounds in memory rather than these registers.

**o09_constant_direction: different.** With `Result:=0`, compare
`for I:=0 to 7 do Touch(A)` with `for I:=7 downto 0 do Touch(A)`.
Up: `mov ebx,8; ... call Touch; dec ebx; jne body`.
Down: `mov ebx,fffffff8; ... call Touch; inc ebx; jne body`.
This confirms the specific constant-bound observation in match.md.
O- instead stores and updates I, not the optimized unused-index counter.

**o02_for_while: different.**

```pascal
{ A } Result:=0; for I:=0 to A-1 do Result:=Result+I;
{ B } Result:=0; I:=0; while I<A do begin Result:=Result+I; Inc(I) end;
```

A uses a separate iteration count: `dec eax; test eax,eax; jl end; inc eax;
xor edx,edx; add ecx,edx; inc edx; dec eax; jne body`.
B: `xor edx,edx; cmp eax,edx; jle end; add ecx,edx; inc edx;
cmp eax,edx; jg body`. O- the for bound is saved once, while the while test
loads A/I at the test site.

**o03_while_repeat: different.** `Result:=0; I:=A; while I>0 do begin
Result:=Result+B; Dec(I) end` versus `Result:=0; I:=A; repeat
Result:=Result+B; Dec(I) until I<=0`.
While: `test eax,eax; jle end; add ecx,edx; dec eax; test eax,eax; jg body`.
Repeat starts with `add ecx,edx` and only tests at the bottom. Both modes
preserve that entry-test difference. They have different behavior when A<=0.

**o04_after_loop: different.** Add `Result:=Result+I` after the up loop in o01.
Without that use, only the countdown in eax exists. With it, I gets ebx:
`push ebx; ... xor ebx,ebx; add ecx,edx; inc ebx; dec eax; jne body;
add ecx,ebx`. Under O-, I already occupies a stack slot, and the added use
loads it. The zero-iteration path need not initialize I.

**o05_break: different.**

```pascal
{ A } Result:=0; I:=A;
while I>0 do begin if I=B then Break; Result:=Result+I; Dec(I) end;
{ B } Result:=0; I:=A;
while (I>0) and (I<>B) do begin Result:=Result+I; Dec(I) end;
```

A: `test eax,eax; jle end; cmp edx,eax; je end; add ecx,eax;
dec eax; test eax,eax; jg compare_B`.
B: `jmp test; body: add ecx,eax; dec eax; test: test eax,eax;
jle end; cmp edx,eax; jne body`.
Break is a jump out of the body; combining the conditions rotates the loop.
The same placement difference survives O-.

**o06_while_memory: different.** Method
`while A>0 do begin Touch(A); Dec(A) end; Result:=A` versus
`while F>0 do begin Touch(F); Dec(F) end; Result:=F`.
Register A: `test ebx,ebx; jle end; ... call Touch; dec ebx;
test ebx,ebx; jg body`. Field F: `jmp test; body: call Touch;
dec [ebx+4]; test: mov eax,[ebx+4]; test eax,eax; jg body`.
The field value loaded at the bottom also supplies Touch at the next iteration.
O- puts both operands in memory; the optimized register-versus-field distinction
is no longer the criterion for the entry shape.

**o07_for_used: different.** `Result:=0; for I:=0 to A-1 do Touch(B)` versus
the same loop with `Touch(I)`. The first has only ebx's count:
`mov eax,esi; call Touch; dec ebx; jne body`.
The second introduces I=esi initialized to zero:
`mov eax,esi; call Touch; inc esi; dec ebx; jne body`.
Under O-, I exists in either version, but the call argument changes slots.

**o08_word_for: different in all four settings.** `Run(N:Word):Integer`,
`Result:=0; for I:=0 to N-1 do Touch(I)`, changing only I:Word to I:Integer.
Word: `dec ebx; test bx,bx; jb end; inc ebx; ... movzx eax,si;
call Touch; inc esi; dec bx; jne body`.
Integer: `movzx ebx,ax; dec ebx; test ebx,ebx; jl end; inc ebx;
... mov eax,esi; call Touch; inc esi; dec ebx; jne body`.
The apparently useless `test bx,bx; jb` is real compiler output (TEST clears
carry); do not silently replace it when matching. Checked builds additionally
carry overflow/range machinery; inspect the actual N=0 behavior before treating
these differently typed loops as equivalent.

## 7. Calls

**k01_virtual_static: different.** TBase has `function Work(X:Integer):Integer`
with body `Result:=X+1`; TProbe descends from it and Run returns `Work(X)`.
Changing only Work's declaration to `virtual` changes Run from
`call TBase.Work; ret` to `mov ecx,[eax]; call dword ptr [ecx]; ret`.
The first virtual slot here is zero. O- likewise dispatches through the VMT
after loading Self instead of using the direct call.

**k02_inherited: different.** Keep Work virtual; change only Run's call from
`Work(X)` to `inherited Work(X)`. The VMT sequence above becomes
`call TBase.Work; ret`. Inherited names the ancestor implementation even when
the declared method is virtual.

**k03_record_const: different callee, same caller in both modes.**

```pascal
type TRec=record F,G:Integer end;
{ A } function ReadIt(X:TRec):Integer;
{ B } function ReadIt(const X:TRec):Integer;
{ both bodies } begin Result:=X.F+X.G end;
{ caller } var R:TRec;
begin FillChar(R,SizeOf(R),0); Result:=ReadIt(R) end;
```

Both callers pass R's address: `mov eax,esp; call ReadIt`.
Value callee: `push esi; push edi; add esp,-8; mov esi,eax;
lea edi,[esp]; movsd; movsd; mov eax,[esp]; add eax,[esp+4]`.
Const callee: `mov edx,[eax]; add edx,[eax+4]; mov eax,edx; ret`.
The eight-byte value copy belongs to the callee.

**k04_record_var: same code in caller and callee, both modes.** The exact
record example above with `const X:TRec` versus `var X:TRec` has the same
address-passing caller and uncopied reads. Their different source contracts
are not visible in this read-only body.

**k05_scalar_const: same code in both routines, both modes.**
`ReadIt(X:Integer)` versus `ReadIt(const X:Integer)`, body `Result:=X+1`.
Caller initializes local R with FillChar, then calls ReadIt(R).
Both O+ callees: `inc eax; ret`; both callers: `mov eax,[esp]; call ReadIt`.

**k06_scalar_var: different.** Replace value X with `var X:Integer` in that
same scalar example. Callee gains `mov eax,[eax]` before `inc eax`.
Caller changes `mov eax,[esp]` to `mov eax,esp` before `call ReadIt`.
O- similarly changes the argument from the value to its address.

**k07_string_const: different callee, same caller.**
`ReadIt(X:string)` versus `ReadIt(const X:string)`, body `Result:=Length(X)`.
Caller initializes local R:string using FillChar and calls ReadIt(R).
Value callee saves X at `[ebp-4]`, calls `System.@LStrAddRef`, installs
`fs:[0]`, calls `System.@LStrLen`, and clears `[ebp-4]` through
`System.@LStrClr` in an implicit finally. Const callee is
`call System.@LStrLen; ret`. The caller's own local-string cleanup exists in
both variants. The distinction holds under O- too.

**k10_string_var: different caller and callee.** Change the preceding const
parameter to `var X:string`. Const caller passes `mov eax,[ebp-4]`, var
passes `lea eax,[ebp-4]`. Var callee is `mov eax,[eax]; call System.@LStrLen;
ret`, const callee omits the pointer dereference. Neither adds the value
parameter's AddRef/finally pair. Both modes show this distinction.

**k08_string_temp: different.** `Run(const S:string):Integer` calls
`ReadIt(S)` versus `ReadIt(S+'x')`, where ReadIt also takes const string.
A is `call ReadIt; ret`. B allocates and zeros `[ebp-4]`, installs a finally,
then `lea eax,[ebp-4]; mov ecx,literal_x; mov edx,ebx;
call System.@LStrCat3; mov eax,[ebp-4]; call ReadIt`. Its hidden cleanup calls
`System.@LStrClr`. Const on the callee does not avoid a temporary needed to
evaluate the argument. The frame/temp remain under O-.

**k09_nested: different.**

```pascal
function Run(A:Integer):Integer;
var X:Integer;
procedure Inner;
begin { A: } Touch(1); { B instead: Inc(X); Touch(1); } end;
begin X:=A; Inner; Result:=X end;
```

Without capture, outer Run keeps X in ebx and just `call Inner`;
Inner is `mov eax,1; call Touch; ret`.
With capture, outer Run has `push ebp; mov ebp,esp; push ecx;
mov [ebp-4],eax; push ebp; call Inner; pop ecx`.
Inner has its own EBP frame, `mov eax,[ebp+8]; inc dword ptr [eax-4]`:
the extra stack argument is the parent's frame. O- already spills X, but
capture still adds the static-link argument/access.
The map gives both nested routines the bare name Inner; use `Inner<Run`.

## 8. Exceptions

**x01_try_start: different.** Method bodies:

```pascal
{ A } Touch(A); try Result:=F finally Touch(B) end;
{ B } try Touch(A); Result:=F finally Touch(B) end;
```

A: `mov eax,edx; call Touch; xor eax,eax; push ebp; push handler;
push fs:[eax]; mov fs:[eax],esp`.
B: `xor eax,eax; push ebp; push handler; push fs:[eax]; mov fs:[eax],esp;
mov eax,edx; call Touch`.
Self remains ebx, B is `[ebp-4]`, Result `[ebp-8]` in both.
The first call's protection changes, not merely a jump offset. The same
registration-order difference is present under O-.

**x04_unused_managed: different.** Plain function body
`try Result:=Step(A) finally Touch(B) end`, with no local versus adding
`var S:string` that is never referenced.
A has one `fs:[0]` registration and one `jmp System.@HandleFinally`.
B has two: `xor edx,edx; push ebp; push +58; push fs:[edx];
mov fs:[edx],esp`, then another at +17 with handler +43.
The outer cleanup is empty (`push +5f; ret`), with its own HandleFinally
thunk. There is no S slot and no LStrClr under O+, yet the empty wrapper
remains. O- reserves S as well and also retains the wrapper.

**x06_unused_string_alone: different.** Body `Result:=Step(A)+B`, no locals
versus unused S:string. A has a simple ebx/esi prologue, Step, addition and
return. B adds an EBP frame and `push handler; push fs:[eax];
mov fs:[eax],esp`, an empty cleanup `ret`, and `jmp System.@HandleFinally`.
An explicit try in the source is not needed to trigger this effect.

**x02_managed: different.** Both declare S:string and have
`try Result:=Step(A) finally Touch(B) end`; B prefixes `S:='x'`.
A already has the empty outer frame described above.
B zeroes S at `[ebp-$0c]`, saves A in ebx, calls `System.@LStrLAsg` before
the explicit try, and gives the outer cleanup
`lea eax,[ebp-$0c]; call System.@LStrClr; ret`. Its explicit and implicit
frames are separate. Under O- both variants have a string slot and LStrClr;
B's assignment still distinguishes them.

**x03_finally_local: different.** A declares T:Integer and uses
`T:=A; try Result:=Step(T) finally Touch(B) end`.
B adds S:string, assigns `S:='x'` before that same body, leaving T intact.
A optimizes T into the incoming value and has one frame. B adds the outer
string frame and `[ebp-$0c]` string slot; the inner setup starts
`mov eax,ebx; xor edx,edx; push ebp; push +5a; push fs:[edx]`.
The extra managed lifetime changes the frame and setup registers even though
the explicit finally is identical. O- additionally retains T's own slot.

**x05_managed_implicit: different.** Both declare and assign S:string.
A: `S:='x'; Result:=Step(A)`.
B: `S:='x'; try Result:=Step(A) finally Touch(B) end`.
A has one implicit registration, clears S at `[ebp-4]`, and keeps Result in ebx.
B has two registrations, clears S at `[ebp-$0c]`, and stores Result at
`[ebp-8]` while running the explicit cleanup. B contains two HandleFinally
thunks; A contains one. O- keeps both the extra explicit registration and
its stack-backed result.

## Qualifications to match.md

* The statement that direct `if F<>nil` always yields a memory compare is too
  strong. e09's direct field test gets `mov edx,[eax+$0c]; test edx,edx` when
  the taken branch reuses P. e11 confirms the memory compare when it is not reused.
* A Word case is not always an ascending 16-bit subtract chain. c06 confirms
  that small-case form, but c08's dense eight-label Word case zero-extends the
  selector and uses a jump table.
* The general unused-for-index description needs a bound-shape qualification:
  o09 confirms `7 downto 0` counting from -8 up to zero, while o01's variable
  `A-1 downto 0` decrements and compares against -1. The specific constant-loop
  observation in match.md is correct.

The tests confirm the documented O- stack locals, source-order case bodies,
Q+ increment checks, record-by-value copies and constant-loop examples.
They do not test the claim about class declaration counts affecting otherwise
identical methods. These probes compare compiled forms with each other; a
rewrite of a game method still needs the original's call/data identities and
control flow checked with `tools/addrcheck.py` (see [match.md](match.md), "What a match proves").

## 9. Leftover-driven source forms (second round)

The source comments beside unmatched functions, all 556 rows of `data/equiv-review/*.tsv`, and the matching notes were surveyed. Repeated register permutations, ordinary spill counts, basic widths and branch inversions already have first-round entries. The remaining mechanisms are grouped into the **38 kinds** below, with the motivating function or note named for each. A kind is an experimental source mechanism, not a claim that its original leftover has now been matched.

**143 additional pairs, 287 pair/switch configurations**: every pair has O+ and O- results, and the overflow guard also has O- Q+ R+. Four extra enum flag controls isolate the probe bug. All paired builds were repeated with the corrected probe. Sixteen representative first-round configurations were also rebuilt and remained unchanged (regression_checks.json). The deliberately broken numeric-CLI enum control is the stated exception. No game was run.

Complete inputs and results are under `D:\Build\tmp\cx_cg1\round2`: `inputs\<id>_a.pas` / `_b.pas`, output `<id>_<mode>_a` / `_b`, and `round2_results.json`. `review_inventory.json` retains the review rows and `pair_sources.json` the tested source pairs. Temporary Python drivers were deleted; the probe remains the only repository tool.

For example:

```powershell
python -B tools/dcc_probe.py D:\Build\tmp\cx_cg1\round2\inputs\r2_try_carrier_a.pas `
  --out D:\Build\tmp\cx_cg1\round2\reprobe -- Run
```

The source fragments below show the changed declarations/statements and, where needed, the shared body. Complete units are retained in the named input files. O+/O- outcomes refer to the **named routines**: assembler-callee controls intentionally compare the caller, and unit-lifetime controls name init/fini as well as Run. Excerpts retain instruction offsets; omitted instructions are not permission to drop calls or cleanup. Same-code results were compared across the full printed streams. These probes test generation, not runtime equivalence; some controls intentionally change contracts, call counts, undefined paths or side-effect order.

This round uses `uses SysUtils,Classes`, G:Integer, `Tick(X)` implemented as `G:=G+X; Result:=G`, and `Sink(X)` as `G:=G xor X`. Default Run is `function Run(A,B:Integer):Integer`. Method probes share:

```pascal
type TObj=class
  F,H:Integer; P:TObj;
  function Get(X:Integer):Integer; virtual;
  procedure Put(X,Y:Integer); virtual;
  function Run(A,B:Integer):Integer;
end;
var Obj:TObj;
{ Get returns F+X; Put assigns F:=X+Y; Fetch returns Obj. }
```

Thus F/H/P are at offsets 4/8/$0C. Sources called TTarget or TT declare separate tiny classes in their input files. TR/TS/TE shapes are stated in each kind or source fragment. PInteger is explicitly declared as ^Integer because this Delphi installation does not provide that name. Call-scheduling probes that leave Result unset are evidence for those call sites, not examples of defined return values.

Review-only artifacts were kept separate: color immediates mistaken for image addresses, relocated assembly continuations, a wrong bare Register symbol, and truncated case-table displays do not identify a new compiler source form. Their instruction/data identity must be checked rather than perturbed until a masked comparison happens to match.

### K01. Field tracking, bounds and repeated subscripts

Reason: [match.md](match.md), field-store and FLists observations; [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TProductionControl.GetProduceUnitLevelMax.

A store can leave its value available for the following comparison; an intervening call forces a reload. Moving a field load across a guard reverses the observed comparison operands here. Conversely, naming the repeated `A and $FF` subscript did **not** change optimized code in this two-call example. A local is an experiment, not a guaranteed way to defeat reuse.

**r2_store_track: O+: different; O-: different.**

A: `begin F:=A; if F<H then Result:=F else Result:=H; end;`
B: `begin F:=A; Sink(B); if F<H then Result:=F else Result:=H; end;`

O+: A `TObj.Run: 0000: mov ecx, edx; 0002: mov dword ptr [eax + 4], ecx; ...; 000f: mov eax, edx; 0011: ret`; B `TObj.Run: 0000: push ebx; 0001: mov ebx, eax; ...; 0017: mov eax, edx; 0019: pop ebx`.
O-: A `TObj.Run: 0006: mov dword ptr [ebp - 0x10], ecx; ...; 003a: mov eax, dword ptr [ebp - 0xc]`; B `TObj.Run: 0006: mov dword ptr [ebp - 0xc], ecx; ...; 0042: mov eax, dword ptr [ebp - 0x10]`.
Context: A call invalidates the tracked field value.

**r2_bound_reuse: O+: different; O-: different.**

A: `begin if A>F then begin T:=F; for I:=T to A do Sink(I) end; Result:=F; end;`
B: `begin T:=F; if A>T then begin for I:=T to A do Sink(I) end; Result:=F; end;`

O+: A `TObj.Run: 0008: cmp edx, eax; 000a: jle +0x20`; B `TObj.Run: 0008: cmp eax, edx; 000a: jge +0x20`.
O-: A `TObj.Run: 0015: cmp eax, dword ptr [ebp - 8]; ...; 001d: mov eax, dword ptr [eax + 4]`; B `TObj.Run: 0018: mov eax, dword ptr [ebp - 8]; ...; 001e: jle +0x41`.

**r2_index_reuse: O+: same code; O-: different.**

A: `begin Items[A and $FF].Put(A,B); Result:=Items[A and $FF].Get(A); end;`
B: `var I:Integer; begin I:=A and $FF; Items[I].Put(A,B); Result:=Items[I].Get(A); end;`

O+: Both `Run: 0006: and esi, 0xff 000c: mov eax, dword ptr [esi*4 + image+0x3024] 0013: mov ecx, edx 0015: mov edx, ebx`.
O-: A `Run: 0003: add esp, -0xc; ...; 0029: and eax, 0xff`; B `Run: 0003: add esp, -0x10; ...; 002c: mov eax, dword ptr [ebp - 0x10]`.

### K02. Global cell addresses, pointer contents and aliasing

Reason: [AoWWinMan.pas](../src/delphi3/AoW/AoWWinMan.pas), TGeneral.SaveLayout; [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TPBEMPlayerControl.ValidateLoadedMap; [AoW review](../data/equiv-review/AoW.exe.tsv), TVideoDialog.ApplyMode.

`T:=Obj` saves the current object across Sink. `Q:=@Obj` saves the address of the global cell but still reloads Q^ after Sink. Both can produce an extra saved register, but only the former freezes the receiver. The alias control stores through P and Q: replacing a final P^ load with A is wrong when P=Q. Do not classify a global or alias reload as redundant merely because the addresses look similar.

**r2_global_value: O+: different; O-: different.**

A: `begin Result:=Obj.F; Sink(A); Result:=Result+Obj.H; end;`
B: `var T:TObj; begin T:=Obj; Result:=T.F; Sink(A); Result:=Result+T.H; end;`

O+: A `TObj.Run: 0001: mov eax, dword ptr [image+0x3024]; 0006: mov ebx, dword ptr [eax + 4]; ...; 0015: add ebx, dword ptr [eax + 8]; 0018: mov eax, ebx`; B `TObj.Run: 0001: push esi; 0002: mov ebx, dword ptr [image+0x3024]; ...; 0015: mov eax, esi; 0017: pop esi`.
O-: A `TObj.Run: 0003: add esp, -0x10; ...; 0022: mov eax, dword ptr [image+0x3024]`; B `TObj.Run: 0003: add esp, -0x14; ...; 0028: mov eax, dword ptr [ebp - 0x10]`.
Context: Caching the pointer can change behavior across a call.

**r2_global_cell: O+: different; O-: different.**

A: `begin Result:=Obj.F; Sink(A); Result:=Result+Obj.H; end;`
B: `var Q:^TObj; begin Q:=@Obj; Result:=Q^.F; Sink(A); Result:=Result+Q^.H; end;`

O+: A `TObj.Run: 0001: mov eax, dword ptr [image+0x3024]; 0006: mov ebx, dword ptr [eax + 4]; ...; 0015: add ebx, dword ptr [eax + 8]; 0018: mov eax, ebx`; B `TObj.Run: 0001: push esi; 0002: mov ebx, image+0x3024; ...; 0018: mov eax, esi; 001a: pop esi`.
O-: A `TObj.Run: 0003: add esp, -0x10; ...; 0022: mov eax, dword ptr [image+0x3024]`; B `TObj.Run: 0003: add esp, -0x14; ...; 002c: mov eax, dword ptr [eax]`.

**r2_alias_reload: O+: different; O-: different.**

A: `begin P^:=A; Q^:=B; Result:=P^; end;`
B: `begin P^:=A; Q^:=B; Result:=A; end;`

O+: A `Run: 0005: mov ecx, dword ptr [ebp + 8]; 0008: mov dword ptr [edx], ecx; 000a: mov eax, dword ptr [eax]`; B `Run: 0005: mov eax, dword ptr [ebp + 8]; 0008: mov dword ptr [edx], eax; 000a: mov eax, ecx`.
O-: A `Run: 0017: mov eax, dword ptr [ebp + 8]; ...; 0022: mov eax, dword ptr [eax]`; B `Run: 0017: mov eax, dword ptr [ebp - 8]; ...; 001f: mov eax, dword ptr [ebp - 0xc]`.
Context: The second form is wrong when P=Q; a retained value is not always equivalent.

### K03. Single-use receivers, use order and result lifetimes

Reason: [AoWSetup.pas](../src/delphi3/AoWEPACK/AoWSetup.pas), TSetupControl.Create; [Spells.PAS](../src/delphi3/AoWEPACK/inc/Spells.PAS), single-use-source and saved-Self comments; [match.md](match.md), search-index/result leftovers.

A single-use `T:=Fetch` was removed completely under O+, including any additional save; it became real storage under O-. Returning the search index keeps it live through Put, and changing I to Result changes the saved-register allocation. A procedure that does not return the index can use eax and omit the function version's ebx save. Parameter use order also changes which incoming value is saved. None of this reproduces every unexplained original Self save.

**r2_single_receiver: O+: same code; O-: different.**

A: `begin Result:=Fetch.Get(A); end;`
B: `var T:TObj; begin T:=Fetch; Result:=T.Get(A); end;`

O+: Both `TObj.Run: 0003: call Fetch 0008: mov edx, ebx 000a: mov ecx, dword ptr [eax] 000c: call dword ptr [ecx]`.
O-: A `TObj.Run: 0003: add esp, -0x10; 0006: mov dword ptr [ebp - 0x10], ecx`; B `TObj.Run: 0003: add esp, -0x14; ...; 001a: mov eax, dword ptr [ebp - 0x10]`.

**r2_result_index: O+: different; O-: different.**

A: `var I:Integer; begin I:=Get(A); if I>=0 then Put(I,B); Result:=I; end;`
B: `begin Result:=Get(A); if Result>=0 then Put(Result,B); end;`

O+: A `TObj.Run: 0005: mov esi, eax; 0007: mov eax, esi; ...; 001b: call dword ptr [esi + 4]; 001e: mov eax, ebx`; B `TObj.Run: 0005: mov ebx, eax; 0007: mov eax, ebx; ...; 0019: mov ebx, dword ptr [eax]; 001b: call dword ptr [ebx + 4]`.
O-: A `TObj.Run: 0003: add esp, -0x14; ...; 0034: mov dword ptr [ebp - 0x10], eax`; B `TObj.Run: 0003: add esp, -0x10; ...; 0026: mov edx, dword ptr [ebp - 0x10]`.

**r2_parameter_uses: O+: different; O-: different.**

A: `begin Sink(A); Result:=B+H; end;`
B: `begin Sink(B); Result:=A+H; end;`

O+: A `TObj.Run: 0002: mov esi, ecx; 0006: mov eax, edx`; B `TObj.Run: 0002: mov esi, edx; 0006: mov eax, ecx`.
O-: A `TObj.Run: 0012: call Sink; 0017: mov eax, dword ptr [ebp - 0xc]`; B `TObj.Run: 000f: mov eax, dword ptr [ebp - 0xc]; 0012: call Sink`.
Context: Use order, not merely declaration order, changes entry saves.

**r2_proc_function: O+: different; O-: different.**

A: `procedure Run(A:Integer); procedure Run(A:Integer); var I:Integer; begin I:=Tick(A); if I>=0 then Sink(I) end;`
B: `function Run(A:Integer):Integer; function Run(A:Integer):Integer; var I:Integer; begin I:=Tick(A); if I>=0 then Sink(I); Result:=I; end;`

O+: A `Run: 0005: test eax, eax`; B `Run: 0000: push ebx; 0006: mov ebx, eax; ...; 0013: mov eax, ebx; 0015: pop ebx`.
O-: A `Run: 0003: add esp, -8; ...; 0023: pop ecx`; B `Run: 0003: add esp, -0xc; ...; 002b: mov esp, ebp`.

### K04. Receiver, field and untyped-argument scheduling

Reason: [ExploreS.pas](../src/delphi3/AoWEPACK/ExploreS.pas), GetTerrainTypeImage; [Structur.PAS](../src/delphi3/AoWEPACK/inc/Structur.PAS), receiver/index comments; [Ilpack review](../data/equiv-review/Ilpack.dpl.tsv), TBitMask.GrabImage.

`with P` captures P before Fetch; the repeated-field form calls Fetch before loading Self.P in this context. An untyped const field argument passes its actual address; copying it first makes a private addressable slot instead. The var-argument control shows that an addressable incoming argument can force stack storage and xchg staging. These examples do not establish one global left-to-right rule; each expression kind is scheduled separately.

**r2_receiver_eval: O+: different; O-: different.**

A: `begin Fetch.Put(P.F,P.H); end;`
B: `begin with P do Fetch.Put(F,H); end;`

O+: A `TObj.Run: 0002: push edi; 0003: mov ebx, eax; ...; 0018: mov eax, edi; 001a: pop edi`; B `TObj.Run: 0002: mov ebx, dword ptr [eax + 0xc]; 000a: mov ecx, dword ptr [ebx + 8]; 000d: mov edx, dword ptr [ebx + 4]; 0015: mov eax, esi`.
O-: A `TObj.Run: 0003: add esp, -0x10; ...; 0021: mov edx, dword ptr [edx + 0xc]`; B `TObj.Run: 0003: add esp, -0x14; ...; 0024: mov edx, dword ptr [ebp - 0xc]`.

**r2_untyped_arg: O+: different; O-: different.**

A: `begin Send(A,F,B); end;`
B: `var T:Integer; begin T:=F; Send(A,T,B); end;`

O+: A `TObj.Run: 0001: add eax, 4`; B `TObj.Run: 0001: push ecx; 0002: mov eax, dword ptr [eax + 4]; ...; 0008: mov eax, esp; 0012: pop edx`.
O-: A `TObj.Run: 0003: add esp, -0x10; 0012: lea edx, [eax + 4]`; B `TObj.Run: 0003: add esp, -0x14; ...; 0018: lea edx, [ebp - 0x14]`.

**r2_var_arg_order: O+: different; O-: different.**

A: `begin Send(A,A,B); end;`
B: `begin Send(A,B,A); end;`

O+: A `Run: 0002: mov dword ptr [esp], eax; 0005: mov eax, esp; ...; 0009: mov edx, dword ptr [esp]; 000c: xchg edx, eax`; B `Run: 0002: mov dword ptr [esp], edx; 0005: mov edx, esp; 0007: mov ecx, eax`.
O-: A `Run: 000c: lea edx, [ebp - 4]; 000f: mov ecx, dword ptr [ebp - 8]`; B `Run: 000c: lea edx, [ebp - 8]; 000f: mov ecx, dword ptr [ebp - 4]`.

### K05. Casts of call results and nested constructors

Reason: [match.md](match.md), `Result:=TClass(Items[I])` and GetEClass(...).Create(...).

The cast directly around GetObj saves/reloads the incoming argument; assigning GetObj's result to P first reduces the optimized wrapper to `call GetObj; ret`. Nested Find(A).Create(B) saves A and B in ebx/esi; the explicit class local needs only ebx for B. GetObj returns TObject; the cast/result type is an otherwise empty TObj. Find returns a class reference; its constructor writes G and calls inherited Create.

**r2_call_result_cast: O+: different; O-: different.**

A: `begin Result:=TObj(GetObj(A)); end;`
B: `var P:TObject; begin P:=GetObj(A); Result:=TObj(P); end;`

O+: A `Run: 0000: push ebx; 0001: mov ebx, eax; 0003: mov eax, ebx; 000a: pop ebx`; B `Run: (no corresponding instruction)`.
O-: A `Run: 0003: add esp, -8; ...; 0018: pop ecx`; B `Run: 0003: add esp, -0xc; ...; 001d: mov esp, ebp`.

**r2_nested_create: O+: different; O-: different.**

A: `begin Result:=Find(A).Create(B); end;`
B: `var C:TObjClass; begin C:=Find(A); Result:=C.Create(B); end;`

O+: A `Run: 0001: push esi; 0002: mov esi, edx; ...; 000d: mov ecx, esi; 0016: pop esi`; B `Run: 0001: mov ebx, edx; 0008: mov ecx, ebx`.
O-: A `Run: 0003: add esp, -0xc`; B `Run: 0003: add esp, -0x10; ...; 001c: mov eax, dword ptr [ebp - 0x10]`.

### K06. Record size, packing and hidden result buffers

Reason: [AoWTCPCK review](../data/equiv-review/AoWTCPCK.dpl.tsv), UpdateMoveCursor/CanMoveOn; [AoWTC.pas](../src/delphi3/AoWTCPCK/AoWTC.pas), packed-temporary comments; [match.md](match.md), GetHeapStatus.

The return ABI follows the exact record size. The byte-array records of sizes 1,2,4 return in al,ax,eax; sizes 3,5,8,9 use a caller-provided destination (edx after the explicit Byte argument here). Packing `record B:Byte; W:Word end` changes size 4 to 3: it therefore **adds** a hidden buffer, with W read at buffer+1 instead of extracting the high word of eax. Naming that buffer did not change O+ code. Two GetHeapStatus field expressions call it twice and reserve two $28-byte records; the explicit snapshot calls once. Those are different heap snapshots, not interchangeable in every program.

**r2_packed_result: O+: different; O-: different.**

A: `type TR=record B:Byte; W:Word; end; begin Result:=Make(Byte(A)).W; end;`
B: `type TR=packed record B:Byte; W:Word; end; begin Result:=Make(Byte(A)).W; end;`

O+: A `Run: 000a: shr eax, 0x10; 000d: movzx eax, ax`; B `Run: 0001: push ecx; 0006: mov edx, esp; 000d: movzx eax, word ptr [esp + 1]; 0012: pop edx`.
O-: A `Run: 0003: add esp, -0xc; ...; 0017: movzx eax, ax`; B `Run: 0003: add esp, -0x10; ...; 0017: movzx eax, word ptr [ebp - 0xf]`.

**r2_explicit_result_buffer: O+: same code; O-: different.**

A: `begin Result:=Make(Byte(A)).W; end;`
B: `var R:TR; begin R:=Make(Byte(A)); Result:=R.W; end;`

O+: Both `Run: 0008: call Make 000d: movzx eax, word ptr [esp + 1] 0012: pop edx 0013: pop ebx`.
O-: A `Run: 0006: mov dword ptr [ebp - 0xc], edx; ...; 0017: movzx eax, word ptr [ebp - 0xf]`; B `Run: 0006: mov dword ptr [ebp - 0x10], edx; ...; 0017: movzx eax, word ptr [ebp - 0xb]`.

**r2_record_size1: O+: different; O-: different.**

A: `type TR=packed record B:array[1..1] of Byte end; function Run(X:Byte):TR;`
B: `type TR=packed record B:array[1..2] of Byte end; function Run(X:Byte):TR;`

O+: A `Run: 0007: mov edx, 1; 0011: mov al, byte ptr [esp]`; B `Run: 0007: mov edx, 2; 0011: mov ax, word ptr [esp]`.
O-: A `Run: 000c: lea eax, [ebp - 2]; ...; 0019: mov al, byte ptr [ebp - 2]`; B `Run: 000c: lea eax, [ebp - 3]; ...; 0019: mov ax, word ptr [ebp - 3]`.

**r2_record_size2: O+: different; O-: different.**

A: `type TR=packed record B:array[1..2] of Byte end; function Run(X:Byte):TR;`
B: `type TR=packed record B:array[1..3] of Byte end; function Run(X:Byte):TR;`

O+: A `Run: 0000: push ecx; 0005: mov eax, esp; ...; 0011: mov ax, word ptr [esp]; 0015: pop edx`; B `Run: 0004: mov eax, edx; 0006: mov edx, 3`.
O-: A `Run: 0003: push ecx; ...; 0019: mov ax, word ptr [ebp - 3]`; B `Run: 0003: add esp, -8; ...; 001e: pop ecx`.

**r2_record_size4: O+: different; O-: different.**

A: `type TR=packed record B:array[1..4] of Byte end; function Run(X:Byte):TR;`
B: `type TR=packed record B:array[1..5] of Byte end; function Run(X:Byte):TR;`

O+: A `Run: 0000: push ecx; 0005: mov eax, esp; ...; 0011: mov eax, dword ptr [esp]; 0014: pop edx`; B `Run: 0004: mov eax, edx; 0006: mov edx, 5`.
O-: A `Run: 000e: lea eax, [ebp - 5]; ...; 001b: mov eax, dword ptr [ebp - 5]`; B `Run: 0006: mov dword ptr [ebp - 8], edx; ...; 0014: mov edx, 5`.

**r2_record_size8: O+: different; O-: different.**

A: `type TR=packed record B:array[1..8] of Byte end; function Run(X:Byte):TR;`
B: `type TR=packed record B:array[1..9] of Byte end; function Run(X:Byte):TR;`

O+: A `Run: 0006: mov edx, 8`; B `Run: 0006: mov edx, 9`.
O-: A `Run: 0014: mov edx, 8`; B `Run: 0014: mov edx, 9`.

**r2_heap_record: O+: different; O-: different.**

A: `begin Result:=GetHeapStatus.TotalAllocated+GetHeapStatus.TotalFree; end;`
B: `var R:THeapStatus; begin R:=GetHeapStatus; Result:=R.TotalAllocated+R.TotalFree; end;`

O+: A `Run: 0000: push ebx; 0001: add esp, -0x50; ...; 001e: add esp, 0x50; 0021: pop ebx`; B `Run: 0000: add esp, -0x28; 000a: mov eax, dword ptr [esp + 0xc]; 000e: add eax, dword ptr [esp + 0x10]; 0012: add esp, 0x28`.
O-: A `Run: 0003: add esp, -0x5c; ...; 0029: pop ebx`; B `Run: 0003: add esp, -0x34; ...; 001a: mov dword ptr [ebp - 4], eax`.

### K07. Address-taking, record reinterpretation and pointer aliases

Reason: [PoisonP.pas](../src/delphi3/AoWEPACK/PoisonP.pas), CreatePoisonPlant; [UnHolyG.pas](../src/delphi3/AoWEPACK/UnHolyG.pas), CreateUnholyGround; [match.md](match.md), TLargeInteger casts.

Reinterpreting a Comp local as `TR(C)` forces an EBP frame; `PR(@C)^` stays ESP-relative under O+. Passing an Integer local to an untyped const parameter forces its addressable slot. `TR(Pointer(P)^)` versus `with PR(P)^` changes which object address survives Fetch. This small case reused the pointer for both fields; it did not reproduce the repeated reloads described for a larger original method. TR in that last pair is `record X,Y:Integer end`, so X/Y occupy offsets 0/4 of the cast memory.

**r2_record_cast_frame: O+: different; O-: different.**

A: `type TR=record Lo,Hi:Integer end; begin C:=A; Result:=TR(C).Lo; end;`
B: `type TR=record Lo,Hi:Integer end; PR=^TR; begin C:=A; Result:=PR(@C)^.Lo; end;`

O+: A `Run: 0000: push ebp; 0001: mov ebp, esp; ...; 0013: mov esp, ebp; 0015: pop ebp`; B `Run: 0003: mov dword ptr [esp + 8], eax; 0007: fild dword ptr [esp + 8]; ...; 0011: mov eax, dword ptr [eax]; 0013: add esp, 0xc`.
O-: A `Run: 0009: mov dword ptr [ebp - 0xc], eax; ...; 0019: mov eax, dword ptr [ebp - 0x10]`; B `Run: 0009: mov dword ptr [ebp - 4], eax; ...; 0018: mov dword ptr [ebp - 8], eax`.

**r2_address_local: O+: different; O-: different.**

A: `begin X:=Tick(A); Sink(X); Result:=X+B; end;`
B: `procedure Read(const X); procedure Read(const X); begin G:=Integer(X) end; begin X:=Tick(A); Read(X); Sink(X); Result:=X+B; end;`

O+: A `Run: 0004: call Tick; 0012: lea eax, [esi + ebx]`; B `Run: 0002: push ecx; 0009: call Tick; ...; 0023: add eax, esi; 0025: pop edx`.
O-: A `Run: (no corresponding instruction)`; B `Run: 0017: lea eax, [ebp - 0x10]; 001a: call Read`.

**r2_record_with_cast: O+: different; O-: different.**

A: `begin Fetch.Put(TR(Pointer(P)^).X,TR(Pointer(P)^).Y); end;`
B: `begin with PR(P)^ do Fetch.Put(X,Y); end;`

O+: A `TObj.Run: 0002: push edi; 0003: mov ebx, eax; ...; 0017: mov eax, edi; 0019: pop edi`; B `TObj.Run: 0002: mov ebx, dword ptr [eax + 0xc]; 000a: mov ecx, dword ptr [ebx + 4]; 000d: mov edx, dword ptr [ebx]; 0014: mov eax, esi`.
O-: A `TObj.Run: 0003: add esp, -0x10; ...; 0021: mov edx, dword ptr [edx + 0xc]`; B `TObj.Run: 0003: add esp, -0x14; ...; 0024: mov edx, dword ptr [ebp - 0xc]`.

### K08. Aggregate assignment, Move and callee copies

Reason: [aowInt review](../data/equiv-review/aowInt.dpl.tsv), DrawBack<TAOWPanel.Draw; [match.md](match.md), const-record copies.

`D:=S` is specialized: the four-byte const record arrives as a value in eax, eight bytes copy two dwords, and 16/32 bytes use saved esi/edi plus `rep movsd` with count 4/8. `Move(S,D,SizeOf(S))` calls System.Move instead. A value 16-byte R copied again to L reserves/copies two records ($20 bytes); const R copied to L needs one ($10). Do not replace record assignment by Move when matching the copy instructions or parameter ABI.

**r2_copy4: O+: different; O-: different.**

A: `procedure Run(const S:TR; var D:TR); begin D:=S; end;`
B: `procedure Run(const S:TR; var D:TR); begin Move(S,D,SizeOf(S)); end;`

O+: A `Run: 0004: mov eax, dword ptr [esp]; 0007: mov dword ptr [edx], eax`; B `Run: 0004: mov eax, esp; 0006: mov ecx, 4; 000b: call System.Move@8E671582`.
O-: A `Run: 000c: mov eax, dword ptr [ebp - 8]; ...; 0012: mov dword ptr [eax], edx`; B `Run: 000c: mov edx, dword ptr [ebp - 8]; ...; 0017: call System.Move@8E671582`.

**r2_copy8: O+: different; O-: different.**

A: `procedure Run(const S:TR; var D:TR); begin D:=S; end;`
B: `procedure Run(const S:TR; var D:TR); begin Move(S,D,SizeOf(S)); end;`

O+: A `Run: 0000: mov ecx, dword ptr [eax]; 0002: mov dword ptr [edx], ecx; 0004: mov ecx, dword ptr [eax + 4]; 0007: mov dword ptr [edx + 4], ecx`; B `Run: 0000: mov ecx, 8; 0005: call System.Move@8E671582`.
O-: A `Run: 000c: mov eax, dword ptr [ebp - 8]; ...; 0019: mov dword ptr [eax + 4], ecx`; B `Run: 000c: mov edx, dword ptr [ebp - 8]; ...; 0017: call System.Move@8E671582`.

**r2_copy16: O+: different; O-: different.**

A: `procedure Run(const S:TR; var D:TR); begin D:=S; end;`
B: `procedure Run(const S:TR; var D:TR); begin Move(S,D,SizeOf(S)); end;`

O+: A `Run: 0000: push esi; 0001: push edi; ...; 000d: pop edi; 000e: pop esi`; B `Run: 0000: mov ecx, 0x10; 0005: call System.Move@8E671582`.
O-: A `Run: 0006: push esi; ...; 0020: pop esi`; B `Run: 000c: mov edx, dword ptr [ebp - 8]; ...; 0017: call System.Move@8E671582`.

**r2_copy32: O+: different; O-: different.**

A: `procedure Run(const S:TR; var D:TR); begin D:=S; end;`
B: `procedure Run(const S:TR; var D:TR); begin Move(S,D,SizeOf(S)); end;`

O+: A `Run: 0000: push esi; 0001: push edi; ...; 000d: pop edi; 000e: pop esi`; B `Run: 0000: mov ecx, 0x20; 0005: call System.Move@8E671582`.
O-: A `Run: 0006: push esi; ...; 0020: pop esi`; B `Run: 000c: mov edx, dword ptr [ebp - 8]; ...; 0017: call System.Move@8E671582`.

**r2_const_copy: O+: different; O-: different.**

A: `type TR=record X,Y,Z,W:Integer end; function Run(const R:TR):Integer; function Run(const R:TR):Integer; var L:TR; begin L:=R; Result:=L.X+L.W end;`
B: `type TR=record X,Y,Z,W:Integer end; function Run(R:TR):Integer; function Run(R:TR):Integer; var L:TR; begin L:=R; Result:=L.X+L.W end;`

O+: A `Run: 0002: add esp, -0x10; 0007: mov edi, esp; ...; 0013: add eax, dword ptr [esp + 0xc]; 0017: add esp, 0x10`; B `Run: 0002: add esp, -0x20; 0007: lea edi, [esp]; ...; 0022: add eax, dword ptr [esp + 0x1c]; 0026: add esp, 0x20`.
O-: A `Run: 0003: add esp, -0x18; ...; 0023: mov eax, dword ptr [ebp - 8]`; B `Run: 0003: add esp, -0x24; ...; 0024: add eax, dword ptr [ebp - 0x18]`.

### K09. Managed cleanup grouping and managed record fields

Reason: [Arena.pas](../src/delphi3/AoWEPACK/Arena.pas), ExecuteTE; [Cave.pas](../src/delphi3/AoWEPACK/Cave.pas), EnterEx; [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TTeleport.Teleport.

The shared body assigns a,b,c to S1/S2/S3, calls Sink, then sums their lengths. Three string locals finalize with `LStrArrayClr` and edx=3. Making S2 a distinct `TAlt=type string` splits them into three LStrClr calls, despite identical pointer representation. Inserting an **unused** Integer between declarations does not split them, even under O-. The record-field test changes S:string to S:ShortString: the managed case initializes/finalizes the record through type metadata; the ShortString case does not. Grouping is about allocated managed values and type identity, not just the printed var-list order.

**r2_string_group_alias: O+: different; O-: different.**

A: `var S1,S2,S3:string; begin S1:='a'; S2:='b'; S3:='c'; Sink(A); Result:=Length(S1)+Length(S2)+Length(S3); end;`
B: `var S1:string; S2:TAlt; S3:string; begin S1:='a'; S2:='b'; S3:='c'; Sink(A); Result:=Length(S1)+Length(S2)+Length(S3); end;`

O+: A `Run: 0076: mov edx, 3; 007b: call System.@LStrArrayClr`; B `Run: 0076: call System.@LStrClr; 007b: lea eax, [ebp - 8]; ...; 0083: lea eax, [ebp - 4]; 0086: call System.@LStrClr`.
O-: A `Run: 0086: mov edx, 3; 008b: call System.@LStrArrayClr`; B `Run: 0086: call System.@LStrClr; ...; 0096: call System.@LStrClr`.

**r2_string_group_gap: O+: same code; O-: same code.**

A: `var S1,S2,S3:string; I:Integer; begin S1:='a'; S2:='b'; S3:='c'; Sink(A); Result:=Length(S1)+Length(S2)+Length(S3); end;`
B: `var S1:string; I:Integer; S2,S3:string; begin S1:='a'; S2:='b'; S3:='c'; Sink(A); Result:=Length(S1)+Length(S2)+Length(S3); end;`

O+: Both `Run: 0073: lea eax, [ebp - 0xc] 0076: mov edx, 3 007b: call System.@LStrArrayClr 0080: ret`.
O-: Both `Run: 0083: lea eax, [ebp - 0x14] 0086: mov edx, 3 008b: call System.@LStrArrayClr 0090: ret`.

**r2_managed_record: O+: different; O-: different.**

A: `type TR=record S:string; I:Integer end; procedure Run;`
B: `type TR=record S:ShortString; I:Integer end; procedure Run;`

O+: A `Run: 0000: push ebp; 0001: mov ebp, esp; ...; 005f: pop ebp; 0060: ret`; B `Run: 0000: add esp, 0xfffffefc; 0006: mov word ptr [esp], 0x7801; ...; 0011: mov dword ptr [esp + 0x100], eax; 0018: add esp, 0x104`.
O-: A `Run: 0003: add esp, -8; ...; 005e: pop ecx`; B `Run: 0003: add esp, 0xfffffefc; ...; 001d: mov esp, ebp`.

**r6_unused_live: O+: same code; O-: different.**
Report: `cx_cg5\forms.txt`, am4. Function:
`TLeaderSetupWin.DefaultBtnClick` (AoW.exe). An unused method parameter
can change managed-string initialization even though the body never reads it.
TObj has F:string and virtual `function GetValue:string`, implemented as
`Result:=F`. The paired declarations and complete bodies are:

```pascal
{ A } procedure TObj.A;
begin F:=GetValue end;
{ B } procedure TObj.B(Sender:TObject);
begin F:=GetValue end;
```

The getter needs one hidden string temporary. O- initializes it before
spilling the incoming parameters:

```text
A +03: add esp,-8                B +03: add esp,-0c
  +06: xor edx,edx                 +06: xor ecx,ecx
  +08: mov [ebp-8],edx             +08: mov [ebp-0c],ecx
  +0b: mov [ebp-4],eax             +0b: mov [ebp-8],edx
                                    +0e: mov [ebp-4],eax
```

The unused Sender still occupies EDX at initialization and gets an O- slot.
This is the initialization scratch register, not the FS-registration zero
register (EAX in both). O+ discards Sender, uses `push 0` for the temporary,
and produces identical bodies. Controls `r6_unused`, `r6_unused_temps`
and `r6_unused_four` likewise have identical optimized bodies; do not
generalize the reported EDX-to-ECX effect to every managed prologue.

### K10. String temporary destinations and lifetimes

Reason: [AoW review](../data/equiv-review/AoW.exe.tsv), TSendEmailGameDlg.ShowSendDialog; [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), path/managed-local leftovers.

Inlining `IntToStr` inside Copy reserves the Copy result pointer before calling IntToStr and uses the two private string slots in the opposite roles from explicit S. Both finally blocks still clear two strings together. By contrast, two separate `Length(IntToStr(...))` statements reuse one hidden string destination: naming and reassigning S gives the same code in both modes. A named temporary does not automatically lengthen lifetime or add cleanup; inspect the destination and clear sites.

**r2_string_inline: O+: different; O-: different.**

A: `begin Result:=Length(Copy(IntToStr(A),1,B)); end;`
B: `var S:string; begin S:=IntToStr(A); Result:=Length(Copy(S,1,B)); end;`

O+: A `Run: 001b: lea eax, [ebp - 4]; 001e: push eax; ...; 0029: mov eax, dword ptr [ebp - 8]; 0038: mov eax, dword ptr [ebp - 4]`; B `Run: 001b: lea edx, [ebp - 4]; 0025: lea eax, [ebp - 8]; ...; 0030: mov eax, dword ptr [ebp - 4]; 0038: mov eax, dword ptr [ebp - 8]`.
O-: A `Run: 000b: mov dword ptr [ebp - 0x14], ecx; ...; 0041: mov eax, dword ptr [ebp - 0x10]`; B `Run: 0008: mov dword ptr [ebp - 0x14], ecx; ...; 0041: mov eax, dword ptr [ebp - 0x14]`.

**r2_string_reuse: O+: same code; O-: same code.**

A: `begin Sink(Length(IntToStr(A))); Result:=Length(IntToStr(B)); end;`
B: `var S:string; begin S:=IntToStr(A); Sink(Length(S)); S:=IntToStr(B); Result:=Length(S); end;`

O+: Both `Run: 001e: call SysUtils.IntToStr@0F6FDFF6 0023: mov eax, dword ptr [ebp - 4] 0026: call System.@LStrLen 002b: call Sink`.
O-: Both `Run: 0025: call SysUtils.IntToStr@0F6FDFF6 002a: mov eax, dword ptr [ebp - 0x10] 002d: call System.@LStrLen 0032: call Sink`.

### K11. ShortString, Char concatenation and H state

Reason: [match.md](match.md), ClassName concatenation and Char+Char observations.

With S:ShortString, `S+'x'` builds a $100-byte short-string temporary with PStrCpy/PStrCat and then converts it. Casting S to string first instead creates a managed temporary, uses LStrFromString/LStrCat3 and adds finally cleanup. Char+Char takes the short-string path; casting the first Char to string selects managed conversions. H- changes the unqualified parameter/result string types and their ABI, not just the concatenation instruction.

**r2_short_concat: O+: different; O-: different.**

A: `begin Result:=S+'x'; end;`
B: `begin Result:=string(S)+'x'; end;`

O+: A `Run: 0002: add esp, 0xffffff00; 000e: mov eax, esp; ...; 0025: call System.@LStrFromString; 002a: add esp, 0x100`; B `Run: 0000: push ebp; 0001: mov ebp, esp; ...; 0051: pop ecx; 0052: pop ebp`.
O-: A `Run: 0003: add esp, 0xfffffef8; ...; 0036: call System.@LStrFromString`; B `Run: 0003: add esp, -0xc; ...; 0055: jmp +0x47`.

**r2_char_concat: O+: different; O-: different.**

A: `begin Result:=A+B; end;`
B: `begin Result:=string(A)+B; end;`

O+: A `Run: 0002: add esp, -0x10; 0007: mov byte ptr [esp], dl; ...; 0047: call System.@LStrFromString; 004c: add esp, 0x10`; B `Run: 0000: push ebp; 0001: mov ebp, esp; ...; 0068: mov esp, ebp; 006a: pop ebp`.
O-: A `Run: 0003: add esp, -0x14; ...; 0045: call System.@LStrFromString`; B `Run: 0003: add esp, -0x10; ...; 006e: pop ebx`.

**r2_string_H: O+: different; O-: different.**

A: `begin Result:=S+'x'; end;`
B: `{$H-} begin Result:=S+'x'; end;`

O+: A `Run: 0008: mov ecx, +0x20; 000d: mov edx, ebx; 000f: call System.@LStrCat3`; B `Run: 0002: add esp, 0xffffff00; 000c: mov edx, ebx; ...; 0025: call System.@PStrCpy; 002a: add esp, 0x100`.
O-: A `Run: 0003: add esp, -8; ...; 001d: pop ecx`; B `Run: 0003: add esp, 0xfffffef8; ...; 003b: mov esp, ebp`.

### K12. String data addresses, nil conversion and uniqueness

Reason: [ILToolsP review](../data/equiv-review/ILToolsP.dpl.tsv), CopyStreamToClipboard/PasteStreamFromClipboard; [match.md](match.md), @S[1].

For const S:string, both @S[1] and PChar(S) call LStrToPChar; Pointer(S) merely returns the incoming pointer. A writable **global** @S[1] instead passes the cell address to UniqueString, while Pointer(S) loads the pointer value. Storage and constness matter: do not transfer the global UniqueString observation to a const parameter. The Pointer(S)/Pointer(S) pair is the identical-source control.

**r2_strptr37: O+: different; O-: different.**

A: `begin Result:=Pointer(S); end;`
B: `begin Result:=@S[1]; end;`

O+: A `Run: (no corresponding instruction)`; B `Run: 0000: push ebx; 0001: mov ebx, eax; ...; 0005: call System.@LStrToPChar; 000a: pop ebx`.
O-: A `Run: (no corresponding instruction)`; B `Run: 000c: call System.@LStrToPChar`.

**r2_strptr38: O+: different; O-: different.**

A: `begin Result:=Pointer(S); end;`
B: `begin Result:=PChar(S); end;`

O+: A `Run: (no corresponding instruction)`; B `Run: 0000: push ebx; 0001: mov ebx, eax; ...; 0005: call System.@LStrToPChar; 000a: pop ebx`.
O-: A `Run: (no corresponding instruction)`; B `Run: 000c: call System.@LStrToPChar`.

**r2_strptr39: O+: same code; O-: same code.**

A: `begin Result:=Pointer(S); end;`
B: `begin Result:=Pointer(S); end;`

O+: Both `Run: 0000: ret`.
O-: Both `Run: 0001: mov ebp, esp 0003: add esp, -8 0006: mov dword ptr [ebp - 4], eax 0009: mov eax, dword ptr [ebp - 4]`.

**r2_global_unique: O+: different; O-: different.**

A: `begin Result:=@S[1]; end;`
B: `begin Result:=Pointer(S); end;`

O+: A `Run: 0000: mov eax, image+0x3024; 0005: call System.UniqueString@40929B27`; B `Run: 0000: mov eax, dword ptr [image+0x3024]`.
O-: A `Run: 0004: mov eax, image+0x3024; 0009: call System.UniqueString@40929B27`; B `Run: 0004: mov eax, dword ptr [image+0x3024]`.

**r6_move: O+: different; O-: different.**
Report: `cx_cg5\forms.txt`, am5. Functions:
`CopyStreamToClipboard` and `PasteStreamFromClipboard` (ILToolsP).
This extends the address/constness probes above with a statement-scoped
range-check switch. CopyA/B take `const S:string; P:Pointer; L:Integer`;
PasteA/B take `P:PChar; var S:string; L:Integer`:

```pascal
{ Copy A } Move(S[1],P^,L);
{ Copy B } {$R+} Move(S[1],P^,L); {$R-}
{ Paste A } SetLength(S,L); Move(P[4],S[1],L);
{ Paste B } SetLength(S,L); {$R+} Move(P[4],S[1],L); {$R-}
```

Copy A preserves its arguments across `+0b call System.@LStrToPChar`.
Copy B instead retains the literal index calculation:
`+01 mov ebx,1; +06 lea eax,[eax+ebx-1]; +0a call System.Move`.
It saves only EBX rather than EBX/ESI/EDI and has no string conversion.
Paste A/B both call SetLength and UniqueString; immediately after the latter:

```text
A +19: mov edx,eax               B +19: mov edx,1
  +1b: lea eax,[edi+4]              +1e: lea edx,[eax+edx-1]
                                    +22: lea eax,[edi+4]
```

Neither B body has a runtime bounds check or range-error call. O- also
removes Copy's LStrToPChar and emits MOV 1 plus LEA in both B routines.
This observation concerns the first-character address passed to Move's
untyped operand; it does not establish that ordinary checked string reads
omit bounds checks. Paste's writable var string still needs UniqueString.

### K13. Resource strings and typed constant cells

Reason: [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), assertion constant-cell loads; [match.md](match.md), LoadResString.

For a string result, `const Text='hello'` loads a literal pointer and calls LStrLAsg. A resourcestring calls LoadResString with its descriptor; `const Text:string='hello'` loads a pointer from a constant cell. These are distinct references and call traces even when the visible text agrees. This is the source distinction behind LEA/immediate versus a cell load in diagnostic rewrites.

**r2_resource_literal: O+: different; O-: different.**

A: `const Text='hello'; begin Result:=Text; end;`
B: `resourcestring Text='hello'; begin Result:=Text; end;`

O+: A `Run: 0003: mov eax, ebx; 0005: mov edx, +0x1c; 000a: call System.@LStrLAsg`; B `Run: 0003: mov edx, ebx; 0005: mov eax, image+0x130c; 000a: call System.LoadResString@02614E1B`.
O-: A `Run: 0007: mov eax, dword ptr [ebp - 4]; ...; 000f: call System.@LStrLAsg`; B `Run: 0007: mov edx, dword ptr [ebp - 4]; ...; 000f: call System.LoadResString@02614E1B`.

**r2_typed_string_const: O+: different; O-: different.**

A: `const Text='hello'; begin Result:=Text; end;`
B: `const Text:string='hello'; begin Result:=Text; end;`

O+: A `Run: 0005: mov edx, +0x1c`; B `Run: 0005: mov edx, dword ptr [image+0x2020]`.
O-: A `Run: 000a: mov edx, +0x20`; B `Run: 000a: mov edx, dword ptr [image+0x2020]`.

### K14. Method-pointer code/data halves and parameter copying

Reason: [MoveT.PAS](../src/delphi3/AoWEPACK/inc/MoveT.PAS), method-pointer-frame comment; [match.md](match.md), Assigned and @E comparisons.

TE is `procedure(X:Integer) of object`. Assigned(E) tests word [ebp+$0a], the high word of Code; TMethod(E).Code<>nil tests the entire dword at +8. @E=@F compares only Code, whereas explicit TMethod comparison checks both halves. Copying E to a local copies two dwords and changes call/test addresses, also in the loop. Value versus const TE did **not** change caller or callee here: both push Data then Code, and both indirect calls load Data into eax. Const method pointers must not be assumed to follow the eight-byte const-record ABI.

**r2_event_assigned: O+: different; O-: different.**

A: `begin Result:=Assigned(E); end;`
B: `begin Result:=TMethod(E).Code<>nil; end;`

O+: A `Run: 0003: cmp word ptr [ebp + 0xa], 0`; B `Run: 0003: cmp dword ptr [ebp + 8], 0`.
O-: A `Run: 0004: cmp word ptr [ebp + 0xa], 0`; B `Run: 0004: cmp dword ptr [ebp + 8], 0`.

**r2_event_equal: O+: different; O-: different.**

A: `begin Result:=@E=@F; end;`
B: `begin Result:=(TMethod(E).Code=TMethod(F).Code) and (TMethod(E).Data=TMethod(F).Data); end;`

O+: A `Run: 0009: sete al`; B `Run: 0009: jne +0x13; 000b: mov eax, dword ptr [ebp + 0x14]; ...; 0015: jmp +0x19; 0017: mov al, 1`.
O-: A `Run: 000a: sete byte ptr [ebp - 1]`; B `Run: 000a: jne +0x14; ...; 001a: mov byte ptr [ebp - 1], al`.

**r2_event_call: O+: different; O-: different.**

A: `begin E(A); end;`
B: `var T:TE; begin T:=E; T(A); end;`

O+: A `Run: 0006: mov eax, dword ptr [ebp + 0xc]; 0009: call dword ptr [ebp + 8]`; B `Run: 0003: add esp, -8; 0007: mov edx, dword ptr [ebp + 8]; ...; 001e: pop ecx; 001f: pop ecx`.
O-: A `Run: 0003: add esp, -8; ...; 0016: pop ecx`; B `Run: 0003: add esp, -0x10; ...; 0021: mov esp, ebp`.

**r2_event_loop: O+: different; O-: different.**

A: `begin while Assigned(E) do begin E(A); Dec(A); if A=0 then Break end; Result:=A; end;`
B: `var T:TE; begin T:=E; while Assigned(T) do begin T(A); Dec(A); if A=0 then Break end; Result:=A; end;`

O+: A `Run: 000a: mov eax, dword ptr [ebp + 0xc]; 000d: call dword ptr [ebp + 8]; 0015: cmp word ptr [ebp + 0xa], 0`; B `Run: 0003: add esp, -8; 0009: mov eax, dword ptr [ebp + 8]; ...; 002e: pop ecx; 002f: pop ecx`.
O-: A `Run: 0003: add esp, -8; ...; 002e: pop ecx`; B `Run: 0003: add esp, -0x10; ...; 0039: mov esp, ebp`.

**r2_event_parameter: O+: same code; O-: same code.**

A: `type TE=procedure(X:Integer) of object; procedure Send(E:TE; X:Integer); procedure Run(E:TE; X:Integer); procedure Send(E:TE; X:Integer); begin E(X) end; procedure Run(E:TE; X:Integer); begin Send(E,X) end;`
B: `type TE=procedure(X:Integer) of object; procedure Send(const E:TE; X:Integer); procedure Run(E:TE; X:Integer); procedure Send(const E:TE; X:Integer); begin E(X) end; procedure Run(E:TE; X:Integer); begin Send(E,X) end;`

O+: Both `Run: 0003: push dword ptr [ebp + 0xc] 0006: push dword ptr [ebp + 8] 0009: call Send 000e: pop ebp / Send: 0000: push ebp 0001: mov ebp, esp 0003: mov edx, eax 0005: mov eax, dword ptr [ebp + 0xc]`.
O-: Both `Run: 000a: push dword ptr [ebp + 8] 000d: mov eax, dword ptr [ebp - 4] 0010: call Send 0015: pop ecx / Send: 0000: push ebp 0001: mov ebp, esp 0003: push ecx 0004: mov dword ptr [ebp - 4], eax`.

### K15. Class-method receivers and dynamic declaration order

Reason: [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TCommandAbility.Command; [match.md](match.md), dynamic method numbering.

An instance virtual Work calls through its VMT while leaving the instance in eax. A class virtual Work first replaces eax with [eax], then calls its slot: the callee receives the class, not the instance. For dynamic A/B methods, swapping declaration order changes A's bx selector from $FFFF to $FFFE before CallDynaInst. Same-sized classes can therefore call different methods with identical ordinary argument setup.

**r2_class_method: O+: different; O-: different.**

A: `type TTarget=class function Work:Integer; virtual; end; function Run(O:TTarget):Integer; function TTarget.Work:Integer; begin Result:=1 end; function Run(O:TTarget):Integer; begin Result:=O.Work end;`
B: `type TTarget=class class function Work:Integer; virtual; end; function Run(O:TTarget):Integer; class function TTarget.Work:Integer; begin Result:=1 end; function Run(O:TTarget):Integer; begin Result:=O.Work end;`

O+: A `Run: 0000: mov edx, dword ptr [eax]; 0002: call dword ptr [edx]`; B `Run: 0000: mov eax, dword ptr [eax]; 0002: call dword ptr [eax]`.
O-: A `Run: 000c: mov edx, dword ptr [eax]; 000e: call dword ptr [edx]`; B `Run: 000c: mov eax, dword ptr [eax]; 000e: call dword ptr [eax]`.

**r2_dynamic_order: O+: different; O-: different.**

A: `type TTarget=class procedure A; dynamic; procedure B; dynamic; end; procedure Run(O:TTarget);`
B: `type TTarget=class procedure B; dynamic; procedure A; dynamic; end; procedure Run(O:TTarget);`

O+: A `Run: 0001: mov bx, 0xffff`; B `Run: 0001: mov bx, 0xfffe`.
O-: A `Run: 000b: mov bx, 0xffff`; B `Run: 000b: mov bx, 0xfffe`.

### K16. Constructor/destructor flags and inherited results

Reason: [AoWEd review](../data/equiv-review/AoWEd.exe.tsv), TAoWMapEditForm.vmt90 and TAoWResourceEditForm.Destroy; [match.md](match.md), stub inherited result.

Free is a direct TObject.Free call; Destroy supplies dl=1 and dispatches through VMT[-4]. Creating through an instance supplies allocation flag zero, while a class constructor call supplies one. The constructor-keyword control moves explicit X from edx to ecx and adds ClassCreate/FS handling. A destructor preserves the flag, masks dl with $FE for inherited Destroy, conditionally calls ClassDestroy, and returns Self. A procedure calling inherited Destroy instead passes -1. Finally, discarding an inherited function result keeps an extra ebx save/reload; `Result:=inherited Work(X)` avoids it. An unset function result is not a harmless stub contract.

**r2_free_destroy: O+: different; O-: different.**

A: `begin O.Free; Result:=0; end;`
B: `begin O.Destroy; Result:=0; end;`

O+: A `Run: 0000: call System.TObject.Free@23EDC2EF`; B `Run: 0000: mov dl, 1; 0002: mov ecx, dword ptr [eax]; 0004: call dword ptr [ecx - 4]`.
O-: A `Run: 000c: call System.TObject.Free@23EDC2EF`; B `Run: 0009: mov dl, 1; ...; 0010: call dword ptr [ecx - 4]`.

**r2_inherited_result: O+: different; O-: different.**

A: `function TB.Work(X:Integer):Integer; begin Result:=X+1 end; function TC.Work(X:Integer):Integer; begin inherited Work(X) end;`
B: `function TB.Work(X:Integer):Integer; begin Result:=X+1 end; function TC.Work(X:Integer):Integer; begin Result:=inherited Work(X) end;`

O+: A `TC.Work: 0000: push ebx; 0006: mov eax, ebx; 0008: pop ebx`; B `TC.Work: (no corresponding instruction)`.
O-: A `TC.Work: (no corresponding instruction)`; B `TC.Work: 0017: mov dword ptr [ebp - 0xc], eax`.

**r2_create_instance_class: O+: different; O-: different.**

A: `function Run(A,B:Integer):TObject; function Run(A,B:Integer):TObject; begin Result:=TObject.Create; end;`
B: `function Run(O:TObject):TObject; function Run(O:TObject):TObject; begin Result:=O.Create; end;`

O+: A `Run: 0000: mov dl, 1; 0002: mov eax, dword ptr [image+0x40c8]`; B `Run: 0000: xor edx, edx`.
O-: A `Run: 0003: add esp, -0xc; ...; 001e: mov esp, ebp`; B `Run: 0003: add esp, -8; ...; 001a: pop ecx`.

**r2_constructor_keyword: O+: different; O-: different.**

A: `type TT=class F:Integer; procedure Run(X:Integer); end; procedure TT.Run(X:Integer); begin F:=X end;`
B: `type TT=class F:Integer; constructor Run(X:Integer); end; constructor TT.Run(X:Integer); begin F:=X end;`

O+: A `TT.Run: 0000: mov dword ptr [eax + 4], edx`; B `TT.Run: 0000: test dl, dl; 0002: je +0xc; ...; 0013: pop dword ptr fs:[0]; 001a: add esp, 0xc`.
O-: A `TT.Run: 0003: add esp, -8; ...; 0016: pop ecx`; B `TT.Run: 0003: add esp, -0xc; ...; 0037: mov esp, ebp`.

**r2_destructor_keyword: O+: different; O-: different.**

A: `type TT=class F:Integer; procedure Run; end; procedure TT.Run; begin Sink(F); inherited Destroy end;`
B: `type TT=class F:Integer; destructor Run; end; destructor TT.Run; begin Sink(F); inherited Destroy end;`

O+: A `TT.Run: 0001: mov ebx, eax; 0003: mov eax, dword ptr [ebx + 4]; 000b: or edx, 0xffffffff; 000e: mov eax, ebx`; B `TT.Run: 0001: push esi; 0002: mov ebx, edx; ...; 0025: mov eax, esi; 0027: pop esi`.
O-: A `TT.Run: 0003: push ecx; 0012: or edx, 0xffffffff`; B `TT.Run: 0003: add esp, -8; ...; 0036: pop ecx`.

### K17. Calling conventions and assembler record formals

Reason: [match.md](match.md), stack arguments, stdcall and FillLargeInteger.

The five-Tick argument control distinguishes conventions. Register calls evaluate stack arguments 4,5 first, then register arguments 3,2,1; stdcall/cdecl evaluate 5,4,3,2,1; pascal evaluates 1,2,3,4,5. Register Send returns `ret 8`, stdcall/pascal `ret $14`; cdecl uses plain ret and caller `add esp,$14`. Merely changing the value-record callee from Pascal to assembler did **not** change either of the two tested callers (including the Fill(var B;N;V) shape). That negative result does not explain the larger FillLargeInteger matching observation.

**r2_asm_record_arg: O+: same code; O-: same code.**

A: `procedure Send(R:TR; X:Integer); begin end; procedure Run(A:Integer); var R:TR; begin R.X:=A; R.Y:=2; Send(R,Tick(A)) end;`
B: `procedure Send(R:TR; X:Integer); assembler; asm end; procedure Run(A:Integer); var R:TR; begin R.X:=A; R.Y:=2; Send(R,Tick(A)) end;`

O+: Both `Run: 0018: mov edx, eax 001a: mov eax, esp 001c: call Send 0021: pop ecx`.
O-: Both `Run: 001e: mov edx, eax 0020: lea eax, [ebp - 0xc] 0023: call Send 0028: mov esp, ebp`.

**r2_conv_stdcall: O+: different; O-: different.**

A: `function Send(A,B,C,D,E:Integer):Integer; register; function Run:Integer; function Send(A,B,C,D,E:Integer):Integer; register; begin Result:=A+B+C+D+E end; function Run:Integer; begin Result:=Send(Tick(1),Tick(2),Tick(3),Tick(4),Tick(5)) end;`
B: `function Send(A,B,C,D,E:Integer):Integer; stdcall; function Run:Integer; function Send(A,B,C,D,E:Integer):Integer; stdcall; begin Result:=A+B+C+D+E end; function Run:Integer; begin Result:=Send(Tick(1),Tick(2),Tick(3),Tick(4),Tick(5)) end;`

O+: A `Run: 0000: mov eax, 4; 000b: mov eax, 5; 0036: pop edx; 0037: pop ecx / Send: 0003: add edx, eax; 0005: add ecx, edx; ...; 000d: mov eax, ecx; 0010: ret 8`; B `Run: 0000: mov eax, 5; 000b: mov eax, 4; 0036: push eax / Send: 0003: mov eax, dword ptr [ebp + 8]; 0006: add eax, dword ptr [ebp + 0xc]; ...; 000f: add eax, dword ptr [ebp + 0x18]; 0013: ret 0x14`.
O-: A `Run: 0004: mov eax, 4; ...; 003b: pop ecx / Send: 0003: add esp, -0x10; ...; 0027: ret 8`; B `Run: 0004: mov eax, 5; ...; 003a: push eax / Send: 0003: push ecx; ...; 001b: ret 0x14`.

**r2_conv_cdecl: O+: different; O-: different.**

A: `function Send(A,B,C,D,E:Integer):Integer; register; function Run:Integer; function Send(A,B,C,D,E:Integer):Integer; register; begin Result:=A+B+C+D+E end; function Run:Integer; begin Result:=Send(Tick(1),Tick(2),Tick(3),Tick(4),Tick(5)) end;`
B: `function Send(A,B,C,D,E:Integer):Integer; cdecl; function Run:Integer; function Send(A,B,C,D,E:Integer):Integer; cdecl; begin Result:=A+B+C+D+E end; function Run:Integer; begin Result:=Send(Tick(1),Tick(2),Tick(3),Tick(4),Tick(5)) end;`

O+: A `Run: 0000: mov eax, 4; 000b: mov eax, 5; 0036: pop edx; 0037: pop ecx / Send: 0003: add edx, eax; 0005: add ecx, edx; ...; 000d: mov eax, ecx; 0010: ret 8`; B `Run: 0000: mov eax, 5; 000b: mov eax, 4; 0036: push eax; 003c: add esp, 0x14 / Send: 0003: mov eax, dword ptr [ebp + 8]; 0006: add eax, dword ptr [ebp + 0xc]; ...; 000f: add eax, dword ptr [ebp + 0x18]; 0013: ret`.
O-: A `Run: 0004: mov eax, 4; ...; 003b: pop ecx / Send: 0003: add esp, -0x10; ...; 0027: ret 8`; B `Run: 0004: mov eax, 5; ...; 0040: add esp, 0x14 / Send: 0003: push ecx; ...; 001b: ret`.

**r2_conv_pascal: O+: different; O-: different.**

A: `function Send(A,B,C,D,E:Integer):Integer; register; function Run:Integer; function Send(A,B,C,D,E:Integer):Integer; register; begin Result:=A+B+C+D+E end; function Run:Integer; begin Result:=Send(Tick(1),Tick(2),Tick(3),Tick(4),Tick(5)) end;`
B: `function Send(A,B,C,D,E:Integer):Integer; pascal; function Run:Integer; function Send(A,B,C,D,E:Integer):Integer; pascal; begin Result:=A+B+C+D+E end; function Run:Integer; begin Result:=Send(Tick(1),Tick(2),Tick(3),Tick(4),Tick(5)) end;`

O+: A `Run: 0016: mov eax, 3; 001b: call Tick; ...; 0036: pop edx; 0037: pop ecx / Send: 0003: add edx, eax; 0005: add ecx, edx; ...; 000d: mov eax, ecx; 0010: ret 8`; B `Run: 0000: mov eax, 1; 0005: call Tick; ...; 001b: call Tick; 0020: push eax / Send: 0003: mov eax, dword ptr [ebp + 0x18]; 0006: add eax, dword ptr [ebp + 0x14]; ...; 000f: add eax, dword ptr [ebp + 8]; 0013: ret 0x14`.
O-: A `Run: 001a: mov eax, 3; ...; 003b: pop ecx / Send: 0003: add esp, -0x10; ...; 0027: ret 8`; B `Run: 0004: mov eax, 1; ...; 0024: push eax / Send: 0003: push ecx; ...; 001b: ret 0x14`.

**r2_asm_fill_record: O+: same code; O-: same code.**

A: `procedure Fill(var B; N:Integer; V:TR); begin Integer(B):=V.X end; procedure Run(P:Pointer; N:Integer; V:TR); begin Fill(P^,N,V) end;`
B: `procedure Fill(var B; N:Integer; V:TR); asm mov eax,[ecx] end; procedure Run(P:Pointer; N:Integer; V:TR); begin Fill(P^,N,V) end;`

O+: Both `Run: 000b: movsd dword ptr es:[edi], dword ptr [esi] 000c: mov ecx, esp 000e: call Fill 0013: pop ecx`.
O-: Both `Run: 0018: lea ecx, [ebp - 0x10] 001b: mov edx, dword ptr [ebp - 8] 001e: call Fill 0023: pop edi`.

### K18. Open-array highs and array-of-const descriptors

Reason: [Enginep review](../data/equiv-review/Enginep.dpl.tsv), SortStringsEx; [AoW review](../data/equiv-review/AoW.exe.tsv), resource formatting.

An open Integer array arrives as data pointer eax and high index edx. `High(X)>=0` uses test edx/ jl; the fully unsigned comparison uses test edx/ jb, whose carry condition cannot be true after TEST. It preserves the original empty-array bug rather than fixing it. Format('%d',[A]) builds an Integer TVarRec; preconverting to S and formatting %s adds IntToStr, a managed slot and a different descriptor type. The array-of-const call contains a hidden high index (zero for one element) as well as the descriptor address.

**r2_open_high: O+: different; O-: different.**

A: `begin if High(X)>=0 then Result:=X[0] else Result:=0; end;`
B: `begin if Cardinal(High(X))>=Cardinal(0) then Result:=X[0] else Result:=0; end;`

O+: A `Run: 0002: jl +0x7`; B `Run: 0002: jb +0x7`.
O-: A `Run: 0010: jl +0x1c`; B `Run: 0010: jb +0x1c`.

**r2_format_temp: O+: different; O-: different.**

A: `begin Result:=Format('%d',[A]); end;`
B: `var S:string; begin S:=IntToStr(A); Result:=Format('%s',[S]); end;`

O+: A `Run: 0002: add esp, -8; 000a: mov dword ptr [esp + 4], ebx; ...; 0013: lea edx, [esp + 4]; 0024: pop edx`; B `Run: 0000: push ebp; 0001: mov ebp, esp; ...; 0062: mov esp, ebp; 0064: pop ebp`.
O-: A `Run: 0003: add esp, -0x14; ...; 001d: lea edx, [ebp - 0x14]`; B `Run: 0003: add esp, -0x18; ...; 0068: pop ebx`.

### K19. Out versus var interface ownership

Reason: [match.md](match.md), interface out argument observation.

For a local IUnknown, an out call clears the caller's destination with IntfClear immediately before Get; var does not. Both already need the local's outer managed cleanup. The out callee also has an initial nonnil-address check/zero store absent from the var callee in this `X:=nil` example. Do not infer out from the presence of the function-wide finalizer alone.

**r2_out_interface: O+: different; O-: different.**

A: `procedure Get(var X:IUnknown); procedure Run; procedure Get(var X:IUnknown); begin X:=nil end; procedure Run; var X:IUnknown; begin Get(X) end;`
B: `procedure Get(out X:IUnknown); procedure Run; procedure Get(out X:IUnknown); begin X:=nil end; procedure Run; var X:IUnknown; begin Get(X) end;`

O+: A `Run: (no corresponding instruction) / Get: (no corresponding instruction)`; B `Run: 0016: call System.@IntfClear / Get: 0000: push ebp; 0001: mov ebp, esp; ...; 000c: mov dword ptr [ebx], eax; 0016: pop ebp`.
O-: A `Run: (no corresponding instruction) / Get: (no corresponding instruction)`; B `Run: 0016: call System.@IntfClear / Get: 000a: test eax, eax; ...; 0012: mov eax, dword ptr [ebp - 4]`.

### K20. Typed handlers, consuming handlers and empty protected regions

Reason: [Enginep review](../data/equiv-review/Enginep.dpl.tsv), TCompareStorageStream.rwCreateEObject; [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TAIMoveExecuterMove.Destroy.

Catch-all except uses HandleAnyException and DoneExcept; adding raise calls RaiseAgain. An on E:Exception handler selects HandleOnException and adds a class/target table. An empty try/finally still installs and removes a frame and emits its handler; replacing it by the cleanup statement removes that machinery. These constructs differ in exception behavior, not merely layout. The displayed .handlers class address is masked by match.py; read the table identity when comparing different exception classes.

**r2_except_raise: O+: different; O-: different.**

A: `begin try Result:=Tick(A) except Sink(B); Result:=0 end; end;`
B: `begin try Result:=Tick(A) except Sink(B); raise end; end;`

O+: A `Run: 0004: push ebx; 0005: push esi; ...; 0040: pop esi; 0041: pop ebx`; B `Run: 0022: pop ecx; 0023: pop ebp; 0024: ret; 0032: call System.@RaiseAgain`.
O-: A `Run: 0006: push ebx; ...; 004e: pop ebx`; B `Run: 003c: call System.@RaiseAgain`.

**r2_except_typed: O+: different; O-: different.**

A: `begin try Result:=Tick(A) except Sink(B); Result:=0 end; end;`
B: `begin try Result:=Tick(A) except on E:Exception do begin Sink(B); Result:=0 end end; end;`

O+: A `Run: 0029: jmp System.@HandleAnyException`; B `Run: 0029: jmp System.@HandleOnException; .handlers ADDR:3a`.
O-: A `Run: 0003: add esp, -0xc; 0032: jmp System.@HandleAnyException`; B `Run: 0003: add esp, -0x10; ...; 0043: mov dword ptr [ebp - 0x10], eax`.

**r2_empty_try: O+: different; O-: different.**

A: `begin try finally Sink(A) end; Result:=B; end;`
B: `begin Sink(A); Result:=B; end;`

O+: A `Run: 0000: push ebp; 0001: mov ebp, esp; ...; 003c: pop ebp; 003d: ret`; B `Run: 0000: push ebx; 0001: mov ebx, edx; 0008: mov eax, ebx; 000a: pop ebx`.
O-: A `Run: 000c: xor eax, eax; ...; 0035: jmp +0x27`; B `Run: (no corresponding instruction)`.

### K21. Try-frame zero registers and nonlocal declaration context

Reason: [MapCtrl.pas](../src/delphi3/AoWEPACK/MapCtrl.pas), ExecuteEventLog; [match.md](match.md), Engine try-frame and class-count leftovers.

Changing a tested Tick result from an expression to local T did not change O+ code. A different carrier does: T:=Tick(A) leaves the result live in eax through `xor edx,edx` and FS registration, while Result:=Tick(A) stores it to [ebp-8] and registers via `xor eax,eax`. Under O- both carriers have storage but their slots/stores differ. The class-count sweep compares 0 through 9 extra declared/implemented methods, one count step at a time; reversing implementation order was also tested at three. All tested target bodies remained identical in each mode. This does **not** reproduce or disprove the context-sensitive larger original routine; it is not evidence for a different compiler build.

**r2_try_result_state: O+: same code; O-: different.**

A: `begin if Tick(A)>0 then try Result:=B finally Sink(A) end else Result:=0; end;`
B: `var T:Integer; begin T:=Tick(A); if T>0 then try Result:=B finally Sink(A) end else Result:=0; end;`

O+: Both `Run: 001a: push ebp 001b: push +0x3f 0020: push dword ptr fs:[eax] 0023: mov dword ptr fs:[eax], esp`.
O-: A `Run: 0003: add esp, -0xc; 0014: test eax, eax`; B `Run: 0003: add esp, -0x10; ...; 0017: cmp dword ptr [ebp - 0x10], 0`.

**r2_context_decls: O+: same code; O-: same code.**

A: `type TTarget=class F:Integer; function Run(A:Integer):Integer; procedure D0; procedure D1; end; function TTarget.Run(A:Integer):Integer; begin if Tick(A)>0 then try Result:=F finally Sink(A) end else Result:=0 end;procedure TTarget.D0; begin G:=G+0 end; procedure TTarget.D1; begin G:=G+1 end;`
B: `type TTarget=class F:Integer; function Run(A:Integer):Integer; procedure D0; procedure D1; procedure D2; end; function TTarget.Run(A:Integer):Integer; begin if Tick(A)>0 then try Result:=F finally Sink(A) end else Result:=0 end;procedure TTarget.D0; begin G:=G+0 end; procedure TTarget.D1; begin G:=G+1 end; procedure TTarget.D2; begin G:=G+2 end;`

O+: Both `TTarget.Run: 001a: push ebp 001b: push +0x42 0020: push dword ptr fs:[eax] 0023: mov dword ptr fs:[eax], esp`.
O-: Both `TTarget.Run: 001a: push ebp 001b: push +0x45 0020: push dword ptr fs:[eax] 0023: mov dword ptr fs:[eax], esp`.

**r2_context_order: O+: same code; O-: same code.**

A: `function TTarget.Run(A:Integer):Integer; begin if Tick(A)>0 then try Result:=F finally Sink(A) end else Result:=0 end;procedure TTarget.D0; begin G:=G+0 end; procedure TTarget.D1; begin G:=G+1 end; procedure TTarget.D2; begin G:=G+2 end;`
B: `procedure TTarget.D0; begin G:=G+0 end; procedure TTarget.D1; begin G:=G+1 end; procedure TTarget.D2; begin G:=G+2 end;function TTarget.Run(A:Integer):Integer; begin if Tick(A)>0 then try Result:=F finally Sink(A) end else Result:=0 end;`

O+: Both `TTarget.Run: 001a: push ebp 001b: push +0x42 0020: push dword ptr fs:[eax] 0023: mov dword ptr fs:[eax], esp`.
O-: Both `TTarget.Run: 001a: push ebp 001b: push +0x45 0020: push dword ptr fs:[eax] 0023: mov dword ptr fs:[eax], esp`.

**r2_try_carrier: O+: different; O-: different.**

A: `begin T:=Tick(A); try Result:=T+B finally Sink(A) end; end;`
B: `begin Result:=Tick(A); try Result:=Result+B finally Sink(A) end; end;`

O+: A `Run: 0014: xor edx, edx; 001c: push dword ptr fs:[edx]; ...; 0022: add ebx, eax; 0024: mov dword ptr [ebp - 8], ebx`; B `Run: 0014: mov dword ptr [ebp - 8], eax; 0017: xor eax, eax; ...; 0022: mov dword ptr fs:[eax], esp; 0025: add dword ptr [ebp - 8], ebx`.
O-: A `Run: 0014: mov dword ptr [ebp - 0x10], eax; ...; 002b: mov dword ptr [ebp - 0xc], eax`; B `Run: 0014: mov dword ptr [ebp - 0xc], eax; ...; 0028: add dword ptr [ebp - 0xc], eax`.

**r2_context_count0/1/3/4/5/6/7/8: same code in both modes.** These supplement r2_context_decls (2 versus 3). A class declares/implements n unrelated D methods (body G:=G+i); B declares/implements n+1, with the target Run body unchanged: `if Tick(A)>0 then try Result:=F finally Sink(A) end else Result:=0`. n=0,1,3,4,5,6,7,8. The full target streams, including FS setup and cleanup, agree at each step. Representative O+ start: `push ebp; mov ebp,esp; add esp,-8`; the target remains frame-backed under O- as well. The implementation-order pair above also agrees.

### K22. Assertion source position, includes and explicit diagnostics

Reason: [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TCombatPredictor.AddWall and TAIGroup.Deactivate; [HSEPack review](../data/equiv-review/HSEPack.dpl.tsv), THSMap.UnlockTerrainChangedEvent.

Splitting Assert across a line moves its ecx line argument from $0F to $10. Putting the same statement in r2_assert_fragment.inc changes the embedded filename; the Assert call/register forms are otherwise unchanged (literal positions move because the filenames have different lengths). An explicit three-argument import of System.@Assert@E17CE8DC preserves the original filename/line without rearranging source. Both calls use eax=message, edx=filename, ecx=line. These diagnostics are observable; matching only masked pointers is insufficient.

**r2_assert_endline: O+: different; O-: different.**

A: `begin Assert(A>0,'bad'); Result:=A; end;`
B: `begin Assert(A>0, 'bad'); Result:=A; end;`

O+: A `Run: 0007: mov ecx, 0xf`; B `Run: 0007: mov ecx, 0x10`.
O-: A `Run: 000f: mov ecx, 0xf`; B `Run: 000f: mov ecx, 0x10`.

**r2_assert_manual: O+: different; O-: different.**

A: `begin Assert(A>0,'bad'); Result:=A; end;`
B: `procedure Fail(const M,F:string; L:Integer); external 'vcl30.dpl' name 'System.@Assert@E17CE8DC'; begin if A<=0 then Fail('bad','original.pas',123); Result:=A; end;`

O+: A `Run: 0007: mov ecx, 0xf`; B `Run: 0007: mov ecx, 0x7b`.
O-: A `Run: 000f: mov ecx, 0xf`; B `Run: 000f: mov ecx, 0x7b`.

**r2_assert_include: O+: different; O-: different.**

A: `begin Assert(A>0,'bad'); Result:=A; end;`
B: `begin {$I r2_assert_fragment.inc} end;`

O+: A `Run: 0011: mov eax, +0x74`; B `Run: 0011: mov eax, +0x6c`.
O-: A `Run: 0019: mov eax, +0x84`; B `Run: 0019: mov eax, +0x7c`.

### K23. Assembler Result, local priority and tail shims

Reason: [match.md](match.md), pure-asm Result and asm-local observations; [Unit.PAS](../src/delphi3/AoWEPACK/inc/Unit.PAS), register-ABI shims.

Assigning Result in pure asm causes the compiler to reload al from its Result slot at the end. If the asm already loads al, this becomes a duplicate load; a private B local with an explicit al load avoids it. Omitting that explicit load in the Result version happens to match the local version. Naming X versus Y in an inline asm block determines which gets the first frame slot, changing the other's register. A Pascal forwarding function emits call Target/ret; a pure-asm jmp Target retains a tail jump (and no reached trailing ret).

**r2_asm_result: O+: same code; O-: same code.**

A: `function Run:Byte; assembler; asm mov Result,1 end;`
B: `function Run:Byte; assembler; var B:Byte; asm mov B,1; mov al,B end;`

O+: Both `Run: 0004: mov byte ptr [ebp - 1], 1 0008: mov al, byte ptr [ebp - 1] 000b: pop ecx 000c: pop ebp`.
O-: Both `Run: 0004: mov byte ptr [ebp - 1], 1 0008: mov al, byte ptr [ebp - 1] 000b: pop ecx 000c: pop ebp`.

**r2_asm_local_order: O+: different; O-: different.**

A: `begin X:=A; Y:=B; asm mov eax,Y end; Result:=X+Y; end;`
B: `begin X:=A; Y:=B; asm mov eax,X end; Result:=X+Y; end;`

O+: A `Run: 0004: mov ecx, eax; 0006: mov dword ptr [ebp - 4], edx; 000f: add eax, ecx`; B `Run: 0004: mov dword ptr [ebp - 4], eax; 000d: add eax, edx`.
O-: A `Run: 0012: mov eax, dword ptr [ebp - 0xc]; ...; 001e: add eax, dword ptr [ebp - 4]`; B `Run: 000f: mov dword ptr [ebp - 4], eax; ...; 001e: add eax, dword ptr [ebp - 0x14]`.

**r2_asm_tail: O+: different; O-: different.**

A: `function Target(X:Integer):Integer; begin Result:=X+1 end; function Run(X:Integer):Integer; begin Result:=Target(X) end;`
B: `function Target(X:Integer):Integer; begin Result:=X+1 end; function Run(X:Integer):Integer; assembler; asm jmp Target end;`

O+: A `Run: 0000: call Target`; B `Run: 0000: jmp Target`.
O-: A `Run: 0000: push ebp; ...; 0019: pop ebp`; B `Run: 0000: jmp Target`.

**r2_asm_extra_result: O+: different; O-: different.**

A: `function Run:Byte; assembler; asm mov Result,1; mov al,Result end;`
B: `function Run:Byte; assembler; var B:Byte; asm mov B,1; mov al,B end;`

O+: A `Run: 000b: mov al, byte ptr [ebp - 1]`; B `Run: (no corresponding instruction)`.
O-: A `Run: 000b: mov al, byte ptr [ebp - 1]`; B `Run: (no corresponding instruction)`.

### K24. Integer reassociation, operand order and complementary operations

Reason: [HSEPack review](../data/equiv-review/HSEPack.dpl.tsv), TAbstractRoad.GetShowPriority; [AoW review](../data/equiv-review/AoW.exe.tsv), TRelWindow.HighlightRace.

The constant-add reassociation and splitting `A+36` into Result assignment plus Inc collapse to the same O+ code here, but O- preserves their operation/store order. A+B versus B+A still changes add direction and the result move. XOR $FFFFFFFF and NOT have distinct opcodes. Both alternative doublings match `2*(A-B)` in both modes. Do not assume a split expression forces MOV/ADD rather than LEA; that depends on the rest of the allocation context.

**r2_add_assoc: O+: same code; O-: different.**

A: `begin Result:=(A+B)+$1000; end;`
B: `begin Result:=(A+$1000)+B; end;`

O+: Both `Run: 0000: lea edx, [edx + eax + 0x1000] 0007: mov eax, edx 0009: ret`.
O-: A `Run: 0012: add eax, 0x1000`; B `Run: 000f: add eax, 0x1000`.

**r2_add_split: O+: same code; O-: different.**

A: `begin Result:=A+36; end;`
B: `begin Result:=A; Inc(Result,36); end;`

O+: Both `Run: 0000: add eax, 0x24 0003: ret`.
O-: A `Run: 000f: add eax, 0x24`; B `Run: 0012: add dword ptr [ebp - 8], 0x24`.

**r2_xor_not: O+: different; O-: different.**

A: `begin Result:=A xor $FFFFFFFF; end;`
B: `begin Result:=not A; end;`

O+: A `Run: 0000: xor eax, 0xffffffff`; B `Run: 0000: not eax`.
O-: A `Run: 000c: xor eax, 0xffffffff`; B `Run: 000c: not eax`.

**r2_double73: O+: same code; O-: same code.**

A: `begin Result:=2*(A-B); end;`
B: `begin Result:=(A-B)*2; end;`

O+: Both `Run: 0000: sub eax, edx 0002: add eax, eax 0004: ret`.
O-: Both `Run: 0001: mov ebp, esp 0003: add esp, -0xc 0006: mov dword ptr [ebp - 8], edx 0009: mov dword ptr [ebp - 4], eax`.

**r2_double74: O+: same code; O-: same code.**

A: `begin Result:=2*(A-B); end;`
B: `begin Result:=(A-B) shl 1; end;`

O+: Both `Run: 0000: sub eax, edx 0002: add eax, eax 0004: ret`.
O-: Both `Run: 0001: mov ebp, esp 0003: add esp, -0xc 0006: mov dword ptr [ebp - 8], edx 0009: mov dword ptr [ebp - 4], eax`.

**r2_operand_add: O+: different; O-: different.**

A: `begin Result:=A+B; end;`
B: `begin Result:=B+A; end;`

O+: A `Run: 0000: add edx, eax; 0002: mov eax, edx`; B `Run: 0000: add eax, edx`.
O-: A `Run: 000c: mov eax, dword ptr [ebp - 4]; 000f: add eax, dword ptr [ebp - 8]`; B `Run: 000c: mov eax, dword ptr [ebp - 8]; 000f: add eax, dword ptr [ebp - 4]`.

**r6_shift_live: O+: different; O-: same code.**
Report: `cx_cg5\forms.txt`, am1. Function: `TItemHS.GetShowPriority`
(AoWEPACK). Unlike the simple doubling controls above, a larger power of
two can change allocation even though multiplication already becomes SHL.
TObj has F:Integer, P:TObj and virtual `Priority:Integer` returning F;
Coords takes `F:Integer; var X,Y:Integer` and assigns X:=F+1, Y:=F+2.
Both A/B methods return Integer and declare Xhp,Yhp:Integer; HS:TObj:

```pascal
Coords(F,Xhp,Yhp);
{ A } Result:=$68000000+(Yhp+33)*$2000+(Xhp+16);
{ B } Result:=$68000000+((Yhp+33) shl 13)+(Xhp+16);
HS:=P;
if (HS<>Self) and (HS<>nil) then
  if Result<=HS.Priority then Result:=HS.Priority+1;
```

```text
A +16: mov eax,[esp+4]           B +16: mov edi,[esp+4]
  +1a: add eax,21                   +1a: add edi,21
  +1d: mov edi,eax                  +1d: shl edi,0d
  +1f: shl edi,0d                   +20: add edi,68000000
  +22: add edi,68000000
```

Both retain Result in EDI across the Priority calls; the explicit shift
removes the intermediate EAX-to-EDI copy, shortening the routine by two
bytes. O- uses EAX for the computation and agrees completely. Controls
`r6_shift` (plain Xhp/Yhp parameters) and `r6_shift_slots` (Coords outputs
but no later calls) have identical O+ bodies. The live result context is
material; replacing multiplication by a shift is not a universal copy
removal, and Q+ overflow behavior was not tested.

### K25. Signed division, x87 helpers and precision barriers

Reason: [PrdPlace.pas](../src/delphi3/AoWEPACK/PrdPlace.pas), GetIncome; [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TAbstractUnit.ExecuteDamageRole; [match.md](match.md), reciprocal division and Comp records.

Signed A div 2 uses `sar; jns; adc` to round toward zero, unlike logical shr. Unsigned div 8 equals shr 3 in both modes; X/4 equals X*0.25 and uses the same reciprocal multiplication. Round and Trunc call different RTL helpers. A Single intermediate adds fstp dword/wait/fld and therefore a rounding boundary to a Double expression. Comp casts of the two eight-byte records compare with fild/fcompp/fnstsw/sahf; fieldwise Integer comparison does not. Typed Scale:Single versus Scale:Double changes FMUL from dword to qword; Scale:Extended instead uses FLD xword then multiplies the Double argument. Changing only the untyped literal 0.005 to 0.01 leaves both instruction streams identical, but the xword literal bytes change from `0a d7 a3 70 3d 0a d7 a3 f7 3f` to `0a d7 a3 70 3d 0a d7 a3 f8 3f` (float_literal_data.json). This is the TWorldFXHS.NewFrame kind of wrong-number bug in the AoWEPACK review: an instruction match alone cannot establish a floating value.

**r2_signed_half: O+: different; O-: different.**

A: `begin Result:=A div 2; end;`
B: `begin Result:=A shr 1; end;`

O+: A `Run: 0000: sar eax, 1; 0002: jns +0x7; 0004: adc eax, 0`; B `Run: 0000: shr eax, 1`.
O-: A `Run: 000c: sar eax, 1; ...; 0010: adc eax, 0`; B `Run: 000c: shr eax, 1`.

**r2_unsigned_div: O+: same code; O-: same code.**

A: `begin Result:=A div 8; end;`
B: `begin Result:=A shr 3; end;`

O+: Both `Run: 0000: shr eax, 3 0003: ret`.
O-: Both `Run: 000c: shr eax, 3 000f: mov dword ptr [ebp - 8], eax 0012: mov eax, dword ptr [ebp - 8] 0015: pop ecx`.

**r2_real_recip: O+: same code; O-: same code.**

A: `begin Result:=X/4; end;`
B: `begin Result:=X*0.25; end;`

O+: Both `Run: 0006: fld qword ptr [ebp + 8] 0009: fmul dword ptr [+0x1c] 000f: fstp qword ptr [ebp - 8] 0012: wait`.
O-: Both `Run: 0006: fld qword ptr [ebp + 8] 0009: fmul dword ptr [+0x1c] 000f: fstp qword ptr [ebp - 8] 0012: wait`.

**r2_round_trunc: O+: different; O-: different.**

A: `begin Result:=Round(X); end;`
B: `begin Result:=Trunc(X); end;`

O+: A `Run: 0006: call System.@ROUND`; B `Run: 0006: call System.@TRUNC`.
O-: A `Run: 0007: call System.@ROUND`; B `Run: 0007: call System.@TRUNC`.

**r2_fp_temp: O+: different; O-: different.**

A: `begin Result:=(X+Y)-X; end;`
B: `begin T:=X+Y; Result:=T-X; end;`

O+: A `Run: 0003: add esp, -8; 0016: pop ecx; 0017: pop ecx`; B `Run: 0003: add esp, -0xc; 000c: fstp dword ptr [ebp - 0xc]; ...; 0010: fld dword ptr [ebp - 0xc]; 001d: mov esp, ebp`.
O-: A `Run: (no corresponding instruction)`; B `Run: 000c: fstp dword ptr [ebp - 0xc]; ...; 0010: fld dword ptr [ebp - 0xc]`.

**r2_comp_compare: O+: different; O-: different.**

A: `begin Result:=Comp(A)=Comp(B); end;`
B: `begin Result:=(A.X=B.X) and (A.Y=B.Y); end;`

O+: A `Run: 0014: fild qword ptr [esp]; 0017: fild qword ptr [esp + 8]; ...; 001f: sahf; 0020: sete al`; B `Run: 0014: mov eax, dword ptr [esp]; 0017: cmp eax, dword ptr [esp + 8]; ...; 0029: jmp +0x2d; 002b: mov al, 1`.
O-: A `Run: 0016: fild qword ptr [ebp - 8]; ...; 0021: sete byte ptr [ebp - 0x11]`; B `Run: 0016: mov eax, dword ptr [ebp - 8]; ...; 002c: mov byte ptr [ebp - 0x11], al`.

**r2_float_const_single: O+: different; O-: different.**

A: `const Scale:Single=0.005; begin Result:=X*Scale; end;`
B: `const Scale:Double=0.005; begin Result:=X*Scale; end;`

O+: A `Run: 0009: fmul dword ptr [image+0x2020]`; B `Run: 0009: fmul qword ptr [image+0x2020]`.
O-: A `Run: 0009: fmul dword ptr [image+0x2020]`; B `Run: 0009: fmul qword ptr [image+0x2020]`.

**r2_float_const_extended: O+: different; O-: different.**

A: `const Scale:Double=0.005; begin Result:=X*Scale; end;`
B: `const Scale:Extended=0.005; begin Result:=X*Scale; end;`

O+: A `Run: 0006: fld qword ptr [ebp + 8]; 0009: fmul qword ptr [image+0x2020]`; B `Run: 0006: fld xword ptr [image+0x2020]; 000c: fmul qword ptr [ebp + 8]`.
O-: A `Run: 0006: fld qword ptr [ebp + 8]; 0009: fmul qword ptr [image+0x2020]`; B `Run: 0006: fld xword ptr [image+0x2020]; 000c: fmul qword ptr [ebp + 8]`.

**r2_float_literal_value: same instructions, different literal data (both modes).**

A: `begin Result:=X*0.005; end;`
B: `begin Result:=X*0.01; end;`

O+: Both `Run: 0006: fld xword ptr [+0x1c] 000c: fmul qword ptr [ebp + 8] 000f: fstp qword ptr [ebp - 8] 0012: wait`.
O-: Both `Run: 0006: fld xword ptr [+0x1c] 000c: fmul qword ptr [ebp + 8] 000f: fstp qword ptr [ebp - 8] 0012: wait`.

### K26. Set constants, Include, membership and literal type inference

Reason: [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TMine.SetRazed, TArmy.Desert and TAbstractUnit.ExecuteDamageEffects; [MoveT.PAS](../src/delphi3/AoWEPACK/inc/MoveT.PAS), set-expression leftover.

Include(S,2) ORs immediate 4 into the byte slot; S:=S+[2] loads a constant then ORs. A typed set constant loads a data cell rather than the local literal pool. Integer bit tests differ from set intersection/equality and variable membership uses a bound guard plus BT instead of SHL/AND. A two-byte S combined with untyped [0,2] and [] expands to 32-byte sets and SetExpand/SetIntersect/SetEq in this expression. Declaring Mask and Empty as the same TS instead yields word AND/CMP. The attempted direct literal typecasts were rejected; typed constant declarations are the tested small-set form.

**r2_set_include: O+: different; O-: different.**

A: `begin Include(S,2); Result:=S; end;`
B: `begin S:=S+[2]; Result:=S; end;`

O+: A `Run: 0004: or byte ptr [esp], 4`; B `Run: 0004: mov al, byte ptr [+0x14]; 0009: or al, byte ptr [esp]; 000c: mov byte ptr [esp], al`.
O-: A `Run: 0007: or byte ptr [ebp - 1], 4`; B `Run: 0007: mov al, byte ptr [+0x20]; ...; 000f: mov byte ptr [ebp - 1], al`.

**r2_set_typed_const: O+: different; O-: different.**

A: `type TS=set of 0..7; begin Result:=S+[2]; end;`
B: `type TS=set of 0..7; const C:TS=[2]; begin Result:=S+C; end;`

O+: A `Run: 0005: mov bl, byte ptr [+0x14]`; B `Run: 0005: mov bl, byte ptr [image+0x2020]`.
O-: A `Run: 0007: mov al, byte ptr [+0x18]`; B `Run: 0007: mov al, byte ptr [image+0x2020]`.

**r2_set_integer_mask: O+: different; O-: different.**

A: `begin Result:=S*[0,2]=[0]; end;`
B: `begin Result:=(Byte(S) and 5)=1; end;`

O+: A `Run: 0004: mov al, byte ptr [+0x1c]; 0009: and al, byte ptr [esp]; 000c: mov dl, byte ptr [+0x20]; 0012: cmp dl, al`; B `Run: 0004: mov al, byte ptr [esp]; 0007: and al, 5; 0009: cmp al, 1`.
O-: A `Run: 0007: mov al, byte ptr [+0x24]; ...; 0015: cmp dl, al`; B `Run: 0007: mov al, byte ptr [ebp - 1]; ...; 000c: cmp al, 1`.

**r2_set_member: O+: different; O-: different.**

A: `begin Result:=I in S; end;`
B: `begin Result:=(Byte(S) and (1 shl I))<>0; end;`

O+: A `Run: 0004: cmp al, 7; 0006: ja +0xf; ...; 000b: bt dword ptr [esp], eax; 000f: setb al`; B `Run: 0004: mov ecx, eax; 0006: mov eax, 1; ...; 0012: and eax, edx; 0014: setne al`.
O-: A `Run: 000a: mov al, byte ptr [ebp - 1]; ...; 001b: mov byte ptr [ebp - 3], al`; B `Run: 000a: mov cl, byte ptr [ebp - 1]; ...; 001b: setne byte ptr [ebp - 3]`.

**r2_set_width: O+: different; O-: different.**

A: `type TS=set of 0..7; begin Result:=S*[0,2]<>[]; end;`
B: `type TS=set of 0..15; begin Result:=S*[0,2]<>[]; end;`

O+: A `Run: 0000: push ecx; 0001: mov byte ptr [esp], al; ...; 0012: cmp dl, al; 0017: pop edx`; B `Run: 0000: push esi; 0001: push edi; ...; 004e: pop edi; 004f: pop esi`.
O-: A `Run: 0003: push ecx; ...; 001e: pop ecx`; B `Run: 0003: add esp, -0x44; ...; 0050: mov esp, ebp`.

**r2_set_annotate: O+: different; O-: different.**

A: `type TS=set of 0..15; begin Result:=S*[0,2]<>[]; end;`
B: `type TS=set of 0..15; const Mask:TS=[0,2]; Empty:TS=[]; begin Result:=(S*Mask)<>Empty; end;`

O+: A `Run: 0000: push esi; 0001: push edi; ...; 004e: pop edi; 004f: pop esi`; B `Run: 0000: push ecx; 0005: mov ax, word ptr [image+0x2020]; ...; 0016: cmp dx, ax; 001c: pop edx`.
O-: A `Run: 0003: add esp, -0x44; ...; 0050: mov esp, ebp`; B `Run: 0003: push ecx; ...; 0023: pop ecx`.

### K27. Exact True, enum storage and normalization width

Reason: [AoW review](../data/equiv-review/AoW.exe.tsv), TMultiWindow.JoinBtnClick and TUnitSelectionDlg.DrawUnit; [Enginep review](../data/equiv-review/Enginep.dpl.tsv), TCompressStream.SaveToStreamEx.

`if B` tests nonzero, while `B=True` compares al with 1; values 2..255 distinguish them. Explicit source Z1 versus Z4 changes SizeOf of TE=(e0,e1,e2) from 1 to 4. With valid one-byte enum storage, passing a Byte cast to TE gives the same caller as a Byte formal in this control: it did not reproduce the original extra eax copy. The two Byte/mask placements also normalize to the same code. Those controls did not explain the original conversion/register choice; the constructor/enum-local refinement below now reproduces the extra EAX copy.

**r2_exact_true: O+: different; O-: different.**

A: `begin if B then Result:=1 else Result:=2; end;`
B: `begin if B=True then Result:=1 else Result:=2; end;`

O+: A `Run: 0000: test al, al; 0002: je +0xa`; B `Run: 0000: cmp al, 1; 0002: jne +0xa`.
O-: A `Run: 0009: cmp byte ptr [ebp - 1], 0; 000d: je +0x18`; B `Run: 0009: cmp byte ptr [ebp - 1], 1; 000d: jne +0x18`.

**r2_byte_enum: O+: same code; O-: same code.**

A: `type TE=(e0,e1,e2); procedure Send(E:TE); begin end; procedure Run(B:Byte); begin Send(TE(B)) end;`
B: `type TE=(e0,e1,e2); procedure Send(E:Byte); begin end; procedure Run(B:Byte); begin Send(B) end;`

O+: Both `Run: 0000: call Send 0005: ret / Send: 0000: ret`.
O-: Both `Run: 000a: call Send 000f: pop ecx 0010: pop ebp 0011: ret / Send: 0000: push ebp 0001: mov ebp, esp 0003: push ecx 0004: mov byte ptr [ebp - 1], al`.

**r2_enum_size: O+: different; O-: different.**

A: `{$Z1}`
B: `{$Z4}`

O+: A `Run: 0000: mov eax, 1`; B `Run: 0000: mov eax, 4`.
O-: A `Run: 0004: mov dword ptr [ebp - 4], 1`; B `Run: 0004: mov dword ptr [ebp - 4], 4`.

**r2_mask_width: O+: same code; O-: same code.**

A: `begin Result:=Byte(A) and $7F; end;`
B: `begin Result:=Byte(A and $7F); end;`

O+: Both `Run: 0000: and al, 0x7f 0002: and eax, 0xff 0007: ret`.
O-: Both `Run: 000c: and al, 0x7f 000e: and eax, 0xff 0013: mov dword ptr [ebp - 8], eax 0016: mov eax, dword ptr [ebp - 8]`.

**r2_enum_third: O+: same code; O-: same code.**

A: `type TE=(e0,e1,e2); procedure Send(X,Y:Integer; E:TE); procedure Run(A,B:Integer; C:Byte); procedure Send(X,Y:Integer; E:TE); begin G:=X+Y+Ord(E) end; procedure Run(A,B:Integer; C:Byte); begin Sink(A); Send(A,B,TE(C)) end;`
B: `type TE=(e0,e1,e2); procedure Send(X,Y:Integer; E:TE); procedure Run(A,B:Integer; C:TE); procedure Send(X,Y:Integer; E:TE); begin G:=X+Y+Ord(E) end; procedure Run(A,B:Integer; C:TE); begin Sink(A); Send(A,B,TE(C)) end;`

O+: Both `Run: 0016: call Send 001b: pop edi 001c: pop esi 001d: pop ebx / Send: 0000: add edx, eax 0002: xor eax, eax 0004: mov al, cl 0006: add edx, eax`.
O-: Both `Run: 0020: call Send 0025: mov esp, ebp 0027: pop ebp 0028: ret / Send: 0000: push ebp 0001: mov ebp, esp 0003: add esp, -0xc 0006: mov byte ptr [ebp - 9], cl`.

**Fourth-round refinement: an enum local before construction reproduces the
extra EAX copy.** Source: `D:\Build\tmp\cx_cg3\reports\rw4.md`,
`TCompressStream.SaveToStreamEx`. This extends K27's same-code formal-type
controls; changing the formal type alone was insufficient.

**r4_enum_local: O+: different; O-: different.** TE=(eNone,eFast,eDefault,eMax),
`TComp.Create(E:TE; S:TStream)`, `Run(S:TStream; B:Byte)`:

```pascal
S.Write(B,1); { Makes B addressable in both forms. }
{ A } C:=TComp.Create(TE(B),S);
{ B, E:TE } E:=TE(B); C:=TComp.Create(E,S);
C.Free;
```

```text
A +16: push ebx                    B +16: mov al,[esp]
  +17: mov cl,[esp+4]                +19: push ebx
                                    +1a: mov ecx,eax
  +1b: mov dl,1                     +1c: mov dl,1
  +22: call TComp.Create            +23: call TComp.Create
```

No zero extension is added: the enum argument is still in CL. Under O-, B
stores AL to the extra enum byte at `[ebp-$0D]` and later loads CL from it;
A loads CL straight from B's `[ebp-5]`. Inputs/output are in `cx_cg3`, as
specified in section 11. This also resolves the narrow enum-conversion
example listed as unexplained in `match.md`; it does not identify another
compiler build.

### K28. Equivalent thresholds, overflow-sensitive guards and mask timing

Reason: [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), CompareCityProductions; [AoW review](../data/equiv-review/AoW.exe.tsv), TUnitWindow.ShowUnit and TArmyInfoDlg.DrawUnit.

A<4 uses cmp 4/jge; A<=3 uses cmp 3/jg. A>0 uses test/jle, whereas A-1>=0 uses dec/js, with different behavior at INT_MIN when checks are off. Q+ adds IntOver to the subtraction form. Moving the $7F mask before the unsigned Byte guard moves the AND before CMP and changes which inputs reach the body. These are distinct kinds: threshold spelling is equivalent; overflow and early masking need a domain proof.

**r2_threshold: O+: different; O-: different.**

A: `begin if A<4 then Result:=1 else Result:=2; end;`
B: `begin if A<=3 then Result:=1 else Result:=2; end;`

O+: A `Run: 0000: cmp eax, 4; 0003: jge +0xb`; B `Run: 0000: cmp eax, 3; 0003: jg +0xb`.
O-: A `Run: 0009: cmp dword ptr [ebp - 4], 4; 000d: jge +0x18`; B `Run: 0009: cmp dword ptr [ebp - 4], 3; 000d: jg +0x18`.

**r2_overflow_guard: O+: different; O-: different; O- Q+ R+: different.**

A: `begin if A>0 then Result:=1 else Result:=2; end;`
B: `begin if A-1>=0 then Result:=1 else Result:=2; end;`

O+: A `Run: 0000: test eax, eax; 0002: jle +0xa`; B `Run: 0000: dec eax; 0001: js +0x9`.
O-: A `Run: 0009: cmp dword ptr [ebp - 4], 0; 000d: jle +0x18`; B `Run: 0009: mov eax, dword ptr [ebp - 4]; ...; 000d: js +0x18`.
O- Q+ R+: A `Run: 0009: cmp dword ptr [ebp - 4], 0; 000d: jle +0x18`; B `Run: 0009: mov eax, dword ptr [ebp - 4]; 000c: sub eax, 1; ...; 0011: call System.@IntOver; 0016: js +0x21`.

**r2_mask_guard: O+: different; O-: different.**

A: `begin if A<128 then Result:=A and $7F else Result:=0; end;`
B: `begin A:=A and $7F; if A<128 then Result:=A else Result:=0; end;`

O+: A `Run: 0004: and al, 0x7f`; B `Run: 0000: and al, 0x7f`.
O-: A `Run: 0012: and al, 0x7f; 0014: and eax, 0xff`; B `Run: 0009: and byte ptr [ebp - 1], 0x7f; 0013: xor eax, eax`.

### K29. Pointer stepping, loop bounds and exception-bearing loops

Reason: [Ability.PAS](../src/delphi3/AoWEPACK/inc/Ability.PAS), nested-loop slots; [BloodShrine.pas](../src/delphi3/AoWEPACK/BloodShrine.pas), map-pointer reuse; [match.md](match.md), palette pointer walk and arithmetic while.

Inc(PInteger) and explicit Pointer(Integer(P)+4) match under O+ but differ under O-. The fixed local array V[0..255] of three-byte pixels is already walked by a pointer in the indexed source; explicit P merely swaps pointer/count registers here. A per-iteration except moves Self, Result, index and count into frame slots. Writing D:=A-B separately adds a top test that the arithmetic while form lacks. The Tick-bound direction control calls Tick(1) then Tick(2) in both directions in this context; the exit tests and counter updates differ.

**r2_pointer_inc: O+: same code; O-: different.**

A: `begin Inc(P); Result:=P^; end;`
B: `begin P:=Pointer(Integer(P)+4); Result:=P^; end;`

O+: Both `Run: 0000: add eax, 4 0003: mov eax, dword ptr [eax] 0005: ret`.
O-: A `Run: 0009: add dword ptr [ebp - 4], 4`; B `Run: 0009: mov eax, dword ptr [ebp - 4]; ...; 000f: mov dword ptr [ebp - 4], eax`.

**r2_array_walk: O+: different; O-: different.**

A: `var V:TV; I:Integer; begin FillChar(V,SizeOf(V),1); Result:=0; for I:=0 to 255 do Inc(Result,V[I].R); end;`
B: `var V:TV; I:Integer; P:^TP; begin FillChar(V,SizeOf(V),1); Result:=0; P:=@V[0]; for I:=0 to 255 do begin Inc(Result,P^.R); Inc(P) end; end;`

O+: A `Run: 001a: mov edx, 0x100; 001f: mov eax, esp; ...; 0027: add eax, 3; 002a: dec edx`; B `Run: 001a: mov edx, esp; 001c: mov eax, 0x100; ...; 0027: add edx, 3; 002a: dec eax`.
O-: A `Run: 0003: add esp, 0xfffffcf8; ...; 002e: movzx eax, byte ptr [ebp + eax - 0x308]`; B `Run: 0003: add esp, 0xfffffcf4; ...; 003a: add dword ptr [ebp - 0xc], 3`.

**r2_loop_exception: O+: different; O-: different.**

A: `begin Result:=0; for I:=0 to A do begin Sink(F); Inc(Result,I) end; end;`
B: `begin Result:=0; for I:=0 to A do begin try Sink(F) except end; Inc(Result,I) end; end;`

O+: A `TObj.Run: 0004: mov edi, eax; 0006: xor ebp, ebp; ...; 001f: mov eax, ebp; 0021: pop ebp`; B `TObj.Run: 0000: push ebp; 0001: mov ebp, esp; ...; 0061: mov esp, ebp; 0063: pop ebp`.
O-: A `TObj.Run: (no corresponding instruction)`; B `TObj.Run: 0006: push ebx; ...; 0069: pop ebx`.

**r2_bound_calls: O+: different; O-: different.**

A: `begin Result:=0; for I:=Tick(1) to Tick(2) do Sink(I); end;`
B: `begin Result:=0; for I:=Tick(1) downto Tick(2) do Sink(I); end;`

O+: A `Run: 001f: jl +0x2d; 0021: inc ebx; 0029: inc esi; 002a: dec ebx`; B `Run: 001f: jg +0x2d; 0021: dec ebx; 0029: dec esi; 002a: inc ebx`.
O-: A `Run: 0029: jl +0x42; ...; 003d: dec dword ptr [ebp - 0xc]`; B `Run: 0029: jg +0x42; ...; 003d: inc dword ptr [ebp - 0xc]`.

**r2_while_expression: O+: different; O-: different.**

A: `begin while A-B>0 do begin Sink(B); Inc(B) end; Result:=B; end;`
B: `var D:Integer; begin D:=A-B; while D>0 do begin Sink(B); Inc(B); D:=A-B end; Result:=B; end;`

O+: A `Run: 0006: jmp +0x10`; B `Run: 0006: mov eax, esi; 0008: sub eax, ebx; 000a: test eax, eax; 000c: jle +0x1e`.
O-: A `Run: 0003: add esp, -0xc; ...; 001f: test eax, eax`; B `Run: 0003: add esp, -0x10; ...; 002f: cmp dword ptr [ebp - 0x10], 0`.

### K30. Dead stores, retained conditions and undefined results

Reason: [AoW review](../data/equiv-review/AoW.exe.tsv), TTCUnit.UAbilLBMouseMove; [HSEPack review](../data/equiv-review/HSEPack.dpl.tsv), THSMEdit.UpdateMouseCoordinates; [Gfxepack review](../data/equiv-review/Gfxepack.dpl.tsv), alignment benchmarks.

A dead B:=3 assignment is removed, yet its `test eax,eax` remains under O+. A dead local result of Tick does not remove the call. A missing Result initialization leaves the incoming eax on the untaken branch here; adding Result:=0 introduces an accumulator/zero. Such paths cannot be judged equivalent merely because all defined-result paths agree. O- exposes actual stale slots instead of these register choices.

**r2_dead_parameter: O+: different; O-: different.**

A: `begin if A>0 then B:=3; Result:=A; end;`
B: `begin Result:=A; end;`

O+: A `Run: 0000: test eax, eax`; B `Run: (no corresponding instruction)`.
O-: A `Run: 0006: mov dword ptr [ebp - 8], edx; ...; 001f: mov eax, dword ptr [ebp - 0xc]`; B `Run: 0006: mov dword ptr [ebp - 0xc], edx; ...; 0012: mov eax, dword ptr [ebp - 8]`.

**r2_dead_call: O+: different; O-: different.**

A: `var T:Integer; begin T:=Tick(A); Result:=B; end;`
B: `begin Result:=B; end;`

O+: A `Run: 0000: push ebx; 0001: push esi; ...; 000f: pop esi; 0010: pop ebx`; B `Run: 0000: mov eax, edx`.
O-: A `Run: 0003: add esp, -0x10; ...; 001d: mov eax, dword ptr [ebp - 0xc]`; B `Run: 0003: add esp, -0xc; ...; 000f: mov dword ptr [ebp - 8], eax`.

**r2_undefined_result: O+: different; O-: different.**

A: `begin if A>0 then Result:=B; end;`
B: `begin Result:=0; if A>0 then Result:=B; end;`

O+: A `Run: (no corresponding instruction)`; B `Run: 0000: xor ecx, ecx`.
O-: A `Run: (no corresponding instruction)`; B `Run: 000c: xor eax, eax; 000e: mov dword ptr [ebp - 0xc], eax`.

### K31. Source switch state and the numeric command-line Z trap

Reason: [match.md](match.md), compiler-switch sweep and unexplained compiler-build conjecture.

W+ adds an EBP frame to the nonleaf Tick(A)+B function under O+, but not to the trivial leaf A+B; O- already has the frame. A- changes TR.I from offset 4 to 1. J- did not fold a typed Integer constant load. The numeric command-line -$Z1 is a separate bug: SizeOf(TE) becomes 28 in the retained control and Byte-to-enum calls failed with C4436/C7400 before adding a valid source directive. Removing that flag, appending -$Z-, or writing {$Z1} gives size 1; source {$Z4} gives 4. The probe default is now Z-. **r2_enum_cli_source A alone deliberately overrides it with --switch Z1**; B uses source {$Z1}. Four independent flag controls are retained in enum_controls.json. The no-source-override enum-call input enum_bad_cli.pas also reproduces C4436 under O+ and C7400 under O- with --switch Z1; the compile logs are in control_enum_bad_opt/noopt. These two intentionally failing diagnostics are not counted as successful source-pair configurations. Do not blame a source variant or a compiler build before separating source directives from CLI spellings.

**r2_frame_switch: O+: same code; O-: same code.**

A: `begin Result:=A+B; end;`
B: `{$W+} begin Result:=A+B; end;`

O+: Both `Run: 0000: add edx, eax 0002: mov eax, edx 0004: ret`.
O-: Both `Run: 0001: mov ebp, esp 0003: add esp, -0xc 0006: mov dword ptr [ebp - 8], edx 0009: mov dword ptr [ebp - 4], eax`.

**r2_alignment_switch: O+: different; O-: different.**

A: `begin Result:=R.I; end;`
B: `{$A-} begin Result:=R.I; end;`

O+: A `Run: 0000: mov eax, dword ptr [eax + 4]`; B `Run: 0000: mov eax, dword ptr [eax + 1]`.
O-: A `Run: 000c: mov eax, dword ptr [eax + 4]`; B `Run: 000c: mov eax, dword ptr [eax + 1]`.

**r2_typed_const_J: O+: same code; O-: same code.**

A: `begin Result:=C; end;`
B: `{$J-} begin Result:=C; end;`

O+: Both `Run: 0000: mov eax, dword ptr [image+0x2020] 0005: ret`.
O-: Both `Run: 0001: mov ebp, esp 0003: push ecx 0004: mov eax, dword ptr [image+0x2020] 0009: mov dword ptr [ebp - 4], eax`.

**r2_frame_nonleaf: O+: different; O-: same code.**

A: `begin Result:=Tick(A)+B; end;`
B: `{$W+} begin Result:=Tick(A)+B; end;`

O+: A `Run: (no corresponding instruction)`; B `Run: 0000: push ebp; 0001: mov ebp, esp; 0014: pop ebp`.
O-: Both `Run: 0001: mov ebp, esp 0003: add esp, -0xc 0006: mov dword ptr [ebp - 8], edx 0009: mov dword ptr [ebp - 4], eax`.

**r2_enum_cli_source: O+: different; O-: different.**

A: `function Run:Integer;`
B: `{$Z1}`

O+: A `Run: 0000: mov eax, 0x3f`; B `Run: 0000: mov eax, 1`.
O-: A `Run: 0004: mov dword ptr [ebp - 4], 0x3f`; B `Run: 0004: mov dword ptr [ebp - 4], 1`.

### K32. Getter calls versus fields and unchecked backing arrays

Reason: [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TAIMoveTargetSelector.ProcessStates; [Unit.PAS](../src/delphi3/AoWEPACK/inc/Unit.PAS), raw backing-array note; [AoW review](../data/equiv-review/AoW.exe.tsv), pure Count getter caching.

TList L[I] calls Classes.TList.Get, including its bounds behavior; L.List^[I] loads the backing pointer at +4 and indexes directly. A field-backed Value property compiles to a field load, while an otherwise identical getter-backed property calls Get, even though Get is only Result:=F. The getter is not inlined. A getter's apparent purity may justify an equivalence argument, but it does not give the same call trace or code.

**r2_list_get_raw: O+: different; O-: different.**

A: `begin Result:=Integer(L[I]); end;`
B: `begin Result:=Integer(L.List^[I]); end;`

O+: A `Run: 0000: push ebx; 0001: push esi; ...; 000f: pop esi; 0010: pop ebx`; B `Run: 0000: mov eax, dword ptr [eax + 4]; 0003: mov eax, dword ptr [eax + edx*4]`.
O-: A `Run: 000f: mov eax, dword ptr [ebp - 4]; 0012: call Classes.TList.Get@23EDC2EF`; B `Run: 000c: mov eax, dword ptr [ebp - 4]; ...; 0015: mov eax, dword ptr [eax + edx*4]`.

**r2_property_getter: O+: different; O-: different.**

A: `type TTarget=class F:Integer; function Get:Integer; property Value:Integer read F; end; function Run(O:TTarget):Integer;`
B: `type TTarget=class F:Integer; function Get:Integer; property Value:Integer read Get; end; function Run(O:TTarget):Integer;`

O+: A `Run: 0000: mov eax, dword ptr [eax + 4]`; B `Run: 0000: call TTarget.Get`.
O-: A `Run: 000c: mov eax, dword ptr [eax + 4]`; B `Run: 000c: call TTarget.Get`.

### K33. Checked class casts and exact versus descendant type tests

Reason: [CitySpells.pas](../src/delphi3/AoWEPACK/CitySpells.pas), animation-cast comments; [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TCombatUnit.ObjectDestroyed.

`O as TStringList` adds the target-class load and AsClass helper before Count; the hard cast omits them. `O is TStringList` calls IsClass, while ClassType=TStringList calls ClassType then compares the exact VMT. Nil and subclass cases differ. These checked forms are not substitutes for redundant hard casts used only to perturb allocation.

**r2_checked_cast: O+: different; O-: different.**

A: `begin Result:=TStringList(O).Count; end;`
B: `begin Result:=(O as TStringList).Count; end;`

O+: A `Run: (no corresponding instruction)`; B `Run: 0000: push ebx; 0001: mov ebx, eax; ...; 000b: call System.@AsClass; 0015: pop ebx`.
O-: A `Run: (no corresponding instruction)`; B `Run: 000c: mov edx, dword ptr [image+0x4104]; 0012: call System.@AsClass`.

**r2_is_class: O+: different; O-: different.**

A: `begin Result:=O is TStringList; end;`
B: `begin Result:=O.ClassType=TStringList; end;`

O+: A `Run: 0005: mov edx, dword ptr [image+0x4104]; 000b: call System.@IsClass`; B `Run: 0005: call System.TObject.ClassType@23EDC2EF; 000a: cmp eax, dword ptr [image+0x4104]; 0010: sete al`.
O-: A `Run: 000c: mov edx, dword ptr [image+0x4104]; ...; 0017: mov byte ptr [ebp - 5], al`; B `Run: 000c: call System.TObject.ClassType@23EDC2EF; ...; 0017: sete byte ptr [ebp - 5]`.

### K34. Typed deallocation and clear-before-free order

Reason: [match.md](match.md), Dispose/FreeMem; [Ilpack review](../data/equiv-review/Ilpack.dpl.tsv), old-image freeing/reloads.

Dispose of the plain eight-byte record loads edx=8 before FreeMem; explicit FreeMem(P,SizeOf(P^)) omits that size argument in the emitted helper call. Dispose of a record containing string calls @Dispose with type metadata; raw FreeMem does not finalize that string. `P.Free; P:=nil` clears after the call; saving P, clearing it, then freeing T clears before the callback/destructor. Delphi 3 has no FreeAndNil helper in this installation; the latter is the explicitly written pattern, not a presumed library call.

**r2_dispose_freemem: O+: different; O-: different.**

A: `procedure Run(P:PR); begin Dispose(P) end;`
B: `procedure Run(P:PR); begin FreeMem(P,SizeOf(P^)) end;`

O+: A `Run: 0000: mov edx, 8`; B `Run: (no corresponding instruction)`.
O-: A `Run: 0007: mov edx, 8`; B `Run: (no corresponding instruction)`.

**r2_freeandnil: O+: different; O-: different.**

A: `begin P.Free; P:=nil; Result:=F; end;`
B: `var T:TObj; begin T:=P; P:=nil; T.Free; Result:=F; end;`

O+: A `TObj.Run: 000b: xor eax, eax; 000d: mov dword ptr [ebx + 0xc], eax`; B `TObj.Run: 0006: xor edx, edx; 0008: mov dword ptr [ebx + 0xc], edx`.
O-: A `TObj.Run: 0003: add esp, -0x10; ...; 0015: call System.TObject.Free@23EDC2EF`; B `TObj.Run: 0003: add esp, -0x14; ...; 0023: call System.TObject.Free@23EDC2EF`.
Context: Clear-before-Free is a source implementation of FreeAndNil; Delphi 3 has no such helper.

**r2_dispose_managed: O+: different; O-: different.**

A: `procedure Run(P:PR); begin Dispose(P) end;`
B: `procedure Run(P:PR); begin FreeMem(P,SizeOf(P^)) end;`

O+: A `Run: 0000: mov edx, dword ptr [image+0x130c]; 0006: call System.@Dispose`; B `Run: 0000: call System.@FreeMem`.
O-: A `Run: 0007: mov edx, dword ptr [image+0x130c]; 0010: call System.@Dispose`; B `Run: 000a: call System.@FreeMem`.

### K35. Constructor-compatible callback signatures

Reason: [match.md](match.md), TEObjectEditor.Edit constructor-shaped method pointer.

TCB is `procedure(Alloc:Boolean;X:Integer) of object`. A callback C(False,X) sends Data in eax, zero allocation flag in edx and X in ecx before its indirect Code call. Direct `O.Create(X)` uses the same hidden-flag layout with a known target. The callback wrapper retains O separately to return it. This explains why an ordinary procedure-of-object declaration with the wrong explicit Boolean can shift every following register argument.

**r2_constructor_callback: O+: different; O-: different.**

A: `constructor TTarget.Create(X:Integer); begin inherited Create end; function Run(C:TCB; O:TTarget; X:Integer):TTarget; begin Result:=O.Create(X) end;`
B: `constructor TTarget.Create(X:Integer); begin inherited Create end; function Run(C:TCB; O:TTarget; X:Integer):TTarget; begin C(False,X); Result:=O end;`

O+: A `Run: 0007: call TTarget.Create`; B `Run: 0003: push ebx; 0004: mov ebx, eax; ...; 0010: mov eax, ebx; 0012: pop ebx`.
O-: A `Run: 0014: call TTarget.Create`; B `Run: 0011: mov eax, dword ptr [ebp + 0xc]; 0014: call dword ptr [ebp + 8]`.

### K36. Unit initialization/finalization and global managed storage

Reason: [match.md](match.md), automatic per-unit init/fini pair.

The named routines here are Run, ProbeUnit and Finalization<ProbeUnit. Adding an empty initialization section leaves all three identical, including the existing reference counter and protected finalization skeleton. Changing unused Shared:Integer to Shared:string leaves Run alone but adds a global LStrClr in Finalization. A method can therefore match while its unit lifetime code differs; empty source initialization is not evidence that those emitted functions are absent.

**r2_unit_empty_init: O+: same code; O-: same code.**

A: `begin Result:=A+B; end;`
B: `initialization begin Result:=A+B; end;`

O+: Both `Run: 0000: add edx, eax 0002: mov eax, edx 0004: ret / ProbeUnit: 0000: sub dword ptr [image+0x3024], 1 0007: ret / Finalization<ProbeUnit: 000b: push dword ptr fs:[eax] 000e: mov dword ptr fs:[eax], esp 0011: inc dword ptr [image+0x3024] 0017: xor eax, eax`.
O-: Both `Run: 0000: push ebp 0001: mov ebp, esp 0003: add esp, -0xc 0006: mov dword ptr [ebp - 8], edx / ProbeUnit: 0000: sub dword ptr [image+0x3024], 1 0007: ret / Finalization<ProbeUnit: 000b: push dword ptr fs:[eax] 000e: mov dword ptr fs:[eax], esp 0011: inc dword ptr [image+0x3024] 0017: xor eax, eax`.

**r2_unit_managed_global: O+: different; O-: different.**

A: `var Shared:Integer; begin Result:=A+B; end;`
B: `var Shared:string; begin Result:=A+B; end;`

O+: A `Finalization<ProbeUnit: (no corresponding instruction)`; B `Finalization<ProbeUnit: 0017: jne +0x23; 0019: mov eax, image+0x3024; 001e: call System.@LStrClr`.
O-: A `Finalization<ProbeUnit: (no corresponding instruction)`; B `Finalization<ProbeUnit: 0017: jne +0x23; ...; 001e: call System.@LStrClr`.

### K37. Shared failure returns and Boolean branch materialization

Reason: [Cave.pas](../src/delphi3/AoWEPACK/Cave.pas), CanEnter shared-return comment; [City.pas](../src/delphi3/AoWEPACK/City.pas), ValidUpgradeBudgetCity; [AoW review](../data/equiv-review/AoW.exe.tsv), TFileDlgWindow.FileLBChange.

Two explicit early failure returns versus a short-circuit Boolean assignment share different return blocks and branch targets. A separate `if A=B then Result:=True else Result:=False` uses branches and explicit constants; `Result:=A=B` uses SETE. This extends the first-round Exit/else negative result: identical epilogues in one shape do not imply that every equivalent Boolean return structure canonicalizes.

**r2_shared_fail: O+: different; O-: different.**

A: `begin if A<0 then begin Result:=False; Exit end; if B<0 then begin Result:=False; Exit end; Result:=True; end;`
B: `begin Result:=(A>=0) and (B>=0); end;`

O+: A `Run: 0002: jge +0x7; 0004: xor eax, eax; 0006: ret`; B `Run: 0002: jl +0x8`.
O-: A `Run: 0010: jge +0x18; ...; 0024: mov byte ptr [ebp - 9], 1`; B `Run: 0010: jl +0x18; ...; 001e: mov byte ptr [ebp - 9], al`.

**r2_branch_boolean: O+: different; O-: different.**

A: `begin if A=B then Result:=True else Result:=False; end;`
B: `begin Result:=A=B; end;`

O+: A `Run: 0002: jne +0x7; 0004: mov al, 1; 0007: xor eax, eax; 0009: ret`; B `Run: 0002: sete al`.
O-: A `Run: 0012: jne +0x1a; ...; 001a: mov byte ptr [ebp - 9], 0`; B `Run: 0012: sete byte ptr [ebp - 9]`.

### K38. Single-label cases and explicit empty arms

Reason: [match.md](match.md), single-enum-label and empty-arm observations; [AoWEPACK review](../data/equiv-review/AoWEPACK.dpl.tsv), TAIGroupTargetSelector.Setup; [MainAG.pas](../src/delphi3/AoWEPACK/MainAG.pas), ProcessStates.

For source-sized TE=(e0,e1,e2), case E of e1 uses DEC al/JNE, while an equivalent if E=e1 uses CMP al,1/JNE. An explicit empty label is removed when the implicit default does nothing: the four-action cases with and without label 1 match. Once there is an else action, label 1 must bypass it. The five-label version then uses a table with offsets `27 61 33 3f 4b`, where label 1 targets the statement end at +61; removing that empty arm selects a four-label comparison chain instead. Removing it also changes input 1 behavior, so it is not a safe rewrite merely to obtain a chain.

**r2_empty_case_arm: O+: same code; O-: same code.**

A: `begin case A of 0:Sink(1); 1:; 2:Sink(2); 3:Sink(3); 4:Sink(4); end; Result:=A; end;`
B: `begin case A of 0:Sink(1); 2:Sink(2); 3:Sink(3); 4:Sink(4); end; Result:=A; end;`

O+: Both `Run: 0005: sub al, 1 0007: jb +0x17 0009: dec al 000b: je +0x23`.
O-: Both `Run: 000c: sub al, 1 000e: jb +0x1e 0010: dec al 0012: je +0x2a`.

**r2_enum_case_if: O+: different; O-: different.**

A: `begin Result:=0; case E of e1:Result:=Tick(1); end; end;`
B: `begin Result:=0; if E=e1 then Result:=Tick(1); end;`

O+: A `Run: 0002: dec al`; B `Run: 0002: cmp al, 1`.
O-: A `Run: 000e: mov al, byte ptr [ebp - 1]; 0011: dec al`; B `Run: 000e: cmp byte ptr [ebp - 1], 1`.

**r2_empty_case_else: O+: different; O-: different.**

A: `begin case A of 0:Sink(1); 1:; 2:Sink(2); 3:Sink(3); 4:Sink(4); else Sink(9) end; Result:=A; end;`
B: `begin case A of 0:Sink(1); 2:Sink(2); 3:Sink(3); 4:Sink(4); else Sink(9) end; Result:=A; end;`

O+: A `Run: 0003: xor eax, eax; 0005: mov al, bl; ...; 000c: jmp dword ptr [eax*4 + +0x13]; .table 27 61 33 3f 4b`; B `Run: 0003: mov eax, ebx; 0005: sub al, 1; ...; 0013: je +0x3b; 0015: jmp +0x47`.
O-: A `Run: 0009: xor eax, eax; ...; .table 2e 68 3a 46 52`; B `Run: 000c: sub al, 1; ...; 001c: jmp +0x4e`.

## 10. Worker-report audit (third round)

Read every file in `D:\Build\tmp\cx_cg2\reports` on 2026-10-23: **150 files**,
rather than the expected 148. This includes integration, conflict-resolution,
layout and behavior reports as well as near-miss, flow-fix, review and rewrite
reports. `report_audit.tsv` in `cx_cg2` lists every filename, SHA256 and disposition.
Repeated reports of one mechanism count once; a mismatch reason without a source
variation is not a newly established compiler rule. Wrong fields, constants,
call targets, signatures and comparison extents are not new source spellings.

**21 new report findings: 17 confirmed (K39..K55), 4 reported, not reproduced
(NR01..NR04); 27 mechanisms already present.** Two unconfirmed findings are
compiler diagnostics whose failing source was not supplied. Some confirmed
entries refine a covered topic: the new information is the specific load,
lifetime or ABI effect, not that locals or casts can affect code.

There are **44 plain source pairs, 91 pair/switch configurations, 182 successful
builds**, plus one exception-handler regression build. Every pair has O+ and O-
results. The packed-storage, packed-storage-with-extra-array and SmallInt memory
controls also have O- Q+ R+ results. These switches are relevant to
`AoWTCPCK/AoWTC.pas` (`{$O-,R+,Q+}`). No package or routine was executed.
The compiler hash still agrees with the setup section.

Inputs are `cx_cg2\inputs\r3_<name>_a.pas` and `_b.pas`; full disassembly is
`cx_cg2\r3_<name>_<mode>_<side>.txt`, with generated files in the corresponding
directory. Modes are `opt`, `noopt`, `checked`. `worker_probe_results.json`
records each command, named routine, output and exit status. Sources and logs
are retained; no scratch scripts or additional probe tool were created.

```powershell
python -B tools/dcc_probe.py D:\Build\tmp\cx_cg2\inputs\r3_index_local_shl0_b.pas `
  --out D:\Build\tmp\cx_cg2\reprobe -- TObj.Run
```

Report references such as `mr2.md` below are relative to that reports directory.
The motivating functions are named even when a small probe has a different
class layout. A successful probe confirms the mechanism, not an independent
recheck of the entire game function. The worker's original call/data identity
checks remain necessary when applying a form.

The common class for `sender_guard`, `sender_string`, `signed_reload`,
`index_shl0`, `index_local_shl0`, `global_cell_cast`, `nested_reuse` and several
existing-topic controls is:

```pascal
type TObj=class
  F,G,H:Integer; B:ShortInt; P,Q:TObj;
  function Get(X:Integer):Integer; virtual;
  procedure Put(X,Y:Integer); virtual;
  procedure Event(Sender:TObject);
  procedure Run(Sender:TObj);
end;
var Obj:TObj; Global:Integer;
{ Get returns F+X; Put assigns F:=X+Y; Event is empty. }
{ Tick(X): Global:=Global+X; Result:=Global. }
{ Sink(X): Global:=Global xor X. }
```

F/G/H/B/P/Q are at `$04/$08/$0C/$10/$14/$18`. Uses are SysUtils and Classes.
Other probes declare their smaller class or record in the retained input.

### K39. A Sender local moves preservation past a guard or frame setup

Reports: `mr2.md`, `mr5.md`. Functions: `TControlWin.Unit1FramePreDraw`,
`TRelWindow.P1CBPreDraw`, `TUnitWindow.Gnd1Draw`,
`TWorldMap.PPawnMouseMove`, and `TFileDlgWindow.FileLBChange`.

**r3_sender_guard: O+: different; O-: different.**

```pascal
{ A } if Obj<>nil then begin Sink(Sender.F); Sender.Put(F,G) end;
{ B, C:TObj } if Obj<>nil then begin C:=Sender; Sink(C.F); C.Put(F,G) end;
```

```text
A +02: mov esi,edx                 B +02: mov ebx,eax
  +04: mov ebx,eax                   +04: cmp [Obj],0
  +06: cmp [Obj],0                   +0b: je +24
  +0d: je +24                       +0d: mov esi,edx
```

The local copy occurs only on the taken path. The direct parameter is preserved
before the guard. Under O-, B has an extra local store/load instead.

**r3_sender_string: O+: different; O-: different.** Both have S:string:

```pascal
{ A } S:=IntToStr(Sender.F); Sender.Put(Length(S),F);
{ B, C:TObj } C:=Sender; S:=IntToStr(C.F); C.Put(Length(S),F);
```

A copies Sender with `+07 mov esi,edx` before `+0b xor eax,eax` and FS setup.
B installs the frame with `+09 xor eax,eax; ... +14 mov fs:[eax],esp`, then
copies Sender with `+17 mov ebx,edx`. Self becomes ESI in B. A source assignment
at the beginning of the body still follows the implicit managed-local frame.
This is more specific than l02's removed argument reload.

### K40. An indexed Char view defeats narrow-field reuse

Report: `mr1.md`. Functions: `TProductionControl.GetProduceUnitLevelMax`,
`TProductionControl.GetResearchUnitLevelMax`, `TLeader.MsgProc`.

**r3_signed_reload: O+: different; O-: same code.**

```pascal
{ A } if F<Sender.B then F:=Sender.B;
{ B } if F<Sender.B then F:=ShortInt(PChar(Sender)[$10]);
```

```text
A +00: movsx ecx,byte ptr [edx+10]  B +00: movsx ecx,byte ptr [edx+10]
  +04: cmp ecx,[eax+4]                +04: cmp ecx,[eax+4]
  +07: jle +0c                       +07: jle +10
  +09: mov [eax+4],ecx                +09: movsx edx,byte ptr [edx+10]
                                     +0d: mov [eax+4],edx
```

O- already reloads the typed field and both streams agree. The worker uses
`$2F` for resource level and `$24` for player. PChar indexing alone reads an
unsigned Char; the ShortInt cast restores the field's signed interpretation.

**Fourth-round refinement: Boolean as well as ShortInt.** Source:
`D:\Build\tmp\cx_cg3\reports\rw3.md`, `TAOWMemo.CheckMouseUp`, whose
FEditable is at `$158`. The probe uses B at `$0C` in section 11's TObj.

**r4_bool_reload: O+: different; O-: same code.**

```pascal
if B and (X>F) and (X<G) then
  { A } if B=True then Sender.Put(F,G);
  { B } if Boolean(PChar(Self)[$0C])=True then Sender.Put(F,G);
```

A: `+04 mov dl,[eax+0c]; +07 test dl,dl; ... +15 cmp dl,1`.
B: `+01 cmp byte ptr [eax+0c],0; ... +11 cmp byte ptr [eax+0c],1`.
B rereads the byte and drops A's ESI save. Both O- forms already use memory
comparisons and agree. This extends K40, preserving K27's exact-True test;
it does not normalize a noncanonical Boolean byte.

### K41. Nested predicates can change reuse even under B-

Report: `mr3.md`. Function: `TAOWWindow.CheckMouseMove`.

**r3_nested_reuse: O+: different; O-: same code.**

```pascal
{ A } if (F>Sender.F) and (Sender.G>F) then Sink(F);
{ B } if F>Sender.F then if Sender.G>F then Sink(F);
```

A: `+00 push ebx; +01 mov ebx,[edx+4]; +04 mov ecx,[eax+4];
+07 cmp ebx,ecx; +09 jge +17; +0b cmp ecx,[edx+8]`.
B: `+00 mov ecx,[eax+4]; +03 cmp ecx,[edx+4]; +06 jle +14;
+08 cmp ecx,[edx+8]`.
The EBX save disappears. Repeated F still stays in ECX in this small example;
Sender.F becomes a memory operand instead of a materialized EBX value.
b03's same-code result is not a general equivalence of code generation.

**r3_nested_resize: O+: different; O-: same code.** The closer resize-shaped control has
F/G/H:Integer and P:TObj at offsets 4/8/$0C/$10, with X:Integer:

```pascal
{ A }
if (F+G>X) and (P<>nil) and (H<>0) and (P.F>X-G) then X:=P.F+G;
{ B }
if F+G>X then if (P<>nil) and (H<>0) then
  if P.F>X-G then X:=P.F+G;
{ both finish with Result:=X }
```

A loads G into ECX at +05, reuses it at +22 and +2E, and reloads P.F at
+28/+2B after comparing it. B stops carrying G from the first predicate:
`+05 add ecx,[eax+8]`, then `+1e mov edi,[eax+8]` in the inner scope.
B instead retains P.F in ESI from +19 through `+27 mov edx,esi`.
Thus splitting predicates can trade which repeated value survives a condition;
it is not a general command to disable all reuse.

### K42. Rebasing a const-record address forces a second field access

Report: `mr3.md`. Function: `DrawLine16`, using
`PSurfaceDesc(@SD.Width)^.ClipRect.Left` at the repeated clip-left read.

**r3_record_rebase: O+: different; O-: same code.**
TR is `record Width,Height,Left,Top,Right,Bottom:Integer end`; PR=^TR.
Run is `function Run(const R:TR; X1,X2:Integer):Boolean`.

```pascal
{ A } Result:=(X1>=R.Left) and (X2>=R.Left);
{ B } Result:=(X1>=R.Left) and (X2>=PR(@R.Width)^.Left);
```

A: `+00 push esi; +01 mov esi,[eax+8]; +04 cmp edx,esi;
... +08 cmp esi,ecx; ... pop esi`.
B: `+00 cmp edx,[eax+8]; +03 jl +0a; +05 cmp ecx,[eax+8]; +08 jge +0d`.
B needs neither an address-add instruction nor the retained ESI value.
Both O- forms already reload R. This trick relies on Width being at offset zero;
rebasing through a later field changes the object addressed.

### K43. Zero shifts change expression scheduling

Report: `mr5.md`. Function: `TRealmWin.HeroInfoClick`.

**r3_index_local_shl0: O+: different; O-: different.**

```pascal
var Index:Integer;
Index:=Get(F);
{ A } Sender.P.Put(Index,Sender.G);
{ B } Sender.P.Put(Index shl 0,Sender.G);
```

```text
A +0a: mov ecx,[ebx+8]             B +0a: mov edx,eax
  +0d: mov edx,eax                   +0c: mov ecx,[ebx+8]
  +0f: mov eax,[ebx+14]              +0f: mov eax,[ebx+14]
```

There is no SHL. O- likewise moves the Index-slot load before the Sender/G
loads. `r3_index_shl0` repeats the effect with F as the index expression:
`mov eax,[eax+4]` moves from +07 to +01. The operation is folded away after
it has affected scheduling.

A receiver shifted by zero works the same way: `TProductionControlList(Integer(P) shl 0).GetPC(I)`
loads the receiver into EAX before the index into EDX, where `P.GetPC(I)` loads the index first
(report `mf1.md`; it made `TAutoProduceAIPA.Process` match).

The am1 report in `cx_cg5\forms.txt` repeats this receiver form as
`TImageSequenceList(Integer(Sequences) shl 0).GetImageSequence(...)` in
`TCity.GetTopBorderImage`, `GetMiddleBorderImage` and `GetBottomBorderImage`.
It is already covered here, including receiver-before-index scheduling;
the literal index does not establish a new mechanism.

### K44. Casting through Pointer changes an argument's member load timing

Report: `mr2.md`. Function: `ShowTutorialEvent` at both FMessage argument reads.

**r3_pointer_string_arg: O+: different; O-: different.** Here TObj has
`P,Q:TStringList`, and Run receives Sender:TObj.

```pascal
{ A } P.Add(Sender.Q[0]);
{ B } P.Add(TObj(Pointer(Sender)).Q[0]);
```

A: `+19 lea ecx,[ebp-4]; +1c xor edx,edx; +1e mov eax,[esi+8]`.
B: `+19 lea ecx,[ebp-4]; +1c mov eax,[esi+8]; +1f xor edx,edx`.
The same string getter and Add are called, with the same cleanup. Only the
independent receiver and zero-index loads exchange positions. O- exchanges
the analogous loads.

The simpler `r3_pointer_arg` control, `Sender.Put(F,G)` versus
`TObj(Pointer(Sender)).Put(F,G)`, is **same code in both modes**. A Pointer
cast is not a universal scheduling barrier; its position in the expression
matters.

### K45. An inline view of a global pointer cell changes reuse

Report: `mr2.md`. Function: `StartGame<AoWWinMan`, for the MWindow and
VideoDialog expressions. This differs from K02's named pointer-cell local.

**r3_global_cell_cast: O+: different; O-: different.**

```pascal
{ A }
Obj.F:=Obj.G-24; Obj.H:=Obj.G-32;
{ B }
TObj(Pointer(@Obj)^).F:=TObj(Pointer(@Obj)^).G-24;
TObj(Pointer(@Obj)^).H:=TObj(Pointer(@Obj)^).G-32;
```

A starts `+00 mov eax,[Obj]; +05 mov eax,[eax+8]; +08 sub eax,18;
+0b mov edx,[Obj]; +11 mov [edx+4],eax`.
B starts `+00 mov eax,Obj; +05 mov eax,[eax]; +07 mov edx,[eax+8];
+0a sub edx,18; +0d mov [eax+4],edx`, then repeats the cell-address/dereference
at +10/+15 for the next statement. The recipe changes which subexpressions
share a receiver; it does not promise that every source gets more loads.
O- also emits the explicit cell dereference. `Pointer(Obj)` and `@Obj` are
different addresses and must not be interchanged.

### K46. Field-first equality retains the common receiver

Report: `mr2.md`. Function: `TTCUnit.UAbilLBPreDrawItem`, the comparison of
movement points against the unit's GetMoves result.

**r3_field_first_chain: O+: different; O-: same code.** TObj has
`P,Q:TObj; F:Integer; function Get:Integer; virtual`, so P/Q/F are at 4/8/$0C.

```pascal
{ A } if Sender.P.Q.Get=Sender.P.F then F:=1;
{ B } if Sender.P.F=Sender.P.Q.Get then F:=1;
```

A: `+06 mov eax,[ebx+4]; +09 mov eax,[eax+8]; ... +0e call [edx];
+10 mov edx,[ebx+4]; +13 cmp eax,[edx+0c]`.
B adds `push edi`, then `+07 mov esi,[ebx+4]; +0a mov eax,[esi+8];
... +0f call [edx]; +11 cmp eax,[esi+0c]`.
The field value is still read after Get; P is now retained across that call.
A getter that changes Sender.P can distinguish these forms.
`r3_field_first`, with only `Sender.Get(0)=Sender.F` versus the reverse, is
**same code in both modes**. The shared receiver chain is material.

### K47. WordRec/LongRec overlays select a memory byte

Report: `mr1.md`. Function: `TEnchantedRoads.ShowAnimation`, the FFieldFlags
byte used in the frame-offset expression.

**r3_byte_field: O+: different; O-: different.** O:TObj, F:Integer at +4:

```pascal
{ A } Result:=(O.F shr 16) and $FF;
{ B } Result:=WordRec(LongRec(O.F).Hi).Lo;
```

A: `+00 mov eax,[eax+4]; +03 shr eax,10; +06 and eax,ff; +0b ret`.
B: `+00 movzx eax,byte ptr [eax+6]; +04 ret`.
O- retains the dword/shift/mask versus byte-load distinction. The worker also
needed explicit pointer stepping, already covered by K29.

**r3_byte_overlay: O+: different; O-: different.** With X:Integer a register
parameter instead of a memory field, A is `shr eax,10; and eax,ff; ret`.
The overlay B forces an addressable parameter and an EBP frame:
`+04 mov [ebp-4],eax; +07 xor eax,eax; +09 mov al,[ebp-2]`.
Thus the memory-field recipe does not imply a frame-free byte load for a
register parameter.

### K48. Multiplication operand order changes load order and destination

Report: `mr1.md`. Function: `TFastCombatUnit.GetTargetPriority`, multiplication
of the priority field by Count+2.

**r3_multiply_local: O+: different; O-: different.**
`procedure Run(Count:Integer; var F:Integer)`:

```pascal
{ A } F:=(Count+2)*F;
{ B } F:=F*(Count+2);
```

A: `+00 add eax,2; +03 imul eax,[edx]; +06 mov [edx],eax`.
B: `+00 mov ecx,[edx]; +02 add eax,2; +05 imul ecx,eax;
+08 mov [edx],ecx`.
O- also swaps the field load and Count addition.
`r3_multiply_order`, using fields in `F:=(G+2)*F` versus `F:=F*(G+2)`, is
**same code in both modes**. The worker's register-local Count is significant;
K24's equivalent doubling examples are unchanged as well.

### K49. Eight-byte storage for a six-byte packed local

Report: `mr6.md`. Function: `TTacticalCombatUnitHS.CanMoveOn`, whose two
TAbilityCombatInfo values needed slots at `-$20/-$28` in the full method.

**r3_packed_storage: O+: different; O-: different; O- Q+ R+: different.**

```pascal
type TInfo=packed record Bytes:array[0..5] of Byte end;
{ A locals } X,Y:Integer; A,B:TInfo;
{ B locals } X,Y:Integer;
  A,B:record case Integer of
    0:(Data:TInfo); 1:(Align:array[0..1] of Integer);
  end;
{ A } Fill(A); Fill(B);
{ B } Fill(A.Data); Fill(B.Data);
```

Fill takes `var I:TInfo` and writes I.Bytes[0]. A reserves $0C under O+ and
passes `esp`, then `esp+6`; B reserves $10 and passes `esp`, then `esp+8`.
Under O- A passes `+09 lea eax,[ebp-6]`, `+11 lea eax,[ebp-0c]`;
B passes `[ebp-8]`, `[ebp-10]`. Checked results keep those locations.
This confirms the slot-size/spacing mechanism, without claiming those small
probes reproduce the full method's absolute offsets.

The overlay has **size eight and four-byte alignment**, not an eight-byte
alignment guarantee. It preserves the six-byte Data representation and var
parameter type. A 24-byte array declared before these locals
(`r3_packed_positions`) does not get placed first in the O- frame: the packed
locals still occupy the preceding slots. Arbitrary padding declarations are
not a reliable way to choose an exact address.

### K50. A Pointer temporary removes the Self copy before FS setup

Report: `mr6.md`. Function: `TEngine.GetEClass`.

**r3_pointer_result: O+: different; O-: different.** TObj has P:TObj at +4;
Find(X) is virtual and returns Pointer. Run returns TClass:

```pascal
{ A }
Result:=TClass(P.Find(X));
if Result=nil then raise Exception.Create(IntToStr(X));
{ B, Q:Pointer }
Q:=P.Find(X); Result:=TClass(Q);
if Result=nil then raise Exception.Create(IntToStr(X));
```

A: `+07 mov esi,edx; +09 mov ebx,eax; +0b xor eax,eax;
... +16 mov fs:[eax],esp; ... +1b mov eax,[ebx+4]`.
B: `+07 mov esi,edx; +09 xor edx,edx; ... +14 mov fs:[edx],esp;
... +19 mov eax,[eax+4]`.
B omits the Self copy into EBX; EBX is still saved because it later carries
the result. This combines K05's cast-result effect with a concrete managed-frame
carrier case beyond K21. Under O- the Pointer temporary has a real slot and no
optimized saved-Self conclusion follows.

### K51. Taking an otherwise unused parameter address still spills it

Report: `mr2.md`. Function: `TTextControlEditForm.SetText`.

**r3_parameter_address: O+: different; O-: different.** TObj has F:Integer,
P:TObj, virtual Work(X), and Run(Item:TObj). Both declare Saved:TObj:

```pascal
{ A }
Saved:=Item; P:=Saved;
if Saved<>nil then begin Saved.Work(F); Work(Item.F) end;
{ B also declares ItemPtr:Pointer; prefixes the same body with: }
ItemPtr:=@Item;
```

A: `+01 push esi; +02 mov esi,edx; ... +16 mov edx,[esi+4]`.
B: `+01 push ecx; +02 mov [esp],edx; ... +18 mov eax,[esp];
+1b mov edx,[eax+4]`.
No ItemPtr value is read, and no external call receives @Item, yet Item has
become addressable. O- also retains the address-taking instructions and
additional local allocation. K07's earlier address test passed the address to
a real call; that call is not required for this spill.

### K52. A separate search index plus removal of a result cast yields LEA

Report: `mr5.md`. Function: `TRelWindow.HighlightRace`.

**r3_index_local_lea: O+: different; O-: different.** TObj has L:TList at +4,
virtual Find(X):Integer, Run(X):TObject:

```pascal
{ A } Result:=TObject(L[Find(X)+36]);
{ B, I:Integer } I:=Find(X); Result:=L[I+36];
```

A saves EBX/ESI and after Find has `+0e mov edx,eax; +10 add edx,24`.
B saves EBX only and after Find has `+09 lea edx,[eax+24]`.
Both then load L and call the same `Classes.TList.Get`.
O- materializes I and also changes staging. This is a measured positive case
for K24's qualified LEA observation; the whole worker recipe has two changes.
K05 separately isolates a redundant cast on a call result. Do not infer that
any extra index local forces LEA.

### K53. A nil-result search loop has a different result lifetime

Report: `mr4.md`. Function: `TEventLogList.FindID`.

**r3_nil_search: O+: different; O-: different.** L:TList; objects have ID:Integer:

```pascal
{ A }
for I:=L.Count-1 downto 0 do
  if TObj(L.List^[I]).ID=ID then begin Result:=TObj(L.List^[I]); Exit end;
Result:=nil;
{ B }
I:=L.Count; Result:=nil;
while (I<>0) and (Result=nil) do begin
  Dec(I);
  if TObj(L.List^[I]).ID=ID then begin Result:=TObj(L.List^[I]); Break end;
end;
```

A starts with `+05 dec ecx; +06 cmp ecx,0; +09 jl +24`, returning the found
pointer directly in EAX. B adds an EDI save and `+06 xor esi,esi; +08 jmp +1d`;
its test is `+1d test ecx,ecx; +1f je +25; +21 test esi,esi; +23 je +0a`.
Success uses `+19 mov esi,edi; +1b jmp +25; ... +25 mov eax,esi`.
The result is explicitly live during B's loop. O- preserves its different
loop/Result-slot structure. This is the whole worker search recipe, not a claim
about changing Break alone; o05 covers that smaller experiment.

### K54. Stack arguments, including hidden results, frame assembler tails

Reports: `p2.md`, `p4.md`. Named example: `P2StatisticsToDV`, forwarding the
stack-argument call used by `TAbstractUnit.RetrieveDamageInfo`; p4 reports a
string-result forwarding adapter without naming that adapter.

**r3_asm_stack: O+: different; O-: different.** Target and Run have
`function (A,B,C,D:Integer):Integer`; Run is assembler:

```pascal
{ A } asm jmp Target end;
{ B } asm pop ebp; jmp Target end;
```

A: `+00 push ebp; +01 mov ebp,esp; +03 jmp Target`.
B: `+00 push ebp; +01 mov ebp,esp; +03 pop ebp; +04 jmp Target`.
The fourth argument requires an EBP frame even with W-. A forwards the wrong
stack shape; B removes the implicit frame before the jump. These code-only
probes were not executed.

**r3_asm_format: O+: different; O-: different.** Both signatures are
`function (const S:string; const Args:array of const):string`.
The same framing/jump evidence results: the hidden string destination is a
stack argument after S/data/high consume EAX/EDX/ECX.

Controls `r3_asm_string` (const S) and `r3_asm_string_value` (value S), each
with one string input and a string result, have no implicit frame in either
mode: A is just `+00 jmp Target`; B starts with an unjustified `pop ebp`.
A string result alone does not require that pop. K23's three-register-or-fewer
integer tail remains frame-free as well. Inspect the complete signature.

### K55. Callback destination scope changes the retained target register

Report: `mr6.md`. Function: `THSMapViewer.SetHSMap`.

**r3_callback_assign: O+: different; O-: different.** TMap has only
OnA/OnB/OnC:TNotifyEvent. TObj has P:TMap and its own Event(Sender:TObject):

```pascal
P:=Value;
{ A } if P<>nil then with P do begin OnA:=Event; OnB:=Event; OnC:=Event end;
{ B } if P<>nil then begin P.OnA:=Event; P.OnB:=Event; P.OnC:=Event end;
```

A: `+00 mov ecx,edx; +02 mov [eax+4],ecx; ... +09 mov edx,ecx;
+0b mov [edx+8],eax; +0e mov [edx+4],TObj.Event`.
B: `+00 push ebx; +01 mov ebx,edx; +03 mov [eax+4],ebx;
... +0a mov [ebx+8],eax; +0d mov [ebx+4],TObj.Event`.
The other two Code/Data pairs follow that pattern. B keeps the map in EBX and
restores it at +28; A uses EDX. O- has the respective hidden-with versus
repeated member loads. The distinct TMap type is deliberate: Event denotes
the viewer's handler in both forms, not a same-named destination method.

### K56. Doubling an index in place removes a temporary

Report: `mf1.md`. Function: `BltSpriteClipped16` (Gfxepack), which matches after the change.

```pascal
{ A } D := Pointer(Base + X * 2);
{ B } D := Pointer(Base); Inc(X, X); Inc(Integer(D), X);
```

B doubles the saved X in its own register and adds it to D, with no ECX temporary for `X * 2`.
The fourth-round audit now confirms the mechanism in `r4_inplace_blit`,
**different in O+ and O-**, with two descriptor parameters and a six-argument
blit call. A spills X at `+09 mov [ebp-4],ecx`, then doubles a copy with
`+2f mov ebx,[ebp-4]; +32 add ebx,ebx`. B keeps X in ECX and doubles it
with `+28 add ecx,ecx; +2a add esi,ecx`. Its local allocation shrinks from
8 to 4 bytes. The actual temporary register depends on context; the worker's
full method used ECX for the temporary that disappeared.

The minimal `r4_inplace_double` control, `function Run(Base,X:Integer):Pointer`
with just D and Result, is **same code O+**, different O-: both optimized
forms are `add edx,edx; add eax,edx; ret`. `r4_inplace_live` and
`r4_inplace_desc` retain additional uses/descriptors and differ in both modes.
These inputs/output are under `cx_cg3` (section 11). The source form was
already cataloged before that audit and is not counted as new there.

### Reported, not reproduced

These entries are not matching recipes. They retain the originating report and
the exact limit of the small test instead of promoting an unconfirmed detail
to a compiler guarantee.

**NR01. SmallInt casts alone did not reproduce repeated overlay loads.**
Report: `mr4.md`, `TCrop.TerrainChanged`. The successful worker recipe combined
destruction predicates, direct inherited fields, and repeated SmallInt overlay
reads. Isolating its casts in `r3_smallint_memory` gives **same code** under
O+, O-, and O- Q+ R+:

```pascal
type TInfo=packed record Pad:Integer; Overlay:ShortInt end;
{ A } Result:=(Info.Overlay>=0) and (Info.Overlay<>4);
{ B } Result:=(SmallInt(Info.Overlay)>=0) and (SmallInt(Info.Overlay)<>4);
```

Both O+: `+00 movsx edx,byte ptr [eax+4]; +04 test dx,dx;
+07 jl +0f; +09 cmp dx,4; +0d jne +12`.
Both O-: `+0c cmp byte ptr [eax+4],0; ... +15 movsx eax,byte ptr [eax+4];
+19 cmp ax,4`. The size-one const-record control `r3_smallint_overlay` is also
identical in both modes. This does not undo the worker's complete matched
rewrite; predicate combination is already covered by b03/b05 and K37.

**NR02. Unit qualification by itself did not force global reloads.**
Report: `mr1.md`, `TEarthMastery.ShowAnimation`,
`TEnchantedRoads.ShowAnimation`, `TTeleport.MapFieldMsgProc`,
`TWatcherHS.UpdateUnfog`. The report credits direct `AoWE.AoWHSMap` reads.
The narrow reading that adding only a unit qualifier forces reloads was not
reproduced:

```pascal
{ r3_global_qualifier A } Obj.P.Put(Obj.F,Obj.G);
{ B } ProbeUnit.Obj.P.Put(ProbeUnit.Obj.F,ProbeUnit.Obj.G);
```

**Same code, both modes.** Both O+ load Obj at +01/+09/+11 before the call.
`r3_import_qualifier`, `Screen.Width+Screen.Height` versus
`Forms.Screen.Width+Forms.Screen.Height`, also agrees in both modes, including
the two-step import-cell loads at +01/+06 and +0F/+14 under O+.
`r3_global_with` (`with Obj do P.Put(F,G)` versus direct qualified members)
is another same-code control in both modes.

The related, already documented mechanism **does** reproduce in
`r3_global_direct`: a named `O:=Obj` retains O in EBX through Get, while direct
qualified reads reload Obj before and after Get. O+ cached:
`+01 mov ebx,[Obj]; ... +0f call [ecx]; +11 add eax,[ebx+4]`;
direct: `+00 mov eax,[Obj]; +08 mov eax,[Obj]; ... +12 call [ecx];
+14 mov edx,[Obj]; +1a add eax,[edx+4]`. This is K02, not a special property
of the unit-name spelling. Qualification can also resolve a different symbol;
that is an address-identity correction, as in the rf reports.

**NR03. A reported method-address typed-constant rejection was not localized.**
Report: `p6c.md`, adapters for `TFlagEvent.UpdateInstantTrigger` and
`TFlagEvent.UpdateNewTurnTrigger`. The report omits the rejected constant's
complete type and initializer. In `r3_method_constant`, a nonvirtual
Work(Sender:TObject) supports:

```pascal
{ A } const MethodCode:Pointer=@TObj.Work;
      { Run returns MethodCode. }
{ B } E:=O.Work; Result:=TMethod(E).Code; { E:TNotifyEvent local }
```

Both compile in O+ and O-. A returns `+00 mov eax,[constant cell]; +05 ret`;
B forms the Code/Data local (`+06 mov [ebp-4],eax;
+09 mov [ebp-8],TObj.Work`). These controls do not reproduce the rejection or
justify a rule that Delphi 3 rejects all method-address constants. They do not
test every method-pointer constant type, virtual method or imported initializer.

**NR04. C1820 on an unspecified call variant was not reproduced.**
Report: `p5.md`, the recovered negotiation group containing
`CreateNegotiateTE`; the exact failing call was not recorded.
`r3_c1820_control` checks these small class-reference constructor forms:

```pascal
{ A } Result:=Find(A).Create(B);
{ B, C:TObjClass } C:=Find(A); Result:=C.Create(B);
```

Both compile in both modes, with no C1820. O+ A saves EBX/ESI and passes B from
ESI to ECX before TObj.Create; B saves only EBX and passes it to ECX. This is
K05's distinction. The generic control cannot stand in for the missing failing
variant, so no C1820 trigger is claimed.

### Existing mechanisms found again in the reports

These **27** rows are the already-present count. Several reports contribute to
one row; several rows can describe one successful rewrite. Routine mismatch
counts, ordinary behavioral fixes and comparison-tool artifacts are not counted
as new forms. Later mr reports sometimes give more precise recipes than an
earlier near-miss report's register-only explanation.

| Existing mechanism | Report examples and function where it mattered | Catalog evidence |
|---|---|---|
| Invert a condition and exchange physical branches | `mr2`: ShowProductionInfo, TRelWindow.P1CBPreDraw; `mr3`: ShowTrail<TfxHS.Show, TCAbTouchMoveTE.LastMove; `mr5`: TFileDlgWindow.FileLBChange | b01 |
| Preserve source order of case bodies | `cf2`: TMainForm.PlayInterfaceSound, TGeneral.PlayButtonSound; `cf3`: Color2PixelInfo | c01/c02 |
| Named copies, declaration order and split expressions change staging | `mr1`: TAbstractUnit.ExecuteDamageRole; `mr5`: TArmyEventDlg.DrawUnits centered origin | l02/l04, e03 |
| Cache a field or product across calls | `mr1`: TUnitIndexListCollection.DeleteUnit, caching stride and delete index | l01, K01 |
| Direct members versus receiver locals/with | `mr1`: TDefaultMEC.CalculateMoves; `mr4`: TSetupControl.Create, TSpellCC.GetName, TStructure.GetRebuildInfo; `mr5`: TItemEditForm.UpdateControls, TArmyEventDlg.DrawUnits | e01, K03/K04 |
| A redundant Self cast changes allocation | `mr5`: TFileDlgWindow.FileLBChange | e10 |
| Global value snapshot versus repeated cell reads | `mr1`: the four map-global rewrites in NR02; `mr2`: TProductionScreen.ShowPlace's retained center and reloaded Y receiver | K02 |
| Explicit receiver/argument assignments set staging order | `mr4`: TArmyCombineMoveTE.CanMoveNext | e05, K04 |
| Separate Boolean decisions materialize a value | `mr4`: THeroJoinEventLog.Execute, THeroUpgradeEventLog.Execute (with receiver, uncast FindUnit result, subsequent cast, separate popup decision) | b06, K05/K37 |
| Explicit pointer arithmetic versus typed stepping | `mr1`: TEnchantedRoads.ShowAnimation | K29 |
| String temporaries change destinations/lifetimes | `er4`: TSendEmailGameDlg.ShowSendDialog | K10 |
| Resourcestrings versus literals/cells | `nm11`: TDispelMagic.Create/ExecuteSpell, TPlayerComboBox.GenerateItems; `er1`/`er2`: assertion text | K13 |
| Class versus instance receivers | `er2`: TCommandAbility.Command; `nm1`: TAbstractUnit.ReadWrite | K15 |
| Exact True versus a nonzero Boolean test | `er4`: TMultiWindow.JoinBtnClick | K27 |
| Signedness and narrow parameter/result width | `nm2`: TCombat.DefendersAvailable, TFastCombat.ExecuteCombatRound; `nm6`: combat/player comparisons; `nm21`: GetUpkeep; `er4`: UpdateScenarioRow | section 5, K27 |
| Mask timing and overflow-sensitive guards | `er4`: TUnitSelectionDlg.DrawUnit, TArmyInfoDlg.DrawUnit, TUnitWindow.ShowUnit | K28 |
| Unsigned open-array high test | `er6`: SortStringsEx | K18 |
| Checked class cast versus hard cast | `nm15`: TCityAIPA.UpgradeCity/FortifyCity; `nm19`: TMainForm.ApplicationShowHint | K33 |
| Consuming versus reraising exceptions and handler shape | `er2`: TAIMoveExecuterMove.Destroy; `er6`: TCompareStorageStream.rwCreateEObject; `nm20`: TAdjacentMEC.CalculateMoves | K20 |
| Assertion filename/line and include position | `al2`, `relayout`, `er1`, `er2`, `er6`: named assertion repairs, including THSMap.UnlockTerrainChangedEvent | K22 |
| Checked getter calls versus direct backing storage | `nm1`: TAbilityTypeList.GetAbility; `er2`: TAIMoveTargetSelector.ProcessStates; `er3`: TSmokeCloud.UpdateConcealment's cached terrain list | K32, K02 |
| Calling convention controls stack order | `nm11`: BltColumn changed to pascal | K17 |
| Const versus value record copy/ABI | `g1`: TConstructionResourceEditForm.vmt98; `t1c`: TAnimation.SetDimensions | k03, K08 |
| String Pointer/PChar/index conversions | `er5`: CopyStreamToClipboard | K12 |
| Uninitialized results/stack bytes remain observable | `er5`: TestQWordAligned/TestDWordAligned/TestWordAligned/TestMissAligned; `er6`: THSMEdit.UpdateMouseCoordinates; `nm9`: TAbility.CanActivate | K30 |
| Constructor/destructor declaration and hidden flags | `i2`: resource form vmt80 constructors; `nm13`: TAoWMapEditForm.vmt90, TAoWResourceEditForm.Destroy | K16 |
| Set Include versus constructing a defined set | `nm16`: THeroEditForm.SetHero | K26, K30 |

Additional small controls preserve context for the already-covered rows. They
are in the same inputs/results inventory:

* `r3_subtract_local`: naming `F-Sender.Get(G)` before Put adds
  `push eax; mov eax,[ebx+4]; pop edx; sub eax,edx` instead of the inline
  `mov edx,[ebx+4]; sub edx,eax`; different in both modes.
* `r3_product_cache`: two inline F*G products have two IMULs around Put; named
  Offset/Index retains the product in ESI and has one IMUL; different in both.
  Retaining a product across a call needs the same field-stability proof as
  l01; a byte match alone does not supply it.
* `r3_center_local`: retaining P for only one of two Get expressions adds
  `mov esi,[ebx+14]` before the calls while the other receiver is reloaded;
  different in both modes.
* `r3_separate_receivers`: separate S:=P and T:=Sender.P assignments move
  `mov edx,[edx+14]` before `mov ecx,ff` rather than after it; different in both.
* `r3_direct_members`/`r3_destination_with`: direct P.F/P.G arguments save ESI
  and load P into ESI; with uses EAX and omits that save; different in both
  modes. Removing with does not always reduce the save set.
* `r3_output_members`: `with R do begin Cost:=Gold; Time:=Days end` versus
  explicit R.Gold/R.Days changes the retained receiver and adds an ESI save
  under O+; O- also differs. This preserves the TStructure.GetRebuildInfo kind.

Integration/build-only reports and the remaining recovery summaries add no
further concrete source-pair mechanism. The rf/rv/cf reviews also document
wrong symbol identities, missing parameters, incorrect constants, omitted
branches and signature extents. Their corrections must not be replaced by
code-shape tricks; section 9's comparison-artifact qualification still applies.

### Probe correction during this audit

`dcc_probe.py` previously passed **every** named routine to the flow graph as
if it were an RTL exception handler. The shared graph deliberately follows the
instruction after an exception-handler jump. An ordinary assembler `jmp Target`
therefore made its unreachable compiler epilogue appear in the probe output.
The probe now supplies only `@Handle...` symbols in that map; no shared
comparison tool was changed.

The framing evidence in K54 now ends at the tail jump. The separate
`inputs\probe_handler_regression.pas` build verifies that ordinary local branches,
`@HandleOnException` and its `.handlers ADDR:55` target, managed string cleanup,
and `@HandleFinally` continuations are still printed. Its full output is
`probe_handler_regression.txt`. The corrected probe is 118 lines. All 182 paired
builds in this round use the correction; all compiler outputs remain on D:.

## 11. Rewrite-report audit (fourth round)

Read **all nine complete reports** in `D:\Build\tmp\cx_cg3\reports` on
2026-10-23, including their bodies and restored trials. Report names in this
section refer to that directory, not section 10's older reports with the same
names. `report_audit.tsv` records every report's SHA256 and disposition.

**19 new forms: 17 confirmed, 2 reported, not reproduced in full; 22 already
present mechanisms.** The 17 comprise K57..K71 and the refinements to K27
(enum local) and K40 (Boolean) above. Counts deduplicate the same form across
reports/functions; a single rewrite can use several forms. NR05/NR06 retain
partial positive results without claiming the reported spill/FS effects.
Already-present forms are enumerated in the final table below. A failed full
match, a signature/address artifact, or an unspecified variant is not another
source form; concrete code-changing restored trials are included.

| Report read in full | Findings accounted for here |
|---|---|
| mf1.md | K69; existing parameter/set forms, K43 and K56 (now probed) |
| mf2.md | Existing Pointer argument casts, Sender locals and comparison order |
| mr4.md | Existing receiver/decision staging, search loop and NR01 overlay claim |
| mr5.md | Existing DrawUnits, FileLBChange, HighlightRace, HeroInfoClick and UpdateControls forms |
| mr6.md | Existing K49, K50 and K55; no additional concrete form in the leftovers |
| rw1.md | K57, K59..K63, including the restored ProcessHexagon arithmetic trial |
| rw2.md | K61, K64..K66, K69/K70; existing owner paths/Self casts; LoadBMP trial retained as evidence |
| rw3.md | K67/K68, Boolean extension of K40, NR05; existing named receiver/bounds |
| rw4.md | K58/K61/K71, enum extension of K27, NR06; existing cast-result, component, Self, global-cell and packed-storage forms |

There are **32 plain source pairs, 64 pair/switch configurations, 128 retained
successful builds**, all through `tools/dcc_probe.py` with the setup's switches,
once O+ and once O-. Controls and refinements of already-present entries are
included in those totals. The compiler SHA256 still agrees with the setup.
Nothing was executed. No game copy, additional probe tool or scratch script
was created; `dcc_probe.py` needed no change.

Inputs are `cx_cg3\inputs\r4_<name>_<side>.pas`; generated files and full
printed disassembly are `cx_cg3\r4_<name>_<side>_<mode>\` and the sibling
`.txt`, respectively. Side is a/b; mode is opt/noopt.
`worker_probe_results.json` records sources, commands, compile status and full
outputs; `pair_summary.json` records pair outcomes. For example:

```powershell
python -B tools/dcc_probe.py D:\Build\tmp\cx_cg3\inputs\r4_self_set_b.pas `
  --out D:\Build\tmp\cx_cg3\reprobe -- TObj.Run
```

Unless an entry supplies another declaration, its TObj has F/G:Integer,
B:Boolean, P:TObj at `$04/$08/$0C/$10`; virtual Get(X):Integer,
Find(X):TObj and Put(X,Y:Integer), followed by Run(Sender:TObj; X:Integer).
Get returns F+X, Find returns P, Put assigns F:=X+Y. Tick and Sink update
Global as in earlier sections. Complete declarations are in each input.
Instruction offsets are hexadecimal. Evidence confirms the small source pair,
not every register or the complete original function's address identities.

### K57. An eliminated self assignment still changes allocation

Report: `rw1.md`. Function: `TAbstractUnit.ExecuteDamageEffects`. Also retained
in TCity.MoveArmiesOutOfCity, TUnitHS.SetUnitGFXResourceIndex,
TAoWHSMap.Select, TTurnUndeadAbility.CreateTurnUndeadCA and other rw1 rewrites.

**r4_self_set: O+: different; O-: different.** TS=set of 0..9; Immune returns
TS, Expand(X) returns Boolean:

```pascal
Result:=[]; Active:=D-Immune;
{ A } { no assignment }
{ B } Active:=Active;
if Active<>[] then begin
  if (4 in Active) and Expand(96) then Result:=Result+[4];
  if (5 in Active) and Expand(93) then Result:=Result+[5];
  if (6 in Active) and Expand(98) then Result:=Result+[6];
end;
```

A: `+08 mov ebx,eax; ... +17 mov esi,eax; +19 not esi;
+1b and si,[esp]; ... +2a test si,10`.
B: `+08 mov esi,eax; ... +17 mov ebx,eax; +19 not ebx;
+1b and bx,[esp]; ... +2a test bl,10`.
The same word-sized set gets byte membership tests after the allocation swap;
there is no instruction for `Active:=Active` under O+. O- retains a real
load/store of Active. This refines K30: removing the assignment's instructions
does not undo its effect on the register candidates.

The simpler `r4_self_assign` prefixes a call-heavy method with
`Sender:=Sender` and is **same code O+**, different O-. An identity assignment
does not universally change allocation.

### K58. A Pointer-cast identity assignment exchanges Self and Sender

Report: `rw4.md`. Functions: `TArmyInfoDlg.U1MouseDown`,
`THeroInfoDlg.U1MouseDown`. This differs from K39's extra Sender local.

**r4_sender_cast: O+: different; O-: different.** Run receives Sender:TObject:

```pascal
{ A } { no assignment }
{ B } Sender:=TObject(Pointer(Sender));
if TObj(Sender).F<P.Get(X) then begin
  P.Put(TObj(Sender).F,X); TObj(Sender).Put(F,G);
end;
```

A: `+06 mov esi,edx; +08 mov ebx,eax; ... +0c mov eax,[ebx+10]`.
B: `+06 mov ebx,edx; +08 mov esi,eax; ... +0c mov eax,[esi+10]`.
The optimized streams have the same instruction count and positions, but
Self/Sender exchange EBX/ESI; no conversion or extra assignment remains.
O- instead adds `+10 mov eax,[ebp-8]; +13 mov [ebp-8],eax`.
This extends e10's cast-sensitive allocation to an assignment to the parameter.

### K59. Reusing a consumed parameter changes its next lifetime

Report: `rw1.md`. Functions: THolyGround.NewFrameSummonAnimation,
TUnHolyGround.NewFrameSummonAnimation, TPoisonPlant.NewFrameSummonAnimation,
TRaisedMountain.NewFrameRaiseTerrainAnimation; TArmy.GetUnitConcealedForPlayer
similarly reuses Index for a selected unit pointer.

**r4_reuse_param: O+: different; O-: different.** Both declare Q:TObj:

```pascal
{ A }
Q:=P.Find(Sender.Get(X));
if (Q.Find(X)=Self) and (X=9) then F:=0;
{ B }
Sender:=P.Find(Sender.Get(X));
if (Sender.Find(X)=Self) and (X=9) then F:=0;
```

A saves X in ESI and Sender/Q in EDI:
`+03 mov esi,ecx; +05 mov edi,edx; ... +1b mov edi,eax`.
B saves X in EDI and the reused Sender in ESI:
`+03 mov edi,ecx; +05 mov esi,edx; ... +1b mov esi,eax`.
O- writes the found object to Q's slot versus the incoming Sender slot.
The old parameter value must have no later use; the Index recipe also relies
on Delphi 3's 32-bit Integer/Pointer representation.

### K60. Splitting successive object generations can remove a save

Report: `rw1.md`. Function: `TAoWCampaignTransferSettings.Retrieve`, which
uses CopyItem for a copied Item. The report's lifetime splits also include
TUnitHS.SetUnitGFXResourceIndex's Old and TArmy.IncommingNegotiateOffer's Side.

**r4_split_generation: O+: different; O-: different.** A declares Q:TObj;
B declares Q,C:TObj:

```pascal
Q:=Sender;
{ A } if Q<>nil then begin Q:=Q.Find(X); Q.Put(F,G); Q.F:=X end;
{ B } if Q<>nil then begin C:=Q.Find(X); C.Put(F,G); C.F:=X end;
```

A saves EBX/ESI/EDI and spills incoming Sender:
`+06 mov [esp],edx; +0b mov ebx,[esp]; ... +1b mov ebx,eax`.
B saves only EBX/ESI, spills X instead, and calls Find with incoming EAX:
`+03 mov [esp],ecx; ... +08 mov eax,edx; ... +16 mov esi,eax`.
O- adds the distinct C slot. More declared locals can reduce optimized saves;
this is a concrete nonoverlapping-generation refinement of l02/l03/K03.

### K61. Unused address-taking spills Boolean locals and loop indexes

Reports: `rw1.md`, `rw2.md`, `rw4.md`. Functions:
TEmailGameControl.ValidateIncommingGame, TTransportMEC.UpdateTransportMeetingPoint,
TMapField.DestroyLevelHS, THSMEdit.MouseDown, TMapObjectResourceList.FindMOR,
TPlugInControl.InitializePlugIns. This extends K51 from an incoming parameter
to locals; rw2's `@Self` is already a parameter case.

**r4_bool_address: O+: different; O-: different.** Both declare Flag:Boolean;
B also declares Spill:Pointer:

```pascal
{ A } { no address-taking }
{ B } Spill:=@Flag; { Spill is never read. }
Flag:=X>F; Sink(X); if Flag then Sender.Put(F,G);
```

A: `+0a setg bl; ... +14 test bl,bl`.
B: `+02 push ecx; ... +0a setg byte ptr [esp];
... +15 cmp byte ptr [esp],0`.
There is no LEA or stored Spill value under O+, but Flag is addressable.
O- retains `+10 lea eax,[ebp-0d]; +13 mov [ebp-14],eax` as well as Flag's slot.

`r4_string_index_address` isolates `IndexAddress:=@I` in a string-list loop:
A has `+2d xor esi,esi; ... +8c inc esi`; B has
`+31 mov [ebp-4],0; ... +97 inc dword ptr [ebp-4]`.
It differs in both modes. Inline-string cleanup is measured separately in
K71; neither the pointer assignment nor inlining alone explains both effects.

### K62. Repeated addition changes a doubled-coordinate expression

Report: `rw1.md`. Function: `TArmyHS.ShowEnchantments`.

**r4_double_add: O+: different; O-: different.**

```pascal
{ A } Result:=(X+Y*2) shr 4;
{ B } Result:=(X+Y+Y) shr 4;
```

A: `+00 add edx,edx; +02 add eax,edx; +04 shr eax,4`.
B: `+00 lea eax,[edx+eax]; +03 add edx,eax; +05 shr edx,4;
+08 mov eax,edx`.
`r4_double_live`, passing the coordinate and original X/Y to Put, also differs
in both modes; B uses `lea ecx,[edx+eax]; add ecx,edx`. The worker described
A as a scaled LEA in the larger method; these small A controls use ADD/ADD.
The reproducible rule is the changed sequence and destination, not a universal
scaled-LEA promise. K24's same-code isolated `2*(A-B)` controls still stand.

### K63. A cancelling constant pair survives as DEC plus ADD

Report: `rw1.md`. Function: `TMoveControl.ProcessHexagon`; the trial changed
code but did not produce the complete match and was restored.

**r4_dec_add: O+: different; O-: different.**

```pascal
{ A } Result:=N+$FF;
{ B } Result:=N-1+$100;
```

A: `+00 add eax,ff; +05 ret`.
B: `+00 dec eax; +01 add eax,100; +06 ret`.
O- also retains DEC followed by ADD. This refines K24's constant-reassociation
controls: this spelling is not folded to the single ADD. The test uses Q-;
with checked arithmetic intermediate overflow would require separate analysis.

### K64. Repeating a difference retains its input call result

Report: `rw2.md`. Functions: `TestQWordAligned`, `TestDWordAligned`,
`TestWordAligned`, `TestMissAligned`.

**r4_difference_dead: O+: different; O-: different.**

```pascal
Stop:=Tick;
{ A, Time:Integer } Time:=Stop-Start; if Time<Best then Best:=Time;
{ B } if Stop-Start<Best then Best:=Stop-Start;
Result:=Best;
```

A after Tick: `+0b sub eax,esi; +0d cmp ebx,eax; ... +11 mov ebx,eax`.
B: `+0b mov edx,eax; +0d sub edx,esi; +0f cmp ebx,edx;
... +13 mov ebx,edx`.
B keeps Stop in EAX and computes the difference once in EDX; writing it twice
does not force two SUBs. O- stores/loads Time in A and recomputes the difference
on B's taken path. In `r4_repeat_difference`, adding Stop to the final result
keeps Stop live in both forms: only Start/Best's saved-register allocation
changes under O+. This is expression-lifetime information beyond l01 caching.

### K65. Overwriting a consumed width changes the blit allocation

Report: `rw2.md`. Function: `BltSDRectClipped`.

**r4_width_clipped: O+: different; O-: different.** The small clipped-rectangle
probe uses two const descriptors, a by-value TRect, and the same six-argument
Blt in both forms. W is first assigned Right-Left and clipped before this:

```pascal
{ A, Bytes:Integer }
Bytes:=(Src.Bits*W) shr 3;
{ compute S and D }
Blt(S,D,Src.Pitch,Dst.Pitch,Bytes,H);
{ B, no Bytes local }
W:=(Src.Bits*W) shr 3;
{ same computation of S and D }
Blt(S,D,Src.Pitch,Dst.Pitch,W,H);
```

A keeps pixel width in ESI, then spills byte width:
`+90 imul ebx,esi; +93 shr ebx,3; +96 mov [ebp-8],ebx;
... +cc mov ecx,[ebp-8]; +cf push ecx`.
B carries both successive widths in EDX:
`+90 imul ebx,edx; +93 shr ebx,3; +96 mov edx,ebx; ... +ce push edx`.
B spills S instead, so both small O+ frames reserve $18; the worker's full
method shrank $20 to $18. O- here shrinks $30 to $2C when Bytes is removed.
`r4_reuse_width`, using a parameter and simpler pointer calls, is **same code
O+**, different O-. Width reuse is a scheduling option, not a fixed frame-size
saving, and no later expression may require the old pixel width.

### K66. A short-lived source avoids storing through an addressable pointer

Report: `rw2.md`. Function: `LoadBMP`, Move paths; partial improvement,
restored because the complete function still did not match.

**r4_move_source: O+: different; O-: different.** Run(S,D:Pointer; N:Integer)
first calls ReadPointer(var P:Pointer) on S, making S addressable in both forms:

```pascal
ReadPointer(S);
{ A } S:=Pointer(Integer(S)+N); Move(S^,D^,N);
{ B, SourcePtr:Pointer }
SourcePtr:=Pointer(Integer(S)+N); Move(SourcePtr^,D^,N);
```

A: `+14 add eax,ebx; +16 mov [esp],eax; +19 mov edx,esi;
+1b mov eax,[esp]; +1e mov ecx,ebx; +20 call System.Move`.
B: `+14 add eax,ebx; +16 mov edx,esi; +18 mov ecx,ebx;
+1a call System.Move`.
S still has its original addressable slot in B; the computed source does not
pass through it. O- gives SourcePtr its own real slot instead. This is more
specific than K07's address-taking: it separates an addressable variable from
an expression that only needs a register. S's updated value must be dead.

### K67. Even unused absolute views force addressable storage

Report: `rw3.md`. Functions: `TSprite16.GrabImage`, `TAOWMemo.CheckMouseUp`,
`TAOWMenu.CheckMouseMove`.

**r4_absolute_local: O+: different; O-: different.** Both have Q:TObj;
I:Integer; only B adds `QA:TObj absolute Q`, without reading QA:

```pascal
Q:=Sender; I:=X+1; Sink(I); Q.Put(I,F); Q.F:=G;
```

A: `+05 mov esi,edx; +07 lea edi,[ecx+1]; ... +16 mov eax,esi`.
B: `+00 push ebp; +01 mov ebp,esp; +03 add esp,-8;
+08 mov [ebp-8],ecx; +0d mov [ebp-4],edx; ... +20 mov eax,[ebp-4]`.
Q loses register promotion, and an EBP frame is introduced even though QA is
unused. O- also changes local/parameter slot allocation. This is not l05's
ordinary unused local, which disappears completely under O+.

**r4_absolute_record: O+: different; O-: different.** With a filled local
R:TRect, A computes `A:=R.Right-R.Left; B:=R.Bottom-R.Top; Put(A,B,R.Left)`.
B adds `G:TRect absolute R` and reads G.Top/G.Left at the last two sites.
A uses ESP-relative R: `+00 add esp,-10; ... +0f mov ecx,[esp]`.
B introduces EBP: `+00 push ebp; +01 mov ebp,esp; +03 add esp,-10;
... +12 mov ecx,[ebp-10]`. Both still reuse the first Left load; a record
alias does not universally force another field read.

### K68. Absolute-view declaration order changes early stack slots

Report: `rw3.md`. Functions: `TSprite16.GrabImage`, `TAOWMemo.CheckMouseUp`,
`TAOWMenu.CheckMouseMove`; the order is significant in addition to addressability.

**r4_absolute_order: O+: different; O-: different.** Same Q/I/body as K67,
with no alias reads; only alias declaration order changes:

```pascal
{ A }
SA:TObj absolute Self; XA:Integer absolute X; QA:TObj absolute Q;
{ B }
QA:TObj absolute Q; XA:Integer absolute X; SA:TObj absolute Self;
```

Both reserve $0C under O+ and store X at `[ebp-8]`. A:
`+0a mov [ebp-4],eax; +0d mov [ebp-0c],edx` (Self, then Q).
B: `+0a mov [ebp-0c],eax; +0d mov [ebp-4],edx`.
O- also exchanges Self/Q's slots, retaining X at -8 and I at -$14.
Unlike ordinary local reordering in l04, the main declarations and body are
unchanged: the alias declarations themselves request the early allocations.

### K69. A Pointer view changes member-load order inside an equality

Reports: `mf1.md`, `rw2.md`. Functions: `TTerrainMO.FindDecorationResource`,
`TTerrainMO.FindTerrainResource`, `TTerrainMO.ClearTerrain`. This refines K44:
the effect also occurs in a comparison, without an argument getter or a call
between the compared reads; it is not K46's across-call receiver retention.

**r4_pointer_equality: O+: different; O-: different.**

```pascal
if (Sender.F=P.F) and
  { A } (Sender.G=P.G) then Sender.Put(F,G);
  { B } (TObj(Pointer(Sender)).G=P.G) then Sender.Put(F,G);
```

Both initially load P to ECX. A: `+0c mov ecx,[ecx+8];
+0f cmp ecx,[edx+8]`. B: `+0c mov ebx,[edx+8]; +0f cmp ebx,[ecx+8]`.
The materialized member and memory operand exchange sides; no cast instruction
is emitted. O- also reverses which member is loaded first. The worker also
reversed the source equality: `r4_equality_order`, A `(P.G=Sender.G)` against
B's Pointer-view form, reproduces the same distinction in both modes.

### K70. Assigning a stdcall result first changes argument scratch registers

Report: `rw2.md`. Function: `TWindows08DIBSurface.BltDC`.

**r4_stdcall_result: O+: different; O-: different.** Send is a five-Integer
stdcall function; Run receives DC:Integer and R:PRect:

```pascal
{ A }
if Send(DC,R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top)=R.Bottom-R.Top
then Result:=0 else Result:=-1;
{ B }
Result:=Send(DC,R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top);
if Result=R.Bottom-R.Top then Result:=0 else Result:=-1;
```

A saves EBX/ESI/EDI/EBP, then uses EAX to build the stack arguments:
`+08 mov eax,[ebx+0c]; +0b mov edi,[ebx+4]; +0e sub eax,edi; +10 push eax`.
B saves only EBX/ESI and keeps DC in EAX while building arguments in ECX:
`+04 mov ecx,[ebx+0c]; +07 mov esi,[ebx+4]; +0a sub ecx,esi; +0c push ecx`.
Both call the same Send with the same argument order and compare its return
value in EAX. O- materializes Result before the comparison in B. This localizes
`match.md`'s stdcall comparison observation; it is not a calling-convention
change or a different target.

### K71. Inlining strings packs cleanup around an active loop-count slot

Report: `rw4.md`. Function: `TPlugInControl.InitializePlugIns`. This refines
K09/K10: the change is cleanup grouping, beyond temporary destination order.

**r4_string_inline_only: O+: different; O-: different.** A declares S:string;
both have I:Integer and P:TPlug. Find(const S:string):TPlug returns Plug:

```pascal
for I:=0 to L.Count-1 do begin
  { A } S:=L[I]; P:=Find(S);
  { B } P:=Find(L[I]);
  if P<>nil then P.Init(E) else begin
    { A } S:='Missing ('+L[I]+')'; raise Exception.Create(S);
    { B } raise Exception.Create('Missing ('+L[I]+')');
  end;
end;
```

A has strings at `[ebp-4]` and `[ebp-0c]`, with the live hidden loop count at
`[ebp-8]`: `+9f lea eax,[ebp-0c]; +a2 call @LStrClr;
+a7 lea eax,[ebp-4]; +aa call @LStrClr`.
B has the count at `[ebp-4]` and adjacent hidden strings at -8/-$0C:
`+9f lea eax,[ebp-0c]; +a2 mov edx,2; +a7 call @LStrArrayClr`.
O- likewise changes two scalar clears into one array clear.

`r4_inline_strings` combines this with K61's unused `IndexAddress:=@I`, as
the worker did: it keeps I at -4 and strings at -$0C/-$10, still cleared by
one `LStrArrayClr`. `r4_string_index_address` keeps S and changes only the
index address-taking; its strings stay separated and need two `LStrClr`s.
K09's unused Integer-gap control does not contradict this: the loop-count
slot here is allocated and live, not an unused declaration.

### Reported, not reproduced

**NR05. Sharing the typed pixel pointer did not newly spill SD in the probes.**
Source: `rw3.md`, `TPicture16.GrabImage`. The worker reports that replacing
separate S/S24 pointers with shared S and PByteArray(S) casts spills SD and
changes pixel/counter registers; the complete function remained unmatched and
was restored.

```pascal
{ A, S:PWords; S24:PBytes }
S24:=PBytes(S);
for I:=0 to N-1 do begin Global:=S24^[0]; Inc(Integer(S24),3) end;
{ B }
for I:=0 to N-1 do begin Global:=PBytes(S)^[0]; Inc(Integer(S),3) end;
```

`r4_shared_pixel_ptr` is **different in O+ and O-**: A uses ECX for the pointer,
EAX for the count and DL for the byte; B uses EAX, EDX and CL. Thus allocation
sensitivity reproduces, but that control has no SD to spill.
The closer `r4_pixel_frame` adds const SD:TDesc, nested row/pixel loops,
Self.F, pitch/width reads and a Pixel call. Both O+ forms already spill SD
with `+05 mov [esp],edx`; both keep the pixel pointer in ESI and counters in
EBX/EBP. Only the initial pointer load loses a move. O- removes S24's separate
slot ($24 to $20 frame), which is not the reported optimized SD spill.
The exact descriptor-spill effect is therefore not a confirmed recipe.

**NR06. Reading restored FBuffer changed restore order, but not the FS zero register.**
Source: `rw4.md`, `TEWriteStorageStream.rwCreateEObject`, `rwEObject`,
`rwEObjectStream`. The three writer trials were restored after an address gate;
the report names an existing Exception-cell/VMT inconsistency. They are not
accepted address-clean game rewrites.

**r4_restored_field: O+: different; O-: different; FS-register change not reproduced.**
The small method saves Outer:=FBuffer, installs a new TMemoryStream, writes X,
then frees/restores it, with the same cleanup in an on-Exception handler:

```pascal
{ in the handler, both } FBuffer.Free; FBuffer:=Outer;
{ A } Outer.Position:=X;
{ B } FBuffer.Position:=X;
raise;
```

A: `+81 mov eax,[ebp-4]; +84 mov edx,[ebp-0c]; +87 mov [eax+4],edx;
+8a mov edx,[ebp-8]; +8d mov eax,[ebp-0c]`.
B: `+81 mov edx,[ebp-4]; +84 mov eax,[ebp-0c]; +87 mov [edx+4],eax;
+8a mov edx,[ebp-8]`, then both call the same TStream.SetPosition.
The restore/load scheduling effect reproduces: B already has the restored
pointer in EAX. However both start registration with `+2a xor edx,edx` and
install `fs:[edx]`; the reported FS zero-register change does not reproduce.
O- reloads the FBuffer field in B rather than using the Outer slot. This
partial result refines K01/K21 without promising a zero-register selector.

### Already-present forms in these reports

These **22 rows** are the already-present count, including the previously
unreproduced SmallInt claim. New refinements above are counted only as new.
This is a mechanism count, not a count of functions, trials or matching gains.

| Existing form | Reports and motivating functions | Catalog entry |
|---|---|---|
| Invert a condition / place success branch first | mr5: TFileDlgWindow.FileLBChange | b01 |
| Reverse comparison operands | mf2: TResultsWin.P1CBChange; rw1: TEmailGameControl.ValidateIncommingGame | b07 |
| Use a parameter directly, or introduce an ordinary named copy | mf1: TItemControlGrid.GetItem; rw4: TECustomResourceGrid.SetEComponent | l02 |
| Byte-sized set operations instead of integer masks | mf1: TMine.SetRazed | K26 |
| Zero shift schedules an index or receiver earlier | mf1: TAutoProduceAIPA.Process; mr5: TRealmWin.HeroInfoClick | K43 |
| Split pointer arithmetic and double the consumed index in place | mf1: BltSpriteClipped16 | K56, now snippet-confirmed |
| Cast through Pointer at argument member reads | mf2: THelpWindow.ShowHelpEvent | K44 |
| Copy Sender into a local | mf2: TResultsWin.P1CBChange, TScenSetup.RaceBehaviorCBChange, TWorldMap.PPawnMouseDown; mr5: FileLBChange | K39 |
| Cast Self, including a typed Self with | mr5: FileLBChange; rw2: TBorderHexagon.SetOwner; rw4: TDrawImageGrid.SetCellCount | e10 |
| Direct member paths versus locals/with/named receivers | mr4: TSetupControl.Create, TSpellCC.GetName, TStructure.GetRebuildInfo; mr5: DrawUnits/UpdateControls; rw2: GetShowPriority owner paths; rw3: TCustomImageLibrary.RemoveSub | e01, K03/K04 |
| Explicit source/receiver assignment order | mr4: TArmyCombineMoveTE.CanMoveNext | e05, K04 |
| Uncast result then cast, with a separate Boolean decision | mr4: THeroJoinEventLog.Execute, THeroUpgradeEventLog.Execute | b06, K05/K37 |
| Nil-result search loop with Break | mr4: TEventLogList.FindID | K53 |
| Combined predicate / repeated SmallInt overlay claim | mr4: TCrop.TerrainChanged | b03/b05, K37, NR01; still not a confirmed cast-only rule |
| Separate search index and remove result cast for LEA | mr5: TRelWindow.HighlightRace | K52 |
| Eight-byte variant storage for packed locals | mr6: TTacticalCombatUnitHS.CanMoveOn; rw4: TCombatUnitSelectionControl.UpdateMoveCursor | K49 |
| Pointer local before cast-result/FS setup | mr6: TEngine.GetEClass | K50 |
| Explicit callback destination fields instead of with | mr6: THSMapViewer.SetHSMap | K55 |
| Name a scalar call result before using it | rw4: TEReadStorageStream.rwBool | e03 |
| Read a global pointer through an inline cell view | rw4: TGeneral.SaveLayout | K45 |
| Separate a lookup's Pointer result from its result cast | rw4: TECopyComponent.GetEObject, GetEngine | K05 |
| Name rectangle bounds or a centered origin | mr5: TArmyEventDlg.DrawUnits; rw3: TSprite16.GrabImage | l02, e03, K01 |

The report bodies' remaining function lists describe unsuccessful classes of
trials, often without an exact pair or a claimed code effect. Their receiver,
local, case, record, loop and argument topics are already covered; they do not
establish additional forms. Reported comparison artifacts (including unresolved
indirect jumps, truncated signatures and address masking) remain tool/extent
issues, not compiler source-form rules.

## 12. Latest rewrite-report audit (fifth round)

Read **all five complete reports, rx1.md through rx5.md**, including their
bodies and New source forms sections, in `D:\Build\tmp\cx_cg4\reports`
on 2026-10-23. Report names in this section refer to that directory.
`cx_cg4\report_audit.tsv` records hashes and dispositions.

**7 new forms: 6 confirmed (K72..K77), 1 reported, not reproduced (NR07);
18 already-present form groups.** Counts deduplicate reports/functions and
include new refinements of existing entries. They count source mechanisms,
not matches or unsuccessful attempts. Generic lists of restored receiver,
slot, branch, managed-local and other trials give no additional concrete
source pair or successful code effect; they are accounted for by the existing
entries in the final table. Unresolved indirect jumps, signature extents and
address-check findings are comparison issues, not new source forms.

| Report read in full | Findings accounted for here |
|---|---|
| rx1.md | K72; existing identity assignments/casts, addressability, declaration order, branches and comparisons |
| rx2.md | K73/K74; existing receiver/cache, spill, comparison, constructor and zero-shift forms |
| rx3.md | K75; existing addressability, lookup-result casts, copies, local order, typed access, assertions and Boolean staging |
| rx4.md | K76/K77 and NR07; existing Self casts, zero shifts, dimension lifetimes and Sender/index staging |
| rx5.md | No new claim; existing split lifetimes, removal of with, self assignment and eight-byte overlay |

There are **10 plain paired test units, each built once O+ and once O-:
20 successful builds and 40 printed routine bodies**, including three
controls. Every build used `tools/dcc_probe.py` and the setup's switches;
the compiler SHA256 still agrees with the setup. Nothing was executed.
No game copy, scratch script or additional probe tool was created, and
`dcc_probe.py` needed no change.

Inputs are `cx_cg4\inputs\r5_<name>.pas`; each has A/B routines with the
same declarations except the stated change. Outputs are
`cx_cg4\r5_<name>_<mode>\`, with full printed disassembly in the sibling
`.txt`; mode is opt/noopt. `worker_probe_results.json` retains commands,
compile status and complete output; `pair_summary.json` records outcomes.
For example:

```powershell
python -B tools/dcc_probe.py D:\Build\tmp\cx_cg4\inputs\r5_selection.pas `
  --out D:\Build\tmp\cx_cg4\reprobe -- TObj.A TObj.B
```

Complete declarations are in those small inputs. Excerpts below are O+
unless stated; offsets are hexadecimal. The evidence establishes these
small source pairs, not the full worker functions or universal register choices.

### K72. A zero addition changes a byte memory operand into a separate load

Report: `rx1.md`. Function: `EncodeSecurityID`. This refines K24's
constant-expression controls: adding zero can disappear while still changing
the way its byte operand is evaluated. It is not an ordinary named copy.

**r5_byte_zero: O+: different; O-: different.** A/B receive Value:string
by value and Key:Byte, return string, and declare I:Integer:

```pascal
Result:='';
for I:=1 to Length(Value) do
  Result:=Result+Char(Byte((Length(Value)+(I+5)+
    { A } Key
    { B } Byte(Key+0)
  ) and $FF) xor Byte(Value[I]));
```

After the identical `+52 add al,5; +54 add dl,al`, A has
`+56 add dl,[ebp-5]; +59 and dl,ff`.
B has `+56 mov al,[ebp-5]; +59 add dl,al; +5b and dl,ff`.
There is no instruction adding zero, and no change to the string helper
identities. O- likewise splits `+5a add dl,[ebp-5]` into
`+5a mov al,[ebp-5]; +5d add dl,al`.

**r5_byte_cast: same code, both modes.** Replacing Key only with
`Byte(Key)` retains the memory ADD. The arithmetic expression inside the
cast, rather than the redundant Byte cast alone, is material under these
Q-/R- settings.

### K73. Naming a reused quotient removes its saved-register copy

Report: `rx2.md`. Function: `THero.LevelToExperience`. This refines l01/e03
and K25: the optimized repeated division is already computed once, but naming
its result changes allocation even without removing another IDIV.

**r5_quotient: O+: different; O-: different.** Tab:array[0..5] of Integer;
A/B(Level:Integer):Integer; both declare I,Total:Integer:

```pascal
Total:=0;
{ A }
for I:=1 to Level-1 do
  if I div 5<=5 then Inc(Total,Tab[I div 5]);
{ B, also Q:Integer }
for I:=1 to Level-1 do begin
  Q:=I div 5; if Q<=5 then Inc(Total,Tab[Q]);
end;
Result:=Total;
```

A: `+19 idiv esi; +1b mov esi,eax; +1d cmp esi,5;
+22 add edi,[Tab+esi*4]`.
B: `+19 idiv edi; +1b cmp eax,5; +20 add esi,[Tab+eax*4]`.
Both have one division per optimized iteration. The count/I/Total allocation
also changes from EBX/ECX/EDI to ECX/EBX/ESI; B still saves three registers.
O- A has two IDIVs on the taken path, at +29/+39; B has one at +29 and
stores Q at `[ebp-14]`. This is a reuse recipe, not a change in division
rounding or permission to cache a side-effecting expression.

### K74. Staging the first byte result changes Boolean materialization

Report: `rx2.md`. Function: `TCity.JoinAmount`. This refines e03 and K37:
both forms still use SETE, but the explicit byte local changes its destination
and the subsequent full-register copy.

**r5_selection: O+: different; O-: different.** TObj.One/Two are virtual
Byte functions, Sink is virtual, A/B return Boolean; Flag:Boolean:

```pascal
{ A } Flag:=One=Two;
{ B, Selection:Byte } Selection:=One; Flag:=Selection=Two;
if Flag then Sink;
Result:=Flag;
```

Both call One then Two and compare `+13 cmp bl,al`.
A: `+15 sete bl; +18 test bl,bl`.
B: `+15 sete al; +18 mov ebx,eax; +1a test bl,bl`.
The new copy is not zero extension: only the Boolean low byte is meaningful.
O- B instead stores Selection at `[ebp-7]` and compares
`+1b cmp al,[ebp-7]`; A retains One across Two in EBX and compares BL/AL.

### K75. An enum local removes an incoming byte spill before membership

Report: `rx3.md`. Function: the standalone `ValidAttackRelation`.
This extends K05's call-result staging and K27's enum-local control to set
membership and preservation of an incoming parameter.

**r5_enum_member: O+: different; O-: different.** A/B receive P,I,T,R:
ShortInt, with R on the stack; Relation returns
TRelation=(drPeace,drWar,drAlliance,drUnknown):

```pascal
if P=0 then
  if T<>0 then begin
    { A } Result:=Relation(P,I,T,R) in [drWar,drUnknown];
    { B, Rel:TRelation }
    Rel:=Relation(P,I,T,R); Result:=Rel in [drWar,drUnknown];
  end else Result:=False
else Result:=Map.Players.Get(P).Valid(T,R);
```

A spills I with `+08 mov [ebp-1],dl` and reloads it with
`+1e mov dl,[ebp-1]` before `+23 call Relation`.
B omits both instructions and calls Relation at +1D with incoming DL.
T remains spilled in both; the enum local itself has no optimized store.
Both membership tests use `sub al,1; je ...; sub al,2; je ...`.
O- keeps incoming I in `[ebp-2]` in both forms and adds Rel's actual
store/reload at `[ebp-5]` in B. The spill removal is an O+ observation,
not a different calling convention or set test.

### K76. Hard Sender casts prevent reuse of coordinate sums

Report: `rx4.md`. Functions: `TArenaDlg.MapViewDraw`,
`TDisjunctionDlg.MapViewDraw`. This refines e10/K44/K69: besides selecting
another address register, a class cast can separate repeated arithmetic
expressions within a call. No AsClass check is involved.

**r5_sender_coords: O+: different; O-: same code.** TObj has F/G/H/I:
Integer at +4/+8/+C/+10; TChild descends from it unchanged. Self.P:TObj;
Draw takes four const Integer arguments (the fourth on the stack):

```pascal
{ A }
Draw(P.F+Sender.F,P.G+Sender.G,
     P.F+Sender.F+Sender.H,P.G+Sender.G+Sender.I);
{ B }
Draw(P.F+TChild(Sender).F,P.G+TChild(Sender).G,
     P.F+TChild(Sender).F+TChild(Sender).H,
     P.G+TChild(Sender).G+TChild(Sender).I);
```

A computes P.G+Sender.G into EDI at +06/+09, reuses EDI at +0C/+1D,
and likewise keeps the F sum in ESI. B instead computes the G sum twice:
`+05 mov ebx,[ebx+8]; +08 add ebx,[edx+8]`, then
`+1a mov esi,[esi+8]; +1d add esi,[ecx+8]`.
It also computes the F sum twice, with another P load at +20. A saves
EBX/ESI/EDI; B saves EBX/ESI and copies Sender from EDX to ECX at +0B.
The cast emits no conversion. Both O- streams already recompute the sums
and agree completely. This is a same-object hard cast with the same inherited
field layout; an `as` cast or a getter with side effects is a different case.

### K77. Integer locals inside try change its entry zero register

Report: `rx4.md`. Function: `TGeneral.SortLists`. This refines K21:
both conversions are **inside** try, yet choosing their later destinations
changes FS registration before either call has run.

**r5_try_integers: O+: different; O-: different.** A/B are methods with
L:TStrings and I,J:Integer; Value is a global Integer:

```pascal
try
  { A } if StrToInt(L[I])>StrToInt(L[J]) then Value:=I;
  { B, X,Y:Integer }
  X:=StrToInt(L[I]); Y:=StrToInt(L[J]); if X>Y then Value:=I;
except
end;
```

Both have an outer string-temporary finalizer registered through EAX.
The explicit inner except registration changes:
A `+1a xor eax,eax; ... +22 push fs:[eax]; +25 mov fs:[eax],esp`;
B `+21 xor edx,edx; ... +29 push fs:[edx]; +2c mov fs:[edx],esp`.
A retains the first conversion with `+3c push eax` and compares
`+52 pop edx; +53 cmp edx,eax; +55 jle ...`.
B uses `+44 mov esi,eax`, then `+5b cmp eax,esi; +5d jge ...`.
Both still retrieve/convert I before J. B also spills I at `[ebp-4]`
and moves the hidden string from -4 to -8.

O- B stores X/Y at `[ebp-10/-14]`, while A retains the first result in
EBX. Both O- inner registrations use EAX, so the zero-register change
is specific to O+ here. Unlike NR06, this small pair reproduces the
reported FS effect without reading a restored object field.

### Reported, not reproduced

**NR07. Enum/Ord alone did not select the reported single AND EAX,7F.**
Source: `rx4.md`, `TArmyInfoDlg.DrawUnit` and `TUnitSelectionDlg.DrawUnit`.
The report claims that a Byte local plus `[Alignment and 127]` becomes an
enum local plus `[Ord(Alignment)]`, with one AND EAX,7F after the full-byte
guard. This is a new claim beyond K27's constructor-local and K28's mask
placement controls, but that exact mask effect did not reproduce.

**r5_enum_ord: O+: different; O-: different; reported mask not reproduced.**
TAlign=(a0,a1,a2,a3,a4,a5,a6), P.GetA returns TAlign, Lib.Count:Integer,
Lib.Get(Index:Integer):TObj:

```pascal
{ A, Alignment:Byte }
Alignment:=Byte(P.GetA);
if Alignment<Lib.Count then begin
  Q:=Lib.Get(Alignment and 127); Value:=Q.F;
end;
{ B, Alignment:TAlign }
Alignment:=P.GetA;
if Ord(Alignment)<Lib.Count then begin
  Q:=Lib.Get(Ord(Alignment)); Value:=Q.F;
end;
```

Both guards zero-extend all eight bits with XOR/MOV DL,AL before CMP.
A then emits `+19 mov edx,eax; +1b and dl,7f; +1e and edx,ff`.
B has **no AND** after its guard: `+16 mov eax,[Lib]; +1b call TLib.Get`;
the full-byte value remains in EDX. It also removes A's EBX save.
O- similarly zero-extends B's enum byte without a $7F mask.

`r5_enum_property` changes the lookup to a default indexed property using
the same getter; its complete disassembly agrees with r5_enum_ord in each
mode. `r5_enum_ord_mask` explicitly adds `and 127` to B's Ord expression:
O+ gives `+18 and dx,7f; +1c movsx edx,dx`, not the reported single
32-bit AND. These are partial allocation/width results, not confirmation
that Ord inserts the claimed mask. The report's exact lookup context
remains necessary; do not silently replace a full-byte index by a masked one.

### Already-present forms in these reports

These **18 rows** are the already-present count. Most body summaries name
successful kinds without the individual functions; the table preserves those
descriptions and does not attribute a success to a function in a restored list.
New refinements above are counted only as new.

| Existing form | Reports and body descriptions | Catalog entry |
|---|---|---|
| Identity assignment or Pointer-cast identity | rx1: identity assignments/casts; rx5: retain self-assignment | K57/K58 |
| Make a parameter/local addressable | rx1/rx3: address-taking; rx2: parameter spills | K07/K51/K61 |
| Reorder declarations | rx1/rx3: declaration order | l04/l07 |
| Change branch layout | rx1/rx2: branches | b01/b02/K37 |
| Reverse comparison operands | rx1/rx2: comparisons | b07 |
| Direct field/list receiver or remove with | rx2: direct field/list receivers; rx5: remove with | e01/K03/K04/K32 |
| Map/global access and caching | rx2: map access/cache forms | l01/K04/K45 |
| Add/remove an ordinary named copy | rx2: selection/relation temporaries; rx3: removing local copies; the new Boolean destination effect is K74 | l02/l03/e03 |
| Cast a lookup result or separate its cast | rx3: lookup-result casts | K05 |
| Inline a constructor receiver | rx2: inline constructor receiver | K05 |
| Typed object access and Self casts | rx3: typed object access; rx4: Self casts | e10/K04 |
| Zero-shift an argument | rx2/rx4: zero-shift arguments | K43 |
| Change dimension lifetimes | rx4: dimension lifetimes | l02/K60/K65 |
| Stage Sender or an index | rx4: Sender/index staging | K39/K52 |
| Explicit assertion immediates | rx3: assertion immediates | K22 |
| Stage a Boolean/event decision | rx3: Boolean/event staging | b06/e03/K37 |
| Separate successive value lifetimes | rx5: separate locals/lifetimes | K60 |
| Eight-byte storage for a packed local | rx5: eight-byte overlay | K49 |

Rx3's enum temporary and rx4's numeric locals are accounted for by K75 and
K77, respectively; repeated mentions in the body and New source forms section
are not extra forms. Rx4's two enum/Ord matches are one claim, NR07.
