# Equivalence checker: joint repair and validation plan

Status: approved by Fable with eleven required changes incorporated here. Astra implements; Fable reviews each design, patch and evidence report, including every accepted data alias. The coordinator authorized step 0 and step 1 measurement now; later implementation retains the review gates. Failing closed is preferable to retaining coverage. No target number of PROVEN functions is an acceptance criterion.

## Observation contract and execution domain

The subject is Delphi 3 / 32-bit x86 user-mode execution of the identified original and reconstructed modules, under the declared loader, ABI and environment model. Corresponding inputs are related by a validated global storage/code mapping, not by numerical address equality or the instruction alignment being tested. Unsupported instructions, incomplete decoding, unexplained premises and solver unknown/timeouts never prove a function.

For every admitted input and environment behavior, both sides must have corresponding termination/divergence, calls in the same order with the same observable inputs, and the same synchronous exceptions visible to game handlers. Normal returns agree on the return target, EAX, EDX, ESP and observable FP state; both restore callee-saved registers and satisfy the DF contract. Debuggers, timing differences and raw OS exception-register snapshots are excluded. Ordinary Pascal entry has DF=0; calls and normal exits require DF=0 unless a checked nonstandard contract says otherwise. Exceptions must agree on their condition, kind, relevant fault information, handler selection and handler-visible state; ordinary accesses, division, BOUND and pending x87 exceptions are covered within the bounded model below.

Public memory agrees at calls, returns and checked cut points. Public reads and writes are ordered events (address, width, value); private writes remain unordered. The checker will not model concurrency semantics. H8 is the only interference statement: "no other thread writes memory this function reads or writes between its boundaries". Every verdict relying on it says so. Under H8 only, a repeated load of an address already read in the same boundary interval with no intervening public write may be dropped (the same width/kind); no other read coarsening is permitted. The bounded fault model uses an uninterpreted validity predicate over (address, width, kind) per access. Equal ordered access sequences interleaved with write events establish equal fault conditions, equal first fault and equal handler-visible memory. Kind covers read-versus-write permissions; no page-permission or partial-progress model beyond this is in scope. REP expands to its element accesses. Divide/BOUND/FP retain explicit fault predicates. Independent private-frame garbage is allowed on entry; dependence on matching that garbage is unproved. Private writes may be hidden only under the validated ownership/projection rule, including escape and alias conditions.

### Named premises and obligations

Every certificate lists each applicable H below as discharged (with evidence), assumed, or unsupported. The validator determines applicability and required obligations; the producer cannot omit them. An assumption may be used only if it is explicit, semantically coherent and belongs to the chosen execution domain.

| ID and name | Required meaning / discharge evidence |
| --- | --- |
| H1 EntrySeparation | Constrain incoming EAX, EDX, ECX, stack-argument words, and any word loaded from public memory before address use: each is not in [ESP_entry-frame, ESP_entry). ESP_entry is in [0x10000+extent, 0x80000000). Instantiate the extent per side; record established versus assumed. |
| H2 CreatedPointerOwnership | Under path conditions, stored, pushed, passed or returned values cannot expose hidden bytes; semantic alias/escape obligations, including branch-established aliases and aliases carried through memory. For returned and passed register words, outside-frame range or absence of syntactic derivation from entry ESP suffices; return/call events still require equal values, including unconstrained upper bytes. |
| H3 CalleeContract | Target identity, complete input read set, preservation, cleanup, FP/exception effects and cross-image behavior are justified; otherwise record the exact assumed contract. |
| H4 IndependentFrameGarbage | Each side's actual private allocation starts with independently quantified bytes; no read-before-definition dependence or blanket fixed-size havoc standing in for a proved extent. |
| H5 ImageRelation | Global identities, extents, byte overlap, initialized contents, pointer graph, BSS zero initialization and external anchors form one coherent module/program relation. |
| H6 AccessAndFaultModel | Per-access validity(address,width,kind), ordered accesses interleaved with writes, and explicit divide/BOUND/FP fault predicates; no page-permission or partial-progress model beyond this bounded rule. Accesses inside the owned private stack extent are assumed valid (stack exhaustion and guard-page faults excluded); each such access is an instantiated H6 assumption. |
| H7 SegmentRelation | FS and ordinary addresses refer to one linear memory through FS.base; an optional TIB-separation assumption must be explicit and sufficient for every relevant ordinary access. |
| H8 EnvironmentInterference | No other thread writes memory this function reads or writes between its boundaries. This is the only interference statement; reliance is conditional unless discharged. |
| H9 FPObservation | Relevant x87 stack/environment, operand addresses and exceptions are modeled; any restriction on callee FNSTENV/FSAVE or FP-environment observation is explicit. |

Emit `PROVEN` only when every applicable obligation is discharged in the declared domain. Otherwise emit `PROVEN under H1,H3,...` with the assumed premise names and precise instantiated predicates/contracts. Count unconditional and conditional verdicts separately, grouping conditional counts by exact assumption set. Inconsistent premises are an error, not a vacuous proof; assumptions cannot assert the desired equivalence itself. Keep NOT PROVEN and UNSUPPORTED distinct and explain unresolved obligations. Never silently promote conditional results.

## Data aliases, storage mappings and certificates

Add a versioned data-alias manifest, separate from function aliases and from automatically generated proposals. An entry identifies module hashes, original address, compiled symbol/address, kind, byte extent, extent evidence, identity evidence, related pointer targets, proposal origin, reviewer disposition and the recorded reason for acceptance. MATCH positions may propose entries. Fable accepts each entry on recorded independent evidence; neither automatic positional consistency nor coordinator approval establishes an identity. Rejected/pending proposals cannot enter proofs. Approved aliases satisfy the provenance policy only: they never waive content, extent, overlap or pointer checks. If identity is merely asserted without sufficient evidence, H5 stays assumed or the case remains unsupported.

Names must be unambiguous and scoped (including DLL/import identity and class/unit identity); strings/content records, VMT/typeinfo layouts and relocated cells require their own validation. Equal bytes alone do not identify mutable globals. No external identity may be certified solely by positions in the tested function, MATCH functions or exception tables. Local code/handler correspondences require verified CFG/table structure and instruction boundaries.

Use validated type/layout information, self-describing headers, reviewed extent annotations or certified storage regions. The next public symbol, relocation target or section end is an extent proposal, not a guaranteed object size. Alignment padding and overlapping/interior aliases must be explicit. Resource caps never establish an endpoint. Unknown indexed or callee reach beyond justified storage is unsupported; bounded accesses need a coverage proof. BSS requires justified extent and loader-zero initialization, even though there is no payload to compare. Validate initialized bytes and relocated pointer graphs independently before constructing proof premises; mismatching bytes cannot be encoded as contradictory constraints on a common array. Mutable data is not frozen to startup values at arbitrary function entries. Immutable contents must agree through direct, indexed, indirect and callee access paths.

Introduce the certificate schema in step 2b; populate and independently validate it incrementally. A certificate identifies source/tool/schema versions and hashes of binaries, maps, signatures, aliases and contracts; it records decoded ranges, entry/exit/exception roots, CFG correspondence, binding provenance, used storage ranges, all H statuses, callees/dependencies, invariants, frame relations, event rules and proof results/diagnostics. The validator is a second entry point of at most about 600 lines. It reads bindings/provenance, CFG pairing, invariants, callee contracts and H statuses, validates identified inputs/coverage, and re-runs only proof obligations with the shared instruction model. It performs no discovery and imports no Houdini or alignment code. Every proof route, including finite paths, graph variants and frames, must pass that validator. Linked callee proofs/contracts must close dependencies; recursive components require a justified joint rule. Use caching only with complete content/version keys; malformed, stale or incomplete certificates fail closed.

## Review and measurement protocol

no previously proven function is lost unless its new reason names an instruction that is a real difference or a named premise violation, or the trace establishes "previous proof relied on a checker defect (step 7 escape test), closed by this change"; the implementer traces every loss before handing in and attaches the trace.

Each numbered change is independently reviewable; Fable signs off its design and regression evidence before the next. Time-box every step: one implementation session (two total for step 2 and two total for step 5), and a line budget stated in the step's design note. Step 10 has the explicit two-session maximum below. A step that overruns ships what is done, with unfinished obligations UNSUPPORTED or reported as assumed H-premises; it never extends its scope. Budgets below count handwritten implementation and tests; generated suite data and measurement artifacts are excluded. Execution order: 0, 1, 2a, 2b, 4, 7, 6, 3, 5a, 5b, 8, 9, 10, 11. Every step reports before/after MATCH, unconditional PROVEN, conditional PROVEN (by assumption set), NOT PROVEN and UNSUPPORTED counts, per module and total, with per-function transitions and reasons; report unimplemented categories as not yet classified rather than mislabeling old results. No historical verdict is grandfathered. Until the corresponding independent checks exist, discovery counts are provisional and do not restore certification. Report fixture outcomes and separate preprocessing, discovery and validation timings, cold/warm cache policy and host. At every executable step measure the full module suite against the roughly 30-minute total target; an overrun prompts caching/budget changes or fewer proofs, never weaker obligations. Report any incomplete run explicitly. Pin inputs and enumerate all selected functions so missing, duplicated, truncated and newly differing functions reconcile. Historical 12,697/13,303 matches and 125/491 proofs are reference counts, to be refreshed on the pinned inputs.

### Step 0 — Fixture harness and pinned baseline

Design box: one session; at most 900 handwritten code lines including tests.

Change: add `tools/equiv_tests/` and a discoverable self-test entry point; preserve both reviewers' fixtures and native integer/division checks. Game-derived tests patch installed binaries at runtime by path/address; never commit game bytes.

Acceptance: the baseline exposes every known false acceptance, with the corrected expected verdict recorded; positive controls distinguish safe equivalences from rejected mutants. Synthetic tests run under one minute; time game cases separately.

Report: pinned baseline inventory, known failing tests, existing counts/timings and exact commands for all modules.

### Step 1 — MATCH control flow and complete coverage

Design box: one session; at most 500 handwritten code lines including tests. Measure old/new default outputs over all modules before any match.py change is merged; start with a separate measurement script and keep default behavior untouched. Preserve match.py output format for retained matches.

Change: compare direct local successors under checked instruction correspondence, displaying function-relative offsets; require targets to land on decoded boundaries. Check external transfers independently, and cover reachable suffixes, jump tables and exception metadata. Replace compiled-prefix truncation as certification evidence in match/addrcheck inputs.

Acceptance: branch retargeting, mid-instruction targets and added reachable suffixes lose MATCH; relocation-only controls retain it. Benign encoding/layout differences may fail closed, with an explicit reason and an equiv candidate.

Report: full old/new per-function diffs for every module, not just totals; classify changed edges, benign layout changes, incomplete boundaries and unsupported tables/handlers. Run every flipped MATCH through equiv as a provisional diagnostic. Retire the old MATCH-derived address evidence before trusting subsequent proofs; distinguish shape match from certification.

### Step 2a - Remove positional premises and correct relocated operands

Design box: one session (first of step 2's two); at most 250 handwritten code lines including tests.

Change: remove external positional certification in the tested function, MATCH evidence and exception tables; canonicalize relocated displacements with or without base/index, otherwise keep them literal; add `--explain` provenance.

Acceptance: this step alone rejects Fable's three real-game substitutions and Astra's invented-callee fixture; numeric-offset mutants resembling image addresses are not hidden; proof order cannot change accepted bindings.

Report: removed positional bindings, unresolved identities, fixtures and standard counts/timings.

### Step 2b - Reviewed data aliases and certificate schema

Design box: one session (second of step 2's two); at most 350 handwritten code lines including tests.

Change: add the manifest, batch proposal/acceptance records and certificate schema described above; no workflow application. Fable accepts each entry with an evidence class and recorded identity/extent justification.

Acceptance: pending, rejected or evidence-free entries cannot certify functions; g->h plus g+4->h+2 conflicts; duplicate names/wrong DLL/classes and malformed provenance reject. Steps 3-8 populate certificates incrementally.

Report: proposed/accepted/pending aliases, provenance and standard counts/timings.

### Step 4 — Calls and returns

Design box: one session; at most 400 handwritten code lines including tests.

Change: compare all potentially observed registers/flags by default; add DF and uniform save/restore obligations. Allow omission only through conservative def-before-use/read-set analysis on both direct callees, covering CFG paths, partial registers, implicit/address operands and flags. The scan is intraprocedural over the reachable callee CFG; fail closed on indirect jumps, unresolved calls or more than one nesting level. Unknowns retain full comparison. Check forwarding thunks and contract/proof dependencies; indirect ABI assumptions are H3, not unconditional facts.

Acceptance: EBX/carry helper mutations reject; missing restores/DF changes reject; unsummarized asm/indirect targets cannot bypass input checks. Positive leaf/thunk controls pass. The 41 rename cases are measured, not a preservation quota.

Report: headline H3-conditional virtual-call counts (near-zero unconditional coverage is expected), full-input/summary coverage, dependencies and standard counts/timings.

### Step 7 — Independent frame garbage and exception/frame compatibility

Design box: one session; at most 300 handwritten code lines including tests.

Change: quantify private-entry bytes independently on every route. verify_fast uses the same prologue extent scan as Frames (callee-saved pushes, sub esp); if the scan cannot reach a fixed point, the route fails closed. Dependence on garbage is NOT PROVEN with reason "reads uninitialized private slot". Until a linked exceptional-entry relation is proved, exception regions use only the compatible whole-memory route; finite-path/acyclic fallbacks cannot bypass this gate. Class-table identities require justified external bindings.

Acceptance: read-before-write locals and the two-function stack-garbage composition test remain unproved; verified initialization/save/restore passes; changing handler classes or enabling an incompatible frame fallback rejects.

Report: garbage dependence, exception-gated proofs, route coverage and counts/timings.

### Step 6 — Frame entry separation and semantic escape

Design box: one session; at most 350 handwritten code lines including tests.

Change: implement H1/H2, using established caller/ABI ownership where available; otherwise retain the precise H1 premise as conditional, concretely instantiating the incoming values/range in H1. Prove semantic non-escape under guards; cover stored, pushed, passed, returned and memory-carried aliases.

Acceptance: the branch-established input alias cannot receive unconditional PROVEN; it either rejects or has an explicit H1 excluding that input. Created-pointer escapes reject even through branches/partial representations; safe mappings pass.

Report: established versus assumed ownership, masked extents, escape reasons and counts/timings.

### Step 3 — Data contents, extents and initial-state relation

Design box: one session; at most 500 handwritten code lines including tests.

Change: implement H5 validation, recursive relocated pointer checks and coherent immutable-memory semantics.

Acceptance: typed-constant/table byte changes, wrong pointer targets, undersized coverage, shifted overlapping objects and invalid BSS mappings reject. Direct, indexed, indirect and pointer-to-callee reads expose differing immutable bytes. Positive tests permit legitimate runtime mutations of mutable globals and reject contradictory initial-state premises.

Report: content/extent/pointer failures, bytes/objects validated, remaining assumed H5 cases and counts/timings.

### Step 5a - Ordered public events

Design box: one session (first of step 5's two); at most 350 handwritten code lines including tests.

Change: public reads and writes become ordered (address,width,value) events with boundary memory equality. Do not model concurrency semantics; instantiate H8 exactly and display all reliance. Only under H8 drop repeated loads already read in the same interval with no intervening public write; no other read coarsening.

Acceptance: reversed/extra public writes reject; repeated-read controls need explicit H8; intervening writes prevent coarsening. Private writes stay unordered under ownership.

Report: event failures, H8 reliance, coarsened loads and standard counts/timings.

Result (Fable approved after two revisions): 12,875 MATCH, 41 conditional PROVEN, 186 NOT PROVEN, 226 UNSUPPORTED; 288,383 queries uncached and cold. Accepted pointer cells and immutable data are not read events, each side looked up in its own tables. One stack bound, lowest = min(prologue extent, static minimum ESP offset), serves H1, H2 and event privacy. Eleven earlier proofs retracted: their outgoing-argument slots made the H1 premises jointly unsatisfiable. H8 is used by four functions with a dropped load.

Follow-ups (accepted conservatism): (1) the eleven need step 7b must-write coverage for callees reached through virtual and IAT calls; (2) pushed words lack the non-derivation fallback that register words have (TDrawImagePanel.DrawLibraryImage); (3) garbage masking still uses the prologue extent, so below-extent temporaries are compared publicly at boundaries. Cosmetic: the H2 witness names the instruction before the call.

Resourcestring content source (tools/equiv_resources.py, Fable approved): a record (module handle, resource ID) is equal when each side's own RT_STRING text for its own ID is equal; IDs stay opaque, the module field is pointer identity with the HInstance cells bound, and the record may only flow into System.LoadResString. Pairs need an independent binding plus equal text, or exactly one record with that text on each side: 721 paired, 0 unequal, 428 unpaired (392 without an equal-text partner, 37 ambiguous) and so UNSUPPORTED. No verdict changed. Follow-ups: no game function proves through this source yet, so recognizing the original's LoadResString thunk is fixture-tested only; Exception.CreateRes-style wrappers fail closed.

### Step 5b - Bounded synchronous fault predicates

Design box: one session (second of step 5's two); at most 350 handwritten code lines including tests.

Change: validity(address,width,kind) per access, equal ordered accesses interleaved with writes; apply only the repeated-load coarsening permitted by step 5a (identical address/width/kind under H8). No page-permission or partial-progress model beyond this; REP expands to element accesses; divide/BOUND/FP keep explicit predicates.

Acceptance: missing loads, changed access kind/width, reordered first faults around public writes, division/BOUND and WAIT regressions reject; equal supported access sequences establish equal faults and handler-visible memory.

Report: access/fault failures, bounded-model assumptions and standard counts/timings.

Result (tools/equiv_faults.py, Fable approved): counts unchanged (12,875 MATCH, 41 conditional PROVEN, 186 NOT PROVEN, 226 UNSUPPORTED); all 41 proofs now name H6; 288,456 queries uncached and cold. Follow-ups: label H6 whenever any validity or fault predicate is emitted, not only when a private instance exists (a proof with only public accesses now reads as unconditional); a duplicated WAIT rejects (conservative); explicit-fault diagnostics repeat "fault condition".

### Step 8 — Segment and x87 state

Design box: one session; at most 300 handwritten code lines including tests.

Change: unify FS/linear memory or require explicit sufficient H7 separation; include relevant FP environment and effective operand addresses. Treat restricted callee FP-environment observation as H9 rather than an implicit convention.

Acceptance: the TIB-alias fixture, differing x87 operand-pointer state and pending-exception memory fixtures reject unconditionally; any conditional acceptance displays precisely the restriction excluding the distinguishing context.

Report: segment/FP assumptions, unsupported forms and counts/timings.

### Step 9 - Bounded replay and mutation adjudication

Design box: one session; second validator entry point at most about 600 lines, plus at most 150 test lines.

Change: replay certificates with shared instruction semantics; no discovery, Houdini or alignment imports. Every proof route uses replay. Add baseline substitutions of globals/tables/callees/classes, typed bytes, relocation targets, branches and suffixes.

Acceptance: forged bindings, missing edges/events, weakened H predicates, stale hashes, malformed certificates and unknown/timeouts reject. Known bad mutants reject on every route. List each survivor with its differing instruction; it is "equivalent" only with a one-line argument Fable accepts in review, otherwise unresolved and counted as such. No concrete-execution interpreter unless session time remains; random survival is not proof.

Report: replay coverage, mutations, accepted arguments/unresolved survivors and standard counts/timings.

### Step 10 - Bounded Lean rules and hypothesis coverage

Design box: two sessions maximum; at most 500 Lean lines plus 80 Python hypothesis-coverage test lines.

Change: formalize the validator's abstract IR, cut-point simulation theorem and frame/composition lemma with named H1-H9; add a Python test that every proof route emits applicable named side conditions.

Acceptance: theorems compile without admitted proofs; broken projection/initialization examples expose failed obligations; coverage tests reject routes omitting hypotheses. Named functions and coverage are not a verified refinement bridge. The executable Lean certificate checker, Lean-side VC comparison and any refinement bridge are future work, outside this plan.

Report: theorem/test status, remaining decoder/lifter/semantics/solver trust and standard counts/timings.

### Step 11 — Full requalification and final review

Design box: one session; at most 150 handwritten code lines including tests.

Change: rerun all modules, all previous 125 PROVEN functions, all former MATCH functions and every newly exposed candidate.

Acceptance: reconcile the complete inventory; every accepted verdict has a replayable certificate and visible assumptions; no grandfathered result, unexplained mutant or unsupported path contributes to unconditional certification.

Report: old/new per-function and module tables, retained/downgraded/new proofs, conditional premise sets, MATCH audit, alias/callee dependency inventory and total cold-run time against 30 minutes. Fable reviews design, code and evidence.

## Remaining choices and selected defaults

- External identities: cheap automatic proposals cannot justify identity; Fable-reviewed aliases cost review time. Pick per-entry recorded evidence plus machine-checked consistency; evidence-free entries stay pending and functions UNSUPPORTED.
- Extents: guessed next-boundary/capped objects are cheap; justified regions/types/annotations cost recovery effort. Pick justified coverage including BSS; a cap never establishes an endpoint.
- Entry aliasing: establishing caller ownership costs analysis; concrete H1 retains conditional coverage cheaply. Permit both, but only discharged H1 supports unconditional PROVEN.
- H8: concurrency modeling is open-ended and removed from this plan; the exact no-other-thread-writes premise is bounded but conditional. Pick H8, ordered events and only the one repeated-load rule, exposing every reliance.
- Faults: sets alone are cheaper but insufficient; ordered accesses plus validity(address,width,kind) are bounded. Pick the latter, with no page-permission/partial-progress implementation in scope.
- Disagreement: hardware partial-progress behavior requires future validation or an explicit execution-domain restriction; I apply Fable's bounded H6 model now, without calling it an end-to-end hardware fault proof.
- Indirect calls: checked summaries cost effort; a Pascal convention H3 costs assumptions. Default to full inputs and headline H3-conditional virtual-call counts; low unconditional counts are expected.
- FS/FP: complete models cost code/proofs; restrictions yield H7/H9-conditional coverage. Use explicit restrictions if the time box precludes stronger modeling, never hidden assumptions.
- Lean: executable replay/refinement is stronger but open-ended; abstract theorems plus coverage are bounded. Pick the bounded scope now; an executable checker/refinement and checked solver evidence remain future work.
