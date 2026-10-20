#!/bin/sh
# Build every recovered package from a clean copy of the working tree (tracked files plus the
# changes in it, without untracked work in progress) and compare each with the game's module.
# Usage: tools/checkall.sh [package ...]   (default: all). Run from the repository root.
# Prints one "N of M functions match" line per package.
set -u
REPO=$(pwd)
GAME="D:/Games/GOG/Age of Wonders"
DCC=C:/Tools/Delphi3/BIN/DCC32.EXE
T=${TEMP:-/tmp}/aowchk
rm -rf "$T" && mkdir -p "$T"
git ls-files -z src/delphi3 | (cd "$REPO" && xargs -0 tar -cf -) | tar -xf - -C "$T"
S="$T/src/delphi3"
find "$S" -name '*.dcu' -delete

classes() {  # classes and units of a module, from its signature file: classes() <module> <units>
    python - "$1" "$2" <<'PY'
import json, sys
sig = json.load(open('notes/signatures/%s.json' % sys.argv[1], encoding='utf-8'))
units = set(sys.argv[2].split(','))
print(' '.join(sorted({n['name'].split('@')[0].split('.')[1] for n in sig
                       if n['name'].count('.') == 2 and n['name'].split('.')[0] in units})))
PY
}

build() {  # build <dir> <dpr> <-U paths>
    out="$T/out/$(basename "$1")_$2"
    mkdir -p "$out"
    w=$(cygpath -w "$out")
    (cd "$S/$1" && "$DCC" -GD -B -Q "-U$3" -O"$S" "-E$w" "-N$w" "$2.dpr" 2>&1 | grep -i "error\|fatal")
    echo "$out"
}

check() {  # check <name> <dir> <dpr> <-U> <module> <units> <aliases...>
    name=$1 dir=$2 dpr=$3 u=$4 mod=$5 units=$6; shift 6
    out=$(build "$dir" "$dpr" "$u" | tail -1)
    al=""
    for a in "$@"; do al="$al --alias $S/$a"; done
    cl=$(classes "$mod" "$units")
    printf '%-12s ' "$name"
    python tools/match.py --quiet --units "$units" $al "$out/$dpr.exe" "$out/$dpr.map" "$GAME/$mod" \
        notes/signatures/$mod.json $cl 2>&1 | tail -1
}

ALL=${*:-Gfxepack Dcpack Ilpack Enginep EngineGrids EngineSmall aowDPlay VideoP Network SoundP Adcpack aowFXpck aowInt}
for p in $ALL; do
  case $p in
    Gfxepack) check Gfxepack Gfxepack matchtest . Gfxepack.dpl GFXE,GFXDiag Gfxepack/match-aliases.json ;;
    Dcpack) check Dcpack Dcpack matchtest ..\\Gfxepack Dcpack.dpl DisplayC Dcpack/match-aliases.json ;;
    Ilpack) check Ilpack Ilpack matchtest ..\\Gfxepack Ilpack.dpl ImageLib,HashTabU,ILSpin,PerfDlg,ILEdGrid,ImgSetEd,SImgSEd,SubImgEd,ILEdForm Ilpack/match-aliases.json ;;
    Enginep) check Engine . matchtest "Ilpack;Gfxepack" Enginep.dpl Engine,FMemStr match-aliases.json ;;
    EngineGrids) check Grids hosts ui "..;..\\Ilpack;..\\Gfxepack" Enginep.dpl ImgLComp,EResGrid aliases/ui.json ;;
    EngineSmall) check Small hosts misc "..;..\\Ilpack;..\\Gfxepack" Enginep.dpl zlib,PlugInM,EList,DebMDlg aliases/misc.json ;;
    aowDPlay) check aowDPlay aowDPlay matchtest . aowDPlay.dpl aowDPlayComp,DPlay,DPLobby aowDPlay/match-aliases.json ;;
    VideoP) check VideoP VideoP matchtest ..\\Gfxepack VideoP.dpl Video,VFW VideoP/match-aliases.json ;;
    Network) check Network Network matchtest "..;..\\Ilpack;..\\Gfxepack" Network.dpl NetworkE Network/match-aliases.json ;;
    SoundP) check SoundP SoundP matchtest "..;..\\Ilpack;..\\Gfxepack" SoundP.dpl Sound,GalSndS,SFXEdDlg,Galaxy,DSound SoundP/match-aliases.json ;;
    Adcpack) check Adcpack Adcpack matchtest ..\\Gfxepack Adcpack.dpl ZoomControl,AdvancedDisplay Adcpack/match-aliases.json ;;
    aowFXpck) check aowFXpck aowFXpck matchtest . aowFXpck.dpl aowFX aowFXpck/match-aliases.json ;;
    aowInt) check aowInt aowInt matchtest "..\\Dcpack;..\\Gfxepack;..\\Ilpack" aowInt.dpl AoWComp,AOWInterfaceImgLib,AoWWinControl,AoWWinGeneric,AOWToolTip,AOWWinManager,AoWBaseWin,AoWControl,AoWVScroll,AoWHScroll,AOWMenu,AOWMenuBar,AoWMemo,AoWComboBox,AoWListBox,AoWPanel,AOWGauge,AoWTabPanel,AoWHTMLMemo,AoWButton,AoWEdit,AoWImage,AoWFrame,AoWDialogForm,AoWLabel,AoWWindow,aowUserDrawBox,AoWCheckBox,AOWInterfaceEditor aowInt/match-aliases.json ;;
  esac
done
