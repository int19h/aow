"""Portable argument inventory shared by runtime game fixtures and CFG measurement."""
import json
from pathlib import Path
import tempfile

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_GAME = Path('D:/Games/GOG/Age of Wonders')


def suite(build_root=None, game_root=None):
    replacements = {
        '${repo}': ROOT.as_posix(),
        '${build}': Path(build_root or tempfile.gettempdir()).as_posix(),
        '${game}': Path(game_root or DEFAULT_GAME).as_posix(),
    }
    groups = json.loads(Path(__file__).with_name('suite.json').read_text(encoding='utf-8'))
    for group, argv in groups.items():
        result = []
        for value in argv:
            for key, replacement in replacements.items():
                value = value.replace(key, replacement)
            result.append(value)
        yield group, result
