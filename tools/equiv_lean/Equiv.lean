import Std

/- Bounded abstract rules only. There is no executable certificate checker or
   decoder/lifter/Python refinement bridge in this project. -/
namespace Equiv

abbrev Memory := Nat → Nat

structure Frame where
  low : Nat
  top : Nat

def Frame.owns (f : Frame) (a : Nat) : Prop := f.low ≤ a ∧ a < f.top
instance (f : Frame) (a : Nat) : Decidable (f.owns a) := inferInstanceAs (Decidable (_ ∧ _))

def overlay (f : Frame) (garbage memory : Memory) : Memory :=
  fun a => if f.owns a then garbage a else memory a

def store (memory : Memory) (address value : Nat) : Memory :=
  fun a => if a = address then value else memory a

def PublicEq (frame : Frame) (map : Nat → Nat) (a b : Memory) : Prop :=
  ∀ p, ¬ frame.owns p → a p = b (map p)

def EntrySeparation (f : Frame) (incoming : List Nat) : Prop :=
  ∀ p, p ∈ incoming → ¬ f.owns p

def CreatedPointerOwnership (f : Frame) (exposed : Nat → Prop) : Prop :=
  ∀ p, exposed p → ¬ f.owns p

def ImageRelation (a b : Frame) (map : Nat → Nat) : Prop :=
  Function.Injective map ∧ ∀ p, a.owns p ↔ b.owns (map p)

-- H4 relates only public bytes: private garbage is universally quantified,
-- independently on the two sides, with no equal-garbage premise.
theorem independent_initialization {a b : Frame} {map : Nat → Nat}
    {m n : Memory} (H4 : PublicEq a map m n) (H5 : ImageRelation a b map)
    (garbageA garbageB : Memory) :
    PublicEq a map (overlay a garbageA m) (overlay b garbageB n) := by
  intro p hp
  have hq : ¬ b.owns (map p) := fun h => hp ((H5.2 p).mpr h)
  simpa only [overlay, if_neg hp, if_neg hq] using H4 p hp

theorem incoming_read {f : Frame} {incoming : List Nat} {p : Nat}
    (H1 : EntrySeparation f incoming) (hp : p ∈ incoming) (garbage m : Memory) :
    overlay f garbage m p = m p := by
  exact if_neg (H1 p hp)

theorem exposed_read {f : Frame} {exposed : Nat → Prop} {p : Nat}
    (H2 : CreatedPointerOwnership f exposed) (hp : exposed p) (garbage m : Memory) :
    overlay f garbage m p = m p := by
  exact if_neg (H2 p hp)

theorem private_write_projection {f : Frame} {p : Nat} (inside : f.owns p)
    (m : Memory) (value : Nat) : PublicEq f id (store m p value) m := by
  intro q hq
  have hne : q ≠ p := by intro h; subst q; exact hq inside
  exact if_neg hne

theorem public_relation_composition {a b : Frame} {f g : Nat → Nat}
    {m n p : Memory} (H5 : ImageRelation a b f)
    (ab : PublicEq a f m n) (bc : PublicEq b g n p) :
    PublicEq a (g ∘ f) m p := by
  intro x hx
  exact (ab x hx).trans (bc (f x) (fun h => hx ((H5.2 x).mpr h)))

-- Composition never needs to equate the three independently chosen frames.
theorem frame_composition {a b c : Frame} {f g : Nat → Nat} {m n p : Memory}
    (H4ab : PublicEq a f m n) (H4bc : PublicEq b g n p)
    (H5ab : ImageRelation a b f) (H5bc : ImageRelation b c g)
    (garbageA garbageB garbageC : Memory) :
    PublicEq a (g ∘ f) (overlay a garbageA m) (overlay c garbageC p) := by
  exact public_relation_composition H5ab
    (independent_initialization H4ab H5ab garbageA garbageB)
    (independent_initialization H4bc H5bc garbageB garbageC)

theorem segment_load {f : Frame} {map : Nat → Nat} {m n : Memory}
    {baseA baseB offset : Nat} (H5 : PublicEq f map m n)
    (H7 : map (baseA + offset) = baseB + offset)
    (outside : ¬ f.owns (baseA + offset)) :
    m (baseA + offset) = n (baseB + offset) := by
  rw [← H7]
  exact H5 _ outside

-- The boundary FDP obligation excludes dereference of a hidden frame byte.
-- The Python non-derivation alternative is deliberately not formalized here.
theorem fp_pointer_projection {f : Frame} {fdp : Nat}
    (H9 : ¬ f.owns fdp) (garbage m : Memory) :
    overlay f garbage m fdp = m fdp := by
  exact if_neg H9

inductive Kind where
  | read | write
  deriving DecidableEq, Repr

-- A snapshot is an abstract encoding of handler-visible memory/FS/FP. Its
-- interpretation as a Python symbolic state is an outstanding bridge obligation.
structure Access where
  address : Nat
  width : Nat
  kind : Kind
  value : Nat
  snapshot : List Nat
  deriving DecidableEq, Repr

inductive Event where
  | access (a : Access)
  | call (target : Nat) (inputs : List Nat)
  | returned (target : Nat) (observed : List Nat)
  | explicitFault (kind : Nat) (condition : Bool) (snapshot : List Nat)
  deriving DecidableEq, Repr

abbrev Validity := Nat → Nat → Kind → Bool

-- Fault prefixes are ordered; the first failing access retains the snapshot
-- before that access. No page permissions or partial progress are modeled.
def firstFault (valid : Validity) (events : List Event) : Option Event :=
  match events with
  | [] => none
  | event :: rest =>
    match event with
    | .access a =>
        if valid a.address a.width a.kind then firstFault valid rest else some (.access a)
    | .explicitFault k fault state =>
        if fault then some (.explicitFault k fault state) else firstFault valid rest
    | .call _ _ => firstFault valid rest
    | .returned _ _ => firstFault valid rest
termination_by structural events

theorem ordered_faults {a b : Validity} (H6 : ∀ p w k, a p w k = b p w k)
    (events : List Event) : firstFault a events = firstFault b events := by
  induction events with
  | nil => rfl
  | cons e rest ih =>
    cases e with
    | access access =>
      change (if a access.address access.width access.kind then _ else _) = _
      rw [H6]
      exact congrArg (fun tail => if b access.address access.width access.kind
        then tail else some (.access access)) ih
    | call _ _ => exact ih
    | returned _ _ => exact ih
    | explicitFault k fault state =>
      exact congrArg (fun tail => if fault then some (.explicitFault k fault state)
        else tail) ih

-- This helper requires identical metadata, including the pre-fault snapshot.
-- It never drops a write or changes access kind, width or fault context.
theorem same_read_faults {valid : Validity} {p w x y : Nat} {snapshot : List Nat}
    (sameValue : x = y) (rest : List Event) :
    firstFault valid
      (.access ⟨p,w,.read,x,snapshot⟩ :: .access ⟨p,w,.read,y,snapshot⟩ :: rest) =
    firstFault valid (.access ⟨p,w,.read,x,snapshot⟩ :: rest) := by
  subst y
  unfold firstFault
  dsimp only
  cases h : valid p w .read with
  | false => rfl
  | true => exact if_pos h

-- Memory snapshots in a write-free interval are constant on its footprint.
-- This is the local consequence of H8 + no intervening public write, not a
-- concurrency semantics or a permission to erase arbitrary read events.
def EnvironmentInterference (memoryAt : Nat → Memory) (footprint : Nat → Prop) : Prop :=
  ∀ time p, footprint p → memoryAt time p = memoryAt 0 p

theorem repeated_read {valid : Validity} {p w first second : Nat} {snapshot : List Nat}
    {memoryAt : Nat → Memory} {footprint : Nat → Prop}
    (H8 : EnvironmentInterference memoryAt footprint) (used : footprint p)
    (rest : List Event) :
    firstFault valid
      (.access ⟨p,w,.read,memoryAt first p,snapshot⟩ ::
       .access ⟨p,w,.read,memoryAt second p,snapshot⟩ :: rest) =
    firstFault valid (.access ⟨p,w,.read,memoryAt first p,snapshot⟩ :: rest) := by
  exact same_read_faults ((H8 first p used).trans (H8 second p used).symm) rest

-- IR chunks are the already-lifted transitions between checked cut points.
-- List Event is ordered and includes all boundary observations.
structure IR (State : Type) where
  chunk : State → List Event → State → Prop
  terminal : State → Prop
  observe : State → List Nat

inductive Run {S : Type} (m : IR S) : S → List Event → S → Prop where
  | refl (s) : Run m s [] s
  | next {s t u e rest} : m.chunk s e t → Run m t rest u → Run m s (e ++ rest) u

-- These are parameters, not global axioms and not a claim that a certificate
-- was translated. A future bridge must instantiate each with the actual H rule.
structure Domain where
  EntrySeparation : Prop
  CreatedPointerOwnership : Prop
  CalleeContract : Prop
  IndependentFrameGarbage : Prop
  ImageRelation : Prop
  AccessAndFaultModel : Prop
  SegmentRelation : Prop
  EnvironmentInterference : Prop
  FPObservation : Prop

structure Hypotheses (d : Domain) : Prop where
  H1 : d.EntrySeparation
  H2 : d.CreatedPointerOwnership
  H3 : d.CalleeContract
  H4 : d.IndependentFrameGarbage
  H5 : d.ImageRelation
  H6 : d.AccessAndFaultModel
  H7 : d.SegmentRelation
  H8 : d.EnvironmentInterference
  H9 : d.FPObservation

-- H3c is a concrete instance of CalleeContract; no extra logical axiom.
-- Each VC is local: entry, one chunk, and exit. Neither run matching nor whole
-- function equivalence is assumed. Coverage of decoded instructions is external.
structure VCs {A B : Type} (d : Domain) (a : IR A) (b : IR B)
    (entry relation : A → B → Prop) : Prop where
  init : Hypotheses d → ∀ s t, entry s t → relation s t
  forward : Hypotheses d → ∀ s t e u, relation s t → a.chunk s e u →
    ∃ v, b.chunk t e v ∧ relation u v
  backward : Hypotheses d → ∀ s t e v, relation s t → b.chunk t e v →
    ∃ u, a.chunk s e u ∧ relation u v
  exit : Hypotheses d → ∀ s t, relation s t →
    (a.terminal s ↔ b.terminal t) ∧ (a.terminal s → a.observe s = b.observe t)

theorem simulate_run {A B : Type} {a : IR A} {b : IR B} {r : A → B → Prop}
    (step : ∀ s t e u, r s t → a.chunk s e u → ∃ v, b.chunk t e v ∧ r u v)
    {s u : A} {events : List Event} (run : Run a s events u) :
    ∀ t, r s t → ∃ v, Run b t events v ∧ r u v := by
  induction run with
  | refl s => intro t h; exact ⟨t, .refl t, h⟩
  | next edge rest ih =>
    intro t h
    obtain ⟨v, edgeB, related⟩ := step _ _ _ _ h edge
    obtain ⟨w, runB, final⟩ := ih v related
    exact ⟨w, .next edgeB runB, final⟩

-- All applicable H instances are explicit theorem arguments. Discharged
-- instances require proofs too; this theorem cannot silently omit a premise.
theorem cutpoint_simulation {A B : Type} {d : Domain} {a : IR A} {b : IR B}
    {entry r : A → B → Prop}
    (H1 : d.EntrySeparation) (H2 : d.CreatedPointerOwnership)
    (H3 : d.CalleeContract) (H4 : d.IndependentFrameGarbage)
    (H5 : d.ImageRelation) (H6 : d.AccessAndFaultModel)
    (H7 : d.SegmentRelation) (H8 : d.EnvironmentInterference) (H9 : d.FPObservation)
    (vc : VCs d a b entry r) {s u : A} {t : B} {events : List Event}
    (initial : entry s t) (run : Run a s events u) (done : a.terminal u) :
    ∃ v, Run b t events v ∧ r u v ∧ b.terminal v ∧ a.observe u = b.observe v := by
  let h : Hypotheses d := ⟨H1,H2,H3,H4,H5,H6,H7,H8,H9⟩
  obtain ⟨v, runB, final⟩ := simulate_run (vc.forward h) run t (vc.init h s t initial)
  have exit := vc.exit h u v final
  exact ⟨v, runB, final, exit.1.mp done, exit.2 done⟩

-- Matching in both directions also matches every finite prefix of divergence.
-- This does not assert totality, nor identify a stuttering/chunk boundary policy.
theorem cutpoint_backward {A B : Type} {d : Domain} {a : IR A} {b : IR B}
    {entry r : A → B → Prop} (h : Hypotheses d) (vc : VCs d a b entry r)
    {s : A} {t v : B} {events : List Event} (initial : entry s t) (run : Run b t events v) :
    ∃ u, Run a s events u ∧ r u v := by
  exact simulate_run (r := fun t s => r s t)
    (fun t s e v related edge => vc.backward h s t e v related edge)
    run s (vc.init h s t initial)

theorem cutpoint_equivalence {A B : Type} {d : Domain} {a : IR A} {b : IR B}
    {entry r : A → B → Prop} (h : Hypotheses d) (vc : VCs d a b entry r)
    {s : A} {t : B} (initial : entry s t) (events : List Event) (observation : List Nat) :
    (∃ u, Run a s events u ∧ a.terminal u ∧ a.observe u = observation) ↔
    (∃ v, Run b t events v ∧ b.terminal v ∧ b.observe v = observation) := by
  constructor
  · intro ⟨u,run,done,observed⟩
    obtain ⟨v,runB,final⟩ := simulate_run (vc.forward h) run t (vc.init h s t initial)
    have boundary := vc.exit h u v final
    exact ⟨v,runB,boundary.1.mp done,(boundary.2 done).symm.trans observed⟩
  · intro ⟨v,run,done,observed⟩
    obtain ⟨u,runA,final⟩ := cutpoint_backward h vc initial run
    have boundary := vc.exit h u v final
    have doneA := boundary.1.mpr done
    exact ⟨u,runA,doneA,(boundary.2 doneA).trans observed⟩

theorem append_associative {T : Type} (x y z : List T) :
    (x ++ y) ++ z = x ++ (y ++ z) := by
  induction x with
  | nil => rfl
  | cons head tail ih => exact congrArg (List.cons head) ih

theorem run_append {S : Type} {m : IR S} {s t u : S} {x y : List Event}
    (first : Run m s x t) (second : Run m t y u) : Run m s (x ++ y) u := by
  induction first with
  | refl => exact second
  | next edge rest ih =>
    rw [append_associative]
    exact Run.next edge (ih second)

-- A checked callee contract is exactly a local matching-call obligation. The
-- composition theorem uses H3 only at that call and needs no closed-program axiom.
theorem call_composition {A B : Type} {a : IR A} {b : IR B} {r : A → B → Prop}
    {s u : A} {t : B} {events : List Event} {target : Nat} {inputs : List Nat}
    (H3 : ∀ s t u, r s t → a.chunk s [.call target inputs] u →
      ∃ v, b.chunk t [.call target inputs] v ∧ r u v)
    (before : r s t) (call : a.chunk s [.call target inputs] u)
    (continuation : ∀ v, r u v → ∃ w, Run b v events w) :
    ∃ w, Run b t (.call target inputs :: events) w := by
  obtain ⟨v, edge, related⟩ := H3 s t u before call
  obtain ⟨w, rest⟩ := continuation v related
  exact ⟨w, Run.next edge rest⟩

end Equiv
