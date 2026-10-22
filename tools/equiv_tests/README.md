# Checker review fixtures

Run from the repository root:

```powershell
python -B tools/equiv.py --selftest --native --json "$env:TEMP/cx_rva/step0-results.json"
python -B tools/equiv.py --selftest --synthetic-only --strict
python -B -m unittest discover -s tools -t tools -p test_cfg.py
python -B tools/match_cfg.py --suite --baseline-dir "$env:TEMP/cx_rva/cfg_measure_handlers" --output-dir "$env:TEMP/cx_rva/cfg_measure_all"
```

The default self-test reports `KNOWN_FALSE_ACCEPT` explicitly and exits successfully
only if its fixtures/controls execute without errors. This is a baseline inventory,
not a clean bill of health. `--strict` exits 1 while any known false acceptance remains.
Conditional expectations list allowed premises (H1 for alias fixtures, H9 for the
x87 pointer fixture). Only a nonempty subset counts as fixed; other conditionals
remain known false acceptances. Rejections are not independently proved inequivalences.

Synthetic machine bytes are hand-authored. Native checks exercise 8/16/32-bit
operands in Windows x64 and are isolated to the explicit `--native` option; they do
not establish the entire x86 model. Raw divide-register context is an excluded-domain
control, not an expected rejection under the agreed observation contract.

`game.py` ports Fable's `wrong2.py` and `unbound.py` algorithms. It loads the installed
AoW.exe and the reconstructed build by path, finds the named functions and operands,
and substitutes operands **before** address preparation. It never writes a binary
or embeds game bytes. The JSON report includes the pre-proof unbound-reference survey.
Already-bound/out-of-image replacement candidates are listed as skipped, not counted
as rejected. Missing files/functions/operands are errors, never passing fixtures.
`--survey-unbound AoW P6b` runs the optional complete survey for those groups.
The AoWTCPCK fixture also drops the identified private store in
`TCenterViewLocation.CanPlace` in memory to expose Fable's stack-garbage case.

`suite.json` records the review's game part lists plus the library groups from
`tools/checkall.sh`; paths use `${repo}`, `${build}` and `${game}` placeholders.
Defaults: current checkout, the system temporary directory and
`D:/Games/GOG/Age of Wonders`. Use `--build-root` / `--game-root` to override.
Game builds are under `cx_main_*`; existing library builds under `aowchk/out`.

The CFG measurement uses a captured pre-change baseline and records current match.py
stdout for every group,
checks its old classification counts against the inventory, and writes `.old.txt`,
`.new.txt`, `functions.json`, `summary.json` (including input hashes), and
`per-function-diff.tsv` outside the repository. Retained function lines keep the
default format. It is conservative MATCH measurement, not equivalence certification:
relative-offset/layout differences and incomplete coverage are classified separately
from changed edges. Full compiled ranges and bounded original extensions to the next signature expose
reachable suffixes; unresolved decode/table/handler coverage remains a diagnostic.
External target identities and non-CFG instruction semantics are outside this overlay.
