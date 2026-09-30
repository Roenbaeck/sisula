<#
    Regenerates golden/<variant>/<Sisulet>.sql for every variant with the ORIGINAL Anchor engine
    (see golden.ps1). Needs an Anchor checkout next to this repository, or -Anchor. The golden
    files are committed, so the tests themselves do not need Anchor.
#>
[CmdletBinding()]
param(
    [string[]] $Variant = @('base', 'equivalence', 'plain', 'equivalence-plain'),
    [string[]] $Sisulet = @('CreateKnots', 'CreateAnchors', 'CreateAttributes', 'CreateTies'),
    [string] $Anchor
)
$root = Split-Path -Parent $PSScriptRoot
foreach ($v in $Variant) {
    New-Item -ItemType Directory -Force (Join-Path $root "golden\$v") | Out-Null
    foreach ($s in $Sisulet) {
        $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $PSScriptRoot 'golden.ps1'),
            '-Model', (Join-Path $root "models\$v.xml"), '-Sisulet', $s, '-Out', (Join-Path $root "golden\$v\$s.sql"))
        if ($Anchor) { $arguments += @('-Anchor', $Anchor) }
        & powershell @arguments
        if ($LASTEXITCODE -ne 0) { throw "golden.ps1 failed for $v/$s" }
    }
}
