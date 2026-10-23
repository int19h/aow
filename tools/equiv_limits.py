"""Deterministic query/search effort; elapsed time is only a visible safety net."""
import time

# Fixed host calibration (Z3 5.3.1); see cx_rva/rlimit/calibration.json.
# Deliberately generous limits: stable proofs take precedence over shortest runs.
UNITS_PER_MS = 2500
EXPECTED_MS = dict(prove=5000, filter=2000, ownership=2000,
                   diagnostic=5000, diagnostic_address=2000)
# Work and elapsed safety allowances are independent: in particular a cheap
# resource-limited filter may take over a second under concurrent host load.
RLIMIT = dict(prove=5000000, filter=250000, ownership=500000,
              diagnostic=2500000, diagnostic_address=500000)
INFERENCE_EXPECTED_MS = 20000
MAX_STEPS = 50000
used = 0
calibration = None


class SafetyCap(Exception):
    pass


def resources(solver):
    stats = solver.statistics()
    return stats.get_key_value('rlimit count') if 'rlimit count' in stats.keys() else 0


def check(solver, kind):
    global used
    ms = EXPECTED_MS[kind]
    solver.set(rlimit=0 if calibration is not None else RLIMIT[kind],
               timeout=10 * ms, random_seed=0)
    before = resources(solver)
    start = time.process_time()
    answer = solver.check()
    delta = resources(solver) - before
    used += delta
    unknown = solver.reason_unknown() if str(answer) == 'unknown' else ''
    if calibration is not None:
        calibration.append(dict(kind=kind, units=delta,
                                cpu_ms=1000 * (time.process_time()-start),
                                result=str(answer), reason=unknown))
    # Z3 also calls exact rlimit exhaustion "canceled"; it is not a timeout.
    elif str(answer) == 'unknown' and ('timeout' in unknown or
            ('canceled' in unknown and delta < RLIMIT[kind])):
        raise SafetyCap('solver safety cap: ' + kind)
    return answer


class WorkBudget:
    def __init__(self, expected_ms, reason):
        self.start = used
        self.limit = expected_ms * UNITS_PER_MS
        self.ticks = 0
        self.reason = reason
        # AST construction/simplification is not charged to Solver.rlimit.
        # The host pilot measured 19s for such a search; allow 10x 20s,
        # independently of its deterministic solver-work allowance.
        safety_ms = max(expected_ms, INFERENCE_EXPECTED_MS) if 'inference' in reason else expected_ms
        self.deadline = time.monotonic() + safety_ms / 100

    def step(self):
        from equiv_garbage import model
        self.ticks += 1
        if time.monotonic() > self.deadline:
            raise SafetyCap('solver safety cap: ' + self.reason)
        if calibration is None and (used-self.start > self.limit or self.ticks > MAX_STEPS):
            raise model().NotProven(self.reason + ' (deterministic work limit)')
