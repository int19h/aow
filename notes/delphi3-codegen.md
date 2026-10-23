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

## Setup and how to reproduce

Experiments run on 2026-10-23 with `C:\Tools\Delphi3\BIN\DCC32.EXE`, SHA256
`2EEFE2C33C88E0BD466000C57F6B198088343D8E37DBA5042F0C3F2F824E8CEF`.
The compiler identifies itself as Delphi for Win32 Version 10.0. Nothing was executed.

The baseline from the switch sweep in [match.md](match.md) is
`O+ W- B- G+ A+ R- Q- Z1`. Every pair was also compiled with `O-`.
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
control flow checked as required by [near-miss.md](briefs/near-miss.md).
