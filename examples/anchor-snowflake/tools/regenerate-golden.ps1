<#
    Writes golden/<variant>/ for every model in models/ (or the ones named) from the output of Anchor's
    Sisula templates, with the engine that Anchor ships (see check.ps1 -Update). Needs an Anchor
    checkout next to this repository, or -Anchor.

    The golden files are approved output, not an independent check: a change to a template changes them,
    and the change is read in git diff before it is committed. What checks them independently is
    lint-sql.ps1 (known defects), csharp-check.ps1 and browser-check.ps1 (other implementations of the
    engine and of the path from a model to SQL), and above all running the SQL on Snowflake.

    Usage:
      regenerate-golden.ps1 [-Variant <name>,...] [-Anchor <checkout>]
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
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $PSScriptRoot 'check.ps1'), '-Variant', $v, '-Update')
    if ($Anchor) { $arguments += @('-Anchor', $Anchor) }
    & powershell @arguments
    if ($LASTEXITCODE -ne 0) { throw "check.ps1 -Update failed for $v" }
}
