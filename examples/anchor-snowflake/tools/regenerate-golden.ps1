<#
    Regenerates golden/<variant>/ for every model in models/ with the ORIGINAL Anchor engine (see
    golden.ps1). Needs an Anchor checkout next to this repository, or -Anchor. The golden files
    are committed, so the checks themselves do not need to run the original engine.
#>
[CmdletBinding()]
param(
    [string[]] $Variant,
    [string] $Anchor
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Variant) {
    $Variant = Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name | ForEach-Object { $_.BaseName }
}
# powershell -File passes "a,b" as one string.
$Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
foreach ($v in $Variant) {
    $outDir = Join-Path $root "golden\$v"
    # Start from an empty directory, so a sisulet that no longer produces output leaves no stale file.
    if (Test-Path $outDir) { Remove-Item (Join-Path $outDir '*.sql') }
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $PSScriptRoot 'golden.ps1'),
        '-Model', (Join-Path $root "models\$v.xml"), '-OutDir', $outDir)
    if ($Anchor) { $arguments += @('-Anchor', $Anchor) }
    & powershell @arguments
    if ($LASTEXITCODE -ne 0) { throw "golden.ps1 failed for $v" }
}
