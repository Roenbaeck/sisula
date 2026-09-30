<#
    Checks every model in models/ (see check.ps1): each template's output, and the whole output,
    must be byte-identical to the original engine's. Exits 1 if anything differs.
#>
[CmdletBinding()]
param(
    [string[]] $Variant,
    [switch] $Loose
)
$root = Split-Path -Parent $PSScriptRoot
if (-not $Variant) {
    $Variant = Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name | ForEach-Object { $_.BaseName }
}
# powershell -File passes "a,b" as one string.
$Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$failed = 0
foreach ($v in $Variant) {
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $PSScriptRoot 'check.ps1'), '-Variant', $v)
    if ($Loose) { $arguments += '-Loose' }
    & powershell @arguments
    if ($LASTEXITCODE -ne 0) { $failed++ }
}
Write-Host ''
if ($failed -gt 0) { Write-Host "$failed of $($Variant.Count) models differ."; exit 1 }
Write-Host "All $($Variant.Count) models identical."
