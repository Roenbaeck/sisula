<#
    Checks every model in models/ (see check.ps1): each template's output, and the whole output,
    must be byte-identical to the original engine's. Exits 1 if anything differs.

    Usage:
      run-all.ps1 [-Variant <name>,...] [-Temporalization uni|bi|crt] [-Name <template>,...] [-Loose] [-Anchor <checkout>]

    -Temporalization keeps the models that are for that temporalization. -Name renders only those
    templates, which also skips the comparison of the whole output (see check.ps1). -Anchor reads
    the templates, directive and engine from another checkout, for instance a worktree.
#>
[CmdletBinding()]
param(
    [string[]] $Variant,
    [ValidateSet('uni', 'bi', 'crt')] [string] $Temporalization,
    [string[]] $Name,
    [switch] $Loose,
    [string] $Anchor
)
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'directive.ps1')
if (-not $Variant) {
    $Variant = Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name | ForEach-Object { $_.BaseName }
}
# powershell -File passes "a,b" as one string.
$Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
if ($Temporalization) {
    $Variant = @($Variant | Where-Object { (Get-ModelTemporalization (Join-Path $root "models\$_.xml")) -eq $Temporalization })
}
$failed = 0
foreach ($v in $Variant) {
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $PSScriptRoot 'check.ps1'), '-Variant', $v)
    if ($Loose) { $arguments += '-Loose' }
    if ($Anchor) { $arguments += @('-Anchor', $Anchor) }
    if ($Name) { $arguments += @('-Name', ($Name -join ',')) }
    & powershell @arguments
    if ($LASTEXITCODE -ne 0) { $failed++ }
}
Write-Host ''
if ($failed -gt 0) { Write-Host "$failed of $($Variant.Count) models differ."; exit 1 }
Write-Host "All $($Variant.Count) models identical."
