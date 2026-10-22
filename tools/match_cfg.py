"""Reconcile implemented MATCH checks against captured pre-change default output.

Run --suite --output-dir DIR to capture default match.py output, per-function
old/new classifications, full module totals, input hashes and changed edges.
The comparison is conservative: unresolved coverage is a classified flip, not a
claim that the recovered function is wrong. External identities are out of scope.
"""
import argparse
import collections
import contextlib
import hashlib
import io
import json
from pathlib import Path
import re
import sys
import time

sys.dont_write_bytecode = True
import addrcheck
import match
from equiv_tests.suite import suite

from match_flow import compare_cfg, helper_addresses, primary_classification


def old_output(argv):
    """Run the current default CLI and retain its exact stdout."""
    capture, previous = io.StringIO(), sys.argv
    try:
        sys.argv = ['match.py'] + argv
        with contextlib.redirect_stdout(capture):
            match.main()
    finally:
        sys.argv = previous
    return capture.getvalue()


def function_lines(text):
    by_name = collections.defaultdict(collections.deque)
    for line in text.splitlines():
        found = re.match(r'^(\S+)\s+(MATCH\s|differs(?:\s|$))', line)
        if found:
            by_name[found[1]].append(line)
    return by_name


def measure(group, argv, output, equiv_flips=False, baseline_dir=None):
    began = time.monotonic()
    baseline = (baseline_dir / (group + '.old.txt')).read_text(encoding='utf-8')
    actual = old_output(argv)
    before, after = function_lines(baseline), function_lines(actual)
    (output / (group + '.old.txt')).write_text(baseline, encoding='utf-8')
    inp = addrcheck.Inputs(argv)
    helpers = helper_addresses(inp)
    md = match.capstone.Cs(match.capstone.CS_ARCH_X86, match.capstone.CS_MODE_32)
    md.detail = True
    rows = []
    for fn in inp.functions:
        old_line, new_line = before[fn.name].popleft(), after[fn.name].popleft()
        old_match = bool(re.search(r'\sMATCH\s', old_line))
        actual_match = bool(re.search(r'\sMATCH\s', new_line))
        if old_match and actual_match and old_line != new_line:
            raise RuntimeError('retained MATCH output changed: ' + new_line)
        row = dict(group=group, module=inp.original_path.name, function=fn.name, original_name=fn.original_name,
                   original_address=hex(fn.ova), compiled_address=hex(fn.nva),
                   old='MATCH' if old_match else 'differs', new='differs', classifications=[], details=[])
        if old_match:
            from match_flow import original_extent
            extent = original_extent(inp.sigs, fn.ova, fn.osize)
            a, b, classes, details = match.control_flow(md, inp.old, inp.new, fn.ova, fn.nva,
                                                       fn.osize, fn.nsize, inp.sigs, helpers)
            if (not classes) != (actual_match):
                raise RuntimeError('%s: CLI/shared comparator disagree for %s' % (group, fn.name))
            row.update(new='differs' if classes else 'MATCH', classifications=classes, details=details,
                       original_extent=extent, compiled_extent=fn.nsize,
                       classification=primary_classification(classes))
        rows.append(row)
    default_matches = re.findall(r'^\S+\s+MATCH\s', baseline, re.M)
    totals = re.search(r'(\d+) of (\d+) functions match', baseline)
    if not totals or int(totals[1]) != sum(r['old'] == 'MATCH' for r in rows) or int(totals[2]) != len(rows):
        raise RuntimeError('%s: selection/old-output inventory does not reconcile' % group)
    if len(default_matches) != int(totals[1]):
        raise RuntimeError('%s: quiet/modified default output is not a complete baseline' % group)
    flips = [r for r in rows if r['old'] == 'MATCH' and r['new'] != 'MATCH']
    if equiv_flips and flips:
        import equiv
        eq_input = equiv.Inputs(argv)
        checker = equiv.Checker(eq_input)
        by_key = {(f.name, hex(f.ova), hex(f.nva)): f for f in eq_input.functions}
        for row in flips:
            fn = by_key[row['function'], row['original_address'], row['compiled_address']]
            row['provisional_equiv'] = checker.check(fn)
    import difflib
    totals_new = re.search(r'(\d+) of (\d+) functions match', actual)
    if not totals_new or int(totals_new[1]) != sum(r['new'] == 'MATCH' for r in rows):
        raise RuntimeError(group + ': new inventory mismatch')
    (output / (group + '.new.txt')).write_text(actual, encoding='utf-8')
    diff = ''.join(difflib.unified_diff(baseline.splitlines(True), actual.splitlines(True),
                                      fromfile=group+'.old', tofile=group+'.new'))
    (output / (group + '.diff')).write_text(diff, encoding='utf-8')
    return rows, dict(group=group, module=inp.original_path.name, functions=len(rows),
                      old_matches=int(totals[1]), flips=len(flips),
                      new_matches=sum(r['new'] == 'MATCH' for r in rows),
                      seconds=round(time.monotonic() - began, 3))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--suite', action='store_true', required=True)
    parser.add_argument('--output-dir', required=True, type=Path)
    parser.add_argument('--groups', nargs='+')
    parser.add_argument('--baseline-dir', type=Path, required=True, help='captured pre-change *.old.txt files')
    parser.add_argument('--build-root')
    parser.add_argument('--game-root')
    parser.add_argument('--equiv-flips', action='store_true', help='also run the untrusted current checker on flips')
    args = parser.parse_args(argv)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    rows, groups, inputs = [], [], []
    began = time.monotonic()
    hashes = {}
    for group, command in suite(args.build_root, args.game_root):
        if args.groups and group not in args.groups:
            continue
        for value in command:
            path = Path(value)
            if path.is_file() and value not in hashes:
                hashes[value] = hashlib.sha256(path.read_bytes()).hexdigest()
        selected, counts = measure(group, command, args.output_dir, args.equiv_flips, args.baseline_dir)
        rows += selected
        groups.append(counts)
        inputs.append(dict(group=group, argv=command))
        print(json.dumps(counts), flush=True)
        (args.output_dir / 'functions.json').write_text(json.dumps(rows, indent=2) + '\n', encoding='utf-8')
    totals = collections.defaultdict(lambda: dict(functions=0, old_matches=0, flips=0, new_matches=0))
    for counts in groups:
        for key in totals[counts['module']]:
            totals[counts['module']][key] += counts[key]
    summary = dict(modules=dict(totals), groups=groups, seconds=round(time.monotonic() - began, 3),
                   input_hashes=hashes, commands=inputs, measurement_only=False, baseline_directory=str(args.baseline_dir))
    (args.output_dir / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    lines = ['module\tgroup\tfunction\told\tnew\tclassification\tdetails\toriginal\tcompiled']
    for r in rows:
        lines.append('\t'.join((r['module'], r['group'], r['function'], r['old'], r['new'],
                                 r.get('classification', 'existing_instruction_difference'),
                                 ','.join(r['classifications']), r['original_address'], r['compiled_address'])))
    (args.output_dir / 'per-function-diff.tsv').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    (args.output_dir / 'old-vs-new.diff').write_text(''.join((args.output_dir / (g['group'] + '.diff')).read_text(encoding='utf-8') for g in groups), encoding='utf-8')
    print(json.dumps(dict(modules=dict(totals), seconds=summary['seconds'])), flush=True)


if __name__ == '__main__':
    main()
