# Identity records and incremental certificates (schema 1)

`equiv.py --data-alias FILE` explicitly loads reviewed identity records. There is
no automatic proposal application. The document has exactly `schema_version`,
`module` (original_sha256, compiled_sha256) and `entries`. Each entry has:

- `id`, `kind`, `disposition` (pending/rejected/accepted), and `origin`;
- `original` and `compiled`: address (hex), section, scope, symbol;
- `identity`: class and independent evidence;
- `extent`: size in bytes, basis and evidence;
- `review`: reviewer and reason. Fable accepts each entry individually.

`equiv_records.load_aliases` defines the accepted evidence classes/bases and
rejects stale hashes, ambiguous names, incompatible overlaps and invalid imports.
Unknown extents, next-boundary guesses and evidence-free identities cannot be
accepted. A reviewed annotation may establish an extent; a resource cap cannot.
The 64 KiB loader bound limits this implementation and never establishes size.
Consistent interior aliases are permitted with distinct scoped symbols.
Reviewed cell names accumulate across files; repeating one is an error.
Approved records authorize identity only: H5 content, pointer, extent coverage
and initialization validation is still outstanding in step 3. All current proof
counts remain provisional. Human acceptance/evidence is an explicit trusted input.

For `kind: pointer-cell`, each endpoint instead contains a scoped cell-record name,
`cells: [{address, section}, ...]`, `pointee: {scope, symbol, via, dll?}` and
`immutability: {class, evidence}`. `via` is original `export`/`iat` or compiled
`map`. The extent is exactly four bytes per cell. Export values, IAT DLL/name,
MAP symbols, relocations and initial pointer payloads are checked independently.
These records install no cell-to-cell identity. Several compiled cells can share
one pointee. IAT disk words are loader RVAs: the imported global gets a scoped
symbolic address, shared with its independently named compiled counterpart.
Four-byte loads fold to the canonical pointee; mutable pointee values stay mutable.
Direct writes anywhere in the decoded function, including unreachable suffixes,
and concrete indirect writes to approved cells fail UNSUPPORTED. Potentially
aliasing stores fail closed when the function uses a cell; stack/image separation
is not silently assumed. Store guards include implicit pushes and REP elements.
`--explain` distinguishes pointer-cell review evidence from pointee name evidence.
The eight reviewed records are in `equiv_data_aliases/`, pinned to the review
snapshot hashes; loading them remains explicit via `--data-alias`.

Proposal batches live in the review build directory, with initial bytes, extent
proposals and use sites; they contain no accepted entries by default. Identical
bytes or MATCH alignment may propose an entry but cannot justify its acceptance.

`equiv_certificate.schema.json` is the versioned envelope, constructed by
`equiv_records.certificate`. Steps 3–8 populate its payloads and refine their
schemas. H1–H9 start unsupported; unset evidence cannot claim discharge. Its
only supported stage is `incomplete`: no producer verdict is a validated
certificate. Step 9 supplies the bounded independent replay entry point.

Step 4 assumes ordinary DF=0 entry and rejects DF-setting bodies; every proof
route first checks individual callee-saved register and stack restoration.
Both bounded callee scans justify H3 read sets; otherwise H3c explicitly assumes
only EAX/EDX/ECX, stack arguments and DF=0 as inputs. H3/H3c records effects,
preservation, cleanup and context restrictions, including callee save-slot H1. Flags the callee leaves undefined are not observed;
UNDEFINED is a definition. Passed-through flags are inputs only when live after
the call according to live_locations (conservatively unioned for same-target
sites across both callers). REP stores invalidate only their known stack range;
unknown destinations/counts retain save facts under an explicit H1 instance.
Prologue PUSH immediates allocate space; negative floor-ESP records cleanup 0.
R1 requires agreeing own RET counts (including import thunks); R2 records the H3c
assumption cleanup=max(0,floor-ESP) and uses that same concrete count in both models.
ABI ESP/save-slot keys retain an offset and unknown-cleanup multiset. Nonempty
R3 cleanup multisets require explicit H3 restoration constraints on the call records.
Potential immutable-storage aliases require reported H5 disjoint-write predicates
(including callee effects); concrete overlaps reject. Unknown save-slot aliases
require H1; the array model still checks aliasing. Other H checks remain pending.
