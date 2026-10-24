# Export name hashes of Delphi 3 packages (research scripts)

Every export of a Delphi 3 package carries `@XXXXXXXX`, a hash of the declaration. A helper of the
HSEPack work reconstructed the hash function from the shipped modules. These are its scripts as
they were left (2026-10-20): `th.py` holds the base type hashes and the formulas for names
(`h * 17 + ord(c)` modulo 2^32), records, arrays and routines; `hh.py`, `cls.py` and `var.py`
extend them to classes and variables; `inv.py`, `solve.py` and `solve2.py` invert the formulas to
recover unknown type names; the others are one-off checks.

What the hashes cover: parameter and result types, calling convention, record layout, and for
classes the visibility and the types of everything outside the private section, recursively;
not field, parameter or property names. `tools/exports.py` compares the hashes of a package built
from the recovered source with the original. These scripts would let the declarations be checked
offline, without a package build, which matters for the pass over Engine.pas's class declarations.
