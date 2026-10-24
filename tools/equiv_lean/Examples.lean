import Equiv

namespace Equiv.Examples

def frame : Frame := ⟨8, 12⟩
def zero : Memory := fun _ => 0
def one : Memory := fun _ => 1

-- Independent private bytes preserve the public relation, but not a return
-- value loaded from an uninitialized slot. Initialization/exit VCs must catch it.
theorem arbitrary_garbage_public :
    PublicEq frame id (overlay frame zero zero) (overlay frame one zero) := by
  apply independent_initialization (a := frame) (b := frame) (map := id)
  · intro p _; rfl
  · exact ⟨fun _ _ h => h, fun _ => Iff.rfl⟩

theorem uninitialized_return_differs :
    overlay frame zero zero 8 ≠ overlay frame one zero 8 := by decide

-- A projection that erases public memory can claim equality while the actual
-- public state differs. It cannot discharge the frame/projection obligation.
def brokenProjection (_ : Memory) : Nat := 0

theorem broken_projection_equal : brokenProjection zero = brokenProjection one := rfl

theorem broken_projection_not_public : ¬ PublicEq frame id zero one := by
  intro h
  have bad := h 0 (by decide)
  contradiction

-- Removing entry separation is observably wrong: an incoming pointer may read
-- private bytes. The required incoming_read premise is false, not silently true.
theorem missing_entry_separation : ¬ EntrySeparation frame [8] := by
  intro h
  exact h 8 (.head []) (by decide)

def goodRead : Access := ⟨100, 4, .read, 7, [0]⟩
def badWrite : Access := ⟨100, 4, .write, 7, [0]⟩
def readOnly : Validity := fun _ _ k => k == .read

theorem access_kind_is_observed :
    firstFault readOnly [.access goodRead] ≠ firstFault readOnly [.access badWrite] := by
  intro h
  cases h

-- A fault cannot move across a write that changed handler-visible state.
def denied : Validity := fun _ _ _ => false
theorem fault_snapshot_is_observed :
    firstFault denied [.access ⟨100,4,.read,0,[0]⟩] ≠
    firstFault denied [.access ⟨100,4,.read,0,[1]⟩] := by
  intro h
  cases h

-- A nonempty, memory-free instance discharges the named conditions and uses
-- the simulation theorem; the VC relation and entry set are inhabited.
def noMemoryDomain : Domain := ⟨True,True,True,True,True,True,True,True,True⟩
def counterIR : IR Nat :=
  ⟨fun s events t => events = [] ∧ t = s + 1, fun _ => True, fun s => [s]⟩

def counterVC : VCs noMemoryDomain counterIR counterIR Eq Eq where
  init := by intro _ s t h; exact h
  forward := by
    intro _ s t events u h edge
    subst t
    exact ⟨u,edge,rfl⟩
  backward := by
    intro _ s t events v h edge
    subst t
    exact ⟨v,edge,rfl⟩
  exit := by
    intro _ s t h
    subst t
    exact ⟨Iff.rfl,fun _ => rfl⟩

theorem counter_simulation {s u : Nat} {events : List Event}
    (run : Run counterIR s events u) :
    ∃ v, Run counterIR s events v ∧ u = v ∧ counterIR.terminal v ∧
      counterIR.observe u = counterIR.observe v := by
  exact cutpoint_simulation (d := noMemoryDomain)
    True.intro True.intro True.intro True.intro True.intro True.intro
    True.intro True.intro True.intro counterVC rfl run True.intro

#print axioms independent_initialization
#print axioms cutpoint_simulation
#print axioms call_composition
#print axioms uninitialized_return_differs
#print axioms broken_projection_not_public

end Equiv.Examples
