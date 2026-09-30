<# Checks every variant. Exits 1 if any template output differs from its golden file. #>
[CmdletBinding()]
param([string[]] $Variant = @('base', 'equivalence', 'plain', 'equivalence-plain'))
$failed = 0
foreach ($v in $Variant) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'check.ps1') -Variant $v
    if ($LASTEXITCODE -ne 0) { $failed++ }
}
if ($failed -gt 0) { exit 1 }
