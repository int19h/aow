# Wrapper for Ghidra headless runs against the aow project.
# Examples:
#   .\ghidra.ps1 -Process AoWEPACK.dpl -Script DecompileFunctions.java -ScriptArgs @('..\..\data\decomp\x', 'name:AoWE.TUnit.')
#   .\ghidra.ps1 -Import 'D:\Games\GOG\Age of Wonders\Ilpack.dpl'
# Paths for Ghidra, the JDK, and the project directory follow the machine setup from 2026-10-19.
# ($Args is reserved in PowerShell, hence the name ScriptArgs.)
param(
    [string]$Import,
    [string]$Process,
    [string]$Script,
    [string[]]$ScriptArgs = @(),
    [string]$PreScript,
    [switch]$Analyze,
    [string]$Project = 'aow',
    [string]$ProjectDir = 'C:\Tools\ghidra-projects',
    [string]$Ghidra = 'C:\Tools\ghidra_12.1.4_PUBLIC',
    [string]$Jdk = 'C:\Program Files\Microsoft\jdk-21.0.12.101-hotspot'
)
$env:JAVA_HOME = $Jdk
$env:PATH = "$Jdk\bin;$env:PATH"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$cmd = @($ProjectDir, $Project)
if ($Import) {
    $cmd += @('-import', $Import, '-processor', 'x86:LE:32:default', '-cspec', 'borlanddelphi')
    if (-not $PreScript) { $PreScript = 'CreateDelphiFunctions.java' }
} elseif ($Process) {
    $cmd += @('-process', $Process)
    if (-not $Analyze) { $cmd += '-noanalysis' }
}
$cmd += @('-scriptPath', $scriptPath)
if ($PreScript) { $cmd += @('-preScript', $PreScript) }
if ($Script) { $cmd += @('-postScript', $Script) + $ScriptArgs }
& "$Ghidra\support\analyzeHeadless.bat" @cmd 2>&1 |
    Where-Object { $_ -match 'ERROR|error:|Exception|> |REPORT' -and $_ -notmatch 'DecompileCallback|NoReturnFunctionAnalyzer' } |
    ForEach-Object { "$_" -replace '^INFO  ', '' -replace ' \(GhidraScript\)', '' -replace ' \(HeadlessAnalyzer\)', '' }
