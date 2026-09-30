<#
    Derives the variant models from models/base.xml by text edits, so the branches the base model
    does not reach are still exercised: equivalence, generator knots, equivalent and checksummed
    attributes, and a model without metadata columns. Every edit must match, or the script stops.
#>
[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$models = Join-Path (Split-Path -Parent $PSScriptRoot) 'models'
$base = [IO.File]::ReadAllText((Join-Path $models 'base.xml'))

function Edit([string] $text, [string] $pattern, [string] $replacement, [int] $expected = 1) {
    $count = [regex]::Matches($text, $pattern).Count
    if ($count -ne $expected) { throw "Expected $expected match(es) of '$pattern' but found $count" }
    [regex]::Replace($text, $pattern, $replacement)
}
function Save([string] $name, [string] $text) {
    [IO.File]::WriteAllText((Join-Path $models "$name.xml"), $text, (New-Object Text.UTF8Encoding($false)))
    Write-Host "wrote models\$name.xml"
}

# equivalence: turned on, with one generator+equivalent knot, one equivalent knot, one plain
# generator knot, and equivalent and checksummed attributes (static and historized).
$t = $base
$t = Edit $t 'equivalence="false"' 'equivalence="true"'
$t = Edit $t '(<knot mnemonic="PAT"[^>]*>\s*<metadata capsule="public" generator=")false(")' '${1}true" equivalent="true$2'
$t = Edit $t '(<knot mnemonic="GEN"[^>]*>\s*<metadata capsule="public" generator="false")' '$1 equivalent="true"'
$t = Edit $t '(<knot mnemonic="RAT"[^>]*>\s*<metadata capsule="public" generator=")false(")' '${1}true$2'
$t = Edit $t '(<attribute mnemonic="NAM"[^>]*timeRange[^>]*>\s*<metadata privacy="Ignore" capsule="public")' '$1 equivalent="true" checksum="true"' 2
$t = Edit $t '(<attribute mnemonic="LOC"[^>]*>\s*<metadata privacy="Ignore" capsule="public")' '$1 equivalent="true"'
Save 'equivalence' $t

# plain: no metadata columns, the original naming convention, partitioning on.
$t = $base
$t = Edit $t 'metadataUsage="true"' 'metadataUsage="false"'
$t = Edit $t 'naming="improved"' 'naming="original"'
$t = Edit $t 'partitioning="false"' 'partitioning="true"'
Save 'plain' $t

# equivalence-plain: the equivalence model without metadata columns, which reaches the dummy
# column that equivalent knots get in its place.
$t = [IO.File]::ReadAllText((Join-Path $models 'equivalence.xml'))
$t = Edit $t 'metadataUsage="true"' 'metadataUsage="false"'
Save 'equivalence-plain' $t
