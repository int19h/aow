# One iteration of the naming loop for one package (default AoWEPACK.dpl):
#   build classes.json -> apply structs in Ghidra -> dump the package -> snapshot classes.json next to the dump
#   -> rebuild the field tables from the dump -> rebuild classes.json and engine-classes.md.
# Usage: .\tools\pipeline.ps1 [-Module AoWEPACK.dpl] [-Rtti notes\rtti\AoWEPACK.dpl.txt] [-SkipGhidra]
param(
    [string]$Module = 'AoWEPACK.dpl',
    [string]$Rtti = '',
    [string]$GameDir = 'D:\Games\GOG\Age of Wonders',
    [switch]$SkipGhidra
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$notes = Join-Path $repo 'notes'
$tools = Join-Path $repo 'tools'
if (-not $Rtti) { $Rtti = Join-Path $notes "rtti\$Module.txt" }
$dump = Join-Path $notes "decomp\$($Module -replace '\.dpl$|\.exe$','')-typed"
$tables = @((Join-Path $notes 'persisted-fields.md'), (Join-Path $notes 'persisted-fields-base.md'), (Join-Path $notes 'field-names.md'), (Join-Path $notes 'field-overrides.md'))
$classes = Join-Path $notes 'classes.json'

python (Join-Path $tools 'build_classdb.py') $GameDir $classes @tables
if (-not $SkipGhidra) {
    & (Join-Path $tools 'ghidra\ghidra.ps1') -Process '*' -Script ApplyDelphiClasses.java -ScriptArgs @($classes) | Where-Object { $_ -match 'typed on|ERROR|could not' }
    if (Test-Path $dump) { Rename-Item $dump "$dump-prev-$(Get-Date -Format yyyyMMdd-HHmmss)" }
    & (Join-Path $tools 'ghidra\ghidra.ps1') -Process $Module -Script DecompileFunctions.java -ScriptArgs @($dump) | Where-Object { $_ -match 'decompiled|ERROR' }
}
Copy-Item $classes (Join-Path $dump 'classes.json') -Force
python (Join-Path $tools 'readwrite_table.py') $dump $tables[0]
python (Join-Path $tools 'field_names.py') $dump $tables[2]
python (Join-Path $tools 'build_classdb.py') $GameDir $classes @tables
python (Join-Path $tools 'class_layout.py') $Rtti $tables[0] $tables[2] (Join-Path $notes 'engine-classes.md')
"indirect rows: " + ((Get-Content $tables[0]) | Where-Object { $_ -match 'indirect' }).Count
