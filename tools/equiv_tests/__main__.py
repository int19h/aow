"""Self-tests: expose known false acceptances, or enforce rejection with --strict."""
import argparse
import contextlib
import io
import json
from pathlib import Path
import runpy
import struct
import sys
import time
import traceback

sys.dont_write_bytecode = True
if __package__ in (None, ''):
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    __package__ = 'equiv_tests'

from . import game, synthetic


def classify(expected, status):
    if expected == 'prove' and not status.startswith('PROVEN under '):
        return 'CONTROL_PASS' if status == 'PROVEN' else 'ERROR'
    if status in ('NOT PROVEN', 'UNSUPPORTED'):
        return 'FIXED_OR_REJECTED'
    if status.startswith('PROVEN under '):
        import re
        premises = set(re.findall(r'H[1-9][0-9]*', status[len('PROVEN under '):]))
        allowed = set(expected.split(':', 1)[1].split(',')) if expected.startswith('conditional:') else set()
        # Do not silently accept unparsed premise names or an empty declaration.
        residue = re.sub(r'H[1-9][0-9]*|[{},; +\[\]()]', '', status[len('PROVEN under '):])
        return ('FIXED_OR_REJECTED' if premises and not residue and premises <= allowed
                else 'KNOWN_FALSE_ACCEPT')
    return 'KNOWN_FALSE_ACCEPT' if status == 'PROVEN' else 'ERROR'


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--strict', action='store_true', help='exit 1 for any known false acceptance')
    parser.add_argument('--synthetic-only', action='store_true')
    parser.add_argument('--native', action='store_true', help='native CPU integer checks (Windows x64 only)')
    parser.add_argument('--build-root')
    parser.add_argument('--game-root')
    parser.add_argument('--json', type=Path, help='write results outside the repository, e.g. cx_rva')
    parser.add_argument('--survey-unbound', nargs='*', help='optional expensive complete survey by suite group')
    args = parser.parse_args(argv)
    started = time.monotonic()
    report = dict(cases=[], evidence={})
    errors = bad = fixed = controls = 0

    def consume(cases):
        nonlocal errors, bad, fixed, controls
        for case in cases:
            before = time.monotonic()
            try:
                status, reason = case.run()
                outcome = classify(case.expected, status)
                controls += outcome == 'CONTROL_PASS'
                bad += outcome == 'KNOWN_FALSE_ACCEPT'
                fixed += outcome == 'FIXED_OR_REJECTED'
            except Exception:
                status, reason, outcome = 'EXCEPTION', traceback.format_exc(), 'ERROR'
            errors += outcome == 'ERROR'
            row = dict(name=case.name, expected=case.expected, outcome=outcome,
                       status=status, reason=reason, why=case.why,
                       seconds=round(time.monotonic() - before, 4))
            report['cases'].append(row)
            print('%s %s [%s]%s' % (outcome, case.name, status, ' ' + reason if reason else ''), flush=True)

    consume(synthetic.cases())
    report['synthetic_seconds'] = time.monotonic() - started
    try:
        if not args.synthetic_only:
            consume(game.cases(args.build_root, args.game_root, report['evidence']))
        if args.survey_unbound is not None:
            groups = args.survey_unbound or ['AoW', 'AoWTCPCK', 'P6b', 'P2', 'P5']
            report['survey'] = game.survey(groups, args.build_root, args.game_root)
        if args.native:
            if sys.platform != 'win32' or struct.calcsize('P') != 8:
                raise RuntimeError('--native requires Windows x64')
            for module in ('native_integer', 'native_division'):
                capture = io.StringIO()
                with contextlib.redirect_stdout(capture):
                    runpy.run_module('equiv_tests.' + module, run_name='__main__')
                report[module] = capture.getvalue().strip()
                print(report[module], flush=True)
    except Exception:
        errors += 1
        report['error'] = traceback.format_exc()
        print(report['error'], flush=True)
    report['summary'] = dict(known_false_acceptances=bad, rejected=fixed, controls=controls,
                             errors=errors, seconds=round(time.monotonic() - started, 3))
    print(json.dumps(report['summary']), flush=True)
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    return int(errors != 0 or (args.strict and bad != 0))


if __name__ == '__main__':
    raise SystemExit(main())
